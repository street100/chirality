#!/usr/bin/env bash
# render-doc.sh -- E158 commit 4: `doc->rendering`. The Phase 17 gate.
#
# PHASE 17, and 17 for the reason 14 was 14, 15 was 15 and 16 was 16: 8-12 are
# names still OWED to unported old-tree phases (run-tests.sh:18-22), and reusing
# one would make an unported gate look ported. 13/14/15/16 are taken.
#
# ⚑ WHY THIS IS NOT A ROW ADDED TO doc.sh. The E158 SPEC wrote G8/G9 as rows of
# Phase 14. They are not, because the four gate scripts diag.sh / doc.sh /
# row.sh / face.sh must stay byte-unchanged -- doc.sh carries sha256 pins over
# diag.sh, and this gate now carries pins over all four (G8). A new element gets
# a new phase; an old gate that moves stops being the control it was.
#
# ─── WHAT THIS ELEMENT IS, AND WHAT IT IS GRADED ON ─────────────────────────
#
# `doc->rendering : (-> I64 Doc Rendering)` -- E158's second exit. `Doc` does
# NOT unify with `Rendering` (SPEC decision 3); this converts. Its rule is
# `d-tag` -> `r-face`, and FLAG C is binding: it ships CORRECT FOR NESTED TAGS
# or it does not land.
#
# ⚑ THE SHORTCUT THIS GATE HAD TO BE BUILT AGAINST IS NOT THE ONE FLAG C NAMED,
# and this is the finding that shaped every row below. The cheap conversion
# carries the tag stack down the walk and re-wraps EVERY EMITTED LEAF in its
# whole stack -- `r-face kw (r-text "ab")`, `r-face kw (r-face cm (r-text
# "cd"))`, `r-face kw (r-text "ef")`. That output is screen-correct. It is also
# MEASURED to produce a cell map byte-for-byte IDENTICAL on the pre-E175
# emitter (`rnd-restore` reverted to a bare `ansi-reset`) as on the fixed one,
# because no `r-face` in it ever wraps more than one painted node -- so a gate
# written over that design would have passed on the broken emitter and called
# E175 an unused dependency. The implementation builds the TREE instead (one
# `r-face` per `d-tag` occurrence per line), and M4 below is the row that proves
# the tree needs E175: with the fix, cells (1,5)/(1,6) read {1,31}; without it,
# {}.
#
# ⚑ TWO KINDS OF ROW, because the element has two kinds of claim.
#   * A LOST CHARACTER is invisible to a cell map that is only asked about SGR,
#     and a re-run walk can drift from the one it re-runs. G1 reads the text
#     back out of the `Rendering` with an INDEPENDENT reader and requires it to
#     equal `doc->str` at five (document, width) pairs.
#   * A LOST FACE is invisible to the string half entirely. G3/G4 grade a CELL
#     MAP carrying the SGR REGISTER SET per painted cell -- the same reducer
#     face.sh uses, and G8 pins it byte-identical rather than trusting that.
#   * And the two are joined by G5: the screen, read back as text, IS the
#     string. That is the row `rnd-cols` can move and neither of the others can.
#
# ⚑ EVERY MUTANT PINS THE FULL VERDICT LINE, not just "some row went red". A
# mutant that reddens a row it was not paired with is the shape that produced
# nine toothless rows in this arc; a full-line pin makes that impossible to miss
# rather than merely unlikely. `verdict` prints all fifteen value rows at once.
#
#   G0  the fixture builds, exits 0, and paints                    [-]
#   G0p the layout PIN the rest of the gate is written against     [-]
#   G1  a-f  the text survives the conversion, 5 pairs + the
#            proof that the widths actually differ            [M1,M2]
#   G2  a-c  the tag TREE: row count and DFS pre-order face names
#                                                            [M3,M12]
#   G3  a,b  nested faces on the SCREEN -- the JOIN, and THE FLAG C
#            ROW: the outer face survives the inner close         [M4]
#   G4  a,b  one tag over TWO rows, and an UNTAGGED indent         [M5]
#   G5       the screen read back as text IS doc->str              [M6]
#   G6       the sum is closed: a 7th Doc arm must break this
#            file's compile                                       [M10]
#   G7       E154 census, tree-wide, `grep -R` not `grep -r`        [M7]
#   G8       the four neighbouring gates are byte-unchanged, the
#            SGR reducer is byte-identical to face.sh's, and
#            Phase 17 is registered                             [M8,M9]
#   G9       render-doc is OUTSIDE prog/compiler.prog's closure --
#            which is what says no fixpoint fires for it         [M11]
#
# ⚑ WHAT THIS GATE DOES NOT GRADE, stated because it bounds the rows.
# `doc->str`'s own laws (the flat law, width independence, the group decision)
# are Phase 14's and a row here would grade them twice -- G1 asserts the
# rendering AGREES with `doc->str`, not that `doc->str` is right. `rnd-cols`
# per se is Phase 15's; `rnd-restore` per se is Phase 16's. Display width is
# E177, `r-table`'s two layouts E178, the face registry E179, and a repaint
# landing inside a face E180.
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

