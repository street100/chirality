---
node: translation-aead-chacha20-poly1305
layer: reference
related: [translations/README, definitions/working-discipline, index]
status: draft
updated: 2026-09-07
---

# Translation: aead-chacha20-poly1305

> One published object rendered into this tree's forms. The mathematics is
> external and stays external. Every quote carries a pinned citation in the
> form `ID:LINE "span"`, resolvable by `tools/xlat/xlat.sh check`.

## 1. Source

| slot | source | state |
|---|---|---|
| construction | `RFC8439`, raw, 2,579 lines | run |
| properties | `RFC9771`, raw, 1,344 lines | run |
| limits | `AEADLIMITS`, draft-irtf-cfrg-aead-limits-07, raw, 1,120 lines | run |
| known-gaps | the partitioning-oracle literature | **UNRUN** |

Binding obligations by source: 10 in `RFC8439`, 5 in `RFC9771`, 1 in
`AEADLIMITS` which is the RFC 2119 boilerplate rather than a duty.

⚑ **The known-gaps slot decides §8 and stands UNRUN.** §2 records that key
commitment exists as a property and says nothing about whether this
construction has it.

## 2. Object

An AEAD is a keyed family with a partial inverse. `Seal : K × N × A × P → C`
and `Open : K × N × A × C → P ∪ {⊥}`, with `⊥` naming the complement of Seal's
image under that key. The correctness law is
`Open(k, n, a, Seal(k, n, a, p)) = p`.

The construction, from the pin. The one-time MAC key comes from a zeroth block,
RFC8439:994 "The block counter is set to zero.", and the stream starts one
block later, RFC8439:1250 "ciphertext = chacha20_encrypt(key, 1, nonce, plaintext)".
The MAC covers associated data and ciphertext, each padded, under the rule
RFC8439:1137 "padding1 -- the padding is up to 15 zero bytes, and it brings"
the total to a multiple of 16, and padding2 carries the same rule. The output is RFC8439:825 "The output is a 128-bit tag."

**The precondition the object rests on**, ranked first by the RFC itself:
RFC8439:1423 "document is the uniqueness of the nonce used in ChaCha20." Its
consequence is stated rather than left to the reader, RFC8439:1430
"Consequences of repeating a nonce: If a nonce is repeated, then both" the
one-time key and the keystream repeat.

**The property set.** RFC 9771 defines **21** properties an AEAD may carry: 3
conventional, 10 security, 8 implementation. Counted from the section headings
in the pinned body. Two bear directly on the carriers below.
Nonce misuse, RFC9771:549 "even if an adversary can repeat nonces in its encryption queries.",
and streaming, RFC9771:790 "implemented with constant memory usage and a single one-direction".
A third bounds what any translation can claim: key commitment, RFC9771:395
"AEAD scheme guarantees that a ciphertext is a commitment to the" key.

## 3. Conventional

Generated from the binding obligations. Each is a duty the reference signature
cannot carry, so each is a bug class.

| obligation | in a C signature |
|---|---|
| nonce uniqueness, RFC8439:1423 | a pointer the caller promises is fresh |
| RFC8439:1435 "The Poly1305 key MUST be unpredictable to an attacker." | a buffer anyone can fill |
| tag truncation, RFC8439:1484 "MUST NOT be done." | a length parameter |
| RFC8439:1478 "implementation MUST use a constant-time comparison function rather" than memcmp | a call site nothing checks |

## 4. Carriers

Precedent counts from `tools/xlat/xlat.sh carriers`, comments excluded.

| obligation | carrier | precedent |
|---|---|---|
| nonce uniqueness | a linear `Nonce` yielded by a linear source, consumed by `seal` | linear binder, 142 uses. `lib/ports/pool.port:27` |
| the one-time MAC key is unpredictable | one constructor at the zeroth block, no path from arbitrary bytes | closed sum, 6 uses |
| no tag truncation | `Tag` as a fixed 16-byte type carrying no truncating operation | refinement, 8 uses. `lib/ports/sock.port:69` |
| unverified plaintext never released | `OpenR` closed sum, case coverage checked | `lib/protocol/grid.chiral` `apply-one`, no default arm |
| the kernel reads no clock and no RNG | `(cat A)`, empty effect row by derivation | 15 modules |

⚑ **One carrier is blocked.** Carrying a domain separator as an erased index on
the sealed value walks into a measured lowering gap:
`lib/lowering/upper/specialize-singleton.chiral:99-118` matches a projector as
exactly one `t-lam`, so an indexed function-bearing record does not lower.
`Sealed` carries no function fields, which puts it in the class that does lower
(`lib/memory/mem-region.chiral:31`), and that needs measuring.

## 5. Refusals

| | |
|---|---|
| reusing a nonce under one key | the nonce is consumed by `seal` |
| discarding the authentication result | `open` returns a closed sum and coverage is checked |
| opening against the wrong nonce | the nonce rides inside `Sealed` |
| supplying the one-time MAC key directly | it has one constructor |
| truncating the tag | no operation produces a shorter one |
| reading a clock or an RNG in the kernel | the effect row is empty by derivation |

## 6. Invariant core

The arithmetic does not move. The zeroth block for the MAC key, block 1 for the
stream, the same MAC input in the same order, the same padding to a multiple of
16, the same little-endian lengths, the same 128-bit tag. **RFC 8439's
published vectors apply unmodified**, which is what makes this a translation.

## 7. Laws and pins

| instrument | reaches |
|---|---|
| the correctness law | `Open(k, n, a, Seal(k, n, a, p)) = p` over arbitrary inputs |
| a law | a tampered ciphertext or a tampered `aad` yields `op-bad` |
| a pin | the published vectors, which fix the arbitrary constants. Constants carry no structure, so a vector is the only instrument that reaches them |

The vector rows already run: `tools/test/crypto.sh` at suite phase 31,
registered at `tools/test/run-tests.sh:367`.

## 8. Push

Generated by crossing the properties the object lacks against the carriers
available. **The left half is incomplete while `known-gaps` is UNRUN.**

RFC9771:549 "even if an adversary can repeat nonces in its encryption queries."
names the property class this construction sits outside, and RFC8439:1430
states the consequence of reuse plainly. Linearity
adds no property to the object. It removes the ability to violate the
precondition, which reaches the same safety by a route the standard has no way
to express.

RFC9771:395 "AEAD scheme guarantees that a ciphertext is a commitment to the"
key names key commitment. **No carrier here reaches it**, and whether this construction has it is the ungathered
question. It is a property of the object rather than of the rendering.

## 9. Limits

One binding obligation reaches no carrier. RFC8439:1478 "implementation MUST
use a constant-time comparison function rather" than an optimized library
function, and chirality has no timing model. The form argument holds, folding
over all sixteen bytes before one comparison. The typed claim does not.
`native-protocol/N5` owns this row.
