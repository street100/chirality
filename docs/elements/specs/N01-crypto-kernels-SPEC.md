---
element: N01
slug: crypto-kernels
title: "**Crypto kernels: an AEAD cipher, a hash, a key exchange, the WireGuard suite as reference class**"
kind: LAYER-K
example: examples/N01-crypto-kernels.md
status: draft
updated: 2026-09-03
---

# N01 SPEC: **Crypto kernels: an AEAD cipher, a hash, a key exchange, the WireGuard suite as reference class**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** four new pure modules under `lib/crypto/` hold the
  WireGuard kernel suite natively, and a new gate phase asserts the published
  RFC vectors against each one. The exported surface, all `->`:

  | module | binding | type |
  |---|---|---|
  | `crypto/chacha` | `chacha-block` | `(-> Bytes Bytes I64 Bytes)` |
  | `crypto/chacha` | `chacha-xor` | `(-> Bytes Bytes I64 Bytes Bytes)` |
  | `crypto/poly1305` | `poly1305-mac` | `(-> Bytes Bytes Bytes)` |
  | `crypto/poly1305` | `aead-seal` | `(-> Bytes Bytes Bytes Bytes Bytes)` |
  | `crypto/poly1305` | `aead-open` | `(-> Bytes Bytes Bytes Bytes OpenR)` |
  | `crypto/blake2s` | `blake2s-hash` | `(-> Bytes Bytes)` |
  | `crypto/x25519` | `x25519` | `(-> Bytes Bytes Bytes)` |

  Argument order is key, nonce, counter, message where each applies;
  `aead-seal` takes key, nonce, aad, plaintext and returns the ciphertext with
  the 16-byte tag appended; `aead-open` takes the same shape and returns the
  closed sum `OpenR` (`op-ok` carrying the plaintext, `op-bad`). Every module
  is category A with an empty crossings row by derivation.

- **Non-goals**, each with a home in §6: randomness (N2), listen-side sockets
  (N3), handshake and framing (N4), secret custody and the constant-time
  judgment (N5 via E40), nonce assignment policy, and any extern to a C crypto
  library (the arc ruled it out).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no rows. N1 postdates the map snapshot, so the
  element is **BUILD**. The lane's order and scope live in
  `docs/arcs/native-protocol-arc.md`.
- **Baseline honesty:** the tree holds zero crypto. Nothing under `lib/crypto/`
  exists; all four target files are new. The one module with crypto in its
  vocabulary says so itself: `lib/capability/secret.chiral` opens with
  `No crypto here` and its seal is custody over already-plaintext bytes.
- **Live code this composes with. Named here; do not respec it:**

  | shard | what is built | where |
  |---|---|---|
  | integer externs | `+ - * / % =i <i <=i` and `band bor bxor shl shr sar` | `lib/prelude/prelude.chiral:58-71` |
  | bytes externs | `blen bget bslice bcat brepeat` | `lib/prelude/prelude.chiral:93-97` |
  | LE serialization | `pack-u32` / `unpack-u32` | `lib/prelude/prelude.chiral:98-99`, LE per `lib/lowering/compile-emit.chiral:29` and `lib/protocol/wire.chiral:3` |
  | guarded byte read | `at-byte` | `lib/text/matcher.chiral:310-315` |
  | result idiom | fallible `sock-*` carrying `*-err` constructors | E29, `docs/examples/E29-sockets.md` |
  | totality shapes | countdown to a constant bound; index under `blen` | `docs/definitions/totality.md` |

- **True delta:** four new `lib/crypto/` modules plus one new gate phase. Zero
  edits to any existing file except the one-line phase registration in
  `tools/test/run-tests.sh` (§4 step 1).

## 3. Decisions

Every open question from the example §6, dispositioned with its authority. A
silent resolution is the defect this section exists to prevent.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | `St` flat sixteen fields vs four `Q4` quarters | **RESOLVED**: flat | example §5 (reviewed); `dround` wants all sixteen names in one scope |
| 2 | `blen` guard at kernel entry | **RESOLVED**: precondition comment + guarded accessor | `docs/definitions/pattern-boundary-sums.md`; the `at-byte` precedent |
| 3 | BLAKE2s sigma encoding under decimal literals | **RESOLVED**: ten literal `(List I64)` defs + total nth | packed I64 overflows; data rows add plumbing for zero gain |
| 4 | Home of the LE u64 length helper | **RESOLVED**: `le-u64` in `crypto/poly1305` | single consumer; E155 spends a basename; say it once |

