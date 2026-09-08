---
node: goal-emitted-speed
layer: navigation
related: [goals/README, goals/own-web, goals/self-hosting, goals/enforcement, goals/local-ai, benchmarks/language-performance, benchmarks/crypto-kernel-allocation, benchmarks/OPT-CANDIDATES-2026-09, benchmarks/OPTIMIZATIONS-TODO, implementation/optimizer-inventory, arcs/crypto-primitives-arc, arcs/memory-discipline-arc, status-ledger, index]
status: current
updated: 2026-09-08
---

# Goal: the code this compiler emits is fast enough for what the project ships

## The claim, and where the project makes it

This goal is a derivation. The repo states the ambition in four places, and the
first of them states it in its own words and parks it.

- [[benchmarks/OPTIMIZATIONS-TODO]] names itself "the continuation contract" in
  its title and "the RESUMPTION contract" in its header, closes the campaign by
  author call on 2026-08-02, and names the entry point on resumption:
  `rd-packed`, certificate design ratified, zero code written. A parked contract
  is the project saying this work continues.
- [[benchmarks/language-performance]] publishes a band as a standing claim about
  the language: ~1.4x of `gcc -O2` on compute and 5 to 8x on memory and branch
  work, run-10 verified, closed 2026-08-02. Publishing a ratio against a C
  compiler is the project saying its emitted code is meant to stand beside one.
- [[benchmarks/README]] states why every figure carries a host, a date and a
  band: this project has a false-summit history and will not carry an unsourced
  number. The convention exists because cost is something this tree reports on.
- [[goals/own-web]] condition 4 requires every layer's crypto to be chirality's
  own, and [[arcs/crypto-primitives-arc]] requirement 5 makes that observable as
  "no allocation in an inner loop, and the resident cost measured against the
  declared budget rather than assumed". That dependency is measured as of
  2026-09-07, and the measurement refutes the requirement for the one primitive
  already built.

**Why this opens instead of amending a standing goal.** [[goals/self-hosting]]
claims a byte-identical fixpoint and is held with no arc by the BUILD RULE. A
cost condition there would need scheduled work, which would break the shape
[[goals/README]] records as that goal's finished one. [[goals/enforcement]]
claims that what is built is gated and that the compiler's claims about its own
work are carried as evidence. Its two performance sentences say that erasure
makes checking free at runtime and that the optimizer's re-check should run in
the shipping compile, and both are about whether a check runs. Neither goal
claims anything about what a compiled program costs, and widening the claim of
either one is a decision `docs/decisions/` holds first, per [[goals/README]].

## What done means

Six conditions. [[arcs/emitted-speed-arc]] holds conditions 1 and 2. The other
four hold no arc file. The sixth is the operation set the other five measure the
cost of, so it sits beside them instead of standing as its own goal.

1. **The shipping compiler carries a cost figure against a control outside the
   tree.** Every `gcc` ratio in this tree was measured on the evicted
   Python-hosted backend: [[implementation/optimizer-inventory]] §4 attributes
   both `docs/benchmarks/RESULTS-2026-08-01.md` and
   [[benchmarks/language-performance]] to `scaffold/chirality/native.py`, and
   `scaffold/` is absent from this tree. Observed: one doc under
   `docs/benchmarks/` whose figures name `bin/chirality-bin` by sha256, carry a
   host and a date, and quote a band against a named outside control.
   **Held by [[arcs/emitted-speed-arc]] requirement 3, row `X5`.**
   ⚑ **The ratio this condition should reach is OWED.** The 2026-08-02 band
   measured a backend that no longer exists, so it is a record of something else
   and sets no target, and no other figure in the tree sets one either.

2. **Building a product stops forcing an allocation.** Measured 2026-09-07 by
   [[benchmarks/crypto-kernel-allocation]] on `bin/chirality-bin`, sha256 prefix
   `7d971a30c0bfda52fc2d952b`: ten double rounds of ChaCha20 allocate 4,560 B in
   90 arena cells per 64-byte block, the whole block function allocates 5,776 B,
   and the same ARX arithmetic carrying its four lanes as parameters allocates
   zero bytes and runs 3.1 to 3.4x faster at quiet load.
   [[benchmarks/OPT-CANDIDATES-2026-09]] names what holding it requires as
   `B4`: `ti-cona` always allocates, and the IR has no field-update or reuse
   form. Observed: `tools/bench/crypto-kernel.sh alloc` reporting a zero delta
   for the round subject, which is also the observable
   [[arcs/crypto-primitives-arc]] requirement 5 states for
   `crypto-primitives/K20`. **Held by [[arcs/emitted-speed-arc]] requirement 1,
   rows `X1`, `X2` and `X3`.**

