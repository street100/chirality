---
row: enforcement/N13
arc: enforcement
title: the preserve-check's T1 rung: `lib/evidence/interp.chiral` (109 L) and `lib/lowering/tal/eval.chiral` (187 L), both at zero importers, reach a call site and are required to agree **over the definitions that lower**, **22,395** of the 22,742 globals the peel accepts once the 347 skipped at `lib/lowering/compile-back.chiral:270-271` have left, because T0's claim is target well-typedness and says nothing about which value a well-typed body returns. ⚑ **Re-scoped 2026-09-09 by [[records/enforcement-arc]] EN-27.** This row read `so ttype's (none) routes to detection instead of the definition leaving the artifact`, and that router has nothing to route: `ttype` has zero call sites and `term->ntalty` refuses 0 of 22,742. The 347 term-level skips leave this row's reach, having no tal image to run. The convicting case is unchanged, EN-20 sitting inside the lowered set. `docs/decisions/decision-preserve-check.md` settled 2026-09-08 that a preserve-check is two rungs and was amended 2026-09-09 so the rungs stack over one program rather than partitioning it; GAP-22 is the gap this row closes; FD-20 measured every published route to a preservation claim as a function of two programs, and measured these two evaluators as the independent writers `PRINCIPLES.md` §5's rung table requires before N copies buy anything. EN-20 is the case T1 convicts and `ck-prog` accepted. ⚑ `docs/elements/catalog.md:484` E169 half (a) already describes this instrument, is minted at ledger state `design`, and no arc names it (UNS-45), so whether this row adopts E169 or mints is the design stage's
kind: tool
origin: connect
req: 2, 3
status: blocked
updated: 2026-09-29
---

# enforcement/N13: the preserve-check's T1 rung

> One roster row worked up, produced by the `element-design` run. It runs BEFORE
> the row has an element number. §6 is the packet the mint executes.

## 1. The obligation

- **The row:** a source evaluator and a target evaluator run the same program
  and a gate reddens when they disagree, over the definitions that lower. The
  case the rung exists to convict is EN-20's: a well-typed target body that
  returns `0` where the source returns `30`.
- **Serves:** requirement 3 of [[arcs/enforcement-arc]], "**The check agrees
  with the compiler it checks.**", in its second half, "Agreement runs both
  ways, and [[records/enforcement-arc]] EN-20 measures a case where the check
  agrees with a compiler that is wrong" (`docs/arcs/enforcement-arc.md`,
  requirement 3). The row also lists requirement 2, whose own text says the
  floor reaching the shipping path "buys type preservation, which
  `docs/decisions/decision-preserve-check.md` already fixes as T0". T1 is the
  rung that requirement leaves uncarried.
- **Goal:** [[goals/enforcement]], condition 2, a claim the compiler makes about
  its own work carried as a value with evidence (`docs/goals/enforcement.md:29`).
  Condition 3's "running in the shipping compile" (`:34`) is touched only
  through the placement call in §5.

## 2. What the tree holds

Measured 2026-09-29 at `eaacba2`, working tree as the author left it.

- **Bank:** [[banks/verification]]. Shard 9 (`docs/banks/verification.md:468`)
  is this instrument, "upper→tal behavioural coverage", DESIGN, `E169`, pairing
  `interp.chiral` with `eval.chiral`. Shard 2 (`:126-135`) is T0's side and
  reads "BUILT and ENFORCED", which `ck-prog`'s zero call sites contradict
  (residue, drift). [[banks/evidence-and-split]] adds no shard here.
- **Settled texts.** `docs/decisions/decision-preserve-check.md:16-29` settles
  two rungs over one program; `:66-70` names EN-20 as the case "T1 convicts";
  `:77-82` names the two files as the independent writers; `:119-123` sets the
  population as the definitions that reach the artifact.
  `docs/decisions/decision-self-verification.md:171-177` puts translation
  validation below L0, "per compilation".

