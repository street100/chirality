---
element: E188
slug: unreachable-arm-reached
title: **`arm-body`'s unreachable arm is reached, and an `$apply` arm returns a literal `0` as a whole function body**
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-09-04
---

# E188 — **`arm-body`'s unreachable arm is reached, and an `$apply` arm returns a literal `0` as a whole function body**

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E188. `arm-body` (`lib/lowering/upper/closconv.chiral:1051-1058`)
  has one arm for a defunctionalization site whose `def-ctx` returns `none`, and
  that arm emits `(c-lit-i 0)` as the whole body of an `$apply` dispatcher arm.
  Its own comment reads `unreachable: g always has a def-ctx`. It is reached.
- **Kind:** BUILD-PROPER. The correct arm was never built; a placeholder stands
  where it belongs.
- **Why chirality needs its own:** this is a defect in chirality's own compiler,
  and [[decisions/decision-scope]] consequence 1 cut the external judgment that
  would otherwise hold an opinion about it. Rocq, CompCert and the Python oracle
  are gone. What refuses a wrong `$apply` arm has to be written here.

**Reproduced at HEAD, 2026-09-04** (`75944f4`). Every line below was read from
the tree during this run.

| claim | verified |
|---|---|
| `closconv.chiral:1057` is `((none) (c-lit-i 0))))` with the `unreachable` comment | yes |
| `(c-lit-i 0)` occurs exactly once in `closconv.chiral` and never in `closconv-driver.chiral` | yes, `grep -c` = 1 and 0 |
| `def-ctx` at `closconv.chiral:582-596`, and the peel call it fails on is `closconv.chiral:590` | yes |
| `mach-galo` `(-> Mach (-> I64 I64 (List I64) (List Asm)))` at `mach.chiral:134-135`, `mach-gbnw` `(-> Mach (-> I64 I64 (List Asm)))` at `:136-137` | yes |
| `alloc-growing` puts both in value position, `alloc-growing.chiral:18-24` | yes |
| `tal-ty=?`'s first arm is `((tt-word) true)`, `check.chiral:68-70` | yes |
| the `ret` refusal is `ck-term`'s `t-ret` arm, `check.chiral:256-258` | yes |
| `keep-fams` at `closconv-driver.chiral:96-106`, poison threaded as `CState`'s `pois` | yes |
| `SkReason` has exactly two constructors, `sk-extern` and `sk-callee`, `skip-diag.chiral:11` | yes |

⚑ **Four rows re-read by the EXAMPLE-level audit, 2026-09-04.** Two of them
overturn a claim this pre-run made, and the sections below carry the corrected
text.

| claim | verified |
|---|---|
| a `cs-g` site is built at three places, and only one of them records the global's REMAINING type: `cwalk-app-head` (`closconv.chiral:826-833`) keys by `(ty-of ctx t)` after `k` args, `fv-own` (`:844-850`) keys by the global's OWN type at `k=0`, and `fv-site` (`:852-862`) keys by the CALLEE-PARAM SLOT | yes, and it breaks §5's stated ground for `d = arity - k` |
| `d` is `(cc-llen (peel-pi-doms key))` of the FAMILY key, `closconv-driver.chiral:204` and `:207` | yes |
| `collect` already consults `def-ctx`: `collect-defs` (`closconv.chiral:922-930`) calls it at `:927` and skips the def on `none` | yes, so candidate (c)'s stated cost is wrong |
| `mach-galo`'s type peels 4 domains (`ty-cod` is greedy, `compile-front.chiral:165`) against a body one `lam` deep, so `compile-fn` (`lower.chiral:412`) refuses it on the `strip-lams` arm rather than on a `tr-skip` | derived from HEAD, not measured |

### Is zero blast radius a reason to defer this? No, and the reason inverts the usual one

EN-20 measured the blast radius as zero: `compile-fn` `le-skip`s `alloc-growing`
and `mach-galo`, no `$clo5` or `$clo6` construction reaches any of the 1,484
TFns, and `$apply5` and `$apply6` ride into the ELF dead. That is true and it is
**not** a reason to defer. Three grounds, and the third is the one that decides.

