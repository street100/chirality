---
node: records-enforcement-arc
layer: navigation
related: [records/README, status-ledger, arcs/enforcement-arc, arcs/diagnostics-arc, index]
status: current
updated: 2026-09-03
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

Rows EN-01 to EN-07 were measured on 2026-09-01 and EN-08 to EN-14 on
2026-09-03. Re-run a row's evidence before relying on it.

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

## The `ck-prog` disagreement, class by class

Measured 2026-09-03. Every count below came from one scratch probe, described in
EN-08 and reverted, and every claim is per-TFn.

### EN-08 the four diagnostic classes reproduce, and the instrument is a probe

- state:    OPEN
- claim:    [[arcs/enforcement-arc]] requirement 3 records `ck-prog` accepting 743 of 1,504 TFns and rejecting 761 (50.6%), in four classes: 392 `ret`, 187 `con`, 107 `case on non-data register`, 75 `argument arity`.
- measured: CONFIRMED in shape, with counts that moved with the tree. Today's compiler blob emits 1,481 TFns: 727 accept and 754 reject (50.9%), in the same four classes at 389 `ret`, 185 `con`, 105 `case on non-data register`, 75 `argument arity`. The delta traces to E182, which landed at `65bec90` and `d26d7a1` on 2026-09-02 over `lib/typing/diag.chiral` and `lib/typing/kernel.chiral`, both inside the compiler's closure. Method: a scratch probe living outside `lib/` and `prog/`, importing `lowering/compile-all`, re-running `lower-defs`' per-def loop over the `NDef` list `compile-front` produces, and folding a copy of `check.chiral` over every emitted TFn under the `CEnv` `ck-prog` rebuilds. The copy exists because `check.chiral` cannot be imported beside the compiler: E154's fifth instance, eleven colliding top-level names. Each name in the copy carries a prefix; every accept and reject decision is the original's, and only the verdict strings differ, plus `ck-args` returning a reason string where the original returns a `Bool`. The probe was reverted. The same source reaches a byte fixpoint the same day: `bin/chirality-bin` over the blob yields a 1,188,216-byte binary that reproduces itself byte for byte.
- evidence: `lib/lowering/tal/check.chiral:243-246`, `lib/lowering/compile-back.chiral:231-240`, `lib/lowering/compile-all.chiral:18-33`, commits `65bec90`, `d26d7a1`, `docs/definitions/working-discipline.md:30-38`
- checked:  2026-09-03
- element:  none

### EN-09 the `ret` class is the checker: an erased type-argument list, 389 of 389

- state:    OPEN
- claim:    requirement 3 counts the `ret` class and leaves the side that is wrong unnamed.
- measured: THE CHECKER, in all 389, and the shape is uniform. Every one is `tt-data` against `tt-data` under the same data name, with the register's type carrying zero type arguments and the declared return carrying one (375) or two (14). Zero are an unbound register, zero are a data-name mismatch, zero are a ground-type mismatch. The register's type comes from `expr-con`, which annotates every constructed value `(tt-data dn nil)`; the declared return comes from `ntalty->talty`, which carries the arguments through from `compile-front`'s `t-tcon` peel. `tal-ty=?`'s `tt-data` arm demands `tys=?`, and `tys=?` refuses an empty list against a non-empty one. The arguments carry no checking power anywhere else in the checker: `ck-con` and `ck-term`'s case arm both resolve a data type by its name alone. Relaxing `tal-ty=?` so that an empty argument list on either side matches, the wildcard role `tt-word` already plays for a whole type, turns all 389 into accepts. Minimal rejecting TFn: a def declared to return `(tt-data "Lst" (tt-i64))` whose whole body is `(i-con 0 "Lst" "lnil" nil (tt-data "Lst" nil))` then `(t-ret 0)`; respelling the declared return as `(tt-data "Lst" nil)` makes the identical body accept. Its source twin compiles, emits, links and runs correctly. ⚑ The lowering carries a contributing defect that would close none of the class on its own: `expr-con` binds an expected type `exty` and reads it at no line.
- evidence: `lib/lowering/upper/lower.chiral:288-296`, `lib/lowering/compile-back.chiral:29`, `lib/lowering/compile-front.chiral:68`, `lib/lowering/tal/check.chiral:50-63`, `:190-192`, `:123-125`, `:196`
- checked:  2026-09-03
- element:  UNASSIGNED

### EN-10 the `con` class is that same erased argument list, 184 of 185

