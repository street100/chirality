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
under `bin/chirality-bin`. The substrate is 9,930 lines under `prog/prapanca/`,
37 `.chiral` modules and 18 `.prog` roots, measured 2026-09-02. Phase 7 of
`tools/test/run-tests.sh` sweeps every root in the tree compile-only, and when
this arc opened no phase in the suite performed a model call. So the largest
body of built code in the repository was gated on whether it parses and lowers,
and on nothing else. Phase 20 judges the transport path's five roots.
`prog/prapanca/` stays compile-only.

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

Every extern declared under `lib/protocol/` and `prog/prapanca/` is either crossed
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
| `prog/samples/shilpa-probe.prog` | 17 | a full `agent-run` tool-call turn against `qwen3:8b` at `100.64.0.5:11434` | beyond the four below | no |

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
   exited 42, its header's code for status 200 with a non-empty body. Phase 20
   of `tools/test/run-tests.sh` compiles that root, runs it under a `timeout`
   and asserts 42. The assertion is deferred when `100.64.0.5:11434` does not
   answer a TCP probe.
3. **The streaming path gets the same treatment.** `chat-open`, `chat-read` and
   `chat-close` carry a run. All three ran on 2026-09-02.
   `prog/samples/stream-ollama.prog` exited 0 on a clean `[DONE]` against the
   live endpoint, and `prog/samples/e131_sse_socketpair.prog` exited 0 over a
   socketpair. Phase 20 asserts exit 0 on each, and asserts that
   `prog/samples/stream-ollama.prog` writes a non-empty stdout, which an exit
   code alone cannot show. The socketpair root is hermetic and hard-gated.
   `chat-open` is reached only by the endpoint-bound root, so on a box with no
   route the streaming open is deferred and `chat-read` and `chat-close` stay
   gated.
4. **An absent server produces a typed refusal.** A run against a closed port
   ends in a verdict. `prog/samples/e130_http_request_refused.prog` exited 42 on
   2026-09-02, the code its header gives when the conn-err arm yields status
   `-1`, and the root is hermetic. Phase 20 asserts 42 on every run, under a
   `timeout` so a regression that hangs fails loudly.

Requirement 1 holds as of 2026-09-02, and requirements 2 through 4 hold with it.
`tools/test/transport.sh` is the phase all three waited on. It compiles each
root with `bin/chirality-bin`, checks the artifact is non-empty, executes it and
judges the exit code, so the run is defended on every suite run and no longer
rests on a measurement performed by hand once. Two of its five assertions are
endpoint-bound and defer when the endpoint is silent.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `transport/T1` | restate the transport gap where it is recorded, against the 2026-09-02 measurement. done. `docs/goals/local-ai.md:110` landed in `9ef9448`; the orchestration-substrate row in [[status-ledger]] names the measured run and the absent gate. `records/author-calls.md` still carries the three-name reading and sits on another session's write surface, which moved its line number twice on 2026-09-02, so the citation names the file with no line number | record | decision | connect | 1 | built | `unminted` |
| `transport/T2` | a phase in `tools/test/run-tests.sh` that compiles `prog/samples/e130_http_get.prog`, runs it, and compares the exit code against the 42 its own header specifies. done. Requirement 2. Phase 20 is `tools/test/transport.sh`, registered at `tools/test/run-tests.sh:324`. It blobs the root through `chirality_blob_file "lib:prog"`, compiles it with `bin/chirality-bin`, refuses an empty artifact, runs it under a `timeout` and asserts exit 42. The root is non-hermetic, so the phase probes `100.64.0.5:11434` once and defers this assertion when the probe is refused, under the ruling at `prog/samples/e130_http_get.prog:8-9` | gate | tool | connect | 2 | built | `unminted` |
| `transport/T3` | the same phase treatment for `prog/samples/e131_sse_socketpair.prog`, header exit 0, and for `prog/samples/stream-ollama.prog`, header exit 0. done. Requirement 3. Phase 20 asserts exit 0 on `prog/samples/e131_sse_socketpair.prog`, hermetic and hard-gated, and exit 0 plus a non-empty stdout on `prog/samples/stream-ollama.prog`, which is endpoint-bound and deferred with T2's assertion. `chat-open` is reached only by the endpoint-bound one, so a box with no route gates `chat-read` and `chat-close` and defers the streaming open | gate | tool | connect | 3 | built | `unminted` |
| `transport/T4` | the same phase treatment for `prog/samples/e130_http_request_refused.prog`, header exit 42, as a negative control on T2. done. Requirement 4. Phase 20 asserts exit 42 against `127.0.0.1:1`, hermetic and hard-gated on every run, under a `timeout` because a hang is the failure this row watches for. It is the phase's negative control, and it is why the phase carries no mutant harness | gate | tool | connect | 4 | built | `unminted` |