1. **The zero is an accident of a second defect, and repairing the second defect
   arms the first.** Nothing in the tree asserts that no `$clo5`/`$clo6`
   construction reaches a TFn. What holds it is `compile-fn` refusing to lower
   `alloc-growing`, which is itself a gap the tree wants closed: a skipped def is
   a missing function. The day `alloc-growing` lowers, the dead dispatcher goes
   live and returns `0`. So the ordering constraint is real and it points the
   other way from "defer": E188 must land **before** anything that makes
   `alloc-growing` lower. ⚑ **One qualifier the audit adds.** For *these two*
   instances `ck-prog`'s `ret` refusal already reddens, so if the arc's
   requirement 2 lands first the arming shows up as a refused compile rather
   than as a wrong answer. The qualifier does not survive the general case,
   which is ground 3: at a ground codomain the same arming is silent.

2. **The instruments that would notice are structurally blind here, so "zero" is
   unmeasured rather than measured.** [[banks/verification]] §1 states the limit
   directly: the fixpoint proves stability rather than correctness, and *a
   compiler that miscompiles consistently fixpoints perfectly*. This is that
   case. The suite is green, `B2 == B3` holds at 1,192,312 bytes, and neither
   witnesses the arm. `ck-prog` reddens the two live instances only because their
   family codomain is `(List Asm)`. The zero rests on EN-20's one-off census of
   1,484 TFns, which nothing re-runs and no gate re-derives.

3. **Against urgency, honestly: E188 blocks nothing the arc is doing now.** No
   shipped byte is wrong today. The arc's requirement 2, `ck-prog` on the
   shipping path, is blocked by E185 and E187, and E188 is a defect that
   `ck-prog` on the shipping path would still miss. So the verdict is not "drop
   everything". It is: **E188 is not deferrable behind the work that arms it, and
   it is deferrable behind the work that does not.** That is a scheduling
   constraint with a named trigger, which is what an honest urgency answer owes.

## 2. Research

- **Reference class:** `OURS` (the tree's own refusal precedent) with `PAPER`
  support (defunctionalization and arity mismatch). No web fetch; the citations
  into `.planning/RESEARCH-EN15-prior-art.md` are to a tracked file
  ([[decisions/decision-ai-tier]] removed the exclusion on 2026-09-01).

**Finding 1. The textbook `apply` arm for a named function is a call, and no
formulation derives it by peeling the callee's body.** Reynolds' construction
and Danvy and Nielsen's presentation of it (*Defunctionalization at Work*, PPDP
2001) build the branch for a tag from the lambda abstraction the tag came from.
A top-level function used as a bare function value has no such abstraction at the
family arity; the standard treatment makes it a nullary constructor whose branch
is the application `f(x)`. `arm-body`'s `some` path takes the other route,
reading the global's *body* and demanding it be exactly as deep as its type. For
a lambda literal (`cs-lam`) that demand is satisfied by construction. For a
global (`cs-g`) it is an assumption about how the global happens to be written.

**Finding 2. Pottier and Gauthier's specialized dispatcher is the same
construction, and it is a call.** `.planning/RESEARCH-EN15-prior-art.md` §2
quotes §6 of the POPL 2004 paper: the specialized `apply` has *"code identical to
that of `apply`, except it contains branches only for the tags corresponding to
source functions whose type is an instance of τ₁→τ₂"*. Identical to `apply`
means a dispatch onto a call. The family specialization changes which branches
exist and leaves what a branch *is* alone.

**Finding 3. The prior art's uniform answer to an arity mismatch is to handle it
at the apply point.** Marlow and Peyton Jones, *Making a fast curry: push/enter
vs. eval/apply* (ICFP 2004, JFP 2006), exists because a function value's arity
need not match the call's; eval/apply keeps generic apply machinery precisely to
reconcile the two at the call. Nothing in that literature assumes the callee's
body is deep enough and emits a constant when it is not.

**Finding 4, and it is the load-bearing one. The tree already answers this exact
predicate, in the same lowering, with a refusal.** `compile-fn`
(`lib/lowering/upper/lower.chiral:412-420`) computes `total` as the arity and
asks `strip-lams body total`. On `none` it answers:

```
      (case (strip-lams body total)
        (none (le-skip "body is not a lambda chain"))
```

