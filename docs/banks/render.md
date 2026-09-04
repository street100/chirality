---
node: banks/render
layer: bank
tier: depth
related: [banks/INDEX, banks/text, banks/module, banks/memory, banks/port, banks/capability, banks/verification, banks/erasure, goals/display, arcs/display-calculus-arc, decisions/decision-display-numerics, decisions/decision-work-ids, records/author-calls, records/baseline-alignment, design-principles, status-ledger, index]
status: current
updated: 2026-09-04
---

# Bank: render

> The monolith this refracts: **the renderer / the style engine / the display
> list / the terminal emulator**. Four subsystems elsewhere; here, twenty-four
> shards across thirteen homes, twenty of them running, two written and
> unreached, two absent. The twenty-fourth is in the tool tier and was found by
> the C1C2 example on 2026-09-04.

**Why this bank exists, and the cost is measured.** The C01 EXAMPLE audit at
`d0fc26a` caught a drafted worked example proposing *"a theme is a value the
root supplies"* as new machinery. `lib/protocol/render.chiral:42-43` already
declares the field, `prog/scriba/init-loader.chiral:614-616` fills it three
times, and `prog/scriba/command-loop.chiral:96` destructures `((mode r faces))`
and drops `faces` on the floor. [[banks/INDEX]] states the rule that catches
this class and there was no bank here to read. This is the bank that would have
caught it.

**The measurement, 2026-09-04**, in the working tree at `7168ae7`.

| measured | figure | command |
|---|---|---|
| `(r-face` applications | **26** tree-wide, **18** under `prog/scriba/` | `grep -rn '(r-face' lib/ prog/ \| grep -v ':[0-9]*: *;'` |
| `r-face` sites naming a face by literal | **10**, over **6** distinct names | `grep -rno '(r-face "' lib/ prog/` |
| `(d-tag "` constructions | **35**, over **7** distinct keys, in **2** files | `grep -rno '(d-tag "[a-z-]*"' lib/ prog/` |
| importers of `protocol/render` | **18** | `grep -rl '(import "protocol/render")' lib/ prog/` |
| importers of `protocol/render-doc` | **0** | the same, with `render-doc` |
| importers of `prelude/doc` | **3**, two of them compiler modules | the same, with `prelude/doc` |
| files under `lib/protocol/` carrying a `(module …)` coordinate | **0 of 11**, against **9 of 9** under `lib/prelude/` | `grep -l '^(module ' lib/protocol/*.chiral` |
| hits for `theme`, `specificity` in `lib/` and `prog/` | **0** and **0** | `grep -rni` |

The seven keys and the six names reproduce the arc's coverage table exactly:
`diag-head` `diag-site` `term-kw` `term-lit` `term-name` `term-qty` `term-var`
against `comment` `keyword` `manas-header` `manas-ok` `manas-bad` `manas-field`,
zero overlap.

**Build state.** Grounded in `records/conformance-map.md` and [[status-ledger]].
⚑ **The map has a row for three of the shards below and is silent on the rest.**
It classifies 82 rows over E-numbers reaching E67 plus E166, against a catalog
of 180, so every shard keyed to E99, E111, E112, E120, E158, E174, E175, E177 or
E181 has no map row and its state beside it is measured against the tree with
the command given. Citing the map for those would be a gate that cannot fail,
which is the shape [[decisions/decision-scope]] names.

| shard | map row | verdict |
|---|---|---|
| the term printer, shard A's first client | *Pretty-printer (display)*, E14 | `CONFORMS`, *"Built; no judgment path consults it"* |
| the wire, shard T | *Wayland wire codec + niri IPC*, E35, E36 | `CONFORMS`, *"Demo-scoped but complete"* |
| the writable region under shard S | *Memory discipline: linear (Pool, mem-put-checked)*, E22 | `CONFORMS` |

---

## 1. The concept in chirality

**Rendering IS** a total function from a typed value to one surface's own form,
with style resolved during the walk. Five of them exist and each names its
surface in its own signature:

| exit | home | produces |
|---|---|---|
| `doc->str` | `lib/prelude/doc.chiral:190` | characters |
| `doc->rendering` | `lib/protocol/render-doc.chiral:254` | the screen tree |
| `render-to-ansi` | `lib/protocol/render.chiral:718` | a terminal's byte stream |
| `draw-rows` | `prog/demo/sprites.chiral:66` | ARGB8888 pixels in a shared pool |
| `wenc` | `lib/protocol/wire.chiral:13` | a compositor's wire messages |

**The width IS an argument to the exit.** `doc.chiral:10` states it and every
exit above obeys it: no constructor in `Doc` or in `Rendering` carries a width
field. That single rule is what lets one value reach five surfaces.

**Rendering IS NOT one pipeline with a screen at the end.** The five exits share
no code below the value they consume. Two of them never meet: the `Doc` half and
the `Rendering` half are joined by exactly one file, and that file has zero
importers (shard K).

**The typed style value IS NOT missing.** It exists twice, in two tiers, and the
two have never met. `Face` (`render.chiral:37-38`) is a name, two bare `I64`
colour indices and an `I64` attribute bitmask, so every invalid state is
constructible. `Attrs` (`lib/protocol/grid.chiral:12`) is six named `Bool`s over
a closed three-arm `Color` sum, so the invalid states have no representation.
Both are built. Both run. Nothing relates them.

**Rendering IS NOT the document.** [[banks/text]] §1 carries that line and the
U13 seam behind it. Not restated here.

The four monoliths this gets confused with, and what each actually is:

| you reach for | it is here |
|---|---|
| a renderer | five exits, shards A, B, K, L, S, T. One value, one function each |
| a style engine | shards C through J, plus X in the tool tier. Nine parts, all nine on disk, one unreached, and the ninth is in awk |
| a display list | shard B, `Rendering`, nine constructors, 18 importers |
| a terminal emulator | shards P and Q, a linear cell grid and a total escape parser, both built |

---

## 2. The refraction: the shards, their homes, their build-state

**Three states, and they are different things.** `runs` means present and
reached by a shipping program. `unreached` means present on disk with no caller,
which is the class [[arcs/enforcement-arc]] records for E17 and which reads as
done to anyone who greps for the name. `absent` means nothing in the tree spells
it. Reach that comes only from a root under `prog/scriba/samples/` is reach into
a gate, and every such row says so.

