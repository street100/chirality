---
node: totality
layer: foundation
related: [decision-graded-kernel, decision-effect-facets, status-ledger, open-edges, floor-agreement, design-principles, decision-scope]
status: current
updated: 2026-09-04
---

# Totality

Totality is the decision ([[decision-graded-kernel]] item 2) that a chirality
function is **total by default** — it returns, on every input, without looping or
getting stuck. Partiality is the marked climb, not the baseline — the mark is a
tracked modality in which partiality now stands *alone*
([[decision-effect-facets]] amending the graded-kernel decision: alarms are
crossings on the membrane, not modality-mates). Totality is not
a grade in the coeffect semiring; it is a *property* checked beside the grades,
because "does it return" is a yes/no fact about a definition, not a quantity that
adds and multiplies.

It earns its keep twice. It is the **license to evaluate at generation time**:
the fold optimizer and the pregenerator ([[floor-agreement]]) may run a subterm
early only because a total subterm cannot hang the generator. And it is what
keeps the refinement layer **sound at runtime** (`lib/typing/refine.chiral`,
[[decision-graded-kernel]] item 1): a diverging term inhabits every type, so a
solver-discharged refinement `{i < 16}` would be a lie if the term proving it
could loop. Totality is the floor those two stand on.

## The three pillars

The standard minimal totality kit is three checks, each ruling out one way a
program can fail to be total:

| Pillar | Rules out | Where | Status |
|---|---|---|---|
| **Strict positivity** | non-well-founded *data* (a type whose values can't be built finitely) | `lib/surface/data.chiral` + `lib/module/loader.chiral`, per-parameter variance | IMPLEMENTED, refuses |
| **Case coverage** | a *match* that gets stuck on an unhandled constructor | `lib/typing/kernel.chiral` + `lib/typing/diag.chiral` (`non-exhaustive case`) | IMPLEMENTED, refuses |
| **Structural recursion** | a *recursion* that never bottoms out | `lib/typing/totality.chiral`, reached by `lib/typing/totality-check.chiral` | IMPLEMENTED (classifier), refuses under `(total)` |

Positivity makes the data well-founded; coverage makes matching total; structural
recursion makes the recursion total. All three live outside the kernel core,
because each must see through `Con`/`Case`, which the kernel core does not
understand ([[status-ledger]]).

⚑ **The three do not refuse alike.** Positivity and coverage refuse on every
compile. Termination classifies on every compile and refuses only where a profile
carries `(total)`, which the profile-gate section below states exactly.

## The structural-recursion criterion

A self-recursive def is **proven total** when some fixed argument position is
*strictly structurally smaller* in every self-call. "Structurally smaller" means
the argument is a variable introduced by pattern-matching (a `case`) on the
corresponding parameter — directly, or through nested matches, which carry the
same size root. A uniform decreasing position is a well-founded measure, so the
recursion descends and must stop.

`length`, `append`, `foldl`, `filter`, `alist-get` all pass: each recurses on the
list tail bound by casing its list parameter. Because the check demands *one*
position that decreases in *every* call, it is sound — it never marks a looping
def total by this criterion.

### The numeric measure

A second measure covers **bounded numeric recursion**, the loops the structural
rule misses. A self-call is decreasing at position `j` when the argument is a
constant step of parameter `j` — `(+ i k)` or `(- i k)` — *toward* a constant
bound that the guards on the path to the call establish (via the path-sensitivity
of `lib/typing/refine.chiral`): an increment `i` with an upper bound `i < H` learned from a
guard, or a decrement with a lower bound. The measure is the distance to the
bound (`H - i`), and the argument is sound because the guard is **re-checked every
iteration** — `i` steps monotonically, so after finitely many steps it crosses
the bound and the recursing branch is not taken.

`row-bytes` in the sprite demo — `(<=i 16 i)` guards `(row-bytes row (+ i 1))` —
proves total this way, as does every counting loop with a constant guard.

The bound must **exclude the two's-complement wraparound point** (`hi ≤ MAX − k`,
`lo ≥ MIN − k`): a vacuous bound at the extreme (`i ≤ MAX`, then `i + 1`) would
otherwise "prove" a loop that actually wraps `MAX → MIN` and never stops. That is
where wrapping `I64` would have made a naive measure unsound; the exclusion is what
keeps it sound. `num-dec-ok` in `lib/typing/totality.chiral` carries that proof
against the real `I64-MAX` and `I64-MIN` constants.

