---
element: E139
slug: be-log
title: "be-log seam op"
kind: BUILD
reference_class: OURS/SPEC
ours_source: (none — design from METIS-PORT-SPEC §1 + §8)
status: drafted
updated: 2026-08-15
---

# E139 — the `be-log` backend seam op (N3)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E139 — the run-record crossing. Serialize a `RunManifest` to JSON
  (`manifest-to-json`, PURE) and POST it to the worker's `/internal/log`
  (`be-log`, EFFECTFUL), so every orchestration run is persisted.
- **Kind:** BUILD (BUILD-PROPER — no run-record crossing exists in chirality;
  `backend.chiral` has no `be-log`, and `manifest.chiral` deserializes but does not
  serialize a `RunManifest`).
- **Why chirality needs its own:** this is the ONLY missing crossing in the whole
  manas port (METIS-PORT-SPEC §1, row `"be-log"`). Without it a run is computed
  but never recorded; with it, `manifest-to-json` is the provable inverse of
  E141's `manifest-from-json`, so a run written by one process reads back
  identically in another — persistence with a checkable round-trip, not a
  hope-it-matches dict dump.

## 2. Research

- **Reference class:** OURS/SPEC — `METIS-PORT-SPEC.md §1` (the `be-log` effect
  row: `"be-log"` = POST `/internal/log`; all `be-*` sit atop the `http-request`
  transport) + `§8` (the 15 `RunManifest` fields being serialized) + the E141
  siblings `prapanca/contract/manifest.chiral` (the deserializer + accessors this
  inverts) and `prapanca/contract/golden.chiral` (`manifest-conforms`, the round-trip
  assertion).
- **Key findings:**
  1. **`manifest-to-json` is the exact inverse of `manifest-from-json` (E141).**
     Same 15 top-level JSON keys, same 9 `ExpertCall` keys, same `config_binds`
     shape (a JSON OBJECT `slot -> {model, num_ctx}`, NOT an array — E141's
     `binds-from-json` cases on `j-obj`). Matching the key names and the
     object-vs-array shape is what makes the round-trip close.
  2. **No float type.** `num_ctx`, `duration_ms`, and the `context_chunks_used`
     ids are `I64`; they serialize via `i64->str` into `j-num` (which takes a
     `Str` lexeme). Parse reads them back with `str->i64`. Lossless.
  3. **Arrays fold, they do not `map-list`.** `map-list` does NOT lower in a leaf
     blob (E100 `$apply` residual; E134's FLAG, mirrored by `chat-body` in
     `backend.chiral`). So `fired_expert_ids`, `combiner_patches`,
     `context_chunks_used`, `expert_calls`, and the `config_binds` object are each
     built with `foldl`+`append` — element → `Json`, appended in order.
  4. **The worker endpoint is manas's lane, unbuilt.** `/internal/log` does not
     exist yet, so a LIVE POST is deferred to the integration pass (like E138's
     live run). `be-log` COMPILES + lowers now; the gate is (a) it lowers under
     B1, (b) the pure round-trip test passes.

## 3. Conventional (other-language) approach

The Python driver builds the manifest as a `dict`, dumps it, and fires a POST —
serialization and network fused, no proof either half is what it claims:

```python
def log_run(base, manifest: dict, run_dir: str):
    body = json.dumps(manifest).encode()           # untyped dict -> bytes
    requests.post(f"{base}/internal/log", data=body)  # network call, inline
    # a typo'd key ships silently; the "does this touch the network" question
    # has no answer in the type — log_run and a pure helper look identical.
```

- **Assumptions it bakes in:** the manifest is an untyped `dict` (a missing/typo'd
  key is a silent partial record, caught only when something later reads it); the
  serialize step and the network step are one function, so nothing proves the
  serializer is pure; a float sneaks in wherever a number is (no I64 wall).

## 4. The chirality idea