| | shard | home | state |
|---|---|---|---|
| **A** | **the layout algebra**: `Doc`, six constructors, and Lindig's strict worklist renderer | `lib/prelude/doc.chiral` (226 L), `Doc` at `:77`, `doc-best` at `:140` | **runs.** E158, `built`. Three importers, two of them compiler modules (`lib/typing/diag.chiral`, `lib/surface/pretty.chiral`). Map is silent |
| **B** | **the display vocabulary**: `Rendering`, nine constructors | `lib/protocol/render.chiral`, `Rendering` at `:7` | **runs.** E174 added the ninth (`r-row`); `built`. 18 importers. Map is silent |
| **C** | **the style value, untyped**: a name, two SGR indices, an attribute bitmask | `render.chiral:37-38` | **runs.** Zero invariants: `(face "x" 99 -4 255)` typechecks. Map is silent |
| **D** | **the style value, typed**: `Attrs`, six named `Bool`s over a closed `Color` sum (`color-default` \| `color-indexed` \| `color-rgb`) | `lib/protocol/grid.chiral`, `Color` at `:6`, `Attrs` at `:12` | **runs, in one tier only.** E111, `built`. Reached by `lib/protocol/vt-parser.chiral` and by four sample roots. **No consumer in `render.chiral`, and no relation to C.** Map is silent |
| **E** | **the registry**: `default-faces`, a hardcoded assoc list of 11 entries | `render.chiral:148` | **runs.** Six of the 11 are one application's palette, spelled `manas-*`, living under `lib/`. Map is silent |
| **F** | **the resolution**: `lookup-face` | `render.chiral:164`, miss arm at `:167` | **runs, and fabricates on a miss.** `:167` returns `(face name -1 -1 0)` and reports nothing. All 35 emitted `d-tag` keys resolve through it. Map is silent |
| **G** | **the cascade, emit side**: `face-join` | `render.chiral:366`, sole caller at `:773` | **runs with no stated law and no check.** Attributes accumulate by `bor`, the inner's stated colour wins, a negative colour inherits. Its own comment calls itself *"a DESCRIPTION of what the emitter ALREADY DOES"*. Map is silent |
| **H** | **the cascade, decode side**: `apply-one` over the `Sgr` boundary sum, folded by `fold-sgr` | `grid.chiral`, `Sgr` at `:35`, `parse-sgr` at `:201`, `apply-one` at `:215`, `fold-sgr` at `:232` | **runs.** A total ordered fold over a typed style value, arm-per-arm with no `_`. E111, `built`. This is requirement 2 of [[arcs/display-calculus-arc]], already built, facing the other way. Map is silent |
| **I** | **the attachment**: `d-tag`, a semantic role at zero width and zero text | `doc.chiral:83` | **runs.** 35 constructions, 21 in `lib/surface/pretty.chiral` and 14 in `lib/typing/diag.chiral`. E181, `BUILT 2026-09-01`. Map is silent |
| **J** | **the theme's domain**: `Mode`'s `faces` field, the face set a renderer declares it emits | `render.chiral:42-43`, filled at `init-loader.chiral:614-616` | **written and unreached, at two seams.** `command-loop.chiral:96` binds `faces` and never uses it. Below that, `render-to-ansi`'s signature (`render.chiral:103`) takes no registry, and its `r-face` arm names the `lib/` table directly (`render.chiral:771`). Threading the first seam reaches nothing while the second stands. Map is silent |
| **K** | **the `Doc` to `Rendering` bridge**: `doc->rendering`, tag stack, segment list, tree builder | `lib/protocol/render-doc.chiral` (258 L), `doc->rendering` at `:254` | **written and unreached. Zero importers**, measured. Its own header at `:19-24` says so and gives the reason: `prelude/doc` sits inside the compiler's blob and `protocol/render` sits outside it, so this file changes no blob. E158 commit 4. Map is silent |
| **L** | **the emission**: the tree walk, the SGR builder, the ambient restore | `render.chiral`, `sgr-code` at `:180`, `face-sgr` at `:188`, `face-join` at `:366`, `rnd-face-plain` at `:382`, `rnd-restore` at `:394`, `render-to-ansi` at `:718` | **runs.** E175, `Built 2026-08-31`. The invariant E175 holds is the screen rather than the byte stream, stated in the source. Map is silent |
| **M** | **the advance width** | `render.chiral`, `str-cols` at `:448` and `rnd-cols` at `:526`; `Cell`'s `width` field at `grid.chiral:18` | **runs, and both slots are hardwired to one column per codepoint.** `str-cols` counts codepoints; `put-cell` (`grid.chiral:169`) writes a literal `1` into every cell it stamps. E174 built the seam, E177 owns the table and is `Not built`. Map is silent |
| **N** | **the addressable node**: `block-id`, an FNV-1a-64 content hash rendered as 16 hex characters | `lib/protocol/apc.chiral:141`, re-verified on decode at `:229` | **runs under one fixture root only** (`prog/scriba/samples/t6_apc_roundtrip.prog`). Addresses `r-section` and `r-hole`, two of nine constructors; every other arm gets `""`. E112, `built`. Map is silent |
| **O** | **the sidechannel codec**: `Rendering` to a printable APC envelope and back | `apc.chiral` (286 L), `enc-frame` at `:120`, `dec-frame` at `:285` | **runs under fixture roots only.** Two importers: `vt-parser.chiral` and one sample root. All nine `Rendering` arms covered. Errors are values (`p-err`). E112, `built`. ⚑ The ledger row for E112 still says *"all six `Rendering` ctors"* and cites `TUI/apc.chiral`, a path that no longer exists |
| **P** | **the terminal grid**: `(Grid n)`, a pool-backed linear cell region with a 16-byte `Cell` codec | `grid.chiral`, `Grid` at `:28`, `cell->bytes` at `:91`, `bytes->cell` at `:111` | **runs under fixture roots only.** Five importers: `vt-parser.chiral` and four sample roots. E111, `built`. Map is silent |
| **Q** | **the escape-sequence parser**: `PState`, `Action`, the C0 and CSI executors | `lib/protocol/vt-parser.chiral` (402 L), `PState` at `:11`, `Action` at `:25`, `feed` at `:390` | **runs under fixture roots only.** Two importers, both sample roots. Map is silent |
| **R** | **the codepoint**: a total UTF-8 decoder with U+FFFD resync on any malformed byte | `lib/protocol/utf8.chiral` (105 L), `utf8-decode1` at `:46`, `decode-utf8` at `:104` | **runs.** Two importers, `render.chiral` and `vt-parser.chiral`. `str-cols` is built on it. Map is silent |
| **S** | **the pixel surface**: characters to ARGB8888, written a row at a time through a linear pool | `prog/demo/sprites.chiral` (76 L), `px` at `:10`, `draw-rows` at `:66`; the region is `Pool` (`lib/ports/pool.port:13`) | **runs.** Three demo roots import it. The map's E22 row carries the region as `CONFORMS`. The colour spelling here is three 8-bit channels, unrelated to C and unrelated to D |
| **T** | **the wire**: the Wayland message codec, no libwayland | `lib/protocol/wire.chiral` (96 L), `wenc` at `:13`, `wstr` at `:20`, `wsplit1` at `:33` | **runs.** Four demo roots. Map: `CONFORMS` under E35, E36, *"Demo-scoped but complete"* |
| **U** | **the surface port**: the crossing every terminal byte leaves through | `lib/ports/stdio.port`, `put` | **runs, and it is `Str`.** Nothing at the crossing distinguishes a control sequence from content. Shard L emits SGR through it. Map is silent |
| **V** | **the theme value**: a colour set a root supplies, distinct from the library's own | nowhere | **absent.** Zero hits for `theme` in `lib/` and `prog/`. J carries the shape of its *domain*; nothing carries its value. `display-calculus/C5` |
| **W** | **the every-state walk**: a property checked in every reachable rendering | nowhere | **absent, and its witness is unchosen.** The cell lane's `(Env, State)` product measures 1. `display-calculus/C9` and `H6`; the open call is in [[records/author-calls]] |
| **X** | **the style model in the tool tier**: an `attr[]` set plus single-valued `fg` and `bg` registers, a third representation of the value C and D each hold | `tools/test/face.sh`, `SGR_AWK` at `:176-223`, `sgr_screen` at `:225` | **runs, as Phase 16** (`run-tests.sh:252`), gating E175. It is the one place the emitter's SGR bytes are decoded today, and it disagrees with shard H in three classes, which is §3. Found by `docs/examples/C1C2-style-round-trip.md` 2026-09-04. Map is silent |

