#!/usr/bin/env bash
# crypto.sh -- N1: the crypto kernels. Slice 1: ChaCha20 (lib/crypto/chacha.chiral).
#
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

# ─── helpers (the pretty.sh idiom) ──────────────────────────────────────────
# build_raw LIBDIR OUT -> 0 and OUT holds the fixture's raw stdout.
build_raw() {
  local lib="$1" out="$2" blob="$TMP/o.blob" elf="$TMP/o.elf"
  ( cd "$REPO" && chirality_blob_file "$lib:$REPO/prog" "$FIXTURE" ) >"$blob" 2>/dev/null || return 1
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

echo
echo "  crypto.sh: $pass ok, $fail FAIL, $((SECONDS - T0))s wall (records, sets no bar)"
[ "$fail" -eq 0 ] || exit 1
exit 0
