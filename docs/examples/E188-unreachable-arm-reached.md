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
   `alloc-growing` lower.

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

**What chirality makes impossible here.** It makes throwing impossible, which is
what produced the defect. It also makes the honest repair cheap and composable,
which is what closes it: the refusal is a **value**, it travels in a sum, and the
consumer already exists. `keep-fams` (`closconv-driver.chiral:96-106`) takes a
poison list threaded through `CState`'s `pois` field (`closconv.chiral:618`) and
removes the family wholesale; `st-add-pois` (`:676`) is how a site joins it. The
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
; Correct for every cs-g site, because a family's arity d always satisfies
; d = arity - k: the site's recorded arrow is the global's REMAINING type, so
; `peel-pi-doms` of it counts exactly the arguments the dispatcher supplies.
; The spine is therefore saturated at the global's full arity by construction.

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

; the replacement arm.  `arity` comes from `arity sig g` (:490-494), which reads the
; TYPE alone and never the body, so this path is total wherever the global has a
; declared type.
;   ((none) (spine-body g (+ k d) fields k m d))
```

```chirality
; ---------------------------------------------------------- the refusal channel
; What (c) and (d) both need, and what (a) still needs for the residue:
; arm-body stops being total in Core and answers in a sum instead.  The
; consumers are build-arms (:1117) -> apply-body (:1124) -> synth.
(def arm-body (-> SigV Csite I64 I64 (List ApplyEnt) (Maybe Core)) ; …
  ; …
  )

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
| **(a)** | build the call spine from the `Csite` | one new helper (~15 L), reuse of `cspine` with its `declare` hoisted one place, and the erased-position placeholder inherited from `g-subst-go`. Touches `arm-body` alone. | **recommended.** Correct without reading the body at all, and EN-20 already measured the thing it reproduces: `direct box-f: 30`. The spine *is* the direct call. |
| **(b)** | eta-expand a shallow body before peeling | a de Bruijn shift of the body under the added binders. `remap`/`rm` shift a threshold (`closconv.chiral:14`, `:144`) and `free-indices` exists (`:108`, used at `:1015`), so it is buildable, and it runs inside the pass that is already miscompiling. Changes `def-ctx`'s output for every shallow site. | **rejected.** Eta-expanding `(lam (m) (case m …))` to depth 4 produces the spine `((case m …) a b c)`. It computes candidate (a) the long way, through the body, at strictly higher risk and cost. |
| **(c)** | poison the family through `keep-fams` | `collect` must consult `def-ctx`, which it does not today; the `SigV` it holds makes that reachable. `SkReason` needs a third constructor or the blame is unnameable. Converts wrong code into a missing function. | **keep as the backstop, reject as the primary.** A named skip beats a wrong value and loses to correct code. It is the right answer for any residue (a) cannot construct, such as a global with no declared type. |
| **(d)** | refuse: make the arm a refusal rather than a value | `arm-body : … (Maybe Core)`, propagated through `build-arms`, `apply-body`, `synth`. The refusal then has to *become* something, and the only thing in the tree that consumes it is the poison list. | **it is (c)'s local half, and it is right.** (d) states the impossibility; (c) is the mechanism that carries it. Adopting (d) without (c) leaves the compile with a `none` and nowhere to put it. |

**The recommendation, in one line.** Take **(a)** as the code answer and
**(d)+(c)** as the honesty answer underneath it, so that the arm is correct where
it can be constructed and refuses where it cannot, and no path returns a value it
cannot justify. What the SPEC stage must decide beyond that is the minimal-vs-
uniform knob: whether (a) replaces the `none` arm alone or the whole `cs-g` case.

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
  - Minimal or uniform: does (a) replace the `none` arm alone, or the whole
    `cs-g` case? Uniform retires a code path and changes emitted code for eleven
    currently-correct sites, so it needs the fixpoint to be the arbiter.
  - The erased-position placeholder. `g-subst-go` maps an erased captured param
    to `(+ m d)`, the closure's own index. Candidate (a) inherits it. Whether
    that convention is *sound* or merely *unobserved* is unmeasured by this run
    and the SPEC should settle it against [[banks/erasure]] shard A.
  - Does `collect` reach `def-ctx` cheaply? It holds the `SigV`, so the data is
    there; whether the traversal order permits it is unread.
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