3. **Each of the nine enablers the candidate walk discovered is built, or
   carries a recorded refusal.** [[benchmarks/OPT-CANDIDATES-2026-09]] lists 221
   candidates walked out of seven pinned pass catalogues, and about 45 of them
   want one of nine enablers: no interprocedural constant fact, no loop form, no
   location vocabulary, no non-allocating product, no CFG, the binary-only
   `ti-prim`, the single-slot return, and the refinement and quantity drops at
   the peel. Each of the nine is a capability this substrate does not reach
   today, and [[working-discipline]] rules on how that is recorded. All nine
   classify as category A, so no floor holds any family below A, and 213 of the
   221 rows are A with zero B among them. Observed: every row of that enabler
   table reading as a built enabler or as a recorded refusal. **Unopened, and it
   holds no arc file.**

4. **A shipped native tool runs inside a declared budget.**
   `prog/prose-lint.prog` measures 15.1x slower than the mawk tool it replaces,
   band 7.8x to 18.5x, allocating 1.11 GB to scan 609,872 B over 81 files, and
   is OOM-killed at the tree's default scope
   ([[benchmarks/text-matcher-prose-lint]], 2026-09-02, self-hosted). Observed: a
   gate row that fails when the tool exceeds its stated budget.
   **Unopened, and it holds no arc file.**
   ⚑ **The budget is OWED.** The author's 2026-09-01 ruling, recorded at
   `docs/benchmarks/README.md:29`, says the wall clock is recorded and sets no
   bar, so there is no number for a gate to check and this condition cannot be
   observed until one is stated. [[arcs/crypto-primitives-arc]]
   `crypto-primitives/K13` owes the same thing on the crypto side: the target
   declaration and the cost model that gives `best` a meaning.

5. **A cost figure in this tree names the backend that produced it.**
   [[implementation/optimizer-inventory]] §4 marks the split document by
   document and closes by recording that the line between the two backends is
   otherwise unmarked in `docs/benchmarks/`, where the README described five
   docs against twelve files on 2026-09-07 and the directory holds thirteen
   files today. Observed: every doc under `docs/benchmarks/` naming its backend
   in its own text, and the README's list matching the directory.
   **Unopened, and it holds no arc file.**

6. **Every operation the machine offers is named or refused, and every name the
   `Op` sum carries reaches the surface.** [[working-discipline]] section "A
   capability the substrate lacks is a finding" is the frame, and `PRINCIPLES.md`
   P1 fixes the form: an operation the backend emits that the language does not
   name is P1's forgotten-syscall hole one level down, so an idiom recognized in
   the emitter sits underneath a named primitive and substitutes for none. Three
   sets carry the condition. The `Op` sum (`lib/prelude/prelude.chiral:36-39`)
   declares fifteen constructors, the extern block (`:58-71`) binds fourteen,
   and `op-bytes` (`lib/lowering/x64/mach.chiral:351-385`) encodes fifteen.
   `op-mulhi` is the one difference: `:373` emits it as the signed one-operand
   `imul` at `:319`, and no program can write it. Outside all three sits what a
   current ISA offers and the sum omits, which
   [[benchmarks/OPT-CANDIDATES-2026-09]] bucket C enumerates as **38 rows**:
   rotate, unsigned widening multiply, conditional move, byte swap,
   count-leading-zeros, count-trailing-zeros, popcount, add-with-carry, bit
   deposit and extract, the unsigned comparisons and divisions, and a native
   32-bit lane. What the gap costs is a count. ChaCha20's `qround` is 28
   operations here, `4 x (add32=2, bxor=1, rotl32=4)`
   ([[benchmarks/crypto-kernel-allocation]] section 3), and a machine holding a
   rotate and a 32-bit lane pays one apiece for the three, so 12. That is an
   operation count and it is unrelated to the 2.2 to 2.3x wall clock the same
   document reports. Observed in two halves. First, the three in-tree sets
   agreeing constructor for constructor, which a script reads out of two files
   and which finds exactly one difference today. Second, every bucket C row
   reading as a named operation or as a recorded refusal, where `C35`, `C36` and
   `C37` recognize an idiom in the emitter, name no operation, and therefore
   close none of `C1`, `C21` and `C32`. **Unopened, and it holds no arc file.**
   ⚑ **The baseline this is complete against is OWED.** `C10` and `C11`
   record that BMI2 availability is a target question this tree has not asked,
   and `C34` records that no document states what a shift by 64 or more means.
   The control box carries `bmi1`, `bmi2`, `adx` and `popcnt` in
   `/proc/cpuinfo`, read 2026-09-08, and one host's flag list settles no
   baseline. What would set it is a statement in
   `docs/decisions/` naming the instruction set the emitted code may assume. No
   threshold is owed here. The disposal is built or refused, which needs no
   number.

