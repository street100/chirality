---
element: E138
slug: run-loop
title: **The multi-agent run loop (N1)** — the MoE heart. Functional-core / imperative-shell: a PURE spine (`plan-run` = match→gate→bind; `assemble-manifest` = fired experts + already-obtained outcomes → `RunManifest`) that is the whole network-free testable decision, and an EFFECTFUL shell (`call-expert`/`call-combiner`/`run-pipeline`, `=>` over `be-chat`). `guarded-run` folds E67's `cycle-step` breaker over the run. `scaffold/lib/manas/pipeline/{plan,runner,guarded}.chiral`
kind: BUILD
example: examples/E138-run-loop.md
status: audited
updated: 2026-08-15
---

# E138 SPEC — the multi-agent run loop (N1): the MoE heart, functional-core / imperative-shell

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** three new chirality modules —
  `scaffold/lib/manas/pipeline/plan.chiral` (the PURE spine: `plan-run` +
  `assemble-manifest` + the `PlanOutcome` sum + `empty-manifest` + private
  accessors; imports NO backend), `scaffold/lib/manas/pipeline/runner.chiral` (the
  EFFECTFUL shell: `call-expert`, `call-combiner`, `fan-experts`, `run-pipeline`;
  imports backend + plan), `scaffold/lib/manas/pipeline/guarded.chiral`
  (`guarded-run` folding E67's `cycle-step` breaker over the run) — plus a
  network-free conformance test `scaffold/tests/samples/e138_spine.chiral`. B1
  compiles the effectful `runner.chiral` (linking backend/http) and the
  pure-spine test exits 0.
- **Non-goals:** no linear-porttype Backend / `Exit` / `LocalZone` (E137); no
  retrieval (`be-search`); no streaming (`be-chat-stream`); no `be-log` (E139); no
  golden-manifest JSON conformance (E141/E142); no LIVE model run (the endpoint is
  unreachable — the live run of `run-pipeline` is a deferred integration step, not
  this element's gate).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no CONFORMANCE-MAP row for E138 yet (fresh element);
  the catalog row is BUILD (`Not built — no fan-out runner in chirality`). This is
  glue-over-built-shards, not new algorithm.
- **Live code this composes with (name, do NOT respec):**
  - `manas/core/types` (E133) — `Expert`, `Binding`, `Config`, `Pipeline`,
    `ExpertOutcome` (`expert-ok`/`expert-bad`), `CombinerOutcome`
    (`combiner-ok`/`combiner-bad`), `Finding` (`finding`), `ExpertCall`
    (`expert-call`, 9 fields), `RunManifest` (`run-manifest`, 15 fields),
    `GateRule`, `GateDecision`, `PipelineMatch`, `BindResult`.
  - `manas/core/match` (E136) — `match-pipeline : (-> Str (List Pipeline)
    PipelineMatch)`, `pipeline-id`.
  - `manas/core/gate` (E134) — `run-gate : (-> (List GateRule) Str
    (List (Pair Str Str)) GateDecision)`, `dedup-str`, `elem-str`.
  - `manas/core/bind` (E135) — `bind-config : (-> Config (List Str) BindResult)`.
  - `manas/core/assemble` (E136) — `assemble-prompt : (-> Expert Str
    (List (Pair Str Str)) (List Str) Str)`.
  - `backend` — `be-chat : (=> Backend Str (List Msg) ChatR)` (plain-data Backend),
    `Msg`, `msg`, `ChatR` (`chat-ok`/`chat-bad`).
  - `manas` (E67) — `cycle-step : (-> I64 Turn (Step I64 Turn))`, `Turn`, `turn`,
    `Outcome` (`produced`/`failed`); `fsm` — `Step`, `step-go`, `step-halt`.
  - `manas/profile/{doc-refine,profiles}` (E140, TEST ONLY) —
    `doc-refine-pipeline`, `expert-pool`, `smoke-local-config`,
    `cheap-local-config`, and their accessors.
- **True delta:** the fan-out-and-merge glue — `PlanOutcome` (a new boundary sum),
  `plan-run`, `assemble-manifest`, `call-expert`, `call-combiner`, `fan-experts`,
  `run-pipeline`, `guarded-run`, and their private accessors. No existing symbol
  changes.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Split the pure spine into its own leaf module? | RESOLVED | Yes — `plan.chiral` (pure, no backend) is separate from `runner.chiral` (effectful). The functional-core / imperative-shell split is then a MODULE boundary, so the pure-spine test blob links no HTTP libs. Mirrors `manas.chiral`'s `cycle-step`/`run-recorded` (pure) vs `run-batch` (effectful) precedent, and the task's own "cleaner" recommendation. |
| 2 | Plain-data vs linear-porttype Backend + `Exit`/`LocalZone`? | DEFERRED (E137) | METIS-PORT-SPEC §2/§4 targets a linear porttype Backend + erased zone tokens; E137 is minted for exactly that upgrade. First cut rides today's `(data Backend () (backend (base Str)))` and `be-chat` as-is — plain (unrestricted) Backend, no threading, no `Exit`, no `LocalZone`. `run-pipeline` therefore drops the `(1 e Exit) (0 z LocalZone)` params of the §4 type. |
| 3 | parse-findings granularity? | RESOLVED | Trivial first cut: the whole model response becomes one `(finding "raw" "" text)`. The golden compares expert-call STRUCTURE (`expert-id`/`slot`/`bound-model`/`parsed-ok`), not finding granularity — so this does not affect the gate. A real JSON→`(List Finding)` parser is follow-on (no new element needed; lives inside `call-expert` when the worker is reachable). |
| 4 | Non-streaming combiner? | DEFERRED (E137/streaming) | Use `be-chat` (not `be-chat-stream`) for both experts and combiner — avoids the on-delta `(=> Str Unit)` fn-param and its lowering. The §4 `on-delta` param is dropped from `run-pipeline`. Streaming rides the porttype upgrade. |
| 5 | Retrieval (`retrieve-context`/`be-search`)? | DEFERRED (E139-adjacent / RAG) | Skipped. `assemble-prompt`'s context arg is `nil` (empty `(List Str)`); no `be-search` crossing. RAG is optional and re-enters by threading `retrieve-context`'s hits into `assemble-prompt`'s 4th arg later. |
| 6 | Consolidate `expert.chiral`/`combine.chiral`/`retrieve.chiral` into `runner.chiral`? | RESOLVED | Yes for the first cut — `call-expert`/`call-combiner` live in `runner.chiral`; `retrieve.chiral` is not built (decision #5). The catalog's five-file layout is the eventual home; consolidating keeps the first cut to three files + one test. |
| 7 | `run-pipeline` takes a Pipeline directly (§4) but `plan-run` does `match`? | RESOLVED | `plan-run` takes the REQUEST + a `(List Pipeline)` and matches to pick one (E136 is real, not a no-op) — this makes routing genuinely testable. `run-pipeline` likewise takes `(List Pipeline)` + `(List Expert)` pool (keeps the runner generic over the profile — no `doc-refine` import in the shell). |
| 8 | Naming to avoid duplicate top-level defs in a combined blob? | RESOLVED | E140's FLAG. Private accessors use non-colliding names: `exp-id`/`exp-slot` (not `expert-id`/`expert-slot-of`), `cfg-id` (not `config-id`), `pipe-gate`/`pipe-combiner` (not `pipeline-gate`), `bnd-model`/`bnd-ctx` (not `binding-model`). `dedup-str`/`elem-str`/`pipeline-id` are IMPORTED, not redefined. |

No NEEDS-AUTHOR: every open question is either derivable from a settled
doc/precedent (RESOLVED) or waits on an already-minted element (DEFERRED).

## 4. Change plan (ordered, commit-sized)

### Step 1 — `manas/pipeline/plan.chiral` (the pure spine)
- **Target:** new file. Imports `prelude`, `collections`, `manas/core/types`,
  `manas/core/match`, `manas/core/gate`, `manas/core/bind`. NO backend.
- **Change:** mint `PlanOutcome` (`plan-ok`/`plan-no-route`/`plan-no-fire`/
  `plan-unbound`). Private accessors `exp-id`/`exp-slot`/`cfg-id`/`pipe-gate`/
  `pipe-combiner`/`find-expert`/`bnd-model`/`bnd-ctx`/`ids-of-experts`/`slots-of`/
  `fired-experts-of`. `plan-run : (-> Str (List Pipeline) (List Expert) Config Str
  (List (Pair Str Str)) PlanOutcome)` = match→gate→bind, each failure a variant.
  `assemble-manifest : (-> Str Str Str Str (List Expert) (List Binding)
  (List ExpertOutcome) CombinerOutcome RunManifest)` (request, pipeline-id,
  config-id, routing, fired experts, bindings, parallel outcomes, combiner
  outcome). `build-calls`/`mk-call` (zip experts×outcomes → `ExpertCall`,
  structural lockstep). `empty-manifest : (-> Str Str RunManifest)` for the
  failure paths. All `->`, `foldl`/`filter`/`find`/`append`/`case` only, no
  `map-list`, no float, exhaustive `case`.
- **Size:** ~L

### Step 2 — `manas/pipeline/runner.chiral` (the effectful shell)
- **Target:** new file. Imports `prelude`, `collections`, `backend`,
  `manas/core/assemble`, `manas/pipeline/plan`.
- **Change:** `call-expert : (=> Backend Expert Str (List (Pair Str Str)) Str
  ExpertOutcome)` (assemble-prompt ctx=nil → be-chat → `expert-ok`/`expert-bad`);
  `render-findings : (-> (List Finding) Str)`; `call-combiner : (=> Backend Expert
  (List Finding) (List Str) Str CombinerOutcome)` (accepts all fired ids on ok,
  first cut); `fan-experts` (`=>`, accumulator-threaded structural recursion,
  one `call-expert` per fired expert on its slot's bound model); `run-pipeline :
  (=> Backend Str (List Pipeline) (List Expert) Config Str (List (Pair Str Str))
  (Pair Str RunManifest))` = `plan-run` → `fan-experts` → `call-combiner` →
  `assemble-manifest`; `gather-findings : (-> (List ExpertOutcome) (List Finding))`.
- **Size:** ~M

### Step 3 — `manas/pipeline/guarded.chiral` (breaker composition)
- **Target:** new file. Imports `prelude`, `collections`, `manas/core/types`,
  `manas`, `fsm`, `manas/pipeline/runner`.
- **Change:** `manifest-calls`/`call-parsed-ok` accessors; `call->turn`
  (parsed-ok=false → `(failed 0 "")`), `calls->turns`, `fold-breaker : (-> I64
  (List Turn) I64)` (runs `cycle-step` from the incoming count, halts early on a
  trip); `guarded-run : (=> Backend I64 Str (List Pipeline) (List Expert) Config
  Str (List (Pair Str Str)) (Pair I64 (Pair Str RunManifest)))`.
- **Size:** ~S

### Step 4 — `scaffold/tests/samples/e138_spine.chiral` (the network-free gate)
- **Target:** new test. Imports `prelude`, `collections`, `manas/pipeline/plan`,
  `manas/profile/doc-refine`, `manas/profile/profiles`. NO backend → pure blob.
- **Change:** `compile-main : (=> I64 I64)` asserting (A) `plan-run` over a
  code+spec doc through `[doc-refine-pipeline]` + `expert-pool` + `smoke-local-config`
  → `plan-ok` with fired ⊇ {claim-vs-source, anchor-sharpen, coverage-vs-spec} and
  claim-vs-source's slot (cheap-verifier) bound to `qwen2.5:0.5b`; under
  `cheap-local-config` the reasoner slot is `qwen3:8b`; (B) canned `ExpertOutcome`s
  (one per fired expert) + a canned `CombinerOutcome` into `assemble-manifest` →
  `RunManifest` with `fired-expert-ids` = fired set, one `ExpertCall` per fired
  expert with right `expert-id`/`slot`/`bound-model`, `config-id` = "smoke-local",
  `final-yield` = the canned yield; plus a negative control. Exit 0 iff all hold.
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** the pure spine reproduces the routing decision (who fires,
  on what model) and the run record STRUCTURE over the real E140 payload, with
  canned model outcomes — no network. The effectful shell type-checks and lowers
  (the membrane proves its row is exactly the backend crossings).
- **Tests to add:** `scaffold/tests/samples/e138_spine.chiral` (pure blob, no
  linkage; exit 0 with a negative control). Plus the B1 lowering check of
  `manas/pipeline/runner` (+ linkage libs) as the effectful-compiles gate.
- **Green line:** 709 test functions → the sample suite gains `e138_spine`
  (exit-code test); ledger-lint clean.
- **Done when:** (a) `B1 < resolve(runner) + linkage` exits 0 ("RUNNER B1 OK");
  (b) `B1 < resolve(plan + doc-refine + profiles) + e138_spine` compiles and the
  ELF exits 0, and a mutated assertion flips it to exit 1.

## 6. Residue & links

- **Deliberately unbuilt:** linear-porttype Backend + `Exit`/`LocalZone` (E137);
  retrieval / `be-search` (RAG, decision #5); streaming / `be-chat-stream` (E137);
  `be-log` run logging (E139); structured `parse-findings` (in-place follow-on);
  golden-manifest JSON deserialize + `manifest-conforms` (E141/E142); the LIVE
  `run-pipeline` run against a reachable model (integration step).
- **Follow-on:** E137 (porttype upgrade turns `run-pipeline`'s Backend linear +
  adds the zone tokens), E139 (`be-log` folds a `log-run` crossing in), E141/E142
  (golden conformance uses `assemble-manifest`'s output as the actual side).
- **Related:** [[E138-run-loop]] · [[E133-manas-core-types]] · [[E134-gate]] ·
  [[E135-bind]] · [[E136-match]] · [[E140-profiles-docrefine]] · E67 (`cycle-step`).
