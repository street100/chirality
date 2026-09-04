---
element: E120
slug: native-pool
title: Native `Pool` representation — wire `pool-write`/`pool-read`/`pool-close` to native over the arena's mmap machinery
kind: BUILD-PROPER
reference_class: OURS
ours_source: scaffold/chirality/impl_ports.py
status: drafted
updated: 2026-08-12
---

# E120 — Native `Pool` representation

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E120 — give the linear `Pool (n I64)` cap a *native runtime
  witness* (an mmap base + size) and add the `crossing-wraps`/`sys-linkage`
  entries so its three ops (`pool-write`, `pool-read`, `pool-close`) lower to a
  native ELF run instead of only running under the Python oracle
  (`impl_ports.py`).
- **Kind:** BUILD-PROPER (a designed feature not yet built — the crossings have
  no lowering today).
- **Why chirality needs its own:** the `pool-*` ops are the only `Pool` operations
  and they are oracle-only — `crossing-wraps.chiral` has **no** `pool-*` row, so
  none of them reach machine code. E120 is the shared substrate that SYS·E107
  (`pool-close`), MEM·E111 (cell-store) and MEM·E113 (`pool-read`) each gate on
  for a native run: without a native `Pool` value none of those can lower.

## 2. Research

- **Reference class:** OURS — `scaffold/chirality/impl_ports.py` (the oracle pool
  impls), `scaffold/lib/ports.chiral` (the `Pool` porttype + `PoolR` +
  signatures), `scaffold/lib/crossing-wraps.chiral` (the crossing→wrapper table,
  E70/E105 shape), `scaffold/lib/sys-tal.chiral` (the native TAL bodies the arena
  already uses: `nb-sys-mmap`/`nb-sys-munmap`/`nb-sys-memfd`/`nb-sys-ftruncate`/
  `nb-sys-close`, plus `nb-arena-commit`/`nb-arena-grow` for how the region is
  acquired and boxed-cell reads/writes are expressed).
