---
element: E110
slug: cloexec-pty
title: Close-on-exec fd hygiene on the pty path: open the pty master `O_CLOEXEC` (or explicitly close it in the child branch of `spawn-in-pty` before `exec`) so the child does not inherit the master fd across `exec`
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-11
---

# E110 — Close-on-exec fd hygiene on the pty path: open the pty master `O_CLOEXEC` (or explicitly close it in the child branch of `spawn-in-pty` before `exec`) so the child does not inherit the master fd across `exec`

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E110, close the master-fd leak on chirality's own pty path — the child
  shell must not inherit the pty **master** fd across `exec`.
- **Kind:** BUILD-PROPER (an fd-hygiene invariant not yet built on the E104 pty path).
- **Why chirality needs its own:** chirality acquires its own pty pair natively
  (`open-pty`, `term.chiral:183-198`) and spawns a child shell into the slave
  (`nb-spawn-in-pty`, `sys-tal.chiral:650`). The master fd is the terminal's
  control side — whoever holds it can read everything the tty shows and inject
  input. Opened without close-on-exec, the master is inherited by the `exec`'d
  child, so the child can read/write the master side of its own controlling
  terminal: a real fd-leak and isolation hole. The mechanism to fix it
  (`MFD_CLOEXEC`) already exists in the tree for `memfd` (`sys-tal.chiral:74`) —
  it is simply not applied on the pty path.

## 2. Research

- **Reference class:** OURS — the chirality pty path (`term.chiral`, `sys-tal.chiral`)
  plus the C `open(2)`/`dup2(2)` ABI (kernel `asm-generic/fcntl.h`, man7).
