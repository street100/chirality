# Orchestration substrate — reference & handoff

This is the contract between the **chirality orchestration substrate** and the
**manas application layer**. It exists so a manas implementation agent can build
the app without re-deriving how the substrate works, and so requests for new
primitives have a clear shape.

## Division of labour

| Owns | Who | What |
|---|---|---|
| **Substrate** | this repo (chirality) | the language, the primitive/module set, the backend seam, the effect membrane. Anything under `lib/*.chiral` + the host bindings in `chirality/impl_*.py`. |
| **Application** | manas implementation agent | the Emacs/elisp UI, the specific agents and their tool wiring, the concrete cycle states, prompts and policy. Consumes the substrate; does not modify the kernel. |

The rule of thumb: **if it's a reusable capability (talk HTTP, parse JSON, drive a
state machine, call a model backend), it belongs in the substrate and is
general.** If it's "what manas specifically does with those" (which tools, which
agents, which UI), it belongs in the app. manas is a *conformance profile* of a
general orchestration layer, not the reason the layer exists.

When the app needs a capability the substrate doesn't have, **request a
primitive** (see the last section) rather than reaching around the seam.

## How orchestration code is shaped

Three structural facts govern everything below.

1. **The effect membrane.** `->` is a pure function; `=>` is a process function
   (may touch the network/OS). The type checker enforces the boundary. Anything
   that reaches the outside world — `http-request`, `chat-open`, the whole
   backend — is `=>`. Pure data shaping (JSON, collections, the cycle policy) is
   `->`. Keep the pure core large and the `=>` shell thin.

2. **The backend seam.** The model backend is the OpenAI-compatible HTTP
   contract (`lib/backend.chiral`). The *transport* underneath it is a swappable
   extern: today a Python `urllib` shim (`chirality/impl_ports.py`), tomorrow a
   chirality-native/sys-face transport — the orchestration code above never changes.
   Any OpenAI-compatible server (the manas worker, Ollama, vLLM, OpenAI itself)
   plugs in by base URL alone.

3. **Everything runs on the RT interpreter.** Functional manas needs no native
   codegen and no self-hosting: effectful `main` runs on the tree-walking runtime
   with real I/O through the port externs. Native/sys-face is a separate later
   TCB-shrink arc, not a prerequisite.

**Testing pattern (important).** Orchestration modules are tested against a mock
backend injected at the extern seam — `runtime.IMPLS["<extern>"] = mock` — which
is a legitimate second implementation of the contract, not a workaround. Never
hit a real model in a test. The mock asserts *both* directions of the seam: the
exact request bytes chirality builds, and how it parses each response shape. See
`tests/test_backend_iface.py` and `tests/test_backend_stream.py`. (A real-worker
run is owed on the host; ccbox blocks TCP, including loopback.)

## Module reference

The floor is `lib/prelude.chiral` (Bool, Maybe, List, Pair, Unit; I64 arithmetic;
`str-*`/`b*` string+byte prims). **I64 only — there is no float type.** Strings
are UTF-8. Build on the modules below; `(import "name")` pulls one in.

### lib/collections.chiral — lists, Maybe, association lists
Pure, polymorphic. `length append reverse map-list filter foldl foldr find
any-list concat head cat-maybes` over `List`; `maybe-map maybe-then with-default`
over `Maybe`; `str-join` for building URLs/bodies; `alist-get alist-put alist-has`
(caller supplies the key equality, e.g. `str-eq`). No hashtable yet — alists are
O(n), fine at current scale.

### lib/json.chiral — JSON parse + serialise
- `Json` = `j-null | j-bool Bool | j-num Str(lexeme) | j-str Str | j-arr (List Json) | j-obj (List (Pair Str Json))`. Numbers are kept as their raw lexeme (no float type).
- `json-show : Json -> Str` — serialise.
- `json-parse : Bytes -> Maybe Json`, `json-parse-str : Str -> Maybe Json`.
- Accessors: `obj-get : Json -> Str -> Maybe Json`, `as-str as-int as-bool as-arr as-numstr : Json -> Maybe X`.
- Handles escapes, raw multi-byte UTF-8, and `\u` **surrogate pairs** (emoji). Known limit: an uncaught `RecursionError` on pathological huge arrays (~10k+ elements) — never a normal response body.

