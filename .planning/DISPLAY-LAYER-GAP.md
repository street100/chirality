# The display layer: the feature-goal roster

**Opened 2026-09-04** from a design session with the author. This is an
**outline of coverage**. No row is specced, nothing is minted into
`docs/elements/catalog.md` or `docs/elements/ledger.md`, and no code is
touched. §7 is the mint queue that runs before any row here may be cited by a
spec, per the no-phantom-dep rule in `docs/definitions/working-discipline.md`.

The question this answers: **what does a display layer have to do, if the target
is the best of web design expressed in chirality's own representations, across
every surface the tree will want to draw on.**

The question it does not answer: how any row is built, in what order beyond a
sketch, or whether it should be. Those are spec tier and author tier.

**Scope ruling, author, 2026-09-04.** The immediate roadmap excludes
non-chirality. Rendering HTML, CSS, JS or HTTPS from foreign servers is out.
Focus is local primitives until the crypto and enforcement arcs finish. Rows
below are the full roster; the ruling decides which are reachable now, and §8
sorts them by it.

**Lane ruling, author, 2026-09-04.** Terminal parsing, drawing, shading,
layering and 3D are separate lanes. A style vocabulary for one does not
generalize to another. §4 states what does cross.

---

## §1 · Measured baseline

Measured 2026-09-04 in the working tree.

| where | lines | what |
|---|---|---|
| `lib/protocol/render.chiral` | 790 | `Rendering`, nine constructors: `r-text`, `r-table`, `r-section`, `r-stream`, `r-tree`, `r-lines`, `r-hole`, `r-face`, `r-row`. SGR emission |
| `lib/prelude/doc.chiral` | ~200 | the six-constructor `Doc` algebra, Lindig's strict renderer. `d-tag` carries a face key |
| `lib/protocol/wire.chiral` | 96 | the Wayland wire codec, encode and message split |
| `prog/demo/sprites.chiral` | 76 | character rows to ARGB8888, the whole drawing surface of the tree |
| `lib/ports/pool.port` | 31 | the shm pool, size in the port type, backing memfd a linear `Fd` |
| `lib/memory/` | 233 | six files. The only writable region is a `Pool`, written by `pool-write` at an offset |

### The five parts of a style system already exist, untyped

| part | where | today | defect |
|---|---|---|---|
| the value | `render.chiral:38` | `(face (name Str) (fg I64) (bg I64) (attrs I64))` | SGR indices in a bare `I64`, attrs a bitmask. Zero invariants |
| the registry | `render.chiral:147-161` | a hardcoded assoc list, 11 entries | it lives in `lib/`, and 6 of 11 are one application's palette (`manas-*`) |
| the attachment | `doc.chiral:83-85` | `d-tag`'s `Str`, an open keyspace | any string is a key, and no key is required to exist |
| the resolution | `render.chiral:167` | `lookup-face` | a miss returns `(face name -1 -1 0)` silently |
| the cascade | `render.chiral:369` | `face-join` | attrs accumulate by `bor`; the inner's stated colour wins and `-1` inherits. A real rule with no law and no check |

**The coverage gap, measured 2026-09-04.** Grepped across `lib/`, `prog/` and
`TUI/`.

```
d-tag names emitted:  diag-head diag-site term-kw term-lit term-name term-qty term-var
faces defined:        comment default error keyword manas-bad manas-cursor
                      manas-field manas-header manas-ok manas-tag string
```

**Seven tags, eleven faces, zero overlap.** Every semantic tag the tree emits
resolves through `lookup-face`'s silent arm, including the compiler's own
diagnostics and the term pretty-printer. Five defined faces (`default`, `error`,
`manas-cursor`, `manas-tag`, `string`) have no `r-face` or `d-tag` consumer.
The registry and its consumers have drifted apart in both directions and nothing
reports it.

### What is absent

Grepped 2026-09-04: zero xdg-shell, zero seat, zero xkb, zero font, zero glyph,
zero protocol scanner, zero rasterizer beyond the sprite blit, zero DNS, zero
TLS. `parse-url` (`lib/protocol/http.chiral:101`) requires a dotted quad and an
explicit port.

---

## §2 · The numeric substrate: the float ruling

**There is no float type.** The `Op` sum is closed at fifteen integer ops
(`lib/prelude/prelude.chiral:37-39`). The phrase "the float→I64 wall" appears
across 26 documents in `docs/examples/` as a stated design position.

