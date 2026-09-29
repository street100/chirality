#!/usr/bin/env bash
# span-over.sh -- the E200 gate: the coverage composite `bover`, judged over six
# rows and five mutants.
#
# suite phase: registered 2026-09-18. run-tests.sh is the authority for the
# number (the author's 2026-09-06 ruling at run-tests.sh:348-354), and a gate
# takes the first number colliding with nothing. Eight were registered, 25
# through 32, the eighth being mul-widen.sh at :368, so 33 is the first free.
#
# ⚑ THE PROBE ASSERTS NOTHING. `prog/samples/e200-coverage-composite.prog`
# prints five lines and exits 0. Every comparison lives here, in bash, on the
# rule mul-widen.sh:9-12 states: a probe that derives its own verdict is green
# under any mutant that changes what the verdict says.
#
# ⚑ NO GOLDEN IS PINNED. This file carries the destination bytes, the mask
# bytes and the colour bytes as its OWN literals, beside the probe's, and
# recomputes every output byte from them through the source-over formula. A
# golden cut by running the code pins a wrong answer as correct for good.
# Carrying the operands here rather than reading them back out of the probe is
# also what lets M4 convict the fixture.
#
# The arithmetic, per channel, with `a` the coverage byte, `s` the colour
# channel, `sA` the colour's alpha (byte 3, DRM memory order) and `d` the
# destination channel:
#
#     ca  = div255(sA * a)
#     out = div255(s * a) + div255(d * (255 - ca))
#     div255(x) = ((x + 128) + ((x + 128) >> 8)) >> 8
#
# ─── THE SIX ROWS ───────────────────────────────────────────────────────────
#
#   G1  the probe resolves, compiles to a non-empty ELF, exits 0, five rows
#   G2  the ARITHMETIC. Every one of R1's sixteen output bytes equals the value
#       recomputed here from this file's own operands, and R4's sixteen bytes
#       equal R1's -- same destination, same first four mask bytes, same colour
#   G3  the two EXTREMES, each on its own row. R2's coverage-0 pixel leaves all
#       four destination bytes byte-identical; R3's coverage-255 pixel leaves
#       all four equal to the colour, which is opaque, so replacement is exact
#   G4  the EXTENT, which lives in the routine and not in the type. R2's mask
#       is one byte against a two-pixel span, so pixel 1 is past the extent and
#       must be COPIED THROUGH (ti-bnew does not zero its payload, so a copy
#       that did not run shows as whatever the arena last held). R4's mask is
#       eight bytes against a four-pixel span, so the output length must still
#       be the destination's sixteen, and R5's must be 7,680
#   G5  MEMORY, read off the allocator itself. Sixteen 1920-pixel spans through
#       `bover` against the same sixteen through `bcat` per pixel, each root
#       reporting its own `heap-allocated` delta (lib/ports/process.port:36,
#       the arena's bump cursor: heapptr - heapbase, which the crypto bench
#       already uses as its instrument, tools/bench/crypto-kernel.sh:11)
#   G6  both halves of the pair are reachable ALONE: a root naming only
#       `brepeat` compiles and runs, and a root naming only `bover` compiles
#       and runs. docs/goals/display.md:43-45 consequence 3 is a property of
#       the vocabulary, and a gate over one primitive never sees it
#
# ⚑ G5 DOES NOT MEASURE RSS AND THAT IS A CORRECTION. The SPEC's §4 sets G5 on
# "max RSS ... at most one eighth of a control". There is no `/usr/bin/time` on
# this box, and `ulimit -v` is not a substitute: measured 2026-09-18, ANY
# RLIMIT_AS makes the entry stub's arena mmap fail ("can't allocate arena") at
# caps from 96 MiB to 32 GiB, so the instrument refuses every root equally and
# a gate built on it passes by looking at nothing. `heap-allocated` is the
# tree's own instrument, it is exact rather than sampled, and the threshold
# stays the SPEC's arithmetic.
#
# ⚑ G2 AND G4 ARE SPLIT ALONG THE MUTANTS, AND THAT IS THE WHOLE REASON FOR
# THE SPLIT. R4-equals-R1 is an arithmetic fact and sits in G2, because M4
# moves R1 and not R4 and must redden ONE row. R2's tail and the two lengths
# are extent facts and sit in G4, because M1 moves none of them. The SPEC's §4
# put R4-equals-R1 in G4; measured against the mutants, that placement makes M4
# redden two rows, so the check moved rather than the mutant.
#
# ─── THE MUTANTS, EACH ACTUALLY RUN ─────────────────────────────────────────
#
#   M1  coverage-dropped        -- nb-bover-go's five multiplies by the mask
#                                  byte become multiplies by 255.  one
#                                  generation.  moves R1 R2 R4 R5; reddens G2
#                                  and G3's coverage-0 row
#   M2  tail-copy-suppressed    -- the shorter-mask arm's nb-copy length
#                                  becomes zero, so everything past the extent
#                                  is left as the allocator found it.  one
#                                  generation.  moves R2; reddens G4
#   M3  prim2lib-row-dropped    -- the (pair "bover" "nb-bover") row leaves
#                                  prim2lib-table.  one generation.  reddens G1
#                                  with a refusal naming bover
#   M4  fixture-mask-collapsed  -- the probe's R1 mask becomes four 255 bytes.
#                                  NO rebuild.  moves R1 alone: R2, R3, R4 and
#                                  R5 carry their own mask literals
#   M5  extent-collapsed        -- nb-bover-go's termination becomes `i < n`,
#                                  so no pixel is composited at all.  one
#                                  generation.  moves all five; reddens G2, G3
#                                  and G4
#
# ⚑ M5 IS THIS RUN'S ADDITION AND THE REASON IS A MEASUREMENT. The SPEC's M2 is
# "the loop bound becomes n + 1, so the routine reads one pixel past the
# shorter cell", pinned at G4. Built and run, IT MOVES NOTHING, and the reason
# is the routine's own order: it composites [0, 4n) and then copies [4n, ld)
# through from the destination, so an over-run either lands inside the copied
# region and is overwritten, or lands past the output cell where no printed
# byte reads it. An over-extent is therefore unobservable through the output by
# construction. The direction the output CAN see is an under-extent, so M5
# drives the count to zero and M2 takes the other half of the length discipline
# -- the copy-through. The SPEC's mutant is still run, below, and reported
# ungraded with what it measured, because a mutant that convicts nothing is a
# result about the gate and not a row to hide.
#
# ⚑ M3 PINS THE REFUSAL THE COMPILER ACTUALLY PRINTS, WHICH IS NOT THE SPEC'S.
# The SPEC names `prim not in native subset: bover`, which erase.chiral:169
# does construct. It never reaches stderr: `filter-erasable`
# (lib/lowering/compile-back.chiral:185-188) discards `xf-err`'s message and
# records `sk-extern op` instead, which skip-diag.chiral:85-88 formats as
# `<fn>: extern does not lower: <op>`. Measured 2026-09-18. The row pins the
# string that is load-bearing and names the other one here.
#
# ⚑ EACH MUTANT PINS THE WHOLE SET OF ROWS IT MOVES, and a row moving outside
# its set fails the mutant. records/gate-audit.md GA-21 and GA-22 both convict
# a gate naming one row per mutant (mul-widen.sh:83-86).
#
# ⚑ THE E145 PLACEMENT IS PRINTED AND LEFT UNGRADED. bytes.chiral:643-644 says
# native-lib's list position IS the runtime routine's address, so an insertion
# anywhere but the tail shifts every later routine. The note's scope is layout
# and it makes no correctness claim, because a full rebuild regenerates every
# call site from the same list. Grading it would assert a refusal nothing
# enforces, which is the failure BA-39 records in E173's own gate
# (records/baseline-alignment.md:426-433).

