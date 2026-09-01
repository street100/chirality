---
node: goals
layer: navigation
related: [index, arcs/README, records/README, status-ledger, open-edges]
status: current
updated: 2026-09-01
---

# Goals

Three tiers organise the work.

| tier | what it is | where it lives |
|---|---|---|
| goal | a broad thing this project claims it is doing | `docs/goals/` |
| arc | the list of elements that serve one goal, with its requirements | `docs/arcs/` |
| element | one catalog item, an `E#` | `docs/elements/`, `.planning/SELF-IMPLEMENT-CATALOG.md` |

A goal file says what the goal claims, cites where the project claims it, names
the arcs that serve it, and states what `done` means. An arc file names the goal
it serves. An element belongs to exactly one arc.

Every goal below is derived from text already in the repo. The citation is in
the goal file. A goal nobody has written down does not go here: it goes in the
arc's `goal` field as `UNWRITTEN`, and it is an author call.

## The goals

| goal | state | arcs |
|---|---|---|
| [[goals/self-hosting]] | held since 2026-08-05, maintained by the BUILD RULE | none open |
| [[goals/self-tooling]] | in flight | [[arcs/zero-python-arc]] |
| [[goals/readable-surface]] | in flight | [[arcs/diagnostics-arc]], [[arcs/file-types-arc]] |
| [[goals/presentability]] | in flight | [[arcs/baseline-alignment-arc]], [[arcs/presentability-arc]], [[arcs/binary-split-arc]] |
| [[goals/enforcement]] | in flight | [[arcs/enforcement-arc]] |
| [[goals/independent-judgment]] | stated, unbuilt, **zero arcs** | none |
| [[goals/ownership-and-trust]] | deferred out of scope 2026-08-31 | none, by decision |

`independent-judgment` is a stated goal with no arc and no element. `README.md`
lists it under Honest limits and `CLAUDE.md` states the replacement criterion.
Nothing in the tree works toward it.

[[goals/presentability]] and [[goals/readable-surface]] are author calls rather
than derivations from existing text, and say so in their own first section.

## Rules

- A goal file is written once and audited. It does not track status. Build state
  is [[status-ledger]]; measurement residue is [[records/README]].
- Adding a goal means citing where the project already claims it. Authoring a
  new ambition is an author call.
- Changing what a goal claims changes what its arcs are for, so it is a decision
  and belongs in `docs/decisions/` first.
