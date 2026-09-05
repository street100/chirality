---
element: E188
slug: unreachable-arm-reached
title: **`arm-body`'s unreachable arm is reached, and an `$apply` arm returns a literal `0` as a whole function body**
kind: BUILD-PROPER
example: examples/E188-unreachable-arm-reached.md
status: audited
updated: 2026-09-04
---

# E188 SPEC — **`arm-body`'s unreachable arm is reached, and an `$apply` arm returns a literal `0` as a whole function body**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

**Reproduced at HEAD `a47a38d`, 2026-09-04**, against `bin/chirality-bin`
1,192,312 bytes, sha256 `fbcd2aeffbaba86e…`, the B3 EN-18 promoted. Two fixtures
were built outside `lib/` and `prog/`, compiled and run by that binary, and
deleted. A third measurement is a mechanical census over the tree. All three are
§3's evidence and none of them is derived.

## 1. Deliverable

- **After this runs:** an `$apply` arm for a defunctionalization site whose
  `def-ctx` fails is the **call spine** `(g cap0..cap_{k-1} a0..a_{d-1})` rather
  than `(c-lit-i 0)`, and a `cs-g` site whose recorded family arity does not
  equal the global's own declared arity is **refused at `collect`** through the
  existing poison channel instead of being built. EN-20's fixture, which today
  prints `direct: 30` and `apply : 0`, prints `30` on both lines.
- **Non-goals.** `def-ctx` is not changed (candidate (b) is rejected in §3.2).
  The `cs-lam` arm is not touched. `arm-body`'s type does not change: no
  `(Maybe Core)` crosses `build-arms` / `apply-body` / `synth-apply` (§3.3 gives
  the reason, and it is a measurement rather than a preference). The codomain is
  not erased, which [[banks/erasure]] shard F and the catalog row both rule out
  in advance. The blast-radius census of which TFn calls which dispatcher stays
  unbuilt and unassigned (§6).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none. E188 postdates the map snapshot, so the row
  is BUILD by default and every claim below is read from the live tree.
- **Live code this composes with, all of it built.**
  - `arm-body` (`lib/lowering/upper/closconv.chiral:1051-1058`), the `cs-g` case
    with its two arms. The `(none)` arm at `:1057` is the defect.
  - `def-ctx` (`:582-596`) and `peel-lam-exact` (`:565-572`), the predicate that
    fails.
  - `arity` (`:490-494`), `(cc-llen (peel-pi-doms (sv-type s g)))` wrapped in a
    `Maybe`. This is the second number the guard needs.
  - `peel-pi-doms` (`:304-309`), which stops at the first non-`Pi`. This is why
    the invariant is not construction.
  - The three `cs-g` site builders: `cwalk-app-head` (`:816-836`), `fv-own`
    (`:844-850`), `fv-site` (`:852-862`). All three take `sig` first.
  - The poison channel, built and running: `CState`'s `pois` field (`:618`),
    `st-add-site` (`:670-672`), `st-add-pois` (`:676-678`), `keep-fams`
    (`lib/lowering/upper/closconv-driver.chiral:96-106`), reached from
    `closconv-sig` (`:277-289`, the `keep-fams` call at `:282`).
  - `cspine` (`lib/lowering/upper/closconv.chiral:1206-1208`), the left fold that
    builds an application spine. Its `(declare)` sits below `arm-body`.
  - `g-subst-go` (`lib/lowering/upper/closconv.chiral:961-977`), which already
    states the arm's index layout.
  - `SkReason` (`lib/lowering/skip-diag.chiral:11`), two constructors, consumed
    by `SkRec` (`lib/lowering/compile-back.chiral:238-239`) and `format-blame`
    (`lib/lowering/compile-all.chiral:38`).
  - The refusal precedent this element argues from: `compile-fn`
    (`lib/lowering/upper/lower.chiral:412-420`), whose `:417` arm answers the
    same predicate with `(le-skip "body is not a lambda chain")`.
- **True delta.** One new helper (`spine-args`) and one new site-builder helper
  (`st-add-gsite`) in `closconv.chiral`; one `cspine` `(declare)` hoisted; one
  `SkReason` constructor; three call sites rewritten to route through
  `st-add-gsite`; one arm replaced. Plus the gate: one probe, two fixtures, one
  script. Nothing else moves.

## 3. Decisions

Every open question from the example §6, dispositioned. Three of them are
answered by measurements this run performed; those measurements are stated in
full, because the example's §5 ground for the recommendation was **false** and a
disposition that only asserted a replacement would repeat the defect.

### 3.0 The three measurements

**M-A. The census. `d = arity − k` holds at every `cs-g` site in `lib/` and
`prog/` today, and nothing enforces it.** A scoped s-expression walk over all
`.chiral` and `.prog` sources under `lib/` and `prog/` collected every top-level
`def` / `declare` type and every `data` constructor's field types, then found
every application whose callee is a known global or constructor, whose argument
at position *i* is a **bare global**, and whose *i*-th domain is an arrow — which
is exactly `scan-fvargs`' condition for reaching `fv-site` / `fv-own`
(`closconv.chiral:863-872`). **66 such sites, 0 mismatches**: the slot's
`peel-pi-doms` depth equals the global's own arity at every one. The two sites
this element exists for are in the list and both match:
`alloc-growing.chiral`'s `(alloc mach-galo …)` at slot depth 4 against
`arity mach-galo` 4, and `mach-gbnw` at 3 against 3. So the family arity `d`
that `synth-apply` (`lib/lowering/upper/closconv-driver.chiral:201-208`) passes
as `(cc-llen doms)` over `(peel-pi-doms key)` does equal
`arity − k` at every live site, and the pass establishes that nowhere.

