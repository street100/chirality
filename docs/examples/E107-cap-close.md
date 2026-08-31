---
element: E107
slug: cap-close
title: Porttype-consuming native close family: `sock-close`/`fd-close`/`env-close`/`lsock-close`/`pool-close` as crossings that CONSUME a linear (quantity-1) porttype and lower to its release syscall (`nb-sys-close` for fd-backed types) — E105-shaped surface extern + `crossing-wraps` pair over already-registered syscalls; completes E106's runtime leg so a real cap drains to a native exit-42 run
kind: BUILD-PROPER
reference_class: OURS/SPEC
ours_source: (none)
status: drafted
updated: 2026-08-11
---

# E107 — Porttype-consuming native close family

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E107, the porttype-consuming native **close family** — a crossing
  per porttype that consumes a linear (quantity-1) cap and lowers to that type's
  release syscall. The five surface externs already exist in `ports.chiral`
  (`sock-close` :63, `lsock-close` :59, `fd-close` :80, `pool-close` :75,
  `env-close` :121); E107 is the **lowering leg** — the `crossing-wraps` pairs
  that let those consuming crossings emit native code.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** E106 (`lincoll.chiral`) built `SockVec` and its
  `sv-drain`, the ONLY end of a linear cap collection — it closes every held cap
  by calling `sock-close`. But `sock-close` does not lower: `crossing-wraps.chiral:21`
  has only the raw-fd `close`→`nb-sys-close` pair; no porttype-consuming close is
  in the table. So a `SockVec` drain type-checks but cannot reach a native
  exit-42 run. E107 closes that gap — the runtime leg E106 left open.

## 2. Research

- **Reference class:** OURS/SPEC — `ports.chiral` (the porttype floor + the five
  already-declared `*-close` externs), `crossing-wraps.chiral` (the lowering
  table), `sys-tal.chiral` (the TAL syscall bodies), `lincoll.chiral` (E106, the
  ready consumer). SPEC: `close(2)` / `munmap(2)` (man7, verified below). The
  shape to mirror is E105's `write-fd`→`nb-sys-write` pair.
