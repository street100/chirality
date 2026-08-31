---
element: E103
slug: term-raw
title: Terminal raw-mode fidelity — complete `termios-set-raw` to a `cfmakeraw`-equivalent (clear IXON/ICRNL/OPOST/IEXTEN across all termios flag-words, set VMIN=1/VTIME=0) on top of E99's alloc-inside ioctl crossings, and prove it with a pty behavioral test
kind: BUILD-PROPER
reference_class: OURS/IMPL
ours_source: scaffold/lib/term.chiral (termios-set-raw)
status: drafted
updated: 2026-08-10
---

# E103 — Terminal raw-mode fidelity (`cfmakeraw`-equivalent) + pty behavioral proof, on E99's ioctl crossings

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E103 — bring `termios-set-raw` up to a **full `cfmakeraw`
  fidelity** and **prove it behaviorally under a pty**. Today it clears only
  `c_lflag`'s `ECHO|ICANON|ISIG` (mask `0xFFFFFFF4` @offset 12) — a *partial*
  raw mode that compiles and runs but leaves **IXON on (Ctrl-S freezes the
  editor)**, ICRNL/OPOST/IEXTEN on, and `VMIN`/`VTIME` unset. A real terminal
  editor needs the full multi-field `cfmakeraw` set.
- **Substrate (already shipped, NOT this element):** E99 delivered the *honest
  ioctl surface* — the alloc-inside per-request crossings (`nb-winsz-raw` fd→8B,
  `nb-tcgets-raw` fd→60B, `nb-tcsets` value-in) in `term.chiral`/`ports.chiral`,
  verified correct (TIOCGWINSZ is runtime-proven under a pty). E103 **builds on
  those crossings unchanged** — it only completes the flag arithmetic they feed
  and adds the missing runtime proof.
- **Kind:** BUILD-PROPER. **Reference:** `OURS` (`term.chiral`'s current partial
  `termios-set-raw`) + `IMPL` (C `cfmakeraw(3)`; Rust `nix` `cfmakeraw`).
- **Why chirality needs its own:** two gaps the shipped E99 explicitly deferred
  (its SPEC line 235: "the other ~30 fields… out of scope"). **(a) Fidelity.**
  Raw mode is a *multi-field* mask, not one `c_lflag` clear; partial fidelity is
  invisible until Ctrl-S freezes the terminal. **(b) Evidence.** The raw path is
  only *compile*-tested (`test-scriba-funcs.sh` scores PASS = "emitted an ELF");
  nothing enters raw mode on a real tty and observes un-echoed/unbuffered
  delivery. chirality's payoff is that the fix rides a **pure** `Bytes -> Bytes`
  function — testable *without* a tty — so the fidelity is provable in a small
  behavioral sample plus pure unit checks.

## 2. Research

- **The kernel `struct termios` ABI (x86-64, little-endian u32 flag-words).**
  `c_iflag@0`, `c_oflag@4`, `c_cflag@8`, `c_lflag@12`, `c_line@16` (1 byte),
  then `c_cc[NCCS]@17` with `NCCS=19`; inside `c_cc`, `VTIME = c_cc[5] @ 22`,
  `VMIN = c_cc[6] @ 23`. Kernel struct is 36B; E99's cell over-sizes to **60B**
  (`sizeof` on glibc), which is safe — the kernel writes/reads only its own 36.
- **`cfmakeraw` is a multi-field mask.** The full set:
  `c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL|IXON)`;
  `c_oflag &= ~OPOST`; `c_lflag &= ~(ECHO|ECHONL|ICANON|ISIG|IEXTEN)`;
  `c_cflag &= ~(CSIZE|PARENB)`, `c_cflag |= CS8`; `c_cc[VMIN]=1`, `c_cc[VTIME]=0`.
  Linux constants: `IXON=0x400`, `ICRNL=0x100`, `ISTRIP=0x20`, `INLCR=0x40`,
  `IGNCR=0x80`, `BRKINT=0x2`, `IGNBRK=0x1`, `PARMRK=0x8`; `OPOST=0x1`;
  `ECHO=0x8`, `ECHONL=0x40`, `ICANON=0x2`, `ISIG=0x1`, `IEXTEN=0x8000`;
  `CSIZE=0x30`, `PARENB=0x100`, `CS8=0x30`. (The current partial mode = only the
  `c_lflag` `ECHO|ICANON|ISIG` subset.)
- **The single change site.** E99 already routes get→modify→set through
  `tcgetattr` → `termios-set-raw` → `tcsetattr`. Only `termios-set-raw` (and the
  test) change; the crossings and the request numbers (TCGETS 0x5401, TCSETS
  0x5402) are untouched.
