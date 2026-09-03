---
node: decision-quorum-store
layer: decision
status: DECIDED
decided: 2026-09-03
related: [goals/native-stack, arcs/native-protocol-arc, banks/evidence-and-split, capability, decisions/decision-work-ids, records/author-calls, index]
updated: 2026-09-03
---

# Decision: crypto and Shamir serve a split source-of-truth store

**Set by the author 2026-09-03, in session.**

## The ruling

The kernel line exists to be composed hard, as the mechanics of a store where
nothing authoritative sits whole in one place. A value is sealed, split t of n
by Shamir sharing, distributed, and reconstructed only by quorum, and the
return track names disagreement as an outcome instead of an error.

PRINCIPLES.md 5 already states the doctrine for judgment: where proof runs
out, split the truth and require agreement. [[banks/evidence-and-split]] holds
that concept for category C. This decision applies the same shape to data at
rest, so the store is the principle's second instance and borrows nothing new.

## What follows

- **Primitives first.** One shared module carries the word ops, the LE codecs
  and the field arithmetic, and every kernel consumes it. A helper private to
  one kernel is the exception and carries a reason. The slice 1 helpers in
  `lib/crypto/chacha.chiral` migrate there when the module lands.
- **The entropy crossing moves ahead of the handshake.** Share generation and
  key generation are its consumers, so it stops being deferrable transport
  plumbing.
- **Shamir over GF(256) is a kernel beside the WireGuard suite.** Split,
  reconstruct, and the disagreement seed: reconstruction from two share
  subsets that fails to agree is a named observable, and a corrupted share is
  detected instead of silently absorbed.
- Rows `N6` to `N8` on [[arcs/native-protocol-arc]] carry the work.

## Left open

- Whether the store becomes its own arc once N8's design lands.
- The share verification scheme: plain Shamir first; verifiable secret
  sharing is residue and gets its own row rather than an unminted deferral.
- Quorum membership and transport binding live in N4 and N8 jointly; the
  seam between them is undrawn.
