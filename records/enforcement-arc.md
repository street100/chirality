---
node: records-enforcement-arc
layer: navigation
related: [records/README, status-ledger, arcs/enforcement-arc, arcs/diagnostics-arc, decisions/decision-erased-word-level, index]
status: current
updated: 2026-09-04
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

Rows EN-01 to EN-07 were measured on 2026-09-01, EN-08 to EN-16 on
2026-09-03, and EN-15's ruling, EN-17, EN-18 and EN-19 on 2026-09-04. Re-run a
row's evidence before relying on it.

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
- evidence: `lib/lowering/upper/optimize.chiral:250`, `lib/lowering/tal/check.chiral:240-241`, `:250-256`, `:259-263`
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
- evidence: `lib/lowering/tal/check.chiral:260-263`, `lib/lowering/compile-back.chiral:231-240`, `lib/lowering/compile-all.chiral:18-33`, commits `65bec90`, `d26d7a1`, `docs/definitions/working-discipline.md:30-38`
- checked:  2026-09-03
- element:  none

### EN-09 the `ret` class is the checker: an erased type-argument list, 389 of 389

- state:    OPEN
- claim:    requirement 3 counts the `ret` class and leaves the side that is wrong unnamed.
- measured: THE CHECKER, in all 389, and the shape is uniform. Every one is `tt-data` against `tt-data` under the same data name, with the register's type carrying zero type arguments and the declared return carrying one (375) or two (14). Zero are an unbound register, zero are a data-name mismatch, zero are a ground-type mismatch. The register's type comes from `expr-con`, which annotates every constructed value `(tt-data dn nil)`; the declared return comes from `ntalty->talty`, which carries the arguments through from `compile-front`'s `t-tcon` peel. `tal-ty=?`'s `tt-data` arm demands `tys=?`, and `tys=?` refuses an empty list against a non-empty one. The arguments carry no checking power anywhere else in the checker: `ck-con` and `ck-term`'s case arm both resolve a data type by its name alone. Relaxing `tal-ty=?` so that an empty argument list on either side matches, the wildcard role `tt-word` already plays for a whole type, turns all 389 into accepts. Minimal rejecting TFn: a def declared to return `(tt-data "Lst" (tt-i64))` whose whole body is `(i-con 0 "Lst" "lnil" nil (tt-data "Lst" nil))` then `(t-ret 0)`; respelling the declared return as `(tt-data "Lst" nil)` makes the identical body accept. Its source twin compiles, emits, links and runs correctly. ⚑ The lowering carries a contributing defect that would close none of the class on its own: `expr-con` binds an expected type `exty` and reads it at no line.
- evidence: `lib/lowering/upper/lower.chiral:288-296`, `lib/lowering/compile-back.chiral:29`, `lib/lowering/compile-front.chiral:68`, `lib/lowering/tal/check.chiral:67-80`, `:207-209`, `:140-142`, `:213`
- checked:  2026-09-03
- element:  UNASSIGNED

### EN-10 the `con` class is that same erased argument list, 184 of 185

- state:    OPEN
- claim:    requirement 3 counts the `con` class and leaves the side that is wrong unnamed.
- measured: THE CHECKER for 184 of 185, by the mechanism EN-09 names, arriving through `ck-con`'s field check instead of through the terminator. `expr-con` types each field argument by walking `expr`, so a nested constructed value comes back `(tt-data dn nil)` while the declaring constructor's field type carries its arguments, peeled by `field-tys->n` and widened by `ndctors->dctors`. All 184 carry zero arguments against one (182) or two (2). The 185th is a ground-type conflation inside `$apply7`, a register typed `(tt-data "List" ...)` in a field position declared `tt-str`, and it belongs with the residue in EN-13. Minimal rejecting TFn: a two-level con whose outer constructor declares its second field `(tt-data "Lst" (tt-word))` while the inner con's register is `(tt-data "Lst" nil)`; annotating that inner register `(tt-data "Lst" (tt-word))` makes it accept. Its source twin compiles, emits, links and runs correctly.
- evidence: `lib/lowering/tal/check.chiral:134-146`, `:99-107`, `lib/lowering/upper/lower.chiral:288-296`, `lib/lowering/compile-front.chiral:216-223`, `lib/lowering/compile-back.chiral:66-69`
- checked:  2026-09-03
- element:  UNASSIGNED

### EN-11 the `case on non-data register` class is the checker lacking the recovery the lowering has, 105 of 105

