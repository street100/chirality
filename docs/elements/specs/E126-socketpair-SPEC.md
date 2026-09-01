---
element: E126
slug: socketpair
title: Native `socketpair` — surface `socketpair : (=> Unit SockPairR)` extern + `SockPairR` sum, lowered via a `nb-sys-socketpair` TAL body (nr 53)
kind: BUILD-PROPER
example: examples/E126-socketpair.md
status: audited
updated: 2026-08-12
---

# E126 SPEC — Native `socketpair`

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a surface `socketpair : (=> Unit SockPairR)` extern exists
  in `ports.chiral` with a new `SockPairR = (sp-ok (1 a Sock) (1 b Sock)) |
  (sp-err (msg Str))` result type; it lowers through a hand-authored
  `nb-sys-socketpair-t` TAL body in `sys-tal.chiral` that issues
  `socketpair(AF_UNIX=1, SOCK_STREAM=1, 0, sv)` (nr 53) into an alloc-inside
  8-byte out-cell, reads the two u32 fds, and constructs `(sp-ok fd0 fd1)`
  in-body (or `(sp-err msg)` on `-errno`). Two REAL connected native `Sock` caps
  come back, no listener/peer/network. A hermetic sample drives
  `socketpair → sv-push a (sv-push b sv-nil) → sv-drain → native exit 42`.
- **Non-goals:** no `sockaddr` packing (socketpair takes no address);
  no `SOCK_CLOEXEC|SOCK_NONBLOCK` type flags (later knob); no send/recv
  round-trip over the pair before draining; no precise numeric errno→`Str`
  rendering (fixed literal message this run — see §3.3 / §6); no `sock-connect`
  (the non-hermetic sibling, DEFERRED E127).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no rows name E126 (postdates the map snapshot) —
  treat as **BUILD**. Grep-clean: no surface `socketpair` extern or
  `nb-sys-socketpair` TAL body exists; `socketpair` currently lives only inside
  the Python oracle spawn (`impl_ports.py:126`), which this run does not touch.
- **Live code this composes with (do NOT respec):**
  - `Sock` porttype — opaque linear cap, E123 carrier lowers the field to the raw
    fd word so **inside TAL a `Sock` *is* just the `int` fd** (`ports.chiral:12`).
  - Result-sum precedents `ConnR` (one cap, error arm) / `AccR`
    (`ports.chiral:35,38`) — the "error folds into the value" shape SockPairR copies.
  - `Poll2R = (poll2-r (idx I64) (1 a Sock) (1 b Sock))` (`ports.chiral:33`) — two
    Socks already lower cleanly (E123), but wrong semantics (see §3.2).
  - Alloc-inside out-cell idiom — `nb-sys-winsz-t` (`sys-tal.chiral:475`),
    `nb-sys-ptsno-t` (`:601`): `ti-const len; ti-bnew cell; ti-bptr payload;
    ti-sys …; (op-lti r 0)` split with an error/success `ti-tcase`.
  - `ti-cona (dst) (tag) (fields)` — the boxed-constructor TAL op, "pointer to
    fresh cell `[tag][fields]`" (`tal-ir.chiral:23`); tags are declaration order.
    This is what lets the body build `sp-ok`/`sp-err` directly. **First-of-kind
    note (honest baseline):** `ti-cona` is a real, emit-supported IR op — the
    lowering pipeline reifies `n-cona → ti-cona` (`tal-reify.chiral:29`) and the
    backend emits it as an `alo`/`alo-cell` allocation (`emit-core.chiral:151`) —
    but **no existing hand-authored TAL body in `scaffold/lib/` constructs a con
    with it** (every current producer is the pure-lowering path), and **no native
    crossing returns a boxed sum today**: the port-carrying sum externs
    (`ConnR`/`AccR`/`Poll2R`) have *no* `crossing-wraps` rows (oracle-only,
    `impl_ports.py`); all native crossings return `I64`/`Bytes`/`Unit`. So the
    op + emit support exist, but `nb-sys-socketpair-t` is the **first
    hand-authored body to build a con** and the **first native crossing to return
    a boxed port-carrying sum**. The milestone gate (§5) is what first exercises
    this path end-to-end.
  - `nb-unpack32-t` (`bytes-tal.chiral:172`) — the TAL-floor u32 LE read (4
    `ti-bget` byte reads + `*256` fold); reachable from a sys-tal body by
    cross-lib `ti-call`, exactly as `nb-read-key-t` calls `nb-copy`
    (`sys-tal.chiral:554`).
  - `SockVec` / `sv-nil` / `sv-push` / `sv-drain` linear-collection lifecycle
    (`lincoll.chiral:26,31,67`) — the drain end that closes each held cap exactly
    once (E123/E124/E107).
  - `crossing-wraps` routing table + auto-derived `sys-linkage`
    (`crossing-wraps.chiral:13`, header invariant); `target-linux.chiral`
    `linux-syscalls` SysReg (`:11`).
