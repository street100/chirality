---
element: E96
slug: bitwise-ops
title: Bitwise op family: complete {`band`,`bor`,`bxor`,`shl`} through surface extern (`prelude.chiral`), Op ctors + printer, interp (`impl_pure.py`), py shuttle (`native.py` `_PRIMS`/`_STR2OP`) + fold list (`optimize.py:705`), erase parse (`tal-erase.chiral` op-parse), and mach-x64 reg+imm encodings with `op-bytes`/`bini-body` arms
kind: BUILD-PROPER
reference_class: OURS
ours_source: scaffold/chirality/impl_pure.py
status: reviewed
updated: 2026-08-10
---

# E96 — Bitwise op family: complete {`band`,`bor`,`bxor`,`shl`} through surface extern (`prelude.chiral`), Op ctors + printer, interp (`impl_pure.py`), py shuttle (`native.py` `_PRIMS`/`_STR2OP`) + fold list (`optimize.py:705`), erase parse (`tal-erase.chiral` op-parse), and mach-x64 reg+imm encodings with `op-bytes`/`bini-body` arms

> One worked example: close the Python-floor gap for `band` (`native.py` +
> `optimize.py`), then run the S7 coverage probe (add an Op ctor without an
> emitter arm — B1 must REJECT). `bor`/`bxor`/`shl` are already through
> all seven layers.

## 1. Scope

- **Element:** E96, finish the I64 bitwise op family. The real state
  (verified from source, 2026-08-10):

  | Layer | band | bor | bxor | shl |
  |-------|------|-----|------|-----|
  | `prelude.chiral` extern + Op ctor | ✓ | ✓ | ✓ | ✓ |
  | `tal-erase.chiral` op-parse | ✓ | ✓ | ✓ | ✓ |
  | `mach-x64.chiral` op-bytes | ✓ | ✓ | ✓ | ✓ |
  | `mach-x64.chiral` bini-body | ✓ | ✓ | ✓ | ✓ |
  | `native.py` _PRIMS + _STR2OP | **✗** | ✓ | ✓ | ✓ |
  | `optimize.py` prim_sigs | **✗** | ✓ | ✓ | ✓ |

  `bor`/`bxor`/`shl` are fully built through all seven layers. The only
  gap is `band` missing from the Python floor (`native.py`, `optimize.py`).
  Per S12a this is advisory — the chirality compiler doesn't depend on it —
  but the folder/interp agreement law says it must land.

  The remaining compiler verification deliverable is the **S7 coverage
  probe**: add an `Op` ctor in the sum but omit its `mach-x64` emitter arm.
  B1 must REJECT with an exhaustive-match error. If it doesn't, the
  emitter silently drops ops at runtime (a correctness hole).

- **Kind:** BUILD-PROPER — an op family where only the Python-floor cleanup
  and the coverage-probe audit remain.
- **Why chirality needs its own:** the self-hosted interpreter, optimizer, hash,
  and bit-set need OR/XOR/shift as first-class typed I64 ops that lower to
  real x86-64. Every layer must agree byte-for-byte (fold == interp ==
  native), or B1 stops self-reproducing. This is a pure category-A
  extension — the value is *completeness and agreement*, not new capability.

## 2. Research

- **Reference class:** OURS — our own Python + tal + mach across both floors:
  `scaffold/chirality/impl_pure.py` (the `IMPL_PURE` host bindings + `wrap64`),
  `native.py` (`_PRIMS`/`_STR2OP`), `optimize.py` (the constant-fold op
  list), `tal-erase.chiral` (op-parse arm), `mach-x64.chiral` (reg-form +
  imm-form + `op-bytes` + `bini-body`).
