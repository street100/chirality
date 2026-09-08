# Crypto: the primitive model

**Opened 2026-09-05** from a design session with the author. The crypto half of
`.planning/REACH-MODEL.md`, worked in depth. It settles shape and settles no
build order. Nothing here is minted and no code is touched.

The question this answers: **what the full primitive set is, given a
post-quantum target, and what form it takes so the language derives a
configuration from the hardware instead of a person choosing one.**

Author rulings. The first five are 2026-09-05 and the last is 2026-09-07.

| ruling | consequence |
|---|---|
| post-quantum throughout | §1. The reference class N1 was scoped against is pre-quantum |
| we build our own take, splitting the primitives up and giving them native form | §11. A standard's named instantiation becomes a value in a table, and the machine is ours |
| compute belongs at message creation and at reading | `REACH-MODEL` §11. No public-key work on the forwarding path |
| **hardware scaling is automatic at the language level** | §8. A person states a numerical model only at an interop boundary between binaries |
| **the language's idioms are followed verbatim, and they are the mechanism** | §11. Configuration cascades from target to parameters to types to refusals, and no layer restates the one before it |
| **the five step mappings are each their own primitive** | §4. The family is the layer above them, and a fusion of two steps is a composition there that owes a proof of equality. `.planning/CRYPTO-TRANSLATION.md` `T1` |

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

**A post-quantum target threatens one of the suite's three layers.** Shor solves
the discrete log outright and takes the classical asymmetric layer with it.
Grover reaches everything else, and it buys only a quadratic speedup on
unstructured search.

| primitive | what a quantum adversary brings to it | verdict |
|---|---|---|
| X25519 | Shor, against the discrete log its security rests on | **genuinely dead** |
| Ed25519 | Shor, on the same curve | dead. §2 records that it appears nowhere |
| ChaCha20 | Grover, against a 256-bit key that already absorbs a quadratic speedup | **stands** |
| Poly1305 | a Carter-Wegman MAC over a one-time key | **untouched** |
| BLAKE2s | Grover, against a 256-bit digest | **stands on security grounds** |

**So exactly one of N1's four slices is retired by the security finding.** Slice
4 is X25519 and Shor takes it. Slices 1 and 2 are ChaCha20 and
ChaCha20-Poly1305, and the table above leaves both standing. Slice 3 is BLAKE2s,
displaced by §11's architecture, which makes a digest a configuration of our own
machine. Shor and Grover have no part in that displacement.

**`C1` reads as a correctness question and is a cost one.** Its current phrasing
puts the built work under suspicion of being insecure. The real question is
whether it is redundant under §11. Redundancy has a price and can be paid or
declined. Insecurity has neither. `C1` stays open as the author's call, with
that distinction attached to it.

## §2 · The primitive set

| layer | primitives | state |
|---|---|---|
| 0 word | width-indexed words, wrap ops, rotations, LE and BE codecs | `native-protocol/N6`'s row exists. Unscoped |
| 1 permutation | §4's five step primitives, and the family over them | unscoped |
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

## §4 · The permutation primitives, and the family over them

**Author ruling, 2026-09-07.** The five step mappings are each their own
primitive with its own signature. The family is the layer above them, and a
fusion of two steps is a composition at that layer which owes a proof of
equality. `.planning/CRYPTO-TRANSLATION.md` `T1` carries the ruling and what it
buys. This section is written to it. An earlier draft presented one machine with
four slots, and `records/findings.md` `FD-13` measured six defects in it against
three pins.

### Which level the machine sits at

**FIPS 202 publishes two levels and derives the lower one from the upper.** The
upper is FIPS202:14 "The generalization of the KECCAK-f [b] permutations that is defined in this Standard by converting the number of rounds nr to an input parameter", written Keccak-p[b, nr] and defined at FIPS202:15 "the permutation is defined for any b in {25, 50, 100, 200, 400, 800, 1600} and any positive integer nr". The lower is FIPS202:26 "KECCAK-f [b] = KECCAK-p[b, 12 + 2l]."

