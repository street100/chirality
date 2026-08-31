---
node: node-architecture
layer: foundation
refines: [thesis]
related: [process-and-runtime, axis-typeability, modules-broker, modules-bridges, modules-substrate, modules-custody, joining-law, perspectives, open-edges, decision-split-checker, certificate-discipline]
status: draft
updated: 2026-07-25
---

# Node architecture

How the whole system is shaped. Code runs in nodes, and nodes touch only through
typed ports. That is the architecture. Everything people expect from an OS and do
not find here, a kernel, an owner, a manager, is absent not by a rule that forbids
it but because there is nowhere for it to be. There are only nodes and ports.

## The two nouns

- A node is a process at the scale of a participant in the running graph, a
  compiler-plus-runtime bundle. See [[process-and-runtime]].
- A port is a typed crossing in a node's membrane, the only way it touches
  anything outside itself. See [[perspectives]] and [[vocabulary]].

Define the system by these two and the absences stop needing to be stated. No
kernel, because mediation is not a place. Nothing owns the substrate, because
ownership is not one of the two nouns.

## Not kernel-centric

The root difference from the usual model: authority is not a runtime entity behind
a privilege boundary, it is a property of a port's type, settled when the code was
staged. The rest are corollaries.

- Mediation. Usual: a place you call into, the syscall, where the kernel decides
  at runtime. Here: nothing to call into, the type was already checked. Complete
  mediation with no mediator.
- Trust in state. Usual: one privileged copy is authoritative, the kernel's table
  is the truth. Here: several copies, trust by agreement not privilege, divergence
  is the alarm (P5).
- Unit of authority. Usual: which ring you are in, who you are. Here: which ports
  you hold, what you possess. Capability, not class.
- What runs. Usual: a passive program the kernel schedules, the compiler a
  separate earlier tool. Here: a self-similar compiler-plus-runtime bundle that
  stages more of itself.

The nearest prior art is seL4, and the contrast is sharp. seL4 is a small
capability core, but it is a kernel: one privileged verified artifact that checks
capabilities at runtime on every invocation. It concentrates trust. Here trust is
distributed across the cross-checked floor and the register root, the check is in
the port's type at stage time, and modularity is the type discipline, not a
component framework on a kernel.

The one place trust could still concentrate is the checker that settles those
stage-time types. It is a small trusted core (a derivation checker over the audited
spec, climbing toward machine-verified) surrounded by untrusted producers that emit
certificates it re-checks ([[decision-split-checker]], [[certificate-discipline]]).
Trust does not vanish, it shrinks to the audited spec and that small core, and the
evolving bulk around it is trusted for nothing. "Complete mediation with no mediator"
holds in the sense that no large privileged artifact mediates, not that the trusted
core reaches zero.

## The substrate is owned by nothing

A device, a span of RAM, is B, raw, just there (see [[modules-substrate]]).
Nothing owns it. No memory manager, no arbiter. Governance is in the port's
construction: a port is typed so the thing you must not do is not expressible
through it, checked at stage time, so at runtime there is no permission asking. A
port with no gap has no ungoverned path. This is the thesis applied to access.

## State is many truths, reconciled

There is no single source of truth that something owns. State is held as several
cross-checked truths, and the active things are typed processes that carry the
communication between them and raise the alarm on divergence (P5). Managing
state is reconciliation, not ownership and not arbitration. The C bridges
(custody, redundancy, datum-policy, audit-reconcile) are these processes. See
[[modules-custody]] and [[modules-bridges]].

## Ports are where the logic lives

A port is not a hole you pass through. It is a typed contract carrying whatever
governance the job needs, checked at stage time. So a hardware question collapses
to one question: what logic does the port carry, and is its supply linear.

- A mass storage view is the type of the port over the raw blocks. There is no one
  filesystem that something owns; a block view, a log view, a key-value view are
  all port types over the same substrate, and they coexist.
- A resource limit is the bound in the port's type (P2, P3, `cost-typed`). Using
  more than the bound does not type-check. The limit is structural, in the port,
  not an allocator saying no at runtime.

The seam: a single port carries its own bound, not the global sum. Conservation
comes from the port supply being linear. You can only mint a port against real
finite capacity, so the total handed out cannot outrun the hardware. Conservation
by linearity, not by an accountant.

## Hardware access is decentralized

A node reaches a device by holding a port to it, through that node's own typed
bridge. No central owner serializes access. Where two nodes would touch the same
substrate and structure can forbid it, linearity forbids it: an exclusive port is
a linear resource, held by one node at a time and moved, not owned. Where
structure cannot forbid it, DMA writing past every check, you do not forbid, you
detect: many truths, divergence is the alarm. Whether detect-and-reconcile
suffices for every device class was **shaped 2026-07-25** ([[open-edges]] edge
15): it turns on the **reversibility of the effect**. Read-back substrate (a
secret in RAM) closes the loop — a diverged read is caught inbound and a
counter-effect re-derives, so it **suffices**. An irreversible effect (a committed
disk write, a network send) degrades to **detect-and-account**: you name and
reconcile your own state but cannot undo the external effect — the honest limit,
and structurally the same outbound-confinement gap ([[banks/port]] Shard 5 / E44)
edges 14/17/2 surfaced. See [[open-edges]].

## Distribution is native

A remote node is just a node you hold a port to. The port works the same whether
the other node is on this CPU or across the mesh, and Adhikara carries the
capability over the wire (see [[modules-broker]]). Distribution is not a layer
added on top; nodes are distribution-native, which is why "across silicon, kernel,
language, component, network" in Adhikara's scope is one protocol, the port
protocol between nodes wherever they sit. This is what resolves the old network
gap.

## The handhold

When the two nouns feel too thin, picture living tissue, not a computer. Each cell
is a complete bundle carrying its own machinery, not a client of a central organ.
Things cross a cell's membrane only through the channels the membrane is built
with, and the build is the gate; no manager waves them through. No cell is in
charge. State that matters is kept redundantly and compared. Cells divide, which
is staging. P4 already calls the crossing the membrane, so the image is the
principle, not an import. The picture is a handhold; the definition is the two
nouns.
