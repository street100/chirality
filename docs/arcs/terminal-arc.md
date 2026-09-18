---
node: arc-terminal
layer: navigation
related: [arcs/README, goals/display, goals/own-web, goals/local-ai, arcs/native-window-arc, arcs/canvas-arc, arcs/display-calculus-arc, arcs/vocabulary-arc, arcs/diagnostics-arc, arcs/scriba-arc, arcs/tool-authority-arc, banks/render, banks/port, banks/capability, decisions/decision-b-in-type, decisions/decision-work-ids, records/author-calls, records/homing-triage, status-ledger, index]
status: current
updated: 2026-09-17
---

# Arc: the terminal

- goals: [[goals/display]], condition 2: "**The seam.** One document reaches
  more than one surface, and no theme or render changes silently." ⚑ That
  condition covers this arc's negotiation and draw half. Three of its groups sit
  under no stated condition in any goal, and the FLAG below is owed an author
  ruling.
- reserved element block: **none**. Rows carry arc-local ids `TM1` and up, per
  [[decisions/decision-work-ids]], and map to an element or to `unminted`. The
  letter is `TM` because `T` is spelled three times already:
  `docs/arcs/transport-arc.md` rows `T1` to `T4`, `docs/arcs/zero-python-arc.md`,
  and `diagnostics/T1` at `docs/arcs/diagnostics-arc.md:257`. `T#` also names the
  side-project set at `docs/elements/ledger.md:391-397`.
- build-state authority: [[status-ledger]]
- checklist: none. No `records/` file holds this arc's history yet.

Opened 2026-09-10 by author statement: *"dispatch research and creation of
terminal arc there should be misc docs about the terminal stuff planned"*. The
forcing case is `E128`, the APC handshake, which `records/homing-triage.md:188`
routes to *"[[arcs/vocabulary-arc]] or [[arcs/native-window-arc]]"* under the
verdict `author-call`, on the evidence *"a terminal capability negotiation sits
under neither arc's stated requirements"*.

## Why this arc exists

The terminal is the one surface this tree already draws on. `goals/own-web.md:79`
says *"The terminal host is unaffected by either"* of the two blockers between a
canvas and a screen, and `canvas/G8` at `docs/arcs/canvas-arc.md:81` writes
*"Terminal live, the rest behind the two blockers"*. Both arcs lean on a terminal
host that exists, and neither owns it. `docs/arcs/native-window-arc.md:16` pushes
it away from the other side: that arc is *"a windowed Wayland app, distinct from
a terminal app and from a browser"*.

Condition 2 of [[goals/display]] is what the negotiation half schedules. A draw
tier selected by a wire query is the shape in which a render stops changing
silently, and `E128` is that query. The substrate half is a different claim and
the FLAG below carries it.

⚑ **FLAG, author tier: three groups here serve no stated goal condition.** The
pty lifecycle, the line discipline and the emulator's own machinery are built,
cited by nine ledger rows, and named by no condition in [[goals/display]],
[[goals/own-web]], [[goals/native-stack]] or [[goals/local-ai]].
[[goals/local-ai]] condition 2 consumes the terminal and is about the editor
inside it. [[goals/native-stack]] condition 2 excludes it by name. Whether
[[goals/display]] grows a sixth condition, whether a goal is opened, or whether
these rows stay unscheduled, is the author's. `docs/goals/README.md` forbids
authoring an ambition the project has never stated, so this run invents no goal.

⚑ **FLAG, author tier: a dated ruling drops half of what this arc rosters.**
`.planning/MINI-RUSH-HANDOFF.md:42-48`, verbatim:

```
A fresh session's biggest risk is rebuilding the abandoned terminal/OS arc. **Do not.**

- ❌ The chirality terminal **app / emulator** (old T15 / T17, `TUI/emulator/`).
- ❌ The pluggable **`Terminal` *port* abstraction** (T13 / T14 / T16). scriba writes
  ANSI straight to fd 0/1. No port indirection over the host terminal.
- ❌ **pty multiplexing** across real ptys (T9). Pane layout is scriba's own window
  tree drawing into one host terminal, not multiple ptys.
```

