---
element: E22
slug: regions
title: Memory allocator / region types / GC-outside-TCB (beyond the bump arena)
kind: REPLACE-CRUTCH
example: examples/E22-regions.md
status: audited
updated: 2026-08-02
---

# E22 SPEC — Memory allocator / region types (beyond the bump arena)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
> **E22 is the production region-TYPES tier; it consumes [[E41-region-types]]'s
> arith bound.** The CONFORMANCE-MAP lists E41/E22 jointly on both region rows.
> **Clean division:** E41 = the enabler (`refine.py` `o+s ≤ cap` + a demo) ·
> E22 = the region types — the REFACTOR reshape of the BUILT `lib/mem-region.chiral`
> (Tier 1) + the BUILD-L kernel ρ-brand (Tier 2). No GC in the TCB.

## 1. Deliverable

- **After this runs:** two tiers land.
  **Tier 1 (REFACTOR, consumes E41):** `lib/mem-region.chiral`'s runtime capacity
  branch (`(<=i (+ used len) cap)` + `halt`) becomes a **type obligation** — the
  cursor/offsets are `(refine I64 (>= 0) (<= cap))` and `mem-alloc` discharges
  `o+s ≤ cap` via E41's arith bound, dead-coding the halt on the proven path.
  **Tier 2 (BUILD-L, kernel ρ-brand):** a **linear** `(Region r)` capability
  branded with an **erased** region name `r`, and a `(Ptr r t)` whose region name
  is part of its type; `region-free` **consumes** the linear cap, after which no
  term can name `r`, so every `(Ptr r _)` is un-typeable — **use-after-free,
  double-free, and cross-region reads are type errors**, with O(1) bulk free and
  **no collector in the TCB**.
