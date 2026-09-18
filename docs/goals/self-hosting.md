---
node: goal-self-hosting
layer: navigation
related: [goals/README, status-ledger, testing-floors, bug-classes, records/homing-triage, records/findings, index]
status: current
updated: 2026-09-18
---

# Goal: the language compiles and checks itself

## The claim, and where the project makes it

- [[status-ledger]], the self-hosting fixpoint milestone: the native compiler
  compiles its own source to a byte-identical copy of itself, and CPython is
  evicted from the compile path. `docs/definitions/status-ledger.md:11-17`.
- `docs/decisions/decision-scope.md:29-30`: current work is self-hosting only,
  the language compiling and checking itself.
- [[working-discipline]], The build rule: *"The compiler compiles everything.
  Python compiles nothing."* `build-new`, test, promote, and nothing replaces
  itself in place. `docs/definitions/working-discipline.md:15-21`.

## What done means

**Amended 2026-09-14 on the author's direction, and the claim above is
unchanged.** This section was undercounting it. Conditions 1 to 3 are the
fixpoint, and the BUILD RULE holds each one on every change that reaches the
compiler's import closure. Conditions 4 and 5 read the same claim over the
compiler's parts rather than over its output, and nothing holds either. The
author's words, on being told that a goal whose three conditions are all held
leaves an arc under it unanchored: *"it becoming that is just splitting it. Do
it."*

1. **`bin/chirality-bin` compiles the blob to a binary that compiles the same
   blob to a byte-identical binary**, with each artifact checked non-empty
   before the compare. Held by the BUILD RULE, whose procedure
   `docs/definitions/working-discipline.md:26-33` states as the command block a
   person runs. A standing rule holds it, so it carries no arc. ⚑ **The
   observation this condition carried until today named two gates that measure
   something else, and both were opened in this run.** `bin/chirality test` is
   `tools/test/run-tests.sh` (`bin/chirality:181`), and no phase in that file
   runs the compare; `tools/test/run-tests.sh:412` records the absence as *"no
   committed blob artifact to cmp against"*. `tools/test/map-integrity.sh` reads
   `.planning/MIGRATION-MAP.tsv`, and its own header at `:7` calls itself
   `not-a-phase` that a person runs after a move.
2. **The binary is committed**, with the tree and harness that rebuild it. Held
   by the same rule, observed by a fresh clone reproducing it.
   `bin/chirality-bin` is tracked and 1,220,984 B, measured 2026-09-14. A
   standing rule holds it, so it carries no arc.
3. **Nothing replaces itself in place.** Build-new, test, promote. Held by the
   BUILD RULE, which [[working-discipline]] states and which every
   compiler-source change owes. A standing rule holds it, so it carries no arc.
4. **Every checking rule the compiler ships runs on a path something asserts.**
   `docs/definitions/bug-classes.md:171-173` states the failure in one sentence:
   a checking rule can be written, compile cleanly, pass the suite, get marked
   built in the catalog, then run on no path. Two observations, because a rule
   fails to run in two ways. **(a)** The module sits inside the transitive
   import closure of `prog/compiler.prog` over the `lib:prog` search path,
   observed by the closure assertion `docs/definitions/bug-classes.md:183-188`
   describes and says no element covers. **(b)** A phase asserts a value over
   the root rather than only compiling it, observed by the root's name appearing
   in some `tools/test/*.sh` script. All four subject arcs below state this
   condition over their own subject, each arc's own `goals:` field naming which of its
   requirements carry it: [[arcs/sys-face-arc]] its 2 and 3,
   [[arcs/checker-core-arc]] its 1, 2 and 6, [[arcs/lowering-and-emit-arc]] its
   1, 2 and 3, and [[arcs/substrate-floor-arc]] its 1 and 2. ⚑ **Observation (a)
   is stated over three subjects of four.** The other three arcs each carry (a)
   as requirement 2, worded as every module an element of the arc names sitting
   inside the compiler's import closure. `docs/arcs/sys-face-arc.md:137-143` is
   a state-claim requirement and no sys-face requirement names the closure,
   measured 2026-09-18.
