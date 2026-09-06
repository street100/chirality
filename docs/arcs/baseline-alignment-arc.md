---
node: arc-baseline-alignment
layer: navigation
related: [arcs/README, goals/presentability, records/baseline-alignment, records/README, index]
status: current
updated: 2026-09-05
---

# Arc: baseline alignment

- goal: [[goals/presentability]]
- reserved element block: **none**. Its rows are the `BA-` ids in
  [[records/baseline-alignment]], which is the arc-local id scheme
  [[decisions/decision-work-ids]] settles. They map to `unminted`.
- finding list: [[records/baseline-alignment]]

TRACKED for the reason [[arcs/diagnostics-arc]] is.

## The checklist and the arc are different things

[[records/baseline-alignment]] is the finding list. One row is a claim this
repo makes about itself beside what was measured, with a state, evidence and a
date. Any agent may add or amend a row without asking.

This file is the work. It says which findings are being closed, in what order,
and what has to hold before the arc is done. A row moves to `FIXED` in the
checklist; the arc says who moves it and why that one next.

The author's framing: current work to actually align with the goals
we are trying to claim, since apparently we are not.

## REQUIREMENTS

Done when all four hold.

1. **No gate in the tree can pass by looking at nothing.** A gate with an
   unreachable branch, a grep matching its own source, or a subject that no
   longer exists is repaired or deleted. Naming it VACUOUS is the interim, and it
   is a state rather than an answer.
2. **Every documented kind has an instance or a row saying why not.** `.profile`
   is documented in `MAP.md` with zero instances and no consumer, measured
   2026-09-01.
3. **Every claim in a root document is measured or carries a checklist row.**
   `MAP.md`, `README.md`, `CONTENTS.md`, `docs/decisions/decision-scope.md`.
4. **`python3 tools/ledger-lint/ledger-lint.py` exits 0**, or each remaining
   failing check has a row stating why it cannot.

## State

The row count is omitted here; read the file. Sections, in its order:

| section | what it covers |
|---|---|
| gates that cannot fail | map-integrity, ledger-lint G and R, H and M, the `check` CLI |
| the `check` subcommand | three failure classes on one exit code |
| claims that do not match the tree | testing-floors, the fixture count, `.profile`, "the two binaries", the port floor |
| dead or unreachable code | `ddc.chiral`, `alloc-fixed.chiral`, both deliberate |
| structure | four of six roots carry the identical 58-module closure |
| navigation | `MAP.md` on `docs/elements/` |
| residue from the gate repair | what the repaired gates still cannot see |
| what the compiler claims to enforce and does not | the effect membrane, totality, the TAL floor, positivity, refinement bounds, profiles, file kinds |

BA-16 and BA-17 are the measurement [[arcs/binary-split-arc]] starts from.
BA-18 was closed by this restructure.

The last section is the largest and it is the one that overlaps
[[goals/enforcement]]. A row there whose fix is an element belongs to
[[arcs/enforcement-arc]] once a number is minted for it. Nothing routes rows
between arcs automatically, so a row can sit in both readings until an element
claims it.

## Roster

Nine rows, one per section of the State table above, each serving a numbered
requirement. **The roster is the work; the lens rows are the findings.** This
arc's own first section draws that line, and a roster mirroring all 44 findings
would collapse it.

The `BA-` findings moved to the lenses on 2026-09-05
([[decisions/decision-four-lenses]]): 32 to `records/lenses/problems.md` and 6 to
`records/lenses/limits.md`, each carrying its old id in `from:`, each `BA-` row
left in place and `RETIRED` with a pointer. Six are `FIXED` and stay as history.

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `baseline-alignment/AL1` | repair every gate that can pass by looking at nothing | gates | tool | new | 1 | open | `unminted` |
| `baseline-alignment/AL2` | the `check` subcommand separates its three failure classes | gates | tool | new | 1 | open | `unminted` |
| `baseline-alignment/AL3` | close the residue the gate repair left: what the repaired gates still cannot see | gates | tool | new | 1 | open | `unminted` |
| `baseline-alignment/AL4` | `.profile` gains an instance, or a limit row says why it has none | kinds | decision | new | 2 | open | `unminted` |
| `baseline-alignment/AL5` | every claim in a root document is measured or carried by a lens row | claims | decision | new | 3 | open | `unminted` |
| `baseline-alignment/AL6` | dead and unreachable code: each deliberate one carries a limit row | claims | decision | new | 3 | open | `unminted` |
| `baseline-alignment/AL7` | four of six roots carry the identical 58-module closure | structure | law | new | 3 | open | `unminted` |
| `baseline-alignment/AL8` | what the compiler claims to enforce and does not | enforcement | law | connect | 3 | open | `unminted` |
| `baseline-alignment/AL9` | `ledger-lint` exits 0, or each failing check carries a row saying why it cannot | gates | tool | new | 4 | open | `unminted` |

### Coverage

Every requirement is served: 1 by AL1, AL2 and AL3; 2 by AL4; 3 by AL5, AL6, AL7
and AL8; 4 by AL9. Every row serves one. Every `origin` is `new` except AL8,
which is `connect`: its subject is built and the gap is that nothing reaches it,
which is the section this arc shares with [[goals/enforcement]].

## Ordering

No element numbers are reserved for this arc, so nothing here can be scheduled
as catalog work. Rows carry the arc-local ids above, per
[[decisions/decision-work-ids]], which settled the scheme on 2026-09-01 for an
arc with no band. An arc-local id claims identification and claims no place in a
band or a catalog row, so the deferral rule in [[working-discipline]] keeps its
whole force over `E#`.

What can be done without a number: repairing a gate, correcting a document,
deleting a claim. Three of the four requirements above are reachable that way.
Requirement 2 is not, because minting `.profile` instances is a design change.

## Resume state

Next, in the order the measurement suggests:

1. **BA-03**, the two VACUOUS ledger-lint checks. H is now repointable at
   `lib/typing/refine.chiral:11` and `lib/module/loader.chiral:20`, both live,
   which makes it a measured repoint rather than a guess. M has no live subject.
2. **BA-01's residue**, `tools/test/map-integrity.sh`'s `-z` branch. It is
   unreachable for a 4-column row, because `IFS=$'\t' read -r old new ext why`
   collapses tab runs and a blank `new_path` shifts `ext` into `$new`. Retired
   rows use the brace form instead. The branch wants fixing or deleting.
3. **BA-09**, the fixture count. `docs/decisions/decision-scope.md` claimed
   `tools/test/samples/` holds 98 files; `ls` counted 54 on 2026-09-01. The
   C-backend drop removed four, so roughly 40 is older drift and undiagnosed.
4. **BA-23**, check A reads a module key as a filesystem path. It is the mirror
   of BA-02. The 5 issues it reported on 2026-09-01 are gone for a reason that
   leaves the defect standing: `b5994d0` reworded [[status-ledger]] and took the
   module keys out of the code spans check A scans, so the check reads 0 on
   2026-09-04 with `is_pathish` unchanged. The resolver still accepts any token
   carrying a slash, and the next module-key citation in the ledger fires it
   again.

**Measured 2026-09-04, and it moves requirement 4.** `ledger-lint` exits 1 and
prints `[FAIL]` for G and R alone. A, B, C, F, I and T all report 0 issues, H
and M stay VACUOUS. `BA-36`'s reading, that the run exits 0 while A, I and T
fail, was taken on 2026-09-01 and describes neither the tool nor its exit status
today. Repointing that row belongs to whoever holds
[[records/baseline-alignment]].
