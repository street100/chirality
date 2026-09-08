#!/usr/bin/env bash
# row.sh -- E174: horizontal composition, and the width function it needs.
# The Phase 15 gate.
#
# `Rendering` could compose VERTICALLY (`r-lines` steps the row and holds the
# column) and on a hardcoded 16-column GRID (`r-table`).  `r-face` rendered its
# body at the SAME (row, col) and emitted no positioning at all, and
# `render-section` never emitted an `ansi-goto` in its life.  So one line
# holding a tagged span beside plain text was UNREPRESENTABLE rather than
# awkward -- the measured blocker under E158's `doc->rendering`.
#
# ⚑ WHAT THIS GATE GRADES.  Not the constructor: `r-row` is one arm and six
# lines of emitter.  The element is `rnd-cols`, because laying children left to
# right requires knowing how far each one advances the column and no
# `Rendering` node ever had to answer that before.
#
# A WIDTH FUNCTION IS EXACTLY THE THING THAT LOOKS RIGHT AND IS OFF BY ONE.  So
# no row below is a shape assertion -- not "rnd-cols returns 15", not "the sum
# has nine arms by grep".  Every row that matters renders through
# `render-to-ansi` and READS THE EMITTED BYTE STREAM, and every row carries a
# named mutant that is RUN.  A row whose mutant also passes exercises nothing
# (the E156 lesson, and the five self-matching grep gates this repo turned up).
#
#   G1  the red module goes green                            [M6]
#   G2  the codec ROUND-TRIPS all nine, including the three
#       arms the compiler cannot see                         [M7]
#   G3  the row is a row -- three segments, one line         [M1]
#   G4  widths agree with the emitter, per constructor,
#       by EXACT ADJACENCY             [M2,M3,M11,M4,M13,M14,M10]
#   G5  FLAG A's own row: the fix is a NO-OP where the tree
#       already worked                                       [M10]
#   G6  the sum is closed and no `_` absorbs the new arm     [M5]
#   G7  E157's and E158's gates are byte-unchanged, and all
#       three phases still run                              [M8,M9]
#   G8  name census, tree-wide                           [M12,M5]
#
# ⚑ FOURTEEN mutants, not the SPEC's twelve. M13 (table-forgets-its-grid) and
# M5's census half were added because without them the r-table row and the
# constructor-count row were the two rows here that NOTHING could redden -- the
# exact standing hazard this repo turned up five instances of. M14
# (hole-forgets-its-mark) closes the third: the same reasoning applied to the
# one G4 row the SPEC's enumeration stopped short of.
#
# ⚑ WHAT THIS GATE CANNOT PROVE, stated because it bounds the rows above.  The
# screen reducer advances ONE COLUMN PER CODEPOINT, which is the same unit
# `str-cols` counts in.  So Phase 15 grades AGREEMENT BETWEEN `rnd-cols` AND
# THE EMITTER -- the invariant E174 introduces and the one that can silently
# rot.  It does NOT grade agreement with a real terminal: CJK is two cells and
# combining marks are none, that is E177 (the wcwidth-class table, minted, with
# E174 as its first consumer), and E177's landing must move `str-cols` and this
# reducer TOGETHER.
#
# ⚑ NOT rows here, deliberately: any fixpoint `cmp` (lib/protocol/render.chiral
# is outside prog/compiler.prog's import closure, so no compiler source moved
# -- and a fixpoint is a STABILITY check, never a correctness one) · agreement
# with a real terminal's wcwidth (E177) · `r-table`'s header/body overrun
# (E178, and G4 says so at the row) · nested-`r-face` SGR restoration (E175 --
# E174 is missing LAYOUT, E175 is non-nesting SGR STATE, and `rnd-cols` is
# provably invariant under it, which M3 is what makes checkable) · a second row
# asserting `t5_vt_parser` went green (Phase 7's own KNOWN_FAIL accounting
# grades that, and a row here would grade it twice) · any `dg-msg` or
# `doc->str` byte-identity row (E157 and E158 own those; G7 keeps them out).
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
APC="$REPO/lib/protocol/apc.chiral"
FIXTURE="$HERE/samples/e174_row.prog"
for f in "$RND" "$APC" "$FIXTURE"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its fixture cannot fail"; exit 2; }
done
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# ---- helpers ---------------------------------------------------------------
# build_run LIBDIR SRC -> the compiled program's exit code (255 = compile error)
build_run() {
  local lib="$1" src="$2" blob="$TMP/b.$$" elf="$TMP/e.$$"
  ( cd "$REPO" && chirality_blob_file "$lib:$REPO/prog" "$src" ) >"$blob" 2>/dev/null || return 255
  ( ulimit -s unlimited; "$CC" <"$blob" >"$elf" 2>/dev/null ) || return 255
  [ -s "$elf" ] || return 255
  chmod +x "$elf"
  ( ulimit -s unlimited; "$elf" >/dev/null 2>&1 )
  local rc=$?
  rm -f "$blob" "$elf"
  return $rc
}

