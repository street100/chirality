# Display research queue

Opened 2026-09-22 by the author's directive, recorded at
`records/author-calls.md` under *Added by the display review, 2026-09-22*.
Serial: one run out, waited for, verified, committed, then the next.

**The stop condition.** Not "the queue emptied". **No row in the five display
arcs rests on a category statement.** A run that returns may add rows to this
queue; that is the campaign working, not the campaign failing.

**The standing instruction on every run**, from the author's fourth directive:
the run names the primitives its subject implies and nobody has written down.
An `FD` row from this queue carries an implied-primitive section, and a run that
finds none says so in those words.

## The measurement this campaign exists to move

Taken 2026-09-22 over the 62 roster rows of `display-calculus`, `terminal`,
`canvas`, `native-window` and `native-document`.

| | rows | cite `FD-` | cite code | cite neither |
|---|---|---|---|---|
| raster group | 7 | **6** | 1 | 0 |
| everything else | 55 | 0 | 11 | **44** |

Median row length: 100 words in raster, 11 to 18 in cascade, element, gate,
canvas and lens. Re-run the measurement at the end of the campaign; the number
that has to move is the 44.

## The queue

`state`: `queued` · `dispatched` · `returned` · `merged`.

| # | state | question | rows it must reach | FD |
|---|---|---|---|---|
| 1 | `merged` | In systems that resolve style WITHOUT selectors or specificity, what is the minimal set of objects each makes first-class and separately nameable? Survey GTK4 CSS's deliberate subset, SwiftUI's Environment, Compose's CompositionLocal, Flutter's InheritedWidget, Elm and Halogen. The answer is a named list per system plus the intersection | `display-calculus/C3` `C6` `C7` `C10` `C11` `C12` | `FD-41` |
| 2 | `merged` | What must an element model carry for an accessibility tree to be derived from it by a total function, and which shipped systems actually derive rather than maintain it? | `display-calculus/E1` `E2` `E3` `E4`, `native-document/V1` | `FD-42` |
| 3 | `merged` | What does a declarative scene or document file actually declare, and what fields would a canvas file need to be a kind under this tree's `.manifest` scheme? Measure against `.planning/MANIFEST-DESIGN-MAP.md:112-121`'s six requirements | `canvas/G1` `G4` `G8`, `native-document/V4`, condition 2 | `FD-43` |
| 4 | `merged` | What does hit testing require of a layout result, and what makes it the exact inverse of layout rather than an approximation? | condition 3, gap `B1` `B9` | `FD-44` |
| 5 | `merged` | Flex and grid as pure functions over a child list: what does a faithful implementation need as input, and what does it return? Taffy is the reference | gap `B2` `B3` `B4` `B5` `B6` `B7` | `FD-45` |
| 6 | `queued` | The display list as a closed sum: what constructor set does a shipped scene graph settle on, and what forces a constructor to exist? GSK render nodes are the reference | gap `Z1` `Z2` `Z3`, `canvas/G2` `G8` | — |
| 7 | `queued` | A frame as a function of state and time: which systems make this total and replayable, and what does a deterministic animation need to carry? | condition 5, gap `Z5` | — |
| 8 | `queued` | What does a golden render gate compare, and what does a property walk over `(Env, State)` actually check? | `display-calculus/C9` `H6`, `canvas/Q2` `Q3` `Q4` `Q5`, gap `H5` `H7` `H9` | — |
| 9 | `queued` | The xdg-shell vocabulary and seat input: what is the minimum object set a client must name, and what does each carry? | `native-window/W1` `W2` `W3` `W4` | — |
| 10 | `queued` | Where does a key decoder belong when the crossing yields bytes, and what does a pty inventory have to check? | `terminal/TM2` `TM3` `TM6` `TM7` | — |
| 11 | `queued` | Font vocabulary, fallback and line breaking: what is the minimum a bitmap-font floor needs, and where does UAX #14 stop being a table? | gap `T1` `T3` `T6` | — |
| 12 | `queued` | Fractional scale and HiDPI as an input to style rather than a correction after it: what does the scale have to be a field of? | gap `Z6` | — |

## Ordering, and why

1, 2 and 3 first: they are the author's conditions 1 and 2 and they constrain
the rest. 4 through 7 open the three unopened conditions and return to the
author before any arc is drawn, per the third directive. 8 through 12 are the
gate, port and text surfaces, which consume the earlier answers.

## Log

| run | dispatched | returned | FD | what it moved |
|---|---|---|---|---|
| 1 | 2026-09-22 | 2026-09-22 | `FD-41` | 24 pins. Two of six surveyed fail the premise. Intersection is TWO objects. **Eight implied primitives, none rostered.** Killed C10 outright: no surveyed system resolves at compile time |
| 2 | 2026-09-22 | 2026-09-23 | `FD-42` | 21 pins. NO system derives totally; the six that do are total only via declared defaults. **Ten implied primitives, none rostered.** Refutes the gap doc: AccessKit is its `E3` model and is the clearest MAINTAINED case |
| 3 | 2026-09-23 | 2026-09-23 | `FD-43` | 13 pins. 4 of 8 declare, and NO format refuses on a missing structural field. **Nine implied primitives.** Refutes my brief on manifest req 3, undercounts req 4 at 17 of 40 not 7, and finds the canvas format already rostered on vocabulary-arc: the missing artifact is a BINDING, not a design |

