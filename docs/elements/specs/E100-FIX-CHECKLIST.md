# E100 fix — polymorphic-HO defunctionalization: erase type-kinded captures

> **✅ DONE 2026-08-16** (commits `b402aff` sub-task 0, `ff6d72c` sub-tasks 1-5,
> `1bf585f` sub-task 7). All 8 sub-tasks landed. Fix = DROP type-kinded captures
> (one `field-erased?` predicate at every materialization point + `$apply` arm
> de-Bruijn re-addressing re-derived for the reduced capture count). Verified by the
> runtime gate `scaffold/tests/samples/e100_poly_ho.chiral` (5 cases, exit 0);
> self-host fixpoint holds at gen3 (gen3==gen4, one-generation promotion lag, 1020280
> B); workaround dropped, manas-run-conform `CONFORM: true` live. Only pre-existing
> orthogonal residue: capturing an HO *function* into a partial-app closure (fails
> identically on the old compiler — not part of E100).

## The bug (one line)
A polymorphic HO fn (`q=0` type params: `map-list`, `foldl`-with-a-named-fn, `papply`)
fails to defunctionalize because a captured **type variable** lands in a runtime capture
slot → the synthesized `$clo` gets a `t-type` ctor field → `term->ntalty`
(`compile-front.chiral:70`) returns `none` → `ctors->n`/`datas->n` silently drop the whole
`$clo` data → `$apply` hits "case on unknown data" (`lower.chiral:349`) → vanishes →
`map-list` pruned → entry pruned → surfaces only as "no emitted label".

**The fix, in one sentence:** erase type-kinded captures from closures — a `t-type`
capture is an erased-binder (`q0`) reference and must be DROPPED from the runtime closure,
not word-ified (word-ifying gives a dangling de Bruijn reference). Do it consistently
across every place the capture set is materialized or re-addressed.

## Checklist (ordered; each its own atomic commit + the closure-correctness test green)

- [x] **0. Blame-chain fix FIRST (so the surgery is debuggable).** `lower-defs`' `nil` case
  (`compile-back.chiral:241`) discards accumulated `le-skip` records — append `skips` so
  closure-lowering failures self-report instead of surfacing as a bare "no emitted label".
  Compiler-source change → self-host fixpoint. Low-risk (diagnostic only). *(This is why
  E100 cost hours to diagnose; do it up front.)* Also logged in `BUGS-AND-GAPS.md`.

- [x] **1. `$clo` ctor fields — drop type-kinded captures.** `mk-fields`
  (`closconv.chiral:701`) tags every capture `q2` and keeps its type verbatim, emitting
  `t-type` fields. Filter type-kinded captures out of the `$clo` field list (and
  `site-fields->term`). A `q0`/`t-type` capture carries no runtime witness → it must not
  become a field.

- [x] **2. `c-con` capture args + ckey.** `reg-lam`/`lam-con` build the closure
  construction args and the closure key. Drop the type-kinded captures from BOTH the arg
  list and the ckey so the ctor arity matches sub-task 1's field list, and so two lambdas
  differing only in erased type captures share a `$clo`/`$apply`.

- [x] **3. `$apply` arm-body de Bruijn re-addressing.** This is the delicate one: the
  capture count `m` ripples into every offset in the arm body (`lam-subst`/`cap-subst`/
  `own-subst` — the `m+v`, `m-1-j`, `2m+d-1-p` forms and the arm binder count). Dropping
  `k` type-kinded captures shifts `m → m-k` everywhere consistently. Re-derive each offset
  formula for the reduced `m`; an off-by-one here silently corrupts closures.

- [x] **4. Parallel `cs-g` path.** Partial application of a polymorphic global (e.g.
  `(alist-get A B)`) captures its type args via `gps`. Apply the same type-kinded-capture
  erasure there.

- [x] **5. VERIFICATION — the closure-correctness test (this substitutes for the ungated
  fixpoint).** The self-host fixpoint CANNOT catch a bug here (the compiler's own sources
  use no poly-HO defunctionalization, so a miscompile byte-reproduces the compiler cleanly
  and passes). So build a **runtime** test that exercises polymorphic HO closures and
  checks the RESULTS, not just that it compiles:
  - `map-list Str Str dup` over a list → assert the mapped list is correct.
  - `map-list Msg Json msg->json` (the original failing case) → assert the JSON.
  - `foldl` with a NAMED polymorphic fn (not an inline lambda) → assert the fold.
  - `papply`/partial-application of a polymorphic global → assert the applied result.
  - a closure capturing BOTH a type var AND a real value → assert the value survives and
    the type capture is correctly absent.
  Each must produce the RIGHT answer at runtime. This test passing = the fix is real.

- [x] **6. Self-host fixpoint** holds (`B2==B3`) AND **no-regression** (existing suite +
  scriba + manas samples compile byte-identically — the fix only enables a previously-
  failing lowering, existing lowerings unchanged).

- [x] **7. DROP THE WORKAROUND (the original cleanup).** Replace `foldl`+`append`
  map-list-avoidance with `map-list` in `runner.chiral` (`render-findings`, the manifest
  array) + `backend.chiral` (`chat-body`), delete the workaround comments, and confirm
  `manas-run-conform.chiral` still `CONFORM: true` live.

- [x] **8. Close it:** flip E100 LEDGER + catalog to `built`; clear §6b.

## Homes
`closconv.chiral` (`mk-fields`:701, `reg-lam`, `lam-con`, `lam-subst`/`cap-subst`/
`own-subst`, the `cs-g` path), `compile-front.chiral:70` (`term->ntalty`),
`compile-back.chiral:241` (`lower-defs` le-skip), `lower.chiral:349` ("case on unknown
data"). Runtime test: a new `tools/test/samples/e100_poly_ho.prog`.

## Why this is doable (not a rabbit hole)
The root cause is exact and the erasure principle is simple ("a `q0` type capture has no
runtime witness → drop it"). The only genuinely delicate part is sub-task 3's de Bruijn
offset re-derivation — which is mechanical once you hold `m → m-k` consistently, and is
exactly what sub-task 5's runtime test verifies. Sub-task 0 makes the whole thing
self-reporting so mistakes are visible, not silent.
