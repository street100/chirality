---
element: N07
slug: shamir-gf256
title: "**Shamir over GF(256): split, reconstruct, quorum agreement, corrupted-share detection**"
kind: LAYER-K
reference_class: EXTERNAL
ours_source: (none)
status: drafted
updated: 2026-09-03
---

# N07. Shamir over GF(256): split, reconstruct, quorum agreement, corrupted-share detection

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** N07, Shamir secret sharing over the AES field: split a secret
  t of n, reconstruct by quorum, and surface a share set that fails to agree
  as a named outcome instead of a wrong answer.
- **Kind:** LAYER-K. A pure kernel beside the ChaCha20 and Poly1305 slices,
  serving [[decision-quorum-store]]: nothing authoritative sits whole in one
  place, and reconstruction from two share subsets that disagrees is a named
  observable (goal requirement 4, the Store line of [[goals/native-stack]]).
- **Why chirality needs its own:** the goal's requirement 1 bars foreign crypto
  from the path, and the codebase settles neither of this element's two real
  shape choices: the GF(256) representation, and which helpers move to the N6
  shared primitives module. Both are exactly the unsettled-shape condition the
  build rule names, so the pipeline runs with N6 dispositioned inside N7 (the
  arc's re-ruled order, 2026-09-03).

## 2. Research

- **Reference class:** EXTERNAL (PAPER + SPEC + IMPL). PAPER: Shamir, "How to
  Share a Secret", CACM 22(11), 1979. SPEC: FIPS-197 §4.2, the GF(2^8)
  arithmetic under the polynomial 0x11b (283 decimal); SLIP-0039 as a
  published GF(256) share format over the same field. IMPL: codahale/sss
  (Go), as carried into HashiCorp Vault's `shamir` package.
- **Key findings:**
  1. The scheme is byte-wise: one degree t-1 polynomial per secret byte, the
     secret byte at f(0), every polynomial evaluated at one nonzero x per
     share. A share is the point x plus a y string the secret's length, and
     reconstruction interpolates each byte position independently from t
     points.
  2. Characteristic 2 deletes the sign bookkeeping. Addition and subtraction
     are both `bxor`, so Lagrange at zero collapses to an xor fold of field
     products and the whole kernel is integer-free past the byte lanes.
  3. Field multiplication has two production shapes: 512-entry log/exp
     tables with a mod-255 on the exponent sum, and the peasant loop (eight
     double-and-reduce steps against 283, gathering the addend on each set
     multiplier bit). The AES literature pins anchors for either: 87 * 131 =
     193 is FIPS-197 §4.2's worked product, and 83 * 202 = 1 is the S-box
     inverse pair.
  4. Plain Shamir authenticates nothing. Any t well-formed shares interpolate
     to some value, and Vault's package documents that a wrong reconstruction
     returns no error. Detection at this layer takes k > t shares held to
     mutual consistency; naming WHICH share lied takes verifiable secret
     sharing (Feldman 1987), which [[decision-quorum-store]] rules residue.

## 3. Conventional (other-language) approach

Go, the codahale/sss shape as carried into HashiCorp Vault's `shamir` package.

```go
// 512 table entries, package globals initialized at load
var logTable = [256]uint8{0x00, 0xff, 0x19 /* 253 more */}
var expTable = [256]uint8{0x01, 0x03, 0x05 /* 253 more */}

func mult(a, b uint8) uint8 {
        if a == 0 || b == 0 {
                return 0
        }
        return expTable[(int(logTable[a])+int(logTable[b]))%255]
}

func Split(secret []byte, parts, threshold int) (map[byte][]byte, error) {
        // coefficients drawn AMBIENTLY from crypto/rand inside the call
}

func Combine(shares map[byte][]byte) ([]byte, error) {
        // Lagrange at zero. Any threshold well-formed shares return
        // (value, nil): a corrupted share yields a wrong secret, no error.
}
```

- **Assumptions it bakes in:**
  - 512 magic table entries live as ambient package state. One mistranscribed
    entry is silent on most inputs and wrong forever on the rest.
  - Every `mult` indexes memory by secret data. The cache channel exists
    outside anything the type system sees.
  - `Split` reaches `crypto/rand` ambiently; the effect is invisible in the
    signature, so the function is untestable without stubbing the planet.
  - `Combine` is total over garbage. Share subsets that reconstruct
    differently have no representation, so the caller cannot learn that its
    quorum disagreed.
  - `map[byte][]byte` deduplicates x silently: a colliding share overwrites
    its sibling upstream of any arithmetic.

## 4. The chirality idea

- **Chirality features in play:** purity as a typed fact (`->` with an empty
  row); boundary sums (`docs/pattern-boundary-sums.md`); totality by fixed
  8-step counters and structural recursion; the I64 floor with decimal
  literals; category A beside the landed kernels.
- **The reframing.** Coefficients become an argument, so split and join are
  functions of their inputs and every gate row is deterministic today. Live
  randomness is N2's crossing and arrives later: the caller will draw
  coefficient bytes through the entropy port and pass them in, and the kernel
  keeps `->`. Disagreement becomes a constructor: `AgreeR` names the share
  set that fails quorum, which is the observable [[decision-quorum-store]]
  seeds the split store on. Duplicate x becomes a refusal value instead of a
  silent map overwrite.
- **The field representation, compared.** Both real shapes were weighed under
  the working constraint (signed I64, `band`/`bor`/`bxor`/`shl`/`shr`,
  `bget`, decimal literals only, zero compiler changes):

  | shape | what it costs here |
  |---|---|
  | log/exp tables | Two 256-byte tables. With decimal-only literals each is spelled as 64 `pack-u32` words: 128 opaque constants, and one mistranscribed word is silent on most inputs. Every lookup is a secret-indexed `bget`, a cache channel stacked on top of the branch channel N5 will judge. Generating the tables at startup instead trades the constants for a 256-step builder plus a sharing question (whether a computed top-level `def` evaluates once) that sits behind the compiler wall this arc rules off. |
  | peasant loop | One constant, 283, and the anchor vectors pin it. Eight fixed steps per product on a decreasing counter, the exact proof shape `rounds` and `pl-loop` already carry. Secret-dependent branches remain and are N5 inventory, the `f-final` precedent. The cost is arithmetic: eight iterations per product, t^2 products per byte in join. Wall clock sets no bar (the 2026-09-01 ruling, docs/benchmarks/README.md:29). |

  **The peasant loop wins.** It is table-free under a literal syntax that
  makes tables hostile, it reuses a landed totality shape, and it keeps the
  side-channel inventory to the branch class the tree already names.
- **What chirality makes impossible here:** an ambient `rand` inside split
  (a crossing needs its capability parameter, and the `->` signature refuses
  the row); a garbage reconstruction consumed as if clean (`ag-off` is a
  constructor, and exhaustive `case` makes ignoring it untypeable); a
  duplicate or out-of-range x reaching the field arithmetic (the point scan
  refuses both as values before any `gf-inv` runs, so `inv 0` is unreachable
  from this call graph, and an x = 0 "share", whose y string Lagrange at zero
  would hand back verbatim as the secret, is refused before interpolation).

## 5. Chirality example (fleshed)

```chirality
; ─── the field ops: land in lib/crypto/prim.chiral (N6) ─────────────────────
(import "prelude/prelude")

; Pure, category A. Prelude i64/bytes ops only, so the crossings row is
; empty by derivation (the chacha/poly1305 header idiom).
(module crypto/prim (cat A) (alt upper))

; the guarded byte read: ONE home for what chacha spells cc-at and poly1305
; spells pl-at (the at-byte shape, lib/text/matcher.chiral:310)
(def pm-at (-> Bytes I64 I64)
  (lam (bs i)
    (cond ((<i i 0) 0)
          ((<i i (blen bs)) (bget bs i))
          (else 0))))

; one byte as a Bytes of length 1 (the e151 idiom, third spelling retired)
(def pm-b1 (-> I64 Bytes) (lam (b) (bslice (pack-u32 b) 0 1)))
(def pm-empty Bytes (bslice (pack-u32 0) 0 0))

; word ops and LE codecs migrate here from the landed kernels:
; M32, add32, rotl32, pm-zeros, le-u64 ; …

; ─── GF(256), the AES field ─────────────────────────────────────────────────
; reduction polynomial x^8 + x^4 + x^3 + x + 1 = 283 decimal (hex does not
; lex). Addition is bxor; characteristic 2 makes it subtraction too.
(def R283 I64 283)

(def gf-add (-> I64 I64 I64) (lam (a b) (bxor a b)))

; the peasant product: eight fixed steps on a decreasing counter, the rounds
; proof shape. acc gathers a on each set low bit of b; a doubles per step
; and reduces by R283 the moment it leaves 0..255, so every lane stays a
; byte. No table: zero transcribed constants, zero secret-indexed bget. The
; secret-dependent branches remain and are N5's workload (f-final precedent).
(def gf-mul-go (-> I64 I64 I64 I64 I64)
  (lam (a b acc n)
    (case (<i 0 n)
      (true
        (let ((acc1 (case (=i 1 (band b 1)) (true (bxor acc a)) (false acc)))
              (a2 (shl a 1))
              (a3 (case (<i 255 a2) (true (bxor a2 R283)) (false a2))))
          (gf-mul-go a3 (shr b 1) acc1 (- n 1))))
      (false acc))))

(def gf-mul (-> I64 I64 I64) (lam (a b) (gf-mul-go a b 0 8)))

; inverse by Fermat: the multiplicative group has order 255, so a^-1 = a^254.
; gf-pow 0 254 is 0; every caller below refuses the x-collision that could
; ask for inv 0 BEFORE an inverse is taken.
(declare gf-pow (-> I64 I64 I64))  ; 8-step square-and-multiply, gf-mul-go's twin ; …
(def gf-inv (-> I64 I64) (lam (a) (gf-pow a 254)))

; ─── the kernel: lands in lib/crypto/shamir.chiral (N7) ─────────────────────
(import "prelude/prelude")
(import "crypto/prim")

; Pure, category A. Coefficients arrive as an ARGUMENT, so split is a
; function of its inputs and the crossings row is empty by derivation.
; Entropy is N2's crossing: when it lands, the CALLER draws coefficient
; bytes through the entropy port and passes them here. The kernel keeps ->.
(module crypto/shamir (cat A) (alt upper))

; one share: the evaluation point x in 1..255, one y byte per secret byte
(data Share () (share (px I64) (py Bytes)))

; join outcomes as a closed sum (the OpenR idiom): every caller cases, totally
(data JoinR ()
  (j-ok    (jsec Bytes))             ; the interpolated secret
  (j-short (jhave I64) (jneed I64))  ; fewer than t shares offered
  (j-dupx  (jdx I64))                ; two shares carry one x: refused as a value
  (j-badx  (jbx I64)))               ; an x outside 1..255: refused as a value

; the point scan answers a which-of-three, so it is a sum. px-bad covers
; x = 0: split never emits it, f(0) IS the secret, and a "share" there would
; hand join its y string verbatim (Lagrange at zero returns that point's y)
(data PxR () (px-clean) (px-dup (pdx I64)) (px-bad (pbx I64)))

; agreement outcomes: disagreement is the NAMED observable the quorum store
; seeds on (decision-quorum-store). ag-off carries the witness x and the
; first byte position where that share leaves the curve through the base
; subset. WHICH share lied is undecidable in plain Shamir; blame is VSS
; residue (UNASSIGNED row).
(data AgreeR ()
  (ag-ok    (asec Bytes))
  (ag-off   (ox I64) (opos I64))
  (ag-short (ahave I64) (aneed I64))
  (ag-dupx  (adx I64))
  (ag-badx  (abx I64)))

; ─── split ──────────────────────────────────────────────────────────────────
; coefs carries (t - 1) injected bytes per secret byte, degree-major per
; position: the degree-d coefficient for byte i sits at i*(t-1) + (d-1),
; read through pm-at. Per byte position, Horner at x:
;   f(x) = s_i xor x*(a_1 xor x*(a_2 xor …))
(declare sh-eval1    (-> Bytes Bytes I64 I64 I64 I64))  ; one position at one x
(declare sh-ys       (-> Bytes Bytes I64 I64 Bytes))    ; every position at one x ; …
(declare sh-split-go (-> Bytes I64 I64 Bytes I64 (List Share) (List Share)))

; shares at x = 1..n; x = 0 is unused by construction, f(0) IS the secret
(def sh-split (-> Bytes I64 I64 Bytes (List Share))
  (lam (secret t n coefs)
    (sh-split-go secret t n coefs 1 (nil))))

; ─── join: Lagrange at zero ─────────────────────────────────────────────────
; characteristic 2 folds every sign away: the secret byte at position p is
; the xor over the t shares i of
;   (py_i at p) * w_i,  w_i = product over the other shares j of
;                             px_j * inv(px_j xor px_i)
; The point scan runs FIRST, so the inv argument is nonzero on this call
; graph with no refinement obligation spent.
(declare sh-len   (-> (List Share) I64))
(declare sh-take  (-> I64 (List Share) (List Share)))
(declare sh-px    (-> (List Share) PxR))             ; pairwise px scan
                                                     ; + 1..255 range ; …
(declare sh-w     (-> I64 (List Share) I64))         ; one basis weight w_i
(declare sh-bytes (-> (List Share) I64 Bytes Bytes)) ; positions climb under
                                                     ; (<i p len); one pm-b1
                                                     ; bcat per byte ; …

(def sh-join (-> I64 (List Share) JoinR)
  (lam (t shares)
    (case (<i (sh-len shares) t)
      (true (j-short (sh-len shares) t))
      (false
        (case (sh-px (sh-take t shares))
          ((px-dup x) (j-dupx x))
          ((px-bad x) (j-badx x))
          (px-clean (j-ok (sh-bytes (sh-take t shares) 0 pm-empty))))))))

; ─── agreement: the quorum seed ─────────────────────────────────────────────
; join the base subset (the first t), then hold EVERY offered share against
; the curve through the base by evaluating that interpolation at its x. Two
; distinct degree t-1 curves agree on at most t-1 points, and with all k
; offered x distinct the t-1 clean base points spend that whole budget, so
; one corrupted share among k >= t+1 surfaces wherever it sits: inside the
; base (every clean extra goes off the bent curve) or outside it (the
; corrupt share goes off the true curve). The scan here therefore covers
; ALL k offered shares; a scan of the taken t alone leaves a hole, because
; a clean extra that repeats a clean base x sits ON the bent curve and a
; corruption elsewhere in the base goes unseen (checked numerically
; 2026-09-03: t = 3, base share 2 flipped, extra repeating base x = 1,
; zero off-curve shares). This IS two-subset disagreement: the base and
; base-minus-one-plus-witness reconstruct differently, and ag-off is that
; pair compressed to its witness.
(declare sh-at    (-> (List Share) I64 I64 I64))  ; base curve at x, position p
(declare sh-check (-> Bytes (List Share) (List Share) AgreeR))  ; walk all k ; …

(def sh-agree (-> I64 (List Share) AgreeR)
  (lam (t shares)
    (case (sh-px shares)
      ((px-dup x) (ag-dupx x))
      ((px-bad x) (ag-badx x))
      (px-clean
        (case (sh-join t shares)
          ((j-ok sec)    (sh-check sec (sh-take t shares) shares))
          ((j-short h n) (ag-short h n))
          ((j-dupx x)    (ag-dupx x))     ; unreachable: all k just scanned
          ((j-badx x)    (ag-badx x))))))) ; unreachable, mapped for coverage
```

- **Knobs to modify:** refinements on the point and the threshold
  (`(refine I64 (>= 1) (< 256))` on `px`, `(refine I64 (>= 2))` on `t`);
  refined `data` fields are live prior art (`lib/runtime/proc.chiral:41`,
  `ExitStatus`), and a refined `px` is fed by a guard or a checked cast at
  the construction site, since arithmetic results never carry a range
  (measured 2026-09-03 by probe against `bin/chirality check`; the gf lanes
  below stay bare I64 with their byte bound argued in comments and pinned by
  G7). Also: the `ag-off` payload, widened to carry both candidate
  reconstructions when N8's return track wants them on the wire; the
  coefficient layout, flipped to position-major if N8's share record reads
  better that way; the base subset, rotated per retrieval if the store wants
  it. (The all-k point scan was a knob here when drafted; the 2026-09-03
  EXAMPLE audit moved it into the spine, because the agreement claim is
  false without it.)
- **Deliberately omitted:** verifiable secret sharing (Feldman commitments):
  residue by [[decision-quorum-store]], row `UNASSIGNED`. Secret custody
  around the reconstructed value (E40): N8's seam. Share serialization,
  distribution and the return track: N8. The constant-time claim: N5 judges
  it; this file's branches are inventory for that row. Live entropy: N2.

## 6. Use / modify notes

- **Lands in:** `lib/crypto/shamir.chiral` (the kernel) with the field ops in
  `lib/crypto/prim.chiral`, the N6 shared primitives module. A standalone
  `lib/crypto/gf256.chiral` was considered and argued down:
  [[decision-quorum-store]] rules that one shared module carries the word
  ops, the LE codecs and the field arithmetic, and a second home for field
  arithmetic would reopen the drift the decision closes. Basenames are
  unique per E155 (grepped 2026-09-03: zero hits for `shamir.*`, `prim.*`,
  `gf256.*` under `lib/` and `prog/`).
- **The N6 disposition** (dispositioned here per the arc's re-ruled order):

  | helper | today | disposition |
  |---|---|---|
  | `cc-at`, `pl-at` | duplicated across both kernels | migrate as one `pm-at`; a third copy in shamir would realize the drift again |
  | `cc-b1`, `pl-b1` | duplicated (`na-b1` a third time in the gate fixture) | migrate as `pm-b1` |
  | `cc-empty`, `pl-empty` | duplicated | migrate as `pm-empty` |
  | `pl-zeros` | poly1305 | migrate as `pm-zeros`; `pad16` keeps calling it |
  | `M32`, `add32`, `rotl32` | chacha; poly1305 imports chacha for `M32` | migrate: a cross-kernel import for one constant is the drift the decision names |
  | `le-u64` | poly1305, per its SPEC decision 4 (single consumer) | migrate: the decision names LE codecs as the module's cargo and N8's share record is the second consumer |
  | `gf-add`, `gf-mul`, `gf-pow`, `gf-inv`, `R283` | new | born in prim; shared field arithmetic is the module's third named cargo |
  | `St`, `Q4`, `qround` through `st-bytes`, `C0..C3`, `cx-*` | chacha | stay: the cipher itself, one consumer. The `St` homonym against `lib/lowering/upper/lower.chiral` (arc residue 2026-09-03) gets its rename when the migration touch opens the file; the homonym is the standing proof that one shared home matters |
  | `F`, `M26`, `f-*`, `pl-loop`, `pad16`, `pl-mac-data`, `pl-otk`, `aead-*`, `tag-eq` | poly1305 | stay: the 2^130-5 limb arithmetic is that kernel's own bound argument, and prim's field arithmetic means the shared GF(256). `tag-eq` keeps its single consumer and its 16-byte shape |

- **Conformance target:** new rows in `tools/test/crypto.sh`, emitted-bytes
  idiom, named as planned; the build lands with the SPEC's slice, and the
  `run_phase` registration stays owed to the suite session (phases 21..23
  free at that script's writing).

  | row | pins |
  |---|---|
  | G7 | field anchors: `gf-mul 87 131` is 193 (FIPS-197 §4.2), `gf-mul 83 202` is 1 and `gf-inv 83` is 202 (the inverse pair) |
  | G8 | round-trip: (t, n) in {(2, 3), (3, 5), (5, 8)}, fixed injected coefs, a 32-byte secret from `pack-u32` words (the `nt-key` idiom); `sh-join` over the first t shares returns `j-ok` with the secret |
  | G9 | subset agreement: all n clean shares under the same three shapes, `sh-agree` returns `ag-ok` |
  | G10 | corrupted share: one y byte flipped inside the base subset and, on a second row, outside it; `sh-agree` returns `ag-off` both times |
  | G11 | refusals: t-1 shares yield `ag-short`; a duplicated x yields `ag-dupx`, including a clean extra repeating a base x (the hole a base-only scan leaves, per the `sh-agree` comment); an x = 0 share yields `ag-badx` |
  | M3 | mutant, RUN: `R283` 283 to 27 in the scratch lib (one sed needle, the M1/M2 mechanism); every product that overflows degree 7 reduces wrong, so G7 and G8 both go red |

- **Open questions:** whether the `sh-split` call site spends a guard or a
  checked cast to fill a refined `px`, or the `px`/`t` bounds stay stated
  contracts (the N01 SPEC decision 2 precedent; the engine's reach itself is
  settled, see the refinement knob above); whether prim lands as its own commit before shamir or in the
  same train (the SPEC orders the slices); whether `sh-bytes` keeps the
  per-byte bcat under a key-sized secret budget or takes the `cx-run` block
  shape, which N8's seal-then-split sizing decides.
- **Author-tier flags, verbatim from [[decision-quorum-store]] "Left open":**
  "Whether the store becomes its own arc once N8's design lands." and
  "Quorum membership and transport binding live in N4 and N8 jointly; the
  seam between them is undrawn." Flagged, untouched here. One divergence
  flag: the dispatch prompt proposed `lib/crypto/gf256.chiral` as a home;
  this example follows the decision's one-shared-module sentence instead and
  the SPEC audit can overrule.
- **Related:** [[N01-crypto-kernels]], [[decision-quorum-store]],
  [[arcs/native-protocol-arc]], `docs/pattern-boundary-sums.md`.
