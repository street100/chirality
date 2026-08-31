---
element: E86
slug: ioctl-crossing
title: `ioctl` as sys crossing (terminal control: TIOCGWINSZ, TCGETS/TCSETS)
kind: REPLACE-CRUTCH
example: examples/E86-ioctl-crossing.md
status: audited
updated: 2026-08-06
---

# E86 SPEC — `ioctl` as sys crossing (terminal control: TIOCGWINSZ, TCGETS/TCSETS)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `ioctl`(2) syscall (nr 16) is a working chirality crossing —
  TAL floor `nb-sys-ioctl-t`, typed surface `(extern ioctl (=> I64 I64 I64 I64))`
  in ports.chiral, and a new `scaffold/lib/term.chiral` with typed terminal-control
  wrappers (tiocgwinsz, tcgetattr/tcsetattr, term-raw/term-restore). scriba can
  query terminal size and enter/restore raw mode without proc-spawn.
- **Non-goals:** non-terminal ioctls (FIONREAD, TIOCSTI, etc.), `Fd` porttype
  threading (linear `Fd` is E51), SIGWINCH signal handling, termios struct fields
  beyond c_lflag (baud rate, c_cc), `bytes-tal.chiral` primitives (bget-u16-le,
  bget-u32-le, bput-u32-le, cell-copy — CHECK existence before impl; add if
  missing but scoped to byte-cell floor, not ioctl), refinement type annotations
  on winsize fields (E9, aspirational — plain I64 for now, per FLAG from example
  audit).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** BUILD — E86 postdates the map snapshot; zero code
  at any layer. The handoff (.planning/SCRIBA-SYSCALL-HANDOFF.md) confirms a pure
  gap: no TAL crossing, no target-linux entry, no typed surface.
- **Live code (shards this composes with):**
  - `scaffold/lib/sys-tal.chiral` — the TAL floor: `nb-sys-clock-gettime-t` at
    line 129 is the model (kernel-fills-caller-cell pattern: ti-bptr for the arg
    cell, ti-sys nr N). `nb-sys-lseek-t` at line 64 is the all-integer-args
    model. The `sys-lib` list at line 383 collects all `nb-sys-*-t` defs; E76
    chokepoint test asserts `len(sys-lib) == len(SYSCALL_TABLE)`.
  - `scaffold/lib/target-linux.chiral` — `linux-syscalls` `SysReg` at line 11:
    the swappable backend mapping `nb-sys-*` names → syscall numbers.
  - `scaffold/lib/crossing-wraps.chiral` — `crossing-wraps` list at line 13:
    `(Pair Str Str)` mapping bound-crossing names → wrapper names. `cw-lookup` at
    line 26 does the lookup. `ioctl` maps directly to `nb-sys-ioctl` (no wrap-*
    since ioctl crosses directly from the typed surface; same pattern as
    `read`/`close`/`fd-write`).
  - `scaffold/lib/ports.chiral` — the typed surface: raw-I64 externs for `read`
    (line 95), `close` (line 96), `fd-write` (line 97). `ioctl` follows the same
    all-I64 shape: `(extern ioctl (=> I64 I64 I64 I64))`.
  - `scaffold/chirality/native.py` — `LIB_SIGS` dict at line 87: entry
    `"nb-sys-ioctl": ([I64, I64, I64], I64)` — fd, request, cell → result-or-errno.
  - `scaffold/chirality/tal.py` — `SYSCALL_TABLE` dict at line 104: entry
    `"nb-sys-ioctl": 16`.
  - `scaffold/tests/test_sig_derive_chirality.py` — `test_bound_crossings_matches_oracle`
    at line 95: golden list of `(extern, wrapper)` pairs. Add
    `("ioctl", "nb-sys-ioctl")`.
  - `scaffold/tests/test_e76_chokepoint.py` — auto-validates that `sys-lib`
    length matches `SYSCALL_TABLE` (line 123); adding `nb-sys-ioctl-t` to
    `sys-lib` + `nb-sys-ioctl` to `SYSCALL_TABLE` keeps the invariant.
  - `scaffold/lib/bytes-tal.chiral` — byte-cell primitives (bget-u16-le,
    bget-u32-le, bput-u32-le, cell-new, cell-copy). CHECK before impl; add any
    missing primitives as a pre-step (scoped to the byte-cell floor, not ioctl).
- **True delta:** new file (`scaffold/lib/term.chiral`), 1 new TAL crossing
  (`nb-sys-ioctl-t`), 1 new syscall-registration row (target-linux + tal.py),
  1 new crossing-wraps row, 1 new extern (ports.chiral), 1 new LIB_SIGS entry,
  2 golden-list extensions, possible byte-cell-primitive additions.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Does `term.chiral` import from `ports.chiral` or duplicate the `ioctl` extern? | RESOLVED — keep ioctl in ports.chiral | Precedent: `self-wield.chiral` duplicates `openat` but that's a self-contained wield file; `term.chiral` is a typed wrapper layer — it SHOULD import `ports` so the `ioctl` extern has one canonical home. The `ioctl` extern lives in `ports.chiral`; `term.chiral` imports `ports`. |
