---
node: totality
layer: foundation
related: [decision-graded-kernel, decision-effect-facets, status-ledger, open-edges, floor-agreement, design-principles]
status: draft
updated: 2026-07-23
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
keeps the refinement layer **sound at runtime** (`chirality/refine.py`,
[[decision-graded-kernel]] item 1): a diverging term inhabits every type, so a
solver-discharged refinement `{i < 16}` would be a lie if the term proving it
could loop. Totality is the floor those two stand on.

## The three pillars

The standard minimal totality kit is three checks, each ruling out one way a
program can fail to be total:

| Pillar | Rules out | Where | Status |
|---|---|---|---|
| **Strict positivity** | non-well-founded *data* (a type whose values can't be built finitely) | `data.py`, per-parameter variance | IMPLEMENTED |
| **Case coverage** | a *match* that gets stuck on an unhandled constructor | `data.py` `_check_case` (exhaustive-or-default) | IMPLEMENTED |
| **Structural recursion** | a *recursion* that never bottoms out | `data.py` `check_termination` | IMPLEMENTED (classifier) |

Positivity makes the data well-founded; coverage makes matching total; structural
recursion makes the recursion total. All three live in the types module, not the
kernel core, because each must see through `Con`/`Case`, which the kernel core
does not understand ([[status-ledger]]). The kernel calls the recursion check
through `sig.def_hooks` after a def type-checks.

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
of `chirality/refine.py`): an increment `i` with an upper bound `i < H` learned from a
guard, or a decrement with a lower bound. The measure is the distance to the
bound (`H - i`), and the argument is sound because the guard is **re-checked every
iteration** — `i` steps monotonically, so after finitely many steps it crosses
the bound and the recursing branch is not taken.

`row-bytes` in the sprite demo — `(<=i 16 i)` guards `(row-bytes row (+ i 1))` —
now proves total this way, as does every counting loop with a constant guard.

The bound must **exclude the two's-complement wraparound point** (`hi ≤ MAX − k`,
`lo ≥ MIN − k`): a vacuous bound at the extreme (`i ≤ MAX`, then `i + 1`) would
otherwise "prove" a loop that actually wraps `MAX → MIN` and never stops. That is
where wrapping `I64` would have made a naive measure unsound; the exclusion is what
keeps it sound.

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

- **non-unit or non-strict symbolic steps** — `(+ i 2)` against a variable bound,
  or a `≤` guard, where the wraparound argument no longer holds;
- **size-change** recursion — the descent is real but not on a single argument
  (argument-permuting groups; the reserved fallback beyond E50's cheap tier);
- **lexicographic descent and mutual recursion without a declared measure** —
  since 2026-07-28 (E50) both PROVE when the recursion group declares a shared
  measure (`(measure structural <argpos>)` or
  `(measure lexicographic (<argpos> structural|numeric) …)` on the forward
  `declare`s; declared, never inferred — certificate discipline: the checker
  only re-checks the measure, and a false one is rejected). An undeclared
  mutual group still classifies not-proven with the mutual-recursion reason.

Two shapes it cannot analyze at all it names explicitly: a definition **used as a
value** (passed to a higher-order function rather than called), whose future call
sites are out of view — inside a measured group this poisons the whole group's
verdict; and a **forward reference** to a declared-but-undefined global outside
any measured group, the unmeasured-mutual case.

## Classify now, enforce later

With the numeric measure, the loops that would have forced this open — the
counting loops the structural rule misses — now prove, so mandatory totality no
longer rejects them wholesale. But it is still not the default, because genuine
gaps remain (non-unit or non-strict symbolic steps, size-change/argument-
permuting descent, mutual groups that declare no measure), and blocking
those outright would reject terminating code the checker simply cannot yet see.
The honest response is not to overclaim by forcing it ([[design-principles]]).

So the checker **classifies, it does not yet enforce by default**. Every def
records a verdict in `sig.totality[name]`: `None` if proven total, else the reason
it could not be proven. `sig.require_total` (default `False`) flips classification
into rejection — available now for code that wants the guarantee, and the
intended default once the remaining gaps close. This is the [[status-ledger]]
distinction made operational: totality is **IMPLEMENTED** (the analysis is sound —
structural *and* numeric — and runs on every def) but not yet globally
**ENFORCED**, and the ledger says exactly that rather than overclaiming.

## The profile gate

The per-def ledger is what a **profile** demands totality against. A profile that
carries a bare `(total)` clause asserts it is the sub-category where every
morphism is total (open-edge 9); `chirality verify` discharges that by checking every
def in the composite has `sig.totality[name] is None`, and reports each holdout
with its reason:

```
profile p: VALID   (target totalizer: 1/1; port set: respected; total: proven)
profile p: INVALID (target totalizer: 1/1; port set: respected; total: violated)
  def spin not proven total: no argument position decreases in every recursive ...
```

This is the same shape as the profile's other conformance rows — the target
requirement type and the frozen port set — a *composition-time* judgment over the
loaded composite, not a load-time gate. `sig.require_total` is the orthogonal
load-time enforcer for code that wants the guarantee eagerly; the profile clause
is the declarative, per-composite version, and is how chirality-verify becomes a real
gate rather than a description. (`demo/verify-total.chiral` is a worked example.)
Scope is the whole composite, as it is for the port set; reachability-scoped
totality is the same refinement the port check will eventually want.

## The promotion path

The symbolic refinement slice has since **landed**: `chirality/refine.py` carries
strict variable-vs-variable facts (`v < n`) beside the constant intervals, the
variable-bound measure above consumes them, and the pool offset is compile-time
bounds-checked (`mem-put-checked`). What remains is catalogued. The fuller
completion is **sized types** (E47, not built): a size index on a datatype turns
"smaller" from a syntactic fact into a typed measure, subsuming both structural
and numeric descent, and a size index is close enough to a cost grade that if
sized types land they reuse the semiring machinery ([[decision-graded-kernel]]
item 2) — the one place totality touches the grade vector. Beside it sits
**lexicographic / mutual descent** (E50, **built 2026-07-28** at the cheap
tier — a declared shared measure per recursion group; the full size-change
graph for argument-permuting groups is the deferred residue). Flipping
enforcement on by default is E11's owed payload, **gated on E47 + E50** —
E50 now satisfied, E47 (sized types) remaining — flipped earlier it would
reject real terminating code. Until then,
`require_total` (and the `(total)` profile clause) gates the guarantee, and the
per-def ledger records how much of the corpus already clears the bar —
structural, constant-bounded, strict-`±1` variable-bounded numeric, and
declared-measure mutual/lexicographic groups today.
