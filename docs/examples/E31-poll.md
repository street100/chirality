---
element: E31
slug: poll
title: "poll(2): the struct-passing crossing — pollfd arrays, readiness as evidence, the deadline that bounds time"
kind: REPLACE-CRUTCH
reference_class: SPEC
ours_source: scaffold/chirality/impl_ports.py (`poll2`, the select.select crutch)
status: drafted
updated: 2026-07-22
---

# E31 — poll(2): the struct-passing crossing

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.
> ABI facts are **looked up, not researched**: `refs/ref-poll.md` (regenerable,
> `refs/gen-poll.py`, local sources, MEASURED where possible).

## 1. Scope

- **Element:** E31, the readiness crossing: replace CPython `select.select`
  behind the `poll2` extern with a hand-tal `poll(2)` crossing — the floor's
  **first array-of-structs argument** (N × `pollfd`), and its first
  kernel-written-back buffer that is *not* a flat payload.
- **Kind:** REPLACE-CRUTCH (`impl_ports.py:182–191`; delegation-map lane A).
- **Why chirality needs its own:** poll is the demo's **only time-boundedness
  mechanism** — the tomodachi's whole cadence is "block on two ports until an
  event or the deadline," which is time-and-clocks' third sense, *time you
  must act by*. Until this crossing is chirality, the program's one clock hangs
  off CPython.

## 2. Research

- **Reference class:** SPEC — `poll(2)` ABI, banked in `refs/ref-poll.md`.
- **Key facts (from the ref; per-row sources there):**
  1. syscall **7**; args rdi = array ptr, rsi = nfds, rdx = timeout-ms —
     three registers, within the existing sys-tal bank.
  2. `pollfd` is **8 bytes**: fd i32 @0, events i16 @4, revents i16 @6
     (MEASURED). Entry *i* at `8*i`; a 2-entry array is `bnew 16`.
  3. **revents is kernel-written**: we zero it (a fresh cell reads 0 on both
     floors, by contract), the kernel writes readiness INTO our cell, we read
     it back as evidence. Mixed ownership inside one cell across one crossing.
  4. Event bits: POLLIN 0x1, POLLOUT 0x4, POLLERR 0x8, POLLHUP 0x10,
     POLLNVAL 0x20. Timeout: ms; **-1 forever, 0 immediate**; -errno on
     failure (EINTR included — caller decides re-arm).

## 3. Conventional (other-language) approach

The OURS crutch — readiness via the CPython stdlib, structs never touched:

```python
@impl("poll2")
def _poll2(av, bv, timeout_ms):
    timeout = None if timeout_ms < 0 else timeout_ms / 1000.0
    ready, _, _ = select.select([av[1], bv[1]], [], [], timeout)
    idx = -1
    if av[1] in ready:
        idx = 0
    elif bv[1] in ready:
        idx = 1
    return ("con", "poll2-r", [idx, av, bv])
```

- **Assumptions it bakes in:** the struct marshalling is someone else's
  problem (CPython builds the fd sets); readiness collapses to one `idx`,
  throwing away *why* (POLLHUP vs POLLIN vs POLLERR — the crutch cannot say
  "peer closed" except by a later failed read); floats in the timeout path;
  ambient authority (any importer of `select` can wait on any fd); and the
  fd's identity leaks around the port abstraction as a bare tuple field.

## 4. The chirality idea

- **Chirality features in play:** byte cells (`bnew`/`bput`/`bget`) as the
  struct-passing substrate; linear port threading (view-and-thread, the
  drafted E51 `FdView` shape); result sums for errno; the sys crossing; the
  effect row naming `poll` as a crossing.
- **The reframing:** the pollfd array is an ordinary byte cell the wrapper
  *assembles* (fd and events written per entry at ref offsets), the crossing
  is one `sys` with three registers, and readiness comes back as **typed
  evidence**: revents read out of the cell, decoded against the ref's bits
  into a `Ready` value per entry — richer than the crutch's `idx`, because
  HUP/ERR become facts the caller cases on instead of a later read surprise.
- **Nondeterminism, seated:** *which* port is ready is chosen by the
  environment, not the program. That needs no nondeterminism effect: the
  choice arrives as the **crossing's result** — B-world's answer, verified at
  the membrane like any other evidence. The row records that `poll` happened;
  the result records what the world said.
- **What chirality makes impossible here:** waiting on an fd you don't hold (the
  wrapper demands the linear ports; views are minted only inside the sys
  library — E51 open question 1); ignoring the error path (errno is a
  constructor); conflating timeout with readiness (distinct constructors);
  losing a port on any path (every path threads both socks back, checked).

## 5. Chirality example (fleshed)