| 2 | Is the `Fd` porttype upgrade in-scope for E86? | DEFERRED → E51 | Raw I64 fds match `read`/`openat` precedent; linear `Fd` threading is E51's transport swap. |
| 3 | What about struct-packing helpers (bget-u16-le, bput-u32-le, cell-copy)? | RESOLVED — audit during impl | CHECK `bytes-tal.chiral` for each primitive before writing `term.chiral`. If missing, add to the byte-cell floor as a pre-step (scoped there, not to ioctl). The crossing itself doesn't depend on these — only the typed wrappers do. |
| 4 | How many args does the TAL crossing pass? | RESOLVED — 3 args (fd, request, cell) | ioctl(fd, request, arg). The kernel gets the cell's payload pointer via ti-bptr (like clock_gettime). Signature: `(=> I64 I64 I64 I64)` — 3 args + return. TAL: ti-fn with 3 params, 5 temps (params + bptr temp + result temp), ti-sys nr 16 with arg list `(cons 0 (cons 1 (cons 3 nil)))` where temp 3 holds the bptr'd register (bptr of param 2), result in temp 4. Model on clock_gettime:129. |
| 5 | TCSETS (0x5402) — kernel reads the cell; does the bptr direction matter? | RESOLVED — ti-bptr works for both reads and writes | ti-bptr passes the cell's payload pointer to the kernel. Whether the kernel reads (TCSETS) or writes (TIOCGWINSZ, TCGETS) is the kernel's business — the TAL crossing is uniform. |

No NEEDS-AUTHOR — all questions have settled answers.

## 4. Change plan (ordered, commit-sized)

### Step 1 — TAL crossing: `nb-sys-ioctl-t` in sys-tal.chiral
- **Target:** `scaffold/lib/sys-tal.chiral` — new `nb-sys-ioctl-t` def + append to `sys-lib`
- **Change:** Add after `nb-sys-close-t` (line 123) or before `nb-sys-clock-gettime-t` (line 129), model on `nb-sys-clock-gettime-t`:
  ```chirality
  ; ioctl(fd, request, arg-cell) -> 0 (or -errno). The kernel reads or writes
  ; the caller-allocated byte cell depending on the request code; the cell's
  ; payload pointer is passed via ti-bptr. nr 16; args rdi rsi rdx.
  (def nb-sys-ioctl-t TIFn
    (ti-fn "nb-sys-ioctl" 3 5
      (t-seq (ti-bptr 3 2)
      (t-seq (ti-sys 4 16 (cons 0 (cons 1 (cons 3 nil))))
        (ti-ret 4)))))
  ```
  Append to `sys-lib` list at line 383.
- **Size:** S

### Step 2 — Syscall registration: target-linux.chiral + tal.py
- **Target:** `scaffold/lib/target-linux.chiral` — insert `(sys-row "nb-sys-ioctl" 16)` into `linux-syscalls`
- **Target:** `scaffold/chirality/tal.py` — add `"nb-sys-ioctl": 16` to `SYSCALL_TABLE`
- **Change:** Insert the row in target-linux (alphabetically between `"nb-sys-ftruncate"` and `"nb-sys-lseek"`). Add the entry to tal.py (alphabetically between `"nb-sys-ftruncate"` and `"nb-sys-lseek"`).
- **Size:** S

### Step 3 — Typed surface: ports.chiral + native.py LIB_SIGS
- **Target:** `scaffold/lib/ports.chiral` — add `(extern ioctl (=> I64 I64 I64 I64))` near line 97 (after `fd-write`)
- **Target:** `scaffold/chirality/native.py` — add `"nb-sys-ioctl": ([I64, I64, I64], I64)` to `LIB_SIGS` (alphabetically among the `nb-sys-*` entries, near line 123)
- **Change:** One extern line + one LIB_SIGS entry. Follow the raw-I64 pattern of `read`, `close`, `fd-write`.
- **Size:** S

### Step 4 — Crossing-wraps: ioctl → nb-sys-ioctl
- **Target:** `scaffold/lib/crossing-wraps.chiral` — add `(cons (pair "ioctl" "nb-sys-ioctl")` to `crossing-wraps` list (near line 20, beside `read`/`close`)
- **Change:** One pair in the list.
- **Size:** S

### Step 5 — Golden lists: test_sig_derive_chirality.py + test_eff_lower_chirality.py
- **Target:** `scaffold/tests/test_sig_derive_chirality.py` line 99–102 — add `("ioctl", "nb-sys-ioctl")` to the `pairs` list and to the sorted `got` assertion on line 105
- **Target:** `scaffold/tests/test_eff_lower_chirality.py` — if this file has a standalone golden list of crossings, add `"ioctl"`; otherwise skip (the XS list at line 97 is for test fixtures only, not a production golden list)
- **Change:** One pair. E76 chokepoint test auto-validates consistency.
- **Size:** S

