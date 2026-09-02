---
node: arc-transport
layer: navigation
related: [arcs/README, goals/local-ai, records/author-calls, records/baseline-alignment, status-ledger, decision-work-ids, decisions/decision-lane-split, index]
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

## What was measured, 2026-09-02, and it moved the premise twice

### The three names the gap was stated in

`docs/definitions/status-ledger.md` and the owed table in [[goals/local-ai]]
both stated the gap as three externs missing from
`lib/lowering/tal/crossing-wraps.chiral`. Two of the three stopped being
externs when E130 and E131 landed.

| name | measured state |
|---|---|
| `http-request` | a chirality `def` at `lib/protocol/http.chiral:437`, over the socket caps. E130 is BUILT in the catalog |
| `chat-open` | a chirality `def` at `lib/protocol/http.chiral:773`. E131 is BUILT in the catalog |
| `backend-open` | still an extern, and erased to `nb-id` at `lib/lowering/tal/erase.chiral:123`, so a crossing entry is the wrong home for it |

Every extern declared under `lib/protocol/` and `prog/manas/` is either crossed
or erased: `backend-close`, `backend-open`, `be-base` and `be-peek` erase,
`close` crosses. That measurement is `BA-42` in [[records/baseline-alignment]],
and T1 is the repair.

One statement of the three-name reading survives outside T1's reach.
`records/author-calls.md:139`, the row headed "A reserved element block for the
local-ai goal", still describes this arc as "give `http-request`,
`backend-open` and `chat-open` a runtime referent". `records/` is another
session's write surface, so that repair is outstanding and belongs to whoever
holds the file.

### The model server is reachable

Probed from `claude-sandbox` on 2026-09-02.

| endpoint | result |
|---|---|
| `100.64.0.5:11434` | TCP connect succeeds. `GET /v1/models` returns `HTTP/1.1 200 OK` with `Content-Length` 1201, a JSON model list carrying `qwen3:8b`, `qwen2.5-coder:7b`, `gemma4:12b` and `qwen2.5:3b-instruct` |
| `127.0.0.1:11434` | connection refused |

⚑ One probe, one day, one box, and the endpoint is off-tree. A phase that gates
on it is non-hermetic. `prog/samples/e130_http_get.prog:8-9` carries the author
ruling for that case: golden-check deferral if the endpoint is unreachable,
report honestly, do not gate on it. A phase built for requirement 2 or
requirement 3 honors that ruling.

### The roots already exist

Each of T2, T3 and T4 was written as owing a gated root. Every root is written
and in the tree.

| root | lines | what it does | requirement | hermetic |
|---|---|---|---|---|
| `prog/samples/e130_http_get.prog` | 21 | `http-request "GET" "http://100.64.0.5:11434/v1/models"`, exit 42 on status 200 with a non-empty body, exit 1 otherwise | 2 | no, needs the endpoint |
| `prog/samples/e130_http_request_refused.prog` | 25 | `http-request "GET" "http://127.0.0.1:1/"`, exit 42 when the conn-err arm yields status `-1` | 4 | yes, port 1 is closed |
| `prog/samples/e131_sse_socketpair.prog` | 54 | writes a canned SSE stream into a socketpair, wraps the far end as a `ChatStream`, loops `chat-read` asserting `hello`, `world`, `chunk-done`, then `chat-close` on a done handle and a dead handle. Exit 0, or 2 on mismatch | 3, in part | yes |
| `prog/samples/stream-ollama.prog` | 29 | `chat-open "POST" .../v1/chat/completions` then a `chat-read` loop, exit 0 on clean `[DONE]`, 1 on any `chunk-err`. Model `qwen2.5:0.5b` | 3, the rest | no, needs the endpoint |
| `prog/samples/e131_sse_framing.prog` | 57 | pure framing golden over hardcoded `Bytes`, no socket | supporting | yes |
| `prog/samples/agent-probe.prog` | 17 | a full `agent-run` tool-call turn against `qwen3:8b` at `100.64.0.5:11434` | beyond the four below | no |

