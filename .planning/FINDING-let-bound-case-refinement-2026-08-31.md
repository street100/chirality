> **Tracked row: `FD-02` in `records/findings.md`.** That row is what survives a fresh clone; this file is the long-form measurement and stays because the eliminated hypotheses and the mechanism are what the fix needs.

# FINDING: `let` over a `case` on a computed comparison cannot be proven

**2026-08-31.** Found porting `tools/paren-audit/paren-audit.py` to
`prog/paren-audit.prog` (wave 0 of `ZERO-PYTHON-SCOPE.md`). The port needed a
two-line minimum function and could not have one.

## Reproducer

Three lines. `chirality check` on each.

```chiral
(import "prelude/prelude")

; FAILS -- load: cannot prove refinement
(def imin (-> I64 I64 I64)
  (lam (a b) (let (m (case (<i a b) (true a) (false b))) m)))
```

## What changes the verdict

| form | verdict |
|---|---|
| `(let (m (case (<i a b) (true a) (false b))) m)` | **cannot prove refinement** |
| `(let (m (cond ((<i a b) a) (else b))) m)` | **cannot prove refinement** |
| `(case (<i a b) (true a) (false b))` — same case, not let-bound | OK |
| `(let (m (case (<i a b) (true 1) (false 2))) m)` — literal arms | OK |
| `(let (m (case p (true a) (false b))) m)` — `p` a `Bool` **parameter** | OK |
| `(let (m (imin2 a b)) m)` — the case moved into a top-level def | OK |

So the trigger is narrow and it is all four of these at once:

1. a `case`,
2. whose **scrutinee is a computed comparison** (`(<i a b)`), not a `Bool` that
   arrived as a variable,
3. whose **arms return bound variables**, not literals,
4. and whose result is **`let`-bound** rather than returned directly.

`cond` fails identically, which is expected: it desugars to `case`.

## Why it matters

This is `min`. Writing `min` or `max` over two I64s and naming the result is the
most ordinary thing in the language, and the checker refuses it. `prelude/map`'s
`i64-max2` survives only because it returns the `cond` directly instead of
binding it:

```chiral
(def i64-max2 (-> I64 I64 I64)
  (lam (a b) (cond ((<i a b) b) (else a))))
```

Add one `let` around that body and the prelude stops checking.

The error is also unhelpful. `load: cannot prove refinement` names no term, no
line, and no refinement. E157 gave the checker a typed `Reason`, and this
judgment (`jg-refine-unproved`, `lib/typing/diag.chiral:442`) is one that
carries none of the evidence a reader needs. It cost a bisect down from a
240-line file to three lines to find out which construct was refused.

## Where it probably lives

The comparison `(<i a b)` refines the scrutinee, so the two arms are checked
under different assumptions (`a < b` and its negation) and their result types
carry different refinements. Returning the case directly checks each arm against
the declared codomain separately. Binding it forces a **join** of the two arms'
refinements first, and the join is what cannot be proven. Literal arms have no
variable refinement to join, which is why they pass; a `Bool` parameter provides
no comparison to refine on, which is why that passes too.

That is a hypothesis from the outside. It has not been confirmed in
`lib/typing/`.

## Not fixed here

It is in the checker, on the compiler's own path, so a fix carries a self-host
fixpoint. No `E#` is minted, so nothing is deferred to a phantom; mint the
catalog and ledger rows in the same change that fixes it.

Two things owed, and they are separable:

1. **The join.** Either prove it, or widen the bound result to the declared type
   when the join fails, which is what returning-directly already effectively does.
2. **The diagnostic.** `cannot prove refinement` should name the term and the
   two refinements it could not join. This is exactly E157's shape applied to a
   judgment E157 did not reach.

Workaround in the tree today: `prog/paren-audit.prog` puts the comparison in a
top-level `pa-min` and calls it, since a call's result binds fine.

---

