---
element: E57
slug: staging-modality
title: Staging / binding-time modality (Fork C): link/load vs runtime carried in the type
kind: BUILD-PROPER
example: examples/E57-staging-modality.md
status: draft
updated: 2026-08-07
---

# E57 SPEC — Staging / binding-time modality (Fork C): link/load vs runtime carried in the type

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** Two kernel-internal type constructors `Static(Type)` and
  `Next(Type)` exist in `kernel.py`, representing the binding-time modality
  `□A` (known at this stage) and `○A` (known at the next stage). Surface syntax
  `(static A)` and `(dynamic A)` parse in `surface.py`. The lowerer treats
  `Static` parameters as erased (already computed at an earlier stage) and
  `Next` parameters as normal TAL values. The autospec optimizer (`optimize.py`)
  reads stage annotations on lowered function signatures to decide static-vs-dynamic
  without the `const`-instruction heuristic. Existing tests (673 functions)
  continue passing — the new constructors are inert when unused.
- **Non-goals:**
  - Multi-stage generalization (N stages: compile → init → runtime → dynamic)
  - Stage inference (the compiler propagates `□` through the call graph) — this
    element only provides the *declarative* mechanism; inference is a follow-on
  - Staged effects (`□(=> A)`) — code performing effects at a later stage
  - Cross-stage persistence (values surviving from one stage to the next)
  - The reflective floor (E45 — staged metaprogramming over typed terms)
  - Interaction with E38 graded cost — staging is a modality, not a grade;
    cost of specialization is E38's concern

## 2. Baseline (what already exists)

- **Conformance-map verdict:** `BUILD` — the staging connector exists only as
  an ad-hoc link-at-load slice (`spawn` + extern check, `runtime.py`). No
  type-level representation. E57 is the design authority; this spec is the
  first build step.
- **Live code:**
  - `scaffold/chirality/kernel.py` — `Type` constructors: `Pi`, `Lam`, `App`, `Var`,
    `Let`, `Ann`, `Lit`, `PrimTy`, `Global`, `Prim`. Extension points:
    `Sig.ext_check`, `Sig.ext_eval`, `Sig.check_hooks`, `Sig.subtype_hooks`.
    The type universe is extensible through hooks — `Static`/`Next` can be
    value forms dispatched through the existing seam.
  - `scaffold/chirality/surface.py` — `Elab.arrow()` (line 636) builds `Pi` types
    from `(-> ...)` syntax. `Elab.apply()` (line 615) resolves type applications.
    The surface parser already handles arbitrarily-nested S-expressions — new
    type constructors like `(static A)` are parseable once `static`/`dynamic`
    are recognized.
  - `scaffold/chirality/lower.py` — `ttype()` (line 37) maps upper `Value` to
    `TalType`. Currently handles `VPrimTy`, `VTCon`, `VNe`. `lower_all()`
    (line 440) walks lowered defs. The lowering connector already knows how to
    erase `Pi` parameters — a `Static` parameter extends this pattern: its
    runtime representation is zero slots.
  - `scaffold/chirality/optimize.py` — `specialize()` (line 506) binds static
    arguments and folds them through. `autospec()` (line 652) applies the
    bounded pregen policy using `const` instructions as a static-value
    heuristic. `_AUTOSPEC_ROUNDS = 3`, `_AUTOSPEC_MAX_SIZE = 48`. The
    infrastructure for binding + folding exists; E57 makes the heuristic
    type-driven.
