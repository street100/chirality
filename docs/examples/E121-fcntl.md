---
element: E121
slug: fcntl
title: `fcntl`/`F_GETFD` crossing: expose `fcntl` (F_GETFD / F_SETFD) as a TAL crossing so a fd's close-on-exec state is readable at runtime — the conclusive gate for E110's O_CLOEXEC (assert `fcntl(master, F_GETFD) & FD_CLOEXEC`) and general fd-flag hygiene
kind: BUILD-PROPER
reference_class: OURS/SPEC
ours_source: (none)
status: drafted
updated: 2026-08-12
---

# E121 — `fcntl`/`F_GETFD` crossing

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E121, expose `fcntl(fd, cmd, arg)` (at least `F_GETFD` / `F_SETFD`)
  as a value-in TAL syscall crossing so a fd's close-on-exec state is readable at
  runtime.
- **Kind:** BUILD-PROPER (design from the ABI spec — no OURS Python to port).
- **Why chirality needs its own:** `fcntl` is the conclusive gate for E110's
  O_CLOEXEC. E110 opens the pty master with O_CLOEXEC but has no way to *prove*
  the flag stuck — it ships a static+regression check pending this crossing.
  With `fcntl(master, F_GETFD)` readable, the pty lib can assert
  `flags & FD_CLOEXEC != 0` after `open-pty` and turn a documented expectation
  into a runtime-checked invariant. Also general fd-flag hygiene.

## 2. Research

- **Reference class:** SPEC — Linux `fcntl(2)` ABI (man7 `fcntl(2)` /
  `F_GETFD.2const`, glibc `bits/fcntl-linux.h`, `asm/unistd_64.h`). No OURS
  baseline; the crossing bodies are mirrored from existing chirality crossings in
  `lib/lowering/tal/sys.chiral`.
- **Key ABI facts (web-verified — do NOT assert from memory, this is the
  wrong-constant failure class):**
  - **`fcntl` syscall number on x86-64 = `72`** (`__NR_fcntl`, `asm/unistd_64.h`).
    Source: filippo.io/linux-syscall-table, blog.rchapman.org x86-64 table.
  - **`F_GETFD = 1`, `F_SETFD = 2`** (glibc `bits/fcntl-linux.h`; the canonical
    POSIX/Linux command values — `F_DUPFD 0`, `F_GETFD 1`, `F_SETFD 2`,
    `F_GETFL 3`, `F_SETFL 4`). Source: man7 `fcntl(2)`, GNU libc "Descriptor
    Flags" manual node.
  - **`FD_CLOEXEC = 1`** (bit `0b1`; the only fd-level flag). If bit is 0 the fd
    stays open across `execve(2)`; if set it is closed. Source: man7
    `fcntl(2)`, GNU libc Descriptor Flags.
  - **Return semantics:** `fcntl(fd, F_GETFD)` returns the fd flags *as the
    syscall return value in rax* (`>= 0`), or `-errno` on error — a
    **value-in / value-out-via-rax** crossing with **NO out-cell** (unlike the
    alloc-inside ioctl family `nb-sys-winsz-t`/`nb-sys-tcgets-t` that write a
    caller cell). `fcntl(fd, F_SETFD, arg)` takes the flag word and returns
    `0`/`-errno`. Both are plain-int in, int out.

## 3. Conventional (other-language) approach

How this is done outside chirality — C over raw libc:

```c
#include <fcntl.h>
/* is the master fd close-on-exec? */
int flags = fcntl(master, F_GETFD);       /* -> flag word, or -1/errno */
if (flags == -1) { perror("fcntl"); ... } /* easy to forget */
if (!(flags & FD_CLOEXEC)) abort();       /* leak: fd survives exec */
```

- **Assumptions it bakes in:** `fcntl` is an ambient variadic call reachable
  from anywhere (no capability); the error return `-1` is a sentinel that mixes
  into the flag-word value space and is trivially dropped; `errno` is hidden
  global mutation; `FD_CLOEXEC` is a bare macro the caller must remember — all
  things chirality refuses.

## 4. The chirality idea

- **Chirality features in play:** the effect membrane (`=>` = a crossing performed),
  the sys-face TAL floor (`ti-sys`/`ti-bptr` reachable only from `sys-tal.chiral`,
  so the crossing membrane holds structurally), the SysReg allow-list
  (`target-linux.chiral`), and the crossing-wrap linkage table.
- **The reframing:** `fcntl` is not an ambient function — it is a named crossing
  authored ONCE at the tal floor (`nb-sys-fcntl-t`), registered in the syscall
  allow-list (`SysReg` row → nr 72), linked to a surface extern via
  `crossing-wraps`, and typed `(=> I64 I64 I64 I64)` in `ports.chiral`. Any def
  that calls it carries a nonempty effect row (`=>`); pure code has no surface
  path to it. Because F_GETFD returns the flag word in rax and touches no buffer,
  it mirrors the **value-in** crossings (`nb-sys-close-t`, `nb-sys-tcsets-t`),
  NOT the alloc-inside ioctl Getters — no `ti-bnew`/`ti-bptr`, just `ti-sys` over
  three register args.
- **What chirality makes impossible here:** you cannot reach `fcntl` without being in
  a `=>` context that holds the authority; you cannot silently drop the `-errno`
  (it is an ordinary I64 the caller must case/compare — a `p-err`-style value, not
  a hidden `errno`); and the SysReg allow-list means an fcntl the profile didn't
  authorize simply is not linkable.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
