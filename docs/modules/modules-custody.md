---
node: modules-custody
layer: module
implements: [category-bridge]
supervises: [category-untyped]
related: [module-map, modules-security, modules-bridges, modules-substrate]
status: draft
updated: 2026-06-16
---

# Custody modules

> **Status: DESIGNED.** custody-split, redundancy, and datum-policy are unbuilt;
> this note is intent, not scaffold reality. See [[status-ledger]].

The part of [[category-bridge|C]] that holds sensitive state. This is P7 made
into modules: declaring a split should be as cheap as declaring a variable.

## custody-split

A split value whose only exit is a guarded combine process. Shares are move only
and zeroed on drop. Reconstruction is an effect. Verification is in the type.
This covers tiers T1 and T3. The T0 case (a typed singleton secret) is proof,
not evidence, so it lives in A as a linear value, not here. The plain Shamir case
T2 is the warning case: secrecy without tamper evidence, so anything where silent
corruption matters never sits at T2.

## redundancy

The T1 mechanism: several full copies that must agree, with divergence
detection. For the untypeable region, redundancy is the evidence you fall back on
when proof runs out (P6). Robust or verifiable decoding can correct some bad
copies and name them.

## datum-policy

The per datum security weaving. Each datum's type declares which layers apply:
confidential, register keyed, integrity by MAC or Merkle, versioned, clear window
bound, refresh interval, split k of n, constant time. The module weaves the
mechanism: derive in register, decrypt into a bounded window, verify against the
root, bump the version, re encrypt, relocate. The blocking typed properties it
weaves (information flow, taint, constant time) live in A, in
[[modules-security]]. The mechanism it produces is C.

The secure datum model is the threat model and layer stack this implements. See
[SECURE-DATUM-MODEL](../definitions/secure-datum-model.md). The register root it derives from
is a B module; see [[modules-substrate]].

## Why these are C and not A

Their referent is untyped memory that DMA can read and write. They cannot prove
the memory is intact; they can hold evidence that catches tampering. That is the
A to C handoff described in [[category-bridge]].
