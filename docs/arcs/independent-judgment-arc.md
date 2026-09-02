---
node: arc-independent-judgment
layer: navigation
related: [arcs/README, goals/independent-judgment, decision-self-verification, decision-work-ids, certificate-discipline, status-ledger, index]
status: current
updated: 2026-09-01
---

# Arc: judgment that does not rest on one formulation

- goal: [[goals/independent-judgment]]
- reserved element block: **none**. Rows carry arc-local ids `J1` and up, per
  [[decisions/decision-work-ids]], and map to `unminted`.
- build-state authority: [[status-ledger]]

Opened 2026-09-01. The goal was stated and carried no arc, so nothing in the
tree could be scheduled against it and `ledger-lint` check V reported it as a
goal with no path to work.

## Why this arc exists

External judgment is cut. The Rocq leg, the CompCert leg and the Python oracle
are gone, and what replaces them is three semantically distinct judgment cores
that must agree. `docs/decisions/decision-self-verification.md` records the call.

The criterion is **different formulations**. Three encodings of one rule set are
worth nothing, which is why the C backend was dropped rather than counted as a
leg: it shared `compile-front` and `compile-back` whole and differed only at
emit, making it a second target under one formulation
(`docs/elements/catalog.md`, E166).

Until a second formulation exists, every rung in [[status-ledger]] is enforcement
against error. An adversary who controls the source is out of reach of all of
them, and the ledger says so.

## What is in the tree already

| module | lines | importers | |
|---|---|---|---|
| `lib/evidence/ddc.chiral` | 213 | 1 | the quorum machinery. `prov-disjoint`, `leg2-disjoint`, `ddc-compare`, and the refusal `ddc-bad-quorum` for fewer than two legs of disjoint provenance |
| `lib/typing/kernel-core.chiral` | 60 | 0 | written, unreached |
| `lib/typing/reflect-floor.chiral` | 54 | 0 | written, unreached |

`ddc.chiral` still carries `ddc-legc` and `ddc-legcc`, the two C legs, with zero
callers and zero assertions since the backend was dropped. The disjointness check
runs before any byte is read, which was a repair: it once folded bytes without
consulting provenance, so leg 0 plus both C legs came back converged as a
three-leg quorum carrying two opinions.

## REQUIREMENTS

Done when all four hold.

1. **What counts as a distinct formulation is written down**, so a candidate leg
   can be judged against it rather than argued about. `Prov` has four axes and
   `leg2-disjoint` checks two, with `author` assertable only.
2. **A second judgment core exists in a different formulation**, and the quorum
   it forms is disjoint on the axes that matter.
3. **The quorum refuses what it should.** `ddc-bad-quorum` fires on fewer than
   two disjoint legs, with a mutant that is actually run.
4. **`status-ledger` stops saying every rung is enforcement against error**,
   because it no longer is.

## Rows

| row | what | state | element |
|---|---|---|---|
| `independent-judgment/J1` | the distinctness criterion, written | not started. Requirement 1 | `unminted` |
| `independent-judgment/J2` | `kernel-core` and `reflect-floor` wired, or moved to SEEDED with the reason | not started. Both are written with zero importers | `unminted` |
| `independent-judgment/J3` | a second judgment core in a different formulation | not started. The whole of requirement 2 | `unminted` |
| `independent-judgment/J4` | the two dead C legs retired or re-grounded | not started. `ddc-legc` and `ddc-legcc` have zero callers since the backend was dropped | `unminted` |

## Resume state

Nothing built, and J1 comes first: requirement 2 cannot be judged without it.

**What blocks the arc.** No reserved element block, so nothing here can be
minted. That is an author call and the rows carry arc-local ids meanwhile.

**A trap already recorded.** A leg that shares a front end and differs at emit is
one formulation emitting twice. E166 was built, measured, and dropped on exactly
that reading, and its catalog row keeps the whole record of the leg while it ran.
Any candidate for J3 meets the same test.
