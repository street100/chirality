---
node: arc-enforcement
layer: navigation
related: [arcs/README, goals/enforcement, status-ledger, arcs/diagnostics-arc, records/enforcement-arc, decisions/decision-erased-word-level, decisions/decision-def-partition, index]
status: current
updated: 2026-09-10
---

# Arc: enforcement

- goal: [[goals/enforcement]]
- reserved element block: `E184-E189`, shared with [[arcs/diagnostics-arc]] (`docs/decisions/decision-lane-split.md`, Lane A)
- checklist: [[records/enforcement-arc]]
- build-state authority: [[status-ledger]]

**This file is TRACKED for the same reason [[diagnostics-arc]] is.** ⚑ **The
reason stated here until 2026-09-04 was false twice over:** the catalog and the
ledger are tracked at `docs/elements/`, and `.gitignore:12` is `.claude/*`, so
`.planning/` was never the exclusion this paragraph named. `.planning/` has been
tracked since 2026-09-01 (`docs/decisions/decision-ai-tier.md`). What survives is
the real reason, which `docs/arcs/README.md` states: two sessions minted `E173`
independently and nothing caught it until a merge put both INDEX rows side by
side. An element fact anyone else needs lives here.

The arc's subject is enforcement: a claim the compiler makes about its own work,
carried as a value, with evidence, and refused when it does not hold. E184,
E185, E186, E187 and E188 are minted for it, and four older catalog rows belong
to it: E16, E17, E18 and E70.

`.planning/` stays the working detail (change plans, decision tables, SPECs).
This is the part that survives a fresh clone.

Build-state authority for the suite as a whole: [[status-ledger]].
Measurements this arc rests on: [[records/enforcement-arc]].
Lane division and what enforces it: `docs/decisions/decision-lane-split.md`. Lane A resume: `records/lane-a-record.md`.

## REQUIREMENTS

Done when all six hold. Each is checkable, and the state beside it is measured
2026-09-02.

1. **A capability sits at ENFORCED, or its ledger row says why it does not.**
   Inherited verbatim from [[goals/enforcement]]. The row-says-why half carries
   the weight and is the open part. Measured 2026-09-05: `docs/elements/ledger.md`
   holds **66 rows at `design`**, and a `design` row states what an element would
   do rather than why the capability is not at ENFORCED. Filling that half is
   mechanical, row by row, and needs no author call. E70's row is the shape to
   copy: it keeps `design` and says in the row why.
2. **The typed-assembly floor runs on the shipping path.** Open, and **materially
   smaller than this requirement claimed until 2026-09-05.** ⚑ **The stated
   blocker is gone and was gone before it was stated.** The eleven E154
   collisions were resolved at `5b4fb71` and never reverted:
   `lib/lowering/tal/check.chiral:47` declares `TckR`/`tck-ok`/`tck-err`, and
   `(import "lowering/compile-all") (import "lowering/tal/check")` answers `OK`.
   The "duplicate label refusal at load" and the "seven sha256-pinned gate
   scripts" cascade are both pre-`5b4fb71` readings. **E185 is built** and so are
   E186, E187 and E188, so the `$apply` dispatchers no longer gate this either;
   EN-15 is answered by [[decisions/decision-erased-word-level]] and EN-17 is
   ruled `concrete` by E186.

   **The remaining gap is measured, and it is one class.** Requirement 4's
   wiring put a re-check on every compile, so the floor's judgment now runs on
   the shipping path in `optimize`'s form. Over the compiler's own blob:
   **1,582 TFns, 1,550 `chk-ok`, 32 `chk-err`**, and every one of the 32 is
   `call: unknown tal function` ([[records/enforcement-arc]] EN-24).

   ⚑ **The figure is reproducible as of 2026-09-05, and the class behind it is
   not what this requirement said it was.** `prog/optimizer-census.prog`
   (`7a62965`) re-derives the census over the compiler's own blob and prints
   `census tfns=1582 ok=1550 err=32 defs=1551 skipped=10 unfolded-ok=1550`, so
   all three numbers hold and `tools/test/opt-census.sh` R2 pins them. **The
   attribution does not.** This paragraph read that the 32 sit on port externs
   the tal function table does not carry, first instance `bput-u8`. Measured:
   `bput-u8` is the name of the *refused TFn*, it is an ordinary def at
   `lib/lowering/tal/bytes.chiral:610`, and no port extern appears in the set.
   All 32 are missing the SAME callee shape, `<name>$0`, which is the TFn's own
   outlined block: `outline` (`lib/lowering/upper/lower.chiral:311-319`)
   extracts a non-tail `case` as `<name>$<n>` and adds its signature to `St`'s
   fn list, `compile-fn` (`:420`) returns `le-ok main extra` and discards
   `st-fns`, and the program-wide `CEnv` `lower-defs` builds from `def-sigs`
   never carries it. **So what stands between here and `ck-prog` on the shipping
   path is a `CEnv`-plumbing gap at the re-check call site.** The extern table
   is a different subject and this set says nothing about it.
   [[records/enforcement-arc]] EN-25 carries the measurement and
   `tools/test/opt-census.sh` R3 asserts the shape positively, with M5 as its
   falsifier.

   ⚑ **THE SHIPPING-PATH HALF EXPIRED 2026-09-08 AND THE CENSUS DID NOT.** The
   author ruled that `lowering/tal/check` stays OUTSIDE the compiler closure
   (`records/lenses/problems.md` PRB-70) and `b613a8f` cut the wiring, so **no
   judgment of the floor runs on the shipping path**: `opt-tfns` adopts
   `(fold t)` with nothing to consult. The census moved out with it and still
   runs, against the same checker, from `prog/optimizer-census.prog`. Re-measured
   at `38ecdba` over the blob the ruling left behind:
   `census tfns=1548 ok=1517 err=31 defs=1518 skipped=10 unfolded-ok=1517`. Every
   proportion above holds. One class, `call: unknown tal function`, first
   instance `bput-u8`, and all 31 callees the refused TFn's own `<name>$0` block.
   The 33 fewer defs are `check.chiral` leaving the blob. The `CEnv`-plumbing gap
   is unchanged and is still what stands between here and `ck-prog`.

   E16's title names the preserve-check and three of its four deliverables are
   built; E18's checker and reference interpreter exist unreached.
3. **The check agrees with the compiler it checks.** **Root-caused 2026-09-03**,
   `records/enforcement-arc.md` EN-08 to EN-13. Re-measured on that day's blob:
   1,481 TFns, 727 accept, **754 reject, 50.9%** (the move from 1,504/743/761 is
   E182 at `65bec90`, `d26d7a1`). **The checker is wrong in 99.2% of it**, through
   two defects: an erased type-argument list that `tal-ty=?` refuses and no other
   rule reads, and a `tt-word` scrutinee `ck-term`'s case arm has no arm for,
   which contradicts `tal-ty=?`'s own first arm. Relaxing both, 1,475 of 1,481
   accept. **Both checker defects are repaired at `ddfbc27`** and Phase 22
   (`tools/test/tal-check.sh`) pins that the repaired check still refuses, with
   nine REJECT rows and three live mutants. Of the six survivors, the
   erased-binder register is **fixed at `40e8726`** (EN-14) and the probe reads
   **1,477 of 1,481**. ⚑ The four `$apply` dispatchers remain, and EN-15 is
   **answered 2026-09-04**: [[decisions/decision-erased-word-level]] settles the
   level. Their spelling is **E185**, minted the same day and unbuilt.

   ⚑ **The requirement has a second half nothing measured until 2026-09-04.**
   Agreement runs both ways, and [[records/enforcement-arc]] EN-20 measures a
   case where the check agrees with a compiler that is wrong. `arm-body`'s
   `(none)` arm emits the literal `0` as a whole function body; when the
   family's codomain is ground, `const 0` matches the declared return, `ck-prog`
   accepts, and the wrong code passes. The two instances in the compiler's own
   blob redden only because their codomain is `(List Asm)`. So the 1,477-of-1,481
   figure above measures the checker agreeing with the compiler and says nothing
   about either being right. **E188** owns that defect, and E188 is **built**.

   ⚑ **THE EVIDENCE GATE IS RED, AND THE CLAIM THAT NOTHING TECHNICAL IS LEFT
   WAS FALSE WHEN IT WAS WRITTEN.** The evidence for this requirement is Phase
   22, `tools/test/tal-check.sh`, which `tools/test/registration.sh` prints as
   `PEND  tal-check.sh -- it claims 22, which is inside Lane B's reserved 21-23
   band.` Run by hand at HEAD on 2026-09-05 it **exits 1** and reads
   **`20 ok, 1 FAIL`**. The failing row is
   `FAIL  G18 'def ck-prog' appears 1 time(s) in the compiler blob`. G18 asserts
   that `lowering/tal/check` stays OUTSIDE the compiler's closure, and
   requirement 4's wiring at `5b7478f` put it inside:
   `lib/lowering/compile-back.chiral:16` imports `lowering/upper/optimize` and
   `lib/lowering/upper/optimize.chiral:17` imports `lowering/tal/check`. G18 is
   therefore falsified correctly by the tree it measures.

   ⚑ **THE REDNESS WAS PRE-REGISTERED AND THE FOLLOW-THROUGH WAS NOT.**
   `tools/test/tal-check.sh:79-81`, written at `5b4fb71` two days before the
   wiring, says the row "goes red the day one of them is wired, and on that day
   the red row is a REMINDER to retire this gate. It reports no defect." That
   note rules out a compiler defect. It leaves the absent check exactly where it
   was, and it was never acted on: the wiring shipped and no file under
   `tools/test/` was touched ([[records/enforcement-arc]] EN-25). **What is left
   here includes technical work.** G18's fate is an author call and carrying it
   out edits a gate script, so this requirement waits on more than a number.

   ⚑ **G18 IS GREEN SINCE 2026-09-08, AND THE TREE MOVED RATHER THAN THE GATE.**
   The author ruled that `lowering/tal/check` stays OUTSIDE the compiler closure
   and that the wiring is the defect (`records/lenses/problems.md` PRB-70). G18
   keeps its polarity: it was neither inverted nor retired. `b613a8f` repointed
   the two importers at `lowering/tal/ssa`, where the typed IR they cited is
   actually declared, and cut `re-check`. Measured at that commit,
   `bash tools/test/tal-check.sh` exits 0 at **`21 ok, 0 FAIL`**, the row reading
   `G18 lowering/tal/check is OUTSIDE the compiler blob (840440 bytes, 0
   occurrences of 'def ck-prog')`. The two paragraphs above are the record of the
   red period and stand as written. What is still open in this requirement is the
   `$apply` work E185 owns and the author call below.

   The suite-phase-number author call is separate and still open: 21 through 23,
   contested across four documents ([[records/author-calls]]), and a session is
   barred from making it. Phase 22 sits outside `run-tests.sh`'s dispatch table
   under either answer, so the suite line does not carry it today.