- **Key findings:**
  - **The syscalls are already registered.** `nb-sys-close-t` (nr 3, one arg in
    rdi) and `nb-sys-munmap-t` (nr 11, addr+length) both live in `sys-tal.chiral`
    and are listed in `sys-lib`. E107 adds **no new TAL body** — only the
    surface→wrapper `crossing-wraps` pairs. (No separate
    `sys-linkage` edit: its `sys-bindings` is *derived* from `crossing-wraps` via
    `cw->binds crossing-wraps` — `sys-linkage.chiral:87-93` — so a new pair flows
    there automatically; by construction the two cannot drift.) This is strictly
    smaller than E105, which also authored a body.
  - **`close(2)` is not idempotent** (man7): "Retrying the close() after a
    failure return is the wrong thing to do, since this may cause a reused file
    descriptor … to be closed." Double-close is a real bug. A linear
    (quantity-1) consuming crossing makes double-close **untypeable** — the cap
    goes in exactly once and nothing threads back. The type is the fix for the
    exact hazard the man page warns about.
  - **`munmap(addr, length)` needs the length at runtime** (man7: "length …
    parameter is necessary"; returns 0 / -EINVAL). And mapping and fd are
    independent: "After the mmap() call has returned, the file descriptor … can
    be closed … without invalidating the mapping." So a memfd-backed `Pool`
    carries **two** obligations — the mapping (release via `munmap`) and the fd
    (release via `close`) — matching `PoolR`'s two linear fields
    `(pool-r (1 pool (Pool n)) (1 fd Fd))` (`ports.chiral:34`).

## 3. Conventional (other-language) approach

Outside chirality, release is an untyped runtime call with no exactly-once guarantee.

```c
int fd = accept(lsock, NULL, NULL);
/* ... use fd ... */
close(fd);              /* nothing stops a second close(fd) below */
close(fd);              /* double-close: may reap a *different* fd (man7 close(2)) */

void *p = mmap(NULL, len, PROT_READ|PROT_WRITE, MAP_SHARED, memfd, 0);
close(memfd);           /* fd and mapping are independent */
munmap(p, len);         /* forget len, or forget this call entirely -> leak */
```

- **Assumptions it bakes in:** release is ambient (any code holding the int may
  close it); use-after-close and double-close are runtime UB, not type errors;
  the release call is untracked, so a leaked mapping is silent; `munmap`'s
  `len` is a hand-carried integer with no link to the region it frees.

## 4. The chirality idea

The cap is a linear (quantity-1) `porttype` value; its close is a **crossing that
consumes it** — the terminal move across the membrane. It goes in, the resource
is released, nothing threads back (contrast `RecvR`, which returns the live cap).
This is the corpse case: a consumed cap is unusable and un-droppable by
construction, so double-close and use-after-close are both non-terms.

- **Chirality features in play:** QTT quantity-1 possession (`(1 s Sock)`); the effect
  membrane (`=>` — a crossing performs the syscall); the E105 lowering shape
  (surface extern + `crossing-wraps` pair over a registered syscall); boundary
  sums (E106's `RecvR`/`DetachR` thread live caps, the close family does not).
- **The reframing — one close per porttype, mapped to its real release** (this is
  a *family*, not one close; each was verified against `ports.chiral` +
  `sys-tal.chiral`):

  | Porttype | Surface extern (already in `ports.chiral`) | Release | Wrapper (already in `sys-lib`) |
  |---|---|---|---|
  | `Sock` | `sock-close` :63 | `close(fd)` | `nb-sys-close` (nr 3) |
  | `LSock` | `lsock-close` :59 | `close(fd)` | `nb-sys-close` (nr 3) |
  | `Fd` | `fd-close` :80 | `close(fd)` | `nb-sys-close` (nr 3) |
  | `Pool n` | `pool-close` :75 | `munmap(addr,len)` — the mapping; the paired `Fd` is closed separately via `fd-close` | `nb-sys-munmap` (nr 11) |
  | `Env` | `env-close` :121 | **nothing to release at the OS level** | — (see residue) |

  `Env` is the honest odd-one-out: `env-open` (:120) is an INTERIM ambient
  acquisition, `env-view` reads the process environ (no syscall), and there is no
  env syscall in `sys-tal.chiral`. `env-close` discharges the *linear obligation*
  (the cap is consumed exactly once) but performs no crossing — its lowering is
  moot until real Env acquisition lands with `profile-hands-caps`, and `env-open`
  doesn't lower today either, so an `Env` cap can't reach a native run yet
  regardless.
- **What chirality makes impossible here:** dropping a cap without closing it (linear
  = used exactly once, the checker rejects the drop); closing it twice (it is
  consumed on the first close, there is no second value); using it after close
  (nothing threads back). The `close(2)` reused-fd hazard is untypeable.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
; ── ports.chiral: the consuming crossings (ALREADY DECLARED — shown for shape) ──
; A consuming close takes the linear cap and returns Unit: the cap goes IN, the
; resource is released, NOTHING threads back. Contrast RecvR, which returns the
; live Sock. This is the terminal/corpse move across the => membrane.
(extern sock-close  (=> (1 s Sock) Unit))                       ; :63
(extern lsock-close (=> (1 l LSock) Unit))                      ; :59
(extern fd-close    (=> (1 f Fd) Unit))                         ; :80
(extern env-close   (=> (1 e Env) Unit))                        ; :121
; pool-close's size is an ERASED (0) type param — it exists only in types:
(extern pool-close  (-> (0 n I64) (=> (1 p (Pool n)) Unit)))    ; :75

; ── crossing-wraps.chiral: THE E107 DELTA — the lowering pairs to ADD ──
; Mirror the E105 write-fd pair EXACTLY: surface name -> already-registered
; wrapper. No new TAL body; nb-sys-close (nr 3) and nb-sys-munmap (nr 11) are
; already in sys-lib. (No hand-edit to lib/sys-linkage.chiral: its sys-bindings is
; DERIVED from this table — (def sys-bindings (cw->binds crossing-wraps)) at
; sys-linkage.chiral:93 — so a new pair here flows to the linkage side by itself.)
(cons (pair "write-fd"    "nb-sys-write")     ; E105, the shape to copy
(cons (pair "sock-close"  "nb-sys-close")     ; E107  ─┐
(cons (pair "lsock-close" "nb-sys-close")     ; E107   │ fd-backed: release = close(fd)
(cons (pair "fd-close"    "nb-sys-close")     ; E107  ─┘
(cons (pair "pool-close"  "nb-sys-munmap")    ; E107  memfd region: release = munmap(addr,len)
  nil)))))
; env-close: intentionally NOT paired — no OS release; the linear obligation is
; discharged at the type level, the crossing is a no-op pending profile-hands-caps.

; ── lincoll.chiral (E106): sv-drain's call site, NOW reaching native ──────────────
; process (=>): sock-close is a crossing. Structural recursion => total.
; Once the sock-close pair above lowers, this drains a real SockVec to native.
(declare sv-drain (=> (1 v SockVec) Unit))
(def sv-drain
  (lam (v)
    (case v
      (sv-nil unit)
      ((sv-cons h t)
        (case (sock-close h)          ; ← was: no wrapper -> no native emit
          (unit (sv-drain t)))))))    ; ← now: lowers to close(fd), drains to exit 42

; ── the E106 conformance run this unblocks (skeleton) ────────────────────────────
(declare compile-main (=> Unit I64))
(def compile-main
  (lam (_)
    ; … acquire >=2 caps, push into a SockVec (sv-push), service one …
    (case (sv-drain the-vec)          ; close every held cap exactly once
      (unit 42))))                    ; exit 42 — the reachable behavioral target
```

- **Knobs to modify:** which porttype (each row is one `(pair "<x>-close" "<wrapper>")`);
  the wrapper only ever differs by the release syscall (`nb-sys-close` for
  fd-backed, `nb-sys-munmap` for the pool mapping).
- **Deliberately omitted:** the cap-acquisition side (E107 is release only); the
  `Pool` native-lowering question (see §6). No `sys-linkage.chiral` rows are
  omitted — its `sys-bindings` is derived from this table, not a parallel list.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/crossing-wraps.chiral` (the four/five new pairs)
  ONLY. `sys-linkage.chiral`'s `sys-bindings` is derived from that table
  (`cw->binds crossing-wraps`, `sys-linkage.chiral:93`), so it needs no edit. No
  change to `ports.chiral` (externs exist) and no new body in `sys-tal.chiral`
  (`nb-sys-close` / `nb-sys-munmap` exist).
- **Conformance target:** the E106 behavioral sample — hold ≥2 linear caps in a
  `SockVec`, service one, `sv-drain` the rest, **B1-compiled, exit 42**. Measured
  today (verbatim through `scaffold/build/B1`):
  - Control — `compile-main` calling raw-fd `close` on an fd: **compiles and runs
    to exit 42**. The shape is reachable.
  - The gap — `compile-main` whose body reaches `sock-close` via `sv-drain`:
    `no emitted label for entry compile-main` (compile exit 1) — the exact E106
    signal. `sock-close` has no wrapper, so `sv-drain` can't emit, so the entry
    can't emit.
- **Open questions:**
  - **`pool-close`→`munmap` needs the region length at runtime — but that length
    is NOT lost (cf. the E113 pre-run).** The runtime `Pool` value is the host
    tuple `("pool", mm, size)` (`impl_ports.py:8`, minted at `impl_ports.py:273`),
    and `pool-close` already reads `size` to `munmap` (`impl_ports.py:278-282`).
    So the erased type param `n` (`(0 n I64)`) is only the *type-level* bound; the
    concrete length rides in the port value, host-side. The real open work is
    different: **`pool-*` crossings have no native binding at all yet** — there is
    no `pool-create`/`pool-write`/`pool-close` entry in `crossing-wraps` (only the
    arena's raw `mmap`/`mprotect`), so they are Python-oracle-only. Giving
    `pool-close` a native lowering therefore means designing the native `Pool`
    representation to carry its length beside the base address (the fat-cap shape
    the host tuple already has) — E107 work **shared with E111/E113**, not a
    fd-close-style one-line pair. The three fd-backed closes have no such
    dependency (`close` takes only the fd), so they land first; `pool-close`
    lands with the native pool binding.
  - **`env-close` lowering is deferred**, not designed away: `Env` has no OS
    release and no acquisition that lowers yet (`env-open` is interim/ambient).
    Decide at spec time whether to emit a no-op wrapper or leave it unpaired
    until `profile-hands-caps`.
- **Related:** [[E106-linear-cap-collection]] (the consumer — `sv-drain`); E105
  `write-fd`→`nb-sys-write` (`crossing-wraps.chiral:35` — the pair shape mirrored
  here); the ports bank / capability bank.