5. **Every built element of the compiler holds a roster row in an arc.** Homing
   is planning, which `docs/decisions/decision-scope.md:42-63` fixes and the
   author ruled on 2026-09-10, so a `built` element still takes a row.
   [[goals/README]] at `:27` is the invariant. Observed by `python3
   tools/lens/lens.py chain`, rung `catalog element -> arc roster row`, with no
   `built` element left among the unhomed. All four subject arcs below serve it
   and the table gives each one its date: [[arcs/sys-face-arc]] rosters nineteen
   elements, [[arcs/checker-core-arc]] eighteen,
   [[arcs/lowering-and-emit-arc]] twenty-three and
   [[arcs/substrate-floor-arc]] sixteen, counted from the four rosters
   2026-09-18. Sixteen `built` catalog elements tree-wide hold no roster row, so
   every subject is served and the condition is unmet.

## Arcs

**Conditions 1 to 3 carry no arc, and that is their finished shape.** The BUILD
RULE holds them on every change whose deliverable enters the compiler's import
closure. An arc schedules work toward a condition that is open, and a condition a
standing rule maintains on every change has nothing to schedule.
[[goals/README]] states that shape once, under Rules.

**Conditions 4 and 5 are open and all four of their arcs exist.** Each owns one
subject of the compiler, rosters the elements of that subject that no other arc
rosters, and states over the same code the reach and assertion requirements
condition 4 names. The seam is subject, read off the categories in
`docs/elements/ledger.md` and checked against class `Q1` of
`records/homing-triage.md:62`. [[arcs/sys-face-arc]] took the crossings,
[[arcs/checker-core-arc]] the type theory, [[arcs/lowering-and-emit-arc]] the
path to ELF, and [[arcs/substrate-floor-arc]] what a compiled program stands
on.

| arc | subject | its elements | the nearest standing arc, and the boundary |
|---|---|---|---|
| [[arcs/checker-core-arc]], opened 2026-09-18 | the reader and the type theory: reader, NbE, bidirectional infer and check, QTT, data and coverage, positivity, linear kinds, de Bruijn, mutual data groups, refinement, narrowing, totality, linear-result externs | 18. E1, E2, E3, E4, E5, E6, E7, E8, E9, E10, E11, E13, E14, E48, E79, E101, E102, E159 | [[arcs/enforcement-arc]] owns what the compiler states about its own work. This arc owns the rules that decide it |
| [[arcs/lowering-and-emit-arc]], opened 2026-09-18 | surface to ELF: x64 codegen, the B1 passes, defunctionalization, porttype carriers, closure conversion, effectful mutual recursion, the module search path, the executable format | 23. E15, E19, E34, E69, E87, E93, E94, E95, E96, E97, E100, E108, E109, E123, E144, E145, E147, E154, E155, E167, E168, E169, E170 | [[arcs/emitted-speed-arc]] owns what emitted code costs. This arc owns whether the emitter's own parts are reached and gated at all |
| [[arcs/substrate-floor-arc]], opened 2026-09-18 | what a compiled program stands on: the loader, the mmap arena and its growth, byte cells, I64 arithmetic, the FFI trampoline, collections, the `Pool` region, linear containers | 16. E20, E21, E22, E23, E24, E25, E27, E41, E89, E90, E91, E106, E111, E113, E120, E122 | [[arcs/memory-discipline-arc]] owns the value-cell heap's reclamation discipline under [[goals/local-ai]]. This arc owns the substrate those cells sit in |
| [[arcs/sys-face-arc]], opened 2026-09-17 | the crossings themselves: mmap and its family, poll, clock and exit, the sys-face linkage, tty and termios, pty acquisition and hygiene, fd adoption and close, sockets and socketpair, filesystem mutation | 19. E28, E29, E30, E31, E32, E51, E98, E99, E103, E104, E107, E110, E121, E124, E125, E126, E127, E129, E149 | [[arcs/syscall-custody-arc]] owns the permitted set and who may widen it. This arc owns the crossings that set governs |

The four arcs roster 76 elements between them and the rung reads 142 of 188,
measured 2026-09-18 by `python3 tools/lens/lens.py chain`. Of the 46 elements
holding no roster row, one is `superseded` and exempt, 27 are admitted by a row
in `records/lenses/unspoken.md`, and 18 are owed a home with 16 of those
`built`. `records/homing-triage.md` proposes an existing arc for some of the 18
and records the rest as straddles awaiting a ruling, so they belong to the arcs
and the calls that file already names.

**Eight arcs have opened in exactly this shape**, each homing elements that had
no arc: [[arcs/orchestration-engine-arc]], [[arcs/syscall-custody-arc]],
[[arcs/runtime-loading-arc]], [[arcs/surface-syntax-arc]],
[[arcs/sys-face-arc]], [[arcs/checker-core-arc]],
[[arcs/lowering-and-emit-arc]] and [[arcs/substrate-floor-arc]]. The last four
are this goal's subject arcs and each took one unit of work to open.

