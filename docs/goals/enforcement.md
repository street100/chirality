---
node: goal-enforcement
layer: navigation
related: [goals/README, arcs/enforcement-arc, status-ledger, testing-floors, index]
status: current
updated: 2026-09-01
---

# Goal: what is built is gated, and what the compiler claims it checks

## The claim, and where the project makes it

- [[status-ledger]] ranks every capability on four rungs. They measure reach:
  DESIGNED, SEEDED (nothing calls it), IMPLEMENTED (reached but ungated),
  ENFORCED (gated).
- `PRINCIPLES.md` §3: crossing the membrane is where computation becomes
  checkable and mediated, and that crossing is the type-check.
- `MAP.md:86`: the `ports/` rule is structural and could be a gate. Today it is
  prose, and prose is how three files got into the wrong directory.
- `README.md`, Honest limits: three capabilities are built and reach nothing.

## What done means

A capability sits at ENFORCED or its ledger row says why it does not. A claim
the compiler makes about its own work is carried as a value with evidence, and
refused when it does not hold. Every gate row has a named mutant that is
actually run.

## State

In flight. The named gaps, from `README.md` Honest limits and
[[records/enforcement-arc]]:

- The effect membrane's three refusing rules are in the tree and nothing calls
  them. E171, unbuilt.
- The typed-assembly floor is built and unadopted. Neither the floor checker nor
  the optimizer's re-check runs in the shipping compile.
- Inbound entry-point verification is cut with no successor in this tree.
- Attribution of a def's fate cannot be measured today. E184, minted 2026-09-01.

## Arcs

[[arcs/enforcement-arc]].

## Honest limits

Every rung in the ledger is enforcement against error. An adversary who controls
the source is out of its reach, because [[goals/independent-judgment]] is
unbuilt.
