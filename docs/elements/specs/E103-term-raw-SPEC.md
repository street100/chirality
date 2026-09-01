---
element: E103
slug: term-raw
title: Terminal raw-mode fidelity (E99 follow-on) — complete `termios-set-raw` to a `cfmakeraw`-equivalent + prove it under a pty
kind: BUILD-PROPER
example: examples/E103-term-raw.md
status: audited
updated: 2026-08-10
---

# E103 SPEC — Terminal raw-mode fidelity (`cfmakeraw`-equivalent) + pty behavioral proof

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `termios-set-raw` (scaffold/lib/term.chiral) is a full
  `cfmakeraw`-equivalent pure `Bytes -> Bytes` transform — it clears the
  `c_iflag`/`c_oflag`/`c_cflag` raw bits and sets `CS8`, extends the `c_lflag`
  clear to `IEXTEN|ECHONL`, and writes `VMIN=1`/`VTIME=0` — replacing today's
  `c_lflag`-only `ECHO|ICANON|ISIG` partial mode. The fidelity is proven by a
  **pure native unit sample** (exact output bytes for a known input, no tty) and
  a **pty behavioral test** (keystroke un-echoed/unbuffered, Ctrl-S no-freeze,
  restore) — the first pty test in the suite and the two runtime gates E99 left
  open.
