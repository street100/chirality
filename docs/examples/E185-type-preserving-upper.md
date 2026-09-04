---
element: E185
slug: type-preserving-upper
title: **How the `$apply` dispatcher's erased domains are spelled at the lowering type level**
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: reviewed
updated: 2026-09-04
---

# E185 — **How the `$apply` dispatcher's erased domains are spelled at the lowering type level**

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E185, the spelling of the erased position in the type `closconv`
  writes for the `$apply` dispatchers it synthesizes.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** the level is settled and the shape is open.
  [[decisions/decision-erased-word-level]] rules that the erased-word type lives
  strictly at the lowering type level, that `Core` gains no word spelling, and
  that the kernel's `conv` relation is untouched. `.planning/RESEARCH-EN15-prior-art.md`
  §6 measures the prior art as split on the shape, so the codebase settles the
  level and the literature settles neither candidate. That is the build rule's
  test for the full pipeline.

### The catalog's framing is narrower than the defect, and this section says so

The row reads the problem as *how the dispatcher's erased domains are spelled*.
That is one true sentence about one function. Three measurements at `242c0e5`
say the sentence sits inside a larger one.

**Measurement 1: `lib/lowering/upper/` splits along the wrong axis.** Six modules,
2,677 lines, and the split between the ones that mention a tal type and the ones
that do not runs opposite to the split between live and dead.

| module | L | imports a tal module | reached |
|---|---|---|---|
| `closconv.chiral` | 1332 | no, only `surface/surface` | live, via `closconv-driver` |
| `closconv-driver.chiral` | 256 | no, `module/loader` and `closconv` | live, `compile-front.chiral:21` |
| `specialize-singleton.chiral` | 232 | no, only `module/loader` | live, `compile-front.chiral:20` |
| `lower.chiral` | 420 | `lowering/tal/ssa` | live, and its preserve-check has no call site |
| `optimize.chiral` | 254 | `lowering/tal/check` | zero importers |
| `eff-lower.chiral` | 183 | `lowering/tal/check` | one importer, `module/sig-driver`, which has zero |

Measured by `wc -l` over `lib/lowering/upper/*.chiral`, by reading each file's
`(import` lines, and by `grep -rln '(import "<key>")' lib prog`. So **1,820 lines
of live rewriting carry no statement at the lowering type level**, and the two
most aggressive transforms in the compiler, defunctionalization and singleton
monomorphization, are both inside that 1,820. The three modules that do speak tal
are the ones off the live path or whose check never runs: `ck-prog` and `ck-fn`
have no caller outside `optimize.chiral:250`, which nothing loads
([[records/enforcement-arc]] EN-16, and requirement 2 of [[arcs/enforcement-arc]]).

**Measurement 2: `apply-ty` hand-writes an output type, and the value it copies is
a tree-walk artifact.** `apply-ty` (`lib/lowering/upper/closconv.chiral:1081-1083`),
called once at `lib/lowering/upper/closconv-driver.chiral:175`, builds the
dispatcher's Pi chain from `(peel-pi-doms key)`. `key` is a `Family`'s stored key
(`closconv.chiral:616`), and `ensure-fam` (`:653`) stores **the first arrow type
walked into the family**; every later member is matched to it by `arrow-key-eq`
and changes nothing. So the domain type four dispatchers declare is one arbitrary
member's concrete `Core` type, and which member is decided by traversal order.

Three of `synth-apply`'s four inputs are already computed from the family key
honestly. `pi-effs key` gives the per-arrow effect flags, which are part of
`arrow-key-eq`. `peel-pi-cod key` gives the codomain, and `cod-key-eq`
(`closconv.chiral:365-380`) keeps a ground codomain concrete on purpose, so two
families returning different ground types never merge. Only the domains are
copied from a member across an erasure the key performed. The defect is one
position wide inside a function that otherwise reads its key correctly.

**Measurement 3: the shape of the defect is a missing type translation.** In a
type-preserving pipeline every pass `P` carries a translation ⟦·⟧ on types and
contexts, and the pass is correct when

> `Γ ⊢ e : τ` implies `⟦Γ⟧ ⊢ P(e) : ⟦τ⟧`.

