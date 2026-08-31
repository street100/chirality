---
element: E90
slug: arena-grow-crossing
title: `nb-arena-grow` TAL crossing: mprotect reserve-commit growth + heapend cell update
kind: BUILD-PROPER
example: examples/E90-arena-grow-crossing.md
status: audited
updated: 2026-08-09
---

# E90 SPEC — `nb-arena-grow` TAL crossing: mprotect reserve-commit growth + heapend cell update

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `scaffold/lib/sys-tal.chiral` gains two TIFn definitions
  — `nb-arena-commit-t` (4 params, 12 temps, commits a chunk of a
  `PROT_NONE` reservation to `PROT_READ|PROT_WRITE` via `mprotect`, ceiling-checked, honest-fail on error) and `nb-arena-grow-t` (4 params, 12 temps, doubling-policy growth: reads current committed end from `heapend`, computes `max(double, cover-need)`, calls `nb-arena-commit`). Both inserted after `nb-sys-mprotect-t` (line 116). `scaffold/lib/bytes-tal.chiral` gains `nb-get-u64-t` (3 params, 10 temps, the 8-byte LE read dual of `nb-put-u64-t`, inserted before `nb-put-u64-t` at line 461). One entry each in `sys-lib` and `native-lib` cons chains. No new `target-linux.chiral` row — both TIFns compose `nb-sys-mprotect` (already registered, nr 10) via `ti-call`, carrying no `ti-sys` of their own.

- **Non-goals:** `mremap` growth (rejected — moving mappings dangle absolute heap pointers; the stale `nb-sys-mremap` row at `target-linux.chiral:18` is retired separately, this element must not revive or depend on it); surface `Arena`/`ArenaR` types or `arena-grow` function (live in `arena.chiral`, §6 residue); `crossing-wraps.chiral` or `ports.chiral` entries (the grow is sub-semantic — called only by the E91 out-of-line stub at the TAL floor, never through a `=>` surface name); the reservation/commit init (E89 stub v3 owns `base`, the initial commit, and `reserve_end`); the check-first reorder of `x-alo`/`x-bnw` (E91 step 1, a prerequisite); page-alignment of `delta`/`need` (caller responsibility); the E91 out-of-line grow stub itself (assembly glue between allocation sites and this crossing); zeroing of newly committed pages (fresh `PROT_NONE`→RW pages read as zero, like `MAP_ANONYMOUS`).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E90 postdates the conformance-map
  snapshot. Treat as BUILD (greenfield addition to live files).

- **Live code this element composes with:**
  - `scaffold/lib/sys-tal.chiral:113` — `nb-sys-mprotect-t`, the raw three-arg TIFn (nr 10, `mprotect(addr, len, prot)` → 0 or `-errno`). Already E76-registered (`sys-row "nb-sys-mprotect" 10` at `target-linux.chiral:19`). Callable via `ti-call` with regs `(addr, len, prot)`.
  - `scaffold/lib/bytes-tal.chiral:461` — `nb-put-u64-t`, writes 8 bytes LE into a cell at offset 0 via two `nb-put-u32` stores. Takes `(cell, offset, val)`. Used by `nb-arena-commit` to publish the new committed end into `heapend`.
  - `scaffold/lib/bytes-tal.chiral:502` — `native-lib` cons chain (currently 26 entries, ends with `nb-bfind-t` at nil tail). `nb-get-u64-t` is inserted alongside `nb-put-u64-t`.
  - `scaffold/lib/sys-tal.chiral:431` — `sys-lib` cons chain (currently 27 entries, ends with `nb-read-keyseq-t` at nil tail). Both arena TIFns are inserted after `nb-sys-mprotect-t`.
  - `scaffold/lib/mach-x64.chiral:258-264` — `x-fin`: `heapptr` and `heapend` are raw 8-byte labels (`a-bytes (b8 0)`, page-aligned at 4096). Addressable via `ti-bptr`; `ti-bget`/`ti-bput` provide raw byte access at `(address + offset)`. E89 stub v3 writes initial values via raw `mov [moffs64]`; this element reads/writes via the cell-word primitives.
  - `scaffold/lib/target-linux.chiral:19` — `(sys-row "nb-sys-mprotect" 10)`. Already present; no new row needed (the `nb-run-elf` / `nb-sys-exec-elf` precedent: wrappers composing a registered crossing carry no `ti-sys` of their own).
  - `scaffold/lib/compile-emit.chiral:49-50` — `arena-bytes` constant and `entry-stub-v2`. E89 stub v3 replaces this; this element references the interface (base, reserve_end, heapend cell addresses) but does not modify it.

