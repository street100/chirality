---
node: arc-enforcement
layer: navigation
related: [arcs/README, goals/enforcement, status-ledger, arcs/diagnostics-arc, records/enforcement-arc, decisions/decision-erased-word-level, index]
status: current
updated: 2026-09-04
---

# Arc: enforcement

- goal: [[goals/enforcement]]
- reserved element block: `E184-E189`, shared with [[arcs/diagnostics-arc]] (`docs/decisions/decision-lane-split.md`, Lane A)
- checklist: [[records/enforcement-arc]]
- build-state authority: [[status-ledger]]

**This file is TRACKED for the same reason [[diagnostics-arc]] is.** ⚑ **The
reason stated here until 2026-09-04 was false twice over:** the catalog and the
ledger are tracked at `docs/elements/`, and `.gitignore:12` is `.claude/*`, so
`.planning/` was never the exclusion this paragraph named. `.planning/` has been
tracked since 2026-09-01 (`docs/decisions/decision-ai-tier.md`). What survives is
the real reason, which `docs/arcs/README.md` states: two sessions minted `E173`
independently and nothing caught it until a merge put both INDEX rows side by
side. An element fact anyone else needs lives here.

The arc's subject is enforcement: a claim the compiler makes about its own work,
carried as a value, with evidence, and refused when it does not hold. E184,
E185, E186, E187 and E188 are minted for it, and four older catalog rows belong
to it: E16, E17, E18 and E70.

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
   waits on **E185** being built, since the compiler would refuse its own four
   `$apply` dispatchers. EN-15 is answered:
   [[decisions/decision-erased-word-level]] puts the erased-word type strictly at
   the lowering type level, leaves `Core` without a word spelling and leaves the
   kernel's `conv` relation alone. What is left is the spelling of the erased
   position, which is E185's whole subject and needs the full pipeline.
   E16's title names the preserve-check and three of its four
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
   **1,477 of 1,481**. ⚑ The four `$apply` dispatchers remain, and EN-15 is
   **answered 2026-09-04**: [[decisions/decision-erased-word-level]] settles the
   level. Their spelling is **E185**, minted the same day and unbuilt.

   ⚑ **The requirement has a second half nothing measured until 2026-09-04.**
   Agreement runs both ways, and [[records/enforcement-arc]] EN-20 measures a
   case where the check agrees with a compiler that is wrong. `arm-body`'s
   `(none)` arm emits the literal `0` as a whole function body; when the
   family's codomain is ground, `const 0` matches the declared return, `ck-prog`
   accepts, and the wrong code passes. The two instances in the compiler's own
   blob redden only because their codomain is `(List Asm)`. So the 1,477-of-1,481
   figure above measures the checker agreeing with the compiler and says nothing
   about either being right. **E188** owns that defect. The requirement stands as
   written.
4. **The optimizer's re-check runs, or E17 says why it does not.**
   `lib/lowering/upper/optimize.chiral` has zero importers and is in no blob, so
   `optimize` and `specialize` return a `Checked` result nothing ever forms.
