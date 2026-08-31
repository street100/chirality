---
node: bootstrap-sequence
layer: foundation
refines: [process-and-runtime]
related: [process-and-runtime, modules-substrate, modules-staging, modules-broker, module-map, joining-law]
status: draft
updated: 2026-06-16
---

# The bootstrap sequence

The start process: a machine with no language, powered off, up to a running self
managing system. This is the most intuitive way to see the process model, even
though the true model is the self-similar one in [[process-and-runtime]]. Read
this as the on-ramp, then read that as the structure. The sequence is the cascade
run once, from the bottom.

## Off

No language. No runtime. Nothing. The starting point.

## Power on, and the register root

The machine starts. The master secret is established in registers at boot, a
passphrase turned into a key schedule computed in register and never written to
RAM (TRESOR style). This is the base of all trust, the one location the in scope
threat cannot reach. See `register-root` in [[modules-substrate]] and
[SECURE-DATUM-MODEL](secure-datum-model.md).

Honest limit: this is the pre-IOMMU boot window, where DMA is wide open. The
CPU and RAM only model does not cover it; closing it needs measured boot. The
window is named, not hidden. See the secure datum model.

## The bootstrap floor

The smallest set of tuned runtimes is brought up and cross checked, each a staged
compiler residual. Trust bottoms out here, at the register root plus the
agreement mechanism that compares the runtimes. This is the base case of the
cascade: the smallest thing that can check the next thing. See [[joining-law]]
and the bootstrap floor in [[module-map]].

## The cascade

The floor stages the next configuration. A runtime is a configuration of modules
and connectors, and because each runtime is a compiler it can stage further
runtimes. Spawn is staging a residual into a live process. Processes touch only
through ports. The cascade climbs: runtimes managing runtimes.

## The endgoal

A self managing, self hosting system. Every running thing is a process and a
runtime. Each piece of chirality code runs in its own configuration. The component
broker supervises the live population. The language expresses its own kernel,
compiler, and runtime (P1), and self modifying code is bounded by the reflective
floor. This is the aim, not a finished artifact; nothing here is built yet.