- **Key findings (web-verified, do not assert from memory):**
  - **`O_CLOEXEC = 02000000` octal = `524288` = `(1 << 19)`** on Linux
    (`include/uapi/asm-generic/fcntl.h`). It sets `FD_CLOEXEC` on the fd
    **atomically at open time** — no race window between `open` and a follow-up
    `fcntl(F_SETFD)` (torvalds/linux `asm-generic/fcntl.h`; man7 `open(2)`).
  - **Post-open alternative:** `fcntl(fd, F_SETFD, FD_CLOEXEC)`. Correct but a
    two-syscall, non-atomic window exists (man7 `fcntl(2)`).
  - **`dup2` CLEARS close-on-exec on the new fd** — the duplicate does **not**
    inherit `FD_CLOEXEC`; "the two descriptors do not share file descriptor
    flags" (man7 `dup(2)`, die.net `dup2(2)`). This is the load-bearing subtlety:
    even if the **slave** were opened `O_CLOEXEC`, the child's `dup2 slave -> 0/1/2`
    produces fds 0/1/2 **without** cloexec, so they survive `exec` (exactly what
    we want), while the raw slave fd (>=3) is explicitly closed before `exec`
    anyway (`login-tty`, `term.chiral:246-248`). So `O_CLOEXEC` can be applied to
    **both** opens: it closes the master leak and is harmless on the slave.
  - **Current flags:** the pty opens use `O_RDWR|O_NOCTTY = 0x102 = 258`
    (`nb-sys-open-rw-t`, `sys-tal.chiral:630`). Adding cloexec →
    `O_RDWR|O_NOCTTY|O_CLOEXEC = 0x102 | 0x80000 = 0x80102 = 524546`.

  Sources: [asm-generic/fcntl.h (torvalds/linux)](https://github.com/torvalds/linux/blob/master/include/uapi/asm-generic/fcntl.h),
  [open(2) man7](https://man7.org/linux/man-pages/man2/open.2.html),
  [dup(2) man7](https://man7.org/linux/man-pages/man2/dup.2.html),
  [dup2(2) die.net](https://linux.die.net/man/2/dup2).

## 3. Conventional (other-language) approach

Outside chirality this is a well-known pty-hygiene rule. In C/Python you either pass
the cloexec flag at open, or set it after the fact, or manually close the master
in the child between `fork` and `exec`:

```c
/* (a) atomic — set close-on-exec in the open flags (preferred) */
int master = open("/dev/ptmx", O_RDWR | O_NOCTTY | O_CLOEXEC);

/* (a') post-open, non-atomic alternative */
int master = open("/dev/ptmx", O_RDWR | O_NOCTTY);
fcntl(master, F_SETFD, FD_CLOEXEC);

/* (b) manual — close the master by hand in the child before exec */
pid_t pid = fork();
if (pid == 0) {              /* child */
    close(master);           /* a window exists: master is open until this line */
    login_tty(slave);
    execve(shell, argv, envp);
}
```

- **Assumptions it bakes in:** ambient fd inheritance across `exec` is the
  *default* — every open fd leaks into the child unless the programmer remembers
  to opt out. Option (a) is atomic; (a') and (b) both leave a window where the
  fd is inheritable, and (b) additionally depends on the programmer threading the
  master fd number into the child branch and never forgetting the `close`.

## 4. The chirality idea

chirality has the exact same syscall surface and the exact same choice, but the
mechanism is already precedented and the boundary-sum discipline says the intent
should live where it can be read.

- **Chirality features in play:** category-B raw-syscall crossings at the TAL floor
  (`sys-tal.chiral` `TIFn` drivers); the `MFD_CLOEXEC` precedent (`memfd` already
  threads cloexec as a flag bit, `sys-tal.chiral:74`); the errno-or-value result
  sums already guarding every pty crossing (`PtyR`/`SpawnR`, `term.chiral`).
- **The reframing — two options, both real, decide in the spec:**
  - **(a) `O_CLOEXEC` in the open flags — atomic, no window.** The catch: E104's
    `open-rw` extern takes **only** `Bytes` (the path) — there is **no flags
    argument** to OR into. The flags `O_RDWR|O_NOCTTY = 258` are hardcoded as
    `(ti-const 3 258)` inside `nb-sys-open-rw-t` (`sys-tal.chiral:630`). So (a)
    splits into:
    - **(a1)** OR the bit into the existing hardcoded const: `258 -> 524546`. One
      const flip at the TAL floor. Every open through this crossing gets cloexec.
      Since `open-rw` is used **only** for pty opens (master `/dev/ptmx` + slave
      `/dev/pts/n`), and cloexec is correct on both (dup2 clears it off 0/1/2, raw
      slave is closed), this is safe and complete. Mirrors `memfd` exactly.
    - **(a2)** mint a flags-taking open crossing (as E104 minted `open-rw`
      *because* `openat` was hardcoded `O_RDONLY`), so the flag is an explicit
      value at each call site. More surface; earns its keep only if some future
      caller wants an fd deliberately *without* cloexec.
  - **(b) explicitly close the master in the child before `exec`.** Works, but
    the master fd is opened in the **parent** (`open-pty`) and the child lives in
    the fat `nb-spawn-in-pty` driver whose extern signature is `(elf, slave-path)`
    — it does **not** receive the master fd. Option (b) therefore requires
    threading the master fd through the spawn crossing so the child branch can
    `close` it, and a window still exists between `fork` and that `close`.
- **What chirality makes impossible here:** nothing structurally today — this IS the
  gap. The fix pushes the invariant into the crossing (a1) rather than relying on
  a remembered manual `close` (b), which is the substrate-over-bolted-on move.

## 5. Chirality example (fleshed)

The concrete change. Primary option (a1): a one-const flip at the TAL floor that
gives every pty open close-on-exec atomically. The surface `open-pty` and
`login-tty` are **unchanged** — they simply inherit the hygiene.

```chirality
; ── sys-tal.chiral — nb-sys-open-rw-t (E110: + O_CLOEXEC) ──
; openat(AT_FDCWD=-100, path, O_RDWR|O_NOCTTY|O_CLOEXEC, 0) -> fd.
;   O_RDWR   0x2        read-write (pty master + slave both need it)
;   O_NOCTTY 0x100      the open must NOT itself grab a controlling terminal
;   O_CLOEXEC 0x80000   set FD_CLOEXEC atomically: the fd is auto-closed on exec
; 0x2 | 0x100 | 0x80000 = 0x80102 = 524546   (was 258 = 0x102, no cloexec)
; Mirrors nb-sys-memfd-t threading MFD_CLOEXEC (sys-tal.chiral:74).
(def nb-sys-open-rw-t TIFn
  (ti-fn "nb-sys-open-rw" 1 6
    (t-seq (ti-bptr 1 0)
    (t-seq (ti-const 2 -100)
    (t-seq (ti-const 3 524546)                     ; O_RDWR|O_NOCTTY|O_CLOEXEC  (was 258)
    (t-seq (ti-const 4 0)
    (t-seq (ti-sys 5 257 (cons 2 (cons 1 (cons 3 (cons 4 nil)))))
      (ti-ret 5))))))))

; ── term.chiral — open-pty is UNCHANGED; it now returns a cloexec master ──
; (shown for context only — DO NOT edit; the const flip above is the whole fix)
(def open-pty (=> Unit PtyR)
  (lam (u)
    (let (master (open-rw (bcat (str->bytes "/dev/ptmx") nul-byte)))  ; now O_CLOEXEC
      ; … unlock → ptsno → open slave (also cloexec, harmless) → pty-ok …
      )))

; Why the SLAVE staying cloexec is harmless (the dup2 subtlety, verified):
;   child: dup2 slave -> 0    ; dup2 CLEARS cloexec on the new fd -> 0 survives exec
;          dup2 slave -> 1    ;   "                                   1 survives exec
;          dup2 slave -> 2    ;   "                                   2 survives exec
;          close slave        ; the raw (cloexec) slave fd >=3 is closed anyway
;          exec-elf           ; master (cloexec) auto-closed here -> LEAK CLOSED
```

Alternative option (b) — manual close, sketched (NOT recommended; needs the
master fd threaded through `spawn-in-pty` and leaves a fork→close window):

```chirality
; Would require: spawn-in-pty extern grows a master-fd arg, and its CHILD branch
; issues (close master) after fork, before setsid/exec. login-tty already closes
; the slave; this adds the symmetric master close — but manually, with a window.
;   (t-seq (ti-call _ "nb-sys-close" (cons master-reg nil))   ; close master in child
;      … setsid → open slave → TIOCSCTTY → dup2 → exec …)
```

- **Knobs to modify:** the flag const (`524546`) if a moduleset ever needs a
  different profile; whether to keep (a1) shared-const or promote to (a2) a
  flags-taking crossing.
- **Deliberately omitted:** the `fcntl(F_SETFD)` post-open path (option a'') — it
  is strictly worse than `O_CLOEXEC` (non-atomic) and adds a syscall; only worth
  it if an fd must be opened first and made cloexec later, which the pty path
  never needs.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/sys-tal.chiral` (`nb-sys-open-rw-t`, the const flip)
  for option (a1). If (a2) is chosen instead: a new `TIFn` crossing +
  `ports.chiral` extern + `native.py`/`tal.py` prim rows (the E104 pattern).
  `scaffold/lib/term.chiral` needs **no** edit under (a1).
- **Conformance target:** after `spawn-pty-child`, the child process must not
  hold the master fd — verifiable by having the child attempt to read/write the
  master fd number and confirming `EBADF`, or by inspecting the child's
  `/proc/<pid>/fd` and confirming the master is absent while 0/1/2 point at the
  pts. The parent's master read of child output must still work (dup2'd 0/1/2
  survive exec).
- **Recommendation (§6 decision lean):** **option (a1) — OR `O_CLOEXEC` into the
  shared `nb-sys-open-rw` flag const (258 → 524546).** Reasoning: (1) it is
  **atomic** — no fork→exec race window, unlike (b) and the `fcntl` variant;
  (2) it needs **zero new plumbing** — the master fd never has to be threaded
  into the child crossing, whereas (b) forces a signature change on
  `spawn-in-pty`; (3) it exactly mirrors the in-tree `MFD_CLOEXEC` precedent
  (`sys-tal.chiral:74`), so the mechanism is proven; (4) it is **complete and
  harmless across both opens** because `dup2` clears cloexec off 0/1/2
  (web-verified) and the raw slave is closed pre-exec. Promote to (a2) only if a
  future non-pty caller of this crossing needs an inheritable fd — not the case
  today (`open-rw` serves only the pty path).
- **Open questions for the spec:** (1) a1 vs a2 (shared const vs flags-taking
  crossing) — lean a1; (2) whether the const should be a named `def`
  (`O_RDWR_NOCTTY_CLOEXEC I64 524546`) for readability rather than a bare
  `ti-const`; (3) whether E110 should also audit the E104 slave-open and the
  parent-held slave fd for the same hygiene (they route through the same crossing,
  so a1 covers them automatically).
- **Related:** [[E104-pty-acquire]] (added `open-rw`, the flags-less open this
  builds on), [[tal-spec]] (`nb-sys-memfd-t` MFD_CLOEXEC precedent), [[term]].