- **True delta:** three new TIFn definitions (`nb-get-u64-t`, `nb-arena-commit-t`, `nb-arena-grow-t`) + three symbol additions to cons chains. Edits in two files (`sys-tal.chiral`, `bytes-tal.chiral`) + golden list test extension. Zero new files.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **FLAG: `nb-get-u64` doesn't exist in `bytes-tal.chiral`** — how does `nb-arena-grow` read the current `committed_end` from the `heapend` cell? | **RESOLVED: Create `nb-get-u64-t` in `bytes-tal.chiral`** as the 8-byte LE read dual of `nb-put-u64-t`. It reads 8 bytes from a cell at a given offset, reconstructing the I64 via 8 × `ti-bget` with Euclidean decomposition (inverse of `nb-put-u64-t`'s `ti-bput` chain). Lives in `bytes-tal.chiral` immediately before `nb-put-u64-t`, added to `native-lib` alongside it. `nb-arena-grow` calls `nb-get-u64(cell, 0)` to read the current committed end from `heapend`. This is the symmetric, chirality-native approach: provide the dual primitive rather than restructuring the caller interface to work around a missing floor operation. |
| 2 | Is `heapend` addressable by `nb-get-u64`/`nb-put-u64`? The cell is a raw 8-byte label (`a-bytes (b8 0)`), not a `[len][payload]` Bytes cell. | **RESOLVED: raw label works with `ti-bptr` + `ti-bget`/`ti-bput`.** `ti-bptr "heapend"` resolves to the label's absolute address in the data section. `ti-bget`/`ti-bput` do raw byte access at `(address + offset)` — no header dependency. `nb-get-u64` reads the 8 raw bytes; `nb-put-u64` writes them. The `a-bytes (b8 0)` is exactly 8 zeroed bytes — a valid target. No change to `x-fin` needed; E89 stub v3 continues to write initial values via raw `mov [moffs64]` in the entry stub. The TAL primitives and the entry stub share the same 8-byte backing store. |
| 3 | Where do `base` and `reserve_end` come from? | **RESOLVED: passed as register parameters** from the E91 out-of-line stub. The E89 stub v3 single-sources these as constants or cells; the E91 stub reads them and passes them to `nb-arena-grow` in regs 0 and 1. This keeps the grow function pure-I64 (no metadata-cell reads for its own parameters) and leaves the cell-layout choice to E89. `committed_end` is the exception — it MUST be read from `heapend` inside the grow because the grow IS the thing that updates `heapend`, so the value must be current at call time. |
| 4 | Doubling measure: `committed_end - base` correct given `base` never moves? | **RESOLVED: confirmed.** E89 gives `base` as the reservation start (fixed for process lifetime) and `heapptr` as the bump cursor (moves). `nb-arena-grow` computes `committed_size = committed_end - base`, not `heapptr - base`. The committed prefix and the bump cursor are independent: the prefix grows in coarse chunks (`mprotect` pages); the cursor advances in fine increments (allocation sizes). `base` is the single source of truth for the reservation origin. |
| 5 | `sys-lib` or `native-lib` for the arena TIFns? | **RESOLVED: `sys-lib`.** `nb-arena-commit` calls `nb-sys-mprotect` (a syscall wrapper in `sys-lib`), so it lives in the same library. `nb-arena-grow` calls `nb-arena-commit` and `nb-get-u64` (in `native-lib`). `sys-lib` entries can call `native-lib` entries — the linker resolves both. All other syscall wrappers live in `sys-lib`. |
| 6 | `native-lib` for `nb-get-u64`? | **RESOLVED: `native-lib`.** It's a cell-word primitive alongside `nb-put-u64`, `nb-put-u32`, `nb-put-ptr`, `nb-cell-i64`, `nb-cell-put-i64`. All these live in `native-lib`. The `native-lib` chain is linked into every binary (the emit pipeline includes it). |
| 7 | Error path: return sentinel or honest-fail? | **RESOLVED: honest-fail** (E89-style). On reservation exhaustion or `mprotect` failure, `nb-arena-commit` calls `nb-arena-fail` (E89's helper: write diagnostic to fd 2 via `nb-sys-write`, then `nb-sys-exit-group(1)`) and never returns. Continuing past a failed commit means a store into a `PROT_NONE` page — the one outcome reserve-commit exists to make impossible. Failure codes: 1 = reservation exhausted, 2 = mprotect refused. |
| 8 | No `target-linux.chiral` row for either TIFn? | **RESOLVED: no new row.** Neither TIFn issues a raw `ti-sys`; both compose `nb-sys-mprotect` via `ti-call`. The mprotect governance rides the existing `(sys-row "nb-sys-mprotect" 10)`. Precedent: `nb-run-elf` composes `nb-sys-fork`/`nb-sys-wait4`/`nb-sys-exec-elf` and has no `sys-row` of its own. |
| 9 | Insertion point in `sys-lib` chain? | **RESOLVED: insert `nb-arena-commit-t` and `nb-arena-grow-t` immediately after `nb-sys-mprotect-t`** in the cons chain. Lexical proximity matches semantic proximity — the wrappers sit next to the raw syscall they compose. The chain currently goes `... nb-sys-mprotect-t (cons nb-sys-close-t ...)`. New: `... nb-sys-mprotect-t (cons nb-arena-commit-t (cons nb-arena-grow-t (cons nb-sys-close-t ...)))`. |
| 10 | Concurrency concerns for `heapend` write? | **RESOLVED: none.** The chirality runtime is single-threaded. The `heapend` write in `nb-arena-commit` is a plain 8-byte store (two `nb-put-u32` calls = 8 byte writes); the next allocation reads it in program order. No atomicity, no memory barriers needed. |

## 4. Change plan (ordered, commit-sized)

### Step 1 — `nb-get-u64-t` in `bytes-tal.chiral`

- **Target:** `scaffold/lib/bytes-tal.chiral` — insert before `nb-put-u64-t` (line 461).
- **Change:** Add `nb-get-u64-t` TIFn definition. 3 params `(cell, offset, ret_reg)`, 10 temps, `ti-fn` name `"nb-get-u64"`. Body: 8 × `ti-bget` calls with offset 0..7, each reading one byte, reconstructing the I64 via `ti-prim (op-mul)` × 256 + `ti-prim (op-add)` (the inverse of `nb-put-u64-t`'s Euclidean split into `nb-put-u32` calls). Pattern: `lo = unpack_u32(cell, offset)`, `hi = unpack_u32(cell, offset+4)` → `result = hi * 2^32 + lo`. Uses `ti-const 256` (or `ti-const 4294967296` for the 32-bit shift). Add `nb-get-u64-t` to `native-lib` chain (insert before `nb-put-u64-t`).
- **Size:** ~M (8 × `ti-bget` + shift/add reconstruction, ~25 lines incl. comments). Requires sexp-reader paren verification.
- **Verify:** `PYTHONPATH=scaffold python3 -c "from chirality.sexp import read_all; list(read_all(open('scaffold/lib/bytes-tal.chiral').read(),'f')); print('OK')"` must print OK.

### Step 2 — `nb-arena-commit-t` in `sys-tal.chiral`

- **Target:** `scaffold/lib/sys-tal.chiral` — insert after `nb-sys-mprotect-t` (after line 116, after the closing paren of that def).
- **Change:** Insert `nb-arena-commit-t` TIFn definition. 4 params: `(from, to, reserve_end, heapend_cell)`, 12 temps, `ti-fn` name `"nb-arena-commit"`. Body:
  1. Ceiling check: `(reserve_end < to)` via `ti-prim (op-lti)` → if true, call `nb-arena-fail` with code 1 (reservation exhausted).
  2. Compute `delta = to - from` via `ti-prim (op-sub)`.
  3. Call `nb-sys-mprotect(from, delta, 3)` via `ti-call` (3 = `PROT_READ|PROT_WRITE`).
  4. Check `(rc < 0)` via `ti-prim (op-lti)` → if true, call `nb-arena-fail` with code 2 (mprotect refused).
  5. On success: call `nb-put-u64(heapend_cell, 0, to)` to publish the new committed end.
  6. Return `to` via `ti-ret`.
  Uses `ti-tcase` branching with nil-terminated branch pairs. No `ti-sys` — composes `nb-sys-mprotect` via `ti-call`.
- **Size:** ~L (14-deep nesting, ~35 lines incl. comments). Requires sexp-reader paren verification.
- **Verify:** same paren check as Step 1 on `sys-tal.chiral`.

### Step 3 — `nb-arena-grow-t` in `sys-tal.chiral`

- **Target:** `scaffold/lib/sys-tal.chiral` — insert immediately after `nb-arena-commit-t`.
- **Change:** Insert `nb-arena-grow-t` TIFn definition. 4 params: `(base, reserve_end, need, heapend_cell)`, 12 temps, `ti-fn` name `"nb-arena-grow"`. Body:
  1. Call `nb-get-u64(heapend_cell, 0)` → `committed_end`.
  2. Compute `committed_size = committed_end - base` via `ti-prim (op-sub)`.
  3. Compare `(committed_size < need)` via `ti-prim (op-lti)`.
  4. If need dominates: `target = committed_end + need` via `ti-prim (op-add)`, call `nb-arena-commit(from=committed_end, to=target, reserve_end, heapend_cell)`.
  5. If doubling dominates: `target = committed_end + committed_size` via `ti-prim (op-add)`, call `nb-arena-commit(from=committed_end, to=target, reserve_end, heapend_cell)`.
  6. Return the result of `nb-arena-commit` (the new committed end).
  Uses `ti-tcase` branching. No `ti-sys` — composes `nb-arena-commit` and `nb-get-u64` via `ti-call`.
- **Size:** ~L (12-deep nesting, ~30 lines incl. comments). Requires sexp-reader paren verification.

### Step 4 — `sys-lib` cons chain entries

- **Target:** `scaffold/lib/sys-tal.chiral` — `sys-lib` chain at line 431.
- **Change:** Insert `nb-arena-commit-t` and `nb-arena-grow-t` into the cons chain immediately after `nb-sys-mprotect-t`. The chain is a right-nested cons; wrap two new `(cons ...)` around the existing continuation. Current: 27 entries → after: 29 entries. Verify closing paren count: N entries = N cons calls + 1 closing paren for `def sys-lib`.
- **Size:** ~S (two cons forms, two new closing parens at the tail).

### Step 5 — Golden list test extension

- **Target:** `scaffold/tests/test_eff_lower_chirality.py` and `scaffold/tests/test_tal_chirality.py` — golden TIFn name lists.
- **Change:** Add `"nb-arena-commit"`, `"nb-arena-grow"`, and `"nb-get-u64"` to the expected TIFn name sets. All TAL wrappers are enumerated here; missing names cause tests to fail.
- **Size:** ~S (three string additions).

### Step 6 — Paren verification (all files)

- **Target:** `scaffold/lib/sys-tal.chiral` and `scaffold/lib/bytes-tal.chiral` — the whole files after all edits.
- **Change:** Run `PYTHONPATH=scaffold python3 -c "from chirality.sexp import read_all; list(read_all(open('FILENAME').read(),'f')); print('OK')"` for each file. Re-run after every edit to any TIFn body. If it doesn't print OK, the parens are wrong. Use Python to compute closing paren counts — never hand-count.
- **Size:** verification step only.

## 5. Conformance gate

- **Golden behavior:** with a reserve-commit arena (E89 stub v3):
  - `nb-arena-grow(base, reserve_end, need, heapend_cell)`:
    - Reads current `committed_end` from `heapend`.
    - Computes `target = committed_end + max(committed_size, need)`.
    - Calls `nb-arena-commit` → `mprotect` commits pages from `committed_end` to `target`.
    - `heapend` advances to `target`.
    - Returns `target`.
  - Ceiling overrun (`to > reserve_end`): process exits with honest-fail code 1 (writes diagnostic to fd 2, `exit_group(1)`).
  - `mprotect` failure (e.g., `-ENOMEM` under `RLIMIT_AS`): process exits with honest-fail code 2 — NOT SIGSEGV, NOT OOM-kill.
  - `nb-get-u64(cell, offset)`: reads 8 LE bytes from `cell[offset..offset+8]`, returns the I64. Dual of `nb-put-u64`: `nb-get-u64(result_of_put_u64, 0) == original_val` for any I64 value.
- **The real soak:** the self-compile from `INIT_COMMIT` (~256 KB) through ~nine doublings to the compiler's peak (~128 MB). The fixpoint must stay byte-identical.
- **Tests to add:**
  - `test_nb_get_u64_roundtrip` — put a known I64 via `nb-put-u64`, read it back via `nb-get-u64`, assert equality.
  - `test_nb_arena_commit_success` — commit a 4096-byte chunk of a `PROT_NONE` reservation, verify `mprotect` returns 0 and `heapend` advances.
  - `test_nb_arena_commit_ceiling` — request `to > reserve_end`, verify honest-fail exit.
  - `test_nb_arena_commit_mprotect_fail` — inject failure (e.g., invalid address), verify honest-fail exit code 2.
  - `test_nb_arena_grow_doubling` — call grow with `need < committed_size`, verify doubling policy fires.
  - `test_nb_arena_grow_cover_need` — call grow with `need > committed_size`, verify need-dominates policy fires.
  - `test_eff_lower_chirality` / `test_tal_chirality` — golden TIFn name lists include `"nb-arena-commit"`, `"nb-arena-grow"`, `"nb-get-u64"`.
- **Green line:** current 708 test functions → ≥ 714 (+6 new). `test_eff_lower_chirality` and `test_tal_chirality` pass (golden name lists, extended with three new TIFn names — not counted as new test functions). `test_tal` passes (TAL checker structural checks). Ledger-lint clean.
- **Done when:**
  - `PYTHONPATH=scaffold python3 -c "from chirality.sexp import read_all; list(read_all(open('scaffold/lib/sys-tal.chiral').read(),'f')); print('OK')"` prints OK.
  - `PYTHONPATH=scaffold python3 -c "from chirality.sexp import read_all; list(read_all(open('scaffold/lib/bytes-tal.chiral').read(),'f')); print('OK')"` prints OK.
  - All named conformance tests pass.
  - `nb-get-u64` roundtrip test passes: `put-then-get` produces the original I64 for a range of values including negatives, zero, and large positives.

## 6. Residue & links

- **Deliberately unbuilt:**
  - Surface `Arena`/`ArenaR` types and `arena-grow` function → live in `arena.chiral`; not modified by this element.
  - `crossing-wraps.chiral` entry (`"arena-grow"` → `"nb-arena-grow"`) and `ports.chiral` extern declaration → sub-semantic; called only by E91 stub at TAL floor. If a surface caller needs it later, add the wrap in whatever element introduces that caller.
  - `mremap` growth path → rejected (dangling absolute pointers). The stale `nb-sys-mremap` row at `target-linux.chiral:18` is retired separately by S3 (cleanup element).
  - Page-alignment of `delta`/`need` → caller (E91 stub) responsibility. `mprotect` requires page-aligned addr; the caller rounds `need` to a page multiple before passing it.
  - Zero-initialization of newly committed region → fresh `PROT_NONE`→RW pages read as zero (kernel guarantees zero-fill on first access for anonymous mappings).
  - `MREMAP_DONTUNMAP` flag (Linux 5.7+) → not applicable (no `mremap` in this element).
  - `old_len == 0` guard in a grow → not applicable (no `mremap` in this element).
- **Follow-on:**
  - E91 (growing allocator): check-first reorder of `x-alo`/`x-bnw` in `mach-x64.chiral` PLUS the out-of-line grow stub (preserve scratch regs, SysV-call `nb-arena-grow` with needed-bytes, return-to-retry) that CALLS this element's TIFns. Replaces the fixed `arena-bytes` trap with a growing bump cursor.
  - E89 (arena init): reserve-commit entry stub v3 that establishes `base`/`reserve_end`/`heapend` and owns `nb-arena-fail` (honest-fail helper). Sibling prerequisite.
  - E81 (alloc discipline): `growing` as a named `Alloc` instance beside `fixed-trap`, selected at link time.
- **Related:** [[E90-arena-grow-crossing]] · [[E89-arena-init]] (reserve-commit entry stub v3 — sibling prerequisite that establishes `base`/`reserve_end`/`heapend` and owns `nb-arena-fail`) · [[E91-growing-allocator]] (check-first reorder + out-of-line grow stub + retry loop — the consumer that CALLS `nb-arena-grow`) · [[E81-alloc-discipline]] (`growing` Alloc instance) · `scaffold/lib/sys-tal.chiral:113` (`nb-sys-mprotect-t`, the registered crossing this composes) · `scaffold/lib/target-linux.chiral:19` (`mprotect` `sys-row`, nr 10 — already present) · `scaffold/lib/mach-x64.chiral:258-264` (`heapptr`/`heapend` cells in `x-fin`) · `scaffold/lib/bytes-tal.chiral:461` (`nb-put-u64-t`, the write dual of the new `nb-get-u64-t`) · `scaffold/lib/bytes-tal.chiral:502` (`native-lib` chain — insertion point for `nb-get-u64-t`) · `scaffold/lib/compile-emit.chiral:49` (`entry-stub-v2` — E89 replaces this with v3).
