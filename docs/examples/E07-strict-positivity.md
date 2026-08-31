---
element: E07
slug: strict-positivity
title: Strict positivity / variance analysis (`_positivity`, `_compute_sp_params`)
kind: SELF-HOST
reference_class: PAPER/IMPL
ours_source: scaffold/chirality/data.py
status: drafted
updated: 2026-07-22
---

# E07 — Strict positivity / variance analysis (`_positivity`, `_compute_sp_params`)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E07, the strict-positivity check on data declarations — the walk
  that rejects a recursive occurrence in a negative position, plus the
  per-parameter variance cache that lets covariant containers carry recursion.
- **Kind:** SELF-HOST — `data.py`'s `_positivity` + `_compute_sp_params`
  become chirality source in the checker-stack port.
- **Why chirality needs its own:** this is one of the three totality pillars
  (positivity, coverage, termination). Positivity forecloses the diverging
  fixpoint a negative datatype encodes — a term that loops *with no recursion
  anywhere in it* — which would unsound the "total = safe to run early"
  license that pregen and precompute stand on (decision-graded-kernel, point
  2). The trusted judgment cannot borrow this from CPython forever; it is
  kernel-adjacent code and must shrink into the self-hosted TCB.

## 2. Research

- **Reference class:** PAPER/IMPL — Agda/Coq positivity checking as the idea
  lineage (Tier P: papers and behavior, not their kernels); `OURS` port source
  is `data.py:287–408`.
- **Key findings:**
  1. The check is **one walk, two targets**: `("name", D)` checks a
     declaration's own recursive occurrences; `("var", idx)` measures a
     *parameter's* variance. `_compute_sp_params` runs the same walk per
     parameter to fill the strictly-positive cache the first mode consults —
     one algorithm, reused, not two.
  2. The reject set (keep exactly): occurrence **left of any arrow at any
     nesting depth** ("a double negative is still refused"); **nested through
     a container parameter not known strictly positive**; **under a type-level
     application** or inside Lam/Let/Con/Case in a field type (variance
     unknown → conservative refusal); **as a nested non-uniform type argument
     of the head itself**.
  3. The allow set (keep exactly): a bare head occurrence (`D` or `(D p …)`
     with occurrence-free args); nesting **through a strictly-positive
     parameter** of an already-declared container (`(List D)` is fine because
     `List` was measured covariant at its own declaration).
  4. The self-reference convention: while walking `under`'s own fields,
     `sp_in(under, i) = True` — "the type under definition is positive in
     itself" — which is what breaks the regress for self-recursive shapes.
     An *unset* cache reads as refuse (`bool(sp)` is false), so
     declaration-order conservatism is a behavior, not an accident.

## 3. Conventional (other-language) approach

Haskell (and OCaml with `-rectypes`) accepts negative occurrences, and the
loop they encode needs no recursion:

```haskell
newtype Bad = Bad (Bad -> ())

loop :: Bad -> ()
loop b@(Bad f) = f b

diverge :: ()
diverge = loop (Bad loop)   -- no recursive definition anywhere; still loops
```

The OURS baseline does the right thing but in host-Python idiom — a mutable
`reason` cell for early exit, `getattr` cache probing, exceptions upstream:

```python
def walk(t, depth):
    if reason[0] is not None: return
    ...
    if k == "Pi":
        if mentions(t[4], depth):
            reason[0] = "to the left of a function arrow"; return
        walk(t[5], depth + 1)
```

- **Assumptions it bakes in:** Haskell/OCaml: that non-termination is an
  acceptable ambient effect, so the type system may admit types whose mere
  *inhabitants* diverge — exactly the exemption P2 forbids. The Python: hidden
  mutation for control flow, a cache probed via reflection (`getattr`), and a
  reason path that is a side channel rather than a value.

## 4. The chirality idea

- **Chirality features in play:** totality (this IS a pillar of it), errors as
  result-sum values, structural recursion, pure `->` throughout (the walk
  performs no crossings — empty row), the collections floor for the cache.
