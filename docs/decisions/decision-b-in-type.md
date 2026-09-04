---
node: decision-b-in-type
layer: decision
related: [category-untyped, modules-substrate, modules-lowering]
status: settled
updated: 2026-09-03
---

# Decision: B lives in the type, not the packaging

## The contradiction

The dumps say a hardware interface is a normal module, not special (dump A15).
The frame says category B is a set of named, quarantined holes. Is hardware
special or not.

## The decision

Both, at different levels.

At the packaging level the dumps are right. A hardware module is written,
versioned, composed, and replaced like any other module. There is no privileged
syntax for the hardware stuff. That is P2, no exemption: the hardware module is a
process with a type like everything else.

At the type level it is special, and the specialness must live in the type. The
module's signature declares its untyped referent, carries the ports that say it
crosses to ungoverned substrate, and so forces every use through a category C
supervisor. The quarantine is the signature.

Stated as one rule: hardware modules are normal in their packaging and special in
their type. B is a type level category realized as an ordinary module whose
signature names its untyped referent and routes it through C.

## Why this resolves it

The failure to avoid is a module that touches DMA while presenting a light, pure
looking type. That is the thesis's gap, the same shape as a regex that looks pure
and still pins a core. "Not special" is correct about composition and dangerous
only if it is taken to mean "not specially typed." The type makes it special; the
packaging keeps it normal.

## Principle basis

P2 (the type carries the weight, no exemption) and P3 (the membrane is where
governance happens; here the membrane is the signature).

## Connection to the floor

CHERI makes the type level B mark enforceable at the bottom, so the membrane
declared in the signature is also real in silicon. Without it the mark is checked
above tal; with it the mark is checked to the metal. This is an additive layer,
not a requirement. See the cheri floor in [[modules-lowering]].