`E128`'s SPEC is implement-gated on that dropped port.
`docs/elements/specs/E128-apc-handshake-SPEC.md:52` cites its signature to
`TUI/docs/TERMINAL-PORT-DESIGN.md:109`, and neither that file nor the `TUI/`
directory exists in this tree. Row `TM9` carries the call. ⚑ **Half of it is
answered as of 2026-09-17: the supervisor is `ports/ports`, declared at
`lib/ports/ports.chiral:55` and the only `(cat C)` in the port tier.** What the
signature names is the half that stands, and the row states it.

**The vocabulary that states `TM9`'s question is
[[decisions/decision-b-in-type]].** A pty and a tty fd are B referents, Linux
facilities the language cannot type, and `lib/ports/pty.port:8-10` separates the
two registries at that level. One level up they are two referents of one surface.
`Terminal` is a C-side name: the supervisor every use routes through, which is
why it survives a substrate change. `lib/lowering/tal/target-linux.manifest:18`
declares `(cat B)` and its header at `:4-5` says a rung-2 backend *"replaces THIS
FILE alone"*. So `.planning/MINI-RUSH-HANDOFF.md:45` does not reach a C-side
port. It refused B-level indirection over one facility with no supervisor, and
that refusal stands on its own terms.

⚑ **FLAG, author tier: the repair this reading exposes is measured and
unplaced.** `records/lenses/problems.md` PRB-94 records that the nine `.port`
sheets under `lib/ports/` declare no module coordinate while
`lib/ports/ports.chiral:55` declares the C supervisor, so the quarantine is
unenforced across the crossing surface. Whether that repair is a `TM9` row, a
port-tier row of its own, or belongs to an existing element is the placement call
`records/author-calls.md` carries at `unreviewed`.

⚑ **FLAG, author tier: the lane ruling this arc sits beside.**
`.planning/DISPLAY-LAYER-GAP.md:22-24`, verbatim: *"**Lane ruling, author,
2026-09-04.** Terminal parsing, drawing, shading, layering and 3D are separate
lanes. A style vocabulary for one does not generalize to another. §4 states what
does cross."* This arc takes the terminal lane and leaves the style vocabulary to
[[arcs/display-calculus-arc]].

## What the tree already holds

Measured 2026-09-10. [[banks/render]] is the bank, and its shards N, O, P, Q and
U at `docs/banks/render.md:129-136` are its terminal half. [[banks/port]] and
[[banks/capability]] carry the crossing and the cap.

| group | what exists today | where | rung |
|---|---|---|---|
| line discipline | raw-mode enter and restore over a 60-byte termios cell, with the five `RAW_*` masks | `lib/protocol/term.chiral:116`, `:125`, masks at `:72-76` | IMPLEMENTED. E103. `prog/scriba/scriba-main.prog:21` and `:41` are the shipping callers |
| line discipline | window size read and write | `lib/protocol/term.chiral:26`, `:55` | IMPLEMENTED. E99, and the `T2` cite. `prog/scriba/scriba-main.prog:25` reads it |
| line discipline | the raw key read | `lib/ports/tty.port:25`, lowered at `lib/lowering/tal/crossing-wraps.chiral:25` | IMPLEMENTED. E98. `prog/scriba/command-loop.chiral:124` is the caller |
| line discipline | the key vocabulary: `Key`, `KeySeq`, `Keymap` | `lib/ports/tty.port:13-23` | IMPLEMENTED, and the decode from bytes sits a tier away in `prog/scriba/key-parser.chiral` |
| pty | acquisition: `TIOCGPTN`, `TIOCSPTLCK`, `open-pty` | `lib/protocol/term.chiral:197`, crossings at `lib/ports/pty.port:41-42` | IMPLEMENTED. E104 |
| pty | close-on-exec hygiene and its readback | `lib/protocol/term.chiral:185-195` | IMPLEMENTED. E110, with E121 as its conclusive test |
| pty | child wiring: `setsid`, `TIOCSCTTY`, `dup2`, and the spawn | `lib/protocol/term.chiral:243`, `:287`; crossings at `lib/ports/pty.port:44-47` | IMPLEMENTED. The `T1` cite. The capability angle on `spawn-in-pty` is claimed by `tool-authority/TA7` at `docs/arcs/tool-authority-arc.md:199` |
| pty | the linear master cap and its two result sums | `lib/ports/pty.port:14`, `:18-33` | IMPLEMENTED. The `T7` cite |
| pty | the linear session collection, `PtyVec` | `lib/capability/session.chiral:58-62` | SEEDED. E106 monomorphized for the `T9` mux. One importer, `prog/scriba/samples/t7_pty_cap.prog` |
| emulator | the cell region: a pool-backed linear grid of cells, sixteen bytes each | `Grid` at `lib/protocol/grid.chiral:28`, `Cell` at `:18` | SEEDED. E111. Five importers, four of them sample roots |
| emulator | the escape parser and its action set | `PState` at `lib/protocol/vt-parser.chiral:11`, `Action` at `:25`, `feed` at `:390` | SEEDED. The `T5` cite. Two importers, both under `prog/scriba/samples/` |
| emulator | the SGR decode as a total ordered fold | `lib/protocol/grid.chiral:201`, `:215`, `:232` | SEEDED. E111. [[arcs/display-calculus-arc]] requirement 2, built and facing the other way |
| emulator | codepoints: a total UTF-8 decoder with `U+FFFD` resync | `lib/protocol/utf8.chiral:46`, `:104` | IMPLEMENTED. Two importers, `render.chiral` and `vt-parser.chiral` |
| negotiation | the APC transport codec and its content-addressed node | `lib/protocol/apc.chiral:120`, `:141`, `:285` | SEEDED. E112, `built`. Two importers, `vt-parser.chiral` and one sample root |
| negotiation | the handshake that sets the bit the codec reads | nowhere | DESIGNED. E128, `design` at `docs/elements/ledger.md:224`, SPEC `audited` and triaged NEEDS-REPLAN |
| the exit | the crossing every terminal byte leaves through | `lib/ports/stdio.port`, `put` | IMPLEMENTED, and it is `Str`. Nothing at the crossing separates a control sequence from content. [[banks/render]] shard U |

