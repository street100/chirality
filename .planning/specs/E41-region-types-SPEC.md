---
element: E41
slug: region-types
title: Region types (retire runtime offset/bounds checks)
kind: BUILD-PROPER
example: examples/E41-region-types.md
status: audited
updated: 2026-08-02
---

# E41 SPEC — Region types (retire runtime offset/bounds checks)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
> **Two-part deliverable:** (1) the **edge-3 refinement extension** — linear
> arith-expression bounds `e1+e2 ≤ e3` in `refine.py` (the facet the audited E9
> SPEC deferred here); (2) a typed region layer over the built arena whose
> `alloc` discharges `offset+size ≤ cap` at check time, retiring the runtime halt.
> **This is the enabler E22's refined-cursor tier waits on.**

## 1. Deliverable

- **After this runs:** `refine.py`'s entailment decides a **linear
  arith-expression bound** — a *sum of atoms* against an atom (`(<= (+ o s) cap)`)
  — beyond today's constant + single-variable symbolic bounds; and a
  `lib/region.chiral` typed layer carries a region's capacity in its **type**
  (erased index) with a **linear refined cursor** (`(refine I64 (>= 0) (<= cap))`),
  so `alloc` **proves `o + s ≤ cap` at the call** and re-mints the cursor at
  `o+s`. On the proven path the arena's runtime `(<=i (+ used len) cap)` halt is
  **dead-coded by type**; a span the checker cannot decide falls back to the
  existing runtime-checked allocator (a strict widening).