`strip-lams` (`lower.chiral:218`) and `peel-lam-exact` (`closconv.chiral:565-573`)
are the same predicate over two IRs. They differ in one respect, and the
difference favours the refusing one: `strip-lams` skips annotations through
`strip-ann`, while `peel-lam-exact`'s own comment says it deliberately does not.
So `closconv` asks a *stricter* version of the question `lower` asks, and where
`lower` refuses and reaches `SkRec`/`format-blame`, `closconv` returns `0`. One
condition, two functions, opposite answers. The honest answer is already built
and running forty lines of module away.

⚑ **The EXAMPLE-level audit sharpened this finding twice, and it holds harder
than the pre-run stated it.**

**It is the same def, not merely the same predicate.** `peel-def` takes the
codomain through `ty-cod` (`lib/lowering/compile-front.chiral:165`), which
recurses to the final non-`Pi`, so `mach-galo` reaches `compile-fn` with
`total = 4` against a body one `lam` deep. `strip-lams` returns `none` and the
arm at `lower.chiral:417` fires. EN-20 measures the same def `le-skip`ped by
`compile-fn`; this run derives which arm does it. So `mach-galo` is refused by
name in one function and answered with `(c-lit-i 0)` in the other, in the same
compile.

**And a third function in this pass asks the predicate a third way, inside
`closconv` itself.** `collect-defs` (`closconv.chiral:922-930`) calls
`def-ctx` at `:927` for every def it walks and **skips** the def on `none`,
silently. So the pass already carries two answers to `def-ctx` failing — skip
the def, and emit `0` — and the refusing one is the one written first. What
`arm-body` lacks is not the mechanism. It is a channel to put the refusal in.

## 3. Conventional (other-language) approach

OCaml, a hand-written defunctionalizer of the shape `closconv` ports. The arm
builder faces the same case and the language hands it a first-class spelling for
"impossible".

```ocaml
(* the branch for one defunctionalization site *)
let arm_body (sig_ : sigv) (site : csite) (d : int) (m : int) : core =
  match site with
  | Cs_g (g, k, fields) ->
      (match def_ctx sig_ g with
       | Some dc -> rw (remap (g_subst dc.n fields k m d) dc.body)
       (* the site is a named global: the branch is a call, and OCaml lets you
          say so.  If you instead believe this case cannot arise: *)
       | None -> assert false)            (* loud, total, and costs nothing *)
  | Cs_lam (inner, dd, captys, fields) -> rw (remap (lam_subst inner dd fields d m) inner)
```

- **Assumptions it bakes in.** Partiality is free. `assert false` inhabits every
  type, costs one token, and if the belief is wrong the program stops with a file
  and a line. The exception mechanism gives "unreachable" a spelling that is
  *cheap to write and loud to be wrong about*, so an author who guesses badly
  finds out. The same code also assumes ambient control flow: the failure
  propagates without appearing in any signature, so no caller is restructured to
  carry it and the arm builder stays total-looking while being partial.

## 4. The chirality idea

- **Chirality features in play:** totality; errors as values with no exceptions;
  boundary sums ([[definitions/pattern-boundary-sums]], `SkReason`); the pure
  `->` membrane over the whole pass; erasure shards E and F
  ([[banks/erasure]] §2).

**The reframing, and it is a diagnosis rather than a scolding.** chirality
removed the escape hatch that makes `assert false` cheap. `arm-body`'s signature
is

```
(-> SigV Csite I64 I64 (List ApplyEnt) Core)
```

total, pure, and with no error channel. There is no `absurd`, no exception, and
no `halt` reachable from a `->` arrow. So an impossible case still has to produce
a `Core`, and the author needed the smallest term that always typechecks. That is
`(c-lit-i 0)`. **A total function with no result-side error channel converts
every unproven "unreachable" into a silently wrong value.** The defect is
structural, and the same shape will recur at every arm in this tree that carries
an `unreachable` comment over a value.

Two more instances of the shape sit inside the very functions this element
touches, and they are named here as observations rather than claims:
`g-subst-go` carries `((nil) nil) ; unreachable: fs has k entries`
(`closconv.chiral:969`), and `build-binders` carries
`; defensive: no more params` (`lower.chiral:407`). Neither is measured by this
run.

⚑ **The audit read both, and neither is a second live miscompile. The
observation is kept and its wording is corrected.**

`closconv.chiral:969` is the same shape and its "unreachable" is discharged.
`fs` is `(g-param-specs sig g k)`, `cwalk-app-head` guards its site with
`0 < k < ar` (`:827`), and the two `fv-*` paths build `cs-g g 0 nil`, so the
`p < k` branch is either fed exactly `k` entries or never entered. An unproven
comment over a proven fact.