| what exists | where | rung | reached by |
|---|---|---|---|
| the source evaluator: a trampolined big-step evaluator over its own nameless `Term` of seven constructors, `e-var`, `e-lit`, `e-lam`, `e-app`, `e-let`, `e-con` by `I64` tag, `e-case` with no default arm | `lib/evidence/interp.chiral:31-38`, driver `:75-105` | SEEDED | zero importers: `grep -rln 'evidence/interp"' lib prog tools` returns nothing |
| its op coverage: **zero**. No prim, no global, no string literal. Its header defers the whole extern face, "`e-global`/`e-prim` … the DEFERRED bridge connector (decision #2)" | `interp.chiral:17-20`; `docs/elements/specs/E15-reference-interpreter-SPEC.md:83` resolves decision 2 as a separate bridge module owned by "the bridge module + E51" | absent | nothing |
| its answer on anything it cannot run: the sentinel `(v-lit -1)`, from an out-of-range index, an unmatched case tag and every `step-stuck` | `interp.chiral:52`, `:58`, `:105` (stuck sites `:87-88`, `:92-93`) | SEEDED | nothing |
| its effect: `=>`, may diverge, no fuel | `interp.chiral:8-11`, `:68-71` | SEEDED | nothing |
| the target evaluator: fuel-bounded and total, `(-> I64 Prog Store TFn (List Val) RunR)` | `lib/lowering/tal/eval.chiral:98`, `:111-187`, fuel `:6-8` | SEEDED | zero importers, same grep |
| its op coverage: `eval-prim` defines `+ - * / %` and answers `(v-i64 0)` for every other op or operand shape | `eval.chiral:86-95`, fallbacks `:88`, `:95` | SEEDED | `eval-instr`'s `i-prim` arm, `:132-134` |
| the op names a lowered `i-prim` may carry: 16 parsed by `op-parse` and 24 byte-library rows, 40 in all, so 35 fall to the fallback | `lib/lowering/tal/erase.chiral:91-108`, `:112-142` | IMPLEMENTED | `lowerable-prim?`, `lib/lowering/compile-back.chiral:280-290` |
| `eval-instr` reads every `i-const` as `v-i64`, a `tt-str` literal's table index included, and the evaluator's entry takes no literal table | `eval.chiral:131`; the entry's signature at `:98` | SEEDED | nothing |
| a non-constructor scrutinee refuses: `r-err "case: scrutinee is not a constructor"`, so a comparison reaching `tt-case` refuses | `eval.chiral:180` | SEEDED | nothing |
| no sysface | `eval.chiral:11` | absent | the gap is empty on the lowered set, per `docs/arcs/parts/enforcement-N23.md` §2 |
| the source program: the checked `Sig`, then `specialize-singletons`, then `closconv-sig`, then the peel into `NDef` with `NCore` bodies | `lib/lowering/compile-front.chiral:369-373`; `NCore` at `lib/lowering/lowspec.chiral:38-50` | ENFORCED | every compile |
| the target program: `compile-fn` over each `NDef`, then `fold` through `opt-tfns`, before erase | `lib/lowering/compile-back.chiral:246-250`, `:253-272` | ENFORCED | every compile |
| the driver shape: a `prog/` root outside the closure that runs `compile-front` and replays `lower-defs`' loop | `prog/optimizer-census.prog:48-53`, `:154-162`, `:204-225` | ENFORCED as a gate | `tools/test/opt-census.sh` |
| EN-20's defect: `closconv`'s `arm-body` emitted `(c-lit-i 0)`; FIXED by E188, whose gate carries it as a mutant over a fixture that prints `30` against `0` | `records/enforcement-arc.md:250-258`; `lib/lowering/upper/closconv.chiral:1129`; `tools/test/samples/e188_apply_spine.prog:1-8`; `tools/test/apply-spine.sh:306-311` (M1) | ENFORCED (E188) | `apply-spine.sh`, outside dispatch |
| the kernel's own evaluator: NbE, globals and prims stuck | `lib/typing/kernel.chiral:672-690`, `:682-683` | ENFORCED as a type-checker | the kernel |
| `E169`, half (a) of which is this instrument, homed at `lowering-and-emit/LE20`; `E15`'s row is `LE19` | `docs/elements/catalog.md:489`; `docs/elements/ledger.md:155`; `docs/arcs/lowering-and-emit-arc.md:219-220` | DESIGN | nothing |

