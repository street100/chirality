---
node: splitting-law
layer: foundation
refines: [axis-typeability]
related: [joining-law, module-map, decision-brokers, modules-security, category-bridge]
status: draft
updated: 2026-07-21
---

# The splitting law

The rule that decides where one module ends and the next begins.

## Statement

A module that appears in two typeability categories is under split. Cut it until
each piece is monochromatic: each piece sits in exactly one of A, B, C.

A split is real if and only if the two halves have different types, meaning
different effect, cost, or tier weight. If the two halves have the same type
shape, the split is spurious and adds only overhead. So the law has a floor and
a ceiling, both taken from P2: split where the type differs, stop where it does
not.

Stated as one line: overlap on the typeability axis means a split is missing;
identical type shape means a split is spurious.

## Why it follows from the principles

P2 says everything is a process and the type is the process. Two forms with
different types are therefore different processes, which means different modules.
The same noun can name two of them. They share the noun and nothing else.

## The twin pattern

Once overlap is forbidden, the map reorganizes by modality rather than topic. A
governance concept tends to appear twice: a proof twin in A and an evidence twin
in C. Sometimes a bare referent in B as well.

- ports: `effects` in A, `kernel-gate` in C
- cost: `cost-typed` in A, metered cost inside `runtime` in C
- custody: the T0 case is a linear value in `types` (proof), `custody-split` in C
  (T1, T3). The A twin is not its own module; a dedicated `custody-singleton`
  would be a spurious split, since its type shape is an ordinary linear value.
- reflection: `reflect-typed` in A, `reflect-raw` in C
- kernel: `kernel-expressed` in A, `kernel-gate` in C, and the bootstrap floor
  governed as a C set of cross-checked tuned runtimes rather than a bare B
  referent. `kernel-expressed` is split again by [[decision-split-checker]] into a
  spec plus a small trusted core that re-checks untrusted producers' certificates
  (the checker is provable, so it is held by certificate, not agreement). See
  [[joining-law]], [[certificate-discipline]], and [[module-map]].

The A twin is the type as proof. The C twin is the enforcement or the evidence
for the case where proof is absent or must be checked against reality. The B
referent is the bare substrate.

## Worked splits

These are recorded where they apply:

- The broker name carried two modules. See [[decision-brokers]] and
  [[modules-broker]].
- Three security modules each carried a proof half and an evidence half. See
  [[modules-security]]: isolation, anti replay, audit.
- integer safety did not split. It has the same type shape as refinement, so it
  folds in rather than standing alone. See [[modules-security]].

## The dual

Cutting is half the theory. How the cut modules reconnect is the [[joining-law]]:
modules join only through a typed connector that preserves the invariant the
split exposed, and there are four. The twin pairs this law produces are rejoined
there.
