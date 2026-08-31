---
element: E126
slug: socketpair
title: Native `socketpair` — two connected linear Sock caps (hermetic sv-drain gate)
kind: BUILD-PROPER
reference_class: SPEC+OURS
ours_source: (none)
status: drafted
updated: 2026-08-12
---

# E126 — Native `socketpair` — two connected linear Sock caps (hermetic sv-drain gate)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E126, a native `socketpair(2)` crossing that hands back **two
  already-connected linear `Sock` caps** — the *hermetic* socket acquisition (no
  listener, no peer, no name).
- **Kind:** BUILD-PROPER — no surface `socketpair` extern or `nb-sys-socketpair`
  TAL exists yet (grep-clean; `socketpair` currently lives only inside the Python
  oracle spawn, `impl_ports.py:126`). The `Sock`/`SockVec`/`sv-drain` lifecycle it
  rides is already built (E123/E124/E107).
- **Why chirality needs its own:** it is the **milestone gate** for the linear-cap
  collection machinery. Every other socket crossing (`sock-accept`,
  `sock-connect`) needs an external peer to exercise; `socketpair` manufactures
  two real, connected, native fds *in-process*, so the `sv-push`/`sv-drain` path
  can be driven end-to-end with zero network dependency — a hermetic test that
  two real caps are acquired, threaded, and each closed exactly once.

## 2. Research

- **Reference class:** SPEC (Linux `socketpair(2)` ABI) + OURS (the chirality
  precedents: `ports.chiral` `Sock` carrier E123, `lincoll.chiral` `sv-drain`,
  `sys-tal.chiral` alloc-inside out-cell E99, `target-linux.chiral`,
  `crossing-wraps.chiral`).
- **Key findings (web-verified, not from memory):**
  - **Syscall number = 53** on x86-64. Args land `family→rdi`, `type→rsi`,
    `protocol→rdx`, `sv→r10` (int*). Returns `0` on success, `-errno` on error.
    (`filippo.io/linux-syscall-table`; `torvalds/linux`
    `arch/x86/entry/syscalls/syscall_64.tbl`; `man7 socketpair(2)`.)
  - **Constants:** `AF_UNIX = 1`, `SOCK_STREAM = 1`, `protocol = 0`. On Linux the
    only domains `socketpair` accepts are `AF_UNIX`/`AF_LOCAL` (and `AF_TIPC`);
    `AF_UNIX + SOCK_STREAM + 0` is the canonical connected-stream pair. (`man7
    socketpair(2)` / `unix(7)`.)
  - **Out-buffer:** `int sv[2]` = two 32-bit fds = **8 bytes**; fd0 at byte
    offset 0, fd1 at byte offset 4, both native-endian (little-endian on x86-64).
    The kernel is just another writer into a caller-allocated cell — exactly the
    winsz/ptsno alloc-inside pattern (`sys-tal.chiral:472,597`).
  - The two fds come back **already connected** (full-duplex stream) — no
    `connect`/`accept` handshake, which is precisely why this is the hermetic
    gate.

## 3. Conventional (other-language) approach

How this is done outside chirality — C / the CPython oracle.

```c
int sv[2];
if (socketpair(AF_UNIX, SOCK_STREAM, 0, sv) < 0)   /* nr 53 */
    perror("socketpair");                          /* errno, side-channel */
/* sv[0], sv[1] are two connected fds — plain ints. */
use(sv[0]); use(sv[1]);
close(sv[0]); close(sv[1]);                        /* MUST close both, by hand */
```

```python
# impl_ports.py:126 (oracle side)
a, b = socket.socketpair()   # returns two socket objects; GC/refcount closes them
```

- **Assumptions it bakes in:**
  - **Ambient, untyped fds** — `sv[0]`/`sv[1]` are bare `int`s. Nothing stops a
    double-close, a leak (forget one), a use-after-close, or aliasing the same fd
    into two owners.
  - **Errors as a side-channel** — failure is a `-1` return plus a global
    `errno`, not part of the value.
  - **Ambient allocation** — `int sv[2]` is stack scratch the caller must size and
    the kernel scribbles into; no proof the two slots are the two you read.
  - **Manual, unenforced release** — "close both" is a comment, not a type.

## 4. The chirality idea

How chirality's model reframes it.

- **Chirality features in play:** QTT linear quantities (`(1 s Sock)`), the `=>`
  process membrane, ports/capabilities (`porttype Sock`, E123 carrier), boundary
  sums (result-as-value, E29), category-C bridge over a raw syscall, and the
  `SockVec`/`sv-drain` linear-collection lifecycle.
