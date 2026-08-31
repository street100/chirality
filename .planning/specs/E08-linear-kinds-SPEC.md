---
element: E08
slug: linear-kinds
title: Linear-kind decision for data (`_linear_data`, bounded abstract walk)
kind: SELF-HOST
example: examples/E08-linear-kinds.md
status: audited
updated: 2026-08-01
---

# E08 SPEC — Linear-kind decision for data

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/data.chiral` (the file E6/E7 build) gains the
  self-hosted linear-kind walk — `linear-ty`/`fields-lin` over a first-order
  `TyV` view, returning a **three-valued `LinR`** (`lin-yes`/`lin-no`/
  `lin-defer`) — differentially equal to `data.py`'s `_linear_data` (mapping
  `lin-yes`→True, `lin-no`/`lin-defer`→False, since the Python collapses defer)
  on every declaration and instantiation the suite exercises.
- **Non-goals:** the kernel `is_linear` **fast path + hook plumbing** (atom flag,
  `sig.linear_data` cache, `linear_hooks` dispatch, `kernel.py:208`) → the
  declining-hook assembly (as E3/E4 deferred); the **instantiation-time
  re-judgment** wiring (`on_apply` re-judges `(List A)` at `A:=Sock`) → **E12**;
  dependent field types (the un-evaluable branch) → the evaluator seam (E3/E15);
  **capture** linearity (a closure over a linear port) → **E39/E69**, explicitly
  outside this walk (shapes, not captures).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the sole E8 row is **CONFORMS, size S** — "Built;
  `is_linear` + depth-bounded abstract walk, deferral sound … Deferral = same
  sound answer as cycle-break." A self-host transcription; one leg of capability
  non-forgeability (the linear-kind leg of `decision-b-in-type`).
- **Live code (the reference being ported, do NOT respec):**
  - `data.py:77 _linear_data` — the walk: non-`VTCon`→False; seen-key
    `(name, repr(args))` cuts cycles (`:80–82`); `len(seen) >=
    _LINEAR_ABSTRACT_DEPTH`→defer (`:83`); any `q==1` field→linear (`:92`); else
    recurse into each field type `eval`'d under the args env (`:95`); an
    un-evaluable field is skipped — judged at instantiation (`:97`).
  - `kernel.py:208 is_linear` — the two-level seam: `VPrimTy` atom flag, `VTCon`
    in `sig.linear_data`, else declining `linear_hooks` (of which `_linear_data`
    is one). The kernel never learns what a constructor is.
  - **The consumer seams (E12):** `on_binder` rejects a linear type at `q≠1`;
    `on_apply` re-judges the instantiated parameter — the polymorphic-smuggle
    closure. E5's SPEC and E6's `_ctor_field_types` (`data.py:137`) already name
    `is_linear` as the E8 seam they consume.
- **True delta:** the `linear-ty`/`fields-lin` walk added to `lib/data.chiral`,
  over a first-order `TyV` (the post-`eval` value view: `tv-atom`/`tv-tcon`/
  `tv-arrow`/`tv-other`). No `scaffold/chirality/*.py` change; `data.py` stays the
  bootstrap referent.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **Three-valued `LinR` vs boolean** — making `lin-defer` explicit changes the consumer seam's contract. | **RESOLVED → three-valued `LinR`.** | Deferral-as-a-value is the chirality discipline every checker-stack SPEC follows (E3/E4/E6 result sums); the Python collapses defer into `False` and carries the re-judgment obligation *in comments* — exactly the "hidden convention" chirality un-hides. `case` forces every consumer to handle `lin-defer`. **Forward contract to E12** (audited, unbuilt): its `on-binder`/`on-apply` must `case` on `LinR` — `lin-yes` at `q≠1` rejects, `lin-defer` triggers the instantiation-time re-judgment. Differential maps `lin-no`/`lin-defer`→Python `False`, so conformance is preserved. |
| 2 | **Seen-set key** — the Python uses `(name, repr(args))`, a borrowed CPython canonicalizer (a trust-boundary crutch). | **RESOLVED → structural `TyV` equality; broader canonical-type-form → determinism debts.** | `TyV` is first-order data, so structural equality is decidable and *is* the honest canonical form — a faithful replacement for `repr` (same tcon at different args re-walks, same as the Python). The wider question of a canonical form/ordering for *all* type values across the fixpoint belongs to `DETERMINISM-DEBTS.md`, but E8's walk needs only structural `TyV` equality, available now. Decidable → decided. |
| 3 | **Where instantiation-time re-judgment lives once the checker is chirality** (the `on_apply` seam's port). | **DEFERRED → E12.** | The re-judgment of a parametric shape at its instantiation (`(List A)` at `A:=Sock`) is the membrane's `on_apply` — **E12's** seam (`effects.py`). E8 provides the `linear-ty` walk; E12 calls it at declaration (`on_binder`) and instantiation (`on_apply`). The three-valued result (decision #1) is what makes the `lin-defer`→re-judge obligation explicit at that seam. |

No blocking NEEDS-AUTHOR. Decision #1 carries a forward contract to E12 (a
bounded `case`-arm, not a conflict); the SPEC audited without `status: blocked`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — the first-order type view + result
- **Target:** `lib/data.chiral` — `TyV` (`tv-atom (lin Bool)`/`tv-tcon`/`tv-arrow`/
  `tv-other`), `Field`/`Decl` (flattened ctor fields), `LinR`
  (`lin-yes`/`lin-no`/`lin-defer`), and `tyv=` (structural equality, decision #2).
- **Change:** `(import "prelude" "collections")`; the sums per example §5.
  `tv-arrow` is opaque → `lin-no` (shapes, not captures — the settled boundary).
- **Size:** ~S.

### Step 2 — the bounded abstract walk
- **Target:** `lib/data.chiral` — `linear-ty`, `fields-lin`, `seen-has`,
  `ctor-fields`.
- **Change:** transcribe `data.py:77` per example §5. `linear-ty`: `tv-atom`→its
  flag; `tv-arrow`/`tv-other`→`lin-no`; `tv-tcon`→`cond` on `(<=i fuel 0)`→
  `lin-defer`, `(seen-has …)`→`lin-no`, else `fields-lin` under `(cons name
  seen)` and `(- fuel 1)`. `fields-lin`: any `(fld 1 _)`→`lin-yes`, else join
  `(linear-ty … ty)` over each field with **`lin-defer` sticky** (an undecided
  branch is never dropped). The Python's inline ctor/field loops (`data.py:90–91`)
  become an explicit `linear-ty`↔`fields-lin` **mutual** pair, so — as with E7's
  `walk`/`walk-args` — its termination is **E50 mutual-termination** (built), with
  the **fuel** as the strictly-decreasing measure across the cycle (`- fuel 1` on
  every `tv-tcon` descent) and the seen-list cutting cycles. (An inline
  single-function fold over the fields is the E50-free alternative, matching the
  Python's non-mutual shape.) `seen-has` uses `tyv=`/name equality; `ctor-fields`
  substitutes args into field types (consumes E3 `eval` for real decls — see
  gate).
- **Size:** ~M.

## 5. Conformance gate

- **Golden behavior:** the chirality `linear-ty` agrees with Python
  `is_linear`/`_linear_data` on every declaration in `lib/*.chiral` and every
  instantiation the suite exercises, under the mapping `lin-yes`→True,
  `lin-no`/`lin-defer`→False. Required cases: the **`RecvR` precedent** (a ctor
  with a `1`-field `Sock` → `lin-yes`); **`(List Sock)`** rejected at the
  instantiation seam (List's binder is ω, so a port smuggled through it fails);
  a cyclic data type cut by `seen`→`lin-no`; a deeply-nested non-uniform shape
  hitting the fuel bound→`lin-defer` (Python `False`).
- **Gate split (honest):** the **walk core** (fuel/seen/`q=1`/three-valued join)
  is standalone over a hand-built `TyV` corpus; the **full differential** (real
  declarations) needs **E3's `eval`** to produce `TyV`s from field types via
  `ctor-fields` (the same instantiation the Python does at `data.py:95`).
- **Tests to add:** `tests/test_kernel.py` linear-kind rejections are the oracle;
  add a `test_linear_selfhost` differential over the declaration + instantiation
  corpus, comparing `LinR`→bool against Python.
- **Green line:** 355 → ≥ 355 + (case count, ≥ 5); ledger-lint clean.
- **Done when:** chirality `linear-ty` and Python `is_linear` agree (under the
  three-valued→bool mapping) across the corpus, incl. `RecvR`→yes and `(List
  Sock)` rejected at instantiation.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **Kernel `is_linear` fast path + hook plumbing** (atom flag, `linear_data`
    cache, hook registration) → the declining-hook assembly.
  - **Instantiation-time re-judgment** (`on_apply`) → **E12** (decision #3).
  - **Dependent field types** (the un-evaluable branch) → the evaluator seam
    (E3/E15).
  - **Capture linearity** (a closure over a linear port) → **E39/E69**
    (EDGE-CANDIDATES C3) — outside this walk by construction (shapes, not
    captures).
  - **Canonical type-value form** across the fixpoint → `DETERMINISM-DEBTS.md`
    (decision #2; E8 uses structural `TyV` equality locally).
- **Follow-on:** completes the linear-kind seam E5 (`on_binder` q=1) and E6
  (`_ctor_field_types`'s `is_linear`) consume; feeds **E12**'s membrane seams.
- **Related:** [[E08-linear-kinds]], [[E06-data-ctors-coverage]] /
  [[E07-strict-positivity]] (lands beside them, shares `data.chiral`),
  [[E12-effect-membrane]] (the consumer seams + the forward contract of decision
  #1), [[E05-qtt-semiring]] (the `q=1` field declaration), [[E03-nbe-normalize]]
  (the `eval` that instantiates field types), [[decision-b-in-type]] (the rule
  this mechanizes), [[E39-effect-row]] (the capture half this walk excludes).
