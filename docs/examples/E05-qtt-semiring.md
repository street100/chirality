---
element: E05
slug: qtt-semiring
title: QTT quantity semiring + usage-vector linearity accounting
kind: SELF-HOST
reference_class: PAPER/IMPL
ours_source: scaffold/chirality/kernel.py
status: drafted
updated: 2026-07-22
---

# E05 — QTT quantity semiring + usage-vector linearity accounting

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E05, the accounting heart of the judgment: the quantity
  semiring ({0,1,ω}: `qadd/qmul/qjoin/qfits`) and usage vectors over de Bruijn
  contexts (`uzero/uadd/uscale/ujoin`) that make linearity a *computed fact*
  of every typing derivation.
- **Kind:** SELF-HOST.
- **Why chirality needs its own:** this is the TCB shrink at its core — the
  checker cannot become chirality source while its resource arithmetic is Python.
  Every enforcement story in the language (linear ports, erasure, the E39
  graded-continuation law) bottoms out in these ~40 lines; they are the first
  thing `kernel-core` (E52) must carry.

## 2. Research

- **Reference class:** PAPER (Atkey, "Syntax and Semantics of QTT"; McBride,
  "I Got Plenty o' Nuttin'") for the metatheory; `OURS` (`kernel.py`) as the
  port source; Idris2 is a Tier-O oracle only (run it, never read it).
- **Key findings:**
  1. **QTT is parametric over an arbitrary resource semiring** — {0,1,ω} is
     one instance. The settled enrichment (decision-graded-kernel +
     decision-effect-facets: a usage×time×space×info-flow product with frozen
     factor width) must be an *instance swap*, not a rewrite — so the port
     keeps the vector algebra parametric in the grade type through exactly
     four ops.
  2. **The concrete tables** (`kernel.py:70–96`): `qadd` saturates (0 is
     unit; 1+1 = ω; ω absorbs); `qmul` has 0 annihilating and 1 as unit,
     else ω; `qjoin` merges case branches (equal stays, divergent saturates
     to ω); `qfits` — a declared ω admits anything, otherwise the computed
     usage must be exactly the declared quantity.
  3. **The two call-site formulas are the whole enforcement story** and the
     port must reproduce them exactly: application computes
     `uadd(uf, uscale(q, ua))` (`kernel.py:436`) — the argument's *whole*
     vector, including usages of captured free variables, scales by the
     binder quantity; this single line is what forces a port-capturing
     closure to be one-shot (E39's graded-continuation law: ω-binding scales
     a captured 1-use to ω and `qfits` fails). Let-binding checks
     `qfits(used, q)` on the binder's own slot, then returns
     `uadd(ub[:-1], uscale(q, uv))` (`kernel.py:530`).
  4. **Usage vectors are context-length lists, de Bruijn-indexed**; branch
     merge is pointwise `ujoin`. Nothing else — no regions, no borrow graph.

## 3. Conventional (other-language) approach

The OURS baseline — untyped Python over magic ints with a `W` sentinel:

```python
def qadd(a, b):
    if a == 0: return b
    if b == 0: return a
    return W                    # 1+1 and anything involving W saturate

def qmul(a, b):
    if a == 0 or b == 0: return 0
    if a == 1: return b
    if b == 1: return a
    return W

def qfits(computed, declared):
    if declared == W: return True
    return computed == declared

def uscale(q, u): return [qmul(q, x) for x in u]
def uadd(u1, u2): return [qadd(a, b) for a, b in zip(u1, u2)]
```

- **Assumptions it bakes in:** quantities as untagged ints plus a sentinel
  object (nothing stops `qadd(7, W)`); vectors as raw lists with `zip`'s
  silent shortest-wins on length mismatch; no totality evidence (Python
  recursion just runs); correctness held by tests, not types. And the wider
  conventional world doesn't even have this seam: Rust's borrow checker is a
  separate non-type-level analysis bolted beside the types; Haskell's linear
  arrows are multiplicity-polymorphic but not a semiring product — neither
  has a swappable grade set for cost/info-flow to land in later.

## 4. The chirality idea

- **Chirality features in play:** closed `data` sums with coverage-checked
  `case`; totality (structural + numeric-measure recursion — the checker
  itself must be total, since checking is decidable); `->` purity throughout
  (accounting performs no crossings); errors-as-values (`qfits` returns the
  fact; the judgment layer decides rejection).
- **The reframing:** quantities become a three-constructor sum, so the
  sentinel and the untagged ints vanish — `(qadd 7 W)` is not a value error
  but an untypeable sentence. The four q-ops become total tables the
  coverage checker verifies exhaustive. The vector algebra is structural
  recursion over `(List Qty)`, parametric in `Qty` through the four ops
  alone — which is the reserved seat: the E38 product semiring replaces the
  `Qty` instance and the vector functions never change.
- **What chirality makes impossible here:** a malformed quantity (no such
  inhabitant); a non-exhaustive op table (coverage); a diverging accounting
  pass (totality); a semiring op that secretly does I/O (`->` = empty row).
  The checker's own arithmetic becomes checkable by the discipline it
  implements — self-applicability in miniature.

## 5. Chirality example (fleshed)

