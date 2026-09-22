---
node: arc-crypto-primitives
layer: navigation
related: [arcs/README, goals/own-web, arcs/native-protocol-arc, banks/INDEX, decisions/decision-work-ids, decisions/decision-lane-split, records/author-calls, records/crypto-primitives, status-ledger, index]
status: current
updated: 2026-09-21
---

# Arc: the crypto primitives

- goals: [[goals/own-web]], condition 4: "**The primitives.** Every layer's
  crypto is chirality's own, post-quantum, with the configuration derived from
  the target."
- reserved element block: **none**. Rows carry arc-local ids `K1` and up per
  [[decisions/decision-work-ids]]. A band is advisory and an arc without one
  mints the next free number tree-wide.
- build-state authority: [[status-ledger]]
- checklist: [[records/crypto-primitives]], prefix `CP`, opened 2026-09-21 by the
  revisit that walked `.planning/REACH-MODEL.md` against this roster

Opened 2026-09-07. The design is `.planning/CRYPTO-MODEL.md`, which settles the
primitive set and its form, and `.planning/CRYPTO-TRANSLATION.md`, which settles
the frame that work is done under.

## Why this arc exists

The goal condition says every layer's crypto is ours, post-quantum, and derived
from the target rather than chosen by a person. `docs/goals/own-web.md` records
it as unopened and holding no arc file.

**The boundary against [[arcs/native-protocol-arc]].** That arc owns the wire:
its `N6` holds word ops, LE codecs and field arithmetic, `N7` holds GF(256), `N2`
the entropy crossing, `N5` the constant-time judgment, and `N3`, `N4`, `N8` and
`N9` the transport and split store. **This arc takes the layers those rows do not
reach**, which `.planning/CRYPTO-MODEL.md` §2 marks `unscoped`: the permutation,
the sponge modes, the tree, the post-quantum asymmetric pair, the combiner and
the PAKE. It also takes the translation and representation machinery, which is
new since that arc opened.

⚑ **`native-protocol/N10` overlaps this arc's whole subject.** It reads "the
post-quantum re-scope: `.planning/CRYPTO-MODEL.md`'s twelve decisions applied to
the kernel set". Whether it closes into this arc or keeps the two built slices as
its remaining scope is a boundary this run cannot settle, and it is carried to
[[records/author-calls]].

## What the tree already holds

Measured 2026-09-07.

| where | what | rung |
|---|---|---|
| `lib/crypto/chacha.chiral` | ChaCha20 block and stream, 163 lines | built, gated |
| `lib/crypto/poly1305.chiral` | Poly1305 and the AEAD composition, 245 lines | built, gated |
| `tools/test/run-tests.sh:367` | `run_phase 31 "the crypto kernels (N1 slices 1 and 2)"` | the gate runs in the suite |
| `lib/crypto/chacha.chiral:18-25` | the 32-bit lane idiom: `M32`, `add32`, `rotl32` inside signed `I64`. The word layer as one kernel spells it | built |
| `docs/translations/` | the translation tier, its README and one artifact | new 2026-09-07 |
| `tools/xlat/xlat.sh` | pin, obligations, carriers, gather, bundle, check, new | built |
| `.planning/sources/` | 3 raw pins: RFC 8439, RFC 9771, draft-irtf-cfrg-aead-limits-07 | measured |
| `ledger-lint` check AL | an external quote resolves into a pin | built, green |
| carrier forms in `lib/` | 142 linear-binder uses, 33 erased index, 15 indexed data, 15 category A, 8 refinement, 6 closed sum | built, comments excluded |

**A collision-resistant digest is absent**, and so is every layer below. The
permutation, the sponge, the tree, the PQ pair, the combiner and the PAKE have no
module and no row anywhere before this arc.

## What is missing, and its structure

Eight groups, in dependency order. Each owns one line.

| group | owns |
|---|---|
| `translation` | one published object rendered into our forms, before it is built |
| `permutation` | the family, parameterized only where the mathematics is |
| `modes` | hash, XOF, MAC and KDF as configurations of one machine |
| `tree` | the Merkle mode for chunked marks, and what its shape costs |
| `asymmetric` | the post-quantum KEM and signature |
| `combine` | how two shared secrets become one, and the short-secret exchange |
| `representation` | the same object encoded differently per target, proven equivalent |
| `assurance` | the laws, the differential and the vectors as three instruments |

