---
node: goal-ownership-and-trust
layer: navigation
related: [goals/README, secure-datum-model, bootstrap, trust-boundary, index]
status: current
updated: 2026-09-01
---

# Goal: the ownership and trust model

## The claim, and where the project makes it

- `README.md`, Scope: *"The ownership and trust model is a separate track,
  deferred and built in its own lane: the re-bootstrap climb, DDC, the secure
  datum model, the register root, the cascade."*
- `PRINCIPLES.md` §5 and its rung table T0 through T3.
- [[secure-datum-model]], [[bootstrap]], [[trust-boundary]].

## What done means

Not stated in scope terms, because the track is deferred. The documents above
carry the design.

## State

**Deferred, by author call 2026-08-31.** Do not pull any of it into current
work, and do not audit its documents.

This file exists so the goal is visible without being worked. A deferred goal
with no entry reads as an abandoned one.

## Arcs

None, by decision.

## Open, and parked with the track

- The datum-model threat split: DMA write is in scope and CPU code execution is
  out, and on no-IOMMU hardware write subsumes execution.
- `docs/definitions/bootstrap.md` (the re-bootstrap climb) and
  `bootstrap-sequence.md` (the runtime on-ramp) are two unrelated concepts
  sharing a word. `bootstrap.md` cites three paths that are stale post-hoist:
  `scaffold/lib/climb.chiral`, `examples/refs/`, and `docs/tal-spec.md` (four
  times, as the golden object; it is `docs/definitions/tal-spec.md`).