5. **Chirality's own tooling is chirality's.** Measured 2026-09-04: **12,450
   lines outside the language** against **782 native**, every `.prog` file:
   `prose-lint` 256, `paren-audit` 244, `test-runner` 134, `resolve` 104,
   `wield` 44. The **390** this requirement carried until 2026-09-04 was
   `test-runner` plus `prose-lint` and omitted the other three.

   ⚑ **782 is the worse reading. 390 was the flattering one.** The two entries
   the 390 counted are the two entries anything reaches. `grep -rIn` over
   `tools/` and `bin/` finds no shell file, gate phase or CLI subcommand
   invoking `paren-audit.prog`, `resolve.prog` or `wield.prog`, so **392 of the
   782 sits at SEEDED**. TC-03 and TC-04 in [[records/tooling-classification]]
   carry the two whose replaced predecessor is still live beside them.

   The surface is the gate tier at 6,915 lines of shell,
   `tools/prose-lint/prose-lint.sh` at 223 with awk doing the matching, nine
   Python tools at 4,786, and `bin/chirality` plus `bin/chirality-resolve.sh` at
   526. Within the gate tier alone `grep`, `sed`, `sort` and `awk` run as **240
   invocations**, of which **30 are ones where `docs/arcs/text-tools-arc.md`
   records a built chirality composition**. The other 210 are judgments and wait
   on [[arcs/independent-judgment-arc]] J1, the distinctness criterion, which is
   rowed there as not started (TC-12).

   ⚑ **The 352 this requirement carried until 2026-09-04 was a word-occurrence
   count, presented as a call count with a composition behind every one.**
   `grep -ohE '\bgrep\b' tools/test/*.sh` and its three siblings return 149,
   100, 22 and 81, summing to exactly 352 at `acc70d6`. The occurrences include
   comments, the scratch filenames `g5.awk` and `g9.awk`, and the prose in
   `tools/test/matcher.sh` naming the tool the native matcher is graded against.
   TC-02.

   `lib/text/matcher.chiral` has one consumer.

   ⚑ **Some of it is correct and stays.** A comparator holding constants cannot
   be fooled by a mutated compiler, which is why `crypto.sh` prints from the
   fixture and compares in bash, and why `mutant.sh` substitutes in pure
   parameter expansion. Over-claiming that bucket replaces a safety property
   with a dependency. What is owed is the work a composition already covers.

   ⚑ **The reason is the OS rung rather than the gate.** Every classic tool
   that becomes a composition is one fewer thing an operating system written in
   this language has to trust, and a resolver and a text tool are needed long
   before a test harness is. Taking the ground now is cheaper than migrating a
   coreutils dependency later. `records/gate-audit.md` holds the measurement;
   `docs/arcs/text-tools-arc.md` holds the coverage table.

6. **Every gate row names a mutant that is actually run.** Inherited from
   [[goals/enforcement]] and from `docs/definitions/testing-floors.md:261`. E173
   found two rows that could not fail; both were repaired at `e882568`.

⚑ Requirement 3 is the one that gates the rest. E16's scope and E18's both
stop short of it as written, so no element owns it.

## Resume state

**2026-09-04: requirement 5 is first priority by author direction**, and
`.planning/HANDOFF-2026-09-04.md` carries the full queue. The gate tier is
6,915 lines of shell against `prog/test-runner.prog` at 134 lines, the only
native part of that floor, with 240 invocations of the four classic tools
across it and a built composition behind 30 of them. Every tool that moves is one fewer the OS
rung has to trust.

**Requirement 3 is closed and requirement 2 is the live one.** 2026-09-03 ran
the diagnosis (EN-08 to EN-13), the author's ruling, both checker repairs with
Phase 22 gating them (`ddfbc27`), and the erased-binder fix with a promoted
fixpoint (`40e8726`). Suite 339 passed, 0 failed, 87 roots, gate PASSED.

Four things are owed, and they are independent of each other. **The eleven name
collisions** make `lowering/tal/check` unimportable beside the compiler, which
blocks requirement 2 and requirement 4 alike; resolving them is mechanical and
cascades into `tools/test/diag.sh:256` and seven sha256-pinned gate scripts.
**E185** is the second: EN-15 was answered 2026-09-04 and
[[decisions/decision-erased-word-level]] settles the level, so what stands
between the four `$apply` dispatchers and a live refusal is an unbuilt element
needing the full pipeline. It gates the moment the refusal goes live rather
than the plumbing. The refuse-or-carry ruling in [[records/author-calls]] is a
third and separate call, and **EN-17** is a fourth, opened 2026-09-04: the
`$kI_J` capture constructor's field types are their own author call, since
research §7 finds the prior art keeping constructor fields concrete.
[[records/enforcement-arc]] EN-17 and its row in [[records/author-calls]] both
hold that `ck-prog` cannot refuse on the shipping path while that instance
stands, so requirement 2 carries it alongside E185.

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

