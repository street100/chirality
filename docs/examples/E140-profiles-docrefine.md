---
element: E140
slug: profiles-docrefine
title: **Profiles + doc-refine pipeline as typed values — "add backends and test em"** (Wave 5): the four Config profiles (`cheap-local`, `quality`, `quality-local`, `smoke-local`) and the `doc-refine` Pipeline (its GATE rules, agent pool, combiner, STOP) as **typed chirality values**, not `.md` prose — the swappable-backend payload the config-binding seam (E135) consumes. `smoke-local` (every slot → the one resident `qwen2.5:0.5b`) is the guaranteed-runnable proof profile. `scaffold/lib/manas/profile/{profiles,doc-refine}.chiral`
kind: BUILD
reference_class: OURS/SPEC
ours_source: (none)
status: drafted
updated: 2026-08-15
---

# E140 — **Profiles + doc-refine pipeline as typed values — "add backends and test em"** (Wave 5): the four Config profiles (`cheap-local`, `quality`, `quality-local`, `smoke-local`) and the `doc-refine` Pipeline (its GATE rules, agent pool, combiner, STOP) as **typed chirality values**, not `.md` prose — the swappable-backend payload the config-binding seam (E135) consumes. `smoke-local` (every slot → the one resident `qwen2.5:0.5b`) is the guaranteed-runnable proof profile. `scaffold/lib/manas/profile/{profiles,doc-refine}.chiral`

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E140 — the manas orchestration **payload as typed chirality values**:
  the four `Config` profiles (`smoke-local`, `cheap-local`, `quality-local`,
  `quality`) and the `doc-refine` `Pipeline` (its GATE rules, its 7-agent Expert
  pool, its combiner + ORDER + STOP), lifted out of `.md` prose into `Config` /
  `Pipeline` / `Expert` VALUES the pure engine (E134 gate, E135 bind, E136 match)
  runs on directly. Two files: `scaffold/lib/manas/profile/profiles.chiral` (the
  configs + `profile-by-id`) and `scaffold/lib/manas/profile/doc-refine.chiral`
  (the pipeline + Expert pool + `expert-by-id` / `expert-slot-of`).
- **Kind:** BUILD — pure data (like E133's types), no logic beyond `find`-based
  lookups and single-ctor accessors. Nothing to shed, nothing to self-host; today
  the profiles/pipelines live ONLY as `.md` in `/workspace/manas/orchestration/`,
  with no typed chirality copy the engine can consume.
- **Why chirality needs its own:** binding (E135) and gating (E134) are pure functions
  over `Config` / `Pipeline` / `Expert` values — but those values did not exist as
  chirality data yet, only as English in `configs.md` / `processes.md` / `agents.md`.
  E140 is the swappable-backend PAYLOAD: with it, `bind-config <profile> <slots>`
  and `run-gate (pipeline-gate doc-refine) <doc> <extra>` run over the REAL
  orchestration data. `smoke-local` (every slot → the one resident `qwen2.5:0.5b`)
  is the guaranteed-runnable proof profile — the live end-to-end run is never
  blocked on an `ollama pull`.

## 2. Research

- **Reference class:** OURS/SPEC. Three ground-truth sources, transcribed to
  values (not invented):
  - `/workspace/manas/orchestration/configs.md` — the four profiles, each a
    slot→`(model, num_ctx)` map. `smoke-local`: all 3 slots → `qwen2.5:0.5b`
    (8192/16384/16384). `cheap-local`: cheap-verifier → `qwen2.5:0.5b`@8192,
    reasoner/combiner → `qwen3:8b`@16384. `quality-local`: cheap-verifier →
    `qwen2.5:3b-instruct`@8192, reasoner → `qwen3:8b`@16384, combiner →
    `qwen2.5-coder:7b`@16384. `quality`: cheap-verifier → `qwen3:1.7b`@8192,
    reasoner → `qwen3:8b`@16384, combiner → `deepseek-v4-pro`@16384 (cloud).
  - `/workspace/manas/orchestration/processes.md` (`doc-refine` template, ~line
    191) — the Pipeline: WHEN "a doc must be checked against reality, sharpened,
    and its examples completed/organized"; the GATE block (four condition→experts
    rules); AGENTS (the 7); COMBINER `curate-merge`; STOP "audit agents
    single-pass; sharpen + example agents loop-until-dry"; YIELD "revised_doc +
    cross-doc-drift flags".
  - `/workspace/manas/orchestration/agents.md` — the 7 agents doc-refine fires,
    each with its LENS/SEES/RETURNS/SLOT/TOOLS. The SLOT is load-bearing (it is
    what E135 binds): `claim-vs-source` → `cheap-verifier`; `coverage-vs-spec`,
    `cross-doc-drift`, `anchor-sharpen`, `example-completeness`,
    `example-organization` → `reasoner`; `curate-merge` → `combiner`.