`lower.chiral:407` is a **different** shape and does not belong beside the
other two. Its comment reads `defensive`, not `unreachable`; it produces a
short binder list rather than a fabricated value; and it is a list running out
rather than a `Maybe` failing. Nothing there invents a `0`.

The closer third instance is `cap-subst`'s `((nil) nil) ; unreachable: aligned`
(`closconv.chiral:1005`), which is `g-subst-go`'s twin on the `cs-lam` side and
carries the same unproven comment over a value. It is unmeasured here.

**What chirality makes impossible here.** It makes throwing impossible, which is
what produced the defect. It also makes the honest repair cheap and composable,
which is what closes it: the refusal is a **value**, it travels in a sum, and the
consumer already exists. `keep-fams` (`closconv-driver.chiral:96-106`) takes a
poison list threaded through `CState`'s `pois` field (`closconv.chiral:618`) and
removes the family wholesale; `st-add-pois` (`:684`) is how a site joins it. The
standing boundary-sums directive says the classification travels as a value, and
this is a case with the consumer already built.

⚑ **Erasing the codomain would hide this, and that is the one shape ruled out in
advance.** [[banks/erasure]] shard F records `tt-word` as representation-
compatible with any one-word type, checked by `tal-ty=?` whose first arm matches
everything. A `tt-word` return accepts `const 0`, the two red rows go green, and
the wrong code still ships. This is a citation to a built shard rather than a gap:
the erasure the tree performs is correct and it is the wrong instrument to point
at a wrong value.

## 5. Chirality example (fleshed)

Two snippets. The first is candidate (a), the call spine, which is the code a
later run copies. The second is the refusal channel, which is what any of (c) or
(d) needs and which (a) does not remove the need for.

**The binder layout, read off the code rather than assumed.** `apply-body`
(`closconv.chiral:1124-1126`) is `mk-lams (+ 1 d)` over `(c-case (c-var d) arms)`,
and the arm pushes `m` capture binders. `g-subst-go` (`:961-977`) states the
resulting indices, and candidate (a) reuses them verbatim:

| what | index inside the arm |
|---|---|
| the closure scrutinee | `(+ m d)` |
| capture `kj` (kept fields, `cap0` outermost) | `(- (- m 1) kj)` |
| dispatcher argument at source param `p >= k` | `(- (- (+ m d) 1) (- p k))` |
| an **erased** captured param `p < k` | `(+ m d)`, the convention `g-subst-go` already uses |

```chirality
; ---------------------------------------------------------------- candidate (a)
; The arm for a cs-g site, built from the SITE and never from the callee's body.
; Correct for every cs-g site WHERE d = arity - k holds.  ⚑ THAT IS AN
; OBLIGATION, NOT A CONSTRUCTION.  See the note under this block.

; one argument term per source parameter p in 0..arity-1, in source order.
(declare spine-args (-> I64 I64 (List (Pair I64 Core)) I64 I64 I64 I64 (List Core)))
(def spine-args
  (lam (p kj fs arity k m d)
    (case (<i p arity)
      (false nil)
      (true
        (case (<i p k)
          ; a captured argument: read it out of the $clo, or, if the field was
          ; erased (E100 / erasure shard A), emit the same placeholder g-subst-go
          ; emits.  Sound because a q=0 position has no runtime presence.
          (true (case fs
                  ; ⚑ THE AUDIT FLAGS THIS ARM.  It is `g-subst-go`'s
                  ;   `((nil) nil) ; unreachable: fs has k entries` (:969)
                  ;   copied verbatim, and it silently TRUNCATES the spine
                  ;   rather than fabricating a 0.  Copying an unproven
                  ;   "unreachable" into the arm written to remove one is the
                  ;   defect this element exists to close.  The SPEC either
                  ;   discharges it with `k <= |fs|` at the site builder or
                  ;   routes it into the same refusal channel below.
                  ((nil) nil)
                  ((cons f rest)
                    (case (field-erased? f)
                      (true  (cons (c-var (+ m d))
                                   (spine-args (+ p 1) kj rest arity k m d)))
                      (false (cons (c-var (- (- m 1) kj))
                                   (spine-args (+ p 1) (+ kj 1) rest arity k m d)))))))
          ; a dispatcher argument: a0 outermost .. a_{d-1} innermost.
          (false (cons (c-var (- (- (+ m d) 1) (- p k)))
                       (spine-args (+ p 1) kj fs arity k m d))))))))

; the arm body: (g e0 .. e_{arity-1}), folded left by `cspine` (:1207).
; ⚑ `cspine`'s (declare) sits at :1206, BELOW arm-body at :1051.  Candidate (a)
;   hoists that one line.
(def spine-body (-> Str I64 (List (Pair I64 Core)) I64 I64 I64 Core)
  (lam (g arity fields k m d)
    (cspine (c-global g) (spine-args 0 0 fields arity k m d))))

; the replacement arm.  TWO READINGS OF `arity`, and they are NOT the same code:
;   ((none) (spine-body g (+ k d)          fields k m d))   ; A: arity FROM THE FAMILY
;   ((none) (spine-body g <arity sig g>    fields k m d))   ; B: arity FROM THE TYPE
; B reads `arity sig g` (:490-494), the TYPE alone and never the body, and it is
; total wherever g has a declared type.  A cannot disagree with the dispatcher
; because it is defined from it, and it silently truncates or over-extends the
; spine when g's real arity differs.  The SPEC picks one; the pre-run wrote A in
; the snippet and B in the prose, which is the contradiction this audit found.
```

