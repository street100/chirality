#!/usr/bin/env bash
# crypto.sh -- N1: the crypto kernels.
#   slice 1: ChaCha20 (lib/crypto/chacha.chiral)
#   slice 2: Poly1305 + AEAD (lib/crypto/poly1305.chiral)
#
# not-a-phase: N1's kernels; the dispatch line is owed to the suite-owning session.
# NOT YET REGISTERED: the run_phase line in run-tests.sh is owed to the
# suite-owning session. 8-12 stay owed to unported old-tree phases and reusing
# one would make an unported gate look ported; 21-23 are free at this writing.
#
# ─── WHAT THIS SLICE IS, AND WHAT IT IS GRADED ON ───────────────────────────
#
# `crypto/chacha` holds the ChaCha20 block function and the stream xor. Every
# row compares bytes a compiled fixture PRINTS against RFC constants held
# here in bash: the fixture asserts nothing and always exits 0, so a mutant
# cannot pass by rechecking its own arithmetic (the pretty.sh precedent).
#
# ⚑ VECTOR PROVENANCE: RFC 8439 fetched from rfc-editor.org on 2026-09-03 by
# the implementing session (WebFetch over the .txt) and §2.3.2 / §2.4.2
# transcribed below verbatim; the fetch agreed byte-for-byte with the
# session's own knowledge of both vectors. Both rows are asserted so a single
# mistranscription cannot pass silently: §2.4.2 exercises the same block
# function through chacha-xor under a different nonce, so the two rows only
# agree with each other by being right.
#
#   G1   the block function, RFC 8439 §2.3.2: key 00..1f, nonce
#        ..09....4a.., counter 1 -> the 64 serialized keystream bytes    [M1]
#   G2   the cipher, RFC 8439 §2.4.2: the sunscreen plaintext under
#        counter 1 -> all 114 ciphertext bytes (multi-block, so the
#        counter walk and the 50-byte tail are both on this row)         [M1]
#   M1   rotl32 count 16 -> 17 at qround's first rotation, RUN: the
#        first rotation of every quarter round moves, so the keystream
#        diverges from the first double round and BOTH rows must go red
#
# ⚑ SLICE 2 VECTOR PROVENANCE: RFC 8439 fetched from rfc-editor.org on
# 2026-09-03 by the implementing session (WebFetch over the .txt) and §2.5.2
# / §2.8.2 transcribed below verbatim; the fetch agreed byte-for-byte with
# the session's own knowledge of both vectors. The tag row and the seal row
# are asserted independently so a single mistranscription cannot pass
# silently: §2.8.2's tag runs the same Poly1305 under a chacha-derived key,
# so the two rows only agree with each other by being right.
#
#   G3   poly1305-mac, RFC 8439 §2.5.2: the one-time key 85:d6:.. over
#        "Cryptographic Forum Research Group" -> the 16 tag bytes        [M2]
#   G4   aead-seal, RFC 8439 §2.8.2: key 80..9f, nonce 07:00:00:00 +
#        IV 40..47, aad 50..53:c0..c7, the sunscreen plaintext -> all
#        114 ciphertext bytes with the 16 tag bytes appended
#   G5   aead-open on the sealed blob -> op-ok carrying the plaintext
#   G6   aead-open with ciphertext byte 0 flipped -> op-bad
#   M2   the weight-5 carry fold dropped in f-mul (x0 keeps u0, loses
#        w5), RUN: the §2.5.2 message spans three blocks and its clamped
#        r has a nonzero top limb, so every fold carries reduced value
#        into the tag and G3 must go red
#
# ⚑ THE MUTANT HARNESS IS NOT tools/test/mutant.sh. That one rebuilds
# prog/compiler.prog and asserts the mutant compiler differs; crypto/chacha
# is OUTSIDE that closure, so every mutation of it builds a byte-identical
# compiler and would score INERT. The mechanism for a module outside the
# closure is Phase 17/18/19's: a scratch lib/ copied with cp -a, mutated with
# sed -i, refused when the mutation changed nothing, the fixture compiled
# against that tree.
#
# The phase's wall clock is printed and sets no bar (the 2026-09-01 ruling,
# docs/benchmarks/README.md:29). Zero Python.
set -uo pipefail
T0=$SECONDS

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"

