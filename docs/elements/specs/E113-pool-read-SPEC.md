---
element: E113
slug: pool-read
title: `Pool` region read/peek crossing: `pool-read` (offset, len → `Bytes` + the threaded `(Pool n)` cap, memfd read in place) — the read companion to the existing `pool-write`, so a `Pool`-backed store (E111 Grid) supports O(1) indexed reads; shares the Pool-runtime-length question with E107 (`Pool n` is erased, but a bounded read needs the length at runtime)
kind: BUILD-PROPER
example: examples/E113-pool-read.md
status: audited
updated: 2026-08-12
---

# E113 SPEC — `Pool` region read/peek crossing (`pool-read`)

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 4 steps are executable at HEAD.
> `lib/ports/pool.port:30` carries `pool-read`, commented `E113/E120`. Steps
> 1-2 self-annotate DONE (E120). Bucket and evidence:
> `records/spec-tier-triage.md`. This file was not rewritten and its `status:`
> was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

> **✅ RESOLVED at spec-audit (2026-08-12) — E113 conforms to E120 (already shipped).**
> The spec-audit found E120 (commit 604ce36) **already shipped native `pool-read`**:
> extern + `PoolReadR` live in `ports.chiral:38,91`, native `nb-pool-read-t` at
> `sys-tal.chiral:1030`. E120 shipped **single-arm `(pr-r (bs Bytes) (1 p (Pool n)))`
> with halt-on-OOB** (`nb-arena-fail`). This spec originally designed a two-arm
> OOB-as-value shape; **that is retired — E113 conforms to E120's shipped shape.**
> Rationale: (1) `pool-write` already halts on OOB, so a value-returning read would
> be an inconsistent pair; (2) an OOB pool read is a caller *logic bug* (a Grid's
> `idx = row*cols+col` is in-bounds by construction), not a recoverable boundary —
> halt-as-assertion is correct; (3) the boundary-sums directive governs which-of-N
> *classification*, and errors-as-values (E29) governs genuinely-fallible ops — a
> bounds violation is neither; the chirality-principled "safe read" is a
> **refinement-typed in-bounds offset** (OOB made *unrepresentable*), noted as the
> future path (§6), not OOB-as-value. **Net: the native leg of E113 is DONE (E120);
> E113's only residue is the optional Python-advisory oracle binding `_poolread`
> matching `pr-r` (non-gating per the python-advisory ruling).** Sections below are
> revised to this reality.

## 1. Deliverable

- **Already shipped by E120 (the substance of E113):** the `pool-read` crossing
  exists — the extern `(extern pool-read (-> (0 n I64) (=> (1 p (Pool n)) I64 I64
  (PoolReadR n))))` + the `PoolReadR` sum `(pr-r (bs Bytes) (1 p (Pool n)))` in
  `ports.chiral:38,91`, and the **native** `nb-pool-read-t` (`sys-tal.chiral:1030`):
  a bounds-checked byte-loop read of `len` bytes from `base+off`, threading the
  live `(Pool n)` back, **halting (`nb-arena-fail`) on OOB** — consistent with
  `pool-write`. A `Pool`-backed store (E111 Grid) can already do O(1) indexed reads
  natively. **This is the read half of the arena, and it is built.**
- **This spec's remaining residue (optional):** the **Python-oracle** host binding
  `@impl("pool-read")` `_poolread` in `impl_ports.py` — a `mm[off:off+len]` slice,
  bounds-checked against the tuple `size`, returning `pr-r`, **halting on OOB to
  match native**. Per the python-advisory ruling (`docs/testing-floors.md`) the oracle is
  advisory, not gating — so this binding is optional parity cleanup, not a blocker.
