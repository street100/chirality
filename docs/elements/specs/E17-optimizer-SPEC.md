---
element: E17
slug: optimizer
title: Optimizer: const-fold, DCE, specialize/partial-eval/pregen
kind: SELF-HOST
example: examples/E17-optimizer.md
status: audited
updated: 2026-08-01
---

# E17 SPEC — Optimizer: const-fold, DCE, specialize/partial-eval/pregen

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new `scaffold/lib/optimize.chiral` carrying the tal→tal
  **optimizer** in chirality source — `fold` (constant folding), `dead` (DCE), and
  `specialize` (partial evaluation = the pregen primitive), plus the `optimize`
  pipeline — as pure `->` transforms that return a `Checked` result sum
  (`c-ok`/`c-err`) with every pass output run back through `check-fn` (the tal
  preserve-check). Run on the RT interpreter it reproduces
  `scaffold/chirality/optimize.py`'s pass outputs (`fold:184`, `dead:216`,
  `specialize:264`, `optimize:321`) — meaning-preserving, **bit-identical folds**.
- **Non-goals (residue → §6):**
  - **The tal checker it consumes** — `check-fn`/`PR`/`Env` are **E18**'s
    (`tal.py`, not yet self-hosted); the *runnable* re-check differential rides
    E18 (§2 coupling, same as E16). The fold/dead/specialize *transform* logic is
    differentiable now against `optimize.py`.
  - **Any graded-cost claim** — the passes are **meaning-preserving only**; a
    cost-typed account is **E38** (the map row says so explicitly), decision #3.
  - Does **not** delete or wire-in `optimize.py`; it stays the golden oracle.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** `Optimizer: fold/DCE/specialize/pregen | CONFORMS ·
  S · E17 | "Each a tal→tal transform re-run through preserve-check; Built;
  fold/dead/specialize fixpoint, SSA guard, folds bit-identical to runtime.
  Meaning-preserving only, NO graded-cost claim — cost-typed account is E38, not a
  defect here."` CONFORMS ⇒ faithful transcription of a complete artifact.
- **Live code this composes with (do NOT respec):**
  - `scaffold/chirality/optimize.py` — the golden oracle. `fold` (`:184`) over
    `_fold_block` (`:125`)/`_fold_prim` (`:37`); `dead` (`:216`) over
    `_uses_in_block` (`:54`)/`_dead_block` (`:193`); `specialize` (`:264`) over
    `_remap_block` (`:223`) — which calls `tal.check_fn` on its residual; the
    `optimize` pipeline (`:321`); `_check_single_assignment` (`:111`, the SSA
    guard); `_size` (`:333`, the fold worklist measure).
  - **E18's tal checker (consumed, not respec'd):** `tal.py check_fn` (the
    preserve-check) + the `PR` result sum + `Env`. E18 is `drafted` — so the
    chirality passes' `check-fn` calls ride E18's self-host (coupling, decision #4);
    the transform logic is testable against `optimize.py` now.
  - `scaffold/lib/tal-ir.chiral` — the tal **data** the passes rewrite: `TFn`
    (`:48`), `TCode` (`:41`), `TInstr` (`:19`). `scaffold/lib/prelude.chiral` /
    `collections.chiral` — `List`/`Pair`, structural folds, `=i`.
- **True delta = one new library file's optimizer.** The wins over `optimize.py`:
  each pass is a pure `->` transform (an "optimization" that reads a file or
  reorders I/O is untypeable — no ambient `cenv`/`live` mutation), and the
  preserve-check moves **into the signature** — a pass returns `Checked`, so the
  `c-ok` residual cannot be formed without `check-fn` passing; the proof
  obligation is a value the caller must `case` on, not a forgettable call.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled source (cited); DEFERRED to a named
home; genuinely novel design → NEEDS-AUTHOR, surfaced never answered.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does `re-check` after **each pass** or only at the **pipeline end** suffice for the floor's guarantee? | **RESOLVED — end suffices for soundness; per-pass is optional localization (matches OURS)** | The *soundness* guarantee is that shipped tal is checked, so re-checking the final `optimize` output is sufficient — the residual that leaves is judged. OURS matches: `specialize` (`:264`) re-checks its residual and `optimize` (`:321`) checks the pipeline output; `fold`/`dead` are meaning-preserving-by-construction. Per-pass re-check is a *localization* aid (which pass broke it), which the map's "each … re-run through preserve-check" phrasing allows as the stronger option. Not author-tier — derivable from `optimize.py`'s structure. |
| 2 | What is the **totality measure** for the DCE liveness fixpoint (block count vs instr count)? | **RESOLVED — bounded monotone growth of the live-set** | The liveness fixpoint (`_uses_in_block`/`dead`) adds defs to a set that only grows and is bounded by the finite total def-set, so it terminates by the measure `|defs| − |live|` strictly decreasing until fixpoint; the per-iteration walk is structural over the (finite) block/instr lists. Standard fixpoint-termination argument, decidable from the algorithm — no author call. (`_size:333` is the separate fold-worklist measure.) |
| 3 | The **cost-gradient** decision (edges 2/3) is unresolved — should `optimize` carry a graded-cost type? | **DEFERRED → E38 (+ edges 2/3)** | The map row is explicit: "Meaning-preserving only, NO graded-cost claim — cost-typed account is **E38**, not a defect here." Until the graded-kernel cost enrichment (E38) lands, `optimize` carries only meaning-preservation, never a cost claim. The example's own honest boundary. Owner: [[E38]] / open-edges 2,3. |
| 4 | *(coupling, surfaced by the bundle)* E18's tal checker (`check-fn`/`PR`/`Env`) is **not yet self-hosted** — what is runnably testable now? | **RESOLVED — transforms now; re-check rides E18** | Same pattern as E16: the **transform logic** (fold/dead/specialize's tal→tal rewrites) is self-contained and differentiable against `optimize.py`'s outputs today. The **`check-fn` re-check** consumes E18's tal-in-chirality, so the full "output re-judged" differential lands when E18 self-hosts. Engineering scoping call; the E18 hand-off is named. |

