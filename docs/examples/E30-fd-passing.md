---
element: E30
slug: fd-passing
title: "fd passing: sendmsg + SCM_RIGHTS (sock-send-fd) — the hard one"
kind: REPLACE-CRUTCH
reference_class: SPEC
ours_source: scaffold/chirality/impl_ports.py (socket.send_fds), scaffold/lib/sys-tal.chiral (the hand-tal floor)
abi_ref: examples/refs/ref-fdpass.md
status: drafted
updated: 2026-07-22
---

# E30 — fd passing: `sendmsg` + `SCM_RIGHTS` (the struct-passing crossing)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> **ABI facts are in [`refs/ref-fdpass.md`](refs/ref-fdpass.md)** (script-derived,
> local sources); this example cites it and never re-types a number.

## 1. Scope

- **Element:** E30, moving an open file descriptor to another process over an
  `AF_UNIX` socket — `sendmsg(2)` carrying a `SCM_RIGHTS` control message. The
  scaffold's `sock-send-fd` extern, today a CPython `socket.send_fds`.
- **Kind:** REPLACE-CRUTCH — the transport is Python; the destination is
  hand-tal at the sys floor (`lib/sys-tal.chiral`, the E51 lane).
- **Why chirality needs its own:** it is the catalog's named **hard one** — the
  first crossing that passes a **struct**, not a register of scalars. Every sys
  crossing built so far (`write`/`read`/`lseek`/`mmap`/…) hands the kernel
  integers; `sendmsg` hands it a pointer to a `msghdr` that itself points at a
  `cmsghdr` carrying the fd. It is the real dependency of the tomodachi: the
  Pool's memfd reaches the compositor only through `sock-send-fd`. And it is
  the one crossing where **possession transfer is literal** — the linear `Fd`
  is consumed here because the kernel genuinely moves the descriptor to the
  peer (Adhikara's "move" as an actual kernel operation, not a metaphor).

## 2. Research

- **Reference class:** SPEC — the Linux `sendmsg`/`cmsg` ABI. Tier R (always
  readable). All concrete values are **derived locally** by
  `examples/refs/gen-fdpass.py` and tabled in `ref-fdpass.md`; the generator
  cross-checks its CMSG arithmetic against Python's own `socket.CMSG_LEN` /
  `CMSG_SPACE` so a wrong number cannot survive.
- **Key findings (from the ref):**
  1. `sendmsg` = syscall **46** (x86-64); args `(sockfd, &msghdr, flags)`.
  2. An fd rides in a control message: `cmsg_level = SOL_SOCKET (1)`,
     `cmsg_type = SCM_RIGHTS (1)`, data = the raw `int` fd.
  3. Layouts (LP64, ctypes-computed): `msghdr` is 56 bytes with
     `msg_control` at **offset 32** and `msg_controllen` at **40**; `cmsghdr`
     is a 16-byte header (`cmsg_len@0` u64, `cmsg_level@8` i32,
     `cmsg_type@12` i32) then the fd at **offset 16**.
  4. For one fd: `cmsg_len = CMSG_LEN(4) = 20`, control buffer =
     `CMSG_SPACE(4) = 24` bytes. These two constants are the whole ceremony.
  5. `msg_namelen` is a 4-byte `socklen_t` at offset 8 with **4 bytes of
     padding** before `msg_iov` at 16 — the alignment trap that makes this a
     struct-builder problem, not a field-list problem.

## 3. Conventional (other-language) approach

The C idiom — a stack struct, pointer arithmetic macros, and an `int` fd with
no ownership:

```c
struct msghdr msg = {0};
struct iovec iov = { .iov_base = payload, .iov_len = 1 };
char cbuf[CMSG_SPACE(sizeof(int))];              /* 24 bytes */
msg.msg_iov = &iov; msg.msg_iovlen = 1;
msg.msg_control = cbuf; msg.msg_controllen = sizeof(cbuf);
struct cmsghdr *c = CMSG_FIRSTHDR(&msg);
c->cmsg_level = SOL_SOCKET; c->cmsg_type = SCM_RIGHTS;
c->cmsg_len = CMSG_LEN(sizeof(int));
memcpy(CMSG_DATA(c), &fd, sizeof(int));          /* fd is just an int */
sendmsg(sock, &msg, 0);                          /* sender still "has" fd */
```

The scaffold's Python is the same shape, one call up:

```python
# impl_ports.py — the crutch
def _sock_send_fd(sock, payload, fd):
    socket.send_fds(sock, [payload], [fd])       # ambient, fd untracked
    return sock
```

- **Assumptions it bakes in:** the fd is a plain `int` — copyable, forgeable,
  and *still held by the sender after the send* (a double-holder the kernel
  now permits); the struct is raw stack memory with macro-computed offsets and
  no type; ambient authority (anyone with the sock can send any fd); errors are
  `errno`/exceptions, invisible in the signature.

## 4. The chirality idea

- **Chirality features in play:** linear ports (the `Fd` is quantity-1, moved not
  copied), byte cells (`bnew`/`bput`/`bptr` — the struct is a `[len][payload]`
  cell), the sysface confinement mark, result sums for errno, the two-facet
  membrane (the send is a crossing in the row; the `Fd` and `Sock` are
  possession).
- **The reframing:** the `msghdr`+`cmsghdr` is **built in a byte cell** exactly
  the way `bytes-tal.chiral` packs wire frames — `bnew` a 24-byte control cell
  and a 56-byte msghdr cell, `bput` the fields at the ref's offsets, `bptr` to
  hand the kernel the addresses. The fd is written into the control cell's data
  slot (offset 16). Because the `Fd` parameter is **linear**, `sock-send-fd`
  *consumes* it: after the send the sender provably no longer holds it — which
  is the truth the kernel enforces anyway (the fd now lives in the peer), made
  a typed fact instead of a footgun. The crossing returns the `Sock` moved back
  plus a result sum.
- **What chirality makes impossible here:** keeping the fd after sending it (linear
  consumption — the double-holder the C API allows is untypeable); building the
  struct with a wrong-typed field (the cell is bytes, but the *builder* is
  typed chirality using named ref offsets, and the sysface mark confines the raw
  `sys` instruction to this one library); reaching `sendmsg` without holding
  the `Sock` (no ambient authority); an unhandled errno (it is a constructor).

## 5. Chirality example (fleshed)

Two layers: the typed face + result shape (upper), and the hand-tal builder
(floor). Offsets and constants are **named from the ref**, never inlined blind.

```chirality
; ================= upper: the typed face (lib/ports.chiral style) ============
(import "prelude")
(import "ports")        ; Sock, Fd, fd-view (E51), the linear porttypes

; The fd MOVES: (1 f Fd) is consumed; the Sock is returned for the next use.
(data SendFdR ()
  (sfd-ok   (1 s Sock))                 ; sent; the fd is gone (moved to peer)
  (sfd-err  (errno I64) (1 s Sock) (1 f Fd)))  ; -errno; fd NOT moved, back to you

;   (extern sock-send-fd (=> (1 s Sock) Bytes (1 f Fd) SendFdR))
; the payload Bytes is the ordinary iovec data (>=1 byte; SCM_RIGHTS wants a
; real message to ride along).

; ================= floor: build the structs in byte cells ===================
; Offsets/sizes are ref-fdpass.md, x86-64 LP64. A control cell of CMSG_SPACE(4)
; = 24 bytes, and a msghdr cell of 56 bytes. Multi-byte stores are the
; pack-u32/u64 idiom from bytes-tal.chiral, lifted to tal.
;
; control cell (24 bytes):
;   [0..8)  cmsg_len   = 20   (CMSG_LEN(4))            u64
;   [8..12) cmsg_level = 1    (SOL_SOCKET)             i32
;   [12..16)cmsg_type  = 1    (SCM_RIGHTS)             i32
;   [16..20)fd         = <the int fd>                  i32
;
; msghdr cell (56 bytes), connected socket so name is null:
;   [0..8)  msg_name       = 0
;   [8..12) msg_namelen    = 0
;   [16..24)msg_iov        = &iov      (one iovec over the payload cell)
;   [24..32)msg_iovlen     = 1
;   [32..40)msg_control    = &control-cell
;   [40..48)msg_controllen = 24        (CMSG_SPACE(4))
;   [48..52)msg_flags      = 0
;
; then: sys 46 (sendmsg) with args (sockfd, &msghdr, 0)

; Hand-tal skeleton (tal-ir; mirrors nb-sys-mmap's ti-sys + nb-sys-write's
; ti-bptr discipline in lib/sys-tal.chiral). Register numbers illustrative;
; ti-put-u32/u64/ptr are the little-endian store helpers this element needs
; (see open questions — the "structs at the floor" vocabulary).
;
; (def nb-sys-send-fd TFn
;   (tfn "nb-sys-send-fd" 3 N            ; args: r0 sockfd, r1 payload-cell, r2 fd
;     ; --- control cell (24B) ---
;     (t-seq (ti-const  4 24)   (t-seq (ti-bnew  5 4)      ; r5 = control cell
;     (t-seq (ti-put-u64 5 0 20)                            ; cmsg_len = CMSG_LEN(4)
;     (t-seq (ti-put-u32 5 8 1)                             ; cmsg_level SOL_SOCKET
;     (t-seq (ti-put-u32 5 12 1)                            ; cmsg_type  SCM_RIGHTS
;     (t-seq (ti-put-u32 5 16 2)                            ; fd bytes (r2)
;     ; --- iovec (16B) over the payload cell ---
;     (t-seq (ti-bptr 6 1) (t-seq (ti-blen 7 1)             ; base=&payload,len
;     (t-seq (ti-const 8b 16) (t-seq (ti-bnew 8 8b)
;     (t-seq (ti-put-ptr 8 0 6) (t-seq (ti-put-u64 8 8 7)   ; iov = {base,len}
;     ; --- msghdr (56B) ---
;     (t-seq (ti-const 9b 56) (t-seq (ti-bnew 9 9b)
;     (t-seq (ti-put-u64 9 0 0)  (t-seq (ti-put-u32 9 8 0)  ; name=0, namelen=0
;     (t-seq (ti-bptr 10 8) (t-seq (ti-put-ptr 9 16 10)     ; msg_iov=&iov
;     (t-seq (ti-put-u64 9 24 1)                            ; msg_iovlen=1
;     (t-seq (ti-bptr 11 5) (t-seq (ti-put-ptr 9 32 11)     ; msg_control=&cbuf
;     (t-seq (ti-put-u64 9 40 24)                           ; msg_controllen=24
;     (t-seq (ti-put-u32 9 48 0)                            ; msg_flags=0
;     ; --- the crossing ---
;     (t-seq (ti-bptr 12 9) (t-seq (ti-const 0f 0)
;            (ti-sys 13 46 (cons 0 (cons 12 (cons 0f nil))))))  ; sendmsg
;       ...)))))))))))))))))))))))))

; ================= use site (unchanged shape from the tomodachi) ============
(def share-pool-fd (=> (1 s Sock) Bytes (1 f Fd) SendFdR)
  (lam (s payload f)
    (case (fd-view f)                     ; E51: sysface-only view of the raw int
      ((fd-view-r raw f2)                 ; raw fd int; f2 rebuilt around raw
       (sock-send-fd s payload f2)))))    ; the crossing consumes f2 (kernel move)
```

- **Knobs to modify:** payload contents (any ≥1-byte message rides with the
  fd); multiple fds (control data becomes `n*4` bytes, `cmsg_len = CMSG_LEN(4n)`,
  `controllen = CMSG_SPACE(4n)` — the ref's macros parameterize on `n`);
  `MSG_CMSG_CLOEXEC` on the recv side; the result-sum granularity.
- **Deliberately omitted:** `recvmsg` (47) + `CMSG_FIRSTHDR`/`CMSG_DATA`
  extraction on the receive side (the dual; same ref, mirror offsets); the
  multi-byte store helpers' exact tal spelling (open question); the
  `runtime.py` dispatch wiring (E51's implementation run).

## 6. Use / modify notes

- **Lands in:** `lib/sys-tal.chiral` (the `nb-sys-send-fd` crossing, sysface-
  marked) + the E51 binding table (`sock-send-fd` → `nb-sys-send-fd`);
  `impl_ports.py`'s `socket.send_fds` retires as transport.
- **Conformance target:** differential vs CPython `socket.send_fds` over a real
  `socketpair` — send an fd, recv it on the peer, confirm the received fd names
  the same open file (fstat st_ino match), byte-identical payload. The
  reference machine performs the *same* real `sendmsg` (as the sys slices
  already do for `write`/`mmap`), so native and reference are checked against
  one kernel.
- **Open questions:** (1) **fd consumption matches kernel truth, exactly** — on
  a *failed* send the fd was NOT moved and is still the sender's; on success it
  is gone. The result sum returns the `Fd` only on the `sfd-err` arm, so the
  linear discipline and the kernel's actual behavior agree by construction —
  the negative test (recover and reuse the fd after EMFILE/EPIPE) is the point.
  (2) **multi-byte store helpers at the floor** — `bput` is one byte; `sendmsg`
  needs u32/u64/ptr stores at computed offsets, so tal wants `ti-put-u32/u64`
  (or the builder emits byte-loops via the pack-u32 idiom). A small
  tal-vocabulary addition (edge 6) shared by *every* future struct crossing —
  the first real payload of "structs at the floor". (3) pointer stores mean an
  arena address must be materializable as an i64 in a cell — `bptr` gives the
  address; storing it needs `ti-put-ptr`.
- **Related:** [[E51-sys-linkage]] (the binding table + fd-view this rides),
  [[E29-sockets]] (the socket the fd crosses; sibling lane-A crossing),
  [[E21-arena]] (the memfd/Pool whose fd this shares), [[E70-effectful-lowering]]
  (the row shadow naming this crossing), [[E28-mmap-crossings]] (sibling struct-
  free sys slices), `refs/ref-fdpass.md` (the ABI).