**The machine sits at the p level**, which is where a round count as an input
parameter is legitimate. At the f level `R = 12 + 2l` is a definition and a free
round count is forbidden. So `R = 12 + 2l` is the boundary between the two
levels rather than a cell in an instance table, and an instance calling itself
Keccak-f[b] owes that derivation. `docs/arcs/parts/crypto-primitives-K1.md` §5
chose the same level for the translation and gives three reasons for it.

### The five primitives

A round is five step mappings, FIPS202:15 "consists of a sequence of five transformations, which are called the step mappings", applied in the order θ, ρ, π, χ, ι. **Both instances apply a bitsliced 5-bit S-box across five lanes**,
computed with boolean operations on whole words, and both XOR a round constant
into one lane. Those two positions are where the shapes agree.

| primitive | what it is | Keccak-p | Ascon-p |
|---|---|---|---|
| θ, the column parity | FIPS202:21 "is to XOR each bit in the state with the parities of two columns in the array". Five parities, one rotation, XOR back into every lane. It crosses lanes | present | **absent** |
| ρ, the rotation | FIPS202:22 "is to rotate the bits of each lane by a length, called the offset, which depends on the fixed x and y coordinates of the lane". It stays inside one lane | one rotation per lane, offsets taken mod `w` | a XOR of two rotated copies: ASCONSPEC:102 "<i>S</i><sub>0</sub> := <i>S</i><sub>0</sub> &oplus; (<i>S</i><sub>0</sub> &#8921; 19) &oplus; (<i>S</i><sub>0</sub> &#8921; 28)" |
| π, the lane permutation | FIPS202:23 "[x, y, z]= A[(x + 3y) mod 5, x, z]", whose effect is FIPS202:23 "is to rearrange the positions of the lanes" | present | **absent** |
| χ, the S-box | FIPS202:24 "is to XOR each bit with a non-linear function of two other bits in its row" | KECCAKSUM:188 "  A[x,y] = B[x,y] xor ((not B[x+1,y]) and B[x+2,y]),", at fixed y | its own, chosen for stronger per-round properties: ASCONSPEC:76 "applies a 5-bit S-box 64 times in parallel in a bit-sliced fashion (vertically, across words)." |
| ι, the round constant | one lane, KECCAKSUM:191 "  A[0,0] = A[0,0] xor RC" | an LFSR derivation | one byte, ASCONSPEC:75 "s a round-specific 1-byte constant to word <i>S</i><sub>2</sub>." |

**Ascon's round fills three of the five positions.** ASCONSPEC:71 "The round transformation consists of the following three steps which operate on a 320-bit state divided into 5 words" of 64 bits each, and the three are the constant, the S-box and ASCONSPEC:77 "Linear Diffusion Layer".

**Ascon's linear step occupies ρ's position.** It stays inside one word,
ASCONSPEC:77 "s different rotated copies of each word (horizontally, within each word)." θ crosses lanes and Ascon has no cross-lane step at all. Pairing the two
under one name is what left ρ with nowhere to go, so the mispairing and the
missing step were one defect. ⚑ The name *the Σ functions* an earlier draft used
is dropped. The designers' page calls the step the Linear Diffusion Layer, and
the Σ spelling comes from a PDF that maps the glyph to S, which no pin here
resolves.

⚑ **Every Ascon claim in this section rests on the designers' specification
page.** NIST SP 800-232 was fetched and could not be read in this sandbox: it
draws its body text from CID-keyed fonts, and this sandbox has no `pdftotext`
and no PDF library. The standard itself has not been read here.

### The family over the primitives

An instance names a lane geometry, a step set and a round count.

| | Keccak-p[1600, nr] | Keccak-p[800, nr] | Ascon-p[nr] |
|---|---|---|---|
| lanes | 25 | 25 | 5 |
| `planes` of 5 lanes | 5 | 5 | 1 |
| lane width `w` | 64 | 32 | 64 |
| `R` at its f member | 24 | **22** | it has no f member. 12 and 8 are the standardized counts |
| θ | present | present | absent |
| ρ | the offset table | the same table mod 32 | the two-rotation XOR |
| π | present | present | absent |
| χ | Keccak's S-box | the same | its own |
| ι | the LFSR derivation | the same | its own byte constants |
| `budget`, which derives `planes` | large | large | small |
| `access` | `full` | `full` | `windowed k` |

