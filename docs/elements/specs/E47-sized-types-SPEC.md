---
element: E47
slug: sized-types
title: Sized types (termination promotion)
kind: BUILD-PROPER
example: examples/E47-sized-types.md
status: audited
updated: 2026-08-02
---

# E47 SPEC — Sized types (termination promotion)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
> **Scope bound:** the MINIMAL annotation-checked fragment — a size index on a
> recursive datatype, a size-reducing signature, and the single-recursive
> decrease-behind-a-call it promotes. No inference, no size polymorphism.
> **Inclusion is a fast-follow, not rung-1 critical path** (§3 #2 / §6).

## 1. Deliverable

- **After this runs:** `data.py`'s `check_termination` / `_totality_reason` gain a
  **size channel**: a recursive datatype may carry an **erased size index**
  (`Nat`: `s0` base, `ssuc` raise, `sinf` saturating top), constructors *raise*
  the index and `case` *lowers* it, a def may declare a **size-reducing
  signature** (`T^{i+1} → T^i`), and a recursive call whose decreasing argument
  is the result of such a signature is **admitted** (recorded `None` = proven-total
  in `sig.totality`) even though it is not a `case`-bound sub-term. The reduction
  claim is **checked** (a signature that returns its input unshrunk is rejected at
  the helper's own definition), never trusted.
- **Non-goals:** size **inference** (every size is annotated); size
  **polymorphism** / `∀i` beyond the erased-param form; higher-rank size use;
  folding the size index into E38's grade seat (§3 #1 — stays a distinct erased
  param here); flipping E11 enforce-by-default (that is E11's owed payload,
  gated on E47+E50 — E47 *feeds* it, does not do it). The enforcement seam
  (`sig.require_total` / the `(total)` profile clause) is **unchanged** — sizes
  only widen what is *provable*-total.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** **BUILD-L** (E47) — "forward construction inside
  the existing checker; no reshape." `_totality_reason` returns *not-proven* for
  these size-change recursions today. Also EXTEND-M (E11): the enforce-by-default
  flip is "GATED on E47+E50" — E50 satisfied 2026-07-28, E47 remaining.
- **Live code this composes with (do NOT respec):**
  - **E11 totality** (`data.py` `check_termination` / `_totality_reason`) — the
    three pillars (strict positivity, coverage, structural recursion) are
    **IMPLEMENTED** (`totality.md`); E47 *widens* the third, it does not rebuild
    it. The structural/numeric-measure routes stay and run **first** (§3 #3).
  - **E9 refinement** (`refine.py` `entails`) — the `< i` size bound is decided
    the same interval way E9 already decides numeric bounds.
  - **`data`-layer declared machinery** (strict positivity, linear kinds) — the
    size index rides here, not the kernel core: it must see through `Con`/`Case`,
    which the extrinsic kernel deliberately does not.
- **True delta:** (a) the size algebra + an **erased size-index param** on `data`
  declarations (raise at `Con`, lower at `Case`); (b) the size channel in
  `check_termination` (admit a recursive call at a strictly-smaller declared
  size); (c) the **negative check** that a size-reducing signature actually
  reduces; (d) a `data`-param surface for the size grade.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Size rides E38's carrier **grade seat**, or a **distinct erased `Nat` param**? | **RESOLVED-PROVISIONAL for this fragment: distinct erased `Nat` param** (as the example §5 sketches). The grade-seat *unification* is a **non-blocking author call tied to E38**. | The minimal fragment needs only an erased type param that `data.py` reads — no E38 dependency, and E38's grade seat is itself unbuilt. Whether to later fold size into the frozen grade vector (`decision-graded-kernel` pt 2: "size ≈ cost grade") is a carrier-design call the author owns; it does not block or change this fragment (the index is erased either way). |
| 2 | Is annotation-checked-only enough, or do checker functions force size **polymorphism**? | **DEFERRED → a post-E48/E50 audit of the actual self-hosted checker source.** | The RUNG-1 verdict: E47 is **not** on the critical path for *classifying* the checker (E50 owns the mutual heart; much remaining recursion is structural or mutual). E47 earns inclusion only if that audit finds N genuinely single-recursive size-change functions. Measured against real source, not a priori. |
| 3 | Interaction with E11's built numeric measures (a def provable *either* way). | **RESOLVED: structural/measure route runs FIRST; sizes consulted only on its failure.** | Keeps common code annotation-free and the size channel a pure widening — the example states it and it is the sound cheap-first ordering (no verdict a def already earns is lost). |

No blocking NEEDS-AUTHOR: #1 proceeds against the example's provisional distinct-index
form (grade-seat unification surfaced, non-blocking); #2 is a scoping gate on a
future audit (the fragment is still specifiable); #3 is derivable. Frontmatter
stays `draft`. **Scoping recommendation carried from the example:** hold E47's
*implementation* until after E48/E50 land and the checker-source audit confirms
which functions need it — build the fragment for exactly them.

## 4. Change plan (ordered, commit-sized)

### Step 1 — the size algebra + erased size-index on `data`
- **Target:** `data.py` (data-declaration machinery) + a surface size-param form.
- **Change:** admit an erased `Nat`-indexed data param (`(0 i Nat)`); record per
  constructor whether it **raises** the index (a recursive field at `SList i`
  under a result `SList (ssuc i)`) — the size-transfer table the checker reads.
- **Size:** ~M.

### Step 2 — the size channel in `check_termination`
- **Target:** `data.py` `check_termination` / `_totality_reason`.
- **Change:** when a recursive call's decreasing argument is the result of a
  **size-reducing** signature (`T^{i+1} → T^i`), admit the call as strictly
  smaller (record `None`). Runs **after** the structural/measure route (§3 #3):
  only consulted when the cheap routes leave the def not-proven.
- **Size:** ~M.

### Step 3 — the size-reduction check (the soundness half)
- **Target:** `data.py` (signature check at a size-annotated def).
- **Change:** verify a declared size-reducing signature *honors* the reduction —
  `case` lowers, `Con` raises, so a body returning its input unshrunk **fails**
  at the helper's own definition. This negative check is the guarantee that the
  admitted recursion is real.
- **Size:** ~S.

### Step 4 — differential + neutral preservation
- **Target:** the `TestTermination` suite.
- **Change:** every def E11 already proves total stays proven (structural/measure
  first); the existing suite is unchanged.
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** (a) every def E11 proves total today stays proven
  (structural/measure route unchanged); (b) an `msort`-shaped def (recurse on a
  size-reducing helper's result) **promotes** from not-proven to proven-total;
  (c) a **false** size-reducing signature (returns its input unshrunk) is
  **REJECTED** at the helper's definition — the soundness negative test; (d) the
  enforcement seam is untouched (`require_total` still gates identically).
- **Tests to add (`scaffold/tests/test_totality.py` / `test_kernel.py`):**
  1. **Promotion:** an `msort`/`halve`-shaped def classifies total *only* with
    the size signature; without it, not-proven (differential on the verdict).
  2. **Soundness (the point):** a bogus `T^{i+1} → T^i` that returns its argument
    is rejected at its own definition.
  3. **No regression:** the full `TestTermination` suite green, verdicts identical.
- **Green line:** 430 → **≥ 433**; `ledger-lint` clean.
- **Done when:** a merge-sort-shaped recursion on a size-reducing helper is
  classified total, a lying size signature is rejected, and every prior totality
  verdict is unchanged.
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - *Size inference / size polymorphism (`∀i`)* — annotation-only here; inference
    is the Abel complexity sink, deferred (§3 #2, gated on the checker-source audit).
  - *Grade-seat unification* — size folded into E38's frozen grade vector; the
    non-blocking author call of §3 #1 → [[E38-graded-cost]].
  - *E11 enforce-by-default flip* — E11's owed EXTEND payload, gated on E47+E50;
    E47 feeds it, does not perform it → [[E11-totality-checker]].
  - *Coverage interaction* — a size-lowered `case` must still be exhaustive
    (mechanical, but real) → the coverage checker (E6).
- **Rung-1 note:** E47 is a **fast-follow, not a rung-1 blocker.** [[E50-mutual-lex-termination]]
  (built) owns the mutual-recursion heart of the checker; [[E48-telescopes]] owns
  the dependent-signature blocker. E47's inclusion is confirmed by auditing the
  ported checker source *after* those land.
- **Links:** [[E11-totality-checker]] (the criterion this promotes),
  [[E50-mutual-lex-termination]] (the actual rung-1 blocker), [[E48-telescopes]]
  (the other), [[E38-graded-cost]] (the carrier the index may ride),
  [[E09-refinement]] (the bound decider), `docs/decision-graded-kernel.md`
  (pt 2: size ≈ cost grade), `docs/totality.md` (the enforcement seam).
