---
node: decision-work-ids
layer: decision
related: [arcs/README, elements/README, goals/README, records/README, working-discipline, decision-lane-split, index]
status: settled
updated: 2026-09-01
---

# Decision: an arc names its work before the work has a number

**Settled 2026-09-01 by author directive.**

## The problem

`E#` is the only citable unit of work in this tree, and minting one needs a
reserved band. ⚑ **That sentence states the problem as it stood and is no longer
the rule, noted 2026-09-24.** [[decisions/decision-lane-split]] carries the
author's 2026-09-06 overlap ruling, *"an arc with no band still mints. It takes
the next free number"*, and `tools/pack/pack.py --mint` implements it: minting
`E201` on 2026-09-24 printed *"band E184-E189 is full; taking the next number
free tree-wide"*. Read the rest of this file under the later ruling. `docs/decisions/decision-lane-split.md` reserves two bands and
nothing else, so five arcs of eight cannot mint an element. Their work writes
`UNASSIGNED`, which is anonymous: it cannot be cited, counted, given a state, or
pointed at from another document.

That leaves the tree naming far more work than it can schedule. The naming is
correct and the scheduling is what is missing, so the honest record of what this
project intends to build is spread through arc prose, bank shards and record
rows with no handle on any of it.

Measured 2026-09-01, by `ledger-lint` check V: `baseline-alignment`,
`binary-split`, `presentability`, `text-tools` and `zero-python` all write
`UNASSIGNED` rows and hold no block. They serve two of the five in-flight goals.

## What the tree already does

`docs/arcs/text-tools-arc.md` solved this locally without saying so. It carries
four rows called `P1` through `P4`. `P1` maps to `E173`, which is minted. `P2`,
`P3` and `P4` map to nothing. All four are cited by name from the arc's own
coverage table, which reads `needs P1`, `needs P1, P2` and `needs P3` against
the classic tools each composition would yield.

Those citations work today. Nothing formalises them, so no other arc has them
and no check knows they exist.

## The proposal

**An arc holds rows with arc-local ids, and a row maps to an element or to
nothing.**

| field | |
|---|---|
| id | arc-local and stable, cited as `<arc>/<id>` such as `text-tools/P2` |
| title | one line |
| state | what is true of it now |
| element | the `E#` it was minted as, or `unminted` |

Promotion assigns an `E#` and **the local id does not change**, so every citation
made before the number existed survives the number arriving. That invariant is
already written down for a different tier in `records/README.md`: *"Never
renumber a row that already exists. Its ID is cited elsewhere."*

## Why this does not break the deferral rule

[[working-discipline]] forbids deferring work to an `E#` that has not been
minted, because an unminted `E#` reads as scheduled work and is not. The reason
is about what the reader concludes from the form.

An arc-local id claims identification. It says this arc has named this piece of
work and can point at it. It does not claim a place in a band, a catalog row, a
ledger row or a pipeline stage, and `unminted` in the element field says so on
every row that has no number.

So the deferral rule keeps its whole force over `E#`, and the tree gains a way
to write down what it intends without inventing a number to hold it.

## What it buys

- Every goal can list its arcs with a state note, because an arc with no band
  still has rows.
- Every arc cites its own work by name, so a requirement, a bank shard or a
  record row can point at a specific piece rather than at a paragraph.
- Work is documented while a band is still an open author call, which is the
  current blocker on five arcs.
- Promotion becomes a mapping change in one cell rather than a rewrite, and no
  citation anywhere else moves.

## The three details, settled

**The id alphabet is the arc's own.** One letter naming the kind of work, then a
number from 1. `text-tools` keeps `P` for primitive.
`records/baseline-alignment.md` keeps `BA`, which it already used for exactly
this and which is the second place the tree invented this pattern by itself.

| arc | letter | |
|---|---|---|
| `text-tools` | `P` | primitive |
| `zero-python` | `T` | tool |
| `presentability` | `D` | document |
| `binary-split` | `B` | binary |
| `baseline-alignment` | `BA` | the existing record rows, reused rather than duplicated |

**One list, with an element column.** An arc with a band holds minted and
unminted work at once, and splitting them into two lists hides that the same arc
owns both. The element cell carries the `E#` or `unminted`.

**A row's state is a short phrase.** The four rungs in [[status-ledger]] measure
what is built and reached; an unminted row usually has nothing on them, so
forcing it onto a rung would put it at DESIGNED and say less than a sentence
does. Build state stays with the ledger and does not move here.
