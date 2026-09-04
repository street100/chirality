---
node: target-tomodachi
layer: target
related: [decision-profiles, open-edges, permission-model, time-and-clocks, node-architecture, error-and-alarm, modules-staging, category-bridge]
status: draft
updated: 2026-09-04
---

# Target: tomodachi

⚑ **Parked. No part of this has been verified against a compositor.** Measured 2026-09-03:
nothing under `tools/test/` reads `prog/demo/`, so `tomodachi.chiral`,
`profile-tomodachi.chiral` and `wl-client.chiral` are neither compiled nor run
by the suite, and none of them is a `compile-main` root that Phase 7 would
sweep. No environment in this tree hosts a Wayland compositor, so the wire
client has never spoken to one. Everything below states the requirement, which
is what a target note is for. None of it is a report of observed behaviour.
[[arcs/native-window-arc]] is unopened and re-measuring the demos is its first
row.

The first concrete target requirement type, per the conformance mechanism in
[[decision-profiles]] (G9). A desktop companion process for a Wayland session,
with user-swappable behavior reacting to compositor events (niri first). It is
chosen as the vertical-slice driver: it lands on the open edges the design says
to settle next, and it is small enough that a scaffold can run it before
self-hosting.

## Why this target

A companion is a long-running, mostly-idle, event-driven process on one machine.
That profile touches exactly the seams stage 2 names and nothing extra:

- Idle cost is the concrete case for the cost gradient (edge 3). The claim is
  structural: the process spends nothing between events because event-driven is
  in the type, not in the author's discipline. Existing desktop pets poll; this
  one cannot express polling cheaply.
- The Wayland wire protocol is a typestate port protocol nearly verbatim:
  objects with interfaces, requests, events, lifecycles, over a unix socket. The
  compositor is a foreign counterpart across a port, already governed (G7). No
  libwayland; the client speaks the wire format.
- A socket carrying an event stream plus request/reply sequences is the concrete
  case for edge 14 (agreement rendezvous and data transfer, one step or two).
- A behavior pack is user-supplied code confined by capability, installed
  through the staging connector, supervised by the broker. Customization is a
  typed module swap, the profile idea in miniature.
- One machine, no distribution, no rollback-critical secrets: edges 17, 19, 20
  stay untouched. Time use is the monotonic counter only, per
  [[time-and-clocks]]; the companion never reads a wall clock.

## The requirement type, in prose

Ports the target demands (each linear, per [[permission-model]] move-only):

- One stream port to the compositor socket (Wayland wire protocol), outbound
  requests and inbound events on one crossing, with fd-passing for the shared
  buffer.
- One stream port to the compositor IPC socket (niri: JSON lines, an event
  stream after one request).
- One shared-memory buffer supply (memfd pool), bounded, the only pixel path.
- One deadline port (monotonic, for idle and animation timing). No wall clock.
- Nothing else. No filesystem beyond the two sockets, no network, no exec.

Guarantees the composite must satisfy:

- Idle bound: between events the process performs no port operation and burns no
  fuel beyond the blocked wait. When the cost mechanism lands (edge 3) this
  becomes a graded bound in the type.
- Memory bound: the buffer supply carries its size in the port type.
- Behavior packs are typed modules with a fixed signature (event and mood in,
  mood out), hot-swappable, and confined: a pack holds no ports, so a malicious
  pack can compute but not reach anything (Principles 3 and 4).
- Alarm on divergence: a protocol violation from either socket is a typed alarm
  with a named counter effect (quarantine the stream, redraw from state), per
  [[error-and-alarm]].

Deliberate exclusions: GPU (a giant foreign blob that proves nothing shm does
not), network, persistence, audio, multi-seat.

## Status against the scaffold

The stage 9 scaffold was pulled forward (2026-07-05) as the execution vehicle so
this target runs before self-hosting. What the scaffold enforces today and what
it stubs is recorded in `scaffold/README.md`, not here — the pre-migration
tree, and that file has no successor in this one; this note is the
requirement, not the implementation. "Highly optimized" stays a typed claim
until a real backend (stage 5) exists to measure; no numbers before then.

The conformance mechanism this note assumes exists in part:
`prog/demo/profile-tomodachi.chiral` is the profile (import manifest plus a
`target` requirement type naming the crossings above), and `chirality check`
judges its shape, its port set and its target name (`handle-profile-body`,
`lib/surface/parse.chiral:960`), refusing a pure extern in the port set and an
unknown target. ⚑ **The subtyping half has no live implementation (measured
2026-09-04).** [[decision-profiles]] states conformance as type-checking, and
this sentence used to name `chirality verify` for it; that subcommand does not
exist and `bin/chirality` dispatches check / compile / run / test. Nothing in the
tree judges a target's `require` types against what the composite provides. The
one profile refusal that is live is the port-set one, `emit-elf-m` in
`lib/lowering/compile-emit.chiral:292` (H8, per-program, refusing at `:299`).

The memory bound is now typed (2026-07-05, [[memory-model]] pass): the pool
port type is value-indexed, the target requires the client to come up holding
exactly a `(Pool 16384)`, and the bridge verifies the size claim at the
crossing. Still not judgeable: offsets within the bound (refinement types,
deferred), the idle bound as a type (edge 3), and whole-assembly sums
(edge 18).
