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
| **the dynamism serves the highest security reachable, and what it adjusts is performance** | §3, §11. The output holds and the level holds at every target. A weak target pays in time |

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

**`T9` is ruled: the 64-byte mark.** The maximize-security ruling takes the
second row, and 256-bit collision resistance is a ceiling rather than a point,
because NIST defines no category above it. The state floor of 100 bytes follows
and is affordable at every target this project reaches.

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

⚑ **Ascon-p is out on the ruling and not on the mathematics.** At a 256-bit mark
it is conformant at 40 bytes and it is the smallest of the three. The 64-byte
mark demands a 512-bit capacity, which exceeds its 320-bit state. A ruling is
revisitable and a mathematical elimination is permanent, so
`.planning/CRYPTO-MODEL.md` `C2` closes against `T9` and reopens if `T9` moves.

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
| §13 decisions owed | `C8` is answered by the invariance ruling and `C2` by `T9`. **`C3`'s option set is incomplete**, and §11 here adds the stateful schemes it omits |

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
| 7 | **zero allocation in the inner loop.** A streaming kernel on a tiny target cannot allocate per block, and this tree's arena never reclaims | §13 measures the floor at ~200 B and allocation is what decides whether an implementation reaches it |

## §11 · The post-quantum stack, staged

The invariance ruling transfers to the sponge for free and stops at the
asymmetric layer.

| layer | what flexes with the target | what the security level costs |
|---|---|---|
| sponge, symmetric | **time.** A small state does more permutation calls per byte | nothing on the wire. The digest is one size at every configuration |
| PQ signature | nothing, by itself | **wire bytes.** The signature is the output and the level sets its size |

A weak device raising its permutation count changes no byte of what it emits. A
signature at a higher level enlarges what every party transmits and stores, so
the asymmetric layer needs its own mechanism for the same principle.

### The signature staircase

**The whole signature side is stages over the permutation and introduces no new
mathematics.**

| stage | what | new mathematics |
|---|---|---|
| A | the permutation | the one object |
| B | the sponge modes: hash, XOF, MAC, KDF | none |
| C | the one-time signature, WOTS+ hash chains | none |
| D | the Merkle tree | none |
| E | the hypertree, or the key state | none |
| F | the signature scheme | none |

`.planning/CRYPTO-MODEL.md` §10 reaches the same finding for SLH-DSA and states
it as a cost. Staged, each step is small, separately testable, and ordered.

**The KEM is where new mathematics enters**: polynomial arithmetic over
`Z_q[X]/(X^n + 1)`, the NTT and its inverse, rejection sampling, and
compression. It is a separate stack and it sequences behind the staircase.

### The stateful fork

`.planning/CRYPTO-MODEL.md` `C3` offers ML-DSA against SLH-DSA with FALCON
eliminated. **That option set omits the stateful schemes.** NIST SP 800-208
approves XMSS, LMS, and the multi-tree HSS and XMSS^MT, and they are materially
smaller: LMS and HSS stay below 8 KB where SPHINCS+ parameter sets exceed 10 KB
and reach about 23 KB at the 128-bit level. LMS signatures run 8 bytes larger
than XMSS at comparable parameters, and HSS adds 2 to 5 percent by tree count.

They are held out of general use for one reason. SP 800-208 requires persistent,
crash-consistent counters, records that key reuse from a counter reset is
catastrophic and unrecoverable, requires key generation and signing inside
hardware modules that cannot export key material, and approves them only for
firmware and software signing at low signing volume.

**The objection is a one-time-use property and §5 already carries one-time use
in the type system.** A signing key consumed by use has no spelling for reuse,
on the same carrier as the Poly1305 key.

⚑ **Linearity reaches one of the two failure classes.** In-program reuse is
removed. A crash between signing and persisting the counter, a restore from a
backup, and two processes opening one key file are durability failures, and they
stay open. `docs/decisions/decision-quorum-store.md` and the linear `Region`
discipline are where that half is worked.

### The size dial

The Winternitz parameter trades signature size against hashing at a constant
security level: a larger `w` shortens the signature and lengthens the chains.
This is the invariance ruling applied inside a signature, and it moves in the
direction the ruling wants.

### Sizes, for scale

| object | size |
|---|---|
| a mark at the 256-bit collision target | 64 B |
| a permutation state at that target | 100 to 200 B |
| ML-KEM-768 encapsulation key, ciphertext | 1,184 B, 1,088 B |
| ML-KEM-1024 encapsulation key, ciphertext | 1,568 B, 1,568 B |
| LMS and HSS signatures | below 8 KB |
| SLH-DSA-128s signature | 7,856 B |
| SLH-DSA-256f signature | ~49,856 B |

## §12 · The two regimes, and what a key buys

