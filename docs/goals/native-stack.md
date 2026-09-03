---
node: goal-native-stack
layer: navigation
related: [goals/README, arcs/native-protocol-arc, arcs/native-window-arc, arcs/native-document-arc, target-tomodachi, decisions/decision-scope, decisions/decision-work-ids, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-03
---

# Goal: the native stack, wire and screen in the same language

Stated by the author 2026-09-03, in session, with an internal order: protocol
first, window second, document layer third. This file is the record of that
statement, following the precedent in [[records/author-calls]] where
[[goals/presentability]] closed an UNWRITTEN goal the same way.

## The claim, and where the project makes it

- `README.md#the-questions` asks whether one language can be held to every
  layer at once and names the layers it means.
- [[target-tomodachi]] already puts the language on screen: "A desktop
  companion process for a Wayland session", speaking the wire format with no
  libwayland.
- `lib/protocol/inet.chiral:4` names the borrowed piece this goal retires:
  "WireGuard is the transport crypto". The transport a chirality process
  trusts today is code outside the tree.
- [[examples/U13-typed-document-seam]] states the document half: the renderer
  takes the typed value.

## What done means

Three conditions, one per arc.

1. **Wire.** Two chirality processes complete an authenticated key exchange
   and move bytes under an AEAD, with every kernel on the path written and
   checked in chirality. [[arcs/native-protocol-arc]].
2. **Screen.** A windowed Wayland app: xdg-shell, seat input, text on screen,
   through the tree's own wire codec. [[arcs/native-window-arc]].
3. **Document.** A typed document with a typed style calculus renders in that
   window, and style is a total function of a declared state.
   [[arcs/native-document-arc]].
4. **Store.** A value is sealed, split t of n by Shamir sharing, and
   reconstructed only by quorum, with disagreement a named outcome.
   [[decisions/decision-quorum-store]], added by author ruling 2026-09-03,
   carried by [[arcs/native-protocol-arc]] rows N6 to N8.

## State

Stated 2026-09-03, unbuilt. The inventory measured that day is in each arc's
own table; the short form: the socket registry, the Wayland wire codec, shm
pools with fd passing and a working layer-shell demo exist, and crypto,
entropy, xdg-shell, seat input and fonts do not.

## Honest limits

- [[decisions/decision-scope]] holds the current track to self-hosting only.
  This goal is stated and unopened; the opening is an author call recorded in
  [[records/author-calls]].
- None of the three arcs holds a reserved element block. Rows carry arc-local
  ids per [[decisions/decision-work-ids]].
- The window app carries no name. The author deferred naming.
- The rung of the existing Wayland demos was unverified on the day this goal
  was stated: the suite gates them and the suite was deliberately unrun
  (3.85 GB, no swap, OOM history).
