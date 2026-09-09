---
element: E141
slug: golden-conformance
title: "golden-manifest conformance"
kind: BUILD
example: examples/E141-golden-conformance.md
status: audited
updated: 2026-08-15
---

# E141 SPEC — golden-manifest conformance

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** two new pure `->` modules exist —
  `scaffold/lib/manas/contract/manifest.chiral`
  (`manifest-from-json : (-> Json (Maybe RunManifest))` + the RunManifest/
  ExpertCall accessors the oracle needs) and
  `scaffold/lib/manas/contract/golden.chiral`
  (`manifest-conforms : (-> RunManifest RunManifest Bool)` + the list-compare
  helpers) — plus a behavioral test `scaffold/tests/samples/e141_conformance.chiral`
  that reads the REAL golden `3dde…-manifest.json`, deserializes it, checks the
  extracted fields, and exercises `manifest-conforms` (self / mutated / ignored).
- **Non-goals:** running a LIVE pipeline to produce the `actual` manifest (E138's
  `run-pipeline` shell is not wired to real models — the "actual" here is a
  synthetic in-test manifest); serializing a RunManifest back to JSON
  (`manifest-to-json`, not needed for the oracle); a richer `Patch` type for
  `combiner_patches` (stays `(List Str)`). See §6.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** BUILD (E141 postdates the map snapshot; the row is
  "Not built — no manifest (de)serialize/compare in chirality"). No CONFORMS/EXTEND
  row to honor — this is greenfield over already-built dependencies.
- **Live code this composes with (do NOT respec):**
  - `scaffold/lib/manas/core/types.chiral` (E133) — `RunManifest` (15 fields),
    `ExpertCall` (9 fields), `Binding` (`binding slot model num-ctx`). Imported,
    never redefined.
  - `scaffold/lib/json.chiral` — `Json`, `obj-get : (-> Json Str (Maybe Json))`,
    `as-str`/`as-int`/`as-bool`/`as-arr`, `json-parse : (-> Bytes (Maybe Json))`.
  - `scaffold/lib/collections.chiral` — not strictly needed by the two modules
    (the folds are hand-written structural recursion), pulled in by the test for
    nothing extra; `map-list` is BANNED (does not lower in a leaf blob — E134/E135
    finding), so all list-building uses `cons`/explicit recursion.
  - `scaffold/lib/ports.chiral` — `open-rw`/`read`/`adopt-fd`/`fd-close` for the
    test's file read (verified: B1 has native bindings, the golden is readable,
    no `sys-linkage` needed).
- **True delta:** the deserializer (field-dig over `Json` → `Maybe RunManifest`),
  the accessors, the structural comparator, and the test. Zero new types.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Which fields are STRUCTURAL (compared) vs IGNORED (non-deterministic)? | RESOLVED | METIS-PORT-SPEC §8 ("compare structure, not responses") + the golden shape. **STRUCTURAL:** top-level `pipeline-id`, `config-id`, `routing-decision`, `fired-expert-ids`; per-`ExpertCall` `expert-id`, `slot`, `bound-model` (compared pairwise, length included). **IGNORED:** `run-id`, `request`, `doc-path`, `artifact-path`, `pipeline-choice`, `config-binds`, `context-chunks-used`, `combiner-patches`, `final-yield`, `generated-at`; per-call `num-ctx`, `prompt-sha256`, `response-sha256`, `parsed-ok`, `accepted-into-merge`, `duration-ms`. Rationale: shas/duration/yield-text are model-nondeterministic; `num-ctx` is deterministic-from-config but SPEC §8's stable list omits it, so it stays IGNORED (a `num-ctx`-inclusive variant is one line if a caller wants it — knob in the example §5). |
| 2 | Test reads the real golden file, or embeds a mini JSON literal? | RESOLVED — read the real golden | Verified empirically: `open-rw`/`read`/`fd-close` (ports.chiral) compile under B1 and read `/workspace/manas/orchestrator/golden/3dde…-manifest.json` (a >1KB real file) with exit 0, no `sys-linkage`. Reading the real golden is the stronger test (proves `manifest-from-json` extracts the ACTUAL golden shape, not a hand-tuned mini). The test is therefore effectful (`=>`); the two contract modules stay pure `->`. |
| 3 | `manifest-from-json` takes `Json` or `Bytes`? | RESOLVED — `(-> Json (Maybe RunManifest))` | The catalog row sketched `Bytes`; keeping `json-parse` in `json.chiral` (caller does `json-parse` then `manifest-from-json`) keeps the parse boundary in one place and `manifest.chiral` byte-scan-free. A `Bytes` one-shot wrapper is trivial residue (§6) if wanted. |
| 4 | `config_binds` deserialize order / how the JSON object maps to `(List Binding)`? | RESOLVED | `json.chiral`'s parser preserves object insertion order (alist); each `(slot -> {model,num_ctx})` field folds to a `(binding slot model num-ctx)` in that order. Order is irrelevant to conformance (decision #1: `config-binds` is IGNORED), so no canonical-ordering obligation. |