### lib/http.chiral — the transport spine
- `HttpR` = `http-r (status I64) (body Bytes)`; `http-request : (=> Str Str Bytes HttpR)` (method, url, body). A transport failure surfaces as **status `-1` data**, not an alarm, so a loop counts it against its breaker instead of aborting.
- Streaming (pull-based, mirrors the socket port floor): `porttype ChatStream`; `ChatChunk = chunk (delta Str) s | chunk-done s | chunk-err (status I64) s`; `chat-open : (=> Str Str Bytes ChatStream)`, `chat-read : (=> (1 s ChatStream) ChatChunk)`, `chat-close : (=> (1 s ChatStream) Unit)`. The stream handle is **linear** (used exactly once per step). The shim owns SSE framing + delta extraction; chirality drives the pull and sees clean content strings.

### lib/fsm.chiral — a general Mealy state machine
- `Step S O = step-go (next S) (out (List O)) | step-halt (final S) (out (List O))`.
- `run-fsm : (-> S E (Step S O)) -> S -> (List E) -> (Pair S (List O))` — fold events, early-halt, outputs in order. `fsm-state`/`fsm-output` project the result. Domain-agnostic; the manas cycle is one instance.

### lib/backend.chiral — the model-backend seam (OpenAI-compatible)
Address a backend by base URL: `Backend = backend (base Str)`.
- `Msg = msg (role Str) (content Str)`; a conversation is a `List Msg`.
- `ChatR = chat-ok (text Str) | chat-bad (status I64) (raw Str)`.
- `be-chat : (=> Backend Str(model) (List Msg) ChatR)` — POST `/v1/chat/completions`, parses `choices[0].message.content`.
- `be-chat-stream : (=> Backend Str (List Msg) (=> Str Unit) ChatR)` — streaming; the `(=> Str Unit)` hook fires **per delta as it arrives**; returns the assembled text (or `chat-bad` on a mid-stream error — including an Ollama `{"error":...}` frame).
- `be-health : (=> Backend Bool)` — GET `/internal/health`.
- `be-models : (=> Backend (List Str))` — GET `/v1/models`, model ids.
- `be-embed : (=> Backend Str(text) Str(source_type) (Maybe I64))` — POST `/internal/embed`, returns the stored `chunk_id` (the vector lives worker-side; ids+text cross the wire, no float needed).
- `be-search : (=> Backend Str(query) I64(k) (List Hit))` — POST `/internal/search`; `Hit = hit (chunk-id I64) (content Str) (distance Str-lexeme)`.

Grounded in `/workspace/manas/manas-worker/manas_worker/{app.py,serve/router.py}`.
`train-start`/`train-status` are documented-not-built worker-side; add when they land.

### lib/string-utils.chiral — pure string helpers
`str-starts-with`, `str-strip-prefix`, `str-contains`, `str-split` — over the
prelude str prims. For router prefix-parsing (N2) and coordinator plumbing.

### lib/coordinator.chiral — the thin cycle (run-me-first)
The minimal end-to-end loop, built to be **run** against a real worker so friction
reveals the full cycle's needs: `run-cycle : (=> Backend Str(prompt) ChatR)` =
`route` (stub → default model) → `be-search`+inject (hits as a system `Msg`) →
`be-chat-stream` (one `put` per delta to stdout) → `ChatR`. Each stage is a seam
the real thing (N1/N2/N3) slots into. Deliberately one turn, no breaker.

Process-face primitives it uses (declared in `lib/ports.chiral`): `put : (=> Str
Unit)` writes a delta to stdout **with no trailing newline** (the coordinator's
streaming output — a per-delta newline would corrupt the stream a reader
reassembles); `sleep-ms : (=> I64 Unit)` blocks the runtime n ms (poll cadence
for the future training-status monitor, N4).