## Diagnosis, 2026-08-31. The hypothesis above is REFUTED.

There is no join. The verdict depends on **source arm order**:

| form | verdict |
|---|---|
| `(lam (a b c) (let (m (case (<i a b) (true a) (false c))) m))` | FAILS |
| `(lam (a b c) (let (m (case (<i a b) (false c) (true a))) m))` | OK |

Same arms, same guard, other order. A join is commutative. This is
**first-arm-wins**: arm 1 is `infer`red, its type becomes the expected type, and
arms 2..n are `check`ed against it (`proc-branch2`, `lib/typing/kernel.chiral:1277`).

Also corrected: the table above says literal arms pass. That is a coincidence of
*both* arms being literals. `(let (m (case (<i a b) (true a) (false 2))) m)` FAILS.
So trigger point 3 in the four-part list is wrong.

### Mechanism

A branch-local assumption introduced by the narrow hook escapes the branch as the
case's inferred result type, and every later arm is then required to entail an
assumption that is false in it.

`narrow-branch` (kernel.chiral:1505) sees `(<i a b)` and rewrites `a`'s context
type to `(v-refine (v-primty "I64") ...)` carrying a symbolic fact keyed on `b`'s
de Bruijn level. Arm `true` infers `a` at exactly that refined type. `ensure-escapes`
(kernel.chiral:1245) does not stop it: it is built to catch *binder* escape and
cannot see *assumption* escape, because the refinement mentions `a` and `b`, both
legitimately in scope outside. So `rty := {I64 | < b}`.

Arm `false` is then checked against `{I64 | < b}` with `b : {I64 | s-le lvl_a}`.
`check` (kernel.chiral:937) intercepts a `v-refine` want before `check-body`, so
`subsume`/`subtype` is never reached. `check-against` (kernel.chiral:1428) calls
`refine-entails?` -> `entails` (`lib/typing/refine.chiral:93`), whose symbolic leg
`sym-subset` (refine.chiral:86) is a syntactic subset test. It says no. Refusal at
**kernel.chiral:1440**.

`let` is the trigger because `check-let` (kernel.chiral:983) unconditionally
`infer`s the bound value. Returned directly, the case is reached through
`check-body` (kernel.chiral:963) with the declared codomain, so every arm takes the
`(some rtv)` path and the `refine <: base` forgetting rule applies
(kernel.chiral:806-808). `let` is the sole construct that drops into infer mode,
and that is the entire scope of the defect. `(the I64 ...)` restores check mode via
`infer-ann2` (kernel.chiral:929), which is why the one-line workaround works.

The `ujoin` at kernel.chiral:1297 joins QTT usage vectors. It is not a type join,
and it is probably what the hypothesis was seeing.

### Why the tree survives it

Every `def` carries a `declare`d type, so the compiler's own sources sit in check
mode, which propagates through `proc-branch2`'s `(some rtv)` arm to any depth.
`lib/evidence/harness.chiral:17-19` is the same shape and checks only because
`run-python-suite` is declared at line 9.

### The two candidate fixes, assessed

**Fix (b), widen the bound result, is unsound.** In infer mode there is no declared
type; that is what makes it infer mode. The reachable reading is blanket widening,
stripping `v-refine` from arm 1 before seeding `rty`. Two lines, fixes `imin`, and
regresses code that checks today:

```chiral
(def pos (-> (refine I64 (> 0)) I64) (lam (x) x))
(def pick (-> Bool (refine I64 (> 0)) (refine I64 (> 0)) I64)
  (lam (p a b) (let (m (case p (true a) (false b))) (pos m))))
```

Both arms carry a *declared* refinement, so `entails` succeeds and `(pos m)` goes
through. Under blanket widening `m : I64` and it fails. It discards refinements
that were never branch-local, trading one false refusal for another.

