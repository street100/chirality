---
element: E29
slug: sockets
title: Sockets: `socket`/`connect`/`bind`/`listen`/`accept`/`send`/`recv`
kind: REPLACE-CRUTCH
reference_class: SPEC
ours_source: scaffold/chirality/impl_ports.py
status: drafted
updated: 2026-07-13
---

# E29 — Sockets: `socket`/`connect`/`bind`/`listen`/`accept`/`send`/`recv`

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E29, the stream-socket lifecycle — create, connect, bind+listen,
  accept, send, recv, close — as typed chirality ports over the Linux socket ABI.
- **Kind:** REPLACE-CRUTCH.
- **Why chirality needs its own:** the whole lifecycle rides on CPython's `socket`
  module inside `scaffold/chirality/impl_ports.py`, a Category C bridge. The typed
  face over it already substantially exists and CONFORMS: `scaffold/lib/ports.chiral`
  declares the `Sock`/`LSock`/`Fd` porttypes (the listen/connected distinction
  already carried in the types, each binder linear) and the full
  `sock-connect`/`sock-listen`/`sock-accept`/`sock-send`/`sock-recv`/`sock-close`/
  `lsock-close` extern set — with `sock-recv` and `sock-accept` already returning
  result sums (`RecvR`, carrying a named `recv-closed` EOF event; `AccR`,
  returning both live handles). Sockets are the transport every other net element
  (E30 fd-passing, the poll deadline, the exchange protocol) sits on. The
  REPLACE-CRUTCH delta this element still owes is narrow: (a) an explicit error
  arm on every fallible op — `sock-connect`/`sock-listen`/`sock-send` currently
  return a bare handle and raise `PortError`, and `sock-recv`/`sock-accept` carry
  no `*-err` arm yet; (b) capability-gating socket creation behind a `NetCap`
  grant (the current `sock-connect`/`sock-listen` take no authority parameter);
  (c) a refined positive length on `sock-recv` (currently a bare `I64`).

## 2. Research

- **Reference class:** SPEC — the Linux socket ABI (`socket(2)`, `connect(2)`,
  `bind(2)`, `listen(2)`, `accept(2)`, `send(2)`, `recv(2)` semantics),
  grounded in the OURS bridge `scaffold/chirality/impl_ports.py`.
- **Key findings:**
  1. The ABI is a *state machine smeared over one type*: a bare `int` fd is
     simultaneously "fresh", "bound", "listening", and "connected", and the
     kernel polices transitions at runtime (`EINVAL`, `ENOTCONN`). The states
     are real; the C type system just doesn't carry them.
  2. OURS already collapses `bind`+`listen` into one op (`sock-listen` does
     `bind(path); listen(1)`): the bound-but-not-listening intermediate state
     has no use for us, so the typed face need not expose it.
  3. `recv` returning `b""` is the ABI's in-band EOF sentinel. OURS already
     lifts it to a *named event* (`recv-closed`, distinct from `recv-r`) —
     the typed face must keep that as a constructor, never a sentinel value.
     **Disposition 2026-07-26 (the recv-closed FLAG):** `recv-closed` **carries
     the still-live `Sock` back** — `(recv-closed (s Sock))`, not `(recv-closed)`.
     Peer EOF is a *half-close*, not a socket death: the local fd is still open,
     must be `sock-close`d locally, and (TCP half-open) can still `sock-send`.
     Dropping the linear `Sock` would need an implicit destructor (forbidden —
     [[decision-effect-facets]]: "no implicit destructor; cancel is explicit") or
     leak the fd; it also mirrors E30's possession facet (an unmoved resource
     stays held). The OURS reference already returns it (`("con","recv-closed",
     [sv])`); the typed `RecvR` def was internally inconsistent and is corrected
     to match. (`recv-err` keeps dropping the stream — a real error is a corpse;
     whether an errored fd still needs an explicit local close is a separate,
     narrower question, not this FLAG.)
  4. Every op can fail with `OSError`; OURS converts each to a raised
     `PortError` (E26 alarms). In chirality the error path moves into the
     signature as a `*-err` constructor.
  5. `accept` yields *two* live resources — the still-listening socket and a
     fresh connected stream (OURS: `("con", "acc-r", [lv, ("sock", conn)])`) —
     so its result type must return both, each still linear.

