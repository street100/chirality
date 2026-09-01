---
element: E94
slug: form-type-capacity
title: B1 form/type capacity: raise or remove hard limit on forms/data types in `parse.chiral`/`loader.chiral` so scriba blob compiles with full linkage
kind: BUILD-PROPER
example: examples/E94-form-type-capacity.md
status: audited
updated: 2026-08-08
---

# E94 SPEC — B1 form/type capacity: raise or remove hard limit on forms/data types in `parse.chiral`/`loader.chiral` so scriba blob compiles with full linkage

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** A new file `scaffold/lib/load-batch.chiral` exists providing
  `load-source-batched` — a capacity-token-bounded alternative to `load-source`
  that processes forms in configurable-sized batches rather than one unbounded
  recursive pass. `scaffold/lib/compile-front.chiral` line 249 is patched to call
  `load-source-batched` instead of `load-source`. The scriba blob compiled through
  B1 with all 5 linkage files (`crossing-wraps.chiral`, `sys-check.chiral`,
  `target-linux.chiral`, `sys-tal.chiral`, `sys-linkage.chiral`) appended produces
  a runnable ELF that passes the 5 gate tests in
  `scaffold/lib/scriba/scriba-test-b1.chiral`.

- **Non-goals:**
  - Does not fix the 2-type-param B1 limitation (render.chiral:21, keymap.chiral:74)
  - Does not support multi-file loads with real `import` resolution — targets
    only the flattened blob path
  - Does not implement per-phase cap sub-accounting — uses a unified step counter
  - Does not implement Bytes-buffer-based batching — V1 uses string re-serialization
  - Does not profile the exact B1 native stack ceiling (diagnostic step only)

## 2. Baseline (what already exists)

- **Conformance-map verdict:** BUILD. E94 postdates the map snapshot; no existing
  conformance rows name it. Treat as a greenfield build on the existing
  loader/compiler-front stack.

- **Live code (already built, this change composes with):**
  - `scaffold/lib/compile-front.chiral` — `compile-front` (line 247–251): the
    front entry calling `load-source src` at line 249, then `bridge-sig` which
    runs closconv + specialize-singletons + peel. Also: `bridge-sig` (235),
    `peel-globals` (169), `term->ncore` (72), `datas->n` (197).
  - `scaffold/lib/parse.chiral` — `load-source` (line 849–869): three-phase
    pipeline (porttypes → data group → rest); `run-forms` (840–845): linear
    recursive form processor; `load-form` (line ~800): dispatches
    def/declare/data/extern/import. Also: `SrcSt`, `StepR`, `base-senv`,
    `collect-porttype`, `collect-data`, `keep-rest`, `load-forms`.
  - `scaffold/lib/loader.chiral` — `LoadR` (ld-ok / ld-err), `Sig` operations
    (`sig-add-global`, `sig-add-data`, `sig-add-prim`, `sig-add-atom`,
    `sig-add-linear-data`, `empty-sig`), `load-def`, `load-declare`,
    `load-finish`, `load-extern`, `load-atom`, `load-data`, `load-data-group`,
    `load-items`, `load-unit`, `ChkR`, `core->term`, `core-list`.
  - `scaffold/chirality/surface.py` — `Elab.load_file`, `Elab.load_str` (Python
    baseline with no form-count limits, dict-based Sig, 1 GB thread stack).
    Serves as the design reference for the chirality port's intended behavior.

- **The current limit mechanism:** `run-forms` (parse.chiral:841–845) recurses
  linearly over the `(List Sexp)` — each form is one recursive call. Similarly,
  `load-forms` in loader.chiral recurses over the item list. `elab-all-data` in
  surface.chiral recurses over data declarations. None has an explicit counter;
  the limit is the native stack depth available to recursive B1-compiled
  functions. The scriba blob (~38 types + linkage) exceeds that depth; the
  compiler's own ~62-type blob passes.

- **True delta:** New file `scaffold/lib/load-batch.chiral` (~120 lines:
  `Cap`, `BatchR`, `load-forms-capped`, `load-source-capped`,
  `load-source-batched`, `load-source-loop`, `sig-merge`, `serialize-forms`).
  One-line patch in `scaffold/lib/compile-front.chiral`: `load-source src` →
  `load-source-batched src`. No other files touched.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled doc (cite it); genuinely novel
