#!/usr/bin/env bash
# mul-widen.sh -- the E189 gate: the widening multiply's two names, `mulhi`
# signed and `mulhu` unsigned, judged over six rows and four mutants.
#
# suite phase: registered 2026-09-08. run-tests.sh is the authority for the
# number; 29, 30 and 31 were taken by encoding.sh, recording.sh and crypto.sh,
# so 32 is the first free one.
#
# ⚑ THE PROBE ASSERTS NOTHING. `prog/e189-widening-multiply.prog` prints six
# lines and exits 0. Every comparison lives here, in bash, on the pretty.sh /
# tal-check.sh rule: a probe that derives its own verdict is green under any
# mutant that changes what the verdict says.
#
# ⚑ THE FIELDS ARE 16 HEX NIBBLES AND THAT IS MEASURED, NOT STYLE. The SPEC
# says `i64->str` prints the operands. It does not: R6's operand is 2^63 and
# `(put (i64->str (shl 1 63)))` SEGFAULTS under the promoted compiler. The
# defect predates E189 and belongs to `i64->str`, not to the multiply, so the
# probe prints unsigned hex and `$((16#...))` reads it back here as a wrapped
# 64-bit value -- which is the arithmetic G4 needs anyway.
#
# ─── THE SIX ROWS ───────────────────────────────────────────────────────────
#
#   G1  the probe resolves, compiles to a non-empty ELF, exits 0, six rows
#   G2  R1 and R2 AGREE -- both operands non-negative, so the two readings
#       coincide, and a row where they differ convicts one of the two arms
#   G3  R3 to R6 DISAGREE, over THREE distinct (mulhi,mulhu) pairs, with R3
#       and R4 carrying the same pair because they are the same product with
#       its operands swapped
#   G4  every row satisfies the wrapping identity, computed here from the
#       row's OWN operands with no golden read:
#           mulhi == mulhu - (a < 0 ? b : 0) - (b < 0 ? a : 0)   (mod 2^64)
#   G5  BOTH call forms are emitted, read out of the probe's own bytes
#   G6  `prog/compiler.prog`'s blob holds no `mulhu` CALL SITE, AND a copied
#       lib/ with one spliced in makes the same scan see it arrive
#
# ⚑ G3 PINS THREE DISTINCT PAIRS, NOT FOUR, AND THE SPEC SAYS FOUR. The SPEC's
# §4 prose reads "each disagreement is a different pair of values", but its own
# six-row table gives R3 (-1*3) and R4 (3*-1) the same answers -- (-1, 2) both
# times -- because they are one product with its operands swapped. The prose and
# the table disagree and the table is the one the rows were built from, so this
# row pins what is true: four disagreements over three distinct pairs, R3 and R4
# equal. Pinning the count still convicts a collapse, which drives it to one.
# Measured 2026-09-08 by the implementation run.
#
# ⚑ G4 CONVICTS A ROW A PINNED TABLE CANNOT. A golden cut by running the code
# pins a wrong answer as correct for good. G4 never reads a golden: it derives
# `mulhi` from `mulhu` and the row's two operands, in bash `$(( ))`, which is
# 64-bit two's complement and wraps. `a = A - 2^64*[a<0]` over the unsigned word
# `A`, so `a*b = A*B - 2^64(s_a*B + s_b*A) + 2^128*s_a*s_b` and dividing by
# 2^64 leaves `mulhu - s_a*B - s_b*A` in the low 64 bits. This is encoding.sh's
# G2-beside-G3 shape (tools/test/encoding.sh:24-32).
#
# ⚑ G5 READS BYTES BECAUSE THE PROBE'S OUTPUT CANNOT SETTLE IT. The register
# arm (mach.chiral:379) and the immediate arm (mach.chiral:1031) are two arms
# and two clobber keys, and which one the compiler took is emit-instr's
# decision (lowering/mach/emit-core.chiral:152-161), made on whether the SECOND
# operand resolves to a tracked constant. Nothing the probe prints distinguishes
# them. The immediate arm materializes through `x-mov-rcx-imm`, which is `48 B9`
# and an 8-byte immediate, so an immediate-form `48 F7 E1` has `48 B9` exactly
# ten bytes before it and a register-form one does not. G5 counts both columns
# and fails on a zero in either.
#
# ⚑ G6 IS ONE ROW WITH TWO HALVES, on render-doc.sh's G9-plus-M11 precedent
# (tools/test/render-doc.sh:558-580). A scan for a needle that matches nothing
# anywhere passes by looking at nothing, so the negative half is checked beside
# a positive one over a copied lib/ with a `mulhu` call spliced into the
# prelude. G6 is what the SPEC's `C1 == C2` fixpoint prediction rests on.
#
# ─── THE FOUR MUTANTS ───────────────────────────────────────────────────────
#
#   M1  mulhu-emits-imul       `x-mul-rcx-1op`'s E1 becomes E9
#   M2  mulhi-emits-mul        `x-imul-rcx-1op`'s E9 becomes E1
#   M3  clobber-key-dropped    the `bin:mulhu`/`bini:mulhu` test is removed
#   M4  probe-calls-mulhi-twice   the probe's `mulhu` calls become `mulhi`
#
# ⚑ M1, M2 AND M3 EACH REBUILD ONE COMPILER GENERATION. A mutated lib/ alone
# proves nothing here: the probe is compiled by a binary that embeds the OLD
# backend, so a driver that only mutated lib/ would run four green mutants
# against an unchanged compiler. Each of the three assembles prog/compiler.prog
# from the mutated lib/, builds ONE generation with the promoted binary, and
# compiles the probe with THAT generation. One generation is about 2 s here.
#
# ⚑ EACH MUTANT PINS THE WHOLE SET OF ROWS IT MOVES. records/gate-audit.md
# GA-21 and GA-22 both convict a gate naming one row per mutant: a mutant
# reddening a row outside its own pin is then invisible. A green mutant row here
# says the blast radius was exactly the arm.
#
# ⚑ M3 IS A LADDER OF THREE RUNGS AND ONLY THE THIRD CONVICTS. Dropping the
# clobber key is a SILENT MISCOMPILE, not a build failure: `x64-clobbers` falls
# through to `clb-rcx` = {3} and the allocator believes `rdx` survives a `mul`
# that writes RDX:RAX. Whether that bites depends on register pressure. Rungs 1
# and 2 MEASURE whether it does -- the probe as written, then a probe holding
# eight values live across two multiplies -- and both were measured on
# 2026-09-08 to leave the emitted ELF BYTE-IDENTICAL. They are printed as notes,
# not graded, because a row asserting "M3 does not move the probe" would go red
# on a future allocator that made it move, which is not a defect. Rung 3 is the
# graded row: `x64-clobbers` is a pure function of the key string
# emit-core.chiral:156-161 builds, so M3 changes its answer for `bin:mulhu` and
# `bini:mulhu` from {2,3} to {3} BY CONSTRUCTION, whatever the allocator does.
# A `prog/` probe importing `lowering/x64/mach` reads that answer directly; the
# SPEC left the collision question open and this run measured it: `mach` imports
# clean from a root, no E154 collision.
#
# ⚑ M4 CONVICTS THE GOLDEN, NOT THE BACKEND. It rebuilds no compiler. It proves
# G3's four rows are load-bearing and that the probe's two columns come from two
# different primitives rather than one printed twice.