## 3. Conventional (other-language) approach

The OURS bridge is idiomatic Python-over-POSIX — untyped ints/objects, raised
exceptions, in-band EOF:

```python
@impl("sock-listen")
def _socklisten(path):
    s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    try:
        s.bind(path)
        s.listen(1)
    except OSError as e:
        raise PortError(f"sock-listen {path}: {e}")
    return ("lsock", s)

@impl("sock-recv")
def _sockrecv(sv, n):
    try:
        data = sv[1].recv(n)
    except OSError as e:
        raise PortError(f"sock-recv: {e}")
    if not data:
        # a closed stream is a named protocol event, not a sentinel value
        return ("con", "recv-closed", [sv])
    return ("con", "recv-r", [data, sv])
```

- **Assumptions it bakes in:**
  - **One untyped socket value for every state** — nothing stops `recv` on a
    listener or `accept` on a stream except a runtime `OSError`.
  - **Ambient authority** — `socket.socket(...)` conjures network authority
    out of nothing; any code anywhere can open a socket.
  - **Partiality as control flow** — errors are raised `PortError`s, invisible
    in any signature.
  - **No lifecycle discipline** — a socket can be closed twice, leaked, or
    used after close; Python's GC and the kernel clean up whatever's left.

## 4. The chirality idea

- **Chirality features in play:** QTT linearity (`1` on every socket binder), the
  `->`/`=>` membrane, ports & capabilities (no ambient authority), result
  sums (E26), refinement on `recv` length, totality via a fuel measure,
  Category C (typed face here, untyped referent stays in `impl_ports.py`).
- **The reframing:** the socket state machine moves *into the types*. Two
  distinct opaque port types — `LSock` (listening) and `Sock` (connected
  stream) — mean each op exists only for the state it's valid in. Every
  socket is a **linear capability**: each op consumes it and (on success)
  threads a fresh handle back, so drop, reuse, and use-after-close are
  rejected by the checker, not the kernel. Creating a socket at all requires
  holding a `NetCap` grant — authority is a port you were handed, not a call
  you can make. All ops are `=>` process arrows: a `->` function provably
  cannot touch the network. Errors are constructors the caller must `case` on.
- **What chirality makes impossible here:**
  - `recv` on a listener / `accept` on a stream — no such function exists at
    that type.
  - use-after-close and double-close — the close op consumed the linear handle.
  - leaking a socket — an unconsumed linear binder is a type error.
  - opening a socket from pure code or without the `NetCap` grant.
  - silently ignoring EOF or an error — `case` coverage forces both arms.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")

; ---- typed faces over the Category B socket referent (impl_ports.py) ----
(porttype NetCap)   ; the grant that authorizes creating sockets at all
(porttype LSock)    ; a listening unix socket: accept/close only
(porttype Sock)     ; a connected stream:      send/recv/close only

; ---- result sums: the error path lives in the signature, not a throw ----
(data ConnR ()
  (conn-ok  (s Sock))
  (conn-err (msg Str)))                 ; no socket back: nothing was opened

(data LisR ()
  (lis-ok  (l LSock))                   ; bind+listen collapsed (spec finding 2)
  (lis-err (msg Str)))

(data AccR ()
  (acc-ok  (l LSock) (s Sock))          ; listener survives; fresh stream arrives
  (acc-err (msg Str)))                  ; listener is dead — bridge closed it

(data SendR ()
  (send-ok  (s Sock))                   ; stream threaded back for the next op
  (send-err (msg Str)))                 ; stream is gone — no retry on a corpse

