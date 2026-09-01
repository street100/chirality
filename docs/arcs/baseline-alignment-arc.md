---
node: arc-baseline-alignment
layer: navigation
related: [arcs/README, goals/presentability, records/baseline-alignment, records/README, index]
status: current
updated: 2026-09-01
---

# Arc: baseline alignment

- goal: [[goals/presentability]]
- reserved element block: **none**. Rows needing one write `UNASSIGNED`.
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
   `MAP.md`, `README.md`, `CONTENTS.md`, `HANDOFF.md`.
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

## Ordering

No element numbers are reserved for this arc, so nothing here can be scheduled
as an element yet. Rows carry `UNASSIGNED` in their `element:` field, which is
what [[records/README]] requires and what `CLAUDE.md`'s deferral rule
forbids working around.

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
3. **BA-09**, the fixture count. `HANDOFF.md` claimed
   `tools/test/samples/` holds 98 files; `ls` counted 54 on 2026-09-01. The
   C-backend drop removed four, so roughly 40 is older drift and undiagnosed.
4. **BA-23**, check A reads a module key as a filesystem path. 5 issues today,
   all module keys. It is the mirror of BA-02.
