---
element: E10
slug: occurrence-typing
title: Path-sensitivity / occurrence typing (`_narrow`, `sig.narrow_hooks`)
kind: SELF-HOST
reference_class: PAPER/IMPL
ours_source: scaffold/chirality/refine.py
status: drafted
updated: 2026-07-12
---

# E10 — Path-sensitivity / occurrence typing (`_narrow`, `sig.narrow_hooks`)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E10, path-sensitivity / occurrence typing — the `_narrow` hook that
  lets a `case` branch guarded by a comparison learn the refinement bound its
  guard proves about the compared variable.
- **Kind:** SELF-HOST — this is Python (`refine.py`'s `_narrow` +
  `data.py` guard tracking) that must become chirality source.
- **Why chirality needs its own:** to shrink the TCB. Narrowing is the piece that
  makes refinement types *usable* — without it a `(refine I64 (< n))` obligation
  could only be met by values already typed that way, never by a plain `I64`
  that a runtime `if` just proved in-bounds. It is a hook behind the value-form
  seams (`check_hooks`/`subtype_hooks`), so the kernel gains no narrowing logic.

## 2. Research

- **Reference class:** PAPER/IMPL — Typed Racket *occurrence typing*
  (Tobin-Hochstadt & Felleisen, "Logical Types for Untyped Languages") and
  Flow's control-flow-based refinement. Read for the algorithm shape, not copied.
- **Key findings:**
  1. **Guards carry propositions, and branches split the environment.** A test
     `(< i n)` yields a proposition `i < n` on the *then* path and its negation
     `i >= n` on the *else* path; the type of `i` is refined per-occurrence, per
     branch. This is exactly what OURS does: `_narrow` keys on `cname` being
     `"true"`/`"false"` and installs a different `ctx` per arm.
  2. **The proposition must attach to a *variable*, not an arbitrary expression.**
     Typed Racket narrows on `x` when the scrutinee is a predicate applied to a
     path rooted at `x`. OURS mirrors this: it unwinds the comparison `App` spine
     and only narrows an operand whose form is `("var", …)` — a constant or
     compound operand teaches nothing.
  3. **Two flavors of learned fact.** A guard against a *constant* gives an
     interval bound (`i < 64`); a guard against another *variable* gives a
     *symbolic* fact (`i < n`). OURS's docstring makes the entailment for the
     symbolic set a syntactic-subset check — sound, incomplete (it does no
     arithmetic: `i < n` does not entail `i < n+1`).
  4. **Narrowing only tightens an existing refinement.** OURS narrows the operand
     only when its looked-up type is already `VRefine` over `I64` — narrowing
     *adds an atom* to a refinement's predicate conjunction; it never invents a
     refinement on a raw `I64`.

## 3. Conventional (other-language) approach

How this is done outside chirality — the OURS Python `_narrow` hook.

```python
def _narrow(sig, ctx, scrut, cname):
    if cname not in ("true", "false"):
        return None
    # unwind (Prim op) applied to two operands
    t, args = scrut, []
    while t[0] == "App":
        args.append(t[2]); t = t[1]
    args.reverse()
    if t[0] != "Prim" or t[1] not in ("<i", "<=i", "=i") or len(args) != 2:
        return None
    # for each operand that is a *variable* already typed as VRefine I64,
    # add the atom the guard proves (constant -> interval, var -> symbolic)
    ...
```