- **Key findings:**
  - **Host `Pool` value = `("pool", mm, size)`** (`impl_ports.py:8`, `272`). The
    region is a `memfd_create` → `ftruncate(size)` → `mmap(fd, size)`
    (`_poolcreate`, 270–273), returned wrapped as
    `("con","pool-r",[("pool",mm,size),("fd",fd)])` — i.e. `PoolR` carries the
    pool **and its memfd `fd` as two separate linear fields**
    (`ports.chiral:34`).
  - **The three op bodies are trivial over `(mm, size)`**: `_poolwrite`
    bounds-checks `off+len(data) > size` then `mm[off:off+len] = data`, returns
    the pool (287–292); `_poolclose` zeroizes `mm[:size]`, then `mm.close()`
    (277–283); there is **no `pool-read` oracle impl yet** (that extern is
    E113's — E120 designs its lowering shape, E113 mints the extern).
  - **`size` is the runtime witness of the erased type-level `n`.** The extern
    signatures pass the bound as an **erased** parameter —
    `pool-write : (-> (0 n I64) (=> (1 p (Pool n)) I64 Bytes (Pool n)))`,
    `pool-close : (-> (0 n I64) (=> (1 p (Pool n)) Unit))` (`lib/ports/pool.port:27`, `:31`)
    — so `n` is compile-time only; the store bound at runtime must come from a
    value carried *inside* the `Pool` (exactly the E113/E107 resolution, now
    native).
  - **The native mmap machinery already exists and is proven.** `nb-sys-mmap-t`
    (`sys-tal.chiral:99-102`) is `mmap(addr,len,prot,flags,fd,off)` returning the
    address; `nb-sys-munmap-t` (106-109) is `munmap(addr,len)`; the self-hosted
    arena drives `memfd → ftruncate → mmap → munmap` through these natively.
    E120 **reuses** this, it does not invent a new region primitive.
  - **The crossing table is a flat `(op → wrapper)` list** with a linear
    `cw-lookup` (`crossing-wraps.chiral:13-47`); `write-fd → nb-sys-write` (line
    35) is the E105 precedent for adding an op that fans out to a native TAL
    body. Adding `pool-*` is three new rows + three `nb-pool-*` TAL bodies +
    matching `sys-linkage` entries (the file's INVARIANT, lines 8-10).

## 3. Conventional (other-language) approach

Outside chirality a "pool" is just a mapped buffer with ambient bounds — the oracle
is the faithful transcription of the C `mmap`/memcpy/`munmap` idiom:

```python
# impl_ports.py — the oracle the native path must reproduce
@impl("pool-write")
def _poolwrite(_n, pv, off, data):
    _, mm, size = pv
    if off < 0 or off + len(data) > size:      # runtime bounds, hand-checked
        raise PortError(f"pool-write out of bounds: {off}+{len(data)} > {size}")
    mm[off:off + len(data)] = data             # ambient memcpy into the mapping
    return pv

@impl("pool-close")
def _poolclose(_n, pv):
    _, mm, size = pv
    mm[:size] = b"\x00" * size                 # zeroize (drop hygiene)
    mm.close()                                  # munmap the region
    return UNIT
```

- **Assumptions it bakes in:** the pool handle is an ambient Python object that
  can be aliased, re-read after close, or dropped without release; bounds are a
  hand-written `if` that raises (control flow, not a value); the size is a field
  a caller could ignore. Nothing structurally prevents use-after-free or a
  second write after close — the discipline is convention.

## 4. The chirality idea

chirality already refuses the alias/use-after-free freedoms *at the type floor* —
E120 only has to give that typed cap a **runtime body** that lowers.

- **Chirality features in play:** QTT linearity (`(1 p (Pool n))` — consumed exactly
  once, no drop/reuse), the effect membrane (`pool-create`/`write`/`close` are
  `=>` crossings; the erased `(0 n I64)` keeps the bound off the runtime), ports
  & capabilities (the `Pool` is authority, held not ambient), categories B/C (the
  raw mmap region is B; the typed `Pool` face over it is C), boundary sums (the
  bounds outcome is a returned value, never a raised exception).
- **The reframing:** the native `Pool` is a **base+size witness**, not an opaque
  object. Concretely a small **2-slot boxed cell** — `[base | size]` — where
  `base` is the `I64` address returned by `nb-sys-mmap` and `size` is the runtime
  bound (the witness of the erased `n`). Because `PoolR` already carries the
  memfd `fd` as its own linear field, the `Pool` cell itself needs *only* base +
  size; `pool-close` munmaps, `fd-close` closes the memfd. The three ops become
  thin TAL wrappers that unpack `[base|size]` and call the arena's existing
  `nb-sys-*` bodies — mirroring `write-fd → nb-sys-write` exactly.
- **What chirality makes impossible here:** the linear `(1 p (Pool n))` means the
  base+size witness is threaded once and surrendered on `pool-close`; there is no
  typed path to write after close or to read a dropped region — the
  use-after-free the C idiom leaves to convention is untypeable. Bounds are still
  a runtime check (the erased `n` cannot decide `off` statically), but its result
  is the ordinary error-as-value path, not a throw.

## 5. Chirality example (fleshed)

The three additions, copy-and-modify ready. **(a)** the `crossing-wraps` rows,
**(b)** the native TAL bodies that unpack the `[base|size]` cell and reuse the
arena's `nb-sys-*` crossings — modelled on `nb-sys-memfd-t`/`nb-arena-commit-t`
in `sys-tal.chiral`.

```chirality
; ---- (a) crossing-wraps.chiral: three new rows (mirror  write-fd -> nb-sys-write)
;         and the matching entries in sys-linkage.chiral `sys-bindings`.
(cons (pair "pool-write" "nb-pool-write")
(cons (pair "pool-read"  "nb-pool-read")     ; extern minted by E113; wrapper here
(cons (pair "pool-close" "nb-pool-close")
  ; ... rest of crossing-wraps ...
```

```chirality
; ---- (b) sys-tal.chiral: the native Pool value is a 2-slot cell [base | size].
;      A held (Pool n) IS a pointer to this cell; base+size is its runtime witness.
;      nb-put-u64/nb-get-u64 write/read an 8-byte slot at ptr+off+8 (boxed payload
;      offset), so slot 0 -> off 0, slot 1 (size) -> off 8  (see nb-arena-commit-t).

; pool-write : store `len` bytes from the Bytes cell into [base+off, base+off+len)
;   reg0 = pool-cell ptr   reg1 = off   reg2 = bytes-cell ptr
(def nb-pool-write-t TIFn
  (ti-fn "nb-pool-write" 3 12
    (t-seq (ti-const 3 0)
    (t-seq (ti-call 4 "nb-get-u64" (cons 0 (cons 3 nil)))   ; reg4 = base   (slot 0)
    (t-seq (ti-const 5 8)
    (t-seq (ti-call 6 "nb-get-u64" (cons 0 (cons 5 nil)))   ; reg6 = size   (slot 1)
    (t-seq (ti-prim 7 (op-blen) 2 2)                        ; reg7 = len(bytes)
    (t-seq (ti-prim 8 (op-add) 1 7)                         ; reg8 = off + len
      ; -- bounds: size < off+len  -> out-of-range (return a p-err sum) --
      (ti-tcase-bounds ...   ; off>=0 && off+len<=size, else error-as-value
        ; in range: dst = base + off ; memcpy len bytes from bytes-payload
        (t-seq (ti-prim 9 (op-add) 4 1)                     ; reg9 = base + off
        (t-seq (ti-bptr 10 2)                               ; reg10 = bytes payload addr
        (t-seq (ti-call 11 "nb-memcopy" (cons 9 (cons 10 (cons 7 nil)))) ; dst src len
          (ti-ret 0)))))))))))))                            ; return the (Pool n)

; pool-read : load `len` bytes from [base+off, ...) into a FRESH Bytes cell (E113)
;   reg0 = pool-cell ptr   reg1 = off   reg2 = len
(def nb-pool-read-t TIFn
  (ti-fn "nb-pool-read" 3 10
    ; ... symmetric bounds check on off+len <= size ...
    (t-seq (ti-bnew 5 2)                                    ; reg5 = fresh len-byte cell
    (t-seq (ti-call 4 "nb-get-u64" (cons 0 (cons (the I64 0) nil)))  ; base
    (t-seq (ti-prim 6 (op-add) 4 1)                         ; src = base + off
    (t-seq (ti-bptr 7 5)                                    ; dst = payload of new cell
    (t-seq (ti-call 8 "nb-memcopy" (cons 7 (cons 6 (cons 2 nil))))
      (ti-ret 5))))))))                                     ; return the Bytes cell

; pool-close : munmap(base, size)  (fd is discharged separately by fd-close).
;   reg0 = pool-cell ptr
(def nb-pool-close-t TIFn
  (ti-fn "nb-pool-close" 1 6
    (t-seq (ti-call 1 "nb-get-u64" (cons 0 (cons (the I64 0) nil)))  ; reg1 = base
    (t-seq (ti-call 2 "nb-get-u64" (cons 0 (cons (the I64 8) nil)))  ; reg2 = size
      ; (optional) zeroize [base, base+size) first -- drop hygiene, matches oracle
    (t-seq (ti-call 3 "nb-sys-munmap" (cons 1 (cons 2 nil)))         ; reuse arena crossing
      (ti-ret 3))))                                                   ; -> Unit

; and register the three bodies in the native TAL table alongside
; nb-sys-mmap-t / nb-sys-munmap-t (sys-tal.chiral:704-707).
```

- **Knobs to modify:** the cell layout (2 slots here; a 3rd could inline `fd` if
  a future `PoolR` merge wanted it); whether `pool-write`/`pool-read` call a
  shared `nb-memcopy` crossing or an inlined `ti-bget`/`ti-bput` byte loop; the
  bounds-error sum returned (reuse `PortError`-shaped `p-err`).
- **Deliberately omitted:** the exact `ti-tcase` bounds-branch wiring (sketched
  as `ti-tcase-bounds ...`), the `nb-memcopy` TAL body itself, and the
  register-allocation counts — mechanical, filled at implementation.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/crossing-wraps.chiral` (3 rows) +
  `scaffold/lib/sys-linkage.chiral` (matching `sys-bindings` — the file's stated
  INVARIANT) + `scaffold/lib/sys-tal.chiral` (3 `nb-pool-*-t` bodies + table
  registration). The typed faces in `scaffold/lib/ports.chiral` are unchanged
  (they already declare the externs).
- **Conformance target:** a native run reproduces the oracle
  (`impl_ports.py:_poolwrite`/`_poolclose`): a `pool-write off bytes` then
  `pool-read off len` round-trips the bytes; an out-of-range `off+len > size`
  yields the error-as-value (not a trap); `pool-close` munmaps the base+size and
  a subsequent op is untypeable (linearity). Byte-for-byte the fixpoint must
  still reproduce itself.
- **Open questions (genuine spec-stage decisions — not silently picked):**
  1. **Exact native `Pool` cell layout** — a 2-slot `[base|size]` boxed cell is
     proposed; a spec must fix whether it is a boxed cell (len header) or a raw
     16-byte slot, and confirm the reader offsets (`nb-get-u64` +8 payload
     convention, cf. `nb-arena-commit-t`'s `-8` compensation for raw slots).
  2. **`pool-write`/`pool-read` copy mechanism** — a shared generic `nb-memcopy`
     crossing vs an inlined `ti-bget`/`ti-bput` per-byte loop. There may be no
     existing memcopy TAL body; if not, one is a companion deliverable.
  3. **Who mints the native cell** — `pool-create` is *also* oracle-only today;
     a native round-trip needs it to build `[base|size]` from
     `nb-sys-memfd`→`nb-sys-ftruncate`→`nb-sys-mmap`. Whether that native
     `pool-create` lowering is in E120's scope or a stated dependency is a
     spec call (the three ops are inert without it).
  4. **`pool-read`'s extern** is E113's to declare; E120 provides the wrapper
     shape but the signature/quantities are settled there.
  5. **Zeroize-on-close** — whether the oracle's `mm[:size] = 0` drop hygiene is
     preserved natively before `munmap` (a bounded store loop) or dropped.
- **Ground truth note:** `pool-*` does **not** lower today (verified: no `pool`
  row in `crossing-wraps.chiral`, `cw-lookup` returns `none`), so a running native
  pool round-trip is **not** feasible until E120 implements — this example
  *designs* the lowering. The reused pieces (`nb-sys-mmap-t`/`nb-sys-munmap-t`,
  the boxed-cell `nb-get-u64`/`nb-put-u64`/`ti-bnew`/`ti-bptr` idioms) are
  already compiled and exercised by the self-hosted arena.
- **Related:** [[E107-pool-close]] · [[E111-cell-store]] · [[E113-pool-read]] ·
  the E105 `write-fd → nb-sys-write` crossing precedent.
