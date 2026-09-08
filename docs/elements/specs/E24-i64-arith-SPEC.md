---
element: E24
slug: i64-arith
title: I64 two's-complement arithmetic (bignum reference is a crutch)
kind: REPLACE-CRUTCH
example: examples/E24-i64-arith.md
status: audited
updated: 2026-08-01
---

# E24 SPEC — I64 arithmetic: the refined safe path over the pinned semantics

> ⚑ **TRIAGE 2026-09-04 — NEEDS-REPLAN.** 1 of 2 steps are executable at HEAD.
> Step 1 is executable at `lib/prelude/prelude.chiral`; Step 2's gate must be
> rehomed on `tools/test/`. Bucket and evidence:
> `records/spec-tier-triage.md`. This file was not rewritten and its `status:`
> was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the *safe path* for division exists in chirality source —
  `div` / `mod` / `divmod` with the divisor refined `(refine I64 (<> 0))`
  (compile-time discharge, zero-case unreachable inside) and `try-div` (the
  marked `Maybe` climb) land in `lib/prelude.chiral`'s pure-defs section, and the
  checker **rejects** a refined-div call whose divisor is a literal `0`.
- **Non-goals:** the **floor agreement itself** — already BUILT: the fold
  imports `impl_pure`'s law as its single source (the docstring's purpose), and
  the D3 fix gave the native floor guarded `idiv` (Euclidean fixup;
  `INT_MIN/-1` wraps; `÷0` = deliberate `ud2`) agreeing across all three floors
  — nothing here re-opens it. **`wrap64` in chirality** — nothing to write: on the
  native floor the drop is the register width; the Python fold is the
  reference's narrowing, staying put. **The prelude-face swap** and **the law's
  home migration** — dispositioned below (#1, #2). U64/I32 word variants,
  saturating/checked ops — the example's knobs, nobody's yet.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no row — E24 postdates the map snapshot; treated
  as BUILD for the *wrapper* surface only. The semantics layer beneath is
  settled and built:
  - **The pinned law** (`impl_pure.py:11–17`): I64 = two's-complement 64-bit;
    `+ - *` wrap (matching the native drop); `/`/`%` **Euclidean** (SMT-LIB
    `div`/`mod`) so a solver-discharged refinement means at runtime exactly
    what it proved. **Settled 2026-07-06 — do not re-argue** (the
    division-Euclidean decision).
  - **Single-source collapse:** the optimizer's constant folder imports these
    functions (`impl_pure.py:12–14` docstring — "a fold and the runtime can
    never disagree"); the native floor is differentially validated (D3:
    guarded `idiv`, all three floors agree incl. `INT_MIN/-1` and the `÷0`
    trap).
  - **The raw face:** `prelude.chiral:23–30` — `+ - * / %` at plain
    `(-> I64 I64 I64)`; zero divisor = `PortError` at the reference
    (`impl_pure.py:63/71`).
  - **The refinement machinery:** E9 (audited) — the I64 constant-bound
    fragment is sound + complete and `<>` is in `refine.py`'s `_OPS`; the
    `mem-put-checked` precedent (`mem-linear.chiral:26–29`) shows the
    refined-parameter + forget-at-raw-call idiom the wrappers copy.
- **True delta:** four small pure defs in `prelude.chiral` + their tests. No
  Python change, no kernel change, no new externs.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **Does the prelude extern face itself become refined** (raw division the marked climb), or do the refined wrappers live beside the raw face? (added at the example audit) | **RESOLVED (now) → wrappers beside the raw face; the face-swap FLAGGED as a non-blocking author call.** | Swapping `(extern / …)` to a refined domain breaks every raw call site with an unproven divisor — a caller-ripple change to *what programs typecheck* (the E29 lesson made ripple a first-class cost), and "should raw division require proof" is object-language surface semantics — the same tier as E6's default-branch FLAG. P4 (safe = cheap default) *leans* toward the swap eventually; surfaced, not forced. The wrappers deliver the safe path today with zero ripple. |
| 2 | **Does the reference implementation of the law move to chirality source** (the example's §6 lands-in ambition)? | **DEFERRED → E71/E72.** | *What is golden* is exactly E71's provisionally-resolved question (spec-as-golden; the reference demoted to first-among-executors) — moving the law's home before E71 confirms would pre-empt it. The RT floor's `/` extern *is* `impl_pure` (a chirality-source `div` law would be circular there); the law's migration rides the golden-restructure + re-bootstrap manifest (E72). The *wrappers* are surface and land now. |
| 3 | **Which divisor proofs discharge today?** | **RESOLVED → literal/constant divisors now; guarded-variable discharge is a testable-later slice.** | E9's built fragment is constant-bound sound+complete, so `(div a 7)` discharges and `(div a 0)` rejects — the gate's core. Whether the `(=i b 0)` false arm teaches `b <> 0` to the narrow layer (letting `try-div` call *refined* `div`) depends on E10's guard-fact wiring; the example's `try-div` deliberately calls raw `/` so nothing here depends on it. If it discharges, a bonus test records it; if not, no obligation. |
| 4 | **Where the wrappers land** — prelude defs vs a new lib. | **RESOLVED → `prelude.chiral` pure-defs section.** | `div`/`mod` are as basic as the `max`/`min`/`if` defs already there (`prelude.chiral:60–79`); a separate lib for four one-line defs is ceremony. The A floor is the principled home for the arithmetic safe path. |

No blocking NEEDS-AUTHOR; #1 carries a non-blocking FLAG (the face-swap).

## 4. Change plan (ordered, commit-sized)

### Step 1 — the wrappers
- **Target:** `lib/prelude/prelude.chiral` — the pure-defs section (after
  `min`).
- **Change:** per the audited example §5: `div`/`mod`/`divmod` with the second
  parameter `(refine I64 (<> 0))` (body forgets to base I64 at the raw call —
  the `mem-put-checked` idiom), and `try-div : (-> I64 I64 (Maybe I64))`
  (`case`-on-`(=i b 0)`, `none`/`some`). All `->` pure.
- **Size:** ~S.

### Step 2 — the gate tests
- **Target:** `tests/test_refine.py` (discharge/reject) + `tests/test_kernel.py`
  or `test_native.py` (behavior).
- **Change:** (a) `(div a 7)`-style literal-divisor call **accepted**; (b)
  `(div a 0)` **rejected** by the checker (the refinement refuses); (c)
  `try-div` returns `none` at 0 and `some (/ a b)` otherwise on the RT floor;
  (d) extend the existing floor-agreement corpus with the canonical pins as
  wrapper calls: `(div (- 0 7) 2) = -4`, `(mod (- 0 7) 2) = 1`,
  `(+ MAX 1) = MIN`.
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** the wrappers change no arithmetic — they are the typed
  safe path over the settled Euclidean/wrapping law; the three floors' existing
  agreement stays untouched and green.
- **Tests:** Step 2's four cases; the canonical `-4`/`1` pins as wrapper calls;
  existing `test_native.py`/`test_refine.py` suites stay green.
- **Green line:** 360 → ≥ 362; ledger-lint clean.
- **Done when:** literal-zero division is a *checker* error, `try-div` is the
  runtime-marked form, and the canonical Euclidean pins pass through the
  wrappers on the RT floor (native unchanged).

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **The prelude-face swap** (raw `/` refined, unproven division becomes the
    marked climb) → **author call, non-blocking FLAG** (decision #1).
  - **The law's home migration** (chirality-source reference) → **E71/E72**
    (decision #2).
  - **Guarded-variable discharge** (`=i` false arm → `<> 0` narrow fact) →
    rides E10's guard wiring; bonus-test only (decision #3).
  - **Alarm-typed division** (the `Maybe` climb as a counter-effect) → **E26**
    (the example's knob).
  - **U64/I32 word variants; saturating/checked ops** → nobody's yet.
- **Follow-on:** none blocking — this is a leaf. Strengthens the E9 story with
  a user-visible refined API precedent beyond `mem-put-checked`.
- **Related:** [[E24-i64-arith]], [[E09-refinement]] (the discharge machinery),
  [[E17-optimizer]] / [[E19]] (the collapsed/validated floors),
  [[E71-golden-restructure]] (what is golden), [[E26-alarm-control-flow]],
  [[floor-agreement]] (the collapse/validate gradient + the canonical division
  bug), [[E11-totality-checker]] (partiality as the marked climb).