No pass writes an output type down; the output type is computed from the input
type by ⟦·⟧. `closconv`'s ⟦·⟧ on an arrow is exactly `shape-eq`
(`closconv.chiral:335-356`): every non-arrow domain is one word, a nested arrow
recurses, the effect flags ride along. `apply-ty` is the one place where the pass
declines to apply its own ⟦·⟧ and substitutes a member instead.

**What follows for scope.** Fixing the spelling makes four dispatchers green and
leaves the invariant unstated. [[records/enforcement-arc]] EN-17 is already the
second instance of the same missing statement, at the `$kI_J` capture
constructor's fields, and it was opened one day after EN-15 was answered. §6 of
this file carries the split recommendation.

⚑ **Nothing here is a miscompile.** Every one of these values is one word at
runtime and the emitted code is correct. The defect is the type the IR carries,
and `ck-prog` is right to refuse it.

## 2. Research

- **Reference class:** the catalog row and the ledger both say `OURS`, and the
  `ours` cell is `(none)`, so no baseline in this tree carries the answer. What
  carries §2 is `PAPER`, and the papers are already this tree's cites.
  `.planning/RESEARCH-EN15-prior-art.md` (committed `224f215`, tracked since
  2026-09-01 per [[decisions/decision-ai-tier]]) is the survey, and §2, §4, §6
  and §7 are read here rather than re-derived. No web fetch was performed by this
  run.
- **The reference class proper:** *From System F to Typed Assembly Language*,
  Morrisett, Walker, Crary and Glew, TOPLAS 21(3), 1999, which is already the
  `PAPER` cite on E18. Closure conversion's translation is Minamide, Morrisett
  and Harper, POPL 1996. Defunctionalization's is Pottier and Gauthier, POPL 2004.

**Key findings.**

1. **Type preservation is an obligation on each pass, discharged by a translation
   rather than by an annotation.** TAL's chain carries a ⟦·⟧ at every stage and
   the target keeps full System F types, with `∀`, `∃` and type variables living
   in register-file types (research §4). The checker holds a type variable
   abstract, and erasure is a property of the runtime while the static annotation
   stays exact. There is no uniform word type and no top type anywhere in the
   TOPLAS paper's extracted text.

2. **Closure conversion's ⟦·⟧ hides the environment behind `∃` and keeps the
   environment's field types concrete inside the pack** (Minamide, Morrisett and
   Harper, via research §4 and §7). The unifier for heterogeneous environments is
   existential quantification. The fields themselves do not erase. That is the
   finding EN-17 turns on, and it is the reason the capture constructor and the
   dispatcher may take opposite answers.

3. **Defunctionalization's ⟦·⟧ makes the dispatcher polymorphic and puts the
   concrete types on the constructor** (Pottier and Gauthier, research §2). One
   `apply : ∀α₁α₂. ⟦α₁→α₂⟧ → α₁ → α₂`, with each tag a GADT constructor at its
   own concrete indices (`succ : Arrow int int`), and the branch checked under the
   recovered equation. Their §6 adds the part that names chirality's situation
   directly: a specialized member `apply_{∀β̄.τ₁→τ₂}` is still well-typed, with the
   domain spelled by the **quantified variables β̄**, and type-based specialization
   becomes optional. The paper also diagnoses the simply-typed family workaround
   this tree uses, and says why it stops: "there is no natural way of translating
   non-ground arrow types". `shape-eq`'s coarse "both non-arrow" test is an
   approximation of β̄'s instance test, and `apply-ty` is where the approximation
   stops being represented.

4. **The coarse relation stays below the source checker in every system surveyed,
   and the erased position is spelled two ways.** Research §6's table covers seven
   systems and not one admits into a source conversion or equality relation a type
   that identifies two distinct ground types. Where they split is the spelling.
   TALx86 puts the word size in the **kind** and the erased position is a variable
   at that kind, `∀α:T4`, on the stated ground that a variable at kind `T4` already
   means "some one-word value" and, unlike a nominal `Word`, cannot be confused
   with a concrete type by an equality check. MLton runs `RepType` with `isSubtype`
   and `width` at RSSA, strictly below SSA's exact equality. The JVM verifier runs
   `oneWord` and `isAssignable`, below javac.

