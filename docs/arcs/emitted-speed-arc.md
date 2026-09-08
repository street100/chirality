---
node: arc-emitted-speed
layer: navigation
related: [arcs/README, goals/emitted-speed, arcs/memory-discipline-arc, arcs/crypto-primitives-arc, benchmarks/crypto-kernel-allocation, benchmarks/OPT-CANDIDATES-2026-09, benchmarks/OPTIMIZATIONS-TODO, implementation/optimizer-inventory, banks/INDEX, banks/memory, banks/erasure, working-discipline, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-08
---

# Arc: what the emitted code costs

- goals: [[goals/emitted-speed]], condition 2: "**Building a product stops
  forcing an allocation.**", condition 1: "**The shipping compiler carries a
  cost figure against a control outside the tree.**" and condition 6: "**Every
  operation the machine offers is named or refused, and every name the `Op` sum
  carries reaches the surface.**"
- reserved element block: **none**. Rows carry arc-local ids `X1` and up per
  [[decisions/decision-work-ids]], where `X` is the emitted artifact's cost.
  The letter is free tree-wide: the twenty-four standing arcs spell `A`, `B`,
  `BA`, `C`, `D`, `E`, `F`, `G`, `H`, `J`, `K`, `M`, `N`, `O`, `P`, `Q`, `S`,
  `T`, `V` and `W`. A band is advisory and an arc without one mints the next
  free number tree-wide.
- build-state authority: [[status-ledger]]

Opened 2026-09-08 on a goal stated the same day. Five artifacts committed on
2026-09-07 and 2026-09-08 are the evidence this arc rests on:
[[implementation/optimizer-inventory]] (`43c7fab`, what the compiler already
does), [[benchmarks/crypto-kernel-allocation]] (`ea31370`, what one kernel
costs), [[benchmarks/OPT-CANDIDATES-2026-09]] (`6188eaa`, 221 candidates, and
`8a865cf`, their typeability), and [[goals/emitted-speed]] itself (`30fec84`).

**Amended 2026-09-08 to take condition 6 as well.** The arc excluded that
condition when it opened, on a reading of `C33` that a measurement of the
backend taken the same day voids. §"Why this roster is nine rows and not 221"
carries the measurement and what it corrected.

## Why this arc exists

Condition 2 is measured and refuted today. Ten double rounds of ChaCha20
allocate **4,560 B in 90 arena cells per 64-byte block**, the whole block
function allocates **5,776 B**, and the same ARX arithmetic carrying its four
lanes as parameters allocates **zero** and runs **3.1 to 3.4x faster** at quiet
load ([[benchmarks/crypto-kernel-allocation]], 2026-09-07, self-hosted,
`bin/chirality-bin` sha256 prefix `7d971a30c0bfda52fc2d952b`). What it takes to
hold is a change of representation. `is-enum`
(`lib/lowering/tal/erase.chiral:75`) boxes any fielded constructor, `ti-cona`
(`lib/lowering/tal/ir.chiral:23`) is the only way to write a cell's fields and
always allocates, and `ti-ret` (`:43`) carries one `src`, so a four-field value
returned from a function has one slot to travel in and a cell is the only thing
that fits.

Condition 1 is unmeasurable today for a different reason. Every `gcc` ratio in
this tree was taken on `scaffold/chirality/native.py`, and `scaffold/` is absent
from this tree ([[implementation/optimizer-inventory]] §3 and §4). What it takes
to hold is one measurement: a control outside this tree, run against the
shipping binary, written down with its host block, its date and the backend
behind it. ⚑ **The ratio that figure should reach is OWED**, and this arc
invents none. [[goals/emitted-speed]] states why in its own Honest limits, and
requirement 3 below carries the gap instead of a number.

Condition 6 is unobserved by any instrument this tree runs. Three sets carry it.
The `Op` sum (`lib/prelude/prelude.chiral:36-39`) declares fifteen constructors,
the extern block (`:58-71`) binds fourteen, and `op-bytes`
(`lib/lowering/x64/mach.chiral:351-385`) encodes fifteen. `op-mulhi` is the one
difference, and the difference is worse than a missing name. `:373` reaches it
through `x-imul-rcx-1op` (`:319`, `48 F7 E9`), the one-operand **signed**
`imul`, and a grep for the unsigned `F7 /4` form over `lib/lowering/x64/`
returns nothing. The backend therefore holds a signed high-word multiply and
reaches no unsigned one, and the two answers differ whenever either operand's
top bit is set. What it takes to hold is a shape for the widening multiply, a
name for the rotate the measured kernel spends four operations emulating, and a
check that keeps the three sets agreeing once both land.

**The boundary against [[arcs/memory-discipline-arc]].** That arc's `M3`
(`E83`, alloc-reuse) and `M4` (`E84`, alloc-dps) attack the same cells under
[[goals/local-ai]] condition 1, against its requirement 1, whose observable is
peak RSS on the default-scope projection. **The line is the `Alloc` seam.**
`E81` gave allocation a policy dimension over the `Mach` record, and
`emit-instr`'s `ti-cona` arm calls `alo-cell` on whichever policy is bound
(`lib/lowering/mach/emit-core.chiral:151`). A policy decides how a cell is
obtained: reuse writes over one that exists, destination-passing has the caller
supply it. Every policy still emits an allocation site, still stores a tag,
still reads the fields back out. **This arc changes whether `ti-cona` is emitted
at all**, which is decided above that seam by `is-enum` and by the return form.
So `memory-discipline` owns residency and this arc owns construction, and
neither is reachable from the other's rows. ⚑ **If `M3` lands first the two
measurements interact.** A reused cell bumps nothing, so the `sD` delta would
fall without reaching zero, and requirement 1's second observable is what keeps
the halves apart: the ELF site count, which no allocation policy moves.

## What the tree already holds

Measured 2026-09-08 against the artifacts above. Two banks carry the concepts
this arc touches. [[banks/memory]] holds the arena as shard 1 and
space-as-a-grade as shard 8, `E38`, settled on paper with nothing consuming it.
[[banks/erasure]] holds representation-shape erasure as shard E and the uniform
erased word as shard F, both built. **Neither bank holds a shard for an unboxed
product**, which is the gap this arc opens on. A grep of every bank
[[banks/INDEX]] lists for `op-mulhi`, for the `Op` sum and for the primitive set
returns nothing, so **the machine's operation set holds no shard either** and
condition 6 opens on a second absence.

| group | what exists today | where | rung |
|---|---|---|---|
| representation | `is-enum`: every constructor nullary gives an immediate tag, and any fielded constructor boxes the whole type. `Q4` and `St` are both single-constructor | `lib/lowering/tal/erase.chiral:75`, against `lib/crypto/chacha.chiral:42-45,48` | IMPLEMENTED |
| representation | `ti-cona`, the only way to write a cell's fields | `lib/lowering/tal/ir.chiral:23` | IMPLEMENTED |
| representation | the allocation itself: `emit-instr`'s `ti-cona` arm calls `alo-cell` on the bound `Alloc`, and `x-galo` sizes the cell `8 * (1 + fields)`, so a `Q4` is 40 B and an `St` is 136 B | `lib/lowering/mach/emit-core.chiral:151`, `lib/lowering/x64/mach.chiral:509,511` | IMPLEMENTED |
| representation | `tt-word`, the uniform erased word, representation-compatible with every one-word type | `lib/lowering/tal/ssa.chiral:21-22`, matched by `tal-ty=?` at `lib/lowering/tal/check.chiral:68-70` | built, [[banks/erasure]] shard F |
| boundary | the single-slot return: `ti-ret` carries one `src` and `TalSig` one `ret` | `lib/lowering/tal/ir.chiral:43`, `lib/lowering/tal/ssa.chiral:44` | IMPLEMENTED |
| boundary | the hand-written proof that the same arithmetic allocates nothing when the four lanes travel as parameters across a self tail call: `sB`, `qround`'s body verbatim, 0 B over 8,000,000 quarter rounds | `tools/bench/crypto-kernel.sh`, against `lib/crypto/chacha.chiral:50-56` | measured 2026-09-07 |
| operations | the `Op` sum: fifteen constructors, closed, matched exhaustively by every consumer, and every one a scalar 64-bit operation | `lib/prelude/prelude.chiral:36-39` | IMPLEMENTED |
| operations | the extern block, binding fourteen of the fifteen at the surface. `mulhi` is the one with no `(extern …)` line, so no program can write it | `lib/prelude/prelude.chiral:58-71` | IMPLEMENTED |
| operations | everything below the surface already accepting `mulhi`: `op-name` gives the string, `op-parse` takes it back, `op-bytes` encodes it, the immediate form dispatches it, and `x64-clobbers` has its entry | `lib/prelude/prelude.chiral:49`, `lib/lowering/tal/erase.chiral:100`, `lib/lowering/x64/mach.chiral:373,1025,1445` | IMPLEMENTED |
| operations | what `op-mulhi` actually emits: `x-imul-rcx-1op`, the bytes `48 F7 E9`, the one-operand **signed** `imul`. A grep over `lib/lowering/x64/` for the unsigned `F7 /4` form returns nothing | `lib/lowering/x64/mach.chiral:319`, commented at `:313` as the optimizer's magic-division prim | IMPLEMENTED, and it is the wrong sign for what `C17` asks |
| operations | the rotate as four operations: `rotl32` is `(band (bor (shl x n) (shr x (- 32 n))) M32)`, rotating at 32 bits inside a 64-bit lane, and `qround` is `4 x (add32=2, bxor=1, rotl32=4)` = 28 ops | `lib/crypto/chacha.chiral:24-25`, counted at [[benchmarks/crypto-kernel-allocation]] §3 | measured 2026-09-07 |
| operations | the one built consumer that routed around the gap: Poly1305 sizes its limbs at 26 bits so signed `I64` holds every intermediate and the comment records "no mulhi" as the consequence | `lib/crypto/poly1305.chiral:11-14`, five 26-bit limbs at `:45-57` | built, gated |
| operations | `ti-prim` binary, so a unary operation has no erased representation and `erase-prim` refuses any `Op` without exactly two operands. A rotate is binary and wants none of that, which is why `B6` sits under `C3` to `C6` and under neither of this arc's operation rows | `lib/lowering/tal/ir.chiral:21`, refused at `lib/lowering/tal/erase.chiral:153-157` | IMPLEMENTED |
| pass | `fold`, the one transformation above the erasure seam and the only member of `opt-tfns`. It reads no type fact | `fold` in `lib/lowering/upper/optimize.chiral`, wired at `opt-tfns` in `lib/lowering/compile-back.chiral` | IMPLEMENTED |
| pass | the certificate seam left the shipping path today. `re-check` and the `Checked` sum moved out of `lib/lowering/upper/optimize.chiral` by the author's `PRB-70` ruling of 2026-09-08, and `opt-tfns` adopts `(fold t)` with no verdict to consult | `opt-tfns` in `lib/lowering/compile-back.chiral`, committed at `b613a8f` | IMPLEMENTED, and changed today. See the resume state |
| pass | `ck-fn` judging every TFn the shipping compiler emits, from outside the compiler closure | `lib/lowering/tal/check.chiral:290`, run by `prog/optimizer-census.prog` | built, run by hand |
| pass | `specialize-singletons`, the one monomorphizer in the tree | `lib/lowering/upper/specialize-singleton.chiral:229` | IMPLEMENTED |
| pass | `specialize-raw` and the `rmap-*` SSA renamer, the pregen primitive | `lib/lowering/upper/optimize.chiral` | written, reached by nothing |
| grading | the `dead` exclusion: wired whole the compiler miscompiles itself at `293 passed, 98 failed`, `fold` alone grades `42 passed, 0 failed` and `dead` alone `33 passed, 9 failed`. The measurement was taken by editing the pipeline | the header comment above `opt-tfns`, `lib/lowering/compile-back.chiral` | recorded measurement |
| grading | `tools/test/opt-census.sh` over `prog/optimizer-census.prog`: four rows and four mutants since `38ecdba`, pinning `defs=1518 skipped=10` and `tfns=1548 ok=1517 err=31`. Two rows and two mutants asserted a wiring that was cut the same day | `tools/test/opt-census.sh` | built, unregistered. It takes no phase number and is run by hand |
| grading | three emit entry points, one reached | `lib/lowering/x64/emit.chiral:8,11,14` | `emit` live, `emit-truthful` and `emit-param` built with no caller |
| control | `tools/bench/crypto-kernel.sh`, four modes, over `heap-allocated`, which reads `heapptr - heapbase` and is exact for total bytes ever allocated | `tools/bench/crypto-kernel.sh`, `lib/ports/process.port:36` | built 2026-09-07 |
| control | the harness behind every `gcc` ratio this tree quotes | `scaffold/bench/`, absent | evicted with the Python backend |
| control | the memory machine: every virtual register in a stack slot, `slotd` and `frame` arithmetic, and no register allocator | `lib/lowering/x64/mach.chiral:7-9,45,53` | IMPLEMENTED, and it is why a de-boxed product's fields land in slots |

Two absences hold the same weight as the rows above. There is **no wall-clock or
instruction-count instrument inside `tools/test/run-tests.sh`**, whose wall clock
is printed and sets no bar under the 2026-09-01 ruling at
`docs/benchmarks/README.md:29`. And `perf_event_open` is unavailable in this
microVM, which [[benchmarks/OPT-CANDIDATES-2026-09]] carries as `B13`, the one
category-C floor on its list that binds.

## What is missing, and its structure

Six groups, in dependency order.

| group | owns |
|---|---|
| `representation` | whether a single-constructor product is a cell, and where its fields live when it is not |
| `boundary` | how such a product crosses a call, given one return slot |
| `operations` | which of the machine's operations the language names, what shape a name takes when the machine's answer does not fit one slot, and what keeps the three in-tree sets agreeing |
| `pass` | the transformation that removes the construction, and where it sits against the erasure seam |
| `grading` | one transformation measured alone against the self-hosting fixpoint |
| `control` | a figure against something outside this tree, and the residual inside it |

### The edges that run against the order

Four, and an ordering with no back-edges reads as a schedule.

- **`grading` runs backward into `pass`.** `dead` is compiled into the shipping
  binary and left out of `opt-tfns` because wiring it whole makes the compiler
  miscompile itself, and that measurement was taken by editing the pipeline.
  A new transformation with no switch repeats the same session. The switch is a
  precondition for shipping the pass, and the group order puts it last.
- **`control` runs backward into every other group.** The outside-control figure
  has to be taken **before** the pass lands. Taken afterward it is one number
  spanning two changes and neither half can be read out of it. `X5` is therefore
  last in the dependency order and first in time.
- **`boundary` runs backward into `representation`.** The return form decides
  whether a transparent product is representable at all, so `X2` constrains `X1`
  instead of following it.
- **`operations` runs backward into `boundary`.** `C38` wants one operation
  defining two slots and names `B15`, the single-slot return, as what it depends
  on. `X2` is the row that decides what a function may return. So `X7` cannot
  settle before `X2` has answered, and the two rows are settling one thing from
  opposite ends. That edge is why condition 6 sits in this arc.

### Why this roster is nine rows and not 221

[[benchmarks/OPT-CANDIDATES-2026-09]] lists 221 candidates over seven pinned
catalogues and says in its own closing section that it ranks nothing, estimates
nothing and orders nothing, with a triage and an evaluation stage standing
between it and any scheduled work. This arc **selects from that list**, and the
selection rule is [[working-discipline]]'s: a row is scheduled iff building it
requires choosing between shapes the codebase does not already settle.

Two examples mark the line. `C13`, an unsigned less-than, settles nothing: the
sum already carries the signed `op-lti` with its encoding at
`lib/lowering/x64/mach.chiral:369`, so the unsigned row copies a shape the tree
has into a new constructor and edits the four places bucket C's own preamble
names. That is a finishing job and it is consumed as ordinary work. `B3`, a
location vocabulary, is genuine design: it decides whether the IR can name a
place other than a slot, and nothing in the tree settles it.

⚑ **This arc used `C33` as the finishing-job example when it opened, and that
reading was measured wrong.** It said a surface binding for `mulhi` was one
`extern` the surface never got, because everything below the surface already
accepts the string. Measured 2026-09-08: `x-imul-rcx-1op`
(`lib/lowering/x64/mach.chiral:319`) is the bytes `48 F7 E9`, the one-operand
**signed** `imul`, `:373` is where `op-mulhi` reaches it, and grep finds no
unsigned `F7 /4` form anywhere under `lib/lowering/x64/`. Binding what is there
therefore ships a primitive whose high word differs from the unsigned one
whenever either operand's top bit is set, and the unsigned high word is what
`C17` asks for. `C33` requires choosing between shapes the codebase does not
settle, so on this arc's own test it is a roster row. It is `X7`, and the
exclusion of bucket C that rested on the old reading is void.

Three families the candidate list holds are deliberately **out of this arc**.
`B4`'s wider family beyond the measured cells, the Bytes-path tail (`C27`,
`C28`, `D11`, the 944 B of `pack-u32` and `bcat` in `chacha-block`) and the
whole enabler table serve condition 3, which stays unopened. `C27` and `C28`
are bucket C rows, so requirement 6 below counts them as scheduled by name
under a condition this arc does not take. That disposes of them and leaves them
unnamed.
⚑ **`rd-packed` wants a change nobody had recorded.**
[[benchmarks/OPTIMIZATIONS-TODO]] names it the campaign's resumption entry point
with its certificate format ratified and zero code written, and the inventory
establishes that the IR has no location vocabulary, so `B19` depends on `B3`.
That belongs to condition 3 and is written here so the arc that opens it starts
from the dependency instead of rediscovering it.

