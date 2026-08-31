---
element: E13
slug: debruijn
title: Term de-Bruijn machinery (uses_below, shift_close)
kind: SELF-HOST
reference_class: OURS
ours_source: scaffold/chirality/terms.py
status: drafted
updated: 2026-07-12
---

# E13 — Term de-Bruijn machinery (`uses_below`, `shift_close`)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E13, the two generic term walkers under the kernel — `uses_below`
  (does a term reference any free variable with index `< bound`?) and
  `shift_close` (lower free indices by `delta` when a binder is eliminated). They
  are the de-Bruijn plumbing the kernel, `data.py`, and `lower.py` all share.
- **Kind:** SELF-HOST — it is Python (`terms.py`, 83 lines, "depends on nothing")
  that must become chirality source so the syntactic floor beneath the trusted kernel
  is itself written in the checked language.
- **Why chirality needs its own:** `terms.py` is deliberately the bottom of the
  trusted core — "syntax beneath judgment." As long as it is host Python, the very
  layer the kernel's substitution/context bookkeeping stands on sits outside the
  TCB the project is trying to shrink. Self-hosting it moves the binding
  mechanics into chirality, where totality and coverage are machine-checked rather
  than assumed.

## 2. Research

- **Reference class:** `OURS` — `scaffold/chirality/terms.py` (the whole file; it is
  the baseline). The `PAPER` side is the textbook de-Bruijn index representation
  (nameless terms; a binder shifts the "free" threshold by one), which the file
  already implements straightforwardly, so no external transcription is needed.
- **Key findings:**
  1. Both walkers are the **same traversal** over the tag-tuple term language,
     differing only in the leaf action: `uses_below` folds `Var` leaves to a
     `Bool` (`depth <= idx < depth+bound`); `shift_close` rewrites `Var` leaves
     (`idx < depth` ? keep : `idx - delta`). Every binder node (`Pi` cod, `Lam`
     body, `Let` body, `Case` branch) recurses at `depth + 1` (or `+ len(names)`).
  2. `shift_close`'s docstring states an **unchecked precondition**: "valid only
     when none of the lowered range is used." Nothing enforces it — the caller in
     the kernel must have separately established it. This is exactly the seam
     chirality can close.
  3. Dispatch is `k = t[0]` on an untyped tuple union with a **silent
     fallthrough** (`return False` / `return t` for any unhandled tag). Adding a
     term constructor and forgetting a walker case fails silently, not loudly.

## 3. Conventional (other-language) approach

The host walkers (`terms.py`) — one closure `go(t, depth)` per operation,
dispatching on a string tag pulled out of a positional tuple.

```python
def shift_close(t, delta):
    """Lower free variables by delta (valid only when none of the lowered range is used)."""
    def go(t, depth):
        k = t[0]                                    # (a) tag = tuple[0], untyped union
        if k == "Var":
            return t if t[1] < depth else ("Var", t[1] - delta)  # (b) precondition unchecked
        if k == "Lam":
            return ("Lam", t[1], go(t[2], depth + 1))
        if k == "Let":
            return ("Let", t[1], t[2], go(t[3], depth), go(t[4], depth + 1))
        # ... Pi, App, TCon, Con, Case, Ann, Refine ...
        return t                                    # (c) silent fallthrough for any other tag
    return go(t, 0)
```

- **Assumptions it bakes in:**
  - **Unchecked precondition as prose.** "Valid only when none of the lowered
    range is used" lives in a docstring. Call `shift_close` when the range *is*
    used and you get a silently wrong term, no error — a soundness bug in the
    layer beneath the type checker.
  - **Untyped tuple union + silent fallthrough.** `t` is `("Var", i) | ("Lam", …)
    | …`; an unrecognized tag returns `t`/`False` instead of failing. Coverage is
    a convention the walker author must remember, not a checked property.
  - **Partiality is ambient.** `t[2]`, `t[4]` index into tuples of tag-dependent
    arity; a malformed node throws `IndexError` at runtime rather than being
    ruled out by construction.
  - **Termination is assumed.** `go` recurses on `t[i]` with no machine-checked
    guarantee those are strict subterms; it happens to be structural, but nothing
    proves it.