**Cost of adding one.** `Op`, `op-parse`, `op-name`, `op-bytes`, a new kernel
base type, the TAL checker, and the x64 emitter's register classes, since xmm is
a separate class with its own calling convention and allocation. Compiler
source, BUILD RULE, fixpoint.

**The reference class runs on fixed point.**

| system | representation | why |
|---|---|---|
| FreeType | 26.6, coordinates in 1/64 px | grid alignment is bit arithmetic: `round(x) == (x + 32) & -64`, `floor(x) == x & -64` |
| Blink and WebKit `LayoutUnit` | 1/64 px, chosen September 2012 | avoids precision loss converting to `Length`, and avoids integer division |
| Cairo | 24.8 for path coordinates | rasterizer-internal precision |

Blink aligns layout values to integer pixels at paint time to land on device
pixels. That is the whole discipline, and it is integer arithmetic end to end.

**A second reason applies here and nowhere else.** This tree verifies a
byte-identical fixpoint on every promotion. Float rounding is a reproducibility
hazard across emit paths. Fixed point preserves the property the tree already
gates on.

**Verdict.** Fixed point covers lanes C, E, B, T, R and most of Z. Lane Z's 3D
shading is the only place float earns its keep, and the 1990s software
renderers shipped without it. A decision doc is owed (§5, D1).

**The other float.** CSS `float` is a layout feature and a separate question,
carried as row B10.

---

## §3 · The feature goals

Reference class per row. `OURS` means an in-tree baseline exists to compare
against. `EXTERNAL` means the comparator is another system.

**Kind** is what the row produces, and it is the anti-monolith column. A design
feature that is one subsystem elsewhere lands here as several rows in different
homes, per the refraction rule in `docs/banks/INDEX.md`.

| kind | what the row produces | where it lives |
|---|---|---|
| `primitive` | a type carrying an invariant, or a value | the module that owns the concept |
| `law` | a total function plus the property it satisfies | beside its primitive, with the property in the gate |
| `port` | a crossing, and its extern surface | `lib/ports/`, a `.port` file |
| `tool` | a program that consumes the primitives and reports | a `.prog` root, or a phase in `tools/test/` |
| `decision` | a fork the author settles before any row cites it | `docs/decisions/` |

### Lane C · the style calculus (surface-independent machinery)

