---
element: E97
slug: skip-chain-diagnostics
title: B1 lowering skip-chain diagnostics: accumulate `er-skip` reasons with blamed callee in `lower-defs` (compile-back.chiral:211-226); on missing entry label, report the drop chain root-first to stderr; resolve `native-prim?` (lower.chiral:143, apparently uncalled) to one documented authority or delete
kind: BUILD-PROPER
example: examples/E97-skip-chain-diagnostics.md
status: audited
updated: 2026-08-09
---

# E97 SPEC — B1 lowering skip-chain diagnostics

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** when the native compiler drops the entry def because its
  transitive callee cone fails to lower, `compile-all` returns a `ca-err` whose
  message is the **root-first blame chain** (a typed `SkReason` sum walked from
  the entry to the leaf), e.g.
  `compile-main <- command-loop <- termios-set-raw: extern does not lower: band`,
  replacing today's provenance-free `no emitted label for entry compile-main`.
  `native-prim?` (lower.chiral:143, dead) is deleted; `op-parse`
  (tal-erase.chiral:90) is the sole lowerable-membership authority.
- **Non-goals:** does not change *what* lowers (no op newly lowers or stops
  lowering); does not touch the successful emit path (bytes stay identical);
  does not introduce a new `Console`/stderr port (reuses the existing `trace`
  crossing); does not build multi-branch (tree) blame, ledger dedup, or a
  linear `SkRec` — all §6 residue.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E97 postdates the map snapshot; treat as
  **BUILD**. This is a new diagnostic layered over the existing (built) lowering
  pipeline; no shard here is respec'd.
- **Live code this composes with (do NOT re-build):**
  - `compile-back.chiral` — `lower-defs` (:211-226) accumulates emitted `TFn`s in
    `acc`, then at the `nil` case runs `filter-erasable` (:206) → `prune-fix`
    (:193) → `erase-list` (:140). `back-program` (:232) is its sole caller.
    `tfn-names` (:182), `tfn-nm` (:180), `block-calls` (:174), `cb-all-in` (:184)
    already exist and are reused for the walk.
  - `compile-all.chiral` — `compile-all` (:8, `=> Str Str CAllR`) calls
    `back-program` then `emit-elf`; `compile-main` (:34) already writes the error
    message to stderr via `(trace m)` (:39). **This is the crossing the example's
    `report-drop`/`Console` cap refracts onto — no new cap is needed.**
  - `tal-erase.chiral` — `op-parse` (:90) is **the** extern-lowerability boundary;
    `prim2lib` (:121) + the inline `bget`/`blen`/`str-len` cases in `erase-prim`
    (:135) complete the lowerable-prim set; `erase-fn` (:253) returns `xf-err`
    when a fn contains a non-lowering op.
  - `compile-emit.chiral` — `emit-elf` (:149) is where the entry-label lookup
    *actually* fails today: `offs-lookup offs entry` → `none` →
    `elf-err "no emitted label for entry <entry>"` (:156). Untouched by this
    change (see delta).
- **True delta (deliverable minus baseline) — and where the example simplified:**
  1. The example modelled ONE skip site (`le-skip` in `lower-defs`). In the live
     code the drop has **three** origins, all currently discarding their reason:
     (a) `lower-defs` `le-skip` arm (:225) — body compile failed; (b)
     `filter-erasable` (:206) drops a fn whose `erase-fn` returns `xf-err` — **the
     leaf extern rejection**; (c) `prune-fix`/`prune-pass` (:186-197) drop a caller
     whose callee is now absent — **the callee-blame cascade**. The ledger must
     capture all three.
  2. The example placed the entry gate + report inside `compile-back`, but the
     live "no emitted label" signal is produced in `emit-elf`
     (compile-emit.chiral:156). This SPEC moves the **detection** upstream: check
     entry-presence on the kept `TFn` set inside `lower-defs`' `nil` case (names
     via `tfn-names`), and on absence emit the blame chain as a `br-err` — so
     `emit-elf` stays byte-identical and its :156 arm becomes an unreachable
     belt-and-suspenders fallback (left in place).
  3. `back-program` gains an `entry` parameter (its one caller `compile-all`
     already holds `"compile-main"`); everything downstream is contained to these
     two files plus the deletion in `lower.chiral`.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | `native-prim?` (lower.chiral:143) — wire as authority or delete? | **RESOLVED — DELETE** | Dead — `grep -rn native-prim? scaffold/` returns a single hit: the def itself at `lower.chiral:143` (no call sites; `scaffold/build/blob.chiral` does not exist yet, so there is no compiled copy to worry about — it will simply not appear when blob is first generated from source). `op-parse` (tal-erase.chiral:90) is already **the** membership boundary; a second predicate is the drift hazard the example §2.3 names. Example §2.3 + task directive both say delete. |