- state:    OPEN
- claim:    requirement 3 counts the `case on non-data register` class and leaves the side that is wrong unnamed.
- measured: THE CHECKER, in all 105. Every one is a scrutinee register typed `tt-word`. Zero are the other path to that same message, an unbound scrutinee register. The lowering performs a B1 recovery: `case-sty` calls `ctor-data` to read the data name out of the first arm's constructor whenever the scrutinee's tal type fails to be `tt-data`. That recovery stays inside the lowering's own bookkeeping and reaches the emitted instruction at no point, so the register keeps `tt-word` in the TFn. `ck-term`'s case arm carries no `tt-word` arm and falls through to its catch-all. The refusal contradicts the checker's own `tal-ty=?`, whose first arm makes `tt-word` compatible with every type. Giving `ck-term` the same `ctor-data` walk over `ce-datas` turns all 105 into accepts. Minimal rejecting TFn: `(tfn "sel" ((tt-word)) (tt-i64) (block nil (tt-case 0 ...)))`; respelling that parameter `(tt-data "Lst" nil)` makes the identical body accept. Its source twin, a case over a value read out of a polymorphic field, compiles, emits, links and runs correctly.
- evidence: `lib/lowering/upper/lower.chiral:168-188`, `:304-306`, `:347-355`, `lib/lowering/tal/check.chiral:210-222`, `:67-69`, `lib/lowering/tal/ssa.chiral:17-20`
- checked:  2026-09-03
- element:  UNASSIGNED

### EN-12 the `argument arity` class splits, 70 to the checker and 5 to the lowering

- state:    OPEN
- claim:    requirement 3 counts the `argument arity` class and leaves the side that is wrong unnamed.
- measured: SPLITS 70 to the checker and 5 to the lowering. As counted, the 75 are 73 the erased argument list of EN-09 reaching `ck-app` through `ck-args`, all of them zero arguments against one, plus one data-name mismatch and one ground-type mismatch. Relaxing that one checker relation flips 70 of the 75 to accepts and leaves 5, which is where the split lives: the relaxation unmasks two rejects the argument-list failure had been hiding, because `ck-args` returns on its first failing position. Those two are the lowering, and they are a real defect. `build-binders` allocates a fresh register for every erased binder position and emits no instruction defining it, on the stated ground that a `q=0` binder has zero runtime uses; `outline` then passes the whole binder environment as the outlined call's arguments, so that undefined register is passed. The enclosing TFn's `params` holds the kept list, so nothing binds it there either. They are `emit-code` (4 params, undefined register 4) and `emit-args-res` (3 params, undefined register 3), where in both the offending index equals the parameter count, which is the first register `build-binders` allocates. The emitted native code reads an undefined register and the program still computes correctly, because the callee reads that argument at no point. The remaining 3 of the 5 sit inside `$apply` dispatchers and belong with the residue in EN-13. Minimal rejecting TFn: a caller of one parameter whose body is `(i-call 1 "inner" (0 2) (tt-i64))` where register 2 is bound by nothing; inserting a definition of register 2 makes it accept. Its source twin, an erased binder over a non-tail case, compiles, emits, links and runs correctly.
- evidence: `lib/lowering/upper/lower.chiral:383-397`, `:308-317`, `:399-406`, `lib/lowering/tal/check.chiral:99-107`, `:109-117`, `:237-242`
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