| id | goal | what the reference does | the chirality representation | kind | class |
|---|---|---|---|---|---|
| C1 | **Typed property values** | CSS values are strings parsed per property; the Typed OM exists to stop re-parsing, and its type coverage is still partial | every property is a sum with invariants. `Length` = px \| em \| rem \| pct \| fr \| ch \| auto \| min-content \| max-content. An invalid value has no representation | `primitive` | `OURS` (`Face`'s four bare fields) |
| C2 | **The cascade as a total ordered fold** | Servo records match results as a path in a shared rule trie keyed on (rule, specificity), then folds applicable declarations against the parent's computed values | one fold over an ordered list, total, with the order decidable from the value. No trie, because there is no string selector to memoise | `law` | `OURS` (`face-join`) |
| C3 | **Attachment without selectors** | selector matching needs a Bloom filter for descendant selectors and a specificity algebra to break ties | style attaches by a pure function over the node. A function returns one style, so specificity has nothing to arbitrate. Selector-shaped helpers are derived, and they compose by a stated law | `law` | `EXTERNAL` |
| C4 | **The inherit sum on every value** | CSS-wide keywords `inherit`, `initial`, `unset`, `revert`, applicable to every property | one wrapper sum around every property type, so "no opinion" is a constructor. `face-join` already does this with `-1` and cannot say it in the type | `primitive` | `OURS` |
| C5 | **Design tokens as typed bindings** | CSS custom properties are untyped strings that fail at the use site. The W3C DTCG format reached its first stable version 2025.10 with 40+ organisations behind it | a token is a typed binding checked at its definition. A theme is a value a root supplies, which also evicts `manas-*` from `lib/` | `primitive` | `EXTERNAL` |
| C6 | **The value expression algebra** | `calc()`, `min()`, `max()`, `clamp()`, with unit errors surfacing at computed-value time | an expression ADT with the unit in the type. A unit mismatch fails the checker | `primitive` | `EXTERNAL` |
| C7 | **The environment as a declared ADT** | media queries, then container queries (baseline since 2023), then anchored container queries. Each is a separate matching mechanism | the style function takes a declared `Env`. Viewport, container, colour scheme, reduced motion are fields of one value | `primitive` | `EXTERNAL` |
| C8 | **State-driven style over a finite state sum** | `:hover`, `:focus-visible`, `:active`, `:checked`, `:has()`, plus whatever CSS-in-JS computes at runtime | `style : (-> Env State Node Style)`, the state a declared ADT. This is the JSS capability with the closure replaced by a total function | `law` | `EXTERNAL` |
| C9 | **The every-state gate** | nothing in CSS or JS can state a property that holds across every reachable rendering | with `State` and `Env` finite, the gate walks the product and checks a property in each: contrast, no overflow, focus visible, no unstyled role. **The genuinely new row** | `tool` | `EXTERNAL` |
| C10 | **Resolution at compile time** | vanilla-extract and StyleX extract to static CSS at build time; Slint compiles `.slint` ahead of time and requires binding expressions to be pure, checked by its compiler | style resolution is ordinary code the compiler already evaluates. Nothing new is needed for the property Slint advertises | `law` | `EXTERNAL` |
| C11 | **Declared invalidation** | Blink's invalidation sets accept deliberate over-invalidation to avoid the cost of precise dependency tracking. Xilem diffs successive view trees | the dependency is the argument list of a pure function. What a style reads is what invalidates it, by construction | `law` | `EXTERNAL` |
| C12 | **Shorthands as constructors** | a CSS shorthand resets longhands it does not mention, which is the classic surprise | a shorthand is a function returning a value of the property record type. It cannot reach a field it does not name | `primitive` | `EXTERNAL` |

### Lane E · the element vocabulary

| id | goal | what the reference does | the chirality representation | kind | class |
|---|---|---|---|---|---|
| E1 | **Closed element sums per context** | HTML content models are validated after parsing, and the parser's error recovery is normative | constructor sets split by context (block, inline, row, cell). Invalid nesting is unconstructible, which retires the validator | `primitive` | `OURS` (`matcher.chiral`'s `Cls` idiom) |
| E2 | **Semantic role as a required field** | ARIA roles are optional attributes. Dear ImGui has no accessibility support at all; egui added AccessKit optionally | the role is a required constructor field. An unlabelled interactive element has no representation | `primitive` | `EXTERNAL` |
| E3 | **The accessibility tree derived** | AccessKit uses a push model borrowed from Chromium's multi-process architecture: the toolkit pushes a full tree, then incremental updates. Each node carries an id, a role and optional attributes | the tree is a total function of the document, because the role is already a field. No second tree to keep in sync | `law` | `EXTERNAL` |
| E4 | **Every document has a text form** | HTML is its own serialization, which is why the parser must be lenient | `print` is mandatory per type and nothing renders from it. Save, diff and grep work; there is one truth | `law` | `OURS` (U19) |

### Lane B · layout

| id | goal | what the reference does | the chirality representation | kind | class |
|---|---|---|---|---|---|
| B1 | **The box model** | content, padding, border, margin, plus `box-sizing` to switch which one `width` names | one record. The measured edge is a field, so there is no mode switch | `primitive` | `EXTERNAL` |
| B2 | **Normal flow: block and inline** | line boxes, baseline alignment, margin collapsing, the hardest legacy in CSS | block and inline as separate contexts from E1, so a line box is a type. Margin collapsing becomes a stated decision | `law` | `EXTERNAL` |
| B3 | **Flex** | Taffy implements Flexbox faithfully from the spec, runs on microcontrollers with kilobytes of RAM, and is used by Servo, Bevy and Zed | a pure function over the child list. Main and cross axis parameterised so one implementation serves both directions | `law` | `EXTERNAL` |
| B4 | **Grid** | tracks, areas, auto-placement, `fr` units. Taffy carries it beside flex | same shape as B3 with a two-dimensional placement pass | `law` | `EXTERNAL` |
| B5 | **Intrinsic sizing** | `min-content`, `max-content`, `fit-content`. Every layout algorithm needs them and they are a second traversal | two pure measures over the tree, which is what `rnd-cols` already is for the cell lane | `law` | `OURS` (`rnd-cols`, E174) |
| B6 | **Positioned and anchored elements** | CSS anchor positioning shipped in Chromium first and support is still uneven in 2026 | a positioned child is a constructor carrying its anchor reference. An anchor that does not exist fails the checker | `primitive` | `EXTERNAL` |
| B7 | **Scroll containers, overflow, clip** | overflow creates a scroll container, a clip, and a stacking context at once | three separate constructors. Coupling three effects to one property is the defect | `primitive` | `EXTERNAL` |
| B8 | **Fixed-point layout units** | Blink and WebKit use 1/64 px `LayoutUnit`; FreeType uses 26.6 for the same reason | a `Length` whose scale is in the type, so a mixed-scale arithmetic is a type error | `primitive` | `EXTERNAL` |
| B9 | **Hit testing** | egui rewrote hit testing to be more accurate and to allow clicking slightly outside a target. Dear ImGui users report non-rectangular hit testing as unsupported | the inverse of layout, over the same frame tree, pure. One traversal answers which node owns a point | `law` | `EXTERNAL` |
| B10 | **CSS `float`** | text wrapping around a floated box, the legacy layout mode flex and grid replaced | a decision, and the recommendation is to omit it. It exists because 1996 had no other tool | `decision` | `EXTERNAL` |
| B11 | **Constraint layout** | Cassowary is an incremental simplex solver, published 1997, behind Auto Layout since OS X Lion. SwiftUI replaced it with a dataflow technique | a fork. Dataflow over a pure tree is what B3 and B4 already are, and it is the direction SwiftUI went | `decision` | `EXTERNAL` |

