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

## What was measured, 2026-09-02, and it moved the premise three times

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
`records/author-calls.md`, under the heading "A reserved element block for the
local-ai goal", still describes this arc as "give `http-request`,
`backend-open` and `chat-open` a runtime referent". `records/` is another
session's write surface, so that repair is outstanding and belongs to whoever
holds the file.

### The model server is reachable

Probed from `claude-sandbox` on 2026-09-02.

| endpoint | result |
|---|---|
| `100.64.0.5:11434` | TCP connect succeeds. `GET /v1/models` returns `HTTP/1.1 200 OK`, 1,330 bytes complete under `Connection: close`, a JSON model list carrying fourteen model ids including `qwen3:8b`, `qwen2.5-coder:7b`, `gemma4:12b`, `qwen2.5:3b-instruct` and `qwen2.5:0.5b` |
| `127.0.0.1:11434` | connection refused |

The first probe of that endpoint recorded 1,201 bytes and a shorter id list.
That read was cut short by `Content-Length`. The full response is 1,330 bytes
and carries fourteen ids, and `qwen2.5:0.5b`, the model
`prog/samples/stream-ollama.prog` requests, is among them.

⚑ One box and one day, and the endpoint is off-tree. A phase that gates on it
is non-hermetic. `prog/samples/e130_http_get.prog:8-9` carries the author
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

### Five roots compile and run

Measured 2026-09-02 on host `claude-sandbox`. Compiler `bin/chirality-bin`. Blob
via `chirality_blob_file "lib:prog" <root>`, piped in under `ulimit -s
unlimited`, which is Phase 7's own invocation. One root at a time, a distinct
artifact path each, the artifact deleted once its exit code was read.

| root | artifact bytes | header contract | measured exit | runs |
|---|---|---|---|---|
| `prog/samples/e131_sse_framing.prog` | 94,584 | exit 0 iff all framing cases hold, 1 on mismatch | 0 | dispatched agent |
| `prog/samples/e130_http_request_refused.prog` | 90,488 | exit 42 when the conn-err arm yields status `-1`, 1 otherwise | 42 | agent, then the orchestrating session |
| `prog/samples/e131_sse_socketpair.prog` | 94,584 | exit 0 iff the chunk sequence holds, 2 on mismatch | 0 | dispatched agent |
| `prog/samples/e130_http_get.prog` | 90,488 | exit 42 on status 200 with a non-empty body, 1 otherwise | 42 | agent, then the orchestrating session |
| `prog/samples/stream-ollama.prog` | 90,488 | exit 0 on clean `[DONE]`, 1 on any `chunk-err` | 0 | agent, then the orchestrating session |

Every root returned its header's success code. No compile failed. Every artifact
was non-empty and complete. Neither a compile step nor a blob step wrote to
stderr. `MemAvailable` read 3,452,808 kB before the first compile and 3,422,028
kB after the last, holding a 3,437,176 to 3,452,808 kB band throughout, about 30
MB of drift across five compiles. Nothing was OOM-killed.
This measurement never invoked `tools/test/run-tests.sh`.

A model call runs in this tree as of 2026-09-02, non-streaming and streaming,
all chirality, zero Python. `prog/samples/stream-ollama.prog` printed different
stdout on its two runs, from the same binary against the same model
`qwen2.5:0.5b`:

```
agent run:         Hello. How may I assist you today?
orchestrator run:  Hello, how are you?
```

That divergence is evidence of a live call. A fixture repeats.

⚑ `prog/samples/e130_http_get.prog` and `prog/samples/stream-ollama.prog` are
non-hermetic by their own headers, and the endpoint was up for this run. Nothing
here measures what either does against a different or an absent endpoint.
`prog/samples/e130_http_request_refused.prog` is the hermetic negative control
and it is the root that covers the absent-peer case.

**The split inside requirement 3.** `prog/samples/stream-ollama.prog:29` calls
`chat-open`, and the loop it hands the stream to calls `chat-read` and
`chat-close`. It exited 0, so all three names of requirement 3 carry a run. The
hermetic split governs what a phase can gate on without the endpoint.
`prog/samples/e131_sse_socketpair.prog:25` builds its `ChatStream` by hand, so
`chat-read` and `chat-close` have a subject with no network under them, and
`chat-open` has a subject only while the endpoint answers. A phase that must
pass on a box with no route to `100.64.0.5` gates the socketpair root and defers
the streaming one under the ruling at `prog/samples/e130_http_get.prog:8-9`.

