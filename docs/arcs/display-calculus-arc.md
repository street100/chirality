---
node: arc-display-calculus
layer: navigation
related: [arcs/README, goals/display, arcs/native-document-arc, arcs/native-window-arc, arcs/memory-discipline-arc, banks/module, decisions/decision-display-numerics, decisions/decision-work-ids, decisions/decision-scope, records/author-calls, records/findings, status-ledger, index]
status: current
updated: 2026-09-18
---

# Arc: the style calculus

- goal: [[goals/display]]
- reserved element block: **none**. Rows carry arc-local ids per
  [[decisions/decision-work-ids]] and map to an element or to `unminted`. This
  arc keeps five letters instead of one, `C`, `E`, `H`, `A` and `R`, because
  three of them are the roster's in `.planning/DISPLAY-LAYER-GAP.md` and
  renumbering them would break every citation the roster already makes. ⚑ A
  row spelled `E1` here is arc-local, cited `display-calculus/E1`, and carries
  no claim on the element numbering. **`A` is the fourth letter, minted by the
  C01 EXAMPLE audit.** `A1` and `A2` measure reach into what already exists in
  the tree instead of proposing a goal, so no lane in the roster fits them.
  **`R` is the fifth, taken from the gap file's raster lane with `R3` on
  2026-09-06 and widened 2026-09-18.** That file spells `R1` through `R9` with
  its own meanings, so an id in that span means here what it means there, and
  a row this arc discovers for itself takes `R10` onward. `R10` through `R15`
  were opened 2026-09-18 and no gap-file row carries those numbers.
- build-state authority: [[status-ledger]]

Opened 2026-09-04 by author statement, as the first of five conditions under
[[goals/display]]. The done-condition: **style is a typed value resolved by
total functions, and a property holds in every reachable rendering.** The arc
covers the surface-independent machinery and the element vocabulary it attaches
to. Every property vocabulary belongs to a lane and stays out, per the author's
lane ruling in [[records/author-calls]].

## What is in the tree already

Measured 2026-09-04. **Six parts of a style system exist and none of them
carries a type.**

| part | where | today | the defect |
|---|---|---|---|
| the value | `render.chiral:38` | `(face (name Str) (fg I64) (bg I64) (attrs I64))` | SGR indices in a bare `I64` and attrs a bitmask. Zero invariants |
| the registry | `render.chiral:148-161` | a hardcoded assoc list, 11 entries | it lives in `lib/`, and 6 of the 11 are one application's palette, spelled `manas-*` |
| the attachment | `doc.chiral:83` | `d-tag` carries a `Str` | the keyspace is open. Any string is a key and no key is required to exist |
| the resolution | `render.chiral:164` | `lookup-face` | its `nil` arm at `:167` returns `(face name -1 -1 0)` and reports nothing |
| the cascade | `render.chiral:366` | `face-join` | attrs accumulate by bitwise or, the inner's stated colour wins, and a negative colour inherits. A real rule with no law and no check |
| the theme | `render.chiral:42-43`, `Mode`'s `faces` field | `init-loader.chiral:614-616` registers three modes, each carrying its own face list | `command-loop.chiral:96` destructures `((mode r faces))` and discards `faces`. A root-supplied theme already exists and reaches no consumer |

**The coverage gap, measured 2026-09-04** by grepping `lib/` and `prog/` for
every emitted `d-tag` and `r-face` name against the registry. `TUI/` does not
exist in this tree; the terminal code the name pointed at lives at
`prog/scriba/`, already reached by the `prog/` half of the grep.

```
d-tag names emitted:  diag-head diag-site term-kw term-lit term-name term-qty term-var
faces defined:        comment default error keyword manas-bad manas-cursor
                      manas-field manas-header manas-ok manas-tag string
```

**Seven tags, eleven faces, zero overlap.** Every semantic tag the tree emits
resolves through the silent arm. The two emitters are the compiler's own
diagnostics, `lib/typing/diag.chiral`, and the term pretty-printer,
`lib/surface/pretty.chiral`. **Eight** faces reach a consumer through `r-face`:
six by a literal name at the call site (`comment`, `keyword`, `manas-header`,
`manas-ok`, `manas-bad`, `manas-field`), and two through a computed name:
`manas-tag` (`prog/scriba/init-loader.chiral:222`, registered at `:244`) and
`manas-cursor` (`prog/scriba/manas-mode.chiral:918`, also `:1002`). **Three
reach none: `default`, `string`, `error`.** A grep for `r-face "NAME"` finds
only the literal six; a name bound to a variable before the call does not
match that pattern, so a literal grep undercounts reach and the true orphan
count is three rather than the five such a grep reports. The registry and its
consumers have drifted apart in both directions and nothing reports it.

### The raster surface, measured 2026-09-18

The style calculus resolves a value and the raster lane writes it. `R3` minted
as `E200` on 2026-09-06 and its design ran on 2026-09-18, which is what put the
six rows below on this roster. Every cell here was re-opened in the file it
cites.