**A key that everyone must hold in order to verify is a published constant.**
Universal verifiability means universal knowledge, so a keyed mark with a public
key has exactly the security of the unkeyed function. That obstruction is total,
and it reaches one object.

| regime | who verifies | keyed | mark |
|---|---|---|---|
| a value published to strangers | anyone | **no** | 64 B |
| private storage | the owner | yes | 32 B |
| group storage | the group | yes | 32 B |
| the transport, the handshake, the session | the parties | yes | |
| a mutable pointer | anyone, against a public key | yes | |

`REACH-MODEL` §10 already puts signatures on the mutable-pointer layer alone, so
the architecture already carries the keyed naming layer. The keyless seam is the
interface to strangers and it is one row.

**Private storage never meets the seam.** One party holds the key, so the chunks,
the authentication, the tree and the names are all keyed. A storage system pays
the 64-byte mark only at the moment it publishes to someone it has no
relationship with.

That regime also defeats the malicious-preparer attack outright. An outsider who
hands the owner a file cannot craft a colliding mark, **because the outsider
cannot compute the owner's marks at all.** This is the randomized-hashing idea
with the randomizer held by the verifying party, which is the party that makes it
work.

### What the key is worth

Keying moves three terms at once.

| | unkeyed, a public mark | keyed |
|---|---|---|
| rounds | full. 24 at `b = 1600`, 22 at `b = 800` | **6**, in a Farfalle construction |
| capacity | `c = 512`, forced by birthday on the inner state | 128 to 256, and a full-state duplex pushes the rate toward `b` |
| output | 64 B | a 32 B tag |

**This is the largest optimization in the stack**, ahead of representation,
windowing and materialization together.

### The bulk path

Kravatte and Xoofff are Farfalle instances over Keccak-p[1600] and Xoodoo, and
their permutations run **6 rounds** apiece. The reduced count is sound because
the construction is keyed, which is the keyed and unkeyed split appearing on
rounds instead of on capacity. A duplex enciphers and authenticates in one
permutation call per block, so authentication is close to free.

Op counts per byte, derived off the estimated `k ≈ 9` and soft for that reason:

| | ops per byte |
|---|---|
| an unkeyed mark, Keccak-f[1600] at `c = 512` | ~40 |
| ChaCha20 keystream, 10 double rounds of 8 quarter-rounds at 12 ops | ~15 |
| Farfalle expansion over Keccak-p[1600] at 6 rounds | **~7** |

Hardware measurements point the same way, reporting SHA-3 about twice as
energy-efficient as ChaCha20 for pseudo-random generation, because it yields more
bits per round.

⚑ **`.planning/CRYPTO-MODEL.md` `C10` leans yes on this evidence**: an AEAD over
the same machine retires ChaCha20-Poly1305, on throughput and code reuse. It owes
a measurement, since `k` is estimated and the Farfalle AEAD accounting needs both
the compression and the expansion pass counted.

### The round count as a type index earns its keep

`.planning/CRYPTO-MODEL.md` §7 lists "shipping a reduced-round variant by
accident" as a refusal and had no case behind it. There is one now, and it is
unavoidable.

| use | rounds |
|---|---|
| a public mark | 24 |
| keyed bulk, in Farfalle | 6 |

Both live in one binary over one permutation, and a 6-round permutation used for
an unkeyed mark is broken. The round count as a type index makes them different
types, so the confusion has no spelling.

## §13 · The target floor

| tier | what the device does | RAM |
|---|---|---|
| 0 | fetch and verify immutable values | **~200 B.** The Keccak-f[800] state is 100 B and absorbs in place, beside the 64-byte mark under comparison |
| 1 | + verify signed mutable pointers | **~1 KB.** Hash-based verification streams: one chain value and two or three Merkle nodes live at once, and an 8 to 50 KB signature never becomes resident |
| 2 | + bulk encrypt and decrypt | the permutation state, already counted |
| 3 | + establish a confidential channel | **~3.4 KB, and this is the wall.** ML-KEM-1024 measures 3,332, 3,372 and 3,356 bytes of stack for keygen, encapsulation and decapsulation in the pqm4 stack-optimized build |

**A 4 KB device runs the whole level-5 stack.** Below 4 KB the only capability
lost is establishing a confidential channel, and private file storage needs none.

Speed at the low end stays inside a small factor. Both members below give 256-bit
collision resistance and a 64-byte mark.

| | state | lanes | rate | on a 32-bit target |
|---|---|---|---|---|
| Keccak-f[800] | 100 B | 32-bit, native, and lighter on flash | 36 B | baseline |
| Keccak-f[1600] | 200 B | 64-bit, wanting bit-interleaving | 136 B | ~1.7x faster per byte |

### What dominates the byte count

The permutation is the smallest term in the system.