## REQUIREMENTS

1. **The round subject allocates nothing.** Observed:
   `tools/bench/crypto-kernel.sh alloc` reporting a **zero delta** for `sD`'s ten
   double rounds, against the 4,560 B per 64-byte block measured 2026-09-07
   ([[benchmarks/crypto-kernel-allocation]] §1a), **and**
   `tools/bench/crypto-kernel.sh sites` finding no 40-byte `Q4` allocation site
   in the block subject's ELF, where it counted one on that date. The second
   half is what distinguishes this from a residency change.
2. **Every transformation this arc adds is graded alone before it ships, and the
   compiler still reproduces itself.** Observed: a grade for the pass by itself
   in the form the header above `opt-tfns` already carries for `dead` and
   `fold`, taken without editing the pipeline; `tools/test/run-tests.sh` green;
   `tools/test/opt-census.sh` re-pinned; and the BUILD RULE's fixpoint
   converging by `C4`.
3. **The shipping compiler carries a figure against a control outside this
   tree.** Observed: one doc under `docs/benchmarks/` whose figures name
   `bin/chirality-bin` by sha256, carry a host block and a date, name the
   backend behind them, and quote a band against a named outside control.
   ⚑ **The ratio it should reach is OWED and this requirement states none.** The
   2026-08-02 band measured a backend absent from this tree, so it is a record
   of something else and sets no target.
