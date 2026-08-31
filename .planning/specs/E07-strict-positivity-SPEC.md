---
element: E07
slug: strict-positivity
title: Strict positivity / variance analysis (`_positivity`, `_compute_sp_params`)
kind: SELF-HOST
example: examples/E07-strict-positivity.md
status: audited
updated: 2026-08-01
---

# E07 SPEC — Strict positivity / variance analysis

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/data.chiral` (the file E6 creates) gains the
  self-hosted positivity check — `hit?`/`mentions?`/`walk`/`walk-args` (the
  single walk, two targets `pt-name`/`pt-var`) returning a `PosR` verdict value,
  plus `compute-sp` filling the per-parameter strict-positivity cache — 
  differentially equal to `data.py`'s `_positivity` + `_compute_sp_params` on the
  accept/reject-per-declaration behavior.
- **Non-goals:** the `check-data` caller that runs this per ctor field and folds
  the cache into the signature (composition step, beside E6's handlers); the
  **mutual-group frozenset extension** (E79 sibling-non-uniform refusal) →
  deferred to the group-install assembly (decision #3); a variance lattice
  (co/contra/invariant) → deferred-until-needed (decision #1).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the sole E7 row is **CONFORMS, size S** — "Built;
  `_positivity` + `_compute_sp_params` run at check_data … Conservative-by-design
  (App variance refused)." A self-host transcription of a correct reference; one
  of the three totality pillars (with coverage E6, termination E11).
- **Live code (the reference being ported, do NOT respec):**
  - `data.py:296 _positivity` (the walk, with inner `is_hit`/`mentions`/`sp_in`/
    `walk`), `:410 _compute_sp_params`, `:431 _check_strict_positive` (the
    caller). Reject/allow sets verified against the walk:
    - **Reject:** occurrence in a `Pi` domain at any depth ("left of a function
      arrow", `:377`); nested through a non-sp parameter ("through a non-positive
      parameter", `:392`); under an `App` ("type-level application, variance
      unknown", `:396`); inside `Lam`/`Let`/`Con`/`Case` in a field type
      (`:401`); a bare head whose own args nest the target ("nested non-uniform
      type argument", `:366`).
    - **Allow:** a bare head occurrence (`:371`); nesting through a
      strictly-positive parameter of an already-measured container (`:395` walks
      deeper) — so `(List D)`/`(Maybe D)` pass.
  - **The self-convention:** `sp_in(con,i)` returns `True` for `con` in `under`
    (`:354`) — "the type under definition is positive in itself," breaking the
    self-recursive regress; an **unset** cache reads as refuse (`bool(sp)`, `:358`).
  - **Cache arithmetic:** the p-th parameter is de Bruijn index `nparams-1-p`
    inside a field type (`:418`); `compute-sp` runs the *same* walk with a
    `pt-var` target over every field (`:422`).
- **Baseline correction (E79, post-example):** the example (2026-07-22) predates
  E79 and its §6 says mutual families "conservatively refuse … **same as OURS
  today**" — **now stale.** The live `_positivity` takes `under` as
  `Str | frozenset<group>` (`:303–309, 350`) and, in name mode, refuses a
  recursive occurrence in the type args of a **group sibling** as non-uniform
  (`:388–391`). The example's single-`under` skeleton is the pre-E79 view.
- **True delta:** positivity functions added to `lib/data.chiral`; the walked
  `Ty` is the **shared kernel `Term`** (full arms Pi/Lam/App/Let/TCon/Con/Case/
  Ann/Refine/Var, not the 4-ctor skeleton). No `scaffold/chirality/*.py` change.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **Boolean per-param cache vs a variance lattice** (co/contra/invariant)? | **RESOLVED → boolean; lattice DEFERRED-until-needed.** | The bool `sp_params` (`data.py:427`) is sufficient for every container the checker itself needs (List/Maybe/pairs/assoc — all covariant). A variance lattice is owed only if a genuinely contravariant-parameter container ever earns a seat; none does today. Widening later is a bounded cache-type change, not a rewrite. Decidable → decided. |
| 2 | **Term rep walked** — example's 4-ctor `Ty` skeleton vs the real term type. | **RESOLVED → the shared kernel `Term`** (E3/E4/E6). | `mentions`/`walk` dispatch on the full tag set (`data.py:328–348, 373–404`): Pi/Lam/App/Let/TCon/Con/Case/Ann/Refine/Var. The port walks the shared `Term`, extending the skeleton's arms — the same "full ADT assembles" convergence as E6. The depth discipline (binder cases bump depth) is preserved. |
| 3 | **Mutual datatype families** — how the `under`-convention generalizes to a declaration group. | **PARTIALLY-RESOLVED by the live code; wiring DEFERRED to the group-install assembly.** | The generalization is already in the reference (the E79 correction above): `under` = the group's frozenset; a self *or sibling* head is positive-in-itself, but a recursive occurrence in a sibling's type args is refused non-uniform (`data.py:388–391`). E7 ports the **single-`under`** walk (the example's scope, the load-bearing check); threading the frozenset + sibling-refusal is a bounded extension that lands with the **mutual-group install** (`check_data_group`, `data.py:472`) beside E6/E79 — a cross-element seam, not E7-standalone. |

No NEEDS-AUTHOR: every question is decidable-and-decided or defers to a named
assembly; the change plan is fully unblocked (audited without `status: blocked`).

## 4. Change plan (ordered, commit-sized)

### Step 1 — verdicts, targets, cache types
- **Target:** `lib/data.chiral` — `PosR` (`pos-ok`/`pos-bad`), `PTarget`
  (`pt-name`/`pt-var`), `SP` (`sp-yes`/`sp-no`), and the cache shape
  `(List (Pair Str (List SP)))` threaded as a signature value (the D3 staged-in
  discipline — computed at declaration, never mutated after).
- **Size:** ~S.

### Step 2 — `hit?` / `mentions?`
- **Target:** `lib/data.chiral` — `hit?`, `mentions?`.
- **Change:** transcribe `data.py:319–348`. `hit?` for `pt-name` matches a `TCon`
  head; for `pt-var` matches `Var` at `ix+depth`. `mentions?` is pure structural
  recursion over the full `Term`, binder cases bumping depth (`Pi` cod +1, `Lam`
  +1, `Let` body +1, `Case` branch +|names|). Self-recursive only (does not call
  `walk`) — no E50 needed.
- **Size:** ~S.

### Step 3 — `walk` / `walk-args`
- **Target:** `lib/data.chiral` — `walk`, `walk-args`, `sp-in`.
- **Change:** transcribe `data.py:362–404` as result-sum threading (first
  `pos-bad` wins by `case`, replacing the mutable `reason` cell): the five reject
  arms + the two allow arms above. The Python's inline TCon arg-loop (`:382`)
  becomes an explicit `walk`↔`walk-args` **mutual** pair — its cross-calls are
  structurally decreasing (`walk-args` calls `walk` on a strict subterm `a`;
  `walk` calls `walk-args` on the current term's arg-list), so its termination is
  **E50 mutual-termination** (built), *not* E11 single-function structural. (The
  example's "no E50 needed" is specifically about `mentions?`/`walk`, which are
  each self-recursive — Step 2; it does not cover this pair. An inline
  numeric-fold over the arg-list is the E50-free alternative if preferred.)
  `sp-in` is assoc lookup with the self-convention (`under` ⇒ `true`, absent/
  `sp-no` ⇒ `false`). Single-`under` (decision #3).
- **Size:** ~M.

### Step 4 — `compute-sp`
- **Target:** `lib/data.chiral` — `compute-sp`.
- **Change:** transcribe `data.py:410`: for each param `p` at index
  `nparams-1-p`, run `walk` with a `pt-var` target over every field of every
  ctor; all clean ⇒ `sp-yes`. Structural recursion on a countdown; the *same*
  walk as Step 3 (one algorithm, two targets — keep it that way).
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** differential against `data.py` `_positivity`/
  `_compute_sp_params` on **accept/reject per declaration** (reason wording is
  free — accept/reject is the observable). Required cases: reject left-of-arrow
  at any depth (incl. the double-negative); reject nested-through-non-sp
  parameter; reject under a type-level `App`; reject inside `Lam`/`Let`/`Con`/
  `Case`; reject a non-uniform nested head arg; **accept** a bare head and
  covariant-container nesting (`(List D)`, `(Maybe D)`); an **unset** cache
  refuses.
- **Mostly-standalone:** the walk is a *syntactic* pass over `Term` + a value
  cache — it needs the shared `Term` grammar (E3's data layer) and prelude/
  collections, but **not** `eval`/`conv`, so its differential is far more
  standalone than E4/E6's handler integration (only the `check-data` caller that
  folds the cache into the sig composes later).
- **Tests to add:** the existing `tests/test_kernel.py` positivity cases are the
  oracle; add a `test_positivity_selfhost` differential feeding the same field
  types to both floors and comparing accept/reject + the `sp_params` bool vector.
- **Green line:** 355 → ≥ 355 + (case count, ≥ 6); ledger-lint clean.
- **Done when:** chirality `walk`/`compute-sp` agree with `data.py` on accept/reject
  and the per-param cache across the corpus (incl. `List D` accepted, `Bad`'s
  `(f (=> Bad X))` rejected left-of-arrow).

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **Mutual-group frozenset extension** (E79 sibling-non-uniform refusal) →
    the group-install assembly (`check_data_group`), beside E6/E79 (decision #3).
  - **Variance lattice** (co/contra/invariant) → deferred-until-a-contravariant-
    container-needs-it (decision #1).
  - **The `check-data` caller** (runs positivity per field, folds `compute-sp`
    into the sig) → the data-layer assembly beside E6's handlers.
  - **Cache as a balanced map** (assoc now) → **E27** (maps).
- **Follow-on:** completes the **positivity pillar** of totality (with coverage
  E6, termination E11); the trusted judgment's own positivity code passes its own
  termination pillar (self-applicability).
- **Related:** [[E07-strict-positivity]], [[E06-data-ctors-coverage]] (lands
  beside it, shares `DataDecl`), [[E11-totality-checker]] (sibling pillar),
  [[E03-nbe-normalize]] / [[E13-debruijn]] (the `Term` walked),
  [[E27-dict-set-to-maps]] (the cache's eventual map),
  [[decision-graded-kernel]] (Fork B: positivity as the minimal totality guard).
