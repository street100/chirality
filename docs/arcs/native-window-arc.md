---
node: arc-native-window
layer: navigation
related: [arcs/README, goals/native-stack, target-tomodachi, banks/port, decisions/decision-work-ids, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-03
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

## Rows

| row | what | state | element |
|---|---|---|---|
| `native-window/W1` | the xdg-shell vocabulary | not started | `unminted` |
| `native-window/W2` | seat input | not started | `unminted` |
| `native-window/W3` | negotiated pool sizes | not started | `unminted` |
| `native-window/W4` | text on screen, bitmap first | not started | `unminted` |

## Resume state

Unopened. The design discussion is `.planning/NATIVE-STACK-EXPANSION.md`. The
rung of the existing demos is the first thing to re-measure on opening: the
suite gates them and was deliberately unrun on the day this arc was written
(3.85 GB, no swap, OOM history). The agent sandbox hosts no compositor, so
live verification runs on the host.