**Four readings the design turns on.**

1. **The literal EN-20 measured is born upstream of `NCore`.** `closconv-sig`
   runs before the peel: the import comment at `compile-front.chiral:21` and the
   composition at `:373`. And `arm-body` returns a `Core` (`closconv.chiral:1129`). So under
   E188's M1 the `0` is already in the `NCore` body, and a source side read at
   `NCore` evaluates it to `0` on both sides and agrees. A T1 cut at `NCore`
   cannot convict the case `decision-preserve-check.md:66-70` says T1 convicts.
   Read from source. No T1 driver exists to run the mutant under.
2. **The source evaluator can run no definition in the tree.** Its `Term` has
   no global, no prim and no string (`interp.chiral:31-38`). A body that calls
   another definition or any primitive has no image in it. Whether any of the
   22,395 lowered bodies avoids all three is unmeasured; `+` alone is a prim.
3. **Both evaluators manufacture values.** The target's `(v-i64 0)` is
   N23's measurement. The source's `(v-lit -1)` is the same shape: a stuck
   evaluation reads as a legitimate `-1`, and agrees with a target that returns
   `-1`. Across the two sides the sentinels differ, so the more likely failure
   is a false disagreement, and an unstuck source beside a `0`-fabricating
   target can agree on `0` by accident.
4. **The pair collides on names.** `v-con` is declared at `interp.chiral:28`,
   `eval.chiral:28` and `kernel.chiral:30`. `interp.chiral` also shares
   `arm-body` with `closconv.chiral:1129`, `Value` with `kernel.chiral:24`,
   `Term` with `lib/surface/syntax.chiral:18` and `eval-args` with
   `kernel.chiral:654`. Any root that imports `lowering/compile-front` and
   `evidence/interp` carries both. Measured by grep; the load or emit refusal
   is unmeasured. `lowering-and-emit/LE18` reproduces the label refusal for a
   private `helper` (`docs/arcs/lowering-and-emit-arc.md:218`).

## 3. The delta

What is missing once §2 is subtracted.

1. **A source evaluator that can run the source program.** Globals by lookup,
   prims by dispatch, string literals, constructors by name, a case default,
   stuck made observable as a closed result, and fuel so it terminates. None
   of it is this row's: E15's SPEC deferred the extern face and no roster row
   holds it (residue table).
2. **A target evaluator that can run the target program.** Already on the queue
   from N23 (`.planning/DISPATCH-QUEUE.md` E4): `eval-prim` coverage, `r-err`
   on an unknown op, a literal table. This row restates the dependency and
   claims none of it.
3. **The bridge from the source program to the source evaluator.** A total
   translation from kernel `Term` into the evaluator's term language, with the
   type-level constructors (`t-type`, `t-pi`, `t-primty`, `t-tcon`, `t-refine`)
   mapped to one inert value. This row's.
4. **A value relation across the two value languages.** Source `Value` against
   target `Val`: an integer against `v-i64`, a constructor against `v-con` by
   constructor name with fields related pointwise, a string against a `v-str`,
   and a closure related to nothing, so an entry returning a function is
   `vacuous`. This row's. The target-side read of a `v-cell` through its
   `Store` is N23's §3 item 2 and this row imports it.
5. **A verdict and a gate.** The verdict is N23's three-way sum, `agree`,
   `disagree` with the first differing entry, `vacuous` when either side is
   stuck or the result is higher-order. The gate's falsifier is E188's M1
   re-applied under the T1 driver: the gate must redden. A control row: the
   unmutated tree agrees over the corpus. A vacuity row: the count of lowered
   definitions the corpus reaches, printed and pinned.