- **Non-goals:** Tofte–Talpin region **inference** / **polymorphism** (`∀ρ`);
  region **lifetime nesting / escape** typing (the `ρ`-brand, kernel-tier); the
  **general/nonlinear** refinement solver (only `e1+e2 ≤ e3` *linear* bounds are
  owed); scaled bounds `k*e ≤ e'` (aligned alloc — §3 #1, deferred); flipping any
  enforcement default (§3 #4).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** E41 = "discipline lib only; edge 3." The region
  **discipline** is built; the **types** tier (refined cursor) is not, and it is
  gated on the arith-expression bound E9's built fragment lacks.
- **Live code this composes with (do NOT respec):**
  - **`lib/mem-region.chiral`** — the built region discipline: `Region ((n I64))
    (region (1 pool (Pool n)) (cap I64) (used I64))`, `region-open`, `bump`. It
    carries `cap`/`used` as **runtime witnesses** and its own comment (`:12`)
    names the upgrade: *"Refinement types would make the offset [check compile-
    time]."* E41 is exactly that upgrade — it erases `cap` into the type and turns
    `used` into the refined cursor.
  - **`refine.py`** — the built entailment: constant bounds + a single **symbolic**
    bound (`v < n`, a `(op, level)` fact). Its docstring (`:29`) states the gap
    verbatim: *"an arithmetic expression (`v < n+1`) is still out of the
    fragment."* E41 extends exactly this — the edge-3 facet the audited E9 SPEC
    deferred "to E41 / edge-3."
  - **E8 linear kinds** — the cursor is `(1 cur …)`; reuse of a bumped cursor is
    the existing linearity rejection.
  - **E21 arena** — the self-hosted `nb-sys-mmap` arena the cursor governs.
- **True delta:** (a) the `refine.py` sum-of-atoms entailment; (b) `lib/region.chiral`
  (`Region`/`Cursor`/`region-open`/`alloc`); (c) `alloc` carrying the proof +
  dead-coding the halt on the proven path, with the runtime fallback preserved.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Which linear-arith shapes E41 owns. | **RESOLVED: the minimal decidable slice — `e1 + e2 ≤ e3` (sum of atoms vs an atom), linear.** Scaled `k*e ≤ e'` (aligned alloc) **DEFERRED** to a follow-on. | `alloc`'s obligation is exactly a two-atom sum vs one atom; that is decidable linear integer arithmetic (Presburger-lite) and is the whole enabler E22 needs. Scaling is not required to retire the bump halt. |
| 2 | Does **E41 own** the arith extension, or a distinct E9-REFACTOR sub-element? | **RESOLVED: E41 owns it** (the audited E9 SPEC deferred the inter-variable-arith facet explicitly "to E41 / edge-3"); consumers beyond regions (E22 refined cursor, E25 byte-cell faces) consume E41's extension. | Already assigned by the E9 SPEC — one home, multiple consumers. Not re-litigated here; E41 is where the arith bound lives, regions are its first customer. |
| 3 | Region **lifetime / nesting** types. | **DEFERRED: flat single-region cursor only.** Nested sub-region `[lo, hi]` telescopes ride [[E48-telescopes]] field-dependence. | Flat-first is the conservative start and covers the arena-retirement goal; nesting is a separate feature with a named home. |
| 4 | May a bounded-memory **profile forbid** the runtime-fallback path? | **DEFERRED → E11 enforce-by-default machinery** (the `(total)`-clause-shaped gate). | The fallback keeps E41 a strict widening now; demanding *every* allocation be proven is a profile-enforcement flip that rides the same machinery E11's default-flip owes — not this SPEC. |

No blocking NEEDS-AUTHOR: #1/#2 are code/decision-derived, #3/#4 are clean deferrals
to named homes. Frontmatter stays `draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `refine.py`: the linear arith-expression bound
- **Target:** `refine.py` (the `entails` engine + the bound representation).
- **Change:** admit a bound whose LHS is a **sum of atoms** (`o + s`) against an
  atom RHS (`cap`), decided by linear-integer entailment beside the existing
  constant/single-symbolic facts. The minimal slice: `Σ atoms ≤ atom` and its
  negation. Determinism: canonical sorted atom order (reuse the existing sorted
  quote discipline).
- **Size:** ~L (the edge-3 refinement extension — the load-bearing step).

### Step 2 — `lib/region.chiral`: the typed region + refined cursor
- **Target:** `lib/region.chiral` (NEW) over `lib/mem-region.chiral` / E21.
- **Change:** `Region ((0 cap I64))`, `Cursor cap = (refine I64 (>= 0) (<= cap))`,
  `region-open` (cursor at 0), transcribe example §5. The cursor is linear.
- **Size:** ~M.

### Step 3 — `alloc`: prove-then-bump + dead-code the halt
- **Target:** `lib/region.chiral` `alloc` (+ the arena `mem-alloc` proven path).
- **Change:** `alloc` discharges `(<= (+ o s) cap)` via Step 1, returns the slice
  + the cursor at `o+s`; on the proven path the runtime `(<=i (+ used len) cap)`
  `false`-arm is unreachable by type (dead-coded). A span the checker cannot
  decide routes to the existing runtime-checked allocator (the sound fallback).
- **Size:** ~M.

### Step 4 — differential + fallback preservation
- **Target:** `scaffold/tests/test_refine.py` + `test_memory.py` (NEW cases).
- **Change:** the arith-expression entailment has a direct unit test; the region
  layer is differential vs the runtime-checked arena; the fallback path stays green.
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** (a) `(<= (+ o s) cap)` is **decided** by `refine.py`
  (accept when it holds, reject when it cannot, against a Python oracle); (b) an
  allocation within a region's proven capacity type-checks and produces the same
  bytes/layout as the runtime-checked arena; (c) a **provable over-allocation is
  rejected at the `alloc` call**, not halted at runtime; (d) an undecidable span
  still compiles via the runtime fallback (strict widening — no prior program
  regresses); (e) reusing a bumped cursor is a linearity rejection.
- **Tests to add:**
  1. **`refine.py` arith bound:** `entails` on `(+ o s) ≤ cap` fixtures — decided
    both ways, vs a Python linear-arith oracle (`test_refine.py`).
  2. **Region differential:** within-capacity allocation == runtime-checked arena
    (bytes + layout); the halt path is dead on the proven path.
  3. **Negative:** a provably-over allocation is a compile-time refusal; a stale
    cursor is a linearity rejection.
  4. **Fallback:** an undecidable-span program compiles + runs (runtime check).
- **Green line:** 430 → **≥ 434**; `ledger-lint` clean.
- **Done when:** `refine.py` decides `o+s ≤ cap`, an in-bounds region allocation
  runs identically to the arena with its runtime halt dead-coded, and a provable
  over-allocation is a checker rejection.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - *Region inference / polymorphism (`∀ρ`)* — Tofte–Talpin's engine; deferred.
  - *Region lifetime / nesting typing* — §3 #3 → [[E48-telescopes]].
  - *Scaled arith `k*e ≤ e'`* (aligned alloc) — §3 #1, a follow-on.
  - *General/nonlinear refinement* — only linear `Σ ≤ atom` is owed.
  - *Profile enforcement of proven-only allocation* — §3 #4 → E11 default-flip.
- **Unblocks:** [[E22-regions]] — its refined-cursor REFACTOR tier depends on
  exactly Step 1's arith bound; with E41 audited, E22 can spec against it.
- **Links:** [[E09-refinement]] (the engine extended — the deferred-to-E41 facet),
  [[E21-arena]] (the referent), [[E22-regions]] (the first consumer),
  [[E25-byte-cells]] (another arith-face consumer), [[E08-linear-kinds]] (the
  linear cursor), `docs/open-edges.md` edge 3, `docs/banks/memory.md` §5 (the
  runtime-witnessed-bound residue this retires).