⚑ **`d = arity - k` is an OBLIGATION the SPEC must discharge, and the pre-run's
ground for it is wrong. The EXAMPLE-level audit overturned this claim; it is the
one finding that changes what the SPEC owes.**

`d` is `(cc-llen (peel-pi-doms key))` of the **family key**
(`closconv-driver.chiral:204`, `:207`), and a `cs-g` site is built at three
places, which record three different arrows:

| site path | recorded arrow | is it `arity - k`? |
|---|---|---|
| `cwalk-app-head` (`closconv.chiral:826-833`) | `(ty-of ctx t)`, the type of the `k`-ary partial application, guarded `0 < k < ar` | yes, and this is the case the pre-run described |
| `fv-own` (`:844-850`) | the global's OWN type, `k = 0` | yes, trivially |
| `fv-site` (`:852-862`) | the **callee's parameter slot**, `k = 0`, and its own comment says so | **unproven** |

`arrow-key-eq` (`:381-385`) forces every member of one family to share a domain
count, so `d` is well defined per family. Nothing relates `d` to the *global's*
arity on the `fv-site` path. `peel-pi-doms` stops at a non-`Pi`, so a slot whose
codomain is a type variable peels shallower than the global filling it: this
tree's own prelude has such slots, `map-list`'s `(-> A B)` and `foldl`'s
`(-> B A B)` (`lib/prelude/list.chiral:37`, `:50`), and any of them filled by a
global whose arity exceeds the slot's depth gives `d < arity - k`.

Two consequences, and the second is why this is not a reason to abandon (a).

1. **Reading B without the invariant is unsound the same way the current code
   is.** At `d < arity - k` the innermost `spine-args` index
   `(- (- (+ m d) 1) (- p k))` goes negative. `arm-body`'s existing `some` path
   already computes exactly that expression through `g-subst` with `n` from
   `def-ctx`, so if the invariant fails, **today's code is already wrong at that
   site too**, in a second way this element does not yet name.
2. **The refusal channel is what closes it.** (a) with a `none` case for
   `d ≠ arity - k`, answered by (d) and carried by (c), is correct without the
   invariant. That is the recommendation this section already makes, and this
   finding is the sharpest argument for it: (a) alone is not enough.

⚑ **This run does not measure whether a real site breaks the invariant.** It
measures that nothing in the pass establishes it. The SPEC owes either a proof
or the `none` case, and a census is the cheaper of the two only if it is a gate
rather than a one-off.

