---
node: arcs
layer: navigation
related: [goals/README, index, records/README, status-ledger, elements/README]
status: current
updated: 2026-09-01
---

# Arcs

An arc is the list of elements to be done for one goal. It carries the
requirements that must hold before the arc is done, and it carries its own
resume state, so a session starts from the arc file and needs nothing at root.

These files are TRACKED. `.gitignore:12` excludes `.planning/`, so an element
fact written there forks per worktree and dies with it. Two sessions minted
`E173` independently and nothing caught it. An element fact a second reader
needs lives here.

## The three tiers

| tier | unit | home |
|---|---|---|
| goal | a broad thing this project claims it is doing | `docs/goals/` |
| arc | elements assembled toward one goal, with requirements | `docs/arcs/` |
| element | one catalog item, an `E#` | `docs/elements/`, `.planning/SELF-IMPLEMENT-CATALOG.md` |

An arc names exactly one goal. Where no goal is written down, the arc's `goal`
field says `UNWRITTEN` and the arc stays open on an author call. Authoring a
goal the project has never stated is forbidden.

## What an arc file carries

1. `goal:` the goal it serves, or `UNWRITTEN`.
2. `REQUIREMENTS`: what must hold for the arc to be done, numbered, each one
   checkable. A requirement with no way to observe it is a wish.
3. The element list with state. One row per element.
4. Resume state: where a session picks up, what blocks it, what was measured.
5. Its reserved element block, or `none`.

An arc may keep a second file, `records/<arc>-record.md`, holding the measured
history: what landed, the traps that fired, the decisions that each cost a
measurement. The arc file is rewritten as work moves. The record is appended and
not rewound. That split is why [[records/diagnostics-arc-record]] exists as its
own file.

Records live in `records/` at the root, not under `docs/`. `docs/` is the tier a
reader is handed; `records/` is what we measured about ourselves. Keeping the
audit residue out of the reader's path is a requirement of
[[goals/presentability]].

## Naming

`docs/arcs/<arc>-arc.md`, slug-cased, link by `[[arcs/<arc>-arc]]`. The `-arc`
suffix is kept even though the directory says it, because two arc files carry
that basename in pointers outside this directory and because `records/` holds a
same-stem file for two of these arcs.

## Element numbers

Do not mint a number that does not exist. `LANES.md` reserves `E184-E189` for
Lane A and `E190-E195` for Lane B. An arc with no reserved block writes
`UNASSIGNED` and stops. `CLAUDE.md`'s deferral rule forbids naming an element
that has never been minted, and a deferral to a nonexistent element is a phantom
dependency.

A new element's row lands in `docs/examples/INDEX.md` and in its arc file in the
same change that mints it. Those are the tracked collision detectors.

## The arcs

| arc | goal | state | reserved block |
|---|---|---|---|
| [[arcs/diagnostics-arc]] | [[goals/self-tooling]] | 5 built, 4 open | `E184-E189` shared with enforcement |
| [[arcs/enforcement-arc]] | [[goals/enforcement]] | 1 minted, 0 built | `E184-E189` |
| [[arcs/file-types-arc]] | [[goals/self-tooling]] | 0 of 3 built | `E190-E195` |
| [[arcs/zero-python-arc]] | [[goals/self-tooling]] | 0 of 14 `.py` files removed | none |
| [[arcs/baseline-alignment-arc]] | [[goals/honest-claims]] | 3 rows closed, the rest open | none |
| [[arcs/binary-split-arc]] | `UNWRITTEN` | measured, unstarted | none |
