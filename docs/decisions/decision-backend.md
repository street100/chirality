---
node: decision-backend
layer: decision
related: [modules-lowering, axis-altitude, modules-staging, dump-integration, floor-agreement, status-ledger]
status: settled
updated: 2026-08-01
---

# Decision: own typed backend, no compile to C

> **⚑ SCOPE CLARIFIED BY THE AUTHOR, 2026-08-23 — this fork is about the
> CANONICAL SHRED INSTANCE, not about chirality the language.** chirality admits any
> number of instances, and an *additive* one that emits C for external
> verification does not reverse this note: the canonical backend stays the own
> typed one (`mach-x64`, `asm-reloc`, no LLVM, no Cranelift, no C). The
> mechanism is already in place — `mach.chiral` is a 137-line record of backend
> operations and `mach-listing.chiral` is a second conforming `Mach` whose own
> header says it "exists to prove emit-core is genuinely target-independent".
> A C-emitting third target is that same seam used again. It was **E166**, and
> **it is now built** (2026-08-24): `mach-c.chiral` inhabits all 37 `Mach` fields,
> gcc compiles what it emits, and the resulting compiler is admitted by
> conformance and convicted by bit-identity — its purpose being the
> diverse-double-compilation leg (E53) that Python's retirement would otherwise
> leave with only one leg. The build **does not touch this fork**: the canonical
> instance still lowers through the typed assembly floor to `mach-x64`, and the
> C target exists only inside the verification leg. What this note still forbids,
> unchanged: the canonical instance compiling *through* C or depending on an
> external codegen library. See [[testing-floors]] and [[banks/verification]]
> Shard 8 for what the leg does and does not buy — disjoint provenance, not a
> smaller trusted base.

## The contradiction

The dumps cite ATS as proof that dependent and linear types can match or beat C
on performance. ATS gets that result by compiling to C. The same dumps reject
compiling to C as a primary target (dump D9). So the dumps want ATS's result
while disallowing ATS's mechanism.

## The decision

Implement it the way it is supposed to be. Lower through the typed assembly floor
and use LLVM or Cranelift as a codegen library from the typed IR, for instruction
selection and register allocation only *(mechanism superseded 2026-07-22 — see
the reconciliation below; the principle stands)*. Never round trip through C
source.

ATS is demoted from a mechanism to copy to an existence proof: it shows the
design space allows C competitive performance. Performance becomes a backend
engineering problem we own, not a result we borrow.

## Why this resolves it, and why it is forced

Compiling to C is an untyped bottom. It serializes the typed IR to untyped text
and hands it to a compiler that knows nothing about linearity, capabilities, or
effects, which reintroduces the thesis's gap at the floor: the exact hole the
language exists to close. So D9's rejection is not a preference; it is forced by
no untyped bottom (see [[axis-altitude]]).

The difference from using LLVM: you lower your own typed IR and use LLVM as a
backend library, you do not serialize to a source language that throws the types
away and re parses. Erasure happens once, in a single trusted emission step below
tal. See [[modules-lowering]].

## Principle basis

P1 and the no untyped bottom rule. A typed floor is incompatible with a backend
that requires an untyped intermediate.

## Reconciliation (2026-07-22): the mechanism is the built Mach path

The build superseded the named mechanism, and the reconciliation (DECISION-DOCKET
D2) lands on **supersede, not stopgap**: the backend is the chirality-authored Mach
path — `lib/emit-core.chiral` (target-independent codegen), `lib/mach.chiral` (the
target interface: base + heap + byte + sys + optimization faces), conforming machines
(`mach-x64`, `mach-listing`), `lib/asm-reloc.chiral` — with **no LLVM, Cranelift,
or QBE in the trusted path, now or later.** This serves the decision's own
principle better than its original mechanism sentence: a codegen library is a
large untyped foreign component below the floor, exactly where a gap is worst,
whereas the built emitter is typed chirality source whose output is differentially
validated against the reference ([[floor-agreement]]). A new hardware target is
a new conforming `Mach` value admitted under floor-agreement's rule (agree with
the reference before shipping), not a library choice. LLVM et al. remain
Tier-F/O cross-check references only (encoding oracles for E19, opt ideas for
E16–E17 — [[decision-inspiration-policy]]). The open-edges "first backend choice
among LLVM, Cranelift, QBE" is thereby closed: the first backend exists and is
ours. What this now claims about performance is measured, narrow, and dated
(2026-08-01, `scaffold/bench/RESULTS-2026-08-01.md`, seven runs): the bare
emitter landed within **1.0×–1.5× of gcc -O0** on three kernels; the same day,
a first optimization pass (inline byte ops; constant folding incl. comparisons;
immediate operands; Euclidean pow2 sar/and strength reduction; **tail-call
elimination**) moved all three kernels **ahead of gcc -O0 outright** (honestly read: TCO is
a structural transform -O0 never does); a same-day trait-native tier
(constant-divisor guard elision, totality-licensed total-call folding, CSE,
dense-tag lookup tables — transforms licensed by checker-proven facts,
`scaffold/bench/TRAIT-OPTS.md`) brought the whole-day native speedup to
2.6×–8.3× at equal load and the gap to **gcc -O2**, the honest optimized-C
reference, to **1.4× (compute-bound) – 8.4× (branch-bound)** from 4.4×–57× (magic-multiply division, 2026-08-02, closed the compute kernel to 1.37×). The remaining gap is attributed
kernel-by-kernel to the still-unbuilt passes (register allocation / slot
traffic on all three; control-dispatch jump tables for the branch kernel;
fused branches, tail calls, lookup tables, and magic division are landed —
the -O2 loops are disassembly-confirmed real and unvectorized, not folded). Only the cross-side
**ratios** are defensible — absolute ns swung 44–82% between runs on the same
guest, so they do not travel — and
the dumps' own speedup multipliers (2–5×, 0.9–1.1× C) remain fabricated: the
benchmark did not test them. Nothing in the emitter is tuned. E34 (ELF output)
and E20 (loader endgame) are the remaining path to a standalone artifact.

## Note

There is now a backend: the scaffold hand-emits real x86-64 from chirality
(`native.py`, `lib/mach-x64.chiral`) and the pure fragment runs as native machine
code. See [[dump-integration]] and [[status-ledger]].