⚑ **An unlettered shard, unreached and superseded.**
`prog/scriba/render-str.chiral` is a second `Str`-to-`Rendering` renderer with
zero importers. `default-str-renderer` (`init-loader.chiral:68`) does the job and
is the one wired into the mode table. Recorded here and given no letter, because
a duplicate with no caller refracts nothing.

⚑ **The mode face lists carry no colour the library does not.** All three
(`init-loader.chiral:149`, `:152`, `:243`) are built by calling `lookup-face` on
`default-faces` with names already in the `lib/` table. So shard J today is a
projection of shard E, and reaching it would change no pixel. That is a fact
about what `A2` closing buys, and it sharpens the row rather than refuting it.

⚑ **The whole display tier sits outside the module datasheet.** Zero of the
eleven files under `lib/protocol/` carry a `(module …)` coordinate; nine of nine
under `lib/prelude/` do. `render-doc.chiral:108` records the choice and its own
count is stale at eight.

---

## 3. Cross-cuts: where a render shard IS another concept's shard

### The fork under [[banks/text]] shard G, and it has three arms

The quote is verified verbatim at **`docs/banks/text.md:75-77`**. ⚑ It sits in
that bank's **H** bullet, `d-tag`'s. Its **G** bullet is separate, at `:69-74`.
H is the vehicle; G is the address that would ride it, and G's own §2 row
(`:53`) reads `owed; render half built · UNASSIGNED`.