- **Non-goals (residue in §6):** the two-arm OOB-as-value shape (retired — see the
  banner); a `pool-len` accessor crossing (length rides the host tuple / surface
  reuses `Region.cap`); a `region-read` wrapper (that is E111's job); a
  refinement-typed in-bounds offset (the future "safe read" ergonomics, §6).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E113 postdates the CONFORMANCE-MAP snapshot;
  treat as BUILD-PROPER (catalog row: "Not built — `mem-region.chiral`/`pool-write`
  only ever WRITE; no read/peek crossing exists"). The reference class is OURS: the
  work extends the real `ports.chiral`/`impl_ports.py` `Pool` machinery, it does not
  port an external.
- **Live code this composes with (name, do NOT respec):**
  - `lib/ports/pool.port:13` — `(porttype Pool (n I64))`; `:15` — `PoolR`
    (`pool-r (1 pool (Pool n)) (1 fd Fd)`); `:26` `pool-create`; `:27`
    `pool-write : (-> (0 n I64) (=> (1 p (Pool n)) I64 Bytes (Pool n)))` — the
    line-for-line shape mirror; `:31` `pool-close`. `RecvR` (`lib/ports/sock.port:22`) / `AvailR`
    (`mem-region.chiral:65`) are the precedent for a linear-field-carrying result sum.
  - `scaffold/chirality/impl_ports.py:287` `_poolwrite(_n, pv, off, data)` — the host
    tuple `("pool", mm, size)` unpack + the bounds check + `mm[off:off+len] = data`
    store; `:267` `_poolcreate` (records `size` via `ftruncate`+`mmap`); `:277`
    `_poolclose` (reads `_, mm, size = pv`, gets its `munmap` length from the same
    tuple — the precedent that the runtime length already lives host-side).
  - `lib/memory/mem-region.chiral:23` — `Region` carries `cap` (the value the pool
    was created with, agreeing with `n` by construction), the surface-level length
    witness; `:74` `region-close`. E111 will thread `pool-read` through here.
- **True delta (post-E120):** the `PoolReadR` sum + `pool-read` extern + native
  `nb-pool-read-t` are **already built** (E120). The only thing E113 still adds is
  the **optional** `_poolread` Python-oracle host function in `impl_ports.py`, so
  the advisory python floor matches native. No change to `Pool`'s representation,
  no new syscall, no new TAL, no changes to `pool-write`/`pool-create`/`pool-close`.
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

## 3. Decisions

Every open question from the example §6 (and the load-bearing §4 calls),
dispositioned. RESOLVED only when derivable from a settled doc/precedent (cited);
genuinely novel design goes to NEEDS-AUTHOR and is surfaced, never answered here.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Shape of `pool-read` — signature + result type | **RESOLVED → as shipped by E120** | Signature mirrors `pool-write` (`ports.chiral:91`): erased bound `(0 n I64)`, then `(=> (1 p (Pool n)) I64 I64 (PoolReadR n))`. The result sum is **single-arm `(pr-r (bs Bytes) (1 p (Pool n)))`** (`ports.chiral:38`) — a dedicated sum because a generic `Pair` cannot hold a linear field (the `RecvR`/`AvailR` pattern). Built by E120, not a new decl. |
| 2 | Where does the runtime length come from (E113⊗E107 shared question) | RESOLVED | No new length-exposing crossing. The length lives in the host port value `("pool", mm, size)` (`impl_ports.py:273`); `pool-read` bounds-checks against `size` host-side exactly as `_poolwrite` (`:289`) and `_poolclose`'s `munmap` (`:278`) already do. Where surface code needs the length as a value, reuse `Region.cap` (`mem-region.chiral:23`, a total pure field read — keeps pure code pure). Recommend against a `pool-len` crossing and a length-carrying `Pool` variant (both duplicate what already rides in the host value / `cap`). |
| 3 | OOB behavior — halt (like `pool-write`) or return a value | **RESOLVED → halt-on-OOB (conform to E120)** | E120's `nb-pool-read-t` **halts via `nb-arena-fail`** on `off<0 ∨ off+len>size`, consistent with `pool-write`'s halt. The earlier "OOB-as-value" design is retired (banner): an OOB pool read is a caller logic bug (a Grid index is in-bounds by construction), not a recoverable boundary — halt-as-assertion is correct, and the chirality "safe read" is a refinement-typed in-bounds offset (OOB unrepresentable), not a value arm. The oracle `_poolread`, if built, halts too (parity). |
| 4 | New `nb-*` TAL body needed? | **RESOLVED → already built (E120)** | `nb-pool-read-t` (`sys-tal.chiral:1030`) is the native body: `nb-get-u64` base+size from the `[base\|size]` cell, bounds-check, `nb-copy` `len` bytes into a fresh `ti-bnew` cell, return `(pr-r bytes pool)` via `ti-cona`. Crossing-wraps row `"pool-read"→"nb-pool-read"` (`crossing-wraps.chiral:50`). No `pread(2)`, no fresh `mmap`. |
| 5 | The shared **native Pool representation** that E107/E111/E113 all gate on for native lowering — mint it as its OWN element or absorb it into whichever of E107/E111/E113 implements first? | **RESOLVED → minted as its own element(s), and IMPLEMENTED** (author, `TUI-PRIMITIVES.md` §Decisions rows 5–6, 2026-08-12) | The recommendation (a single shared native-Pool element, not three drifting copies) was taken: the mint was split into **`MEM·E122`** native `pool-create` (memfd→ftruncate→mmap→box `[base\|size\|fd]`) + **`MEM·E120`** native `pool-write`/`pool-read`/`pool-close` bodies + the `[base\|size]` cell witness (E114 was taken by crypto). **Both are now built** (commit 604ce36, "native Pool round-trip — create/write/read/close"; LEDGER state `built`), so the native `Pool` representation + `crossing-wraps`/`sys-linkage` entries E107/E111/E113 gate on **now exist**. This SPEC's own deliverable stays surface+oracle; its native leg is no longer author-blocked — it rides E120/E122 and becomes a scheduling follow-on (§4 Step 4, §6). |
| 6 | Does E111's `region-read` pre-check purely against `Region.cap` before crossing (keeping the pre-check off the effect membrane), with `pool-read`'s host check as backstop? | DEFERRED (E111) | Not this element's surface — E111 owns the `Region`-level wrapper. `pool-read`'s host bounds check is authoritative regardless; a pure `cap` pre-check is an E111 ergonomics choice. |

No NEEDS-AUTHOR remains: decision 5 is now resolved (native pool = E120/E122,
built) and governs only the native leg, which stays out of scope for this
surface+oracle run. `status: draft` (surface+oracle deliverable fully unblocked;
the native leg is now available as a follow-on rather than author-gated).

## 4. Change plan (ordered, commit-sized)

### Step 1 — `PoolReadR` sum + `pool-read` extern — **DONE (E120)**
- Live in `ports.chiral:38,91` as `(data PoolReadR ((n I64)) (pr-r (bs Bytes)
  (1 p (Pool n))))` + the extern. No work — verify it matches (single-arm `pr-r`).

### Step 2 — native `nb-pool-read-t` — **DONE (E120)**
- Live at `sys-tal.chiral:1030` + crossing-wraps row (`:50`), bounds-checked,
  halt-on-OOB via `nb-arena-fail`. This is the authoritative implementation.

### Step 3 (residue, OPTIONAL) — `_poolread` Python-oracle binding
- **Target:** `scaffold/chirality/impl_ports.py` — beside `_poolwrite`.
- **Change:** add `@impl("pool-read")` `_poolread(_n, pv, off, length)`: unpack
  `_, mm, size = pv`; if `off < 0 or off + length > size` **halt** the same way
  `_poolwrite` does on OOB (match native — NOT a value arm); else
  `bs = bytes(mm[off:off+length])` and return the `pr-r` value carrying `bs` and
  `pv` (same value-encoding `_poolwrite`/`_sockrecv` use). **Optional** — the
  python floor is advisory (`docs/testing-floors.md`); build only to keep the advisory
  floor legible.
- **Size:** ~S. Commit: `E113: _poolread advisory-oracle binding (matches native pr-r + halt)`.
- 2026-09-04: cut Python oracle, no live successor.

### Step 4 — round-trip sample (native, authoritative)
- **Target:** E120 already ships `tools/test/samples/e120_pool_roundtrip.prog`
  (create → write → read → close, exit 42). E113's read leg is exercised there.
  If a read-focused sample is wanted, extend it: `pool-read` the written range back,
  assert byte-equality on `pr-r`, threaded `(Pool n)` live. Native run is the gate.
- **Size:** ~S (or none — E120's round-trip already covers it).

## 5. Conformance gate

- **Golden behavior:** `pool-read(pool-write(p, off, bs), off, |bs|)` returns
  `pr-r` carrying `bs` and threads the same `(Pool n)` onward; an offset+len past
  the region **halts** (`nb-arena-fail`, like `pool-write`). Linear resources
  threaded through `case`, never `let`.
- **Gate, honestly tiered:**
  - **(a) Native run (authoritative — already green):** E120's
    `e120_pool_roundtrip.chiral` compiles through B1 and runs to **exit 42** (create
    → write → read → close), with the linear `(Pool n)` threaded through `case`.
    Native codegen SUCCEEDS (E120 wired the crossing) — the earlier "no emitted
    label" expectation is void. `let`-threading the `(Pool n)` still yields
    `load: field binder usage mismatch` — the `case`-not-`let` invariant holds.
  - **(b) Oracle parity (advisory only):** IF `_poolread` (Step 3) is built, a
    write-then-read `pr-r` byte-equality passes under the Python oracle. Non-gating
    per `docs/testing-floors.md`.
- **Tests to add:** none required beyond E120's shipped round-trip; a read-focused
  extension is optional. `pool-read(pool-write(...))` byte-equality is the golden.
- **Green line:** native floor green (E120 round-trip); ledger-lint clean. The
  advisory python green-line moves only if the optional `_poolread` is built.
- **Done when:** already met on the native floor (E120). The optional oracle-parity
  leg is done when `_poolread` matches native (`pr-r` + halt) and the advisory
  round-trip passes.

## 6. Residue & links

- **Built (was residue, now shipped by E120):**
  - **Native `pool-read`** — `nb-pool-read-t` (`sys-tal.chiral:1030`) + crossing-wraps
    row (`:50`) + the `pr-r` sum + extern (`ports.chiral:38,91`). Commit 604ce36.
- **Deliberately unbuilt:**
  - **`_poolread` Python-oracle binding** — the optional advisory-parity leg (§4
    Step 3); non-gating per `docs/testing-floors.md`.
  - **`region-read` `Region`-level wrapper** — E111's job (threads `pool-read`
    through `Region`, optional pure `cap` pre-check per §3 decision 6).
  - **Refinement-typed offset variant** (a `mem-put-checked`-style compile-time
    in-bound offset) — the chirality-principled "safe read" that makes OOB
    *unrepresentable*; future ergonomics, the successor to today's halt-on-OOB.
  - **No `pool-len` crossing / length-carrying `Pool` variant** — rejected by §3
    decision 2 (length rides host tuple; surface reuses `Region.cap`).
  - No OOB-as-value arm — retired (banner; conforms to E120's halt).
- **Follow-on:** unblocks E111 (Pool-backed Grid indexed reads); pairs with E107
  (`pool-close`→`munmap`) on the shared native-Pool work.
- **Related:** [[E113-pool-read]], [[E111-pool-grid]], [[E107-pool-close-munmap]],
  [[banks/port]], [[banks/memory]], `docs/definitions/pattern-boundary-sums.md`
  (E29 errors-as-values).