```chirality
; ---------------------------------------------------------- the refusal channel
; What (c) and (d) both need, and what (a) still needs for the residue:
; arm-body stops being total in Core and answers in a sum instead.  Signature
; only; the arms are the SPEC's.
(declare arm-body (-> SigV Csite I64 I64 (List ApplyEnt) (Maybe Core)))

; ⚑ THE CONSUMER CHAIN, READ AT HEAD.  Five frames and two accumulators, not
; the three the pre-run named:
;   arm-body        closconv.chiral:1051
;   build-arms      closconv.chiral:1118   (builds one CArm per site)
;   apply-body      closconv.chiral:1124   (mk-lams over the c-case)
;   synth-apply     closconv-driver.chiral:201  -- core->term inside a `let`,
;                     result stuffed into the SynA accumulator
;   synth-applies   closconv-driver.chiral:212
;   synth-fams      closconv-driver.chiral:220 (SynR), reached from :285
; `synth` is not a function.  A (Maybe Core) has to cross core->term and both
; accumulators, so (d)'s cost is the chain and not the one signature.

; and the blame gets a name, because SkReason today has exactly two constructors
; and neither of them says this (skip-diag.chiral:11):
(data SkReason ()
  (sk-extern (op Str))
  (sk-callee (name Str))
  (sk-defunc (fam Str) (site Str)))     ; NEW: a site that cannot be lowered honestly
```

- **Knobs to modify.** Whether candidate (a) replaces the `none` arm only
  (minimal) or the whole `cs-g` case (uniform, and it retires `def-ctx`'s
  inlining path for globals). The erased-position placeholder, if the SPEC
  decides `(+ m d)` is the wrong convention to inherit. The `SkReason`
  constructor's payload, which the boundary-sums directive says should carry the
  blame the site knows rather than a formatted string.
- **Deliberately omitted.** The gate. Section 6 states what it must fail on and
  designs nothing, because that is the SPEC stage's work. Also omitted: the
  `cs-lam` arm, which is correct today and which no candidate touches; and the
  `build-new → test → promote` ceremony, which is the BUILD RULE's and not this
  example's.

### The four candidate shapes, judged

| | shape | what it costs | verdict |
|---|---|---|---|
| **(a)** | build the call spine from the `Csite` | one new helper (~15 L), reuse of `cspine` with its `declare` hoisted one place, and the erased-position placeholder inherited from `g-subst-go`. Touches `arm-body` alone. ⚑ Plus the `d = arity - k` obligation, which the pre-run priced at zero and the audit prices at either a proof or a `none` case. | **recommended, and it does not stand alone.** Correct without reading the body at all, and EN-20 already measured the thing it reproduces: `direct box-f: 30`. The spine *is* the direct call. But `fv-site` keys a site by the callee's parameter slot, so `d = arity - k` is not construction, and (a) without (d)+(c) trades one silent wrong value for another. |
| **(b)** | eta-expand a shallow body before peeling | a de Bruijn shift of the body under the added binders. `remap`/`rm` shift a threshold (`closconv.chiral:14`, `:143`) and `free-indices` exists (`:109`, used at `:1015`), so it is buildable, and it runs inside the pass that is already miscompiling. Changes `def-ctx`'s output for every shallow site. | **rejected.** Eta-expanding `(lam (m) (case m …))` to depth 4 produces the spine `((case m …) a b c)`. It computes candidate (a) the long way, through the body, at strictly higher risk and cost. |
| **(c)** | poison the family through `keep-fams` | ⚑ **cheaper than the pre-run priced it.** `collect` ALREADY consults `def-ctx`: `collect-defs` (`:922-930`) calls it at `:927` and skips the def on `none`. What is missing is the consult at the SITE, and all three site builders (`cwalk-app-head` `:864`, `fv-own` `:891`, `fv-site` `:899`) take `sig` as their first parameter, so the data is in hand at the point of decision. `st-add-pois` (`:684`) is the one call. `SkReason` needs a third constructor or the blame is unnameable. Converts wrong code into a missing function. | **keep as the backstop, reject as the primary.** A named skip beats a wrong value and loses to correct code. It is the right answer for any residue (a) cannot construct, such as a global with no declared type. |
| **(d)** | refuse: make the arm a refusal rather than a value | `arm-body : … (Maybe Core)`, propagated through `build-arms` (`:1204`), `apply-body` (`:1211`), then `synth-apply` / `synth-applies` / `synth-fams` in the driver (`:201`, `:212`, `:220`) and their two accumulators. ⚑ Five frames, not three. The refusal then has to *become* something, and the only thing in the tree that consumes it is the poison list. | **it is (c)'s local half, and it is right.** (d) states the impossibility; (c) is the mechanism that carries it. Adopting (d) without (c) leaves the compile with a `none` and nowhere to put it. |

