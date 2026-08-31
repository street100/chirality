---
element: E99
slug: ioctl-out-cells
title: Honest ioctl surface: per-request-family crossings that allocate out-cells INSIDE the wrapper and return fresh values (`nb-tcgets` fd→60B cell, `nb-winsz` fd→8B cell; TCSETS keeps value-in shape); rework term.chiral on top so no surface-allocated Bytes is kernel-mutated (removes the pure-fragment immutability violation that fold/CSE strengthening would miscompile)
kind: BUILD-PROPER
example: examples/E99-ioctl-out-cells.md
status: audited
updated: 2026-08-09
---

# E99 SPEC — Honest ioctl surface: per-request-family out-cell crossings

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** two new per-request-family TAL crossings (`nb-sys-winsz-t`,
  `nb-sys-tcgets-t`) in `sys-tal.chiral` that allocate their out-cells *inside*
  the wrapper (`ti-bnew N` + `ti-bptr`) and return a fresh `Bytes` — never
  touching a surface `cell-new` Bytes. Two new typed surface externs in
  `ports.chiral` (`nb-winsz-raw`, `nb-tcgets-raw`) and their crossing-wraps
  entries. `term.chiral` reworked so `tiocgwinsz` and `tcgetattr` call the
  new crossings instead of `ioctl` + `cell-new`. The old generic `ioctl` extern
  is removed from `ports.chiral` (retired). No surface-allocated `Bytes` is
  ever kernel-mutated anywhere in the tree.
- **Non-goals:** does NOT create a new `term-tal.chiral` leaf (wrapper home is
  sys-tal, per author decision — see §3); does NOT add a full `nb-tcgets-raw`
  surface decoder (the `tcgetattr` path already decodes via `bget-u32-le` at
  c_lflag offset 12); does NOT touch `termios-set-raw` (it is already honest —
  pure `->`, no kernel mutation); does NOT add any new struct fields beyond
  the two already in term.chiral (ws_row/ws_col, c_lflag); does NOT change the
  TCSETS path except to point `tcsetattr` at the new value-in-only wrapper.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none (E99 postdates the map snapshot; treated as
  BUILD — net-new crossings over existing substrate).
- **Live code:**
  - `scaffold/lib/sys-tal.chiral`:39-57 — `nb-sys-read-t`: the **alloc-inside
    precedent** (category-B TAL wrapper: `ti-bnew 2 1` allocates 1-byte cell,
    `ti-bptr 3 2` hands pointer to kernel, `ti-sys 4 0 ...` does read syscall,
    copies results via `nb-copy`, returns fresh cell). This is the pattern to
    follow.
  - `scaffold/lib/sys-tal.chiral`:448-453 — `nb-sys-ioctl-t`: the **current
    generic wrapper** (3-arg, `ti-bptr` on arg 2 — hands kernel a surface Bytes
    ptr to mutate in place). This is the wrapper being replaced.
  - `scaffold/lib/ports.chiral`:152 — `(extern ioctl (=> I64 I64 Bytes I64))`:
    the generic extern that exposes the surface-mutation hazard. Being retired.
  - `scaffold/lib/term.chiral`:1-92 — the surface layer. `tiocgwinsz` (line 26)
    does `cell-new 8` + `ioctl fd TIOCGWINSZ cell` — the exact `->`→hidden-mutate
    pattern this element removes. `tcgetattr` (line 53) does the same. `tcsetattr`
    (line 62) is value-in already (kernel only reads). `termios-set-raw` (line 69)
    is pure `->` already. `term-raw`/`term-restore` (lines 81-92) compose the
    above.
  - `scaffold/lib/crossing-wraps.chiral`:23 — `(pair "ioctl" "nb-sys-ioctl")`:
    the existing crossing-wraps entry. New entries needed for the two new
    wrappers.
  - `scaffold/lib/target-linux.chiral`:21 — `(sys-row "nb-sys-ioctl" 16)`:
    the syscall whitelist entry. New entries needed.
  - `scaffold/lib/bytes-tal.chiral`:478-499 — `cell-new`, `bget-u16-le`,
    `bget-u32-le`, `bput-u32-le`: the pure surface helpers. `cell-new` is the
    `->` allocator whose immutability claim the old pattern violates; the new
    pattern does not use it for kernel-facing cells.
