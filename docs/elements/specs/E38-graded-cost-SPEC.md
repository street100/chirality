---
element: E38
slug: graded-cost
title: Graded cost / coeffect semiring (the load-bearing decision)
kind: BUILD-PROPER
example: examples/E38-graded-cost.md
status: audited
updated: 2026-08-02
---

# E38 SPEC — Graded cost / coeffect semiring (the load-bearing decision)

> ⚑ **TRIAGE 2026-09-04 — DEAD.** 0 of 4 steps are executable at HEAD.
> Re-example against `lib/typing/kernel.chiral` before any SPEC is written
> again. Bucket and evidence: `records/spec-tier-triage.md`. This file was not
> rewritten and its `status:` was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
> **Scope bound (from the example):** ONLY the carrier-adjacency slice — the
> grade seats beside the row seat + one composition motion + a declared-ceiling
> check. Grade inference, size-indexed bounds, and lowering to tal are edges 2/3,
> not this SPEC.

## 1. Deliverable

- **After this runs:** the Pi carrier holds a **grade vector** seat beside its
  quantity/row seats (`usage × time × space × info-flow`, `cost = ℕ∞`), the
  semiring ops (`qadd`/`qmul`/`qjoin`/`qfits` + the usage-vector ops) range over
  the **product domain** instead of the 3-point lattice, a surface form declares
  a per-signature ceiling, and application/let compose grades in the **same
  motion** that already composes usage (`gadd(gf, gscale(q, ga))`) — a declared
  ceiling exceeded by the composed grade is a **conservative rejection** at the
  declaration, the exact shape of a refinement rejection. Neutral grades embed
  the current 0/1/ω behavior bit-for-bit.