`.planning/DISPLAY-LAYER-GAP.md` D10 states the fork as two arms: either `Role`
gets a constructor an address can occupy, or shard G's open keyspace stops
existing once `display-calculus/C1` lands. Measured against the tree, the fork is
narrower in one direction and wider in another.

**Narrower.** `d-tag`'s field stays `Str` under C1. The arc's own resume state
carries the reason and `doc.chiral:13-16` is the authority: `Doc` depends on
`Str`/`List`/`I64` and is needed by `typing/`, so retyping the field forces the
base shelf to import a `protocol/`-tier type. So the keyspace at the seam
survives C1 whatever `Role` looks like. What C1 closes is the theme's *domain*,
and an address-bearing key then resolves to `rl-unknown` rather than to
`lookup-face`'s silent fabrication. The address still constructs, still occupies
zero width, still survives `doc->str`.

**Wider.** The thing that changes is that an address becomes *loud*. `rl-unknown`
is designed as a named and reverse-video failure state. Every citation tag in a
rendered buffer would paint. So the two shards coexist on one condition: `Role`
needs an arm that resolves to a zero-width unstyled value, distinct from
`rl-unknown`'s loud arm. Without it shard G is unusable in practice rather than
unrepresentable, which is the harder failure to notice.

**The third arm D10 does not name: the address already exists, in this bank's
own tier.** Shard N's `block-id` is a stable name attached to a rendered node,
re-verified on decode, on a channel a non-supporting terminal discards. That is
shard G's stated purpose, built. ⚑ **And it does not serve shard G's stated
need.** `block-id` is a *content* hash (`apc.chiral:139-141`: section hashes
title plus body, hole hashes its label), so it is stable across a re-render and
changes on the first edit. [[records/baseline-alignment]] BA-20 and BA-21 need an
address that survives an edit, which is the opposite property. Arm 3 is therefore
a real home with the wrong key function, and costing it means costing a
non-content key for `block-id`. Adopting it as it stands buys nothing.

**The fork, stated for the SPEC to settle.**

| arm | what it costs | what it leaves open |
|---|---|---|
| 1. `Role` gains a zero-width address arm | one constructor, and `rl-unknown` stops being the only escape hatch | whether a role sum should carry a non-role |
| 2. `Role` closes with no address arm | nothing at C1 time | every address tag paints reverse video; shard G loses its vehicle in practice |
| 3. the address moves to shard N | a non-content key for `block-id`, and reach past one fixture root | `block-id` covers two of nine `Rendering` arms, and nothing on the `Doc` side |

### Two style values, two cascades, two width slots

- **C and D are the same shard in two tiers, and only D is typed.** `Attrs` and
  `Color` (`grid.chiral:6`, `:12`) are the property-values-carry-their-invariant
  requirement, already built, already reached. Any claim that this tree lacks a
  typed style value is a phantom. What is true is narrower: the *emit* side has
  none, and the two tiers have no conversion between them.
- **G and H are one cascade seen from both ends.** `face-join` folds a face onto
  an ambient going out; `apply-one` folds an `Sgr` onto an `Attrs` coming in. H
  is total, typed and arm-per-arm; G is a bitwise `bor` with its rule written in
  a comment. The round trip does not close: `face-sgr` (`render.chiral:188`)
  emits from a bitmask and `parse-sgr` (`grid.chiral:201`) parses into a sum, and
  no gate feeds one into the other. That round trip is the cheapest law
  `display-calculus/C2` could assert, and both halves already exist.
- **M's width slot exists twice and is filled once, with the wrong function.**
  `str-cols` counts codepoints, `Cell` has a `width` field, and `put-cell` writes
  a literal `1`. E177 is one table serving both.
