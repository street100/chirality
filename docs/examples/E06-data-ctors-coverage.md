---
element: E06
slug: data-ctors-coverage
title: Data: constructors, case coverage, ctor-param unification (`_infer_ctor_params`)
kind: SELF-HOST
reference_class: PAPER/IMPL
ours_source: scaffold/chirality/data.py
status: drafted
updated: 2026-07-13
---

# E06 — Data: constructors, case coverage, ctor-param unification (`_infer_ctor_params`)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E06, the data-type layer of the checker — parametric `data`
  declarations, constructor checking, exhaustive-`case` coverage, and the
  bounded solver that infers a constructor's type parameters from its value
  arguments (`_infer_ctor_params`), so `(cons 3 nil)` needs no `(the (List I64) …)`.
- **Kind:** SELF-HOST — Python `scaffold/chirality/data.py` (738 lines) that must
  become chirality source.
- **Why chirality needs its own:** this module *is* the sum-type judgment — the
  kernel does not know what a constructor is; `data.py` owns TCon/Con/Case and
  their check/eval handlers. Everything downstream (result sums, `case` state
  machines, E7 positivity, E8 linear-kind) judges *through* this code, so it is
  squarely inside the TCB that self-hosting must shrink.

## 2. Research

- **Reference class:** PAPER/IMPL — pattern-coverage as in Idris/GHC
  exhaustiveness checking; first-order unification literature for the
  parameter solver; grounded in the OURS docstrings in `data.py`.