4. **The optimizer's re-check runs, or E17 says why it does not.**
   **REOPENED 2026-09-08 by the author's ruling**, `records/lenses/problems.md`
   PRB-70 and commit `b613a8f`, stated in full in the last block of this
   requirement. It read **CLOSED 2026-09-05 on the first branch**,
   [[records/enforcement-arc]] EN-24, and ⚑ **the closure was short of its own
   evidence**, two paragraphs down. Everything between here and that last block
   is the record of the closure and stands as written.
   `lib/lowering/compile-back.chiral:16` imports `lowering/upper/optimize` and
   `lower-defs` hands every emitted TFn to `re-check`, adopting the residual
   only through `chk-ok`, which ck-fn has to form. Measured on the promoted
   binary: **1,582 TFns per self-compile, 1,550 `chk-ok`, 32 `chk-err`**, and
   the un-folded baseline accepts the same 1,550, so the fold costs no
   acceptance. The 32 are `call: unknown tal function` on port externs and are
   requirement 2's. Fixpoint `F2 == F3 == F4` at 1,241,464 bytes,
   `391 passed, 0 failed`, `91 roots built, 0 failed`, gate PASSED on the day of
   promotion. Re-run at HEAD 2026-09-05: `391 passed, 0 failed`,
   **`92 roots built, 0 failed`**, gate PASSED, exit 0. The extra root is
   `prog/e197-recording-sweep.prog`, added by E197 at `a2130c5`. Re-run again
   after this requirement's own gate landed: `391 passed, 0 failed`,
   **`93 roots built, 0 failed`**, gate PASSED, exit 0. That extra root is
   `prog/optimizer-census.prog`.

   ⚑ **THE CLOSURE SHIPPED NO GATE, LEFT ONE RED, AND RESTS ON A PROBE THAT IS
   NOT IN THE TREE.** [[records/enforcement-arc]] EN-25 measures all three.
   `git show --stat 5b7478f` touches `bin/chirality-bin`,
   `lib/lowering/compile-back.chiral` and `lib/lowering/upper/optimize.chiral`,
   and **zero files under `tools/test/`**; `e7c27e7` seven minutes later is
   documentation. Every other element that landed this week shipped a gate in
   its own step commit: E186 `capture-fields.sh` (`f1d86b7`), E188
   `apply-spine.sh` (`bd367bf`), E187 `defunc-blame.sh` (`7a0b3fd`), E196
   `encoding.sh` (`799bf06`), E197 `recording.sh` (`a2130c5`). Grep over
   `tools/test/` for `compile-back`, `optimize`, `opt-tfns` and `chk-ok` finds
   no assertion about the wiring, so **cutting the wiring would leave the suite
   at `391 passed, 0 failed`**. The one gate over the module the wiring pulled
   into the closure, Phase 22, is red at HEAD and sits outside the dispatch
   table, so nothing runs it. And the `1,582 / 1,550 / 32` figure the closure
   rests on came from a probe outside `lib/` and `prog/` that was never
   committed: nothing under `prog/` or `tools/` mentions `opt-tfns`, and nothing
   in the tree reproduces `1,582`.

   **What is built, what is unverified, what is owed.** Built: the import,
   `opt-tfns` on `lower-defs`' `le-ok` arm, the `chk-ok` adoption, and a fixpoint
   at 1,241,464 bytes under a green suite. Unverified: that the re-check runs on
   a shipping compile at all, because no gate reads it and the suite is
   indifferent to its removal. Owed: a gate that reddens when the wiring is cut,
   and a committed form of the probe behind `1,582 / 1,550 / 32`, which is also
   requirement 2's scope statement. That owed gate has no element.
   **Whether this requirement reopens is the author's call and this file does
   not make it.**

   ⚑ **BOTH OWED ITEMS SHIPPED 2026-09-05, AND NEITHER CHANGES THE `CLOSED`
   MARKER, WHICH IS THE AUTHOR'S.** `prog/optimizer-census.prog` (`7a62965`) is
   the committed probe and reproduces all three numbers exactly.
   `tools/test/opt-census.sh` (`d7ccad8`) is the gate: six rows, six mutants,
   **`opt-census: 12 passed, 0 failed`**, out of dispatch by a `not-a-phase:`
   declaration on the route eight sibling gates take. It reddens on each of the
   three cuts this requirement was closed without: **M1** comments out the
   import at `lib/lowering/compile-back.chiral:16` and reverts `opt-tfns` to the
   identity, which is the tree exactly as it stood before `5b7478f`, and R5 and
   R6 both go red; **M2** keeps the call to `re-check` and adopts the residual
   without `chk-ok`, and R5 alone convicts it; **M3** regresses the accept count
   from 1,550 to 358, and R2 and R3 go red. Every row carries a falsifier that
   was built and run, so no row here is one of requirement 6's.

   ⚑ **AND THE GUARD IS INERT ON THE COMPILER'S OWN BLOB.** A compiler with
   `re-check` forced to answer `chk-ok` emits **byte-identical** output for
   `prog/compiler.prog`'s blob against the guarded one, 1,241,464 bytes each.
   None of the 32 refused TFns carry foldable work outside the block that
   outlined, so the residual the check refuses and the fallback it adopts emit
   the same code. The check runs on every compile and, on this blob, refuses 32
   residuals that would have cost nothing. R5 is therefore measured on
   `tools/test/samples/opt_census_outline.prog`, the smallest program where the
   refusal is observable, beside a control that must not move. What the wiring
   buys today is the shape of a guarantee rather than a change to what ships.

   ⚑ **THE COLLISIONS THIS REQUIREMENT WAS WAITING ON WERE ALREADY GONE.** The
   eleven E154 names were prefixed `tck-` at `5b4fb71` and `lowering/tal/check`
   loads beside the compiler's whole blob today, measured by loading it. What
   `optimize` still owed was two homonyms of its own, `cenv-get` against
   `lowering/mach/emit-core` and `two-srcs` against `lowering/tal/erase`, both
   in a module nothing imported. EN-16 stays open on its own subject, the five
   duplicated defs, and no longer blocks this requirement or requirement 2.

   ⚑ **THE REWRITE IS `fold` ALONE, AND E17's DCE IS A LIVE MISCOMPILE.**
   `optimize` is `re-check ce (dead (fold fn))`. Wired whole it reaches a
   fixpoint and the compiler miscompiles itself: `293 passed, 98 failed` with
   `91 roots built, 0 failed`, so every program still compiles and many compute
   the wrong value. Attributed over `tools/test/row.sh` by two single-generation
   builds: `fold` alone `42 passed, 0 failed`, `dead` alone
   `33 passed, 9 failed`. **`re-check` accepts the dead residual**, which is
   EN-19's shape a second time: the `Checked` sum proves ck-fn ran and says
   nothing about meaning. Repairing `dead` is E17's remaining work and it is
   not this requirement's.

   ⚑ **REOPENED 2026-09-08: THE WIRING THIS REQUIREMENT CLOSED ON IS CUT.** The
   author ruled that `lowering/tal/check` stays OUTSIDE the compiler closure and
   that the wiring is the defect (`records/lenses/problems.md` PRB-70). Three
   measurements are named in the ruling. The wiring put `ck-fn` in the blob and
   never `ck-prog`, so requirement 2's subject still has zero call sites. A
   compiler with `re-check` forced to answer `chk-ok` emits a byte-identical blob
   at 1,241,464 bytes, so the wiring bought no shipped byte. And keeping it
   charged the BUILD RULE on every edit of `check.chiral` and cost
   `tools/test/tal-check.sh` the scratch-`lib/` mutant harness G18 exists to
   license.

   Carried out at `b613a8f`. `lib/lowering/upper/eff-lower.chiral:20` and
   `lib/lowering/upper/optimize.chiral:17` both cited `lowering/tal/check` for a
   typed IR declared at `lib/lowering/tal/ssa.chiral:21-40`, and both are
   repointed there. `re-check`, `Checked`, `chk-ok` and `chk-err` moved whole to
   `prog/optimizer-census.prog`; `lower-defs`' `opt-tfns` adopts `(fold t)` with
   no verdict to consult. The compiler rebuilt to `C1 == C2` at **1,220,984
   bytes**, 20,480 fewer than the 1,241,464 above, which is `check.chiral`
   leaving the blob; the blob itself is 840,440 bytes against 855,545 and holds
   zero `def ck-prog`. `tools/test/run-tests.sh` reads **`412 passed, 0 failed`**,
   `93 roots built, 0 failed`, gate PASSED, matching a pre-change baseline taken
   in a clean worktree at HEAD. `tools/test/tal-check.sh` reads `21 ok, 0 FAIL`.

   **What the requirement now needs.** The first branch is gone: no re-check runs
   on the shipping path. The second branch is open and unwritten, because E17's
   ledger row does not yet say why it does not run. The census survives as the
   measurement it always was, taken from outside the closure:
   `tools/test/opt-census.sh` at `38ecdba` reads **`opt-census: 8 passed, 0
   failed`** over `census tfns=1548 ok=1517 err=31 defs=1518 skipped=10
   unfolded-ok=1517`, four rows and four mutants, 7s wall against 49s. R5, R6 and
   mutants M1 and M2 asserted the wiring and retired with it, and the fixtures
   `tools/test/samples/opt_census_outline.prog` and `opt_census_control.prog`
   were R5's subject and its control and are removed.
   [[records/enforcement-arc]] EN-26 carries the measurement.

5. **Chirality's own tooling is chirality's.** Measured 2026-09-05 at `67d3d54`:
   **12,671 lines outside the language** against **782 native**, every `.prog`
   file:
   `prose-lint` 256, `paren-audit` 244, `test-runner` 134, `resolve` 104,
   `wield` 44. The **390** this requirement carried until 2026-09-04 was
   `test-runner` plus `prose-lint` and omitted the other three. ⚑ **The 12,450
   this requirement carried until 2026-09-05 is behind.** Four falsifier commits
   after `acc70d6` took the gate tier to 7,136 lines;
   [[records/tooling-classification]] TC-13 measures the corrected 12,671 and
   confirms the gate-tier four-tool count reproduces at **240** site for site.

   ⚑ **782 is the worse reading. 390 was the flattering one.** The two entries
   the 390 counted are the two entries anything reaches. `grep -rIn` over
   `tools/` and `bin/` finds no shell file, gate phase or CLI subcommand
   invoking `paren-audit.prog`, `resolve.prog` or `wield.prog`, so **392 of the
   782 sits at SEEDED**. TC-03 and TC-04 in [[records/tooling-classification]]
   carry the two whose replaced predecessor is still live beside them.

   The surface is the gate tier at 6,915 lines of shell,
   `tools/prose-lint/prose-lint.sh` at 223 with awk doing the matching, nine
   Python tools at 4,786, and `bin/chirality` plus `bin/chirality-resolve.sh` at
   526. Within the gate tier alone `grep`, `sed`, `sort` and `awk` run as **240
   invocations**, of which **30 are ones where `docs/arcs/text-tools-arc.md`
   records a built chirality composition**. The other 210 are judgments and wait
   on [[arcs/independent-judgment-arc]] J1, the distinctness criterion, which is
   rowed there as not started (TC-12).

   ⚑ **Every gate-tier line figure in this requirement is behind by at least
   `recording.sh`.** They were taken at `67d3d54` (2026-09-04 11:52). E197's
   gate, `tools/test/recording.sh` at **414 lines**, landed at `a2130c5`
   (2026-09-05 15:41), and E196's `tools/test/encoding.sh` at 306 landed at
   `799bf06` the same day. No corrected total is written here because none was
   measured.

   ⚑ **The 352 this requirement carried until 2026-09-04 was a word-occurrence
   count, presented as a call count with a composition behind every one.**
   `grep -ohE '\bgrep\b' tools/test/*.sh` and its three siblings return 149,
   100, 22 and 81, summing to exactly 352 at `acc70d6`. The occurrences include
   comments, the scratch filenames `g5.awk` and `g9.awk`, and the prose in
   `tools/test/matcher.sh` naming the tool the native matcher is graded against.
   TC-02.

   `lib/text/matcher.chiral` has one consumer.

   ⚑ **Some of it is correct and stays.** A comparator holding constants cannot
   be fooled by a mutated compiler, which is why `crypto.sh` prints from the
   fixture and compares in bash, and why `mutant.sh` substitutes in pure
   parameter expansion. Over-claiming that bucket replaces a safety property
   with a dependency. What is owed is the work a composition already covers.

   ⚑ **The reason is the OS rung rather than the gate.** Every classic tool
   that becomes a composition is one fewer thing an operating system written in
   this language has to trust, and a resolver and a text tool are needed long
   before a test harness is. Taking the ground now is cheaper than migrating a
   coreutils dependency later. `records/gate-audit.md` holds the measurement;
   `docs/arcs/text-tools-arc.md` holds the coverage table.

6. **Every gate row names a mutant that is actually run.** Inherited from
   [[goals/enforcement]] and from `docs/definitions/testing-floors.md:261`. E173
   found two rows that could not fail; both were repaired at `e882568`.

   **Two halves, and they part company.** ⚑ *Registration.* Measured at HEAD
   2026-09-05: `ls tools/test/*.sh` lists **26** scripts, `run-tests.sh`
   dispatches **thirteen**, and **thirteen sit outside the dispatch table**:
   `run-tests.sh` itself, `apply-spine.sh`, `apply-word.sh`,
   `capture-fields.sh`, `crypto.sh`, `defunc-blame.sh`, `encoding.sh`,
   `map-integrity.sh`, `mutant.sh`, `opt-census.sh`, `recording.sh`,
   `registration.sh` and `tal-check.sh`. `registration.sh` prints the same split
   as `13 of 26 scripts are outside the dispatch table by their own
   declaration.` and reads `9 passed, 0 failed` with G1 to G6 ok. The
   twenty-five and twelve this paragraph carried predate `opt-census.sh`,
   requirement 4's gate, added at `d7ccad8`; the twenty-four and eleven before
   them predate `recording.sh` at `a2130c5`. Every one carries a `not-a-phase:`
   declaration with a reason in its own header, which `registration.sh` G2 and
   G4 enforce, so no row is undeclared and that half survives each recount.

   ⚑ **ALL THIRTEEN WERE RUN BY HAND AT HEAD ON 2026-09-05. ELEVEN ARE GREEN AND
   TWO ARE RED.** The "built, runs green by hand" this paragraph carried was
   measured false for one and unmeasured for the rest; both halves are closed
   here.

   | gate | exit | reads |
   |---|---|---|
   | `apply-word.sh` | 0 | `11 ok, 0 FAIL` |
   | `apply-spine.sh` | 0 | `11 ok, 0 FAIL` |
   | `capture-fields.sh` | 0 | `9 ok, 0 FAIL` |
   | `crypto.sh` | 0 | `8 ok, 0 FAIL` |
   | `defunc-blame.sh` | 0 | `11 ok, 0 FAIL` |
   | `encoding.sh` | 0 | `9 passed, 0 failed` |
   | `mutant.sh` | 0 | the matrix, `fixpoint=C1==C2` on every row |
   | `opt-census.sh` | 0 | `12 passed, 0 failed` |
   | `recording.sh` | 0 | `12 passed, 0 failed` |
   | `registration.sh` | 0 | `9 passed, 0 failed` |
   | `run-tests.sh` | 0 | `391 passed, 0 failed`, `93 roots built, 0 failed`, gate PASSED |
   | `tal-check.sh` | **1** | `20 ok, 1 FAIL` on G18 |
   | `map-integrity.sh` | **1** | `869 rows, 176 stale` |

   ⚑ **THREE OF THE THIRTEEN MOVED BY 2026-09-08 AND THE TABLE ABOVE IS THE
   2026-09-05 READING.** Re-measured at `38ecdba`:

   | gate | exit | reads |
   |---|---|---|
   | `tal-check.sh` | 0 | `21 ok, 0 FAIL` |
   | `opt-census.sh` | 0 | `8 passed, 0 failed` |
   | `run-tests.sh` | 0 | `412 passed, 0 failed`, `93 roots built, 0 failed`, gate PASSED |

   `tal-check.sh`'s red was requirement 3's: G18 asserts `lowering/tal/check`
   stays outside the compiler closure and requirement 4's wiring put it inside,
   so the row was falsified correctly. The author ruled on 2026-09-08 that the
   wiring is the defect (`records/lenses/problems.md` PRB-70), `b613a8f` cut it,
   and G18 is green with its polarity unchanged. `opt-census.sh` lost the two
   rows and two mutants that asserted that wiring and kept the four that measure
   the census, so twelve checks became eight. `run-tests.sh`'s figure grew with
   the gates added between the two dates.
   `map-integrity.sh`'s red is a separate defect dated 2026-08-31: 176 of its
   869 `.planning/MIGRATION-MAP.tsv` rows point at paths the migration moved. It
   is not this requirement's subject and it is not fixed here. Whether any
   of the thirteen *should* be dispatched is the suite-phase-number author call,
   the same one requirement 3 waits on ([[records/gate-audit]] GA-10, still OPEN
   for that reason).

   ⚑ *Rows nothing can move.* Two rows in [[records/gate-audit]] stay OPEN with
   stated reasons. **GA-04**: `ba62549` took `profile-target.sh` from 1 of 31
   rows reddened to 23 of 34, but twenty of the twenty-three come from one
   coarse mutant, and **eleven rows are reddened by nothing** — `target with one
   requirement`, `target with several requirements`, `profile with one clause`,
   `profile name is not a symbol`, and seven `top_target` refusals. Left open on
   measured churn: eleven message-rename mutants and eleven compiler builds on a
   phase that already went from 2 s to 27 s. **GA-08**: the `(memory ...)` rows
   are quantified over an empty set of consumers. `mk-profile`'s `me` field is
   read by nothing in `lib/`, and no mutant of the discipline's *meaning* can
   exist until something consumes it, which is a compiler change and an author
   call about what a memory discipline is for. GA-01 and GA-10 are the other two
   open rows.

⚑ Requirement 3 is the one that gates the rest. E16's scope and E18's both
stop short of it as written, so no element owns it.

## Roster