- state:    OPEN
- claim:    requirement 3 counts the `con` class and leaves the side that is wrong unnamed.
- measured: THE CHECKER for 184 of 185, by the mechanism EN-09 names, arriving through `ck-con`'s field check instead of through the terminator. `expr-con` types each field argument by walking `expr`, so a nested constructed value comes back `(tt-data dn nil)` while the declaring constructor's field type carries its arguments, peeled by `field-tys->n` and widened by `ndctors->dctors`. All 184 carry zero arguments against one (182) or two (2). The 185th is a ground-type conflation inside `$apply7`, a register typed `(tt-data "List" ...)` in a field position declared `tt-str`, and it belongs with the residue in EN-13. Minimal rejecting TFn: a two-level con whose outer constructor declares its second field `(tt-data "Lst" (tt-word))` while the inner con's register is `(tt-data "Lst" nil)`; annotating that inner register `(tt-data "Lst" (tt-word))` makes it accept. Its source twin compiles, emits, links and runs correctly.
- evidence: `lib/lowering/tal/check.chiral:117-129`, `:82-90`, `lib/lowering/upper/lower.chiral:288-296`, `lib/lowering/compile-front.chiral:216-223`, `lib/lowering/compile-back.chiral:66-69`
- checked:  2026-09-03
- element:  UNASSIGNED

### EN-11 the `case on non-data register` class is the checker lacking the recovery the lowering has, 105 of 105

- state:    OPEN
- claim:    requirement 3 counts the `case on non-data register` class and leaves the side that is wrong unnamed.
- measured: THE CHECKER, in all 105. Every one is a scrutinee register typed `tt-word`. Zero are the other path to that same message, an unbound scrutinee register. The lowering performs a B1 recovery: `case-sty` calls `ctor-data` to read the data name out of the first arm's constructor whenever the scrutinee's tal type fails to be `tt-data`. That recovery stays inside the lowering's own bookkeeping and reaches the emitted instruction at no point, so the register keeps `tt-word` in the TFn. `ck-term`'s case arm carries no `tt-word` arm and falls through to its catch-all. The refusal contradicts the checker's own `tal-ty=?`, whose first arm makes `tt-word` compatible with every type. Giving `ck-term` the same `ctor-data` walk over `ce-datas` turns all 105 into accepts. Minimal rejecting TFn: `(tfn "sel" ((tt-word)) (tt-i64) (block nil (tt-case 0 ...)))`; respelling that parameter `(tt-data "Lst" nil)` makes the identical body accept. Its source twin, a case over a value read out of a polymorphic field, compiles, emits, links and runs correctly.
- evidence: `lib/lowering/upper/lower.chiral:168-188`, `:304-306`, `:347-355`, `lib/lowering/tal/check.chiral:193-205`, `:50-52`, `lib/lowering/tal/ssa.chiral:17-20`
- checked:  2026-09-03
- element:  UNASSIGNED

### EN-12 the `argument arity` class splits, 70 to the checker and 5 to the lowering

- state:    OPEN
- claim:    requirement 3 counts the `argument arity` class and leaves the side that is wrong unnamed.
- measured: SPLITS 70 to the checker and 5 to the lowering. As counted, the 75 are 73 the erased argument list of EN-09 reaching `ck-app` through `ck-args`, all of them zero arguments against one, plus one data-name mismatch and one ground-type mismatch. Relaxing that one checker relation flips 70 of the 75 to accepts and leaves 5, which is where the split lives: the relaxation unmasks two rejects the argument-list failure had been hiding, because `ck-args` returns on its first failing position. Those two are the lowering, and they are a real defect. `build-binders` allocates a fresh register for every erased binder position and emits no instruction defining it, on the stated ground that a `q=0` binder has zero runtime uses; `outline` then passes the whole binder environment as the outlined call's arguments, so that undefined register is passed. The enclosing TFn's `params` holds the kept list, so nothing binds it there either. They are `emit-code` (4 params, undefined register 4) and `emit-args-res` (3 params, undefined register 3), where in both the offending index equals the parameter count, which is the first register `build-binders` allocates. The emitted native code reads an undefined register and the program still computes correctly, because the callee reads that argument at no point. The remaining 3 of the 5 sit inside `$apply` dispatchers and belong with the residue in EN-13. Minimal rejecting TFn: a caller of one parameter whose body is `(i-call 1 "inner" (0 2) (tt-i64))` where register 2 is bound by nothing; inserting a definition of register 2 makes it accept. Its source twin, an erased binder over a non-tail case, compiles, emits, links and runs correctly.
- evidence: `lib/lowering/upper/lower.chiral:383-397`, `:308-317`, `:399-406`, `lib/lowering/tal/check.chiral:82-90`, `:92-100`, `:220-225`
- checked:  2026-09-03
- element:  UNASSIGNED

### EN-13 six TFns survive both relaxations, and the repair shape is an author call

