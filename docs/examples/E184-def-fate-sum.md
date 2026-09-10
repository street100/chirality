---
element: E184
slug: def-fate-sum
title: **Attribution: every def's fate is stated by the compiler, with evidence, and checked**
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-09-10
---

# E184 — **Attribution: every def's fate is stated by the compiler, with evidence, and checked**

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E184, the fate of every definition the compiler is handed, spelled
  as a closed sum, carried to the success arm, and conserved.
- **Kind:** BUILD-PROPER. The classification exists in four places as four
  partial filters and in no place as one type.
- **Why chirality needs its own:** [[decisions/decision-def-partition]],
  `status: settled`, ruled the partition and wrote it in prose tables with the
  classes named in English. It contains zero declarations and zero code blocks.
  What is owed after it is the literal mechanical spelling, and §5 of this file
  is that spelling.

**This run adds no measurement of its own to §2 of the decision.** The counts
below are that document's, taken 2026-09-09 over 63 roots and 22,742 globals, and
they are read here rather than re-derived. What this run adds is the shape, plus
four readings of the live source that the decision's class table does not
survive.

**Reproduced at HEAD, 2026-09-09** (`309994c`). Every line below was read from
the working tree during this run.

| claim | verified |
|---|---|
| `SkReason` has three constructors and `sk-defunc`'s `why` is a `Str`, `skip-diag.chiral:15` | yes |
| `skip-diag.chiral:11-13` calls that `Str` *"one of two discriminants"* | yes |
| `skwhy-tag` renders `sk-extern` as `"extern"`, `skip-diag.chiral:28-29` | yes |
| `compile-back.chiral:271` wraps every term-level `le-skip` as `(sk-extern er)` | yes |
| `skip-diag.chiral:8` imports `prelude/prelude` and nothing else | yes |
| `compile-back.chiral:11-12` states the lower image cannot import `kernel` | yes |
| `lower.chiral` has **19** originating skip sites: `grep -c -- '-skip "'` = 15, `grep -c -- '-skip (str-cat'` = 4 | yes |
| `peel-def` is `compile-front.chiral:211-223` with four `(none)` arms at `:214`, `:217`, `:220`, `:222` | yes |
| `sk-defunc`'s two `why` strings are built at `closconv.chiral:723` and `:726` | yes |
| kernel `Term` has **16** constructors, `surface/syntax.chiral:18-34` | yes |
| `term->ntalty` names 5 of them and refuses through a `_` arm, `compile-front.chiral:60-72` | yes |
| `outline` emits an extra TFn named `<def>$<ncase>`, `lower.chiral:311-320`, adopted at `compile-back.chiral:272` | yes |
| `Mach` has **37** fields and `lib/lowering/mach/mach.chiral` defines **37** `mach-*` projectors | yes |
| `x64`'s 37 field bodies split **10** lambdas and **27** bare globals, `x64/mach.chiral:1680-1766` | yes |

### Four readings the decision's class table does not survive

Each one is read off the live source with a citation, and each one changes a
field type or a domain in §5.

**M-A. `emitted <label>` is singular and a def emits one or more labels.**
`outline` (`lower.chiral:311-320`) lifts a non-tail `case` into its own TFn named
`(str-cat (str-cat name "$") (i64->str ncase))` and returns it through `st-extra`;
`lower-defs` adopts `(cons main extra)` whole at `compile-back.chiral:272`.
Derived from [[decisions/decision-def-partition]] §2's own pinned figures for
`prog/compiler.prog`: 1,519 defs, 10 skipped, so 1,509 lowered, against
`tfns=1549` from `tools/test/opt-census.sh`, which puts **40 outlined extras**
across those 1,509, and `1549 - 2 = 1547` emitted `NFn`s after the cascade drops
two. R7's fold reproduces the emitted set only if a fate names every label its def
produced, so the field is `(List Str)`.

**M-B. The skip records are keyed by emitted label and the fate function is
keyed by definition.** `filter-erasable` builds `(mk-skrec (tfn-nm f) ...)` at
`compile-back.chiral:191` and `prune-pass` does the same at `:211`, and by M-A a
`TFn`'s name is sometimes `<def>$<ncase>`. `tools/test/opt-census.sh` R3 already
pins 31 refusals whose callee is *"the refused TFn's own `<name>$0` outlined
block"*, so outlined names reach the same lists. The two channels run at
`compile-back.chiral:255-256` over a flat accumulator that has lost the per-def
grouping `lower-defs` had at `:272`. Attribution therefore needs an owner
relation carried into both, and reading it back off the `$` convention is a
string standing in for a relation.

**M-C. `erased-by-design`'s named producer does not produce it, and its
extension is empty for a structural reason.** The decision's table gives the
producer as *"`filter-erasable`'s silent arm, `compile-back.chiral:189`"*. That
arm fires when `erase-fn` answered `xf-err m` **and** `first-nonlowering-op` found
no op to name; it discards `m` and drops the function. That is an unattributed
failure, and it is a skip. The type-level defs the arm was written to describe
never reach it: a `Sig`'s type-level content lives in `sig-datas`, and a
hypothetical type-level global dies four passes earlier at `peel-def`'s codomain
refusal (`compile-front.chiral:213-214`), which the same table files under
`type-does-not-peel`. So the two rows have swapped producers, and the arm R1
requires has, today, no producer at all.

**M-D. `specialize-singletons` does not rename, and it creates definitions the
stated domain does not contain.** Read at `specialize-singleton.chiral:193-206`
and `:227-232`:

| the pass does | where |
|---|---|
| lifts each field body that is **not** already a `(t-global g)` into a NEW global named `<gname>$<i>`, `i` the field index | `lift-lifted`, `:195` |
| maps a field body that **is** a `(t-global g)` to `g` and creates nothing | `lift-add`, `:194` |
| offers the singleton global **and every projector** for pruning | `process-mk`, `:202` |
| keeps any of those still referenced after the rewrite and deletes the rest | `prune-live` / `drop-pruned`, `:227-228` |
| rewrites `(proj m)` applications to `(t-global target)` | `sp-rw`, `:124-132` |

