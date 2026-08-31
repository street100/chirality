---
element: E28
slug: mmap-crossings
title: `mmap`/`munmap`/`mprotect`/`close` as sys crossings
kind: REPLACE-CRUTCH
reference_class: SPEC/IMPL
ours_source: scaffold/chirality/impl_ports.py
status: drafted
updated: 2026-07-13
---

# E28 — `mmap`/`munmap`/`mprotect`/`close` as sys crossings

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E28, the four memory/fd syscalls (`mmap`/`munmap`/`mprotect`/
  `close`) reframed as **typed membrane crossings** that hand back a *linear
  mapping capability* instead of a raw address.
- **Kind:** REPLACE-CRUTCH — today `impl_ports.py` reaches straight into CPython
  `mmap`/`os.memfd_create`/`os.close` behind the port membrane (the `("pool", mm,
  size)` runtime value). That ctypes/CPython convenience is the crutch to shed.
- **Why chirality needs its own:** these are the **Category-B floor** — the untyped OS
  referent every higher module (the loader, the memfd pool, a future JIT page)
  stands on. chirality must own a **Category-C bridge** over them so a mapping's
  lifetime, bounds, and W^X protection are *proven in the type*, not enforced by a
  Python comment (`# zeroize before release`, `impl_ports.py:207`). Shedding the
  crutch shrinks the TCB to one audited `extern` face.

## 2. Research

- **Reference class:** SPEC/IMPL — the Linux syscall ABI + musl's thin wrappers,
  read against the OURS `pool-create`/`pool-close`/`pool-write`/`fd-close` slice.
- **Key findings:**
  - **The ABI signals failure by sentinel, not by value.** `mmap(2)` returns
    `MAP_FAILED` (`(void*)-1`) and sets `errno`; `munmap`/`mprotect` return `-1`.
    There is no typed error channel — the classic partiality chirality refuses. The
    bridge must turn the sentinel into an explicit result sum at the seam.
  - **W^X is an idiom the ABI cannot enforce.** `prot` is a free bitmask
    (`PROT_READ|WRITE|EXEC`); a page can legally be `W|X`. Hardened kernels reject
    it *at runtime*, so the safe pattern is **map `RW` → fill → `mprotect` to
    `RX`**. Nothing types-checks that you never held both — exactly the invariant
    chirality can lift into the type.
  - **A mapping is a linear resource with a page-aligned extent.** `[base,
    base+len)` must be unmapped **exactly once**; double-`munmap` or touch-after-
    `munmap` is UB. `len` must be `> 0` and page-multiple. The OURS pool pairs an
    `mmap` with a **memfd** (`memfd_create`+`ftruncate`), so `close` of the fd is a
    *second* linear resource with its own once-only lifetime.
  - **Drop carries a hygiene obligation.** OURS zeroizes the whole region before
    `mm.close()` (`impl_ports.py:209`). That "scrub on release" is a property of
    the *drop*, not the syscall — a natural fit for a linear type's consume rule.

## 3. Conventional (other-language) approach

The OURS Python — a memfd-backed pool behind the port membrane:

```python
@impl("pool-create")
def _poolcreate(size):
    if size <= 0:
        raise PortError("pool-create: size must be positive")
    fd = os.memfd_create("chirality-pool", 0)
    os.ftruncate(fd, size)
    mm = mmap_mod.mmap(fd, size)              # untyped effect, ambient
    return ("con", "pool-r", [("pool", mm, size), ("fd", fd)])

@impl("pool-write")
def _poolwrite(_n, pv, off, data):
    _, mm, size = pv
    if off < 0 or off + len(data) > size:     # bounds checked by hand, at runtime
        raise PortError("pool-write out of bounds")
    mm[off:off + len(data)] = data
    return pv

@impl("pool-close")
def _poolclose(_n, pv):
    _, mm, size = pv
    mm[:size] = b"\x00" * size                # hygiene by convention (a comment)
    mm.close()                                # nothing stops a second close
    return UNIT
```

- **Assumptions it bakes in:** untyped effects (`mmap` callable from anywhere, no
  capability gates it); a raw address / live `mm` object copyable and reusable
  after `close` (use-after-free is a runtime crash, never a type error);
  **mprotect / W^X simply absent** — there is no protection state at all; bounds
  and `size > 0` re-checked by hand each call and failing via `raise`; the
  zeroize-on-drop rule enforced only by a comment and programmer discipline.

## 4. The chirality idea

- **Chirality features in play:** QTT linearity (`1`) for the mapping and fd
  capabilities; the `->`/`=>` effect membrane; errors-as-values result sums;
  refinement types for `len`; the float→I64 wall (addresses/lengths are `I64`);
  Category-C bridge over the Category-B `extern` syscall face.
- **The reframing:** a live mapping becomes a **linear `Map` capability** carrying
  `base`, a **refined** `len (> 0)`, and its **`Prot` protection level**. `mmap`
  is a **`=>` process crossing** that is the *only* way to mint one — no ambient
  authority. `munmap` and `close` **consume** their capability (quantity `1`), so
  the checker rejects double-free and use-after-free outright. `mprotect` is
  modelled as **consume-RW / mint-RX**: it eats the writable `Map` and hands back a
  fresh executable one, same extent, new protection — so **W^X falls out of the
  type**: no value is ever both writable and executable. The `MAP_FAILED` sentinel
  is collapsed at the seam into an explicit `MapR` result the caller must `case`.
