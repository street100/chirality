---
node: tal-spec
layer: foundation
refines: [floor-agreement]
related: [floor-agreement, joining-law, modules-lowering, open-edges]
status: draft
updated: 2026-08-02
---

# The tal specification (spec-as-golden)

> **Provisional direction (2026-08-02, E71).** This document is the golden
> object for [[floor-agreement]] under the provisionally-adopted **spec-as-golden**
> branch ("go for a solution, may change" — the call is the author's, ratification
> owed). It is written as the definition; if the branch is later reversed it
> becomes a derived artifact instead. Nothing here is ratified; everything is
> revisitable.

**This prose is the trust root.** tal has more than one executor — the Python
reference `TalMachine`, the native backend, the constant-folder, and eventually a
chirality reference executor. Under spec-as-golden none of them *is* the semantics:
**this document is**, and each executor is first-among-producers, admitted only
once it agrees with the entries below. `lib/tal-spec.chiral` is the checkable
*data form* of this document — the first derived checker, not the definition. A
weekend re-implementer reads *this file* to learn the floor, not a codebase.

Why the anchor is a spec and not an executor: a reference implementation makes
its own accidents into law (an observed bug becomes semantics), dies with its
runtime, and is a moving target that certificate discipline forbids at the socket.
chirality already made this call once, in miniature — division was never defined by
"what the reference computes"; it was **pinned to SMT-LIB's Euclidean `div`/`mod`**
so a solver-discharged refinement means at runtime exactly what it proved (the
Euclidean-division pin, `docs/decision-graded-kernel` lineage). This document is
that move generalized: the
spec is the demanded statement, every executor a conformance candidate.

## Observables

The spec speaks **only in observables** — what floor agreement compares. Register
allocation, instruction encoding, and arena layout are executor-private and
deliberately unspecified. An observable (`Obs` in the data form) is one of:

- **`obs-val v`** — the instruction's result value (an `I64` in the first cut).
- **`obs-halt`** — a fatal alarm (a deliberate trap; the program stops).
- **`obs-sys n args`** — a crossing: the syscall number and its arguments. A real
  syscall is *not* a pure transition, so the spec pins the register/observable
  contract (what crosses), never the kernel's internal effect (E71 §3 #5).

Each spec entry is an instruction's semantics as a **total, pure** function from
the abstract machine state to its observable, plus **pinned vectors**
(input/observable pairs). Purity is the point: the floor's semantics is itself a
category-A object — checkable, weekend-readable. The determinism debts (iteration
order, encoding) are pinned *in the vectors, on purpose* — an executor pins them
by accident, the spec pins them deliberately.

The abstract machine state (`MState`) is **minimal and exemplar-driven** (E71 §3
#4): today it carries the two operands the exemplars observe. It grows by the
standing admission rule — **a new tal instruction is a new spec entry first**
(§3 #3): its entry and vectors are written *before* any executor implements it,
so no executor's behavior can back-fill the definition.

## Exemplar entry: `div` (Euclidean, SMT-LIB-aligned)

The canonical [[floor-agreement]] failure, already pinned. `div` on operands
`(a, b)` observes:

- `b = 0` → **`obs-halt`**: division by zero is a deliberate fatal alarm. The
  semantic function guards this case, so it is total and never traps; the trap is
  the *observable*, pinned as a vector like any other.
- `b ≠ 0` → **`obs-val q`** where `q` is the **Euclidean** quotient: the unique
  `q` with `a = b·q + r` and `0 ≤ r < |b|`. This is SMT-LIB's `div`, not
  truncation-toward-zero. It is what a solver-discharged refinement on `/` means.

Pinned vectors (the full sign grid; each is the exact observable the reference
floor independently produces — verified in `tests/test_tal_spec.py`):

| a | b | `div` observable | note |
|---|---|---|---|
| 7 | 2 | `obs-val 3` | |
| −7 | 2 | `obs-val −4` | Euclidean (remainder +1), not truncation (−3) |
| 7 | −2 | `obs-val −3` | |
| −7 | −2 | `obs-val 4` | |
| 0 | 5 | `obs-val 0` | |
| INT_MIN | −1 | `obs-val INT_MIN` | two's-complement **wrap**; all floors agree |
| 7 | 0 | `obs-halt` | the deliberate trap |

The remainder is `+1` in every mixed-sign case above — that is the Euclidean
signature (a non-negative remainder), the property the pin exists to enforce.

## Exemplar entry: `byte-zero-read`

An unwritten byte of a freshly allocated cell **reads `0`** on every executor.
Yesterday this was a floor *contract* stated in prose; under the spec it is a
pinned vector like any other. For any read index into a fresh (zeroed) cell the
observable is **`obs-val 0`**.

## What this makes impossible

Semantics-by-accident. An executor behavior that is **not derivable from a spec
vector or semantic function is a bug — even if every executor agrees on it.**
Correlated agreement (two floors sharing a toolchain's provenance) can no longer
ratify an accident into law, which is precisely the failure mode of a
reference-implementation-as-spec. The reference stays first-among-producers: where
it *diverges* from the spec the divergence is **investigated**, not auto-ruled
against either side — a spec can be wrong or incomplete where a running reference
cannot be silent, so seeding it from the live differential corpus and keeping the
reference in the loop mitigates (does not erase) that risk.

## Reach

Coverage is two exemplars today; it grows by the new-entry-first rule, not a
backlog. The obligations this anchor must eventually pin: the rest of the
arithmetic prims, the byte/string intrinsics, the `case`/`call` control transfer,
and the sys-face register contract (whose interaction with the effect-row tal
shadow is [[E70]]'s to design). Each lands as prose here first, then a vector row,
then the data-form entry, then an executor.
