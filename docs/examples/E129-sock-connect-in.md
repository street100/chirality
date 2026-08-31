---
element: E129
slug: sock-connect-in
title: Native `sock-connect-in` (AF_INET TCP connect): the mesh/Tailscale client crossing that lets `http.chiral` reach a local model endpoint with zero TLS — lower `sock-connect-in : (=> Str I64 ConnR)` (dotted-quad host, port) to native: a fused TAL body doing `socket(AF_INET=2, SOCK_STREAM=1, 0)` (nr 41, reuse `nb-sys-socket`) then `connect(fd, sockaddr_in, 16)` (nr 42, reuse `nb-sys-connect`), packing a 16-byte `sockaddr_in` (family u16 = 2, port u16 network-order, 4-byte addr) as a pure chirality surface function `pack-sa-in` (`parse-quad` → pack, no I/O — the big-endian port is the one ABI trap). Decode the return → `conn-err` (close fd, E107) / `conn-r Sock`, assemble `ConnR` via `ti-cona` (the `nb-sock-connect-t` precedent). WireGuard/Tailscale is the transport crypto, so no TLS in the chirality path. crossing-wraps row + `nb-sock-connect-in-t` in `sys-lib`. **Scope: client connect only**; host is a dotted-quad IP (DNS resolution, AF_INET6, and server bind/listen/accept deferred)
kind: BUILD-PROPER
reference_class: OURS/SPEC
ours_source: (none)
status: reviewed
updated: 2026-08-12
---

# E129 — Native `sock-connect-in` (AF_INET TCP connect): the mesh/Tailscale client crossing that lets `http.chiral` reach a local model endpoint with zero TLS — lower `sock-connect-in : (=> Str I64 ConnR)` (dotted-quad host, port) to native: a fused TAL body doing `socket(AF_INET=2, SOCK_STREAM=1, 0)` (nr 41, reuse `nb-sys-socket`) then `connect(fd, sockaddr_in, 16)` (nr 42, reuse `nb-sys-connect`), packing a 16-byte `sockaddr_in` (family u16 = 2, port u16 network-order, 4-byte addr) as a pure chirality surface function `pack-sa-in` (`parse-quad` → pack, no I/O — the big-endian port is the one ABI trap). Decode the return → `conn-err` (close fd, E107) / `conn-r Sock`, assemble `ConnR` via `ti-cona` (the `nb-sock-connect-t` precedent). WireGuard/Tailscale is the transport crypto, so no TLS in the chirality path. crossing-wraps row + `nb-sock-connect-in-t` in `sys-lib`. **Scope: client connect only**; host is a dotted-quad IP (DNS resolution, AF_INET6, and server bind/listen/accept deferred)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E129, the native `sock-connect-in` crossing: an AF_INET TCP
  client connect that lowers `(=> Str I64 ConnR)` (dotted-quad host, port) to a
  fused TAL body of `socket(2,1,0)` then `connect(fd, sockaddr_in, 16)`.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** the socket floor is AF_UNIX-only today. The
  `nb-sock-connect-t` precedent builds a `sockaddr_un`; there is no `sockaddr_in`
  packer and no AF_INET connect. `http.chiral` still rides the Python urllib shim
  (`@impl("http-request")`, impl_ports.py). This crossing is the client half that
  lets `http.chiral` reach a local model endpoint over the mesh with zero TLS:
  WireGuard/Tailscale already supplies transport crypto at the network layer, so
  the chirality path is plain HTTP over a connected socket. Client connect only. DNS
  resolution, AF_INET6, and server bind/listen/accept are deferred.

## 2. Research

- **Reference class:** OURS/SPEC. OURS is the in-tree socket floor (sys-tal.chiral
  `nb-sa-un-pack-t`/`nb-sock-connect-t`, ports.chiral `Sock`/`ConnR`,
  crossing-wraps.chiral). SPEC is Linux `socket(2)`/`connect(2)`/`ip(7)`/
  `sockaddr_in(3type)`.