FIXTURE="$HERE/samples/e158_render.prog"
RDOC="$REPO/lib/protocol/render-doc.chiral"
DOC="$REPO/lib/prelude/doc.chiral"
for f in "$FIXTURE" "$RDOC" "$DOC"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its fixture cannot fail"; exit 2; }
done
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

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
# into the tree under test -- nineteen phantom failures, measured, during this
# arc. Checked here rather than remembered.
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

# fld N FILE -> the Nth byte-1-separated field of FILE, verbatim.
fld() { LC_ALL=C awk -v n="$1" 'BEGIN{RS="\1"} NR==n{printf "%s",$0}' "$2"; }

# ---- the SGR-TRACKING screen reducer ---------------------------------------
# ⚑ A VERBATIM COPY of face.sh's, and G8 pins it byte-identical rather than
# asking a reader to believe it. There is no shell-library tier under
# tools/test/ and sourcing a sibling gate would RUN that gate, so a copy is the
# only form available -- which makes the copy's identity an invariant to check,
# not a smell to apologise for. row.sh carries a third variant (SCREEN_AWK) that
# treats SGR as a documented no-op; that one is deliberately different and is
# not compared here.
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

cell_sgr() { LC_ALL=C awk -v r="$2" -v c="$3" '$1==r && $2==c {print $4}' "$1"; }
cell_byte() { LC_ALL=C awk -v r="$2" -v c="$3" '$1==r && $2==c {print $3}' "$1"; }

# screen_text MAPFILE -> the painted cells laid back out as text lines, gaps
# filled with spaces. THE ROW THAT JOINS THE TWO HALVES: if `rnd-cols` and the
# emitter's column step ever disagree, a segment lands somewhere other than the
# offset `doc->str` puts that character at, and this reconstruction says so.
SCR_AWK='
{ r=$1+0; c=$2+0; b=$3; sub(/\/.*/,"",b)
  if (!(r in L)) L[r]=""
  while (length(L[r]) < c-1) L[r] = L[r] " "
  L[r] = substr(L[r],1,c-1) sprintf("%c", b+0) substr(L[r],c+1)
  if (r>mx) mx=r
  if (mn==0 || r<mn) mn=r }
END { for (r=mn; r<=mx; r++) print L[r] }'
screen_text() { LC_ALL=C awk "$SCR_AWK" "$1"; }

# ============================================================================
# `verdict LIBDIR` -> one line of fifteen `name:ok` / `name:bad` tokens, or
# `BUILD:fail`. Every mutant below pins this line IN FULL.
G0P="$(printf 'abcdef\nghij\n  klmn')"

