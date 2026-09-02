---
node: goal-independent-judgment
layer: navigation
related: [goals/README, decision-self-verification, certificate-discipline, split-role, testing-floors, index]
status: current
updated: 2026-09-01
---

# Goal: judgment that does not rest on one formulation

## The claim, and where the project makes it

- `README.md`, Honest limits: *"External judgment is cut: the Rocq leg, the
  CompCert leg, the Python oracle. What replaces them is three semantically
  distinct judgment cores that must agree, and that is unbuilt."* So every rung
  in the ledger is enforcement against error.
- The criterion is **different formulations**. Three encodings of one rule set
  would be worth nothing, which is why a second target under one formulation was
  dropped rather than counted (`docs/elements/catalog.md`, E166).
- `docs/decisions/decision-self-verification.md` §0 records the call and what it
  rules out.
- `PRINCIPLES.md` §5: where proof runs out, split the truth and require
  agreement.

## What done means

N semantically distinct judgment cores, each a different formulation of the rule
set, run against the same input and required to agree. Disagreement is a
refusal. One formulation with two emitters does not count: that is what the
`Mach`-to-C backend was, and it was dropped on 2026-09-01 for that reason
(`d8bcec5`, `d0c5dd5`).

## State

Unbuilt. **This goal has zero arcs and zero elements.** No work in the tree
serves it.

Recording that is the point of the goals tier. The gap was visible only as a
line in `README.md`'s Honest limits, where it read as a caveat instead of as
unstarted work.

## Arcs

[[arcs/independent-judgment-arc]]. It carries no reserved element block and its
rows take arc-local ids `J1` and up, so it can be worked without one.

## Honest limits

- `bin/chirality` has no `test-rocq` and no `test-python` subcommand, on purpose.
  A subcommand dispatching to a floor this tree lacks is a gate that cannot fail.
- [[testing-floors]] still lists the cut external floors. That is
  `records/baseline-alignment.md` BA-08.