- **Key findings:**
  1. `sockaddr_in` is `{sin_family u16; sin_port u16; sin_addr 4 bytes}` — 8
     payload bytes, zero-padded to 16 (sin_zero). `in_port_t` is u16,
     `in_addr_t` is u32. (sockaddr_in(3type), man7.org)
  2. "sin_port and sin_addr are stored in network byte order." The port is
     big-endian, high byte first. This is the trap: the E109 `bput-u16-le`
     precedent is little-endian and must not be copied for the port.
     (sockaddr_in(3type), ip(7), man7.org)
  3. `sin_family` must be AF_INET; ip(7) notes Linux returns EINVAL when it is
     missing. It is a host-order u16, value 2, so bytes `[02 00]` on x86-64.
     (ip(7), man7.org)
  4. `connect(sockfd, addr, addrlen)` connects a SOCK_STREAM socket to `addr`;
     `addrlen` is the address size, 16 for `sockaddr_in`. (connect(2), man7.org)

## 3. Conventional (other-language) approach

The OURS baseline is CPython `socket` — the same shape the frozen Python shim
uses, and what the `http-request` urllib fallback hides.

```python
import socket

def connect_in(host, port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)  # hides socket(2)
    try:
        s.connect((host, port))  # hides DNS + sockaddr_in pack + connect(2)
        return s
    except OSError as e:
        s.close()                # a line you must remember
        raise
```

- **Assumptions it bakes in:** socket() and connect() are ambient, invisible
  effects — no effect row, purity untracked. The fd is a raw int, aliasable and
  reusable; use-after-close is a runtime error, not a type error. connect()
  resolves the hostname inside the call (getaddrinfo), so name resolution and
  connect are conflated. Errors are exceptions (control flow), not a returned
  sum; the close-on-error is manual and forgettable. sockaddr packing and byte
  order are libc's problem — nothing in the type says "network byte order".
  No totality bound: connect() can block indefinitely.

## 4. The chirality idea

- **Chirality features in play:** QTT usage; the effect membrane (`->` vs `=>`);
  ports and linear capabilities; categories A/B/C; refinement; totality.
- **The reframing:** the connected socket is a linear port `(1 s Sock)` carried
  in `ConnR`. Parsing the dotted-quad and packing the `sockaddr_in` are pure
  `->` functions — they hold and repack bytes, they do no I/O, so their empty
  effect row is a typed fact. The only `=>` step is the fused socket+connect
  crossing, and it takes the destination as a parameter: no ambient authority.
  The one place byte order is decided is a typed, named helper, not a libc call.
  A fallible connect returns a sum; the error branch closes the fd before
  returning, so "forgot to close" is untypeable rather than forgettable.
- **What chirality makes impossible here:** returning the same `Sock` twice or
  dropping it (linear, used exactly once); using the fd after it moved into
  `conn-r`; a pure function performing the connect; a little-endian port packed
  silently; an error path that leaks the socket fd.

## 5. Chirality example (fleshed)

```chirality
(import "prelude")
(import "ports")

; =====================================================================
; E129 — sock-connect-in: the AF_INET TCP client connect crossing.
; Reaches a local model endpoint over the mesh/Tailscale with zero TLS.
; WireGuard is the transport crypto, so the chirality path is plain HTTP
; over a connected AF_INET socket.
;
; Result type (already in ports.chiral; restated for context):
;   (data ConnR () (conn-r (1 s Sock)) (conn-err (msg Str)))
; Sock is a porttype. The E123 carrier lowers it to one word (nt-i64),
; so a connected socket round-trips TAL as a single register.
; =====================================================================

; ---- dotted-quad host: a boundary sum, parsed ONCE, pure (no crossing) ----

(data Quad ()
  (quad (a I64) (b I64) (c I64) (d I64)))

(data QuadR ()
  (quad-ok (q Quad))
  (quad-err (msg Str)))

(declare parse-quad (-> Str QuadR))
; Splits (str->bytes s) on '.' (46), parses each field as an octet 0-255.
; Empty field, non-numeric field, out-of-range field, or a field count
; other than 4 -> (quad-err "...").
; ; ... mechanical byte-loop, structural recursion on the byte index.

; ---- sockaddr_in packer: the ONE ABI fact that matters is byte order ----
; 16 bytes (sockaddr_in(3type)):
;   off 0 : sin_family = 2 (AF_INET), u16 host order (little-endian on x86)
;   off 2 : sin_port, u16 NETWORK order (big-endian: high byte first)
;   off 4 : sin_addr, four octets verbatim
;   off 8 : sin_zero, eight zero bytes
; The port is big-endian. The E109 bput-u16-le precedent is little-endian
; and must NOT be copied here.

(def byte (-> I64 Bytes)        ; low 8 bits of n, as a one-byte cell
  (lam (n) (bslice (pack-u16 n) 0 1)))

(def pack-sa-in (-> Quad I64 Bytes)
  (lam (q port)
    (case q
      ((quad a b c d)
        (let ((phi (/ port 256))   ; network byte order: high byte first
              (plo (% port 256)))  ; low byte second
          (bcat (pack-u16 2)                            ; sin_family = AF_INET
            (bcat (bcat (byte phi) (byte plo))          ; sin_port, big-endian
              (bcat (bcat (bcat (bcat (byte a) (byte b))
                                  (byte c)) (byte d))   ; sin_addr
                (brepeat (byte 0) 8)))))))))                   ; sin_zero

; ---- the crossing: socket + connect cross the effect membrane ----

(declare sock-connect-in (=> Str I64 ConnR))
; ports.chiral extern (bare types, no named params). crossing-wraps maps
; sock-connect-in -> nb-sock-connect-in. The wrapper parses the quad,
; packs the sockaddr_in, and calls the fused TAL body. That body does
; socket(2, 1, 0) (nr 41, reuse nb-sys-socket) then connect(fd, sa, 16)
; (nr 42, reuse nb-sys-connect); on failure it closes fd (E107) and
; assembles (conn-err ...), on success (conn-r fd), via ti-cona, mirroring
; nb-sock-connect-t (E127).

(declare nb-sock-connect-in-t (=> Bytes ConnR))
; fused TAL body; see the comment above. The Bytes is the packed sockaddr_in.

; ---- wrapper spine: parse, pack, cross, then case the sum ----

(declare nb-sock-connect-in (=> Str I64 ConnR))
(def nb-sock-connect-in
  (lam (host port)
    (case (parse-quad host)
      ((quad-err msg) (conn-err msg))
      ((quad-ok q) (nb-sock-connect-in-t (pack-sa-in q port))))))
```