### Lane T · text

| id | goal | what the reference does | the chirality representation | kind | class |
|---|---|---|---|---|---|
| T1 | **Font vocabulary and fallback** | cosmic-text uses fontdb for discovery and a custom fallback that reuses the static fallback lists from Chromium and Firefox | the font set is a declared value of the profile. Fallback is a total function over a closed list | `primitive` | `EXTERNAL` |
| T2 | **Shaping** | rustybuzz is an incremental port of HarfBuzz and is strictly an OpenType shaper. cosmic-text delegates to it | out of scope for the floor. A bitmap font needs no shaper. Complex scripts are a stated limit until this row opens | `law` | `EXTERNAL` |
| T3 | **Line breaking, UAX #14** | expressible as rules over line-breaking classes, implementable with a two-dimensional pair table | the pair table is a value, and the class of a codepoint is a total function. `utf8.chiral` already decodes with U+FFFD resync | `primitive` | `OURS` (partial) |
| T4 | **Bidi, UAX #9** | line breaks are determined before rule L1, and the level determination depends on where the lines broke. The two algorithms are mutually entangled | a fixpoint stated as such, with the entanglement in the type instead of in a comment | `law` | `EXTERNAL` |
| T5 | **Glyph rasterization** | FreeType stores outline points as 26.6 vectors, scales from the EM grid, then grid-fits | a bitmap font is the floor and it is a table. Outline rasterization is its own row and needs R3 | `law` | `EXTERNAL` |
| T6 | **Paragraph layout** | alignment, justification, letter and word spacing, decoration, hyphenation | pure functions over the shaped run list. Nothing here crosses the membrane | `law` | `EXTERNAL` |

### Lane R · raster and paint

| id | goal | what the reference does | the chirality representation | kind | class |
|---|---|---|---|---|---|
| R1 | **Colour as a typed value** | CSS moved to `oklch()`, `color-mix()` and relative colour syntax, with Display P3 reachable. `color-mix()` is baseline widely available in 2026 | a colour is a sum over spaces with a gamut invariant. Mixing carries the space it mixed in, so a perceptual mix and an sRGB mix are different values | `primitive` | `OURS` (three bare `I64`) |
| R2 | **Gamma-correct compositing** | correct blending converts sRGB to linear, premultiplies, blends, and converts back. 8 bits per channel is insufficient once stored linearly | the encoding is in the type. A premultiplied linear sample and an sRGB sample cannot be added, because they are different types. **The single highest-value invariant in this lane** | `primitive` | `EXTERNAL` |
| R3 | **The span primitive** | every rasterizer writes runs of varying pixels | **the measured wall.** The pure `Bytes` surface is twelve externs, with no `pack-u8`, no builder, no fill-with-function. `brepeat` makes a solid span in one call; varying content has no linear-time path. Gates R4 through R9, T5 and all of Z | `port` | `OURS` |
| R4 | **Paths, fills, strokes** | tiny-skia is a minimal CPU-only Skia subset covering fill and stroke with solid colours, gradients and patterns, stroke dashing, clipping and blending | a path is a value, filling is a pure scanline function, and the write is one `pool-write` per row | `law` | `EXTERNAL` |
| R5 | **Gradients** | GSK carries linear, radial and conic gradient nodes as distinct render node types | one constructor per gradient kind, interpolating in the colour space R1 names | `primitive` | `EXTERNAL` |
| R6 | **Clipping, including rounded** | GSK has a dedicated `RoundedClipNode` beside its plain clip | the clip is a constructor wrapping its child, so nesting is structural | `primitive` | `EXTERNAL` |
| R7 | **Shadow and blur** | GSK has a `ShadowNode` drawing one or more shadows behind a child | a shadow is a constructor with a list of offsets. A property that secretly repaints is the defect | `primitive` | `EXTERNAL` |
| R8 | **Blend modes** | `mix-blend-mode` and `background-blend-mode`, meaningful only against a defined backdrop | a blend is a constructor taking two children. The backdrop is an argument, so "what does this blend against" has one answer | `primitive` | `EXTERNAL` |
| R9 | **Images** | decode, scale, colour-manage, then composite | decode is pure over `Bytes`. PNG needs inflate, which is its own row | `law` | `EXTERNAL` |

