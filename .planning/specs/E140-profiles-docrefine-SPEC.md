---
element: E140
slug: profiles-docrefine
title: **Profiles + doc-refine pipeline as typed values — "add backends and test em"** (Wave 5): the four Config profiles (`cheap-local`, `quality`, `quality-local`, `smoke-local`) and the `doc-refine` Pipeline (its GATE rules, agent pool, combiner, STOP) as **typed chirality values**, not `.md` prose — the swappable-backend payload the config-binding seam (E135) consumes. `smoke-local` (every slot → the one resident `qwen2.5:0.5b`) is the guaranteed-runnable proof profile. `scaffold/lib/manas/profile/{profiles,doc-refine}.chiral`
kind: BUILD
example: examples/E140-profiles-docrefine.md
status: audited
updated: 2026-08-15
---

# E140 SPEC — **Profiles + doc-refine pipeline as typed values — "add backends and test em"** (Wave 5): the four Config profiles + the `doc-refine` Pipeline as typed chirality values. `scaffold/lib/manas/profile/{profiles,doc-refine}.chiral`

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** two NEW pure-`->` data modules exist —
  `scaffold/lib/manas/profile/profiles.chiral` (the four `Config` VALUES
  `smoke-local-config`/`cheap-local-config`/`quality-local-config`/`quality-config`,
  the `all-profiles` list, `config-id`, and `profile-by-id`) and
  `scaffold/lib/manas/profile/doc-refine.chiral` (the 7 `Expert` VALUES, the
  `expert-pool` list, the `doc-refine-gate` `(List GateRule)`, the
  `doc-refine-pipeline` `Pipeline` value, and the accessors/lookups `expert-id`,
  `expert-slot-of`, `expert-by-id`, `pipeline-gate`) — plus an integration test
  `scaffold/tests/samples/e140_profiles.chiral` that drives the real payload
  through E134 gate + E135 bind + E136 match and exits 0 iff all assertions hold.
- **Non-goals:** the fired-ids→slots runner DFS (E138); the manifest JSON
  (de)serialize (E141); the dependent `Config (covers S)` coverage proof (E143);
  any other pipeline template (bug-fix/review/reconcile/…) — doc-refine only;
  any `=>` crossing (both files are pure data).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E140 postdates the CONFORMANCE-MAP snapshot;
  treated as BUILD (a designed-but-unbuilt payload). E138/E141/E143 are cataloged
  homes for the residue (verified in `.planning/SELF-IMPLEMENT-CATALOG.md`).
- **Live code this composes with (do NOT respec):**
  - `scaffold/lib/manas/core/types.chiral` (E133) — `Config`/`Binding`,
    `Pipeline` (`pipeline id when gate order expert-ids combiner stop yield-desc`),
    `Expert` (`expert id lens sees returns slot tools`), `GateRule`
    (`gate-rule condition expert-ids`), `Order` (`order-fan-out`/`-chain`/`-branch`),
    `StopPolicy` (`stop-single`/`stop-capped`/`stop-until-dry`). Imported, never
    redefined. E133 defines NO accessors.
  - `scaffold/lib/manas/core/gate.chiral` (E134) — `run-gate`, `condition-fires`
    (substring-matches `code`/`path`, `spec`/`req`, `sibling`, `example`;
    gate.chiral:67-78).
  - `scaffold/lib/manas/core/bind.chiral` (E135) — `bind-config : (-> Config
    (List Str) BindResult)`, `binding-slot`, `lookup-binding`.
  - `scaffold/lib/manas/core/match.chiral` (E136) — `match-pipeline`, `pipeline-id`,
    `pipeline-when`, local `str-contains`.
  - `scaffold/lib/collections.chiral` — `find`, `filter`, `foldl`, `append`.
  - Precedent for top-level constructor-value defs: `lib/tal-spec.chiral:118,125`
    (`(def spec-byte-zero SpecEntry (spec-entry …))`, `(def tal-spec (List SpecEntry)
    (cons …))`) and `lib/climb.chiral:42`. Confirms `(def name Type <ctor-value>)`.
