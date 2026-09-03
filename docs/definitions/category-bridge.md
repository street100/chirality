---
node: category-bridge
layer: category
refines: [axis-typeability]
implements: [modules-custody, modules-broker, modules-bridges]
supervises: [category-untyped]
related: [category-typed, splitting-law, joining-law, modules-lowering, certificate-discipline, split-role, decision-split-checker]
status: draft
updated: 2026-07-21
---

# Category C: the supervisory bridge

The module is typed. Its referent is a B thing. Its job is to let
[[category-typed|A]] govern [[category-untyped|B]] by turning untypeable reality
into checkable evidence rather than proof. Principle P5, tiers T1 and T3.

This is the part of Chirality that is new work. A is borrowed prior art; B is an
honest admission of holes. C is the apparatus that makes the holes governable,
and it is where the design spends its originality.

## What lives here

- Custody: split values, redundant copies, the per datum security weaving. See
  [[modules-custody]].
- The runtime broker and the capability protocol it speaks. See
  [[modules-broker]].
- The other bridges: attestation, runtime isolation, freshness verification,
  audit reconciliation, driver wrapping, raw reflection, the runtime itself. See
  [[modules-bridges]].

## The defining operation

This operation is the bridge connector of the [[joining-law]]: the connector that
strings A to B across the proof boundary, the across-typeability join. It is what
preserves governance when a module is cut on the typeability axis.

The bridge runs both ways.

Inbound, B to A, verify. Untyped substrate, to checkable evidence, to typed
value. A C module holds a typed handle on a B thing and produces evidence that a
typed process can check: copies that must agree, a verifiable split, a register
anchored MAC, an attestation, an audit trail reconciled against live state.
Disagreement is the alarm. This governs integrity: can I trust what I read.

Outbound, A to B, confine. Typed value, to confined form, to substrate. An A
value crossing into B must be stripped of what must not leak: encrypted if it must
not be read (a secret reaching DMA-readable RAM is a leak), carrying no live
capability or authority into ungoverned substrate, and its cleartext exposure
window bounded. This governs confidentiality and capability containment: does what
I write leak, or hand authority to the substrate. The mechanisms already exist, in
`information-flow` and the linearity in `types` (A) and in `datum-policy` (C); the
outbound bridge is what names them as one discipline.

A C module must never return a B derived value into A without first turning it
into evidence, and must never emit an A value into B without first confining it.
Those two disciplines, verify inbound and confine outbound, are what keep the
thesis's gap closed at the seam in both directions.

## C on the language's own tools, and the provability boundary

"B" means anything unprovable from inside the thing asking, and some of the
language's own tools are B: the bootstrap floor and hardware the checker runs on are
genuinely unprovable, so they are held the C way, as cross-checked evidence ("a set
of tuned runtimes, cross-checked" rather than a trusted blob, [[joining-law]],
[[split-role]]). But the boundary is *provability*, and not everything self-referential
is B. A checker cannot prove *itself* (circular), yet it *can* be proven against an
external spec, so it is not held by agreement at all; it is a small trusted core that
re-checks untrusted producers' certificates ([[decision-split-checker]],
[[certificate-discipline]]). So C's discipline splits by provability: certificates
where the property is provable, agreement across independent sources where it is not.
"No single source of truth" is the right instinct for the unprovable residue and the
wrong tier for the provable core.

## The bridge is one elaborator, not per-referent modules

The bridges listed above are not bespoke per referent. Each is the general bridge
elaborator instantiated with an evidence element (copies that must agree, a MAC, an
attestation, a reconcile) and a target type, the same shape the lowering connector
already has (`translate` plus a generic `preserve-check`). This is where the
originality of C actually lives: in the evidence disciplines, the elements, not in
re-plumbing a bridge each time. See [[decision-bridge-elaborator]].

## C is itself typed, which is required

A hole in the supervisor would be the thesis's gap restated, so C is implemented
in typed code with no exemption. Its dual nature is the point: typed
implementation, untyped referent. The type tracks the evidence; the referent is
the thing the evidence is about.

## Why C is the novel core

The C ceremonies exist today as hand-written procedure: a tiered lock over a
secret, a quorum release of a key, an audit chain that has to be reconciled
against a second record. Every system that needs one rebuilds it from scratch,
and the invariant it protects lives in the author's head rather than in a type.
The aim is to express these directly, so declaring a split is as cheap as
declaring a variable (P5).