# build_out LIBDIR SRC OUTFILE -> 0 and OUTFILE holds the program's STDOUT.
# ⚑ This was the one helper doc.sh did not have when E174 was written: its
# `build_run` discarded stdout, and every layout row below is read out of
# stdout.  GA-23's repair gave doc.sh a `build_raw` of the same shape; this one
# stays, because row.sh is sha256-pinned by two neighbours and a rename here
# would move both pins for a helper that is already correct.
build_out() {
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
MUTLIB=""
mutlib() {
  local name="$1" rel="$2"; shift 2
  MUTLIB="$TMP/mutlib"; rm -rf "$MUTLIB"; cp -a "$REPO/lib" "$MUTLIB"
  local target="$MUTLIB/${rel#lib/}" e
  for e in "$@"; do
    sed -i "$e" "$target" || { bad "$name -- sed failed"; return 1; }
  done
  if cmp -s "$target" "$REPO/$rel"; then
    bad "$name -- the mutation did not change $rel (stale pattern)"; return 1
  fi
  return 0
}

# ---- the screen reducer ----------------------------------------------------
# Reduce a program's ANSI stdout to a CELL MAP: one "row col bytes" line per
# painted cell, `bytes` being the cell's UTF-8 bytes in decimal, slash-joined.
#
#   ESC[<r>;<c>H  set the cursor      ESC[H  home        ESC[2J  clear the map
#   ESC[<p>m      IGNORED -- SGR paints no cell.  This is what makes G4's
#                 r-face row a real row rather than a comment, and it is why
#                 `rnd-cols` is provably invariant under E175.
#   ESC[?<n>h/l, ESC[K   ignored
#   \n            row += 1, col = 1
#   a UTF-8 CONTINUATION byte (0x80-0xBF)   appended to the current cell and
#                 DOES NOT ADVANCE the column -- one column per codepoint, the
#                 same unit str-cols counts in
#   any other byte   painted at (row, col); col += 1
SCREEN_AWK='
BEGIN { st=0; par=""; r=1; c=1; nc=0 }
function paint(v) { key = r "," c; if (!(key in cell)) ord[++nc]=key; cell[key]=v }
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
      } else if (b==74 && par=="2") { for (k in cell) delete cell[k]; nc=0 }
      st=0
    }
  }
}
END { for (i=1;i<=nc;i++) { k=ord[i]; if (k in cell) { split(k,p,","); print p[1], p[2], cell[k] } } }'

screen() {  # screen RAWFILE -> the cell map, sorted by row then column
  LC_ALL=C od -An -v -tu1 <"$1" | LC_ALL=C tr -s ' ' '\n' | grep -v '^$' \
    | LC_ALL=C awk "$SCREEN_AWK" | LC_ALL=C sort -k1,1n -k2,2n
}

cell_at()   { LC_ALL=C awk -v r="$2" -v c="$3" '$1==r && $2==c {print $3}' "$1"; }
band_stat() { # band_stat MAP ROW0 ROW1 -> "topmost maxcol ncells" (0 0 0 if empty)
  LC_ALL=C awk -v a="$2" -v b="$3" \
    '$1>=a && $1<=b { if (n==0 || $1<top) top=$1; if ($2+0>mx) mx=$2+0; n++ }
     END { if (n==0) print "0 0 0"; else print top, mx, n }' "$1"
}

# ---- the probes this gate writes, OUTSIDE the source tree ------------------
# The nine nodes are spelled ONCE and interpolated into both probes, so the
# measured widths and the measured layout cannot be reading two different
# fixtures.  ⚑ The r-table node is deliberately inside the AGREEING region --
# headers <= 14 columns, cells <= 16 -- see G4.
EZ_NODES='(import "prelude/prelude")
(import "protocol/render")

(def ez-kids (List Rendering) (cons (r-text "a" false) (cons (r-text "bbbb" false) nil)))
(def ez-cells (List Rendering) (cons (r-text "1" false) (cons (r-text "ab" false) nil)))

(def ez-n1 Rendering (r-text "abc" false))
(def ez-n2 Rendering (r-face "keyword" (r-text "abcd" false)))
(def ez-n3 Rendering (r-lines ez-kids))
(def ez-n4 Rendering (r-row (cons (r-text "ab" false) (cons (r-text "cde" false) nil))))
(def ez-n5 Rendering (r-tree ez-kids (r-text "a" false)))
(def ez-n6 Rendering (r-section "Sec" false (r-text "body" false)))
(def ez-n7 Rendering (r-table (cons "id" (cons "nm" nil)) (cons ez-cells nil)))
(def ez-n8 Rendering (r-stream "log1"))
(def ez-n9 Rendering (r-hole "h"))'

# The layout probe.  Each constructor gets TWO six-row bands: an ALONE band, in
# which it is the only thing drawn, and a WITH-BAR band, in which it is the
# first child of an r-row whose second child is a single `|`.
#
#   i  node        alone   with-bar          i  node        alone   with-bar
#   1  r-text        1        61             6  r-section    31        91
#   2  r-face        7        67             7  r-table      37        97
#   3  r-lines      13        73             8  r-stream     43       103
#   4  r-row        19        79             9  r-hole       49       109
#   5  r-tree       25        85
#
# ⚑ r-section's two bands are emitted FIRST, before anything else.  That is not
# cosmetic: under M10 (its `ansi-goto` reverted) the title draws at the AMBIENT
# cursor, and emitting it first confines the stray output to cells that band 1
# then overwrites, so M10's conviction lands on the r-section rows and nowhere
# else.  Emitted anywhere later it would redden whichever band happened to
# precede it, and a mutant that convicts at the wrong row is a mutant that has
# stopped naming anything.
cat >"$TMP/emit.prog" <<EMIT
$EZ_NODES

(def ez-bar Rendering (r-text "|" false))
(def ez-dims (Pair I64 I64) (pair 130 200))

(declare ez-alone (=> Rendering I64 Unit))
(def ez-alone (lam (nd rw) (render-to-ansi nd ez-dims none rw 1 rw 1 rnd-face-plain)))

(declare ez-withbar (=> Rendering I64 Unit))
(def ez-withbar
  (lam (nd rw)
    (render-to-ansi (r-row (cons nd (cons ez-bar nil))) ez-dims none rw 1 rw 1 rnd-face-plain)))