No NEEDS-AUTHOR — every question is derivable from SPEC §8 + the golden + a verified build probe.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `prapanca/contract/manifest.chiral` (deserialize + accessors)
- **Target:** new file `scaffold/lib/manas/contract/manifest.chiral`
- **Change:** import `prelude` / `json` / `prapanca/core/types`. Define:
  - typed field-diggers `og-str`/`og-int`/`og-bool`/`og-arr` (`obj-get` + `as-*`);
  - `js-str-list`/`js-int-list : (List Json) -> (Maybe (List X))` (structural
    recursion; any mistyped element → `none`);
  - `ec-from-json : (-> Json (Maybe ExpertCall))` (9 fields, ctor order) and
    `ec-list-from-json : (-> (List Json) (Maybe (List ExpertCall)))`;
  - `binding-from-field : (-> (Pair Str Json) (Maybe Binding))`,
    `binds-from-fields`, `binds-from-json : (-> Json (Maybe (List Binding)))`;
  - `manifest-from-json : (-> Json (Maybe RunManifest))` — the 15-field spine,
    each field a `(case (dig …) (none none) ((some x) …))` nesting, closing with
    the `run-manifest` constructor in the E133 field order;
  - the accessors the oracle + test read: `manifest-pipeline-id`,
    `manifest-config-id`, `manifest-routing-decision`, `manifest-fired-expert-ids`,
    `manifest-expert-calls` (RunManifest); `ec-expert-id`, `ec-slot`,
    `ec-bound-model` (ExpertCall). Defined ONCE here, imported elsewhere.
  - All pure `->`. No float. Exhaustive `case`.
- **Size:** M

### Step 2 — `prapanca/contract/golden.chiral` (structural conformance)
- **Target:** new file `scaffold/lib/manas/contract/golden.chiral`
- **Change:** import `prelude` / `prapanca/core/types` / `prapanca/contract/manifest`
  (for the accessors). Define `str-list-eq`, `ec-struct-eq`, `ec-list-match`
  (pairwise, length-checked), and `manifest-conforms : (-> RunManifest RunManifest
  Bool)` comparing exactly the decision-#1 STRUCTURAL set. Pure `->`.
- **Size:** S

### Step 3 — `e141_conformance.chiral` behavioral test
- **Target:** new file `scaffold/tests/samples/e141_conformance.chiral`
- **Change:** `compile-main : (=> I64 I64)`. Inline file-read helpers over
  `ports` (uniquely named, no collision). Read the real golden → `json-parse` →
  `manifest-from-json`. Assert: `some`; `pipeline-id`="doc-refine";
  `config-id`="smoke-local"; `fired-expert-ids` length 2; `expert-calls` length 5;
  first call `expert-id`="claim-vs-source" / `slot`="cheap-verifier". Then, over
  synthetic manifests (built via test-local `mk`/`mkec` helpers): `conforms m m`
  = true; mutated `config-id` = false; mutated expert `slot` = false; a manifest
  differing ONLY in IGNORED fields (run-id/request/pipeline-choice/patches/
  final-yield/generated-at + per-call prompt-sha/duration) = true. Exit 0 iff all
  hold, else 1.
- **Build recipe:** `chirality_blob scaffold/lib ports json collections prapanca/core/types
  prapanca/contract/manifest prapanca/contract/golden > blob`, append the test source,
  `B1 < blob > elf`, run. (ports for the file read — verified sufficient.)
- **Size:** M

## 5. Conformance gate

- **Golden behavior:** `manifest-from-json (json-parse <golden bytes>)` yields
  `(some RunManifest)` whose stable fields equal the golden's; `manifest-conforms`
  is reflexive (`m m` → true), discriminates on any STRUCTURAL field (mutation →
  false), and is invariant under any IGNORED field (difference → true).
- **Tests to add:** `scaffold/tests/samples/e141_conformance.chiral` — native
  floor (B1 compile + run, exit-code oracle), with negative controls that flip to
  exit 1 when the discrimination is broken.
- **Green line:** the two modules compile under B1 (self-contained leaf blob) and
  the test ELF exits 0; ledger-lint clean.
- **Done when:** `B1 < blob > elf` exits 0 and the test ELF exits 0, reading the
  real golden and passing every assertion + negative control.

## 6. Residue & links

- **Deliberately unbuilt:** `manifest-to-json` (serialize back — the oracle only
  reads); a `Bytes` one-shot `manifest-from-json'` wrapper (decision #3; nobody's
  yet); a richer `Patch` type for `combiner_patches` (E133 §6 residue); wiring a
  LIVE `run-pipeline` (E138) to produce the `actual` manifest from real models
  (deferred to manas integration — the "actual" here is synthetic).
- **Follow-on:** unblocks the golden-driven integration test once E138's runner
  drives real backends (the `actual` manifest becomes a live run's output).
- **Related:** [[E141-golden-conformance]], [[E133-manas-core-types]],
  [[E140-profiles-docrefine]], [[E138-run-loop]].
