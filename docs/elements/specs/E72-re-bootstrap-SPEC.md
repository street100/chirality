---
element: E72
slug: re-bootstrap
title: Re-bootstrap artifact: the shipped form contains its own re-derivation — kernel-spec + a reference semantics simple enough to reimplement in a weekend in any language, + DDC (E53) to verify the climb; no trusted binary in the forever-story. Couples E71 (spec-as-golden) and the E52 spec-size budget
kind: BUILD-PROPER
example: examples/E72-re-bootstrap.md
status: audited
updated: 2026-08-02
---

# E72 SPEC — Re-bootstrap artifact (the climb as a checkable manifest)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> **Position (the cluster capstone).** E72 consumes E69+E70 (the native
> compiler), E71 (spec-as-golden), E52 (spec-size budget), E53 (DDC). Its
> *manifest artifact* is writable now; its *end-to-end verification* (the climb
> running, the fixpoint) lights up only as those gates clear. This SPEC scopes
> the two apart honestly — it does not pretend the climb runs today.

## 1. Deliverable

- **After this runs (buildable NOW):**
  1. `lib/climb.chiral` (NEW) — the **checkable manifest** as data (example §5):
     `ShipItem` (what ships: prose / source / preserve-checked tal / gen-refs),
     `Stage` (the climb steps 0–4, each with what it does + what checks it),
     `Breaker` (the chain-breakers, each pinned to a named obligation). Total,
     pure, loads clean — the shape a future `chirality climb --verify` consumes.
  2. `docs/definitions/bootstrap.md` (NEW) — the human-facing climb instructions (the manifest in
     prose): from "any Linux box + any language" back to native self-checked
     chirality, no trusted binary anywhere.
  3. The **ship-list** definition — which artifacts the packaged form carries
     (spec + upper source + preserve-checked tal + ref-bank scripts + this
     manifest).
- **Non-goals (gated — named, not hidden):** the climb *actually running*
  end-to-end (stage 2's checked-chirality-checker + stage 3's native fixpoint need
  E69+E70; stage 1 needs E71's tal-spec + vectors; stage 4 needs E53 leg-running
  — all tracked in §3/§6); the `chirality climb` *tooling*; the weekend-bound as a
  *measured* claim (needs a real run — §3 #2); non-Linux climbs (the sys-face
  crossings are Linux-shaped today); E52's spec-size budget enforcement.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the DDC row (E53, BUILT 2026-07-28) — the compare
  core `lib/ddc.chiral` + driver `scaffold/tests/ddc.py` exist; **but** "true Stage1==Stage2
  fixpoint + leg-running are E70-gated" and "D-1/D-2 determinism debts remain
  pre-port gates." So E72's stage-3 fixpoint and stage-4 DDC *compare* have their
  machinery (E53) but cannot *run the full climb* until the gates clear. No E72
  row (postdates snapshot) — **BUILD**.
- **Live code this composes with (do NOT respec):**
  - `lib/ddc.chiral` / `scaffold/tests/ddc.py` (E53) — stage 4's Wheeler compare; the
    weekend leg IS the provenance-disjoint compiler DDC needs (one machinery).
  - `lib/tal-spec.chiral` + `docs/tal-spec.md` (E71) — stage 1 reimplements the
    tal executor + checker from *this* prose; the golden object the climb
    validates against. (Provisional per E71; E72 proceeds against it.)
  - The native compiler (E69+E70) — stage 3 runs it to go native + regenerate
    the shipped tal (the fixpoint).
  - `examples/refs/` + `gen-*.py` — stage 0's locally-re-derived ABI facts (no
    unexplained constants); the ownership-story precedent already in the tree.
  - `.planning/SELF-HOST-PLAN.md` — ownership requirements 1–2 (the spec this
    makes checkable).
- **True delta:** the two new files (`lib/climb.chiral`, `docs/definitions/bootstrap.md`) + the
  ship-list. The manifest *describes* a climb whose stages are built by other
  elements; E72 owns the description + its checkability, not the stages.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | What form the checker/compiler ship in for stage 2 — preserve-checked tal, or a minimal spec'd upper evaluator? | **RESOLVED: ship preserve-checked tal ("no unverifiable artifact").** | The shipped tal is present but independently checkable (the weekend implementer's spec'd tal checker verifies it before running; stage 3's fixpoint re-derives it). This sharpens "no trusted binary" into "no *unverifiable* artifact." A minimal spec'd upper evaluator (making even the shipped tal optional) is DEFERRED → the E52 spec-size budget decides whether it earns its cost. |