On `prog/compiler.prog` this is measurable by reading the two singletons.
`x64` (`x64/mach.chiral:1680`) has 37 field bodies, 10 of them `(lam …)` and 27 of
them bare globals, so it creates `x64$0` through `x64$5`, `x64$7`, `x64$8`,
`x64$9` and `x64$12`, **ten new definitions**, and offers `x64` plus 37 `mach-*`
projectors for pruning. `alloc-growing` (`memory/alloc-growing.chiral:18-24`) has
5 field bodies, 2 of them the projectors `mach-galo` and `mach-gbnw` and 3 of them
lambdas, so it creates **three more** and offers itself plus 5 `alo-*` projectors.
Thirteen created names, forty-four offered for pruning, and how many survive is
unmeasured, which is F3.

Two consequences, and both are structural rather than statistical. **`x64$0` is
not in the pre-pass definition set**, so a fate function whose domain is that set
cannot claim the label `x64$0` that the emitted program contains. And **a
singleton global that stays referenced keeps its own fate**: `prune-live` deletes
only the unreferenced, and E188's example measures `alloc-growing` reaching
`compile-fn` and being skipped there, so one definition is both the source of a
`specialized-into` relation and the subject of a `skipped` fate. R1's *exactly one
per def* and R7's *folding reproduces the emitted set* pull in opposite directions
until the domain is chosen, which is decision 1 in §6.

⚑ **The catalog's `x64` becomes `x64$0` reads as a rename and the pass performs a
delete and a create.** The sentence is in `docs/elements/catalog.md:500`, in the
ledger row, in the arc's R6 and in [[decisions/decision-def-partition]] §1. It is
directionally right about identity moving and wrong about the mechanism, and the
mechanism is what decides the domain.

## 2. Research

- **Reference class:** the catalog and the ledger both say `OURS` with the `ours`
  cell `(none)`, so no baseline in this tree holds the answer. What carries this
  section is the tree's own settled precedent for exactly this shape, and every
  cite below is a tracked file read during this run. **No web fetch was performed
  and no external source is cited.**

**Finding 1. The taxonomy rule is already written, and it is checkable at
review.** `lib/typing/diag.chiral:12-18`: *"ONE `Reason` constructor per EVIDENCE
SHAPE, never per message. What a reason is ABOUT varies far more than what it
CARRIES, so the varying part is a separate `Subject`, and the judgments whose only
evidence IS their subject share one arm (`r-judged`) over a closed `Judg` code."*
E157 discharged it at scale: `Reason` has 10 arms, `Subject` 12, and `Judg` 36
(`diag.chiral:99-141`). A 36-arm closed code is this tree's demonstrated answer to
a wide which-of-N, so §5's 18-arm `SkLow` and 16-arm `SkHead` are inside the
established range rather than a new device.

**Finding 2. The rule was stated and then broken in the same file it governs.**
`skip-diag.chiral:11-13` documents `sk-defunc`'s `why` as *"one of two
discriminants"* and types it `Str`. `pattern-boundary-sums`' test is quoted in the
worked-example cheatsheet: *"if a `Str`/`I64` in a signature encodes
WHICH-OF-N-THINGS, it is a sum wearing a disguise."* Two producers exist, at
`closconv.chiral:723` and `:726`, and both are literals. This is the smallest
correction in §5 and it is forced.

**Finding 3. The accessor-function pattern is mandatory, and the source files say so.**
`skip-diag.chiral:3-6` and `diag.chiral:20-25` both state it, and the second calls
it inherited from the first: every `case` on these sums lives inside a small
accessor def as the direct body of a `lam`, because a nested case over a
newly-defined data type triggers a real compiler *"unknown name"* bug. Every sum
§5 introduces owes its accessors in the same file, which is why the accessor block
is part of the spelling rather than an afterthought.

**Finding 4. E97's blame chain is a walk with fuel, and the walk is a symptom of
the missing field.** `blame-chain` (`skip-diag.chiral:92-106`) takes `fuel` and
`format-blame` passes 100. The walk exists because `sk-callee` carries a pointer
and the root is somewhere else in the list. R5 asks for the root; carrying it as a
field retires the walk and the fuel together, and makes *"resolves to a
non-cascade root"* true by construction instead of true by iteration.

**Finding 5. A module both compiler images import may import only `prelude`.**
`lowspec.chiral:5-12` records the finding and calls it verified: the flat global
namespace plus whole-file import makes `kernel` and `tal-ssa` in one module a hard
load error, `data Term redeclared`. `compile-back.chiral:11-12` states the same
constraint from the lower side. `skip-diag` is already on both sides, through
`compile-back.chiral:21` in the lower image and through `typing/diag.chiral:57` in
the kernel image, and its own import list is one line (`skip-diag.chiral:8`). So
the fate sum may carry names, integers and its own codes, and it may carry neither
a kernel `Term` nor a tal `TalTy`. That single constraint decides more of §5's
field types than any other fact in this file.

## 3. Conventional (other-language) approach

The conventional shape is in this tree's own comments, describing the oracle this
compiler was differentiated against. `compile-back.chiral:265-269`:

> a def the back cannot lower is SKIPPED (not fatal) — mirrors
> `lower.py.lower_all`, whose skipped map is non-fatal.

and `lower.chiral:1-5` scopes the dead partition as *"the self-contained half
differentiable against `lower.py.lower_all`'s partition today"*.

⚑ **The file is gone.** [[status-ledger]] records the oracle CUT and the
2026-08-31 migration deleted `scaffold/` entirely, so the sketch below is
reconstructed from those two comments and is labelled as a reconstruction rather
than a quotation.

```python
# the conventional partition: a dict of survivors and a dict of excuses.
def lower_all(defs):
    lowered, skipped = {}, {}
    for d in defs:
        try:
            lowered[d.name] = lower_def(d)
        except Ineligible as e:
            skipped[d.name] = str(e)          # the reason is a sentence
    return lowered, skipped                    # and the caller usually drops it

def compile_all(src, entry):
    lowered, skipped = lower_all(parse(src))
    elf = emit(lowered)
    if elf is None:
        raise CompileError(explain(skipped))   # skipped is read ONLY on failure
    return elf                                 # on success it goes out of scope
```