**The recommendation, in one line.** Take **(a)** as the code answer and
**(d)+(c)** as the honesty answer underneath it, so that the arm is correct where
it can be constructed and refuses where it cannot, and no path returns a value it
cannot justify. What the SPEC stage must decide beyond that is the minimal-vs-
uniform knob: whether (a) replaces the `none` arm alone or the whole `cs-g` case.

⚑ **The audit strengthened this recommendation rather than weakening it.** The
pre-run offered (d)+(c) as honesty underneath a spine that was correct anyway.
With `d = arity - k` unproven on the `fv-site` path, (d)+(c) is the thing that
makes (a) correct, and dropping it is no longer a matter of taste.

## 6. Use / modify notes

- **Lands in:** `lib/lowering/upper/closconv.chiral` (`arm-body`, and `cspine`'s
  `declare`), plus `lib/lowering/upper/closconv-driver.chiral` and
  `lib/lowering/skip-diag.chiral` if the refusal channel is taken. All compiler
  source inside the blob, so the full BUILD RULE applies: `build-new → test →
  promote`, fixpoint verified, Step-0 precondition checked first.
- **Conformance target:** EN-20's fixture. `box-f` has `mach-galo`'s shape
  exactly, three domains after peeling and one `lam` in the body. Today's binary
  prints `direct box-f: 30`, `via $apply: 0`, `via $apply2: -10`. The repaired
  binary must print `30` on the second line as well as the first. The metamorphic
  relation the fixture asserts is the target stated generally: **for every
  defunctionalized global `g`, routing a call through `$apply` agrees with
  calling `g` directly.**

### What the gate has to be able to fail on

⚑ **The existing `ret` check demonstrably does not catch this, so no gate built
on `ck-prog` alone qualifies.** `ck-term`'s `t-ret` arm
(`lib/lowering/tal/check.chiral:256-258`) compares the returning register's tal
type against the declared return through `tal-ty=?`. It reddens `$apply5` and
`$apply6` because their family codomain is `(List Asm)` and `const 0 : i64`
disagrees. EN-20's fixture has codomain `I64`, `const 0` agrees, and the check
accepts. Stated as a requirement:

1. **It must fail on a body that returns a literal where a computation belongs,
   with the family codomain `I64`.** This is the case `ck-prog` accepts silently,
   and it is the case the compiler's own two instances do not exercise. A gate
   that only reproduces the two `(List Asm)` instances is testing the luck rather
   than the defect.
2. **It must assert the VALUE.** The observable has to be an answer the program
   computes, because the type-level assertion is absent for the whole class of
   families whose codomain is ground. `direct` against `via $apply` on one
   fixture is the smallest instrument that can carry that.
3. **It must have a run mutant that reddens it.** [[banks/verification]] §1:
   *"A gate row must name a mutant that breaks it and the mutant must be run."*
   The obvious candidate is reverting `arm-body`'s repaired arm to `(c-lit-i 0)`,
   and it must be built and run rather than derived, which is the correction EN-21
   made to E186's M5.
4. **It must not be satisfiable by the fixpoint or by the suite's current green
   line.** Both are undisturbed by this defect today, by EN-20's measurement, so
   either passing is evidence of nothing.

5. ⚑ **It must assert that the dispatcher is ON the path, and this requirement
   was missing.** Requirements 1 to 4 are individually satisfiable and none is
   unsatisfiable as stated, but the set has a hole the EXAMPLE-level audit
   found: requirement 2's observable is *`direct` agrees with `via $apply`*, and
   candidate **(c)** satisfies it by deleting the second term. Poisoning the
   family drops it at `keep-fams`, the site is never rewritten to a `Con`,
   `use` becomes a missing label, and the `via $apply` line does not print at
   all. A row that reads "the two agree" then passes on absence. Since this
   section recommends (a) with (c) underneath it, the gate has to distinguish
   *repaired* from *removed*: it must assert that the fixture's family is built
   and its `$apply` called, and it must grade a skipped compile as `absent`
   rather than as `ok`. E185's `apply-word.sh` already spells that convention,
   with `absent` a distinct cell from `ok` and `bad`.

An element whose gate cannot see its own defect is a gate that cannot fail, which
is the failure the erasure bank names in its own build-state note and which
[[decisions/decision-scope]] consequence 2 is about at the rung level: every rung
reading ENFORCED is enforcement against error. A gate blind to its element's
error enforces nothing.