- **Non-goals:** grade **inference** (this slice checks *declared* ceilings only);
  **size-indexed** grades (E47-adjacent promotion path); **info-flow** semantics
  (reserved trivial-lattice seat, enforcement stage 7–8); **lowering grades to
  tal**; any runtime metering (none exists, none is claimed); the ω-absorption
  law for higher-order captures (§3 #1, deferred). The judgment seams
  (`conv`/`infer`/`check`) do **not** reshape — the containment win.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** **REFACTOR-L** (three reconciled rows, E38). The
  semiring is *built but hardcoded*: `qadd`/`qmul`/`qjoin`/`qfits` + the usage
  vector are enforced at binder-exit and case-join (E5, **CONFORMS at 0/1/ω**),
  but pinned to the 3-point lattice with `W` a bare string. E38 **reshapes the
  data the arithmetic ranges over** (scalar → product tuple) and adds the carrier
  seat; it does **not** touch the judgment seams (map: "conv/infer/check do NOT
  reshape").
- **Live code this composes with (do NOT respec):**
  - **E5 QTT semiring** (`kernel.py` `qadd`/`qmul`/`qjoin`/`qfits`, the usage
    vector `uadd`/`uscale`/`ujoin`/`uzero`) — the existing semiring *instance*;
    E38 generalizes its domain, reusing the composition sites verbatim
    (`uadd(uf, uscale(q, ua))` at application `kernel.py:455`, same at let `:549`).
  - **E39 row seat** (`row.py` `Seats(row, grades, totality)`) — the carrier
    **already reserves a `grades` seat** (`decision-effect-facets`: seat count
    frozen). E38 *populates* that reserved seat; it does not reshape the carrier.
  - **E9 refinement entailment** (`refine.py` `entails`, interval + symbolic
    linear arithmetic) — the ceiling check `composed ≤ declared` **is** a linear
    entailment; reuse it (§3 #2).
- **True delta:** (a) the grade-product **data type** + its `gadd`/`gscale`/
  `gjoin`/`gfits` ops (the scalar ops generalized); (b) the `graded` **surface
  form** parsing per-factor ceilings onto a signature; (c) wiring the grade seat
  through the existing usage-composition sites (no new sites); (d) the
  neutral-grade embedding so the whole suite stays green.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | The **ω-absorption rule per factor** (what `ω × (time 3)` means — ∞, or bounded when the consumer proves a resume count?). | **DEFERRED → edges 2/3 (higher-order grade inference).** | This slice checks **first-order declared ceilings**; ω-absorption only bites on higher-order captures / inference, which are explicit non-goals. The carrier slice uses the conservative default (`gscale(ω, g)` = ∞ on the additive factors) so a declared first-order ceiling is sound; the *useful* higher-order rule (prove the count → finite) rides the E39 continuation law + inference. Carrier is shaped to admit it; the law itself is build-out. |
| 2 | Grade entailment reuses `refine.py`'s engine or a sibling module. | **RESOLVED: reuse `refine.py` `entails`.** | The ceiling check is exactly a linear-arithmetic entailment `Σ composed-factor ≤ declared-ceiling` — the built decidable fragment E9 already decides (example finding #4 + bank C4: "shares the linear-arithmetic entailment the refinement engine already has"). One engine, two seats; no second solver. |
| 3 | Surface form: `graded` wrapper vs inline per-arrow annotation. | **RESOLVED-PROVISIONAL: the example's `(graded ((time N)(space N)) TYPE)` wrapper (per-signature).** Non-blocking author ratification owed. | The example commits to the wrapper and it carries the carrier slice cleanly (per-signature ceilings). Not a fresh design call — the example set the direction. The per-arrow variant is the higher-order concern (#4); ratifying wrapper-vs-per-arrow as the *final* surface is a taste call the author may revisit — it does not block this slice. |
| 4 | Per-def vs per-arrow attachment (higher-order signatures). | **DEFERRED → edges 2/3 (higher-order).** | The carrier slice is **per-signature** (one ceiling over the whole arrow chain); per-arrow attachment only matters when a grade must ride an *inner* arrow of a higher-order type — the same build-out that owns #1. |

No blocking NEEDS-AUTHOR: #1/#4 are clean deferrals to the named higher-order
build-out; #2 is code-derivable; #3 proceeds against the example's provisional
form with the ratification noted. Frontmatter stays `draft`.

## 4. Change plan (ordered, commit-sized)

> **Trusted-core edit.** Steps 1–2 reshape the kernel's semiring data — reviewed
> as a trusted-core change per `decision-effect-facets` (show the diff; seat
> count stays frozen — the `grades` seat is *populated*, not added).

### Step 1 — the grade product + its semiring ops
- **Target:** `kernel.py` (semiring ops) + a new `grades.py` (the product domain
  behind the existing seam).
- **Change:** define `Grade = (usage, time, space, flow)` with `time`/`space` over
  `ℕ∞` (a bounded int or `Inf` sentinel), `flow` a reserved trivial-lattice seat.
  Add `gzero`/`gadd`/`gscale`/`gjoin`/`gfits` as the pointwise-per-factor lift of
  the scalar ops (usage factor = the existing 0/1/ω semiring verbatim). `gfits`
  (the ceiling test) delegates the additive factors to `refine.entails`.
- **Size:** ~M.

### Step 2 — populate the carrier grade seat + compose at the existing sites
- **Target:** `terms.py` Pi carrier (the reserved `grades` seat) + `kernel.py`
  application/let composition (`:455`/`:549`).
- **Change:** the Pi carrier's `Seats.grades` now carries a `Grade` (was reserved
  `None`). At application/let, beside the unchanged `uadd(uf, uscale(q, ua))`,
  compose `gadd(gf, gscale(q, ga))` — **same motion, new factor**. Default
  (unannotated) = neutral grade, so no judgment-seam change.
- **Size:** ~M.

### Step 3 — the `graded` surface form + ceiling check
- **Target:** `surface.py` (QUANTS / annotation parsing) + the declaration site.
- **Change:** parse `(graded ((time N)(space N)) TYPE)` onto the signature's
  grade seat. At the declaration, `gfits(composed, declared)` — a false result
  raises the conservative-rejection alarm (shape mirrors a refinement rejection,
  cite the message form). First-order only.
- **Size:** ~S.

### Step 4 — neutral-grade embedding (bit-compat)
- **Target:** the whole suite.
- **Change:** verify the 0/1/ω kernel embeds as the usage factor with
  time/space/flow at the neutral element — every existing test green with no
  ceiling declared (the E39 empty/nonempty-row bit-compat story, on the grade
  seat).
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** with **no** ceiling declared, behavior is byte-identical to
  today (neutral grades embed 0/1/ω). With a ceiling declared: a signature whose
  composed grade fits the ceiling checks; one that exceeds it is **rejected at the
  declaration** (conservative, never a runtime meter); sequencing **adds** grades
  pointwise (`sum-two`'s 64+64+2 ≤ 130 checks, ≤ 100 rejects).
- **Tests to add (`scaffold/tests/test_graded.py`, NEW):**
  1. **Neutral embedding:** the existing 0/1/ω linearity/usage tests pass
    unchanged under the product domain (differential: same verdicts).
  2. **Ceiling fits / exceeds:** `sum-bytes (time 64)` and `sum-two (time 130)`
    check; `sum-two (time 100)` rejects with the conservative-failure message.
  3. **Pointwise addition:** grade composition adds per factor (time and space
    independently), `gscale`/`gadd` unit + associativity fixtures vs a Python oracle.
- **Green line:** 430 → **≥ 433** (the three tests); every existing test green
  (neutral embedding); `ledger-lint` clean.
- **Done when:** a signature declaring a too-tight `time` ceiling is a checker
  rejection, a truthful one checks, and the full suite is green with neutral grades.
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - *ω-absorption law for higher-order captures* — §3 #1 → edges 2/3 (rides the
    E39 continuation-multiplicity law: `mult × body-grade`).
  - *Grade inference* — declared-only here; inference → edges 2/3.
  - *Size-indexed grades* — the promotion path → [[E47]] (sized types).
  - *Info-flow semantics* — reserved trivial-lattice seat; enforcement stage 7–8.
  - *Lowering grades to tal* — the cost claim reaching the floor → edges 2/3.
  - *Per-arrow attachment* — §3 #4 → higher-order build-out.
- **Sequencing note (rung-1):** this REFACTORs the *Python* kernel semiring. If
  the checker port (§I → chirality) lands first, E38 re-targets `lib/kernel.chiral`'s
  ported semiring — the *shape* (grade product, populated seat, one motion) is
  identical; only the host language differs. Not a blocker either way; E38 is a
  designed-feature edge (2/3), not on the rung-1 critical path.
- **Follow-on / links:** [[E39-effect-row]] (the sibling seat, one composition
  motion), [[E05-qtt-semiring]] (the semiring this generalizes), [[E09-refinement]]
  (the shared entailment), [[E47-sized-types]] (sized promotion),
  `decision-graded-kernel` (the settled three-home split),
  `decision-effect-facets` (the frozen carrier).
