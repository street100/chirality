---
element: E135
slug: bind
title: **Config binding — slot→model, the "add backends" seam** (Wave 2): `bind-config : (-> Pipeline Config (List Str) BindResult)` resolving each fired agent's SLOT (`cheap-verifier`/`reasoner`/`combiner`) to a `(model, num_ctx)` `Binding`; a missing slot is a `bind-miss` **value** the caller must handle, not a `KeyError`. Selecting a Config *is* the model-mixing — the **same pipeline runs under any backend profile unchanged**. `num_ctx` is part of the binding (silent-truncation WALL). `scaffold/lib/manas/core/bind.chiral`
kind: BUILD
reference_class: OURS/SPEC
ours_source: (none)
status: drafted
updated: 2026-08-15
---

# E135 — **Config binding — slot→model, the "add backends" seam** (Wave 2): `bind-config : (-> Pipeline Config (List Str) BindResult)` resolving each fired agent's SLOT (`cheap-verifier`/`reasoner`/`combiner`) to a `(model, num_ctx)` `Binding`; a missing slot is a `bind-miss` **value** the caller must handle, not a `KeyError`. Selecting a Config *is* the model-mixing — the **same pipeline runs under any backend profile unchanged**. `num_ctx` is part of the binding (silent-truncation WALL). `scaffold/lib/manas/core/bind.chiral`

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E135, config binding — the **"add backends" seam** of the manas
  Mixture-of-Experts orchestrator. Given a `Config` (a profile: a list of
  slot→`(model, num_ctx)` `Binding`s) and the deduped SLOTS a run needs,
  `bind-config` returns a `BindResult` — `bind-ok bindings` if every needed slot
  is bound, or `bind-miss missing-slots config-id` (a VALUE the caller cases on,
  not a `KeyError`). Selecting a Config *is* the model-mixing: the SAME pipeline
  runs under any backend profile unchanged. Lands in
  `scaffold/lib/manas/core/bind.chiral`, Wave 2 of METIS-PORT-SPEC (§11).
- **Kind:** BUILD (a designed-but-unbuilt feature — nothing to shed, nothing to
  self-host; today the model id is a hardcoded literal at the call site
  (`agent-run "…" "qwen3:8b"`), and there is no `bind-config`/`Binding` lookup in
  chirality logic yet — the types are E133, the logic is grep-clean).
- **Why chirality needs its own:** binding is the point where a run commits to *which
  backend runs each slot*. Because binding is per-slot, one profile already mixes
  models within a single run (a 0.5B verifier + an 8B reasoner in the same pass);
  there is no separate "mixer". A missing slot is not an exception that bypasses
  the return type — it is a `bind-miss` variant carrying WHICH slots are missing
  and the config id, so the caller decides. The function is pure `->`: resolving a
  slot is a list lookup, never a network call.

## 2. Research

- **Reference class:** OURS/SPEC.
  - **SPEC (the code)** = `/workspace/manas/.planning/METIS-PORT-SPEC.md` §6 — the
    actual chirality `bind-config`: dedup the slots, `filter` the ones with no binding,
    return `bind-miss` if any are missing else `bind-ok` with the resolved
    bindings. §6 also names the *deferred* dependent target (`Config (covers S)`
    with an erased coverage proof) — that is **E143, NOT this element**; the honest
    first cut is the `BindResult` sum, which is what E135 builds.
  - **OURS (the real profiles)** = `/workspace/manas/orchestration/configs.md` — the
    ground-truth Config values: `smoke-local` (every slot → `qwen2.5:0.5b`),
    `cheap-local` (cheap-verifier → `qwen2.5:0.5b`, reasoner/combiner → `qwen3:8b`),
    `quality-local` (mixed families). The slots in use are `cheap-verifier`,
    `reasoner`, `combiner`.
- **Key findings (load-bearing):**
  1. **`num_ctx` is part of the binding, not an afterthought (WALL).** Ollama's
     default context is only 2k–4k tokens; anything longer is silently truncated
     mid-run with no error. So every `Binding` names an explicit `num-ctx` (I64 —
     the float wall) and the driver must send it as `options.num_ctx`. Per-slot
     defaults: `cheap-verifier` 8192, `reasoner` 16384, `combiner` 16384.
  2. **The types are already built (E133).** `Binding` (`binding slot model
     num-ctx`), `Config` (`config id binds`, `binds : (List Binding)`), and
     `BindResult` (`bind-ok bindings` | `bind-miss missing-slots config-id`) live in
     `scaffold/lib/manas/core/types.chiral`. E135 imports them and adds ONLY the
     logic — no type redefinition. Config models the JSON slot-map as a
     `(List Binding)`, each Binding carrying the slot the JSON had as its key.
  3. **A missing slot is a VALUE, not a `KeyError`.** METIS-PORT-SPEC §6: "the
     Python driver has `bind_config` that raises `KeyError` if a slot is unbound.
     In chirality, the result is a sum type — the caller MUST handle the missing-slot
     case." This is the boundary-sums directive: the "which slots are missing"
     classification is a closed sum at the boundary, cased downstream.
  4. **The Expert pool (E140) is not built yet.** METIS-PORT-SPEC §6's signature is
     `(-> Pipeline Config (List Str expert-ids))` and it calls `expert-slot eid` to
     map each fired expert → its slot. That lookup depends on the Expert pool
     (E140), which does not exist. So E135 takes the **slots-needed directly** —
     `bind-config : (-> Config (List Str) BindResult)` (the `(List Str)` is the
     deduped slots the fired agents need); *extracting slots-from-fired-experts is
     E138's job* (the runner reads each fired Expert's `slot` field and passes the
     deduped slot list here). This keeps E135 self-contained and honest — see §6.