| part | where | today | the defect |
|---|---|---|---|
| the span surface | `lib/prelude/prelude.chiral:91-104` | **eleven** externs touch `Bytes`, and `brepeat` (`:100`) is the only one that writes a span | a repeated cell is all it writes, so varying content has no linear-time path. `E200` is minted against exactly this |
| the byte write | `lib/lowering/tal/bytes.chiral:610` | `bput-u8` writes one byte and returns a fresh cell | it slices the prefix, slices the suffix and concatenates twice, so it copies the whole cell per byte |
| the arithmetic | `lib/prelude/prelude.chiral:37-39` | **sixteen** `Op` constructors, every one integer | nothing is missing here. `FD-39` (`records/findings.md:625`) states positively that every operation in its six-item build list is one of these sixteen, and no float type exists anywhere in this tree |
| the coordinate | nowhere | a grep over `lib/` and `prog/` for `fixed point`, `26.6`, `24.8` and `frac-bits` returns one hit, a comment about Loihi 2 at `prog/unit/encoding.chiral:15` | a coordinate is a bare `I64` and its denominator lives in a reader's head |
| the pixel | nowhere | a grep over `lib/` and `prog/` for `premultipl`, `srgb` and `gamma` returns three hits, two of them the type checker's `Gamma` register environment (`lib/lowering/tal/check.chiral:5`, `:45`) and one a trace string (`prog/demo/e51-hello.chiral:8`) | no width, alpha state or transfer function sits in any type, so two samples in different encodings add |
| reclamation | `lib/memory/alloc-growing.chiral:22-24`, `lib/memory/arena.chiral:29` | three empty instruction lists for `renter`, `rexit` and `adrop` over a fixed 67,108,864-byte arena | nothing a compiled program runs reclaims a byte. `E200`'s design prices one 1920-pixel scanline on the `bcat` route at 7,376,640 bytes and one frame at 7.97 GB (`docs/arcs/parts/display-calculus-R3.md:128-129`) |
| the drawing that exists | `prog/demo/sprites.chiral` | 76 lines, the whole drawing surface of this tree | it draws solid sprite rows and `docs/arcs/canvas-arc.md:117` records the consequence as "Sprites work and real drawing does not" |

## What is missing

Grepped 2026-09-04 across `lib/` and `prog/`: zero hits for `theme`, zero for
`specificity`, and no declaration of a `Style`, `State` or `Length` data type.
The one `(data Env` hit is `EnvR` at `lib/ports/clock.port:28`, the process
environment. `cascade` appears four times and every one is a comment about
dropped-definition propagation in `lib/lowering/compile-back.chiral`.

### The raster group, and the three edges that run against its order

`FD-39` (`records/findings.md:625`) lists six items and `E200` delivers item
(5) alone. The other five plus the pixel type form one group whose dependency
order reads `R10` then `R13` and `R11`, then `R12`, then `R14`, with `R2` and
`R15` off to the side. Each row owns one thing: `R10` a coordinate whose
denominator is a type parameter, `R11` one integer per pixel of the active
band, `R12` the sum that turns those integers into coverage bytes, `R13` the
subdivision that feeds curves in, `R14` the loop that hands `E200` its spans,
`R2` what a pixel is, and `R15` the destination `E200`'s design refused.

Three edges run backwards through that order and none of them is a schedule.

**`R2` reaches back into an element already minted.** `E200`'s design resolved
its operand question by minting two one-constructor wrappers and recorded that
`R2` "widens the colour wrapper later without touching this signature"
(`docs/arcs/parts/display-calculus-R3.md:334`, its decision 1). So the row latest
in the pixel's own story edits the meaning of the row built first.

**`R14` sits above `E200` and is consumed by it.** The emitter is the last
item in the build list and the surface primitive it feeds is the first thing
built, so the arithmetic arrives after its own consumer.

**`R13`'s tolerance is re-derived from the device surface each frame.**
`FD-39`'s own header (`records/findings.md:583`) measures that per-frame
re-derivation as the single mechanism any surveyed renderer uses to keep a
border exact while the zoom changes. That makes a pure arithmetic row depend on
a port-lane fact, which is the one edge that stops this group being read as a
build sequence.

## REQUIREMENTS

1. **A value in this lane carries its invariant.** Every property is a sum whose
   invalid states have no representation, so a construction the vocabulary
   forbids fails the checker. The `Face` record's four bare fields are the
   baseline this replaces. ⚑ **Widened 2026-09-18 from "a property value" to
   "a value in this lane"**, because two more values here carry an invariant a
   bare `I64` and a bare `Bytes` throw away. A coordinate carries the
   denominator it is measured in, so two instantiations at 1/64 and 1/256 have
   no sum. A pixel carries its width, its alpha state and its transfer
   function, so `FD-37`'s four refusals hold by construction: an encoded sample
   plus a linear one, a premultiplied sample plus a straight one, a linear
   sample stored at 8 bits, and an unpremultiply at 8 bits, which is the one
   operation Skia declines to implement in integers at all
   (`records/findings.md:567`). The observation is the same in all three cases,
   which is why this is one requirement: the checker refuses the program, and
   today it accepts every one of them because the types are bare.
2. **The cascade is a total ordered fold with a stated law.** The order is
   decidable from the value, the fold is total, and the law is asserted in a
   gate that reddens when the fold changes. `face-join` is the rule that exists
   today with neither statement nor check.
3. **A role has no silent default.** Resolution is total over a closed role sum,
   so the silent-miss arm has no counterpart in the replacement. The seven tags
   above are the fixture: each one resolves to a named role or the build fails.
4. **A theme is a value a root supplies, and an incomplete one fails to
   compile.** The coverage check the compiler already runs on a closed sum is
   the whole gate. Done also evicts `manas-*` from `lib/`, which is checkable by
   the same grep that measured it.
