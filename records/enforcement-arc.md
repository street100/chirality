---
node: records-enforcement-arc
layer: navigation
related: [records/README, status-ledger, arcs/enforcement-arc, arcs/diagnostics-arc, index]
status: current
updated: 2026-09-01
---

# Enforcement arc

Every row is a claim this repo makes about what its compiler enforces and what it
can measure about its own work, beside what was actually observed.

Row format, states and the rules for adding, changing and retiring a row are in
[[records/README]]. Prefix is `EN`.

The arc's element rows live in [[arcs/enforcement-arc]]. Its reserved element block is
Lane A's `E184-E189` (`docs/decisions/decision-lane-split.md`), of which `E184` is minted.

One note on state. [[records/README]] has four states and none of them means
"the claim reproduced exactly and there is nothing to do". EN-06 is that case and
is filed `FIXED`, with the reason written into its `measured` line. A fifth state
is an author call, and the README says so.

Everything below was measured on 2026-09-01. Re-run a row's evidence before
relying on it.

## What is measurable about lowering

### EN-01 the lowered/skipped ratio is unmeasured, and `skip-reason` is not the mechanism

- state:    OPEN
- claim:    `records/lane-a-record.md` says a large fragment of the language never lowers, and that the lowered/skipped ratio is unmeasured.
- measured: `skip-reason` has no caller. It, `eligible?`, `lower-all`, `lower-def` and `LowRes` are referenced nowhere outside `lib/lowering/upper/lower.chiral`; the live path imports `lower` for `compile-fn` only. So the four exclusions those functions name (dependent type, effectful, quantified binder, type does not lower) are never produced by a real compile. The actual drop points are `compile-fn`'s `le-skip` (`compile-back.chiral:238-239`), `filter-erasable` (`:190`), `prune-fix`'s cascade (`:210`), and `peel-globals`' silent `(none)` (`compile-front.chiral:203-210`). Of those four, only the first three record anything, and `compile-all.chiral:34-38` discards even that on the `elf-ok` arm. Attribution is not measurable today.
- evidence: `lib/lowering/upper/lower.chiral:83-93`, `lib/lowering/compile-back.chiral:15`, `:190`, `:210`, `:238-239`, `lib/lowering/compile-front.chiral:203-210`, `lib/lowering/compile-all.chiral:34-38`
- checked:  2026-09-01
- element:  E184

## Citations that moved or were miscounted

### EN-02 `optimize.chiral:250` is not the only `ck-fn` call site

- state:    OPEN
- claim:    `records/lane-a-record.md:149` says `lowering/upper/optimize` "holds the only `ck-fn` call in the tree, at `:250`".
- measured: REFUTED as stated. A second call sits inside `check.chiral` itself, in `ck-fns`, which `ck-prog` folds over the program. So `check.chiral` is the defining module and it calls its own `ck-fn`. The corrected claim is that `optimize.chiral:250` is the only call site outside `check.chiral`. The downstream conclusion survives unchanged: nothing on the compile path calls `ck-fn`.
- evidence: `lib/lowering/upper/optimize.chiral:250`, `lib/lowering/tal/check.chiral:223-224`, `:233-239`, `:242-246`
- checked:  2026-09-01
- element:  none

### EN-03 the `Judg` and `Reason` line ranges are two lines off

- state:    OPEN
- claim:    `Judg` is declared at `diag.chiral:97-110` and `Reason` at `:120-137`, with 38 constructors and 9 reasons. Repeated in three places.
- measured: the line ranges are REFUTED. `(data Judg ()` opens at `:99` and closes at `:112`; `(data Reason ()` opens at `:122` and closes at `:140`. Line 97 is prose in the preceding comment and line 120 is blank. The counts are CONFIRMED: 38 `Judg` constructors and 9 `Reason` shapes. This is BA-13's class, a citation that a later insertion moved, and it has been copied forward into three documents.
- evidence: `lib/typing/diag.chiral:99-112`, `:122-140`, `docs/definitions/bug-classes.md:109`, `records/lane-a-record.md:176`
- checked:  2026-09-01
- element:  none

### EN-04 the compile-only verdict line is at `:298`, not `:280`

- state:    OPEN
- claim:    two documents cite `tools/test/run-tests.sh:280` as the line printing `compile-only: N roots built, N failed -- gates, but asserts nothing`.
- measured: REFUTED. That line is `:298`. Line `:280` is the `run_phase 18` call for the term-printer gate. The quoted text is correct and only the citation is wrong, so this is the same class as EN-03. The 88 roots the claim was measured against were correct at the time; master now reports 87, after the C-leg fixture drop.
- evidence: `tools/test/run-tests.sh:280`, `:298`, `docs/definitions/bug-classes.md:155`, `records/lane-a-record.md:191`
- checked:  2026-09-01
- element:  none

## Numbers that need their definition stated

### EN-05 the zero-importer count is definition-dependent and the definition is not stated

- state:    OPEN
- claim:    `records/lane-a-record.md:144` records 18 zero-importer modules in `lib/`, 2,086 LOC.
- measured: CONFIRMED, but only under the definition where an importer is a file under `lib/` or `prog/`. Counting importers within `lib/` alone gives 27 modules and 4,769 LOC. Counting importers anywhere in the repo gives 17 modules and 1,828 LOC, the one-module difference being `protocol/render-doc`, whose sole importer is `tools/test/samples/e158_render.prog`. Three defensible definitions, three different numbers, and the figure is quoted without the one it used. State the definition wherever the number is used.
- evidence: `records/lane-a-record.md:144`, `lib/protocol/render-doc.chiral`, `tools/test/samples/e158_render.prog`
- checked:  2026-09-01
- element:  none

### EN-06 the closure and outside-closure figures reproduce exactly

- state:    FIXED
- claim:    `records/lane-a-record.md:141-143` and `docs/decisions/decision-scope.md`:68-69` say the compiler's closure is 59 modules / 16,463 LOC, `lib/` is 103 modules / 25,559 LOC, and ten checking-machinery modules totalling 1,680 LOC sit outside the closure.
- measured: CONFIRMED exact. Every module count and every LOC figure reproduces, including the per-module breakdown of the ten. Neither side moved, because neither side was wrong; the row is filed `FIXED` because the four states carry no value for a claim that reproduced, and minting a fifth is an author call. For context the full outside-closure set is 46 modules / 9,178 LOC, of which the 1,680 is the checking-machinery part.
- evidence: `records/lane-a-record.md:141-143`, `docs/decisions/decision-scope.md`:68-69`, `docs/definitions/bug-classes.md:145`
- checked:  2026-09-01
- element:  none

## Withdrawn

### EN-07 the 96.4% emitted-def figure is withdrawn and must not be cited

- state:    RETIRED
- claim:    1,352 of 1,402 defs reach the emitted image (96.4%), with 44 of the 50 absences being monomorphized singletons and six genuine (`filter`, `foldl`, `foldr`, `find`, `any-list`, `m-fold`).
- measured: WITHDRAWN. The figure was obtained by compiling through the E166 `Mach`→C leg and joining mangled C symbol names back to def names. The method is not legitimate: that leg shared `compile-front` and `compile-back` whole with the canonical instance and differed only at emit, which is one formulation with two emitters, the shape `docs/decisions/decision-self-verification.md` §0 rules out. It is also no longer reproducible, the leg having been dropped at `d8bcec5` with its fixtures at `d0c5dd5`. Do not cite this figure. The real number is unknown until E184.
- evidence: commits `d8bcec5`, `d0c5dd5`, `docs/decisions/decision-self-verification.md:16-21`
- checked:  2026-09-01
- element:  E184
