---
node: elements
layer: navigation
related: [arcs/README, goals/README, status-ledger, index]
status: draft
updated: 2026-09-01
---

# Elements

An element is one catalog item, an `E#`. It is the unit of work. An arc
assembles elements toward a goal; see [[arcs/README]].

## What this directory is for

The tracked home of element rows. `.gitignore:12` excludes `.planning/`, so the
element catalog (`.planning/SELF-IMPLEMENT-CATALOG.md`) and the ledger
(`.planning/LEDGER.md`) fork per worktree and die there. Two sessions minted
`E173` independently and nothing caught it. An element fact a second reader
needs has to survive a fresh clone.

## What blocks filling it

The shape of a tracked element row is undecided, and it is an author call. Three
candidates, none chosen:

1. One file per element. 184 files, most of them a paragraph.
2. One file per number band, matching the reserved blocks in `LANES.md`.
3. A single tracked index, with the arc files keeping the prose.

Underneath that sits a larger question this run did not answer: whether the
catalog and ledger themselves become tracked and move out of `.planning/`.
Moving them goes past a restructure. It changes what is published, and it needs the
author.

Until then this directory holds this file and nothing else. An empty directory
with a stated purpose beats a directory filled with a guess.

## Where element rows are today

| what | where |
|---|---|
| the catalog | `.planning/SELF-IMPLEMENT-CATALOG.md`, untracked |
| the ledger | `.planning/LEDGER.md`, untracked |
| per-arc element rows, tracked | the arc files under `docs/arcs/` |
| the worked-example registry, tracked | `docs/examples/INDEX.md` |
| build state | [[status-ledger]] |

`docs/arcs/diagnostics-arc.md` and `docs/arcs/enforcement-arc.md` were in this
directory until 2026-09-01. They are arc files, so they moved one directory
across. A pointer to `docs/elements/diagnostics-arc.md` written before that date
means `docs/arcs/diagnostics-arc.md`.

## Rules

- Do not mint a number that does not exist. Element bands are reserved in
  `LANES.md`; an arc with no block writes `UNASSIGNED`.
- A new element's row lands in `docs/examples/INDEX.md` and in its arc file in
  the same change that mints it.
- Element status does not originate here. [[status-ledger]] holds build state, on
  the rungs DESIGNED, SEEDED, IMPLEMENTED, ENFORCED.