4. **What the change bought is measured on this tree's own terms.** Observed: a
   dated re-run of `tools/bench/crypto-kernel.sh` on the same host block with
   the residual attributed, the counter separating `x-alo` traffic from `x-galo`
   traffic, and the stack-slot traffic the de-boxed lanes take. Both are named
   in [[benchmarks/crypto-kernel-allocation]] under "What this does not
   establish", and the memory machine puts every virtual register in a slot, so
   removing a cell moves cost somewhere nothing counts today.
5. **The three in-tree operation sets agree, and a gate checks the agreement.**
   Observed: one check over the `Op` sum (`lib/prelude/prelude.chiral:36-39`),
   the extern block (`:58-71`) and `op-bytes`
   (`lib/lowering/x64/mach.chiral:351-385`) that fails when they disagree
   constructor for constructor, registered in `tools/test/run-tests.sh` under a
   phase number so it runs without anyone remembering to run it. It fails today
   on `op-mulhi`, which is the one difference the three sets hold, and a check
   that cannot fail on the difference already present measures nothing.
6. **The operations the measured workload asks for carry a name a program can
   write, and every other bucket C row carries a disposition.** Observed in two
   halves. First, a rotate and a widening multiply reachable from surface
   source, and `qround` re-counted against the 28 operations
   [[benchmarks/crypto-kernel-allocation]] §3 records, with the residue against
   the 12 [[goals/emitted-speed]] condition 6 computes attributed to the 32-bit
   lane `C32` names, which this arc does not schedule. Second, every one of the
   38 bucket C rows reading as a named operation, as a row scheduled by name
   under another condition, or as a refusal citing the baseline.
   ⚑ **The baseline is OWED and this requirement invents none.** `C10` and `C11`
   record BMI2 availability as a target question this tree has not asked and
   `C34` records that no document states what a shift by 64 or more means, so a
   refusal has nothing to cite until `docs/decisions/` names the instruction set
   the emitted code may assume.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `emitted-speed/X1` | the transparent single-constructor product: whether a one-constructor data type is a cell at all, what `is-enum` (`lib/lowering/tal/erase.chiral:75`) decides in place of boxing every fielded constructor, and what carries the fields when the value stays unboxed | representation | decision | new | 1 | open | `unminted` |
