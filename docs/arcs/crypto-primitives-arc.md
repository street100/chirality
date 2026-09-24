---
node: arc-crypto-primitives
layer: navigation
related: [arcs/README, goals/own-web, arcs/native-protocol-arc, banks/INDEX, decisions/decision-work-ids, decisions/decision-lane-split, records/author-calls, records/crypto-primitives, status-ledger, index]
status: current
updated: 2026-09-22
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
   implementation. ⚑ **AMENDED 2026-09-22 against
   `.planning/RUNG2-MICROVM-MAP.md` §5.6.** §11's five classes run per pairing,
   per ceremony, per message creation, per hop and per parcel, which is a
   message-path axis, and the boot chain is not on the message path. A primitive
   whose consumers are install, boot and login therefore sits on none of the
   five. Such a module declares **off-path** and states its frequency instead.
   That `.planning/REACH-MODEL.md:507-513` holds no such class is reported here
   and not settled: widening that table is outside this arc's write surface.
8. **A keyed module's output is indexed by the key and the context that produced
   it, so use under the wrong key or in the wrong context does not construct.**
   Added 2026-09-22 by the `.planning/AI-RESIDENT-AND-CAPABILITY-RUNG.md` §7
   walk. `:371-375` applies its §3 witness move to ciphertext, *"indexed by
   0-quantity key and context terms"*, and prices the refusal as covering *"key
   confusion and cross-context decryption"*, which it calls most of the real
   CVEs. No requirement here read the shape of a keyed module's output type: 2
   indexes the permutation's width, 6 refuses a name, 7 declares a position, and
   none of the three reaches what a ciphertext is. Observable: each keyed
   module's ciphertext, tag or derived key is a datum carrying its key and its
   domain as erased indices; a gate row shows a decryption offered a different
   key binding or a different domain failing to typecheck; and each such module
   states which guarantee its index carries, because the index equates terms and
   not bytes. ⚑ **The carrier this asks for does not exist in `lib/`.** Every
   erased binder there is `(0 _ (type 0))` or `(0 _ I64)`, the `(Pool n)` shape
   at `lib/memory/mem-linear.chiral:15`, and nothing anywhere is indexed by a
   data term. So this requirement is new carrier work rather than a second
   customer for a built idiom, and the honest reading of what it buys is refusal
   on the **binding** a ciphertext was produced under, not on the key's value.

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `crypto-primitives/K1` | translate Keccak-f[b]: the family at `b = 25w`, `R = 12 + 2l`, its five steps, and what each carrier reaches. Everything below rests on it | translation | law | new | 1, 2 | designed | `unminted` |
| `crypto-primitives/K2` | the permutation module: named lanes, no array, the width as an erased index, the round count as a type index | permutation | primitive | new | 2 | open | `unminted` |
| `crypto-primitives/K3` | translate the sponge: absorb, squeeze, padding, domain separation, and the keyed against unkeyed capacity bound | translation | law | new | 1 | open | `unminted` |
| `crypto-primitives/K4` | the sponge module: hash, XOF, MAC and KDF as configurations of `K2`, one machine, separated by domain | modes | primitive | new | 2 | open | `unminted` |
| `crypto-primitives/K5` | the mark: the digest a content address is, at the length the author ruled, with the refusal for a target below its floor ⚑ **AMENDED 2026-09-21 against `.planning/REACH-MODEL.md` §3.** A mark is a typed record of four fields and the digest is one of them: `alg`, a closed sum naming which digest; `digest`; `size`, read by the receiver before it accepts anything; and `chunk`, `whole` or `chunked n`, read by the asker's own router before it asks. This row was written as a digest at a length and the naming model makes it a record. `mark-of` is new work and E112's `block-id` at `lib/protocol/apc.chiral:48`, FNV-1a-64, is the precedent for the shape and too narrow to be the thing. | modes | primitive | new | 2 | open | `unminted` |
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
| `crypto-primitives/K19` | the AEAD over the machine: a Farfalle or duplex mode at the keyed round count, which is the bulk path and the largest throughput lever in the stack | modes | primitive | new | 2, 8 | open | `unminted` |
| `crypto-primitives/K20` | zero allocation in the inner loop. `.planning/CRYPTO-TRANSLATION.md` §13 measures allocation as what sets the target floor, against `lib/memory/mem-linear.chiral`, `mem-region.chiral` and the `Alloc` interface | representation | law | new | 5 | open | `unminted` |
| `crypto-primitives/K21` | materialization as the third memory dial beside `budget` and `access`: how much of a derivable structure is stored against recomputed, and whether the schedule is written or derived from the target | representation | decision | new | 5 | open | `unminted` |
| `crypto-primitives/K22` | the regime split: a public mark is unkeyed and one length, a private or group mark is keyed and shorter, and whether they are one type or two ⚑ **AMENDED 2026-09-21 against `.planning/REACH-MODEL.md` §4.** §4 prices unreadable and unreachable separately and says most private things want the first: a sealed value rides the **open** infrastructure as opaque bytes at nearly free, on the same path as any public value. That requires the sealed value to be addressed by a mark a stranger can verify, which a keyed mark is not, so the regime split has to say which mark addresses a sealed value. `R24` in §15 is the open fork and this row waits on it. | modes | decision | new | 2 | open | `unminted` |
| `crypto-primitives/K23` | the domain separator: its encoding, whether the configuration rides in it, and the extension point the layer above needs ⚑ **AMENDED 2026-09-21 against `.planning/REACH-MODEL.md` §6, §7 and §10.** The consumers that size the extension point are now named: §10's envelope slices, one key derivation each and their count open as `R12`; §6's per-pairing link secret against its per-ceremony route key; and the tree's leaf against internal separation that `K29` rests on. | modes | law | new | 2, 8 | open | `unminted` |
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
| `crypto-primitives/K34` | the memory-hard derivation: a key from a human-chosen secret at a deliberate memory and time cost, the cost parameters declared, and the refusal for a target that cannot pay them. `.planning/RUNG2-MICROVM-MAP.md:284-287` puts hash, signature and KDF on the critical path from install onward and names Argon2 and scrypt for the KDF, which is the password-hashing job and **not** the key-expansion job `K4` configures the sponge for: `.planning/REACH-MODEL.md:520` prices its KDF at *"per-layer and per-parcel keys from a link secret"*, 32 B out, riding whichever hash is chosen. One word, two primitives, and this arc held only the second. `.planning/RUNG2-SECURITY-MODEL.md:112` adds the property the construction has to carry: a static passphrase reaching the same bundle every time is what leaves T2 unenforceable, so the derivation is salted and session-scoped rather than a pure function of the secret. ⚑ **This row collides with requirement 5 and with `K20`.** A memory-hard function's whole mechanism is a large deliberate allocation, so "no allocation in an inner loop" cannot mean here what it means elsewhere and the declared budget is the only thing it can be measured against. Its position is the off-path case requirement 7 now names | modes | law | new | 1, 5, 7, 8 | open | `unminted` |
| `crypto-primitives/K35` | the derivation hierarchy: keys descend from one seed so that a child reveals nothing about a sibling or a parent, which is what makes `.planning/RUNG2-MICROVM-MAP.md:263`'s per-stage independent keys multiply across boot stages instead of adding. `.planning/CRYPTO-TRANSLATION.md:569` names it one of four things that must hold now for the deferred layer above to land without rework, and no row carried it. The boundary against two rows that neighbour it: `K18` says a deterministic derivation replaces an entropy draw, `K23` says how a domain is encoded, and neither states the independence property or the shape of the tree | representation | law | new | 4, 6, 8 | open | `unminted` |
| `crypto-primitives/K36` | the key-and-context index: a keyed module's ciphertext, tag or derived key is a datum indexed by erased key and domain terms, so decryption under the wrong key or in the wrong context does not construct, and something shows every keyed module carries it. The same shape as `K17` for requirement 6 and `K33` for requirement 7, and the law and its check are one row here as they are there. `.planning/AI-RESIDENT-AND-CAPABILITY-RUNG.md:371-375` applies its §3 witness move to ciphertext and calls key confusion and cross-context decryption *"most of the real CVEs"*. Two things this row settles before any design. **The index equates terms, not bytes**: two live keys bound through one variable are one key to the checker, so the refusal is over provenance and the row states that rather than inheriting the document's phrasing. **The carrier is new work**: `lib/` holds `(0 _ (type 0))` and `(0 _ I64)` and no erased binder over a data term anywhere, so `(Pool n)` at `lib/memory/mem-linear.chiral:15` is a precedent for the shape and not for the content. It carries the dependency `.planning/AI-RESIDENT-AND-CAPABILITY-RUNG.md:375` names, §3.3's rule that an erased position must be effect-free or 0 is not erasure, which is `E12`'s effect membrane and not this arc's to enforce | representation | law | new | 8 | open | `unminted` |