### The edges that run against the order

Three, and an ordering with no back-edges reads as a schedule.

- **`assurance` runs backward into `permutation`.** The differential instrument
  needs two representations of one object, so it cannot be built after the
  permutation is finished. It constrains how the first one is written.
- **`native-protocol/N5` runs into this arc from outside it.**
  `.planning/CRYPTO-MODEL.md` `C6` states the cost: scoping the constant-time
  judgment after the kernels means writing every kernel twice.
- **`tree` runs backward into the naming layer.**
  `.planning/CRYPTO-TRANSLATION.md` §13 measures chunk size moving aggregate mark
  overhead by 16x, so the tree's shape is priced against the mark rather than
  after it.

## REQUIREMENTS

1. **Every primitive here is a translation before it is a module.** Its artifact
   sits in `docs/translations/`, `tools/xlat/xlat.sh check` exits 0 on it, and
   `pipeline-audit` at TRANSLATE level passes. Observable: `ledger-lint` check AL
   green with one artifact per built primitive.
2. **The permutation is a family parameterized only where the mathematics is,
   and a target below its floor fails to construct.** Observable: the module
   carries the lane width as an erased index, carries no parameter the published
   family lacks, and a gate row shows the refusal for a state that cannot hold
   its capacity.
3. **Correctness is checked by laws and by a differential, beside the vectors.**
   Observable: a differential gate names two representations of one object and
   runs in the suite; a law gate runs at the smallest member of a family; the
   published vectors live in a declared form rather than in shell.
4. **Randomness enters through one discipline and everything downstream of it is
   deterministic and reproducible.** Observable: no module here reads entropy
   directly, a randomness source is linear so it cannot be reused, and a key
   derived from a seed reproduces byte-for-byte.
5. **A primitive runs at the floor its target declared.** Observable: no
   allocation in an inner loop, and the resident cost measured against the
   declared budget rather than assumed.
6. **Nothing in this arc names a user.** Observable: the crypto modules carry no
   identity, principal or permission type. `.planning/CRYPTO-TRANSLATION.md` §15
   states why this is the invariant that keeps the layer above stratified.
7. **Every primitive carries its position on the path, and no asymmetric
   operation is reachable from a per-hop or per-parcel position.** Added
   2026-09-21 by the `.planning/REACH-MODEL.md` walk.
   `.planning/CRYPTO-MODEL.md` §15 already names `.planning/REACH-MODEL.md` §11
   the authority for **where** each primitive is spent, and this arc carried no
   requirement reading it. Observable: each module declares one of §11's five
   position classes, a gate shows the per-hop and per-parcel entry points
   reaching no public-key call, and each primitive's wire output is a stated
   number checked against §12's budget table rather than read off the
   implementation.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `crypto-primitives/K1` | translate Keccak-f[b]: the family at `b = 25w`, `R = 12 + 2l`, its five steps, and what each carrier reaches. Everything below rests on it | translation | law | new | 1, 2 | designed | `unminted` |
