---
node: arc-enforcement
layer: navigation
related: [arcs/README, goals/enforcement, status-ledger, arcs/diagnostics-arc, records/enforcement-arc, index]
status: current
updated: 2026-09-02
---

# Arc: enforcement

- goal: [[goals/enforcement]]
- reserved element block: `E184-E189`, shared with [[arcs/diagnostics-arc]] (`docs/decisions/decision-lane-split.md`, Lane A)
- checklist: [[records/enforcement-arc]]
- build-state authority: [[status-ledger]]

**This file is TRACKED for the same reason [[diagnostics-arc]] is.** The element
catalog and the ledger live in `.planning/`, which `.gitignore:12` excludes by
design, so each worktree carries its own copy and nothing there reaches a second
reader or a second session. An element fact anyone else needs lives here.

The arc's subject is enforcement: a claim the compiler makes about its own work,
carried as a value, with evidence, and refused when it does not hold. E184 is the
first element minted for it, and four older catalog rows belong to it: E16, E17,
E18 and E70.

`.planning/` stays the working detail (change plans, decision tables, SPECs).
This is the part that survives a fresh clone.

Build-state authority for the suite as a whole: [[status-ledger]].
Measurements this arc rests on: [[records/enforcement-arc]].
Lane division and what enforces it: `docs/decisions/decision-lane-split.md`. Lane A resume: `records/lane-a-record.md`.

## REQUIREMENTS

Done when all six hold. Each is checkable, and the state beside it is measured
2026-09-02.

1. **A capability sits at ENFORCED, or its ledger row says why it does not.**
   Inherited verbatim from [[goals/enforcement]]. Today four rows in
   [[status-ledger]] are written and unreached, so the row-says-why half is
   carrying the weight.
2. **The typed-assembly floor runs on the shipping path.** Still open, and the
   two things standing in front of it are now named. `ck-prog` is called nowhere
   and `lib/lowering/compile-back.chiral` does not import `lowering/tal/check`,
   because that import is a `duplicate label` refusal at load: eleven colliding
   top-level names, E154's fifth instance. Resolving them cascades through seven
   sha256-pinned gate scripts. Beyond that, a hard refusal on the shipping path
   needs EN-15 answered, since the compiler would refuse its own four `$apply`
   dispatchers. E16's title names the preserve-check and three of its four
   deliverables are built; E18's checker and reference interpreter exist
   unreached.
3. **The check agrees with the compiler it checks.** **Root-caused 2026-09-03**,
   `records/enforcement-arc.md` EN-08 to EN-13. Re-measured on that day's blob:
   1,481 TFns, 727 accept, **754 reject, 50.9%** (the move from 1,504/743/761 is
   E182 at `65bec90`, `d26d7a1`). **The checker is wrong in 99.2% of it**, through
   two defects: an erased type-argument list that `tal-ty=?` refuses and no other
   rule reads, and a `tt-word` scrutinee `ck-term`'s case arm has no arm for,
   which contradicts `tal-ty=?`'s own first arm. Relaxing both, 1,475 of 1,481
   accept. **Both checker defects are repaired at `ddfbc27`** and Phase 22
   (`tools/test/tal-check.sh`) pins that the repaired check still refuses, with
   nine REJECT rows and three live mutants. Of the six survivors, the
   erased-binder register is **fixed at `40e8726`** (EN-14) and the probe reads
   **1,477 of 1,481**. ⚑ The four `$apply` dispatchers remain, EN-15, and they
   are an author call in [[records/author-calls]].
4. **The optimizer's re-check runs, or E17 says why it does not.**
   `lib/lowering/upper/optimize.chiral` has zero importers and is in no blob, so
   `optimize` and `specialize` return a `Checked` result nothing ever forms.
5. **The gate tier is chirality's own.** Measured 2026-09-04: 6,915 lines of
   shell against 134 lines of native floor, and **352 calls to `grep`, `sed`,
   `sort` and `awk` where `docs/arcs/text-tools-arc.md` records a built
   chirality composition**. `lib/text/matcher.chiral` has one consumer,
   `prog/prose-lint.prog`. ⚑ Some shell is correct and stays: a comparator
   holding constants cannot be fooled by a mutated compiler, which is why
   `crypto.sh` prints from the fixture and compares in bash. What is owed is the
   text work, where a composition exists and nothing calls it. Every tool that
   moves is one fewer the OS rung has to trust. `records/gate-audit.md`.