## REQUIREMENTS

Done when all four hold.

1. **The gap is stated in names the tree still has.** The orchestration-substrate
   row in [[status-ledger]] and the owed table in [[goals/local-ai]] name what is
   absent on the day they are read. Observed by grepping each name against the
   crossing table, the erase table and its `def` site.
2. **One non-streaming call runs end to end and is asserted.** A request leaves
   the tree, a typed result comes back, and a phase in `tools/test/run-tests.sh`
   judges it. The call ran on 2026-09-02: `prog/samples/e130_http_get.prog`
   exited 42, its header's code for status 200 with a non-empty body. The phase
   is owed.
3. **The streaming path gets the same treatment.** `chat-open`, `chat-read` and
   `chat-close` carry a run. All three ran on 2026-09-02.
   `prog/samples/stream-ollama.prog` exited 0 on a clean `[DONE]` against the
   live endpoint, and `prog/samples/e131_sse_socketpair.prog` exited 0 over a
   socketpair. The phase is owed.
4. **An absent server produces a typed refusal.** A run against a closed port
   ends in a verdict. `prog/samples/e130_http_request_refused.prog` exited 42 on
   2026-09-02, the code its header gives when the conn-err arm yields status
   `-1`, and the root is hermetic. The phase is owed.

Requirement 1 holds as of 2026-09-02, and the substance of requirements 2
through 4 holds with it. The one piece all three wait on is a phase in
`tools/test/run-tests.sh` that compiles a root, executes it, and judges the exit
code, so a run is defended on every suite run instead of performed by hand once.

## Rows

| row | what | state | element |
|---|---|---|---|
| `transport/T1` | restate the transport gap where it is recorded, against the 2026-09-02 measurement | done. `docs/goals/local-ai.md:110` landed in `9ef9448`; the orchestration-substrate row in [[status-ledger]] names the measured run and the absent gate. `records/author-calls.md` still carries the three-name reading and sits on another session's write surface, which moved its line number twice on 2026-09-02, so the citation names the file with no line number | `unminted` |
| `transport/T2` | a phase in `tools/test/run-tests.sh` that compiles `prog/samples/e130_http_get.prog`, runs it, and compares the exit code against the 42 its own header specifies | not started. Requirement 2. The root is verified: compiled with `bin/chirality-bin` and run 2026-09-02, exit 42 measured. It is non-hermetic, so the phase carries the deferral ruling | `unminted` |
| `transport/T3` | the same phase treatment for `prog/samples/e131_sse_socketpair.prog`, header exit 0, and for `prog/samples/stream-ollama.prog`, header exit 0 | not started. Requirement 3. Both roots are verified: compiled and run 2026-09-02, exit 0 measured on each. `chat-open` is reached only by the endpoint-bound one | `unminted` |
| `transport/T4` | the same phase treatment for `prog/samples/e130_http_request_refused.prog`, header exit 42, as a negative control on T2 | not started. Requirement 4. The root is verified: compiled and run 2026-09-02, exit 42 measured against a closed port, which is a verdict. It is hermetic | `unminted` |

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

**What has stopped blocking it.** Three things.

- The model server. `100.64.0.5:11434` answered `GET /v1/models` with
  `HTTP/1.1 200 OK` on 2026-09-02 from `claude-sandbox`, so the reachability
  blocker the arc recorded is retired. The non-hermeticity it brings stays, and
  `prog/samples/e130_http_get.prog:8-9` rules on how a phase handles it.
- Writing a gated root. Six roots covering all four requirements are already in
  `prog/samples/`.
- Running one. Five of the six were compiled with `bin/chirality-bin` and
  executed on 2026-09-02, each returning its header's success code, and the two
  endpoint-bound roots reached the live model.

What no phase does is judge an exit code, so every row below T1 stays
`not started` and `unminted`.

**A trap this arc has now hit three times.** The premise the arc was proposed
under was stale within a day of being written, because the proposal quoted a
ledger row rather than the tree. The resume state written after T1 was stale
the same way: it named a blocker, no reachable model server, and a shape of
work, write a gated root, that a read of `prog/samples/` and one TCP probe both
refuted. The `UNVERIFIED` flag on the root table is the third: it said nothing
had compiled or executed a root, and five roots compiled and ran on the first
attempt. Three instances in one arc, from the same cause. Measure the tree
before scoping a row.