6. **A consumer for the verdict**, which is the placement call.

**Verdict:** a real delta. Items 3 to 5 are this row's; items 1 and 2 are
preconditions owned elsewhere; item 6 is the author's.

## 4. The shapes

Three axes differ in the tree and a fourth is the author's.

### Axis 1: where the source side is read

**Shape N, at `NCore`.** The source is `fr-ok`'s `NDef` list
(`prog/optimizer-census.prog:210`), the same value `compile-back` reads.
- **Costs:** least. `NCore` has eleven constructors, first-order after
  `closconv`, and every driver already has it.
- **Forbids:** convicting EN-20 (§2 reading 1). The rung would cover
  `compile-fn` and `fold` only, and `closconv`, `specialize-singletons` and the
  peel would sit on the source side of the comparison, trusted.

**Shape K, at the checked `Sig`.** The source is the `Sig` `tot-gate` accepts,
before `specialize-singletons` (`compile-front.chiral:369-373`).
- **Costs:** the source evaluator meets higher-order values, which
  `interp.chiral` was written for (`v-clo`, `:27`). The translator of §3 item 3
  covers sixteen kernel constructors (`kernel.chiral:675-690`) against eleven.
  The driver must obtain the `Sig` and the `TFn`s from one run: today it would
  replay `compile-front`'s chain, which is the stale-copy hazard N12 measured
  for the pre-erase program.
- **Forbids:** nothing the row wants. Definitions `closconv` invents, the
  `$apply` dispatchers, have no source image and are checked only through the
  entries that call them.

**Shape NK, both cuts.** Evaluate at `Sig`, at `NCore` and at `TFn`, and
compare pairwise, so a disagreement names the stage.
- **Costs:** two translators and a third comparison.
- **Forbids:** nothing; it is K with blame localized.

### Axis 2: how the source evaluator reaches kernel terms

**Shape T, translate into its own `Term`.** `interp.chiral` keeps its term
language and imports only the prelude; a bridge module translates kernel
`Term` into it.
- **Costs:** a third writer, the translator, which can itself be wrong. Its
  error shows as a disagreement and is localized by Shape NK.
- **Forbids:** nothing. The evaluator stays independent of the compiler's data
  types, which is the independence `decision-preserve-check.md:77-82` names.

**Shape D, evaluate kernel `Term` directly.** `interp.chiral` imports
`surface/syntax` and walks the compiler's own `Term`.
- **Costs:** a rewrite of E15's module around the kernel image, and every
  change to `Term` in `lib/surface/syntax.chiral` becomes an edit here.
- **Forbids:** the name split of §2 reading 4 as a cheap fix, since the module
  then shares the kernel's namespace.

**Shape R, reuse the kernel's NbE.** Extend `eval-term` (`kernel.chiral:672`)
to unfold globals and reduce prims.
- **Costs:** an edit inside the type-checker and the closure, on the BUILD
  RULE.
- **Forbids:** the independence the decision requires: the source writer
  becomes the type-checker's evaluator, and `interp.chiral` stays unreached.

### Axis 3: where the arguments come from

**Shape W, named entries.** A corpus of programs, each with an entry and
argument tuples, the shape `docs/arcs/parts/enforcement-N23.md` §5 chose.
- **Costs:** coverage is by reach; the vacuity row reports it.
- **Forbids:** checking a definition no entry reaches.

**Shape P, per definition.** Each lowered definition with first-order
parameters evaluated alone on arguments drawn from its type.
- **Costs:** a generator over types, and inputs no program produces.
- **Forbids:** nothing, and it is the only shape that ranges over every
  definition the decision names.

### Axis 4: where the verdict is consumed, the author's