## 4. The chirality idea

chirality makes the two walkers **total structural recursions over a closed `data
Term`**, and turns `shift_close`'s prose precondition into an obligation the
kernel already discharges via QTT.

- **Chirality features in play:**
  - **QTT usage & erasure (E5).** `uses_below` is a *relevance* query — "is any
    variable in this index window actually referenced?" That is precisely what
    QTT's usage vector already tracks when the kernel checks a binder. In chirality,
    `uses-below` is either the same fact read off the usage vector, or a walker
    whose result the kernel can *cross-check* against it. And `shift_close`'s
    precondition — the lowered range is unused — is the statement that those
    binders carry quantity `0` in the usage accounting. chirality can make that a
    typed precondition rather than a docstring.
  - **Totality by default (E11).** Both walkers recurse only on strict subterms
    of a `data Term`; chirality's structural-termination check certifies this with no
    measure annotation. The Python `while`-free recursion is *already* structural
    — chirality makes that a proof instead of an observation.
  - **Closed sum + exhaustive `case` (E6 coverage).** The tag-tuple union becomes
    `data Term` with named constructors; `case` is coverage-checked, so adding a
    constructor and forgetting a walker branch is a compile error, not the
    Python `return t` silent fallthrough.
  - **Effect membrane (`->`, pure).** Both are `(-> … Term …)` / `(-> … Bool)`:
    inert syntax transforms, no ports, no I/O — the membrane makes "the binding
    plumbing cannot touch the world" a typed fact.
  - **I64 floor (E24).** Indices and `depth`/`delta` are `I64` with explicit
    `<i`/`<=i`/`+`/`-`; no host `int`.
