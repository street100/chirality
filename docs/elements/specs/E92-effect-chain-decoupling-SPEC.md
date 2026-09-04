---
element: E92
slug: effect-chain-decoupling
title: Effect chain decoupling: inline `try-dispatch` helper before `command-loop-inner` in `command-loop.chiral`, forward-declare `command-loop-inner`, replace `(false ...)` beep arm with `try-dispatch` call
kind: BUILD-PROPER
example: examples/E92-effect-chain-decoupling.md
status: audited
updated: 2026-08-08
---

# E92 SPEC — Effect chain decoupling: inline `try-dispatch` helper before `command-loop-inner` in `command-loop.chiral`, forward-declare `command-loop-inner`, replace `(false ...)` beep arm with `try-dispatch` call

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 3 steps are executable at HEAD.
> `try-dispatch` is live; `prog/scriba/command-loop.chiral:481,687`. Bucket
> and evidence: `records/spec-tier-triage.md`. This file was not rewritten and
> its `status:` was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `prog/scriba/command-loop.chiral` has `try-dispatch` inlined as a helper defined before `command-loop-inner`, with a forward `declare` for `command-loop-inner`, and the `(false ...)` arm of the quit check calls `try-dispatch` instead of beeping + recursing directly.
- **Non-goals:** Fixing B1's lowering pass (`lower.chiral`) to handle mutual recursion through effects. The helper is wired but B1 still rejects the blob — that's a compiler-level change tracked separately. Also not: making `try-dispatch` a separate importable module (a standalone `dispatch.chiral` exists but B1 can't fuse the chain either way).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** No CONFORMANCE-MAP rows reference E92 (postdates the map snapshot). The change composes with built shards in `command-loop.chiral` — `command-loop`, `command-loop-inner`, `render-puffer`, `read-key-sequence`, `lookup-keymap`.
- **Live code:**
  - `scaffold/lib/scriba/command-loop.chiral:84–97` — `command-loop` entry point (unchanged by E92)
  - `scaffold/lib/scriba/command-loop.chiral:130–160` — `command-loop-inner` (changed: `(false ...)` arm now calls `try-dispatch` at line 160)
  - `scaffold/lib/scriba/command-loop.chiral:99–113` — `try-dispatch` helper (new, defined before `command-loop-inner`)
  - `scaffold/lib/scriba/dispatch.chiral:1–145` — standalone `try-dispatch` module (imported at command-loop.chiral line 22, but its `try-dispatch` definition conflicts with the inlined version — both define `(def try-dispatch ...)`, creating a duplicate if B1 ever processes the blob. The import was left in place during the inline refactor.)
- **True delta:** The inlined `try-dispatch` helper + forward declare + wire into `(false ...)` arm — all applied. The `(import "dispatch")` at line 22 of command-loop.chiral pre-dates E92 and was not removed when the helper was inlined. This creates a latent duplicate-definition conflict if `dispatch.chiral` is resolved into the same blob.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Inline `try-dispatch` in command-loop.chiral vs separate importable module? | RESOLVED — inlined | Both approaches hit the same B1 limit (mutual recursion through effects). Inlining avoids an extra file and import chain; it's simpler and matches the worked example's guidance from chirality-dev-patterns `references/b1-effect-chain-workaround.md`. A standalone `dispatch.chiral` exists at `scaffold/lib/scriba/dispatch.chiral` with its own `try-dispatch` definition but the `(import "dispatch")` at command-loop.chiral line 22 pre-dates the inline refactor and was not removed — this creates a latent duplicate-definition conflict. The import should be removed to clean up, or the inlined version replaced by the module import. |
| 2 | Should the forward `declare` include `Keymap` parameter or use `default-keymap` directly? | RESOLVED — remove `Keymap` | B1 rejects `(=> Keymap (Puffer Str) ...)` type signatures — the `Keymap` + `(Puffer Str)` combination kills labels per chirality-dev-patterns §"B1 Keymap + (Puffer Str) type combination kills labels." The `try-dispatch` helper calls `command-loop-inner` with `default-keymap` directly. `command-loop-inner`'s own signature still carries `Keymap` for internal use but `try-dispatch` doesn't need it. |
| 3 | B1 mutual recursion through effects — fix now or defer? | NEEDS-AUTHOR | The helper is defined before `command-loop-inner` with a forward declare, but `try-dispatch` calls `command-loop-inner` which calls `try-dispatch` — this is mutual recursion through effectful calls. B1's lowering pass (`lower.chiral` `compile-fn` → `st-fns` → `sig-assoc`) sees both functions referencing each other's signatures in a cycle, and the erase step can't fuse the mutual effect chain. The scriba blob still fails with "no emitted label." This requires compiler changes to `lower.chiral` — specifically multi-pass handling for effectful mutual recursion. Not resolvable at the scriba level. |

## 4. Change plan (ordered, commit-sized)

### Step 1 — Forward-declare `command-loop-inner` for the helper
- **Target:** `prog/scriba/command-loop.chiral` — after `command-loop` definition, before `try-dispatch`
- **Change:** Add `(declare command-loop-inner (=> Keymap (Puffer Str) (Pair I64 I64) Rendering (List (Pair Str RendererFn)) (List ScribaOp) Unit))` so `try-dispatch` can reference it before the full `def`.
- **Size:** ~S (1 line)

### Step 2 — Inline `try-dispatch` helper
- **Target:** `scaffold/lib/scriba/command-loop.chiral` — between the forward declare and `command-loop-inner` definition
- **Change:** Define `try-dispatch` as an effectful helper that takes `(puf dims rendering renderers ops opname)`, calls `lookup-scribaop`, and on match executes `op-fn` then recurses into `command-loop-inner`. On no match, beep and recurse. Uses `default-keymap` directly (Keymap removed from signature to avoid B1 type-combination bug).
- **Size:** ~M (~15 lines)

### Step 3 — Wire `try-dispatch` into `command-loop-inner`
- **Target:** `prog/scriba/command-loop.chiral` — the `(false ...)` arm of the quit check in `command-loop-inner`
- **Change:** Replace the inline beep+recurse in the `(false ...)` arm with a call to `(try-dispatch puf dims old-rendering renderers ops opname)`.
- **Size:** ~S (1 line changed)

## 5. Conformance gate

- **Golden behavior:** The `(false ...)` arm of the quit check in `command-loop-inner` delegates to `try-dispatch` instead of beeping + recursing directly. `try-dispatch` looks up the op name in the ops registry and either executes it (updating the puffer) or beeps for unregistered ops, then recurses back into `command-loop-inner`. Observable output: key sequences mapped to ops trigger their registered functions; unmapped sequences produce a beep. The change is purely structural (refactoring the dispatch path) — no new behavior beyond what the existing op registry already defines.
- **Tests to add:** No new tests — the behavioral change is wiring an existing dispatch mechanism. The `test_e2e.py` suite covers the command loop; once B1 accepts the blob, existing tests verify the loop still works. A differential test comparing `command-loop-inner` output before/after the wiring would validate equivalence.
- **Green line:** 708 → 708 (no new test functions; the change is blocked from passing B1 so no test baseline shift). If B1 is later fixed: green line stays ≥708, ledger-lint clean.
- **Done when:** `command-loop.chiral` compiles through B1 and existing e2e tests pass with the wired `try-dispatch` path. **Currently blocked:** B1 rejects the blob with "no emitted label" due to mutual recursion through effects (`command-loop-inner` ↔ `try-dispatch`). The code changes are applied and syntactically correct per the Python checker, but the native compiler cannot lower the mutual effect chain.

## 6. Residue & links

- **Deliberately unbuilt:**
  - B1 lowering pass multi-pass handling for effectful mutual recursion — this is a compiler-level change (`lower.chiral`). Not scoped to E92. Track in a follow-on element or docket.
  - Standalone `dispatch.chiral` module — exists as reference code at `scaffold/lib/scriba/dispatch.chiral` and is imported at command-loop.chiral line 22. The import pre-dates E92 and was not removed when the helper was inlined, creating a latent duplicate-definition conflict (both define `try-dispatch`). Could be activated as the canonical definition if the inlined version is removed, or the import should be removed to clean up.
- **Follow-on:** Compiler change to `lower.chiral` to handle effectful mutual recursion (the `st-fns` → `sig-assoc` cycle). This unblocks E92 and any future effect-chain decoupling patterns.
- **Related:** [[E92-effect-chain-decoupling]]
