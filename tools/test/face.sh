#!/usr/bin/env bash
# face.sh -- E175: a face survives its body.  The Phase 16 gate.
#
# The ANSI emitter was self-inconsistent.  `face-sgr` has always emitted a
# DELTA on the OPEN -- only the bits that are set, nothing at all for a colour
# of -1 -- and the terminal composes it over whatever is already on.  Every
# CLOSE emitted a full `\e[0m`: a REPLACEMENT.  So a faced node's SIBLING lost
# the enclosing face.
#
# ⚑ THE DEFECT IS NOT NESTING, AND THE FIX IS NOT A FACE STACK IN THE `r-face`
# ARM.  Measured, byte-exact: `(r-face "keyword" (r-row [ab cd]))` painted `cd`
# with NO SGR at all, and so did the same shape through `r-lines`, which
# predates `r-face` in the sum.  The killing reset is `r-text`'s, not
# `r-face`'s.  Six drawing sites open with an SGR and close with an
# unconditional reset, and FIVE of the six are ad-hoc `ansi-bold` the face
# registry does not know about -- a stack scoped to the `r-face` arm repairs one
# of six and passes its own review.  G2 and G3 are that finding as rows, and M3
# is the mutant that proves it: M3 PASSES any fix scoped to `r-face`.
#
# ⚑ WHAT THIS GATE GRADES, AND WHY IT NEEDS TWO KINDS OF ROW.  A rendering
# defect that is invisible on the screen cannot be graded by a shape assertion,
# and a rendering defect that is invisible in the bytes cannot be graded by a
# cell map.  E175 has BOTH.
#
#   * The live consumers are SCREEN-identical, NOT byte-identical.  A faced
#     leaf's close now restores the AMBIENT, and inside an `r-face` the ambient
#     IS that face -- so the stream gains bytes while every painted cell stays
#     put.  A row asserting byte-identity is not merely unproven here, it is
#     FALSE.  G1-G4 are therefore graded on a CELL MAP carrying the SGR
#     REGISTER SET per painted cell.
#   * A TRAILING SGR PAINTS NO CELL.  Measured: under M7 (`r-hole` restores too)
#     the cell map is byte-for-byte identical to the fixed tree's while the raw
#     stream gains `ESC[0m ESC[1m ESC[31m`.  A cell-map-only gate would call
#     this element done.  G5 and G6 are therefore RAW BYTE rows.
#
#   G1  the live shape at depth 0 is a NO-OP, on the screen      [M1,M2]
#   G2  the defect itself, through `r-row`                       [M3]
#   G3  the same defect through `r-lines`, which predates E174   [M3]
#   G4  the JOIN -- two shapes, each with a TWO-leaf inner face
#                                                        [M4,M5,M6]
#   G5  depth 0 emits exactly `\e[0m` -- RAW BYTES            [M1]
#   G6  `r-hole` is unchanged -- RAW BYTES, and this row exists
#       BECAUSE the cell map cannot see it                       [M7]
#   G7  the neighbouring gates hold: five sha256 pins, four
#       registrations, and no 7-argument caller under tools/
#                                                       [M8,M9,M13]
#   G8  the nine signatures moved TOGETHER -- three compiles
#                                                     [M10,M11,M12]
#
# ⚑ THIRTEEN mutants, not the SPEC's twelve, and the thirteenth is there for
# the reason row.sh's was: G7(c)'s arity scan was the one row here that nothing
# could redden.  M12 proves the COMPILER rejects a seven-argument caller; M13
# proves the SCANNER can SEE one.  Those are different claims and a gate that
# ran only the first would be asserting its own scanner works.
#
# ⚑ EVERY ROW CARRIES A NAMED MUTANT THAT IS RUN.  Reading a gate does not tell
# you whether it can fail; eight toothless or self-matching rows were found in
# this repo during this arc, one of them created by the language itself
# (chirality is CURRIED, so a bare seven-argument call bound to `_` is a legal
# partial application of type `(=> Face Unit)` and compiles clean -- which is
# why M12 carries a `declare`).
#
# ⚑ WHAT THIS GATE CANNOT PROVE, stated because it bounds the rows.  It grades
# the EMITTER'S OWN BYTE STREAM against the SGR state machine in `sgr_screen`,
# not against a real terminal.  It does NOT grade `rnd-cols` (E174's Phase 15
# owns that, and a row here would grade it twice -- `rnd-cols` is provably
# invariant under E175 because SGR bytes paint no cell), nor display width
# (E177), nor `r-table`'s two layouts (E178), nor whether the five ad-hoc
# `ansi-bold` faces belong in the registry (E179 -- E175 fixes their CLOSES and
# leaves them ad-hoc), nor an incremental repaint that lands inside a face
# (E180, which this element CREATES and which is unreachable today because
# `render-to-ansi-delta` is a full redraw).
#
# Zero Python -- the byte decoder is od + awk, here as everywhere.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"

