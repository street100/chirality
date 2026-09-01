# Fork C — the staging modality, unrolled

**2026-08-06**
**Decision document:** `docs/decision-graded-kernel.md` (settled 2026-07-21)

---

## What Fork C already decided

The graded-kernel decision settled three forks at once. Fork C is the third:

> 3. A modality, not a grade: binding time and staging. Static versus dynamic is
>    about when a value is available, not how much of a resource it costs, so it
>    is a modality (Davies and Pfenning's staged calculus) and lives in the
>    staging layer, not the kernel semiring. Multi stage, not two level, because
>    the process model is self similar: run a configuration and it is itself a
>    runtime that can stage a further runtime. spawn stages the next level,
>    specialize is cross stage partial evaluation, pregen is running the static
>    level ahead of time. The scaffold path is two level first (formalizing what
>    the lowering connector and the native backend already do implicitly) then
>    the multi stage generalization.

**What this means concretely:**

- Binding time is a **modality** — a type-level annotation, like `□A` (code
  for A) and `○A` (next-stage A). Not a grade in the QTT semiring.
- The compiler already has implicit stages: surface → core → tal → machine
  code. Fork C formalizes these as type-level stages.
- `spawn` already stages a residual into a live runtime. `specialize` already
  produces a residual. Fork C makes the type system aware of which stage a
  value belongs to.
- **Two-level first, then multi-stage.** The scaffold already has two levels
  (compile time / runtime). Fork C formalizes the two-level spine first, then
  generalizes to N stages (compile → init → runtime → dynamic).

## What Fork C unlocks

The bounded autospec policy (`optimize.autospec`) has hard guards:

```python
_AUTOSPEC_ROUNDS = 3       # max cascade depth
_AUTOSPEC_MAX_SIZE = 48    # max instructions in target
# No self-recursion        # specializing a loop unrolls forever
```

These guards exist because the compiler doesn't know what's "worth"
specializing. It can't decide. Fork C gives the compiler the information it
needs to make that decision:

1. **Which parameters are static?** The staging modality marks parameters as
   `□` (known at this stage) or `○` (known at the next stage). The compiler
   doesn't guess — the type says.

2. **What is the cost of specializing vs not?** The graded cost semiring
   (E38) gives a cost model. `specialize` has a cost (code size growth).
   Not specializing has a cost (runtime overhead). The compiler compares them
   using the grade.

3. **Is this function total?** Totality (Fork B) is the license to evaluate
   at generation time. A non-total function can't be specialized because
   running it early might diverge.

4. **How deep should specialization cascade?** With stages, the compiler
   knows that specializing a stage-0 function with stage-0 arguments produces
   a stage-1 residual. That residual can itself be specialized with its own
   stage-1 static arguments. The cascade is bounded by the stage count, not
   an arbitrary round limit.

**The unbounded pregen policy IS Fork C.** The current autospec guards
(48 instrs, no recursion, 3 rounds) are ad-hoc approximations of what the
staging modality would compute precisely.

---

## The payoff triangle — how the three forks compose

```
E38 (graded cost)  ──→  "Is specializing worth it?"
                          cost(specialize) vs cost(not specialize)
                          computed from the coeffect semiring

Fork B (totality)  ──→  "Is it safe to run early?"
                          total-by-default, partiality is marked
                          the license to precompute

Fork C (staging)   ──→  "When is this value available?"
                          □A = known now, ○A = known next stage
                          the mechanism that runs early
```

The three together make pregen **fully automatic and fully safe.** The
programmer writes a function parameterized by config. The compiler sees:
- config is `□Config` (static — Fork C)
- the function is total (Fork B)
- specializing costs 200 bytes, saves 50ns per call, called 1M times —
  net positive (E38)

The compiler specializes. No programmer annotation. No manual `specialize`
call. The type system carries the information; the cost model makes the
decision; the staging modality runs it.

---

## What's needed to close Fork C — the build order

### Step 1 — two-level staging spine (E57 slice 1)

The smallest useful slice. The compiler already has "compile time" and
"runtime" as implicit stages. Formalize them:

```chirality
; Stage modality in the type system
; □A = "available at compile time" (static)
; ○A = "available at runtime" (dynamic)

; A lowered function's type becomes explicit about stages:
; compile-main : □Source -> ○Bytes
; "Given source text known at compile time, produce bytes available at runtime"
```

**What changes in the compiler:**
- Surface syntax: `(static A)` and `(dynamic A)` as type annotations, or
  inferred from context
- Kernel: stages are part of the type universe. □ and ○ are type
  constructors. The judgment `Γ ⊢ e : A at stage s` already exists
  implicitly (the compiler operates at compile time, the output runs at
  runtime). Formalize it.
- Lowering: `□A` values are erased (they're already computed). `○A`
  values become runtime values.

**Estimated work:** ~200 lines in `kernel.py` + `surface.py` + `lower.py`.
This is the E57 worked example → spec → implement pipeline.

### Step 2 — graded cost semiring (E38)

The cost model. Currently `autospec` uses hard-coded thresholds. Replace
with a grade in the QTT semiring:

```chirality
; The enriched semiring: usage × time × space × info-flow
; Usage: 0, 1, ω (already present)
; Time: N ∪ {∞} — constant upper bounds
; Space: N ∪ {∞} — constant upper bounds
; Info-flow: ⊥, ⊤ (trivial lattice — reserved seat)
```

**What changes:**
- Kernel: the grade set grows from {0,1,ω} to a product semiring.
  The judgment is parametric over the grade set (already designed this way).
- Refinement: time/space bounds are refinements on I64. The entailment
  procedure already handles linear arithmetic.
- Specialize gets a cost model: `cost(specialize(f, bindings))` returns
  (time-saved-per-call, space-growth). If time-saved × call-count >
  space-growth × threshold, specialize.

**Estimated work:** ~300 lines. E38 is already specced in `examples/E38-graded-cost.md`.

### Step 3 — fact-carrying lowering (E9 × E16 slice)

Refinement facts survive from the kernel into TAL. This is the bridge
between "the type system proved it" and "the codegen can use it."

```chirality
; Today: kernel proves "x ≥ 0", lowering discards the proof
; After: the proof becomes a TAL annotation

; Before lowering:
;   (refine I64 (>= 0))  →  type carries the bound

; After lowering:
;   I64 with fact {>= 0}  →  TAL register carries the bound
;   The peephole can elide bounds checks because the fact is in the TAL type
```

**What changes:**
- `lower.py`: the refinement type maps to a TAL register annotated with
  the fact. A fact is `(op, constant)` — e.g., `(>=, 0)`, `(<, n)`,
  `(≠, 0)`, `(≠, -1)`.
- `tal.py`: the TAL type system gains a fact lattice. `check_fn` verifies
  that instructions preserve facts (e.g., `add` on two non-negative
  registers produces a non-negative register if no overflow).
- `mach-x64.chiral`: the Mach emitter uses facts to elide guards.
  `x-guarded` (division guard) is dead when the divisor fact is `(≠, 0)`
  and `(≠, -1)`. Bounds checks on `pool-write` are dead when the offset
  fact is `(>=, 0)` and `(<, n)`.

**The smallest slice:** carry ONE fact type through the pipeline. `(>=, 0)`
— non-negative integers. This is the most common fact in scriba (cursor
positions, terminal dimensions, counts, lengths). Prove it end-to-end:
kernel → lower → TAL → Mach.

**Estimated work:** ~250 lines. This is the "architectural prize" from
TRAIT-OPTS T4.

### Step 4 — unbounded auto-pregen policy (optimize.autospec v2)

Replace the hard-coded guards with the staging-based policy:

```python
# Current (bounded):
_AUTOSPEC_MAX_SIZE = 48    # arbitrary
# No self-recursion        # conservative

# After (unbounded, Fork C-driven):
# - Specialize if the target has □ parameters and □ arguments available
# - Specialize if cost(specialization) < cost(not_specializing) × call_frequency
# - Allow self-recursion if the recursive argument is ○ (decreases each call)
# - Cascade depth = stage depth (no arbitrary round limit)
```

**What changes:**
- `optimize.autospec` reads stage annotations from the TAL function
  signature (seeded by Fork C step 1).
- The cost model (E38 step 2) replaces `_AUTOSPEC_MAX_SIZE`.
- Self-recursion is allowed when the recursion argument is a `○` natural
  number (the compiler proves it decreases → terminates → safe to inline
  N times).

**Estimated work:** ~150 lines in `optimize.py`.

---

## The complete unbounded tier — dependency graph

```
E38 (graded cost) ──────────────────────┐
                                         ├──→ E57 (staging, step 1) ──→ autospec v2
Fork B (totality, already settled) ─────┘              │
                                                        │
E9 × E16 (fact-carrying lowering) ─────────────────────┘
   │
   └──→ T4 guard elision (division, bounds checks)
   └──→ T5 in-place bcat (linear + bump-top)
```

E38 and the staging spine are parallel — both need Fork B (already settled).
Fact-carrying lowering is parallel to both. autospec v2 depends on all three.

---

## What scriba gets from each step

| Step | What it unlocks for scriba | Impact |
|------|---------------------------|--------|
| E38 graded cost | Compiler can decide "this specialization is worth it." Without it, specialization is either manual or bounded by arbitrary thresholds. | Makes pregen automatic |
| E57 staging spine | Static vs dynamic is in the type. Keymap is `□Keymap`, init config is `□Config`. The compiler knows what to specialize without guessing. | Makes pregen type-safe |
| Fact-carrying lowering | Cursor bounds checks elide because `pos < len` is a refinement fact that survives into TAL. Division guards elide because `divisor ≠ 0, ≠ -1` survives. Every refinement type in scriba becomes a compile-time fact. | Every keystroke, every render frame |
| autospec v2 | The command loop, renderer registry, ANSI escapes, and init config all auto-specialize without manual `specialize` calls. The compiler just does it. | Zero programmer effort |

---

## What's NOT in this plan (deferred)

- **Multi-stage generalization.** Two-level first (compile/runtime). N-stage
  (compile → init → runtime → dynamic) is the generalization. Not needed for
  unbounded pregen — two-level is sufficient for scriba's use case.
- **Information flow enforcement.** The fourth seat in the semiring is
  reserved but not enforced (stage 7–8).
- **Reflective floor (E45).** Staged metaprogramming over typed terms.
  Separate from pregen — pregen operates on TAL, not on surface terms.
- **Sized types (E47).** Promotion path for the time grade. Not needed for
  pregen's first unbounded policy.