⚑ **The walk's SCOPE is corrected by the SPEC audit 2026-09-04, and the
invariant claim is reproduced under a second instrument.** Two statements in the
paragraph above describe a mechanism the pass does not have. Neither moves the
verdict, and both narrow what the census is evidence for.

- The condition stated is not `scan-fvargs`' condition for reaching `fv-site` /
  `fv-own`. `scan-fvargs` (`closconv.chiral:863-872`) calls `fv-site` on EVERY
  argument of every application, and `fv-site` falls through to `fv-own`
  whenever the slot is absent or is not an arrow. What the condition describes
  is `fv-site`'s ARROW branch (`:858`), the one `cs-g` shape whose recorded `d`
  can disagree with `arity sig g`. Every other path keys the site by the
  global's OWN type at `k = 0` (`fv-own`, `:848`), where `d = arity` holds by
  construction and a mismatch is unreachable.
- A constructor application is a `c-con`, and `cwalk-struct`'s `c-con` arm
  (`:791`) hands `scan-fvargs` `cdoms = none`. A constructor's field type is
  therefore never a slot, and every bare global inside a `c-con` reaches
  `fv-own`. That covers **the two sites this element exists for**: `alloc` is a
  constructor of `Alloc` (`lib/memory/alloc.chiral`), so
  `lib/memory/alloc-growing.chiral:19-20` keys `mach-galo` and `mach-gbnw` by
  their own types rather than by `alloc`'s field slots. The two depths coincide
  with the field types for the reason `alloc-growing.chiral:15-17` states in its
  own comment, that the curried types match the field types exactly.

**Reproduced.** A second scoped walk, written independently and run three times
at widening scope (def-telescope param types; then `arm-ctx`'s ctor field types
for `case` binders and a `ty-of` for `let`; then `cwalk-descend`'s lam-literal
params), reads the same tree at **68 occurrences, 63 distinct
`(family key, g, k)` sites, 0 mismatches**, with `mach-galo` 4 against 4 and
`mach-gbnw` 3 against 3. The count is instrument-dependent and the verdict is
not. Of the 68, 32 are ctor-headed and reach `fv-own`, so the evidence bearing
on this element is **36 occurrences, 31 distinct sites**. Widening the walk to
heads that are local binders of known arrow type added no site at all, and the
7,724 applications whose head type neither walk could resolve cannot hide one:
an unresolved head is `callee-doms` answering `none`, which is `fv-own` again.

**M-B. The invariant is constructible-false, and today the failure is a REFUSAL
rather than a second wrong value.** Fixture, outside `lib/` and `prog/`:

```chirality
(def e188-plus (-> I64 I64 I64) (lam (x y) (+ x y)))
(def e188-ap1 (-> (0 A (type 0)) (0 B (type 0)) (-> A B) A B) (lam (A B f x) (f x)))
(def e188-drive (-> (-> I64 I64) I64 I64) (lam (g y) (g y)))
;   (e188-drive (e188-ap1 I64 (-> I64 I64) e188-plus 100) 5)
```

`e188-ap1`'s function slot is `(-> A B)`; `peel-pi-doms` stops at the type
variable `B`, so the slot peels **one** domain whatever `B` is instantiated to.
`e188-plus` fills it with `B := (-> I64 I64)`, so the site records `d = 1`
against `arity e188-plus = 2`. `def-ctx` succeeds here — the body IS two `lam`s
deep — so the **existing `some` path** runs `g-subst` with `n = 2`, `k = 0`,
`m = 0`, `d = 1`, and its supplied-param index `(- (- (+ m d) 1) (- p k))` is
`-1` at `p = 1`. Today's binary answers:

```
no emitted label for entry compile-main | skip chain for compile-main
  <- e188-ap1 <- $apply0: extern does not lower: unbound var
```

**The negative index can never alias a live binder.** `env-get`
(`lib/lowering/upper/lower.chiral:198`) indexes `(- (- (l-llen env) 1) ix)`, so
`ix < 0` always exceeds the environment and `lnth` always answers `none`. The
failure mode is therefore structurally a named skip, not a silent wrong value.

⚑ **Checked one level down by the SPEC audit 2026-09-04, because the
composition is what carries the claim.** `lnth` (`lower.chiral:154`) tests
`(<=i i 0)`, so `lnth` itself CLAMPS a negative index to the list head. The
safety rests on the COMPOSED index being `>= len`, not on `ix` being negative:
at `ix = -1` the composed index is `len`, `lnth` walks off the end, and
`lower.chiral:239` turns the `none` into `er-skip "unbound var"`, the message
measured above. The mirror case, `ix > len - 1`, drives `lnth`'s own index
negative and WOULD alias the environment's first entry. M-C is what rules that
one out, because `d <= arity − k` puts every index error this pass can produce
in the negative direction. So the no-aliasing claim holds, and it holds on M-C
rather than on `env-get` read alone.
**So the `fv-site` break is not a second miscompile and E188's scope does not
grow to one.** What it is, is a compile refused with an internal name
(`$apply0`) and a reason (`unbound var`) that describe the pass rather than the
program. E188 converts that into a source-level skip.