| `crypto-primitives/K2` | the permutation module: named lanes, no array, the width as an erased index, the round count as a type index | permutation | primitive | new | 2 | open | `unminted` |
| `crypto-primitives/K3` | translate the sponge: absorb, squeeze, padding, domain separation, and the keyed against unkeyed capacity bound | translation | law | new | 1 | open | `unminted` |
| `crypto-primitives/K4` | the sponge module: hash, XOF, MAC and KDF as configurations of `K2`, one machine, separated by domain | modes | primitive | new | 2 | open | `unminted` |
| `crypto-primitives/K5` | the mark: the digest a content address is, at the length the author ruled, with the refusal for a target below its floor ⚑ **AMENDED 2026-09-21 against `.planning/REACH-MODEL.md` §3.** A mark is a typed record of four fields and the digest is one of them: `alg`, a closed sum naming which digest; `digest`; `size`, read by the receiver before it accepts anything; and `chunk`, `whole` or `chunked n`, read by the asker's own router before it asks. This row was written as a digest at a length and the naming model makes it a record. `mark-of` is new work and E112's `block-id` at `lib/module/apc.chiral:48`, FNV-1a-64, is the precedent for the shape and too narrow to be the thing. | modes | primitive | new | 2 | open | `unminted` |
| `crypto-primitives/K6` | the tree mode for chunked marks: fanout, chunk size, domain separation, and the aggregate cost each choice carries ⚑ **AMENDED 2026-09-21 against `.planning/REACH-MODEL.md` §3 and §7.** The tree is not an option here. A `chunked n` mark commits to the root and verifying one parcel must prove that parcel belongs to this value alone, with no other parcel present, which is what makes a fetch resumable, splittable across peers and drawable from a bus, a cache and a tether at once. The fanout and the chunk size are priced against that property and not only against aggregate overhead. | tree | primitive | new | 2 | open | `unminted` |
| `crypto-primitives/K7` | translate a post-quantum KEM. The only place new mathematics enters: polynomial arithmetic, the NTT, sampling, compression ⚑ **AMENDED 2026-09-21 against `.planning/REACH-MODEL.md` §11 and §12.** The translation states whether the family admits re-randomisation, because §11 makes it the wall: Sphinx re-blinds one 32 B group element per hop, ML-KEM has no equivalent, and a ~1.1 KB ciphertext beside a ~1.2 KB public key takes the LAN header from ~304 B to ~1360 B and takes the radio profile out of one frame. Those sizes carry §11's own VERIFY caveat. | translation | law | new | 1 | open | `unminted` |
| `crypto-primitives/K8` | translate a post-quantum signature, and settle stateful against stateless. Linearity reaches the in-program half of the stateful objection and not the durability half | translation | decision | new | 1 | open | `unminted` |
| `crypto-primitives/K9` | the signature staircase: the one-time signature, the Merkle tree and the scheme over `K2`, introducing no new mathematics ⚑ **AMENDED 2026-09-21 against `.planning/REACH-MODEL.md` §11 and §12.** §11 puts the signature on the mutable pointer layer alone, so it never touches the fetch path and a large signature is affordable, and §12's receiver row budgets a signed pointer at ~3.3 KB. A hash-based staircase is tens of kilobytes at SLH-DSA's shape, an order over that budget. Which side moves is `.planning/CRYPTO-MODEL.md` `C3` and `.planning/CRYPTO-TRANSLATION.md` `T10`, both open, and this row settles neither. | asymmetric | primitive | new | 1 | open | `unminted` |
| `crypto-primitives/K10` | the KEM module, behind `K7` | asymmetric | primitive | new | 1 | open | `unminted` |
| `crypto-primitives/K11` | the combiner: how two shared secrets become one | combine | law | new | 1 | open | `unminted` |
| `crypto-primitives/K12` | the PAKE: a short human-carried secret authenticating an exchange ⚑ **AMENDED 2026-09-21 against `.planning/REACH-MODEL.md` §6.** One primitive serves two callers: a pairing whose output is a link secret, and a route ceremony whose output is a shared routing key. The property to state is that the construction gives an attacker one online guess instead of an offline dictionary attack, which is what lets roughly twenty bits of spoken secret authenticate a full-strength exchange. | combine | law | new | 1 | open | `unminted` |
| `crypto-primitives/K13` | the target declaration: what a target states beyond width, and the cost model that gives `best` a meaning | representation | decision | new | 5 | open | `unminted` |
| `crypto-primitives/K14` | the representation registry and its admission test: what evidence a second encoding of one object supplies to be admitted | representation | law | new | 3 | open | `unminted` |
| `crypto-primitives/K15` | the differential gate: two representations of one object agree, which is the floor `docs/definitions/testing-floors.md` records as cut | assurance | tool | new | 3 | open | `unminted` |
| `crypto-primitives/K16` | the law gate: the field axioms, bijectivity and the representation round trip, run exhaustively at the smallest member of each family | assurance | tool | new | 3 | open | `unminted` |
| `crypto-primitives/K17` | the user-naming refusal: the crypto modules carry no identity, principal or permission type, and something checks it | representation | law | new | 6 | open | `unminted` |
| `crypto-primitives/K18` | the randomness discipline: what consumes entropy, why a source is linear, and where deterministic derivation replaces a draw so `native-protocol/N2`'s crossing is spent once per identity ⚑ **AMENDED 2026-09-21 against `.planning/REACH-MODEL.md` §11.** The entropy row names three consumers and this row named none of them: keys, nonces, and cover selection. Cover selection draws every slot under §9's cadence, busy or idle, so the draw rate is a standing cost rather than a function of traffic. | representation | law | new | 4 | open | `unminted` |
| `crypto-primitives/K19` | the AEAD over the machine: a Farfalle or duplex mode at the keyed round count, which is the bulk path and the largest throughput lever in the stack | modes | primitive | new | 2 | open | `unminted` |
| `crypto-primitives/K20` | zero allocation in the inner loop. `.planning/CRYPTO-TRANSLATION.md` §13 measures allocation as what sets the target floor, against `lib/memory/mem-linear.chiral`, `mem-region.chiral` and the `Alloc` interface | representation | law | new | 5 | open | `unminted` |
| `crypto-primitives/K21` | materialization as the third memory dial beside `budget` and `access`: how much of a derivable structure is stored against recomputed, and whether the schedule is written or derived from the target | representation | decision | new | 5 | open | `unminted` |
| `crypto-primitives/K22` | the regime split: a public mark is unkeyed and one length, a private or group mark is keyed and shorter, and whether they are one type or two ⚑ **AMENDED 2026-09-21 against `.planning/REACH-MODEL.md` §4.** §4 prices unreadable and unreachable separately and says most private things want the first: a sealed value rides the **open** infrastructure as opaque bytes at nearly free, on the same path as any public value. That requires the sealed value to be addressed by a mark a stranger can verify, which a keyed mark is not, so the regime split has to say which mark addresses a sealed value. `R24` in §15 is the open fork and this row waits on it. | modes | decision | new | 2 | open | `unminted` |
| `crypto-primitives/K23` | the domain separator: its encoding, whether the configuration rides in it, and the extension point the layer above needs ⚑ **AMENDED 2026-09-21 against `.planning/REACH-MODEL.md` §6, §7 and §10.** The consumers that size the extension point are now named: §10's envelope slices, one key derivation each and their count open as `R12`; §6's per-pairing link secret against its per-ceremony route key; and the tree's leaf against internal separation that `K29` rests on. | modes | law | new | 2 | open | `unminted` |
| `crypto-primitives/K24` | the vector tier: the published constants as declared data rather than 403 lines of shell, which is `.planning/CRYPTO-MODEL.md` `C7` | assurance | tool | new | 3 | open | `unminted` |
| `crypto-primitives/K25` | the lattice arithmetic a KEM needs: `Z_q` at its moduli, modular reduction, the NTT and its inverse, and rejection sampling. `native-protocol/N6` predates the post-quantum target and says field arithmetic generically | asymmetric | primitive | new | 2 | open | `unminted` |
| `crypto-primitives/K26` | the wide-block payload cipher: a length-preserving strong pseudorandom permutation over the whole payload, so every payload bit changes and any modification invalidates all of it. `.planning/REACH-MODEL.md` §9 names it as one of the four mechanisms bitwise unlinkability needs, and it is not an AEAD: a 16 B tag beside a 12 B nonce expands what §9's fixed payload size forbids | modes | primitive | new | 2, 7 | open | `unminted` |
| `crypto-primitives/K27` | the output length as a security parameter: what a truncated tag, a shortened digest and an expanded seed each buy and cost, with the refusal below a declared floor. `.planning/REACH-MODEL.md` §12 offers three, an 8 B per-hop MAC at a stated cost in forgery resistance, a 24 B digest at 96-bit collision resistance instead of 128, and 16 B of per-hop key material where the hop expands a seed, and this arc priced none of them | modes | law | new | 2, 7 | open | `unminted` |
| `crypto-primitives/K28` | the `alg` field: which digest a mark names, as a closed sum the verifier reads, so the digest can change without invalidating every mark ever written. `.planning/REACH-MODEL.md` §3 puts it first in the record. What an arm costs, what a build that does not hold an arm does, and whether this is the same dispatch `.planning/CRYPTO-TRANSLATION.md` `T8` asks about for representations | modes | decision | new | 2 | open | `unminted` |
| `crypto-primitives/K29` | the inclusion proof: the sibling path a `give` carries for one parcel of a `chunked n` mark, its encoding, its verification against the root alone, and the leaf against internal separation that makes a forged path unconstructible. `.planning/REACH-MODEL.md` §12 prices it at one hash plus log(n) siblings riding the give | tree | primitive | new | 2, 3 | open | `unminted` |
| `crypto-primitives/K30` | the nonce discipline the keyed modes demand: whether the mode is misuse-resistant or an unrepeatable counter is structurally enforced, what a repeat costs, and where the counter lives. `.planning/REACH-MODEL.md` §16 raises nonce management across slices and under a long-lived key, and §9's cadence emits every slot busy or idle, so the nonce space is spent at a standing rate | modes | law | new | 2, 4 | open | `unminted` |
| `crypto-primitives/K31` | the grant: whether a bearer capability suffices or a membership proof is owed, and what a post-quantum anonymous credential would cost. `.planning/REACH-MODEL.md` §4 requires permission proved without identity, which is what keeps anonymity across the gate, and `.planning/CRYPTO-MODEL.md` §2's twelve layers hold no credential layer at all. `R1` and `R24` in §15 are the open forks and this row waits on them | asymmetric | decision | new | 1, 6 | open | `unminted` |
| `crypto-primitives/K32` | the header's asymmetric element: whether the selected KEM re-randomises, what Outfox's dropped second exchange requires of it, and what the isogeny option costs. `.planning/REACH-MODEL.md` §11 prices this as the wall and §12 as the difference between a ~304 B and a ~1360 B header. `R11` in §15 is the open fork and this row waits on it | asymmetric | decision | new | 1, 7 | open | `unminted` |
| `crypto-primitives/K33` | the position declaration and the forwarding-path refusal: each module states one of `.planning/REACH-MODEL.md` §11's five position classes, and something shows the per-hop and per-parcel entry points reaching no public-key call. The same shape as `K17`, for requirement 7 instead of 6 | representation | law | new | 7 | open | `unminted` |

