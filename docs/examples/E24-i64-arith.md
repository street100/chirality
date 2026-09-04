---
element: E24
slug: i64-arith
title: I64 two's-complement arithmetic (wrap64 / i64_div / i64_mod)
kind: REPLACE-CRUTCH
reference_class: SPEC
ours_source: scaffold/chirality/impl_pure.py
status: drafted
updated: 2026-07-12
---

# E24 — I64 two's-complement arithmetic (wrap64 / i64_div / i64_mod)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E24, the pinned semantics of `I64` `+ - * / %` — 64-bit
  two's-complement wrapping for `+ - *`, and *Euclidean* `/`/`%` (remainder in
  `[0, |b|)`), which the reference realizes as `wrap64` / `i64_div` / `i64_mod`.
- **Kind:** REPLACE-CRUTCH. The host reference computes `I64` in CPython's
  unbounded bignums and re-wraps; the native floor already does it in hardware.
  The crutch is the bignum reference, not the operation.
- **Why chirality needs its own:** three floors (reference interpreter,
  constant-folder, x86-64 backend) each implement the same typed op and must
  agree *bit-for-bit*; the Python bignum baseline exists only to be the one
  definition the other floors collapse onto or validate against.

## 2. Research

- **Reference class:** SPEC — the ABI this must conform to bit-for-bit, not an
  algorithm to invent. Sources reviewed: `scaffold/chirality/impl_pure.py`
  (`wrap64`/`i64_div`/`i64_mod`, lines 19–75); the pinned semantics comment
  (lines 11–17); `docs/floor-agreement.md` "Worked example: division" (§73–83)
  and its collapse/validate/fuzz gradient (§55–71); `scaffold/lib/prelude.chiral`
  (the `extern + - * / %` typed face, lines 21–30); `scaffold/lib/mem-linear.chiral`
  (real `(refine I64 …)` surface syntax, line 27).
- **Key findings:**
  1. **Two decisions are load-bearing** (impl_pure.py:14–17): `I64` is
     two's-complement 64-bit and `+ - *` *wrap* (match the native drop); `/` and
     `%` are **Euclidean** (`0 <= r < |b|`), matching SMT-LIB's `div`/`mod` "so a
     solver-discharged refinement means at runtime exactly what it proved."
  2. `wrap64(n) = (n - MIN) % 2^64 + MIN` — the canonical fold into signed range.
  3. **The canonical floor-agreement bug** (floor-agreement.md:75–83): `(/ (- 0 7) 2)`
     gave `-4` (reference floored), `-3` (fold truncated), `-3` (hardware `idiv`
     truncates) — one type, three values, `preserve-check` passed all three. Fix:
     *collapse* the fold onto the reference, *pin* the reference to Euclidean,
     *validate* the native floor by differential fuzz across the full sign grid.
  4. Division is **partial** at `b = 0`; the reference returns `None` and the
     caller raises `PortError` (impl_pure.py:30, 62–75).

## 3. Conventional (other-language) approach

How this is done outside chirality — the existing Python reference (impl_pure.py):

```python
_I64_MIN = -(2 ** 63)
_I64_MOD = 2 ** 64

def wrap64(n):                       # fold an unbounded int into signed 64-bit
    return (n - _I64_MIN) % _I64_MOD + _I64_MIN

def i64_div(a, b):                   # Euclidean quotient, or None on zero divisor
    if b == 0: return None
    r = a % b
    if r < 0: r += abs(b)
    return wrap64((a - r) // b)      # (a - r) is an exact multiple of b

impl("+")(lambda a, b: wrap64(a + b))   # compute wide, then drop to 64 bits
```

