---
element: E09
slug: refinement
title: Refinement decision procedure (interval-with-holes + symbolic bounds, entails)
kind: SELF-HOST
reference_class: PAPER
ours_source: scaffold/chirality/refine.py
status: drafted
updated: 2026-07-12
---

# E09 — Refinement decision procedure (interval-with-holes + symbolic bounds, entails)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E09, the refinement **entailment decision procedure** — given two
  predicates over `I64`, decide whether one implies the other, using an
  interval-with-holes constant domain plus a set of symbolic `(op, variable)`
  bounds (`refine.py:entails` / `is_empty` / the constraint algebra).
- **Kind:** SELF-HOST — this is compiler judgment currently written in host
  Python (`scaffold/chirality/refine.py`) that must become chirality source; it is part
  of the checker stack (catalog §I, the shrink-the-TCB target).
- **Why chirality needs its own:** subtyping `{I64 | >=5, <10} <: {I64 | >=0}`, the
  in-range value check, and path-sensitive narrowing all bottom out in
  `entails`. As long as that decision lives in CPython it is outside the trusted
  base chirality can check about itself. Self-hosting it moves the proof of "this
  offset is in bounds" from a runtime check into chirality-checked chirality.

## 2. Research

- **Reference class:** PAPER/IMPL — Liquid Types (Rondon, Kawaguchi, Jhala,
  *Liquid Types*, PLDI'08), the abstract-interpretation **interval / octagon
  numeric domains** (Cousot–Cousot; Miné's octagons), and SMT-backed refinement
  checkers (Z3/CVC5) as the maximal-power comparison point. Grounded against the
  `OURS` baseline `scaffold/chirality/refine.py` (docstring lines 1–36; `entails`
  122–141; `is_empty` 105–119; `_atom`/`_sym_atom` 64–84) and the golden
  behavior in `scaffold/tests/test_refine.py`.
- **Key findings:**
  1. **Liquid Types** discharge refinement subtyping as **implication checking**
     over a fixed set of predicate templates, farmed out to an SMT solver. The
     load-bearing move is that entailment is *decided*, not proven by hand — but
     the general version needs a solver in the trusted base.
  2. chirality deliberately takes the **decidable, solver-free fragment**: the
     constant predicate is an **interval-with-holes** `(lo, hi, excluded)` —
     sound *and complete* for conjunctions of `>= <= < > <>` against constants
     (`refine.py` docstring 14–20). Entailment is interval containment plus a
     forbidden-set check.
  3. The **symbolic** slice (`v < n`, bound against an in-scope variable keyed by
     de Bruijn *level*) is handled by a **syntactic subset check** — sound but
     incomplete: it does no arithmetic between variables, so `v < n` does not
     entail `v < n+1` (docstring 18–20, `entails` 137–140).
  4. **Completeness needs `is_empty`**: an uninhabited constraint (empty interval
     or a finite range fully punched out by holes) vacuously entails everything;
     without that check `entails` wrongly rejects sound subtypings
     (`is_empty` 105–119, `entails` 124–125).

## 3. Conventional (other-language) approach

How this is done outside chirality — the existing Python, whose full-power cousin is
"emit a verification condition and ask Z3."

```python
# scaffold/chirality/refine.py — the decidable core, in host Python
def entails(c1, c2):
    """Does every value satisfying c1 satisfy c2? (c1 is at least as strong.)"""
    if is_empty(c1):
        return True                       # nothing satisfies c1 -> vacuous
    lo1, hi1, ex1, sym1 = c1
    lo2, hi2, ex2, sym2 = c2
    if lo2 is not None and (lo1 is None or lo1 < lo2):
        return False                      # c1's floor is not high enough
    if hi2 is not None and (hi1 is None or hi1 > hi2):
        return False                      # c1's ceiling is not low enough
    for x in ex2:                         # every hole c2 punches, c1 must too...
        outside = (lo1 is not None and x < lo1) or (hi1 is not None and x > hi1)
        if not outside and x not in ex1:  # ...unless it's already out of range
            return False
    if not sym2 <= sym1:                  # symbolic facts: syntactic subset
        return False
    return True
```

- **Assumptions it bakes in:** (a) **ambient partiality** — a Python tuple
  `(lo, hi, ex, sym)` with `None` sentinels; nothing forces the caller to prove
  the constraint well-formed, and `is_empty` is a *separate* function you must
  remember to call first or silently get an unsound answer. (b) **untracked
  totality** — `entails` happens to terminate, but Python asserts nothing; the
  `for x in ex2` loop and the `is_empty` range-walk are trusted by inspection.
  (c) **an untyped set** `sym2 <= sym1` over opaque `(op, level)` tuples — the
  meaning of a "level" is a comment, not a type. The SMT-backed version goes
  further and pulls an entire external solver into the trusted base.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** **totality** (the decision procedure is a *total*
  `->` function chirality checks terminates — no solver oracle, no partiality);
  the **effect membrane** (`->` pure, no `=>` — deciding entailment observes
  nothing and touches no port); **category A** (this is fully typed judgment,
  correctness by proof, not a category-C evidence bridge); **refinement itself**
  (the feature is bootstrapping — the decision procedure is exactly what gives
  `{I64 | ...}` its meaning); and the **float→I64 wall** (bounds are `I64`, so
  entailment is exact integer reasoning with no rounding).
- **The reframing:** the `(lo, hi, ex, sym)` tuple-with-`None` becomes a **data
  type** — `Maybe I64` for each open-able bound, `List I64` for the holes, and a
  `List (Pair SymOp I64)` for the symbolic facts, with `SymOp` a closed 5-way
  enum. `is_empty` stops being a footgun you must remember: `entails` opens with
  a `case` on emptiness as its first branch, so vacuous-truth is *structurally*
  the first thing decided. Because the whole thing is a total `->` over finite
  inductive data, chirality checks that the decision procedure itself terminates —
  the property Python only asserts by inspection.
- **What chirality makes impossible here:** you **cannot** answer "does c1 entail c2"
  by consulting an external solver or performing an effect — the signature is
  pure `->`, so a solver call (a process crossing `=>`) would not type. You
  cannot forget the emptiness case and still return `Bool` for every input (the
  `case` is total). And a "symbolic bound" is no longer an opaque tuple: a
  `(Pair SymOp I64)` names its operator and its de-Bruijn level in the type.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready. This
is the entailment decision procedure, self-hosted. The surface refinement forms
it decides look like `(refine I64 (>= 0) (< 64))` (constant) and
`(refine I64 (< n))` (symbolic, against an erased `(0 n I64)`), exactly as in
`scaffold/lib/mem-linear.chiral` and `scaffold/tests/test_refine.py`.

```chirality
(import "prelude")   ; Maybe/List/Pair/Bool, =i <i, and/or/not

; The predicate operators, closed enum -- the five atoms  >= > <= < <>.
(data SymOp () (s-ge) (s-gt) (s-le) (s-lt) (s-ne))

; A constraint = interval-with-holes (the CONSTANT part) plus a set of
; symbolic (op, de-Bruijn-level) facts. `none` bound = open. The constant part
; is decidable and complete; the symbolic part is decided by syntactic subset.
(data Constraint ()
  (constraint
    (lo  (Maybe I64))                 ; inclusive floor,  none = -inf
    (hi  (Maybe I64))                 ; inclusive ceiling, none = +inf
    (ex  (List I64))                  ; the holes: forbidden values (v <> k)
    (sym (List (Pair SymOp I64)))))   ; symbolic bounds keyed by operand level

; -- constant-domain helpers ------------------------------------------------

; x sits below the floor / above the ceiling (open bound = never outside).
(def below-lo (-> (Maybe I64) I64 Bool)
  (lam (lo x) (case lo (none false) ((some l) (<i x l)))))
(def above-hi (-> (Maybe I64) I64 Bool)
  (lam (hi x) (case hi (none false) ((some h) (<i h x)))))

; membership of a value in a hole-list (recursive -> forward `declare`).
(declare i64-mem (-> I64 (List I64) Bool))
(def i64-mem
  (lam (x xs)
    (case xs
      (nil false)
      ((cons y rest) (case (=i x y) (true true) (false (i64-mem x rest)))))))

; interval-empty: floor strictly above ceiling. (The finite-fully-punched-out
; case -- see `is_empty` in refine.py -- is deliberately omitted, below.)
(def interval-empty (-> (Maybe I64) (Maybe I64) Bool)
  (lam (lo hi)
    (case lo (none false)
      ((some l) (case hi (none false) ((some h) (<i h l)))))))

; c1's floor is at least as high as every floor c2 demands.
(def lo-ok (-> (Maybe I64) (Maybe I64) Bool)
  (lam (lo1 lo2)
    (case lo2 (none true)
      ((some l2) (case lo1 (none false) ((some l1) (not (<i l1 l2))))))))
; c1's ceiling is at least as low as every ceiling c2 demands.
(def hi-ok (-> (Maybe I64) (Maybe I64) Bool)
  (lam (hi1 hi2)
    (case hi2 (none true)
      ((some h2) (case hi1 (none false) ((some h1) (not (<i h2 h1))))))))

; every hole c2 punches, c1 must punch too -- unless it is already out of c1's
; interval, which excludes it for free.
(declare holes-ok (-> (Maybe I64) (Maybe I64) (List I64) (List I64) Bool))
(def holes-ok
  (lam (lo1 hi1 ex1 ex2)
    (case ex2
      (nil true)
      ((cons x rest)
        (case (or (or (below-lo lo1 x) (above-hi hi1 x)) (i64-mem x ex1))
          (true  (holes-ok lo1 hi1 ex1 rest))
          (false false))))))

; -- symbolic-domain helpers (sound, incomplete: pure syntactic subset) ------

(def sym-tag (-> SymOp I64)
  (lam (o) (case o (s-ge 0) (s-gt 1) (s-le 2) (s-lt 3) (s-ne 4))))
(def fact-eq (-> (Pair SymOp I64) (Pair SymOp I64) Bool)
  (lam (p q)
    (case p ((pair po pl)
      (case q ((pair qo ql)
        (and (=i (sym-tag po) (sym-tag qo)) (=i pl ql))))))))

(declare fact-mem (-> (Pair SymOp I64) (List (Pair SymOp I64)) Bool))
(def fact-mem
  (lam (f fs)
    (case fs
      (nil false)
      ((cons g rest) (case (fact-eq f g) (true true) (false (fact-mem f rest)))))))

; sym2 subset-of sym1: every fact c2 demands, c1 already carries.
(declare sym-subset (-> (List (Pair SymOp I64)) (List (Pair SymOp I64)) Bool))
(def sym-subset
  (lam (sub super)
    (case sub
      (nil true)
      ((cons f rest)
        (case (fact-mem f super) (true (sym-subset rest super)) (false false))))))

; -- the decision procedure -------------------------------------------------

; entails c1 c2: does EVERY value satisfying c1 satisfy c2? (c1 is at least as
; strong.) Emptiness is decided FIRST, so vacuous truth is structural.
(def entails (-> Constraint Constraint Bool)
  (lam (c1 c2)
    (case c1 ((constraint lo1 hi1 ex1 sym1)
    (case c2 ((constraint lo2 hi2 ex2 sym2)
      (case (interval-empty lo1 hi1)
        (true true)                         ; nothing satisfies c1 -> vacuous
        (false
          (and (lo-ok lo1 lo2)
          (and (hi-ok hi1 hi2)
          (and (holes-ok lo1 hi1 ex1 ex2)
               (sym-subset sym2 sym1))))))))))))
```

- **Knobs to modify:** widen the constant domain by extending `SymOp` /
  `Constraint` (e.g. add a `stride` field for congruence `v % k == r`); replace
  `interval-empty` with the fuller `is_empty` (also `true` when a finite range
  is completely covered by `ex`); swap the symbolic `List` for a set with a real
  ordering if the fact-list grows; change the base from `I64` if refinements ever
  extend past the integer wall.
- **Deliberately omitted:** the **finite-fully-punched-out** emptiness case
  (`hi - lo + 1 <= len(ex)` walk in `is_empty`) — kept out so the core reads
  clean; the constraint *builders* (`_atom`/`_sym_atom`/`build`) and the term
  `_eval_refine` that folds a symbolic bound to a constant on instantiation
  (that is E-adjacent evaluator work); and any arithmetic between symbolic
  variables (`v < n` ⊢ `v < n+1`) — explicitly out of the decidable fragment.

## 6. Use / modify notes

- **Lands in:** a chirality-source refinement module, e.g. `scaffold/lib/refine.chiral`
  (the chirality re-implementation of `scaffold/chirality/refine.py`'s constraint algebra
  and `entails`), consumed by the self-hosted subtype/check hooks.
- **Conformance target:** must reproduce the golden decisions in
  `scaffold/tests/test_refine.py` — subtyping accepts `{>=5,<10} <: {>=0}` and
  rejects `{>=0} <: {>=5}` (`TestSubtyping`); the uninhabited constraint entails
  everything (completeness test, `is_empty`); symbolic `{<n} <: {<n}` passes by
  subset while `{}` at `n` does not (`TestSymbolicRefinement`); and every
  path-sensitivity narrowing that bottoms out in `entails` still lands the same
  accept/reject.
- **Open questions:** does the self-hosted version key symbolic facts by de
  Bruijn **level** (absolute, NbE-stable) the way the Python does, and how does
  chirality-source code obtain that level without the kernel's internals — likely a
  reflected term API this element depends on? Is `Maybe I64` the right encoding
  for an open bound, or should the constraint carry a total floor/ceiling with an
  explicit `unbounded` constructor?
- **Related:** [[E13-debruijn]] (the level machinery the symbolic keys ride on),
  [[E10-narrowing]] (path-sensitivity / occurrence typing — the `_narrow` hook
  that *produces* the constraints this procedure then decides), [[E24-i64-arith]]
  (the exact-integer base the interval domain reasons over).
