---
element: E108
slug: shift-ops
title: Right-shift surface ops: `shr` (logical) + `sar` (arithmetic) surface externs completing the bitwise family (E96 did `band`/`bor`/`bxor`/`shl`) — Op ctors + mach-x64 emit already exist; needs surface extern (`prelude.chiral`), interp (`impl_pure.py`), py shuttle (`native.py` `_PRIMS`/`_STR2OP`) + fold (`optimize.py`), erase parse (`tal-erase.chiral`)
kind: BUILD-PROPER
reference_class: OURS
ours_source: scaffold/chirality/impl_pure.py
status: drafted
updated: 2026-08-11
---

# E108 — Right-shift surface ops: `shr` (logical) + `sar` (arithmetic) surface externs completing the bitwise family (E96 did `band`/`bor`/`bxor`/`shl`) — Op ctors + mach-x64 emit already exist; needs surface extern (`prelude.chiral`), interp (`impl_pure.py`), py shuttle (`native.py` `_PRIMS`/`_STR2OP`) + fold (`optimize.py`), erase parse (`tal-erase.chiral`)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E108, expose two right-shift ops at the surface — `shr` (logical,
  zero-fill) and `sar` (arithmetic, sign-fill) — as `I64 -> I64 -> I64` externs,
  completing the bitwise family that E96 finished for `band`/`bor`/`bxor`/`shl`.
- **Kind:** BUILD-PROPER — a designed op the language already lowers internally
  but never gave surface programs a typed name for.
- **Why chirality needs its own:** shift is the honest primitive for bit-field work.
  Today code that wants "the k-th bit" fakes it with `(mod (div m f) 2)`
  arithmetic (`poll.chiral:22-23`), which is slower, obscures intent, and only
  works for exact powers of two. `(band (shr m k) 1)` says exactly what it means
  and lowers to one `shr rax, cl` + one `and`.

## 2. Research

- **Reference class:** OURS — the existing chirality pipeline (`prelude.chiral`,
  `impl_pure.py`, `native.py`, `optimize.py`, `tal-erase.chiral`, `mach-x64.chiral`)
  and the E96 `band` shape it mirrors.
- **The load-bearing finding (checked, not assumed):** unlike E96, the internal
  layers are ALREADY DONE. `shr`/`sar` are not new — they are emitted internally
  by the Euclidean division lowering (`optimize.py:357-364` uses `sar`/`shr` to
  build `mulhi`-based `div`/`mod`), so every layer below the surface already
  carries them:
  - `Op` sum ctors `op-sar`/`op-shr` — `prelude.chiral:28`.
  - Interp arms — `impl_pure.py:66-67`
    (`sar = a >> (k&63)`; `shr = (a & mask) >> (k&63)`).
  - Py shuttle — `native.py:63` `_PRIMS` and `:70` `_STR2OP` both list `sar`/`shr`.
  - Constant-fold whitelist — `optimize.py:705`.
  - Erase op-parse — `tal-erase.chiral:101-102`.
  - x86 encodings — `mach-x64.chiral:321` `x-sar-cl` / `:323` `x-shr-cl`
    (`sar rax,cl` / `shr rax,cl`), wired in the op→bytes dispatch.
  The ONLY missing layer is the surface extern in `prelude.chiral`. So E108 is a
  strict subset of E96: two declaration lines, no shuttle work.
- **SHR vs SAR semantics (web-verified, Intel SDM / felixcloutier):** both shift
  right; SHR fills the vacated MSB with 0 (logical — unsigned divide by 2^k),
  SAR replicates the sign bit into the MSB (arithmetic — signed divide by 2^k).
  This matches `impl_pure.py` exactly: `shr` masks to unsigned first, `sar` keeps
  Python's sign-propagating `>>`. The sign distinction is the whole reason both
  ops exist and must stay two separate names.

## 3. Conventional (other-language) approach

In C the two shifts are one operator `>>`, and which shift you get is decided by
the operand's declared signedness, not by the operator:

```c
unsigned long u = ...;  long s = ...;
u >> k;   /* SHR — logical, zero-fill  */
s >> k;   /* SAR — arithmetic, sign-fill (implementation-defined pre-C99) */
```

- **Assumptions it bakes in:** the shift kind is an invisible property of the
  variable's type, so a signedness bug silently swaps SHR for SAR. Shift counts
  `>=` word width are undefined behavior. There is no proof that the shift is
  what the author meant — the compiler picks the instruction from a type the
  reader may not be looking at.

