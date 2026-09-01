> **ARCHIVED 2026-09-01. Superseded by the E64-E68 rows in `docs/elements/ledger.md`, tracked.** The decision worth quoting rather than losing: **the transport is a hidden seam.** That is what made E130/E131 a data change rather than a redesign.

# Milestone: Orchestration module layer (Lisp-machine-like)

**STATUS: SUBSTRATE COMPLETE + HARDENED (2026-07-07).** Handoff reference for the
manas implementation agent: `scaffold/docs/orchestration.md` (module API, the
backend seam contract, idioms, and the primitive-request protocol). Four audit
rounds hardened the backend/streaming path (real OpenAI contract, SSE both frame
shapes, error-frame detection, surrogate-pair emoji, resource-close, transport-
failure-as-data); ergonomics `cond` + `tools/balance.py` landed. 262 tests green.
Owed: real-worker run on host; streaming wired into the cycle; persistence/retry.

Original completion note (2026-07-06). All six modules built + green (230 tests):
http (lib/http.chiral), json (lib/json.chiral), collections (lib/collections.chiral
extended), fsm engine (lib/fsm.chiral), model-backend seam (lib/backend.chiral), and
the manas conformance profile (lib/manas.chiral — cycle-step breaker + pure
run-recorded driver + effectful run-batch headless driver). Owed: real-worker run on
the host (ccbox refuses loopback TCP + egress); embed/search (need float vectors,
chirality is I64-only); train endpoints (unbuilt Python worker on shredtower).

Started 2026-07-06. Driven by the goal "manas in chirality" but scoped deliberately
**general**: build the reusable modules that make chirality a Lisp-machine-like
orchestration environment — network, JSON, collections, a state-machine engine,
a swappable backend interface — of which the **manas orchestration is one
conformance profile**, not the whole point. (Per the chirality principle: frozen base
+ named testable profiles; modularity = conformance, not configuration. A narrow
manas-only demo would violate it.)

## What grounded this (two scouts, 2026-07-06)

- **chirality:** effectful `main` already runs on the `RT` interpreter with real I/O via
  the `impl_ports.py` port externs. So functional orchestration needs **no native
  codegen, no E51 sys-face purity, no effect algebra** — the interpreter + coarse
  `=>` membrane suffice. The self-host/sys-face path (E51 + native sockets) is a
  **separate, later** TCB-shrink arc, NOT on this milestone's critical path.
- **manas:** the orchestration tier is **designed but unwritten** (only a ~200-line
  elisp HTTP client exists) — so this is green-field from `ARCHITECTURE.md`, not a
  port. manas is **HTTP-over-mesh**: the backend interface *is* the HTTP contract
  (`generate/chat`, `list-models`, `embed`, `search`, `train-start/status`,
  `health`, `unload`). The overnight-loop use case is **headless** (no Emacs UI).

## Decisions (user, 2026-07-06)

- **Scope:** build the general module set (Lisp-machine-like), not a narrow single
  cycle. manas is the conformance driver.
- **Transport:** **Python HTTP shim first** — an `http-request` extern in
  `impl_ports.py`. chirality does the logic; transport is Python (transitional), hidden
  behind the backend interface so it swaps for a chirality-native/sys-face transport
  later without touching orchestration code.

## The module set (ordering; each reusable, manas-agnostic)

1. **Network / HTTP effect** — `lib/http.chiral` (`HttpR`, `http-request`) + the
   `impl_ports` shim. The transport spine. **← this milestone starts here.**
2. **JSON** — `lib/json.chiral`: parse + serialize (chirality values ↔ JSON bytes).
   Needed by every backend call. The first real test of chirality's ergonomics for a
   nontrivial library.
3. **Collections** — audit/extend `lib/collections.chiral` (assoc maps, lists) to
   what orchestration state needs (registries, model lists, chunk-id arrays).
4. **State-machine engine** — `lib/fsm.chiral`: a general validated-transition FSM
   (states, a transition table, rejection of illegal moves). manas's 9-state
   inference/training machines are instances.
5. **Backend interface** — `lib/backend.chiral`: a record-of-effects capturing the
   HTTP contract (generate/embed/search/health/...), with one concrete HTTP+JSON
   implementation. THIS is the "replaceable backend" seam.
6. **manas profile** — compose the above into the manas orchestration cycle and a
   headless driver. The conformance instance that proves the modules hold.

## Explicitly NOT in this milestone
Native compilation of orchestration (RT is fine for an I/O-bound coordinator);
E51 sys-face linkage and native sockets (the TCB-shrink arc); the effect algebra
(edge 16 — coarse `=>` suffices here); the Emacs UI/panels and the chirality↔Emacs
transport boundary (the headless path sidesteps them); the worker's own
`train-start/status` endpoints (Python work, gates only the *train* step).

## Test posture in the sandbox
The real worker runs on shredtower over the mesh (unreachable from ccbox). Modules
are tested against **local mock HTTP servers on loopback**, which proves the shim +
chirality logic end-to-end without shredtower. A real-worker run is owed on the host.