- **Knobs to modify:** the host argument type (`Str` dotted-quad vs a pre-parsed
  `Quad` — passing `Quad` moves parsing to the caller); the hardcoded family
  byte 2 (AF_INET6 needs family 10 and a 28-byte packer); the port byte split
  (`(/ port 256)` high, `(% port 256)` low — flipping to `pack-u16 port`
  reintroduces the E109 little-endian bug); refinement bounds on the octets
  (`(refine I64 (>= 0) (<= 255))` if parse-quad proves them).
- **Deliberately omitted:** DNS resolution (dotted-quad only, no getaddrinfo);
  AF_INET6 and server bind/listen/accept; the `http.chiral` A3 step-2 rewrite
  that consumes this extern; the exact errno-to-`Str` message formatting; the
  byte-level TAL sequence of `nb-sock-connect-in-t` (mirrors `nb-sock-connect-t`).

## 6. Use / modify notes

- **Lands in:** surface extern `sock-connect-in` plus the pure surface
  `parse-quad`/`pack-sa-in` and the `nb-sock-connect-in` wrapper in
  `scaffold/lib/ports.chiral`; the `nb-sock-connect-in-t` TAL body plus its
  `sys-lib` entry in `scaffold/lib/sys-tal.chiral`; a `sock-connect-in ->
  nb-sock-connect-in` row in `scaffold/lib/crossing-wraps.chiral`. No new
  syscall numbers: 41/42 already registered in `target-linux.chiral`.
- **Conformance target:** CPython `socket.socket(AF_INET,
  SOCK_STREAM).connect(("100.64.0.5", 11434))` reachability is the oracle.
  `sock-connect-in "100.64.0.5" 11434` returns `(conn-r s)` with `s` a live
  connection on success, and `(conn-err msg)` with the fd already closed on a
  refused port — no fd leak, no uncaught exception.
- **Open questions:** where parse-quad lives (it must stay `->` pure, off the
  membrane); whether `conn-err` carries a formatted `Str` or should grow an
  errno field (`(conn-err (errno I64))` is more honest than a `Str` tag); whether
  `sock-connect-in` shares the `ConnR` decode with `sock-connect` or wants its
  own errno mapping (ECONNREFUSED vs ENOENT).
- **Related:** [[E127-sock-connect]] (the AF_UNIX connect precedent),
  [[E125-sock-use]] (send/recv, already built), [[E126-socketpair]],
  [[E123-native-porttype-carrier]] (Sock lowers to one word), [[E124-adopt-fd]];
  the E107 sock-close on the conn-err path and the E109 bput-u16-le byte-order
  trap (no example file yet).