set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CC="${CHIRALITY_COMPILE:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
[ -x "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
# shellcheck disable=SC1091
. "$REPO/bin/chirality-resolve.sh"

PROBE="e189-widening-multiply.prog"
ROOT="$REPO/prog/$PROBE"
MACH="$REPO/lib/lowering/x64/mach.chiral"
for f in "$ROOT" "$MACH"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its fixture cannot fail"; exit 2; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()   { echo "  ok    $1"; pass=$((pass+1)); }
bad()  { echo "  FAIL  $1"; fail=$((fail+1)); }
note() { echo "  note  $1"; }

# ---- helpers ---------------------------------------------------------------

# mutlib NAME REPO-REL-PATH SED-EXPR... -> a scratch copy of lib/ with that file
# mutated, left in $MUTLIB.  render-doc.sh:131-145 verbatim, including its two
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

# build COMPILER LIBDIR PROGDIR ROOTFILE ELF -> compile a root with COMPILER.
build() {
  local cc="$1" libdir="$2" progdir="$3" rootf="$4" elf="$5"
  ( cd "$REPO" && chirality_blob_file "$libdir:$progdir" "$progdir/$rootf" ) \
    >"$TMP/b.blob" 2>/dev/null || return 1
  [ -s "$TMP/b.blob" ] || return 1
  ( ulimit -s unlimited; "$cc" <"$TMP/b.blob" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
}

# rows ELF OUT -> run it, keep only the six ==E189== lines
rows() {
  ( ulimit -s unlimited; "$1" >"$TMP/r.raw" 2>/dev/null ) || return 1
  grep '^==E189== ' "$TMP/r.raw" >"$2" || return 1
  [ "$(wc -l <"$2")" -eq 6 ]
}

# cell ROW FIELD FILE -> field N of the row tagged ROW (1=a 2=b 3=mulhi 4=mulhu)
cell() { awk -v t="$1" -v n="$2" '$2==t{print $(2+n)}' "$3"; }

# moved BASE MUT -> the tags whose whole line differs, space separated
moved() {
  local t
  for t in R1 R2 R3 R4 R5 R6; do
    [ "$(grep " $t " "$1")" = "$(grep " $t " "$2")" ] || printf '%s ' "$t"
  done
}

# forms ELF -> "IMM REG": occurrences of `48 F7 E1` with and without a
# `48 B9` exactly ten bytes earlier.
forms() {
  od -An -tx1 -v "$1" | tr -s ' ' '\n' | grep -v '^$' | awk '
    {b[NR]=$1}
    END{ imm=0; reg=0
      for(i=1;i<=NR-2;i++)
        if(b[i]=="48"&&b[i+1]=="f7"&&b[i+2]=="e1"){
          if(i>=11&&b[i-10]=="48"&&b[i-9]=="b9") imm++; else reg++ }
      print imm, reg }'
}

# ============================================================================
echo "=== E189 G1: the probe compiles, runs and prints six rows ==="
BASE="$TMP/base.out"
if build "$CC" "$REPO/lib" "$REPO/prog" "$PROBE" "$TMP/base.elf" && rows "$TMP/base.elf" "$BASE"; then
  ok "the probe compiles to a non-empty ELF, exits 0 and prints six rows"
else
  bad "the probe did not compile, did not run, or did not print six rows"
  echo; echo "mul-widen: $pass passed, $fail failed"; exit 1
fi

# ---- G2 --------------------------------------------------------------------
echo
echo "=== E189 G2: R1 and R2 agree ==="
g2=""
for t in R1 R2; do
  hi="$(cell "$t" 3 "$BASE")"; hu="$(cell "$t" 4 "$BASE")"
  [ "$hi" = "$hu" ] || g2="$g2$t "
done
if [ -z "$g2" ]; then ok "R1 and R2: both operands non-negative, both readings coincide"
else bad "R1/R2 disagree on [$g2] -- one of the two arms is wrong on non-negative operands"; fi

# ---- G3 --------------------------------------------------------------------
echo
echo "=== E189 G3: R3 to R6 disagree, over three distinct pairs ==="
g3=""; pairs=""
for t in R3 R4 R5 R6; do
  hi="$(cell "$t" 3 "$BASE")"; hu="$(cell "$t" 4 "$BASE")"
  [ "$hi" != "$hu" ] || g3="$g3$t "
  pairs="$pairs$hi/$hu"$'\n'
done
d="$(printf '%s' "$pairs" | sort -u | grep -c .)"
swap=no
[ "$(cell R3 3 "$BASE")/$(cell R3 4 "$BASE")" = "$(cell R4 3 "$BASE")/$(cell R4 4 "$BASE")" ] && swap=yes
if [ -z "$g3" ] && [ "$d" -eq 3 ] && [ "$swap" = yes ]; then
  ok "R3 to R6 each disagree, over three distinct (mulhi,mulhu) pairs, R3 and R4 equal under the operand swap"
else
  bad "R3-R6: agreeing rows [$g3], distinct pairs $d (want 3), R3==R4 $swap (want yes)"
fi

# ---- G4 --------------------------------------------------------------------
echo
echo "=== E189 G4: the wrapping identity, from each row's own operands ==="
g4=""
for t in R1 R2 R3 R4 R5 R6; do
  A=$((16#$(cell "$t" 1 "$BASE"))); B=$((16#$(cell "$t" 2 "$BASE")))
  HI=$((16#$(cell "$t" 3 "$BASE"))); HU=$((16#$(cell "$t" 4 "$BASE")))
  sa=0; sb=0
  [ "$A" -lt 0 ] && sa=$B
  [ "$B" -lt 0 ] && sb=$A
  W=$(( HU - sa - sb ))
  [ "$W" -eq "$HI" ] || g4="$g4$t "
done
if [ -z "$g4" ]; then ok "all six rows: mulhi == mulhu - (a<0?b:0) - (b<0?a:0), mod 2^64, golden unread"
else bad "the identity fails on [$g4]"; fi

# ---- G5 --------------------------------------------------------------------
echo
echo "=== E189 G5: both call forms are emitted ==="
read -r IMM REG <<<"$(forms "$TMP/base.elf")"
if [ "$IMM" -ge 1 ] && [ "$REG" -ge 1 ]; then
  ok "the probe's bytes carry $IMM immediate-form and $REG register-form \`48 F7 E1\`"
else
  bad "call forms: $IMM immediate, $REG register -- a zero column means one arm is untested"
fi

# ---- G6 --------------------------------------------------------------------
echo
echo "=== E189 G6: prog/compiler.prog's blob holds no mulhu call site ==="
# Assembled, so this row does not match its own source line.
NEEDLE="(mulhu "
blob_has() {
  ( cd "$REPO" && chirality_blob_file "$1:$REPO/prog" prog/compiler.prog ) 2>/dev/null \
    | grep -c -F -- "$NEEDLE"
}
BASEHITS="$(blob_has "$REPO/lib")"
if [ "$BASEHITS" -eq 0 ]; then
  if mutlib "G6 splice-a-mulhu-call" lib/prelude/prelude.chiral \
       's|^(extern mulhu (-> I64 I64 I64)).*$|&\n(def e189-blob-witness (-> I64 I64) (lam (x) (mulhu x 3)))|'; then
    if [ "$(blob_has "$MUTLIB")" -ge 1 ]; then
      ok "the compiler blob holds zero mulhu call sites, and a spliced one is seen to arrive"
    else
      bad "the closure scan is blind -- it would pass on any needle"
    fi
  fi
else
  bad "prog/compiler.prog's blob holds $BASEHITS mulhu call sites -- the C1==C2 prediction no longer holds"
fi

# ============================================================================
echo
echo "=== E189 mutants ==="

# ---- M1 --------------------------------------------------------------------
if mutlib "M1 mulhu-emits-imul" lib/lowering/x64/mach.chiral \
     's|(def x-mul-rcx-1op Bytes (bc3 (b1 72) (b1 247) (b1 225)))|(def x-mul-rcx-1op Bytes (bc3 (b1 72) (b1 247) (b1 233)))|'; then
  if gen "$MUTLIB" "$TMP/m1.cc" && build "$TMP/m1.cc" "$REPO/lib" "$REPO/prog" "$PROBE" "$TMP/m1.elf" \
       && rows "$TMP/m1.elf" "$TMP/m1.out"; then
    MV="$(moved "$BASE" "$TMP/m1.out")"
    if [ "$MV" = "R3 R4 R5 R6 " ]; then
      ok "M1 mulhu-emits-imul -- R3 to R6 collapse to agreement, R1 and R2 stand: moved [$MV]"
    else
      bad "M1 mulhu-emits-imul -- moved [$MV], want [R3 R4 R5 R6 ]"
    fi
  else bad "M1 mulhu-emits-imul -- the mutated tree did not build or run"; fi
fi

# ---- M2 --------------------------------------------------------------------
if mutlib "M2 mulhi-emits-mul" lib/lowering/x64/mach.chiral \
     's|(def x-imul-rcx-1op Bytes (bc3 (b1 72) (b1 247) (b1 233)))|(def x-imul-rcx-1op Bytes (bc3 (b1 72) (b1 247) (b1 225)))|'; then
  if gen "$MUTLIB" "$TMP/m2.cc" && build "$TMP/m2.cc" "$REPO/lib" "$REPO/prog" "$PROBE" "$TMP/m2.elf" \
       && rows "$TMP/m2.elf" "$TMP/m2.out"; then
    MV="$(moved "$BASE" "$TMP/m2.out")"
    if [ "$MV" = "R3 R4 R5 R6 " ]; then
      ok "M2 mulhi-emits-mul -- the same four rows move the other way: moved [$MV]"
    else
      bad "M2 mulhi-emits-mul -- moved [$MV], want [R3 R4 R5 R6 ]"
    fi
  else bad "M2 mulhi-emits-mul -- the mutated tree did not build or run"; fi
fi

# ---- M3, three rungs -------------------------------------------------------
mkdir -p "$TMP/prog"
cat >"$TMP/prog/live.prog" <<'LIVE'
; M3 rung 2: eight values held live across two multiplies. If dropping the
; clobber key let the allocator park one of them in rdx, this sum moves.
(import "prelude/prelude")
(import "ports/stdio")
(declare e189-hide (-> I64 I64 I64))
(def e189-hide (lam (n x) (bor (band n 0) x)))
(def compile-main (=> I64 I64)
  (lam (n)
    (let (v1 (e189-hide n 11))
    (let (v2 (e189-hide n 22))
    (let (v3 (e189-hide n 33))
    (let (v4 (e189-hide n 44))
    (let (v5 (e189-hide n 55))
    (let (v6 (e189-hide n 66))
    (let (m1 (mulhu (- 0 1) 3))
    (let (m2 (mulhu (e189-hide n (shl 1 32)) (e189-hide n (shl 1 32))))
      (do (put (str-cat "==LIVE== " (str-cat (i64->str (+ v1 (+ v2 (+ v3 (+ v4 (+ v5 (+ v6 (+ m1 m2)))))))) "\n")))
      0)))))))))))
LIVE
cat >"$TMP/prog/clb.prog" <<'CLB'
; M3 rung 3: x64-clobbers' own answer, read straight out of the module under
; mutation. It is a pure function of the key string emit-core.chiral:156-161
; builds, so this row convicts M3 whatever the allocator does with rdx.
(import "prelude/prelude")
(import "lowering/x64/mach")
(import "ports/stdio")
(declare e189-clb-show (-> (List I64) Str))
(def e189-clb-show (lam (xs)
  (case xs
    (nil "")
    ((cons h t) (str-cat (i64->str h) (str-cat "," (e189-clb-show t)))))))
(def compile-main (=> I64 I64)
  (lam (n)
    (do (put (str-cat "==CLB== bin:mulhu " (str-cat (e189-clb-show (x64-clobbers "bin:mulhu")) "\n")))
    (do (put (str-cat "==CLB== bini:mulhu " (str-cat (e189-clb-show (x64-clobbers "bini:mulhu")) "\n")))
    (do (put (str-cat "==CLB== bin:mulhi " (str-cat (e189-clb-show (x64-clobbers "bin:mulhi")) "\n")))
    0)))))
CLB

M3SED_A='/(or (str-eq k "bin:mulhu")/d'
M3SED_B='s|(or (str-eq k "bini:mulhi")$|(or (str-eq k "bini:mulhi") (str-eq k "bpt")))|'

if mutlib "M3 clobber-key-dropped" lib/lowering/x64/mach.chiral "$M3SED_A" "$M3SED_B"; then
  M3LIB="$TMP/m3lib"; rm -rf "$M3LIB"; cp -a "$MUTLIB" "$M3LIB"

  # rung 1: the probe as written.
  if gen "$M3LIB" "$TMP/m3.cc" && build "$TMP/m3.cc" "$REPO/lib" "$REPO/prog" "$PROBE" "$TMP/m3.elf" \
       && rows "$TMP/m3.elf" "$TMP/m3.out"; then
    MV="$(moved "$BASE" "$TMP/m3.out")"
    if [ -n "$MV" ]; then note "M3 rung 1 -- the probe as written MOVES: [$MV]"
    else note "M3 rung 1 -- the probe as written does not move (register pressure never puts a live value in rdx)"; fi
  else note "M3 rung 1 -- the mutated tree did not build or run"; fi

  # rung 2: eight values held live across two multiplies.
  if build "$TMP/m3.cc" "$REPO/lib" "$TMP/prog" "live.prog" "$TMP/m3live.elf" \
       && build "$CC" "$REPO/lib" "$TMP/prog" "live.prog" "$TMP/baselive.elf"; then
    LB="$( ulimit -s unlimited; "$TMP/baselive.elf" 2>/dev/null )"
    LM="$( ulimit -s unlimited; "$TMP/m3live.elf" 2>/dev/null )"
    if [ "$LB" != "$LM" ]; then note "M3 rung 2 -- the enlarged probe MOVES: base [$LB] mutant [$LM]"
    else note "M3 rung 2 -- the enlarged probe does not move either: both [$LB]"; fi
  else note "M3 rung 2 -- the enlarged probe did not build or run"; fi

  # rung 3: x64-clobbers' own answer, the deterministic one.
  if build "$CC" "$REPO/lib" "$TMP/prog" "clb.prog" "$TMP/baseclb.elf" \
       && build "$CC" "$M3LIB" "$TMP/prog" "clb.prog" "$TMP/m3clb.elf"; then
    CB="$( ulimit -s unlimited; "$TMP/baseclb.elf" 2>/dev/null | grep '^==CLB== bin:mulhu ' )"
    CM="$( ulimit -s unlimited; "$TMP/m3clb.elf"   2>/dev/null | grep '^==CLB== bin:mulhu ' )"
    IB="$( ulimit -s unlimited; "$TMP/baseclb.elf" 2>/dev/null | grep '^==CLB== bini:mulhu ' )"
    IM="$( ulimit -s unlimited; "$TMP/m3clb.elf"   2>/dev/null | grep '^==CLB== bini:mulhu ' )"
    HB="$( ulimit -s unlimited; "$TMP/baseclb.elf" 2>/dev/null | grep '^==CLB== bin:mulhi ' )"
    HM="$( ulimit -s unlimited; "$TMP/m3clb.elf"   2>/dev/null | grep '^==CLB== bin:mulhi ' )"
    if [ "$CB" = "==CLB== bin:mulhu 2,3," ] && [ "$CM" = "==CLB== bin:mulhu 3," ] \
       && [ "$IB" = "==CLB== bini:mulhu 2,3," ] && [ "$IM" = "==CLB== bini:mulhu 3," ] \
       && [ "$HB" = "$HM" ]; then
      ok "M3 clobber-key-dropped -- x64-clobbers answers {2,3} for both mulhu keys and {3} under the mutant, with bin:mulhi untouched"
    else
      bad "M3 clobber-key-dropped -- base [$CB / $IB / $HB] mutant [$CM / $IM / $HM]"
    fi
  else bad "M3 clobber-key-dropped -- the rung-3 probe did not build or run"; fi
fi

# ---- M4 --------------------------------------------------------------------
# A scratch prog/, never lib/: this mutant convicts the golden, not the backend,
# and it rebuilds no compiler.
M4PROG="$TMP/m4prog"; rm -rf "$M4PROG"; cp -a "$REPO/prog" "$M4PROG"
if [ -L "$M4PROG" ]; then
  bad "M4 probe-calls-mulhi-twice -- the scratch prog/ is a SYMLINK"
else
  sed -i 's|(mulhu |(mulhi |g' "$M4PROG/$PROBE"
  if cmp -s "$M4PROG/$PROBE" "$ROOT"; then
    bad "M4 probe-calls-mulhi-twice -- the mutation did not change the probe (stale pattern)"
  elif build "$CC" "$REPO/lib" "$M4PROG" "$PROBE" "$TMP/m4.elf" && rows "$TMP/m4.elf" "$TMP/m4.out"; then
    MV="$(moved "$BASE" "$TMP/m4.out")"
    if [ "$MV" = "R3 R4 R5 R6 " ]; then
      ok "M4 probe-calls-mulhi-twice -- every disagreement row collapses: moved [$MV]"
    else
      bad "M4 probe-calls-mulhi-twice -- moved [$MV], want [R3 R4 R5 R6 ]"
    fi
  else bad "M4 probe-calls-mulhi-twice -- the mutated probe did not build or run"; fi
fi

echo
echo "mul-widen: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
