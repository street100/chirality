---
node: arc-<name>
layer: navigation
related: [arcs/README, goals/<name>, status-ledger, index]
status: current
updated: <YYYY-MM-DD>
---

# Arc: <name>

- goals: [[goals/<name>]], condition <N>: "<the condition, quoted>"
- reserved element block: `E<a>-E<b>` per [[decisions/decision-lane-split]], or
  `none`, with the arc-local id scheme this arc spells
- build-state authority: [[status-ledger]]
- checklist: [[records/<name>]]

## Why this arc exists

<The goal condition and what it takes to hold. Two paragraphs at most.>

## What the tree already holds

Measured, bank first. [[banks/INDEX]] holds twelve.

| group | what exists today | where | rung |
|---|---|---|---|
| <group> | <shard> | `file:line` | DESIGNED / SEEDED / IMPLEMENTED / ENFORCED |

## What is missing, and its structure

| group | owns |
|---|---|
| <G1> | <one line> |

### The edges that run against the order

<An ordering with no stated back-edges reads as a build sequence, and reading it
that way is usually wrong.>

| edge | direction | what crosses |
|---|---|---|
| <Gn> -> <Gm> | against the numbering | <what> |

## REQUIREMENTS

Numbered, six or fewer, each checkable with its observation beside it.

1. **<requirement>.** <What would be observed.>

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `<arc>/<id>` | <one line> | <G> | primitive/law/port/decision/tool | new/bind/connect | <N> | open | `unminted` |

### Coverage

<Every requirement named by a row, every row naming a requirement, every
`origin` defensible from the section above. State the result.>

## Resume state

<Where a session picks up, what blocks it, what was measured, with dates.>
