---
node: goal-self-hosting
layer: navigation
related: [goals/README, status-ledger, testing-floors, bug-classes, records/homing-triage, records/findings, index]
status: current
updated: 2026-09-17
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
   in some `tools/test/*.sh` script. [[arcs/sys-face-arc]] states both
   observations over the crossing subject, as its requirements 2 and 3. The
   other three subject arcs below have yet to open, so this condition is
   served over one subject of four.
5. **Every built element of the compiler holds a roster row in an arc.** Homing
   is planning, which `docs/decisions/decision-scope.md:42-63` fixes and the
   author ruled on 2026-09-10, so a `built` element still takes a row.
   [[goals/README]] at `:27` is the invariant. Observed by `python3
   tools/lens/lens.py chain`, rung `catalog element -> arc roster row`, with no
   `built` element left among the unhomed. [[arcs/sys-face-arc]] serves it over
   the crossing subject and rosters nineteen elements. The other three subject
   arcs below have yet to open, so this condition is served over one subject of
   four.

## Arcs

**Conditions 1 to 3 carry no arc, and that is their finished shape.** The BUILD
RULE holds them on every change whose deliverable enters the compiler's import
closure. An arc schedules work toward a condition that is open, and a condition a
standing rule maintains on every change has nothing to schedule.
[[goals/README]] states that shape once, under Rules.

**Conditions 4 and 5 are open and one of their four arcs exists.** Each would
own one subject of the compiler, roster the elements of that subject that no arc
rosters today, and state over the same code the reach and assertion requirements
condition 4 names. The seam is subject, read off the categories in
`docs/elements/ledger.md` and checked against class `Q1` of
`records/homing-triage.md:62`. [[arcs/sys-face-arc]] opened 2026-09-17 and took
the crossings. The other three are named below and unopened.

| arc | subject | its elements | the nearest standing arc, and the boundary |
|---|---|---|---|
| `checker-core`, unopened | the reader and the type theory: reader, NbE, bidirectional infer and check, QTT, data and coverage, positivity, linear kinds, de Bruijn, mutual data groups, refinement, narrowing, totality, linear-result externs | 13. E1, E3, E4, E5, E6, E7, E8, E9, E10, E11, E13, E79, E159 | [[arcs/enforcement-arc]] owns what the compiler states about its own work. This arc owns the rules that decide it |
| `lowering-and-emit`, unopened | surface to ELF: x64 codegen, the B1 passes, defunctionalization, porttype carriers, closure conversion, effectful mutual recursion, the module search path, the executable format | 13. E19, E34, E69, E93, E95, E97, E100, E109, E123, E144, E145, E147, E155 | [[arcs/emitted-speed-arc]] owns what emitted code costs. This arc owns whether the emitter's own parts are reached and gated at all |
| `substrate-floor`, unopened | what a compiled program stands on: the loader, the mmap arena and its growth, byte cells, I64 arithmetic, the FFI trampoline, collections, the `Pool` region, linear containers | 13. E20, E21, E23, E24, E25, E27, E89, E90, E91, E106, E113, E120, E122 | [[arcs/memory-discipline-arc]] owns the value-cell heap's reclamation discipline under [[goals/local-ai]]. This arc owns the substrate those cells sit in |
| [[arcs/sys-face-arc]], opened 2026-09-17 | the crossings themselves: mmap and its family, poll, clock and exit, the sys-face linkage, tty and termios, pty acquisition and hygiene, fd adoption and close, sockets and socketpair, filesystem mutation | 19. E28, E29, E30, E31, E32, E51, E98, E99, E103, E104, E107, E110, E121, E124, E125, E126, E127, E129, E149 | [[arcs/syscall-custody-arc]] owns the permitted set and who may widen it. This arc owns the crossings that set governs |

The three unopened arcs cover 39 of the 63 `built` elements that hold no roster
row, measured 2026-09-17 by `python3 tools/lens/lens.py chain`. The other 24 are
unhomed for a different reason: `records/homing-triage.md` proposes an existing
arc for some and records the rest as straddles awaiting a ruling, so they belong
to the arcs and the calls that file already names.

**Opening any of the three is a separate unit of work, and naming them here is
not opening them.** Five arcs have opened in exactly this shape, each homing
elements that had no arc: [[arcs/orchestration-engine-arc]],
[[arcs/syscall-custody-arc]], [[arcs/runtime-loading-arc]],
[[arcs/surface-syntax-arc]] and [[arcs/sys-face-arc]].

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

- **39 of the compiler's own built elements hold no roster row anywhere**,
  against condition 5. Tree-wide the figure is 63 of the 188 catalog elements,
  measured 2026-09-17 by `python3 tools/lens/lens.py chain` on the rung `catalog
  element -> arc roster row`. It read 81 of 187 on 2026-09-14, split by ledger
  category SYS 18, CG 15, MEM 14, CK 11, VAL 7, EF 5, ORCH 4, RF 3, FMT 2,
  APP 2, and [[arcs/sys-face-arc]] homed nineteen of the SYS rows on 2026-09-17.
  The 39 are the three unopened arcs of §Arcs, 13 elements each, and they fall
  in class `Q1` at `records/homing-triage.md:62`, which that file defines as a
  built self-hosting-core element whose residue no arc's requirement names and
  counts at 55. Opening those three is what would close the condition.
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
  is real and every compiler-source change owes it. Whether that still counts as
  the standing-gate shape [[goals/README]] records under Rules is a call this
  goal does not take, and it decides whether conditions 1 to 3 keep the
  `none open` cell.
- **A fixpoint shows stability. It says nothing about correctness.** That gap is
  [[goals/independent-judgment]].
- **A `built` state cell is a claim, and its binding to evidence can miss
  silently.** `docs/elements/ledger.md:196` carries E76 at `built (ENFORCED)`
  naming `target-linux.chiral` and `test-syscall-manifest.sh`; `find . -name
  'target-linux*'` returns only `lib/lowering/tal/target-linux.manifest` and
  `find . -name 'test-syscall-manifest*'` returns nothing, both measured
  2026-09-14. `docs/banks/runtime.md:377` lists the W^X loader among its built
  shards while `readelf -l bin/chirality-bin` reports a single `RWE` PT_LOAD.
  [[records/findings]] FD-27 is the general statement and E76 is its worked
  failure. That class is condition 1 of [[goals/presentability]], so this goal
  names it and leaves it there.