- **Assumptions it bakes in:** untyped host recursion over raw `("App", …)`
  tuples; the fact database is a mutable Python `ctx` threaded by convention;
  "did we narrow" is a bare `changed` boolean; nothing in the *types* records
  that the else-branch saw the negated fact — the soundness lives in reviewer
  discipline, not in a signature. Partiality is pervasive (`return None` on any
  shape it doesn't understand).

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** refinement types (`(refine I64 …)`), the
  `->` pure membrane (narrowing is inert judgment — it must never touch a port),
  totality (structural recursion on the comparison spine), and the float→I64
  wall (bounds are `I64` atoms only, so entailment stays decidable).
- **The reframing:** narrowing stops being a mutation of an ambient `ctx` and
  becomes a **pure, total function from (guard, environment) to a refined
  environment**, expressed in the surface language it types. The scrutinee is a
  real `data` value (a comparison term), the branches are `case` arms, and the
  learned bound is an *atom appended to a refinement predicate* — a typed value,
  not a side effect. Because narrowing is a `->` function, it is provably
  incapable of I/O: the checker cannot smuggle authority through path-sensitivity.
- **What chirality makes impossible here:** you cannot narrow a value the guard did
  not actually constrain (the operand must be a `var` bound to a refinement, or
  the branch env is returned unchanged), and you cannot claim a bound the atom
  set does not syntactically contain — no "it's probably fine" arithmetic. The
  conventional freedom removed is *silent, untyped mutation of the fact store*.

## Categories note

Category **A, typed**: narrowing is part of the kernel's judgment, correct by
proof, not a bridge over an untyped referent.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")

; --- the payoff: a read whose in-bounds-ness is a TYPING obligation, ---------
; --- not a runtime check. the index must already carry the proof.       ------
; bound is a BARE VARIABLE (< n) over an erased length -- the decidable fragment
; keys symbolic bounds on a variable, NOT on a computed expr like (blen b).
(declare bget-safe
  (-> (0 n I64) Bytes (refine I64 (>= 0) (< n)) I64))

; --- occurrence typing in action: a plain I64 index, narrowed by guards -------
; two nested comparison guards each teach `_narrow` one atom about `i`, so by
; the inner `true` arm `i`'s type has grown from I64 to the refinement bget-safe
; demands. no runtime re-check; the branch condition IS the proof.
(def clamped-read (-> Bytes I64 (Maybe I64))
  (lam (b i)
    (let ((n (blen b)))                   ; bind the length to a bare variable n
      (case (<=i 0 i)                      ; guard 1: constant lower bound
        (true
          (case (<i i n)                   ; guard 2: symbolic upper bound (against n)
            ; here i : (refine I64 (>= 0) (< n))  -- both atoms learned
            (true  (some (bget-safe n b i)))
            ; else arm saw the negated fact:  i : (refine I64 (>= n))
            (false none)))
        (false none)))))

; --- the hook itself, self-hosted: (guard-term, env) -> refined env -----------
; pure and total; a comparison the hook does not understand returns env intact.
(data Bound ()                             ; declared before Guard, which uses it
  (b-const (k I64))                        ; interval atom
  (b-sym   (n Str)))                       ; symbolic atom (syntactic entailment)
(data Guard ()                             ; the shapes _narrow recognizes
  (g-lt  (var Str) (bnd Bound))            ;  var <  bound
  (g-le  (var Str) (bnd Bound))            ;  var <= bound
  (g-none))                                ; not a narrowing guard

; Env (the refinement env) and Atom (a refinement predicate atom) are E9's types;
; opaque here so the hook's signatures are well-formed.
(declare Env  (type 0))
(declare Atom (type 0))

; helpers forward-declared (narrow calls them; spines elided). add-atom appends
; an atom to a var's refinement; {lt,le,ge,gt}-atom build the atom a guard proves.
(declare add-atom  (-> Env Str Atom Env))
(declare pick-atom (-> Bool Atom Atom Atom))
(declare lt-atom   (-> Bound Atom))
(declare le-atom   (-> Bound Atom))
(declare ge-atom   (-> Bound Atom))
(declare gt-atom   (-> Bound Atom))

(declare narrow (-> Env Guard Bool Env))   ; pure: a fact-transform, never a port
(def narrow                                ; type from the declare above
  (lam (env g on-true)
    (case g
      (g-none env)                         ; teaches nothing -> env unchanged
      ((g-lt var bnd)
        (add-atom env var (pick-atom on-true (lt-atom bnd) (ge-atom bnd))))
      ((g-le var bnd)
        (add-atom env var (pick-atom on-true (le-atom bnd) (gt-atom bnd)))))))

; (the atom-constructor and add-atom spines are elided — a real run fleshes them
; plus the syntactic-subset entailment check; all forward-declared above.)
```

- **Knobs to modify:** the recognized comparison set (`g-lt`/`g-le` — add `g-eq`
  to mirror OURS's `=i`); the `Bound` variants (constant interval vs symbolic);
  the entailment strength of `add-atom` (syntactic-subset today, could gain
  bounded arithmetic later); whether `Env` is QTT-erased or a live value.
- **Deliberately omitted:** the actual predicate-conjunction datatype and its
  subtype/entailment decision (that is E9, the refinement engine); the
  comparison-spine unwinder (`(<i i (blen b))` -> `Guard`) that parses a term
  into a `Guard`; and any `data.py` coverage interaction beyond the boolean
  `case`.

## 6. Use / modify notes

- **Lands in:** `scaffold/chirality/refine.py`'s `_narrow` becomes `lib/refine.chiral`
  (the `narrow` function + `Guard`/`Bound` data), consulted via the
  `check_hooks`/`subtype_hooks` value-form seams — never the kernel.
- **Conformance target:** reproduce OURS's golden behavior — a `case` on a
  comparison-guarded boolean narrows *each variable operand already typed
  `VRefine I64`* with the atom the guard proves (constant -> interval, variable
  -> symbolic), returns the env unchanged for any unrecognized shape, and the
  `false` arm learns the negated atom. Symbolic entailment is syntactic-subset.
- **Open questions:** does narrowing compose across *nested* guards by env
  threading (as the snippet assumes) or need an explicit fact-merge? how does a
  symbolic bound "collapse to a constant" when the referenced variable is itself
  a refined constant (OURS's docstring hints at this)? is `Env` linear (`1`) or
  unrestricted?
- **Related:** [[E9-refinement-engine]] (the predicate/entailment decider this
  hook feeds), [[E26-alarms]] (errors-as-values on the failed-bound path).