**A `Terminal` is nothing in this tree.** Grepped 2026-09-10 across `lib/`,
`prog/` and `tools/`: zero hits for `porttype Terminal`, `term-write` and
`term-structured?`. Every terminal byte goes to fd 0 or fd 1 by convention.

**Nine ledger rows cite a catalog that is absent.** `docs/elements/ledger.md:386`
opens §Z with *"TUI ecosystem, `TUI/CATALOG.md` (T1–T19)"*, and `TUI/` does not
exist. The rows carrying a `→TUI:T#` cite are at `:115`, `:176`, `:190`, `:200`,
`:202`, `:203`, `:204`, `:223` and `:224`.

## What is missing, and its structure

Six groups, in dependency order.

| group | owns |
|---|---|
| `disposal` | every declared terminal crossing having a body that lowers |
| `gate` | a phase that holds a real terminal and can fail |
| `port` | what a program holds when it holds the surface |
| `negotiation` | the query, the reply, the deadline, and the tier they select |
| `emulator` | the grid and the parser reaching a program |
| `record` | the `T#` cites resolving into something that exists |

### The edges that run against the order

| edge | direction | what crosses |
|---|---|---|
| `negotiation` to `port` | against the order | `E128`'s signature takes `(1 t Terminal)` and `.planning/MINI-RUSH-HANDOFF.md:45` refused B-level indirection over the host terminal. The negotiation decides how much of a port the arc needs, so `TM9` is settled by what `TM4` turns out to require |
| `gate` to `disposal` | against the order | the gate sits last in dependency order and first in what the arc should do. `pty-close` has been declared and unlowered since E107 landed, and the reason nothing caught it is that no phase holds a pty. A gate built last measures a hole already closed |
| `emulator` to `port` | against the order | whether the emulator draws through the C supervisor or writes fd 1 directly is `TM9`'s question arriving from the other side |

## REQUIREMENTS

1. **Every declared terminal crossing lowers.** `pty-close` is declared at
   `lib/ports/pty.port:38` and called twice at
   `lib/capability/session.chiral:54-55`, and
   `grep -c pty-close lib/lowering/tal/crossing-wraps.chiral` returns 0. Observed
   when that count is nonzero and a root driving `read-once` compiles and runs.
2. **A gate holds a real terminal.** No phase of `tools/test/run-tests.sh`
   executes a tty or pty root. Phase 7 is compile-only and states the reason at
   `:151`: *"several of these are TUI programs that want a tty"*. Observed by a
   named phase that acquires a pty, drives a child through it, and exits 42.
