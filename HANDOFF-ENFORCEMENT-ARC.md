# Enforcement arc — upper ↔ lower, and tests that can fail

**Resume from this file, 2026-09-01.** Lane split and file ownership: `LANES.md`.
Lane A resumes from `HANDOFF-LANE-A.md`. Coverage target list:
`docs/definitions/bug-classes.md`. Build-state authority:
`docs/definitions/status-ledger.md`.

## What this arc is

Two author directives, 2026-09-01:

> fully enforce upper ↔ lower as a must always. we made a typed lower level to use it.
> also we need to enforce real tests

The language lowers to typed assembly and then throws the types away without
checking them. The checker that would check them is not in the compiler. That is
this arc.

## The measurement that forces it

All measured on this tree after E181 landed. Reproduce before trusting.

| | |
|---|---|
| compiler import closure of `prog/compiler.prog` | **59 modules, 16,463 LOC** |
| `lib/` | 103 modules, 25,559 LOC |
| checking machinery **outside** the closure | **1,680 LOC across 10 modules** |
| zero-importer modules in `lib/` | 18, 2,086 LOC |

The ten outside:

| module | LOC | what it was for |
|---|---|---|
| `typing/totality` | 387 | termination |
| `lowering/upper/optimize` | 254 | holds the only `ck-fn` call in the tree, at `:250` |
| `lowering/tal/check` | 246 | **the preserve check** |
| `lowering/tal/eval` | 187 | reference tal interpreter |
| `lowering/upper/eff-lower` | 183 | effectful lowering |
| `typing/row-infer` | 137 | effect row inference |
| `lowering/tal/spec` | 126 | the tal spec |
| `typing/kernel-core` | 60 | the frozen judgment |
| `typing/reflect-floor` | 54 | the reflective floor |
| `typing/effects` | 46 | the `->` / `=>` membrane |

### What the compile actually does

`compile-fn` (`lowering/upper/lower.chiral`, imported at `compile-back.chiral:15`)
lowers eligible defs to typed SSA (`TFn`) in **every** compile. `erase-fn`
(`compile-back.chiral:16`) then strips every `TFn` to a neutral `NFn`, and
`emit-elf-m` takes `(List NFn)` only (`compile-emit.chiral:292`).

So the types are produced and discarded with nothing checking them in between.

One check does ship and does run: `ck-tiprog`, the E76 syscall chokepoint, at
`compile-emit.chiral:296`. It refuses the image. Do not confuse it with the
preserve check.

### And a large fragment never lowers

`skip-reason` (`lowering/upper/lower.chiral:83-93`) keeps a def **upper** when it:

1. is dependently typed,
2. is **effectful**,
3. carries a quantified (0/1) binder,
4. has a type that does not lower.

E70's catalog row states that self-hosting cannot go native without effectful
lowering. The lowered-versus-skipped ratio is **unmeasured**; `status-ledger`
marks the old 48/48 figure as a Python-era count that nothing in the tree
reproduces.

### The checker cannot say it

`diag.chiral:97-110` defines 38 `Judg` constructors, `:120-137` nine `Reason`
evidence shapes. Grouped: type and arity shape 17, case coverage and constructor
use 10, refinements 5 (**`I64` only**), linearity and usage 4, strict positivity 1,
scope and binding 4, lowering skips 1.

**No constructor exists for a preserve-check failure, an effect violation,
non-termination, a bounds violation, an overflow, or ABI disagreement.** A rule
cannot refuse what the vocabulary cannot say, so the arm comes before the caller.

⚑ `diag.chiral:20-25` records a landmine any new arm inherits: a `case` over
`Reason`/`Subject`/`Judg` must be the direct body of a `lam`, never nested inside a
case arm, or a real compiler "unknown name" bug fires. Seven exhaustive `case`s
over `Reason` each gain an arm.

⚑ `Judg` is edited by **E182, which is Lane A's**. This is the one part of the arc
that is not lane-neutral.

### How 1,680 LOC got written and never ran

`tools/test/run-tests.sh:280` prints its own verdict:

> `compile-only: N roots built, N failed -- gates, but asserts nothing`

**88 roots** go through that. A module that compiles passes. Nothing asks whether
a module is inside the compiler's closure. So a checking rule can be written,
compile clean, pass the suite, get marked built, and never run.

`prog/test-runner.prog:8-9` already calls "built but unadopted" this repo's
measured failure mode and counts four. The sweep says ten. Lane A independently
found **eleven toothless gate rows** in one arc. Same defect at two altitudes: a
row that cannot fail, and a module that cannot run.

## Requirements

1. **Everything lowers.** `skip-reason`'s four exclusions go. Gate is an empty skip
   list for the compiler's own source.
2. **What lowers is checked.** `ck-fn` runs on every `TFn` **before** `erase-fn`,
   and failure refuses the compile.
