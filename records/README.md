---
node: records
layer: navigation
related: [index, status-ledger, open-edges, arcs/README, arcs/diagnostics-arc, decisions/decision-ai-tier]
status: current
updated: 2026-09-01
---

# Checklists

A checklist is one arc's standing list of things this repo says about itself, each
paired with what was measured. One file per arc.

These files are TRACKED, and since 2026-09-01 so is the agent tier
([[decision-ai-tier]]). They stay here because a record is written for a person:
a claim this repo makes about itself beside what was measured. A finding written
into a commit message or a handoff paragraph is gone by the next session. A row
here survives a fresh clone.

## What a checklist is for

An agent finds a defect mid-task, outside its own task. Today that finding has
nowhere to go. Here it becomes a row: the claim, the measurement, a state, the
evidence, and the date it was last checked.

A checklist carries no build-state authority. [[status-ledger]] holds what is built.
[[open-edges]] holds what is open by design. `docs/arcs/` holds the arcs and
their element rows.
A checklist holds the residue: gaps between what a document asserts and what the
tree does.

## Row format

One row is one `###` block with six fields, one per line, in this order.

```
### <ID> <short title>

- state:    <STATE>
- claim:    what the repo says, and where it says it
- measured: what was observed
- evidence: file:line spans a reader can open
- checked:  YYYY-MM-DD
- element:  the element that owns the fix, or `none`, or `UNASSIGNED`
```

The heading is the ID and a short title. State lives on its own line, so changing
it is a one-line diff and the heading anchor never moves.

## States

| state | meaning |
|---|---|
| `OPEN` | claim and measurement disagree, nothing has been done |
| `ACCEPTED` | the gap is real and deliberately kept. `measured` says why |
| `FIXED` | reconciled. `measured` says which side moved, and in which commit |
| `RETIRED` | the row's subject no longer exists |

Four states. A fifth would need a rule for when to use it.

## Rules

Any agent may extend or modify a checklist without asking. These rules exist so
concurrent edits merge.

**Adding a row.** Append to the end of the section it belongs in, or open a new
`##` section. Mint the ID by taking the next number in the arc's prefix. Two agents
appending at once can pick the same number; git puts both blocks adjacent and the
later one gets renumbered. Never renumber a row that already exists. Its ID is
cited elsewhere.

**Changing a row.** Edit the `state:` line and the `checked:` date together. If the
subject moved, update `evidence:` in the same edit. A state change without a fresh
`checked:` date is a guess.

**Retiring a row.** Set `state: RETIRED` and leave the row in place. Never delete a
row. The record of what was once wrong is why the file exists.

**Re-verifying.** Re-run a row's evidence before relying on it. A row whose
`checked:` date predates the last change to the files it cites is unverified. Say
so rather than carrying it forward.

**Evidence is mandatory.** `evidence:` names files and line spans. A row nobody can
re-run is worthless.

**Elements.** Where a row needs an element to fix it, write `UNASSIGNED` and stop.
Do not mint a number. `docs/decisions/decision-lane-split.md` reserves E184-E189 for Lane A and E190-E195 for
Lane B. An arc with no reserved block gets one from the author, and CLAUDE.md's
deferral rule forbids naming an element that does not exist.

## Naming

`records/<arc>.md`, slug-cased. Link by `[[records/<arc>]]`.

## Why a new doc role

`MAP.md` sorts docs by role. A checklist is a reconciliation that any agent is
expected to edit, where `definitions/`, `decisions/` and `elements/` are written
once and audited. Editability by anyone is the role.

## The records

- [[records/baseline-alignment]]: does the repo do what it claims to do
- [[records/enforcement-arc]]: what the compiler enforces, and what it can
  measure about its own work
- [[records/findings]]: dated investigations belonging to no single arc

The first two have an arc beside them under `docs/arcs/`. The checklist is the
finding list; the arc is the work.

[[records/findings]] is the exception to one-file-per-arc, and it is deliberate.
A session that finds a defect outside its own task writes a `FINDING-*.md` into
`.planning/`, which `.gitignore:12` excludes, so the finding dies with the
worktree. Those rows have to land somewhere tracked before an arc exists to own
them. Its prefix is `FD`. A row moves out of it when the arc that owns it is
written, and moving a row keeps its ID.