design goes to NEEDS-AUTHOR and is surfaced, never answered on the author's behalf.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | What is the actual native stack ceiling in B1's codegen? Need a small reproducer: a chirality program with N recursive calls that finds the exact overflow point. | NEEDS-AUTHOR | The SPEC authors can build a diagnostic harness (a chirality program that recurses N times and reports the last successful N), but the ceiling value is an empirical property of the current B1 native codegen. The implementation run will measure it and document the safe cap value. |
| 2 | Is the limit really in the recursive loader functions (`run-forms`/`load-forms`), or in the sexp reader (`read-list` → `read-form` mutual recursion for deeply nested tal-ir instruction sequences)? The known `(lam (x ...) body)` error suggests a parse corruption, not a clean overflow. | NEEDS-AUTHOR | The implementation run must first isolate the bottleneck: run the sexp reader alone on the scriba+linkage blob to verify it parses correctly, then run the loader phases incrementally to identify which recursive function overflows and at what form count. The parse corruption symptom may indicate a separate arena-exhaustion issue. |
| 3 | Should batching use string re-serialization or pass the `Bytes` buffer + cursor? | RESOLVED — string re-serialization for V1 | The example §5 explicitly designs `serialize-forms` as a `(List Sexp) → Str` function, and the `load-source-loop` calls it to convert pending forms back to source for the next batch. This is simpler and reuses the existing `read-all-str` entry point. Bytes-buffer batching is a future optimization (see §6). |
| 4 | Does the 2-type-param B1 limitation (render.chiral:21, keymap.chiral:74) interact with the form-count limit? | DEFERRED to separate element | The example §5 states: "The 2-type-param B1 limitation is a separate issue — E94 does not fix it." If investigation reveals a shared root cause (e.g., both from codegen stack depth), a follow-on element should address the union. For now, E94 targets form-count capacity only. |
| 5 | What is the right per-batch cap value? | NEEDS-AUTHOR (empirical) | Must be found during implementation. Start at the compiler blob's form count (~200), double until scriba+linkage passes, then add a 2× safety margin. Document the chosen value and the measurement methodology in `load-batch.chiral` comments. The example's 10000 is a placeholder. |
| 6 | Should `Cap` and `BatchR` live in `load-batch.chiral` or be promoted to `kernel.chiral`? | RESOLVED — live in `load-batch.chiral` | The example §5 defines them locally. They are loader-internal plumbing, not kernel concepts. A future slice could promote `Cap` if it becomes a general pattern (see §6). |

## 4. Change plan (ordered, commit-sized)

### Step 1 — Diagnose the ceiling and bottleneck (investigation)
- **Target:** Build a small reproducer and run targeted diagnostics.
- **Change:** Create a chirality program with N recursive calls to `load-forms`-style
  linear list processing, compile through B1, find the overflow N. Separately,
  run the sexp reader (`read-all-str`) on the scriba+linkage blob to verify it
  parses without corruption. Run each phase of `load-source` (porttype-only,
  data-group-only, rest-only) incrementally to isolate the bottleneck function.
- **Size:** M (no permanent code change; writes diagnostic findings to a
  `.planning/E94-diagnostic.md` note).

### Step 2 — Create `scaffold/lib/load-batch.chiral` (new file)
- **Target:** New file `scaffold/lib/load-batch.chiral` — capacity types and
  capped loader functions.
- **Change:** Port the example §5 chirality code, fleshing out stubs:
  - `(data Cap () (cap-remaining (steps I64)) (cap-exhausted))` — capacity token
  - `(data BatchR () (batch-done (sig Sig)) (batch-more (sig Sig) (pending (List Sexp)) (steps I64)) (batch-err (msg Str)))` — partial-load result
  - `load-forms-capped` — wraps `load-form` with cap decrement per step
  - `load-source-capped` — three-phase pipeline (porttypes → data group → rest)
    with capped final loop; reuses existing `run-forms`, `elab-all-data`,
    `load-data-group` for the first two phases (unchanged)
  - `load-source-batched` — public entry: calls `load-source-loop` with initial
    `cap-remaining N` and `empty-sig`
  - `load-source-loop` — iterates `load-source-capped` with fresh caps,
    accumulating Sig via `sig-merge`, re-serializing pending forms
  - `sig-merge` — append lists (`globals ++ globals`, `datas ++ datas`, etc.)
    with first-definition-wins duplicate rejection
  - `serialize-forms` — `(List Sexp) → Str` using existing `pretty.chiral` or a
    simple sexp printer