- **True delta:** one new surface type + one new extern + one hand-authored TAL
  body (with an in-body two-u32 read and a tagged-sum construction) + one
  crossing-wraps row + one target-linux row + one sample. **No new IR ops and no
  new emit/carrier machinery** — `ti-cona`, cross-lib `ti-call`, `ti-bnew`/`ti-bptr`
  out-cells, and `ti-sys` are all present and backend-supported. The novelty is
  *usage*, not machinery: this is the first hand-authored TAL body to construct a
  con and the first native crossing to return a boxed port-carrying sum (see the
  first-of-kind note above), so the milestone gate carries the burden of proving
  the hand-authored `ti-cona` crossing works, not just that the extern type-checks.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Exact primitive/index for the two u32 fd reads | **RESOLVED** | Reuse `nb-unpack32` via cross-lib `ti-call`; offsets 0 and 4 |
| 2 | New `SockPairR` vs reuse `Poll2R` | **RESOLVED** | New `SockPairR` — `Poll2R` has an extra `idx` and no error arm |
| 3 | errno decode into the error arm | **RESOLVED** (numeric rendering DEFERRED) | `(op-lti r 0)` → `(sp-err msg)`, msg a fixed literal this run |
| 4 | `ti-fn` arity / temp budget | **RESOLVED** | `0` params, `nregs 14` from the concrete register assignment |

### 3.1 — Reading the two u32 fds (RESOLVED)

`ti-bget` reads **one byte** (`tal-ir.chiral:27`, "dst := one byte of the cell";
`idx` is a byte offset), so it alone cannot read a u32. **Honest correction to
the example's citation:** `nb-sys-ptsno-t` does **not** read its u32 in-body — it
returns the whole raw cell to the surface (`ti-ret 2`, `sys-tal.chiral:616`) and
the surface decodes it. It is the out-cell *allocation* precedent, not an
in-body-read precedent. The real in-body u32 read is `nb-unpack32-t`
(`bytes-tal.chiral:172`): four `ti-bget` byte reads at `base..base+3` reassembled
`b0 + 256*(b1 + 256*(b2 + 256*b3))` (little-endian, x86-64 native).

**Resolution:** inside `nb-sys-socketpair-t`, after the syscall succeeds, read
the two fds with two cross-lib calls
`ti-call fd0 "nb-unpack32" (cons cell (cons off0 nil))` (off0 = const 0) and
`ti-call fd1 "nb-unpack32" (cons cell (cons off4 nil))` (off4 = const 4), passing
the **boxed** out-cell reg (the `ti-bnew` result, as `nb-run-elf-t`'s
`ti-bget 8 5 7` reads the boxed cell, not the `ti-bptr` payload). Cross-lib
sys-tal→bytes-tal `ti-call` is precedented by `nb-read-key-t` calling `nb-copy`
(`sys-tal.chiral:554`; `nb-copy-t`/`nb-unpack32-t` both in the bytes lib list,
`bytes-tal.chiral:585-587`). Each returned fd word IS a `Sock` at the boundary
(E123 carrier), so no conversion is needed before it flows into `ti-cona`.

### 3.2 — `SockPairR` new vs reuse (RESOLVED: NEW)

New `SockPairR = (sp-ok (1 a Sock) (1 b Sock)) | (sp-err (msg Str))`.
`Poll2R = (poll2-r (idx I64) (1 a Sock) (1 b Sock))` (`ports.chiral:33`) is the
only two-Sock carrier, but it (a) carries an extra `idx I64` socketpair has no
use for and (b) has **no error arm** — socketpair must express `-errno` as a
value. A purpose-built two-arm sum is cleaner and mirrors `ConnR`/`AccR`
(`ports.chiral:35,38`), the built error-carrying result shape. Tags follow
declaration order: `sp-ok` = tag 0, `sp-err` = tag 1.

### 3.3 — errno decode (RESOLVED; numeric rendering DEFERRED)

