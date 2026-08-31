---
node: joining-law
layer: foundation
refines: [splitting-law]
related: [splitting-law, axis-typeability, axis-altitude, category-bridge, modules-lowering, modules-staging, decision-profiles, module-map, open-edges, floor-agreement]
status: draft
updated: 2026-07-26
---

# The joining law

The dual of the [[splitting-law]]. The splitting law decides where one module
ends. This decides how two modules reconnect once cut. On its own the splitting
law is half a theory: it says where to cut and never how to join.

## Statement

Modules connect only through a typed connector, and a connector is valid only if
it preserves the invariant the split exposed. There are four connectors, one per
direction you can compose. Each is defined by the one thing it must preserve, and
that thing is the principle the boundary protects.

| Connector | Direction | Preserves | Failure mode | Defined in |
|---|---|---|---|---|
| bridge | across typeability, both ways between A and B | inbound, a B referent enters A only as evidence (verify); outbound, an A value enters B only confined (encrypt, contain capability, bound exposure) | a raw B value into A, or a secret or capability leaked into B | [[category-bridge]] |
| lowering | across altitude, upper down to the metal | the type, preserved and checked down to tal | an untyped bottom above tal | [[modules-lowering]] |
| staging | across stage, one binding time to the next | semantics: a residual computes what its source would | a specialization that changes behavior | [[modules-staging]] |
| port-composition | within one category | the port set: compose ports into capabilities, add or drop none | a synthesized or dropped port | [[decision-profiles]] |

## Why it follows from the principles

The splitting law cuts on the type (P2): two forms with different types are
different modules. A cut separates an invariant across the seam. Reconnecting has
to carry that invariant across, or the join reopens the thesis's gap exactly
where the cut was made. So each connector preserves one invariant, and each
invariant is one principle.

- bridge preserves the thesis across the proof boundary, both ways (P1, P5).
  Inbound, no untrusted path leads from B into A; outbound, nothing secret or
  authority-bearing leaks from A into B.
- lowering preserves the type downward, the no untyped bottom rule. See
  [[axis-altitude]]. Type preservation is not value preservation: that every
  executor of tal computes what the reference interpreter would is a separate
  invariant, [[floor-agreement]].
- staging preserves the meaning of a process across binding time (P2). A process
  is its type, and the type is stable under the stage it runs at.
- port-composition preserves the closed port set (P3). The governance surface
  does not grow or shrink when modules compose.

**Each invariant is discharged by one `preserve-check`, a certificate re-checker
([[certificate-discipline]]), and they split by type-vs-semantic — which is also
the build-state line** ([[open-edges]] edges 12/13, shaped 2026-07-25):

- **Built (structural):** lowering → the generic `preserve-check` over `translate`;
  port-composition → the frozen-port-set check (`verify_profiles`, ENFORCED). Each
  preserves a *type* / a *set*, mechanically checkable.
- **Open (semantic):** bridge → `bridge-preserve-check` "a B referent enters A only
  as evidence" (its *inbound* half; the *outbound* half — "nothing secret or
  authority-bearing leaks A→B", above — is the outbound-confinement obligation,
  docket D8); staging → semantics-preservation across binding time (the succession
  wall, edge 5 / E45). Each preserves a *semantic*, harder to state than a type.

This is why **completeness (edge 13) and statability (edge 12) are one question**:
each connector is one principle-invariant with one certificate re-checker, so the
four are complete iff they cover the principle-boundaries a P2 type-cut can expose
(they do, one per principle), and the only remaining *work* is stating the two
semantic checks — not finding a fifth connector.

## The dual of the twin pattern

The splitting law produces twins: a proof twin in A, an evidence twin in C,
sometimes a bare referent in B. The joining law reconnects them. A twin pair is
rejoined by the connector that fits the boundary between its halves. The A and C
twins of a governance concept are rejoined by the bridge. The upper and lower
faces of one module are rejoined by lowering. The same concept across stages is
rejoined by staging.

## A profile is modules plus connectors

A [[decision-profiles|profile]] is a named set of modules and the connectors that
string them toward a target. The splitting law gives the alphabet, the modules.
The joining law gives the grammar, the connections. A profile is valid if and
only if every connection uses a preserving connector and the composite type
covers the target's requirements. This is the testable form of modularity as
conformance, not configuration: you conform to the connectors, you do not wire
freely.

## When evidence from one source is not enough

The bridge connector turns a B referent into evidence. Where even a single
evidence source cannot be trusted, the floor the verifier itself runs on, the
bridge works by redundancy: hold several independent copies and require them to
agree, divergence is the alarm (P5). The bootstrap floor is that case. It is
governed not as one trusted blob but as a set of tuned runtimes, each a staged
compiler residual, cross-checked. That moves the floor from a bare B hole to a C
governed set and shrinks the trusted base to the register root plus the agreement
mechanism. The internals of that set, how many, how independent they really are,
how they relate to the `runtime` supervisor, are open — narrowed 2026-07-22 to
a budget call on which provenance axes are bought versus asserted-and-named
(edge 11). See [[open-edges]], [[modules-staging]], and the bootstrap floor in
[[module-map]].

The checker is *not* the same case. It cannot prove itself, but it can be proven
against an external spec, so it is held by certificate, not by redundancy: a small
trusted core re-checks untrusted producers' derivations ([[decision-split-checker]],
[[certificate-discipline]]). The boundary is provability. Redundancy is for the
genuinely-unprovable residue only, and where it is used, independence is the
load-bearing requirement, made checkable as typed provenance-disjointness in
[[split-role]].

## The bridge connector is one general elaborator

The bridge is not written per referent. Like lowering, which is one `translate`
plus a generic `preserve-check` ([[modules-lowering]]), the bridge is one general
elaborator parameterized by a target A-type and an evidence element (K-of-N, a MAC,
an attestation, a reconcile), with a `bridge-preserve-check` discharging "a B
referent enters A only as evidence" generically. Per-referent bridges are the
anti-pattern; the reusable unit is the evidence element. See
[[decision-bridge-elaborator]].
