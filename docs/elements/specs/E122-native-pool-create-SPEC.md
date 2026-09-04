---
element: E122
slug: native-pool-create
title: "Native `pool-create` mint: size → `PoolR` via memfd→ftruncate→mmap, box the `[base|size]` cell + assemble `(pool-r cell fd)`"
kind: BUILD-PROPER
example: examples/E122-native-pool-create.md
status: audited
updated: 2026-08-12
---

# E122 SPEC — Native `pool-create` mint (size → `PoolR`)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the native `pool-create` mint exists — a `nb-pool-create-t`
  TAL body in `sys-tal.chiral`'s `sys-lib` plus a `(pair "pool-create" "nb-pool-create")`
  row in `crossing-wraps.chiral`, so a native ELF can create a `Pool` (a byte `size`
  crosses `memfd_create`→`ftruncate(size)`→`mmap(fd,size)`, boxes a 16-byte
  `[base|size]` cell, and assembles the `PoolR` con `(pool-r cell fd)`) instead of
  running only under the Python oracle (`_poolcreate`, `impl_ports.py:267`). Today
  `cw-lookup "pool-create"` returns `none` — the op does not lower at all.
- **Non-goals:** E120's `pool-write`/`pool-read`/`pool-close` bodies (they *consume*
  this `Pool`); the `pool-read` extern declaration (E113); a shared `nb-memcopy`
  (E120 decision #2, DEFERRED); threading an explicit `MemCap`/allocator port
  (decision #2 below, DEFERRED). Residue in §6.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E122 postdates the CONFORMANCE-MAP snapshot
  (split from E120 on 2026-08-12). Treat as **BUILD** (a designed feature with no
  prior lowering).
- **Live code this composes with (reuse, do NOT respec):**
  - `nb-sys-memfd-t` (`sys-tal.chiral:75`), `nb-sys-ftruncate-t` (:88),
    `nb-sys-mmap-t` (:99) — the E28 region-acquire syscalls this mint sequences;
    already registered and exercised by the self-hosted arena
    (`nb-arena-commit-t`:133 / `nb-arena-grow-t`:174). `nb-sys-munmap-t` (:106)
    is the release side used by E120's `pool-close`, not this mint.
  - `ti-bnew` (`tal-ir.chiral:26`) — mints a fresh boxed byte cell (with the
    8-byte len header); `nb-put-u64-t` (`bytes-tal.chiral:505`) writes an 8-byte
    slot, addressing `ptr + off + 8` (the boxed-cell payload offset — the +8 the
    header already accounts for).
  - The crossing table shape: flat `(op → wrapper)` `List (Pair Str Str)` with
    linear `cw-lookup` (`crossing-wraps.chiral:13-47`); `mmap → nb-sys-mmap` (:26)
    is the exact add-a-row precedent. `cw->binds`/`sys-bindings`
    (`sys-linkage.chiral:91`) auto-derives the linkage from the row — its stated
    INVARIANT, no hand edit there.
  - `PoolR = (pool-r (1 pool (Pool n)) (1 fd Fd))` (`ports.chiral:34`) — the return
    con carries the memfd **fd as a separate linear field**; the typed extern face
    (`pool-create`:73) is already declared, unchanged by this element.
  - The oracle to reproduce: `_poolcreate` (`impl_ports.py:267`) —
    `memfd_create("chirality-pool",0)` → `ftruncate(fd,size)` → `mmap(fd,size)`,
    `size<=0` rejected.
  - The error-path precedent this element does *better* than the oracle:
    `open-pty` (`term.chiral:183`) threads `close` on every error path after the
    master fd is open (:190/:193/:197) and decodes negative raw returns into a
    `pty-err` sum (`<i master 0` :186, `<i rc 0` :173).
- **True delta:** one native TAL body (`nb-pool-create-t`) + one crossing row +
  the fact of the `[base|size]` cell as the `Pool`'s native mint representation
  (byte-consistent with E120 §4 step 1 and decision #3). Everything the body
  *calls* — the three E28 crossings, `ti-bnew`, `nb-put-u64`, con-construction —
  already exists.

## 3. Decisions

Every open question from example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled precedent (cited); DEFERRED to a
named home; NEEDS-AUTHOR surfaced, never self-answered.

| # | Question (example §6) | Disposition | Rationale / citation |
|---|-----------------------|-------------|----------------------|
| 1 | Partial-failure cleanup: mirror the oracle's fd leak, or handle the failing path the arena way? | **RESOLVED — arena-fail (`exit_group`) on the failing path; no cleanup, no error value** | On failure (`size<=0`, or `memfd`/`ftruncate`/`mmap` returns `<0`), follow the **arena-fail shape**: call `nb-arena-fail(errno)` which `exit_group`s (`sys-tal.chiral:118`, "honest fail, never returns") — matching E120-SPEC and the arena's own allocation-failure discipline. Because it never returns and the kernel reclaims the memfd + mapping on process exit, **no explicit cleanup and no error value are needed** (the extern's return type `(PoolR n)` has no error arm). Consistent with boundary-sums: a fatal exit is control flow, not a value-space sentinel. (Supersedes the earlier `pool-err`-return disposition, which named constructors that do not exist.) |
| 2 | Capability parameter: keep the E28 sys crossings as substrate externs, or thread a `MemCap`/allocator port now? | **DEFERRED — keep E28 crossings as category-B substrate externs** | E122 crosses `nb-sys-memfd`/`nb-sys-ftruncate`/`nb-sys-mmap` ambiently, matching how the self-hosted arena and every current memory crossing work (`sys-tal.chiral:75/88/99`, used by `nb-arena-commit-t`:133). Threading an explicit `MemCap`/allocator port is a cross-cutting **no-ambient-authority refactor of the whole memory-crossing layer** — a rung-2 capability-arc element, not E122's scope (see `.planning/RUNG2-SECURITY-MODEL.md` — attenuated/per-user possession is the rung-2 posture). DEFERRED with that rationale — surfaced, not silently dropped; no element minted here. |
| 3 | Crossing-return typing: does the raw-I64→sum boundary live at the E28 layer or inside `nb-pool-create-t`? | **RESOLVED — the boundary lives INSIDE `nb-pool-create-t`** | The success path constructs the single-con `(pool-r cell fd)` directly inside `nb-pool-create-t` (the extern is `(=> (w n I64) (PoolR n))` — NOT a sum). The failure path is the arena-fail `exit_group` (control flow), so surface code never sees a sentinel value. This is the boundary-sums discipline for this crossing: the only which-of-N is well-typed-record vs fatal-exit, and fatal-exit is control flow, not an encoded value. Cite `ports.chiral:34,73` (the single-con `PoolR` + extern) and `sys-tal.chiral:118` (arena-fail). |

No decision blocks §4: #1 and #3 are RESOLVED (specced into Step 1 below), #2 is
DEFERRED with its home. Frontmatter stays `status: draft`.

## 4. Change plan (ordered, commit-sized)

This is E120 §4 step 1, made byte-consistent with E120's design (decision #3 —
the `[base|size]` boxed cell + `+8` payload convention) and extended with
decisions #1/#3 (arena-fail on the failing path + direct single-con `PoolR`
construction).

### Step 1 — `nb-pool-create-t` (the mint) + its crossing row
- **Target:** `scaffold/lib/sys-tal.chiral` — new `def nb-pool-create-t TIFn`,
  registered in `sys-lib` (:696) alongside `nb-sys-mmap-t`; **and**
  `scaffold/lib/crossing-wraps.chiral` — one row `(pair "pool-create" "nb-pool-create")`
  in `crossing-wraps` (:13), before the terminating `nil` (add one `cons`).
- **Change:** reproduce `_poolcreate` natively, with honest cleanup.
  - reg0 = `size` (the `w n` runtime arg). **Gate:** reject `size<=0` via the
    arena-fail shape → `nb-arena-fail(-22)` (`-EINVAL`), which `exit_group`s and
    never returns (`sys-tal.chiral:118`); no crossing performed (mirrors
    `_poolcreate`'s rejection, but as fatal control flow, not a value).
  - `fd = nb-sys-memfd("chirality-pool", 0)` (crossing 1). Decode: `(<i fd 0)` →
    `nb-arena-fail(fd)` (honest fail, never returns — decision #1).
  - `rc = nb-sys-ftruncate(fd, size)` (crossing 2). Decode: `(<i rc 0)` →
    `nb-arena-fail(rc)` (the kernel reclaims the memfd on process exit — decision #1).
  - `base = nb-sys-mmap(0, size, PROT_RW=3, MAP_SHARED, fd, 0)` (crossing 3).
    Decode: `(<i base 0)` → `nb-arena-fail(base)` (the kernel reclaims the memfd
    on process exit — decision #1).
  - Mint the Pool cell: `cell = ti-bnew 16`; `nb-put-u64(cell, 0, base)`;
    `nb-put-u64(cell, 8, size)` (boxed cell, base = slot 0 @ off 0, size = slot 1
    @ off 8; the `+8` payload offset is applied by `nb-put-u64` — E120 decision #3,
    the arena's `-8` does NOT apply).
  - Assemble `(pool-r cell fd)` directly via ordinary con-construction — the
    single-con `PoolR` record (`ports.chiral:34`), NOT a sum, with `fd` as the
    separate linear field. Return the `PoolR`.
  - `sys-linkage`'s `cw->binds`/`sys-bindings` derive the linkage automatically
    from the new row (INVARIANT — no `sys-linkage.chiral` edit).
- **Size:** ~L (the mint + `PoolR` assembly + the size-gate and three
  crossing-decode arena-fail paths).

### Step 2 — the `pool-create` checker-level test + green-line
- **Target:** `scaffold/tests/test_e122_pool_create.py` (mirroring
  `test_e106_linear_cap.py` / `test_compile_run_chirality.py`) + a small `.chiral`
  program that mints a pool.
- **Change:** a program that `pool-create`s a `size>0` region and typechecks to a
  well-typed `(PoolR n)` — asserting the checker **ACCEPTS** the mint (it lowers,
  links, and produces a balanced-linear `Pool` value). Plus the two linear
  negatives, asserting the checker **REJECTS** them: double-consume, and
  drop-without-close of the `(Pool n)`/`Fd` fields. There is **no standalone
  native exit-42 run** at E122-first sequencing — nothing consumes the pool
  natively until `pool-close`/`fd-close` gain `crossing-wraps` rows at `SYS·E107`;
  the native value path is exercised by E120's round-trip test.
- **Size:** ~M.

## 5. Conformance gate

- **Sequencing:** E122 sequences **FIRST in Wave 2** (E120 decision #1). E122
  standalone conformance is **type-check + checker-negatives only**: the mint
  typechecks and produces a well-typed `(PoolR n)`, and the linear negatives
  (double-consume, drop-without-close of the `(Pool n)`/`Fd` fields) are
  checker-rejected. There is **NO standalone native exit-42 run** — at E122-first
  sequencing nothing consumes the pool natively (`pool-close`/`fd-close` have no
  `crossing-wraps` row until `SYS·E107`). The **native exit-42 proof rests on
  E120's joint round-trip** (`create→write→read→close`) once E107 provides the
  close crossings — E122 mints the `Pool` value E120's three ops are inert without.
- **Golden behavior:** for `size>0`, `pool-create` lowers and produces a `Pool`
  byte-identical in layout to `_poolcreate`'s — a 16-byte `[base|size]` cell
  (base @ off 0, size @ off 8) plus the memfd `fd` as a separate linear field —
  such that an E120 `pool-write`/`pool-read` round-trips through it. On failure
  (`size<=0`, or a crossing returning `<0`), the mint takes the **arena-fail
  shape**: `nb-arena-fail(errno)` `exit_group`s and never returns
  (`sys-tal.chiral:118`); the kernel reclaims the memfd + mapping on process exit,
  so there is no cleanup and no error value (the extern's `(PoolR n)` has no error
  arm — decisions #1/#3). Fatal exit is control flow, not a value-space sentinel.
- **Linear negatives stay checker-rejected:** double-consuming the `PoolR`, or
  dropping it without discharging its two linear fields (the cell via
  `pool-close`, the fd via `fd-close`), must remain a type error — the leak the
  oracle tolerates stays untypeable.
- **Reblob-`cmp` self-hosting gate:** `crossing-wraps.chiral` and `sys-tal.chiral`
  are both in B1's compile blob, so after promoting the new B1, reblob and
  self-compare: `chirality_blob … | B1 < blob | cmp - scaffold/build/B1` — reblob +
  promote **only if** it differs (the self-hosting fixpoint must still reproduce
  byte-identically).
- **Tests to add:** `test_e122_pool_create.py` asserts the checker **ACCEPTS**
  the mint (typechecks to a well-typed `(PoolR n)`) and **REJECTS** the two linear
  negatives (double-consume; drop-without-close of the `(Pool n)`/`Fd` fields).
  The native value path is exercised by E120's round-trip test, not here.
- **Green line:** 704 → ≥ 705; ledger-lint clean.
- **Done when:** the mint compiles with B1, the checker accepts it and rejects the
  two linear negatives as specified, and the reblob self-compare is byte-identical
  (or a clean reblob+promote if the blob-resident files changed).

## 6. Residue & links

- **Deliberately unbuilt:**
  - **Recoverable `pool-create` (boundary-sums ideal) → DEFERRED.** A
    `pool-create` returning a `PoolCreateR` result sum (so ENOMEM/EMFILE is
    handled, not fatal) would be the boundary-sums ideal, but the extern
    signature `(=> (w n I64) (PoolR n))` (`lib/ports/pool.port:26`), the `_poolcreate`
    oracle, and every E120 consumer of `pool-r` assume the non-recoverable
    `(PoolR n)`. Reshaping to a recoverable sum is a pool-family-wide refactor
    (re-opens the extern + oracle + E120) — surfaced, not dropped; same posture
    as the MemCap deferral.
  - **`MemCap`/allocator port** threading `pool-create` (decision #2) — DEFERRED
    to the rung-2 capability arc (`.planning/RUNG2-SECURITY-MODEL.md`); the E28
    crossings stay category-B substrate externs. No element minted here.
  - E120's `pool-write`/`pool-read`/`pool-close` bodies + the `pool-read` extern
    (E113) — the consumers of this `Pool`, their own runs.
  - Inlining `fd` into the cell (a 3-slot `[base|size|fd]` variant) — the `PoolR`
    split keeps the fd separate today (E120 decision #3 leaves the door).
- **Follow-on this unblocks:** **MEM·E120** (`pool-write`/`pool-read`/`pool-close`
  — its round-trip gate needs this mint), **SYS·E107** (`pool-close` native),
  **MEM·E111** (cell-store), **MEM·E113** (native `pool-read`).
- **Related:** [[E122-native-pool-create]] · [[E120-native-pool]] ·
  [[E28-mmap-memfd-crossings]] · the `open-pty` error-path-cleanup /
  boundary-sum precedent (`term.chiral`) · `docs/pattern-boundary-sums.md`.
