---
row: enforcement/N14
arc: enforcement
title: `ttype` (`lib/lowering/upper/lower.chiral:35`, `(-> UT (Maybe TalTy))`) becomes total over the region a preservation lemma is stated on, or the skip at `lib/lowering/compile-back.chiral:268-270` is stated as a costed choice naming the region it excludes. FD-15 measured the published theorem as five lemmas each stated against a TOTAL function on types, so a lemma of that shape cannot be written over a partial non-injective `ttype`, and measured the divergence as starting in `lower.chiral` upstream of `tal-ty=?`. FD-16 surveyed seven production compilers and found every translation total on its input or aborting the whole compilation, with the drop-one-definition position unoccupied; the one production partiality, a HotSpot C2 bailout, keeps the refused method running from an already-verified class file. FD-20 measured the total type translation as a precondition of writing a typed preservation claim down at all
kind: tool
origin: new
req: 2
status: blocked
updated: 2026-09-09
---

# enforcement/N14: the region the type translation excludes, measured and stated

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** the type translation on the shipping path is total over the
  region a preservation lemma would be stated on, or the tree carries a
  statement of what that region excludes, with a measurement behind it and a
  gate that reddens when the region moves.
- **Serves:** requirement 2 of [[arcs/enforcement-arc]], "**The typed-assembly
  floor runs on the shipping path.**"
- **Goal:** [[goals/enforcement]], condition 3.

FD-20 measured the total type translation as the precondition of writing a
typed preservation claim down at all, which is why the row sits under
requirement 2 rather than under requirement 3's checker questions.

## 2. What the tree holds

Measured 2026-09-09 at `0aa1800`, against the working tree. Every count below
was taken by running something; the method is named beside it.

**Bank:** [[banks/erasure]], and this row lands on three of its nine shards.
Shard **F** is `tt-word` at `lib/lowering/tal/ssa.chiral:17-22`. Shard **G** is
the kept-versus-erased peel, `ty-kept-doms` at
`lib/lowering/compile-front.chiral:159-163` with `term->ntalty` sending
`(t-var i)` to `(nt-word)` at `:70`. Shard **H** is `filter-erasable` at
`lib/lowering/compile-back.chiral:184-193`, and the bank already carries the
correction this row needs: a def outside the native subset "earns a skip record
only when `first-nonlowering-op` names an offending extern; everything else is
dropped silently", with E184's `erased-by-design` arm named as the fix.

### The two type translations, and only one of them runs

| what exists | where | rung | reached by |
|---|---|---|---|
| `ttype`, `(-> UT (Maybe TalTy))`, partial on `u-other`, non-injective on `u-erased` | `lib/lowering/upper/lower.chiral:35-57` | **SEEDED** | nothing |
| the partition around it: `UT`, `LowBind`, `Lowdef`, `LowRes`, `any-dep?`, `any-eff?`, `any-quant?`, `doms-lower?`, `types-lower?`, `skip-reason`, `eligible?`, `lower-def`, `lower-all` | `lib/lowering/upper/lower.chiral:22-105`, 84 lines of 420 | **SEEDED** | nothing |
| `compile-fn`, the emission half of the same file | `lib/lowering/upper/lower.chiral:412-420` | IMPLEMENTED | `lower-defs`, `lib/lowering/compile-back.chiral:264` |
| `term->ntalty`, `(-> Term (Maybe NTalTy))`, the live type translation | `lib/lowering/compile-front.chiral:58-79` | IMPLEMENTED | `peel-def` `:212-224`, `prim->n` `:326-333`, `field-tys->n` `:238-245` |
| `ntalty->talty`, `(-> NTalTy TalTy)`, **total by its own declaration** | `lib/lowering/compile-back.chiral:24-32` | IMPLEMENTED | `lower-defs` `:261-262` |
| the exclusion channel: `SkReason`, `SkRec`, `skwhy-tag`, `skwhy-detail`, `format-blame` | `lib/lowering/skip-diag.chiral:15-16`, `:25-38`, `:119` | IMPLEMENTED | `lower-defs` `:271`, `filter-erasable` `:191`, `prune-pass` `:211` |
| the emitted-TFn census, committed and gated | `prog/optimizer-census.prog`, `tools/test/opt-census.sh` | IMPLEMENTED | run by hand, `not-a-phase:` |
| the peel census | absent | **absent** | nothing |