| term | size | movable |
|---|---|---|
| a PQ signature | 8 to 50 KB | **yes.** 2 to 3x from a stateful scheme, more from the Winternitz parameter |
| the marks a value carries | 64 B times every reference | **yes, entirely.** Chunk size and tree fanout are ours |
| the mark's own width | 64 B | no |
| the permutation state | 100 to 200 B | barely, and it does not matter |

Derived for a 1 GB value: at a 4 KB chunk size that is 262,144 leaf marks and
16.8 MB, **1.7% overhead**. At 64 KB chunks it is 16,384 marks and 1 MB, **0.1%**.
Chunk size alone moves mark overhead by 16x. A Merkle tree adds internal nodes at
about `leaves / (f - 1)`, so a binary tree nearly doubles the node count where a
fanout of 16 adds about 7%. That lever sits in
`.planning/CRYPTO-MODEL.md` §2 layer 3, which is `unscoped`.

### The blocker, which lies outside the mathematics

**Allocation sets the floor.** The mathematics says 100 bytes of state. Whether an
implementation runs in 200 bytes depends on whether the round loop allocates, and
this tree's arena never reclaims. `docs/examples/N01-crypto-kernels.md` designed
against it, holding round state in fixed-shape `data` and Bytes growth to one
block plus one `bcat` per message block. A tiny target needs **zero allocation in
the inner loop**, which is a requirement on the memory discipline rather than on
the kernel. It lands on `lib/memory/mem-linear.chiral`, `mem-region.chiral` and
the `Alloc` interface.

⚑ **The named-lane argument has a limit.** Twenty-five lanes of 32 bits exceed any
microcontroller register file, and a Cortex-M0+ has eight usable registers. Named
lanes remove indexed indirection and leave load and store traffic in place.

## §14 · Materialization, the third dial

**A large object derived from a small seed by a total pure function costs the
seed and the derivation.** This is already the dominant size technique in the
reference class.

| object | materialized | derived from | ratio |
|---|---|---|---|
| the ML-KEM public matrix `A` at k=4 | 16 polynomials of 256 coefficients at 12 bits, 6,144 B | the 32-byte seed `ρ`, expanded by SHAKE128 | ~190x |
| an ML-KEM-1024 decapsulation key | 3,168 B expanded | a 64-byte seed | ~50x |
| a hash-based scheme's `2^h` one-time keys | unbounded | one seed and a PRF | unbounded |
| a Merkle authentication path | the full tree | traversal over a frontier | tunable |
| Keccak round constants | a table | an 8-bit LFSR | the table goes |
| Keccak `ρ` offsets and `π` | 25 entries and a mapping | `t(t+1)/2 mod w`, and `(x,y) → (y, 2x+3y)` | the tables go |
| GF(256) log and antilog | 512 B | bit operations | the table goes, and the secret-indexed lookup with it |

ML-KEM's 1,568-byte encapsulation key checks out against this exactly: 1,536
bytes of `t̂` plus 32 bytes of `ρ`. Materializing `A` would make it 7.7 KB.

**So there are three memory dials and they are independent.**

| dial | is |
|---|---|
| `budget` | how much state the permutation has |
| `access` | how much of that state is resident at once |
| **`materialization`** | how much of a derivable structure is stored against recomputed |

All three leave the security level alone, because a derived value is
byte-identical either way. pqm4 measures the third one working: ML-KEM-1024
decapsulation at 20,352 B in the clean build, 7,484 B speed-optimized and 3,356 B
stack-optimized, one algorithm at one security level across a 6x memory range.

**What the lens adds.** In pqm4 those are separate C implementations whose
agreement rests on vectors and review. Here they are two representations of one
object, so their agreement is the correspondence §2 owes and §7 tests. **The
dangerous optimization becomes the checked one.** Four properties carry it: the
membrane makes the derivation provably reproducible with no clock and no RNG,
totality makes it terminate, erased indices keep the choice at compile time, and
linearity holds a secret seed under custody.

Deterministic derivation also protects a tree property.
`docs/arcs/native-protocol-arc.md` requirement 3 records that every compiled path
today is deterministic. If signing derives its randomness from the key and the
message, entropy enters at key generation alone, so `N2`'s crossing is spent once
per identity rather than once per operation.

⚑ **Derivation concentrates authority.** A 64-byte seed that regenerates every key
a device holds is the most concentrated authority in the system, and each
derivation added makes it more so. That runs straight into
`docs/decisions/decision-quorum-store.md` and `native-protocol/N7` and `N8`:
**derivation and quorum-splitting are complements**, and the smaller the root of
authority becomes the more it wants splitting.

## §15 · What sits above, and why it is deferred

A permissions layer, and through it a user model, is the one structural piece
this stack does not reach. It is deferred, and
`docs/decisions/decision-scope.md` already defers ownership.

