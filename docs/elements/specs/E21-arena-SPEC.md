---
element: E21
slug: arena
title: `mmap` as the arena; represent the returned pointer; wire bump-allocator base/end
kind: REPLACE-CRUTCH
example: examples/E21-arena.md
status: audited
updated: 2026-08-01
---

# E21 SPEC — the typed arena over the self-hosted mapping

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 0 of 4 steps are executable at HEAD.
> `lib/memory/arena.chiral` exists; Steps 3-4 target the cut oracle. Bucket
> and evidence: `records/spec-tier-triage.md`. This file was not rewritten and
> its `status:` was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** allocation is a typed, linear, **total** operation. A new
  `lib/memory/arena.chiral` defines `Ptr`/`Arena`/`Alloc` + `align8` + the pure
  `bump` (exhaustion = a returned `a-err`, never a fault) and the `MapPort`-gated
  `arena-map` crossing; `native.py`'s arena setup (`:476–480`) routes through it.
  The typed bump agrees address-for-address with **both** live bumps — the
  emitted inline x86 bump and the host-side `alloc_bytes` (`native.py:498`).
- **Non-goals:** rewriting the **emitted inline bump** (that is codegen — E16/E19
  territory; it stays as the floor twin the differential compares against, its
  `ud2` kept as the metal's refuse-to-corrupt trap, decision #1); the boxed-cell
  `[tag][fields]`/`[len][payload]` layout (E25, built); `munmap`/teardown
  (regions live for the process life, faithful to `_map_rw`); multi-arena
  nesting / region types / GC (→ **E22**); grant *delivery* to `main` (→ E80).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the row naming E21 is E28's (**CONFORMS, M**) —
  "all nine memory/fd crossings present … **E21 arena done**." The *mapping
  milestone* is complete (chirality `memfd→ftruncate→mmap→roundtrip→munmap`,
  differentially tested); no map row demands the typed layer — that scope is set
  by the catalog row ("represent the returned pointer; wire bump-allocator
  base/end") and the example. This SPEC is the typed layer only.
- **Live code (the reference being ported/wired, do NOT respec):**
  - `native.py:410 _map_rw` — the arena's mapping already goes through
    `nb-sys-mmap` (post the 2026-07-29 E20 mechanism refactor); `:476–480` maps
    `ARENA_BYTES` (1<<20) and pokes `heapptr`/`heapend` cells;
    `self._heap = (base, hoff, abase, aend)` bookkeeping.
  - **The two live bumps the typed one must agree with:** (1) the **emitted
    inline bump** — `p = heapptr; heapptr += (size+7)&~7; ud2 if > heapend`;
    (2) **`alloc_bytes`** (`native.py:498`) — the host-side entry: reads the
    heapptr cell, `size = 8 + ((len+7)&~7)`, bounds-checks vs `aend`
    (`MemoryError`), writes `[len][payload]`, advances the cell.
  - **E20 (audited)** provides the mapping porttypes (`MapRW`), the `nb-blit`
    floor routine (the cell pokes ride it), and the loader file layout this
    composes with. Implementation order: E20's steps land first.
  - Ports precedent: `Clock`/`Timer`/`Env` porttype grants taken as parameters
    (`lib/ports.chiral:106–123`) — the `MapPort` shape already exists in idiom.
- **True delta:** `lib/arena.chiral` (new file), one host binding for
  `arena-map`, the `native.py:476–480` rewire, and the 3-way bump differential.
  No new syscalls; no kernel change.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **Exhaustion: returned `a-err`, or the emitter's `ud2`?** (example §6 q1) | **RESOLVED → both, by level.** | The typed layer returns `a-err` (totality — the example's §4 claim); the emitted floor **keeps `ud2`** — "the alarm that refuses to corrupt" ([[memory-model]] Scaffold status). Two levels, one contract: the typed layer decides exhaustion *before* the metal can trap; the trap remains the last-resort backstop for any path that bypasses the typed layer. Not a contradiction — the floor twin discipline (T1 agreement). |
| 2 | **`<= end` by refinement (E9) or explicit guard?** (example §6 q2) | **RESOLVED (now) → explicit `case` guard; refined form DEFERRED → E48.** | A refined `cur` field `(refine I64 (<= end))` is a **dependent field** — its predicate names the sibling `end` — and fields-depending-on-fields is exactly the scaffold limit E6's SPEC pinned ("fields may not depend on earlier fields, only params", `data.py:142`); lifting it is **E48** telescopes. Until then the guard is the honest form; E9's symbolic bounds don't help across sibling fields. |
| 3 | **Where does "belongs to this arena" pointer evidence live?** (example §6 q3) | **DEFERRED → E22.** | Region membership *in the type* is the region-types shard — E22's subject ("Allocator / region types / GC-outside-TCB"); [[banks/memory]]'s gradient names region-*types* a forward edge blocked on a named mechanism. E21's `Ptr` stays one raw I64 word (the catalog's "represent the returned pointer" — static rep, no runtime tag). |
| 4 | **`Arena`: plain data threaded `q=1` by discipline, or its own porttype?** (the call E20 deferred here) | **RESOLVED → transparent data carrying a linear witness token.** | A bare `(porttype Arena)` is **opaque** — `bump` could no longer `case` on `cur`/`end`, forcing the pure arithmetic behind extern crossings and defeating the C-bridge point. A plain `(arena (cur I64) (end I64))` is **not linear-kind** (both fields ω I64s — E8's walk returns no; the threading would be per-signature discipline only, the example's audited caveat). The hybrid gets both: `(porttype ArenaTok)` + `(data Arena () (arena (1 tok ArenaTok) (cur I64) (end I64)))` — the `q=1` porttype field makes `Arena` **linear-kind by E8's walk** (`data.py:92`: any declared 1-field ⇒ linear), so binding an Arena at ω is *structurally* rejected, while `cur`/`end` stay readable and `bump` stays pure chirality arithmetic (destructure, thread `tok` into the new arena). |
| 5 | **`MapPort` now, when grant-delivery is E80?** | **RESOLVED → keep the grant in the type; delivery rides E80.** | The `Clock`/`Timer`/`Env` precedent: the porttype + grant-as-parameter shape is already idiom (`lib/ports/clock.port:17-40`); what E80 adds is the profile handing the grant to `main`. `arena-map (=> (1 m MapPort) …)` is expressible and checkable today; E80 closes the ambient-conjuring interim exactly as it will for Clock. |

