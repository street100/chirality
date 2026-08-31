---
node: floor-agreement
layer: foundation
refines: [joining-law]
related: [testing-floors, joining-law, axis-altitude, modules-lowering, modules-staging, decision-backend, open-edges]
status: draft
updated: 2026-07-26
---

# Floor agreement

> **Provisional direction (2026-08-02, E71).** The **Statement** below now reads
> **spec-as-golden**: the tal specification ([[tal-spec]]) is the golden object;
> the reference interpreter is first-among-producers, none privileged. This is the
> provisionally-adopted branch ("go for a solution, may change" — ratification is
> the owed author call, E72 its strongest argument). Marked revisitable. Only
> *what is golden* moved; the *agreement mechanism* (collapse → validate → fuzz,
> every executor agrees on the observable) is unchanged, and its sections below
> still read "against the reference" — sound because the reference is a
> spec-conformant producer, the cheap proxy for the spec.

The [[joining-law]] gives the lowering connector one invariant, *the type,
preserved and checked down to tal*, and the staging connector another,
*semantics: a residual computes what its source would*. This note draws the line
those two rows straddle, and that the scaffold once crossed: **type preservation
is not value preservation, and tal has more than one executor.**

## Statement

tal is a typed IR with one operational meaning. That meaning is fixed by a
**specification** — [[tal-spec]], per-instruction transition semantics plus
pinned observable vectors — and *realized* by more than one executor. Call each
executor a floor:

- the **reference interpreter** (`TalMachine`), which runs tal directly —
  first-among-producers, no longer the definition;
- the **native backend**, which lowers tal to machine code below the single
  trusted drop ([[axis-altitude]]);
- the **constant-folder**, which evaluates tal fragments at generation time
  ([[modules-staging]]);
- eventually a **chirality reference executor**, the self-hosted producer.

`preserve-check` guarantees each floor is well-typed. It does not guarantee two
floors compute the same value. **Floor agreement** is that second invariant:
every floor agrees with **the spec** on the *observable result* — the returned
value and the sequence of effects — for every well-typed program. The spec is
the golden object; **a floor that disagrees with the spec's vectors and semantic
functions is wrong by definition**, even where it type-checks — and so is a
behavior every floor happens to share but no spec vector derives (correlated
agreement cannot ratify an accident into law). The reference interpreter is
demoted to the first producer through that gate; where it diverges from the spec
the divergence is *investigated*, not auto-ruled against either side.

## Why it follows from the principles

The joining law assigns lowering the type and staging the meaning. A floor is
both: a lowering (upper to tal to metal) and, whenever it folds, a staging (a
residual standing in for what the source computes). `preserve-check` discharges
the lowering half. Nothing discharged the staging half except by test — so a
rewrite could preserve the type and change the value, and the floor accepted it.
That is not a lowering bug the type catches; it is a staging-invariant violation
the type is blind to. P2 (a process is its type) fixes what a program *is*; it
says nothing about two machines agreeing on what it *does*. Floor agreement is
the missing half, and it is a joining-law invariant like the other four, not a
testing convenience.

## The mechanism, strongest first

Push the invariant into the substrate where you can; test it only where you
cannot. In order of preference:

1. **Collapse.** Where a floor can reuse the reference's own definition, it must.
   The constant-folder computes `+ - * / %` by *importing the reference
   interpreter's arithmetic*, so a folded value is the executed value by
   construction, not by agreement. One definition cannot disagree with itself.
   This is the substrate form (P5); prefer it always.
2. **Validate.** Where a floor is irreducibly separate — native machine code is
   not the reference interpreter — check it against the reference by differential
   execution: run both on sampled inputs, require equal observables. The target
   is per-compile *translation validation*: synthesize a simulation between the
   tal and the emitted code and discharge it to the same solver the refinements
   use, so a validated compile carries a proof rather than a sample.
3. **Fuzz.** Generate well-typed tal and mutate it into equivalent variants
   (equivalence modulo inputs), cross-checking every floor against the reference.
   This is the cheap net that finds the divergence no one thought to sample.

The three are a gradient, not a choice: collapse what you can, validate what is
left, fuzz to find what the first two missed.

## Worked example: division

`(/ (- 0 7) 2)` type-checks on every floor. Before this note the reference
interpreter floored (`-4`), the constant-folder truncated toward zero (`-3`), and
the native backend truncated on the hardware `idiv` — three floors, one type,
three values, and `preserve-check` passed all three. The repair was the mechanism
in order: **collapse** (the fold now imports the reference's arithmetic),
**pin the reference** to Euclidean division (matching SMT-LIB's `div`/`mod`, so a
solver-discharged refinement means at runtime exactly what it proved), and
**validate** the native floor by differential fuzz across the full sign grid.
This is the canonical floor-agreement failure and its canonical fix.

## The honest boundary

Today floor agreement is testing-grade, not proof-grade. Collapse is a real
guarantee for the fragment it covers (the arithmetic prims). The native floor
rests on differential execution, which proves nothing about the inputs it did not
run. The target is the split the verified compilers settled on: a simulation
proof for the frozen tal *core* — small and stable — and validation-plus-fuzz for
the periphery. State the guarantee as it is: floor agreement holds *by
construction* where floors collapse, and *by test* everywhere else, and the work
is to move each floor up that gradient.

## Reach

Every new tal instruction (edge 6, where the vocabulary is drawn; see
[[open-edges]]) is a new agreement obligation across all floors, not just a new
type rule. Every new backend ([[decision-backend]]) is a new floor that must
agree before it ships. The rule is one line: **a floor is admitted only once it
agrees with the reference interpreter on observable value, by construction where
possible and by validation where not.**
