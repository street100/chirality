---
element: E04
slug: bidir-universes
title: Bidirectional infer/check + universes/cumulativity
kind: SELF-HOST
reference_class: PAPER/IMPL
ours_source: scaffold/chirality/kernel.py
status: drafted
updated: 2026-07-13
---

# E04 — Bidirectional infer/check + universes/cumulativity

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E04, the trusted judgment core — bidirectional `infer`/`check`
  with QTT usage vectors, plus `subtype` implementing universe cumulativity
  (`Type l <= Type l'` when `l <= l'`).
- **Kind:** SELF-HOST.
- **Why chirality needs its own:** this is `kernel.py`'s `infer`/`check`/`subtype`
  — the center of the TCB. Every other L1 element (QTT semiring, refinement,
  membrane rules, data) is a seam *into* these three functions. Rewriting the
  judgment in chirality is the shrink-the-TCB move: the checker becomes Category-A
  typed code checked by itself, and its error and effect behavior become facts
  in its own signatures.

## 2. Research

- **Reference class:** PAPER/IMPL — Dunfield–Krishnaswami (bidirectional typing
  survey), ATTAPL; pi-forall and Idris2 as implementations; grounded in the
  OURS docstring of `scaffold/chirality/kernel.py`.
- **Key findings:**
  1. **The mode split** (Dunfield–Krishnaswami): elimination forms and
     annotated terms *infer* (synthesize); introduction forms (`lam`) *check*
     against an expected type. The annotation `(the T e)` is the only mode
     switch, and subsumption (conversion/subtyping) happens at exactly one
     place — the infer→check boundary. This keeps the algorithm syntax-directed
     and the TCB small.
  2. **Cumulativity is local to `subtype`** (ATTAPL; OURS `subtype`): the whole
     universe hierarchy story reduces to one rule, `VType l <= VType l'` iff
     `l <= l'`, falling through to conversion otherwise. Everything else (Pi
     formation taking `max l1 l2`, `Type l : Type (l+1)`) lives in `infer`.
  3. **QTT resource counting** (Atkey; Idris2 kernel): judgments return usage
     vectors, not booleans — `infer : ctx × term → (type, usage)`, `check :
     ctx × term × type → usage`. A variable use is a one-hot vector; application
     combines as `u_f + q·u_a`; binders strip and audit their own entry. The
     semiring itself is E05's element; here it is consumed.
  4. **Types are values (NbE)** (pi-forall, Idris2, OURS): `infer` returns
     evaluated `Val`s, comparison is conversion of quoted normal forms at a de
     Bruijn level, and `check` on `Lam` re-enforces the binder discipline
     because a `VPi` can arrive from type-level computation without ever
     passing formation (OURS: the "type-level Pi smuggle" audit note).

## 3. Conventional (other-language) approach

The OURS Python (`scaffold/chirality/kernel.py`) — string-tagged tuples, exceptions
for the error path, mutable usage lists:

```python
def infer(sig, ctx, t, allow_eff):
    """Returns (type_value, usage_vector)."""
    k = t[0]
    if k == "Var":
        name, q, tyv = ctx.lookup(t[1])
        u = uzero(len(ctx))
        u[len(ctx) - 1 - t[1]] = 1          # mutate a one-hot in place
        return tyv, u
    ...
    raise KernelError(f"unknown global {t[1]}")   # error = control flow

def subtype(sig, lvl, a, b):
    if a[0] == "VType" and b[0] == "VType":
        return a[1] <= b[1]                 # cumulativity, one line
    ...
    return conv(sig, lvl, a, b)
```

- **Assumptions it bakes in:** exceptions as the rejection path (the signature
  says nothing about failure); partiality — nothing bounds the recursion of
  `infer`/`conv`, CPython's stack is the trust anchor; mutable usage vectors
  updated in place; string tags dispatched with no coverage check (a typo'd
  tag falls off the end silently); ambient allocation throughout; and the
  checker *could* do I/O mid-judgment — nothing in Python's types forbids it.

## 4. The chirality idea

- **Chirality features in play:** errors-as-values (result sums), totality
  (structural recursion on `Term`), the `->`/`=>` membrane, QTT usage vectors
  as immutable data, refinement (`(refine I64 (>= 0))` for universe levels),
  `data`+`case` coverage checking.
- **The reframing:** the judgment becomes a *pure total function over a closed
  sum*. Rejection is a constructor (`tc-err`), so every caller is forced by
  coverage checking to handle it — the error path is in the signature.
  `infer`/`check` are structurally recursive on the `Term` tree, so the
  checker itself is total where the algorithm is; the one genuinely
  non-structural part (conversion under evaluation) is quarantined behind
  `conv`'s declared signature. Every arrow in the kernel is `->`: type
  checking provably touches no port. Usage vectors are values combined by
  E05's semiring ops, never mutated. Term formers are one `data` — an
  unhandled former is a compile error, not a silent fall-through.
