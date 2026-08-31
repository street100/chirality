---
element: E104
slug: pty-crossings
title: "Native pty acquisition crossings (E99 ioctl follow-on)"
kind: BUILD-PROPER
reference_class: OURS + IMPL
ours_source: (none — design from spec; mirrors E99 ioctl idiom in term.chiral/sys-tal.chiral/ports.chiral)
status: drafted
updated: 2026-08-10
---

# E104 — Native pty acquisition crossings (E99 ioctl follow-on)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E104 — chirality acquires its OWN pseudo-terminal pair natively: the
  raw four-step dance a terminal multiplexer/editor does with no libc `openpty`.
  `openat /dev/ptmx` (O_RDWR|O_NOCTTY) → master fd; ioctl `TIOCSPTLCK` writing
  int 0 → unlock the slave; ioctl `TIOCGPTN` reading the pts index N;
  `openat /dev/pts/N` (O_RDWR|O_NOCTTY) → slave fd.
- **Kind:** BUILD-PROPER — a designed-but-unbuilt feature. E99 shipped only the
  `tcgets`/`tcsets`/`winsz` ioctl families; no ptmx/pts path exists yet. E104
  mints **three** crossings: `nb-sys-ptsno-t` (alloc-inside ioctl `TIOCGPTN`),
  `nb-sys-ptunlock-t` (value-in ioctl `TIOCSPTLCK`), and **`open-rw`** — because
  the existing `openat` crossing is hardcoded `O_RDONLY`, a flags-taking open is
  required to open the pty `O_RDWR|O_NOCTTY`.
- **Why chirality needs its own:** so scriba (and any chirality terminal program) owns
  its terminal without a C harness. It is the prerequisite E103's pty behavioral
  test rides — chirality must drive both ends of a pty it opened itself. Author chose
  native pty over a C harness (2026-08-10).

## 2. Research

- **Reference class:** OURS (the E99 alloc-inside/value-in ioctl idiom already in
  `term.chiral` + `sys-tal.chiral` + `ports.chiral`) + IMPL (glibc/musl
  `openpty`/`grantpt`/`unlockpt`/`ptsname`, which wrap exactly these ioctls).
- **The ptmx/pts protocol** (`man 4 ptmx`, `man 3 ptsname`): open `/dev/ptmx` to
  get a master and an *automatically-allocated* slave; the slave is reached at
  `/dev/pts/N` where N is the decimal integer returned by `TIOCGPTN`. On modern
  Linux with a `devpts` mount the `unlockpt` step (`TIOCSPTLCK` ← 0) is what
  makes the slave openable. `O_NOCTTY` keeps the newly opened tty from becoming
  the process's controlling terminal.
