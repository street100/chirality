---
element: E127
slug: sock-connect
title: Native `sock-connect`: lower `sock-connect : (=> Str ConnR)` to native — a fused TAL body doing `socket(AF_UNIX, SOCK_STREAM)` then `connect(fd, sockaddr_un, len)`, packing the `sockaddr_un` (family u16 + `sun_path`), decoding the return (negative = errno → `conn-err`, else → `conn-r Sock`), assembling the `ConnR` result sum (via `ti-cona`, the E126 `nb-sys-socketpair-t` precedent; its `Sock` field lowers via E123's carrier). crossing-wraps row + `nb-sys-socket`(41)/`nb-sys-connect`(42) TAL + target-linux numbers. **DEFERRED real-client-networking follow-on** — the hermetic `sv-drain` milestone gate is `socketpair` (E126, committed), not this; a client `connect` needs a live listener, so E127's hermetic conformance drives only the connect-ERROR path (`sock-connect "/nonexistent"` → `conn-err` → defined exit), the `conn-r` success path verified-by-construction but undriven until the server side lands. Native leg of E29 (oracle-only). **Scope: sock-connect only**; `sock-listen`/`sock-accept` (server) and `sock-send`/`recv` (E125 use, rows over `nb-sys-write`/`read`) are follow-on
kind: BUILD-PROPER
reference_class: OURS/SPEC
ours_source: (none)
status: drafted
updated: 2026-08-12
---

# E127 — Native `sock-connect`

> **DEFERRED (2026-08-12):** E126 was re-pointed to `socketpair` (the hermetic
> `sv-drain` milestone gate — real connected caps with no peer). This
> sock-connect design is preserved here as **E127**, a follow-on for real client
> networking (needs a live peer / listener; not the milestone path). The
> web-verified ABI + fused-body design below stand.

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E127 — lower the client socket-acquisition crossing
  `sock-connect : (=> Str ConnR)` (`ports.chiral:63`) from the Python oracle
  (`_sockconnect`, `impl_ports.py:143-152`) to a native TAL body: one surface
  extern that runs **two** syscalls — `socket(AF_UNIX, SOCK_STREAM)` then
  `connect(fd, sockaddr_un, addrlen)` — and hands back a `ConnR` value.
- **Kind:** BUILD-PROPER (the native leg of E29, which is oracle-only today —
  grep-clean of any `nb-sys-socket`/`nb-sys-connect`).
- **Why chirality needs its own:** the whole point of the port floor is that a
  socket is an *acquired linear capability*, not an ambient fd. Only the native
  crossing actually acquires one on-target; the Python oracle is a stand-in that
  keeps the seam untyped and un-self-hosted. **This is the real-client-networking
  crossing (DEFERRED follow-on), not the milestone gate:** the hermetic
  `sv-drain` milestone gate is `socketpair` (E126, `nb-sys-socketpair-t`,
  committed), which mints two already-connected `Sock`s with no peer. `sock-connect`
  reaches a *real* listener over the wire — so exercising its `conn-r` success
  path needs a live server (bind/listen/accept), which is out of scope here. The
  linear `Sock` lifecycle it feeds (E123 carrier / E124 `adopt-fd` / E107
  `sock-close`) is already exercisable natively today via `socketpair`.

## 2. Research

- **Reference class:** OURS/SPEC. OURS = `_sockconnect` (`impl_ports.py:143-152`),
  `ConnR`/`Sock` (`ports.chiral:38-40,12`), and the in-tree crossing precedents
  (`sys-tal.chiral` — chiefly `nb-sys-socketpair-t`, the committed E126 hand-authored
  `ti-cona` sum-return body; `target-linux.chiral`, `crossing-wraps.chiral`). SPEC = the
  Linux syscall ABI (`socket(2)`, `connect(2)`, `unix(7)`), **web-verified**
  below — not asserted from memory (per the standing web-verify directive; a
  wrong termios mask shipped from memory once).

- **Web-verified ABI facts (x86-64 Linux):**
  - **Syscall numbers:** `socket` = **41**, `connect` = **42**
    (filippo.io/linux-syscall-table; matches the kernel `unistd_64.h`).
  - **`AF_UNIX` = 1, `SOCK_STREAM` = 1** (`include/linux/socket.h` /
    `bits/socket.h`; `AF_UNIX` is the alias of `PF_UNIX` = 1, `SOCK_STREAM` = 1).
    So `socket(1, 1, 0)` creates the AF_UNIX stream socket.
  - **`struct sockaddr_un` (`unix(7)`):**
    `sa_family_t sun_family` (**u16**, 2 bytes) then `char sun_path[108]` —
    total sizeof = **110 bytes**. `sun_family` must hold `AF_UNIX` (1).
  - **`addrlen` for `connect()` on a pathname socket:** `unix(7)` gives two legal
    forms — the tight `offsetof(struct sockaddr_un, sun_path) + strlen(path) + 1`
    ( = `2 + strlen(path) + 1`, counting the NUL), or simply
    `sizeof(struct sockaddr_un)` (= 110). We use the **tight** form: it is the
    canonical pathname-socket length and avoids trailing-garbage ambiguity.

- **Raw-syscall return convention (the load-bearing decode fact):** at the raw
  syscall ABI the kernel returns the fd (≥ 0) on success or **`-errno`**
  (negative) on failure — it does **not** set a separate `errno` global the way
  glibc's wrappers do. So the native decode is `r < 0 ⇒ error`, exactly the
  `(op-lti ... 0)` pattern every existing crossing uses
  (`nb-sys-winsz-t`, `nb-sys-open-rw-t`).

- **Sum-return assembly — direct precedent (`nb-sys-socketpair-t`, E126):** a
  hand-authored TAL body that returns a *boxed sum* over the effect membrane is
  no longer novel. `nb-sys-socketpair-t` (`sys-tal.chiral`, committed) is the
  "FIRST hand-authored `ti-cona` body + FIRST native crossing returning a boxed
  sum": it splits `r < 0` with `(op-lti … 0)`, builds `(sp-err msg)` via
  `(ti-cona dst 1 (cons msg nil))` on the error arm and `(sp-ok fd0 fd1)` via
  `(ti-cona dst 0 …)` on the ok arm — each fd word IS a `Sock` at the boundary
  (E123 carrier). `ConnR` here is structurally identical (tags `conn-r`=0 /
  `conn-err`=1), so the `ConnR` assembly is a **direct copy** of that shape — no
  new backend machinery, just one more `ti-cona`-returning body.
- **Oracle behavior to match (`_sockconnect`):** create the socket; on
  `connect` failure **`s.close()`** then return `conn-err`; on success return
  `conn-r` carrying the socket. The `close`-on-error is essential: `socket()`
  already allocated an fd, so the connect-error arm must `close(fd)` or it leaks
  a descriptor. (Real ctors are **`conn-r`** / **`conn-err`** — the catalog's
  "conn-ok" is a paraphrase; `ports.chiral:38-40` is authoritative.)

## 3. Conventional (other-language) approach

The BSD-sockets dance, as the Python oracle does it:

```python
def _sockconnect(path):
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)  # ambient fd appears
    try:
        s.connect(path)                                    # may raise OSError
    except OSError as e:
        s.close()                                          # manual leak-avoid
        return ("con", "conn-err", [f"sock-connect {path}: {e}"])
    return ("con", "conn-r", [("sock", s)])
```

In C it is `int fd = socket(AF_UNIX, SOCK_STREAM, 0); connect(fd, &addr, len);`
with `errno` on the side and a `sockaddr_un` filled by hand.

- **Assumptions it bakes in:**
  - **Ambient authority** — `socket()` mints an fd out of thin air; anyone can
    call it, and the fd is a bare `int` copyable/dup-able at will.
  - **Untyped effect** — nothing in the type says this touches the kernel; the
    same `s` is a value you can forget to `close`, `close` twice, or use after
    close, all type-clean.
  - **Failure as control flow** — `connect` failure is an exception / a global
    `errno`, separate from the return, so the leak-avoiding `s.close()` is a
    hand-maintained obligation the type system never checks.

## 4. The chirality idea

- **Chirality features in play:** ports & capabilities (`porttype Sock`), QTT linear
  usage (`1` binders), the `=>` process membrane, boundary-sums (E29 `ConnR`),
  and the E123 porttype-carrier that lowers a `Sock` field to `nt-i64`.
- **The reframing:**
  - The acquired socket is a **linear `Sock` capability** (`ports.chiral:12`),
    not an ambient int. It threads move-only: the checker rejects dropping it
    (must reach `sock-close`, E107) or using it twice — **use-after-free and
    fd-leak become untypeable**, not lint.
  - Failure is a **value in the result type**: `ConnR = (conn-r (1 s Sock)) |
    (conn-err (msg Str))` (`ports.chiral:38-40`). The error arm carries **no**
    `Sock` — a failed connect acquired nothing to thread back (E29: "a real
    error is a corpse"). The caller must `case` on `ConnR`; there is no
    exception and no `errno` side channel.
  - The two-syscall fusion and the raw-int→sum decode live **inside** the TAL
    body `nb-sock-connect`; surface chirality only ever sees `ConnR`. That is the
    boundary-sums directive applied to a syscall pair: parse the raw returns
    once, at the crossing, and emit the sum — downstream stays total and pure.
  - `sock-connect` is `=>` (process): it holds no port on entry but performs a
    crossing, so its effect row is nonempty.
- **What chirality makes impossible here:** silently leaking the socket on the
  connect-error path (the `conn-err` arm has no `Sock` field, and the fused body
  is the *only* place the fd exists before it becomes a `Sock` — so the body
  **must** `close` it there); copying/forgetting/double-closing the returned
  `Sock`; and calling any crossing without holding its capability.

## 5. Chirality example (fleshed)

Surface `sock-connect` is untouched (`ports.chiral:63` already declares it). The
work is the **native lowering**: a fused TAL body + one routing row + two
syscall numbers. Skeleton in real TAL surface (mirrors `nb-sys-open-rw-t` for
the `ti-sys` shape, `nb-spawn-in-pty-t` for the fused multi-step shape, and
`nb-sys-socketpair-t` for the `ti-cona` boxed-sum return — the committed E126
precedent this copies):

```chirality
; ── sys-tal.chiral: the fused acquisition body ────────────────────────────
; nb-sock-connect(path-cell) -> ConnR-as-i64-carrier | -errno-encoded-err
;   reg0 = NUL-terminated path bytes cell (the Str lowered to Bytes)
; socket(AF_UNIX=1, SOCK_STREAM=1, 0) ; on fd<0 -> conn-err
; pack sockaddr_un{ family=1 (u16 LE), sun_path=path\0 } into a fresh cell
; connect(fd, &sa, addrlen=2+strlen+1) ; on r<0 -> close(fd) then conn-err
; else -> conn-r(fd as Sock)              (E123: Sock field -> nt-i64)
(def nb-sock-connect-t TIFn
  (ti-fn "nb-sock-connect" 1 17
    (t-seq (ti-const 1 1)                         ; AF_UNIX
    (t-seq (ti-const 2 1)                         ; SOCK_STREAM
    (t-seq (ti-const 3 0)                         ; protocol 0
    (t-seq (ti-sys 4 41 (cons 1 (cons 2 (cons 3 nil))))   ; fd = socket(1,1,0)
    (t-seq (ti-const 5 0)
    (t-seq (ti-prim 6 (op-lti) 4 5)               ; fd < 0 ?
      (ti-tcase 6 false
        ; ── fd<0: socket() itself failed, nothing to close ──
        (cons (pair (pair 0 nil)
          ; assemble (conn-err msg)  [tag 1 of ConnR] — mirror nb-sys-socketpair-t
          (t-seq (ti-const 7 0)
          (t-seq (ti-bnew 8 7)                     ; empty Str message (errno render deferred)
          (t-seq (ti-cona 9 1 (cons 8 nil))        ; (conn-err msg) via ti-cona, tag 1
            (ti-ret 9)))))
        (cons (pair (pair 1 nil)
          ; ── fd>=0: pack sockaddr_un, connect ──
          ; sun_len = offsetof(sun_path)=2 + strlen(path) + 1
          (t-seq (ti-call 7 "nb-sa-un-pack" (cons 0 nil))  ; helper: family+path+NUL cell
          (t-seq (ti-bptr 8 7)                     ; &sa
          (t-seq (ti-call 9 "nb-sa-un-len" (cons 0 nil))   ; helper: 2+strlen+1
          (t-seq (ti-sys 10 42 (cons 4 (cons 8 (cons 9 nil))))  ; connect(fd,&sa,len)
          (t-seq (ti-const 11 0)
          (t-seq (ti-prim 12 (op-lti) 10 11)       ; connect r < 0 ?
            (ti-tcase 12 false
              (cons (pair (pair 0 nil)
                ; assemble (conn-r fd)  [tag 0 of ConnR] — fd word IS a Sock (E123)
                (t-seq (ti-cona 13 0 (cons 4 nil))   ; (conn-r fd) via ti-cona, tag 0
                  (ti-ret 13)))
              (cons (pair (pair 1 nil)
                ; connect failed: close the fd (else leak) THEN conn-err
                (t-seq (ti-call 13 "nb-sys-close" (cons 4 nil))
                (t-seq (ti-const 14 0)
                (t-seq (ti-bnew 15 14)               ; empty Str message
                (t-seq (ti-cona 16 1 (cons 15 nil))  ; (conn-err msg) via ti-cona, tag 1
                  (ti-ret 16))))))
              nil)) none))))))))
        nil)) none))))))))))

; ── target-linux.chiral: two new syscall rows (append to syscall-table) ──
(cons (sys-row "nb-sys-socket"   41)   ; E127
(cons (sys-row "nb-sys-connect"  42)   ; E127
; …existing rows (nb-sys-socketpair 53 already present from E126)…

; ── crossing-wraps.chiral: one routing row ──
(cons (pair "sock-connect" "nb-sock-connect")   ; E127: fused socket+connect
; …existing rows…
```

The `sockaddr_un` packer (modelled on `bput-u16-le` E109 + `nb-copy`
`bytes-tal.chiral`): allocate a cell of `2 + strlen + 1` bytes,
`pack-u16 1` the family little-endian at offset 0, `nb-copy` the path bytes at
offset 2, and the trailing NUL falls out of the zero-filled `ti-bnew`. Hand
`ti-bptr` of that cell to `connect`.

- **Knobs to modify:**
  - **`addrlen` form** — the tight `2+strlen+1` shown, vs the blunt `110`
    (`sizeof`). Tight is canonical; both connect to a pathname listener.
  - **abstract-namespace sockets** (leading NUL in `sun_path`) — out of scope;
    would change the packer and the len computation.
  - **error message** — `conn-err` carries a `Str`; could fold the raw `-errno`
    into it (boundary-sums would prefer an errno field, but `ConnR`'s shape is
    fixed at `(msg Str)` in `ports.chiral` — keep the Str, format the errno in).
- **Deliberately omitted:** `sock-listen`/`sock-accept` (the *server* side — a
  separate bind+listen+accept crossing set) and `sock-send`/`sock-recv` (E125,
  rows over `nb-sys-write`/`read`). This element is **client acquisition only**.

## 6. Use / modify notes

- **Lands in:**
  - `scaffold/lib/sys-tal.chiral` — the fused `nb-sock-connect-t` body (+ two
    tiny helpers for the sockaddr_un pack and the len), added to `sys-lib`.
  - `scaffold/lib/target-linux.chiral` — two `sys-row`s: `nb-sys-socket` 41,
    `nb-sys-connect` 42.
  - `scaffold/lib/crossing-wraps.chiral` — one row `("sock-connect"
    "nb-sock-connect")`; `lib/sys-linkage.chiral` `sys-bindings` auto-derives
    from it (the stated invariant at `crossing-wraps.chiral:8-9`).
  - No change to `ports.chiral` — surface `sock-connect` and `ConnR`/`Sock` are
    already declared; this is pure lowering.

- **SIZE verdict: M** — matches the catalog's M sizing. Rationale: it is more
  than a one-const flip (E110) or a single bare-int crossing (E121 fcntl) —
  it's a **fused two-syscall body with in-body struct packing and a
  two-level result-sum assembly** (socket-fail arm + connect-fail-with-close
  arm + success arm), plus the con-carrier assembly for `ConnR`. But it is
  bounded: every ingredient has a direct in-tree precedent (`nb-spawn-in-pty-t`
  for fused multi-step + close-on-error; `bput-u16-le` + `nb-copy` for the
  packing; `nb-sys-winsz-t` for the `r<0` decode), no new TAL primitive is
  needed, and it's three files + one grep-clean. Not L: no new op, no linkage
  machinery, no surface-type change.

- **Conformance target — the connect-ERROR path only (honest):** a client
  `connect` needs a **live AF_UNIX listener at the path** to reach `conn-r`, and
  bind/listen/accept (the server side) are **not built** — so the `conn-r`
  success path is **verified-by-construction but NOT driven** here. The hermetic
  conformance E127 can actually exercise is the **error path**:
  `sock-connect "/nonexistent"` → the kernel returns `-ENOENT`/`-ECONNREFUSED` →
  `(op-lti … 0)` decodes it → `(conn-err msg)` assembles via `ti-cona` → a
  **defined native exit**. That drives the whole lowering under test — `socket`
  and `connect` both run on-target, the `-errno` decode fires, and the `ConnR`
  sum is built and cased — **without** claiming a full connect round-trip. The
  sample compiles with B1 and runs to a defined exit, **zero** Python in the
  compile/run path; the `Sock` field of the (undriven) `conn-r` arm lowers via
  the E123 carrier (`term->ntalty` maps `Sock → nt-i64`, committed afea68d — the
  same field shape the E123 audit confirmed for `RecvR`/`AccR`; `ConnR` is
  identical), and `sock-close` (E107 rows in `crossing-wraps.chiral:36-38`) is the
  release the success arm would use.

  > The **hermetic real-connection** proof (two live connected `Sock`s, drained
  > via `sock-close`) is already covered by `socketpair` (**E126**, committed
  > `nb-sys-socketpair-t`) — that is the `sv-drain` milestone gate, not this
  > element. The `conn-r` success path of `sock-connect` waits on the deferred
  > server side (`sock-listen`/`sock-accept`) for an end-to-end drive.

- **Open questions (flag for the spec):**
  1. **Error-path sample shape** — the sample cases `ConnR` and maps `conn-err`
     to a defined exit (e.g. exit 42), leaving the `conn-r` arm compiled but
     unreached (or trivially `sock-close`+exit for coverage). Confirm the exit
     convention and whether the unreached `conn-r` arm should still be present
     for the linear-usage check.
  2. **`addrlen`** — tight `2+strlen+1` (recommended) vs `sizeof`=110.
  3. **Helper factoring** — inline the sockaddr_un pack/len into
     `nb-sock-connect-t`, or mint reusable `nb-sa-un-pack`/`nb-sa-un-len`
     helpers (reused by the future `sock-listen` bind). Leaning reusable, since
     bind will need the identical packing.
  4. **`conn-err` message content** — fold the raw `-errno` into the `Str` (the
     oracle formats `path: <OSError>`); `ConnR`'s `(msg Str)` shape is fixed, so
     no errno-field option without changing `ports.chiral`.

- **Related:** [[E29-socket-ports]] (the oracle-only surface this natives),
  [[E126-socketpair]] (the committed `nb-sys-socketpair-t` — the direct
  `ti-cona` boxed-sum precedent this copies, and the *actual* `sv-drain`
  milestone gate),
  [[E123-porttype-carrier]] (the `Sock`-field lowering this depends on),
  [[E124-adopt-fd]] · [[E107-cap-close]] (the rest of the `Sock` lifecycle),
  [[E106-sockvec-drain]] (the milestone — gated by socketpair, not this),
  [[E109-bput-u16-le]] (the u16 packer reused for `sun_family`),
  [[E110-cloexec-pty]] · [[E121-fcntl]] (sibling recent crossing rows).
