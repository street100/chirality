# Diagnostics arc — handoff (2026-08-31)

**Self-contained.** A fresh session should be able to resume from this file alone.
**Updated 2026-08-31 after E158 commit 4 landed** (`34a6dfb`, `688888c`) — the
arc's last unbuilt piece. E175's history is below and still accurate; the
`stash@{0}` partial it describes was applied, verified and committed, and both
stash entries can be dropped.


## ⚑ Why this arc exists — the chain, written down because it got lost

**The arc is not about diagnostics.** Diagnostics are the first consumer. The
destination is **the new file types**, and `HANDOFF.md`'s route step 3 says so.

```
E157  Reason        the compiler's errors become VALUES with evidence
  ↓
E158  Doc           a formatter that takes structure and defers the flatten     [BUILT]
  ↓                 (needed E174 r-row + E175 face restore under it)            [BUILT]
E181  pretty        the term printer repointed at the REAL Term, returning Doc  [NOT BUILT]
  ↓                 today: 51 lines, its own local 5-ctor Term vs the real 15,
  ↓                 Str-typed, ZERO importers
E146  value→source  the five emitters return Doc, gated at widths 1/40/10⁶      [NOT BUILT]
  ↓
E163  .manifest     a declared form → a derived codec → a round-trip gate       [NOT BUILT]
E183  .protocol     the same law, carried in BYTES instead of source            [NOT BUILT]
```

**The law both file types share** (`HANDOFF.md`): *a declared form → a derived
codec → a round-trip gate*. `.manifest` round-trips against chirality source
(`parse(source(v)) ≡ v`); `.protocol` round-trips against bytes. That is why
`Doc` serves one and not the other — bytes have no layout freedom.

**⚑ What went wrong in the session that built E157/E158/E174/E175, recorded so it
does not repeat.** Every element built was a genuine blocker discovered by the one
before it, and all four are green. But **`pretty.chiral` — the actual named
target — was never touched**, and ended the session demoted to a residue row
(E181), minted as *phantom-dep cleanup* rather than as the goal. `HANDOFF.md:136`
says it flatly: *"E158 into E146, the pretty-printer chain. Untouched all
session."*

The tell was available early: E158's pre-run measured that `pretty.chiral` is a
**rewrite, not a signature change**, and that got filed as a reason to keep it out
of E158's gate rather than as a reason it needed its own element immediately.
**A `why` that lives only in a different document is a `why` that will be traded
away for whatever is in front of you.** Hence this section, here.

**Also unadopted:** `dg-doc` and `doc->rendering` are imported only by the arc's
own three modules. No `prog/`, nothing in scriba. Fifth "built but unadopted"
instance in this repo — and E181 closes it, since a `Doc`-returning printer is
`Doc`'s first real consumer.


### The chain does not end at the file types — it ends at ZERO PYTHON

**Measured 2026-08-31.** 13 Python files remain, **4,140 lines**: nine tools plus
four `docs/examples/refs/gen-*.py` generators. **Zero of them are in the build or
test path** — `bin/chirality` has no `test-python` and never shells to it — so
what is left is the *tooling tier*, not the floor.

```
tools/ledger-lint  1128     tools/capture      620     tools/paren-audit   154
tools/pack          831     tools/scriba-*     182     tools/doc           330
tools/frontier      651     tools/syscall-map  244
```

**Why this is the same arc and not a separate one.** Every one of those tools does
three things: it **scans** text, it **reports** what it found, and it **prints**
the report. Those are precisely the three capabilities this chain builds —

