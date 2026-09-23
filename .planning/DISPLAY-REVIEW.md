# Display layer review sheet

> Generated 2026-09-22 at `c07edd9` by `.planning/build-display-review.py`.
> Regenerating overwrites this file and your comments with it.

**Scope: the display layer only.** Five arcs — the two that declare
[[goals/display]] as their goal, and the three that goal names as serving it —
plus the 61-row roster in `.planning/DISPLAY-LAYER-GAP.md`, which is the agent
tier and is where most of this layer still lives.

Rows are grouped by **kind**, because that is your goal's own axis: *"a design
feature arrives as primitives plus tools that harness them"*
(`docs/goals/display.md:36`), and the arc rosters carry a `kind` cell precisely
so a row has to say which half it is.

## The numbers

| | |
|---|---|
| roster rows across the five arcs | **62** |
| of those, minted | **3** |
| **of those, never minted** | **59** |
| by kind | 25 primitive, 18 law, 10 tool, 5 port, 4 decision |
| by row state | 57 `open`, 2 `designed`, 1 `built`, 1 `specced`, 1 `minted` |
| rows in the gap roster | **61** |
| **gap rows no arc rosters** | **40** — 16 law, 15 primitive, 6 tool, 3 decision |
| goal conditions | **5**, 3 unopened |
| standing author calls touching display | **8** |

## How to use it

Every condition, arc, row and lane has a `**Comment:**` line. Nothing here
pre-closes a question.

`KEEP` / `DROP` / `RESCOPE` / `BUILD NEXT` / `NOT MINE` / `ASK ME AGAIN`.

---

## Part 1 · The goal's conditions

### Condition 1: The calculus

Style is a typed value resolved by total functions, and a property holds in every reachable rendering. [[arcs/display-calculus-arc]].

- **Comment: Vague as shit. Research primitive we want instead of just making a blanket statement about typing everything. it is a given we type everything. There are many clear cut items if the goal is the set of things we have outlined already. Stop leaving it vague.**

### Condition 2: The seam

One document reaches more than one surface, and no theme or render changes silently. [[arcs/terminal-arc]], opened 2026-09-10, whose requirement 3 is the second clause: a draw tier selected by a wire query is the shape in which a render stops changing silently, and rows `TM4`, `TM5` and `TM9` serve it. The terminal is one of the surfaces the first clause counts, and it is the one this tree already draws on. Six of that arc's nine rows are outside what this condition says, and the section below names them.

- **Comment: Still incredibly vague. Ensure outlining of a format for canvas files that fits in with the .manifest line of thinking from other arcs. Those arcs can totally be bound to the completion of this. It would make a lot of sense to.**

### Condition 3: Geometry

A box and a glyph have positions, and hit testing inverts them. **Unopened, and it holds no arc file.** Behind [[decisions/decision-display-numerics]] and the resolution-staging question the calculus arc names.

- **Comment: Dispatch of research and review with author is needed. Ensure this is not a task that can be missed.**

### Condition 4: The pixel

A pixel has a correct value by type. **Unopened, and it holds no arc file.** Behind the span-primitive question, which is [[arcs/native-protocol-arc]] row N6's question about word ops asked over `Bytes`.

- **Comment: Same as previous**

### Condition 5: The frame

A frame is a function of state and time. **Unopened, and it holds no arc file.**

- **Comment: Same as previous**

---

## Part 2 · The arcs, by kind

## Arc `display-calculus-arc`

- **goal** `display`
- **rows** 27 — 25 open, 1 built, 1 designed
- **kinds** 14 primitive, 10 law, 2 tool, 1 port
- **minted** 1 of 27
- **Comment on the arc:**

### `display-calculus` · primitive (14)

**Comment on this kind:**

#### `display-calculus/C1` · primitive · row `open` · **unminted**

- **what** typed property values, invalid states unconstructible. **built, in one tier.** `lib/protocol/grid.chiral:12` is `Attrs`, six named `Bool`s over the closed `Color` sum at `:6`; E111, `built`. The C01 pre-run is `superseded`. The residue is a conversion to the emit side's `Face`, taken over by `docs/examples/C1C2-style-round-trip.md` (pre-run 2026-09-04)
- **group** cascade · **origin** new · **serves req** 1
- **ruling needs**
  - **named in the body of an open author call**: Whether [[arcs/native-document-arc]] merges into [[goals/display]]
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/C4` · primitive · row `open` · **unminted**

- **what** the inherit sum wrapping every property value. not started. Covered by the C01 pre-run, which went `superseded` 2026-09-04; C1C2 does not take this row over. `Color`'s `color-default` (`grid.chiral:6`) is a default and `Face`'s `-1` is a sentinel, so neither is the constructor this row asks for
- **group** cascade · **origin** new · **serves req** 1
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/C5` · primitive · row `open` · **unminted**

- **what** design tokens as typed bindings, and a theme as a root-supplied value. Cashes the `Mode.faces` shard `render.chiral:42-43` already carries and `command-loop.chiral:96` discards. not started. Covered by the C01 pre-run, which went `superseded` 2026-09-04; C1C2 does not take this row over. [[banks/render]] shard V measures the theme value as `absent`
- **group** cascade · **origin** new · **serves req** 4
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/C6` · primitive · row `open` · **unminted**

- **what** the value expression algebra with the unit in the type. not started
- **group** cascade · **origin** new · **serves req** 1
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/C7` · primitive · row `open` · **unminted**

- **what** the environment as a declared ADT. not started
- **group** cascade · **origin** new · **serves req** 4
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/C12` · primitive · row `open` · **unminted**

- **what** shorthands as constructors that cannot reach an unnamed field. not started
- **group** cascade · **origin** new · **serves req** 1
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/E1` · primitive · row `open` · **unminted**

- **what** closed element sums per context, so invalid nesting is unconstructible. not started
- **group** element · **origin** new · **serves req** 1
- **ruling needs**
  - **named in the body of an open author call**: Whether [[arcs/native-document-arc]] merges into [[goals/display]]
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/E2` · primitive · row `open` · **unminted**

- **what** the semantic role as a required constructor field. not started
- **group** element · **origin** new · **serves req** 3
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/R2` · primitive · row `open` · **unminted**