**Keccak-f[800] is 22 rounds and does not arrive free.** KECCAKSUM:171 "is given by $n = 12+2l$, where $2^l = w$. This gives 24 rounds for" fixes the law and attaches 24 to f[1600]. At `w = 32` the exponent `l` is 5 and the law gives 22.
Setting `planes` and `w` while leaving `R` at 24 produces a different
permutation. The round count travels with `w` and is derived rather than
carried.

**One plane does not give Ascon-p.** π's formula holds no plane-count term to
specialize, and its source index at `y = 0` reads a lane at every `y`, so a
one-plane state has no π to restrict. Ascon's round omits θ and π; it does not
instantiate them at the identity. Choosing the identity at one plane is a free
choice available to the family, and deriving it from the plane count is the half
that fails.

**So Ascon-p is a composition at the family layer**, and under the ruling above
an instance that drops or fuses primitives owes an equality proof against the
primitives it claims to compose. This tree holds no such proof and states none.
`crypto-primitives/K2` is the row that discovers how many families there are and
`C2` is the call. `crypto-primitives/K15` and `crypto-primitives/K16` are the
rows that would run such a proof as a gate.

**Terminology.** `planes` is FIPS 202's own word for what this parameter counts:
FIPS202:11 "plane For a state array of a KECCAK-p permutation with width b, a sub-array of b/5 bits with a constant y coordinate." The standard reserves *row* for something else, FIPS202:11 "row For a state array, a sub-array of five bits with constant y and z coordinates.", which is the sub-array χ works across. An earlier
draft of this model called the 5-lane sub-array a row, colliding with both.

**Memory is two dials and they are independent.**

| dial | is |
|---|---|
| `budget` | the bytes available. `planes` is derived from it and a person never chooses it |
| `access` | how much of the state is live at once: `full`, or `windowed k` |

A large-state node may still want windowed access. A constrained one has no
choice. Keccak sits at `budget = large, access = full`. Ascon's niche is
`budget = small, access = windowed`, and §9 records what reaching that niche by
configuring this family costs. `k` here is the window size. §7's `k` is the
ops-per-lane term and the two share a letter, which §14 records as owed.

**Two instances is the point.** One instance proves nothing about whether the
abstraction constrains anything, which is the tree's own rule about abstractions
earning their keep. Whether the second instance is Ascon-p or a second member of
the Keccak family is `C2`, and §9 carries the evidence for it.

## §5 · Implying the computation

Of the five primitives §4 separates, three cost less than they appear to and two
are the real work. The names are §4's.

| step | what it does | cost |
|---|---|---|
| θ, the column parity | column parity across five, one rotation, XOR back into every lane | **real** |
| ρ, the rotation | rotate each lane by a fixed per-position offset | **cheaper.** The table lookup and the index arithmetic disappear against named lanes. The rotation itself stays three ops, because the closed `Op` sum has no rotate and the backend emits shift, shift, or |
| π, the lane permutation | move lane (x,y) to (y, 2x+3y), which is KECCAKSUM:185 "  B[y,2*x+3*y] = rot(A[x,y], r[x,y])," read forward | **free.** Pure reindexing. Nothing is computed |
| χ, the S-box | the only nonlinear step | **real**, and the largest single cost |
| ι, the round constant | XOR into one lane | **free.** Derivable from the LFSR at compile time |

## §6 · Constant time by construction

**The state is a record of named lanes with no array.**

| what follows | why |
|---|---|
| π costs nothing | it is which field is read next |
| ρ needs no table | one rotate-by-literal per named lane |
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
| state | `b = planes × 5 × w` |
| rate | `rate = b − c` |
| security | `c ≥ 2 × S` |
| work per permutation | `≈ lanes × k × R` |
| **work per output byte** | `(planes × 5 × k × R × 8) / (planes × 5 × w − c)` |
| memory | `b / 8` bytes |