- **Key findings:**
  1. **Coverage is a closed-sum count, not SAT.** With flat, one-level
     patterns (ours), exhaustiveness reduces to: every declared ctor matched
     exactly once, no unknown ctor names — the degenerate, decidable core of
     the GHC/Idris coverage problem. Depth-1 patterns keep it linear in
     `|ctors| × |branches|`.
  2. **The solver is deliberately NOT full unification.** `_infer_ctor_params`
     solves a parameter only where a field's type is *exactly* that parameter
     (a bare `Var` occurrence); the p-th parameter sits at de Bruijn index
     `nparams-1-p` inside a field type. No occurs-check, no substitution
     composition — a bounded pattern that avoids the whole Robinson machinery.
  3. **Sound-by-recheck.** The solved tuple is only a *candidate*:
     `_check_con` re-checks every argument against the instantiated field
     types, so a bad guess is caught there, not trusted here. Inference and
     judgment stay separated — the recheck is the proof.
  4. **Coverage runs against declaration order** (`_check_case` walks
     `decl.ctors` from the scrutinee's `VTCon`), and a non-data scrutinee is
     rejected before any branch is examined.

## 3. Conventional (other-language) approach

The OURS Python: coverage as a mutable `set` accumulated in a loop, and the
parameter solver as a try/except probe around inference.

```python
def _infer_ctor_params(sig, ctx, decl, cname, args, allow_eff):
    fields = decl.ctors.get(cname)
    if fields is None or len(args) != len(fields):
        return None                       # partiality: None-as-failure
    nparams = len(decl.params)
    solved = [None] * nparams             # hidden mutation
    for arg, (q, fname, fty) in zip(args, fields):
        if fty[0] != "Var":
            continue
        p = nparams - 1 - fty[1]
        if 0 <= p < nparams and solved[p] is None:
            try:
                solved[p] = K.infer(sig, ctx, arg, allow_eff)[0]
            except KernelError:           # exceptions as control flow
                pass
```

- **Assumptions it bakes in:** exceptions as control flow (`except KernelError:
  pass` silently swallows a failed probe); `None` overloaded to mean three
  different failures (unknown ctor, arity mismatch, unsolved parameter);
  in-place mutation of `solved`; unbounded `for`/`zip` with no termination
  evidence; duck-typed term tuples (`fty[0] != "Var"`) with no proof the tag
  set is closed.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** closed sums + exhaustive `case` (the feature is
  implemented *in terms of itself*), errors-as-values result sums, totality by
  structural recursion, QTT-erased helpers, `->` throughout (checking is pure —
  a judgment that could do I/O would be a broken judgment).
- **The reframing:** every implicit Python convention becomes a datatype. The
  three meanings of `None` split into named ctors of a result sum; the
  mutable `solved` list becomes a `(List OptTy)` accumulator threaded through
  structural recursion; the try/except probe disappears because inference
  itself returns a sum, so a failed probe is just an `o-none` in the input.
  Coverage checking of the *object* language is written with an exhaustive
  `case` of the *host* language — so when a ctor is added to `Ty` or `CovR`,
  the checker's own checker forces every judgment to handle it.
- **What chirality makes impossible here:** a silently swallowed inference error
  (no exceptions exist to swallow); a coverage checker that itself forgets a
  ctor (the meta-level `case` is coverage-checked); a solver loop that doesn't
  terminate (structural recursion on the field list); an "I checked it"
  boolean with no evidence of *which* failure occurred (the result sum carries
  the offending ctor name).

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")

;; What E06 buys the user, in one line: an unannotated ctor application
;;   (cons 3 nil)          ; checks as (List I64) with no (the ...) ascription
;; Below is the self-hosted judgment that makes that work.

;; ---- object-language types (what the checker judges) ---------------------
;; De Bruijn: the p-th data parameter appears inside a field type as
;; (ty-var (- (- nparams 1) p)) — the same arithmetic as the Python.
(data Ty ()
  (ty-var (ix I64))                        ; bound type parameter, de Bruijn
  (ty-con (name Str) (args (List Ty)))     ; applied data type, e.g. (List I64)
  (ty-i64))                                ; base type (skeleton keeps one)

(data Field ()
  (field (q I64) (fname Str) (fty Ty)))    ; QTT quantity travels with the field

(data Ctor ()
  (ctor (cname Str) (fields (List Field))))

(data DataDecl ()
  (data-decl (dname Str) (nparams I64) (ctors (List Ctor))))

;; ---- results are sums, not None/exceptions --------------------------------
(data OptTy () (o-none) (o-some (t Ty)))   ; a maybe-solved parameter slot

(data CovR ()                              ; case-coverage verdict
  (cov-ok)
  (cov-missing (cname Str))                ; declared ctor with no branch
  (cov-dup     (cname Str))                ; same ctor matched twice
  (cov-unknown (cname Str)))               ; branch names a ctor not in the decl

(data SolveR ()                            ; ctor-param solver verdict
  (sv-solved (params (List Ty)))           ; a CANDIDATE — check-con rechecks it
  (sv-unsolved (p I64))                    ; parameter p has no bare occurrence
  (sv-arity))                              ; args/fields length mismatch

;; ---- declared helpers (spine defined below; bodies elided or obvious) -----
(declare str=      (-> Str Str Bool))                ; via str-eq; …
(declare opt-init  (-> I64 (List OptTy)))            ; n copies of (o-none)
(declare opt-set1  (-> (List OptTy) I64 Ty (List OptTy)))  ; set slot iff o-none
(declare ctor-names (-> (List Ctor) (List Str)))
(declare len       (-> (0 A (type 0)) (List A) I64)) ; list length (type arg explicit)

;; ---- case coverage: every declared ctor exactly once ----------------------
(declare count-name (-> Str (List Str) I64))
(def count-name
  (lam (want names)
    (case names
      (nil 0)
      ((cons n rest)
        (case (str= want n)
          (true  (+ 1 (count-name want rest)))
          (false (count-name want rest)))))))

(declare cov-unknowns (-> (List Str) (List Str) CovR))  ; branches vs declared; …
(declare cov-go (-> (List Ctor) (List Str) (List Str) CovR))  ; forward-declared: check-coverage calls it

(declare check-coverage (-> DataDecl (List Str) CovR))
(def check-coverage
  (lam (decl branch-names)
    (case decl
      ((data-decl dname nparams ctors)
        (cov-go ctors branch-names (ctor-names ctors))))))

(def cov-go
  (lam (ctors branch-names declared)
    (case ctors
      (nil (cov-unknowns branch-names declared))   ; leftover unknown branches?
      ((cons c rest)
        (case c
          ((ctor cname fields)
            (let ((k (count-name cname branch-names)))
              (case (=i k 0)
                (true (cov-missing cname))
                (false (case (<i 1 k)
                         (true (cov-dup cname))
                         (false (cov-go rest branch-names declared))))))))))))

;; ---- ctor-param solver: bounded, sound-by-recheck --------------------------
;; A parameter is solved ONLY where a field's type is exactly that parameter
;; (a bare ty-var). Returns p, or -1 when the field type is anything else.
(declare bare-param (-> I64 Ty I64))
(def bare-param
  (lam (nparams fty)
    (case fty
      ((ty-var ix)
        (let ((p (- (- nparams 1) ix)))
          (case (and (<=i 0 p) (<i p nparams))
            (true p)
            (false -1))))
      ((ty-con name args) -1)
      (ty-i64 -1))))

;; argtys: the CALLER-inferred type of each value argument, (o-none) where
;; inference failed — the Python's try/except probe, as a value.
(declare solve-go
  (-> I64 (List Field) (List OptTy) (List OptTy) (List OptTy)))
(def solve-go
  (lam (nparams fields argtys acc)
    (case fields
      (nil acc)
      ((cons f frest)
        (case argtys
          (nil acc)                              ; lengths pre-checked; inert
          ((cons aty arest)
            (case f
              ((field q fname fty)
                (let ((p (bare-param nparams fty)))
                  (case aty
                    (o-none (solve-go nparams frest arest acc))
                    ((o-some t)
                      (case (<i p 0)
                        (true (solve-go nparams frest arest acc))
                        (false (solve-go nparams frest arest
                                         (opt-set1 acc p t)))))))))))))))

(declare finish (-> (List OptTy) SolveR))        ; all o-some -> sv-solved; …

(declare infer-ctor-params (-> I64 (List Field) (List OptTy) SolveR))
(def infer-ctor-params
  (lam (nparams fields argtys)
    (case (=i (len Field fields) (len OptTy argtys))   ; arity gate up front, named
      (true (finish (solve-go nparams fields argtys (opt-init nparams))))
      (false sv-arity))))

;; check-con (not shown) re-checks every argument against the instantiated
;; field types of an (sv-solved …) candidate — a bad guess dies THERE.
```

- **Knobs to modify:** the `Ty` grammar (add `ty-arrow`, refinements) — each
  addition forces `bare-param`'s `case` to grow, by construction; the solver's
  bound (extend beyond bare occurrences to matching under `ty-con` args, still
  sound-by-recheck); `CovR`/`SolveR` payloads (add source positions); whether
  `cov-go` short-circuits at the first failure (as here) or accumulates a list
  of all failures.
- **Deliberately omitted:** the recheck pass itself (`check-con` — it is the
  ordinary checking judgment applied to the candidate); default/wildcard
  branches (the Python `_check_case` carries a `default`; coverage with a
  default is a strictly weaker check); evaluation handlers for Con/Case; the
  linear-kind contribution (that is E8); mechanical bodies of the declared
  helpers (`str=`, `opt-set1`, `finish`, `cov-unknowns`).

## 6. Use / modify notes

- **Lands in:** the self-hosted checker stack — the chirality-in-chirality successor to
  `scaffold/chirality/data.py` (alongside the E-series kernel port), with the
  `Ty`/`DataDecl` grammar shared with the rest of the checker.
- **Conformance target:** the same accept/reject set as `data.py` on the golden
  suite — specifically: (a) `_check_case` behavior — non-data scrutinee
  rejected, missing/duplicate/unknown ctor branches rejected with the ctor
  named; (b) `_infer_ctor_params` behavior — `(cons n nil)`-style applications
  check unannotated, arity mismatch and unsolved parameters fall back to
  "annotation required", and a wrong candidate is rejected by the recheck,
  never trusted.
- **Open questions:** surface semantics of the default branch (does a default
  suppress `cov-missing`, and is that allowed in the self-hosted core?);
  telescoped parameters (Python's `decl.params` are binders each under earlier
  params — the skeleton flattens to `nparams I64`; the real port must keep the
  telescope for dependent parameters); how the scrutinee's QTT usage (`us` from
  `K.infer`) threads through branch checking; whether coverage should
  accumulate all failures for better diagnostics.
- **Related:** [[E06-data-ctors-coverage]] — feeds [[E07]] (strict positivity
  walks the same `DataDecl`), [[E08]] (linear-kind of a data type reads the
  same field quantities), and the result-sum discipline every `lib/*.chiral`
  parser already uses.
