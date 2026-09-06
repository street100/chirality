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
| `native-window/W5` | the fd-passing crossing lowers: `sock-send-fd` has no entry in `crossing-wraps.chiral`, so `wl-client.chiral:201` does not lower and nothing reaches a screen. `sock-listen`, `sock-accept` and `bind` are missing with it, and it is E29's unowned server half | shell | port | new | 1 | open | `unminted` |
| `native-window/W6` | a gate reads `prog/demo/`, which is why W5 went unnoticed while the demos were described as running | shell | tool | new | 1 | open | `unminted` |

### Coverage

Every requirement is served: 1 by W1, W5 and W6; 2 by W2; 3 by W4; 4 by W3.
Every row serves one, and every `origin` is `new`: none of this exists in the
tree.

`W5` and `W6` were opened 2026-09-06. The fd-passing crossing sat as an author
call reading "which arc owns it" when this is the arc whose whole subject is a
window on a screen, and `wl-client.chiral` is its client. `PRB-71` holds the
measurement.

## Resume state


⚑ **2026-09-06: `W5` and `W6` opened.** The fd-passing crossing is this arc's: `sock-send-fd` has no entry in `crossing-wraps.chiral` while `wl-client.chiral:201` calls it, so **nothing in this tree reaches a screen**, and no gate reads `prog/demo/`, which is why it went unnoticed. `PRB-71` holds the measurement. **Next: `W5`.**
⚑ **A blocker was measured 2026-09-05 and it sits under all four rows.**
`lib/lowering/tal/crossing-wraps.chiral` carries 44 lowered crossings and
`sock-send-fd` is absent from them, so `prog/demo/wl-client.chiral:201` does
not lower and no pool memfd reaches a compositor. `sock-listen`, `sock-accept`
and `bind` are missing too. The line below records why it went unnoticed: no
gate reads `prog/demo/`, so the demos are described as running and were never
compiled by the suite. **Nothing in this arc is reachable until that crossing
has a body**, and [[arcs/canvas-arc]] carries the same blocker.

Unopened. The design discussion is `.planning/NATIVE-STACK-EXPANSION.md`. The
rung of the existing demos is the first thing to re-measure on opening. Nothing
under `tools/test/` reads `prog/demo/`, measured 2026-09-03, so no gate defends
them and none of them is a `compile-main` root Phase 7 would sweep. The agent
sandbox hosts no compositor, so live verification runs on the host.
