---
element: E108
slug: shift-ops
title: Right-shift surface ops — `shr` (logical) + `sar` (arithmetic) surface externs
kind: BUILD-PROPER
example: examples/E108-shift-ops.md
status: audited
updated: 2026-08-12
---

# E108 SPEC — `shr` / `sar` right-shift surface externs

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 3 steps are executable at HEAD.
> `lib/prelude/prelude.chiral:70-71` carries `shr` and `sar`. Bucket and
> evidence: `records/spec-tier-triage.md`. This file was not rewritten and its
> `status:` was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** two new lines in `lib/prelude/prelude.chiral`, right after
  `shl` at `:69` — `(extern shr (-> I64 I64 I64))` (logical / zero-fill) and
  `(extern sar (-> I64 I64 I64))` (arithmetic / sign-fill) — so surface programs
  can call `(shr a k)` and `(sar a k)` and have them type-check, interpret, and
  native-compile. B1's current `load: unknown name sar` gap closes.
- **Non-goals:** no change below the surface (every internal layer already
  carries `shr`/`sar` — see §2); the `poll.chiral:22-23` call-site rewrite is
  optional residue (§6), not part of this deliverable.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no map row — E108 postdates the map snapshot; kind
  is BUILD-PROPER but in practice the below-surface work is DONE, so the true
  delta is a two-line EXTEND of the prelude extern block. E108 is a strict subset
  of E96 (`band`/`bor`/`bxor`/`shl`), whose shape it mirrors exactly.
- **Live code — VERIFY, do NOT re-add (all cites confirmed against the tree):**
  - `Op` sum ctors `op-sar` / `op-shr` — `prelude.chiral:28` (inside `data Op`).
  - Interp arms — `impl_pure.py:66-67`
    (`sar = wrap64(a >> (k&63))`; `shr = wrap64((a & (2^64-1)) >> (k&63))`).
  - Py shuttle — `native.py:63` `_PRIMS` and `:70` `_STR2OP` both list `sar`/`shr`.
  - Constant-fold prim-sigs — `optimize.py:705` (`sar`/`shr` in the seeded tuple).
  - Erase op-parse — `tal-erase.chiral:101-102` (`str-eq op "sar"`/`"shr"` →
    `op-sar`/`op-shr`).
  - x86 encodings — `mach-x64.chiral:321` `x-sar-cl` (`sar rax,cl`) / `:323`
    `x-shr-cl` (`shr rax,cl`), dispatched at `:375`/`:377`.
- **True delta:** the two `(extern …)` lines. Nothing else — no shuttle, fold,
  emit, or interp work is needed; the audit and this SPEC's re-verification both
  confirm every below-surface layer is present and mutually agreeing.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Should E108 touch any layer besides the prelude extern? | RESOLVED — surface-only. | Every internal layer is pre-wired by the Euclidean-division lowering that already emits `sar`/`shr`; verified at `prelude.chiral:28`, `impl_pure.py:66-67`, `native.py:63/70`, `optimize.py:705`, `tal-erase.chiral:101-102`, `mach-x64.chiral:321/323`. The extern is the only missing face. |
| 2 | `shr` logical vs `sar` arithmetic — are the semantics settled? | RESOLVED. | Settled by the existing interp arms `impl_pure.py:66-67`: `shr` masks to unsigned then shifts (zero-fill); `sar` keeps the sign-propagating shift (sign-fill). Count masked `&63` on both — no undefined-behavior cliff. Two distinct names by design (boundary-sums; the shift kind is a `ctor`, never a signedness accident). |
| 3 | Migrate `poll.chiral:bit?` to the new op in this run? | DEFERRED to §6 residue. | The extern is the element; the call-site rewrite is optional polish, not required for the gate. |

No NEEDS-AUTHOR items. §4 is fully unblocked.

## 4. Change plan (ordered, commit-sized)