(def compile-main (=> I64 I64)
  (lam (n)
    (let ((_ (ez-alone   ez-n6  31)))
    (let ((_ (ez-withbar ez-n6  91)))
    (let ((_ (ez-alone   ez-n1   1)))
    (let ((_ (ez-alone   ez-n2   7)))
    (let ((_ (ez-alone   ez-n3  13)))
    (let ((_ (ez-alone   ez-n4  19)))
    (let ((_ (ez-alone   ez-n5  25)))
    (let ((_ (ez-alone   ez-n7  37)))
    (let ((_ (ez-alone   ez-n8  43)))
    (let ((_ (ez-alone   ez-n9  49)))
    (let ((_ (ez-withbar ez-n1  61)))
    (let ((_ (ez-withbar ez-n2  67)))
    (let ((_ (ez-withbar ez-n3  73)))
    (let ((_ (ez-withbar ez-n4  79)))
    (let ((_ (ez-withbar ez-n5  85)))
    (let ((_ (ez-withbar ez-n7  97)))
    (let ((_ (ez-withbar ez-n8 103)))
    (let ((_ (ez-withbar ez-n9 109)))
      0))))))))))))))))))))
EMIT

# The width probe: the SAME nine nodes, through `rnd-cols`, one "i W" per line.
cat >"$TMP/widths.prog" <<WIDTHS
$EZ_NODES

(declare ez-line (=> I64 Rendering Unit))
(def ez-line
  (lam (i r)
    (let ((_ (put (i64->str i))))
      (let ((_ (put " ")))
        (let ((_ (put (i64->str (rnd-cols r)))))
          (put "\n"))))))

(def compile-main (=> I64 I64)
  (lam (n)
    (let ((_ (ez-line 1 ez-n1)))
    (let ((_ (ez-line 2 ez-n2)))
    (let ((_ (ez-line 3 ez-n3)))
    (let ((_ (ez-line 4 ez-n4)))
    (let ((_ (ez-line 5 ez-n5)))
    (let ((_ (ez-line 6 ez-n6)))
    (let ((_ (ez-line 7 ez-n7)))
    (let ((_ (ez-line 8 ez-n8)))
    (let ((_ (ez-line 9 ez-n9)))
      0)))))))))))
WIDTHS

# G3's probe: E158's `dg-doc` r-redeclared shape -- a tagged head, a space and a
# tagged site on ONE line -- reduced to four cells, at the coordinates the SPEC
# pins.  This is the forcing consumer, and it is what was unrepresentable.
cat >"$TMP/g3.prog" <<'G3'
(import "prelude/prelude")
(import "protocol/render")
(def gz-row Rendering
  (r-row (cons (r-face "diag-head" (r-text "a" false))
         (cons (r-text " " false)
         (cons (r-face "diag-site" (r-text "bb" false))
         nil)))))
(def compile-main (=> I64 I64)
  (lam (n)
    (let ((_ (render-to-ansi gz-row (pair 24 80) none 3 5 3 5 rnd-face-plain)))
      0)))
G3

# G5's probe: FLAG A's own row, and the ONLY configuration the tree currently
# produces -- a section rendered first-on-row, through render-to-ansi-full.
cat >"$TMP/g5.prog" <<'G5'
(import "prelude/prelude")
(import "protocol/render")
(def compile-main (=> I64 I64)
  (lam (n)
    (let ((_ (render-to-ansi-full (r-section "Sec" false (r-text "body" false)) (pair 24 80))))
      0)))
G5

# Two bare roots, one per module, so a module's compile can be graded on its own.
cat >"$TMP/bare-render.prog" <<'BR'
(import "protocol/render")
(def compile-main (-> I64 I64) (lam (n) 42))
BR
cat >"$TMP/bare-apc.prog" <<'BA'
(import "protocol/apc")
(def compile-main (-> I64 I64) (lam (n) 42))
BA

# ============================================================================
# G1 -- THE RED MODULE GOES GREEN.  lib/protocol/apc.chiral was already red
# before this element: `enc` matched six of eight constructors with no default
# arm, because `r-lines` and `r-face` were added to the sum and the codec was
# never updated.  E174 adds a NINTH.  Measured FAILED / `load: non-exhaustive
# case` before, so this row can fail and did.
echo
echo "=== E174 G1: the module that was red is green, and an unrelated red stays red ==="
# `chirality check` exits non-zero on a refusal, and this script runs with
# pipefail, so the output is captured FIRST and matched second -- piping it
# straight into grep would make every negative row read as a pipeline failure.
chk() { ( cd "$REPO" && ./bin/chirality check "$1" 2>&1 ) || true; }
if chk lib/protocol/apc.chiral | grep -q ' OK$'; then ok "lib/protocol/apc.chiral checks OK (it was load: non-exhaustive case)"
else bad "lib/protocol/apc.chiral does not check: $(chk lib/protocol/apc.chiral | tr '\n' ' ')"; fi
if chk lib/protocol/render.chiral | grep -q ' OK$'; then ok "lib/protocol/render.chiral still checks OK"
else bad "lib/protocol/render.chiral does not check: $(chk lib/protocol/render.chiral | tr '\n' ' ')"; fi
if chk prog/scriba/samples/t6_apc_roundtrip.prog | grep -q ' OK$'; then ok "prog/scriba/samples/t6_apc_roundtrip.prog checks OK"
else bad "t6_apc_roundtrip.prog does not check: $(chk prog/scriba/samples/t6_apc_roundtrip.prog | tr '\n' ' ')"; fi
# THE CONTROL that keeps the row specific.  t5_utf8 is red for a reason no
# `enc` fix can touch -- it carries ZERO (import ...) lines, an unported
# old-tree root, so `Unit` is simply absent.  If this ever goes green, G1 has
# started reading a tree-wide state rather than this element's repair.
if chk prog/scriba/samples/t5_utf8.prog | grep -q 'unknown name Unit'; then
  ok "the control holds: t5_utf8.prog is still red on 'unknown name Unit' (no imports at all -- not a codec failure)"
