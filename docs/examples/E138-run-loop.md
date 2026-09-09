---
element: E138
slug: run-loop
title: **The multi-agent run loop (N1)** — the MoE heart: one request fans out to N narrow single-lens agents (each bound to its slot's model), gated sparsely, merged by a combiner into one yield + a `RunManifest`. Structured functional-core / imperative-shell: a PURE spine (`plan-run` = match→gate→bind; `assemble-manifest` = fired experts + outcomes → run record) that is the whole testable decision, and an EFFECTFUL shell (`call-expert`/`call-combiner`/`run-pipeline`) that wraps `be-chat`. `guarded-run` folds E67's `cycle-step` breaker over the run. `scaffold/lib/manas/pipeline/{plan,runner,guarded}.chiral`
kind: BUILD
reference_class: OURS/SPEC/PAPER
ours_source: (none)
status: reviewed
updated: 2026-08-15
---

# E138 — the multi-agent run loop (N1): the MoE heart, functional-core / imperative-shell

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E138 — the run loop that makes manas a **Mixture-of-Experts**
  engine, not one-chat-to-one-AI. One request fans out to N narrow single-lens
  agents (each bound to its slot's model via the Config), the GATE fires them
  sparsely, a COMBINER merges their findings into one yield, and the whole run is
  recorded as a typed `RunManifest`. Composes the already-built pure core (E134
  gate, E135 bind, E136 match/assemble, E140 profiles/pipeline) with the backend
  seam (`be-chat`).
- **Kind:** BUILD — a designed-but-unbuilt feature. `manas.chiral`'s `run-batch`
  drives ONE model over a prompt list with no gate/experts/combiner; E138 is the
  fan-out-and-merge loop that has no chirality analog yet.
- **Why chirality needs its own:** the run loop is the point where the effect membrane
  earns its keep. The routing decision (match→gate→bind) is PURE (`->`) — the type
  PROVES no model call can steer which experts fire (no hallucination in the
  router). Only the fan-out itself crosses the seam (`=>`). Splitting the loop into
  a pure spine + an effectful shell is not a style choice: it is what makes the
  engine testable with the model endpoint unreachable, and what the type system
  enforces.

## 2. Research

- **Reference class:** OURS/SPEC/PAPER. `/workspace/manas/.planning/METIS-PORT-SPEC.md`
  §1 (the `->`/`=>` split of the pipeline functions), §4 (the full `run-pipeline`
  type), §9 (`guarded-run` folding in the breaker); `scaffold/lib/manas.chiral`
  (`cycle-step`/`Turn`/`Outcome`, the functional-core/imperative-shell precedent);
  gated-MoE (Shazeer et al. 2017, arXiv:1701.06538 — sparse expert activation; the
  GATE is rules-first, the sparse-activation model is the same).
- **Key findings (load-bearing):**
  1. **The whole pure core is already built and composes directly.** `match-pipeline`
     (E136), `run-gate` (E134), `bind-config` (E135), `assemble-prompt` (E136), and
     the E140 payload (`doc-refine-pipeline`, `expert-pool`, the four Configs) are
     all pure `->` values. E138 IMPORTS them; it redefines nothing. The runner is
     glue, not new algorithm.
  2. **The backend is plain data today, not the linear porttype.** `backend.chiral`
     is `(data Backend () (backend (base Str)))` and `be-chat : (=> Backend Str
     (List Msg) ChatR)` (non-linear, non-threaded). E137 is the porttype upgrade;
     E138 rides the plain-data seam as it is (SCOPE TRIM, §6).
  3. **manas.chiral already models functional-core / imperative-shell.** `cycle-step`
     (pure `->` breaker) + `run-recorded` (pure fold) vs `run-batch` (effectful
     `=>` driver). E138 mirrors this exactly: `plan-run`/`assemble-manifest` are the
     pure `run-recorded` analog; `run-pipeline` is the `run-batch` analog.
  4. **`map-list` does not lower in an isolated leaf blob on branch e106** (E134's
     FLAG). Every list build in the spine uses `foldl`/`filter`/`find`/`append`,
     never `map-list` — same discipline the pure core already follows.
  5. **Two modules must not define the same top-level name.** The E140 test proved
     it (`gate` vs `match` both wanting `str-contains`). The runner's private
     accessors are named to NOT collide with the pool/profile accessors it sits
     beside in a combined blob (`exp-id`/`exp-slot` not `expert-id`/`expert-slot-of`;
     `cfg-id` not `config-id`; `pipe-gate` not `pipeline-gate`; `bnd-model` not the
     test's `binding-model`).

## 3. Conventional (other-language) approach

Outside chirality the run loop is one imperative function: fetch context, loop the
experts calling the model, collect, call the combiner, build a dict manifest.

```python
def run_pipeline(backend, pipeline, config, request, doc, extra):
    pl = match_pipeline(request, PIPELINES)         # may raise PipelineMatchError
    fired = run_gate(pl.gate, doc, extra)           # list[expert_id]
    binds = bind_config(pl, config, slots_of(fired))# may raise KeyError
    calls, findings = [], []
    for eid in fired:                               # fan-out — each iteration a model call
        prompt = assemble_prompt(pool[eid], doc, extra, [])
        resp = backend.chat(binds[pool[eid].slot].model, prompt)  # NETWORK
        findings += parse_findings(resp)
        calls.append({"expert_id": eid, "slot": pool[eid].slot, ...})
    yield_text = backend.chat(binds["combiner"].model, render(findings))  # NETWORK
    return {"fired_expert_ids": fired, "expert_calls": calls,
            "config_id": config.id, "final_yield": yield_text, ...}       # dict
```

- **Assumptions it bakes in:** the routing (`match`/`gate`/`bind`) is interleaved
  with the network calls in one function — nothing stops a future edit from letting
  a model response influence routing; a missing slot is a `KeyError` mid-loop; the
  manifest is an untyped dict assembled by mutation; and the ONLY way to test any of
  it is to have a live model. chirality refuses all of it: the router is a pure `->`
  function the membrane proves cannot call the model; a missing slot is a `bind-miss`
  VALUE; the manifest is a typed `RunManifest`; and the routing + assembly are a
  pure spine testable with no network at all.

## 4. The chirality idea

- **Chirality features in play:** the **effect membrane** (`->` router provably crosses
  no seam; `=>` shell wraps `be-chat`; the split is the type, not a comment); the
  **functional-core / imperative-shell** idiom (the pure spine is the whole
  decision; the shell is a thin `=>` wrapper — mirrors `cycle-step` vs `run-batch`);
  **boundary sums** (`PlanOutcome` = `plan-ok`/`plan-no-route`/`plan-no-fire`/
  `plan-unbound` — every routing failure is a variant the caller cases, never an
  exception); **totality** (fan-out recurses structurally on the fired-expert list;
  no unbounded loop); the **float→I64 wall** (num-ctx/duration-ms are I64); a
  **module-level split** — the pure spine (`plan.chiral`) imports NO backend, so a
  test over it needs no HTTP linkage at all.
- **The reframing:** the run loop is TWO things wearing one name. (1) A pure
  decision: given the request/doc/extra/pipeline/pool/config, WHO fires and on WHAT
  model — `plan-run : (-> ... PlanOutcome)`. And, given the fired experts + their
  already-obtained outcomes + the combiner's outcome, WHAT is the run record —
  `assemble-manifest : (-> ... RunManifest)`. Both `->`, both testable with canned
  outcomes. (2) An effectful actuation: `call-expert`/`call-combiner` wrap `be-chat`,
  and `run-pipeline : (=> ...)` is `plan-run` (pure) → fan-out `call-expert` over the
  fired experts → `call-combiner` → `assemble-manifest` (pure). `guarded-run` folds
  E67's `cycle-step` over the run's per-expert outcomes (the breaker sees the run).
- **What chirality makes impossible here:** a model call inside the router (the arrow is
  `->`); a `KeyError` for an unbound slot (it is a `bind-miss` → `plan-unbound`
  VALUE); an untyped manifest (it is a `RunManifest`); a run loop untestable without
  a live model (the pure spine is the whole decision and takes canned outcomes); a
  float crossing the seam (there is no float type).

## 5. Chirality example (fleshed)

Two files. `plan.chiral` — the PURE spine (imports match/gate/bind/types, **NO
backend**, so a test over it links nothing):

```chirality
; ==================================================== manas run-loop PURE spine
; E138 (METIS-PORT-SPEC §1/§4). plan-run (match->gate->bind: who fires + on what
; model) and assemble-manifest (fired experts + outcomes -> run record). Both -> ;
; NO backend import -> this leaf links nothing, so the spine test is a pure blob.
(import "prelude")
(import "collections")          ; foldl, filter, find, append, reverse
(import "prapanca/core/types")     ; Expert, Binding, Config, Pipeline, ExpertOutcome, CombinerOutcome, ExpertCall, RunManifest, PlanOutcome? (minted here)
(import "prapanca/core/match")     ; match-pipeline, pipeline-id
(import "prapanca/core/gate")      ; run-gate, dedup-str, elem-str
(import "prapanca/core/bind")      ; bind-config

; the plan: WHO fires + on WHAT model, or a routing-failure VALUE (boundary sum).
(data PlanOutcome ()
  (plan-ok       (pipeline-id Str) (config-id Str) (routing Str)
                 (fired (List Expert)) (combiner Expert) (bindings (List Binding)))
  (plan-no-route (listing (List (Pair Str Str))))    ; match failed / tied
  (plan-no-fire  (reason Str))                        ; gate fired nothing
  (plan-unbound  (missing (List Str)) (config-id Str))); a slot has no binding

; private accessors — named to NOT collide with the pool/profile accessors this
; module sits beside in a combined blob (doc-refine's expert-id, profiles' config-id).
(def exp-id   (-> Expert Str) (lam (e) (case e ((expert id l s r sl t) id))))
(def exp-slot (-> Expert Str) (lam (e) (case e ((expert id l s r sl t) sl))))
(def cfg-id   (-> Config Str) (lam (c) (case c ((config id bs) id))))
(def pipe-gate     (-> Pipeline (List GateRule)) (lam (p) (case p ((pipeline id w g o e c st y) g))))
(def pipe-combiner (-> Pipeline Str)             (lam (p) (case p ((pipeline id w g o e c st y) c))))
(def find-expert (-> Str (List Expert) (Maybe Expert))
  (lam (want pool) (find Expert (lam (e) (str-eq (exp-id e) want)) pool)))
(def bnd-model (-> (List Binding) Str Str)
  (lam (bs slot) (case (find Binding (lam (b) (case b ((binding s m n) (str-eq s slot)))) bs)
                   (none "") ((some b) (case b ((binding s m n) m))))))
; bnd-ctx similar (returns the I64 num-ctx, 0 default); ids-of-experts = foldl exp-id

; fired ids -> Expert values (drop unknowns); their deduped slots (+ combiner slot).
(def fired-experts-of (-> (List Str) (List Expert) (List Expert))
  (lam (ids pool)
    (foldl Str (List Expert)
      (lam (acc id) (case (find-expert id pool)
                      ((some e) (append Expert acc (cons e nil))) (none acc)))
      nil ids)))

; plan-run: the pure decision. match -> gate -> bind, each failure a PlanOutcome.
(def plan-run (-> Str (List Pipeline) (List Expert) Config Str (List (Pair Str Str)) PlanOutcome)
  (lam (req pipes pool config doc extra)
    (case (match-pipeline req pipes)
      ((match-none listing)     (plan-no-route listing))
      ((match-tied ids listing) (plan-no-route listing))
      ((match-found p w)
        (case (run-gate (pipe-gate p) doc extra)
          ((gate-no-match r) (plan-no-fire r))
          ((gate-fired ids reason)
            (let ((fired (fired-experts-of ids pool))
                  (comb  (case (find-expert (pipe-combiner p) pool)
                           ((some e) e) (none (expert (pipe-combiner p) "" "" "" "combiner" nil)))))
              (let ((slots (dedup-str (append Str (slots-of fired) (cons (exp-slot comb) nil)))))
                (case (bind-config config slots)
                  ((bind-miss missing cid) (plan-unbound missing cid))
                  ((bind-ok bindings)
                    (plan-ok (pipeline-id p) (cfg-id config) reason fired comb bindings)))))))))))

; assemble-manifest: fired experts + parallel outcomes + combiner outcome -> record.
; build-calls zips experts with outcomes (structural, lockstep); mk-call resolves
; each expert's slot -> bound-model (bnd-model), parsed-ok (from the outcome), and
; accepted-into-merge (elem-str id (combiner accepted-ids)). ALL foldl/find/case.
(def assemble-manifest
  (-> Str Str Str Str (List Expert) (List Binding) (List ExpertOutcome) CombinerOutcome RunManifest)
  (lam (req pid cid routing fired bindings outcomes comb-oc)
    (run-manifest "" req "" "" pid pid routing
      (ids-of-experts fired) cid bindings nil
      (build-calls fired bindings outcomes comb-oc) nil
      (case comb-oc ((combiner-ok y a r) y) ((combiner-bad r rs) "")) "")))
```

`runner.chiral` — the EFFECTFUL shell (imports `backend` + `plan`; this is the
module B1 lowers with the http linkage libs):

```chirality
; ================================================== manas run-loop EFFECTFUL shell
; E138 (METIS-PORT-SPEC §1/§4). call-expert/call-combiner wrap be-chat; run-pipeline
; = plan-run (pure) -> fan-out -> call-combiner -> assemble-manifest (pure). => .
(import "prelude") (import "collections")
(import "backend")                  ; be-chat, Msg, msg, ChatR   (=> http crossings)
(import "prapanca/core/assemble")      ; assemble-prompt
(import "prapanca/pipeline/plan")      ; plan-run, assemble-manifest, PlanOutcome, exp-slot, bnd-model, ...

; one expert call: assemble the SEES prompt (ctx nil — no retrieval, first cut),
; be-chat, wrap. parse-findings is trivial (whole response as one raw finding).
(def call-expert (=> Backend Expert Str (List (Pair Str Str)) Str ExpertOutcome)
  (lam (b ex doc extra model)
    (case (be-chat b model (cons (msg "user" (assemble-prompt ex doc extra nil)) nil))
      ((chat-ok t)    (expert-ok (cons (finding "raw" "" t) nil) t))
      ((chat-bad s r) (expert-bad r (str-cat "http-" (i64->str s)))))))

; call-combiner: findings -> be-chat -> CombinerOutcome (accepts all fired ids, first cut).
(def call-combiner (=> Backend Expert (List Finding) (List Str) Str CombinerOutcome)
  (lam (b ex findings fired-ids model)
    (case (be-chat b model (cons (msg "user" (assemble-prompt ex (render-findings findings) nil nil)) nil))
      ((chat-ok t)    (combiner-ok t fired-ids t))
      ((chat-bad s r) (combiner-bad r (str-cat "http-" (i64->str s)))))))

; fan-experts: call-expert once per fired expert, threading an accumulator (effect
; order explicit via let, mirroring manas.chiral drive-batch). Structural, total.
(declare fan-experts (=> Backend (List Expert) (List Binding) Str (List (Pair Str Str)) (List ExpertOutcome) (List ExpertOutcome)))
(def fan-experts
  (lam (b exps bindings doc extra acc)
    (case exps
      (nil (reverse ExpertOutcome acc))
      ((cons e rest)
        (let ((oc (call-expert b e doc extra (bnd-model bindings (exp-slot e)))))
          (fan-experts b rest bindings doc extra (cons oc acc)))))))

; run-pipeline: the full loop. plan-run (pure) -> fan-out -> combiner -> manifest (pure).
(def run-pipeline
  (=> Backend Str (List Pipeline) (List Expert) Config Str (List (Pair Str Str)) (Pair Str RunManifest))
  (lam (b req pipes pool config doc extra)
    (case (plan-run req pipes pool config doc extra)
      ((plan-no-route l)        (pair "" (empty-manifest req "no-route")))
      ((plan-no-fire reason)    (pair "" (empty-manifest req reason)))
      ((plan-unbound miss cid)  (pair "" (empty-manifest req "unbound")))
      ((plan-ok pid cid routing fired comb bindings)
        (let ((outcomes (fan-experts b fired bindings doc extra nil)))
          (let ((comb-oc (call-combiner b comb (gather-findings outcomes)
                           (ids-of-experts fired) (bnd-model bindings (exp-slot comb)))))
            (let ((m (assemble-manifest req pid cid routing fired bindings outcomes comb-oc)))
              (case comb-oc ((combiner-ok y a r) (pair y m)) ((combiner-bad r rs) (pair "" m))))))))))
```

`guarded.chiral` — fold E67's `cycle-step` breaker over the run's per-expert outcomes:

```chirality
(import "manas")                    ; cycle-step, Turn, turn, produced, failed
(import "fsm")                      ; Step, step-go, step-halt
(import "prapanca/pipeline/runner")    ; run-pipeline

; each expert-call's parsed-ok=false counts as a backend failure for the breaker;
; fold-breaker runs cycle-step from the incoming count, halting early on a trip.
(def guarded-run
  (=> Backend I64 Str (List Pipeline) (List Expert) Config Str (List (Pair Str Str))
      (Pair I64 (Pair Str RunManifest)))
  (lam (b fails req pipes pool config doc extra)
    (case (run-pipeline b req pipes pool config doc extra)
      ((pair yield m)
        (pair (fold-breaker fails (calls->turns (manifest-calls m))) (pair yield m))))))
```

- **Knobs to modify:** the parse-findings granularity (first cut = one raw finding;
  a real parser splits the model's JSON into structured `Finding`s); wiring
  `retrieve-context` (`be-search`) back in when RAG lands (ctx flows into
  `assemble-prompt`'s 4th arg, currently `nil`); switching `be-chat` → `be-chat-stream`
  for the combiner's on-delta yield (E137/streaming); the breaker's fail-limit
  (lives in `cycle-step`, swappable).
- **Deliberately omitted:** the linear-porttype Backend + `Exit`/`LocalZone` tokens
  (E137 — the spec §4 full type; this cut is plain-data Backend); retrieval
  (`retrieve-context`/`be-search`); the log seam (E139 `be-log`); streaming; the
  golden-manifest JSON conformance (E141/E142 — deserialize + `manifest-conforms`).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/manas/pipeline/plan.chiral` (pure spine — `plan-run`,
  `assemble-manifest`, `PlanOutcome`, `empty-manifest`, the private accessors; NO
  backend import), `scaffold/lib/manas/pipeline/runner.chiral` (effectful shell —
  `call-expert`, `call-combiner`, `fan-experts`, `run-pipeline`; imports backend +
  plan), `scaffold/lib/manas/pipeline/guarded.chiral` (`guarded-run` over
  `cycle-step`). The catalog's `expert.chiral`/`combine.chiral`/`retrieve.chiral` are
  consolidated into `runner.chiral` for the first cut (retrieve deferred).
- **Conformance target (the network-free gate):** a pure-spine test
  (`scaffold/tests/samples/e138_spine.chiral`) over the E140 payload. (A) `plan-run`
  a code+spec doc through `[doc-refine-pipeline]` + `expert-pool` +
  `smoke-local-config` → `plan-ok` whose fired experts ⊇ {claim-vs-source,
  anchor-sharpen, coverage-vs-spec} and whose bindings put claim-vs-source's slot
  (cheap-verifier) on `qwen2.5:0.5b`; under `cheap-local-config` the reasoner slot
  is `qwen3:8b` (the swappable-backend property). (B) feed CANNED `ExpertOutcome`s
  (one per fired expert) + a canned `CombinerOutcome` into `assemble-manifest` →
  the `RunManifest` has `fired-expert-ids` = the fired set, one `ExpertCall` per
  fired expert with the right `expert-id`/`slot`/`bound-model`, `config-id` =
  "smoke-local", `final-yield` = the combiner's yield. Plus a negative control.
  Exit 0 iff all hold. Because `plan.chiral` imports no backend, the test blob links
  nothing. The effectful `run-pipeline` is a SEPARATE gate: B1 must LOWER it (linking
  backend/http); its LIVE run against a model is a documented integration step,
  deferred until the endpoint is reachable — NOT this element's gate.
- **Open questions:**
  1. **Split the pure spine into its own leaf module?** RESOLVED: yes —
     `plan.chiral` (pure, no backend) separate from `runner.chiral` (effectful). The
     pure-spine test then needs no HTTP linkage, and the functional-core /
     imperative-shell boundary is a MODULE boundary, not just an arrow.
  2. **Plain-data vs linear-porttype Backend.** TAKEN: plain data (today's
     `backend.chiral`), `be-chat` as-is. E137 upgrades to the porttype + `Exit`/
     `LocalZone`; deferred there, not silently dropped.
  3. **parse-findings granularity.** TAKEN: trivial first cut (whole response = one
     `(finding "raw" "" text)`); the golden compares expert-call STRUCTURE, not
     finding granularity, so this does not affect the gate. Flagged for the real
     parser.
- **Related:** [[E138-run-loop]] · [[E133-manas-core-types]] (all the record types) ·
  [[E134-gate]] (`run-gate`) · [[E135-bind]] (`bind-config`) · [[E136-match]]
  (`match-pipeline`/`assemble-prompt`) · [[E140-profiles-docrefine]] (the payload the
  test runs on) · [[E67]] (`cycle-step` breaker `guarded-run` folds in) · E137
  (linear-porttype Backend — the deferred upgrade) · E139 (`be-log` seam).