verdict() {
  local lib="$1" raw="$TMP/v.raw" map="$TMP/v.map" ansi="$TMP/v.ansi" out="" k=""
  build_raw "$lib" "$FIXTURE" "$raw" || { echo "BUILD:fail"; return; }
  fld 14 "$raw" >"$ansi"
  sgr_screen "$ansi" >"$map"
  add() { out="$out${out:+ }$1:$2"; }
  eq()  { if [ "$2" = "$3" ]; then add "$1" ok; else add "$1" bad; fi; }
  ne()  { if [ "$2" != "$3" ]; then add "$1" ok; else add "$1" bad; fi; }
  cs()  { # cs NAME ROW COL WANT   -- one cell's SGR register set
          if [ "$(cell_sgr "$map" "$2" "$3")" = "$4" ]; then k="$k"; else k="x"; fi; }

  eq G0p "$(fld 1 "$raw")" "$G0P"
  eq G1a "$(fld 1 "$raw")" "$(fld 2  "$raw")"
  eq G1b "$(fld 3 "$raw")" "$(fld 4  "$raw")"
  eq G1c "$(fld 5 "$raw")" "$(fld 6  "$raw")"
  eq G1d "$(fld 7 "$raw")" "$(fld 8  "$raw")"
  eq G1e "$(fld 9 "$raw")" "$(fld 10 "$raw")"
  ne G1f "$(fld 1 "$raw")" "$(fld 3  "$raw")"
  eq G2a "$(fld 11 "$raw")" "3"
  eq G2b "$(fld 12 "$raw")" "keyword/comment/error/error"
  eq G2c "$(fld 13 "$raw")" "keyword/comment/error"
  # G3a -- the JOIN. `comment` states fg 2 and no attrs; inside `keyword`
  # (bold, fg 1) the register model must read {1,32}: attrs accumulate, the
  # inner's colour wins. Only a face nested INSIDE another produces this.
  k=""; cs x 1 3 "{1,32}"; cs x 1 4 "{1,32}"; if [ -z "$k" ]; then add G3a ok; else add G3a bad; fi
  # G3b -- ⚑ THE FLAG C ROW. `ef` is painted after the inner face CLOSED, with
  # nothing re-opening the outer, so it reads whatever the close restored. On
  # E175's emitter that is the ambient, {1,31}. On the emitter before it, {}.
  k=""; cs x 1 5 "{1,31}"; cs x 1 6 "{1,31}"; if [ -z "$k" ]; then add G3b ok; else add G3b bad; fi
  # G4a -- ONE `d-tag` over TWO output rows. The tag's body spans a brk-space
  # that broke, so `error` must face row 2 and row 3 both.
  k=""; cs x 2 1 "{4,31}"; cs x 2 4 "{4,31}"; cs x 3 3 "{4,31}"; cs x 3 6 "{4,31}"
  if [ -z "$k" ]; then add G4a ok; else add G4a bad; fi
  # G4b -- and the INDENT is untagged: the two leading cells of row 3 are
  # SPACES (byte 32) carrying no face. Facing the gutter would paint a
  # background colour across a region no `d-tag` covers.
  k=""; cs x 3 1 "{}"; cs x 3 2 "{}"
  [ "$(cell_byte "$map" 3 1)" = "32" ] || k="x"
  [ "$(cell_byte "$map" 3 2)" = "32" ] || k="x"
  if [ -z "$k" ]; then add G4b ok; else add G4b bad; fi
  eq G5 "$(screen_text "$map")" "$(fld 1 "$raw")"
  echo "$out"
}

ALLOK="G0p:ok G1a:ok G1b:ok G1c:ok G1d:ok G1e:ok G1f:ok G2a:ok G2b:ok G2c:ok G3a:ok G3b:ok G4a:ok G4b:ok G5:ok"

# ============================================================================
echo
echo "=== E158c4 G0-G5: the fixture, on the real tree -- fifteen rows in one line ==="
BASE="$(verdict "$REPO/lib")"
if [ "$BASE" = "$ALLOK" ]; then
  ok "all fifteen value rows hold: $BASE"
else
  bad "the value rows do NOT all hold"
  echo "          got:  $BASE"
  echo "          want: $ALLOK"
fi

# The cell map itself, printed once, because a gate that only reports ok/bad
# about a screen makes the screen unreadable to whoever has to fix it.
build_raw "$REPO/lib" "$FIXTURE" "$TMP/b.raw" && fld 14 "$TMP/b.raw" >"$TMP/b.ansi" \
  && sgr_screen "$TMP/b.ansi" >"$TMP/b.map" \
  && sed 's/^/          /' "$TMP/b.map"

# ============================================================================
# Each mutant names ONE corruption and pins the WHOLE verdict line it must
# produce. A mutant that reddens a row it was not paired with is caught by the
# same assertion that catches one that reddens nothing.
echo
echo "=== E158c4 the named mutants (a row whose mutant passes exercises nothing) ==="
mutant() {  # mutant NAME WANT-VERDICT REPO-REL-PATH SED-EXPR...
  local name="$1" want="$2" rel="$3"; shift 3
  mutlib "$name" "$rel" "$@" || return
  local got; got="$(verdict "$MUTLIB")"
  if [ "$got" = "$want" ]; then ok "$name -- $(echo "$got" | tr ' ' '\n' | grep -c ':bad') row(s) red, exactly the pinned ones"
  else
    bad "$name -- the verdict is not the pinned one"
    echo "          got:  $got"
    echo "          want: $want"
  fi
}

