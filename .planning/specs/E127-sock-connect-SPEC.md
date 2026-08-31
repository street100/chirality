---
element: E127
slug: sock-connect
title: Native `sock-connect` — lower `sock-connect : (=> Str ConnR)` to native TAL (client AF_UNIX socket()+connect(), sockaddr_un pack, ConnR sum). DEFERRED real-client-networking follow-on to E126 socketpair; error-path is the only hermetic conformance.
kind: BUILD-PROPER
example: examples/E127-sock-connect.md
status: audited
updated: 2026-08-12
---

# E127 SPEC — Native `sock-connect`

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

> **Deviation from the example §5 sketch (load-bearing, see Decision #1):** the
> example drew `nb-sock-connect` issuing raw `ti-sys 41` (socket) AND `ti-sys 42`
> (connect) inside one named body. That **cannot pass the E76 chokepoint** — a
> name maps to exactly one syscall number (`sys-check.chiral` `row-find` short-
> circuits on the first name match). This SPEC RESTRUCTURES into single-syscall
> helper bodies called via `ti-call`, the `nb-spawn-in-pty-t` / `nb-sock-send-t`
> precedent. The fused `nb-sock-connect` then issues **no** `ti-sys` and needs
> **no** sys-row; only the two new single-syscall helpers carry rows.

## 1. Deliverable

- **After this runs:** the surface crossing `sock-connect : (=> Str ConnR)`
  (`ports.chiral:63`) is lowered to native TAL — a fused `nb-sock-connect-t` body
  in `sys-tal.chiral` that acquires a client AF_UNIX stream socket
  (`socket(1,1,0)`), packs a `sockaddr_un` for the given path, `connect()`s, and
  hands back a `ConnR` boxed sum (`conn-r (1 s Sock)` / `conn-err (msg Str)`,
  `ports.chiral:38-40`) — routed by one `crossing-wraps` row and compiled with
  **zero** Python in the compile/run path. The connect-**error** path
  (`sock-connect "/nonexistent"` → `-errno` → `close(fd)` → `conn-err`) runs to a
  defined native exit under B1.
- **Non-goals:** the `conn-r` **success** path is verified-by-construction but
  **not driven** (needs a live listener — the server side `sock-listen`/
  `sock-accept` is out of scope, §6). No `sock-send`/`sock-recv` (E125, built),
  no abstract-namespace sockets, no numeric errno rendering (empty `Str`, §3
  Decision #4). No change to `ports.chiral` — `sock-connect`/`ConnR`/`Sock`
  already declared; this is pure lowering.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E127 postdates the map snapshot; treat as
  **BUILD**. Catalog build-state: "Not built — no `nb-sys-socket`/`nb-sys-connect`
  TAL (grep-clean); `sock-connect` is oracle-only (`_sockconnect`,
  `impl_ports.py:143-152`)."
- **Live code this composes with (do NOT respec):**
  - `ports.chiral:63` — surface `sock-connect : (=> Str ConnR)`; `ports.chiral:12`
    `porttype Sock`; `ports.chiral:38-40` `ConnR = (conn-r (1 s Sock)) |
    (conn-err (msg Str))`, tags `conn-r`=0 / `conn-err`=1.
  - `sys-tal.chiral:717-742` — `nb-sys-socketpair-t` (E126, committed): the FIRST
    hand-authored `ti-cona` boxed-sum-return body; `ti-bnew`/`ti-bptr` out-cell
    (:723-724), `(op-lti … 0)` split (:727), empty-`Str` error message via
    `ti-bnew` (:731), `ti-cona` on both arms. `ConnR` is structurally identical
    to `SpR` — the sum assembly is a direct copy.
  - `sys-tal.chiral:662-706` — `nb-spawn-in-pty-t`: the **fused multi-syscall**
    precedent that issues **zero** raw `ti-sys` and delegates every syscall via
    `ti-call` to single-syscall helpers (`nb-sys-fork`/`nb-sys-dup2`/
    `nb-sys-close`/…), and `close`-on-error at :704 (`ti-call "nb-sys-close"`).
  - `sys-tal.chiral:200-203` `nb-sys-close-t` (row `nb-sys-close`=3, `target-linux
    :15`); `sys-tal.chiral:208-211` `nb-sys-fcntl-t` — the value-in/rax-out,
    3-arg, no-cell single-syscall shape the two new helpers copy.
  - E123 porttype-carrier (committed afea68d): `term->ntalty` maps `Sock →
    nt-i64`, so the `Sock` field of `conn-r` lowers as a bare fd word — the same
    shape the E123 audit confirmed for `RecvR`/`AccR`.
  - `nb-copy` (used `sys-tal.chiral:820`) and `bput-u16-le` (E109) — the byte
    primitives the sockaddr_un packer reuses.
  - `crossing-wraps.chiral:13` `crossing-wraps` list; `sys-linkage.chiral:93`
    `sys-bindings = (cw->binds crossing-wraps)` auto-derives bindings from it;
    `sys-linkage.chiral:108` `checked-sys-lib = (ck-tiprog linux-syscalls sys-lib)`
    — the E76 chokepoint every `sys-lib` TIFn passes through.
- **True delta:** three new TAL bodies (two single-syscall helpers +
  one fused acquisition body) + two sockaddr_un byte helpers, all added to
  `sys-lib`; two `sys-row`s (`nb-sys-socket` 41, `nb-sys-connect` 42) in
  `target-linux.chiral`; one `crossing-wraps` row; one error-path sample + test.

## 3. Decisions

| # | Question | Disposition | Rationale / citation |
|---|----------|-------------|----------------------|
| 1 | **E76 for a fused two-syscall body** — can one name (`nb-sock-connect`) carry syscalls 41 AND 42 (AND 3 on the close arm)? | **RESOLVED → RESTRUCTURE into single-syscall helpers called via `ti-call`** | A name maps to **exactly one** number: `sys-check.chiral` `row-find` (:23-27) returns `(some rnum)` on the **first** matching `sys-row` and never accumulates a set; `ck-ti-code` (:51-59) walks the **whole** body (every `t-seq` instr + every `ti-tcase` branch + default) and checks **each** `ti-sys` via `ck-sys` (:33-39) against the fn's own name (`ck-tifn` :70). So a body with raw `ti-sys 41` and `ti-sys 42` under one name → the second mismatches the single registered number → `sbad`. Adding two rows for one name does not help (short-circuit takes the first). **Fix:** mint `nb-sys-socket-t` (`ti-sys …41`, its own row) + `nb-sys-connect-t` (`ti-sys …42`, its own row); `nb-sock-connect-t` calls all three syscalls (socket, connect, and `nb-sys-close` on the error arm) via `ti-call`, issues **no** `ti-sys`, and needs **no** sys-row. Precedent: `nb-spawn-in-pty-t` (`sys-tal.chiral:662-706`, zero ti-sys, all `ti-call`) and `nb-sock-send-t` (`:788`, comment: "Issues NO ti-sys (only ti-call) -> no E76 row"); each single-syscall helper carries its own row exactly as `nb-sock-send-go`→1 / `nb-sock-recv`→0 do (`target-linux.chiral:37-38`). |
| 2 | **sockaddr_un packing** — family u16=1 @ off 0 + path bytes @ off 2 + NUL; addrlen = 2+strlen+1 | **RESOLVED** | Allocate the cell with `ti-bnew` and hand its address to the kernel with `ti-bptr` — the exact out-cell shape of `nb-sys-socketpair-t` (`sys-tal.chiral:723-724`). Write the u16 family little-endian at offset 0 with `bput-u16-le` (E109), copy the path bytes at offset 2 with `nb-copy` (`sys-tal.chiral:820`), and the trailing NUL falls out of the zero-filled `ti-bnew`. **addrlen = tight `2 + strlen + 1`** (web-verified `unix(7)`: `offsetof(sun_path)=2 + strlen + 1`, counts the NUL) — canonical pathname-socket length. Factored as two pure byte helpers `nb-sa-un-pack`/`nb-sa-un-len` (reusable by the future `sock-listen` bind); they issue no `ti-sys` → no E76 rows. |
| 3 | **close-on-connect-error** — must `close(fd)` before `conn-err` (socket() allocated the fd) | **RESOLVED** | Oracle `_sockconnect` (`impl_ports.py:143-152`): on `OSError` it calls `s.close()` then returns `conn-err`. The connect-error arm calls `ti-call "nb-sys-close" (cons fd nil)` before assembling `(conn-err msg)` — matching the in-tree `nb-spawn-in-pty-t:704` `ti-call "nb-sys-close"` close-on-error precedent. The `conn-err` arm carries no `Sock`, so the fused body is the only place the fd exists before it becomes a `Sock`; not closing it leaks a descriptor (untypeable to catch downstream). |
| 4 | **errno rendering** in `conn-err` message | **DEFERRED** (shared E126 deferral) | `conn-err` carries `(msg Str)`; build an **empty** `Str` via `ti-bnew` — identical to `nb-sys-socketpair-t:731` `(sp-err msg)` empty-Str deferral. Numeric `-errno` → `Str` formatting is deferred with E126; `ConnR`'s shape is fixed at `(msg Str)` in `ports.chiral`, so no errno-field option without a surface-type change. Home: the shared "numeric errno render" residue. |
| 5 | **Error-path sample shape / exit convention** (example open-q #1) | **RESOLVED** | Sample `case`s the `ConnR`: `(conn-err m)` → native **exit 42** (the driven arm); `(conn-r s)` → consume the linear `Sock` via `sock-close` (E107, `crossing-wraps.chiral:39-41`) then exit 0. The `conn-r` arm is **compiled but unreached** and MUST be present — the QTT linear-usage check requires the `Sock` bound by `conn-r` to be consumed (reach `sock-close`), so a missing arm fails the checker, not just coverage. |

No NEEDS-AUTHOR; `status: draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — two single-syscall helper crossings + their E76 rows
- **Target:** `scaffold/lib/sys-tal.chiral` (near the socketpair block, ~:717) —
  add `nb-sys-socket-t` and `nb-sys-connect-t`; add both to `sys-lib` (:831).
  `scaffold/lib/target-linux.chiral` (:13-47 registry) — add rows.
- **Change:** value-in/rax-out helpers mirroring `nb-sys-fcntl-t` (:208-211):
  `(def nb-sys-socket-t TIFn (ti-fn "nb-sys-socket" 3 4 (t-seq (ti-sys 3 41 (cons 0 (cons 1 (cons 2 nil)))) (ti-ret 3))))`
  and `(def nb-sys-connect-t TIFn (ti-fn "nb-sys-connect" 3 4 (t-seq (ti-sys 3 42 (cons 0 (cons 1 (cons 2 nil)))) (ti-ret 3))))`.
  Rows: `(cons (sys-row "nb-sys-socket" 41) …)` and `(cons (sys-row "nb-sys-connect" 42) …)`.
- **Size:** ~S

### Step 2 — the sockaddr_un byte helpers
- **Target:** `scaffold/lib/sys-tal.chiral` — add `nb-sa-un-pack-t` and
  `nb-sa-un-len-t`; add both to `sys-lib`.
- **Change:** `nb-sa-un-len(path-cell)` = `(op-add (blen path) 3)` (2 + strlen + 1).
  `nb-sa-un-pack(path-cell)` = `ti-bnew` a `(len)`-byte cell, `bput-u16-le 1` at
  offset 0, `nb-copy` the path bytes to offset 2 (NUL from the zero fill), return
  the cell. Pure byte ops — no `ti-sys`, no E76 row.
- **Size:** ~S/M

### Step 3 — the fused `nb-sock-connect-t` body + routing
- **Target:** `scaffold/lib/sys-tal.chiral` — add `nb-sock-connect-t`; add to
  `sys-lib`. `scaffold/lib/crossing-wraps.chiral` (:13) — add the routing row.
- **Change:** fused body issuing **no** `ti-sys` (all via `ti-call`):
  `ti-call "nb-sys-socket" (cons AF (cons ST (cons 0 nil)))` → `(op-lti fd 0)` split:
  true → `ti-cona 1` empty-Str `conn-err`; false → `ti-call "nb-sa-un-pack"` /
  `nb-sa-un-len`, `ti-call "nb-sys-connect" (cons fd (cons saptr (cons salen nil)))`
  → `(op-lti r 0)` split: true → `ti-call "nb-sys-close" (cons fd nil)` then
  `ti-cona 1` `conn-err`; false → `ti-cona 0 (cons fd nil)` `(conn-r fd)` (fd word
  IS a `Sock`, E123). Copy the two-level `ti-tcase`/`ti-cona` shape from
  `nb-sys-socketpair-t:717-742` and the fused/`ti-call` shape from
  `nb-spawn-in-pty-t:662-706`. Crossing-wraps: `(cons (pair "sock-connect" "nb-sock-connect") …)`.
- **Size:** ~M

### Step 4 — the error-path sample + test + self-hosting gate
- **Target:** `scaffold/tests/` (new `test_e127_sock_connect.py` mirroring
  `test_e106_linear_cap.py`) + a sample `.chiral` driving the error path.
- **Change:** sample `case (sock-connect "/nonexistent/path")` → `(conn-err m)`
  exit 42; `(conn-r s)` → `sock-close s`; exit 0 (unreached). B1-compile, run,
  assert exit 42. Assert the **old** B1 (pre-crossing-wraps-row) fails to compile
  it (no `sock-connect` binding → unresolved crossing) — the discriminator.
  Then the reblob-`cmp` self-hosting gate (compiler's own stdlib sources changed).
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** `sock-connect "/nonexistent/path"` on-target →
  `socket(1,1,0)` succeeds (fd≥0) → `connect` returns `-ENOENT`/`-ECONNREFUSED` →
  `(op-lti r 0)` fires → `ti-call "nb-sys-close"` releases the fd →
  `(conn-err msg)` assembles via `ti-cona` (tag 1) → the sample `case`s it →
  **native exit 42**. Both `socket` and `connect` run on-target; the `-errno`
  decode fires; the `ConnR` sum is built and cased — with zero Python in the
  compile/run path. The `conn-r` success arm is verified-by-construction
  (compiled, linearly consumes its `Sock` via `sock-close`) but **not driven**
  (needs a live listener — deferred server side).
- **Tests to add:** `test_e127_sock_connect.py` — (1) B1 compiles the sample and
  it runs to exit 42 (native floor); (2) **discriminator**: the pre-row B1 fails
  to resolve `sock-connect` (no `crossing-wraps` row) → old floor cannot build
  it; (3) the E76 chokepoint `checked-sys-lib` stays `sok` with the two new rows
  (guards Decision #1 — a regression to raw-fused would go `sbad`).
- **Green line:** 704 → ≥ 707 test functions; `ck-tiprog linux-syscalls sys-lib`
  = `sok`; ledger-lint clean; reblob-`cmp` byte-identical (B1-compiling-B1 over
  the changed stdlib blob).
- **Done when:** the error-path sample compiles under the new B1 and runs to
  exit 42, the pre-row B1 cannot build it, the E76 chokepoint is green, and the
  promoted binary reproduces itself byte-for-byte over the blob.

## 6. Residue & links

- **Deliberately unbuilt:**
  - `conn-r` **success-path drive** — needs `sock-listen`/`sock-accept` (the
    server side: bind+listen+accept crossing set). Home: a future server-side
    element (sibling of E127).
  - **Numeric errno → `Str`** in `conn-err` — empty `Str` for now; home: the
    shared E126 "errno render" deferral.
  - **Abstract-namespace sockets** (leading-NUL `sun_path`) — would change the
    packer + len; home: none yet.
- **Follow-on:** the built `Sock` lifecycle (E123 carrier / E124 `adopt-fd` /
  E107 `sock-close`) is already exercisable natively via `socketpair` (E126); the
  server side unblocks E127's success-path drive; E106 `sv-drain` milestone is
  gated by socketpair (E126), **not** this element.
- **Related:** [[E127-sock-connect]] · [[E29-socket-ports]] (the oracle surface
  natived) · [[E126-socketpair]] (the committed `ti-cona` boxed-sum precedent +
  the actual `sv-drain` gate) · [[E123-porttype-carrier]] (the `Sock`-field
  lowering) · [[E124-adopt-fd]] · [[E107-cap-close]] · [[E109-bput-u16-le]] ·
  [[E110-cloexec-pty]] · [[E121-fcntl]] (sibling crossing rows).
