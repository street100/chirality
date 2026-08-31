---
node: insp-capability-os
layer: application
related: [live-environment, insp-erlang-beam, node-architecture, permission-model, category-typed]
status: draft
updated: 2026-07-20
---

# Capability operating systems

KeyKOS, EROS, seL4, and Genode built operating systems with no ambient authority:
a program can affect only what it holds a capability for, and it can reach nothing
it was not explicitly handed. There is no global namespace to name a resource you
were not given. seL4 went further and proved its kernel correct, making the
containment a theorem rather than a hope.

**Lights up:** the security half of the mesh invariant of [[live-environment]].
Ports are capabilities, there is no central kernel with ambient reach, and blast
radius is bounded by construction rather than by policy.

**chirality takes:** capability-as-the-only-authority ([[node-architecture]],
[[permission-model]]), deny-by-default meaning everything because the surface is
closed (P1, P3), and the ambition that containment is proven, not asserted.

**chirality differs:** these kernels manage capabilities over largely untyped
programs, with the capability discipline living in the kernel. chirality carries the
capability in the *type* of the port, so the object-capability check and the
type-check are the same act ([[category-typed]]), and the whole thing is
self-hosted rather than a fixed C kernel under foreign code.
