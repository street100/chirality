---
element: E125
slug: sock-use
title: Native `sock-send`/`sock-recv` (the socket "use" stage): lower `sock-send : (=> (1 s Sock) Bytes SendR)` and `sock-recv : (=> (1 s Sock) (refine I64 (>0)) RecvR)` — hand-authored TAL bodies over the existing `nb-sys-write`/`nb-sys-read`, each threading the `Sock` cap back and building its result sum via `ti-cona` (the E126 socketpair pattern — boxed-sum-returning crossing). `sock-send`: write the Bytes, assemble `SendR` (sent count / err) with the Sock re-threaded. `sock-recv`: read up to N into a fresh cell, assemble `RecvR` — `recv-ok`(bytes, Sock) / `recv-closed`(Sock, on 0 bytes = peer half-close) / `recv-err`. The `Sock` fields lower via E123's carrier. crossing-wraps rows + the two bodies in `sys-lib`. **Scope: send/recv only**; `sock-send-fd` (SCM_RIGHTS, `nb-sys-send-fd-t` already exists) is a follow-on
kind: BUILD-PROPER
example: examples/E125-sock-use.md
status: audited
updated: 2026-08-12
---

# E125 SPEC — Native `sock-send`/`sock-recv` (the socket "use" stage)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a chirality program holding a `Sock` (from E126 `socketpair`)
  can move bytes over it with **zero CPython in the loop** — `sock-send` and
  `sock-recv` lower to hand-authored TAL in `sys-lib`, so the hermetic round-trip
  `socketpair → sock-send a "hi" → sock-recv b 8 → "hi"` compiles under B1 and
  runs native. `sock-send` implements **full `sendall`** (loops until every byte
  is gone, then re-threads the `Sock` in `send-r`); `sock-recv` does one `read`
  into a fresh cell truncated to the actual count, splitting three ways
  (`recv-err` / `recv-closed` / `recv-r`).
- **Non-goals:** `sock-send-fd` (SCM_RIGHTS — `nb-sys-send-fd-t` already exists,
  a separate follow-on), `sock-accept`/`sock-connect`/`poll2`, and any
  numeric-errno→`Str` rendering (err arms carry an empty `Str`; §3 decision 3).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** BUILD (E125 postdates the map snapshot — no rows).
  The catalog row is authoritative: `sock-send`/`sock-recv` are **oracle-only**
  (`impl_ports.py` `_socksend:186`, `_sockrecv:210`); the target types and
  crossings already exist; only the native lowering is missing.
- **Live code this composes with (do NOT respec):**
  - **Result sums** — `SendR = (send-r (1 s Sock)) | (send-err (msg Str))`
    (`ports.chiral:51-53`, **no count field**); `RecvR = (recv-r (bs Bytes)
    (1 sock Sock)) | (recv-closed (1 sock Sock)) | (recv-err (msg Str))`
    (`ports.chiral:28-31`). `recv-err` carries **no** `Sock` (cap already
    consumed on error — documented `lincoll.chiral:89`).
  - **The externs** — `sock-send` (`ports.chiral:70`), `sock-recv`
    (`ports.chiral:72`). Real downstream users already call them:
    `lincoll.chiral:86` (`sock-recv s 4096`), `secret.chiral:56` (`sock-send s bs`).
  - **The two raw crossings** — `nb-sys-write-t` (nr 1, `sys-tal.chiral:18`),
    `nb-sys-read-t` (nr 0, with the truncate-to-`r`-via-`nb-copy` idiom,
    `sys-tal.chiral:39-57`). The syscall **numbers** 0/1 are used by existing
    registered crossings, but **E76 is name-keyed default-deny, not
    number-keyed**: `ck-sys` looks up the *issuing function's own name* in the
    `SysReg` and rejects any unregistered name, then checks its `ti-sys` number
    matches that name's row (`sys-check.chiral:7-9,33-39`; `ck-tifn` keys by the
    fn's name, `:70`). So a NEW crossing that issues `ti-sys 0`/`ti-sys 1` needs
    its **own** `sys-row` even though it reuses an existing number — exactly as
    `nb-read-key` gets its own row for read's nr 0, `nb-sys-open-rw` its own for
    openat's 257, and the whole ioctl family (`nb-sys-winsz`/`tcgets`/`ptsno`/…)
    each get their own row for nr 16 (`target-linux.chiral:11-40`). §4 adds the
    two rows accordingly.
  - **The ti-cona boxed-sum precedent** — `nb-sys-socketpair-t`
    (`sys-tal.chiral:717-742`): run syscall → `op-lti r 0` → `ti-tcase` whose
    arms each `ti-cona` one constructor. **Tag convention confirmed:** the
    tcase branch tag selects the boolean outcome (tag0 = the TRUE arm), while
    the `ti-cona` tag is the constructor index in the `data` decl — the two are
    independent (socketpair's true/tag0 error arm builds `ti-cona _ 1` = sp-err;
    the false/tag1 arm builds `ti-cona _ 0` = sp-ok).
  - **The recursion mechanism** (the crux enabler) — `nb-bfind-from-t`
    (`bytes-tal.chiral:302-327`) is a genuine **self-recursive** worker: it
    tail-calls `nb-bfind-from` with an `op-add`-incremented offset (line
    313-318); `emit-core.chiral:417` recognizes `(t-seq (ti-call dst f args)
    (ti-ret dst))` as a tail call. `op-add`/`op-sub` exist (`prelude.chiral:27`).
  - **The routing table** — `crossing-wraps` (`crossing-wraps.chiral:13`), a flat
    `(op → wrapper)` list. `sys-bindings` is **derived** from it via `cw->binds`
    (`sys-linkage.chiral:91-93`) — no hand-mirroring (see §3 decision 5, a FIX).