- **Non-goals:** no change to the E99 crossings (`tcgetattr`/`tcsetattr`/
  `nb-tcgets-raw`/`nb-tcsets`), `ports.chiral`, request numbers, or any compiler
  source; no new chirality syscall crossing (so no fixpoint check); no raw
  read/write *loop* that consumes raw mode (that is [[E98]] `nb-read-key`); no
  native pty *crossings* — those are the prerequisite element **E104** (the
  author's 2026-08-10 choice); E103 *rides* E104's crossings for its Step-4
  behavioral test but does not build them. Chirality acquires the pty (via E104),
  not a C harness.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E103 postdates the map snapshot; treat as
  **BUILD**. The catalog row records the current state: `termios-set-raw` clears
  only `c_lflag` `ECHO|ICANON|ISIG` (mask `0xFFFFFFF4` @12); IXON/VMIN/VTIME
  untouched; the raw path is compile-tested only (`bin/test-scriba-funcs.sh`),
  never runtime-verified (only TIOCGWINSZ is pty-proven). E99 SPEC line 235
  explicitly deferred the other ~30 fields.
- **Live code this composes with (built, do NOT respec):**
  - `term.chiral` — `tcgetattr` (=> alloc-inside via `nb-tcgets-raw`, returns a
    fresh 60B `TermiosR` cell), `tcsetattr` (value-in via `nb-tcsets`), `term-raw`
    (get→`termios-set-raw`→set, saves cooked via `bslice attrs 0 60`),
    `term-restore`, `TermiosR`/`RawR` boundary sums, `TERMIOS_LEN=60`,
    `TERMIOS_C_LFLAG_OFF=12`. **All unchanged by E103** except `termios-set-raw`
    and the mask defs.
  - `bytes-tal.chiral` — `bget-u32-le` (`unpack-u32`, line 535), `bput-u32-le`
    (fresh-cell LE splice, line 538); `band`/`bor` bitwise ops. **`bput-u8` and
    `bnot32` are absent** (grep-confirmed).
  - E99 crossings in `ports.chiral` (lines 142–144): `nb-winsz-raw`,
    `nb-tcgets-raw`, `nb-tcsets`. `read` (line 84, `read(fd,count)->Bytes`),
    `exit` (line 122) — the only crossings the pty slave program needs.
- **True delta:** (a) rewrite the `termios-set-raw` body from a single
  `c_lflag` band to the five-field `cfmakeraw` transform + `VMIN`/`VTIME`;
  (b) five named `RAW_*` mask defs replacing `termios-raw-mask`; (c) add
  `bput-u8` to `bytes-tal.chiral`; (d) a pure native unit sample; (e) a pty
  behavioral test riding **E104**'s native pty crossings (Step 4, gated on E104);
  (f) retire one stale compile-smoke case.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | `termios-set-raw` `cfmakeraw`-exact (clear ISIG → no Ctrl-C signal) vs keep ISIG (hung scriba stays Ctrl-C-killable)? | **RESOLVED** (E103 default = cfmakeraw-exact, ISIG cleared) + the *editor's* profile choice **DEFERRED** to the editor element ([[E98]]/scriba) | The catalog row mandates "mask constants as softenable knobs" and the example (§4, §6) ships cfmakeraw-exact + a softenable knob. cfmakeraw is the reference standard; making each `RAW_*` a named `def` means the softer profile (Ctrl-C alive) is a one-constant edit — drop `ISIG=0x1` from the `c_lflag` clear. No one-way door: the editor element picks its profile later by overriding the knob. Not a settled *doc*, but derivable from the catalog row's explicit "softenable knobs" contract — recorded here, not silently chosen. |
| 2 | Add `bnot32` (32-bit NOT) so `clr-u32` bands with `~mask`, OR precompute each `RAW_*_CLR` as its complement AND-mask? | **RESOLVED** — complement AND-mask; **no `bnot32`** | It is the exact idiom the current code already uses (`termios-raw-mask = 0xFFFFFFF4`), avoids adding a prelude/bytes-tal primitive, and keeps the change term.chiral-local. Overrides the example §5 `bnot32` sketch. The five clear-masks are stored as full-u32 complements (table in §4 Step 1). |
| 3 | `bput-u8` — add it? (a u32 write at `c_cc` would clobber the VKILL/VEOF neighbors of VMIN/VTIME @22/@23) | **RESOLVED** — add `bput-u8` to `bytes-tal.chiral` | Needed and absent (grep-confirmed). VMIN@23/VTIME@22 are single bytes inside `c_cc`; only a byte-precise write leaves `c_cc[21]`/`c_cc[24]` intact. Mirror `bput-u32-le`'s fresh-cell contract (never mutate in place). |
| 4 | How does the pty behavioral test obtain a pty pair (chirality has no pty crossing)? | **RESOLVED** (author, 2026-08-10) — **native pty crossings**, built as the prerequisite element **E104**; no C in the floor. | The author chose the pure-chirality path over a C `openpty` harness: chirality acquires its own pty via **E104** (`/dev/ptmx` openat + `TIOCGPTN`/`TIOCSPTLCK` ioctl → `/dev/pts/N`), dogfooding scriba's own terminal ownership. E103 Step 4 *rides* E104's crossings; **E103 itself still adds no crossing** — E104 owns the crossings and its fixpoint. **Sequencing: E103 Steps 1–3/5 (fidelity fix + pure test + retire) are independent and ship first; Step 4 gates on E104.** |

No open NEEDS-AUTHOR. Decision #4 RESOLVED (native pty via **E104**).
Sequencing: Steps 1–3/5 implement-ready now; **Step 4 gates on E104**. `status: draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `term.chiral`: `RAW_*` mask defs + `cfmakeraw` body
- **Target:** `scaffold/lib/term.chiral` — replace `termios-raw-mask`
  (`0xFFFFFFF4`) with the five named knobs; rewrite `termios-set-raw`.
- **Change:** the transform reads each flag-word, bands with its **complement
  AND-mask**, ORs `CS8` into `c_cflag`, then `bput-u8` `VMIN=1`@23 and
  `VTIME=0`@22 — returning a fresh cell at every step (pure-fragment contract;
  `cell` is never mutated in place). Offsets: `c_iflag`@0, `c_oflag`@4,
  `c_cflag`@8, `c_lflag`@12.

  **Mask table (each verified as the sum of individual Linux constants):**

  | Field | Clear-set (cfmakeraw) | Σ bits = value | Stored AND-mask (`~value` u32) |
  |---|---|---|---|
  | `c_iflag`@0 | IGNBRK 0x1, BRKINT 0x2, PARMRK 0x8, ISTRIP 0x20, INLCR 0x40, IGNCR 0x80, ICRNL 0x100, IXON 0x400 | `0x5EB` = 1515 | `0xFFFFFA14` = 4294965780 |
  | `c_oflag`@4 | OPOST 0x1 | `0x1` = 1 | `0xFFFFFFFE` = 4294967294 |
  | `c_cflag`@8 (clr) | CSIZE 0x30, PARENB 0x100 | `0x130` = 304 | `0xFFFFFECF` = 4294966991 |
  | `c_cflag`@8 (set) | CS8 0x30 | `0x30` = 48 | OR-mask (set, not clear) |
  | `c_lflag`@12 | ECHO 0x8, ECHONL 0x40, ICANON 0x2, ISIG 0x1, IEXTEN 0x8000 | `0x804B` = 32843 | `0xFFFF7FB4` = 4294934452 |

  (ABI: kernel `struct termios` x86-64 little-endian — `c_iflag@0 c_oflag@4
  c_cflag@8 c_lflag@12 c_line@16` (1B) `c_cc[NCCS=19]@17`; `VTIME=c_cc[5]@22`,
  `VMIN=c_cc[6]@23`; kernel writes 36B, E99's cell is 60B — safe. Source:
  `asm-generic/termbits.h` + musl/glibc `cfmakeraw`, confirmed in the E103
  worked example §2.)

  ```chirality
  (def RAW_IFLAG_AND I64 4294965780)   ; ~0x05EB  clears IXON|ICRNL|INLCR|IGNCR|ISTRIP|BRKINT|IGNBRK|PARMRK
  (def RAW_OFLAG_AND I64 4294967294)   ; ~0x0001  clears OPOST
  (def RAW_CFLAG_AND I64 4294966991)   ; ~0x0130  clears CSIZE|PARENB
  (def RAW_CFLAG_SET I64 48)           ;  0x0030  sets   CS8
  (def RAW_LFLAG_AND I64 4294934452)   ; ~0x804B  clears IEXTEN|ECHONL|ECHO|ICANON|ISIG
  ; softer profile (keep Ctrl-C): use ~0x804A = 4294934453 for RAW_LFLAG_AND (leaves ISIG).

  (def termios-set-raw (-> Bytes Bytes)      ; pure — no tty needed to test the masks
    (lam (b0)
      (let (b1 (bput-u32-le b0 0  (band (bget-u32-le b0 0)  RAW_IFLAG_AND)))
        (let (b2 (bput-u32-le b1 4  (band (bget-u32-le b1 4)  RAW_OFLAG_AND)))
          (let (b3 (bput-u32-le b2 8  (band (bget-u32-le b2 8)  RAW_CFLAG_AND)))
            (let (b4 (bput-u32-le b3 8  (bor (bget-u32-le b3 8) RAW_CFLAG_SET)))
              (let (b5 (bput-u32-le b4 12 (band (bget-u32-le b4 12) RAW_LFLAG_AND)))
                (bput-u8 (bput-u8 b5 23 1) 22 0))))))))   ; VMIN=1  VTIME=0
  ```
- **Size:** S. `term-raw`/`term-restore`/crossings/data unchanged.

### Step 2 — `bytes-tal.chiral`: add `bput-u8`
- **Target:** `scaffold/lib/bytes-tal.chiral` — new `bput-u8 (-> Bytes I64 I64 Bytes)`.
- **Change:** byte-precise single-byte write returning a fresh cell (same
  fresh-cell discipline as `bput-u32-le` at line 538; write `val & 0xFF` at
  `off`, copy the rest). Must not touch neighboring bytes. Used by Step 1 for
  VMIN/VTIME.
- **Size:** S.

### Step 3 — pure native unit sample (mask math, no tty)
- **Target:** new `scaffold/samples/e103_termios_raw.chiral` (Phase-2 native
  test-runner sample; exit code encodes the result — per docs/testing-floors.md).
- **Change:** build a known 60B cooked cell, run `termios-set-raw`, assert the
  exact output. Concrete vector:

  | Offset | Cooked input (LE) | Expected output (LE) | Proves |
  |---|---|---|---|
  | @0  `c_iflag`  | `0x00004500` (IUTF8\|ICRNL\|IXON) | `0x00004000` | ICRNL+IXON cleared, IUTF8 survives |
  | @4  `c_oflag`  | `0x00000005` (OPOST\|ONLCR) | `0x00000004` | OPOST cleared, ONLCR survives |
  | @8  `c_cflag`  | `0x000001A0` (PARENB\|CS6\|CREAD) | `0x000000B0` | CSIZE+PARENB cleared, CS8 set, CREAD survives |
  | @12 `c_lflag`  | `0x0000803B` (IEXTEN\|ISIG\|ECHOK\|ECHOE\|ECHO\|ICANON) | `0x00000030` | ISIG/IEXTEN/ECHO/ICANON cleared, ECHOE\|ECHOK survive |
  | @21 (VSTOP nbr)| `0xAA` | `0xAA` | `bput-u8` doesn't clobber the low neighbor |
  | @22 `VTIME`    | `0x00` | `0x00` | VTIME=0 |
  | @23 `VMIN`     | `0x04` | `0x01` | VMIN=1 |
  | @24 (nbr)      | `0xBB` | `0xBB` | `bput-u8` doesn't clobber the high neighbor |

  Program compares each and `exit 0` on full match, else `exit k` (k = the
  first mismatching field's index 1..8) so a failure names the field. The test
  cell may use `cell-new` (it builds a plain buffer — the `grep cell-new
  term.chiral` invariant is about term.chiral, not tests).
- **Size:** M.

### Step 4 — pty behavioral test (the E103 runtime gate — gates on E104)
- **Depends on:** **E104** (native pty acquisition crossings). Built after E104
  lands; Steps 1–3/5 do not depend on it. No C, no external harness — chirality
  acquires the pty via E104's crossings (the author's 2026-08-10 choice).
- **Target:** a chirality pty-driver program + a chirality slave
  (`scaffold/samples/e103_pty_slave.chiral`), wired as a new case in
  `scaffold/tests/run-native.sh`.
- **Change:**
  - **Driver (chirality, via E104):** open `/dev/ptmx` → read/unlock the pts index
    (`TIOCGPTN`/`TIOCSPTLCK`) → open `/dev/pts/N` → spawn the slave with the
    slave fd as its stdin/stdout (existing fork+exec crossings) → drive the
    master fd and assert:
    1. **un-echoed:** write `0x78 'x'` to the master; read master — with ECHO off
       the kernel does not echo, so the read returns empty (a cooked tty would
       return `x`).
    2. **unbuffered + Ctrl-S no-freeze:** master writes `0x13`(Ctrl-S)`0x41`('A')
       — with IXON cleared both bytes reach the slave as data (IXON on would
       swallow `0x13` as XOFF and freeze output).
    3. **restore:** slave `term-restore`s before exit; the driver reports the
       slave exit code as the verdict.
  - **Slave (`e103_pty_slave.chiral`):** `term-raw 0`; `read 0 3` (VMIN=1 → first
    byte returns unbuffered, no newline); check the 3 bytes == `[0x78,0x13,0x41]`
    (proves ICANON off AND IXON off AND VMIN=1); `term-restore 0 saved`; `exit 0`
    on match else `exit 1`. Uses only `term-raw`/`read`/`exit` — pty acquisition
    is the driver's job (E104).
  - The run-native.sh case gates on slave exit 0 + the driver's master-side
    assertions. All chirality + bash — **no `cc`**.
- **Size:** M (after E104).

### Step 5 — retire the stale compile-smoke case
- **Target:** `scaffold/tests/../bin/test-scriba-funcs.sh` line 27:
  `ioctl) body='(ioctl 0 21505 (cell-new 512))' ;;` — pre-E99 surface (raw
  `ioctl` + surface `cell-new`, the mutate-in-place pattern E99 replaced).
- **Change:** remove the `ioctl` compile-smoke case (superseded by the Step 3
  pure sample + Step 4 pty gate, which are real runtime checks).
- **Size:** S.

## 5. Conformance gate

- **Golden behavior:**
  - *Mask math (pure):* `termios-set-raw` on the §Step-3 cooked cell yields
    exactly `c_iflag=0x4000`, `c_oflag=0x4`, `c_cflag=0xB0`, `c_lflag=0x30`,
    `VMIN@23=1`, `VTIME@22=0`, neighbors `@21=0xAA`/`@24=0xBB` intact.
  - *Behavioral (pty):* a bare keystroke is delivered un-echoed and unbuffered;
    Ctrl-S does not freeze / is delivered as data (IXON cleared); `term-restore`
    returns the tty to canonical/echo.
- **Tests to add:** Step 3 pure native sample (native-behavioral floor,
  self-checking exit code — the mask half, no tty); Step 4 pty behavioral case
  in `run-native.sh` (native-behavioral floor, chirality pty driver via **E104**'s
  crossings + chirality slave — the delivery half; gated on E104). Both **GATE** per
  docs/testing-floors.md; Python is ADVISORY.
- **Green line:** native floor green today → native floor green + the new pure
  sample (exit 0) + the new pty case (slave exit 0, master assertions pass);
  `bin/test-scriba-funcs.sh` green minus the retired `ioctl` case;
  `grep cell-new scaffold/lib/term.chiral` stays empty (E99 invariant). No
  fixpoint check (term.chiral + bytes-tal.chiral are lib, not compiler source;
  B1-compile + run). Python suite (698 fns/75 files) advisory-only — a new red
  there is reported, not gating.
- **Done when:** on a real pty a keystroke arrives un-echoed/unbuffered, Ctrl-S
  does not freeze, `term-restore` restores canonical mode, and the pure sample
  asserts the exact `cfmakeraw` output bytes — all under the native gate with
  zero compiler-source change.
- **Decision #4 RESOLVED** (author, 2026-08-10): native pty crossings via **E104**
  — no C in the floor. Step 4 gates on E104; Steps 1–3/5 ship independently.
  No residual audit concern.

## 6. Residue & links

- **Deliberately unbuilt:**
  - Native pty crossings (`/dev/ptmx` openat + `TIOCGPTN`/`TIOCSPTLCK` ioctl +
    `/dev/pts/N` open) so chirality acquires its own pty — the author's chosen path,
    now the prerequisite element **E104**. E103 Step 4 rides it; E103 itself
    builds no crossing.
  - `bnot32` — intentionally not added (decision #2); complement AND-masks
    subsume it.
  - The raw read/write loop that *consumes* raw mode — [[E98]] `nb-read-key`.
  - The editor's raw-mode *profile* choice (keep ISIG or not) — the editor
    element's call (decision #1), enabled by the softenable knob.
- **Follow-on:** unblocks [[E98]] (raw key reads over a proven raw tty) and the
  scriba editor's full-screen input path.
- **Related:** [[E103-term-raw]] (the worked example), [[E99-ioctl-out-cells]]
  (the alloc-inside crossings this rides), [[E98]] (`nb-read-key`), [[E26]]
  (alarms/errors-as-values feeding `TermiosR`/`RawR`).
