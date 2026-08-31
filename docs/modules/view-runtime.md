---
node: view-runtime
layer: view
related: [index, perspectives, process-and-runtime, node-architecture, bootstrap-sequence, modules-staging, modules-broker, decision-brokers, permission-model, error-and-alarm, time-and-clocks, joining-law, modules-substrate, open-edges]
status: draft
updated: 2026-07-04
---

# View: the runtime seat

The whole system read from one seat: the operator asking what a live chirality system
is, what is actually running, and what happens when things go wrong. Everything
here is restated from the linked notes; on any conflict, the notes win. For the
other seats, see [[perspectives]] and [[index]].

## One construct at every scale

What is running is one construct, seen at different sizes. A process is the typed
unit of computation (P2), and a running system is a process too: a configuration
of modules wired by connectors, staged live. That live thing is a runtime, and a
runtime is built of processes. The atom, the configuration, the runtime, the
whole system are the same type discipline at different scales, cascading, each
level managing the one below. There is no separate engine underneath your program;
there is only the construct, recursively. See [[process-and-runtime]].

## From off to self hosting

The intuitive way in is to watch one come up. See [[bootstrap-sequence]].

- Off. No language, no runtime, nothing.
- Power on. The master secret is established in registers, a key schedule computed
  in register and never written to RAM. This is the base of all trust, the one
  location the in scope threat cannot reach. See `register-root` in
  [[modules-substrate]] and the secure datum model. The pre-IOMMU boot window is a
  named honest limit, not covered by the CPU and RAM only model.
- The floor. The smallest set of tuned runtimes comes up and is cross checked,
  each a staged compiler residual. Trust bottoms out at the register root plus the
  agreement mechanism comparing them. See [[joining-law]].
- The cascade. The floor stages the next configuration. Each runtime is a compiler,
  so it can stage further runtimes. The cascade climbs, runtimes managing runtimes.
- The endgoal. A self managing, self hosting system that expresses its own kernel,
  compiler, and runtime (P1), self modification bounded by the reflective floor.
  An aim, not a built artifact.

## Nodes and ports, no kernel

The live population is nodes: each a compiler-plus-runtime bundle, a peer, and
nodes touch only through typed ports. There is no central kernel, no owner, no
manager, not by prohibition but because there is nowhere for one to be. Mediation
is not a place: authority is a property of a port's type, settled when the code
was staged, so at runtime there is no permission asking. The substrate, a device
or a span of RAM, is owned by nothing; governance is in the port's construction,
built so the thing you must not do is not expressible through it. See
[[node-architecture]].

## Birth and death are staging

Spawn is staging a residual: partial evaluation specializes a configuration into
a live process at a binding time. Teardown is consuming it, linear and use once.
There is no separate runtime compiler; runtime compilation is the one staged
compiler invoked at a later stage. The staging connector's preserved invariant is
semantics: a residual computes what its source would. See [[modules-staging]] and
[[joining-law]].

## The two brokers

At runtime, most of what a broker would do has already disappeared. The emergent
broker is compile time port mediation dissolved into the type check; it has no
runtime entity. What remains live is the component broker: the supervisor of the
irreducibly dynamic, lifecycle (spawn and teardown), dynamic grant and revoke,
audit reconciliation against live state. Its referent is the set of running
processes. Both halves speak Adhikara, the capability protocol whose invariants
are checkable: monotonic attenuation, no spontaneous rights, revocation
transitivity, translation preserves or reduces rights. See [[decision-brokers]]
and [[modules-broker]].

## A live crossing

A crossing between modules or profiles is permitted by agreement, not by an owner.
The process brings a grant, a held port in its active role, and the bridges the
crossing traverses verify against it: copies compared, a verifiable split, a
register anchored MAC, an attestation, an audit trail reconciled against live
state. Agreement permits the crossing; divergence is the alarm. Authority is
stratified by altitude, operations up high and resources at the metal, and a guard
on an operation must lower into constraints on the resource access it entails, or
the guard is theater. See [[permission-model]].

## Distribution is native

A remote node is just a node you hold a port to. The port works the same whether
the other node is on this CPU or across the mesh, and Adhikara carries the
capability over the wire. Distribution is not a layer added on top; it is native,
the old network gap resolved rather than a layer. See [[node-architecture]]; the
G8 framing is in [[open-edges]].

## When things go wrong

A detected divergence is raised as a typed effect in the same port and effect
algebra as everything else, named in the type and total: code cannot drop an alarm
without the drop showing in its type. The alarm is rich because everything is
split; the matching logic runs over the full cross checked set, so it carries what
diverged from what, which copy, which share, which MAC, which audit line. The
response is a counter effect drawn from a named set: re-key, re-derive from the
register root, relocate, repair from survivors, quarantine, halt. Recoverable or
fatal is in the type. See [[error-and-alarm]].

## Time, three ways

Time is three things at this seat, not one. Time you spend is a proven budget in
the type, fuel, not a clock reading. Time you are told is an untrusted B reading
made into evidence by reconciling against the register anchored monotonic counter;
a rollback shows as divergence, which is an alarm. Time you must act by is a bound
whose expiry fires a counter effect, and the runtime schedules those. See
[[time-and-clocks]].

## The hardware is finite

A port is a claim backed by linear supply. You can only mint a port against real
finite capacity, so the total handed out cannot outrun the hardware: conservation
by linearity, not by an accountant. An exclusive port is a linear resource, held
by one node at a time and moved. Real RAM, real devices, real cycles bound the
live population structurally. See [[node-architecture]].

## What this seat cannot yet see

Several runtime questions are open, recorded in [[open-edges]] and not resolved
here; the ones this seat touches most:

- Edge 14: what a live port between two running processes is, synchronous or
  asynchronous, message passing or shared handle, whether linearity rules out data
  races by construction.
- Edge 11: the bootstrap floor internals, how many tuned runtimes, how independent
  they really are, how they relate to the `runtime` supervisor.
- Edge 8: the component broker's internal AUTH and AUDIT decomposition and how it
  handles spawn and teardown as first class events. The broker section above
  presents its live role, not its internals.
- Edge 15: whether detect-and-reconcile suffices for every device class, not just a
  secret in RAM.
- Edge 17: cross-node alarm propagation, how loud a divergence in one node is to
  the nodes holding ports to it.
- Edge 19: cross-node ordering, causality and happens-before across the mesh,
  which the three single machine senses of time do not cover.
- Edge 20: the register-anchored counter this seat's time section relies on clears
  on power loss; rollback-proof persistence needs hardware.