### Coverage

Every requirement is named by at least one row: 1 by `K1`, `K3`, `K7`, `K8`,
`K9`, `K10`, `K11`, `K12`, `K31` and `K32`; 2 by `K1`, `K2`, `K4`, `K5`, `K6`,
`K19`, `K22`, `K23`, `K25`, `K26`, `K27`, `K28`, `K29` and `K30`; 3 by `K14`,
`K15`, `K16`, `K24` and `K29`; 4 by `K18` and `K30`; 5 by `K13`, `K20` and
`K21`; 6 by `K17` and `K31`; 7 by `K26`, `K27`, `K32` and `K33`.

Every row names at least one requirement. Every `origin` is `new`, and §3
defends it: the permutation, the sponge, the tree, the PQ pair, the combiner and
the PAKE have no module in `lib/`, and the representation, randomness and
assurance machinery has no home anywhere. The two built modules
`lib/crypto/chacha.chiral` and `lib/crypto/poly1305.chiral` belong to
`native-protocol/N1` and no row here claims them.

⚑ **Eight rows were added after the first coverage run, and the omission is
worth recording.** `K18` through `K25` were found by walking
`.planning/CRYPTO-TRANSLATION.md` against the roster, which the first pass never
did: it built from `.planning/CRYPTO-MODEL.md` §2's `unscoped` column alone.
Randomness, the bulk AEAD path, allocation, materialization, the regime split,
the domain separator, the vector tier and the lattice arithmetic all had zero
mentions. Working from one source and treating it as the whole object is the
failure this tree keeps finding.

