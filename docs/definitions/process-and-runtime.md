---
node: process-and-runtime
layer: foundation
refines: [thesis]
related: [modules-core, modules-staging, modules-broker, bootstrap-sequence, splitting-law, joining-law, open-edges]
status: draft
updated: 2026-06-16
---

# Process and runtime

One construct, seen at every scale. This is P2 taken all the way: not only that a
function is a process, but that a running system is one too.

## The self-similar construct

A process is the typed unit of computation (P2). A function, a value, a statement
are special cases. Run a process and it is a configuration of modules wired by
connectors, staged into a live thing. That live thing is a runtime. A runtime is
built of processes. So the same construct appears at every scale: the atom, the
configuration, the runtime, the whole system. It cascades, each level managing
the one below.

The noun does not split. The atom and the runtime are not two different types
sharing a name; they are the same type discipline at two scales. By the
[[splitting-law]] the law does not fire, because there is one construct, not two.
What looked like an under split is intended recursion.

## Three things this gives

- Staging births a runtime. Each configuration is a staged residual, the staging
  connector in [[joining-law]]. Spawn is instantiate and stage; teardown is
  consume, linear and use once. This is the dump's factory of ephemeral runtimes
  reduced to staging, now the process model and not only the compiler. See
  [[modules-staging]].
- Ports connect runtimes. Concurrent processes share nothing except through typed
  ports (P3, P4). The concurrency model is the port model applied between
  processes: every interaction is a port crossing, typed and governed. The
  component broker (C) supervises the live population, the dynamic referent it
  always had. See [[modules-broker]].
- The cascade bottoms out. A runtime manages itself by being made of runtimes.
  The base case is the bootstrap floor: the register root plus the agreement
  mechanism. See [[bootstrap-sequence]] and [[open-edges]].

## What is still open

The structure is settled; the semantics of a live port is not. What a port
between two running processes is, synchronous or asynchronous, message passing or
shared handle, and whether linearity rules out data races by construction, no
aliasing so no shared mutable state so no race, or whether there is a shared
state story at all. Recorded in [[open-edges]].

## The intuitive way in

The recursion is the true model but not the easiest entry. The easiest entry is
to walk it from the start, from a powered off machine up to a running system. See
[[bootstrap-sequence]]. To see the construct under several lights at once, builder,
type, membrane, runtime, lifecycle, trust, hardware, graph, see [[perspectives]].