- **Key findings:**
  1. **`bor`/`bxor`/`shl` are the copy-and-modify template for `band`'s
     Python-floor entries.** They already exist in `native.py` (`_PRIMS`
     L63 + `_STR2OP` L71) and `optimize.py` (`prim_sigs`). `band`'s
     two missing lines mirror these exactly — `_PRIMS["band"] = Op.BAND`,
     `_STR2OP["band"] = Op.BAND` — plus the `prim_sigs` tuple entry.
  2. **I64 is two's-complement 64-bit and every result wraps** — `impl_pure.py`
     already owns this law via `wrap64` (single source of truth, imported
     by the folder so a fold and the runtime can never disagree).
     `band`/`bor`/`bxor` on wrapped operands stay in range; `shl` wraps
     after shifting (the count is already masked to `0..63` by x86).
  3. **The S7 coverage probe is the real compiler verification.** The chirality
     compiler must exhaustively match on the `Op` sum in every emitter arm.
     Adding a `(op-probe)` ctor that has no `case` arm in `mach-x64.chiral`
     proves B1 catches the gap at compile time — not at runtime, not via
     a Python lint rule.
  4. **Python is the advisory floor (S12a).** The chirality compiler runs
     without Python — `native.py` and `optimize.py` exist for testing and
     agreement verification. They must stay in sync but a missing entry is
     a test-suite catch, not a compiler crash.

## 3. Conventional (other-language) approach

How this is done outside chirality — the existing Python floor.

The Python floor holds `IMPL_PURE` (interp), `_PRIMS`/`_STR2OP` (op-name
shuttle), and `prim_sigs` (constant-fold list). `band` already has its
`IMPL_PURE` entry — only the shuttle and fold-list entries are missing.
`bor`/`bxor`/`shl` already have all three, so they are the template:

```python
# scaffold/chirality/impl_pure.py — band's IMPL_PURE entry already exists
IMPL_PURE["band"] = lambda a, b: wrap64(a & b)   # done

# scaffold/chirality/native.py — band is the only missing pair
_PRIMS  = { ..., "band": Op.BAND, ... }   # line ~63: add "band"
_STR2OP = { ..., "band": Op.BAND, ... }   # line ~71: add "band"

# scaffold/chirality/optimize.py — band is the only missing entry
prim_sigs = (
    # ...
    ("band", 2, lambda a, b: wrap64(a & b)),   # add this row
)
```

- **Assumptions it bakes in:** Python's ints are unbounded (`1 << 64` is a
  real 20-digit number, never wraps); bit ops carry no width and no proof
  obligation. chirality refuses both — there is one width (I64), overflow is a
  defined two's-complement wrap, and the shift count is masked, never
  partial. The Python floor's role is conformance oracle, not authority —
  `wrap64` is the shared law that keeps fold/interp/native identical.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** category A (pure typed computation, no referent
  outside RAM); the float→I64 wall (there is only I64, and bit ops live
  *only* here); totality (every op is total — no partial shift, no
  exception); the `->` membrane (all four are pure, empty-row `->`, provably
  no crossing).
- **The reframing:** `band` is already first-class across all chirality layers
  — `prelude.chiral` extern, `Op` ctor + printer arm, `tal-erase` op-parse
  arm, `mach-x64` reg+imm encodings with `op-bytes`/`bini-body` arms. This
  is not a from-scratch build — it's a Python-floor completion that mirrors
  the already-landed `bor`/`bxor`/`shl` entries. The chirality compiler does not
  touch `native.py` or `optimize.py` at all (S12a: Python is advisory), so
  the chirality side was already complete before this element was catalogued.
- **What chirality makes impossible here:** unbounded `<<` (no bignum — the
  width is I64, full stop); a partial/raising shift (the count is masked
  to `0..63` by construction, so `shl` is total); silent fold/runtime
  divergence (the folder folds through the same `wrap64` the interp and
  native emitter use — there is no second implementation to drift);
  incomplete emitter arms (the `Op` sum is a closed sum and `case` is
  coverage-checked — the S7 probe proves this by construction).

## 5. Chirality example (fleshed)

The clear-cut example — real source, from the tree as of 2026-08-10.

`band` is already present in every chirality layer. Below is what exists (not
what should be added). The two-line Python gap is shown in §3.

