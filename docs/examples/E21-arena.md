---
element: E21
slug: arena
title: `mmap` as the arena; represent the returned pointer; wire bump-allocator base/end
kind: REPLACE-CRUTCH
reference_class: SPEC
ours_source: scaffold/chirality/native.py
status: drafted
updated: 2026-07-12
---

# E21 — `mmap` as the arena; represent the returned pointer; wire bump-allocator base/end

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E21 — obtain the boxed-value arena from the OS via `mmap`,
  represent the returned base as a machine pointer, and wire a bump allocator
  that threads `base`/`end` and hands out fresh cells.
- **Kind:** REPLACE-CRUTCH. **Build-state note (updated 2026-08-01):** the
  mapping *mechanism* is already self-hosted. The E21 syscall milestone is
  COMPLETE (CONFORMANCE-MAP "E21 arena done"; status-ledger: chirality
  `memfd_create → ftruncate → mmap(MAP_SHARED) → byte-roundtrip → munmap`,
  differentially tested), and since the 2026-07-29 E20 mechanism refactor
  `native.py` maps the arena through the chirality `nb-sys-mmap` crossing
  (`_map_rw`, `native.py:410,476`) — CPython's `mmap` module and ctypes
  `_mprotect` are gone. What this example proposes on *top* of that — the
  **typed linear `Arena` value + total pure `bump`** (`lib/arena.chiral`) — is
  **unbuilt**; the live bump is x86 emitted inline over raw `heapptr`/`heapend`
  cells with `ud2` on exhaustion.
- **Why chirality needs its own:** the mapping is (rightly) untyped substrate behind
  a self-hosted crossing, but the *bump discipline over it* is still host/metal
  convention: a raw base poked into cells, aliasing unchecked, exhaustion a
  fault. That discipline is the part chirality should own, so allocation becomes a
  typed, linear, total operation instead of ambient pointer arithmetic.

## 2. Research

- **Reference class:** SPEC — the Linux `mmap`/`munmap` ABI as consumed by
  `scaffold/chirality/native.py` (`nb-sys-mmap` prim, sig `[I64,I64,I64,I64,I64,I64]
  -> I64`) and `docs/memory-model.md`'s region discipline.
- **Key findings:**
  1. **The mapping call is a 6-arg syscall returning one word.** `mmap(addr,
     len, prot, flags, fd, off)` returns the page-aligned base **address** (an
     I64), or an error value in the top errno band (`MAP_FAILED`). Anonymous
     private RW arena = `fd = -1`, `flags = MAP_ANONYMOUS|MAP_PRIVATE`,
     `prot = PROT_READ|PROT_WRITE` (1|2), zero-filled, `len` rounded to a page.
  2. **The pointer is just an integer.** `native.py` takes `abase =
     addressof(...)` and computes `heapend = abase + ARENA_BYTES`
     (`ARENA_BYTES = 1<<20`). There is no runtime tag — a pointer is one raw I64
     word (Milestone-2 "static representation, no runtime tagging").
  3. **Bump = two cells, `heapptr` and `heapend`, emitted into the code.** Alloc
     is `p = heapptr; heapptr += aligned(size); fault if heapptr > heapend`.
     Exhaustion is currently a **`ud2` fault** (or `MemoryError` in the Python
     cell materializer) — i.e. partiality baked into the metal.
  4. **The invariant the SPEC forces:** `base <= heapptr <= heapend`, and every
     handed-out pointer lies in `[base, end)` and is 8-byte aligned. That is the
     whole correctness contract the chirality side must preserve.

## 3. Conventional (other-language) approach

How this is done outside chirality — the **pre-refactor** Python loader (the
CPython-`mmap` shape, since retired by the E20 mechanism refactor; kept as the
conventional foil because its *type-unsafety* — the ambient global `heapptr`,
the untyped base int — is exactly what the typed layer below removes), plus the
C shape it mirrors.

```python
ARENA_BYTES = 1 << 20
arena = mmap.mmap(-1, ARENA_BYTES,
                  prot=mmap.PROT_READ | mmap.PROT_WRITE)
abase = ctypes.addressof(ctypes.c_char.from_buffer(arena))
# heapptr/heapend are cells poked into the emitted code:
heapptr = abase
heapend = abase + ARENA_BYTES

def bump(size):                     # what the emitter's inline code does
    global heapptr
    p = heapptr
    heapptr += (size + 7) & ~7      # 8-byte align
    if heapptr > heapend:           # chirality emitter: ud2; loader: raise
        raise MemoryError("arena exhausted")
    return p
```

- **Assumptions it bakes in:** the mapping syscall is an **ambient, untyped
  effect** (anyone can call `mmap`); `heapptr` is **mutable global state**
  aliased freely; the base pointer can be copied/reused with no linearity;
  exhaustion is **partiality** (a fault/exception), not a value; the pointer is
  an untyped `int` with no evidence it came from *this* arena.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** categories A/B/C (the mapping is B, the allocator
  is a C bridge over it); QTT linearity (`q=1` on the arena capability); the
  effect membrane (`=>` to acquire the map, `->` to bump); errors-as-values +
  totality (exhaustion returns a sum); the float→I64 wall (a pointer is one
  I64 word, never anything else).