- **What chirality makes impossible here:** a checker that throws (no exceptions
  exist); a checker that performs I/O or reads ambient state mid-judgment
  (`->` forbids it); a missed term-former case (exhaustiveness); a negative
  universe level (`refine`); silently dropping or double-counting a usage
  entry by aliasing a mutable list.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")

; ---------------------------------------------------------------- syntax
; Universe levels are refined I64s: no negative universes representable.
; Lvl abbreviates (refine I64 (>= 0)) at each use site below.

(data Qty ()                      ; E05's semiring, consumed here
  (q-zero)                        ; erased
  (q-one)                         ; linear
  (q-many))                       ; unrestricted

(data Term ()                     ; de Bruijn indices
  (t-var  (ix I64))
  (t-type (lvl I64))                     ; level >= 0 is an invariant (refined form awaits E9 arith refinements)
  (t-pi   (q Qty) (eff Bool) (dom Term) (cod Term))  ; eff: -> vs => of the CHECKED arrow
  (t-lam  (q Qty) (body Term))
  (t-app  (fn Term) (arg Term))
  (t-ann  (tm Term) (ty Term)))   ; (the ty tm) — the one mode switch

(data Clos () (clos (env (List Val)) (body Term)))

(data Val ()                      ; types are values (NbE)
  (v-type (lvl I64))
  (v-pi   (q Qty) (eff Bool) (dom Val) (cod Clos))
  (v-lam  (q Qty) (body Clos))
  (v-ne   (head I64) (sp (List Val))))   ; neutral: de Bruijn level + spine

(data Ctx () (ctx-nil) (ctx-bind (q Qty) (ty Val) (rest Ctx)))

; errors are values: rejection is a constructor, never a throw
(data TcR ()                      ; result of infer
  (tc-ok  (ty Val) (use (List Qty)))
  (tc-err (msg Str)))
(data CkR ()                      ; result of check
  (ck-ok  (use (List Qty)))
  (ck-err (msg Str)))

; ------------------------------------------------------- declared seams
; NbE + usage ops: separate elements, consumed by signature only.
(declare eval    (-> (List Val) Term Val))            ; E-nbe
(declare capply  (-> Clos Val Val))                   ; close_apply
(declare conv    (-> I64 Val Val Bool))               ; quote+compare at level
(declare u-zero  (-> I64 (List Qty)))                 ; E05
(declare u-one   (-> I64 I64 (List Qty)))             ; one-hot at ix
(declare u-add   (-> (List Qty) (List Qty) (List Qty)))
(declare u-scale (-> Qty (List Qty) (List Qty)))
(declare ctx-len    (-> Ctx I64))
(declare ctx-lookup (-> Ctx I64 TcR))                 ; tc-ok reuses (ty,use)
(declare max-lvl    (-> I64 I64 I64))
(declare strip-binder (-> (List Qty) Qty CkR))        ; audit + drop own entry
(declare env-of       (-> Ctx (List Val)))            ; the evaluation env of a ctx
(declare ck-err-to-tc (-> Str TcR))                   ; lift a check error into infer's result
; infer / check / subsume are one mutual group -> all declared before any def
(declare infer   (-> Ctx Term TcR))
(declare check   (-> Ctx Term Val CkR))
(declare subsume (-> Ctx Term Val CkR))

; --------------------------------------------------------------- subtype
; Conversion plus universe cumulativity. The ENTIRE hierarchy story is the
; v-type/v-type case; refinement forgetting (E09) hooks here later.
(declare subtype (-> I64 Val Val Bool))
(def subtype
  (lam (lvl a b)
    (case a
      ((v-type la)
        (case b
          ((v-type lb) (<=i la lb))       ; Type la <= Type lb  iff  la <= lb
          ((v-pi q e d c) (conv lvl a b))
          ((v-lam q c)    (conv lvl a b))
          ((v-ne h sp)    (conv lvl a b))))
      (_ (conv lvl a b)))))              ; all other formers fall through to conversion