```chirality
; ── prelude.chiral : the typed surface face — band extern + Op ctor ──────────
; All four ops exist as typed externs + Op constructors. Verified L28-29,56-59.
(declare band (-> I64 I64 I64))
(declare bor  (-> I64 I64 I64))
(declare bxor (-> I64 I64 I64))
(declare shl  (-> I64 I64 I64))

(data Op ()
  ; … existing arithmetic ctors …
  (op-band )
  (op-bor  )
  (op-bxor )
  (op-shl  ))

; ── tal-erase.chiral : op-parse arm — band arm verified L103 ─────────────────
(declare op-parse (-> Str (Maybe Op)))
(def op-parse (lam (op)
  (case (str-eq op "+")    (true (some (op-add)))
  ; … existing arms …
  (false (case (str-eq op "band")  (true (some (op-band)))
  (false (case (str-eq op "bor")   (true (some (op-bor)))
  (false (case (str-eq op "bxor")  (true (some (op-bxor)))
  (false (case (str-eq op "shl")   (true (some (op-shl)))
  (false (none)))))))))))))

; ── mach-x64.chiral : op-bytes (reg/reg form) — band arm verbatim L379 ──────
(def op-bytes (-> Op Bytes)
  (lam (op)
    (case op
      ; … arithmetic + shift arms …
      ((op-shr)   x-shr-cl)

      ((op-band)  x-and-rcx)
      ; … 3 more ops (bor → x-or-rcx, bxor → x-xor-rcx, shl → x-shl-cl)
      ))))

; ── mach-x64.chiral : bini-body (imm form) — band arm verbatim L965 ──────────
(def bini-body (-> Op I64 Bytes)
  (lam (op imm)
    (case op
      ; … div/mod/sar/shr arms …
      ((op-band) (case (imm32? imm) (true (x-imm-and imm))
                   (false (bcat (x-mov-rcx-imm imm) (op-bytes op)))))
      ; … 3 more ops (bor → x-imm-or, bxor → x-imm-xor, shl → x-shl-imm)
      ((op-mulhi) (bcat (x-mov-rcx-imm imm) (op-bytes op))))))
```

- **Knobs to modify:** none at the chirality layer — the chirality-side code is
  complete for all four ops. The remaining work is two Python lines plus
  the S7 coverage probe (see §6). To add a further op (`bnot`, `rol`,
  `ror`) copy any existing arm through all seven layers.
- **Deliberately omitted:** the `wrap64`/mask arithmetic (shown in §3 on
  the Python floor — the interp and folder own the semantics); the
  mechanical `imm32-le`/`imm8-le` little-endian byte loops (`; …`); the
  printer arm for the `Op` ctor (exists, mechanical).

## 6. Use / modify notes

- **Lands in (two Python files, one coverage probe):**
  - `scaffold/chirality/native.py` — add `"band": Op.BAND` to `_PRIMS`
    (~L63) and `_STR2OP` (~L71). Copy the `bor` entry, change the name.
  - `scaffold/chirality/optimize.py` — add `("band", 2, lambda a,b:
    wrap64(a & b))` to `prim_sigs`. Copy the `bor` entry, change the op.
  - **S7 coverage probe** (new compiler verification, chirality-side only):
    add a dummy `(op-probe)` ctor to the `Op` sum, keep it out of every
    `case` arm in `mach-x64.chiral`. B1 must REJECT with an exhaustive-match
    error. If it compiles, the emitter has a coverage hole. This is the
    deliverable that closes E96 — the probe becomes a permanent regression
    test proving the compiler catches incomplete emitter arms.
- **Conformance target:** for all I64 `a`, `b`: fold(`op` a b) == interp(`op`
  a b) == native(`op` a b), bit-exact. `band`/`bor`/`bxor` are
  two's-complement wraps; `shl` masks the count to `0..63` and wraps the
  result. B1 must still self-reproduce byte-identically (the fixpoint
  invariant). S12a note: Python is advisory — the chirality compiler doesn't
  link `native.py` or `optimize.py`, so the Python gap is a test-suite
  catch, not a compiler dependency.
- **Open questions:** the S7 probe should be a permanent file (not a
  throwaway test) so every future `Op` ctor addition re-verifies coverage;
  whether to co-ship `bnot`/`rol`/`ror` in a follow-up element or close the
  family here (the right-shift pair `shr`/`sar` already exists, and `shl` has
  no arithmetic-vs-logical variant, so the shift family is now complete).
- **Related:** [[E96-bitwise-ops]] — the `band` gap (this file); the I64
  floor + `wrap64` law shared with the arithmetic ops; `bor`/`bxor`/`shl`
  as the already-landed template; S12a (Python-is-advisory decision, 2026-08).