- **The reframing:**
  - `mmap` stays **category B** — raw substrate the kernel cannot type. It is
    reached only through a **`=>` process** holding a `MapPort` grant, so the
    authority to map memory is a held capability, not ambient.
  - The bump allocator is **category C** — a typed module over that untyped
    region, governed by evidence. The arena is a **linear value** `(cur, end)`;
    **holding it is the authority to allocate.** `bump` takes the arena `q=1`
    and returns a fresh pointer *plus a new arena* — a value-semantics update,
    so it is a **pure `->`** function (no port, no I/O).
  - Exhaustion becomes a returned `a-err` (totality), not a `ud2` fault. The
    fault stays as the *last-resort* metal behavior; the typed layer decides
    exhaustion explicitly before it can happen.
- **What chirality makes impossible here:** aliasing or reusing a stale `base`
  (linearity consumes the arena on each bump); double-allocating from a copied
  pointer; allocating with *no* arena in hand (no ambient `malloc`); and
  silently running past `end` (the `<=i cur end` check is in the signature's
  contract, not an optional guard).

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")

; A machine pointer: ONE raw I64 word, category B. No runtime tag — the
; representation is static, exactly as the emitter lays boxed cells out.
(data Ptr () (ptr (addr I64)))

; The arena is a LINEAR capability: the half-open region [cur, end). Holding
; this value IS the authority to allocate from it; it is threaded q=1 so no
; stale base can survive a bump.
(data Arena () (arena (cur I64) (end I64)))

; Allocation is TOTAL: either a fresh pointer + the shrunk arena, or a named
; exhaustion value. No fault, no throw — the error path is in the type.
(data Alloc () (a-ok (p Ptr) (rest Arena)) (a-err (why Str)))

; The authority to map memory is a held capability, not ambient.
(porttype MapPort)

; Acquire the mapping. This CROSSES the membrane: => process, and it must hold
; the OS map-port grant. This is the thin category-C bridge over `nb-sys-mmap`;
; the syscall itself (prot=RW, MAP_ANON|MAP_PRIVATE, fd=-1) is category B.
(declare arena-map (=> (1 m MapPort) (len I64) Arena))

; round a request up to the next multiple of 8 (Euclidean mod; there is no
; bitwise &/~ in the pure fragment -- the C `(n+7)&~7` idiom is arithmetic here)
(declare align8 (-> I64 I64))   ; (mod-based: r = n mod 8; r=0 ? n : n+(8-r)) ; …

; The bump is PURE: given the arena linearly, return a new one. -> not =>,
; because once the region is in hand this is just arithmetic on I64 words.
(declare bump (-> (1 a Arena) (n I64) Alloc))
(def bump
  (lam (a n)
    (case a
      ((arena cur end)
        (let ((next (+ cur (align8 n))))
          (case (<=i next end)
            (true  (a-ok (ptr cur) (arena next end)))  ; hand out cur, keep [next,end)
            (false (a-err "arena exhausted"))))))))

; Sketch of a caller threading the linear arena through two allocations.
(declare two-cells (-> (1 a Arena) Alloc))
(def two-cells
  (lam (a)
    (case (bump a 16)
      ((a-err w)      (a-err w))
      ((a-ok p0 a1)   (case (bump a1 24)     ; a0 is consumed; only a1 lives on
                        ((a-err w)    (a-err w))
                        ((a-ok p1 a2) (a-ok p1 a2)))))))   ; … chain onward
```

- **Knobs to modify:** `ARENA_BYTES`/`len` (the map size); the alignment mask
  (8 → 16 for SIMD-ish cells); the `MapPort` grant set (add a `PROT_EXEC` port
  for the separate RWX *code* region); an optional `(refine I64 (<= end))` on
  `cur` to make the invariant a proof obligation instead of a runtime `if`.
- **Deliberately omitted:** the actual `nb-sys-mmap` syscall wiring and errno
  band check (a syscall milestone); `munmap`/teardown; the RWX code mapping
  (`mprotect` to `R|X`, a distinct region); the `[tag][field0…]` cell payload
  layout (the boxed-data element); multi-arena nesting.

## 6. Use / modify notes

- **Lands in:** the bump allocator becomes `lib/arena.chiral` (chirality-authored,
  `->` pure) over the **already-self-hosted** mapping (`_map_rw` →
  `nb-sys-mmap`, in place since the E20 mechanism refactor); the remaining
  `native.py` rewiring is the arena *setup* (`_map_rw(ARENA_BYTES)` + the
  heap-cell pokes, `native.py:476–480`) routing through the typed layer, behind
  the `MapPort` grant.
- **Conformance target:** reproduce the loader's observable behavior — a
  `1<<20`-byte anonymous RW region, 8-byte-aligned bump, a monotonically
  increasing sequence of non-overlapping in-region pointers, and exhaustion at
  exactly the point where `native.py` faults (`heapptr > heapend`), but yielded
  as `a-err` rather than `ud2`/`MemoryError`.
- **Open questions:** does exhaustion stay a returned `a-err`, or does the
  emitter keep `ud2` as the *floor* with `a-err` only at the typed layer? Is the
  `<= end` invariant enforced by refinement (E9) or by the explicit guard? Where
  does the pointer's "belongs to this arena" evidence live once cells are boxed?
  And — the question E20's audited SPEC explicitly defers here — does `Arena`
  stay a plain data value threaded `q=1` by signature discipline (as in §5:
  both fields are ω I64s, so the *type* is not linear-kind and a careless caller
  could bind one at ω), or does it become its own **porttype** so linear-kind
  (E8) makes the threading structural?
- **Related:** [[E21-arena]] — feeds the boxed-data-cell and Str/Bytes-cell
  elements (same arena), the syscall-milestone element (`nb-sys-mmap`), and E26
  alarms (errors-as-values, the `a-err` path).
