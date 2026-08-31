---
node: modules-core
layer: module
implements: [category-typed]
related: [module-map, modules-lowering, modules-staging, modules-security]
status: draft
updated: 2026-07-26
---

# Core typed modules

> **Status: mixed.** The kernel judgment and QTT quantities (0/1/ω) are ENFORCED
> and tal/lowering are IMPLEMENTED, but cost-typed (grades beyond 0/1/ω), full
> totality (functions, not just data), and reflect-typed are DESIGNED. See
> [[status-ledger]] per claim.

The category A backbone: the calculus, the type system, and the surface. All of
this is preserved downward to the typed assembly floor (see [[axis-altitude]]).

## kernel

A small trusted core, not a kernel in the OS sense. A small checker over a
single canonical term language, built on Quantitative Type Theory. QTT carries
linearity, dependency, and erasure in one calculus, which makes it the concrete
mechanism for P2 (everything is a process with a typed cost). The 0 quantity
binding lines up with the erased, proof only T0 case. Keep it small; everything
else is elaboration that it checks. Provenance: dump A9, A10.

The checker cannot prove *itself* (circular) but can be proven against an external
spec, so it splits by the LCF / de Bruijn discipline: `kernel-spec` (the type theory
as a small human-audited requirement type), `kernel-core` (one small trusted,
climbing-to-verified derivation checker), and arbitrarily many untrusted producers
(elaboration, optimizers, solvers via proofs, staging) that emit certificates the
core re-checks. Trust concentrates in the small core; the evolving bulk is trusted
for nothing. Agreement across independent sources is reserved for the genuinely
unprovable residue, not the checker. See [[decision-split-checker]] and
[[certificate-discipline]].

## process and core-ir

The one atom and the canonical IR. A function, a value, a statement, a
declaration are special cases of process, not separate kinds. The canonical
representation is the single source of truth; every surface is a rendering of it
(dump A12). The atom is self-similar: run a configuration of processes and it is
itself a process, a runtime. See [[process-and-runtime]].

## types

The typed feature surface, all folded under one module rather than scattered:
linear and refinement (which absorbs integer safety, since it has the same type
shape), with dependent, region, and subtype deferred to later slices. Build
order from the dumps: refinement, then linear, then capability. Capability as a
type is the typed face of P3; its runtime counterpart is `kernel-gate` in
[[modules-broker]].

## effects and cost-typed

`effects` is the port algebra: the finite, named effect and capability set (P3).
It includes alarm effects and the counter effects that answer them: a detected
divergence is raised as an effect and a counter effect responds. See
[[error-and-alarm]]. `cost-typed` is graded time, space, and termination on the
membrane (P2, P4).
Cost is an over approximate bound, not an exact predictor, because exact cost is
undecidable. That choice is recorded in [[open-edges]]. Time as a resource spent is
one of the three senses of time; see [[time-and-clocks]].

## totality

Total by default. Partiality is the marked, opt in climb (P5). The default is
provably terminating; unbounded recursion has to be requested. A divergence is
not non-termination; it is an alarm effect, a separate concern. See
[[error-and-alarm]].

## syntax

Surface forms. Function and value and declaration are sugar over process. The
surface also renders profiles, and that rendering is lossless: a surface may not
drop linearity, capabilities, or effects, or it becomes an ungoverned path (dump
A13). See [[decision-profiles]].

## reflect-typed

Staged metaprogramming over typed terms. Type preserving, total, a function from
typed term to typed term. Its untyped twin, `reflect-raw`, is a different module
in [[modules-bridges]]; the split is forced by [[splitting-law]].

Its auditor-facing use is the **proof-presentation layer** ([[open-edges]] edge 10
/ E46, shaped 2026-07-26): since the certificate *is* the elaborated term
([[certificate-discipline]]) and every surface is a rendering of the one canonical
representation (above), presenting a proof to a human auditor is a `reflect-typed`
traversal of the derivation into a structured surface (the Isar analogue) — one
general renderer, not per-proof; it adds no trust (it renders the already-checked
certificate) and names the tier ([[split-role]]) so the auditor sees where trust
rests. The novel residue is only the presentation surface itself.