- state:    FIXED
- claim:    EN-13 records six TFns surviving both checker relaxations and leaves them as residue no row owns. The author's ruling (`records/author-calls.md`, "The `ck-prog` repair shape", 2026-09-03) makes them the evidence that the repair is sound and says they get their own row.
- measured: **THE LOWERING MOVED, for one of the two families, and the whole-blob figure is re-measured.** Both checker repairs are in `lib/lowering/tal/check.chiral` as of 2026-09-03, `ddfbc27`: `targs=?`, where an empty type-argument list on either side matches, and `ck-scrut-dn`, which recovers a `tt-word` scrutinee's data name from the first arm's constructor over `ce-datas`. `tools/test/tal-check.sh` gates them, Phase 22, sixteen hand-built TFns of which nine are refusals, plus three mutants that each turn a named green row red; it runs `21 ok, 0 FAIL` on this tree. **The erased-binder family is repaired in `lib/lowering/upper/lower.chiral`.** `build-binders` allocated a fresh register for every erased binder position, on the stated ground that a `q=0` binder has zero runtime uses, and emitted no instruction defining it; `outline` then passed the whole binder environment as the outlined call's arguments, so the undefined register travelled with them, and the enclosing TFn's `params` carries the kept list, which bound it nowhere either. `emit-code` and `emit-args-res` therefore read an undefined register in the shipping compiler, and both computed correctly for one reason, that their callees read that argument at no point. `build-binders` now returns a `BB` carrying the defining `i-const 0` for each placeholder alongside the environment, and `compile-fn` seeds `tail`'s instruction list with them, which is the repair `tail`'s own `lc-let q=0` arm already performs for an erased LET binder. **The remaining four are the `$apply` dispatchers and they are an author call**, re-diagnosed and carried to EN-15. Measured by the EN-08 probe, rebuilt against today's repaired `check.chiral` and reverted: **1,477 of 1,481 accept before the compiler is rebuilt, against 1,475 of 1,481 on the same probe before the change.** The blob moves 806,827 to 807,767 bytes and `check.chiral` still holds zero occurrences of `def ck-prog`, so the checker stays outside the closure; the lowering change is inside it and owes the full build rule, which ran: `B1 != B2`, `B2 == B3` at 1,188,216 bytes, generation two promoted, `tools/test/run-tests.sh` `339 passed, 0 failed` with `87 roots built, 0 failed`. ⚑ The 1,477 figure is a probe's measurement and no compile produces it. `ck-prog` still has no call site on the shipping path, which is requirement 2 and the next stage. ⚑ EN-14's stale-citation note is retired: `docs/elements/specs/E158-doc-formatter-SPEC.md:139` now cites `lib/lowering/tal/check.chiral:180` and `const-fits?` is at `:180`.
- evidence: `lib/lowering/upper/lower.chiral:132-134`, `:381-410`, `:412-420`, `lib/lowering/mach/emit-core.chiral:178`, `:200`, `lib/lowering/tal/check.chiral:64`, `:75`, `:90-95`, `:130-144`, `:261-262`, `tools/test/tal-check.sh`
- checked:  2026-09-03
- element:  none

### EN-15 the four `$apply` dispatchers are one cause, and the repair shape is an author call

- state:    ANSWERED 2026-09-04
- claim:    EN-13 and EN-14 record four `$apply` dispatchers rejecting across the ground-versus-data boundary, name `closconv.chiral:362` as the shape they have, and leave the repair unnamed.
- measured: ONE CAUSE, in all four, and it is the erasure the family key performs on purpose. Every rejection is an `$apply` **parameter** register, low-indexed, whose declared tal type is one family member's concrete domain while the arm body passes it to a callee holding another member's. Re-measured 2026-09-03 with the EN-08 probe instrumented to print the pair: `$apply4` register 2 carries `i64` against `(List Str)`; `$apply5` register 3 carries `i64` against `(List Word)`; `$apply6` register 1 carries `Mach` against `Op`; `$apply7` register 1 carries `(List Asm)` against `Str`, through `ck-con`'s field check instead of through `ck-args`. `shape-eq` makes every non-arrow type one word, so `I64` and `(List Str)` share a defunctionalization family by design, and `closconv.chiral:359-360` states that design: domains always erase, because a polymorphic `(-> K K ..)` parameter has to share a family with the concrete closures passed to it. `apply-ty` then spells the dispatcher's domains with one member's Core types, and `term->ntalty` carries them through the peel as `nt-data` / `nt-i64` / `nt-str`. So the checker is right and the annotation is the defect: an erased domain's honest tal type is `tt-word`, which `ssa.chiral:17-20` defines for exactly this. ⚑ **The repair is a fork the tree does not settle, and this row stops.** `Core` has no word spelling, `closconv-sig` runs after the typecheck and before the peel so its output is never re-checked by the kernel, and the same question applies a second time to the `$kI_J` capture constructor's field types, which is what `$apply7` fails on. Making the families finer instead is ruled out by `closconv.chiral:359-360`, and relaxing the checker is ruled out by the author's standing ruling. The call is a row in [[records/author-calls]]. ⚑ Nothing here is a miscompile today. Every one of these values is one word at runtime and the emitted code is correct; what is wrong is the type the IR carries,  ⚑ **ANSWERED 2026-09-04, and the ruling is recorded in [[decisions/decision-erased-word-level]].** **The erased-word type lives strictly at the lowering type level. `Core` gains no word spelling and the kernel's `conv` relation is not widened.** Five reasons, in order of force. Conversion is an equivalence relation, so it is transitive: a `Word` that converts with `I64` and with `(List Str)` makes `I64` convert with `(List Str)`, which collapses the source type system, and that reason alone settles the fork. The prior art is one-sided: `.planning/RESEARCH-EN15-prior-art.md` §6 surveys seven systems (JVM verifier, MLton RSSA, TALx86, GHC, Pottier and Gauthier, Huang and Yallop, OCaml and CakeML) and not one admits a type into the source conversion or equality relation that identifies two distinct ground types. The kernel would gain a conversion it never uses, because `closconv-sig` runs after the typecheck (`lib/lowering/compile-front.chiral:342`) and its output is never re-checked by the kernel. The relation already exists at exactly one level, `lib/lowering/tal/ssa.chiral:17-20`, and a second statement of one rule drifts from the first. And the one argument for the kernel, letting it re-check post-closconv output, asks one instrument to work at two levels, which `docs/banks/verification.md` refuses; the right instrument for lowered code is `ck-prog`, so that argument is an argument for unblocking `ck-prog`, which is the ruling. ⚑ **Two things the ruling does not settle.** The SPELLING of the erased position is open and is **E185**: a quantified type variable against a coarse word type of the lower language, the two candidates in research §6. The `$kI_J` capture constructor's field types are a SEPARATE call and stay open as **EN-17**; research §7 corrects the earlier reading that the two instances take one answer.
- evidence: `lib/lowering/upper/closconv.chiral:335-356`, `:359-363`, `:1081-1083`, `lib/lowering/compile-front.chiral:68-71`, `:335-342`, `lib/lowering/tal/ssa.chiral:17-20`, `lib/lowering/tal/check.chiral:148-156`, `:183-196`, `.planning/RESEARCH-EN15-prior-art.md`, `docs/decisions/decision-erased-word-level.md`
- checked:  2026-09-04
- element:  E185