The diagnosis slice for the four classes ran 2026-09-03, EN-08 to EN-13. What is
still owed before any of this lands is the refuse-or-carry ruling, which is the
author's.

[[arcs/display-calculus-arc]]'s resume state names a further item on this
requirement's surface: `tools/pack/pack.py`'s prefix gate has no adapter and
no `--mark` path for that arc's rows, so its pipeline has no deterministic
finish on a PASS.

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

### E185

| E185 | **How the `$apply` dispatcher's erased domains are spelled at the lowering type level** | Not built. Minted 2026-09-04. The level is settled and the spelling is open. [[decisions/decision-erased-word-level]] rules that the erased-word type lives strictly at the lowering type level, that `Core` gains no word spelling, and that the kernel's `conv` relation is left alone. What stays open is the SHAPE of the erased position, and [[records/enforcement-arc]] EN-15 is the measurement that stops without it: `apply-ty` spells the dispatcher's domains with one defunctionalization family member's concrete `Core` types (`lib/lowering/upper/closconv.chiral:1081-1083`), reached from `lib/lowering/upper/closconv-driver.chiral:175`, so four dispatchers carry a tal type their own arms contradict and `ck-prog` is right to refuse them. **Two candidates, and `.planning/RESEARCH-EN15-prior-art.md` §6 measures the prior art as split between them.** **(a) A quantified type variable**, with the concrete types on the constructor: Pottier and Gauthier's specialized `apply`, TAL's abstract `α` in a register-file type, TALx86's `∀α:T4`. **(b) A coarse word type of the lower language**, related by subtyping: Java's `Object`, the JVM verifier's `oneWord`, MLton's `RepType` with `isSubtype`. The tree already reaches `tt-word` from a type variable, because `term->ntalty` maps `(t-var i)` to `(nt-word)` at `lib/lowering/compile-front.chiral:70` under the comment *"B1: an erased type variable in a KEPT position"*. That is an observation about machinery that exists, and it settles nothing. **What it touches:** `apply-ty` and its one call site, plus the peel in `lib/lowering/compile-front.chiral`. All of it is compiler source inside the blob, so the full BUILD RULE applies: `build-new → test → promote` with the fixpoint verified and the Step-0 precondition checked first. **Needs the full pipeline** (worked example → audit → SPEC → audit → implement), because the spelling is a genuine choice between shapes the codebase does not settle. **What it closes.** The arc's requirement 2, wiring `ck-prog` onto the shipping path, is what EN-15 blocks today, and this element is what unblocks it. **What it leaves.** [[records/enforcement-arc]] EN-17, the `$kI_J` capture constructor's field types, is a separate author call and stays open: research §7 shows the prior art keeping constructor fields concrete, so the two instances may take different answers. ⚑ **The scope of that sentence is corrected 2026-09-04 by [[records/enforcement-arc]] EN-20.** What EN-15 measured is no miscompile: every one of these values is one word at runtime, the emitted code is correct, and the defect is the type the IR carries. What the sentence over-claimed is the rest of the pass. `arm-body` (`lib/lowering/upper/closconv.chiral:1051-1058`) has one arm for a site whose `def-ctx` fails, and that arm emits the literal `0` as a whole function body. EN-20 demonstrates the wrong value end to end on today's binary, and the arm is reached twice in the compiler's own blob. That defect is **E188** and it leaves E185's spelling question untouched. | `OURS`; ←E16, ←E18 |

