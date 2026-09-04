---
element: E88
slug: mark-region
title: Mark + region system: mark-ring, mark (saved cursor position), region (text between point and mark), set-mark, exchange-point-and-mark, kill-region, copy-region — wires the existing kill-ring into real region operations
kind: BUILD-PROPER
example: examples/E88-mark-region.md
status: audited
updated: 2026-08-08
---

# E88 SPEC — Mark + region system

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 3 steps are executable at HEAD.
> `prog/scriba/mark-region.chiral` exists. Bucket and evidence:
> `records/spec-tier-triage.md`. This file was not rewritten and its `status:`
> was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** A new file `prog/scriba/mark-region.chiral` exists
  (~80 lines) defining `Mark`, `MarkRing` types and pure `->` functions:
  `set-mark`, `exchange-point-and-mark`, `mark-ring-push`, `mark-ring-pop`,
  `zipper-offset`, `region-between`, `kill-region`, `copy-region`. The file
  compiles through B1 when blob'd with its dependencies (`prelude`, `str-edit`).
- **Non-goals:**
  - Command-loop integration (wire mark/kill-ring into `command-loop-inner`
    state threading) — blocked on B1's dispatch effect-chain threshold
    (scriba slice 2 `chirality-needs` row 1).
  - Mark-ring integration with the Puffer type (mark follows the zipper, not
    the puffer's linear handle).
  - Transient mark mode / region highlighting — depends on the render
    pipeline (scriba slice 4).
  - Active/inactive mark distinction — always-active design per the example.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** (none — E88 postdates the map snapshot; treat
  as BUILD: pure new construction, nothing to conform to or extend.)
- **Live code this composes with:**
  - `prog/scriba/str-edit.chiral` (699 lines) — `TextZipper`, `LineCtx`,
    `zipper-to-text`, `advance-by`, `text-zipper-from-str`,
    `str-delete-forward`, `str-len`, `str-sub`, `str-cat`, `str-eq`.
  - `prog/scriba/kill-ring.chiral` (74 lines) — `KillRing`,
    `kill-ring-push`, `kill-ring-top`, `kill-ring-empty?` (integration target;
    not imported by mark-region, used by command loop).
  - `prelude` — `I64`, `Str`, `Bool`, `Unit`, `List`, `Maybe`, `Pair`, `=i`,
    `<i`, `+`, `-`, `min`, `and`, `let`, `case`, `lam`.
- **True delta:**
  - **New types:** `Mark` (1-ctor wrapper around `TextZipper Str`),
    `MarkRing` (2-field LIFO ring).
  - **New pure functions (13):** `mark-ring-new`, `mark-ring-push`,
    `mark-ring-pop`, `mark-ring-trim`, `mark-take`, `set-mark`,
    `exchange-point-and-mark`, `zipper-offset`, `sum-line-lengths`,
    `region-between`, `kill-region`, `copy-region`, `zipper-at-offset`.
  - **Changed files:** none — this is a new file, no existing file modified.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Should `zipper-offset` be cached in TextZipper? | RESOLVED: defer | Correctness first. `zipper-offset` is O(n) per call — acceptable for interactive use on human-scale buffers. Cache if profiling shows it matters; the pure functional design makes caching a transparent optimization. |
| 2 | How does mark ring integrate with command-loop-inner state threading? | RESOLVED: add `Mark` and `MarkRing` and `KillRing` parameters | Follows the existing pattern: `command-loop-inner` already threads `Keymap`, `(Puffer Str)`, `(Pair I64 I64)`, renderers, and ops. The mark/MarkRing/KillRing are additional pure-data parameters in the same chain. The type signature grows to `(=> Keymap (Puffer Str) (Pair I64 I64) (List (Pair Str RendererFn)) (List ScribaOp) Mark MarkRing KillRing Unit)`. Actual wiring deferred to the dispatch-unblocked integration pass. |
| 3 | Should `region-between` handle zippers from different buffers? | RESOLVED: documented invariant | The type system does not distinguish zipper provenance (both are `TextZipper Str`). The invariant "zippers must be from the same buffer" is documented in the function preamble. This is not a type-level guarantee — it's a runtime contract, like most zipper invariants in functional editors. |

## 4. Change plan (ordered, commit-sized)

### Step 1 — `mark-region.chiral`: types + pure ops
- **Target:** `prog/scriba/mark-region.chiral` — new file.
- **Change:** Write the full file: `(import "prelude")`, `(import "str-edit")`,
  `Mark` and `MarkRing` data types, then all pure functions in the order they
  appear in the example §5 snippet. Adapt naming and types from the example
  exactly; add `(total)` pragmas where applicable. The file is self-contained
  beyond its two imports.
- **Size:** ~80 lines (M).

### Step 2 — B1 compilation verification
- **Target:** verify through B1: `chirality_blob scaffold/lib scriba/mark-region |
  bin/chirality-bin`.
- **Change:** If B1 rejects any construct (effect chain threshold on a pure
  `->` function should be fine — pure functions don't cross the membrane),
  simplify the offending function body. The expected hazard is `region-between`
  having too many nested `case`/`let` expressions for B1's compilation limit;
  if so, split helpers out.
- **Size:** iterative fix loop, ~S.
- 2026-09-04: the 2026-08-31 migration moved the tree out of scaffold/. The pre-migration paths kept here name no live directory.

### Step 3 — (deferred) command-loop wiring
- **Target:** `prog/scriba/command-loop.chiral`,
  `prog/scriba/scriba-main.prog`.
- **Change:** Add `Mark`, `MarkRing`, `KillRing` parameters to
  `command-loop-inner` and `command-loop`. Thread them through the recursive
  call. Initialize `none` mark, empty `mark-ring`, empty `kill-ring` in
  `compile-main`. **BLOCKED** on B1 dispatch (scriba slice `chirality-needs` row 1)
  — the ops that call `set-mark`/`kill-region` need the dispatch module to
  route keybindings to op functions, which requires B1's effect chain
  threshold raised.
- **Size:** ~30 lines (S), deferred.

## 5. Conformance gate

- **Golden behavior:** The region text between any two `TextZipper Str`
  positions must be byte-identical to the substring extracted from the full
  reconstructed buffer text (via `zipper-to-text`). Specifically:
  - `region-between a b` → `(region-text, start, end)` where
    `region-text == str-sub(zipper-to-text(a), start, end-start)`.
  - `kill-region mk pt` → `(killed, new-z)` where `killed` matches
    `region-between`'s text and `zipper-to-text(new-z)` equals
    `zipper-to-text(pt)` with the region removed.
  - `exchange-point-and-mark mk pt` → `(mk', pt')` where `mk'` wraps the
    original `pt` and `pt'` equals the mark's zipper.
- **Tests to add:**
  - `scaffold/tests/test_mark_region.py` — pure function differential: set up
    a `TextZipper Str` fixture (via Python `str-edit` equivalents), exercise
    each function on known inputs, assert output byte-equality against a
    Python reference implementation of the same logic.
  - Fixture: a 5-line buffer "abc\ndef\nghi\njkl\nmno" with marks at various
    positions. Test: region-between returns correct substring; kill-region
    deletes correct range; exchange-point-and-mark swaps positions correctly;
    mark-ring-push/pop round-trip.
- **Green line:** 708 (current test count: 708 test functions across 74 files)
  → ≥ 713. One new test file with ≥ 5 test functions.
- **Done when:** `mark-region.chiral` compiles through B1 and all new tests
  pass with byte-identical differential output.

## 6. Residue & links

- **Deliberately unbuilt:**
  - Command-loop state threading (Mark/MarkRing/KillRing in
    `command-loop-inner`) — DEFERRED to B1 dispatch fix (scriba slice 2
    `chirality-needs` row 1).
  - Region highlighting (transient mark mode) — DEFERRED to render pipeline
    (scriba slice 4, not yet catalogued).
  - `zipper-offset` caching optimization — DEFERRED indefinitely (measured
    before optimized).
  - Multi-buffer mark rings (per-buffer rings like Emacs) — DEFERRED to
    scriba window-tree wiring (scriba slice 8).
- **Follow-on:** The kill-ring can now receive region kills once the dispatch
  module routes `kill-region` op calls through the command loop. Undo tree
  (scriba slice 3) can record kill-region as atomic edits.
- **Related:** [[E88-mark-region]],
  `prog/scriba/kill-ring.chiral`,
  `prog/scriba/str-edit.chiral`.