- **Chirality features in play:** the effect membrane (`->` for `manifest-to-json`,
  `=>` for `be-log`, effect row `("http-request")`); the float→I64 wall (`j-num`
  from `i64->str`, never a float); errors-as-values (the round-trip's failure is a
  `(Maybe RunManifest)` = `none`, never a throw); `foldl` array construction (the
  leaf-blob lowering discipline).
- **The reframing:** serialization is split OFF the crossing. `manifest-to-json :
  (-> RunManifest Json)` is pure — the membrane PROVES it cannot touch the
  network while building the body. `be-log : (=> Backend RunManifest Str Unit)`
  is the thin effectful shell: `manifest-to-json` → `json-show` → `str->bytes` →
  `http-request "POST"`. The interesting logic (the 15+9 field walk) is in the
  provable-pure half; the crossing is three lines.
- **What chirality makes impossible here:** `manifest-to-json` cannot POST (its arrow
  is `->`); a number field cannot be a float (there are none); and because
  `manifest-to-json` and `manifest-from-json` are typed inverses over the SAME
  `Json` shape, a serializer/deserializer drift is caught by the round-trip test
  mechanically, not by reading two files by eye.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
; ---- prapanca/contract/manifest.chiral : ADD manifest-to-json (pure ->) ------------
; Lives BESIDE E141's manifest-from-json (same module, imports already present:
; prelude, json, prapanca/core/types). Reuses the RunManifest/ExpertCall/Binding
; ctors; defines NO name E141 already defined.

