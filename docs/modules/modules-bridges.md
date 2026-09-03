---
node: modules-bridges
layer: module
implements: [category-bridge]
supervises: [category-untyped]
related: [module-map, modules-security, modules-custody, modules-broker, modules-lowering]
status: draft
updated: 2026-06-16
---

# Bridge modules

The rest of [[category-bridge|C]] beyond custody and the broker. Each is a typed
module whose referent is a B thing, governing by evidence.

## attestation

A typed evidence chain whose referent is hardware (TPM, TrustZone, measured
boot), which is B class. The dumps name it; the frame already lists it as a C
exemplar. It is monochromatic C: the typed evidence chain is the implementation
of a bridge, not an A proof. Anchored on `register-root` in [[modules-substrate]].

## isolation-enforce

The runtime compartment that supervises foreign or untyped code. The evidence
half of the isolation split; the proof half `isolation-type` is in
[[modules-security]].

## freshness-verify

Reconciles a value against an external clock or network counter to defeat replay
and rollback. The evidence half of the anti replay split; the linear token half
`freshness-discipline` is in [[modules-security]]. The external clock it reconciles
against is untrusted substrate made into evidence, the told time of
[[time-and-clocks]].

## audit-reconcile

Checks a write once trail against live state. The evidence half of the audit
split; the obligation half `audit-mark` is in [[modules-security]]. This is the
the audit chain pattern: a second, tamper evident record reconciled against
the live state.

## bridge-supervisor

The general typed manager over foreign and device substrate, presenting cross
checked views. Driver wrapping is the clearest case: the driver internals can be
anything, the typed interface gives the guarantee, and a compromise is bounded by
the capability the interface holds. This is the microkernel server pattern at the
type layer (dump D4). It is also what resolves foreign as an apparent untyped
bottom: the runtime offers no port to unwrapped foreign, so foreign is reachable
only wrapped, and getting around that is structurally hard rather than easy. See
[[axis-altitude]].

## runtime

Critical sections, preemption control, register root custody, the scheduler. It
holds the bounded clear window and keeps it atomic and preemption disabled,
because a context switch spills registers to RAM and would leak the root. It also
meters cost for the partial, unbounded processes whose bound is not proven, which
is the C twin of `cost-typed`. See the secure datum model.

## reflect-raw

Substrate mutating self modification, bounded above by the reflective floor. The
untyped twin of `reflect-typed`. It crosses a membrane and mutates running
structure, so it is effectful and gated, not a pure term to term function. The
boundary it cannot cross is an open edge; see [[open-edges]].
