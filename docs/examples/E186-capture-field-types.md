---
element: E186
slug: capture-field-types
title: "**The `$k<i>_<j>` capture constructor's field types: concrete, or the erased word**"
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: reviewed
updated: 2026-09-04
---

# E186 — **The `$k<i>_<j>` capture constructor's field types: concrete, or the erased word**

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E186, whether the `$k<i>_<j>` capture constructor's declared field
  types are spelled with the capture's own concrete type or with the erased word,
  at the lowering type level.
- **Kind:** BUILD-PROPER as minted.
- **Why chirality needs its own:** the fork exists here and nowhere else because
  chirality carries **two** type levels with different vocabularies.
  [[decisions/decision-erased-word-level]] rules that the erased word lives
  strictly at the lowering level, that `Core` gains no word spelling, and that
  the kernel's `conv` relation is untouched. The `$clo<i>` data declaration that
  `closconv-sig` mints is a kernel `DataDecl` whose fields carry `Term`, so one
  side of this fork cannot be written in the artifact the pass produces. Naming
  the fork honestly is what this element is for.

⚑ **What this pre-run finds, stated up front.** The ruling is **concrete**, and
the tree already implements it. The redness that made the question look like a
defect (`$apply7` through `ck-con`) was the **dispatcher's** side and E185 fixed
it. The residue is an unstated type rather than a wrong one, and it is already
E187's. The cut is in §6.

⚑ **Not a phantom feature.** Before naming any gap here, [[banks/erasure]] was
read. Its shard **G** is exactly the machinery this element is about,
`term->ntalty` reaching `(nt-word)` from a type variable, and the bank measures
it **built**. Its shard **E** is `shape-eq`, the family merge, built. Its shard
**D** is E100's type-kinded capture drop, built. "The capture fields have no way
to reach the erased word" would have been a phantom feature; they have two, and
both are live.

## 2. Research

- **Reference class:** `OURS` (the tree itself is the baseline) over `PAPER`,
  through `.planning/RESEARCH-EN15-prior-art.md` §7. The agent tier is tracked
  since 2026-09-01 ([[decisions/decision-ai-tier]]), so that citation resolves in
  a fresh clone. No web fetch was made and none was needed.

**F1. Both published shapes keep constructor fields CONCRETE.** Research §7:
Pottier and Gauthier's `succ : Arrow int int` carries concrete field types beside
concrete arrow indices, and the dispatcher's branch recovers the indices from the
GADT equation. Minamide, Morrisett and Harper (POPL 1996) hide a heterogeneous
environment behind `∃`, with the record's field types concrete inside the pack.
Huang and Yallop's label-context entry keeps the captures at their source types.
The prior art erases **neither** side nominally: it makes the dispatcher
polymorphic and lets the constructor stay concrete.

**F2. The structural reason the two instances differ.** A capture constructor,
spelled by `ctor-name` (`lib/lowering/upper/closconv.chiral:1181`), is applied at
exactly one site, its own definition site, so nothing forces its field types to
merge with another constructor's. The shared dispatcher's argument position is
constrained by every member of the family at once. Only the second is under
merge pressure, so only the second has to erase.

**F3. The measured arrangement was the opposite, and E185 flipped it.** EN-17
([[records/enforcement-arc]]) recorded `$apply7` reddening through `ck-con`'s
field check (`lib/lowering/tal/check.chiral:183-196`) rather than through
`ck-args` (`:148-156`), which is the constructor being the varying side and the
dispatcher the concrete one. EN-18 measures what E185 did to that: **1,477 of
1,481 accept before, 1,482 of 1,484 after**, `$apply4` and `$apply7` accepting
outright, the two survivors `$apply5` and `$apply6` in a different class (`ret`).
E185 did not touch a single field type. It stated the **dispatcher's** parameters
as `nt-word`, and `tal-ty=?`'s first arm (`:68-70`) makes a `tt-word` source
register match a concrete field type. So the constructor was never the wrong
side; the dispatcher was, and repairing the dispatcher put the tree on exactly
the arrangement F1 describes.

