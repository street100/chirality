# Decision: Inspiration & Reading Policy

**Status:** settled 2026-07-06. Governs *what external material chirality may read
directly* when building its own implementation of each element in
`docs/elements/catalog.md`. This is Step 2 of the plan/audit arc.

## The governing question

Not "may we look at prior art" (of course) but: **for each element, does reading a
specific external *implementation's source* threaten chirality's provenance, TCB, or
identity — or is it required for conformance?** The answer sorts every element into
one of four tiers. The sort is driven by **identity/provenance first, license as a
hard floor** — for the metatheory we stay paper-led even when the license would
permit reading source, because the load-bearing claim is *"this checker is ours."*

## The four tiers

### Tier R — Required reading (conform exactly)
Interface contracts and our own code. Not reading them is the error. Bit-exact
conformance is the goal or the thing literally *is* our source.

- **All `SPEC`** — x86-64 ISA (Intel SDM), Linux syscall ABI + struct layouts
  (`pollfd`, `msghdr`/`cmsghdr` for SCM_RIGHTS), ELF + SysV gABI, Wayland wire,
  PNG, SMT-LIB div/mod (Boute Euclidean). Elements E19–E21, E24, E28–E37.
- **All `OURS`** — our Python (`sexp/surface/runtime/lower/optimize/tal.py`, the
  checker modules as *port source*). Elements E1–E2, E13–E17, E23, E25, E49.
- **musl (MIT)** as the canonical *"how to issue a Linux syscall"* reference —
  treat as SPEC-adjacent for E28–E33. It documents the ABI more legibly than the
  man pages in places; permissive license, mechanical content, no identity stake.

### Tier O — Oracle-only (observe behavior, never read source)
Use as a **differential / golden oracle**: run it, compare our output to its output,
build accept/reject corpora — but do **not** read its source. Clean-room-safe
*regardless of that tool's license*, because we consume behavior, not structure.

- **Z3 / CVC5** — oracle for the refinement decision procedure (E9): emit our
  constraints in SMT-LIB, check our `entails`/`is_empty` verdicts against theirs on
  a generated corpus. Never read the solver internals.
- **Agda / Idris2 / Lean / Rocq(Coq)** — oracle for *what ought to typecheck,
  terminate, or count as strictly positive* (E3–E8, E11, E47, E50). Curate a suite
  of programs with known accept/reject verdicts; do not read their kernels.

This tier is how we get the correctness leverage of mature tools without taking on
their provenance. It is the single most valuable move in the policy.

### Tier P — Paper-led, source-avoided (identity-bearing metatheory)
Read the **papers**; reimplement clean; **deliberately do not read** the canonical
implementation's source even when its license permits. This is where chirality's
identity lives — the checker must be ours by construction.

| Element | Read (paper) | Avoid (source) |
|---|---|---|
| E3 NbE | Abel; Coquand "NbE for MLTT" | Agda/pi-forall evaluators |
| E4 bidirectional | Dunfield–Krishnaswami | Idris2 elaborator |
| E5 QTT semiring/linearity | Atkey; McBride "Plenty o' Nuttin'" | Idris2 quantity checker |
| E7 strict positivity | Agda/Coq *papers* | their positivity checkers |
| E11 termination | foetus / size-change (Lee–Jones–Ben-Amram); Abel sized | Agda `.Termination` |
| E9 refinement domain | Liquid Types (Rondon/Jhala); interval/octagon | LiquidHaskell src |
| E10 occurrence typing | Typed Racket (Tobin-Hochstadt–Felleisen) | TR impl |
| E38 coeffects | Petricek/Orchard; graded modal | — |
| E39 effect algebra | Koka/Frank/Eff *papers* | their runtimes |
| E40 capabilities | object-capability literature | — |
| E41 regions | Tofte–Talpin region calculus | MLKit |

Rule of thumb: **an algorithm from a paper is an idea we may take; a kernel from a
repo is a structure we build ourselves.**

### Tier F — Free-to-read (permissive, mechanical, non-identity)
Substrate/mechanical elements with no identity stake and a permissive license — read
source freely, borrow structure, cite it.

- **dlmalloc** (public domain), bump/arena allocators — E22.
- **LLVM / Cooper–Torczon / Appel** for reg-alloc, DCE, SSA — E16–E17 (ideas).
- **Existing assemblers** (nasm tables, LLVM MC) for x86 encoding cross-checks — E19,
  as a *check* against the Intel SDM, which remains the authority.

## License floor (hard constraint, verify before relying)

Reading source is gated on license regardless of tier. Believed licenses (VERIFY —
ccbox egress is blocked, these are from memory): Agda MIT · Idris2 BSD-3 · Lean4
Apache-2.0 · **Rocq/Coq LGPL-2.1** · Z3 MIT · CVC5 BSD-3 · musl MIT · dlmalloc
public-domain · Wayland MIT · LLVM Apache-2.0-with-LLVM-exception. The one to note is
**Coq/Rocq is LGPL** — fine, since it sits in Tier O (oracle-only, we never read it).
**No GPL/AGPL source enters the reading set for any clean-room element.** If a
tempting reference is GPL, it drops to Tier O automatically.

## One-line summary per catalog element

- **R (read/conform):** E1, E2, E13–E21, E23–E25, E28–E37, E49.
- **O (oracle-only):** the *verification* of E3–E11, E47, E50 (behavioral corpora).
- **P (paper-led, source-avoided):** E3–E12, E22*, E26, E27, E38–E48, E50.
- **F (free-to-read):** E22 (allocator), E16–E17 (opt ideas), E19 (encoding checks).

(*E22 splits: region *types* are Tier P (Tofte–Talpin); the concrete bump/arena
allocator is Tier F (dlmalloc).)

## Why this shape

- Keeps the **TCB-shrink prize** (the checker, E1–E14) clean-room by construction —
  the thing we most want to be able to say is ours, is.
- Still gets **mature-tool correctness** via Tier O without a provenance cost.
- Doesn't waste purity on **substrate** (allocators, encoders) where conformance and
  permissive reuse are the honest, faster path — *compose, don't reinvent* applies
  exactly where identity isn't at stake.
- **Specs are always read** — conformance is not a clean-room concern.