CC="${CHIRALITY_COMPILE:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
[ -x "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
# shellcheck disable=SC1091
. "$REPO/bin/chirality-resolve.sh"

CHACHA="$REPO/lib/crypto/chacha.chiral"
[ -f "$CHACHA" ] || { echo "  FAIL  $CHACHA missing -- a gate without its module cannot fail"; exit 2; }
POLY="$REPO/lib/crypto/poly1305.chiral"
[ -f "$POLY" ] || { echo "  FAIL  $POLY missing -- a gate without its module cannot fail"; exit 2; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# ─── the fixture ────────────────────────────────────────────────────────────
# Written here rather than tracked under samples/: slice 1 landed as a
# new-file-only addition (module + gate) while the enforcement-arc session
# held the rest of tools/test/. Emitted-bytes framing per e181_pretty.prog.
FIXTURE="$TMP/n01_chacha.prog"
cat >"$FIXTURE" <<'CHIRAL'
; n01_chacha.prog -- N1 slice 1 emitted-bytes fixture. Prints, never asserts:
; the assertions live in tools/test/crypto.sh, in bash, over these bytes.
(import "prelude/prelude")
(import "crypto/chacha")
(import "ports/stdio")

; the RFC 8439 inputs, built from LE words. Both sections share the key
; 00 01 .. 1f: eight LE u32 words from 0x03020100, each 0x04040404 above
; the last, spelled in decimal.
(def nt-key Bytes
  (bcat (pack-u32 50462976)  (bcat (pack-u32 117835012)
  (bcat (pack-u32 185207048) (bcat (pack-u32 252579084)
  (bcat (pack-u32 319951120) (bcat (pack-u32 387323156)
  (bcat (pack-u32 454695192) (pack-u32 522067228)))))))))

; §2.3.2 nonce 00:00:00:09:00:00:00:4a:00:00:00:00 as three LE words
(def nt-n232 Bytes
  (bcat (pack-u32 150994944) (bcat (pack-u32 1241513984) (pack-u32 0))))

; §2.4.2 nonce 00:00:00:00:00:00:00:4a:00:00:00:00
(def nt-n242 Bytes
  (bcat (pack-u32 0) (bcat (pack-u32 1241513984) (pack-u32 0))))

; §2.4.2 plaintext, 114 bytes
(def nt-pt Bytes
  (str->bytes "Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it."))

(def nt-emit (=> Bytes I64 Unit)
  (lam (bs i)
    (case (<i i (blen bs))
      (true (let ((_ (put (i64->str (bget bs i)))))
              (let ((_ (put " ")))
                (nt-emit bs (+ i 1)))))
      (false (unit)))))

(def nt-block (=> Str Bytes Unit)
  (lam (lbl bs)
    (let ((_ (put (str-cat "==BEGIN " (str-cat lbl "==\n")))))
      (let ((_ (nt-emit bs 0)))
        (put "\n==END==\n")))))

(def compile-main (=> I64 I64)
  (lam (n)
    (let ((_ (nt-block "b232" (chacha-block nt-key nt-n232 1))))
      (let ((_ (nt-block "x242" (chacha-xor nt-key nt-n242 1 nt-pt))))
        0))))
CHIRAL

# ─── the slice-2 fixture ────────────────────────────────────────────────────
# Inline for the same reason as the slice-1 fixture above: the slice landed
# as new-file additions plus this script while the enforcement-arc session
# held the rest of tools/test/.
AFIXTURE="$TMP/n01_aead.prog"
cat >"$AFIXTURE" <<'CHIRAL'
; n01_aead.prog -- N1 slice 2 emitted-bytes fixture. Prints, never asserts:
; the assertions live in tools/test/crypto.sh, in bash, over these bytes.
(import "prelude/prelude")
(import "crypto/chacha")
(import "crypto/poly1305")
(import "ports/stdio")

; §2.5.2 one-time key 85:d6:be:78:..:41:49:f5:1b as eight LE u32 words
(def na-k252 Bytes
  (bcat (pack-u32 2025772677) (bcat (pack-u32 862803287)
  (bcat (pack-u32 4266804351) (bcat (pack-u32 2819020098)
  (bcat (pack-u32 2323645185) (bcat (pack-u32 4256304635)
  (bcat (pack-u32 2952183626) (pack-u32 469059905)))))))))

; §2.5.2 message, 34 bytes (three MAC blocks, the last one short)
(def na-msg Bytes (str->bytes "Cryptographic Forum Research Group"))

; §2.8.2 key 80:81:..:9f as eight LE u32 words
(def na-k282 Bytes
  (bcat (pack-u32 2206368128) (bcat (pack-u32 2273740164)
  (bcat (pack-u32 2341112200) (bcat (pack-u32 2408484236)
  (bcat (pack-u32 2475856272) (bcat (pack-u32 2543228308)
  (bcat (pack-u32 2610600344) (pack-u32 2677972380)))))))))

; §2.8.2 nonce 07:00:00:00:40:41:42:43:44:45:46:47 as three LE words
(def na-n282 Bytes
  (bcat (pack-u32 7) (bcat (pack-u32 1128415552) (pack-u32 1195787588))))

; §2.8.2 aad 50:51:52:53:c0:c1:c2:c3:c4:c5:c6:c7 as three LE words
(def na-aad Bytes
  (bcat (pack-u32 1397903696)
        (bcat (pack-u32 3284320704) (pack-u32 3351692740))))

; §2.8.2 plaintext, 114 bytes (the §2.4.2 sunscreen text)
(def na-pt Bytes
  (str->bytes "Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it."))

; one byte as a Bytes of length 1 (the e151 idiom)
(def na-b1 (-> I64 Bytes) (lam (b) (bslice (pack-u32 b) 0 1)))

(def na-emit (=> Bytes I64 Unit)
  (lam (bs i)
    (case (<i i (blen bs))
      (true (let ((_ (put (i64->str (bget bs i)))))
              (let ((_ (put " ")))
                (na-emit bs (+ i 1)))))
      (false (unit)))))

(def na-blk (=> Str Bytes Unit)
  (lam (lbl bs)
    (let ((_ (put (str-cat "==BEGIN " (str-cat lbl "==\n")))))
      (let ((_ (na-emit bs 0)))
        (put "\n==END==\n")))))

; an open outcome as bytes: 1 then the plaintext on op-ok, 0 on op-bad
(def na-open-blk (=> Str OpenR Unit)
  (lam (lbl r)
    (case r
      ((op-ok pt) (na-blk lbl (bcat (na-b1 1) pt)))
      ((op-bad) (na-blk lbl (na-b1 0))))))

(def compile-main (=> I64 I64)
  (lam (n)
    (let ((sealed (aead-seal na-k282 na-n282 na-aad na-pt)))
      (let ((_ (na-blk "t252" (poly1305-mac na-k252 na-msg))))
        (let ((_ (na-blk "s282" sealed)))
          (let ((_ (na-open-blk "o282"
                     (aead-open na-k282 na-n282 na-aad sealed))))
            (let ((flip (bcat (na-b1 (bxor (bget sealed 0) 1))
                              (bslice sealed 1 (blen sealed)))))
              (let ((_ (na-open-blk "obad"
                         (aead-open na-k282 na-n282 na-aad flip))))
                0))))))))
CHIRAL

# ─── helpers (the pretty.sh idiom) ──────────────────────────────────────────
# build_raw LIBDIR OUT [FIX] -> 0 and OUT holds the fixture's raw stdout.
# FIX defaults to the slice-1 fixture; slice 2 passes its own.
build_raw() {
  local lib="$1" out="$2" fix="${3:-$FIXTURE}" blob="$TMP/o.blob" elf="$TMP/o.elf"
  ( cd "$REPO" && chirality_blob_file "$lib:$REPO/prog" "$fix" ) >"$blob" 2>/dev/null || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
  ( ulimit -s unlimited; "$elf" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ]
}

# blk LABEL FILE -> the bytes of one ==BEGIN label== .. ==END== block
blk() {
  awk -v l="==BEGIN $1==" 'BEGIN{p=0} $0==l{p=1;next} p&&$0=="==END=="{exit} p{print}' "$2"
}

# dec "HEX BYTES.." -> the same bytes in decimal, single-space-joined
dec() {
  local h out=""
  for h in $1; do out="$out $((16#$h))"; done
  echo $out
}

# ─── the transcribed vectors, hex verbatim from the RFC's dumps ─────────────
# RFC 8439 §2.3.2, the serialized keystream block:
V232="10 f1 e7 e4 d1 3b 59 15 50 0f dd 1f a3 20 71 c4
c7 d1 f4 c7 33 c0 68 03 04 22 aa 9a c3 d4 6c 4e
d2 82 64 46 07 9f aa 09 14 c2 d7 05 d9 8b 02 a2
b5 12 9c d1 de 16 4e b9 cb d0 83 e8 a2 50 3c 4e"

# RFC 8439 §2.4.2, the ciphertext:
V242="6e 2e 35 9a 25 68 f9 80 41 ba 07 28 dd 0d 69 81
e9 7e 7a ec 1d 43 60 c2 0a 27 af cc fd 9f ae 0b
f9 1b 65 c5 52 47 33 ab 8f 59 3d ab cd 62 b3 57
16 39 d6 24 e6 51 52 ab 8f 53 0c 35 9f 08 61 d8
07 ca 0d bf 50 0d 6a 61 56 a3 8e 08 8a 22 b6 5e
52 bc 51 4d 16 cc f8 06 81 8c e9 1a b7 79 37 36
5a f9 0b bf 74 a3 5b e6 b4 0b 8e ed f2 78 5e 42
87 4d"

WANT232="$(dec "$V232")"
WANT242="$(dec "$V242")"

# ─── the real build: G1 and G2 ──────────────────────────────────────────────
echo "=== N1 slice 1: ChaCha20 vs RFC 8439 ==="
OUT="$TMP/real.out"
if ! build_raw "$REPO/lib" "$OUT"; then
  echo "  FAIL  the fixture did not build/run against the real lib/"; exit 1
fi

got232="$(echo $(blk b232 "$OUT"))"
got242="$(echo $(blk x242 "$OUT"))"

if [ "$got232" = "$WANT232" ]; then ok "G1 block function -- all 64 §2.3.2 keystream bytes match"
else bad "G1 block function diverges from §2.3.2"; echo "        want: $WANT232"; echo "        got:  $got232"; fi

if [ "$got242" = "$WANT242" ]; then ok "G2 cipher -- all 114 §2.4.2 ciphertext bytes match (two blocks, 50-byte tail)"
else bad "G2 cipher diverges from §2.4.2"; echo "        want: $WANT242"; echo "        got:  $got242"; fi

# ─── M1: the flipped-rotation mutant, RUN ───────────────────────────────────
# ⚑ THE SCRATCH lib/ MUST BE A REAL DIRECTORY, NEVER A SYMLINK. cp -a copies
# a symlink AS a symlink and every sed -i then writes THROUGH it into the
# tree under test (nineteen phantom failures, measured, pretty.sh's arc).
MUTLIB="$TMP/mutlib"; rm -rf "$MUTLIB"; cp -a "$REPO/lib" "$MUTLIB"
if [ -L "$MUTLIB" ]; then
  bad "M1 -- the scratch lib/ is a SYMLINK; sed would write into the tree under test"
else
  MTGT="$MUTLIB/crypto/chacha.chiral"
  NEEDLE="(rotl32 (bxor d a1) 16)"
  nhits="$(grep -cF -- "$NEEDLE" "$MTGT")"
  if [ "$nhits" -ne 1 ]; then
    bad "M1 -- needle matched $nhits time(s), not 1 (stale pattern; the mutation would be a lie)"
  else
    sed -i 's/(rotl32 (bxor d a1) 16)/(rotl32 (bxor d a1) 17)/' "$MTGT"
    if cmp -s "$MTGT" "$CHACHA"; then
      bad "M1 -- the mutation did not change chacha.chiral (stale pattern)"
    else
      MOUT="$TMP/mut.out"
      if ! build_raw "$MUTLIB" "$MOUT"; then
        bad "M1 -- the mutant did not build/run; UNBUILT measures nothing about the rows"
      else
        m232="$(echo $(blk b232 "$MOUT"))"
        m242="$(echo $(blk x242 "$MOUT"))"
        if [ "$m232" != "$WANT232" ] && [ "$m242" != "$WANT242" ]; then
          ok "M1 rotl32 16->17 -- RUN, and both rows went red (the assertions read the code)"
        else
          bad "M1 rotl32 16->17 -- a row stayed GREEN under the mutant; that row is toothless"
        fi
      fi
    fi
  fi
fi

# ─── slice 2: the transcribed vectors, hex verbatim from the RFC's dumps ────
# RFC 8439 §2.5.2, the Poly1305 tag:
V252="a8 06 1d c1 30 51 36 c6 c2 2b 8b af 0c 01 27 a9"

# RFC 8439 §2.8.2, the AEAD ciphertext:
V282CT="d3 1a 8d 34 64 8e 60 db 7b 86 af bc 53 ef 7e c2
a4 ad ed 51 29 6e 08 fe a9 e2 b5 a7 36 ee 62 d6
3d be a4 5e 8c a9 67 12 82 fa fb 69 da 92 72 8b
1a 71 de 0a 9e 06 0b 29 05 d6 a5 b6 7e cd 3b 36
92 dd bd 7f 2d 77 8b 8c 98 03 ae e3 28 09 1b 58
fa b3 24 e4 fa d6 75 94 55 85 80 8b 48 31 d7 bc
3f f4 de f0 8e 4b 7a 9d e5 76 d2 65 86 ce c6 4b
61 16"

# RFC 8439 §2.8.2, the AEAD tag:
V282TAG="1a e1 0b 59 4f 09 e2 6a 7e 90 2e cb d0 60 06 91"

WANT252="$(dec "$V252")"
WANT282="$(dec "$V282CT") $(dec "$V282TAG")"

# the open row's expectation comes from the plaintext itself, not the RFC
# dump: 1 (op-ok) then the 114 sunscreen bytes in decimal
PT282="Ladies and Gentlemen of the class of '99: If I could offer you only one tip for the future, sunscreen would be it."
WANTOPEN="1 $(printf '%s' "$PT282" | od -An -v -tu1 | xargs)"

# ─── slice 2: G3..G6 ────────────────────────────────────────────────────────
echo
echo "=== N1 slice 2: Poly1305 + AEAD vs RFC 8439 ==="
AOUT="$TMP/aead.out"
if ! build_raw "$REPO/lib" "$AOUT" "$AFIXTURE"; then
  echo "  FAIL  the aead fixture did not build/run against the real lib/"; exit 1
fi

got252="$(echo $(blk t252 "$AOUT"))"
got282="$(echo $(blk s282 "$AOUT"))"
gotopen="$(echo $(blk o282 "$AOUT"))"
gotobad="$(echo $(blk obad "$AOUT"))"

if [ "$got252" = "$WANT252" ]; then ok "G3 poly1305-mac -- all 16 §2.5.2 tag bytes match"
else bad "G3 poly1305-mac diverges from §2.5.2"; echo "        want: $WANT252"; echo "        got:  $got252"; fi

if [ "$got282" = "$WANT282" ]; then ok "G4 aead-seal -- all 114 §2.8.2 ciphertext bytes and the 16 tag bytes match"
else bad "G4 aead-seal diverges from §2.8.2"; echo "        want: $WANT282"; echo "        got:  $got282"; fi

if [ "$gotopen" = "$WANTOPEN" ]; then ok "G5 aead-open -- op-ok, and the recovered plaintext matches byte for byte"
else bad "G5 aead-open did not return the plaintext"; echo "        want: $WANTOPEN"; echo "        got:  $gotopen"; fi

if [ "$gotobad" = "0" ]; then ok "G6 aead-open -- ciphertext byte 0 flipped, refused as op-bad"
else bad "G6 aead-open ACCEPTED a flipped ciphertext byte"; echo "        got:  $gotobad"; fi

# ─── M2: the dropped weight-5 carry fold, RUN ───────────────────────────────
# Same mechanism and same symlink guard as M1: a module outside the compiler
# closure is mutated in a scratch lib/ and the fixture rebuilt against it.
MUTLIB2="$TMP/mutlib2"; rm -rf "$MUTLIB2"; cp -a "$REPO/lib" "$MUTLIB2"
if [ -L "$MUTLIB2" ]; then
  bad "M2 -- the scratch lib/ is a SYMLINK; sed would write into the tree under test"
else
  MTGT2="$MUTLIB2/crypto/poly1305.chiral"
  NEEDLE2="(x0 (+ u0 w5))"
  nhits2="$(grep -cF -- "$NEEDLE2" "$MTGT2")"
  if [ "$nhits2" -ne 1 ]; then
    bad "M2 -- needle matched $nhits2 time(s), not 1 (stale pattern; the mutation would be a lie)"
  else
    sed -i 's/(x0 (+ u0 w5))/(x0 u0)/' "$MTGT2"
    if cmp -s "$MTGT2" "$POLY"; then
      bad "M2 -- the mutation did not change poly1305.chiral (stale pattern)"
    else
      MOUT2="$TMP/mut2.out"
      if ! build_raw "$MUTLIB2" "$MOUT2" "$AFIXTURE"; then
        bad "M2 -- the mutant did not build/run; UNBUILT measures nothing about the rows"
      else
        m252="$(echo $(blk t252 "$MOUT2"))"
        if [ "$m252" != "$WANT252" ]; then
          ok "M2 f-mul carry fold dropped -- RUN, and the §2.5.2 tag row went red (the assertion reads the code)"
        else
          bad "M2 f-mul carry fold dropped -- the §2.5.2 row stayed GREEN under the mutant; that row is toothless"
        fi
      fi
    fi
  fi
fi

echo
echo "  crypto.sh: $pass ok, $fail FAIL, $((SECONDS - T0))s wall (records, sets no bar)"
[ "$fail" -eq 0 ] || exit 1
exit 0
