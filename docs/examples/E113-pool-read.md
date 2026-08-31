---
element: E113
slug: pool-read
title: `Pool` region read/peek crossing: `pool-read` (offset, len → `Bytes` + the threaded `(Pool n)` cap, memfd read in place) — the read companion to the existing `pool-write`, so a `Pool`-backed store (E111 Grid) supports O(1) indexed reads; shares the Pool-runtime-length question with E107 (`Pool n` is erased, but a bounded read needs the length at runtime)
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-11
---

# E113 — `Pool` region read/peek crossing (`pool-read`)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

> **⚠ OUTCOME NOTE (spec-audit 2026-08-12):** the §4/§5 **OOB-as-value** design
> below (two-arm `pread-r`/`pread-oob`) was **explored here but retired at
> spec-audit** — E120 had already shipped `pool-read` as **single-arm
> `(pr-r (bs Bytes) (1 p (Pool n)))` with halt-on-OOB** (`nb-arena-fail`), matching
> `pool-write`. E113 conforms to that. This example is kept as the design rationale
> (why OOB-as-value was considered); the **SPEC banner** carries the decision and
> its reasoning (an OOB read is a caller logic bug → halt; the principled "safe
> read" is a refinement-typed in-bounds offset, not a value arm).

## 1. Scope

- **Element:** E113, a `pool-read` crossing — read `len` bytes at an offset from a
  linear `(Pool n)`, returning the `Bytes` AND threading the same `(Pool n)` cap
  back. The read companion to `pool-write`.
- **Kind:** BUILD-PROPER (the memfd `Pool` arena only ever writes today; no read
  crossing exists — surfaced by the E111 pre-run).
- **Why chirality needs its own:** a `Pool`-backed cell store (E111 Grid) needs O(1)
  indexed **reads**. `mem-region.chiral` builds a bump arena on `Pool` that can
  `mem-alloc`/`mem-write`/`mem-stow` but never read a stored cell back — the
  region is write-only. `pool-read` is the missing half of the arena.

## 2. Research

- **Reference class:** OURS — the real chirality tree: `ports.chiral` (`Pool` porttype,
  `pool-write`/`pool-create`/`pool-close` signatures, lines 19, 73-75), the host
  bindings in `scaffold/chirality/impl_ports.py` (`_poolcreate`/`_poolwrite`/`_poolclose`,
  lines 266-292), `mem-region.chiral` (the linear bump arena, the `Region.cap`
  runtime witness), and `sys-tal.chiral` (the `nb-sys-memfd`/`ftruncate`/`mmap`/
  `munmap` TAL bodies, lines 75-107).

- **Key findings (the load-bearing facts):**
  1. **The runtime length is NOT lost — it lives in the host port value.** At the
     chirality type level `Pool n`'s `n` is erased `(0 n I64)`, so chirality code cannot
     read the size. But a `Pool` value's runtime representation is the tuple
     `("pool", mm, size)` (`impl_ports.py:273`) — the live `mmap` plus its byte
     size, recorded when `pool-create` calls `ftruncate(fd, size)` + `mmap(fd, size)`.
  2. **`pool-write` already bounds-checks host-side against that size.**
     `_poolwrite` does `if off < 0 or off + len(data) > size: raise PortError`
     (`impl_ports.py:289`) — it trusts the caller's offset only up to a runtime
     check it performs itself, from the tuple. A constant in-bound offset is
     compile-time checked by refinement types (`mem-put-checked`, `mem-linear.chiral`);
     a computed offset falls back to this runtime check (ports.chiral:70-72).
  3. **`pool-close` (E107's territory) already gets its `munmap` length the same
     way.** `_poolclose` reads `_, mm, size = pv`, zeroizes `mm[:size]`, then
     `mm.close()` (`impl_ports.py:278-282`). So the length E107's `munmap` needs is
     already in the host tuple — no chirality-side length is threaded for it today.
  4. **A `Pool` read is a slice of the live mapping, not a new syscall.** `pool-write`
     is `mm[off:off+len] = data`; the read is `bs = mm[off:off+len]`. No `pread(2)`,
     no fresh `mmap` — the region `pool-create` mapped is still live. So `pool-read`
     needs **no new `nb-*` TAL body**; it rides the existing mapped region exactly
     as `pool-write` does.
  5. **Pool crossings are not natively wired yet.** `crossing-wraps.chiral` and
     `sys-linkage.chiral` contain no `pool-*` entry — `pool-create`/`write`/`close`
     have only the Python-oracle bindings in `impl_ports.py`. The `nb-sys-memfd/
     ftruncate/mmap/munmap` TAL bodies exist in `sys-tal.chiral` but aren't stitched
     to the `Pool` externs. `pool-read` joins them as an oracle binding until the
     native memfd arena is wired.

## 3. Conventional (other-language) approach

Outside chirality a mapped buffer is just a pointer + length; reads are unchecked
pointer arithmetic, and the length is ambient (the caller "just knows" it).

```python
# the OURS host binding shape (impl_ports.py), and how a conventional caller reads
def pool_read(pv, off, length):
    _, mm, size = pv                 # size rides in the value — but nothing types it
    return mm[off:off + length]      # C would be memcpy(dst, base+off, length): no check

# conventional caller: length is ambient, aliasing is free, use-after-free is possible
buf = pool_create(4096)
pool_write(buf, 0, b"hi")
data = pool_read(buf, 0, 2)          # buf still usable, freely, forever — no linearity
pool_close(buf)                      # nothing stops a read AFTER this
```

- **Assumptions it bakes in:** ambient length (the size is a loose runtime value,
  not tied to the region's type); free aliasing (the buffer is copyable, so a read
  after close, or two concurrent readers, is expressible); unchecked offsets (C
  reads past `size` are UB, not a returned error); no proof that a read even
  targets a live mapping.

## 4. The chirality idea

chirality keeps the runtime length exactly where it already is — in the host port
value — and adds nothing to the *type*, because the type already says everything
chirality needs: the region is linear and its bound is erased.

- **Chirality features in play:** QTT linearity (`(1 p (Pool n))` — the cap is moved,
  never copied), the erased size index (`(0 n I64)`), the effect membrane
  (`pool-read` is `=>` process — it touches a live mapping), boundary sums (OOB
  as a returned value, not a halt), and the `Region.cap` runtime witness for the
  surface-level length.
- **The reframing:** `pool-read` **mirrors `pool-write` exactly** — takes the linear
  `(1 p (Pool n))`, an offset, a length, and returns a result sum whose success arm
  carries the `Bytes` AND threads the same `(Pool n)` onward (a read cannot peek
  without moving the cap back — a generic `Pair` cannot hold a linear field, so the
  result is a dedicated data type, the `RecvR`/`AvailR` pattern). The bound is
  enforced host-side against the tuple's `size`, identically to `pool-write`.
- **The shared runtime-length question (E113 + E107), RESOLVED here:** neither
  element needs a new length-exposing crossing. The length already lives in the
  host port representation `("pool", mm, size)`, and every crossing that needs it —
  `pool-write`, `pool-close`→`munmap`, and the new `pool-read` — reads it there,
  host-side, at the crossing. **Recommended mechanism (one, resolved once):**
  keep `n` erased in the type; the crossing enforces the bound from the host value;
  and where chirality *surface* code genuinely needs the length as a value (to compute
  a read length, or bounds-check purely before crossing), **reuse the existing
  `Region.cap` witness** (`mem-region.chiral:23` — "the value the pool was created
  with, agreeing with `n` by construction"). Reading `cap` is a total pure field
  access — no effect row — so it keeps pure code pure. **Recommend against** a new
  `pool-len` accessor crossing (it re-derives what the caller already had at
  `pool-create`, and adds a crossing where a field read suffices) and against a
  length-carrying `Pool` porttype variant (it duplicates in the type what already
  rides in the host value and is already recoverable via `Region.cap`).
- **One deliberate improvement over `pool-write`:** `pool-write` currently *halts*
  host-side on an out-of-bounds offset (`raise PortError`). Per errors-as-values
  (E29) and the boundary-sums directive, `pool-read` returns OOB as a value arm
  (`pread-oob`) that **threads the `Pool` back** — a bad offset is not a corpse, the
  region is intact and reusable. (The implementer may reconcile `pool-write` to
  match, or leave the asymmetry noted.)
- **What chirality makes impossible here:** reading a `Pool` you no longer hold (the
  cap is linear — after `pool-close` consumes it, no read term can name it);
  aliasing a region for two concurrent readers; and silently reading past the
  region and treating garbage as data (OOB is a typed arm the caller must `case`).

## 5. Chirality example (fleshed)

Real chirality surface syntax. `pool-read`'s signature mirrors `pool-write` line-for-line;
the round-trip writes bytes, reads them back, and asserts equality. Linear
resources are threaded through `case` (the `mem-region.chiral` idiom) — **not** `let`
(a `let`-bound linear `(Pool n)` trips the kernel's field-binder usage check).

```chirality
; --- the read companion to pool-write (ports.chiral) ---------------------------
; success threads Bytes + the live (Pool n); OOB threads the Pool back as a value
; (a bad offset is recoverable — the region is intact). A generic Pair cannot
; hold the linear pool, so this is a dedicated result sum (the RecvR/AvailR shape).
(data PoolReadR ((n I64))
  (pread-r   (bs Bytes) (1 p (Pool n)))
  (pread-oob (off I64) (want I64) (1 p (Pool n))))

; mirror pool-write exactly: erased bound, then (=> linear-pool, off, len -> result)
;   pool-write : (-> (0 n I64) (=> (1 p (Pool n)) I64 Bytes   (Pool n)))
;   pool-read  : (-> (0 n I64) (=> (1 p (Pool n)) I64 I64 (PoolReadR n)))
; bound enforced host-side against the port value's size; no new nb-* body —
; a read is a slice of the mapping pool-create already mmap'd.
(extern pool-read (-> (0 n I64) (=> (1 p (Pool n)) I64 I64 (PoolReadR n))))

; --- round trip: write "hi" at offset 0, read it back, assert equality --------
(declare compile-main (-> Unit I64))
(def compile-main
  (lam (_)
    (case (pool-create 4096)                         ; (PoolR 4096): pool + memfd
      ((pool-r p fd)
        (case (fd-close fd)                           ; scratch pool: discharge fd here
          (unit
            ; write bytes in, then read the same range back out
            (case (pool-read 4096 (pool-write 4096 p 0 (str->bytes "hi")) 0 2)
              ((pread-r got p2)                        ; got : Bytes, p2 : live (Pool 4096)
                (case (pool-close 4096 p2)             ; drop the arena as a unit
                  (unit (case (=i (bget got 0) (bget (str->bytes "hi") 0))
                          (true 0)                     ; round-trip byte matches
                          (false 1)))))
              ((pread-oob o w p2)                      ; OOB arm still threads the cap back
                (case (pool-close 4096 p2) (unit 2))))))))))
```

- **Knobs to modify:** the bound `4096` (the erased `n`, matched to the
  `pool-create` size); the offset/len pair (`0`/`2` here — a computed offset takes
  the host runtime check, a constant in-bound one could carry a refinement like
  `pool-write`'s `mem-put-checked`); and whether a not-locally-shared pool
  discharges its `Fd` here (`fd-close`) or ships it to a peer (`sock-send-fd`).
- **Deliberately omitted:** the native `nb-*` wiring (pool crossings are
  Python-oracle-bound today — see §2 finding 5); a refinement-typed offset variant;
  and a `Region`-level `region-read` wrapper (E111's job — it threads `pool-read`
  through the `Region` and can bounds-check against `cap` purely before crossing).

## 6. Use / modify notes

- **Lands in:** the `pool-read` extern + `PoolReadR` in `scaffold/lib/ports.chiral`
  (beside `pool-write`); the host binding as `@impl("pool-read")` in
  `scaffold/chirality/impl_ports.py` (a `mm[off:off+len]` slice, bounds-checked against
  the tuple `size` exactly as `_poolwrite`); and a `Region`-level reader in
  `scaffold/lib/mem-region.chiral` for E111 to call.
- **Conformance target:** a write-then-read round trip returns the bytes written
  (`pool-read(pool-write(p, off, bs), off, |bs|) == bs`), threads the same `(Pool n)`
  onward, and returns `pread-oob` (not a halt, not garbage) for an offset+len past
  the region — with the `Pool` still live in the OOB arm.
- **B1 ground truth (verbatim):** the shape above type-checks through B1 —
  linearity, effect membrane, exhaustive `case`, and the type-level `(Pool n)`-in →
  `Bytes` + `(Pool n)`-out threading all pass. It reaches native codegen and fails
  there with **`no emitted label for entry compile-main`** — the expected outcome,
  because pool crossings (including the new `pool-read`) have no native binding yet
  (§2 finding 5); execution is blocked only by that missing wiring, not the shape.
  (Threading the linear `(Pool n)` through `let` instead of `case` produces
  `load: field binder usage mismatch` — thread linear resources through `case`.)
- **Open questions a real implementation must decide:** (1) reconcile `pool-write`'s
  host *halt* on OOB with `pool-read`'s OOB-as-value arm, or keep the asymmetry;
  (2) whether E111's `region-read` bounds-checks purely against `Region.cap` before
  crossing (keeping the pre-check off the effect membrane) and lets `pool-read`'s
  host check be the backstop.
- **Related:** [[E111-pool-grid]] (the cell-store dependent that needs indexed
  reads), [[E107-pool-close-munmap]] (shares the runtime-length resolution above),
  [[ports]], [[memory]].