⚑ Research §8 records what could not be found, and one entry bears on this run:
no published statement of the two-level principle as a principle was located, so
§6's table is convergent practice assembled in that document. It is evidence,
and no paper states the rule.

## 3. Conventional (other-language) approach

**OCaml.** Below the source typechecker the OCaml compiler drops the type
discipline: Lambda is untyped (research §5). A defunctionalizing pass written
against that pipeline may write any output type it likes, because nothing below
reads one. Expressed at the source level, where the shapes are visible, the
conventional move looks like this.

```ocaml
(* The simply-typed family workaround, which is closconv's construction. *)
type clo0 = K0_succ | K0_double
let apply0 (c : clo0) (x : int) : int =        (* domain spelled from one member *)
  match c with K0_succ -> x + 1 | K0_double -> 2 * x

(* Now a family whose members disagree on the domain, which is what an erasing
   family key permits.  The annotation `int` is a lie, so the escape hatch pays
   for it, and the payment is invisible below Lambda. *)
type clo1 = K1_len | K1_succ
let apply1 (c : clo1) (x : Obj.t) : Obj.t =
  match c with
  | K1_len  -> Obj.repr (List.length (Obj.obj x : string list))
  | K1_succ -> Obj.repr ((Obj.obj x : int) + 1)
```

- **Assumptions it bakes in.**
  - **The IR below the source typechecker is untyped**, so a pass's output type
    is documentation. A wrong annotation costs nothing at compile time and is
    found, if at all, by a crash.
  - **An ambient escape hatch exists.** `Obj.magic` is reachable from anywhere,
    unconstrained by what the function was given, so the erased position can be
    written by widening the value's type rather than by stating the translation.
  - **Type preservation is a paper property.** The pass is proved correct in a
    write-up, or it goes unproved; the compiler never re-derives ⟦τ⟧ and
    compares.
  - **Representation compatibility and type equality are the same relation**,
    because there is only one relation and it has been switched off.

MLton takes the other conventional route and pays a different price: it
monomorphises before defunctionalizing, so its dispatchers never see a
polymorphic domain and can be spelled exactly (research §5). Pottier and Gauthier
name the cost, "code duplication, whose cost may be difficult to control", and
with polymorphic recursion it "becomes impossible". `closconv.chiral:359-363`
records that this tree does not take that route: a polymorphic `(-> K K ..)`
parameter reaches `closconv` and has to share a family with the concrete closures
passed to it, which is a parameter MLton's dispatchers never see. The note rules
out finer families; the route it forecloses is a consequence, not its subject.

## 4. The chirality idea

- **Chirality features in play:** the typed lowering floor (`TalTy`, `tt-word`,
  `tal-ty=?`, `ck-prog`), QTT quantities on Pi binders and the erased-position
  drop at the peel, the effect flags riding each arrow (`->` against `=>`),
  categories A and B at the checker boundary, and totality of the passes
  themselves.

- **The reframing.** The IR below chirality's typechecker is **typed**, so the
  annotation is refusable and is being refused. `ck-prog` is written, it is
  correct, and it says no to four dispatchers today. There is no `Obj.magic` to
  buy silence with, and [[decisions/decision-erased-word-level]] closes the other
  purchase: the kernel's `conv` relation stays as it stands, because conversion is an
  equivalence relation and therefore transitive, so a `Word` converting with
  `I64` and with `(List Str)` makes `I64` convert with `(List Str)`. The coarse
  relation exists at exactly one level, `tal-ty=?`
  (`lib/lowering/tal/check.chiral:68`), whose first arm makes `tt-word` match
  everything, and `lib/lowering/tal/ssa.chiral:17-20` defines it for exactly
  this. [[banks/erasure]] shard F holds the measurement.

  With both purchases closed, the only remaining move is the one the papers make:
  the pass computes the output type from the input type. `closconv` already knows
  its own ⟦·⟧, because `shape-eq` **is** ⟦·⟧ on an arrow and `arrow-key-eq` is the
  equality it induces. What is missing is that `apply-ty` reads a member where it
  should read the shape.

