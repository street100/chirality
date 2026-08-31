---
node: decision-graded-kernel
layer: decision
related: [modules-core, memory-model, open-edges, modules-staging, error-and-alarm, time-and-clocks, decision-b-in-type, permission-model, totality, decision-effect-facets]
status: settled
updated: 2026-07-21
---

# Decision: the graded kernel (cost, totality, staging)

## The forks

The load-bearing open edges named the same region from three sides. Edge 3
(the cost gradient): totality by default, graded cost in the type, or runaway
shapes made hard to express. Edge 2 (how far the membrane reaches inward):
I/O, time, space for certain, then termination and information flow or grade
them and stop. Edge 16 (the effect mechanism for alarms and counter effects).
Under all three sat one meta question, the one that blocks the stage 3 kernel:
does cost live in the kernel's own grade structure, or in an elaboration
module the kernel checks.

The scaffold made these decidable with running evidence: the idle bound is
structurally zero, the value indexed pool carries a bound in its type,
refinement showed the quantity arithmetic is already generic over its grade
set, and F1/F2 backflow fixed what erasure and linear kinds must say.

## The decision

Cost lives in the kernel, as an enrichment of the grade structure QTT already
carries (option A over the external module option B). QTT is defined over an
arbitrary resource semiring; the {0,1,w} the kernel uses today is one instance.
Enriching it grows the data the resource arithmetic ranges over, not the
judgment logic, so it keeps the "keep the kernel small" mandate while pushing
the cost invariant into the substrate rather than bolting it across a seam.

The things the design wants are not one kind of construct. They divide three
ways, and each goes to its correct home:

1. Coeffect grades, which compose in one product semiring: usage (the linear
   0/1/w already present), time, space, and information flow. These are
   resources: they scale under substitution and add under sequencing, so they
   share one graded structure (the Granule design is the existence proof that
   usage, cost, and security levels cohabit as grades). The kernel semiring is
   parametric over its grade set; the factor width is fixed now (usage x time
   x space x info-flow) so adding a factor later is not a change to the trusted
   structure. The cost grade domain starts as the naturals with infinity
   (constant bounds), with size indexed grades as the promotion path, sharing
   the linear arithmetic entailment refinement already needs. Information flow
   starts as a trivial lattice (a reserved seat, enforcement is stage 7 to 8).

2. A property, not a grade: totality. Total by default, partiality is the
   marked climb (the policy the base already states); the mark is a tracked
   modality, and it is the home of the effect algebra of edge 16 (partiality is
   one effect beside the alarm and counter effects — amended 2026-07-21, alarms
   are crossings; see the amendment at the end). The checker that
   discharges the total claim is structural recursion plus strict positivity
   plus case coverage, the standard minimal totality kit (all three built —
   [[totality]] — with the recursion check classifying, not yet enforcing);
   sized types are the
   promotion path, and a size index is close enough to a cost grade that if
   sized types land they reuse the semiring machinery. Totality is the license
   to evaluate at generation time: the compiler may run a subterm early only if
   it is total, so this property is what makes precomputation and pregeneration
   safe rather than a way to hang the generator.

3. A modality, not a grade: binding time and staging. Static versus dynamic is
   about when a value is available, not how much of a resource it costs, so it
   is a modality (Davies and Pfenning's staged calculus) and lives in the
   staging layer, not the kernel semiring. Multi stage, not two level, because
   the process model is self similar: run a configuration and it is itself a
   runtime that can stage a further runtime. spawn stages the next level,
   specialize is cross stage partial evaluation, pregen is running the static
   level ahead of time. The scaffold path is two level first (formalizing what
   the lowering connector and the native backend already do implicitly) then
   the multi stage generalization.

## Why this resolves it

Edge 3 becomes the cost semiring; edge 2's membrane reach becomes the fixed
factor set (time and space as grades now, information flow as a reserved
factor, termination handled as a property beside the grades rather than as one
of them); edge 16's mechanism is the partiality-and-alarm modality that the
totality mark already needs. The category error the decision avoids is forcing
termination or staging into the coeffect semiring: termination is not a
resource that scales, and staging is a question of availability, not amount.
Keeping each in its home is what lets the trusted structure be fixed once.

The three together are the stated goal's payoff triangle: the semiring says
what can be known statically, totality says it is safe to run early, and the
staging modality is the mechanism that runs it early. Type, precompute,
pregenerate, generate on the fly, in that order of dependence.

## What this does not decide

The reflective floor (edge 5) is untouched here; it remains open. This
decision fixes the grade structure's shape and the direction of the totality
and staging mechanisms. The enforcement is a staged build: the semiring shape
unblocks the stage 3 kernel and is built first; the totality checker and the
staging modality need only their seats reserved and are built as their stages
arrive. Full information flow enforcement is stage 7 to 8. Recorded so the
build proceeds without reopening the shape.

## Amendment (2026-07-21): alarms are crossings, not modality-mates

Point 2 homed the edge-16 effect algebra in the partiality modality,
"partiality is one effect beside the alarm and counter effects." The
effect-facets decision ([[decision-effect-facets]]) corrects the second half:
an alarm is an act on the membrane — a crossing carried in the effect row —
and its counter effects are crossings too (the scaffold's `halt`/`exit`
externs were already this). Partiality stands alone as the marked modality.
The grade structure of point 1 and the staging modality of point 3 are
unchanged.