### Coverage

Every requirement is named by at least one row: 1 by `K1`, `K3`, `K7`, `K8`,
`K9`, `K10`, `K11`, `K12`, `K31`, `K32` and `K34`; 2 by `K1`, `K2`, `K4`, `K5`,
`K6`, `K19`, `K22`, `K23`, `K25`, `K26`, `K27`, `K28`, `K29` and `K30`; 3 by
`K14`, `K15`, `K16`, `K24` and `K29`; 4 by `K18`, `K30` and `K35`; 5 by `K13`,
`K20`, `K21` and `K34`; 6 by `K17`, `K31` and `K35`; 7 by `K26`, `K27`, `K32`,
`K33` and `K34`; 8 by `K19`, `K23`, `K34`, `K35` and `K36`.

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

⚑ **A third walk, and the count broke.** `K34` and `K35` were added 2026-09-22
by walking `.planning/RUNG2-MICROVM-MAP.md` §5.6 and
`.planning/RUNG2-SECURITY-MODEL.md` §3 and §6 against this roster, the first two
of the three walks [[records/crypto-primitives]] `CP-02` left owed. **Two rows,
not eight**, and the drop is the finding: both documents write from the
consumer's side, and a census that reads a document as owning rows is not a
census that predicts how many. The one genuinely new primitive class is the
memory-hard derivation, `K34`. Everything else those sections name was already
here under a different name, was already homed in another arc, or is a consumer
this arc does not own. **Five sources is the count now, and the arc has read
five.** §5.6's Shamir-split anchor and its robust-shared manifest are
`native-protocol/N6` to `N8`; its register-anchored MAC and its whole tier 2 are
rung-2 hardware, which `docs/decisions/decision-deployment-custody.md:63-67`
puts behind metal; its reproducible-build consensus is determinism and not a
primitive; and §3's T1 and T2 tables are the capability layer, layer 3 in
`.planning/CRYPTO-TRANSLATION.md:541-546`.

