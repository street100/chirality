---
node: trust-boundary
layer: foundation
related: [status-ledger, floor-agreement, permission-model, axis-altitude, axis-typeability, bootstrap-sequence, modules-substrate, open-edges]
status: draft
updated: 2026-07-24
---

# Trust boundary

The design notes name the *target* trusted base: the register root, measured
boot, CHERI bounds, the bootstrap floor cross-checked down to the register root.
This note names the *current* one — what you actually have to trust to trust a
chirality program today. The two are far apart, and the distance is the honest
measure of what self-hosting still owes. [[status-ledger]] says which claims are
built; this says what the built ones rest on.

## The current TCB, by category

> **⚑ Update (2026-08-05, self-hosting fixpoint).** The **compile path** no
> longer trusts CPython: native chirality compiles chirality source to a runnable ELF
> end-to-end, and it compiles its own source to a byte-identical copy of itself
> (the fixpoint — [[status-ledger]]). So for *compilation*, the Python below has
> been discharged: what remains CPython-trusted is (a) the `check`/kernel +
> elaborator when run in the reference interpreter, (b) the test-suite oracle,
> and (c) the still-host-mediated syscall floor (Category B/C below). The paragraphs
> below describe the reference-interpreter TCB; the shipped native compiler's TCB
> is the emitted machine code + the Linux syscall surface it invokes, no CPython.

The three typeability categories ([[axis-typeability]]) each trust a different
piece of the host.

**Category A — pure typed compute.** The kernel judgment, the type checker, and
the elaborator are themselves *trusted Python*: a bug in `kernel.py` unsounds the
whole language, and it is CPython code, not chirality. Below them, `impl_pure`
inherits CPython's int/str/bytes semantics — the I64 two's-complement law is
re-imposed in Python (`wrap64`), not carried by a machine word. Category A trusts
**CPython the interpreter and the ~1000 lines of Python that are the checker and
its primitives.**

**Category B — the floor and its executors.** The reference interpreter
(`TalMachine`, the golden semantics of [[floor-agreement]]) is Python. The native
drop additionally trusts libc (`mprotect`, `syscall`), the `mmap` W^X mapping,
the ctypes FFI shuttle, and the CPU/OS. **The W^X loader itself is trusted
Python.** `bput` write-once is authored, not checked (a documented floor
assumption). Category B trusts **CPython, libc, mmap/mprotect, ctypes, and the
hardware.**

**Category C — the OS bridge.** The entire live effect surface is the Linux
syscall interface reached through CPython stdlib: AF_UNIX sockets, fd-passing via
SCM_RIGHTS, `memfd_create`/`ftruncate`/`mmap`, `select`, `subprocess` (for
`spawn`). The typed `sys` face exists in a hand-authored library but is not wired
to the live crossings. It now carries a **numeric allowlist** (`SYSCALL_TABLE`,
E76 2026-07-28): a `ti-sys` number must match its registered crossing and an
unregistered `sys` op is refused at tal-check, so the surface is closed by
default-deny at the chokepoint (`docs/decision-syscall-governance.md`) rather
than by naming discipline alone — though the rung-1 OS-level enforcement
(seccomp, E77) and the profile-permitted-subset gate are still owed. Category C
trusts **the full Linux syscall surface and the CPython
stdlib over it**, and in-sandbox is exercised only against protocol mocks — no
real-compositor proof.

## Where de-Python actually reached

De-Python has consumed the *pure-compute leaf* and the *code generator*: the pure
fragment (arithmetic, boxed data, Str/Bytes) runs as native x86-64 with no CPython
in the execution loop, and the emitter is chirality source, not Python. It has **not**
touched the *type theory above* (kernel, checker, elaborator — the parts that make
native output *sound*) nor the *OS bridge below* (Category C is ~0% de-Pythoned;
every live crossing runs through Python).

So the two ends that matter for trust — the judgment that says the code is safe,
and the syscalls that let it act — are exactly the two still borrowed. The middle
crossed first because it was the easy leaf. The consequence for self-hosting: the
Stage1==Stage2 fixpoint has not begun for the code that matters, and porting the
kernel is where the borrowed arithmetic, ordering, and encoding semantics — pinned
now on the host — will either hold or break the fixpoint.

