---
element: E11
slug: totality-checker
title: Totality: structural + numeric-measure termination (`check_termination`)
kind: SELF-HOST
example: examples/E11-totality-checker.md
status: audited
updated: 2026-08-01
---

# E11 SPEC — Totality: structural + numeric-measure termination (`check_termination`)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new `scaffold/lib/totality.chiral` carrying the
  **single-function termination classifier** in chirality source — the `Term`/`Arm`/
  `SizeTok`/`Bound`/`Verdict` data and a pure, total `check-termination
  (-> Str Term Verdict)` that walks the finite `Term` tree by structural
  recursion and returns `(total)` / `(not-total reason)` reproducing the verdicts
  of `scaffold/chirality/data.py`'s `_totality_reason` (`:847`): accepts structural
  descent on a case-bound field, accepts a safe numeric measure (constant/±1 step
  toward a guard-established bound), **rejects** a bound that touches the
  two's-complement wrap point, and rejects a self-reference used as a value.
- **Non-goals (residue → §6):**
  - **The enforce-by-default flip.** The conformance map's *other* E11 facet
    (EXTEND — "Termination ENFORCED, not just classified; flip `require_total`
    default ON") is a **different deliverable**, explicitly **GATED on E47+E50**
    (else it regresses lexicographic/mutual/non-unit loops). This SPEC ports the
    **classifier** the example scopes; it does not change any enforcement default.
  - **Mutual / lexicographic termination** — the multi-`def` size-change-graph
    checker is **E50** (built in Python: `data.py` `_check_recgroup:683`,
    `_edge_delta:624`, `_measured_gid:607`); its self-host is E50's, not E11's.
    E11 ports the single-function walk only (the example punts mutual recursion).
  - **The full LJB size-change condition** (idempotent-decreasing transitive
    closure) — OURS does the uniform-decreasing-position special case; the full
    graph is E50's deferred residue.
  - Does **not** delete or wire-in `data.py`'s checker; `_totality_reason` stays
    the bootstrap gate **and** the differential oracle. Does **not** touch the
    kernel (totality rides the `def_hooks` seam, `data.py:32`).

## 2. Baseline (what already exists)

- **Conformance-map verdict — two facets, and this SPEC takes the first:**
  - The **self-host port** (this SPEC): the catalog row is `SELF-HOST`, the
    example is `reviewed`; the classifier is *built and sound* in Python
    (`data.py`), so this is a faithful transcription, not a reshape.
  - The **enforce-flip** facet: `Totality: structural + numeric-measure | EXTEND
    · M · E11 | Payload owed = flip enforcement default; GATED on E47+E50 proving
    more measures first (else regresses …)` — deferred (§1 non-goal, §6).
- **Live code this composes with (do NOT respec):**
  - `scaffold/chirality/data.py` — the golden oracle. `check_termination` (`:573`)
    records the verdict + escalates under `require_total`; `_totality_reason`
    (`:847`) is the single-function walk this ports, with its inner `walk`
    (`:864`), `_num_delta` (`:725`, the constant-step detector), `_guard_bound`
    (`:760`, guard→constant window), `_meet` (`:805`), `_num_dec_ok` (`:823`, the
    **wraparound-excluding** numeric-decrease test), `_term_spine` (`:978`). The
    `I64_MAX`/`I64_MIN` wrap constants live here.
  - `scaffold/chirality/data.py` **E50 machinery** — `_check_recgroup` (`:683`),
    `_edge_delta` (`:624`), `_measured_gid` (`:607`), `_measure_list` (`:617`),
    `_eq_cycle` (`:656`): the mutual/lexicographic checker. **Out of E11's port
    scope** (E50 owns its self-host); named so the port does not respec it.
  - `scaffold/chirality/surface.py` — `verify_profiles` (`:817`): the caller that
    escalates a `not-total` verdict when a profile carries `(total)` /
    `require_total`. The port returns a `Verdict` value; **escalation stays
    here** (errors-as-values; the checker does not decide policy).
  - The mutual-data support the example's `Term`/`Arm` needs
    (`surface.py:_scan_data_groups`, `data.py:check_data_group:472`) — **built
    2026-08-01** (element **E79**), so the `Term`↔`Arm` mutual `data` block the
    example uses elaborates today. Prelude floor (`prelude.chiral`): `List`/`Str`/
    `I64`/`Bool`/`Maybe`; comparisons `=i <i <=i` only.
- **True delta = one new library file's classifier.** The `data`+`case`
  structural-recursion idiom is established; E11's *new* content is the `Term`/
  `Arm`/`SizeTok`/`Bound`/`Verdict` shapes, the foetus per-call decreasing-set
  collection + uniform intersection, and the numeric branch **carrying the I64
  wraparound-exclusion proof in I64 arithmetic** (the chirality-specific obligation
  finding §2.4). The `Sizes`/`Bounds`/`Calls`/`DecSet` working types are opaque
  stubs in the example; the port gives them a minimal concrete representation
  (decision #3).

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled source (cited); DEFERRED to a named
home; genuinely novel design → NEEDS-AUTHOR, surfaced never answered.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **Deliverable boundary** — is E11 the self-host *port of the classifier* (example) or the *enforce-by-default flip* (map EXTEND)? | **RESOLVED — the port; flip deferred** | The example is the primary pipeline input and scopes the classifier; the map's own framing separates the EXTEND enforce-flip and marks it **GATED on E47+E50**. Porting the classifier neither needs nor performs that flip, so the two are cleanly separable. The flip is homed in §6 to the map's EXTEND facet + its E47/E50 gate. Not author-tier — derivable from the example + the map's two-facet split. |
| 2 | **Mutual recursion** — does the port include the cross-`def` call graph? | **DEFERRED → E50** | E50 (mutual/lexicographic termination) is *built* in Python (`data.py:_check_recgroup`/`_edge_delta`/`_measured_gid`) as a distinct checker from `_totality_reason`; the example explicitly punts mutual recursion. The single-function port emits `(not-total "…")` for a self-reference-as-value exactly as OURS does, and the mutual-group self-host is E50's element. |
| 3 | **Working-type representation** — `Sizes`/`Bounds`/`Calls`/`DecSet` are opaque in the example; what does the runnable port use? | **RESOLVED — minimal concrete reps** | Engineering scoping call (as in E10 #4): `Sizes` = `(List SizeTok)` indexed by de-Bruijn level; `Bounds` = `(List Bound)`; `Calls` = `(List DecSet)`; `DecSet` = `(List I64)` (decreasing arg positions). This is enough to run the foetus collect-and-intersect and the numeric test; it mirrors OURS's per-call `dec` sets + `bounds` dict. No settled doc needed — a data-representation choice, forward-compatible with a richer size order later (example "knobs"). |
| 4 | **Where does `Bounds` extraction live** — shared with the refinement engine (E09)? | **RESOLVED — E11-local, not shared** | Two separate built implementations read similar comparison-guard syntax: totality's `data.py:_guard_bound` (`:760`) and refinement's `refine.py:_narrow`/`_atom` (E09/E10). They live in different modules with different consumers (termination-measure vs occurrence-typing) and neither calls the other. The port keeps `guard-bound` in `totality.chiral`, local; any future unification is a separate refactor, not E11. Derivable from the outlines (distinct functions, distinct modules). |
| 5 | **How does `require_total` bind to a profile?** | **RESOLVED — caller's job, unchanged** | `check-termination` returns a pure `Verdict`; escalation to an error is done by the profile-verify caller (`surface.py:verify_profiles`) on the built `(total)` clause / `require_total` — the example's "the caller escalates … instead of the checker deciding." Errors-as-values keeps policy out of the classifier. The *default* value of `require_total` is the enforce-flip (decision #1, deferred). |

All dispositioned; none blocking. `status: draft` (not blocked).

## 4. Change plan (ordered, commit-sized)

### Step 1 — data shapes + working-type reps
- **Target:** `scaffold/lib/totality.chiral` (new) — `(import "prelude")`; the
  `Term` (`t-var`/`t-lam`/`t-app`/`t-case`/`t-glob`) ↔ `Arm` mutual `data` block
  (example §5, elaborates via E79), plus `SizeTok` (`st-root`/`st-smaller`),
  `Bound` (`bnd`), `Verdict` (`total`/`not-total`), `Walked` (`v-ok`/`v-err`),
  and the concrete `Sizes`/`Bounds`/`Calls`/`DecSet` reps (decision #3).
- **Change:** the example §5 decls verbatim, with the opaque `declare`d working
  types replaced by their concrete list reps. **Define `I64-MAX`/`I64-MIN`
  locally in `totality.chiral`** — `(def I64-MAX I64 …)` = `2^63−1`,
  `(def I64-MIN I64 …)` = `−(2^63)`, matching `data.py:717–718` (`_I64_MAX`/
  `_I64_MIN`); prelude does **not** export them (verified: grep of `prelude.chiral`
  is empty), so the example §5's "prelude … I64-MAX, I64-MIN" comment is
  superseded here — the port owns the constants.
- **Size:** ~M

### Step 2 — helpers (measure list / size + bounds env / dec-set)
- **Target:** `totality.chiral` — `count-lams`/`strip-lams`, `sizes-init`,
  `bounds-init`, `calls-empty`/`calls-empty?`/`calls-push`, `intersect-all`,
  `is-self`, `dec-empty`, `guard-bound` (the `data.py:_guard_bound` port,
  decision #4). All forward-`declare`d before the spine (json.chiral idiom).
- **Change:** structural-recursion list folds; `guard-bound` reads a `case`/`<i`
  test into a `Bound`. Total on the list/tree measures.
- **Size:** ~M

### Step 3 — the numeric-decrease test (the wraparound obligation)
- **Target:** `totality.chiral` — `num-dec-ok (-> Bound I64 I64 Bool)` (the port
  of `data.py:_num_dec_ok:823` + `_num_delta:725`).
- **Change:** for a step `d` of param `j` toward a bound `(bnd j lo hi)`: accept
  `d>0` only when `(<=i hi (- I64-MAX d))`, `d<0` only when
  `(>=i lo (- I64-MIN d))` (finding §2.4). Reject the vacuous extreme bound.
  Arithmetic in I64 against the real constants — the tool reasons about wrapping
  in the arithmetic it polices.
- **Size:** ~M

### Step 4 — `score-args` (structural OR numeric per position)
- **Target:** `totality.chiral` — `score-args (-> Str I64 (List Term) I64 Sizes
  Bounds DecSet)`.
- **Change:** fold over enumerated args: a `(t-var l)` with `SizeTok`
  `(st-smaller j)` → add `j` (structural); else a safe `num-dec-ok` step → add
  `j` (numeric). Mirrors OURS's per-call `dec` accumulation.
- **Size:** ~M

### Step 5 — the walk + `check-termination` (the spine, from example §5)
- **Target:** `totality.chiral` — `walk`/`walk-children`/`walk-arms` +
  `check-termination`, verbatim from the audited example §5 (structural on
  `Term`; self-call → `calls-push (score-args …)`; `t-glob`=name → `v-err`
  used-as-value; intersect → `total`/`not-total`).
- **Change:** paste the spine; wire Steps 2–4. Already syntax-legal (`case`, no
  value-`if`).
- **Size:** ~S

### Step 6 — differential test file
- **Target:** `scaffold/tests/test_totality_chirality.py` (new; leave the Python
  `test_kernel.py::TestTermination` untouched).
- **Change:** load `lib/totality.chiral`, drive `check-termination` with the
  `apply1` RT harness (test_json.py shape). Assert `(total)`/`(not-total …)`
  agrees with `data.py:_totality_reason` (`None` ⇔ `total`) on the four golden
  cases (§5): (a) structural case-field descent → total; (b) symbolic-strict
  `i<n`, `n` unchanged, ±1 step → total; (c) vacuous extreme bound (`i<=MAX`,
  `i+1`) → **not-total**; (d) self-ref-as-value → not-total. Drive OURS live
  where feasible (build the `Term`, call `_totality_reason`), else transcribe the
  verdict with the cited `data.py` line.
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** `totality.chiral::check-termination(name, term)` returns
  `(total)` on exactly the terms `data.py:_totality_reason` returns `None` for
  and `(not-total reason)` otherwise, over the classifier's scope (single-
  function structural + safe-numeric recursion). The four must-match cases: (a)
  structural descent on a case-bound field → total; (b) safe numeric measure
  (±1 step, guard-established bound, `n` unchanged) → total; (c) wrap-touching
  bound → not-total (the I64 obligation, finding §2.4); (d) self-reference used
  as a value → not-total. Mutual recursion and full-SCT terms are **out of scope**
  (E50) — the port matches OURS's single-function verdict, including OURS's own
  "punt" on those.
- **Floors compared:** the **chirality RT interpreter** running `totality.chiral` vs
  the **Python `data.py` oracle** (`_totality_reason`), driven live where the
  `Term` can be constructed — lib-level chirality-vs-golden (`test_json.py` shape),
  not a native/tal differential. Enforcement (`require_total` escalation) is the
  caller's and is **not** exercised here.
- **Green line:** 355 → ≥ 355 + k (the new `test_totality_chirality.py` functions);
  full suite stays green, `data.py` unchanged, ledger-lint clean.
- **Done when:** `test_totality_chirality.py` passes — the chirality classifier matches
  `_totality_reason`'s verdict on the four golden cases (structural-accept,
  safe-numeric-accept, wrap-reject, value-use-reject).

## 6. Residue & links

- **Deliberately unbuilt:**
  - **Enforce-by-default flip** (`require_total` default ON) — the map's EXTEND
    facet, **GATED on E47+E50** (else regresses lexicographic/mutual/non-unit
    loops). Decision #1; home = the E11 EXTEND row + [[E47]]/[[E50]].
  - **Mutual / lexicographic termination self-host** — **[[E50]]** (built in
    Python; its own port). Decision #2.
  - **Full LJB size-change** (transitive-closure condition) — E50's deferred
    size-change-graph residue; the port does the uniform-intersection special
    case OURS does.
  - **Sized types** (promote non-structural size-decreasing recursion) —
    **[[E47]]** (the other E11-flip prerequisite; not built).
  - Retiring `data.py`'s checker and wiring `check-termination` onto the live
    `def_hooks` seam — rides the whole checker self-host, not E11.
  - Higher-order / definitional-unfolding termination — example "deliberately
    omitted"; no home yet.
- **Follow-on:** contributes the single-function classifier to the self-hosted
  checker stack; pairs with [[E50]] (mutual) and [[E47]] (sized) toward the
  enforce-flip.
- **Related:** [[E11-totality-checker]] (rationale) · [[E50]] (mutual/lex, dec.
  #2) · [[E47]] (sized types, the flip prereq) · [[E01-sexp-reader]]/[[E03-nbe-normalize]]
  (the `Term` ADT this walks) · [[E06]]/[[E07]] (data ctors / positivity — the
  structural order's source) · [[E09-refinement]] (guard predicates; dec. #4) ·
  [[E24-i64-arith]] (the I64 floor whose wraparound the numeric branch excludes).
