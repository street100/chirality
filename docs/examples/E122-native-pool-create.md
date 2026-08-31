---
element: E122
slug: native-pool-create
title: "Native `pool-create` mint: size → `PoolR` via memfd→ftruncate→mmap, box the `[base|size]` cell + assemble `(pool-r cell fd)`"
kind: BUILD-PROPER
reference_class: OURS
ours_source: scaffold/chirality/impl_ports.py:267 (_poolcreate)
status: drafted
updated: 2026-08-12
---

# E122 — Native `pool-create` mint (size → `PoolR`)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E122 — the native lowering of `pool-create`: take a byte `size`,
  cross `memfd_create`→`ftruncate(size)`→`mmap(fd,size)`, box the resulting
  `[base|size]` cell, and assemble a `Pool` = `(pool-r cell fd)` that carries the
  memfd `fd` as a *second, separate linear field*.
- **Kind:** BUILD-PROPER — `pool-create` is oracle-only today (`_poolcreate`,
  `impl_ports.py:267`); there is no `crossing-wraps` entry and no `nb-pool-create-t`
  TAL body. E28 already ships the `nb-sys-memfd` / `nb-sys-ftruncate` /
  `nb-sys-mmap` crossings this mint composes.
- **Why chirality needs its own:** this is the **native mint** the rest of the pool
  family gates on. Split from E120 (2026-08-12, which now owns write/read/close);
  E120/E107/E111/E113 all need a natively-created `Pool` to run without the Python
  oracle. Minting the pool value natively is the step that lets a pool exist at
  all in a native run.

## 2. Research

- **Reference class:** OURS — `_poolcreate` in `impl_ports.py:267`, the
  `Pool`/`pool-create` surface in `ports.chiral`, `crossing-wraps.chiral`, and the
  E28 `mmap`/`memfd`/`ftruncate` crossings named in the catalog row.
- **Key findings:**
  1. **Three ordered crossings, no rollback in the oracle.** `_poolcreate` does
     `memfd_create("chirality-pool", 0)` → `ftruncate(fd, size)` → `mmap(fd, size)`,
     strictly in that order. The oracle leaks on partial failure (a raised
     `ftruncate`/`mmap` never closes the fd) — the native mint should decide
     whether to mirror that or clean up (see §6).
  2. **The return is a two-linear-field record.** The Python value is
     `("con", "pool-r", [("pool", mm, size), ("fd", fd)])` — the mapped cell and
     the memfd fd are *distinct* fields, not one handle. The fd outlives creation
     because `ftruncate`/growth may need it and close is a separate op (`fd-close`).
  3. **The cell is `[base|size]`, 16 bytes.** Native, this is a boxed cell:
     `ti-bnew 16`, then `nb-put-u64` at offset 0 (base pointer) and offset 8
     (size). That is exactly the shape `pool-write`/`pool-read` (E120) index into.
  4. **`size<=0` is rejected at the gate.** The oracle raises `PortError`; chirality
     mirrors that as the **arena-fail shape** — `nb-arena-fail(errno)` (`exit_group`,
     "honest fail, never returns", `sys-tal.chiral:118`), matching E120 + the arena's
     allocation-failure discipline. The extern's return type `(PoolR n)` has **no
     error arm**; failure is fatal control flow, not a value.

## 3. Conventional (other-language) approach

The OURS Python — one function, three unchecked effects, an exception for the
bad-size gate:

```python
@impl("pool-create")
def _poolcreate(size):
    if size <= 0:
        raise PortError("pool-create: size must be positive")
    fd = os.memfd_create("chirality-pool", 0)   # crossing 1
    os.ftruncate(fd, size)                   # crossing 2
    mm = mmap_mod.mmap(fd, size)             # crossing 3
    return ("con", "pool-r", [("pool", mm, size), ("fd", fd)])
```

- **Assumptions it bakes in:**
  - **Untyped, ambient effects** — three syscalls with no capability in scope; the
    function's type says nothing about the fact that it touches the kernel.
  - **Exceptions for the bad-size path** — the failure is control flow, invisible
    to the caller's type.
  - **No linearity on the returned resources** — nothing forces the `mm` cell to
    be munmap'd or the `fd` to be closed exactly once; leak-on-partial-failure is
    silent, and double-close/use-after-free are untyped.
  - **Ambient allocation** — `mmap`'s result is an opaque Python object, not a
    chirality-owned `[base|size]` cell with a known layout.

## 4. The chirality idea

- **Chirality features in play:** QTT linearity (the `Pool` cap and the fd are `1`-use
  resources), the `->`/`=>` effect membrane (creation *crosses*, so `=>`),
  categories B/C (raw syscalls are B; the typed `Pool` over the untyped mapping is
  a **C bridge**), and the native TAL lowering (`crossing-wraps` row +
  `nb-pool-create-t`).
- **The reframing:** `pool-create` returns a single-con record `(PoolR n)` =
  `(pool-r (1 pool (Pool n)) (1 fd Fd))` (`ports.chiral:34,73`) holding **two linear
  fields**: the opaque `Pool n` cap (its runtime witness is the boxed `[base|size]`
  cell) and the memfd `fd`. Because both are `1`-use, the checker forces exactly one
  `pool-close` (munmap) and one `fd-close`; dropping either, or reading after close,
  is untypeable. There is **no error arm** — on `size<=0` or any crossing `<0`,
  creation takes the **arena-fail shape** (`nb-arena-fail(errno)` → `exit_group`,
  `sys-tal.chiral:118`), the same fatal-control-flow path the arena uses for
  allocation failure. (A *recoverable* result-sum `pool-create` is the
  boundary-sums ideal but reshapes the whole pool family — deferred, see §6.)
  Natively the cell is a real 16-byte box (`ti-bnew 16` + two `nb-put-u64`), the
  same layout E120's write/read index into — the C bridge is a typed cap over the
  untyped mmap referent.