- **what** the pixel encoding as a type: width, alpha state and transfer function, so an encoded sample and a linear one are different types. **Rostered by no arc until 2026-09-18**, existing only at `.planning/DISPLAY-LAYER-GAP.md:195`, which is the agent tier. `FD-37` (`records/findings.md:551`) hands it four corrections and the number it lacked. Unpremultiply precedes linearisation and the two fail to commute, Skia conditioning the elision on exactly that (`records/findings.md:559`), so three premultiplication states exist where the gap file's cell names two. The depth is 10 bits encoded against 12 linear, from CSS Color 4's own precision table (`:557`). Source-over with a coverage mask is integer-reachable at ±1 LSB while no surveyed implementation evaluates a transfer function in integers at any width (`:561`). Wayland's floor is a SHOULD over two 8-bit premultiplied encoded formats and accepts nothing linear and nothing wider (`:563`). Absence: a grep over `lib/` and `prog/` for `premultipl`, `srgb` and `gamma` returns three hits and every one is the type checker's `Gamma` environment or a trace string
- **group** raster · **origin** new · **serves req** 1
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/R3` · primitive · row `built` · `E200` (ledger `built`)

- **what** the span primitive: **eleven** externs touch `Bytes` (`lib/prelude/prelude.chiral:91-104`), re-counted 2026-09-18 against the twelve this cell carried, and `brepeat` (`:100`) is the only one that writes a span. A builder does exist, `bput-u8` (`lib/lowering/tal/bytes.chiral:610`), and it slices the prefix, slices the suffix and concatenates twice, so it copies the whole cell per byte and varying content still has no linear-time path. Cited by [[arcs/canvas-arc]] and [[goals/own-web]] as the wall in front of six raster rows, one text row and all of composite. **Built 2026-09-18** at `30b288b`, `d2b8f05` and `f0de3cc`: `bover` is a twelfth `Bytes` extern, source-over of one premultiplied colour over a destination span through a coverage mask, one `ti-bnew` and one pass. Measured on the arena's own cursor (`lib/ports/process.port:36`): sixteen 1920-pixel spans cost 278,144 bytes against 118,824,960 through `bcat` per pixel, a 427x ratio. Phase 33 green at 19 rows, five mutants each moving exactly its pinned set
- **group** adoption · **origin** new · **serves req** 1
- **E200** `bytes` · MEM · Memory & substrate floor
  - **The coverage composite: one span write, one allocation.** Composite a rectangle of coverage against one colour over a destination span, in one `ti-bnew` and one pass, with the mask and the colour as distinct one-constructor types. The fill half is `brepeat` and needs nothing. `FD-33` measured eleven systems and found these two writes and no third; `FD-37` priced the arithmetic at ±1 LSB inside …
- **ruling needs**
  - **author call `unreviewed`**: Which arc owns `display-calculus/R3`
- **Comment:**

#### `display-calculus/R10` · primitive · row `designed` · **unminted**

- **what** the fixed-point coordinate type, denominator a type parameter. `FD-39` build-list item (1) (`records/findings.md:625`). `FD-34` (`records/findings.md:523`) measures that nothing in the record argues for 1/64 specifically, that FreeType, cairo and Blink each made the denominator a parameter in their own language (`FT_PAD_FLOOR( x, n )`, `CAIRO_FIXED_FRAC_BITS`, `FixedPoint<fractional_bits, Storage>`), and that Gecko's 1/60 argues **against** a power of two on decimal-exactness grounds and still ships. Absence: a grep over `lib/` and `prog/` for `fixed point`, `26.6`, `24.8` and `frac-bits` returns one hit, a comment about Loihi 2 at `prog/unit/encoding.chiral:15`. Discovered by `E200`'s design (`docs/arcs/parts/display-calculus-R3.md:217`), which named it residue and could not open a row
- **group** raster · **origin** new · **serves req** 1, 6
- **ruling needs**
  - **row is `designed` and names no element** — work happened with nothing minted to carry it
- **Comment:**

#### `display-calculus/R11` · primitive · row `open` · **unminted**

- **what** the signed-area cell accumulator: one integer per pixel of the active band, updated by the two integer adds at `FTGRAYS:533`. `FD-39` item (2) (`records/findings.md:625`). It ships in FreeType `grays` and in Skia's analytic AA, two independent shipped proofs in integers. Absence: nothing under `lib/` holds a per-pixel accumulation buffer, and it never writes to the surface, so `E200` cannot deliver it and its design says so (`docs/arcs/parts/display-calculus-R3.md:218`)
- **group** raster · **origin** new · **serves req** 6
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/R12` · primitive · row `open` · **unminted**

- **what** the row prefix sum with a truncating clamp to the coverage byte. `FD-39` item (3) (`records/findings.md:625`). `FTGRAYS` derives coverage as `area >> ( PIXEL_BITS * 2 + 1 - 8 )` and **compensates** its per-scanline division remainders instead of dropping them, so error does not accumulate along a slanted edge (`records/findings.md:611`); that non-accumulation is the property a gate on this row asserts. Absence: no prefix sum and no coverage byte exist in this tree. Discovered by `E200`'s design (`docs/arcs/parts/display-calculus-R3.md:219`)
- **group** raster · **origin** new · **serves req** 6
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/R13` · primitive · row `open` · **unminted**

- **what** integer midpoint subdivision with a shift-derived segment count, over a flattening tolerance re-derived in device pixels each frame. `FD-39` item (4) (`records/findings.md:625`), at `FTGRAYS:1073-1074` where conics split on a second difference of `ONE_PIXEL / 4` and the count is taken as `count = 0x10000U >> shift`. The per-frame re-derivation is the load-bearing half: `FD-39`'s own header (`records/findings.md:583`) measures it as the single mechanism any surveyed renderer uses to keep a border exact while the zoom changes, and Vello states its tolerance as 0.25 device pixels. Absence: no curve type and no subdivision exist under `lib/`. Discovered by `E200`'s design (`docs/arcs/parts/display-calculus-R3.md:220`)
- **group** raster · **origin** new · **serves req** 6
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `display-calculus` · tool (2)

**Comment on this kind:**

#### `display-calculus/C9` · tool · row `open` · **unminted**

- **what** the every-state gate: a property checked in every reachable rendering. not started. ⚑ **The witness is proposed 2026-09-05: [[arcs/canvas-arc]] row `G5`.** A canvas declares a finite `State` because `G4` forbids a document from carrying computation, so behaviour is a closed sum with a total transition table. The cell lane's product measures 1 and a canvas's does not ⚑ **Witness chosen 2026-09-06: `prog/scriba/`.** The cell lane's `(Env, State)` product measures 1, so a walk over it proves only that the phase runs; scriba is the interactive consumer, and the face registry already carries a `manas-cursor` for a navigable cursor row.
- **group** cascade · **origin** new · **serves req** 5
- **ruling needs**
  - **named in the body of an open author call**: Which consumer witnesses the every-state walk (C9/H6)
  - the roster row carries a ⚑ flag
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/H6` · tool · row `open` · **unminted**