# M1 (G1) -- THE INDENT STOPS BEING EMITTED. `doc->str` writes "\n" plus i
# spaces; the rendering writes a row boundary plus a leading untagged segment.
# Drop the segment and the two exits carry different characters -- at every
# width whose layout has an indent, which is three of the five pairs.
mutant "M1 rdc-indent-returns-nil (the break indent stops being a segment)" \
  "G0p:ok G1a:bad G1b:ok G1c:bad G1d:bad G1e:ok G1f:ok G2a:ok G2b:ok G2c:ok G3a:ok G3b:ok G4a:bad G4b:bad G5:bad" \
  lib/protocol/render-doc.chiral \
  's|(true (cons (rdcs nil (str-pad "" i " ")) nil))|(true nil)|'

# M2 (G1) -- THE RE-RUN WALK STOPS AGREEING WITH THE ONE IT RE-RUNS. `rdc-best`
# always breaks; `doc-best` still decides. This is the ONLY thing standing
# between "one algorithm written twice" and two formatters, and it reddens
# exactly the wide-width pairs, where the group would have stayed flat.
mutant "M2 rdc-group-always-breaks (the re-run walk stops agreeing)" \
  "G0p:ok G1a:ok G1b:bad G1c:ok G1d:ok G1e:bad G1f:ok G2a:ok G2b:ok G2c:bad G3a:ok G3b:ok G4a:ok G4b:ok G5:ok" \
  lib/protocol/render-doc.chiral \
  's|(true  (rdc-best w k (cons (rdcf i (m-flat) b tg) rest) cur lines))|(true  (rdc-best w k (cons (rdcf i (m-brk) b tg) rest) cur lines))|'

# M3 (G2/G3) -- `d-tag` STOPS BECOMING `r-face`. The tree still has the right
# characters in the right places, so every G1 row and G5 stay GREEN. That
# asymmetry is why the cell rows exist at all: the string half is structurally
# blind to the entire ledger rule this element implements.
mutant "M3 rdc-tree-drops-the-face (d-tag no longer becomes r-face)" \
  "G0p:ok G1a:ok G1b:ok G1c:ok G1d:ok G1e:ok G1f:ok G2a:ok G2b:bad G2c:bad G3a:bad G3b:bad G4a:bad G4b:ok G5:ok" \
  lib/protocol/render-doc.chiral \
  's|(cons (r-face t (r-row (rdc-tree grp))) (rdc-tree after))|(cons (r-row (rdc-tree grp)) (rdc-tree after))|'

# M4 (G3) -- ⚑ THE E175 DEPENDENCE, MADE A ROW. `rnd-restore` reverts to the
# bare `ansi-reset` every close used to emit. Nothing about `doc->rendering`
# changes; the characters and their positions are untouched, so G1, G4 and G5
# all stay green. Only the two cells painted around a nested face move -- which
# is the whole of FLAG C, and the reason this commit could not land before E175.
mutant "M4 restore-resets (E175 reverted: the close clears the outer face)" \
  "G0p:ok G1a:ok G1b:ok G1c:ok G1d:ok G1e:ok G1f:ok G2a:ok G2b:ok G2c:ok G3a:bad G3b:bad G4a:ok G4b:ok G5:ok" \
  lib/protocol/render.chiral \
  's|(put (str-cat ansi-reset (face-sgr amb)))|(put ansi-reset)|'

# M5 (G4) -- THE NEWLINE GOES BACK TO BEING A CHARACTER. `rdc-break` conses the
# "\n"+indent onto the current line instead of starting a new row. ⚑ Every G1
# row STAYS GREEN, because the reconstructed text is byte-identical -- this is
# precisely the E158 defect (structure flattened into a string) reappearing
# inside E158's own exit, and the string law cannot see it. The row count and
# the screen can.
mutant "M5 rdc-break-emits-a-newline-segment (the row boundary flattens)" \
  "G0p:ok G1a:ok G1b:ok G1c:ok G1d:ok G1e:ok G1f:ok G2a:bad G2b:ok G2c:ok G3a:ok G3b:ok G4a:bad G4b:bad G5:bad" \
  lib/protocol/render-doc.chiral \
  's|(rdc-best w i rest (rdc-indent i) (rdc-flush cur lines))|(rdc-best w i rest (cons (rdcs nil (nl-indent i)) cur) lines)|'

