---
element: E06
slug: data-ctors-coverage
title: Data: constructors, case coverage, ctor-param unification (`_infer_ctor_params`)
kind: SELF-HOST
example: examples/E06-data-ctors-coverage.md
status: audited
updated: 2026-08-01
---

# E06 SPEC — Data: constructors, case coverage, ctor-param unification

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/data.chiral` exists — the self-hosted data
  layer: the `Field`/`Ctor`/`DataDecl` grammar + result sums (`OptTy`/`CovR`/
  `SolveR`), the **coverage verdict** (`check-coverage`/`cov-go` — every declared
  ctor matched exactly once, unknown/dup/missing named), the **bounded
  ctor-param solver** (`bare-param`/`solve-go`/`infer-ctor-params` — solve a
  parameter only where a field is a bare occurrence, sound-by-recheck), and the
  **Con/Case check-handlers** (`check-con`/`check-case`/`check-tcon`) that
  integrate the two algorithms with E4/E5/E10 — differentially equal to
  `data.py`'s `_check_con`/`_check_case`/`_check_tcon`/`_infer_ctor_params`.
- **Non-goals:** strict positivity (`_positivity`) → **E7**; linear-kind of a
  data type (`_linear_data`) → **E8**; termination/`check_termination` → **E11**;
  Con/Case **eval** handlers (`_eval_con`/`_eval_case`) → the NbE data-value arms
  E3 deferred; dependent/telescoped parameters → **E48**.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the sole E6 row is **CONFORMS, size S** — "Built;
  coverage enforced, `_infer_ctor_params` solves bare params … Scaffold limits
  (no dependent fields) recorded honestly, not defects." A self-host
  transcription of a correct reference.
- **Live code (the reference being ported, do NOT respec):**
  - `data.py:202 _check_case` (coverage + branch usage), `:146
    _infer_ctor_params` (the bounded solver), `:173 _check_con`, `:111
    _check_tcon`, `:128 _ctor_field_types`, `:104 lookup_ctor`.
  - **The solver arithmetic:** the p-th parameter sits at de Bruijn index
    `nparams-1-p` in a field type; a param is solved only where a field is a bare
    `Var` (`data.py:162–164`) — E6's `bare-param`.
  - **Sound-by-recheck:** `_check_con` re-checks every arg against the
    instantiated field types (`data.py:196–198`), so a solver candidate is never
    trusted — the recheck is the proof.
  - **Consumers integrated in the handlers** (not built by E6): E4 `check`/
    `infer`/`subtype`; E5 `uadd`/`uscale`/`ujoin`/`qfits` (branch usage +
    per-binder audit, `data.py:237–256`); E10 `narrow_hooks` (path-sensitivity,
    `data.py:226–229`); E8 `is_linear` inside `_ctor_field_types` (`:137`).
- **True delta:** one new `lib/data.chiral`. Its `Ty` grammar is the **shared
  kernel ADT** (E3/E4's `Term`/`Val`), not the example's standalone `ty-i64`
  skeleton — same "full ADT assembles" convergence as E3→E4→E5. No
  `scaffold/chirality/*.py` change; `data.py` stays the bootstrap referent.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **Default-branch coverage** — does a `default` suppress `cov-missing`, and should the self-hosted core permit it (a default is a strictly weaker check)? | **RESOLVED (port) → keep `default`, faithful to the reference; the "tighten it" question FLAGGED as non-blocking future author call.** | Conformance *requires* keeping it: `data.py:244` treats a present `default` as covering any missing ctor, so dropping it would newly reject programs on the golden suite (a semantic change, not a port). E6 ports the reference behavior. **FLAG (non-blocking):** whether the self-hosted core should eventually drop the default escape hatch to force exhaustiveness (aligns with the totality-pillar / "coverage kills the catch-all" direction in [[E14-pretty-printer]]) is an object-language-semantics call for the author — surfaced in §6, not forced now. |
| 2 | **Telescoped parameters** — Python's `decl.params` are a telescope (each binder under earlier params); the skeleton flattens to `nparams I64`. | **RESOLVED (port) → flat `nparams`; DEFERRED (telescopes) → E48.** | The flat model **is** the reference's actual behavior — `_ctor_field_types` states "fields may not depend on earlier fields (scaffold limit), only params" (`data.py:142`), and the map row records "no dependent fields … honestly, not defects." Dependent/telescoped parameters need value-indexed telescopes → **E48**. Faithful port = flat. |
| 3 | **Scrutinee QTT usage `us` threading through branches.** | **RESOLVED → the reference behavior, consuming E5.** | Not open — `data.py:256` returns `uadd(us, joined)`, each branch `ujoin`ed (`:242`), each field binder `qfits`-audited and stripped (`:237–241`). E6's `check-case` reproduces this exactly, consuming E5's `uadd`/`ujoin`/`qfits` by signature (integration facet, gated on E5 built). |
| 4 | **Coverage: short-circuit vs accumulate all failures.** | **RESOLVED → short-circuit (first failure), matching the reference.** | `data.py` raises at the first missing/dup/unknown; the example's `cov-go` returns the first failing `CovR`. Accumulate-all is a diagnostic nicety, recorded as an optional knob (§6), not owed. Decidable → decided. |

One FLAG (decision #1, non-blocking future author call). No blocking
NEEDS-AUTHOR; the change plan is fully unblocked (audited without `status:
blocked`).

## 4. Change plan (ordered, commit-sized)

### Step 1 — the data grammar + result sums
- **Target:** `lib/data.chiral` (NEW FILE) — `Field`/`Ctor`/`DataDecl`, and
  `OptTy`/`CovR`/`SolveR`.
- **Change:** `(import "prelude")` + the shared kernel ADT; define `Field (q
  Qty)…` (quantity from E5), `Ctor`, `DataDecl (nparams I64)…` (flat, decision
  #2), and the result sums per example §5. `Ty` = the shared `Term`/`Val`, not a
  standalone skeleton. Forward-`declare` the mutual group before any `def`.
- **Size:** ~S.

### Step 2 — coverage verdict (pure, standalone)
- **Target:** `lib/data.chiral` — `count-name`/`cov-unknowns`/`ctor-names`/
  `cov-go`/`check-coverage`.
- **Change:** transcribe example §5 — walk `decl.ctors`, `count-name` each in the
  branch list, emit `cov-missing`/`cov-dup`/`cov-unknown`/`cov-ok`. Depth-1
  patterns, linear in `|ctors|×|branches|`. Pure `->`, structurally recursive.
- **Size:** ~S.

### Step 3 — ctor-param solver (pure, standalone)
- **Target:** `lib/data.chiral` — `bare-param`/`opt-init`/`opt-set1`/`solve-go`/
  `finish`/`infer-ctor-params`.
- **Change:** transcribe example §5 — arity gate up front (`sv-arity`),
  `bare-param` computes `p = nparams-1-ix` and returns `-1` for non-bare fields,
  `solve-go` threads the `(List OptTy)` accumulator (the caller-inferred arg
  types, `o-none` where inference failed — the try/except probe as a value),
  `finish` maps all-`o-some`→`sv-solved` else `sv-unsolved p`. No occurs-check,
  no substitution (`data.py:146` is deliberately not Robinson).
- **Size:** ~S.

### Step 4 — the Con/Case check-handlers (integration)
- **Target:** `lib/data.chiral` — `check-tcon`/`check-con`/`check-case`,
  `ctor-field-types`, `lookup-ctor`.
- **Change:** transcribe `data.py:111/173/202`. `check-con`: when no expected
  type, run the Step-3 solver, then **recheck** every arg against the
  instantiated field types (E4 `check` + E5 usage) — the candidate is never
  trusted. `check-case`: infer scrutinee (reject non-`VTCon`), run Step-2
  coverage against `decl.order`, apply E10 `narrow-hooks` per branch, bind field
  names at their quantities, check/infer the body, `qfits`-audit + strip + `ujoin`
  the usage, honor `default` (decision #1). These consume **E4/E5** (and **E10**
  for narrow) by signature — the differential for this step is gated on those
  built.
- **Size:** ~M.

## 5. Conformance gate

- **Golden behavior:** same accept/reject set as `data.py`. (a) **Coverage** —
  a non-data scrutinee is rejected; missing/duplicate/unknown ctor branches are
  rejected with the offending ctor named; a `default` suppresses the missing
  check. (b) **Solver** — `(cons n nil)`-style applications check unannotated;
  arity mismatch and unsolved parameters fall back to "annotation required"; a
  wrong candidate is rejected by the recheck, never trusted.
- **Gate split (honest, per E4's pattern):**
  - **Standalone (Steps 2–3, needs only prelude + the grammar):** both are pure
    algorithms, but they differ in how they diff. The **solver** is a *direct
    function diff* — `_infer_ctor_params` is a standalone function (`data.py:146`),
    so `infer-ctor-params` compares to it argument-for-argument. **Coverage** is
    *inlined* in `_check_case` (no standalone Python fn), so `check-coverage` is a
    *behavioral diff*: feed the same `DataDecl` + branch-name set to both and
    compare the missing/dup/unknown verdict (E6's `CovR` vs `_check_case`'s
    accept/reject on a constructed case).
  - **Integration (Step 4, needs E4+E5 built, +E10 for narrow):** the full
    `check-con`/`check-case` accept/reject + usage-vector differential vs
    `data.py`.
- **Tests to add:** `tests/test_kernel.py` (or `test_data_selfhost.py`) — the
  coverage + solver tables standalone; the handler differential when E4/E5 land.
- **Green line:** 355 → ≥ 355 + (case count, ≥ 6 standalone); ledger-lint clean.
- **Done when:** the standalone coverage + solver agree with `data.py` on the
  sampled corpus (incl. missing/dup/unknown named and the bare-vs-non-bare solver
  cases), and the handler differential passes once E4/E5 are built.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **Strict positivity** (`_positivity`) → **E7**; **linear-kind** (`_linear_data`,
    the `is_linear` check in `_ctor_field_types`) → **E8**; **termination**
    (`check_termination`) → **E11** — all live in `data.py` but are separate
    elements.
  - **Con/Case eval handlers** (`_eval_con`/`_eval_case`) → the NbE data-value
    arms E3 deferred (`v-tcon`/`v-con`).
  - **Telescoped/dependent parameters** → **E48** (decision #2).
  - **Default-branch tightening** (drop the escape hatch for totality) → author
    call, non-blocking (decision #1 FLAG).
  - **Accumulate-all coverage diagnostics** → optional knob, nobody's yet
    (decision #4).
- **Follow-on:** unblocks **E7** (positivity walks the same `DataDecl`), **E8**
  (linear-kind reads the same field quantities), and completes the data-value
  arms E3/E4 deferred (the `ext_check` former hooks).
- **Related:** [[E06-data-ctors-coverage]], [[E03-nbe-normalize]] /
  [[E04-bidir-universes]] (the shared ADT + `check`/`infer`/`subtype` consumed),
  [[E05-qtt-semiring]] (branch usage ops), [[E07-strict-positivity]],
  [[E08-linear-kinds]], [[E10-occurrence-typing]] (narrow hooks),
  [[E48-telescopes]] (dependent parameters), [[E14-pretty-printer]] (the
  coverage-kills-catch-all direction).