**Capacity is the one term that does not scale.** `c ≥ 2S` is fixed by the
security target, so **rate is the surplus after security is paid** and growing
the state grows only the rate.

Derived at `w = 64`, `S = 128` so `c = 256`, `k ≈ 9`, `R = 24`. `R` follows
`w` through §4's `12 + 2l` and the plane count does not enter it, which is why
one `R` serves the whole column.

⚑ **Two terms in that derivation are unbacked.** `k` is estimated from the
step counts in §5 and has never been measured, so every ops-per-byte figure
below is an estimate and §14 carries it. And `12 + 2l` is published over the
seven widths at 25 lanes, FIPS202:15 "b 25 50 100 200 400 800 1600 w 1 2 4 8 16 32 64 l 0 1 2 3 4 5 6", so `R` at a plane count other than 5 is this
model's extrapolation and no published law covers it. §14 carries that too.

| planes | state | rate | ops per byte |
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

**`access` moves the resident memory and leaves the security terms where
`budget` and `S` put them.** `b`, `rate` and `c` are unchanged, so a windowed
configuration has the same state size, the same capacity and the same security
target as the full one at that `budget`. It holds fewer than `planes × 5` lanes
live at any moment. Interoperation is untouched, because §8's mark names the
configuration and verification reads the machine.

⚑ **The work-per-byte row is derived at `access = full` and is underived under
`access = windowed`.** The whole table above assumes every lane resident, with
`k` counting what one lane costs per round. A window adds movement between the
live lanes and the rest of the state, and this tree has measured neither `k` nor
that movement. **No windowed figure is stated here**: no cell, no column, and
the asymptote `k·R·8/w` stays the full-access one. §14 carries it as a note to
cover.

**The relationship rides as refinements over the indices.**

| constraint | what it makes impossible |
|---|---|
| `rate + c = planes × 5 × w` | a parameter set that does not close |
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
| the target's `budget` | `planes` |
| the target's `access` | how much of the state is resident, `full` or windowed |
| the security requirement | `c` |
| derived from those | `rate` |
| the chosen S-box's floor, and `12 + 2l` where the instance is an f member | `R` |

A person writes `hash`. The moduleset's target supplies the width, the budget
and the access pattern, and every other parameter is computed. The two memory
dials are independent, so a large-state target may still declare windowed
access; §4 carries both and §7 states what `access` changes. This is the same
seam the tree already has three times: memory disciplines are
moduleset-configured, `NumProfile` makes width moduleset-configured, and `Mach`
makes the backend an instance.

**This is the structural argument for a family and against a point.** A design
fixed at one state size and one lane width cannot scale automatically, so
adopting it as the base forfeits the property. Keccak-f[b] is defined across
the seven lane widths 1 through 64 with one offset table taken mod `w`, so the
8, 32 and 64-bit members are one module. **The width dial carries the round
count with it**: `R = 12 + 2l` moves when `w` moves, which is why §4 states the
derivation and why Keccak-f[800] is 22 rounds. Ascon-p is one point and cannot
be the base. Whether it is a second instance of this family or a second design
is `C2`, since §4 measures its round as dropping θ and π.

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
| Ascon-p[12] | 12 | 7 on the AEAD, varying by variant, some in restricted key classes | **~1.7x** |

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

⚑ **Both ops-per-round figures are estimates and neither has been measured.**
They are counted the way §7's `k` is counted, and §14 carries `k` as owed. Every
ops-per-byte number in this table inherits that, so the ratio between the two
columns is what the table supports and the absolute figures are not.

**Keccak is roughly three times cheaper per byte** on those estimates. Its state
is 7x larger and its rate 21x larger, so the larger permutation repays itself.

**Ascon's only win is memory, and that is evidence about the design space.** It
is worth little where 200 bytes of state is affordable and worth everything
where it is not, so what the result establishes is that **memory is an axis the
family must expose**. It establishes nothing about which design ships.

