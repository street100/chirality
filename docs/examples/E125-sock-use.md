---
element: E125
slug: sock-use
title: Native `sock-send`/`sock-recv` (the socket "use" stage): lower `sock-send : (=> (1 s Sock) Bytes SendR)` and `sock-recv : (=> (1 s Sock) (refine I64 (>0)) RecvR)` — hand-authored TAL bodies over the existing `nb-sys-write`/`nb-sys-read`, each threading the `Sock` cap back and building its result sum via `ti-cona` (the E126 socketpair pattern — boxed-sum-returning crossing). `sock-send`: write the Bytes, assemble `SendR` (sent count / err) with the Sock re-threaded. `sock-recv`: read up to N into a fresh cell, assemble `RecvR` — `recv-ok`(bytes, Sock) / `recv-closed`(Sock, on 0 bytes = peer half-close) / `recv-err`. The `Sock` fields lower via E123's carrier. crossing-wraps rows + the two bodies in `sys-lib`. **Scope: send/recv only**; `sock-send-fd` (SCM_RIGHTS, `nb-sys-send-fd-t` already exists) is a follow-on
kind: BUILD-PROPER
reference_class: OURS/SPEC
ours_source: (none)
status: drafted
updated: 2026-08-12
---

# E125 — Native `sock-send`/`sock-recv` (the socket "use" stage)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E125 — lower the two socket "use" crossings, `sock-send`
  (`lib/ports/sock.port:67`) and `sock-recv` (`lib/ports/sock.port:69`), from oracle-only
  Python to hand-authored native TAL bodies, each threading the linear `Sock`
  cap back through its result sum (`SendR`/`RecvR`, `ports.chiral:51,28`).
