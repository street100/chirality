# Crypto: the primitive model

**Opened 2026-09-05** from a design session with the author. The crypto half of
`.planning/REACH-MODEL.md`, worked in depth. It settles shape and settles no
build order. Nothing here is minted and no code is touched.

The question this answers: **what the full primitive set is, given a
post-quantum target, and what form it takes so the language derives a
configuration from the hardware instead of a person choosing one.**

Author rulings, 2026-09-05.

| ruling | consequence |
|---|---|
| post-quantum throughout | §1. The reference class N1 was scoped against is pre-quantum |
| we build our own take, splitting the primitives up and giving them native form | §11. A standard's named instantiation becomes a value in a table, and the machine is ours |
| compute belongs at message creation and at reading | `REACH-MODEL` §11. No public-key work on the forwarding path |
| **hardware scaling is automatic at the language level** | §8. A person states a numerical model only at an interop boundary between binaries |

---

## §1 · The finding that forces a re-scope

**Zero mentions of post-quantum anywhere in the crypto scoping.** Measured
2026-09-05 across `docs/examples/N01-crypto-kernels.md`, its SPEC,
`docs/arcs/native-protocol-arc.md` and `.planning/NATIVE-PROTOCOL-CHECKLIST.md`.

N01 states its reference class in its own words: *"a key exchange (X25519, RFC
7748). WireGuard runs on exactly this suite, which is why it is the reference
class."* ChaCha20-Poly1305, BLAKE2s, X25519.

That is a pre-quantum suite. Its four slices deliver a classical stack the
stated target cannot ship on. **Slices 1 and 2 are built and gated against a
reference class the target abandons**, which is `C1` below.

## §2 · The primitive set

| layer | primitives | state |
|---|---|---|
| 0 word | width-indexed words, wrap ops, rotations, LE and BE codecs | `native-protocol/N6`'s row exists. Unscoped |
| 1 permutation | the machine of §4, with at least two instances | unscoped |
| 2 modes | hash, XOF, MAC, KDF, all sponge modes over layer 1 | unscoped |
| 3 tree | a Merkle construction for chunked marks | unscoped |
| 4 AEAD | ChaCha20-Poly1305 | **built.** `C10` asks whether it survives |
| 5 arithmetic | modular reduction, Barrett or Montgomery, NTT and its inverse, the Curve25519 field, `Z_q` at two moduli, GF(256) | N6 row; N7 has a pre-run for GF(256) |
| 6 classical asymmetric | X25519, Ed25519 | X25519 specced as N1 slice 4. **Ed25519 appears nowhere** |
| 7 PQ asymmetric | a KEM, and a signature | unscoped |
| 8 combiner | how two shared secrets become one | unscoped |
| 9 PAKE | a short human-carried secret authenticating an exchange | unscoped |
| 10 entropy | the crossing | `N2`, unstarted |
| 11 constant time | the checked judgment | `N5`, unstarted |

## §3 · The word layer, and why nothing may name `I64`

`docs/decisions/decision-numeric-width-pluggable.md`, decided 2026-08-10, sets
the direction: **the integer word-width is pluggable, configured per moduleset
as a named conformant `NumProfile`, and `I64` is the default profile and not
the floor.** It records that the earlier framing, a fixed source-level I64
floor with width flexing only at the backend, was retracted as a cop-out. Its
stated purpose is that *nothing is built that silently re-hardcodes 64-bit*.

A `NumProfile` fixes the width `W`, wrap and Euclidean div and mod at that
width, the slot size, the refinement engine's bounds over `W`, and which
codegen arms fire. **A kernel written against `I64` defeats all five.**

**The form is expressible today.** `lib/protocol/grid.chiral:28` declares
`(data Grid ((n I64))`, and `lib/ports/pool.port:27` and
`lib/memory/mem-linear.chiral:15` carry `(-> (0 n I64) (=> …))`. Indexed data
with a quantity-0 erased index is in use in `lib/` now, so layer 0 is a
**library element rather than a language one**.

`lib/memory/mem-region.chiral` also carries the idiom for the case where the
erased index is needed at runtime: a capacity witness travels beside it,
agreeing with the index by construction.

`lib/crypto/chacha.chiral` is the counter-example to generalise off. It masks
with `M32` on every operation because 32-bit lanes live inside signed `I64`.
Over a width-indexed word that masking is the profile's business.

## §4 · The permutation machine

Keccak and Ascon are the same shape at different row counts. Both apply a
**bitsliced 5-bit S-box across five lanes**, computed with boolean operations
on whole words.