```chirality
(import "prelude")

; ---- the grade set: today's instance -----------------------------------
; The enrichment (usage x time x space x info-flow, frozen width) swaps THIS
; data type and its four ops; the vector algebra below is untouched. That
; parametricity seam is the point of the port's shape.
(data Qty () (q0) (q1) (qw))

; ---- the semiring, as total coverage-checked tables --------------------
(def qadd (-> Qty Qty Qty)
  (lam (a b)
    (case a
      ((q0) b)
      ((q1) (case b ((q0) (q1)) ((q1) (qw)) ((qw) (qw))))   ; 1+1 saturates
      ((qw) (qw)))))

(def qmul (-> Qty Qty Qty)
  (lam (a b)
    (case a
      ((q0) (q0))                                            ; 0 annihilates
      ((q1) b)                                               ; 1 is unit
      ((qw) (case b ((q0) (q0)) ((q1) (qw)) ((qw) (qw)))))))

; branch merge: divergent linear use across case arms saturates to w
(def qjoin (-> Qty Qty Qty)
  (lam (a b)
    (case a
      ((q0) (case b ((q0) (q0)) ((q1) (qw)) ((qw) (qw))))
      ((q1) (case b ((q0) (qw)) ((q1) (q1)) ((qw) (qw))))
      ((qw) (qw)))))

; computed-vs-declared: w admits anything, else exact
(def qfits (-> Qty Qty Bool)
  (lam (computed declared)
    (case declared
      ((qw) true)
      ((q1) (case computed ((q1) true) ((q0) false) ((qw) false)))
      ((q0) (case computed ((q0) true) ((q1) false) ((qw) false))))))

; ---- usage vectors: one Qty per de Bruijn context slot -----------------
; Numeric-measure recursion (n toward 0): the termination checker's measure
; fragment proves this total (docs/totality.md).
(def uzero (-> I64 (List Qty))
  (lam (n) (case (<=i n 0)
             (true  nil)
             (false (cons (q0) (uzero (- n 1)))))))

; Structural recursion, explicit (no partial application: this code is
; destined for the floor, and floor-friendly shape costs nothing here).
(def uadd (-> (List Qty) (List Qty) (List Qty))
  (lam (u1 u2)
    (case u1
      ((nil) nil)
      ((cons a r1)
       (case u2
         ((nil) nil)
         ((cons b r2) (cons (qadd a b) (uadd r1 r2))))))))

(def uscale (-> Qty (List Qty) (List Qty))
  (lam (q u)
    (case u
      ((nil) nil)
      ((cons x r) (cons (qmul q x) (uscale q r))))))

(def ujoin (-> (List Qty) (List Qty) (List Qty))
  (lam (u1 u2)
    (case u1
      ((nil) nil)
      ((cons a r1)
       (case u2
         ((nil) nil)
         ((cons b r2) (cons (qjoin a b) (ujoin r1 r2))))))))

; ---- the two call-site formulas the port must reproduce EXACTLY --------
; application (kernel.py:436):   usage = (uadd uf (uscale q ua))
;   The argument's WHOLE vector scales by the binder quantity — including
;   captured free variables. This is the line that enforces E39's
;   graded-continuation law: q = w scales a captured 1-use to w, and the
;   context's qfits rejects it upstream.
; let (kernel.py:530):           (qfits used q) on the binder's own slot,
;                                then usage = (uadd (drop-last ub) (uscale q uv))
```

- **Knobs to modify:** the grade instance (`Qty` + the four op tables → the
  E38 product; nothing else moves); the vector representation (`List` now, a
  packed `Bytes` cell later if accounting shows up in profiles); the
  length-mismatch policy (silent-shortest inherited from `zip` — see open
  questions).
- **Deliberately omitted:** the judgment traversal that *calls* these (E3/E4
  own infer/check); the E38 product instance itself (its own example owns
  the carrier slice); context machinery (E13).

## 6. Use / modify notes

- **Lands in:** `lib/qtt.chiral` — the first file of the kernel-core port
  tree (E52's trusted core is this + the traversal).
- **Conformance target:** differential against the Python original — the
  full 3×3 tables for `qadd/qmul/qjoin` and the `qfits` truth table,
  byte-equal; the semiring laws as property checks (associativity and
  commutativity of `qadd`, distributivity of `qmul`, 0-unit/1-unit); and the
  two call-site formulas producing identical vectors on sampled judgments.
  Tier-O oracle: Idris2 for what-ought-to-typecheck at the feature level.
- **Open questions:** (1) **how parametricity is realized in chirality** — the
  four ops passed as a first-class record needs closures at the floor (E69)
  if kernel-core is to lower, vs per-instance specialization through
  `specialize`/pregen (the staging story) with zero closures — a genuine
  fork between E69-dependency and E17-dependency; (2) whether `qfits`
  returns `Bool` or a diagnostic sum (errors-as-values pulls toward the sum;
  this is the judgment's hottest path); (3) the vector-length invariant —
  `(List Qty)` of length = context depth is currently a discipline, and
  saying it in the type (`(UVec n)`) wants value-indexed data the E48
  telescope work owns; until then the `zip` shortest-wins policy is
  inherited and should at least become an explicit guard.
- **Related:** [[E03-nbe-normalize]] / [[E04-bidir-universes]] (the
  consumers), [[E38]] (the enrichment instance), [[E39-effect-row]] (the law
  the application-site formula enforces), [[E13-debruijn]] (context
  machinery), [[E69]] (closures-at-the-floor, if parametricity goes the
  record route), [[E27-dict-set-to-maps]] (the library floor this sits
  beside).