- **what** the property walk, run as a suite phase. not started; same witness gap as C9, which it instantiates
- **group** gate · **origin** new · **serves req** 5
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `display-calculus` · law (10)

**Comment on this kind:**

#### `display-calculus/A1` · law · row `open` · **unminted**

- **what** the `Doc` to `Rendering` path is reached. measured 2026-09-04, and re-measured the same day: `grep -rn '"protocol/render-doc"' lib/ prog/` returns zero, and `dg-doc` (`lib/typing/diag.chiral:561`) has zero consumers outside its own file. ⚑ The scope is load-bearing. Two importers live under `tools/`, `tools/test/samples/e158_render.prog:58` and a heredoc probe at `tools/test/render-doc.sh:423`, and Phase 17 (`tools/test/run-tests.sh:268`) builds the first and runs it (`tools/test/render-doc.sh:110`). What this row asks for is a SHIPPING producer, and there is none. No `d-tag` in this tree reaches `lookup-face`. **Precondition for any C1 gate that can fail**
- **group** adoption · **origin** connect · **serves req** 2
- **ruling needs**
  - the roster row carries a ⚑ flag
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/A2` · law · row `open` · **unminted**

- **what** `Mode`'s `faces` reaches the renderer. measured 2026-09-04: `command-loop.chiral:96` discards it. The shard C5 cashes
- **group** adoption · **origin** connect · **serves req** 4
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/C2` · law · row `open` · **unminted**

- **what** the cascade as a total ordered fold. **the fold is built and the law is unstated.** `apply-one` (`grid.chiral:215`) cases totally over `Sgr` and `fold-sgr` (`:232`) folds it in order. No gate feeds `face-sgr`'s bytes into it. The C01 pre-run is `superseded`; `docs/examples/C1C2-style-round-trip.md` (pre-run 2026-09-04) states the round-trip law
- **group** cascade · **origin** new · **serves req** 2
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/C3` · law · row `open` · **unminted**

- **what** attachment by a pure function over the node, no selectors and no specificity. not started; C1's example measures that this witness needs no conflict rule, without settling C3 itself
- **group** cascade · **origin** new · **serves req** 2
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/C8` · law · row `open` · **unminted**

- **what** state-driven style over a finite state sum. not started
- **group** cascade · **origin** new · **serves req** 5
- **ruling needs**
  - **named in the body of an open author call**: Whether [[arcs/native-document-arc]] merges into [[goals/display]]
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/C10` · law · row `open` · **unminted**

- **what** resolution at compile time, as ordinary code the compiler evaluates. not started
- **group** cascade · **origin** new · **serves req** 2
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/C11` · law · row `open` · **unminted**

- **what** declared invalidation: the dependency is the argument list. not started
- **group** cascade · **origin** new · **serves req** 2
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/E3` · law · row `open` · **unminted**

- **what** the accessibility tree derived by a total function. not started
- **group** element · **origin** new · **serves req** 3
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/E4` · law · row `open` · **unminted**

- **what** every document has a text form, and nothing renders from it. not started
- **group** element · **origin** new · **serves req** 3
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `display-calculus/R14` · law · row `open` · **unminted**

- **what** the coverage-span emitter, the loop over `R12` that hands `E200` its spans. `FD-39` item (6) (`records/findings.md:625`) calls it "a loop over (3) and not a new primitive", so it may mint no element at all. `E200`'s design put it in residue because it cannot run until `R12` exists (`docs/arcs/parts/display-calculus-R3.md:222`). The row is here because the deferral needs a name: this is the one item of the build list that joins the arithmetic to the surface, and until it has an id the join is a phantom
- **group** raster · **origin** new · **serves req** 6
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `display-calculus` · port (1)

**Comment on this kind:**

#### `display-calculus/R15` · port · row `open` · **unminted**

- **what** Shape D, the zero-allocation composite straight into a `(Pool n)`, **refused** by `E200`'s design (`docs/arcs/parts/display-calculus-R3.md:296-322`) because it binds the primitive to the port lane and `docs/goals/display.md:43` consequence 3 forbids that, making a glyph atlas, an offscreen layer and a unit test all unreachable without a live pool. It allocates nothing, which against an arena that reclaims nothing (`lib/memory/alloc-growing.chiral:22-24`, over the fixed 67,108,864 bytes at `lib/memory/arena.chiral:29`) is the strongest single property any shape in that design held, and the design keeps it "as the zero-allocation path a frame loop will want" (`docs/arcs/parts/display-calculus-R3.md:329`). That design routed it to [[arcs/native-window-arc]], whose roster carries no such row today; which arc seats it is an author call this amendment does not take
- **group** raster · **origin** new · **serves req** 6
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

## Arc `terminal-arc`

- **goal** `display`
- **rows** 9 — 8 open, 1 specced
- **kinds** 3 decision, 2 tool, 2 primitive, 1 port, 1 law
- **minted** 1 of 9
- **Comment on the arc:**

### `terminal` · primitive (2)

**Comment on this kind:**

#### `terminal/TM4` · primitive · row `specced` · `E128` (ledger `design`)

