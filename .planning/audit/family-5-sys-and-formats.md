# Family 5 — Syscall layer + external formats (E28–E37)

**Elements:** E28–E33 (REPLACE-CRUTCH, the `impl_ports.py` → sys-crossing arc) +
E34–E37 (external formats). All Tier R (SPEC — Linux syscall ABI, ELF/gABI,
Wayland wire, PNG; musl is the SPEC-adjacent syscall reference, name-only here
since egress is blocked).

**State of the family.** The recipe is proven and cheap: five crossings already
live at the tal floor (`scaffold/lib/sys-tal.chiral` — write 1, read 0, lseek 8,
memfd_create 319, ftruncate 77), each one = a `LIB_SIGS` line in
`scaffold/chirality/native.py:69-97` + a hand-authored `tfn` + a differential test in
`scaffold/tests/test_native.py:367-518`. The generic `_sys` path (checker
`tal.py:145-151`, reference `tal.py:263-271`, emitter `mach-x64.chiral:253-290`)
handles **any all-integer syscall up to 6 args with zero new Python or emitter
code** — including 6-arg `mmap`. What remains splits cleanly: eight crossings are
all-integer (S, recipe verbatim), five need a fixed struct built in a byte cell
(M — sockaddr_un, pollfd, timespec, sv[2], wstatus), and two need structs that
contain **pointers to other cells** (L — `msghdr`/`cmsghdr` for SCM_RIGHTS, and
`execve`'s argv/envp arrays). The pointer-in-struct step needs exactly one new
pure helper (`nb-put64`, ~nb-copy-sized) after which the L cases become
mechanical byte-table filling — the build-sheets below are those tables. E35/E36
are already chirality and are the template for all binary-format work; E34 (ELF) is
unbuilt but is *pure byte-building in wire.chiral's exact idiom* plus a fill-in
header table. One structural gap is not this family's to close but gates its
payoff: nothing in chirality-land can *call* the sys face yet (lowered pure code is
forbidden from it by design; effectful upper code has no linkage to tal
functions), so each pass here delivers crossing + differential test, while
actually retiring `impl_ports.py` needs the upper-effectful→sys-face linkage
(flagged cross-family, candidate E51).

## The master crossing table (x86-64, copy-ready)

Syscall convention (`mach-x64.chiral:253-257`): nr in rax (immediate in `ti-sys`),
args in **rdi rsi rdx r10 r8 r9**, result in rax, rcx/r11 clobbered (harmless:
nothing is live in registers between chunks). Errors return as `-errno` in rax
(−4095..−1). Buffer args take the **payload address** of a cell via `ti-bptr`
(= cell+8; `sys-tal.chiral:9-12`).

| crossing | nr | rdi | rsi | rdx | r10 | r8 | r9 | class |
|---|---|---|---|---|---|---|---|---|
| close | 3 | fd | | | | | | **S** |
| mmap | 9 | addr (0) | length | prot | flags | fd | offset | **S** (6 args, all-int) |
| mprotect | 10 | addr | length | prot | | | | **S** |
| munmap | 11 | addr | length | | | | | **S** |
| socket | 41 | domain | type | protocol | | | | **S** |
| listen | 50 | fd | backlog | | | | | **S** |
| accept | 43 | fd | 0 (NULL) | 0 (NULL) | | | | **S** (peer addr discarded) |
| accept4 | 288 | fd | 0 | 0 | flags | | | **S** |
| dup2 | 33 | oldfd | newfd | | | | | **S** |
| fork | 57 | | | | | | | **S** (semantics! see E33) |
| exit_group | 231 | code | | | | | | **S** (noreturn) |
| sendto (=send) | 44 | fd | buf* | len | flags | 0 | 0 | **S+** (write pattern) |
| recvfrom (=recv) | 45 | fd | buf* | len | flags | 0 | 0 | **S+** (read pattern) |
| open | 2 | path* (NUL-term) | flags | mode | | | | **S+** (memfd name trick) |
| connect | 42 | fd | sockaddr_un* | addrlen | | | | **M** (110-byte struct) |
| bind | 49 | fd | sockaddr_un* | addrlen | | | | **M** (same struct) |
| socketpair | 53 | domain | type | protocol | int sv[2]* out | | | **M** (8-byte out cell) |
| poll | 7 | pollfd[]* in+out | nfds | timeout_ms | | | | **M** (8 B/entry, revents written back) |
| clock_gettime | 228 | clk_id (MONOTONIC=1) | timespec* out | | | | | **M** (16-byte out cell) |
| wait4 | 61 | pid | int* wstatus out | options | rusage* (0) | | | **M** (4-byte out cell) |
| sendmsg | 46 | fd | msghdr* | flags | | | | **L** (pointers inside struct) |
| recvmsg | 47 | fd | msghdr* in+out | flags | | | | **L** |
| execve | 59 | path* | argv** | envp** | | | | **L** (pointer arrays) |

Classes: **S** = registers only, `nb-sys-lseek` copies verbatim. **S+** = one
`ti-bptr`/`ti-blen`, `nb-sys-write`/`nb-sys-memfd` copy verbatim. **M** = build
or read one flat struct in a `ti-bnew` cell (byte stores + `nb-unpack16/32`
readback). **L** = struct embeds absolute addresses of *other* cells (needs the
`nb-put64` helper; build-sheets below).

All numbers are standard x86-64 Linux and I am confident of every nr above.
Flag constants used later: PROT_READ/WRITE/EXEC = 1/2/4; MAP_SHARED/PRIVATE/
FIXED/ANONYMOUS = 1/2/0x10/0x20; AF_UNIX=1; SOCK_STREAM=1; SEEK_SET/CUR/END =
0/1/2; POLLIN/POLLOUT/POLLERR/POLLHUP = 0x1/0x4/0x8/0x10; SOL_SOCKET=1;
SCM_RIGHTS=1; CLOCK_MONOTONIC=1; MFD_CLOEXEC=1; O_WRONLY|O_CREAT|O_TRUNC =
0x241 (=577), mode 0755 = 493. VERIFY: SOCK_CLOEXEC=0x80000, O_CLOEXEC=0x80000
(believed, unverifiable offline).

## The proven recipe (referenced by every element below)

From the built slices — a new crossing is exactly:

(a) one sig line in `native.py` `LIB_SIGS` (`native.py:90-96`), e.g.
    `"nb-sys-lseek": ([I64, I64, I64], I64),`
(b) a hand-authored `tfn` in `lib/sys-tal.chiral` + append to `sys-lib`
    (`sys-tal.chiral:52-55, 81-83`),
(c) a differential test in `tests/test_native.py` run both natively and on
    `TalMachine` (`test_native.py:458-481` is the lseek pair).

The checker marks it `sysface` automatically (`tal.py:145-156`); the backend's
membrane assertion (`native.py:374-378`) requires the `nb-sys-` name prefix.
No emitter, checker, or interpreter change for ≤6 integer args.

Two reference-machine disciplines that the flat recipe hides (name them once,
they bind every M/L crossing):

1. **bptr lifetime** — `TalMachine._bptr` (`tal.py:273-279`) pins `from_buffer`
   views and `_sys` clears the pins after each call (`tal.py:270`). Addresses of
   `ti-bnew` cells (bytearrays, shared memory) stay valid for the whole
   function; addresses of `ti-lit` literals (`bytes`, `from_buffer_copy`) die at
   the first `ti-sys`. Rule: **any cell whose address is embedded in a struct or
   read back after the call must come from `ti-bnew`, and one function issues at
   most one syscall per set of taken addresses.**
2. **zero-init divergence** — reference `bnew` gives a zeroed bytearray
   (`tal.py:238`); native `x-bnw` (`mach-x64.chiral:216-225`) only bumps. Today
   they agree because the bump never rewinds over virgin anonymous-mmap arena
   (zero pages) — an *accident*, not a contract. Struct-building crossings must
   explicitly store every byte they rely on (or `nb-fill` the cell), as
   `nb-sys-memfd` already does for its 1-byte name (`sys-tal.chiral:63-71`).

Alignment note: natively a cell payload is 8-aligned (8-byte len word, bump
rounds to 8 — `mach-x64.chiral:199-205`), which satisfies msghdr/cmsg/timespec
alignment. On the reference machine the bytearray buffer alignment is CPython's
allocator's (≥8 in practice on x86-64 glibc — VERIFY, believed safe).

---

## E28 — mmap/munmap/mprotect/close as sys crossings   [REPLACE-CRUTCH · Tier R]

**Lives now:**
- `scaffold/chirality/native.py:104-116` — ctypes `mprotect` (the W^X flip)
- `scaffold/chirality/native.py:404-421` — `mmap.mmap` for code buffer + arena, `_mprotect` call
- `scaffold/chirality/impl_ports.py:174-191` — `pool-create`/`pool-close` (`os.memfd_create` + `mmap.mmap`); memfd/ftruncate halves already chirality (`lib/sys-tal.chiral:63-79`)
- `scaffold/chirality/impl_ports.py:203-206` — `fd-close` via `os.close`

**Verdict:** REDO — the crossings exist only as CPython/ctypes conveniences;
they must become four sys-tal functions. This is the flattest remaining slice in
the whole catalog: all four are all-integer.

**Explainer:** `mmap` is the family's keystone: it completes the memfd →
ftruncate → **mmap** chain the push log names as the next milestone (a
chirality-created, chirality-sized, chirality-mapped arena), and with `mprotect` it is the
whole W^X loader vocabulary. All six `mmap` args are plain integers; the return
is a pointer-as-I64 (or −errno) — exactly what `ti-sys` already produces and the
tal floor already treats as a word. The emitter's syscall path was built for
six args from day one: `sys-modrm` (`mach-x64.chiral:260-266`) covers
rdi/rsi/rdx/r10/r8/r9, so nothing below the `tfn` changes. The trap is not the
crossing but its *result discipline*: an address returned by `nb-sys-mmap` is a
raw I64 with no cell header — `bget`/`bput` cannot touch it (they address
cells), so consuming the mapped region from chirality needs either the region types
of E41 or, near-term, pointing the emitted `heapptr`/`heapend` cells at it
(which today only the Python loader does, `native.py:411-416`). Name that
honestly: this pass delivers the crossings + tests against real mappings; the
*self-hosted arena wiring* is the follow-on that also needs the linkage seam
(cross-family flag F1). MAP_FIXED should be refused/never used from chirality
(overwrite hazard); the loader use is `MAP_PRIVATE|MAP_ANONYMOUS` (0x22) and
`MAP_SHARED` (1) for pool memfds.

**Translation dossier:**

*Source exemplar* — the proven all-integer crossing, `lib/sys-tal.chiral:52-55`:

```lisp
(def nb-sys-lseek TFn
  (tfn "nb-sys-lseek" 3 4
    (t-seq (ti-sys 3 8 (cons 0 (cons 1 (cons 2 nil))))
      (t-ret 3))))
```

*Target sketch* — same shape, wider (every construct from `sys-tal.chiral`):

```lisp
; mmap(addr, len, prot, flags, fd, off) -> address (or -errno). nr 9.
(def nb-sys-mmap TFn
  (tfn "nb-sys-mmap" 6 7
    (t-seq (ti-sys 6 9 (cons 0 (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 nil)))))))
      (t-ret 6))))

; munmap(addr, len) -> 0 or -errno. nr 11.
(def nb-sys-munmap TFn
  (tfn "nb-sys-munmap" 2 3
    (t-seq (ti-sys 2 11 (cons 0 (cons 1 nil))) (t-ret 2))))

; mprotect(addr, len, prot) -> 0 or -errno. nr 10.
(def nb-sys-mprotect TFn
  (tfn "nb-sys-mprotect" 3 4
    (t-seq (ti-sys 3 10 (cons 0 (cons 1 (cons 2 nil)))) (t-ret 3))))

; close(fd) -> 0 or -errno. nr 3.
(def nb-sys-close TFn
  (tfn "nb-sys-close" 1 2
    (t-seq (ti-sys 1 3 (cons 0 nil)) (t-ret 1))))
```

*Mechanical recipe:*
1. COPY — the four `tfn`s above into `sys-tal.chiral`; append to `sys-lib`
   (`sys-tal.chiral:81-83` shows the cons-list form).
2. COPY — `LIB_SIGS` lines: `"nb-sys-mmap": ([I64]*6, I64)` etc. (rule: params
   all I64, result I64; `native.py:92-96` is the block to extend).
3. TRANSLATE — tests from `test_native.py:483-507` (memfd tests): memfd →
   ftruncate(4096) → `nb-sys-mmap(0, 4096, 3, 1, fd, 0)` → assert result > 0
   → write through the fd, read the mapping back via ctypes in the *test only*
   → `nb-sys-mprotect(addr, 4096, 1)` → `nb-sys-munmap` → `nb-sys-close`.
   Run both `self.compiled[...]` and `TalMachine` variants.
4. NEW — nothing.

**Dependencies:** none (memfd/ftruncate/lseek already in). Unblocks: chirality-side
arena, E20/E21 loader self-hosting, E34's file-writing driver, E29 fd hygiene.

**Est. pass size:** S.

---

## E29 — sockets: socket/connect/bind/listen/accept/send/recv   [REPLACE-CRUTCH · Tier R]

**Lives now:**
- `scaffold/chirality/impl_ports.py:90-159` — `sock-connect`, `sock-listen`, `sock-accept`, `lsock-close`, `sock-send` (sendall), `sock-recv`, `sock-close`, all via CPython `socket`
- Typed face: `scaffold/lib/ports.chiral:34-54` (externs + `RecvR`/`AccR` result data)
- Runtime port value convention: `("sock", socket)` — `impl_ports.py:8`, checked at the bridge `bridge.py:19,41-61`

**Verdict:** REDO — CPython socket objects must become raw fds crossed at the
tal floor. Slices cleanly into an S half and an M half.

**Explainer:** Everything here is AF_UNIX/SOCK_STREAM only (the frozen port
set), which kills most of the sockaddr zoo: `socket`/`listen` are pure-integer;
`accept` with NULL addr/addrlen is pure-integer (we never want the peer
address); and on a connected stream socket **send/recv are `sendto`/`recvfrom`
with NULL address — or literally `write`/`read`, which are already built**. The
only struct is `sockaddr_un` (110 bytes, flat, no pointers): u16 family then a
NUL-terminated path, and `addrlen = 2 + strlen + 1`. Three semantic gaps the
Python papered over: (1) `sock-send` is `sendall` — a raw `write`/`sendto` may
be short, so the crossing's *upper wrapper* needs a resend loop on the
remainder (note: its decrement is data-dependent, so today's measure checker
can't prove it total — fine, sys-face code is not in the total fragment);
(2) `sock-recv` returning 0 becomes the `recv-closed` constructor — that
mapping lives in whatever wraps the crossing into `RecvR`
(`ports.chiral:24-27`), not at the floor; (3) errors: CPython raised
`PortError`, the floor returns −errno; the −errno→alarm mapping is an
effects-family concern (flag F3). Finally, retiring the Python means the
runtime port value `("sock", socket)` eventually becomes a bare fd; that
touches `bridge.py`'s `_ATOM_TAG` verification and is flagged cross-family
(F5) — do not let this pass grow into that.

**Translation dossier:**

*Source exemplars* — all-integer: `nb-sys-lseek` (`sys-tal.chiral:52-55`);
buffer-passing: `nb-sys-write` (`sys-tal.chiral:18-23`); cell-building with
`ti-bnew`/`ti-bput`/`ti-bptr`: `nb-sys-memfd` (`sys-tal.chiral:63-71`);
byte-copy into a cell at an offset: `nb-copy` call shape
(`lib/bytes-tal.chiral:31-48`, `nb-copy(dst, src, doff, soff, n)`).

*sockaddr_un layout* (flat, confident):

| off | size | field | value |
|---|---|---|---|
| 0 | 2 | sun_family | 1 = AF_UNIX, LE (`bput` 1 at 0; byte 1 must be 0) |
| 2 | ≤107 | sun_path | path bytes, NUL-terminated |
| — | — | addrlen arg | 2 + pathlen + 1 |

*Target sketch* (S half — verbatim recipe):

```lisp
; socket(domain, type, protocol) -> fd or -errno. nr 41.
(def nb-sys-socket TFn
  (tfn "nb-sys-socket" 3 4
    (t-seq (ti-sys 3 41 (cons 0 (cons 1 (cons 2 nil)))) (t-ret 3))))

; listen(fd, backlog) -> 0 or -errno. nr 50.
(def nb-sys-listen TFn
  (tfn "nb-sys-listen" 2 3
    (t-seq (ti-sys 2 50 (cons 0 (cons 1 nil))) (t-ret 2))))

; accept(fd, NULL, NULL) -> connected fd or -errno. nr 43. The peer address is
; deliberately discarded (AF_UNIX; the path told us who we dialed).
(def nb-sys-accept TFn
  (tfn "nb-sys-accept" 1 4
    (t-seq (ti-const 1 0)
    (t-seq (ti-sys 3 43 (cons 0 (cons 1 (cons 1 nil))))
      (t-ret 3)))))
```

*Target sketch* (M half — the one struct; modeled construct-for-construct on
`nb-sys-memfd` + `nb-sys-read`'s `nb-copy` call):

```lisp
; connect(fd, path) -> 0 or -errno. nr 42. Builds sockaddr_un in a fresh
; zero-cell: family=AF_UNIX at [0], path at [2], NUL free (cell is zeroed --
; but store it explicitly anyway, see the zero-init divergence note).
(def nb-sys-connect TFn
  (tfn "nb-sys-connect" 2 12
    (t-seq (ti-const 2 110)                       ; sizeof(sockaddr_un)
    (t-seq (ti-bnew 3 2)                          ; the address cell
    (t-seq (ti-const 4 1)                         ; AF_UNIX
    (t-seq (ti-const 5 0)
    (t-seq (ti-bput 3 5 4)                        ; cell[0] := 1 (family lo)
    (t-seq (ti-blen 6 1)                          ; pathlen
    (t-seq (ti-const 7 2)
    (t-seq (ti-call 8 "nb-copy" (cons 3 (cons 1 (cons 7 (cons 5 (cons 6 nil))))))
    (t-seq (ti-bptr 9 3)                          ; &sockaddr
    (t-seq (ti-prim 10 "+" 6 7)                   ; pathlen + 2
    (t-seq (ti-const 11 1)
    (t-seq (ti-prim 10 "+" 10 11)                 ; addrlen = pathlen + 3
    (t-seq (ti-sys 11 42 (cons 0 (cons 9 (cons 10 nil))))
      (t-ret 11)))))))))))))))
```

`nb-sys-bind` is the identical body with nr 49. Send/recv: either reuse
`nb-sys-write`/`nb-sys-read` outright (stream fds; flags 0), or add
`nb-sys-send`/`nb-sys-recv` as the write/read bodies with nr 44/45 and two
extra `ti-const 0` args if flags are ever wanted — start with reuse.

*Mechanical recipe:*
1. COPY — S half above + `LIB_SIGS` lines (`socket [I64,I64,I64]→I64`,
   `listen [I64,I64]→I64`, `accept [I64]→I64`).
2. TRANSLATE — connect/bind from the sketch (rule: struct field ↦ one
   `ti-const`+`ti-bput` for constants, one `nb-copy` per variable byte run).
   Sig: `"nb-sys-connect": ([I64, BYTES], I64)`.
3. TRANSLATE — tests: mirror `test_native.py:410-431` but against a real
   AF_UNIX pair: Python-side `socket.bind`+`listen` in the test, chirality-side
   `nb-sys-socket`+`nb-sys-connect`, then `nb-sys-write` across and
   `os.recv` asserts; and the mirrored direction. Both native and TalMachine.
4. NEW — the sendall wrapper and the RecvR mapping stay OUT of this pass
   (they land with the linkage seam, F1). Nothing else new.

**Dependencies:** E28 (`nb-sys-close` for hygiene in tests). Unblocks E30, E31,
E33, and the demos' transport self-hosting.

**Est. pass size:** M (S half is <½ session; the struct half + tests the rest).

---

## E30 — fd passing: sendmsg + SCM_RIGHTS (`sock-send-fd`)   [REPLACE-CRUTCH · Tier R]

**Lives now:**
- `scaffold/chirality/impl_ports.py:135-141` — `socket.send_fds(sv[1], [data], [fdv[1]])`
- Typed face: `scaffold/lib/ports.chiral:39` — `(extern sock-send-fd (=> (1 s Sock) Bytes (1 f Fd) Sock))`
- The one real consumer: `scaffold/demo/wl-client.chiral:179-180` (wl_shm.create_pool carries the memfd)

**Verdict:** REDO — the hard one. CPython's `send_fds` hides the entire
msghdr/cmsghdr construction. Build-sheet below is intended to be pass-ready.

**Explainer:** `sendmsg` is the family's first crossing whose argument struct
*contains absolute addresses of other cells* — an iovec pointing at the data
payload and a control buffer holding the fd. Three invariants: (i) every
address written into the structs must be a `ti-bptr` of a `ti-bnew` cell taken
in the *same function* as the single `ti-sys` (reference-machine pin rule
above) — the incoming data cell may be a literal, so **copy it into a fresh
cell first** rather than legislate about callers; (ii) SCM_RIGHTS on a stream
socket must accompany ≥1 byte of real data — our only use sends the
create_pool request as that data, so make non-empty data a stated precondition;
(iii) all lengths in the cmsg macros align to 8 (`sizeof(size_t)` on x86-64):
CMSG_ALIGN(n) = (n+7) & ~7, CMSG_LEN(d) = 16 + d, CMSG_SPACE(d) = 16 +
CMSG_ALIGN(d). For one fd (d=4): cmsg_len = **20**, controllen = **24** (the 4
pad bytes must be zeroed). The kernel copies the fd — the sender's fd stays
open and is still closed by `fd-close`/linear discharge as today; the *moved*
authority is the port-level story, not a kernel one. `recvmsg` (nr 47) is the
mirror (kernel fills the same layouts; read fd out of the control cell at
offset 16) — needed only when a chirality node *receives* an fd; today none does
(the parent side of spawn is Python), so ship send first, recv with E33.

**Translation dossier:**

*Source exemplars* — cell building + single-sys pattern: `nb-sys-memfd`
(`sys-tal.chiral:63-71`); recursive byte-store helper shape: `nb-copy`
(`bytes-tal.chiral:32-48`); u64 store: **does not exist yet** — the one NEW
helper, `nb-put64` (see recipe).

*Build-sheet — byte layouts (x86-64, LE; all offsets from cell payload start).*
I am confident of these; the only VERIFY is noted at the end.

**iovec cell** (16 bytes, `ti-bnew 16`):

| off | size | field | value |
|---|---|---|---|
| 0 | 8 | iov_base | bptr(data-copy cell) |
| 8 | 8 | iov_len | blen(data) |

**control cell** (24 bytes = CMSG_SPACE(4), `ti-bnew 24`, zero the tail):

| off | size | field | value |
|---|---|---|---|
| 0 | 8 | cmsg_len | 20 = CMSG_LEN(4) |
| 8 | 4 | cmsg_level | 1 = SOL_SOCKET |
| 12 | 4 | cmsg_type | 1 = SCM_RIGHTS |
| 16 | 4 | fd | the passed fd |
| 20 | 4 | pad | 0 (explicitly stored) |

**msghdr cell** (56 bytes, `ti-bnew 56`):

| off | size | field | value |
|---|---|---|---|
| 0 | 8 | msg_name | 0 |
| 8 | 4 | msg_namelen | 0 |
| 12 | 4 | (pad) | 0 |
| 16 | 8 | msg_iov | bptr(iovec cell) |
| 24 | 8 | msg_iovlen | 1 |
| 32 | 8 | msg_control | bptr(control cell) |
| 40 | 8 | msg_controllen | 24 |
| 48 | 4 | msg_flags | 0 (ignored on send) |
| 52 | 4 | (pad) | 0 |

Call: `ti-sys dst 46 (fd, bptr(msghdr), 0)` → bytes sent or −errno.

*Target sketch* (register plan; constructs all from `sys-tal.chiral` +
`bytes-tal.chiral`; `nb-put64`/`nb-put32` are the NEW helpers):

```lisp
; sendmsg(fd, data, passfd) -> sent or -errno. nr 46. Data is copied into a
; fresh cell so every embedded address is a bnew address (pin rule).
(def nb-sys-sendfd TFn
  (tfn "nb-sys-sendfd" 3 24
    ; r3  = blen data          (ti-blen 3 1)
    ; r4  = bnew r3, data copy (ti-bnew 4 3) + (ti-call _ "nb-copy" (4 1 0 0 r3))
    ; r5  = bptr r4            (ti-bptr 5 4)
    ; r6  = bnew 16, iovec:      nb-put64(6, 0, r5); nb-put64(6, 8, r3)
    ; r7  = bnew 24, control:    nb-put64(7, 0, 20); nb-put32(7, 8, 1);
    ;                            nb-put32(7, 12, 1); nb-put32(7, 16, r2=passfd);
    ;                            nb-put32(7, 20, 0)
    ; r8  = bnew 56, msghdr:     nb-put64(8, 0, 0); nb-put64(8, 8, 0);
    ;                            nb-put64(8, 16, bptr r6); nb-put64(8, 24, 1);
    ;                            nb-put64(8, 32, bptr r7); nb-put64(8, 40, 24);
    ;                            nb-put64(8, 48, 0)
    ; r9  = bptr r8
    ; r10 = (ti-sys 10 46 (cons 0 (cons 9 (cons ZERO nil))))   ; flags reg = const 0
    ; (t-ret 10)
    ...))
```

(Elided body is pure `t-seq` chaining of exactly those calls — no construct not
already in `sys-tal.chiral:18-71`.)

*The NEW helper* — pure (no sysface), lives in `bytes-tal.chiral`, modeled
line-for-line on `nb-copy`'s recursion (`bytes-tal.chiral:32-48`):

```lisp
; store the low `n` bytes of val into dst at off, little-endian; returns dst.
; nb-putle(dst, off, val, n): bput dst off (val % 256); recurse (off+1,
; val / 256, n-1); n=0 returns dst. Euclidean / and % make the byte split
; exact for val >= 0 (addresses and lengths are nonnegative).
(def nb-putle TFn (tfn "nb-putle" 4 12 ...))   ; nb-copy's case/recursion shape
```

with `nb-put64` = `nb-putle(dst, off, val, 8)` and `nb-put32` = n=4 (either as
two 4/8-reg wrappers or callers pass n). Sig lines: `"nb-putle": ([BYTES, I64,
I64, I64], BYTES)`.

*Mechanical recipe:*
1. NEW (small, bounded) — `nb-putle` in `bytes-tal.chiral` + `LIB_SIGS` line +
   differential test against `struct.pack("<q", ...)`.
2. TRANSLATE — the build-sheet tables into the `t-seq` chain (rule: one table
   row ↦ one `nb-put64`/`nb-put32`/`nb-copy` call; constants via `ti-const`).
3. COPY — `LIB_SIGS`: `"nb-sys-sendfd": ([I64, BYTES, I64], I64)`; `sys-lib`
   append.
4. TRANSLATE — test: `socket.socketpair()` in the test harness; chirality sends
   `b"x"` + a memfd from `nb-sys-memfd`; Python side `socket.recv_fds` asserts
   the byte arrived and the received fd works (`os.write`/`os.read` through
   it). Native + TalMachine variants (pin rule is exercised by the latter).
5. NEW (later, with E33) — `nb-sys-recvfd` mirror: same cells, kernel fills;
   read the fd with `nb-unpack32(control, 16)` (`LIB_SIGS` has `nb-unpack32`
   already, `native.py:83`).

VERIFY: msg_controllen may also legally be 20 (=cmsg_len) for a single final
cmsg; 24 (CMSG_SPACE) is what CPython/musl use and is the safe choice — if the
kernel ever rejects 24-with-20 pairing (it does not, to my knowledge), drop to
20.

**Dependencies:** E29 (a socket to send on), E28 (close hygiene), `nb-putle`.
Unblocks: wl-client fully self-hosted transport; E33's fd hand-off option.

**Est. pass size:** M (with this sheet; L without — the sheet is the slicing).

---

## E31 — poll/select and the pollfd shape   [REPLACE-CRUTCH · Tier R]

**Lives now:**
- `scaffold/chirality/impl_ports.py:162-171` — `poll2` via `select.select` over exactly two socks
- Typed face: `scaffold/lib/ports.chiral:28,42` — `Poll2R`, `(extern poll2 (=> (1 a Sock) (1 b Sock) I64 Poll2R))`
- Consumers: `demo/tomodachi.chiral:75-85` (wl vs niri readiness), `demo/node-render.chiral`

**Verdict:** REDO — `select.select` must become the `poll` syscall over a
pollfd array cell. Keep the two-fd face; do *not* generalize to N fds yet
(the frozen port set has no consumer for it — language-over-demos cuts both
ways: no speculative generality either).

**Explainer:** `poll` is the gentlest struct crossing and the right warm-up for
E30: the array is flat (no pointers), 8 bytes per entry, and it is the family's
first *kernel-writes-back* buffer — the crossing must read `revents` out of the
cell after the syscall, which exercises the bnew-shares-memory property of the
reference machine (`tal.py:273-279`) and the native arena cell equally.
`timeout` is milliseconds directly (matching the existing face; −1 blocks —
same convention, no conversion). Result mapping preserved from
`impl_ports.py:166-171`: idx 0 if a is ready, else 1 if b, else −1 — check
`revents != 0` rather than `POLLIN` alone so HUP/ERR count as "ready" and the
subsequent recv observes the close (that is what select gives today: a closed
peer selects readable). `nfds=2` is an immediate. `ppoll`(271) is not needed
(no signal story yet). `select`(23) is strictly worse (fd_set bitmaps); skip.

**Translation dossier:**

*pollfd layout* (8 bytes/entry, confident):

| off | size | field | in/out |
|---|---|---|---|
| 0 | 4 | fd | in |
| 4 | 2 | events (POLLIN=1) | in |
| 6 | 2 | revents | **out** (kernel writes) |

*Source exemplars* — cell build: `nb-sys-memfd` (`sys-tal.chiral:63-71`);
readback after a sys: `nb-sys-read`'s post-syscall use of the buffer
(`sys-tal.chiral:27-45`); u16 read: `nb-unpack16` (`LIB_SIGS`, `native.py:84`).

*Target sketch* (condensed; every construct cited above; needs `nb-putle`
from E30 for the 4-byte fd stores):

```lisp
; poll over exactly two fds. nr 7. -> 0 a-ready, 1 b-ready (a wins ties),
; -1 timeout; a negative -errno propagates as-is for the wrapper to alarm.
(def nb-sys-poll2 TFn
  (tfn "nb-sys-poll2" 3 20
    ; r3 = bnew 16 (two pollfds; zero cell -- store all constant bytes anyway)
    ; nb-put32(3, 0, r0)  nb-put32(3, 8, r1)      ; the two fds
    ; POLLIN: (ti-const e 1) (ti-const o4 4) (ti-bput 3 o4 e)
    ;         (ti-const o12 12) (ti-bput 3 o12 e) ; events lo byte; hi + revents zeroed
    ; r4 = bptr 3;  r5 = const 2 (nfds)
    ; r6 = (ti-sys 6 7 (cons 4 (cons 5 (cons 2 nil))))    ; (ptr, nfds, timeout=r2)
    ; case r6 <= 0 -> handle -errno/timeout -> ret -1 form
    ; r7 = nb-unpack16(3, 6)   ; revents a
    ; case r7 = 0 -> r8 = nb-unpack16(3, 14) ... ret 1/-1 ; else ret 0
    ...))
```

Branching uses `t-case` on a `ti-prim "=i"`/`"<=i"` Bool exactly as
`nb-sys-read` does (`sys-tal.chiral:33-45`).

*Mechanical recipe:*
1. COPY — cell build lines from the E30 pattern (fd stores via `nb-putle`).
2. TRANSLATE — the select→poll result mapping from `impl_ports.py:166-171`
   into the two `t-case` chains (rule above: revents≠0 ⇒ ready).
3. COPY — `LIB_SIGS` `"nb-sys-poll2": ([I64, I64, I64], I64)`; `sys-lib`.
4. TRANSLATE — test from the pipe pattern (`test_native.py:433-456`): two
   pipes; write to one; poll2 returns its index; timeout path returns −1
   within tolerance; closed-writer path reports the read end ready. Native +
   TalMachine.
5. NEW — nothing beyond E30's helper.

**Dependencies:** `nb-putle` (E30 step 1 — can land first, it is independent).
Unblocks the demos' event loop; pairs with E29 for full transport.

**Est. pass size:** S (once `nb-putle` exists).

---

## E32 — clock_gettime (time-mono), exit, env   [REPLACE-CRUTCH · Tier R]

**Lives now:**
- `scaffold/chirality/impl_ports.py:52-64` — `time-mono` (`time.monotonic_ns()//1e6`), `exit` (raises `MetisExit`), `env-get` (`os.environ.get`)
- Typed face: `scaffold/lib/ports.chiral:69-78`
- `MetisExit` unwinding: `scaffold/chirality/alarms.py`, caught in `cli.py:91-92`

**Verdict:** REDO for `time-mono` and `exit`; for `env` the honest verdict is
**blocked-by-design**: there is no "getenv" syscall — the environment is memory
handed to the process at `execve` (envp on the initial stack), which chirality can
only see once it owns its entry point (E34) — or via `open("/proc/self/environ")`
+ read + NUL-split as a Linux-specific bridge. Name it, don't fake it.

**Explainer:** `clock_gettime(CLOCK_MONOTONIC=1, &ts)` fills a 16-byte timespec
`{i64 tv_sec; i64 tv_nsec}`; ms = sec·1000 + nsec/10⁶ — computable at the floor
with `ti-prim "+"/"*"/"/"` (Euclidean / equals floor on nonneg operands, and
both are nonneg here). Reading the two u64s back: `nb-unpack32` low words
suffice — tv_nsec < 10⁹ fits u32 exactly, tv_sec (monotonic = seconds since
boot) fits u32 for 136 years of uptime; assert the high words zero if you want
the paranoid version (VERIFY note: vDSO vs syscall — the raw syscall is always
correct, just slower; we never link vDSO, fine). `exit` is `exit_group` (231,
not `exit` 60 — 60 ends one thread; 231 ends the process, and CPython hosting
the JIT is multi-threaded under tests) and *does not return* — but a `tfn`
still needs a terminator, so `t-ret` the sys result as dead code. Trap: while
the scaffold hosts native code inside CPython, calling `nb-sys-exit` natively
kills the *test runner*; the differential test must fork first (subprocess or
`os.fork` in the test harness) — the Python `exit` impl (MetisExit unwind)
remains the *hosted* behavior until chirality owns its process (E34/E42), so this
crossing lands with a fork-based test and is consumed for real only by the ELF
path. That's a scoping statement, not a defect.

**Translation dossier:**

*Source exemplars* — out-buffer + readback: `nb-sys-read` (`sys-tal.chiral:27-45`);
all-integer: `nb-sys-lseek` (`sys-tal.chiral:52-55`); u32 readback:
`nb-unpack32` (`native.py:83`).

*timespec layout* (confident): tv_sec i64 @0; tv_nsec i64 @8.

*Target sketch:*

```lisp
; monotonic milliseconds. clock_gettime(1, &ts), nr 228.
(def nb-sys-monoms TFn
  (tfn "nb-sys-monoms" 0 12
    ; r0 = const 16; r1 = bnew r0; r2 = const 1 (CLOCK_MONOTONIC)
    ; r3 = bptr 1
    ; r4 = (ti-sys 4 228 (cons 2 (cons 3 nil)))
    ; r5 = nb-unpack32(1, 0)          ; tv_sec  (low word; hi 0 for uptimes)
    ; r6 = nb-unpack32(1, 8)          ; tv_nsec (< 1e9, fits u32)
    ; r7 = const 1000; r8 = * r5 r7
    ; r9 = const 1000000; r10 = / r6 r9
    ; r11 = + r8 r10 ; (t-ret 11)
    ...))

; exit_group(code), nr 231; never returns (the ret is dead).
(def nb-sys-exit TFn
  (tfn "nb-sys-exit" 1 2
    (t-seq (ti-sys 1 231 (cons 0 nil)) (t-ret 1))))
```

*Mechanical recipe:*
1. COPY — `nb-sys-exit` verbatim; `LIB_SIGS` `([I64], I64)`.
2. TRANSLATE — `nb-sys-monoms` from the sketch (one table row per line rule).
3. TRANSLATE — tests: monoms twice with a `time.sleep(0.05)` between, assert
   monotone and Δ within [40,500] ms of `time.monotonic_ns()`'s own Δ; exit
   tested in a forked child (assert waitpid status code).
4. NEW — env: decide the bridge (`/proc/self/environ` via open(2)+read) vs
   wait-for-E34 (envp). Recommend: defer to E34, keep `env-get` a host binding,
   record it in the profile's frozen port set story unchanged.

**Dependencies:** none for exit/monoms. env gates on E34 (or accepts a
/proc-based Linux-ism). Unblocks: honest `time-and-clocks.md` floor story.

**Est. pass size:** S.

---

## E33 — process model: spawn via socketpair + fork/execve   [REPLACE-CRUTCH · Tier R]

**Lives now:**
- `scaffold/chirality/impl_ports.py:69-85` — `_spawn`: `socket.socketpair(AF_UNIX, SOCK_STREAM)` → `subprocess.Popen([sys.executable, "-m", "chirality", "spawn-run", path], pass_fds=[child.fileno()], env={**os.environ, "MET_SPAWN_FD": ...})`; parent keeps `("sock", parent)`, closes the child end
- `scaffold/chirality/cli.py:71-72,101-144` — `spawn-run`: the child self-verifies (profile valid, `node-main : (=> (1 peer Sock) Unit)` via kernel `conv`), wraps `MET_SPAWN_FD` into a Sock, runs `node-main`
- Typed face: `scaffold/lib/ports.chiral:56-65` — `(extern spawn (=> Str Sock))`
- Consumer: `demo/duo.chiral` (stages its own renderer)

**Verdict:** REDO — but two-layered, and only the bottom layer is this family's.
The *crossings* (socketpair, fork, execve, dup2, wait4) are buildable and
testable now; the *spawn semantics* (which program image to exec, the child's
self-verification) is Python end-to-end until chirality has an executable form
(E34) and a runtime that can be entered (E42). Do not pretend otherwise.

**Explainer:** How spawn works today, traced: parent makes a socketpair; the
child *process* is a fresh CPython running the chirality CLI, which re-elaborates
the staged file, re-verifies the profile and the entry type *in the child* (the
staging membrane — a refused staging is seen by the parent as its port
closing, `cli.py:104-106`), then adopts the inherited fd as its one port. The
raw-syscall version of the mechanics: `socketpair(1,1,0,sv)` (the out-param is
an 8-byte cell, two i32 fds) → `fork()` (57) → child: `close(sv[0])`, optionally
`dup2(sv[1], KNOWN_FD)` (33), `execve(path, argv, envp)` (59) → parent:
`close(sv[1])`, keep `sv[0]`, later `wait4` (61) for teardown accounting.
`fork` at the tal floor is semantically loaded: the syscall returns twice (0 in
child, pid in parent) — as a crossing that is just an I64 `t-case`, but the
*reference machine* forks the hosting CPython, so the child must reach `execve`
or `exit_group` immediately or two test runners continue; tests must be written
fork→exec-`/bin/true`→wait4 as one unit. `execve` needs NUL-terminated strings
(the `nb-sys-memfd` empty-name trick, `sys-tal.chiral:58-62`, generalizes: copy
into a len+1 cell) and NULL-terminated *pointer arrays* — `nb-put64` again.
CLOEXEC discipline: today `pass_fds` handles inheritance; raw execve inherits
everything not CLOEXEC — the staging fd must simply not be CLOEXEC (default for
`socketpair` without SOCK_CLOEXEC). Fd numbering across exec: dup2 to a fixed
fd (e.g. 3) is simpler than the env-var handshake and removes the getenv
dependency; note it as the recommended protocol change *when* the child is a
chirality image. clone(56) is not needed — fork(57) is exactly
clone(SIGCHLD,0,0,0,0) for this use; no threads, no namespaces yet.

**Translation dossier:**

*Source exemplar* — the Python protocol to preserve, `impl_ports.py:74-79`
(quoted at "Lives now"); NUL-name trick `sys-tal.chiral:63-71`; out-param cell:
E31's pattern.

*Target sketches* (crossing layer only):

```lisp
; socketpair(AF_UNIX, SOCK_STREAM, 0) -> writes two fds into an 8-byte cell.
; nr 53. Wrapper reads them with nb-unpack32(cell,0)/(cell,4).
(def nb-sys-sockpair TFn
  (tfn "nb-sys-sockpair" 0 8
    ; r0=const 1; r1=const 1; r2=const 0
    ; r3=bnew (const 8); r4=bptr 3
    ; r5=(ti-sys 5 53 (cons 0 (cons 1 (cons 2 (cons 4 nil)))))
    ; ret r3-or-r5: return the CELL via a small (data SpR ...) or two calls --
    ; NOTE: a tal fn returns one word; returning the cell (BYTES) and letting
    ; the wrapper unpack is the honest shape: sig ([ ], BYTES) with -errno
    ; signaled by a leading sentinel... SEE FINDING BELOW.
    ...))

(def nb-sys-fork TFn        ; nr 57; 0 in child, pid in parent, -errno on fail
  (tfn "nb-sys-fork" 0 1
    (t-seq (ti-sys 0 57 nil) (t-ret 0))))

(def nb-sys-dup2 TFn        ; nr 33
  (tfn "nb-sys-dup2" 2 3
    (t-seq (ti-sys 2 33 (cons 0 (cons 1 nil))) (t-ret 2))))
```

**Finding, not a sketch:** `socketpair` (and `nb-sys-recvfd`, and E32's
timespec if returned raw) want to return *two* values; a `TalFn` returns one
word. Options: (a) return the out-cell (BYTES) and unpack in a second call —
works today, slightly leaky (−errno vs cell discrimination needs a convention);
(b) return a boxed 2-field data cell (`ti-cona` exists in the emitter,
`native.py:196-198`) — cleaner, but `LIB_SIGS` must then name a data type
shared with the caller. Neither is hard; (b) matches how `ports.chiral` already
shapes results (`AccR`, `PoolR`). Decide at pass time; (b) recommended.

`execve` sketch shape (M/L, described): path → NUL-terminated cell (copy, len+1);
each arg string likewise; argv cell = 8·(n+1) bytes, `nb-put64` each `bptr`,
last slot 0; envp likewise (or 0-cell for empty environment); single
`ti-sys 59 (pathptr, argvptr, envpptr)`; only reached in the fork child; on
success never returns, on failure the child must `nb-sys-exit(127)`.

*Mechanical recipe:*
1. COPY — fork/dup2/wait4-with-out-cell + `LIB_SIGS` lines (fork `([], I64)`).
2. TRANSLATE — socketpair per E31's out-cell pattern + the two-value decision.
3. TRANSLATE — execve per the byte-table rule (one pointer slot ↦ one
   `nb-put64(bptr ...)`), reusing E30's helper.
4. TRANSLATE — test: fork; child dup2s a pipe to fd 1 and execves `/bin/echo
   hello`; parent wait4s and reads "hello" from the pipe. Entirely at the
   crossing layer; runs today under CPython hosting.
5. NEW — nothing at this layer. The spawn-protocol re-plumb (chirality child image,
   fixed-fd handshake, child self-verification in chirality) is explicitly NOT this
   pass: it composes E34 + E42 + the checker self-host, and should be written
   up as its own slice when E34 lands.

**Dependencies:** E29 (socketpair is socket-family), E30 helper, E28 (close).
Full spawn self-host additionally gates on E34 + E42 (+E1–E14 for the child's
self-verify). Unblocks: teardown/wait accounting, the E43 broker story.

**Est. pass size:** M for the crossing layer (slice: S for
fork/dup2/sockpair + test; S/M for execve). The protocol layer is L and
deferred with named gates.

---

## E34 — ELF output, ahead-of-time instead of JIT-in-mmap   [BUILD-PROPER · Tier R]

**Lives now:** UNBUILT. The consumers-to-be:
- `scaffold/chirality/native.py:400-431` — everything a loader does today: mmap RW, write code, poke `heapptr`/`heapend` (`native.py:415-416`), mprotect RX, CFUNCTYPE entry (the E23 crutch this element deletes)
- `scaffold/lib/mach-x64.chiral:187-193` — `x-fin`: the emitted blob already ends `[a-align 4096][heapptr][heapend]` — i.e. **the emitter already produces a file image whose RX/RW split is page-aligned**
- Catalog `.planning/SELF-IMPLEMENT-CATALOG.md:88`; policy `docs/decision-inspiration-policy.md:24` (ELF + SysV gABI, Tier R)

**Verdict:** UNBUILT — and smaller than it looks: the machine code, literals,
relocation, and page-aligned RX/RW layout all exist; what's missing is 176
bytes of headers, a ~20-byte `_start` stub, and a file writer. The header
builder is *pure* chirality in wire.chiral's exact idiom.

**Explainer:** Choose ET_EXEC (fixed load address), not ET_DYN: the emitted
code is RIP-relative for heap cells and rel32 for calls (`mach-x64.chiral:
130-143`, `asm-reloc` conventions), so it would *run* anywhere, but ET_EXEC
lets the ELF writer compute `heapptr`/`heapend` initial values at link time and
write them into the file image — replacing the loader poke with two `b8` words,
no relocations section, no interpreter, no dynamic anything. Two PT_LOADs
mirror today's W^X flip exactly: RX covers headers+`_start`+code+literals
(everything before the `a-align 4096` boundary that `x-fin` already emits;
today's `code_end = offsets["heapptr"]`, `native.py:420`), RW covers the
16-byte heapptr/heapend cells with `p_memsz = p_filesz + ARENA_BYTES` so the
kernel's zero-fill BSS *is* the arena — the mmap-the-arena step disappears into
the segment. `_start` is not `main`: no caller, no returning — call the entry
function (rel32, `enc-call` exists), move rax→rdi, `exit_group`. The kernel
hands argc/argv/envp on the stack at entry — E32's env story plugs in here
later; ignore the stack contents for v1. Add PT_GNU_STACK (flags RW, no X) or
the kernel gives an executable stack for e_phnum=2 binaries — cheap and keeps
the W^X story honest. Entry functions take no args in v1 (SysV arg passing into
the entry fn already works via `x-store-arg` if needed later). The file writer
needs open(2)+write+close crossings (E28/E29 table) and chmod-by-mode-arg at
open.

**Translation dossier:**

*Source exemplars* — byte-building idiom: `wenc` (`lib/wire.chiral:13-17`) and
`b1/b2/b4/b8` (`lib/mach-x64.chiral:14-18` — b8 splits an I64 via
`(/ v 4294967296)`, valid for the nonneg values here); padding: `wstr`'s
`brepeat` (`wire.chiral:19-26`); the blob layout: `x-fin`
(`mach-x64.chiral:187-193`); the values being replaced: `native.py:404-421`.

*Fill-in table — ELF64 header (64 bytes at offset 0):*

| off | sz | field | value |
|---|---|---|---|
| 0 | 4 | magic | 0x7F 'E' 'L' 'F' |
| 4 | 1 | EI_CLASS | 2 (ELFCLASS64) |
| 5 | 1 | EI_DATA | 1 (LSB) |
| 6 | 1 | EI_VERSION | 1 |
| 7 | 1 | EI_OSABI | 0 (SysV) — VERIFY: 0 vs 3 (Linux); 0 is standard for static |
| 8 | 8 | pad | 0 |
| 16 | 2 | e_type | 2 (ET_EXEC) |
| 18 | 2 | e_machine | 62 (EM_X86_64) |
| 20 | 4 | e_version | 1 |
| 24 | 8 | e_entry | VBASE + 0x1000 (= `_start`) |
| 32 | 8 | e_phoff | 64 |
| 40 | 8 | e_shoff | 0 (no sections — VERIFY tooling tolerance; kernel doesn't care) |
| 48 | 4 | e_flags | 0 |
| 52 | 2 | e_ehsize | 64 |
| 54 | 2 | e_phentsize | 56 |
| 56 | 2 | e_phnum | 3 |
| 58 | 2 | e_shentsize | 0 — VERIFY (0 accepted when shnum 0; some tools prefer 64) |
| 60 | 2 | e_shnum | 0 |
| 62 | 2 | e_shstrndx | 0 |

*Fill-in table — program headers (3 × 56 bytes at offset 64).* Let VBASE =
0x400000; CODE = `_start` bytes + emitter output up to the `a-align 4096`
boundary (= `offsets["heapptr"]` in today's terms); CEND = that boundary
(page multiple already).

| field (off/sz) | PH1 (RX) | PH2 (RW) | PH3 (GNU_STACK) |
|---|---|---|---|
| p_type @0 u32 | 1 (PT_LOAD) | 1 (PT_LOAD) | 0x6474e551 — VERIFY constant |
| p_flags @4 u32 | 5 (R\|X) | 6 (R\|W) | 6 (RW, no X) |
| p_offset @8 u64 | 0 | 0x1000 + CEND | 0 |
| p_vaddr @16 u64 | VBASE | VBASE + 0x1000 + CEND | 0 |
| p_paddr @24 u64 | = vaddr | = vaddr | 0 |
| p_filesz @32 u64 | 0x1000 + CEND | 16 | 0 |
| p_memsz @40 u64 | = filesz | 16 + ARENA_BYTES | 0 |
| p_align @48 u64 | 0x1000 | 0x1000 | 0x10 (conventional) — VERIFY |

Rule that generates the offsets: `p_offset ≡ p_vaddr (mod 4096)` — satisfied by
construction above (headers page 0 is RX-mapped along with code; code proper
starts at file offset 0x1000 = vaddr VBASE+0x1000 so `e_entry` math stays
simple). File image: `[ehdr 64][phdrs 168][pad to 0x1000][_start][emitter blob
incl. literals][heapptr=VBASE+0x1000+CEND+16 as b8][heapend=heapptr+ARENA]` —
the last two replacing the zeros `x-fin` emits, exactly the two words
`native.py:415-416` pokes today.

*`_start` stub* (bytes via existing encoders): `enc-call` rel32 to the entry
function (`mach-x64.chiral:126`), `mov rdi, rax` = 48 89 C7 (three `b1`s, same
shape as `x-mov-rax-rdx`, `mach-x64.chiral:83`), `x-mov-rax-imm 231`
(`mach-x64.chiral:50-51`), `x-syscall` (`mach-x64.chiral:277`).

*Mechanical recipe:*
1. TRANSLATE — the two tables into a pure `lib/elf.chiral`: one row ↦ one
   `b1/b2/b4/b8` term `bcat`-chained, `wenc`-style (rule: u16→`b2`(=`pack-u16`
   exists, `impl_pure.py:128`), u32→`b4`, u64→`b8`).
2. COPY — `_start` from the four encoder calls above.
3. TRANSLATE — a Python (later chirality) driver: run the existing emitter
   (`native.py:391-393` shows the call shape), compute CEND from
   `offsets["heapptr"]`, assemble header+pad+blob, patch the two heap words,
   write the file 0755. First version writes via Python `open`; the chirality
   version uses open(2)/`nb-sys-write` when E28/E29 land.
4. TRANSLATE — test: build an ELF whose entry function returns a constant;
   `subprocess.run` the file; assert the exit status equals the constant. Then
   one with boxed data (exercises the BSS arena) and one with a literal
   (exercises RX literals).
5. NEW — the VBASE/entry bookkeeping (small; it is the one genuinely new
   decision, and the tables above pin it).

**Dependencies:** none to build (emitter + encoders exist); E28/E32-open to
write the file from chirality; deletes E23 when adopted; E33's protocol layer and
E32's env both plug into `_start` later.

**Est. pass size:** M.

---

## E35 — Wayland wire protocol   [SELF-HOST(done) · Tier R]

**Lives now:**
- `scaffold/lib/wire.chiral:1-61` — the codec: `wenc` (header packing, size in high 16 bits of word 2, `wire.chiral:13-17`), `wstr` (NUL + pad-to-4, `:19-26`), `wsplit1` (buffer framing with the incomplete-message case, `:33-47`), `glob-name`/`glob-iface`/`wbind` (registry, `:49-61`), `err-msg` (wl_display.error decode, `:75-84`)
- Consumer: `scaffold/demo/wl-client.chiral` (full client: registry roundtrip, layer-shell, shm pool at `:174-187`)
- Test double: `scaffold/mock/mockwl.py` (Python, test-only — acceptable)

**Verdict:** PROPER — already chirality, already exercised end-to-end against the
mock, and it is the family's template for every binary-format pass (E34's
tables translate through exactly its idiom).

**Explainer:** The things worth copying from it, named so the other passes do:
(1) *length-prefixed framing with an explicit incomplete case* — `wsplit1`
returns `(wsplit none buf)` when fewer than 8 bytes or a partial body,
and the caller carries the remainder (`WSplit`/`LSplit` data both here);
(2) *padding by arithmetic, not special cases* — `(% (- 4 (% n 4)) 4)`
(`wire.chiral:24`); (3) *fixed-width packing through the four prims*
`pack-u32/unpack-u32/pack-u16/unpack-u16` (LE, `impl_pure.py:127-142`), with
`(/ szop 65536)`/`(% szop 65536)` splitting packed words — the same Euclidean-
on-nonneg discipline the family's struct work uses. Two honest limits, neither
a defect: u32 packing is little-endian only (PNG in E37 needs BE — a 4-byte
reverse helper, pure); and there is no `pack-u64` at the surface — `b8` in
`mach-x64.chiral:17-18` is the pattern if a format ever needs it. The transport
under this codec is E29/E30's business; nothing in this file changes when the
crutch goes.

**Translation dossier:** nothing to translate. *Source exemplar* for other
passes — the header pack, `wire.chiral:13-17`:

```lisp
(def wenc (-> I64 I64 Bytes Bytes)
  (lam (obj op body)
    (bcat (pack-u32 obj)
          (bcat (pack-u32 (+ op (* 65536 (+ 8 (blen body)))))
                body))))
```

*Mechanical recipe:* none. Keep. (If the fd-carrying message ever needs to be
marked in the type — Wayland fds ride the cmsg, not the body — that is a
port-face design note for E30's wrapper, not a wire.chiral change.)

**Dependencies:** none. E30 completes its transport story.

**Est. pass size:** — (done).

---

## E36 — niri IPC event stream   [SELF-HOST(done) · Tier R]

**Lives now:**
- `scaffold/lib/wire.chiral:63-96` — `line1` (newline framing, `LSplit`), `ev-name` (outer JSON key extractor) — the niri codec lives in wire.chiral, not a separate file
- Consumers: `scaffold/demo/sensor-core.chiral:14-47` (`fwd-lines`/`sloop` — recv → line-split → `ev-name` → behavior), `demo/tomodachi.chiral:25-40,75-97`, `demo/duo.chiral`, `demo/node-sensor.chiral` (env `NIRI_SOCKET`)
- Event vocabulary: `scaffold/demo/behavior.chiral` (WorkspaceActivated, WindowClosed, …)
- Test double: `scaffold/mock/mockniri.py` (accepts `"EventStream"`, plays scripted lines — Python, test-only)

**Verdict:** PROPER — already chirality. The parsing is deliberately shallow and
should stay that way.

**Explainer:** niri IPC is newline-delimited JSON over an AF_UNIX socket; the
demos consume exactly one bit of structure — the outer one-key object's key —
and `ev-name` (`wire.chiral:87-96`) extracts it by quote-scanning, with `"Ok"`
and `""` filtered at the consumer (`sensor-core.chiral:22`). This is a settled
language-over-demos point: a JSON parser is not owed until some element needs
JSON *values* (none does; the request side sends the literal `"EventStream"`
line). The buffer-carry pattern (`nbuf` threaded through `SSt`,
`sensor-core.chiral:33-47`) is the same incomplete-frame discipline as
`wsplit1` — cite it when E31's wrapper re-plumbs the event loop. What actually
retires here is underneath: `sock-connect`/`sock-recv`/`poll2` (E29/E31) and
`env-get NIRI_SOCKET` (E32's blocked env note). The mock stays Python
(test-only), same status as E37.

**Translation dossier:** nothing to translate. *Source exemplar* for
line-framed protocols — `line1`, `wire.chiral:66-73`. *Mechanical recipe:*
none. If niri's request side ever grows (actions, replies), extend `ev-name`
style helpers, not a JSON library.

**Dependencies:** none; rides E29/E31/E32 for transport self-hosting.

**Est. pass size:** — (done).

---

## E37 — PNG writer (test-only mock)   [REPLACE-CRUTCH(nominal) · Tier R]

**Lives now:** `scaffold/mock/png.py:1-27` — `write_png` (IHDR/IDAT/IEND,
`zlib.compress`, `struct.pack(">I")`, `zlib.crc32`), `argb_le_to_rgba`.
Path confirmed: `scaffold/mock/png.py`. Consumers: test/demo capture only
(the real render path writes ARGB into the shm pool; PNG is how a human looks
at it).

**Verdict:** PROPER — as a test-only mock this is exactly what the catalog
says it is ("mock, low priority"). No pass owed. Recording the honest port
route in case it is ever promoted:

**Explainer:** The only real dependency is zlib — and the PNG spec permits a
zlib stream of *stored* (uncompressed) DEFLATE blocks, which removes the
compressor entirely: header bytes `0x78 0x01` (valid: 0x7801 mod 31 = 0), then
per ≤65535-byte chunk `[BFINAL|BTYPE=00][len u16 LE][~len u16 LE][raw]`, then
Adler-32 (init 1, mod 65521) big-endian. With that, a chirality PNG writer is pure
wire.chiral-idiom byte building plus two loops (CRC-32 table over IHDR/IDAT
chunks, Adler over raw) — both structural recursions over byte cells, the kind
the totality checker already proves. The two format frictions: PNG integers
are **big-endian** (a 4-byte reverse of `pack-u32`, pure) and CRC-32
(polynomial 0xEDB88320 reflected — VERIFY the constant) needs either a
256-entry table (a `brepeat`/`bput`-built cell) or bitwise ops chirality's prim set
lacks (`xor`/`shift` are not prims — only `+ - * / % =i <i <=i`,
`native.py:50`; xor is *expressible* via arithmetic per-bit but ugly). That
missing-bitwise-prims fact is the real finding: any checksum/format work
(CRC, Adler is fine with %, hashing for E27) wants `xor`/`and`/`shr` prims at
the floor — flagged cross-family (F8), since adding prims touches E16/E19/E24.

**Translation dossier:** *Source exemplar* — chunk framing to imitate,
`mock/png.py:8-10` (length + tag+data + crc32). *Target* — only if promoted:
`lib/png.chiral` in wire.chiral idiom + a BE-u32 helper + stored-deflate blocks
as above. *Mechanical recipe:* 1. COPY chunk layout from png.py; 2. TRANSLATE
LE→BE helper; 3. NEW — CRC table build (small, gated on bitwise prims F8).
Do not schedule until something needs it.

**Dependencies:** none (mock). A promotion gates on F8 (bitwise prims).

**Est. pass size:** — (none owed); S/M if ever promoted.

---

# Family footer

## Redo list (ranked by downstream poison)

1. **E29 sockets** — every demo's transport and E30/E33's substrate; while it
   is CPython, no chirality program's I/O story is real. (M)
2. **E30 sendmsg/SCM_RIGHTS** — the single crossing the flagship demo cannot
   run without; hardest, so its helper (`nb-putle`) and build-sheet should land
   early even if the pass itself comes after E29. (M with the sheet)
3. **E33 spawn mechanics** — the staging story (a core design claim) currently
   bottoms out in `subprocess`; the crossing layer is buildable now, and every
   session it isn't, the process-model docs describe Python. (M crossings; L
   protocol, gated on E34/E42 — named, not hidden)
4. **E31 poll2** — small, but it is the event loop; `select.select` is the
   crutch every long-running demo sits in. (S after `nb-putle`)
5. **E28 mmap family** — least poisonous as *crutch* (loader-internal) but
   highest leverage per hour: S-size, unblocks the self-hosted arena and E34's
   segment story. Do it first regardless of rank. (S)
6. **E32 exit/time-mono** — cosmetic-adjacent, S; `env` explicitly blocked on
   E34 (design fact, not debt).

## Ordering (dependency-respecting)

1. **E28** (S, verbatim) — also proves the 6-arg path.
2. **`nb-putle` helper** (E30 step 1; pure, independent, unblocks E30/E31/E33).
3. **E32 exit + monoms** (S).
4. **E29** — S half (socket/listen/accept), then M half (connect/bind).
5. **E31 poll2** (S).
6. **E30 sendmsg** (M, build-sheet above).
7. **E33 crossing layer** (socketpair/fork/dup2/execve/wait4; fork-then-exec
   tests).
8. **E34 ELF** (M; pure `lib/elf.chiral` + driver; can start any time — only
   its *chirality-side file writing* waits on E28/open).
9. E33 protocol layer + E32 env — after E34 (+E42, other family).
   E35/E36 done; E37 not scheduled.

## The S-size verbatim-recipe queue (recipe applies with zero new machinery)

`nb-sys-mmap` (9), `nb-sys-munmap` (11), `nb-sys-mprotect` (10),
`nb-sys-close` (3), `nb-sys-socket` (41), `nb-sys-listen` (50),
`nb-sys-accept` (43, NULL/NULL), `nb-sys-dup2` (33), `nb-sys-fork` (57),
`nb-sys-exit` (231) — plus `open` (2) and send/recv-as-write/read using the
already-proven bptr pattern.

## Cross-family flags

- **F1 (candidate E51 / E42):** *upper-effectful → sys-face linkage does not
  exist.* Lowered pure code is forbidden the sys face by design
  (`tal.py:34-41`, enforced `test_native.py:385-394`); effectful upper code has
  no path to call a tal function at all. Every crossing built here is therefore
  test-reachable only. Retiring `impl_ports.py` needs a deliberate seam
  (extern → sys-face tal call at link time, membrane-checked). This is the
  family's binding external dependency and belongs to the runtime/process
  family or a new element.
- **F2 (E25 bytes family):** `nb-putle`/`nb-put64`/`nb-put32` cell-store
  helpers — pure, nb-copy-shaped; spec'd under E30 above.
- **F3 (E26/E39 effects):** −errno → alarm mapping convention. Crossings return
  raw negative errnos; today's `PortError` texts (`impl_ports.py:96` etc.) are
  the behavior to preserve at the typed face.
- **F4 (E18/E19):** `ti-sys` accepts >6 args unchecked; `sys-modrm` silently
  emits r9 for any index ≥5 (`mach-x64.chiral:260-266`), and `arg-modrm` has the
  same shape (`mach-x64.chiral:53-59`). One-line arity guard in `tal.py:145-151`
  wanted.
- **F5 (E42/E43 + bridge):** when Sock/Fd/Pool become raw fds/addresses at
  runtime, `bridge.py:19` `_ATOM_TAG` verification and the `("sock", s)` tuple
  convention (`impl_ports.py:8`) change together. Not this family's pass.
- **F6 (E18/E25):** bnew zero-init is an accident (reference zeroes; native
  relies on virgin arena pages, `mach-x64.chiral:216-225`). Either document
  cells-are-zero as a contract (and zero on any future bump-rewind) or require
  explicit fills. Struct crossings above store every byte regardless.
- **F7 (E34/E42):** `env-get` has no syscall; it is envp-at-entry (E34) or a
  `/proc/self/environ` Linux-ism. Recorded under E32.
- **F8 (E16/E19/E24):** no bitwise prims (`xor/and/or/shr`) at the floor —
  blocks CRC-32 (E37 promotion) and cheap hashing (E27). Adding prims touches
  the prim table (`native.py:50`), `impl_pure.py`, `op-bytes`
  (`mach-x64.chiral:112-122`), and the fold — a coordinated small pass.
- **F9 (E50 totality):** the sendall short-write loop's decrement is
  data-dependent (not ±1), outside the current measure checker — the sys
  wrappers won't be in the total fragment; fine, but worth a line in
  `docs/totality.md` when F1 lands.

## VERIFY ledger (egress blocked; all from ABI memory)

Confident: all syscall numbers in the master table; pollfd, sockaddr_un,
timespec, msghdr/cmsghdr/iovec layouts and CMSG arithmetic; ELF field offsets.
To verify against man-pages/musl/gABI when possible: PT_GNU_STACK constant
0x6474e551 and its p_align; e_shentsize=0 tolerance; EI_OSABI 0-vs-3;
msg_controllen 24-vs-20 for a single cmsg; O_CLOEXEC/SOCK_CLOEXEC = 0x80000;
CRC-32 polynomial 0xEDB88320; CPython bytearray buffer alignment ≥8 (reference
machine only).
