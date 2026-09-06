---
node: goal-ownership-and-trust
layer: navigation
related: [goals/README, arcs/ownership-and-trust-arc, secure-datum-model, bootstrap, trust-boundary, index]
status: current
updated: 2026-09-03
---

# Goal: the ownership and trust model

## The claim, and where the project makes it

- `docs/decisions/decision-scope.md`: the ownership and trust model is a
  separate track, deferred and built in its own lane, being the re-bootstrap
  climb, DDC, the secure datum model, the register root and the cascade.
- `PRINCIPLES.md` §5 and its rung table T0 through T3.
- [[secure-datum-model]], [[bootstrap]], [[trust-boundary]].

## What done means

**The track is deferred**, so these conditions state what done would mean if it
reopened. Every row in [[arcs/ownership-and-trust-arc]] is deferred by the same
author call, and the arc's coverage says so.

1. **A quorum has two legs of disjoint provenance.** Observed by
   `ddc-bad-quorum` firing on fewer than two live legs.
   [[arcs/ownership-and-trust-arc]] row `O1`.
2. **The golden object is settled.** The provisional ruling of E71, the kernel
   spec as the golden object with every executor first among executors, is
   confirmed or replaced. [[arcs/ownership-and-trust-arc]] row `O2`.
3. **The reference semantics is reached.** `lib/lowering/tal/spec.chiral` is
   imported by something on a shipping path. **No row serves this**, and the
   hole is enumerated as `GAP-08`. [[arcs/ownership-and-trust-arc]].
4. **The shipped artifact carries its own re-derivation**, with no trusted
   binary in the forever story. [[arcs/ownership-and-trust-arc]] row `O3`.

The documents above carry the design.

## State

**Deferred, by author call 2026-08-31.** Do not pull any of it into current
work, and do not audit its documents.

This file exists so the goal is visible without being worked. A deferred goal
with no entry reads as an abandoned one.

## Arcs

[[arcs/ownership-and-trust-arc]], opened 2026-09-02 and deferred whole. The
track's own sentence above points at three minted elements, `E53`, `E71` and
`E72`, and until now they had no place in the goal-arc-element chain to sit.
The arc holds them with the state each is actually in. Opening it schedules
nothing: every row says deferred and the arc's resume state says a session picks
it up nowhere.

## Honest limits

Parked with the track. Nothing below is being worked.

- The datum-model threat split: DMA write is in scope and CPU code execution is
  out, and on no-IOMMU hardware write subsumes execution.
- `docs/definitions/bootstrap.md` (the re-bootstrap climb) and
  `bootstrap-sequence.md` (the runtime on-ramp) are two unrelated concepts
  sharing a word. `bootstrap.md` cites three paths that are stale post-hoist:
  `scaffold/lib/climb.chiral`, `examples/refs/`, and `docs/tal-spec.md` (four
  times, as the golden object; it is `docs/definitions/tal-spec.md`).
