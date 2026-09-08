---
node: arc-crypto-primitives
layer: navigation
related: [arcs/README, goals/own-web, arcs/native-protocol-arc, banks/INDEX, decisions/decision-work-ids, decisions/decision-lane-split, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-07
---

# Arc: the crypto primitives

- goals: [[goals/own-web]], condition 4: "**The primitives.** Every layer's
  crypto is chirality's own, post-quantum, with the configuration derived from
  the target."
- reserved element block: **none**. Rows carry arc-local ids `K1` and up per
  [[decisions/decision-work-ids]]. A band is advisory and an arc without one
  mints the next free number tree-wide.
- build-state authority: [[status-ledger]]

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

## Roster

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `crypto-primitives/K1` | translate Keccak-f[b]: the family at `b = 25w`, `R = 12 + 2l`, its five steps, and what each carrier reaches. Everything below rests on it | translation | law | new | 1, 2 | open | `unminted` |
| `crypto-primitives/K2` | the permutation module: named lanes, no array, the width as an erased index, the round count as a type index | permutation | primitive | new | 2 | open | `unminted` |
| `crypto-primitives/K3` | translate the sponge: absorb, squeeze, padding, domain separation, and the keyed against unkeyed capacity bound | translation | law | new | 1 | open | `unminted` |
| `crypto-primitives/K4` | the sponge module: hash, XOF, MAC and KDF as configurations of `K2`, one machine, separated by domain | modes | primitive | new | 2 | open | `unminted` |
| `crypto-primitives/K5` | the mark: the digest a content address is, at the length the author ruled, with the refusal for a target below its floor | modes | primitive | new | 2 | open | `unminted` |
| `crypto-primitives/K6` | the tree mode for chunked marks: fanout, chunk size, domain separation, and the aggregate cost each choice carries | tree | primitive | new | 2 | open | `unminted` |
| `crypto-primitives/K7` | translate a post-quantum KEM. The only place new mathematics enters: polynomial arithmetic, the NTT, sampling, compression | translation | law | new | 1 | open | `unminted` |
| `crypto-primitives/K8` | translate a post-quantum signature, and settle stateful against stateless. Linearity reaches the in-program half of the stateful objection and not the durability half | translation | decision | new | 1 | open | `unminted` |
| `crypto-primitives/K9` | the signature staircase: the one-time signature, the Merkle tree and the scheme over `K2`, introducing no new mathematics | asymmetric | primitive | new | 1 | open | `unminted` |
| `crypto-primitives/K10` | the KEM module, behind `K7` | asymmetric | primitive | new | 1 | open | `unminted` |
| `crypto-primitives/K11` | the combiner: how two shared secrets become one | combine | law | new | 1 | open | `unminted` |
| `crypto-primitives/K12` | the PAKE: a short human-carried secret authenticating an exchange | combine | law | new | 1 | open | `unminted` |
| `crypto-primitives/K13` | the target declaration: what a target states beyond width, and the cost model that gives `best` a meaning | representation | decision | new | 5 | open | `unminted` |
| `crypto-primitives/K14` | the representation registry and its admission test: what evidence a second encoding of one object supplies to be admitted | representation | law | new | 3 | open | `unminted` |
| `crypto-primitives/K15` | the differential gate: two representations of one object agree, which is the floor `docs/definitions/testing-floors.md` records as cut | assurance | tool | new | 3 | open | `unminted` |
| `crypto-primitives/K16` | the law gate: the field axioms, bijectivity and the representation round trip, run exhaustively at the smallest member of each family | assurance | tool | new | 3 | open | `unminted` |
| `crypto-primitives/K17` | the user-naming refusal: the crypto modules carry no identity, principal or permission type, and something checks it | representation | law | new | 6 | open | `unminted` |
| `crypto-primitives/K18` | the randomness discipline: what consumes entropy, why a source is linear, and where deterministic derivation replaces a draw so `native-protocol/N2`'s crossing is spent once per identity | representation | law | new | 4 | open | `unminted` |
| `crypto-primitives/K19` | the AEAD over the machine: a Farfalle or duplex mode at the keyed round count, which is the bulk path and the largest throughput lever in the stack | modes | primitive | new | 2 | open | `unminted` |
| `crypto-primitives/K20` | zero allocation in the inner loop. `.planning/CRYPTO-TRANSLATION.md` §13 measures allocation as what sets the target floor, against `lib/memory/mem-linear.chiral`, `mem-region.chiral` and the `Alloc` interface | representation | law | new | 5 | open | `unminted` |
| `crypto-primitives/K21` | materialization as the third memory dial beside `budget` and `access`: how much of a derivable structure is stored against recomputed, and whether the schedule is written or derived from the target | representation | decision | new | 5 | open | `unminted` |
| `crypto-primitives/K22` | the regime split: a public mark is unkeyed and one length, a private or group mark is keyed and shorter, and whether they are one type or two | modes | decision | new | 2 | open | `unminted` |
| `crypto-primitives/K23` | the domain separator: its encoding, whether the configuration rides in it, and the extension point the layer above needs | modes | law | new | 2 | open | `unminted` |
| `crypto-primitives/K24` | the vector tier: the published constants as declared data rather than 403 lines of shell, which is `.planning/CRYPTO-MODEL.md` `C7` | assurance | tool | new | 3 | open | `unminted` |
| `crypto-primitives/K25` | the lattice arithmetic a KEM needs: `Z_q` at its moduli, modular reduction, the NTT and its inverse, and rejection sampling. `native-protocol/N6` predates the post-quantum target and says field arithmetic generically | asymmetric | primitive | new | 2 | open | `unminted` |

### Coverage

Every requirement is named by at least one row: 1 by `K1`, `K3`, `K7`, `K8`,
`K9`, `K10`, `K11` and `K12`; 2 by `K1`, `K2`, `K4`, `K5`, `K6`, `K19`, `K22`,
`K23` and `K25`; 3 by `K14`, `K15`, `K16` and `K24`; 4 by `K18`; 5 by `K13`,
`K20` and `K21`; 6 by `K17`.

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

## Resume state

Opened 2026-09-07 with 25 rows and 6 requirements, none designed.

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

⚑ **`.planning/REACH-MODEL.md` was never walked against this roster.** The arc
was built from `.planning/CRYPTO-MODEL.md` and `.planning/CRYPTO-TRANSLATION.md`
alone. `K5`, `K6` and `K22` all touch the naming layer that model owns, and the
same omission produced the eight rows §Coverage records. It is the obvious next
sweep and it has not been run.

**Next, in order.** Audit that artifact at TRANSLATE level, which closes the loop
on a gate that has never run against real work. Then `K1`, because everything
under this arc rests on the permutation and its family is the one place the
mathematics is genuinely parametric.

`.planning/CRYPTO-MODEL.md` §13 carries twelve decisions and
`.planning/CRYPTO-TRANSLATION.md` §16 carries seventeen. Two are ruled: the
maximize principle, and `T9` at the 64-byte mark. `T1` gates how every row here
is written and stands open: faithful to the specification's algorithm, or
faithful to the mathematics the algorithm computes.