- **Assumptions it bakes in.**
  - **A definition that leaves the pipeline needs no record.** Dropping is
    ordinary control flow, so the majority class of exclusion can be produced by a
    filter that returns nothing and says nothing. `filter-erasable`'s silent arm
    (`compile-back.chiral:189`) and `peel-def`'s four `(none)` arms are that
    assumption, live in this tree today.
  - **The reason is a sentence.** A string is the widest type available, so one
    construction site can serve four causes and the consumer re-parses or gives
    up. `compile-back.chiral:271` is that assumption, live, 182 times.
  - **The record is diagnostic, so it belongs on the error path.** Success has no
    use for it. `compile-all.chiral:34-35` is that assumption, live: `elf-ok`
    returns the bytes and the `skips` list goes out of scope.
  - **Conservation is a property of the code, checked by reading it.** Nothing
    computes the partition and compares it to the artifact, so a definition can be
    dropped twice, or dropped and emitted, with no observable.
  - **Attribution across a rewriting pass is the reader's problem.** A pass that
    lifts, renames and deletes emits a new program and no relation between the
    two, so the before-and-after correspondence is reconstructed from a naming
    convention.

Every one of the five is already in this tree, which is what makes the section
short. The conventional approach is the incumbent.

## 4. The chirality idea

- **Chirality features in play:** closed sums with coverage-checked `case` and no
  `_` arm; errors as values, so the classification IS the return type; the
  boundary-sums standing directive; totality, so the fate function is a total
  function rather than a best-effort pass; and the flat-namespace image split,
  which is what constrains the evidence a fate may carry.

- **The reframing.** The conventional partition is a filter that keeps survivors
  and a side channel that describes casualties. The chirality partition is one
  **total function** from the definition set into a closed sum, and every existing
  filter becomes a producer of that function's value. Three things follow, and
  each is a requirement E184 already carries.

  **Dropping stops being expressible.** `peel-def` returns `(Maybe NDef)` today
  and R3 makes it a result sum, so the four `(none)` arms at
  `compile-front.chiral:214`, `:217`, `:220` and `:222` each have to name what
  they refused. There is no arm left that discards.

  **The reason stops being a sentence.** R2 makes it a sum, and E157's rule says
  one arm per evidence shape. The 182 term-level refusals then land on 18 sites
  that already exist as distinct code paths in `lower.chiral`, and the 5 genuine
  extern refusals keep the arm all 187 share today.

  **The chain stops being a pointer.** R5 asks that every cascade resolve to a
  non-cascade root. Splitting the reason into a `SkRoot` with no cascade arm and a
  `SkReason` whose cascade arm carries a `SkRoot` makes an unrooted chain
  **unrepresentable**. That is E97's own construction read one level further:
  the cheatsheet records `SkReason` as the precedent where *"the blame chain
  exists at the entry gate BY CONSTRUCTION"*, and the root is the part of the
  chain the current spelling still leaves to a walk.

- **The structural constraint, and it decides the field types.** Finding 5:
  `skip-diag` is imported by `typing/diag.chiral:57` in the kernel image and by
  `compile-back.chiral:21` in the lower image, and a module in both may import
  only `prelude`. So:

  | wanted evidence | available where the refusal happens | carriable in the sum |
  |---|---|---|
  | the refused type, as a `Term` | yes, `term->ntalty` is in the kernel image | **no.** `Term` in the lower image is `data Term redeclared` |
  | the refused type, as a `TalTy` | yes, `expr-case` holds `sty` | **no.** `tal-ssa` in the kernel image is the same refusal |
  | which `Term` head was refused | yes | yes, as a code declared in `skip-diag` |
  | a definition name, an op name, a ctor name | yes | yes, `Str` |
  | a binder index, an arity, a field index | yes | yes, `I64` |

  This is the same seam `lowspec` was built for, read from the diagnostic side:
  `NTalTy` exists because an `NDef` has to cross it, and `SkHead` exists for the
  same reason. E157 carries a whole `Term` in `r-mismatch` (`diag.chiral:125`)
  precisely because `typing/diag` sits on one side only.

- **What chirality makes impossible here.** No `_` arm, so adding a nineteenth
  skip site in `lower.chiral` is a compile error in `skip-diag`'s renderer rather
  than a silently accepted new string. No exceptions, so a refusal cannot leave
  the pipeline without passing through the return type. No ambient log, so a
  producer cannot describe a drop without also being the drop. And once R7's
  `conserve` runs inside the compile, no definition can be dropped twice or
  dropped and emitted, because the fold is compared to the artifact and the
  compiler refuses itself.

## 5. Chirality example (fleshed)

Real surface syntax. Six parts: the four evidence codes, the two-level reason,
the fate, the accessors the pattern forces, the signatures the shape forces, and
the conservation check. Every line citation was read at `309994c`.