Seventeen rows. Five are the minted `E184-E188` band, four are older catalog
rows this arc owns, three came from the 2026-09-06 native-tests ruling, and five
came from the TAL conformance findings on 2026-09-08. Groups: `attribution` is
what the compiler states about its own work, `floor` is the typed-assembly floor
and its adoption, and `tooling` is the gate tier owning itself.

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `enforcement/N1` | attribution: every def's fate is stated by the compiler, with evidence, and checked ⚑ **E184's R1 is the tree's def partition, established 2026-09-09 by [[decisions/decision-def-partition]]** and by [[records/enforcement-arc]] EN-28. That document is the outline the author asked for when ruling the 84-line `lower.chiral` partition neither retired nor repaired, and it lands entirely on R1 through R7, so **no second element is minted for the partition**. Three findings it owes this row's SPEC stage: **R2's three skipped classes are the wrong set** (it names `type-does-not-peel`, measured at 0 of 22,742 on definitions with no record produced; it omits `body-does-not-lower`, measured at 182 of the 347 refusals; and E187 added a fourth `SkReason` constructor after E184 minted); `lib/lowering/compile-back.chiral:271` files all 182 term-level failures as `(sk-extern er)`, which `lib/lowering/skip-diag.chiral:28` renders as the tag `"extern"`, and that is the mechanical cause of the five misattributed citations; and no committed instrument re-derives any def-level count, which `enforcement/N14` is now scoped to fix first. The 84 dead lines are retired inside this element's build cycle ⚑ **A fourth finding, 2026-09-10: R1's domain is amended and the SPEC stage is barred from spelling it.** R1, R6 and R7 each carry a ⚑ dated 2026-09-10 under `#### The seven requirements`, and [[records/enforcement-arc]] EN-29 is the run. The domain of the fate function stays the author's, priced at two options by [[records/findings]] FD-21 ⚑ **That bar is LIFTED 2026-09-10: the domain is ruled.** [[records/author-calls]] carries the row at `ruled` (`0ffa1ae`) and the ruling is `docs/examples/E184-def-fate-sum.md` §6 decision 1: the domain is the pre-pass def set plus what the pass created, and deletion is never a fate. [[records/enforcement-arc]] EN-30 is the run. R1, R6 and R7 each gain a second ⚑ under `#### The seven requirements`; R6 survives on one restated clause, the two-stage domain's construction at the pass boundary; the SPEC stage may now spell `FateRec`'s domain. What stays the author's is two arm-count sub-questions | attribution | law | new | 1 | open | `E184` |
| `enforcement/N2` | how the `$apply` dispatcher's erased domains are spelled at the lowering type level | attribution | primitive | new | 3 | open | `E185` |
| `enforcement/N3` | the `$k<i>_<j>` capture constructor's field types: concrete, or the erased word | attribution | primitive | new | 3 | built | `E186` |
| `enforcement/N4` | the `sk-defunc` blame channel: `closconv` states why it dropped a family | attribution | law | new | 1 | built | `E187` |
| `enforcement/N5` | `arm-body`'s unreachable arm is reached, and an `$apply` arm returns a literal `0` | attribution | law | new | 3 | built | `E188` |
| `enforcement/N6` | lowering: pure to tal, register and slot allocation, non-tail case outlining, preserve-check ⚑ **The title's fourth deliverable has a definition since 2026-09-08 and its second is measured absent.** `docs/decisions/decision-preserve-check.md` settles preserve-check as two rungs, T0 and T1, split by `ttype`'s `Maybe`, so the fourth deliverable is `N13` and `N14` together and giving `ck-prog` a call site does not discharge it: FD-20 and PRB-77 measured `ck-prog` as `(-> CEnv Prog TckR)` with both arguments target-level, which witnesses target well-typedness alone. LIM-19 measured the second: there is no register allocator, `nregs` (`lib/lowering/tal/ssa.chiral:40`) is a fresh-register high-water mark and `lib/lowering/mach/emit-core.chiral:533` hands it to `(mach-pro m)` for one stack slot per SSA register, so slot allocation is what is built | floor | primitive | new | 2 | open | `E16` |
| `enforcement/N7` | the optimizer's re-check runs, or the element says why it does not | floor | tool | connect | 4 | open | `E17` |
| `enforcement/N8` | the typed-assembly checker and reference tal interpreter reach the shipping path ⚑ **The interpreter half is now named and it is half of a pair this row does not hold.** FD-20 and `docs/decisions/decision-preserve-check.md` place `lib/lowering/tal/eval.chiral` (187 L, zero importers) as T1's target evaluator; its source-side counterpart `lib/evidence/interp.chiral` (109 L, zero importers) is E15's and sits outside E18, and T1 buys nothing until both are required to agree. `N13` carries the pair. What stays here is the call site `ck-prog` has never had, PRB-15 | floor | tool | connect | 2 | open | `E18` |
| `enforcement/N9` | effectful lowering: the effect row's tal shadow plus a preserve-check over the effect claim ⚑ **The phrase in this title is defined since 2026-09-08 and the effect side is unpriced.** `docs/decisions/decision-preserve-check.md` settles preserve-check as two rungs for E70 as well as E16, so this row owes an effect-side T0 and an effect-side T1. R7 of `.planning/TAL-CONFORMANCE-QUEUE.md`, the slice that asks what carries an effect claim at the target level, reads UNRUN, so no finding prices either rung and the row stays gated on `decision-effect-facets`. PRB-70's ruling repointed `lib/lowering/upper/eff-lower.chiral:20` at `lowering/tal/ssa` at `b613a8f`, so the module no longer carries the checker into the closure with it | floor | law | new | 2 | open | `E70` |
| `enforcement/N10` | the gate tier becomes chirality: 10,719 lines of shell in `tools/test/` against 1,775 native, on the `prose-lint` precedent where the checks moved into a `.prog` and the shell kept only the front end | tooling | tool | new | 5 | open | `unminted` |
| `enforcement/N11` | every gate row names a mutant that is actually run, checked mechanically rather than per gate by hand | tooling | tool | new | 6 | open | `unminted` |
| `enforcement/N12` | the TFn census as a gate: fold `ck-prog` over every emitted TFn and report accept, reject and the four reject classes. Three record rows rest on this number. The instrument that still cannot be re-run is `ck-prog`, which has zero call sites anywhere under `lib/` or `prog/`, so the four reject classes stay un-taken. The `ck-fn` half does re-run: `prog/optimizer-census.prog` under `tools/test/opt-census.sh` reads `census tfns=1548 ok=1517 err=31`, measured 2026-09-08 at `38ecdba`. It reads 1582/1550/32 before that date, over a blob that still carried `check.chiral`; PRB-70's ruling took the module out of the compiler closure and the probe imports it directly now. ⚑ It became buildable when E154's eleven collisions were prefixed away: measured 2026-09-06, **zero** names in `lowering/tal/check` collide with any module under `lib/`, so a probe imports the real checker instead of keeping a copy | tooling | tool | connect | 2 | open | `unminted` |
| `enforcement/N13` | the preserve-check's T1 rung: `lib/evidence/interp.chiral` (109 L) and `lib/lowering/tal/eval.chiral` (187 L), both at zero importers, reach a call site and are required to agree **over the definitions that lower**, **22,395** of the 22,742 globals the peel accepts once the 347 skipped at `lib/lowering/compile-back.chiral:270-271` have left, because T0's claim is target well-typedness and says nothing about which value a well-typed body returns. ⚑ **Re-scoped 2026-09-09 by [[records/enforcement-arc]] EN-27.** This row read `so ttype's (none) routes to detection instead of the definition leaving the artifact`, and that router has nothing to route: `ttype` has zero call sites and `term->ntalty` refuses 0 of 22,742. The 347 term-level skips leave this row's reach, having no tal image to run. The convicting case is unchanged, EN-20 sitting inside the lowered set. `docs/decisions/decision-preserve-check.md` settled 2026-09-08 that a preserve-check is two rungs and was amended 2026-09-09 so the rungs stack over one program rather than partitioning it; GAP-22 is the gap this row closes; FD-20 measured every published route to a preservation claim as a function of two programs, and measured these two evaluators as the independent writers `PRINCIPLES.md` §5's rung table requires before N copies buy anything. EN-20 is the case T1 convicts and `ck-prog` accepted. ⚑ `docs/elements/catalog.md:484` E169 half (a) already describes this instrument, is minted at ledger state `design`, and no arc names it (UNS-45), so whether this row adopts E169 or mints is the design stage's | floor | tool | connect | 2, 3 | open | `unminted` |
| `enforcement/N14` | `ttype` (`lib/lowering/upper/lower.chiral:35`, `(-> UT (Maybe TalTy))`) becomes total over the region a preservation lemma is stated on, or the skip at `lib/lowering/compile-back.chiral:268-270` is stated as a costed choice naming the region it excludes. FD-15 measured the published theorem as five lemmas each stated against a TOTAL function on types, so a lemma of that shape cannot be written over a partial non-injective `ttype`, and measured the divergence as starting in `lower.chiral` upstream of `tal-ty=?`. FD-16 surveyed seven production compilers and found every translation total on its input or aborting the whole compilation, with the drop-one-definition position unoccupied; the one production partiality, a HotSpot C2 bailout, keeps the refused method running from an already-verified class file. FD-20 measured the total type translation as a precondition of writing a typed preservation claim down at all ⚑ **Re-scoped 2026-09-09 by [[records/enforcement-arc]] EN-28.** The first branch is struck. The author ruled the 84-line partition **neither retired nor repaired** ([[records/author-calls]]) and asked for the partition the tree should actually have, outlined and documented; that is [[decisions/decision-def-partition]], which measures the proper partition as **E184's R1** and mints nothing. So `ttype` becoming total leaves this row, and the fifteen dead names (`lib/lowering/upper/lower.chiral:22-105`, zero consumers re-verified at `d3ee8ad`) go out inside E184's build cycle rather than on their own. **What stays here is the second branch alone**: the region the live translation excludes, re-derived by a committed instrument and stated with the number behind it. Measured 2026-09-09: 0 refusals over 22,742 globals, 153 over 4,902 extern signatures all `(t-primty "Pty")` and owned by E107, 347 skip records in three channels of which 182 are term-level. Nothing in the tree re-derives any of it, which is what the row now buys. The `kind` cell moves from `primitive` to `tool`: the deliverable is an instrument and a statement | floor | tool | new | 2 | designed | `unminted` |
| `enforcement/N15` | `tal-ty=?` stops standing in for type equality while failing to be an equivalence, or the collapse is discharged at a site the producer writes into the artifact. PRB-74 measured the failure from the relation's own arms (`lib/lowering/tal/check.chiral:68-77`): `(tal-ty=? tt-i64 tt-word)` and `(tal-ty=? tt-word tt-str)` are both `true` while `(tal-ty=? tt-i64 tt-str)` is `false`, and `docs/decisions/decision-erased-word-level.md:44` is the argument for why transitivity is what would collapse the source type system. FD-17 surveyed five published discharges, the checked downcast, specialization, type passing, term-level type representations and a coercion calculus, and none of them lands inside a checker's equality relation, which is where this one lands; four of the five need an instruction naming the type it moves to. FD-16 measured GHC's `weak_eq`, the nearest shipping analogue, as an equivalence over three classes that runs only in the lint | floor | law | new | 3 | open | `unminted` |
| `enforcement/N16` | `shape-eq` (`lib/lowering/upper/closconv.chiral:343-350`) splits domains the way defunctionalization's published criterion does, or the coarsening is stated as a costed choice. FD-18 measured the tree as on route one, whose criterion is equality of the source arrow type, and priced the repair at zero new `TalTy` constructors, zero new `Instr` forms and zero change to `tal-ty=?`, because `tt-data`, `i-con` and `tt-case` already are the closed sum, its injections and its dispatch, with the whole-program charge paid by `closconv-sig` over one `Sig`. PRB-76 measured the asymmetry `shape-eq` introduces: it answers `true` for any two non-arrows while `cod-key-eq` at `:365-376` sends ground codomains through `core-eq` exactly, so a family merges over its domains and splits over its codomain. `N2` and `N3` are two symptoms of that criterion and this row is the criterion | attribution | primitive | new | 3 | open | `unminted` |
| `enforcement/N17` | `i-bnew`, `i-bget` and `i-blen` carry a result type, or they leave the checked IR. PRB-75 measured three of `Instr`'s eight constructors (`lib/lowering/tal/ssa.chiral:26-33`) binding a `dst` with no `ty` while `ssa.chiral:24-25` claims every value-defining form carries its annotation so the checker re-verifies independently of the kernel, and measured the checker supplying `(tt-bytes)`, `(tt-i64)` and `(tt-i64)` from its own constants at `lib/lowering/tal/check.chiral:215-218`, which is inventing the answer. FD-19 measured the tree on the type-per-definition route whose closure is that every value's type sits in the artifact, three annotations short of it, and measured `compile-fn` as the producer that would owe them and as owing nothing today because no pass in the typed SSA path originates a byte-cell instruction. FD-17 measured the JVM's `checkcast` and WebAssembly's `ref.cast` at exactly this heap-read position. The real byte cells are hand-written below the check at `lib/lowering/tal/bytes.chiral:54-67` and `lib/lowering/tal/sys-linkage.chiral:44-61`, which `ck-prog` never sees | floor | primitive | new | 2, 3 | open | `unminted` |

### Coverage

**Every requirement is served.** 1 by N1 and N4; 2 by N6, N8, N9, N12, N13, N14
and N17; 3 by N2, N3, N5, N13, N15, N16 and N17; 4 by N7; **5 by N10 and 6 by
N11**, both opened 2026-09-06 on the author's ruling that tests and harnesses are
native. `GAP-02` and `GAP-03` enumerated those two holes while the arc's band was
spent and are closed by these rows. Every row serves one. `N7`, `N8` and `N13`
are `connect`: every subject they name is built and unadopted, which is the
defect this arc names.

**N13 through N17 came in on 2026-09-08 from the TAL conformance findings**,
FD-15 through FD-20 and `docs/decisions/decision-preserve-check.md`. They split
across the two requirements the property touches. Requirement 2 is coverage: a
definition `ttype` drops never reaches the artifact `ck-prog` reads (N14), a
`(none)` has no destination (N13), and the byte layer sits below the check
entirely (N17). Requirement 3 is agreement: the checker's stand-in for equality
fails transitivity (N15), the split criterion that forced the erased spelling
in N2 and N3 is coarser than the published one (N16), the checker invents the
types it should be reading (N17), and target well-typedness alone accepted EN-20's
wrong program (N13). `GAP-22` names N13 as its owner, and PRB-74, PRB-75 and
PRB-76 name N15, N17 and N16.

## Resume state


⚑ **2026-09-08: the TAL conformance property has rows, five of them, and three older rows were amended where the findings redefined them.** The property is the author's, carried by `.planning/TAL-CONFORMANCE-QUEUE.md`: type the upper language and the lowering is fully and properly typed. Six research slices landed the same day as FD-15 through FD-20 and `docs/decisions/decision-preserve-check.md` settled the shape, two rungs split by `ttype`'s `Maybe`, and none of it had a roster row to be designed from. `N13` is the T1 rung, `N14` is `ttype`'s totality, `N15` is `tal-ty=?`, `N16` is `shape-eq`'s split criterion, `N17` is the three untyped heap forms. `N6`, `N8` and `N9` were amended: E16's fourth deliverable now has a definition and its second is measured absent (LIM-19), E18's reference interpreter is measurably one half of a pair E18 does not hold, and E70 carries the same two-rung phrase with its slice unrun. **`N13` is the row to design first.** It is the only new row whose origin is `connect`, both its halves are written and unimported at 187 and 109 lines, `docs/elements/catalog.md:484` E169 half (a) already describes the instrument with no arc naming it, and it is the one rung that convicts EN-20, the live case where `ck-prog` accepted a program returning `0` where the source returned `30`. `N14` is second, because FD-20 measured the total type translation as the precondition of writing the typed claim down at all. R7 of the queue is UNRUN and it is `N9`'s, so E70 cannot be designed against a finding yet.