else bad "the control moved: t5_utf8.prog no longer fails on 'unknown name Unit' -- G1 is reading a tree-wide state"; fi

# M6: DROP THE ENC ARM.  The compiler must go back to refusing the module.
# The arm is two lines and its second carries the closes for the case, the lam
# and the def, so removing it means promoting the r-face arm to last -- delete,
# then re-balance.  A stale half shows up as a parse error, not as a pass: the
# row greps for `non-exhaustive case` specifically.
if mutlib "M6 drop-the-enc-arm" lib/protocol/apc.chiral \
     '/^    ((r-row children)$/,+1d' \
     's|^      (str-cat "F" (str-cat (enc-str f) (enc body))))$|      (str-cat "F" (str-cat (enc-str f) (enc body)))))))|'; then
  m6err="$(build_err "$MUTLIB" "$TMP/bare-apc.prog")"
  if echo "$m6err" | grep -q 'non-exhaustive case'; then
    ok "M6 drop-the-enc-arm -- protocol/apc goes back to: $(echo "$m6err" | head -c 60)"
  else bad "M6 drop-the-enc-arm -- protocol/apc compiled clean without the r-row arm; a catch-all has crept into enc"; fi
fi

# ============================================================================
# G2 -- THE CODEC ROUND-TRIPS ALL NINE, including the three the compiler cannot
# see.  ⚑ `dec` is a cond on a tag Str ending in `(else (p-err ...))`, so a
# forgotten DECODE arm is a runtime value and not a compile error.  This row is
# the only thing in the tree that can see one.
echo
echo "=== E174 G2: the codec round-trips all nine constructors, plus a nested r-row ==="
build_run "$REPO/lib" "$FIXTURE"
g2rc=$?
if [ $g2rc -eq 0 ]; then ok "e174_row: 10 cases (nine constructors + r-row inside an r-face inside an r-row)"
else bad "e174_row: first failing case = $g2rc"; fi

# M7: DROP THE DEC ARM.  ⚑ BOTH MODULES STILL COMPILE -- that is the finding --
# and the round-trip must convict anyway, at case 9.  A gate that stopped at G1
# would have called this element done.
if mutlib "M7 drop-the-dec-arm" lib/protocol/apc.chiral 's|      ((str-eq tag "R")|      ((str-eq tag "Z")|'; then
  m7r="$(build_err "$MUTLIB" "$TMP/bare-render.prog")"
  m7a="$(build_err "$MUTLIB" "$TMP/bare-apc.prog")"
  build_run "$MUTLIB" "$FIXTURE"; m7rc=$?
  if [ -z "$m7r" ] && [ -z "$m7a" ] && [ "$m7rc" -eq 9 ]; then
    ok "M7 drop-the-dec-arm -- both modules compile CLEAN and the round-trip still convicts at case 9 (the bare r-row)"
  else bad "M7 drop-the-dec-arm -- render err '$m7r', apc err '$m7a', fixture exit $m7rc (wanted '', '', 9)"; fi
fi

# ============================================================================
# G3 -- THE ROW IS A ROW.  E158's `dg-doc` r-redeclared shape (a tagged head, a
# space, a tagged site, on one line) reduced to four cells.  This is the
# forcing consumer, and before `r-row` it was unrepresentable rather than
# awkward.  The assertion is the CELL MAP, painted at absolute coordinates.
echo
echo "=== E174 G3: three segments, one line, exact cells ==="
G3_WANT='3 5 97
3 6 32
3 7 98
3 8 98'
g3_map() {  # g3_map LIBDIR -> the cell map of the G3 probe
  build_out "$1" "$TMP/g3.prog" "$TMP/g3.raw" || return 1
  screen "$TMP/g3.raw"
}
if g3got="$(g3_map "$REPO/lib")"; then
  if [ "$g3got" = "$G3_WANT" ]; then ok "the r-row paints exactly 3:5 'a' · 3:6 ' ' · 3:7 'b' · 3:8 'b', and nothing anywhere else"
  else bad "the r-row's cell map is wrong: $(echo "$g3got" | tr '\n' ' | ')"; fi
else bad "G3's probe did not build"; fi

# M1: TEXT OFF BY ONE.  rnd-cols' r-text arm charges one column too many, so
# every following segment drifts right: the three segments land at 5, 7 and 9.
# (It reddens G4's rows too -- every fixture holds an r-text -- which is why M1
# is asserted HERE, at the row whose golden names the columns.)
if mutlib "M1 text-off-by-one" lib/protocol/render.chiral \
     's|      ((r-text content bold) (str-cols content))|      ((r-text content bold) (+ 1 (str-cols content)))|'; then
  if m1got="$(g3_map "$MUTLIB")"; then
    if [ "$m1got" != "$G3_WANT" ]; then ok "M1 text-off-by-one -- the segments drift: $(echo "$m1got" | tr '\n' ' | ')"
    else bad "M1 text-off-by-one -- G3 stayed GREEN; it is not measuring the layout"; fi
  else bad "M1 text-off-by-one -- the mutant probe did not build"; fi
fi