- **what** the APC handshake: an `ESC _ ? ... ST` query, a reply or a deadline, and the bit that selects the draw tier. Its SPEC is `audited` and triaged NEEDS-REPLAN at `docs/elements/specs/E128-apc-handshake-SPEC.md:13`, 0 of 4 steps executable, every target a `TUI/` path. Implement-gated on `TM9`
- **group** negotiation · **origin** new · **serves req** 3
- **E128** `apc` · FMT · External formats & ABIs
  - APC structured-side-channel **handshake**: the wire negotiation protocol that *sets* `term-structured?`'s bit — an APC query (`ESC _ ? … ST`) the emulator answers with an APC reply, so a dumb terminal stays silent and a timeout ⇒ `false` (aligned with E112's APC transport). Split out of E112 (the codec consumes the `Bool`; this negotiates it) 2026-08-12 by the E112 spec-revision. Its spec …
- **ruling needs**
  - **author call `unreviewed`**: What `E128`'s `(1 t Terminal)` names
  - `E128` is ledger `design` with a SPEC, build not run
- **Comment:**

#### `terminal/TM5` · primitive · row `open` · **unminted**

- **what** the responder: the side that answers `TM4`'s query. `E128`'s SPEC §1 files it as a non-goal and homes it at `T15`, a side-project row whose catalog is absent
- **group** negotiation · **origin** new · **serves req** 3
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `terminal` · tool (2)

**Comment on this kind:**

#### `terminal/TM2` · tool · row `open` · **unminted**

- **what** one checked inventory over the eleven tty and pty crossings: declared, lowered, reached. The measurement `TM1` came out of, made repeatable
- **group** disposal · **origin** connect · **serves req** 1
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `terminal/TM3` · tool · row `open` · **unminted**

- **what** a phase that acquires a pty, wires a child onto it, reads the child's bytes back and exits 42. The first gate in this tree that holds a terminal
- **group** gate · **origin** new · **serves req** 1, 2
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `terminal` · law (1)

**Comment on this kind:**

#### `terminal/TM6` · law · row `open` · **unminted**

- **what** the grid and the parser reach a root outside `prog/scriba/samples/`. Both are built, both are SEEDED, and the four sample roots are reach into a gate
- **group** emulator · **origin** connect · **serves req** 4
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `terminal` · port (1)

**Comment on this kind:**

#### `terminal/TM1` · port · row `open` · **unminted**

- **what** `pty-close` gets a `crossing-wraps` row, so the declared close lowers. Declared `(=> (1 p Pty) Unit)` at `lib/ports/pty.port:38`, called at `lib/capability/session.chiral:54-55`, absent from `lib/lowering/tal/crossing-wraps.chiral`. E107's named residue, still owed
- **group** disposal · **origin** connect · **serves req** 1
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `terminal` · decision (3)

**Comment on this kind:**

#### `terminal/TM7` · decision · row `open` · **unminted**

- **what** where the key decoder lives. `Key`, `KeySeq` and `Keymap` are declared at `lib/ports/tty.port:13-23` on the stated ground that a key is what the crossing yields, while the decode from `read-key`'s bytes sits in `prog/scriba/key-parser.chiral`
- **group** emulator · **origin** connect · **serves req** 4
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `terminal/TM8` · decision · row `open` · **unminted**

- **what** every `→TUI:T#` cite resolves or retires. Nine ledger rows point into `TUI/CATALOG.md` and the directory is absent
- **group** record · **origin** new · **serves req** 5
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `terminal/TM9` · decision · row `open` · **unminted**

- **what** what the signature names, once the supervisor is fixed. ⚑ **The supervisor half is answered, 2026-09-17.** `lib/ports/ports.chiral:55` declares `(module ports/ports (cat C) (alt upper))`, and `grep -rn '(cat C)' lib/ports/` returns that line alone, so the category C supervisor the terminal's B referents route through is `ports/ports` and no second candidate was ever on offer. [[decisions/decision-b-in-type]] at `:26-29` requires every B use to route through a category C supervisor and names none itself, so the vocabulary asks for one and the port tier declares exactly one. **What stays with this row.** A `Terminal` is nothing in this tree, measured under *What the tree already holds*, and `E128`'s `(1 t Terminal)` needs a name over the two referents that section separates: the tty fd, and the `Pty` master at `lib/ports/pty.port:14`. Declaring a module coordinate on `tty.port` and `pty.port` routes them through `ports/ports` and mints no `Terminal`, which is why requirement 6 still has nothing holding it. `.planning/MINI-RUSH-HANDOFF.md:45` refused B-level indirection over the host terminal in 2026-08 and reaches no C-side port, and `canvas/G2` asks for a host that places a display list without owning the surface. **The adoption work belongs elsewhere.** `sys-face/SF20` at `docs/arcs/sys-face-arc.md:197` takes the coordinate across all nine `.port` sheets, measured by `records/lenses/problems.md` PRB-94, and that row is carried as blocked on the placement author call this arc quotes under FLAGs
- **group** port · **origin** new · **serves req** 3, 6
- **ruling needs**
  - **named in the body of an open author call**: Where the port tier's missing module coordinates are repaired
  - **named in the body of an open author call**: What `E128`'s `(1 t Terminal)` names
  - the roster row carries a ⚑ flag
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

## Arc `canvas-arc`

- **goal** `own-web`
- **rows** 16 — 16 open
- **kinds** 5 law, 4 primitive, 4 tool, 2 port, 1 decision
- **minted** 0 of 16
- ⚑ **this arc has never minted anything**
- **Comment on the arc:**

### `canvas` · primitive (4)

**Comment on this kind:**

#### `canvas/G1` · primitive · row `open` · **unminted**

- **what** a canvas is a pure view function, `(-> Env State Node)`. `pretty.chiral` is the working instance over a different value
- **group** canvas · **origin** new · **serves req** 1
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `canvas/G2` · primitive · row `open` · **unminted**

- **what** a canvas does not own its surface; a host places the display list
- **group** canvas · **origin** new · **serves req** 2
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `canvas/G4` · primitive · row `open` · **unminted**

- **what** a document carries no computation: a closed `State` sum with a total transition table, and a closed `Request` sum. **The highest-value invariant in this arc**
- **group** canvas · **origin** new · **serves req** 4
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `canvas/P1` · primitive · row `open` · **unminted**