- **printing** → `Doc` (E158, built) + `pretty` (E181, not built)
- **reporting** → `Reason` (E157, built), the diagnostics vocabulary
- **scanning** → the total matcher (master's E173, drafted)

plus the floor gap master already measured in
`.planning/PRIMITIVES-FOR-NATIVE-TOOLS.md`, taken from *writing*
`prog/prose-lint.prog` rather than from reading a list. **`prose-lint` is the
existence proof**: one tool already ported, natively.

So the order is forced, not chosen: **the tools cannot be replaced before the
things they are all made of exist.** Doing the file types first and the Python cut
second is one sequence, not two projects — and `HANDOFF.md`'s route already says
so (step 1 *replace the Python tools and delete `tools/`*, step 2 diagnostics,
step 3 the new file types); the only correction measurement forces is that step 1
**depends on** steps 2 and 3 rather than preceding them.

⚑ **Do not narrow this to "no Python in the compile path".** That is already true
and has been for the whole migration. The goal is **zero Python in the repo**,
`tools/` and the four generators included.

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
| **E175** face restore | **BUILT** 2026-08-31. Phase 16, 38 assertions, 13 mutants |
| **E158 commit 4** `doc->rendering` | **BUILT** 2026-08-31. Phase 17, 19 assertions, 11 mutants |

Suite: **268 assertions, 0 failed, 12 phases, exit 0** (211 → 249 → 268; the
last delta is Phase 17's 19, and Phases 13/14/15/16 are unchanged at
30/26/41/38). All four pre-existing gate scripts are byte-identical by sha256.

## ⚑ The one next action

**Rebase `e158-doc` onto master and merge.** The arc has nothing unbuilt left in
it; see *After E158 commit 4* below.

### E158 commit 4, as landed (2026-08-31)

`lib/protocol/render-doc.chiral` — `doc->rendering : (-> I64 Doc Rendering)`.
`Doc` does **not** unify with `Rendering`; this converts, one way.

**⚑ The finding, and it is the durable one.** FLAG C named a shortcut (the naive
whole-node `r-face`) and the author refused it. There is a *second*, subtler
shortcut it does not name, and it is the one you would reach for: carry the tag
stack down the walk and re-wrap **every emitted leaf** in its whole stack —
`r-face kw (r-text "ab")`, `r-face kw (r-face cm (r-text "cd"))`,
`r-face kw (r-text "ef")`. That output is **screen-correct**. It was also
**measured, byte-for-byte, to produce an identical cell map on the pre-E175
emitter** (`rnd-restore` reverted to a bare `ansi-reset`), because no `r-face`
in it ever wraps more than one painted node. A gate built over that design
**passes on the broken emitter** and would have reported E175 as an unused
dependency. It is also the E158 defect one layer down: the tag **tree**, smeared
across the leaves.

What landed is the tree — **one `r-face` per `d-tag` occurrence per line**:
`r-face kw (r-row [ r-text "ab", r-face cm (r-row [r-text "cd"]), r-text "ef" ])`.
`"ef"` is painted after an inner face **closed**, with nothing re-opening the
outer, so it reads the ambient E175's close restores. Measured both ways, on the
six cells of Phase 17's fixture row 1:

| | (1,1) (1,2) | (1,3) (1,4) | (1,5) (1,6) |
|---|---|---|---|
| **with E175** | `{1,31}` | `{1,32}` (the JOIN) | `{1,31}` (**restored**) |
| **E175 reverted** | `{1,31}` | `{32}` | `{}` (**unfaced**) |

**The walk is re-run, and the gate pins the two together.** `doc-best`
accumulates a `(List Str)` and cannot also carry line structure and a tag stack,
so `rdc-best` re-runs Lindig's walk over a frame carrying the tag stack. The
**one decision point is not re-implemented** — `d-group` calls `prelude/doc`'s
own `doc-fits` over a stripped worklist (`rdc-strip`, O(depth) per group, paid
to keep a single authority). The residual duplication is answered by a **law**,
not a convention: Phase 17's **G1** reads the text back out of the `Rendering`
with an independent reader and requires it to equal `doc->str` at five
(document, width) pairs.

**Sibling vs nested, re-measured:** `dg-doc`'s thirteen `d-tag` sites are still
all siblings and `dg-decl-doc` still emits no tag — but that is a fact about
*today's* consumer, not about the exit. `doc->rendering` is correct for both,
and Phase 17 grades the nested case because the sibling case cannot fail.

**Phase 17, not two rows added to `doc.sh`.** The E158 SPEC wrote G8/G9 as rows
of Phase 14. They are not: the four existing gate scripts must stay
byte-unchanged, and `render-doc.sh` now carries sha256 pins over all four.
Eleven mutants, every one RUN, and **each pins the FULL fifteen-row verdict
line** — so a mutant that reddens a row it was not paired with fails the same
assertion as one that reddens nothing. All seven of the value-row verdicts were
**predicted from the design before the first run** and came out exactly as
predicted.

### E175, as landed (2026-08-31)

`stash@{0}`'s partial was **SPEC-conformant** and was applied unchanged after a
line-by-line check against §4 — three `def`s below the `ansi-*` block, nine
signatures, nine `lam` binders, 21 call sites (including the two paren traps at
`:570`/`:578` placed correctly), six closes, `r-hole` untouched, `-delta`
untouched, and all four `row.sh` edits. It had never been compiled; it compiled
first try. `stash@{1}` (superseded E174) is still there and is still ignorable.

What was built on top of it: `tools/test/samples/e175_face.prog` (one fixture,
read by both the cell-map rows and the raw-byte rows) and `tools/test/face.sh`
(Phase 16), registered in `run-tests.sh` and `MIGRATION-NOTES.md`.

**Every trap in the list below fired or was avoided exactly as recorded**, and
the `row.sh:595` one was re-measured rather than trusted: reverting *only* that
edit gives `39 passed, 2 failed` with the message *"the mutant G5 probe did not
build"* — the audit's corrected mechanism (a compile failure, not the
stale-pattern guard), confirmed.

## Traps that bit — or would have — all measured

