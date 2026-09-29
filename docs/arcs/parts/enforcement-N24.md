---
row: enforcement/N24
arc: enforcement
title: `fold`'s rules checked once, each arm of `fold-prim` and `fold-cmp` against the instruction the backend emits and against the definition, over a boundary operand table, with a mutant per arm the table convicts
kind: tool
origin: new
req: 7
status: draft
updated: 2026-09-29
---

# enforcement/N24: `fold`'s rules checked once

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** every arm of `fold-prim` (`+ - * / %`) and `fold-cmp`
  (`=i <i <=i`) gives, on every pair drawn from a boundary operand table, the
  value the shipped binary computes for the same operation left unfolded, and
  the value the operation's definition gives. A gate derives this on each run,
  and a mutated arm reddens it.
- **Serves:** requirement 7 of [[arcs/enforcement-arc]]
  (`docs/arcs/enforcement-arc.md:471`), "**Every rewrite the optimizer adopts
  carries evidence that its output means what its input meant, and a rewrite
  without that evidence is refused.**" The requirement names this row as its
  second half. `enforcement/N23` is the first half.
- **Goal:** [[goals/enforcement]], condition 2
  (`docs/goals/enforcement.md:29-31`).

## 2. What the tree holds

Measured 2026-09-29 at `ef3b1ba`, working tree as the author left it. Every
`file:line` below was opened this run.

- **Bank:** [[banks/verification]]. Shard 7 (`docs/banks/verification.md:260-263`)
  ranks an expectation's source: external, then an independent in-house
  reference, then meaning-of-the-form hand-derived, then an
  implementation-derived golden, admissible only as a labelled regression net.
  That ranking decides this row's reference (§4 Axis 1). The status ledger
  already names the shard this row checks and says its check was cut:
  `docs/definitions/status-ledger.md:164`, "Floor agreement of the arithmetic
  prims (by collapse)", records that `fold-prim`/`fold-cmp` and `eval-prim` are
  "separate dispatch chains over one set of prims" and that the Python tests
  "which pinned the agreement, are CUT".
- **Settled texts.** FD-55 in [[records/findings]], §4 "CHECKED OPTIMIZATION:
  PROVE ONCE, OR VALIDATE EVERY RUN", its table row "prove the rewrite rule
  once | Alive" and the paragraph "What it owes in chirality", which closes
  "Validating a rewrite rule once at its definition is Alive's route and fits
  `fold`, whose arms are local algebraic identities over `I64`." Cited by id,
  since its line number differs between `HEAD` and the working tree.

