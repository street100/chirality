---
element: E104
slug: pty-crossings
title: "Native pty acquisition crossings (E99 ioctl follow-on)"
kind: BUILD-PROPER
example: examples/E104-pty-crossings.md
status: audited
updated: 2026-08-10
---

# E104 SPEC — Native pty acquisition crossings (E99 ioctl follow-on)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** chirality acquires its OWN pseudo-terminal pair natively —
  `(open-pty ())` returns `(pty-ok master slave n)` where writing a byte to the
  `master` fd is readable on the `slave` fd (same devpts, proving both ends), via
  **three new effect crossings** minted on the E99 ioctl surface:
  `nb-sys-ptsno-t` (alloc-inside ioctl `TIOCGPTN`, reads the pts index),
  `nb-sys-ptunlock-t` (value-in ioctl `TIOCSPTLCK`, unlocks the slave), and
  `nb-sys-open-rw-t` (openat with `O_RDWR|O_NOCTTY`, because the existing `openat`
  crossing is hardcoded `O_RDONLY`). Surface wrappers `nb-ptsno` / `nb-ptunlock-w`
  / `open-pty` case the results into closed sums (`PtnR` / `UnlockR` / `PtyR`).
- **Non-goals:** linear `Fd` porttyping of pty fds (fds stay raw `I64`, matching
  `openat`/`read`/`exit`; §3 D2); `grantpt` (a devpts no-op, deliberately skipped);
  window-size / termios setup on the new pts (that is E99, composed in the test
  only); a `forkpty`-style controlling-terminal handoff (residue, §6). No new
  syscall NUMBERS — `ioctl`=16 and `openat`=257 are already issued by E99/openat.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no rows — E104 postdates the map snapshot; treat as
  **BUILD**. The idiom it copies (E99 `tiocgwinsz`/`tcsetattr`) is CONFORMS/built.
- **Live code this composes with (do NOT respec):**
  - `scaffold/lib/sys-tal.chiral` — the E99 mirrors: `nb-sys-winsz-t` (L467,
    alloc-inside, `ti-const 21523` request, 8-byte `ti-bnew`, `ti-sys _ 16`,
    `op-lti` success test → fresh cell / empty cell), `nb-sys-tcsets-t` (L511,
    value-in, `ti-const 21506`, `ti-bptr` caller cell, `ti-sys _ 16`, `ti-ret`),
    `nb-sys-openat-t` (L30, `ti-bptr 1 0` / `ti-const 3 0`=O_RDONLY / `ti-sys 5
    257`), and the `sys-lib` TIFn list (L543–554).
  - `scaffold/lib/crossing-wraps.chiral` — surface→TAL pairs (L27–29 for the E99
    raws); `sys-bindings` in `sys-linkage.chiral` is DERIVED from this table
    (L93 `(cw->binds crossing-wraps)`), so **sys-linkage needs no edit**.
  - `scaffold/lib/ports.chiral` — the E99 raw externs `nb-winsz-raw`/`nb-tcgets-raw`/
    `nb-tcsets` (L142–144); `term.chiral` already `(import "ports")` (L12).
  - `scaffold/lib/target-linux.chiral` — `linux-syscalls` `SysReg`, one `sys-row`
    per crossing NAME (winsz/tcgets/tcsets each have their own row → 16; openat →
    257; L11–35). Header L7: *"Adding a crossing = one row here + its nb-sys-* def."*
  - `scaffold/lib/term.chiral` — the E99 surface wrappers `tiocgwinsz` / `term-raw`
    / `term-restore` live here; E104's sums + `open-pty` land alongside.
  - **`close` is already fully built** — surface `(extern close (=> I64 Unit))`
    (resolve.chiral:25), crossing pair `"close"→"nb-sys-close"`, TAL `nb-sys-close-t`
    (sys-tal.chiral:200), `SysReg` row (nb-sys-close→3), oracle entries. E104 REUSES
    it for error-path cleanup and the test's fd teardown; NOT a new deliverable.
  - Helpers exist (do not re-add): `i64->str` (closconv.chiral), `cell-new` /
    `bget-u32-le` / `bput-u32-le` / `blen` (bytes-tal.chiral), `str->bytes`,
    `str-cat`, and the path-NUL idiom `nul-byte` + `(bcat path nul-byte)`
    (resolve.chiral:29,176).