# ============================================================================
# G4 -- WIDTHS AGREE WITH THE EMITTER, PER CONSTRUCTOR, BY EXACT ADJACENCY.
#
# For each constructor N the probe draws two bands: N ALONE, and N as the first
# child of an r-row whose second child is a `|`.  Four things are asserted, and
# the split is what makes the row non-circular -- (a) alone is `render-row`
# agreeing with itself.
#
#   (a) the `|` is painted at column 1 + rnd-cols(N) in the with-bar band
#   (d) N's topmost painted row IS the band's row -- it draws where it is told
#   (b) no cell N paints, on ANY row it touches, is at a column >= 1+rnd-cols(N)
#   (c) TIGHTNESS: N's rightmost painted column is EXACTLY rnd-cols(N).
#       One column too many leaves a gap, one too few overwrites.
#
# ⚑ TWO SCOPE STATEMENTS, in as many words.
#
#  1. `r-table` is graded on (a), (d) and (b) ONLY -- NOT on (c).  Its two
#     placers disagree by construction: rnd-emit-headers advances by content
#     plus a gutter, rnd-emit-one-row by a fixed 16 that ignores the content,
#     so the grid RESERVES columns nothing draws in and the tight bound is
#     false for a reason that is not this element's.  The fixture is inside the
#     agreeing region (headers <= 14 columns, cells <= 16), so this row does
#     NOT grade the measured header/body overrun.  That is E178, minted, and
#     naming it here is what keeps the narrowing a tracked debt.
#  2. The r-section case is the one FLAG A's fix makes satisfiable at all.
#     Before it, render-section ignored `col` entirely and (d) could not hold
#     for a section that is not first on its row.
echo
echo "=== E174 G4: rnd-cols agrees with the emitter, per constructor, by exact adjacency ==="
G4_NAMES=(x r-text r-face r-lines r-row r-tree r-section r-table r-stream r-hole)
G4_ALONE=(0 1 7 13 19 25 31 37 43 49)
G4_WITHBAR=(0 61 67 73 79 85 91 97 103 109)

# g4_run LIBDIR -> writes $TMP/g4.map and $TMP/g4.w ; 1 if either probe failed
g4_run() {
  local lib="$1"
  build_out "$lib" "$TMP/emit.prog" "$TMP/emit.raw" || return 1
  build_out "$lib" "$TMP/widths.prog" "$TMP/g4.w"   || return 1
  screen "$TMP/emit.raw" >"$TMP/g4.map"
  [ -s "$TMP/g4.map" ]
}

# g4_case i -> "" when the constructor's four assertions hold, else the reason
g4_case() {
  local i="$1" w a b0 b1 stat top mx nc barcell
  w="$(LC_ALL=C awk -v i="$i" '$1==i {print $2}' "$TMP/g4.w")"
  [ -n "$w" ] || { echo "rnd-cols reported no width"; return; }
  a="${G4_ALONE[$i]}"; b0="${G4_WITHBAR[$i]}"; b1=$((b0+5))
  stat="$(band_stat "$TMP/g4.map" "$a" $((a+5)))"
  top="${stat%% *}"; mx="$(echo "$stat" | cut -d' ' -f2)"; nc="${stat##* }"
  barcell="$(cell_at "$TMP/g4.map" "$b0" $((w+1)))"
  [ "$nc" -gt 0 ] || { echo "the node painted nothing in its band"; return; }
  [ "$barcell" = "124" ] || { echo "(a) the bar is not at column $((w+1)) on row $b0 (found '${barcell:-nothing}')"; return; }
  [ "$top" = "$a" ]      || { echo "(d) its topmost painted row is $top, not the band's row $a"; return; }
  if [ "$i" = 7 ]; then
    [ "$mx" -lt $((w+1)) ] || { echo "(b) it paints at column $mx, at or past 1+rnd-cols=$((w+1))"; return; }
  else
    [ "$mx" = "$w" ] || { echo "(c) its rightmost painted column is $mx, not exactly rnd-cols=$w"; return; }
  fi
  echo ""
}

# g4_report -> prints one row per constructor; sets G4_RED to the failing names
G4_RED=""
g4_report() {
  local quiet="${1:-}" i why
  G4_RED=""
  for i in 1 2 3 4 5 6 7 8 9; do
    why="$(g4_case "$i")"
    if [ -z "$why" ]; then
      [ -n "$quiet" ] || ok "$(printf '%-10s advances %2s columns, and the emitter agrees exactly' \
            "${G4_NAMES[$i]}" "$(LC_ALL=C awk -v i="$i" '$1==i {print $2}' "$TMP/g4.w")")"
    else
      G4_RED="$G4_RED ${G4_NAMES[$i]}"
      [ -n "$quiet" ] || bad "${G4_NAMES[$i]} -- $why"
    fi
  done
}

if g4_run "$REPO/lib"; then
  g4_report
  echo "        (r-table is graded on (a)(d)(b) and NOT on the tight bound: its"
  echo "         grid reserves columns nothing draws in.  E178 owns that fix.)"
else
  bad "G4's probes did not build"; G4_RED=" build-failed"
fi

# The G4 mutants.  Each names ONE corruption and the constructor row it must
# redden -- and each is RUN.
echo
echo "=== E174 the width mutants (a row whose mutant passes exercises nothing) ==="
g4_mutant() {  # g4_mutant NAME WANT-RED-NAME SED-EXPR...
  local name="$1" want="$2"; shift 2
  mutlib "$name" lib/protocol/render.chiral "$@" || return
  if ! g4_run "$MUTLIB"; then bad "$name -- the mutant probes did not build"; return; fi
  g4_report quiet
  case " $G4_RED " in
    *" $want "*) ok "$name -- the $want row goes red, as required (red:${G4_RED})" ;;
    *)           bad "$name -- the $want row stayed GREEN (red:${G4_RED:- none}); that row is measuring nothing" ;;
  esac
}