### EN-16 five of `check.chiral`'s eleven collisions are duplication, and the honest fix is a shared module

- state:    OPEN
- claim:    none yet. The rename that made `lowering/tal/check` importable beside the compiler treated all eleven collisions alike, and for five of them that is a hand-patch over a different defect.
- measured: `sig-assoc`, `find-data`, `ce-prims`, `ce-fns` and `ce-datas` were **byte-identical** in `lib/lowering/tal/check.chiral` and `lib/lowering/upper/lower.chiral` up to whitespace: the same association-list lookup, the same `DData` lookup, and three `CEnv` field accessors over the same `(cenv p f d l)` shape, whose type `lowering/tal/ssa.chiral` already declares for both. That is duplication rather than a conflict of meaning, so the `tck-` prefix leaves the tree with two copies of one function instead of one copy in one place. The other six are genuine homonyms and the prefix is right for them: `CkR`/`ck-ok`/`ck-err` name a different sum from `typing/kernel.chiral`'s, `CovR`/`cov-ok` a different sum from `surface/data.chiral`'s, and `find-ctor` walks `(List DCtor)` where the kernel's walks `(List Ctor)`. The extraction was deliberately **not** taken in the rename slice: `lower.chiral` is inside the compiler's blob, so lifting five defs out of it changes compiler source and owes `build-new → test → promote` with a fixpoint, which is a larger slice than making one module importable. E154's row already records the flat emitted-label namespace as the live, recurring, hand-patched defect this is the fifth instance of; per-module label mangling is the structural fix and remains unbuilt.
- evidence: `lib/lowering/tal/check.chiral:20-35`, `:101-110`, `:51-53`, `lib/lowering/upper/lower.chiral:163-168`, `:192-194`, `lib/lowering/tal/ssa.chiral`, `docs/elements/catalog.md:480`
- checked:  2026-09-03
- element:  UNASSIGNED

### EN-17 the `$kI_J` capture constructor's field types are a second instance, and a separate call

