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

**The shape fork is CLOSED, 2026-09-06, by author directive: close forking.**
`catalog.md` and `ledger.md` stay as they are. `pack.py` reads both, `--mint`
writes both, and `ledger-lint` check AE fails an element present in one and
absent from the other, so the two-file shape is now gated rather than merely
tolerated. One file per element and one per band are both refused.

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
  `docs/decisions/decision-lane-split.md`; an arc with no block carries
  arc-local roster ids per [[decisions/decision-work-ids]].
- **Minting is the last step of the design stage.** It used to be the first act of work.
  A unit of work is named in its arc's roster, worked up at
  `docs/arcs/parts/<arc>-<id>.md`, and given an `E#` only when that design
  passes audit. `pack.py <arc>/<id> --mint` writes the catalog row and the
  ledger row the design's §6 produced, and the arc's roster row is the tracked
  collision detector. [[decisions/decision-design-before-mint]] settled this on
  2026-09-05, and the reason is that a catalog row demands seven facts at the
  moment least is known.
- A mint writes BOTH rows. `ledger-lint` check AE fails an element in the
  catalog and not the ledger, or the reverse.
- Element status does not originate here. [[status-ledger]] holds build state, on
  the rungs DESIGNED, SEEDED, IMPLEMENTED, ENFORCED.
