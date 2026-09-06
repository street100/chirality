---
node: arc-native-protocol
layer: navigation
related: [arcs/README, goals/native-stack, arcs/transport-arc, banks/port, decisions/decision-work-ids, decisions/decision-scope, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-04
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

1. **The transport is ours.** ⚑ Re-scoped by [[goals/own-web]] condition 4, and the wording below predates it: post-quantum throughout, with the configuration derived from the target. `.planning/CRYPTO-MODEL.md` §1 measures the gap and §13 carries the twelve decisions it opens. Two chirality processes complete an
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

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `native-protocol/N1` | the kernels: an AEAD cipher, a hash, a key exchange, the WireGuard suite as reference class. slices 1 and 2 built and gated 2026-09-03, slices 3 and 4 open. ⚑ **The reference class is pre-quantum and [[goals/own-web]] condition 4 states a post-quantum target.** Measured 2026-09-05: zero mentions of post-quantum across this arc, `docs/examples/N01-crypto-kernels.md`, its SPEC and the checklist. `.planning/CRYPTO-MODEL.md` holds the re-scope, and slices 3 and 4 are specced against a suite the target abandons | kernels | primitive | new | 2 | built | `unminted` |
| `native-protocol/N2` | the entropy crossing. not started | crossings | port | new | 3 | open | `unminted` |
| `native-protocol/N3` | listen-side AF_INET, and UDP if the handshake wants it. not started | transport | port | new | 1 | open | `unminted` |
| `native-protocol/N4` | the handshake and framing, Noise reference class, shrednet identity model as base. not started | transport | law | new | 1 | open | `unminted` |
| `native-protocol/N5` | the constant-time judgment: a secret-dependent branch or index is refused mechanically. not started | custody | law | new | 4 | open | `unminted` |
| `native-protocol/N6` | the shared primitives module: word ops, LE codecs, field arithmetic; every kernel consumes it, slice 1 helpers migrate in. not started | kernels | primitive | new | 2 | open | `unminted` |
| `native-protocol/N7` | Shamir over GF(256): split, reconstruct, quorum agreement, corrupted-share detection. pre-run done. Example `92b0660`, EXAMPLE audit PASS `0bd65dd`, `docs/examples/INDEX.md` row reads `reviewed`. SPEC not written | split | law | new | 5 | open | `unminted` |
| `native-protocol/N8` | the split store: seal then split, distribution, the return track with disagreement handling. not started | split | primitive | new | 5 | open | `unminted` |
| `native-protocol/N9` | the universal crossing trait: a crossing's TAL stub synthesized from its declared type, so a new port extends a table instead of TAL code. not started | crossings | law | new | 1 | open | `unminted` |

### Coverage

Every requirement is served: 1 by N3, N4 and N9; 2 by N1 and N6; 3 by N2; 4 by
N5; 5 by N7 and N8. Every row serves one, and every `origin` is `new`: this arc
builds a floor the tree does not have.

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
suite session along with an optional tracked sample fixture. ⚑ Measured
2026-09-04: `tools/test/crypto.sh` carries no `run_phase` line, so it sits
outside the suite's `339 passed, 0 failed` and is run directly. N7 then ran its
pre-run on 2026-09-03:
`docs/examples/N07-shamir-gf256.md` drafted at `92b0660` and audited PASS at
`0bd65dd`, with the agreement theorem repaired and `x=0` refused. Its SPEC is
the next artifact. Residue
noted 2026-09-03: `St`/`st` are also defined in
`lib/lowering/upper/lower.chiral`, and `OpenR` in
`lib/module/resolve.chiral`; no current blob co-links either pair, and a
future blob linking crypto with those modules would collide. The N6
primitives module is the natural fix for the first pair when it lands. After N1: N2 and N3 are
crossings, owed before N4; N5 is the language-development row and leans on
the information-flow deferral recorded in `lib/capability/secret.chiral`'s
header.

The pipeline's working constraint, set by the timeline: zero compiler
changes. The key exchange uses limbs small enough that every product fits
signed I64, and the op-mulhi surface binding stays unbuilt. An audit that
finds the small-limb route unsound flags it instead of reaching for the
binding, because the binding is a `lib/` edit and owes a fixpoint rebuild.