### Step 1 — Add the two surface externs
- **Target:** `lib/prelude/prelude.chiral` — immediately after the `shl` extern at
  `:59`, inside the `; i64 (bitwise)` block.
- **Change:** insert, mirroring the E96 band/bor/bxor/shl formatting:
  ```chirality
  (extern shr (-> I64 I64 I64))             ; shift right, logical    (zero-fill)
  (extern sar (-> I64 I64 I64))             ; shift right, arithmetic (sign-fill)
  ```
- **Size:** XS (2 lines).

### Step 2 — Verify the internal layers accept `shr`/`sar` from the surface
- **Target:** no edits — a probe. Compile a tiny program using `(shr a b)` and
  `(sar a b)` through B1 and confirm it type-checks and lowers (the pre-E108
  failure was `load: unknown name sar`; it must now be gone).
- **Change:** none; this is the guard that Step 1 was sufficient and no
  below-surface layer was in fact missing.
- **Size:** XS (probe, folded into the §5 sample).

### Step 3 (OPTIONAL residue) — simplify the `poll.chiral` bit test
- **Target:** `lib/runtime/poll.chiral:22-23` — `bit?` currently
  `(=i (mod (div m f) 2) 1)`.
- **Change:** may be re-keyed by bit index as `(=i (band (shr m k) 1) 1)`. Explicitly
  NOT required for the gate; land as a follow-up cleanup only if convenient.
- **Size:** XS, optional.

## 5. Conformance gate

- **Golden behavior (behavioral sample, compile + run through B1):** all four
  semantics hold, exit 42:
  - `(shr -1 63)` = `1` (logical: top bit shifts to LSB, zero-filled)
  - `(sar -1 63)` = `-1` (arithmetic: sign smears, all-ones preserved)
  - `(shr 8 2)`  = `2`
  - `(sar -8 1)` = `-4` (signed divide-by-2, rounds toward -inf)
  The sample computes these and exits `42` iff every check passes, otherwise a
  distinguishable non-42 code.
- **Sample file:** `scaffold/samples/e108_shift.chiral` (new; sits beside the
  existing `scaffold/samples/*.chiral` behavioral samples). Optionally mirror the
  E96 differential harness with `scaffold/tests/test_e108_shift_goldens.py`
  (B1-vs-Python agreement on `shr`/`sar`, following
  `test_e96_bitwise_goldens.py`).
- **Core-blob gate (REQUIRED — `prelude.chiral` is a compiler-blob source):** after
  the edit, per `.planning/BUGS-AND-GAPS.md` (2026-08-11), run
  ```
  chirality_blob scaffold/lib sys-linkage compile-front compile-back compile-emit compile-all > blob
  scaffold/build/B1 < blob | cmp - scaffold/build/B1
  ```
  It must be byte-identical (the compiler never calls `shr`/`sar`, so its
  self-image should not move; committed B1 = 827768 B). Only if `cmp` differs:
  reblob → `B1 < blob > chirality-bin.new`, refixpoint (`chirality-bin.new < blob` reproduces
  itself), promote.
- **Green line:** 704 → ≥ 705 (the E108 sample; +1 more if the differential
  golden test is added); existing suite stays green; ledger-lint clean.
- **Done when:** `scaffold/samples/e108_shift.chiral` compiled by B1 exits 42, and
  the core-blob `cmp` is byte-identical (or reblob+refixpoint+promote completed).

## 6. Residue & links

- **Deliberately unbuilt:** `poll.chiral:bit?` migration to `(band (shr m k) 1)`
  (Step 3) — home is a follow-up cleanup commit, nobody's yet.
- **Follow-on:** completes the surface bitwise family opened by E96; unblocks
  clean bit-field idioms across the lib without div/mod workarounds.
- **Related:** [[E108-shift-ops]], E96 (band/bor/bxor/shl — the mirrored shape),
  E70 (the closed `Op` sum this rides on).
