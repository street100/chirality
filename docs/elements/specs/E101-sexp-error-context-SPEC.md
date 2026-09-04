---
element: E101
slug: sexp-error-context
title: Sexp-reader error context — line/column, depth, last-opened-form on failures
kind: BUILD-PROPER
example: examples/E101-sexp-error-context.md
status: audited
updated: 2026-08-09
---

# E101 SPEC — Sexp-reader error context

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 5 steps are executable at HEAD.
> `lib/surface/sexp.chiral:136-154` carries `pos-line`/`pos-col`. Bucket and
> evidence: `records/spec-tier-triage.md`. This file was not rewritten and its
> `status:` was not changed.

> Implementation contract. Bridges the worked example into an executable change plan.

## 1. Deliverable

- **After this runs:** `lib/surface/sexp.chiral` gains `pos-line`, `pos-col`,
  `fmt-pos`, and `i64->str` helpers plus enhanced `read-form`/`read-list` that
  thread depth + last-opened-form and produce location-bearing error messages
  (e.g., `unexpected ) at 45:12 depth=3 (inside case)`). `lib/surface/parse.chiral`
  `load-source` preserves the byte position from sexp errors so B1's stderr
  reports `parse: unexpected ) at 45:12 depth=3` instead of `parse: unexpected )`.
  Existing parse paths produce identical ASTs.
- **Non-goals:**
  - Does **not** change `RR`/`AllR`/`PR`/`LoadR` type shapes — error context is
    embedded in the `msg Str` field only.
  - Does **not** add file-name tracking (the reader has no filename context;
    B1 receives a flat blob).
  - Does **not** enhance surface parse errors (`PR.p-err`) with position —
    that cascade touches every function in `parse.chiral` + `surface.chiral`.
  - Does **not** add a full form-ancestry stack — only the immediate parent.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** BUILD — this is a net-new diagnostic layer over
  the existing E1 reader.
- **Live code:**
  - `lib/surface/sexp.chiral` (202 lines): `read-form`, `read-list`, `read-all`,
    `read-all-str`, `RR`/`AllR` types. The `pos` field in `RR` is a byte offset.
  - `lib/surface/parse.chiral` (869 lines): `load-source` at line 849, calls
    `read-all-str` and wraps sexp errors with `str-cat "parse: " m` (dropping
    the byte position `p`).
  - `lib/surface/surface.chiral`: `PR` type — `(p-err (msg Str))` with no position.
  - `lib/module/loader.chiral`: `LoadR` type — `(ld-err (msg Str))`.
- **True delta:**
  1. New helpers in `sexp.chiral`: `i64->str`, `pos-line`, `pos-col`, `fmt-pos`
  2. Enhanced `read-form`/`read-list` (thread `depth`, `last-form`, `ctx`)
  3. Backward-compatible wrappers preserving the existing API
  4. `load-source` in `parse.chiral` preserves byte position in error messages
  5. Error messages gain: `at L:C depth=N (inside <form>)`

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Change `PR` to carry position? | DEFERRED — too much cascade | Touches every `parse-*` function + their callers + surface.chiral elab. Stay with string-only enhancement at `load-source` gateway. |
| 2 | `i64->str` — new helper or reuse? | RESOLVED — new local helper | Mirror existing `digits->i64` pattern; define `i64->str` as `digits->str` in sexp.chiral. Pure `->` function. |
| 3 | Full form-ancestry stack vs parent-only? | RESOLVED — parent-only for this wave | Full stack requires `reverse` over a `(List Str)` which is a more invasive change. Parent-only captures the most actionable context. |
| 4 | File name in error messages? | DEFERRED — no filename context available | The reader receives `Bytes` (flat blob); B1 has no per-file tracking. Follow-up: E87 (import handler) could thread filenames. |

No NEEDS-AUTHOR items. All decisions resolved.

## 4. Change plan (ordered, commit-sized)

### Step 1 — Add `i64->str` to sexp.chiral
- **Target:** `lib/surface/sexp.chiral` — after `digits->i64` (line 116), before `read-atom`
- **Change:** Add `i64->str` — a structural-recursion-based I64→Str converter
  that handles zero, negative, and positive values. Mirrors `digits->i64` direction.
  Pure `->`. Signature: `(-> I64 Str)`.
- **Size:** ~S (~15 lines)

### Step 2 — Add `pos-line`, `pos-col`, `fmt-pos` to sexp.chiral
- **Target:** `lib/surface/sexp.chiral` — after `i64->str`
- **Change:** Add three pure helpers:
  - `pos-line`: count newlines in `b[0..pos)` via structural recursion
  - `pos-col`: scan backward from `pos` to last newline
  - `fmt-pos`: compose `i64->str` outputs as `"line:col"` string
- **Size:** ~S (~40 lines)

### Step 3 — Enhance `read-form`/`read-list` with depth + last-form
- **Target:** `lib/surface/sexp.chiral` — replace lines 161–187
- **Change:** Add `read-form*` and `read-list*` with extra params `depth I64`,
  `last-form Str`, `ctx (List Str)`. Error messages include `at L:C depth=N`.
  `read-list*` tracks the first element's symbol as `last-form` for context on
  nested errors. Existing `read-form`/`read-list` become thin wrappers calling
  the enhanced versions with default values.
- **Size:** ~M (~60 lines)

### Step 4 — Update `read-all-go` to use enhanced reader
- **Target:** `lib/surface/sexp.chiral` — `read-all-go` (line 190)
- **Change:** `read-all-go` calls `read-form` which now delegates to `read-form*`.
  No structural change needed — the wrapper preserves the API.
- **Size:** ~S (0 lines changed — API compatible)

### Step 5 — Enhance `load-source` in parse.chiral to preserve position
- **Target:** `lib/surface/parse.chiral` — `load-source` (line 849–869)
- **Change:** The `(a-err m p)` branch in `load-source` currently drops `p`.
  Change from `(ld-err (str-cat "parse: " m))` to use `fmt-pos` (imported from
  sexp.chiral) to include the position in the error message.
- **Size:** ~S (~3 lines)

## 5. Conformance gate

- **Golden behavior:** All existing `chirality test` + `chirality test-native` must pass
  unchanged. Error message strings CHANGE but error conditions remain identical.
  Specifically: `unexpected )` → `unexpected ) at L:C`, `unclosed (` →
  `unclosed ( at L:C depth=N inside <form>`, `unexpected end of input` →
  `unexpected end of input at L:C`.
- **Tests to add:** None — existing `test_sexp.py` and `test_parse_chirality.py`
  test the oracle, but error message strings are not part of the differential
  corpus (only AST shape is). The native test-runner (`run-native.sh`) exercises
  B1's parse path implicitly through self-compile.
- **Green line:** 724 → 724 (no new tests; existing corpus passes)
- **Done when:** `chirality test` passes, and B1's stderr shows `unexpected ) at
  LINE:COL` instead of bare `unexpected )`.

## 6. Residue & links

- **Deliberately unbuilt:**
  - `PR` type position field — deferred to a follow-up wave (touches every
    parse function + surface.chiral elab)
  - Full form-ancestry stack — parent-only for now
  - Filename context — requires E87 import handler to thread filenames
  - Surface parse errors with position — `(lam (x ...) body)` stays as-is;
    only sexp-level errors gain location
- **Follow-on:** E87 (import handler) — could later thread filename context
  through the reader for `file:line:col` diagnostics.
- **Related:** [[E01-sexp-reader]] (base reader), [[E97-skip-chain-diagnostics]]
  (related lowering diagnostics work)
