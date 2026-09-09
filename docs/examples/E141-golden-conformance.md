---
element: E141
slug: golden-conformance
title: "golden-manifest conformance"
kind: BUILD
reference_class: OURS/SPEC
ours_source: (none — design from METIS-PORT-SPEC §8 + the golden manifests)
status: drafted
updated: 2026-08-15
---

# E141 — golden-manifest conformance

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E141 — the manas engine's **test oracle**: deserialize a golden
  run-manifest JSON into a typed `RunManifest`, and structurally compare a live
  manifest against the frozen golden.
- **Kind:** BUILD (BUILD-PROPER — no manifest (de)serialize/compare exists in
  chirality; the golden JSONs live worker-side as the Python driver's oracle).
- **Why chirality needs its own:** P5 (split what you can't type) in practice — two
  independent truths compared. The committed golden manifest is one truth; a
  live pipeline run's manifest is the other. Conformance is how divergence gets
  noticed. chirality makes the comparison a **pure, total function over typed data**
  instead of a fuzzy JSON diff.

## 2. Research

- **Reference class:** OURS/SPEC — `METIS-PORT-SPEC.md §8` (the
  `manifest-from-json` / `manifest-conforms` design and the "compare structure,
  not responses" rule) + the two real golden manifests in
  `orchestrator/golden/*.json` (the conformance ground truth).
- **Key findings:**
  1. The `RunManifest` type (E133, `prapanca/core/types.chiral`) already models the
     golden field-for-field: 15 top-level fields, `ExpertCall` with 9, `Binding`
     for the `config_binds` slot-map. Deserialization is pure field-digging over
     a parsed `Json`; no new types.
  2. **Structural vs run-specific fields.** A model call is non-deterministic:
     `prompt_sha256`/`response_sha256`, `duration_ms`, and the final-yield *text*
     vary run-to-run. The **stable** surface is the routing/binding structure:
     `pipeline_id`, `config_id`, `routing_decision`, `fired_expert_ids`, and per
     `ExpertCall` its `expert_id` / `slot` / `bound_model`. Conformance compares
     ONLY the stable set (SPEC §8).
  3. `json.chiral` already gives the parse + accessors: `json-parse : Bytes ->
     Maybe Json`, `obj-get`, `as-str`/`as-int`/`as-bool`/`as-arr`. Deserialize is
     a fold over those — a required field missing/mistyped folds to `none`.
     **Boundary note:** `manifest-from-json` takes an already-parsed `Json`
     (`(-> Json (Maybe RunManifest))`), not raw `Bytes` — the catalog row sketched
     `Bytes`, but keeping `json-parse` in `json.chiral` (the caller does
     `json-parse` then `manifest-from-json`) keeps the parse boundary in one place
     and `manifest.chiral` free of byte-scanning. A `Bytes` wrapper is trivial to
     add later if a caller wants the one-shot form.

## 3. Conventional (other-language) approach

The Python driver builds the manifest as a plain `dict`, dumps it with
`json.dumps`, and a golden test typically re-reads it and diffs:

```python
def load_manifest(path):
    return json.load(open(path))              # an untyped dict; any key may be absent

def conforms(golden, actual):
    # ad-hoc: compare "the fields that matter", by hand, per test
    return (golden["pipeline_id"]  == actual["pipeline_id"]
        and golden["config_id"]    == actual["config_id"]
        and golden["fired_expert_ids"] == actual["fired_expert_ids"]
        and [ (c["expert_id"], c["slot"], c["bound_model"])
              for c in golden["expert_calls"] ]
          == [ (c["expert_id"], c["slot"], c["bound_model"])
              for c in actual["expert_calls"] ])
```

- **Assumptions it bakes in:** the manifest is an untyped `dict` (a typo'd key is
  a silent `KeyError` at compare time, not a schema violation at load); the
  "which fields matter" set is re-derived by hand in each test (drift between
  producer and consumer); a malformed manifest is an exception, not a value.

## 4. The chirality idea

- **Chirality features in play:** the effect membrane (`->` — deserialize and compare
  are **pure**, provably no crossing); errors-as-values (a missing/mistyped field
  is `none`, never a throw); totality (structural recursion over the field lists);
  boundary sums (`Json` was already parsed once; `manifest-from-json` classifies
  it into `RunManifest` at the boundary, and every downstream consumer cases on
  the typed value).
- **The reframing:** deserialization returns `(Maybe RunManifest)` — a manifest
  that doesn't match the schema is `none` at the boundary, so no partial/`dict`
  ever flows downstream. Conformance is `(-> RunManifest RunManifest Bool)`, pure:
  the membrane *proves* the oracle cannot call a model or touch the network while
  judging a run. The stable-vs-ignored field split is written ONCE, in the
  comparator, not re-derived per test.
- **What chirality makes impossible here:** the oracle cannot make a network call
  (the arrow is `->`); it cannot compare a float (there are none — `num_ctx` /
  `duration_ms` are `I64`, shas are `Str`); a mistyped field cannot silently pass
  as `""`/`0` — the field-dig returns `none` and the whole deserialize fails.

## 5. Chirality example (fleshed)

```chirality
; ---- prapanca/contract/manifest.chiral : deserialize + accessors (pure ->) --------
(import "prelude")
(import "json")              ; Json, obj-get, as-str/as-int/as-bool/as-arr
(import "prapanca/core/types")  ; RunManifest, ExpertCall, Binding  (E133 — imported, not redefined)

; obj-get composed with a typed reader: a required field, as a (Maybe X).
(def og-str (-> Json Str (Maybe Str))
  (lam (j k) (case (obj-get j k) (none none) ((some v) (as-str v)))))
(def og-int (-> Json Str (Maybe I64))
  (lam (j k) (case (obj-get j k) (none none) ((some v) (as-int v)))))
(def og-arr (-> Json Str (Maybe (List Json)))
  (lam (j k) (case (obj-get j k) (none none) ((some v) (as-arr v)))))

; a JSON array of strings -> (Maybe (List Str)); any non-string element => none.
; Structural recursion on the list (decreasing) — total.
(def js-str-list (-> (List Json) (Maybe (List Str)))
  (lam (xs)
    (case xs
      (nil (some nil))
      ((cons h t)
        (case (as-str h) (none none)
          ((some s)
            (case (js-str-list t) (none none)
              ((some rest) (some (cons s rest))))))))))

; one expert_calls[] entry -> (Maybe ExpertCall). 9 fields, dug in ctor order.
(def ec-from-json (-> Json (Maybe ExpertCall))
  (lam (j)
    (case (og-str j "expert_id") (none none) ((some eid)
    (case (og-str j "slot") (none none) ((some slot)
    (case (og-str j "bound_model") (none none) ((some bm)
    (case (og-int j "num_ctx") (none none) ((some nc)
    ; … prompt_sha256, response_sha256, parsed_ok, accepted_into_merge, duration_ms …
    (some (expert-call eid slot bm nc "" "" true true 0)))))))))))   ; sketch tail

; config_binds{} is a JSON OBJECT slot -> {model,num_ctx}; each field -> a Binding.
(def binding-from-field (-> (Pair Str Json) (Maybe Binding))
  (lam (kv)
    (case kv ((pair slot v)
      (case (og-str v "model") (none none) ((some m)
      (case (og-int v "num_ctx") (none none) ((some nc)
        (some (binding slot m nc))))))))))

; manifest-from-json : dig each field; a missing/mistyped required field => none.
; PURE (->) — the membrane proves this touches no port. (15-field spine sketched.)
(def manifest-from-json (-> Json (Maybe RunManifest))
  (lam (j)
    (case (og-str j "run_id") (none none) ((some run-id)
    ; … request, doc_path, artifact_path, pipeline_id, pipeline_choice, routing_decision,
    ;   fired_expert_ids (js-str-list), config_id, config_binds (binds-from-json),
    ;   context_chunks_used (js-int-list), expert_calls (ec-list), combiner_patches,
    ;   final_yield, generated_at …
    (some (run-manifest run-id "" "" "" "" "" "" nil "" nil nil nil nil "" ""))))))  ; sketch

; ---- prapanca/contract/golden.chiral : structural conformance (pure ->) -----------
; accessors live in manifest.chiral (imported here) — no name is redefined.

; compare TWO expert-call lists on the STABLE per-call fields only, pairwise
; (length included). expert-id / slot / bound-model — NOT the shas/duration.
(def ec-struct-eq (-> ExpertCall ExpertCall Bool)
  (lam (g a)
    (and (str-eq (ec-expert-id g) (ec-expert-id a))
    (and (str-eq (ec-slot g) (ec-slot a))
         (str-eq (ec-bound-model g) (ec-bound-model a))))))

(def ec-list-match (-> (List ExpertCall) (List ExpertCall) Bool)
  (lam (gs as)
    (case gs
      (nil (case as (nil true) ((cons h t) false)))
      ((cons g gt)
        (case as (nil false)
          ((cons a at) (and (ec-struct-eq g a) (ec-list-match gt at))))))))

; manifest-conforms : STRUCTURAL agreement of a live run vs the golden.
; Stable set: pipeline-id, config-id, routing-decision, fired-expert-ids,
; and per-call expert-id/slot/bound-model. Everything run-specific is IGNORED.
(def manifest-conforms (-> RunManifest RunManifest Bool)
  (lam (golden actual)
    (and (str-eq (manifest-pipeline-id golden) (manifest-pipeline-id actual))
    (and (str-eq (manifest-config-id golden) (manifest-config-id actual))
    (and (str-eq (manifest-routing-decision golden) (manifest-routing-decision actual))
    (and (str-list-eq (manifest-fired-expert-ids golden) (manifest-fired-expert-ids actual))
         (ec-list-match (manifest-expert-calls golden) (manifest-expert-calls actual))))))))
```

- **Knobs to modify:** the **stable field set** in `manifest-conforms` (add
  `num_ctx` if a run must reproduce context windows; drop `routing_decision` if
  the routing prose is allowed to drift); the JSON key names if the manifest
  schema changes; `ec-struct-eq` if per-call structure gains a stable field.
- **Deliberately omitted:** the 15-field deserialize spine and the 9-field
  `ec-from-json` tail are sketched (`""`/`0`/`nil` placeholders) — the real file
  fills every field. `combiner_patches` stays an opaque `(List Str)` of diff
  lines (a richer `Patch` type is deferred, per E133 §6).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/manas/contract/manifest.chiral` (deserialize +
  accessors) and `scaffold/lib/manas/contract/golden.chiral` (`manifest-conforms`
  + list-compare helpers). Both pure `->`.
- **Conformance target:** parsing the real golden `3dde…-manifest.json` yields a
  `RunManifest` with `pipeline-id`="doc-refine", `config-id`="smoke-local",
  `fired-expert-ids` length 2, `expert-calls` length 5, first call
  `expert-id`="claim-vs-source" / `slot`="cheap-verifier"; `manifest-conforms m m`
  = true; a copy with a mutated stable field = false; a copy differing only in
  ignored fields (shas / duration / final-yield) = true.
- **Open questions:** whether `num_ctx` belongs in the stable set (deterministic
  from the config, but the SPEC §8 stable list omits it — kept out here to match).
  The test reads the real golden via the file crossings (`open-rw`/`read`/
  `fd-close`), making it effectful `=>`; the deserialize/compare functions
  themselves stay pure `->`.
- **Related:** [[E133-manas-core-types]] (the types), [[E140-profiles-docrefine]]
  (the profiles a live run binds), `json.chiral` (the parser).
