# Crypto: the translation model

**Opened 2026-09-07** from a design session with the author. It states the frame
`.planning/CRYPTO-MODEL.md` was written under and the frame it should have been
written under. It settles frame and settles no build order. Nothing here is
minted and no code is touched.

The question this answers: **what the work is, given that the mathematics is
published and external, and what has to be specified for a strong machine and a
weak machine to reach one guarantee at different costs.**

Author rulings, 2026-09-07.

| ruling | consequence |
|---|---|
| this is translation work | §1. The mathematics is fixed, published and external |
| every named scheme is an example | §1. Keccak, Ascon, ChaCha20, Poly1305, X25519, ML-KEM and SLH-DSA are reference class, and none of them is the thing built |
| **the guarantee is invariant across hardware** | §3. A weak device pays in time and footprint and reaches the same security level |
| **a weaker device never settles for a lower guarantee** | §4. A target below the floor gets a refusal |
| we give best representations | §2, §10. Optimization lives in the representation and leaves the object alone |

---

## §1 · The frame

The mathematics is published, analyzed, and external. The work is expressing it
in a lens where a mathematical object's invariants are a type's invariants. The
lens is the new thing. **Fidelity is the criterion.**

A parameter exists here when the mathematics has one.

| object | parametric in | members |
|---|---|---|
| Keccak-f[b] | the lane width `w` | `b = 25w`, `w = 2^ℓ` for ℓ = 0 to 6, with `R = 12 + 2ℓ` |
| Ascon-p | nothing | one permutation on 320 bits, 5 lanes of 64 |
| GF(2^130 − 5) | nothing | one field |
| Z_q[X]/(X^n + 1) | `q` and `n` | a family |

`.planning/CRYPTO-MODEL.md` §4 merges Keccak and Ascon into one machine
parameterized by a `rows` dial. **Keccak-f is 5 rows of 5 lanes at every member
and varies only `w`**, so `rows` is a parameter neither object has. The merge
states a relationship between two objects that the mathematics does not state.
The faithful statement is that a sponge takes a permutation, Keccak-f[b] is a
family of permutations, and Ascon-p is a permutation.

## §2 · The object and its representations

| | is | carries | varies with |
|---|---|---|---|
| **the object** | the mathematical thing | the laws, and the security argument | nothing. There is one |
| **a representation** | an encoding of the object in machine terms | the cost | the target |

Every representation is proven equivalent to the object. **Security is a
property of the object and cost is a property of the representation**, so
invariance of the guarantee across representations is derived and no
representation restates it.

Three worked cases, all published, all computing an identical function.

| object | representations | selected by |
|---|---|---|
| Keccak-f[1600] | lane-oriented, one lane per machine word · bit-interleaved, a 64-bit lane split into even and odd bits so a rotation becomes two 32-bit rotations · bitsliced, the state transposed so one word holds one bit position across lanes | the target's word width, and whether it has vector lanes |
| GF(2^255 − 19) | 10 limbs alternating 26 and 25 bits · 5 limbs of 51 bits · 4 limbs of 64 bits | the word width, and whether a widening multiply exists. Without `op-mulhi` the 5-limb form needs 102-bit products and is unavailable, which is a target fact rather than a design choice |
| GF(2^8) | log and antilog tables · carry-less multiply · bitsliced | the word width, and whether table lookups are admissible where the index is secret |

**`NumProfile` is already the representation selector.**
`docs/decisions/decision-numeric-width-pluggable.md` makes width a
moduleset-configured conformant profile. The facts a representation needs from
its target are the facts that decision already routes: the width, the available
arithmetic, and which codegen arms fire.

## §3 · One security level, a cost curve

Every target reaches the same guarantee. **Time and resident footprint are what
vary.**

The sponge gives this without being asked. Capacity is fixed by the security
target alone and rate is the surplus after security is paid. A small state keeps
the whole capacity and buys a small rate, so it pays permutation calls per byte
and its guarantee is untouched.