# M6 (G5) -- `rnd-cols` LIES BY ONE ABOUT A FACED NODE. Nothing structural
# moves: the same characters, the same faces, the same rows. The segments after
# a faced one simply land one column right of where `doc->str` puts them, and
# ONLY the reconstruction can see it. E174's Phase 15 grades `rnd-cols` on its
# own; this row grades the thing E158 depends on it FOR.
mutant "M6 rnd-cols-face-off-by-one (a faced node over-reports its width)" \
  "G0p:ok G1a:ok G1b:ok G1c:ok G1d:ok G1e:ok G1f:ok G2a:ok G2b:ok G2c:ok G3a:ok G3b:bad G4a:ok G4b:ok G5:bad" \
  lib/protocol/render.chiral \
  's|      ((r-face face-name body) (rnd-cols body)))))|      ((r-face face-name body) (+ 1 (rnd-cols body))))))|'

# M12 (G2/G3) -- THE NESTING ORDER INVERTS. The tag stack is built with `cons`
# instead of `append`, so it is innermost-first and `rdc-tree` peels the INNER
# face first: `comment` ends up OUTSIDE `keyword`. Same characters, same rows,
# same columns -- G1, G4 and G5 all green -- and the JOIN reads {1,31} instead
# of {1,32}. ⚑ G3b stays GREEN here, which is exactly why G3a is a separate
# row: an inverted nesting still restores *something* after the inner close.
mutant "M12 rdc-tags-cons-not-append (the nesting order inverts)" \
  "G0p:ok G1a:ok G1b:ok G1c:ok G1d:ok G1e:ok G1f:ok G2a:ok G2b:bad G2c:bad G3a:bad G3b:ok G4a:ok G4b:ok G5:ok" \
  lib/protocol/render-doc.chiral \
  's|(append Str tg (cons n nil))|(cons n tg)|'

# ============================================================================
# The closed sum. `rdc-best` and `rdc-tree` carry no `_` arm, so a new `Doc`
# constructor must BREAK this file rather than be silently ignored -- which is
# the entire reason the cost of adding one is knowable.
echo
echo "=== E158c4 G6: a seventh Doc constructor must break render-doc's compile ==="
cat >"$TMP/bare.prog" <<'BARE'
(import "protocol/render-doc")
(def compile-main (-> I64 I64) (lam (n) 42))
BARE
g6err="$(build_err "$REPO/lib" "$TMP/bare.prog")"
if [ -z "$g6err" ]; then ok "G6 control -- protocol/render-doc compiles clean on the unmutated tree"
else bad "G6 control -- protocol/render-doc does NOT compile: $(echo "$g6err" | head -c 160)"; fi

if mutlib "M10 add-seventh-Doc-constructor" lib/prelude/doc.chiral \
     's|  (d-tag   (name Str) (body Doc)))|  (d-tag   (name Str) (body Doc))\n  (d-fill  (body Doc)))|'; then
  m10err="$(build_err "$MUTLIB" "$TMP/bare.prog")"
  if [ -n "$m10err" ]; then ok "M10 add-seventh-Doc-constructor -- refused: $(echo "$m10err" | head -c 90)"
  else bad "M10 add-seventh-Doc-constructor -- a 7th Doc arm compiled clean; render-doc's closed case buys nothing"; fi
fi

# ============================================================================
# E154: the emitted-label namespace is FLAT. `protocol/render-doc` co-blobs with
# `protocol/render` AND `prelude/doc`, so a name it introduces must not exist
# anywhere else. The names are read out of the file itself, so a new binding is
# censused without editing this script, and the search is `grep -R` -- NOT
# `grep -r`, which does not follow symlinks and would let a skipped file read as
# a clean census (MIGRATION-NOTES.md records that exact trap for diag.sh's G6).
echo
echo "=== E158c4 G7: E154 -- every render-doc.chiral name is defined exactly once ==="
{ grep -oE '^\((def|data|declare) [^ ()]+' "$RDOC" | awk '{print $2}'
  grep -oE '\((rdcf|rdcs)[A-Za-z0-9?!*<>=+-]*' "$RDOC" | sed 's/^(//'
} | sort -u >"$TMP/rnames.txt"
nrnames="$(grep -c . "$TMP/rnames.txt")"

