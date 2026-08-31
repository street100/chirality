---
element: E90
slug: arena-grow-crossing
title: `nb-arena-grow` TAL crossing: mprotect reserve-commit growth + heapend cell update
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-09
---

# E90 — `nb-arena-grow` TAL crossing: mprotect reserve-commit growth + heapend cell update

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E90, the `nb-arena-grow` TIFn — a TAL crossing that grows the
  bump-allocator arena by `mprotect`ing the NEXT chunk of an already-reserved,
  `PROT_NONE` virtual region up to `PROT_READ|PROT_WRITE`, then publishing the
  new committed end into the `heapend` tracking cell the bump allocator reads
  every allocation. It grows the COMMITTED prefix of a fixed reservation; the
  reservation itself never moves.
- **Kind:** BUILD-PROPER — `sys-tal.chiral` already has the raw
  `nb-sys-mprotect-t` (nr 10, three integer args in `rdi rsi rdx`, returns 0 or
  `-errno`; `sys-tal.chiral:113`), and the `mprotect` syscall is already
  E76-registered (`sys-row "nb-sys-mprotect" 10`, `target-linux.chiral:19`). What
  lives nowhere yet is the doubling arithmetic, the reservation-ceiling check,
  the honest-failure path, and the `heapend` write. `nb-arena-grow` composes the
  registered `mprotect` crossing — it has no `ti-sys` of its own, so it needs NO
  new `target-linux` row (the governance rides `nb-sys-mprotect-t`, exactly like
  `nb-run-elf` riding its three crossings, `sys-tal.chiral:353`).
- **Why chirality needs its own:** the arena is Category-B — raw mmap'd memory the
  type system can't see. Under reserve-commit (E89 stub v3) the arena is a large
  `PROT_NONE` reservation with only a small `PROT_READ|PROT_WRITE` prefix
  committed. When the bump cursor approaches `heapend`, SOMETHING must commit the
  next pages before the store lands — otherwise the write faults on a
  `PROT_NONE` page. `nb-arena-grow` is that something: one `mprotect`, pure I64
  arithmetic, one cell write, and an honest exit if the reservation is exhausted
  or the kernel refuses. No Python, no ctypes — the program commits its own
  memory.

## 2. Research

- **Reference class:** OURS — the existing `nb-sys-mprotect-t` crossing
  (`sys-tal.chiral:113`), the `nb-put-u64`/`nb-get-u64` cell-word primitives in
  `bytes-tal.chiral`, the raw `heapptr`/`heapend` cells in `mach-x64.chiral` x-fin
  (`:258-264`), and the E89 reserve-commit entry stub. `ours_source: (none)`
  because `nb-arena-grow` does not yet exist in any form — the earlier claim that
  it (or an `mremap` doubling variant) was implemented is false; there is zero
  grow code in any commit.
