---
element: N01
slug: crypto-kernels
title: "**Crypto kernels: an AEAD cipher, a hash, a key exchange, the WireGuard suite as reference class**"
kind: LAYER-K
reference_class: EXTERNAL
# ours_source is TRANSITIONAL: the zero-Python route deletes every .py in
# this tree, so this field's referent is going away. Keep the field. It
# records what the example was written against, and a chirality baseline
# (lib/<name>.chiral, prog/<name>.prog) or `(none)` is equally legal.
ours_source: (none)
status: drafted
updated: 2026-09-03
---

# N01 · **Crypto kernels: an AEAD cipher, a hash, a key exchange, the WireGuard suite as reference class**

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** N01, the pure crypto kernels the native protocol arc stands on:
  an AEAD cipher (ChaCha20 + Poly1305, RFC 8439), a hash (BLAKE2s, RFC 7693),
  a key exchange (X25519, RFC 7748). WireGuard runs on exactly this suite,
  which is why it is the reference class.
- **Kind:** LAYER-K. Pure category A throughout: keystream, tag, digest and
  shared secret are all functions of their inputs. Randomness, key storage and
  transport stay outside these modules.
- **Why chirality needs its own:** the arc exists to retire borrowed crypto.
  An extern to a C library was ruled out by the arc; the protocol layers above
  (handshake, transport framing) consume these kernels as typed chirality
  values.
- **One element, four implementation slices** (the E173 precedent: the matcher
  shipped slice 1 without captures, `lib/text/matcher.chiral:8`):
  - **slice 1** ChaCha20 block function + stream encrypt;
  - **slice 2** Poly1305 and the AEAD composition (seal / open);
  - **slice 3** BLAKE2s;
  - **slice 4** X25519.
- **The working constraint, restated from the arc:** zero compiler changes.
  The surface integer type is signed `I64`; the available integer externs are
  `+ - * / % =i <i <=i` and `band bor bxor shl shr sar`
  (`lib/prelude/prelude.chiral:59-72`; `shr` is logical zero-fill, `sar`
  arithmetic sign-fill). There is no `mulhi` surface binding and none may be
  added. Every product the kernels form must therefore fit signed 63 bits,
  which forces small-limb field arithmetic.

## 2. Research

- **Reference class:** EXTERNAL, SPEC + IMPL. SPEC: RFC 8439 (ChaCha20 and
  Poly1305 for IETF Protocols), RFC 7693 (BLAKE2), RFC 7748 (Elliptic Curves
  for Security). IMPL: the WireGuard kernel suite and the donna family
  (poly1305-donna 32-bit path, curve25519-donna c32), which are the standard
  no-wide-multiply reference implementations.
- **Key findings:**
  1. **The whole suite fits under the no-`mulhi` ceiling.** ChaCha20 and
     BLAKE2s are add / xor / rotate machines on 32-bit words. Poly1305-donna's
     32-bit path holds the accumulator in five 26-bit limbs; the block add
     lifts an h limb toward 2^27, so each product stays under `2^53` and the
     worst five-term accumulation with its weight-5 folds stays under
     `21 * 2^53 < 2^58`; curve25519-donna c32 holds field elements in ten limbs
     alternating 26 and 25 bits, worst accumulation under `19 * 2^52 * 10 <
     2^62`. Both profiles fit signed I64 with headroom (checked 2026-09-03,
     `python3`, this pre-run).
  2. **Everything serializes little-endian**: ChaCha20 state words, BLAKE2s
     words, the Poly1305 tag, X25519 scalars and coordinates. The tree already
     owns an LE u32 pair: `pack-u32` / `unpack-u32`
     (`lib/prelude/prelude.chiral:101-102`), documented LE where the ELF emitter
     uses them (`lib/lowering/compile-emit.chiral:29`) and where the wire
     protocol does (`lib/protocol/wire.chiral:3`).
  3. **Reduction is multiply-by-a-small-constant; division never appears.** Poly1305
     works mod `2^130 - 5`: limbs above the top fold back at weight 5. X25519
     works mod `2^255 - 19`: they fold back at weight 19. Carry chains are
     `shr` / `band` because limb widths are bit counts; all limb values stay
     nonnegative by construction, so logical `shr` is the right shift
     everywhere and `sar` goes unused.
  4. **Published vectors exist for every kernel.** RFC 8439 §2.3.2 (block
     function), §2.5.2 (tag), §2.8.2 (full AEAD); RFC 7693 appendix B
     (BLAKE2s of `"abc"`); RFC 7748 §5.2 (two scalar-mult vectors) and §6.1
     (the Diffie-Hellman pair). The catalog row's rule binds: a kernel with a
     missing vector row is unproven and says so.