**The dependency looks circular and stratifies.** The rule that breaks it: **the
crypto layer knows keys and never knows users.** A key names no person. A person
is an interpretation of a key, held two layers up.

| layer | knows | reads |
|---|---|---|
| 0 primitives | bytes and keys | nothing above |
| 1 custody | that a key is secret. `E40`, `lib/capability/secret.chiral` | 0 |
| 2 identity | a keypair with a mark | 1 |
| 3 capability | what a holder of a token may do | 2 |
| 4 user model | a person, possibly several identities | 3 |

**A capability breaks the loop and an access list creates it.** An access list
asks who the holder is and whether they are allowed, which needs the
identity-to-user-to-permission lookup that closes the circle. A capability asks
whether the token is held, which needs nothing above the token.
`lib/ports/sock.port:54-74` records every cap linear, so a capability that cannot
be copied is already the tree's idiom.

`REACH-MODEL` states the same stratification: a party is a separate mechanism,
layered above, and only a mutable answer needs one.

The shape is one this tree already lives with. A self-hosting compiler looks
circular and is not, because the bootstrap breaks it, and
`docs/definitions/working-discipline.md` carries that rule. Crypto is the
bootstrap here.

**What has to hold now for the layer to land later without rework.**

| what | why |
|---|---|
| nothing in the crypto layer names a user | the invariant that keeps the loop broken, and it belongs as a stated refusal |
| domain separation stays extensible | a permission layer wants its own derivation domains, and §7's required separator field has to hold them |
| keys derive hierarchically from one seed | sub-identities and delegation fall out of §14's hierarchy |
| a signature can sign a statement about another key | delegation is the one thing every capability system needs |

**The crypto layer is complete without the layer above it**, which is what makes
the deferral safe. `decision-quorum-store` already holds a piece of the
arbitration primitive in its honest form: two share subsets that reconstruct
differently surface as a named disagreement, which surfaces a conflict without
deciding it.

## §16 · Decisions owed by this frame

| id | decision |
|---|---|
| T1 | fidelity target: faithful to the specification's algorithm, or faithful to the mathematics the algorithm computes |
| T2 | the cost model of §10, item 1 |
| T3 | what a target declares, beyond `NumProfile`'s width |
| T4 | the admission test a representation passes |
| T5 | whether the object and its representations are distinct types with an explicit map, or one type with the representation erased |
| T6 | where the laws live: a `.manifest` of properties, a gate script, or types that carry them |
| T7 | the smallest-member testing tier: whether Keccak-f[25] and its siblings are built as real modules or as test-only instances |
| ~~T9~~ | **RULED 2026-09-07: the 64-byte mark.** 256-bit collision resistance, `c = 512`, Keccak-f[800] as the floor at 100 bytes. §3 carries the derivation and what it costs on every address |
| T8 | whether a representation may be selected at runtime, or is fixed per moduleset. `.planning/CRYPTO-MODEL.md` §8 promises verification of any mark, and a moduleset-fixed representation narrows that to configurations the binary was built with |
| T10 | **stateful against stateless hash-based signature**, re-opened by §11. `C3`'s option set omits XMSS, LMS and HSS, and linearity reaches the in-program half of their objection |
| T11 | the Winternitz parameter, and whether it is fixed or a declared trade |
| T12 | build order between the signature staircase, which needs no new mathematics, and the KEM stack, which is where new mathematics enters |
| T13 | **robustness against bits at one address width.** A 64-byte mark is either one 512-bit digest at 256-bit collision resistance, or two 256-bit digests from different designs concatenated at about 135 bits that survives one design breaking. Joux caps the second row and §16's sources price it |
| T14 | the chunk size and the Merkle fanout, which move aggregate mark overhead by 16x and are the largest byte lever that is ours |
| T15 | whether the bulk path is a Farfalle over the mark's permutation, which is `C10` restated with §12's evidence attached |
| T16 | the materialization schedule: hand-written per device class, or computed at compile time from the target's declared budget |
| T17 | the refusal that keeps §15's loop broken, and where it is enforced |

## §17 · Notes to cover

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
- the durability half of the stateful-signature objection: a crash between
  signing and persisting a counter, a restore from a backup, and two processes
  opening one key file
- whether Ascon-p's exclusion is recorded as a ruling. At a 256-bit mark it is
  conformant at 40 bytes, and the maximize-security ruling is what removes it
- the Farfalle AEAD op count with both the compression and the expansion pass,
  which §12 leaves at the expansion alone
- the keyed capacity bound stated properly, which §12 gives as a range
- whether a 32-byte private mark and a 64-byte public mark are one type or two,
  and what a value crossing between the regimes costs
- the register pressure of 25 named lanes on an eight-register target, which §13
  names and does not quantify