- **Size:** L (~120 lines of chirality)

### Step 3 — Patch `scaffold/lib/compile-front.chiral`
- **Target:** `scaffold/lib/compile-front.chiral` — `compile-front` (line 249)
- **Change:** Replace `(load-source src)` with `(load-source-batched src)`.
  Add `(import "load-batch")` at the top import block (after line 18).
  No other lines change. Both return `LoadR`, so the `case` arm below (line 250)
  is unchanged.
- **Size:** S (2 lines changed, 1 line added)

### Step 4 — Tune and verify
- **Target:** `scaffold/lib/load-batch.chiral` — the cap value in `load-source-batched`
- **Change:** Set the per-batch cap to the empirically measured safe value from
  Step 1 (target: scriba+linkage passes), with a 2× safety margin. Document the
  measurement in a comment.
- **Size:** S (one constant change + comment)

### Step 5 — Rebuild B1 and run conformance gates
- **Target:** `scaffold/build/B1` (native compiler binary)
- **Change:** Rebuild B1 with the patched loader path. Run scriba blob build
  with all 5 linkage files. Run 708 compiler tests. Run self-compile fixpoint.
- **Size:** S (build + test commands)

## 5. Conformance gate

- **Golden behavior:**
  1. `python3 bin/scriba-build.py` (or equivalent) with all 5 linkage files
     appended to the scriba blob produces a runnable ELF — no `(lam (x ...) body)`
     parse corruption, no stack overflow, no `LoadR` error.
  2. The resulting scriba ELF passes the 5 gate tests defined in
     `scaffold/lib/scriba/scriba-test-b1.chiral`: `test1-find`, `test2-alist-get`,
     `test3-two-type`, `test4-command-loop`, `test5-full-editor`.
  3. Self-compile fixpoint holds: the B1 built with `load-source-batched`
     compiles its own frontend (parse.chiral + loader.chiral + compile-front.chiral)
     and produces a bit-identical or behaviorally equivalent B1 binary.

- **Tests to add:**
  - `scaffold/tests/test_batch_loader.py`: test `load-source-batched` with
    blobs of varying sizes (1 form, N forms, 2N forms) against the Python
    baseline's `load_str` for Sig equivalence.
  - Extend `scaffold/tests/test_loader_chirality.py` with a "large blob" case that
    exceeds the unbounded-recursion ceiling but passes with batching.
  - Extend `scaffold/tests/test_compile_run_chirality.py` with a scriba+linkage
    end-to-end gate.

- **Green line:** 708 → ≥ 711 test functions (708 existing + 3 new batch-loader
  tests). All existing tests continue to pass (no regression).

- **Done when:** The scriba blob with all 5 linkage files compiles through B1,
  the resulting ELF passes all 5 scriba gate tests, all 708 compiler tests pass,
  and self-compile produces an equivalent B1.

## 6. Residue & links

- **Deliberately unbuilt:**
  - Per-phase cap sub-accounting (separate caps for porttype, data-group, and
    rest phases) — the example §5 sketch shows a unified counter; V1 ships that.
    (Future E# or V2 slice.)
  - Bytes-buffer-based batching (avoiding string re-serialization overhead) —
    V1 uses `serialize-forms` → `Str`; a future slice can add a `Bytes`-cursor
    path. (Future E#.)
  - `Cap` as a general kernel concept — currently local to `load-batch.chiral`.
    If batching proves broadly useful (e.g., for compile-emit batching), promote
    to `kernel.chiral`. (Future E#.)
  - 2-type-param B1 limitation (render.chiral:21, keymap.chiral:74) — explicitly
    scoped out of E94. If investigation in Step 1 reveals a shared codegen root
    cause, file a follow-on element. (Future E#.)
  - Non-blob multi-file `import` resolution — E94 targets the flattened blob
    path only. (Future E# or existing multi-file element.)

- **Follow-on:** Unblocks the scriba editor's native compile path. Enables the
  self-hosting reach expansion planned for E95+.

- **Related:** [[E94-form-type-capacity]], [[E92-effect-chain-decoupling]]
  (E92 §5 references "B1 limits #1"), [[E89-arena-init]] (§5: "linearity on
  compound data fields is a B1 limitation").
