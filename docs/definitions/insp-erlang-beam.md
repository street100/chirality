---
node: insp-erlang-beam
layer: application
related: [live-environment, insp-capability-os, node-architecture, process-and-runtime, error-and-alarm]
status: draft
updated: 2026-07-20
---

# Erlang / BEAM

The single closest existing system to chirality's structure, and it is not an editor.
BEAM runs a mesh of isolated lightweight processes that share no memory and
communicate only by message passing. Failure is contained by supervision trees: a
crashing process is restarted by its supervisor, not allowed to corrupt its
neighbours. Code is hot-reloaded into the running mesh, so a live system is
modified without stopping, which is live self-modification of a mesh rather than
of an image.

**Lights up:** the mesh invariant of [[live-environment]]. Isolated processes,
message passing, crash containment, and liveness, all at once and all without a
single shared image.

**chirality takes:** the process mesh ([[node-architecture]]), message passing over
shared memory (a live port is a move, not an alias, [[process-and-runtime]]),
supervision as the shape of the alarm/counter-effect model ([[error-and-alarm]]),
and hot reload as the proof that a mesh can be modified live.

**chirality differs:** BEAM is dynamically typed and its processes hold roughly
ambient authority. chirality puts the authority and the cost in the type (the
port-check is the type-check), scopes each process to a frozen port set, and
self-hosts the floor. Erlang answered "how do you keep a mesh running forever";
chirality adds "and prove what each node in it may touch."
