---
node: arcs
layer: navigation
related: [goals/README, index, records/README, status-ledger, elements/README]
status: current
updated: 2026-09-04
---

# Arcs

An arc is the list of elements to be done for one goal. It carries the
requirements that must hold before the arc is done, and it carries its own
resume state, so a session starts from the arc file and needs nothing at root.

These files are TRACKED. `.planning/` is tracked too, since 2026-09-01
(`docs/decisions/decision-ai-tier.md`); the `.gitignore` header states the rule
and keeps out only the machine state Claude Code writes for itself. **The
exclusion that made this paragraph necessary is closed.** What survives it is
the reason an element fact lives here: two sessions minted `E173` independently
and nothing caught it until a merge put both INDEX rows side by side.
`records/baseline-alignment.md` BA-44 holds the measurement.

## The three tiers

| tier | unit | home |
|---|---|---|
| goal | a broad thing this project claims it is doing | `docs/goals/` |
| arc | elements assembled toward one goal, with requirements | `docs/arcs/` |
| element | one catalog item, an `E#` | `docs/elements/`, `docs/elements/catalog.md` |

An arc names every goal it serves, and a goal is served by every arc that names
it. The relation is many to many: one arc can supply two goals at once, and one
goal can take work from several arcs. Where no goal is written down, the arc's
`goal` field says `UNWRITTEN` and the arc stays open on an author call.
Authoring a goal the project has never stated is forbidden.

## What an arc file carries

1. `goals:` every goal it serves, or `UNWRITTEN`. The singular `goal:` is
   the same field and is what the arcs written before the relation opened up
   still spell.
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

Do not mint a number that does not exist. `docs/decisions/decision-lane-split.md` reserves `E184-E189` for
Lane A and `E190-E195` for Lane B. `CLAUDE.md`'s deferral rule forbids naming an
element that has never been minted, and a deferral to a nonexistent element is a
phantom dependency.

An arc with no reserved block writes `UNASSIGNED` in the `element:` field of
anything owed a number, and carries its work as arc-local rows meanwhile.
`docs/decisions/decision-work-ids.md` settled that on 2026-09-01, replacing the
earlier rule that such an arc writes `UNASSIGNED` and stops. An arc-local id
claims identification and claims no place in a band, a catalog row, a ledger row
or a pipeline stage, so the deferral rule keeps its whole force over `E#`.

A new element's row lands in `docs/examples/INDEX.md` and in its arc file in the
same change that mints it. Those are the tracked collision detectors.

## The arcs

Each row's goal is the arc's own `goal:` field, and `ledger-lint` check V fails
when this table and an arc file disagree.

| arc | goal | state | reserved block |
|---|---|---|---|
| [[arcs/diagnostics-arc]] | [[goals/readable-surface]] | 5 built, 4 open | `E184-E189` shared with enforcement |
| [[arcs/enforcement-arc]] | [[goals/enforcement]] | 5 rows: E16 on the live path with its check unrun, E17/E18 built and unadopted, E70/E184 design | `E184-E189` |
| [[arcs/file-types-arc]] | [[goals/readable-surface]] | 0 of 4 built | `E190-E195` |
| [[arcs/text-tools-arc]] | [[goals/self-tooling]] | 1 of 4 primitives minted | none |
| [[arcs/zero-python-arc]] | [[goals/self-tooling]] | 0 of 14 `.py` files removed | none |
| [[arcs/baseline-alignment-arc]] | [[goals/presentability]] | 44 rows on 2026-09-04: 4 FIXED, 6 ACCEPTED, 34 open | none |
| [[arcs/presentability-arc]] | [[goals/presentability]] | 3 rows, none started | none |
| [[arcs/binary-split-arc]] | [[goals/presentability]] | 5 rows, none started | none |
| [[arcs/independent-judgment-arc]] | [[goals/independent-judgment]] | 5 rows, none started | none |
| [[arcs/bridge-arc]] | [[goals/bridge]] | 5 rows, C4 holds E40/E56 | none |
| [[arcs/module-split-arc]] | [[goals/module-split]] | 4 rows, none started | none |
| [[arcs/transport-arc]] | [[goals/local-ai]] | 4 rows, all four done 2026-09-02 and gated by Phase 20 | none |
| [[arcs/scriba-arc]] | [[goals/local-ai]] | 6 rows, `S18` built and five open | the `S` namespace |
| [[arcs/tuning-arc]] | [[goals/local-ai]] | opened blocked, no row written | none |
| [[arcs/ownership-and-trust-arc]] | [[goals/ownership-and-trust]] | 3 rows, all deferred by author call | none |
| [[arcs/native-protocol-arc]] | [[goals/native-stack]] | 9 rows: N1 slices 1 and 2 built, N7 example audited | the `N` namespace |
| [[arcs/native-window-arc]] | [[goals/native-stack]] | 4 rows, none started | none |
| [[arcs/native-document-arc]] | [[goals/native-stack]] | 4 rows, none started | none |
| [[arcs/display-calculus-arc]] | [[goals/display]] | 17 rows, none started | none |

Three of the nineteen hold a reserved `E` band, [[arcs/scriba-arc]] holds the
`S` namespace and [[arcs/native-protocol-arc]] holds the `N` namespace. The
other fourteen cannot mint an element today, and
`docs/decisions/decision-work-ids.md` settles the arc-local row id that lets
them name their work anyway. Every one of the fourteen spells its scheme in its own
`reserved element block:` field, and `ledger-lint` check V fails an arc that
holds neither a band nor a scheme.

A goal with no arc is a different shape and `docs/goals/README.md` states when
it is legitimate.
