---
element: E50
slug: mutual-lex-termination
title: Bidirectional/mutual termination + lexicographic measures
kind: BUILD-PROPER
reference_class: PAPER
ours_source: (none)
status: drafted
updated: 2026-07-22
---

# E50 — Bidirectional/mutual termination + lexicographic measures

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> **Rung-1 self-applicability blocker:** the checker's own source is mutually
> recursive, so chirality cannot prove *itself* total until this lands — and a
> principled/infallible rung 1 requires the checker be total.

## 1. Scope

- **Element:** E50, the third totality pillar's missing half — termination
  across a **mutual recursion group** (functions that call each other), and
  **lexicographic measures** (a tuple decreasing left-to-right) for descents no
  single measure ranks. Extends the built single-function pillar (E11).
- **Kind:** BUILD-PROPER — designed-but-unbuilt; the scaffold's
  `check_termination` proves structural + numeric-measure recursion for
  *single-function self-recursion only* (`data.py`), and a mutual group returns
  the reason `"mutual recursion is not yet checked for totality"`
  (`data.py:669`), so it classifies as **not proven total**.
- **Why chirality needs its own:** this is the sharpest rung-1 self-hosting
  requirement. The checker is bidirectional — `infer` and `check` are *mutually
  recursive*, as are `eval`/`quote`/`conv` and the positivity `walk`/`mentions`
  pair. None of those groups can be proven total by a single-function measure,
  so `chirality verify (total)` over the self-hosted checker fails at exactly its
  own heart until E50 exists. "The checker is proven total over its own source"
  is a rung-1 infallibility claim (E52's trusted core must terminate on
  well-typed input), and it is unreachable without mutual + lexicographic
  measures.

## 2. Research