; a (List Str) -> a JSON array of strings. foldl+append (NOT map-list: does not
; lower in a leaf blob — E134's FLAG). Order preserved.
(def strs->jarr (-> (List Str) Json)
  (lam (xs)
    (j-arr (foldl Str (List Json)
             (lam (acc s) (append Json acc (cons (j-str s) nil)))
             nil xs))))

; a (List I64) -> a JSON array of numbers. Each I64 -> i64->str -> j-num lexeme.
(def ints->jarr (-> (List I64) Json)
  (lam (xs)
    (j-arr (foldl I64 (List Json)
             (lam (acc n) (append Json acc (cons (j-num (i64->str n)) nil)))
             nil xs))))

; one ExpertCall -> its 9-field JSON object (the inverse of ec-from-json's keys).
(def ec-to-json (-> ExpertCall Json)
  (lam (c)
    (case c
      ((expert-call eid slot bm nc psha rsha pok acc dur)
        (j-obj
          (cons (pair "expert_id" (j-str eid))
          (cons (pair "slot" (j-str slot))
          (cons (pair "bound_model" (j-str bm))
          (cons (pair "num_ctx" (j-num (i64->str nc)))
          (cons (pair "prompt_sha256" (j-str psha))
          (cons (pair "response_sha256" (j-str rsha))
          (cons (pair "parsed_ok" (j-bool pok))
          (cons (pair "accepted_into_merge" (j-bool acc))
          (cons (pair "duration_ms" (j-num (i64->str dur))) nil))))))))))))))

(def ecs->jarr (-> (List ExpertCall) Json)
  (lam (xs)
    (j-arr (foldl ExpertCall (List Json)
             (lam (acc c) (append Json acc (cons (ec-to-json c) nil)))
             nil xs))))

; config_binds is a JSON OBJECT slot -> {model,num_ctx} (E141 cases on j-obj), so
; each Binding becomes an OBJECT FIELD keyed by its slot — not an array element.
(def binding->field (-> Binding (Pair Str Json))
  (lam (b)
    (case b
      ((binding slot model nc)
        (pair slot
          (j-obj (cons (pair "model" (j-str model))
                  (cons (pair "num_ctx" (j-num (i64->str nc))) nil))))))))

(def binds->jobj (-> (List Binding) Json)
  (lam (xs)
    (j-obj (foldl Binding (List (Pair Str Json))
             (lam (acc b) (append (Pair Str Json) acc (cons (binding->field b) nil)))
             nil xs))))

; manifest-to-json : the 15-field spine, ctor order, key names matching E141.
(def manifest-to-json (-> RunManifest Json)
  (lam (m)
    (case m
      ((run-manifest run-id request doc-path artifact-path pipeline-id
                     pipeline-choice routing-decision fired-expert-ids config-id
                     config-binds context-chunks-used expert-calls combiner-patches
                     final-yield generated-at)
        (j-obj
          (cons (pair "run_id" (j-str run-id))
          (cons (pair "request" (j-str request))
          (cons (pair "doc_path" (j-str doc-path))
          (cons (pair "artifact_path" (j-str artifact-path))
          (cons (pair "pipeline_id" (j-str pipeline-id))
          (cons (pair "pipeline_choice" (j-str pipeline-choice))
          (cons (pair "routing_decision" (j-str routing-decision))
          (cons (pair "fired_expert_ids" (strs->jarr fired-expert-ids))
          (cons (pair "config_id" (j-str config-id))
          (cons (pair "config_binds" (binds->jobj config-binds))
          (cons (pair "context_chunks_used" (ints->jarr context-chunks-used))
          (cons (pair "expert_calls" (ecs->jarr expert-calls))
          (cons (pair "combiner_patches" (strs->jarr combiner-patches))
          (cons (pair "final_yield" (j-str final-yield))
          (cons (pair "generated_at" (j-str generated-at))
                nil)))))))))))))))))))))

; ---- prapanca/pipeline/log.chiral : be-log (effectful =>) --------------------------
(import "prelude")                 ; str->bytes
(import "backend")                 ; Backend, be-url
(import "http")                    ; http-request, HttpR
(import "json")                    ; json-show
(import "prapanca/contract/manifest") ; manifest-to-json

; be-log : POST the run record to {base}/internal/log. Effect row ("http-request").
; The response is ignored — logging is fire-and-forget (a failed POST must not
; abort a completed run; the record is best-effort). Returns Unit.
(def be-log (=> Backend RunManifest Str Unit)
  (lam (b m run-dir)
    (case (http-request "POST" (be-url b "/internal/log")
            (str->bytes (json-show (manifest-to-json m))))
      ((http-r st body) unit))))
```

- **Knobs to modify:** the endpoint path (`/internal/log`); whether the response
  status is inspected (here ignored — fire-and-forget; a caller wanting delivery
  proof would case on `st`); the `run-dir` arg (carried for the worker's log
  layout, currently unused in the body — kept to match the SPEC §1 signature
  `(=> Backend RunManifest Str Unit)`).
- **Deliberately omitted:** the `/internal/log/expert` per-call fan-out (the row
  names both endpoints; a first runnable engine POSTs the whole manifest once,
  and the per-expert split is a worker-side optimization deferred with the live
  endpoint); retry/timeout on the POST (the transport's concern, not `be-log`'s).

## 6. Use / modify notes

- **Lands in:** `manifest-to-json` (+ the array helpers) is ADDED to
  `scaffold/lib/manas/contract/manifest.chiral` (the E141 module — imported, not
  duplicated). `be-log` lands in the new `scaffold/lib/manas/pipeline/log.chiral`.
- **Conformance target:** the round-trip. Build a `RunManifest` in chirality, run
  `manifest-to-json` → `json-show` → `json-parse-str` → `manifest-from-json`, and
  assert `manifest-conforms orig round-tripped` = true — a clean pass through JSON
  that ALSO cross-checks E141's deserializer against this serializer. Negative
  control: a malformed JSON string, and a well-formed object missing `run_id`,
  both yield `none` from the pipeline. `be-log` itself must lower under B1
  (effectful, links `http`); the LIVE POST is deferred (the endpoint is unbuilt).
- **Open questions:** whether `/internal/log/expert` per-call POSTs are worth the
  extra crossings before the endpoint lands (deferred, per §5); whether a failed
  log POST should ever be surfaced (currently swallowed — fire-and-forget).
- **Related:** [[E141-golden-conformance]] (the inverse deserializer +
  `manifest-conforms`), [[E133-manas-core-types]] (the `RunManifest` shape),
  `backend.chiral` (`chat-body` — the same foldl-not-map-list serializer pattern),
  `http.chiral` (`http-request`, the transport).