; ── (a) TAL floor: the crossing body — lib/lowering/tal/sys.chiral ──────────
; fcntl(fd, cmd, arg) -> result in rax (flag word for F_GETFD, 0 for F_SETFD;
; -errno on error). Value-in / value-out-via-rax: NO cell, so NO ti-bptr/ti-bnew.
; Mirror of nb-sys-close-t (value-in, ti-ret the rax result); 3 args instead of 1.
; ti-fn "<name>" <arity> <nregs>: 3 args in regs 0,1,2; reg 3 holds the result.
(def nb-sys-fcntl-t TIFn
  (ti-fn "nb-sys-fcntl" 3 4
    (t-seq (ti-sys 3 72 (cons 0 (cons 1 (cons 2 nil))))   ; nr 72 = __NR_fcntl
      (ti-ret 3))))

; ── (b) syscall allow-list: one row — lib/lowering/tal/target-linux.manifest ──────
;   (cons (sys-row "nb-sys-fcntl"       72)     ; E121: fcntl F_GETFD/F_SETFD

; ── (c) crossing → wrapper linkage: one row — lib/lowering/tal/crossing-wraps.chiral
;   (cons (pair "fcntl"      "nb-sys-fcntl")

; ── (d) surface extern: the owned type — lib/ports/ports.chiral ──────────
;   flat E105 write-fd style: one raw crossing, cmd/arg passed as plain I64s.
(extern fcntl (=> I64 I64 I64 I64))   ; fcntl(fd, cmd, arg) -> flags | -errno

; ── (e) typed sugar over the raw crossing (pure surface, in a pty/fd lib) ──
; Named commands as values, not bare macros. These are thin — no new crossing.
(def F_GETFD I64 1)          ; glibc bits/fcntl-linux.h
(def F_SETFD I64 2)
(def FD_CLOEXEC I64 1)

; fd-cloexec?(fd) -> 1 if close-on-exec is set, 0 if clear, -errno on fcntl error.
; and = I64 bitwise-and (cheatsheet: `and`/`or`/`not` are the I64 bit ops).
(declare fd-cloexec? (=> I64 I64))
(def fd-cloexec? (lam (fd)
  (let ((flags (fcntl fd F_GETFD 0)))
    (if (<i flags 0)
        flags                                 ; propagate -errno as a value
        (and flags FD_CLOEXEC)))))            ; 0 or FD_CLOEXEC(1)
```

The **E110 payoff** — the conclusive cloexec assertion E110's SPEC deferred to
this element:

```chirality
; after (open-pty ...) yields the master fd, PROVE O_CLOEXEC actually stuck:
(let ((flags (fcntl master F_GETFD 0)))
  (if (=i (and flags FD_CLOEXEC) 0)
      (halt "open-pty: master fd is NOT close-on-exec")  ; would leak across exec
      master))                                           ; proven: fd closes on exec
```

- **Knobs to modify:** swap `F_GETFD`/`F_SETFD` for the same-shape `F_GETFL`/
  `F_SETFL` (3/4) to read/set O_NONBLOCK etc.; the `arg` operand is `0` for the
  Get commands and the flag word for the Set commands.
- **Deliberately omitted:** the file-lock commands (`F_SETLK`/`F_GETLK`) — those
  take a `struct flock *` and would be an alloc-inside crossing (the winsz Getter
  shape), a separate element. E121 is only the int-in/int-out fd-flag subset.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/sys-tal.chiral` (crossing body `nb-sys-fcntl-t`),
  `scaffold/lib/target-linux.chiral` (one `SysReg` row → nr 72),
  `scaffold/lib/crossing-wraps.chiral` (one `(pair "fcntl" "nb-sys-fcntl")`),
  `scaffold/lib/ports.chiral` (the `fcntl` extern). The typed sugar
  (`F_GETFD`/`FD_CLOEXEC`/`fd-cloexec?`) lands in the pty/fd surface lib that
  E110 already touches. Note: the crossing must also agree with
  `lib/sys-linkage.chiral` `sys-bindings` (crossing-wraps' stated invariant).
- **Conformance target:** on a fd opened with O_CLOEXEC, `fcntl(fd, F_GETFD)`
  returns a value with bit 0 (`FD_CLOEXEC`) set; on a plain fd, clear; on a bad
  fd, a negative errno (EBADF = -9). The E110 assertion above must fire only when
  the flag is genuinely absent.
- **Ground-truth B1 probe (verbatim):**
  - undeclared `(fcntl n 1 0)` → `load: unknown name fcntl` — no surface name
    resolves today (grep-clean confirmed).
  - with the proposed extern `(extern fcntl (=> I64 I64 I64 I64))` declared, the
    program **type-checks** (load passes; the `=>` shape is accepted) but
    lowering fails at the E97 skip-chain gate:
    `extern does not lower: fcntl` — because the SysReg row + crossing-wrap +
    tal body do not exist yet. That missing linkage is exactly the E121 gap; the
    shape itself is validated.
- **Open questions:** single flat `fcntl` extern (recommended, mirrors
  `write-fd`/`mmap`) vs. split typed `fd-getfd`/`fd-setfd` externs — recommend
  the single raw crossing + pure typed sugar (section 5e), so one SysReg/wrap row
  covers every command. Whether to mint a closed `FcntlCmd` sum for the command
  operand (boundary-sums directive) — deferred to the SPEC; F_GETFD/F_SETFD as
  named I64 defs suffices for the E110 gate.
- **Related:** [[E110]] (O_CLOEXEC pty master — the consumer of this gate),
  [[E104]] (pty ioctl crossings — sibling sys-tal bodies), [[E105]] (`write-fd`
  flat-extern precedent).
