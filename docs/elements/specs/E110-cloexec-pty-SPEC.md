---
element: E110
slug: cloexec-pty
title: Close-on-exec fd hygiene on the pty path: open the pty master `O_CLOEXEC` (or explicitly close it in the child branch of `spawn-in-pty` before `exec`) so the child does not inherit the master fd across `exec`
kind: BUILD-PROPER
example: examples/E110-cloexec-pty.md
status: audited
updated: 2026-08-12
---

# E110 SPEC — Close-on-exec fd hygiene on the pty path

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the pty master (and slave) opened by `open-pty`
  (`term.chiral:199,209`) carry `O_CLOEXEC`, because the hardcoded open-flag const
  in `nb-sys-open-rw-t` (`sys-tal.chiral:638`) changes from `258` (`O_RDWR|O_NOCTTY`)
  to `524546` (`O_RDWR|O_NOCTTY|O_CLOEXEC = 0x80102`). The child shell spawned by
  `spawn-pty-child` / `nb-spawn-in-pty` no longer inherits the pty **master** fd
  across `exec` — the fd is auto-closed by the kernel at `exec`, closing the
  fd-leak / isolation hole. The dup2'd child fds 0/1/2 still survive `exec`
  (dup2 clears close-on-exec on the new fd), so the child's controlling terminal
  is unaffected.
- **Non-goals:** no new open crossing that takes an explicit flags argument
  (option a2, §3.1); no manual `close(master)` in the child branch (option b,
  §3.1); no `fcntl(F_SETFD)` post-open path (strictly worse, non-atomic); no
  change to `term.chiral`, `ports.chiral`, or the surface `open-rw` extern.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no rows — E110 postdates the CONFORMANCE-MAP
  snapshot; treat as **BUILD** on the E104 pty path. The catalog row confirms the
  mechanism (`MFD_CLOEXEC`) is already in-tree for `memfd` (`sys-tal.chiral:74,82`,
  flags param `0` or `1`) and simply not applied on the pty path.
- **Live code (compose with, do NOT respec):**
  - `nb-sys-open-rw-t` (`sys-tal.chiral:634-641`) — the openat(AT_FDCWD, path,
    `258`, 0) crossing (nr 257). Flag word is `(ti-const 3 258)` at line 638.
  - `open-pty` (`term.chiral:197-216`) — calls `open-rw` twice (master `/dev/ptmx`
    line 199, slave `/dev/pts/n` line 209). **Unchanged** by this SPEC.
  - `nb-spawn-in-pty-t` (`sys-tal.chiral:658`) / `spawn-pty-child`
    (`term.chiral:287`) — the child branch dup2's the slave onto 0/1/2 and closes
    the raw slave; it never receives the master fd. **Unchanged**.
  - `nb-sys-memfd-t` (`sys-tal.chiral:75-86`) — the `MFD_CLOEXEC` precedent.
  - `nb-sys-fcntl-t` (`sys-tal.chiral:208-211`, nr 72) + `fd-cloexec?` /
    `F_GETFD` / `FD_CLOEXEC` (`term.chiral:185-196`) — the E121 fcntl crossing
    (committed 6bc75ba), the readback machinery this SPEC's gate now uses.
  - e104_pty sample (`tools/test/samples/e104_pty.prog`) — opens master via
    `open-rw`, unlocks, reads ptsno, opens slave, exits 42 on success.
  - e121_fcntl sample (`tools/test/samples/e121_fcntl.prog`) — leg (a) is a
    standalone `fcntl` set→get round-trip (drives exit 42); leg (b)
    `observe-master-cloexec` opens the master via `open-pty` and reads
    `fd-cloexec? master` — the conclusive E110 gate, wired observational-only
    pending this flip.