- **The reframing:**
  - The two raw fds are lifted at the boundary into **two linear `Sock` caps**.
    `Sock` is a `porttype` — an opaque linear atom (`ports.chiral:12`) whose E123
    carrier lowers each field to the raw fd word, so inside TAL a `Sock` *is* just
    the `int` fd, but at the surface it is move-only and closeable exactly once.
  - Success/failure is a **closed sum value**, `SockPairR`: `sp-ok` carries the
    two linear caps; `sp-err` carries a message (the `-errno` decoded once at the
    boundary). The caller must `case` it — the error path is in the signature, not
    a global. Mirrors `ConnR`/`AccR` in `ports.chiral:35,38`.
  - The `sv[2]` out-cell is caller-allocated with `ti-bnew` and handed to the
    kernel as *another writer* (winsz/ptsno precedent) — the len word stays
    chirality's; the raw→sum lift happens **inside the crossing body**, so the surface
    only ever sees `SockPairR`.
  - Downstream, the two caps flow into a `SockVec` (`sv-push a (sv-push b
    sv-nil)`) and the **only** end of that vector is `sv-drain`, which closes
    every held cap exactly once (`lincoll.chiral:65`).
- **What chirality makes impossible here:** dropping a returned fd (linear `1` binder
  — the checker rejects a non-consumed `Sock`), double-closing one (`sv-drain`
  consumes each exactly once), aliasing a cap into two owners (move-only), reading
  a fd from an error result (no `Sock` field on `sp-err`), and treating failure as
  success (must `case` the sum). No ambient authority: the caps exist only as the
  named result of the crossing.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
; ── surface: ports.chiral additions ─────────────────────────────────────────
; result-as-value sum; the port fields are linear (move-only) — mirror of ConnR.
; sp-ok carries TWO connected caps; sp-err drops both handles, carries a message.
(data SockPairR ()
  (sp-ok  (1 a Sock) (1 b Sock))
  (sp-err (msg Str)))

; the hermetic acquisition crossing: no argument port, => because it crosses.
(extern socketpair (=> Unit SockPairR))