### lib/manas.chiral — the batch-driver profile (worked example)
Functional core + imperative shell. `cycle-step` is the pure policy (a
circuit breaker: halt after `fail-limit` consecutive backend failures), expressed
as an fsm `Step`. `run-recorded` drives it purely over a recorded `List Turn`;
`run-batch : (=> Backend Str (List Str) (List Turn))` is the effectful driver that
generates each prompt and threads the same breaker. Read this module as the
template for composing the substrate.

## Writing chirality modules — idioms & gotchas

- **Forward declaration** (for mutual recursion): `(declare name TY)` then a
  **body-only** `(def name BODY)` — do *not* repeat the type on the `def`, or you
  get "global redefined".
- **`cond` for multi-way branches**: `(cond (c1 e1) (c2 e2) (else z))` instead of a
  right-nested `case` ladder. Desugars to `case`; the last clause must be `else`.
- **Sequence effects / consume linear resources with `do`**: `(do e1 e2)` runs
  `e1` for effect then returns `e2`. Use it (not `(let (u e1) e2)`) whenever you
  consume a linear port — `let` fails the linearity check.
- **Linear ports** thread the handle back through the result (see `ChatStream` /
  `chat-read`): each branch either recurses with the returned handle exactly once
  or closes it exactly once. A linear param in a declared type needs the
  `(1 s TY)` binder form.
- **Constructors infer their type params** — write `(step-go ns outs)`, not
  `(step-go S O ns outs)`. But a constructor **can't be passed bare** as a
  function (it carries quantity annotations); wrap it: `(lam (h t) (cons h t))`.
- **Balance parens** with `python3 tools/balance.py [file...]` — it reports the
  exact line where depth goes wrong and which top-level form was left open. Run it
  after editing; it's faster than chasing a terse load error.
- **Run tests**: `python3 -m unittest discover -s tests` (or a single module,
  `python3 -m unittest tests.test_backend_iface`). Type-check a module without the
  runtime: `chirality check scaffold/lib/<mod>.chiral` (native, no Python).
- **Smoke-test against a real worker**: `python3 tools/smoke.py http://<host>:<port> [model]`
  drives the *real* shims (no mocks) — health, models, chat, stream, embed,
  search, and the thin cycle — printing a pass/fail checklist. Runs on the host
  once the worker is up; inside ccbox every step degrades to a transport failure
  (proof the plumbing is intact). This is the first-real-cycle gate.

## Requesting a new primitive (the protocol)

When the app needs something the substrate lacks, open a request describing:

1. **The operation** and its **effect class** (`->` pure or `=>` process).
2. **The wire/OS contract** if it crosses the membrane (endpoint + request/response
   shape, or syscall + argument types).
3. **The typed face** you want to call from chirality (the extern/module signature).

The substrate side then adds: the typed extern (its type owned in chirality source),
the host binding behind the membrane (`impl_ports.py`/`impl_pure.py`), any module
functions, and tests (mock at the extern seam, both directions).

### Known gaps / likely near-term requests

- **Persistence** — `run-batch` returns an in-memory `List Turn`; an overnight loop
  needs a transcript appended to disk (a file/append primitive on the port face).
- **Streaming into the cycle** — now wired in `lib/coordinator.chiral` (`run-cycle`
  uses `be-chat-stream` with a `put`-per-delta hook). The batch breaker
  (`manas.cycle-step`) is not yet folded into this thin loop — that's the N1
  step, once the loop has run for real.
- ~~a `sleep-ms` primitive~~ **DONE** — `(=> I64 Unit)` in `ports.chiral`, for the
  N4 poll cadence.
- **Retry/backoff** — the breaker only counts and halts; no re-attempt policy.
- **Per-call timeout** — `http-request` shares one 300s ceiling; fast liveness
  probes want a shorter cap (thread a timeout param through the extern).
- **`Maybe` threading sugar** — `chat-content` is still a deep nested `case`; a
  `do`/thread form for `Maybe` unwrap-chains would flatten it (proposed).
- **`be-search`/`be-models` empty-vs-failure** — both return `nil` on a shape
  mismatch, indistinguishable from "no results"; grow to `Maybe` when
  `/internal/search` is built worker-side.
- **Multi-turn / tool-calling** — `Msg` history already supports multi-turn; a
  tool/function-call schema on top is unbuilt.
