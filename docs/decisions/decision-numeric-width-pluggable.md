---
node: decision-numeric-width-pluggable
layer: decision
status: DIRECTION-SET (broader-project TODO — not yet scoped into elements)
decided: 2026-08-10
related: [decision-graded-kernel, banks/memory, modules-lowering, open-edges, floor-agreement]
---

# Decision — numeric width is a moduleset-configured conformance axis

**Status: DIRECTION SET (2026-08-10). Broader-project TODO. NOT current work,
NOT yet scoped into catalog elements. This doc reserves the direction so it is
not lost and so nothing is built that silently re-hardcodes 64-bit.**

## The decision

The integer **word-width is pluggable**, configured per **moduleset** as a named,
conformant **NumProfile** — exactly the way memory disciplines and codegen
backends are already configured. `I64` is the **default profile**, *not* the
floor. A moduleset for a 32-bit target selects an `i32` profile; an 8-bit target
selects `i8`; etc.

This **supersedes** the earlier framing (also 2026-08-10, retracted) that "I64 is
the fixed source-level floor and width only flexes at the backend." That framing
was the P4 cop-out in disguise: a single baked-in choice pretending to be neutral.

## Why (this is the chirality-native answer, not a compromise)

- **P4 — modularity = conformance, not configuration; "general-purpose" is a
  cop-out.** A hardcoded I64 floor *is* the cop-out. Width-as-a-named-profile is
  the frozen-base + named-testable-profiles pattern applied to the numeric layer.
- **Consistency with the existing seams** — same shape as the memory-discipline
  modulesets ([[memory]]) and the two-axis module architecture /
  modular `Mach` backend. Width becomes a *first-class conformance axis*, not a
  hidden backend detail.
- **Required by the vision** — a substrate that runs the "view-anything" system on
  small/ancient/embedded hardware (8-bit … 64-bit) as **named profiles of one
  base**, not as forks. "Push invariants into the substrate."

## What a `NumProfile` fixes (each an instance; I64 is one)

- the width **W**;
- `wrapW` and Euclidean div/mod **at that width** (the [[floor-agreement]]
  three-floor agreement re-parameterized over W, not hardcoded to 2^63/2^64);
- the value/cell **slot size** (today 8-byte slots → W-byte slots);
- the refinement engine's **bounds** (today the I64 constant-bound fragment → over W);
- which **codegen** arms fire (per-width `Mach` lowering).

## Scope (cross-cutting — why it's a thread, not an edit)

Touches: numeric semantics (`impl_pure` / kernel / fold / native agreement), the
value + cell/pointer model, the refinement engine, every backend, and the Rocq
external-spec model (`rocq/Chirality/I64.v` becomes the **`i64` instance** of a
width-parameterized model). Real design-doc → element(s) work.

## Open for the design pass (do NOT resolve here)

- Does a `NumProfile` carry only width, or also signedness / overflow behavior /
  endianness? (Probably a small bundle, but decide deliberately.)
- Relation to `Bytes`/pointer width and the arena slot size.
- **Mono-profile program vs. multiple coexisting widths** (i.e. does this also
  deliver first-class fixed-width *types* `i8`/`i32`/… usable together, or is a
  program compiled against exactly one profile?). This is the biggest fork.
- Migration: how the current I64-hardcoded sites become the `i64` profile without
  regressing the fixpoint.

## Next

A dedicated design pass after the in-flight terminal pipeline (E99→E103/E104)
lands — then a decision-doc refinement + catalog element(s). Tracked as an open
edge; not on the current worklist.
