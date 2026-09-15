---
node: goal-display
layer: navigation
related: [goals/README, goals/native-stack, arcs/display-calculus-arc, arcs/terminal-arc, arcs/native-window-arc, arcs/native-document-arc, decisions/decision-display-numerics, decisions/decision-scope, decisions/decision-work-ids, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-15
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

Five conditions. Two hold an arc; the other three are conditions in this file
and hold no arc file, so nothing schedules them yet.

1. **The calculus.** Style is a typed value resolved by total functions, and a
   property holds in every reachable rendering. [[arcs/display-calculus-arc]].
2. **The seam.** One document reaches more than one surface, and no theme or
   render changes silently. [[arcs/terminal-arc]], opened 2026-09-10, whose
   requirement 3 is the second clause: a draw tier selected by a wire query is
   the shape in which a render stops changing silently, and rows `TM4`, `TM5`
   and `TM9` serve it. The terminal is one of the surfaces the first clause
   counts, and it is the one this tree already draws on. Six of that arc's nine
   rows are outside what this condition says, and the section below names them.
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

## What condition 2 does not reach

[[arcs/terminal-arc]] rosters nine rows and this condition reaches three of
them. Requirement 3, the negotiated draw tier, is served by `TM4`, `TM5` and
`TM9`. Requirements 1, 2, 4 and 5 are served by `TM1`, `TM2`, `TM3`, `TM6`,
`TM7` and `TM8`, and no condition in this goal or in any other names them:
every declared terminal crossing lowering, a gate that holds a real terminal,
the emulator half reaching a program, and the `T#` cites resolving into
something that exists. Requirement 6, that what holds the terminal is a value,
is served by `TM9` alone, and that half is the author call below.

The author directed on 2026-09-14 that this condition be opened, over two
alternatives: a new terminal condition here, and a terminal goal of its own.
Condition 2 says what it said before. Widening it to swallow the pty lifecycle,
the line discipline and the emulator would take that decision back.

⚑ **FLAG, author tier.** [[arcs/terminal-arc]]'s first FLAG, verbatim:

```
⚑ FLAG, author tier: three groups here serve no stated goal condition. The
pty lifecycle, the line discipline and the emulator's own machinery are built,
cited by nine ledger rows, and named by no condition in [[goals/display]],
[[goals/own-web]], [[goals/native-stack]] or [[goals/local-ai]].
[[goals/local-ai]] condition 2 consumes the terminal and is about the editor
inside it. [[goals/native-stack]] condition 2 excludes it by name. Whether
[[goals/display]] grows a sixth condition, whether a goal is opened, or whether
these rows stay unscheduled, is the author's. `docs/goals/README.md` forbids
authoring an ambition the project has never stated, so this run invents no goal.
```

⚑ **FLAG, author tier.** Row `terminal/TM9`, verbatim:

```
whether the surface is a held value or stays fd 0 and fd 1 by convention.
⚑ Author call, carried and unanswered. `.planning/MINI-RUSH-HANDOFF.md:45`
refused the port in 2026-08, `E128`'s signature needs one, and `canvas/G2` asks
for a host that places a display list without owning the surface
```

## Its relation to the native stack

[[goals/native-stack]] condition 3, Document, becomes a consumer of this goal:
the typed style calculus it names is condition 1 here.
[[arcs/native-window-arc]] stays where it is and becomes the Wayland backend
that conditions 4 and 5 draw through.

## State

Stated 2026-09-04, unbuilt. The measured baseline sits in
[[arcs/display-calculus-arc]]'s own table, which is the authority for it. The
full roster of 59 rows across seven lanes, with the reference class per row, is
`.planning/DISPLAY-LAYER-GAP.md`. Of that roster, only the calculus arc's rows
are tracked here. [[arcs/terminal-arc]] comes from outside it, opened 2026-09-10
by author statement on the forcing case of `E128`, and condition 2 reaches three
of its nine rows. `E128` is the only element either arc has minted.

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
- **Three of the five conditions are unopened.** Each is citable from this file
  and none of them is scheduled.
- **Opening condition 2 anchored part of one arc and left the rest of it
  unanchored.** Six of [[arcs/terminal-arc]]'s nine rows are named by no
  condition in any goal, and the section above carries the arc's FLAG on it.
  Whether this goal grows a sixth condition, whether a terminal goal opens, or
  whether those rows stay unscheduled, is the author's.
- **The [[goals/README]] row for this goal is owed.** Its arcs column lists
  [[arcs/display-calculus-arc]] alone and its paragraph reads "Four of its five
  done-conditions hold no arc file", both true before this amendment and false
  after it. This run's write surface was this file.