## 3. Conventional (other-language) approach

C, the donna / WireGuard shape. The quarter round mutates a `uint32_t` state
array in place; the field multiply relies on `uint64_t` (or wider) products.

```c
#define QR(a, b, c, d)                              \
  a += b; d ^= a; d = (d << 16) | (d >> 16);        \
  c += d; b ^= c; b = (b << 12) | (b >> 20);        \
  a += b; d ^= a; d = (d <<  8) | (d >> 24);        \
  c += d; b ^= c; b = (b <<  7) | (b >> 25);

/* poly1305-donna 32-bit path: 64-bit accumulators over 26-bit limbs */
uint64_t d0 = (uint64_t)h0*r0 + (uint64_t)h1*(5*r4) + (uint64_t)h2*(5*r3)
            + (uint64_t)h3*(5*r2) + (uint64_t)h4*(5*r1);
h0 = (uint32_t)d0 & 0x3ffffff;  c = (uint32_t)(d0 >> 26);
```

- **Assumptions it bakes in:** unsigned machine words of exact width, with
  wraparound as the ambient semantics; in-place mutation of caller-owned
  buffers; a widening multiply the type system hands over for free; `memcpy`
  and ambient allocation; constant-time behavior held by convention and code
  review; partiality at every edge (a short key is a buffer overread, an
  unauthenticated ciphertext raises or returns `-1` by local custom).

## 4. The chirality idea

- **Chirality features in play:** the `->` membrane (all four kernels are
  pure, category A, empty effect row by derivation); closed result sums at the
  AEAD boundary; totality via the numeric measure; fixed-shape `data` for
  cipher and field state; the I64 floor with masked 32-bit lanes.
- **The reframing.** Word width stops being a machine fact and becomes a
  module discipline: a 32-bit lane is an I64 that every add masks with
  `band` against `4294967295`, and `rotl` is two shifts and a `bor` under the
  same mask. A field element stops being a byte buffer and becomes a closed
  product of limb fields; a carry is a `shr` and a `band`. With `mulhi` off
  the table the limb split is the design itself: 26-bit limbs for Poly1305,
  the 25.5-bit alternation for X25519, chosen so the worst accumulation stays
  under `2^62`. Authentication failure is a value: `open` returns a closed
  sum and the caller cases on it totally, which is the standing boundary-sum
  directive applied to the one place crypto classifies anything.
- **What chirality makes impossible here:** mutating the message buffer in
  place (Bytes ops are pure; the ciphertext is a new value); an exception path
  on tag mismatch (the sum is the only exit); a kernel that secretly reads an
  RNG or the clock (that would put a crossing in the row and the `->`
  signature refuses it); an unhandled classification downstream of `open`
  (case coverage is checked). The checker also refuses any recursion it
  cannot see descend, which turns "the round loop terminates" from a comment
  into a classified fact.
- **Totality, said precisely** (`docs/definitions/totality.md` is the
  authority): the round loops recurse on a decreasing counter with a strict
  guard, the shape the numeric measure proves (unit step toward a constant
  bound, guard re-checked each iteration, wraparound excluded). Byte walks
  climb an index against `blen` with step `+1` under strict `<i`, the
  symbolic-bound shape it also proves. Every loop in the four kernels is
  designed to one of those two shapes; the classifier's verdict is measured
  at implement time and the SPEC records it rather than assuming it.

## 5. Chirality example (fleshed)

Slice 1 is what an implementation run copies first: the ChaCha20 module
skeleton, plus the Poly1305 limb shape that fixes the arithmetic idiom for
slices 2 and 4.