- **Assumptions it bakes in:** (1) an **unbounded integer** underneath — `a + b`
  is computed in bignum space then re-narrowed, so overflow is a post-hoc
  correction rather than the machine's actual behavior; (2) **partiality via a
  sentinel** — `None` threading plus an exception (`PortError`) at the use site,
  invisible in the type `(-> I64 I64 I64)`; (3) **semantics live in host code** —
  the arithmetic law is a Python function, so a second floor (fold, native) can
  silently disagree until a differential test catches it. Nothing in the type
  records that `+` wraps, that `/` is Euclidean, or that `b` must be nonzero.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** the **float→I64 wall** (I64 *is* the machine word;
  there is no promotion to bignum, so wrap is the type, not a fixup);
  **refinement types** (P: refinement absorbs integer safety); **totality** —
  partiality is the *marked climb*, totality the default (P4); **category A**
  (correctness by proof, pure `->`, no membrane); **floor collapse** as the
  substrate form of P5 (one definition can't disagree with itself).
- **The reframing:** two moves. **(a) Wrap becomes the type, not a correction.**
  `I64` denotes two's-complement 64-bit; `+ - *` are the wrapping ops by
  definition, so there is no wide compute to re-narrow — the native `add`/`imul`
  *is* the semantics, and the reference only exists to pin it. **(b) The zero
  divisor moves into the type.** Instead of returning `None` and raising, the
  nonzero precondition becomes a refinement `(refine I64 (<> 0))` the solver
  discharges at compile time (exactly the `mem-put-checked` pattern, mem-linear.chiral:27),
  so `div` is **total**: the `b = 0` arm is unreachable by construction. When the
  caller *cannot* prove nonzero, they climb explicitly — `(Maybe I64)` — which is
  the honest, marked form of the reference's `None`.
- **What chirality makes impossible here:** you cannot compute `a + b` in some wider
  arithmetic and "forget" to wrap (there is no wider arithmetic in the type); and
  three floors cannot quietly disagree, because the Euclidean pin is one
  reference the others collapse onto or are validated against — the
  `-4`/`-3`/`-3` split becomes a checked obligation. **Honest limit:** unproven
  division is not *unrepresentable* today — the prelude's raw `/` stays plainly
  typed `(-> I64 I64 I64)` (verified: `prelude.chiral` extern block; zero divisor
  = `PortError` at the reference, `impl_pure.py`). The refined `div`/`mod` below
  are the *cheap safe path* (P4) beside it; whether the prelude face itself
  should become the refined one (making the raw form the marked climb) is a
  spec-time question (§6).

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")   ; I64, Bool, Maybe, Pair, and the externs + - * / % =i <i <=i

; ---- The pinned two's-complement / Euclidean contract (documentation) --------
; I64 is 64-bit two's-complement. `+ - *` WRAP on overflow: the result is
; (n - MIN) mod 2^64 + MIN, which is exactly the native `add`/`sub`/`imul` drop.
; There is no promotion to a bignum -- the wrap IS the type. `/` and `%` are
; EUCLIDEAN (remainder in [0, |b|)), matching SMT-LIB div/mod so a refinement the
; solver discharges means at runtime precisely what it proved. These are the
; prelude externs; restated here only to name the semantics they are pinned to.
;   (extern + (-> I64 I64 I64))   ; wrapping add       (native: add)
;   (extern * (-> I64 I64 I64))   ; wrapping mul       (native: imul)
;   (extern / (-> I64 I64 I64))   ; Euclidean quotient (native: idiv + fixup)
;   (extern % (-> I64 I64 I64))   ; Euclidean remainder in [0,|b|)

; ---- Divisor proven nonzero: partiality retired at the type level ------------
; Raw `/` is partial (undefined at b = 0). Totality is the default (P4), so the
; precondition goes INTO the type: a safe divisor is an I64 refined `<> 0` (the
; disequality op in refine.py's _OPS — there is no `/=`). In the arrow this
; reads just like mem-linear's `(refine I64 (>= 0) (< n))` offset. Inside div,
; the b = 0 case is UNREACHABLE by construction: no None, no alarm, no guard.
(def div (-> I64 (refine I64 (<> 0)) I64)
  (lam (a b) (/ a b)))          ; refinement forgets to base I64 at the raw call

(def mod (-> I64 (refine I64 (<> 0)) I64)
  (lam (a b) (% a b)))

; Euclidean divmod as the pair a caller usually wants, still total.
(def divmod (-> I64 (refine I64 (<> 0)) (Pair I64 I64))
  (lam (a b) (pair (/ a b) (% a b))))

; ---- When nonzero is NOT statically known: mark the partiality ---------------
; Cannot prove b <> 0? Then you CLIMB -- return Maybe instead of asserting. This
; is the explicit, typed form of the reference's `return None`; the caller must
; `case` on it. (Raw `/` needs no proof -- its face is plain I64 -- but the
; guard makes the zero case unreachable, so no PortError can fire here.)
(def try-div (-> I64 I64 (Maybe I64))
  (lam (a b)
    (case (=i b 0)
      (true  (none))
      (false (some (/ a b))))))
```

- **Knobs to modify:** swap the base type (`I64` → a future `U64`/`I32` word) and
  the wrap modulus follows the type; tighten the divisor refinement (e.g.
  `(refine I64 (<> 0) (>= 0))` for a nonnegative divisor); replace the `Maybe`
  climb with an alarm-typed effect (ties [[E26-alarms]]) if the partiality should
  surface as a counter-effect rather than a value; add saturating or
  checked-overflow variants as *separate* named ops rather than changing `+`.
- **Deliberately omitted:** the `wrap64` fold itself (it is the reference's
  bignum→64-bit narrowing — on the native floor the drop is implicit in the
  register width, so there is nothing to write in chirality); the string/bytes
  primitives that share impl_pure.py; and the differential-fuzz harness that
  validates the native floor (that is a floor-agreement test, not this op's type).

## 6. Use / modify notes

- **Lands in:** the typed face stays in `scaffold/lib/prelude.chiral` (the `extern`
  block, lines 21–30 — unchanged); the *reference implementation* of the law
  moves out of `scaffold/chirality/impl_pure.py` (`wrap64`/`i64_div`/`i64_mod`) into
  chirality once refinement-safe `div`/`mod`/`divmod` exist, with the native backend
  (`lib/emit-x64.chiral`, E19) providing the collapsed floor.
- **Conformance target:** reproduce the reference bit-for-bit across the full sign
  grid, and specifically pass the canonical case `(/ (- 0 7) 2) = -4` and
  `(% (- 0 7) 2) = 1` (Euclidean), on all three floors — reference, fold, native.
  `+ - *` must match two's-complement wrap at the `I64` boundaries
  (`(+ MAX 1) = MIN`).
- **Open questions:** ~~the disequality atom~~ — **RESOLVED at audit
  (2026-08-01): it exists, spelled `<>`** (the legal refine ops are exactly
  `>= > <= < <>`, `refine.py` `_OPS`; the cheatsheet's own nonzero-divisor
  example is `(refine I64 (<> 0))`) — applied throughout §5. Remaining: (1)
  does the **prelude face itself** become the refined `div`/`mod` (P4: the safe
  shape as the default, raw division the marked climb), or do the refined
  wrappers live beside the raw face? (2) does `/` on the *native* floor emit
  `idiv` + a sign fixup to reach Euclidean, or a branchless correction? — a
  codegen decision for E19, gated on the differential-validation obligation
  (note the guarded-`idiv` D3 fix already made the three floors agree on
  `INT_MIN/-1` and `÷0`-trap behavior).
- **Related:** [[E17-optimizer]] (the constant-folder that must import this
  reference, floor-agreement collapse); [[E19-x64-codegen]] (the native floor to
  validate); [[E26-alarms]] (the alarm-typed alternative to the `Maybe` climb);
  [[E11-totality]] (partiality as the marked climb this example enacts).