6. **Every gate row names a mutant that is actually run.** Inherited from
   [[goals/enforcement]] and from `docs/definitions/testing-floors.md:261`. E173
   found two rows that could not fail; both were repaired at `e882568`.

⚑ Requirement 3 is the one that gates the rest. E16's scope and E18's both
stop short of it as written, so no element owns it.

## Resume state

**2026-09-04: requirement 5 is first priority by author direction**, and
`.planning/HANDOFF-2026-09-04.md` carries the full queue. The gate tier is
6,915 lines of shell against a 134-line native floor, with 352 calls where a
built chirality composition exists. Every tool that moves is one fewer the OS
rung has to trust.

**Requirement 3 is closed and requirement 2 is the live one.** 2026-09-03 ran
the diagnosis (EN-08 to EN-13), the author's ruling, both checker repairs with
Phase 22 gating them (`ddfbc27`), and the erased-binder fix with a promoted
fixpoint (`40e8726`). Suite 339 passed, 0 failed, 87 roots, gate PASSED.

Two things are owed, and they are independent of each other. **The eleven name
collisions** make `lowering/tal/check` unimportable beside the compiler, which
blocks requirement 2 and requirement 4 alike; resolving them is mechanical and
cascades into `tools/test/diag.sh:256` and seven sha256-pinned gate scripts.
**EN-15** is the author's, and it gates the moment the refusal goes live rather
than the plumbing. The refuse-or-carry ruling in [[records/author-calls]] is a
third and separate call.

The enabling change was measured, then reverted. Its artifacts survive.
`lib/lowering/tal/check.chiral` declares **11 top-level names that already exist
in the compiler's blob** (`CkR`/`ck-ok`/`ck-err` against `lib/typing/kernel.chiral:411`,
`CovR`/`cov-ok` against `lib/surface/data.chiral:37`, `find-ctor`, and five
byte-identical duplicates of `lower.chiral:160-191`), so importing it is a
`duplicate label` refusal at load before any type-checking. That is E154's
fifth instance. `tools/test/diag.sh:250-256` already records the collision as
deliberate.

Resolving them plus inserting the call site reaches a fixpoint at `K2 == K3` and
the suite runs `320 passed, 1 failed`, the one failure being `diag.sh:256`
grepping for a renamed literal. Repointing that guard cascades through **seven
sha256-pinned gate scripts over two rounds**, which is why it was reverted rather
than half-shipped.

Owed before any of this lands: the diagnosis slice for the four classes. Then the
refuse-or-carry ruling, which is the author's.

## Open: minted, not built

### E184