- **what** a lens is a reader and a view beside the existing pair
- **group** lens · **origin** new · **serves req** 5
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `canvas` · tool (4)

**Comment on this kind:**

#### `canvas/Q2` · tool · row `open` · **unminted**

- **what** a host's closure carries no compiler, counted as `^(end-module "` markers. `binary-split`'s method, `BA-16`
- **group** gate · **origin** connect · **serves req** 2
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `canvas/Q3` · tool · row `open` · **unminted**

- **what** the two-host gate, compared structurally
- **group** gate · **origin** new · **serves req** 3
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `canvas/Q4` · tool · row `open` · **unminted**

- **what** the hostile-document corpus, every refusal named
- **group** gate · **origin** new · **serves req** 4
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `canvas/Q5` · tool · row `open` · **unminted**

- **what** the every-state walk, run as a phase. `display-calculus/H6` instantiated
- **group** gate · **origin** new · **serves req** 4
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `canvas` · law (5)

**Comment on this kind:**

#### `canvas/G5` · law · row `open` · **unminted**

- **what** the declared `State` is the every-state witness. Answers the open call in [[arcs/display-calculus-arc]]
- **group** canvas · **origin** new · **serves req** 4
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `canvas/G6` · law · row `open` · **unminted**

- **what** a canvas asks for nothing on a document's behalf; a forbidden request is refused and the document still renders
- **group** canvas · **origin** new · **serves req** 1
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `canvas/G8` · law · row `open` · **unminted**

- **what** one value, many hosts. Terminal live, the rest behind the two blockers
- **group** canvas · **origin** new · **serves req** 3
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `canvas/P2` · law · row `open` · **unminted**

- **what** a lens re-spells the vocabulary and never extends it
- **group** lens · **origin** new · **serves req** 5
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `canvas/P3` · law · row `open` · **unminted**

- **what** the round trip separates viewing from editing
- **group** lens · **origin** new · **serves req** 5
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `canvas` · port (2)

**Comment on this kind:**

#### `canvas/G3` · port · row `open` · **unminted**

- **what** the port set is the border, and nesting reduces it. **The first `.profile` instance**
- **group** canvas · **origin** new · **serves req** 1
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `canvas/G7` · port · row `open` · **unminted**

- **what** `Grant` at route formation, request honouring and ownership, proving permission and never identity. `E40` custody is the precedent
- **group** canvas · **origin** connect · **serves req** 1
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `canvas` · decision (1)

**Comment on this kind:**

#### `canvas/P4` · decision · row `open` · **unminted**

- **what** lenses come last: a stated ordering, and the reason this arc follows [[arcs/vocabulary-arc]]
- **group** lens · **origin** new · **serves req** 5
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

## Arc `native-window-arc`

- **goal** `native-stack`
- **rows** 6 — 4 open, 1 minted, 1 designed
- **kinds** 3 primitive, 1 law, 1 port, 1 tool
- **minted** 1 of 6
- **Comment on the arc:**

### `native-window` · primitive (3)

**Comment on this kind:**

#### `native-window/W1` · primitive · row `open` · **unminted**

- **what** the xdg-shell vocabulary
- **group** shell · **origin** new · **serves req** 1
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `native-window/W2` · primitive · row `open` · **unminted**

- **what** seat input: pointer and keyboard events decoded
- **group** input · **origin** new · **serves req** 2
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `native-window/W4` · primitive · row `open` · **unminted**

- **what** text on screen, bitmap font first
- **group** text · **origin** new · **serves req** 3
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `native-window` · tool (1)

**Comment on this kind:**

#### `native-window/W6` · tool · row `designed` · **unminted**

- **what** a gate reads `prog/demo/`, which is why W5 went unnoticed while the demos were described as running
- **group** shell · **origin** new · **serves req** 1
- **ruling needs**
  - **row is `designed` and names no element** — work happened with nothing minted to carry it
- **Comment:**

### `native-window` · law (1)

**Comment on this kind:**

#### `native-window/W3` · law · row `open` · **unminted**

- **what** negotiated pool sizes, so resize is honored
- **group** shell · **origin** new · **serves req** 4
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `native-window` · port (1)

**Comment on this kind:**

#### `native-window/W5` · port · row `minted` · `E199` (ledger `design`)

- **what** the fd-passing crossing lowers: `sock-send-fd` has no entry in `crossing-wraps.chiral`, so `wl-client.chiral:201` does not lower and nothing reaches a screen. The server half (`sock-listen`, `sock-accept`, and a `bind` extern that has never existed) is E29's and leaves this row for `W7`, per the E199 design
- **group** shell · **origin** connect · **serves req** 1
- **E199** `sys-net` · SYS · Syscall crossings
  - `sock-send-fd` lowers: the TAL wrapper joining `nb-sys-send-fd` to `SendFdR`, plus its `crossing-wraps` row
- **ruling needs**
  - **`E199` is ledger `design`, no SPEC** — minted, unbuilt, unplanned
- **Comment:**

## Arc `native-document-arc`

- **goal** `native-stack`
- **rows** 4 — 4 open
- **kinds** 2 primitive, 1 law, 1 tool
- **minted** 0 of 4
- ⚑ **this arc has never minted anything**
- **Comment on the arc:**

### `native-document` · primitive (2)

**Comment on this kind:**

#### `native-document/V1` · primitive · row `open` · **unminted**

- **what** the document vocabulary, closed sums per context
- **group** vocabulary · **origin** new · **serves req** 2
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

#### `native-document/V4` · primitive · row `open` · **unminted**

- **what** the render seam into the window
- **group** seam · **origin** new · **serves req** 1
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `native-document` · tool (1)

**Comment on this kind:**

#### `native-document/V3` · tool · row `open` · **unminted**

- **what** the state function, and the every-state gate
- **group** style · **origin** new · **serves req** 3
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

### `native-document` · law (1)

**Comment on this kind:**

#### `native-document/V2` · law · row `open` · **unminted**

- **what** typed style values, and the cascade as a total ordered fold
- **group** style · **origin** new · **serves req** 3
- **ruling needs**
  - `unminted` — no element, no SPEC, nothing scheduled
- **Comment:**

---

## Part 3 · The gap roster, and what no arc carries