- **Reference class:** PAPER — **size-change termination** (Lee, Jones,
  Ben-Amram, POPL'01): abstract each call by which arguments strictly decrease
  or stay equal, then a program terminates iff every infinite call sequence
  would decrease some value infinitely (a graph condition over the call
  edges). **foetus** (Abel) is the same idea specialized to structural
  descent, and is what Agda/Coq use. **Lexicographic measures** are the classic
  tuple order for nested descent. Tier P: read the idea; reimplement clean.
- **Key findings:**
  1. **Mutual termination is a property of the recursion *group*, not the
     function.** Compute the call graph's strongly-connected component; a
     measure must be **non-increasing on every intra-group edge and strictly
     decreasing around every cycle** (size-change's core condition). Single-
     function analysis is the degenerate case (a one-node SCC).
  2. **The checker's groups have a *shared structural argument*, which is the
     cheap form.** In `infer`/`check`, the subject **term** is that argument:
     `infer` recurses only on strict subterms, and the one non-decreasing edge
     (`check t T` falling back to `infer t` on the *same* `t`) is
     *non-increasing*, so every cycle `check → infer → check` returns on a
     strict subterm. A **declared shared structural measure** (the term) proves
     the whole group — no full size-change graph needed. Full size-change is
     only required when arguments *permute* across the cycle (rare in the
     checker); it is the fallback tier, not the default.
  3. **Lexicographic is for genuine nested descent** — a measure `(a, b)`
     compared left-to-right: an edge is admissible if some position strictly
     decreases and all earlier positions stay equal. The checker needs it where
     a bounded unfolding budget decreases *or* (budget equal) the term shrinks —
     `conv` under definition-unfolding is the case.
  4. **It classifies exactly like the built pillar.** The result still lands in
     `sig.totality[name]` (None = proven total, else a reason) and enforces via
     `sig.require_total` / a profile `(total)` clause — E50 replaces the
     blanket mutual-recursion reason with a real per-group verdict.

## 3. Conventional (other-language) approach

Mainstream languages do not prove mutual termination *at all* — they permit
general recursion and accept non-termination as an ambient effect:

```haskell
-- Haskell: infer/check mutually recursive, total by nobody's checking.
-- Nothing rejects a diverging pair; nothing certifies a terminating one.
infer :: Ctx -> Term -> Ty
infer ctx (App f a) = let piTy = infer ctx f in check ctx a (dom piTy) ...
check :: Ctx -> Term -> Ty -> ()
check ctx t ty = let ty' = infer ctx t in unify ty ty'   -- same t: unranked
```

Agda and Coq *do* prove it, via exactly the size-change / foetus lineage above —
a `{-# TERMINATING #-}` escape hatch exists precisely because the checker
otherwise *demands* the proof.

- **Assumptions the mainstream bakes in:** non-termination is an acceptable
  effect (P2 forbids the exemption); a mutually-recursive group is just a set of
  functions with no group-level obligation; "it typechecks" says nothing about
  whether evaluation halts — so a checker written this way cannot certify *its
  own* halting, which is the one thing a trusted core must.

## 4. The chirality idea

- **Chirality features in play:** totality as a classified-then-enforced property
  (`sig.totality`, the E11 pillar), structural recursion, the call graph chirality
  already computes for the effect row (`decision-effect-facets` — the *same*
  graph an SCC pass consumes), result-sum verdicts, `->` purity (the checker is
  pure).
- **The reframing:** termination stops being a per-`def` question and becomes a
  **per-recursion-group** one. The termination checker (a) finds SCCs in the
  already-built call graph, (b) for each multi-node SCC consults a **declared
  shared measure** — a structural argument every member decreases-or-holds, or a
  lexicographic tuple — and (c) verifies the size-change condition on the group's
  edges. A one-node SCC is the existing single-function check unchanged, so E50
  is a *generalization* of the built pillar, not a second mechanism. The
  measure is declared, not inferred, keeping the checker itself small and total
  (inference is a later, untrusted producer that emits a measure the core
  re-checks — certificate discipline).
- **What chirality makes impossible here:** a mutually-recursive definition that
  silently diverges (the group carries a reason in `sig.totality` until a
  measure proves it, and `(total)` makes the reason a hard error); a checker
  that cannot vouch for its own halting (the self-hosted `infer`/`check` group
  proves total by the shared term measure, so the trusted core is provably
  terminating on well-typed input — E52's normalization obligation discharged);
  a nested descent passed off as structural (lexicographic positions are
  explicit — no hand-wave that "it obviously shrinks").

## 5. Chirality example (fleshed)

The bidirectional checker's own `infer`/`check` group — the concrete blocker —
plus the proposed group/measure surface (a BUILD-PROPER: the annotation form is
an open question, §6, like E38's `graded`).

```chirality
(import "prelude")

; ---- the term the group recurses on -------------------------------------
(data Term ()
  (tm-var (i I64))
  (tm-app (f Term) (a Term))
  (tm-lam (body Term))
  (tm-ann (t Term) (ty Term)))

; ---- the mutual group: infer <-> check ----------------------------------
; PROPOSED surface: a recursion group names its members and ONE shared
; structural measure. The checker verifies: every intra-group call passes a
; sub-term-or-equal of the measured argument, and every cycle strictly
; decreases it. `t` is that argument in both.
(recgroup ((measure structural t))       ; t : Term, the shared subject
  (declare infer (-> Ctx Term InferR))
  (declare check (-> Ctx Term Ty CheckR)))

; infer recurses only on STRICT subterms -> decreasing edges
(def infer
  (lam (ctx t)
    (case t
      ((tm-app f a)   (case (infer ctx f)          ; f < (tm-app f a): decreases
                        ((got-pi dom cod)
                         (case (check ctx a dom)    ; a < (tm-app f a): decreases
                           ((chk-ok)  (inf-ok (inst cod a)))
                           ((chk-err m) (inf-err m))))
                        ((got-non-pi) (inf-err "applied a non-function"))))
      ((tm-ann tm ty) (case (check ctx tm ty)       ; tm < (tm-ann tm ty): decreases
                        ((chk-ok) (inf-ok ty))
                        ((chk-err m) (inf-err m))))
      ((tm-var i)     (ctx-lookup ctx i))
      ((tm-lam body)  (inf-err "cannot infer a bare lambda")))))  ; check-only

; check's fallback calls infer on the SAME t -> the NON-INCREASING edge.
; single-function analysis of `check` alone cannot rank this; the GROUP can,
; because infer's own recursion is all strict-subterm.
(def check
  (lam (ctx t ty)
    (case t
      ((tm-lam body) (case ty
                       ((v-pi dom cod) (check ctx body cod))   ; body < (tm-lam body)
                       (else (chk-err "lambda vs non-Pi"))))
      (else (case (infer ctx t)          ; SAME t: non-increasing, group-ranked
              ((inf-ok ty2) (if (conv-ty ty ty2) chk-ok (chk-err "mismatch")))
              ((inf-err m)  (chk-err m)))))))

; ---- lexicographic: the nested-descent case (conv under unfolding) -------
; measure is a TUPLE (budget, term): unfolding a definition spends budget;
; structural recursion holds budget and shrinks the term. Left-to-right:
; an edge is OK if budget drops, OR budget equal and the term shrinks.
(recgroup ((measure lexicographic (fuel I64) (structural u Term)))
  (declare conv-nf (-> I64 Term Term Bool)))
; (unfold t) -> (conv-nf (- fuel 1) t' ...)   ; position 0 strictly decreases
; (tm-app f a)(tm-app g b) -> (conv-nf fuel f g)  ; pos 0 equal, pos 1 shrinks
```

- **Knobs to modify:** the measure kind per group (`structural` shared arg,
  `lexicographic` tuple, or the `size-change` fallback for permuted args); the
  term rep (the real one is E13/E3's); which groups are declared `(total)`.
- **Deliberately omitted:** the SCC-finding pass (mechanical over the call
  graph chirality already builds for the effect row); size-change *inference* (a
  later untrusted producer — the core only re-checks a declared measure); the
  `eval`/`quote`/`conv` group (same shared-measure shape as infer/check, on the
  value/term).

## 6. Use / modify notes

- **Lands in:** `scaffold/chirality/data.py` `check_termination` / `_totality_reason`
  — the mutual-recursion branch (`data.py:669`) stops returning a blanket reason
  and instead runs the group analysis, filling `sig.totality` per member; the
  surface gains the `recgroup`/`measure` forms (E49-era, or a `(declare ...)`
  attribute in the interim).
- **Conformance target:** the negative test is the point — a genuinely
  diverging mutual pair still gets a reason and `(total)` rejects it; and the
  positive milestone: the self-hosted `infer`/`check` and `eval`/`quote`/`conv`
  groups **prove total** under a declared shared structural measure, so
  `chirality verify (total)` passes over the checker's own source (the rung-1
  self-applicability gate). Cross-check: every currently-total single-function
  def stays total (one-node SCC = the existing check).
- **Open questions:** the **measure-declaration surface** (a `recgroup` form vs
  a per-`def` `(measure …)` attribute vs full inference); whether the checker's
  groups need only declared shared measures or whether any group (conv?) forces
  the full size-change graph — **finding: infer/check and eval/quote need only a
  declared shared structural measure (the subject term/value); lexicographic
  covers conv-under-unfolding; full size-change is a reserved fallback for
  argument-permuting groups, which the checker largely lacks** — so the cheap
  tier suffices for self-hosting and full size-change can be deferred; and how a
  measure becomes a **certificate** E52's core re-checks (declared-and-verified,
  not trusted from an inference pass).
- **Related:** [[E11-totality-checker]] (the single-function pillar this
  generalizes — one-node SCC), [[E47]] (sized types — the sibling promotion
  path for numeric measures; the boundary: sized types carry the bound *in the
  type*, E50 carries it in a *measure* over structural/lexicographic args —
  complementary, not overlapping), [[E52-certificate-split]] (the trusted core's
  normalization/termination obligation this discharges), [[E03-nbe-normalize]] /
  [[E04-bidir-universes]] (the mutual groups being proven).