- **True delta:** three hand-authored TAL bodies (a recursive `sendall` worker +
  the two entry crossings) added to `sys-lib`, plus two `crossing-wraps` rows
  **and two name-keyed `sys-row`s in `target-linux.chiral` `linux-syscalls`**
  (`nb-sock-send-go`→1, `nb-sock-recv`→0 — E76 is name-keyed, so the ti-sys-
  issuing bodies must register even reusing existing numbers). No new syscall
  *numbers*, no `scaffold/chirality/*.py`, no python-reference-machine work
  (write/read already agree by construction), no type changes.

## 3. Decisions

Every open question from the example §6, dispositioned. FIX applied to the
change plan where the example was stale; author-tier design surfaced, never
silently resolved.

| # | Question | Disposition | Rationale / citation |
|---|----------|-------------|----------------------|
| 1 | **Partial writes** — `SendR` has no count, so `send-r` contractually asserts "ALL bytes sent"; a single `write` moving `<len` then returning `send-r` is a silent data-loss lie. sendall or single-write-v1? | **RESOLVED → full `sendall` (loop)** | A bounded loop **is** expressible in hand-authored TAL: bodies recurse via `ti-call` to a named label (`nb-bfind-from-t` self-recurses with an `op-add` offset, `bytes-tal.chiral:313-318`; tail-call at `emit-core.chiral:417`), and `op-add`/`op-sub` give the `ptr+off` / `len-off` arithmetic (`prelude.chiral:27`). So a recursive worker `nb-sock-send-go(fd, ptr, len, off)` issuing `ti-sys 1 (fd, ptr+off, len-off)` (a name-keyed E76 registration — §2, §4) and recursing on a short write realizes true `sendall`, matching the oracle (`_socksend` uses `sendall`, `impl_ports.py:186`). Size stays S–M. **Termination:** the measure `len-off` strictly decreases whenever `write` returns `>0`; on a blocking stream socket `write` returns `>0` or `<0` (never 0 for `len>0`). This is a hand-authored **sys-face** body (raw TAL, not totality-checked), so no measure proof is machinery-required — the assumption is documented in the body comment, honestly named. |
| 2 | **`recv-r` cell truncation** — return the full n-byte `bnew` cell, or copy down to the actual `r` bytes? | **RESOLVED → truncate to `r` via `nb-copy`** | Mirror `nb-sys-read-t` exactly (`sys-tal.chiral:48-50`): on `r>0`, `ti-bnew` a fresh `r`-length cell and `nb-copy` the payload down, so `blen bs == r` for callers. Honest cost (a second cell) until cells can shrink — the same tradeoff read already takes. |
| 3 | **errno rendering** — the err arms' `Str` message. | **DEFERRED → shared E126 §3.3** | `send-err`/`recv-err` carry an **empty `Str`** now (`ti-bnew` of length 0), identical to `nb-sys-socketpair-t`'s `sp-err` (`sys-tal.chiral:730-732`). When numeric-errno→`Str` lands (the deferral shared with E126), both err arms adopt it — no type change needed then (the `Str` field already exists). |
| 4 | **`SendR` countless shape** — confirm `(send-r (1 s Sock)) \| (send-err (msg Str))` (no count) is final. | **RESOLVED → confirmed final; not E125's to change** | The type already exists (`ports.chiral:52-53`) and decision 1 makes the countless shape **correct**: `sendall` is all-or-error, so there is no partial count to report — `send-r` re-threads only the `Sock`. Any count field would be dead. Type edits are out of scope. |
| 5 | **(FIX) sys-linkage mirror rows** — the example §5/§6 says "add the mirror rows in `sys-linkage` `sys-bindings` (INVARIANT: agree)". | **FIX → no manual mirror; `crossing-wraps` rows only** | `sys-bindings` is **derived** from `crossing-wraps` via `cw->binds` (`sys-linkage.chiral:91-93`) precisely so the two cannot drift — hand-mirroring would be wrong. Only `crossing-wraps.chiral` gets the two rows; the change plan reflects this (the example's instruction is stale). |

No NEEDS-AUTHOR. `status: draft` — unblocked.

## 4. Change plan (ordered, commit-sized)

### Step 1 — `sock-send` lowering (recursive sendall)
- **Target:** `scaffold/lib/sys-tal.chiral` (`sys-lib` at `:744`) +
  `scaffold/lib/crossing-wraps.chiral` (`:13`) +
  `scaffold/lib/target-linux.chiral` (`linux-syscalls` at `:11`).
- **Change:**
  1. Add **`nb-sock-send-go-t`** — a self-recursive worker
     `nb-sock-send-go(fd, ptr, len, off)`: `rem = op-sub len off`; if
     `rem <= 0` → `(ti-cona _ 0 (cons fd nil))` = `send-r` (tag0, re-thread the
     fd word) and return; else `cur = op-add ptr off`, `r = ti-sys _ 1 (fd, cur,
     rem)` (raw `write` on the computed slice — reuses nr 1),
     `op-lti r 0` → true-arm builds `(ti-cona _ 1 (cons emptyStr nil))` =
     `send-err` (tag1, drop the cap), false-arm tail-recurses
     `nb-sock-send-go(fd, ptr, len, op-add off r)`. Spine copied from
     `nb-bfind-from-t` (`bytes-tal.chiral:302-327`); ti-cona shell from
     `nb-sys-socketpair-t`.
  2. Add **`nb-sock-send-t`** — the 2-param entry `nb-sock-send(sock, bytes)`:
     `ti-bptr` + `ti-blen` the Bytes arg, seed `off = 0` (`ti-const`), tail-call
     `nb-sock-send-go(fd=reg0, ptr, len, 0)` (the `nb-bfind`→`nb-bfind-from`
     seed pattern, `bytes-tal.chiral:329-333`). The entry issues no `ti-sys`
     (only a `ti-call`), so it needs no `sys-row`.
  3. Register both in `sys-lib` (`:744`).
  4. **Add the E76 row** `(sys-row "nb-sock-send-go" 1)` to `linux-syscalls`
     (`target-linux.chiral:11`) — the worker issues `ti-sys 1`, so E76's
     name-keyed default-deny requires its own row (§2).
  5. Add `(cons (pair "sock-send" "nb-sock-send")` to `crossing-wraps`
     (next to the E126/E107 socket rows, `:35`).
- **Test:** a native send-side smoke (write into one half of a socketpair,
  observe `send-r`, close both) — or fold into Step 2's round-trip if leaner.
- **Size:** ~M (one recursive worker + one thin entry + one row).

### Step 2 — `sock-recv` lowering (three-way split)
- **Target:** `scaffold/lib/sys-tal.chiral` (`sys-lib`) +
  `scaffold/lib/crossing-wraps.chiral` +
  `scaffold/lib/target-linux.chiral` (`linux-syscalls`).
- **Change:**
  1. Add **`nb-sock-recv-t`** — `nb-sock-recv(sock, n)`: `ti-bnew` an n-byte
     cell, `ti-bptr` it, `r = ti-sys _ 0 (fd=reg0, ptr, n)` (raw `read`, nr 0).
     **Add the E76 row** `(sys-row "nb-sock-recv" 0)` to `linux-syscalls`
     (`target-linux.chiral`) — this body issues `ti-sys 0`, so it needs its own
     name-keyed row (§2). **Nested `ti-tcase`** for the three-way split:
     `op-lti r 0` → true → `(ti-cona _ 2 (cons emptyStr nil))` = `recv-err`
     (tag2, drop cap); false-arm tests `op-lti 0 r` → false (`r==0`) →
     `(ti-cona _ 1 (cons fd nil))` = `recv-closed` (tag1, re-thread fd);
     true (`r>0`) → truncate to `r` via `ti-bnew`+`nb-copy` (per
     `nb-sys-read-t`, `sys-tal.chiral:48-50`) → `(ti-cona _ 0 (cons cell
     (cons fd nil)))` = `recv-r` (tag0). The nested tcase is the one structural
     step beyond socketpair's two-way (both precedents: `nb-sys-read-t`,
     `nb-spawn-in-pty-t`).
  2. Register in `sys-lib`; add `(cons (pair "sock-recv" "nb-sock-recv")` to
     `crossing-wraps`.