# M2: BYTES, NOT COLUMNS.  str-cols' body becomes str-len.  ⚑ ONLY the r-stream
# row reddens, because `" — live stream]"` is 17 bytes and 15 columns -- the
# module's own counterexample to its own arithmetic, now a convicting test.
g4_mutant "M2 bytes-not-columns" r-stream \
  's|  (lam (s) (cp-count (decode-utf8 (str->bytes s)) 0)))|  (lam (s) (str-len s)))|'
# M3: A FACE COSTS A COLUMN.  SGR bytes are non-printing, so this is what makes
# "rnd-cols is provably invariant under E175" a CHECKED claim rather than a
# scoping note.
g4_mutant "M3 face-costs-a-column" r-face \
  's|      ((r-face face-name body) (rnd-cols body)))))|      ((r-face face-name body) (+ 1 (rnd-cols body))))))|'
# M11: THE TREE FORGETS ITS INDENT.  render-tree draws every child at
# col + rnd-tree-indent.  Dropping the constant from the width arm proves the
# hoisted `def` is wired to BOTH readers and not just to the emitter.
g4_mutant "M11 tree-forgets-its-indent" r-tree \
  's|          ((cons c cs) (+ rnd-tree-indent (rnd-cols-max children 0)))))|          ((cons c cs) (rnd-cols-max children 0))))|'
# M4: THE ROW USES MAX.  A row that reports its widest child instead of its
# total tells its parent the row is shorter than it is -- and the next sibling
# lands on top of it.
g4_mutant "M4 row-uses-max" r-row \
  's|      ((cons h t) (rnd-cols-sum t (+ acc (rnd-cols h)))))))|      ((cons h t) (rnd-cols-sum t (max acc (rnd-cols h)))))))|'
# M13: THE TABLE FORGETS ITS GRID.  ⚑ Added beyond the SPEC's twelve, and the
# reason is the standing hazard this repo has already been bitten by: without
# it the r-table row is the one row in G4 with NO mutant, and a row nothing can
# redden is a row that exercises nothing.  rnd-emit-one-row steps every cell by
# rnd-table-cell; dropping the constant from the width arm makes the width
# report the header extent (6) while the body still draws out to column 18.
g4_mutant "M13 table-forgets-its-grid" r-table \
  's|             (\* rnd-table-cell (rnd-row-cells rows 0 0))))|             (rnd-row-cells rows 0 0)))|'
# M14: THE HOLE FORGETS ITS MARK.  Added for the same reason M13 was, one row
# further along the enumeration: `r-hole` was the last constructor in G4 that
# NOTHING could redden.  The six g4_mutant calls redden six of the nine rows and
# M1 reaches `r-text` and `r-lines` as collateral, which leaves `r-hole` alone --
# it holds no `r-text`, so M1's off-by-one never touches it, and every other
# mutant aims at another arm or another file.  records/gate-audit.md GA-17 is
# that measurement.
#
# `rnd-cols`'s r-hole arm is the mark plus the label; the emitter paints the
# mark and then the label.  Drop the mark from the WIDTH only and the two
# disagree by exactly the mark's three columns, which is (a) and (c) both.
# ⚑ Not a mutation of `rnd-hole-mark` itself: the width arm and the emitter
# both read it, so changing it moves them together and reddens nothing.
g4_mutant "M14 hole-forgets-its-mark" r-hole \
  's|      ((r-hole label) (+ (str-cols rnd-hole-mark) (str-cols label)))|      ((r-hole label) (str-cols label))|'

# ============================================================================
# G5 -- FLAG A's OWN ROW: THE FIX IS A NO-OP WHERE THE TREE ALREADY WORKED.
#
# `render-section` never issued an `ansi-goto` -- measured by running it.  It
# took `row` and `col` and read neither to position itself; the title landed at
# (1,1) purely because `ansi-home` had put the cursor there.  E174 gives it the
# line every other drawing arm already has, and this row pins that a section
# rendered FIRST-ON-ROW lands exactly where it landed before:
#
#   before  ESC[2J ESC[H          ESC[1m S e c ESC[0m ESC[2;3H b o d y ESC[0m
#   after   ESC[2J ESC[H ESC[1;1H ESC[1m S e c ESC[0m ESC[2;3H b o d y ESC[0m
#
# The stream gains six bytes; the SCREEN is identical, and the screen is what
# the map below pins.
echo
echo "=== E174 G5: FLAG A -- render-section's new ansi-goto is a no-op first-on-row ==="
G5_WANT='1 1 83
1 2 101
1 3 99
2 3 98
2 4 111
2 5 100
2 6 121'
g5_map() { build_out "$1" "$TMP/g5.prog" "$TMP/g5.raw" || return 1; screen "$TMP/g5.raw"; }
if g5got="$(g5_map "$REPO/lib")"; then
  if [ "$g5got" = "$G5_WANT" ]; then ok "the section still paints 1:1 S · 1:2 e · 1:3 c · 2:3 b · 2:4 o · 2:5 d · 2:6 y"
  else bad "FLAG A's fix MOVED the screen: $(echo "$g5got" | tr '\n' ' | ')"; fi
else bad "G5's probe did not build"; fi

