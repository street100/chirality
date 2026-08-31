---
element: E47
slug: sized-types
title: Sized types (termination promotion)
kind: BUILD-PROPER
reference_class: PAPER
ours_source: (none)
status: drafted
updated: 2026-07-22
---

# E47 — Sized types (termination promotion)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E47, a *size index* on data types so the termination checker can
  prove a recursive call decreases even when the smaller argument arrives
  *through a function call* rather than directly out of a `case`.
- **Kind:** BUILD-PROPER — designed-not-built; extends the E11 termination
  checker (`data.py check_termination`).
- **Why chirality needs its own:** the current checker (E11) is sound but
  deliberately incomplete — its own comment lists what it rejects: "recursion on
  an accumulator-transformed argument, size-change recursion, lexicographic
  descent, mutual recursion" (`data.py:466-468`). Sized types are the standard
  promotion for the *first two*: they let the checker *prove* a helper returns
  something smaller, so a function total-in-reality but currently classified
  not-proven-total gets promoted. This matters because a chirality-hosted checker
  (the self-host target) is itself full of decrease-behind-a-call recursion
  (NbE, substitution), so without *some* promotion the self-hosted judgment
  cannot be classified total by its own criterion — the exact "principled logic
  layer, infallible primitives" rung-1 obligation.

## 2. Research

- **Reference class:** PAPER — Abel, "MiniAgda / Type-Based Termination and
  Sized Types" (the λ̂ system); Abel & Pientka on sized types in Agda; Barthe et
  al. on type-based termination. Read for the *idea*, reimplement clean.
- **Key findings (load-bearing):**
  1. **A size is an ordinal-ish index carried by a type**, written `List^i A`
     (a list of size < i). Constructors *raise* the size (`cons : A → List^i A →
     List^{i+1} A`); a `case` *lowers* it (matching `List^{i+1}` binds the tail
     at `List^i`). Recursion is admitted when the recursive call is at a
     *strictly smaller* size index — the well-foundedness is now a fact *in the
     type*, checked at the call, not re-derived structurally at each site.
  2. **The decrease travels through function types.** A helper typed
     `f : List^i A → List^i A` (size-*preserving*) or `List^{i+1} A → List^i A`
     (size-*reducing*) lets the caller's checker know `(f xs)` is no larger /
     strictly smaller — which is exactly the "decrease behind a call" the
     structural criterion cannot see. This is the whole point: E11 sees only
     `case`-bound sub-terms; sizes let a *signature* carry the decrease.
  3. **Size is a coeffect-shaped grade, not a value.** A size index scales and
     bounds like the QTT quantities and the E38 cost grades — Abel's `∞` is the
     saturating top exactly like `ω`. `decision-graded-kernel` point 2 already
     anticipated this: "a size index is close enough to a cost grade that if
     sized types land they reuse the semiring machinery." So E47 is a *third
     factor-family* candidate for the frozen carrier, not a bolt-on.
  4. **The complexity sink is size *inference* and size *polymorphism*.** Full
     Abel infers size variables and quantifies over them (`∀ i. List^i → …`).
     That is the part to *not* build first; the minimal fragment (§6) is
     annotation-checked, not inferred.

## 3. Conventional (other-language) approach

Outside chirality, the two live options are (a) accept partiality — most languages
just let this loop — or (b) Agda-style sized types, the reference here:

```agda
-- Agda: the size is explicit, and the checker admits the recursion because the
-- recursive call is at a provably-smaller size j < i, carried in the type.
merge : ∀ {i} → Vec ℕ i → Vec ℕ i → List ℕ     -- (sketch)
merge {i} xs ys with split xs           -- split : Vec ℕ i → Vec ℕ ⌊i/2⌋ × Vec ℕ ⌊i/2⌋
... | (l , r) = ... merge l r' ...      -- l : Vec ℕ j, j < i  ⇒ admitted
```