**Arm A, every compile.** The source `Sig` travels into the back, the
translator, both evaluators and the verdict enter `prog/compiler.prog`'s
closure, `interp.chiral` must become `->` to be called from `opt-tfns`'s pure
path (`compile-back.chiral:246`), and the four name collisions of §2 reading 4
must be gone first. Every later edit to either evaluator owes the BUILD RULE.
Time is unmeasured; FD-55 prices a validator at 1.1x to 4x of a pass's own
time.

**Arm B, a gate outside the closure.** A root in `optimizer-census.prog`'s
shape runs the corpus. No `lib/` file inside the closure changes. A
miscompile ships in any build that skips the gate.

## 5. The call

- **Chosen, Axis 1: Shape K.** Derived from the settled decision:
  `decision-preserve-check.md:66-70` says T1 convicts EN-20, and §2 reading 1
  measures that a cut at `NCore` cannot. Shape NK is deferred to a measured
  need: the first disagreement whose stage K cannot name.
- **Chosen, Axis 2: Shape T.** It keeps the source writer independent of the
  compiler's data types, which is the criterion the decision cites, and it
  leaves E15's pure core intact. D and R are refused on that criterion.
- **Chosen, Axis 3: Shape W, with the reach counted.** It is the shape N23
  chose, so one corpus serves both rows, and E188's fixture is a member by
  construction. P is deferred behind question 3 below.
- **Axis 4: carried, NEEDS-AUTHOR.**

**What N23 and N13 share, and what each keeps.** One corpus format and one
fixture directory, `tools/test/samples/`. One verdict sum, `agree`,
`disagree`, `vacuous`, which N23 §3 item 2 defines first. One target-side
precondition, the evaluator repair on the queue. One target-side value read
through a `Store`, N23's. N23 keeps the target-against-target comparison per
rewrite and `M-dead`. N13 keeps the source evaluator's reach, the translator,
the cross-language value relation, and the E188 mutant as its falsifier. Two
gates, because the falsifiers differ and a gate that reddens for either reason
cannot say which. T1 compares against the folded `TFn`, which is what ships
(`compile-back.chiral:272`), so a `fold` defect reddens T1 as well; the
attribution is N23's and N24's.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Where the T1 verdict is consumed: every compile, or a gate outside the closure | **NEEDS-AUTHOR** | The same fork as `records/author-calls.md:116`, whose words name "a rewrite's value check". PRB-70 (`records/lenses/problems.md:986`) points out; `docs/decisions/decision-self-verification.md:175` and `docs/goals/enforcement.md:34` point in. Arm A costs more here than for N23: the source `Sig` and a now-total `interp` both enter the closure. This run leaves row 116 as written |
| 2 | Whether `decision-preserve-check`'s tier line moves off `ttype` | **NEEDS-AUTHOR, carried** | `records/author-calls.md:83`, `unreviewed`. The decision's text was amended 2026-09-09 (`docs/decisions/decision-preserve-check.md:31-56`) and row 83 still quotes the pre-amendment wording. This design builds against the amended text: two rungs over one program, population the lowered definitions |
| 3 | Does T1 claim agreement over every definition that lowers, or over the definitions a named corpus reaches, with the reach counted | **NEEDS-AUTHOR** | `docs/decisions/decision-preserve-check.md:21-22` reads "value agreement, over the same definitions". An evaluator needs arguments; Shape W reaches a counted subset and Shape P reaches every first-order definition at the price of inputs no program produces. A session may not narrow a settled decision's words |
| 4 | Adopt `E169` or mint | **RESOLVED → adopt `E169`, half (a)** | `docs/goals/README.md:32` sits an element in every arc that claims it; `docs/arcs/lowering-and-emit-arc.md:220` states that `N13` adopting it "is no competition". Half (b), the Rocq ladder, stays `LE20`'s |
| 5 | Who extends `interp.chiral` with the extern face, observable stuck and fuel | **NEEDS A ROW** | E15's SPEC deferred it (`docs/elements/specs/E15-reference-interpreter-SPEC.md:83`); `LE19`'s "Wanted" names the header and a reach only (`docs/arcs/lowering-and-emit-arc.md:219`). Residue table |
| 6 | Who repairs `eval-prim` and adds the literal table | **DEFERRED → the queue's E4 fold-in** | Listed from N23 in `.planning/DISPATCH-QUEUE.md` E4. Not re-claimed here |
| 7 | Whether the name collisions block a driver | **DEFERRED → `lowering-and-emit/LE18`** | Label mangling is `E154`'s. Until it lands, a prefix rename in `interp.chiral` is the cost every root importing both pays, the `tck-` precedent at `5b4fb71` |
| 8 | Whether the gate takes a suite phase number | **RESOLVED → `not-a-phase:` with a reason** | The route `opt-census.sh` takes, kept honest by `tools/test/registration.sh` G2 and G4 |
| 9 | Whether T1 reaches below tal | **RESOLVED → no** | `tal-eval` runs the pre-erase `TFn`; erase and emit are outside this rung, which `docs/decisions/decision-self-verification.md:172-173` calls the single trusted drop |