## Its relation to the arc that already holds part of this

[[arcs/memory-discipline-arc]] rows `M3` (`E83`, alloc-reuse) and `M4` (`E84`,
alloc-dps) attack the same cells condition 2 measures, and they are scheduled
under [[goals/local-ai]] condition 1 against that arc's requirement 1, whose
observable is peak RSS on the default-scope projection. Reclaiming a cell sooner
leaves the cell allocated and the field reads in place, so that arc closes the
footprint half of the measurement and leaves condition 2 standing. Which arc
should carry the other half is unsettled, and this goal records the overlap
instead of assuming an answer.

## Arcs

[[arcs/emitted-speed-arc]], opened 2026-09-08, takes **condition 1 and
condition 2**, which are the two the 2026-09-07 measurements make actionable. It
carries four requirements and six roster rows under arc-local ids `X1` to `X6`.

**Conditions 3, 4 and 5 stand unopened**, and the arc records why for each.
Condition 4 is the one to watch: its budget is owed, so its observable is a gate
row that fails when a tool exceeds a bar nobody has set, which is the
gate-that-cannot-fail shape `docs/decisions/decision-scope.md` names. The arc
refused it on that ground rather than shipping a check aimed at a guess. The
budget is now a row in [[records/author-calls]].

**Condition 6 stands unopened too, and the arc excludes it by its own rule.**
That arc schedules a row iff building it requires choosing between shapes the
codebase does not already settle, and on that ground it puts bucket C outside
itself, reading `C33` as a finishing job the surface never got. The rule sorts
those 38 rows and disposes of none of them, so the condition is untouched by it.
An arc that took condition 6 would open on the one row that is genuine design:
what a widening multiply's shape is, given that `C38` wants an operation
defining two slots and `B15` records the single-slot return standing against it.
This goal names that as the opening question and settles nothing about it.

No standing gate holds this goal, which is **a hole rather than the finished
shape** [[goals/self-hosting]] carries: the 2026-09-01 ruling makes the suite's
wall clock a printed number that sets no bar.

This section carries no element rows and no roster.

## State

Stated 2026-09-08, unbuilt. One arc is open, [[arcs/emitted-speed-arc]], and it
takes two of the six conditions. [[status-ledger]] carries the native
backend at IMPLEMENTED with its own caveat that the benchmark run behind it
predates the migration and has not been re-run.

### The control box

Measured 2026-09-08 by `lscpu` and `/proc/cpuinfo`, and the host behind every
self-hosted figure below: `Intel(R) Xeon(R) Processor`, 12 vCPU, reported
`cpu MHz` 2496.000 with `constant_tsc`, `MemTotal` 4,033,056 kB and `SwapTotal`
0, L1d 32 KiB and L2 2 MiB per core, L3 12 MiB shared. The flag list carries
`aes`, `sha_ni` and `avx2`, and the backend emits none of the three: the `Op`
sum at `lib/prelude/prelude.chiral` has fifteen constructors and every one is a
scalar 64-bit operation.

### What is measured

| what | figure | date | backend behind it |
|---|---|---|---|
| three micro-kernels against `gcc -O2` | run 10: arith 1.39x, bytesum 6.3x, states 7.6x. The published band is ~1.4x on compute and 5 to 8x on memory and branch work | 2026-08-02 | Python-hosted, `scaffold/chirality/native.py`, absent from this tree |
| ChaCha20 keystream | 12.9 to 14.0 MB/s at quiet load, 178 to 194 cycles per byte by conversion, 5,776 B allocated per 64-byte block, 3.1 to 3.4x its own non-allocating in-tree control | 2026-09-07 | self-hosted, `bin/chirality-bin` sha256 prefix `7d971a30c0bfda52fc2d952b` |
| `chacha-xor`, the stream path | 1.8 MB/s at 16 KiB falling to 0.41 MB/s at 128 KiB, allocation per doubling growing 2.87x, 3.21x, 3.51x toward the 4x a quadratic gives | 2026-09-07 | the same binary |
| `prose-lint` against mawk | 15.1x slower, band 7.8x to 18.5x, 1.11 GB allocated to scan 609,872 B, OOM-killed at the default scope | 2026-09-02 | self-hosted, `bin/chirality-bin` sha256 prefix `ac8de63e5687fad4` |
| the optimizer itself | seventeen transformations and five gates from text to bytes. `dead`, `optimize`, `specialize`, `emit-truthful` and `emit-param` are compiled in and never called | 2026-09-07 | self-hosted, the same binary as the crypto row |
| the candidate surface | 221 candidates over seven pinned catalogues: 213 A, 7 C, 1 A+C, zero B. About 45 of them want one of nine enablers | listed 2026-09-07, annotated 2026-09-08 | a reading of the self-hosted tree |