| 2 | The `compile-back.chiral:204` comment ("the native-prim subset") — stale? | **RESOLVED — refresh phrasing only** | Auditor note: the comment already names *erase* as the authority (correct); it is NOT stale in substance. The only cleanup is the dangling "native-prim subset" wording after the delete → reword to "the prim subset (op-parse / prim2lib are the authority)". No logic change. |
| 3 | Leaf phrasing / how `sk-extern` names the op | **RESOLVED** | `sk-extern` carries the offending op *token* (matches example `sk-extern (op Str)`). Obtain it via `first-nonlowering-op`, a thin reader over the **existing** authorities (`op-parse` ∪ `prim2lib` ∪ {`bget`,`blen`,`str-len`}) — not a rival membership list. `leaf-label name op` → `"<name>: extern does not lower: <op>"`, giving the golden shape exactly. |
| 4 | Where does the report cross to stderr? | **RESOLVED — reuse `trace`** | `compile-main` (compile-all.chiral:39) already `(trace m)`s the error message. The blame chain becomes the `ca-err`/`br-err` *message string*; the existing crossing writes it. The example's `eprint`/`Console` cap is refracted onto this built crossing — no new port. |
| 5 | Report all skipped callee branches (tree) or the first (line)? | **RESOLVED — first (single line)**; tree DEFERRED | Golden is a single root-first line; matches the example draft. Multi-branch tree → §6 residue (a `blame-tree` follow-on), no home yet. |
| 6 | Dedup the ledger so fuel can become a structural measure? | **DEFERRED — §6 residue** | Fuel (`4096`, or the program def-count) is total and sufficient for the gate; dedup+structural-measure is an optimization, not required for the diagnostic. Totality holds via the fuel decrement. |
| 7 | Force-consumption: make `SkRec` linear so a lost reason is a type error? | **DEFERRED — §6 residue (knob)** | The reason reaches the gate by construction (threaded through the return sum); linearity is an extra guarantee, out of scope. Example §4 lists it as a knob. |
| 8 | Thread the ledger out through `BR`/`CAllR` for external consumers? | **RESOLVED — keep internal** | Detection+report are fully contained in `back-program`; enriching `BR` for outside consumers is unmotivated now. Noted as §6 residue if a future tool wants structured skips. |

No decision blocks §4. All RESOLVED or DEFERRED to §6.

## 4. Change plan (ordered, commit-sized)

### Step 1 — Delete dead `native-prim?`; refresh the erase-authority comment
- **Target:** `scaffold/lib/lower.chiral` — remove `native-prim?` (:143-151) and its
  `(declare …)` if present. `scaffold/lib/compile-back.chiral` — reword the :204
  comment tail "the native-prim subset" → "the prim subset (op-parse / prim2lib
  are the authority)".
