---
element: E33
slug: process-spawn
title: Process model: `spawn` (socketpair + `fork`/`execve`/`clone`)
kind: REPLACE-CRUTCH
reference_class: SPEC
ours_source: (none)
status: drafted
updated: 2026-07-13
---

# E33 — Process model: `spawn` (socketpair + `fork`/`execve`/`clone`)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E33, spawning a child process connected to us by a bidirectional
  byte channel — `socketpair` → `fork`/`clone` → child-side `dup2`+`execve`,
  parent-side single return of `(pid, sock)`, and a `waitpid` reap.
- **Kind:** REPLACE-CRUTCH — today this is CPython's `subprocess` +
  `socket.socketpair()`, an untyped convenience the runtime must shed.
- **Why chirality needs its own:** the process model is where every agentic use of
  chirality lives (drive a worker, run a filter, talk to a tool over a channel),
  and it is the single worst-behaved corner of POSIX — a call that returns
  twice, a call that on success never returns, and an obligation (`waitpid`)
  that the OS enforces only by leaking zombies. Chirality wants all three shaped
  into a typed, single-return, capability-gated `spawn` with a linear reap
  obligation, keeping the fork-returns-twice weirdness inside one Category B
  primitive.

## 2. Research

- **Reference class:** SPEC — the `clone(2)`/`fork(2)`, `execve(2)`,
  `socketpair(2)`, and `wait4`/`waitpid(2)` Linux ABI (no OURS Python; design
  from spec).
- **Key findings:**
  1. `socketpair(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0, sv)` yields two
     connected, bidirectional fds. `SOCK_CLOEXEC` at creation (not a later
     `fcntl`) is what closes the classic fd-leak race: any *other* concurrent
     exec cannot inherit our pair; the child end we *do* want inherited gets
     `dup2`'d to fds 0/1, and `dup2` clears close-on-exec on the copy.
  2. `fork`/`clone` returns **twice** — 0 in the child, the child's pid (> 0)
     in the parent, −1/errno on failure. Everything between fork and `execve`
     in the child runs in a copied address space and must be async-signal-safe
     shaped: `dup2`, `close`, `execve`, `_exit(127)` only.
  3. `execve(path, argv, envp)` takes NUL-terminated string arrays and on
     success **does not return**; failure is only visible in the child, so the
     conventional protocol reports it as exit code 127 (or writes errno back
     over a CLOEXEC pipe). Strings with interior NUL bytes are unrepresentable
     in argv — that's a *precondition*, checkable before any syscall.
  4. Every child must be reaped **exactly once**: no `waitpid` → zombie;
     a second `waitpid` on the same pid → `ECHILD` (or worse, reaps an
     unrelated recycled pid). The status word decodes as exited(0–255) vs
     signaled(1–63).

## 3. Conventional (other-language) approach

CPython: `socketpair` + `subprocess.Popen` gluing the untyped pieces.

```python
import socket, subprocess

parent, child = socket.socketpair()          # AF_UNIX SOCK_STREAM pair
p = subprocess.Popen(argv, stdin=child, stdout=child)
child.close()                                 # drop our copy of the child end
parent.sendall(payload)
reply = parent.recv(65536)                    # hope it's all there
code = p.wait()                               # easy to forget → zombie
```