CC="${CHIRALITY_COMPILE:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
[ -x "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
# shellcheck disable=SC1091
. "$REPO/bin/chirality-resolve.sh"

RND="$REPO/lib/protocol/render.chiral"
FIXTURE="$HERE/samples/e175_face.prog"
for f in "$RND" "$FIXTURE"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its fixture cannot fail"; exit 2; }
done
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# ⚑ The name is never spelled as a call in this file.  G7(c) scans tools/ for
# seven-argument applications, and this script is UNDER tools/ -- a literal
# `(<name> ` anywhere in this source would be scanned as if it were a call and
# the row would grade its own text.  Assembled from two fragments so it cannot.
RTA="render-to-""ansi"

# ---- helpers ---------------------------------------------------------------
# build_raw LIBDIR SRC OUT -> 0 and OUT holds the program's raw STDOUT.
build_raw() {
  local lib="$1" src="$2" out="$3" blob="$TMP/o.blob" elf="$TMP/o.elf"
  ( cd "$REPO" && chirality_blob_file "$lib:$REPO/prog" "$src" ) >"$blob" 2>/dev/null || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
  ( ulimit -s unlimited; "$elf" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ]
}

# build_err LIBDIR SRC -> the compiler's stderr (empty on success)
build_err() {
  local lib="$1" src="$2" blob="$TMP/be.blob"
  ( cd "$REPO" && chirality_blob_file "$lib:$REPO/prog" "$src" ) >"$blob" 2>"$TMP/be.rerr" || { cat "$TMP/be.rerr"; return; }
  ( ulimit -s unlimited; "$CC" <"$blob" >/dev/null 2>"$TMP/be.cerr" )
  cat "$TMP/be.cerr"
}

# mutlib NAME REPO-REL-PATH SED-EXPR... -> a scratch copy of lib/ with that file
# mutated, left in $MUTLIB.  A mutation that does not apply is a mutant that
# proves nothing, so a stale pattern is REPORTED rather than silently passing.
#
# ⚑ THE SCRATCH lib/ MUST BE A REAL DIRECTORY, NEVER A SYMLINK.  `cp -a` copies
# a symlink AS a symlink, and every subsequent `sed -i` then writes THROUGH it
# into the tree under test.  Measured cost during this element's spec run:
# nineteen phantom failures, including a `Rendering` that had silently grown a
# tenth constructor.  Checked here rather than remembered.
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

# ---- the SGR-TRACKING screen reducer ---------------------------------------
# The one helper row.sh does not already have.  row.sh's SCREEN_AWK treats
# `ESC[<p>m` as a DOCUMENTED NO-OP -- which is exactly what makes `rnd-cols`
# provably invariant under E175 and exactly what makes it useless for grading
# E175.  This variant tracks the SGR state and emits `row col bytes sgrset` per
# painted cell.
#
# ⚑ fg AND bg ARE SINGLE-VALUED REGISTERS, NOT MEMBERS OF A SET, and the model
# is load-bearing rather than a detail.  Measured both ways: under a naive
# set-union reducer G4 shape (a)'s first leaf reads `{1,31,32}` -- the outer's
# 31 never leaves the set when the inner emits 32 -- and every expected set in
# this gate requires the register model to come out right.
#
#   ESC[<r>;<c>H  set the cursor     ESC[H  home       ESC[2J  clear the map
#   ESC[0m / ESC[m   clear ALL attribute flags AND both colour registers
#   ESC[30m-37m / 39m   set / clear the fg REGISTER -- replaces, never accumulates
#   ESC[40m-47m / 49m   the same for bg
#   any other ESC[<n>m  set attribute flag n
#   ESC[?<n>h/l, ESC[K  ignored
#   \n            row += 1, col = 1
#   a UTF-8 CONTINUATION byte (0x80-0xBF)  appended to the current cell and
#                 DOES NOT ADVANCE the column -- one column per codepoint
#   any other byte   painted at (row, col) with the CURRENT register set; col += 1
#
# `bytes` is decimal and slash-joined, as in row.sh.  The fixture's alphabet:
#   97 a · 98 b · 99 c · 100 d · 112 p · 113 q · 119 w · 120 x · 121 y · 122 z
#   60 < · 63 ? · 62 > · 104 h
SGR_AWK='
BEGIN { st=0; par=""; r=1; c=1; nc=0; fg=""; bg="" }
function sgrset(   i,j,n,a,v,out,k) {
  n=0
  for (k in attr) if (attr[k]) a[++n]=k+0
  if (fg!="") a[++n]=fg+0
  if (bg!="") a[++n]=bg+0
  for (i=2;i<=n;i++) { v=a[i]; j=i-1; while (j>=1 && a[j]>v) { a[j+1]=a[j]; j-- } a[j+1]=v }
  out=""
  for (i=1;i<=n;i++) out = out (i>1 ? "," : "") a[i]
  return "{" out "}"
}
function paint(v,   key) { key = r "," c; if (!(key in cell)) ord[++nc]=key; cell[key]=v; sgr[key]=sgrset() }
{
  b=$1+0
  if (st==0) {
    if (b==27) { st=1 }
    else if (b==10) { r++; c=1 }
    else if (b>=128 && b<=191) { key = r "," (c-1); if (key in cell) cell[key]=cell[key] "/" b }
    else { paint(b); c++ }
  } else if (st==1) {
    if (b==91) { st=2; par="" } else { st=0 }
  } else {
    if ((b>=48 && b<=57) || b==59 || b==63) { par = par sprintf("%c", b) }
    else {
      if (b==72) {
        if (index(par,";")>0) { split(par,a,";"); r=a[1]+0; c=a[2]+0 }
        else if (par=="")     { r=1; c=1 }
        else                  { r=par+0; c=1 }
      } else if (b==74 && par=="2") {
        for (k in cell) delete cell[k]; for (k in sgr) delete sgr[k]; nc=0
      } else if (b==109 && index(par,"?")==0) {
        n=split(par, ps, ";"); if (par=="") { ps[1]="0"; n=1 }
        for (i=1;i<=n;i++) {
          v = (ps[i]=="" ? 0 : ps[i]+0)
          if (v==0)                  { for (k in attr) delete attr[k]; fg=""; bg="" }
          else if (v>=30 && v<=37)   { fg=v }
          else if (v==39)            { fg="" }
          else if (v>=40 && v<=47)   { bg=v }
          else if (v==49)            { bg="" }
          else                       { attr[v]=1 }
        }
      }
      st=0
    }
  }
}
END { for (i=1;i<=nc;i++) { k=ord[i]; if (k in cell) { split(k,p,","); print p[1], p[2], cell[k], sgr[k] } } }'

sgr_screen() {  # sgr_screen RAWFILE -> "row col bytes sgrset", sorted
  LC_ALL=C od -An -v -tu1 <"$1" | LC_ALL=C tr -s ' ' '\n' | grep -v '^$' \
    | LC_ALL=C awk "$SGR_AWK" | LC_ALL=C sort -k1,1n -k2,2n
}
band() { LC_ALL=C awk -v a="$2" -v b="$3" '$1>=a && $1<=b' "$1"; }
cell_sgr() { LC_ALL=C awk -v r="$2" -v c="$3" '$1==r && $2==c {print $4}' "$1"; }

# raw_map LIBDIR TAG -> 0 and $TMP/TAG.raw + $TMP/TAG.map exist
raw_map() {
  build_raw "$1" "$FIXTURE" "$TMP/$2.raw" || return 1
  sgr_screen "$TMP/$2.raw" >"$TMP/$2.map"
  [ -s "$TMP/$2.map" ]
}

# tail4 RAWFILE -> the final four bytes, decimal, space-joined
tailn() {
  LC_ALL=C od -An -v -tu1 <"$1" | LC_ALL=C tr -s ' ' '\n' | grep -v '^$' \
    | tail -n "$2" | tr '\n' ' ' | sed 's/ $//'
}

# hole_gap RAWFILE -> the number of bytes between the r-hole's "<?>h" (60 63 62
# 104) and the next cursor move.  ZERO on the fixed tree; three SGR sequences,
# thirteen bytes, under M7.  od + awk like every other decoder here -- no third
# language for one measurement.
GAP_AWK='
{ b[++n] = $1+0 }
END {
  s = 0
  for (i = 1; i <= n-3; i++)
    if (b[i]==60 && b[i+1]==63 && b[i+2]==62 && b[i+3]==104) { s = i+4; break }
  if (s == 0) { print "NOHOLE"; exit }
  gap = 0; i = s
  while (i <= n) {
    if (b[i]==27 && i < n && b[i+1]==91) {
      j = i + 2
      while (j <= n && ((b[j]>=48 && b[j]<=57) || b[j]==59 || b[j]==63)) j++
      if (j > n) { print "UNTERMINATED"; exit }
      if (b[j] == 72) { print gap; exit }         # ESC[<r>;<c>H -- the cursor move
      gap += (j - i + 1); i = j + 1               # any other CSI is gap
    } else { gap++; i++ }
  }
  print "NOMOVE"
}'
hole_gap() {
  LC_ALL=C od -An -v -tu1 <"$1" | LC_ALL=C tr -s ' ' '\n' | grep -v '^$' \
    | LC_ALL=C awk "$GAP_AWK"
}

# ============================================================================
# The baseline: the fixture built against the REAL lib/.
echo
echo "=== E175 G0: the fixture builds and paints ==="
if raw_map "$REPO/lib" fix; then
  ok "the E175 fixture compiles against lib/ and paints $(wc -l <"$TMP/fix.map") cells"
else
  bad "the E175 fixture did not build -- every row below is unreachable"
  echo
  echo "ambient face restore (E175): $pass passed, $fail failed"
  exit 1
fi
FIXMAP="$TMP/fix.map"

# ============================================================================
# G1 -- NO-OP WHERE THE TREE ALREADY WORKS, ON THE SCREEN.
#
# The live shape at depth 0 -- `(r-row [(r-face f (r-text "ab" b)) (r-text "cd"
# false)])` -- over the faces the fourteen live `r-face` sites actually use, in
# both the bold and the plain `r-text`.  This map is the PRE-E175 golden,
# pinned literally: at depth 0 the ambient is the plain face, `face-sgr` of it
# is "", and `(rnd-restore rnd-face-plain)` is exactly the four bytes the close
# used to emit.  Depth 0 is NOT special-cased anywhere -- the general rule IS
# the base case, which is the difference between an invariant and a guard.
#
# ⚑ THE TRAILING UNFACED SIBLING IS NOT DECORATION.  Measured at the SPEC
# audit: on the solo shape `(r-face "keyword" (r-text "ab" false))` BOTH
# mutants below produce a cell map byte-for-byte identical to the fixed tree's,
# because nothing is painted after the faced leaf for a wrong restore to touch.
echo
echo "=== E175 G1: the live shape at depth 0 is unmoved -- 5 faces x bold/plain ==="
G1_GOLDEN='11 1 97 {1,31}
11 2 98 {1,31}
11 3 99 {}
11 4 100 {}
12 1 97 {1,31}
12 2 98 {1,31}
12 3 99 {}
12 4 100 {}
13 1 97 {32}
13 2 98 {32}
13 3 99 {}
13 4 100 {}
14 1 97 {1,32}
14 2 98 {1,32}
14 3 99 {}
14 4 100 {}
15 1 97 {1,37}
15 2 98 {1,37}
15 3 99 {}
15 4 100 {}
16 1 97 {1,37}
16 2 98 {1,37}
16 3 99 {}
16 4 100 {}
17 1 97 {1,32}
17 2 98 {1,32}
17 3 99 {}
17 4 100 {}
18 1 97 {1,32}
18 2 98 {1,32}
18 3 99 {}
18 4 100 {}
19 1 97 {4,31}
19 2 98 {4,31}
19 3 99 {}
19 4 100 {}
20 1 97 {1,4,31}
20 2 98 {1,4,31}
20 3 99 {}
20 4 100 {}'
g1now="$(band "$FIXMAP" 11 20)"
if [ "$g1now" = "$G1_GOLDEN" ]; then
  ok "G1 the depth-0 live map is identical to the pre-E175 golden (40 cells, 5 faces)"
else
  bad "G1 the depth-0 live map MOVED -- E175 must be a no-op here"
  diff <(echo "$G1_GOLDEN") <(echo "$g1now") | sed 's/^/          /'
fi

# M1 plain-seed-is-bold: the depth-0 seed stops being plain, so every close at
# depth 0 re-asserts bold onto cells that must carry nothing.
if mutlib "M1 plain-seed-is-bold" lib/protocol/render.chiral \
    's|^(def rnd-face-plain Face (face "default" -1 -1 0))$|(def rnd-face-plain Face (face "default" -1 -1 1))|'; then
  if raw_map "$MUTLIB" m1; then
    m1a="$(cell_sgr "$TMP/m1.map" 11 3)"; m1b="$(cell_sgr "$TMP/m1.map" 11 4)"
    if [ "$m1a" = "{1}" ] && [ "$m1b" = "{1}" ]; then
      ok "M1 plain-seed-is-bold -- the unfaced sibling goes {} -> {1} at (11,3) and (11,4)"
    else bad "M1 plain-seed-is-bold -- the sibling did not move: (11,3)=$m1a (11,4)=$m1b"; fi
    if [ "$(band "$TMP/m1.map" 11 20)" != "$G1_GOLDEN" ]; then
      ok "M1 plain-seed-is-bold -- the whole depth-0 band leaves the golden"
    else bad "M1 plain-seed-is-bold -- the depth-0 band did NOT move; G1 grades nothing"; fi
  else bad "M1 plain-seed-is-bold -- the mutant probe did not build"; fi
fi

# M2 restore-forgets-the-reset: `rnd-restore` drops `str-cat ansi-reset` and
# emits only the ambient's SGR.  At depth 0 that is "" -- so NOTHING is ever
# cleared and the face leaks past its body for the rest of the stream.
if mutlib "M2 restore-forgets-the-reset" lib/protocol/render.chiral \
    's|^    (put (str-cat ansi-reset (face-sgr amb)))))$|    (put (face-sgr amb))))|'; then
  if raw_map "$MUTLIB" m2; then
    m2a="$(cell_sgr "$TMP/m2.map" 11 3)"
    if [ "$m2a" = "{1,31}" ]; then
      ok "M2 restore-forgets-the-reset -- the keyword leaks onto its sibling: (11,3) {} -> {1,31}"
    else bad "M2 restore-forgets-the-reset -- (11,3) reads $m2a, expected the leaked {1,31}"; fi
    if [ "$(band "$TMP/m2.map" 11 20)" != "$G1_GOLDEN" ]; then
      ok "M2 restore-forgets-the-reset -- the whole depth-0 band leaves the golden"
    else bad "M2 restore-forgets-the-reset -- the depth-0 band did NOT move"; fi
  else bad "M2 restore-forgets-the-reset -- the mutant probe did not build"; fi
fi

# ============================================================================
# G2 / G3 -- THE DEFECT ITSELF, twice, through two different containers.
#
# ⚑ Note what M3 proves.  It reverts `r-text`'s close and NOTHING ELSE, and it
# reddens both rows -- so both rows are about the leaf's close, not the face's.
# A fix scoped to the `r-face` arm PASSES M3, which is the whole reason this
# element is not the face stack the catalog row originally prescribed.
echo
echo "=== E175 G2/G3: the defect -- a faced sibling through r-row AND through r-lines ==="
g2c="$(cell_sgr "$FIXMAP" 3 3)"; g2d="$(cell_sgr "$FIXMAP" 3 4)"
if [ "$g2c" = "{1,31}" ] && [ "$g2d" = "{1,31}" ]; then
  ok "G2 through r-row: (3,3) and (3,4) carry the enclosing keyword {1,31}"
else bad "G2 through r-row: (3,3)=$g2c (3,4)=$g2d, expected {1,31} -- today they are {}"; fi
g3c="$(cell_sgr "$FIXMAP" 8 1)"; g3d="$(cell_sgr "$FIXMAP" 8 2)"
if [ "$g3c" = "{1,31}" ] && [ "$g3d" = "{1,31}" ]; then
  ok "G3 through r-lines (which PREDATES r-face): (8,1) and (8,2) carry {1,31}"
else bad "G3 through r-lines: (8,1)=$g3c (8,2)=$g3d, expected {1,31}"; fi

if mutlib "M3 text-close-resets" lib/protocol/render.chiral \
    's|^                  (rnd-restore amb)))))))$|                  (put ansi-reset)))))))|'; then
  if raw_map "$MUTLIB" m3; then
    m3a="$(cell_sgr "$TMP/m3.map" 3 3)"; m3b="$(cell_sgr "$TMP/m3.map" 3 4)"
    m3c="$(cell_sgr "$TMP/m3.map" 8 1)"; m3d="$(cell_sgr "$TMP/m3.map" 8 2)"
    if [ "$m3a" = "{}" ] && [ "$m3b" = "{}" ]; then
      ok "M3 text-close-resets -- G2's (3,3)/(3,4) go {1,31} -> {} (the r-text close is the killer)"
    else bad "M3 text-close-resets -- G2 did not move: (3,3)=$m3a (3,4)=$m3b"; fi
    if [ "$m3c" = "{}" ] && [ "$m3d" = "{}" ]; then
      ok "M3 text-close-resets -- G3's (8,1)/(8,2) go {1,31} -> {} in the SAME pass"
    else bad "M3 text-close-resets -- G3 did not move: (8,1)=$m3c (8,2)=$m3d"; fi
  else bad "M3 text-close-resets -- the mutant probe did not build"; fi
fi

# ============================================================================
# G4 -- THE JOIN, and it needs TWO shapes each with a TWO-LEAF inner face.
#
# ⚑ `face-join` feeds `rnd-restore` and NOTHING ELSE -- an open is always
# `face-sgr` of the LOOKED-UP face, never the join.  So the only cell that reads
# a join is the leaf AFTER another leaf inside the same inner face; the first
# leaf is painted straight off the two opens and carries the right set on the
# UNFIXED tree too.  An inner face with one leaf grades nothing.
#
# Two shapes because the fg rule and the attrs rule are convicted by different
# inner faces: `comment` (2 -1 0) STATES a foreground, `manas-cursor` (-1 -1 8)
# has NO foreground opinion and must inherit the outer's.
echo
echo "=== E175 G4: the JOIN -- attrs accumulate, the inner's colour wins when stated ==="
G4A_GOLDEN='25 1 120 {1,32}
25 2 121 {1,32}
25 3 122 {1,32}
25 4 119 {1,32}
25 5 112 {1,31}
25 6 113 {1,31}'
G4B_GOLDEN='27 1 120 {1,7,31}
27 2 121 {1,7,31}
27 3 122 {1,7,31}
27 4 119 {1,7,31}
27 5 112 {1,31}
27 6 113 {1,31}'
g4a="$(band "$FIXMAP" 25 25)"; g4b="$(band "$FIXMAP" 27 27)"
if [ "$g4a" = "$G4A_GOLDEN" ]; then
  ok "G4(a) keyword over comment: x,y,z,w {1,32} and p,q {1,31} -- the inner fg wins, the outer bold survives"
else bad "G4(a) moved:"; diff <(echo "$G4A_GOLDEN") <(echo "$g4a") | sed 's/^/          /'; fi
if [ "$g4b" = "$G4B_GOLDEN" ]; then
  ok "G4(b) keyword over manas-cursor: x,y,z,w {1,7,31} and p,q {1,31} -- no inner fg, so the outer's is inherited"
else bad "G4(b) moved:"; diff <(echo "$G4B_GOLDEN") <(echo "$g4b") | sed 's/^/          /'; fi

if mutlib "M4 join-drops-the-attrs" lib/protocol/render.chiral \
    's|^                  (bor oat iat))))))))$|                  oat)))))))|'; then
  if raw_map "$MUTLIB" m4; then
    if [ "$(cell_sgr "$TMP/m4.map" 25 3)" = "{32}" ] && [ "$(cell_sgr "$TMP/m4.map" 25 5)" = "{31}" ] \
       && [ "$(cell_sgr "$TMP/m4.map" 27 3)" = "{31}" ] && [ "$(cell_sgr "$TMP/m4.map" 27 5)" = "{31}" ]; then
      ok "M4 join-drops-the-attrs -- (a) z,w {32} p,q {31}; (b) z,w {31} p,q {31}: the bold stops surviving"
    else
      bad "M4 join-drops-the-attrs -- did not convict as measured"
      echo "          (a) z=$(cell_sgr "$TMP/m4.map" 25 3) p=$(cell_sgr "$TMP/m4.map" 25 5) · (b) z=$(cell_sgr "$TMP/m4.map" 27 3) p=$(cell_sgr "$TMP/m4.map" 27 5)"
    fi
  else bad "M4 join-drops-the-attrs -- the mutant probe did not build"; fi
fi

if mutlib "M5 join-keeps-the-outer-fg" lib/protocol/render.chiral \
    's|^                  (case (<i ifg 0) (true ofg) (false ifg))$|                  ofg|'; then
  if raw_map "$MUTLIB" m5; then
    if [ "$(cell_sgr "$TMP/m5.map" 25 3)" = "{1}" ] && [ "$(cell_sgr "$TMP/m5.map" 25 5)" = "{1}" ] \
       && [ "$(cell_sgr "$TMP/m5.map" 27 3)" = "{1,7}" ] && [ "$(cell_sgr "$TMP/m5.map" 27 5)" = "{1}" ]; then
      ok "M5 join-keeps-the-outer-fg -- (a) z,w and p,q {1}; (b) z,w {1,7} p,q {1}: every colour is lost"
    else
      bad "M5 join-keeps-the-outer-fg -- did not convict as measured"
      echo "          (a) z=$(cell_sgr "$TMP/m5.map" 25 3) p=$(cell_sgr "$TMP/m5.map" 25 5) · (b) z=$(cell_sgr "$TMP/m5.map" 27 3) p=$(cell_sgr "$TMP/m5.map" 27 5)"
    fi
  else bad "M5 join-keeps-the-outer-fg -- the mutant probe did not build"; fi
fi

# ⚑ M6 is the reason shape (b) is not optional: it leaves shape (a) COMPLETELY
# unchanged.  A G4 written on one shape would have shipped with this mutant
# green, and "the inner's colour wins" would have been asserted by nothing.
if mutlib "M6 join-keeps-the-inner-fg" lib/protocol/render.chiral \
    's|^                  (case (<i ifg 0) (true ofg) (false ifg))$|                  ifg|'; then
  if raw_map "$MUTLIB" m6; then
    if [ "$(band "$TMP/m6.map" 25 25)" = "$G4A_GOLDEN" ]; then
      ok "M6 join-keeps-the-inner-fg -- shape (a) is COMPLETELY unchanged, which is why (b) exists"
    else bad "M6 join-keeps-the-inner-fg -- shape (a) moved; the stated reason for shape (b) is wrong"; fi
    if [ "$(cell_sgr "$TMP/m6.map" 27 3)" = "{1,7}" ]; then
      ok "M6 join-keeps-the-inner-fg -- shape (b) convicts: z,w {1,7,31} -> {1,7}, the inherited fg is dropped"
    else bad "M6 join-keeps-the-inner-fg -- shape (b) reads $(cell_sgr "$TMP/m6.map" 27 3), expected {1,7}"; fi
  else bad "M6 join-keeps-the-inner-fg -- the mutant probe did not build"; fi
fi

# ============================================================================
# G5 -- DEPTH 0 EMITS EXACTLY `\e[0m`.  RAW BYTES, not the cell map: a trailing
# SGR paints no cell, so the tracking reducer cannot see this row at all.  The
# fixture's last emission is G6's outer `r-face` close, at depth 0.
echo
echo "=== E175 G5: depth 0 emits exactly ESC [ 0 m -- raw bytes, no trailing re-open ==="
t4="$(tailn "$TMP/fix.raw" 4)"
if [ "$t4" = "27 91 48 109" ]; then
  ok "G5 the stream's final four bytes are 27 91 48 109 -- no trailing ESC[m, no doubled parameters"
else bad "G5 the final four bytes are '$t4', expected '27 91 48 109'"; fi
if [ -s "$TMP/m1.raw" ]; then
  m1t="$(tailn "$TMP/m1.raw" 8)"
  if [ "$m1t" = "27 91 48 109 27 91 49 109" ]; then
    ok "M1 plain-seed-is-bold (as BYTES) -- the tail gains 27 91 49 109: the depth-0 restore re-opens a face"
  else bad "M1 plain-seed-is-bold (as BYTES) -- tail is '$m1t', expected '27 91 48 109 27 91 49 109'"; fi
else bad "M1 plain-seed-is-bold (as BYTES) -- no mutant stream to read"; fi

# ============================================================================
# G6 -- `r-hole` IS UNCHANGED, and THIS ROW EXISTS BECAUSE THE CELL MAP CANNOT
# SEE IT.  `r-hole` emits no SGR and closes with `(put "")`; E175 does not
# touch it.  It is E174's residue and it is the control that shows this element
# was not a blanket `sed` over every close.
echo
echo "=== E175 G6: r-hole is untouched -- and only the raw bytes can say so ==="
gap="$(hole_gap "$TMP/fix.raw")"
if [ "$gap" = "0" ]; then
  ok "G6 zero bytes between the hole's <?>h and the next cursor move -- r-hole still emits nothing"
else bad "G6 the gap after <?>h is '$gap' bytes, expected 0"; fi

if mutlib "M7 hole-restores-too" lib/protocol/render.chiral \
    's|^                  (put "")))))))$|                  (rnd-restore amb)))))))|'; then
  if raw_map "$MUTLIB" m7; then
    m7gap="$(hole_gap "$TMP/m7.raw")"
    if [ "$m7gap" != "0" ] && [ "$m7gap" != "NOMATCH" ]; then
      ok "M7 hole-restores-too -- the raw gap goes 0 -> $m7gap bytes (ESC[0m ESC[1m ESC[31m)"
    else bad "M7 hole-restores-too -- the raw gap reads '$m7gap'; G6 grades nothing"; fi
    # ⚑ The row's justification, asserted rather than claimed.
    if cmp -s "$FIXMAP" "$TMP/m7.map"; then
      ok "M7 hole-restores-too -- the CELL MAP is byte-for-byte IDENTICAL: a cell-map-only gate would call E175 done"
    else bad "M7 hole-restores-too -- the cell map moved, so G6's stated reason for being a byte row is wrong"; fi
  else bad "M7 hole-restores-too -- the mutant probe did not build"; fi
fi

# ============================================================================
# G7 -- THE NEIGHBOURING GATES HOLD.
#
# (a) FIVE sha256 pins, not four: E174's fixture joins E157's and E158's pair,
# so each element's gate is held by the next one.  ⚑ `row.sh` is deliberately
# NOT pinned -- E175 edits it, by four lines, and (c) is what stands in for the
# pin it cannot have.
echo
echo "=== E175 G7: the E157, E158 and E174 gates hold, and every phase still runs ==="
DIAG_SH_SHA=938897ecf553c73fb0ea80ed05afca43b96363861cdf53f8496caf78ac21509f
DIAG_FX_SHA=713fe84d51c149d491edf8289a5799206f44b0e925a28dc7f123ba3f7ab4171c
DOC_SH_SHA=4e20eb0a80d42a9a08745cbe2991cd2924315c361713194d31f1277cb371b405
DOC_FX_SHA=2a319302e79f4bf012b72f7f870069742df340d93618f6314d67c0a08d27eea8
ROW_FX_SHA=a0cf04d8cb91a5bbc4f143c1315e406558f22d5c97ce76f83c8a5f53f02e75fd
sha_of() { sha256sum "$1" | awk '{print $1}'; }
pin() {  # pin LABEL FILE WANT
  local got; got="$(sha_of "$2")"
  if [ "$got" = "$3" ]; then ok "$1 is byte-unchanged (sha256 pinned)"
  else bad "$1 MOVED -- sha256 $got, pinned $3"; fi
}
pin "tools/test/diag.sh"                "$HERE/diag.sh"                "$DIAG_SH_SHA"
pin "tools/test/samples/e157_diag.prog" "$HERE/samples/e157_diag.prog" "$DIAG_FX_SHA"
pin "tools/test/doc.sh"                 "$HERE/doc.sh"                 "$DOC_SH_SHA"
pin "tools/test/samples/e158_doc.prog"  "$HERE/samples/e158_doc.prog"  "$DOC_FX_SHA"
pin "tools/test/samples/e174_row.prog"  "$HERE/samples/e174_row.prog"  "$ROW_FX_SHA"
# M8: append one line to a COPY of each pinned file.  EVERY pin must move --
# pinning four while exercising one is the same hole one file smaller.
m8bad=0
for f in diag.sh samples/e157_diag.prog doc.sh samples/e158_doc.prog samples/e174_row.prog; do
  cp "$HERE/$f" "$TMP/m8"; printf '\n# a row E175 had no business adding\n' >>"$TMP/m8"
  case "$f" in
    diag.sh)                m8w="$DIAG_SH_SHA" ;; samples/e157_diag.prog) m8w="$DIAG_FX_SHA" ;;
    doc.sh)                 m8w="$DOC_SH_SHA"  ;; samples/e158_doc.prog)  m8w="$DOC_FX_SHA"  ;;
    *)                      m8w="$ROW_FX_SHA"  ;;
  esac
  [ "$(sha_of "$TMP/m8")" != "$m8w" ] || m8bad=$((m8bad+1))