| what exists | where | rung | reached by |
|---|---|---|---|
| `fold-prim`: five arms, each one host operator; `/` and `%` refuse `b = 0` | `lib/lowering/upper/optimize.chiral:60-67`, guards `:65-66` | IMPLEMENTED | `fold-prim-instr` `:89` |
| `fold-cmp`: three arms, each a host comparison rendered to a `Bool` constructor name | `optimize.chiral:68-73`; the folded `i-con` at `:92` | IMPLEMENTED | `fold-prim-instr` `:91` |
| fold's third rule, static case dispatch on a known constructor | `optimize.chiral:124-136` | IMPLEMENTED | `fold-block`; outside this row's text |
| `fold` on the shipping path | `lib/lowering/compile-back.chiral:246-250`, import `:16`; its output goes to `erase-fn` (`:17`) | ENFORCED as a rewrite, unjudged | every compile |
| `eval-prim`: the same five host operators in a second dispatch chain, `/` unguarded | `lib/lowering/tal/eval.chiral:86-95`, `/` at `:93` | SEEDED, zero importers (N23 §2) | nothing |
| the erase boundary: op name to the closed `Op` sum, the eight fold ops among sixteen | `lib/lowering/tal/erase.chiral:90-108`, comparisons `:97-99` | IMPLEMENTED | every lowered `i-prim` |
| the emitter's choice of form: `bini:<op>` when the second operand is a tracked constant, `bin:<op>` otherwise | `lib/lowering/mach/emit-core.chiral:152-161` | IMPLEMENTED | every `ti-prim` |
| register form: `x-add`, `x-sub`, `x-imul`, `x-div-guarded`, `x-mod-guarded`, and `cmp` + `setcc` for the three comparisons | `lib/lowering/x64/mach.chiral:355-375` | IMPLEMENTED | `bin:<op>` |
| the division guard: divisor 0 traps (`ud2`), divisor -1 computes the answer without `idiv` | `mach.chiral:173`, `x-guarded` `:281`, `x-div-guarded` `:299`, `x-mod-guarded` `:305` | IMPLEMENTED | both forms |
| immediate form: power-of-two divisors strength-reduced to `sar` and a mask, -1 to negate, 0 to the trap; comparisons split on `imm32?` | `mach.chiral:911` (`x-div-imm`), `:931` (`x-mod-imm`), `bini-body` `:967`, comparisons `:1005-1013` | IMPLEMENTED | `bini:<op>` |
| a fused compare-and-branch path for a comparison feeding a case | `mach.chiral:1175`; `emit-core.chiral:383` | IMPLEMENTED | a comparison in scrutinee position |
| the pinned-golden route: a spec entry for `div` with seven vectors, including `INT_MIN / -1` and `/0` | `lib/lowering/tal/spec.chiral:86-109` | SEEDED, zero importers in `lib/`, `prog/`, `tools/` | nothing. E71 is `ownership/O2`, ledger `design` with its SPEC audit BLOCKED (`docs/elements/ledger.md:137`) |
| the harness precedent: a probe that asserts nothing and prints hex, a bash driver that derives from the row's own operands, one compiler generation per backend mutant, and a byte scan that proves both emitted forms were taken | `tools/test/mul-widen.sh` (435 L), probe `prog/e189-widening-multiply.prog` (98 L), `run-tests.sh:368` phase 32 | ENFORCED | the suite |
| the runtime-opaque identity the precedent uses to keep an operand from being folded | `prog/e189-widening-multiply.prog:38-42`, `(bor (band n 0) x)` | ENFORCED | depends on `fold-prim` modelling no `band` or `bor` |
| a call kills the constant environment, so an operand passed through a call is invisible to the fold | `docs/benchmarks/OPT-CANDIDATES-2026-09.md:80-81` | measured by that inventory | the reason the identity above works |
| `i64->str` segfaults on `I64` minimum | `records/lenses/problems.md:1094` PRB-78 | open, no roster row | the probe routes around it in hex |

**Four readings taken this run.** The probe was compiled in the scratchpad by
`bin/chirality-bin` and nothing under the tree was written.

1. **Literal operands reach `fold-prim`, and nothing upstream folds them
   first.** A probe printing `(/ (- 0 7) 2)` three ways, all literal, second
   operand literal with the first hidden, and both hidden, prints
   `fffffffffffffffc` (-4, the Euclidean quotient) in all three. A compiler
   generation built from a `lib/` copy whose `fold-prim` `/` arm reads
   `(+ a b)` prints `fffffffffffffffb` (-5) on the all-literal line and
   leaves the other two unchanged. So the mutant's blast radius is the folded
   form alone, and one generation took 1.9 s wall.
2. **`INT_MIN / -1` folds to `INT_MIN`**, printed `8000000000000000`, which
   matches the guard's documented answer at `mach.chiral:173-185` and the
   pinned vector at `spec.chiral:107`.
3. **PRB-78 reproduces at `ef3b1ba`**: `(i64->str (- (- 0 9223372036854775807) 1))`
   dies with SIGSEGV, exit 139.
