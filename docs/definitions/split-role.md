---
node: split-role
layer: application
related: [certificate-discipline, decision-split-checker, decision-profiles, modules-custody, permission-model, category-bridge, node-architecture, open-edges, thesis]
status: draft
updated: 2026-07-25
---

# The split as a substrate-provided role

Where a truth cannot be proven, you hold it as several independent sources that must
agree (P5). Hand-rolling that per module is easy once and does not scale, and
naive "N copies agree" is theater unless the copies are independent and contained.
This note makes the split a **typed role the substrate provides**, that any module
requires and consumes without implementing, with independence and containment
*checked*, not hoped. It realizes P5's "declaring a split should be as cheap as
declaring a variable" and answers open-edge 11.

## A role, not an implementation

A module that needs a split does not build one. It **declares a requirement** for a
`Split` provider ([[decision-profiles]]: a requirement type). The **profile must supply
a conforming provider** (the machinery — share, guarded combine, agree, alarm,
provenance-check — living in one place, generalizing `custody-split` in
[[modules-custody]]). The consuming module **uses the role** and cannot misuse it:
linearity means the only exit is the guarded combine, and divergence is a typed effect
it is forced to handle ([[permission-model]]). The machinery exists for any consumer by
construction; the profile guarantees it.

## Three legs, and how they couple

The split has three questions that are commonly conflated. Two are distinct typed
properties; the third rides on them, so they are not fully orthogonal, and saying so
honestly is part of the point.

- **Containment — what can a member do to the world?** Its typed **port set** (P3,
  [[node-architecture]]). A member computes anything internally and has no effect until
  it crosses a port, so a member holding no port but "take a share, emit a verdict, raise
  an alarm" cannot *overtly* exfiltrate the corpus — no egress port means no file or
  socket write — even if you cannot read it. But the verdict and alarm it does emit are
  themselves a channel it can modulate by timing or content, so *covert* exfiltration is
  not closed by ports; that is the constant-time and information-flow work (P3's own
  honest limit), a separate, higher tier. Tiers: port-bounded overt containment (the
  floor, always affordable) → covert-channel hardening → audited source → verified
  isolation.
- **Independence — can members fail together?** Typed **provenance-disjointness** in the
  combine. Each source carries a provenance vector (author, source language, toolchain,
  algorithm, hardware, time), and the combine's type requires the *declared* tags disjoint
  on the axes the threat names, so a syntactically-correlated split does not type-check.
  What the type enforces is *declared*-disjointness; whether the tags reflect reality is
  the attestation question (limits below), so real independence is that plus trustworthy
  tags. Tiers: asserted → hardware-attested → diverse authors and toolchains → formal
  argument.
- **Verdict — is a member's verdict right?** In split-role the property is unprovable
  (that is why you are splitting), so the verdict is **agreement**: no single member
  trusted, K-of-N. And agreement is only as good as independence — correlated agreement
  is theater — so this leg *rides on* the independence leg, it is not independent of it.
  Where a source *can* emit a certificate, the property was provable and it leaves the
  split for [[certificate-discipline]] entirely; certificate is the sibling tool, not a
  tier inside this role.

So honestly: two typed properties (containment, independence) plus a verdict-by-agreement
parasitic on independence. A member is a category-C bridge: B computation, reached through
typed ports, held as evidence ([[category-bridge]]).

## Tiering is the spine: do what you can, named

You do not max every axis everywhere. The requirement names a **minimum tier per axis**,
and a provider below it does not conform. Where you are *forced* below what you wanted,
the shortfall is a **visible typed gap**, not a silent hole (open-edge 4: the tier carried
in the type, so under-reaching is a type error). This is the honest form of "do what you
can":

> **Edge 4 resolved in direction here (2026-07-25).** This section *is* the answer to
> "what picks a value's default tier": not a per-value annotation but a type-carried
> classification auto-selecting the minimum rung per axis, defaulting high. The open
> residual is the concrete **tier carrier** (how a tier rides the type), which edges
> 17 (alarm-visibility tier) and 18 (tier-weight composition) also consume — one
> mechanism to mint once. See [[open-edges]] edges 4/17/18.


- **Use the tier you can reach.** Proprietary hardware, closed toolchains, libraries you
  cannot afford to replace are facts of finite resources, not failures. Seat them at their
  honest tier and **contain them at the floor** (ports), so a floor-tier proprietary blob
  cannot hurt more than floor-tier allows.
- **Name the tier, so you are never fooled.** A proprietary-contained member sits beside an
  audited one and the type says which is which. You always know where trust actually rests,
  and where you were forced below your intent.
- **Spend serious rigor where it is load-bearing.** Climb the rungs that matter; floor the
  rest, on purpose.

Two honest constraints on this, or it inverts its own principles. First, the minimum tier
per axis must **default high**, so safe is the frictionless default and lowering is the
loud opt-in (P4: the safe path is the cheap path). A low default would make insecurity the
path of least resistance while labelling it honestly, which is the exact shape P4 forbids.
Second, naming buys the *auditor* visibility and lets a *consumer* refuse a below-minimum
provider; it does not by itself deliver default security. The type detects unmet ambition
(a required minimum exceeding what is available becomes a gap) but not insufficient security
(a negligently low minimum type-checks cleanly, floor-tier blob inside). So "do what you
can, named" strengthens audit and consumer-side enforcement; it is not "the unsafe is
inexpressible," and the notes must not borrow that stronger claim by association.

## Honest limits

Provenance tags can lie; a trustworthy tag needs attestation (`attestation` in the C
bridges), which bottoms out at the register root like everything else. Some axes are
attestable (toolchain, author-identity), others only assertable (did two teams make the
same conceptual error — unprovable), so the type can *enforce* disjointness on the
attestable axes and only *demand-and-audit* it on the rest. And unknown shared causes
remain: provenance-typing makes independence checkable against the *named* axes, not
absolutely, the same seccomp logic as P1. The spec of what is being agreed on stays
common-mode; that is handled by minimality and certificates, not by more copies.

## Where this sits

This is the legitimate home of the split after the checker went to certificates
([[decision-split-checker]]): the bootstrap floor, hardware, foreign devices, solvers that
emit no proof, and differential testing as a development discipline. It is the redundancy
tool for the irreducible unprovable residue, provided once and required anywhere.