- **Verified ioctl / flag constants** (the load-bearing web-research output — do
  NOT assert these from memory). `TIOCGPTN`/`TIOCSPTLCK` are `_IOR`/`_IOW`-encoded,
  NOT the flat `0x54xx` form the `TCGETS` family uses (`TCGETS` = `0x5401`). The
  encoding packs `dir<<30 | size<<16 | 'T'(0x54)<<8 | nr`; `_IOR` sets dir=2
  (kernel writes user buffer), `_IOW` sets dir=1 (kernel reads user buffer):

  | name | macro form | direction | computed value | source |
  |------|------------|-----------|----------------|--------|
  | `TIOCGPTN` | `_IOR('T', 0x30, unsigned int)` | READ (kernel→user, reads pts# into `*argp`) | `0x80045430` | uapi `asm-generic/ioctls.h` L69 |
  | `TIOCSPTLCK` | `_IOW('T', 0x31, int)` | WRITE (user→kernel, kernel reads int from `*argp`; 0 = unlock, nonzero = lock) | `0x40045431` | uapi `asm-generic/ioctls.h` L70 |
  | `O_RDWR` | — | — | `0x0002` (02 octal) | `bits/fcntl-linux.h` (x86-64) |
  | `O_NOCTTY` | — | — | `0x0100` (0400 octal) | `bits/fcntl-linux.h` (x86-64) |

  Combined open flags `O_RDWR|O_NOCTTY` = `0x0102`. Size field is
  `sizeof(int)` = 4 for both ioctls, hence the `0004` in the value. `_IOR`/`_IOW`
  direction is named from **userspace's** view: `TIOCGPTN` is `_IOR` because the
  user *reads back* the number; `TIOCSPTLCK` is `_IOW` because the user *writes*
  the lock flag — but the kernel READS the int from `*argp` (write int 0 to
  unlock). Both take a `*int` argument, so both are 4-byte cell crossings on the
  E99 surface.

## 3. Conventional (other-language) approach

C, via libc — the whole dance is four opaque calls that hide the ioctls:

```c
int m = posix_openpt(O_RDWR | O_NOCTTY); // = open("/dev/ptmx", ...)
grantpt(m);                              // (historical; no-op on modern devpts)
unlockpt(m);                             // ioctl(m, TIOCSPTLCK, &(int){0})
char *slave = ptsname(m);                // ioctl(m, TIOCGPTN, &n) -> "/dev/pts/N"
int s = open(slave, O_RDWR | O_NOCTTY);
```

- **Assumptions it bakes in:** untyped effects (every call is an ambient syscall,
  nothing in the type says so); `ptsname` returns a pointer into a **static
  buffer** — partiality + hidden shared mutation; error signalling by `-1`/`NULL`
  sentinels the caller may ignore; the two fds are plain `int`s with no linearity,
  so leaking or double-closing either end is a silent bug.

## 4. The chirality idea

- **Chirality features in play:** the effect membrane (`=>` crossings carry their
  capability), the E99 alloc-inside / value-in ioctl idiom, boundary sums for
  every result (errno-or-value), and QTT linearity on the returned fds.
- **The reframing:** each ioctl becomes a small `=>` crossing that owns a 4-byte
  cell in the chirality arena — no static libc buffer, no ambient allocation. The
  result is a **closed sum**, mirroring E99's `WinsizeR`/`TermiosR`/`RawR`:
  `nb-ptsno` returns the pts number or an errno; `nb-ptunlock` returns unit or an
  errno. The master and slave fds are returned as **linear** port values
  (`(1 Fd)`), so the checker forces exactly-once close on each end — the C
  double-close/leak bug becomes untypeable.
- **What chirality makes impossible here:** ignoring the `-1` from an ioctl (the
  caller must `case` the sum); treating the pts number as a raw int that silently
  aliases a shared buffer (it is a fresh field in the result sum); and holding a
  pty fd without accounting for it (linear possession). Building the `/dev/pts/N`
  path is a pure `Str` concat over the *value* N — no crossing, so path
  construction stays off the effect membrane.

## 5. Chirality example (fleshed)

Real surface syntax, copy-and-modify ready. Mirrors E99's **per-request** ioctl
wrappers (`nb-sys-winsz-t` alloc-inside, `nb-sys-tcsets-t` value-in — the request
number is baked IN the wrapper, never passed as data; there is **no** generic
`nb-sys-ioctl` in the tree). Two build-state facts settle the plumbing (verified
against lib, see §6): the ioctls are per-request crossings, and the existing
`openat` crossing is **hardcoded `O_RDONLY`** — so opening the pty `O_RDWR` needs
a NEW `open-rw` crossing E104 adds.

```chirality
(import "prelude")
(import "term")        ; E99 per-request ioctl idiom (tiocgwinsz/tcsetattr shape)
(import "bytes-tal")   ; bget-u32-le / bput-u32-le / cell-new

; --- result sums: errno-or-value, never a -1 sentinel (boundary-sum directive) ---
(data PtnR ()    (ptn-ok (n I64))                 (ptn-err (errno I64)))
(data UnlockR () (unlock-ok)                       (unlock-err (errno I64)))
(data PtyR ()    (pty-ok (master I64) (slave I64) (n I64)) (pty-err (errno I64)))

; --- per-request ioctl crossings (request # baked in the TAL wrapper) ---------
; nb-sys-ptsno-t  : alloc-inside, ti-const 0x80045430 (TIOCGPTN), ti-bnew 4-byte
;   out-cell, ioctl(fd,req,ptr), fresh cell on success / empty on err — a mirror
;   of nb-sys-winsz-t (sys-tal.chiral). Surface extern + crossing-wrap:
(extern nb-ptsno-raw (=> I64 Bytes))        ; fd -> 4B cell (pts# u32) | empty
; nb-ptunlock : value-in, ti-const 0x40045431 (TIOCSPTLCK), kernel reads int 0 —
;   a mirror of nb-sys-tcsets-t. Caller passes an in-cell holding 0:
(extern nb-ptunlock  (=> I64 Bytes I64))    ; fd, in-cell(int 0) -> 0 | -errno

; surface wrappers cased into the sums (mirror term.chiral tiocgwinsz / tcsetattr):
(def nb-ptsno (=> I64 PtnR)
  (lam (fd)
    (let (cell (nb-ptsno-raw fd))
      (case (=i (blen cell) 0)
        (false (ptn-ok (bget-u32-le cell 0)))   ; pts# at offset 0
        (true  (ptn-err -1))))))

(def nb-ptunlock-w (=> I64 UnlockR)
  (lam (fd)
    (let (rc (nb-ptunlock fd (bput-u32-le (cell-new 4) 0 0)))   ; int 0 = unlock
      (case (<i rc 0) (true (unlock-err (- 0 rc))) (false (unlock-ok))))))

; --- pure path build: "/dev/pts/" ++ decimal(N) — no crossing --------------------
(def pts-path (-> I64 Str)
  (lam (n) (str-cat "/dev/pts/" (i64->str n))))      ; i64->str exists (closconv.chiral)

; --- open-rw: the NEW crossing E104 adds (existing `openat` is O_RDONLY-only) ---
; openat(AT_FDCWD, path, O_RDWR|O_NOCTTY=0x102, 0) -> fd | -errno. Extends the
; nb-sys-openat-t shape with a flags arg (or a sibling wrapper). Returns raw I64.
(extern open-rw (=> Bytes I64))             ; NUL-terminated path -> fd | -errno

; --- the four-step dance, cased at every step (fds raw I64, matching openat/read)
(def open-pty (=> Unit PtyR)
  (lam (_)
    (let (m (open-rw (str->bytes "/dev/ptmx")))
      (case (<i m 0) (true (pty-err (- 0 m)))
        (false
          (case (nb-ptunlock-w m)                    ; step 2: unlock slave
            ((unlock-err e) (pty-err e))             ; (real impl closes m on err — §6 Q2)
            ((unlock-ok)
              (case (nb-ptsno m)                     ; step 3: read pts index
                ((ptn-err e) (pty-err e))
                ((ptn-ok n)
                  (let (s (open-rw (str->bytes (pts-path n))))   ; step 4
                    (case (<i s 0) (true (pty-err (- 0 s)))
                      (false (pty-ok m s n)))))))))))))
```

- **Knobs to modify:** the open flags (add `O_NONBLOCK` for a nonblocking
  master); whether `O_NOCTTY` is dropped when the caller *wants* a controlling
  terminal; the arena cell size (fixed 4 here — both ioctls take a `*int`); and
  the error policy on the master fd (the skeleton returns `pty-err` before closing
  `m` on the unlock/ptsno/slave-open failure paths — a real impl threads a close).
- **Deliberately omitted:** `grantpt` (a devpts no-op on modern Linux — skipped
  deliberately, not forgotten); `i64->str`/`bget-u32-le`/`bput-u32-le`/`cell-new`
  bodies (all exist in lib); the TAL bodies of the three new crossings
  (`nb-sys-ptsno-t` alloc-inside + `nb-sys-ptunlock-t` value-in, each a direct
  mirror of E99's `nb-sys-winsz-t`/`nb-sys-tcsets-t`; and `open-rw`, the openat
  wrapper extended with a flags arg) — sketched in §6, written at implement time.

## 6. Use / modify notes

- **Lands in:** the sums + `nb-ptsno`/`nb-ptunlock`/`open-pty` in
  `scaffold/lib/term.chiral` (alongside the E99 `WinsizeR`/`TermiosR` crossings).
  **BUT** unlike E103 (lib-only), the two NEW ioctl request numbers and the pty
  crossings touch the **compiled crossing tables** — `sys-tal.chiral` (sys-lib
  sigs), `crossing-wraps.chiral`, `ports.chiral`, and `target-linux.chiral`'s
  `SysReg` — so implementing E104 **FORCES A B1 FIXPOINT** (build-new → test →
  promote → self-reproduce byte-compare). The example itself is lib-shaped but
  the element is not.
- **Conformance target:** on a Linux box with a devpts mount, `open-pty` returns
  `pty-ok` with two valid fds and the same N that `/dev/pts/N` names; writing to
  the master appears readable on the slave and vice-versa (this is exactly what
  E103's behavioral test drives). Values must match the §2 table byte-for-byte —
  a wrong ioctl number silently reads garbage or `EINVAL`.
- **Open questions:** (1) **RESOLVED** (audit, verified vs sys-tal.chiral): there is
  NO generic `nb-sys-ioctl`; E99 uses per-request TAL wrappers, so E104 mints
  `nb-sys-ptsno-t` (alloc-inside) + `nb-sys-ptunlock-t` (value-in). (2) **openat is
  O_RDONLY-hardcoded** (`nb-sys-openat-t`), so E104 MUST add an `open-rw` crossing
  (openat + a flags arg / O_RDWR|O_NOCTTY) — a real sub-deliverable, in scope.
  (3) **RESOLVED**: `i64->str` exists (closconv.chiral) — no new render helper.
  (4) **Genuine, for the SPEC** — fd cleanup on error paths: keep fds as raw `I64`
  (matching `openat`/`read`/`exit`), or wrap them in a linear `Fd` porttype so the
  checker forces exactly-once close (the "double-close untypeable" win, but a new
  porttype + close crossing). SPEC decides; the skeleton uses raw I64.
- **Related:** [[E99-ioctl-crossings]] (the idiom this mirrors), [[E103]] (the pty
  behavioral test that rides this), [[syscall-map]], [[pattern-boundary-sums]].
