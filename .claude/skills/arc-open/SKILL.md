---
name: arc-open
description: >-
  Open ONE arc for chirality: the goal condition it serves, what the tree already
  holds, the structure of what is missing, numbered checkable requirements, and a
  roster of arc-local rows that covers them. Writes docs/arcs/<name>-arc.md. Use
  when asked to "open an arc", "schedule a goal condition", "draw the roster", or
  before designing any row.
---

# arc-open: open one arc, with a roster that covers its requirements

Produce exactly **one** arc file per run, then **stop**. An arc is the work
assembled toward one goal condition, carrying the requirements that must hold
before it is done and the roster of rows that meet them.

This is a **planning run.** It writes `docs/arcs/<name>-arc.md` and adds that
arc's row to `docs/arcs/README.md`. It designs no row, mints no element, and
touches nothing under `lib/` or `prog/`.

## When to use

When a goal carries a done-condition that no arc schedules.
`docs/goals/README.md` lists which conditions hold an arc and which do not, and
each goal file names its own unopened conditions.

**Authoring a goal the project has never stated is forbidden.** If the ambition
has no goal file, the `goal-open` run comes first, or the arc's `goals:` field
reads `UNWRITTEN` and it stays open on an author call.

## Hard rule: one run = one arc

Exactly one arc file. Do not design a row, do not mint an element, do not open a
second arc. End by naming the arc path and its row count, then **STOP**.

## Cadence is serial

One stage at a time, one agent at a time.
`docs/decisions/decision-dispatch-cadence.md` is the authority.

## Step 1: get the input bundle (ONE command)

```
python3 tools/pack/pack.py --arc <name> --start
```

This prints the goal file and the condition being scheduled, the banks naming
this concept, the `docs/definitions/status-ledger.md` rungs in range, every
existing arc that overlaps, and the reserved element bands from
`docs/decisions/decision-lane-split.md`. `--start` is the write: it
**scaffolds** `docs/arcs/<name>-arc.md` with the section headers and the roster
table ready, and leaves an existing file as it is. Without `--start` the command
writes nothing.

**Read the overlapping arcs.** Two arcs owning one row is the collision this
stage exists to catch, and `docs/arcs/README.md` records that two sessions once
minted `E173` independently.

## Step 2: fill the arc (six sections, in order)

### 1. The header fields

```
- goals: [[goals/<name>]], condition <N>: <the condition, quoted>
- reserved element block: `E<a>-E<b>` per [[decisions/decision-lane-split]], or
  `none`, with the arc-local id scheme this arc spells
- build-state authority: [[status-ledger]]
- checklist: [[records/<arc>]] where one exists
```

An arc with no reserved band carries arc-local rows per
`docs/decisions/decision-work-ids.md` and says which letter it uses. Check V of
`ledger-lint` fails an arc holding neither a band nor a scheme.

### 2. Why this arc exists

The goal condition, quoted, and what it takes to hold. Two paragraphs at most.

### 3. What the tree already holds

**Measured, and the bank comes first.** `docs/banks/INDEX.md` holds twelve. A
feature that is one thing elsewhere is here a sum of shards, each in its own
home, usually mostly built. Naming a phantom feature is the cardinal working
error in this repository.

A table: the group, and what exists today, cited at `file:line` with its ledger
rung. A count or a size appears only when something was measured. If a shard is
written and reached by nothing, say so and give the rung.

### 4. What is missing, and its structure

**A flat list of gaps is what makes an arc thin.** The gap has a shape and this
section carries it:

- **the groups**, in dependency order, each with one line saying what it owns;
- **the edges that run against that order.** An ordering with no stated
  back-edges reads as a build sequence, and reading it that way is usually
  wrong. `.planning/AI-LANE-GAP.md` names two such edges over eight layers, and
  they are what stop the ordering being read as a schedule.

### 5. REQUIREMENTS

Numbered. Each one checkable. **A requirement with no way to observe it is a
wish.** State the observation beside it: the gate that would fail, the count
that would move, the file that would exist.

Six or fewer. A requirement list that enumerates the roster is the roster
written twice.

### 6. The roster

One row per unit of work, ids arc-local and stable per
`docs/decisions/decision-work-ids.md`. **The id never changes when the row
mints**, so every citation made before the number existed survives it.

| column | holds |
|---|---|
| `row` | `<arc>/<id>`, the citable name |
| `what` | one line, specific enough that two people would build the same thing |
| `group` | which group of §4 |
| `kind` | `primitive` · `law` · `port` · `decision` · `tool` |
| `origin` | `new` · `bind` (a thing exists and needs a surface) · `connect` (two built things need joining) |
| `req` | the numbered §5 requirements this row serves |
| `state` | `open` · `designed` · `minted` · `specced` · `building` · `built` · `closed` |
| `element` | the `E#` once minted, or `unminted` |

### The coverage check, and it is what makes the arc detailed

Run it before finishing, and write the result into the arc:

- **every requirement in §5 is named by at least one row's `req`.** A
  requirement no row serves is unscheduled, and the arc is claiming a
  done-condition it has no plan for;
- **every row names at least one requirement.** A row serving none is out of
  scope, or §5 is missing a requirement;
- **every row's `origin` is defensible from §3.** A row marked `new` whose work
  §3 shows already built is the phantom-feature error, caught here rather than
  four stages later.

## Step 3: the README row

Add this arc to the table in `docs/arcs/README.md`: arc, goal, state, reserved
block. `ledger-lint` check V fails when that table and the arc file disagree.

## Done

- `docs/arcs/<name>-arc.md` filled, six sections, roster complete with every
  column.
- The coverage check run, its result written into the arc.
- The `docs/arcs/README.md` row added.
- No row designed, no element minted, nothing under `lib/` or `prog/` changed.
- `python3 tools/ledger-lint/ledger-lint.py` run, and the count compared against
  the run before.
- Final message: the arc path, the row count, the requirement count, and any
  requirement left uncovered. Stop.
