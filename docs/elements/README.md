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
element catalog (`docs/elements/catalog.md`) and the ledger
(`docs/elements/ledger.md`) fork per worktree and die there. Two sessions minted
`E173` independently and nothing caught it. An element fact a second reader
needs has to survive a fresh clone.

## What this directory holds

| what | file |
|---|---|
| the element catalog, detail per element | `catalog.md`, 635 lines |
| the category map over the E#/T# sets | `ledger.md`, 450 lines |
| the per-element implementation specs | `specs/`, 126 files |

Moved out of `.planning/` and into git on 2026-09-01, on the author's call. The
reason is measured: 76 tracked documents cited 156 distinct `.planning` files, so
a fresh clone got the goals, the arcs, the records and the build state, and then
every element row those pointed at was missing. Six of those citations could not
be followed from *this* clone either.

**Moved, not reshaped.** The shape question this file used to pose — one file per
element, one per number band, or a single index — is still open and is still an
author call. Changing location and changing shape in one step would make both
unreviewable. The catalog and ledger are byte-for-byte what they were in
`.planning/`, at a new path.

### What tracking exposed

`ledger-lint` went from 3 failing checks to 7 the moment these files entered a
scanned doc role: A(5) B(5) F(27) G(77) I(1) R(112) T(1), 228 issues against 7.
None of that is new breakage. Those citations were always wrong; they sat where
the checks did not reach. Treating the jump as a regression would be the wrong
reading, and re-ignoring the directory to make the number go down would be the
gate-that-cannot-fail error this repo names as cardinal.

## Rules

- Do not mint a number that does not exist. Element bands are reserved in
  `docs/decisions/decision-lane-split.md`; an arc with no block writes `UNASSIGNED`.
- A new element's row lands in `docs/examples/INDEX.md` and in its arc file in
  the same change that mints it.
- Element status does not originate here. [[status-ledger]] holds build state, on
  the rungs DESIGNED, SEEDED, IMPLEMENTED, ENFORCED.
