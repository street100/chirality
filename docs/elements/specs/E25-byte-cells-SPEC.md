---
element: E25
slug: byte-cells
title: Byte cells `[len][payload]` (bytearray reference is a crutch)
kind: REPLACE-CRUTCH
example: examples/E25-byte-cells.md
status: audited
updated: 2026-08-01
---

# E25 SPEC — the linear byte-builder over the built cell floor

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 2 steps are executable at HEAD.
> `lib/lowering/tal/bytes.chiral` is the cell builder. Bucket and evidence:
> `records/spec-tier-triage.md`. This file was not rewritten and its `status:`
> was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the **linear builder discipline** exists in chirality source
  — `BBuf`/`bnew`/`bput`/`bfreeze`/`copy-into` and a builder-backed `bcat` in a
  new `scaffold/lib/bytes.chiral` — making write-after-freeze, builder reuse,
  builder leak, out-of-range init (bare-var `(< n)` bound), and non-byte
  payloads (`(< 256)`) **checker rejections**, with `bcat` byte-for-byte equal
  to the existing prelude `bcat`.
- **Non-goals:** the **cell floor itself** — BUILT/CONFORMS and not respecced
  (native arena cells execute, `nb-*` prims preserve-checked,
  `lib/bytes-tal.chiral` exists; the tal.py `bytearray` stays as the pinned
  differential oracle — the map row's own framing). The **expression-bound
  refined faces** (`bget` at `(< (blen b))`, `bslice`'s `(<= (blen b))`) →
  **edge 3 / E41** (outside E9's fragment — the same gate as E22's cursor;
  annotated in the example §5). Codecs, realloc/growth, arena reclamation →
  the example's omissions, homed below.
- 2026-09-04: the 2026-08-31 migration moved the tree out of scaffold/. The pre-migration paths kept here name no live directory.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** **CONFORMS, S** — "Real path built +
  self-hosted; nb-* prims preserve-checked at load, arena cells execute;
  bytearray is golden oracle … deliberate differential oracle, not unmet
  crutch." **The element's original crutch-replacement obligation is met**;
  this SPEC scopes only the example's residual — the typed layer above the
  cells, which the map does not owe (forward design, declared as such).
- **Live code (do NOT respec):**
  - The tal byte ops + ABI: `("bnew"/"bget"/"bput"/"blen", …)`, "a Bytes value
    is one word: a pointer to a `[len][payload]` cell" (`tal.py:28`); `bput` is
    an initialization write by *convention* (`tal.py:21` — a comment, which is
    exactly what the builder lifts into a type).
  - `lib/bytes-tal.chiral` (the floor library) + the native arena cells (E21/
    E25); the prelude byte externs `blen`/`bget`/`bslice`/`bcat`/`brepeat`
    (`prelude.chiral:47–52`) — the behavior oracle for the builder-backed ops.
  - **E9's fragment:** bare-var symbolic bounds landed (2026-07-06) — `bput`'s
    `(refine I64 (>= 0) (< n))` and byte-range `(< 256)` discharge today;
    expression bounds do not (edge 3).
  - **E21 (audited):** the `ArenaTok` linear-witness pattern — the same
    shape `BBuf` uses (a linear value carrying a raw B-side pointer).
- **True delta:** one new surface lib (the builder) + tests. No floor change,
  no `tal.py` change, no new tal instructions.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **Do the dependent refined faces ship?** (example §6, resolved-split at the audit) | **RESOLVED → no; edge-3-gated design target.** | `(< (blen b))` / `(<= (blen b))` are *expression* bounds — outside E9's decidable fragment (const + bare-var only). They are annotated as gated design in the example and deferred to **edge 3 / E41**, beside E22's cursor (one gate, two customers — when expression bounds land, both elements' refined faces unlock). The builder half has no such dependency. |
| 2 | **Does tal-level `bput` stay an untyped init-write instruction?** (example §6) | **RESOLVED → yes.** | The floor re-checks *types*, not linearity — the tal checker types `bput : Bytes × I64 × I64` and the interpreter enforces bounds dynamically; the linearity discipline is upper-level judgment (E5/E8's home). The builder is the **C-bridge** carrying that discipline; the floor instruction is its B-side referent, unchanged. Matches the example's own "likely yes" with the reason made precise. |
| 3 | **Where the builder lands** — extend `bytes-tal.chiral`, extend prelude, or a new lib? | **RESOLVED → new `lib/bytes.chiral`.** | `bytes-tal.chiral` is the *floor* library (TFn/tal tier — wrong altitude for surface `data`+`declare`); prelude is the minimal A floor every file imports (a builder discipline is opt-in, not core). A surface lib beside `mem-linear.chiral` matches the discipline-gets-its-own-named-home pattern the memory bank records for E22's linear lib. |
| 4 | **`[len]` header word size** (example §6). | **RESOLVED → one I64 word, as assumed.** | Fixed by the built ABI — the cells the loader/arena already lay out (`native.py` `alloc_bytes`: `size = 8 + ((len+7)&~7)`, an 8-byte little-endian length header; symbol-anchored, not line-anchored — `native.py` is under active concurrent edit). Not a free knob; recorded as the pinned fact. |
| 5 | **Builder ↔ region story** (example §6's reclamation hook). | **DEFERRED → E21/E22.** | The linear `BBuf` is indeed the natural hook (same witness shape as E21's `ArenaTok`); reclamation/regions are E22's subject — blocked there on the same edge-3 gate. Named, not built. |

No NEEDS-AUTHOR: the layer is declared **optional forward design** (the map
owes nothing), scoped because the example survives as its rationale; all calls
resolve from the fragment limits, the built ABI, or named homes.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `lib/bytes.chiral`: the builder
- **Target:** `scaffold/lib/bytes.chiral` (NEW FILE).
- **Change:** per the audited example §5 (the ungated half): `(data BBuf ((0 n
  I64)) (bbuf (ptr I64)))`; `bnew : (-> (n (refine I64 (>= 0))) (BBuf n))`;
  `bput : (-> (0 n I64) (1 b (BBuf n)) (refine I64 (>= 0) (< n)) (refine I64
  (>= 0) (< 256)) (BBuf n))`; `bfreeze : (-> (0 n I64) (1 b (BBuf n)) Bytes)`;
  `copy-into` (structural recursion on the remaining-count measure); a
  builder-backed `bcat` (the audited let-chain binding the erased `n` once).
  Bindings for `bnew`/`bput`/`bfreeze` route to the existing floor ops.
- **Size:** ~S.
- 2026-09-04: pre-migration scaffold/ path.

### Step 2 — the gate tests
- **Target:** `tests/test_memory.py` or `test_string_utils.py` (behavior) +
  `tests/test_kernel.py` (rejections).
- **Change:** (a) builder `bcat` ≡ prelude `bcat` byte-for-byte on sampled
  pairs (incl. empty); (b) **rejections**: write-after-freeze (using `b` after
  `bfreeze`), builder double-use, builder leak (unconsumed `1`-binder),
  literal out-of-range init index vs `(< n)`, literal `256` payload vs
  `(< 256)` — each a checker error; (c) `bnew`-zero-fill + `bput`-then-freeze
  round-trip on the RT floor.
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** the builder changes no byte semantics — its `bcat`
  agrees byte-for-byte with the prelude oracle; the discipline claims (§4 of
  the example) become checker rejections.
- **Tests:** Step 2; existing byte/tal suites stay green (no floor change).
- **Green line:** 360 → ≥ 362; ledger-lint clean.
- **Done when:** builder-`bcat` matches the oracle, and all five rejection
  cases fail the *checker* (not the runtime).

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **Expression-bound refined faces** (`bget`/`bslice` dependent bounds) →
    **edge 3 / E41**, beside E22's cursor (decision #1).
  - **Two-index `(BBuf n filled)`** initialized-prefix tracking → the
    example's stricter knob, nobody's yet (would also want edge-3 arithmetic).
  - **Codecs** (`str->bytes`/`bytes->str`) → layered above, existing externs.
  - **Arena reclamation / region hook** → **E21/E22** (decision #5).
  - **Realloc/growth** → cells are fixed-size at `bnew`, by design.
- **Follow-on:** none blocking. Gives E23 (FFI) a typed builder for inbound
  buffers; a second refined-API precedent beside E24's `div`.
- **Related:** [[E25-byte-cells]], [[E24-i64-arith]] (the refined-face
  precedent + `<>`/fragment facts), [[E22-regions]] (the shared edge-3 gate),
  [[E21-arena]] (the linear-witness shape), [[E09-refinement]] (the fragment),
  [[E23]] (FFI buffers), [[banks/memory]] (Shard 6 — the built cells + the
  oracle framing).