**M-C. The direction is one-way: `d ≤ arity − k` always.** `peel-pi-doms` stops
at the first non-`Pi`, and instantiating a slot's type variables can only make
the real type peel **deeper** than the slot, never shallower. `cwalk-app-head`
keys by `(ty-of ctx t)` = `peel-n-pi k (sv-type g)`, which peels exactly
`arity − k`; `fv-own` keys by `(sv-type g)` itself at `k = 0`. So `d > arity − k`
is unreachable and only the `fv-site` path can produce `d < arity − k`. The
guard is therefore one inequality at one place, not a general audit.

**Control, and it reproduces EN-20 verbatim.** The `box-f` fixture — `E188Box`
holding a `(-> I64 I64 I64)`, `e188-boxf` with three domains after peeling and
one `lam` in the body, ground codomain `I64` — compiled and run by the same
binary prints `direct: 30`, `apply : 0`, `sib   : -10`.

### 3.1 The decision table

| # | Question | Disposition | Rationale |
|---|---|---|---|
| 1 | ⚑ Discharge `d = arity − k`, or carry a refusal for its failure. | **RESOLVED — carry the refusal, at `collect` rather than at `arm-body`.** | M-A shows the invariant true today and unenforced; M-B shows it constructible-false; M-C shows the failure confined to `fv-site` and one-directional. A census that runs once settles nothing, which the example's §6 says in its own words. The guard goes in the code, at the one place where both numbers are already in hand and the refusal channel already exists. |
| 2 | Which reading of `arity` the replacement arm takes: `(+ k d)` from the family, or `arity sig g` from the type. | **RESOLVED — `(+ k d)`, form A, and decision 1 is what makes it right.** | The two forms are the same code wherever `d = arity − k`. Where they differ, form B computes a negative index (M-B) and form A builds a **partial** application of `g`, which `collect` never registered as a site, so `rw` leaves it bare and `lower` refuses it. **Neither form is correct at a mismatch**, which is why the answer is not a choice between them but the guard in decision 1. Once the guard runs at the site builder, every surviving `cs-g` site satisfies `arity = k + d`, and form A is correct **by construction** — the phrase the example's §5 used as an assumption becomes a consequence of the code this element adds. Form A is then also total: it needs no `Maybe`. ⚑ **Both halves checked at source by the SPEC audit 2026-09-04, and the pass ORDER is what keeps the argument off its own tail.** `closconv-sig` (`closconv-driver.chiral:277-289`) runs `collect`, then `keep-fams` at `:282`, then `synth-fams`, and `arm-body` is reached only from `synth-fams`, so the guard runs in a strictly earlier pass on every path into the arm. Form A's counterfactual is real rather than asserted: an unregistered partial application falls through `rw-app-disp`'s `ctor-of-find` to a bare spine (`closconv.chiral:1287-1291`), and `lower` refuses that at `expr-args` with `"partial application"` (`lower.chiral:266`). |
| 3 | Minimal or uniform: does the spine replace the `none` arm alone, or the whole `cs-g` case? | **RESOLVED — minimal at `arm-body`, uniform at the guard.** | The example's own note pushes toward uniform because the `some` path rests on the same invariant. Decision 1 satisfies that: the guard covers **both** arms, because it runs before either. Replacing the `some` path's `def-ctx` inlining with a spine as well would change emitted code at eleven currently-correct sites for no measured defect, and [[banks/verification]] §1 is explicit that the fixpoint would not tell us whether that was right. Leave the `some` path alone. |
| 4 | The erased-position placeholder: `g-subst-go` maps an erased captured param to `(+ m d)`, the closure's own index. Does the spine inherit it? | **RESOLVED — yes, and the reason is that the reference is discarded.** | `g-subst-go`'s own comment (`lib/lowering/upper/closconv.chiral:955-957`) states it: the erased reference sits in a q=0 position and `term->ncore`'s `tnc-keep` (`lib/lowering/compile-front.chiral:104`, `:136-143`) drops the argument before it reaches lowering. [[decisions/decision-erased-word-level]] settles that an erased position has no runtime presence. Inheriting the convention keeps one spelling; inventing a second would be the drift `CLAUDE.md` names. |
| 5 | ⚑ The example's snippet copies `g-subst-go:969`'s `((nil) nil) ; unreachable: fs has k entries` into `spine-args`. | **RESOLVED — do not ship it. `fs` carries the `p < k` test, so the arm it would sit in does not exist.** | `spine-args` walks `p` from `0` to `arity−1` and needs a field only for `p < k`. The fields it gets are the site's own: `(g-param-specs sig g k)` at a `cwalk-app-head` site, `nil` at an `fv-site` / `fv-own` site where `k = 0`. Either way `fs` has exactly `k` entries, so the field list running out IS `p` reaching `k`. §4 Step 2 therefore scrutinises **`fs`** and gives its `nil` arm the SUPPLIED-parameter body: both arms carry real work and neither is an unproven "unreachable". ⚑ **The prose here read "pattern-matches only `cons`, with the `nil` case folded into the `p < k` guard: `(case (<i p k)`", which describes a shape Step 2 does not ship; corrected by the SPEC audit 2026-09-04 to match the code, which is the better of the two.** Reproducing an unproven "unreachable" inside the arm written to remove one is the defect this element exists to close. |
| 6 | Where the poison decision is placed: at the site builder, or in a second pass over the families. | **RESOLVED — at the site builder, through one shared helper.** | All three builders take `sig`, and the key is the value being passed to `st-add-site`, so both numbers are in hand at the point of decision. A second pass would re-derive what the builder knew. One helper called by three builders pushes the invariant into the substrate rather than repeating a check three times, which is the shape [[definitions/pattern-boundary-sums]] and the tree's own directive prefer. |
| 7 | Whether a global with no declared type can reach a `cs-g` site. | **RESOLVED — yes, through `fv-site`, and the guard catches it.** | `fv-site`'s arrow branch (`:858`) calls `st-add-site` without consulting `g`'s type at all; only the `fv-own` fallback reads it. `arity` returns `(Maybe I64)`, so `none` is one of the guard's two refusal cases. After the guard, `arm-body`'s `cs-g` case can assume a declared type. |
| 8 | Whether `arm-body` should answer in `(Maybe Core)` — candidate (d). | **RESOLVED — no, and this overrides the example's recommendation on placement while keeping its judgment.** | The example's §6 chain is right about the cost: five frames and two accumulators (`build-arms` `:1118`, `apply-body` `:1124`, `synth-apply` `closconv-driver.chiral:201`, `synth-applies` `:212`, `synth-fams` `:220`, reached from `:285`), and a `(Maybe Core)` has to cross `core->term` as well. The example's judgment was that (a) needs a refusal channel to be right; decision 1 gives it one that costs nothing, because the poison channel already spans exactly those frames and already ends somewhere. Adding (d) as well would be a **second** channel for one condition. The refusal is kept; only its home moves earlier. |
| 9 | `SkReason` needs a constructor or the blame is unnameable. | **RESOLVED — add `sk-defunc`, carrying the two names the site knows.** | `SkReason` has exactly two constructors (`skip-diag.chiral:11`) and neither says this. The boundary-sums directive says the classification travels as a value carrying the blame the site knows rather than a formatted string, so the constructor takes the global's name and the reason discriminant, not a sentence. `skwhy-name` (`:21`) and `skwhy-tag` (`:24`) each gain an arm. |
| 10 | ⚑ The gate's suite phase number. | **DEFERRED — to the standing author call, `records/author-calls.md:30`.** | The gate declares itself out with `# not-a-phase: <reason>`, the route `crypto.sh`, `tal-check.sh`, `apply-word.sh` and `capture-fields.sh` all take, which keeps `registration.sh` G2 and G4 green. `registration.sh` reads **8 of 21** scripts outside the dispatch table today; E188's gate makes it 9 of 22. ⚑ **The ordinal is corrected by the SPEC audit 2026-09-04, re-measured at HEAD:** eight `not-a-phase:` header declarations across twenty-one `tools/test/*.sh`, four of them waiting on the contested number (`crypto.sh:6`, `tal-check.sh:11`, `apply-word.sh:5`, `capture-fields.sh:6`), the other four out for structural reasons. `records/author-calls.md:30` already reads `display-calculus/C1C2`'s gate as the **fifth** when it exists, and C1C2's script does not exist yet, so whichever of the two lands first takes fifth and the other takes sixth. **This SPEC assigns no number and opens no new call.** A blank reason fails G4, so the declaration's reason is written out in §5. |
| 11 | ⚑ `docs/definitions/bug-classes.md:85` carries `miscompilation` with mechanism *"typed assembly, checked at instruction level"* and state `unwired`. E188 is a measured instance the stated mechanism does not cover. | **DEFERRED — to a `doc-audit` run on `bug-classes.md`.** | The example flagged it as doc-tier residue for a later run, and it is not this element's write surface. Named in §6 so it is not lost. |