; ----------------------------------------------------------------- infer
; Elimination forms + annotations synthesize. Structural recursion on Term.
(def infer
  (lam (c t)
    (case t
      ((t-var ix) (ctx-lookup c ix))      ; one-hot usage built by lookup

      ((t-type l)                         ; Type l : Type (l+1)
        (tc-ok (v-type (+ l 1)) (u-zero (ctx-len c))))

      ((t-pi q e dom cod)                 ; formation: max of the two levels
        (case (infer c dom)
          ((tc-err m) (tc-err m))
          ((tc-ok dty du)
            ; require dty = v-type l1; bind dom, infer cod under it,
            ; require v-type l2; result (v-type (max-lvl l1 l2)).
            ; membrane rule on-binder(q, dom) consults `e` here.  ; …
            (tc-err "elided"))))

      ((t-ann tm ty)                      ; THE mode switch: check ty is a
        (case (infer c ty)                ; type, eval it, flip to check
          ((tc-err m) (tc-err m))
          ((tc-ok tyty tu)
            ; require tyty = v-type _; (let ((want (eval (env-of c) ty)))
            ;   (case (check c tm want) ...)) → tc-ok want use   ; …
            (tc-err "elided"))))

      ((t-app f a)
        (case (infer c f)
          ((tc-err m) (tc-err m))
          ((tc-ok fty fu)
            (case fty
              ((v-pi q e dom cod)
                (case (check c a dom)
                  ((ck-err m) (ck-err-to-tc m))
                  ((ck-ok au)             ; usage: u_f + q·u_a — QTT app rule
                    (tc-ok (capply cod (eval (env-of c) a))
                           (u-add fu (u-scale q au))))))
              (_ (tc-err "cannot apply a non-function"))))))   ; non-Pi head

      ((t-lam q body)                     ; intro form: cannot synthesize
        (tc-err "un-annotated lambda: use (the T ...)")))))

; ----------------------------------------------------------------- check
; Intro forms check; everything else infers then subsumes — subtyping is
; consulted at exactly this one boundary.
(def check
  (lam (c t want)
    (case t
      ((t-lam q body)
        (case want
          ((v-pi qp e dom cod)
            ; re-enforce binder discipline HERE too (type-level Pi smuggle):
            ; on-binder(qp, dom); bind a fresh neutral at level (ctx-len c);
            ; check body against (capply cod fresh); strip-binder own usage. ; …
            (ck-err "elided"))
          (_ (ck-err "lambda checked against a non-function type"))))
      ; mode switch: infer, then subsume
      ((t-var ix)      (subsume c t want))
      ((t-type l)      (subsume c t want))
      ((t-pi q e d k)  (subsume c t want))
      ((t-app f a)     (subsume c t want))
      ((t-ann tm ty)   (subsume c t want)))))

(def subsume
  (lam (c t want)
    (case (infer c t)
      ((tc-err m) (ck-err m))
      ((tc-ok got use)
        (case (subtype (ctx-len c) got want)
          (true  (ck-ok use))
          (false (ck-err "type mismatch")))))))  ; pretty-print via E-pretty, not here
```

- **Knobs to modify:** the `Term`/`Val` sums grow via the data seam (E-data
  adds `t-con`/`t-case` handlers rather than editing these functions); the
  membrane rules (`on-binder`, erased-position allowance) plug at the two
  commented seam points; `subtype` gains refinement hooks (E09) as extra
  cases before the `conv` fallthrough; `eff` on `t-pi` is where the checked
  language's `->` vs `=>` distinction is threaded to application.
- **Deliberately omitted:** `eval`/`capply`/`conv` bodies (NbE is its own
  element); the usage-semiring op bodies (E05); `let`, globals, prims,
  literals; the effect-allowance parameter (`allow_eff`) threading; error
  message pretty-printing (display is not judgment — separate module).

## 6. Use / modify notes

- **Lands in:** `lib/kernel.chiral` (the chirality-in-chirality judgment core),
  shadowing `scaffold/chirality/kernel.py`'s `infer`/`check`/`subtype`. The
  Python stays as the bootstrap referent until conformance passes.
- **Conformance target:** golden behavior of `scaffold/chirality/kernel.py` —
  identical accept/reject decisions AND identical usage vectors on the
  existing kernel test corpus, including: `Type l : Type (l+1)`, cumulative
  acceptance `Type 0 <= Type 1`, rejection of un-annotated lambdas in infer
  mode, the QTT application usage `u_f + q·u_a`, and the type-level-Pi-smuggle
  audit case (lambda checked against a computed `VPi` still hits the binder
  rule).
- **Open questions:** (1) totality of `conv` — conversion under evaluation is
  not structurally decreasing on any argument; does it take a fuel measure, or
  is the NbE element granted a trusted-total marking (Category C)? (2) how the
  `sig` seam table (ext-check hooks, subtype hooks, membrane rules) is
  represented in chirality — a record of function values vs. compile-time module
  wiring; (3) whether `ck-err-to-tc` style result-sum plumbing wants a shared
  polymorphic result type instead of `TcR`/`CkR` twins.
- **Related:** [[E05]] (QTT semiring — `u-add`/`u-scale`/`strip-binder`
  consumed here), [[E09]] (refinement — subtype hooks), the NbE
  `eval`/`quote`/`conv` element, and E-data (term-former handler seams).