```python
# Python: no notion at all — this is total in reality but the interpreter will
# happily run it forever if `smaller` ever returns something not-smaller. The
# language offers zero help; "it terminates" is a comment, not a check.
def norm(t):
    if is_redex(t):
        return norm(reduce_step(t))   # decrease is behind reduce_step() — invisible
    return t
```

- **Assumptions it bakes in:** partiality is ambient (the function typechecks
  whether or not it terminates); termination is a runtime hope or a hand proof,
  never a machine-checked fact in the signature; and where a checker *does* care
  (Agda), the price is a full size-inference engine most users fight.

## 4. The chirality idea

- **Chirality features in play:** totality (this *is* the promotion of the E11
  criterion), the graded carrier (`decision-graded-kernel`, E38 — a size is a
  grade-family), data declarations (the size index rides the type, like a QTT
  binder rides a param), refinement (the `< i` bound is decided the same
  interval way E9 already decides numeric bounds).
- **The reframing:** termination stops being *only* a structural walk over
  `case`-bound terms (E11) and gains a *type-carried* channel: a def may declare
  its size behavior in its signature, and the checker admits a recursive call
  whose size argument is strictly smaller by that signature — even across a
  helper. The verdict still lands in `sig.totality[name]`; sized types just
  *expand what is provable-total*, they don't change the enforcement seam
  (`sig.require_total` / the `(total)` profile clause).
- **What chirality makes impossible here:** declaring a size-reducing signature a
  function does not honor (a constructor raises the size, so `f : T^{i+1} → T^i`
  that returns its input unshrunk fails to typecheck — the reduction claim is
  checked, not trusted); and — the payoff — a self-hosted checker function whose
  decrease is real but structurally-invisible can now be *classified total*
  rather than left in the not-proven bucket, closing the gap that would
  otherwise force the chirality checker to run under a partiality escape hatch.

## 5. Chirality example (fleshed)

The minimal fragment: a size annotation on a data type, a size-reducing helper
signature, and the recursion it unblocks. Sizes written `^i` as a type-level
grade argument; `s0`/`(ssuc i)` are the size expressions.

```chirality
(import "prelude")

; ---- a size-indexed type: the index is an erased grade param, not a value ----
; (Nat) is the size algebra; s0 the base, ssuc the raise, sinf the saturating top.
(data Nat () (s0) (ssuc (n Nat)) (sinf))

; List carries a size: cons RAISES it, so a (SList (ssuc i)) is strictly bigger
; than its tail at (SList i). The index is erased (0) — compile-time only.
(data SList ((0 i Nat) (0 A (type 0)))
  (snil)                                        ; : SList s0 A
  (scons (x A) (xs (SList i A))))               ; : SList (ssuc i) A  (raise)

; ---- a size-REDUCING helper: the signature is the decrease certificate -------
; halve returns a list at a strictly smaller size than its input. The checker
; verifies scons raises and case lowers, so this claim is CHECKED, not trusted.
(declare halve (-> (0 i Nat) (SList (ssuc i) A) (SList i A)))
; (def halve ...) ; drops every other element; each scons in the result is
;                 ; built from a doubly-lowered tail — elided ; …

; ---- the recursion E11 rejects, promoted by the size signature ---------------
; msort recurses on (halve xs). Structurally, (halve xs) is NOT a case-bound
; sub-term of xs, so check_termination (data.py) leaves it not-proven-total.
; With sizes: halve's result is SList i (< the input's ssuc i), so the call is
; at a strictly smaller size and the checker ADMITS it.
(declare msort (-> (0 i Nat) (SList i A) (List A)))
(def msort
  (lam (i xs)
    (case xs
      ((snil)          nil)
      ((scons y ys)
       ; at this arm xs : SList (ssuc i'), ys : SList i'  (case lowered)
       ; (halve xs) : SList i'  — strictly smaller than (ssuc i') ⇒ recursion ok
       (merge (msort (halve xs)) (msort (halve-odd xs)))))))   ; … helpers elided

; ---- the enforcement seam is UNCHANGED ---------------------------------------
; A profile's (total) clause / sig.require_total still gates; sized types only
; widen sig.totality[msort] from a reason-string to None (proven total).
```

