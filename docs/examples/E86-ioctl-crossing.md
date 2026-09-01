---
element: E86
slug: ioctl-crossing
title: `ioctl` as sys crossing (terminal control: TIOCGWINSZ, TCGETS/TCSETS)
kind: REPLACE-CRUTCH
reference_class: SPEC
ours_source: (none)
status: superseded
superseded_by: E99
updated: 2026-09-01
---

# E86 — `ioctl` as sys crossing (terminal control: TIOCGWINSZ, TCGETS/TCSETS)

> **SUPERSEDED 2026-09-01 by E99** — [[E99-ioctl-out-cells]]. E86 shipped
> 2026-08-06 as a single generic 3-arg `ioctl` crossing over a surface-allocated
> `Bytes`. E99 founds its own baseline on exactly that artifact — *"Partially
> built — one generic 3-arg ioctl crossing works at runtime (pty-verified) but
> mutates a `cell-new` (pure `->`) Bytes in place"*
> (E99's catalog row, `docs/elements/catalog.md`) — and replaces it with
> per-request-family crossings that allocate the out-cell INSIDE the wrapper and
> return a fresh value. E99's SPEC decision 5 resolved to retire the generic
> extern in the same wave, because leaving it "re-admits the hazard"
> (`docs/elements/specs/E99-ioctl-out-cells-SPEC.md:86`), and the INDEX records E99
> implemented 2026-08-09 with *"old ioctl retired"* (E99's `docs/examples/INDEX.md` row).
> Nothing E86 shipped survives: `grep -rn "extern ioctl" lib/ prog/` is empty.
> E104 then built the pty acquisition crossings on E99's surface
> (E104's catalog row; `lib/ports/pty.port:40`).
>
> The body below is unchanged. It is the record of what was decided in August,
> not a live design.

---

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E86, the `ioctl`(2) syscall — device control, parameterized by
  request code. The first concrete target is terminal control: query size
  (TIOCGWINSZ), get/set terminal attributes (TCGETS/TCSETS), enter raw mode.
- **Kind:** REPLACE-CRUTCH — shed the `proc-spawn stty` / `proc-spawn tput` crutch
  and the CPython `os.get_terminal_size()` / `termios` module.
- **Why chirality needs its own:** ioctl is the last syscall gap blocking a pure-chirality
  terminal environment (scriba). Without it, every terminal interaction routes
  through proc-spawn — a process spawn per raw-mode toggle, a parse of `stty size`
  output per resize. The TAL floor already has write/read/close/openat; ioctl
  closes the terminal-control surface.

## 2. Research

- **Reference class:** SPEC — Linux `ioctl`(2) ABI, termios(3).
- **Key findings:**
  - **Syscall number 16**, signature `ioctl(fd, request, arg)`. The request
    code selects an operation; `arg` is either an integer or a pointer the
    kernel reads/writes. For terminal ioctls, `arg` is always a pointer to a
    caller-allocated struct — the kernel is just another writer (the
    `clock_gettime` precedent: `nb-sys-clock-gettime-t` gives the kernel a
    caller-allocated cell to fill).
  - **TIOCGWINSZ (0x5413):** the kernel fills a 4-ushort `struct winsize`
    {ws_row, ws_col, ws_xpixel, ws_ypixel}. 8 bytes total. chirality unpacks the
    first two ushorts for rows/cols; pixels are unused.
  - **TCGETS (0x5401) / TCSETS (0x5402):** the kernel reads/writes a ~60-byte
    `struct termios`. chirality only needs ~5 flag fields — the ones controlling
    echo, canonical mode, and signal generation (ISIG). The rest pass through
    unchanged (read-modify-write).
  - **ioctl is the B-referent varargs trap:** the request code IS the type
    discriminator. A caller passing the wrong struct to the wrong request
    reads/writes garbage at kernel-pointer distances. chirality wraps each request
    family in a typed function that packs the correct struct — the raw `ioctl`
    extern is never called directly by application code.

## 3. Conventional (other-language) approach

```python
# Python: os module abstracts ioctl away
term_size = os.get_terminal_size()  # TIOCGWINSZ
old = termios.tcgetattr(sys.stdin)  # TCGETS
new = termios.tcgetattr(sys.stdin)
new[3] = new[3] & ~termios.ECHO    # flip flag bits
termios.tcsetattr(sys.stdin, termios.TCSANOW, new)  # TCSETS
```

```c
// C: direct ioctl with struct pointers
#include <sys/ioctl.h>
struct winsize ws;
ioctl(STDIN_FILENO, TIOCGWINSZ, &ws);  // kernel fills ws
printf("%d rows, %d cols\n", ws.ws_row, ws.ws_col);
```

- **Assumptions it bakes in:** ambient authority (any code can ioctl any fd),
  untyped `void*` arg (the struct pointer is a raw address; no proof it matches
  the request code), silent mutation (the kernel overwrites the struct — no
  linearity forcing the caller to consume the result), partiality (ioctl returns
  -1 on error; the caller must check manually), no effect distinction (ioctl
  is a process crossing — it mutates kernel state — but looks like any other
  function call).

## 4. The chirality idea

- **Chirality features in play:**
  - **Effect membrane `->` vs `=>`:** the raw ioctl crossing is `=>` — it
    performs a syscall. The typed wrappers (tiocgwinsz, tcgetattr) are also
    `=>` since they call ioctl. Pure unpacking helpers (winsize-unpack,
    termios-raw-flags) are `->`.
  - **Categories A/B/C:** the raw `ioctl` is a B crossing (the kernel's
    `void*` referent). The typed wrappers form a C bridge over it, packing
    known struct layouts at known offsets and calling the one raw crossing.
  - **Errors as values:** ioctl returns bytes-written-or-errno. The wrapper
    unpacks only on success (rc >= 0); a negative rc is an error the caller
    must case on.
  - **Linear ports:** the `Fd` authority is linear. ioctl doesn't consume the
    fd, so the long-term shape is `(=> (1 f Fd) I64 I64 (Pair (1 f Fd) I64))`
    — the fd threads through and returns. For Phase 1, raw I64 fds follow
    the `read` precedent: `(=> I64 I64 I64 I64)` — no linearity, ambient-like.
  - **Refinement:** the winsize result is `(refine I64 (>= 0))` for rows/cols
    after unpacking (a terminal with zero rows makes no sense, but the kernel
    can return 0 — the refinement encodes "we checked").

- **The reframing:** in C, ioctl is one function with a tag-and-pointer arg
  — the type of the arg is a documentation comment. In chirality, ioctl is ONE
  raw extern, but it is called only by typed wrappers, one per request family.
  Each wrapper owns the struct layout, packs/unpacks at the byte-cell level,
  and exposes a typed result. The raw extern is intentionally narrow — it
  takes the already-packed cell's payload pointer and the request code, and
  returns bytes-written-or-errno. The struct-packing code is pure `->` chirality
  using `bytes-tal.chiral` primitives.

- **What chirality makes impossible here:** calling `ioctl` with a wrong-struct
  for the request code (the typed wrapper owns the layout; the raw extern is
  not called directly by application code). Forgetting to check the return
  value (negative errno in the result forces a `case`). Ambiguity about
  whether the call crosses the membrane (`=>` is in the type).

## 5. Chirality example (fleshed)

```chirality
; E86 — ioctl as sys crossing with terminal-control wrappers.
; Three layers: raw TAL crossing → typed wrapper per request family → high-level
; term-raw/term-restore that scriba calls.
(import "prelude")
(import "bytes-tal")

; ── Layer 1: raw ioctl extern (B crossing) ──
; ioctl(fd, request, arg-cell) -> 0 success / -errno. arg-cell is a caller-
; allocated byte cell the kernel may read (TCSETS) or write (TIOCGWINSZ,
; TCGETS). The kernel gets the cell's PAYLOAD address via ti-bptr. This is
; the ONLY ioctl crossing — all typed wrappers call this one extern.
(extern ioctl (=> I64 I64 Bytes I64))

; IOC request codes (x86-64 Linux, /usr/include/asm-generic/ioctls.h)
; These are immediates — no new crossings.
(def IOC_TIOCGWINSZ I64 0x5413)
(def IOC_TCGETS      I64 0x5401)
(def IOC_TCSETS      I64 0x5402)

; ── Layer 2a: TIOCGWINSZ — terminal window size ──
; struct winsize { u16 ws_row, ws_col, ws_xpixel, ws_ypixel } = 8 bytes.
; Unpack row/col as (>= 0) I64 after checking the ioctl return.

(data WinsizeR ()
  (ws-r (rows I64) (cols I64))
  (ws-err (errno I64)))

(def winsize-unpack (-> I64 (Maybe WinsizeR))
  (lam (cell)
    ; little-endian u16 at offset 0 and 2 — skip xpixel(4)/ypixel(6)
    (let (rows (bget-u16-le cell 0))
      (let (cols (bget-u16-le cell 2))
        (some (ws-r rows cols))))))

(def tiocgwinsz (=> I64 WinsizeR)
  (lam (fd)
    (let (cell (cell-new 8))            ; fresh 8-byte cell
      (let (rc (ioctl fd IOC_TIOCGWINSZ cell))
        (case (<i rc 0)
          (true  (ws-err rc))
          (false (case (winsize-unpack cell)
                   ((some r) r)
                   (none     (ws-err -1)))))))))

; ── Layer 2b: TCGETS / TCSETS — terminal attributes ──
; struct termios is ~60 bytes. chirality only touches the flags that matter for
; raw mode: c_lflag (offset 12, u32) — ECHO(0x08), ICANON(0x02), ISIG(0x01).
; The read-modify-write pattern: get attrs, flip bits, set attrs.

(def TERMIOS_LEN I64 60)               ; sizeof(struct termios)
(def TERMIOS_C_LFLAG_OFF I64 12)       ; offset of c_lflag (u32)

(def termios-raw-mask I64 0xFFFFFFF4)  ; ~ (ECHO | ICANON | ISIG) for u32 mask
; Bitwise: AND with ~(0x08 | 0x02 | 0x01) = AND with 0xFFFFFFF4 clears those 3 bits.

(def tcgetattr (=> I64 I64)            ; fd -> termios cell (or -errno)
  (lam (fd)
    (let (cell (cell-new TERMIOS_LEN))
      (let (rc (ioctl fd IOC_TCGETS cell))
        (case (<i rc 0)
          (true  rc)                    ; caller cases on negative
          (false cell))))))

(def tcsetattr (=> I64 I64 Unit)       ; fd, termios cell -> ()
  (lam (fd cell)
    (let (_ (ioctl fd IOC_TCSETS cell))
      Unit)))

; ── Layer 3: term-raw / term-restore (scriba's API) ──
; Pure chirality bit manipulation over the termios cell. No new crossings.

(def termios-set-raw (-> I64 I64)       ; termios cell -> termios cell (in place)
  (lam (cell)
    (let (lflag (bget-u32-le cell TERMIOS_C_LFLAG_OFF))
      (let (raw (and lflag termios-raw-mask))
        (bput-u32-le cell TERMIOS_C_LFLAG_OFF raw)
        cell))))

(data RawR ()
  (raw-r (orig I64))                    ; the original termios cell (for restore)
  (raw-err (errno I64)))

(def term-raw (=> I64 RawR)             ; fd -> enter raw mode, return original
  (lam (fd)
    (let (attrs (tcgetattr fd))
      (case (<i attrs 0)
        (true  (raw-err attrs))
        (false
          (let (saved (cell-copy attrs TERMIOS_LEN))
            (let (_ (tcsetattr fd (termios-set-raw attrs)))
              (raw-r saved))))))))

(def term-restore (=> I64 I64 Unit)     ; fd, original termios cell -> restore
  (lam (fd orig)
    (tcsetattr fd orig)))
```

- **Knobs to modify:** request codes are x86-64 Linux — the same numbers on
  aarch64 but the ioctl command encoding macro differs (the `_IOC` bit layout);
  the TERMIOS_LEN is arch-dependent (verify against `/usr/include/.../termios.h`);
  the `termios-raw-mask` is scriba's raw-mode policy — a different editor may
  want different flags (e.g. IXON for flow control, ICRNL for CR→NL).
- **Deliberately omitted:** non-terminal ioctls (FIONREAD, TIOCSTI, etc. —
  each family gets its own typed wrapper when needed); the `Fd` porttype
  threading (Phase 1 uses raw I64 fds like `read`/`openat`; the linear-Fd
  upgrade is the same crossing swap E51 does for every port); SIGWINCH
  handling (the signal → resize loop belongs to scriba's command loop, not
  the crossing); `termios` struct fields beyond c_lflag (baud rate, c_cc
  special chars — unused by raw-mode toggle).

## 6. Use / modify notes

- **Lands in:**
  - `scaffold/lib/sys-tal.chiral` — `nb-sys-ioctl-t` (ti-fn, ti-bptr for the
    arg cell, ti-sys nr 16). Model on `nb-sys-clock-gettime-t` (kernel-fills-
    caller-cell pattern, sys-tal.chiral:129).
  - `scaffold/lib/target-linux.chiral` — syscall number 16.
  - `scaffold/lib/crossing-wraps.chiral` — `ioctl` → `nb-sys-ioctl`.
  - `scaffold/lib/ports.chiral` — `(extern ioctl (=> I64 I64 Bytes I64))`.
  - Typed wrappers: new `scaffold/lib/term.chiral` for tiocgwinsz/tcgetattr/
    tcsetattr/term-raw/term-restore (follow `lib/ports.chiral` style).
- **Conformance target:** differential test — issue the same ioctl via chirality
  and via CPython `fcntl.ioctl` / `os.get_terminal_size`, assert byte-identical
  struct contents. The clock_gettime test (test_eff_lower_chirality.py) is the
  pattern: one golden test that issues the raw crossing and checks the cell.
- **Open questions:**
  - Does `term.chiral` import from `ports.chiral` or duplicate the `ioctl` extern?
    (Precedent: `self-wield.chiral` duplicates `openat` — keep ioctl in ports.)
  - Is the `Fd` porttype upgrade in-scope for E86, or deferred to E51?
    (Deferred — raw I64 fds match `read`/`openat`; linear threading is E51.)
  - What about the struct-packing helpers (bget-u16-le, bput-u32-le)? These
    exist in `bytes-tal.chiral` or need to be added? (Check before impl.)
- **Related:** [[E86-ioctl-crossing]] · [[E32-clock-exit-env]] (sibling
  struct-returning crossing, clock_gettime precedent) · [[E28-mmap-crossings]]
  (sibling raw-syscall element) · [[E51-sys-linkage]] (the Fd porttype upgrade
  that threads linearity through every crossing) · `scaffold/lib/sys-tal.chiral`
  (the TAL floor where the crossing lands) · `scaffold/lib/ports.chiral` (the
  typed surface) · `docs/banks/port.md` · `.planning/SCRIBA-SYSCALL-`docs/decisions/decision-scope.md`
  (the scriba requirement that motivated this element).
