---
element: E48
slug: telescopes
title: Dependent records / telescopes (field dependence)
kind: BUILD-PROPER
example: examples/E48-telescopes.md
status: audited
updated: 2026-08-02
---

# E48 SPEC — Dependent records / telescopes (field dependence)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
> **Scope bound:** left-to-right field dependence in `data` constructors only —
> a field's type may mention *earlier fields' values*, checked under a
> field-by-field extended context. NOT first-class Σ-types / projections, NOT
> induction-recursion / intrinsic syntax (§6). **Language-completeness, not a
> self-host blocker** (§2.3 extrinsic finding; SELF-HOST-PLAN: E48 self-removed).

## 1. Deliverable

- **After this runs:** a constructor field's type may reference the **values of
  earlier fields** — `(data PoolRec () (pool-rec (n I64) (1 p (Pool n))))` type-
  checks, `p`'s type `(Pool n)` reading field `n` at de Bruijn index 0. Field
  types are elaborated/evaluated/positivity-and-coverage-walked under a context
  **extended field-by-field** (`params ++ fields[0..i-1]`), the same Pi-codomain
  shift discipline (E13). This retires the lift-to-parameter workaround (`PoolR`
  carrying `n` as a *param*): the index becomes an ordinary earlier field, so the
  record's *type* no longer has to name it.