rcensus() {  # rcensus LIBDIR -> the DEFINING duplicate occurrences, one per line
  local lib="$1" out="$TMP/rd.$$"
  : >"$out"
  while read -r n; do
    [ -n "$n" ] || continue
    ( cd "$REPO" && grep -RIn -E "^\((def|data|declare) ${n}[[:space:]]" "$lib" prog tools 2>/dev/null \
        | grep -v '/protocol/render-doc\.chiral:' ) >>"$out" || true
  done <"$TMP/rnames.txt"
  sort -u "$out"
  rm -f "$out"
}
rdupes="$(rcensus "$REPO/lib")"
if [ -z "$rdupes" ]; then ok "none of the $nrnames render-doc.chiral names is redefined anywhere in lib/ prog/ tools/"
else bad "render-doc.chiral names redefined elsewhere:"; echo "$rdupes" | sed 's/^/          /'; fi

# M7: REDEFINE `doc->rendering` in a co-blobbed sibling. If G7 cannot see this,
# it is censusing nothing.
#
# ⚑ THE INJECTED LINE IS ASSEMBLED FROM TWO FRAGMENTS, and this row is why the
# rule exists. Spelled out, `(declare doc->rendering ...)` sat at the start of a
# line in THIS FILE -- and the census greps `tools/` -- so G7 reported its own
# mutant's sed expression as a duplicate definition and went red on a clean
# tree. Measured, not anticipated: the first run of this gate failed here.
M7INJ="(declare doc""->rendering (-> I64 Doc Rendering))"
if mutlib "M7 redefine-doc-to-rendering" lib/protocol/render.chiral \
     "\$a${M7INJ}"; then
  m7="$(rcensus "$MUTLIB")"
  if [ -n "$m7" ]; then ok "M7 redefine-doc-to-rendering -- census catches the duplicate declaration"
  else bad "M7 redefine-doc-to-rendering -- census did NOT catch a second declaration"; fi
fi

# ============================================================================
# The neighbouring gates. This element adds a phase; it must move NONE of the
# four that exist, and it must actually be registered -- an unregistered script
# is a gate that never runs, and a phase that silently vanishes reports ok
# forever.
echo
echo "=== E158c4 G8: the four existing gates are byte-unchanged, and Phase 17 runs ==="
# ⚑ The pins are the sha256 of the four gate scripts AS OF THIS ELEMENT. doc.sh
# already pins diag.sh; this pins all four, so a later element cannot quietly
# reword one of them and leave this gate's expectations describing a file that
# no longer exists.
PINS="f50f2ff82f533b13f1eadc23edb69ffde30511ea26796b60f1bddb9a468808fe  diag.sh
d4feea4ae7a95c66b9e7cb854f5306096682d22ad786968a14023df9ac8e5686  doc.sh
00aa631da299a711fc611c32324ffa9da56b5225995c3dc52e5fd62f10efc0b4  row.sh
7733277092446b7a0a6a34307b73af01c91d8e79d9345de964bc715e4d52b07c  face.sh"
pin_check() {  # pin_check DIR -> "" when every pin matches, else the offenders
  local dir="$1" n h
  echo "$PINS" | while read -r h n; do
    [ -n "$n" ] || continue
    if [ ! -f "$dir/$n" ]; then echo "$n MISSING"
    elif [ "$(sha256sum <"$dir/$n" | cut -d' ' -f1)" != "$h" ]; then echo "$n MOVED"; fi
  done
}
pin_bad="$(pin_check "$HERE")"
if [ -z "$pin_bad" ]; then ok "diag.sh, doc.sh, row.sh and face.sh are byte-unchanged (4 sha256 pins)"
else bad "a neighbouring gate moved:"; echo "$pin_bad" | sed 's/^/          /'; fi