- **The two candidates, and which machinery each one needs.**

  **(a) A quantified type variable.** Pottier and Gauthier's β̄, TAL's abstract
  `α`, TALx86's `∀α:T4`. In chirality that is an erased type binder, the tree's
  most ordinary idiom: `(0 a (type 0))`. The dispatcher becomes
  `(-> (0 a0 (type 0)) … $clo<i> a0 … cod)`, and each erased domain is spelled by
  the bound variable. **No new constructor is needed anywhere.** `term->ntalty`
  maps `(t-var i)` to `(nt-word)` at `lib/lowering/compile-front.chiral:70` under
  the comment "B1: an erased type variable in a KEPT position", and `ty-kept-doms`
  / `ty-erased` (`:159-170`) drop the `q=0` binders at the peel. So candidate (a)
  reaches `tt-word` through machinery that runs on every compile, adds nothing to
  `Core`, and leaves `conv` alone. [[banks/erasure]] shard G is that machinery,
  and the decision names its existence as an observation that settles nothing.

  **(b) A coarse word type of the lower language.** Java's `Object`, the JVM
  verifier's `oneWord`, MLton's `RepType`. In chirality this candidate **cannot be
  written by `apply-ty` at all**, and the reason is the settled decision: a
  `(c-primty "Word")` or a `(c-tcon "$word" nil)` is a `Core` word spelling. So
  candidate (b) forces the dispatcher's type to be **stated at the lowering type
  level** instead of peeled from a `Core` type, which means `closconv` hands the
  bridge an `NTalTy` list with `(nt-word)` in each erased position.

- **The structural constraint, and the transport that already exists.**
  `closconv` lives in the kernel's `Term` image and cannot import `lowering/tal/ssa`:
  the flat global namespace plus whole-file import makes `kernel` and `tal-ssa` in
  one module a hard load error, `data Term redeclared`, and
  `lib/lowering/lowspec.chiral:1-22` records the finding. `lowspec` is the neutral
  `n`-prefixed transport built for that seam, carrying `NTalTy` parameter and
  return types beside an `NCore` body, and it imports cleanly into both images.

  ⚑ **Verified, and it is stronger than "importable in principle".**
  `lib/lowering/compile-front.chiral` imports `lowering/upper/specialize-singleton`
  at `:20`, `lowering/upper/closconv-driver` at `:21` and `lowering/lowspec` at
  `:22`. Flat namespace plus whole-file import means all three are already one
  loaded image on every compile. So `lowspec` sitting beside `closconv` is a fact
  about the shipping compiler rather than a proposal.

- **Judging the candidate shape: `lowspec` as the typed spine every upper pass
  reads and writes.** Half of it is right and the wrong half is load-bearing.

  1. **`NTalTy` has no arrow former**, by design: `nt-i64`, `nt-str`, `nt-bytes`,
     `nt-word`, `nt-data` (`lowspec.chiral:30-33`). ⚑ **The ground is not that the
     bridge refuses an arrow.** It does not: `term->ntalty` maps `(t-pi _ _ _ _)`
     to `(nt-word)` at `compile-front.chiral:71`, *"arrow types (kept by
     `ty-kept-doms`) are pointer-sized"*, so an arrow already reaches `NTalTy` and
     arrives there **flattened to one word**. The header's "a non-ground type never
     reaches here" is written for the types `term->ntalty` returns `none` on, and it
     over-reads if taken to cover arrows. The constraint is the flattening, and it
     is stronger than a refusal would be. `closconv`'s entire input is arrow types
     and its family key is an arrow-shape equality recursing through `peel-pi-doms`
     and `pi-effs`, which is exactly the structure `nt-word` has destroyed. A spine
     that collapses `(-> A B)` before the pass runs cannot carry the pass whose job
     is to eliminate arrows, and adding an arrow former would put the structure back
     at the one level built to have dropped it.
  2. **`NCore` is deliberately the lowerable term fragment**, and
     `specialize-singletons` runs before anything is known to lower: it rewrites
     data declarations, `KArm`s and quantities in the kernel `Term`, ahead of
     `closconv` and far ahead of the peel (`compile-front.chiral:342`). It cannot
     be moved below a transport that only carries what already lowers.
  3. **What is right is narrower and it is the whole of the answer.** The names
     `closconv` invents have **no source type at all**: `$clo<i>`, `$k<i>_<j>` and
     `$apply<i>` exist because the pass made them, and the pass is the only thing
     in the tree that knows the erasure it performed. Those, and only those, want
     their types stated at the lowering level. So the correct shape is narrower:
     **`lowspec` as the place where a pass states the types of the names it
     invented**, with passes that only rewrite existing defs staying on the
     `Term` image where their inputs live.

  Under that narrowing, candidate (a) needs no `lowspec` change and candidate (b)
  is exactly the narrowing applied to one name. That is the trade the SPEC stage
  has to price.