### Lane Z · composite

| id | goal | what the reference does | the chirality representation | kind | class |
|---|---|---|---|---|---|
| Z1 | **The display list as a closed sum** | GSK render nodes are the drawing primitives needed to express widget content and CSS styling: text, gradient, texture, clip, rounded clip, repeat, shadow. One node tree feeds GL, Vulkan and cairo renderers | one closed sum. **This is the harness seam**: the cell lane, a shm surface, a wire document and a compositor scene are four consumers of one value | `primitive` | `EXTERNAL` |
| Z2 | **Layers and explicit stacking** | in CSS a stacking context is created implicitly by opacity, transform, filter and overflow, and `z-index` interacts with all of them | a layer is a constructor. Paint order is a total function of the tree with no implicit promotion | `primitive` | `EXTERNAL` |
| Z3 | **Transforms** | 2D affine, then perspective, `preserve-3d`, `backface-visibility` | a matrix of fixed-point values. The 3D cases are separate constructors, so a 2D-only backend refuses them at the type | `primitive` | `EXTERNAL` |
| Z4 | **Damage tracking** | the wlroots scene graph handles damage so the compositor does not have to. Without damage tracking, battery life goes | damage is a pure function of two display lists. The diff is a value, and the same function serves a compositor later | `law` | `EXTERNAL` |
| Z5 | **Animation as a function of time** | CSS shipped scroll-driven animations in 2023, scroll-triggered animations in Chrome 145, `interpolate-size: allow-keywords` for the `auto` transition, and the View Transitions API | a frame is `(-> Env State Time DisplayList)`. Deterministic, replayable, and testable at any `t`, which no stateful animation system can offer | `law` | `EXTERNAL` |
| Z6 | **HiDPI and fractional scaling** | `wp-fractional-scale-v1` pairs with `wp-viewport`: the client sets the destination rectangle to the unscaled surface size, sizes the buffer by the intended scale, and leaves `buffer_scale` at 1 | the scale is a field of `Env`, so it is an input to style and layout rather than a correction applied afterwards | `primitive` | `EXTERNAL` |
| Z7 | **3D geometry and projection** | vertices, camera, projection, depth buffer | the pipeline is a pure fold. The perspective divide is the one place fixed point needs care | `law` | `EXTERNAL` |
| Z8 | **Shading as a checked pure function** | GLSL, WGSL and MSL are separate languages with separate compilers, and purity is enforced by the language boundary | a shader is an ordinary `->` function. The membrane makes "a shader performs no I/O" a checked property of ordinary code. Same shape as the constant-time judgment on `native-protocol/N5`. **The second genuinely new row** | `law` | `EXTERNAL` |

### Lane H · harness

