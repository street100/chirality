---
node: arc-native-window
layer: navigation
related: [arcs/README, goals/native-stack, target-tomodachi, banks/port, decisions/decision-work-ids, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-06
---

# Arc: the native window

- goal: [[goals/native-stack]]
- reserved element block: **none**. Rows carry arc-local ids `W1` and up, per
  [[decisions/decision-work-ids]], and map to an element or to `unminted`.
- build-state authority: [[status-ledger]]

Opened 2026-09-03 by author statement: a windowed Wayland app, distinct from a
terminal app and from a browser. The app is unnamed; the author deferred
naming. Unopened for work until the author call in [[records/author-calls]]
schedules it.

## What is in the tree already

Measured 2026-09-03. [[target-tomodachi]] is the standing target this arc
extends.

| where | lines | what |
|---|---|---|
| `lib/protocol/wire.chiral` | 96 | the Wayland wire codec: encode, string args, message split. Zero libwayland |
| `prog/demo/wl-client.chiral` | 217 | surface, attach, damage, commit, against layer-shell |
| `lib/ports/pool.port` | 31 | shm pools: the buffer size rides the port type, the backing memfd is a linear Fd |
| `prog/demo/tomodachi.chiral` | 129 | the running companion: Wayland socket, niri IPC socket, one pool, all linear |

## What is missing

Grepped 2026-09-03: zero hits for xdg, seat, pointer or keyboard across
`prog/demo/` and `lib/protocol/wire.chiral`. Zero hits for font or glyph in
`lib/` and `prog/`. The demos draw sprites.

## REQUIREMENTS

1. **A window opens on a stock compositor** through xdg-shell, with the
   configure and ack dance honored, in the tree's own codec.
2. **Input changes what it draws.** Seat events decoded, pointer and keyboard.
3. **Text renders.** A bitmap font is an acceptable floor. A rasterizer is a
   separate decision.
4. **Resize is honored**: pool sizes negotiated at runtime instead of the
   demo's fixed 16384.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `native-window/W1` | the xdg-shell vocabulary | shell | primitive | new | 1 | open | `unminted` |
| `native-window/W2` | seat input: pointer and keyboard events decoded | input | primitive | new | 2 | open | `unminted` |
| `native-window/W3` | negotiated pool sizes, so resize is honored | shell | law | new | 4 | open | `unminted` |
| `native-window/W4` | text on screen, bitmap font first | text | primitive | new | 3 | open | `unminted` |
| `native-window/W5` | the fd-passing crossing lowers: `sock-send-fd` has no entry in `crossing-wraps.chiral`, so `wl-client.chiral:201` does not lower and nothing reaches a screen. The server half (`sock-listen`, `sock-accept`, and a `bind` extern that has never existed) is E29's and leaves this row for `W7`, per the E199 design | shell | port | connect | 1 | minted | `E199` |
| `native-window/W6` | a gate reads `prog/demo/`, which is why W5 went unnoticed while the demos were described as running | shell | tool | new | 1 | designed | `unminted` |

### Coverage

Every requirement is served: 1 by W1, W5 and W6; 2 by W2; 3 by W4; 4 by W3.
Every row serves one. Five rows carry `origin: new`, and nothing they name is in
the tree. `W5` reads `connect`, corrected 2026-09-15 by its own design: the
`sendmsg`+`SCM_RIGHTS` floor crossing is built at
`lib/lowering/tal/sys.chiral:366` and permitted at
`lib/lowering/tal/target-linux.manifest:40`, so two built things need joining
per [[arcs/README]].

`W5` and `W6` were opened 2026-09-06. The fd-passing crossing sat as an author
call reading "which arc owns it" when this is the arc whose whole subject is a
window on a screen, and `wl-client.chiral` is its client. `PRB-71` holds the
measurement.

## Resume state


⚑ **2026-09-15: the arc is scheduled and `W5` minted as `E199`.** The author
scheduled this arc in session 2026-09-14, and the scope is a client on a stock
compositor: `records/author-calls.md` carries the ruling. `W5`'s design passed
its audit at DESIGN level with no author-tier FLAG and minted `E199`. **Next:
`W6`**, then `E199 --spec`.

**What `W5`'s design measured, and the arc's own text was wrong on two
counts.** The `sendmsg`+`SCM_RIGHTS`
floor crossing is BUILT at `lib/lowering/tal/sys.chiral:366`, consed into
`sys-lib` (`lib/lowering/tal/sys.chiral:1308`) at `:1338`, and permitted at
`lib/lowering/tal/target-linux.manifest:40`, so the delta is one TAL wrapper
plus one table row. The server half is E29's and leaves the row for a proposed
`W7`. The table's 44 routing rows are the honest count, re-verified 2026-09-15
by `E199`'s design audit: `grep -c '(pair '` returns 45 because `cw-lookup`'s
destructure at `crossing-wraps.chiral:64` matches the same pattern. Two runs
and one orchestrator reported 45 off that grep before the audit opened the
line. `crossing-wraps.chiral:8-11` declares an invariant against
`lib/sys-linkage.chiral`, which does not exist:
`lib/lowering/tal/sys-linkage.chiral:87-93` derives `sys-bindings` FROM
`crossing-wraps`, so a row added there owes no second edit.

**Two defects `E199` does not fix, each owed a row.** A def calling
`sock-send-fd` fails with the blame naming the def's scrutinee crossing, which
compiles on its own in two probe roots. Nothing in this tree can receive a
descriptor: no `recvmsg` row and no receive-fd extern, so the `st_ino`
round-trip `docs/examples/E30-fd-passing.md:207-209` describes is unreachable
and `E199`'s gate ships with that ceiling stated.

⚑ **2026-09-06: `W5` and `W6` opened.** The fd-passing crossing is this arc's, and `wl-client.chiral:201` calls it. `PRB-71` holds the measurement.
⚑ **A blocker was measured 2026-09-05 and it sits under all four rows.**
`lib/lowering/tal/crossing-wraps.chiral` carries 44 lowered crossings and
`sock-send-fd` is absent from them, so `prog/demo/wl-client.chiral:201` does
not lower and no pool memfd reaches a compositor. `sock-listen`, `sock-accept`
and `bind` are missing too. The line below records why it went unnoticed: no
gate reads `prog/demo/`, so the demos are described as running and were never
compiled by the suite. **Nothing in this arc is reachable until that crossing
has a body**, and [[arcs/canvas-arc]] carries the same blocker.

Scheduled 2026-09-14. The design discussion is
`.planning/NATIVE-STACK-EXPANSION.md`. The rung of the existing demos is the
first thing to re-measure, and `W6` is the row that makes a rung claim
checkable. Nothing
under `tools/test/` reads `prog/demo/`, measured 2026-09-03, so no gate defends
them and none of them is a `compile-main` root Phase 7 would sweep. The agent
sandbox hosts no compositor, so live verification runs on the host.