- **What chirality makes impossible here.** No ambient escape hatch, so a pass
  cannot widen a value's type to cover a wrong annotation. No source-level word,
  so a pass cannot buy silence by widening `conv`. No second compatibility
  relation, because [[banks/verification]]'s one-instrument-per-level rule keeps
  `tal-ty=?` the only one and keeps the kernel out of re-checking lowered code.
  And no unchecked pass output once requirement 2 lands, because `ck-prog`
  recomputes the type and compares. The conventional freedom that goes is the
  freedom to write down an output type.

## 5. Chirality example (fleshed)

Real surface syntax. Three parts: the law stated where a reader of `closconv`
meets it, the erasure made writable, and `apply-ty` computing rather than
copying. Candidate (b) is sketched at the end so the SPEC can price both.

```chirality
; ---------------------------------------------------------------------------
; E185. closconv states its type translation for the names it invents.
; Lands in lib/lowering/upper/closconv.chiral beside apply-ty (:1081-1083).
; ---------------------------------------------------------------------------
(import "surface/surface")          ; Core / c-pi / c-var / c-tcon / c-type

; ---- (i) THE LAW ----------------------------------------------------------
; closconv rewrites a Sig the kernel has already checked, and the instrument
; below it is ck-prog over tal. The obligation is per pass:
;
;     G |- e : t   ==>   [[G]] |- P(e) : [[t]]
;
; closconv's [[.]] on an arrow is shape-eq (:335-356): every non-arrow domain
; is one word, a nested arrow recurses, the per-arrow eff flags are carried.
; cod-key-eq (:365-380) keeps a GROUND codomain concrete on purpose. So the
; dispatcher's honest type is computed from the family SHAPE, and every input
; synth-apply already has is the key. What it must stop doing is reading the
; domains off that key: ensure-fam (:653) stores the FIRST arrow walked into
; the family and arrow-key-eq matches every later member to it, so a copied
; domain is a traversal artifact.

; ---- (ii) the erased spelling of ONE domain -------------------------------
; `lvl` is the number of type binders wrapped around the whole chain, one per
; DOMAIN POSITION and a0 OUTERMOST; `j` is this domain's index in the chain. One
; per position rather than one per erased position is what keeps the index
; arithmetic below a constant; a nested-arrow position then leaves its binder
; unused, and tightening that is knob 3's to price. The index is CONSTANT
; at lvl, and the derivation is the whole of the care this needs: domain j sits
; under the $clo binder plus j earlier domain binders, so counting outward
; a_{lvl-1} is at 1+j and a_j is at (1+j) + (lvl-1-j) = lvl. A bound index is
; not enough on its own -- lvl-1-j is bound too, and names the wrong binder.
(declare dom-ty (-> Core I64 I64 Core))
(def dom-ty
  (lam (d lvl j)
    (case (is-arrow d)
      (false (c-var lvl))                      ; one word: the family's variable
      (true  (arrow-ty d lvl j)))))            ; nested arrow keeps its structure
; arrow-ty mirrors shape-eq's recursion over peel-pi-doms / peel-pi-cod /
; pi-effs and rebuilds the c-pi chain with each non-arrow domain erased,
; carrying the extra depth of the binders it introduces. …

(declare erase-doms (-> (List Core) I64 I64 (List Core)))
(def erase-doms
  (lam (ds lvl j)
    (case ds
      ((nil) nil)
      ((cons d r) (cons (dom-ty d lvl j) (erase-doms r lvl (+ j 1)))))))

; ---- (iii) apply-ty, candidate (a): the quantified type variable -----------
; One erased type binder per erased domain, then the $clo domain, then the
; domains spelled as those variables:
;
;   $apply3 : (-> (0 a0 (type 0)) (0 a1 (type 0)) $clo3 a0 a1 Bool)
;
; Erased binders are this tree's ordinary idiom and the peel already removes
; them: ty-kept-doms drops every q=0 domain and ty-erased records the position
; (compile-front.chiral:159-170), and term->ntalty maps the surviving bound
; (t-var i) to (nt-word) at :70. tt-word is reached with NO new constructor,
; no Core word spelling, and no widened conv, which is the settled level.
; (lvl k body): wrap the remaining k binders, naming from a_{lvl-k}, so the
; OUTERMOST is a0 and the display above reads left to right.
(declare quant-binders (-> I64 I64 Core Core))
(def quant-binders
  (lam (lvl k body)
    (case (<=i k 0)
      (true  body)
      (false (c-pi 0 0 (str-cat "a" (i64->str (- lvl k)))
                   (c-type 0)
                   (quant-binders lvl (- k 1) body))))))

(declare apply-ty (-> Str (List Core) Core (List I64) Core))
(def apply-ty
  (lam (dname doms cod fam-effs)
    (let (k (cc-llen doms))
      (quant-binders k k
        (mk-pi (cons (c-tcon dname nil) (erase-doms doms k 0))
               (cons 0 fam-effs)               ; the leading $clo arrow is pure
               cod)))))                        ; cod-key-eq already keeps this honest

; ---- (iii-b) apply-body's binder chain moves with the type -----------------
; compile-fn strips exactly |params| + |erased| lambdas (lower.chiral:414-416)
; and returns le-skip "body is not a lambda chain" when the chain is short, so
; the k new q=0 binders need k new lams. lowspec.chiral:52-55 is the reason: an
; erased binder KEEPS its lambda position and takes a placeholder register.
;
;   (mk-lams (+ (+ 1 d) k) (c-case (c-var d) …))   ; closconv.chiral:1109-1111
;
; The scrutinee index d does not move: the new binders sit OUTSIDE the $clo
; binder, so nothing under it shifts.

; ---- (iii') candidate (b): state the type at the lowering level ------------
; Not writable above, because a Core word spelling is refused by
; decisions/decision-erased-word-level. So the dispatcher's type is STATED
; rather than peeled: closconv hands the bridge an NDef whose params carry
; (nt-word) at every erased position. lowspec loads beside closconv today --
; compile-front.chiral:20-22 imports specialize-singleton, closconv-driver and
; lowspec into one image on every compile.
;
;   (import "lowering/lowspec")     ; NTalTy / nt-word / NDef
;   (declare apply-ndef (-> Str I64 (List Core) Core (List I64) NDef))
;   (def apply-ndef
;     (lam (dname i doms cod fam-effs)
;       (ndef (apply-name i)
;             (cons (nt-data dname nil) (word-params doms))   ; erased -> nt-word
;             (cod->ntalty cod) nil (apply-nbody …))))
; …the bridge then takes the stated NDef for a synthesized name instead of
; running peel-def over a Core type it would have to invent anyway.
```