| id | goal | what the reference does | the chirality representation | kind | class |
|---|---|---|---|---|---|
| H1 | **One document, many surfaces** | GSK routes one render-node tree to GL, Vulkan and cairo. GTK4 CSS is a deliberate subset of web CSS: it has no `display`, no `position`, and no flex properties, because layout belongs to the widget | the same split, made structural. The style calculus resolves; the surface consumes a display list. A surface that cannot express a constructor refuses it at the type | `law` | `EXTERNAL` |
| H2 | **The view and widget split** | Xilem diffs successive view trees into a retained widget tree, with Adapt nodes for component composition. Immediate mode has a stated paradox: layout is needed to know a window's size, and interaction needs the position before the contents are shown | `view : (-> State Node)` with the diff over an immutable tree. Chirality is strict and linear, so the retained side holds no hidden mutable state | `decision` | `EXTERNAL` |
| H3 | **Profile-enforced layering** | GTK's `GdkDisplay` reaches through the whole stack, so "this widget does not touch the display server" is a convention | a profile is a module set over a frozen port set, gated by `lib/typing/totality-check.chiral:130`. Style code that reaches for a socket does not compile. **The requirement the author stated, made checkable** | `tool` | `OURS` |
| H4 | **The theme coverage gate** | a CSS theme that omits a rule silently falls back. `lookup-face` does the same thing in this tree today | a theme is a total function from the role sum. The gate is the coverage check the compiler already runs on any closed sum, so an incomplete theme fails to compile | `tool` | `OURS` |
| H5 | **The golden render gate** | browsers gate on reference tests: render two documents, compare pixels, allow a fuzz factor | a document renders to a display list, and a display list is a value. Compare structurally with no fuzz factor, which is what `prog/manas/contract/golden.chiral` already does for run manifests | `tool` | `OURS` |
| H6 | **The property walk** | contrast checkers and linters run outside the style system and read the output | C9's walk, run as a phase. Contrast, overflow, focus visibility and unstyled roles checked in every reachable `(Env, State)` pair | `tool` | `EXTERNAL` |
| H7 | **The display-list differ** | wlroots computes damage inside the scene graph so each compositor does not | one pure function over two display lists, returning the changed region. Damage tracking and the golden gate are the same function with different consumers | `tool` | `EXTERNAL` |
| H8 | **The interface scanner** | `wayland-scanner` reads protocol XML and emits C for both the client and the server role | a tool that reads an interface description and emits chirality: a closed sum per interface, encode and decode. Direction-agnostic, so a compositor gets the mirror role for free. Belongs to enforcement requirement 5's tooling surface | `tool` | `EXTERNAL` |
| H9 | **The style inspector** | devtools exists because the cascade is opaque: a computed value cannot say which rule produced it without instrumentation | provenance is a value. The inspector is a pure function from a node to the list of functions that contributed each property, exact rather than reconstructed | `tool` | `EXTERNAL` |

**Count: 59 rows across seven lanes. 24 primitives, 23 laws, 8 tools, 1 port, 3 decisions.**

---

## §4 · What crosses a lane and what does not

The author's lane ruling, stated structurally.

**Crosses.** Lane C entire, lane E entire, and the shape of lane B. The
machinery is the element tree, the attachment, the cascade fold, the inherit
sum, the environment, the state function and the gate.

**Does not cross.** Every property vocabulary. A blend mode has no cell-lane
meaning. A gradient has no cell-lane meaning. Sub-cell position does not exist
in a grid of characters. Lane B's algorithms cross only when parameterised over
the unit, because cells and fixed-point pixels are different scales.

**The consequence.** The calculus is parameterised over a property algebra per
lane. Lanes share an algebra. They do not share a stylesheet.

### What GTK settles, and what it does not

GTK is the right comparator and the wrong shape, and the two halves are
separable.

| take | why |
|---|---|
| style resolves, the widget lays out | GTK4 CSS has no `display`, no `position` and no flex properties. That boundary is what lets one style vocabulary serve more than one surface |
| the render-node tree as a closed sum | GSK's node set is chosen to express widget content and CSS styling, and three renderers consume one tree |
| a property set chosen for the context | GTK adds its own properties when needed instead of inheriting the document vocabulary whole |

| refuse | why |
|---|---|
| `GdkDisplay` reaching through the stack | H3 replaces the convention with a frozen port set |
| the widget object with mutable state and signals | H2. A strict linear language has no place to hide the state a signal mutates |
| one shipped library | gdk, gsk, gtk and pango ship together and are versioned together. The refraction rule refuses that here |
| a stylesheet parsed at runtime | C10. Resolution is ordinary code the compiler already evaluates |

---

## §5 · Decisions owed