**The memory property is reached by the family at `planes = 1`, `w = 64`,
`budget = small, access = windowed`**, which is a 320-bit state. That
configuration is a different permutation from Ascon-p: §4 measures that it keeps
θ and π where Ascon's round has neither, so it inherits none of Ascon's
cryptanalysis and the margin table above covers it nowhere. Adopting Ascon-p
instead buys the same state size and forfeits §8's derivation, since a design
fixed at one state size supplies no dial for the target to turn. Both halves of
that trade are `C2`, and §14 carries the unanalyzed member as a hole.

**This is the second reason behind §8's structural argument for a family and
against a point.** The first is that a fixed state size and lane width cannot
scale automatically. The second is that the low-memory end is a setting of the
family. §8's closing sentence about Ascon-p now hands its status to `C2`, and
both reasons stand behind it.

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

### The cascade

**The configuration cascades, and the cascade is where this design draws its
power.** Each layer is derived from the one before it and nothing is restated.

| layer | what it holds | stated in |
|---|---|---|
| the target | `NumProfile`, `budget`, `access`, the security requirement | §8 |
| the parameters | `w`, `planes`, `c`, `rate`, `R` | §7, §8 |
| the types | the round count as a type index, the rotation amount as a refinement, the state as named lanes | §4, §6, §7 |
| the refusals | a parameter set that does not close, a configuration under its security target, a secret-dependent index, a cross-configuration agreement | §6, §7, §8 |

**`cascade` is already this tree's word, and this is that concept at another
layer.** `docs/examples/C01-typed-style-value.md:138` names the style cascade
*"an ordered, incremental fold"*, resolving one face against its ancestor chain
with the order living in the value. `docs/examples/C1C2-style-round-trip.md`
builds the typed style layer on that fold and ties its two directions with one
equation. The crypto cascade folds a target into a configuration under the same
rule: ordered, incremental, total, each step reading only what the step before
it produced. One sense of the word holds across both.

**The idioms are the mechanism.** §5's three free steps cost nothing because the
language removes them. §7's relationship rides as refinements over the indices,
each constraint naming a thing that becomes unconstructible. §8's
derivation-from-target is a seam the tree already has three times. The named
instantiations above are rows in a table. §12 marks four idioms already in use
in `lib/` and all four are load-bearing here. None of it is new machinery, and
the model is their composition. Following what the language already does,
verbatim, is what makes the configuration derivable at all.

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
| C2 | the family's initial instances, and whether Ascon-p is one of them or a second design. §4 measures its round as dropping θ and π, so it is a composition owing an equality proof rather than the family at `planes = 1`. The family at `planes = 1` is the other candidate and §9's margin table reaches it nowhere |
| C3 | the PQ signature: ML-DSA against SLH-DSA, with FALCON eliminated |
| C4 | where each scheme's decompose-against-change line sits |
| C5 | the hybrid combiner construction |
| C6 | whether `N5` lands before the kernels, since scoping it after means writing every kernel twice |
| C7 | vectors as a `.manifest` against shell |
| C8 | the security target `S`, which fixes the capacity floor and therefore the whole curve |
| C9 | the shape of the `budget` declaration a target carries, now that §4 derives `planes` from it and stands `access` beside it |
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
- **the work-per-byte relationship under `access = windowed`**, which §7 leaves
  underived: the movement between the live window and the rest of the state is
  unmeasured and no figure for it is stated
- **`R` at a plane count other than 5.** `12 + 2l` is published over the seven
  widths at 25 lanes and §7's curve varies the plane count, so the round count
  every row of that table uses is this model's extrapolation
- **the security of the family at `planes = 1`.** §9's margin table covers
  Keccak-f[1600] and Ascon-p[12]. A one-plane Keccak-shaped permutation is
  neither, and §9 now reaches for it as the low-memory configuration
- **the two `k`s.** §4's `access` dial spells its window size `k` and §7's `k`
  is the ops-per-lane term. One of them owes a rename
- **what a windowed state is made of.** §6 rests on a record of named lanes with
  no array, and where the non-resident lanes live under `access = windowed` is
  unsettled. §6's argument is stated at `access = full`
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
