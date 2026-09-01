---
element: E121
slug: fcntl
title: `fcntl`/`F_GETFD` crossing: expose `fcntl` (F_GETFD / F_SETFD) as a TAL crossing so a fd's close-on-exec state is readable at runtime — the conclusive gate for E110's O_CLOEXEC (assert `fcntl(master, F_GETFD) & FD_CLOEXEC`) and general fd-flag hygiene
kind: BUILD-PROPER
example: examples/E121-fcntl.md
status: audited
updated: 2026-08-12
---

# E121 SPEC — `fcntl`/`F_GETFD` crossing

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** `fcntl(fd, cmd, arg)` lowers to a native x86-64 syscall
  crossing (nr 72), so `fcntl(fd, F_GETFD)` reads a fd's flag word at runtime and
  `fcntl(fd, F_SETFD, arg)` sets it; the surface sugar `fd-cloexec? fd` returns
  the fd's close-on-exec bit. This closes **SYS·E110**'s deferred conclusive gate:
  its O_CLOEXEC on the pty master becomes a *runtime-checked* invariant
  (`band (fcntl master F_GETFD 0) FD_CLOEXEC ≠ 0`) instead of a documented
  expectation.
- **Non-goals:** the file-lock commands `F_SETLK`/`F_SETLKW`/`F_GETLK` (they take a
  `struct flock *` — an alloc-inside crossing, a separate element); `F_GETFL`/
  `F_SETFL` (same int-in/int-out shape, trivially reachable through the same raw
  extern later, but not authored here); a closed `FcntlCmd` sum for the command
  operand (see §3 #3). Residue in §6.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** BUILD — E121 postdates the CONFORMANCE-MAP
  snapshot (bundle §3: "none — treat as BUILD"); grep-clean, no `fcntl` crossing
  exists. This is net-new linkage on a fully-built substrate, not an EXTEND/REFACTOR.
- **Live code this composes with (name, do not respec):**
  - `scaffold/lib/sys-tal.chiral:200` `nb-sys-close-t` — the value-in / rax-out
    mirror (`ti-fn "nb-sys-close" 1 2` → `ti-sys` then `ti-ret`, no cell). E121 is
    the same shape with 3 register args.
  - `scaffold/lib/sys-tal.chiral:511` `nb-sys-tcsets-t` — the existing 3-arg
    `ti-sys` precedent (`(cons 0 (cons 2 (cons 3 nil)))`), confirms the arg-list
    idiom E121 mirrors (E121's three args are the plain a0/a1/a2 registers, no
    `ti-const`/`ti-bptr` staging since there is no cell).
  - `scaffold/lib/target-linux.chiral:11` `linux-syscalls` (`SysReg`) — the
    allow-list E121 adds one row to.
  - `scaffold/lib/crossing-wraps.chiral:13` `crossing-wraps` — the surface→wrapper
    table E121 adds one pair to. Its stated INVARIANT: must agree with
    `lib/sys-linkage.chiral` `sys-bindings`, which is *derived* from this table
    (`cw->binds crossing-wraps`, sys-linkage.chiral:91-93) — so no manual
    sys-linkage edit is needed; adding the pair propagates automatically.
  - `scaffold/lib/ports.chiral:88` `write-fd` (`(=> I64 Bytes I64)`) — the flat
    single-raw-crossing extern precedent E121's `fcntl` extern follows.
  - `scaffold/lib/term.chiral:181` `open-pty` — E110's consumer; currently opens
    via `open-rw` (O_RDWR|O_NOCTTY, no O_CLOEXEC). Home for the typed sugar and
    the E110 assertion.
  - `scaffold/lib/prelude.chiral:28,39` `op-band` (surface op **`band`**) — the
    I64 bitwise-and used by the sugar and both conformance legs.
- **True delta:** one tal body + one SysReg row + one crossing-wraps pair + one
  surface extern + three pure I64 defs + one pure `fd-cloexec?` def + one
  conformance sample. Nothing else changes.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Single flat `fcntl` extern vs. split typed `fd-getfd`/`fd-setfd` externs | RESOLVED — single raw crossing + pure typed sugar | Mirrors the settled flat-crossing precedent `write-fd`/`mmap` (ports.chiral:88-89): one raw crossing means one SysReg row + one wrap pair covers *every* fcntl command; commands/args are ordinary I64s the caller passes. The typed face (`F_GETFD`, `fd-cloexec?`) is pure surface over it (example §5e). This is the example §6 recommendation, consistent with the boundary-sums directive's "parse once" only at the *typed* layer. |
| 2 | ABI constants (syscall nr, command values, flag bit) | RESOLVED-with-source | `__NR_fcntl = 72` (asm/unistd_64.h; filippo.io/linux-syscall-table). `F_GETFD = 1`, `F_SETFD = 2` (glibc bits/fcntl-linux.h; man7 fcntl(2)). `FD_CLOEXEC = 1` (bit 0; man7 fcntl(2), GNU libc Descriptor Flags). Web-verified in example §2 — do NOT re-assert from memory (wrong-constant failure class). |
| 3 | Mint a closed `FcntlCmd` sum for the command operand (boundary-sums directive) | DEFERRED — named I64 defs suffice | Example §6 defers it; `F_GETFD`/`F_SETFD` as named I64 defs meets the E110 gate. A closed `FcntlCmd` sum is a follow-on typed-face refinement (§6), not required for the crossing to lower or for the cloexec proof. Not an author call — it is a scoped-out enhancement with a named home. |
| 4 | Surface bitwise-and op name in the sugar/asserts | RESOLVED — `band` | The example §5 wrote `and`; the actual surface op is **`band`** (`op-band`, prelude.chiral:28/39; native.py:63 `_PRIMS`). The SPEC and sample use `band` (E96 bitwise goldens). This is a mechanical correction carried into the contract; the example rationale is unaffected. |

No genuine open author decision. Nothing blocks §4; `status: specced`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — crossing body + allow-list row
- **Target:** `scaffold/lib/sys-tal.chiral` (new `nb-sys-fcntl-t`, near the
  value-in crossings ~L200/L511) and `scaffold/lib/target-linux.chiral`
  (`linux-syscalls`, one row).
- **Change:**
  ```chirality
  ; fcntl(fd, cmd, arg) -> result in rax (flag word for F_GETFD, 0 for F_SETFD;
  ; -errno on error). Value-in / rax-out: NO cell, so NO ti-bptr/ti-bnew.
  ; Mirror of nb-sys-close-t; 3 register args instead of 1. nr 72 = __NR_fcntl.
  (def nb-sys-fcntl-t TIFn
    (ti-fn "nb-sys-fcntl" 3 4
      (t-seq (ti-sys 3 72 (cons 0 (cons 1 (cons 2 nil))))
        (ti-ret 3))))
  ```
  Register `nb-sys-fcntl-t` in `sys-lib` (the `List TIFn`, sys-tal.chiral:696).
  In `target-linux.chiral` add `(cons (sys-row "nb-sys-fcntl" 72)` inside the
  cons-chain and one matching `)` to the trailing `(nil)))))...` closer.
- **Size:** S

### Step 2 — surface extern + wrap pair + typed sugar
- **Target:** `scaffold/lib/crossing-wraps.chiral` (one pair), `scaffold/lib/ports.chiral`
  (one extern), `scaffold/lib/term.chiral` (typed sugar, near `open-pty`).
- **Change:**
  - crossing-wraps: add `(cons (pair "fcntl" "nb-sys-fcntl")` + one closing `)`
    on the trailing `nil))))...` line. (sys-linkage `sys-bindings` re-derives — no
    edit there.)
  - ports: `(extern fcntl (=> I64 I64 I64 I64))  ; fcntl(fd,cmd,arg) -> flags | -errno`
  - term (pure sugar):
    ```chirality
    (def F_GETFD I64 1)          (def F_SETFD I64 2)          (def FD_CLOEXEC I64 1)
    (declare fd-cloexec? (=> I64 I64))
    (def fd-cloexec? (lam (fd)
      (let (flags (fcntl fd F_GETFD 0))
        (case (<i flags 0)
          (true  flags)                       ; propagate -errno as a value
          (false (band flags FD_CLOEXEC))))))  ; 0 or FD_CLOEXEC(1)
    ```
    (Use the repo's live `let`/`case` surface form as in term.chiral:185-197 —
    single-binder `(let (x e) ...)`, `case` over `(<i flags 0)`.)
- **Size:** S

### Step 3 — conformance sample (both legs)
- **Target:** `scaffold/tests/samples/e121_fcntl.chiral` (model on
  `scaffold/tests/samples/e104_pty.chiral`).
- **Change:** the two `compile-main (=> I64 I64)` legs of §5 (a) and (b),
  exit 42 on success. Import `prelude`/`ports`/`bytes-tal`/`term`.
- **Size:** S

## 5. Conformance gate

- **Golden behavior — TWO legs, both runnable:**
  - **(a) standalone fcntl round-trip** (independent of E110): open a fd
    (`open-rw` on `/dev/ptmx`, or any fd), `fcntl(fd, F_SETFD, FD_CLOEXEC)` then
    `fcntl(fd, F_GETFD, 0)`; assert `band result FD_CLOEXEC ≠ 0` → exit **42**,
    else a distinct non-42 code. Proves the crossing itself works (set→get
    round-trips through nr 72). Runs today without E110.
  - **(b) E110 integration payoff** (the reason E121 exists): after `open-pty`
    yields `master`, assert `band (fcntl master F_GETFD 0) FD_CLOEXEC ≠ 0` → the
    conclusive cloexec proof E110's SPEC deferred. **Dependency:** observing the
    bit *set* requires E110 implemented (open-pty opening the master with
    O_CLOEXEC). Until E110 lands this leg observes the bit *clear* (documents the
    gap); it flips to the positive proof when E110 ships. Name E110 as the
    prerequisite for leg (b)'s green assertion.
- **Reblob-cmp gate:** `sys-tal.chiral`, `target-linux.chiral`, and
  `crossing-wraps.chiral` are all in B1's blob, so a self-host re-check is
  required. After promoting: rebuild the blob and byte-compare —
  `chirality_blob … | B1 < blob | cmp - scaffold/build/B1`. Reblob + promote only if
  it differs (compiler sources changed → the one-command self-hosting check per
  the BUILD RULE). Then green-line the sample: compile it with B1 and run
  (`B1 < sample.chiral > out && ./out; echo $?` → 42).
- **Tests to add:** the `e121_fcntl.chiral` sample (both legs), wired the way
  `e104_pty.chiral` is verified (resolver blob, imports resolved; requires a
  devpts mount for the pty path). A native compile-run assertion on leg (a) if a
  test_* harness slot fits (`test_compile_run_chirality.py` shape).
- **Green line:** 704 test functions → ≥ 705 (the sample; +1 more if a native
  compile-run test is added); ledger-lint clean.
- **Done when:** leg (a) exits 42 through the native (B1-compiled) binary, the
  blob byte-reproduces after promotion, and leg (b) is present and observes the
  bit (clear pre-E110, set post-E110).

## 6. Residue & links

- **Deliberately unbuilt:** `F_GETFL`/`F_SETFL` (same int-in/int-out shape —
  reachable through the same `fcntl` extern later, no new linkage); `F_SETLK`/
  `F_GETLK` file locks (alloc-inside `struct flock *` crossing — the winsz-Getter
  shape, a separate element); closed `FcntlCmd` command sum (§3 #3 — typed-face
  follow-on, home = term/ports typed layer).
- **Follow-on:** unblocks **E110**'s conclusive O_CLOEXEC assertion (leg b);
  enables general fd-flag hygiene for future pty/socket work.
- **Related:** [[E121-fcntl]] (example/rationale), [[E110]] (O_CLOEXEC pty master
  — the consumer of this gate), [[E104]] (pty ioctl crossings — sibling sys-tal
  bodies), [[E105]] (`write-fd` flat-extern precedent).
