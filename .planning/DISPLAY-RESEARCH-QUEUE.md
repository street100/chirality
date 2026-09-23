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
| 1 | `queued` | In systems that resolve style WITHOUT selectors or specificity, what is the minimal set of objects each makes first-class and separately nameable? Survey GTK4 CSS's deliberate subset, SwiftUI's Environment, Compose's CompositionLocal, Flutter's InheritedWidget, Elm and Halogen. The answer is a named list per system plus the intersection | `display-calculus/C3` `C6` `C7` `C10` `C11` `C12` | — |
| 2 | `queued` | What must an element model carry for an accessibility tree to be derived from it by a total function, and which shipped systems actually derive rather than maintain it? | `display-calculus/E1` `E2` `E3` `E4`, `native-document/V1` | — |
| 3 | `queued` | What does a declarative scene or document file actually declare, and what fields would a canvas file need to be a kind under this tree's `.manifest` scheme? Measure against `.planning/MANIFEST-DESIGN-MAP.md:112-121`'s six requirements | `canvas/G1` `G4` `G8`, `native-document/V4`, condition 2 | — |
| 4 | `queued` | What does hit testing require of a layout result, and what makes it the exact inverse of layout rather than an approximation? | condition 3, gap `B1` `B9` | — |
| 5 | `queued` | Flex and grid as pure functions over a child list: what does a faithful implementation need as input, and what does it return? Taffy is the reference | gap `B2` `B3` `B4` `B5` `B6` `B7` | — |
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