4. **The row's reason for its reference holds only in part, and the part that
   fails decides the design.** The row reads that against `eval-prim` a check
   "agrees by construction" and "can fail only on the guards" and the three
   comparison arms. Read from source, `fold-prim` (`optimize.chiral:62-66`) and
   `eval-prim` (`eval.chiral:90-94`) are two separately written dispatch chains
   from an op name to a host operator, and the status ledger says so at `:164`.
   A mutant that swaps one `fold-prim` arm's operator changes one chain and not
   the other, so an evaluator comparison would redden on it. What an evaluator
   comparison cannot see is a defect in the host operator itself. **The same
   blindness reaches the emitted register form.** `fold-prim`'s `(/ a b)` has
   register operands, so the compiler that runs it was emitted through
   `bin:/`, `x-div-guarded` (`mach.chiral:367`). A defect in that sequence,
   once it is built into the compiler, sits on both sides of the comparison.
   A generation built from a mutated `mach.chiral` by the promoted binary
   carries the old sequence in its own `fold` and the new one in what it
   emits, so the defect shows one generation and hides at the fixpoint. This
   is read from the build order and unrun. The immediate form
   (`mach.chiral:911-1013`) is separately written code and is an independent
   comparison. Only a reference written from the definition, outside the
   compiler, sees a defect common to the host operator and the register form.

## 3. The delta

What is missing once §2 is subtracted.

1. **A reference outside the compiler.** Each arm's expected value over the
   table, derived from the definition in the gate's own arithmetic: two's
   complement wrap for `+ - *`, the Euclidean quotient and remainder for `/`
   and `%`, and the three orderings. Bash `$(( ))` wraps at 64 bits and
   answers `INT_MIN / -1` as `INT_MIN` and `INT_MIN % -1` as 0, measured this
   run; it truncates, so the gate carries the Euclidean correction.
2. **A probe that prints each arm three ways per operand pair**: folded, with
   both operands literal; the immediate form, first operand hidden; the
   register form, both hidden. It asserts nothing.
3. **The zero divisor as its own rows.** `fold-prim` refuses `b = 0`, so the
   folded form keeps the instruction and the program must trap at run time in
   every form. A trap ends the process, so each such case runs alone and the
   expected observation is the `ud2` exit.
4. **Mutants, one compiler generation each**: one per arm of the eight, and one
   that drops the `/` guard. The guard mutant makes the compiler fold `/0` with
   its own guarded `/`, so it traps at compile time on the zero-divisor probe.
5. **A row that ties the table to `fold`'s arm list**, read from
   `optimize.chiral`, so an arm added later without table rows reddens.
6. **A byte scan** that the immediate and register forms were both emitted, on
   `mul-widen.sh`'s G5 precedent (`:53`), because the probe's output cannot tell them
   apart.

Nothing in `lib/` changes. `fold`'s repair is nobody's today, since no defect
in it is measured; this row buys the check.

**Verdict:** a real delta.

## 4. The shapes

Two axes differ in the tree.

### Axis 1: the reference

**Shape E, the emitted instruction alone**, as the row is written.
- **Form:** the three columns of §3 item 2 must agree.
- **Costs:** least.
- **Forbids:** nothing it should. §2 reading 4: it convicts a mutated `fold`
  arm and a defect in the immediate form, and it is blind to a defect in the
  register sequence at the fixpoint. Shard 7 ranks it as an in-house reference
  that shares code with the thing checked.

**Shape ED, the emitted instruction and the definition.**
- **Form:** Shape E's three columns, plus the bash derivation of §3 item 1.
  All four must agree per pair.
- **Costs:** the Euclidean correction and the wrap written once in the gate,
  about 30 lines on `mul-widen.sh` G4's precedent.
- **Forbids:** a defect common to every executor ratifying itself. This is
  shard 7's meaning-of-the-form rank, and the enforcement goal's reason for
  comparators outside the compiler (`docs/goals/enforcement.md:82`).

**Shape P, the pinned spec vectors.** `spec.chiral`'s `spec-div` extended to
eight entries and read by the gate.
- **Costs:** an edit to E71's module under this row, while E71 is
  `ownership/O2`'s, its SPEC audit BLOCKED (`docs/elements/ledger.md:137`), and
  its track `OT`.
- **Forbids:** this row landing before an ownership ruling. A pinned golden cut
  by running the code is the lowest rank in shard 7.

