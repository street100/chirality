---
node: decision-bridge-elaborator
layer: decision
related: [category-bridge, joining-law, modules-lowering, modules-custody, decision-profiles, decision-split-checker, certificate-discipline, split-role, splitting-law, open-edges]
status: draft
updated: 2026-07-21
---

# Decision: one general bridge elaborator, parameterized by evidence elements

The direction is settled; the preservation obligation it rests on is open
(open-edge 12) and depends on an unpinned type feature (open-edge 18), so the
status is `draft`. An audit (2026-07-20) corrected the first draft's inflated
"N-squared collapse" and over-strong lowering analogy.

## The question

The [[joining-law]] bridge connector turns a B referent into evidence a typed
process can check. The [[module-map]] lists the bridges as somewhat bespoke C
modules (`attestation`, `redundancy`, `custody-split`, `freshness-verify`,
`audit-reconcile`). Does every typeability crossing need its own hand-written
bridge, or can one general elaborator build the bridge from supplied elements?

## The decision

One general bridge elaborator, not per-referent bridges, parameterized by:

- **T**, the target A-type it must produce, and
- **E**, an *evidence discipline* supplied as a conforming module, the "element":
  K-of-N agreement, a register-anchored MAC, an attestation, reconcile-against-clock,
  a refinement predicate.

Plus a **bridge-preserve-check** that discharges the bridge's invariant, "a B
referent enters A only as evidence" ([[joining-law]]), generically.

## The precedent, and how far it actually reaches

The lowering connector is already a general elaborator: `translate/lower` plus
`preserve-check` ([[modules-lowering]]) lowers any typed term and checks
preservation generically. The bridge should take the same *shape*. But the analogy
is weaker than the first draft claimed. `preserve-check` verifies **type
preservation**, a derivable relation over two terms. "Entered only as evidence"
constrains downstream **use** (never treated as proof, tier weight respected),
which is an information-flow-shaped semantic property. Enforcing it in types needs
tier weight to compose and subtype across composites, which **open-edge 18 lists as
unpinned**. So this decision's one generic mechanism depends on an open type
feature; that dependency is now stated, not hidden.

## Why it resolves, honestly scoped

The bespoke bridges were per-*referent* (N of them), not per-pair, so the first
draft's "N-squared collapse" was rhetorical. The real, still-worthwhile win: the
plumbing and the preservation proof are written once, and the reusable unit becomes
the evidence element, shared across crossings (the same K-of-N element serves the
checker's verdicts, redundant storage, and sensor fusion). The evidence disciplines
themselves remain the novel, hard work; C is where the design spends its
originality ([[category-bridge]]), and this decision reduces bespoke bridges to N
substantive elements, not to zero.

The bridge instances are the C evidence bridges: `split-provider` ([[split-role]])
for the unprovable residue, plus `attestation`, `freshness-verify`, and the rest. The
checker is *not* among them: it went to certificates ([[decision-split-checker]],
[[certificate-discipline]]), which is a bridge whose evidence element is "re-check a
derivation" rather than "agree across sources." Both are elaborator instances; they
differ only in the element.

## Principle basis

P4 as modularity is conformance, not configuration: the elaborator is the frozen
mechanism, elements are named conforming profiles ([[decision-profiles]]);
"general-purpose bridge that does everything" is the cop-out this avoids. P1: a
generic bridge-preserve-check keeps the thesis's gap closed at every crossing at
once, instead of trusting N hand-written bridges to each close it.

## What it leaves open

- **The evidence-element conformance interface.** What an element `E` must provide
  (a verify obligation, an outbound confine obligation, an alarm on divergence), and
  **element composition** (when `E` is K-of-N *then* threshold, do the obligations
  compose?), so `bridge-preserve-check` can discharge preservation from an element's
  small obligation rather than re-proving the whole bridge.
- **Bridge-preservation is harder to state than lowering's** (open-edge 12), and
  depends on tier-weight composition (open-edge 18). The checkable statement is
  owed; until it exists, "one elaborator" is a design direction, not a discharged
  claim.
- **Not one elaborator over all four connectors.** Four connectors preserve four
  invariants; a single elaborator over all would constrain nothing. Keep four,
  generalize within each. Lowering is done, the bridge is this decision, staging and
  port-composition later.