`.planning/DISPLAY-LAYER-GAP.md` holds 61 rows across 8 lanes. **40 of them are rostered by no arc**, so they live only in the session tier and nothing in `docs/` knows they exist. They are marked ✗ below.

**Comment on the gap roster as a whole:**

### Lane A · adoption

2 rows, **0 rostered by no arc**.

**Comment on the lane:**

#### A1 · law · ✓ rostered as `display-calculus/A1`

- **goal** The `Doc` to `Rendering` path is reached
- **ours** measured: `grep -rn '"protocol/render-doc"' lib/ prog/` returns zero, and `dg-doc` (`lib/typing/diag.chiral:561`) has zero consumers outside its own file. No `d-tag` reaches `lookup-face`. Precondition for any C1 gate that can fail
- **class** OURS (unreached)
- **Comment:**

#### A2 · law · ✓ rostered as `display-calculus/A2`

- **goal** `Mode`'s `faces` reaches the renderer
- **ours** `command-loop.chiral:96` discards it today. The shard C5 cashes
- **class** OURS (unreached)
- **Comment:**

### Lane B · layout

11 rows, **11 rostered by no arc**.

**Comment on the lane:**

#### B1 · primitive · ✗ **no arc rosters this**

- **goal** The box model
- **ours** one record. The measured edge is a field, so there is no mode switch
- **class** EXTERNAL
- **Comment:**

#### B2 · law · ✗ **no arc rosters this**

- **goal** Normal flow: block and inline
- **ours** block and inline as separate contexts from E1, so a line box is a type. Margin collapsing becomes a stated decision
- **class** EXTERNAL
- **Comment:**

#### B3 · law · ✗ **no arc rosters this**

- **goal** Flex
- **ours** a pure function over the child list. Main and cross axis parameterised so one implementation serves both directions
- **class** EXTERNAL
- **Comment:**

#### B4 · law · ✗ **no arc rosters this**

- **goal** Grid
- **ours** same shape as B3 with a two-dimensional placement pass
- **class** EXTERNAL
- **Comment:**

#### B5 · law · ✗ **no arc rosters this**

- **goal** Intrinsic sizing
- **ours** two pure measures over the tree, which is what `rnd-cols` already is for the cell lane
- **class** OURS (rnd-cols, E174)
- **Comment:**

#### B6 · primitive · ✗ **no arc rosters this**

- **goal** Positioned and anchored elements
- **ours** a positioned child is a constructor carrying its anchor reference. An anchor that does not exist fails the checker
- **class** EXTERNAL
- **Comment:**

#### B7 · primitive · ✗ **no arc rosters this**

- **goal** Scroll containers, overflow, clip
- **ours** three separate constructors. Coupling three effects to one property is the defect
- **class** EXTERNAL
- **Comment:**

#### B8 · primitive · ✗ **no arc rosters this**

- **goal** Fixed-point layout units
- **ours** a `Length` whose scale is in the type, so a mixed-scale arithmetic is a type error
- **class** EXTERNAL
- **Comment:**

#### B9 · law · ✗ **no arc rosters this**

- **goal** Hit testing
- **ours** the inverse of layout, over the same frame tree, pure. One traversal answers which node owns a point
- **class** EXTERNAL
- **Comment:**

#### B10 · decision · ✗ **no arc rosters this**

- **goal** CSS `float`
- **ours** a decision, and the recommendation is to omit it. It exists because 1996 had no other tool
- **class** EXTERNAL
- **Comment:**

#### B11 · decision · ✗ **no arc rosters this**

- **goal** Constraint layout
- **ours** a fork. Dataflow over a pure tree is what B3 and B4 already are, and it is the direction SwiftUI went
- **class** EXTERNAL
- **Comment:**

### Lane C · the style calculus (surface-independent machinery)

12 rows, **0 rostered by no arc**.

**Comment on the lane:**

#### C1 · em \ · ✓ rostered as `display-calculus/C1`

- **goal** Typed property values
- **ours** every property is a sum with invariants. `Length` = px \
- **class** rem \
- **Comment:**

#### C2 · law · ✓ rostered as `display-calculus/C2`

- **goal** The cascade as a total ordered fold
- **ours** one fold over an ordered list, total, with the order decidable from the value. No trie, because there is no string selector to memoise
- **class** OURS (face-join)
- **Comment:**

#### C3 · law · ✓ rostered as `display-calculus/C3`

- **goal** Attachment without selectors
- **ours** style attaches by a pure function over the node. A function returns one style, so specificity has nothing to arbitrate. Selector-shaped helpers are derived, and they compose by a stated law
- **class** EXTERNAL
- **Comment:**

#### C4 · primitive · ✓ rostered as `display-calculus/C4`

- **goal** The inherit sum on every value
- **ours** one wrapper sum around every property type, so "no opinion" is a constructor. `face-join` already does this with `-1` and cannot say it in the type
- **class** OURS
- **Comment:**

#### C5 · primitive · ✓ rostered as `display-calculus/C5`

- **goal** Design tokens as typed bindings
- **ours** a token is a typed binding checked at its definition. A theme is a value a root supplies. `Mode`'s `faces` field (`render.chiral:42-43`) already carries one per mode, discarded today at `command-loop.chiral:96`; C5 cashes that shard. This also evicts `manas-*` from `lib/`
- **class** OURS (Mode.faces, discarded)
- **Comment:**

#### C6 · primitive · ✓ rostered as `display-calculus/C6`

- **goal** The value expression algebra
- **ours** an expression ADT with the unit in the type. A unit mismatch fails the checker
- **class** EXTERNAL
- **Comment:**

#### C7 · primitive · ✓ rostered as `display-calculus/C7`

- **goal** The environment as a declared ADT
- **ours** the style function takes a declared `Env`. Viewport, container, colour scheme, reduced motion are fields of one value
- **class** EXTERNAL
- **Comment:**

#### C8 · law · ✓ rostered as `display-calculus/C8`

- **goal** State-driven style over a finite state sum
- **ours** `style : (-> Env State Node Style)`, the state a declared ADT. This is the JSS capability with the closure replaced by a total function
- **class** EXTERNAL
- **Comment:**

#### C9 · tool · ✓ rostered as `display-calculus/C9`