⚑ UNVERIFIED: nothing in this session compiled or executed any of these roots.
Phase 7 sweeps them compile-only and none is on its known-failing list, which is
evidence that they compile and no evidence about what they do when run.

**The split inside requirement 3.** `e131_sse_socketpair.prog:25` constructs its
`ChatStream` by hand, so it gives `chat-read` and `chat-close` a subject and
reaches `chat-open` never. `stream-ollama.prog:29` is the only caller of
`chat-open`, and it needs the endpoint. Requirement 3 therefore has a hermetic
root for two of its three names and an endpoint-bound root for the third.

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

Requirement 1 holds as of 2026-09-02. Requirements 2 through 4 each wait on the
same missing piece: a phase that executes a root and judges its exit code.

## Rows

| row | what | state | element |
|---|---|---|---|
| `transport/T1` | restate the transport gap where it is recorded, against the 2026-09-02 measurement | done. `docs/goals/local-ai.md:110` landed in `9ef9448`; the orchestration-substrate row in [[status-ledger]] names the absent run and the two phases that do not supply it. `records/author-calls.md:139` still carries the three-name reading and sits on another session's write surface | `unminted` |
| `transport/T2` | a phase in `tools/test/run-tests.sh` that compiles `prog/samples/e130_http_get.prog`, runs it, and compares the exit code against the 42 its own header specifies | not started. Requirement 2. The root is written and non-hermetic | `unminted` |
| `transport/T3` | the same phase treatment for `prog/samples/e131_sse_socketpair.prog`, header exit 0, and for `prog/samples/stream-ollama.prog`, header exit 0 | not started. Requirement 3. Both roots are written; `chat-open` is reached only by the endpoint-bound one | `unminted` |
| `transport/T4` | the same phase treatment for `prog/samples/e130_http_request_refused.prog`, header exit 42, as a negative control on T2 | not started. Requirement 4. The root is written and hermetic | `unminted` |

### Two constraints on how T2 through T4 are built

**One file, two owners, unresolved.**
`docs/decisions/decision-lane-split.md:243` gives transport "a new phase in
`tools/test/run-tests.sh`" as part of its measured file ownership.
`.planning/HANDOFF-DOC-SESSION.md:16` gives `tools/test/` to the parallel
compiler session and says it edits those files while other work runs. Two live
documents assign the same file to two lanes. This is an open coordination
question for the author and no row here settles it.

**The suite does not run on this box.** `tools/test/run-tests.sh` needs more
than the 3.85 GB available, there is no swap, and it has OOM-killed sessions
(`.planning/HANDOFF-DOC-SESSION.md:34-36`). A new phase therefore has to be
runnable standalone, so that the root it compiles and executes can be judged
without the whole suite.

## Resume state

**Where a session picks up.** T2. Requirement 1 is met, and T2 is the first row
whose subject is a phase.

**What blocks the arc.** No reserved element block, so T2 through T4 write
`unminted` and cannot be scheduled as catalog work. Author call B in
[[records/author-calls]] is the ruling, and `arcs/text-tools-arc`'s P2 through
P4 wait on the same one. The `tools/test/run-tests.sh` ownership contention
above is the second block, and it is an author call as well.

**What has stopped blocking it.** Two things.

- The model server. `100.64.0.5:11434` answered `GET /v1/models` with
  `HTTP/1.1 200 OK` on 2026-09-02 from `claude-sandbox`, so the reachability
  blocker the arc recorded is retired. The non-hermeticity it brings stays, and
  `prog/samples/e130_http_get.prog:8-9` rules on how a phase handles it.
- Writing a gated root. Six roots covering all four requirements are already in
  `prog/samples/`. What no phase does is execute one.

**A trap this arc has now hit twice.** The premise the arc was proposed under
was stale within a day of being written, because the proposal quoted a ledger
row rather than the tree. The resume state written after T1 was stale the same
way: it named a blocker, no reachable model server, and a shape of work, write a
gated root, that a read of `prog/samples/` and one TCP probe both refuted. Two
instances in one arc, from the same cause. Measure the tree before scoping a
row.
