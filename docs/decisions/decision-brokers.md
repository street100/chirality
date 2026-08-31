---
node: decision-brokers
layer: decision
related: [modules-broker, splitting-law, category-bridge, open-edges]
status: settled
updated: 2026-07-27
---

# Decision: two brokers, agreeing through Adhikara

## The contradiction

The dumps used broker for two incompatible things. In some places the broker
collapses to nothing, because it is just a result of type systeming (dump D1). In
others the broker is a component managing things with its own state behind it,
decomposed into four AUTH and AUDIT parts that handle runtime spawn and teardown
(dump D13).

## The decision

These are two different modules wearing one name. The splitting law cuts them.

- broker, emergent (A). The compile time port mediation. The port check is the
  type check, so the static part has no runtime entity and dissolves into the
  capability and effect type system.
- broker, component (C). The runtime supervisor of the irreducibly dynamic part:
  lifecycle, dynamic grant and revoke, audit reconciliation against live state.
  Stateful, with running processes (a B thing) as its referent.

The dividing line is the compile and run line. Push everything statically
decidable into the type system, where it becomes the emergent broker and
disappears. Leave only the irreducibly dynamic to the component broker.

Adhikara is the capability protocol both halves speak, so the static checker and
the runtime supervisor agree on what a capability is.

## Why this resolves it

D1 collapse to one is true of the static half. D13 four component decomposition
is true of the dynamic half. They were never describing the same thing. See
[[modules-broker]].

## Principle basis

P5 (push invariants into the substrate, keep the runtime seam minimal) and the
splitting law (one name across two categories is under split).

## Resolved (D-walk 2026-07-22, homed 2026-07-27)

Two questions the D-walk settled in direction — the component broker's internal
decomposition (docket D5, edge 8) and the capability-type↔Adhikara correspondence
(docket D6, edge 7). Both are now settled here; the open-edges entries carry the
residues.

**Broker decomposition (D5): not a bespoke four-part architecture.** The component
broker **is the general bridge elaborator** ([[decision-bridge-elaborator]])
instantiated over the live-population B-referent ([[decision-b-in-type]]: quarantine
in the signature, ordinary packaging, no privilege), per-runtime by self-similarity
— each runtime's configuration carries its own broker over its own population, and
**no global registry is expressible**. The internals reduce to *evidence-element
choices* (audit-reconcile as the load-bearing verify; freshness; attestation) plus
the counter-effect dispatch set. Dynamic grant/revoke stay (the [[live-environment]]
is the forcing function): a grant to a live node is a **port move over an existing
crossing**, whose protocol content is D6. Residue: pick the evidence elements; audit
the dump's four-part material (D13) for any job the elaborator framing cannot seat.

**Adhikara correspondence (D6): Adhikara is the capability-type discipline *lowered
onto a B channel*,** not a sibling protocol needing agreement. The upper face is
*exactly* the type operations — the four grant ops, crossings, property-certificate
presentation, alarm signalling: a closed, enumerable message space. Below it, the
lowering connector with **"translation preserves-or-reduces rights"** as its
preserve-check ([[joining-law]]); confidentiality and integrity come from the
bridge's confine-outbound / verify-inbound (the wire is B). **Zero-trust completion
(author-settled): no foreign agreement is ever load-bearing for safety** —
exactly-once and no-forge are local linear accounting + `derive-not-store` at the
authority's home membrane; a comms failure costs *progress only* (in-doubt grants
discharged by local expiry/re-key counter-effects); hostile revocation is
stop-deriving, the peer never consulted. Rendezvous/acks demote to liveness
engineering (edge 14's wire coupling softens accordingly). Enumerated choice left to
E61: home-referenced authority vs offline-verifiable attenuation chains — both
zero-trust-clean. See [[open-edges]] edges 7/8.