```chirality
(import "prelude")
(import "sys-tal")            ; nb-sys-poll: syscall 7, 3-register crossing

; ---- readiness, decoded: revents as a typed fact (bits: refs/ref-poll.md)
(data Ready () (rd-none) (rd-in) (rd-hup) (rd-err))   ; demo's need; extend

; ---- result: timeout / ready / errno — ports thread back on EVERY path
(data Poll2R ()
  (p2-timeout (1 a Sock) (1 b Sock))
  (p2-ready   (r0 Ready) (r1 Ready) (1 a Sock) (1 b Sock))
  (p2-err     (errno I64) (1 a Sock) (1 b Sock)))

; per-porttype view, sys-library-minted, threading per the drafted shape
; (QTT has no borrowing: the view consumes and returns — the RecvR pattern)
(data SockView () (sock-view-r (raw I64) (1 s Sock)))
; (extern sock-view (=> (1 s Sock) SockView))          ; sysface-only mint

; deadline is "time you must act by": ms; -1 forever, 0 immediate (ref)
(declare poll2-sys (=> (1 a Sock) (1 b Sock) I64 Poll2R))
(def poll2-sys
  (lam (a b tmo)
    (case (sock-view a)
      ((sock-view-r fa a2)
       (case (sock-view b)
         ((sock-view-r fb b2)
          ; 2-entry pollfd array: stride 8 => bnew 16 (ref). A fresh cell
          ; reads 0 on both floors by contract, so revents@6/@14 start zeroed.
          ;   entry0: fd(i32)@0 := fa   events(i16)@4 := POLLIN (0x1)
          ;   entry1: fd(i32)@8 := fb   events(i16)@12 := POLLIN
          ; i32/i16 stores via put helpers (pack-u32 precedent; a put-i16
          ; sibling is owed — first 16-bit fields at the floor). ; …
          (let ((cell (pollfd-fill (bnew 16) fa fb)))
            (let ((ret (nb-sys-poll (bptr-of cell) 2 tmo)))
              (if (<i ret 0)
                  (p2-err (- 0 ret) a2 b2)
                (if (=i ret 0)
                    (p2-timeout a2 b2)
                  ; readiness = evidence read back from the kernel-written
                  ; halves: revents@6 and @14, decoded per the ref's bits
                  (p2-ready (decode-revents (bget-i16 cell 6))
                            (decode-revents (bget-i16 cell 14))
                            a2 b2)))))))))))

; decode-revents: 0 => rd-none; HUP(0x10) checked before IN(0x1) so a closed
; peer reads as rd-hup even when data remains — policy, stated not hidden ; …
```

- **Knobs to modify:** the `Ready` decode policy (HUP-before-IN above; or
  carry the raw bitmask alongside); events per entry (POLLIN only is the
  demo's need; POLLOUT for writable-wait); the timeout constructor split.
- **Deliberately omitted:** the `pollfd-fill` byte loop (mechanical `bput`s
  at ref offsets); the put-i16/bget-i16 helpers (2-byte LE composites of
  `bput`/`bget`); the N-ary generalization — see open questions, it is a
  *language* question, not a loop.

## 6. Use / modify notes

- **Lands in:** `lib/sys-tal.chiral` (`nb-sys-poll`, all-integer 3-register
  crossing) + the E51 binding table (`poll2` → `wrap-poll2` over this shape);
  `impl_ports.py:_poll2` retires with the table flip.
- **Conformance target:** differential vs `select.select` on real pipes with
  **staggered readiness** — write to pipe A only, then B only, then both,
  then neither-with-timeout-0, then neither-with-30ms (timeout path); revents
  decode checked against a peer-closed pipe (POLLHUP) and a closed-fd entry
  (POLLNVAL). The crutch's `idx` semantics must be reproducible as a
  projection of `p2-ready` (first-ready-wins) so existing tests stay green.
- **Open questions:** (1) **N-ary linear collections** — the pollfd array
  wants N ports, but linear kinds forbid `(List Sock)` (generic containers
  cannot hold ports, E8); today the honest shape is per-arity results
  (`Poll2R`, the demo's need) — a first-class *linear vector* declaration
  (a port array with 1-fields) is the missing language shape, and poll is
  the crossing that forces it first. (2) **Mixed-ownership cell**: fd/events
  are ours, revents is kernel-written — one cell, two writers across one
  crossing; does bridge-verify's re-read cover only the evidence bytes, and
  should the fill/read split be typed? (3) **The deadline as a type**: `tmo`
  is a bare I64 ms; time-and-clocks' "act by" wants the window typed (expiry
  firing a counter-effect) — couples the in-doubt-grant expiry design.
  (4) put-i16/bget-i16: the floor's first sub-word multi-byte fields —
  helpers over `bput`/`bget`, or new byte-face ops?
- **Related:** [[E51-sys-linkage]] (binding table + view threading),
  [[E29-sockets]] (the ports being waited on), [[E70-effectful-lowering]]
  (the row shadow this crossing lands in), E30 (fd-passing sibling),
  `refs/ref-poll.md` (the ABI bank), `docs/time-and-clocks.md` (the third
  sense of time).