- **`open-rw` caller audit (re-verified, full tree):** callers are `open-pty`
  master+slave (`term.chiral:199,209`), the e104_pty sample (`:29,:39`), the
  e121_fcntl sample (`:37`), and two T1 child samples — `t1_child_ctty.chiral:22`
  (opens `/dev/tty`) and `t1_child_wiring.chiral:35` (opens the child ELF file).
  **Every caller is cloexec-safe:** the two `open-pty` opens are the fix (master
  leak closed; slave harmless — dup2 clears cloexec off 0/1/2, raw slave closed
  pre-exec); e104_pty/t1_child_ctty/t1_child_wiring each use the fd **locally and
  `close` it before any `exec`** (t1_child_wiring reads the ELF bytes then closes
  cfd *before* `spawn-pty-child`), so cloexec never matters; e121_fcntl leg (a)
  **sets** `FD_CLOEXEC` itself via `F_SETFD` so the flip is idempotent (still
  exits 42), and leg (b) now observes the master bit **set** (the payoff). No
  caller needs an inheritable fd → the shared-const flip is complete and safe.
  Were an inheritable-fd caller ever added, it would need (a2). (See decision #2.)
- **True delta:** exactly one integer literal at `sys-tal.chiral:638`
  (`258` → `524546`) plus its comment, and the conformance gate (§5). Nothing else.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | (a1) OR the bit into the shared hardcoded const vs (a2) mint a flags-taking open crossing vs (b) close master manually in the child | **RESOLVED → (a1)** | Example §6 recommendation, cited: (a1) is **atomic** (no fork→exec window, unlike b and fcntl); needs **zero new plumbing** (master fd never threaded into the child crossing, unlike b); **mirrors the in-tree `MFD_CLOEXEC` precedent** (`sys-tal.chiral:74,82`); complete + harmless across both opens (dup2 clears cloexec off 0/1/2 — web-verified man7 `dup(2)`; raw slave closed pre-exec `term.chiral`). (a2) earns its keep only if a future caller wants a deliberately-inheritable fd — not the case today. |
| 2 | Is applying cloexec to the shared `open-rw` const safe for EVERY caller (no caller must stay inheritable)? | **RESOLVED** | Grep-verified full tree: `open-rw` callers = `open-pty` master+slave (`term.chiral:199,209`), e104_pty sample (`:29,39`), e121_fcntl sample (`:37`), t1_child_ctty (`:22`, opens `/dev/tty`), t1_child_wiring (`:35`, opens the child ELF). Master: leak is the bug being fixed. Slave: dup2 onto 0/1/2 clears cloexec so 0/1/2 survive exec; raw slave fd (>=3) is explicitly closed before exec (`login-tty`/child branch). The four samples each use the fd locally and `close` it before any `exec` (t1_child_wiring closes cfd before `spawn-pty-child`); e121_fcntl leg (a) sets `FD_CLOEXEC` itself so the flip is idempotent. No inheritable-fd caller exists → shared-const flip is total and correct. Were one ever added, it would need (a2). |
| 3 | The exact flag value | **RESOLVED** | `O_RDWR 0x2 | O_NOCTTY 0x100 | O_CLOEXEC 0x80000 = 0x80102 = 524546`. Arithmetic verified: `2 + 256 + 524288 = 524546`; `O_CLOEXEC = 0o2000000 = 1<<19 = 524288` (Linux `asm-generic/fcntl.h`, man7 `open(2)`, web-verified in example §2). Was `258 = 0x102`. |
| 4 | Named `def` (`O_RDWR_NOCTTY_CLOEXEC I64 524546`) vs bare `(ti-const 3 524546)` | **RESOLVED → bare const + comment** | The sibling crossings in `sys-tal.chiral` (memfd flags, openat, etc.) all use bare `ti-const` with an explanatory comment, not named flag `def`s. Keep the local convention; the comment carries the readability (`258 → 524546`, bit breakdown). A named `def` is a cross-file refactor out of scope for a one-const hygiene fix. |
| 5 | Should E110 also audit the parent-held slave fd + E104 slave-open for the same hygiene? | **RESOLVED — covered automatically** | Both route through the same `open-rw` crossing, so (a1) applies cloexec to them too. No separate work; noted in §6 residue. |
| 6 | Can the conformance gate observably prove FD_CLOEXEC was set (not just requested)? | **RESOLVED — conclusive readback now runnable** | The fcntl crossing this decision waited on **exists**: E121 (committed 6bc75ba) added `nb-sys-fcntl-t` (nr 72, `sys-tal.chiral:208-211`), the `fcntl` extern (`ports.chiral`), and the typed `fd-cloexec?` sugar with `F_GETFD`/`FD_CLOEXEC` (`term.chiral:185-196`). The conclusive gate — open the master via `open-pty` (which threads the flipped `open-rw`) and assert `(band (fcntl master F_GETFD 0) FD_CLOEXEC) ≠ 0`, i.e. `fd-cloexec? master == FD_CLOEXEC(1)` — is therefore feasible today, with **no new crossing**. Better: `e121_fcntl.chiral` leg (b) `observe-master-cloexec` already wires exactly this call (currently observational, "clear pre-E110, set once E110 lands"); §5 promotes it to a gating assertion. The prior static-flag-word gate is retained as a cheap unit check, no longer the ceiling. |

No decision blocks §4. `status: draft` (implementable). Decision #6 (the only
former NEEDS-AUTHOR) is now RESOLVED by E121 — the conclusive gate is in §5.

