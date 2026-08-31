# chirality-lane response to the manas orchestration contract

**Re:** `manas/.planning/CHIRALITY-CONTRACT.md` (DRAFT v0) + handoff message.
**From:** chirality lane. **Status:** feasibility gut-check; not a commitment to build (heads-up received, not acting yet).
**Date:** 2026-07-07.

## Verdict

**All of N1–N5 are feasible. Nothing is hard or impossible with chirality as it's
evolving.** The substrate as it stands covers most of it; the genuinely *new*
work is either mechanical (N3 seam ops = the pattern we've shipped 6×) or a
known composition pattern (N4 = functional-core/imperative-shell, same as
`cycle-step` + `drive-batch`). I foresee **three small primitive additions**, all
easy, called out below. The float rule holds and matches the design — no pushback.

## Stability commitment (the "keep stable or flag" ask)

Confirmed stable, will not churn signatures: `be-chat`, `be-embed`, `be-search`,
`be-health`, `be-models`, `fsm.{drive,run-fsm,Step}`, `manas.cycle-step`/`run-batch`,
`json`, `collections`. The exact current signatures are in
`chirality/scaffold/docs/orchestration.md` — build against that, not the
contract's prose.

**Two corrections to your §2 snapshot (it predates the audit rounds):**
- `be-chat-stream` now returns **`ChatR`**, not `Str`: `(=> Backend Str(model) (List Msg) (=> Str Unit) ChatR)`. The `(=> Str Unit)` is the per-delta hook; the `ChatR` return means a **mid-stream failure is not silent** (`chunk-err`/Ollama `{"error":…}` → `chat-bad`). This is a *hardening* you want — but pin to it.
- It's **262 tests** now (was 230): four audit rounds added the real OpenAI contract, SSE dual-frame + error-frame handling, surrogate-pair emoji, resource-close, transport-failure-as-data. Still mock-only — N5 is still owed.

## Per-ask feasibility

**N1 — cycle profile (route → search+inject → chat-stream → log).** EASY.
Structurally it's `run-batch` with more stages per turn, all composable:
- *inject* = pure: map `be-search` hits into a context `Msg`, prepend to the user `Msg` list. `collections` + `Msg` cover it.
- *chat-stream* = `be-chat-stream`; the on-delta hook streams to the cockpit (see subprocess note). Its `ChatR` return gives you the full assembled text for the log step in the same call.
- *log* = Fork A (below).
- *breaker* = `cycle-step` folded in exactly as `run-batch` does.
No new language features. No blocker.

**N2 — router.** EASY. Rules-only in pure chirality is trivial now that `cond`
exists (string dispatch via `str-eq`/`starts-with`/`str-sub`). Zero new seam ops
for the rules-only cut. The similarity variant is just one seam op returning a
worker-chosen **id string** (no scores cross). Likely small ask: a
`string-utils` helper (prefix-strip / split) for technique-prefix parsing —
minor, flagged below.

**N3 — new seam ops.** EASY / mechanical. Each is the proven `be-embed`/`be-search`
pattern: build a JSON request, `http-request`, parse the response. All payloads
cross as ids / string lexemes / records — metrics (loss etc.) as `Str` like
`distance`, so no floats. Path-param URLs (`/train/status/{job_id}`) are just
`str-cat`. `be-registry-*` returning rows = a `List` of parsed records, same as
`be-search`'s `List Hit`. ~15 lines + a test each. No blocker.

**N4 — training-monitor FSM.** FEASIBLE, and here's the one design note worth
stating up front: **use the effectful-driver pattern, not `run-fsm`.** `run-fsm`
is a *pure fold over a known event list* — a monitor's events aren't known up
front; each is produced by an effectful `be-train-status` poll that depends on
the prior state. So the shape is a pure `train-step : State -> Status -> Step`
(the policy — continue-poll / done / failed) driven by an **effectful loop** that
polls, feeds the result to `train-step`, and on `step-go` waits + polls again.
That's exactly `cycle-step` + `drive-batch`. OOM/SIGKILL/timeout all arrive as
*data* the step branches on (a failed status, or a negative HTTP status from the
shim). Timeout is expressible today via `time-mono` vs a deadline.
- **One new primitive needed:** a `sleep-ms`/`delay` extern (`=> I64 Unit`) for the
  poll cadence — there's no sleep today (only `time-mono` + `poll2`-with-timeout).
  Trivial to add (`time.sleep` in the shim). Without it a poller busy-spins.
- No concurrency primitive needed: training ⊥ inference on the single GPU, and if
  the monitor is a separate spawned process it's OS-level parallelism, not
  chirality-level. Good.

**N5 — real-worker run.** Not chirality code — it's the integration, and it's the
**win**: it closes the "real-worker run owed" gap my milestone carries. From the
chirality side all I need is the base URL pointing at the real worker; the worker
must honor the OpenAI contract + the `/internal/*` routes (your lane). I'll hand
you a small **host-runnable smoke script** (`/v1/chat/completions` + `/internal/health`
+ one `be-embed`/`be-search` round-trip) so the first real call is a known-good
checklist, not a debugging session. This is the highest-value thing to do early —
don't let the app build far on an unexercised transport.

## Audit inferences I can resolve from the chirality side

- **C2 (float rule honored):** CONFIRMED. `Hit.distance` is `Str` (raw lexeme via `as-numstr`); `be-embed` returns `Maybe I64` (chunk_id). No float crosses the seam anywhere. Design fits the rule with zero changes.
- **C4 (subprocess-stdio streaming):** chirality's half is **sound**. The on-delta hook is `(=> Str Unit)`; wiring it to the `print` extern streams each delta to stdout, which the cockpit reads. **Open coordination item you haven't pinned:** how the *input* (the user prompt / cycle request) reaches the chirality coordinator process. chirality supports three today — stdin (`read` fd 0), env (`env-get`), or a CLI arg — pick one when you design the cockpit↔chirality transport (your §6 marks that transport deferred). Not a blocker; just needs a decision before N1 ships.
- **C5 / C7** (N5 == Plan 01-06; the decision-overturn): your lane, can't confirm.

## The two forks — chirality-side read

- **Fork A (interactions row).** chirality is ~indifferent; both are cheap. Slight lean **A2** (chirality emits the record on stdout, Emacs owns the table): it keeps the cycle self-contained — no mid-cycle network dependency on a worker endpoint just for its own bookkeeping — and the log step becomes a pure `print` of a JSON record we already have in hand. A1 (worker writes via `be-log-interaction`) is one extra seam op, ~equal effort. **Your call** — it's a table-ownership/SQLite-discipline decision, which is your lane. Either way N1 is unaffected in shape.
- **Fork B (rules-only v1).** Agree with your lean: **rules-only first** — zero new seam ops, pure chirality, and `cond` makes it clean. Add `be-route` (similarity) later behind the same seam without touching the rules path.

## Primitive gaps I foresee (pre-heads-up, so nothing surprises you)

1. `sleep-ms` / `delay` extern — for N4 poll cadence. Small.
2. `string-utils` helper (prefix-strip / split) — for N2 technique-prefix routing. Small, pure.
3. The cockpit→chirality **input channel** decision (stdin / env / arg) — no code gap, a choice.

None of these are blockers or research; all fit the existing extern/module pattern.

## What I'm doing with this

Factoring it in, not building (heads-up received). I'll keep the surface stable
and hold the three small primitives in the queue. Ping me when Forks A/B resolve
and the base URL / mesh wiring is ready, and I'll send the smoke script first.