**No NEEDS-AUTHOR blocks §4.** Decision 10 is deferred to a call that already
exists and does not gate the build; the gate runs by hand, exactly as
`apply-word.sh` and `capture-fields.sh` do. Frontmatter stays `status: draft`.

### 3.2 Candidate (b), rejected, and the reason is now a measurement

Eta-expanding a body shallower than its type before peeling computes the spine
the long way, through the body, inside the pass that is already miscompiling.
M-B adds a second reason the example did not have: at `d < arity − k` there is
**no** correct depth to eta-expand to, because the family's arity and the
global's arity genuinely disagree. Eta-expansion would have to guess which one
wins, and both answers are wrong (decision 2). Rejected.

### 3.3 What the refusal buys, stated as an observable

Under the guard, M-B's fixture stops being `$apply0: extern does not lower:
unbound var` and becomes a named skip at the source def, reaching `SkRec` and
`format-blame` the way `compile-fn`'s `:417` arm already does. That is the
element's whole argument made concrete: **one condition, three answers in one
compile** — `lower` refuses by name, `collect-defs` (`:922-930`) skips silently,
`arm-body` returns `0` — collapses to one.

⚑ **The refusal is FAMILY-wide, stated by the SPEC audit 2026-09-04.**
`st-add-pois` (`:676-678`) keys the poison by the family key, and `keep-fams`
(`closconv-driver.chiral:96-106`) drops the whole family, so one mismatching
site refuses every site that shares that key, the honest ones with it. That is
the existing channel's granularity and this element adds no new cost to it. M-A
is what bounds the cost: no family anywhere in `lib/` or `prog/` is newly
poisoned, which is also what bounds Step 5's `B1 ≠ B2`.

## 4. Change plan (ordered, commit-sized)

⚑ **Steps 1–5 touch `lib/`, so each owes the BUILD RULE**
([[definitions/working-discipline]]): `build-new → test → promote`, the promoted
binary re-run over the same blob and byte-compared, **a non-empty check before
every `cmp`**, and `(ulimit -s unlimited; …)` on every compiler invocation. A
fixpoint shows stability and says nothing about correctness, so it is a
precondition on landing and never the evidence.

### Step 1 — `SkReason` gains `sk-defunc`
- **Target:** `lib/lowering/skip-diag.chiral` — `SkReason` (`:11`), `skwhy-name`
  (`:21`), `skwhy-tag` (`:24`).
- **Change:** a third constructor `(sk-defunc (name Str) (why Str))`, where
  `name` is the global at the site and `why` is one of two discriminants
  (`"no declared type"`, `"family arity disagrees with the global's"`). Add the
  matching arm to `skwhy-name` and `skwhy-tag`. Both are total `case`s over the
  sum, so a missing arm is a compile refusal rather than a silent gap.
- **Size:** S.

### Step 2 — `spine-args` and the `cspine` hoist
- **Target:** `lib/lowering/upper/closconv.chiral` — a new `spine-args` above
  `arm-body`, and `cspine`'s `(declare)` moved from `:1206` to sit with it.
- **Change:** one argument term per source parameter `p` in `[0, arity)`, in
  source order, using `g-subst-go`'s own index layout verbatim:

```chirality
; one arg per source param p in [0, arity), in source order.  Indices are
; g-subst-go's (:961-977) and nothing here re-derives them:
;   captured, KEPT   (kj-th kept field)  -> (- (- m 1) kj)
;   captured, ERASED (no field)          -> (+ m d), the clo binder; dropped by
;                                           term->ncore's tnc-keep
;   supplied p >= k  (apply arg a_{p-k}) -> (- (- (+ m d) 1) (- p k))
; fs is (g-param-specs sig g k): exactly k entries, so the p<k branch is fed
; while entries remain and the exhausted case is UNREACHABLE BY THE GUARD rather
; than by a comment.  It is therefore not written as an arm.
(declare spine-args (-> I64 I64 (List (Pair I64 Core)) I64 I64 I64 I64 (List Core)))
(def spine-args
  (lam (p kj fs arity k m d)
    (case (<i p arity)
      (false nil)
      (true
        (case fs
          ((cons f rest)
            (case (field-erased? f)
              (true  (cons (c-var (+ m d))
                           (spine-args (+ p 1) kj rest arity k m d)))
              (false (cons (c-var (- (- m 1) kj))
                           (spine-args (+ p 1) (+ kj 1) rest arity k m d)))))
          ((nil)
            (cons (c-var (- (- (+ m d) 1) (- p k)))
                  (spine-args (+ p 1) kj nil arity k m d))))))))
