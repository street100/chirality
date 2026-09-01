# E17 EXTEND — auto-pregen v2 (unbounded policy)

**2026-08-06**
**Pipeline:** spec (E17 extension)
**Depends on:** E38 (graded cost), E57 (staging), fact-carrying lowering

---

## 1. Deliverable

Replace `optimize.autospec`'s hard-coded guards with a staging-aware,
cost-model-driven policy. The compiler decides automatically what to
specialize, using type-level stage annotations and cost grades.

## 2. Baseline delta

### Current autospec (bounded, built 2026-08-02)

```python
_AUTOSPEC_ROUNDS = 3       # arbitrary cascade limit
_AUTOSPEC_MAX_SIZE = 48    # arbitrary size threshold
# skip self-recursion       # conservative — never specialize a loop
# skip non-const calls      # no attempt to specialize through function calls
```

The policy: scan lowered TAL functions. Find call sites where arguments are
`const` instructions. If the target is ≤48 instructions, doesn't call itself,
and the arguments are I64 constants, specialize. Repeat up to 3 times for
cascade.

### What's wrong

1. **48 is arbitrary.** A 50-instruction function with a static keymap has
   exactly the same pregen semantics as a 47-instruction function. The cutoff
   is wrong — it should be a cost decision, not a size threshold.

2. **No self-recursion is too conservative.** A recursive function with a
   static decreasing argument (e.g., unrolling a `for i in 0..n` where `n`
   is static) SHOULD specialize on `n`. The current policy refuses.

3. **Const detection is fragile.** The compiler looks for `const` instructions
   in the TAL. But `const 42` followed by `call f(42)` vs `call f(CONST_42)`
   where `CONST_42` is a named constant — the latter is missed. Stage
   annotations (`□`) make statieness structural, not instruction-pattern-based.

4. **3 rounds is a guess.** After the staging modality, the cascade depth is
   the stage depth — specialize at compile time, then at link time, then at
   init time. No arbitrary cap.

### Target autospec v2

The policy: scan lowered TAL functions. A call site `(call dst target args...)`
is eligible for specialization when:
1. The target has `□` parameters (statically known — E57)
2. The arguments are `□` values (available at this stage — E57)
3. The target is total (safe to run early — Fork B, already settled)
4. The cost of specializing is less than the cost of not specializing (E38)
5. Specializing the target on these args doesn't exceed the code-size budget
   (E38 — the space grade)

The compiler specializes. No arbitrary thresholds. The type system provides
the information; the cost model makes the decision.

## 3. Dispositioned decisions

### Decision 1: specialization trigger

**RESOLVED — □ parameters with □ arguments.** When a function has at least
one `□` parameter and a call site provides a `□` argument for it, the call
site is eligible. No manual `(specialize ...)` annotation needed. The
compiler decides.

**Rejected:** "specialize everything with const args" (current behavior) —
too aggressive, no cost model. "Only specialize when annotated" — too
conservative, requires programmer effort for every site.

### Decision 2: cost model

**RESOLVED — heuristic, not formal (first version).** Full E38 graded cost
is a large build. For v2, use a simple heuristic:

```
cost(specialize) = code_size_growth (bytes of TAL)
benefit(specialize) = instructions_saved_per_call × call_frequency_estimate

specialize if benefit > cost × COST_WEIGHT (default: 1.0)
```

- `code_size_growth`: the size of the specialized residual minus the size
  of the original call site (which is always 1 instruction after inlining).
- `instructions_saved_per_call`: the number of instructions in the original
  function that become dead after specializing (const-folded branches,
  elided map lookups).
- `call_frequency_estimate`: static heuristic — 1 for non-loop sites, 10
  for loop-body sites, 100 for doubly-nested loop sites.

**DEFERRED — formal E38 grade comparison.** When E38 lands, replace the
heuristic with grade arithmetic: `time_grade(specialized) <
time_grade(original)`.

### Decision 3: self-recursion

**RESOLVED — allowed when the recursion argument is a `○` natural number.**
If a function calls itself with a decreasing `○I64` argument, and the base
case is reachable (structural recursion, already checked by the totality
checker), then specializing N times for a static N is safe. The compiler
unrolls the recursion N times and produces a straight-line residual.