| `emitted-speed/X2` | a product crossing a call with no cell: the multi-value return against a worker-wrapper that keeps the product inside one function, given that `ti-ret` carries one `src` and `TalSig` one `ret` | boundary | primitive | new | 1 | open | `unminted` |
| `emitted-speed/X3` | the transformation itself: which of scalar replacement, constructed-product-result and argument flattening this is, whether they are one candidate or four, and whether it sits above the erasure seam where `fold` is the only pass today | pass | law | new | 1, 2 | open | `unminted` |
| `emitted-speed/X4` | the per-pass switch: one transformation turned on alone and graded against the self-hosting fixpoint without editing the pipeline, which is how `dead`'s `33 passed, 9 failed` was taken | grading | tool | new | 2 | open | `unminted` |
| `emitted-speed/X5` | the outside control: a `gcc -O2` figure for one real kernel measured against `bin/chirality-bin`, under the host-block, honest-spread and anti-fold conventions `docs/benchmarks/README.md` states. The harness behind every earlier ratio, `scaffold/bench/`, was evicted with the Python backend on 2026-08-31 | control | tool | new | 3 | open | `unminted` |
| `emitted-speed/X6` | the residual instrument: `x-alo` traffic separated from `x-galo` traffic in the counter, and the stack-slot traffic a de-boxed product moves, so the claim about what the cells cost is measured | control | tool | new | 4 | open | `unminted` |
| `emitted-speed/X7` | the widening multiply's shape, which is `C33`, `C17` and `C38` as one decision because they cannot be settled apart: the tree's high word is signed (`lib/lowering/x64/mach.chiral:319`) where the workload wants unsigned, and `C38`'s two-slot form is what `B15`'s single-slot return stands against. Unsigned alone, signed and unsigned as two constructors, and one operation defining two slots are the live shapes, and this row names the decision without taking it | operations | decision | new | 5, 6 | specced | `E189` |
| `emitted-speed/X8` | the rotate's name and its width: `C1` and `C2` name a left and a right rotate and the sum names neither, `C35` recognizes the idiom in the emitter and names no operation, and `rotl32` (`lib/crypto/chacha.chiral:24-25`) rotates at 32 bits inside a 64-bit lane, so what width a named rotate carries is open against `C32` and `B8` | operations | primitive | new | 6 | open | `unminted` |
| `emitted-speed/X9` | the three-set agreement gate: one check reading the `Op` sum, the extern block and `op-bytes` and failing when they disagree, and whether it reads source text the way `tools/ledger-lint` does or the compiler's own structures the way `prog/optimizer-census.prog` does, given that `tools/test/opt-census.sh` is built and unregistered because it takes no phase number | operations | tool | new | 5 | open | `unminted` |

