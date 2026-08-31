---
element: E102
slug: sexp-enhancements
title: Sexp-reader follow-up enhancements: per-function paren delta reporting (balance per `def`/`declare` boundary), max nesting depth guard (configurable, prevents arena corruption), form-splitter `read-all-forms` (returns forms with byte offsets for binary-search), token start position in atom-parse errors (byte offset where token began, not just error site)
kind: BUILD-PROPER
example: examples/E102-sexp-enhancements.md
status: audited
updated: 2026-08-09
---

# E102 SPEC — Sexp-reader follow-up enhancements

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/sexp.chiral` gains four additive enhancements
  built on E101's position helpers: (1) `data ParenDelta` + `paren-scan` for
  per-function paren balance reporting, (2) `MAX-DEPTH` constant + `read-form-depth`
  depth guard, (3) `data FormPos` + `data AllFR` + `read-all-forms`/`read-all-forms-str`
  form-splitter with byte offsets, (4) `read-atom-start`/`read-string-start`/`scan-str-start`
  for token-start-position-aware error messages.
  `scaffold/lib/parse.chiral` may optionally use `read-all-forms` in
  `load-source` but this is not required for conformance.
- **Non-goals:** Inline paren counting (the `paren-scan` skeleton detects
  `def`/`declare` boundaries but does not count interior parens within function
  bodies — that requires the form-splitter + byte-range re-reading, deferred to
  a follow-up). Integration of `read-form-depth` into `read-form*`'s call chain
  (max-depth is a separate entry point, not a modification of the existing
  recursive descent). Changing `AllR` or `PR` type shapes. Wiring
  `read-atom-start` through `read-form*` (keep the existing `read-form*` unchanged;
  the new functions stand alone).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** None (E102 postdates the map). Treat as BUILD.
- **Live code:**
  - `lib/sexp.chiral` (271 lines): E1 reader with `Sexp`/`RR`/`AllR` types,
    char helpers (`code`, `u8`, CH-* constants), predicates (`is-trivia`,
    `is-digit-b`, `is-delim`), skip helpers (`skip-comment`, `skip-trivia`),
    atom reader (`read-atom`, `atom-end`, `is-i64-lit`, `digits->i64`),
    string reader (`read-string`, `scan-str`, `scan-str-escape`, `esc-char`),
    E101 position helpers (`pos-line`, `pos-col`, `fmt-pos`),
    E101 enhanced recursive spine (`read-form*`, `read-list*` with depth +
    last-form context), backward-compat wrappers (`read-form`, `read-list`),
    and top-level reader (`read-all`, `read-all-go`, `read-all-str`).
  - `lib/parse.chiral` (869 lines): surface parser + `load-source` gateway.
  - `lib/collections.chiral`: provides `reverse` (used by `read-all-forms-go`).
- **True delta:** Three additive data types (`ParenDelta`, `FormPos`, `AllFR`),
  1 new constant (`MAX-DEPTH`), ~10 new functions
  (`paren-scan`, `paren-delta-report`, `read-form-depth`, `read-all-forms-go`,
  `read-all-forms`, `read-all-forms-str`, `read-atom-start`, `scan-str-start`,
  `scan-str-escape-start`, `read-string-start`). Zero modifications to
  existing functions or types. `AllR`/`RR`/`read-form`/`read-all` unchanged.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled doc (cite it); genuinely novel
design goes to NEEDS-AUTHOR and is surfaced, never answered on the author's behalf.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Should `read-form*` use `read-atom-start` internally? | RESOLVED: NO for this slice | Keep existing `read-form*` unchanged to avoid cascading signature changes. The token-start functions are standalone; integration into `read-form*` is deferred. |
| 2 | Should `MAX-DEPTH` be a parameter or constant? | RESOLVED: constant | `(def MAX-DEPTH I64 200)` — a `def` that can be redefined later if parameterization is needed. Example §6 already decided this. |
| 3 | Should paren delta be inline (during parsing) or post-hoc? | RESOLVED: post-hoc | Post-hoc via `paren-scan` over already-parsed `(List Sexp)`. Keeps `read-all` simple; inline would thread a balance map through every recursive call. The form-splitter provides offsets for byte-range re-reading as a follow-up. |
| 4 | Should `read-all-forms` reuse `AllR` or use a new type? | RESOLVED: new type `AllFR` | `AllR.a-ok` carries `(List Sexp)`; `read-all-forms` produces `(List FormPos)`. A new `AllFR` type prevents the type mismatch. `AllR` stays unchanged for backward compatibility. Example audit already fixed this. |

## 4. Change plan (ordered, commit-sized)

### Step 1 — Add data types for paren delta, form-splitter, and depth guard
- **Target:** `scaffold/lib/sexp.chiral` — after the existing `AllR` definition (line 26), before char helpers (line 28).
- **Change:** Insert `data ParenDelta`, `data FormPos`, `data AllFR`, and the `MAX-DEPTH` constant. These are pure data declarations with no dependencies on rest of file.
- **Size:** ~S (4 data types + 1 constant, ~25 lines)

### Step 2 — Add per-function paren delta scanner
- **Target:** `scaffold/lib/sexp.chiral` — after E101's `read-list` wrapper (line 257), before `read-all-go` (line 259).
- **Change:** Insert `paren-scan` and `paren-delta-report` functions as shown in example §5 Enhancement 1. `paren-scan` uses only `Sexp` constructors (`s-list`, `s-sym`, `cons`, `nil`), `str-eq`, `pair`, which are all already available.
- **Size:** ~M (~50 lines, deeply nested pattern matching)

### Step 3 — Add max nesting depth guard function
- **Target:** `scaffold/lib/sexp.chiral` — after paren delta functions, before `read-all-go`.
- **Change:** Insert `read-form-depth` as shown in example §5 Enhancement 2. Depends on `MAX-DEPTH` (Step 1), `read-form*` (E101), `fmt-pos` (E101), `i64->str` (prelude).
- **Size:** ~S (~10 lines)

### Step 4 — Add form-splitter (read-all-forms)
- **Target:** `scaffold/lib/sexp.chiral` — after depth guard, before `read-all-go`.
- **Change:** Insert `read-all-forms-go`, `read-all-forms`, `read-all-forms-str` as shown in example §5 Enhancement 3. Depends on `FormPos`/`AllFR` (Step 1), `read-form` (existing), `skip-trivia` (existing), `reverse` (collections import already present).
- **Size:** ~S (~20 lines)

### Step 5 — Add token-start-position-aware atom and string readers
- **Target:** `scaffold/lib/sexp.chiral` — after the existing `read-string` (line 192), before `read-form*` (line 197).
- **Change:** Insert `read-atom-start`, `scan-str-start`, `scan-str-escape-start`, `read-string-start` as shown in example §5 Enhancement 4. These stand alone alongside the existing `read-atom`/`read-string` — they do NOT replace them.
- **Size:** ~M (~35 lines, includes scan-str-start and scan-str-escape-start with start parameter)

## 5. Conformance gate

- **Golden behavior:**
  - `paren-delta-report` on a balanced file returns `pd-ok`; on a file with
    `(def foo ... (def bar ...)` (missing close before bar) reports
    `(pd-missing "foo" 1)`.
  - `read-form-depth` at depth 200 returns `r-err` with `"max depth 200 exceeded"`.
    At depth <200, delegates to `read-form*` and returns identical results.
  - `read-all-forms` on valid source returns `(af-ok forms)` where each form
    carries its byte offset. On invalid source, returns `(af-err msg pos)`.
  - `read-atom-start` returns identical AST to `read-atom` for valid input;
    byte-identical `Sexp` values, same next-position.
  - `read-string-start` error message includes the byte offset of the opening
    `"`, not just the error-detection point.
  - `chirality test` passes with 726+ tests green (zero regressions). All existing
    `read-form`/`read-all` paths are untouced.
- **Tests to add:** `test_sexp.py` gains tests for: paren delta on
  balanced+imbalanced input, max-depth rejection at exactly 200, form-splitter
  offset correctness (verify each form's offset matches known positions in test
  strings), token-start error messages include opening position. Python oracle
  `chirality.sexp.read_all` is the differential reference for AST equivalence.
- **Green line:** 726 → ≥ 730; `ledger-lint` clean.
- **Done when:** `chirality test` passes with added test coverage over all four
  enhancements, B1 rebuilds from chirality and produces byte-identical binary
  (fixpoint holds because sexp.chiral is on the self-compile path — E1 reader is
  used by B1 to parse its own input).

## 6. Residue & links

- **Deliberately unbuilt:**
  - Inline paren counting within function bodies (requires re-reading byte
    ranges via form-splitter offsets). Deferred to E103 or follow-up slice.
  - Integration of `read-form-depth` into `read-form*`/`read-list*` call chain
    (currently a standalone entry point). The existing recursive descent is
    untouched.
  - Wiring `read-atom-start` through `read-form*` dispatch (currently
    standalone; `read-form*` still calls `read-atom`, not `read-atom-start`).
    Deferred to avoid cascading signature changes.
  - `FormPos` `end-offset` field (only `offset` currently; byte-length would
    enable direct slice extraction).
- **Follow-on:** E103 (inline paren counting per function), improved `load-source`
  diagnostics using form-splitter offsets for binary-search error isolation.
- **Related:** [[E01-sexp-reader]] (base reader), [[E101-sexp-error-context]]
  (position helpers this builds on).
