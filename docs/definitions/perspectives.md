---
node: perspectives
layer: navigation
related: [vocabulary, glossary, index, process-and-runtime, joining-law, splitting-law, axis-typeability, decision-profiles, view-security, view-types, view-runtime, view-authoring, view-implementation]
status: draft
updated: 2026-09-03
---

# Perspectives

The core constructs, each under several lights. A construct stops blurring when
you stop forcing one definition to answer every question and instead pick the
light that fits the question. None of these are different things. Each is one
construct asked a different question.

This note is one of two cuts. Here, one construct under many lights. The
`view-*` notes are the transpose: the whole system under one light each,
[[view-security]], [[view-types]], [[view-runtime]], [[view-authoring]],
[[view-implementation]]. Pick this note to unblur a construct, a view note to
read the system from a seat.

## The lights

- builder: what it is made of, how you assemble one.
- type: what its signature says, whether it is safe.
- membrane: how it is governed, the boundary.
- runtime: what it is while running.
- lifecycle: where it came from, how it lives and ends.
- trust: why you can rely on it.
- hardware: what it costs, how it meets the metal.
- graph: how it connects to everything else.

Not every construct uses every light. Each entry uses the ones that illuminate it.

## process (node, runtime)

One self-similar construct, so every line holds at every scale: the atom, the
runtime, the whole system. See [[process-and-runtime]].

- builder: a set of modules wired by connectors, running a piece of code.
- type: its signature, whole. Every effect, cost, and port is in the type, and
  the type is the entire truth about what it can do.
- membrane: an interior of inert compute sealed by a skin; from outside it is
  nothing but its ports.
- runtime: a live compiler-plus-runtime bundle, a node, that stages more of
  itself and talks only through ports.
- lifecycle: a staged residual, specialized into existence at a binding time;
  spawn is staging it live, teardown is consuming it.
- trust: something the floor checked before it ran, plus the ports it holds;
  nothing it does was unverified, nothing it reaches was ungoverned.
- hardware: a claim on finite linear supply; its ports are backed by real RAM,
  real devices, real cycles, and cannot outrun the metal.
- graph: a node defined only by its edges, the ports connecting it to other nodes
  and to substrate. Cut its ports and nothing is left to point at.

## port

The outward-facing construct. See [[vocabulary]].

- builder: the outward slice of a process's type.
- type: a contract naming one crossing, the effect, capability, cost, or view it
  carries.
- membrane: the one place governance happens, a typed crossing in the skin, built
  so the unsafe is not expressible.
- runtime: a protocol with state, which data advances through (the port protocol).
- trust: settled at stage time; holding one is verified authority, not a runtime
  request.
- hardware: a claim backed by linear supply; a finite resource hands out finite
  ports.
- graph: an edge, between a node and another node or substrate.

## module

- builder: a process with a type, packaged, versioned, composed, replaced.
- type: individuated by its type. Same type shape, same module; a split that
  copies a type is spurious. See [[splitting-law]].
- membrane: its surface is the ports it offers.
- trust: a B module is quarantined by its type, which forces its use through a C
  bridge. The quarantine is the signature.
- graph: a vertex the [[splitting-law]] cuts and the [[joining-law]] connects.

## connector

- builder: the typed join between modules; four kinds, bridge, lowering, staging,
  port-composition. See [[joining-law]].
- type: each preserves exactly one invariant, and that invariant is one principle.
- membrane: the bridge connector is the membrane crossing for typeability,
  substrate to evidence to typed value.
- lifecycle: the staging connector births runtimes; its residuals are the tuned
  runtimes of the floor.
- graph: the edges of the module graph. Modules are the alphabet, connectors the
  grammar.

## category A, typed

- type: correctness rests on proof; one copy is correct because it is proven (T0).
- trust: you rely on it because it is proven, not because it is watched.
- builder: mostly borrowed prior art, a QTT core with effects and graded cost.
- membrane: the port-check is the type-check; ports here are pure proof.

## category B, substrate

- hardware: the raw metal, devices, RAM, foreign code, the register root. It just
  exists.
- type: its type declares it untyped; the quarantine is the signature, not a
  privilege.
- trust: you cannot prove it; you hold evidence about it.
- membrane: reached only through ports built to forbid the unsafe.
- graph: a leaf nothing owns.

## category C, bridge (evidence)

- trust: cross-checked evidence about substrate; divergence is the alarm.
- type: a typed module whose referent is a B thing.
- membrane: the bridge, substrate to evidence to typed value; a B value enters A
  only as evidence.
- builder: the novel work, custody ceremonies made cheap and
  declarative.
- runtime: a supervisor reconciling several truths.

## capability

- membrane: authority is the set of ports you hold; a capability is a port held.
- trust: possession, not privilege. There is no ring, only what you hold.
- graph: an edge you carry, grantable and revocable through Adhikara.

## profile

- builder: a set of modules and the connectors that string them toward a target.
- type: valid iff the composite type covers the target and every connection
  preserves. See [[decision-profiles]].
- conformance: you conform to the frozen port set, you do not configure it away.

## tier (T0 to T3)

- trust: how strongly a truth is held, from proof (T0) to verifiable split (T3).
- hardware: T1 and T3 are copies and shares living in B; the shares themselves
  are substrate.
- security: which of secrecy, integrity, availability you buy; name the tier you
  mean. See P5.