- **True delta:**
  - ADD: 2 new TAL wrappers in `sys-tal.chiral` (alloc-inside pattern)
  - ADD: 2 new externs in `ports.chiral` (`nb-winsz-raw`, `nb-tcgets-raw`)
  - ADD: 2 new crossing-wraps entries
  - ADD: 2 new target-linux syscall rows (both syscall 16, different names)
  - MODIFY: `term.chiral` — `tiocgwinsz`, `tcgetattr` switch from `ioctl`+`cell-new`
    to the new alloc-inside crossings
  - REMOVE: `(extern ioctl ...)` from `ports.chiral:152`
  - REMOVE: old `nb-sys-ioctl-t` from `sys-tal.chiral:448-453`
  - REMOVE: old `(pair "ioctl" "nb-sys-ioctl")` from crossing-wraps
  - REMOVE: old `(sys-row "nb-sys-ioctl" 16)` from target-linux

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **S12(c) — wrapper home:** put per-request ioctl crossings in `sys-tal.chiral` (beside `nb-sys-read-t`) or carve a new `term-tal.chiral` leaf? | RESOLVED — sys-tal | Author resolved S12c: wrapper home = sys-tal. Keeps all syscall wrappers in one file (simple, fewer files to sync to public mirror). Decision recorded in INDEX. |
| 2 | **Fate of the generic `ioctl` extern:** retire it (remove `ports.chiral:152` + old TAL + old crossing-wraps entry) or demote it to a documented non-surface primitive? | RESOLVED — RETIRE | Author resolved: RETIRE, delete rows. Nothing else uses it once term.chiral is reworked, and leaving it standing re-admits the surface-mutation hazard. Decision recorded in INDEX. |
| 3 | Cell sizes: 8 bytes for winsize, 60 bytes for termios. | RESOLVED | Linux kernel `struct winsize` = 8 bytes (4× u16). `struct termios` = ~36 bytes; 60 is oversized-safe headroom. Both confirmed in worked example §2 (research). `c_lflag` at offset 12 is cross-verified in both classic and kernel `termios`/`termios2` layouts. |
| 4 | TCSETS: keep value-in shape or also convert to alloc-inside? | RESOLVED | Keep value-in. The kernel only READS the TCSETS cell — there is no mutation, so passing a surface `Bytes` is already honest. The worked example §1 confirms: "TCSETS keeps the value-in shape." No fold/CSE hazard exists on the read path. |
| 5 | Timing: retire old ioctl immediately (one wave) or in a follow-on? | RESOLVED | Same wave. Leaving the old generic ioctl in place after the new crossings are built re-admits the hazard. The negative gate — "no `cell-new` → `ioctl` mutation pattern anywhere" — is only satisfied if the old extern is gone. |

All decisions dispositioned: 5 RESOLVED, 0 NEEDS-AUTHOR.

**`status: ready` — all author decisions resolved. Change plan §4 is unlocked
for implementation.** The plan is written against sys-tal home + retire ioctl
as confirmed by the author.

## 4. Change plan (ordered, commit-sized)

### Step 0 — Author decisions (RESOLVED)
- **Target:** this SPEC §3, decisions #1 and #2.
- **Status:** Both resolved. Wrapper home = `sys-tal.chiral` (per S12c). Old ioctl
  fate = RETIRE (delete rows). Proceed with plan as written — no adjustments needed.

### Step 1 — Add `nb-sys-winsz-t` TAL wrapper (alloc-inside, winsize)
- **Target:** `scaffold/lib/sys-tal.chiral` — new `def` between `nb-sys-ioctl-t`
  (line 453) and `nb-sys-env-get-t` (line 455).