| E184 | **Attribution: every def's fate is stated by the compiler, with evidence, and checked** | Not built. Minted 2026-09-01. Attribution is **not measurable today**: five mechanisms decide a def's fate, only three leave a record, and all of it is discarded on the success arm. Seven requirements. **R1, a total fate function** over every def in the compiler's closure, a closed sum with no `_` arm: `emitted <label>` · `specialized-into <names>` (because `specialize-singletons` rewrites rather than drops) · `erased-by-design` (the type-level defs `filter-erasable` is supposed to remove) · `skipped <reason>`. The `erased-by-design` arm is required rather than optional: a type-level def is not a failed lowering, and without that arm every ratio built on the fates is noise. **R2, reasons carry evidence, not strings.** `skipped`'s reason is itself a closed sum: extern-with-no-wrapper naming the op, type-does-not-peel naming which type and where, callee-cascade naming the chain. E157's rule applies unchanged, and a `str-cat`'d sentence here reintroduces what E157 removed. **R3, `peel-def` stops returning `(Maybe NDef)`** and becomes a result sum. `compile-front.chiral:203-210` drops a def by returning `(none)` and keeps no record at all, the only one of the five mechanisms that leaves no trace, so nothing downstream can recover it. **R4, the record survives success.** `compile-all.chiral:34-38` discards the `skips` list on the `elf-ok` arm, so it surfaces only on an emit failure. **R5, the cascade is rooted.** `prune-fix` (`compile-back.chiral:212`) is transitive, and the cascade record is built at `compile-back.chiral:210`, in `prune-pass`, so "dropped because callee X was dropped" is a pointer rather than an attribution; every chain must resolve to a non-cascade root, and `skip-diag.chiral` already carries E97's blame chain as the existing shape, which is why it is the right home. **R6, fates survive a renaming, and this is the design fork.** `specialize-singletons` (`compile-front.chiral:20`) runs before peel and changes a def's identity: `x64` becomes `x64$0`, `x64$1` and so on. Fates are therefore a relation across a renaming, and the rename mapping has to be produced by the pass that performs it and carried the rest of the way. Get it wrong and monomorphized singletons read as failures, which is exactly the misreading that made the earlier measurement worthless. **R7, conservation checked inside the compile, plus an exit.** The fates partition the closure's def set, exactly one per def, and folding them reproduces the emitted set; a def with no fate, or with two, fails the compile. That is the line between attribution and logging. `bin/chirality` has compile / run / check / test and no exit for the report, so one is owed, and the gate that reads it is a chirality program on E168's test floor rather than a shell script. **Cost:** roughly 150 to 250 LOC across five modules, three signature changes (`peel-def`, `specialize-singletons` emitting its rename relation, `compile-all` threading fates), plus build-new → test → promote with the fixpoint verified and the Step-0 precondition checked first. **Needs the full pipeline** (worked example → audit → SPEC → audit → implement): the fate taxonomy is a taxonomy and R6 is a genuine fork. The pre-run may recommend splitting R6 into its own element; if it does, that split mints its rows in the same change. ⚑ **The one read-only probe is gone.** Compiling through the E166 `Mach`→C leg and joining mangled C symbol names back to def names died with that leg (`d8bcec5`, `d0c5dd5`), and was never legitimate anyway: it shared `compile-front` and `compile-back` whole and differed only at emit, which is one formulation with two emitters, the shape `docs/decisions/decision-self-verification.md` §0 explicitly rules out. ⚑ **Measured 2026-09-01:** `skip-reason` (`lib/lowering/upper/lower.chiral:83-93`) together with `eligible?`, `lower-all`, `lower-def` and `LowRes` has **no caller outside its own file**; the live path imports `lower` for `compile-fn` only (`compile-back.chiral:15`), so the four exclusions those functions name (dependent type, effectful, quantified binder, type does not lower) are **never produced by a real compile**. Full requirement text: `docs/arcs/enforcement-arc.md`. | `OURS`; ←E97, ←E157, ←E168 |

| E184 | lowering | design | **Attribution: every def's fate is stated by the compiler, with evidence, and checked.** A total fate function over every def in the compiler's closure, a closed sum with no `_` arm: `emitted <label>` / `specialized-into <names>` / `erased-by-design` / `skipped <reason>`, with `skipped`'s reason itself a closed sum carrying evidence (extern-with-no-wrapper, type-does-not-peel, callee-cascade), so E157's rule applies unchanged. `peel-def` stops returning `(Maybe NDef)`: `compile-front.chiral:203-210` drops a def with no record at all. `compile-all.chiral:34-38` stops discarding `skips` on the `elf-ok` arm. `prune-fix`'s transitive cascade (`compile-back.chiral:212`, record built at `compile-back.chiral:210` in `prune-pass`) resolves to a non-cascade root, in `skip-diag.chiral` beside E97's blame chain. Fates survive `specialize-singletons`' renaming (`compile-front.chiral:20`, `x64` becomes `x64$0`), which is the design fork: get it wrong and monomorphized singletons read as failures. Conservation is checked inside the compile, one fate per def, folding to the emitted set, with a report exit `bin/chirality` does not have and a gate on E168's floor. **Attribution is not measurable today:** five mechanisms decide a fate, three leave a record, all of it discarded on success. The one read-only probe died with the E166 C leg (`d8bcec5`, `d0c5dd5`) and was never legitimate, one formulation with two emitters. Measured 2026-09-01: `skip-reason` (`lib/lowering/upper/lower.chiral:83-93`) with `eligible?`/`lower-all`/`lower-def`/`LowRes` has no caller outside its own file, so its four exclusions never occur in a real compile. ~150-250 LOC, five modules, three signature changes, full BUILD RULE. **Pipeline: yes.** Minted 2026-09-01; full text in `docs/arcs/enforcement-arc.md`. | ←E97, ←E157, ←E168 |


#### The seven requirements

**R1. A total fate function.** Every def in the compiler's closure maps to exactly
one fate. Closed sum, no `_` arm. Arms: `emitted <label>`; `specialized-into
<names>`, because `specialize-singletons` rewrites rather than drops;
`erased-by-design`, for the type-level defs `filter-erasable` is supposed to
remove; `skipped <reason>`. The `erased-by-design` arm is required rather than
optional: a type-level def is not a failed lowering, and without that arm every
ratio built on the fates is noise.

