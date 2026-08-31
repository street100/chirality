---
node: decision-profiles
layer: decision
related: [category-typed, modules-core, splitting-law, joining-law, open-edges]
status: settled
updated: 2026-07-27
---

# Decision: profiles are additive module manifests over a fixed port set

## The contradiction

The dumps described profiles as subtractive composition: a permissive profile
drops discipline (for example chirality-app drops capability and linearity). That
collides with govern-the-ports. If a profile drops a guarantee, then a crossing
from the permissive profile to a strict one must re establish exactly what was
dropped, and the dumps never said who discharges that.

## The decision

A profile is, first, a named set of modules required to achieve a target (be an
OS substrate, be an app, be firmware, be bare metal). The surface ergonomics
follow from which modules are present; they are a consequence, not the
definition.

The port set is profile invariant. Every profile sees the same finite set of
typed ports. A profile selects modules; modules compose ports into capabilities;
a profile never adds or removes a port.

Profiles are additive toward a target, not subtractive from a maximal language.
There is no full Chirality you strip down. You compose up to the modules a goal
needs. chirality-bare is not app minus features; it is the minimal module set that is
a verified substrate, which happens to be small.

## Why this resolves it

Once profiles are additive, nothing is ever dropped from the substrate, so there
is nothing to re establish at a boundary. A cross profile boundary is a re
render, not a re prove. A value carries its real, full type across regardless of
which surface rendered it. The contradiction stops being expressible.

Where a permissive profile appears to allow something a strict one forbids (for
example partiality), that permission is still a port in the type, flipped from
loud opt in to quiet default. The cost gradient's zero point moves; the port set
does not.

## Principle basis

P3 (the port set is the governance surface) and P5 (the safe shape is the cheap,
default shape). It is also modularity as conformance: a profile conforms to the
frozen port set rather than configuring it away.

## A profile is modules plus connectors

A profile is not only a set of modules; it is the modules and the connectors that
string them toward the target. The splitting law gives the alphabet, the joining
law gives the grammar. See [[joining-law]].

## Consequence: profiles are testable

A profile is valid if and only if its module set's composite type covers the
target's requirements, every included module routes through the ports, and every
connection uses a preserving connector. This turns is chirality-systems enough to
host the broker into a checkable question. The specific module rosters per profile
are held loosely; derive them, do not assert them. See [[modules-core]],
[[joining-law]], and [[open-edges]].

## The conformance mechanism

The check above is type-checking, not a new analysis. Three objects make it so.

- Requirement type. A target (be an OS substrate, host the broker, be firmware) is
  a typed spec: the ports a runtime for it must offer, the effects it must
  support, the properties it must guarantee.
- Composite type. The type of the runtime the profile stages. A profile selects
  modules and connectors, staging assembles them into a runtime, a runtime is a
  process, a process is its type. So the composite is not a new object; it is the
  type of the node the profile builds. See [[process-and-runtime]].
- Conformance. The profile fits the target if and only if its composite type
  satisfies the requirement type: at least those ports, at least those effects,
  the demanded guarantees. Satisfaction is a subtyping relation in the existing
  type system, which is why validity is checkable rather than a slogan. One
  sequencing note: [[modules-core]] defers the subtype feature to a later slice,
  so conformance checking needs at least that much subtyping machinery to land
  before it is mechanized. Not a contradiction, an ordering constraint.

So profile validity is three reused checks: connections use preserving connectors
([[joining-law]]), every module's substrate access routes through a port
([[decision-b-in-type]]), and the composite type satisfies the requirement type. A
profile thereby becomes a typed object, valid for exactly the targets whose
requirement type its composite satisfies.

## Whole-assembly conformance: three classes (D4, settled 2026-07-27)

Which target properties are compositional was docket D4 (edge 18), resolved in
direction 2026-07-22 and settled here. There is **no global mechanism and no one
answer** — a dynamically-staged mesh never presents "the whole assembly" as an
analyzable object (runtimes stage runtimes at runtime; no vantage point holds the
composite). So a target property lands in one of **three classes**, handled per-seam
by the existing connectors:

1. **Signature-compositional** — carried in module/port signatures, discharged by
   **subtyping at the seam** (a structural demand like "offers port X"). The cheap
   default.
2. **Node-local at single-node stage time** — the only place a *closed* composite
   exists. The built `(total)` clause is this class: `chirality verify` demands every
   def in the composite be proven total, at the one node where the composite is
   closed.
3. **A named gap** — genuinely non-compositional, held at its honest rung per
   [[split-role]]'s "do what you can, named." Not faked, not silently dropped.

Cross-node property claims ride the bridge as **certificate evidence elements over
Adhikara** (couples D6 / [[decision-brokers]]). Tier-weight specifically lands
*inside* this shape by leg — containment class 1, independence class 2, verdict
riding independence (the [[banks/profile]] depth; its carrier is element E74). The
active discipline is **default-attempt**: when a goal composes two concepts not yet
proven together, a proof is attempted unless known impossible ([[certificate-discipline]]);
the open part is only *which interaction proofs are cheap subtyping vs need a
dedicated argument*, not whether they are attempted. Residue: the per-property
catalogue (which element, which rung — chirality-verify totality first) and the
tier-weight composition *arithmetic* (unbuilt). See [[open-edges]] edge 18.