done
if [ "$m8bad" -eq 0 ]; then ok "M8 move-a-pinned-gate -- all five pins move when their file does"
else bad "M8 move-a-pinned-gate -- $m8bad pin(s) did not move"; fi

# (b) FOUR registration rows, not three: M9 deletes the run_phase 16 line too,
# and without a Phase-16 row there is nothing for that half of M9 to redden.
# The grep runs against run-tests.sh, a DIFFERENT FILE from the script doing
# the grep -- that, and not an assembled pattern, is what makes a registration
# row unable to match its own source.
RT="$REPO/tools/test/run-tests.sh"
reg() { grep -cE "^run_phase $1 .* $2\$" "$3"; }
for spec in "13 diag.sh E157" "14 doc.sh E158" "15 row.sh E174" "16 face.sh E175"; do
  # shellcheck disable=SC2086
  set -- $spec
  if [ "$(reg "$1" "$2" "$RT")" -ge 1 ]; then ok "Phase $1 ($3) is registered in run-tests.sh"
  else bad "Phase $1 ($3) is NOT registered in run-tests.sh -- an unregistered script never runs"; fi
done
cp "$RT" "$TMP/m9.sh"
sed -i '/^run_phase 13 /d;/^run_phase 14 /d;/^run_phase 15 /d;/^run_phase 16 /d' "$TMP/m9.sh"
if [ "$(reg 13 diag.sh "$TMP/m9.sh")" -eq 0 ] && [ "$(reg 14 doc.sh "$TMP/m9.sh")" -eq 0 ] \
   && [ "$(reg 15 row.sh "$TMP/m9.sh")" -eq 0 ] && [ "$(reg 16 face.sh "$TMP/m9.sh")" -eq 0 ]; then
  ok "M9 unregister-the-phase -- all four registration rows catch a deleted run_phase line"