- **What chirality makes impossible here:** holding a `Map` after `munmap`; unmapping
  twice; writing through a sealed (`prot-rx`) mapping; calling `mmap` without
  crossing the membrane; forgetting the failure branch; letting an address leak as
  a float.

## 5. Chirality example (fleshed)

```chirality
(import "prelude")
(import "sys")   ; Category-B extern face — the raw, trusted syscall crossings

; ---- typed protection level: W^X is encoded, not hoped -------------------
(data Prot ()
  (prot-rw ())      ; readable + writable   (never executable)
  (prot-rx ()))     ; readable + executable (never writable)

; ---- a live mapping is a LINEAR capability: extent + protection ----------
; holding one is authority over [base, base+len). It is consumed exactly once
; (by munmap). No copy, no drop, no reuse — use-after-free is untypeable.
(data Map ()
  (mapping (base I64) (len (refine I64 (> 0))) (prot Prot)))

; ---- errors are VALUES: the MAP_FAILED sentinel dies at the seam ---------
(data MapR () (map-ok (m Map)) (map-err (errno I64)))
(data SysR () (sys-ok ())      (sys-err (errno I64)))
(data AddrR () (addr-ok (a I64)) (addr-err (errno I64)))

; ---- Category-B externs (untyped referent, trusted binding) --------------
(extern sys-mmap     (=> (len I64) (prot I64) AddrR))
(extern sys-munmap   (=> (addr I64) (len I64) SysR))
(extern sys-mprotect (=> (addr I64) (len I64) (prot I64) SysR))
(declare prot-flags  (-> Prot I64))  ; pure: Prot -> PROT_* bitmask (no I/O)

; ---- mmap: the ONLY minter of a Map. a => crossing, no ambient authority --
(declare mmap-rw (=> (len (refine I64 (> 0))) MapR))
(def mmap-rw
  (lam (len)
    (case (sys-mmap len (prot-flags (prot-rw)))
      ((addr-ok base) (map-ok (mapping base len (prot-rw))))
      ((addr-err e)   (map-err e)))))

; ---- munmap: CONSUMES the map (quantity 1). double-free won't typecheck ---
(declare munmap (=> (1 m Map) SysR))
(def munmap
  (lam (m)
    (case m
      ((mapping base len _) (sys-munmap base len)))))

; ---- seal-exec (mprotect RW->RX): eat the writable map, mint an exec one --
; W^X is structural: you cannot hold a Map that is both writable and executable.
(declare seal-exec (=> (1 m Map) MapR))
(def seal-exec
  (lam (m)
    (case m
      ((mapping base len _)
        (case (sys-mprotect base len (prot-flags (prot-rx)))
          ((sys-ok)    (map-ok (mapping base len (prot-rx))))
          ((sys-err e) (map-err e)))))))

; ---- write: only reachable while still prot-rw; threads the linear Map ----
; the prot-rx branch is unwritable — a sealed page rejects the store.
(declare map-write (=> (1 m Map) (off (refine I64 (>= 0))) Bytes Map))
(def map-write
  (lam (m off src)
    (case m
      ((mapping base len (prot-rw)) (mapping base len (prot-rw))) ; ; … store src
      ((mapping base len (prot-rx)) m))))                          ; no-op: sealed
```

- **Knobs to modify:** the `Prot` set (add `prot-r` read-only, or a `guard`
  page); index `Map` by an **erased** `(0 P (type 0))` Prot param so `map-write`
  only *type-checks* on the `prot-rw` variant (turns the runtime `case` above into
  a proof); back the mapping with a memfd `Fd` capability (add `(data Fd () (fd
  (raw I64)))` + `(declare close (=> (1 f Fd) SysR))`) to reproduce the OURS pool;
  tighten `len` with an upper page-count bound; add a zeroize obligation to
  `munmap` for the scrub-on-drop hygiene.
- **Deliberately omitted:** page-alignment arithmetic on `base`/`len`; the memfd
  create/ftruncate pair (fd side); the byte-copy loop inside `map-write` (elided
  `; …`); `MAP_SHARED`/file-backed mappings; per-errno decoding beyond the raw
  `I64`.

## 6. Use / modify notes

- **Lands in:** `lib/mem.chiral` (the typed Category-C face) declaring the `extern`
  crossings that `scaffold/chirality/impl_ports.py`'s `pool-*`/`fd-close` binds behind
  the port membrane; the four `sys-*` externs are the audited Category-B floor.
- **Conformance target:** reproduce the OURS pool round-trip — `mmap-rw size` →
  `map-write off bytes` → read back → `munmap` — byte-for-byte, plus the OURS
  `size > 0` guard (now the `(refine I64 (> 0))`) and bounds check (now the
  `(refine I64 (>= 0))` offset), and the zeroize-before-release scrub. New golden
  behavior beyond OURS: `seal-exec` then attempt-to-write must be a **type error**,
  and a second `munmap m` must **fail to typecheck** (linear reuse).
- **Open questions:** does `seal-exec` returning a *fresh* `Map` (rather than
  mutating in place) confuse a later JIT that cached the old base? (No — same
  `base`, so the address is stable; only the type changes.) How is the
  zeroize-on-drop obligation expressed — a special `munmap` variant, or a general
  linear-`drop` hook? Does the memfd `Fd` need to outlive the `Map` (it does not,
  once mapped) — encode that ordering or leave it to the pool wrapper?
- **Related:** [[E30-fd-passing]] (sends an `Fd` capability across a socket — same
  linear-cap discipline), [[E26-alarms]] (the result-sum error model used here),
  [[E33-process-spawn]] (socketpair+fork consumes fd caps).