| | lanes | arrangement | has a lane-permutation step |
|---|---|---|---|
| Keccak-f[1600] | 25 | **5 rows of 5**, `w` = 64 | yes, to move data between rows |
| Keccak-f[800] | 25 | 5 rows of 5, `w` = 32 | yes |
| Ascon-p | 5 | **1 row of 5**, `w` = 64 | no, because one row needs no cross-row movement |

So one machine covers both: **`rows` rows of 5 lanes of width `w`**, an S-box
across each row, a linear layer, a round constant. **The lane permutation is a
function of `rows` and becomes the identity at `rows = 1`**, so Ascon's missing
step needs no special case.

| the machine carries | Keccak-f[1600] | Ascon-p |
|---|---|---|
| `rows` | 5 | 1 |
| lane width `w` | 64 | 64 |
| rounds, a type index | 24 | 12 |
| the S-box, a value | χ | its own, chosen for stronger per-round properties |
| the linear layer, a value | θ | the Σ functions |
| the constant schedule | an LFSR derivation | its own |
| the lane permutation | derived from `rows` | identity, derived from `rows = 1` |

Keccak-f[800] arrives free as `rows = 5, w = 32` for the 32-bit profile.

**Two instances is the point.** One instance proves nothing about whether the
abstraction constrains anything, which is the tree's own rule about
abstractions earning their keep.

## §5 · Implying the computation

Of the five steps in a Keccak-shaped round, three cost less than they appear to
and two are the real work.

| step | what it does | cost |
|---|---|---|
| the linear layer | column parity across five, one rotation, XOR back into every lane | **real** |
| the rotation layer | rotate each lane by a fixed per-position offset | **cheaper.** The table lookup and the index arithmetic disappear against named lanes. The rotation itself stays three ops, because the closed `Op` sum has no rotate and the backend emits shift, shift, or |
| the lane permutation | move lane (x,y) to (y, 2x+3y) | **free.** Pure reindexing. Nothing is computed |
| the S-box | the only nonlinear step | **real**, and the largest single cost |
| the round constant | XOR into one lane | **free.** Derivable from the LFSR at compile time |

## §6 · Constant time by construction

**The state is a record of named lanes with no array.**

| what follows | why |
|---|---|
| the lane permutation costs nothing | it is which field is read next |
| the rotation layer needs no table | one rotate-by-literal per named lane |
| no bounds check appears anywhere | there is no index to check |
| **a secret-dependent index has no spelling** | there is no index at all |
| the round is straight-line and total | no branch, so nothing to balance |

**The permutation is constant-time by construction, so `N5` has nothing left to
prove about it.** The failure mode is removed by the form instead of caught by
a checker, which is the substrate rule applied to crypto. `N5`'s work then
concentrates where secrets meet indices, which is the field arithmetic and the
sampling rather than the permutation.


## §7 · The sponge, and the relationship between its parameters

| | |
|---|---|
| state | `b = rows × 5 × w` |
| rate | `rate = b − c` |
| security | `c ≥ 2 × S` |
| work per permutation | `≈ lanes × k × R` |
| **work per output byte** | `(rows × 5 × k × R × 8) / (rows × 5 × w − c)` |
| memory | `b / 8` bytes |

**Capacity is the one term that does not scale.** `c ≥ 2S` is fixed by the
security target, so **rate is the surplus after security is paid** and growing
the state grows only the rate.

Derived at `w = 64`, `S = 128` so `c = 256`, `k ≈ 9`, `R = 24`. ⚑ `k` is
estimated from the step counts in §5 and has never been measured.

| rows | state | rate | ops per byte |
|---|---|---|---|
| 1 | 320 b | 8 B | ~135 |
| 5 | **1600 b** | 168 B | **~32** |
| 10 | 3200 b | 368 B | ~29 |
| 20 | 6400 b | 768 B | ~28 |
| → ∞ | | | 27, the asymptote `k·R·8/w` |

**The curve has a knee and a 1600-bit state sits on it.** Below it the capacity
floor eats the state and compute explodes; above it almost nothing is bought.

It also answers the low-memory end honestly: **small memory intrinsically means
many permutation calls per byte**, because the security floor is fixed. Memory
buys throughput linearly and the exchange rate is set by `S`.

**The relationship rides as refinements over the indices.**

