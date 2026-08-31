---
node: modules-security
layer: module
implements: [category-typed]
related: [module-map, modules-custody, modules-lowering, splitting-law, dump-integration]
status: draft
updated: 2026-07-25
---

# Security modules

> **Status: DESIGNED.** None of the blocking trio (information-flow, taint,
> constant-time) or the split modules is in the scaffold. This note describes
> intended structure, in the present tense of the finished system. See
> [[status-ledger]].

The dumps framed security as a second core of eight modules. The audit corrects
that. Most of those eight are more category A typed properties, not a separate
core. The genuinely separate core is [[category-bridge|C]], which the dumps
barely touch. So these notes split into a typed group here and an evidence group
in [[modules-bridges]] and [[modules-custody]].

## The blocking trio, all typed (A)

These three are proof properties, woven per datum by `datum-policy` in
[[modules-custody]] but themselves living in A.

- information-flow. A secrecy lattice with declassification. Non interference is
  a typed proof, not evidence. These are **two things, not one** ([[open-edges]]
  edge 2, shaped 2026-07-25): the **secrecy lattice is the grade** — info-flow's
  reserved coeffect factor in the graded kernel's product semiring
  ([[decision-graded-kernel]] point 1), a per-value level joined by lattice-join at
  seams (class 1); **non-interference is the whole-assembly property** over it
  (class 2 / global, each module preserving level-monotonicity so the composite
  does), the same grade-vs-property split the kernel already made for totality.
- taint. The inverse: trusted and untrusted tracking with sanitizer transitions.
- constant-time. Verified at lowering, by checking for data dependent branches
  and memory access. This one is lower stratum, and it is the first concrete
  customer of `preserve-check` in [[modules-lowering]]. It does not solve the
  microarchitectural channels; it is the partial, checkable part.

## The forced splits

The splitting law cut three dump modules, each into a proof half here and an
evidence half elsewhere. See [[splitting-law]].

- isolation. `isolation-type` (A) is the compile time domain or label proof.
  `isolation-enforce` (C) is the runtime compartment over foreign code, in
  [[modules-bridges]].
- anti replay. `freshness-discipline` (A) is the linear use once token.
  `freshness-verify` (C) reconciles against an external clock or counter, in
  [[modules-bridges]].
- audit. `audit-mark` (A) is the obligation as an effect. `audit-reconcile` (C)
  checks the write once trail against live state, in [[modules-bridges]].

## The non split

integer safety does not become its own module. It has the same type shape as
refinement (numeric predicates), so by the splitting law it folds into `types`
rather than standing alone. Keeping it separate would be spurious. See
[[modules-core]].

## Deferred

The dumps mark isolation, attestation, anti replay, integer safety, and audit as
incremental rather than blocking. Only information flow, constant time, and taint
are blocking for the trusted base. That sequencing is recorded, not yet
committed; see [[open-edges]].