```

  ⚑ The scrutinee is **`fs`**, not `(<i p k)`: the field list running out *is*
  `p` reaching `k`, because `fs` has exactly `k` entries. One test instead of
  two, and the case the example's snippet answered with `((nil) nil)` no longer
  exists to answer.
- **Size:** S (~18 lines plus the hoisted `declare`).

### Step 3 — the guard, at one place, called by three
- **Target:** `lib/lowering/upper/closconv.chiral` — a new `st-add-gsite` beside
  `st-add-site` (`:670-672`), and the three builders that call it for a `cs-g`
  site: `cwalk-app-head` (`:816`), `fv-own` (`:844`), `fv-site` (`:852`).
- **Change:** `st-add-gsite sig st key g k fields` computes
  `d = (cc-llen (peel-pi-doms key))` and consults `(arity sig g)`. On
  `(some ar)` with `(=i ar (+ k d))` it calls `st-add-site` as today; on
  `(some ar)` with a mismatch, or on `(none)`, it calls `st-add-pois st key` and
  records the `sk-defunc` blame. Rewrite the three builders to call it instead
  of `st-add-site` for their `cs-g` sites. `cwalk-app-head`'s existing
  `0 < k < ar` guard stays; the new one subsumes nothing and duplicates nothing,
  because it compares a different pair of numbers.
  ⚑ **The three call sites are enumerated by the SPEC audit 2026-09-04, so the
  rewrite cannot miss one.** `st-add-site` is called four times in
  `closconv.chiral` and exactly three of those calls construct a `cs-g`: line
  830 inside `cwalk-app-head`, its partial-application exit; line 848 inside
  `fv-own`; line 858 inside `fv-site`, its arrow branch. The fourth, line 735,
  builds a `cs-lam` inside `reg-lam` and is out of scope. `fv-own` is reached
  only from `fv-site`, at lines 859 and 860, so the two are one entry with two
  exits and both exits need the guard.
  ⚑ **The blame has to reach `SkRec`.** `CState` carries no diagnostic list
  today. The cheapest honest home is a fourth `CState` field threaded exactly as
  `pois` is (`:618`, `:676`), surfaced by `closconv-sig` alongside `CCOut`'s
  `stated`. If the implementation run finds that channel wider than one commit,
  it lands the poison in Step 3 and the blame in a Step 3b, and the gate's R5
  reads the resulting skip text either way — the refusal is the deliverable and
  the wording is not.
- **Size:** M.

### Step 4 — the arm
- **Target:** `lib/lowering/upper/closconv.chiral` — `arm-body` (`:1051-1058`).
- **Change:** replace `((none) (c-lit-i 0))` with the spine, run through `rw`
  exactly as the `some` path is, so a fn-value global inside it still lowers
  first-order:

```chirality
((none) (rw sig ka (arm-rw-ctx fields) none
            (cspine (c-global g) (spine-args 0 0 fields (+ k d) k m d))))