**Shape V, `eval-prim`.**
- **Costs:** N23's unrostered evaluator repair first, for the three
  comparisons.
- **Forbids:** checking what ships. It shares the host operator (§2 reading 4).

### Axis 2: where the operand table lives

**Shape T, a tracked probe** in `prog/`, as E189 does with six rows.
- **Costs:** at the row's five operands, 25 pairs by eight ops by three forms is 600 printed values from
  hand-written source, and the operand list stated twice, once in the probe and
  once in the gate.
- **Forbids:** nothing.

**Shape G, a probe the gate generates** into its scratch directory from one
operand list.
- **Costs:** a generator of about 40 lines in the gate. The probe is generated outside
  `prog/`, so `registration.sh` and the root census do not see it.
- **Forbids:** the table and the probe drifting apart.

Axis 3, the mutant count, is settled by the tree: `mul-widen.sh` builds one
generation per backend mutant, and each mutant pins its whole blast radius
(GA-21 and GA-22, cited at `tools/test/mul-widen.sh:83-85`). Per-arm mutants
are what "each arm checked" means.

## 5. The call

- **Chosen, Axis 1: Shape ED.** §2 reading 4 is the reason: the emitted
  register form and the fold share the host operator once the compiler is
  built, so the row's own reference inherits the blindness it charged to the
  evaluator. The definition column is the only independent writer, and the
  emitted columns stay because they are what ships. Shape P waits on an
  ownership ruling, and Shape V checks something that does not ship.
- **Chosen, Axis 2: Shape G.** One operand list, one home. The probe asserts
  nothing, on the E189 rule.
- **The table:** 0, 1, -1, `INT_MIN`, `INT_MAX`, and the `imm32?` edges
  2147483647, -2147483648 and 2147483648, which `mach.chiral:1005-1013` and
  `imm32?` split on. Eight operands, 64 ordered pairs, eight ops. The eight
  zero-divisor pairs per division op run as trap rows.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | The reference | **RESOLVED → Shape ED** | shard 7's ranking (`docs/banks/verification.md:260-263`); `mul-widen.sh` G4 derives from the row's own operands (`tools/test/mul-widen.sh:45-52`) |
| 2 | Whether the gate takes a suite phase number | **RESOLVED → a numbered phase** | Alive's route re-runs the check when a rule changes, and a `not-a-phase:` gate is dispatched by nothing (`tools/test/registration.sh:34`). E189 registered phase 32 with three compiler generations (`run-tests.sh:368`). Cost: nine generations at 1.9 s measured, about 20 s. `N23` took `not-a-phase:` for a different reason, a census gate |
| 3 | Whether the probe prints decimal | **RESOLVED → hex** | PRB-78, reproduced this run (§2 reading 3) |
| 4 | Whether this row checks fold's static case dispatch | **NEEDS A ROW** | `optimize.chiral:124-136` is outside the row's text and outside requirement 7's second half as written. Listed below. A roster edit is outside this run |
| 5 | Whether the fused compare-and-branch form is a fourth column | **RESOLVED → yes, for the three comparisons** | it is the instruction the backend emits for a comparison in scrutinee position (`emit-core.chiral:383`), which is where a program's comparisons sit |
| 6 | Whether this row repairs `eval-prim` | **DEFERRED → the N23 residue row** | `docs/arcs/parts/enforcement-N23.md`, "Needed and unrostered", first row. This design does not need it |

No decision is the author's. `status: draft`.

## 6. The mint packet

- **Elements: one.** The probe generator, the reference and the mutants
  constrain each other: the table is chosen so every mutant reddens, and a
  reference no mutant tests re-derives nothing.
- **Band:** `E184-E189` is spent (`docs/decisions/decision-lane-split.md`,
  cited by N23 §6). The arc takes the next free number tree-wide, which
  `pack.py --mint` recomputes. `N23` names 203 as free today and is unminted,
  so the number depends on mint order.