### Two numbers, both true

The published band says ~1.4x of `gcc -O2` on compute. The crypto kernel
measures 3.1 to 3.4x of its own non-allocating in-tree control, and its per-byte
time is what 110 to 120 ops per byte would cost against a static count of 35.
Neither reading covers the other. The band came from three micro-kernels that
are latency-bound or memory-bound, none of which constructs a product inside a
loop, and it came from a backend this tree evicted.
[[benchmarks/crypto-kernel-allocation]] states in its own §"Against the tree's
measured bands" that its 3.1 to 3.4x cannot be compared to those figures,
because its denominator is an in-tree chirality kernel where theirs is
`gcc -O2`, and that a `gcc -O2` ChaCha20 run was never made. **So the distance
between this compiler's output and optimized scalar C on allocation-heavy code
stands unmeasured**, and any single number summarizing it would be invented.

## Honest limits

- **No target exists anywhere in this tree.** The 2026-09-01 ruling at
  `docs/benchmarks/README.md:29` makes the wall clock a recorded number that
  sets no bar, and nothing else states a threshold. Two thresholds are owed by
  name: the ratio in condition 1 and the budget in condition 4. Until the author
  states them, nothing in this goal can fail, and a number picked here would be
  fabrication dressed as a requirement.
- **The published band belongs to a backend that no longer exists.**
  [[implementation/optimizer-inventory]] §3 records `optimize.py`,
  `scaffold/bench/`, `test_regdisc.py` and the `NativeBackend(discipline=…)`
  selector as all absent, and the resumption entry point `rd-packed` as zero
  code written with its design document citing the old tree's paths. Quoting
  1.4x for the compiler that ships today would be quoting a measurement of
  something else.
- **No cycle counts, and no absolute times.** `perf` and `perf_event_open` are
  blocked in this microVM, owed on bare metal since 2026-08-02. Cycles per byte
  is wall clock divided by the clock the guest reports, so turbo, throttling and
  the host's own scheduling sit outside it. Absolute nanoseconds moved 44% to
  82% between two same-day runs on this class of host, so ratios and bands are
  the only quotable form.
- **One instrument, and it counts bytes.** `heap-allocated`
  (`lib/ports/process.port`) reads the arena's bump cursor, which is exact for
  total bytes ever allocated and silent about stack traffic, register pressure
  and spill. [[implementation/optimizer-inventory]] §4 records that no
  wall-clock or instruction-count instrument runs inside
  `tools/test/run-tests.sh`. Four of the five conditions above would need an
  instrument this tree does not have.
- **The tree's own word for cost has no settled meaning.** `E38`, the graded
  cost semiring, sits at DESIGNED in `docs/elements/catalog.md` and nothing
  consumes it. [[benchmarks/OPT-CANDIDATES-2026-09]] §2 records `B11` as the one
  row its splitting law cuts, because whether the cost model predicts real time
  or counts an abstract cost stays open until the model is stated.
- **An optimization already in this tree is excluded by measurement.** `dead`,
  the DCE pass, is compiled into the shipping binary and left out of
  `opt-tfns`, because wiring it whole makes the compiler miscompile itself at
  293 passed and 98 failed, recorded at `lib/lowering/compile-back.chiral`. A
  pass being available here does not make it safe to turn on, so the parked menu
  cannot be read as free.
- **The candidate list ranks nothing.** 221 rows, no estimate of what any row is
  worth, no order, and several rows attacking the same measured cells from four
  catalogue traditions. Its own closing section says so. A triage and an
  evaluation stage both stand between that list and any scheduled work.
- **The language names no operation that a current ISA has and this sum lacks.**
  All 38 bucket C rows read `absent`. `op-mulhi` is in the closed sum and
  reachable from nothing a program can write, `x-imul-rcx-1op`
  (`lib/lowering/x64/mach.chiral:319`) encodes the signed one-operand `imul`,
  and no unsigned multiply path exists anywhere in the backend. So the fifteenth
  constructor is both unwritable and the wrong sign for what `C17` asks. What
  would close it is a design stage that decides the widening multiply's shape,
  and this goal decides none of it: unsigned alone, signed and unsigned as two
  constructors, and one operation defining two slots are three live shapes, and
  the third depends on the single-slot return `B15` records.
- **Four of six conditions are unopened.** [[arcs/emitted-speed-arc]] took
  conditions 1 and 2 on 2026-09-08, which are the two the 2026-09-07
  measurements make actionable. Conditions 3, 4, 5 and 6 hold no arc, and the
  Arcs section above records the reason for each.
