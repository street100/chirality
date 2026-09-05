---
node: goals
layer: navigation
related: [index, arcs/README, records/README, status-ledger, open-edges]
status: current
updated: 2026-09-04
---

# Goals

Three tiers organise the work.

| tier | what it is | where it lives |
|---|---|---|
| goal | a broad thing this project claims it is doing | `docs/goals/` |
| arc | the list of elements that serve one goal, with its requirements | `docs/arcs/` |
| element | one catalog item, an `E#` | `docs/elements/`, `docs/elements/catalog.md` |

A goal file says what the goal claims, cites where the project claims it, names
the arcs that serve it, and states what `done` means. An arc file names every
goal it serves. An element belongs to exactly one arc.

Every goal below is derived from text already in the repo. The citation is in
the goal file. A goal nobody has written down does not go here: it goes in the
arc's `goal` field as `UNWRITTEN`, and it is an author call.

## The goals

| goal | state | arcs |
|---|---|---|
| [[goals/self-hosting]] | held since 2026-08-05, maintained by the BUILD RULE | none open, and see Rules |
| [[goals/self-tooling]] | in flight | [[arcs/zero-python-arc]], [[arcs/text-tools-arc]] |
| [[goals/readable-surface]] | in flight | [[arcs/diagnostics-arc]], [[arcs/file-types-arc]] |
| [[goals/presentability]] | in flight | [[arcs/baseline-alignment-arc]], [[arcs/presentability-arc]], [[arcs/binary-split-arc]] |
| [[goals/enforcement]] | in flight | [[arcs/enforcement-arc]] |
| [[goals/independent-judgment]] | stated, unbuilt | [[arcs/independent-judgment-arc]] |
| [[goals/bridge]] | stated 2026-09-02, unbuilt | [[arcs/bridge-arc]] |
| [[goals/module-split]] | in flight, one measured miss | [[arcs/module-split-arc]] |
| [[goals/local-ai]] | stated 2026-09-01, unbuilt in this tree | [[arcs/transport-arc]], [[arcs/scriba-arc]], [[arcs/tuning-arc]], [[arcs/unit-lane-arc]] |
| [[goals/native-stack]] | in flight: protocol arc opened 2026-09-03, window and document unopened | [[arcs/native-protocol-arc]], [[arcs/native-window-arc]], [[arcs/native-document-arc]] |
| [[goals/display]] | stated 2026-09-04, unbuilt: the calculus arc opened, four conditions unopened | [[arcs/display-calculus-arc]] |
| [[goals/own-web]] | stated 2026-09-05, unbuilt: two arcs opened, three conditions unopened | [[arcs/vocabulary-arc]], [[arcs/canvas-arc]] |
| [[goals/ownership-and-trust]] | deferred out of scope 2026-08-31 | [[arcs/ownership-and-trust-arc]], deferred with the track |

`independent-judgment` carries an arc as of 2026-09-01 and still has no element.
`README.md` lists it under Honest limits, and
`docs/decisions/decision-self-verification.md` records the call. Its four rows
carry arc-local ids per [[decisions/decision-work-ids]], because the arc has no
reserved element block.

[[goals/presentability]] and [[goals/readable-surface]] are author calls rather
than derivations from existing text, and say so in their own first section.

[[goals/local-ai]] is an author call too, stated verbatim on 2026-09-01 and
says so in its own first section. Three of its arcs opened 2026-09-02 from
`.planning/LOCAL-AI-ARC-REALIGNMENT.md`, which also says which existing arcs
supply pieces without being re-pointed. Two rows in [[records/author-calls]]
still block work inside them: [[arcs/tuning-arc]] is blocked whole and
[[arcs/transport-arc]] can be worked as far as its first row. A fourth,
[[arcs/unit-lane-arc]], opened 2026-09-05 for condition 3, carrying the
roster `.planning/AI-LANE-GAP.md` drew from [[banks/unit]].

[[goals/bridge]] was opened 2026-09-02 and is a derivation rather than a new
ambition: [[thesis]] and [[category-bridge]] both call C "the part of Chirality
that is new work rather than borrowed", and no goal, arc or row stood against
it. Its arc has no reserved block, so its rows take arc-local ids.

[[goals/display]] was stated 2026-09-04 and is an author call, the fourth
after [[goals/presentability]], [[goals/readable-surface]] and
[[goals/local-ai]]. It says so in its own first section. Four of its five
done-conditions hold no arc file and stay conditions in the goal, so this
table lists the one arc that exists. [[goals/native-stack]] condition 3 becomes
a consumer of it, and whether [[arcs/native-document-arc]] survives the overlap
is a row in [[records/author-calls]].

[[goals/module-split]] was opened 2026-09-02, also a derivation:
[[splitting-law]] and [[joining-law]] are standing rules with a decidable test
and nothing was scheduled against either. It is separate from
[[goals/readable-surface]] because that goal is the *surface*, its own done
clauses naming syntax, diagnostics and file kinds, and separate from
[[goals/presentability]] because that one is truth and outside-reader
orientation. This is how the source itself is cut.

[[goals/ownership-and-trust]] carries an arc as of 2026-09-02 and every row in
it is deferred. The arc holds three minted elements, `E53`, `E71` and `E72`,
that were sitting in the goal file. A deferred goal keeps its arc unscheduled,
and the arc says so in its own resume state.

## Rules

- A goal file carries a dated summary of where its goal stands, in `## State`,
  and of what still falls short, in `## Honest limits`. It carries no element or arc
  rows. [[status-ledger]] is the authority for what is built on the four rungs
  and [[records/README]] for a claim beside its measurement, so a summary that
  disagrees with either is a defect in the summary.
- Adding a goal means citing where the project already claims it. Authoring a
  new ambition is an author call.
- Changing what a goal claims changes what its arcs are for, so it is a decision
  and belongs in `docs/decisions/` first.
- **A goal held by a standing gate carries no arc, and that is its finished
  shape.** An arc schedules work toward a goal that is open. Where a goal is
  maintained on every change by a rule that already runs, there is no work to
  schedule and an arc would be an empty file. [[goals/self-hosting]] is the
  case: the BUILD RULE in [[working-discipline]] holds it on every change whose
  deliverable enters the compiler's import closure, and
  `tools/test/map-integrity.sh` and `bin/chirality test` measure it. Its goal
  file names the gates and its honest limits say what a fixpoint does not
  prove. A goal in this shape says `none open` in the table above, and
  `ledger-lint` check V reads that as the recorded reason rather than a hole.
  A goal with neither an arc nor a gate is a hole and check V fails it.
