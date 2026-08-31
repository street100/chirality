# scriba ← chirality: syscall handoff

> **⚑ RESCOPED 2026-08-11 — see `TUI/docs/SCRIBA-TERMINAL-RESCOPE.md`.** The raw-mode /
> `term-raw` fd0 / read-key narrative below is now **the `(R)` real-terminal backend
> of the `Terminal` port**, not "what scriba does directly." The "does NOT need pty"
> list stays correct — pty/`Session` caps live in the `session`/emulator lane
> (`TUI/`), not scriba. VT parsing = the `vt-core` lib; multiplexing mechanism = the
> `mux` lib. Architecture: `TUI/README.md` + `TUI/docs/TERMINAL-PORT-DESIGN.md`.

**From:** scriba (Shea)
**To:** chirality agents / scriba developers
**Date:** 2026-08-06
**Updated:** 2026-08-08 — scriba compiles through B1 but command loop is limited

## Status: COMPILES — NOT YET AN EDITOR

The scriba library (18 files) compiles through B1 into a 131KB ELF. What runs:
terminal raw-mode setup, a read-key loop that beeps on every key and exits on
"quit", then terminal restore. It cannot edit text, dispatch operations, or
render anything useful — the command loop only handles quit.

**B1 effect chain blocker:** Op dispatch (`lookup-scribaop` → `op-fn` call)
is written in `scriba/dispatch.chiral` (130/130 parens) but can't be wired into
`command-loop-inner` because B1 kills the entry label when a func body has 4+
effectful operations reachable from compile-main. The current limit is 3:
`read-key-sequence` + `lookup-keymap` + `recurse`. Adding `lookup-scribaop`
as the 4th breaks it. See dispatch.chiral header for exact repro.

| Syscall | TAL floor | Typed surface | Wired | Tests |
|---------|-----------|---------------|-------|-------|
| `write` (1) | `nb-sys-write-t` | `fd-write` in ports.chiral:97 | ✓ | ✓ |
| `close` (3) | `nb-sys-close-t` | `close` in ports.chiral:96 | ✓ | ✓ |
| `ioctl` (16) | `nb-sys-ioctl-t` | `ioctl` in ports.chiral:98 | ✓ | ✓ |

Typed wrappers for terminal control: `lib/term.chiral` — `tiocgwinsz`,
`tcgetattr`, `tcsetattr`, `term-raw`, `term-restore`. All ride the one `ioctl`
crossing.

## What scriba can use (typed surface, all in ports.chiral)

```chirality
(extern openat (=> Bytes I64))        ; self-wield.chiral:13 — NUL-term path → raw fd
(extern read   (=> I64 I64 Bytes))    ; ports.chiral:95 — raw fd, count → bytes
(extern close  (=> I64 Unit))         ; ports.chiral:96 — raw fd → closed
(extern fd-write (=> I64 Bytes I64))  ; ports.chiral:97 — raw fd, bytes → written or -errno
(extern ioctl  (=> I64 Bytes I64))     ; ports.chiral:98 — raw fd, request, cell → 0 or -errno
(extern put    (=> Str Unit))         ; ports.chiral:93 — stdout, no trailing newline
(extern print  (=> Str Unit))         ; ports.chiral:92 — stdout with newline
```

Plus terminal control from `lib/term.chiral`:

```chirality
(tiocgwinsz fd)     ; → (ws-r rows cols) | (ws-err errno)
(term-raw fd)       ; → (raw-r saved-termios) | (raw-err errno)
(term-restore fd saved)  ; → Unit
```

## Proc-spawn hacks still useful for fast iteration

These work today without any new crossings — chirality already spawns processes.
Use them for prototyping, replace with chirality-native when ready.

| Need | Hack | Native replacement |
|------|------|-------------------|
| File list | `proc-spawn ls -1` | deferred (getdents Phase 2) |
| Delete/rename | `proc-spawn rm`/`mv` | deferred (unlink/rename Phase 2) |
| fstat | `proc-spawn wc -c` | deferred |

## What scriba does NOT need

- `fstat` / `stat` — can hack with proc-spawn
- `getdents` / `readdir` — dired can use proc-spawn `ls`
- `unlink` / `rename` — proc-spawn `rm`/`mv`
- `mmap` — out of scope
- `select`/`poll` syscall — `poll2` already exists in ports.chiral:64
- signal handling — scriba can run without SIGWINCH for Phase 1
- pty management — shell mode is Phase 4+
- `Fd` porttype variants — stay with raw-I64 fd everywhere

## Verification

All three crossings verified by the full 678-test suite (scaffold/tests/,
`python3 -m unittest discover`). Targeted verification:

```
python3 /tmp/hermes-verify-scriba-syscalls.py
  parse ✓  bindings ✓  LIB_SIGS ✓  SYSCALL_TABLE ✓  tests (54) ✓
```

Specific scriba-level verification:
1. `(close (openat path-bytes))` → fd closed, no leak after N iterations
2. `(fd-write 1 (str->bytes "hello\n"))` → "hello" on stdout, returns 6
3. `(tiocgwinsz 0)` → returns actual terminal dimensions
4. `(term-raw 0)` → terminal in raw mode, keys appear immediately
5. `(term-restore 0 saved)` → terminal back to cooked mode

## Tracking — E# status

- `close` raw-I64 wrapper — **E28 EXTEND** (implemented)
- `fd-write` raw-I64 wrapper — **E28 EXTEND** (implemented)
- `ioctl` raw crossing + typed wrappers — **E86** (implemented 2026-08-06, catalog §IV)
- Worked example: `examples/E86-ioctl-crossing.md` (drafted, reviewed)
- SPEC: `.planning/specs/E86-ioctl-crossing-SPEC.md` (specced, audited)
- Implementation: `lib/sys-tal.chiral` (TAL), `lib/ports.chiral` (typed), `lib/term.chiral` (wrappers)

---

*scriba catalog: .planning/SCRIBA-CATALOG.md in the manas repo.*
