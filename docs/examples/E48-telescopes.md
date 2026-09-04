---
element: E48
slug: telescopes
title: Dependent records / telescopes (field dependence)
kind: BUILD-PROPER
reference_class: PAPER
ours_source: (none)
status: drafted
updated: 2026-07-22
---

# E48 — Dependent records / telescopes (field dependence)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> **Rung-1 finding up front (§2):** self-hosting does NOT force this, and does
> not force full Σ — the extrinsic checker sidesteps both. E48 is a bounded
> *language-completeness* extension (retire the lift-to-parameter workaround),
> not a self-host blocker.

## 1. Scope

- **Element:** E48, **left-to-right field dependence in `data` constructors** — a
  constructor field's type may mention the *values* of earlier fields, checked
  under a context extended field-by-field (the telescope discipline). NOT
  first-class Σ-types with projections (that is a separate, heavier, deferred
  feature — §6).
- **Kind:** BUILD-PROPER — the scaffold limit is `data.py:162`: field types are
  evaluated in an environment of the type *parameters only*, so no field can
  reference an earlier field.
- **Why chirality needs its own:** value-indexed records today require lifting the
  dependent value into a type *parameter* (`PoolR` carries `n` as a param, not a
  field). That workaround forces the index into the record's *type*, so a caller
  must name `n` to name the type. Field dependence retires the workaround: the
  index becomes an ordinary earlier field. This is a language-completeness gap,
  not a TCB gap.

## 2. Research

- **Reference class:** PAPER — telescopes (de Bruijn; iterated Σ / dependent
  binders), dependent record calculi. Read for the shape; the chirality form reuses
  machinery already present.
- **Key findings:**
  1. **A telescope is the Pi discipline applied to a field list.** The Pi
     codomain is already checked in a context extended by the domain binder,
     with a de Bruijn shift (E13). A constructor's fields are the same move
     iterated: field *i*'s type is checked (and evaluated) in the context
     `params ++ fields[0..i-1]`. The current `_ctor_field_types` evaluates every
     field in `env = list(targs)` (params only, `data.py:154`); the fix is to
     extend `env` with a fresh variable for each field as it is processed.
  2. **The scaffold already does the dependence — via a parameter.** `PoolR`
     carries `(n I64)` as a *param* and field `pool : (Pool n)`. That proves the
     evaluator and linear-kind judgment already handle a dependent field type;
     E48 only moves the index's home from the param telescope to the field
     telescope, which are the same shift discipline at two positions.
  3. **THE self-host finding — extrinsic typing decouples this from self-host.**
     chirality's checker is *extrinsic* (LCF / de Bruijn, per `decision-split-checker`):
     it carries **raw de Bruijn terms plus separately-computed types and re-checks**,
     never intrinsically-typed syntax. So the checker represents the object-level
     dependence it *checks* as ordinary `Term` data — a `(List (Qty, Term))`
     telescope value over a plain `Term` sum — and its own records
     (context entries `(q, ty)`, checked defs `(name, ty, body)`) have **no field
     whose type depends on an earlier field's value.** An *intrinsic* checker
     (well-typed-terms-by-construction) would force full dependent records +
     induction-recursion; the extrinsic one chirality chose does not. **Self-hosting
     forces neither field-dependence nor Σ.** Refinement types (E9) already cover
     the "value with a proof" (subset-Σ) case the checker does use.

## 3. Conventional (other-language) approach

Two poles, and chirality wants the middle:

```c
/* C struct: FLAT. No field's type can mention another field's value.
   A bounded buffer must carry its bound as an untyped, u^nchecked int: */
struct pool { long n; unsigned char *p; };   /* nothing ties p's size to n */
```

```coq
(* Coq: full dependent records — field type mentions earlier field VALUE,
   plus projections and first-class Sigma. More than self-hosting needs: *)
Record Pool := { n : nat ; p : Vector.t byte n }.   (* p's type uses n *)
```

- **Assumptions baked in:** C — the size/index relationship is folklore the
  compiler cannot see (the exact untyped-bottom chirality refuses); Coq — full Σ
  with projections and (with induction-recursion) intrinsic syntax, a heavier
  kernel commitment than the extrinsic checker requires. chirality wants **only** the
  left-to-right field-dependence, decidable and de-Bruijn-checked, and stops
  short of first-class Σ.

## 4. The chirality idea

- **Chirality features in play:** the Pi binder's context-extension + de Bruijn
  shift (E13), the QTT quantity on each field, `is_linear` at field
  instantiation (`data.py:157`), the evaluator (`eval_term`), positivity/coverage
  walks (E6/E7) which must respect the extended context.
- **The reframing:** a constructor declaration *is* a telescope. Processing it,
  carry a growing context: after binding field *j*, field *j+1*'s type is
  elaborated and evaluated with field *j*'s value in scope at de Bruijn index 0
  (params below it). The index that today must be a parameter becomes an ordinary
  preceding field; the record's *type* no longer has to name it.
