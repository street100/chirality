---
node: arc-diagnostics-record
layer: navigation
related: [arcs/diagnostics-arc, arcs/README, status-ledger, index]
status: current
updated: 2026-09-10
---

# Record: the diagnostics and formatting arc

The measured history of [[arcs/diagnostics-arc]]. What landed, the traps that
fired, and the decisions that each cost a measurement. Appended, not rewound.
Live state (element rows, requirements, what is next) is in the arc file.

Two standing facts about the working environment, kept here because they cost a
session each:

- `tools/pack/pack.py` does not run in this tree. It probes `examples/` while
  this tree's corpus is `docs/examples/`, and its `MIGRATION-NOTES.md` records it
  as deliberately not repointed. Every pipeline stage in this arc was run by
  hand. Do not repoint it at a guess.
- `/workspace/metis-the-lang` is the legacy tree and is reference only.

## ⚑ The arc's completed set (do not redo)

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

## Rows

Six-field rows per `records/README.md`. The prefix for this arc is `DG`.

### DG-01 the design of `diagnostics/L5` offered four shapes where the principles distinguish five, and its chosen shape was argued only against the three it beats

- state:    FIXED
- claim:    `docs/arcs/parts/diagnostics-L5.md`, `updated: 2026-09-10`, `status: blocked`, designed and unaudited. §4 opened *"Four forms"* and listed Shape A clamp, Shape B refined signature, Shape C option return, Shape D checked wrapper for the primitive half, and Shape α / Shape β for the consumer half. §5 chose Shape A on four reasons: one routine under two surface names (`lib/lowering/tal/erase.chiral:115`), D answers a memory-safety hole with a convention, C costs 250 rewrites, B is unconstructible over a `Str` with no index. No trap shape appeared anywhere in the file.
- measured: **AMEND. The artifact's side moved, in place, marked ⚑.** Trigger: `.planning/BOUNDS-AUTHOR-CALLS.md` §3.4 item 1 (`d9902a2`, 2026-09-10), *"Clamp-and-return absorbs the caller's error; clamp-and-trap (a checked abort that names the bad call) closes the same crossing and keeps the signal. P1's 'gated shut', P3's membrane and P4's physics are each satisfied by both … this fifth is not among them … This is the largest specific gap."* ⚑ **THE TRAP IS CONSTRUCTIBLE TODAY AND THE PRECEDENT IS THIS DEFECT.** The measurement that could have killed the shape does not. `nb-arena-commit-t` already aborts on an out-of-range commit (`lib/lowering/tal/sys.chiral:139-141`) through `nb-arena-fail-t` (`:118-122`, one `ti-sys 231`), and `nb-pool-create-t` on `size <= 0` (`:1020-1021`); the file states the doctrine at `:1006-1009`, *"A real bounds violation is a corpse … a fatal exit is control flow, not a value sentinel."* `nb-bslice-t` can reach it: `lib/lowering/compile-emit.chiral:295` builds one image `native-lib ++ link-lib ++ obj` and `:168-170` records that the three share one flat label namespace, with `nb-arena-fail-t` in `sys-lib` (`lib/lowering/tal/sys.chiral:1308`, `:1340`) and `wrap-halt-t` in `link-lib` (`lib/lowering/tal/sys-linkage.chiral:98`). ⚑ **AND IT COSTS THE SURFACE TYPES NOTHING.** E76's H7 binds every `ti-sys` in the whole image and `nb-arena-fail → 231` is already registered (`lib/lowering/tal/target-linux.manifest:57`); H8, the profile port set, is scanned over the object program's own reified fns and explicitly not the byte runtime (`lib/lowering/compile-emit.chiral:283-287`, the call is `(manifest-offender ports obj)` at `:298`). So no `crossing-wraps` row, no `=>`, no profile edit, and no change at any of the 250 call sites. ⚑ **THE PARTIALITY MARK IS THE WRONG MARK AND IS NOT IN THE LIVE CARRIER.** `docs/decisions/decision-effect-facets.md:78-80` gives today's carrier as `(q, eff-bit, dom, cod)` against a target `(q, row, grades⟨…⟩, totality-mark, dom, cod)`, and `:107` homes partiality in `totality`. The live Pi is `(t-pi (q Qty) (s Seat) (dom Term) (cod Term))` (`lib/surface/syntax.chiral:21`): no row seat, no totality-mark seat. The mark itself is `docs/decisions/decision-graded-kernel.md:51-58`'s, discharged by *"structural recursion plus strict positivity plus case coverage"*, which is a **termination** property; `nb-bslice` terminates, and `docs/definitions/status-ledger.md:190` puts that pillar at IMPLEMENTED, classifying and refusing only under a `(total)` profile. So `nb-bslice` could not carry the mark honestly and would not be caught by it. ⚑ **THE HONEST SURFACE ROUTE WAS MEASURED AND IS A DIFFERENT SHAPE.** Four probes against the committed `bin/chirality-bin`: `halt` is `(extern halt (-> (0 A (type 0)) (=> Str A)))` (`lib/ports/process.port:14`); a `(-> I64 I64)` def calling it **checks OK**, so the crossing does not propagate to callers through the type; under `(profile p (ports print) (target t5))` the same source fails `E76 profile REFUSED emit: crossing halt (wrap-halt) is outside the declared profile port set`; listing `halt` makes it pass. So declaring `str-sub` `=>` would charge every profile in the tree, at emit and not at check. ⚑ **§5 DID NOT SURVIVE THE WIDENED SET AS WRITTEN.** Its four reasons discriminate B, C and D and are silent on E, which repairs the same routine at the same site, reaches the same 250 sites under both surface names, rewrites no call site and is no convention. Exactly one asymmetry is measured rather than preferred and it is in the design's own §2: 87 class-C2 sites rest on local guards nobody has checked, and §2 states that auditing them is not this element's work. That survives A, which turns a bad guard into a truncated value; it does not survive E, which turns a bad guard into a process exit. The same 87 guards are what a trap would find, so the measurement reads as a cost from one side and as the point from the other. ⚑ **NOT RULED HERE.** Whether a clamp discharges the bug class or hides it is `records/author-calls.md:364` and stays `unreviewed`; that file was outside this run's write surface and was not touched. The clamp-versus-trap fork is now question 9 of §5, **NEEDS-AUTHOR**, with both arms written in the same form so the question is a real two-way choice. The consumer half stands and stands harder: β is required by A and forced by E, since under a trap `str-starts-with` with a too-long prefix is a process exit where the tree expects `false`. ⚑ **WHY AMEND AND NOT REOPEN.** §1, §2, §3 and §6 are untouched in substance, the repair site is still settled by the same measurement, the consumer half is still β, and the correction is one shape added plus one call qualified. The design was already `status: blocked` and unaudited, so the audit gates the widened set. ⚑ **STALE CITATION, REPORTED AND NOT EDITED.** `lib/lowering/tal/sys.chiral:1008` cites `ports.chiral:83-85` for the externs' return types; `lib/ports/ports.chiral` is 63 lines and is a façade that declares no crossing. The process crossings moved to `lib/ports/process.port:13-14` under H11.
- evidence: `docs/arcs/parts/diagnostics-L5.md` (§4 preamble now reads five forms and carries the trigger ⚑; **Shape E** added with Form / Constructible-today / Costs / Forbids / Reaches and the carrier ⚑; §5's primitive-half block re-tested and its chosen shape marked *was chosen*; the A-versus-E ⚑ and the not-ruled-here ⚑ added; the consumer-half block extended; question 1 split and question **9** added NEEDS-AUTHOR; §6's Elements bullet and Size table scoped to the fork). Read at HEAD `838c311` during this run: `lib/lowering/tal/sys.chiral:110-200`, `:1000-1055`, `:1308`, `:1337-1342`, `lib/lowering/tal/sys-linkage.chiral:55-112`, `lib/lowering/tal/bytes.chiral:120-165`, `lib/lowering/tal/erase.chiral:100-130`, `:200-220`, `lib/lowering/tal/crossing-wraps.chiral:1-40`, `lib/lowering/tal/ir.chiral:20-49`, `lib/lowering/tal/sys-check.chiral:1-45`, `lib/lowering/tal/target-linux.manifest:43`, `:57`, `lib/lowering/compile-emit.chiral:155-215`, `:275-300`, `lib/lowering/x64/mach.chiral:559`, `lib/ports/ports.chiral`, `lib/ports/process.port:7-14`, `lib/surface/syntax.chiral:14-35`, `lib/typing/totality.chiral:1-60`, `lib/memory/mem-region.chiral:30-50`, `lib/lowering/mach/asm-reloc.chiral:70-95`, `docs/decisions/decision-effect-facets.md:55-115`, `docs/decisions/decision-graded-kernel.md:40-70`, `docs/definitions/status-ledger.md:190`, `.planning/LANGUAGE-INVENTORY.md:124-130`. Nothing under `lib/`, `prog/` or `tools/` was changed and no build was run. Re-runnable, the four probes: a `.prog` of `(import "prelude/prelude") (import "ports/process") (import "ports/stdio")` plus `(def f (-> I64 I64) (lam (x) (case (<i x 0) (true (halt I64 "neg")) (false x))))` and `(def main (=> Unit Unit) (lam (u) (print (i64->str (f 3)))))` checks **OK** under `bin/chirality check`; adding `(target t5 (require main (=> Unit Unit)))` and `(profile p5 (ports print) (target t5))` fails with the E76 profile refusal; changing that to `(ports print halt)` checks **OK**. The defect itself is not re-derived: `records/enforcement-arc.md` EN-31.
- checked:  2026-09-10
- element:  `E176`, minted 2026-08-31, ledger state `design` (`docs/elements/ledger.md:312`), roster row `diagnostics/L5`. The row's `status:` stays `blocked` and no stage regresses: the design is unaudited and `pipeline-audit` at DESIGN level is the next stage over the widened shape set. **A repair to `nb-bslice-t` is compiler source and emission** under either shape: `prog/compiler.prog:13` → `lib/lowering/compile-all.chiral:15` → `lib/lowering/compile-emit.chiral:16` → `lowering/tal/bytes`, so [[working-discipline]]'s build rule makes the first agreement **`C2 == C3`, not `C1 == C2`**, and `lib/lowering/tal/bytes.chiral:134-144` forces gen3 as mandatory evidence. Shape E does not change that cost.