# M8: the pin checker must be able to SEE a changed file. Without this row, the
# four pins are asserting that sha256sum is deterministic.
mkdir -p "$TMP/pins"; cp "$HERE"/diag.sh "$HERE"/doc.sh "$HERE"/row.sh "$HERE"/face.sh "$TMP/pins/"
printf '\n# mutant\n' >>"$TMP/pins/face.sh"
m8="$(pin_check "$TMP/pins")"
case "$m8" in
  *"face.sh MOVED"*) ok "M8 touch-a-pinned-gate -- the pin checker sees the changed byte" ;;
  *) bad "M8 touch-a-pinned-gate -- the pin checker reported '$m8'; it cannot see a change" ;;
esac

# The SGR reducer above is a verbatim copy of face.sh's. Pinned as a copy, not
# assumed to be one: two decoders that drift apart would make Phase 16 and
# Phase 17 describe two different screens.
sed -n "/^SGR_AWK='/,/}'\$/p" "$HERE/face.sh"       >"$TMP/awk.face"
sed -n "/^SGR_AWK='/,/}'\$/p" "$HERE/render-doc.sh" >"$TMP/awk.this"
if [ ! -s "$TMP/awk.face" ] || [ ! -s "$TMP/awk.this" ]; then
  bad "the SGR reducer could not be extracted from one of the two gates -- an empty compare passes for free"
elif cmp -s "$TMP/awk.face" "$TMP/awk.this"; then
  ok "the SGR reducer is byte-identical to face.sh's ($(wc -l <"$TMP/awk.this") lines)"
else
  bad "the SGR reducer has drifted from face.sh's"; diff "$TMP/awk.face" "$TMP/awk.this" | sed 's/^/          /'
fi

# The registration. The needle is ASSEMBLED so this row cannot match its own
# source line -- the trap that produced nine toothless rows in this arc.
RP="run_""phase 17"
reg_scan() { grep -c -F -- "$RP" "$1"; }
if [ "$(reg_scan "$HERE/run-tests.sh")" -ge 1 ]; then ok "Phase 17 is registered in run-tests.sh"
else bad "Phase 17 is NOT registered in run-tests.sh -- an unregistered gate never runs"; fi

# M9: the registration scanner must be able to see the line GONE.
grep -v -F -- "$RP" "$HERE/run-tests.sh" >"$TMP/rt-nophase17.sh"
if [ "$(reg_scan "$TMP/rt-nophase17.sh")" -eq 0 ]; then ok "M9 drop-the-registration -- the scanner sees the missing line"
else bad "M9 drop-the-registration -- the scanner still counts a registration that is gone"; fi

# ============================================================================
# The BUILD RULE, as a row. `prelude/doc` IS inside prog/compiler.prog's import
# closure (typing/diag imports it); `protocol/render` is NOT, and therefore
# neither is `protocol/render-doc`. That is what says no self-hosting fixpoint
# fires for this element -- and "outside the closure" is exactly the kind of
# claim that is true when written and false three commits later.
echo
echo "=== E158c4 G9: render-doc is OUTSIDE prog/compiler.prog's blob closure ==="
# Assembled, so this row does not match its own source line.
NEEDLE="(data ""RdcSeg ()"
blob_has() {  # blob_has LIBDIR -> 1 when the compiler blob contains render-doc
  ( cd "$REPO" && chirality_blob_file "$1:$REPO/prog" prog/compiler.prog ) 2>/dev/null \
    | grep -c -F -- "$NEEDLE"
}
if [ "$(blob_has "$REPO/lib")" -eq 0 ]; then
  ok "prog/compiler.prog's blob does not contain protocol/render-doc -- no fixpoint obligation"
else
  bad "protocol/render-doc IS in the compiler blob -- this element now carries a self-hosting cmp"
fi

# M11: put the import in, and the scan must SEE it. Without this row the scan
# would pass on a needle that matches nothing anywhere.
if mutlib "M11 import-render-doc-into-the-compiler" lib/typing/diag.chiral \
     's|^(import "prelude/doc")|(import "prelude/doc")\n(import "protocol/render-doc")|'; then
  if [ "$(blob_has "$MUTLIB")" -ge 1 ]; then ok "M11 import-render-doc-into-the-compiler -- the closure scan sees it arrive"
  else bad "M11 import-render-doc-into-the-compiler -- the closure scan is blind; it would pass on any needle"; fi
fi

echo
echo "doc->rendering (E158 commit 4): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
