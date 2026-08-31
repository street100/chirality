---
node: resolution-patterns
layer: foundation
related: [design-principles, thesis, open-edges, split-role, joining-law, certificate-discipline, node-architecture, banks/port]
status: draft
updated: 2026-07-27
---

# Resolution patterns (how open edges resolve)

The reader's-side companion to [[open-edges]]. Walking the edges (the 2026-07-26
pass shaped all twenty) surfaced something the individual edges hide: the *answers*
rhyme. An open boundary rarely resolves by inventing a new subsystem — it resolves
by one of a small set of recurring **moves** that fall out of the principles and the
refraction discipline. Naming them makes the next open question faster to place, and
makes "chirality needs X" easier to refute.

> **The master lens above all of these is refraction** ([[thesis]]; the banks
> tier): a thing that is ONE feature in a conventional language is here a *sum of
> shards*, each in its own principled home. The patterns below are the recurring
> *shapes* those shards take. This set is **open, not closed** — three recurred
> most on the last walk; §4 names the others.

## 1. Ports carry everything (the port is the universal carrier)

When a question is "how does X get *communicated / propagated / ordered / held*
across a boundary," the answer is **X rides the port** — the typed crossing — not a
new X-subsystem. There is no central organ to add one to ([[node-architecture]]:
"no central owner; nodes touch only through ports").

- **Capability** is a port held; **effect** is the crossing's `=>`; **resource
  limit** is a bound in the port; **staging** is the `spawn` crossing ([[banks/port]]
  cross-cuts C1–C7).
- **Edge 1** — a process *is* something that crosses; "is this a process?" = "does
  its type carry a `=>`?". **Edge 14** — sync-vs-async is where the continuation
  sits *relative to the port*. **Edge 17** — an alarm is ordinary port traffic
  carrying evidence. **Edge 19** — cross-node causality is the *port-move order*, a
  vector clock carried on crossings, not a clock service.
- **The refutation it gives:** "chirality needs a subscription bus / an event system / a
  clock service / a message queue" → no; that traffic already has a carrier.

## 2. Tier the honest limit ("do what you can, named")

Where structure or proof *cannot* fully reach, you do not fake it and you do not
throw. You **name a tier** ([[split-role]]): a requirement states a minimum rung per
axis, the minimum **defaults high** (P4), and being forced below it is a **visible
typed gap**, never a silent hole. Prevention degrades to detection degrades to
accountability — each rung named.

- **Edge 4** — a value's tier is a type-carried classification, default-high.
  **Edge 15** — where linearity can't forbid a race (DMA), governance degrades to
  detect-and-reconcile, and for irreversible effects to *detect-and-account*.
  **Edge 20** — persistence is in-boot (built) vs cross-boot (a named hardware
  tier, not-had). **Edge 18** — tier-weight composes per axis, per leg.
- **The refutation it gives:** "chirality claims to prevent everything" → no; it
  *prevents where structure reaches and names the tier where it does not*, which is
  the stronger honest claim.

## 3. The preserve-check discipline (one invariant per boundary, certificate-checked)

A boundary is governed by preserving **one invariant**, discharged by a
**certificate the small trusted core re-checks** ([[certificate-discipline]]) — not
by trust, and not by test alone. Completeness of a boundary family is argued as *one
per principle* ([[joining-law]]: each connector preserves one principle-invariant).

- **Edge 12/13** — the four joining-law connectors are one-preserve-check-each
  (lowering→`preserve-check`, port-composition→frozen-set, bridge→`bridge-preserve-check`,
  staging→semantics); completeness = the invariant=principle correspondence; the
  open work is *stating* the two semantic checks, not finding a fifth connector.
- Its outbound half is the convergent build **E73** (outbound confinement), the
  bridge's unstated outbound preserve-check.
- **The refutation it gives:** "chirality trusts its compiler / its floor" → no; the
  bulk is untrusted and re-checked against a small core, and where proof runs out
  the fallback is *re-derivation* (D7), not trust.

## 4. Not a closed set — the other recurring shapes

Named so the three above are not mistaken for exhaustive:

- **One general elaborator, not per-instance.** The bridge is one elaborator
  parameterized by an evidence element; lowering is one `translate`+`preserve-check`;
  proof-presentation (edge 10 / E46) is one `reflect-typed` renderer. Per-referent
  anything is the anti-pattern.
- **Grade vs property.** A per-value *label* is a grade (carried in the type,
  composed at seams); the *guarantee over it* is a property (whole-assembly,
  class-2). The graded kernel split totality this way; edge 2 splits info-flow the
  same way (secrecy-lattice grade vs the non-interference proof).
- **Relocate, don't collapse — locality is a feature, not a limit.** When two
  concerns *feel* like one (D7's artifact-faithfulness vs operational agreement),
  the move is to send each to its proper home coupled by a shared enabler
  (spec-size), not to flatten them into one. The deeper reason, under every pattern
  above: **collapsing to 1:1 is the *globalizing* move** — a thing with n
  dependency-axes (a process leaning on other processes is already multi-axis)
  squashed onto one axis so a single totalizing view can hold it at once ("n
  pretending to be 1:1"). The error is the flatten-to-hold-it-all, *not* the
  locality. Serial attention and local verifiability **can't and shouldn't try to be
  global** — that is the correct shape, and **refusing to globalize is an axis of why
  chirality exists**: no central kernel ([[node-architecture]]), "the whole assembly is
  never an analyzable object" (D4 / edge 18), per-seam preserve-checks and local
  certificate re-check ([[certificate-discipline]]) — all so *local* composition is
  sound and no global view is ever needed. The only thing that stays central is the
  reflective floor ([[decision-reflective-floor]]). Every pattern here is a *local*
  move; this note must itself resist the collapse it names.

## Relational anchors

- [[open-edges]] — the edges these patterns were read off of; each edge's finding
  cites its pattern.
- [[design-principles]] — the reader's-side charter these sit beside; patterns are
  *how* the principles cash out on an open question.
- [[thesis]] / the banks tier — refraction, the master lens above all three.
- [[split-role]] (pattern 2), [[certificate-discipline]] + [[joining-law]] (pattern
  3), [[banks/port]] + [[node-architecture]] (pattern 1) — the depth homes.