- **True delta:** the two data modules + their `find`/single-ctor accessors + the
  integration test. No change to any existing file.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | `stop-until-dry` numeric cap (prose gives none) | RESOLVED | chirality totality forbids an unbounded loop, so `StopPolicy.stop-until-dry` requires an I64 cap (types.chiral:60). Take `(stop-until-dry 8)` — a finite honest cap; a runner may tune it. Not a novel design call, a required field with a chosen default. |
| 2 | Pipeline STOP is per-agent-class in prose (audit single-pass; sharpen/example loop-until-dry) but `Pipeline.stop` is ONE `StopPolicy` | RESOLVED | The built E133 `Pipeline` is a flat record with ONE `StopPolicy` field (types.chiral:82-89) — per-agent-class STOP is simply not expressible in it, an already-documented Wave-1 simplification (types.chiral:77-89: "Wave 1 is this flat data record"; the richer typed-I/O Pipeline is named as the future TARGET, not a minted work item). E140 stores the pipeline-level STOP that IS expressible: `stop-until-dry` (the loop dominates the single-pass audits). This is not a deferred E140 work item — it is a property of the E133 type E140 consumes; no phantom defer. |
| 3 | `gate-rule` conditions must carry E134's substring keywords | RESOLVED | Conditions authored as "cites code/paths?", "maps to a spec/reqs?", "coupled to sibling docs?", "carries examples?" — each contains the literal token `condition-fires` scans (gate.chiral:70-77: `code`/`path`, `spec`/`req`, `sibling`, `example`). Verified against E134. |
| 4 | Accumulation idiom (`map-list` vs `foldl`/`find`) | RESOLVED | Branch e106: `map-list` does not lower in an isolated leaf blob (E134/E135/E136 finding). E140 uses only `find` (lookups) + literal `cons` chains (the values) — no `map-list`. |
| 5 | `agents.md` slot assignment for the 7 doc-refine agents | RESOLVED | Transcribed verbatim from `agents.md`: `claim-vs-source`→`cheap-verifier`; `coverage-vs-spec`/`cross-doc-drift`/`anchor-sharpen`/`example-completeness`/`example-organization`→`reasoner`; `curate-merge`→`combiner`. No ambiguity in the source. |

No NEEDS-AUTHOR blocks §4. Decision #2's residue has a named home; proceed.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `scaffold/lib/manas/profile/profiles.chiral` (the four Config values)
- **Target:** NEW file — `config-id`, `smoke-local-config`, `cheap-local-config`,
  `quality-local-config`, `quality-config`, `all-profiles`, `profile-by-id`.
- **Change:** copy example §5 `profiles.chiral` verbatim. Imports `prelude`,
  `collections`, `manas/core/types`. Models/num-ctx from `configs.md` (Decision #5
  sources). `profile-by-id` via `find` over `config-id`.
- **Size:** S.

### Step 2 — `scaffold/lib/manas/profile/doc-refine.chiral` (pipeline + pool)
- **Target:** NEW file — `expert-id`, `expert-slot-of`, `pipeline-gate`, the 7
  `Expert` values (fully written, not elided), `expert-pool`, `expert-by-id`,
  `doc-refine-gate`, `doc-refine-pipeline`.