⚑ **`docs/goals/README.md:48` still gives this goal `none open, and see Rules`,
and that cell is now owed a change.** It is true of conditions 1 to 3 and false
of 4 and 5. `ledger-lint` check V stopped reading it once [[arcs/sys-face-arc]]
opened, because V reads the cell only for a goal no arc serves. Check AF reads
it instead, as the reason conditions 1 to 3 name no arc, so replacing the cell
outright raises three AF violations against three conditions a standing rule
holds. Whatever the cell becomes has to keep the words `none open` at its
head.

## State

**Conditions 1 to 3 hold. Conditions 4 and 5 do not, and this run is the first
time the goal states them.**

`bin/chirality-bin` is 1,220,984 B, measured 2026-09-14. The last recorded suite
run is 2026-09-01 in [[status-ledger]] at `:46`: 303 assertions, 0 failed, 11
phases, 88 roots, `gate PASSED`. This session ran no suite. ⚑ This
section read *"321 assertions, 0 failed, 87 roots"* until today. That merged the
recorded run with the matcher figure at `docs/definitions/status-ledger.md:165`
and matched neither, which `records/doc-rot.md:96` raised.

A stack fragments because each layer is held to a different constraint, so the
test of one language is whether it survives being held to all of them at once.

| layer | written in chirality as | state |
|---|---|---|
| the compiler | `prog/compiler.prog` over `lib/lowering/` | self-hosting, byte-identical fixpoint |
| the checker | `lib/typing/`, 3,449 lines | on the path of every compile |
| the emitter | `lib/lowering/x64/emit.chiral` | emits the shipped ELF |
| the runtime | `lib/runtime/`, 3 modules | outside the compiler's import closure |
| the tooling | `prose-lint`, `paren-audit`, `resolve`, `test-runner`, `wield` | 14 Python files remain, [[goals/self-tooling]] |
| config and data | `.manifest` | resolves as an import target, contents unchecked, E163 |
| a frozen port set | `(profile name (ports ...) (target t))` | refuses at emit, `compile-emit.chiral:300` |

⚑ E182 fixpointed at generation two on 2026-09-02. A source change that alters
emitted code makes the old binary's output differ from that output's own, and the
answer is to promote the fixpoint rather than generation one
([[records/findings]] FD-08).

## Honest limits

- **18 catalog elements are owed a home, 16 of them `built`**, against
  condition 5. Tree-wide 46 of the 188 hold no roster row, measured 2026-09-18
  by `python3 tools/lens/lens.py chain` on the rung `catalog element -> arc
  roster row`: one is `superseded` and exempt, 27 are admitted by a row in
  `records/lenses/unspoken.md`, and the remaining 18 are the count check AE
  raises. The figure read 63 of 188 on 2026-09-17 and 81 of 187 on 2026-09-14,
  split then by ledger category SYS 18, CG 15, MEM 14, CK 11, VAL 7, EF 5,
  ORCH 4, RF 3, FMT 2, APP 2. Homing the 16 is what would close the condition. ⚑
  **This limit read *"39 of the compiler's own built elements hold no roster row
  anywhere"* until today.** Those 39 were the three arcs of §Arcs at 13 elements
  each and all 39 now hold a row. Class `Q1` at
  `records/homing-triage.md:62` counts 55 against the state before the four arcs
  opened.
- **44 of `lib/`'s 95 `.chiral` modules sit outside the compiler's import
  closure**, against condition 4(a). Measured 2026-09-14 by resolving `(import
  ...)` transitively from `prog/compiler.prog` over `lib:prog` across the three
  importable extensions `MAP.md:19` names: the closure is 62 import targets, of
  which 51 are `.chiral` modules totalling 17,272 lines, against `lib/`'s 95
  modules and 26,216 lines. **Eight of the 44 are checking machinery, 1,105
  lines**: `lowering/tal/check` 312, `lowering/tal/eval` 187,
  `lowering/upper/eff-lower` 183, `typing/row-infer` 137, `lowering/tal/spec`
  126, `typing/kernel-core` 60, `typing/reflect-floor` 54, `typing/effects` 46.
  `lowering/tal/check` is importable beside the compiler and imported by nothing:
  `grep -rn 'import "lowering/tal/check"' lib prog` returns nothing, and the
  spans naming it are prose. ⚑ This limit read *"59 modules and 16,463 LOC out of
  `lib/`'s 103 and 25,559. 1,680 LOC of checking machinery sits outside it,
  including `lowering/tal/check`, `typing/effects` and `typing/totality`"* until
  today. `typing/totality` entered the closure on 2026-09-02 through
  `typing/totality-check`, and `lowering/upper/optimize` entered it through
  `lib/lowering/compile-back.chiral:16`, so the machinery list is eight rather
  than ten.