**Fix (a) is coherent, and it means writing a join rather than proving one.** A real
`c-join : Constraint -> Constraint -> Constraint` in `refine.chiral` (lo = min,
hi = max, ex = set intersection, sym = fact intersection). All four helpers already
exist there: `max-lo`, `min-hi`, `i64-mem`, `fact-mem`. Then `proc-branch2`'s
`(some rtv)` arm, on `ck-err`, re-`infer`s the arm and threads the joined type
forward. `CaseSt`'s `rty` is already threaded and already rewritten at
`branch-finish` (kernel.chiral:1289). For `imin` the sym intersection is empty, so
`c-top`, so plain `I64`. Sound because `entails c1 (join c1 c2)` holds by
construction, so earlier arms stay valid.

**A third shape, more surgical.** The bug is assumption escape, and `ensure-escapes`
is already the function whose job is "a branch-inferred type must make sense
outside", testing the wrong thing. In `proc-branch2`'s `none` arm, when
`narrow-branch c scrut cn` differs from `c`, re-derive the arm's type in the
un-narrowed context and seed `rty` from that. `imin` becomes plain `I64`; `pick`
keeps `{>0}`, since that refinement is declared rather than narrowed. No new
decision procedure. Weak where an arm only typechecks *under* the guard, which
lands back on (a).

### Verdict: this needs a blueprint

Three coherent shapes that differ in what they preserve. Choosing between "join the
constraint lattice" and "discharge the assumption at the branch boundary" is a
design decision about what a refinement means across a case. Run the pipeline.
Mint the element in the change that fixes it. ⚑ E174 is NOT free: `docs/examples/E174-r-row-width.md` exists with an INDEX row, as do E175 and E181. Highest artifact anywhere is E181, so the next free number is **E182**. Corrected 2026-09-01.

### The diagnostic half is blocked deeper than this finding assumed

Evidence exists at the emit site: `check-against` has `t`, `base`, `cns`, `ity` and
`c` in scope, and `quote-val` (kernel.chiral:775) plus `refine-atoms`
(kernel.chiral:1362) can rebuild the terms. The blockers are downstream.

1. No `Reason` arm fits. A faithful `r-refine-unproved` costs an arm in all seven
   exhaustive `case`s over `Reason` in `diag.chiral` (146, 194, 210, 224, 260, 274,
   318); there is deliberately no `_` (diag.chiral:314-315).
2. **Nothing in the tree can print a surface `Term`.** `dg-mismatch-msg` is
   `(lam (w) "type mismatch")` (diag.chiral:346). E158 has **zero code** in `lib/`
   or `prog/`, only two comment references. `lib/typing/pretty.chiral` is not it: it
   declares its own private 5-former `Term` (pretty.chiral:15-20) and has no
   importers.
3. Binder names are gone. `Ctx` is `(ctx-bind (q Qty) (ty Value) (rest Ctx))`
   (kernel.chiral:404) and `t-lam` has no name field
   (`lib/surface/syntax.chiral:18-34`). The best a printer could say is
   `{I64 | < #1}`. Readable names need binder names threaded into `Ctx`, a larger
   element.

Cheap and real today: kernel.chiral:1439 and 1440 are two different refusals
collapsed into one string. Splitting `jg-refine-unproved` into two `Judg` arms
costs one arm in one `case` (`dg-judg-msg`, diag.chiral:421 region) and needs no new
evidence shape. The printer is the prerequisite for the rest, so it sequences first.

### Self-host risk

- The fix lands in `lib/typing/kernel.chiral`, which every front-end path imports.
  The fixpoint rebuild recompiles the whole tree.
- `diag.chiral:20-25` documents a live landmine: a `case` on `Reason`/`Subject`/`Judg`
  must be the direct body of a `lam`, never nested in a case arm, or a real compiler
  "unknown name" bug fires. Any new arm inherits that.
- `kernel.chiral:817-818` states the helpers are split so parens stay locally
  countable. A join goes in a new top-level helper, never inline in `proc-branch2`.