| constraint | what it makes impossible |
|---|---|
| `rate + c = rows × 5 × w` | a parameter set that does not close |
| `c ≥ 2 × S` | a configuration that silently misses its security target |
| `R ≥ rounds-for(sbox, S)` | a round count below what its S-box needs |
| a required domain-separator field | building a sponge without saying what it is for, which deletes cross-purpose reuse structurally |
| the padding rule as a value | a magic byte in the wrong place |
| the round count as a type index | shipping a reduced-round variant by accident, since the test variant and the real one are different types |
| a rotation amount at `(refine I64 (>= 0) (< w))` | an out-of-range rotation, at compile time |

## §8 · Automatic hardware scaling

**The configuration is derived from the target rather than chosen by a person.**

| supplied by | fixes |
|---|---|
| the target's `NumProfile` | `w` |
| the target's memory budget | `rows` |
| the security requirement | `c` |
| derived from those | `rate` |
| the chosen S-box | `R` |

A person writes `hash`. The moduleset's target supplies the width and the
budget and every other parameter is computed. This is the same seam the tree
already has three times: memory disciplines are moduleset-configured,
`NumProfile` makes width moduleset-configured, and `Mach` makes the backend an
instance.

**This is the structural argument for a family and against a point.** A design
fixed at one state size and one lane width cannot scale automatically, so
adopting it as the base forfeits the property. Keccak-f[b] is defined across
lane widths 1 through 64 with one offset table taken mod `w`, so the 8, 32 and
64-bit members are one module. Ascon-p is one point, which is why it is a
second instance rather than the base.

**Interoperation needs no negotiation.** `REACH-MODEL` §3's mark carries an
`alg` field.

| | |
|---|---|
| a small node | produces marks under the configuration its target derived |
| a large node | verifies them, because the mark names the configuration |
| what verification requires | **the machine alone. A matching configuration is unnecessary** |

So a mesh spanning a constrained node and a server interoperates without either
adopting the other's limits, and **there is no downgrade surface because there
is no negotiation**. With the configuration inside the domain separator, two
parties on different configurations produce different outputs for one input, so
they fail to agree instead of agreeing on the weaker. Cross-configuration
confusion becomes unconstructible.

**A shared value names its configuration in its mark. A node's local work is
free**, because nothing else has to reproduce it.

## §9 · The two candidates, measured against our goals

### Security margin

| | rounds | best attacks reach | margin |
|---|---|---|---|
| Keccak-f[1600] | 24 | 5 to 6 for collisions and preimages, practical ones at 3 to 5 | **~4x** |
| Ascon-p | 12 | 7 on the AEAD, varying by variant, some in restricted key classes | **~1.7x** |

Keccak carries a four-year public competition plus thirteen further years of
attention. Ascon's proven bounds cover three rounds, with four rounds shown to
bound a single characteristic at 2^-72, so most of its assurance rests on the
absence of found attacks.

**Ascon is deliberately margined thin**, which is what lightweight means: it
trades margin for state size and operation count on constrained hardware.

### Throughput

| | ops per round | rounds | rate | ops per byte |
|---|---|---|---|---|
| Keccak-f[1600] | ~216 | 24 | 168 B | **~31** |
| Ascon-p | ~63 | 12 | 8 B | **~95** |

**Keccak is roughly three times cheaper per byte.** Its state is 7x larger and
its rate 21x larger, so the larger permutation repays itself. **Ascon's win is
memory alone**, which is worth little where 200 bytes of state is
affordable and worth everything where it is not. That is precisely the axis §8
scales along.

## §10 · Eliminations, and one reframe

| candidate | verdict |
|---|---|
| **FALCON** | **eliminated structurally.** It requires floating point, and `docs/decisions/decision-display-numerics.md` records the closed fifteen-op integer sum and what adding `F64` costs. This removes it on a tree fact rather than a preference |
| **SLH-DSA** | **the cheapest PQ signature to build natively.** Pure hash: no field arithmetic, no NTT, no sampling beyond the XOF already needed. A few hundred lines over a permutation that is already there. Its cost is signatures in the tens of kilobytes |
| ML-DSA | lattice machinery, the largest single kernel in the set |

**Signatures appear only on the mutable-pointer layer**, fetched once and
cached, so a large signature is charged where it is
cheapest. That trade has never been examined and `C3` records it.

## §11 · Our own take

We build a permutation family and a sponge machine. **A standard's named
instantiation becomes a value in a table rather than the thing implemented.**

| named value | what it is |
|---|---|
| our mark digest | our rate, our capacity, our domain separator |
| our KDF and our MAC | the same machine, different domain separators |
| our tree mode | for chunked marks |
| the conformant entries | the same machine at the parameters a downstream scheme requires |