else bad "M9 unregister-the-phase -- a deleted run_phase line was not caught"; fi

# (c) NO SEVEN-ARGUMENT CALLER SURVIVES UNDER tools/.  This is the arity check
# that stands in for the pin `row.sh` cannot have.  Paren-balanced, not a
# pattern: the scanner counts TOP-LEVEL arguments, so a nested `(r-row (cons
# ...))` counts once and a stale-looking line cannot pass by not matching.
# (It does not parse string literals; no call in this tree carries a paren
# inside a string, and the M13 row is what would notice if one did.)
ARITY_AWK='
{
  line=$0; base=0
  while ((p = index(substr(line, base+1), NEEDLE)) > 0) {
    start = base + p + length(NEEDLE); base = start
    depth = 1; n = 0; inatom = 0; term = 0
    for (i = start; i <= length(line); i++) {
      ch = substr(line, i, 1)
      if (ch == "(")      { if (depth == 1) n++; depth++; inatom = 0 }
      else if (ch == ")") { depth--; inatom = 0; if (depth == 0) { term = 1; break } }
      else if (ch == " " || ch == "\t") { inatom = 0 }
      else { if (depth == 1 && !inatom) { n++; inatom = 1 } }
    }
    print FILENAME ":" FNR ":" (term ? n : "UNTERMINATED")
  }
}'
arity_scan() { # arity_scan DIR -> "file:line:nargs" per application
  ( cd "$REPO" && grep -RlF -- "($RTA " "$1" 2>/dev/null ) | while read -r f; do
    ( cd "$REPO" && LC_ALL=C awk -v NEEDLE="($RTA " "$ARITY_AWK" "$f" )
  done
}
scan="$(arity_scan tools)"
badar="$(echo "$scan" | awk -F: 'NF && $NF != 8')"
nap="$(echo "$scan" | grep -c . )"
if [ -z "$badar" ] && [ "$nap" -ge 5 ]; then
  ok "G7(c) all $nap $RTA applications under tools/ take EIGHT arguments -- no 7-argument caller survives"
