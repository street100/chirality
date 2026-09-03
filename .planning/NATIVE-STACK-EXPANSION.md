# Native stack expansion: the discussion relay

Opened 2026-09-03 from a design session with the author. The tracked outcome
is [[goals/native-stack]] and its three arcs. This file holds the drafts, the
rejections and the open forks, per protocol/placement.md: a discussion in
progress is a file.

## The ruling

The author stated three lines of work and their order:

1. A chirality-native network protocol, crypto required, the shrednet mesh's
   identity model as the base idea.
2. A windowed Wayland app. Terminal apps and browsers are both excluded by
   the statement. Unnamed; naming deferred by the author.
3. The document and style layer, the successor of the "render it as HTML"
   idea. Sequenced after the first two.

Opening date unset. `records/author-calls.md` carries the scheduling call and
the element-block call.

## What the session measured

| claim | evidence |
|---|---|
| the Wayland wire is already spoken | `lib/protocol/wire.chiral` (96 lines), `prog/demo/wl-client.chiral` (217), `prog/demo/tomodachi.chiral` (129), zero libwayland |
| shm pools with fd passing exist | `lib/ports/pool.port`, `sock-send-fd` in `lib/ports/sock.port` |
| the socket registry is live | `sock.port:54-74`: unix listen and accept, AF_INET client connect, socketpair, poll, all linear caps |
| the bitwise floor exists | `band bor bxor shl shr sar`, `prelude.chiral:66-71` |
| `op-mulhi` has no surface binding | `prelude.chiral:38` holds the op; no extern anywhere |
| zero RNG anywhere | grep for getrandom and random across `lib/` and `prog/`: one lseek comment, nothing else |
| zero crypto | `secret.chiral` is custody and says "No crypto here" in its header |
| zero xdg-shell, seat input, fonts | grep for xdg, seat, pointer, keyboard, font, glyph across `prog/demo/` and `lib/` |

## The design drafts, verbatim from the session

### The style calculus

- Typed style values: Length as a sum (px, em, fraction), Color with real
  invariants. An invalid value is unwritable where CSS drops it silently.
- Selectors as a small ADT so specificity is decidable and the cascade is a
  total ordered fold. The further option: drop selectors and attach styles by
  pure functions over the tree.
- Dynamism as a pure function of state: `style : (-> State Node Style)`, the
  state declared as an ADT. With a finite state sum the compiler can walk
  every reachable rendering and check a property in each. That check is the
  genuinely new thing; CSS has no sentence for it.

### The document vocabulary

Closed constructor sets split by context (block, inline, table row), the
`Cls` idiom from `lib/text/matcher.chiral` scaled up. Invalid nesting becomes
unconstructible, which retires the validator.

### The crypto line

The WireGuard suite as reference class: an AEAD cipher, a hash, a key
exchange, each with RFC vectors in the assertion gate. Constant time as a
checked judgment is the chirality-native prize: a secret-dependent branch or
index refused mechanically, seeded by Secret custody (E40) and the deferred
information-flow element named in `secret.chiral`'s header.

## Rejected, with reasons

- **Emitting HTML for a browser as the render target.** Superseded 2026-09-03
  by the author's expansion: dynamism would cross a JS seam, which is the
  seam PRINCIPLES.md 5 refuses. The native window replaces it. HTML emission
  survives only as a possible side target, unscheduled.
- **libwayland.** Already rejected by the tree. `wire.chiral`'s header states
  the position and the demos prove it.
- **Borrowed transport crypto as the permanent story.** The current borrowing
  is named at `inet.chiral:4`. The protocol arc exists to retire it.

## The 2026-09-03 re-ruling, late session

The author corrected the line's purpose and order. Crypto and Shamir are the
mechanics of a split source-of-truth store: seal, split t of n, reconstruct
by quorum, disagreement a named outcome on the return track. Primitives
first, one shared module every kernel consumes. The entropy crossing moves
ahead of the handshake because shares and keys consume it. Tracked in
`docs/decisions/decision-quorum-store.md`; rows N6 to N8 carry it. The
correction also stands as recorded feedback: the orchestrator had sequenced
RNG last and kernels self-contained, and both readings were wrong.

## The formula pass

`.planning/FORMULA-RETHINK.md`, opened 2026-09-03: twelve formulas, each
rethought in the language's own machinery, worked one at a time. Premise
ruled by the author: semantic before mechanical; cipher cores stay
transcriptions. Slices 3 and 4 wait behind row 1's probe and N6.

## Open forks

| fork | shape |
|---|---|
| when the track opens | answered for the protocol arc: opened 2026-09-03 by the author, kernels targeted next day. Window and document still open |
| element block or arc-local ids | the protocol arc took the `N` namespace 2026-09-03, the scriba `S` precedent. The other two arcs still wait |
| mulhi surface binding vs small limbs | working constraint 2026-09-03: small limbs, zero compiler changes. An audit may flag it |
| bitmap font vs rasterizer | W4's floor is bitmap; the rasterizer is its own project |
| the app's name | deferred by the author |
| a crypto bank | the banks hold no crypto concept. One is owed once shards exist to refract; premature at zero |