```chirality
; ---------------------------------------------------------------------------
; E184. Every definition's fate, as a value.
; Lands in lib/lowering/skip-diag.chiral, which already holds SkReason/SkRec
; (:15-16) and is the ONE module both compiler images import.
; ---------------------------------------------------------------------------
(import "prelude/prelude")   ; and nothing else. skip-diag is in the kernel image
                             ; (typing/diag.chiral:57) and in the lower image
                             ; (compile-back.chiral:21); a module in both cannot
                             ; import kernel or tal-ssa (lowspec.chiral:5-12,
                             ; `data Term redeclared`, verified).

; ---- (i) WHICH Term head a peel refused --------------------------------------
; Sixteen arms, one per kernel Term constructor (surface/syntax.chiral:18-34).
; A CODE and not the Term, by the import rule above.  term->ntalty names five
; heads (t-primty, t-tcon, t-refine, t-var, t-pi) and refuses the other eleven
; through its `_` arm at compile-front.chiral:72; term->ncore names eleven and
; refuses five at :134.  One code covers both channels: 16 = 5 + 11 = 11 + 5.
; Five arms carry the name the head itself carries; eleven have none, which is
; the r-judged/Judg split (diag.chiral:94-111) applied here.
(data SkHead ()
  (sh-var)              (sh-type)             (sh-pi)        (sh-lam)
  (sh-app)              (sh-let)              (sh-ann)       (sh-lit-i)
  (sh-lit-s)            (sh-case)             (sh-refine)
  (sh-global (n Str))   (sh-prim   (n Str))   (sh-primty (n Str))
  (sh-tcon   (n Str))   (sh-con    (dn Str) (cn Str)))

; ---- (ii) WHERE in peel-def the refusal happened ------------------------------
; peel-def (compile-front.chiral:211-223) has FOUR (none) arms and THREE causes:
; the codomain (:214), a kept domain (:220), and the body twice (:217 on E185's
; stated branch, :222 on the peeled branch).  The stated/unstated split is
; sp-get's and carries nothing about the refusal, so it earns no arm.
; `ix` is the kept-domain position, which ty-kept-doms (:160-163) produces in
; order and term->ntalty-list (:73-78) currently discards.
(data SkPos () (skp-cod) (skp-dom (ix I64)) (skp-body))

; ---- (iii) WHICH of closconv's two refusals fired -----------------------------
; EXACTLY two, and they are the two literals st-pois-defunc is handed today:
; "no declared type" (closconv.chiral:723) and "family arity disagrees with the
; global's" (:726).  skip-diag.chiral:11-13 already calls the field "one of two
; discriminants", which is the definition of a sum wearing a Str.
(data DefWhy () (dw-no-declared-type) (dw-family-arity))

; ---- (iv) WHICH body-compile site refused ------------------------------------
; NINETEEN originating sites in lib/lowering/upper/lower.chiral, fifteen literal
; and four str-cat.  EIGHTEEN arms: :309 and :358 are one refusal reached from
; expr and from tail, same evidence and same text, so they share an arm.
; One arm per EVIDENCE SHAPE, which is E157's rule (diag.chiral:12-18).
; The three measured classes are marked; the other fifteen sites produced zero
; records over 63 roots, and the sum states them anyway because R1 forbids `_`.
(data SkLow ()
  (sl-unbound-var     (ix I64))                ; :239  env-get missed the index
  (sl-lit-absent      (v Str))                 ; :242  literal not in the table
  (sl-ref-no-sig      (n Str))                 ; :246  global with no TalSig
  (sl-ref-not-nullary (n Str))                 ; :249  global in value position, arity > 0
  (sl-prim-value      (n Str))                 ; :250  prim in value position
  (sl-lam-value)                               ; :251  MEASURED 10
  (sl-partial-app)                             ; :266
  (sl-over-app)                                ; :268
  (sl-extern-no-sig   (n Str))                 ; :278  the one genuine extern refusal here
  (sl-callee-no-sig   (n Str))                 ; :281
  (sl-ho-app)                                  ; :283  MEASURED 162
  (sl-con-data        (dn Str))                ; :293
  (sl-con-ctor        (dn Str) (cn Str))       ; :295
  (sl-case-nondata)                            ; :309 and :358
  (sl-outline-data    (dn Str))                ; :325
  (sl-case-data       (dn Str))                ; :352
  (sl-branch-nonctor  (cn Str))                ; :364
  (sl-short-chain     (want I64) (have I64)))  ; :417  MEASURED 10

; ---- (v) WHY a definition was skipped, and every one of these is a ROOT --------
; Five arms against the decision's five skipped classes, with the counts from
; decisions/decision-def-partition.md §2 beside each.
(data SkRoot ()
  (skr-body   (site SkLow))                    ; 182 of 347.  compile-back.chiral:271
  (skr-extern (op Str))                        ; 5 of 347.    filter-erasable's named arm, :191
  (skr-erase)                                  ; filter-erasable's SILENT arm, :189
  (skr-defunc (name Str) (why DefWhy))         ; 0 of 347.    closconv.chiral:698
  (skr-peel   (pos SkPos) (head SkHead)))      ; 0 of 347 on definitions, and no record today

; ---- (vi) the reason a record carries -----------------------------------------
; R5 asks that every cascade chain resolve to a non-cascade root.  Spelled this
; way it holds BY CONSTRUCTION: sk-cascade's `why` is a SkRoot and SkRoot has no
; cascade arm, so an unrooted chain is UNREPRESENTABLE.  prune-fix's transitivity
; (compile-back.chiral:213-219) is discharged where the record is built, and
; blame-chain's 100 fuel (skip-diag.chiral:92-106, :121) becomes a field read.
; The NAME SkReason is kept and its three constructors are retired: sk-extern
; moves down to skr-extern, sk-defunc to skr-defunc, and sk-callee becomes
; sk-cascade with the root beside the pointer.  Four construction sites move,
; at compile-back.chiral:191, :211, :271 and closconv.chiral:698, plus one
; fixture at tools/test/samples/e158_doc.prog:154.  Keeping the type name is what
; makes those four a COMPILE ERROR rather than a silent survival, which is
; E157's own argument for a closed sum (diag.chiral:16-18).
(data SkReason ()
  (sk-root    (why SkRoot))
  (sk-cascade (callee Str) (root Str) (why SkRoot)))

; ---- (vii) THE FATE ------------------------------------------------------------
; Four arms, closed, no `_`.  Two field types are corrections rather than
; transcriptions of R1 and both are argued in §1:
;   `labels` is a LIST, because outline (lower.chiral:311-320) emits <def>$<n>
;     beside the main TFn and lower-defs adopts (cons main extra) at
;     compile-back.chiral:272.  M-A derives 40 such extras on prog/compiler.prog.
;   `into` is what specialize-singletons CREATED from this definition, which is
;     lift-lifted's <gname>$<i> (specialize-singleton.chiral:195), and it is
;     empty for a definition the pass did not touch.
(data Fate ()
  (ft-emitted     (labels (List Str)))
  (ft-specialized (into   (List Str)))
  (ft-erased)
  (ft-skipped     (why    SkReason)))

; FateRec RETIRES SkRec (skip-diag.chiral:16), whose two fields it widens: a
; record now exists for a definition that succeeded.  Its four readers move with
; it: BR (compile-back.chiral:126), FR (compile-front.chiral:320), CCOut's dsk
; (closconv-driver.chiral:145) and r-skipped (typing/diag.chiral:135).
(data FateRec () (mk-fate (def-name Str) (fate Fate)))

; ---- (viii) the accessors the pattern forces ----------------------------------
; skip-diag.chiral:3-6 and diag.chiral:20-25 both state it and the second calls
; it inherited from the first: every case on these sums lives inside a small
; accessor def, as the DIRECT body of a lam, because a nested case over a
; newly-declared data type triggers a real compiler "unknown name" bug.  This is
; not optional and it is why the block is part of the spelling.
(declare fate-tag       (-> Fate Str))
(declare fate-labels    (-> Fate (List Str)))
(declare fate-reason    (-> Fate (Maybe SkReason)))
(declare fatrec-name    (-> FateRec Str))
(declare fatrec-fate    (-> FateRec Fate))
(declare skreason-tag   (-> SkReason Str))
(declare skreason-root  (-> SkReason SkRoot))
(declare skroot-tag     (-> SkRoot Str))
(declare skroot-name    (-> SkRoot Str))
(declare sklow-tag      (-> SkLow Str))
(declare sklow-name     (-> SkLow Str))
(declare skhead-tag     (-> SkHead Str))
(declare skhead-name    (-> SkHead Str))
(declare skpos-tag      (-> SkPos Str))
(declare defwhy-text    (-> DefWhy Str))

; the two that carry the argument, spelled out.  The rest are the same shape.
(def skreason-root
  (lam (r) (case r ((sk-root w) w) ((sk-cascade cn rn w) w))))

; PRB-81's observable lives here.  Today skwhy-tag (skip-diag.chiral:28) answers
; "extern" for all 187 records; after this it answers "extern" for 5 and "body"
; for 182, and the three body classes have tags of their own through sklow-tag.
(def skroot-tag
  (lam (w) (case w
    ((skr-body   s)     "body")
    ((skr-extern op)    "extern")
    ((skr-erase)        "erase")
    ((skr-defunc n why) "defunc")
    ((skr-peel   p h)   "peel"))))

; ---- (ix) the signatures the shape forces --------------------------------------
; Declares only.  Each one names the site it replaces.

; R3.  peel-def stops returning (Maybe NDef).  compile-front.chiral:211-223.
; pk-erased is the arm M-C says has no producer today: a codomain refused at
; (t-type n) is a type-level definition and is erased by design, while every
; other refused head is a skip.  That one-arm discrimination is the whole of
; what distinguishes ft-erased from ft-skipped, and SkHead already carries it.
(data PeelR () (pk-ok (d NDef)) (pk-erased) (pk-skip (why SkRoot)))
(declare peel-def (-> (List (Pair Str (List I64)))
                      (List (Pair Str (List NTalTy)))
                      Str Term Term PeelR))

; the two peel helpers, which answer (none) today and name nothing.
; compile-front.chiral:58-78 and :102-147.  Both stay in the kernel image, so
; they see the Term and hand out the code.
(data NtR  () (nt-ok  (t NTalTy))          (nt-no  (head SkHead)))
(data NtLR () (ntl-ok (ts (List NTalTy)))  (ntl-no (ix I64) (head SkHead)))
(data NcR  () (ncr-ok (e NCore))           (ncr-no (head SkHead)))
(declare term->ntalty      (-> Term NtR))
(declare term->ntalty-list (-> (List Term) NtLR))
(declare term->ncore       (-> (List (Pair Str (List I64))) Term NcR))

; peel-globals returns the records beside the defs.  compile-front.chiral:226-233.
(declare peel-globals (-> (List (Pair Str (List I64)))
                          (List (Pair Str (List NTalTy)))
                          (List (Pair Str (Pair Term Term)))
                          (Pair (List NDef) (List FateRec))))

; R2 at the term level.  lower.chiral:125-131 declares SEVEN result sums and six
; of them carry the same (reason Str); all seven move together, because the
; propagation arms (:259, :270-272, :287, :306, :316, :341-344, :349, :354-356,
; :367, :375, :419) pass the payload through unchanged.
(data ExprR () (er-ok (reg I64) (ty TalTy) (instrs (List Instr)) (st St)) (er-skip (site SkLow)))
(data TailR () (tr-ok (block Block) (st St))                              (tr-skip (site SkLow)))
(data EA    () (ea-ok (srcs (List I64)) (instrs (List Instr)) (st St))    (ea-skip (site SkLow)))
(data TB    () (tb-ok (branches (List Branch)) (st St))                   (tb-skip (site SkLow)))
(data TD    () (td-ok (dflt (Maybe Block)) (st St))                       (td-skip (site SkLow)))
(data BO    () (bo-ok (fn TFn) (extra (List TFn)) (fns (List (Pair Str TalSig)))) (bo-skip (site SkLow)))
(data LowE  () (le-ok (main TFn) (extra (List TFn)))                      (le-skip (site SkLow)))
(declare compile-fn (-> CEnv Str LCore (List TalTy) (List I64) TalTy LowE))

; M-B.  The owner relation: an emitted label back to the definition that made it.
; lower-defs holds (cons main extra) per def at compile-back.chiral:272 and is
; the only place that knows; filter-erasable (:184) and prune-pass (:204) run at
; :255-256 over a FLAT accumulator that has lost it.
(declare filter-erasable (-> (List DData) (List TFn) (List (Pair Str Str))
                             (Pair (List TFn) (List FateRec))))
(declare prune-pass      (-> (List Str) (List TFn) (List (Pair Str Str)) (List FateRec)
                             (Pair (List TFn) (List FateRec))))
(declare prune-fix       (-> (List Str) (List TFn) (List (Pair Str Str))
                             (Pair (List TFn) (List FateRec))))

; the back half's carrier.  compile-back.chiral:126, :252, :332.
(data BR () (br-ok (fns (List NFn)) (lits (List Str)) (fates (List FateRec)))
            (br-err (msg Str)))
(declare lower-defs   (-> (List Str) (List (Pair Str TalSig)) (List (Pair Str TalSig))
                          (List DData) (List NDef) (List TFn) (List FateRec)
                          (List (Pair Str Str)) BR))
(declare back-program (-> (List NDef) (List NData) (List NPrim) (List FateRec) BR))

; the front half's carrier.  compile-front.chiral:319-321 and :344-353.
(data FR () (fr-ok (defs (List NDef)) (datas (List NData)) (prims (List NPrim))
                   (ports (Maybe (List Str))) (fates (List FateRec)))
            (fr-err (msg Str)))

; R6.  The relation is produced BY the pass that performs the renaming.
; specialize-singleton.chiral:229-232 returns a bare Sig today.  sp-lifted names
; what lift-lifted created (:195); sp-dropped names what drop-pruned deleted
; (:228) beside the targets sp-rw redirected its callers to (:124-132).
(data SpRel () (sp-lifted  (from Str) (into (List Str)))
               (sp-dropped (name Str) (into (List Str))))
(data SpOut () (sp-out (sig Sig) (rel (List SpRel))))
(declare specialize-singletons (-> Sig SpOut))

; R4.  compile-all.chiral:34-35 discards the record on the elf-ok arm today.
(data CAllR () (ca-ok  (elf Bytes) (fates (List FateRec)))
               (ca-err (msg Str)   (fates (List FateRec))))
(declare compile-all (=> Str Str CAllR))

; ---- (x) R7, conservation, checked inside the compile --------------------------
; Three failures and they are different failures, so they are three arms.
; `domain` is the definition-name list the domain decision (§6 decision 1) fixes;
; `emitted` is the label list the artifact actually carries.
(data ConsR () (cs-ok)
               (cs-unfated   (def-name Str))    ; a definition with no fate
               (cs-twice     (def-name Str))    ; a definition with two
               (cs-unclaimed (label Str)))      ; an emitted label no fate names
(declare conserve (-> (List Str) (List FateRec) (List Str) ConsR))

; the seat is compile-all, the one module that sees the whole closure and the
; whole artifact.  A cs-ok is the only value that reaches ca-ok.
(declare fold-labels (-> (List FateRec) (List Str)))
```