- **The reframing:** `depth` is threaded as an ordinary argument (as in the
  Python closure) but the operation now returns a value of a *declared* type, and
  the "valid only when…" side condition rides in the type of `shift-close`'s
  caller (the kernel's binder-elimination site), where the QTT usage vector that
  proves it is already in hand.
- **What chirality makes impossible here:** calling `shift-close` on a term that *does*
  use the lowered range and getting a quietly wrong result; dispatching on a term
  shape the walker forgot to handle and silently returning the input; a walker
  that fails to terminate; a "syntactic" walker that secretly performs effects.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, in the `collections.chiral`
idiom (pure, polymorphic-free, structural `case`). Copy this; extend the `Term`
sum and the two walkers together, in lockstep, so coverage stays checked.

```chirality
; E13 skeleton: de-Bruijn machinery over a closed core-term sum. Pure (->),
; total (structural on Term), coverage-checked (case over data Term).
; Mirrors scaffold/chirality/terms.py's uses_below / shift_close, minus the
; extension nodes (see Deliberately omitted).
(import "prelude")

; The nameless core term. Each binder node opens exactly one new index for the
; subterm noted below; `depth' in the walkers counts how many we have crossed.
; (Subset of terms.py's tag-tuple language: Var/App/Lam/Pi/Let.)
(data Term ()
  (t-var (idx I64))
  (t-app (fn Term) (arg Term))
  (t-lam (body Term))               ; body sees 1 new binder
  (t-pi  (dom Term) (cod Term))     ; cod sees 1 new binder
  (t-let (val Term) (body Term)))   ; body sees 1 new binder

; uses-below-at b depth t : does t reference a free variable whose index lands in
; the half-open window [depth, depth+b)? Under each binder the window slides by
; sliding depth, exactly as terms.py threads its `depth'. Total: every recursive
; call is on a strict subterm of t, so no measure is needed.
(declare uses-below-at (-> I64 I64 Term Bool))
(def uses-below-at                         ; type from the declare above
  (lam (b depth t)
    (case t
      ((t-var i)      (and (<=i depth i) (<i i (+ depth b))))
      ((t-app f a)    (or (uses-below-at b depth f)
                          (uses-below-at b depth a)))
      ((t-lam body)   (uses-below-at b (+ depth 1) body))
      ((t-pi dom cod) (or (uses-below-at b depth dom)
                          (uses-below-at b (+ depth 1) cod)))
      ((t-let v body) (or (uses-below-at b depth v)
                          (uses-below-at b (+ depth 1) body))))))

; Public entry: ask about the outermost context (depth 0).
(def uses-below (-> I64 Term Bool)
  (lam (b t) (uses-below-at b 0 t)))

; shift-close-at delta depth t : lower every FREE index (idx >= depth) by delta,
; leaving BOUND indices (idx < depth) alone. Sound only when
; (uses-below delta t) is false -- the caller (a binder-elimination site in the
; kernel) must hold that; QTT's usage vector is where that proof already lives.
(declare shift-close-at (-> I64 I64 Term Term))
(def shift-close-at                        ; type from the declare above
  (lam (delta depth t)
    (case t
      ((t-var i)      (case (<i i depth)
                        (true  (t-var i))            ; bound: unchanged
                        (false (t-var (- i delta))))) ; free: lowered
      ((t-app f a)    (t-app (shift-close-at delta depth f)
                             (shift-close-at delta depth a)))
      ((t-lam body)   (t-lam (shift-close-at delta (+ depth 1) body)))
      ((t-pi dom cod) (t-pi  (shift-close-at delta depth dom)
                             (shift-close-at delta (+ depth 1) cod)))
      ((t-let v body) (t-let (shift-close-at delta depth v)
                             (shift-close-at delta (+ depth 1) body))))))

(def shift-close (-> I64 Term Term)
  (lam (delta t) (shift-close-at delta 0 t)))
```

- **Knobs to modify:** the `Term` constructor set — add `t-ann`, `t-tcon`,
  `t-con`, `t-case`, `t-refine` to reach parity with `terms.py`, adding the
  matching `case` arm to *both* walkers (coverage will force it); the binder
  depth increment for a many-binder node (`Case` branch uses `+ len(names)`, so a
  branch arm threads `depth + (length names)` instead of `+ 1`); whether
  `shift-close`'s precondition is carried as a refinement on the argument or
  checked by the caller.
- **Deliberately omitted:** the extension nodes (`TCon`/`Con`/`Case`/`Refine`,
  which `terms.py` handles via `any(...)`/list comprehensions and which
  `data.py`/`refine.py` own) and the `Ann` node — they are the same traversal
  with wider arity, not a new idea; the point here is the shared shape (closed
  sum, threaded `depth`, total structural `case`, precondition-as-type), not the
  full constructor table.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/terms.chiral` (new), imported by the chirality kernel
  (E3/E4) and reused by the chirality ports of `data.py` and `lower.py`; eventually
  retires `scaffold/chirality/terms.py`.
- **Conformance target:** reproduce `terms.py` exactly on golden term fixtures —
  for every `(t, bound)`, `uses-below` agrees with `uses_below`; for every
  `(t, delta)` satisfying the precondition, `shift-close` yields the identical
  lowered term as `shift_close`. The extension-node arms, once added, must match
  the Python `any(...)`/comprehension behavior branch-for-branch (including the
  `Case` default arm and `depth + len(names)` binder counting).
- **Open questions:** does `uses-below` stay a standalone walker, or does the
  chirality kernel derive it from the QTT usage vector it already computes (removing a
  second traversal)?; is `shift-close`'s "lowered range unused" precondition best
  expressed as a refinement type on the argument, or discharged entirely at the
  single kernel call site?; how are the many-binder `Case` branches counted once
  the full `Term` sum is restored.
- **Related:** [[E05-qtt-semiring]] (the usage vector that already knows the
  `uses_below` answer and `shift_close`'s precondition), [[E11-totality]] (the
  structural-termination check that certifies both walkers),
  [[E06-data-coverage]] (the exhaustive `case` over `data Term`),
  [[E02-surface-elaborator]] (produces the de-Bruijn indices these walkers move),
  [[E24-i64-arith]] (the `I64` index floor).
