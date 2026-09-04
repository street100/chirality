---
element: E107
slug: cap-close
title: Porttype-consuming native close family: `sock-close`/`fd-close`/`env-close`/`lsock-close`/`pool-close` as crossings that CONSUME a linear (quantity-1) porttype and lower to its release syscall (`nb-sys-close` for fd-backed types) — E105-shaped surface extern + `crossing-wraps` pair over already-registered syscalls; completes E106's runtime leg so a real cap drains to a native exit-42 run
kind: BUILD-PROPER
example: examples/E107-cap-close.md
status: audited
updated: 2026-08-12
---

# E107 SPEC — Porttype-consuming native close family

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the three **fd-backed** consuming closes lower to native.
  `crossing-wraps.chiral` gains three pairs — `sock-close`→`nb-sys-close`,
  `lsock-close`→`nb-sys-close`, `fd-close`→`nb-sys-close` — so a linear
  (quantity-1) `Sock`/`LSock`/`Fd` cap emitted through the `=>` membrane now
  reaches native code (E105's `write-fd` shape). The immediate payoff: E106's
  `sv-drain` over a `SockVec` stops failing at native emit and drains a real cap
  collection to a **native exit-42 run** (today: `no emitted label for entry
  compile-main`, compile exit 1).
- **Non-goals (residue in §6):** `pool-close`→`nb-sys-munmap` — sequenced with
  the native `Pool` representation (shared with E111/E113), NOT a fd-close-style
  one-liner, because `pool-*` crossings have no native binding at all yet.
  `env-close` — deferred; no OS release exists and `env-open` is interim/ambient,
  so an `Env` cap can't reach a native run regardless (moot until
  `profile-hands-caps`). No cap-**acquisition** side (E107 is release-only).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no map row — E107 postdates the CONFORMANCE-MAP
  snapshot; treat as **BUILD**. The verified live baseline:
  - **All five surface externs already exist** in `lib/ports/ports.chiral`:
    `lsock-close` :59, `sock-close` :63, `pool-close` :75, `fd-close` :80,
    `env-close` :122. E107 authors **no new extern**.
  - **Both TAL release bodies already exist** in `lib/lowering/tal/sys.chiral`:
    `nb-sys-close-t` :200 (`ti-fn "nb-sys-close" 1 2` — one arg, the fd) and
    `nb-sys-munmap-t` :106 (`ti-fn "nb-sys-munmap" 2 3` — addr+length), both
    listed in `sys-lib` (:708) at :716–717. E107 authors **no new TAL body**.
  - **`crossing-wraps` is the single lowering authority.** It already carries the
    raw-fd `close`→`nb-sys-close` (:21) and the E105 `write-fd`→`nb-sys-write`
    (:35) — the exact shape to mirror. No porttype-consuming close is paired yet.
  - **`sys-linkage` needs no edit.** `sys-bindings` is DERIVED from this table —
    `(def sys-bindings (cw->binds crossing-wraps))` at `sys-linkage.chiral:93` — so
    a new pair flows to the linkage side by construction; the two cannot drift.
  - **The consumer is ready.** E106 (`lincoll.chiral`) built `SockVec`/`sv-drain`,
    which closes every held cap via `sock-close`; `test_e106_linear_cap.py`
    exists. The runtime leg is the only thing missing.
- **True delta:** exactly **three lines** added to `crossing-wraps`'s
  `crossing-wraps` list — the three fd-backed `(pair "<x>-close" "nb-sys-close")`
  entries. Everything else (externs, bodies, linkage) already exists.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Do the three fd-backed closes lower now, and in what order? | **RESOLVED — immediate, this SPEC.** | `close(2)` takes only the fd; `nb-sys-close-t` (1 arg, `sys-tal.chiral:200`) already exists. Each is a pure `crossing-wraps` pair mirroring `write-fd`→`nb-sys-write` (`crossing-wraps.chiral:35`). No dependency on the Pool representation. They land first and unblock E106's native run. |