- **Non-goals:** first-class **Σ-types / projections** (`fst`/`snd` over a
  dependent pair as a standalone former) — separate, deferred; **induction-
  recursion / intrinsic syntax** — the extrinsic checker deliberately never
  adopts it; field-telescope **inference** (annotation-first — the dependence is
  written, §3 #1). No change to the checker's OWN records (they are flat — §2).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** **BUILD-M** (E48) — "forward in `data.py`." The
  scaffold limit is `data.py:162`: a constructor's field types are evaluated in
  `env = list(targs)` (`data.py:154`) — *parameters only* — so no field can
  reference an earlier field.
- **Live code this composes with (do NOT respec):**
  - **E13 de Bruijn shift + Pi context-extension** — the Pi codomain is already
    checked in a context extended by the domain binder with a de Bruijn shift;
    a field telescope is that move *iterated*.
  - **The dependent-field machinery is already exercised via a param.** `PoolR`
    carries `(n I64)` as a param and a field `(Pool n)` — proving `eval_term` and
    the linear-kind judgment (`is_linear` at field instantiation, `data.py:157`)
    **already handle a dependent field type**; E48 only moves the index's home
    from the param telescope to the field telescope (same shift, new position).
  - **E6 coverage / E7 positivity walks** (`data.py`) — must walk field types
    under the *extended* context, not the params-only env.
  - **`_infer_ctor_params`** (`data.py:166`) already indexes params at
    `nparams-1-p`; field indices sit above that and compose.
- **True delta:** thread a **growing `env`** through `_ctor_field_types` (push a
  fresh binder per field), and route the positivity/coverage walks through the
  same extended context — plus the negative check that a field's type only names
  fields that exist and typecheck.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does the elaborator **infer** a field telescope, or require the dependence be **written**? | **RESOLVED: annotation-first (written).** | The conservative start (the example's own recommendation): the dependence is explicit in the field type `(Pool n)`; no inference engine. Inference is a follow-on with no current consumer. |
| 2 | QTT rule for a field that is **both linear AND indexed by a later field's type**. | **RESOLVED: erased use — mentioning a field in a *later type* costs nothing against its linear budget.** | Types do not survive to runtime, so a type-level mention is erased (identical to `(1 x A) -> (B x)` mentioning `x` erased in `B`); the field's runtime value still flows to the constructor exactly once. Derivable from the existing erasure discipline; verified against the `is_linear` ordering at `data.py:157`. |
| 3 | First-class **Σ / projection** scope. | **DEFERRED — stays deferred until a concrete rung-1 consumer forces it (none found in the checker).** | The extrinsic checker (§2.3) uses `Term`-as-data + refinement (E9) subset-Σ; no first-class Σ consumer exists. A clean standing deferral, not this SPEC's surface. |

No blocking NEEDS-AUTHOR: #1/#2 are code-derivable, #3 is a standing deferral with
a named re-entry condition. Frontmatter stays `draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — thread the growing context through `_ctor_field_types`
- **Target:** `data.py` `_ctor_field_types` (`:148`), the `env = list(targs)` init (`:154`).
- **Change:** after judging field *i*, push a fresh binder (`("Var", level)` /
  the field's value) so field *i+1* elaborates and `eval_term`s its type with
  earlier fields in scope at de Bruijn 0 (params below). The `is_linear` field
  check (`:157`) runs under the extended env.
- **Size:** ~M.

### Step 2 — positivity + coverage under the extended context
- **Target:** `data.py` `_positivity` (E7) + the coverage walk (E6).
- **Change:** both walks descend field types under the *same* growing context, so
  a field's type mentioning an earlier field is neither a false positivity
  rejection nor a coverage miss.
- **Size:** ~S.

### Step 3 — the negative check (a field naming a bad earlier field)
- **Target:** `data.py` (field-type elaboration).
- **Change:** a field type referencing a non-existent or wrongly-typed earlier
  field is **rejected at the declaration** (the de Bruijn index is out of range /
  ill-typed under the telescope) — the soundness half.
- **Size:** ~S.

### Step 4 — differential vs the param workaround
- **Target:** `scaffold/tests/test_kernel.py` (data tests).
- **Change:** `PoolRec` (field dependence) checks and behaves identically to the
  parameterized `PoolR` — same runtime rep, same linear discipline, same
  bound-verification at the crossing.
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** `(data PoolRec () (pool-rec (n I64) (1 p (Pool n))))`
  type-checks and its `pool-rec` behaves identically to the parameterized `PoolR`
  (same rep, same linear discipline); a later field indexing a **non-existent or
  wrongly-typed** earlier field is **rejected at declaration**; a linear field
  freely indexed by a later field's type is accepted (erased use, §3 #2); every
  existing data/kernel test stays green (params-only decls unaffected).
- **Tests to add (`scaffold/tests/test_kernel.py`):**
  1. **Field dependence checks:** `PoolRec` type-checks; differential — same rep
    + linear verdict as `PoolR`.
  2. **Negative:** a field type naming a non-existent/wrong earlier field is
    rejected at the declaration.
  3. **Linear-erased-index:** a `(1 ...)` field mentioned in a later field's type
    is accepted (no double-use), consumed once at runtime.
  4. **No regression:** existing param-telescope data decls unchanged.
- **Green line:** 430 → **≥ 433**; `ledger-lint` clean.
- **Done when:** a value-indexed record written with field dependence checks and
  runs identically to today's parameter workaround, and a lying field index is a
  declaration-time rejection.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - *First-class Σ-types + projections* — §3 #3, deferred until a consumer forces it.
  - *Induction-recursion / intrinsic syntax* — the extrinsic checker never adopts it.
  - *Field-telescope inference* — annotation-first here; inference is a follow-on.
- **Rung-1 status (authoritative):** E48 is a **language-completeness extension,
  NOT a self-host blocker.** The extrinsic LCF/de-Bruijn checker (§2.3,
  `decision-split-checker`) carries raw `Term` sums + flat `(Qty, Term)` context
  entries — **no field of its own records depends on an earlier field's value**;
  refinement (E9) covers the subset-Σ it does use. This matches SELF-HOST-PLAN
  (E48 "self-removed" from the blocker set). *Cross-artifact note:* the E47
  example/SPEC's passing reference to E48 as "the dependent-signature blocker"
  carries the older framing — owed a light reconciliation (not blocking either).
- **Links:** [[E13-debruijn]] (the shift discipline reused), [[E06-data-ctors-coverage]]
  (coverage under the telescope), [[E07-strict-positivity]] (positivity under it),
  [[E09-refinement]] (the subset-Σ the checker actually uses),
  [[E52-certificate-split]] (extrinsic checker — why self-host needs neither this
  nor Σ), [[E47-sized-types]] / [[E50-mutual-lex-termination]] (the sibling
  self-applicability features).