| id | decision | why it is a decision |
|---|---|---|
| D1 | **Fixed point, and at what scale** | §2 recommends fixed point and 1/64 on the FreeType and Blink precedent. Adding `F64` is a closed-op-sum change with a fixpoint, so the alternative has to be refused on the record rather than by omission |
| D2 | **Selectors, or attachment by function** | C3. The draft in `.planning/NATIVE-STACK-EXPANSION.md` names both. Attachment by function removes specificity entirely and is the recommendation |
| D3 | **Where the role sum lives** | E1 and C1. Parameterising `Doc` costs a fixpoint, because `lib/prelude/doc.chiral` is imported by `lib/typing/diag.chiral` and `lib/surface/pretty.chiral`, both compiler modules. Deriving the registry from a role sum by a total function buys the same property with no compiler change |
| D4 | **The span primitive's shape** | R3. It gates six rows in lane R, one in T, and all of Z. It is a memory-bank question and belongs with `native-protocol/N6` |
| D5 | **Immediate or retained** | H2. It decides whether C9's gate is meaningful, because a gate over every state needs the state declared |
| D6 | **The colour encoding in the type** | R1 and R2. Whether premultiplication and linearity are type-level or convention. Type-level is the recommendation and it is invasive |
| D7 | **Which lanes ship a text form** | E4. `print` is mandatory for documents. Whether a display list has one is open |
| D8 | **CSS `float`** | B10. Recommendation is to omit |
| D9 | **How many resolution stages** | CSS has specified, computed, used and actual values because layout feeds back into style: `width: 50%` needs the containing block and `em` needs the parent's resolved size. A single pass before layout is the assumption the roster currently carries, and it is probably false. The staging belongs in the types. **B5 is the row that surfaces it**, which is the reason geometry is the second experiment | 

---

## §6 · Proposed goal, arcs and rows

Following `docs/decisions/decision-work-ids.md`: an arc holds rows with
arc-local ids, and a row maps to an element or to nothing. None of these arcs
holds a reserved element block, so every row maps to `unminted` until §7 runs.

**Proposed goal: `goals/display`.** The relation to the existing goal:
`goals/native-stack` condition 3 (Document) becomes a consumer of this goal.
`arcs/native-window-arc` stays where it is and becomes lane R and Z's Wayland
backend. `arcs/native-document-arc` rows V1 to V4 are absorbed by lanes C and E,
so that arc either closes into this one or keeps only what V carries beyond it.
**That merge is an author call.**

### The goal's shape condition

Stated by the author 2026-09-04, and it governs every arc below: **a design
feature arrives as primitives plus tools that harness them.** No row ships a
display engine, a style engine, a layout engine or a toolkit. The kind column in
§3 is where each row declares which half it is, and a row that cannot say is not
ready to be specced.

Three checkable consequences:

1. **No module is named for a subsystem.** A module is named for the concept it
   owns, per `docs/banks/module`. `cascade.chiral` is a concept. `engine.chiral`
   is a monolith with a filename.
2. **Every law states its property, and the property is in a gate.** A total
   function with no stated property is `docs/definitions/design-principles.md`'s
   overhead case: an abstraction that constrains nothing.
3. **Every primitive is reachable from a program without the rest of the lane.**
   A colour is usable with no layout. A display list is buildable with no style
   calculus. A program takes the shards it needs.

### The arcs

**The section boundary is the done-condition.** An arc's REQUIREMENTS are its
unit in this tree, so an arc is one sentence that becomes true. Lanes survive as
row groups inside an arc, which preserves the lane ruling without spending an
arc file per lane.

| arc | what becomes true | rows | state |
|---|---|---|---|
| **the calculus** | style is a typed value resolved by total functions, and a property holds in every reachable rendering | C1 to C12, E1 to E4, C9, H6 | **mint this one** |
| the seam | one document reaches more than one surface, and no theme or render changes silently | Z1, H1, H3 to H5, H7, H9 | goal condition, unopened |
| geometry | a box and a glyph have positions, and hit testing inverts them | B1 to B11, T1 to T6 | goal condition, unopened. Behind D1 and D9 |
| the pixel | a pixel has a correct value by type | R1 to R9 | goal condition, unopened. Behind D4 |
| the frame | a frame is a function of state and time | Z2 to Z8 | goal condition, unopened |

Geometry holds two lanes because layout and text share a unit and a pass. Raster
and composite stay apart because the lane ruling is about their vocabularies and
they do not share one.

**One arc is minted, and the other four stay as conditions in the goal file.**
`records/author-calls.md:27` records nine arcs already writing `UNASSIGNED` rows
against no reserved block, logged as a defect. Four more arc files nobody can
start repeats it. A condition in a goal file is citable and costs nothing.

**The Z1 condition is the anti-monolith test for the whole goal.** A display
list read by exactly one surface is a rendering engine's internal type wearing a
different name. Two consumers is the evidence that the seam is real. It sits in
the seam arc, so the test is deferred with it.

## §7 · The mint queue

Runs before any row above is cited by a spec.

1. `docs/decisions/decision-display-numerics.md` for D1. It is cited by B8, T5,
   R1, Z3 and Z7, so it is first.
2. The goal file `docs/goals/display.md`, with the four conditions and the
   honest-limits section the schema requires.
