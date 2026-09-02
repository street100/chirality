---
node: thesis
layer: foundation
refines: [principles]
related: [axis-typeability, category-bridge, open-edges]
status: current
updated: 2026-09-01
---

# Thesis: a gap is an ungoverned path

One idea sits under the whole language. Anything a program can do that the
framework cannot name is, by that fact, ungoverned. Intent does not close a
gap. The only way to control everything is to be able to express everything, so
that everything expressible is named and therefore checkable.

The five principles are this idea applied five times:

- §1 states it directly. A framework with a gap has an ungoverned path through
  the gap.
- §2 restates it as no exemption from the type. A category of code that opts
  out of the type is the gap again, and the type carries the whole cost.
- §3 restates it as a closed port set and as the membrane. A port that is not
  in the list is unreachable, and compute is inert until it crosses a named one.
- §4 restates it as the cost gradient. A denylist is never complete, so make the
  safe shape the cheap shape.
- §5 marks where the idea runs out. Some substrate cannot be brought under a
  type as a proof. There you hold the truth in several cross-checked copies and
  treat disagreement as the alarm.

Written against the old seven until 2026-09-01. §3 absorbed the membrane and §5
absorbed the tiering, which is the fold `PRINCIPLES.md`'s crosswalk records.

Why this matters for the rest of the base: the design splits cleanly because the
thesis splits cleanly. Where proof holds, you are in [[category-typed]]. Where
proof runs out, you are in [[category-untyped]]. The apparatus that lets the
first govern the second is [[category-bridge]], and it is the part of Chirality that
is new work rather than borrowed.

See [PRINCIPLES](../../PRINCIPLES.md) for the full statement of each principle with
its example.