- **QTT interaction (the one real subtlety):** a mention of an earlier field in a
  *later field's type* is an **erased use** — types do not survive to runtime, so
  referencing a `1`-quantity field inside a subsequent field's type costs nothing
  against its linear budget (identical to how `(1 x A) -> (B x)` mentions `x`
  erased in `B`). The field's runtime value still flows to the constructor
  exactly once. So a linear field may index a later field's type freely; no
  double-use, by the existing erasure discipline.
- **What chirality makes impossible here:** an index divorced from the value it
  bounds (the C hole — `p`'s length untethered from `n`); and — deliberately —
  first-class projection/Σ smuggling intrinsic typing into the kernel (kept out,
  §6).

## 5. Chirality example (fleshed)

```chirality
(import "prelude")

; ---- WHAT E48 ENABLES: the index is an ordinary earlier field --------------
; Field 2's type (Pool n) mentions field 1's value n. Inside (Pool n), n is the
; immediately-preceding field: de Bruijn index 0 (params, if any, sit below).
(data PoolRec ()
  (pool-rec (n I64) (1 p (Pool n))))          ; <- field dependence: NEW

; ---- the workaround it retires (today's scaffold form) ---------------------
; n must be a TYPE PARAMETER, so the record's type is (PoolR n) and a caller
; must know n to name it. Same dependence, wrong home.
;   (data PoolR ((n I64)) (pool-r (1 pool (Pool n)) (1 fd Fd)))

; ---- WHAT THE CHECKER ACTUALLY NEEDS: nothing here (extrinsic, §2.3) --------
; A typing-context entry: plain product, no field's type mentions another's
; value. The dependence it CHECKS lives in `Term` DATA (de Bruijn), not in this
; record's fields.
(data Qty () (q0) (q1) (qw))
(data CtxEntry () (ctx-entry (q Qty) (ty Term)))     ; flat — no telescope owed
; a constructor's field list, as the checker REPRESENTS it: a telescope VALUE,
; an ordinary list of (quantity, type-term) — dependence encoded in the indices
; of the Terms, checked by a fold that extends a context (the Python
; `_ctor_field_types` loop, ported):
(declare Term (type 0))                              ; the object term sum (E13/E3)
(data FieldT () (field-t (q Qty) (ty Term)))
;   telescope = (List FieldT)   — plain data over Term; NO chirality field-dependence
```

- **Knobs to modify:** how deep the dependence chain runs (field 3 may index
  fields 1 and 2); whether a param telescope and a field telescope coexist in one
  decl (they compose — params sit below fields in the context).
- **Deliberately omitted:** first-class **Σ-types and projections** (`fst`/`snd`
  over a dependent pair as a standalone type former) — a separate feature,
  deferred; and **induction-recursion / intrinsic syntax**, which chirality's
  extrinsic checker deliberately never adopts.

## 6. Use / modify notes

- **Lands in:** `scaffold/chirality/data.py` `_ctor_field_types` — thread a growing
  `env`: after judging field *i*, push a fresh `("Var", level)` (or the field's
  value under substitution) so field *i+1* evaluates its type with earlier fields
  in scope; the de Bruijn bookkeeping mirrors the Pi codomain in `kernel.py`. The
  positivity (`_positivity`) and coverage walks must walk field types under the
  same extended context. `_infer_ctor_params` (`data.py:166`) already indexes
  params at `nparams-1-p`; field indices sit above that and compose.
- **Conformance target:** `PoolRec` above type-checks and its `pool-rec` behaves
  identically to the parameterized `PoolR` (same runtime rep, same linear
  discipline, same bound-verification at the crossing) — differential against the
  param form; plus a negative test: a later field indexing a *non-existent* or
  wrongly-typed earlier field is rejected at declaration.
- **Open questions:** whether the elaborator *infers* a field telescope or
  requires the dependence be written (annotation-first is the conservative
  start); the QTT rule for a field that is *both* linear AND indexed by a later
  type (erased-use argument above says fine — confirm against `is_linear`
  ordering); and the standing scope line — first-class Σ/projection stays
  deferred until a concrete rung-1 consumer forces it (none found in the checker).
- **Related:** [[E13-debruijn]] (the shift discipline reused), [[E06-data-ctors-coverage]]
  (the walks that must respect the extended context), [[E07-strict-positivity]]
  (positivity under the telescope), [[E09-refinement]] (the subset-Σ the checker
  actually uses), [[E52-certificate-split]] (extrinsic/de-Bruijn checker — why
  self-host needs neither this nor Σ), [[E50-mutual-lexicographic]] /
  [[E47-sized-types]] (the sibling self-applicability features).
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.