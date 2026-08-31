---
node: axis-typeability
layer: foundation
refines: [thesis]
related: [axis-altitude, category-typed, category-untyped, category-bridge, splitting-law]
status: draft
updated: 2026-06-16
---

# Axis 1: typeability

The first axis places a module by its relationship to proof. Every module is
exactly one of three kinds. This is a partition, not a spectrum. If a module
seems to be two kinds at once, it is not yet split (see [[splitting-law]]).

## The three kinds

- A, typed. Correctness rests on a proof. One copy is correct because it is
  proven. This is the region of P1 through P5 and tier T0. See
  [[category-typed]].
- B, untyped. A substrate that can violate any type from outside the language's
  reach: DMA, raw pointers, physical memory, foreign code across the ABI, the
  register root, bare hardware. No provable single source of truth exists here.
  These are named, quarantined holes. See [[category-untyped]].
- C, the supervisory bridge. The module is itself typed, but its referent is a B
  thing. Its job is to let A govern B by turning untypeable reality into
  checkable evidence: redundant copies that must agree, a verifiable split, a
  register anchored MAC, an attestation, an audit reconciliation. This is the
  region of P6 and P7, tiers T1 and T3. See [[category-bridge]].

## The test

For any module, ask one question: what does its correctness rest on.

- On proof, with one copy correct: A.
- On being an admitted hole the language cannot type: B.
- On cross checked evidence about a hole: C.

## The tier ladder is this axis

Principle 7's tiers map onto the axis directly.

- T0, a typed singleton, is A. One copy is correct because it is proven.
- T1 (copies compared) and T3 (verifiable split) are C. Evidence catches
  divergence.
- T2 (plain Shamir, no tamper evidence) is the warning case. It looks like C but
  delivers only A's secrecy without C's integrity.
- The shares and replicas themselves live in B.

So the three way split and the tier ladder are the same structure read two ways:
proof, quarantined substrate, evidence over substrate.

## Why C is the center of gravity

A is mostly a borrowing problem. A good typed core with effects and graded cost
is well trodden in prior art. B is a discipline problem: keep it small, named,
and routed through C. C is where Chirality earns its existence. Every Bhumi custody
ceremony today is category C built by hand in Rust. Making C cheap and
declarative is the work.