```

  The `unreachable: g always has a def-ctx` comment is deleted, and the arity is
  `(+ k d)` per decision 2, with a comment naming Step 3's guard as its ground
  rather than an assumption.
- **Size:** S.

### Step 5 — build, fixpoint, promote
- **Target:** `bin/chirality-bin`.
- **Change:** the BUILD RULE, in full. `B1` = today's binary; `B2` = `B1` over
  the new blob; `B3` = `B2` over the same blob; `[ -s ]` before each `cmp`;
  `B2 == B3` is the fixpoint. ⚑ **`B1 ≠ B2` is EXPECTED here** and is not a
  failure: `$apply5`'s `$k5_8` arm and `$apply6`'s `$k6_3` arm stop being
  `const 0; ret` and become call spines, so emitted bytes move. M-A is what
  bounds the move: no family is newly poisoned anywhere in `lib/` or `prog/`, so
  the only emitted-code change is at those two arms.
- **Size:** S (ceremony, no source).

### Step 6 — the two fixtures
- **Target:** `tools/test/samples/e188_apply_spine.prog` and
  `tools/test/samples/e188_slot_break.prog`.
- **Change:** the first is EN-20's `box-f` shape with ground codomain `I64`,
  built and run in §3.0's control: it prints `direct: 30`, `apply : N`,
  `sib   : -10`, where `N` is `0` before the change and `30` after. The second
  is M-B's `e188-ap1` shape: it must NOT emit `compile-main` under either
  binary, and the gate reads its **blame text**. ⚑ **Both live under
  `tools/test/samples/`, not `prog/`**, for `e185_apply_word.prog`'s stated
  reason: Phase 7 discovers roots with `grep -rl '^(def compile-main' lib prog`
  (`tools/test/run-tests.sh:175`), and a fixture under `prog/` would move the
  root census twice.
  ⚑ **The first fixture's supplied arguments must differ under a
  NON-COMMUTATIVE operation** (added by the SPEC audit 2026-09-04). §5's M4 is
  an argument permutation, and a permutation of two equal arguments, or of two
  arguments under `+`, prints `direct`'s own answer and reddens nothing. EN-20's
  `box-f` shape holds a `(-> I64 I64 I64)`, so the constraint costs one operator.
- **Size:** S.

### Step 7 — the probe
- **Target:** `prog/e188-apply-spine.prog`.
- **Change:** E185's probe shape, verbatim in structure: read a blob on stdin,
  call `compile-front`, print one token line under an `==E188==` marker. It
  asserts nothing and always exits `0`; the shell does the comparing. Tokens:
  the family's `$apply<i>` is present in the `NDef` list, and the fixture's
  `use` is present. It imports nothing under `lowering/tal/` (E154's eleven
  collisions). ⚑ **This is a new Phase 7 root and moves the census by one**;
  the absolute figure is read at implementation time, not pinned here.
- **Size:** M.

### Step 8 — the gate
- **Target:** `tools/test/apply-spine.sh`. §5 is its contract.
- **Size:** M.

### Step 9 — the records
- **Target:** `records/enforcement-arc.md` (EN-20 → `FIXED`, plus a new row for
  M-A/M-B/M-C), `docs/elements/catalog.md`, `docs/elements/ledger.md`,
  `docs/examples/INDEX.md`, `docs/arcs/enforcement-arc.md`.
- **Change:** the claim beside its measurement, per
  [[definitions/working-discipline]]. The three homes carrying the *ground* for
  candidate (a) are corrected by **this** run (§6) and not by the implementation.
- **Size:** M.

## 5. Conformance gate

`tools/test/apply-spine.sh`, over `tools/test/samples/e188_apply_spine.prog`,
`tools/test/samples/e188_slot_break.prog` and `prog/e188-apply-spine.prog`.

⚑ **It takes no suite phase number** (decision 10). Its header carries one
declaration line with a non-blank reason, which is what `registration.sh` G4
checks:

```
# not-a-phase: E188's number waits on the standing suite-phase-number call in
#   records/author-calls.md:30 -- four documents disagree about 21-23.
```

⚑ **Six rows, ONE verdict line, and every mutant pins the line in FULL.**
`records/gate-audit.md` GA-21 and GA-22 both convict a gate that names one row
per mutant, because a mutant reddening a row outside its own pin is then
invisible.

| row | asserts | judged by |
|---|---|---|
| **R1** | `direct` prints `30` — the same global called directly | the fixture's stdout |
| **R2** | `via $apply` **agrees with `direct`** — the deliverable | the fixture's stdout |
| **R3** | the honestly-shaped sibling still prints `-10` — the `some` path unchanged | the fixture's stdout |
| **R4** | the family **is built and its `$apply` is called**: `$apply<i>` is in `compile-front`'s `NDef` list and `use` is too | the probe |
| **R5** | the slot-break fixture is refused with a **named** skip at the source def, and the blame does not read `$apply<i>: … unbound var` | the compiler's own diagnostic on that fixture |
| **R6** | the **pre-change** binary prints `0` on the `apply` line of the same fixture, and the promoted one prints `30` | two binaries, one fixture |

**A skipped compile grades `absent`, never `ok`.** If the ELF is empty or a line
does not print, its token is `absent`, the convention `apply-word.sh` already
spells (`:60`, `:275`) and `capture-fields.sh` uses (`:243`). This is
requirement 5's whole point: candidate (c) alone satisfies "the two agree" **by
deleting the second term**, and a row that reads "the two agree" would pass on
absence. It cannot here, because absence is a distinct cell and R4 asserts
presence positively.

⚑ **R5 gates the REFUSAL and it does not reach Step 1. Stated by the SPEC audit
2026-09-04 so the gap is not discovered later as a surprise.** Under the guard
the slot-break fixture's family is poisoned, `keep-fams` drops it, nothing
rewrites the site, and `lower` already answers `er-skip "higher-order
application"` (`lower.chiral:283`) attributed to the source def. That is a named
skip at the source def whose blame does not read `$apply<i>: … unbound var`, so
**R5 goes green on the family drop alone, with or without `sk-defunc`**. §3.3
rules the wording out of the deliverable and Step 3 allows the blame channel to
land as a Step 3b, both of which this is consistent with. The honest consequence
is that Step 1's constructor is falsified by no row in this gate; decision 9
carries it on [[definitions/pattern-boundary-sums]] and on nothing measurable.
Tightening R5 to read the `sk-defunc` tag is available once Step 3b lands and it
is the author's call, recorded in §6.