- **83 of the 102 compilable roots are named by no `tools/test/*.sh` script**,
  against condition 4(b). Measured 2026-09-14: `grep -rl '^(def compile-main' lib
  prog` returns 103 files over 102 distinct basenames, which is the selector
  Phase 7 uses at `tools/test/run-tests.sh:175`, and 57 distinct `.prog`
  basenames appear across `tools/test/*.sh`. Phase 7 compiles every root, and
  `tools/test/run-tests.sh:423` says what that buys: *"compile-only: N roots
  built, N failed -- gates, but asserts nothing"*.
- **No phase runs the fixpoint compare**, so conditions 1 to 3 are held by a
  discipline a person executes rather than by a check that fails. The BUILD RULE
  is real and every compiler-source change owes it. ⚑ **Ruled 2026-09-17: the
  BUILD RULE is a discipline, and the compare owes a phase.** The vocabulary
  holds as written. `docs/definitions/status-ledger.md:136-140` fixes ENFORCED
  as gated and IMPLEMENTED as load-bearing with nothing failing when it breaks,
  so a compare a person runs holds conditions 1 to 3 at IMPLEMENTED, and
  [[goals/README]]'s standing-gate shape under Rules already names this goal's
  case and already states that the first condition records the absent phase.
  **The residue is work.** A phase that builds two generations from one blob and
  compares them is what makes these three gate-held, and `docs/goals/README.md:48`
  keeps `none open` until it exists: `26bf3be` measured that removing the cell
  drops this goal from check AF's gated set and raises three fresh violations.
- **The compare's phase has no owner, and `enforcement` does not hold it.** Read
  2026-09-17. [[goals/enforcement]]'s five conditions and
  [[arcs/enforcement-arc]]'s six requirements reach ENFORCED ledger rows, the
  typed-assembly floor on the shipping path, the check agreeing with the compiler
  it checks, the optimizer's re-check, the tooling ratio, and a named mutant per
  gate row. None of the eleven names the fixpoint, the blob, or the BUILD RULE.
  The nearest candidate in §Arcs is [[arcs/lowering-and-emit-arc]], whose
  subject is whether the emitter's own parts are reached and gated at all. ⚑
  **FLAG, author tier: naming that arc the owner is a placement call, and this
  goal does not take it.** The phase is owed and unplaced.
- **Phase 11's stated reason for being unported does not hold, measured
  2026-09-17.** `tools/test/run-tests.sh:412` gives it as *"no committed blob
  artifact to cmp against"*, and the compare
  `docs/definitions/working-discipline.md:26-33` states puts two generations
  built inside the run against each other, so the compare takes no committed
  blob as an input. Both inputs it does take are tracked: `bin/chirality-bin` at
  1,220,984 B, and `bin/chirality-resolve.sh`, whose `chirality_blob_file` at
  `:269` regenerates the blob from the source tree. The owed phase is therefore a
  wrapper over an existing procedure and existing artifacts, and its cost is the
  compile time of two generations. The other half of that line, the unreachable
  basename-collision class, is untested here and stands.
- **A fixpoint shows stability. It says nothing about correctness.** That gap is
  [[goals/independent-judgment]].
- **A `built` state cell is a claim, and its binding to evidence can miss
  silently.** `docs/elements/ledger.md:196` carries E76 at `built (ENFORCED)`
  naming `target-linux.chiral` and `test-syscall-manifest.sh`; `find . -name
  'target-linux*'` returns only `lib/lowering/tal/target-linux.manifest` and
  `find . -name 'test-syscall-manifest*'` returns nothing, both measured
  2026-09-14. The W^X instance this bullet also carried is repaired: `bfb863b`
  moved the typed seal to unbuilt residue at `docs/banks/runtime.md:402`.
  [[records/findings]] FD-27 is the general statement and E76 is its worked
  failure. That class is condition 1 of [[goals/presentability]], so this goal
  names it and leaves it there.
