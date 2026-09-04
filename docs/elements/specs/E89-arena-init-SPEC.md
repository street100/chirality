---
element: E89
slug: arena-init
title: Arena startup — entry-stub v3 reserve/commit split (PROT_NONE reservation + mprotect'd INIT_COMMIT prefix), single-sourced constants
kind: REPLACE-CRUTCH
example: examples/E89-arena-init.md
status: audited
updated: 2026-08-09
---

# E89 SPEC — Arena startup: entry-stub v3 reserve/commit split, single-sourced constants

> Implementation contract produced by the `example-to-spec` run. Bridges the
> reviewed worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale.

## 1. Deliverable

- **After this runs:** `entry-stub-v3` in `compile-emit.chiral` replaces the
  eager `entry-stub-v2` with a reserve/commit prologue: `mmap(PROT_NONE,
  RESERVE_BYTES)` + `mprotect(PROT_RW, INIT_COMMIT)`, both checked, sharing one
  honest-fail tail. Constants `arena-bytes` and `STUB_ARENA_BYTES` (currently
  drifted: 16 GiB vs 64 MB) are replaced by single-sourced `reserve-bytes` (64
  GiB) and `init-commit` (256 KB) with a cross-check test that mechanically
  enforces parity between chirality authority and py mirror. The compiler rebuilds
  at fixpoint; startup resident footprint (`VmRSS`) is `INIT_COMMIT`, not the
  reservation size.
- **Non-goals:** Runtime growth — committing the next chunk when the bump cursor
  passes `heapend` is E90 (`nb-arena-grow`) + E91 (check-first allocators).
  `mremap` is REJECTED (relocation dangles absolute heap pointers). The JIT
  `_map_rw` disposition (adopt reserve-commit vs pin fixed-trap) is E81's
  decision. Peak-heap measurement tooling (TBD). Bump allocator logic itself
  (E21, already built — only the startup path changes).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** E21 (mmap arena) is BUILT/CONFORMS — the bump
  allocator works; this SPEC replaces only the *setup* (entry stub). E76
  (syscall chokepoint) registers `mmap` (nr 9) and `mprotect` (nr 10) — both
  syscalls are E76-preserved.
- **Live code:**
  - `compile-emit.chiral:49` — `arena-bytes I64 17179869184` (16 GiB, the chirality
    authority — but `native.py:57` says `STUB_ARENA_BYTES = 64 << 20` (64 MB).
    They have silently diverged; nothing mechanical catches it.)
  - `compile-emit.chiral:50-91` — `entry-stub-v2` (106 bytes): one eager
    `mmap(PROT_RW, 16 GiB, MAP_NORESERVE)` with a checked `jns` + silent
    `exit_group(1)` on failure. Sets `heapptr` + `heapend` (base + 16 GiB —
    fully committed), calls `compile-main`, propagates result to exit status.
    This is the target to replace.
  - `compile-emit.chiral:103` — `entry-stub-len I64 106` (recomputed for v3).
  - `compile-emit.chiral:108-113` — `assemble-elf` wires `heapptr-off`/
    `heapend-off` into the stub (will also wire `heapreserve-off` for the new
    third cell).
  - `mach-x64.chiral:258` — `x-fin` emits `heapptr` + `heapend` as two
    `a-dat (b8 0)` cells. Extended to three cells for `heapreserve`.
  - `native.py:57` — `STUB_ARENA_BYTES = 64 << 20` (the drifted mirror).
  - `native.py:741` — `_entry_stub` mirrors the v2 byte sequence.
  - `native.py:555` — `_map_rw` (JIT arena, 1 MB fully-committed RW,
    separate code path from the ELF stub).
- **TAL crossings already wired:**
  - `mmap` (nr 9): `nb-sys-mmap-t` in `sys-tal.chiral:99`, `sys-row` in
    `target-linux.chiral:17`, `(pair "mmap" "nb-sys-mmap")` in
    `crossing-wraps.chiral:30`, `(extern mmap ...)` in `lib/ports/process.port:16`.
  - `mprotect` (nr 10): `nb-sys-mprotect-t` in `sys-tal.chiral:113`, `sys-row`
    in `target-linux.chiral:19` — **but no crossing-wraps entry and no
    ports.chiral extern.** Both must be added (Step 1).
  - 2026-09-04, citation repair: both landed since. The extern is `(extern mprotect (=> I64 I64 I64 I64))` at `lib/ports/process.port:17` and the wraps row at `lib/lowering/tal/crossing-wraps.chiral:27`. Step 1 below is already in the tree; the step text is left as written.
- **True delta:** `compile-emit.chiral` — replace constants + stub + cell count.
  `mach-x64.chiral` — add third arena cell to `x-fin`. `native.py` — mirror
  new constants + stub bytes. `crossing-wraps.chiral` — add mprotect entry.
  `ports.chiral` — add mprotect extern. New cross-check test.
  ~5 files, ~80 lines changed, one new test file.

## 3. Decisions

Every open question from the example §6 and the three non-blocking audit FLAGs,
dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Reserve-end: third cell or constant? | RESOLVED — store as a third arena cell (`heapreserve`) | `nb-arena-grow` (E90) needs the reservation ceiling at TAL level where it cannot call chirality `def`s. A third cell in `x-fin` (`a-dat (b8 reserve-bytes)`) keeps the pattern uniform with `heapptr`/`heapend`. The stub writes `base + reserve-bytes` into it once at startup. DEFERRED to E90: whether `heapend` becomes an addressable `[len][payload]` cell for `nb-put-u64` writes, or the grow path uses raw `mov [moffs64]` stores. |
| 2 | Py JIT `_map_rw` disposition (native.py:555) | DEFERRED to E81 | The JIT arena currently maps a fixed 1 MB RW region. Whether it adopts reserve-commit (matching the ELF floor, inheriting E91's check-first prerequisite) or pins `fixed-trap` is decided by E81's `Alloc` discipline semantics (S17-E: `growing` vs `fixed-trap`). E89 does not touch the JIT path. |
| 3 | FLAG-1: GiB vs GB unit conflation ("~64 GB" in example §2) | RESOLVED — use GiB consistently | `RESERVE_BYTES = 68719476736 = 64 GiB` (~68.7 GB). All comments, docs, and this SPEC use GiB. The example §2 fragment is informational; implementation comments are the authority. |
| 4 | FLAG-2: `MAP_NORESERVE` (0x4022) with `PROT_NONE` | RESOLVED — drop `MAP_NORESERVE` | `PROT_NONE` already means zero swap reservation; `MAP_NORESERVE` is a no-op. Both the example §5 snippet and this SPEC use `MAP_PRIVATE \| MAP_ANONYMOUS` (0x22) only. Cleaner, no behavioral difference. |
| 5 | FLAG-3: §5 snippet closing-paren count (deep bcat nesting) | ACKNOWLEDGED — impl must verify with sexp reader | The bcat chain has ~50 closing parens after `x-arena-fail-tail`. The impl run MUST verify with `python3 -c "from chirality.sexp import read_all; list(read_all(open('lib/compile-emit.chiral').read(),'f')); print('OK')"` after editing. Never hand-count. This is the same discipline v2's compilable 106-byte stub used. |
| 6 | `mprotect` extern + crossing-wraps wiring | RESOLVED — add to ports.chiral + crossing-wraps | `nb-sys-mprotect-t` already exists in `sys-tal.chiral` and `target-linux.chiral`. Adding `(extern mprotect (=> I64 I64 I64 I64))` to `ports.chiral` and `(pair "mprotect" "nb-sys-mprotect")` to `crossing-wraps.chiral` completes the wiring, following the proven `mmap`/`ioctl` pattern. The stub emits raw bytes (not chirality surface calls), so `mprotect` isn't called from chirality — but the extern must exist so `ports.chiral` stays complete and future chirality-level arena code can use it. |
| 7 | `errno` check: `< -4096` vs `< 0` | RESOLVED — use `test rax, rax; js fail` (`rax < 0`) | Linux guarantees error returns are in `[-4095, -1]`, all of which are < 0. Successful addresses are userspace (below the sign bit, non-negative in signed I64). The `< -4096` form (used in an earlier draft) lets errno values slip through. Both the reservation `mmap` and commit `mprotect` use `test+jns` (same as v2's check). |
| 8 | `x-js-fail` and `x-arena-fail-tail` byte constants | RESOLVED — defined as local `def`s in `entry-stub-v3` | These are the shared fail-branch bytes reused from v2, factored so both `js fail` branches (mmap failure + mprotect failure) target one tail. The tail does `write(2, msg, 21); exit_group(1)`. The exact byte sequences are finalized at implementation time against the sexp reader (same discipline as v2's `rel32 = entry-off - 97`). |

## 4. Change plan (ordered, commit-sized)

### Step 1 — Add mprotect extern + crossing-wraps entry
- **Target:** `lib/ports/process.port:16` (after `mmap` extern), `crossing-wraps.chiral:30`
  (after `mmap` entry).
- **Change:**
  - `ports.chiral`: add `(extern mprotect (=> I64 I64 I64 I64))  ; mprotect(addr,len,prot) -> 0 or -errno`
  - `crossing-wraps.chiral`: add `(cons (pair "mprotect" "nb-sys-mprotect")` to
    the cons chain. Update trailing close-paren count.
- **Size:** S (2 files, ~4 lines added, mechanical).

### Step 2 — Replace arena constants + entry stub in compile-emit.chiral
- **Target:** `compile-emit.chiral:49-91` — `arena-bytes` + `entry-stub-v2`.
  `compile-emit.chiral:103` — `entry-stub-len`.
  `compile-emit.chiral:108-113` — `assemble-elf` cell references.
- **Change:**
  - Replace `(def arena-bytes I64 17179869184)` with:
    ```chirality
    (def reserve-bytes I64 68719476736)   ; 64 GiB — PROT_NONE VA reservation
    (def init-commit   I64 262144)        ; 256 KB — mprotect'd RW prefix
    ```
  - Replace `entry-stub-v2` with `entry-stub-v3`: the two-syscall
    reserve/commit prologue from example §5 (mmap PROT_NONE → save base →
    mprotect RW prefix → set heapptr/heapend/heapreserve → call main →
    honest-fail tail). The honest-fail tail writes `"can't allocate arena\n"`
    to fd 2 then `exit_group(1)` — v2 exited silently with no message.
    `x-js-fail` and `x-arena-fail-tail` are local byte defs (resolved at
    impl time per Decision 8).
  - The v3 instructions for setting arena cells:
    - `heapptr := base` (after mmap, before mprotect — rax still holds base)
    - `mprotect(base, INIT_COMMIT, PROT_RW)` — checked
    - `heapend := base + INIT_COMMIT` (COMMITTED end, NOT base + reserve)
    - `heapreserve := base + reserve-bytes` (reservation ceiling, new)
  - Recompute `entry-stub-len` to the actual v3 byte count (longer than 106).
  - `assemble-elf`: add `heapreserve-off` (third cell offset from x-fin).
- **Size:** L (~45 lines changed, the core of this SPEC).

### Step 3 — Add third arena cell to mach-x64.chiral x-fin
- **Target:** `mach-x64.chiral:258` — `x-fin`.
- **Change:** Insert `(a-dat (b8 reserve-bytes))` for `heapreserve` after the
  existing `heapptr` and `heapend` cells. The third cell stores the reservation
  ceiling at startup; `nb-arena-grow` (E90) reads it.
- **Size:** S (1 file, ~3 lines, one new Asm element).

### Step 4 — Mirror constants + stub in native.py
- **Target:** `native.py:57` — `STUB_ARENA_BYTES`. `native.py:741` —
  `_entry_stub`. `native.py` — `_ENTRY_STUB_LEN`.
- **Change:**
  - Replace `STUB_ARENA_BYTES = 64 << 20` with:
    ```python
    RESERVE_BYTES = 68719476736   # 64 GiB — must equal compile-emit.chiral reserve-bytes
    INIT_COMMIT   = 262144        # 256 KB — must equal compile-emit.chiral init-commit
    ```
  - Rewrite `_entry_stub` to emit the v3 byte sequence (matching `entry-stub-v3`
    byte-for-byte). Same discipline as v2: raw bytes via `struct.pack`.
    Note: the byte sequence is NOT identical to v2 — it is a different code
    shape (two-syscall prologue with shared fail tail). The ELF byte-identity
    test (`test_backend.py`) must be updated for the new stub length.
  - Recompute `_ENTRY_STUB_LEN` to match the actual v3 byte count.
- **Size:** M (~20 lines changed).

### Step 5 — Add cross-check test + rebuild, verify fixpoint
- **Target:** New test file `scaffold/tests/test_arena_constants.py`.
- **Change:** A Python test that:
  1. Reads `scaffold/lib/compile-emit.chiral` and extracts `reserve-bytes` and
     `init-commit` values (via the sexp reader or regex on the `def` lines).
  2. Asserts `native.RESERVE_BYTES == reserve-bytes` and
     `native.INIT_COMMIT == init-commit`.
  3. Runs as part of the existing test suite (`chirality test`).
  This is the mechanical guard that permanently fixes the 16 GiB-vs-64 MB drift
  — the "must match" comment alone never enforced anything.
- **Rebuild:** Sync all changed files to `chirality/`, `./build.sh`, confirm
  fixpoint (`bin/chirality-bin.new` byte-identical to `bin/chirality-bin`). Copy new B1 to
  `scaffold/build/B1`. Run `chirality test` — ≥ 708 tests passing.
- **Size:** S (one new test file, ~20 lines, + build step).

## 5. Conformance gate

- **Golden behavior:**
  1. A trivial chirality program (`(def compile-main (=> I64 I64) (lam (n) (put "ok\n") 0))`)
     compiles through B1 with the v3 stub and runs, printing "ok" and exiting 0.
  2. The compiler self-compiles at fixpoint (`build.sh` → `chirality-bin.new ==
     bin/chirality-bin`). The v3 stub's `INIT_COMMIT` (256 KB) is far below the
     self-compile's ~128 MB peak — the self-compile exercises E90/E91 growth.
     **Transitional path:** until E90/E91 land, the implementer sets
     `init-commit` to a transitional value (≥ 256 MB, e.g. `268435456`) for the
     fixpoint gate, verified via `chirality-bin.new == bin/chirality-bin`. After E90/E91 land,
     `init-commit` drops back to 262144 (256 KB). The transitional size is
     reverted as the final commit of E90+E91. The S17-A/B/C sequencing ensures
     no intermediate commit is broken.
  3. Startup resident footprint: after entry, `VmRSS` (from
     `/proc/self/status`) is bounded by `INIT_COMMIT` (256 KB), not 64 GiB.
     Verify with a probe binary that reads its own `/proc/self/status` right
     after the stub finishes.
  4. A reservation failure (e.g. `RLIMIT_AS` below 64 GiB) exits 1 with
     `"can't allocate arena\n"` on stderr — no SIGSEGV, no silent corruption,
     no OOM-kill. An `mprotect` failure (e.g. `vm.max_map_count` exhausted)
     takes the same path.
  5. The cross-check test fails the build if `native.py`'s `RESERVE_BYTES` or
     `INIT_COMMIT` diverge from `compile-emit.chiral`'s `def`s.
- **Tests to add:** `test_arena_constants.py` — cross-check test (Step 5).
  `test_arena_init.py` — Python-host test that compiles a small program with
  the v3 stub and verifies it runs.
- **Green line:** ≥ 708 tests passing (no regression; new tests add to the
  count). The ELF byte-identity test must be updated for the new stub length.
- **Done when:** `build.sh` produces a fixpoint with `entry-stub-v3` (using
  transitional `init-commit` ≥ 256 MB until E90/E91), the cross-check test
  passes, and `bin/chirality-bin < trivial.chiral > /tmp/elf && /tmp/elf` prints "ok"
  and exits 0. Startup `VmRSS` is sub-MB (with final 256 KB `init-commit`).

## 6. Residue & links

- **Deliberately unbuilt by this SPEC:**
  - **Runtime growth** — E90 (`nb-arena-grow`, `mprotect`-doubling crossing
    that commits the next chunk of this reservation) + E91 (check-first
    `x-alo`/`x-bnw` + shared out-of-line grow stub). E89 establishes only the
    reservation, the initial commit, and the three arena cells
    (`heapptr`/`heapend`/`heapreserve`) those siblings consume.
  - **`heapend` cell format** — whether it stays a raw 8-byte label (writable
    via `mov [moffs64]`) or becomes an addressable `[len][payload]` cell (for
    `nb-put-u64`/`nb-get-u64`). DEFERRED to E90.
  - **JIT `_map_rw` disposition** — whether the in-process JIT arena adopts
    reserve-commit or pins `fixed-trap`. DEFERRED to E81.
  - **Peak-heap measurement tooling.** Home: a chirality-internal counter in the
    bump allocator or an external `/proc/<pid>/maps` script. TBD.
- **Follow-on:** E90 (`nb-arena-grow` crossing) consumes E89's `base` (from
  `heapptr`), `heapend` (committed end), and `heapreserve` (reservation
  ceiling). E91 (check-first allocators) is a prerequisite for safe growth —
  without it, a bump-allocator store past `heapend` faults on unmapped VA.
  E81 (`Alloc` discipline) decides whether `fixed-trap` programs use the old
  fully-committed pattern or the new reserve/commit one.
- **Related:** [[E89-arena-init]] · [[E90-arena-grow-crossing]] ·
  [[E91-growing-allocator]] · [[E81-alloc-discipline]] ·
  [[E76-syscall-chokepoint]] · [[E21-arena]] · [[E20-loader]] ·
  `scaffold/lib/compile-emit.chiral` (the constant authority) ·
  `scaffold/chirality/native.py:57,741,555` (the mirror + JIT arena) ·
  `scaffold/lib/mach-x64.chiral:258` (x-fin, the three arena cells) ·
  `scaffold/lib/crossing-wraps.chiral` (mprotect entry) ·
  `scaffold/lib/ports.chiral` (mprotect extern) ·
  `.planning/SCRIBA-UNBLOCK-MAP.md` §"S17 makeup" (the S17-A/B/C sequencing
  for transitional `INIT_COMMIT` until E90/E91 land).