### Coverage

Every requirement is named by at least one row: 1 by `X1`, `X2` and `X3`; 2 by
`X3` and `X4`; 3 by `X5`; 4 by `X6`; 5 by `X7` and `X9`; 6 by `X7` and `X8`.
Every row names at least one requirement.

Every `origin` is `new`, and §3 defends each. `X1` and `X2`: the tree boxes
every fielded constructor and returns one slot, and no shard anywhere holds an
unboxed product. `X3`: `fold` is the only transformation above the erasure seam
and reads no type fact, and `specialize-raw`, the nearest built
machinery, has no call site and does a different thing. `X4`: the `dead`
measurement was taken by editing the pipeline, and `emit-truthful` and
`emit-param` show what a built-and-uncalled alternative entry point buys, which
is nothing without a selector. `X5`: `scaffold/bench/` is absent and
`tools/bench/crypto-kernel.sh` measures against an in-tree control only. `X6`:
the counter reads one number for both allocators and no instrument counts slot
traffic. `X7`: the fifteenth constructor exists and is signed where `C17` asks
unsigned, so binding what is there ships a different high word, and the shape
that replaces it is unsettled between three candidates. `X8`: the sum names
neither rotate, and the tree's one rotate is four operations at a width the sum
does not carry. `X9`: the tree holds two checker idioms and no check over these
three sets, and its nearest built checker is unregistered.

