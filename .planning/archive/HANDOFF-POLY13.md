> **ARCHIVED 2026-09-01. Superseded by `.planning/archive/HANDOFF-RUNG1-FIXPOINT.md` and `docs/definitions/status-ledger.md`.** The part worth keeping legible is the **failed-attempts record**: the approaches that did not work on polymorphic specialization, kept so they are not retried.

# HANDOFF — the poly-13 closure-conversion blocker (read this first)

> ## ⚑ RESOLVED 2026-08-04 — poly-13 is FIXED (commits 4841d83, 63a0ef4)
> **poly-13 was misdiagnosed here.** The real cause was NOT `$W`-return lowering
> but **defunctionalization family keying**: closconv keyed a family's CODOMAIN
> by full erasure, so `(-> K K Bool)` (alist) and `(-> K K Ord)` (map) collapsed
> to ONE `$apply` whose word-erased return broke the caller's `case`. The
> reverted "guarded-cod" attempt MISCOMPILED for exactly this reason (Bool-apply
> dispatching an Ord case → KeyError 'lt'). Two coupled fixes, both mirrored in
> `lib/closconv.chiral` + differential-tested:
> 1. `_cod_key`: domains still erase fully, but a GROUND non-arrow codomain stays
>    concrete (Bool ≠ Ord ≠ word). A variable cod (foldl's poly `B`) still erases.
> 2. Option-A keying: a function-value Global is keyed by the CALLEE-PARAM slot it
>    fills, not its own concrete type (both `_collect`/`scan-fvargs` and
>    `_rewrite`/`rw-global`), so `str-eqf` adopts alist's ground-Bool slot while a
>    closure passed to `foldl` adopts the variable-cod slot.
>
> **`alist-put`/`alist-get`/`alist-has`/`$apply0` now lower. A SECOND, unrelated
> closconv bug was also fixed (63a0ef4): a Global in call-HEAD position was being
> value-converted to a closure Con, breaking `x64-peep`'s own saturated self-call
> ("higher-order application"). A Global head is a direct call; only value-
> position Globals convert. `x64-peep` now lowers.** 649 green throughout.
>
> ### The handoff's "ONLY remaining gap" claim was WRONG.
> The emit path has SEPARATE pre-existing leaves (were cascade-masked behind
> alist): `x-mod-imm` (case on non-data), 5 partial-applications (`resolve-label`,
> `check-len`, `op-bytes`, `emit-jtb-bodies`, `x64$1/$2`), plus the HO combinators
> (`map-list`/`filter`/`foldl`/`m-lookup`…: "type does not lower" — never passed a
> concrete closure, so no ctor; need monomorphization or a real call site).
>
> ### E70 BLOCKER RESOLVED 2026-08-04 (commits a80cc94 `Op` + 2e01493 pre-pass).
> The author's call (see below) was neither A/B/C — it was the STRUCTURAL root:
> the tal-ir prim op was a `Str` validated once at erase then re-checked with a
> defensive `(halt "unknown prim")` in `op-bytes`. Replaced with a closed
> `(data Op …)` of the 11 native ops + `op-parse` at the erase boundary; every
> consumer matches it exhaustively, so `op-bytes`/`bini-body` are total+pure, the
> `halt` is GONE, and `emit-instr` never reaches the membrane. The row-escape
> stopped EXISTING rather than being accounted for (P1/P4/P2). Python floor stays
> Str-keyed via an Op↔Str translation at the single `native.py` shuttle edge.
> With the halt gone, the **fn_sig pre-pass landed** (RowEscape still propagates —
> safety intact): **631 → 905 / 984 lowered.** 649 green, byte-identical.
> **`emit-instr`, `op-bytes`, `$apply1`, `alist-*` all lower now.**
>
> **Remaining emit-path leaves (the NEXT work, separate pre-existing gaps):**
> `check-len`, `emit-jtb-bodies`, `resolve-label`, `x64$1`, `x64$2` (partial
> application); `x-mod-imm` (case on non-data); `find` + the HO combinators
> (`map-list`/`filter`/`foldl`/`m-lookup`: "type does not lower" — never passed a
> concrete closure). None are effect/E70 issues; they are the closconv/lowering
> coverage tail.
>
> ### (historical) NEXT BLOCKER surfaced (AUTHOR-SCOPE — E70): the fn_sig-prepass finding.
> A prototype **fn_sig pre-pass** in `lower_all` (install every eligible def's tal
> sig from its declared type before lowering any body, so direct calls resolve
> regardless of order — fixes the `$apply1`→`peep-hit` ordering cascade) jumped
> 631→901 lowered. It was **REVERTED** because it exposed a real
> **E70 row-inference-vs-specialization seam**: `emit-instr` reaches `halt` (via a
> defensive `(halt …)` trap in `op-bytes`, transitively through the byte emitters)
> but its INFERRED row omits `halt` — because row inference runs PRE-specialization,
> where `emit-instr`'s `(mach-binir m)` is an opaque higher-order Mach-record
> projection; the row-ESCAPE check runs POST-specialization, where it is a resolved
> `call x-binir` and `halt` surfaces. → `RowEscape` (a deliberate HARD module-reject
> per `test_row_escape_rejects_the_module`; must NOT be weakened to a skip).
> **Decision needed (author, E70 policy):** re-infer rows after specialization? make
> `op-bytes` total without the defensive `halt`? exempt total-trap `halt` from the
> row? Until then, the pre-pass cannot land. This is the true remaining self-host
> blocker, and it is an effect-membrane decision — not a mechanical chug.

**Goal:** rung 1 = zero Python. Immediate blocker: the chirality compiler's `emit`
image won't fully lower, so it can't self-compile. ~~The ONLY remaining coverage
gap is poly-13~~ (SEE RESOLVED BLOCK ABOVE — poly-13 fixed; the emit path has
other, separate leaves + an E70 blocker).

## State (all committed on `main`, 649 tests green, `git status` clean)
- **The 3-image split is GONE** — `compile-front`+`compile-back`+`compile-emit`
  co-load into ONE Elab. This was the deep structural blocker (con-value shuttle,
  P5 seam). 7 `unify(*)` commits: 12 type collisions + all ctor collisions renamed
  distinct (kernel `Term` vs tal `TalTerm`; tal-ir `ti-*`; lower `lc-*`/`lowbind`;
  `en-prim`; dup helpers `l-*`/`cb-*`), Python tal-machine + test builders synced.
- **Coverage done otherwise:** mach specialization pass (`chirality/specialize.py`),
  a-rel defunctionalization (`EncTag`, byte-correct), halt gate (A1), zero-Python
  run path (D1a execveat), `str-eqf` wrapper. compile-emit 237→271→one-image ~628.
- Full worklog: `.planning/UNIFICATION-WORKLOG.md`. Map: `.planning/CLUSTER-2-MAP.md`.

## Reproduce the blocker (one command)
```
cd scaffold && python3 -c "
from chirality.surface import Elab
from chirality.lower import lower_all
import collections
el=Elab()
for i in ['sys-linkage','compile-front','compile-back','compile-emit']: el.load_file('lib/'+i+'.chiral')
low,skip=lower_all(el.sig)
b=collections.Counter()
for n,r in skip.items(): b['CASCADE' if 'not lowered' in r else r.split(' (')[0]]+=1
print(len(low),'/',len(el.sig.global_defs)); [print(c,k) for k,c in b.most_common(6)]
print('alist-put:', skip.get('alist-put'))"
```
→ ~628 lower; the leaf is **8 "case on non-data"** (alist-put/alist-get/m-lookup/
`$apply0/1`), driving ~346 cascade (place→resolve-label→materialize→assemble→emit).

## The exact problem (traced, not guessed)
`alist-put`'s body applies its comparator param `(-> K K Bool)` and `case`s on
the result. closconv defunctionalizes: it mints `$clo0` + `$apply0` and rewrites
the application to `($apply0 clo k1 k2)`. But:
- The comparator family's **codomain is a dangling type variable `('Var', 2)`**
  (NOT `Bool` — closconv keys/peels it polymorphically), so the concrete kernel
  check fails and the `$W` (opaque word) fallback fires
  (`chirality/closconv.py` ~line 500-516).
- The `$W` fallback types `$apply0` as `(-> $clo0 $W $W $W)` — **return is `$W`**
  → `ttype` = WORD, not `Data`. So the caller's `(case ($apply0 …) (true..)(false..))`
  hits `lower.py:266/313` `raise Ineligible("case on non-data")` (needs a `Data`
  scrutinee). alist-put stays upper; everything downstream cascades.

## What was tried and FAILED (don't repeat)
1. **closconv "p" ctor kind** (collect Prims-as-function-values, since `str-eq` is
   an extern): collection worked (type-not-lower 13→1) but conversion left 55 HO
   sites + broke the ty-of differential. Superseded by (str-eqf) below. REVERTED.
2. **str-eqf wrapper** (LANDED, committed, byte-correct): `(def str-eqf (lam (a b)
   (str-eq a b)))` so the comparator is a Global (closconv collects Globals). This
   made the family defunctionalize — but exposed the `$W`-return problem above.
3. **guarded-cod** (keep `fam["cod"]` for the `$apply` return instead of `$W` when
   it's a ground type): FAILED — `fam["cod"]` is `('Var', 2)`, a poly type var, so
   the guard never fires. Also breaks when cod is a `$clo` (closure-returning
   family) → "Pi codomain is not a type". REVERTED.

## The real question to research (THIS is the crux)
This is the **poly-HO-defunctionalization vs dependent-typing tension** the B2
notes flagged (`.planning/SELF-COMPILE-FRONTIER-MAP.md`, "B2 CRUX"). The comparator
returns `Bool` concretely but is *used* at a polymorphic type `(-> K K Bool)`; the
`$apply` must accept both, so it's word-erased — but the erasure wrongly swallows
the CONCRETE `Bool` return that a caller needs to `case` on.

Research/decide:
- **Why is the family cod `Var 2` and not `Bool`?** Read closconv `_arrow_key` /
  `_erase_shape` (line ~221) / `fam()` (~356) / `_synth` (~468) / the `$W` install
  (~500-517) end to end. Is the family created from `alist-put`'s `(-> K K Bool)`
  where in that def's context `Bool` peels to a `Var`? Or is the erasure keying
  itself replacing `Bool`→word?
- **Can the `$apply` return keep the concrete `Bool`** while args stay `$W`?
  Options: (a) don't erase the codomain in `_erase_shape` when it's ground across
  all ctors; (b) recover the `$clo`/result Data type at the lower.py case site;
  (c) monomorphize the comparator instead of defunctionalizing (the map/B2 chose
  erasure over this, but for a SINGLE concrete comparator `str-eqf`,
  monomorphizing `alist-put`→`alist-put$str` may be far simpler).
- **Whatever the fix, it must NOT break the concrete closconv path** (ap/inc,
  escaping lambdas) that `tests/test_compile_run_chirality.py` depends on, and it
  needs a **mirror in `lib/closconv.chiral`** for the fixpoint.

## After poly-13 lowers (the rest is mechanical, not research)
1. Wire `compile` as ONE Sig: replace `MetisCompiler`'s 3-RT con-value shuttle
   (`tests/test_compile_run_chirality.py`) with one Elab load of all modules → one
   `lower_all` → emit → one ELF. (co-load now works, so this is straightforward.)
2. Stage1==Stage2 fixpoint: compile the compiler's own source twice, byte-compare
   (`ddc.chiral` / `fixpoint=?`).
3. Delete the CPython bootstrap seed (`scaffold/chirality/*.py`).
4. Rewrite the test harness off Python (external-language tests may keep Python
   for now, per the goal).

## Files that matter
- `scaffold/chirality/closconv.py` — the defunctionalization pass (the blocker).
- `scaffold/chirality/lower.py:261-317` — the `case on non-data` raise.
- `scaffold/lib/closconv.chiral` — the chirality mirror (must follow the Python fix).
- `scaffold/lib/collections.chiral` — alist-put/alist-get/m-* defs.
- `scaffold/lib/prelude.chiral` — `str-eq` extern + `str-eqf` wrapper.