**Measurement M1, the reach.** `grep -rn` over `lib/`, `prog/` and `tools/` for
`\bttype\b`, `\bttype-list\b`, `\blower-all\b`, `\bskip-reason\b`,
`\beligible?\b`, `\btypes-lower?\b`, `\bdoms-lower?\b` and `\blower-def\b`
returns hits inside `lib/lowering/upper/lower.chiral` and two prose comments,
`lib/lowering/lowspec.chiral:27` and `lib/lowering/compile-front.chiral:324`.
A second grep for `\bUT\b`, `\bLowBind\b`, `\bLowdef\b`, `\bLowRes\b`,
`u-prim`, `u-tcon`, `u-erased` and `u-other` outside that file returns nothing.
`lib/lowering/compile-back.chiral:15` imports the module for `compile-fn`,
`LCore`, `TalTy`, `CEnv` and `TalSig`, which its own comment lists.

**Measurement M2, the live translation's refusals on definitions.** A probe
replicating `bridge-sig`'s loop (`lib/lowering/compile-front.chiral:344-353`)
was built with `chirality_blob_file` and run over the blob of every root in
`prog/` and `prog/samples/`. Sixty-nine roots, six of which are the
`e42_reject_*` / `e124_reject_*` / `e126_reject_*` load-refusal fixtures and
stop at `ld-err`. Over the remaining **63 roots and 22,742 globals**,
`term->ntalty` answered `(none)` on **zero** of them. Every codomain, every kept
domain and every body lowered, on every root.

**Measurement M3, the live translation's refusals on extern signatures.** The
same probe over `prim->n` (`lib/lowering/compile-front.chiral:326-333`): **4,902
extern signatures, 153 refused, 3.1%**, and every one of the 153 is one leaf,
`(t-primty "Pty")`. 102 land in a kept domain, first instance `pty-close`; 51
land in a codomain, first instance `adopt-pty`. Per program the set is three
externs, `pty-close`, `pty-read` and `adopt-pty`, all declared at
`lib/ports/pty.port:36-38`. `Pty` is a `porttype` at `lib/ports/pty.port:14` and
appears in neither `porttype-word?` (`lib/lowering/compile-front.chiral:37-46`)
nor `porttype-str?` (`:52-55`).

**Measurement M4, what `compile-back.chiral:268-270` actually skips.** A second
probe ran `compile-front` then `back-program` over the same 63 roots and
classified every `SkRec` reaching `br-ok` through `skwhy-tag` and
`skwhy-detail`. **347 records over 22,742 definitions, 1.53%**, in three
channels:

| channel | site | records | classes |
|---|---|---|---|
| `le-skip`, the arm this row names | `lib/lowering/compile-back.chiral:270-271` | **182** | `higher-order application` 162 (`lower.chiral:283`), `lambda stays upper` 10 (`:251`), `body is not a lambda chain` 10 (`:417`) |
| `filter-erasable`, shard H | `lib/lowering/compile-back.chiral:191` | **5** | `time-mono` 2, `notify` 2, `sock-connect` 1 |
| `prune-pass`, the callee cascade | `lib/lowering/compile-back.chiral:211` | **160** | eight callees, largest `be-chat-stream` 40 |

**Every one of the 182 is a term-level refusal.** `lower.chiral:283` is
`expr-app`'s catch-all on a spine head that is neither `lc-prim` nor
`lc-global`; `:251` is `expr`'s `lc-lam` arm; `:417` is `compile-fn` failing
`strip-lams`. None of the three consults a type translation. The type
translation the lower image applies is `ntalty->talty`, which is
`(-> NTalTy TalTy)` at `lib/lowering/compile-back.chiral:24` and carries no
`Maybe` to answer with.

