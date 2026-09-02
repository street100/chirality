---
node: decision-split-checker
layer: decision
related: [certificate-discipline, split-role, category-typed, category-untyped, decision-profiles, decision-bridge-elaborator, joining-law, splitting-law, module-map, modules-core, node-architecture, trust-boundary, open-edges, insp-unison, live-environment]
status: settled
updated: 2026-07-21
---

# Decision: the checker is a small trusted core plus untrusted producers

This note reverses its own earlier draft. An earlier version split the checker into
a *quorum* of N trusted-ish implementations reconciled by agreement. An adversarial
audit (2026-07-20, three rounds) showed that was the wrong tier for a provable
component. This is the corrected decision. The quorum is not gone, but it shrinks to
the genuinely-unprovable residue ([[split-role]]); the checker itself is not a
quorum.

## First, the word "kernel" here

"kernel" in chirality is not an OS kernel. It is a tiny category-A thing, the QTT term
representation plus the type checker, occupying the position a kernel occupies
without being one ([[node-architecture]]: "complete mediation with no mediator").

## The correction the audit forced

The earlier reasoning was: a checker cannot prove itself (circular, trusting-trust),
so it is B from its own vantage, so hold it as agreement-evidence (a quorum). The
false step is "cannot prove **itself**" silently upgraded to "cannot **be**
proven." A checker can be machine-verified against an external spec: CakeML, seL4,
and MetaCoq's verified typechecker are exactly this. Nothing in "B means unprovable
from inside" forbids *external* proof, and the design already accepts external human
audit of the spec as its anchor, so external mechanized proof of impl-against-spec is
the same move with a far stronger instrument. So the core judgment is *verifiable in
principle*, an element that admits proof, unlike the genuinely-unprovable physical
substrate. That is not a claim that it is verified today (see the tier note below),
and it is not a claim about proving "all of chirality": you prove the elements and the
interactions that admit proof and compose them ([[certificate-discipline]]), never
the monolith.

The audit's decisive line: the quorum was put one level too high. Redundancy is cheap
and genuinely independent at the *proof-checker* level (tiny, portable proof objects,
run N of them almost free) and expensive and correlation-prone at the *type-checker*
level.

## The decision

The checker splits by the de Bruijn / LCF criterion ([[certificate-discipline]]):

- **kernel-spec** — the type theory as a small, human-audited requirement type. The
  demanded statement everything is checked against.
- **kernel-core** — one small, trusted (climbing toward machine-verified) derivation
  checker: bidirectional QTT typing over core-ir, semiring grade accounting, NbE
  conversion including large elimination, positivity/coverage/structural-and-measure
  totality, plus the certificate/signature verifier. Trusted because small and
  spec-directed, not because proven-by-itself.
- **untrusted producers** — the entire evolving bulk *by code volume*: elaboration,
  optimizers (already `preserve-check`ed), SMT via proof-producing solvers, staging.
  They churn freely and are trusted for nothing; each emits a certificate `kernel-core`
  re-checks.

Trust and volume are decoupled. The bulk is untrusted; the trusted part is small and
frozen, its stability guaranteed by `kernel-spec`'s minimality.

## Why this is right where the quorum was wrong

- **Velocity.** chirality is a live self-modifying environment ([[live-environment]])
  whose checker never holds still. Under a quorum, every spec change must propagate to
  N implementations in lockstep, and version skew produces *valid* disagreement, so the
  alarm degrades exactly when the system is most active. Under de Bruijn, implementation
  churn is absorbed (untrusted producers); only `kernel-spec` churn touches the trusted
  base, and its minimality *is* a stability commitment.
- **Canonicality.** The quorum needed a canonical comparable verdict and had none
  (typing admits many valid derivations). Core derivations *are* that canonical object,
  so the de Bruijn split solves the problem the quorum could not.
- **Trust surface.** de Bruijn needs spec + a small core + hardware + build-time DDC.
  The quorum needed all that plus an independence assumption, a threshold DKG, N
  toolchains, and N-fold standing cost.

## Where the user's "no single point" instinct actually lives

The instinct was right; the quorum was the wrong level for it. "No single point" is
realized cheaply here as **N tiny independent proof-checkers over one portable proof
object** ([[split-role]] at the proof-checker level), plus Diverse Double-Compiling of
the core at build time. Redundancy where it is cheap and genuinely independent, not
where it is expensive and correlated.

## The honest tension and the honest interim

`kernel-core` is a small trusted point. Minimized, machine-verifiable, cross-checkable
by tiny proof-checkers, DDC-hardened — but a single point, softer than "structurally
none." That trade is deliberate ([[certificate-discipline]] on why a checked socket
beats a trusted pile). And no one has machine-verified a checker at chirality's full
richness end-to-end. Conventionally that reads as years of work (CakeML and seL4 were
human-paced verification efforts), but that is the wrong prior for this project:
roughly 85% of the chirality-related code, including the temporary Python backend, was
built in about two days of agent-orchestrated work, so estimate at that throughput,
not solo-human pace (see the velocity note in `.planning/ASSESSMENT-selfhost-cockpit.md`).
The honest nuance is that machine-checked *verification* is a distinct activity from
building and the velocity does not transfer automatically; the point is only that
"years" is the conventional prior, not a measured chirality estimate, and no replacement
number is claimed here. So name the current tier honestly (P5): the
checker's present-day assurance *is* agreement — differential testing of diverse
implementations plus `preserve-check` and the element/interaction proofs that already
exist. The earlier draft called that agreement "not the trust story," which was the
dodge the audit caught: today it is exactly the trust story. The verified-core /
certificate tier is the *target*, and the move from agreement-tier now to
certificate-tier later is a **tier climb**, taken element by element as resources allow,
not a switch already thrown.

## What agreement is still for

Not the checker. The legitimate residue for [[split-role]] agreement is: the bootstrap
floor and hardware execution (genuinely unprovable), solvers you cannot get proofs
from, and differential testing as CI.

## Principle basis and open items

P1 (no ungoverned path, including the mediator, met by a checked socket not a trusted
pile), P3 (port-check is type-check), P5 (tier how you hold a truth, lean strong, here
T0 by proof where the component is provable). Open: the full-richness verification
effort; the reflective-floor line (open-edge 5) now sits at `kernel-core`; certificate
preservation for the producers (open-edge 12, via [[certificate-discipline]]).