else
  bad "G7(c) a non-eight-argument $RTA application survives under tools/ (scanned $nap)"
  echo "$badar" | sed 's/^/          /'
fi
# M13: the scanner must be able to SEE a seven-argument caller.  Without this
# row, G7(c) would be asserting that its own scanner found nothing -- which an
# always-empty scanner also does.  (M12 below proves the COMPILER rejects one;
# that is a different claim.)
mkdir -p "$TMP/m13/tools"
printf '(def m13-alone (lam (nd rw) (%s nd m13-dims none rw 1 rw 1)))\n' "$RTA" >"$TMP/m13/tools/probe.chiral"
m13="$( cd "$TMP/m13" && LC_ALL=C awk -v NEEDLE="($RTA " "$ARITY_AWK" tools/probe.chiral )"
if [ "${m13##*:}" = "7" ]; then
  ok "M13 a-seven-arg-caller-under-tools -- the scanner reports 7, so G7(c) can actually fail"
else bad "M13 a-seven-arg-caller-under-tools -- the scanner reported '$m13'; G7(c) grades nothing"; fi

# ============================================================================
# G8 -- THE NINE SIGNATURES MOVED TOGETHER.  Behavioural, not grep: three
# separate compiles, each on a copied lib/ with ONE thing changed.  Each fails
# with a DIFFERENT message, so a row cannot pass by reading the wrong failure.
echo
echo "=== E175 G8: the nine signatures moved TOGETHER -- three compiles, three messages ==="
cat >"$TMP/bare-render.prog" <<'BR'
(import "protocol/render")
(def compile-main (-> I64 I64) (lam (n) 42))
BR
# The positive control: without it, G8's three rows would all pass on a tree
# where EVERYTHING fails to compile.
if [ -z "$(build_err "$REPO/lib" "$TMP/bare-render.prog")" ]; then
  ok "G8 control -- protocol/render compiles clean on the unmutated tree"
else bad "G8 control -- protocol/render does not compile; every row below is meaningless"; fi

# (i) M10: drop `Face` from ONE walker's declare.  The lam still binds seven,
# so the seventh parameter is checked against `Unit`.
if mutlib "M10 declare-drops-the-face" lib/protocol/render.chiral \
    's|^(declare render-lines (=> (List Rendering) (Pair I64 I64) I64 I64 I64 I64 Face Unit))$|(declare render-lines (=> (List Rendering) (Pair I64 I64) I64 I64 I64 I64 Unit))|'; then
  e10="$(build_err "$MUTLIB" "$TMP/bare-render.prog")"
  case "$e10" in
    *"lambda checked against a non-function type"*)
      ok "M10 declare-drops-the-face -- load: lambda checked against a non-function type" ;;
    "") bad "M10 declare-drops-the-face -- the module COMPILED; a signature can be dropped unnoticed" ;;
    *)  bad "M10 declare-drops-the-face -- wrong failure: ${e10%%$'\n'*}" ;;
  esac
