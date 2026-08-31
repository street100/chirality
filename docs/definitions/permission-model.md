---
node: permission-model
layer: foundation
refines: [node-architecture, category-bridge]
related: [node-architecture, category-bridge, axis-altitude, joining-law, modules-custody, modules-substrate, modules-core, modules-broker, modules-lowering, time-and-clocks, decision-profiles, error-and-alarm, open-edges, banks/capability]
status: draft
updated: 2026-07-23
---

# Permission model

> **Status: partly DESIGNED.** Of the four grant operations only *Move*
> (linearity) is ENFORCED in the scaffold; the E40 secret-custody slice CONFORMS
> as seeded. Attenuate is present-but-unapplied: the checker's subtype mechanism
> is IMPLEMENTED but not yet wired to grant narrowing. Delegate, Revoke, the
> broker's grant/revoke/audit (E43), the capability port, and the grant/sidehand
> are design; adhikara over the wire is E61. The claim below that "everything
> that does the work already exists" holds in the type theory, not yet in code.
> See [[status-ledger]].

How authority is held and how a crossing is permitted. Nothing here is a new
mechanism. It applies [[node-architecture]] (nodes touch only through typed ports,
nothing owns anything) and [[category-bridge]] (agreement across the proof seam) to
the question a manifest author actually asks: who may do what, and how is that
enforced with no owner. Depth tier: [[banks/capability]] — the shard-by-shard
refraction, cross-cuts, and build-state behind this note.

## A grant is an authority

A capability port is an authority. Holding it is the authority; there is no separate
permission record to consult. A grant, the sidehand, is what a process brings to a
crossing to authorize the thing it is trying to do. Because nothing owns anything, no
gate holds it and no owner adjudicates it. A grant does something only if it composes
with what the far side of the crossing holds.

## Authority is stratified by altitude

Authority is not one flat target set. It splits on [[axis-altitude|altitude]].

- At the metal, authority is over resources: a device, a span of RAM, a DMA ring, the
  register root. Broad, physical, no semantics. B substrate, see [[modules-substrate]].
- At the upper level, authority is over operations: a named command on a named datum.
  Semantic, typed, A.

A command is an act, not a target, and running it lowers to resource access. So a
guard on the command must lower into constraints on the access it entails, across the
[[joining-law|lowering connector]], or the access is ungoverned even though the
command was guarded. Guard the name, leave the resource open, and you have theater.
That is the thesis (P1, P3) at the altitude seam. The author works in operations,
where intent lives; the guarantee has to reach resources, where damage happens.

What discharges that obligation is machinery that already exists, not a new check.
The guard lives in the port's type. The lowering connector is type preserving, and
`preserve-check` proves each drop opened no hole ([[modules-lowering]]). So a guard
that survives lowering has, by that fact, become constraints on the resource access
the operation entails; a guard that could not survive lowering would be the hole
preserve-check rejects.

## Permission is agreement, which is the bridge

Inside a module, correctness is proof: one copy correct because proven, T0, A. A
crossing between modules or profiles is not proven across the seam, so it goes through
a [[joining-law|bridge]], and the bridge's inbound verify is a set of things that must
agree: copies compared, a verifiable split, a register-anchored MAC, an attestation,
an audit trail reconciled against live state. Agreement permits the crossing;
divergence is the alarm and fires a counter effect (P5, [[error-and-alarm]]).

So permission over a crossing is the result of a set of processes agreeing on that
crossing. Not a vote to design, not an arbiter to build. The set is the bridges the
crossing traverses, fixed by the crossing's type; each is a typed C module producing
evidence. The sidehand is what those bridges verify against. Nothing owns it because
agreement is evidence lining up, not privilege.

## A split is the same shape

A split value is a set of shares that must agree, K of N. Its threshold is the
agreement quorum. Its independence domains are the separate typed modules the shares
live in. Which tier applies, T1 or T3, and never the silent T2 where corruption
matters, is picked by the datum's classification — whether that rides as a per-value
annotation or as a classification carried in the type is open edge 4. So
a split needs no new derivation. It is [[modules-custody|custody-split]] parameterized
by the classification, and its agreement is the same bridge agreement as any other
crossing.

## What you can do with a grant

Four operations, none a new mechanism; each is an existing discipline applied to the
held port.

- Move. Transfer is linear and is the default. The port leaves one holder and arrives
  at another; it is never copied. This is the same linear supply that keeps exclusive
  grants from overlapping ([[node-architecture]]).
- Attenuate. Narrowing a grant is subtyping: the attenuated port's type is a subtype
  offering less, never more. Widening is not expressible.
- Delegate. Whether a holder may pass a grant on is itself an attenuable dimension of
  the port's type, narrowed like anything else.
- Revoke. Three shapes by how the grant is held. A linear grant is reclaimed, the move
  reversed. A scoped grant expires, its window a deadline whose expiry fires a counter
  effect ([[error-and-alarm]], [[time-and-clocks]]). Where evidence has been copied
  and cannot be recalled, revocation is re-key: derive-not-store means the next
  derivation excludes the revoked holder.

These are the port-type face of the Adhikara invariants ([[modules-broker]]:
monotonic attenuation, no spontaneous rights, revocation transitivity). That the two
layers must agree exactly is open edge 7 — resolved in direction 2026-07-22:
Adhikara is these operations lowered onto the wire, and safety (including
revocation against an uncooperative peer — stop deriving, the peer never
consulted) is enforced locally at each membrane, never by foreign agreement;
see [[open-edges]].

## What is actually new here

Two observations, neither a module. First, authority is stratified by altitude and a
guard must lower or it is theater. Second, the grant or sidehand is named and placed
in the agreement model. Everything that does the work already exists in the design —
**flagged as a stale overclaim** (CONFORMANCE-MAP:84) and re-confirmed by measurement
2026-08-22: of the capability bank's FOUR non-forgeability mechanisms, two are real in
the native compiler (porttype opacity; q=1 linearity — a `(1 f Fd)` used twice or
dropped is refused with `load: linear binder usage mismatch`), the **frozen port set is
Python-oracle-only** (`profile`/`target` are absent from `parse.chiral`), and the
reflective floor (E45) is unbuilt. The bank's own rule is that *pulling any one leaks*,
so the conjunction does not hold in the build path. See `.planning/AUTH-HARNESS-MAP.md`.
The sentence below is true of the type theory, not of the shipped compiler —
in the scaffold only Move's linearity is built (status banner above): the effect type
says what a crossing touches (`effects`, the port algebra, P3, [[modules-core]]),
`datum-policy` and `custody-split` weave the handling, the bridge is the agreement, G9
([[decision-profiles]]) is the conformance check, and the linear port supply keeps
grants from overlapping. An earlier version of this note invented a derive-then-verify
pipeline of new modules and an open edge for choosing a split's threshold. All of it
was reinvention of the above and was cut.