- **goal** The every-state gate
- **ours** with `State` and `Env` finite, the gate walks the product and checks a property in each: contrast, no overflow, focus visible, no unstyled role. **The genuinely new row, and the one this roadmap has not yet reached a witness for.** The cell lane's `(Env, State)` product measures 1, so it cannot exercise the walk; [[arcs/display-calculus-arc]]'s resume state carries the open …
- **class** EXTERNAL
- **Comment:**

#### C10 · law · ✓ rostered as `display-calculus/C10`

- **goal** Resolution at compile time
- **ours** style resolution is ordinary code the compiler already evaluates. Nothing new is needed for the property Slint advertises
- **class** EXTERNAL
- **Comment:**

#### C11 · law · ✓ rostered as `display-calculus/C11`

- **goal** Declared invalidation
- **ours** the dependency is the argument list of a pure function. What a style reads is what invalidates it, by construction
- **class** EXTERNAL
- **Comment:**

#### C12 · primitive · ✓ rostered as `display-calculus/C12`

- **goal** Shorthands as constructors
- **ours** a shorthand is a function returning a value of the property record type. It cannot reach a field it does not name
- **class** EXTERNAL
- **Comment:**

### Lane E · the element vocabulary

4 rows, **0 rostered by no arc**.

**Comment on the lane:**

#### E1 · primitive · ✓ rostered as `display-calculus/E1`