**Measurement M5, the compiler's own numbers, and they agree with the pinned
gate.** Over `prog/compiler.prog`: `peel globals=1519 lowered=1519 cod-none=0
dom-none=0 body-none=0`, `prims n=85 lowered=82`, `skip defs=1519 front-dsk=0
emitted-nfns=1547 total-skips=12` of which 10 are `le-skip` and 2 are the
cascade. `bash tools/test/opt-census.sh` at HEAD the same day reads
`census tfns=1549 ok=1518 err=31 defs=1519 skipped=10 unfolded-ok=1518` and
`opt-census: 8 passed, 0 failed` in 23s wall. `defs=1519` and `skipped=10`
match the probes exactly, and `1549 - 1547 = 2` accounts for the cascade with
nothing left over, so `filter-erasable` dropped **zero** definitions silently on
this program.

**Measurement M6, the three refused externs have no crossing.** `grep -rn` for
`adopt-pty`, `pty-read`, `pty-close` and `nb-pty` over `lib/lowering/` returns
nothing. `lib/ports/pty.port:30-35` states the position itself: their native TAL
bindings are deferred, "declared here, owned at declaration, so callers
typecheck now; reaching the crossing native-emits only once it is registered."
`docs/elements/ledger.md:202` carries the owed item on E107, which is `built`
with `pty-close`'s native binding named as outstanding.