- **X is a third model of the same value, and the gate disagrees with the code
  it gates.** `SGR_AWK` (`tools/test/face.sh:176-223`) reduces the emitter's
  bytes in awk, and three classes separate it from `apply-one`. Its final arm is
  `else { attr[v]=1 }` (`:216`), so `ESC[22m` sets an attribute numbered 22
  where `apply-one` clears bold, and every unrecognised code becomes a set flag
  where `parse-sgr` returns `sgr-other` and the fold discards it. It honours
  `39` and `49` as default-fg and default-bg (`:213`, `:215`), and `parse-sgr`
  has a row for neither. The disagreement therefore runs both ways: the awk
  knows two codes the typed decoder does not, and the typed decoder knows three
  off-codes (`22`, `24`, `27`) the awk does not. `face-sgr` emits none of the
  five, so Phase 16 grades E175 correctly as the tree stands. What X cannot be
  is the oracle for `display-calculus/C2`'s law, because a decoder that agreed
  with it would disagree with `apply-one`. Whether X retires once a typed
  decoder can serve is [[arcs/enforcement-arc]]'s tooling-surface requirement.

### Where a render shard belongs to another bank

- **S and the pool are [[banks/memory]]'s.** The only writable pixel region is a
  `Pool`, its size lives in the port type, and its capacity bound arrives erased.
  That bank already carries the erased bound; this one carries the one program
  that draws through it.
- **U is [[banks/port]]'s, and it is the display's whole membrane.** Every
  terminal byte crosses at `put`, typed `Str`. Shard L is `=>` for exactly that
  reason and shards A through K are `->` throughout. The purity boundary of the
  terminal path is that one extern; the pixel path crosses at `pool-write`
  instead, which is [[banks/memory]]'s.
- **T is [[banks/capability]]'s and [[banks/port]]'s.** The compositor is a
  foreign counterpart across one typed port, which is the map's own wording for
  E35 and E36.
- **The missing `(module …)` coordinates are [[banks/module]]'s and
  [[banks/profile]]'s.** A profile is a module set over a frozen port set. Eleven
  files that render carry no datasheet, so `display-calculus/H3`'s layering proof
  has nothing to read for this tier.
- **R is [[banks/text]]'s shard I, and shard M is built on it.** `str-cols`
  decodes UTF-8 to count. A width table changes what the count means and leaves
  the decoder alone.
- **Which shards a gate can reach is [[banks/verification]]'s question.** Five of
  the twenty-four (N, O, P, Q, and the `t4_*` half of D) are reached only from
  roots under `prog/scriba/samples/`, which Phase 7 compiles without running.
  `t5_utf8.prog` is one of three names in that phase's `KNOWN_FAIL` list
  (`tools/test/run-tests.sh:173`). A shard whose only caller is a fixture is
  gated on compilation and on nothing else.
- **J's second seam is [[banks/erasure]]'s shape without its mechanism.** A field
  bound and never read is dropped by nobody: it stays in the closure, it costs a
  word, and the compiler reports nothing. `command-loop.chiral:96` is that
  pattern at the top of the display path.

---

## 4. Native → chirality translation (the misfire → the correction)

Read this before saying chirality lacks a display feature.

| "chirality needs…" | what it actually is |
|---|---|
| a typed style value with invalid states unconstructible | shard D, `grid.chiral:6` and `:12`. **Built and reached.** The emit side lacks it, which is a conversion rather than a construction |
| a colour type | shard D's `Color`, three arms including 24-bit truecolour. Shard S carries a second spelling for pixels |
| a theme a root supplies | shard J holds the **domain**, filled three times and read never. Shard V, the value, is the absent half |
| a cascade with a law | shard H, total and typed, on the decode side. Shard G is the untyped twin, and the law both could satisfy is the round trip |
| a pretty printer | shard A. Six constructors, Lindig's strict renderer, one exit per surface |
| a display list | shard B. Nine constructors, 18 importers, a codec that covers all nine |
| a terminal emulator | shards P and Q. A linear cell grid, a 16-byte codec, a total escape parser |
| a stable id for a rendered block | shard N, and its key is content-derived. See §3 |
| a `wcwidth` | E177, `Not built`. The seam is `str-cols` and the signature does not move |
| a Wayland client | shard T, `CONFORMS` in the map, four demo roots |
| a float for layout | refused. [[decisions/decision-display-numerics]] settled fixed point 2026-09-04 |
| specificity, selectors, a stylesheet parser | nothing owed. `display-calculus/C3` attaches by a pure function, so specificity has nothing to arbitrate; `C10` makes resolution ordinary code |
| a second document type | shard A already is one, and `Doc` deliberately does not unify with `Rendering` (`render-doc.chiral:8-12`) |