**R6's baseline binary** comes from git the way `apply-word.sh`'s does:
`E188_BASE_REV` defaults to the last commit before E188's promotion, overridable
by `E188_BASE_CC`. With neither, R6 scores `nobase` and the script exits 1 — an
unscored control is not a passing one. The pin will age, and a stale pin is
repaired by a fresh `E188_BASE_REV`, never by widening the comparison.

**The five mutants, every one of them SUBSTITUTIONS and every one of them RUN.**
GA-19: deleting an arm makes the module non-exhaustive and the row is then
graded on a compile refusal instead of on the property it names. Each mutation
declares its occurrence count, the count is enforced at exactly 1, the mutated
file is `cmp -s`'d against the base before it is built, and the scratch `lib/` is
checked not to be a symlink (the `pretty.sh` arc).

| mutant | substitution | reddens | pin |
|---|---|---|---|
| **M1** | Step 4's arm reverted to `(c-lit-i 0)` | **R2** alone | `ok bad ok ok ok bad` |
| **M2** | Step 3's guard always refuses (`(=i ar (+ k d))` → `(=i ar (+ k (+ d 1)))`) | **R4**, and R1–R3 become `absent` | `absent absent absent bad ok bad` |
| **M3** | Step 3's guard never fires (the mismatch branch calls `st-add-site`) | **R5** alone | `ok ok ok ok bad ok` |
| **M4** | ⚑ **arity-PRESERVING, value-CHANGING**: one supplied index in `spine-args` reads a different binder, the argument count staying `(+ k d)`. The SPEC audit replaced the original substitution and the note below says why | **R2** with a different failure than M1's | measured at implementation |
| **M5** | `g-subst-go`'s supplied index off by one (`(- (- (+ m d) 1) (- p k))` → `(- (+ m d) (- p k))`) | **R3** alone | `ok ok bad ok ok bad` |

⚑ **M1 is the element's own falsifier and it is BUILT AND RUN, not derived.**
EN-21 corrected E186's M5 for exactly that gap; this SPEC does not reintroduce
it. ⚑ **M3 is R5's falsifier**, and without it R5 would be a row no mutant
reddens, which is GA-22's shape. ⚑ **M4 separates "a spine" from "the RIGHT
spine"**: R2 without it is satisfied by any spine that happens to return 30.

⚑ **M4'S SUBSTITUTION IS WRONG AND ITS PIN CANNOT HOLD. Corrected by the SPEC
audit 2026-09-04, and the replacement is measured at implementation time rather
than pinned here.** `(<i p arity)` → `(<i p (- arity 1))` makes `spine-args`
emit `(+ k d) − 1` arguments for a `(+ k d)`-ary global, so the arm becomes a
PARTIAL application. Decision 2 already traced that shape to a refusal:
`rw-app-disp` finds no ctor for the unregistered `(ckey-g g ((+ k d) − 1))` and
leaves the spine bare (`closconv.chiral:1287-1291`), and `lower` refuses it at
`expr-args` with `"partial application"` (`lower.chiral:266`). The fixture's
`compile-main` is then skipped, R1 to R3 grade **`absent`** rather than
`ok bad ok`, and M4 has collapsed into M2. A mutant that reddens R2 by DELETING
the observable is the hole R4 and the `absent` cell exist to close, and it
leaves "the RIGHT spine" falsified by nothing, which is GA-22's shape and the
thing M4 is for. **The replacement is arity-PRESERVING and value-CHANGING**: it
keeps the argument count at `(+ k d)` and changes which binder ONE argument
reads, so the fixture still compiles, `$apply` is still called, and the `apply`
line prints a number that is not `direct`'s. Two constraints on the choice, both
read off this tree: the substituted index has to stay inside the arm's binder
range, or `lower` answers `unbound var` (M-B) and the row grades `absent` again;
and the fixture's supplied arguments have to carry DIFFERENT values under a
non-commutative operation, or a permutation is invisible. Step 6 owes the second
one. `apply-word.sh:59-67` records the same correction being forced on E185 by
measurement, and it is why **no pin in the table above is evidence until its
mutant has been built and run**.