5. **The every-state walk is a distinct mechanism from coverage, and it needs
   an interactive witness this arc has not chosen.** The phase enumerates the
   `(Env, State)` product and checks contrast, overflow, focus visibility and
   unstyled roles in each pair. Requirements 3 and 4 are the static check:
   a closed `Role` sum plus a total `Theme`, and the compiler's own
   exhaustiveness check is what finds the seven silently-resolving tags,
   because a theme omitting one of them fails to compile. The walk is a
   dynamic check over a state axis, and it needs a consumer that declares one.
   The cell-lane witness (`lib/typing/diag.chiral`, `lib/surface/pretty.chiral`)
   declares neither an `Env` nor a `State`, so its product is 1 and a walk over
   it would prove only that the phase runs. A meaningful instance needs an
   interactive consumer, and which one stands as its witness is an open author
   call ([[records/author-calls]]); `prog/scriba/` is the obvious candidate, on
   the evidence that the registry already carries a `manas-cursor` face for a
   navigable cursor row. ⚑ Its phase number is behind the standing
   suite-number call in [[records/author-calls]].
6. **Each piece of the coverage arithmetic compiles alone, and none of it needs
   a float type.** ⚑ **Added 2026-09-18.** `FD-39` (`records/findings.md:625`)
   answers the zoom-exactness question with a six-item build list and states
   positively that every arithmetic operation in it is one of the sixteen `Op`
   constructors at `lib/prelude/prelude.chiral:37-39`. Five of those six items
   and the pixel type they write through had no row on any arc's roster, which
   is what [[working-discipline]] calls a discovered requirement. The
   requirement has two halves and each has its own observation. The separation
   half: the accumulator, the sum, the subdivision and the emitter each build
   and run in a program holding none of the other three, which is
   [[goals/display]] consequence 3 (`docs/goals/display.md:43`) stated for this
   group. Observed as four module cells that each compile alone, and a design
   that folds two of them together fails its audit on that clause, which is
   exactly how `E200`'s design refused Shape D. The integer half: a grep for a
   float type over the four cells returns zero, which today is true of the whole
   tree and has to survive the rows landing.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `display-calculus/C1` | typed property values, invalid states unconstructible. **built, in one tier.** `lib/protocol/grid.chiral:12` is `Attrs`, six named `Bool`s over the closed `Color` sum at `:6`; E111, `built`. The C01 pre-run is `superseded`. The residue is a conversion to the emit side's `Face`, taken over by `docs/examples/C1C2-style-round-trip.md` (pre-run 2026-09-04) | cascade | primitive | new | 1 | open | `unminted` |