- **goal** Closed element sums per context
- **ours** constructor sets split by context (block, inline, row, cell). Invalid nesting is unconstructible, which retires the validator
- **class** OURS (matcher.chiral's Cls idiom)
- **Comment:**

#### E2 · primitive · ✓ rostered as `display-calculus/E2`

- **goal** Semantic role as a required field
- **ours** the role is a required constructor field. An unlabelled interactive element has no representation
- **class** EXTERNAL
- **Comment:**

#### E3 · law · ✓ rostered as `display-calculus/E3`

- **goal** The accessibility tree derived
- **ours** the tree is a total function of the document, because the role is already a field. No second tree to keep in sync
- **class** EXTERNAL
- **Comment:**

#### E4 · law · ✓ rostered as `display-calculus/E4`

- **goal** Every document has a text form
- **ours** `print` is mandatory per type and nothing renders from it. Save, diff and grep work; there is one truth
- **class** OURS (U19)
- **Comment:**

### Lane H · harness

9 rows, **8 rostered by no arc**.

**Comment on the lane:**

#### H1 · law · ✗ **no arc rosters this**

- **goal** One document, many surfaces
- **ours** the same split, made structural. The style calculus resolves; the surface consumes a display list. A surface that cannot express a constructor refuses it at the type
- **class** EXTERNAL
- **Comment:**

#### H2 · decision · ✗ **no arc rosters this**

- **goal** The view and widget split
- **ours** `view : (-> State Node)` with the diff over an immutable tree. Chirality is strict and linear, so the retained side holds no hidden mutable state
- **class** EXTERNAL
- **Comment:**

#### H3 · tool · ✗ **no arc rosters this**

- **goal** Profile-enforced layering
- **ours** a profile is a module set over a frozen port set, gated by `lib/typing/totality-check.chiral:130`. Style code that reaches for a socket does not compile. **The requirement the author stated, made checkable**
- **class** OURS
- **Comment:**

#### H4 · tool · ✗ **no arc rosters this**

- **goal** The theme coverage gate
- **ours** a theme is a total function from the role sum. The gate is the coverage check the compiler already runs on any closed sum, so an incomplete theme fails to compile
- **class** OURS
- **Comment:**

#### H5 · tool · ✗ **no arc rosters this**

- **goal** The golden render gate
- **ours** a document renders to a display list, and a display list is a value. Compare structurally with no fuzz factor, which is what `prog/prapanca/contract/golden.chiral` already does for run manifests
- **class** OURS
- **Comment:**

#### H6 · tool · ✓ rostered as `display-calculus/H6`

- **goal** The property walk
- **ours** C9's walk, run as a phase. Contrast, overflow, focus visibility and unstyled roles checked in every reachable `(Env, State)` pair
- **class** EXTERNAL
- **Comment:**

#### H7 · tool · ✗ **no arc rosters this**

- **goal** The display-list differ
- **ours** one pure function over two display lists, returning the changed region. Damage tracking and the golden gate are the same function with different consumers
- **class** EXTERNAL
- **Comment:**

#### H8 · tool · ✗ **no arc rosters this**

- **goal** The interface scanner
- **ours** a tool that reads an interface description and emits chirality: a closed sum per interface, encode and decode. Direction-agnostic, so a compositor gets the mirror role for free. Belongs to enforcement requirement 5's tooling surface
- **class** EXTERNAL
- **Comment:**

#### H9 · tool · ✗ **no arc rosters this**

- **goal** The style inspector
- **ours** provenance is a value. The inspector is a pure function from a node to the list of functions that contributed each property, exact rather than reconstructed
- **class** EXTERNAL
- **Comment:**

### Lane R · raster and paint

9 rows, **7 rostered by no arc**.

**Comment on the lane:**

#### R1 · primitive · ✗ **no arc rosters this**

- **goal** Colour as a typed value
- **ours** a colour is a sum over spaces with a gamut invariant. Mixing carries the space it mixed in, so a perceptual mix and an sRGB mix are different values
- **class** OURS (three bare I64)
- **Comment:**

#### R2 · primitive · ✓ rostered as `display-calculus/R2`

- **goal** Gamma-correct compositing
- **ours** the encoding is in the type. A premultiplied linear sample and an sRGB sample cannot be added, because they are different types. **The single highest-value invariant in this lane**
- **class** EXTERNAL
- **Comment:**

#### R3 · port · ✓ rostered as `display-calculus/R3`

- **goal** The span primitive
- **ours** **the measured wall.** The pure `Bytes` surface is twelve externs, with no `pack-u8`, no builder, no fill-with-function. `brepeat` makes a solid span in one call; varying content has no linear-time path. Gates R4 through R9, T5 and all of Z
- **class** OURS
- **Comment:**

#### R4 · law · ✗ **no arc rosters this**

- **goal** Paths, fills, strokes
- **ours** a path is a value, filling is a pure scanline function, and the write is one `pool-write` per row
- **class** EXTERNAL
- **Comment:**

#### R5 · primitive · ✗ **no arc rosters this**

- **goal** Gradients
- **ours** one constructor per gradient kind, interpolating in the colour space R1 names
- **class** EXTERNAL
- **Comment:**

#### R6 · primitive · ✗ **no arc rosters this**

- **goal** Clipping, including rounded
- **ours** the clip is a constructor wrapping its child, so nesting is structural
- **class** EXTERNAL
- **Comment:**

#### R7 · primitive · ✗ **no arc rosters this**

- **goal** Shadow and blur
- **ours** a shadow is a constructor with a list of offsets. A property that secretly repaints is the defect
- **class** EXTERNAL
- **Comment:**

#### R8 · primitive · ✗ **no arc rosters this**

- **goal** Blend modes
- **ours** a blend is a constructor taking two children. The backdrop is an argument, so "what does this blend against" has one answer
- **class** EXTERNAL
- **Comment:**

#### R9 · law · ✗ **no arc rosters this**

- **goal** Images
- **ours** decode is pure over `Bytes`. PNG needs inflate, which is its own row
- **class** EXTERNAL
- **Comment:**

### Lane T · text

6 rows, **6 rostered by no arc**.

**Comment on the lane:**

#### T1 · primitive · ✗ **no arc rosters this**

- **goal** Font vocabulary and fallback
- **ours** the font set is a declared value of the profile. Fallback is a total function over a closed list
- **class** EXTERNAL
- **Comment:**

#### T2 · law · ✗ **no arc rosters this**

- **goal** Shaping
- **ours** out of scope for the floor. A bitmap font needs no shaper. Complex scripts are a stated limit until this row opens
- **class** EXTERNAL
- **Comment:**

#### T3 · primitive · ✗ **no arc rosters this**

- **goal** Line breaking, UAX #14
- **ours** the pair table is a value, and the class of a codepoint is a total function. `utf8.chiral` already decodes with U+FFFD resync
- **class** OURS (partial)
- **Comment:**

#### T4 · law · ✗ **no arc rosters this**

- **goal** Bidi, UAX #9
- **ours** a fixpoint stated as such, with the entanglement in the type instead of in a comment
- **class** EXTERNAL
- **Comment:**

#### T5 · law · ✗ **no arc rosters this**

- **goal** Glyph rasterization
- **ours** a bitmap font is the floor and it is a table. Outline rasterization is its own row and needs R3
- **class** EXTERNAL
- **Comment:**

#### T6 · law · ✗ **no arc rosters this**

- **goal** Paragraph layout
- **ours** pure functions over the shaped run list. Nothing here crosses the membrane
- **class** EXTERNAL
- **Comment:**

### Lane Z · composite

8 rows, **8 rostered by no arc**.

**Comment on the lane:**

#### Z1 · primitive · ✗ **no arc rosters this**

- **goal** The display list as a closed sum
- **ours** one closed sum. **This is the harness seam**: the cell lane, a shm surface, a wire document and a compositor scene are four consumers of one value
- **class** EXTERNAL
- **Comment:**

#### Z2 · primitive · ✗ **no arc rosters this**

- **goal** Layers and explicit stacking
- **ours** a layer is a constructor. Paint order is a total function of the tree with no implicit promotion
- **class** EXTERNAL
- **Comment:**

#### Z3 · primitive · ✗ **no arc rosters this**

- **goal** Transforms
- **ours** a matrix of fixed-point values. The 3D cases are separate constructors, so a 2D-only backend refuses them at the type
- **class** EXTERNAL
- **Comment:**

#### Z4 · law · ✗ **no arc rosters this**

- **goal** Damage tracking
- **ours** damage is a pure function of two display lists. The diff is a value, and the same function serves a compositor later
- **class** EXTERNAL
- **Comment:**

#### Z5 · law · ✗ **no arc rosters this**

- **goal** Animation as a function of time
- **ours** a frame is `(-> Env State Time DisplayList)`. Deterministic, replayable, and testable at any `t`, which no stateful animation system can offer
- **class** EXTERNAL
- **Comment:**

#### Z6 · primitive · ✗ **no arc rosters this**

- **goal** HiDPI and fractional scaling
- **ours** the scale is a field of `Env`, so it is an input to style and layout rather than a correction applied afterwards
- **class** EXTERNAL
- **Comment:**

#### Z7 · law · ✗ **no arc rosters this**

- **goal** 3D geometry and projection
- **ours** the pipeline is a pure fold. The perspective divide is the one place fixed point needs care
- **class** EXTERNAL
- **Comment:**

#### Z8 · law · ✗ **no arc rosters this**

- **goal** Shading as a checked pure function
- **ours** a shader is an ordinary `->` function. The membrane makes "a shader performs no I/O" a checked property of ordinary code. Same shape as the constant-time judgment on `native-protocol/N5`. **The second genuinely new row**
- **class** EXTERNAL
- **Comment:**

---

## Part 4 · Author calls touching display

8 of the standing calls mention this layer.

**Comment on the call queue:**

- `unreviewed` — Whether [[arcs/native-document-arc]] merges into [[goals/display]]
  - **Comment:**
- `unreviewed` — Which consumer witnesses the every-state walk (C9/H6)
  - **Comment:**
- `unreviewed` — Which arc owns the fd-passing crossing
  - **Comment:**
- `unreviewed` — Which arc owns `display-calculus/R3`
  - **Comment:**
- `unreviewed` — Whether [[arcs/native-document-arc]] closes into [[goals/own-web]]
  - **Comment:**
- `unreviewed` — E184's six unruled spelling decisions
  - **Comment:**
- `unreviewed` — Where the port tier's missing module coordinates are repaired
  - **Comment:**
- `unreviewed` — What `E128`'s `(1 t Terminal)` names
  - **Comment:**

⚑ **One display call is not in that list and cannot be**, because no register
carries it: the `Fix d` × `Fix d` question that blocks `display-calculus/R10`
from minting lives only in `docs/arcs/parts/display-calculus-R10.md:280`. A
design run may not write to `records/`, so check AK cannot see it.

- **Comment:**