## Discipline, not enforcement

The one sentence a security reviewer must hear first:

> **While chirality runs on CPython, its security properties are compile-time
> discipline, not runtime enforcement.**

The type labels are Python tuples. Linearity, port aliasing control,
revocation-by-consumption, the sysface confinement — all are properties the
*checker* proves and the *runtime honors*, but nothing enforces them against an
adversary at the Python level. A Python-level actor (a malicious import, a runtime
patch) can forge a "linear" port, fabricate a capability, mint a reference, or
call a syscall directly; the typed floor is irrelevant to code that never went
through it. The guarantees are real *for programs the chirality checker actually
checked, running in an unhostile Python*, and void otherwise. Today chirality is a
**trusted Python wrapper that enforces a typed discipline on the code it
compiles**, not a **secure typed runtime that enforces it against the world.**

## What converts discipline to enforcement

Both moves are already in the design:

1. **Self-hosting.** When the kernel, checker, elaborator, and the effect bridge
   are chirality on the typed floor — no CPython in the trusted base — a "linear" port
   is unforgeable because there is no untyped level at which to forge it (P1: a
   framework with a gap has an ungoverned path through the gap). The linear/affine
   discipline becomes *enforcement* the moment the whole reachable language is
   memory-safe with no forgery escape hatch. The reflective floor (edge 5) is the
   last such hatch and must be gated by a capability itself.
2. **The hardware substrate.** The register root (TRESOR-style key schedule in
   registers; [[bootstrap-sequence]], [[modules-substrate]]) and CHERI bounds move
   the final, physical guarantees off "the OS will not let it" onto silicon. On
   CHERI the type does not die at the trusted drop ([[axis-altitude]]); the
   capability is hardware-enforced.

Until both, state the guarantee as it is: enforced against a well-behaved program
by a trusted Python checker, and against an adversary by nothing yet.

## The two rungs

Those two moves are the two rungs of the self-host ladder
(`.planning/SELF-HOST-PLAN.md`), and they convert *different* roots — so the
honest security statement changes between them, but is not complete at rung 1:

- **Rung 1 — self-hosted on Linux.** Move 1 lands: kernel, checker, elaborator,
  and the effect bridge are chirality on the typed floor, so the **judgment and
  authority roots** become enforcement, not discipline — a linear port is
  unforgeable because there is no untyped level at which to forge it. But the
  **secret root stays degraded**: under a preemptive kernel we do not control
  there is no register custody (keys spill to RAM on a context switch), so secret
  custody is *OS-trusted*, not enforced. Rung 1 **completes ownership** — the
  authority path is fully chirality-typed and red-teamable.
- **Rung 2 — chirality-as-OS on metal.** Move 2 lands: the register root
  (TRESOR-style key schedule; [[bootstrap-sequence]], [[modules-substrate]]),
  critical sections, and CHERI bounds move the secret root and the physical
  guarantees off "the OS will not let it" onto silicon — the full
  [SECURE-DATUM-MODEL](../../SECURE-DATUM-MODEL.md) story. Rung 2 **completes
  sovereignty**.

So even a fully self-hosted rung-1 chirality must still state secret custody as
OS-trusted, not enforced; only rung 2 closes that gap. The ladder's home is
`SELF-HOST-PLAN.md`; this note carries its security reading (candidate C8).

## Relationship to the other trust notes

- [SECURE-DATUM-MODEL](../../SECURE-DATUM-MODEL.md) is the *threat model and target
  layer stack* — what the finished system defends against. This note is the
  *current* base, far below it.
- [[permission-model]] is the *design* of authority; its status banner records
  that only *Move* is built. This note is why even that is discipline, not
  enforcement, today.
- [[status-ledger]] gives the per-claim rungs and [[floor-agreement]] governs
  whether the floor's executors agree. Trust bottoms out where the three meet: a
  claim is trustworthy only if it is ENFORCED (ledger), its floors agree
  (floor-agreement), and its TCB (this note) is one you accept.

One line: **today the TCB is CPython plus the Linux syscall surface; self-hosting
onto the typed floor and the hardware substrate is what turns the language's
disciplines into enforcement.**
