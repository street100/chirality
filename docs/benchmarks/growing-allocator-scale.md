---
node: benchmarks-growing-allocator
layer: benchmark
status: measured
updated: 2026-08-10
---

# E91 growing allocator — reserve-commit arena scale test

## What this measures

The E91 growing allocator is a **reserve-commit arena**: at startup it reserves
a fixed **64 GiB** address range as `PROT_NONE` (address space only, zero
physical memory) and commits a 256 KiB `PROT_RW` prefix. Allocation is a
userspace **bump** in the committed prefix; when a bump would cross the
committed edge, `nb-arena-grow` **doubles** the committed region with one
`mprotect` call. Because the reservation never moves, a grow **never re-copies**
existing data — the mapping's base address is stable across every grow. This
test drives both allocation paths to large sizes and checks two things: that the
grown structures are byte-correct (via checksum-as-exit-code), and that wall
time scales linearly (no hidden re-copy).

Two paths:
- **value cells** (`x-galo`) — cons cells, 24 bytes each (tag + 2 fields),
  built via a balanced double loop (bounded stack depth).
- **byte cells** (`x-gbnw`) — one large `brepeat`'d buffer per rung.

Each rung builds its structure and returns an **independently-predicted
checksum as its exit code**; PASS ⇔ `exit == predicted`. A wrong value is
silent corruption (distinct exit), a signal is a crash. See the shared
conventions in [README.md](README.md).

Arena constants (`lib/compile-emit.chiral`, cross-checked to `native.py`):
`init-commit = 262144` (256 KiB), `reserve-bytes = 68719476736` (64 GiB hard
ceiling). On grow, `nb-arena-grow` checks `target > reserve_end` **before** any
`mprotect`, so an overrun is a clean `exit_group(1)` and an `mprotect` refusal
(overcommit accounting) is `exit 2` — neither is a fault.

## shredtower run — 2026-08-10T13:29:15Z

- **Host:** Linux 7.1.6-1-cachyos x86_64; MemTotal 63388 MiB, MemAvailable
  56649 MiB, CommitLimit 48078 MiB, Swap 16384 MiB, `vm.overcommit_memory=0`.
- **Compiler:** B1, 790904 bytes (md5 `2e2da0bedff04f17492138c9ba56d581`).
- **Blob:** 45108 bytes (`sys-linkage` + transitive deps).

Ladder (all rungs PASS on both paths):

```
PATH   MB     bytes        cells/len      grows  exp  got  wall_s   MB/s     VERDICT
value  16     16773504     698896c        5      40   40   0.006    2666.1   PASS
byte   16     16777216     16777216b      6      195  195  0.137    116.8    PASS
value  32     33530976     1397124c       6      126  126  0.010    3197.8   PASS
byte   32     33554432     33554432b      7      195  195  0.274    116.8    PASS
value  64     67094016     2795584c       7      32   32   0.020    3199.3   PASS
byte   64     67108864     67108864b      8      195  195  0.505    126.7    PASS
value  128    134123904    5588496c       8      232  232  0.036    3553.1   PASS
byte   128    134217728    134217728b     9      195  195  0.975    131.3    PASS
value  256    268376064    11182336c      9      128  128  0.072    3554.8   PASS
byte   256    268435456    268435456b     10     195  195  1.949    131.3    PASS
value  512    536722584    22363441c      10     173  173  0.141    3630.2   PASS
byte   512    536870912    536870912b     11     195  195  3.918    130.7    PASS
value  1024   1073504256   44729344c      11     0    0    0.280    3656.3   PASS
byte   1024   1073741824   1073741824b    12     195  195  7.829    130.8    PASS
value  2048   2147344344   89472681c      12     138  138  0.557    3676.6   PASS
byte   2048   2147483648   2147483648b    13     195  195  15.693   130.5    PASS
value  4096   4294659096   178944129c     13     161  161  1.111    3686.5   PASS
byte   4096   4294967296   4294967296b    14     195  195  31.361   130.6    PASS
value  8192   8589377376   357890724c     14     254  254  2.488    3292.4   PASS
byte   8192   8589934592   8589934592b    15     195  195  62.294   131.5    PASS
value  16384  17178636384  715776516c     15     6    6    6.132    2671.7   PASS
byte   16384  17179869184  17179869184b   16     195  195  124.216  131.9    PASS
value  32768  34359325656  1431638569c    16     255  255  14.678   2232.4   PASS
byte   32768  34359738368  34359738368b   17     195  195  248.623  131.8    PASS
```

**Ceiling test.** A single 100 GiB request (`107374182400` B) against the 64 GiB
reservation (`68719476736` B): `nb-arena-grow` checks `target > reserve_end`
**before** any `mprotect` — it touches zero physical memory — and returns
**exit 1** (clean `nb-arena-fail`), not OOM-kill (137) or segfault (139). PASS.

**Summary.** Largest rung grown correctly: **32 GB (32768 MiB)**. All checksums
matched; ceiling clean; **OVERALL PASS**.

## Interpretation — linear, no re-copy

- **value-cell holds ~3.2–3.7 GB/s from 16 MB through 4 GB**, then tapers to
  ~2.2 GB/s at 32 GB. The taper is **first-touch page-faults + TLB/cache
  pressure** at that working-set size, **not** re-copy — a re-copying grow would
  *collapse* MB/s (super-linear wall time), not gently taper.
- **byte-cell is flat ~117–132 MB/s across the whole range.** This path is
  **copy-bandwidth-bound, not allocator-bound**: `brepeat` does a real `memcpy`
  per cell, so its throughput reflects `memcpy`, independent of arena size.
- **~17 doublings, O(log N) `mprotect` syscalls total**, amortized to ~zero per
  allocation. The bump hot path is **syscall-free userspace**; grows are the
  only kernel crossings and there are logarithmically few of them.

The flat/linear MB/s across five orders of magnitude of size, on both paths, is
the positive evidence that grows never re-copy — the whole point of the
reserve-commit design.

## VM cross-check (ccbox, ~4 GB RAM)

The same test on the sandbox VM confirms the same shape at small scale:
value-cell growth correct to **3 GB (~1.8–2.0 GB/s)**, byte-cell **~144 MB/s**,
and the self-compile **grows its own arena and fixpoints byte-identically**.
Same linear / no-recopy behavior; the lower absolute value-cell rate reflects
the smaller, more contended guest.

## Reproduce

```
cd /workspace/chirality && ./E91-host-scale.sh
```

`E91_MAX_MB=<n>` caps the ladder at `n` MiB (auto-caps at host RAM − margin,
≤ 32768 by default). The script writes `E91-host-scale-results.txt`, exercises
both grow paths, then runs the deterministic ceiling test. Optional knobs:
`E91_FIXPOINT=1` (emit-determinism proxy check), `E91_BYTE_VAL`,
`E91_RAM_CEILING=1` (aggressive page-writing ceiling — can OOM-kill; off by
default, only the zero-memory 64 GiB hard ceiling runs otherwise).
