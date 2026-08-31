---
element: E51
slug: sys-linkage
title: "Sys-face linkage: upper-effectful chirality reaches syscalls through sys-tal, retiring impl_ports as the transport (the true self-host gate — F7/C1)"
kind: REPLACE-CRUTCH
reference_class: OURS
ours_source: scaffold/chirality/runtime.py (extern link + dispatch), scaffold/chirality/impl_ports.py (the crutch), scaffold/lib/sys-tal.chiral (the destination)
status: drafted
updated: 2026-07-22
---

# E51 — Sys-face linkage: upper-effectful chirality reaches syscalls *through* `sys-tal`

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E51, the binding seam that routes every effectful extern through
  the hand-tal sys library instead of a CPython callable — the last transport
  swap before "no Python in the run path."
- **Kind:** REPLACE-CRUTCH — the crutch is `impl_ports.py`: every port extern
  today resolves at link time to a Python function over the CPython stdlib.
- **Why chirality needs its own:** this is **the** self-host gate. The typed sys
  crossings already exist (`lib/sys-tal.chiral`: `write`(1), `read`(0),
  `lseek`(8), `ftruncate`(77), `memfd_create`(319), `mmap`(9), `munmap`(11) as
  hand-authored tal, differentially tested against real pipes and a
  self-mapped arena) — but they are only tal-machine/test-reachable. Upper
  effectful code cannot use them: its externs go to Python. Until this seam
  flips, every security property above the socket is discipline on CPython
  (trust-boundary). Sockets/poll/fd-passing/spawn/clock are still
  CPython-only crossings; delegation-map lane A (E28–E33) authors them as
  hand-tal, and this element is where they get *wired*.

## 2. Research

- **Reference class:** OURS — `runtime.py` (externs link to `IMPLS` at load;
  the staging story's link step in miniature; `MET_TAL=1` already executes
  lowered pure functions on the tal machine), `impl_ports.py` (the transport
  to retire), `lib/sys-tal.chiral` + `tal.py` (`TalFn.sysface` mark; the
  backend refuses the `sys` instruction outside the deliberate sys library).