**Decision 1.** `St` is one closed product of sixteen `I64` fields; `Q4` stays
as `qround`'s return type only. The diagonal half of `dround` replumbs words
across all four columns, so the flat shape puts every word in scope for one
rebuild per double round. Four quarter products would force cross-quarter
rebuilds at every diagonal step and buy nothing arithmetically. The reviewed
example §5 already carries the flat shape; the implementation copies it.

**Decision 2.** Kernels state their length preconditions (key 32 bytes, nonce
12 bytes, X25519 inputs 32 bytes) in header comments, and every byte read goes
through a module-local guarded accessor in the `at-byte` shape:
`bget` behind an `<i` bound so a short buffer yields a deterministic value with
no trap. Refuse-by-result was considered and rejected here:
`docs/definitions/pattern-boundary-sums.md` reserves closed sums for genuine
which-of-N classifications, and its `at-byte` carve-out
(`lib/text/matcher.chiral:306-309`) covers exactly this byte-value case. E29's
`*-err` constructors classify OS outcomes at a crossing; these kernels have no
crossing and a short key is a caller contract violation with statically known
lengths. The one genuine classification in the suite is tag verification, and
`aead-open` returns the closed `OpenR` sum for it. Named cost, accepted: a
short key produces a wrong keystream with no signal beyond the header
contract; the gate's vector rows pin correct-length behavior.

**Decision 3.** The sigma schedule is ten defs `sig0` .. `sig9`, each a
literal `(List I64)` of sixteen decimal entries in 0..15, read through a total
nth in the `at-byte` shape (an out-of-range index yields 0, unreachable under
the fixed call pattern). Two alternatives die on inspection: packing a round
into one I64 needs sixteen 4-bit nibbles, and any entry of 8 or more in the
top nibble crosses `2^63`, so signed I64 refuses the encoding; ten
sixteen-field data rows would add a fresh type and a sixteen-way `case` per
lookup for zero arithmetic gain. Entries of 0..15 sit inside decimal literals
directly, so the decimal-only lexer rule (example §5) costs nothing here. The
list shape reuses `prelude/list` machinery as is.

**Decision 4.** `le-u64` (an `I64` to eight LE bytes, low `pack-u32` of
`(band n 4294967295)` then `pack-u32` of `(shr n 32)`) lives in
`crypto/poly1305`. Its single consumer is the RFC 8439 §2.8 lengths block,
built there in step 2; `crypto/chacha` serializes through `pack-u32` alone. A
shared sibling module would spend a unique basename (E155,
`docs/definitions/altitude-errors.md:104`) on a two-line def with one caller,
and defining the helper at its one consumer already satisfies the
regularity rule (`docs/definitions/design-principles.md`). A second consumer
promotes it to a shared home as that change's business (§6).

No NEEDS-AUTHOR rows. All four dispositions derive from reviewed or settled
documents cited above, so `status: draft` stands.

## 4. Change plan (ordered, commit-sized)

**Precondition, before step 1:** confirm the enforcement-arc session has
cleared `lib/` and `tools/test/`, or coordinate the work as new-file-only
additions plus one registration line. Every module file below is new; no step
edits an existing `lib/` file.

**Build rule note:** all four modules are category A library files outside the
compiler's closure, so the promote and byte-compare legs of
`docs/definitions/working-discipline.md` never fire. Each step's test leg is
its gate phase run.

### Step 1: ChaCha20 block and stream (slice 1)
- **Target:** `lib/crypto/chacha.chiral` (NEW); `tools/test/crypto.sh` (NEW,
  registered as a named phase in `tools/test/run-tests.sh`);
  `tools/test/samples/n01_chacha.prog` (NEW).