Same machine, our configurations, and the conformant entries cost nothing extra
because they are rows rather than implementations.

**The line, stated once.** Re-forming a scheme's internals as typed chirality
pieces leaves the mathematics untouched. Changing the mathematics is a
different act with different consequences. §13 records where each scheme's line
sits as a decision rather than assuming one.

## §12 · What is in the tree

Measured 2026-09-05.

| piece | state |
|---|---|
| ChaCha20 | **built and gated.** `lib/crypto/chacha.chiral`, 163 lines, RFC 8439 rows G1 and G2 |
| Poly1305 and the AEAD composition | **built and gated.** 245 lines, rows G3 to G5 |
| BLAKE2s, X25519 | specced as N1 slices 3 and 4, unbuilt, against the retired reference class |
| a collision-resistant digest | **absent** |
| indexed data with an erased index | **in use.** `grid.chiral:28`, `pool.port:27`, `mem-linear.chiral:15` |
| a runtime witness beside an erased index | **in use.** `mem-region.chiral` |
| the interface-plus-instances idiom | **in use.** `Alloc`, `Mach` |
| the ordered total fold | **in use.** `grid.chiral`'s `fold-sgr`, `apply-one` with no default arm |
| vectors as declared data | **absent.** `tools/test/crypto.sh` holds RFC constants across 403 lines of shell |
| the gate's home | `crypto.sh` carries `not-a-phase` and sits outside the dispatch table with three other scripts waiting on the standing suite-number author call |
| `op-mulhi` | in the `Op` sum with no surface extern. `E189`, minted, unbuilt |

**The small-limb bet holds.** X25519 at ten limbs of 25 and 26 bits gives
52-bit products; a KEM at a 12-bit modulus gives 24-bit products; a lattice
signature at a 23-bit modulus gives 46-bit products. All fit signed I64 with
accumulation room, so **`E189` stays unneeded and no kernel owes a fixpoint**.

## §13 · Decisions owed

| id | decision |
|---|---|
| C1 | what happens to N1's four slices, two of them built and gated against a reference class the target abandons |
| C2 | the machine's initial instances, and whether Ascon-p is one of them |
| C3 | the PQ signature: ML-DSA against SLH-DSA, with FALCON eliminated |
| C4 | where each scheme's decompose-against-change line sits |
| C5 | the hybrid combiner construction |
| C6 | whether `N5` lands before the kernels, since scoping it after means writing every kernel twice |
| C7 | vectors as a `.manifest` against shell |
| C8 | the security target `S`, which fixes the capacity floor and therefore the whole curve |
| C9 | how a target states its memory budget, which is the input §8's derivation lacks |
| C10 | whether ChaCha20 and Poly1305 are retired by an AEAD mode over the same machine |
| C11 | the limb representation for field arithmetic, and whether a limb carries its bit bound |
| C12 | whether the sponge's absorb and squeeze state is linear |

## §14 · Notes to cover

- **`shl` and `shr` at width 64**, and whether a shift of 64 is defined. A
  rotation needs `(bor (shl x n) (shr x (- w n)))` and the `n = 0` case shifts
  by the full width. ChaCha20 only ever shifts within 32, so this tree has
  never exercised it
- **`k`, the real ops per lane per round**, measured for each S-box and linear
  layer in this tree's instruction set. The whole §7 curve scales off it and it
  is estimated
- what one permutation call allocates, against the region work
- the round-constant schedule derived against transcribed
- how the domain separator is encoded, and whether the configuration rides in it
- the tree mode for chunked marks, and its domain separation
- the byte-to-lane codec's endianness, and whether it is a profile choice
- Ed25519 appears in no document and the hybrid signature needs it
- how far a KEM's sampler entangles with its hash, which is where §11's line is
  hardest to draw
- the error and refusal vocabulary, since a refusal with no name is the silent
  arm `render.chiral:167` already demonstrates

## §15 · Relation to the arc and the reach model

`docs/arcs/native-protocol-arc.md` rows `N1`, `N2`, `N5`, `N6` and `N7` are the
tracked homes for this work and were written against the pre-quantum reference
class. **Rewriting `N1`'s row and the arc's requirement 1 against a
post-quantum target is owed and undone.**

`.planning/REACH-MODEL.md` §11 lists eight primitives with their positions on
the per-pairing to per-parcel axis, and that table stays the authority for
**where** each primitive is spent. This file is the authority for **what each
one is and what form it takes.**
