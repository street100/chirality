---
node: view-implementation
layer: view
related: [perspectives, module-map, joining-law, modules-lowering, modules-staging, decision-backend, bootstrap-sequence, dump-integration, open-edges]
status: draft
updated: 2026-08-01
---

# View: implementation

The system read from the implementer seat: what must exist, what is borrowed,
what is novel, and in what order it has to come up. Everything here restates the
linked notes under one light, the way [[perspectives]] does per construct; on any
conflict the linked notes win.

## What must exist: the inventory

The [[module-map]] is the full build list. Three categories, three kinds of work.

Category A is mostly a borrowing problem. The core is a QTT checker kept tiny
(`kernel-expressed`, split by [[decision-split-checker]] into a spec plus a small
trusted core that re-checks untrusted producers' certificates), the one atom and
canonical IR (`process` / `core-ir`),
then the typed feature surface: `types`, `effects` (the port algebra),
`cost-typed`, `totality`, `syntax`, `reflect-typed`. See [[modules-core]]. The
blocking security properties live here too as proof properties: `information-flow`,
`taint`, `constant-time`, plus the proof halves of three forced splits,
`isolation-type`, `freshness-discipline`, `audit-mark`. See [[modules-security]].
Prior art covers most of this ground; the novelty budget in A is low by design.

Category B is what exists already, the metal. Nothing is built here; it is named
and quarantined: `raw-mem`, `device` / `dma`, `foreign`, `register-root`. Each is
packaged as an ordinary module whose type declares the untyped referent, per
[[decision-b-in-type]]. The work is discipline, keeping the set small and routed
through C. See [[modules-substrate]].

Category C is the novel work: custody ceremonies made cheap and
declarative. Custody: `custody-split`, `redundancy`, `datum-policy`
([[modules-custody]]). The runtime side: `broker` (component), `kernel-gate`,
`adhikara` ([[modules-broker]]). The bridges: `bridge-supervisor`, `attestation`,
`isolation-enforce`, `freshness-verify`, `audit-reconcile`, `runtime`,
`reflect-raw` ([[modules-bridges]]). This is where the design spends its
originality: new work, custody ceremonies made language features. See
[[category-bridge]].

## How it composes: four connectors

Modules connect only through the four typed connectors of the [[joining-law]],
each preserving one invariant: bridge (across typeability, verify inbound and
confine outbound), lowering (across altitude, the type held down to tal), staging
(across binding time, semantics preserved), port-composition (within a category,
the closed port set). For the implementer this is the integration contract: a
profile is modules plus connectors, and validity is three reused checks per
[[decision-profiles]]. Whether the four are complete is edge 13 in
[[open-edges]]; the staging connector still lacks a checkable preservation
statement, edge 12.

## The lowering path

The floor is `tal`, typed assembly, human writable, with its own A, B, C inside
it: typed instructions, raw unsafe instructions, guarded sequences. `translate` /
`lower` carries the upper core down through type preserving drops, and
`preserve-check` is the proof each drop opened no hole; its first customer is
`constant-time`. Erasure happens once, in a single trusted emission step below
tal that the programmer never edits. See [[modules-lowering]] and
[[axis-altitude]].

The backend is owned: lower the typed IR and use a codegen library for
instruction selection and register allocation only, never a round trip through C
source, which would be an untyped bottom. ATS is an existence proof for the
performance target, not a mechanism to copy. See [[decision-backend]].
`cheri-floor` is additive: where tagged capability hardware exists the B mark is
enforced in silicon; the type level mark holds without it.

## The bootstrap order

The [[bootstrap-sequence]] is the dependency order run once from the bottom.
First the register root: the master secret established in registers at boot,
never written to RAM, the base of all trust. Then the bootstrap floor: the
smallest set of tuned runtimes, each a staged compiler residual, cross-checked,
so the trusted base shrinks to the register root plus the agreement mechanism.
Then the cascade: each runtime is a compiler and stages further runtimes, spawn
is staging a residual live, processes touch only through ports. The endgoal is a
self hosting system that expresses its own kernel, compiler, and runtime (P1).
The roadmap (.planning/ROADMAP.md) reaches that through a host language scaffold
compiler that is later torn out. Nothing here is built yet.

## The named gaps

Five modules are needed and not yet designed, marked `gap` in [[module-map]]:
`stage` (the binding time spine, the biggest gap), `specialize` (partial
evaluation to residuals), `pregen` (seed to artifact, derive not store, required
by the secure datum model rather than optional), `link` / `load` (installing
generated code into a running process), and the auditor facing proof
presentation layer, edge 10. There is no `jit` module to build: it dissolves
into `stage` plus `tal`, one staged compiler invoked at a later stage. See
[[modules-staging]].

## Recorded, not decided

Three sequencing questions sit at the end of [[open-edges]], not committed. Two
are recorded from the dumps. Type system build order: refinement, then linear,
then capability, deferring dependent, region, subtype, effect. Blocking security
properties: the dumps say information flow, constant time, and taint block the
trusted base and the other five are incremental. The third was the first-backend
choice among LLVM, Cranelift, QBE — closed by reconciliation 2026-07-22
([[decision-backend]]: the built chirality Mach path supersedes; no codegen library
in the trusted path). The implementer inherits the remaining two as
recorded-not-decided, to settle, not as decisions already made.

## What blocks what

Only the roadmap states a blocking order, and it states little. Its stage 2 is
"resolve the load bearing open edges," the seams that block module design: the
cost gradient mechanism (edge 3), the reflective floor (edge 5), how far the
membrane reaches inward (edge 2), default tier selection (edge 4), and the non
process boundary (edge 1). It says to start with the cost gradient and the
reflective floor. The only hard block named anywhere is stage 3, the kernel,
"blocked on stage 2's cost gradient decision" (edge 3). Stage 5, the lowering
floor, "resolves the asm vocabulary open edge" (edge 6), so that edge closes as
lowering is built rather than gating it.

Beyond those, the notes state no ordering, so this view asserts none. The
remaining edges are owned by their notes: edge 14 (live port semantics) and edge
16 (alarm effect mechanism) are called type-system decisions by their owning
notes; edge 11 (bootstrap floor internals), edge 12 (the staging connector's
checkable preservation statement), edges 7 and 8 (the broker), edge 15 (device
class coverage), edges 9 and 18 (profiles and conformance), and the cross-node
edges 17, 19, and 20 are all open with no committed sequence. [[open-edges]] owns
them; none are resolved or ranked here.

## Honest scope limits

The secure datum model promises exponential attacker cost, not prevention:
software is not on the bus, so DMA cannot be prevented, only multiplied against.
Out of scope for the CPU and RAM only model, needing hardware honestly: CPU code
execution, cold boot capture of the working window, and the pre-IOMMU boot
window. The register-anchored counter clears on power loss, so rollback-proof
persistent monotonicity needs a TPM NVRAM counter, edge 20 in [[open-edges]] and
[[time-and-clocks]]. The model never assumes capability hardware: every guarantee
must hold on a commodity CPU, since CHERI-class machines are rare and will be
for a while. If one is ever in hand, its enforcement adds one more independent
multiplier on top; nothing in the model waits for it. And a backend now exists
(the chirality-emitted x86-64 path), with narrow measurements across four runs:
the bare emitter within 1.0–1.5× of gcc -O0; with its first optimization pass
(inline byte ops, const folding, immediates, Euclidean pow2 strength reduction,
tail-call elimination) ahead of -O0 outright, and with the trait-native tier
(transforms licensed by checker-proven facts: guard elision, totality-licensed
comptime, CSE, dense-tag tables, magic-multiply division) 1.4–8.4× behind
-O2 on three micro-kernels —
cross-side ratios only ([[decision-backend]],
`scaffold/bench/RESULTS-2026-08-01.md`, `scaffold/bench/TRAIT-OPTS.md`).
The dumps' own speedup multipliers remain fabricated — the benchmark did not test
them — and their LOC budgets are rejected outright as estimate theater for a
language that does not exist ([[dump-integration]]). See
[SECURE-DATUM-MODEL](../definitions/secure-datum-model.md).