⚑ **2026-09-08: requirement 4 is REOPENED and G18 is green.** The author ruled (`records/lenses/problems.md` PRB-70) that `lowering/tal/check` stays OUTSIDE the compiler closure and that the wiring is the defect. `b613a8f` repointed `eff-lower.chiral:20` and `optimize.chiral:17` at `lowering/tal/ssa`, where the typed IR they cited is declared, and cut `re-check`. The compiler is at `C1 == C2`, 1,220,984 bytes, blob 840,440. `tools/test/tal-check.sh` reads `21 ok, 0 FAIL`, `tools/test/run-tests.sh` reads `412 passed, 0 failed` with `93 roots built, 0 failed` and gate PASSED, unchanged from the pre-change baseline. `38ecdba` cut opt-census.sh's two wiring rows and two wiring mutants and kept the four census rows, re-pinned at `census tfns=1548 ok=1517 err=31 defs=1518 skipped=10 unfolded-ok=1517`, reading `8 passed, 0 failed`. **Requirement 4's second branch is what is owed next: E17's ledger row has to say why the re-check does not run, and nothing says it yet.** `N8` is no longer half-moved by the closure question; what it owes is the call site `ck-prog` has never had. EN-26 carries the measurement.
⚑ **2026-09-06: three rows opened and the arc now serves all six requirements.** `N10` and `N11` came from the native-tests ruling, closing `GAP-02` and `GAP-03`. `N12` is the TFn census, which became buildable when E154's eleven collisions were prefixed away: zero names in `lowering/tal/check` collide with any module under `lib/` today, so a probe imports the real checker instead of copying it. **Nine record rows rest on that census and none can be re-run until `N12` exists**, which makes it the highest-leverage row here. `PRB-70` also measured `check.chiral` inside the compiler closure with `ck-prog` called by nothing, so `N8` is half-moved.
**2026-09-05: resume from `.planning/HANDOFF-2026-09-05.md`.** It supersedes
`.planning/HANDOFF-2026-09-04-EVENING.md`, which is kept for its measurements.
That file carries the state, the six requirements in working order, the DCE
defect a fresh session must not rediscover, the open author calls and the rules
that bit.

**All four minted elements in this arc's band are built.** E185, E186, E187 and
E188 reached `built`; `E184` and `E189` are the two `design` rows left in the
band, and `E189` is the last free number. E184 needs the full pipeline and has
no pre-run.

⚑ **EN-20's live miscompile is E188's and E188 is built.** What EN-24 opened in
its place is a second live miscompile: **wiring `optimize` whole miscompiles the
compiler.** `fold` alone is `42 passed, 0 failed`; **`dead` alone is
`33 passed, 9 failed`**, and `re-check` accepts the dead residual. DCE is
excluded from the shipped wiring and named in requirement 4. No instrument in
the tree can refuse it, because `ck-fn` accepts it. Repairing `dead` and finding
an instrument that can refuse it are E17's remaining work.

**Requirement 5 is first priority by author direction** and
`.planning/HANDOFF-2026-09-04.md` carries the full queue. The gate tier reads
7,136 lines of shell against `prog/test-runner.prog` at 134 lines, the only
native part of that floor, with 240 invocations of the four classic tools across
it and a built composition behind 30 of them. The program of work is gated on
[[arcs/independent-judgment-arc]] J1, the distinctness criterion, rowed there as
not started (TC-12).

⚑ **REQUIREMENTS 3 AND 4 ARE NOT CLOSED ON CONTENT, AND THIS PARAGRAPH SAID
THEY WERE.** Requirement 3's evidence is Phase 22, `tools/test/tal-check.sh`,
which exits 1 at HEAD reading `20 ok, 1 FAIL` on G18. Requirement 4's closure
shipped no gate, left G18 unrun, and rests on an uncommitted probe
([[records/enforcement-arc]] EN-25). Requirement 2 is still the live one, and
what it has left is the 32 `call: unknown tal function` refusals on port
externs, first `bput-u8`. That figure comes from the same uncommitted probe and
cannot be re-derived from the tree.

**The eleven name collisions are resolved and block nothing.** They were prefixed
`tck-` at `5b4fb71`, and `lowering/tal/check` loads beside the compiler's whole
blob today. The census paragraph below is the pre-`5b4fb71` reading and is kept
for the collision census it carries, not for its conclusion. The refuse-or-carry
ruling in [[records/author-calls]] is a separate and still-open call. **EN-17 is
ruled**: E186 settled the `$kI_J` capture constructor's field types as
`concrete` on 2026-09-04, so requirement 2 no longer carries it.

**The enabling change LANDED at `5b4fb71`, and this paragraph is the census it
was measured from.** ⚑ Its opening sentence read "measured, then reverted" until
2026-09-05, when EN-24 loaded the module beside the blob and found it clean.
`lib/lowering/tal/check.chiral` declares **11 top-level names that already exist
in the compiler's blob** (`CkR`/`ck-ok`/`ck-err` against `lib/typing/kernel.chiral:411`,
`CovR`/`cov-ok` against `lib/surface/data.chiral:37`, `find-ctor`, and five
byte-identical duplicates of `lower.chiral:160-191`), so importing it is a
`duplicate label` refusal at load before any type-checking. That is E154's
fifth instance. `tools/test/diag.sh:250-256` already records the collision as
deliberate.

Resolving them plus inserting the call site reaches a fixpoint at `K2 == K3` and
the suite runs `320 passed, 1 failed`, the one failure being `diag.sh:256`
grepping for a renamed literal, and repointing that guard cascades through
**seven sha256-pinned gate scripts over two rounds**. ⚑ **This paragraph read
"which is why it was reverted rather than half-shipped" until 2026-09-05.** It
was not reverted. `5b4fb71` shipped the renames, and EN-24 measured the module
loading clean beside the blob.

The diagnosis slice for the four classes ran 2026-09-03, EN-08 to EN-13. What is
still owed before any of this lands is the refuse-or-carry ruling, which is the
author's.

[[arcs/display-calculus-arc]]'s resume state names a further item on this
requirement's surface: `tools/pack/pack.py`'s prefix gate has no adapter and
no `--mark` path for that arc's rows, so its pipeline has no deterministic
finish on a PASS.

## Open: minted, not built

### E184

| E184 | **Attribution: every def's fate is stated by the compiler, with evidence, and checked** | Not built. Minted 2026-09-01. Attribution is **not measurable today**: five mechanisms decide a def's fate, only three leave a record, and all of it is discarded on the success arm. Seven requirements. **R1, a total fate function** over every def in the compiler's closure, a closed sum with no `_` arm: `emitted <label>` · `specialized-into <names>` (because `specialize-singletons` rewrites rather than drops) · `erased-by-design` (the type-level defs `filter-erasable` is supposed to remove) · `skipped <reason>`. The `erased-by-design` arm is required rather than optional: a type-level def is not a failed lowering, and without that arm every ratio built on the fates is noise. **R2, reasons carry evidence, not strings.** `skipped`'s reason is itself a closed sum: extern-with-no-wrapper naming the op, type-does-not-peel naming which type and where, callee-cascade naming the chain. E157's rule applies unchanged, and a `str-cat`'d sentence here reintroduces what E157 removed. **R3, `peel-def` stops returning `(Maybe NDef)`** and becomes a result sum. `compile-front.chiral:203-210` drops a def by returning `(none)` and keeps no record at all, the only one of the five mechanisms that leaves no trace, so nothing downstream can recover it. **R4, the record survives success.** `compile-all.chiral:34-38` discards the `skips` list on the `elf-ok` arm, so it surfaces only on an emit failure. **R5, the cascade is rooted.** `prune-fix` (`compile-back.chiral:213`) is transitive, and the cascade record is built at `compile-back.chiral:210`, in `prune-pass`, so "dropped because callee X was dropped" is a pointer rather than an attribution; every chain must resolve to a non-cascade root, and `skip-diag.chiral` already carries E97's blame chain as the existing shape, which is why it is the right home. **R6, fates survive a renaming, and this is the design fork.** `specialize-singletons` (`compile-front.chiral:20`) runs before peel and changes a def's identity: `x64` becomes `x64$0`, `x64$1` and so on. Fates are therefore a relation across a renaming, and the rename mapping has to be produced by the pass that performs it and carried the rest of the way. Get it wrong and monomorphized singletons read as failures, which is exactly the misreading that made the earlier measurement worthless. **R7, conservation checked inside the compile, plus an exit.** The fates partition the closure's def set, exactly one per def, and folding them reproduces the emitted set; a def with no fate, or with two, fails the compile. That is the line between attribution and logging. `bin/chirality` has compile / run / check / test and no exit for the report, so one is owed, and the gate that reads it is a chirality program on E168's test floor rather than a shell script. **Cost:** roughly 150 to 250 LOC across five modules, three signature changes (`peel-def`, `specialize-singletons` emitting its rename relation, `compile-all` threading fates), plus build-new → test → promote with the fixpoint verified and the Step-0 precondition checked first. **Needs the full pipeline** (worked example → audit → SPEC → audit → implement): the fate taxonomy is a taxonomy and R6 is a genuine fork. The pre-run may recommend splitting R6 into its own element; if it does, that split mints its rows in the same change. ⚑ **The one read-only probe is gone.** Compiling through the E166 `Mach`→C leg and joining mangled C symbol names back to def names died with that leg (`d8bcec5`, `d0c5dd5`), and was never legitimate anyway: it shared `compile-front` and `compile-back` whole and differed only at emit, which is one formulation with two emitters, the shape `docs/decisions/decision-self-verification.md` §0 explicitly rules out. ⚑ **Measured 2026-09-01:** `skip-reason` (`lib/lowering/upper/lower.chiral:83-93`) together with `eligible?`, `lower-all`, `lower-def` and `LowRes` has **no caller outside its own file**; the live path imports `lower` for `compile-fn` only (`compile-back.chiral:15`), so the four exclusions those functions name (dependent type, effectful, quantified binder, type does not lower) are **never produced by a real compile**. Full requirement text: `docs/arcs/enforcement-arc.md`. | `OURS`; ←E97, ←E157, ←E168 |

| E184 | lowering | design | **Attribution: every def's fate is stated by the compiler, with evidence, and checked.** A total fate function over every def in the compiler's closure, a closed sum with no `_` arm: `emitted <label>` / `specialized-into <names>` / `erased-by-design` / `skipped <reason>`, with `skipped`'s reason itself a closed sum carrying evidence (extern-with-no-wrapper, type-does-not-peel, callee-cascade), so E157's rule applies unchanged. `peel-def` stops returning `(Maybe NDef)`: `compile-front.chiral:203-210` drops a def with no record at all. `compile-all.chiral:34-38` stops discarding `skips` on the `elf-ok` arm. `prune-fix`'s transitive cascade (`compile-back.chiral:213`, record built at `compile-back.chiral:210` in `prune-pass`) resolves to a non-cascade root, in `skip-diag.chiral` beside E97's blame chain. Fates survive `specialize-singletons`' renaming (`compile-front.chiral:20`, `x64` becomes `x64$0`), which is the design fork: get it wrong and monomorphized singletons read as failures. Conservation is checked inside the compile, one fate per def, folding to the emitted set, with a report exit `bin/chirality` does not have and a gate on E168's floor. **Attribution is not measurable today:** five mechanisms decide a fate, three leave a record, all of it discarded on success. The one read-only probe died with the E166 C leg (`d8bcec5`, `d0c5dd5`) and was never legitimate, one formulation with two emitters. Measured 2026-09-01: `skip-reason` (`lib/lowering/upper/lower.chiral:83-93`) with `eligible?`/`lower-all`/`lower-def`/`LowRes` has no caller outside its own file, so its four exclusions never occur in a real compile. ~150-250 LOC, five modules, three signature changes, full BUILD RULE. **Pipeline: yes.** Minted 2026-09-01; full text in `docs/arcs/enforcement-arc.md`. | ←E97, ←E157, ←E168 |


#### The seven requirements

**R1. A total fate function.** Every def in the compiler's closure maps to exactly
one fate. Closed sum, no `_` arm. Arms: `emitted <label>`; `specialized-into
<names>`, because `specialize-singletons` rewrites rather than drops;
`erased-by-design`, for the type-level defs `filter-erasable` is supposed to
remove; `skipped <reason>`. The `erased-by-design` arm is required rather than
optional: a type-level def is not a failed lowering, and without that arm every
ratio built on the fates is noise.

⚑ **THE DOMAIN IS FALSIFIED AND THE CLOSED SUM IS CONFIRMED, MEASURED 2026-09-09
BY [[records/findings]] FD-21.** Ten pinned sources. Six systems read at their own
sources: DWARF 5, ECMA-426 source maps, LLVM's debug-info rules, LLVM's machine
outliner, GHC's cost centres, AutoFDO, plus Graf and Peyton Jones on selective
lambda lifting.

**What this requirement fixes as the domain.** *Every def in the compiler's
closure*, which R6 below and [[decisions/decision-def-partition]] §1 both read as
the set standing before `specialize-singletons`.

**The artifact carries names that set does not contain.** `lift-lifted`
(`lib/lowering/upper/specialize-singleton.chiral:195`) builds a new global
`<gname>$<i>` out of a field body, **13 of them on `prog/compiler.prog`**, and
`outline` (`lib/lowering/upper/lower.chiral:311-319`) builds `<name>$<ncase>`,
which `lib/lowering/compile-back.chiral:272` adopts whole as `(cons main extra)`,
**40 outlined extras across 1,509 lowered defs** (`docs/examples/E184-def-fate-sum.md` §1 M-A
and M-D). A function whose domain is the pre-pass set cannot claim a label the
emitted program carries.

**`PRINCIPLES.md` §1 names this shape and its example is the argument.** *"A
seccomp filter is only as complete as the syscall table it enumerates. The fix is
never a longer denylist; it is a model that covers the whole surface, so 'deny by
default' actually means everything."* The pre-pass def set is the enumerated
table and the artifact's name set is the surface. An arm added to the sum while
the domain stays fixed closes nothing, because a created name sits outside the
function before any arm is reached. A fifth arm **over a widened domain** is the
other move and it is DWARF's: a created entity enters with its own identity and a
typed field naming its origin (DWARF5:6070), and an entity with no pre-pass
existence carries no origin field at all (DWARF5:6148-6154). One sum spends two
of its arms on the two levels, so what stays open is which set the function ranges
over.

**One clause survives with an occupant.** *Closed sum, no `_` arm* is shipped by
LLVM, which annotates every instruction that has no source location with one of
four named values, compiler-generated, dropped, unknown and temporary, and detects
an unannotated absence in a coverage-tracking build (LLVMDBGUP:166-194). That is
this clause with a checker behind it, at instruction granularity.

**What this requirement stops asserting: the domain.** FD-21 finds **no occupant**
for the pre-pass set alone as the domain of a total per-definition sum, and prices
the two occupied shapes: the pre-pass set plus what the pass created, which is
DWARF's, and the post-pass set, which is the one system shipping the clause above.
That is decision 1 in `docs/examples/E184-def-fate-sum.md` §6 and it stays the
author's. Spelling `FateRec`'s domain is barred to the SPEC stage until it is
ruled.