- **Test:** the hermetic round-trip + the linear negative (§5).
- **Size:** ~M (one body with a nested tcase + one row).

### Step 3 — reblob + self-host byte-compare
- **Target:** the blob (`sys-tal.chiral` + `crossing-wraps.chiral` are
  blob-resident compiler sources).
- **Change:** rebuild `chirality-bin.new` from the blob (`./build.sh`), test it, promote;
  then run the promoted binary over the same blob once more and `cmp` — it must
  reproduce itself byte-for-byte (the self-hosting fixpoint, since the
  compiler's OWN sources changed).
- **Size:** ~S (ceremony, no new authoring).

## 5. Conformance gate

- **Golden behavior — hermetic send/recv round-trip (no peer, no network):**
  ```
  socketpair Unit → (sp-ok a b)
    → sock-send a "hi"  → (send-r a)     ; full sendall of both bytes
    → sock-recv b 8     → (recv-r bs b)  ; one read, truncated to 2
    → check (bytes->str bs) == "hi"
    → sock-close a → sock-close b        ; each cap consumed exactly once
    → native exit 42
  ```
  A genuine kernel `write`+`read` over an AF_UNIX `SOCK_STREAM` pair, entirely
  in-process, B1-compiled and exiting 42. **DISCRIMINATING:** the old B1 (pre-
  lowering) fails this — `sock-send`/`sock-recv` have no `crossing-wraps` row, so
  the crossing is unresolved and the program does not compile/link.
- **Linear negative:** a program that uses a `Sock` after `sock-send` **without
  threading the returned one** (e.g. `(sock-send s "x") ; sock-send s "y"`
  reusing `s`) must be **rejected by the checker** — the cap was consumed by the
  first send and `send-r`'s fresh `Sock` was dropped. A compile-fail assertion
  (the linear discipline is the point, `ports.chiral:52` `(1 s Sock)`).
- **Tests to add:** a native round-trip test (extend `tests/test_sockets.py`, or
  a `samples/` program the native floor runs) comparing the **native** floor's
  exit code (42) against the expected; a linear-negative compile-fail case.
  `test_e76_chokepoint.py` must reflect the **two new registered crossings**
  (`nb-sock-send-go`→1, `nb-sock-recv`→0): the rows are added to
  `linux-syscalls` (§4) so `checked-sys-lib` stays `sok` (E76 is name-keyed
  default-deny — without the rows the new ti-sys-issuing bodies would be
  rejected). Update any manifest assertion that enumerates the registered set;
  no ti-sys number is re-pointed, so the name↔number rule still holds.
- **Gate gap — the sendall loop is NOT exercised by the 2-byte round-trip:**
  a `"hi"` payload is one `write` (rem 2 → write 2 → rem 0 → `send-r`), so the
  short-write recursion (decision 1's crux) never fires. The happy-path gate
  proves recv end-to-end + send's success + linearity, but not the loop. A
  discriminating loop test would send a payload larger than the socketpair send
  buffer to force a partial write and drive the recursion (author-tier: whether
  to add it and how to size it reliably — see FLAG).
- **Green line:** 704 test functions → ≥ 706 (round-trip + linear negative);
  E76 chokepoint green; `tools/ledger-lint/ledger-lint.py` clean.
- **Done when:** the native round-trip exits 42, the linear-negative program is
  rejected, and the promoted binary reproduces itself byte-identically over the
  reblobbed sources (`cmp` clean).

## 6. Residue & links

- **Deliberately unbuilt:**
  - **errno→`Str` rendering** — empty `Str` err arms now; home = the shared E126
    §3.3 numeric-errno deferral (adopt when it lands, no type change).
  - **`sock-send-fd`** (SCM_RIGHTS) — `nb-sys-send-fd-t` already exists
    (`sys-tal.chiral:366`); the wrapper/wire-up is a separate follow-on element.
  - **A totality-proved sendall** — the worker's `len-off` measure is documented,
    not machine-checked (sys-face raw TAL is outside the totality checker); home
    = a future "totality for hand-authored crossings" edge if ever wanted.
- **Follow-on:** unblocks native `secret.chiral`/`lincoll.chiral` (real
  `sock-send`/`sock-recv` callers) and E127 `sock-connect` (the connected-stream
  leg that reuses this use-stage over a non-socketpair `Sock`).
- **Related:** [[E125-sock-use]], [[E126-socketpair]] (the committed `ti-cona`
  precedent + the hermetic pair this round-trips over), [[E127-sock-connect]],
  [[E123]] (fd word-carrier), [[E107]] (`sock-close`, the release leg),
  [[E30]] (result sums thread the cap back linearly).