- **Knobs to modify.**
  - **Which candidate.** (a) touches `apply-ty`, `mk-pi`, `apply-body` and the one
    call site at `closconv-driver.chiral:175`. (b) touches the bridge and gives
    `lowspec` a second producer.
  - **`apply-body`'s lambda count under (a).** Not optional and not a knob at all,
    which is why it is in the snippet: `compile-fn` strips `|params| + |erased|`
    lambdas (`lower.chiral:414-416`) and a short chain returns `le-skip "body is
    not a lambda chain"`, so a dispatcher whose type gained `k` erased binders and
    whose body did not stops lowering. `lowspec.chiral:52-55` states the rule the
    strip enforces. The measured effect of missing it is not a red row, it is a
    dispatcher silently absent from the emitted program.
  - **The call sites of `$apply<i>` under (a).** Adding leading `q=0` binders
    changes the global's erased-position vector, and `build-emap`
    (`compile-front.chiral:171-175`) computes that vector from the type, so
    `emap-get` will drop args at the new positions. Either `apply-body` and `rw`
    pass type arguments at those positions, or the emap entry for a synthesized
    dispatcher is built by the pass that synthesized it. This is the one place
    where (a) reaches outside `closconv`.
  - **Whether `arrow-ty` erases a nested arrow's own domains.** `shape-eq`
    recurses, so ⟦·⟧ says yes. A first cut may keep nested arrows verbatim and
    take the narrower gate.
  - **The codomain stays untouched** under both candidates. `cod-key-eq` is the
    reason, and changing it would merge families that must not merge.