```chirality
; lib/crypto/chacha.chiral — ChaCha20 block + stream encrypt (RFC 8439), slice 1.
(import "prelude/prelude")
(import "prelude/list")

; Pure, category A, checked form. Binds no extern beyond prelude i64/bytes
; ops, so this module's crossings row is empty by derivation.
(module crypto/chacha (cat A) (alt upper))

; ─── 32-bit lanes inside signed I64 ─────────────────────────────────────────
(def M32 I64 4294967295)          ; 2^32 - 1 in decimal (hex literals do not lex)

(def add32 (-> I64 I64 I64) (lam (a b) (band (+ a b) M32)))

(def rotl32 (-> I64 I64 I64)
  (lam (x n) (band (bor (shl x n) (shr x (- 32 n))) M32)))
; shr is the logical zero-fill shift (prelude.chiral:70); lanes stay
; nonnegative, so sar is never wanted here.

; ─── state: sixteen words as one fixed shape ────────────────────────────────
; A closed product keeps the round loop off the arena's Bytes path: rounds
; allocate cells, never buffers.
(data St () (st (s0 I64) (s1 I64) (s2 I64) (s3 I64)
                ; … s4..s15, sixteen I64 fields total
                (s15 I64)))

; a quarter round returns its four words as a closed product
(data Q4 () (q4 (qa I64) (qb I64) (qc I64) (qd I64)))

(def qround (-> I64 I64 I64 I64 Q4)
  (lam (a b c d)
    (let ((a1 (add32 a b)) (d1 (rotl32 (bxor d a1) 16))
          (c1 (add32 c d1)) (b1 (rotl32 (bxor b c1) 12))
          (a2 (add32 a1 b1)) (d2 (rotl32 (bxor d1 a2) 8))
          (c2 (add32 c1 d2)) (b2 (rotl32 (bxor b1 c2) 7)))
      (q4 a2 b2 c2 d2))))

; one double round: four column qrounds then four diagonals, replumbed by case
(declare dround (-> St St))
; (def dround (lam (s) (case s ((st s0 s1 … s15) ; …
;   eight qround calls, one nested case per Q4 result, rebuild (st …)

; ten double rounds on a decreasing counter. Strict guard + unit step toward
; the constant bound 0: the numeric measure proves this total.
(def rounds (-> St I64 St)
  (lam (s n)
    (case (<i 0 n)
      (true  (rounds (dround s) (- n 1)))
      (false s))))

; ─── constants and block assembly ───────────────────────────────────────────
(def C0 I64 1634760805)   ; "expa"
(def C1 I64 857760878)    ; "nd 3"
(def C2 I64 2036477234)   ; "2-by"
(def C3 I64 1797285236)   ; "te k"

; init: 4 constants, 8 key words, 1 counter, 3 nonce words, all LE.
; unpack-u32 (prelude.chiral:99) reads the little-endian u32 at a byte offset.
(declare block-init (-> Bytes Bytes I64 St))       ; key(32B) nonce(12B) ctr

; block: init, 10 double rounds, add32 each word of the init state back in,
; serialize the sixteen words with pack-u32 + bcat (one 64-byte Bytes out).
(declare chacha-block (-> Bytes Bytes I64 Bytes))

; encrypt = xor with the keystream. Walks the message in 64-byte blocks;
; each block xors byte-by-byte via bget/bxor into one Bytes, appended with a
; single bcat per block. The index climbs under (<i i (blen msg)): the
; symbolic-bound shape the numeric measure proves.
(declare chacha-xor (-> Bytes Bytes I64 Bytes Bytes)) ; key nonce ctr msg
```

```chirality
; lib/crypto/poly1305.chiral — the limb idiom for slices 2 and 4.
; Five 26-bit limbs, the donna shape. r is clamped per RFC 8439 §2.5 at load.
(data F () (f5 (l0 I64) (l1 I64) (l2 I64) (l3 I64) (l4 I64)))

(def M26 I64 67108863)            ; 2^26 - 1

; h * r mod 2^130 - 5. Limbs above the top fold back at weight 5. The block
; add lifts an h limb toward 2^27, so each product stays under 2^53 and each
; five-term sum with its weight-5 folds under 21 * 2^53 < 2^58: signed I64
; holds it without a mulhi.
(def f-mul (-> F F F)
  (lam (h r)
    (case h ((f5 h0 h1 h2 h3 h4)
      (case r ((f5 r0 r1 r2 r3 r4)
        (let ((t0 (+ (* h0 r0)
                     (+ (* 5 (* h1 r4)) (+ (* 5 (* h2 r3))
                     (+ (* 5 (* h3 r2)) (* 5 (* h4 r1)))))))
              ; … t1..t4 by the same rotation, then the carry chain:
              ;   (c0 (shr t0 26)) (u0 (band t0 M26)) … c4 folds into u0 at *5
              )
          (f5 u0 u1 u2 u3 u4))))))))

; AEAD open returns a closed sum. Tag mismatch is a value; the caller cases.
(data OpenR () (op-ok (pt Bytes)) (op-bad))
```

