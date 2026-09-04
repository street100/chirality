---
element: E20
slug: loader
title: Loader: RW mmap → W^X `mprotect` → executable
kind: REPLACE-CRUTCH
example: examples/E20-loader.md
status: audited
updated: 2026-08-01
---

# E20 SPEC — Loader: RW mmap → W^X `mprotect` → executable

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** W^X is a **type fact**, not a line ordering. A new
  `lib/module/loader.chiral` defines the linear porttypes `MapRW`/`MapRX` and
  the crossings `map-rw` / `map-write` / `seal-exec` (seal **consumes** the
  writable handle — no writable view survives it), plus `load-batch`;
  `NativeBackend.compile`'s imperative W^X block (`native.py:472–486`) is rewired
  to issue map→write→seal through the typed loader. Golden behavior unchanged
  (the `test_native.py` differential stays green).
- **Non-goals:** the **CFUNCTYPE entry trampoline** (`native.py:487–495`) →
  **E23/E34** (moves with a real entry point); **arena creation + bump wiring** +
  whether the arena gets its own porttype → **E21**; `munmap` teardown (regions
  live for the process life — `_map_rw` docstring, faithful); relocation /
  offset tables → the emitter (E19); `map-enter` (calling into `MapRX` at an
  offset) → rides the trampoline, E23.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** **REFACTOR, size M** — "Memory fully chirality-side
  (E20, 2026-07-29): code buffer + arena mapped via `nb-sys-mmap`, sealed via
  `nb-sys-mprotect` … Python's `mmap` module + ctypes `_mprotect` both gone."
  The syscall *mechanism* is self-hosted; this element lifts the *invariant*
  into the type. E28's row (all nine crossings, CONFORMS) satisfies the
  dependency.
- **Live code (the reference being ported/rewired, do NOT respec):**
  - `native.py:410 _map_rw` — mmap RW through the `nb-sys-mmap` crossing on the
    reference tal machine (`_sysmachine`, `:400`); page-rounds; negative return
    → `OSError(-errno)`; regions held for process life.
  - `native.py:472–486` — the W^X block: `_map_rw(len(code))` → **blit via
    `ctypes.memmove`** (`:473`) → arena `_map_rw` + **cell-pokes via
    `ctypes.memmove`** (`:477–479`) → `nb-sys-mprotect(base, code_end, R|X)`
    (`:483`).
  - **The sub-span fact:** `code_end = offsets.get("heapptr", page-rounded len)`
    (`:482`) — the seal covers the *prefix* only; the emitted `heapptr`/`heapend`
    cells sit in the **same mapping past the seal** and stay RW (running code
    bumps them). The example's whole-region `seal-exec` was its own open
    question #1; the reference answers it: **prefix seal** (decision #1).
  - `lib/sys-tal.chiral:87/94/101` — `nb-sys-mmap`/`munmap`/`mprotect` built
    (E28); `lib/ports.chiral:70–72` — the `pool-create`/`pool-write` witness +
    erased-index idiom the loader externs copy.