- **Catalog row:**
  `| E<NN> | **fold's rules checked once: each arm of fold-prim and fold-cmp agrees with the emitted instruction, in its folded, immediate and register forms, and with the definition, over a boundary operand table.** A gate generates a probe that prints each arm three ways per pair of eight boundary operands, derives the expected value in bash from two's-complement wrap and Euclidean division, runs the zero-divisor rows as traps, and builds one compiler generation per mutant arm plus a guard mutant | Not built. No lib/ file changes | OURS (tools/test/mul-widen.sh, E189); Alive's rule-level check (PAPER, FD-55 §4) | SH |`
- **Ledger row:**
  `| E<NN> | fold-rules | design | Rule-level check of fold-prim and fold-cmp against the emitted forms and a bash derivation, eight-operand table, nine mutant generations | enforcement/N24 | SH |`
- **Size and closure.** Basis: `tools/test/mul-widen.sh` is 435 lines for six
  rows and four mutants.

  | file | change | lines | inside `prog/compiler.prog`'s closure |
  |---|---|---|---|
  | `tools/test/fold-rules.sh` (new) | generator, reference, trap rows, arm-list row, byte scan, nine mutants | 400 to 550 | no |
  | `tools/test/run-tests.sh` | one dispatch line | 1 | no |
  | `lib/lowering/upper/optimize.chiral` | none; the mutants edit a scratch copy | 0 | yes, untouched |

  No closure file changes, so the BUILD RULE owes no cycle for this element.
- **Related:** [[banks/verification]] shard 7 · [[records/findings]] FD-55 ·
  `records/lenses/problems.md` PRB-70, PRB-78 · `enforcement/N7`, `N23` · E17,
  E18, E71, E189

Every `E#` named here is already minted.

## Residue

### Needed and unrostered

Grepped 2026-09-29 over `docs/arcs/*-arc.md` for `dispatch`, `fold`,
`i64->str`, `nb-i64s`, `x-div-imm`, `pow2`, `tal-spec` and `E71`. No row holds
the item below. The `eval-prim` repair is N23's residue row and stays there.

| needed | evidence | arc it belongs to |
|---|---|---|
| fold's static case dispatch checked once at the rule level: a known constructor selects the matching nullary branch or the default, and a mutant that picks the wrong branch reddens | `lib/lowering/upper/optimize.chiral:57` names it fold's third rule; `:124-136` is the code; requirement 7 (`docs/arcs/enforcement-arc.md:471`) quantifies over every rewrite, and row `N24` (`:555`) names only `fold-prim` and `fold-cmp` | enforcement, requirement 7, beside `N24` |

**Seen and not needed.** PRB-78 (`i64->str` on `INT_MIN`) has no roster row
and this design routes around it. The immediate form's divisor-specific arms
beyond the table (powers of two above 2^31, `mach.chiral:931-951`) are the
emitter's own obligation and no gate reads them; this row reaches them only at
the table's divisors.

### Drift against the brief and the row

- The row reads that an evaluator comparison "can fail only on the guards" and
  the comparison arms. It also fails on a mutated dispatch arm, because
  `fold-prim` and `eval-prim` are two dispatch chains
  (`docs/definitions/status-ledger.md:164`). The row's reference has the
  evaluator's remaining blindness at the fixpoint (§2 reading 4).
- The row cites FD-55 at `records/findings.md:1521`. That resolves in the
  working tree only; at `HEAD` the same paragraph is at `:1282`.
- The row's table has five operands. The emitter splits comparisons and other
  immediates on `imm32?` (`mach.chiral:1005-1013`), so §5 adds three.
- `N23` §5 decision 5 says this row checks fold's arms "against the emitted
  instruction". It does, and against the definition too; the two designs claim
  no shared deliverable.
- The brief's `erase.chiral:91-108` and `:112-142`: `op-parse` is declared at
  `:90`, and `prim2lib-table` closes at `:143`. The counts, 16 and 24, hold.

### Unmeasured

- The fixpoint reading in §2 reading 4, a `mach.chiral` mutant showing at one
  generation and hiding at two, is read from the build order and unrun.
- The gate's wall time beyond the 1.9 s per generation measured here.