**Measurement M7, E123 landed on one side of a pair.**
`docs/elements/catalog.md:449` instructs "Add `Sock/LSock/Fd/Clock/Timer/Env →
nt-i64` (each one word) there (+ mirror the `ttype` `u-prim` twin in
`lower.chiral`)". `term->ntalty` carries both porttype legs at
`lib/lowering/compile-front.chiral:64-67`. `ttype`'s `u-prim` arm at
`lib/lowering/upper/lower.chiral:38-44` maps `I64`, `Str` and `Bytes` and stops.
The two functions the catalog calls twins have diverged, and the divergence is
in the direction that makes the dead one look more partial than the live one.

### The ledger rung, and the sentence it carries

`docs/definitions/status-ledger.md:174` places "Lowering: pure fragment → tal"
under **IMPLEMENTED** and gives as its evidence

```
lib/lowering/upper/lower.chiral — the E16 eligibility partition (ttype,
eligible?/skip-reason, the lowered/skipped split) plus compile-fn, imported by
lib/lowering/compile-back.chiral and so live in every compile
```

M1 measures
the partition half at zero call sites. The `compile-fn` half is live in every
compile and the partition half is SEEDED by that page's own definition, "code
exists and **nothing reaches it**".

## 3. The delta

**The row's obligation is undischarged and its mechanism is misattributed.**
Three facts, each measured above, and each one changes what is left to build.

**D1. `ttype`'s partiality has no consequence, because `ttype` has no caller.**
M1. Making it total, by any of the five mechanisms FD-17 surveyed or by
enriching `TalTy`, changes no byte the compiler emits and costs a BUILD RULE
cycle on a module inside the compiler's own blob. The row's first branch is a
no-op on the shipping path.

**D2. The live type translation is already total on definitions, and its whole
refusal region is three extern signatures owned by another element.** M2 and M3:
0 refusals over 22,742 globals, 153 over 4,902 extern signatures, all one leaf,
`(t-primty "Pty")`, three externs per program. M6 and E107's ledger row put
those three behind an owed native binding, and `lib/ports/pty.port:30-35` states
the deferral in the source. Adding `Pty` to `porttype-word?` would peel three
crossings that `lib/lowering/tal/crossing-wraps.chiral` cannot lower, which is
the failure `lib/lowering/compile-front.chiral:32-33` describes from the other
side. **The code-side delta of this row is zero and its owner already exists.**

**D3. The skip the row names is a term-level skip, and five documents read it as
a type-translation skip.** M4: all 182 `le-skip` records come from
`lower.chiral:251`, `:283` and `:417`, and `ntalty->talty` has no `(none)` to
produce. The five readings are the `enforcement/N14` roster row itself; the
`enforcement/N13` roster row, "so `ttype`'s `(none)` routes to detection instead
of the definition leaving the artifact at
`lib/lowering/compile-back.chiral:268-270`"; `records/lenses/gaps.md` GAP-22,
"today a `(none)` drops the definition instead of routing it";
`docs/decisions/decision-preserve-check.md`, "This tree drops the definition from
the artifact `ck-prog` reads"; and `docs/definitions/status-ledger.md:174`.
`records/findings.md` FD-15 names `low-skip` at `lower.chiral:32` as "the pass
recording that failure as a value", and `low-skip` is inside the SEEDED
partition.

**And the census's 31 is a third thing again.** `opt-census.sh` R3 pins one
class, `call: unknown tal function`, n=31, every callee the refused TFn's own
`<name>$0` outlined block, which `outline` (`lower.chiral:311-319`) names and
`compile-fn` (`:420`) discards from `st-fns` before `lower-defs` builds the
program-wide `CEnv` from `def-sigs`. Those 31 TFns **are in the artifact** and
the checker refuses them. The 10 skipped ones never enter the artifact, so the
checker never sees them. The two numbers count opposite events and neither is a
type-translation refusal.

**What is genuinely missing, then.** The tree carries no statement of the region
its type translation excludes. The region is unmeasured and no instrument
re-derives it. Requirement 2's second branch, and this row's second
branch, both ask for exactly that, and `docs/decisions/decision-scope.md`'s rule
is why the statement needs the number behind it: a check aimed at a guess passes
by looking at nothing. [[records/enforcement-arc]] EN-25 is the precedent in this
arc, where a closing figure rested on a probe that was never committed and the
repair was `prog/optimizer-census.prog` plus `tools/test/opt-census.sh`.

**Verdict:** a real delta, smaller than the row states and differently sited.
The code-side work is zero and belongs to E107. What is owed is the instrument
and the statement, plus the repointing of five citations onto the site that
runs.

## 4. The shapes

### Shape A: enrich `TalTy` so `ttype` becomes total

- **Form:** give `TalTy` (`lib/lowering/tal/ssa.chiral:21-22`, five
  constructors) a spelling for arrows and universes, so `ttype`'s `u-other` arm
  has a target and the `(Maybe ...)` in its declaration can go.
- **Costs:** two modules inside the compiler blob change, so a BUILD RULE cycle
  with the `C2 == C3` case live, per [[working-discipline]]. `tal-ty=?`
  (`lib/lowering/tal/check.chiral:68-77`) gains arms and every `ck-*` rule gains
  a case. FD-15 measured the underlying obstruction: `∀` and `∃` have no target
  spelling, so neither CPS's `K[[∀a.t]]` nor closure conversion's existential
  has a `TalTy` to be.
- **Buys:** nothing measurable. M1: the function has no caller, and M5's census
  is the instrument that would show a change.
- **Forbids:** Shape E.

### Shape B: one of FD-17's five discharges, applied to the erased region

- **Form:** pick a published mechanism that makes the coarse target type sound,
  and pay it where FD-17 §7 says it is paid.
- **Prices, quoted from FD-17 §7 by coordinate.** *The checked downcast* needs a
  new `Instr` form carrying a source register and a target `TalTy`, a `ck-instr`
  arm that retypes the register, a runtime type descriptor on every value a
  `tt-word` can hold, and a trap; `tt-word`'s arm in `tal-ty=?` becomes a
  refusal and every site it exposes becomes a producer obligation.
  *Specialization* needs no target change and duplicates a definition per
  instantiation, deleting `tt-word` from the range;
  INTENSIONAL:162 is the compilation-unit boundary it cannot cross, which
  [[decisions/decision-scope]]'s self-hosting-is-one-program makes locally
  available and globally not. *Type passing* needs `LCore`
  (`lower.chiral:116-123`) to stop being type-erased, plus a `typecase` at the
  TAL term level and a `Typerec` at the `TalTy` level, and FD-17 measures it the
  largest of the five by every measure its sources give. *Term-level
  representations* need one new `TalTy` constructor, a representation family
  indexed by a `TalTy`, and a `tal-ty=?` arm relating representations by index.
  *A coercion* needs a proof-term category in `Instr` and an axiom set.
- **The tension, and it is real.** FD-17 measured the coercion calculus as the
  only one of the five with zero runtime cost, SYSTEMFC:49-51, "coercions are
  erased before running the program, so they are guaranteed to have no run-time
  cost", and GHC implementing exactly that at GHCCORETOSTG:218. The axiom its
  `tt-word`-against-`tt-str` case needs has no derivation from reflexivity,
  symmetry and transitivity, and FD-17 states the consequence in the tree's own
  terms: "an axiom admitting every one-word type is the collapse
  `docs/decisions/decision-erased-word-level.md:44` names". That line is the
  settled argument that a `Word` converting with `I64` and with `(List Str)`
  makes `I64` convert with `(List Str)`. GHC's own answer to the same need is
  `UnivCo`, GHCTYCOREP:1540 and :1655, an unproved coercion a producer names at
  a site with its dependencies tracked. **So the free-at-runtime option and the
  no-collapse option meet only in the restricted form, and the restricted form
  reintroduces the site four of the five already require.** No mechanism among
  the five is free, and FD-17's own negative result is that no pinned source
  describes one that discharges inside a checker's equality relation with no
  site in the artifact.
- **Whose it is:** not this row's. All five discharge `tt-word` inside
  `tal-ty=?`, which is `enforcement/N15`, or at `shape-eq`, which is
  `enforcement/N16`. FD-17's own `element:` field reads "the choice among the
  five is the author's call", and
  `docs/decisions/decision-preserve-check.md` says "Not settled here: which
  discharge T0 takes."
- **Composes with:** A, D, E, F. It is orthogonal to all four.

### Shape C: route the refusal to T1 rather than dropping

- **Form:** `docs/decisions/decision-preserve-check.md`'s ruling carried out.
  Where the translation refuses, hand the definition to the two-evaluator
  agreement instead of dropping it.
- **Costs:** T1 does not exist. GAP-22 is the gap, owner `enforcement/N13`, and
  its two halves are `lib/evidence/interp.chiral` (109 lines) and
  `lib/lowering/tal/eval.chiral` (187 lines), both at zero importers, verified
  by grep 2026-09-09.
- **What it would route, measured.** M2 and M3: zero definitions and three
  extern signatures per program. Routed today it carries nothing. The 182
  `le-skip` records M4 counts are a different door and
  `decision-preserve-check` does not name them.
- **Whose it is:** `enforcement/N13`'s construction, and the question of what T1
  covers is decision 1 in §5.
- **Composes with:** D. Mutually exclusive with nothing.

### Shape D: the costed choice, stated and instrumented

- **Form:** the row's own second branch. The tree gains a committed probe that
  re-derives the peel census, a gate that pins it and reddens when the excluded
  region moves, and a document statement naming the region, its size, its cause
  and its owner. The five misattributing citations in D3 are repointed at the
  site that runs.
- **Costs:** one `prog/` root and one `tools/test/` gate, on the
  `prog/optimizer-census.prog` plus `tools/test/opt-census.sh` precedent that
  [[records/enforcement-arc]] EN-25 forced. Neither is inside the compiler
  closure, so no BUILD RULE cycle is owed. The gate takes no suite phase number
  and declares `not-a-phase:`, which is the standing author call four scripts
  already wait on ([[records/author-calls]]) and which this row does not deepen.
- **Buys:** the only measurement in this design that nothing in the tree can
  re-derive today. It also makes D1, D2 and D3 falsifiable: a change that
  reintroduces a definition-level refusal reddens the gate.
- **Forbids:** nothing.
- **Composes with:** every other shape. Under A or E the census is what shows
  the edit changed nothing; under F it is what shows the region closed.

### Shape E: retire the unreached partition

- **Form:** delete `UT`, `LowBind`, `Lowdef`, `LowRes`, `ttype`, `ttype-list`,
  `any-dep?`, `any-eff?`, `any-quant?`, `doms-lower?`, `types-lower?`,
  `skip-reason`, `eligible?`, `lower-def` and `lower-all` from
  `lib/lowering/upper/lower.chiral`, 84 lines of 420, leaving `compile-fn` and
  its helpers. M1 measured zero consumers for all fifteen names.
- **Costs:** the module is inside the compiler's blob, so a BUILD RULE cycle is
  owed. It removes the object `docs/decisions/decision-preserve-check.md` names
  as `PRINCIPLES.md` §5's tier line, the object GAP-22 is written over, and the
  object FD-15, FD-16 and FD-20 reason from. `lower.chiral:1-16`'s header names
  the partition as the half differentiable against `lower.py.lower_all`, and
  that oracle is CUT ([[status-ledger]]), so the differential it was kept for no
  longer has a second side.
- **Forbids:** Shape A, and Shape C as `decision-preserve-check` currently
  words it.
- **Against it:** `docs/elements/catalog.md:449` instructs the opposite,
  mirroring the porttype legs into `ttype`'s `u-prim` arm, which M7 measures as
  the half of E123 that never landed. Two settled documents point at keeping the
  function and one measurement points at deleting it.

### Shape F: close the measured region by declaring the carrier

- **Form:** the STOPGAP `lib/lowering/compile-front.chiral:49-51` already names.
  Replace the two closed name lists with a per-`porttype` declared carrier the
  loader populates, on the `latoms` precedent the comment itself cites, so
  `term->ntalty` is total over every `t-primty` a `porttype` can name.
- **Costs:** M6. The three refused externs have no entry in
  `lib/lowering/tal/crossing-wraps.chiral`, and `lib/ports/pty.port:30-35`
  defers their native bindings deliberately. Declaring the carrier without the
  bindings peels three defs whose crossings cannot lower, which moves the
  refusal from the peel to emit and buys a worse error.
- **Whose it is:** E107's owed `pty-close` binding
  (`docs/elements/ledger.md:202`) and E123's unlanded half
  (`docs/elements/catalog.md:449`). Both are minted.
- **Composes with:** D. Under D the gate is what shows the region closed when
  E107's item lands.

### Mutual exclusion and composition, in one place

| | A | B | C | D | E | F |
|---|---|---|---|---|---|---|
| **A** | | composes | composes | composes | **exclusive** | composes |
| **B** | composes | | composes | composes | composes | composes |
| **C** | composes | composes | | composes | **exclusive as worded** | composes |
| **D** | composes | composes | composes | | composes | composes |
| **E** | **exclusive** | composes | **exclusive as worded** | composes | | composes |
| **F** | composes | composes | composes | composes | composes | |

Only one pair is genuinely exclusive: A enriches the dead function and E deletes
it. C against E is exclusive only in the wording, because
`decision-preserve-check` draws its tier line through `ttype`'s `Maybe`; that is
decision 1 in §5.

## 5. The call

- **Chosen: Shape D**, the costed choice with an instrument behind it, and
  nothing else from this row.

Three reasons, in order of weight.

1. **Every other shape is measured as another row's or another element's.** B is
   `N15` and `N16` and, by FD-17's own field and by
   `decision-preserve-check`, the author's. C's construction is `N13` and
   GAP-22. F is E107's owed binding and E123's unlanded half. A and E turn on
   decision 2 below, which is the author's.
2. **D is the only shape that buys a measurement.** M2, M3 and M4 exist because
   this run built two throwaway probes. Nothing in the tree re-derives any of
   them, which is the exact position EN-25 convicted requirement 4 of and which
   `prog/optimizer-census.prog` was written to end.
3. **The row's first branch is a no-op and its second branch is unfilled.**
   D1 measures the first; D3 measures that five documents currently stand in for
   the second and all five name the wrong site.

**What the call costs, stated rather than absorbed:**

1. **It closes nothing on the shipping path.** The floor still does not run
   there, requirement 2 stays open, and this element adds no judgment. What it
   adds is a number nobody can quietly lose.
2. **It ships a gate outside the dispatch table**, the fifth in this arc to do
   so, and the standing suite-phase-number call gets no cheaper.
3. **It leaves `ttype` where it is.** Under decision 2 the function may later be
   retired or repaired, and the census is indifferent to either.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Whether `docs/decisions/decision-preserve-check.md`'s tier line moves off `ttype` | **NEEDS-AUTHOR** | The decision is `status: settled` and reads "`ttype`'s `Maybe` is P5's tier boundary written into the code", with T1 covering "the region where `ttype` answers `none`". M1 measures that function at zero call sites and M2 measures the live translation's `(none)` region as empty on definitions, so T1's region as the decision draws it is empty and `enforcement/N13` would build against it. The decision's substance is untouched by this: EN-20's `const 0` case sits inside the `(some t)` region and T1 still convicts it, which is a different job from the one the decision assigns. A session may not rewrite a settled decision, and redrawing T1's region changes what `N13` is built against. The measurement is in §2; the ruling is the author's |
| 2 | Whether the 84-line unreached partition in `lower.chiral` is retired or repaired | **NEEDS-AUTHOR** | Shape E against Shape A, and the tree points both ways. `docs/elements/catalog.md:449` instructs mirroring the porttype legs into `ttype`, which M7 measures as never done, and `docs/decisions/decision-preserve-check.md` plus GAP-22 are written over the function, so two settled documents want it kept. M1 measures fifteen names with zero consumers and `lower.chiral:1-16`'s stated reason for keeping them is a differential against a CUT oracle, so the measurement wants it gone. Either answer costs a BUILD RULE cycle on a blob module and neither changes an emitted byte |
| 3 | Which of FD-17's five discharges T0 takes | **DEFERRED → `enforcement/N15`** | FD-17's `element:` field reads "the choice among the five is the author's call" and `docs/decisions/decision-preserve-check.md` reads "Not settled here: which discharge T0 takes". All five land on `tal-ty=?`, which is `N15`'s subject. §4 Shape B prices them and states the coercion tension; this row rules none of it |
| 4 | Whether `shape-eq` splits | **DEFERRED → `enforcement/N16`** | PRB-76 and FD-18 are that row's, and the roster row names the criterion as its subject. It bears on this row only through Shape B |
| 5 | Whether the `Pty` region is closed | **DEFERRED → E107** | `docs/elements/ledger.md:202` carries the owed `pty-close` native binding on E107, which is minted and `built`. M6 measures no crossing entry for any of the three externs, and `lib/ports/pty.port:30-35` states the deferral in the source. Closing the type-level list ahead of the bindings moves the refusal from the peel to emit |
| 6 | Whether T1 gets a call site | **DEFERRED → `enforcement/N13`** | GAP-22, owner `enforcement/N13`, state `scheduled`. Shape C cannot land before it |
| 7 | Whether the peel census duplicates `enforcement/N12` | **RESOLVED → no** | `N12`'s subject is "fold `ck-prog` over every emitted TFn and report accept, reject and the four reject classes", which is post-emission and reads the checker. This census is pre-emission and reads the peel: it counts definitions that never become TFns, which `ck-prog` cannot see. M5 shows the two meeting at one number, `defs=1519`, and diverging everywhere else |
| 8 | Whether the gate takes a suite phase number | **RESOLVED → no, `not-a-phase:` with a reason** | The route `crypto.sh:6`, `tal-check.sh:11`, `apply-word.sh:5`, `capture-fields.sh:6` and `opt-census.sh:5` all take, which keeps `tools/test/registration.sh` G2 and G4 green. The standing author call in [[records/author-calls]] stays exactly as wide as it was |
| 9 | Whether the five misattributing citations are repointed by this element | **RESOLVED → the two it owns, and the rest are named** | An element may repoint the documents it authors. The roster rows for `N13` and `N14` are the arc's, GAP-22 is a lens row whose `author:` and `note:` fields no pass may touch, `decision-preserve-check` is decision 1 above, and `status-ledger:174` is a `doc-audit` subject. The element writes its own record row and names the other four for their owners |

Decisions 1 and 2 set `status: blocked` and earn rows in
[[records/author-calls]]. Neither blocks the element §6 mints: the census and
the gate measure the live path and are correct under every answer to both.

## 6. The mint packet

- **Elements: one.** The probe and the gate are one deliverable, because a
  census that asserts its own verdict is green under any mutant that changes
  what the verdict says, which is the rule `prog/optimizer-census.prog:24-28`
  states for itself. Splitting them ships a number with nothing pinning it. The
  document statement is the same element's, because a statement without the
  number behind it is the guess `docs/decisions/decision-scope.md` names.
- **Band:** `E184-E189`, [[decisions/decision-lane-split]], and it is spent. The
  2026-09-06 overlap ruling in [[records/author-calls]] makes a band advisory,
  so `pack.py --mint` takes the lowest number free tree-wide. Measured
  2026-09-09 over `docs/elements/catalog.md` and `docs/elements/ledger.md`, that
  is **`E191`**, which lands inside Lane B's advisory `E190-E195` and collides
  with nothing.
- **Catalog row**, columns `E# | Element | State / location | Reference (class) | Track`:

  `| E191 | **The peel census: what the live type translation excludes, measured and gated.** `term->ntalty` (`lib/lowering/compile-front.chiral:58-79`) is the type translation on the shipping path and `ttype` (`lib/lowering/upper/lower.chiral:35`) has zero call sites, so the region a preservation lemma would exclude is the peel's refusals and not `ttype`'s. A committed root re-derives `bridge-sig`'s loop over any program and reports globals, lowered, and the refusals by position and by failing leaf, beside `back-program`'s three skip channels classified through `skwhy-tag`. A gate pins the compiler's own figures and reddens when the region moves. FD-20 measured the total type translation as the precondition of a typed preservation claim; this states which region the tree's translation is total over, with a number behind it | Not built. Measured 2026-09-09: 63 roots, 22,742 globals, **zero** refused; 4,902 extern signatures, **153** refused, all `(t-primty "Pty")`, owned by E107's owed binding; 347 skip records, of which 182 are `compile-back.chiral:270`'s term-level `le-skip`. Nothing in the tree re-derives any of it | `OURS` (`prog/optimizer-census.prog` + `tools/test/opt-census.sh`, the same shape one stage earlier); CompCert's per-pass validators (`PAPER`, FD-20) | SH |`