- **Kind:** BUILD-PROPER (design from the spec + the committed E126 precedent;
  no OURS port to transliterate beyond the oracle's behavior).
- **Why chirality needs its own:** these are the third leg of the socket lifecycle
  — E126 `socketpair` opens a hermetic pair, E107 `sock-close` releases it, and
  E125 is the *use* between them. Until they lower, a chirality program that holds a
  `Sock` can construct and close it natively but cannot move a byte over it
  without the CPython oracle in the loop — the socket cap is real but inert.

## 2. Research

- **Reference class:** OURS/SPEC. OURS = the oracle behavior (`_socksend`
  `impl_ports.py:186`, `_sockrecv` `:210`) + the committed precedents
  `nb-sys-socketpair-t` (`sys-tal.chiral:717`, the first hand-authored `ti-cona`
  boxed-sum-returning crossing), `nb-sys-write-t` (`:18`), `nb-sys-read-t`
  (`:39`). SPEC = Linux `send(2)`/`recv(2)`.
- **Key findings:**
  1. **`send`/`recv` with flags 0 ≡ `write`/`read` on a stream socket.** On an
     AF_UNIX `SOCK_STREAM` fd (what E126 hands back), `send(fd,buf,len,0)` and
     `recv(fd,buf,len,0)` are byte-identical to `write`/`read`. So E125 needs
     **no new syscall number** — the `nb-sys-write` (nr 1) and `nb-sys-read`
     (nr 0) TAL bodies already do the crossing; E125 only adds the sum-building
     shells around them.
  2. **The result sums are narrower than the row title suggests.** `SendR` is
     `(send-r (1 s Sock)) | (send-err (msg Str))` — **no sent-count field**
     (the oracle uses `sendall`, which loops until all bytes are gone, then
     returns just the Sock). `RecvR` is `(recv-r (bs Bytes) (1 sock Sock)) |
     (recv-closed (1 sock Sock)) | (recv-err (msg Str))` — the `recv-r`/
     `recv-closed` arms thread the socket onward; `recv-err` drops it (matches
     the oracle closing `sv[1]` on `OSError`). `recv-closed` on a **0-byte read**
     is the typed peer-half-close event — a named `RecvR` value, never a
     sentinel (`ports.chiral:27`).
  3. **The Sock is a word-carrier (E123), so re-threading is free.** A `Sock`
     lowers to its raw fd word; the crossing takes it in `reg0`, uses it as the
     syscall's fd, and passes *the same reg0* into `ti-cona` as the `Sock`
     field. No box, no copy — the cap "survives" the crossing by construction
     because it is the same word in and out.
  4. **`ti-cona <dst> <tag> <fields>` builds a boxed sum by constructor index.**
     `nb-sys-socketpair-t` is the exact shape: run the syscall, `ti-prim
     (op-lti) r 0` to test `r < 0`, then a `ti-tcase` whose arms each build one
     constructor via `ti-cona` (tag = the ctor's position in the `data` decl).
     E125 `sock-recv` needs a **three-way** split (`<0` / `==0` / `>0`), i.e. a
     nested `ti-tcase`, the one structural step beyond socketpair's two-way.

## 3. Conventional (other-language) approach

BSD sockets: `send`/`recv` are ordinary calls on an ambient integer fd, with a
byte-count return and an out-of-band `errno`. The oracle (`impl_ports.py`) is a
faithful thin wrapper over exactly that:

```python
@impl("sock-send")
def _socksend(sv, data):
    try:
        sv[1].sendall(data)          # loops until every byte is gone
    except OSError as e:
        sv[1].close()                # error → close, drop the socket
        return ("con", "send-err", [f"sock-send: {e}"])
    return ("con", "send-r", [sv])   # success → hand the socket back

@impl("sock-recv")
def _sockrecv(sv, n):
    try:
        data = sv[1].recv(n)
    except OSError as e:
        sv[1].close()
        return ("con", "recv-err", [f"sock-recv: {e}"])
    if not data:                     # 0 bytes = peer half-closed the stream
        return ("con", "recv-closed", [sv])
    return ("con", "recv-r", [data, sv])
```

- **Assumptions it bakes in:** (a) the fd is **ambient** — any code holding the
  integer can `send`/`recv`/`close` it, and nothing stops a double-close or a
  use-after-close; (b) the byte-count return is a **sentinel channel** — `0`
  means half-close, `-1`+`errno` means error, and the caller is trusted to
  branch on the raw number; (c) `sendall` **hides partiality** — the C `write`
  it wraps can move fewer than `len` bytes, and Python papers over it with a
  loop the chirality floor doesn't get for free.

## 4. The chirality idea

- **Chirality features in play:** QTT linearity (`(1 s Sock)` — the socket is
  consumed exactly once and threaded back inside the result), the effect
  membrane (`=>` — both are process crossings, authored only in the sys-face
  file `sys-tal.chiral`), boundary sums (the byte-count sentinel becomes a
  closed `SendR`/`RecvR` value parsed once at the crossing), and the E123 fd
  word-carrier (a `Sock` field lowers to its fd word).
- **The reframing:** the crossing does the syscall (`write`/`read`), then
  **parses the kernel's return once** into a typed sum: `r < 0 →` err arm,
  `r == 0 →` (recv only) `recv-closed`, else the data arm — re-threading `reg0`
  (the Sock's fd word) into every arm that keeps the cap. Downstream code
  `case`s on `RecvR` totally; there is no raw count to re-inspect, no `errno`
  global, no ambient fd to double-use.
- **What chirality makes impossible here:** using the socket after it errored (the
  err arms carry no `Sock`, so the linear cap is *gone* — the checker rejects
  any further reference); silently mistaking a half-close for data (`recv-r` and
  `recv-closed` are distinct constructors the caller must both cover); and
  leaking the cap (a `Sock` threaded out of `recv-r` is still linear and must
  still be `sock-close`d exactly once).

## 5. Chirality example (fleshed)

Two hand-authored TAL bodies in `sys-tal.chiral` (`sys-lib`), each a direct
copy-and-modify of `nb-sys-socketpair-t` (`:717`) over `nb-sys-write`/
`nb-sys-read`. Register/branch mechanics mirror the committed precedents; the
skeleton below shows the spine and elides only the exact tcase boolean encoding
(copy it verbatim from `nb-sys-read-t` / `nb-sys-socketpair-t`).

```chirality
; ─── sock-send(sock, bytes) -> SendR ────────────────────────────────────────
; args: reg0 = Sock's fd word (E123 carrier), reg1 = Bytes cell.
; write(fd, payload-ptr, len); r<0 -> (send-err msg); else -> (send-r sock).
; SendR ctor tags: send-r = 0, send-err = 1  (order in ports.chiral:51).
(def nb-sock-send-t TIFn
  (ti-fn "nb-sock-send" 2 9
    (t-seq (ti-bptr 2 1)                       ; reg2 = payload address of Bytes
    (t-seq (ti-blen 3 1)                       ; reg3 = byte count
    (t-seq (ti-sys 4 1 (cons 0 (cons 2 (cons 3 nil))))  ; write(fd=r0, buf, len)
    (t-seq (ti-const 5 0)
    (t-seq (ti-prim 6 (op-lti) 4 5)            ; r < 0 ?   (true = ERROR)
      (ti-tcase 6 false
        (cons (pair (pair 0 nil)               ; ERROR arm
          (t-seq (ti-const 7 0)
          (t-seq (ti-bnew 8 7)                 ; empty Str message (errno render deferred)
          (t-seq (ti-cona 9 1 (cons 8 nil))    ; (send-err msg)  tag 1
            (ti-ret 9)))))
        (cons (pair (pair 1 nil)               ; OK arm
          (t-seq (ti-cona 7 0 (cons 0 nil))    ; (send-r sock)   tag 0, re-thread reg0
            (ti-ret 7)))
        nil))
        none))))))))

; ─── sock-recv(sock, n) -> RecvR ────────────────────────────────────────────
; args: reg0 = Sock's fd word, reg1 = n (refine I64 (> 0)).
; bnew an n-byte cell; read into it; THREE-way split on r:
;   r < 0  -> (recv-err msg)      [socket dropped]
;   r == 0 -> (recv-closed sock)  [peer half-close]
;   r > 0  -> (recv-r cell sock)  [truncate cell to r via nb-copy, like read-t]
; RecvR ctor tags: recv-r = 0, recv-closed = 1, recv-err = 2 (ports.chiral:28).
(def nb-sock-recv-t TIFn
  (ti-fn "nb-sock-recv" 2 14
    (t-seq (ti-bnew 2 1)                        ; reg2 = fresh n-byte cell (len = reg1)
    (t-seq (ti-bptr 3 2)                        ; reg3 = its payload address
    (t-seq (ti-sys 4 0 (cons 0 (cons 3 (cons 1 nil))))  ; read(fd=r0, buf, n)
    (t-seq (ti-const 5 0)
    (t-seq (ti-prim 6 (op-lti) 4 5)             ; r < 0 ?
      (ti-tcase 6 false
        (cons (pair (pair 0 nil)                ; ERROR arm
          (t-seq (ti-const 7 0)
          (t-seq (ti-bnew 8 7)
          (t-seq (ti-cona 9 2 (cons 8 nil))     ; (recv-err msg)  tag 2
            (ti-ret 9)))))
        (cons (pair (pair 1 nil)                ; r >= 0: split == 0 vs > 0
          (t-seq (ti-prim 10 (op-lti) 5 4)      ; 0 < r ?  (data vs half-close)
            (ti-tcase 10 false
              (cons (pair (pair 0 nil)          ; 0 < r TRUE -> r > 0 -> data (tag0 = true arm, per socketpair/read-t)
                ; … truncate reg2 to r bytes via nb-copy (see nb-sys-read-t:48-51) …
                (t-seq (ti-cona 12 0 (cons 2 (cons 0 nil)))  ; (recv-r cell sock) tag 0
                  (ti-ret 12)))
              (cons (pair (pair 1 nil)          ; FALSE -> r == 0 -> half-close
                (t-seq (ti-cona 11 1 (cons 0 nil))   ; (recv-closed sock)  tag 1, re-thread reg0
                  (ti-ret 11)))
                nil))
              none)))
        nil))
        none)))))))))

; ─── crossing-wraps rows (crossing-wraps.chiral) ─────────────────────────────
;   (cons (pair "sock-send" "nb-sock-send")
;   (cons (pair "sock-recv" "nb-sock-recv")
; and the mirror rows in sys-linkage.chiral `sys-bindings` (INVARIANT: agree),
; and add nb-sock-send-t / nb-sock-recv-t to `sys-lib` (sys-tal.chiral:744).
```

- **Knobs to modify:** the two ctor-tag numbers per body (read them off the
  `data` decl order); whether `recv-r` truncates the cell to `r` bytes
  (mirror `nb-sys-read-t`) or returns the full n-byte cell; the error message
  cell (empty Str now — a real errno render is the shared §3.3 deferral from
  E126); the wrapper names (`nb-sock-send`/`nb-sock-recv` vs a `nb-sys-` prefix).
- **Deliberately omitted:** `sock-send-fd` (SCM_RIGHTS; `nb-sys-send-fd-t`
  already exists — a separate follow-on), `sock-accept`/`poll2`/`sock-connect`,
  a partial-write retry loop (see open questions), and any errno-string
  formatting.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/sys-tal.chiral` (`nb-sock-send-t`, `nb-sock-recv-t`,
  added to `sys-lib`), `scaffold/lib/crossing-wraps.chiral` (two rows), and
  `scaffold/lib/sys-linkage.chiral` `sys-bindings` (the mirror rows — the
  crossing-wraps invariant). No `scaffold/chirality/*.py` change; no new syscall nr.

- **SIZE verdict: S–M.** Two hand-authored `ti-cona` bodies that ride E126's
  now-proven boxed-sum pattern and the existing `write`/`read` crossings.
  `sock-send` is essentially `nb-sys-write-t` + a two-arm `ti-cona` shell —
  small. `sock-recv` is the same shell with the one genuinely new structural
  step: a **nested** `ti-tcase` for the three-way `<0` / `==0` / `>0` split
  (socketpair and read were two-way). Plus two flat table rows ×2 files. No new
  syscalls, no python, no reference-machine work (`write`/`read` already agree
  by construction). The novelty budget was spent by E126; E125 spends the
  precedent.

- **The two body designs (summary):**
  - **`sock-send`** — `bptr`/`blen` the `Bytes` arg, `ti-sys 1` (write) on the
    Sock's fd (`reg0`), `op-lti r 0`; ERROR arm → `(ti-cona _ 1 …)` `send-err`
    (empty Str), OK arm → `(ti-cona _ 0 (cons 0 nil))` `send-r` re-threading
    `reg0`. `SendR` carries no count, so `r` is discarded on success.
  - **`sock-recv`** — `bnew` a fresh n-byte cell, `bptr` it, `ti-sys 0` (read),
    then nested tcase: `r<0` → `(ti-cona _ 2 …)` `recv-err`; `r==0` → `(ti-cona
    _ 1 (cons 0 nil))` `recv-closed` re-threading `reg0`; `r>0` → truncate the
    cell (`nb-copy`, per `nb-sys-read-t`) → `(ti-cona _ 0 (cons cell (cons 0
    nil)))` `recv-r`.

- **Conformance target — hermetic send/recv round-trip (no peer, no network).**
  Now that E126 `socketpair` is committed, a real socket-I/O round-trip runs
  entirely in-process:

  ```
  socketpair Unit
    → (sp-ok a b)                     ; two live Sock caps
    → sock-send a "hi"  → (send-r a)  ; write "hi" into one half
    → sock-recv b 8     → (recv-r bs b)
    → check (bytes->str bs) == "hi"   ; the bytes made the round trip
    → sock-close a → sock-close b     ; each cap consumed exactly once
    → native exit 42                  ; conformance sentinel
  ```

  This is a genuine kernel `write`+`read` over an AF_UNIX stream pair — real
  socket I/O, zero external peer or network — compiled by the native compiler
  and exiting 42. It also exercises the linear discipline end-to-end: `a`
  survives `sock-send` (threaded out of `send-r`), `b` survives `sock-recv`
  (threaded out of `recv-r`), and both are closed exactly once.

- **Open questions (flag for the spec):**
  1. **Partial writes.** Raw `write` may move `< len` bytes; the oracle's
     `sendall` loops. `SendR` has no count field to report a short write, so
     `sock-send` must either (a) loop internally to full `sendall` semantics,
     or (b) treat any `r ≥ 0` as success and accept that a short write silently
     drops the tail. Decide, and if (a), that changes the body from a straight
     shell into a bounded loop (a totality-measure question).
  2. **`SendR`'s exact shape.** Confirm the committed `(send-r (1 s Sock)) |
     (send-err (msg Str))` (no count) is final — if partial-write reporting is
     wanted, `send-r` would gain a `(sent I64)` field, changing the `ti-cona`
     arity.
  3. **`recv-r` cell truncation.** Return the full n-byte `bnew` cell, or copy
     down to `r` bytes as `nb-sys-read-t` does? Affects `blen bs` for callers.
  4. **errno rendering.** The err arms carry an empty `Str` (shared with E126
     §3.3). When numeric-errno→Str lands, both send/recv err arms adopt it.

- **Related:** [[E126-socketpair]] (the committed `ti-cona` precedent + the
  hermetic pair this round-trips over), [[E127-sock-connect]], [[E123]] (fd
  word-carrier that makes the `Sock` fields lower), [[E107]] (`sock-close`, the
  release leg), [[E30]] (result sums thread the cap back linearly).
