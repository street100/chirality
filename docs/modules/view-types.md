---
node: view-types
layer: view
related: [perspectives, vocabulary, modules-core, category-typed, category-bridge, decision-b-in-type, modules-lowering, decision-profiles, permission-model, node-architecture, open-edges]
status: draft
updated: 2026-07-04
---

# View: the type system

The system read from one seat, the proof engineer's: what is proven, what is only
evidenced, and what the type actually contains. Everything here is restated from
the linked notes; on any conflict, those notes win.

## Three words, one of which is "type"

[[vocabulary]] pins the disambiguation this seat depends on. A type is the full
proof-carrying signature of a process, in the QTT sense (P2): its effects, the
resources it spends, its tier weight, all of it. A port is the outward-facing
contract of a single boundary crossing, not a type. A port protocol is the state a
crossing advances as data flows through it, not a static type either. This view
uses the words that way throughout.

## What the type contains

The type is the entire truth about what a process can do ([[perspectives]]). P2
allows no exemption: a function is a process whose type says it has no effects,
and a category of code that opts out of the type is the thesis's gap restated. So
the signature carries the effects (the port algebra, P3), the graded cost (time,
space, termination, P2 and P4), the tier weight (how the truths it holds are held,
P7), and the ports it offers, which are the outward slices of the type. Authority
and resource use are not two accounts; both are the weight of the type, and that
weight is the cost gradient of P5.

## The feature list

[[modules-core]] fixes the kernel and the features. The trusted core is a small
checker over one canonical term language built on Quantitative Type Theory, which
carries linearity, dependency, and erasure in one calculus; the 0 quantity binding
lines up with the erased, proof-only T0 case. The `types` module folds the feature
surface under one roof: linear and refinement (refinement absorbs integer safety,
same type shape, see [[modules-security]]), with dependent, region, and subtype
deferred to later slices, plus capability as the typed face of P3. `effects` is
the closed port algebra, including alarm effects and their counter effects
([[error-and-alarm]]). `cost-typed` is graded time, space, and termination, an
over-approximate bound, because exact cost is undecidable. `totality` makes total
the default and partiality the marked climb (P5). The build order (refinement,
then linear, then capability) is recorded, not decided; see [[open-edges]].

## Where proof ends and evidence begins

The typeability axis is this seat's map ([[axis-typeability]]). In
[[category-typed|A]], correctness rests on proof: one copy is correct because it
is proven, tier T0, the region of P1 through P5. In [[category-bridge|C]], the
module is itself typed but its referent is untyped, so what the type tracks is
evidence: copies that must agree, a verifiable split, a register-anchored MAC, an
attestation, a reconciled audit trail. Divergence is the alarm (P6, P7). Tiers T1
and T3 live here; T2 is the warning case, secrecy without tamper evidence. In
[[category-untyped|B]] there is no proof and no evidence, only the referent, and
the type system's move is [[decision-b-in-type]]: B lives in the type, not the
packaging. A B module's signature declares its untyped referent and carries the
ports that say it crosses to ungoverned substrate, which forces every use through
a C supervisor. The quarantine is the signature. A must never accept a B-derived
value except as evidence produced by C, and never emit into B except confined.

## Typed lowering

The type does not stop at the surface. Lowering is type preserving and checked
down to `tal`, the typed assembly floor, which has its own A, B, C
([[modules-lowering]], [[axis-altitude]]). `preserve-check` is the proof that a
lowering step opened no hole; its first concrete customer is `constant-time`,
verified at lowering. There is no untyped bottom: erasure relocates into one
trusted machine code emission step below tal that the programmer never edits,
which is why compiling to C is forbidden ([[decision-backend]]). On CHERI hardware
the B type mark is carried into silicon rather than erased, an additive floor, not
a requirement.

## Conformance is type-checking

G9 in [[decision-profiles]] makes profile validity a typing judgment. A target is
a requirement type: the ports, effects, and guarantees a runtime for it must
provide. A profile's composite type is the type of the runtime it stages, since a
runtime is a process and a process is its type ([[process-and-runtime]]).
Conformance is the composite satisfying the requirement, a subtyping relation in
the existing type system, alongside two reused checks: every connection uses a
preserving connector ([[joining-law]]) and every substrate access routes through a
port. Nothing new is invented; validity is checkable because it is a type check.

## Permission in type terms

Authority is not a runtime entity behind a privilege boundary. It is a property of
a port's type, settled when the code was staged ([[node-architecture]]). A
capability is a port held; holding it is the authority, and there is no separate
permission record. The [[permission-model]] adds the crossing: permission over a
crossing is a set of processes agreeing on it, and that set, the bridges the
crossing traverses, is fixed by the crossing's type. The grant a process presents
is a held port in its active role; the bridges verify against it. Mediation with
no mediator: the port check is the type check, so at runtime there is no
permission asking for the statically decided part, and only the irreducibly
dynamic remains with the component broker ([[decision-brokers]]).

## Linearity is the conservation law

Linearity does physical work in this design, not just aliasing hygiene. The port
supply is linear: a port can only be minted against real finite capacity, so the
total authority handed out cannot outrun the hardware, conservation by linearity,
not by an accountant ([[node-architecture]]). An exclusive port is a linear
resource, held by one node at a time and moved, never owned, so aliased exclusive
authority is not expressible; overlapping exclusive grants cannot coexist because
they draw on the same linear supply ([[open-edges]], the permission section).
Custody uses the same mechanism: the T0 secret is a linear value in A, shares are
move-only and zeroed on drop, and reconstruction is an effect
([[modules-custody]], [[splitting-law]]).

## The open type mechanisms

Four edges from this seat are open in [[open-edges]] and are not resolved here.
Edge 14, the port protocol: what a live port between processes is, and whether
ports are formally session-typed, is an open mechanism decision
([[vocabulary]]). Edge 16, the effect mechanism for alarms and counter effects:
algebraic effects with resumable handlers, typed result rows, or another shape.
Edge 18, compositionality: which requirement-type properties are plain subtyping
and which need a global analysis, with chirality-verify as the first concrete case.
Edge 4, tier selection: whether a classification carried in the type auto-selects
the minimum rung, so forgetting to split a secret is a type error.
