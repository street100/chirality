---
node: category-untyped
layer: category
refines: [axis-typeability]
implements: [modules-substrate]
related: [category-typed, category-bridge, decision-b-in-type, modules-lowering]
status: draft
updated: 2026-07-25
---

# Category B: untyped

The substrate that can violate any type from outside the language's reach. No
provable single source of truth exists here, so by P5 you do not try to prove
it. You quarantine it, name it, and route it through [[category-bridge]].

## What lives here

DMA capable peripherals, raw memory and pointers, the far side of the FFI, the
register root. These are named holes, kept as small a set as possible so that
everything else stays in [[category-typed]]. See [[modules-substrate]].

## The non-process boundary (edge 1)

This named-holes set *is* where pure description ends and untypeable substrate
begins ([[open-edges]] edge 1, shaped 2026-07-25). The A/B boundary is not a
fresh seam — it is the membrane, the `=>` crossing routed through
[[category-bridge]]. And type-level computation does **not** count as a process:
a process crosses (holds ports, exercises an effect row), while NbE / elaboration
/ checking / staging are pure (`->`, the empty row) and cross nothing, so they are
description, not process. "Is this a process?" is the same derived read as "is
this a port?" — does the type carry a `=>`. The one open sliver is a check-time
untyped-oracle call (a proofless solver): whether that puts a crossing into
elaboration's own effect row is undecided (edge 1 residual; [[split-role]],
[[certificate-discipline]]).

## B lives in the type, not the packaging

This is the settled point in [[decision-b-in-type]]. A hardware module is
packaged like any other module: written, versioned, composed, replaced. That is
P2, no exemption. What marks it as B is its type, not a special status. Its
signature declares the untyped referent, carries the ports that say it crosses to
ungoverned substrate, and so forces every use through a C supervisor.

The failure to avoid: a module that touches DMA while presenting a light, pure
looking type. That is the thesis's gap, the same shape as a regex that looks
pure and still pins a core. The type makes a B module special; the packaging
keeps it normal.

## Enforcing the mark downward

The type level B mark is checked above the typed assembly floor on every target.
Where the hardware exists, the CHERI floor enforces the same mark in silicon as
an additive layer, so the membrane declared in the signature is also real at the
metal. The mark holds with or without that hardware. See [[modules-lowering]] and
[SECURE-DATUM-MODEL](../../SECURE-DATUM-MODEL.md).

## Note on the dumps

The brainstorm dumps never define a B hole directly. Every untyped referent in
them appears only as something a C module supervises. The B vocabulary comes
from this spine and from the secure datum model, not from the dumps. See
[[dump-integration]].
