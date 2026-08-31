---
element: E96
slug: bitwise-ops
title: Bitwise op family: complete {`band`,`bor`,`bxor`,`shl`} through surface extern (`prelude.chiral`), Op ctors + printer, interp (`impl_pure.py`), py shuttle (`native.py` `_PRIMS`/`_STR2OP`) + fold list (`optimize.py:705`), erase parse (`tal-erase.chiral` op-parse), and mach-x64 reg+imm encodings with `op-bytes`/`bini-body` arms
kind: BUILD-PROPER
example: examples/E96-bitwise-ops.md
status: audited
updated: 2026-08-10
---

# E96 SPEC — Bitwise op family: complete {`band`,`bor`,`bxor`,`shl`}

> Implementation contract from the worked example. The example is the design
> rationale; this file is the executable plan the implementation run follows.

## 1. Deliverable

- **After this runs:** `band` is wired through the Python advisory floor
  (`native.py` `_PRIMS`/`_STR2OP` + `optimize.py` `prim_sigs`), exactly matching
  the already-landed `bor`/`bxor`/`shl` entries. The S7 coverage probe file
  lives in `scaffold/tests/` and B1 rejects it with an exhaustive-match error.
  B1 self-reproduces byte-identically (fixpoint re-established).
- **Non-goals:** no new chirality-side code — `band`/`bor`/`bxor`/`shl` are already
  complete through `prelude.chiral`, `tal-erase.chiral`, and `mach-x64.chiral`
  (all seven layers). No `bnot`/`rol`/`ror` (residue, §6). No new tests beyond
  the S7 probe; existing `test_e96_bitwise_goldens.py` already covers band.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no CONFORMANCE-MAP row (E96 postdates the map
  snapshot; treat as BUILD). Build-state authority is the live tree, verified
  2026-08-10.

- **Live state (the build-state table from the worked example, confirmed):**

  | Layer | band | bor | bxor | shl |
  |-------|------|-----|------|-----|
  | `prelude.chiral` extern + Op ctor | ✓ | ✓ | ✓ | ✓ |
  | `tal-erase.chiral` op-parse | ✓ | ✓ | ✓ | ✓ |
  | `mach-x64.chiral` op-bytes | ✓ | ✓ | ✓ | ✓ |
  | `mach-x64.chiral` bini-body | ✓ | ✓ | ✓ | ✓ |
  | `native.py` _PRIMS + _STR2OP | **✗** | ✓ | ✓ | ✓ |
  | `optimize.py` prim_sigs | **✗** | ✓ | ✓ | ✓ |

  `bor`/`bxor`/`shl` are through all seven layers. The only gap is `band`
  missing from the Python advisory floor.

- **The copy template — `bor` as the nearest sibling:**

  ```python
  # native.py L63 — band is the only missing entry in _PRIMS
  _PRIMS = {..., "bor", "bxor", "shl"}   # add "band"

  # native.py L68-71 — band is the only missing entry in _STR2OP
  _STR2OP = {..., "bor": "op-bor", "bxor": "op-bxor", "shl": "op-shl"}
  # add: "band": "op-band"

  # optimize.py L705 — band is the only missing entry in prim_sigs
  for name in ("mulhi", "sar", "shr", "bor", "bxor", "shl"):
  # add "band"
  ```

  `band`'s `IMPL_PURE` entry already exists in `impl_pure.py` (~L89):
  `impl("band")(lambda a, b: wrap64(a & b))`. The chirality-side Op ctor
  `(op-band)` and all `case` arms are already present in `prelude.chiral`,
  `tal-erase.chiral`, and `mach-x64.chiral`. This is a three-line Python patch
  plus a coverage-probe file — no chirality compiler changes.

- **S12a note:** Python is advisory. The chirality compiler doesn't link `native.py`
  or `optimize.py`. A missing `band` entry is a test-suite catch, not a compiler
  crash. The Python floor exists for agreement verification — `wrap64` in
  `impl_pure.py` is the shared law that keeps fold/interp/native identical.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | S12a says Python is advisory — does `band` really need to land in `native.py`/`optimize.py`? | **RESOLVED → yes, per S12a itself** | S12a says Python is advisory but the folder/interp agreement law says every floor must agree. `bor`/`bxor`/`shl` already have entries; `band`'s absence is a gap, not a design choice. The chirality compiler doesn't depend on it, but the agreement invariant does. Cost: three lines. |