; ── the TAL crossing body (sys-tal.chiral) — alloc-inside out-cell, E99 pattern ─
; socketpair(AF_UNIX=1, SOCK_STREAM=1, 0, sv) ; nr 53. Args rdi rsi rdx r10.
; The raw→sum boundary lives HERE: read the two u32 fds, tag into sp-ok/sp-err.
(def nb-sys-socketpair-t TIFn
  (ti-fn "nb-sys-socketpair" 0 12
    (t-seq (ti-const 0 1)                       ; AF_UNIX
    (t-seq (ti-const 1 1)                       ; SOCK_STREAM
    (t-seq (ti-const 2 0)                       ; protocol
    (t-seq (ti-const 3 8)                        ; sv[2] = two ints (bnew len is a SLOT)
    (t-seq (ti-bnew 4 3)                         ; reg4 = fresh 8-byte out-cell
    (t-seq (ti-bptr 5 4)                         ; reg5 = &sv payload (kernel gets payload, not cell)
    (t-seq (ti-sys 6 53 (cons 0 (cons 1 (cons 2 (cons 5 nil)))))
    (t-seq (ti-const 7 0)
    (t-seq (ti-prim 8 (op-lti) 6 7)              ; r < 0 ?
      (ti-tcase 8 false
        (cons (pair (pair 0 nil)                 ; tag0 = true  = ERROR
          ; … decode -errno → Str, build (sp-err msg) …
          (ti-ret 9))
        (cons (pair (pair 1 nil)                 ; tag1 = false = OK
          ; read fd0 @ off 0, fd1 @ off 4 of the out-cell (two u32 LE),
          ; each fd word IS a Sock (E123 carrier), assemble (sp-ok fd0 fd1)
          (t-seq (ti-bget 10 4 <idx0>)           ; fd0
          (t-seq (ti-bget 11 4 <idx1>)           ; fd1
          ; … pack (sp-ok (reg10 as Sock) (reg11 as Sock)) …
            (ti-ret 12))))
        nil))
        none)))))))))))

; ── the hermetic milestone sample (samples/…) ──────────────────────────────
(def main (=> Unit I64) (lam (u)
  (case (socketpair unit)
    ((sp-ok a b)
      ; two REAL connected caps → into a SockVec → drain closes each exactly once
      (let ((_ (sv-drain (sv-push a (sv-push b sv-nil)))))
        42))                                     ; exit 42 = hermetic pass
    ((sp-err m) 1))))                            ; defined failure exit
```

- **Knobs to modify:** the domain/type constants (`AF_UNIX`/`SOCK_STREAM` → e.g.
  `SOCK_DGRAM`), the errno-decode arm shared with the other `*-err` sums, the
  success exit code, and whether the sample also does a `sock-send`/`sock-recv`
  round-trip over the pair before draining (out of scope for the pure-acquisition
  gate).
- **Deliberately omitted:** any `sockaddr` packing (there is none — `socketpair`
  takes no address), `SOCK_CLOEXEC|SOCK_NONBLOCK` type flags (a later knob), the
  exact errno→`Str` decode (shared boundary helper), and the precise `ti-bget`
  word-index encoding for the two u32 reads (see open questions).

## 6. Use / modify notes

- **Lands in:** surface `SockPairR` + `socketpair` extern in
  `scaffold/lib/ports.chiral`; `nb-sys-socketpair-t` in `scaffold/lib/sys-tal.chiral`
  (registered in the sys-tal fn list) and its `crossing-wraps` row
  (`socketpair → nb-sys-socketpair`) in `scaffold/lib/crossing-wraps.chiral`; nr 53
  in `scaffold/lib/target-linux.chiral`; `sys-linkage` auto-derives from
  crossing-wraps. The milestone sample under `scaffold/samples/`.
- **Conformance target — the hermetic `sv-drain` milestone gate:**
  `socketpair → (sp-ok a b) → sv-push a (sv-push b sv-nil) → sv-drain → native
  exit 42`. Two REAL connected native caps acquired, threaded through a `SockVec`,
  and each closed exactly once by `sv-drain` — verified with **no peer, no
  listener, no network** (the property that distinguishes E126 from the DEFERRED
  E127 sock-connect). Type-checks (linear threading holds) AND runs to exit 42.
- **SIZE verdict: S–M.** Rationale: **no `sockaddr` packing** (the usual socket
  cost) and the crossing rides an existing, well-worn precedent chain — the
  alloc-inside out-cell (winsz/ptsno, E99), the result-sum shape (`ConnR`/`AccR`),
  the `Sock` carrier (E123), and the whole `SockVec`/`sv-drain` lifecycle
  (E123/E124/E107) are all already built. But it is not a one-const flip: it adds
  a **new surface extern + a new result type** (`SockPairR`) and does a genuine
  **two-u32 out-cell read + raw→sum lift inside the body**, which is more than the
  value-in/rax-out crossings (E121 fcntl). Net: a bounded, precedent-guided
  addition.
- **Exact new surface/TAL/rows/numbers:**
  - New type: `SockPairR = (sp-ok (1 a Sock) (1 b Sock)) | (sp-err (msg Str))`.
  - New extern: `socketpair : (=> Unit SockPairR)`.
  - New TAL fn: `nb-sys-socketpair-t` (`ti-sys … 53`), alloc-inside `ti-bnew 8`
    out-cell, `ti-bptr` for the r10 arg, two u32 reads at offsets 0/4.
  - Constants: `AF_UNIX = 1`, `SOCK_STREAM = 1`, `protocol = 0`, syscall nr `53`.
  - One `crossing-wraps` row: `("socketpair" "nb-sys-socketpair")`.
  - `target-linux.chiral`: nr `53`. `sys-linkage` auto-derives.
- **Open questions (for the spec):**
  1. **Reading the two u32 fds** — `ti-bget` reads by *word index* at the boxed
     payload offset (`sys-tal.chiral:467`, `ti-const 7 1; ti-bget 8 5 7` = second
     u64 slot). For two adjacent **u32** fds at byte 0 and byte 4 the index/width
     encoding must be pinned: does `ti-bget` index 32-bit words here, or is a
     dedicated u32 read (à la `bget-u32-le`, `bytes-tal.chiral:535`) needed at the
     TAL floor? The spec must nail the exact primitive + index.
  2. **`SockPairR` new vs reuse** — is a fresh two-cap-success sum warranted, or
     should this reuse/extend an existing shape? (`Poll2R` already carries `(1 a
     Sock) (1 b Sock)` but has no error arm and different semantics; `ConnR`
     carries one cap.) Recommend **new** `SockPairR` — the two-connected-caps
     acquisition is a distinct boundary — but flag for the author.
  3. **errno decode** — reuse whatever `*-err`-building helper the other socket
     crossings share for `-errno → Str`, or inline a minimal one? (Consistency
     call.)
  4. **`ti-fn` arity/temps** — the `0`-arg / temp-count in the sketch is
     indicative; the real register budget follows the tcase/pack lowering.
- **Related:** [[E123]] (Sock carrier — fd word lowers), [[E124]] / [[E107]]
  (cap lifecycle + close), [[E99]] (ioctl alloc-inside out-cell precedent),
  [[E127]] (DEFERRED sock-connect — the non-hermetic sibling), `sv-drain`
  (`lincoll.chiral:67`), `ConnR`/`AccR` (`ports.chiral:35`).
