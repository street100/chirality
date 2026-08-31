# Fact-carrying lowering — E9 × E16 slice

**2026-08-06**
**Pipeline:** spec (cross-cut element, not a standalone E#)
**Status:** drafted — first slice: carry `(>= 0)` through the lowering boundary

---

## 1. Deliverable

A single refinement fact — `x ≥ 0` — survives from the kernel's type judgment
through lowering into TAL. The TAL type system gains a fact lattice. The Mach
emitter uses facts to elide one runtime guard: the division-by-zero / -1 check
(`x-guarded`). This is the smallest end-to-end slice that proves the mechanism.

## 2. Baseline delta

### What exists today

- **Kernel:** `refine.py` proves facts about I64 values. `entails(ctx, pred)`
  decides whether `x ≥ 0`, `x < n`, `x ≠ 0`, etc. These facts are DISCHARGED
  at typechecking — the kernel proves them, then discards them.
- **Lowering:** `lower.py` flattens refinement types to plain `I64`. A
  `(refine I64 (>= 0))` becomes `I64` in TAL. The fact is lost.
- **TAL:** `tal.py` has no fact lattice. Types are `I64`, `Bytes`, `(Data
  dname ())`. No registers carry range annotations.
- **Mach:** `mach-x64.chiral` emits `x-guarded` (division guard: test divisor
  against 0 and -1, `cmp −1` / `je ud2` / `cmp 0` / `je ud2`). Paid every
  division, even when the kernel proved the divisor is safe.

### What changes

- **Kernel → Lowering interface:** the refinement type carries its facts as
  metadata alongside the base type. `(refine I64 (>= 0) (≠ 0))` lowers to
  `I64` with facts `{≥0, ≠0}`.
- **TAL type system:** `tal.py` gains a fact lattice. A register type is
  `(I64, facts)` where facts is a set of `(op, constant)` pairs. The checker
  propagates facts through instructions (e.g., `const 5` → facts `{≥0, ≠0,
  <100, ...}` — any fact that 5 satisfies).
- **Mach emitter:** `x-guarded` checks the divisor's facts. If `{≠0, ≠-1}` is
  present, the guard is dead code. If only `{≠0}` is present, only the zero
  check is dead. If no facts, the full guard stays.

## 3. Dispositioned decisions

### Decision 1: fact representation

**RESOLVED — set of (op, constant) pairs.** Each fact is `(op, I64)` where
`op ∈ {>=, >, <=, <, <>, =}` — the five operators refinement already uses.
Multiple facts compose by intersection (the register satisfies all of them).
The lattice bottom is the empty set (no facts). The lattice top is... no top
(facts are bounded — we don't need a "contradiction" element because the
kernel would reject a term that requires it).

**Rejected alternatives:**
- Interval representation `[lo, hi]` — more compact but can't represent `≠ 0`
  precisely (the interval `[-∞, -1] ∪ [1, ∞]` is not an interval).
- Bitmask predicates — overkill for the first slice. Only needed when facts
  include bit-level properties (alignment, power-of-two).

### Decision 2: fact propagation rules

**RESOLVED — instruction-specific propagation.** Each TAL instruction has a
rule for which facts survive:

| Instruction | Propagation rule |
|-------------|-----------------|
| `const dst I64 n` | `dst` gets all facts that `n` satisfies (e.g., `const 5` → `{≥0, ≠0, <100}` from a fact table lookup) |
| `prim dst op src1 src2` | Arithmetic: `add` on two `≥0` operands → `≥0` (no overflow by fiat — wrapping-add of two non-negative values is non-negative). `sub`: no propagation (result sign unknown). `mul`: `≥0 × ≥0` → `≥0`. `div`: quotient facts depend on both operands; elide for first slice. |
| `cmp dst op src1 src2` | The comparison result is `Bool`, not `I64` — facts don't apply. |
| `call dst f args` | The callee's return type carries facts. If the callee returns `I64` with facts `{≥0}`, the caller's `dst` gets `{≥0}`. |
| `param` | The parameter's type carries the caller-proven facts. |

### Decision 3: fact soundness at Mach boundaries

**RESOLVED — preserve-check is the gate.** The TAL checker verifies that
facts are consistent with the instruction sequence. The Mach emitter trusts
the facts (they were checked at the TAL level). If the emitter elides a
guard based on a fact, and the fact is wrong, the TAL checker would have
caught it. This is the same preserve-check discipline as every other
tal→tal transform.

### Decision 4: lowering boundary — where facts enter TAL

**RESOLVED — at the `lower_fn` call.** When `lower.py` encounters a
`(refine I64 preds...)`, it maps to `(I64, facts-from-preds(preds))` where
`facts-from-preds` extracts `(op, n)` from each predicate. The lowerer
doesn't re-prove the facts — the kernel already did. It just translates
the kernel's proof into TAL's fact representation.

### Decision 5: first slice scope — `(>= 0)` only

**DEFERRED — full fact lattice.** The first implementation slice carries
exactly one fact: `(>=, 0)`. This is the most common refinement in the
codebase (cursor positions, counts, lengths, terminal dimensions). It's
also the simplest to propagate. After the slice works end-to-end, extend
to `(<>, 0)`, `(<, n)`, and the full set.

## 4. Change plan (commit-sized steps)

### Step 1 — TAL fact type (tal.py)

Add `Facts` type: `set of (op, I64)` where `op in ("gte",)` for first slice.
Add to register types: `(type, facts)`. Default facts is empty set.
No change to `check_fn` yet — accept facts, ignore them.

### Step 2 — Fact propagation in TAL checker (tal.py)

Add propagation rules for `const`, `prim` (add, mul), `call`, `param`.
The checker asserts that facts are consistent (a register with `{≥0}` can't
be the result of a `sub` with unknown operands — but for the first slice,
just propagate, don't verify backward).

### Step 3 — Fact source in lowering (lower.py)

At `lower_fn`, when the source term has refinement type `(>= 0)`, annotate
the TAL parameter with facts `{≥0}`. At `const` emission, annotate with
facts the constant satisfies.

### Step 4 — Fact consumer in Mach (mach-x64.chiral)

In `x-guarded`, check divisor facts. If `{≥0, ≠0}` is present (a non-zero
non-negative divisor — can't be 0 or -1), elide the entire guard. If only
`{≠0}` is present, elide the zero check. Otherwise emit the full guard.

### Step 5 — Preserve-check the end-to-end (test)

Differential test: compile a function with `(refine I64 (>= 0))` division.
Compare the emitted machine code: the guard should be absent when the divisor
is proven non-zero, present otherwise. Verify byte-identity with and without
the refinement annotation (the annotated version should be smaller/faster).

### Step 6 — Extend to `(≠ 0)` and `(< n)` (second slice)

After the first slice works, add `("neq", n)` and `("lt", n)` to the fact
lattice. Propagation: `const n` where `n ≠ 0` → `{≠0}`. `prim add` on
`{≥0, <n}` and `{≥0, <m}` where `n + m ≤ 2^63-1` → `{≥0, <n+m}`.

## 5. Conformance gate

- `test_optimize.py`: existing `test_specialize_division_fold` passes (division
  guard elision verified by disassembly diff)
- `test_refine.py`: no regression — refinement facts are still proved by the
  kernel
- `test_tal.py`: TAL checker accepts fact-annotated registers
- New test: `test_fact_lowering.py` — end-to-end: kernel proves `x ≥ 0`,
  lowering carries the fact, TAL checker verifies it, Mach elides the guard

## 6. Honest residue

- **Fact weakening at module boundaries.** When a function is called from
  outside the current compilation unit, the caller's facts may be weaker
  than the callee expects. The linker must re-check facts at module
  boundaries. Not in scope for the first slice — all tests are single-module.
- **Overflow and fact soundness.** `add` on two `{<n}` values may overflow
  if `n + m > 2^63-1`. The first slice assumes no overflow (the proven
  bounds are small enough). Full soundness needs the refinement engine to
  verify `n + m` at compile time — this is E9's job, not lowering's.
- **Facts on Bytes.** Byte arrays carry length facts (the `n` in `(Pool n)`).
  Lowering bytes with length facts to TAL is the next step after I64 facts.
  Needed for bounds-check elision on `pool-write`.
- **Interaction with E57 (staging).** `□` facts are available at compile
  time; `○` facts are available at runtime. The fact lattice crosses the
  stage boundary — a `□` fact can be used at compile time to elide a guard
  in `□` code. Deferred until E57 lands.

---

**Related:** [[E9-refinement-decision]] · [[E16-lowering]] · [[E38-graded-cost]]
· [[E57-staging-modality]] · `scaffold/bench/TRAIT-OPTS.md` §T4
· `.planning/FORK-C-UNROLLED.md` · `scaffold/chirality/tal.py` · `scaffold/chirality/lower.py`
