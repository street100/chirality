---
node: modules-broker
layer: module
implements: [category-bridge, category-typed]
related: [module-map, decision-brokers, splitting-law, modules-bridges]
status: draft
updated: 2026-07-22
---

# Broker modules

> **Status: mostly DESIGNED.** Only spawn / teardown / link-at-load are built;
> grant / revoke, audit-reconcile, and adhikara (the capability protocol this
> chapter rests on) are intent. See [[status-ledger]].

The word broker carried two different modules. The splitting law and
[[decision-brokers]] cut them apart. They sit at different altitudes and in
different categories, and they agree through one protocol.

## broker, emergent (A)

The compile time port mediation. In Chirality the port check is the type check, so
the static part of Bhumi's syscall broker has no runtime entity. It dissolves
into the capability and effect type system. This is `kernel-gate`'s static half
plus capability typing. Calling it a broker is the historical confusion; it is
just type checking. Provenance: dump D1, the broker collapse.

## broker, component (C)

The runtime supervisor of the part that cannot be decided at compile time:
process and runtime lifecycle (spawn and teardown), dynamic grant and revoke,
audit reconciliation against live state. It is stateful, its referent is the set
of running processes (a B thing), so it is a typed supervisor over untyped
runtime reality. The live population it supervises is the process model in
[[process-and-runtime]]. Provenance: dump D13, the four component AUTH and AUDIT
decomposition. That internal decomposition is resolved in direction (2026-07-22,
edge 8): not four bespoke parts — the general bridge elaborator over the
live-population B-referent, per-runtime by self-similarity, its internals
evidence-element choices plus the counter-effect dispatch set; see
[[open-edges]].

## The dividing line

The compile and run line decides which broker owns a concern. Push everything
statically decidable down into the type system, where it becomes the emergent
broker and disappears as a component. Leave only the irreducibly dynamic to the
component broker. This is P5: push invariants into the substrate, leave the
runtime seam as small as possible.

## adhikara

The capability protocol both halves speak: the shared algebra so the static
checker and the runtime supervisor agree on what a capability is. Its invariants
are checkable: monotonic attenuation, no spontaneous rights, revocation
transitivity, translation preserves or reduces rights. It is the same discipline
as the language level capability type, projected onto the wire and translation
layer across silicon, kernel, language, component, and network. The
correspondence is resolved in direction (2026-07-22, edge 7): the two do not
"agree" — Adhikara is the capability discipline *lowered* onto a B channel,
its upper face exactly the type operations, safety enforced locally at each
membrane with no foreign agreement load-bearing; see [[open-edges]].
Provenance: dump D8.
