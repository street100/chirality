---
element: E133
slug: manas-core-types
title: **manas core types** (Wave 1): the pure data model the whole engine is typed against — `GateRule`, `GateDecision` (`gate-fired`/`gate-no-match`), `Binding`, `BindResult` (`bind-ok`/`bind-miss`), `Config`, `Pipeline`, `Expert`, `Finding`, `ExpertCall`, `ExpertOutcome`, `CombinerOutcome`, `PipelineMatch`, `PreflightResult`, `RunManifest`. Pure `data`, zero logic — every failure path is a variant, not an exception (chirality has none). `scaffold/lib/manas/core/types.chiral`
kind: BUILD
example: examples/E133-manas-core-types.md
status: audited
updated: 2026-08-15
---

# E133 SPEC — **manas core types** (Wave 1): the pure data model the whole engine is typed against — `GateRule`, `GateDecision` (`gate-fired`/`gate-no-match`), `Binding`, `BindResult` (`bind-ok`/`bind-miss`), `Config`, `Pipeline`, `Expert`, `Finding`, `ExpertCall`, `ExpertOutcome`, `CombinerOutcome`, `PipelineMatch`, `PreflightResult`, `RunManifest`. Pure `data`, zero logic — every failure path is a variant, not an exception (chirality has none). `scaffold/lib/manas/core/types.chiral`

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/manas/core/types.chiral` exists — 17 pure `data`
  declarations (the 15 named types + the `Order`/`StopPolicy` boundary sums),
  `(import "prelude")` at the top, **zero logic** (no `def`, no accessor, no
  crossing), and it compiles clean under B1 when pulled into a blob. Every golden
  manifest top-level key and every `expert_calls[]` key has a corresponding field
  on `RunManifest`/`ExpertCall`.
- **Non-goals:** accessors and any function (later elements); the effect membrane
  and linear `Backend` porttype (Wave 3, E137/E138); the JSON deserializer +
  conformance comparator (E141); the dependent-`Pipeline`/zone-token targets
  (E142/E143). Those live in §6.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E133 postdates the map snapshot (bundle §3
  confirms). Treat as **BUILD** (forward construction, nothing to reshape).
- **Live code it composes with:** `prelude` (`I64`, `Str`, `Bool`, `List`, `Pair`,
  `data`) — the only import. It does NOT touch the substrate types (`Turn`/`Outcome`
  in `manas.chiral`, `Backend`/`Msg`/`ChatR`/`Hit` in `backend.chiral`, `Step` in
  `fsm.chiral`); those stay as-is and E138 composes across the seam.
- **True delta:** one new file, 17 `data` decls, no change to any existing file.

## 3. Decisions

| # | Question (example §6) | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Drop `corpus_eligible` (spec §8 had it; absent from both goldens)? | **RESOLVED — drop** | SCHEMA.md names the goldens the normative conformance surface ("reproduce the golden run-manifests … the manifests are the conformance surface") — golden wins over the spec sketch. If a future golden carries it, add the field then. |
| 2 | `Finding` granular shape `(kind target body)` is a guess (goldens record only post-merge findings) | **DEFERRED → E134** | The element that *produces* findings (the GATE's fired agents / `call-expert`) owns the real RETURNS schema; E133 carries a provisional `(kind target body)` so downstream compiles, E134 firms it. Not an author call — future work with a named home. |
| 3 | `combiner-patches` as `(List Str)` opaque lines vs a `Patch` sum | **DEFERRED — knob** | Golden carries opaque unified-diff line strings; `(List Str)` is faithful. A `Patch` sum is a later refinement, not load-bearing for Wave 1. |
| 4 | `Order`/`StopPolicy` embedded in `Pipeline` vs a dedicated element | **RESOLVED — embed as sums** | They ARE `Pipeline`'s ORDER/STOP fields (SCHEMA.md PIPELINE). The boundary-sums directive (`docs/pattern-boundary-sums.md`) forbids `Str` tags for a which-of-N, so both are closed sums on the `Pipeline` record. |

No NEEDS-AUTHOR blocks §4. Q1/Q4 resolve from settled docs; Q2/Q3 are deferred with named homes.

## 4. Change plan (ordered, commit-sized)

### Step 1 — write `scaffold/lib/manas/core/types.chiral`
- **Target:** `scaffold/lib/manas/core/types.chiral` (NEW; create the `manas/core/` path).
- **Change:** the example §5 snippet verbatim — `(import "prelude")` then the 17
  `data` decls (`GateRule`, `GateDecision`, `Binding`, `Config`, `Order`,
  `StopPolicy`, `Expert`, `Finding`, `Pipeline`, `PipelineMatch`, `BindResult`,
  `PreflightResult`, `ExpertOutcome`, `CombinerOutcome`, `ExpertCall`,
  `RunManifest`). Constructors lowercase-hyphenated, types CamelCase, all fields
  `I64`/`Str`/`Bool`/`List`/sibling-data (no floats, no fn-typed fields).
- **Size:** ~S. One commit.

## 5. Conformance gate

- **Golden behavior:** a blob importing `manas/core/types` compiles under B1 to a
  running ELF (the types resolve, no unknown-type / arity error); and the field set
  is complete — every golden top-level key (15) + every `expert_calls[]` key (9)
  maps to a `RunManifest`/`ExpertCall` field. The *populate-from-JSON-loses-no-field*
  property is proven at E141 (the deserializer), not here — E133 only owes the shape.
- **Tests to add:** none behavioral at this stage (pure types have no runtime
  behavior). The gate is a **compile smoke**: a tiny `scaffold/tests/` blob or the
  E141 harness imports `manas/core/types` and B1 accepts it. The real conformance
  test (`manifest-conforms` over the two goldens) lands in E141.
- **Green line:** 709 → 709 (no new behavioral test at the pure-types stage;
  E141 adds the conformance tests); ledger-lint's pre-existing C/F/I fails unchanged.
- **Done when:** `scaffold/lib/manas/core/types.chiral` exists and a B1 compile of a
  blob importing it exits 0.

## 6. Residue & links

- **Deliberately unbuilt:** dependent `Pipeline (covers …)` / typed-I/O per SPEC
  §12.6 → **E143**; zone tokens `LocalZone`/`CloudZone` → **E142** (`PreflightResult`
  is the Wave-1 stand-in, already in this file); real `Finding` RETURNS schema →
  **E134**; `Patch` sum for `combiner-patches` → deferred knob (nobody's yet).
- **Follow-on this unblocks:** E134 (`run-gate` over `GateRule`/`GateDecision`),
  E135 (`bind-config` over `Binding`/`Config`/`BindResult`), E136 (`match-pipeline`
  over `PipelineMatch`), E138 (the runner produces `RunManifest`), E141 (deserialize
  the goldens into `RunManifest`).
- **Related:** [[E133-manas-core-types]] · [[E134-gate]] · [[E135-bind]] · [[E141-golden-conformance]].