Decisions 1 and 3 set `status: blocked`. Items 3 to 5 of §3 are designable
before either ruling; the vacuity row's meaning waits on decision 3 and the
consumer on decision 1.

## 6. The mint packet

- **Elements: none minted. The row adopts `E169`**, half (a) (§5 decision 4).
  The translator, the value relation, the verdict consumer and the gate
  constrain each other: the corpus is chosen so the E188 mutant reddens the
  gate, and the relation decides which entries are `vacuous`. They are one
  element, and `E169`'s half (a) already describes it. The two evaluator
  repairs are separate rows because each evaluator has other consumers: `N23`,
  `N24` and `LE20` on the target side, `LE19` on the source side.
- **Band:** none drawn. `E169` is minted.
- **Catalog row:** `E169`'s row at `docs/elements/catalog.md:489` keeps its
  number and title. The mint step appends to its rationale cell:
  `Half (a) is the preserve-check's T1 rung, adopted by enforcement/N13 (design docs/arcs/parts/enforcement-N13.md): source read at the checked Sig before specialize-singletons, translated into interp's Term, compared against the folded TFn under tal-eval over a named corpus; falsifier E188's M1. Rests on two unbuilt evaluator repairs. Half (b) stays lowering-and-emit/LE20's.`
- **Ledger row:** `E169`'s row at `docs/elements/ledger.md:155` keeps state
  `design`. The arc cell gains `enforcement/N13` beside `LE20`.
- **Size and closure.** Basis: `prog/optimizer-census.prog` is 225 lines for a
  root of this shape, `interp.chiral` is 109 lines for seven term forms, and
  `docs/arcs/parts/enforcement-N23.md` §6 sizes the shared gate pattern.

  | file | change | lines | inside `prog/compiler.prog`'s closure |
  |---|---|---|---|
  | `lib/evidence/t1-bridge.chiral` (new) | kernel `Term` to `interp` `Term`, and the value relation | 150 to 220 | no under Arm B; yes under Arm A |
  | `prog/t1-agree.prog` (new) | the corpus runner, Shape W | 150 to 220 | no |
  | `tools/test/t1-agree.sh` (new) | control, vacuity row, the E188 mutant | 150 to 250 | no |
  | `tools/test/samples/` | corpus fixtures beside `e188_apply_spine.prog` | 1 to 3 files | no |
  | `lib/evidence/interp.chiral` | none from this element; the residue row edits it | 0 | no today; yes under Arm A |
  | `lib/lowering/tal/eval.chiral` | none from this element; E4's row edits it | 0 | no today; yes under Arm A |
  | `lib/lowering/compile-front.chiral` | none under Arm B; under Arm A the `Sig` rides out with `FR` | 0, or 10 to 30 | **yes**, owes the BUILD RULE under Arm A |
  | `lib/lowering/compile-back.chiral:246-250` | none under Arm B; under Arm A `opt-tfns` consults the verdict | 0, or 10 to 20 | **yes**, owes the BUILD RULE under Arm A |

  Under Arm B no file inside the closure changes and no BUILD RULE cycle is
  owed by this element.
