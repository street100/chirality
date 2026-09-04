---
element: E20
slug: loader
title: "Loader: RW mmap -> W^X mprotect -> executable"
kind: REPLACE-CRUTCH
reference_class: SPEC   # mmap/mprotect man pages; JIT loaders (SPEC/IMPL)
ours_source: scaffold/chirality/native.py
status: drafted
updated: 2026-09-03
---

# E20 — Loader: RW mmap -> W^X mprotect -> executable

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E20, the loader that maps fresh memory read-write, blits the
  emitted machine code into it, then flips that region to read-execute so a real
  `call` can enter it — the last step of the trusted drop (emitter output ->
  live CPU).
- **Kind:** REPLACE-CRUTCH. **Build-state note (updated 2026-08-01):** the
  syscall *mechanism* is already self-hosted. `lib/sys-tal.chiral` ships all nine
  crossings including `nb-sys-mprotect` (nr 10, built by **E28**, 2026-07-28,
  `sys-tal.chiral:101`); `native.py`'s ctypes `_mprotect` shim and the `mmap`
  module are **gone**, and `compile()`'s W^X seal is issued through the chirality
  crossing (the **E20 mechanism refactor**, 2026-07-29 — CONFORMANCE-MAP: "Memory
  fully chirality-side"). What this example proposes on *top* of that — the typed
  `MapRW`/`MapRX` loader that makes W^X a **type fact** — is **unbuilt**
  (`lib/loader.chiral` does not exist; no `MapRW`/`MapRX` porttype anywhere).
- **Why chirality needs its own:** it is the last host crutch between "chirality emitted
  these bytes" and "the CPU ran them." The syscalls are now self-hosted, but the
  W^X invariant (never executable-while-writable) is **still** enforced by the
  *ordering* of a few imperative lines in `native.py`'s `compile()`
  (`native.py:454–468`: mmap-RW → `ctypes.memmove` blit → `nb-sys-mprotect` seal
  over a raw int `base` — nothing structurally forbids a write after the seal),
  not by anything the checker holds. Lifting that invariant into the type is the
  remaining work, and shrinks the TCB to the codegen itself.

## 2. Research

- **Reference class:** SPEC — the `mmap(2)` / `mprotect(2)` Linux ABI, plus the
  standard JIT-loader shape (IMPL, clean-room: describe the move, copy no code).
  Grounded against our own `native.py` baseline and the already-built
  `lib/sys-tal.chiral` crossings.
- **Key findings:**
  - The W^X loader move is three syscalls in order: `mmap(NULL, len,
    PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0)` -> write the code ->
    `mprotect(base, len, PROT_READ|PROT_EXEC)`. Never map `PROT_WRITE|PROT_EXEC`
    at once. `base` is page-aligned by mmap; `len` rounds up to a page.
  - `PROT_READ=1, PROT_WRITE=2, PROT_EXEC=4`; on x86-64 `mprotect` is syscall
    **nr 10** (all-integer args in `rdi/rsi/rdx`) — the same `ti-sys` shape the
    other crossings in `sys-tal.chiral` use, and **now built** as `nb-sys-mprotect`
    (`sys-tal.chiral:101`, E28).
  - `native.py`'s `compile()` keeps the **arena** mapping read-write after sealing the code:
    code + read-only literals become RX, but the emitted `heapptr`/`heapend`
    cells stay RW because the running code bumps them. So there are *two*
    mappings with *different* final protections — a natural fit for two distinct
    linear values.
  - The floor is **complete**: `sys-tal.chiral` ships `nb-sys-mmap` (nr 9),
    `munmap` (nr 11), `memfd` (nr 319), `ftruncate` (nr 77), and — since E28 —
    `mprotect` (nr 10). No crossing is missing; what is unbuilt is the *typed
    loader layer* above them (this example's subject).

## 3. Conventional (other-language) approach

How this is done outside chirality — the conventional JIT-loader shape, shown as the
**pre-refactor** `native.py` (the ctypes `_mprotect` helper, since retired by the
E20 mechanism refactor; kept here because its *type-unsafety* — the writable `buf`
outliving the seal — is exactly what the typed loader below removes):

```python
# map read-write, write the code, then mprotect the code region to read-execute
buf = mmap.mmap(-1, max(len(code), 1),
                prot=mmap.PROT_READ | mmap.PROT_WRITE)
buf.write(code)
base = ctypes.addressof(ctypes.c_char.from_buffer(buf))
...                                  # (arena mmap'd separately, stays RW)
code_end = offsets.get("heapptr", (len(code) + _PAGE - 1) & ~(_PAGE - 1))
_mprotect(base, code_end, _PROT_READ | _PROT_EXEC)   # ctypes -> libc.mprotect
# `buf` the ctypes object is STILL a live writable handle to those same pages
```

- **Assumptions it bakes in:** ambient mutable memory (nothing stops a later line
  from writing `buf` again after the mprotect — the writable handle outlives the
  seal); the W^X invariant is a *comment* ("never executable-while-writable"),
  upheld by call order, not by the type; a raw integer `base` address with no
  witness of its protection state; a nonzero `mprotect` return handled as an ad
  hoc `OSError` rather than a typed alarm; and libc/ctypes in the trust path.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** port types & capabilities (P3/P3 — the `porttype`
  category-C boundary of `lib/ports.chiral`), QTT linearity (move-only quantity
  1), the effect membrane (`=>` process, since mapping and protecting are
  crossings), erased type indices (quantity 0 for the page-count bound), and the
  typed alarm effect (`halt`).
- **The reframing:** make the protection state part of the *type* of the
  mapping. A writable region and an executable region are **two different
  linear port types** — `MapRW` and `MapRX`. `mprotect` is not a mutation of a
  shared address; it is a crossing that **consumes** the linear `MapRW` handle
  and **produces** a `MapRX` handle. Because the input is linear (used exactly
  once), the moment you seal the region to executable you no longer hold any
  writable view of it. W^X stops being a discipline and becomes a fact the
  checker enforces. The arena, a *separate* `MapRW` value, simply is never
  sealed — so "code RX, arena RW" falls straight out of holding two values.
- **What chirality makes impossible here:** there is no `PROT_WRITE|PROT_EXEC` value
  to construct, and no way to retain the writable handle after sealing — the
  `buf`-still-writable-after-mprotect hole in the Python is unrepresentable. You
  cannot even *name* an executable-and-writable mapping.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")
(import "ports")

; Protection state lives in the TYPE: a mapping is EITHER writable OR
; executable, never both. Two opaque linear port types (category C boundary,
; like ports.chiral's Sock/Pool); n = page count, an erased (0) type index.
(porttype MapRW (n I64))          ; page-aligned, PROT_READ|PROT_WRITE
(porttype MapRX (n I64))          ; PROT_READ|PROT_EXEC -- no writable alias exists

; mmap n fresh anonymous pages, read-write only. `w` = a runtime witness that
; also flows into the type index (cf. pool-create). Lowers to nb-sys-mmap with
; PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, fd -1.
(extern map-rw (=> (w n I64) (MapRW n)))

; blit code bytes at an offset into the writable mapping; thread it back
; (linear: you cannot write without moving the handle onward).
(extern map-write (-> (0 n I64) (=> (1 m (MapRW n)) I64 Bytes (MapRW n))))

; the W^X hinge: mprotect the region RW -> RX (nr 10, PROT_READ|PROT_EXEC).
; It CONSUMES the writable handle and hands back an executable one. After this
; call no writable view of these pages is reachable -- the seal is structural.
; A nonzero mprotect return is a loader alarm (halt), not a sentinel.
(extern seal-exec (-> (0 n I64) (=> (1 m (MapRW n)) (MapRX n))))

; result of a load: the sealed code region and the still-writable arena,
; both linear -- the arena stays RW because running code bumps its heap cells.
(data Loaded ((c I64) (a I64))
  (loaded (1 code (MapRX c)) (1 arena (MapRW a))))

; the loader: take emitted bytes and a live arena, map+write+seal the code,
; and hand back both regions. This is native.py's compile() W^X sequence with
; the invariant moved into the types.
; NOTE the quantities: `c` is a RUNTIME witness (w) because map-rw consumes it
; at runtime (mmap needs the page count) -- the pool-create pattern, where the
; witness also flows into the type index. `a` stays erased (0): it appears
; only inside types, never at a runtime position.
(def load-batch
  (-> (w c I64) (0 a I64)
      (=> Bytes (1 arena (MapRW a)) (Loaded c a)))
  (lam (c a code arena)
    (loaded
      ; map-rw -> map-write CONSUMES it -> seal-exec CONSUMES that: the writable
      ; handle is threaded straight into the seal and never bound again.
      (seal-exec c (map-write c (map-rw c) 0 code))
      arena)))                     ; arena is a distinct value -> never sealed -> stays RW
```

- **Knobs to modify:** the page-count witness `c`/`a`; swap `map-rw`'s backing
  from `MAP_ANONYMOUS` to a memfd-backed shared mapping (add a `MapShared`
  porttype and route through `nb-sys-memfd`/`ftruncate`) when the region must be
  handed to a peer; add a `map-write` offset table if code and literals need
  separate spans; parameterize the final PROT if a data-only RO section is wanted
  (add a `seal-ro : MapRW -> MapRO`).
- **Deliberately omitted:** arena creation and the bump-allocator wiring (that is
  [[E21-mmap-arena]]); relocation / offset-table application (the emitter's job,
  [[E19-x64-codegen]]); page-alignment arithmetic (mmap guarantees it, so it is
  not surfaced); `munmap` teardown (the region drops as a unit — a `map-close`
  extern, elided to keep the seal the star); calling into `MapRX` at a function
  offset (a `map-enter` crossing left for the implementation run).

## 6. Use / modify notes

- **Lands in:** a new `lib/loader.chiral` (the `MapRW`/`MapRX` porttypes +
  `load-batch`) that the backend calls, plus rewiring the imperative W^X block of
  `NativeBackend.compile` (`native.py:454–468`) to go through it. The tal-floor
  crossing it needs, `nb-sys-mprotect` (nr 10), **already exists**
  (`sys-tal.chiral:101`, E28), and `native.py`'s ctypes `_mprotect` helper is
  **already retired** — so this element is no longer "add the crossing" but "lift
  the already-self-hosted W^X *mechanism* into the *type* via the typed loader."
- **Conformance target:** reproduce `native.py`'s golden behavior — map RW,
  write the emitted `code`, seal the code span (through `heapptr`, or `len`
  rounded to a page) to RX, leave the arena RW — such that a real call into
  `base + offsets[name]` returns exactly what `tal.TalMachine` and the host
  prims return (the differential test in `tests/test_native.py`).
- **Open questions:** does `seal-exec` seal the whole mapping or a sub-span up to
  the page-aligned `heapptr` (native.py does the latter when a heap exists)? —
  likely a second erased length index on `MapRX`. How is the `mprotect` -errno
  return threaded into a typed alarm at the crossing vs. inside `seal-exec`? Does
  the arena mapping want its own porttype distinct from `MapRW` to forbid ever
  sealing it by mistake?
- **Related:** [[E21-mmap-arena]] (the arena this loader hands back),
  [[E28-sys-crossings]] (`mmap`/`munmap`/`mprotect`/`close` as sys crossings),
  [[E19-x64-codegen]] (produces the `code` bytes loaded here).