- **Non-goals:** region **inference** / region-polymorphic effects (`∀ρ`);
  nested-region multi-cap ceremony (§3 #1); a **borrowing** (non-linear view)
  `ralloc` (§3 #2); a tracing **GC** (a separate Category-C module for non-LIFO
  lifetimes — never Category-A, §3 #4); the arith bound itself (that is E41).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** two coupled rows, both `E41,E22`:
  **REFACTOR-M** ("region data gains refined cursor; runtime branch → type
  obligation; gated on E9 arith-expression bounds") and **BUILD-L**
  ("region-types-in-kernel; E9 variable-bound refinement is the enabling
  sub-capability"). The enabler (E41) is now `audited`.
- **Live code this composes with (do NOT respec):**
  - **`lib/mem-region.chiral`** (BUILT, `ours_source`) — `Region ((n I64))
    (region (1 pool (Pool n)) (cap I64) (used I64))`, `mem-alloc` (runtime
    capacity check), `region-close`, the `(memory region)` profile clause. Tier 1
    **reshapes** this file — it is not a new library.
  - **[[E41-region-types]]** (`audited`) — `refine.py`'s `o+s ≤ cap` arith bound;
    Tier 1 is its first consumer. (E41 also ships a minimal demo region layer;
    E22 is the production reshape — the division above.)
  - **`mem-put-checked`** (BUILT, CONFORMS) — already takes `(refine I64 (>=0)(<n))`
    and collapses the runtime check for literal/guarded offsets (F8 offset half);
    Tier 1's refined cursor is the same discipline on the *capacity* axis.
  - **QTT erased type params** (E5) — the ρ-brand is a `(0 r (type 0))` erased
    region name; branded `Ptr`/`Region` are standard erased-param data.
- **True delta:** Tier 1 = the refined-cursor reshape of `mem-region.chiral`
  (consuming E41); Tier 2 = the erased ρ-brand on `Region`/`Ptr` + the
  `region-free` linear consume that makes `(Ptr r _)` un-nameable.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | How nested regions thread multiple linear caps without ceremony. | **DEFERRED: flat single-region cursor / single cap first.** Nested regions ride the same field-dependence path as E41 #3 → [[E48-telescopes]]. | Flat-first covers the arena-retirement + use-after-free goals; nested-cap ergonomics are a follow-on, consistent with E41's flat-first. |
| 2 | Should `ralloc` **borrow** (non-linear view) rather than thread the cap? | **RESOLVED: thread the linear cap (single-owner), per §5.** A borrowing view is DEFERRED (needs a fractional-permission / borrow facet not yet designed). | Threading keeps the one-live-cap invariant that makes aliasing untypeable — the whole safety story. Borrowing is an ergonomic follow-on, not a safety prerequisite. |
| 3 | Where the raw arena's Category-B ops sit relative to the kernel. | **RESOLVED: Category-B substrate, reached ONLY through the Category-C region bridge** (`decision-b-in-type` / categories). | The `Arena` is untyped substrate; all typed access goes through `(Region r)` — B-ness lives in the type, the bridge governs the crossing. No new partition. |
| 4 | If/when a Category-C GC is needed for non-LIFO lifetimes. | **DEFERRED: a separate Category-C module, out of the TCB and out of this SPEC.** | Regions make the common LIFO case collector-free; a GC (if ever built) is a typed module over the untyped heap, never Category-A judgment — the key finding. |

No blocking NEEDS-AUTHOR: #2/#3 are decision-derived, #1/#4 are clean deferrals.
Frontmatter stays `draft`. Sequencing: Tier 1 depends on E41 (audited); Tier 2
(ρ-brand) is standard erased-param QTT and can land alongside or before Tier 1.

## 4. Change plan (ordered, commit-sized)

### Step 1 — Tier 1: refined cursor in `lib/mem-region.chiral` (consumes E41)
- **Target:** `lib/mem-region.chiral` `Region` / `mem-alloc`.
- **Change:** the `Region` capacity becomes an erased index; the offset/`used`
  becomes a `(refine I64 (>= 0) (<= cap))` cursor; `mem-alloc` discharges
  `o+s ≤ cap` via E41's arith bound and dead-codes the `halt` arm on the proven
  path; an undecidable span keeps the runtime check (strict widening).
- **Size:** ~M. **Depends on:** E41 Step 1 (the arith bound).

### Step 2 — Tier 2: the erased ρ-brand + branded pointer
- **Target:** `lib/mem-region.chiral` (or a kernel-tier sibling) — `Region`/`Ptr`.
- **Change:** brand `Region`/`Ptr` with an erased region name `(0 r (type 0))`;
  `ralloc : (=> (0 r) (0 t) (1 reg (Region r)) I64 (Alloc r t))` threads the
  linear cap and returns a branded `(Ptr r t)`. Transcribe example §5.
- **Size:** ~M.

### Step 3 — `region-free`: the O(1) consume that voids the brand
- **Target:** `lib/mem-region.chiral` `region-free`.
- **Change:** `region-free : (=> (1 reg (Region r)) Arena)` spends the linear cap
  and returns the raw arena; after it, no `(Region r)` exists, so `(Ptr r _)` is
  un-nameable — use-after-free is a type error, not a runtime fault.
- **Size:** ~S.

### Step 4 — tests: the golden is the REJECTION
- **Target:** `scaffold/tests/test_memory.py` (NEW cases).
- **Change:** alloc-then-free round trip (distinct in-bounds offsets, O(1) free);
  and the negatives — reading a `(Ptr r t)` after its cap is consumed, a
  double-free, and a cross-region read each **fail to type-check**.
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** an alloc-then-free round trip where (a) `ralloc` returns
  distinct offsets that stay in bounds (Tier 1, via E41), (b) `region-free` is
  O(1) and resets the high-water mark, and — **the golden is the rejection** —
  (c) a program reading a `(Ptr r t)` after its `(Region r)` cap is consumed
  **fails to type-check**, (d) a double-free is a linearity rejection, (e) a
  cross-region read (`(Ptr r₁ t)` with a `(Region r₂)` cap) is a type error.
- **Tests to add (`scaffold/tests/test_memory.py`):**
  1. **Round trip:** `ralloc`×N distinct in-bounds offsets; `region-free` resets.
  2. **Use-after-free rejected:** deref a `(Ptr r t)` after `region-free` — type error.
  3. **Double-free / alias rejected:** second `region-free` on a spent cap — linearity error.
  4. **Cross-region rejected:** deref `(Ptr r₁ t)` with a `(Region r₂)` cap — type error.
  5. **Tier-1 bound:** an in-capacity allocation runs identically to the runtime-checked arena.
- **Green line:** 430 → **≥ 434**; `ledger-lint` clean.
- **Done when:** a region round-trips (alloc + O(1) free) with in-bounds offsets
  proven via E41, and use-after-free / double-free / cross-region reads are all
  compile-time rejections — liveness by linearity, no collector in the TCB.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - *Region inference / region-polymorphic effects (`∀ρ`)* — Tofte–Talpin's engine; deferred.
  - *Nested-region multi-cap ergonomics* — §3 #1 → [[E48-telescopes]].
  - *Borrowing (non-linear) `ralloc`* — §3 #2, a follow-on (fractional permissions).
  - *Tracing GC for non-LIFO lifetimes* — §3 #4, a Category-C module outside the TCB.
  - *The arith bound itself* — [[E41-region-types]] owns it.
- **Depends on:** [[E41-region-types]] (`audited`) — Tier 1 consumes its `o+s ≤ cap`.
- **Links:** [[E41-region-types]] (the arith enabler + demo layer), [[E21-arena]]
  (the Category-B substrate), [[E09-refinement]] (the bounds engine E41 extends),
  [[E08-linear-kinds]] (the linear cap / single-owner), [[E48-telescopes]]
  (nested-region dependence), `docs/banks/memory.md` §5 (the residue this closes),
  `docs/open-edges.md` edge 3.
