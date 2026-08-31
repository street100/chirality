---
node: vocabulary
layer: navigation
related: [index, glossary, thesis, process-and-runtime, joining-law, axis-typeability, permission-model]
status: draft
updated: 2026-07-04
---

# Vocabulary

The source of truth for what each core term means. Each entry says what the term
is, what it is not, and what it replaced. The [[glossary]] is the quick index and
points here; when a usage elsewhere disagrees with this note, this note wins.

This base is developmental, so terms change. Renames in flight are listed under
Deprecated. A rename is not done until the sweep across the base is done; until
then both words may appear and this note records which is current.

This note pins what a term is. To see a construct from several angles at once,
builder, type, membrane, runtime, trust, hardware, graph, see [[perspectives]].
For the **full depth** of a concept — its refraction into shards, homes, and
build-state — see the depth-tier banks in [[banks/INDEX]].

## The word "type" did three jobs

The main confusion this note fixes. "type" was being used for three different
things. Only the first keeps the word.

1. type. The full proof-carrying signature of a process: its effects, the
   resources it spends, its tier weight, all of it (P2). This is the real type.
2. port. The outward-facing contract of a single boundary crossing. Do not call
   this a type. Call it a port.
3. port protocol. The state a crossing advances as data flows through it. Not a
   static type either. Call it the port protocol.

## Core terms

### type
Is: the full proof-carrying signature of a process, in the QTT sense (P2).
Is not: the contract of one crossing (that is a port), nor the runtime protocol
state (that is a port protocol).

### process
Is: the one unit of computation (P2). A function, a value, a statement are
special cases. Self-similar: run a configuration of processes and it is itself a
process. See [[process-and-runtime]].
Is not: an OS process specifically. That is one scale of the construct.

### runtime
Is: a process at the scale of a running system, a configuration of modules and
connectors staged live, itself built of processes.
Is not: a separate engine your program runs on. There is no privileged runtime
beneath everything.

### node
Is: a process-runtime seen as a participant in the communicating graph, a
compiler-plus-runtime bundle, a peer.
Is not: a kernel, a server, an owner, a manager. Those words import privilege and
centralization that do not exist here. Use node for the peer-in-the-graph view,
process or runtime for the self-similar-construct view.

### port
Is: a typed crossing in a process's membrane. The only way a process affects
anything outside itself. The outward-facing part of its type. Where the
governance logic lives. What P3 governs.
Is not: a plain type (it carries a protocol and state), nor an owned channel
(authority is holding the port, not owning the substrate behind it).
Replaces: door.

### port protocol
Is: the state a port advances as data flows through it, the typestate or session
aspect. This is the thing meant by "data gathered through the state of the type."
Note: whether ports are formally session-typed is an open mechanism decision, not
settled by this name. See [[open-edges]].

### membrane
Is: the outward boundary of a process. Compute is inert until it crosses it (P4).
Ports are the typed crossings in it.
Is not: a single point. It is the whole skin; ports are the holes.

### capability
Is: a port held. Authority is the set of ports you hold (P3).
Is not: a ring or a privilege class. There is no privilege here, only possession.

### grant (sidehand)
Is: a capability in its active role, what a process brings to a crossing to
authorize the action it attempts. Permitted by the bridge's agreement at the
crossing, not by an owner (P6, P7). See [[permission-model]].
Is not: a separate mechanism from a capability. A grant is a held port used at a
crossing; sidehand is the informal handle for that presented role.

### module
Is: a process with a type, packaged, versioned, composed, replaced. The unit the
[[splitting-law]] cuts and the [[joining-law]] connects.
Is not: a file or a topic. A module is individuated by its type, not its subject.

### connector
Is: a typed join between modules. The four are bridge, lowering, staging, and
port-composition. Each preserves one invariant. See [[joining-law]].
Is not: glue. A connector that preserves nothing is not a connector.

### substrate (category B)
Is: the raw, untyped reality the language cannot prove: devices, RAM, foreign
code, the register root. It just exists; nothing owns it. See
[[category-untyped]].
Is not: owned or managed. It is reached only through ports whose types forbid the
unsafe, and through evidence where proof runs out.

### evidence (category C)
Is: cross-checked truth about substrate (redundancy, verifiable split, MAC,
attestation, reconciliation). The bridge turns substrate into evidence a typed
process can check (P6). See [[category-bridge]].
Is not: proof. It is what you fall back on when proof runs out.

### tier, T0 to T3
Is: how a truth is held. T0 typed singleton (proof), T1 copies compared, T2 plain
Shamir (the warning case, no tamper evidence), T3 verifiable split. See P7 and
[[axis-typeability]].

## Deprecated

- door. Renamed to port. The sweep across the base is done (2026-06-16): the
  construct is `port` everywhere, the connector is `port-composition`, and P3 in
  PRINCIPLES reads "govern the ports." `door` survives only here as the historical
  name and as the ordinary English idiom "next door" in `category-typed`. If you
  find `door` meaning the construct anywhere else, it is a miss to fix.