- **Ledger row**, CG section, columns `E# | Module | State | Title | Cites | Track`:

  `| E191 | peel-census | design | **The peel census: the region the live type translation excludes.** `prog/peel-census.prog` re-derives `bridge-sig`'s peel (`lib/lowering/compile-front.chiral:344-353`) over any program and `tools/test/peel-census.sh` pins it; `not-a-phase:`, on the `opt-census.sh` route. Measured 2026-09-09: 0 refusals over 22,742 globals, 153 over 4,902 extern signatures all `(t-primty "Pty")`, 347 skip records in three channels | E16, E107, E123, E184 | SH |`

- **Size.** Four files touched, one of them new-in-`prog/`, one new-in-`tools/test/`.
  `prog/peel-census.prog` at **200 to 260 lines**, basis: the working probes this
  run built are 118 and 71 lines and cover the whole measurement; folding them
  into one root with the class printer, the `back-program` half and the header
  the arc's roots carry lands in that band, against
  `prog/optimizer-census.prog`'s 225.
  `tools/test/peel-census.sh` at **220 to 280 lines**, basis:
  `tools/test/opt-census.sh` is 273 lines for four rows and four mutants, and
  this gate needs four rows and three mutants. `records/enforcement-arc.md`
  gains one EN row carrying M1 through M7. `docs/arcs/enforcement-arc.md`
  requirement 2 gains the paragraph naming the three channels and correcting the
  five citations D3 lists. **No file under `lib/` changes, so no BUILD RULE
  cycle is owed**, which M5's `opt-census` run and `tools/test/run-tests.sh`
  together are the check on.
- **The rows the mint writes into the arc.** `enforcement/N14` moves to
  `designed` with element `E191`, and its `kind` cell moves from `primitive` to
  `tool`: the deliverable is an instrument and a statement, and no primitive is
  added. The roster's `what` cell keeps its text and gains the correction, since
  the row's premise is what §3 measured against.
- **Related:** [[banks/erasure]] shards F, G and H · [[decisions/decision-preserve-check]] ·
  [[decisions/decision-erased-word-level]] · [[records/findings]] FD-15, FD-16,
  FD-17, FD-19, FD-20 · [[records/enforcement-arc]] EN-20, EN-24, EN-25 ·
  `records/lenses/gaps.md` GAP-22 · `records/lenses/problems.md` PRB-70, PRB-74,
  PRB-75, PRB-76, PRB-77 · `enforcement/N12`, `N13`, `N15`, `N16`, `N17` ·
  E16, E107, E123, E184 · `.planning/TAL-CONFORMANCE-QUEUE.md`

Every `E#` named here is already minted. `E191` is the number this packet
allocates and `pack.py --mint` is what writes it.