- **Change:** copy the example §5 skeleton and complete it.
  `(module crypto/chacha (cat A) (alt upper))`. Symbols: `M32` `add32`
  `rotl32`; `St` (sixteen `I64` fields, decision 1) and `Q4`;
  `qround (-> I64 I64 I64 I64 Q4)`; `dround (-> St St)` (eight `qround` calls,
  columns then diagonals); `rounds (-> St I64 St)` on the countdown shape;
  `C0`..`C3`; the guarded accessor of decision 2;
  `block-init (-> Bytes Bytes I64 St)` via `unpack-u32`;
  `chacha-block (-> Bytes Bytes I64 Bytes)` (init, ten double rounds, `add32`
  the init state back in, serialize sixteen `pack-u32` words);
  `chacha-xor (-> Bytes Bytes I64 Bytes Bytes)` walking the message in 64-byte
  blocks, one `bcat` per block, index under `(<i i (blen msg))`. The sample
  prints computed bytes in decimal; the gate compares them to the RFC 8439
  §2.3.2 keystream.
- **Verification:** `bash tools/test/crypto.sh` green on the §2.3.2 rows; the
  flipped-rotation mutant (§5) run red, then reverted.
- **Size:** M.

### Step 2: Poly1305 and the AEAD composition (slice 2)
- **Target:** `lib/crypto/poly1305.chiral` (NEW, imports `crypto/chacha`);
  `tools/test/samples/n01_aead.prog` (NEW); extend `tools/test/crypto.sh`.
- **Change:** the example §5 limb idiom, completed. Symbols: `F` as
  `(f5 l0..l4)` five 26-bit limbs, `M26`; `clamp-r (-> Bytes F)` per RFC 8439
  §2.5 at load; `f-mul (-> F F F)` with weight-5 folds and the
  `shr`/`band` carry chain (products under `2^53`, five-term sums under
  `21 * 2^53`); the final reduction and the mod `2^128` add of `s`;
  `poly1305-mac (-> Bytes Bytes Bytes)` over 16-byte chunks with the high pad
  bit; `le-u64` and `pad16` (decision 4); the one-time key as the first 32
  bytes of `chacha-block` at counter 0 (RFC 8439 §2.6);
  `aead-seal (-> Bytes Bytes Bytes Bytes Bytes)`;
  `(data OpenR () (op-ok (pt Bytes)) (op-bad))`;
  `aead-open (-> Bytes Bytes Bytes Bytes OpenR)`;
  `tag-eq (-> Bytes Bytes Bool)` folding `bxor` into `bor` across all sixteen
  bytes before one comparison.
- **Verification:** gate green on the §2.5.2 tag row and the §2.8.2 AEAD rows
  (seal bytes match; `aead-open` yields `op-ok` with the plaintext; one
  flipped ciphertext byte yields `op-bad`); the dropped-carry mutant run red,
  then reverted.
- **Size:** L.

### Step 3: BLAKE2s (slice 3)
- **Target:** `lib/crypto/blake2s.chiral` (NEW);
  `tools/test/samples/n01_blake2s.prog` (NEW); extend `tools/test/crypto.sh`.