- **Related:** [[banks/verification]] shards 2 and 9 ·
  [[decisions/decision-preserve-check]] · [[records/findings]] FD-20, FD-55 ·
  [[records/enforcement-arc]] EN-20, EN-27 · GAP-22 · UNS-45 · PRB-70 ·
  `enforcement/N8`, `N14`, `N23`, `N24` · `lowering-and-emit/LE18`, `LE19`,
  `LE20` · E15, E18, E169, E188

Every `E#` named here is already minted.

## Residue

### Needed and unrostered

Grepped 2026-09-29 over `docs/arcs/*-arc.md` for `interp`, `interp.chiral`,
`reference interpreter`, `bridge connector` and `Sig`. The rows naming the
source evaluator are `lowering-and-emit/LE19`, `LE20` and `enforcement/N8`,
`N13`; none holds its extension. The queue's E4 row already lists the target
evaluator repair and N12's pre-erase program function; neither is repeated.

| needed | evidence | arc it belongs to |
|---|---|---|
| `interp.chiral` gains the extern face: globals by lookup, prims by a pure dispatch, string literals, constructors by name, a case default | `lib/evidence/interp.chiral:17-20`, `:31-38`; `docs/elements/specs/E15-reference-interpreter-SPEC.md:83` defers it to "the bridge module + E51", and E51 is the sys path | lowering-and-emit, beside `LE19` (E15's row) |
| `interp.chiral` answers a closed result where it answers `(v-lit -1)` today, and carries fuel so it is `->` and total | `interp.chiral:52`, `:58`, `:105`; `=>` at `:68-71`; the target side's fuel shape at `lib/lowering/tal/eval.chiral:6-8` | lowering-and-emit, the same row |
| one compiler function returning the checked `Sig` beside the program it lowers to, so a T1 driver reads both from one run | `lib/lowering/compile-front.chiral:369-373` returns only the bridged `FR`; extends N12's pre-erase item on the queue's E4 row | lowering-and-emit, inside the closure |

### Drift against the brief and the row

- The row cites E169 at `docs/elements/catalog.md:484`. It sits at `:489` in
  the working tree; `:484` is `E153`.
- The row reads "no arc names it (UNS-45)". UNS-45 is `ruled` since
  2026-09-18 and `E169` is homed at `lowering-and-emit/LE20`
  (`records/lenses/unspoken.md:619-631`).
- The row reads "The convicting case is unchanged, EN-20 sitting inside the
  lowered set". EN-20 is `FIXED` by E188 (`records/enforcement-arc.md:252`);
  what survives is E188's M1 mutant. And the literal sits upstream of `NCore`
  (§2 reading 1), so it convicts only a cut at the `Sig`.
- `decision-preserve-check.md:79` reads "`interp.chiral` evaluates `Core`". It
  evaluates its own seven-constructor `Term` (`interp.chiral:31-38`), which
  holds no global and no prim.
- `records/author-calls.md:83` quotes the decision's pre-amendment text; the
  decision carries the correction at `:31-56`.
- [[banks/verification]] shard 2 reads "BUILT and ENFORCED" for
  `preserve-check` (`docs/banks/verification.md:130`); `ck-prog` has zero call
  sites since PRB-70. A `doc-audit` item.
- The brief's item 3 asks what `interp.chiral` does on an unknown op. It has no
  op dispatch to be unknown to; every unrunnable shape becomes the `-1`
  sentinel (§2 reading 3).
- This run took the row's 22,395 as given; `enforcement/N14` owns the
  instrument that would.

### Unmeasured

- How many of the 22,395 lowered bodies call a prim, a global or a string, so
  how much of the lowered set the source evaluator reaches before its repair.
- Whether the four name collisions refuse at load or at emit.
- E188's M1 run under a T1 driver: §2 reading 1 is read from source.
- The wall and memory cost of either placement.
