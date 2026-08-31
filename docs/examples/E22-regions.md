---
element: E22
slug: regions
title: Memory allocator / region types / GC-outside-TCB (beyond the bump arena)
kind: REPLACE-CRUTCH
reference_class: PAPER/IMPL
ours_source: scaffold/lib/mem-region.chiral
status: drafted
updated: 2026-08-01
---

# E22 — Memory allocator / region types / GC-outside-TCB (beyond the bump arena)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

> **AUDIT CORRECTION (2026-08-01) — read before using this example.** As
> drafted (2026-07-13) this example claimed "there is only a bump arena; no
> OURS to port — design from the reference." **That named a phantom.** The
> region *library* is BUILT and CONFORMS ([[banks/memory]] Shard 5):
> `lib/mem-region.chiral` ships `(data Region ((n I64)) (region (1 pool (Pool
> n)) (cap I64) (used I64)))`, `mem-alloc` (cursor advance, capacity checked at
> **runtime** — `(<=i (+ used len) cap)`, `halt` on overflow), `region-close`
> (unit free), selectable via the `(memory region)` profile clause. E22's real
> remaining scope is the map's two tiers: **(REFACTOR, M — E41/E22)** the
> refined/indexed cursor that retires the runtime capacity branch (offsets →
> `(refine I64 …)`, the halt → a type obligation), **hard-gated on E9
> arithmetic-expression bounds** (`cursor + size ≤ cap`, edge 3 — const +
> bare-var symbolic landed 2026-07-06; arithmetic expressions did NOT); and
> **(BUILD, L)** region-types-in-the-kernel. The Tofte–Talpin sketch in §4–§5
> below survives as a *design direction for the kernel tier* (the ρ-brand tying
> a pointer to its region), but a redraft must reconcile it with the BUILT
> `mem-region` shape — it is not a from-scratch library design.
>
> **UNBLOCK (2026-08-02):** the E9-arith enabler is now scoped — **[[E41-region-types]]
> is `audited`** and OWNS the edge-3 linear arith-expression bound (`o+s ≤ cap`,
> `refine.py`). E22's REFACTOR tier consumes E41's arith bound; E41/E22 are the
> coupled pair the CONFORMANCE-MAP already lists jointly (both REFACTOR-M and
> BUILD-L rows name `E41,E22`). Clean division: **E41 = the arith enabler**
> (`refine.py`) + a minimal region demo; **E22 = the production region types** —
> the REFACTOR reshape of the BUILT `lib/mem-region.chiral` (refined cursor, halt →
> type obligation) + the BUILD-L kernel ρ-brand. No longer blocked.

## 1. Scope

- **Element:** E22, a typed memory-management layer — region *types* over the
  built region discipline, so allocation lifetimes and bounds are proven, not
  GC-collected or runtime-checked.
- **Kind:** REPLACE-CRUTCH (the runtime capacity branch is the crutch) +
  BUILD-PROPER (the kernel tier). The library itself is **already built** — see
  the audit correction above; OURS is `lib/mem-region.chiral`, chirality source.
- **Why chirality needs its own:** the built discipline still proves liveness only
  by the linearity of the `Region` value; the capacity check is a runtime
  branch, and a raw `I64` offset can outlive its region. Chirality wants
  deallocation and bounds to be *typed facts* and any garbage collector kept
  **outside the TCB**: the kernel should never have to trust a tracing
  collector to know a pointer is dead.

## 2. Research

- **Reference class:** PAPER/IMPL — Tofte–Talpin region calculus (`letregion ρ`
  + region-polymorphic effects), dlmalloc (segregated free-lists / boundary
  tags), and the GC Handbook (tracing vs. region/arena reclamation).
- **Key findings:**
  - **Regions give O(1) bulk free.** Tofte–Talpin brands every allocation with a
    region name `ρ`; `letregion ρ in e` opens a region, `e` allocates into it,
    and the whole extent is freed in one step at scope exit. No per-object
    reclamation, no tracing — the *shape of the program* proves liveness.
  - **The region name is a phantom.** `ρ` is a type-level artifact: it exists to
    stop a reference from outliving its region, and carries no runtime cost.
    This maps cleanly onto a QTT-erased (`0`) type parameter.
  - **A general allocator (dlmalloc) is the fallback, not the floor.** Free-list
    coalescing and boundary tags are what you reach for only when lifetimes are
    *not* nested — the region layer handles the common LIFO case with no metadata
    and no collector, so the collector (if ever built) is a separate module.
  - **Keep the collector out of the trusted base.** A GC is a Category-C bridge
    (typed module over the untyped heap), never Category-A judgment; regions let
    most code avoid it entirely.

## 3. Conventional (other-language) approach

How this is done outside chirality — a C-style bump/arena allocator with ambient,
untyped lifetimes (the shape our current arena has, and what dlmalloc/GC replace).

```c
// bump arena: allocate by advancing a pointer; "free" resets the whole thing.
void *arena_alloc(Arena *a, size_t n) {
    void *p = a->hi;          // hand back current high-water mark
    a->hi  += n;              // advance — no bounds proof, no branding
    return p;                 // raw address escapes; nothing ties it to `a`
}
void arena_reset(Arena *a) { a->hi = a->base; }   // everything now dangling
```