- **True delta:** 3 new TAL crossings + their 3 table registrations in EACH
  name-keyed authority + 3 surface externs + 3 result sums + 3 surface wrappers +
  `pts-path`. Because the crossing tables (sys-tal / crossing-wraps / target-linux)
  are **compiled into B1**, landing E104 **forces a B1 fixpoint** (§4 Step 6).

## 3. Decisions

Every open question from example §6, dispositioned. Two are corrections to the
handoff notes (surfaced, not silently applied).

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| D0 | Generic `nb-sys-ioctl` vs per-request wrappers? | **RESOLVED** | Verified vs sys-tal.chiral: NO generic ioctl; E99 is per-request. E104 mints `nb-sys-ptsno-t` (alloc-inside) + `nb-sys-ptunlock-t` (value-in), exact mirrors of `nb-sys-winsz-t`/`nb-sys-tcsets-t`. |
| D1 | `open-rw`: non-breaking sibling vs extend `openat` arity? | **RESOLVED → sibling** | `nb-sys-openat-t`'s surface `(extern openat (=> Bytes I64))` is 1-arg and consumed by resolve.chiral / self-wield.chiral / test-runner.chiral; changing its arity breaks them. Add `nb-sys-open-rw-t` = `nb-sys-openat-t` with `ti-const 3 0` → `ti-const 3 258` (O_RDWR\|O_NOCTTY=0x102), surface `(extern open-rw (=> Bytes I64))`. Non-breaking, mirrors the openat idiom. |
| D2 | fd representation: raw `I64` vs linear `Fd` porttype? | **DEFERRED → follow-on E# (linear-fd migration)** | The example, and every fd-producing crossing today (`openat`/`read`/`exit`), return raw `I64`; `open-rw` mirrors `openat` so it must return `I64` too. A linear `Fd` (the "double-close untypeable" win) requires the fd-*producing* crossings to return `Fd` + a construction/discharge path — a cross-cutting refactor of openat/read, not a pty-local change. `Fd` + `fd-close` already exist (ports.chiral:77) as the destination. E104 uses raw `I64`; linearity is a separate element. |
| D3 | Does E104 need a `close` crossing? | **RESOLVED → already built** | `close` exists end-to-end (see §2). `term.chiral` re-declares `(extern close (=> I64 Unit))` (externs are owned at declaration; lighter than importing resolve). Used on error paths and in the test teardown. No new sub-deliverable. |
| D4 *(CORRECTION)* | Do the new crossings need `sys-row` / `SYSCALL_TABLE` entries even though nrs 16 & 257 are already registered? | **RESOLVED → YES, one per crossing NAME** | Both authorities are **name-keyed default-deny**: `target-linux.chiral` has a distinct `sys-row` per crossing name (winsz/tcgets/tcsets all → 16), and the oracle `tal.py:225` does `SYSCALL_TABLE.get(fn.name)` → default-deny. So `nb-sys-ptsno`→16, `nb-sys-ptunlock`→16, `nb-sys-open-rw`→257 EACH need a row in `target-linux.chiral` (fixpoint-critical: B1's own `ck-tifn` sys-check rejects an unregistered TAL fn) **and** in `tal.py SYSCALL_TABLE` (advisory floor). This corrects the handoff note "NO new syscall-number row is needed" — true for the *number*, false for the name-keyed *permission row*. |
| D5 *(CORRECTION)* | Path passing — is `(str->bytes "/dev/ptmx")` sufficient? | **RESOLVED → must NUL-terminate** | `nb-sys-openat-t` requires a NUL-terminated cell (comment L27–28: *"payload MUST be null-terminated by the caller"*). The example's bare `(str->bytes …)` is short a terminator; the real call is `(open-rw (bcat (str->bytes "/dev/ptmx") nul-byte))`, and `(pts-path n)` likewise, using the `nul-byte` idiom from resolve.chiral:29. |
| D6 | ioctl request `0x80045430`=2147767344 exceeds 2^31 — does `ti-const` corrupt it (cf. c9f061d)? | **RESOLVED → benign, verify in test** | The kernel truncates the ioctl `cmd` to `unsigned int`; the low 32 bits are `0x80045430` under both zero- and sign-extension, so a sign-extended `ti-const` load still matches. `0x40045431`=1074025521 is < 2^31 anyway. The behavioral test (§5) catches any real corruption (wrong request → `ptn-err`). No codegen change. |

No blocking NEEDS-AUTHOR; `status: draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — three TAL crossings + sys-lib registration
- **Target:** `scaffold/lib/sys-tal.chiral`
- **Change:** add three `TIFn` defs, each a mechanical mirror of its E99 sibling:
  - `nb-sys-ptsno-t` — copy `nb-sys-winsz-t` (L467); substitute request
    `(ti-const 1 2147767344)` (TIOCGPTN 0x80045430) and cell length
    `(ti-const 4 4)` (4-byte `*uint`); keep `ti-sys 4 16`, `op-lti` success test,
    fresh-cell/empty-cell branches.
  - `nb-sys-ptunlock-t` — copy `nb-sys-tcsets-t` (L511); substitute request
    `(ti-const 2 1074025521)` (TIOCSPTLCK 0x40045431); keep `ti-bptr 3 1`,
    `ti-sys 4 16`, `ti-ret 4`. Caller supplies a 4-byte cell holding int 0.
  - `nb-sys-open-rw-t` — copy `nb-sys-openat-t` (L30); substitute flags
    `(ti-const 3 258)` (O_RDWR\|O_NOCTTY=0x102); keep `ti-bptr 1 0`, `ti-const 2
    -100` (AT_FDCWD), `ti-const 4 0` (mode), `ti-sys 5 257`, `ti-ret 5`.
  - Append all three to the `sys-lib` list (L543–554).
- **Size:** ~M

### Step 2 — crossing-wraps surface→TAL pairs
- **Target:** `scaffold/lib/crossing-wraps.chiral` (L27–30, after the E99 pairs)
- **Change:** add `(pair "nb-ptsno-raw" "nb-sys-ptsno")`, `(pair "nb-ptunlock"
  "nb-sys-ptunlock")`, `(pair "open-rw" "nb-sys-open-rw")`. `sys-bindings`
  auto-derives — no sys-linkage edit.
- **Size:** ~S

### Step 3 — surface externs
- **Target:** `scaffold/lib/ports.chiral` (L142–144, beside the E99 raws)
- **Change:** `(extern nb-ptsno-raw (=> I64 Bytes))` (fd → 4B cell \| empty),
  `(extern nb-ptunlock (=> I64 Bytes I64))` (fd, in-cell(int 0) → 0 \| -errno),
  `(extern open-rw (=> Bytes I64))` (NUL-terminated path → fd \| -errno).
- **Size:** ~S

### Step 4 — SysReg permission rows (fixpoint-critical) + oracle mirror
- **Target:** `scaffold/lib/target-linux.chiral` (`linux-syscalls`, L11–35) **and**
  advisory oracle `scaffold/chirality/tal.py` (`SYSCALL_TABLE`, ~L120–125) +
  `scaffold/chirality/native.py` (`LIB_SIGS`, ~L142).
- **Change:** add `(sys-row "nb-sys-ptsno" 16)`, `(sys-row "nb-sys-ptunlock" 16)`,
  `(sys-row "nb-sys-open-rw" 257)` to the chirality `SysReg` (authority; without these
  B1's own sys-check default-denies the new TAL fns). Mirror the same three
  name→number entries into `tal.py SYSCALL_TABLE`, and add the three surface-extern
  crossing sigs to `native.py LIB_SIGS` (`nb-sys-ptsno`:([I64],BYTES),
  `nb-sys-ptunlock`:([I64,BYTES],I64), `nb-sys-open-rw`:([BYTES],I64)) so the
  advisory differential floor stays green — the same both-floors move the self-wield
  `openat` crossing used.
- **Size:** ~S

### Step 5 — result sums + surface wrappers (lib API)
- **Target:** `scaffold/lib/term.chiral`
- **Change:** add `(data PtnR …)` / `(data UnlockR …)` / `(data PtyR …)`;
  `(def nb-ptsno …)` (case `blen`=0 → `ptn-err` / else `ptn-ok (bget-u32-le cell
  0)`); `(def nb-ptunlock-w …)` (pass `(bput-u32-le (cell-new 4) 0 0)`, case rc<0);
  `(def pts-path …)` = `(str-cat "/dev/pts/" (i64->str n))`; `(def open-pty …)` the
  four-step dance from example §5 — **but** wrap both `open-rw` paths as
  `(bcat (str->bytes …) nul-byte)` (D5) and re-declare `(extern close (=> I64
  Unit))` for the error-path fd cleanup (thread a `close` of the master before
  returning `pty-err` on the unlock/ptsno/slave-open failure branches — the fd-leak
  the example skeleton flagged).
- **Size:** ~M

### Step 6 — B1 fixpoint (mandatory; the compiler's own tables changed)
- **Target:** the build, not a file.
- **Change:** build-new (`./build.sh` → `chirality-bin.new`, i.e. `B1 < blob > out`);
  run the native pty sample + suite against `chirality-bin.new`; promote it; then run the
  **promoted** binary over the same blob and **byte-compare it against itself**
  (B1-compiles-B1 self-reproduction, ~1s). Steps 1/2/4's edits are what enter B1's
  compiled crossing tables, so this gate proves the new crossings did not break
  self-hosting. Landing must be byte-identical on the second pass.
- **Size:** ~S (verification)

## 5. Conformance gate

- **Golden behavior:** on a Linux box with a devpts mount, `(open-pty ())` returns
  `(pty-ok master slave n)` with `master ≥ 0`, `slave ≥ 0`, `n ≥ 0`, and the slave
  is exactly `/dev/pts/n`; a byte written to `master` is read back on `slave`
  (proving both fds name the same pty). A wrong ioctl request number would surface
  as `ptn-err`/`unlock-err` (EINVAL) or a garbage `n` — so the request constants
  are checked byte-for-byte by behavior.
- **Tests to add — native floor GATES (docs/testing-floors.md):**
  1. `scaffold/tests/samples/e104_pty.chiral` — a behavioral sample compiled with
     **B1** and run as an ELF. Because `PtyR`'s `pty-err` carries only an errno (no
     step identity), the sample runs the four-step dance **stepwise** — casing
     `open-rw` (master) / `nb-ptunlock-w` / `nb-ptsno` / `open-rw` (slave) directly
     (a test may exercise the raw wrappers; `open-pty` is the collapsed lib API for
     callers who don't need step tags) — so each failing step maps to its own exit
     code; on a step failure exits with that step-tagged code; on the full success
     path (equivalent to `pty-ok m s n`) puts the slave into raw mode via E99
     `(term-raw s)` (so the round-trip is a deterministic single byte, not
     canonical-line-buffered — this also demonstrates E99∘E104 compose); writes one
     byte `0x41` to `m` via `put`/`write`; reads 1 byte from `s`; asserts it equals
     `0x41`; `close`s both fds; `exit`s. **Exit-code encoding:** `42`=full success;
     `10`=master open failed; `11`=unlock failed; `12`=ptsno failed; `13`=slave open
     failed; `20`=byte mismatch. The runner asserts exit `42`.
  2. *(advisory)* mirror the same program through the differential harness so the
     python reference machine (which issues the real syscalls) and the native drop
     agree — kept green by the Step 4 oracle mirror; not the gate.
- **Green line:** 698 test functions → ≥ 699 (the native pty sample); `ledger-lint`
  clean; **fixpoint: promoted B1 reproduces itself byte-identically** over the blob.
- **Done when:** `e104_pty.chiral` compiled by B1 exits `42` on a devpts host, and
  B1-compiles-B1 is byte-identical after the crossings land.

## 6. Residue & links

- **Deliberately unbuilt (with homes):**
  - Linear `Fd` porttyping of the pty (and all) fds — **follow-on element**
    (linear-fd migration; destination type `Fd`+`fd-close` already in ports.chiral).
  - Controlling-terminal handoff / `setsid`+`TIOCSCTTY` / `forkpty` shape — a
    later scriba element (owns-its-terminal end-to-end); E104 uses `O_NOCTTY`.
  - `grantpt` — a devpts no-op, intentionally never ported.
  - Window-size / termios provisioning on the fresh pts — that is E99, only
    *composed* in the E104 test (`term-raw`), not respec'd here.
- **Follow-on:** unblocks **E103** (its pty behavioral test drives exactly the
  `open-pty` round-trip) and scriba owning its own terminal.
- **Related:** [[E104-pty-crossings]] · [[E99-ioctl-crossings]] (the mirrored idiom)
  · [[E103]] (rides this) · [[openat-crossing]] · [[pattern-boundary-sums]].
