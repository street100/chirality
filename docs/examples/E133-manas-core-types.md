---
element: E133
slug: manas-core-types
title: **manas core types** (Wave 1): the pure data model the whole engine is typed against — `GateRule`, `GateDecision` (`gate-fired`/`gate-no-match`), `Binding`, `BindResult` (`bind-ok`/`bind-miss`), `Config`, `Pipeline`, `Expert`, `Finding`, `ExpertCall`, `ExpertOutcome`, `CombinerOutcome`, `PipelineMatch`, `PreflightResult`, `RunManifest`. Pure `data`, zero logic — every failure path is a variant, not an exception (chirality has none). `scaffold/lib/manas/core/types.chiral`
kind: BUILD
reference_class: OURS/SPEC
ours_source: (none)
status: drafted
updated: 2026-08-15
---

# E133 — **manas core types** (Wave 1): the pure data model the whole engine is typed against — `GateRule`, `GateDecision` (`gate-fired`/`gate-no-match`), `Binding`, `BindResult` (`bind-ok`/`bind-miss`), `Config`, `Pipeline`, `Expert`, `Finding`, `ExpertCall`, `ExpertOutcome`, `CombinerOutcome`, `PipelineMatch`, `PreflightResult`, `RunManifest`. Pure `data`, zero logic — every failure path is a variant, not an exception (chirality has none). `scaffold/lib/manas/core/types.chiral`

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E133, the pure chirality DATA MODEL the whole manas MoE orchestration
  engine is typed against — ~15 `data` declarations, zero logic, in one file
  (`scaffold/lib/manas/core/types.chiral`). This is Wave 1 of the METIS-PORT-SPEC
  build plan (§11): "all data types, zero logic," the substrate every later wave
  (gate, bind, match, runner, conformance) imports.
- **Kind:** BUILD (a designed-but-unbuilt feature — the type substrate under the
  manas port; nothing to shed, nothing to self-host, purely new chirality source).
- **Why chirality needs its own:** the Python orchestrator carries the run record as
  a loosely-typed `dict`/dataclass built up field-by-field, and its failure paths
  (`ContextOverflowError`, `PreflightError`/`TrustBoundaryError`,
  `PipelineMatchError`) are exceptions that bypass the return type. chirality has no
  exceptions and no `dict`-as-record; the whole engine has to be typed against a
  closed set of `data`s where every failure is a named variant. Getting the DATA
  right first (before any `run-gate`/`bind-config` logic) is what makes Waves 2–7
  buildable — the types are the contract the golden manifests are checked against.

## 2. Research