- **Deliberately omitted.**
  - The `$kI_J` capture constructor's field types. That is EN-17, the prior art
    answers it the other way (research §7), and §6 recommends it as a sibling.
  - Any change to `ck-prog`, `tal-ty=?` or `lib/lowering/tal/check.chiral`. The
    checker is correct and this element does not touch it.
  - The eleven name collisions that keep `lowering/tal/check` unimportable beside
    the compiler. That is E154's fifth instance and requirement 2's other blocker,
    independent of this element ([[arcs/enforcement-arc]], Resume state).
  - `specialize-singletons` and `eff-lower`. §6 places them.

## 6. Use / modify notes

- **Lands in:** `lib/lowering/upper/closconv.chiral` (`apply-ty`, `mk-pi`,
  `apply-body` under candidate (a), and a new `dom-ty` / `erase-doms` /
  `quant-binders`) with its one call site at
  `lib/lowering/upper/closconv-driver.chiral:170-177`. Under candidate (b), also
  `lib/lowering/lowspec.chiral` and the bridge in
  `lib/lowering/compile-front.chiral`. All of it is compiler source inside the
  blob, so the full BUILD RULE applies: `build-new → test → promote` with the
  fixpoint verified and the Step-0 precondition checked first.

- **Conformance target.** The EN-08 probe moves **1,477 of 1,481 accepting to
  1,481 of 1,481**, with no row that accepts today turning red.
  `tools/test/tal-check.sh` Phase 22 stays `21 ok, 0 FAIL` with its nine refusals
  and three live mutants unchanged, because the checker is untouched. The suite
  stays green at its measured count with the promoted fixpoint, and the emitted
  bytes for a program containing no higher-order call are unchanged, since the
  dispatchers' runtime representation does not move.

- **The judgment this pre-run owes: E185 as minted is one slice of a program.**
  It can carry the spelling ruling and the `apply-ty` repair, and it should,
  because that is one function, one call site and one probe figure. It cannot
  carry the program, for two reasons already on the record. EN-17 exists, which
  makes this the second instance of the same missing statement, opened one day
  after the first was answered. And 1,820 lines of live rewriting still say
  nothing at the lowering type level after E185 lands, so the invariant stays
  unstated and the third instance is unbudgeted.

  ⚑ **This pre-run mints nothing, and names the split as a recommendation for the
  SPEC stage to mint.** Naming a follow-on `E#` without minting it in the same
  change violates the deferral rule ([[definitions/working-discipline]]), so the
  cuts below are described by their content and their band, and the numbers are
  the SPEC's to assign. Lane A's band is `E184-E189`
  ([[decisions/decision-lane-split]]), shared with [[arcs/diagnostics-arc]], and
  `E186` through `E189` are free.

  | | the sibling | where the cut falls |
  |---|---|---|
  | **E185, as minted, keeps** | the spelling of the dispatcher's erased domains: choose (a) or (b), make `apply-ty` compute from the family shape, gate on the probe | one synthesized name's argument position, constrained by every family member at once |
  | **sibling 1** | the `$kI_J` capture constructor's field types, which is EN-17 turned from an author call into an element | a constructor is applied at exactly one site, so nothing forces its fields to merge. Research §7 finds both published answers keeping fields **concrete**, which is the opposite arrangement to the dispatcher. One element ruling on both would prejudge the second |
  | **sibling 2** | `closconv` states the lowering-level types of every name it invents: `$clo<i>` declarations, `$k<i>_<j>` constructors, `$apply<i>` globals, emitted beside the rewritten Sig so the bridge reads them | E185 repairs one output type; this states the pass's whole ⟦·⟧ for its invented names, and it is what makes the repair structural. It subsumes sibling 1's mechanism while leaving sibling 1's ruling open |

  **Ordering.** E185 first, because requirement 2 waits on it and it is the
  smallest measurable move. Sibling 1 next, because it is the other half of what
  blocks `ck-prog` on the shipping path ([[records/enforcement-arc]] EN-17 holds
  that `ck-prog` cannot refuse while either instance stands). Sibling 2 last,
  because it is worth more once both rulings exist to encode.

  **Not recommended: an element for `specialize-singletons`.** [[E184]] R6 already
  owns "fates survive a renaming", and minting a second row for the same pass
  would split one fork across two elements.