**R2. Reasons carry evidence, not strings.** `skipped`'s reason is itself a closed
sum: extern-with-no-wrapper naming the op; type-does-not-peel naming which type and
where; callee-cascade naming the chain. E157's rule applies unchanged, and a
`str-cat`'d sentence here reintroduces what E157 removed.

**R3. `peel-def` stops returning `(Maybe NDef)`.** `compile-front.chiral:203-210`
drops a def by returning `(none)` and keeps no record at all. It becomes a result
sum. This is the only one of the five mechanisms that leaves no trace, so nothing
downstream can recover it.

**R4. The record survives success.** `compile-all.chiral:34-38` discards the
`skips` list on the `elf-ok` arm, so it surfaces only on an emit failure. Fates
must return on success.

**R5. The cascade is rooted.** `prune-fix` (`compile-back.chiral:212`) is
transitive, and the cascade record is built at `compile-back.chiral:210`, in
`prune-pass`. "Dropped because callee X was dropped" is a pointer rather than an
attribution. Every chain resolves to a non-cascade root. `skip-diag.chiral`
already carries E97's blame chain as the existing shape, which is why it is the
right home.

**R6. Fates survive a renaming.** `specialize-singletons`
(`compile-front.chiral:20`) runs before peel and changes a def's identity: `x64`
becomes `x64$0`, `x64$1` and so on. Fates are therefore a relation across a
renaming, and the rename mapping has to be produced by the pass that performs it
and carried the rest of the way. This is the design fork in the element. Get it
wrong and monomorphized singletons read as failures, which is exactly the
misreading that made the earlier measurement worthless. The pre-run may recommend
splitting R6 into its own element; if it does, that split mints its rows in the
same change.

**R7. Conservation, checked inside the compile, plus an exit.** The fates
partition the closure's def set: exactly one per def, and folding them reproduces
the emitted set. A def with no fate, or with two, fails the compile. That is the
line between attribution and logging. `bin/chirality` has compile / run / check /
test and no exit for the report, so one is owed, and the gate that reads it is a
chirality program on E168's test floor rather than a shell script.

#### Cost

Roughly 150 to 250 LOC across five modules. Three signature changes: `peel-def`,
`specialize-singletons` emitting its rename relation, and `compile-all` threading
fates. Plus build-new → test → promote with the fixpoint verified and the Step-0
precondition checked first. **Needs the full pipeline** (worked example → audit →
SPEC → audit → implement): the fate taxonomy is a taxonomy, and R6 is a genuine
fork.

#### Why the element exists

Attribution is not measurable today. Five mechanisms determine a def's fate and
only three leave a record, all of it discarded on success.

The one read-only probe, compiling through the E166 `Mach`→C leg and joining
mangled C symbol names back to def names, is gone with that leg (`d8bcec5`,
`d0c5dd5`), and was never legitimate anyway: it shared `compile-front` and
`compile-back` whole and differed only at emit, which is one formulation with two
emitters, the shape `docs/decisions/decision-self-verification.md` §0 explicitly
rules out.

Also recorded, measured 2026-09-01: `skip-reason`
(`lib/lowering/upper/lower.chiral:83-93`) together with `eligible?`, `lower-all`,
`lower-def` and `LowRes` have **no caller outside their own file**. The live path
imports `lower` for `compile-fn` only (`compile-back.chiral:15`). So the four
exclusions those functions name (dependent type, effectful, quantified binder,
type does not lower) are **never produced by a real compile**.

## The typed-assembly floor: built, and adopted at one point only

[[goals/enforcement]] states the gap in its own State list: the typed-assembly
floor is built and unadopted, and neither the floor checker nor the optimizer's
re-check runs in the shipping compile. These four elements are that sentence,
and they are the reason it is true. Every count below was measured 2026-09-02 by
grepping `(import "<key>")` over `lib/` and `prog/` and by walking the transitive
import closure of `prog/compiler.prog`, which is 50 modules.

### E16