3. **A closure gate.** Computes the compiler's import closure and refuses when a
   module declared required is absent.
4. **Every `Judg` constructor has an asserted refusal fixture.** Run, not compiled.

1 and 2 together are the must-always. Either alone leaves the hole: everything
lowering with nothing checking it, or a check over a fragment.

## Element bounds

⚑ **Numbers are not minted and must not be guessed.** `LANES.md` gives Lane A
E184–E189 and Lane B E190–E195. This arc is in neither band. Author call needed:
extend a band, or open a third. Two sessions already minted `E173` independently
because the catalog is not the only place a number lives.

⚑ **The catalog stops at E173. Artifacts reach E181.** E174, E175 and E181 have
worked examples and INDEX rows; E176 through E180 and E182 through E184 are
referenced in Lane A's artifacts. Reading the catalog alone is how a number gets
reused.

| bound | marks off |
|---|---|
| **Closure enforcement.** A check computing the compiler's import closure, refusing when a declared-required module is absent. The declaration list is the contract | the hole that hid 1,680 LOC |
| **Judgment arms.** `Judg` gains preserve-failure, effect-violation and non-termination constructors with their `Reason` shapes | unblocks E11 and E171, which cannot refuse without them |
| **Preserve check wired.** `ck-fn` on every `TFn` before `erase-fn`; failure refuses | E16's preserve-check claim, E18's "checker built", `optimize`'s orphan call |
| **Effectful lowering.** `=>` defs lower to typed SSA | E70, `eff-lower` outside the closure |
| **Total lowering.** The other three `skip-reason` exclusions | the `r-skipped` escape hatch |
| **Refusal fixtures.** Every `Judg` constructor triggered and asserted | the 88 roots that assert nothing |

Open on bounds:

- Does the closure gate assert a hand-maintained required list, or that every
  `lib/` module is in the closure or explicitly declared out? The second catches
  new drift and costs a declaration file.
- Does effectful lowering absorb E70 or re-bound it? E70's scope is already right.
- `optimize`, `kernel-core` and `reflect-floor` need an author call rather than an
  element: wire, or mark seeded with a date.

## Order

1. **Closure gate.** Nothing else is safe first, because every element below can
   regress into the same state silently.
2. **Judgment arms.** Coordinate with Lane A, since E182 edits `Judg`.
3. **Preserve check wired.** Cheapest real enforcement. The checker exists.
4. **Measure the lowered/skipped ratio.** One read-only run. It decides whether
   step 5 is four small fixes or a rewrite.
5. **Effectful lowering**, then the remaining exclusions.
6. **Refusal fixtures**, per rule as each lands.

## Hazards

- **Everything here lands in `kernel.chiral` or the compile path**, so each carries
  a full fixpoint rebuild. Precondition: on the unmodified tree `B1(blob)` must
  already equal `bin/chirality-bin`, or merge-inherited staleness gets blamed on
  the element. Always `[ -s ]` before `cmp`; two empty files compare equal.
- **A `native-lib` change must be verified at GEN3.** `compile-emit.chiral:295`
  prepends the compiler's compiled-in runtime to every image, so gen1 and gen2
  compiling proves nothing.
- **Wiring a check makes the compiler accept less.** `lib/evidence/harness.chiral`
  and `lib/runtime/proc.chiral` are shapes that could flip. Re-verify against them
  specifically, not just against the fixpoint `cmp`.
- **`kernel.chiral:817-818`** states helpers are split so parens stay locally
  countable. A new judgment goes in a top-level helper, never inline.
- Separate worktree per lane, under `/workspace`, never `/tmp`. Never work in
  `/workspace/chirality` itself.

## Related open work, not this arc

- **`let`-bound `case` is diagnosed and the old hypothesis is refuted.** No join.
  The verdict depends on **source arm order**, so it is first-arm-wins: arm 1 is
  inferred, its type becomes expected, later arms are checked against it. A
  branch-local assumption from the narrow hook escapes as the case's result type.
  Refusal at `kernel.chiral:1440`. `check-let` (`kernel.chiral:983`) is the only
  construct that drops into infer mode, which is the entire scope. Widening the
  bound result is **unsound**, with a counterexample that checks today. Three
  coherent shapes remain, so it needs a blueprint.
- **`str-sub` is E176 and is Lane A's.** Unclamped, exits 139, 131 call sites, and
  `str-starts-with` is built on a false comment claiming it clamps.
- **19 catalog rows say not-built while INDEX says implemented.** Six carry a
  deliberate "recorded rather than picked" flag. Nothing lints the catalog's State
  column: check J compares membership, check N compares LEDGER against INDEX.
- **`ledger-lint` check T** walks the artifacts and asserts each has a catalog row
  and an INDEX row. It flags **E57**, which has example, spec, catalog and ledger
  rows and no INDEX row.