**The bound carries two terms.** Generic collision work against a sponge is
`2^min(n/2, c/2)`, with `n` the output length. Capacity alone fixes nothing.
SHA3-256 runs `c = 512` and delivers 128-bit collision resistance, because its
256-bit output caps it; the surplus capacity buys preimage and indifferentiability
margin.

So the mark's length sets the security level and the state floor follows from it.

| target | mark | `c` | smallest Keccak member | state | rate |
|---|---|---|---|---|---|
| 128-bit collision | 256 b, 32 B | 256 | Keccak-f[400], 20 rounds | **50 B** | 144 b, 18 B |
| 256-bit collision | 512 b, 64 B | 512 | Keccak-f[800], 22 rounds | **100 B** | 288 b, 36 B |

**128-bit collision resistance is a post-quantum level.** NIST Category 2 is
defined as SHA-256 collision resistance. The BHT quantum collision algorithm
reaches `2^(n/3)`, so `2^85` against a 256-bit digest, and it is discounted
because it requires `2^85` of queryable quantum memory.

**The footprint lives elsewhere.** Two measurements against the state:

| | size |
|---|---|
| a 128-bit-target permutation state | 40 to 50 B |
| ML-KEM-768 encapsulation key, ciphertext | 1,184 B, 1,088 B |
| SLH-DSA-128s signature | 7,856 B |
| SLH-DSA-256f signature | ~49,856 B |

A 50-byte permutation state is 0.6% of one small SLH-DSA signature. **The real
per-byte cost of the security level is the mark's own length**, paid on every
address, every reference and every holdings summary, permanently.

`T9` carries the mark-length decision. Nothing in this file picks it.

**What optimizes, ranked.**

| lever | effect |
|---|---|
| the keyed and unkeyed capacity split | large. The exact-security analysis of Ascon finds `c = 128` at `b = 320` sufficient for the NIST lightweight requirements, freeing a 192-bit rate. A MAC, an AEAD and a KDF should not pay the mark digest's capacity |
| `access = windowed` | the genuine footprint dial. Resident memory falls below `b` and `c`, `rate` and the security target hold |
| the representation | ops per byte move hard. State size holds |
| the permutation's state size | 10 bytes across three candidates at one target |

**At a 256-bit mark, three permutations are conformant** and the choice falls to
other terms.

| | state | rounds |
|---|---|---|
| Ascon-p, Ascon-Hash256 at `c = 256`, `n = 256` | 40 B | 12 |
| Xoodoo, Xoodyak's hash mode at rate 16 B and capacity 32 B | 48 B | 12 |
| Keccak-f[400] | 50 B | 20 |

`.planning/CRYPTO-MODEL.md` `C2` stands open. Ascon-p is out only at a 512-bit
mark, where a 512-bit capacity exceeds its 320-bit state.

## §4 · What a target below the floor gets

A refusal. It does not get a weaker configuration.

This is the mechanism that makes §3 a property instead of an intention. A
configuration whose state cannot hold the capacity its security target demands
fails to construct, which is the shape `.planning/CRYPTO-MODEL.md` §7 already
lists as a refusal, applied to the case it was written for.

## §5 · What the lens carries

A faithful translation moves a mathematical fact out of the commentary and into
a form that refuses its violation.

| mathematical fact | how it usually travels | the carrier here |
|---|---|---|
| **the Poly1305 key is one-time** | a comment, in every reference implementation | **linearity.** Carter-Wegman security holds only under non-reuse, so the precondition of the theorem and the type are one object, and reuse has no spelling |
| this loop is a finite product over a fixed index set | a `for` | totality, by the numeric measure |
| a limb is bounded by `2^26` | an invariant stated in a paper | a refinement |
| a field element is reduced | tracked by hand | a refinement, so reduced and unreduced are different types |
| the index set is finite and named | a `#define` and a table | a closed sum |
| the round count is fixed by cryptanalysis | a constant | a type index, so a reduced-round variant is a different type and cannot be shipped by accident |
| the function is a function | convention | the `->` membrane, with an empty effect row by derivation |
| a secret never indexes | code review | named lanes with no array, so a secret-dependent index has no spelling |