- **Change:** `(module crypto/blake2s (cat A) (alt upper))`. Symbols: `rotr32`
  (swap `rotl32`'s shift directions under `M32`); `IV0`..`IV7` in decimal
  (`IV0` is `1779033703`; transcribe the eight words from RFC 7693 §2.6);
  the parameter xor `16842784` into `IV0` for the keyless 32-byte digest;
  `sig0`..`sig9` and the total nth per decision 3 (`sig0` is the identity
  `0..15`; transcribe rounds 1..9 from RFC 7693 §2.7); `g-mix`; `compress`
  with the two counter words held as `I64` fields; `blake2s-hash
  (-> Bytes Bytes)` walking 64-byte blocks on the proven index shape.
  Appendix B is the arbiter for every transcribed constant.
- **Verification:** gate green on the RFC 7693 appendix B row (`"abc"`
  digest); the swapped-sigma mutant run red, then reverted.
- **Size:** M.

### Step 4: X25519 (slice 4)
- **Target:** `lib/crypto/x25519.chiral` (NEW);
  `tools/test/samples/n01_x25519.prog` (NEW); extend `tools/test/crypto.sh`.
- **Change:** `(module crypto/x25519 (cat A) (alt upper))`. Symbols: `F10`
  (ten limbs alternating 26 and 25 bits), `M25` as `33554431`; `f10-add`;
  `f10-sub` biased by a multiple of the prime so limbs stay nonnegative;
  `f10-mul` and `f10-sqr` with weight-19 folds (products at or under `2^52`,
  accumulations under `2^62`); the `shr`/`band` carry chain; `f10-invert` as
  the straight-line square-and-multiply chain for the exponent `p - 2`;
  `decode-u (-> Bytes F10)` LE with the high-bit mask and `encode-u
  (-> F10 Bytes)` after full reduction; `clamp` via `band` byte 0 with 248,
  `band` byte 31 with 127, `bor` byte 31 with 64; `cswap` as mask arithmetic
  (`(- 0 bit)` then `bxor`/`band`); the Montgomery ladder counting 254 down
  to 0 on the countdown shape; `x25519 (-> Bytes Bytes Bytes)`.
- **Verification:** gate green on both RFC 7748 §5.2 scalar-mult rows and the
  §6.1 DH pair (both public keys from the base point 9, shared `K` equal from
  both sides); the weight-19 mutant run red, then reverted.
- **Size:** L.

## 5. Conformance gate

- **Golden behavior:** each kernel reproduces its published RFC vector
  byte-for-byte, and `aead-open` classifies a corrupted ciphertext as
  `op-bad`. The catalog row's rule binds: a kernel with a missing vector row
  is unproven and says so.
- **Gate file:** `tools/test/crypto.sh`, NEW, created in step 1 and extended
  by steps 2..4, wired into `tools/test/run-tests.sh` as a named phase in the
  suite's shape (`tools/test/pretty.sh` is the precedent). Nothing is built
  today; a passing claim needs a run at implement time.
- **Soundness:** a check aimed at a guess passes by looking at nothing. Every
  assertion compares bytes a compiled sample prints against RFC constants
  transcribed into the gate, and the mutant rows prove the assertions read
  the code.
- **Vector rows:**

  | kernel | row | source |
  |---|---|---|
  | ChaCha20 | 64 keystream bytes | RFC 8439 §2.3.2 |
  | Poly1305 | 16 tag bytes | RFC 8439 §2.5.2 |
  | AEAD | seal bytes; `op-ok` plaintext; `op-bad` on a flipped byte | RFC 8439 §2.8.2 |
  | BLAKE2s | 32 digest bytes for `"abc"` | RFC 7693 appendix B |
  | X25519 | two scalar-mult outputs | RFC 7748 §5.2 |
  | X25519 | DH pair: both publics and the shared `K` | RFC 7748 §6.1 |

- **Mutant rows, each RUN (red, then reverted):**

  | mutant | red row |
  |---|---|
  | `rotl32` count 16 changed to 17 in `qround` | §2.3.2 |
  | one weight-5 carry fold dropped in `f-mul` | §2.5.2 |
  | two entries swapped in `sig0` | appendix B |
  | fold weight 19 changed to 18 in `f10-mul` | §5.2 |

- **Green line:** the suite gains one phase. The assertion baseline is
  recorded at implement time from `tools/test/run-tests.sh`'s own print;
  this SPEC quotes no count it did not measure. The phase's wall clock is
  recorded and sets no bar, per the author's 2026-09-01 ruling
  (`docs/benchmarks/README.md:29`).
- **Done when:** all six vector rows green, all four mutant rows measured red
  and reverted, the phase registered, suite exit 0.

## 6. Residue & links

- **Deliberately unbuilt, each with its home:**

  | residue | home |
  |---|---|
  | randomness (`getrandom`) | N2, the entropy crossing |
  | listen-side AF_INET and UDP externs | N3 |
  | handshake, framing, the cookie suite | N4 (gated on N1, N2, N3) |
  | key custody: keys enter these kernels as plain `Bytes` | N5 via E40, `lib/capability/secret.chiral` |
  | constant-time as a checked claim | N5, the constant-time judgment |
  | refinement-typed rotation counts | example §5 knob; nobody's yet |
  | a shared home for `le-u64` | opens with a second consumer; nobody's yet |
  | arena reclamation for the kernels' linear allocation budget | the allocator work; example §6 names the budget |

- **Follow-on:** N4 consumes all four exports. The suggested next element is
  **N2**: the entropy crossing is the smallest remaining gate on N4 and
  touches nothing this SPEC builds.
- **Related:** [[N01-crypto-kernels]] · `docs/arcs/native-protocol-arc.md` ·
  E173 (slice precedent) · E29 (result idiom) · E155 (basename law) · E40 / N5
  (secret custody).