- **True delta:** Adding `Static`/`Next` as *new* kernel value forms (not
  reimplementing anything), surface parsing for `(static A)`/`(dynamic A)`,
  lowering rules for the new forms, and autospec reading the stage annotations
  on TAL function parameters instead of guessing from `const` instructions.
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | `Static`/`Next` as kernel term forms or value forms? | RESOLVED — value forms | Per example §6: "□ and ○ as type constructors in Type." They are type-level annotations (value forms `VStatic`/`VNext`), not computation terms. The kernel already dispatches unknown value forms through `check_hooks`, `conv_hooks`, etc. This avoids changing any core judgment rules. |
| 2 | Surface syntax: `(static A)` or `□A`? | RESOLVED — `(static A)` / `(dynamic A)` | Example §5 (audited): S-expression surface syntax `(static A)`/`(dynamic A)` elaborate to kernel-internal `Static`/`Next`. Unicode `□`/`○` are design notation only. |
| 3 | Inference: do entry points annotate the boundary, or does the compiler propagate? | DEFERRED — inference follow-on | This element provides the *declarative* mechanism (programmer writes `(static A)`). Propagation through pure/total code is a separate build step. Per example §6 open question, answered: "entry points annotate the boundary; the compiler propagates □ forward" — but this element only builds the annotation half. |
| 4 | Does `□` interact with QTT quantities? | RESOLVED — compose, don't merge | Example §4: "□(0 A) = erased AND staged." Static/Next and QTT quantities are orthogonal. `Static` wraps the inner type; the quantity on a `Pi` binder using `Static(T)` is separate. A `0`-quantity `Static` parameter is fully erased at runtime. Per decision-graded-kernel.md: staging is a modality, not a grade. |
| 5 | Does `□` interact with the effect row? | DEFERRED — staged effects follow-on | Example §4 claims "The effect membrane crosses stages" but staged effects (`□(=> A)`) are in the "deliberately omitted" list. This element allows `Static` around any type (including effectful types) but does not enforce the membrane — that's a follow-on build. Per decision-effect-facets: alarms are crossings, not modality-mates. |
| 6 | Lowering: what is the TAL representation of `Static`? | RESOLVED — zero slots | `Static(T)` parameters contribute ZERO to the TAL parameter list. They were already computed at compile/link time. The lowerer skips them. `Next(T)` parameters lower normally via `ttype`. Per example §6: "□A values are already erased." |
| 7 | Should `Static`/`Next` be added as *core* value forms or through the extension seam? | RESOLVED — extension seam | The kernel's design already separates core (Pi/Lam/Var) from extension (TCon/Con via `ext_check`/`ext_eval`). `Static`/`Next` go through the seam — adding a `stage_hook` or reusing `check_hooks`. This keeps the trusted core unchanged. Per kernel.py docstring lines 29-30: "value-form hooks...for value forms the kernel does not understand." |

## 4. Change plan (ordered, commit-sized)

### Step 1 — Kernel: `Static`/`Next` value forms
- **Target:** `scaffold/chirality/kernel.py` — add to `Sig.__init__`, add value-form handling
- **Change:** Add two new value-form constants: `('VStatic', inner_ty)` and
  `('VNext', inner_ty)`. Register a `stage_hooks` list on `Sig` (same pattern
  as `check_hooks`). Add `conv` and `subtype` rules: two `Static` values are
  conv-equal iff their inner types are conv-equal (same for `Next`). Subtype:
  `Static(A) <: Static(B)` iff `A <: B` (same for `Next`). `Static` /= `Next`
  (different stages). Type-of: `VStatic(ty)` → `Type(level_of(ty))`,
  `VNext(ty)` → `Type(level_of(ty))`.
- **Size:** ~M (60–80 lines)
- 2026-09-04: cut Python oracle, no live successor.

### Step 2 — Surface: parse `(static A)` and `(dynamic A)`
- **Target:** `scaffold/chirality/surface.py` — extend `Elab.apply()` or add a new
  method for stage-form types
- **Change:** When `apply()` encounters a `Sym('static')` or `Sym('dynamic')`
  at the head of an application, elaborate the single argument and return
  `('VStatic', arg_ty)` or `('VNext', arg_ty)`. These keywords don't collide
  with any existing names. The elaborated type is a value, not a term — it
  flows into type annotations (the codomain position of `(declare ...)` or
  the domain position of `(-> ...)`).
- **Size:** ~S (20–30 lines)
- 2026-09-04: cut Python oracle, no live successor.

### Step 3 — Lowering: erase `Static` parameters, lower `Next` normally
- **Target:** `scaffold/chirality/lower.py` — `ttype()`, `lower_all()`, `sysface()`
- **Change:**
  - `ttype()`: add cases for `VStatic` and `VNext`. `VStatic(T)` returns
    `ttype(T)` (the inner type's TAL representation — the static value is
    available at compile time but its *representation* at runtime is the
    inner type). `VNext(T)` also returns `ttype(T)` (lowers normally).
    Actually more precisely: `Static` *parameters* are erased from the TAL param
    list (step 3b), but `Static` *values* in types need a TAL representation
    for the preserve-check. The simplest correct approach: `VStatic(T)` is
    transparent at lowering — `ttype` peels it and recurs on `T`.
  - `lower_all()` or `Low.fn()`: when computing `param_tys` for a `Pi` whose
    domain is `VStatic`, skip the parameter — emit no TAL param slot.
    The lowering body for that parameter is a no-op (the value was already
    computed).
  - This is the most delicate step. The current lowering maps each Pi domain
    to a TAL param. With `Static`, the Pi carries the stage annotation on its
    domain type, and the lowerer must inspect it.
- **Size:** ~M (40–60 lines)
- 2026-09-04: cut Python oracle, no live successor.

### Step 4 — Optimizer: autospec reads stage annotations
- **Target:** `scaffold/chirality/optimize.py` — `autospec()`, `specialize()`,
  TAL function signature storage