**F4. The tree already spells the fields the way the ruling calls for, and it
did so before the question was asked.** Two functions in series:
`site-fields->term` (`lib/lowering/upper/closconv-driver.chiral:153-163`) spells
each kept field as `(core->term fty)`, the capture's own source type at its own
site; `field-tys->n` → `term->ntalty` (`lib/lowering/compile-front.chiral:58-73,
:238-245`) then maps a `t-pi` field and a `t-var` field to `(nt-word)` and every
other field to its concrete `NTalTy`. Concrete where a concrete type exists, word
where the source itself has none. That is F1's arrangement, built, and
[[banks/erasure]] shard G already carries the second half of it.

## 3. Conventional (other-language) approach

Pottier and Gauthier's defunctionalization with GADTs, in **OCaml**. The
arrow-indexed family is the direct ancestor of `$clo<i>` / `$k<i>_<j>` /
`$apply<i>`, and it is the reference research §7 reads.

```ocaml
(* the closure family, indexed by the arrow it stands for.  Each constructor
   carries its OWN captures at their OWN concrete types. *)
type (_, _) arrow =
  | Succ  : (int, int) arrow                     (* no captures *)
  | AddN  : int -> (int, int) arrow              (* one capture, concretely int *)
  | Comp  : ('a, 'b) arrow * ('b, 'c) arrow -> ('a, 'c) arrow

(* the shared dispatcher.  Its argument is polymorphic, and the GADT equation
   recovers the concrete indices inside each branch. *)
let rec apply : type a b. (a, b) arrow -> a -> b =
  fun f x -> match f with
    | Succ      -> x + 1                          (* a = int, b = int, recovered *)
    | AddN n    -> x + n                          (* n : int, concrete *)
    | Comp (g, h) -> apply h (apply g x)
```

- **Assumptions it bakes in:** a source type system rich enough to hold the
  equation. OCaml's GADT refinement *is* the recovery mechanism, so the concrete
  field types and the polymorphic dispatcher argument both live in one language
  at one level. The compiler does not have to state anything: the type checker
  it already ran carries the fact forward.
- **What it silently assumes chirality does not have:** that the target of the
  pass can express the same types as its source. Here the pass rewrites `Core`
  into `Core` and then a *second*, coarser vocabulary (`NTalTy`) reads the
  result, and the two do not agree on what a type is.

## 4. The chirality idea

- **Chirality features in play:** the two type levels and the one-way door
  between them; erasure as three independent mechanisms rather than a phase
  ([[banks/erasure]]); the QTT `q=0` capture drop that runs *before* any of this
  (E100, shard D); one instrument per level ([[banks/verification]]).

**The reframing.** The fork is not "concrete or word" as a free choice. It is
asymmetric, because the two answers cost different things:

| answer | what it costs |
|---|---|
| **concrete** | nothing. `site-fields->term` already writes `(core->term fty)` and `field-tys->n` already reads it |
| **the erased word** | the `$clo` data path has to gain a stated channel it does not have. `Field` carries a `Term`, `Core` has no word spelling by ruling, so there is **no `Term` that spells `nt-word`** and the pass cannot say it in its own output |

That second row is the whole point, and it is the same reason `CCOut`
(`lib/lowering/upper/closconv-driver.chiral:142`) exists at all: E185 had to
invent a channel *beside* the `Sig` because a `Sig` global holds a `Term` and no
`Term` spells the erased word. Choosing "word" for the fields means building the
same channel a second time, for datas rather than globals, which is E187's
`$clo<i>` half and runs through `datas->n`
(`lib/lowering/compile-front.chiral:254-261`), a path the `sp` stated channel
does not reach. `peel-def` (`:211-223`) consults `sp` for globals only.

**What chirality makes impossible here.** Three things, and each closes a route
another language leaves open.

1. **You cannot widen the source relation to buy this.** A `Word` converting with
   `I64` and with `(List Str)` makes `I64` convert with `(List Str)`, because
   conversion is transitive. [[decisions/decision-erased-word-level]] refuses it
   and the source type system stays intact.
2. **You cannot say "word" in the pass's own output.** The ruling that keeps
   `Core` clean is exactly what makes the erased-field answer unwritable without
   a new channel. The constraint is structural.
3. **You cannot recover the concrete type later.** Once a field is `nt-word`, no
   downstream reader gets it back, and `tal-ty=?`'s first arm makes `tt-word`
   match everything. Spelling a known-concrete field as the word is a **strictly
   weaker check bought for nothing**, since the one construction site already
   holds the concrete type.