## 4. The chirality idea

Chirality makes the shift kind a **name**, not a hidden consequence of a type. `shr`
and `sar` are two distinct, total `I64 -> I64 -> I64` externs. The choice
between zero-fill and sign-fill is spelled at the call site and cannot flip on
you when a value's signedness changes elsewhere.

- **Chirality features in play:** the closed `Op` sum (the shift kind is a ctor
  parsed once at the erase boundary, `op-sar`/`op-shr`, never a stringly
  dispatch — the boundary-sums directive); the pure effect membrane (`->`, empty
  row — a shift crosses nothing, so it stays off the effect ledger and needs no
  capability); the I64-only floor (shifts are two's-complement on the one word
  type, count masked to `&63` so there is no undefined-behavior cliff).
- **The reframing:** a single extern declaration turns an already-lowered
  internal op into a first-class surface primitive. No new semantics are minted —
  the interp arm, the fold law, and the x86 encoding all already exist and agree;
  the extern just gives them a typed public face.
- **What chirality makes impossible here:** you cannot silently get the wrong shift
  from a signedness mismatch (the two ops are different names), and you cannot
  invoke a shift as an ambient effect — it is pure by its `->` type.

## 5. Chirality example (fleshed)

The whole element is these two lines, added in `prelude.chiral` right after the
existing `shl` extern (`:59`), mirroring the E96 band/bor/bxor/shl block exactly:

```chirality
; ---------------------------------------------------------------- i64 (bitwise)
(extern band (-> I64 I64 I64))            ; bitwise AND   (E96)
(extern bor  (-> I64 I64 I64))            ; bitwise OR    (E96)
(extern bxor (-> I64 I64 I64))            ; bitwise XOR   (E96)
(extern shl  (-> I64 I64 I64))            ; shift left    (E96)
(extern shr  (-> I64 I64 I64))            ; shift right, logical    (zero-fill)   <- E108
(extern sar  (-> I64 I64 I64))            ; shift right, arithmetic (sign-fill)   <- E108
```

Once declared, both ops flow through the machinery that already handles them.
The concrete call-site win — bit extraction from a `poll` revents word. Today
(`poll.chiral:22-23`):

```chirality
; bit-test faked with division: only works for exact powers of two,
; lowers to a full div/mod sequence.
(def bit? (-> I64 I64 Bool)
  (lam (m f) (=i (mod (div m f) 2) 1)))
```

After E108, keyed by bit index instead of a power-of-two mask:

```chirality
; the k-th bit of a flags word: logical shift right, then mask the LSB.
; shr (not sar) so a set top bit never smears down into the test.
(def bit-at? (-> I64 I64 Bool)
  (lam (m k) (=i (band (shr m k) 1) 1)))

; the arithmetic sibling, for signed divide-by-2^k (rounds toward -inf):
; sar preserves sign, so (sdiv2 -8 2) = -2, not a logical-shift garbage value.
(def sdiv2 (-> I64 I64 I64)
  (lam (n k) (sar n k)))
```

- **Knobs to modify:** nothing structural — the two extern lines are the whole
  deliverable. A reuser choosing between the ops picks `shr` for bit tests and
  unsigned scaling, `sar` for signed division by powers of two.
- **Deliberately omitted:** any change below the surface. The `Op` ctors, interp
  arms, fold law, erase parse, and x86 encodings are all already present and are
  NOT touched.

## 6. Use / modify notes

- **Lands in:** `lib/prelude/prelude.chiral` (two `(extern …)` lines beside `shl`
  at `:59`). No other file changes — verify (do not re-add) the existing
  `impl_pure.py:66-67`, `native.py:63/70`, `optimize.py:705`,
  `tal-erase.chiral:101-102`, `mach-x64.chiral:321/323` entries.
- **Conformance target:** a probe `(band (shr a k) 1)` / `(sar a k)` must
  type-check, interpret, and native-compile identically; `sar` sign-extends and
  `shr` zero-fills (e.g. `(shr -1 63) = 1`, `(sar -1 63) = -1`). B1 must reproduce
  itself after the prelude change (self-host check).
- **Open questions:** whether to also migrate `poll.chiral:bit?` to the new op in
  the same commit or leave that as a follow-up cleanup — the extern is the
  element; the call-site rewrite is optional polish.
- **Related:** E96 (band/bor/bxor/shl surface externs — the exact shape mirrored),
  E70 (the closed `Op` sum this rides on).