- **Assumptions it bakes in:** ambient allocation (any code with the `Arena*`
  can bump it); untyped effects (a plain call mutates the high-water mark with no
  membrane); raw addresses escape and can be read after `arena_reset` — a
  use-after-free the type system never sees; double-reset and aliasing the live
  arena are both silently legal; liveness is a runtime hope (or a GC's job).

## 4. The chirality idea

How chirality's model reframes it: make the region a **linear capability** and brand
every pointer with an **erased region name**, so lifetime errors are type errors.

- **Chirality features in play:** QTT quantities (`1` linear region cap, `0` erased
  region/type names), the effect membrane (`=>` because allocation touches the
  arena substrate; `->` for pure inspection), categories B (raw arena) → C (the
  typed region bridge), and totality (bulk free is O(1), no unbounded sweep).
- **The reframing:** the raw `Arena` stays Category-B substrate, but you never
  touch it directly. `with-region` mints a **linear** `(Region r)` capability
  branded with an **erased** name `r`. Every allocation returns a `(Ptr r t)`
  whose region name `r` is part of its *type*. Freeing **consumes** the linear
  cap (`region-free`), after which no term can name `r` — so every `Ptr r _` is
  un-typeable. Liveness is proven by the linearity of the cap, not discovered by
  a collector. `letregion` becomes "acquire a `1`-cap, thread it, consume it".
- **What chirality makes impossible here:** use-after-free (the `Ptr`'s region name
  is gone once the cap is consumed), cross-region reads (a `(Ptr r₁ t)` cannot be
  dereferenced with a `(Region r₂)` cap — different types), double-free (the cap
  is linear, spent exactly once), and aliasing the live region (only one `1`-cap
  exists). None of these need a GC; the collector, if ever built, stays a
  Category-C module outside the kernel's judgment.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")

; ── Category B: the raw arena (untyped substrate the kernel cannot type) ──
; A bump pointer over one flat Bytes cell. The region layer below is the
; Category-C bridge that makes allocating into it safe.
(data Arena ()
  (arena (buf Bytes) (hi I64)))            ; hi = high-water bump offset

; ── The region capability: LINEAR, branded with an erased region name r ──
; (0 r (type 0)) is the Tofte–Talpin region name ρ — a phantom that exists only
; at check time to brand allocations to their region; erased, so zero runtime cost.
(data Region ((0 r (type 0)))
  (region (1 a Arena) (base I64)))         ; owns the arena + this region's low mark

; ── A typed pointer branded with BOTH its region name r and its payload type t ──
; r and t are erased. Two ptrs into different regions are different TYPES, so a
; ptr can never be read through the wrong region cap — and no raw address escapes.
(data Ptr ((0 r (type 0)) (0 t (type 0)))
  (ptr (off I64)))                         ; offset into the arena; opaque

; ── Threaded result: hand the linear region cap BACK alongside the new ptr ──
; (no Pair in prelude; a purpose-built product keeps the 1-cap single-owner).
(data Alloc ((0 r (type 0)) (0 t (type 0)))
  (alloc (1 reg (Region r)) (p (Ptr r t))))

; open a fresh region over a raw arena — PROCESS: it mutates the bump substrate.
(declare with-region
  (=> (0 r (type 0)) (1 a Arena) (Region r)))

; allocate sz bytes INTO region r; consume the cap, return it threaded with the
; branded ptr. Single-owner walk ⇒ no aliasing of the live region.
(declare ralloc
  (=> (0 r (type 0)) (0 t (type 0))
      (1 reg (Region r)) (sz I64) (Alloc r t)))
(def ralloc
  (lam (reg sz)
    (case reg
      ((region a base)
        ; … bump `a.hi` by sz, brand the offset as (Ptr r t), re-pack the cap …
        (alloc (region a base) (ptr base))))))

; free the WHOLE region in O(1): spend the linear cap, reset the bump mark, hand
; back the raw arena. Every (Ptr r _) is now un-nameable — use-after-free is a
; TYPE error, not a runtime fault. No tracing, no TCB growth.
(declare region-free
  (=> (0 r (type 0)) (1 reg (Region r)) Arena))
(def region-free
  (lam (reg)
    (case reg
      ((region a base)
        ; … set a.hi := base (drop this region's extent), return the arena …
        a))))
```

- **Knobs to modify:** the erased region name `r` (nest regions by adding names);
  the size/alignment policy inside `ralloc`; the `Arena` backing (`Bytes` size);
  whether `ralloc` threads the cap (shown) or takes a borrowed non-linear view;
  swapping the LIFO bump for a dlmalloc-style free-list when lifetimes aren't nested.
- **Deliberately omitted:** the actual bump/bounds arithmetic (elided `; …`);
  alignment and boundary tags; region *subtyping* / region-polymorphic effects;
  and the tracing GC path — regions make the common case collector-free, and any
  GC is a separate Category-C module, not part of this skeleton.

## 6. Use / modify notes

- **Lands in:** a reshape of the **existing** `lib/mem-region.chiral` (the
  REFACTOR tier: refined cursor, offsets → `(refine I64 …)`, the runtime
  capacity halt → a type obligation), plus the kernel tier's pointer-branding
  design (BUILD-L) — **not** a new `lib/region.chiral`; the library exists.
- **Conformance target:** an alloc-then-free round trip where (a) `ralloc`
  returns distinct offsets that stay in bounds, (b) `region-free` is O(1) and
  resets the high-water mark, and (c) any program that reads a `(Ptr r t)` after
  its `(Region r)` cap is consumed **fails to type-check** — the golden behavior
  is the *rejection*, matching Tofte–Talpin's `letregion` liveness.
- **Open questions:** how nested regions thread multiple linear caps without
  ceremony; whether `ralloc` should borrow rather than thread the cap; where the
  raw arena's Category-B ops sit relative to the kernel; if/when a Category-C GC
  is ever needed for non-LIFO lifetimes.
- **Related:** [[E22-regions]], [[E26-alarms]] (errors-as-values on OOM),
  [[E9-refinement]] (bounds/`(>= 0)` proofs on offsets and sizes).