- **Knobs to modify:** the size algebra (`Nat` with `sinf` here; a bounded
  fragment omits `sinf`); which types carry an index (only recursive ones that
  appear in decrease-behind-a-call sites need it); whether the index reuses the
  E38 grade seat or is a distinct erased type param (the open question, §6).
- **Deliberately omitted:** size *inference* (here every size is annotated);
  size *polymorphism* / `∀i` quantification beyond the erased-param form shown;
  higher-rank size use; the interaction with the coverage checker (a size-lowered
  `case` must still be exhaustive — mechanical, but real).

## 6. Use / modify notes

- **Lands in:** `scaffold/chirality/data.py` — `check_termination` / `_totality_reason`
  gain a size channel: when a recursive call's decreasing argument is the result
  of a size-reducing signature, admit it (record `None` in `sig.totality`).
  The size index itself is declared machinery in the `data` layer (like strict
  positivity and linear kinds — it must see through `Con`/`Case`, which the
  kernel core does not). Surface: a size grade on `data` params.
- **Conformance target:** (a) every def E11 already proves total stays proven;
  (b) `msort`-shaped defs (recurse on a size-reducing helper) promote from
  not-proven to proven; (c) a *false* size-reducing signature (returns input
  unshrunk) is REJECTED at the helper's own definition — the negative test is
  the soundness guarantee; (d) the differential against the existing
  `TestTermination` suite is unchanged.
- **Open questions:**
  1. **Grade seat vs distinct index** — does the size ride the E38 carrier grade
     factor (`decision-graded-kernel`'s "reuse the semiring machinery") or a
     separate erased `Nat` type parameter as sketched here? The grade route
     unifies the machinery but spends a frozen factor seat on a property that is
     about *arguments' shapes*, not *resource use* — an author call, tied to the
     E38 carrier decision.
  2. **Minimal fragment scope** — is annotation-checked-only (no inference)
     enough for the self-hosted checker, or do a handful of its functions force
     size polymorphism? Measure against the actual checker source, not a priori.
  3. **Interaction with numeric measures (E11's built fragment)** — a def may be
     provable *either* by the existing distance-to-bound measure *or* by a size;
     the checker should try the cheap structural/measure route first and only
     consult sizes when it fails, to keep common code annotation-free.
- **RUNG-1 VERDICT (the key finding this pre-run owes):** **Deferrable behind
  E48 + E50, but only partially, and here is the honest line.** The self-host
  blockers are E48 (telescopes — the checker's *signatures* need dependent
  fields) and E50 (mutual + lexicographic termination — `infer`/`check`,
  `eval`/`quote`/`conv` are *mutually* recursive, which E47 does **not**
  address; sizes promote single-function decrease-behind-a-call, mutual groups
  are E50's job). So E47 is **not** on the critical path *for making the checker
  classifiable* — E50 is the one that unblocks the mutual-recursion heart, and
  much of the checker's remaining recursion is either structural (already
  proven) or mutual (E50). E47 earns rung-1 inclusion only *if* specific checker
  functions have genuine single-recursive size-change decrease (merge-sort-shaped
  or normalize-then-recurse where the reduct is provably smaller). **Recommend:
  defer E47 to a fast-follow, gate its inclusion on an audit of the actual
  self-hosted checker source AFTER E48/E50 land** — if that audit finds N
  functions that are single-recursive-but-size-change, build the minimal
  annotation-checked fragment for exactly them; if it finds them all mutual or
  structural, E47 is a rung-2 completeness item, not a rung-1 obligation.
- **Related:** [[E11-totality-checker]] (the criterion this promotes),
  [[E50-mutual-termination]] (the sibling, and the actual rung-1 blocker),
  [[E48-telescopes]] (the other rung-1 blocker; dependent signatures),
  [[E38-graded-cost]] (the carrier the size index may ride),
  `docs/decision-graded-kernel.md` (point 2: size ≈ cost grade),
  `docs/totality.md` (the enforcement seam).