| E16 | **Lowering: pure→tal, register/slot alloc, non-tail case outlining, preserve-check** | Three of the four deliverables are built and the fourth never runs. `lib/lowering/upper/lower.chiral` (407 L) is inside the compiler's closure and `lib/lowering/compile-back.chiral` imports it for `compile-fn`, which makes E16 the one element of these four on the live path. The preserve-check has no call site: `ck-prog` lives in `lib/lowering/tal/check.chiral` and is called nowhere in `lib/` or `prog/`; `lower.chiral` imports `prelude/prelude` and `lowering/tal/ssa` and nothing further; `compile-back.chiral` imports `lowering/tal/check` at no line. The two comments that name the check (`lib/lowering/upper/lower.chiral:20`, `:115`) say an emitted `TFn` would reach `ck-prog` with no conversion. That is a fact about the IR and is no evidence of a call. The check stays in E16's scope as its remaining work. | `OURS`; SSA/reg-alloc (Cooper–Torczon) (`PAPER`) |

| E16 | lower | built | **Lowering: pure→tal, reg/slot alloc, preserve-check.** Three of four deliverables. The lowering runs on every compile; the preserve-check in the element's own title runs on nothing, because `ck-prog` has no caller and `compile-back.chiral` never imports the module that defines it. Building it is the enforcement content of this row, and E70 carries the effect-side twin. | ←E18, →E70 |

### E17

| E17 | **Optimizer: const-fold, DCE, specialize/partial-eval/pregen** | Built and unreached. `lib/lowering/upper/optimize.chiral` (254 L) has zero importers across `lib/` and `prog/` and sits outside the compiler's closure, so no program in this tree is optimized by it. It is one of the two importers of `lowering/tal/check`, which is the mechanism by which the optimizer's re-check stays unrun: the re-check is written, and the module holding it is dead. | partial evaluation (Jones–Gomard–Sestoft) (`PAPER`) |

| E17 | optimize | built | **Optimizer: const-fold, DCE, specialize/pregen.** 254 L, zero importers, outside the compiler blob. The optimizer's re-check over tal is written inside a module nothing loads. ⚑ The ledger's state cell files E17 `built`, and built here means present on disk. | ←E18 |

### E18

| E18 | **TAL checker + reference tal interpreter** | Split three ways, one part reached. `lib/lowering/tal/ir.chiral` (49 L) is built and inside the compiler's closure, with six importers: `lowering/mach/emit-core`, `lowering/tal/bytes`, `lowering/tal/reify`, `lowering/tal/sys-check`, `lowering/tal/sys-linkage`, `lowering/tal/sys`. The checker `lib/lowering/tal/check.chiral` (246 L) has two importers, `lowering/upper/optimize` with zero importers of its own and `lowering/upper/eff-lower` with one, `lib/module/sig-driver.chiral`, which itself has zero importers. The reference interpreter `lib/lowering/tal/eval.chiral` (187 L) has none. Everything except the IR is outside the compiler's closure. ⚑ The catalog's earlier wording said both importers of `check` were themselves unimported, and that is stale: `eff-lower` has an importer now, and the conclusion survives because that importer is itself dead. | Typed Assembly (Morrisett et al.) (`PAPER`) |

| E18 | tal | built | **TAL checker + reference tal interpreter.** The IR is reached (49 L, six importers, in the blob); the checker (246 L) and the reference interpreter (187 L) are outside the blob and run on nothing. Adopting the checker is what closes the goal's floor-is-unadopted bullet, and it is the same call site E16 owes. | →E16, ←E70 |

### E70

| E70 | **Effectful lowering: the effect row's tal shadow plus a preserve-check over the effect claim** | Design. Unbuilt, and gated on `decision-effect-facets` (edge 16). This is the second preserve-check in the arc and the harder one: E16's check is over types the lowering already carries, while this one is over the effect claim, which `lib/lowering/upper/eff-lower.chiral` (183 L) models and no module inside the compiler's closure reads. Making `=>` arrows lowerable is the precondition for self-hosting going native, because the compiler is itself effectful. | `OURS` (`lib/lowering/upper/lower.chiral`, `lib/lowering/upper/eff-lower.chiral`) plus the effect-facets decision |

| E70 | lower-reach | design | **Effectful lowering: effect-row tal shadow + preserve-check over the effect claim.** Gated on `decision-effect-facets` (edge 16). The effect-side twin of E16's unrun check. | ←E16, ←E12 |

## Numbering

E184 is the **first element minted for this arc**. The highest previously minted element was
**E183**. Lane A mints in **E184–E189**, Lane B in **E190–E195** (`docs/decisions/decision-lane-split.md`).
A new element's row lands in `docs/examples/INDEX.md` **and here** in the same
change: those are the only two tracked places, and therefore the only collision
detectors that exist.
