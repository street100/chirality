---
node: goal-honest-claims
layer: navigation
related: [goals/README, arcs/baseline-alignment-arc, records/README, records/baseline-alignment, index]
status: current
updated: 2026-09-01
---

# Goal: what this repo says about itself matches what the tree does

## The claim, and where the project makes it

- `README.md:60` carries a standing `Honest limits` section, and every principle
  in `PRINCIPLES.md` carries its own. The form is the commitment.
- `CLAUDE.md`: *"Report failures with their output. Name skipped work. Say
  `done` only when a gate ran."*
- `CLAUDE.md`: a subcommand dispatching to a floor this tree lacks is a gate that
  cannot fail. The same rule reads on documents.
- [[records/README]]: a checklist row is a claim this repo makes about itself
  beside what was measured.

## What done means

Every claim a tracked document makes is either measured and matching, or carries
a row saying it does not. A gate that cannot fail is repaired or deleted. The
author's framing, 2026-09-01: work to actually align with the goals we claim,
since apparently we do not.

## State

In flight. `records/baseline-alignment.md` holds 23 rows measured
2026-09-01. Four gates were found unable to fail; two are repaired.

## Arcs

[[arcs/baseline-alignment-arc]]. The checklist is the finding list. The arc is
the work.

## Honest limits

- `python3 tools/ledger-lint/ledger-lint.py` exits 1 today on checks A, G, I, R
  and T.
- Two ledger-lint checks are VACUOUS by decision: their subjects are gone. They
  are named rather than counted clean.
- 294 doc citations name a path that does not exist, and 161 bare `:NN` spans
  have no subject a check can name. Both are recorded and neither is repointed,
  because a check aimed at a guess passes by looking at nothing.