- **Baseline precision (a rounding the SPEC must not inherit):** the map row's
  "ONLY the CFUNCTYPE trampoline stays Python" is true of the *syscalls*, but
  the **write path is still ctypes** — the code blit and the two 8-byte cell
  pokes are `ctypes.memmove` (`:473,477–479`). E20's typed `map-write` needs a
  non-ctypes referent (decision #4); the trampoline alone remains after this
  element.
- **True delta:** `lib/loader.chiral` (new file: 2 porttypes + 3–4 externs +
  `load-batch`), one floor blit routine (decision #4), and the `compile()`
  rewire. No new syscalls; no kernel change.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **Whole-mapping vs sub-span seal** (example §6 open question 1). | **RESOLVED → prefix seal, split-at-witness.** | The reference seals `[base, heapptr)` and leaves the cell tail RW in the same mapping (`native.py:482`). Typed shape: `seal-exec` takes the split point as a **runtime witness** `k` and returns a bundle `(SealedR n k)` = `(1 code (MapRX k))` + `(1 cells (MapTail n k))` — a distinct porttype for the RW tail, carrying **both** erased indices so no type-level subtraction is needed (a symbolic `n-k` is outside E9's decidable fragment — same fragment-limit reasoning as E4's refined levels). The no-heap case (`heapptr` absent) seals the page-rounded whole and the `cells` handle is degenerate. |
| 2 | **`mprotect`/`mmap` errno → typed alarm vs host raise** (example §6 open question 2). | **RESOLVED (interim) → host-raise at the binding, faithful to the current bridge idiom; typed alarm DEFERRED → E26.** | Today every crossing fault is a host-side `PortError`/`OSError` (`native.py:419,486`); alarms-as-typed-effects are **E26**, hard-gated on the E39 row (built) + E26's own build. The loader keeps the faithful interim and converts with E26 — not a loader-local invention. |
| 3 | **A distinct porttype for the arena** so it can never be sealed by mistake (example §6 open question 3). | **DEFERRED → E21.** | The arena is E21's subject; whether it stays a `MapRW` (sealing it would *consume* it — a loud runtime fault, not silent corruption) or gets its own `Arena` porttype is E21's call to make with the bump-allocator wiring. E20's `load-batch` takes the arena handle opaquely either way. |
| 4 | **`map-write`'s referent** — the blit is `ctypes.memmove` today; what does the typed crossing lower to? | **RESOLVED → a floor blit routine (`nb-blit`), differential vs `memmove`.** | The write path must leave ctypes or the W^X "no writable view" claim rests on Python again. The floor already writes memory (arena bump, `mem-put-checked`, byte-cell stores in `bytes-tal.chiral`), so a bounded store-loop `nb-blit(addr, src-cell, len)` is within tal's proven power — the principled home (memory ops live on the floor). The implementation may route through an existing mem-put loop if one fits; the gate is byte-equality vs `memmove`. The two 8-byte cell pokes ride the same routine. |
| 5 | **Where the porttypes live** — `lib/ports/ports.chiral` (the frozen app-facing set) vs the new `lib/loader.chiral`. | **RESOLVED → `lib/loader.chiral`.** | Loader crossings are **compiler-internal**, not app-surface: no app profile should see `MapRW`/`seal-exec` in its port set. `ports.chiral` stays the app-facing C floor; the loader file registers its porttypes the same way (the surface `porttype` form is not file-bound). Follows the example's §6. |

No NEEDS-AUTHOR: each question resolves from the reference's behavior or defers
to its named home (E21/E26). The change plan is fully unblocked.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `lib/loader.chiral`: the typed surface
- **Target:** `scaffold/lib/loader.chiral` (NEW FILE).
- **Change:** per example §5 (with its audited quantities): `(porttype MapRW (n
  I64))`, `(porttype MapRX (n I64))`, `(porttype MapTail (n I64) (k I64))`
  (decision #1); externs `map-rw : (=> (w n I64) (MapRW n))`, `map-write : (->
  (0 n I64) (=> (1 m (MapRW n)) I64 Bytes (MapRW n)))`, `seal-exec : (-> (0 n
  I64) (=> (1 m (MapRW n)) (w k I64) (SealedR n k)))` with `(data SealedR ((n
  I64) (k I64)) (sealed-r (1 code (MapRX k)) (1 cells (MapTail n k))))`; and
  `load-batch` threading map→write→seal with the `w c` runtime witness (the
  example's audited quantity fix). NOTE: decision #1's prefix seal **supersedes**
  the example's whole-region `Loaded` shape — `load-batch`'s result bundles
  `SealedR`'s pieces (RX code + RW cell tail) plus the arena, resolving the
  example's own §6 open question 1 rather than contradicting it.
- **Size:** ~S.

### Step 2 — the floor blit
- **Target:** `lib/lowering/tal/sys.chiral` or `lib/lowering/tal/bytes.chiral` — `nb-blit`.
- **Change:** a bounded store-loop copying `len` bytes from a byte cell to an
  absolute address (decision #4), preserve-checked like every `nb-*` routine;
  registered in `sys-lib`. Differential: bytes written byte-equal to
  `ctypes.memmove` on sampled payloads (incl. the 8-byte little-endian cell
  poke).
- **Size:** ~M.

### Step 3 — host bindings for the loader externs
- **Target:** `scaffold/chirality/impl_ports.py` (or the backend's binding table).
- **Change:** bind `map-rw`→`_map_rw`'s mmap call, `map-write`→`nb-blit`,
  `seal-exec`→`nb-sys-mprotect` with the split-point arithmetic (`code_end`),
  each fault a host raise (decision #2). The bindings are the C-floor referents;
  the *types* live in Step 1.
- **Size:** ~S.

### Step 4 — rewire `compile()`
- **Target:** `scaffold/chirality/native.py` — `compile` (`:472–486`).
- **Change:** replace the imperative block with calls through the typed loader
  path (map-rw → nb-blit writes incl. cell pokes → seal-exec at
  `code_end`), keeping `last_code`/`last_offsets`/`self._maps`/`self._heap`
  bookkeeping identical. The CFUNCTYPE loop (`:487–495`) is untouched (E23).
- **Size:** ~M.

## 5. Conformance gate

- **Golden behavior:** `native.py`'s observable contract is unchanged — map RW,
  write the emitted code, seal `[base, code_end)` RX, leave the cell tail + the
  arena RW — such that every call into `base + offsets[name]` returns exactly
  what `tal.TalMachine` and the host prims return.
- **Tests:** the existing `tests/test_native.py` differential is the oracle and
  must stay green through the rewire (Step 4 is behavior-preserving). Add: (a) a
  `nb-blit` vs `memmove` byte-equality differential (Step 2, standalone); (b) a
  checker-level test that a program *holding* a `MapRW` after `seal-exec`
  consumed it is **rejected** (the W^X-as-type fact — linearity refuses the
  retained writable handle); (c) the sub-span case: heap cells writable after
  seal (the existing native heap tests already exercise this behaviorally).
- **Green line:** 360 → ≥ 360 + 2; ledger-lint clean.
- **Done when:** `test_native.py` green through the typed-loader path, the
  blit differential passes, and the retained-`MapRW` program is rejected by the
  checker.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **CFUNCTYPE entry trampoline** → **E23/E34** (real entry point/ELF; the last
    Python in the load path after this element).
  - **Arena porttype + bump wiring** → **E21** (decision #3).
  - **Typed alarm at the crossing fault** → **E26** (decision #2).
  - **`map-enter` / `map-close`** → ride E23 (enter) and process-life mapping
    policy (close; faithful to `_map_rw`'s never-unmap).
  - **memfd-backed `MapShared`** (hand a region to a peer) → the example's knob,
    nobody's yet — E30/fd-passing adjacency when needed.
- **Follow-on:** **E21** (the arena this loader hands back), **E23/E34** (entry
  point retires the trampoline), **E72** (the re-bootstrap manifest wants the
  load path fully typed).
- **Related:** [[E20-loader]], [[E21-arena]], [[E28]] (the sys crossings),
  [[E19]] (produces the code bytes), [[E23]] (the trampoline),
  [[decision-b-in-type]] (protection state in the type), [[banks/memory]]
  (Shards 1/2 — the mapping + Pool idioms this copies).
