---
node: arc-native-protocol
layer: navigation
related: [arcs/README, goals/native-stack, arcs/transport-arc, banks/port, decisions/decision-work-ids, decisions/decision-scope, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-03
---

# Arc: the native protocol

- goal: [[goals/native-stack]]
- reserved element block: **the `N` namespace**. Rows carry arc-local ids `N1`
  and up, per [[decisions/decision-work-ids]], and the ids double as example
  ids, the scriba `S` precedent.
- build-state authority: [[status-ledger]]

Opened 2026-09-03 by author statement: a chirality-native network protocol,
crypto required, the shrednet mesh's identity model as the base idea. Opened
for work the same day by author direction, in session;
[[records/author-calls]] holds the residue for the window and document arcs.

## What is in the tree already

Measured 2026-09-03.

| where | what |
|---|---|
| `lib/ports/sock.port:54-74` | the socket registry: unix listen and accept, AF_INET client connect, send, recv, fd passing, socketpair, poll. Every cap linear |
| `lib/protocol/inet.chiral` | dotted-quad parse and the sockaddr_in packer, pure. The header names WireGuard as the transport crypto the current path borrows |
| `lib/capability/secret.chiral` | Secret custody, E40. Its own header: "No crypto here" |
| `lib/prelude/prelude.chiral:66-71` | band, bor, bxor, shl, shr, sar as surface externs |
| `lib/prelude/prelude.chiral:38` | op-mulhi exists in the lowering op sum with no surface extern |

## What is missing

Grepped 2026-09-03: zero hits for getrandom or any RNG in `lib/` and `prog/`,
zero crypto kernels, zero listen-side AF_INET, zero UDP.

## REQUIREMENTS

1. **The transport is ours.** Two chirality processes complete an
   authenticated key exchange and move bytes under an AEAD with zero foreign
   crypto on the path.
2. **Every kernel passes its published test vectors** inside the assertion
   gate. A kernel with no vector row is unproven and says so.
3. **Entropy enters through one declared crossing.** The tree currently has
   none, and that is a property to spend deliberately: every compiled path
   today is deterministic.
4. **Key material lives behind Secret custody** from mint to reveal, and every
   reveal site is greppable, per E40's rule.
5. **Nothing authoritative sits whole in one place.** A value is sealed,
   split t of n, reconstructed only by quorum, and two share subsets that
   reconstruct differently surface as a named disagreement
   ([[decisions/decision-quorum-store]]).

## Rows

| row | what | state | element |
|---|---|---|---|
| `native-protocol/N1` | the kernels: an AEAD cipher, a hash, a key exchange, the WireGuard suite as reference class | slice 1 built and gated 2026-09-03, slices 2 to 4 open | `unminted` |
| `native-protocol/N2` | the entropy crossing | not started | `unminted` |
| `native-protocol/N3` | listen-side AF_INET, and UDP if the handshake wants it | not started | `unminted` |
| `native-protocol/N4` | the handshake and framing, Noise reference class, shrednet identity model as base | not started | `unminted` |
| `native-protocol/N5` | the constant-time judgment: a secret-dependent branch or index is refused mechanically | not started | `unminted` |
| `native-protocol/N6` | the shared primitives module: word ops, LE codecs, field arithmetic; every kernel consumes it, slice 1 helpers migrate in | not started | `unminted` |
| `native-protocol/N7` | Shamir over GF(256): split, reconstruct, quorum agreement, corrupted-share detection | not started | `unminted` |
| `native-protocol/N8` | the split store: seal then split, distribution, the return track with disagreement handling | not started | `unminted` |

## Resume state

N1 ran the full pipeline on 2026-09-03: example `77c3867`, EXAMPLE audit
PASS `535c56f`, SPEC `f4f859e`, SPEC audit PASS `54d59b3`. Slice 1 landed the same
day: `lib/crypto/chacha.chiral` green on both RFC 8439 vector rows in
`tools/test/crypto.sh`, mutant run red. The order was re-ruled by the author the same day
([[decisions/decision-quorum-store]]): after slice 2, the pipeline runs N7
with N6 dispositioned inside it (the GF(256) representation and which
helpers migrate to the primitives module are real shape choices), then N2
moves up (entropy feeds share and key generation; it is compiler-touching
and coordinates with the enforcement session), then slices 3 and 4, then N4
beside N8. The `tools/test/run-tests.sh` registration stays owed to the
suite session along with an optional tracked sample fixture. Residue
noted 2026-09-03: `St`/`st` are also defined in
`lib/lowering/upper/lower.chiral`; no current blob co-links them, and a
future blob linking crypto with lowering would collide. After N1: N2 and N3 are
crossings, owed before N4; N5 is the language-development row and leans on
the information-flow deferral recorded in `lib/capability/secret.chiral`'s
header.

The pipeline's working constraint, set by the timeline: zero compiler
changes. The key exchange uses limbs small enough that every product fits
signed I64, and the op-mulhi surface binding stays unbuilt. An audit that
finds the small-limb route unsound flags it instead of reaching for the
binding, because the binding is a `lib/` edit and owes a fixpoint rebuild.