The bound may also be a **variable**: `(f (+ i 1))` guarded by the strict
`(<i i n)` proves total when the step is `±1` and the recursive call passes `n`
**unchanged** — the measure is `n − i`, well-founded because `n` stays fixed while
`i` climbs to it. Two conditions keep it sound where a naive rule would not:
the step must be exactly `±1` (a bigger step could overflow past a near-`MAX`
`n`), and `n` must be invariant (a growing `n` would outrun `i` and the distance
never shrink). A strict `<` needs no wraparound guard here — `i < n ≤ MAX` already
forces `i + 1 ≤ n`. This is the symbolic slice of the measure, mirroring the
symbolic refinement bound.

### What it still does not prove

- **a bound that is a call rather than a variable** — `(str-len s)` as the `n` in
  `(<i i (str-len s))`. The checker reads a bare in-scope variable and reads no
  call, so every index walk over a `Str` or a `Bytes` classifies not-proven. This
  is the largest measured class, and the measurement section below counts it;
- **non-unit or non-strict symbolic steps** — `(+ i 2)` against a variable bound,
  or a `≤` guard, where the wraparound argument no longer holds;
- **size-change** recursion — the descent is real but not on a single argument
  (argument-permuting groups; the reserved fallback beyond E50's cheap tier);
- **a measure spread over two arguments** — merge sort descends on the sum of two
  list lengths and on neither list alone, so the one-position rule misses it;
- **lexicographic descent and mutual recursion**. ⚑ `lib/typing/totality.chiral`
  scopes both **out** of E11 and assigns them to E50, whose catalog row reads
  `not built`. A mutual group classifies not-proven with the mutual-recursion
  reason, and no `(measure …)` clause exists in the surface today.

Two shapes it cannot analyze at all it names explicitly: a definition **used as a
value** (passed to a higher-order function rather than called), whose future call
sites are out of view; and a **forward reference** to a declared-but-undefined
global. Both return the `used-as-value` verdict.

## What the compiler does

The classifier is a **pure function returning a value**. `lib/typing/totality.chiral`
declares

```
(data Verdict () (total) (not-total (reason Str)))
```

and `lib/typing/totality-check.chiral` exposes the one entry a caller reads:

```
(declare tot-of-def (-> Str Term Verdict))
```

`tot-of-def` takes a def's name and its kernel `Term` body, translates the
kernel's sixteen-constructor `Term` into the classifier's six-constructor
`TotTerm` (de Bruijn index to level, the curried spine unwound, `t-let` and
`t-pi` kept as binders the walk can count), and returns a `Verdict`. It raises
nothing and mutates nothing. Its own recursion walks a finite `TotTerm` tree
structurally, so the classifier certifies itself.

⚑ **There is no per-def ledger and no load-time switch.** The Python oracle
carried `sig.totality[name]` and a `sig.require_total` flag; that oracle is CUT
([[decision-scope]] consequence 1) and neither has a native referent. There is
also no `chirality verify` subcommand: `bin/chirality` dispatches `compile`,
`run`, `check` and `test`. A verdict exists while `tot-of-def` is on the stack
and is consumed by the profile gate below.

## The profile gate

A profile that carries a bare `(total)` clause asserts it is the sub-category
where every morphism is total (open-edge 9). `tot-gate` discharges it:

```
(data TotalR () (tot-proven) (tot-holdout (name Str) (reason Str)))
(declare tot-gate (-> Sig TotalR))
```

`tot-gate` reads the composite's profile list first. **A source that declares no
`(total)` profile pays nothing**: the gate returns `tot-proven` without
classifying a single def. Where some profile does carry the clause, `tot-scan`
walks every global in the `Sig`, calls `tot-of-def` on each, and stops at the
**first** holdout with its reason. One name is what the report needs, so the scan
builds no list.

`lib/lowering/compile-front.chiral` is the caller. It runs the gate between the
load and the peel, which is the last point that holds a whole checked `Sig` and
the last point where the bodies are still the ones the loader stored, before
`specialize-singletons` and `closconv-sig` rewrite them. A holdout becomes a
front-end error and the compile stops:

```
profile (total): def spin not proven total: no argument position decreases in
every recursive call by a measure the checker can see ...
```

Measured 2026-09-02: `(profile p (ports halt) (target totalizer) (total))` over
`(def spin (-> I64 I64) (lam (i) (spin (+ i 1))))` fails `chirality check` with
that sentence, and the same source with the clause dropped checks OK.

Scope is the whole composite, as it is for the port set. Reachability-scoped
totality is the same refinement the port check will eventually want.

⚑ **The gate is opt-in and no phase fails when it breaks.**
`tools/test/profile-target.sh` gates the clause's *parse*; nothing gates its
proof. `prog/demo/verify-total.chiral` is the worked example, and its own header
still invokes the retired `python3 -m chirality verify`.

## Measured: 40 holdouts over 1,469 defs

Over `prog/compiler.prog`'s own closure the classifier proved all but **40** defs,
**measured 2026-09-02**.

| where | holdouts |
|---|---|
| `lib/surface/sexp.chiral` | 10 |
| `lib/prelude/string.chiral` | 6 |
| `lib/lowering/mach/emit-core.chiral` | 5 |

The class is real rather than a bug. Three shapes account for it: index loops
whose bound is a **call** (`(str-len s)`) where the checker reads only a bare
variable; merge sort's **two-list measure** in `lib/prelude/list.chiral`, which
descends on no single argument; and `conv` in `lib/typing/kernel.chiral`, whose
termination is the strong-normalization axiom rather than a syntactic descent.

The consequence is concrete. **A `(total)` profile over any closure containing
`lib/prelude/string.chiral` is refused today**, and the first holdout the gate
names is `su-pad-go`. That one is honest: `su-pad-go` grows its accumulator by
`pad` until the accumulator reaches `width`, so an empty `pad` makes it diverge.
The refusal is correct there and conservative in the other 39 cases.

⚑ **This count predates today's compiler and has not been re-measured.**
`40e8726` changed `lib/lowering/upper/lower.chiral`, which is inside
`prog/compiler.prog`'s closure, after the measurement was taken. Re-taking it
needs a classifier run over the current closure. [[status-ledger]] carries the
same figure on its build-state row.

## The promotion path

The symbolic refinement slice has landed: `lib/typing/refine.chiral` carries
strict variable-vs-variable facts (`v < n`) beside the constant intervals, the
variable-bound measure above consumes them, and the pool offset is compile-time
bounds-checked (`mem-put-checked` in `lib/memory/mem-linear.chiral`). What
remains is catalogued.

| what | element | state |
|---|---|---|
| Sized types: a size index turns "smaller" from a syntactic fact into a typed measure | E47 | not built |
| Lexicographic and mutual descent | E50 | not built |
| Flipping enforcement on by default | E11's owed payload, gated on E47 + E50 | not flipped |

A size index is close enough to a cost grade that if sized types land they reuse
the semiring machinery ([[decision-graded-kernel]] item 2), which is the one
place totality touches the grade vector.

Flipped today, enforcement would reject real terminating code: the 40 holdouts
above are the evidence, and 39 of them terminate. Until E47 and E50 land, the
`(total)` profile clause is the whole of the guarantee, and a caller that wants it
per-def calls `tot-of-def` and reads the `Verdict`.