| 2 | The weekend bound as a measured claim. | **DEFERRED: target-note, not an estimate.** | Someone must actually run the climb and clock it once the gates clear; recorded as a target-note requirement, not asserted now. |
| 3 | How the chain versions when the spec grows. | **RESOLVED (revisitable): fixpoint against the previous release's artifacts, with a periodic full re-climb.** | Same fixpoint machinery, cheaper per-release; a full re-climb is the periodic deep check. Revisitable when release cadence is real. |
| 4 | E71 spec-as-golden ratification (E72's precondition). | **PROCEED against provisional (not gated).** | Per the author call, E72 proceeds against provisional spec-as-golden — it is "unbuildable without it," so E72 running *is* the strongest argument for ratifying, but the manifest is writable against the provisional spec now. |

No NEEDS-AUTHOR blockers. The blockers are *build-order gates* (E69/E70/E71/E52/
E53 + determinism debts), tracked in §6 — not decisions.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `lib/climb.chiral`: the manifest data
- **Target:** `lib/climb.chiral` (NEW).
- **Change:** `ShipItem` / `Stage` / `Breaker` sums + the `climb` (stages 0–4)
  and `breakers` lists from example §5, each stage naming what checks it (spec or
  prior-stage output, never a shipped binary). Total, pure, loads clean.
- **Size:** ~M.

### Step 2 — `docs/definitions/bootstrap.md`: the prose climb
- **Target:** `docs/definitions/bootstrap.md` (NEW, repo root).
- **Change:** the human-facing instructions — the five stages in prose, the two
  trust roots (audited prose + the human reading it), the ref-bank re-derivation
  step. Points at `docs/tal-spec.md` (E71) as the weekend-leg source.
- **Size:** ~M.

### Step 3 — the ship-list
- **Target:** a manifest of shipped artifacts (a `climb.chiral` value or a
  packaging list) wired into whatever packaging stage the roadmap ends with.
- **Change:** enumerate what ships (spec + source + preserve-checked tal +
  gen-refs + this manifest); a `climb --verify`-shaped consumer is a follow-on.
- **Size:** ~S.

### Step 4 — (gated integration, NOT this commit) the running climb
- **Target:** the end-to-end climb test.
- **Change:** a fresh-party stages-1–4 run with every check passing + a
  corrupted-shipped-tal caught at stage 2. **Gated on E69+E70+E71+E53** and the
  determinism debts; lands when they clear. Named here so the manifest is not
  mistaken for a running climb.
- **Size:** ~L (deferred).

## 5. Conformance gate

- **Golden behavior (now):** `lib/climb.chiral` loads, is total/pure, and its
  manifest faithfully enumerates the stages + breakers (each breaker pinned to a
  real obligation on a named element). `docs/definitions/bootstrap.md` prose matches the manifest
  data.
- **Golden behavior (the ownership claim, gated):** a fresh party with no chirality
  binary completes stages 1–4 and every check passes; a deliberately-corrupted
  shipped-tal (one instruction changed) is **caught at stage 2** by the
  independently-implemented tal checker — the negative test IS the ownership
  claim. Lands when the cluster gates clear (§6).
- **Tests to add (`scaffold/tests/test_climb.py`, NEW):**
  1. **Load + totality:** `lib/climb.chiral` elaborates; `climb`/`breakers` total.
  2. **Manifest ↔ prose:** the stages/breakers in the data match `docs/definitions/bootstrap.md`
     (a structural check that the two forms agree).
  3. **Breaker coverage:** every `Breaker` names an element/obligation that
     exists in the plan (no dangling pin).
- **Green line:** 407 → **≥ 410** (the post-E69/E71 baseline; the spec's original
  390 predates E69's closure/q0 tests and E71's tal-spec tests); `ledger-lint`
  clean.
- **Done when:** the manifest + prose ship and agree, every breaker is pinned to
  a real obligation, and the running-climb integration test is scoped + gated
  (Step 4) with its gates named.
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

## 6. Residue & links

- **Build-order gates (the climb runs when these clear — not decisions, order):**
  - stage 2 (checked chirality checker over the source) + stage 3 (native fixpoint):
    **E69 + E70** (the native compiler).
  - stage 1 (weekend leg from prose) + the golden object: **E71** (tal-spec +
    vectors, provisional).
  - the determinism debts (D-1 repr, D-2 ordering/encoding): **pre-port gates**
    — the fixpoint cannot bit-agree until paid.
  - stage 4 (DDC compare, leg-running): **E53** tooling extended to full legs.
  - the "weekend" size constraint: **E52** spec-size budget.
- **Deliberately unbuilt:** the `chirality climb --verify` tooling; the measured
  weekend-bound (§3 #2); non-Linux climbs; the minimal upper-evaluator
  alternative (§3 #1, E52-budget-gated).
- **Follow-on / links:** [[E71-golden-restructure]] (the spec this consumes —
  its provisional adoption is E72's working precondition), [[E69-closure-conversion]]
  / [[E70-effectful-lowering]] (the native compiler stage 3 needs), [[E53]] (DDC
  — one machinery), [[E52]] (spec-size budget), [[E18-tal-check]] /
  [[E15-reference-interpreter]] (what stage 1 reimplements from prose),
  [[E34-elf-writer]] (stage 3's native artifact), `examples/refs/README.md` (the
  ABI-fact re-derivation discipline), `.planning/SELF-HOST-PLAN.md` (ownership
  requirements 1–2).