| 2 | Does `pool-close`→`munmap` block on the erased length param `n`? | **RESOLVED — not a blocker (host tuple).** | The runtime `Pool` is the host tuple `("pool", mm, size)` and `pool-close` already reads `size` to `munmap` (`impl_ports.py:273,278–282`). The erased `(0 n I64)` is a type-level bound only; the concrete length rides in the port value. No information loss. |
| 3 | When does `pool-close`→`nb-sys-munmap` actually lower? | **DEFERRED — with the native `Pool` representation (E111/E113).** | `pool-*` crossings have **no** `crossing-wraps` entry at all (only the arena's raw `mmap`/`mprotect`, :26–27); they are Python-oracle-only. Native `pool-close` requires designing the native `Pool` fat-cap (base+length beside the fd), shared work with E111/E113 — NOT a fd-close one-liner. Sequenced after/with the native pool binding. |
| 4 | Does `env-close` get a native lowering (no-op wrapper vs unpaired)? | **DEFERRED — leave unpaired until `profile-hands-caps`.** | `Env` has no OS release syscall in `sys-tal.chiral`, and `env-open` (:121) is INTERIM ambient acquisition that doesn't lower today — so an `Env` cap can't reach a native run regardless. The linear obligation is discharged at the **type** level (cap consumed exactly once); emitting a no-op wrapper now would be dead code. Leave unpaired; revisit when real `Env` acquisition lands with `profile-hands-caps`. |

No NEEDS-AUTHOR items. All four questions resolve from cited code / a named
follow-on element; §4 is unblocked for the fd-close deliverable.

## 4. Change plan (ordered, commit-sized)

### Step 1 — the three fd-close `crossing-wraps` pairs (the deliverable)
- **Target:** `lib/lowering/tal/crossing-wraps.chiral` — the `crossing-wraps` list
  (the `cons`-chain, :14–40).
- **Change:** add three pairs beside the E105 `write-fd` entry, mirroring its
  shape exactly (surface name → already-registered wrapper; no new body):
  ```chirality
  (cons (pair "sock-close"  "nb-sys-close")   ; E107  ─┐
  (cons (pair "lsock-close" "nb-sys-close")   ; E107   │ fd-backed: release = close(fd)
  (cons (pair "fd-close"    "nb-sys-close")   ; E107  ─┘
  ```
  Remember to add the matching `)` to the closing paren run on :41. No edit to
  `ports.chiral` (externs exist), `sys-tal.chiral` (bodies exist), or
  `sys-linkage.chiral` (`sys-bindings` is derived, :93).
- **Size:** ~S (3 lines).

### Step 2 — the E106 `sv-drain` native conformance sample
- **Target:** a conformance sample driving E106's `SockVec` end-to-end (the
  behavioral run the example §6 names) — e.g. an addition to
  `scaffold/tests/test_e106_linear_cap.py` or a `TUI/samples`/`scaffold` sample
  that B1-compiles and runs.
- **Change:** `compile-main` acquires ≥2 linear caps, pushes them into a
  `SockVec` (`sv-push`), services one, `sv-drain`s the rest (closing every held
  cap exactly once), and returns `42`. Assert **B1-compiled, native exit 42**.
  Also add/keep the negative checks: dropping a cap without closing and
  double-close stay **checker-rejected** (linear quantity-1).
- **Size:** ~M.
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

### Step 3 — `pool-close`→`nb-sys-munmap` (DEFERRED; do NOT do in this run)
- **Dependency:** the native `Pool` representation (fat-cap carrying base+length),
  shared with **E111/E113**. `pool-close` gets its `crossing-wraps` pair
  (`"pool-close"`→`"nb-sys-munmap"`) only once `pool-*` has a native binding.
  Named here for sequencing; not implemented under E107.

`env-close` — DEFERRED entirely (decision #4); no step.

## 5. Conformance gate

- **Golden behavior (the payoff gate):** E106's `SockVec` `sv-drain` — or a
  single linear `Sock` closed exactly once through `sock-close` — **compiles AND
  runs to native exit 42**. Today the identical program fails at native emit with
  `no emitted label for entry compile-main` (compile exit 1) because `sock-close`
  has no wrapper; after Step 1 it lowers to `close(fd)` and drains to exit 42.
  The raw-fd `close` control (already exit 42 through `bin/chirality-bin`) proves
  the shape is reachable.
- **Negative gate (unchanged, must stay red):** dropping a linear cap without
  closing, and double-closing a cap, remain **checker-rejected** — the cap is
  consumed on the first close and nothing threads back, so both are non-terms.
- **Tests to add:** the Step-2 sample (native run, exit 42) plus the two
  negative checker-rejection cases; compare the native floor against the checker
  (accept/reject) and the exit code.
- **Reblob-cmp gate (REQUIRED — `crossing-wraps` is in B1's blob):**
  `crossing-wraps` is inlined into `scaffold/build/blob.chiral` (:1013, and the
  derived `sys-bindings` at :1142), so B1's own sources changed. Reproduce:
  ```
  chirality_blob scaffold/lib <root> | bin/chirality-bin > /tmp/B1.new
  cmp /tmp/B1.new bin/chirality-bin
  ```
  If it differs, reblob + promote (the self-hosting check — the promoted binary
  must reproduce itself byte-for-byte); if identical, no reblob needed. Python
  compiles nothing at any point.
- **Green line:** 704 test functions → ≥ 706 (the native sample + the negative
  checks); ledger-lint clean.
- **Done when:** an executor B1-compiles the E106 `sv-drain` sample and observes
  native **exit 42**, the two negative cases stay checker-rejected, and the
  reblob-cmp gate is satisfied (byte-identical or promoted).
- 2026-09-04: pre-migration scaffold/ path.

## 6. Residue & links

- **Deliberately unbuilt:**
  - `pool-close`→`nb-sys-munmap` — **E111/E113** (native `Pool` fat-cap
    representation); decision #3. Length is not lost (host tuple, decision #2).
  - `env-close` native lowering — **`profile-hands-caps`** (real `Env`
    acquisition); decision #4. Unpaired until then.
  - Cap-acquisition side (E107 is release-only) — nobody's yet in this SPEC.
- **Follow-on this unblocks:** E106's `SockVec`/`sv-drain` reaching a native run;
  any linear-cap program whose terminal move is an fd-backed close.
- **Related:** [[E107-cap-close]] (rationale); [[E106-linear-cap-collection]]
  (the consumer); E105 `write-fd`→`nb-sys-write` (`crossing-wraps.chiral:35`, the
  mirrored shape); the ports bank / capability bank.