set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CC="${CHIRALITY_COMPILE:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
[ -x "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
# shellcheck disable=SC1091
. "$REPO/bin/chirality-resolve.sh"

PROBE="samples/e200-coverage-composite.prog"
ROOT="$REPO/prog/$PROBE"
BYTES="$REPO/lib/lowering/tal/bytes.chiral"
ERASE="$REPO/lib/lowering/tal/erase.chiral"
for f in "$ROOT" "$BYTES" "$ERASE"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its fixture cannot fail"; exit 2; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()   { echo "  ok    $1"; pass=$((pass+1)); }
bad()  { echo "  FAIL  $1"; fail=$((fail+1)); }
note() { echo "  note  $1"; }

# ---- the operands, carried HERE, beside the probe's ------------------------
# R1 and R4 destination: four pixels, sixteen bytes
D1=(10 20 30 40 200 150 100 255 0 0 0 0 255 255 255 255)
# R1 mask: four coverage bytes.  R4 adds (17 34 51 68) past the extent.
MK=(0 85 170 255)
# the one colour every row composites, premultiplied ARGB8888, opaque
COL=(10 120 200 255)
# R2 destination: two pixels, against a ONE-byte mask of 0
D2=(10 20 30 40 200 150 100 255)
# R3 destination: one pixel, against a ONE-byte mask of 255
D3=(10 20 30 40)
# the arena, and what the two routes cost against it
ARENA=67108864          # lib/memory/arena.chiral:29
WANT_BOVER=122880       # 16 spans * 7,680 bytes, one ti-bnew each
WANT_BCAT=118026240     # 16 * 4 * 1920 * 1921 / 2, right-recursive bcat

# ---- helpers ---------------------------------------------------------------

# d255 X -> ((X + 128) + ((X + 128) >> 8)) >> 8
d255() { local t=$(( $1 + 128 )); echo $(( (t + (t >> 8)) >> 8 )); }

# overpx D0 D1 D2 D3 A -> the four composited bytes as eight hex nibbles
overpx() {
  local a="$5" ca inv k out=""
  local dst=("$1" "$2" "$3" "$4")
  ca="$(d255 $(( ${COL[3]} * a )))"
  inv=$(( 255 - ca ))
  for k in 0 1 2 3; do
    local sc dc
    sc="$(d255 $(( ${COL[$k]} * a )))"
    dc="$(d255 $(( ${dst[$k]} * inv )))"
    out="$out$(printf '%02x' $(( sc + dc )))"
  done
  printf '%s' "$out"
}

# mutlib NAME REPO-REL-PATH SED-EXPR... -> a scratch copy of lib/ with that file
# mutated, left in $MUTLIB.  mul-widen.sh:141-155 verbatim, including its two
# guards: the scratch lib/ must be a real directory (cp -a copies a symlink AS a
# symlink and every later `sed -i` would then write through it into the tree
# under test), and a pattern that changed nothing is REPORTED, because a mutant
# that did not mutate proves nothing.
MUTLIB=""
mutlib() {
  local name="$1" rel="$2"; shift 2
  MUTLIB="$TMP/mutlib"; rm -rf "$MUTLIB"; cp -a "$REPO/lib" "$MUTLIB"
  if [ -L "$MUTLIB" ]; then
    bad "$name -- the scratch lib/ is a SYMLINK; every sed would write into the tree under test"; return 1
  fi
  local target="$MUTLIB/${rel#lib/}" e
  for e in "$@"; do
    sed -i "$e" "$target" || { bad "$name -- sed failed"; return 1; }
  done
  if cmp -s "$target" "$REPO/$rel"; then
    bad "$name -- the mutation did not change $rel (stale pattern)"; return 1
  fi
  return 0
}

# gen LIBDIR OUT -> ONE compiler generation built by $CC from LIBDIR's sources.
gen() {
  local libdir="$1" out="$2"
  ( cd "$REPO" && chirality_blob_file "$libdir:$REPO/prog" prog/compiler.prog ) \
    >"$TMP/g.blob" 2>/dev/null || return 1
  [ -s "$TMP/g.blob" ] || return 1
  ( ulimit -s unlimited; "$CC" <"$TMP/g.blob" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ] || return 1
  chmod +x "$out"
}

# build COMPILER LIBDIR PROGDIR ROOTFILE ELF [ERRFILE] -> compile a root.
build() {
  local cc="$1" libdir="$2" progdir="$3" rootf="$4" elf="$5" err="${6:-/dev/null}"
  ( cd "$REPO" && chirality_blob_file "$libdir:$progdir" "$progdir/$rootf" ) \
    >"$TMP/b.blob" 2>"$err" || return 1
  [ -s "$TMP/b.blob" ] || return 1
  ( ulimit -s unlimited; "$cc" <"$TMP/b.blob" >"$elf" 2>>"$err" ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
}

# rows ELF OUT -> run it, keep only the five ==E200== lines
rows() {
  ( ulimit -s unlimited; "$1" >"$TMP/r.raw" 2>/dev/null ) || return 1
  grep '^==E200== ' "$TMP/r.raw" >"$2" || return 1
  [ "$(wc -l <"$2")" -eq 5 ]
}

# cell ROW FIELD FILE -> field N of the row tagged ROW (1 is the first payload)
cell() { awk -v t="$1" -v n="$2" '$2==t{print $(2+n)}' "$3"; }

# moved BASE MUT -> the tags whose whole line differs, space separated
moved() {
  local t
  for t in R1 R2 R3 R4 R5; do
    [ "$(grep " $t " "$1")" = "$(grep " $t " "$2")" ] || printf '%s ' "$t"
  done
}

# verdict NAME EXPECTED-SET ACTUAL-SET
verdict() {
  local name="$1" want="$2" got="$3"
  if [ "$want" = "$got" ]; then ok "$name moved exactly [$got]"
  else bad "$name moved [$got], its table entry pins [$want]"; fi
}

# ---- the recomputation, from this file's own literals ----------------------
want_r1=""
for p in 0 1 2 3; do
  b=$(( p * 4 ))
  want_r1="$want_r1$(overpx "${D1[$b]}" "${D1[$((b+1))]}" "${D1[$((b+2))]}" "${D1[$((b+3))]}" "${MK[$p]}")"
done
want_r2_head="$(overpx "${D2[0]}" "${D2[1]}" "${D2[2]}" "${D2[3]}" 0)"
want_r2_tail="$(printf '%02x%02x%02x%02x' "${D2[4]}" "${D2[5]}" "${D2[6]}" "${D2[7]}")"
want_r3="$(overpx "${D3[0]}" "${D3[1]}" "${D3[2]}" "${D3[3]}" 255)"
want_col="$(printf '%02x%02x%02x%02x' "${COL[0]}" "${COL[1]}" "${COL[2]}" "${COL[3]}")"

# ---- the generated roots, for G5 and G6 ------------------------------------
GP="$TMP/gprog"; mkdir -p "$GP"

# ⚑ THE TWO G6 ROOTS CARRY NO COMMENT NAMING THE OTHER'S PRIMITIVE, because the
# disjointness check below reads the whole file and a comment would satisfy it.
cat >"$GP/e200-g6-fill.prog" <<'EOF'
; G6: the fill half alone.
(import "prelude/prelude")
(import "ports/stdio")
(declare g6-quad (-> I64 I64 I64 I64 Bytes))
(def g6-quad (lam (b0 b1 b2 b3)
  (pack-u32 (bor b0 (bor (shl b1 8) (bor (shl b2 16) (shl b3 24)))))))
(declare g6-nib (-> I64 Str))
(def g6-nib (lam (d) (str-sub "0123456789abcdef" d (+ d 1))))
(declare g6-hex8 (-> I64 Str))
(def g6-hex8 (lam (v) (str-cat (g6-nib (band (shr v 4) 15)) (g6-nib (band v 15)))))
(declare g6-bytes-go (-> Bytes I64 I64 Str))
(def g6-bytes-go (lam (b i n)
  (case (=i i n) (true "")
    (false (str-cat (g6-hex8 (bget b i)) (g6-bytes-go b (+ i 1) n))))))
(def compile-main (=> I64 I64)
  (lam (n)
    (do (put (str-cat "==G6== fill "
          (str-cat (g6-bytes-go (brepeat (g6-quad 1 2 3 4) 3) 0 12) "\n")))
    0)))
EOF

# The coverage is 255 and the colour is opaque, so the answer IS the colour,
# which is also why M1 does not move this root.
cat >"$GP/e200-g6-comp.prog" <<'EOF'
; G6: the composite half alone.
(import "prelude/prelude")
(import "ports/stdio")
(declare g6-quad (-> I64 I64 I64 I64 Bytes))
(def g6-quad (lam (b0 b1 b2 b3)
  (pack-u32 (bor b0 (bor (shl b1 8) (bor (shl b2 16) (shl b3 24)))))))
(declare g6-nib (-> I64 Str))
(def g6-nib (lam (d) (str-sub "0123456789abcdef" d (+ d 1))))
(declare g6-hex8 (-> I64 Str))
(def g6-hex8 (lam (v) (str-cat (g6-nib (band (shr v 4) 15)) (g6-nib (band v 15)))))
(declare g6-bytes-go (-> Bytes I64 I64 Str))
(def g6-bytes-go (lam (b i n)
  (case (=i i n) (true "")
    (false (str-cat (g6-hex8 (bget b i)) (g6-bytes-go b (+ i 1) n))))))
(def compile-main (=> I64 I64)
  (lam (n)
    (do (put (str-cat "==G6== comp "
          (str-cat (g6-bytes-go
            (bover (g6-quad 10 20 30 40)
                   (cover (bslice (g6-quad 255 0 0 0) 0 1))
                   (pix (g6-quad 10 120 200 255))) 0 4) "\n")))
    0)))
EOF

cat >"$GP/e200-g5-bover.prog" <<'EOF'
; G5: sixteen 1920-pixel spans through `bover`.  One ti-bnew of 7,680 bytes per
; span, so the composite's own cost is 16 * 7,680 = 122,880 bytes.  The two
; brepeat fixtures per span are the operands and are counted with it.
(import "prelude/prelude")
(import "ports/stdio")
(import "ports/process")
(declare g5-quad (-> I64 I64 I64 I64 Bytes))
(def g5-quad (lam (b0 b1 b2 b3)
  (pack-u32 (bor b0 (bor (shl b1 8) (bor (shl b2 16) (shl b3 24)))))))
(declare g5-fold-go (-> Bytes I64 I64 I64 I64))
(def g5-fold-go (lam (b i n acc)
  (case (=i i n) (true acc)
    (false (g5-fold-go b (+ i 1) n (+ acc (* (+ i 1) (bget b i))))))))
(declare g5-run (-> I64 I64 I64))
(def g5-run (lam (k acc)
  (case (=i k 0) (true acc)
    (false (g5-run (- k 1)
      (+ acc (g5-fold-go
        (bover (brepeat (g5-quad 1 2 3 4) 1920)
               (cover (brepeat (g5-quad 0 85 170 255) 480))
               (pix (g5-quad 10 120 200 255)))
        0 7680 0)))))))
(declare g5-nib (-> I64 Str))
(def g5-nib (lam (d) (str-sub "0123456789abcdef" d (+ d 1))))
(declare g5-hex-go (-> I64 I64 Str))
(def g5-hex-go (lam (v i)
  (case (=i i 0) (true "")
    (false (str-cat (g5-hex-go (shr v 4) (- i 1)) (g5-nib (band v 15)))))))
(def compile-main (=> I64 I64)
  (lam (n)
    (let (a0 (heap-allocated unit))
      (let (r (g5-run 16 0))
        (let (a1 (heap-allocated unit))
          (do (put (str-cat "==G5== bover "
                (str-cat (g5-hex-go r 16)
                (str-cat " " (str-cat (i64->str (- a1 a0)) "\n")))))
          0))))))
EOF

cat >"$GP/e200-g5-bcat.prog" <<'EOF'
; G5: the control.  The same sixteen 1920-pixel spans, assembled `bcat` per
; pixel with the same source-over arithmetic written in surface chirality.
; Right-recursive bcat over k pieces of s bytes costs s * k * (k + 1) / 2, so
; one span is 4 * 1920 * 1921 / 2 = 7,376,640 bytes and sixteen are
; 118,026,240 -- 1.76 times the 67,108,864-byte arena (lib/memory/arena.chiral
; :29), so this root must grow the arena and the bover root must not.
(import "prelude/prelude")
(import "ports/stdio")
(import "ports/process")
(declare g5-quad (-> I64 I64 I64 I64 Bytes))
(def g5-quad (lam (b0 b1 b2 b3)
  (pack-u32 (bor b0 (bor (shl b1 8) (bor (shl b2 16) (shl b3 24)))))))
(declare g5-d255 (-> I64 I64))
(def g5-d255 (lam (x) (shr (+ (+ x 128) (shr (+ x 128) 8)) 8)))
(declare g5-chan (-> I64 I64 I64 I64 I64))
(def g5-chan (lam (s d a inv) (+ (g5-d255 (* s a)) (g5-d255 (* d inv)))))
(declare g5-mask (-> I64 I64))
(def g5-mask (lam (i)
  (case (=i (% i 4) 0) (true 0)
    (false (case (=i (% i 4) 1) (true 85)
      (false (case (=i (% i 4) 2) (true 170) (false 255))))))))
(declare g5-px (-> I64 Bytes))
(def g5-px (lam (i)
  (let (a (g5-mask i))
    (let (ca (g5-d255 (* 255 a)))
      (let (inv (- 255 ca))
        (g5-quad (g5-chan 10 1 a inv) (g5-chan 120 2 a inv)
                 (g5-chan 200 3 a inv) (g5-chan 255 4 a inv)))))))
(declare g5-span (-> I64 I64 Bytes))
(def g5-span (lam (i n)
  (case (=i i n) (true (str->bytes ""))
    (false (bcat (g5-px i) (g5-span (+ i 1) n))))))
(declare g5-fold-go (-> Bytes I64 I64 I64 I64))
(def g5-fold-go (lam (b i n acc)
  (case (=i i n) (true acc)
    (false (g5-fold-go b (+ i 1) n (+ acc (* (+ i 1) (bget b i))))))))
(declare g5-run (-> I64 I64 I64))
(def g5-run (lam (k acc)
  (case (=i k 0) (true acc)
    (false (g5-run (- k 1) (+ acc (g5-fold-go (g5-span 0 1920) 0 7680 0)))))))
(declare g5-nib (-> I64 Str))
(def g5-nib (lam (d) (str-sub "0123456789abcdef" d (+ d 1))))
(declare g5-hex-go (-> I64 I64 Str))
(def g5-hex-go (lam (v i)
  (case (=i i 0) (true "")
    (false (str-cat (g5-hex-go (shr v 4) (- i 1)) (g5-nib (band v 15)))))))
(def compile-main (=> I64 I64)
  (lam (n)
    (let (a0 (heap-allocated unit))
      (let (r (g5-run 16 0))
        (let (a1 (heap-allocated unit))
          (do (put (str-cat "==G5== bcat "
                (str-cat (g5-hex-go r 16)
                (str-cat " " (str-cat (i64->str (- a1 a0)) "\n")))))
          0))))))
EOF

# ============================================================================
echo "=== E200 G1: the probe compiles, runs and prints five rows ==="
BASE="$TMP/base.out"
if build "$CC" "$REPO/lib" "$REPO/prog" "$PROBE" "$TMP/base.elf" && rows "$TMP/base.elf" "$BASE"; then
  ok "the probe compiles to a non-empty ELF, exits 0 and prints five rows"
else
  bad "the probe did not compile, did not run, or did not print five rows"
  echo; echo "span-over: $pass passed, $fail failed"; exit 1
fi

# ---- G2 --------------------------------------------------------------------
echo
echo "=== E200 G2: every output byte of R1, recomputed here ==="
got_r1="$(cell R1 1 "$BASE")"
got_r4="$(cell R4 2 "$BASE")"
if [ "$got_r1" = "$want_r1" ]; then
  ok "R1's sixteen bytes equal the source-over values recomputed from this file's operands"
else
  bad "R1 is $got_r1, this file's arithmetic says $want_r1"
fi
if [ "$got_r4" = "$got_r1" ]; then
  ok "R4's sixteen bytes equal R1's -- same destination, same first four mask bytes, same colour"
else
  bad "R4 is $got_r4 and R1 is $got_r1; the same operands gave two answers"
fi

# ---- G3 --------------------------------------------------------------------
echo
echo "=== E200 G3: the two extremes, each on its own row ==="
got_r2="$(cell R2 1 "$BASE")"
got_r3="$(cell R3 1 "$BASE")"
if [ "${got_r2:0:8}" = "$want_r2_head" ] && [ "${got_r2:0:8}" = "0a141e28" ]; then
  ok "R2: coverage 0 leaves all four destination bytes byte-identical (${got_r2:0:8})"
else
  bad "R2's coverage-0 pixel is ${got_r2:0:8}, the destination is 0a141e28"
fi
if [ "$got_r3" = "$want_col" ] && [ "$got_r3" = "$want_r3" ]; then
  ok "R3: coverage 255 against an opaque colour leaves all four equal to the colour ($got_r3)"
else
  bad "R3 is $got_r3, the colour is $want_col and this file's arithmetic says $want_r3"
fi

# ---- G4 --------------------------------------------------------------------
echo
echo "=== E200 G4: the extent, which lives in the routine and not in the type ==="
if [ "${got_r2:8:8}" = "$want_r2_tail" ]; then
  ok "R2: the pixel past the one-byte mask is copied through verbatim (${got_r2:8:8})"
else
  bad "R2's tail is ${got_r2:8:8}, the destination's second pixel is $want_r2_tail -- the tail copy did not run, or ran wrong"
fi
r4len="$(cell R4 1 "$BASE")"
if [ "$r4len" = "16" ]; then
  ok "R4: an eight-byte mask against a sixteen-byte span still yields sixteen bytes"
else
  bad "R4's output length is $r4len, the destination's is 16"
fi
r5len="$(cell R5 1 "$BASE")"
if [ "$r5len" = "7680" ]; then
  ok "R5: the 1920-pixel span completes and its output is 7,680 bytes"
else
  bad "R5's output length is $r5len, expected 7680"
fi

# ---- G5 --------------------------------------------------------------------
echo
echo "=== E200 G5: sixteen spans, weighed on the arena's own cursor ==="
if build "$CC" "$REPO/lib" "$GP" "e200-g5-bover.prog" "$TMP/g5b.elf" \
   && build "$CC" "$REPO/lib" "$GP" "e200-g5-bcat.prog" "$TMP/g5c.elf" \
   && ( ulimit -s unlimited; "$TMP/g5b.elf" >"$TMP/g5b.out" 2>/dev/null ) \
   && ( ulimit -s unlimited; "$TMP/g5c.elf" >"$TMP/g5c.out" 2>/dev/null ); then
  ab="$(awk '$2=="bover"{print $4}' "$TMP/g5b.out")"
  ac="$(awk '$2=="bcat"{print $4}' "$TMP/g5c.out")"
  fb="$(awk '$2=="bover"{print $3}' "$TMP/g5b.out")"
  fc="$(awk '$2=="bcat"{print $3}' "$TMP/g5c.out")"
  note "bover allocated $ab bytes (the composite's own cells are $WANT_BOVER); bcat allocated $ac (arithmetic: $WANT_BCAT)"
  if [ -n "$ab" ] && [ "$ab" -lt "$(( ARENA / 8 ))" ]; then
    ok "sixteen spans through bover fit inside an eighth of the $ARENA-byte arena"
  else
    bad "the bover route allocated $ab bytes, an eighth of the arena is $(( ARENA / 8 ))"
  fi
  if [ -n "$ac" ] && [ "$ac" -ge "$WANT_BCAT" ]; then
    ok "the same sixteen through bcat per pixel allocate at least $WANT_BCAT bytes, so the arena must grow"
  else
    bad "the bcat control allocated $ac bytes, the arithmetic says at least $WANT_BCAT"
  fi
  if [ -n "$ab" ] && [ "$ab" -gt 0 ] && [ "$(( ac / ab ))" -ge 8 ]; then
    ok "the ratio is $(( ac / ab ))x, at or past the SPEC's one-eighth threshold"
  else
    bad "the ratio is $(( ac / ab ))x, under the SPEC's one-eighth threshold"
  fi
  if [ -n "$fb" ] && [ "$fb" = "$fc" ]; then
    note "the two routes agree on the fold ($fb) -- bover against an independent surface implementation"
  else
    note "the two routes' folds read bover=$fb bcat=$fc (ungraded: G5 weighs memory, not arithmetic)"
  fi
else
  bad "a G5 root did not compile or did not run"
fi

# ---- G6 --------------------------------------------------------------------
echo
echo "=== E200 G6: both halves of the pair are reachable alone ==="
if build "$CC" "$REPO/lib" "$GP" "e200-g6-fill.prog" "$TMP/g6r.elf" \
   && ( ulimit -s unlimited; "$TMP/g6r.elf" >"$TMP/g6r.out" 2>/dev/null ); then
  got="$(awk '$2=="fill"{print $3}' "$TMP/g6r.out")"
  if [ "$got" = "010203040102030401020304" ]; then
    ok "a root naming only brepeat compiles and runs (fill: $got)"
  else
    bad "the brepeat-only root printed $got, expected 010203040102030401020304"
  fi
else
  bad "the brepeat-only root did not compile or did not run"
fi
if build "$CC" "$REPO/lib" "$GP" "e200-g6-comp.prog" "$TMP/g6o.elf" \
   && ( ulimit -s unlimited; "$TMP/g6o.elf" >"$TMP/g6o.out" 2>/dev/null ); then
  got="$(awk '$2=="comp"{print $3}' "$TMP/g6o.out")"
  if [ "$got" = "$want_col" ]; then
    ok "a root naming only bover compiles and runs (composite: $got)"
  else
    bad "the bover-only root printed $got, expected $want_col"
  fi
else
  bad "the bover-only root did not compile or did not run"
fi
if grep -q 'bover' "$GP/e200-g6-fill.prog" || grep -q 'brepeat' "$GP/e200-g6-comp.prog"; then
  bad "the two G6 roots are not disjoint -- one names the other's primitive"
else
  ok "neither G6 root mentions the other's primitive anywhere in its text"
fi

# ============================================================================
# the mutants
# ============================================================================

echo
echo "=== E200 M1: the coverage term dropped ==="
# nb-bover-go's five multiplies by r9 (the mask byte) become multiplies by r14
# (the constant 255), so every pixel composites at full coverage.
if mutlib M1 lib/lowering/tal/bytes.chiral \
     '/ti-fn "nb-bover-go"/,/^(def nb-bover-t/ s/(ti-prim \([0-9]*\) (op-mul) \([0-9]*\) 9)/(ti-prim \1 (op-mul) \2 14)/' \
   && gen "$MUTLIB" "$TMP/m1.cc" \
   && build "$TMP/m1.cc" "$MUTLIB" "$REPO/prog" "$PROBE" "$TMP/m1.elf" \
   && rows "$TMP/m1.elf" "$TMP/m1.out"; then
  verdict "M1" "R1 R2 R4 R5 " "$(moved "$BASE" "$TMP/m1.out")"
  note "M1 rows: $(tr '\n' '|' <"$TMP/m1.out")"
else
  bad "M1 did not produce five rows -- the mutant must RUN to convict"
fi

echo
echo "=== E200 M2: the tail copy suppressed ==="
# the shorter-mask arm's nb-copy length becomes zero, so the bytes past the
# extent are left as the allocator found them.  Only R2 takes that arm: R1, R3,
# R4 and R5 all have blen mask >= blen dst / 4 and take the other one, whose
# remainder is zero anyway.
if mutlib M2 lib/lowering/tal/bytes.chiral \
     's/(ti-prim 14 (op-sub) 5 13)/(ti-prim 14 (op-sub) 13 13)/' \
   && gen "$MUTLIB" "$TMP/m2.cc" \
   && build "$TMP/m2.cc" "$MUTLIB" "$REPO/prog" "$PROBE" "$TMP/m2.elf" \
   && rows "$TMP/m2.elf" "$TMP/m2.out"; then
  verdict "M2" "R2 " "$(moved "$BASE" "$TMP/m2.out")"
  note "M2 rows: $(tr '\n' '|' <"$TMP/m2.out")"
else
  bad "M2 did not produce five rows -- the mutant must RUN to convict"
fi

echo
echo "=== E200 M3: the prim2lib row dropped ==="
if mutlib M3 lib/lowering/tal/erase.chiral \
     '/(cons (pair "bover" "nb-bover")/d' \
     's/^    nil)))))))))))))))))))))))))$/    nil))))))))))))))))))))))))/' \
   && gen "$MUTLIB" "$TMP/m3.cc"; then
  if build "$TMP/m3.cc" "$MUTLIB" "$REPO/prog" "$PROBE" "$TMP/m3.elf" "$TMP/m3.err"; then
    bad "M3: the probe still compiled with the bover rewrite row deleted"
  else
    if grep -q 'extern does not lower: bover' "$TMP/m3.err"; then
      ok "M3 reddens G1: 'compile-main: extern does not lower: bover', the rewrite table is load-bearing"
    else
      bad "M3 refused, but not naming bover -- got: $(tr '\n' ' ' <"$TMP/m3.err" | head -c 300)"
    fi
  fi
else
  bad "M3 could not be built"
fi

echo
echo "=== E200 M4: the fixture's R1 mask collapsed, no rebuild ==="
MP="$TMP/mprog"; rm -rf "$MP"; cp -a "$REPO/prog" "$MP"
if sed -i 's/^                   (cover (e200-quad 0 85 170 255))$/                   (cover (e200-quad 255 255 255 255))/' \
     "$MP/$PROBE" \
   && ! cmp -s "$MP/$PROBE" "$ROOT" \
   && build "$CC" "$REPO/lib" "$MP" "$PROBE" "$TMP/m4.elf" \
   && rows "$TMP/m4.elf" "$TMP/m4.out"; then
  verdict "M4" "R1 " "$(moved "$BASE" "$TMP/m4.out")"
  note "M4 rows: $(tr '\n' '|' <"$TMP/m4.out")"
else
  bad "M4 did not mutate, did not compile, or did not produce five rows"
fi

echo
echo "=== E200 M5: the extent collapsed ==="
# nb-bover-go's termination `i == n` becomes `i < n`, and Bool at this floor is
# the enum tag 0=true 1=false, so the tag-0 arm is the arm where the comparison
# HOLDS: the loop returns on its first step and no pixel is composited.  The
# address range pins the edit to nb-bover-go, because nb-copy carries the same
# `(ti-prim 6 (op-eqi) 4 5)`.
if mutlib M5 lib/lowering/tal/bytes.chiral \
     '/ti-fn "nb-bover-go"/,/^(def nb-bover-t/ s/(ti-prim 6 (op-eqi) 4 5)/(ti-prim 6 (op-lti) 4 5)/' \
   && gen "$MUTLIB" "$TMP/m5.cc" \
   && build "$TMP/m5.cc" "$MUTLIB" "$REPO/prog" "$PROBE" "$TMP/m5.elf" \
   && rows "$TMP/m5.elf" "$TMP/m5.out"; then
  verdict "M5" "R1 R2 R3 R4 R5 " "$(moved "$BASE" "$TMP/m5.out")"
  note "M5 rows: $(tr '\n' '|' <"$TMP/m5.out")"
else
  bad "M5 did not produce five rows -- the mutant must RUN to convict"
fi

# ============================================================================
echo
echo "=== E200: the SPEC's over-extent, run and UNGRADED ==="
# `stop when i == n` becomes `stop when n < i`, so the loop runs for i = 0..n
# inclusive: the SPEC's M2, one pixel past the extent.  It is run here and
# graded by nothing, because it moves nothing and the reason is structural.
if mutlib OVER lib/lowering/tal/bytes.chiral \
     '/ti-fn "nb-bover-go"/,/^(def nb-bover-t/ s/(ti-prim 6 (op-eqi) 4 5)/(ti-prim 6 (op-lti) 5 4)/' \
   && gen "$MUTLIB" "$TMP/ov.cc" \
   && build "$TMP/ov.cc" "$MUTLIB" "$REPO/prog" "$PROBE" "$TMP/ov.elf" \
   && rows "$TMP/ov.elf" "$TMP/ov.out"; then
  m="$(moved "$BASE" "$TMP/ov.out")"
  if [ -z "$m" ]; then
    note "n + 1 moves NO row: the over-run lands inside the copied remainder or past the output cell, and neither is printed"
  else
    note "n + 1 moved [$m] -- the structural argument above is wrong and this row owes a grade"
  fi
else
  note "the over-extent generation did not build or the probe faulted under it"
fi

echo
echo "=== E200: the E145 placement, printed and UNGRADED ==="
# native-lib's list position IS the runtime routine's address (bytes.chiral
# :643-644).  This builds one generation with nb-bover-go-t and nb-bover-t
# spliced BEFORE nb-bfind-from-t instead of appended after nb-be-close-t, and
# prints whether the ELF differs and whether the five rows are unchanged.  The
# expected reading is that the bytes differ and the behaviour does not, because
# a full rebuild regenerates every call site from the same list.
if mutlib PLACE lib/lowering/tal/bytes.chiral \
     's/^  (cons nb-bfind-from-t (cons nb-bfind-t (cons nb-be-peek-t (cons nb-be-close-t$/  (cons nb-bover-go-t (cons nb-bover-t/' \
     's/^  (cons nb-bover-go-t (cons nb-bover-t nil)/  (cons nb-bfind-from-t (cons nb-bfind-t (cons nb-be-peek-t (cons nb-be-close-t nil)/' \
   && gen "$MUTLIB" "$TMP/pl.cc" \
   && build "$TMP/pl.cc" "$MUTLIB" "$REPO/prog" "$PROBE" "$TMP/pl.elf" \
   && rows "$TMP/pl.elf" "$TMP/pl.out"; then
  if cmp -s "$TMP/pl.elf" "$TMP/base.elf"; then
    note "spliced-early and appended-last emit the SAME bytes"
  else
    note "spliced-early and appended-last emit DIFFERENT bytes, at the same $(wc -c <"$TMP/pl.elf") length"
  fi
  if cmp -s "$TMP/pl.out" "$BASE"; then
    note "and the five rows are unchanged -- a full rebuild regenerated every call site"
  else
    note "and the five rows MOVED: $(moved "$BASE" "$TMP/pl.out")"
  fi
else
  note "the spliced-early generation did not build or did not run (nothing is graded on it)"
fi

echo
echo "span-over: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
