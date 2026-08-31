---
element: E41
slug: region-types
title: Region types (retire runtime offset/bounds checks)
kind: BUILD-PROPER
reference_class: PAPER
ours_source: (none)
status: drafted
updated: 2026-08-02
---

# E41 — Region types (retire runtime offset/bounds checks)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> **Scope bound:** the *typed cursor* that turns the bump arena's runtime
> `(<=i (+ used len) cap)` halt into a compile-time refinement proof. The
> load-bearing enabler is the arith-expression bound `(<= (+ o s) cap)` — the
> **edge-3 refinement extension the audited E9 SPEC deferred to E41** (§2.3). Full
> Tofte–Talpin region *inference* and region *polymorphism* are out (§6).

## 1. Scope

- **Element:** E41, **region types** — a bump region carries its capacity `cap`
  in its *type* and a **linear refined cursor** whose offset is proven within
  `[0, cap]`, so allocation discharges `offset + size ≤ cap` as a **compile-time
  refinement obligation** instead of the runtime bounds-check-or-halt the arena
  runs today.
- **Kind:** BUILD-PROPER — the region *discipline* library is built
  (`lib/mem-region.chiral`, `(memory region)` clause); E41 is the *types* tier
  that retires the runtime check, and it is gated on one refinement capability
  chirality does not yet have (§2.3, the edge-3 facet).
- **Why chirality needs its own:** the self-hosted arena (E21) bounds every `alloc`
  with a runtime `(<=i (+ used len) cap)` and *halts* on overflow — a
  runtime alarm, not a typed fact. P2 ("the type is the whole cost") and P4
  (structural, not runtime, guarantees) want the bound *proven in the type*: an
  over-allocation should be a **checker rejection at the call**, not a `ud2` at
  runtime. That is what a refined cursor delivers — and it is the last
  runtime-witnessed bound in the memory story (`banks/memory` §5 gradient).

## 2. Research

- **Reference class:** PAPER — Tofte–Talpin region calculus (regions with
  lexical lifetime + typed allocation), and the refinement/liquid-types line
  (a value carried with a decidable arithmetic proof). Read for the *idea*
  (allocation carries a proof); chirality reuses machinery already present.
- **Key findings (load-bearing):**
  1. **A region's bound belongs in the type, the cursor is a refined value.**
     The region's `cap` is an erased type index; the live offset is a
     `(refine I64 (>= 0) (<= cap))`. Single-variable bounds like `(< n)` /
     `(<= cap)` are **already decided** by the built refinement engine
     (E9, `refine.py`) — the cursor's *own* invariant needs nothing new.
  2. **The cursor is linear.** A single-threaded bump arena has exactly one live
     offset; the cursor is `(1 cur …)`, consumed by each `alloc` and re-minted at
     the advanced offset — reuse of a stale cursor (double-bump) is a linearity
     rejection, exactly the E8 discipline the region library already uses for its
     handle.
  3. **THE load-bearing gap — the allocation obligation is a *variable-sum*
     bound.** `alloc` at offset `o` for `s` bytes must prove `o + s ≤ cap` — an
     inequality over the **sum of two variables** against a third. E9's built
     fragment decides constants and *single*-variable symbolic bounds
     (`v < n`, `refine.py`), **not** `e1 + e2 ≤ e3`. This is **edge 3** — the
     refinement extension the **audited E9 SPEC explicitly deferred "to E41 /
     edge-3."** So E41 *owns* the arith-expression-bound extension as its enabler:
     without it the cursor invariant holds but the *transition* `o → o+s` cannot
     be discharged, and the runtime halt cannot retire. This is the honest
     dependency (and the exact thing E22's refined-cursor tier waits on).
  4. **The bound is over-approximate and monotone.** `o+s ≤ cap` never decreases
     the provable region; a failed proof falls back to the *existing* runtime
     check (the halt stays as the sound floor), so E41 is a strict widening — no
     terminating program it can prove regresses.

## 3. Conventional (other-language) approach

```c
/* C / a hand arena: the bound is a runtime branch, or nothing at all. */
void *bump(Arena *a, size_t s) {
    if (a->used + s > a->cap) abort();   /* runtime check — or UB if omitted */
    void *p = a->base + a->used;
    a->used += s;                        /* nothing ties `used` to a type */
    return p;
}
```

- **Assumptions it bakes in:** the size/offset/capacity relationship is folklore
  the compiler cannot see; the bound is a runtime `if` (or, omitted, undefined
  behavior — the exact untyped-bottom chirality refuses); "it fits" is a hope or a
  crash, never a machine-checked fact in the allocation's type. chirality's own
  arena today is the disciplined version of the *same* runtime branch (a `halt`,
  not UB) — E41 is what moves that branch into the type.

## 4. The chirality idea

- **Chirality features in play:** refinement types (the cursor's `(<= cap)`
  invariant + the `o+s ≤ cap` obligation, E9 + the edge-3 extension), QTT
  linearity (the single live cursor, E8), the built region discipline
  (`lib/mem-region.chiral`), the self-hosted arena (E21, the referent the cursor
  governs), totality (a bounded region is a total allocator — no unbounded loop).
- **The reframing:** allocation stops being *bump-then-check* and becomes
  *prove-then-bump*. The region's capacity rides its type; the cursor is a linear
  refined offset; `alloc` consumes the cursor, **discharges `o + s ≤ cap` at
  check time**, and re-mints the cursor at `o + s` (itself `≤ cap`, so the
  invariant is preserved by construction). The runtime `(<=i (+ used len) cap)`
  halt is *deleted* on the proven path — the bound moved from a branch to a type.
- **What chirality makes impossible here:** allocating past a region's capacity (the
  refinement rejects `o + s > cap` at the call, not at runtime); reusing a stale
  cursor after a bump (linearity rejection — no double-allocation of the same
  span); and an offset escaping `[0, cap]` (the cursor's own refinement carries
  it). The `ud2`/`halt` remains only as the sound fallback for spans the checker
  cannot prove (§2.4).