- **Assumptions it bakes in:** ambient authority (any code anywhere may spawn
  anything); untyped effects (`Popen` looks like any other call); the reap is
  a convention — forget `wait()` and you leak a zombie, call it twice and you
  get an exception at runtime; fd lifetime is manual (`child.close()` misplaced
  → the parent's `recv` hangs forever); argv validity (interior NUL) is checked
  by a runtime `ValueError`, not by the type of `argv`; `fork`'s double return
  and exec's no-return are hidden inside libc where nothing accounts for them.

## 4. The chirality idea

- **Chirality features in play:** ports/capabilities (spawn authority is a held
  `ProcPort` grant, not ambient); QTT linearity (`1` on the reap obligation and
  the socket); the `->`/`=>` membrane (argv validation is pure, only the spawn
  itself is a process arrow); errors as result sums; refinement (`pid > 0`,
  exit code in `[0,256)`, signal in `(0,64)`); Categories B/C (raw
  fork/exec is untyped substrate; the typed spawn is a bridge over it).
- **The reframing:** the four-syscall dance collapses into **one** typed,
  single-return primitive. `raw-spawn` (Category B) is the only place in the
  system where control flow forks; above the bridge, `spawn` is an ordinary
  process function from a capability + argv to a `SpawnRes`. A live child is a
  linear pair — a `Reap` token (the waitpid obligation) and a linear `Sock`
  (our end of the pair) — so the OS-level protocol "close your end, talk, then
  reap exactly once" becomes usage-checking, not discipline. `execve`'s
  in-the-child failure surfaces as an ordinary `se-noexec errno` value.
- **What chirality makes impossible here:** spawning without a `ProcPort` (no
  ambient authority — a `->` function provably cannot fork); forgetting
  `waitpid` (dropping a linear `Reap` is a type error — zombies are
  untypeable); double-reaping (reusing the consumed `Reap`); using the socket
  after close or leaking it; passing argv containing interior NUL to the seam
  (rejected by the pure validator before any syscall runs).

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
(import "prelude")

; ---------- errors are values -------------------------------------------
(data SpawnErr ()
  (se-nomem  (errno I64))     ; socketpair/clone limit hit (EMFILE/EAGAIN/...)
  (se-noexec (errno I64))     ; execve failed in the child (ENOENT/EACCES/...)
  (se-badargv))               ; interior NUL in argv — caught BEFORE any syscall

; a live child = a reap obligation + our end of the socketpair, both linear
(data Reap ()
  (reap (pid (refine I64 (> 0)))))          ; kernel pid, proven positive

(data Child ()
  (child (1 r Reap) (1 io Sock)))

(data SpawnRes ()
  (sp-ok  (1 c Child))
  (sp-err (e SpawnErr)))

; waitpid's status word, decoded — no raw ints escape
(data ExitStatus ()
  (exited   (code (refine I64 (>= 0) (< 256))))
  (signaled (sig  (refine I64 (> 0)  (< 64)))))

; ---------- Category B substrate (the ONLY fork-returns-twice site) ------
; raw-spawn: socketpair(AF_UNIX, SOCK_STREAM|SOCK_CLOEXEC)
;   -> clone -> child: dup2(sv[1],0), dup2(sv[1],1), execve, _exit(127)
;   -> parent: close(sv[1]); SINGLE return of (pid, sv[0]) or an errno.
; `pkt` is the pre-marshalled argv/envp block (NUL-framed, validated below).
(declare raw-spawn (=> (cap ProcPort) Bytes SpawnRes))

; ---------- pure edge: validate + marshal argv BEFORE the membrane -------
(declare argv->pkt (-> (List Str) (Option Bytes)))   ; none iff interior NUL
(def argv->pkt
  (lam (argv)
    ; … fold argv: str->bytes each, scan for 0x00, frame with NUL terminators …
    none))

; ---------- Category C bridge: the typed, single-return spawn ------------
(declare spawn (=> (cap ProcPort) (List Str) SpawnRes))
(def spawn
  (lam (cap argv)
    (case (argv->pkt argv)
      (none       (sp-err se-badargv))     ; rejected pre-syscall
      ((some pkt) (raw-spawn cap pkt)))))

; reaping CONSUMES the obligation: forgetting waitpid or calling it twice
; is a usage error the checker rejects.
(declare wait (=> (1 r Reap) ExitStatus))

; ---------- worked use: run a filter child over the channel --------------
(declare sock-send-close-w (=> (1 s Sock) Bytes Sock)) ; send + shutdown(WR)
(declare sock-drain        (=> (1 s Sock) Bytes))      ; read to EOF, close

(declare run-filter (=> (cap ProcPort) (List Str) Bytes (Option Bytes)))
(def run-filter
  (lam (cap argv input)
    (case (spawn cap argv)
      ((sp-err e) none)
      ((sp-ok c)
        (case c
          ((child r io)
            (let ((io2 (sock-send-close-w io input))  ; linear: io consumed
                  (out (sock-drain io2))              ; linear: io2 consumed
                  (st  (wait r)))                     ; linear: r consumed
              (case st
                ((exited code) (if (=i code 0) (some out) none))
                ((signaled sg) none)))))))))
```

- **Knobs to modify:** the fd wiring in `raw-spawn` (0/1 only vs adding fd 2;
  or a second pair for stderr → a second linear `Sock` field on `Child`);
  envp policy (empty by default — add a validated `(List Str)` env parameter);
  make `ProcPort` linear (`(1 cap ProcPort)`) for one-shot spawn grants, with
  `spawn` returning the port alongside the result; a timeout knob by pairing
  `wait` with the E31-style poll element.
- **Deliberately omitted:** the byte-level argv framing loop in `argv->pkt`
  (mechanical); non-blocking I/O and partial reads on the socket (E31's
  territory); `WUNTRACED`/job-control states in `ExitStatus`; signal
  forwarding/kill (a separate capability); the raw `clone` flags word.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/proc.chiral` (the typed bridge + `Child`/`Reap`
  types), with `raw-spawn` joining the Category B syscall substrate next to
  the wire/socket primitives.
- **Conformance target:** golden behavior of the CPython
  `socketpair`+`Popen`+`wait` triple — `run-filter cap ["cat"] b"x"` returns
  `some b"x"` with the child reaped (no zombie in the process table);
  `spawn cap ["/nonexistent"]` yields `se-noexec`/exit-127, not a hang;
  an argv element containing `0x00` yields `se-badargv` with **zero** syscalls
  issued.
- **Open questions:** how `raw-spawn` reports child-side `execve` failure —
  exit code 127 convention vs the errno-over-CLOEXEC-pipe protocol (the latter
  distinguishes `se-noexec` from a program that itself exits 127; costs one
  more fd pair in the B primitive); `clone` vs plain `fork` flags on the
  chirality runtime (vfork-style `CLONE_VM|CLONE_VFORK` is faster but constrains
  the child-side code even harder); whether `Reap` should carry a phantom
  brand tying it to the `ProcPort` that minted it.
- **Related:** [[E31-poll-select]] (waiting on the child socket without
  blocking), [[E32-clock-exit-env]] (envp construction, `_exit` at the seam),
  [[E29]] wire/socket primitives that `Sock` reuses, [[E34]] — an AOT-emitted
  ELF is exactly what `execve` here would launch.