No NEEDS-AUTHOR: E20's deferred porttype call was explicitly E21's to make
(decision #4, checked against E8's walk); the rest resolve from the reference or
defer to named homes (E22/E48/E80). Change plan fully unblocked.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `lib/arena.chiral`: the typed layer
- **Target:** `lib/memory/arena.chiral` (NEW FILE).
- **Change:** per example §5 with decision #4's shape: `(porttype MapPort)`,
  `(porttype ArenaTok)`; `(data Ptr () (ptr (addr I64)))`, `(data Arena ()
  (arena (1 tok ArenaTok) (cur I64) (end I64)))`, `(data Alloc () (a-ok (p Ptr)
  (rest Arena)) (a-err (why Str)))`; `align8` (Euclidean-mod arithmetic — no
  bitwise ops in the fragment); pure `bump` (`case`-guard per decision #2,
  threading `tok`); `arena-map : (=> (1 m MapPort) (len I64) Arena)`.
- **Size:** ~S.

### Step 2 — host binding for `arena-map`
- **Target:** the backend/RT binding table (beside E20's Step-3 bindings).
- **Change:** `arena-map` → `_map_rw(len)` + construct the `Arena` value
  (`cur=abase, end=abase+len`) with a fresh `ArenaTok`; fault = host raise (the
  E20 decision-#2 interim; typed alarm rides E26).
- **Size:** ~S.

### Step 3 — rewire the arena setup
- **Target:** `scaffold/chirality/native.py` — `compile`'s arena block (`:476–480`).
- **Change:** route the `ARENA_BYTES` map through `arena-map` and the two 8-byte
  heap-cell pokes through E20's `nb-blit`; keep `self._heap` bookkeeping
  identical. Depends on E20 Steps 2–3 being built.
- **Size:** ~S.
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

### Step 4 — the 3-way bump differential
- **Target:** `tests/test_memory.py` (or `test_native.py`).
- **Change:** over a sampled request sequence: chirality `bump` (RT floor) vs
  `alloc_bytes`'s address arithmetic vs the emitted inline bump — same base ⇒
  same address sequence, same alignment, exhaustion at the same request (typed:
  `a-err`; host: `MemoryError`; native: the trap — asserted at the boundary
  request only for the typed/host pair). Plus a checker test: an `Arena` bound
  at ω is **rejected** (linear-kind via `ArenaTok`, decision #4).
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** a `1<<20`-byte anonymous RW region; 8-byte-aligned bump;
  a monotonically increasing sequence of non-overlapping in-region pointers;
  exhaustion at exactly the point `native.py` faults (`heapptr > heapend`) —
  yielded as `a-err` at the typed layer while the floor keeps its trap.
- **Tests:** Step 4's 3-way differential + the ω-rejection checker test; the
  existing `test_memory.py`/`test_native.py` suites stay green through Step 3.
- **Green line:** 360 → ≥ 362; ledger-lint clean.
- **Done when:** the typed bump's address/exhaustion behavior is
  indistinguishable from both live bumps on the corpus, the setup path runs
  through `arena-map`+`nb-blit`, and an ω-bound `Arena` is a checker error.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **Region types / arena-membership evidence / GC-outside-TCB** → **E22**
    (decision #3).
  - **Refined `(<= end)` cursor** → **E48** (dependent fields; decision #2).
  - **Typed alarm on map/bump faults** → **E26** (via E20's interim).
  - **Grant delivery to `main`** (`MapPort` conjuring) → **E80** (decision #5).
  - **Emitted-bump replacement** (inline x86 → typed-layer-emitted) → the
    lowering lane (E16/E69) if ever; the floor twin + differential is the
    current contract.
- **Follow-on:** **E22** (regions build on this arena), **E25** (byte cells
  allocate from it — built, now with a typed allocator beneath), **E20**
  (shares the loader file layout + `nb-blit`).
- **Related:** [[E21-arena]], [[E20-loader]] (the mapping + blit this composes
  with), [[E22-regions]], [[E25-byte-cells]], [[E28]] (the crossings),
  [[E08-linear-kinds]] (the walk decision #4 leans on), [[banks/memory]]
  (Shards 1/6 + the gradient), [[memory-model]] (the ud2-as-refusal framing).