# M10: SECTION FORGETS ITS GOTO -- the fix reverted.  ⚑ TWO-SIDED, and both
# sides are asserted.  G5 must stay GREEN (that is the no-op proof: a section
# first-on-row is unaffected), and G4's r-section row must go RED (a section as
# a non-first child draws at the ambient cursor instead of where it was told).
# A mutant reddening both would mean the fix was not a no-op; one reddening
# neither would mean it was never load-bearing.
m10_revert() {  # drop render-section's ansi-goto line and re-balance its parens
  mutlib "$1" lib/protocol/render.chiral \
    '/^    (let ((_ (put (ansi-goto row col))))$/d' \
    's|^                (render-to-ansi body dims none (+ row 1) (+ col rnd-section-indent) drow dcol amb))))))))))$|                (render-to-ansi body dims none (+ row 1) (+ col rnd-section-indent) drow dcol amb)))))))))|'
}
if m10_revert "M10 section-forgets-its-goto"; then
  if m10g5="$(g5_map "$MUTLIB")"; then
    if [ "$m10g5" = "$G5_WANT" ]; then ok "M10 section-forgets-its-goto -- G5 stays GREEN, so the fix really is a no-op first-on-row"
    else bad "M10 section-forgets-its-goto -- G5 went red, so the fix was NOT a no-op: $(echo "$m10g5" | tr '\n' ' | ')"; fi
  else bad "M10 section-forgets-its-goto -- the mutant G5 probe did not build"; fi
  if g4_run "$MUTLIB"; then
    g4_report quiet
    case " $G4_RED " in
      *" r-section "*) ok "M10 section-forgets-its-goto -- G4's r-section row goes RED (red:${G4_RED}), so the goto is load-bearing off the first column" ;;
      *)               bad "M10 section-forgets-its-goto -- G4's r-section row stayed GREEN (red:${G4_RED:- none}); the fix was never load-bearing" ;;
    esac
  else bad "M10 section-forgets-its-goto -- the mutant layout probes did not build"; fi
fi

# ============================================================================
# G6 -- THE SUM IS CLOSED, AND NO `_` ABSORBS THE NEW ARM.
#
# ⚑ BEHAVIOURAL, NOT A GREP.  A tenth constructor is appended to `Rendering`
# and NOTHING else is changed.  The compile of protocol/render must FAIL
# (diff-node and render-to-ansi) AND the compile of protocol/apc must FAIL
# (enc) -- both, separately asserted.  If either compiles, a catch-all has been
# added and the closed sum is buying nothing, which is the entire cost argument
# for this element.
echo
echo "=== E174 G6: a tenth constructor must break BOTH modules ==="
if mutlib "M5 tenth-constructor" lib/protocol/render.chiral \
     's|  (r-row    (children (List Rendering))))|  (r-row    (children (List Rendering)))\n  (r-fill   (body Rendering)))|'; then
  m5r="$(build_err "$MUTLIB" "$TMP/bare-render.prog")"
  m5a="$(build_err "$MUTLIB" "$TMP/bare-apc.prog")"
  if [ -n "$m5r" ]; then ok "M5 tenth-constructor -- protocol/render refuses it: $(echo "$m5r" | head -c 60)"
  else bad "M5 tenth-constructor -- protocol/render compiled clean; diff-node or render-to-ansi has a catch-all"; fi
  if [ -n "$m5a" ]; then ok "M5 tenth-constructor -- protocol/apc refuses it: $(echo "$m5a" | head -c 60)"
  else bad "M5 tenth-constructor -- protocol/apc compiled clean; enc has a catch-all"; fi
fi

# ============================================================================
# G7 -- E157's AND E158's GATES ARE BYTE-UNCHANGED, AND ALL THREE PHASES RUN.
#
# Pinned by sha256 rather than by a `git diff --stat` row: once these commits
# land the diff against them is empty forever and such a row reports ok for the
# rest of time.  E158's doc.sh already pins E157's pair; this pins E158's too,
# so each element's gate is held by the next one.
echo
echo "=== E174 G7: the E157 and E158 gates are byte-unchanged, and every phase still runs ==="
DIAG_SH_SHA=938897ecf553c73fb0ea80ed05afca43b96363861cdf53f8496caf78ac21509f
DIAG_FX_SHA=713fe84d51c149d491edf8289a5799206f44b0e925a28dc7f123ba3f7ab4171c
DOC_SH_SHA=4e20eb0a80d42a9a08745cbe2991cd2924315c361713194d31f1277cb371b405
DOC_FX_SHA=2a319302e79f4bf012b72f7f870069742df340d93618f6314d67c0a08d27eea8
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
# M8: append one line to a COPY of each pinned file.  EVERY pin must move -- a
# pin nobody has tested is a pin nobody has, and pinning three files while only
# exercising the fourth is the same hole one file smaller.
m8bad=0
for f in doc.sh samples/e158_doc.prog diag.sh samples/e157_diag.prog; do
  cp "$HERE/$f" "$TMP/m8"; printf '\n# a row E174 had no business adding\n' >>"$TMP/m8"
  case "$f" in
    doc.sh)                 m8w="$DOC_SH_SHA"  ;; samples/e158_doc.prog) m8w="$DOC_FX_SHA"  ;;
    diag.sh)                m8w="$DIAG_SH_SHA" ;; *)                     m8w="$DIAG_FX_SHA" ;;
  esac
  [ "$(sha_of "$TMP/m8")" != "$m8w" ] || m8bad=$((m8bad+1))
done
if [ "$m8bad" -eq 0 ]; then ok "M8 move-e158s-gate -- all four pins move when their file does"
else bad "M8 move-e158s-gate -- $m8bad pin(s) did not move"; fi

# THREE registration rows, not two: M9 deletes the run_phase 15 line, so
# without a Phase-15 row there is nothing for M9 to redden.  Asserted the way
# doc.sh asserts them -- the grep runs against run-tests.sh, a DIFFERENT FILE
# from the script doing the grep.  That, and not an assembled pattern, is what
# makes a registration row unable to match its own source.
RT="$REPO/tools/test/run-tests.sh"
reg() { grep -cE "^run_phase $1 .* $2\$" "$3"; }
for spec in "13 diag.sh E157" "14 doc.sh E158" "15 row.sh E174"; do
  # shellcheck disable=SC2086
  set -- $spec
  if [ "$(reg "$1" "$2" "$RT")" -ge 1 ]; then ok "Phase $1 ($3) is registered in run-tests.sh"
  else bad "Phase $1 ($3) is NOT registered in run-tests.sh -- an unregistered script never runs"; fi