Control flow mirrors the alloc-inside precedent: `ti-const 0; ti-prim (op-lti) r
0` splits on `r < 0`. Bool `true` = tag 0, so **tag0 = ERROR**, **tag1 = OK**
(identical to `nb-sys-ptsno-t`/`nb-sys-winsz-t`). The error arm builds
`(sp-err msg)` via `ti-cona errtag 1 (cons msg nil)`. `SockPairR` has **no errno
field** — same as `ConnR` (`ports.chiral:38`) — so the numeric errno is not
surfaced structurally. This run uses a **fixed literal** message via `ti-lit`
(e.g. `"socketpair failed"`); rendering the actual `-errno` number into the
string (via `nb-digits`, `bytes-tal.chiral:206`, + concat) is **DEFERRED** to the
shared `*-err` boundary helper the example flags as deliberately omitted (§6) —
it belongs to whichever element first standardizes errno→`Str` across the socket
crossings, not here.

### 3.4 — `ti-fn` arity / temp budget (RESOLVED)

`(=> Unit …)` ⇒ **0 params** (mirror `nb-sys-setsid-t`, `sys-tal.chiral:570`,
`ti-fn "nb-sys-setsid" 0 1`). Concrete register assignment (see §4 Step 2) tops
out at r13, so **`nregs = 14`**. Comparable multi-temp tcase bodies:
`nb-run-elf-t` (`1 11`, `sys-tal.chiral:451`) and `nb-spawn-in-pty-t` (`2 8`,
`:663`). The example sketched `0 12`; the accurate count is 14 (the two
`nb-unpack32` calls + the two offset consts + the two `ti-cona` results push it
up). Register reuse could trim it, but 14 is the safe upper bound covering every
assigned index; the executor may lower it only if the max assigned reg drops.

## 4. Change plan (ordered, commit-sized)

### Step 1 — surface type + extern (`ports.chiral`)
- **Target:** `scaffold/lib/ports.chiral` — near the socket result sums (`:28–64`).
- **Change:** add
  `(data SockPairR () (sp-ok (1 a Sock) (1 b Sock)) (sp-err (msg Str)))` and
  `(extern socketpair (=> Unit SockPairR))`. Linear `1` binders on the two caps;
  `=>` because it crosses the process membrane.
- **Size:** ~S

### Step 2 — the TAL crossing body (`sys-tal.chiral`)
- **Target:** `scaffold/lib/sys-tal.chiral` — new `def nb-sys-socketpair-t`, and
  cons it into `sys-lib` (`:708–719`).
- **Change:** author the body, `ti-fn "nb-sys-socketpair" 0 14`. Register plan:
  - `r0 = ti-const 1` (AF_UNIX), `r1 = ti-const 1` (SOCK_STREAM),
    `r2 = ti-const 0` (protocol), `r3 = ti-const 8` (out-cell len slot).
  - `r4 = ti-bnew r3` (boxed 8-byte out-cell), `r5 = ti-bptr r4` (payload ptr).
  - `r6 = ti-sys 53 (cons 0 (cons 1 (cons 2 (cons 5 nil))))` — args land
    rdi=family, rsi=type, rdx=protocol, **r10=sv** (positional 4th).
  - `r7 = ti-const 0`, `r8 = ti-prim (op-lti) r6 r7` (r < 0 ?).
  - `ti-tcase r8 false`:
    - **tag0 (ERROR):** `r9 = ti-lit <"socketpair failed">`;
      `r10 = ti-cona 1 (cons 9 nil)`; `ti-ret 10`.
    - **tag1 (OK):** `r9 = ti-const 0`;
      `r10 = ti-call "nb-unpack32" (cons 4 (cons 9 nil))` (fd0);
      `r11 = ti-const 4`;
      `r12 = ti-call "nb-unpack32" (cons 4 (cons 11 nil))` (fd1);
      `r13 = ti-cona 0 (cons 10 (cons 12 nil))` (sp-ok); `ti-ret 13`.
  - Note the OK arm passes the **boxed cell `r4`** (not payload `r5`) to
    `nb-unpack32`, matching `nb-run-elf-t`'s boxed-cell `ti-bget`.
- **Size:** ~M

### Step 3 — crossing-wraps + target-linux rows
- **Target:** `scaffold/lib/crossing-wraps.chiral` (`crossing-wraps` list, `:13`)
  and `scaffold/lib/target-linux.chiral` (`linux-syscalls`, `:11`).
