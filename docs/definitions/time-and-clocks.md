---
node: time-and-clocks
layer: module
implements: [category-typed, category-untyped, category-bridge]
related: [modules-core, modules-substrate, modules-bridges, modules-custody, error-and-alarm, node-architecture, open-edges]
status: draft
updated: 2026-07-26
---

# Time and clocks

The unifying note the scattered uses of time were missing. "Time" was an
under-split noun, like "process" and "port" before it. It is three different
things, and they land in different categories.

## Time you spend

A budget. How much time a process spends is a graded quantity in its type, an
over-approximate bound (exact cost is undecidable). This is `cost-typed`, category
A, internal and provable. See [[modules-core]]. It is not a clock reading; it is
fuel.

## Time you are told

An untrusted reading from the world. A real-time clock or a network time source is
a B referent, substrate the language cannot prove, reached through a port. You
never trust the told time, because the in-scope threat can roll it back or tamper
it. You turn it into evidence: `freshness-verify` (C) reconciles the told time
against a trusted anchor, and a rollback or staleness shows as divergence, which is
an alarm. See [[error-and-alarm]], [[modules-substrate]], and [[modules-bridges]].

The trusted anchor is the register-anchored monotonic counter. It derives from the
register root, so the threat cannot roll it back, registers being unreachable by
DMA. It is the integrity reference the told time is checked against. See the secure
datum model and `register-root` in [[modules-substrate]].

## Time you must act by

A deadline or a window. Refresh every T, hold cleartext no longer than N. These are
bounds in the type (`cost-typed` plus the custody linearity that bounds an exposure
window), and reaching one fires a counter effect: re-key, re-derive, relocate,
zero. So a deadline is a bound, and its expiry is an alarm answered by a counter
effect. The runtime schedules them. See [[modules-custody]], [[error-and-alarm]],
and `runtime` in [[modules-bridges]].

## Why this resolves the blur

The three are not one thing. Time you spend is a proven budget (A). Time you are
told is untrusted substrate (B) made into evidence (C). Time you must act by is a
bound whose expiry fires a counter effect. Each lands where the axes already put
it, so "time" stops being one overloaded word.

## Open — the register-root anchor's two gaps

The register-anchored counter is the single trusted time/order anchor, and it is
**local** and **volatile** — so it has exactly two coverage gaps, dual to each
other, each resolved by a pattern the rest of chirality already uses (shaped
2026-07-26, [[open-edges]] edges 19/20):

- **Cross-node ordering — the *spatial* gap (edge 19).** The three senses above are
  single-machine and the anchor is local; ordering across nodes needs causality
  (happens-before, a logical/vector clock). There is no shared clock (no central
  owner, [[node-architecture]]) and no trustable peer clock (zero trust, edge 7),
  so causality **rides the ports**: the causal edge is the port-move (received
  happened-after sent), happens-before = port-move order, and the vector clock is
  metadata carried on crossings (a bridge-certificate element, like alarm evidence)
  — not a clock subsystem. A peer's order claim is evidence, so safety rests on
  local accounting, never on it. Open: whether any workload needs *total* order
  (consensus, expensive under zero trust) or partial-causal suffices.
- **Persistent monotonicity — the *temporal* gap (edge 20).** Registers clear on
  power loss, so the counter is volatile. Persistence is a **tiered capability**
  ([[split-role]] "do what you can, named"): in-boot monotonicity is the
  register-root counter (built, sufficient *within* a session); cross-boot
  rollback-proofness is a **named hardware tier** (a TPM NVRAM monotonic counter),
  not-had in the CPU+RAM model — the boot-window is the honest bound, named not
  hidden. See the secure datum model and [[open-edges]].
