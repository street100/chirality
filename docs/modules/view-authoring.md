---
node: view-authoring
layer: view
related: [index, perspectives, thesis, decision-profiles, permission-model, axis-altitude, node-architecture, modules-custody, modules-core, error-and-alarm, open-edges]
status: draft
updated: 2026-07-04
---

# View: authoring

The system read from one seat: the person writing a program, a manifest, or a
profile, asking what do I actually touch, what do I get for free, and what can I
never do. Everything here restates the linked notes; on conflict, the notes win.

## What you write

You write processes with types, and nothing else, because there is nothing else
(P2). A function, a value, a declaration are sugar over process (P2,
[[process-and-runtime]]). The surface that renders that sugar, and renders
profiles, may not drop linearity, capabilities, or effects, or the surface itself
becomes an ungoverned path. See [[modules-core]]. The
type is the entire truth about what your code can do: its effects, the time and
space it spends, its tier weight. A cost you did not declare does not type-check
as cheap. Your code is total by default; partiality is the marked opt in climb,
so the common case is provably terminating and unbounded recursion has to be
requested (P5). The lowest thing you can author is tal, the typed assembly floor,
still typed, still yours to write; below it is one trusted emission step you
never edit. See [[axis-altitude]] and [[modules-lowering]]. The `syntax` module names the surface
seat ([[modules-core]]); no concrete surface form is drawn anywhere in this base.

## What you never write

There is no owner, no manager, no privilege ring, no kernel to petition, and you
do not write one, because there is nowhere for it to be. The system is nodes and
ports, two nouns, and neither is a place authority sits behind. See
[[node-architecture]] and [[vocabulary]]. You never write a permission record:
holding a port is the authority, there is no separate table to maintain. You
never write the mediation: the port check is the type check, so the static
broker dissolves into type checking and only the irreducibly dynamic supervisor
remains, the component broker as a module ([[modules-broker]]), selected the way
a profile selects any module ([[decision-profiles]]).

## Profiles: you conform, you do not configure

A profile is a named set of modules plus the connectors that string them toward
a target: be an OS substrate, be an app, be firmware. It is additive. There is
no full Chirality you strip down; you compose up to what the goal needs. The port
set is profile invariant: every profile sees the same finite set of typed ports,
and a profile selects modules, never ports. Where a permissive profile appears
to allow something a strict one forbids, that permission is still a port in the
type, flipped from loud opt in to quiet default; the cost gradient's zero point
moves, the governance surface does not. See [[decision-profiles]]. A profile is
defined by its module set and connectors; no concrete manifest file format is
drawn anywhere in this base.

## Guards at the grain you care about

Authority is stratified by [[axis-altitude|altitude]]. At the metal it is over
resources: a device, a span of RAM, a DMA ring. Broad, physical, no semantics.
At the upper level it is over operations: a named command on a named datum. You
put the guard where your intent lives, and for most authoring that is the upper
level. The rule that makes this honest: a command is an act, not a target, and
running it lowers to resource access, so a guard on the operation must lower
into constraints on the access it entails, across the lowering connector, or the
access is ungoverned even though the command was guarded. Guard the name and
leave the resource open and you have theater. See [[permission-model]].

## How you get authority

You hold ports. A capability is a port held; authority is the set of ports you
hold, settled when the code was staged, not requested at runtime (P3). What you
bring to a crossing is the grant, the sidehand, and it is permitted by the
bridges the crossing traverses agreeing on it: copies compared, a verifiable
split, a register-anchored MAC, an attestation. Agreement permits, divergence is
the alarm. No owner adjudicates because agreement is evidence lining up, not
privilege (P6, P7). See [[permission-model]] and [[category-bridge]]. Ports are
minted from a linear supply against real finite capacity, so what you hold is
backed by real RAM, real devices, real cycles, and grants cannot overlap or
outrun the hardware. A remote node is just a node you hold a port to, so
distribution adds nothing to your authoring model. See [[node-architecture]].

## What the system owes you

The safe shape must be the cheap shape (P5), so the ceremony is the system's
job, not yours. Declaring a split should be as cheap as declaring a variable
(P7). For per-datum security you name the policy in the datum's type,
confidential, register keyed, integrity by MAC or Merkle, versioned, clear
window bound, refresh interval, split k of n, constant time, and `datum-policy`
weaves the mechanism: derive in register, decrypt into a bounded window, verify
against the root, re-encrypt, relocate. You name the policy, not the ceremony.
See [[modules-custody]] and [SECURE-DATUM-MODEL](../definitions/secure-datum-model.md).
The stronger shortcut is not settled: whether a classification carried in the
type auto selects the minimum tier, so forgetting to split a secret is a type
error rather than an oversight, is edge 4 in [[open-edges]]. Hardware is not a
special dialect either: a B module is packaged like any other module, written,
versioned, composed, replaced; what quarantines it is its signature, which names
the untyped referent and forces every use through a C bridge. See
[[decision-b-in-type]].

## What checking tells you

For a profile, validity is type checking, not a review. A target is a
requirement type: the ports a runtime for it must offer, the effects it must
support, the guarantees it must hold. Your profile's composite type is the type
of the runtime it stages. Conformance is the composite satisfying the
requirement, a subtyping check, plus two more reused checks: every connection
uses a preserving connector, every module's substrate access routes through a
port. This is G9 in [[decision-profiles]]. Which target properties are
compositional and which need a global analysis is edge 18 in [[open-edges]].

Many type errors here are an ungoverned path caught. That follows from the
[[thesis]]: anything the framework cannot name is ungoverned, so everything is
named, so a whole class of rejection is the checker finding a path to the world
your type did not admit. A pure looking signature over unbounded allocation, a B
referent entering typed code without passing the bridge, a secret headed for
DMA-readable RAM unconfined, a dropped alarm: each is that kind of rejection. At
runtime the analogue is the alarm, a typed effect you cannot silently drop,
carrying what diverged from what, with recoverable or fatal in the type. See
[[error-and-alarm]].

## Open edges at this seat

The edges an author will feel first, all in [[open-edges]]: edge 3, how the cost
gradient is mechanized; edge 4, what picks a value's default tier; edge 6, where
the tal vocabulary is drawn, since tal is human writable; edge 14, what a live
port between two running processes is; edge 16, the effect mechanism for alarms
and counter effects; edge 18, which conformance properties are compositional.
None are resolved here.