- **Change:**
  - Store stage annotations in `env_tal.fn_sigs`. Today `fn_sigs[name]` is
    `(param_tys, ret_ty)`. Extend to `(param_tys, ret_ty, stage_mask)` where
    `stage_mask` is a tuple of bools (True = Static/compile-time, False =
    Next/runtime) — one per parameter.
  - In `autospec._autospec_block`: instead of (or in addition to) checking
    `cenv` for `const` values from `I64` parameters, read `stage_mask` from
    `fn_sigs[target]`. A Static parameter at position `i` is always a
    candidate for binding (specialization), regardless of whether a `const`
    instruction produced it.
  - The bounded guards (`_AUTOSPEC_MAX_SIZE`, `_reaches_self`) remain —
    stage annotations improve *which* parameters to bind, not *whether* to
    bind. The unbounded policy is a follow-on (FORK-C-UNROLLED step 4).
  - `specialize()` remains unchanged: it already handles int bindings and
    nullary-constructor bindings. The caller (autospec) just has better
    information about which bindings to propose.
- **Size:** ~S (30–40 lines)
- 2026-09-04: cut Python oracle, no live successor.

### Step 5 — Tests
- **Target:** `scaffold/tests/test_staging.py` (new) + updates to
  `test_optimize.py`
- **Change:**
  - Test that `(static I64)` parses in surface and elaborates to `VStatic`
  - Test that `(static I64)` and `(dynamic I64)` are not conv-equal
  - Test that `(static I64)` and `(static I64)` are conv-equal (same inner type)
  - Test that a function declared with `(static I64)` parameter lowers with
    one fewer TAL param
  - Test that autospec binds a Static parameter to a specialization even when
    no `const` instruction appears
  - Run full test suite: 673 → ≥ 680 green
- **Size:** ~M (80–100 lines)
- 2026-09-04: cut Python oracle, no live successor.

## 5. Conformance gate

- **Golden behavior:**
  1. A function with a `(static I64)` parameter, called with a literal,
     produces a residual that is preserve-checked (byte-identical to the
     original function called with the same literal at runtime). This is the
     existing `specialize` contract extended to stage-driven binding.
  2. `(static I64)` and `(dynamic I64)` are distinct types — a function
     expecting one rejects the other.
  3. The existing `specialize` test suite (`test_optimize.py`) passes
     unchanged — stage annotations are additive, not disruptive.
  4. The new constructors are invisible in normal code (no `(static ...)`
     annotation) — all existing tests continue to pass.
- **Tests to add:**
  - `test_staging.py::test_parse_static` — surface `(static I64)` → kernel `VStatic`
  - `test_staging.py::test_parse_dynamic` — surface `(dynamic I64)` → kernel `VNext`
  - `test_staging.py::test_static_next_not_conv` — `VStatic(I64) != VNext(I64)`
  - `test_staging.py::test_static_transparent_conv` — `VStatic(I64) == VStatic(I64)`
  - `test_staging.py::test_lower_static_erased` — Static param not in TAL param list
  - `test_staging.py::test_autospec_static_binding` — autospec binds Static param
  - `test_optimize.py` — add stage-annotated function to existing specialize fixtures
- **Green line:** 673 → ≥ 680; ledger-lint clean (no regressions).
- **Done when:** `python3 -m pytest scaffold/tests/ -q` passes with ≥ 680 green,
  all new tests pass, and an autospec run on a lowered function with
  `(static I64)` parameters produces a specialized residual with the
  static argument folded.
- 2026-09-04: cut Python oracle, no live successor.

## 6. Residue & links

- **Deliberately unbuilt:**
  - Stage inference (propagation of `□` through pure/total code) — follow-on build
  - Multi-stage generalization (compile → init → runtime → dynamic) —
    FORK-C-UNROLLED step 1b (after two-level)
  - Staged effects (`□(=> A)`) — "deliberately omitted" per example §5
  - Cross-stage persistence — FORK-C-UNROLLED multi-stage follow-on
  - The reflective floor (E45) — separate element
  - Unbounded autospec policy (guard removal) — FORK-C-UNROLLED step 4,
    depends on E57 + E38 + fact-carrying lowering
- **Follow-on:** E38 (graded cost) — the cost model that tells autospec *whether*
  to specialize. E57 tells autospec *which* parameters are static. Together
  they enable the unbounded pregen policy.
- **Related:** [[E57-staging-modality]] · [[E38-graded-cost]] · [[E17-optimizer]]
  · [[decision-graded-kernel]] (Fork C, settled) · [[modules-staging]]
  · [[E16-lowering]] · `.planning/FORK-C-UNROLLED.md`