| `display-calculus/C2` | the cascade as a total ordered fold. **the fold is built and the law is unstated.** `apply-one` (`grid.chiral:215`) cases totally over `Sgr` and `fold-sgr` (`:232`) folds it in order. No gate feeds `face-sgr`'s bytes into it. The C01 pre-run is `superseded`; `docs/examples/C1C2-style-round-trip.md` (pre-run 2026-09-04) states the round-trip law | cascade | law | new | 2 | open | `unminted` |
| `display-calculus/C3` | attachment by a pure function over the node, no selectors and no specificity. not started; C1's example measures that this witness needs no conflict rule, without settling C3 itself | cascade | law | new | 2 | open | `unminted` |
| `display-calculus/C4` | the inherit sum wrapping every property value. not started. Covered by the C01 pre-run, which went `superseded` 2026-09-04; C1C2 does not take this row over. `Color`'s `color-default` (`grid.chiral:6`) is a default and `Face`'s `-1` is a sentinel, so neither is the constructor this row asks for | cascade | primitive | new | 1 | open | `unminted` |
| `display-calculus/C5` | design tokens as typed bindings, and a theme as a root-supplied value. Cashes the `Mode.faces` shard `render.chiral:42-43` already carries and `command-loop.chiral:96` discards. not started. Covered by the C01 pre-run, which went `superseded` 2026-09-04; C1C2 does not take this row over. [[banks/render]] shard V measures the theme value as `absent` | cascade | primitive | new | 4 | open | `unminted` |
| `display-calculus/C6` | the value expression algebra with the unit in the type. not started | cascade | primitive | new | 1 | open | `unminted` |
| `display-calculus/C7` | the environment as a declared ADT. not started | cascade | primitive | new | 4 | open | `unminted` |
| `display-calculus/C8` | state-driven style over a finite state sum. not started | cascade | law | new | 5 | open | `unminted` |
| `display-calculus/C9` | the every-state gate: a property checked in every reachable rendering. not started. ⚑ **The witness is proposed 2026-09-05: [[arcs/canvas-arc]] row `G5`.** A canvas declares a finite `State` because `G4` forbids a document from carrying computation, so behaviour is a closed sum with a total transition table. The cell lane's product measures 1 and a canvas's does not  ⚑ **Witness chosen 2026-09-06: `prog/scriba/`.** The cell lane's `(Env, State)` product measures 1, so a walk over it proves only that the phase runs; scriba is the interactive consumer, and the face registry already carries a `manas-cursor` for a navigable cursor row. | cascade | tool | new | 5 | open | `unminted` |
| `display-calculus/C10` | resolution at compile time, as ordinary code the compiler evaluates. not started | cascade | law | new | 2 | open | `unminted` |
| `display-calculus/C11` | declared invalidation: the dependency is the argument list. not started | cascade | law | new | 2 | open | `unminted` |
| `display-calculus/C12` | shorthands as constructors that cannot reach an unnamed field. not started | cascade | primitive | new | 1 | open | `unminted` |
| `display-calculus/E1` | closed element sums per context, so invalid nesting is unconstructible. not started | element | primitive | new | 1 | open | `unminted` |
| `display-calculus/E2` | the semantic role as a required constructor field. not started | element | primitive | new | 3 | open | `unminted` |
| `display-calculus/E3` | the accessibility tree derived by a total function. not started | element | law | new | 3 | open | `unminted` |
| `display-calculus/E4` | every document has a text form, and nothing renders from it. not started | element | law | new | 3 | open | `unminted` |
| `display-calculus/H6` | the property walk, run as a suite phase. not started; same witness gap as C9, which it instantiates | gate | tool | new | 5 | open | `unminted` |
| `display-calculus/A1` | the `Doc` to `Rendering` path is reached. measured 2026-09-04, and re-measured the same day: `grep -rn '"protocol/render-doc"' lib/ prog/` returns zero, and `dg-doc` (`lib/typing/diag.chiral:561`) has zero consumers outside its own file. ⚑ The scope is load-bearing. Two importers live under `tools/`, `tools/test/samples/e158_render.prog:58` and a heredoc probe at `tools/test/render-doc.sh:423`, and Phase 17 (`tools/test/run-tests.sh:268`) builds the first and runs it (`tools/test/render-doc.sh:110`). What this row asks for is a SHIPPING producer, and there is none. No `d-tag` in this tree reaches `lookup-face`. **Precondition for any C1 gate that can fail** | adoption | law | connect | 2 | open | `unminted` |
| `display-calculus/A2` | `Mode`'s `faces` reaches the renderer. measured 2026-09-04: `command-loop.chiral:96` discards it. The shard C5 cashes | adoption | law | connect | 4 | open | `unminted` |
| `display-calculus/R3` | the span primitive: **eleven** externs touch `Bytes` (`lib/prelude/prelude.chiral:91-104`), re-counted 2026-09-18 against the twelve this cell carried, and `brepeat` (`:100`) is the only one that writes a span. A builder does exist, `bput-u8` (`lib/lowering/tal/bytes.chiral:610`), and it slices the prefix, slices the suffix and concatenates twice, so it copies the whole cell per byte and varying content still has no linear-time path. Cited by [[arcs/canvas-arc]] and [[goals/own-web]] as the wall in front of six raster rows, one text row and all of composite. **Built 2026-09-18** at `30b288b`, `d2b8f05` and `f0de3cc`: `bover` is a twelfth `Bytes` extern, source-over of one premultiplied colour over a destination span through a coverage mask, one `ti-bnew` and one pass. Measured on the arena's own cursor (`lib/ports/process.port:36`): sixteen 1920-pixel spans cost 278,144 bytes against 118,824,960 through `bcat` per pixel, a 427x ratio. Phase 33 green at 19 rows, five mutants each moving exactly its pinned set | adoption | primitive | new | 1 | built | `E200` |
| `display-calculus/R2` | the pixel encoding as a type: width, alpha state and transfer function, so an encoded sample and a linear one are different types. **Rostered by no arc until 2026-09-18**, existing only at `.planning/DISPLAY-LAYER-GAP.md:195`, which is the agent tier. `FD-37` (`records/findings.md:551`) hands it four corrections and the number it lacked. Unpremultiply precedes linearisation and the two fail to commute, Skia conditioning the elision on exactly that (`records/findings.md:559`), so three premultiplication states exist where the gap file's cell names two. The depth is 10 bits encoded against 12 linear, from CSS Color 4's own precision table (`:557`). Source-over with a coverage mask is integer-reachable at ±1 LSB while no surveyed implementation evaluates a transfer function in integers at any width (`:561`). Wayland's floor is a SHOULD over two 8-bit premultiplied encoded formats and accepts nothing linear and nothing wider (`:563`). Absence: a grep over `lib/` and `prog/` for `premultipl`, `srgb` and `gamma` returns three hits and every one is the type checker's `Gamma` environment or a trace string | raster | primitive | new | 1 | open | `unminted` |
| `display-calculus/R10` | the fixed-point coordinate type, denominator a type parameter. `FD-39` build-list item (1) (`records/findings.md:625`). `FD-34` (`records/findings.md:523`) measures that nothing in the record argues for 1/64 specifically, that FreeType, cairo and Blink each made the denominator a parameter in their own language (`FT_PAD_FLOOR( x, n )`, `CAIRO_FIXED_FRAC_BITS`, `FixedPoint<fractional_bits, Storage>`), and that Gecko's 1/60 argues **against** a power of two on decimal-exactness grounds and still ships. Absence: a grep over `lib/` and `prog/` for `fixed point`, `26.6`, `24.8` and `frac-bits` returns one hit, a comment about Loihi 2 at `prog/unit/encoding.chiral:15`. Discovered by `E200`'s design (`docs/arcs/parts/display-calculus-R3.md:217`), which named it residue and could not open a row | raster | primitive | new | 1, 6 | open | `unminted` |
| `display-calculus/R11` | the signed-area cell accumulator: one integer per pixel of the active band, updated by the two integer adds at `FTGRAYS:533`. `FD-39` item (2) (`records/findings.md:625`). It ships in FreeType `grays` and in Skia's analytic AA, two independent shipped proofs in integers. Absence: nothing under `lib/` holds a per-pixel accumulation buffer, and it never writes to the surface, so `E200` cannot deliver it and its design says so (`docs/arcs/parts/display-calculus-R3.md:218`) | raster | primitive | new | 6 | open | `unminted` |
| `display-calculus/R12` | the row prefix sum with a truncating clamp to the coverage byte. `FD-39` item (3) (`records/findings.md:625`). `FTGRAYS` derives coverage as `area >> ( PIXEL_BITS * 2 + 1 - 8 )` and **compensates** its per-scanline division remainders instead of dropping them, so error does not accumulate along a slanted edge (`records/findings.md:611`); that non-accumulation is the property a gate on this row asserts. Absence: no prefix sum and no coverage byte exist in this tree. Discovered by `E200`'s design (`docs/arcs/parts/display-calculus-R3.md:219`) | raster | primitive | new | 6 | open | `unminted` |
| `display-calculus/R13` | integer midpoint subdivision with a shift-derived segment count, over a flattening tolerance re-derived in device pixels each frame. `FD-39` item (4) (`records/findings.md:625`), at `FTGRAYS:1073-1074` where conics split on a second difference of `ONE_PIXEL / 4` and the count is taken as `count = 0x10000U >> shift`. The per-frame re-derivation is the load-bearing half: `FD-39`'s own header (`records/findings.md:583`) measures it as the single mechanism any surveyed renderer uses to keep a border exact while the zoom changes, and Vello states its tolerance as 0.25 device pixels. Absence: no curve type and no subdivision exist under `lib/`. Discovered by `E200`'s design (`docs/arcs/parts/display-calculus-R3.md:220`) | raster | primitive | new | 6 | open | `unminted` |
| `display-calculus/R14` | the coverage-span emitter, the loop over `R12` that hands `E200` its spans. `FD-39` item (6) (`records/findings.md:625`) calls it "a loop over (3) and not a new primitive", so it may mint no element at all. `E200`'s design put it in residue because it cannot run until `R12` exists (`docs/arcs/parts/display-calculus-R3.md:222`). The row is here because the deferral needs a name: this is the one item of the build list that joins the arithmetic to the surface, and until it has an id the join is a phantom | raster | law | new | 6 | open | `unminted` |
| `display-calculus/R15` | Shape D, the zero-allocation composite straight into a `(Pool n)`, **refused** by `E200`'s design (`docs/arcs/parts/display-calculus-R3.md:296-322`) because it binds the primitive to the port lane and `docs/goals/display.md:43` consequence 3 forbids that, making a glyph atlas, an offscreen layer and a unit test all unreachable without a live pool. It allocates nothing, which against an arena that reclaims nothing (`lib/memory/alloc-growing.chiral:22-24`, over the fixed 67,108,864 bytes at `lib/memory/arena.chiral:29`) is the strongest single property any shape in that design held, and the design keeps it "as the zero-allocation path a frame loop will want" (`docs/arcs/parts/display-calculus-R3.md:329`). That design routed it to [[arcs/native-window-arc]], whose roster carries no such row today; which arc seats it is an author call this amendment does not take | raster | port | new | 6 | open | `unminted` |