- **Knobs to modify.**
  - **`SkHead`'s width.** Sixteen arms mirror `Term` head for head and make the
    peel channel total by construction. Three arms (`sh-type`, `sh-primty`,
    `sh-tcon`) cover every refusal either channel can produce today and every one
    of the 153 measured extern refusals, which are all `(t-primty "Pty")`. §6
    decision 2 prices the trade.
  - **Where the peel refusal is computed.** The snippet retypes `term->ntalty`,
    `term->ntalty-list` and `term->ncore` as result sums, which is E157's move and
    reaches three other callers (`prim->n` at `compile-front.chiral:326-333`,
    `field-tys->n` at `:238-245`, `tnc-keep` at `:136-143`). A second walk that
    re-derives the head only on the refusal path leaves those three alone and
    computes the type twice. §6 decision 3.
  - **`sl-short-chain`'s `have` field.** `compile-fn` knows `want` as `total`
    (`lower.chiral:414`) and does not know `have`, because `strip-lams` answers
    `(none)` without reporting the depth it reached. Carrying `have` means
    `strip-lams` returns a count on the refusal arm, which is a two-line change in
    the same file and is the field E188's whole subject turns on. Dropping the
    field costs nothing structural.
  - **`sl-case-nondata`'s evidence.** `expr-case` holds the refused `sty`
    (`lower.chiral:307`) and cannot put it in the sum, by finding 5. Carrying it
    as an `NTalTy` needs a `TalTy -> NTalTy` direction, and only
    `ntalty->talty` exists (`compile-back.chiral:24-32`). §6 decision 6.
  - **`skr-erase`'s evidence.** `filter-erasable`'s silent arm discards `m` from
    `(xf-err m)`, and `XF`'s `reason` is a `Str` (`lowering/tal/erase.chiral:30`).
    Widening it is a sixth sum in a tenth module. §6 decision 5.
  - **The owner relation's carrier.** `(List (Pair Str Str))` threaded into
    `filter-erasable` and `prune-pass`, a sixth field on `TFn`
    (`tal/ssa.chiral:40`, which `ck-prog` and `tal-eval` also read), or the
    `<def>$<ncase>` string convention read back. §6 decision 4.

