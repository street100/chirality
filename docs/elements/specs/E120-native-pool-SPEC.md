---
element: E120
slug: native-pool
title: Native `Pool` representation: wire the `Pool` porttype ops (`pool-write`/`pool-read`/`pool-close`; `pool-create` split to E122) to native — a `[base|size]` boxed-cell witness + `crossing-wraps`/`sys-linkage` entries over the existing `nb-sys-memfd`/`ftruncate`/`mmap`/`munmap` (E28) — so linear `Pool` caps lower to native (today Python-oracle-only in `impl_ports.py`). The shared substrate that E107 `pool-close`, E111, and E113 all gate on for a native run.
kind: BUILD-PROPER
example: examples/E120-native-pool.md
status: audited
updated: 2026-08-12
---

# E120 SPEC — Native `Pool` representation

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **SCOPE-CORRECTED 2026-08-12:** `pool-create` is **split to MEM·E122** (decision #1);
  E120 owns `pool-write`/`pool-read`/`pool-close` only. The `[base|size]` cell layout,
  the round-trip gate, and §4 step 1 (the create body) are retained here as the shared
  design — E122 extracts its contract from them.
- **After this runs:** the `Pool` crossings lower to native machine code — `pool-write`,
  `pool-read`, `pool-close` here in E120, with `pool-create` the **E122** mint sequenced
  first. A native ELF can `pool-create` (E122) a region, `pool-write` bytes into it,
  `pool-read` them back, and `pool-close` (munmap) it, with the linear `(1 p (Pool n))`
  cap threaded once and surrendered on close. Today none of the four lower at all (no
  `pool-*` row in `crossing-wraps.chiral`; `cw-lookup` returns `none`) — they run only
  under the Python oracle (`impl_ports.py`). The native runtime witness of a held
  `(Pool n)` is a **2-slot `[base | size]` boxed cell** (`base` = mmap address,
  `size` = the runtime witness of the type-erased `n`).
- **Concretely new in the tree (E120):** three `crossing-wraps` rows
  (`pool-write`/`pool-read`/`pool-close`) + three `nb-pool-*-t` TAL bodies registered in
  `sys-tal.chiral`'s `sys-lib`; `sys-linkage`'s `sys-bindings` derives the linkage
  automatically from the rows (no hand edit there). **E122 adds the fourth** (the
  `pool-create` row + `nb-pool-create-t`). Typed faces in `ports.chiral` are unchanged —
  they already declare the externs (`pool-create`:83, `pool-write`:84, `pool-close`:85).
- **Non-goals:** the `pool-read` **extern declaration** (signature/quantities) is
  E113's to mint — E120 supplies only its lowering wrapper (`nb-pool-read-t`) and
  the crossing row. A shared generic `nb-memcopy` primitive is NOT built (the
  copy is inlined; see decision #2). See §6 for full residue.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E120 postdates the CONFORMANCE-MAP
  snapshot. Treat as **BUILD** (a designed feature with no prior lowering).
- **Live code this composes with (reuse, do NOT respec):**
  - `nb-sys-memfd-t` (`sys-tal.chiral:75`), `nb-sys-ftruncate-t` (:88),
    `nb-sys-mmap-t` (:99), `nb-sys-munmap-t` (:106) — the region
    acquire/release syscalls, already registered and exercised by the
    self-hosted arena (`nb-arena-commit-t`:133 / `nb-arena-grow-t`:174).
  - `nb-get-u64-t` (`bytes-tal.chiral:431`) / `nb-put-u64-t` (:505) — read/write an
    8-byte slot; both address `ptr + off + 8` (the boxed-cell payload offset).
  - `ti-bnew` / `ti-bptr` / `ti-bget` / `ti-bput` (`tal-ir.chiral:26-34`) — fresh
    byte cell, payload-address, per-byte load/store; the copy-loop and
    cell-mint primitives.
  - The crossing table shape: flat `(op → wrapper)` `List (Pair Str Str)` with
    linear `cw-lookup` (`crossing-wraps.chiral:13-47`). `write-fd → nb-sys-write`
    (:35, the E105 precedent) and `mmap → nb-sys-mmap` (:26) are the exact
    add-a-row shape. `cw->binds` (`sys-linkage.chiral:91`) auto-derives
    `sys-bindings` from `crossing-wraps` — its stated INVARIANT.
  - The oracle to reproduce: `_poolcreate` (`impl_ports.py:267`,
    memfd→ftruncate→mmap, `size<=0` rejected), `_poolwrite` (:287, bounds
    `off<0 || off+len>size` then store), `_poolclose` (:277, zeroize `mm[:size]`
    then `mm.close()`). `PoolR = (pool-r (1 pool (Pool n)) (1 fd Fd))`
    (`ports.chiral:34`) carries the memfd **fd as a separate linear field**.
- **True delta:** the four native TAL bodies + four crossing rows + the fact of
  the `[base|size]` cell as the `Pool`'s native representation. Everything the
  bodies *call* already exists.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Is native `pool-create` in E120's scope, or a split element? | **RESOLVED — SPLIT OUT → MEM·E122** (author override exercised 2026-08-12) | E120 owns `write`/`read`/`close`; the `pool-create` mint (memfd→ftruncate→mmap→box `[base|size]`, assemble `PoolR` with the fd field) becomes **MEM·E122**, sequenced FIRST in W2. The three E120 ops are inert without a native `Pool` value, so **E122 must land before E120's round-trip conformance gate (§5) can run** — E120's round-trip is the conclusive exerciser for both. E122's contract is exactly this spec's §4 step 1 (`nb-pool-create-t` + its `crossing-wraps` row); extract into `E122-*-SPEC.md` before implement. (Prior resolution was keep-IN; the author split it — flag honored, not silently kept.) |
| 2 | Copy mechanism for `pool-write`/`pool-read` — shared `nb-memcopy` crossing vs inlined byte loop? | **RESOLVED — inlined `ti-bget`/`ti-bput` byte loop for v1; shared `nb-memcopy` DEFERRED** | Verified: **no `nb-memcopy` TAL body exists** (grep of `scaffold/lib/` finds only `ti-bget`/`ti-bput` primitives, no memcopy wrapper). `pool-write`/`pool-read` are bounded copies over `base+off`; an inlined `ti-bget src → ti-bput dst` loop of length `len` needs no new primitive and matches `bytes-tal.chiral`'s existing byte-loop idiom (:39-59). A shared `nb-memcopy` is a later optimization — DEFERRED to a follow-on (no element minted; note in §6). |
| 3 | Native `Pool` cell layout + `nb-get-u64` payload-offset convention | **RESOLVED — 2-slot boxed cell `[base(off 0) | size(off 8)]`, minted via `ti-bnew 16`** | Cited to the arena's boxed-cell idiom. A `ti-bnew`'d cell carries an 8-byte length header, and `nb-put-u64`/`nb-get-u64` already add **+8** to reach the payload (`bytes-tal.chiral:431/505`). So a **boxed** Pool cell reads slot 0 at `off 0` and slot 1 at `off 8` **directly, with no compensation**. This is the explicit reconciliation of the `+8` payload convention vs the arena's `-8`: `nb-arena-commit-t` (:157) uses `off = -8` **only because** `heapend_cell` is a *RAW* 8-byte slot with no len header; the Pool cell is a proper boxed cell, so the `-8` does **not** apply here. Layout fixed: boxed, 16-byte payload, `base` = slot 0, `size` = slot 1. |
| 4a | Whose extern is `pool-read`? | **RESOLVED — E113 mints the extern; E120 supplies the wrapper** | `ports.chiral` has no `pool-read` extern today; its signature/quantities are settled in E113. E120 delivers `nb-pool-read-t` + the `pool-read → nb-pool-read` crossing row so the lowering machinery is ready when E113's extern lands. |
| 4b | Zeroize-on-close hygiene | **RESOLVED — preserve the oracle's `mm[:size]=0` natively** | `_poolclose` (`impl_ports.py:277`) zeroizes before `mm.close()` (drop hygiene, per the memory-model note it cites). Native `nb-pool-close-t` reproduces it: a bounded `ti-bput 0` store loop over `[base, base+size)` **before** `nb-sys-munmap`. Kept to match oracle behavior exactly (conformance is byte-for-byte against the oracle). |

No decision blocks §4. Decision #1 is now **RESOLVED** — the author exercised
the split, so `pool-create` is **E122's** (its native mint = Step 1's body,
retained here only as the shared design E122 extracts). E120 delivers Steps 2–5
(`write`/`read`/`close` + the three crossing rows + the round-trip gate); the
round-trip in §5 is the conclusive exerciser for **E122 + E120 together** and
requires E122 to land first.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `[base|size]` cell repr + `nb-pool-create-t`
- **Target:** `scaffold/lib/sys-tal.chiral` — new `def nb-pool-create-t TIFn`, registered in `sys-lib` (:923) alongside `nb-sys-mmap-t`.
- **Change:** reproduce `_poolcreate` natively. reg0 = size (the `w n` runtime arg). Reject `size<=0` (error-as-value, oracle raises — mirror the arena-fail shape). Call `nb-sys-memfd` → fd; `nb-sys-ftruncate(fd,size)`; `nb-sys-mmap(0,size,PROT_RW=3,MAP_SHARED,fd,0)` → base. Mint the Pool cell: `ti-bnew 16`, `nb-put-u64(cell, 0, base)`, `nb-put-u64(cell, 8, size)`. Assemble the `PoolR` con `(pool-r pool-cell fd)` (fd = the separate linear field, per `ports.chiral:34`) via ordinary con-construction. Return the `PoolR`.
- **Size:** ~L (the mint + the `PoolR` assembly is the trickiest body).

### Step 2 — `nb-pool-write-t` and `nb-pool-read-t` (bounded byte copy)
- **Target:** `scaffold/lib/sys-tal.chiral` — two `def`s, registered in `sys-lib`.
- **Change (write):** reg0 = pool-cell ptr, reg1 = off, reg2 = bytes-cell ptr. `base = nb-get-u64(cell,0)`, `size = nb-get-u64(cell,8)`, `len = op-blen bytes`. Bounds: `off>=0 && off+len<=size` — else return the `p-err`-shaped error sum (never a trap; boundary-sum discipline). In range: inlined `ti-bget`/`ti-bput` loop copying `len` bytes from the bytes payload into `base+off`. Return the `(Pool n)` (reg0). **(read):** reg0 = pool-cell ptr, reg1 = off, reg2 = len. Symmetric bounds `off+len<=size`; `ti-bnew len` fresh cell; copy `base+off → payload`; return the fresh `Bytes` cell.
- **Size:** ~M each; share the bounds + copy-loop shape.

### Step 3 — `nb-pool-close-t` (zeroize + munmap)
- **Target:** `scaffold/lib/sys-tal.chiral` — one `def`, registered in `sys-lib`.
- **Change:** reg0 = pool-cell ptr. `base = nb-get-u64(cell,0)`, `size = nb-get-u64(cell,8)`. Zeroize `[base,base+size)` via a bounded `ti-bput 0` loop (decision #4b). `nb-sys-munmap(base,size)`. Return `Unit`. (The memfd fd is discharged separately by `fd-close` on the `PoolR.fd` field — not this body's job.)
- **Size:** ~M.

### Step 4 — the four `crossing-wraps` rows
- **Target:** `scaffold/lib/crossing-wraps.chiral` — four rows in `crossing-wraps` (:13), before the terminating `nil`.
- **Change:** `(pair "pool-create" "nb-pool-create")`, `(pair "pool-write" "nb-pool-write")`, `(pair "pool-read" "nb-pool-read")`, `(pair "pool-close" "nb-pool-close")`. `sys-linkage`'s `cw->binds`/`sys-bindings` derive the linkage automatically (INVARIANT — no `sys-linkage.chiral` edit). Add one `cons` to the `nil))))...` tail count.
- **Size:** ~S.

### Step 5 — the native round-trip sample + green-line
- **Target:** `scaffold/tests/` (a `test_e120_*` mirroring `test_e106_linear_cap.py` / `test_compile_run_chirality.py`) + a `TUI/samples`- or `scaffold/`-style `.chiral` round-trip program.
- **Change:** a program that `pool-create`s, `pool-write`s a known payload at an offset, `pool-read`s it back, compares, `pool-close`s, and `exit`s **42**; plus checker-rejection negatives (double-close, drop, non-linear `let`-thread) that must fail to type. Compile with B1, run, assert exit 42.
- **Size:** ~M.

## 5. Conformance gate

- **Depends on E122:** `pool-create` is E122's mint (split from this spec). **E122 must
  be built first**; this round-trip is the conclusive gate for **E122 + E120 together**.
- **Golden behavior:** a native `pool-create → pool-write off bytes → pool-read
  off len → pool-close` round-trip **compiles AND runs to exit 42** (today the
  `pool-*` ops don't lower at all — `cw-lookup "pool-write"` = `none`). The
  read-back bytes equal the written bytes; an out-of-range `off+len > size`
  yields the error-as-value (not a trap), reproducing `_poolwrite`'s bound; the
  zeroize-then-munmap of `pool-close` matches `_poolclose` byte-for-byte.
- **Linear negatives stay checker-rejected:** double-close, drop-without-close,
  and aliasing `let`-thread of `(1 p (Pool n))` must remain type errors — the
  use-after-free the C idiom leaves to convention stays untypeable.
- **Dependents reach native:** confirm **SYS·E107**'s `pool-close` now lowers,
  and that a `SockVec`-style drain over a `Pool` reaches native (was blocked on
  a native `Pool` value). E111 (cell-store) and E113 (native `pool-read` extern)
  are unblocked by the machinery, implemented in their own runs.
- **Reblob-cmp gate:** `crossing-wraps.chiral` and `sys-tal.chiral` are in B1's
  compile blob, so after promoting the new B1, reblob and self-compare:
  `chirality_blob … | B1 < blob | cmp - scaffold/build/B1` — reblob + promote **only
  if** it differs (self-hosting fixpoint must still reproduce byte-identically).
- **Tests to add:** `test_e120_native_pool.py` (native round-trip → exit 42;
  out-of-bounds → error-value; linear negatives → checker reject). Compares the
  native floor against the oracle (`impl_ports.py`) for the value path.
- **Green line:** 704 → ≥ 705; ledger-lint clean.
- **Done when:** the round-trip sample compiles with B1 and runs to exit 42, the
  three linear negatives are rejected, and the reblob self-compare is
  byte-identical (or a clean reblob+promote if the blob-resident files changed).

## 6. Residue & links

- **Deliberately unbuilt:**
  - Shared generic `nb-memcopy` crossing (decision #2) — DEFERRED, no element
    minted; a later optimization folding the inlined write/read copy loops into
    one primitive. Nobody's yet.
  - `pool-read`'s **extern declaration** — E113's deliverable (E120 ships only
    its wrapper + crossing row).
  - Inlining `fd` into the `Pool` cell (a 3-slot `[base|size|fd]` variant) — the
    `PoolR` split keeps fd separate today; a future `PoolR` merge could revisit
    the layout (decision #3 leaves the door, doesn't build it).
- **Follow-on this unblocks:** **SYS·E107** (`pool-close` native), **MEM·E111**
  (cell-store), **MEM·E113** (native `pool-read`).
- **Split element (decision #1, RESOLVED):** native-Pool *minting* (`pool-create`)
  is **MEM·E122**, not E120 — the author exercised the split 2026-08-12. Step 1's
  `nb-pool-create-t` body is retained here as the shared design E122 extracts; E120
  itself owns only `write`/`read`/`close`. No open author flag remains.
- **Related:** [[E120-native-pool]] · [[E107-pool-close]] · [[E111-cell-store]] ·
  [[E113-pool-read]] · the E105 `write-fd → nb-sys-write` crossing precedent.