| E185 | lowering | design | **How the `$apply` dispatcher's erased domains are spelled at the lowering type level.** The level is settled by [[decisions/decision-erased-word-level]]: the erased-word type lives strictly at the lowering type level, `Core` gains no word spelling, and the kernel's `conv` relation is left alone. The spelling is open, and the prior art splits (`.planning/RESEARCH-EN15-prior-art.md` §6): a quantified type variable with the concrete types on the constructor (Pottier and Gauthier, TAL's abstract `α`, TALx86's `∀α:T4`), against a coarse word type of the lower language related by subtyping (Java's `Object`, the JVM verifier's `oneWord`, MLton's `RepType`). `term->ntalty` already maps `(t-var i)` to `(nt-word)` at `lib/lowering/compile-front.chiral:70`, which is an observation and not a decision. Touches `apply-ty` (`lib/lowering/upper/closconv.chiral:1081-1083`), its call site (`lib/lowering/upper/closconv-driver.chiral:175`) and the peel, all compiler source, so the full BUILD RULE applies with the fixpoint verified. **Pipeline: yes.** Closing it unblocks the arc's requirement 2, `ck-prog` on the shipping path. It leaves EN-17, the `$kI_J` capture constructor's field types, which is a separate author call. Minted 2026-09-04; full text in `docs/arcs/enforcement-arc.md`. | ←E16, ←E18 |

### E186

| E186 | **The `$k<i>_<j>` capture constructor's field types: concrete, or the erased word** | Not built. Minted 2026-09-04 by E185's SPEC run, from [[records/enforcement-arc]] EN-17, and the author call EN-17 holds is what this element carries. [[decisions/decision-erased-word-level]] settles where the erased-word type lives and reaches the `$apply` dispatcher's domains only; the capture constructor's fields are a second instance and the prior art answers them the other way. `.planning/RESEARCH-EN15-prior-art.md` §7: Pottier and Gauthier's `succ : Arrow int int` carries concrete field types beside concrete arrow indices, Minamide, Morrisett and Harper hide a heterogeneous environment behind `∃` with the fields concrete inside the pack, and Huang and Yallop's label-context entry keeps the captures at their source types. The structural reason the two instances differ: a capture constructor, spelled by `ctor-name` (`lib/lowering/upper/closconv.chiral:1114`), is applied at exactly one site, its own definition site, so nothing forces its field types to merge, while the shared dispatcher's argument position is constrained by every member of the family at once. ⚑ **E185 does not decide this and does not wait on it.** E185 states the dispatcher's parameter types as the erased word, which makes `$apply7`'s field check in `ck-con` (`lib/lowering/tal/check.chiral:183-196`) pass on the parameter side while the constructor's declared fields stay concrete, so the four dispatchers go green with this question still open. What stays open is whether the fields themselves erase. **The author call comes first** and the pipeline follows it, which is why the element is minted rather than scheduled. ⚑ **The scope of that sentence is corrected 2026-09-04 by [[records/enforcement-arc]] EN-20.** The field-type defect this row carries is no miscompile, for EN-15's reason: every one of these values is one word at runtime and the emitted code is correct. The wider reading, that the `$apply` machinery emits correct code, is false. `arm-body`'s unreachable arm is reached and emits the literal `0` as a whole function body (`lib/lowering/upper/closconv.chiral:1051-1058`), which is **E188**. | `OURS`; ←E185, ←E18 |

| E186 | lowering | design | **The `$k<i>_<j>` capture constructor's field types: concrete, or the erased word.** EN-17 turned from an author call into an element by E185's SPEC run. The 2026-09-04 ruling settles the dispatcher's domains and does not reach the capture constructor, and `.planning/RESEARCH-EN15-prior-art.md` §7 finds both published answers keeping constructor fields CONCRETE. The structural reason: a capture constructor (`ctor-name`, `lib/lowering/upper/closconv.chiral:1114`) is applied at one site, so nothing forces its fields to merge, while the dispatcher's argument position is constrained by the whole family. E185 goes green without this: stating the dispatcher's parameters as the erased word makes `$apply7`'s `ck-con` field check pass on the parameter side with the fields left concrete. **The author call comes first.** Minted 2026-09-04; full text in `docs/arcs/enforcement-arc.md`. | ←E185, ←E18 |

#### Why it is separate from E185

One ruling covering both instances would prejudge the second. The dispatcher's
argument position is constrained by every member of its family at once, so it is
the varying side and the erased word is the honest spelling. A capture
constructor is applied at one site only, so it is the concrete side, and every
system in `.planning/RESEARCH-EN15-prior-art.md` §7 keeps it concrete. The
measured `$apply7` rejection is the opposite arrangement to that reading, which
is exactly why the question is open rather than settled by analogy.

#### What it does not block

E185. Stating a dispatcher's parameter types as the erased word makes the
parameter side of `ck-con`'s field check pass, because `tal-ty=?`
(`lib/lowering/tal/check.chiral:68-70`) has the erased word matching everything.
The constructor's declared fields are untouched by E185 and stay concrete. So the
four dispatchers accept with EN-17 still open, and what EN-17 blocks is the
question of whether the fields are honest, not whether the dispatchers are.

### E187

| E187 | **`closconv` states the lowering-level type of every name it invents** | Not built. Minted 2026-09-04 by E185's SPEC run, and it is the generalization E185's channel makes cheap. `closconv` invents three name families and not one of them has a source type: `$clo<i>` (`lib/lowering/upper/closconv.chiral:1112`), `$apply<i>` (`:1113`) and `$k<i>_<j>` (`:1114`). They exist because the pass made them, and the pass is the only thing in the tree that knows the erasure it performed. E185 builds the stated-parameter channel from `closconv-sig` to the bridge and populates it for `$apply<i>` alone; this element extends it to the other two and writes the pass's translation down, so a reader meets ⟦·⟧ stated rather than reconstructed from `shape-eq` (`:335-356`) and `cod-key-eq` (`:365-380`). It also retires E185's residue: `apply-ty` (`:1096-1098`) still spells the dispatcher's domains from one family member, read after E185 for the codomain and the erased vector only, and an annotation nothing reads still drifts. The constructor half is gated on E186's ruling, and the `$clo<i>` half runs through a second path the `NDef` channel does not reach, `field-tys->n` and `datas->n` (`lib/lowering/compile-front.chiral:238-261`). ⚑ **Measured 2026-09-04:** after E185 lands, 1,820 lines of live rewriting in `lib/lowering/upper/` still say nothing at the lowering type level (`closconv` 1332, `closconv-driver` 256, `specialize-singleton` 232), and the three modules there that do speak tal are off the live path or have no caller. All compiler source inside the blob, so the full BUILD RULE applies: `build-new → test → promote` with the fixpoint verified and the Step-0 precondition checked first. **Needs the full pipeline.** | `OURS`; ←E185, ←E186 |

| E187 | lowering | design | **`closconv` states the lowering-level type of every name it invents.** Three invented name families with no source type: `$clo<i>`, `$apply<i>` and `$k<i>_<j>` (`lib/lowering/upper/closconv.chiral:1112-1114`). E185 builds the stated-parameter channel and populates it for `$apply<i>`; this extends it to the other two and writes ⟦·⟧ down instead of leaving it to be reconstructed from `shape-eq` and `cod-key-eq`. It retires E185's residue, the `Core` domains `apply-ty` still spells from one family member. The constructor half waits on E186; the `$clo<i>` half runs through `field-tys->n` / `datas->n`, a path the `NDef` channel does not reach. After E185, 1,820 lines of live rewriting in `lib/lowering/upper/` still state nothing at the lowering type level. Compiler source, full BUILD RULE. **Pipeline: yes.** Minted 2026-09-04; full text in `docs/arcs/enforcement-arc.md`. | ←E185, ←E186 |

#### Why it is separate from E185, given that E185's SPEC picks the stated form

E185's SPEC resolves the spelling fork to the lowering-level statement, which is
the mechanism this element generalizes, so the two partly merge and the cut is
stated rather than assumed. **E185 builds the channel and populates it for one
name.** That is one function, one call site, one probe figure, and it is what
requirement 2 waits on. **E187 populates the channel for the other two names and
states the translation.** The `$clo<i>` half is not the same work: a data
declaration reaches the bridge through `field-tys->n` and `datas->n`
(`lib/lowering/compile-front.chiral:238-261`), which the `NDef` channel does not
touch, and the constructor half waits on E186's ruling. Folding all of it into
E185 would put an unanswered author call inside the element that unblocks
requirement 2.

### E188

| E188 | **`arm-body`'s unreachable arm is reached, and an `$apply` arm returns a literal `0` as a whole function body** | Not built. Minted 2026-09-04 from [[records/enforcement-arc]] EN-20, and it is the first live wrong-code defect this arc has measured in the shipping compiler. **The defect.** `def-ctx` (`lib/lowering/upper/closconv.chiral:582-596`) returns `(none)` for a defunctionalization site whose `peel-lam-exact` fails, which is any curried projector whose type peels deeper than its body is `lam`s. `arm-body` (`:1051-1058`) has exactly one arm for that case, the `(none)` arm at `:1057` carrying the comment `unreachable: g always has a def-ctx`, and it emits `(c-lit-i 0)` as the arm's whole body. It is reached twice in the compiler's own blob, at `mach-galo` and `mach-gbnw` (`lib/lowering/mach/mach.chiral:134-137`), which `alloc-growing` (`lib/memory/alloc-growing.chiral:18-24`) puts in value position: `$apply5`'s `$k5_8` arm and `$apply6`'s `$k6_3` arm are each two instructions, `const 0` then `ret`. **The demonstration.** EN-20 built a fixture of that shape outside `lib/` and `prog/`, compiled and ran it with today's binary, and got three lines: `direct box-f: 30`, `via $apply: 0`, `via $apply2: -10`. The same global is correct called directly and returns `0` through the dispatcher. **Three candidate fix shapes, and EN-20 picks none.** (a) `arm-body` builds the call spine `(g cap0..capk-1 arg0..argd-1)` from the site, which is correct without reading the body at all. (b) `def-ctx` eta-expands a body shallower than its type before peeling. (c) `collect` poisons the family when `def-ctx` fails, the mechanism `keep-fams` (`lib/lowering/upper/closconv-driver.chiral:96-106`) already runs for an unsaturated higher-order use, which turns wrong code into a named skip. ⚑ **Erasing the codomain would HIDE this defect.** `tal-ty=?`'s first arm makes `tt-word` match everything (`lib/lowering/tal/check.chiral:68-70`), so a `tt-word` return accepts `const 0` and the two red rows go green with the wrong code still emitted. That is the one repair shape ruled out in advance. ⚑ **`ck-prog` does not detect the general case, and the gate is the interesting part of this element.** The `ret` refusal reddens the compiler's two instances only because their family codomain happens to be `(List Asm)`. EN-20's fixture has an `I64` codomain, `const 0` matches the declared return, `ck-prog` accepts, and nothing anywhere reddens. A gate for E188 must therefore catch a body that returns a LITERAL where it should return a COMPUTATION, which is a value-level assertion the existing type-level check demonstrably cannot make. This row states that requirement and does not design the gate. ⚑ **Blast radius in this tree is zero today, and nothing measures that on purpose.** `compile-fn` skips `alloc-growing` and `mach-galo`, so no `$clo5` or `$clo6` con reaches any of the 1,484 TFns and the two dead dispatchers ride into the ELF uncalled. The same two sites appear in `prog/test-runner.prog`, `prog/wield.prog`, `prog/prose-lint.prog` and `prog/paren-audit.prog`. The suite's green line and the byte fixpoint witness none of it. **What it touches:** `arm-body`, `def-ctx` or `collect` depending on the shape chosen, all compiler source inside the blob, so the full BUILD RULE applies: `build-new → test → promote` with the fixpoint verified and the Step-0 precondition checked first. **Needs the full pipeline** (worked example → audit → SPEC → audit → implement), because three candidate shapes is a choice the codebase does not settle. | `OURS`; ←E185, ←E16 |

| E188 | lowering | design | **`arm-body`'s unreachable arm is reached, and an `$apply` arm returns a literal `0` as a whole function body.** Minted 2026-09-04 from [[records/enforcement-arc]] EN-20, the arc's first measured wrong-code defect in the shipping compiler. `def-ctx` (`lib/lowering/upper/closconv.chiral:582-596`) refuses a curried projector whose type peels deeper than its body, and `arm-body` (`:1051-1058`) answers that with `(c-lit-i 0)` under a comment reading `unreachable: g always has a def-ctx`. Reached twice in the compiler's own blob, `mach-galo` and `mach-gbnw`. EN-20's fixture on today's binary: `direct box-f: 30` against `via $apply: 0`. Three candidate shapes and none picked: build the call spine from the site, eta-expand a shallow body, or poison the family through `keep-fams`. Erasing the codomain would HIDE it, because `tal-ty=?`'s `tt-word` arm matches everything, and `ck-prog` misses the general case whenever the family codomain is ground, so the gate must assert the VALUE. Compiler source, full BUILD RULE. **Pipeline: yes.** Minted 2026-09-04; full text in `docs/arcs/enforcement-arc.md`. | ←E185, ←E16 |

#### Why it is separate from E185, E186 and E187

Those three state a TYPE. E188 is a wrong VALUE. `apply-ty`'s domains, the
`$k<i>_<j>` fields and the invented names all carry an annotation the emitted
code contradicts, and repairing the annotation moves no byte, which
`docs/elements/specs/E185-type-preserving-upper-SPEC.md` R6 pins as a control.
`arm-body`'s `(none)` arm emits a different instruction stream from the one the
site calls for, so no statement of a type repairs it. [[records/enforcement-arc]]
EN-19 reached the same conclusion from the other side: `cod-key-eq` was suspected
of merging two families and was cleared, and the residue was the code.

#### The gate this element owes, and why the existing one is not it

`ck-prog`'s `ret` check refuses `$apply5`'s and `$apply6`'s arms today. That is
luck. The refusal fires because those two families return `(List Asm)`, so
`const 0 : i64` disagrees with the declared return. EN-20's fixture has an `I64`
codomain, `const 0` agrees with the declared return, `ck-prog` accepts, and the
wrong code ships silently. A gate for E188 must assert the VALUE the dispatcher
produces on a fixture of the shallow-body shape, because the type-level check is
absent for the whole class of families whose codomain is ground. The requirement
is stated here and the gate is designed in the pipeline.

#### What it does not touch

The blast radius in this tree is zero today. `compile-fn` skips `alloc-growing`
and `mach-galo`, so the two bad dispatchers are dead code inside every blob that
carries them, and the byte fixpoint is undisturbed by both the defect and its
repair. Requirement 2 is unaffected: E185 is what stands between `ck-prog` and
the shipping path, and E188 is a defect `ck-prog` on the shipping path would
still miss.

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

E184 was the **first element minted for this arc** and **E185** is the second,
minted 2026-09-04. **E186 and E187** are the third and fourth, minted 2026-09-04
by E185's SPEC run, which is the stage that mints. **E188** is the fifth, minted
2026-09-04 from [[records/enforcement-arc]] EN-20. The highest previously minted
element was **E183**. Lane A mints in **E184–E189**, Lane B in **E190–E195**
(`docs/decisions/decision-lane-split.md`). **The next free number is `E189`**, the
last one in Lane A's band, and the band is shared with [[arcs/diagnostics-arc]].
A new element's row lands in `docs/examples/INDEX.md` **and here** in the same
change: those are the only two tracked places, and therefore the only collision
detectors that exist.