done
# M9: strip all three run_phase lines from a copy.  Every row must notice.
cp "$RT" "$TMP/m9.sh"
sed -i '/^run_phase 13 /d;/^run_phase 14 /d;/^run_phase 15 /d' "$TMP/m9.sh"
if [ "$(reg 13 diag.sh "$TMP/m9.sh")" -eq 0 ] && [ "$(reg 14 doc.sh "$TMP/m9.sh")" -eq 0 ] \
   && [ "$(reg 15 row.sh "$TMP/m9.sh")" -eq 0 ]; then
  ok "M9 unregister-the-phase -- all three registration rows catch a deleted run_phase line"
else bad "M9 unregister-the-phase -- a deleted run_phase line was not caught"; fi

# ============================================================================
# G8 -- NAME CENSUS, TREE-WIDE.  E154: the emitted-label namespace is FLAT, so
# two co-blobbed modules cannot define the same internal name -- and E174 pulls
# protocol/utf8 into all seventeen of protocol/render's importers.
#
# ⚑ THIS IS THE ONE ROW GENUINELY AT SELF-MATCH RISK, and the device that
# removes it is doc.sh's, copied exactly: the pattern is anchored at COLUMN 0
# (`^\((def|data|declare) NAME[[:space:]]`), and M12's mutation is written as a
# `printf ... >>` line, so this script's own source can never satisfy the
# anchor.  Censusing tools/ while spelling a definition at the start of a line
# is exactly how a census row becomes unfalsifiable, in either direction.
#
# The names are READ OUT OF render.chiral -- its `def`/`data`/`declare` heads
# plus the Rendering constructors -- so a new binding is censused without
# editing this script.  The search is `grep -R`, NOT `grep -r`, which does not
# follow symlinks and would let a skipped file read as a clean census
# (MIGRATION-NOTES.md records this exact trap for diag.sh's G6).
echo
echo "=== E174 G8: every protocol/render.chiral name is defined exactly once, tree-wide ==="
rnd_ctors() {  # the Rendering constructors, read out of the data declaration
  LC_ALL=C awk '
    /^\(data Rendering \(\)/ { f=1 }
    f {
      line=$0; sub(/;.*/,"",line)
      if (line ~ /^[ \t]+\(r-/) { s=line; sub(/^[ \t]+\(/,"",s); sub(/[^A-Za-z0-9?!*<>=+-].*/,"",s); print s }
      o=gsub(/\(/,"",line); c=gsub(/\)/,"",line); d=d+o-c
      if (d<=0) exit
    }' "$1"
}
{ grep -oE '^\((def|data|declare) [^ ()]+' "$RND" | awk '{print $2}'
  rnd_ctors "$RND"
} | sort -u >"$TMP/rnames.txt"
nrn="$(grep -c . "$TMP/rnames.txt")"
nctor="$(rnd_ctors "$RND" | grep -c .)"
if [ "$nctor" -eq 9 ]; then ok "Rendering has exactly 9 constructors: $(rnd_ctors "$RND" | tr '\n' ' ')"
else bad "Rendering has $nctor constructors, wanted 9: $(rnd_ctors "$RND" | tr '\n' ' ')"; fi
# ...and the counter reads the FILE, proven the only way that claim can be:
# append a tenth constructor to a copy and the count must follow.  Without this
# the count row is a number nothing can move.
if mutlib "M5 tenth-constructor (the census half)" lib/protocol/render.chiral \
     's|  (r-row    (children (List Rendering))))|  (r-row    (children (List Rendering)))\n  (r-fill   (body Rendering)))|'; then
  n10="$(rnd_ctors "$MUTLIB/protocol/render.chiral" | grep -c .)"
  if [ "$n10" -eq 10 ]; then ok "M5 tenth-constructor (census half) -- the count follows the file: 10"
  else bad "M5 tenth-constructor (census half) -- the count read $n10 with a tenth arm present"; fi
fi

census() {  # census LIBDIR -> the DEFINING duplicate occurrences, one per line
  local lib="$1" out="$TMP/dd.txt" n
  : >"$out"
  while read -r n; do
    [ -n "$n" ] || continue
    ( cd "$REPO" && grep -RIn -E "^\((def|data|declare) ${n}[[:space:]]" "$lib" prog tools 2>/dev/null \
        | grep -v '/protocol/render\.chiral:' ) >>"$out" || true
  done <"$TMP/rnames.txt"
  sort -u "$out"
  rm -f "$out"
}
dupes="$(census "$REPO/lib")"
if [ -z "$dupes" ]; then ok "none of the $nrn protocol/render.chiral names is redefined anywhere in lib/ prog/ tools/"
else bad "protocol/render.chiral names redefined elsewhere:"; echo "$dupes" | sed 's/^/          /'; fi

# M12: REDEFINE rnd-cols in a sibling of the same blob.  If G8 cannot see this,
# it is censusing nothing.
m12lib="$TMP/m12lib"; rm -rf "$m12lib"; cp -a "$REPO/lib" "$m12lib"
printf '\n(def rnd-cols (-> Rendering I64) (lam (r) 0))\n' >>"$m12lib/prelude/string.chiral"
if [ -n "$(census "$m12lib")" ]; then ok "M12 redefine-rnd-cols -- the census catches the duplicate definition"
else bad "M12 redefine-rnd-cols -- the census did NOT catch a second definition of the width function"; fi

echo
echo "horizontal composition (E174): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