⚑ **`ck-prog`'s field and return checks are not reliable detectors, and §6's
gate must not lean on them.** EN-20 measured why: when a family's codomain is
ground, `const 0` matches the declared return and the checker accepts wrong code
in silence. The compiler's own two instances redden only because their codomain
happens to be `(List Asm)`. The same asymmetry applies to fields: a `tt-word`
field type accepts **any** register, so erasing the fields would remove the only
type-level pressure on the construction site while removing no defect. The
general claim that nothing in this pass miscompiles is **retired**.
[[records/enforcement-arc]] EN-20 demonstrates a live wrong-code defect end to
end on today's binary, and it is [[E188]].

## 5. Chirality example (fleshed)

The ruling, as the code that already carries it, plus the one predicate a gate
would assert. Real surface syntax, skeleton form.

```chirality
; ─────────────────────────────────────────────────────────────────────────────
; (a) THE SPELLING, AS IT STANDS.  lib/lowering/upper/closconv-driver.chiral.
;     One $clo ctor field per KEPT capture, at the capture's own source type.
;     This is the concrete side of the prior art's arrangement, already built.
; ─────────────────────────────────────────────────────────────────────────────
(declare site-fields->term (-> I64 (List (Pair I64 Core)) (List Field)))
(def site-fields->term
  (lam (n fs)
    (case fs
      (nil nil)
      ((cons p r)
        (case (field-erased? p)
          ; E100 / shard D: a q=0 or Type-kinded capture has NO runtime witness.
          ; It is dropped here, and `n` does not advance, so the kept cap#
          ; numbering stays aligned with cap-names and the arm binder count.
          (true (site-fields->term n r))
          ; the kept case: (core->term fty) is the capture's OWN type, concrete.
          ; E186 rules this stays.  The one application site of $k<i>_<j> holds
          ; that same type, so nothing forces a merge and nothing is bought by
          ; coarsening it.
          (false (case p ((pair q fty)
            (cons (field q (str-cat "cap" (i64->str n)) (core->term fty))
                  (site-fields->term (+ n 1) r))))))))))

; ─────────────────────────────────────────────────────────────────────────────
; (b) WHERE THE ERASED WORD IS ALREADY REACHED, by the ordinary peel.
;     lib/lowering/compile-front.chiral.  A field whose SOURCE type has no
;     ground spelling -- a type variable, or an arrow -- lowers to (nt-word).
;     Every other field keeps its concrete NTalTy.  Bank shard G.
; ─────────────────────────────────────────────────────────────────────────────
(def term->ntalty (lam (t)
  (case t
    ((t-var i)        (some (nt-word)))     ; erased type variable in a kept slot
    ((t-pi _ _ _ _)   (some (nt-word)))     ; an arrow capture is pointer-sized
    ((t-refine base atoms) (term->ntalty base))
    ((t-tcon dn args) (case (term->ntalty-list args)
                        ((some ts) (some (nt-data dn ts)))
                        (none      (none))))
    ; …  the primty arms
    (_ (none)))))

; ─────────────────────────────────────────────────────────────────────────────
; (c) THE INVARIANT E186 PINS, and what a gate asserts.  Not new machinery:
;     a predicate over what the pass already emits, so a later change that
;     re-coarsens a field or re-concretes a dispatcher parameter goes red.
;
;     THE ASYMMETRY IS THE CLAIM.  For one family i:
;       every $k<i>_<j> field type      is CONCRETE unless its source is t-var
;                                       or t-pi, in which case it is nt-word;
;       every $apply<i> parameter type  is nt-word, except the leading
;                                       (nt-data $clo<i> nil).
; ─────────────────────────────────────────────────────────────────────────────
(data Side () (s-ctor (dname Str) (ftys (List NTalTy)))
              (s-disp (aname Str) (ptys (List NTalTy))))

(declare word? (-> NTalTy Bool))
(def word? (lam (t) (case t ((nt-word) true) (_ false))))

; the dispatcher side: leading $clo, then nothing but the word.  `i` is the
; family index, because the claim names $clo<i> and nil args, not "some data".
(declare disp-erased? (-> I64 (List NTalTy) Bool))
(def disp-erased?
  (lam (i ts) (case ts
    (nil false)                                   ; a dispatcher has >= 1 param
    ((cons lead r) (case lead
      ((nt-data dn as) (case as
        (nil (and (str-eq dn (clo-name i)) (all-word? r)))
        (_ false)))                               ; $clo<i> takes no type args
      (_ false))))))

; the constructor side: a field is word ONLY where its source had no ground
; spelling.  `srcs` is the aligned (List Term) site-fields->term wrote.
(declare ctor-honest? (-> (List Term) (List NTalTy) Bool))
(def ctor-honest?
  (lam (srcs ftys)
    (case srcs
      (nil (case ftys (nil true) (_ false)))
      ((cons s sr) (case ftys
        (nil false)
        ((cons f fr) (case (and (word? f) (not (no-ground-spelling? s)))
          (true  false)          ; a concretely-spellable field went word: RED
          (false (ctor-honest? sr fr)))))))))

; …  no-ground-spelling? is (t-var|t-pi)?, one case over Term
; …  all-word? is the fold; both elided
```