- state:    OPEN
- claim:    EN-15 reads the four `$apply` rejections and the `$apply7` rejection as one cause, and an earlier session reading took the two instances to have the same answer. The 2026-09-04 ruling on the erased-word type ([[decisions/decision-erased-word-level]]) settles the dispatcher's domains and says nothing about the capture constructor's fields.
- measured: A CORRECTION, and the prior art splits the two instances. `.planning/RESEARCH-EN15-prior-art.md` §7: both published answers keep constructor fields CONCRETE. Pottier and Gauthier's `succ : Arrow int int` carries concrete field types beside concrete arrow indices, and the dispatcher's branch recovers the indices from the GADT equation; Minamide, Morrisett and Harper's typed closure conversion hides a heterogeneous environment behind `∃` with the fields concrete inside the pack, and Huang and Yallop's label-context entry keeps the captures at their source types. The reason the two differ is structural: a capture constructor (`ctor-name`, `lib/lowering/upper/closconv.chiral:1099`, spelling `$k<i>_<j>`) is applied at exactly one site, its own definition site, so nothing forces its field types to merge with another constructor's, while the shared dispatcher's argument position is constrained by every member of the family at once. Under that shape the constructor is the concrete side and the dispatcher the varying side, which is the OPPOSITE arrangement to the measured `$apply7`: that one reddens through `ck-con`'s field check (`lib/lowering/tal/check.chiral:183-196`) instead of through `ck-args` (`lib/lowering/tal/check.chiral:148-156`). So whether the two instances are one defect or two is unsettled, and the E185 spelling ruling may or may not reach the fields. ⚑ Nothing here is a miscompile today, for the same reason EN-15 gives: every one of these values is one word at runtime and the emitted code is correct. What is wrong is the type the IR carries, and `ck-prog` cannot be wired to refuse on the shipping path while either instance stands.
- evidence: `.planning/RESEARCH-EN15-prior-art.md` §7, `lib/lowering/upper/closconv.chiral:1099`, `lib/lowering/tal/check.chiral:183-196`, `:148-156`, `docs/decisions/decision-erased-word-level.md`, [[records/author-calls]]
- checked:  2026-09-04
- element:  E186 (minted 2026-09-04 by E185's SPEC run; the author call stands and the element carries the pipeline after it)

⚑ **E185 no longer waits on this row, measured against the SPEC's disposition
2026-09-04.** `docs/elements/specs/E185-type-preserving-upper-SPEC.md` states the
dispatcher's parameter types at the lowering type level as the erased word.
`tal-ty=?` (`lib/lowering/tal/check.chiral:68-70`) has the erased word matching
everything, so `$apply7`'s field check in `ck-con` passes on the parameter side
while the constructor's declared fields stay concrete, which is the arrangement
research §7 finds in the prior art. So the four dispatchers accept with this row
open. What the row still blocks is whether the constructor's fields are honest,
which is E186.

### EN-18 the dispatchers' domains are stated as the erased word, and two of the four rejects survive in a class the fourth's repair unmasked

- state:    FIXED for the class it names, and it opens EN-19 for what is left.
- claim:    EN-15 measures four `$apply` dispatchers rejecting because `apply-ty` spells their domains with one arbitrary family member's concrete `Core` types, and [[decisions/decision-erased-word-level]] answers the level and leaves the spelling to E185. `docs/elements/specs/E185-type-preserving-upper-SPEC.md` §5 states the target as **zero `$apply` rejects**.
- measured: **THE FOUR ARE GONE AND TWO CAME BACK IN A DIFFERENT CLASS, so the target is not met and the reject count halves.** E185 built the stated-parameter channel: `closconv-driver`'s `apply-ptys` computes the dispatcher's parameter types from the family instead of copying a member's, `nt-word` at every domain and `(nt-data $clo<i> nil)` at the leading argument, `closconv-sig` returns a `CCOut` carrying that statement beside the rewritten `Sig`, and `compile-front`'s `peel-def` prefers a stated entry over the peel. Measured with the EN-08 probe, rebuilt against the promoted binary and reverted, and the instrument reproduces EN-14 exactly on the pre-change tree: **1,477 of 1,481 accept before, rejecting `$apply4`, `$apply5`, `$apply6` on `argument arity or type mismatch` and `$apply7` on `con: field arity or type mismatch`; 1,482 of 1,484 accept after, rejecting `$apply5` and `$apply6` on `ret: type does not match declared return`.** The after set is a SUBSET of the before set, so no TFn became a reject that was not one already, and `$apply4` and `$apply7` accept outright. ⚑ The denominator moved, 1,481 to 1,484, because the change is compiler source inside the blob and the promoted binary emits three more `TFn`s; `N of N` is re-measured and no compile produces `1,481 of 1,481`. **The two survivors are the CODOMAIN, and the repair unmasked them.** Both declare a return of `(List Asm)`, which `cod-key-eq` (`lib/lowering/upper/closconv.chiral:365-380`) keeps concrete on purpose, and the same body under a declared return of `tt-word` ACCEPTS, so the disagreement is the declared return and nothing else. Before the change `ck-args` refused on the first failing argument position and returned, so the `t-ret` rule never ran on either function; that is the masking mechanism EN-12 already recorded for the checker relaxation, working the same way for a lowering repair. The returning register's own tal type is UNMEASURED here, because naming it needs `ck-block`'s register environment threaded out of the checker, and it is carried to EN-19. **The build.** Blob 807,767 to 812,351 bytes; B1 differs from B2 at char 98, B2 == B3 at 1,192,312 bytes with both non-empty, generation two promoted. `tools/test/run-tests.sh` ran once against B3: `352 passed, 1 failed`, `88 roots built, 0 failed`, and the one failure is inherited and orthogonal, `diag.sh` G4's containment scan finding `(r-relayed ` spelled inside a comment at `tools/test/arity.sh:433`, a line present at `67d3d54` and at `0224442`, before any E185 commit. **The gate.** `tools/test/apply-word.sh`, six rows and five mutants, `11 ok, 0 FAIL`: base `ok ok ok ok ok ok` with the fixture's ELF byte-identical at 33,144 bytes under the pre-change and promoted binaries, then M1 `ok bad ok ok ok ok`, M2 `ok bad ok ok ok bad`, M3 `ok ok bad ok ok ok`, M4 `ok ok ok bad ok ok`, M5 `bad absent absent absent absent bad`. It is UNREGISTERED and carries no row saying so, which is `records/gate-audit.md` GA-24, and the number is the author's call already standing in [[records/author-calls]].
- evidence: `lib/lowering/upper/closconv-driver.chiral`, `lib/lowering/compile-front.chiral`, `lib/lowering/upper/closconv.chiral:1079-1099`, `lib/lowering/tal/check.chiral:148-156`, `:255-258`, `tools/test/apply-word.sh`, `tools/test/samples/e185_apply_word.prog`, `prog/e185-apply-word.prog`, commits `4d3b7c4`, `9610304`, `82b7ba0`, `ccff8e8`, `1157028`, `4bacbdf`
- checked:  2026-09-04
- element:  E185

### EN-19 two dispatchers disagree with their own declared CODOMAIN, and `cod-key-eq` was assumed to have made that impossible

- state:    OPEN
- claim:    `docs/elements/specs/E185-type-preserving-upper-SPEC.md` §2 files the codomain under "what is already honest, and stays untouched", on the ground that `cod-key-eq` keeps a ground codomain concrete so two families returning different ground types never merge. EN-18 measures that assumption failing for two families.
- measured: `$apply5` and `$apply6` reject on `ret: type does not match declared return` with the domains repaired. Both declare `(List Asm)`; `$apply5` carries three word domains after its `$clo5` argument and `$apply6` four after `$clo6`. The one-change control is the whole diagnosis: the identical body under a declared return of `tt-word` accepts, so the returning register is a concrete tal type that `tal-ty=?` refuses against `(List Asm)`, and it is neither `tt-word` (which matches everything, `lib/lowering/tal/check.chiral:68-70`) nor a `(List )` with an empty argument list (which `targs=?` matches, the B3 repair). ⚑ WHAT IS NOT MEASURED, and it is the next step: the returning register's own tal type, which needs `ck-block`'s register environment carried out of the checker rather than inferred from the refusal. Until it is named, whether this is `cod-key-eq` merging two families it should not, or an arm returning a value the member's own `TalSig` types differently, is unsettled. ⚑ Nothing here is a miscompile, for the reason EN-15 and EN-17 both give: every one of these values is one word at runtime and the emitted code is correct. `tools/test/apply-word.sh` R6 measures that directly for E185's own change, the fixture's ELF byte-identical at 33,144 bytes across the promotion. What is wrong is the type the IR carries, and `ck-prog` cannot be wired to refuse on the shipping path while this stands. ⚑ It is the LAST of the four `$apply` classes: EN-09's argument lists, EN-11's `tt-word` scrutinee and EN-12's undefined erased-binder register are repaired, EN-15's domains are repaired by E185, and this is the residue.
- evidence: `lib/lowering/upper/closconv.chiral:365-380`, `lib/lowering/tal/check.chiral:68-70`, `:255-258`, `lib/lowering/compile-back.chiral:77-79`, `docs/elements/specs/E185-type-preserving-upper-SPEC.md`
- checked:  2026-09-04
- element:  UNASSIGNED