⚑ **It happened a second time, and the count is the same.** `K26` through `K33`
and requirement 7 were added 2026-09-21 by walking `.planning/REACH-MODEL.md`
end to end against this roster, the sweep the Resume state below had flagged as
owed and unrun. Eight rows again. The wide-block cipher §9 names, the three
truncation levers §12 prices, the mark's `alg` field §3 puts first, the
inclusion proof §12 budgets at log(n) siblings, the nonce discipline §16 raises,
the grant §4 requires, the header's asymmetric element §11 calls the wall, and
the position axis `.planning/CRYPTO-MODEL.md` §15 had already named
`.planning/REACH-MODEL.md` §11 the authority for. Eight of the twenty-five rows
that already existed were amended in place against the same walk. **Three
sources was the count, and the arc read two.**

⚑ **`.planning/REACH-MODEL.md` §4 asks for a primitive class no crypto document
enumerates.** A `Grant` proves permission without proving identity, and
`.planning/CRYPTO-MODEL.md` §2's twelve layers run word, permutation, modes,
tree, AEAD, arithmetic, classical asymmetric, PQ asymmetric, combiner, PAKE,
entropy and constant time, with no credential layer among them. `K31` holds the
question and settles nothing.

## Resume state

Opened 2026-09-07 with 25 rows and 6 requirements, none designed. **33 rows and
7 requirements from 2026-09-21**, still none designed beyond `K1`.