- **Reference class:** OURS/SPEC. **SPEC** = `/workspace/manas/.planning/METIS-PORT-SPEC.md`
  §3 (result sums — `GateDecision`/`BindResult`/`ExpertOutcome`/`CombinerOutcome`/
  `PreflightResult`/`PipelineMatch`), §5 (`GateRule`), §6 (`Binding`/`Config`),
  §8 (`RunManifest`/`ExpertCall`), plus `orchestration/SCHEMA.md` (the
  PROCESS→STAGE→PIPELINE→AGENT primitives, AGENT = LENS/SEES/RETURNS/SLOT/TOOLS,
  PIPELINE = GATE/ORDER/COMBINER/STOP/YIELD). **OURS (the ground truth)** = the
  two committed golden manifests in `orchestrator/golden/` — the conformance
  surface SCHEMA.md names normative ("reproduce the golden run-manifests … the
  manifests are the conformance surface").
- **Key findings (load-bearing):**
  1. **The golden manifest is RICHER than the spec's `RunManifest` sketch, and the
     golden wins.** Spec §8 lists 10 fields (`request pipeline-id pipeline-choice
     config-id fired-expert-ids routing-decision context-chunks-used expert-calls
     corpus-eligible yield-text`). The real golden JSON carries 15 top-level keys:
     `run_id, request, doc_path, artifact_path, pipeline_id, pipeline_choice,
     routing_decision, fired_expert_ids[], config_id, config_binds{}, context_chunks_used[],
     expert_calls[], combiner_patches[], final_yield, generated_at`. Six keys the
     spec omitted (`run_id, doc_path, artifact_path, config_binds, combiner_patches,
     generated_at`) are present in the committed record — so the `data` must carry
     them. One spec field (`corpus_eligible`) is **absent** from both goldens — dropped
     (golden wins; see §6 open questions). One is renamed (`yield-text` → `final_yield`).
  2. **`ExpertCall` in the golden carries five fields the spec's sketch dropped.**
     Each `expert_calls[]` entry is `{expert_id, slot, bound_model, num_ctx,
     prompt_sha256, response_sha256, parsed_ok, accepted_into_merge, duration_ms}`
     — 9 fields. The spec's §8 `ExpertCall` was implied thin (id/slot/model). The
     shas, the two bools, and `duration_ms` are all in the committed record, so
     `ExpertCall` gets all nine. `num_ctx`/`duration_ms` → I64; shas → Str (see the
     float→I64 wall, §4).
  3. **`config_binds` is a JSON MAP, modeled as a `(List Binding)`.** In the golden
     it is `{"reasoner":{"model":"qwen3:8b","num_ctx":16384}, …}` — a
     slot→{model,num_ctx} object. chirality has no record-map primitive at the type
     level here; the faithful model is `(List Binding)` where each `Binding` =
     `(slot model num-ctx)`, matching the spec §6 `Binding`/`Config` design and the
     E135 (bind) design. JSON-object-is-a-map, chirality-value-is-a-list-of-pairs — the
     deserializer (E141) folds the map's entries into the list.
  4. **Every failure path is already a variant in the spec — no exceptions.** Spec §3
     enumerates the result sums directly (`gate-no-match` carries a reason,
     `bind-miss` carries missing-slots + config-id, `expert-bad` carries a reason,
     `combiner-bad` carries a reason, `preflight-missing`/`preflight-cloud` carry the
     model lists, `match-none`/`match-tied` carry the pipeline listing + tied ids).
     This is the boundary-sums directive already applied: no nullable-without-reason,
     no sentinel, no thrown control flow. E133 just transcribes those sums as `data`.

## 3. Conventional (other-language) approach

The Python orchestrator (the NORMATIVE driver, per SCHEMA.md) builds the run
record as a plain `dict` accreted field-by-field through the run loop, and its
failure paths are exceptions that never appear in a return type:

```python
# The manifest is an untyped dict, keys added as the run proceeds:
manifest = {"run_id": run_id, "request": req, "doc_path": doc_path, ...}
...
def bind_config(pipeline, config):
    binds = {}
    for slot in pipeline.slots():
        binds[slot] = config.binds[slot]     # raises KeyError on a missing slot
    return binds

def check_ctx(prompt, num_ctx):
    if len(prompt) / 4 > num_ctx:            # float division, then compared
        raise ContextOverflowError(...)      # control flow bypasses the return type

# expert_calls[] entries are dicts too — parsed_ok / accepted_into_merge / the
# two sha256 hex strings / duration_ms are just keys, checked nowhere:
call = {"expert_id": eid, "slot": slot, "bound_model": m, "num_ctx": n,
        "prompt_sha256": h1, "response_sha256": h2, "parsed_ok": ok,
        "accepted_into_merge": acc, "duration_ms": dt}
```

- **Assumptions it bakes in:** a record is an open `dict` (any key, any type, no
  exhaustiveness — a typo'd key is silent); failure is exceptions
  (`KeyError`/`ContextOverflowError`/`PreflightError`/`PipelineMatchError`) that
  bypass the return type, so a caller cannot see the failure in the signature;
  `len(prompt)/4` is float arithmetic; "no experts fired" / "slot unbound" / "no
  pipeline matched" are indistinguishable `None`s or raises with no carried reason.
  chirality refuses all of it: a record is a closed `data`, a failure is a named
  variant carrying its reason, and there is no float type to leak across the seam.

## 4. The chirality idea

- **Chirality features in play:** closed sums + `case` exhaustiveness (every failure is
  a variant the caller MUST handle); the boundary-sums standing directive (a
  which-of-N classification is a sum at the boundary, never a `Str` tag / sentinel
  — `GateDecision`, `BindResult`, `ExpertOutcome`, `CombinerOutcome`,
  `PipelineMatch`, `PreflightResult` are all this); **the float→I64 wall** (SCHEMA's
  "Float rule — a real WALL, but only AT THE SEAM": nothing that reaches chirality is a
  float, so `num_ctx`, `duration_ms`, and the context-chunk ids are all `I64`, and
  `prompt_sha256`/`response_sha256`/`generated_at` are `Str`); zero effect rows and
  zero linearity in THIS file (it is pure `data` — the effect membrane and the
  linear `Backend` porttype enter in Wave 3, not here).
- **The reframing:** the Python `dict`-manifest becomes one closed `RunManifest`
  `data` whose shape IS the golden JSON's shape, field-for-field; the run's
  failure modes become the six result sums; the JSON `config_binds` map becomes a
  `(List Binding)`. The whole engine is then typed against these — `run-gate`
  returns a `GateDecision`, `bind-config` returns a `BindResult`, the run produces a
  `RunManifest` — so the golden manifests can be deserialized into `RunManifest`
  values and compared (the E141 conformance check).
- **What chirality makes impossible here:** a manifest with a mistyped or missing field
  (the `data` is closed and exhaustive); a failure that doesn't say why (every
  `*-miss`/`*-bad`/`*-none`/`*-tied` variant carries its reason/ids as fields); a
  float sneaking into `num_ctx`/`duration_ms` (there is no float type); "no match"
  masquerading as success (`gate-no-match` and `match-none` are distinct variants
  the caller must case on).

## 5. Chirality example (fleshed)

Pure `data` only — no `def`, no `->`/`=>` functions (accessors and logic are later
elements). Constructors are lowercase-hyphenated; types are CamelCase. Field types
obey the float→I64 wall throughout.

```chirality
; ============================================================ manas core types
; E133, Wave 1 (METIS-PORT-SPEC §11). The pure data model the whole engine is
; typed against. ZERO logic — no def, no accessors, no crossings. Every field
; type is I64 / Str / Bool / List / a sibling data; NO floats (the float->I64
; wall: num-ctx, duration-ms, chunk ids are I64; sha256s + timestamps are Str).
; Every failure path is a VARIANT, not an exception (chirality has none).

(import "prelude")       ; I64, Str, Bool, List, Pair, data

; ------------------------------------------------------------------- the GATE
; A single condition->experts rule, parsed from a pipeline's GATE block
; (SCHEMA.md PIPELINE.GATE; SPEC §5). Pure data — the predicate that reads it
; (condition-fires / run-gate) is E134, not here.
(data GateRule ()
  (gate-rule (condition Str) (expert-ids (List Str))))

; The GATE's decision. "no conditions matched" is a NORMAL outcome, not an error
; and not an exception — its own variant carrying the reason (boundary sum: the
; caller cases, never gets a bare nil). (SPEC §3.1, §5.)
(data GateDecision ()
  (gate-fired    (expert-ids (List Str)) (reason Str))
  (gate-no-match (reason Str)))

; ---------------------------------------------------------------- CONFIG / bind
; One binding: a SLOT resolved to a model + its context window. num-ctx is I64
; (the float wall — a context length is a bounded int, never a float).
; Mirrors the golden config_binds ENTRY {model, num_ctx} plus its slot key.
(data Binding ()
  (binding (slot Str) (model Str) (num-ctx I64)))

; A config profile: an id + its bindings. The golden `config_binds` is a JSON
; MAP (slot -> {model, num_ctx}); chirality models it as a (List Binding) — each
; Binding carries the slot the JSON had as its key. JSON-object-is-a-map,
; chirality-value-is-a-list (the E141 deserializer folds the map into this list).
; (SPEC §6; SCHEMA.md CONFIG; matches E135's design.)
(data Config ()
  (config (id Str) (binds (List Binding))))

; Resolving a pipeline's slots against a config. A missing slot is RECOVERABLE —
; bind-miss carries WHICH slots are missing + the config id, so the caller
; decides (Python raised KeyError; here it's a value). (SPEC §3.1, §6.)
(data BindResult ()
  (bind-ok   (bindings (List Binding)))
  (bind-miss (missing-slots (List Str)) (config-id Str)))

; ------------------------------------------------------------ AGENT / PIPELINE
; ORDER and STOP are which-of-N classifications (SCHEMA.md PIPELINE.ORDER =
; fan-out | chain | branch; PIPELINE.STOP = single | capped-N | loop-until-dry).
; The boundary-sums directive says model a which-of-N as a closed sum, never a
; Str tag — so they are minted here as small sums the Pipeline embeds (beyond
; the 15 named types, but warranted; see §6).
(data Order ()
  (order-fan-out)              ; fire all in parallel, combiner merges
  (order-chain)               ; each output is the next's input
  (order-branch))             ; fan-out over a dynamic (question, perspective) set

(data StopPolicy ()
  (stop-single)               ; one pass
  (stop-capped   (cap I64))   ; up to `cap` iterations
  (stop-until-dry (cap I64))) ; loop until no new findings, capped at `cap`

; One AGENT (SCHEMA.md §1): a lens with typed I/O bound to a SLOT (not a model).
; LENS/SEES/RETURNS are prose descriptors here (typed I/O is target work); SLOT
; is the capability class the Config binds; TOOLS is least-privilege (a list of
; permitted tool names, default read-only = nil).
(data Expert ()
  (expert (id Str) (lens Str) (sees Str) (returns Str)
          (slot Str) (tools (List Str))))

; One structured finding an Expert RETURNS, pre-merge. Shape is deliberately
; small (kind + optional target + body) — the golden records findings only after
; the combiner merges them, so the granular Finding shape is under-specified by
; the goldens (see §6). Kept minimal and honest.
(data Finding ()
  (finding (kind Str) (target Str) (body Str)))

; A PIPELINE as pure data (SCHEMA.md §2: a set of agents = GATE + ORDER +
; COMBINER, under STOP, with a WHEN and a YIELD). Experts are referenced by id
; (the pool is shared across pipelines — the Expert values live in the profile
; element, E-later). The dependent/typed-I/O Pipeline of SPEC §12.6 is the
; TARGET; Wave 1 is this flat data record.
(data Pipeline ()
  (pipeline (id Str) (when Str)
            (gate (List GateRule))     ; GATE
            (order Order)              ; ORDER
            (expert-ids (List Str))    ; the fired-agent pool, by id
            (combiner Str)             ; COMBINER agent id
            (stop StopPolicy)          ; STOP
            (yield-desc Str)))         ; YIELD (prose)

; -------------------------------------------------------- matching / preflight
; Matching a request against pipelines' WHEN texts. match-none carries the full
; (id -> when) listing; match-tied carries the tied ids AND the listing — the
; caller sees exactly why it couldn't pick one (Python raised PipelineMatchError).
; (SPEC §3.1.)
(data PipelineMatch ()
  (match-found (pipeline Pipeline) (matched-when Str))
  (match-none  (listing (List (Pair Str Str))))
  (match-tied  (tied-ids (List Str)) (listing (List (Pair Str Str)))))

; Preflight: are the config's models available and admissible? Three variants —
; ok, models-not-pulled, and trust-boundary violation (a cloud model in a local
; run). preflight-cloud is the typed form of TrustBoundaryError; the zone-token
; (LocalZone/CloudZone) approach of SPEC §3.3 is the target, this sum is the
; honest Wave-1 form (SPEC §12 open Q4). (SPEC §3.1.)
(data PreflightResult ()
  (preflight-ok)
  (preflight-missing (missing (List Str)))       ; model ids not on the worker
  (preflight-cloud   (cloud-models (List Str))))  ; trust-boundary violation

; ---------------------------------------------------- expert / combiner results
; One expert invocation's outcome. A model returning unparseable output is
; RECOVERABLE — expert-bad carries the raw response + the parse-failure reason,
; not an exception. (SPEC §3.1.)
(data ExpertOutcome ()
  (expert-ok  (findings (List Finding)) (raw-response Str))
  (expert-bad (raw-response Str) (reason Str)))

; The combiner's outcome: the merged yield + which expert ids it accepted, or a
; parse/merge failure carrying its reason. (SPEC §3.1.)
(data CombinerOutcome ()
  (combiner-ok  (yield-text Str) (accepted-ids (List Str)) (raw-response Str))
  (combiner-bad (raw-response Str) (reason Str)))

; --------------------------------------------------- the run record (conformance)
; One recorded model call. Shape is the golden expert_calls[] ENTRY, field-for-
; field (9 fields — the spec §8 sketch was thinner; the golden wins). num-ctx and
; duration-ms are I64 (float wall); prompt-sha256/response-sha256 are Str (hex);
; parsed-ok and accepted-into-merge are Bool. (Golden orchestrator/golden/*.json;
; SPEC §8.)
(data ExpertCall ()
  (expert-call
    (expert-id Str)              ; golden expert_id
    (slot Str)                   ; golden slot
    (bound-model Str)            ; golden bound_model
    (num-ctx I64)                ; golden num_ctx           (I64, not float)
    (prompt-sha256 Str)          ; golden prompt_sha256     (hex string)
    (response-sha256 Str)        ; golden response_sha256   (hex string)
    (parsed-ok Bool)             ; golden parsed_ok
    (accepted-into-merge Bool)   ; golden accepted_into_merge
    (duration-ms I64)))          ; golden duration_ms       (I64, not float)

; The full run record. Shape IS the golden manifest's 15 top-level keys — the
; conformance surface (SCHEMA.md: "reproduce the golden run-manifests"). The
; golden is richer than SPEC §8's sketch; the golden wins field-for-field:
;   golden-only vs spec sketch : run_id, doc_path, artifact_path, config_binds,
;                                combiner_patches, generated_at  (ALL carried here)
;   spec-only, dropped         : corpus_eligible (absent from both goldens)
;   renamed                    : spec yield-text -> golden final_yield
; config-binds is the (List Binding) modeling of the JSON slot-map. combiner-
; patches is the golden's list of unified-diff line strings, so (List Str) — an
; opaque line list (a richer Patch type is deferred; see §6). context-chunks-used
; is a list of int chunk ids -> (List I64) (float wall). All shas/timestamps Str.
(data RunManifest ()
  (run-manifest
    (run-id Str)                        ; golden run_id
    (request Str)                       ; golden request
    (doc-path Str)                      ; golden doc_path
    (artifact-path Str)                 ; golden artifact_path
    (pipeline-id Str)                   ; golden pipeline_id
    (pipeline-choice Str)               ; golden pipeline_choice
    (routing-decision Str)              ; golden routing_decision
    (fired-expert-ids (List Str))       ; golden fired_expert_ids[]
    (config-id Str)                     ; golden config_id
    (config-binds (List Binding))       ; golden config_binds{}  (JSON map -> list)
    (context-chunks-used (List I64))    ; golden context_chunks_used[]  (int ids)
    (expert-calls (List ExpertCall))    ; golden expert_calls[]
    (combiner-patches (List Str))       ; golden combiner_patches[]  (diff lines)
    (final-yield Str)                   ; golden final_yield  (was spec yield-text)
    (generated-at Str)))                ; golden generated_at  (ISO-8601 string)
```

- **Knobs to modify:** the `Finding` shape (kind/target/body) once the merged-vs-
  granular finding format firms up; whether `combiner-patches` stays `(List Str)`
  or becomes a `Patch` sum (`patch-hunk`/`patch-add`/…); whether `Order`/`StopPolicy`
  stay embedded in `Pipeline` or move to a dedicated pipeline element; the
  `Pipeline` record when the dependent/typed-I/O target (SPEC §12.6) lands.
- **Deliberately omitted:** ALL logic (no `def`, no accessors — those are later
  elements: gate=E134, bind=E135, the E141 deserializer/conformance check); the
  linear `Backend` porttype and the effect rows (Wave 3, not this file); the
  zone-token `LocalZone`/`CloudZone` design (target; `PreflightResult` is the Wave-1
  honest form); the dependent `Config (covers S)` coverage proof (SPEC §6 target;
  `BindResult` is the Wave-1 form).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/manas/core/types.chiral` (new file — Wave 1 of the
  METIS-PORT-SPEC build plan, imported by every later manas element). Imports
  `prelude` only (I64/Str/Bool/List/Pair/data); no `collections`, no `ports`, no
  `backend` — this file has zero logic and zero crossings.
- **Conformance target:** deserializing each committed golden manifest
  (`orchestrator/golden/3dde39e…json`, `…/c3c223…json`) into a `RunManifest` value
  loses NO field — every top-level golden key maps to a `run-manifest` field, and
  every `expert_calls[]` key maps to an `expert-call` field. That round-trip is the
  E141 check; E133's job is to make the target `data` shape exist and match. The
  two goldens exercise both a with-patches run (`3dde39e…`, `combiner_patches`
  non-empty, `config_id=smoke-local`) and an empty-patches run (`c3c223…`,
  `combiner_patches=[]`, `config_id=quality-local`) — both must fit `RunManifest`.
- **Open questions (a human must rule on the first two; the rest are noted
  reconciliations already taken):**
  1. **`corpus_eligible` — drop or keep?** SPEC §8's `RunManifest` had a
     `corpus-eligible Bool`; it is ABSENT from both goldens. TAKEN: dropped (the
     golden is the conformance surface and doesn't carry it). If a future golden
     regenerates it, add it back — flagged for the author to confirm the drop.
  2. **`Finding` granularity.** The goldens only record findings post-merge (as
     `combiner_patches` + `final_yield`), so the per-expert `Finding` shape is
     under-specified by ground truth. TAKEN: a minimal `(kind target body)`. A
     human should confirm this shape (or supply the real expert RETURNS schema
     from the agents library) before E134/expert-call logic depends on it.
  3. **`combiner_patches` as `(List Str)`.** The golden's patches are raw
     unified-diff line strings (`"--- source\n"`, `"@@ -1,4 +1,4 @@\n"`, …).
     TAKEN: `(List Str)`, opaque lines — faithful to the golden. A richer `Patch`
     sum is deferred (a knob, not a blocker).
  4. **`config_binds` map → `(List Binding)`.** TAKEN (matches SPEC §6 + E135): the
     JSON slot→{model,num_ctx} object becomes a list of `Binding`s carrying the
     slot as a field. The E141 deserializer folds the map's entries.
  5. **`Order`/`StopPolicy` beyond the 15 named types.** TAKEN: minted as small
     closed sums (the boundary-sums directive — ORDER and STOP are textbook
     which-of-N and must not be `Str` tags). They are embedded in `Pipeline`; a
     reviewer may relocate them to a dedicated pipeline element.
- **Related:** [[E133-manas-core-types]] · [[E141-golden-conformance]] (deserialize
  the two goldens into `RunManifest`, lose no field — the conformance check) ·
  [[E134-gate]] (`run-gate` over `GateRule`/`GateDecision`) · [[E135-bind]]
  (`bind-config` over `Binding`/`Config`/`BindResult`).
