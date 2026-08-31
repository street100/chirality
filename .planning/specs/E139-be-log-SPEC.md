---
element: E139
slug: be-log
title: "be-log seam op"
kind: BUILD
example: examples/E139-be-log.md
status: audited
updated: 2026-08-15
---

# E139 SPEC — the `be-log` seam op (N3)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `manas/contract/manifest.chiral` gains
  `manifest-to-json : (-> RunManifest Json)` (PURE — the byte-for-byte inverse of
  E141's `manifest-from-json`, plus its array/object helpers), and a new
  `scaffold/lib/manas/pipeline/log.chiral` defines
  `be-log : (=> Backend RunManifest Str Unit)` (EFFECTFUL — serialize + POST the
  run record to `{base}/internal/log`). A pure JSON round-trip test
  (`e139_roundtrip.chiral`) proves `manifest-to-json` and `manifest-from-json` are
  inverses; `be-log` lowers under B1.
- **Non-goals:** the LIVE POST (the worker `/internal/log` endpoint is manas's
  unbuilt lane — deferred, decision #1); the `/internal/log/expert` per-call
  fan-out (decision #2); any change to `backend.chiral` (decision #3); retry /
  timeout on the POST (transport concern).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E139 postdates the CONFORMANCE-MAP snapshot
  (bundle §3). Treated as BUILD: no `be-log`, no `manifest-to-json` exist
  (`backend.chiral` grep-clean of `be-log`; `manifest.chiral` deserializes only).
- **Live code this composes with (name, do NOT respec):**
  - `manas/contract/manifest.chiral` (E141) — `manifest-from-json` + the field
    keys/shape this inverts (`config_binds` as a JSON **object** slot→{model,
    num_ctx}; the 15 top-level + 9 `ExpertCall` keys); the imports (`prelude`,
    `json`, `manas/core/types`) are already present.
  - `manas/contract/golden.chiral` (E141) — `manifest-conforms`, the round-trip
    assertion oracle.
  - `manas/core/types.chiral` (E133) — `RunManifest` / `ExpertCall` / `Binding`
    ctors (imported, never redefined).
  - `json.chiral` — `Json` ctors (`j-obj`/`j-arr`/`j-str`/`j-num`/`j-bool`),
    `json-show`, `json-parse-str`; `j-num` takes a `Str` lexeme.
  - `http.chiral` — `http-request : (=> Str Str Bytes HttpR)`, `HttpR` (`http-r`).
  - `backend.chiral` — `Backend`, `be-url : (-> Backend Str Str)`; `chat-body` is
    the precedent for foldl-not-map-list JSON array building.
  - `collections.chiral` — `foldl`, `append`; `prelude` — `str->bytes`,
    `i64->str`.
- **True delta:** the serializer half of the manifest I/O (E141 gave the
  deserializer) + the one new crossing that ships a run record.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Live POST to `/internal/log`? | DEFERRED (integration/debug pass) | The worker endpoint is manas's lane, unbuilt (catalog row: "the worker `/internal/log*` endpoints are the manas-side dep (Phase 2)"). Same posture as E138's deferred live model run (INDEX E138: "Live-model fan-out deferred to integration"). `be-log` compiles + lowers now; the gate is B1-lowers + the pure round-trip, not a wire call. |
| 2 | POST `/internal/log/expert` per-call too? | DEFERRED (with the live endpoint) | METIS-PORT-SPEC §1 names both endpoints for the `"be-log"` row, but a first runnable engine POSTs the whole manifest once (the per-expert split is a worker-side optimization). Deferred alongside decision #1's live endpoint — no separate catalog element needed (it is the same crossing, one more URL, added when the endpoint lands). |
| 3 | `be-log` home: `backend.chiral` (catalog) or `pipeline/log.chiral` (example)? | RESOLVED → `pipeline/log.chiral` | The catalog row sketched "a be-log def in backend.chiral", but the brief and example land it in `scaffold/lib/manas/pipeline/log.chiral`, matching METIS-PORT-SPEC §8's module map ("log.chiral — log-run (be-log …)") and the functional-core/imperative-shell split E138 established (pipeline/ holds the effectful shell). `manifest-to-json` (pure) stays in `contract/manifest.chiral` beside its inverse. |
| 4 | `manifest-to-json` home: new module or add to `manifest.chiral`? | RESOLVED → add to `manifest.chiral` | Two modules must not define the same top-level name, and the serializer reuses E141's ctors + imports. Adding it beside `manifest-from-json` keeps the inverse pair in one module and avoids a duplicate `import`/name. |
| 5 | Inspect the POST response status? | RESOLVED → no (fire-and-forget) | Logging is best-effort persistence; a failed log POST must not abort a completed run. `be-log` cases the `HttpR` and returns `unit`. A caller wanting delivery proof is a later signature change, not this crossing. |
| 6 | Round-trip test strategy | RESOLVED → `manifest-conforms orig (from-json (parse (show (to-json orig))))` | The example's conformance target. Structural equality via E141's oracle proves the inverse holds AND cross-checks E141's deserializer against this serializer. Negative controls prove rejection (decision surfaced in §5). |

No NEEDS-AUTHOR; nothing blocks §4.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `manifest-to-json` (pure serializer) in `manas/contract/manifest.chiral`
- **Target:** `scaffold/lib/manas/contract/manifest.chiral` — ADD after the
  deserializer/accessor block. `json`/`prelude`/`manas/core/types` are already
  imported; `foldl`/`append` live in `collections.chiral` (NOT `prelude`), which
  `manifest.chiral` does not yet import — so ADD `(import "collections")`.
- **Change:** add, in order — `strs->jarr : (-> (List Str) Json)`,
  `ints->jarr : (-> (List I64) Json)`, `ec-to-json : (-> ExpertCall Json)`,
  `ecs->jarr : (-> (List ExpertCall) Json)`,
  `binding->field : (-> Binding (Pair Str Json))`,
  `binds->jobj : (-> (List Binding) Json)`, and the 15-field
  `manifest-to-json : (-> RunManifest Json)`. Every array/object built with
  `foldl`+`append` (NOT `map-list` — E134 FLAG). JSON keys + `config_binds`
  object shape match E141's readers exactly (the round-trip closes). Copy the
  example §5 snippet verbatim.
- **Size:** M

### Step 2 — `be-log` (effectful crossing) in a new `manas/pipeline/log.chiral`
- **Target:** `scaffold/lib/manas/pipeline/log.chiral` — NEW FILE.
- **Change:** imports `prelude` (`str->bytes`), `backend` (`Backend`, `be-url`),
  `http` (`http-request`, `HttpR`), `json` (`json-show`),
  `manas/contract/manifest` (`manifest-to-json`). Define
  `be-log : (=> Backend RunManifest Str Unit)` =
  `manifest-to-json` → `json-show` → `str->bytes` →
  `http-request "POST" (be-url b "/internal/log")`, `case` the `HttpR`, return
  `unit` (fire-and-forget, decision #5). Copy the example §5 snippet.
- **Size:** S

### Step 3 — the pure round-trip test
- **Target:** `scaffold/tests/samples/e139_roundtrip.chiral` — NEW.
- **Change:** build a fully-populated `RunManifest` (every field non-default:
  fired ids, config_binds, chunks, one ExpertCall, combiner patches);
  `roundtrip = manifest-from-json ∘ json-parse-str ∘ json-show ∘ manifest-to-json`;
  assert `manifest-conforms orig (roundtrip orig)` = true, a mutated-stable copy
  does NOT conform after round-trip, and negative controls (malformed JSON string;
  a well-formed object missing `run_id`) both yield `none`. Pure blob (imports
  `manifest`, `golden`, `json` + their deps); `compile-main : (=> I64 I64)` exit
  0 iff all hold.
- **Size:** M

## 5. Conformance gate

- **Golden behavior:** `manifest-to-json` and `manifest-from-json` are inverses —
  a `RunManifest` serialized then deserialized structurally conforms to itself
  (`manifest-conforms` true); a mutated stable field breaks conformance
  (serializer faithfully carries the distinguishing data); malformed / incomplete
  JSON deserializes to `none`. `be-log` lowers under B1 as an effectful crossing
  linking `http`.
- **Tests to add:**
  - `scaffold/tests/samples/e139_roundtrip.chiral` — PURE, exit-code oracle, no
    linkage. Recipe: `chirality_blob scaffold/lib manas/contract/manifest
    manas/contract/golden json > blob`; append the sample; B1; run; exit 0.
  - `be-log`-lowers gate — `chirality_blob scaffold/lib manas/pipeline/log > blob` +
    linkage libs (`tal-ir crossing-wraps sys-check target-linux sys-tal
    sys-linkage`) + a compile-main that calls `be-log`; B1 exits 0 (NOT run — no
    endpoint).
- **Green line:** 709 test functions → round-trip sample added (+ the be-log
  lowers gate); ledger-lint clean.
- **Done when:** the round-trip sample exits 0 under B1 and the be-log leaf blob
  lowers (B1 exit 0).

## 6. Residue & links

- **Deliberately unbuilt:** the live POST + `/internal/log/expert` fan-out (home:
  decisions #1/#2, the manas worker endpoint + the integration pass — same
  crossing, no new element); response-status handling (home: a later signature
  change if delivery proof is ever needed).
- **Follow-on:** with `be-log` in place, the manas port has ALL its crossings —
  the effectful shell (`run-pipeline`, E138) can call `be-log` at run end to
  persist each run once the worker endpoint lands.
- **Related:** [[E141-golden-conformance]] (the inverse deserializer +
  `manifest-conforms`), [[E133-manas-core-types]] (`RunManifest`), [[E138-run-loop]]
  (the run loop that will call `be-log`).