- **Change:** pure deletion + comment edit. `op-parse` becomes the sole live
  authority (decisions #1, #2). Do NOT hand-edit `scaffold/build/blob.chiral` — it
  regenerates from source.
- **Size:** ~S

### Step 2 — Diagnostics data + pure blame walk
- **Target:** `scaffold/lib/compile-back.chiral` (top-of-file data section; a
  separate `compile-diag.chiral` is optional but adds a co-load edge — prefer
  in-file per example §6 "can sit there").
- **Change:** add
  `(data SkReason () (sk-extern (op Str)) (sk-callee (name Str)))`,
  `(data SkRec () (mk-skrec (def-name Str) (why SkReason)))`; and pure helpers:
  `find-skip (List SkRec) Str -> (Maybe SkRec)`, `has-name? (List Str) Str -> Bool`
  (reuse `lits-mem` :88), `leaf-label Str Str -> Str` (`"<name>: extern does not
  lower: <op>"`, via `str-cat`), `blame-chain (List SkRec) Str I64 -> (List Str)`
  (adapt example §5: `find-skip` → `none`⇒chain tip, `sk-extern`⇒`leaf-label` tip,
  `sk-callee`⇒`cons name (blame-chain … (- fuel 1))`; fuel-total), and
  `join-arrows (List Str) -> Str` (`" <- "` join via `str-cat`).
- **Size:** ~M

### Step 3 — Make the three skip sites *record* their reason
- **Target:** `scaffold/lib/compile-back.chiral`.
- **Change:**
  - `filter-erasable` (:206) → return `(Pair (List TFn) (List SkRec))`: on
    `xf-err`, record `(mk-skrec (tfn-nm f) (sk-extern <op>))` where `<op>` =
    `first-nonlowering-op f` (new helper reading `op-parse`∪`prim2lib`∪
    {`bget`,`blen`,`str-len`} over `block-calls`/instr ops; the first op none of
    them accept). Kept-list identical to today (byte-invariant).
  - `prune-pass`/`prune-fix` (:186-197) → also thread `(List SkRec)`: when a
    caller is dropped (`cb-all-in` false), record `(mk-skrec (tfn-nm f)
    (sk-callee <first-missing-callee>))` (first call in `block-calls` not in
    `avail`). Kept-list identical to today.
  - `lower-defs` `le-skip` arm (:225) → accumulate the body-compile skip as
    `(mk-skrec name (sk-extern <reason-or-op>))` into a threaded ledger param
    (replaces the discarded `er`).
- **Size:** ~L (the bulk of the work; three functions change return type, one
  caller each, all inside this file).

### Step 4 — Entry gate + report in `lower-defs`/`back-program`; thread `entry`
- **Target:** `scaffold/lib/compile-back.chiral` (`lower-defs` `nil` case,
  `back-program` :232) and `scaffold/lib/compile-all.chiral` (`back-program` call
  :13).
- **Change:** `back-program` and `lower-defs` gain an `entry Str` param. In
  `lower-defs`' `nil` case, after computing the kept `TFn` set (unchanged) and the
  aggregated `(List SkRec)`, check `has-name? (tfn-names kept) entry`:
  - **present** → `erase-list … kept` exactly as today (**byte-identical**);
  - **absent** → `br-err (join-arrows (blame-chain skips entry <fuel>))`
    (`<fuel>` = `4096` or the def count; decision #6).
  `compile-all` (:13) passes `entry`. `compile-main` (:39) already `(trace m)`s
  the resulting `ca-err` message — the chain lands on stderr with no further edit.
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** a synthetic program whose entry `compile-main` transitively
  calls a def using an op `op-parse` rejects (a "band-less-emitter" repro, since
  `band` is normally lowerable per tal-erase.chiral:101 — the repro forces a leaf
  rejection) produces, on stderr, before the nonzero exit:
  `compile-main <- command-loop <- termios-set-raw: extern does not lower: band`
  (or the equivalent synthetic op/def names), replacing the bare
  `no emitted label for entry compile-main`.
- **Tests to add** (Python harness driving the native/interp floors, alongside
  `test_lower_chirality.py` / `test_compile_run_chirality.py` / `test_tal_erase_chirality.py`):
  1. **blame-chain golden** — feed the synthetic skip-cone source; assert the
     `ca-err`/stderr string equals the root-first chain above. Compares the chirality
     `compile-all` result against the expected string (interp floor sufficient;
     native floor if cheap).
  2. **byte-identity of success** — compile a known-good program pre- and
     post-change (or against the committed `blob`/golden ELF); assert
     **byte-identical** output. This is the fixpoint gate — diagnostics must not
     perturb the emit path.
  3. **`native-prim?` absent** — grep asserts `native-prim?` no longer appears in
     `scaffold/lib/` source (blob regen excepted); `op-parse` is the only
     membership predicate.
- **Green line:** 708 test functions → ≥ 711 (three added); existing suite stays
  green.
- **Done when:** the synthetic drop prints the root-first blame chain, a
  successful self-compile is byte-identical pre/post, and `native-prim?` is gone
  with `op-parse` as sole authority.

## 6. Residue & links

- **Deliberately unbuilt (home named):**
  - **Multi-branch (tree) blame** when a def calls several skipped callees — a
    `blame-tree` follow-on; no home yet (decision #5).
  - **Ledger dedup → structural measure** replacing the fuel bound — an
    optimization on `blame-chain` (decision #6); no home yet.
  - **Linear `SkRec`** to make a lost reason a type error — a knob (decision #7);
    would land in the diagnostics data def.
  - **Structured skips out through `BR`/`CAllR`** for external tooling — deferred
    until a consumer exists (decision #8).
- **Follow-on:** unblocks clearer failures for the scriba/self-wield bring-up
  (the blocker this diagnoses); complements [[E69-effectful-lowering]] /
  [[E70-op-sum-emit]] (the lowering-reach cluster).
- **Related:** [[E97-skip-chain-diagnostics]] · docs/pattern-boundary-sums.md
  (the `SkReason` closed-sum directive this exemplifies) ·
  [[E69-effectful-lowering]] [[E70-op-sum-emit]].
