---
element: E135
slug: bind
title: **Config binding — slot→model, the "add backends" seam** (Wave 2): `bind-config : (-> Pipeline Config (List Str) BindResult)` resolving each fired agent's SLOT (`cheap-verifier`/`reasoner`/`combiner`) to a `(model, num_ctx)` `Binding`; a missing slot is a `bind-miss` **value** the caller must handle, not a `KeyError`. Selecting a Config *is* the model-mixing — the **same pipeline runs under any backend profile unchanged**. `num_ctx` is part of the binding (silent-truncation WALL). `scaffold/lib/manas/core/bind.chiral`
kind: BUILD
example: examples/E135-bind.md
status: audited
updated: 2026-08-15
---

# E135 SPEC — **Config binding — slot→model, the "add backends" seam** (Wave 2): `bind-config : (-> Pipeline Config (List Str) BindResult)` resolving each fired agent's SLOT (`cheap-verifier`/`reasoner`/`combiner`) to a `(model, num_ctx)` `Binding`; a missing slot is a `bind-miss` **value** the caller must handle, not a `KeyError`. Selecting a Config *is* the model-mixing — the **same pipeline runs under any backend profile unchanged**. `num_ctx` is part of the binding (silent-truncation WALL). `scaffold/lib/manas/core/bind.chiral`

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/manas/core/bind.chiral` exists — a pure (`->`)
  module that imports `prelude`, `collections`, and `manas/core/types` (E133) and
  defines `binding-slot`, `lookup-binding`, `slot-missing?`, and
  `bind-config : (-> Config (List Str) BindResult)`. It resolves the deduped SLOTS
  a run needs against a `Config` profile: `bind-ok bindings` if every needed slot
  is bound, else `bind-miss missing-slots config-id` (a VALUE, not a `KeyError`).
  It compiles clean under B1 when pulled into a leaf blob, and a behavioral entry
  program builds two profiles (`smoke-local`, `cheap-local`) + a deficient one and
  exercises the config-swap property (same slot set, different backend mix) plus a
  missing-slot case, exiting `0` on all-pass.
- **Non-goals:** the expert→slot extraction from fired-expert-ids (E138 — needs the
  Expert pool E140; decision #1); the dependent `Config (covers S)` coverage proof
  (E143 — METIS-PORT-SPEC §6 target; decision #3); partial `bind-ok`-plus-missing
  binding (all-or-nothing here; decision #2); preflight model-availability /
  trust-boundary checks (`PreflightResult`, a later element); the actual model call
  (`call-expert`, Wave 3, `=>`). Those live in §6.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E135 postdates the map snapshot (bundle §3
  confirms). Treat as **BUILD** (forward construction; nothing to reshape).
- **Live code it composes with:**
  - `prelude` — `str-eq` (`extern (-> Str Str Bool)`), `Maybe` (`none` / `(some
    val)`), `List` (`cons`/`nil`), `Pair`, `Bool` (`true`/`false`), `cond`/`else`.
  - `collections` — `find (-> (0 A) (-> A Bool) (List A) (Maybe A))`,
    `filter (-> (0 A) (-> A Bool) (List A) (List A))`,
    `foldl (-> (0 A) (0 B) (-> B A B) B (List A) B)`,
    `append (-> (0 A) (List A) (List A) (List A))`.
  - `manas/core/types` (E133) — `Binding` (`(binding (slot Str) (model Str)
    (num-ctx I64))`), `Config` (`(config (id Str) (binds (List Binding)))`), and
    `BindResult` (`(bind-ok (bindings (List Binding)))` / `(bind-miss (missing-slots
    (List Str)) (config-id Str))`). Imported, NOT redefined.
- **True delta:** one new file, 4 pure `def`s (`binding-slot`, `lookup-binding`,
  `slot-missing?`, `bind-config`), zero change to any existing file. No `declare`
  needed (no self-recursive helper — all recursion is inside `find`/`filter`/`foldl`
  from `collections`). Sibling E134 (`gate.chiral`) is the direct house-style model.

## 3. Decisions

Every open question from the example §6, dispositioned. RESOLVED only when
derivable from a settled doc / the element brief; genuinely novel design → NEEDS-AUTHOR.

| # | Question (example §6) | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Signature: slots-needed direct vs the METIS-PORT-SPEC §6 `(-> Pipeline Config (List Str expert-ids))` (which calls `expert-slot eid`) | **RESOLVED — slots-needed direct** (`(-> Config (List Str) BindResult)`) | The element brief mandates it: "make `bind-config` take the slots-needed directly … extracting slots-from-fired-experts is E138's job." The Expert pool (E140) is not built (LEDGER confirms E140 unbuilt), so E135 *cannot* map expert → slot. E138 (the runner) reads each fired Expert's `slot` field and passes the deduped list here. Named home exists (E138 runner, E140 pool — both cataloged); not a phantom defer. Documented deviation from §6. |
| 2 | All-or-nothing vs partial binding (bind what's present, report the rest) | **RESOLVED — all-or-nothing** | METIS-PORT-SPEC §6's own code short-circuits to `bind-miss` on any missing slot (the `(cons _ _) → bind-miss` branch). A run can't fire an agent with no backend, so a partial bind has no consumer yet. A partial shape is a later-runner knob, not load-bearing for E135. |
| 3 | Dependent `Config (covers S)` coverage proof (compile-time coverage) | **DEFERRED → E143** | METIS-PORT-SPEC §6 explicitly names this as the *target* beyond the honest first cut ("The sum type above is the honest-first approach. The target is a dependent type"). E143 is cataloged (LEDGER confirms). The `BindResult` sum is the Wave-1 form E135 builds; not a phantom defer. |
| 4 | Which combinator builds the resolved-bindings list (METIS-PORT-SPEC §6 uses `map-list`) | **RESOLVED — `foldl`+`append`** | Established at BUILD by E134 (E134-SPEC decision #4): on this branch (e106) `map-list` does not lower in an isolated leaf blob (B1 skips its label → `no emitted label for entry compile-main`), while `find`/`filter`/`foldl`/`append` lower and run. Semantically identical (a left fold over the needed slots accumulating a `(List Binding)`), so the bind contract is unchanged; only the internal combinator differs. Documented in `bind.chiral`. |

No NEEDS-AUTHOR blocks §4 — all four resolve from the element brief / METIS-PORT-SPEC §6 / a settled E134 build-time finding.

## 4. Change plan (ordered, commit-sized)

### Step 1 — write `scaffold/lib/manas/core/bind.chiral`
- **Target:** `scaffold/lib/manas/core/bind.chiral` (NEW; the `manas/core/` path
  already exists from E133/E134).
- **Change:** the example §5 snippet essentially verbatim —
  `(import "prelude")` / `(import "collections")` / `(import "manas/core/types")`,
  then:
  1. `binding-slot (-> Binding Str)` — `(case b ((binding s m n) s))` (the slot key).
  2. `lookup-binding (-> (List Binding) Str (Maybe Binding))` — `find` over the
     bind list, predicate `(str-eq (binding-slot b) slot)`.
  3. `slot-missing? (-> (List Binding) Str Bool)` — `(case (lookup-binding …)
     (none true) ((some b) false))`.
  4. `bind-config (-> Config (List Str) BindResult)` — `(case config ((config cid
     binds) …))`; `filter` the needed slots by `slot-missing?` → `missing`; if
     `missing` is `(cons …)` return `(bind-miss missing cid)`, else `(bind-ok …)`
     with the bindings accumulated by `(foldl Str (List Binding) …)` that looks each
     slot up (`(some b) → (append Binding acc (cons b nil))`; `(none acc)` — the
     unreachable arm — preserves the accumulator).
  Every arrow `->`; no `=>`; every `case` exhaustive (`Maybe` none/some, `Config`
  single ctor, `missing` nil/cons); no float (`num-ctx` is I64, untouched here).
- **Size:** ~S. One commit (with the test entry, Step 2).

### Step 2 — the behavioral test entry
- **Target:** `scaffold/tests/samples/e135_bind.chiral` (kept, per the brief, so it
  can become an E141-era harness case).
- **Change:** `(import "prelude")` + `(import "manas/core/bind")` +
  `(import "collections")` (for `find`), local helpers `binding-model`, `model-for`
  (find a slot's bound model in a `(List Binding)`, `""` if absent), `len-binds`
  (list length), `mem-str` (id ∈ `(List Str)`), and
  `(def compile-main (=> I64 I64) …)` that builds three `Config` values inline and
  binds the slot set `{cheap-verifier, reasoner, combiner}`:
  - **smoke-local** — all three → `qwen2.5:0.5b` (num_ctx 8192/16384/16384) →
    assert `bind-ok` with 3 bindings, each model `"qwen2.5:0.5b"`.
  - **cheap-local** — cheap-verifier→`qwen2.5:0.5b`, reasoner/combiner→`qwen3:8b`,
    SAME slot set → assert `bind-ok`, reasoner's model `"qwen3:8b"` (the swappable
    backend property — same pipeline, different mix).
  - **verifier-only** — binds only cheap-verifier; ask for `{combiner}` → assert
    `bind-miss` carrying `"combiner"`.
  Exit `0` iff all three assertions hold, else `1`. Exit-code test (no `print`), so
  no linkage libs beyond `manas/core/bind`.
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** reproduce the config-swap property from
  `/workspace/manas/orchestration/configs.md`: binding `{cheap-verifier, reasoner,
  combiner}` under `smoke-local` resolves all three to `qwen2.5:0.5b`; the SAME slot
  set under `cheap-local` resolves reasoner/combiner to `qwen3:8b` (same pipeline,
  different backend mix, unchanged); asking for a slot a config does not bind
  returns `bind-miss` carrying that slot. The purity property is structural (the
  `->` arrow is compiler-checked — a `=>` call in `bind-config` would not type).
- **Tests to add:** `scaffold/tests/samples/e135_bind.chiral` — the `compile-main`
  entry above, driven through `resolve → B1 → run` (native floor). Three asserted
  cases (smoke-local ok / cheap-local swap / verifier-only miss), process exit `0`
  on all-pass. This is the behavioral test; it becomes an E141-era harness case.
- **Green line:** 709 → 709 python test-functions (the new bind test is a native
  sample driven by the B1/resolve recipe, not a pytest); ledger-lint's pre-existing
  fails unchanged.
- **Done when:** a blob importing `manas/core/bind` compiles under B1 to a running
  ELF, and `e135_bind.chiral` runs to exit `0` with all three assertions holding.

## 6. Residue & links

- **Deliberately unbuilt:** expert→slot extraction from fired-expert-ids → **E138**
  (the runner; needs the Expert pool **E140**); dependent `Config (covers S)`
  coverage proof → **E143** (METIS-PORT-SPEC §6 target); partial
  `bind-ok`-plus-missing binding → a later-runner knob (all-or-nothing here);
  preflight model-availability / trust-boundary (`PreflightResult`) → a later
  element; the model call `call-expert` → **Wave 3** (METIS-PORT-SPEC §11).
- **Follow-on this unblocks:** E138 (the runner extracts the deduped slot list from
  fired experts, then calls `bind-config`); the Wave-3 pipeline (which binds the
  fired agents' slots before firing them).
- **Related:** [[E135-bind]] · [[E133-manas-core-types]] (`Binding`/`Config`/
  `BindResult` — imported) · [[E134-gate]] (`run-gate` decides *who* fires; E135
  binds the fired agents' slots) · [[E138-runner]] · [[E143]] (`Config (covers S)`).