⚑ **A fourth walk, and it cost one row and a requirement.**
`.planning/AI-RESIDENT-AND-CAPABILITY-RUNG.md` §7 was read against this roster on
2026-09-22, the last of the three `OWNS-ROWS` walks
[[records/crypto-primitives]] `CP-02` ordered. `K36` and requirement 8 are what
it cost, and four `req` cells moved: `K19` from 2 to 2, 8; `K23` from 2 to 2, 8;
`K34` from 1, 5, 7 to 1, 5, 7, 8; `K35` from 4, 6 to 4, 6, 8. No `what` cell
moved, nothing was renumbered, no element minted. **Six sources is the count now
and the arc has read six.** ⚑ **The requirement reaches wider than the four
cells that cite it.** Twelve rows produce a keyed output and requirement 8
constrains every one: `K4`'s MAC and KDF configurations, `K5` and `K22`'s keyed
mark, `K10`'s KEM output, `K11`'s combined secret, `K12`'s PAKE output, `K19`'s
AEAD, `K23`'s domain, `K26`'s wide-block cipher, `K27`'s truncated tag and
expanded seed, `K30`'s nonce as the other half of the context, `K34`'s
passphrase-derived key and `K35`'s child keys. The four that cite it are the
four whose own decision the index changes; the requirement's own text is what
binds the rest, which is how requirement 7 already stands with five citing rows
against every primitive it names. ⚑ **The rest of §7 owes this arc nothing.**
`:368`'s nonce-uniqueness-as-quantity-1 is `K30`, and `CP-02` had already found
`.planning/FORMULA-RETHINK.md:20` answering it the same way, so two documents
now converge on a design call `K30` still makes. §7.1's inbound-verifies /
outbound-confines split is the membrane, `docs/definitions/open-edges.md` G4 and
edge 14. `:376`'s length and shape refinements are `E9`, built. `:377-379`'s
`E40` linear `Secret` and `E38` `clear-window <= N` are layer 1 custody, already
seated in `.planning/RUNG-2-MAP.md` Cluster 2. §7.3's runtime-as-a-profile is
`decision-profiles` and `spawn`. Not one of them is a primitive.