### Coverage

Every requirement is served: 1 by T1, 2 by T2, 3 by T3, 4 by T4. Every row
serves one. Every `origin` is `connect`: `http-request` and `chat-open` are
built chirality defs and the whole arc is about reaching them from a gate.

### Two constraints on how T2 through T4 are built

**One file, two owners.**
`docs/decisions/decision-lane-split.md:243` gives transport "a new phase in
`tools/test/run-tests.sh`" as part of its measured file ownership.
`.planning/archive/handoffs/HANDOFF-DOC-SESSION.md:16` gives `tools/test/` to the parallel
compiler session and says it edits those files while other work runs. Two live
documents assign the same file to two lanes. The resume state below carries the
author's ruling for the Phase 20 change and says what it leaves standing.

**The suite does not run on this box.** `tools/test/run-tests.sh` needs more
than the 3.85 GB available, there is no swap, and it has OOM-killed sessions
(`.planning/archive/handoffs/HANDOFF-DOC-SESSION.md:34-36`). A new phase therefore has to be
runnable standalone, so that the root it compiles and executes can be judged
without the whole suite. `tools/test/transport.sh` is written that way and runs
as `bash tools/test/transport.sh`.

## Resume state

**Where a session picks up.** No row is open. T1 through T4 are done and all
four requirements hold as of 2026-09-02. The next work on this arc is minting,
which waits on the author.

**What blocks the arc.** No reserved element block, so T1 through T4 stay
`unminted` and cannot be scheduled as catalog work. Author call B in
[[records/author-calls]] is the ruling, and `arcs/text-tools-arc`'s P2 through
P4 wait on the same one.

**The `tools/test/run-tests.sh` ownership contention is settled for this
change.** The author gave the go-ahead directly on 2026-09-02 for Phase 20 to
be written into that file, and that ruling covers this change. The two documents
named above still disagree on paper: `docs/decisions/decision-lane-split.md:243`
gives the phase to transport and `.planning/archive/handoffs/HANDOFF-DOC-SESSION.md:16` gives
`tools/test/` to the parallel compiler session. Whoever holds those files owes
the repair.

**What the phase does not gate.** Three limits, each measured.

- `prog/samples/e130_http_get.prog` and `prog/samples/stream-ollama.prog` stay
  non-hermetic. Phase 20 probes `100.64.0.5:11434` once, and on a refusal it
  prints a DEFER block and counts both roots as neither passed nor failed.
- Requirement 3's `chat-open` is reached only by the endpoint-bound root, so on
  a box with no route the streaming open is deferred and only `chat-read` and
  `chat-close` stay gated, by `prog/samples/e131_sse_socketpair.prog`.
- `prog/samples/shilpa-probe.prog` carries no assertion. It is the sixth root and
  it sits beyond the four requirements.

**What has stopped blocking it.** Four things.

- The model server. `100.64.0.5:11434` answered `GET /v1/models` with
  `HTTP/1.1 200 OK` on 2026-09-02 from `claude-sandbox`, so the reachability
  blocker the arc recorded is retired. The non-hermeticity it brings stays, and
  `prog/samples/e130_http_get.prog:8-9` rules on how a phase handles it.
- Writing a gated root. Six roots covering all four requirements are already in
  `prog/samples/`.
- Running one. Five of the six were compiled with `bin/chirality-bin` and
  executed on 2026-09-02, each returning its header's success code, and the two
  endpoint-bound roots reached the live model.
- Judging one. `tools/test/transport.sh` compiles and runs all five and asserts
  each exit code, plus a non-empty stdout on the streaming root. Run standalone
  twice on 2026-09-02 it reported 5 passed, 0 failed, 0 deferred both times, and
  the streaming root printed different text on each run.

**A trap this arc has now hit three times.** The premise the arc was proposed
under was stale within a day of being written, because the proposal quoted a
ledger row rather than the tree. The resume state written after T1 was stale
the same way: it named a blocker, no reachable model server, and a shape of
work, write a gated root, that a read of `prog/samples/` and one TCP probe both
refuted. The `UNVERIFIED` flag on the root table is the third: it said nothing
had compiled or executed a root, and five roots compiled and ran on the first
attempt. Three instances in one arc, from the same cause. Measure the tree
before scoping a row.