- **Key findings:**
  - **`nb-sys-mprotect-t` is the raw three-arg crossing.**
    `(ti-fn "nb-sys-mprotect" 3 4 (t-seq (ti-sys 3 10 (cons 0 (cons 1 (cons 2 nil)))) (ti-ret 3)))`
    — `mprotect(addr, len, prot)`, nr 10, returns 0 or `-errno`. It does no
    arithmetic and no cell poking; the doubling, the ceiling check, and the
    `heapend` update go in this new wrapper on top of it.
  - **The reservation/commit split is E89's, not designed here.** The entry stub
    v3 (E89 step 3) reserves a large `PROT_NONE` region (`mmap` with
    `PROT_NONE`, VA-only, unaccounted under overcommit) and `mprotect`s an
    initial `INIT_COMMIT` prefix to RW, then sets `heapptr = base`,
    `heapend = base + INIT_COMMIT`, and single-sources the reservation base and
    the reservation END. `nb-arena-grow` CONSUMES that metadata; it never
    reserves and never touches the base.
  - **`mremap` is rejected — it appears nowhere in this element.** `mremap` with
    `MREMAP_MAYMOVE` relocates the mapping, which invalidates every absolute
    heap pointer already handed out (the arena holds raw addresses, not
    handles); without `MAYMOVE` in-place growth is unreliable (fails the moment
    the next VA range is taken). Reserve-commit sidesteps both: the mapping's
    address never changes, only its protection. The stale `nb-sys-mremap` row
    (`target-linux.chiral:18`, nr 25) is dead and is retired separately by S3 —
    this element must not revive or depend on it.
  - **`heapptr`/`heapend` are page-aligned raw label cells** the loader fills
    (`mach-x64.chiral` x-fin, `:258-264`: `a-align 4096`, `a-label "heapptr"`,
    `a-bytes (b8 0)`, `a-label "heapend"`, `a-bytes (b8 0)`). Under reserve-commit
    it is the same two cells; only WHAT the entry stub writes into them changes
    (a reserve base + a committed end instead of a base + a fully-mapped end).
  - **Write-before-check is a PREREQUISITE, owned by E91.** Both allocation
    sequences (`x-alo`, `x-bnw` at `mach-x64.chiral:239-300`) STORE the object at
    the bump address FIRST, then compare against `heapend`, then trap. Benign
    while the whole arena is mapped RW; fatal under reserve-commit (the store
    faults on the `PROT_NONE` page before any grow can fire). E91 step 1
    reorders these to check-first; `nb-arena-grow` assumes that reorder already
    landed and is never entered mid-store.
  - **Errno check: use `(op-lti _ 0)`, not a `< -4095` form.** Linux error
    returns are in `[-4095, -1]`, all `< 0`; a `< -4095` test lets `-1`/`-12`
    pass as success. Every failure branch here tests the raw return `< 0`.

## 3. Conventional (other-language) approach

The OURS baseline — `native.py`'s JIT loader maps one fixed, fully-committed
arena from OUTSIDE the program and pokes `heapptr`/`heapend` via ctypes; the
program itself never grows:

```python
# native.py: the JIT loader maps a fixed RW arena and pokes the cells (ctypes)
STUB_ARENA_BYTES = 48 << 30                       # 48 GB, fully committed RW
libc = ctypes.CDLL(None)
base = libc.mmap(0, STUB_ARENA_BYTES, PROT_READ | PROT_WRITE,
                 MAP_PRIVATE | MAP_ANONYMOUS | MAP_NORESERVE, -1, 0)
if base == ctypes.c_void_p(-1).value:             # only catches -1, misses other errnos
    sys.exit(1)
ctypes.memmove(heapptr_addr, ctypes.byref(ctypes.c_int64(base)), 8)
ctypes.memmove(heapend_addr, ctypes.byref(ctypes.c_int64(base + STUB_ARENA_BYTES)), 8)
# There is NO runtime grow path — the arena size is baked in once, by the host.
```