---

## 5. What is genuinely unbuilt: the honest residue

1. **The theme value. `display-calculus/C5`, `unminted`.** Shard V. The domain
   exists (J), the resolver exists (F), the registry exists (E). What is absent
   is a value distinct from the library table, and an eviction of `manas-*` from
   `lib/`.
2. **Reaching J, and it is two edits rather than one. `display-calculus/A2`,
   `unminted`.** Threading `((mode r faces))` past the bind at
   `command-loop.chiral:96` reaches nothing while the emitter takes no registry:
   `render-to-ansi`'s declared signature is `render.chiral:103`, and its
   `r-face` arm names the `lib/` table at `render.chiral:771`. The resolution
   site is the seam that decides where a theme is homed.
3. **Reaching K. `display-calculus/A1`, `unminted`.** `doc->rendering` has zero
   importers and `dg-doc` (`lib/typing/diag.chiral:561`) has no consumer outside
   its own file, so no `d-tag` in this tree reaches `lookup-face`. Any coverage
   gate over a role sum nothing produces passes by looking at nothing.
4. **The display-width table. E177, `Not built`.** Shard M. One table, two
   consumers, and the hard part is the East-Asian Ambiguous class rather than the
   table.
5. **`r-table`'s two layouts. E178, `Not built`.** Headers advance by content
   (`render.chiral:360`), body cells by a hardcoded `(+ col 16)` (`:368`). One
   value, two layouts, and E174's gate is deliberately narrowed to the agreeing
   region.
6. **The law under shard G.** `face-join` states its rule in prose and no gate
   reddens when the fold changes. `display-calculus/C2`, `unminted`.
7. **The every-state walk and its witness. `display-calculus/C9` and `H6`,
   `unminted`.** Shard W. The cell lane's product measures 1, so which consumer
   stands as witness is an open author call.

**Gradient, stated once.** Shards A, B, C, E, F, G, I, L, M, R, S, T and U run on
every render. D, H, N, O, P and Q run under fixture roots. X runs as a suite
phase and on no render. J and K are written and unreached. V and W are absent.
The seven rows above are the whole of what the display tier owes. Two of them carry a minted element (E177 and E178, both
`design`); the other five are arc rows mapping to `unminted`, so nothing
schedules them.

---

## 6. Relational anchors: thin notes that should link INTO this bank

- [[banks/text]]: shard I is that bank's H; the fork under its shard G is §3.
- [[banks/memory]]: shard S draws through the `Pool` that bank owns.
- [[banks/port]]: shard U is the display's whole membrane, one `Str` extern.
- [[banks/capability]]: shard T crosses to a foreign counterpart on one port.
- [[banks/module]]: eleven rendering files carry no `(module …)` coordinate.
- [[banks/verification]]: five shards are reached only from fixture roots.
- [[banks/erasure]]: shard J's discarded binder is that shape with no mechanism.
- [[goals/display]]: the five conditions, four of them unopened.
- [[arcs/display-calculus-arc]]: the rows, the requirements, and the resume state.
- [[decisions/decision-display-numerics]]: fixed point, settled 2026-09-04.
- [[records/baseline-alignment]]: BA-20 and BA-21 are what shard G's address is
  for, and why a content hash does not serve it.
- [[records/author-calls]]: the scope ruling, the lane ruling, and the witness
  call under §5 item 7.
- [[status-ledger]]: build state for E111, E112, E158, E174, E175, E181.