All dispositioned; none blocking. `status: draft`.

## 4. Change plan (ordered, commit-sized)

2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. Every `optimize.py` line number below is kept as a record and has no live successor; the line numbers are left in prose for that reason.

### Step 1 — `Checked` + `re-check` over the E18 checker seam
- **Target:** `scaffold/lib/optimize.chiral` (new) — `(import "prelude")`
  `(import "tal-ir")`; `data Checked` (`c-ok (v TFn)`/`c-err (msg Str)`); the
  forward-declared E18 coupling (`check-fn`/`PR`/`Env`, decision #4); `re-check`.
- **Change:** the example §5 header + `re-check` (verbatim, load-verified).
- **Size:** ~S

### Step 2 — `fold` (constant folding)
- **Target:** `optimize.chiral` — `fold (-> TFn TFn)` + `fold-block`/the
  `_fold_prim` opcode table.
- **Change:** port `optimize.py:fold` (`:184`)/`_fold_block` (`:125`)/`_fold_prim`
  (`:37`); structural recursion over blocks, reversed-accumulator, threaded
  `cenv` (not ambient). Folds must be **bit-identical to runtime** (map). Total.
- **Size:** ~M

### Step 3 — `dead` (DCE)
- **Target:** `optimize.chiral` — `dead (-> TFn TFn)` + `uses-in`/`_dead_block`.
- **Change:** port `optimize.py`'s `dead` (line 216) / `_uses_in_block` (line 54); the
  liveness fixpoint terminating by bounded live-set growth (decision #2); drop
  instrs whose def ∉ live. Total.
- **Size:** ~M

### Step 4 — `specialize` (partial eval / pregen) + `optimize` pipeline
- **Target:** `optimize.chiral` — `specialize (-> (0 e Env) TFn Bindings Checked)`
  + `optimize (-> (0 e Env) TFn Checked)`.
- **Change:** port `optimize.py`'s `specialize` (line 264) / `_remap_block` (line 223) — bind
  static args → residual, then `re-check` (the residual is a pregen artifact);
  `optimize` = `re-check (dead (fold fn))` (end-recheck, decision #1). Total.
- **Size:** ~M

### Step 5 — differential test file
- **Target:** `scaffold/tests/test_optimize_chirality.py` (new; leave `test_optimize.py`
  untouched).
- **Change:** load `lib/optimize.chiral`, drive `fold`/`dead`/`specialize` with the
  `apply1` RT harness + a `TFn` adapter over `optimize.py`'s tal dicts. Assert the
  pass **outputs** match `optimize.py`'s for a fixture corpus: a foldable
  const-arith block (bit-identical fold), a block with a dead def (DCE drops it),
  a specialize with static bindings (residual matches `_remap_block`). The
  `check-fn` re-check differential is **E18-gated** (decision #4) — until then
  assert the transform outputs, the self-contained half.
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** `optimize.chiral`'s `fold`/`dead`/`specialize` reproduce
  `optimize.py`'s pass outputs on the corpus — folds **bit-identical to runtime**
  (the map's claim), DCE drops exactly the unused defs, `specialize` residual
  matches `_remap_block`; a pass that produced ill-typed tal surfaces as a `c-err`
  value (once E18's `check-fn` is live), never as shipped tal. Meaning-preserving
  only — no cost claim (decision #3).
- **Floors compared:** the **chirality RT interpreter** running `optimize.chiral` vs
  the **Python `optimize.py` oracle** (transform-output differential; the
  `check-fn` re-check differential is E18-gated). Lib-level chirality-vs-golden.
- **Green line:** 355 → ≥ 355 + k (the new `test_optimize_chirality.py` functions);
  full suite stays green, `optimize.py`/`tal.py` unchanged, ledger-lint clean.
- **Done when:** `test_optimize_chirality.py` passes — the chirality passes reproduce
  `optimize.py`'s outputs on the corpus (bit-identical fold, DCE, specialize
  residual), with the preserve-check re-judgment recorded as E18-gated.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **Tal checker self-host** (`check-fn`/`PR`/`Env`) — **[[E18-tal-check]]**; the
    "every pass output re-judged" differential rides it (decision #4).
  - **Graded-cost typing** of the passes — **[[E38]]** / open-edges 2,3
    (decision #3); today meaning-preservation only.
  - The **refined block-index knob** (bounds-checked block access) — [[E09-refinement]].
  - Retiring `optimize.py` and wiring `optimize.chiral` into the toolchain — rides
    the checker self-host.
- **Follow-on:** the optimizer half of the self-hosted compiler; the natural home
  for the **register/slot packing** pass E16 defers (decision #1 there); pairs
  with [[E16-lowering]] (produces the SSA tal it optimizes) and [[E18-tal-check]]
  (the preserve-check every pass rides).
- **Related:** [[E17-optimizer]] (rationale) · [[E18-tal-check]] (the `check-fn`
  every pass re-runs — `tal.py`, NOT E15) · [[E16-lowering]] (its SSA output +
  the deferred packing pass) · [[E38]] (the cost account, decision #3) ·
  [[E24-i64-arith]] (the fold arithmetic must match runtime bit-for-bit).