- **Key findings:**
  1. The seam is *one dispatch decision*: when an applied extern has a
     binding, today the runtime calls Python; after E51 it executes a tal
     function (reference machine or native) and Python is not in the path.
  2. `bridge.verify` already sits at the crossing (every host-returned value
     is checked against the extern's declared type); the linkage re-seats the
     same check on the sys-tal return — the membrane stays, the transport
     changes.
  3. Confinement today is the `sysface` mark plus no-surface-path; when the
     effect row (E39, `decision-effect-facets`) lands, the row *names* each
     crossing, and its tal shadow (E70 — named here, not designed here) is
     what lets lowered effectful code carry the claim to the floor.
  4. Linux returns `-errno` in the syscall register: the C-bridge wrapper is
     where errno stops being ambient global state and becomes a constructor
     in a result sum.

## 3. Conventional (other-language) approach

How this is done outside chirality — today's Python transport, which is also the
shape of every libc wrapper:

```python
# impl_ports.py — the crutch. The extern's implementation is a Python
# callable over the CPython stdlib; authority is ambient (anything that can
# import os can make this call), errors are exceptions or a global errno.
def _pool_write(n, pool, off, bs):
    os.pwrite(pool.fd, bs, off)      # CPython -> libc -> syscall
    return pool                      # authority handed back by convention
IMPLS["pool-write"] = _pool_write
```

- **Assumptions it bakes in:** ambient authority (no capability needed to
  reach the syscall surface); errno as out-of-band global state; exceptions
  as the error path (invisible in any signature); the transport itself is
  unchecked Python — a lying impl is caught only at the inbound tag check;
  and the reachable syscall surface is "whatever the stdlib wraps," not a
  frozen typed set.

## 4. The chirality idea

- **Chirality features in play:** ports & linear quantities (possession), the
  effect membrane `=>` (exercise — the row after E39), categories (the
  linkage is a C bridge: typed module, untyped syscall referent), result
  sums for errors, the sysface confinement mark at the tal floor.
- **The reframing:** the extern declaration *already* owns the seam — its
  type is the contract. E51 changes only what stands behind it: a **binding
  table, itself chirality data**, mapping each effectful extern to the sys-tal
  crossing that carries it, plus a thin C-bridge wrapper per crossing that
  marshals port atoms and byte cells into the tal calling convention and
  turns the raw `-errno` return into a typed sum. Link-at-load walks the
  table; dispatch executes the tal function. The Python callable is gone
  from the path — first on the reference machine (which performs the same
  real syscall through one audited shuttle), then natively.
- **What chirality makes impossible here:** reaching a syscall without holding
  the port it is typed over; errno as ambient state; an error path absent
  from the signature; and — once the table is the only transport — a
  Python-level actor forging or wrapping a crossing, because there is no
  Python level.

## 5. Chirality example (fleshed)

> **Correction (2026-07-27, spec-audit follow-through).** This skeleton was
> drafted against a false premise: `fd-write`/`fd-read`/`fd-seek` are declared
> **nowhere** in the typed face — the face's write path is the pool family,
> its stream path is sockets, and stdout/stderr are the ambient writers
> (`put`/`print`/`trace`). The fd-level face is a phantom, not a gap (SPEC
> Decision 5, resolved by the author: the face stays frozen). Read `WriteR`/
> `wrap-write` and the `fd-write`/`fd-read`/`fd-seek` table rows below as the
> wrapper/table *shape* — which stands, and which the lane-A fd-taking
> wrappers will follow — not as bindable names. The SPEC's step 2 carries the
> real v1 bound set (`put`/`print`/`trace` over `nb-sys-write`).

```chirality
; ---- lib/sys-linkage.chiral (copy-and-modify skeleton) ----
(import "prelude")
(import "sys-tal")        ; the hand-tal crossings: nb-sys-write, nb-sys-read, ...

; Errors are values: the errno world becomes a constructor. One result sum
; per crossing family; the linear port always comes back (or is consumed by
; close) so alarm paths can discharge what they hold.
(data WriteR ()
  (write-r  (n I64) (1 f Fd))          ; n bytes written, authority moved back
  (write-err (errno I64) (1 f Fd)))    ; typed errno, port still yours to close

; The typed face is unchanged (lib/ports.chiral owns it):
;   (extern fd-write (=> (1 f Fd) Bytes WriteR))

; The C-bridge wrapper the table points at. sysface-marked territory: only
; here may a port atom be viewed as its raw integer (fd-view), and only here
; does the raw return get folded into the sum. Linux: ret < 0 is -errno.
;
; The view must THREAD the port back — QTT has no borrowing, so a view that
; merely "reads" the atom would consume it (audit 2026-07-22: an earlier
; draft double-used the linear f — viewing and then returning it — which is
; untypeable; the result-shape threading below is forced, same pattern as
; RecvR).
(data FdView () (fd-view-r (raw I64) (1 f Fd)))
; (extern fd-view (=> (1 f Fd) FdView))  ; sysface-only mint -- open question (1)

(def wrap-write (=> (1 f Fd) Bytes WriteR)
  (lam (f bs)
    (case (fd-view f)
      ((fd-view-r raw f2)
       (let ((ret (nb-sys-write raw bs)))     ; sys-tal crossing
         (if (<i ret 0)
             (write-err (- 0 ret) f2)
             (write-r ret f2)))))))

; The linkage table — the artifact that RETIRES impl_ports.py as transport.
; Link-at-load walks this; an extern bound here never touches Python.
; During the migration window an unbound extern falls back to the host impl;
; when lane A (E28–E33) completes the bank, an unbound effectful extern is a
; LINK ERROR, not a Python call.
(data SysBinding ()
  (bind-sys (extern-name Str) (wrapper Str)))

(def sys-bindings (List SysBinding)
  (cons (bind-sys "fd-write"     "wrap-write")
  (cons (bind-sys "fd-read"      "wrap-read")
  (cons (bind-sys "fd-seek"      "wrap-seek")
  (cons (bind-sys "pool-create"  "wrap-memfd-sized")   ; memfd+ftruncate+mmap
  (cons (bind-sys "fd-close"     "wrap-close")         ; lane A, E28
  ; ... sockets / poll / fd-passing / spawn arrive from lane A (E29-E33)
  nil))))))

; A use site is UNCHANGED — that is the point. The membrane holds; only the
; floor beneath the crossing moved:
(def log-line (=> (1 f Fd) Str WriteR)
  (lam (f s) (wrap-write f (str->bytes s))))
```

- **Knobs to modify:** the result-sum granularity (per-family sums as here vs
  one `SysR`); which crossings are in the table (grows with lane A); the
  migration-window fallback (host-impl vs hard link error).
- **Deliberately omitted:** the row's tal-shadow representation (E70 designs
  it); the dispatch refactor internals in `runtime.py` (implementation run);
  socket/poll/spawn wrappers (their hand-tal doesn't exist yet — lane A).

## 6. Use / modify notes

- **Lands in:** `lib/sys-linkage.chiral` (table + wrappers) plus a REFACTOR-L
  of `runtime.py` dispatch (the applied-extern branch consults the table and
  executes the tal function; `impl_ports.py` demoted to migration fallback,
  then deleted).
- **Conformance target:** differential — every linked crossing must produce
  byte-identical observables to the `impl_ports` path across the existing
  suite (both ultimately hit the same kernel; the reference tal machine
  already performs the real syscall), and `verify`'s frozen-port-set check
  must see the same crossing names before and after.
- **Open questions:** (1) the **`fd-view` privilege** — which layer may open
  a port atom to its raw integer: it must be exactly the sysface-marked
  bridge and inexpressible elsewhere, or the atom's opacity is decorative;
  (2) errno taxonomy — one shared sum vs per-family, and which errnos are
  alarms (counter-effect) vs ordinary values; (3) whether `bridge.verify`
  re-checks on the sys-tal return path at the same depth as it does for host
  impls; (4) the exact row⇄sysface correspondence once E39's row shape lands
  (E70's opening design question).
- **Related:** [[E39-effect-row]] (the row that names crossings),
  [[E70]] (effectful lowering — the row's tal shadow), [[E28-mmap-crossings]]
  [[E29-sockets]] [[E33-process-spawn]] (lane A crossings this table will
  bind), [[E20-loader]]/[[E34]] (the loader/ELF endgame that removes the
  remaining Python shuttle), [[E21-arena]] (the first self-hosted crossing
  chain this linkage generalizes).