- **Deliberately omitted.**
  - **The report exit.** R7 owes `bin/chirality` a subcommand beside compile /
    run / check / test (`bin/chirality:9-12`), and the gate that reads it is a
    chirality program on E168's floor. Both are §6 cost items and neither is a
    type question.
  - **Any change to `format-blame`'s output bytes.** E187's R5 gated exactly that
    and the gate stands. The rendering functions move to the new accessors and the
    strings they produce are the SPEC's to pin.
  - **The extern region.** `prim->n` refuses 153 of 4,902 extern signatures, all
    `(t-primty "Pty")`, and [[decisions/decision-def-partition]] §3 keeps that
    region E107's. `PeelR` covers definitions and `prim->n` keeps its `Maybe`.
  - **The census that pins the counts.** F3 measures that nothing in the tree
    re-derives a def-level number, and `enforcement/N14` is scoped to fix it
    first. §5 spells the type; the instrument is the other row's.
  - **The 84 dead lines.** `lower.chiral:22-105` is retired inside this element's
    build cycle by [[decisions/decision-def-partition]] §5, and the retirement is
    a deletion rather than a design question.

## 6. Use / modify notes

- **Lands in:** `lib/lowering/skip-diag.chiral` for every sum and accessor, which
  is [[decisions/decision-def-partition]] §4's ruling and needs no reopening. The
  signature changes land in eight further files, all inside the compiler's blob.

  | file | what moves |
  |---|---|
  | `lib/lowering/skip-diag.chiral` | six sums, `FateRec`, fifteen accessors, `blame-chain` and `format-blame` rewritten onto them |
  | `lib/lowering/compile-front.chiral` | `NtR`/`NtLR`/`NcR`, `peel-def`, `peel-globals`, `FR`, `bridge-sig` |
  | `lib/lowering/compile-back.chiral` | seven result-sum reads, `filter-erasable`, `prune-pass`, `prune-fix`, `lower-defs`, `BR`, `back-program` |
  | `lib/lowering/upper/lower.chiral` | seven result sums, nineteen skip sites, `compile-fn`, and the 84 dead lines deleted |
  | `lib/lowering/upper/specialize-singleton.chiral` | `SpRel`, `SpOut`, `specialize-singletons` |
  | `lib/lowering/compile-all.chiral` | `CAllR`, the conservation seat, both arms |
  | `lib/lowering/upper/closconv.chiral` | `st-pois-defunc` builds `DefWhy` at `:723` and `:726` |
  | `lib/lowering/upper/closconv-driver.chiral` | `CCOut`'s `dsk` field type at `:145` |
  | `lib/typing/diag.chiral` | `r-skipped`'s payload at `:135`, and `dg-chain-doc` reads `skwhy-tag`/`skwhy-name` at `:749-751` |

  Outside the blob: `bin/chirality` gains the report exit, `tools/test/samples/e158_doc.prog:154`
  constructs `(mk-skrec "lowerme" (sk-callee "callee"))` and moves with the
  spelling, and the gate is a new chirality program on E168's floor.

  All nine `lib/` files are compiler source, so the full BUILD RULE applies:
  `build-new → test → promote` with the fixpoint verified and the Step-0
  precondition checked first. **The change does not touch what the code generator
  emits for a successfully lowered definition**, so the first agreement is
  expected at `C1 == C2`; [[definitions/working-discipline]] caps it at
  `C2 == C3` and the run stops after `C4`.