### Step 6 — Byte-cell audit: verify primitives exist
- **Target:** `scaffold/lib/bytes-tal.chiral` — check for `bget-u16-le`, `bget-u32-le`, `bput-u32-le`, `cell-new`, `cell-copy`
- **Change:** If any are missing, add to `bytes-tal.chiral` + `native.py` `LIB_SIGS` + tal-primitive registrations. This is a pre-step — the crossing doesn't depend on these, only the typed wrappers do.
- **Size:** S (mostly verify; add if needed)

### Step 7 — Typed wrappers: new `scaffold/lib/term.chiral`
- **Target:** NEW FILE `scaffold/lib/term.chiral`
- **Change:** Copy the §5 chirality snippet from the worked example (examples/E86-ioctl-crossing.md §5), adapted to import from `ports` (the `ioctl` extern) and `bytes-tal` or `prelude` (byte-cell primitives). Content:
  - Layer 1: ioctl request codes as `(def ...)` constants
  - Layer 2a: `WinsizeR` data, `winsize-unpack`, `tiocgwinsz`
  - Layer 2b: `TERMIOS_LEN`, `TERMIOS_C_LFLAG_OFF`, `termios-raw-mask`, `tcgetattr`, `tcsetattr`
  - Layer 3: `termios-set-raw`, `RawR` data, `term-raw`, `term-restore`
- **Size:** M (~80–100 lines of pure chirality)

### Step 8 — Run test suite
- **Change:** `pytest scaffold/tests/test_native.py scaffold/tests/test_e76_chokepoint.py scaffold/tests/test_sig_derive_chirality.py -x -v` — verify all pass. Then full suite to catch regressions.
- **Size:** S (verification)

## 5. Conformance gate

- **Golden behavior:**
  1. `(ioctl 0 IOC_TIOCGWINSZ cell)` → kernel fills the 8-byte cell with `struct winsize`; byte-identical to CPython `fcntl.ioctl(0, termios.TIOCGWINSZ, buf)`.
  2. `(ioctl 0 IOC_TCGETS cell)` → kernel fills the 60-byte cell with `struct termios`; byte-identical to CPython `termios.tcgetattr(0)`.
  3. `(ioctl 0 IOC_TCSETS cell)` → kernel applies termios settings; subsequent reads reflect the change.
  4. `tiocgwinsz(0)` → returns actual terminal rows/cols (≥ 0), agreeing with `os.get_terminal_size()`.
  5. `term-raw(0)` → terminal enters raw mode, keys appear immediately; returns saved termios for restore.
  6. `term-restore(0, saved)` → terminal returns to cooked mode.
- **Tests to add:** Golden tests in `test_native.py` following the clock_gettime pattern — issue the raw `nb-sys-ioctl` crossing on stdin/stdout and check cell contents vs CPython. At minimum: `test_ioctl_tiocgwinsz`, `test_ioctl_tcgetattr`, `test_ioctl_tcsetattr_raw_restore` (the last is a roundtrip: get→modify c_lflag→set→get→verify bits cleared→restore→verify restored).
- **Green line:** current 673 → ≥ 676 (3 new golden tests). ledger-lint clean.
- **Done when:** `pytest scaffold/tests/ -x` passes with ≥ 3 new ioctl-specific test functions, and `python3 -m scaffold.chiral.tal` tal-check accepts `nb-sys-ioctl-t`.

## 6. Residue & links

- **Deliberately unbuilt:**
  - Non-terminal ioctls (FIONREAD, TIOCSTI, etc.) — each family gets its own typed wrapper when needed; deferred to their own E#s.
  - `Fd` porttype linear threading — E51 transport swap (the `(=> (1 f Fd) I64 I64 (Pair (1 f Fd) I64))` shape).
  - SIGWINCH handling — scriba's command loop, not the crossing.
  - termios struct fields beyond c_lflag (baud rate, c_cc special chars) — unused by raw-mode toggle.
  - Refinement type annotations on winsize fields — E9 refinement engine; plain `I64` for now.
- **Follow-on:** This unblocks scriba's terminal-control surface — `close` and `fd-write` are already built (typed surface gaps filled in E28 EXTEND); with `ioctl`, scriba can query terminal size and enter/restore raw mode entirely through chirality crossings (zero proc-spawn in the hot path).
- **Related:** [[E86-ioctl-crossing]] · [[E32-clock-exit-env]] (sibling struct-returning crossing; clock_gettime precedent for kernel-fills-caller-cell pattern) · [[E28-mmap-crossings]] (sibling raw-syscall element) · [[E51-sys-linkage]] (Fd porttype upgrade) · `scaffold/lib/sys-tal.chiral` (TAL floor) · `scaffold/lib/ports.chiral` (typed surface) · `.planning/SCRIBA-SYSCALL-HANDOFF.md` (scriba requirement).