**Requirement 6's second half is reached without a row of its own.** `X7` and
`X8` take the bucket C rows that require a shape. Of the remainder, `C27` and
`C28` are scheduled by name under condition 3 in §"What is missing", `C35` to
`C37` are the emitter halves of `C1`, `C21` and `C32` and dispose with whatever
names those under [[working-discipline]] section "A capability the substrate
lacks is a finding", and what is left is a disposition column over documented
rows, which is doc-tier work `doc-audit` reaches with no element and no design.
⚑ **The refusals among them are gated on the OWED baseline**, so requirement 6
is reachable and this arc closes it no earlier than that author call.

**Three conditions of this goal are taken and three are left.** Condition 6
joined on 2026-09-08, and it joined this arc because its one genuine design
question and this arc's `X2` settle the same thing. `C38` wants an operation
defining two slots and names `B15`, the single-slot return, as its dependency,
and `X2` is the row that decides what a function may return. A second arc taking
condition 6 would own that decision twice, which is the collision
[[arcs/README]] records from the day two sessions minted `E173` independently.
Condition 3, the
nine enablers, is the whole optimizer program: nine capabilities that about 45
rows specify, over a list its own author says needs a triage and an evaluation
stage first. An arc taking it would be the candidate list transcribed. Condition 4
cannot be observed at all, because its budget is OWED and its observable is a
gate row that fails when the tool exceeds it, which is a gate that cannot fail
under `docs/decisions/decision-scope.md`. Condition 5 is doc-tier work that
`doc-audit` and `ledger-lint` reach with no element and no design. Requirement 3
here obliges this arc's own figures to name their backend and **does not close
condition 5**, which asks it of every doc under `docs/benchmarks/`.

