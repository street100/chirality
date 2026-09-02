---
node: arc-scriba
layer: navigation
related: [arcs/README, goals/local-ai, records/baseline-alignment, elements/ledger, status-ledger, index]
status: current
updated: 2026-09-02
---

# Arc: the scriba cockpit

- goals: [[goals/local-ai]]
- reserved element block: the `S` namespace, which
  `docs/elements/ledger.md` gives its own letter under Referencing. Rows carry
  `S#` and this arc mints nothing in the `E` bands.
- build-state authority: [[status-ledger]]
- serial order and gates: `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md`

Opened 2026-09-02 from `.planning/LOCAL-AI-ARC-REALIGNMENT.md` section 3B. This
is the half of [[goals/local-ai]] that needs no author call: the S namespace
already exists, so its rows can be scheduled today.

## Why this arc exists

Criterion 2 of [[goals/local-ai]] asks that every part of a run be authored,
composed, fired, watched and revised from `prog/scriba/`, with no step that
requires leaving the editor. The editor is 26 `.chiral` modules and 6 roots. The
cockpit surfaces have worked examples and SPECs: `S14` author, `S15` run-view,
`S16` compose, `S17` token streaming.

The tracked home is what was owed. `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md`
numbers `S18` through `S32` with gates and a serial order, and it is the agent
tier. `docs/arcs/README.md` requires the arc file, and this is it.

## What was measured, 2026-09-02

`S18`, the `Scriba` state record, is **built**. `prog/scriba/editor-state.chiral`
defines `data Scriba` and the checklist's own row records the landing on
2026-08-23 with its measurements: 78 signatures, 367 argument sites over 318
lines, and nine threading shapes where the SPEC predicted one 11-parameter
thread.

The owed table in [[goals/local-ai]] and
`.planning/LOCAL-AI-ARC-REALIGNMENT.md` both carry `S18` as specced and unbuilt.
Both are stale. That measurement is `BA-43` in [[records/baseline-alignment]],
and S1 below is the repair.

## REQUIREMENTS

Done when all four hold.

1. **A run is driven end to end from the editor.** Author, compose, fire, watch,
   revise, with no step that leaves `prog/scriba/`. Observed by the `S14`,
   `S15`, `S16` and `S17` gates running against a live endpoint.
2. **A new surface adds a field to `Scriba`.** The parameter thread `S18`
   retired stays retired. Observed by the next surface's diff touching one
   record and its accessors.
3. **Authoring a config can save it.** `S14`'s SPEC defers write-back to E146,
   which is unbuilt, so a config authored in scriba is read-only today.
   Observed by writing one and reading it back.
4. **Every row this arc holds has a state here.** The checklist is the agent
   tier and dies with a worktree copy; the states a second reader needs live in
   this file. Observed by comparing the two.

## Rows

The checklist holds the full order. This file holds the rows in flight and their
states.

| row | what | state | element |
|---|---|---|---|
| `scriba/S1` | correct the two documents that carry `S18` as unbuilt | not started. `BA-43` holds the measurement | `S18` |
| `scriba/S2` | buffer list and switching, with the `chat` slot retiring into it | not started. Gated on D-S3 in the checklist | `S19` |
| `scriba/S3` | buffer-local state for an empty port set | not started. Gated on `S19` | `S20` |
| `scriba/S4` | split the orchestrator into its own node, so the editor stops holding network authority | not started. The checklist measures 87 network references in the editor's blob | `S20b` |
| `scriba/S5` | the `:` command registry as data | not started. Gated on `S19` | `S21` |
| `scriba/S6` | init-file load | blocked. `init-loader.chiral` returns a default stub, and the row is gated on E132, runtime dynamic loading, which is unbuilt | `S11` |

The local id and the `S#` stay paired for the life of the row, which is the
invariant `docs/decisions/decision-work-ids.md` carries.

## Resume state

**Where a session picks up.** `scriba/S1`, the two stale documents, then
`scriba/S2`. S2 is the checklist's own next row and it is unblocked.

**What blocks the arc.** Requirement 1 needs a live endpoint, which is
[[arcs/transport-arc]]'s T2. The two arcs serve one goal and this dependency is
the seam between them. Requirement 3 waits on E146, which has no arc and no
schedule.

**A trap already recorded.** The `S18` gate walked about 12 of 79 defs and
touched none of the manas, catalog, runview or chat defs, because those need a
live endpoint. A green S-series gate is therefore a claim about the editor's own
state and says little about a run.