- **Change:** add `(pair "socketpair" "nb-sys-socketpair")` to `crossing-wraps`
  and `(sys-row "nb-sys-socketpair" 53)` to `linux-syscalls`. `sys-linkage`
  auto-derives `sys-bindings` from crossing-wraps (header invariant,
  `crossing-wraps.chiral:8`), so no third edit.
- **Size:** ~S (two one-line rows — bundle with Step 2 or as one commit)

### Step 4 — the hermetic milestone sample
- **Target:** `scaffold/samples/` — a new sample (e.g. `socketpair-drain.chiral`).
- **Change:**
  `(def main (=> Unit I64) (lam (u) (case (socketpair unit) ((sp-ok a b) (let ((_ (sv-drain (sv-push a (sv-push b sv-nil))))) 42)) ((sp-err m) 1))))`.
  Two real connected caps threaded through a `SockVec` and drained; exit 42 =
  hermetic pass, exit 1 = defined failure.
- **Size:** ~S

**Suggested commits:** (1) Step 1 surface; (2) Step 2 + Step 3 body+rows
together (the body is dead without its linkage rows); (3) Step 4 sample. Reblob
after each so the self-hosting gate (§5) can run.

## 5. Conformance gate

- **Golden behavior — the hermetic `sv-drain` milestone:** a B1-compiled native
  binary of the Step-4 sample runs to **exit 42**: `socketpair` returns
  `(sp-ok a b)` with two real connected native fds (verified with **no peer, no
  listener, no network** — the property distinguishing E126 from DEFERRED E127),
  both caps flow into a `SockVec` and `sv-drain` closes each exactly once. The
  type-checker must accept the linear threading (each `Sock` consumed exactly
  once) as a precondition of compiling the sample at all.
- **DISCRIMINATING:** the identical sample **fails to compile under the old B1**
  — no `socketpair` extern / no `SockPairR` — so the milestone is a true delta,
  not a no-op.
- **Untypeable negatives (compile-fail, by construction — assert rejection):**
  a variant that drops one returned cap (linear `1` binder unconsumed) and a
  variant that double-consumes one of the pair — both must be rejected by the
  linear checker.
- **Self-hosting gate:** all four edited libs (`ports.chiral`, `sys-tal.chiral`,
  `crossing-wraps.chiral`, `target-linux.chiral`) are blob-resident, so after
  promotion run the compiler over the blob once more and byte-`cmp` — it must
  reproduce itself (B1-compiling-B1, ~1s).
- **Tests to add:** a native-floor test that compiles+runs the sample and asserts
  exit 42 (alongside `test_sockets.py` / `test_process_externs.py`); the two
  compile-fail negatives assert the checker rejects them.
- **Green line:** judge on the **native floor + the milestone sample**, not the
  stale green count. Baseline 704 test fns → ≥ 705 (+1 sample-driven native test,
  +the negative-assertion cases); ledger-lint clean.
- **Done when:** the sample compiles under the new B1, runs to native exit 42
  hermetically, the two negatives are rejected, and the reblob `cmp` is
  byte-identical.

## 6. Residue & links

- **Deliberately unbuilt (with homes):**
  - Numeric `-errno → Str` rendering in the error arm — DEFERRED to the shared
    `*-err` boundary helper (§3.3); fixed literal this run.
  - `SOCK_CLOEXEC|SOCK_NONBLOCK` type flags — a later type-const knob on the
    `SOCK_STREAM` argument.
  - `SOCK_DGRAM` / other domains — knob on the two constants.
  - A send/recv round-trip over the pair before draining — belongs to the socket
    I/O elements, not the pure-acquisition gate.
- **Follow-on:** unblocks E127 (DEFERRED `sock-connect`, the non-hermetic
  sibling) and any element that needs a hermetic pair of native caps to exercise
  the `SockVec`/`sv-drain` lifecycle without a network.
- **Related:** [[E126-socketpair]], [[E123]] (Sock carrier — fd word lowers),
  [[E124]] / [[E107]] (cap lifecycle + close), [[E99]] (ioctl alloc-inside
  out-cell precedent), [[E127]] (DEFERRED sock-connect). Code anchors:
  `nb-unpack32-t` (`bytes-tal.chiral:172`), `ti-cona` (`tal-ir.chiral:23`),
  `nb-sys-ptsno-t`/`nb-sys-winsz-t` (`sys-tal.chiral:601,475`), `Poll2R`/`ConnR`
  (`ports.chiral:33,38`), `sv-drain` (`lincoll.chiral:67`).