## 4. Change plan (ordered, commit-sized)

### Step 1 — Flip the open-flag const to include O_CLOEXEC
- **Target:** `lib/lowering/tal/sys.chiral` — `nb-sys-open-rw-t`, the `(ti-const
  3 258)` at line 638 (and the descriptive comment block at lines 630-633).
- **Change:** `(ti-const 3 258)` → `(ti-const 3 524546)`. Update the comment
  block (`:630`) from `O_RDWR|O_NOCTTY=0x102=258` to
  `O_RDWR|O_NOCTTY|O_CLOEXEC=0x80102=524546`, noting the bit breakdown and that
  it mirrors `nb-sys-memfd-t`'s `MFD_CLOEXEC` (`:75`). No other line changes.
- **Reblob + self-host:** `sys-tal` is in B1's blob. After the edit, rebuild:
  `chirality_blob … | B1 < blob | cmp - bin/chirality-bin`. If the byte-compare
  differs (it will — the const is embedded), reblob and promote the new B1 per
  the BUILD RULE (build-new → test → promote; then run the promoted binary over
  the same blob once and byte-compare for the self-hosting fixpoint, since a
  compiler source changed). If it does NOT differ, no promote.
- **Size:** ~S (one literal + comment).

### Step 2 — Conformance test (conclusive fcntl readback + regression)
- **Target:** promote leg (b) of `tools/test/samples/e121_fcntl.prog`
  (`observe-master-cloexec`) from observational to gating, plus a
  `scaffold/tests/test_e110_cloexec_pty.py` runner; reuse the e104_pty sample.
- **Change:** see §5. (a) **Conclusive:** the e121_fcntl leg (b) call
  `fd-cloexec? master` (= `(band (fcntl master F_GETFD 0) FD_CLOEXEC)`) must now
  return `FD_CLOEXEC(1)` — assert `≠ 0`; a clear bit fails the gate. (b)
  **Regression:** the e104_pty sample still compiles+runs and exits 42 (the new
  flag is a valid `openat` flag → master & slave still open). (c) optional cheap
  unit check: the compiled `nb-sys-open-rw` const is `524546` (`0x80102`).
- **Size:** ~S.
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

## 5. Conformance gate

- **Golden behavior:** every fd returned by `nb-sys-open-rw` is opened with
  `O_CLOEXEC` set, so the pty master is auto-closed at the child's `exec` while
  the dup2'd 0/1/2 survive. The open itself must still succeed for master and
  slave.