- **Knobs to modify:** `no-ground-spelling?`'s two arms are the exact list of
  source shapes allowed to reach the word, and they track `term->ntalty`. A
  future shard that adds a third erasing arm has to widen both together, and the
  predicate going red is how that is noticed. `disp-erased?` is the E185 side and
  is already what `apply-ptys` builds.
  ⚑ **One arm short of the exact preimage, named by the audit 2026-09-04.**
  `term->ntalty`'s refine arm recurses into the base
  (`lib/lowering/compile-front.chiral:69`), so `(refine <t-var> …)` reaches
  `(nt-word)` too and the preimage of the word is closed under `t-refine`. Two
  arms are the honest reading of what the compiler's own fields hold today;
  `no-ground-spelling?` has to recurse through `t-refine` the moment a refined
  type variable or a refined arrow becomes constructible, and the predicate
  would otherwise redden on correct output.
- **Deliberately omitted:** the `∃`-packed alternative. MMH's existential
  environment is the other published shape, and it is not reachable here:
  `NTalTy` has no arrow former and no quantifier, so the pack has nowhere to
  live. Recording it as considered and unreachable is the point of naming it.

## 6. Use / modify notes

- **Lands in:** ⚑ **no `lib/` or `prog/` file, for E186 itself.** The ruling
  lands in [[decisions/decision-erased-word-level]]'s "What this does not settle"
  section, which currently holds the capture-constructor question open, and the
  measurement lands in [[records/enforcement-arc]] EN-17. The predicate in §5(c)
  lands beside the E185 gate, `tools/test/apply-word.sh`, whose registration is
  already an open author call (`records/gate-audit.md` GA-24). The residue that
  *does* touch compiler source is E187's, at
  `lib/lowering/upper/closconv-driver.chiral` and
  `lib/lowering/compile-front.chiral`.

- **Conformance target:** the reject set does not move. EN-18's measurement,
  **1,482 of 1,484 accepting, the two rejects `$apply5` and `$apply6` in the
  `ret` class**, with **no reject in the `con:` class**. The byte fixpoint and
  the suite line are untouched, because nothing in the compiler's blob changes.
  ⚑ The target is a **non-regression**, and it must be read together with §4's
  warning: a green `ck-prog` does not certify the fields, it certifies that
  nothing contradicts them.
  ⚑ **Stated all the way, by the audit 2026-09-04: today's tree already meets
  this target with no work done, and it would meet it under the opposite
  ruling too.** So the reject set is the wrong thing to grade E186 on. The one
  assertion that separates `concrete` from `word` is §5(c)'s `ctor-honest?`,
  which reddens exactly when a concretely-spellable field is spelled as the
  word, and open question 2 recommends deferring its build to E187. If the SPEC
  takes that recommendation, E186 ships with a gate that today's tree passes
  untouched, which is what `docs/definitions/working-discipline.md` names as a
  gate that cannot fail. Binding the two is the SPEC stage's call and open
  questions 1 and 2 are where it is put.

### The judgment this pre-run owes

**E186 stands as its own element, and it does not split.** It resolves rather
than builds, and the cut runs three ways.

1. **E186 keeps the ruling, and the ruling is `concrete`.** Three independent
   grounds converge, which is what makes this answerable without the author's
   taste. The prior art (F1) keeps fields concrete in both published shapes. The
   structure (F2) puts the constructor at one application site, so no merge
   pressure exists to erase it. And the measurement (F4) finds the tree already
   doing it, with the word reached at exactly the two source shapes that have no
   ground spelling. A ruling that agrees with the literature, the structure and
   the code is a ruling rather than a preference.

