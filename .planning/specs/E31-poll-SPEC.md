---
element: E31
slug: poll
title: `poll`/`select` (the struct-passing / `pollfd` shape)
kind: REPLACE-CRUTCH
example: examples/E31-poll.md
status: audited
updated: 2026-07-27
---

# E31 SPEC — `poll`/`select` (the struct-passing / `pollfd` shape)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the `poll2` readiness crossing is chirality, not CPython — a
  hand-tal `poll(2)` syscall (`nb-sys-poll`, nr 7, 3-register) plus a
  chirality-surface wrapper that *assembles* a 2-entry `pollfd` byte cell at the ABI
  offsets, crosses once, and reads `revents` back as **typed evidence**
  (`Ready` per entry, `SysPoll2R` result: timeout / ready / errno), threading both
  linear `Sock`s back on every path. `impl_ports.py:_poll2` (the
  `select.select` crutch) is retired via the E51 binding-table flip.
- **Non-goals:** the N-ary/N-port generalization (demo is 2 ports — §6, E8); new
  byte-face floor ops (the i16 helpers are lib composites of the single-byte
  floor ops we already have); a typed deadline / expiry-effect (§3 #3); the
  `sock-view` mint itself (sysface-only, E51). `POLLOUT`/writable-wait is
  seeded in the decode but the demo events are `POLLIN` only.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the **Category C port membrane** row is
  **CONFORMS / S** — "crossing SHAPE conforms to P3; transport swap is the E51
  lane, not a reshape." So E31 is not a reshape of the port model: `ports.chiral`
  already declares `Sock`/`LSock`/`Fd`/`(Pool n)` as opaque linear porttypes in
  the frozen set, linearity + frozen-set enforced by the checker. The
  **Orchestration self-host linkage** row is **BUILD / L**, gated on E28/E29/E31,
  overlapping the **E51** REFACTOR — E31 is the transport-replacement
  forward-build half. E51 is *not built* (whole substrate still runs
  chirality-logic-over-CPython), so the binding-table flip (Step 5) lands with E51.
- **Live code this composes with (do NOT respec):**
  - `scaffold/lib/sys-tal.chiral` — the sys-tal crossing bank: `nb-sys-write/read/
    lseek/memfd/ftruncate/mmap/munmap` + `sys-lib`. The pattern is fixed:
    `(tfn "name" nargs nregs (t-seq (ti-sys dst NR (cons 0 …)) (t-ret dst)))` —
    `ti-sys`'s first slot is the destination register (tal-ir.chiral:33), which
    for these wrappers is the first free reg after the args.
    `nb-sys-poll` is a new sibling (3 registers, like `lseek`/`ftruncate`).
  - `scaffold/lib/tal-ir.chiral` (lines 26–28) — the mutable byte-cell floor ops:
    `ti-bnew dst len` (allocate; a fresh cell reads 0 by contract), `ti-bput ptr
    idx val` (single-byte write), `ti-bget dst ptr idx` (single-byte read).
    `scaffold/lib/bytes-tal.chiral` is the composite bank over them; the i16/i32
    field helpers are new composites there.
  - `scaffold/lib/ports.chiral` — `Sock` linear porttype; the `sock-view`
    view-and-thread shape (E51 `FdView`/`RecvR` pattern; mint is sysface-only).
    **Also frozen there:** the `poll2` extern and its declared result
    `(data Poll2R () (poll2-r (idx I64) (1 a Sock) (1 b Sock)))` (ports.chiral:28)
    — per the Category C map row the transport swap happens *without touching
    decls*, so this idx-shaped `Poll2R` stays; the rich readiness sum below takes
    a distinct name and `wrap-poll2` projects into the declared shape (Step 5).
  - `scaffold/chirality/impl_ports.py:_poll2` — the crutch being retired.
  - Precedent for LE multi-byte packing: `mach-x64.chiral` `b2 =
    (bslice (pack-u32 v) 0 2)` (immutable 2-byte LE); `impl_pure.py` `pack-u32`.
- **True delta:** the `pollfd`-array **assembly** (first array-of-structs
  argument at the floor: 2 × 8-byte `pollfd`), the `nb-sys-poll` **crossing**,
  and **readiness-as-typed-evidence** (revents decoded out of the
  kernel-written cell into `Ready`/`SysPoll2R`) — plus the i16/i32 field helpers
  the fill/read need, and the E51 binding flip that retires the crutch.

## 3. Decisions

Every open question from example §6, dispositioned. No silent design calls.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | N-ary linear collections — the pollfd array wants N ports, but linear kinds forbid `(List Sock)` (generic containers cannot hold ports). | **DEFERRED → E8** | Honest residue. Linear-kind exclusion of ports from generic containers is E8's domain; the missing shape is a first-class *linear vector* (a port array with 1-fields), and poll is the crossing that forces it first. This SPEC ships the demo's need: a fixed-arity `SysPoll2R` over exactly 2 `Sock`s. When E8 lands the linear vector, `SysPoll2R` generalizes; nothing here blocks it. |
| 2 | Mixed-ownership cell — fd/events are ours, revents is kernel-written; one cell, two writers across one crossing. Does bridge-verify re-read cover only the evidence bytes; should the fill/read split be typed? | **RESOLVED (no new machinery) + refinement DEFERRED** | The cell is a single linear mutable byte cell we own. fd/events are written *before* the crossing; `revents@6`/`@14` are zero by the fresh-cell-reads-0 contract; the kernel writes readiness through the pointer *during* the `ti-sys` crossing; we `bget` it back *after*. This is exactly the ownership pattern E21 already crosses with `mmap` `MAP_SHARED` (a region chirality owns, written by the kernel/peer) — no new type machinery is needed for the demo. The *refinement* (typing the fill-half vs read-half so bridge-verify re-reads only the evidence bytes) is **DEFERRED** (bridge-verify precision; not blocking — the whole cell is re-readable as ordinary evidence today). |
| 3 | The deadline as a type — `tmo` is a bare I64 ms; time-and-clocks' "act by" wants the window typed (expiry firing a counter-effect). | **DEFERRED → `docs/time-and-clocks.md` / in-doubt-grant expiry edge** | Ship the bare `I64` ms per the ABI (`-1` forever, `0` immediate). Typing the deadline couples the in-doubt-grant expiry design (counter-effect on expiry) and is a language-level design owed there, not to this crossing. |
| 4 | put-i16 / bget-i16 — the floor's first sub-word multi-byte fields: helpers over `bput`/`bget`, or new byte-face ops? | **RESOLVED → lib-level helpers (not floor ops)** | The floor already has single-byte `ti-bput`/`ti-bget` (tal-ir.chiral:27–28, composed throughout bytes-tal.chiral). Multi-byte LE fields are lib composites: `put-i16 ptr idx v` = two consecutive `ti-bput` (LE); `bget-i16 dst ptr idx` = two `ti-bget` recombined `lo + 256*hi`; the fd i32 is four `ti-bput` (or a `put-i32` sibling). Precedent: `mach-x64.chiral` `b2` packs 2-byte LE via `bslice (pack-u32 …)`. The "new byte-face ops" alternative is residue **not** taken. |
| — | `sock-view` mint (example note: views minted only inside the sys library). | **DEFERRED → E51** | The wrapper is written *against* the `sock-view`/`sock-view-r` shape; the sysface-only mint (`extern sock-view`) lands with E51's binding layer, which also owns the `poll2 → wrap-poll2` table. Steps 1–3 need none of it. |
| — | `Ready` decode policy — HUP(0x10) checked before IN(0x1) so a closed peer reads as `rd-hup` even with data pending. | **RESOLVED (stated policy, demo need)** | Not an author call: the ordering is a documented decode policy (stated, not hidden) and matches the demo's need (peer-close must not masquerade as readable). Carrying the raw bitmask alongside is a §6 knob, not required. |

No blocking NEEDS-AUTHOR. `status: audited` (SPEC-level gate passed 2026-07-27).

## 4. Change plan (ordered, commit-sized)

Steps 1–3 (the crossing + assembly) are landable now. Steps 4–5 (surface wrapper
+ crutch retirement) are gated on the **E51** binding table / `sock-view` mint.

### Step 1 — sub-word byte-field helpers
- **Target:** `scaffold/lib/bytes-tal.chiral` — new `put-i16`, `bget-i16`, and
  `put-i32` (fd field) tal fns.
- **Change:** compose the existing single-byte floor ops at consecutive LE
  offsets. `put-i16` = `ti-bput ptr idx (v & 0xff)` then `ti-bput ptr (idx+1)
  (v>>8)`; `bget-i16` = two `ti-bget` recombined `lo + 256*hi`; `put-i32` = four
  `ti-bput`. Follows the `b2`/`pack-u32` LE precedent; no floor ops added.
- **Size:** S

### Step 2 — the `poll(2)` crossing
- **Target:** `scaffold/lib/sys-tal.chiral` — new `nb-sys-poll`; extend `sys-lib`.
- **Change:** `(def nb-sys-poll TFn (tfn "nb-sys-poll" 3 4 (t-seq (ti-sys 3 7
  (cons 0 (cons 1 (cons 2 nil)))) (t-ret 3))))` — arg0 rdi = array ptr, arg1 rsi
  = nfds, arg2 rdx = timeout-ms, **nr 7**, result in reg 3. Add `nb-sys-poll` to
  the `sys-lib` cons list.
- **Size:** S

### Step 3 — pollfd-array assembly
- **Target:** `scaffold/lib/sys-tal.chiral` — `pollfd-fill` tal fn (precedent:
  `nb-sys-memfd` already assembles its name cell inline in sys-tal, so
  crossing-argument assembly is at home here; `lib/sys-poll.chiral` is Step 4's
  surface layer, not the tal layer).
- **Change:** `ti-bnew 16` (2 × 8-byte stride; revents@6/@14 start 0 by the
  fresh-cell contract). Entry 0: `put-i32 cell 0 fa`, `put-i16 cell 4 0x1`
  (POLLIN). Entry 1: `put-i32 cell 8 fb`, `put-i16 cell 12 0x1`. Return the cell
  (linear, threaded). Offsets are the ref's: fd i32@0, events i16@4, revents
  i16@6; entry *i* at `8*i`.
- **Size:** S

### Step 4 — surface wrapper: readiness as typed evidence  *(gated on E51)*
- **Target:** E51 sys-face lib layer (`lib/sys-poll.chiral` or the sys-linkage
  module) — `Ready`, `SysPoll2R`, `decode-revents`, `poll2-sys`.
- **Change:** adapt example §5 verbatim in shape, with ONE named divergence:
  the example calls the rich sum `Poll2R`, but that name is taken by the frozen
  idx-shaped decl in ports.chiral:28 (see §2) — here it is `SysPoll2R`.
  `(data Ready () (rd-none)
  (rd-in) (rd-hup) (rd-err))`; `(data SysPoll2R () (p2-timeout (1 a Sock)(1 b Sock))
  (p2-ready (r0 Ready)(r1 Ready)(1 a Sock)(1 b Sock)) (p2-err (errno I64)(1 a
  Sock)(1 b Sock)))`. `poll2-sys` = `case (sock-view a) → (sock-view b)` to raw
  fds threading `a2 b2` back, `pollfd-fill`, `nb-sys-poll (bptr-of cell) 2 tmo`,
  then branch: `ret<0 → p2-err (- 0 ret)`, `ret=0 → p2-timeout`, else `p2-ready
  (decode-revents (bget-i16 cell 6)) (decode-revents (bget-i16 cell 14))`.
  `decode-revents`: 0→`rd-none`; **HUP 0x10 before IN 0x1** (per the §3
  Ready-decode row);
  ERR 0x8→`rd-err`. Bits from the ref: POLLIN 0x1, POLLOUT 0x4, POLLERR 0x8,
  POLLHUP 0x10, POLLNVAL 0x20. Every path threads both socks back (checked).
- **Size:** M

### Step 5 — flip the binding table, retire the crutch  *(gated on E51)*
- **Target:** the E51 `poll2` binding row + `scaffold/chirality/impl_ports.py:_poll2`.
- **Change:** point `poll2 → wrap-poll2` at the `poll2-sys` shape; delete
  `_poll2` (lines 183–191) once the table no longer references it. The crutch's
  `idx` semantics survive as a first-ready-wins projection of `p2-ready` into
  the declared `poll2-r idx` shape — for decl-compatibility, not test-greenness:
  no test and no chirality call site exercises `poll2` today (grep-verified; the
  extern + decl exist unused in ports.chiral), so the projection keeps the frozen
  decl valid for future callers.
- **Size:** S

### Step 6 — conformance test (see §5)
- **Target:** `scaffold/tests/test_process_externs.py` (the process-extern test
  home; `poll2` has NO test today — these are its first).
- **Size:** M

## 5. Conformance gate

- **Golden behavior:** the chirality `poll2-sys` crossing observes readiness
  **byte-identical** to `impl_ports` `select.select` on real pipes under
  staggered readiness — write A only, then B only, then both, then
  neither-with-timeout-0, then neither-with-30ms (the timeout path). `revents`
  decode is checked against a **peer-closed** pipe (POLLHUP → `rd-hup`) and a
  **closed-fd** entry (POLLNVAL). The crutch's `idx` must be reproducible as a
  first-ready-wins projection of `p2-ready`.
- **Tests to add:** in `test_process_externs.py`:
  `test_poll2_readiness_differential` (staggered A/B/both — native tal crossing
  vs the CPython reference floor, revents byte-identical, and `idx`-projection
  equal to the old `_poll2`), `test_poll2_timeout_paths` (timeout-0 immediate,
  30ms deadline → `p2-timeout`), `test_poll2_revents_decode` (POLLHUP→`rd-hup`,
  POLLNVAL, HUP-before-IN ordering), `test_pollfd_fill_offsets` (cell bytes match
  the ref layout: fd@0/@8, events@4/@12, revents@6/@14 zeroed pre-crossing),
  `test_put_bget_i16_roundtrip` (LE helpers).
- **Green line:** 281 → ≥ 286; `tools/ledger-lint/ledger-lint.py` clean.
- **Done when:** the differential test is green, `_poll2` is deleted, and chirality's
  one time-bound (block-until-event-or-deadline) no longer touches CPython.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **N-ary / N-port poll** — fixed-arity `SysPoll2R` (2 socks) ships; the
    first-class linear vector (port array with 1-fields) is **E8**'s. Poll is the
    forcing crossing.
  - **Typed deadline / expiry-effect** — bare `I64` ms ships; typing the window
    (expiry → counter-effect) is owed to `docs/time-and-clocks.md` + the
    in-doubt-grant expiry edge.
  - **Typed fill/read split** for bridge-verify (re-read only the evidence
    bytes) — refinement, not blocking; bridge-verify precision.
  - **New byte-face floor ops** — not taken; the i16/i32 helpers are lib
    composites of the existing single-byte `ti-bput`/`ti-bget`.
  - **`POLLOUT`/writable-wait, raw-bitmask carry** — decode knobs, §6 of the
    example; demo events are `POLLIN` only.
- **Follow-on:** unblocks the transport-replacement half of **E51** (the
  `poll2 → wrap-poll2` flip); the row shadow this crossing lands in is
  **E70** (effectful lowering); pairs with **E29** (the sockets being waited on)
  and **E30** (fd-passing sibling).
- **Related:** [[E31-poll]] · [[E51-sys-linkage]] · [[E29-sockets]] ·
  [[E70-effectful-lowering]] · E8 (linear vector) · E30 (fd-passing) ·
  `refs/ref-poll.md` (ABI bank) · `docs/time-and-clocks.md` (third sense of time).
