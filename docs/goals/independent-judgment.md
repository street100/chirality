---
node: goal-independent-judgment
layer: navigation
related: [goals/README, decision-self-verification, certificate-discipline, split-role, testing-floors, index]
status: current
updated: 2026-09-03
---

# Goal: judgment that does not rest on one formulation

## The claim, and where the project makes it

- [[status-ledger]], the external-judgment banner: the Rocq leg, the CompCert
  leg and the Python oracle are cut, and what replaces them is three
  semantically distinct judgment cores that must agree, which is unbuilt. So
  every rung in the ledger is enforcement against error.
- The criterion is **different formulations**. Three encodings of one rule set
  would be worth nothing, which is why a second target under one formulation was
  dropped rather than counted (`docs/elements/catalog.md`, E166).
- `docs/decisions/decision-self-verification.md` §0 records the call and what it
  rules out.
- `PRINCIPLES.md` §5: where proof runs out, split the truth and require
  agreement.

## What done means

N semantically distinct judgment cores, each a different formulation of the rule
set, run against the same input and required to agree. Disagreement is a
refusal. One formulation with two emitters fails the bar: that is what the
`Mach`-to-C backend was, and it was dropped on 2026-09-01 for that reason
(`d8bcec5`, `d0c5dd5`).

1. **What counts as a distinct formulation is written down**, so a candidate leg
   can be judged against it. Observed by the criterion being settled rather than
   `status: draft`. [[arcs/independent-judgment-arc]] row `J1`.
2. **A second judgment core exists in a different formulation**, and the quorum
   runs both. Observed by two cores agreeing on the same input.
   [[arcs/independent-judgment-arc]] rows `J2` and `J3`.
3. **The quorum refuses what it should.** Observed by `ddc-bad-quorum` firing on
   fewer than two live legs. [[arcs/independent-judgment-arc]] row `J4`.
4. **The demanded statement is a form a check can read.** Observed by `JForm`
   completed or closed, with `SpecRule.statement` no longer a bare `Str`.
   [[arcs/independent-judgment-arc]] row `J5`.
5. **[[status-ledger]] stops saying every rung is enforcement against error.**
   Observed by the ledger distinguishing enforcement against error from
   enforcement against an adversary. **No row serves this**, and the hole is
   enumerated as `GAP-06`. [[arcs/independent-judgment-arc]].

## State

Unbuilt as stated: one arc, five rows, zero elements, and no work in the tree
serves it. What exists today is the premise this goal rests on, and a number.

### Premise 1: three categories cover everything

There is no fourth, because [[thesis]] forbids one. A path the framework cannot
name is ungoverned by that fact alone, so the only way to control everything is
to be able to express everything.

| | what it holds | what judges it |
|---|---|---|
| [[category-typed]], A | the kernel calculus, the type system, quantities, refinements, totality, the surface. Where correctness rests on a proof | the judgment core, directly |
| [[category-untyped]], B | the substrate that violates types from outside the language's reach: DMA-capable peripherals, raw memory, the far side of the FFI, the register root | nothing can. It is named, quarantined, kept as small a set as possible |
| [[category-bridge]], C | typed modules whose referent is a B thing: custody, the broker, attestation, driver wrapping | the judgment core, on the evidence C produces rather than on B |

A is borrowed prior art, B is an honest admission of holes, and C is where the
originality goes. Together they leave nothing unnamed, which is what makes a
single core sufficient rather than merely small.

### Premise 2: the type is carried from upper to lower

A type here survives past the point where an annotation would be discarded. The
surface elaborates into the small calculus before checking, so
convenience syntax has nothing left to smuggle. The calculus is checked against
quantities and refinements. What survives lowers to a typed assembly. The
judgment made at the top is the judgment in force at the bottom.

### So the core is the whole answer

Everything above it is text the core checked. Everything below it carries the
core's verdict rather than deciding again. That is why the number below is a
trust boundary and not a module size. Measured 2026-09-03, and
[[trust-boundary]] holds the TCB it sits inside.

| what | lines | note |
|---|---|---|
| the judgment core: `kernel` + `kernel-core` + `qtt` + `refine` | 1,823 | the number the question asks for |
| all of `lib/typing/` | 3,449 | the core plus elaboration, inference and diagnostics |
| `lib/` and `prog/` | 52,335 | everything the core checks |

Recording the gap is the point of the goals tier. It was visible only as a
caveat in the spine, where it read as a limit instead of as unstarted work.

⚑ 1,823 lines is optimistic for "small enough to read in a sitting", and that
claim is flagged and unresolved. `kernel-core.chiral` and `reflect-floor.chiral`
both have zero importers, so part of what the number counts is written and
unreached. The typed-assembly floor below the core has a checker the compile
never calls, so the trust argument stops where emission begins.

The three modules written for this goal are unreached, and the measurement
sharpened on 2026-09-02 (`records/findings.md` FD-09): `lib/typing/kernel-core.chiral`
holds `JForm`, the six forms the judgment splits into, and every one of them has
a single use, its own declaration line. Nothing imports the module. The demanded
statement each leg would be judged against is a `Str`, so the artifact
[[certificate-discipline]] names as the one place vacuity survives is prose.

## Arcs

[[arcs/independent-judgment-arc]]. It carries no reserved element block and its
rows take arc-local ids `J1` and up, so it can be worked without one.

## Honest limits

**Both premises are partly unpaid.** Premise 2 breaks at emission: types are
erased before the ELF is written, the typed-assembly preserve check is never
called, and the checker that would run there refuses 754 of the 1,481 functions
the compiler emits for its own source ([[records/enforcement-arc]] EN-08,
2026-09-03). Premise 1 is unpaid on C: [[goals/ownership-and-trust]] holds most
of the bridge and is deferred whole, so B is named without being governed.

**The core is one formulation, so agreement is with itself.** That is the goal
above, and it is why the line count answers a smaller question than it looks
like it answers.

- `bin/chirality` has no `test-rocq` and no `test-python` subcommand, on purpose.
  A subcommand dispatching to a floor this tree lacks is a gate that cannot fail.
- [[testing-floors]] still lists the cut external floors. That is
  `records/baseline-alignment.md` BA-08.
