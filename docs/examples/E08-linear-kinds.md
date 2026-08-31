---
element: E08
slug: linear-kinds
title: Linear-kind decision for data (`_linear_data`, bounded abstract walk)
kind: SELF-HOST
reference_class: PAPER
ours_source: scaffold/chirality/data.py
status: drafted
updated: 2026-07-22
---

# E08 — Linear-kind decision for data (`_linear_data`, bounded abstract walk)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E08, the judgment "is this *type* linear?" — decision-b-in-type
  made mechanical: a porttype, and any data type **transitively** holding one,
  may only be bound or held at quantity 1. Concrete shapes are judged at
  declaration; parametric ones at every instantiation, including through type
  parameters — a generic container cannot smuggle a port at ω, and a
  port-carrying shape needs its own declaration with 1-fields (the `RecvR`
  precedent).
- **Kind:** SELF-HOST — checker-stack Python (`data.py` `_linear_data` +
  `kernel.py` `is_linear`) that must become chirality source.
- **Why chirality needs its own:** this walk is one leg of capability
  non-forgeability (the linear-kind leg). It is trusted judgment; the TCB does
  not shrink until it is chirality, checked by chirality.

## 2. Research

- **Reference class:** PAPER (QTT / linear-logic kinds — linearity as a
  *kind-level property of types*, not a per-value annotation) over the OURS
  baseline (`data.py:_linear_data`, `kernel.py:is_linear`).
- **Key findings:**
  1. **Two-level seam architecture.** The kernel knows only declared atom flags
     (`porttype` → `linear=True`), a cached set of already-judged data names
     (`sig.linear_data`), and a hook list; the *composite* judgment lives in the
     data module and registers as a hook (`kernel.py:207–217`). The kernel never
     learns what a constructor is — the same discipline that keeps effects and
     refinement out of the kernel.
  2. **The walk.** A `VTCon` is linear iff some constructor field is declared
     `q=1`, or some field *type* is itself linear (recursive descent). Cycles
     are cut by a seen-set; non-uniform nesting is cut by a **depth bound**
     (`_LINEAR_ABSTRACT_DEPTH`); an un-evaluable field type (depends on a
     parameter) is skipped at declaration. Every cut is a **deferral, never an
     admission**: the walk may under-claim at declaration, and the
     instantiation-time re-judgment closes the hole.
  3. **The consumer seam.** `effects.py` `on_binder` rejects any binder holding
     a linear type at `q ≠ 1`; `on_apply` re-judges the *instantiated*
     parameter where the Pi's domain was a type variable — the
     polymorphic-smuggle closure. `(List A)` at `A := Sock` is judged at the
     application, where `A` is known.
  4. **Boundary (session-settled — state it plainly): shapes, not captures.**
     This walk sees *data shapes*. A closure over a linear port has an ordinary
     arrow type recording nothing about its capture — deliberately outside this
     judgment, covered instead by bind/apply-site usage accounting (the E39
     sharpening; its floor twin is E69's environment-cell typing,
     EDGE-CANDIDATES C3). An arrow type is simply "not linear" to this walk.

## 3. Conventional (other-language) approach

The OURS baseline is a recursive boolean walk keyed by a CPython trick:

```python
def _linear_data(sig, tyv, seen):
    if tyv[0] != "VTCon": return False
    key = (tyv[1], repr(tyv[2]))          # seen-key: name + repr() of args (!)
    if key in seen: return False          # cycle: nothing new
    if len(seen) >= _LINEAR_ABSTRACT_DEPTH:
        return False                      # non-uniform nesting: defer
    seen.add(key)
    env = list(tyv[2])
    for cname, fields in sig.data[tyv[1]].ctors.items():
        for (q, fname, fty) in fields:
            if q == 1: return True        # a declared 1-field
            try:
                if K.is_linear(sig, K.eval_term(sig, env, fty), seen):
                    return True           # or a field whose TYPE is linear
            except KernelError:
                pass                      # un-evaluable field: judged at instantiation
    return False
```

The nearest named-language shape is Rust's **auto-trait propagation**
(`Send`/`Sync`): a marker property inferred structurally through fields. But it
gates *thread movement*, not use-count; Rust ownership is **affine** (silent
drop is legal), and monomorphization means Rust never needs an
instantiation-time re-judgment seam.

- **Assumptions it bakes in:** affinity-not-linearity ("forgot to close"
  type-checks elsewhere); `repr()` as the seen-set canonicalizer — a borrowed
  CPython semantics exactly of the class trust-boundary warns about;
  try/except as the un-evaluable-field escape; and, in every mainstream
  system, **no propagation of must-consume-exactly-once through type
  parameters at all**.

## 4. The chirality idea

- **Chirality features in play:** QTT quantities (a field's `1` *is* the linearity
  declaration); data + `case` + structural recursion (the walk is a total fold
  over first-order type syntax); totality (the depth bound is fuel — the walk
  proves its own termination); result sums (deferral as a value, not an
  exception).