**Why this gate is not satisfiable by the fixpoint or by today's green line.**
Both are undisturbed by the defect today, by EN-20's measurement and by M-A:
the suite is green, `B2 == B3` holds, `$apply5` and `$apply6` ride into the ELF
dead, and neither instrument witnesses the arm. R2's observable is a runtime
**value** that today reads `0`, and R6 pins today's binary at `0` explicitly, so
a green R2 cannot be inherited from either. ⚑ **And it is not built on
`ck-prog`.** The `ret` refusal (`lib/lowering/tal/check.chiral:256-258`) reddens
the compiler's two instances only because their family codomain is `(List Asm)`;
the fixture's codomain is `I64`, `const 0 : i64` matches the declared return,
and `ck-prog` accepts it silently. That is requirement 1, and it is why the
fixture's codomain is ground on purpose.

- **Green line:** the gating floor is `tools/test/run-tests.sh` and E188's own
  gate is not a phase in it. What the suite witnesses is one thing: Phase 7's
  root census moves **+1** for `prog/e188-apply-spine.prog`, and every existing
  phase stays green. `python3 tools/ledger-lint/ledger-lint.py` stays at its
  baseline; nothing may rise.
- **Done when:** `tools/test/apply-spine.sh` prints `11 ok, 0 FAIL` — six rows
  plus five mutants — with the base line `ok ok ok ok ok ok`, the promoted
  binary at its byte fixpoint (`B2 == B3`, non-empty checked), and
  `run-tests.sh` green with its root census up by one.

## 6. Residue & links

**Deliberately unbuilt, each with its home.**

- **The blast-radius census.** Nothing re-derives EN-20's one-off count of which
  TFn constructs which `$clo` and calls which `$apply`. That is a reachability
  census over the blob, diagnostics-arc shape rather than Lane A enforcement
  shape. ⚑ **UNASSIGNED, and this SPEC mints nothing.** `E189` is the last free
  number in Lane A's band (`docs/decisions/decision-lane-split.md`, `E184–E189`),
  the band is shared with [[arcs/diagnostics-arc]], and
  [[definitions/working-discipline]]'s deferral rule forbids naming a follow-on
  without minting its rows. §3's measurements did not change E188's scope
  (M-B: the `fv-site` break is a refusal, not a second miscompile), so nothing
  here earns the number.
- **`cap-subst`'s `((nil) nil) ; unreachable: aligned`
  (`closconv.chiral:1005`)** is `g-subst-go:969`'s twin on the `cs-lam` side and
  carries the same unproven comment over a value. Unmeasured by this run and
  untouched by this element. No home.
- **`docs/definitions/bug-classes.md:85`**, the `miscompilation` row whose stated
  mechanism does not cover a wrong value at a ground codomain. Decision 11,
  deferred to a `doc-audit` run on that doc.
- **The `CState` diagnostic channel**, if Step 3's blame proves wider than one
  commit. Step 3 names the split and the gate reads the refusal either way.
- **Whether R5 is tightened to read the `sk-defunc` tag** once that channel
  lands, which would give Step 1 a falsifier it does not have (§5). ⚑ **The
  author's call, opened by the SPEC audit 2026-09-04 and opening no row**: the
  alternative is dropping Step 1 and letting the family drop carry the blame, at
  the cost of the boundary-sums shape decision 9 argues for. Nothing waits on it
  and the element is implementable either way.
- **`records/author-calls.md:30`'s count paragraph** reads "8 of 21" and will
  read 9 of 22 once E188's gate lands. Editing that row is the author's, per
  decision 10; the implementation run adds the pointer, not the ruling.

**Follow-on this unblocks.** Nothing waits on E188. E188 waits on nothing. What
it constrains is ordering, and the constraint has a named trigger: **E188 must
land before anything that makes `alloc-growing` lower**, because `compile-fn`
skipping `alloc-growing` is the only thing keeping the bad dispatcher dead.

**Related:** [[E188-unreachable-arm-reached]] · [[arcs/enforcement-arc]] ·
[[records/enforcement-arc]] EN-19, EN-20, EN-21 ·
[[decisions/decision-erased-word-level]] · [[banks/erasure]] ·
[[banks/verification]] · [[definitions/pattern-boundary-sums]] ·
[[definitions/working-discipline]] · [[definitions/bug-classes]] ·
[[decisions/decision-lane-split]] · E185 (built; its gate is this one's shape) ·
E186 (ruled `concrete`; EN-21 is why M1 here is run rather than derived) ·
E187 (states types, and this is a wrong value) · E16, E18.