- **`cfmakeraw` is a policy, not a law.** An editor may keep `ISIG` (so Ctrl-C
  still interrupts) — E103 should make the mask a named, softenable knob, not a
  hardcoded literal, so the editor element can choose its profile.

## 3. Conventional (other-language) approach

The full raw-mode a real terminal editor drives (kilo, GNU readline), via C:

```c
struct termios t;
tcgetattr(fd, &t);                 /* ioctl(TCGETS): kernel fills *t */
t.c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL|IXON); /* IXON = Ctrl-S freeze */
t.c_oflag &= ~OPOST;
t.c_lflag &= ~(ECHO|ECHONL|ICANON|ISIG|IEXTEN);
t.c_cflag &= ~(CSIZE|PARENB); t.c_cflag |= CS8;
t.c_cc[VMIN] = 1; t.c_cc[VTIME] = 0;   /* one byte, no timeout */
tcsetattr(fd, TCSANOW, &t);        /* ioctl(TCSETS): kernel reads *t */
```

- **Assumptions it bakes in:**
  - **Bit-twiddling with no field/offset proof** — offsets and masks are raw
    integer literals; nothing checks `VMIN` is byte 23 or the cell is big enough.
  - **Partial fidelity is invisible** — clearing only `c_lflag` still *compiles
    and runs*; you discover IXON is live only when Ctrl-S freezes the editor.
  - **The mode is only observable through a live tty** — C proves it by hand at a
    real terminal, never in a repeatable test.

## 4. The chirality idea

