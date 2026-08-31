---
element: E11
slug: totality-checker
title: Totality: structural + numeric-measure termination (`check_termination`)
kind: SELF-HOST
reference_class: PAPER/IMPL
ours_source: scaffold/chirality/data.py
status: drafted
updated: 2026-07-13
---

# E11 — Totality: structural + numeric-measure termination (`check_termination`)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E11 — the totality gate. For each `def`, classify it as
  proven-total (non-recursive, or every self-call decreases at a uniform
  argument position by a well-founded measure — structural *or* numeric) and
  record `None` in `sig.totality[name]`, else the reason it could not be proven.
- **Kind:** SELF-HOST.
- **Why chirality needs its own:** it is part of the trusted checker stack
  (`terms` + `kernel` + `data` + `effects` + `refine`). Totality is a core
  language guarantee — "functions are total; no unbounded `while`" — so the
  judgment that enforces it must itself become chirality-in-chirality to shrink the TCB
  rather than living forever in host Python.

## 2. Research

- **Reference class:** PAPER — foetus / size-change termination
  (Lee–Jones–Ben-Amram, POPL'01); IMPL — the Agda and Coq structural termination
  checkers.
- **Key findings (load-bearing):**
  1. **Size-change / foetus:** for each self-call, compute the *set* of argument
     positions that strictly decrease under a well-founded order. A definition
     terminates if some position decreases on **every** call path — i.e. the
     intersection of the per-call decreasing sets is non-empty (the "uniform
     decreasing position" special case of the full SCT condition). Our OURS
     slice does exactly this: it appends one `dec` set per self-call.
  2. **Structural order (Agda/Coq):** a field bound by a `case` on a scrutinee is
     *strictly smaller* than the scrutinee; recursion on such a subterm is
     well-founded. In the port this is the `st-smaller` size token.
  3. **Numeric measure:** a constant-step approach of a parameter toward a
     constant bound that the guards on the path establish; the guard, re-checked
     each iteration, must eventually halt the recursion (the measure
     `hi - i` / `i - lo` decreases).
  4. **The chirality-specific twist (from the OURS docstring):** because the floor is
     wrapping two's-complement `I64` (§the float→I64 wall), a numeric measure
     **must exclude the wraparound point**. A vacuous bound at the extreme
     (`i <= I64_MAX`, step `i+1`) would "prove" a loop that actually wraps and
     never stops. So a positive step `d` is safe only when `hi <= I64_MAX - d`
     (and symmetrically for underflow). This obligation does **not** exist in
     foetus/Agda, whose measures live over unbounded ℕ — it is forced by chirality's
     I64 floor.

## 3. Conventional (other-language) approach

The OURS Python: `check_termination` records a verdict, `_totality_reason` does
the walk, collecting a decreasing-position set per self-call.

```python
def check_termination(sig, name, body):
    reason = _totality_reason(sig, name, body)
    sig.totality[name] = reason
    if reason is not None and sig.require_total:
        raise _NotStructural(f"{name}: {reason}")   # control flow via exception

def walk(t, depth, size, bounds):
    if k == "App":
        head, args = _term_spine(t)
        if head[0] == "Global" and head[1] == name:  # a self-call
            dec = set()
            for j, a in enumerate(args):
                if a[0] == "Var":                     # structural: field < param j
                    tok = size.get(depth - 1 - a[1])
                    if tok is not None and tok[0] == j and tok[1]:
                        dec.add(j)
                nd = _num_delta(a, depth, nparams)    # numeric: bounded step
                if nd is not None and nd[0] == j and nd[1] != 0:
                    lo, hi, lt, gt = bounds.get(j, _NOBOUND)
                    if nd[1] > 0 and hi is not None and hi <= _I64_MAX - nd[1]:
                        dec.add(j)                    # i+d cannot overflow
                    # … underflow + symbolic-strict cases …
            calls.append(dec)
```

- **Assumptions it bakes in:** exceptions as control flow (`raise
  _NotStructural`); the checker's *own* arithmetic runs on unbounded Python ints
  (no wraparound in the tool that reasons about wraparound); ambient recursion —
  the checker is not itself proven total; and it mutates `sig.totality` in place
  as a side effect.

## 4. The chirality idea

- **Chirality features in play:** totality (the checker is *itself* total — it
  recurses structurally over the finite `Term` tree, so chirality's own gate
  certifies it); errors-as-values (the verdict is a returned result sum, never a
  throw); the `->` pure membrane (judgment holds no port, does no I/O); the
  I64 floor + the two's-complement wraparound wall; QTT-erased type params.
- **The reframing:** `check-termination` becomes a **pure** (`->`) function that
  *returns* a `Verdict` value — `(total)` or `(not-total reason)` — instead of
  mutating a signature and raising. It walks a finite AST by structural
  recursion, so it passes its own test. The numeric branch carries the I64
  bound-vs-wraparound proof explicitly, in I64 arithmetic, against real
  `I64-MAX` / `I64-MIN` constants — the tool reasons about wrapping in the same
  arithmetic it polices.
- **What chirality makes impossible here:** a totality checker that can silently
  diverge (it must be total), that signals failure by throwing (errors are
  values, in the signature), or that certifies a wrapping loop as total (the
  wraparound guard is a mandatory obligation of the I64 floor, not an optional
  nicety).

## 5. Chirality example (fleshed)

```chirality
(import "prelude")            ; List, Str, I64, Bool, Option, I64-MAX, I64-MIN

; --- the slice of the term ADT the checker judges over (from E01) -------------
(data Term ()
  (t-var  (lvl  I64))                       ; de Bruijn level
  (t-lam  (body Term))                      ; a leading binder = recursion param
  (t-app  (head Term) (args (List Term)))
  (t-case (scrut Term) (arms (List Arm)))
  (t-glob (name Str)))                       ; a global ref / self-call head

; --- the well-founded evidence threaded down each path ------------------------
(data SizeTok ()
  (st-root    (param I64))                   ; the param itself: not-smaller
  (st-smaller (param I64)))                  ; a case-bound field: strictly smaller

(data Bound ()                               ; guard-established constant window
  (bnd (param I64) (lo I64) (hi I64)))

; --- errors are values: the verdict is RETURNED, never thrown -----------------
(data Verdict ()
  (total)                                    ; None in the OURS port
  (not-total (reason Str)))

; case arms — Term<->Arm is mutually recursive, expressible since E79.
(data Arm () (arm (ctor Str) (nvars I64) (body Term)))

; working types the walk threads (opaque stubs; real ones = size-token env /
; bounds env / per-call decreasing-position sets) + the walk's result sum:
(declare Sizes  (type 0))
(declare Bounds (type 0))
(declare Calls  (type 0))
(declare DecSet (type 0))
(data Walked () (v-ok (calls Calls)) (v-err (reason Str)))

; elided helpers, forward-declared (bodies mechanical):
(declare count-lams    (-> Term I64 I64))
(declare strip-lams    (-> Term Term))
(declare sizes-init    (-> I64 Sizes))
(declare bounds-init   Bounds)                ; a value (nullary)
(declare calls-empty   Calls)                 ; a value (nullary)
(declare calls-empty?  (-> Calls Bool))
(declare calls-push    (-> Calls DecSet Calls))
(declare intersect-all (-> Calls (Maybe I64)))
(declare is-self       (-> Term Str Bool))
(declare walk          (-> Str I64 Term I64 Sizes Bounds Calls Walked))
(declare score-args    (-> Str I64 (List Term) I64 Sizes Bounds DecSet))
(declare walk-children (-> Str I64 Term I64 Sizes Bounds Calls Walked))
(declare walk-arms     (-> Str I64 Term (List Arm) I64 Sizes Bounds Calls Walked))
(declare dec-empty     DecSet)                ; a value (nullary)

; the gate is PURE (`->`) and itself STRUCTURALLY recursive on the finite Term
; tree — so chirality's own totality gate certifies check-termination.
(declare check-termination (-> Str Term Verdict))
(def check-termination (lam (name body)
  (let ((nparams (count-lams body 0))        ; strip the recursion binders
        (spine   (strip-lams body)))
    ; foetus: collect one decreasing-position set per self-call, then intersect —
    ; total iff some position decreases on EVERY self-call.
    (case (walk name nparams spine 0 (sizes-init nparams) bounds-init calls-empty)
      ((v-err reason) (not-total reason))            ; used-as-value / mutual rec
      ((v-ok calls)
        (case (calls-empty? calls)
          (true  (total))                            ; non-recursive
          (false (case (intersect-all calls)
                   ((some j) (total))                ; uniform decreasing position j
                   (none (not-total "no argument position decreases on every self-call"))))))))))

; --- the walk: gather decreasing positions; structural recursion on Term ------
(def walk (lam (name np t depth size bounds calls)
  (case t
    ((t-app head args)
      (case (is-self head name)
        (true  (v-ok (calls-push calls (score-args name np args depth size bounds))))
        (false (walk-children name np t depth size bounds calls))))   ; … thread size/bounds …
    ((t-case scrut arms)
      ; each arm binds fields strictly smaller than the scrutinee param → st-smaller
      (walk-arms name np scrut arms depth size bounds calls))
    ((t-glob g)
      (case (str-eq g name)
        (true  (v-err "used as a value, not called directly -- recursion uncheckable"))
        (false (v-ok calls))))
    (_ (v-ok calls)))))                              ; … t-var / t-lam recurse structurally …

; --- scoring one self-call: structural OR numeric measure ---------------------
(def score-args (lam (name np args depth size bounds)
  ; for argument position j:
  ;   structural — (t-var l) whose SizeTok is (st-smaller j)         → j decreases
  ;   numeric    — a constant step d of param j toward a constant bound, AND the
  ;                bound excludes the two's-complement wrap point:
  ;                  d>0 needs (<=i hi (- I64-MAX d))   ; i+d cannot overflow
  ;                  d<0 needs (>=i lo (- I64-MIN d))   ; i+d cannot underflow
  ;                a vacuous extreme bound (i <= MAX, step i+1) is REJECTED —
  ;                it would "prove" a loop that wraps and never halts.
  ; … fold over (enumerate args), adding the safe positions to a DecSet …
  dec-empty))
```

- **Knobs to modify:** the `SizeTok` order (extend to lexicographic/multiset for
  nested structural descent); the `I64-MAX`/`I64-MIN` constants (a different
  target width changes the wraparound guard); the decrease rule (this uniform
  intersection vs the full size-change transitive-closure test); and whether
  `not-total` is fatal — the caller escalates on a `require-total` profile
  instead of the checker deciding.
- **Deliberately omitted:** mutual recursion (multi-`def` size-change graphs —
  the port punts with "declared but not yet defined"); the full LJB size-change
  condition (idempotent-decreasing composition); the guard→`Bounds` extraction
  that reads `case`/`if` tests on I64; and higher-order/definitional unfolding.

## 6. Use / modify notes

- **Lands in:** `scaffold/chirality/data.py` — the `check_termination` /
  `_totality_reason` / `walk` block — porting toward a self-hosted
  `lib/totality.chiral` (or the chirality-in-chirality `data` module).
- **Conformance target:** reproduce the Python port's `sig.totality[name]`
  verdicts — `None` for structural and *safe*-numeric recursion, a reason string
  otherwise. Golden cases that must match: (a) accept structural descent on a
  case-bound field; (b) accept a symbolic-strict step `i < n` with `n` unchanged
  and step ±1; (c) **reject** the vacuous extreme bound (`i <= MAX`, `i+1`) that
  would certify a wrapping loop; (d) reject a self-reference used as a value.
- **Open questions:** mutual recursion (needs a call graph across defs); uniform
  decreasing position vs full SCT; where `Bounds` extraction lives (shared with
  the refinement engine, E09?); and how `require_total` binds to a profile.
- **Related:** [[E01]] (the `Term` ADT this walks), [[E06]] (data ctors / `case`
  — the source of the structural order), [[E07]] (strict positivity — sibling
  data-decl judgment), [[E09]] (refinement — the bound/guard predicates).