## Follow-ups the campaign opened, none scheduled

| what | where it came from | state |
|---|---|---|
| `.planning/protocol/dispatch.md`'s `A1` gloss is wrong on manifest requirement 3 and undercounts requirement 4. `sys-check.chiral:17` declares `(sys-row (name Str) (num I64))`, so the constructor HAS named fields and only the application is positional. And 17 of 40 rows share a syscall number across five groups, not 7 in one | `FD-43`, re-verified by the orchestrator | `owed`, a `doc-audit` on a protocol file |
| The canvas file format needs a BINDING between [[arcs/canvas-arc]] and [[arcs/vocabulary-arc]], not a design. `vocabulary/M1` `M4` `M5` `F1` `F2` `F3` already roster five of its six objects, and `F1` says outright it "Absorbs `display-calculus/E1`" | `FD-43` | `owed`, author call: which arc owns it |
| `vocabulary` requirement 3 takes a position no surveyed format holds: a version field INSTEAD of silent degradation. Five of eight carry a version field and all five also carry an ignore rule | `FD-43` | `owed`, a `revisit` of that arc against `FD-43` |
| `.planning/DISPLAY-LAYER-GAP.md` Lane E cites AccessKit as its model for a DERIVED accessibility tree; it is the survey's clearest MAINTAINED case | `FD-42` | `owed` |
| `display-calculus/C10` claims compile-time resolution; no surveyed system does it | `FD-41` | `owed`, a `revisit` of that row |
| `records/findings.md` carries 148 citations of which **5 do not resolve**, all pre-existing and identical in `HEAD`: `DEBUGFISSION:137`, `SVG2STRUCT:245`, `GLTFSCHEMA:155`, `EBMLRFC:1167`, `PDFSPEC:4952`. `xlat check` reports them and no gate reads that exit | `FD-44`, re-verified by the orchestrator | `owed` |
| `.planning/sources/aead-chacha20-poly1305.gather` is a `translate` artifact sitting unpaired in the pin directory, which is why every `ls`-based pin count this campaign reported was off by one | `FD-44` | `owed` |
| 4 | 2026-09-23 | 2026-09-23 | `FD-44` | 17 pins. **Condition 3's second clause is false of all 8 systems.** CSS declines to specify hit testing at all. Ten implied primitives. Opens an author fork: partition against sibling order |
| `prog/scriba/window.chiral:34` asserts a partition invariant its own file refutes three times (`:100` unused remainder cells, `(max 1 …)` children outside the parent, `:74` returning two identical rects). The invariant is delegated to a caller in a comment and nothing checks it | `FD-45`, re-verified by the orchestrator | **`fixed`** 2026-09-23 as far as it can honestly go: the false comment is corrected in place and the semantic question is [[records/lenses/problems]] PRB-95, held open because rewriting the guard would decide the partition fork in code |
| `.planning/DISPLAY-LAYER-GAP.md` `B3` claims Taffy "runs on microcontrollers with kilobytes of RAM". The README makes no such claim and `Cargo.toml:85` says Taffy always depends on `alloc`. Its other two claims hold | `FD-45` | `owed` |
| `FD-44` reported 527 pins from an `ls` count, 17 low, after being told not to count pins with `ls`. Its `window.chiral` def count is 24 against an actual 25 | `FD-45` | `owed`, a `revisit` of `FD-44`'s two figures |
| 5 | 2026-09-23 | 2026-09-23 | `FD-45` | 20 pins. **No layout engine is a pure function** and none partitions. But the partition arm is CONSTRUCTIBLE by gap-as-child, and two sources build it. Twelve implied primitives. Refutes window.chiral's own invariant and three of my figures |
| **`tools/xlat/xlat.sh:234` reads `head -1`, so `xlat check` inspects ONE citation per line.** `records/findings.md` holds 2,443 citation-shaped spans and the tool reports 159, **6.5%**. 41 carry escaped double quotes and would fail if the tool saw them. Every "citations verified" line this campaign reported rests on it | the correction pass, re-verified by the orchestrator | **`fixed`** 2026-09-23. `xlat check` rewritten as two awk passes: 159 citations to **2,442**, 8.2s to **2.1s**, and the honest unresolved count is **28** |
| `FD-44` contradicts itself three ways on one count: its heading says "each of six implementations reads at least one region layout never wrote", its table at `records/findings.md:789` marks Flutter as the exception, and its element line at `:805` says "four of six". The table supports five of six | the correction pass | **`fixed`** 2026-09-23, and a FOURTH statement of the count was found and fixed with the three |
| `.planning/MANIFEST-DESIGN-MAP.md:119` justified requirement 4 with "7 rows carry `16`", the undercount `FD-43` corrected | the correction pass | **`fixed`** 2026-09-23, in place, with all five groups and the seven uncommented rows named |
| `.planning/DISPLAY-LAYER-GAP.md` `B3`'s chirality column read "a pure function over the child list", which `FD-45` refutes for all five engines | the correction pass | **`fixed`** 2026-09-23, in place, naming what each engine returns instead |