## Resume state

Opened 2026-09-08 with 6 rows and 4 requirements. Amended the same day to take
condition 6, at **9 rows and 6 requirements**, none designed.

**Next, in order.** `X5` first, because the back-edge says so: the
outside-control figure has to exist before the pass lands or the two halves
confound each other. Then `X1`, because `X2` and `X3` both rest on what a
single-constructor product is. `X9` stands outside that chain and fails against
the tree as it is, so it can run at any point. `X7` waits on `X2`, which is the
`operations` back-edge read from the other end. `X8` depends on no row here.
Every row runs `element-design` off
`python3 tools/pack/pack.py emitted-speed/X<n>`.

⚑ **Two of this arc's five sources went stale the day it opened, and this run
corrected neither.** The `chk-ok` guard left the shipping call site by the
author's `PRB-70` ruling of 2026-09-08, landing at `b613a8f` and `38ecdba`, so
`lowering/tal/check` is outside the compiler closure and `opt-tfns` adopts
`(fold t)` with nothing to consult. `docs/implementation/optimizer-inventory.md`
(`43c7fab`) describes the guard as shipping, in its §1 pass table and in its §3
row reading "preserve-check as the transform license: ported and live". The
stage-3 typeability classification in
`docs/benchmarks/OPT-CANDIDATES-2026-09.md` (`8a865cf`) rests on the same fact
in its bucket F-vi. **Both owe a `revisit`**, and this arc cites them as they
stood on their commit dates. `X3` and `X4` sit on the seam that moved, so a
session picking either up reads the code before it reads those two documents.

