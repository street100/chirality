---
element: E93
slug: lowering-multi-pass
title: B1 lowering pass multi-pass: pre-scan all function signatures into `ce-fns` before the per-function lowering loop in `lower-defs` (`compile-back.chiral:211-226`), so mutually recursive effectful calls resolve without forward-reference failures
kind: BUILD-PROPER
example: examples/E93-lowering-multi-pass.md
status: audited
updated: 2026-08-08
---

# E93 SPEC — B1 lowering pass multi-pass: pre-scan all function signatures into `ce-fns` before the per-function lowering loop in `lower-defs` (`compile-back.chiral:211-226`), so mutually recursive effectful calls resolve without forward-reference failures

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a single clarifying comment edit in
  `scaffold/lib/compile-back.chiral` at `back-program` (line 232-236) documents
  the invariant that `(def-sigs defs)` is the COMPLETE pre-scanned signature
  table, passed through unchanged to every `CEnv` inside `lower-defs`. No code
  changes — the pre-scan already lives at `def-sigs` (line 74-77) and is already
  routed through `back-program` (line 236). E93 is verification + documentation
  of an existing working pattern, not a from-scratch build.
- **Non-goals:** cannot change `def-sigs` itself (it already correctly maps over
  every `NDef` eagerly), cannot alter the `lower-defs` loop structure, cannot
  add higher-order call support (function pointers, closures — E70's domain),
  cannot address the `lc-global` partial-application skip in `lower.chiral`
  (separate limitation, surface defs are always nullary).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** BUILD — E93 postdates the conformance map
  snapshot. The map carries no E93 rows but the Python oracle encodes the
  same two-pass pattern (`lower.py.lower_all`, lines 464-547) that the chirality
  pre-scan reproduces. This is a documentation/verification change on an
  already-built feature.
- **Live code — pre-scan collector:** `scaffold/lib/compile-back.chiral:74-77`
  — `def-sigs` maps over all `NDef` forms eagerly, structural recursion over
  the definition list, returns `(List (Pair Str TalSig))` with one pair per
  def `(name, (talsig param-types return-type))`. Pure, total, no bailout.
- **Live code — routing site:** `scaffold/lib/compile-back.chiral:232-236`
  — `back-program` passes `(def-sigs defs)` as the third argument to
  `lower-defs`. This is the COMPLETE table — not incremental, no append
  inside the loop.
- **Live code — consumer:** `scaffold/lib/compile-back.chiral:218` (inside
  `lower-defs`) — `(cenv prims fnsigs datas lits)` builds each per-def `CEnv`
  with the same `fnsigs` list. Every `compile-fn` invocation sees the complete
  table. `scaffold/lib/lower.chiral:169-170` — `sig-assoc` does a linear scan
  over `st-fns` (extracted from `CEnv`) and resolves any named call target
  regardless of definition order.
- **Conformance oracle:** `scaffold/chirality/lower.py:464-547` — `lower_all` runs
  a "sig pre-pass" (lines 464-504) that iterates `sig.global_defs`, installs
  every eligible def's `TalSig` into `env_tal.fn_sigs`, then runs the "body
  pass" (lines 506-547) with all signatures pre-installed. Same semantic:
  signatures collected eagerly, bodies lowered with complete table.
- **True delta:** one comment edit at `compile-back.chiral:232-236` — clarify
  that `(def-sigs defs)` is the pre-scan invariant and that `lower-defs`
  passes the same table through unchanged. Everything else is existing
  infrastructure.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled doc (cite it); genuinely novel
design goes to NEEDS-AUTHOR and is surfaced, never answered on the author's behalf.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Pre-scan approach: collect all signatures eagerly before any body compilation | RESOLVED | Already implemented at `compile-back.chiral:232-236` — `(def-sigs defs)` is the complete table passed to `lower-defs`. No incremental accumulator. Python oracle `lower.py.lower_all:464-504` confirms the same two-pass pattern. |
| 2 | Does `def-sigs` need to include outlined extra functions from `compile-fn`? | RESOLVED — no | Outlined functions (`le-ok main extra`) are anonymous continuations, never called by name from other defs. They don't need entries in the forward-declaration table. If future passes add named outlined helpers, `def-sigs` grows then. No action now. |
| 3 | `lc-global` reference path in `lower.chiral` hits `er-skip` for non-nullary refs | RESOLVED — separate concern | This is a pre-existing limitation of `lc-global` partial-application handling. B1 surface defs are always nullary (partial application stays upper), so this doesn't bite. E70 owns the general call-reach problem. E93 only ensures FIRST-ORDER NAMED calls resolve. |
| 4 | Interplay between `declare`/`def` forward-declaration and the pre-scan — does the pre-scan duplicate what `declare` already provides? | RESOLVED — transparent | The pre-scan works on `NDef` forms after parse/kernel, not on `declare` annotations. `declare` gives the type checker forward knowledge; `def-sigs` gives the LOWERER forward knowledge. They're independent passes at different pipeline stages — `declare` enables type checking of mutual recursion, `def-sigs` enables lowering of mutual recursion. No conflict, no duplication. |

## 4. Change plan (ordered, commit-sized)

### Step 1 — Document the pre-scan invariant in `back-program`
- **Target:** `scaffold/lib/compile-back.chiral` — `back-program` body, lines 232-236
- **Change:** Replace the existing comment block above `back-program` with a
  precise invariant doc. The current comment reads "THE BACK ENTRY: the whole
  program (every lowerable NDef) + the data env -> br-ok (List NFn) / br-err
  msg. Reconstructs the lower inputs per def, compiles each to typed SSA under
  a program-wide CEnv, then erases every emitted TFn to the neutral NFns the
  emit image consumes." — extend it to note that `(def-sigs defs)` is the
  complete pre-scanned table, the invariant that `lower-defs` passes it through
  unchanged to every `CEnv`, and that this is what enables mutual recursion
  (every `compile-fn` call sees all signatures regardless of definition order).
  The code itself (`(def-sigs defs)` on line 236) is unchanged.
- **Size:** ~S (comment-only, zero code changes)

## 5. Conformance gate

- **Golden behavior:** a chirality program with mutual recursion (A calls B, B
  calls A) lowers through B1 without skipped defs. The emitted binary contains
  labels for both A and B, runs to completion without missing-label crashes.
  Specifically: `scriba/root` blob through `bin/chirality-bin` produces a binary
  where `command-loop-inner` ↔ `try-dispatch` mutual recursion resolves cleanly.
- **Tests to add:** run the scriba blob (`source bin/chirality-resolve.sh &&
  chirality_blob scaffold/lib scriba/root > blob.chiral && bin/chirality-bin < blob.chiral`)
  through B1 and verify zero `le-skip` results for defs with mutual recursion.
  Differential test: the Python oracle `lower.py.lower_all` and the chirality
  `back-program` must agree on which defs lower vs skip when given the same
  `NDef` list. Both floors converge.
- **Green line:** test count unchanged (no new test file, scriba blob is
  integration-level). The gate is: scriba blob compiles, existing test suite
  passes (`chirality test`), no regressions.
- **Done when:** the comment edit lands, scriba blob compiles through B1 without
  forward-reference failures, and `chirality test` passes with the same test count
  as before.

## 6. Residue & links

- **Deliberately unbuilt:** none. The pre-scan is already in place; E93 is
  verification + documentation of an existing pattern. No code changes beyond
  the clarifying comment. No new features, no new types, no new passes.
- **Follow-on:** none directly unblocked by E93 — it's a documentation
  closure on a working feature. E70 (effectful-call reach) and E16 (lowering
  eligibility partition) are separate concerns that compose with the pre-scan
  but don't depend on E93's completion.
- **Related:** [[E93-lowering-multi-pass]] — this element. [[E70]] —
  effectful-call reach in the lowering partition (effect rows crossing `=>`).
  [[E16]] — lowering eligibility partition (decides which defs lower at all).