## 5. Chirality example (fleshed)

```chirality
(import "prelude")

; ---- the region: capacity rides the TYPE (erased index) --------------------
; `cap` is compile-time only (0-quantity); `base` is the arena pointer (E21).
(data Region ((0 cap I64)) (region (base I64)))

; ---- the cursor: a linear offset PROVEN within [0, cap] ---------------------
; Single-variable bound `(<= cap)` — decided by the BUILT refinement engine (E9).
; Linear: one live offset per region; a stale cursor is a use-after-bump reject.
(declare Cursor (-> (0 cap I64) (type 0)))
;   Cursor cap  ==  (refine I64 (>= 0) (<= cap))

; a fresh region opens with the cursor at 0 (0 <= cap holds trivially):
(declare region-open (-> (0 cap I64) (Region cap) (Cursor cap)))

; ---- alloc: prove-then-bump — the obligation is `o + s <= cap` --------------
; Consumes the cursor at offset o, requests s bytes, returns the slice and the
; cursor advanced to o+s. The proof obligation `(<= (+ o s) cap)` is discharged
; at CHECK time — this is the edge-3 arith-expression bound E41 introduces.
; On the proven path the runtime `(<=i (+ used len) cap)` halt is GONE.
(declare alloc
  (-> (0 cap I64)
      (1 cur (Cursor cap))
      (s (refine I64 (>= 0)))
      (Pair (Slice cap) (Cursor cap))))     ; slice within the region + advanced cursor

; ---- REJECTED (illustration): a provably-over allocation --------------------
; If the checker cannot prove `o + s <= cap`, `alloc` does not typecheck at the
; call — a compile-time refusal, never a runtime halt. (A span it cannot decide
; falls back to the existing runtime-checked allocator — the sound floor, §2.4.)

; ---- the retired runtime check (what this deletes) --------------------------
; today mem-alloc runs, per allocation:
;   (case (<=i (+ used len) cap) (true <bump>) (false (halt "arena exhausted")))
; with a proven cursor the (false …) arm is unreachable BY TYPE — dead-coded.
```

- **Knobs to modify:** the region's `cap` (any erased I64); whether a profile
  *demands* proven allocation (rejects the runtime-fallback path) for a
  bounded-memory target; the cursor's carried invariant (here `[0, cap]`;
  a nested sub-region carries `[lo, hi]`).
- **Deliberately omitted:** Tofte–Talpin region *inference* and region
  *polymorphism* (`∀ρ`); region *lifetime* nesting/escape typing (the `ρ`-brand,
  a kernel-tier direction); first-class region handles beyond the linear cursor;
  the general refinement solver (only `e1 + e2 ≤ e3` linear bounds are owed, not
  full nonlinear arithmetic).

## 6. Use / modify notes

- **Lands in:** `refine.py` first — extend the entailment engine to **linear
  arith-expression bounds** (`(<= (+ o s) cap)`: a sum of atoms vs an atom),
  the edge-3 facet; then a `lib/region.chiral` typed layer over the built
  `lib/mem-region.chiral` / the E21 arena (`Region`/`Cursor`/`region-open`/`alloc`)
  whose `alloc` carries the proof and dead-codes the halt on the proven path.
- **Conformance target:** (a) a program that allocates within a region's proven
  capacity type-checks and behaves identically to the runtime-checked arena
  (same bytes, same layout); (b) a program that provably over-allocates is
  **rejected at the `alloc` call**, not halted at runtime; (c) a span the checker
  cannot decide still compiles, falling back to the runtime check (strict
  widening — no prior program regresses); (d) reusing a bumped cursor is a
  linearity rejection.
- **Open questions:**
  1. **Scope of the arith-expression extension (edge 3)** — exactly which
     linear-arithmetic shapes E41 owns: `e1 + e2 ≤ e3` (the `alloc` obligation)
     is the minimum; does it also decide `k*e ≤ e'` (scaled, for aligned
     allocation) now, or defer that? The audited E9 SPEC deferred the *whole*
     inter-variable-arith facet here — E41 must pick the minimal decidable slice.
  2. **E41 owns the arith extension, or a distinct E9-REFACTOR sub-element?** The
     region types and the arith bound are separable; folding both into E41 keeps
     one home, but the arith extension has consumers beyond regions (E22's
     refined cursor, E25's byte-cell dependent faces) — a scoping call.
  3. **Region lifetime / nesting types** — does E41 carry only the flat
     single-region cursor, or the nested-sub-region `[lo, hi]` telescope (which
     would ride E48 field-dependence)? Flat-first is the conservative start.
  4. **Profile enforcement** — may a bounded-memory target *forbid* the
     runtime-fallback path (§2.4), demanding every allocation be proven? A profile
     clause, tied to the E11 enforce-by-default machinery.
- **Related:** [[E09-refinement]] (the engine the edge-3 bound extends — the
  deferred-to-E41 facet), [[E21-arena]] (the arena the cursor governs),
  [[E22-regions]] (its refined-cursor REFACTOR tier waits on exactly this arith
  bound), [[E25-byte-cells]] (the other consumer of dependent arith faces),
  [[E48-telescopes]] (nested-region field dependence), [[E08-linear-kinds]] (the
  linear cursor), `docs/open-edges.md` edge 3 (the cost/bounds gradient),
  `docs/banks/memory.md` §5 (the runtime-witnessed-bound residue this retires).
