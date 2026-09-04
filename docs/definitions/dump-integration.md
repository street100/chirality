---
node: dump-integration
layer: provenance
related: [index, module-map, modules-staging, decision-backend, open-edges]
status: draft
updated: 2026-09-03
---

# Dump integration

Where this material came from and what was accepted or rejected. Source: the
brainstorm dumps in `../GIANTDUMP/` (11 notes, around 6,500 words, consolidated
from nine web chat sessions). Four critical readers audited them against the
spine, one reader per cluster. This note is the synthesis.

## The headline: complementary, not redundant

The dumps are rich in category A (the typed upper region) and gesture at category
C (the bridge), but they are B blind and pregen blind. Every untyped referent in
them (TPM, foreign code, raw memory, external clock) appears only as something a
C module supervises; they never define an untyped hole directly. The whole derive
not store thread and the register root model are absent.

So the division of labor is clean. The dumps populate the A upper modules and the
custody seam. This spine and the secure datum model populate B, the pregen twin,
and the discipline that keeps C honest.

## Confirmed by independent re derivation

- QTT is the concrete kernel calculus for P2. Build the trusted core on it. See
  [[modules-core]].
- asm as surface is the floor, not a tier. This is the no untyped bottom rule re
  derived, plus the refinement that erasure relocates into one trusted emission
  step. See [[modules-lowering]].
- One staged compiler. The dumps explicitly collapse jit into the compiler at a
  later stage. See [[modules-staging]].

## Added by the audit

- cheri-floor, the silicon enforcement of the B mark. See [[modules-lowering]].
- adhikara, the cross layer capability protocol. See [[modules-broker]].
- Three security splits: isolation, anti replay, audit. See [[modules-security]].
- Correction: the blocking security trio (information flow, taint, constant time)
  is category A, not C.

## Corrected

- Security as a second core is on the wrong axis. Most of the eight security
  modules are more A modules, not a separate core. The real second core is C,
  which the dumps barely touch.
- Compiling to categories works only in the A region. It breaks at the B and C
  boundary, since the substrate does not live in a closed category. Adopt it as a
  technique inside specialize, not as the global engine.
- integer safety is a spurious split from refinement; fold it.

## Rejected as noise

- All LOC budgets (kernel 500 to 1500, security 22k to 37k, and so on). Estimate
  theater for a language that does not exist.
- All performance multipliers (2 to 5 times, 0.9 to 1.1 times C). No backend
  exists. See [[decision-backend]].
- The plus two years timeline. Invented.
- The factory of ephemeral runtimes metaphor. It is partial evaluation plus dead
  module elimination.
- The institutional gap marketing claim. Unfalsifiable.
- Wall to wall CONVERGED tagging as evidence. Convergence in a brainstorm means
  the chat stopped arguing, not that anything was validated.

## Two reading list frictions

- ATS reaches C competitive performance by compiling to C, which the backend
  decision forbids. Resolved: ATS is an existence proof only. See
  [[decision-backend]].
- WebAssembly sacrifices raw hardware access, so it can be a distribution target
  but not the model for asm as surface, whose point is raw hardware access. Keep
  them distinct.