- **Cost, and the catalog's estimate is left standing beside it.**
  `docs/elements/catalog.md:500` prices this at *"roughly 150 to 250 LOC across
  five modules, three signature changes"*. That estimate is the prediction it was
  and stays as written. Measured against the spelling above on 2026-09-09: **nine
  blob modules**, and eleven signature or data changes rather than three
  (`peel-def`, `term->ntalty`, `term->ntalty-list`, `term->ncore`, `peel-globals`,
  seven result sums in `lower.chiral` counted as one, `filter-erasable`,
  `prune-pass`, `prune-fix`, `lower-defs`, `back-program`, `specialize-singletons`,
  `compile-all`). The sums alone are about 70 lines and their accessors about 45,
  before any producer moves. **This run's own estimate is 380 to 520 LOC**, and
  the prediction-against-outcome delta is calibration data the SPEC stage should
  record rather than overwrite.

- **Conformance target.** Five rows, and the first is the one that makes the
  element falsifiable.

  1. **The `extern` tag count falls from 187 to 5.** PRB-81's observable, measured
     over the same 63 roots: 182 records move from `skr-extern` onto `skr-body`,
     and `sklow-tag` splits those 182 into `ho-app` 162, `lam-value` 10 and
     `short-chain` 10. Any other distribution refutes the spelling.
  2. **`conserve` answers `cs-ok` on all 63 roots**, and a fixture that removes a
     fate, duplicates one, or emits an unclaimed label reddens exactly one arm
     each.
  3. **`tools/test/opt-census.sh` still reads `defs=1519` and `skipped=10`**, and
     the fate report agrees with it on both, while additionally accounting for the
     40 outlined extras and the 2 cascade drops that the census does not see.
  4. **Every emitted ELF is byte-identical.** Nothing in the emission path moves,
     so a root that compiles today compiles to the same bytes.
  5. **`format-blame`'s output stays byte-identical on every program this tree
     compiles**, which is E187's R5 gate, unchanged.

- **The judgment this pre-run owes, and it mints nothing.** E184 as minted covers
  every clause of [[decisions/decision-def-partition]], which that document
  settles as identity rather than overlap, so **no split is recommended and no
  element is minted here**. R6 was flagged at mint as a candidate for its own
  element, and M-D is the reason to keep it inside E184. The fork R6 names is a
  fork about the **domain of the fate function**, and the domain is R1's.
  Splitting it would put R1 in one element and its domain in another.