| 2 | S7 probe: inline build test or permanent file? | **RESOLVED → permanent file in `scaffold/tests/`** | The worked example's open question resolved: a permanent probe file that adds `(op-probe)` to the Op sum with no emitter arm. B1 must REJECT. A throwaway test wastes the work — a permanent probe catches future Op-ctor additions that forget emitter arms. File: `test_e96_s7_probe.chiral` (or similar), checked by a Python test or `test_e96_bitwise_goldens.py`. |
| 3 | Should `band` be backfilled into `_PRIMS`/`_STR2OP` for symmetry? | **RESOLVED → yes, it's the deliverable** | The worked example's §6 lands band in both `native.py` and `optimize.py`. This is the whole point of E96 — close the gap. |
| 4 | Does `band` need a constant-folding arm in `_fold_prim`? | **DEFERRED** (residue §6) | No precedent: `_fold_prim` folds only `+,-,*,/,%`; `sar`/`shr`/`bor`/`bxor`/`shl` are not folded and are correct (unfolded constants emit at runtime). The `prim_sigs` entry at L705 is signatures, not folding. |

No NEEDS-AUTHOR items; `status: specced` (unblocked).

## 4. Change plan (ordered, commit-sized)

### Step 1 — band into native.py `_PRIMS` + `_STR2OP`

- **File:** `scaffold/chirality/native.py`
- **Change:** add `"band"` to `_PRIMS` set at L63; add `"band": "op-band"` to
  `_STR2OP` dict at L68-71. Copy the `"bor"` entry, change the name.
- **Size:** ~XS (two tokens in a set, one key-value pair in a dict).

### Step 2 — band into optimize.py `prim_sigs`

- **File:** `scaffold/chirality/optimize.py`
- **Change:** add `"band"` to the `prim_sigs` registration tuple at L705.
- **Size:** ~XS (one string in a tuple).

### Step 3 — S7 coverage probe

- **File:** new `scaffold/tests/test_e96_s7_probe.chiral` (or add a probe
  assertion to `test_e96_bitwise_goldens.py`).
- **Change:** create a chirality file that:
  1. Adds `(op-probe)` to the `Op` data sum.
  2. Omits `(op-probe)` from every `case` arm in `op-bytes` and `bini-body`.
  3. B1 must REJECT with an exhaustive-match error at compile time.
  The Python test harness asserts the build FAILS — if it passes, the emitter
  has a coverage hole.
- **Size:** ~S (one small chirality file + one Python test assertion).

### Step 4 — fixpoint re-establishment

- **File:** B1 binary (via `./build.sh` in `chirality/`).
- **Change:** re-run the B1 self-compile. The fixpoint size WILL change (the
  tree changed since the last fixpoint measurement). The invariant is
  **generation convergence**: gen-1 output compiled again yields byte-identical
  gen-2 (B1 == B2). Record the new fixpoint size.
- **Size:** ~S (one build cycle, one size comparison).

## 5. Conformance gate

- **Golden behavior:** `band` on representative I64 `a`,`b` (incl. negatives,
  zero, `INT_MIN`, boundary values): `interp(band a b)` == exit code of the
  native ELF, bit-exact. Both register form (`and rax,rcx`) and immediate form
  (`and rax,imm32` + `imm32`-overflow fallback via `mov rcx,imm; and rax,rcx`)
  must agree.

- **Tests:**
  - Existing: `scaffold/tests/test_e96_bitwise_goldens.py` already covers band
    differential goldens (interp vs native ELF).
  - New: S7 coverage probe — B1 REJECTS a build with an `Op` ctor that has no
    emitter arm. If it compiles, STOP and record a coverage-enforcement gap.
  - Fixpoint: B1 self-compiles; gen-1 == gen-2 byte-identical.

- **Green line:** existing test count + 1 (S7 probe assertion). No regression
  in the 698+ test functions.

- **Done when:** `band` is in `_PRIMS`/`_STR2OP`/`prim_sigs`, the S7 probe is
  rejected by B1, the fixpoint converges (gen-1 == gen-2), and all existing
  tests pass.

## 6. Residue & links

- **Deliberately unbuilt:**
  - `bnot` / `rol` / `ror` — remaining bitwise ops; home = a future
    bitwise-completion element. Each is a one-arm copy across the layers.
  - `_fold_prim` arms for bitwise ops — constant-folding (Decision #4); home =
    a later optimizer element. Correctness holds via runtime emit.
  - Non-`rax,rcx` register-pair encodings — the whole Op emitter uses the
    hard-coded `rax,rcx` convention; home = a register-allocation element.
- **Follow-on:** this unblocks SCRIBA S2 (E97 diagnostics) per
  `.planning/SCRIBA-UNBLOCK-MAP.md`.
- **Related:** [[E96-bitwise-ops]]; the `band` precedent (commit `ff5232d`); the
  I64 floor + `wrap64` law shared with the arithmetic ops; S12a (Python-is-
  advisory decision, 2026-08); SCRIBA-UNBLOCK-MAP S1 (carries the S7 coverage
  probe requirement).
