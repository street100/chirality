---
node: category-typed
layer: category
refines: [axis-typeability]
implements: [modules-core, modules-security]
related: [category-untyped, category-bridge, modules-lowering, decision-profiles]
status: draft
updated: 2026-09-03
---

# Category A: typed

The region where correctness rests on a proof and one copy is correct because it
is proven. Principles P1 through P4, tier T0.

## What lives here

The language proper. The kernel calculus and the typed IR, the type system, the
effect and graded cost machinery, totality, the surface syntax, and typed
reflection. The blocking security properties (information flow, taint, constant
time) live here too: they are proof properties, not evidence properties. See
[[modules-core]] and [[modules-security]].

## The port set

A program cannot enumerate its own outputs, which is undecidable. It can
enumerate the finite, named ways it affects anything outside itself: I/O, the
capabilities it holds, the time and space it spends. Those are the ports. The
port set is closed and profile invariant. Modules compose ports into
capabilities; a [[decision-profiles|profile]] selects modules, never ports.

## Why A is mostly borrowing

A good typed core is well trodden. Quantitative Type Theory gives linearity,
dependency, and erasure from one small calculus, which is the concrete mechanism
for P2 (everything is a process with a typed cost). The novelty budget here is
low and that is fine. The hard, original work is next door in
[[category-bridge]].

## The handoff to C

A may never accept a value derived from B except as a value that has already
passed through [[category-bridge]] and been turned into evidence (verified,
divergence checked, MAC confirmed). And A may never emit a value into B except
confined: encrypted if it must not be read, carrying no live capability, its
exposure window bounded. The bridge runs both ways, verify inbound and confine
outbound. It is P3's membrane crossing, applied to integrity on the way in and to
confidentiality and capability containment on the way out, not only to I/O.

## Preserved downward

Everything in A must survive lowering. The typed assembly floor is still A at the
bottom. See [[axis-altitude]] and [[modules-lowering]].