**And *exactly one fate* is contingent on the same ruling.** `alloc-growing` is
the source of a `specialized-into` relation and is skipped at `compile-fn` (M-D),
so it takes two arms under the pre-pass domain and one under the post-pass domain.
FD-21 records that nothing surveyed decides whether a definition that survives a
pass and is also the origin of a created one takes one arm or two, because DWARF's
abstract instance root sits in a different sum from the arms a concrete instance
carries.

⚑ **THE DOMAIN IS RULED 2026-09-10 AND THE BAR ON THE SPEC STAGE LIFTS.**
[[records/author-calls]] carries the row *"The domain of E184's fate function, and
whether a deleted definition keeps a fate"* at `ruled` (`0ffa1ae`), and the ruling
with its measurements is `docs/examples/E184-def-fate-sum.md` §6 decision 1.

**The domain is option (ii): the pre-pass def set plus what the pass created**,
computed in two stages. Option (iii) is refused because `x64` and `mach-galo`
having no fate once the pass deleted them is the ungoverned departure
`PRINCIPLES.md` §1 forbids. Option (i) was already dead at [[records/findings]]
FD-21, with no occupant in six systems.

**Deletion is never a fate.** A definition that leaves the globals list leaves
through `ft-specialized` naming its successors, and there is no other exit. Read
at HEAD `0ffa1ae` for this run rather than carried from the ruling: `process-mk`
(`lib/lowering/upper/specialize-singleton.chiral:202`) builds the prune list as
`(cons gname (projs->names ps))`, the singleton global plus its projectors, and
`prune-live` (`:227`) hands `drop-pruned` only the names `gs-refs` finds no
surviving reference for. A name is deleted **because** its content was lifted
into `$i` globals and its projections rewritten onto them, so every departure
from the globals list is already a specialization consequence and the ruling
costs no new machinery. The two back-end deleters are already inside the fate
system: `prune-pass` files `(mk-skrec (tfn-nm f) (sk-callee cn))` at
`lib/lowering/compile-back.chiral:204-211`, and `filter-erasable` files
`(mk-skrec (tfn-nm f) (sk-extern op))` at `:191` on its `(some op)` arm. Its
silent `none` arm at `:189` still drops with no record, which is M-C's finding
and R3's obligation rather than a second exit from the globals list.

**The arm list grows to five and the sum stays closed.** Option (ii) carries
`ft-created (by Str)` for a name with no pre-pass existence, which is DWARF's
published shape: a concrete instance tree may hold entries with no counterpart in
the abstract instance tree, and those carry no `DW_AT_abstract_origin`
(DWARF5:6148-6154). Closure survives a growing compiler because **a new
specialization is a new instance in `ft-specialized`'s `(List Str)` and never a
new arm**. So *closed sum, no `_` arm* stops being a promise to keep editing the
sum as passes are added. FD-23 measured CakeML doing this shape, a name map
threaded through the backend and unioned with four later passes' own stubs, which
is the modular and reproducible recheck the ruling names.

**What the SPEC stage may now do.** Spell `FateRec`'s domain. The bar EN-29 put
on it is lifted.

**What stays the author's, and it is two arm-count questions rather than the
domain.** Both are the 2026-09-09 sub-question ⚑ in
`docs/examples/E184-def-fate-sum.md` §6 decision 1 and neither is ruled.
(a) Whether `specialize-singletons`' creations and `outline`'s creations take one
arm or two: `outline` extracts one case from one definition and so has exactly one
origin, DWARF's out-of-line-instance construct (DWARF5:6188-6214), while LLVM's
machine outliner merges N candidate sites into one function and sets no origin
field (LLVMOUTLINER:950, :1002-1020). (b) Whether a definition that survives the
pass and is also the origin of a created one takes one arm or two. The ruling
narrows (b) without closing it: `ft-specialized` is stated as the exit of a
**departure**, and `alloc-growing` does not depart, because `prune-live` keeps it
wherever `gs-refs` finds a reference and E188's example measures it reaching
`compile-fn` and being skipped there (M-D). Reading that as *one arm, `skipped`*
is the author's act and this run does not take it.

**R2. Reasons carry evidence, not strings.** `skipped`'s reason is itself a closed
sum: extern-with-no-wrapper naming the op; type-does-not-peel naming which type and
where; callee-cascade naming the chain. E157's rule applies unchanged, and a
`str-cat`'d sentence here reintroduces what E157 removed.

**R3. `peel-def` stops returning `(Maybe NDef)`.** `compile-front.chiral:203-210`
drops a def by returning `(none)` and keeps no record at all. It becomes a result
sum. This is the only one of the five mechanisms that leaves no trace, so nothing
downstream can recover it.

**R4. The record survives success.** `compile-all.chiral:34-38` discards the
`skips` list on the `elf-ok` arm, so it surfaces only on an emit failure. Fates
must return on success.

**R5. The cascade is rooted.** `prune-fix` (`compile-back.chiral:213`) is
transitive, and the cascade record is built at `compile-back.chiral:210`, in
`prune-pass`. "Dropped because callee X was dropped" is a pointer rather than an
attribution. Every chain resolves to a non-cascade root. `skip-diag.chiral`
already carries E97's blame chain as the existing shape, which is why it is the
right home.

**R6. Fates survive a renaming.** `specialize-singletons`
(`compile-front.chiral:20`) runs before peel and changes a def's identity: `x64`
becomes `x64$0`, `x64$1` and so on. Fates are therefore a relation across a
renaming, and the rename mapping has to be produced by the pass that performs it
and carried the rest of the way. This is the design fork in the element. Get it
wrong and monomorphized singletons read as failures, which is exactly the
misreading that made the earlier measurement worthless. The pre-run may recommend
splitting R6 into its own element; if it does, that split mints its rows in the
same change.

⚑ **THE RENAMING THIS REQUIREMENT IS BUILT ON IS NOT WHAT THE PASS DOES,
MEASURED TWICE ON 2026-09-09.** [[records/findings]] FD-21 and
`docs/examples/E184-def-fate-sum.md` §1 M-D.

**In the tree.** `lift-lifted`
(`lib/lowering/upper/specialize-singleton.chiral:195`) lifts a field body into a
NEW global named `<gname>$<i>`, and `prune-live` (`:227`) deletes the singleton
and its projectors only where `gs-refs` finds no surviving reference. `x64` stands
beside `x64$0` whenever anything still refers to it, so the pass performs a create
and a delete. On `prog/compiler.prog` it creates **13** names and offers **44**
for pruning.

**In the published survey.** No surveyed pass renames and no surveyed system
carries a rename mapping. DWARF, LLVM and GHC each give a created definition its
own identity in the artifact's namespace and relate it to its origin through a
field or a tag, and DWARF keeps the original entry even where zero copies of it
survive (DWARF5:6056-6060). The one source matching this requirement's
prescription is Graf and Peyton Jones' selective lambda lifting, which threads an
expander mapping through the pass (SELLAM:1071); the object it lifts is a LOCAL
binding the transformation consumes (SELLAM:353), so the original has no separate
fate to keep. `lift-lifted` lifts out of a global that survives, which is the case
lambda lifting does not have.

**What stands.** The pass produces a relation and something has to carry it, and
the failure this requirement names is real: get the relation wrong and
monomorphized singletons read as failures. One clause was verified at HEAD and
stands as written, the ordering. `lib/lowering/compile-front.chiral:373` composes
`(bridge-sig (closconv-sig (specialize-singletons sig)) name)`, and the peel it
reaches at `:349` is `peel-globals`
(`lib/lowering/compile-front.chiral:226-233`), so the pass does run before
peel.

**What goes.** The word *renaming*, the *rename mapping* this requirement asked
the pass to emit, and its standing as the element's design fork. FD-21's occupied
shape is a relation across a creation with the created entity in the domain, which
makes the fork R1's domain question above. `docs/examples/E184-def-fate-sum.md` §6
keeps this requirement inside E184 for that reason, so the split flagged at mint
is closed and no element is minted for it.

⚑ **R6 SURVIVES ON ONE CLAUSE, AND THAT CLAUSE IS RESTATED. 2026-09-10.** The
domain question that took R6's standing as the design fork is ruled (R1's ⚑
above), so what is left of this requirement is testable, and it was tested rather
than kept.

**What the ruling absorbs into R1.** The relation and its carrier: a departing
definition's successors ride `ft-specialized` and a created name's origin rides
`ft-created`. The failure mode this requirement named, monomorphized singletons
reading as failures, is the failure `ft-specialized` exists to prevent and R1
states it. The word *renaming*, the rename mapping this requirement asked the
pass to emit, and the fork standing all went at [[records/enforcement-arc]] EN-29.

**What is R6's own, stated by no other requirement.** Option (ii)'s priced cost is
*a domain the compiler has to compute in two stages*, and neither R1 nor R7 says
where the two stages come from. They come from a pass boundary, and this is the
requirement that fixes it. Stage one is `sig-globals` as `specialize-singletons`
receives it. Stage two is the set of names a creating pass added, together with
each name's origin, which only the pass that added them holds. So the original
prescription's **shape** stands with its object replaced: produced by the pass
that performs the creation, and carried the rest of the way. The object is the
created-name-and-origin relation where it was a rename mapping.

**Two creators sit on that obligation, in two halves of the compiler.**
`lift-lifted` (`lib/lowering/upper/specialize-singleton.chiral:195`) creates
`<gname>$<i>` in the front, **13** on `prog/compiler.prog`. `outline`
(`lib/lowering/upper/lower.chiral:311-319`) creates `<name>$<ncase>` in the back
and `lib/lowering/compile-back.chiral:272` adopts it whole as
`(cons main extra)`, **40** outlined extras across 1,509 lowered defs (M-A, M-D).
The carry therefore crosses peel and the whole lowering, and it is what makes the
domain two-stage in fact and not only in name.

**The ordering clause is what makes stage one readable, and it was verified
again at HEAD `0ffa1ae`.** `lib/lowering/compile-front.chiral:373` composes
`(bridge-sig (closconv-sig (specialize-singletons sig)) name)`, and the peel it
reaches at `:349` is `peel-globals`
(`lib/lowering/compile-front.chiral:226-233`). Under a pre-pass domain that
ordering fixed nothing the fate function reads. Under the ruled domain it fixes
the seam: everything `specialize-singletons` receives is stage one, and
everything downstream of it that invents a name is stage two.

**R7. Conservation, checked inside the compile, plus an exit.** The fates
partition the closure's def set: exactly one per def, and folding them reproduces
the emitted set. A def with no fate, or with two, fails the compile. That is the
line between attribution and logging. `bin/chirality` has compile / run / check /
test and no exit for the report, so one is owed, and the gate that reads it is a
chirality program on E168's test floor rather than a shell script.

⚑ **THE FOLD CARRIES R1's DOMAIN AND MOVES WITH IT, AND THE FAIL-THE-COMPILE
HALF HAS NO OCCUPANT. MEASURED 2026-09-09 BY [[records/findings]] FD-21.** *The
closure's def set* is R1's set, so R1's ⚑ reaches this sentence unedited: the
emitted set this requirement folds to carries the 40 outlined labels and the 13
created globals, and no pre-pass def is named by any of them.

Nothing in the ten pinned sources states a conservation obligation of this shape.
LLVM's coverage-tracking mode is the nearest, and it detects a missing annotation
while the compilation succeeds (LLVMDBGUP:190-194). Nothing surveyed prices
computing the domain in two stages, which is what decision 1's option (ii) costs.
So conservation is this tree's own requirement and it stands unpriced against
prior art.

What stands: conservation is the line between attribution and logging, and the
report exit is owed.

⚑ **THE FOLD IS RE-TESTED AGAINST THE RULED TWO-STAGE DOMAIN, 2026-09-10. ONE
PHRASE IS WRONG, THE SHAPE HOLDS, AND ONE COST IS NEW.**

**Wrong: *the closure's def set*.** R1's 2026-09-09 ⚑ fixed that phrase as the
set standing before `specialize-singletons`, and this requirement inherited it
unedited. The ruled domain is the pre-pass set plus what the pass created, so the
set these fates partition is the two-stage domain of R1's ⚑ above and this
sentence should say so.

**Right and unchanged: the fold is a flat set compare.** Decision 1 prices option
(ii) that way, and the tree agrees on both halves. Every emitted label is inside
the domain, because the 40 outlined extras enter at stage two through
`lib/lowering/compile-back.chiral:272` (M-A) and the 13 created globals enter at
stage one through `lib/lowering/upper/specialize-singleton.chiral:195` (M-D).
Every departure from the domain already carries a fate: the specializer's
deletions take `ft-specialized` (`:202`, `:227`), `prune-pass` files
`(mk-skrec (tfn-nm f) (sk-callee cn))` at `lib/lowering/compile-back.chiral:204-211`,
and `filter-erasable` files `(mk-skrec (tfn-nm f) (sk-extern op))` at `:191`. So
`fold` compares two sets and walks no tree, which is what option (i) would have
cost. The one hole is `filter-erasable`'s silent `none` arm at `:189`, which drops
with no record; §6 decision 5 measures that arm firing **zero** times on
`prog/compiler.prog` (`1549 - 1547 = 2`, both cascade), and it is the departure
this fold is built to catch rather than a counter-example to it.

**New, and this requirement is where it lands: the fold has a seat, and the seat
moved.** Stage two closes only after `outline` has run, which is inside
`lower-defs` in the back. *Checked inside the compile* therefore means after the
back end has assembled both stages, so no front-end seat can carry it. EN-29's
reading stands unchanged: nothing in the ten pins prices computing a domain in
two stages, and this cost is this tree's own.

**Still open, and the SPEC stage owns it rather than the author.** Whether *a def
with no fate, or with two, fails the compile* is spelled as a checked fold or as
a linear obligation. The author names E33's process spawn as the same shape:
`lib/runtime/proc.chiral:25-33` declares `(data Reap ())` with
`(child (1 reap Reap) (io Bytes))` under the comment *a linear obligation to wait
on a child. Dropping it is a type error*. A fold detects an unaccounted departure
after the fact; a linear `ft-specialized` makes it unrepresentable, which is the
same reason [[records/findings]] FD-22 found GCC's nearest equivalent partial by
construction. Two things the SPEC must face, from §6 decision 1's fifth ⚑: a
`Reap` is consumed by one waiter while `ft-specialized` names N successors, so it
is a fan-out; and linearity inside the compiler's own source is a commitment
about how those passes are written. This run leaves the choice open and takes
neither side.

**Unchanged: *exactly one per def*.** It carries R1's two remaining arm-count
sub-questions and nothing else.

#### Cost

Roughly 150 to 250 LOC across five modules. Three signature changes: `peel-def`,
`specialize-singletons` emitting its rename relation, and `compile-all` threading
fates. Plus build-new → test → promote with the fixpoint verified and the Step-0
precondition checked first. **Needs the full pipeline** (worked example → audit →
SPEC → audit → implement): the fate taxonomy is a taxonomy, and R6 is a genuine
fork.