0. **Two more self-matching gates, both of which FIRED on E158 commit 4's first
   run**, bringing the arc's count to eleven. (a) Phase 17's E154 census went red
   **on a clean tree**, because mutant M7's `sed` expression spelled
   `(declare doc->rendering …)` at the start of a line **in the gate script
   itself** and the census greps `tools/`. (b) Phase **16** went red because the
   new fixture's `render-to-ansi` call was split over two lines and `face.sh`'s
   G7(c) arity scanner is **line-based** — it read `UNTERMINATED`. Neither was
   anticipated; both are now recorded at their sites, not only in a commit
   message. The rule that catches (a) is already written down (*assemble the
   needle from fragments*); the rule (b) needs is new: **a fixture under
   `tools/` is inside a neighbouring gate's scan surface, so its formatting is
   part of its contract.**

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
  `row.sh` *did* change, for E175. **As of E158 commit 4 all four —
  `diag.sh`, `doc.sh`, `row.sh`, `face.sh` — are frozen**, and
  `tools/test/render-doc.sh` carries a sha256 pin over each of them, so a later
  element cannot reword one quietly. **8–12 are still names owed;
  13/14/15/16/17 are taken.** The next new gate is **Phase 18**.
- **`protocol/render-doc` is outside the compiler closure too** (it imports
  `protocol/render`), and Phase 17's **G9** is that as a checked row with a
  mutant (M11) that adds the import to `typing/diag` and watches the scan see it
  arrive. **`prelude/doc` IS inside** — `typing/diag` imports it — so any edit to
  that file, *including a comment*, moves the blob and carries the build-rule
  obligation. Measured when commit 4 corrected a stale sentence there: blob
  753401 → 753702 bytes, emitted compiler **byte-identical** at 1126776 bytes,
  nothing to promote, `N1 == N2` re-run anyway.

## After E158 commit 4

**Rebase `e158-doc` onto master and merge.** Master has moved several times;
the branch is currently based on `cdee302`. E158 has been independently mergeable
since `9364c5e` if the rest needs to wait — and as of `688888c` the whole arc is
built, so there is nothing left to wait for.

**Two things this element deliberately did NOT do**, each with its home: E158's
third exit **`doc->json`** stays absent (no consumer — the "built but unadopted"
trap, four times logged), and **`typing/pretty.chiral`** is still a 51-line
printer over its own local 5-constructor `Term`, imported by zero modules. SPEC
decision 12 says its repointing is a **rewrite**, and the deferral rule means it
needs its own minted row before any work is parked on it. **That row does not
exist yet** — minting it is the honest next piece of paperwork, not a silent
carry-forward.

## Residue minted along the way (rows exist; none are merge blockers)

`E182` arity judgments carry their arity · `E176` **`str-sub` is unclamped and
segfaults** — a prose comment asserted the safety and `str-starts-with` was built on
it, 131 call sites · `E177` display-width table (wide cells; the hard part is the
*ambiguous* class, not the table) · `E178` `r-table` per-column widths — E174's
table gate is deliberately narrowed and says so · `E179` the face registry becomes
authoritative (five ad-hoc `ansi-bold` sites + `lookup-face` synthesizing for
unknown names) · `E180` face-aware incremental redraw — the hazard **E175 creates**.

## Two patterns worth carrying out of this arc

**Toothless gates are systemic here — eleven found across this arc**, in E157's
and E158's gates, E174's SPEC, E175's, and two more on E158 commit 4. Causes: a
`grep` matching its own source or message text, a mutant paired with a row it
cannot move, a fixture whose first failing case masks later rows, a scanner that
would pass on an always-empty result, a **neighbouring** gate's line-based
scanner tripped by a fixture's line breaks, and once the language itself
(currying turned an arity check into a legal partial application). **Every row
needs a named mutant that is actually RUN.** Reading a gate does not tell you
whether it can fail.

⚑ **Two upgrades this arc's last element added, both cheap and both worth
keeping.** (1) **Pin the FULL verdict line, not "a row went red."** Phase 17's
fixture prints fifteen row results as one line and every mutant pins that whole
line — so a mutant that reddens a row it was *not* paired with fails the same
assertion as one that reddens nothing, and the asymmetries a gate claims (this
row can see it, that one cannot) become checked rather than asserted. (2) **The
fixture makes no assertion and always exits 0.** It prints values; the
comparisons are the gate's, in bash. A fixture that grades itself can be wrong in
the same direction twice, and one that exits with its first failing case masks
every later row from every mutant — a hazard this arc had already logged once.

**The shortcut that hides its own dependency.** E158 commit 4's per-leaf
conversion was screen-correct *and* measured byte-identical on the emitter E175
had just fixed. A design can be right and still make its own gate blind — so
when an element claims to depend on another, **revert the dependency and check
the gate goes red**. If it does not, either the dependency is unused or the
design has flattened it out.

**Probe before reasoning, on anything renderer-shaped.** E175's premise was wrong
in all three of its parts, and my catalog row was the thing that was wrong. A
byte-exact probe — blob → `bin/chirality-bin` → run → `od -tu1` — refuted it in one
run after source-reading had produced a confident, wrong framing that would have
shipped a fix repairing one third of one case *and passing its own review*.