### Does E188 split?

**No. One element.** Three reasons.

1. **The gate belongs inside it, and this arc has set that precedent twice.**
   E185 built `tools/test/apply-word.sh` inside the element; E186 built
   `tools/test/capture-fields.sh` inside the element and resolved rather than
   built. Splitting the gate out would make the fix an element with no falsifier,
   which is precisely what §6 above forbids.
2. **The four shapes are one decision, and it is single-valued.** (a), (b), (c)
   and (d) are not four workstreams. (b) reduces to (a), and (d) is (c)'s local
   half. What ships is one arm and one channel, in one function and its two
   consumers.
3. **The residue that could be its own element is not enforcement work.** The
   honest residue is *"nothing measures the blast radius on purpose"*: no
   instrument re-derives EN-20's census of which dispatchers any TFn actually
   calls. That is a reachability census over the blob, which is diagnostics-arc
   shape rather than Lane A enforcement shape.

⚑ **This section mints nothing.** `E189` is the last free number in Lane A's band
(`docs/decisions/decision-lane-split.md`, `E184–E189`), the band is shared with
[[arcs/diagnostics-arc]], and [[definitions/working-discipline]]'s deferral rule
forbids naming a follow-on without minting its rows. So the census residue is
named here as residue and is left `UNASSIGNED`. If a later stage judges it worth
an element, that stage mints it.

- **Open questions for the SPEC stage.**
  - ⚑ **First, and the audit added it: discharge `d = arity - k`, or carry a
    `none` case for its failure.** `fv-site` (`:852-862`) keys a site by the
    callee's parameter slot, so the invariant is nowhere established. Either
    prove it, or read `arity sig g` and refuse the mismatch through (d)+(c).
    A census that runs once settles nothing; the discharge has to be a gate or
    a refusal in the code. ⚑ The existing `some` path rests on the same
    invariant through `g-subst`, so whichever answer the SPEC picks applies to
    both arms of the `cs-g` case, which pushes the minimal-vs-uniform knob
    below toward uniform.
  - Which reading of `arity` the replacement arm takes: `(+ k d)` from the
    family, or `arity sig g` from the type. They are different code and the
    pre-run's snippet and prose disagreed; this is the fork underneath that
    disagreement.
  - Minimal or uniform: does (a) replace the `none` arm alone, or the whole
    `cs-g` case? Uniform retires a code path and changes emitted code for eleven
    currently-correct sites, so it needs the fixpoint to be the arbiter.
  - The erased-position placeholder. `g-subst-go` maps an erased captured param
    to `(+ m d)`, the closure's own index. Candidate (a) inherits it. Whether
    that convention is *sound* or merely *unobserved* is unmeasured by this run
    and the SPEC should settle it against [[banks/erasure]] shard A.
  - ~~Does `collect` reach `def-ctx` cheaply?~~ **Read, and the answer is yes.**
    `collect-defs` calls `def-ctx` at `:927` already, and every site builder
    carries `sig`. What is left for the SPEC is not reachability but placement:
    poison at the site builder, or after `collect` in a second pass over the
    families.
  - Whether a global with no declared type can reach a `cs-g` site. `arity`
    (`:490`) returns `(Maybe I64)`, so candidate (a) has a `none` case of its own,
    and that is exactly the residue (c) catches.
  - ⚑ **A doc-tier residue, for a later `doc-audit` rather than for this run.**
    `docs/definitions/bug-classes.md:85` carries the `miscompilation` row with
    the mechanism *"typed assembly, checked at instruction level"* and state
    `unwired`, against E16 and E18. E188 is a measured instance of that class
    whose stated mechanism does not cover it, because `ck-prog` accepts `const 0`
    at a ground codomain. The row is not edited here.
- **Related:** [[arcs/enforcement-arc]] · [[records/enforcement-arc]] EN-19, EN-20 ·
  [[decisions/decision-erased-word-level]] · [[banks/erasure]] ·
  [[banks/verification]] · [[definitions/pattern-boundary-sums]] ·
  [[definitions/bug-classes]] · E185 (built, and its residue is a TYPE) ·
  E186 (ruled `concrete`, and it is not this) · E187 (states types, and it is not
  this) · E16, E18 (the unwired checker this defect would evade anyway).