## §6 · What makes it secure, stated as a split

| the claim | whose it is | how it is discharged |
|---|---|---|
| the object is secure | external. Published cryptanalysis, competitions, years of attention | cited. This tree reproduces none of it |
| a representation computes the object | **ours** | §7 |
| the composition is used correctly | ours | domain separation, one-time keys, the mode's own argument |

The security argument attaches to the object. Our whole obligation is that a
representation computes it. This is why the work is tractable: nothing here
tests whether Keccak is secure.

**The limit.** Chirality has no timing model, so constant-time is a
property of the form and stays outside the type system. §5's last row removes
secret-dependent indexing by construction. A claim beyond that needs an
instrument this tree does not have.

## §7 · The assurance model

Three instruments. Each catches a class the others miss.

| instrument | catches | why it works |
|---|---|---|
| **the laws** | structural error | the mathematics is a structure. Field axioms, bijectivity, the ladder invariant, reduction idempotence, and the representation round trip are what the object is |
| **differential across representations** | implementation error | two representations of one object agree by construction, and their agreement is the correspondence §2 owes anyway |
| **published vectors** | specification misreading, and constant transcription | constants have no structure to check. Sigma tables, IVs, round constants and the ChaCha20 state words are arbitrary, and a vector is the only instrument that reaches them |

**The multi-representation design restores the differential floor.**
`docs/definitions/testing-floors.md` records the rocq floor, the Python oracle
and the `Mach`-to-C leg all cut, leaving one gating floor and the
run-the-mutant rule. Two representations of one object differ in all of their
arithmetic, so they are semantically distinct in the sense
`docs/decisions/decision-self-verification.md` requires, and the `Mach`-to-C
leg's defect of sharing everything but emit does not apply.

⚑ **One class survives all three when two representations are written by one
session against one reading of the specification.** A shared misreading passes
the laws and passes the differential. Vectors are the instrument for it, which
fixes their role instead of leaving them as the whole gate.

## §8 · Testing efficiently

**The smallest member of a family is the same mathematics and is exhaustively
checkable.**

| family | smallest member | what becomes exhaustive |
|---|---|---|
| Keccak-f[b] | Keccak-f[25], `w = 1`, 12 rounds | 2^25 states, so bijectivity of the whole permutation is enumerable |
| GF(2^8) | itself, 256 elements | every field axiom, every inverse, at 65,536 pairs |
| Z_q[X]/(X^n + 1) | small `q` and `n` | the NTT and its inverse round trip, over the whole space |

**Bijectivity never needs a search at `b = 1600`.** Every step of a Keccak round
is a bijection on its own: χ is a 5-bit S-box, exhaustive at 32 inputs
regardless of `b`; θ is linear over GF(2), so it is a rank computation; π
reindexes lanes; ρ rotates; ι xors a constant. The permutation is a bijection by
composition, and each component's proof is local and cheap. A faithful
translation gets this because the type says permutation and the composition is
visible.

This is the efficiency argument for the whole frame. The expensive tests are the
ones aimed at a structure the code does not carry.

## §9 · Where this leaves `.planning/CRYPTO-MODEL.md`