- **The reframing:** linearity is a *kind-level fact computed by a total, pure,
  first-order function over type values* — ideal self-host material, because
  the types being judged are just data to the judge. Deferral becomes an
  explicit third result instead of a collapsed `False` plus a re-judgment
  convention held in comments.
- **What chirality makes impossible here:** a generic container holding a port
  (`(List Sock)` dies at the instantiation seam); a port-carrying shape bound
  or copied at ω anywhere; the walk's own undecided case being silently
  dropped (it is a constructor the caller must `case` on).

## 5. Chirality example (fleshed)

```chirality
(import "prelude")
(import "collections")

; ---- first-order view of type values, as the walk sees them --------------
(data TyV ()
  (tv-atom  (name Str) (lin Bool))        ; porttype atoms carry their flag
  (tv-tcon  (name Str) (args (List TyV))) ; declared data applied to args
  (tv-arrow)                              ; closures: shapes-not-captures --
  (tv-other))                             ;   arrows are opaque to this walk

(data Field () (fld (q I64) (ty TyV)))
(data Decl  () (dcl (name Str) (fields (List Field)))) ; ctor fields, flattened

; ---- the result: deferral is a VALUE, not a collapsed False --------------
; (the Python collapses defer into False at declaration and re-judges at each
;  instantiation; keeping it explicit is the honest port)
(data LinR () (lin-yes) (lin-no) (lin-defer))

(declare seen-has    (-> (List Str) Str Bool))
(declare ctor-fields (-> (List Decl) Str (List TyV) (List Field)))
; … assoc-list walks over decls, substituting args into field types ; …

; linear-ty and fields-lin are mutually recursive -> both forward-declared here
; (the json.chiral declare-then-define idiom for a recursion group).
(declare linear-ty  (-> (List Decl) (List Str) I64 TyV LinR))
(declare fields-lin (-> (List Decl) (List Str) I64 (List Field) LinR))

; ---- the bounded abstract walk -------------------------------------------
; Total by construction: fuel strictly decreases on descent, the seen list
; cuts cycles, and exhaustion is lin-defer -- never a silent admission.
(def linear-ty        ; type from the declare above
  (lam (decls seen fuel ty)
    (case ty
      ((tv-atom name lin) (cond (lin lin-yes) (else lin-no)))
      ((tv-arrow)         lin-no)   ; capture linearity = bind-site accounting
      ((tv-other)         lin-no)
      ((tv-tcon name args)
       (cond ((<=i fuel 0)         lin-defer)
             ((seen-has seen name) lin-no)
             (else (fields-lin decls (cons name seen) (- fuel 1)
                               (ctor-fields decls name args))))))))

; fields-lin (forward-declared above): any declared 1-field => lin-yes; else
; recurse into each field's type; lin-defer joins sticky, so an undecided branch
; is never dropped. ; … structural fold: ((fld 1 _) …) -> lin-yes ; else join
; (linear-ty … ty) ; …

; ---- the precedent this enforces -----------------------------------------
; (data RecvR () (recv-r (bs Bytes) (1 sock Sock)))  ; linear BY THIS WALK
; (List Sock)  ; rejected at the instantiation seam: List's binder is w
```

- **Knobs to modify:** the fuel bound; three-valued `LinR` vs faithful
  boolean-plus-re-judgment; the seen-list key (the Python keys on
  name+args-`repr`, so the same tcon at different args re-walks — see open
  questions); whether a top-level `lin-defer` should record an
  instantiation-site obligation.
- **Deliberately omitted:** dependent field types (the un-evaluable branch —
  needs the evaluator seam, E15); hook-registration plumbing; the kernel's
  atom-flag fast path and `sig.linear_data` cache.

## 6. Use / modify notes

- **Lands in:** the self-hosted checker's types module (the chirality port of
  `data.py`), consumed by the membrane seams exactly where `on_binder` /
  `on_apply` sit today (E12).
- **Conformance target:** differential — agree with Python
  `is_linear`/`_linear_data` on every declaration in `lib/*.chiral` and every
  instantiation the test suite exercises (the linear-kind rejections in
  `test_kernel.py` are the oracle).
- **Open questions:** (1) **the seen-set key needs a canonical TyV equality** —
  the Python leans on `repr()` of the args vector, a borrowed CPython
  canonicalizer; the self-hosted walk needs a decidable canonical form (or
  ordering) for type values, and that choice belongs with the fixpoint's
  determinism debts, not just here. (2) Three-valued result vs boolean: making
  `lin-defer` explicit changes the consumer seam's contract — decide before
  the E12 port copies this. (3) Where instantiation-time re-judgment lives
  once the checker is chirality (the `on_apply` seam's port).
- **Related:** [[E06-data-ctors-coverage]] (the decl machinery this walks),
  [[E12-effect-membrane]] (the consumer seams), E39/E69 + EDGE-CANDIDATES C3
  (the capture half this walk deliberately does not cover),
  `docs/decision-b-in-type.md` (the rule this mechanizes).