The translation tier landed the same day and is what this arc runs on:
`docs/translations/` with its README, `tools/xlat/xlat.sh`, `pipeline-audit` at
TRANSLATE level, and `ledger-lint` check AL. Three raw pins are in
`.planning/sources/`. One artifact exists,
`docs/translations/aead-chacha20-poly1305.md`, at `status: draft` and never
audited, with 12 citations resolving and its `known-gaps` gather slot `UNRUN`.

**The roster holds two kinds of row and they dispatch differently.** A
translation row (`K1`, `K3`, `K7`, `K8`, `K11`, `K12`) runs the `translate`
skill off `tools/xlat/xlat.sh bundle <object>`, and its artifact lands in
`docs/translations/`. Every other row runs `element-design` off
`python3 tools/pack/pack.py crypto-primitives/K<n>`, which is verified working
and returns a DESIGN bundle. Dispatching a translation row into `element-design`
would produce a design for an object nobody has read.

⚑ **A translation row needs its gather manifest and its pins before it can be
dispatched.** `.planning/sources/` holds one manifest, for the AEAD, and three
raw pins. `K1` has neither, so its first act is the gather: name the four slots,
pin what exists, and declare what does not.

⚑ **WALKED 2026-09-21.** `.planning/REACH-MODEL.md` had never been read against
this roster and now has been, all 852 lines. The verdict was AMEND by addition:
requirement 7, rows `K26` to `K33`, and eight existing `what` cells corrected in
place. Nothing was removed and no row was renumbered. §Coverage carries what the
walk found. `K5`, `K6` and `K22` were the three rows named as suspects and all
three moved; so did `K7`, `K9`, `K12`, `K18` and `K23`, which nothing had
flagged.

⚑ **The walk found one collision between two rulings and did not settle it.**
`.planning/REACH-MODEL.md` §12 budgets a mark's digest at 32 B, with 24 B priced
as the shrink, and `.planning/CRYPTO-TRANSLATION.md` `T9` ruled the 64-byte mark
on 2026-09-07, two days after that budget was written. Every wire figure in §12
rests on the smaller number. Which side moves is the author's, it is carried to
[[records/author-calls]] by [[records/crypto-primitives]] `CP-01`, and no row
here assumes an answer.

**Next, in order.** Audit that artifact at TRANSLATE level, which closes the loop
on a gate that has never run against real work. Then `K1`, because everything
under this arc rests on the permutation and its family is the one place the
mathematics is genuinely parametric. The 2026-09-21 walk moved neither: `K1`
gained no new obligation and its gather is still its first act.

`.planning/CRYPTO-MODEL.md` §13 carries twelve decisions and
`.planning/CRYPTO-TRANSLATION.md` §16 carries seventeen. Two are ruled: the
maximize principle, and `T9` at the 64-byte mark. `T1` gates how every row here
is written and stands open: faithful to the specification's algorithm, or
faithful to the mathematics the algorithm computes.

`.planning/REACH-MODEL.md` §15 carries twenty-four more, `R1` to `R24`, and one
closed. Four of them reach rows here and each is cited by the row that waits on
it: `R1` and `R24` by `K31`, `R11` by `K32`, `R12` by `K23`, and `R24` again by
`K22`. `R3`, the digest and its width, is the fork the 64-byte collision above
sits in, and it reads that `native-protocol/N1` picks. None is answered here.
§16 of that file is four paragraphs of notes to cover, and `K30` is the one row
this walk drew out of them.