- state:    OPEN
- claim:    none. This row records what the diagnosis leaves behind.
- measured: With both checker relaxations applied, the one EN-09 names and the one EN-11 names, 1,475 of 1,481 TFns accept and six reject. Two are the undefined erased-binder register of EN-12, in `emit-code` and `emit-args-res`. Four are the closure-conversion dispatchers `$apply4`, `$apply5`, `$apply6` and `$apply7`, where a register's tal type disagrees with the expected type across the ground-versus-data boundary instead of inside a type-argument list: two `tt-i64` against `(tt-data "List" ...)`, one data-name mismatch, one `(tt-data "List" ...)` against `tt-str`. `closconv.chiral:362` already records that two families of different concrete type must stay unmerged, which is the shape these four have. Those six are lowering defects the checker is right about, and they are 0.4% of 1,481. So the 50.6% disagreement is 99.2% one checker relation and one missing checker arm. ⚑ Two questions stay open and this slice answers neither. The first is the author's: "Is the argument-list disagreement repaired by relaxing the checker so that an erased argument list is a wildcard, or by making the lowering carry the arguments into the IR?" `LCore` is type-erased, so the second option may be unreachable at the constructor sites. The second question is the refuse-or-carry ruling already standing in [[records/author-calls]], which this slice leaves untouched.
- evidence: `lib/lowering/upper/closconv.chiral:362`, `:1098`, `lib/lowering/upper/lower.chiral:116-123`, `:385-397`, `lib/lowering/mach/emit-core.chiral:178`, `:200`
- checked:  2026-09-03
- element:  UNASSIGNED

### EN-14 the six survivors are lowering defects, and they are what the repaired checker refuses

- state:    OPEN
- claim:    EN-13 records six TFns surviving both checker relaxations and leaves them as residue no row owns. The author's ruling (`records/author-calls.md`, "The `ck-prog` repair shape", 2026-09-03) makes them the evidence that the repair is sound and says they get their own row.
- measured: Both repairs are in `lib/lowering/tal/check.chiral` as of 2026-09-03: `targs=?`, where an empty type-argument list on either side matches, and `ck-scrut-dn`, which recovers a `tt-word` scrutinee's data name from the first arm's constructor over `ce-datas`. `tools/test/tal-check.sh` gates them, Phase 22, sixteen hand-built TFns of which nine are refusals, plus three mutants that each turn a named green row red. The compiler blob is byte-identical across the edit at 806,827 bytes and holds zero occurrences of `def ck-prog`, so `check.chiral` sits outside the closure and no promotion is owed. The six survivors are tracked work here, in two families. **Two are the erased-binder register.** `build-binders` allocates a fresh register for every erased binder position, on the stated ground that a `q=0` binder has zero runtime uses, and emits no instruction defining it; `outline` then passes the whole binder environment as the outlined call's arguments, so the undefined register travels with them, and the enclosing TFn's `params` carries the kept list, which binds it nowhere either. `emit-code` and `emit-args-res` therefore read an undefined register in the shipping compiler today, and both compute correctly for one reason: the callee reads that argument at no point. **Four are the `$apply` dispatchers.** `$apply4`, `$apply5`, `$apply6` and `$apply7` disagree across the ground-versus-data boundary rather than inside a type-argument list: two `tt-i64` against `(tt-data "List" ...)`, one data-name mismatch, one `(tt-data "List" ...)` against `tt-str`. `closconv.chiral:362` already warns that two families returning different ground types must stay unmerged, else one `$apply`'s concrete return miscompiles the other's `case`, and that warning names the shape these four have. ⚑ Both families are unrepaired and unscheduled. The element is `UNASSIGNED`: `docs/decisions/decision-lane-split.md` reserves `E184-E189` and `E190-E195`, four numbers remain, and two arcs draw on the band. ⚑ The 1,475-of-1,481 figure this row rests on is EN-13's, measured on that day's blob by a probe that was reverted. Phase 22 measures the two repairs on sixteen hand-built TFns and leaves the whole-blob figure unremeasured. ⚑ One citation moved and stays stale, BA-13's class: the repair inserts 49 lines above `const-fits?`, so `docs/elements/specs/E158-doc-formatter-SPEC.md:139` now cites `lib/lowering/tal/check.chiral:113` for a definition that sits at `:162-163`, and `tools/ledger-lint/ledger-lint.py`'s check R goes 133 to 134. The repoint is one token and is deliberately left to the session that owns that file.
- evidence: `lib/lowering/upper/lower.chiral:385-397`, `:316`, `lib/lowering/mach/emit-core.chiral:178`, `:200`, `lib/lowering/upper/closconv.chiral:362`, `lib/lowering/tal/check.chiral:47`, `:58`, `:73-78`, `:113-127`, `:244-245`, `tools/test/tal-check.sh`
- checked:  2026-09-03
- element:  UNASSIGNED
