---
node: goal-own-web
layer: navigation
related: [goals/README, goals/display, goals/native-stack, goals/presentability, arcs/vocabulary-arc, arcs/canvas-arc, arcs/native-protocol-arc, arcs/native-window-arc, arcs/display-calculus-arc, decisions/decision-scope, decisions/decision-work-ids, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-05
---

# Goal: our own form of the web, and the surface it is read on

Stated by the author 2026-09-05, in session. It is an author call rather than a
derivation, on the precedent [[goals/README]] records for [[goals/display]] and
[[goals/presentability]].

The target the author set: **replace the web design stack and the browser with
one design language and one native surface, over a fabric whose addressing is
not IP's**, and integrate the result into a chirality desktop rather than
bolting a browser beside one.

## The claim, and where the project makes it

- [[examples/U13-typed-document-seam]] states the seam this widens: the
  renderer takes the typed value.
- [[goals/display]] supplies the calculus and the element vocabulary. Its
  **seam** condition gets its consumers here.
- [[goals/native-stack]] supplies the wire. Its **document** condition and this
  goal overlap, which is the merge call [[records/author-calls]] carries.
- `lib/protocol/apc.chiral:48` already computes a content address over a
  rendered tree, derived and never stored, recomputed and verified by the
  decoder. E112, built.
- `lib/surface/pretty.chiral` already prints a value back into its own source
  form, which is the round-trip law this goal gates every lens on.

## What done means

Five conditions. Two hold arcs; three are conditions in this file and schedule
nothing.

1. **The vocabulary.** A document is a typed value with one text form, and
   nothing that reads it can be surprised by it. [[arcs/vocabulary-arc]].
2. **The canvas.** One value reaches many hosts through view functions whose
   port sets are frozen and checked. [[arcs/canvas-arc]].
3. **Reach.** One instance gets a value from another with no global namespace
   and no authority. **Unopened, and it holds no arc file.** The design is
   `.planning/REACH-MODEL.md`.
4. **The primitives.** Every layer's crypto is chirality's own, post-quantum,
   with the configuration derived from the target. [[arcs/crypto-primitives-arc]],
   opened 2026-09-07 with 25 rows. The design is `.planning/CRYPTO-MODEL.md`
   and `.planning/CRYPTO-TRANSLATION.md`. [[arcs/native-protocol-arc]] holds the
   wire rows, and whether its `N10` closes into the new arc is an author call.
5. **The desktop.** A canvas is a layer of the environment rather than a window
   beside it. **Unopened, and it holds no arc file.** It is behind
   [[arcs/native-window-arc]] and the two blockers in the state section below.

## Its relation to the two goals it consumes

[[goals/display]] condition 2, the seam, becomes this goal's condition 2, and
`display-calculus/Z1`'s two-consumer test is satisfied by the hosts named here.
[[goals/native-stack]] condition 1, wire, becomes this goal's condition 3, and
condition 3, document, is absorbed by condition 1.

**Whether [[arcs/native-document-arc]] survives is the open merge call**
[[records/author-calls]] already carries, and this goal gives it a third
option: that arc closes into this one.

## State

Stated 2026-09-05, unbuilt. The measured baseline is
`.planning/OWN-WEB-GAP.md` §1 and the three planning models are the design.

**Two blockers stand between a canvas and a screen**, both measured 2026-09-05,
neither owned by an arc:

| blocker | measurement |
|---|---|
| nothing reaches a screen | `lib/lowering/tal/crossing-wraps.chiral` carries 44 lowered crossings and `sock-send-fd` is absent from them, so `prog/demo/wl-client.chiral:201` does not lower. `sock-listen`, `sock-accept` and `bind` are missing too |
| nothing draws varying content in linear time | `display-calculus/R3`, the measured wall. `brepeat` makes a solid span and varying content has no linear-time path |

The terminal host is unaffected by either, so condition 1 and most of condition
2 are reachable now.

## Honest limits

- **The scope ruling holds condition 3 and most of 4 out of reach.**
  [[decisions/decision-scope]] holds the current track to self-hosting, and the
  2026-09-04 ruling keeps focus on local primitives until the crypto and
  enforcement arcs finish. Rendering HTML, CSS, JS or HTTPS from a foreign
  server is out and stays out.
- **No arc under this goal holds a reserved element block.** Rows carry
  arc-local ids per [[decisions/decision-work-ids]] and map to `unminted`. The
  standing block call in [[records/author-calls]] covers them and this goal
  widens it by two arcs.
- **The primitives condition contradicts a tracked arc.**
  [[arcs/native-protocol-arc]]'s `N1` is scoped to WireGuard's suite, which is
  pre-quantum, and its requirement 1 says so. Re-scoping it is owed.
- **Three of the five conditions are unopened.** Each is citable from this file
  and none of them is scheduled.