- **Change:** Add a new `TIFn` following the `nb-sys-read-t` idiom:
  ```chirality
  ; nb-sys-winsz-t: TIOCGWINSZ (0x5413 = 21523), alloc-inside.
  ; Allocates an 8-byte cell internally, passes its pointer to the kernel,
  ; returns the fresh cell (or the raw errno in the result register).
  (def nb-sys-winsz-t TIFn
    (ti-fn "nb-sys-winsz" 1 5
      (t-seq (ti-const 1 21523)          ; TIOCGWINSZ
      (t-seq (ti-bnew 2 8)               ; alloc 8-byte cell
      (t-seq (ti-bptr 3 2)               ; pointer to cell
      (t-seq (ti-sys 4 16 (cons 0 (cons 1 (cons 3 nil))))  ; ioctl(fd, 0x5413, ptr)
        (ti-ret 4)))))))                  ; return fresh cell (or -errno in reg 4)
  ```
  The wrapper takes `fd` (arg 0), allocates 8 bytes, calls ioctl(fd, TIOCGWINSZ, ptr),
  and returns the raw result. The surface layer decodes the returned cell via
  pure `bget`s — no `cell-new` involved.
- **Size:** S (~12 lines)

### Step 2 — Add `nb-sys-tcgets-t` TAL wrapper (alloc-inside, termios)
- **Target:** `scaffold/lib/sys-tal.chiral` — after `nb-sys-winsz-t`.
- **Change:** Mirror of Step 1, with TCGETS (0x5401 = 21505) and 60-byte cell:
  ```chirality
  ; nb-sys-tcgets-t: TCGETS (0x5401 = 21505), alloc-inside.
  ; Allocates a 60-byte termios cell internally, passes pointer to kernel,
  ; returns fresh cell.
  (def nb-sys-tcgets-t TIFn
    (ti-fn "nb-sys-tcgets" 1 5
      (t-seq (ti-const 1 21505)          ; TCGETS
      (t-seq (ti-bnew 2 60)              ; alloc 60-byte cell (oversized-safe)
      (t-seq (ti-bptr 3 2)               ; pointer to cell
      (t-seq (ti-sys 4 16 (cons 0 (cons 1 (cons 3 nil))))  ; ioctl(fd, 0x5401, ptr)
        (ti-ret 4)))))))                  ; return fresh cell (or -errno)
  ```
- **Size:** S (~10 lines)

### Step 3 — Register new wrappers in sys-lib, crossing-wraps, target-linux
- **Targets:** Three files — `sys-tal.chiral` (sys-lib cons chain), `crossing-wraps.chiral`, `target-linux.chiral`.
- **Change:**
  - `sys-tal.chiral` sys-lib: add `nb-sys-winsz-t` and `nb-sys-tcgets-t` to the cons chain (anywhere; order not load-order-critical for sys-lib).
  - `crossing-wraps.chiral`: add `(pair "nb-winsz-raw" "nb-sys-winsz")` and `(pair "nb-tcgets-raw" "nb-sys-tcgets")`.
  - `target-linux.chiral`: add `(sys-row "nb-sys-winsz" 16)` and `(sys-row "nb-sys-tcgets" 16)` — both use syscall 16 (ioctl).
- **Size:** S (~5 lines per file)
- **Pitfall:** `target-linux.chiral` is a DEFAULT-DENY registry. Missing entries
  cause B1 self-compile rejection via `ck-sys` → `sbad`. The file has no `nil`
  in the cons chain — trailing close-paren count must increase by 2 (one per
  new cons entry). Use `execute_code` to compute exact paren count, never count
  by hand.

### Step 4 — Add surface externs in ports.chiral
- **Target:** `scaffold/lib/ports.chiral` — new externs near the old `ioctl` at line 152.
- **Change:** Add two new externs:
  ```chirality
  (extern nb-winsz-raw  (=> (fd I64) RawR))
  (extern nb-tcgets-raw (=> (fd I64) RawR))
  ```
  `RawR` is already defined in `term.chiral` (line 77-79): `(data RawR () (raw-r (cell Bytes)) (raw-err (errno I64)))`.
  **Pitfall:** `ports.chiral` import order — `term.chiral` (which defines `RawR`)
  must be loaded before `ports.chiral` in the blob, or `RawR` must be moved to
  `ports.chiral`. The current term.chiral `(import "ports")` means `ports` comes
  first. Move `RawR` to `ports.chiral` before the new externs, or adjust the
  import order. Check §4 Step 5.
