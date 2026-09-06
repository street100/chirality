---
node: goal-presentability
layer: navigation
related: [goals/README, arcs/presentability-arc, arcs/baseline-alignment-arc, arcs/binary-split-arc, records/baseline-alignment, index]
status: current
updated: 2026-09-03
---

# Goal: what this repo says about itself is true, and a reader outside it can tell

## The claim, and where the project makes it

- `README.md` marks every live limit inline with ⚑ and carries a standing
  `Claims, state and limits` table; every principle in `PRINCIPLES.md` carries
  its own limits. The form is the commitment.
- [[working-discipline]], Reporting: *"Report failures with their output. Name
  skipped work. Say `done` only when a gate ran."*
- `docs/decisions/decision-scope.md`, by way of [[working-discipline]]: a
  subcommand dispatching to a floor this tree lacks is a gate that cannot fail.
  The same rule reads on documents.
- [[records/README]]: a record row is a claim this repo makes about itself beside
  what was measured.
- `LICENSE.md` is AGPL-3.0-or-later with `LICENSE.EXCEPTION.md`, and
  `docs/decisions/decision-license.md` records why.
- `MAP.md` and `CONTENTS.md` exist to orient a reader who has not seen the tree.

The outside-reader half is an author call: the submission targets are NLnet and
Tangent. Truth and legibility are one goal because they fail together. A false
claim presented clearly is worse than the present state, and a true claim nobody
can find does not count.

## What done means

1. **Every claim a tracked document makes is measured and matching**, or carries
   a row saying it does not, and a gate that cannot fail is repaired or deleted.
   Observed by `ledger-lint` exiting 0 or each failing check carrying a row.
   [[arcs/baseline-alignment-arc]] and [[arcs/presentability-arc]].
2. **An evaluator can build it from a clean clone**: the BUILD RULE runs end to
   end and the byte-compare holds. Observed by the generations converging on a
   fresh clone. [[arcs/presentability-arc]] requirement 1, and
   [[arcs/binary-split-arc]] row `B5` for the split binaries.
3. **They can run the tests and read the result**, and a green suite means what
   it says. Observed by every gate row naming a mutant that is actually run.
   [[arcs/baseline-alignment-arc]] requirement 1.
4. **They can see what is built, what is designed and what is deferred without
   reading `.planning/`.** Observed by `docs/definitions/OVERVIEW.md`
   regenerating clean over the goals, the arcs, the rosters and the four lenses.
   [[arcs/presentability-arc]].
5. **They can take a tool without taking the compiler.** A text tool that ships
   the x64 backend misrepresents the architecture to anyone who measures it.
   Observed as `^(end-module "` markers on the tool's blob.
   [[arcs/binary-split-arc]].

## State

In flight. [[records/baseline-alignment]] holds 36 rows, most still open, and
four of them cite the spine directly: BA-24 (`PRINCIPLES.md`), BA-30 (`MAP.md`),
BA-31 (`chirality verify`, cited 14 times and not a subcommand), BA-36
(`README.md`, `CLAUDE.md`).

The standing miss is `PRINCIPLES.md`, which says "One atom with no exemptions"
and "the port-check is the type-check" while a pure `->` function performs a
syscall and is accepted. `README.md`, [[status-ledger]] and
[[banks/effect-and-alarm]] all disclose that accurately; the spine's most-read
document is the one that does not.

## Arcs

- [[arcs/baseline-alignment-arc]] — establishes whether a claim is true.
- [[arcs/presentability-arc]] — the reader-facing spine and the submission
  material.
- [[arcs/binary-split-arc]] — criterion 5.

Baseline alignment moves first where they meet.

## Honest limits

**This goal is not a licence to trim caveats.** The one failure it can cause is
removing an honest limit to make a document read cleanly. A caveat cut makes the
page better and the project worse, and one missing limit discounts every other
claim. `⚑`, "unbuilt", "UNVERIFIED", "VACUOUS", "SEEDED", and every measured
number with its date stay.

**A submission deadline is not a build gate.** Nothing here licenses marking
something ENFORCED because a form asks whether it is. The four rungs mean what
[[status-ledger]] says they mean.

**The outside half cannot be finished from inside the repo.** Criteria 2 to 4 are
about a reader who is not us. Until someone outside reads it, done is inferred.

**Known false today**: BA-36 recorded `ledger-lint` exiting 0 while three checks
failed. Re-measured 2026-09-01: it exits 1 with 249 findings across nine of its
twenty checks, so the exit code now agrees with the findings and the row's
numbers are stale. `MAP.md:5` and `:37-40` describe a
file-kind check with no implementation (BA-30). `docs/banks/profile.md:246`
refutes a real gap with a command that does not exist (BA-31). 294 doc citations
name a path that does not exist and 161 bare `:NN` spans have no subject a check
can name; both are recorded and neither is repointed, because a check aimed at a
guess passes by looking at nothing.