(data RecvR ()
  (recv-ok     (b Bytes) (s Sock))
  (recv-closed (s Sock))                ; peer EOF (half-close): a named event, never b"" — the socket is STILL LIVE, threaded back for explicit close / half-open send
  (recv-err    (msg Str)))

; ---- extern bridge: => process arrows, sockets always linear ----
(extern sock-connect (=> (net NetCap) Str ConnR))
(extern sock-listen  (=> (net NetCap) Str LisR))
(extern sock-accept  (=> (1 l LSock) AccR))
(extern sock-send    (=> (1 s Sock) Bytes SendR))
(extern sock-recv    (=> (1 s Sock) (refine I64 (> 0)) RecvR))
(extern sock-close   (=> (1 s Sock) Unit))
(extern lsock-close  (=> (1 l LSock) Unit))

; ---- an echo turn-loop: total via a fuel measure, linear thread throughout ----
(declare echo-turns (=> (1 s Sock) (refine I64 (>= 0)) Unit))
(def echo-turns
  (lam ((1 s) fuel)
    (if (=i fuel 0)
        (sock-close s)                        ; out of turns: consume the handle
        (case (sock-recv s 4096)
          ((recv-ok b s2)
             (case (sock-send s2 b)
               ((send-ok s3) (echo-turns s3 (- fuel 1)))
               ((send-err m) unit)))          ; stream dead; surface m upstream
          ((recv-closed s2) (sock-close s2))  ; peer half-closed — close the still-live handle explicitly
          ((recv-err m) unit)))))

; ---- one-shot accept loop spine (mechanical recursion elided) ----
(declare serve (=> (net NetCap) Str (refine I64 (>= 0)) Unit))
(def serve
  (lam (net path fuel)
    (case (sock-listen net path)
      ((lis-ok l)
         (case (sock-accept l)
           ((acc-ok l2 s)
              (let ((u (echo-turns s fuel)))
                (lsock-close l2)))
           ((acc-err m) unit)))              ; listener already reclaimed
      ((lis-err m) unit))))
; … a multi-client server recurses on l2 with its own decreasing measure
```

- **Knobs to modify:** the recv chunk size and its refinement bound; the fuel
  measure (turns vs bytes budget); whether `NetCap` is one grant or split
  into `ConnectCap`/`ListenCap`; the error payload (bare `Str` now, an E26
  alarm sum later); `listen` backlog if >1 ever matters.
- **Deliberately omitted:** fd-passing (`sock-send-fd` — that is E30); the
  poll deadline / non-blocking modes; AF_INET (OURS is AF_UNIX only);
  partial-send handling (OURS uses `sendall`, keep that semantic).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/ports.chiral`, where the `Sock`/`LSock`/`Fd`
  porttypes and the `sock-*` extern set already live — this element MODIFIES
  those extern signatures (adds the `*-err` arms, the `NetCap` parameter on the
  create ops, the refined recv length) and adds the missing result `data`s
  (`ConnR`/`LisR`/`SendR`, plus the `*-err` arms on the existing `RecvR`/`AccR`)
  and the loop helpers; `scaffold/chirality/impl_ports.py` remains the Category C
  referent behind the externs until self-hosting sheds it.
- **Conformance target:** golden behavior of the existing `sock-*` impls in
  `impl_ports.py` — `sock-listen` = bind+listen(1) in one step; `recv` EOF
  surfaces as `recv-closed`, never empty `Bytes`; send has `sendall`
  semantics; every `OSError`→`PortError` site becomes the matching `*-err`
  constructor with the same message shape.
- **Open questions:** do `*-err` arms ever return the socket for explicit
  close, or does the bridge always auto-close on error (assumed here)?
  How does the poll-deadline port compose with a blocked `sock-recv`?
  Is `NetCap` minted per-process by the runtime or granted by a parent port?
- **Related:** [[E30-fd-passing]] (sendmsg+SCM_RIGHTS rides on `Sock`),
  [[E26-alarms]] (`PortError` → result sums), the memfd pool ports that
  share `impl_ports.py`.