3. **The draw tier is negotiated.** Nothing in this tree spells
   `term-structured?`, so the tier is assumed. Observed when a query goes out, a
   reply or a deadline comes back, and the bytes the renderer emits are a
   function of that answer.
4. **The emulator half is reached by a program.** `lib/protocol/vt-parser.chiral`
   has two importers and both are under `prog/scriba/samples/`;
   `lib/protocol/grid.chiral` has five and four are sample roots. Observed when a
   root outside `samples/` imports them and the suite runs it.
5. **The terminal's element record points at something that exists.**
   `docs/elements/ledger.md:386` cites `TUI/CATALOG.md` and the directory is
   absent. Observed when every `→TUI:T#` cite resolves to a live document or is
   retired.
6. **What holds the terminal is a value.** Every write goes to fd 0 or fd 1 by
   convention. Observed when a program cannot draw without holding the thing that
   authorizes it, or when this arc records the author's refusal and the rows that
   die with it.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `terminal/TM1` | `pty-close` gets a `crossing-wraps` row, so the declared close lowers. Declared `(=> (1 p Pty) Unit)` at `lib/ports/pty.port:38`, called at `lib/capability/session.chiral:54-55`, absent from `lib/lowering/tal/crossing-wraps.chiral`. E107's named residue, still owed | disposal | port | connect | 1 | open | `unminted` |
| `terminal/TM2` | one checked inventory over the eleven tty and pty crossings: declared, lowered, reached. The measurement `TM1` came out of, made repeatable | disposal | tool | connect | 1 | open | `unminted` |
| `terminal/TM3` | a phase that acquires a pty, wires a child onto it, reads the child's bytes back and exits 42. The first gate in this tree that holds a terminal | gate | tool | new | 1, 2 | open | `unminted` |
| `terminal/TM4` | the APC handshake: an `ESC _ ? ... ST` query, a reply or a deadline, and the bit that selects the draw tier. Its SPEC is `audited` and triaged NEEDS-REPLAN at `docs/elements/specs/E128-apc-handshake-SPEC.md:13`, 0 of 4 steps executable, every target a `TUI/` path. Implement-gated on `TM9` | negotiation | primitive | new | 3 | specced | `E128` |
| `terminal/TM5` | the responder: the side that answers `TM4`'s query. `E128`'s SPEC §1 files it as a non-goal and homes it at `T15`, a side-project row whose catalog is absent | negotiation | primitive | new | 3 | open | `unminted` |
| `terminal/TM6` | the grid and the parser reach a root outside `prog/scriba/samples/`. Both are built, both are SEEDED, and the four sample roots are reach into a gate | emulator | law | connect | 4 | open | `unminted` |
| `terminal/TM7` | where the key decoder lives. `Key`, `KeySeq` and `Keymap` are declared at `lib/ports/tty.port:13-23` on the stated ground that a key is what the crossing yields, while the decode from `read-key`'s bytes sits in `prog/scriba/key-parser.chiral` | emulator | decision | connect | 4 | open | `unminted` |
| `terminal/TM8` | every `→TUI:T#` cite resolves or retires. Nine ledger rows point into `TUI/CATALOG.md` and the directory is absent | record | decision | new | 5 | open | `unminted` |
| `terminal/TM9` | what the signature names, once the supervisor is fixed. ⚑ **The supervisor half is answered, 2026-09-17.** `lib/ports/ports.chiral:55` declares `(module ports/ports (cat C) (alt upper))`, and `grep -rn '(cat C)' lib/ports/` returns that line alone, so the category C supervisor the terminal's B referents route through is `ports/ports` and no second candidate was ever on offer. [[decisions/decision-b-in-type]] at `:26-29` requires every B use to route through a category C supervisor and names none itself, so the vocabulary asks for one and the port tier declares exactly one. **What stays with this row.** A `Terminal` is nothing in this tree, measured under *What the tree already holds*, and `E128`'s `(1 t Terminal)` needs a name over the two referents that section separates: the tty fd, and the `Pty` master at `lib/ports/pty.port:14`. Declaring a module coordinate on `tty.port` and `pty.port` routes them through `ports/ports` and mints no `Terminal`, which is why requirement 6 still has nothing holding it. `.planning/MINI-RUSH-HANDOFF.md:45` refused B-level indirection over the host terminal in 2026-08 and reaches no C-side port, and `canvas/G2` asks for a host that places a display list without owning the surface. **The adoption work belongs elsewhere.** `sys-face/SF20` at `docs/arcs/sys-face-arc.md:197` takes the coordinate across all nine `.port` sheets, measured by `records/lenses/problems.md` PRB-94, and that row is carried as blocked on the placement author call this arc quotes under FLAGs | port | decision | new | 3, 6 | open | `unminted` |