- **Numbered decisions. None of them is ruled here.**

  1. **The domain of the fate function.** M-D measures `specialize-singletons`
     creating 13 definitions on `prog/compiler.prog` that the pre-pass set does
     not contain, and keeping a singleton global that still carries a fate of its
     own. Three options.
     **(i) The pre-pass set alone**, [[decisions/decision-def-partition]] §1's
     stated choice. Cheapest domain, and R7's fold has to reach a created name
     through its parent's `ft-specialized`, so `x64$0`'s emission is claimed
     transitively and conservation becomes a tree walk rather than a set compare.
     **(ii) The pre-pass set plus what the pass created**, with a fifth arm
     `ft-created (by Str)` for a name that has no pre-pass existence. R7 stays a
     flat set compare, at the cost of one arm and a domain the compiler has to
     compute in two stages.
     **(iii) The post-pass set**, with `SpRel` carried beside as a relation over a
     domain the fate function does not range on. R7 is a flat compare and the
     before-and-after question moves out of the sum entirely, at the cost that
     `x64` and `mach-galo` have no fate when the pass deleted them.
     The measurement favours (ii) on honesty, because it is the only one where
     every name in the artifact is in the domain, and (i) on cost. **Author.**

     ⚑ **PRICED 2026-09-09 BY [[records/findings]] FD-21, AND THE OPTION SET IS
     TWO.** Six systems read at their own sources, ten pins. **(i) has no
     occupant**: not one of them carries a single total function from a pre-pass
     definition set into one closed sum, and every one is two-level with the
     created definition holding its own identity plus a typed field naming its
     origin. **(ii) is DWARF's shape**, and the `ft-created` arm is published: a
     concrete instance tree may hold entries with no counterpart in the abstract
     instance tree, and those entries carry no `DW_AT_abstract_origin` and hold
     all their own attributes (DWARF5:6148-6154). **(iii) is the shape of the one
     system that ships R1's total closed sum**, LLVM over the post-pass set
     (LLVMDBGUP:166-194). The discriminator FD-21 measures is whether the
     consumer has to name a source entity the artifact no longer contains; three
     of R1's four arms (`specialized-into`, `erased-by-design`, `skipped`) name
     definitions with no emitted artifact entity at all. Applying that
     discriminator to this tree is the author's act and this run does not take
     it. The sentence above favouring (i) on cost has lost its subject.

     ⚑ **A SUB-QUESTION OPENS INSIDE THE DOMAIN CALL.** DWARF splits creators by
     mechanism and gives each one its own construct: an inlined instance reusing
     the origin field, an out-of-line instance reusing it under a different tag
     and owner (DWARF5:6188-6214), and a trampoline carrying its own attribute
     naming the target subroutine (DWARF5:6270-6280). `outline` extracts one case
     from one definition and so has exactly one origin, which is DWARF's
     out-of-line-instance construct; LLVM's machine outliner merges N candidate
     sites into one function, sets no origin field, and discards the body's
     attribution (LLVMOUTLINER:950, :1002-1020). So whether
     `specialize-singletons`' creations and `outline`'s creations take one arm or
     two travels with the domain, and FD-21 records that nothing surveyed decides
     whether a definition that survives a pass and is also the origin of a created
     one takes one arm or two. **Author.**
  2. **`SkHead`'s width.** Sixteen arms mirroring `Term` make the peel channel
     total and put a second copy of `Term`'s shape in the lower image, which is
     the *say it once* tension [[protocol/tone]] names. Three arms
     (`sh-type`, `sh-primty`, `sh-tcon`) cover every refusal measured and every
     refusal either helper can produce, and a fourth head becoming refusable later
     is then a silent gap rather than a compile error. **Author.**
  3. **Result sums or a second walk.** Retyping `term->ntalty`,
     `term->ntalty-list` and `term->ncore` is E157's own move and reaches
     `prim->n`, `field-tys->n` and `tnc-keep`. A `ntalty-refusal : (-> Term SkHead)`
     called only on the refusal path leaves those three alone and walks the type
     twice. The second option is cheaper and puts the producer and the classifier
     in two functions that can disagree, which is the drift E157 removed.
     **Author.**
  4. **How an emitted label reaches its definition.** M-B. A threaded
     `(List (Pair Str Str))` costs two parameters and no other reader. A sixth
     field on `TFn` (`tal/ssa.chiral:40`) is read by `ck-prog`, `tal-eval`,
     `erase-fn` and `fold`, so it is the widest change in the tree. Reading the
     `<def>$<ncase>` convention back off the string costs nothing and is a `Str`
     encoding a relation, which R2 forbids one level up. **Author.**
  5. **Whether `skr-erase` carries evidence.** `filter-erasable`'s silent arm
     discards `m` from `(xf-err m)` and `XF`'s reason is a `Str`
     (`tal/erase.chiral:30`). The arm has fired zero times on `prog/compiler.prog`
     (M5, `1549 - 1547 = 2`, both cascade). Widening `XF` adds a tenth module for
     a class with no measured member. **Author.**
  6. **Whether `sl-case-nondata` carries the refused type.** Finding 5 forbids the
     `TalTy`; carrying an `NTalTy` needs the missing direction of
     `ntalty->talty`. The site has produced zero records. **Author.**
  7. **Whether `ft-erased` keeps its arm given M-C.** R1 calls it *"required
     rather than optional"* and argues that without it every ratio is noise. M-C
     measures its extension empty for a structural reason and both its named
     producers wrong. The arm is still the only thing that distinguishes a
     type-level definition from a failed lowering the day one appears, and `PeelR`
     already carries the discrimination through `sh-type`. Keeping an arm with no
     producer is a claim the compiler cannot check. **Author.**

- **Open questions the SPEC stage decides without the author.**
  1. The strings `skroot-tag`, `sklow-tag` and `skhead-tag` return, and which of
     them `format-blame` renders, given that E187's R5 pins the current output
     byte-for-byte.
  2. Whether `conserve` runs on every compile or behind the report exit. R7 says
     inside the compile, and the cost is a fold over 22,742 records on every
     build.
  3. The order in which the nine modules land, so that each commit compiles. The
     sums come first and the producers follow, because a producer cannot construct
     a sum that does not exist yet.

- **Citation corrections this run produces**, each read at `309994c` and each
  small enough to fix in place rather than to schedule.

  | citation | says | reads |
  |---|---|---|
  | E184 R3, in catalog, ledger and arc | `compile-front.chiral:203-210` | `peel-def` is `:211-223` |
  | E184 R4, in catalog, ledger and arc | `compile-all.chiral:34-38` | the `elf-ok` arm is `:35`, the `elf-err` arm `:42-44` |
  | E184 R5, in catalog, ledger and arc | record built at `compile-back.chiral:210` | built at `:211`, in `prune-pass` `:204-211` |
  | [[decisions/decision-def-partition]] §1 | `peel-def` `:212-224` | `:211-223`, and the `(declare)` is `:211` |

- **Related:** [[decisions/decision-def-partition]] · [[records/enforcement-arc]] ·
  [[arcs/enforcement-arc]] · [[records/lenses/problems]] ·
  [[definitions/pattern-boundary-sums]] · [[definitions/working-discipline]] ·
  [[banks/erasure]] · [[banks/verification]] · [[status-ledger]] ·
  [[E97]] · [[E107]] · [[E157]] · [[E168]] · [[E185]] · [[E187]] · [[E188]]