- **Assumptions it bakes in:** the arena is sized ONCE, at startup, by the HOST
  (the program can't commit its own memory); the whole region is committed up
  front (no reserve-commit — the sub-megabyte-footprint ethos is lost); there is
  no grow-after-init; the `MAP_FAILED` check is `base == -1` (misses every other
  errno). Its own hazard shape matches the chirality one: an overflow past the mapped
  region is a `SIGSEGV` on an unmapped VA, not a clean trap — the same reason the
  chirality path must commit BEFORE the store, not after.

## 4. The chirality idea

- **Memory is substrate, not an effect — the grow is SUB-SEMANTIC.** There is NO
  surface `=>` "arena-grow" riding the `->`/`=>` effect membrane. Committing
  pages is below the language's effect semantics, at the same tier as the entry
  stub: the program's own runtime maintaining the ground it stands on. The E91
  out-of-line stub calls `nb-arena-grow` from an allocation site, not from
  effectful surface code, and no `=>` obligation is threaded through it.
- **But the `mprotect` syscall is still E76-registered and preserve-checked.**
  Sub-semantic does not mean unpoliced. `nb-arena-grow` reaches the kernel only
  through `nb-sys-mprotect-t` (nr 10, already in the SysReg / SYSCALL_TABLE), so
  the crossing is `sys-face`, lives in `sys-lib`, and is preserve-checked like
  every other sys-lib crossing. It just isn't reachable from surface `=>` code —
  its only caller is the E91 stub. (Composing a registered crossing, it carries
  no `ti-sys` of its own, so it needs no new `target-linux` row — the
  `nb-run-elf` / `nb-sys-exec-elf` precedent.)
- **Errors as values, then an honest halt — never into unmapped memory.**
  `mprotect` returns 0 or `-errno`; the reservation ceiling is a plain compare.
  On either failure `nb-arena-grow` does NOT return a sentinel the caller might
  ignore and then store through — it takes the E89-style honest-fail path (write
  a diagnostic to fd 2, `exit_group(1)`). Continuing past a failed commit would
  mean a store into a `PROT_NONE` page — the one outcome reserve-commit exists to
  make impossible.
- **The reframing:** in the ctypes model, arena sizing is a HOST operation done
  once. In chirality, `nb-arena-grow` is a TAL function the program calls at runtime
  to commit the NEXT slice of a reservation it already owns. The mapping's
  address is fixed for the process lifetime (no `mremap`, no relocation, no
  dangling pointers); growth is purely a protection change on a prefix that
  gets longer.
- **What chirality makes impossible here:** a relocated arena (no `mremap` — every
  handed-out absolute pointer stays valid); a silent grow-into-unmapped-memory
  (the `mprotect`-fail and ceiling-overrun branches both halt honestly rather
  than returning); a grow that forgets to publish the new end (the `heapend`
  write is on the success path, before the return); an errno-as-success bug
  (`(op-lti rc 0)` catches every negative return).

## 5. Chirality example (fleshed)

```chirality
; E90 — nb-arena-grow: commit the next chunk of a PROT_NONE reservation to RW
; and publish the new committed end. Lives in sys-tal.chiral. sys-face: it
; reaches the kernel through nb-sys-mprotect (nr 10, already registered). It
; is SUB-SEMANTIC -- called by the E91 out-of-line stub at allocation sites,
; NOT from surface => code. No mremap: the reservation never moves.
;
; Reservation/commit metadata (base, reserve-end, heapend) is established by the
; E89 stub v3 -- referenced, not designed here.
;
; nb-arena-commit(from, to, reserve_end, heapend_cell) -> to
;   from        reg0 -- current committed end (start of the chunk to commit)
;   to          reg1 -- desired new committed end
;   reserve_end reg2 -- hard ceiling: end of the PROT_NONE reservation (E89)
;   heapend_cell reg3 -- the heapend tracking cell, updated on success
; Ceiling-overrun or mprotect failure => the E89 honest-fail path (never return).

(def nb-arena-commit-t TIFn
  (ti-fn "nb-arena-commit" 4 12
    ; -- refuse to commit past the reservation (to > reserve_end) --
    (t-seq (ti-prim 4 (op-lti) 2 1)                              ; reg4 = (reserve_end < to)
      (ti-tcase 4 false
        (cons (pair (pair 1 nil)                                 ; true: reservation exhausted
          (t-seq (ti-const 5 1)                                  ; fail code 1 = OOM/ceiling
          (t-seq (ti-call 6 "nb-arena-fail" (cons 5 nil))         ; E89: write msg, exit_group(1)
            (ti-ret 6))))                                        ; sentinel; never reached
        (cons (pair (pair 0 nil)                                 ; false: room to grow
          ; -- mprotect(from, to - from, PROT_READ|PROT_WRITE) --
          (t-seq (ti-prim 7 (op-sub) 1 0)                         ; reg7 = delta = to - from
          (t-seq (ti-const 8 3)                                  ; reg8 = PROT_READ|PROT_WRITE
          (t-seq (ti-call 9 "nb-sys-mprotect" (cons 0 (cons 7 (cons 8 nil))))  ; reg9 = rc
          (t-seq (ti-const 10 0)
          (t-seq (ti-prim 11 (op-lti) 9 10)                       ; reg11 = (rc < 0)
            (ti-tcase 11 false
              (cons (pair (pair 1 nil)                            ; true: mprotect failed
                (t-seq (ti-const 5 2)                             ; fail code 2 = mprotect
                (t-seq (ti-call 6 "nb-arena-fail" (cons 5 nil))
                  (ti-ret 6))))                                   ; never store into PROT_NONE
              (cons (pair (pair 0 nil)                            ; false: committed
                ; -- publish new committed end: heapend := to --
                (t-seq (ti-const 5 0)                             ; offset 0
                (t-seq (ti-call 6 "nb-put-u64" (cons 3 (cons 5 (cons 1 nil))))
                  (ti-ret 1))))                                   ; return new committed end
              nil))
              none)))))))
        nil))
        none))))

; nb-arena-grow(base, reserve_end, need, heapend_cell) -> new_committed_end
;   base        reg0 -- reservation base (E89), for the doubling measure
;   reserve_end reg1 -- reservation ceiling (E89)
;   need        reg2 -- bytes the failing allocation requires beyond heapend
;   heapend_cell reg3 -- current committed end (read) + new end (written)
; Policy: commit max(double-the-committed-prefix, cover-the-need).

(def nb-arena-grow-t TIFn
  (ti-fn "nb-arena-grow" 4 12
    (t-seq (ti-const 4 0)
    (t-seq (ti-call 5 "nb-get-u64" (cons 3 (cons 4 nil)))         ; reg5 = committed_end
    (t-seq (ti-prim 6 (op-sub) 5 0)                               ; reg6 = committed_size
    (t-seq (ti-prim 7 (op-lti) 6 2)                               ; reg7 = (committed_size < need)
      (ti-tcase 7 false
        (cons (pair (pair 1 nil)                                  ; need dominates
          (t-seq (ti-prim 8 (op-add) 5 2)                         ; reg8 = committed_end + need
          (t-seq (ti-call 9 "nb-arena-commit" (cons 5 (cons 8 (cons 1 (cons 3 nil)))))
            (ti-ret 9))))
        (cons (pair (pair 0 nil)                                  ; doubling dominates
          (t-seq (ti-prim 8 (op-add) 5 6)                         ; reg8 = committed_end + committed_size (2x prefix)
          (t-seq (ti-call 9 "nb-arena-commit" (cons 5 (cons 8 (cons 1 (cons 3 nil)))))
            (ti-ret 9))))
        nil))
        none))))))))
; NOTE -- the paren count above is schematic. Real sys-tal.chiral requires exact
; matching verified with the sexp reader
; (PYTHONPATH=scaffold python3 -c "from chirality.sexp import read_all; ...").
; nb-arena-fail is E89's honest-fail helper (write a fixed diagnostic to fd 2 via
; nb-sys-write, then nb-sys-exit-group(1)) -- referenced here, defined by E89.
```

- **Knobs to modify:** the growth policy (`op-add 5 6` doubles the committed
  prefix — swap for a fixed step, or 4×, but powers of two keep page alignment);
  the `prot` value (`ti-const 8 3` = RW; add `PROT_EXEC` only for a W^X code
  arena, never for the data heap); the failure codes handed to `nb-arena-fail`
  (currently 1 = reservation exhausted, 2 = mprotect refused — the caller/user
  sees which); page-rounding of `delta` (see omitted).
- **Deliberately omitted:** `mremap` and any moving-growth path (rejected —
  dangling absolute pointers; §2); the reservation/commit init (E89 stub v3 owns
  `base`, the initial commit, and `reserve_end`); the out-of-line grow STUB —
  the assembly glue between allocation sites and this crossing (preserve scratch,
  SysV-call `nb-arena-grow` with needed-bytes, return-to-retry) is E91's, called
  here only by interface; the check-first reorder of `x-alo`/`x-bnw` (E91 step 1,
  the prerequisite); page-alignment of `delta`/`need` (`mprotect` requires a
  page-aligned addr and rounds the length up — the caller/E89 should round
  `need` to a page multiple; shown unrounded for clarity); the `growing` vs
  `fixed-trap` Alloc-instance selection (E81 extension); explicit zeroing (fresh
  `PROT_NONE`→RW pages read as zero, like `MAP_ANONYMOUS`).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/sys-tal.chiral` — both TIFns sit next to
  `nb-sys-mprotect-t`. Coordinated changes on land:
  1. The two `ti-fn` defs above, paren-verified with the sexp reader.
  2. Insert `nb-arena-grow-t` and `nb-arena-commit-t` into the `sys-lib` cons
     chain (`sys-tal.chiral:431`).
  3. **No `target-linux.chiral` row** — neither TIFn issues a raw `ti-sys`; they
     compose `nb-sys-mprotect` (already `sys-row … 10`) and `nb-put-u64` /
     `nb-get-u64`, so the mprotect governance rides the existing row (the
     `nb-run-elf` precedent).
  4. **No `crossing-wraps` / `ports` extern** — the grow is sub-semantic, not a
     surface effect; it is invoked only by the E91 out-of-line stub at the TAL
     floor, never through a `=>` surface name.
- **Conformance target:** with a reserve-commit arena (E89), drive the bump
  cursor past `INIT_COMMIT` and confirm `nb-arena-grow` commits the next chunk
  (`heapend` advances to the returned end; a store just under the new `heapend`
  succeeds; a store just past it still traps). Failure injection: under
  `RLIMIT_AS` tight enough to make `mprotect` return `-ENOMEM`, the process must
  exit 1 with the diagnostic — NOT SIGSEGV, NOT OOM-kill (E89 honest-fail path).
  The real soak is the self-compile itself: from `INIT_COMMIT` (~256 KB) through
  ~nine doublings to the compiler's peak, the fixpoint must stay byte-identical.
  Extend the golden TIFn-name list test with the two new names.
- **Open questions:**
  - **Is `heapend` addressable by `nb-get-u64`/`nb-put-u64`?** Today it is a raw
    8-byte label (`mach-x64.chiral` x-fin), not a `[len][payload]` Bytes cell, so
    `ti-bget`/`ti-bput`'s payload-relative offset would be wrong. E89's stub v3
    must resolve this: (a) emit `heapend` as an addressable metadata cell the
    word primitives accept, (b) provide a raw absolute load/store primitive
    (matching the entry stub's `mov [moffs64]`), or (c) pass `committed_end` by
    value and let the E91 stub write `heapend` after the grow returns. The body
    above assumes (a); the SPEC picks one.
  - **Where do `base` and `reserve_end` come from?** They are E89 stub-v3
    metadata (single-sourced constants or cells). Passed as params here; the
    SPEC decides register-passing vs cell-reads inside the grow.
  - **Doubling measure without a moving base:** doubling the committed prefix
    needs `committed_end - base`; this is only correct while `base` is the
    reservation base (the cursor `heapptr` moves, `base` does not). Confirm E89
    keeps `base` distinct from the bump cursor.
  - **Concurrency:** none — the runtime is single-threaded; the `heapend` write
    is a plain 8-byte store, read in order by the next allocation.
- **Related:** [[E90-arena-grow-crossing]] · [[E89-arena-init]] (the
  reserve-commit entry stub v3 that establishes `base`/`reserve_end`/`heapend`
  and owns the honest-fail helper — the sibling this element consumes) ·
  [[E91-growing-allocator]] (the check-first reorder of `x-alo`/`x-bnw` PLUS the
  shared out-of-line grow stub + retry loop that CALLS `nb-arena-grow`) ·
  [[E81-alloc-discipline]] (`growing` as a named Alloc instance beside
  `fixed-trap`) · `scaffold/lib/sys-tal.chiral:113` (`nb-sys-mprotect-t`, the
  registered crossing this rides) · `scaffold/lib/target-linux.chiral:19`
  (the `mprotect` row, nr 10 — already present) · `scaffold/lib/mach-x64.chiral`
  x-fin `:258-264` (the `heapptr`/`heapend` cells) · `scaffold/lib/bytes-tal.chiral`
  (`nb-put-u64`/`nb-get-u64`).