### Coverage

Groups are disposal, the gate, the port, negotiation, the emulator and the
record. Every requirement is served: 1 by `TM1`, `TM2` and `TM3`; 2 by `TM3`; 3
by `TM4`, `TM5` and `TM9`; 4 by `TM6` and `TM7`; 5 by `TM8`; 6 by `TM9`. Every
row serves at least one.

Every `origin` is defensible from the measurement above. Four rows are `connect`
because both halves are built and nothing joins them: `TM1` has an extern and a
registered syscall with no pair between them, `TM2` measures what exists, `TM6`
has a grid and a parser with no shipping caller, and `TM7` has a type in the port
and a decoder in the editor. `TM4` is `new` on `E128`'s own SPEC §2, which
records that nothing of the negotiation exists. `TM3`, `TM5`, `TM8` and `TM9` are
`new`, and the tree holds none of them.

**`TM4` is the only row carrying an element.** `E128` is minted, `design` in the
ledger, and its SPEC is `audited`. Every other row writes `unminted`, because
this arc holds no reserved block.

## Resume state

**Where a session picks up.** `TM1`, then `TM3`. `TM1` is a single
`crossing-wraps` pair over a syscall the tree already registers, and it closes a
residue `docs/elements/catalog.md:439` has carried since E107 landed. `TM3` is
what would have caught it. Neither waits on an author call.

**What blocks the arc.** `TM4`, `TM5` and `TM9` stand behind a `Terminal`
that no signature names. The supervisor they route through is settled and is
`ports/ports`; the name over the terminal's two referents is what is absent.
`TM4`'s SPEC cannot be executed as written: 0 of 4 steps run at HEAD and every
target is a `TUI/` path, per `records/spec-tier-triage.md:216`.
Replanning it against `lib/protocol/apc.chiral` is the first move on that side,
and it cannot finish while `TM9` is open.

**What this arc does not take.** The ANSI emission, the face stack, the width
table and the face registry are [[arcs/diagnostics-arc]] rows `L2` to `L5` and
`F1` to `F3` at `docs/arcs/diagnostics-arc.md:253-262`. The style vocabulary over
them is [[arcs/display-calculus-arc]]. Deriving the `vt-parser` and `apc` codecs
from a declared wire form is `diagnostics/W1`, `E183`. The capability shape of
`spawn-in-pty` is `tool-authority/TA7`. The editor that runs in the terminal is
[[arcs/scriba-arc]]. A window on a compositor is [[arcs/native-window-arc]],
which refuses the terminal by name.

**An element may belong to more than one arc**, ruled by the author 2026-09-10.
`E111` sits on `display-calculus/C1` and its grid half is measured here as this
arc's emulator substrate. `E112` sits on `vocabulary/F3` for its `block-id` and
is measured here as the transport `E128` negotiates. This arc rosters `E128`
alone and cites the other two.

**What the gather found beyond the material named at dispatch.**
`.planning/MINI-RUSH-HANDOFF.md` §2 and `.planning/DISPLAY-LAYER-GAP.md:22-24`
are the two dated author rulings over this territory, and neither was on the
list. `docs/arcs/diagnostics-arc.md`, `docs/arcs/tool-authority-arc.md` and
`docs/arcs/file-types-arc.md` each claim a terminal-adjacent row, and none of the
three was named as a display-side arc. `records/lenses/` carries **no** unruled
row about terminal territory: grepped 2026-09-10 for every terminal file under
`lib/`, the only two hits are `PRB-62` on `apc.chiral`'s hash, a crypto row, and
`UNS-49` on computed placement, a vocabulary row.

**The `docs/arcs/README.md` row is owed.** This run's write surface was this file
alone, so the arc table there carries no `terminal` row yet, and `ledger-lint`
check V reports the disagreement until it does.
