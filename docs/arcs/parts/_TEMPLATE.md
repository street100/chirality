---
row: <arc>/<id>
arc: <arc>
title: <human title>
kind: primitive | law | port | decision | tool
origin: new | bind | connect
req: <the numbered arc requirements this row serves>
status: draft
updated: <YYYY-MM-DD>
---

# <arc>/<id>: <human title>

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** <one line, what must become true>.
- **Serves:** requirement <N> of [[arcs/<arc>-arc]], "<the requirement, quoted>".
- **Goal:** [[goals/<name>]], condition <N>.

## 2. What the tree holds

Measured. The bank comes first: a feature that is one thing elsewhere is here a
sum of shards, each in its own home, usually mostly built.

- **Bank:** [[banks/<name>]], <the refraction, and which shards touch this row.
  If the concept has no bank, say so and build one before continuing>.

| what exists | where | rung | reached by |
|---|---|---|---|
| <shard> | `file:line` | DESIGNED / SEEDED / IMPLEMENTED / ENFORCED | <what calls it, or nothing> |

## 3. The delta

<What is missing once §2 is subtracted. Not a restatement of §1.>

**Verdict:** <a real delta, or `closed`>.

> An empty delta is a real result and the most valuable one this stage produces.
> If §2 finds the work built, say so here, write `closed by §3` into §4 and §5,
> mint nothing, and name the shards that cover it.

## 4. The shapes

<At least two candidate forms, unless the tree settles it.>

### Shape A: <name>
- **Form:** <what it looks like>
- **Costs:** <what it spends>
- **Forbids:** <what it makes impossible, and whether that is wanted>

### Shape B: <name>
- …

**Or, the tree settles it:** <the citation showing the shape is forced. The row
is `direct`: it mints and goes to implement with no SPEC, because the defect is
the blueprint.>

## 5. The call

- **Chosen:** <Shape X>, because <the reason>.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | <q> | RESOLVED / DEFERRED(row or minted E#) / NEEDS-AUTHOR | <the settled doc cited, the row it waits on, or the author call owed> |

RESOLVED cites a settled doc. DEFERRED points at something that already exists.
NEEDS-AUTHOR sets `status: blocked` and earns a row in [[records/author-calls]].

## 6. The mint packet

- **Elements:** <one, or several with the reason they split. Where two parts
  constrain each other, one element covers both>.
- **Band:** <`E<a>-E<b>` per [[decisions/decision-lane-split]], or `UNASSIGNED`>.
- **Catalog row:**
  `| E<NN> | <title> | <kind> | <ref> | <refclass> | <rationale> | <track> |`
- **Ledger row:**
  `| E<NN> | <category> | <module> | design | <track> |`
- **Size:** <files touched, lines, and the basis for the estimate>.
- **Related:** [[links]].

Every `E#` named here is already minted. Where one is owed, this names a roster
row instead.