## 3. Conventional (other-language) approach

The Python driver resolves each fired expert's slot against the config dict and
raises when a slot is unbound:

```python
def bind_config(pipeline, config, expert_ids):
    slots_needed = dedup(expert_slot(eid) for eid in expert_ids)  # needs the pool
    bindings = []
    for slot in slots_needed:
        entry = config.binds[slot]        # <-- KeyError if slot unbound (a throw)
        bindings.append(Binding(slot, entry["model"], entry["num_ctx"]))
    return bindings
```

- **Assumptions it bakes in:** the missing-slot path is a `KeyError` that bypasses
  the return type (the caller cannot see it in the signature and cannot enumerate
  *which* slots were missing without catching and re-inspecting); `bindings` is a
  mutable accumulator; `num_ctx` is a loose dict field, not a typed part of the
  binding; the slot→model resolution and the expert→slot resolution are tangled in
  one function. chirality refuses all of it: the arrow is `->` (no network call is
  even expressible), the missing case is a named `bind-miss` variant carrying the
  missing slots + config id, the fold is over an immutable list, `num-ctx` is an
  I64 field of `Binding`, and the expert→slot step is split out (E138) so binding
  is a pure slot→binding lookup.

## 4. The chirality idea

- **Chirality features in play:** the **effect membrane** (`->` = empty row — binding
  is a pure lookup, provably no network); **closed sums + `case` exhaustiveness**
  (`BindResult` is the boundary sum; the caller must handle both `bind-ok` and
  `bind-miss`); the **boundary-sums directive** (the missing-slot set is a value
  carried in the variant, never a raise or a nullable-without-reason); the
  **float→I64 wall** (`num-ctx` is I64, never a float); **totality** (structural
  fold over the slot list, no unbounded loop).
- **The reframing:** the imperative accumulator-plus-raise becomes a pure two-pass
  resolve. `bind-config` `filter`s the needed slots to those the config does NOT
  bind (`slot-missing?`), and either returns `bind-miss` (any missing) or
  `bind-ok` with the resolved `Binding`s (a `foldl` that looks each slot up and
  appends its binding). Selecting *which* Config to pass is the model-mixing — the
  same slot set resolves to `qwen2.5:0.5b` everywhere under `smoke-local` but to
  `qwen3:8b` for the reasoner/combiner under `cheap-local`, with the pipeline
  unchanged.
- **What chirality makes impossible here:** a binding step that calls a model (the
  arrow is `->`; any `=>` call is rejected at the application site); a missing slot
  that fails silently or by exception (`bind-miss` is a variant the caller must
  case on, carrying exactly which slots and which config); a `num_ctx` that
  silently defaults (it is a required I64 field of every `Binding`); a float in the
  binding (there is no float type and `Binding` has no float field).

## 5. Chirality example (fleshed)

Imports `prelude` (`str-eq`, `Maybe`, `List`, `Bool`) and the already-built
`manas/core/types` (`Binding`, `Config`, `BindResult`) and `collections` (`find`,
`filter`, `foldl`, `append`). Every arrow is `->`; there is no `=>` anywhere.
`case` is exhaustive. Accumulation uses `foldl`/`filter`/`find`/`append` — NOT
`map-list`, which does not lower in an isolated leaf blob on this branch (E134's
finding).