- **The reframing:** the check becomes a pure, total, structurally-recursive
  function from a field type to a verdict *value*. The mutable `reason` cell
  becomes result-sum threading (first error propagates by `case`). The
  variance cache becomes an ordinary assoc carried in the signature value —
  computed once at declaration, never mutated after (matches the D3
  staged-in discipline: signature state is fixed by staging, not patched
  live). Self-applicability is the point: the walk is itself structural on
  the term, so the self-hosted checker's own positivity code passes its own
  termination pillar — and `mentions`/`walk` are deliberately each
  self-recursive only (walk *calls* mentions, neither recurses into the
  other), so the port does not need E50 mutual recursion to type itself.
- **What chirality makes impossible here:** declaring `Bad` at all — the loop
  above is unwritable because its *type* is rejected at declaration; a
  positivity checker whose own termination is unproven; a cache that can
  drift from the declarations it summarizes (it is data in the staged
  signature, not a patched attribute).

## 5. Chirality example (fleshed)

```chirality
(import "prelude")
(import "collections")

; ---- the term rep this walks (owned by the checker port, E13/E3 ties) ----
; Minimal skeleton: the cases positivity distinguishes. de Bruijn indices.
(data Ty ()
  (ty-var  (i I64))
  (ty-pi   (dom Ty) (cod Ty))            ; binder: cod is depth+1
  (ty-tcon (name Str) (args (List Ty)))  ; declared datatype head + args
  (ty-app  (f Ty) (a Ty)))               ; type-level application
  ; … ty-lam / ty-let / ty-refine elided: mechanical, same shapes as data.py

; ---- verdicts are values --------------------------------------------------
(data PosR () (pos-ok) (pos-bad (reason Str)))

; what we are hunting: a datatype's own name, or a parameter's index
(data PTarget () (pt-name (d Str)) (pt-var (idx I64)))

; the sp cache: per declared datatype, its per-parameter strict positivity.
; An absent entry means "unknown" and unknown means refuse (conservative,
; declaration-order dependent — the OURS behavior, kept on purpose).
(data SP () (sp-yes) (sp-no))
; sig side: (List (Pair Str (List SP))) threaded as a value, computed at declare.
(declare DataDecl (type 0))   ; the real DataDecl is E6's; opaque here (compute-sp's arg)

; ---- is this node the target? (depth-shifted for pt-var) -----------------
(declare hit? (-> PTarget I64 Ty Bool))
(def hit?
  (lam (tgt depth t)
    (case tgt
      ((pt-name d) (case t ((ty-tcon n as) (str-eq n d)) (_ false)))
      ((pt-var ix) (case t ((ty-var i) (=i i (+ ix depth))) (_ false))))))

; ---- does the target occur anywhere below? -------------------------------
; Pure structural recursion; binder cases bump depth. ; … elided arms are
; mechanical mirrors of data.py's `mentions`.
(declare mentions? (-> PTarget I64 Ty Bool))
(def mentions?
  (lam (tgt depth t)
    (case (hit? tgt depth t)
      (true true)
      (false
        (case t
          ((ty-pi dom cod) (or (mentions? tgt depth dom)
                               (mentions? tgt (+ depth 1) cod)))
          ((ty-tcon n as)  (any-list Ty (lam (a) (mentions? tgt depth a)) as))
          ((ty-app f a)    (or (mentions? tgt depth f) (mentions? tgt depth a)))
          ((ty-var i)      false))))))
        ; … real Ty has more arms (ty-lam/ty-let/…); the 4-ctor skeleton is exhaustive here

; ---- the positivity walk --------------------------------------------------
; `under` = the datatype whose fields we are walking; sp-in treats it as
; positive in itself (breaks the self-recursive regress). First bad reason
; wins via result-sum threading — no mutation, no exceptions.
(declare sp-in (-> (List (Pair Str (List SP))) Str Str I64 Bool))  ; sig d under i
; … assoc lookup; (str-eq d under) => true; absent/short/sp-no => FALSE
(declare walk-args   ; forward-declared: walk calls it (mutual-recursion group by declaration)
  (-> (List (Pair Str (List SP))) Str PTarget I64 Str (List Ty) I64 PosR))

(declare walk (-> (List (Pair Str (List SP))) Str PTarget I64 Ty PosR))
(def walk
  (lam (sig under tgt depth t)
    (case (hit? tgt depth t)
      (true
        ; a bare head occurrence is strictly positive; but a nested
        ; occurrence inside the head's OWN args is non-uniform: refuse.
        (case t
          ((ty-tcon n as)
           (case (any-list Ty (lam (a) (mentions? tgt depth a)) as)
             (true (pos-bad "as a nested (non-uniform) type argument"))
             (false pos-ok)))
          (_ pos-ok)))
      (false
        (case t
          ((ty-pi dom cod)
           ; no occurrence anywhere in a domain, at any depth: that is the
           ; diverging-fixpoint door, and a double negative is still refused
           (case (mentions? tgt depth dom)
             (true (pos-bad "to the left of a function arrow"))
             (false (walk sig under tgt (+ depth 1) cod))))
          ((ty-tcon n as) (walk-args sig under tgt depth n as 0))
          ((ty-app f a)
           (case (mentions? tgt depth t)
             (true (pos-bad "under a type-level application (variance unknown)"))
             (false pos-ok)))
          ((ty-var i) pos-ok))))))
        ; … ty-lam/ty-let/ty-refine arms mirror data.py

; per-argument (walk-args, forward-declared above): an occurrence may route only
; through a strictly-positive parameter of an already-measured container, then be
; walked deeper. ; … cons-recursion: if (mentions? tgt depth a) then
;      if (sp-in sig n under i) => (walk sig under tgt depth a) else
;      (pos-bad "through a non-positive parameter") ; then next arg, i+1

; ---- variance measurement fills the cache at declaration ------------------
; For each param p (index (- (- nparams 1) p) inside field types), run the
; SAME walk with (pt-var idx) over every field of every ctor; all pos-ok
; => sp-yes. One algorithm, two targets — keep it that way in the port.
(declare compute-sp (-> (List (Pair Str (List SP))) DataDecl (List SP)))
; … loop over params via structural recursion on a countdown list; …
```

