> **ARCHIVED 2026-09-01. Superseded by the E100 row in `docs/elements/ledger.md`, tracked.** Kept for one reason: it records a **hypothesis held wrong for two sessions**, and the correction is the value. Read it as a record of how the wrong root cause was reached, not as a description of the bug.

# Rep-unification worklog — GOAL: 3 images co-load into ONE, then self-compile

Do not stop to report. Fix collision → suite green → commit → next collision.
Safety net: `python3 -m unittest discover -s tests` (649) + the ELF differential.

## The loop
1. `Elab().load_file` front, back, emit into ONE Elab → read the collision.
2. Type collision → disambiguate by transitive import (syntax/kernel vs tal-ssa/
   tal-ir vs surface/lower), rename the non-canonical side, sync Python if a tag.
3. Ctor collision → same, but tal ctors ALSO ripple to native.py/tal.py string
   tags (NOT kernel.py). kernel keeps t-*, tal → tt-* (or stage-distinct).
4. Suite green → commit `unify(n): ...` → back to 1.

## DONE (11 code commits, 649 green)
- specialization: mach pass (chirality/specialize.py) + a-rel defunctionalize (EncTag)
  + ref-field fix → compile-emit 237→271.
- unify: 3 helper clashes (ssa-fresh/drop-last-env/resolve-label); 5 IR types
  (TalTerm/TIFn/LCore/LCArm/LowBind).

## NOW: constructor collisions
- `t-case`: kernel Term + tal-ssa TalTerm + tal-ir TCode. Rename tal → tt-case in
  the 14 tal modules + native.py/tal.py tags. (kernel keeps t-case.)
- then re-loop: expect more (dctor? branch? tt-* already distinct).
- tal-ssa vs tal-ir still collide after tt-case (both tt-case) → their MERGE or
  stage-distinct names is the last co-load step.

## ✅✅ CO-LOAD DONE (unify 1-6) — all 3 images load into ONE Elab
The 3-image collision is GONE. 12 type collisions + the ctor collisions
(t-case→tt-case kernel-vs-tal; tal-ir t-ret/tt-case/tfn→ti-*; LCore c-*→lc-*;
n-prim→en-prim; dup helpers l-*/cb-*) all resolved, Python tal-machine + test
builders synced. 649 green.

## NOW: poly-13 defunctionalization (the last coverage piece)
One image alone does NOT lower poly-13. Root cause found + validated: the
comparators are PRIMS (`str-eq` = `(extern str-eq (-> Str Str Bool))`), and
closconv only collects **Global**-of-arrow function-values, not **Prim**-of-arrow.
Prototyped the fix (a "p" ctor kind): _ty_of Prim case + collect prims + _arm_body
prim (apply the Prim to d args) + rewrite Prim→Con. RESULT: collection works
(type-not-lower 13→1) BUT conversion is incomplete (55 "higher-order application"
left unconverted) + it breaks the ty-of differential (chirality ty-of needs the Prim
mirror too). REVERTED to keep green. Remaining for poly-13:
1. Finish the Python prim-closure CONVERSION (the 55 HO sites — the rewrite must
   turn every comparator application into an $apply; likely a family
   poisoning/keying gap).
2. Mirror ALL of it in lib/closconv.chiral (ty-of/collect/arm/rewrite) for the
   fixpoint + the differential.
Then: emit fully lowers → wire compile as one Sig → single artifact → fixpoint.

## ✅ str-eqf DONE + the poly-13 REMAINING EDGE (measured, precise)
- **str-eqf wrapper landed** (byte-compatible, 649 green): the alist comparators
  defunctionalize; one-image `type does not lower` 13→1.
- **The remaining edge = `$W`-case:** the poly `(-> K K Bool)` family's `$apply`
  is installed over the `$W` opaque word carrier (the kernel rejects the concrete
  version — no "any word" type), so its `case` scrutinee is `$W`→WORD, and
  `lower.py.tail`/`expr` require `sty[0]=="Data"` → raises "case on non-data"
  (lower.py:266/313). So the poly defs (alist-put/alist-get/m-lookup) minted a
  `$apply` but it won't lower. **Fix options:** (a) teach the lowerer to recover
  the `$clo<i>` Data type for a `$W`-typed case whose scrutinee is a known `$clo`
  (carry the clo data-name alongside the WORD), or (b) install the poly `$apply`'s
  case over the real `$clo<i>` Data type (not `$W`) while keeping `$W`-typed
  arg/return — the discriminant is Data even if the payload words are opaque.
  (b) is likely cleaner: the `$clo` scrutinee IS a data type; only its fields are
  word-erased. Then mirror in lib/closconv.chiral + lib/lower.chiral.
  **REFINED (tested):** the scrutinee is already Data (`ttype($clo1)`=Data); the
  ACTUAL culprit is the `$apply`'s RETURN — the `$W` fallback (closconv.py:514)
  sets cod=`$W`, but a comparator returns Bool and the CALLER cases on that
  result → `$W`→WORD → "case on non-data". Fix = keep the family's real `cod` for
  the return in the `$W` fallback, ONLY `$W` the domains. BUT: using `cod` raw
  breaks when cod is itself a `$clo` (a closure-returning family) — "Pi codomain
  is not a type ($clo0)". So: **cod if it is a valid ground codomain (prim/data
  type, not a bare `$clo`/neutral), else `$W`.** One guarded line at closconv.py:
  514 + the chirality mirror. That unblocks the alist/map cascade (place→
  resolve-label→materialize→assemble→emit). Do it fresh (trusted-core, careful).
  **CORRECTION (tested, my "one line" estimate was WRONG):** the guarded-cod
  change (cod if PrimTy/non-$clo TCon else $W) did NOT unblock it — one-image
  stays 628, alist-put still "case on non-data". Diagnosis: alist-put uses
  `$apply0` and cases on its result, but `$apply0` apparently takes the CONCRETE
  synth path (str-eqf is concrete Str), so it never hits the $W fallback — the
  return-typing layer is elsewhere. The poly-comparator $apply has interacting
  layers (concrete-vs-$W classification, the call passing poly-K args to a
  concrete-Str $apply, and the result's data-ness) that need dedicated tracing,
  NOT a one-liner. This is the genuine remaining hard edge. Reverted; closconv
  clean. Next session: trace `$apply0`'s exact type + how alist-put's call to it
  type-checks, before touching the synth.
- One-image residue after that: 8 case-on-non-data (all the poly $apply/defs),
  5 partial-application (check-len/op-bytes/x64$1/x64$2 = lifted `=>` fields),
  1 higher-order (x64-peep). Small tail once $W-case is solved.

## AFTER emit lowers: wire compile-as-one-Sig
The MetisCompiler still uses 3 RTs + con-value shuttle. Now that co-load works,
replace with ONE Elab load of all modules → one lower_all → emit → one ELF. Then
Stage1==Stage2 fixpoint (compile own source twice, byte-compare). Then delete the
CPython bootstrap seed + rewrite the harness (external-language tests may keep
Python for now, per the goal).