The `kind` cell is the anti-monolith column of [[goals/display]]'s shape
condition. A row that cannot say which half it is has not been scoped.

### Coverage

Groups are the cascade (`C`), the element vocabulary (`E`), the gate (`H`),
adoption of what is already built (`A`) and the raster arithmetic (`R2`, `R10`
through `R15`). Every requirement is served: 1 by C1, C4, C6, C12, E1, R3, R2
and R10; 2 by C2, C3, C10, C11 and A1; 3 by E2, E3 and E4; 4 by C5, C7 and A2;
5 by C8, C9 and H6; 6 by R10, R11, R12, R13, R14 and R15. Every row serves one.
`A1` and `A2` are `connect`: both subjects are built and the gap is that nothing
reaches them. Twenty-seven rows, six requirements, none uncovered.

`R3` was rostered here 2026-09-06. It was cited by [[arcs/canvas-arc]] and
[[goals/own-web]] under a `display-calculus/` id and rostered by nothing, which
is why "which arc owns it" stood as an author call: the id already said. It is a
`Bytes` primitive and no kind of cascade row, so it sits in `adoption` beside the
other two rows about a surface that exists and does not reach far enough.

**`R2` is here on `R3`'s precedent and nothing else.** It carries a
`display-calculus/`-shaped id in `.planning/DISPLAY-LAYER-GAP.md:195`, it is
that file's own "single highest-value invariant in this lane", and no arc's
roster held it. `records/author-calls.md:72` records the argument that seated
`R3`: the id already said. The seat question on `R3` itself stands open at that
row and this amendment does not touch it.

**Every `origin` above is `new` and §3 defends each one.** The raster table
measures an absence for all seven: no fixed-point type, no accumulation buffer,
no prefix sum, no subdivision, no emitter, no encoding in any type, and a
zero-allocation destination that was designed and refused. `R15` is `new` in the
sense that matters here, which is that the tree holds no such extern; its design
exists and its verdict was against it.