- **Chirality features in play:** the pure fragment (the flag math is a total
  `Bytes -> Bytes`, no tty, no effect); the effect membrane (only the two
  E99 crossings `tcgetattr`/`tcsetattr` are `=>` process); boundary sums
  (`TermiosR`/`WinsizeR` errno-or-value, already in `term.chiral`); the immutable
  `Bytes` contract (E99's alloc-inside cell keeps the kernel write sound).
- **The reframing.** Raw-mode *policy* becomes a **pure value transform** sitting
  between the two crossings: `termios-set-raw : Bytes -> Bytes` reads each
  flag-word at its offset, applies the `cfmakeraw` masks, writes `VMIN=1`/
  `VTIME=0`, and returns a **new** cell. Because it is pure and total, the
  correctness of the *mask math* is a unit test with no tty at all; the tty only
  enters for the end-to-end **behavioral** proof.
- **What chirality makes better here:**
  - **Fidelity is a checkable value, not folklore.** The masks live in one named
    pure function; a unit test asserts the exact output bytes for a known input.
  - **The mode is provable without a live terminal** for the mask half, and
    provable *with* a pty for the delivery half — the two gates E99 left open.
  - **Softening is a one-line policy edit** (keep `ISIG`), not a scattered change.

## 5. Chirality example (fleshed)

```chirality
(import "prelude")
(import "term")        ; E99 substrate: tcgetattr / tcsetattr / TermiosR (unchanged)
(import "bytes-tal")   ; bget-u32-le / bput-u32-le / bput-u8

; --- the E103 deliverable: cfmakeraw as PURE flag arithmetic ------------------
; c_iflag@0  c_oflag@4  c_cflag@8  c_lflag@12 ; VTIME=c_cc[5]@22  VMIN=c_cc[6]@23
; Each mask is a NAMED, softenable knob (see §2), not an inline literal.
(def RAW_IFLAG_CLR I64 1515)     ; 0x05eb = IXON|ICRNL|INLCR|IGNCR|ISTRIP|BRKINT|IGNBRK|PARMRK
(def RAW_OFLAG_CLR I64 1)        ; 0x0001 = OPOST
(def RAW_CFLAG_CLR I64 304)      ; 0x0130 = CSIZE|PARENB
(def RAW_CFLAG_SET I64 48)       ; 0x0030 = CS8
(def RAW_LFLAG_CLR I64 32843)    ; 0x804b = IEXTEN|ECHONL|ECHO|ICANON|ISIG

; band with the bitwise-NOT of the clear-mask; bput-u32-le returns a FRESH cell
; (b0 is never mutated in place — the pure-fragment contract holds).
(def clr-u32 (-> Bytes I64 I64 Bytes)
  (lam (b off mask)
    (bput-u32-le b off (band (bget-u32-le b off) (bnot32 mask)))))

(def termios-set-raw (-> Bytes Bytes)      ; pure: no tty needed to test the masks
  (lam (b0)
    (let (b1 (clr-u32 b0  0 RAW_IFLAG_CLR))
      (let (b2 (clr-u32 b1  4 RAW_OFLAG_CLR))
        (let (b3 (clr-u32 b2  8 RAW_CFLAG_CLR))
          (let (b4 (bput-u32-le b3 8 (bor (bget-u32-le b3 8) RAW_CFLAG_SET)))  ; |CS8
            (let (b5 (clr-u32 b4 12 RAW_LFLAG_CLR))
              (bput-u8 (bput-u8 b5 23 1) 22 0))))))))    ; VMIN=1  VTIME=0

; --- driver: unchanged E99 crossings, new raw policy between them -------------
(def term-raw (=> I64 RawR)                ; fd -> enter raw, return saved cooked attrs
  (lam (fd)
    (case (tcgetattr fd)                   ; E99 crossing (alloc-inside, unchanged)
      ((tios-err e) (raw-err e))
      ((tios-ok attrs)
        (let (saved (bslice attrs 0 60))   ; copy cooked attrs before modifying
          (let (_ (tcsetattr fd (termios-set-raw attrs)))   ; E99 crossing + E103 policy
            (raw-r saved)))))))
```

- **Knobs to modify:**
  - The five `RAW_*` masks. A *softer* raw mode (leave Ctrl-C working) drops
    `ISIG=0x1` from `RAW_LFLAG_CLR` — one constant, nothing else.
  - `VMIN`/`VTIME` (bytes 23/22): set `VMIN=0`,`VTIME=n` for a read *timeout*
    instead of blocking-one-byte.
- **Deliberately omitted:**
  - `bget-u32-le`/`bput-u32-le` bodies (mechanical LE splices, already in
    `bytes-tal.chiral`). (`bnot32` and `bput-u8` are **not** built yet — see §6.)
  - The E99 crossings themselves (`tcgetattr`/`tcsetattr`) — shipped, unchanged.
  - The raw-byte read/write loop that *uses* raw mode (a separate element).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/term.chiral` — the `termios-set-raw` body (the only
  logic change) plus the `RAW_*` mask defs. No crossing, `ports.chiral`, or `bin/`
  change. Plus a new behavioral test (below).
- **Conformance gate (THE E103 gate — a pty behavioral test):** open a pty pair,
  `term-raw` on the slave fd, then from the master:
  1. write a bare keystroke (no newline) → assert it **arrives un-echoed and
     unbuffered** on the slave read (proves ECHO+ICANON off, VMIN=1);
  2. write Ctrl-S (`0x13`) then a byte → assert output does **not** freeze
     (proves IXON cleared — the bug the partial mode has);
  3. `term-restore` the saved cooked `Termios` → assert canonical/echo behavior
     returns.
  Plus a **pure unit test** on `termios-set-raw`: feed a known 60-byte cooked
  cell, assert the exact four flag-words + `c_cc[22/23]` after. (The pure half
  needs no tty — the chirality payoff.) This is the `cfmakeraw` fidelity proof the
  current `ECHO|ICANON|ISIG`-only mode cannot pass. Retire the stale
  `(ioctl 0 21505 (cell-new 512))` case in `bin/test-scriba-funcs.sh` (pre-E99
  surface) as part of this.
- **Baseline gate (per `docs/testing-floors.md` floor architecture):** the **native
  floor** stays green and the new **pty behavioral test** passes — those GATE.
  The python suite is ADVISORY (not a gate) during the oracle retirement.
  `grep cell-new term.chiral` stays empty (the E99 invariant). No fixpoint check
  needed — `term.chiral` is lib, not compiler source; just B1-compile + run the
  pty test.
- **Open questions:**
  - Whether `termios-set-raw` is `cfmakeraw`-exact or a chirality-editor profile
    (keep `ISIG` for Ctrl-C) — a policy call for the editor element; E103 ships
    exact + the softenable knob.
  - `bnot32` (32-bit bitwise NOT) and `bput-u8` do **not** exist in
    `bytes-tal`/prelude (confirmed by grep). Two adds the SPEC must schedule:
    `bput-u8` (needed — a u32 write at `c_cc` would clobber the VKILL/VEOF
    neighbors of VMIN/VTIME), and EITHER `bnot32` OR — cleaner, and the idiom the
    current mode already uses — precompute each `RAW_*_CLR` as its complement
    AND-mask (like `0xFFFFFFF4`) so `clr-u32` needs no `bnot32` at all.
- **Related:** [[E99-ioctl-out-cells]] (the alloc-inside crossings this builds
  on), [[E98]] (`nb-read-key` — the raw read this raw-mode enables),
  [[E26]] (alarms/errors-as-values feeding `TermiosR`/`RawR`).