⚑ **The tier-1 set splits along the post-quantum line and only one half was
missing.** `.planning/RUNG2-MICROVM-MAP.md:284-287` names hash, signature and
KDF. The **hash** is already here, as `K1` and `K2`'s permutation under `K3` and
`K4`'s sponge, with `K5` the mark it addresses with, `K27` its width and `K28`
its `alg` field; a digest is symmetric and
`.planning/CRYPTO-MODEL.md:47-49` records the symmetric half standing under
Grover. The **signature** named there is Ed25519, which
`.planning/CRYPTO-MODEL.md:46` records as *"dead"* under Shor, so the named
instance is unimportable and its class is already held by `K8`, `K9` and `K32`.
The **KDF** is where the word hid a second primitive, and `K34` is the row. A
reference class that is half symmetric survives a post-quantum re-scope by
halves, and this arc had covered the half that survives.

⚑ **`.planning/REACH-MODEL.md` §4 asks for a primitive class no crypto document
enumerates.** A `Grant` proves permission without proving identity, and
`.planning/CRYPTO-MODEL.md` §2's twelve layers run word, permutation, modes,
tree, AEAD, arithmetic, classical asymmetric, PQ asymmetric, combiner, PAKE,
entropy and constant time, with no credential layer among them. `K31` holds the
question and settles nothing.

## Resume state

Opened 2026-09-07 with 25 rows and 6 requirements, none designed. 33 rows and 7
requirements from 2026-09-21. 35 rows and 7 requirements from 2026-09-22.
**36 rows and 8 requirements from 2026-09-22**, still none designed beyond `K1`.

The translation tier landed the same day and is what this arc runs on:
`docs/translations/` with its README, `tools/xlat/xlat.sh`, `pipeline-audit` at
TRANSLATE level, and `ledger-lint` check AL. Three raw pins are in
`.planning/sources/`. One artifact exists,
`docs/translations/aead-chacha20-poly1305.md`, at `status: draft` and never
audited, with 12 citations resolving and its `known-gaps` gather slot `UNRUN`.

**The roster holds two kinds of row and they dispatch differently.** A
translation row (`K1`, `K3`, `K7`, `K8`, `K11`, `K12`, `K34`) runs the
`translate` skill off `tools/xlat/xlat.sh bundle <object>`, and its artifact
lands in
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

⚑ **WALKED 2026-09-22.** `.planning/RUNG2-MICROVM-MAP.md` §5.6 and
`.planning/RUNG2-SECURITY-MODEL.md` §3 and §6 have now been read against this
roster, the first two of the three walks [[records/crypto-primitives]] `CP-02`
left owed. AMEND by addition: `K34`, `K35`, and one clause on requirement 7.
No existing `what` cell moved and nothing was renumbered. §Coverage carries what
the walk found.