- **Key findings (load-bearing):**
  1. **The types are already built (E133).** `Config`/`Binding`, `Pipeline`,
     `Expert`, `GateRule`, `Order` (`order-fan-out`/`order-chain`/`order-branch`),
     `StopPolicy` (`stop-single`/`stop-capped`/`stop-until-dry`) all live in
     `prapanca/core/types`. E140 imports them and adds ONLY values + `find`-based
     lookups — no type redefinition.
  2. **num_ctx is part of every Binding (silent-truncation WALL).** Ollama
     silently truncates past its 2k–4k default, so each Binding names an explicit
     `num-ctx` (I64 — the float wall). Per-slot defaults: cheap-verifier 8192,
     reasoner 16384, combiner 16384.
  3. **The GATE keywords must survive E134's substring predicates.** `run-gate`
     (E134) matches conditions by substring: `code`/`path`, `spec`/`req`,
     `sibling`, `example`. So the doc-refine GATE conditions must literally carry
     those tokens ("cites code/paths?", "maps to a spec/reqs?", "coupled to
     sibling docs?", "carries examples?") for the pipeline to route correctly.
  4. **E133 has NO accessors.** `pipeline-gate`, `config-id`, `expert-slot-of` do
     not exist; each is a one-line single-ctor `case` I add in the profile module
     as needed (E135/E136 already do this for their own accessors).
  5. **E138 (the runner) consumes these lookups.** `expert-by-id` +
     `expert-slot-of` are exactly how the runner turns doc-refine's fired-expert
     ids → the deduped slot list it hands to `bind-config`. E140 supplies the pool
     and the accessors; E138 does the DFS.

## 3. Conventional (other-language) approach

Outside chirality these live as YAML/dict config the driver `dict`-indexes at runtime:

```python
CONFIGS = {
  "smoke-local": {"cheap-verifier": {"model": "qwen2.5:0.5b", "num_ctx": 8192}, ...},
  "cheap-local": {"reasoner": {"model": "qwen3:8b", "num_ctx": 16384}, ...},
}
DOC_REFINE = {
  "gate": {"cites code/paths?": ["claim-vs-source", "anchor-sharpen"], ...},
  "agents": ["claim-vs-source", ...], "combiner": "curate-merge",
}
AGENTS = {"claim-vs-source": {"slot": "cheap-verifier", ...}, ...}
cfg = CONFIGS[profile_id]          # KeyError if the profile id is a typo
slot = AGENTS[eid]["slot"]         # KeyError / silent None if the agent is unknown
```

- **Assumptions it bakes in:** the profile/pipeline/agent tables are untyped
  dicts (a typo'd slot key is a `KeyError` at run time, not a compile error); an
  unknown id is a `KeyError` or a silent `None`; `num_ctx` is a loose dict field,
  easy to omit; the whole payload is stringly-typed prose the engine re-parses.
  chirality refuses all of it: the tables are typed `Config`/`Pipeline`/`Expert`
  VALUES the checker validates once; a missing id is a `none` the caller must
  `case`; `num-ctx` is a required I64 field of every `Binding`.

## 4. The chirality idea

- **Chirality features in play:** **closed sums as data** (each profile is a `Config`
  value, the pipeline a `Pipeline` value, each agent an `Expert` value — all
  checked by the kernel, not re-parsed from prose); the **`Maybe` boundary sum**
  (a lookup miss is `none`, cased downstream, never a `KeyError`); the
  **float→I64 wall** (`num-ctx` is I64); the **effect membrane** (`->` everywhere
  — `profile-by-id` / `expert-by-id` are pure list scans, provably no crossing);
  **totality** (`find` is a structural scan, no unbounded loop); the
  **boundary-sums directive** (ORDER/STOP are `Order`/`StopPolicy` sums the
  Pipeline embeds, never `Str` tags).
- **The reframing:** the `.md` prose and the runtime dict both become one typed
  value each. `smoke-local-config`, `cheap-local-config`, `quality-local-config`,
  `quality-config` are `Config` values; `doc-refine-pipeline` is a `Pipeline`
  value carrying its GATE as a `(List GateRule)`, its pool by id, its combiner
  id, `order-fan-out`, and `(stop-until-dry cap)`; `expert-pool` is a
  `(List Expert)`. Lookups are `find`: `profile-by-id`, `expert-by-id`. Accessors
  (`config-id`, `pipeline-gate`, `expert-slot-of`) are single-ctor `case`s.
- **What chirality makes impossible here:** a profile whose Binding omits `num_ctx`
  (it is a required field); a float context length; a lookup that raises instead
  of returning `none`; an ORDER/STOP stored as a bare string the consumer must
  re-classify; a `=>` sneaking into a config lookup (the arrows are all `->`).

## 5. Chirality example (fleshed)

Two files. `profiles.chiral` — the four Config values + `profile-by-id`:

```chirality
; ======================================================= manas config profiles
; E140, Wave 5 (OURS: orchestration/configs.md). The four backend profiles as
; typed Config VALUES — the swappable-backend payload E135's bind-config consumes.
; Pure data + a find-based lookup. num-ctx is I64 (the float wall). Types
; (Config/Binding) are E133 — imported, never redefined.
(import "prelude")             ; str-eq, List, Maybe
(import "collections")         ; find
(import "prapanca/core/types")    ; Config (config id binds), Binding (binding slot model num-ctx)

; config id accessor (E133 has no accessors; add the one we need)
(def config-id (-> Config Str)
  (lam (c) (case c ((config id binds) id))))

; smoke-local: every slot on the one resident model (guaranteed-runnable proof)
(def smoke-local-config Config
  (config "smoke-local"
    (cons (binding "cheap-verifier" "qwen2.5:0.5b" 8192)
    (cons (binding "reasoner"       "qwen2.5:0.5b" 16384)
    (cons (binding "combiner"       "qwen2.5:0.5b" 16384) nil)))))

; cheap-local: cheap verifier tiny, reasoner+combiner qwen3:8b (SAME pipeline,
; DIFFERENT backend mix — the config-swap property).
(def cheap-local-config Config
  (config "cheap-local"
    (cons (binding "cheap-verifier" "qwen2.5:0.5b" 8192)
    (cons (binding "reasoner"       "qwen3:8b"     16384)
    (cons (binding "combiner"       "qwen3:8b"     16384) nil)))))

; quality-local: mixed families, all LOCAL, capped <=8B; combiner is the coder.
(def quality-local-config Config
  (config "quality-local"
    (cons (binding "cheap-verifier" "qwen2.5:3b-instruct" 8192)
    (cons (binding "reasoner"       "qwen3:8b"            16384)
    (cons (binding "combiner"       "qwen2.5-coder:7b"    16384) nil)))))

; quality: reasoning slots upgraded; combiner reaches a cloud model.
(def quality-config Config
  (config "quality"
    (cons (binding "cheap-verifier" "qwen3:1.7b"       8192)
    (cons (binding "reasoner"       "qwen3:8b"         16384)
    (cons (binding "combiner"       "deepseek-v4-pro"  16384) nil)))))

(def all-profiles (List Config)
  (cons smoke-local-config
  (cons cheap-local-config
  (cons quality-local-config
  (cons quality-config nil)))))

; profile-by-id: find a Config by its id (Maybe Config — a miss is a VALUE).
(def profile-by-id (-> Str (List Config) (Maybe Config))
  (lam (want configs)
    (find Config (lam (c) (str-eq (config-id c) want)) configs)))
```

`doc-refine.chiral` — the Expert pool + the doc-refine Pipeline + the lookups:

```chirality
; ==================================================== manas doc-refine pipeline
; E140, Wave 5 (OURS: orchestration/{processes,agents}.md). The doc-refine
; Pipeline + its 7-agent Expert pool as typed VALUES. GATE conditions literally
; carry E134's keywords (code/path, spec/req, sibling, example). Pure data +
; find-based lookups + single-ctor accessors. Types are E133 — imported.
(import "prelude")             ; str-eq, List, Maybe
(import "collections")         ; find
(import "prapanca/core/types")    ; Pipeline, Expert, GateRule, Order, StopPolicy

; ---------------------------------------------------------- Expert pool accessors
(def expert-id (-> Expert Str)
  (lam (e) (case e ((expert id lens sees returns slot tools) id))))
(def expert-slot-of (-> Expert Str)
  (lam (e) (case e ((expert id lens sees returns slot tools) slot))))

; ---------------------------------------------------------- pipeline accessor
(def pipeline-gate (-> Pipeline (List GateRule))
  (lam (p) (case p ((pipeline id whn g o eids cmb stp yd) g))))

; ---------------------------------------------------------- the 7 doc-refine experts
(def claim-vs-source Expert
  (expert "claim-vs-source"
    "does each cited symbol / path / fact actually exist in its named source?"
    "{ doc_claims[], source_files[] }"
    "finding[]{ location, cited, verdict, evidence }"
    "cheap-verifier"
    (cons "read" (cons "grep" nil))))
; ... coverage-vs-spec, cross-doc-drift, anchor-sharpen, example-completeness,
;     example-organization (all slot "reasoner"), curate-merge (slot "combiner")

(def expert-pool (List Expert)
  (cons claim-vs-source
  (cons coverage-vs-spec
  (cons cross-doc-drift
  (cons anchor-sharpen
  (cons example-completeness
  (cons example-organization
  (cons curate-merge nil))))))))

; expert-by-id: find an Expert by id (E138 maps fired ids -> slots via this).
(def expert-by-id (-> Str (List Expert) (Maybe Expert))
  (lam (want pool)
    (find Expert (lam (e) (str-eq (expert-id e) want)) pool)))

; ---------------------------------------------------------- the doc-refine GATE
(def doc-refine-gate (List GateRule)
  (cons (gate-rule "cites code/paths?"
          (cons "claim-vs-source" (cons "anchor-sharpen" nil)))
  (cons (gate-rule "maps to a spec/reqs?"
          (cons "coverage-vs-spec" nil))
  (cons (gate-rule "coupled to sibling docs?"
          (cons "cross-doc-drift" nil))
  (cons (gate-rule "carries examples?"
          (cons "example-completeness" (cons "example-organization" nil)))
        nil)))))

; ---------------------------------------------------------- the doc-refine Pipeline
(def doc-refine-pipeline Pipeline
  (pipeline "doc-refine"
    "a doc must be checked against reality, sharpened, and its examples completed/organized"
    doc-refine-gate
    order-fan-out
    (cons "claim-vs-source" (cons "coverage-vs-spec" (cons "cross-doc-drift"
     (cons "anchor-sharpen" (cons "example-completeness"
     (cons "example-organization" (cons "curate-merge" nil)))))))
    "curate-merge"
    (stop-until-dry 8)
    "revised_doc + cross-doc-drift flags"))
```

- **Knobs to modify:** the four profiles' backend mix (the whole "add backends"
  seam — swap a model tag or `num-ctx` and every pipeline re-binds unchanged); the
  `stop-until-dry` cap; adding a fifth profile (e.g. `all-local-max`); adding an
  Expert to the pool + wiring it into a GATE rule.
- **Deliberately omitted:** the runner's fired-ids→slots DFS (E138 — it USES
  `expert-by-id`/`expert-slot-of`); the JSON deserializer that folds a config map
  into a `(List Binding)` (E141); the dependent `Config (covers S)` coverage proof
  (E143); the other pipeline templates (bug-fix, review, …) — E140 is doc-refine
  only.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/manas/profile/profiles.chiral` (the four Configs +
  `profile-by-id`) and `scaffold/lib/manas/profile/doc-refine.chiral` (the pipeline
  + Expert pool + `expert-by-id`/`expert-slot-of`). Both import `prelude`,
  `collections`, `prapanca/core/types`. Both pure `->`, no ports, no crossing.
- **Conformance target:** the INTEGRATION test proves the real payload flows
  through the pure core. (1) `match-pipeline <a doc-refine-ish request>
  (cons doc-refine-pipeline nil)` → `match-found` doc-refine. (2) `run-gate
  (pipeline-gate doc-refine-pipeline) <doc with ```code``` + a path + a spec
  extra-input> extra` → `gate-fired` with ids ⊇ {claim-vs-source, anchor-sharpen,
  coverage-vs-spec}. (3) those fired ids → slots (via `expert-by-id` +
  `expert-slot-of`), deduped, then `bind-config smoke-local-config <slots>` →
  `bind-ok`, AND `bind-config cheap-local-config <slots>` → `bind-ok` where the
  reasoner binding's model = `qwen3:8b` (the swappable-backend property: same
  fired-slot set, different backend).
- **Open questions:**
  1. **`stop-until-dry` cap value.** processes.md says "sharpen + example agents
     loop-until-dry" without a numeric cap. TAKEN: `(stop-until-dry 8)` — a
     finite honest cap (chirality totality forbids an unbounded loop; the cap is the
     structural measure). A later runner can tune it; not load-bearing for E140.
  2. **STOP is per-agent-class in the prose (audit single-pass; sharpen/example
     loop-until-dry) but the `Pipeline.stop` field is ONE `StopPolicy`.** TAKEN:
     the pipeline-level STOP is `stop-until-dry` (the strongest of the two — the
     loop dominates); per-agent-class STOP is a Pipeline-shape refinement deferred
     to the dependent/typed-I/O Pipeline target (types.chiral §6, "the TARGET").
     Flagged, not silently resolved.
  3. **`gate-rule` conditions must carry E134's substring keywords.** RESOLVED:
     conditions are authored as "cites code/paths?", "maps to a spec/reqs?",
     "coupled to sibling docs?", "carries examples?" — each contains the literal
     token `run-gate` scans for (gate.chiral:67-78). Verified against E134's
     `condition-fires`.
- **Related:** [[E140-profiles-docrefine]] · [[E133-manas-core-types]]
  (`Config`/`Pipeline`/`Expert`/`GateRule`/`Order`/`StopPolicy` — imported) ·
  [[E134-gate]] (`run-gate` over `pipeline-gate doc-refine-pipeline`) ·
  [[E135-bind]] (`bind-config` over `smoke-local-config`/`cheap-local-config`) ·
  [[E136-match]] (`match-pipeline` over `doc-refine-pipeline`) · [[E138-runner]]
  (consumes `expert-by-id`/`expert-slot-of` to map fired ids → slots).