- **Knobs to modify:**
  - **X25519 (slice 4)** reuses the `F` idiom widened to ten limbs alternating
    26 and 25 bits (`M26` / `33554431` masks): products stay at or under
    `2^52`, the mod `2^255 - 19` wrap folds at weight 19, and the worst
    accumulation is under `2^62`. Scalar clamp in decimal: `band` byte 0 with
    248, `band` byte 31 with 127, `bor` byte 31 with 64. The Montgomery ladder
    counts 254 down to 0 (the proven countdown shape); the conditional swap is
    mask arithmetic (`(- 0 bit)` then `bxor`/`band`); inversion is the fixed
    square-and-multiply chain for `p - 2`, straight-line.
  - **BLAKE2s (slice 3)** reuses `add32`/`M32` with rotr (swap the shift
    directions), the eight-word IV starting `1779033703`, the parameter-block
    xor `16842784` for a keyless 32-byte digest, and a literal sigma schedule.
  - Rotation counts could take a refinement (`(refine I64 (> 0) (< 32))`) if
    the spec wants the shift domain typed.
- **Deliberately omitted:** the full sixteen-field `st` spelling and the
  `dround` plumbing (mechanical); the BLAKE2s compression function and sigma
  table (slice 3's spec); the X25519 field module in full (slice 4's spec);
  every handshake or transport concern above the kernels.

## 6. Use / modify notes

- **Lands in:** a new directory, four new files with unique basenames
  (two modules under one basename is a hard error, E155):
  `lib/crypto/chacha.chiral`, `lib/crypto/poly1305.chiral`,
  `lib/crypto/blake2s.chiral`, `lib/crypto/x25519.chiral`. Nothing edits an
  existing `lib/` file.
- **Conformance target:** the published vectors as gate assertions, RFC 8439
  §2.3.2 / §2.5.2 / §2.8.2, RFC 7693 appendix B, RFC 7748 §5.2 and §6.1. The
  gate is a planned phase in `tools/test/` (a `crypto.sh` in the suite's
  shape) that the implement stage owes. It stays unbuilt today; a passing
  claim needs a run.
- **Honest limits:**
  - **Allocation.** The arena never reclaims (a `records/author-calls.md` row
    measures ~1,747 B per input byte on the compile path). The design spends
    its budget deliberately: round-loop state lives in fixed-shape `data`
    (cells, small and bounded per round) and the only Bytes growth is one
    64-byte block plus one `bcat` per block of message, linear in message
    length. A per-byte `bcat` in an inner loop would square that and is the
    named anti-pattern.
  - **Timing.** Chirality has no timing model, so constant-time is out of
    reach as a typed claim. The design still avoids branching on secret bytes
    where the idiom is free (mask-arithmetic cswap, a tag compare that folds
    `bxor`/`bor` over all sixteen bytes before one comparison), and the claim
    stops there.
  - **Secret custody.** Key material enters these kernels as plain `Bytes`.
    The custody seam (`Secret`, E40, `lib/capability/secret.chiral`) is N5's
    business; these modules stay agnostic about where keys live.
- **Open questions** (for the SPEC to settle):
  - `St` as one sixteen-field product versus four `Q4` quarters; the flat
    shape is assumed above because `dround`'s diagonal replumbing wants all
    sixteen names in scope at once.
  - Whether `unpack-u32` needs a `blen` guard at kernel entry; the guarded
    accessor precedent is `lib/text/matcher.chiral:313`.
  - The sigma-schedule encoding for BLAKE2s (a literal `List I64` per round
    versus ten fixed data rows).
  - Where the AEAD length-encoding helper (LE u64 as two `pack-u32` halves)
    lives, `chacha.chiral` or a shared `lib/crypto/` sibling.
- **Related:** [[N01-crypto-kernels]] · the N lane arc
  (`docs/arcs/native-protocol-arc.md`) · E173 (slice precedent) · E40 / N5
  (secret custody) · E155 (module-key collision).