- **Gate chosen (CONCLUSIVE — the E121 fcntl crossing makes readback runnable):**
  1. **Conclusive fcntl readback (option i — now feasible).** Open the pty master
     via `open-pty` (which routes through the flipped `open-rw`) and read the
     kernel's actual fd flags: `(band (fcntl master F_GETFD 0) FD_CLOEXEC)`, i.e.
     the typed sugar `fd-cloexec? master`. Assert the result is `FD_CLOEXEC(1)`
     (`≠ 0`) — this proves `FD_CLOEXEC` was *set by the kernel*, not merely
     requested. `e121_fcntl.chiral` **leg (b)** (`observe-master-cloexec`,
     `:25-33`) already issues exactly this call; it is documented there as "clear
     pre-E110, set once E110 lands … the conclusive gate E110's SPEC deferred,
     wired but not yet green". This SPEC promotes it from observational to a
     **gating** assertion (a clear bit → non-42 exit). The crossing it rides —
     `nb-sys-fcntl-t` (nr 72, `sys-tal.chiral:208`) + `fcntl` extern + `fd-cloexec?`
     — is live in-tree from E121 (6bc75ba); no new crossing is minted.
  2. **Behavioral regression (open still succeeds).** Compile+run
     `scaffold/tests/samples/e104_pty.chiral` and assert **exit 42** — the master
     and slave still open successfully under the new `0x80102` flag word. `0x80102`
     is a valid `openat` flag, so a broken value (e.g. a typo'd bit) would fail
     the open and change the exit code. Also confirms e121_fcntl leg (a) — the
     standalone `F_SETFD`→`F_GETFD` round-trip — still exits 42 (the flip is
     idempotent: leg (a) sets cloexec itself).
  3. **(optional) Static flag-word unit check.** Compile `nb-sys-open-rw-t` (via
     the TAL/native path used by `test_tal.py` / `test_native.py`) and assert the
     third syscall const is `524546` (`0x80102`). A cheap fast-failing guard,
     subordinate to check 1 which proves *enforcement* end-to-end.
- **Enforcement is proven, not just requested:** with the E121 readback in place,
  check 1 observes the kernel-set `FD_CLOEXEC` bit directly — the earlier honesty
  caveat ("static gate only proves the flag was requested") no longer applies.
  Checks 1 and 2 require a devpts mount (`/dev/ptmx`); on a devpts-less host they
  return `-errno` and are skipped (the static unit check 3 still runs). A
  fork/exec child-probe confirming `EBADF` on the master post-`exec` (option ii)
  remains a nice-to-have but is superseded by the direct `F_GETFD` readback.
- **Tests to add:** `test_e110_cloexec_pty.py` — (a) e121_fcntl leg (b) asserts
  `fd-cloexec? master == FD_CLOEXEC` (conclusive); (b) e104_pty sample exits 42
  (regression); (c) optional static flag-word == 524546.
- **Green line:** current 704 test functions → ≥ 706 (≥2 new assertions);
  ledger-lint clean.
- **Done when:** the const at `sys-tal.chiral:638` is `524546`; `fd-cloexec?
  master` reads `FD_CLOEXEC` after `open-pty` (e121_fcntl leg (b) green as a
  gate); the e104_pty sample still exits 42; and (if B1's blob changed) B1
  reproduces itself byte-identically after promote.

## 6. Residue & links

- **Now built / in-gate (was deferred):**
  - **Conclusive enforcement gate** (`fcntl(F_GETFD)` readback, option i) — the
    `nb-sys-fcntl` crossing (nr 72) it needed now exists (E121, 6bc75ba), so this
    is promoted into §5's gate, not residue. Decision #6 is RESOLVED.
- **Deliberately unbuilt:**
  - **Spawn-probe EBADF test (option ii)** — a child-probe ELF spawned via
    `spawn-pty-child` that confirms the master fd is `EBADF` post-`exec`. Superseded
    by the direct `F_GETFD` readback; recorded as a nice-to-have, not built.
  - **(a2) flags-taking open crossing** — home: a future element, only if a
    non-pty `open-rw` caller ever needs an inheritable fd (none today).
  - **(b) manual master-close in the child** — rejected (non-atomic, needs a
    signature change on `spawn-in-pty`); recorded, not built.
- **Follow-on:** unblocks the pty path's isolation story on the E104/T-series
  child-wiring line; the E121 fcntl crossing also serves any future fd-flag
  inspection.
- **Related:** [[E110-cloexec-pty]], [[E104-pty-acquire]] (added `open-rw`, the
  flags-less open this builds on), sys-tal and term, two old-tree module notes with
  no successor here; their live modules are `lib/lowering/tal/sys.chiral`, which
  carries the `nb-sys-memfd-t` `MFD_CLOEXEC` precedent, and `lib/protocol/term.chiral`.
