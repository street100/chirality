---
node: goal-display
layer: navigation
related: [goals/README, goals/native-stack, arcs/display-calculus-arc, arcs/native-window-arc, arcs/native-document-arc, decisions/decision-display-numerics, decisions/decision-scope, decisions/decision-work-ids, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-04
---

# Goal: the display layer, every surface drawn from one typed value

Stated by the author 2026-09-04, in session. It is an author call rather than a
derivation, on the precedent [[goals/README]] records for [[goals/presentability]]
and [[goals/local-ai]]. The target the author set: the best of web design,
expressed in chirality's own representations, across every surface this tree
will draw on.

## The claim, and where the project makes it

- [[examples/U13-typed-document-seam]] states the seam: the renderer takes the
  typed value. This goal is that seam widened past one renderer.
- [[arcs/native-document-arc]] already carries the requirement "style is a total
  function of a declared state". This goal is what that requirement needs
  underneath it.
- `lib/protocol/render.chiral` and `lib/prelude/doc.chiral` already hold five
  parts of a style system with no types on any of them. The measured shape is in
  [[arcs/display-calculus-arc]].
- [[target-tomodachi]] already puts the language on a screen, speaking the wire
  format with no libwayland.

## The shape condition

Stated by the author 2026-09-04, and it governs every condition below: **a
design feature arrives as primitives plus tools that harness them.** No arc
under this goal ships a display engine, a style engine, a layout engine or a
toolkit. Three consequences, each checkable:

1. **No module is named for a subsystem.** A module is named for the concept it
   owns, per [[banks/module]]. A cascade is a concept. An engine is a monolith
   wearing a filename.
2. **Every law states its property, and the property sits in a gate.** A total
   function with no stated property is the overhead case
   [[design-principles]] names: an abstraction that constrains nothing.
3. **Every primitive is reachable from a program without the rest of its lane.**
   A colour is usable with no layout. A display list is buildable with no style
   calculus. A program takes the shards it needs.

## What done means

Five conditions. One holds an arc; the other four are conditions in this file
and hold no arc file, so nothing schedules them yet.

1. **The calculus.** Style is a typed value resolved by total functions, and a
   property holds in every reachable rendering. [[arcs/display-calculus-arc]].
2. **The seam.** One document reaches more than one surface, and no theme or
   render changes silently. **Unopened, and it holds no arc file.**
3. **Geometry.** A box and a glyph have positions, and hit testing inverts them.
   **Unopened, and it holds no arc file.** Behind
   [[decisions/decision-display-numerics]] and the resolution-staging question
   the calculus arc names.
4. **The pixel.** A pixel has a correct value by type. **Unopened, and it holds
   no arc file.** Behind the span-primitive question, which is
   [[arcs/native-protocol-arc]] row N6's question about word ops asked over
   `Bytes`.
5. **The frame.** A frame is a function of state and time. **Unopened, and it
   holds no arc file.**

## Its relation to the native stack

[[goals/native-stack]] condition 3, Document, becomes a consumer of this goal:
the typed style calculus it names is condition 1 here.
[[arcs/native-window-arc]] stays where it is and becomes the Wayland backend
that conditions 4 and 5 draw through.

## State

Stated 2026-09-04, unbuilt. The measured baseline sits in
[[arcs/display-calculus-arc]]'s own table, which is the authority for it. The
full roster of 59 rows across seven lanes, with the reference class per row, is
`.planning/DISPLAY-LAYER-GAP.md`. Only the calculus arc's rows are tracked here.

## Honest limits

- **The scope ruling holds most of this out of reach.** The author ruled
  2026-09-04 that the immediate roadmap excludes non-chirality, and that focus
  stays on local primitives until the crypto and enforcement arcs finish.
  Rendering HTML, CSS, JS or HTTPS from a foreign server is out.
  [[records/author-calls]] carries the ruling.
- **No arc under this goal holds a reserved element block.** Rows carry
  arc-local ids per [[decisions/decision-work-ids]] and map to `unminted`. The
  standing block call in [[records/author-calls]] covers them.
- **Whether [[arcs/native-document-arc]] merges into this goal is an open author
  call.** Its rows V1 to V4 are absorbed by the calculus arc's row groups, so it
  either closes into this goal or keeps only what it carries beyond it.
- **Four of the five conditions are unopened.** Each is citable from this file
  and none of them is scheduled.