### Where the reclamation requirement landed, and why not here

`E200`'s design priced the arithmetic: one 1920-pixel scanline on the `bcat`
route costs 7,376,640 bytes and one 1080-row frame costs 7.97 GB, against a
fixed 67,108,864-byte arena (`lib/memory/arena.chiral:29`) whose `renter`,
`rexit` and `adrop` are three empty instruction lists
(`lib/memory/alloc-growing.chiral:22-24`), so the arena is exhausted at roughly
byte 3,100 of the first scanline (`docs/arcs/parts/display-calculus-R3.md:119`,
`:128-129`). That is a discovered requirement and **it already holds a roster
row.** [[arcs/memory-discipline-arc]] requirement 1 is "Peak is the live set",
and `memory-discipline/M2` (`alloc-region`, minted `E82`) and
`memory-discipline/M4` (`alloc-dps`, minted `E84`, whose stated target is
"`nb-bcat`'s quadratic") both serve it. Opening a row here would be the same
work under a second id. What this arc contributes is the workload: the numbers
above are a display measurement of a memory row, and they belong in that arc's
resume state when someone next works it.

## Resume state

⚑ **2026-09-18: `R3` is built and `E200` is closed.** Four commits: `30b288b`
the primitive (two wrappers, one extern, one `prim2lib` row, two `TIFn`s
appended last in `native-lib`, and the promoted compiler), `d2b8f05` the probe,
`f0de3cc` phase 33, `8a47cc9` the E185 byte-identity pin repointed at `E200`'s
promotion because `native-lib` grew and every root's image grew a page with it.
The fixpoint ran from one blob to `C2 == C3` at 1,257,848 bytes, which is where
`docs/definitions/working-discipline.md:35-41` puts the first agreement for a
change that reaches emission.

**What the run measured that the SPEC did not have.** Three things, each in the
gate's own header with its citation. `ulimit -v` is not an RSS instrument here,
because any `RLIMIT_AS` makes the entry stub's arena `mmap` fail at every cap
from 96 MiB to 32 GiB, so G5 weighs `heap-allocated` instead and reads
278,144 bytes against 118,824,960. `erase.chiral:169`'s refusal string never
reaches stderr, because `filter-erasable`
(`lib/lowering/compile-back.chiral:188-191`) discards it and records `sk-extern`,
which prints as `extern does not lower: bover`. And the SPEC's own M2, the loop
bound at `n + 1`, **moves no row**: the routine composites `[0, 4n)` and then
copies `[4n, ld)` through, so an over-run lands either inside the copied
remainder or past the output cell and nothing printed reads it. It is still run,
ungraded, and the gate gained M5 for the direction the output can see.

**What `R3` does not close.** The scale conditions in §3 above stand unchanged:
`memory-discipline/M4` (`E84`) owns `nb-bcat`'s quadratic and
`memory-discipline/M2` (`E82`) owns reclamation. `E200` composites one span at
linear cost and joins nothing.

⚑ **2026-09-18: amended, seven rows added and two counts corrected.** Nine
research findings and one design run had produced requirements this roster did
not name. [[working-discipline]] (`docs/definitions/working-discipline.md:112-119`)
rules that a capability the substrate lacks is a finding and is recorded as a
discovered requirement with the workload that found it and the citation that
proves the absence, and (`:76-81`) that a deferral to an unminted `E#` is a
phantom dependency whose fix is a roster row. `E200`'s design named six owed
rows and said outright that it could not open them
(`docs/arcs/parts/display-calculus-R3.md:423-426`). This amendment opens them.

**What changed.** `R2`, `R10`, `R11`, `R12`, `R13`, `R14` and `R15` are new, in
a new `raster` group, and §3 gained a measured table for them. Requirement 1 was
widened from "a property value" to "a value in this lane" so the coordinate's
denominator and the pixel's encoding sit under the invariant clause that was
already there. Requirement 6 is new and covers the four arithmetic pieces plus
the refusal, on the separation clause of [[goals/display]] consequence 3 and on
the no-float clause `FD-39` states positively. The reclamation requirement sits
on `memory-discipline/M2` and `M4` already, so this amendment opens no row for
it and records the workload instead.

**Two counts corrected, both re-measured before the edit.** `R3`'s cell said
twelve pure `Bytes` externs; `lib/prelude/prelude.chiral:91-104` holds
**eleven**, out of 34 externs in that file. The same cell said "no builder";
`bput-u8` at `lib/lowering/tal/bytes.chiral:610` is one, and the real defect is
that it copies the whole cell per byte. The header said this arc keeps four
letters; it keeps **five**, because `R` arrived with `R3` in 2026-09-06 and the
paragraph was never updated.

**What this amendment did not touch.** `R3`'s state, element and requirement
cells stand as minted at `90cc9f0`. Its seat question stands open at
`records/author-calls.md:72` and nothing was written to that file. No row was
designed, no element minted, no audit run.

⚑ **2026-09-06: `R3` rostered here.** The span primitive was cited by [[arcs/canvas-arc]] and [[goals/own-web]] under a `display-calculus/` id and rostered by nothing. `C9`'s every-state witness is settled as `prog/scriba/`.
### Checkpoint, 2026-09-04, session paused mid-pipeline

`C1C2` cleared every gate except the last. The pipeline stands at:

| stage | artifact | state |
|---|---|---|
| pre-run | `docs/examples/C1C2-style-round-trip.md` | `reviewed`, `f15e688` |
| example audit | same file | PASS, `f15e688` |
| SPEC | `docs/elements/specs/C1C2-style-round-trip-SPEC.md` | `audited`, `bf90ac6` |
| SPEC audit | same file | PASS, every execution claim reproduced |
| **implement** | `lib/`, `prog/`, `tools/test/` | **not started.** The run died at baseline capture on an API rate limit and wrote nothing. Working tree verified clean |

**Resume by re-dispatching the implementation of the SPEC's change plan.** It
needs no re-derivation: the SPEC's author ran steps 1 through 5 off-tree against
scratch copies, compiled with `bin/chirality-bin`, and the SPEC audit reproduced
all five claims independently in its own copy.

The one requirement that governs the run: **the gate root exits 1 on today's
unmodified tree and 42 after the two `parse-sgr` rows land.** Today's tree is
mutant 1. Demonstrate both, in that order, in the commit message. A run that
cannot show that transition has not built this element.

Baselines to capture first and compare after: suite 373 passed 0 failed with 88
compile-only roots and `gate PASSED`, Phase 16 at 38/0, Phase 17 at 20/0,
`registration.sh` at 9/0 with 13 dispatch lines and 20 scripts and 7 PEND. The
suite is memory-hungry on this box and [[status-ledger]] records it left
deliberately unrun once over OOM history, so run it whole at each end and run
only the affected phases between steps.

Two things the SPEC leaves to the implementer, both settled here.
`docs/elements/ledger.md` comes off the step 7 target list, because decision 5
declines to reopen E111's row and routes the residue to `records/gate-audit.md`
beside GA-25. And `banks/render:328` still enumerates the pre-correction tally,
13 plus 6 plus 1 running with J and K unreached, against a header that now reads
21 running and 1 unreached; step 7 makes the paragraph agree with the header.

Nothing in the change enters the compiler's blob, verified twice at 812,351
bytes over 17,335 lines, so it ships under a plain `chirality run` with no
fixpoint. Step 6 lands that as a checked gate row on `render-doc.sh:555-566`,
which is G9 plus its paired mutant M11. Re-verify on the real tree before and
after; if a needle enters the blob, stop and promote nothing.

Open and not blocking: the suite phase number is an author call carried in
[[records/author-calls]], so the gate ships `# not-a-phase:` and claims no suite
conformance. Two gate holes are measured and stated rather than closed. A
reorder of `face-params`' output disagrees on 0 of 14,256 probes while the
emitted bytes differ at character 3, so parameter order is guarded by nothing in
either tier. Narrowing the `bg` upper bound to `-1` drops the asserted set to
1,584 with exit 42 still, because every registry `bg` is `-1`.


The cell-lane pre-run ran 2026-09-04 as `docs/examples/C01-typed-style-value.md`
at `23f6830`, covering C1/C2/C4/C5 as one decision, on U13's precedent for a
run that covers more than one row. **It went `superseded` the same day at
`8928028`, and the replacement is `docs/examples/C1C2-style-round-trip.md`,
covering C1 and C2. It passed its example gate at `f15e688` and is `specced` at
`docs/elements/specs/C1C2-style-round-trip-SPEC.md`.** [[banks/render]] found the reason: C01 proposes
building a typed style value and a total ordered fold, and both are on disk.
`lib/protocol/grid.chiral:12` is `Attrs`, six named `Bool`s over the closed
`Color` sum at `:6`; `apply-one` (`:215`) cases over `Sgr` arm-per-arm with no
default clause and `fold-sgr` (`:232`) folds it in order. E111, `built`.

**The measurement that reshaped the rows.** `face-sgr` (`render.chiral:188`)
emits `ESC[3m` for attribute bit 4 and `parse-sgr` (`grid.chiral:201`) names 23
codes, code 3 among none of them, so 8 of the 16 attribute masks lose italic on
the way back. `fg` 10 through 17 emit `ESC[40m` through `ESC[47m` and decode as
a **background** change. Over `default-faces` the trip closes, because all
eleven entries sit in the sub-domain. So C1 and C2 own a conversion between two
built representations plus the law relating them, and C1C2 states it. C4 and C5
lost their pre-run with C01 and return to `not started`.