- **Change:** copy example §5 `doc-refine.chiral`, EXPANDING the 6 elided experts
  (`coverage-vs-spec`, `cross-doc-drift`, `anchor-sharpen`, `example-completeness`,
  `example-organization`, `curate-merge`) to full `(expert id lens sees returns
  slot tools)` values with fields from `agents.md` (LENS/SEES/RETURNS/SLOT/TOOLS).
  GATE conditions carry E134's keywords (Decision #3); `stop-until-dry 8`
  (Decision #1); `order-fan-out`; combiner `"curate-merge"`.
- **Size:** M.

### Step 3 — `scaffold/tests/samples/e140_profiles.chiral` (integration test)
- **Target:** NEW exit-code test (no print → no linkage, like `e135_bind.chiral`).
- **Change:** entry `compile-main : (=> I64 I64)`. Assert (a) `match-pipeline`
  a doc-refine-ish request over `(cons doc-refine-pipeline nil)` → `match-found`
  doc-refine; (b) `run-gate (pipeline-gate doc-refine-pipeline)` over a doc with a
  fenced ```` ``` ```` block + a `/`-path + a `"spec"` extra-input → `gate-fired`,
  ids ⊇ {claim-vs-source, anchor-sharpen, coverage-vs-spec}; (c) map those fired
  ids → slots via `expert-by-id expert-pool` + `expert-slot-of`, dedup, then
  `bind-config smoke-local-config <slots>` → `bind-ok` AND `bind-config
  cheap-local-config <slots>` → `bind-ok` with the reasoner binding's model
  `"qwen3:8b"`. Exit 0 iff all hold, else 1. Local helpers: fired-ids→slots fold
  (dedup via a `mem`/`elem-str`-style scan), `binding-model`/`model-for`.
- **Size:** M.

### Step 4 — B1 compile + run + INDEX patch
- Resolve the leaf blob (`chirality_blob scaffold/lib manas/profile/profiles
  manas/profile/doc-refine manas/core/gate manas/core/bind manas/core/match`),
  strip test imports, append, `B1 < blob`, run, iterate to exit 0. Patch the INDEX
  E140 row to `implemented`. NOTE: gate+match both define `str-contains` in one
  blob — verify the resolver/compiler tolerates the identical redefinition; if
  not, the test's needs decide the minimal module set.
- **Size:** S.

## 5. Conformance gate

- **Golden behavior:** the real `orchestration/*.md` payload, as typed values,
  routes + gates + binds correctly through the pure core. `smoke-local` binds every
  fired slot to `qwen2.5:0.5b`; `cheap-local` binds the reasoner slot to `qwen3:8b`
  from the SAME fired-slot set (the swappable-backend property); doc-refine's GATE
  fires the code/path + spec rules on a code+path+spec doc.
- **Tests to add:** `scaffold/tests/samples/e140_profiles.chiral` (the integration
  test above) — compares the chirality values against the golden `.md` payload via the
  three assertions. B1 is the single floor (native compile+run, exit code).
- **Green line:** 709 test functions baseline → the sample is a B1 exit-code gate
  (not a pytest); ledger-lint clean; INDEX row → `implemented`.
- **Done when:** `B1 < blob` exits 0 producing an ELF that exits 0, and flipping
  any asserted model/id would flip the exit to 1 (negative-control sanity).

## 6. Residue & links

- **Deliberately unbuilt:**
  - fired-expert-ids → deduped-slots runner DFS — home **E138** (the run loop).
  - per-agent-class STOP (Decision #2) — NOT deferred work; a documented shape
    limit of the built E133 flat `Pipeline` (types.chiral:77-89). The richer
    typed-I/O Pipeline is a named future TARGET, not a minted element.
  - manifest (de)serialize/conformance — home **E141**.
  - dependent `Config (covers S)` compile-time coverage proof — home **E143**.
  - other pipeline templates (bug-fix/review/reconcile/cover/map/research/design/
    migrate) — future ORCH elements; E140 is doc-refine only.
- **Follow-on:** E138 (consumes `expert-by-id`/`expert-slot-of`/`profile-by-id`);
  E141 (tests full manifests over these values).
- **Related:** [[E140-profiles-docrefine]] · [[E133-manas-core-types]] ·
  [[E134-gate]] · [[E135-bind]] · [[E136-match]] · [[E138-runner]].