⚑ **TWO CLAUSES HERE ARE FALSIFIED, AND THE ESTIMATE IS LEFT STANDING BESIDE ITS
MEASUREMENT. 2026-09-10.** `specialize-singletons` **emitting its rename relation**
is struck: the pass creates and deletes and emits no rename ([[records/enforcement-arc]]
EN-29, M-D). The signature it owes is the created-name-and-origin relation of R6's
second ⚑, and `outline` owes the same relation in the back. **R6 is a genuine fork**
is struck: the fork was the domain and the domain is ruled (R1's second ⚑). The
element still needs the full pipeline, because the taxonomy is a taxonomy and two
arm-count sub-questions are the author's. The **150 to 250 LOC across five modules**
estimate stays as written and is the prediction it was; `docs/examples/E184-def-fate-sum.md`
§6 measures the spelling at **nine blob modules and eleven signature or data changes**,
**380 to 520 LOC**, and the delta between the two is calibration data the SPEC stage
records rather than overwrites.

#### Why the element exists

Attribution is not measurable today. Five mechanisms determine a def's fate and
only three leave a record, all of it discarded on success.

The one read-only probe, compiling through the E166 `Mach`→C leg and joining
mangled C symbol names back to def names, is gone with that leg (`d8bcec5`,
`d0c5dd5`), and was never legitimate anyway: it shared `compile-front` and
`compile-back` whole and differed only at emit, which is one formulation with two
emitters, the shape `docs/decisions/decision-self-verification.md` §0 explicitly
rules out.

Also recorded, measured 2026-09-01: `skip-reason`
(`lib/lowering/upper/lower.chiral:83-93`) together with `eligible?`, `lower-all`,
`lower-def` and `LowRes` have **no caller outside their own file**. The live path
imports `lower` for `compile-fn` only (`compile-back.chiral:15`). So the four
exclusions those functions name (dependent type, effectful, quantified binder,
type does not lower) are **never produced by a real compile**.

### E185

| E185 | **How the `$apply` dispatcher's erased domains are spelled at the lowering type level** | Not built. Minted 2026-09-04. The level is settled and the spelling is open. [[decisions/decision-erased-word-level]] rules that the erased-word type lives strictly at the lowering type level, that `Core` gains no word spelling, and that the kernel's `conv` relation is left alone. What stays open is the SHAPE of the erased position, and [[records/enforcement-arc]] EN-15 is the measurement that stops without it: `apply-ty` spells the dispatcher's domains with one defunctionalization family member's concrete `Core` types (`lib/lowering/upper/closconv.chiral:1081-1083`), reached from `lib/lowering/upper/closconv-driver.chiral:175`, so four dispatchers carry a tal type their own arms contradict and `ck-prog` is right to refuse them. **Two candidates, and `.planning/RESEARCH-EN15-prior-art.md` §6 measures the prior art as split between them.** **(a) A quantified type variable**, with the concrete types on the constructor: Pottier and Gauthier's specialized `apply`, TAL's abstract `α` in a register-file type, TALx86's `∀α:T4`. **(b) A coarse word type of the lower language**, related by subtyping: Java's `Object`, the JVM verifier's `oneWord`, MLton's `RepType` with `isSubtype`. The tree already reaches `tt-word` from a type variable, because `term->ntalty` maps `(t-var i)` to `(nt-word)` at `lib/lowering/compile-front.chiral:70` under the comment *"B1: an erased type variable in a KEPT position"*. That is an observation about machinery that exists, and it settles nothing. **What it touches:** `apply-ty` and its one call site, plus the peel in `lib/lowering/compile-front.chiral`. All of it is compiler source inside the blob, so the full BUILD RULE applies: `build-new → test → promote` with the fixpoint verified and the Step-0 precondition checked first. **Needs the full pipeline** (worked example → audit → SPEC → audit → implement), because the spelling is a genuine choice between shapes the codebase does not settle. **What it closes.** The arc's requirement 2, wiring `ck-prog` onto the shipping path, is what EN-15 blocks today, and this element is what unblocks it. **What it leaves.** [[records/enforcement-arc]] EN-17, the `$kI_J` capture constructor's field types, is a separate author call and stays open: research §7 shows the prior art keeping constructor fields concrete, so the two instances may take different answers. ⚑ **The scope of that sentence is corrected 2026-09-04 by [[records/enforcement-arc]] EN-20.** What EN-15 measured is no miscompile: every one of these values is one word at runtime, the emitted code is correct, and the defect is the type the IR carries. What the sentence over-claimed is the rest of the pass. `arm-body` (`lib/lowering/upper/closconv.chiral:1051-1058`) has one arm for a site whose `def-ctx` fails, and that arm emits the literal `0` as a whole function body. EN-20 demonstrates the wrong value end to end on today's binary, and the arm is reached twice in the compiler's own blob. That defect is **E188** and it leaves E185's spelling question untouched. | `OURS`; ←E16, ←E18 ⛑ **The line citations in this row are stale by the same +67 drift, corrected 2026-09-05 by E187's re-scope run.** `apply-ty` is at `lib/lowering/upper/closconv.chiral:1163-1165` at HEAD and its one call site at `lib/lowering/upper/closconv-driver.chiral:206`; `arm-body` is at `lib/lowering/upper/closconv.chiral:1109-1126`. E188 landed nine commits into `lib/lowering/upper/` after this row was written. `ledger-lint` check R lands a citation on its symbol and does not catch a span that has drifted past it, which is why the class keeps recurring. |

| E185 | lowering | design | **How the `$apply` dispatcher's erased domains are spelled at the lowering type level.** The level is settled by [[decisions/decision-erased-word-level]]: the erased-word type lives strictly at the lowering type level, `Core` gains no word spelling, and the kernel's `conv` relation is left alone. The spelling is open, and the prior art splits (`.planning/RESEARCH-EN15-prior-art.md` §6): a quantified type variable with the concrete types on the constructor (Pottier and Gauthier, TAL's abstract `α`, TALx86's `∀α:T4`), against a coarse word type of the lower language related by subtyping (Java's `Object`, the JVM verifier's `oneWord`, MLton's `RepType`). `term->ntalty` already maps `(t-var i)` to `(nt-word)` at `lib/lowering/compile-front.chiral:70`, which is an observation and not a decision. Touches `apply-ty` (`lib/lowering/upper/closconv.chiral:1081-1083`), its call site (`lib/lowering/upper/closconv-driver.chiral:175`) and the peel, all compiler source, so the full BUILD RULE applies with the fixpoint verified. **Pipeline: yes.** Closing it unblocks the arc's requirement 2, `ck-prog` on the shipping path. It leaves EN-17, the `$kI_J` capture constructor's field types, which is a separate author call. Minted 2026-09-04; full text in `docs/arcs/enforcement-arc.md`. | ←E16, ←E18 ⛑ **The `apply-ty` citations in this row are stale by the same +67 drift, corrected 2026-09-05 by E187's re-scope run.** `apply-ty` is at `lib/lowering/upper/closconv.chiral:1163-1165` at HEAD and its one call site at `lib/lowering/upper/closconv-driver.chiral:206`. E188 landed nine commits into `lib/lowering/upper/` after this row was written. `ledger-lint` check R lands a citation on its symbol and does not catch a span that has drifted past it. |

### E186

| E186 | **The `$k<i>_<j>` capture constructor's field types: concrete, or the erased word** | **BUILT 2026-09-04**, and it RESOLVES rather than builds: the ruling is **`concrete`** and no compiler source moved. The capture constructor's field types stay at the capture's own source type, and the erased word is reached only where that source type has no ground spelling, which is what `site-fields->term` (`lib/lowering/upper/closconv-driver.chiral:153-163`) already writes. The ruling is in [[decisions/decision-erased-word-level]] (`0d87b27`); the measurement is [[records/enforcement-arc]] EN-21 (`13e4a78`); the gate is `tools/test/capture-fields.sh` (`f1d86b7`) over `prog/e186-capture-fields.prog` (`50693c6`) and `tools/test/samples/e186_capture_fields.prog` (`ab18600`), running **`9 ok, 0 FAIL`**: base `ok ok ok ok`, then M1 `ok bad bad ok`, M2 `ok bad ok bad`, M3 `ok ok bad ok`, M4 `bad absent absent absent`, and **M5 `ok ok ok bad`, reddening R4 alone** on the fourth fixture site no golden pins. ⚑ **No file under `lib/` is touched**, so the blob is byte-identical by construction and there is no `build-new → test → promote` and no fixpoint in this element; what `tools/test/run-tests.sh` witnesses is one thing, Phase 7's root census moving **88 → 89**. ⚑ **The gate takes no suite phase number** and declares itself out with a reason, so `registration.sh` G2 and G4 stay green: it is the eighth `PEND` and the fourth script waiting on the standing call in [[records/author-calls]]. ⚑ **That row stays OPEN and carries a pointer**; closing it is the author's own edit. Minted 2026-09-04 by E185's SPEC run, from [[records/enforcement-arc]] EN-17, and the author call EN-17 holds is what this element carries. [[decisions/decision-erased-word-level]] settles where the erased-word type lives and reaches the `$apply` dispatcher's domains only; the capture constructor's fields are a second instance and the prior art answers them the other way. `.planning/RESEARCH-EN15-prior-art.md` §7: Pottier and Gauthier's `succ : Arrow int int` carries concrete field types beside concrete arrow indices, Minamide, Morrisett and Harper hide a heterogeneous environment behind `∃` with the fields concrete inside the pack, and Huang and Yallop's label-context entry keeps the captures at their source types. The structural reason the two instances differ: a capture constructor, spelled by `ctor-name` (`lib/lowering/upper/closconv.chiral:1201`), is applied at exactly one site, its own definition site, so nothing forces its field types to merge, while the shared dispatcher's argument position is constrained by every member of the family at once. ⚑ **E185 does not decide this and does not wait on it.** E185 states the dispatcher's parameter types as the erased word, which makes `$apply7`'s field check in `ck-con` (`lib/lowering/tal/check.chiral:183-196`) pass on the parameter side while the constructor's declared fields stay concrete, so the four dispatchers go green with this question still open. What stays open is whether the fields themselves erase. **The author call comes first** and the pipeline follows it, which is why the element is minted rather than scheduled. ⚑ **The scope of that sentence is corrected 2026-09-04 by [[records/enforcement-arc]] EN-20.** The field-type defect this row carries is no miscompile, for EN-15's reason: every one of these values is one word at runtime and the emitted code is correct. The wider reading, that the `$apply` machinery emits correct code, is false. `arm-body`'s unreachable arm is reached and emits the literal `0` as a whole function body (`lib/lowering/upper/closconv.chiral:1051-1058`), which is **E188**. | `OURS`; ←E185, ←E18 |

| E186 | lowering | built | **The `$k<i>_<j>` capture constructor's field types: concrete, or the erased word.** EN-17 turned from an author call into an element by E185's SPEC run. The 2026-09-04 ruling settles the dispatcher's domains and does not reach the capture constructor, and `.planning/RESEARCH-EN15-prior-art.md` §7 finds both published answers keeping constructor fields CONCRETE. The structural reason: a capture constructor (`ctor-name`, `lib/lowering/upper/closconv.chiral:1201`) is applied at one site, so nothing forces its fields to merge, while the dispatcher's argument position is constrained by the whole family. E185 goes green without this: stating the dispatcher's parameters as the erased word makes `$apply7`'s `ck-con` field check pass on the parameter side with the fields left concrete. **The author call comes first.** Minted 2026-09-04; full text in `docs/arcs/enforcement-arc.md`. ⚑ **BUILT 2026-09-04**: the ruling is **`concrete`**, written in [[decisions/decision-erased-word-level]] (`0d87b27`), measured as [[records/enforcement-arc]] EN-21 (`13e4a78`), and gated by `tools/test/capture-fields.sh` (`f1d86b7`) at `9 ok, 0 FAIL` over four rows and five mutants, M5 reddening R4 alone. No compiler source moved, so there is no fixpoint; Phase 7's root census moves 88 → 89 for `prog/e186-capture-fields.prog`. The gate takes no phase number and the author's row stays open. | ←E185, ←E18 |

#### Why it is separate from E185

One ruling covering both instances would prejudge the second. The dispatcher's
argument position is constrained by every member of its family at once, so it is
the varying side and the erased word is the honest spelling. A capture
constructor is applied at one site only, so it is the concrete side, and every
system in `.planning/RESEARCH-EN15-prior-art.md` §7 keeps it concrete. The
measured `$apply7` rejection is the opposite arrangement to that reading, which
is exactly why the question is open rather than settled by analogy.

#### What it does not block

E185. Stating a dispatcher's parameter types as the erased word makes the
parameter side of `ck-con`'s field check pass, because `tal-ty=?`
(`lib/lowering/tal/check.chiral:68-70`) has the erased word matching everything.
The constructor's declared fields are untouched by E185 and stay concrete. So the
four dispatchers accept with EN-17 still open, and what EN-17 blocks is the
question of whether the fields are honest, not whether the dispatchers are.

### E187

| E187 | **The `sk-defunc` blame channel: `closconv` states why it dropped a family** | **BUILT 2026-09-05.** Steps 1 to 8 at `8f688be`, `ef40238`, `6ce142d`, `926b8f8`, `4ce44ae`, `21e1b28`, `7a0b3fd` and `8d4009d`, promoted at `8d4009d`, with a citation repoint at `0d7ebb5`. **The fork closed as TWO LISTS**: `CState` is `(cstate fams ho pois dsk)` and `keep-fams` still filters on `pois` alone. `st-pois-defunc` constructs `sk-defunc` from `st-add-gsite`'s two refusing arms, and `dsk` rides `CCOut`, `fr-ok` and `back-program`'s seed parameter to the message, so the breaker now answers `... | defunctionalization refused: e188-plus: family arity disagrees with the global's`. **Fixpoint** `C1 == C2` at 1,188,216 B on a blob of 820,959 B, agreeing at the FIRST comparison and well inside the `C4` bound; the byte-identity behind that reading was checked rather than assumed, 90 of 90 roots identical, 0 differing, 9 skipped, and 0 cause clauses anywhere in the self-compile. Gate `tools/test/defunc-blame.sh` reads `11 ok, 0 FAIL`, six rows on one verdict line and five mutants all built and run, with R2, R3 and R4 measuring `bad` before this element. Suite `373 passed, 0 failed`, 90 roots built, 0 failed, gate PASSED. **Two SPEC pins were measured false**, M4's seventh field on a three-record filter and M5's whole line, and **R1 is reddened by no mutant**, a measured GA-22 shortfall whose falsifier is owed to a fixture that lowers. All three are in [[records/enforcement-arc]] EN-23. ⚑ **The symptom string in the minted prose below is wrong, and the SPEC's M-A measured it so**: the breaker's pre-change refusal reads `extern does not lower: reference stays upper: e188-plus`. ⚑ **The `docs/examples/INDEX.md` row is OWED**, unwritten at this flip because that file held the author's in-flight work. ⚑ **RE-SCOPED IN PLACE 2026-09-05 by author call**, on the finding of E187's own pre-run and the EXAMPLE-level audit that confirmed it (`1069c10`). **What E187 was.** Minted 2026-09-04 by E185's SPEC run as *`closconv` states the lowering-level type of every name it invents*, over the three families the pass mints, `$clo<i>`, `$apply<i>` and `$k<i>_<j>`, and retiring E185's `apply-ty` residue. **Why that subject is spent.** The row treated three invented names as three instances of one job, and only one of them is a global. `$apply<i>` is a global, so `peel-def` consults E185's stated map through `sp-get`, and **E185 built that**. `$clo<i>` is minted as `(data-decl dname nil ctors)` (`lib/lowering/upper/closconv-driver.chiral:186`) with NO type parameters, so it carries no content of its own: `apply-ptys` (`lib/lowering/upper/closconv-driver.chiral:131-133`) writes `(nt-data (clo-name i) nil)` at the one position the name is not recoverable, and `term->ntalty`'s `t-tcon` arm (`lib/lowering/compile-front.chiral:68`) derives the identical value everywhere else with no channel. `$k<i>_<j>` is that data's constructors, and **E186 ruled their fields `concrete`**, so a second stated channel would transport a value identical to the one `field-tys->n` already peels. E185's named residue closes by ruling rather than by build: `apply-ty`'s domain CONTENT is read by nothing, because `peel-def` reaches `ty-kept-doms` only in its `(none)` branch and `sp-get` hits, and `ty-erased` returns nil since every `mk-pi` binder is `q=2`; [[decisions/decision-erased-word-level]] forbids the only honest replacement. The type-statement clauses are struck. ⚑ **`E189` stays free and nothing is minted.** Option (ii), retiring E187 and giving the survivor a fresh number, would have spent the LAST free number in Lane A's `E184-E189` band, which is shared with [[arcs/diagnostics-arc]], and spending a scarce contested number is what produced the two-`E173` collision this tree records. Re-scoping cost four row titles and is reversible. **What E187 is now.** `SkReason` gained `sk-defunc` in E188 (`lib/lowering/skip-diag.chiral:15`, accessors `skwhy-name` at `:25-26` and `skwhy-tag` at `:28-29`) and **no caller constructs it**. `st-add-gsite` (`lib/lowering/upper/closconv.chiral:720-726`) holds both facts the blame needs, the global's name `g` and which of two conditions fired, an untyped global or a family/global arity mismatch, and discards both in its own two refusing arms: each calls `st-add-pois` (`lib/lowering/upper/closconv.chiral:684-686`), typed `(-> CState Core CState)`, which appends the family KEY alone to `CState`'s `pois`, a `(List Core)` (`lib/lowering/upper/closconv.chiral:626`). So `keep-fams` (`lib/lowering/upper/closconv-driver.chiral:96-106`) drops the family, the source def is left unrewritten, and `compile-fn` refuses it with `body is not a lambda chain`, the SYMPTOM rather than the cause; [[records/enforcement-arc]] EN-22 measured that string on E188's own control fixture. This element routes the reason to the user. **What it touches**, priced with every arity measured by the audit: `CState` has three fields (`lib/lowering/upper/closconv.chiral:626`) and gains a fourth; `CCOut` has two (`lib/lowering/upper/closconv-driver.chiral:145`) and gains a **third**, which is where E188's own residue note says *fourth* and is wrong; `fr-ok` has four (`lib/lowering/compile-front.chiral:319-320`) and gains a fifth; `back-program` (`lib/lowering/compile-back.chiral:300-304`) gains a seed `SkRec` parameter whose seat `lower-defs` already has as `nil nil`; and one pattern line at `prog/e186-capture-fields.prog:287`, which must land in the same commit as the `CCOut` widening or that probe stops compiling. Six files, all inside the blob, so the full BUILD RULE applies: `build-new → test → promote` with the fixpoint verified and the Step-0 precondition checked first. **The observable** is `tools/test/samples/e188_slot_break.prog`, which already reaches the guard and today answers the symptom. ⚑ **The emitted code must be BYTE-IDENTICAL over `lib/` and `prog/`**: E188 measured a guard-off rebuild identical there, so no family in this tree is poisoned and no blame should appear. **Needs the full pipeline**, because one genuine shape fork is left for the SPEC stage: `pois` and `dsk` as two lists against one list of pairs. `keep-fams` filters on `key-in? pois key`, so merging makes every membership test project a pair, and only two of `st-add-pois`'s three call sites carry a name, so one list of pairs needs a `Maybe Str` or a fourth `SkReason` arm. | `OURS`; ←E185, ←E186, ←E188 |

| E187 | lowering | built | **The `sk-defunc` blame channel: `closconv` states why it dropped a family.** E188 minted `sk-defunc` (`lib/lowering/skip-diag.chiral:15`) and no caller constructs it. `st-add-gsite` (`lib/lowering/upper/closconv.chiral:720-726`) knows the global's name and which of two conditions fired, an untyped global or a family/global arity mismatch, and drops both into `st-add-pois` (`:684-686`), whose `(-> CState Core CState)` has a seat for the family key alone. So a poisoned family reaches the user as `body is not a lambda chain`, the symptom. Priced: `CState` three fields to four, `CCOut` two to three, `fr-ok` four to five, a seed parameter on `back-program` whose seat `lower-defs` already has, and one pattern line in `prog/e186-capture-fields.prog`. Six files inside the blob, full BUILD RULE with the fixpoint, observable on `tools/test/samples/e188_slot_break.prog`. **Pipeline: yes**, on one shape fork the SPEC stage owes: `pois` and `dsk` as two lists against one list of pairs. Minted 2026-09-04; full text in `docs/arcs/enforcement-arc.md`. ⚑ **RE-SCOPED IN PLACE 2026-09-05 by author call**, on the finding of E187's own pre-run and the EXAMPLE-level audit that confirmed it (`1069c10`). **What E187 was.** Minted 2026-09-04 by E185's SPEC run as *`closconv` states the lowering-level type of every name it invents*, over the three families the pass mints, `$clo<i>`, `$apply<i>` and `$k<i>_<j>`, and retiring E185's `apply-ty` residue. **Why that subject is spent.** The row treated three invented names as three instances of one job, and only one of them is a global. `$apply<i>` is a global, so `peel-def` consults E185's stated map through `sp-get`, and **E185 built that**. `$clo<i>` is minted as `(data-decl dname nil ctors)` (`lib/lowering/upper/closconv-driver.chiral:186`) with NO type parameters, so it carries no content of its own: `apply-ptys` (`lib/lowering/upper/closconv-driver.chiral:131-133`) writes `(nt-data (clo-name i) nil)` at the one position the name is not recoverable, and `term->ntalty`'s `t-tcon` arm (`lib/lowering/compile-front.chiral:68`) derives the identical value everywhere else with no channel. `$k<i>_<j>` is that data's constructors, and **E186 ruled their fields `concrete`**, so a second stated channel would transport a value identical to the one `field-tys->n` already peels. E185's named residue closes by ruling rather than by build: `apply-ty`'s domain CONTENT is read by nothing, because `peel-def` reaches `ty-kept-doms` only in its `(none)` branch and `sp-get` hits, and `ty-erased` returns nil since every `mk-pi` binder is `q=2`; [[decisions/decision-erased-word-level]] forbids the only honest replacement. The type-statement clauses are struck. ⚑ **`E189` stays free and nothing is minted.** Option (ii), retiring E187 and giving the survivor a fresh number, would have spent the LAST free number in Lane A's `E184-E189` band, which is shared with [[arcs/diagnostics-arc]], and spending a scarce contested number is what produced the two-`E173` collision this tree records. Re-scoping cost four row titles and is reversible. **BUILT 2026-09-05**, promoted at `8d4009d`. The fork closed as TWO LISTS: `CState` is `(cstate fams ho pois dsk)` and `keep-fams` still filters on `pois` alone. `st-pois-defunc` constructs `sk-defunc` from `st-add-gsite`'s two refusing arms and `dsk` rides `CCOut`, `fr-ok` and `back-program`'s seed to the message. Fixpoint `C1 == C2` at 1,188,216 B, blob 820,959 B, first comparison, with 90 of 90 roots byte-identical and 0 cause clauses in the self-compile. Gate `tools/test/defunc-blame.sh` `11 ok, 0 FAIL`, five mutants built and run. Suite `373 passed, 0 failed`, gate PASSED. Two SPEC pins were measured false and R1 is reddened by no mutant; all three are in [[records/enforcement-arc]] EN-23. ⚑ The symptom string above is wrong, as the SPEC's M-A measured: the pre-change refusal reads `extern does not lower: reference stays upper: e188-plus`. ⚑ The `docs/examples/INDEX.md` row is OWED. | ←E185, ←E186, ←E188 |

#### Why it is separate from E188, which minted `sk-defunc` and left it unreached

⚑ **This subsection is rewritten 2026-09-05 for the re-scoped subject.** It used
to argue E187 apart from E185 on the ground that E187 states the type of the two
invented names E185's channel does not reach. That ground is gone: E185 and E186
between them consumed it, and the element's row records the measurement.

E188 built the guard. `st-add-gsite` refuses a defunctionalization site whose
global is untyped or whose family arity disagrees with the global's, `keep-fams`
drops the family, and `arm-body`'s spine replaced the literal `0`. E188 also
minted `SkReason`'s third arm, `sk-defunc`, and left it with **no caller**,
because reaching the user costs a field on four data types plus a pattern line in
a probe. E188's own row names that as residue. **E188 stops at the refusal and
E187 carries it to the reader.**

The cut is the fixpoint. E188's change moved 8,192 bytes and settled at
generation three; widening `CState`, `CCOut` and `fr-ok` is a second blob move
with its own fixpoint to verify and its own byte-identity claim to make over
`lib/` and `prog/`. Folding the channel into E188 would also have put a shape
fork the codebase does not settle, `pois` and `dsk` as two lists against one list
of pairs, inside the element that repairs a live miscompile.

### E188

| E188 | **`arm-body`'s unreachable arm is reached, and an `$apply` arm returns a literal `0` as a whole function body** | **BUILT 2026-09-04.** Minted 2026-09-04 from [[records/enforcement-arc]] EN-20, and it is the first live wrong-code defect this arc has measured in the shipping compiler. **The defect.** `def-ctx` (`lib/lowering/upper/closconv.chiral:582-596`) returns `(none)` for a defunctionalization site whose `peel-lam-exact` fails, which is any curried projector whose type peels deeper than its body is `lam`s. `arm-body` (`:1051-1058`) has exactly one arm for that case, the `(none)` arm at `:1057` carrying the comment `unreachable: g always has a def-ctx`, and it emits `(c-lit-i 0)` as the arm's whole body. It is reached twice in the compiler's own blob, at `mach-galo` and `mach-gbnw` (`lib/lowering/mach/mach.chiral:134-137`), which `alloc-growing` (`lib/memory/alloc-growing.chiral:18-24`) puts in value position: `$apply5`'s `$k5_8` arm and `$apply6`'s `$k6_3` arm are each two instructions, `const 0` then `ret`. **The demonstration.** EN-20 built a fixture of that shape outside `lib/` and `prog/`, compiled and ran it with today's binary, and got three lines: `direct box-f: 30`, `via $apply: 0`, `via $apply2: -10`. The same global is correct called directly and returns `0` through the dispatcher. **Three candidate fix shapes, and EN-20 picks none.** (a) `arm-body` builds the call spine `(g cap0..capk-1 arg0..argd-1)` from the site, which is correct without reading the body at all. (b) `def-ctx` eta-expands a body shallower than its type before peeling. (c) `collect` poisons the family when `def-ctx` fails, the mechanism `keep-fams` (`lib/lowering/upper/closconv-driver.chiral:96-106`) already runs for an unsaturated higher-order use, which turns wrong code into a named skip. ⚑ **Erasing the codomain would HIDE this defect.** `tal-ty=?`'s first arm makes `tt-word` match everything (`lib/lowering/tal/check.chiral:68-70`), so a `tt-word` return accepts `const 0` and the two red rows go green with the wrong code still emitted. That is the one repair shape ruled out in advance. ⚑ **`ck-prog` does not detect the general case, and the gate is the interesting part of this element.** The `ret` refusal reddens the compiler's two instances only because their family codomain happens to be `(List Asm)`. EN-20's fixture has an `I64` codomain, `const 0` matches the declared return, `ck-prog` accepts, and nothing anywhere reddens. A gate for E188 must therefore catch a body that returns a LITERAL where it should return a COMPUTATION, which is a value-level assertion the existing type-level check demonstrably cannot make. This row states that requirement and does not design the gate. ⚑ **Blast radius in this tree is zero today, and nothing measures that on purpose.** `compile-fn` skips `alloc-growing` and `mach-galo`, so no `$clo5` or `$clo6` con reaches any of the 1,484 TFns and the two dead dispatchers ride into the ELF uncalled. The same two sites appear in `prog/test-runner.prog`, `prog/wield.prog`, `prog/prose-lint.prog` and `prog/paren-audit.prog`. The suite's green line and the byte fixpoint witness none of it. **What it touches:** `arm-body`, `def-ctx` or `collect` depending on the shape chosen, all compiler source inside the blob, so the full BUILD RULE applies: `build-new → test → promote` with the fixpoint verified and the Step-0 precondition checked first. **Needs the full pipeline** (worked example → audit → SPEC → audit → implement), because three candidate shapes is a choice the codebase does not settle.  ⚑ **The ground for shape (a) is CORRECTED 2026-09-04 by the SPEC run** (`docs/elements/specs/E188-unreachable-arm-reached-SPEC.md` §3.0). (a) is **not** saturated by construction. `d` is `(cc-llen (peel-pi-doms key))` of the FAMILY key (`lib/lowering/upper/closconv-driver.chiral:204`, `:207`), and `fv-site` (`lib/lowering/upper/closconv.chiral:852-862`) keys a site by the CALLEE'S PARAMETER SLOT, which `peel-pi-doms` (`:304-309`) stops peeling at a type variable. A census over `lib/` and `prog/` finds **66 such sites and 0 mismatches**, so `d = arity - k` holds today by MEASUREMENT and nothing in the pass enforces it; a fixture built outside `lib/` and `prog/` breaks it and today's binary answers `$apply0: extern does not lower: unbound var`, a NAMED REFUSAL rather than a second wrong value, because `env-get` (`lib/lowering/upper/lower.chiral:198`) indexes `len-1-ix` so a negative index can never alias a live binder. So (a) is correct only underneath a guard, and the SPEC puts the guard at the site builder where the poison channel already runs, which makes `(+ k d)` the arity reading and makes `saturated by construction` a CONSEQUENCE of the guard instead of an assumption. ⚑ **BUILT 2026-09-04**, in nine commits `959d04c` through the record slice. Both candidates landed: **(c)** as `st-add-gsite` at `collect`, one helper called by the three `cs-g` site builders (`lib/lowering/upper/closconv.chiral:830`, `:848`, `:858`), routing a family/global arity mismatch or an untyped global to `st-add-pois`; and **(a)** as the arm, `(cspine (c-global g) (spine-args 0 0 fields (+ k d) k m d))` run through `rw`. `SkReason` gained `sk-defunc` and NO CALLER REACHES IT: the blame channel is unbuilt and named as residue, because surfacing it costs a fourth `CCOut` field that `prog/e186-capture-fields.prog:287` pattern-matches, plus an `FR` field and a `compile-back` edit. Gated by `tools/test/apply-spine.sh` at **11 ok, 0 FAIL**, base `ok ok ok ok ok ok apply=30`, over `tools/test/samples/e188_apply_spine.prog`, `tools/test/samples/e188_slot_break.prog` and `prog/e188-apply-spine.prog`. All five mutants BUILT AND RUN: M1 `ok bad ok ok ok bad apply=0`, M2 `absent absent absent bad bad bad apply=absent`, M3 `ok ok ok ok bad ok apply=30`, M4 `ok bad ok ok ok bad apply=40`, M5 `ok ok bad ok ok ok apply=30`; two pins differ from the SPEC's table and both corrections are measurements ([[records/enforcement-arc]] EN-22). Fixpoint at **generation THREE, not two**: 1,192,312 → 1,192,312 → 1,184,120 → 1,184,120 bytes, sha256 `cadc5bb9`. The whole 8,192-byte move is step 4's arm, and a guard-off rebuild emits BYTE-IDENTICAL output over the compiler's own blob, so no family in `lib/` or `prog/` is newly poisoned. Suite `373 passed, 0 failed, 90 roots built, 0 failed, gate PASSED`, the root census up one for the probe. ⚑ **The SPEC's §1 claim that EN-20's own fixture prints `30` on both lines is REFUTED.** A body genuinely shallower than its type does not lower either (`rewrite-one`, `closconv-driver.chiral:251-253`), so the spine there CALLS an unlowerable def and the compile is refused by name -- §3.3's argument made literal, and better than a silent `0`, but a refusal and not a value. The value row rides on the ANNOTATION shape instead, where `strip-lams` skips an ann and `peel-lam-exact` does not. [[records/enforcement-arc]] EN-20 is `FIXED`; EN-22 carries the run. | `OURS`; ←E185, ←E16 |

| E188 | lowering | built | **`arm-body`'s unreachable arm is reached, and an `$apply` arm returns a literal `0` as a whole function body.** Minted 2026-09-04 from [[records/enforcement-arc]] EN-20, the arc's first measured wrong-code defect in the shipping compiler. `def-ctx` (`lib/lowering/upper/closconv.chiral:582-596`) refuses a curried projector whose type peels deeper than its body, and `arm-body` (`:1051-1058`) answers that with `(c-lit-i 0)` under a comment reading `unreachable: g always has a def-ctx`. Reached twice in the compiler's own blob, `mach-galo` and `mach-gbnw`. EN-20's fixture on today's binary: `direct box-f: 30` against `via $apply: 0`. Three candidate shapes and none picked: build the call spine from the site, eta-expand a shallow body, or poison the family through `keep-fams`. Erasing the codomain would HIDE it, because `tal-ty=?`'s `tt-word` arm matches everything, and `ck-prog` misses the general case whenever the family codomain is ground, so the gate must assert the VALUE. Compiler source, full BUILD RULE. **Pipeline: yes.** Minted 2026-09-04; full text in `docs/arcs/enforcement-arc.md`. ⚑ **BUILT 2026-09-04**, in nine commits `959d04c` through the record slice. Both candidates landed: **(c)** as `st-add-gsite` at `collect`, one helper called by the three `cs-g` site builders (`lib/lowering/upper/closconv.chiral:830`, `:848`, `:858`), routing a family/global arity mismatch or an untyped global to `st-add-pois`; and **(a)** as the arm, `(cspine (c-global g) (spine-args 0 0 fields (+ k d) k m d))` run through `rw`. `SkReason` gained `sk-defunc` and NO CALLER REACHES IT: the blame channel is unbuilt and named as residue, because surfacing it costs a fourth `CCOut` field that `prog/e186-capture-fields.prog:287` pattern-matches, plus an `FR` field and a `compile-back` edit. Gated by `tools/test/apply-spine.sh` at **11 ok, 0 FAIL**, base `ok ok ok ok ok ok apply=30`, over `tools/test/samples/e188_apply_spine.prog`, `tools/test/samples/e188_slot_break.prog` and `prog/e188-apply-spine.prog`. All five mutants BUILT AND RUN: M1 `ok bad ok ok ok bad apply=0`, M2 `absent absent absent bad bad bad apply=absent`, M3 `ok ok ok ok bad ok apply=30`, M4 `ok bad ok ok ok bad apply=40`, M5 `ok ok bad ok ok ok apply=30`; two pins differ from the SPEC's table and both corrections are measurements ([[records/enforcement-arc]] EN-22). Fixpoint at **generation THREE, not two**: 1,192,312 → 1,192,312 → 1,184,120 → 1,184,120 bytes, sha256 `cadc5bb9`. The whole 8,192-byte move is step 4's arm, and a guard-off rebuild emits BYTE-IDENTICAL output over the compiler's own blob, so no family in `lib/` or `prog/` is newly poisoned. Suite `373 passed, 0 failed, 90 roots built, 0 failed, gate PASSED`, the root census up one for the probe. ⚑ **The SPEC's §1 claim that EN-20's own fixture prints `30` on both lines is REFUTED.** A body genuinely shallower than its type does not lower either (`rewrite-one`, `closconv-driver.chiral:251-253`), so the spine there CALLS an unlowerable def and the compile is refused by name -- §3.3's argument made literal, and better than a silent `0`, but a refusal and not a value. The value row rides on the ANNOTATION shape instead, where `strip-lams` skips an ann and `peel-lam-exact` does not. [[records/enforcement-arc]] EN-20 is `FIXED`; EN-22 carries the run. | ←E185, ←E16 |

#### Why it is separate from E185, E186 and E187 as those were minted

E185 and E186 state a TYPE, and so did E187 until its 2026-09-05 re-scope.
E188 is a wrong VALUE. `apply-ty`'s domains, the
`$k<i>_<j>` fields and the invented names all carry an annotation the emitted
code contradicts, and repairing the annotation moves no byte, which
`docs/elements/specs/E185-type-preserving-upper-SPEC.md` R6 pins as a control.
`arm-body`'s `(none)` arm emits a different instruction stream from the one the
site calls for, so no statement of a type repairs it. [[records/enforcement-arc]]
EN-19 reached the same conclusion from the other side: `cod-key-eq` was suspected
of merging two families and was cleared, and the residue was the code.

#### The gate this element owes, and why the existing one is not it

`ck-prog`'s `ret` check refuses `$apply5`'s and `$apply6`'s arms today. That is
luck. The refusal fires because those two families return `(List Asm)`, so
`const 0 : i64` disagrees with the declared return. EN-20's fixture has an `I64`
codomain, `const 0` agrees with the declared return, `ck-prog` accepts, and the
wrong code ships silently. A gate for E188 must assert the VALUE the dispatcher
produces on a fixture of the shallow-body shape, because the type-level check is
absent for the whole class of families whose codomain is ground. The requirement
is stated here and the gate is designed in the pipeline.

#### What it does not touch

The blast radius in this tree is zero today. `compile-fn` skips `alloc-growing`
and `mach-galo`, so the two bad dispatchers are dead code inside every blob that
carries them, and the byte fixpoint is undisturbed by both the defect and its
repair. Requirement 2 is unaffected: E185 is what stands between `ck-prog` and
the shipping path, and E188 is a defect `ck-prog` on the shipping path would
still miss.

## The typed-assembly floor: built, and adopted at one point only

[[goals/enforcement]] states the gap in its own State list: the typed-assembly
floor is built and unadopted, and neither the floor checker nor the optimizer's
re-check runs in the shipping compile. **Half of it expired 2026-09-05 and came
back on 2026-09-08.** The optimizer's re-check ran on every compile from
`5b7478f` to `b613a8f`, EN-24; the author's PRB-70 ruling cut it, so neither
half runs today and the goal's sentence is true again as written. The floor
checker `ck-prog` has never had a call site, which is requirement 2. These four
elements are that sentence. Every count below was measured 2026-09-02 by
grepping `(import "<key>")` over `lib/` and `prog/` and by walking the transitive
import closure of `prog/compiler.prog`, which is 50 modules.

### E16

| E16 | **Lowering: pure→tal, register/slot alloc, non-tail case outlining, preserve-check** | Three of the four deliverables are built and the fourth never runs. `lib/lowering/upper/lower.chiral` (407 L) is inside the compiler's closure and `lib/lowering/compile-back.chiral` imports it for `compile-fn`, which makes E16 the one element of these four on the live path. The preserve-check has no call site: `ck-prog` lives in `lib/lowering/tal/check.chiral` and is called nowhere in `lib/` or `prog/`; `lower.chiral` imports `prelude/prelude` and `lowering/tal/ssa` and nothing further; `compile-back.chiral` imports `lowering/tal/check` at no line. The two comments that name the check (`lib/lowering/upper/lower.chiral:20`, `:115`) say an emitted `TFn` would reach `ck-prog` with no conversion. That is a fact about the IR and is no evidence of a call. The check stays in E16's scope as its remaining work. | `OURS`; SSA/reg-alloc (Cooper–Torczon) (`PAPER`) |

| E16 | lower | built | **Lowering: pure→tal, reg/slot alloc, preserve-check.** Three of four deliverables. The lowering runs on every compile; the preserve-check in the element's own title runs on nothing, because `ck-prog` has no caller and `compile-back.chiral` never imports the module that defines it. Building it is the enforcement content of this row, and E70 carries the effect-side twin. | ←E18, →E70 |

### E17

| E17 | **Optimizer: const-fold, DCE, specialize/partial-eval/pregen** | **Wired 2026-09-05, and the re-check was cut 2026-09-08.** `lib/lowering/compile-back.chiral:16` imports `lowering/upper/optimize`, and `lower-defs` const-folds every emitted TFn. From `5b7478f` to `b613a8f` it adopted the residual only through `chk-ok`, which `re-check` could not form without ck-fn judging it, at **1,582 TFns per self-compile, 1,550 `chk-ok`, 32 `chk-err`**, un-folded baseline 1,550. PRB-70's ruling took `lowering/tal/check` back out of the compiler closure, so the fold's residual is adopted unjudged and the census runs from `prog/optimizer-census.prog` instead, at 1,548/1,517/31. The 254 lines are on the live path. ⚑ **`dead` IS EXCLUDED BY MEASUREMENT.** Wired whole, `optimize` reaches a fixpoint and the compiler miscompiles itself, `293 passed, 98 failed` with `91 roots built, 0 failed`; `fold` alone grades `tools/test/row.sh` at `42 passed, 0 failed` and `dead` alone at `33 passed, 9 failed`. `re-check` accepts the dead residual. [[records/enforcement-arc]] EN-24 | partial evaluation (Jones–Gomard–Sestoft) (`PAPER`) |

| E17 | optimize | built | **Optimizer: const-fold, DCE, specialize/pregen.** 254 L, **imported by `compile-back.chiral:16` since 2026-09-05**, inside the compiler blob. `fold` runs on every compile. The re-check that guarded it ran from 2026-09-05 to 2026-09-08 and was cut by PRB-70's ruling, so the module no longer carries `lowering/tal/check` in with it. ⚑ The ledger's state cell files E17 `built`, and built here now means reached as well as present. What is left is the DCE pass, which miscompiles and which `re-check` accepted anyway, EN-24, and requirement 4's second branch, which is unwritten | ←E18 |

### E18

| E18 | **TAL checker + reference tal interpreter** | Split three ways, one part reached. `lib/lowering/tal/ir.chiral` (49 L) is built and inside the compiler's closure, with six importers: `lowering/mach/emit-core`, `lowering/tal/bytes`, `lowering/tal/reify`, `lowering/tal/sys-check`, `lowering/tal/sys-linkage`, `lowering/tal/sys`. The checker `lib/lowering/tal/check.chiral` (246 L) had two importers under `lib/`, `lowering/upper/optimize` and `lowering/upper/eff-lower`; PRB-70's ruling repointed both at `lowering/tal/ssa` on 2026-09-08, so it has **zero importers under `lib/`** and one under `prog/`, the census probe `prog/optimizer-census.prog`. The reference interpreter `lib/lowering/tal/eval.chiral` (187 L) has none. Everything except the IR is outside the compiler's closure. ⚑ The catalog's earlier wording said both importers of `check` were themselves unimported, and that is stale: `eff-lower` has an importer now, and the conclusion survives because that importer is itself dead. | Typed Assembly (Morrisett et al.) (`PAPER`) |

| E18 | tal | built | **TAL checker + reference tal interpreter.** The IR is reached (49 L, six importers, in the blob); the checker (246 L) and the reference interpreter (187 L) are outside the blob and run on nothing. Adopting the checker is what closes the goal's floor-is-unadopted bullet, and it is the same call site E16 owes. | →E16, ←E70 |

### E70

| E70 | **Effectful lowering: the effect row's tal shadow plus a preserve-check over the effect claim** | Design. Unbuilt, and gated on `decision-effect-facets` (edge 16). This is the second preserve-check in the arc and the harder one: E16's check is over types the lowering already carries, while this one is over the effect claim, which `lib/lowering/upper/eff-lower.chiral` (183 L) models and no module inside the compiler's closure reads. Making `=>` arrows lowerable is the precondition for self-hosting going native, because the compiler is itself effectful. | `OURS` (`lib/lowering/upper/lower.chiral`, `lib/lowering/upper/eff-lower.chiral`) plus the effect-facets decision |

| E70 | lower-reach | design | **Effectful lowering: effect-row tal shadow + preserve-check over the effect claim.** Gated on `decision-effect-facets` (edge 16). The effect-side twin of E16's unrun check. | ←E16, ←E12 |

## Numbering

E184 was the **first element minted for this arc** and **E185** is the second,
minted 2026-09-04. **E186 and E187** are the third and fourth, minted 2026-09-04
by E185's SPEC run, which is the stage that mints. **E188** is the fifth, minted
2026-09-04 from [[records/enforcement-arc]] EN-20. The highest previously minted
element was **E183**. Lane A mints in **E184–E189**, Lane B in **E190–E195**
(`docs/decisions/decision-lane-split.md`). **The next free number is `E189`**, the
last one in Lane A's band, and the band is shared with [[arcs/diagnostics-arc]].
⚑ **`E189` survived E187's 2026-09-05 re-scope and is still free.** E187's
pre-run measured the element as minted spent and the author took option (i), a
re-scope in place, precisely so the last contested number in the band stayed
unspent. Spending one is what produced the two-`E173` collision this tree
records.
A new element's row lands in `docs/examples/INDEX.md` **and here** in the same
change: those are the only two tracked places, and therefore the only collision
detectors that exist.