The three owed measurements came back, and none killed the design outright,
though one sharpens a claim the arc states more strongly than it holds. The
`(Env, State)` product for the cell lane's two witnesses
(`lib/typing/diag.chiral`, `lib/surface/pretty.chiral`) is **1**: neither
declares an `Env` or a `State` axis, so C9's every-state walk would prove
only that the tool runs; convicting anything needs a bigger product. A
meaningful instance of C9/C8 needs an interactive consumer, out of this
witness's reach. **H1's "one style value drives both `Doc` and `Rendering`" is
narrower than written**: `d-tag`'s field stays `Str`, blocked by a stated
layering rule rather than only by cost. `lib/prelude/doc.chiral:13-16`:
*"`Doc` depends on nothing but Str/List/I64 and is needed by `typing/` (the
diagnostics renderer), by `protocol/` (the display exit) and by `prog/`. That
is 'the base shelf over the extern floor'."* Retyping `d-tag`'s field would
force that shelf to import a `protocol/`-tier type, independent of the BUILD
RULE fixpoint cost. What actually drives both ends is one closed `Role` sum,
projected as a bare string at the frozen `d-tag` seam and carried typed
everywhere `protocol/render` is free to type it (measured: `protocol/render`
sits outside the compiler's blob, `render-doc.chiral:19-24`). Attachment for
the seven tags needs no conflict rule: 35 call sites inside two ordinary
printer functions each choose at most one role by direct code, and nesting is
cascade rather than a race between two attachment functions, so D2 survives
unchanged.

**What this closes and what it does not.** Requirement 4's coverage closes on
the theme side: `Theme = (-> Role Style)` over the closed seven-plus-one-arm
`Role` sum, and an incomplete theme is a compiler refusal. It does not close
on the emission side: nothing stops a stray `d-tag` string literal elsewhere
in the tree from naming a role the closed sum has no arm for, because
`d-tag`'s field stays the open `Str` it is today. `rl-unknown` is the design's
answer, a named and loudly-styled failure state (reverse video in
`compiler-theme`) replacing the silent fabrication at
`lib/protocol/render.chiral:167`. That is an improvement over a fabricated
default, and the compiler's refusal stops at the theme.

**`A1` is the precondition for any C1 gate that can fail.** No `d-tag` in this
tree reaches `lookup-face` today: `protocol/render-doc` has zero importers
under `lib/` and `prog/` and `dg-doc` (`lib/typing/diag.chiral:561`) has zero
consumers outside its own file. Its two importers are both under `tools/`,
so the reach it has is a gate fixture rather than a program a user runs. A gate that walks a theme's coverage over a `Role` sum nothing produces
would pass by looking at nothing, the same failure mode
[[decisions/decision-scope]] names for a subcommand dispatching to a floor the
tree lacks. `A1` closing is what makes a future C1 gate a gate rather than a
formality.

The measured coverage gap reproduces exactly: seven `d-tag` names, eleven
registry faces, zero overlap, three faces with no consumer once the two
computed-name reaches are traced (§ above). The example's `TUI/` grep is
corrected to `lib/ prog/`; the tree carries no `TUI/` directory today.

The design detail, the reference class per row and the full 59-row roster
this arc draws 17 rows from are `.planning/DISPLAY-LAYER-GAP.md`.

**`tools/pack/pack.py` has no adapter for this arc's rows.** It selects a
source adapter by element-id prefix, `E`, `U`, `S` or `N`
(`tools/pack/pack.py:27-37`); this arc's rows carry `C`, `E`, `H` and `A`, and
its own `E` prefix already names a different lane, core self-implementation.
The pre-run assembled its bundle by hand. The same prefix gate blocks `--mark
reviewed` (`tools/pack/pack.py:20`, `:462`, `:548`): the id regex refuses any
prefix outside `E`/`U`/`S`/`N` before `mark_mode` ever runs, so a `C`, `E`
(arc-local) or `H` row has no way to flip `drafted` to `reviewed` even after a
PASS. **This arc's pipeline has no deterministic finish, on a PASS or
otherwise.** `pack.py` is one of the seven Python tools already counted
against enforcement requirement 5's tooling surface
([[records/tooling-classification]] TC-11); [[arcs/enforcement-arc]] carries
the pointer to this gap. This is a fact about running this arc's pipeline.

**Suggested next element:** the SPEC audit of
`docs/elements/specs/C1C2-style-round-trip-SPEC.md` (`pipeline-audit` at SPEC
level), then implementation. The SPEC's change plan was executed off-tree in the
spec run and the gate root reached exit 42, so what the audit grades is citation
truth and gate soundness rather than feasibility. `pack.py` runs neither: its id regex refused
`C1C2` on 2026-09-04 with *"element id must look like E13 / U13 / S19 / N1"*,
which is the same prefix gate this section records below.

**The one experiment is the cell-lane element**, which instantiates C1, C2, C4,
C5 and the `Rendering` half of the seam against the terminal surface. It is one
experiment because it tests four unproven claims at once:

1. the state sum is finite and walkable;
2. attachment by function composes without specificity;
3. a theme's coverage is a compile-time check;
4. one style value drives both `Doc` and `Rendering`.

Three measurements are owed inside its pre-run, and each one can change the
shape:

| owed | why it decides something |
|---|---|
| the size of the `(Env, State)` product for the cell lane | requirement 5 walks it. Nothing has measured either sum, and a walk over an unbounded product cannot be a phase |
| the import closure a typed tag moves | `prelude/doc` is imported at `lib/typing/diag.chiral:58`, `lib/surface/pretty.chiral:36` and `lib/protocol/render-doc.chiral:105`, and two of the three are compiler modules. Retyping `d-tag`'s key owes a fixpoint. Deriving the registry from a role sum outside `doc.chiral` may buy the same property with no compiler change |
| what the seven emitted tags resolve to | requirement 4 checks a theme total against a role sum nobody has authored. The mapping, and the disposition of the three faces with no consumer, has to exist before coverage means anything |

**The staging risk this arc will not surface.** CSS carries specified, computed,
used and actual values because layout feeds back into style: a percentage width
needs the containing block and an `em` needs the parent's resolved size. The
roster assumes a single resolution pass before layout, and that assumption is
probably false. The cell lane cannot test it, because a character grid has no
percentages and no `em`. The row that surfaces it is `B5`, intrinsic sizing, in
the unopened geometry condition of [[goals/display]].
