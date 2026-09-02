---
node: arc-transport
layer: navigation
related: [arcs/README, goals/local-ai, records/author-calls, records/baseline-alignment, status-ledger, decision-work-ids, index]
status: current
updated: 2026-09-02
---

# Arc: a model call that runs in this tree

- goals: [[goals/local-ai]]
- reserved element block: **none**. Rows carry arc-local ids `T1` and up, per
  [[decisions/decision-work-ids]], and map to `unminted`. Author call B in
  [[records/author-calls]] is the ruling that would give this arc a band.
- build-state authority: [[status-ledger]]

Opened 2026-09-02 from `.planning/LOCAL-AI-ARC-REALIGNMENT.md` section 3A. The
goal was stated on 2026-09-01 and carried no arc, so criterion 1 had no path to
work.

## Why this arc exists

Criterion 1 of [[goals/local-ai]] asks for a gated multi-agent run end to end
under `bin/chirality-bin`. The substrate is 9,930 lines under `prog/manas/`,
37 `.chiral` modules and 18 `.prog` roots, measured 2026-09-02. Phase 7 of
`tools/test/run-tests.sh` sweeps every root in the tree compile-only, and no
phase in the suite performs a model call. So the largest body of built code in
the repository is gated on whether it parses and lowers, and on nothing else.

## What was measured, 2026-09-02, and it moved the premise

`docs/definitions/status-ledger.md` and the owed table in [[goals/local-ai]]
both state the gap as three externs missing from
`lib/lowering/tal/crossing-wraps.chiral`. Two of the three stopped being
externs when E130 and E131 landed.

| name | measured state |
|---|---|
| `http-request` | a chirality `def` at `lib/protocol/http.chiral:437`, over the socket caps. E130 is BUILT in the catalog |
| `chat-open` | a chirality `def` at `lib/protocol/http.chiral:773`. E131 is BUILT in the catalog |
| `backend-open` | still an extern, and erased to `nb-id` at `lib/lowering/tal/erase.chiral:123`, so a crossing entry is the wrong home for it |

Every extern declared under `lib/protocol/` and `prog/manas/` is either crossed
or erased: `backend-close`, `backend-open`, `be-base` and `be-peek` erase,
`close` crosses. The recorded gap therefore names three things that no longer
describe it. That measurement is `BA-42` in [[records/baseline-alignment]], and
T1 below is the repair.

What survives the re-measurement: nothing in this tree has run against a model
server since the CPython transport was cut, and the one root that binds a client
connect sits on the suite's known-failing list with the reason *"needs a live
peer"*.

## REQUIREMENTS

Done when all four hold.

1. **The gap is stated in names the tree still has.** The orchestration-substrate
   row in [[status-ledger]] and the owed table in [[goals/local-ai]] name what is
   absent on the day they are read. Observed by grepping each name against the
   crossing table, the erase table and its `def` site.
2. **One non-streaming call runs end to end and is asserted.** A request leaves
   the tree, a typed result comes back, and a phase in `tools/test/run-tests.sh`
   judges it. Observed by that phase.
3. **The streaming path gets the same treatment.** `chat-open`, `chat-read` and
   `chat-close` carry a run. A compile leaves requirement 3 open.
4. **An absent server produces a typed refusal.** The same phase run against a
   closed port ends in a verdict rather than a hang. Observed by running it.

## Rows

| row | what | state | element |
|---|---|---|---|
| `transport/T1` | restate the transport gap where it is recorded, against the 2026-09-02 measurement | not started. `BA-42` holds the measurement | `unminted` |
| `transport/T2` | a gated root that performs one non-streaming call and asserts the result | not started. Requirement 2 | `unminted` |
| `transport/T3` | the same for the streaming path | not started. Requirement 3 | `unminted` |
| `transport/T4` | the absent-server refusal, as a negative control on T2 | not started. Requirement 4 | `unminted` |

## Resume state

**Where a session picks up.** T1, because T2 cannot be scoped against a gap
statement that is three names out of date. T1 is a documentation repair with a
measurement behind it and needs no element number.

**What blocks the arc.** Two things, and they block different halves.

- No reserved element block, so T2 through T4 write `unminted` and cannot be
  scheduled as catalog work. Author call B in [[records/author-calls]] is the
  ruling, and `arcs/text-tools-arc`'s P2 through P4 wait on the same one.
- Requirements 2 through 4 need a reachable model server. Nothing under
  `docs/benchmarks/` times a model call, so the cost of one is unmeasured here.

**A trap already recorded.** The premise this arc was proposed under was stale
within a day of being written, because the proposal quoted a ledger row rather
than the tree. Re-measure the three names before working T2.