3. The arc files for the four arcs reachable now, each with its measured
   what-is-in-the-tree table.
4. `records/author-calls.md`: the scope ruling, the lane ruling, and the
   native-document merge call.
5. A display bank, once shards exist to refract. Premature at zero, on the
   crypto-bank precedent in `.planning/NATIVE-STACK-EXPANSION.md`.

---

## §8 · Sequencing sketch

Not a build order. Sorted by the author's ruling.

**Reachable inside the local-primitives window**, with no crossing and no
compiler change:

| | rows | why now |
|---|---|---|
| the cell-lane instance | C1, C2, C4, C5, the `Rendering` half of H1 | seven tags resolve silently today, the compiler's own diagnostics among them. **This is the one experiment**: it tests the state sum, attachment, coverage and the seam at once |
| the span primitive question | D4, R3 | shares the question `native-protocol/N6` is already asking about word ops and codecs |
| the numerics decision | D1 | pure paperwork, and it unblocks five rows |
| the role and registry question | D3, E1, E2 | a total function from a closed sum, no compiler change |
| the layering proof | H3 | profiles exist and are gated today |

**Behind the two clocks**, per the scope ruling: everything in lanes R, Z and
the Wayland half of H1.

**Out of the immediate roadmap entirely**, per the same ruling: HTML, CSS
parsing, JS, DNS, TLS, and any foreign document.

---

## §9 · Sources

Researched 2026-09-04. Egress from the agent sandbox is blocked for raw
requests; these were retrieved through the harness's own fetch path.

- CSS Typed OM and Houdini: <https://developer.mozilla.org/en-US/docs/Web/API/Houdini_APIs>, <https://web.dev/articles/css-props-and-vals>
- Blink and WebKit `LayoutUnit`: <https://trac.webkit.org/wiki/LayoutUnit>
- FreeType 26.6 conventions: <https://freetype.org/freetype2/docs/glyphs/glyphs-6.html>
- GSK render nodes and the scene graph: <https://docs.gtk.org/gsk4/class.RenderNode.html>, <https://docs.gtk.org/gtk4/drawing-model.html>
- GTK4 CSS subset: <https://docs.gtk.org/gtk4/css-overview.html>, <https://docs.gtk.org/gtk4/css-properties.html>
- Servo Stylo rule tree and cascade: <https://doc.servo.org/style/rule_tree/>, <https://book.servo.org/architecture/style.html>
- Blink style invalidation sets: <https://chromium.googlesource.com/chromium/src/+/master/third_party/blink/renderer/core/css/style-invalidation.md>
- Zero-runtime CSS-in-JS: <https://vanilla-extract.style/>
- Slint language and compiler: <https://slint.dev/>, <https://github.com/slint-ui/slint>
- Xilem architecture: <https://raphlinus.github.io/rust/gui/2022/05/07/ui-architecture.html>, <https://github.com/linebender/xilem>
- Taffy layout: <https://github.com/DioxusLabs/taffy>
- Cassowary: <https://cassowary.readthedocs.io/en/latest/topics/theory.html>
- AccessKit: <https://accesskit.dev/how-it-works/>
- cosmic-text, rustybuzz, swash: <https://github.com/pop-os/cosmic-text>
- UAX #14 line breaking: <https://www.unicode.org/reports/tr14/proposed.html>
- Modern CSS colour: <https://developer.mozilla.org/en-US/docs/Web/CSS/Reference/Values/color_value/oklch>
- Container queries and anchor positioning: <https://developer.mozilla.org/en-US/docs/Web/CSS/Guides/Containment/Container_queries>, <https://developer.mozilla.org/en-US/docs/Web/CSS/Guides/Anchor_positioning/Anchored_container_queries>
- Scroll-driven and scroll-triggered animation: <https://developer.chrome.com/blog/scroll-triggered-animations>
- W3C Design Tokens format: <https://www.designtokens.org/tr/drafts/format/>
- Premultiplied alpha and gamma: <https://ssp.impulsetrain.com/gamma-premult.html>
- tiny-skia and Vello: <https://github.com/linebender/tiny-skia>, <https://github.com/linebender/vello>
- wlroots scene graph and damage: <https://github.com/swaywm/wlroots/blob/master/include/wlr/types/wlr_scene.h>
- Wayland fractional scaling: <https://wayland.app/protocols/fractional-scale-v1>
- Immediate mode tradeoffs: <https://github.com/emilk/egui>, <https://github.com/ocornut/imgui>
