---
node: modules-substrate
layer: module
implements: [category-untyped]
related: [module-map, decision-b-in-type, modules-custody, modules-lowering]
status: draft
updated: 2026-06-16
---

# Substrate modules

Category B: the named, quarantined holes. Kept as a small set so that everything
else stays typed. Each is packaged like any other module but carries a type that
declares its untyped referent. See [[decision-b-in-type]].

## raw-mem

Physical memory and raw pointers, with no MMU in the path. The thing custody
holds evidence about rather than proof of.

## device and dma

Peripherals that write host memory directly, past every type and capability
check. The core threat in the secure datum model. A device can read and write
physical memory no matter what the program does, so software cannot prevent it;
it can only raise the cost. See [SECURE-DATUM-MODEL](../../SECURE-DATUM-MODEL.md).

## foreign

The far side of the FFI and the ABI: code the language cannot type. A foreign
type declaration is an admission of a B atom, not an A proof. It is untyped code
that runs, but it is not an untyped bottom of our stack; it is a B referent
orchestrated from outside. See [[axis-altitude]]. Use is routed through
`bridge-supervisor` in [[modules-bridges]], and the runtime is built with no port
to unwrapped foreign, so an unwrapped driver is not expressible.

## register-root

The master secret established at boot and held only in CPU registers, never
written to RAM. DMA reads memory but cannot read registers, so registers are the
one runtime root of trust against the in scope threat. Everything per datum is
derived from it on demand rather than stored. It is the one dependency every
custody layer shares, and it is the one thing the threat cannot reach. See
[[modules-custody]] and the secure datum model.

## Why these are not a separate language feature

They are ordinary modules. What makes them B is the type, which forces their use
through [[category-bridge]]. A B module that presented a light type while
touching the substrate would be the thesis's gap. The quarantine is the
signature, not a privilege.