- **Knobs to modify:** the `Ty` skeleton (the real one is the E13/E3 port's
  term type — extend the arms, keep the depth discipline); the reason strings
  (observable behavior is accept/reject, wording is free); the cache rep
  (assoc now, a balanced map when E27 lands).
- **Deliberately omitted:** the mechanical `ty-lam`/`ty-let`/`ty-case` arms
  (`; …`, exact mirrors of `data.py`); the `check-data` caller that runs this
  per ctor field and folds `compute-sp` results into the signature; mutual
  datatype *families* (the under-convention covers self-recursion; a mutual
  family still conservatively refuses until declarations can be grouped —
  same as OURS today).

## 6. Use / modify notes

- **Lands in:** the self-hosted checker's types module (the chirality port of
  `data.py`), alongside constructor/coverage checking (E6); the cache lives
  in the staged signature value.
- **Conformance target:** differential against `data.py` on the settled
  behaviors — reject left-of-arrow (any depth), reject nested-through-
  non-sp-parameter, reject under type-level application, reject non-uniform
  nested head args; accept bare heads and covariant-container nesting
  (`(List D)`, `(Maybe D)`); unset cache refuses. The existing
  `tests/test_kernel.py` positivity cases are the oracle; accept/reject per
  declaration is the observable, not reason wording.
- **Open questions:** whether the port keeps the boolean per-param cache or
  widens to a variance lattice (co/contra/invariant) — the bool is enough for
  every container the checker itself needs (List, Maybe, pairs, assoc);
  widening is only owed if a genuinely contravariant-parameter container ever
  earns a seat. Whether mutual datatype families (declaration groups) arrive
  with E50-era work and how the under-convention generalizes to a group.
- **Related:** [[E11-totality-checker]] (sibling pillar; termination),
  [[E06-data-ctors-coverage]] (the module this lands beside),
  [[E13-debruijn]] / [[E03-nbe-normalize]] (the term rep walked),
  [[E27-dict-set-to-maps]] (the cache's eventual map).