fi

# (ii) M11: drop `amb` from ONE walker's lam binder.  Its body reads `amb`
# twice, so the name is simply not in scope.
if mutlib "M11 binder-drops-the-amb" lib/protocol/render.chiral \
    's|^  (lam (title collapsed body dims row col drow dcol amb)$|  (lam (title collapsed body dims row col drow dcol)|'; then
  e11="$(build_err "$MUTLIB" "$TMP/bare-render.prog")"
  case "$e11" in
    *"unknown name amb"*) ok "M11 binder-drops-the-amb -- load: unknown name amb" ;;
    "") bad "M11 binder-drops-the-amb -- the module COMPILED; a binder can be dropped unnoticed" ;;
    *)  bad "M11 binder-drops-the-amb -- wrong failure: ${e11%%$'\n'*}" ;;
  esac
fi

# (iii) M12: a SEVEN-argument caller.
#
# ⚑ THE `declare` IS LOAD-BEARING AND THIS ROW IS TOOTHLESS WITHOUT IT.
# Measured at the SPEC audit: chirality is CURRIED, so a bare seven-argument
# application bound to `_` in a `let` is a legal PARTIAL APPLICATION of type
# `(=> Face Unit)` and `chirality check` returns OK on it.  The arity mismatch
# is detectable only where a DECLARED `Unit` result contradicts a function
# type -- which is the pre-E175 `row.sh:236` shape, reproduced here exactly.
{
  echo '(import "prelude/prelude")'
  echo '(import "protocol/render")'
  echo '(def mz-dims (Pair I64 I64) (pair 24 80))'
  echo '(declare mz-alone (=> Rendering I64 Unit))'
  printf '(def mz-alone (lam (nd rw) (%s nd mz-dims none rw 1 rw 1)))\n' "$RTA"
  echo '(def compile-main (=> I64 I64) (lam (n) (let ((_ (mz-alone (r-text "a" false) 1))) 0)))'
} >"$TMP/m12.prog"
e12="$(build_err "$REPO/lib" "$TMP/m12.prog")"
case "$e12" in
  *"type mismatch"*) ok "M12 a-seven-arg-caller (DECLARED shape) -- load: type mismatch" ;;
  "") bad "M12 a-seven-arg-caller -- it COMPILED; the arity is graded by nothing" ;;
  *)  bad "M12 a-seven-arg-caller -- wrong failure: ${e12%%$'\n'*}" ;;
esac

echo
echo "ambient face restore (E175): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