⚑ **WALKED 2026-09-22, and the `OWNS-ROWS` list is now empty.**
`.planning/AI-RESIDENT-AND-CAPABILITY-RUNG.md` §7 has been read against this
roster, the third and last of the walks [[records/crypto-primitives]] `CP-02`
ordered. AMEND by addition: `K36`, requirement 8, and four `req` cells. No
`what` cell moved and nothing was renumbered. §Coverage carries what the walk
found. **What is still owed is the six `REACHES` documents `CP-02` lists**, and
the first of them, `.planning/LANGUAGE-INVENTORY.md`, names `K1` to `K5`, `K7` to
`K12`, `K18` and `K25` and has never been read here, which makes it the largest
unread claim on this roster.

⚑ **Three of `.planning/AI-RESIDENT-AND-CAPABILITY-RUNG.md` §10's open items
sit next to this arc and none of them is a primitive.** Item 7, *"one master secret
or N?"* at `:511-512`, asks whether every unlock position derives one master
secret by different paths or holds distinct material. That is custody policy over
the hierarchy `K35` already rosters, and §6.4 at `:306-309` already homes it on
`.planning/RUNG-2-MAP.md` Cluster 1's boot-path row, which has no catalog
element. Item 8, key-material reachability as a conformance row at `:513-514`,
asks whether `chirality verify` checks the join across positions the way it
checks `(total)`; that tool does not exist and
`docs/arcs/presentability-arc.md:59` `presentability/D3` is the row for whether
it is built or retired. Item 10 at `:517-518` is the boundary's data direction,
and §7.3 says it itself: it *"changes the exposure surface, not the types"*, so
it lands on the membrane at `docs/definitions/open-edges.md` G4 and edge 14.
Reported, and no row was written into another arc's file.

⚑ **Two homes for the constant-time judgment, and this run does not settle it.**
`.planning/RUNG2-SECURITY-MODEL.md:191` routes tier-1 constant time to **`E60`**,
which `docs/elements/ledger.md:247` holds as a minted element at `design` state
and `docs/elements/catalog.md:202` describes as preserve-check's first customer.
This arc routes the same judgment to **`native-protocol/N5`**, an unminted
roster row, and §"The edges that run against the order" above prices the cost of
scoping it late. `.planning/REACH-MODEL.md:524` names `N5` and not `E60`. One
judgment, two homes and two tiers, which is the same shape as the `N10` boundary
already carried to [[records/author-calls]]. Reported, not settled.

**Next, in order.** Audit that artifact at TRANSLATE level, which closes the loop
on a gate that has never run against real work. Then `K1`, because everything
under this arc rests on the permutation and its family is the one place the
mathematics is genuinely parametric. The 2026-09-21 walk moved neither: `K1`
gained no new obligation and its gather is still its first act.

`.planning/CRYPTO-MODEL.md` §13 carries twelve decisions and
`.planning/CRYPTO-TRANSLATION.md` §16 carries seventeen. Three are ruled: the
maximize principle, `T9` at the 64-byte mark, and `T1`. ⚑ **`T1` was read here as
open until 2026-09-23 and it was ruled on 2026-09-07.**
`.planning/CRYPTO-TRANSLATION.md:582` carries the ruling: "**RULED 2026-09-07:
the mathematics, realized as separated primitives.** The five step mappings are
each their own primitive with its own signature. The family is the layer above
them, and any fusion is a composition there that owes a proof of equality". It
gates how every row here is written, and what it fixes is the factoring: a step
mapping is a primitive, the family sits above them, and a fused step is a
composition at that layer carrying a proof of equality. `.planning/CRYPTO-MODEL.md:107-215`
§4 is written to it, and [[records/crypto-primitives]] `CP-06` carries the
revisit that found this paragraph stale.

`.planning/REACH-MODEL.md` §15 carries twenty-four more, `R1` to `R24`, and one
closed. Four of them reach rows here and each is cited by the row that waits on
it: `R1` and `R24` by `K31`, `R11` by `K32`, `R12` by `K23`, and `R24` again by
`K22`. `R3`, the digest and its width, is the fork the 64-byte collision above
sits in, and it reads that `native-protocol/N1` picks. None is answered here.
§16 of that file is four paragraphs of notes to cover, and `K30` is the one row
this walk drew out of them.
