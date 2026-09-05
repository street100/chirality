---
node: arc-canvas
layer: navigation
related: [arcs/README, goals/own-web, goals/display, arcs/vocabulary-arc, arcs/display-calculus-arc, arcs/native-window-arc, arcs/binary-split-arc, banks/render, banks/profile, decisions/decision-profiles, decisions/decision-work-ids, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-05
---

# Arc: the canvas

- goal: [[goals/own-web]], condition 2
- reserved element block: **none**. Rows carry arc-local ids per
  [[decisions/decision-work-ids]] and map to `unminted`. Three letters, `G` for
  the canvas, `P` for the pipeline and `Q` for the harness, because
  `.planning/OWN-WEB-GAP.md` already cites them.
- build-state authority: [[status-ledger]]

Opened 2026-09-05 by author statement. The done-condition: **one value reaches
many hosts through view functions whose port sets are frozen and checked.**

**A canvas is a view function**, the same kind of thing `lib/surface/pretty.chiral`
already is for `Term`. A **host** puts a presentation on a surface. State,
ports and input belong to the program and never to the canvas, which is what
lets canvases be separate runtimes with nothing shared between them.

There is no browser and no widget toolkit in this arc. Both are a lens plus a
host.

## What is in the tree already

Measured 2026-09-05.

| where | what |
|---|---|
| `lib/typing/kernel.chiral:60` | `Profile` is a kernel type carrying `(ports (List Str))`, `(target Str)`, `(memory (Maybe Str))` and `(total Bool)` |
| `lib/lowering/compile-front.chiral:293-301` | `profile-ports` and `pm-isect`. A composite's admissible port set is the intersection of its profiles' |
| `lib/typing/totality-check.chiral:130-139` | the profile gate over the whole composite |
| `find . -name '*.profile'` | **zero instances.** The kind is documented in `MAP.md` with no consumer, which is `binary-split/B4` and `BA-10` |
| `lib/surface/pretty.chiral` | E181, the working view function: `Term` to `Doc`, output is source |
| `lib/protocol/render.chiral` | `Rendering`, nine constructors, SGR emission. The terminal host, live |
| `prog/demo/sprites.chiral` | character rows to ARGB8888, 76 lines, the whole drawing surface of the tree |

**The profile machinery is live in the compiler and has never been
instantiated.** This arc is its first consumer, which closes `binary-split/B4`
and `BA-10` as a side effect.

## What is missing

Grepped 2026-09-05: no display list, no view function over a document, no host
abstraction, no `.profile` file anywhere.

## REQUIREMENTS

1. **A canvas is pure and its port set is the border.** A pure canvas declares
   an empty port set, and one that reaches a crossing it did not declare fails
   to compile. This is `display-calculus/H3` with a consumer.
2. **A canvas does not own its surface.** The same canvas code runs under two
   hosts, and only the host changes.
3. **One value reaches two hosts**, and their display lists compare
   structurally with no fuzz factor. This is `display-calculus/Z1`'s
   two-consumer test with the consumers named.
4. **A canvas declares a finite `State`**, and the every-state walk runs over
   its product. This is the witness `display-calculus/C9` and `H6` are waiting
   for.
5. **A lens is a reader and a view whose round trip closes**, gated per lens.

## Rows

| row | what | state | element |
|---|---|---|---|
| `canvas/G1` | a canvas is a pure view function, `(-> Env State Node)` | not started. `pretty.chiral` is the working instance over a different value | `unminted` |
| `canvas/G2` | a canvas does not own its surface; a host places the display list | not started. Requirement 2 | `unminted` |
| `canvas/G3` | the port set is the border, and nesting reduces it | not started. **The first `.profile` instance** | `unminted` |
| `canvas/G4` | a document carries no computation: a closed `State` sum with a total transition table, and a closed `Request` sum | not started. **The highest-value invariant in this arc** | `unminted` |
| `canvas/G5` | the declared `State` is the every-state witness | not started. Answers the open call in [[arcs/display-calculus-arc]] | `unminted` |
| `canvas/G6` | a canvas asks for nothing on a document's behalf; a forbidden request is refused and the document still renders | not started | `unminted` |
| `canvas/G7` | `Grant` at route formation, request honouring and ownership, proving permission and never identity | not started. `E40` custody is the precedent | `unminted` |
| `canvas/G8` | one value, many hosts | not started. Terminal live, the rest behind the two blockers | `unminted` |
| `canvas/P1` | a lens is a reader and a view beside the existing pair | not started | `unminted` |
| `canvas/P2` | a lens re-spells the vocabulary and never extends it | not started | `unminted` |
| `canvas/P3` | the round trip separates viewing from editing | not started | `unminted` |
| `canvas/P4` | lenses come last | a stated ordering, and the reason this arc follows [[arcs/vocabulary-arc]] | `unminted` |
| `canvas/Q2` | a host's closure carries no compiler, counted as `^(end-module "` markers | not started. `binary-split`'s method, `BA-16` | `unminted` |
| `canvas/Q3` | the two-host gate, compared structurally | not started. Requirement 3 | `unminted` |
| `canvas/Q4` | the hostile-document corpus, every refusal named | not started | `unminted` |
| `canvas/Q5` | the every-state walk, run as a phase | not started. `display-calculus/H6` instantiated | `unminted` |

## Resume state

**Where a session picks up.** `G1` and `G3` against the terminal host, because
both are reachable today: the profile machinery is live, `pretty.chiral` is the
working shape, and `render.chiral` is a host that exists. Neither needs a
display list, so neither waits on `display-calculus/Z1`.

**What blocks the arc.** It follows [[arcs/vocabulary-arc]]. A canvas is a view
function over a value, and the value is that arc's stage 4, so `G1` has nothing
to view until the vocabulary closes. `P4` states the same ordering for lenses.

**Two blockers stand between a canvas and a screen**, both measured 2026-09-05
and neither owned by an arc.

| blocker | measurement |
|---|---|
| nothing reaches a screen | `lib/lowering/tal/crossing-wraps.chiral` carries 44 lowered crossings and `sock-send-fd` is absent from them, so `prog/demo/wl-client.chiral:201` does not lower. `sock-listen`, `sock-accept` and `bind` are missing too, and nothing under `tools/test/` reads `prog/demo/`, which is why it went unnoticed |
| nothing draws varying content in linear time | `display-calculus/R3`, the measured wall. `brepeat` makes a solid span and varying content has no linear-time path. It gates six raster rows, one text row and all of composite |

Sprites work and real drawing does not. **The terminal host is unaffected by
either**, so `G1`, `G3`, `G4`, `G5`, `Q2` and `Q4` are all reachable now.

**What this arc closes elsewhere.** `display-calculus/H3` gets its consumer,
`Z1` gets its second and third, `C9` and `H6` get the witness their open author
call asks for, and `binary-split/B4` and `BA-10` get the `.profile` instance
they are waiting on.

**The design is `.planning/OWN-WEB-GAP.md`**, lanes G, P and Q, and its §5
carries the decisions this arc waits on.

**Row state and order live in `.planning/OWN-WEB-CHECKLIST.md`**, which carries
both arcs' rows grouped by pipeline stage, with `design`, `blocked`, `decide`
and `owed` against `docs/decisions/decision-design-before-mint.md`.
