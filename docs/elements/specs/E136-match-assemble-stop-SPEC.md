---
element: E136
slug: match-assemble-stop
title: **Match + assemble + stop** (Wave 2, the pure-core remainder): `match-pipeline : (-> Str (List Pipeline) PipelineMatch)` (WHEN keyword overlap → `match-found`/`match-none`/`match-tied`); `assemble-prompt` (an agent's SEES cut + hits → prompt Str); `overflow-guard` (chars/4 vs `num_ctx`, pure arithmetic); `stop-policy : (-> Str I64 Bool)` (single / capped-N / loop-until-dry, swappable per pipeline — no magic constant). All pure `->`, unit-testable without a PTY or a backend. `scaffold/lib/manas/core/{match,assemble,stop}.chiral`
kind: BUILD
example: examples/E136-match-assemble-stop.md
status: audited
updated: 2026-08-15
---

# E136 SPEC — Match + assemble + stop (the pure-core remainder)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** three new pure (`->`) leaf modules exist —
  `scaffold/lib/manas/core/match.chiral` (`match-pipeline : (-> Str (List Pipeline)
  PipelineMatch)`, WHEN keyword-overlap count → `match-found`/`match-none`/
  `match-tied`), `scaffold/lib/manas/core/assemble.chiral` (`assemble-prompt :
  (-> Expert Str (List (Pair Str Str)) (List Str) Str)`, pure prompt string
  building), `scaffold/lib/manas/core/stop.chiral` (`overflow-guard : (-> Str I64
  Bool)` chars/4 ≥ num_ctx, and `stop-policy : (-> Str I64 Bool)` sharpen/example
  loop capped at 3) — B1 compiles all three into one leaf blob that runs a
  behavioral test to exit 0.
- **Non-goals:** the effectful runner that calls all three (E138); the
  worker-`decision` similarity route (richer than keyword overlap); `Hit`→content
  extraction (upstream, effectful); ASCII case-folding; a JSON-driven policy
  registry. Context arrives as `(List Str)` (already-extracted lines), NOT
  `(List Hit)` — the leaf takes no backend/http import.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E136 postdates the map snapshot; treat as
  BUILD (grep-clean: no match/assemble/overflow/stop in chirality today).
- **Live code this composes with (name, do NOT respec):**
  - `scaffold/lib/manas/core/types.chiral` (E133) — `Pipeline` (`pipeline id when
    gate order expert-ids combiner stop yield-desc`), `PipelineMatch`
    (`match-found pipeline matched-when` / `match-none listing` / `match-tied
    tied-ids listing`), `Expert` (`expert id lens sees returns slot tools`),
    `Order`/`StopPolicy` nullary+cap constructors. Imported, never redefined.
  - `scaffold/lib/manas/core/gate.chiral` (E134) — the `str-contains` idiom
    (`(-> Str Str Bool)`, `(<=i 0 (str-find haystack needle))`, arg order
    **haystack needle**). COPIED (not imported — see decision #3).
  - `scaffold/lib/collections.chiral` — `foldl`, `filter`, `find`, `append`,
    `str-join`. `scaffold/lib/prelude.chiral` — `str-cat`, `str-find`, `str-sub`,
    `str-len`, `str-eq`, `=i`, `<i`, `<=i`, `+`, `/`.
- **True delta:** three new files + one behavioral test sample
  (`scaffold/tests/samples/e136_core.chiral`). No existing file changes.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | The exact overlap scoring rule (example §6 "first-cut heuristic to be settled in the SPEC") | **RESOLVED** | Split the request on `" "`, keep words of `str-len ≥ 4` (`sig-words`), count how many occur as substrings of each pipeline's WHEN text (`count-hits`, integer). Highest count wins. Mirrors the example §5 and the METIS-PORT-SPEC §1 "pure keyword overlap — no floats" intent. Case-sensitive over authored WHEN text (same call as E134 decision #1). |
| 2 | Should `match-tied` further tie-break? (example §6) | **DEFERRED to E138** (the runner) | The `PipelineMatch` sum already carries `tied-ids` + `listing`; the caller decides. E138 is minted (INDEX/catalog) and consumes all three functions — it owns any secondary tie-break policy. No phantom dep. |
| 3 | `str-contains`: import string-utils vs copy from gate? | **RESOLVED** | COPY the gate.chiral body (arg order `haystack needle`). string-utils's `str-contains` is the reverse order (`needle s`) AND importing it double-defines the name in a combined leaf blob. Copy into `match.chiral` as `str-contains`; in `stop.chiral` name the copy `str-has` so the two leaves don't collide as duplicate top-level defs when resolved into one blob. |
| 4 | Accumulate lists with `map-list` or `foldl`/`append`? | **RESOLVED** | `foldl`/`filter`/`append` only — on branch e106 `map-list` does not lower in an isolated leaf blob (E134/E135 decision, KNOWN COMPILER FLAG). |
| 5 | `str-split` for `sig-words` — import string-utils or inline? | **RESOLVED** | Inline a local `split-go` (structural recursion on the shrinking suffix via `str-find`/`str-sub`) in `match.chiral`. Avoids importing string-utils (which drags in its reverse-order `str-contains`, decision #3). |
| 6 | The stop cap (3) and token divisor (4) — magic constants? | **RESOLVED** | Both live INSIDE the swappable policy function, exactly as METIS-PORT-SPEC §7 (`(<i iteration 3)`) and §1 (chars/4). A different pipeline supplies `stop-deep`/`stop-quick` — the cap is a function property, not a global. Not exported as knobs in E136. |

No NEEDS-AUTHOR items. §4 is unblocked.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `scaffold/lib/manas/core/match.chiral`
- **Target:** new file — `str-contains` (copied, gate order), `pipeline-id`,
  `pipeline-when`, `imax`, `split-go`/`sig-words`, `count-hits`, `listing-of`,
  `ids-of`, `match-pipeline`.
- **Change:** adapt example §5 verbatim. `match-pipeline` folds `imax` of
  `count-hits` over all pipelines for `best`; `best = 0` → `match-none listing`;
  else `filter` the pipelines whose count equals `best` (winners) and case:
  single winner → `match-found w (pipeline-when w)`, ≥2 → `match-tied (ids-of
  winners) listing`. Imports: prelude, collections, prapanca/core/types.
- **Size:** ~M

### Step 2 — `scaffold/lib/manas/core/assemble.chiral`
- **Target:** new file — `pair-line`, `render-extra`, `assemble-prompt`.
- **Change:** adapt example §5. `assemble-prompt` cases the `Expert`, builds the
  prompt by nested `str-cat` of labeled sections (Lens / You see / Document /
  Extra / Context / Return); `render-extra` folds the `(List (Pair Str Str))` to
  `k: v` lines joined by `\n`; context `(List Str)` joined by `\n`. Imports:
  prelude, collections, prapanca/core/types.
- **Size:** ~S

### Step 3 — `scaffold/lib/manas/core/stop.chiral`
- **Target:** new file — `str-has` (copied, named to avoid the blob collision),
  `overflow-guard`, `stop-policy`.
- **Change:** `overflow-guard` = `(<=i num-ctx (/ (str-len prompt) 4))`;
  `stop-policy` = `(str-has expert-id "sharpen") or (str-has expert-id "example")`
  → `(<i iteration 3)`, else `false` (METIS-PORT-SPEC §7). Imports: prelude only
  (str-find/str-len/<=i/<i/or/cond/`/`).
- **Size:** ~S

### Step 4 — `scaffold/tests/samples/e136_core.chiral`
- **Target:** new behavioral test; entry `(def compile-main (=> I64 I64) …)`.
- **Change:** build real `Pipeline` values (doc-refine + research WHEN texts from
  `orchestration/processes.md`) and assert (all `and`-combined, exit 0 iff all
  true): `match-pipeline "refine this doc against reality and sharpen it" ps` →
  `match-found` doc-refine; `match-pipeline "asdfqwer zxcv" ps` → `match-none`;
  a two-identical-WHEN tie → `match-tied`; `overflow-guard <~6400-char> 1000` →
  true and `overflow-guard "short" 1000` → false; `stop-policy "anchor-sharpen" 1`
  → true, `"anchor-sharpen" 3` → false, `"claim-vs-source" 1` → false;
  `assemble-prompt <expert> "the doc" nil (cons "ctx" nil)` contains "the doc"
  (via the blob's `str-contains`). No `print`/ports import — pure exit code.
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** the processes.md WHEN texts route correctly (a doc-refine
  request → `match-found` doc-refine; gibberish → `match-none`; equal top scores
  → `match-tied`); `stop-policy` reproduces the Python cap-of-3 (§7);
  `overflow-guard` reproduces `len//4 >= num_ctx` (§1); `assemble-prompt` embeds
  the document. Purity is structural (the `->` arrow is compiler-checked — no
  `=>`, no float, no backend import).
- **Tests to add:** `scaffold/tests/samples/e136_core.chiral` (native floor, via
  the `chirality_blob` leaf-blob path — B1 compiles the 3 modules + the test entry).
- **Green line:** the sample compiles and runs to exit 0 under B1; no regression
  to the 709 test functions; ledger-lint clean.
- **Done when:** `B1 < <blob> > e136.elf` exits 0 AND `./e136.elf` exits 0, with
  every assertion above exercised (negative controls flip the exit to 1).

## 6. Residue & links

- **Deliberately unbuilt:** worker-`decision` similarity route (home: a later E,
  richer than keyword overlap — not minted, not deferred-to here); `Hit`→content
  extraction (home: the effectful retrieve step, upstream of E136); ASCII
  case-folding (home: shared with E134 residue — needs single-byte Bytes
  reconstruction); swappable `stop-deep`/`stop-quick` registry (home: E138, the
  runner that selects a pipeline's policy).
- **Follow-on:** E138 (the runner) calls `match-pipeline`, `assemble-prompt`,
  `overflow-guard`, `stop-policy` in the effectful loop.
- **Related:** [[E136-match-assemble-stop]] · [[E133-manas-core-types]]
  (types imported) · [[E134-gate]] (`str-contains` idiom; who fires vs which
  pipeline) · [[E135-bind]] (binds the fired slots).