**Guard:** the compiler MUST verify that the recursion is structural (the
totality checker already proves this). If the totality checker can't prove
termination, the function is not total, and Fork B prevents specialization
entirely.

### Decision 4: cascade policy

**RESOLVED — stage-driven, not round-limited.** After specializing, the
residual has fewer `□` parameters (the static ones were bound). If the
residual still has `□` parameters, it is itself eligible for further
specialization. The cascade depth is the number of `□` parameters in the
original function — not an arbitrary cap. When all `□` parameters are
bound, the cascade terminates naturally.

### Decision 5: code-size budget

**RESOLVED — configurable, default generous.** A profile-level setting
controls the total code-size budget for auto-specialization:

```chirality
; In the target profile:
(profile pregen-budget (0 budget I64))  ; max total bytes of specialized residuals
```

Default: 64KB for Phase 1 (generous — scriba's keymap dispatch is ~2KB
specialized). If specialization would exceed the budget, the compiler
ranks candidates by `benefit/cost` ratio and specializes the top N.

## 4. Change plan (commit-sized steps)

### Step 1 — Stage-aware autospec detection

Replace `const`-instruction detection with `□` parameter detection. A TAL
function annotated with `□` parameters (from E57 lowering) marks those
parameters as static. Call sites with `□` arguments (also from E57 lowering)
are eligible. This step depends on E57 step 1 (two-level staging spine).

### Step 2 — Cost heuristic

Implement the benefit/cost heuristic from Decision 2. Replace
`_AUTOSPEC_MAX_SIZE` with the heuristic. Keep `_AUTOSPEC_ROUNDS` for now
(until cascade policy lands in step 4).

### Step 3 — Self-recursion with decreasing □ arg

Allow specialization targets that call themselves, if the recursion
argument is a `○I64` (dynamic) that decreases each call and the function
is total. The compiler verifies: the call site passes `○I64 - 1` or
similar decreasing expression. If `○I64` is 0, the base case is reached.

### Step 4 — Stage-driven cascade

Replace `_AUTOSPEC_ROUNDS` with □-parameter-driven cascade. After each
specialization pass, re-scan for remaining `□` parameters. Continue until
no `□` parameters remain or the budget is exhausted.

### Step 5 — Profile-level budget

Add `pregen-budget` to the profile clause. The compiler tracks total
specialized code size. When the budget would be exceeded, rank candidates
and specialize the best ones.

## 5. Conformance gate

- `test_optimize.py`: existing autospec tests pass (bounded behavior is a
  subset of unbounded behavior — the new policy should produce the same or
  more specializations).
- New test: `test_autospec_stage.py` — a function with `□` parameters gets
  specialized; a function without doesn't. Self-recursion with decreasing
  `○I64` argument unrolls correctly.
- New test: `test_autospec_budget.py` — the budget is respected; oversize
  specializations are skipped.
- PRESERVE-CHECK: every residual passes `tal.check_fn`. A broken
  specialization is a floor alarm.

## 6. Honest residue

- **`□` propagation through call chains.** If `f : □A → □B` and `g : □B → □C`,
  then `g(f(x))` could be specialized as a unit (`g∘f : □A → □C`). This is
  composition-based specialization — the next step after single-function
  specialization. Not in v2.
- **Dynamic call frequency.** The static heuristic (1/10/100) is crude.
  Profile-guided optimization with real call counts is Phase 3+.
- **Interaction with fact-carrying lowering.** When refinement facts survive
  into TAL, specialization can fold MORE. A function with `(refine I64 (>= 0)
  (< 100))` parameter, called with `50`, can fold not just the constant 50
  but also all the bounds checks that 50 satisfies. V2 handles constant
  folding; fact-driven folding waits on fact-carrying lowering.

---

**Related:** [[E17-optimizer]] · [[E38-graded-cost]] · [[E57-staging-modality]]
· `scaffold/chirality/optimize.py` (autospec) · `scaffold/bench/OPT-LEDGER.md` (#19)
· `.planning/FORK-C-UNROLLED.md`