```chirality
; ============================================================ manas config binding
; E135, Wave 2 (METIS-PORT-SPEC §6). The "add backends" seam: resolve the SLOTS a
; run needs against a Config profile, returning a BindResult. PURE (->) — a slot
; lookup is a list scan, never a crossing; the membrane PROVES no network call.
; A missing slot is a bind-miss VALUE (the caller cases), not a KeyError. num-ctx
; is an I64 field of Binding (the float wall). Types (Binding/Config/BindResult)
; are E133 — imported, never redefined.

(import "prelude")             ; str-eq, and/or/not, cond, List, Pair, Bool, Maybe
(import "collections")         ; find, filter, foldl, append
(import "manas/core/types")    ; Binding (binding slot model num-ctx), Config, BindResult

; ------------------------------------------------------------- binding accessor
; the SLOT a binding resolves. Pattern-match the single ctor; pure. num-ctx and
; model are ignored here (only the slot key matters for lookup).
(def binding-slot (-> Binding Str)
  (lam (b) (case b ((binding s m n) s))))

; ----------------------------------------------------------------- slot lookup
; find the Binding for `slot` in a config's bind list. `find` returns
; (Maybe Binding): (some b) when a binding's slot key matches, else none.
; Pure linear scan; str-eq compares slot keys.
(def lookup-binding (-> (List Binding) Str (Maybe Binding))
  (lam (binds slot)
    (find Binding
      (lam (b) (str-eq (binding-slot b) slot))
      binds)))

; is `slot` UNbound in this bind list? none -> missing (true). Used by filter to
; collect the missing slots for a bind-miss.
(def slot-missing? (-> (List Binding) Str Bool)
  (lam (binds slot)
    (case (lookup-binding binds slot)
      (none true)
      ((some b) false))))

; ----------------------------------------------------------------- bind-config
; bind-config: resolve the deduped slots a run needs against a Config profile.
; Pure (->). Two passes: (1) filter the needed slots to those the config does NOT
; bind; (2) if any are missing -> bind-miss (carrying the missing slots + the
; config id, a VALUE the caller handles); else bind-ok with the resolved Bindings.
; The bindings are accumulated with foldl+append (map-list does not lower in an
; isolated blob on this branch — E134's finding); in the ok branch every lookup is
; (some b) by construction (the missing set was empty), so the (none acc) arm is
; unreachable and preserves the accumulator.
;
; NOTE (signature): the slots-needed (List Str) are passed DIRECTLY, not extracted
; from fired-expert-ids as METIS-PORT-SPEC §6 sketched — the Expert pool (E140) is
; not built, so E135 cannot map expert -> slot. Extracting the deduped slot list
; from each fired Expert's `slot` field is E138's job (the runner). This keeps
; bind-config a self-contained, pure slot -> binding resolver. (See §6.)
(def bind-config (-> Config (List Str) BindResult)
  (lam (config slots-needed)
    (case config
      ((config cid binds)
        (let ((missing
                (filter Str
                  (lam (slot) (slot-missing? binds slot))
                  slots-needed)))
          (case missing
            ((cons h t) (bind-miss missing cid))
            (nil
              (bind-ok
                (foldl Str (List Binding)
                  (lam (acc slot)
                    (case (lookup-binding binds slot)
                      ((some b) (append Binding acc (cons b nil)))
                      (none acc)))
                  nil slots-needed)))))))))
```

- **Knobs to modify:** the `Config` value passed in (the whole "add backends"
  seam — a different profile swaps the backend mix with the pipeline unchanged);
  whether a partial `bind-ok` (bind what's present, report the rest) is ever
  wanted (here binding is all-or-nothing — any missing slot short-circuits to
  `bind-miss`); the dedup policy of the incoming slot list (E135 assumes it is
  already deduped by the caller — E138).
- **Deliberately omitted:** the expert→slot extraction (E138 — needs the Expert
  pool, E140); the dependent `Config (covers S)` coverage proof (E143 — the
  METIS-PORT-SPEC §6 target); preflight model-availability / trust-boundary checks
  (`PreflightResult`, a later element); the actual model call (`call-expert`,
  Wave 3, `=>`).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/manas/core/bind.chiral` (NEW — Wave 2). Imports
  `prelude`, `collections`, and `manas/core/types` (E133). No `ports`, no
  `backend`, no crossing — the whole file is `->`.
- **Conformance target:** reproduce the config-swap property from
  `orchestration/configs.md`: binding the slot set `{cheap-verifier, reasoner,
  combiner}` under `smoke-local` resolves all three to `qwen2.5:0.5b`; the SAME
  slot set under `cheap-local` resolves the reasoner/combiner to `qwen3:8b` (the
  swappable-backend property — same pipeline, different mix); and asking for a
  slot a config does not bind returns `bind-miss` carrying that slot. The
  behavioral test builds these exact profiles and asserts all three.
- **Open questions:**
  1. **Signature: slots-needed direct vs expert-ids (METIS-PORT-SPEC §6).** TAKEN:
     `bind-config : (-> Config (List Str) BindResult)` takes the deduped slots
     directly. §6 sketched `(-> Pipeline Config (List Str expert-ids))` with an
     `expert-slot eid` lookup, but the Expert pool (E140) is not built — E135
     cannot map expert → slot. Extracting the deduped slot list from each fired
     Expert's `slot` field is **E138**'s job (the runner). Named home exists (E138,
     the runner; E140, the pool); not a phantom defer. Documented deviation from §6.
  2. **All-or-nothing vs partial binding.** TAKEN: all-or-nothing — any missing
     slot short-circuits to `bind-miss` (a run can't fire an agent with no backend,
     so a partial bind is not useful yet). A partial `bind-ok`-plus-`missing` shape
     is a knob a later runner could want; not load-bearing for E135.
  3. **Dependent `Config (covers S)` coverage proof.** Deferred to **E143** (the
     METIS-PORT-SPEC §6 target — an erased coverage proof moving the check to
     compile time). The `BindResult` sum is the honest Wave-1 form; not a phantom
     defer (E143 named). 
- **Related:** [[E135-bind]] · [[E133-manas-core-types]] (`Binding`/`Config`/
  `BindResult` — imported) · [[E134-gate]] (`run-gate` decides *who* fires; E135
  binds the fired agents' slots) · [[E138-runner]] (extracts the deduped slot list
  from fired experts, then calls `bind-config`).