| section | standing |
|---|---|
| §1 the post-quantum finding | holds. It is a fact about the objects |
| §2 the primitive set | holds as an inventory |
| §3 the word layer, nothing names `I64` | holds, and §2 here gives it its reason: width is a representation fact |
| **§4 the permutation machine** | **neither object has a `rows` parameter.** §1 here replaces it |
| §5 implying the computation | holds, and it is a representation-level statement |
| §6 constant time by construction | holds, and §6 here states its limit |
| **§7 the sponge relationship** | the curve holds. `c ≥ 2S` is the **unkeyed** bound, and Ascon-AEAD128 runs `c = 192` at 128-bit security because a keyed sponge draws security from the key. The keyed and unkeyed bounds owe a split |
| §8 automatic hardware scaling | holds, and §3 here states what it is scaling and what it holds fixed |
| §9 the two candidates | the comparison assumed a security level per target. Its throughput figures are derived at `b = 1600` and say nothing about the small-state operating point |
| §10 eliminations | holds |
| §11 our own take | holds as the cascade. §1 here bounds what may be configured |
| §12 what is in the tree | holds |
| §13 decisions owed | `C8` is answered by the invariance ruling. `C2` stands open and §3 here gives it three conformant candidates |

## §10 · What specifying best representations needs

Six things, and none of them exists today.

| # | what | why it blocks |
|---|---|---|
| 1 | **a cost model.** Which terms "best" minimizes: permutation calls per byte, ops per permutation, resident state bytes, code bytes, and whether energy is a term | "best" has no meaning until the objective is written down |
| 2 | **the target's declaration.** What a target states beyond width: whether a widening multiply exists, whether vector lanes exist, the resident memory, whether a secret-indexed table lookup is admissible | a representation is selected from these, and `NumProfile` carries only the first today |
| 3 | **the admission test for a representation.** What evidence a representation supplies to be admitted against its object | without it, adding a representation is adding unreviewed crypto |
| 4 | **the registry.** A closed set of admitted representations per object, each with its correspondence evidence | a closed set is what makes a new one a visible act |
| 5 | **the invariance as a derived fact.** The security level stated once on the object, and no representation permitted to state one | an invariant restated in N places is an invariant that drifts |
| 6 | **the refusal path.** A target below the floor, named and refused | §4 is the principle and this is its mechanism |

## §11 · Decisions owed by this frame

| id | decision |
|---|---|
| T1 | fidelity target: faithful to the specification's algorithm, or faithful to the mathematics the algorithm computes |
| T2 | the cost model of §10, item 1 |
| T3 | what a target declares, beyond `NumProfile`'s width |
| T4 | the admission test a representation passes |
| T5 | whether the object and its representations are distinct types with an explicit map, or one type with the representation erased |
| T6 | where the laws live: a `.manifest` of properties, a gate script, or types that carry them |
| T7 | the smallest-member testing tier: whether Keccak-f[25] and its siblings are built as real modules or as test-only instances |
| T9 | **the mark's length, 32 bytes or 64 bytes.** It sets the security level, the state floor follows from it, and it is a permanent per-address cost across the naming layer |
| T8 | whether a representation may be selected at runtime, or is fixed per moduleset. `.planning/CRYPTO-MODEL.md` §8 promises verification of any mark, and a moduleset-fixed representation narrows that to configurations the binary was built with |

## §12 · Notes to cover

- `k`, the ops per lane per round, carried from `.planning/CRYPTO-MODEL.md` §14
  and still estimated. Every ops-per-byte figure in §3 rests on it
- the round schedule is more than one number. Ascon's AEAD runs 12 rounds at
  initialization and finalization and fewer between data blocks, and a machine
  carrying one round count cannot express it
- bit-interleaving's correspondence proof, which is the first representation
  equivalence this tree would owe
- whether `Keccak-f[25]` at `w = 1` degenerates usefully. Its rotation offsets
  are taken mod 1 and vanish, so ρ becomes the identity and the miniature tests
  less than the family does
- the message buffer's footprint, which §3's state floors exclude
- the second preimage and preimage targets for a mark, which §3 states only for
  collisions
- where a representation's choice is recorded in a mark, if anywhere. §8 of
  `.planning/CRYPTO-MODEL.md` puts the configuration in the domain separator,
  and a representation sits below that layer
- what a law looks like as a tested artifact in this tree, against
  `tools/test/`'s current shape
