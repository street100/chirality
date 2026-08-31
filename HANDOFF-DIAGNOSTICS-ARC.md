# Diagnostics arc — handoff (2026-08-31)

**Self-contained.** A fresh session should be able to resume from this file alone.
Stopped because a spend limit killed the E175 implement agent mid-run; the session
limit resets 5:40pm America/New_York.

## Where everything lives

- **Work branch:** `e158-doc` in the worktree **`/workspace/chirality-verify`**
  (a `git worktree` off `/workspace/chirality`). **Do not work in
  `/workspace/chirality` itself** — another session tests and audits there. Never
  put scratch or worktrees in `/tmp`; this sandbox is fragile. Use `/workspace`.
- `/workspace/metis-the-lang` is the **legacy** tree. E157's original
  implementation lives there on `worktree-agent-af246604dea6cfa2a`, already ported.
- **`tools/pack/pack.py` does not run here** — it probes `examples/` while this
  tree's corpus is `docs/examples/`, and its `MIGRATION-NOTES.md` records it as
  deliberately not repointed. Every pipeline stage in this arc was run **by hand**.
  Do NOT repoint it at a guess.

## Status

| element | state |
|---|---|
| **E157** typed diagnostics | **BUILT**, ported into chirality. Phase 13, 30 assertions |
| **E158** `Doc` commits 1–3 | **BUILT**. Phase 14, 26 assertions |
| **E174** `r-row` + width fn | **BUILT**. Phase 15, 41 assertions. Turned the tree green (`apc.chiral` was already red) |
| **E175** face restore | **example ✅ → audit ✅ → SPEC ✅ → audit ✅ → implement ⬜ NOT DONE** |
| **E158 commit 4** `doc->rendering` | **BLOCKED** on E175. Never started |

Suite at the last green measurement: **211 assertions, 0 failed, 10 phases, exit 0.**

## ⚑ The one next action

**Implement E175** from `.planning/specs/E175-face-restore-SPEC.md` (status
`audited`). This is a **transcription-with-verification job, not a discovery job**:
the SPEC run *and* the SPEC audit each independently built and ran the entire
change in scratch trees, both reaching **211/0, gate PASSED, Phase 15 41/0**, with
`scriba-main.prog`, `t6_apc_roundtrip.prog` and `prog/compiler.prog` compiling
unedited. §6 logs the mutant output. Re-derive, don't trust — but expect it to work.

**There is a partial attempt in `git stash@{0}`**, labelled
`E175 PARTIAL, UNVERIFIED, UNGATED`: edits to `lib/protocol/render.chiral` and
`tools/test/row.sh` from the killed agent, **never compiled or tested**. Diff it
against the SPEC and take only what the SPEC endorses; the SPEC wins any conflict.
(`stash@{1}` is the earlier `E174 premature` attempt, superseded — E174 is built.)

## Traps that will bite the implement run — all measured

1. **`row.sh` needs FOUR edits.** `row.sh:595` is mutant M10's `sed` expression,
   matching `render-section`'s body line **verbatim** (ends `drow dcol))))))))))$`).
   E175 rewrites that line → the pattern goes stale → **Phase 15 goes red because
   the fix worked.** Three edits only was measured at `39 passed, 2 failed`.
   *(Second instance of this class in the arc: E174 hit the same shape via Phase 7's
   `KNOWN_FAIL`, where repairing the codec turned newly-passing roots into a gate
   failure.)*
2. **NEVER let a scratch `lib` be a symlink.** A prior run's `cp -a` copied the
   link, so every `sed -i` wrote *through it into the tree under test* — nineteen
   phantom failures, including a `Rendering` that had silently grown a tenth
   constructor. The SPEC carries an `[ -L "$SCRATCH/lib" ]` check as a standing
   obligation.
3. **Three SPEC instructions do not work as written** (the audit corrected them;
   don't regress): the three new `def`s go **after the `ansi-*` block**, not after
   `face-sgr`'s body (`ansi-reset` is a bare `def` at `:325` with no `declare` →
   `load: unknown name ansi-reset`); decision 8's mechanism is wrong in its
   *mechanism* though right in conclusion (M10's first `sed` still applies, so the
   guard passes and the mutant `lib/` fails to **compile** instead); and
   **G8(iii)/M12 was toothless because chirality is curried** — a bare 7-arg
   `render-to-ansi` bound to `_` is a partial application of type `(=> Face Unit)`
   and compiles clean; only the *declared* `row.sh:236` shape yields a type mismatch.