- **What chirality makes impossible here:** no ambient crossing (creation's effect row
  is a typed fact, not a hidden `os.` call), no leaked/double-freed pool (linearity
  forces balanced close), and no opaque handle (the pool is a chirality-owned cell).
  Failure is an honest fatal exit (kernel reclaims the memfd + mapping), never a
  silent leak like the oracle's raise-past-the-fd.

## 5. Chirality example (fleshed)

```chirality
(import "prelude")

; --- Surface: the create-result record ------------------------------------
; `Pool n` is the opaque linear porttype (the mapped region), from ports.chiral.
; `PoolR` is the single-con record pool-create returns: the linear `Pool n` cap
; (its runtime witness = the boxed [base|size] cell) + the memfd fd, two SEPARATE
; 1-use fields (mirroring the oracle's ("pool", mm, size) + ("fd", fd)). Both
; 1-use ⇒ balanced close by construction. NO error arm (ports.chiral:34).
(data PoolR ((n I64))
  (pool-r (1 pool (Pool n))   ; the mapped region cap — linear
          (1 fd   Fd)))       ; memfd fd, closed separately by fd-close — linear

; Creation CROSSES (memfd/ftruncate/mmap) ⇒ process arrow `=>`, nonempty row.
; The <=0 case + any crossing failure take the arena-fail shape below — the
; return type (PoolR n) has no error arm (ports.chiral:73).
(declare pool-create (=> (w n I64) (PoolR n)))

; --- Native TAL body: nb-pool-create-t ------------------------------------
; crossing-wraps row binds the surface `pool-create` to this native body,
; over E28's nb-sys-memfd / nb-sys-ftruncate / nb-sys-mmap.
;   crossing-wraps: (pair "pool-create" "nb-pool-create")
(def nb-pool-create-t
  (lam (size)
    ; gate: reject size<=0 via arena-fail (exit_group, never returns) — mirrors
    ; _poolcreate's PortError; the arena's own allocation-failure discipline.
    (if (nb-i<= size 0)
        (nb-arena-fail -22)                                   ; -EINVAL, exit_group
      (let ((fd   (nb-sys-memfd "chirality-pool" 0)))             ; crossing 1
        ; any crossing <0 ⇒ nb-arena-fail(errno) → exit_group; the kernel
        ; reclaims the memfd + mapping on exit (no leak, nothing to return).
        (let ((_    (nb-sys-ftruncate fd size))               ; crossing 2
              (base (nb-sys-mmap fd size)))                    ; crossing 3
          ; box the [base|size] cell: 16-byte box, base@0, size@8 — this cell
          ; IS the runtime witness of the (Pool n) cap.
          (let ((cell (ti-bnew 16)))
            (nb-put-u64 cell 0 base)
            (nb-put-u64 cell 8 size)
            ; assemble the single-con (pool-r cell fd) — fd its own linear field
            (pool-r cell fd)))))))
; …  errno-decoding of the crossing returns elided (mechanical) …
```

- **Knobs to modify:** the memfd name/flags passed to `nb-sys-memfd`; the cell
  layout width (16 → wider if a generation/refcount word is added); the
  refinement on `size` (e.g. page-alignment); whether `pool-create` takes an
  explicit `MemCap`/allocator capability (see §6).
- **Deliberately omitted:** E120's `pool-write`/`pool-read`/`pool-close` and
  `fd-close` bodies (they *consume* this `Pool`); the errno→arena-fail decoding of
  each crossing's raw return (mechanical); the exact `ti-bnew`/`nb-put-u64` opcode
  emission (that is the `emit-instr` layer, not this mint).

## 6. Use / modify notes

- **Lands in:** the `crossing-wraps.chiral` row + a `nb-pool-create-t` TAL body
  (native lowering, alongside the E28 sys crossings); the `Pool`/`PoolR` surface
  in `ports.chiral`. No change to `scaffold/chirality/impl_ports.py` (that stays the
  oracle).
- **Conformance target:** for `size>0`, produce a `Pool` byte-identical in layout
  to what `_poolcreate` returns — a 16-byte `[base|size]` cell (base@0, size@8)
  plus the memfd `fd` as a separate linear field — such that an E120
  `pool-write`/`pool-read` round-trips through it. For `size<=0`, take the
  arena-fail exit (no crossing performed), matching the oracle's rejection.
- **Decisions (resolved in the SPEC):**
  1. **Partial-failure — arena-fail, no result value.** `PoolR` has no error arm
     (`ports.chiral:34`), so on `size<=0` or any crossing `<0` the mint calls
     `nb-arena-fail(errno)` → `exit_group` (`sys-tal.chiral:118`); the kernel
     reclaims the memfd + mapping on exit, so no explicit cleanup and no `pool-err`
     value are needed. (A *recoverable* result-sum `pool-create` is the
     boundary-sums ideal but reshapes the extern + oracle + E120 — DEFERRED.)
  2. **Capability parameter — DEFERRED.** The E28 sys crossings stay category-B
     substrate externs (matching the arena + all current memory crossings); a
     `MemCap`/allocator port is a rung-2 capability-arc refactor, surfaced not
     dropped.
  3. **Crossing-return typing — boundary inside `nb-pool-create-t`.** The body
     decodes each raw `nb-sys-*` I64 return (negative = errno → arena-fail) and
     constructs the single-con `(pool-r cell fd)`, so surface code never sees a
     sentinel.
- **Related:** [[E120-native-pool-io]] (write/read/close — consumes this Pool),
  [[E28-mmap-memfd-crossings]] (the sys crossings this composes), [[E107]],
  [[E111]], [[E113]] (native-run gaters).
