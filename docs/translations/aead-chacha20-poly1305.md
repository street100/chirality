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

⚑ **This artifact is partial and says so.** Three of four gather slots are
`UNRUN`, and the one pin it rests on is `transcribed` rather than `raw`.

| slot | source | state |
|---|---|---|
| construction | `RFC8439`, **transcribed** | run |
| properties | `RFC9771`, Properties of AEAD Algorithms | **UNRUN** |
| limits | draft-irtf-cfrg-aead-limits-07 | **UNRUN** |
| known-gaps | key commitment, partitioning oracles | **UNRUN** |

`RFC8439` was transcribed from the verbatim spans of a fetch on 2026-09-07,
because raw egress is unavailable here. A binding obligation absent from the
transcription may still be in the RFC, so §9's count is a floor.

**The properties slot is the one that matters most.** A session working this
object from memory produced two of the property set. The published enumeration
is the deliverable of §2 and remains unpinned, so §2 below covers the
construction alone.

## 2. Object

An AEAD is a keyed family with a partial inverse. `Seal : K × N × A × P → C`
and `Open : K × N × A × C → P ∪ {⊥}`, with `⊥` naming exactly the complement of
Seal's image under that key. The correctness law is
`Open(k, n, a, Seal(k, n, a, p)) = p`.

The construction, from the pin:

| | |
|---|---|
| the one-time MAC key | RFC8439:7 "The block counter is set to zero." |
| encryption offset | RFC8439:14 "The ChaCha20 encryption is done with a block counter starting at 1." |
| the MAC input | RFC8439:15 "mac_data = aad | pad16(aad) | ciphertext | pad16(ciphertext)" |
| the padding rule | RFC8439:18 "the padding is up to 15 zero bytes, and it brings the total length so far to an integral multiple of 16." |
| the sizes | RFC8439:19 "The key is 32 bytes, the nonce is 12 bytes, and the tag is 16 bytes." |

**The precondition the whole object rests on**, ranked first by the RFC itself:
RFC8439:22 "The most important security consideration in implementing this
document is the uniqueness of the nonce used in ChaCha20."

Its consequence is stated rather than left to the reader: RFC8439:23 "If a nonce
is repeated, then both the one-time Poly1305 key and the keystream are identical
between the messages."

⚑ The formal notions this construction is proved against, and the twenty-plus
further properties an AEAD may or may not have, wait on the `properties` slot.

## 3. Conventional

Generated from the binding obligations. Each is a duty the reference signature
cannot carry, so each is a bug class.

| obligation | in a C signature |
|---|---|
| nonce uniqueness, RFC8439:22 | a pointer the caller promises is fresh |
| RFC8439:24 "The Poly1305 key MUST be unpredictable to an attacker." | a buffer anyone can fill |
| RFC8439:26 "Tag truncation MUST NOT be done" | a length parameter |
| RFC8439:25 "implementation MUST use a constant-time comparison function rather than relying on optimized but insecure library functions such as the C language's memcmp()." | a call site nothing checks |

## 4. Carriers

Precedent counts from `tools/xlat/xlat.sh carriers`, comments excluded.

| obligation | carrier | precedent |
|---|---|---|
| nonce uniqueness | a linear `Nonce` yielded by a linear source, consumed by `seal` | linear binder, 142 uses. `lib/ports/pool.port:27` |
| Poly1305 key unpredictable | one constructor at counter 0, with no path from arbitrary bytes | closed sum, 6 uses |
| no tag truncation | `Tag` as a fixed 16-byte type carrying no truncating operation | refinement, 8 uses. `lib/ports/sock.port:69` |
| unverified plaintext never released | `OpenR` closed sum, case coverage checked | `lib/protocol/grid.chiral` `apply-one`, no default arm |
| the kernel reads no clock and no RNG | `(cat A)` and the empty effect row by derivation | 15 modules |

⚑ **One carrier is blocked.** Carrying the domain separator as an erased index
on the sealed value walks into a measured lowering gap:
`lib/lowering/upper/specialize-singleton.chiral:99-118` matches a projector as
exactly one `t-lam`, so an indexed function-bearing record does not lower.
`Sealed` carries no function fields, which puts it in the class that does lower
(`lib/memory/mem-region.chiral:31`), and that needs measuring rather than
assuming.

## 5. Refusals

Derived from §4. Each stops being constructible.

| | |
|---|---|
| reusing a nonce under one key | the nonce is consumed by `seal` |
| discarding the authentication result | `open` returns a closed sum and coverage is checked |
| opening against the wrong nonce | the nonce rides inside `Sealed` |
| supplying the one-time MAC key directly | it has one constructor |
| truncating the tag | no operation produces a shorter one |
| reading a clock or an RNG inside the kernel | the effect row is empty by derivation |

## 6. Invariant core

The arithmetic does not move. Counter 0 for the MAC key, counter 1 for the
stream, the same MAC input in the same order, the same padding to a multiple of
16, the same 64-bit little-endian lengths, the same 32, 12 and 16 byte sizes.
**RFC 8439's published vectors apply unmodified**, which is what makes this a
translation.

## 7. Laws and pins

| instrument | reaches |
|---|---|
| the correctness law | `Open(k, n, a, Seal(k, n, a, p)) = p` over arbitrary inputs |
| a law | a tampered ciphertext or a tampered `aad` yields `op-bad` |
| a pin | the published vectors, which fix the arbitrary constants. Constants carry no structure, so a vector is the only instrument that reaches them |

The vector rows for this object already run: `tools/test/crypto.sh` at suite
phase 31, registered at `tools/test/run-tests.sh:367`.

## 8. Push

Generated by crossing the properties this object lacks against the carriers
available. **Partial, because the `properties` slot is `UNRUN`** and the
property list is the left half of that cross.

What is visible from the construction alone: the object offers no protection
against nonce reuse, and RFC8439:23 states the consequence. Linearity does not
add a property to the object. It removes the ability to violate the
precondition, which reaches the same safety by a route the standard cannot
express.

## 9. Limits

One binding obligation reaches no carrier: RFC8439:25 requires a constant-time
comparison, and chirality has no timing model. The form argument holds, folding
over all sixteen bytes before one comparison, and the typed claim does not.
`native-protocol/N5` is the row that owns this.

⚑ **This count is a floor.** It covers the binding obligations present in a
transcription, over one of four gather slots.
