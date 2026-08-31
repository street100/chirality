---
node: certificate-discipline
layer: foundation
related: [testing-floors, decision-split-checker, decision-bridge-elaborator, split-role, modules-lowering, joining-law, category-bridge, thesis, open-edges]
status: draft
updated: 2026-07-21
---

# Certificate discipline: trusted checker, untrusted producers

The general form of "a socket that checks whatever plugs into it." A small trusted
checker plus arbitrarily many untrusted producers that emit re-checkable
certificates. Trust concentrates in the small checker and a fixed demanded
statement; everything that produces churns freely and is trusted for nothing. This
is the LCF architecture and the de Bruijn criterion, and it is chirality's house pattern,
already used in `preserve-check` ([[modules-lowering]]) and the certificate-keyed
amortization of checking.

## Show your work, do not spot-check

The distinction that makes the check ungameable:

- A **test** says "I ran some examples and both sides agreed." Vacuous examples pass,
  so it checks nothing meaningful. Gameable.
- A **certificate** says "here is my derivation, re-run it." The producer must show
  the actual steps, and the checker re-runs them against fixed rules, accepting only
  steps that genuinely follow. You cannot hand it fake work.

So the check is re-derivation, not comparison. This is why the split-checker
([[decision-split-checker]]) uses certificates for the provable core rather than a
quorum of test-agreeing implementations.

## The one residual vacuity, and how it is pinned

A certificate can be a real proof of a **weak** statement: an airtight derivation of
"this term has *some* type" when what was needed was "this term has *the* type it
claims." The work is real, the statement empty. This is the certificate-world version
of a vacuous test, and it is the only place vacuity survives.

It is pinned by two moves:

1. **The producer does not choose what it proves.** The demanded statement is fixed at
   the socket, part of the small audited spec, not selected per plugin. Vacuity then
   lives in exactly one place: is the demanded statement itself meaningful. That is one
   small thing audited once, not a per-plugin worry.
2. **Tie the demanded statement to what the consumer structurally needs.** If downstream
   can only consume the artifact through a typed interface that demands the real
   property, a weak statement visibly breaks consumers. The evidence is not a badge, it
   is the thing you must present to cross ([[category-bridge]] outbound/inbound; P1).

## Relation to the bridge elaborator

The bridge ([[decision-bridge-elaborator]]) is the general socket; certificate
discipline is what makes its check non-gameable (re-run, not test) and its demanded
property meaningful (fixed at the interface). The bridge-preserve-check owed by
open-edge 12 is exactly the generic re-checker for the bridge's fixed statement.

## Tiering

Certificate strength is itself tiered (P5, [[split-role]]): a machine-checked proof is
stronger than a `preserve-check` re-derivation, which is stronger than a signature over
a prior check reused by content hash ([[insp-unison]]). Pick the tier the property
warrants and the resources allow, and name it, so a reused-signature is never mistaken
for a fresh proof.

## Elements, and the interactions between them

chirality proves elements, and it proves their *interactions* too, wherever the
interaction is provable, which is often because most compositions in chirality are
type-level. The discipline is default-attempt: when a goal composes two concepts
that have not been proven together (which happens constantly), you try to prove the
composition, and skip only when you know you cannot. Hard-bound type elaboration
composed with a dozen other type-level concerns is provable and gets proven; a
hardware or DMA interaction is not and gets best-guessed as evidence ([[split-role]]).
The joining-law's preserving connectors *are* these interaction proofs, and
`preserve-check` is the flagship: a proof that one specific composition opened no
hole ([[joining-law]], [[modules-lowering]]). This is not optional where it is
available: individually-sound features can be jointly unsound (Girard: impredicativity
plus large elimination plus proof-irrelevance), which is exactly why a composition of
two not-yet-proven-together concepts earns a proof attempt, not a shrug.

What chirality does not do is prove the whole system as a monolith, and not because
composition is unprovable. It does not need a monolith: trust is composed from
element proofs, plus interaction proofs at every seam that admits one, plus evidence
at the genuinely-unprovable physical seams (hardware, DMA, foreign). "Prove all of
chirality" is the proof-theoretic form of proving all of a brain, neither the goal nor
possible. The provability boundary runs through interactions the same way it runs
through elements: a type-level composition is proven, a physical one is best-guessed.
Open-edge 18 tracks the sub-question of which interaction proofs are cheap (subtyping)
and which need a dedicated argument.

## The boundary with agreement

Certificate discipline works only where the property is *provable*. Where it is not —
the genuinely-unprovable substrate, hardware, foreign devices, solvers that emit no
proof — you fall back to agreement across independent sources ([[split-role]]). The
boundary between the two tools is provability, and the design's job is to push as much
as possible into certificate land, where the check cannot be gamed, and shrink
agreement land to the irreducible physical residue.