2. **E186 does not keep a build, because the redness that motivated it was the
   other element's.** `$apply7`'s `ck-con` failure was read as evidence about the
   fields. EN-18 measures it disappearing under a change that touched **no field
   type at all**: E185 stated the dispatcher's parameters as `nt-word` and the
   field check passed on the source-register side. So the observable was the
   dispatcher's, it is spent, and E186 has no measured defect left to repair.

3. **The residue is E187's, already scoped, and needs no mint.** What remains is
   that the field types are **correct and reconstructed rather than stated**:
   `bridge-sig` reads them through `datas->n`, a path the `sp` stated channel
   does not reach. E187's own row already names this as its `$clo<i>` half, in
   those words. Extending the stated channel to datas is one job with one shape,
   and splitting it across two elements would put half a channel in each.

4. **It is not E188, and EN-19 already drew that line.** E188 is a body returning
   the wrong **value**. No field type, concrete or word, repairs it; erasing the
   codomain would only hide it. Concurring rather than re-deciding.

⚑ **Nothing is minted here.** `E189` is the last free number in Lane A's reserved
band, shared with the diagnostics arc ([[decisions/decision-lane-split]]), and
this pre-run's recommendation is that **no mint is needed at all**: the residue
has an owner. If the SPEC stage disagrees and wants the datas channel separated
from E187's other two halves, that mint is the SPEC stage's to make and its cost
is the band's last number.

- **Open questions:**
  1. **Does E186's SPEC produce a change plan, or a ruling and a gate row?** This
     pre-run recommends the second: a documentation delta plus the §5(c)
     predicate wired into the E185 gate, with no commit inside the compiler's
     blob and therefore no `build-new → test → promote`. That is unusual for a
     `BUILD-PROPER` row and the SPEC stage should say so out loud.
  2. **Is the §5(c) predicate worth building before E187 lands?** It asserts an
     invariant over two producers, and E187 is going to rewrite one of them. The
     cheap answer is to specify it in E186 and build it inside E187, where both
     sides are in hand at once.
  3. ⚑ **A stale citation this pre-run found and did not fix.** The catalog's
     E187 row cites the three name spellings at
     `lib/lowering/upper/closconv.chiral:1097-1099`; they are at `:1112-1114`,
     15 lines low, which is E185's own insertion. `docs/elements/ledger.md`'s
     E187 row already says `:1112-1114`, so the catalog and the ledger disagree
     in prose while check J passes on state. `records/enforcement-arc.md` EN-17's
     evidence carries the same `:1099`. Three coordinates in another element's
     row, so this run leaves them; they belong to E187's pre-run or to a
     `doc-audit` pass.
     ⚑ **REPAIRED 2026-09-04 by this example's audit**, on the author's
     direction, and the item stands as the finding it was. `:1112-1114` verified
     at HEAD and repointed in the E187 row of `docs/elements/catalog.md` and in
     the two mirrors of that row in `docs/arcs/enforcement-arc.md`; EN-17 got an
     appended correction rather than a rewrite, because `records/` is not
     rewound. Two more spans in the same row carried the same drift and were
     repointed with them: `field-tys->n`/`datas->n` at
     `lib/lowering/compile-front.chiral:216-240`, now `:238-261`, and `apply-ty`
     at `lib/lowering/upper/closconv.chiral:1096-1098`, cited there as
     `:1081-1083`. Still standing, and reported rather than touched: E185's own
     catalog and arc rows carry that same pre-E185 `apply-ty` span and
     `closconv-driver.chiral:175` for its call site, now `:206`. Both are the
     record of a built element.

- **Related:** [[E185]] (the dispatcher's side, built, and the reason this
  element's observable is gone) · [[E187]] (owns the residue: state the lowering
  type of every name `closconv` invents) · [[E188]] (the live wrong-code defect
  in the same pass; a different kind entirely) · [[E100]] (the type-kinded
  capture drop that runs first) · [[banks/erasure]] (shards D, E, F, G) ·
  [[banks/verification]] (one instrument per level) ·
  [[decisions/decision-erased-word-level]] · [[arcs/enforcement-arc]] ·
  [[records/enforcement-arc]] EN-15, EN-17, EN-18, EN-19, EN-20