⚑ **Two thresholds are OWED and no row here may invent one.** Condition 1's
target ratio and condition 4's budget, both stated as owed in
[[goals/emitted-speed]]. `records/author-calls.md` holds no row for either, and
this run was scoped to two files and could not open one, so **a row there is
owed**. `crypto-primitives/K13` owes the same thing on the crypto side: the
target declaration and the cost model that gives `best` a meaning. The standing
2026-09-01 ruling at `docs/benchmarks/README.md:29` is the reason there is
nothing to inherit: it made the wall clock a recorded number that sets no bar.

⚑ **Condition 6 brings a third owed author call, and it is a disposal instead
of a number.** Which instruction set the emitted code may assume. `C10` and
`C11` record BMI2 availability as a target question this tree has not asked,
`C34` records that no document states what a shift by 64 or more means, and the
control box carries `bmi1`, `bmi2`, `adx` and `popcnt` in `/proc/cpuinfo`, which
is one host and settles no baseline. `records/author-calls.md` holds no row for
it, so **a row there is owed** beside the two above. `X7`, `X8` and `X9` all run
without it. Every refusal among the remaining bucket C rows waits on it.

⚑ **`X4` inherits a standing author decision.**
[[benchmarks/OPTIMIZATIONS-TODO]] lists the `(regs …)` profile clause as open
until two profiles actually diverge. A per-pass switch is the same question in a
different place, and `X4`'s design says whether it is one fork or two.

**The measurement this arc exists to move**, all self-hosted on
`bin/chirality-bin` sha256 prefix `7d971a30c0bfda52fc2d952b`, taken 2026-09-07
on the control box [[goals/emitted-speed]] records: **4,560 B per 64-byte block
in the rounds, 5,776 B in the whole block function, 12.9 to 14.0 MB/s at quiet
load, 178 to 194 cycles per byte by conversion from wall clock with no cycle
counter read, and 3.1 to 3.4x its own non-allocating in-tree control.** The
static count is 35 ops per byte and the measured per-byte time is what 110 to
120 would cost. ⚑ **None of those figures is comparable to the ~1.4x band in
[[benchmarks/language-performance]]**, which measured
`scaffold/chirality/native.py` on 2026-08-02 and belongs to a backend absent
from this tree.