- **Size:** S (~4 lines + potential type move)

### Step 5 — Rework term.chiral to use new crossings
- **Target:** `scaffold/lib/term.chiral` — `tiocgwinsz` (line 26), `tcgetattr` (line 53), `tcsetattr` (line 62).
- **Change:**
  - `tiocgwinsz`: replace `(let (cell (cell-new 8)) (let (rc (ioctl fd IOC_TIOCGWINSZ cell)) ...` with a call to `nb-winsz-raw` + pure decode. The example §5 shows the pattern: `(winsz-decode (nb-winsz-raw fd))`. However, the current `term.chiral` already has `WinsizeR` with `(ws-r rows cols)` / `(ws-err errno)` — the decode extracts `bget-u16-le` at offsets 0 and 2.
  - `tcgetattr`: replace `(let (cell (cell-new TERMIOS_LEN)) (let (rc (ioctl fd IOC_TCGETS cell)) ...` with `nb-tcgets-raw fd` + the same errno/-ok dispatch.
  - `tcsetattr`: switch from `(ioctl fd IOC_TCSETS cell)` to a new `nb-tcsets` wrapper (value-in only — kernel reads the cell). Keep the current shape: `(declare nb-tcsets (=> (fd I64) (cell Bytes) I64))` or inline as `(let (_ (ioctl fd IOC_TCSETS cell)) unit)` → `(let (_ (nb-tcsets fd cell)) unit)`. Wait: if we retire the old `ioctl` extern, `tcsetattr` needs a TCSETS-specific wrapper. Add `nb-sys-tcsets-t` in Step 5b (or Step 1b) — a simple TAL wrapper that does `ti-bptr` + `ti-sys 16` with TCGETS request code, value-in (kernel reads, doesn't write). Same pattern as old `nb-sys-ioctl-t` but explicitly value-in.
  - Remove `(import "ports")` for `ioctl` — replace with imports for the new externs.
- **Clarification:** The TCSETS path. `tcsetattr` currently calls `(ioctl fd IOC_TCSETS cell)` where `cell` is a surface Bytes. Since the kernel only READS (doesn't mutate), this is already honest — but if we retire `ioctl`, we still need a wrapper. Add a minimal `nb-sys-tcsets-t` (3-arg, value-in, same shape as old `nb-sys-ioctl-t` but hardcoded to TCGETS = 21506). This wrapper does NOT need alloc-inside — it's value-in by design.
- **Size:** M (~20-30 lines modified across 3 functions, plus 1 new TAL wrapper)

### Step 6 — Remove old generic ioctl
- **Target:** Four files.
- **Change:**
  - `ports.chiral:152`: delete `(extern ioctl (=> I64 I64 Bytes I64))`
  - `sys-tal.chiral:448-453`: delete `nb-sys-ioctl-t`
  - `crossing-wraps.chiral:23`: delete `(pair "ioctl" "nb-sys-ioctl")`
  - `target-linux.chiral:21`: delete `(sys-row "nb-sys-ioctl" 16)`
  - `sys-tal.chiral` sys-lib: remove `nb-sys-ioctl-t` from the cons chain
- **Size:** S (~6 lines removed, 4 files)

### Step 7 — Sync to public mirror, rebuild B1, verify fixpoint
- **Target:** `chirality/` public mirror.
- **Change:** Copy all changed files (`sys-tal.chiral`, `ports.chiral`, `crossing-wraps.chiral`, `target-linux.chiral`, `term.chiral`), run `./build.sh`, verify byte-identical fixpoint. Copy new `bin/chirality-bin` back as `scaffold/build/B1`.
- **Size:** S (mechanical sync)
- **Pitfall:** All changed files must be synced TOGETHER. Missing any one causes
  "no emitted label" (missing crossing-wraps) or "duplicate label" (if
  `sys-tal.chiral` is pulled into user blob when B1 already has the new wrappers
  baked in).

## 5. Conformance gate

- **Golden behavior:**
  1. `tiocgwinsz fd` under a pty returns `(ws-r rows cols)` with non-zero
     `rows`/`cols` — exact same behavior as today, but through the alloc-inside
     path. Negative: `ws-r` result must NOT be foldable to `(ws-r 0 0)` by any
     future CSE strengthening — the fresh cell breaks the purity chain.
  2. `term-raw fd` → `(raw-r saved)` then `term-restore fd saved` restores
     cooked mode — exact same behavior as today, zero diff.
  3. After E99, `grep cell-new scaffold/lib/term.chiral` returns zero matches.
  4. After E99, `grep 'ioctl' scaffold/lib/ports.chiral` returns zero matches
     (retired).
  5. `chirality test-native` passes with zero regressions.
- **Tests to add:**
  - `test_tiocgwinsz_pty`: spawn a pty pair, call `tiocgwinsz` on the slave fd,
    assert `(ws-r r c)` with `r > 0`, `c > 0`. Compare against `stty size` on
    the master fd.
  - `test_tcgetattr_pty`: spawn pty, call `tcgetattr`, assert `(tios-ok cell)`
    with `blen cell == 60`.
  - `test_term_raw_restore`: spawn pty, `term-raw` → `(raw-r saved)`, verify
    saved cell is non-zero length, `term-restore` returns unit, pty is still
    usable.
  - `test_no_cell_new_in_term`: static grep assertion — zero occurrences of
    `cell-new` in `scaffold/lib/term.chiral`.
  - `test_no_generic_ioctl`: static grep assertion — zero occurrences of the
    generic `ioctl` extern in `ports.chiral` (if retired).
  - Golden list tests: `test_eff_lower_chirality.py` and `test_sig_derive_chirality.py`
    golden fixture lists must be updated for the new and removed crossings.
- **Green line:** 731 tests → ≥ 735 tests (4 new behavioral + golden list
  updates pass); `chirality test` clean; `chirality test-native` clean.
- **Done when:** `chirality test` passes, `grep cell-new term.chiral` is empty,
  `grep '(extern ioctl' ports.chiral` is empty, and a pty-spawn
  test verifies `tiocgwinsz` returns live window dimensions through the
  alloc-inside path.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **Full `termios` struct decoder.** E99 only decodes `c_lflag` at offset 12
    (the field `termios-set-raw` needs). The other ~30 fields (`c_iflag`,
    `c_oflag`, `c_cflag`, `c_line`, `c_cc[NCCS]`, `c_ispeed`, `c_ospeed`)
    are untouched. If scriba ever needs baud rate, flow control, or special
    characters, they go in a follow-on element.
  - **`term-tal.chiral` leaf.** Not needed — author resolved wrapper home = sys-tal.
  - **`nb-tcgets-raw` pure decoder function.** The example §5 sketches a
    `TermiosR`-returning decoder that mirrors `winsz-decode`. The current
    `tcgetattr` already decodes via `tios-ok` / `tios-err` dispatch — the raw
    crossing just returns the cell, and the decoder extracts fields on demand.
    Not needed until a second field is accessed.
- Follow-on:
  - Any future ioctl request family (e.g., `TIOCGPTN` for pty negotiation,
    `FIONREAD` for readable byte count) gets its own per-request crossing
    following this pattern. The E99 spec serves as the template.
  - When fold/CSE is strengthened (a future optimizer pass), E99 is the
    precondition that prevents ioctl results from being constant-folded.
  - `nb-tcsets-t` (the value-in-only TCSETS TAL wrapper added in Step 5) is
    generalizable: any ioctl that only reads the third arg (kernel-read,
    no writeback) follows the same 3-arg value-in pattern.
- **Related:** [[E99-ioctl-out-cells]] (the example); [[E97-skip-chain-diagnostics]]
  (boundary sums — `WinsizeR`/`TermiosR`/`RawR` errno-or-value shape reused
  here); `nb-sys-read-t` (sys-tal.chiral:39-53, the alloc-inside precedent);
  [[pattern-boundary-sums]] (the fresh cell *is* the crossing evidence).