- **Open questions.**
  1. Candidate (a) or candidate (b). The prior art splits and the decision leaves
     it open; this pre-run's measurement favours (a) on cost, because it adds no
     constructor and reuses `term->ntalty:70` and `ty-kept-doms`, and favours (b)
     on shape, because it puts the statement at the level the ruling names. Two
     things price the fork and neither was in the catalog row. **(a)'s cost is
     four functions and a call-site question**, not two functions: the binder
     chain and the emap both move with the type. **And (a) relocates the remaining
     dishonesty rather than removing it.** `$apply`'s `Core` type becomes a
     parametric claim its own arms do not honour, since an arm applies a concrete
     function at a variable-typed argument, and Pottier and Gauthier recover that
     step with a GADT equation this tree has no machinery for (research §2).
     Nothing catches it, because `closconv-sig` runs after the typecheck
     (`compile-front.chiral:342`) and reason 3 of the ruling turns on exactly that.
     Under (b) the tal type is stated and the `Core` type stops being read. So the
     fork is where the unchecked statement sits, and the SPEC decides.
  2. Under (a), how `$apply<i>`'s call sites get their type arguments, given that
     `build-emap` derives erased positions from the type and `emap-get` drops args
     at them.
  3. Whether `arrow-ty` erases a nested arrow's domains, matching `shape-eq`'s
     recursion, or keeps them for a first cut.
  4. Whether the gate can be a chirality program on E168's test floor rather than
     another shell script, given requirement 5's standing direction
     ([[arcs/enforcement-arc]], Resume state).

- **Related open rows, placed rather than solved.**
  - **[[records/enforcement-arc]] EN-17**, the `$kI_J` capture constructor's field
    types, blocking requirement 2 alongside this element. Placed as sibling 1
    above. This run places it and leaves it open; E185's ruling may or may not
    reach the fields.
  - **[[E184]] R6**, fates surviving `specialize-singleton`'s renaming. This
    framing bears on it structurally: a pass that states what it produced states
    the renaming too, so R6's "produce a rename map and thread it" fork gets a
    cheaper answer if sibling 2 lands. Ownership stays with E184 and the fork is
    E184's pre-run to resolve.
  - **[[E17]]**, the optimizer. `lib/lowering/upper/optimize.chiral:250` holds
    `re-check`, the tree's only pass that re-judges its own residual with `ck-fn`,
    which is the shape this element's invariant wants. The module has zero
    importers, so the instance runs on nothing. E185 does not change that, and
    requirement 4 is E17's row.
  - **[[E70]]**, effectful lowering. The translation stated here is over types.
    The effect row's tal shadow is E70's and stays E70's, and
    `lib/lowering/upper/eff-lower.chiral` (183 L) is the module that models it,
    reached only by `lib/module/sig-driver.chiral`, which has zero importers. One
    thing does carry across today: `apply-ty` already threads `(pi-effs key)` into
    the Pi chain, so the effect flags are the one part of ⟦·⟧ the current code
    computes rather than copies.

- **Related:** [[decisions/decision-erased-word-level]] · [[banks/erasure]] ·
  [[records/enforcement-arc]] · [[arcs/enforcement-arc]] · [[status-ledger]] ·
  [[E16]] · [[E17]] · [[E18]] · [[E70]] · [[E184]] · [[E154]]