4. **The paren trap at `:570`/`:578`** — the new trailing argument does not go at
   end-of-line there.
5. **Leave `lib/prelude/doc.chiral:182` alone.** It still carries the withdrawn
   nesting framing, and that file **is** inside `prog/compiler.prog`'s closure, so
   "fixing one sentence" would trip a fixpoint that decision 13 says does not fire.
   Recorded residue, not a bug to tidy.

## Binding decisions (do not re-litigate — each cost a measurement)

- **Face-as-DELTA, and only the CLOSE changes.** The emitter is self-inconsistent:
  `face-sgr` already emits a delta on the open and the terminal composes it; the
  close is a full `\e[0m` replacement. That asymmetry is the entire defect.
- **SCREEN-identical, NOT byte-identical.** A faced leaf's close restores the
  ambient, and inside an `r-face` the ambient *is* that face — so the stream gains
  bytes while every painted cell stays put. **Gate on the cell map** (G1–G4);
  **G5/G6 are raw-byte rows** because a trailing SGR paints no cell.
- **One trailing `Face` parameter**, not a `(List Face)`: pushes and pops are
  separated by a call, so the call stack already *is* the stack. 21 call sites, all
  in one file, no external caller.
- **Depth 0 is not special-cased** — `face-sgr` of the plain face is `""`.
- **`-1` means "no opinion"** (author, decision 14). A fourth `Face` clear-mask
  field is **deliberately not minted** — a new requirement, not residue.
- **The SGR reducer models fg/bg as REGISTERS**, not a set union.
- **`protocol/render` is outside `prog/compiler.prog`'s closure** → **no fixpoint,
  no promotion**. Re-verify; if it ever changes, `cmp C1 C2` with **C1 checked
  non-zero before `cmp`** (cmp of two empty files passes).
- **`diag.sh` and `doc.sh` must stay byte-unchanged** (`doc.sh` carries sha256 pins).
  `row.sh` *does* change. Gate registers as **Phase 16** (`tools/test/face.sh`);
  8–12 are names still owed, 13/14/15 taken.

## After E175

**E158 commit 4** — `doc->rendering`, `lib/protocol/render-doc.chiral`. It was
blocked on E174 (missing horizontal composition) and E175 (the close). Both will
then be built. FLAG C stands: **it ships correct for nested tags or it does not
land** — a knowingly-wrong first commit was refused.

Then **rebase `e158-doc` onto master and merge.** Master has moved several times;
the branch is currently based on `cdee302`. E158 has been independently mergeable
since `9364c5e` if the rest needs to wait.

## Residue minted along the way (rows exist; none are merge blockers)

`E173` arity judgments carry their arity · `E176` **`str-sub` is unclamped and
segfaults** — a prose comment asserted the safety and `str-starts-with` was built on
it, 131 call sites · `E177` display-width table (wide cells; the hard part is the
*ambiguous* class, not the table) · `E178` `r-table` per-column widths — E174's
table gate is deliberately narrowed and says so · `E179` the face registry becomes
authoritative (five ad-hoc `ansi-bold` sites + `lookup-face` synthesizing for
unknown names) · `E180` face-aware incremental redraw — the hazard **E175 creates**.

## Two patterns worth carrying out of this arc

**Toothless gates are systemic here — eight found in this session**, across E157's
and E158's gates, E174's SPEC, and E175's. Causes: a `grep` matching its own source
or message text, a mutant paired with a row it cannot move, a fixture whose first
failing case masks later rows, and once the language itself (currying turned an
arity check into a legal partial application). **Every row needs a named mutant that
is actually RUN.** Reading a gate does not tell you whether it can fail.

**Probe before reasoning, on anything renderer-shaped.** E175's premise was wrong
in all three of its parts, and my catalog row was the thing that was wrong. A
byte-exact probe — blob → `bin/chirality-bin` → run → `od -tu1` — refuted it in one
run after source-reading had produced a confident, wrong framing that would have
shipped a fix repairing one third of one case *and passing its own review*.
