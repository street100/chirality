#!/usr/bin/env bash
# pretty.sh -- E181: the term printer. The Phase 18 gate.
#
# PHASE 18, and 18 for the reason 17 was 17: 8-12 are names still OWED to
# unported old-tree phases (run-tests.sh:18-22), and reusing one would make an
# unported gate look ported. 13-17 are taken.
# docs/decisions/decision-lane-split.md:30 gives Lane A 18/19/20.
#
# ─── WHAT THIS ELEMENT IS, AND WHAT IT IS GRADED ON ─────────────────────────
#
# `lib/surface/pretty.chiral` walks the REAL sixteen-constructor `Term`
# (surface/syntax:18-34) and returns a `Doc`. Its output IS chirality source --
# there is no second "readable" form, because the surface is S-expressions.
#
# ⚑ EVERY ROW HERE READS EMITTED BYTES. The classic toothless shape for a
# printer gate is a row that walks the produced `Doc` and checks it has the
# constructors you expected: the same information twice, green under any mutant
# that changes what those constructors SAY. So the fixture PRINTS and asserts
# nothing (it always exits 0), and every comparison below is in bash over the
# bytes it printed.
#
#   G1   all sixteen formers byte-exact at width 10^6, plus KArm,
#        RfAtom and the dc-ty site -- twenty goldens     [M1,M18-M25]
#   G2   `brk-soft` is never correct between atoms: the TOKEN
#        SEQUENCE is width-independent                             [M2]
#   G3   the group decision and the indent, on a real term      [M3,M4]
#   G4   the application spine is FLAT                             [M5]
#   G5   the quantity is always printed -- the evidence row        [M6]
#   G6   no invented name shadows a FREE one                       [M7]
#   G7   arm binders agree with the elaborator's push order        [M8]
#   G8   adoption is real and the frozen gates did not move [M9,M10,M11]
#   G9   the file is IMPORTABLE -- refused twice over before  [M12,M13]
#   G10  no cross-assertion on E157's wording                     [M14]
#   G11  E154 census, tree-wide, for every `pp-` name             [M15]
#   G11b neither `str-sub` nor `str-starts-with` is CALLED        [M16]
#   G12  the BUILD RULE's one checkable guard: a `cmp` of two
#        empty files must be REFUSED, not passed              (control)
#   G13  the HOME: `surface/pretty`, and it closes no cycle       [M17]
#
# ⚑ THE SEVENTEENTH-CONSTRUCTOR MUTANT IS NOT A ROW HERE, and that is measured
# rather than argued. `Term` is cased exhaustively by four OTHER modules in the
# same blob, so a seventeenth former already refuses `prog/compiler.prog` with
# `load: non-exhaustive case` on the un-E181'd tree -- it would redden
# identically if `pp-term` had a `_` catch-all, which makes it a false row.
# Coverage is asserted by ARM DELETION, one arm at a time (M1).
#
# ⚑ NEEDLES ARE ASSEMBLED FROM FRAGMENTS wherever a row greps under `tools/`.
# Phase 17's E154 census went red on a CLEAN tree once because a mutant's own
# `sed` expression spelled a definition at the start of a line inside the gate
# script, and the census greps `tools/`. This gate greps `tools/` too.
#
# Zero Python.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"

CC="${CHIRALITY_COMPILE:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
[ -x "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
# shellcheck disable=SC1091
. "$REPO/bin/chirality-resolve.sh"

FIXTURE="$HERE/samples/e181_pretty.prog"
PRETTY="$REPO/lib/surface/pretty.chiral"
DIAG="$REPO/lib/typing/diag.chiral"
for f in "$FIXTURE" "$PRETTY" "$DIAG"; do
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
# mutated, left in $MUTLIB.
#
# ⚑ THE SCRATCH lib/ MUST BE A REAL DIRECTORY, NEVER A SYMLINK. `cp -a` copies a
# symlink AS a symlink, and every subsequent `sed -i` then writes THROUGH it into
# the tree under test -- nineteen phantom failures, measured, during this arc.
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

# blk LABEL FILE -> the bytes of one ==BEGIN label== .. ==END== block
blk() {
  awk -v l="==BEGIN $1==" 'BEGIN{p=0} $0==l{p=1;next} p&&$0=="==END=="{exit} p{print}' "$2"
}

# toks FILE LABEL -> the block's token sequence, `is-delim`'s way
# (sexp.chiral:74): an atom ENDS at whitespace, `(`, `)`, `"` or `;`.
# ⚑ WHITESPACE IS A DELIMITER AND IS NEVER DELETED. This row was first drafted
# with doc.sh's `dt-strip-ws`, which removes every whitespace byte -- exactly the
# byte M2 removes -- so `(type 0)` and `(type0)` both mapped to `(type0)` and the
# row passed either way. That inversion IS the row.
toks() {
  blk "$2" "$1" | sed -e 's/[()";]/ & /g' | tr -s ' \t\n' '\n' | sed '/^$/d' | tr '\n' '|'
}

# ---- the baseline run ------------------------------------------------------
OUT="$TMP/base.out"
if build_raw "$REPO/lib" "$FIXTURE" "$OUT"; then
  ok "the fixture builds and runs against lib/ ($(wc -c <"$OUT") bytes emitted)"
else
  bad "the fixture did not build+run -- every row below is vacuous"; echo "assertions: $pass passed, $((fail+1)) failed"; exit 1
fi

# expect LABEL EXPECTED
# ⚑ IT RECORDS AS IT GRADES.  M18-M25 below re-run G1's own comparison over a
# mutated tree, and a golden re-spelled beside those mutants would be a want the
# mutation cannot reach -- the defect tools/test/arity.sh:75-79 names.  There is
# one spelling of each golden and it is the argument here.
G1_LABELS=""
declare -A G1_WANT=()
expect() {
  G1_LABELS="$G1_LABELS $1"; G1_WANT["$1"]="$2"
  local got; got="$(blk "$1" "$OUT")"
  if [ "$got" = "$2" ]; then ok "G1 $1 -> $(printf '%s' "$2" | head -1)$( [ "$(printf '%s\n' "$2" | wc -l)" -gt 1 ] && printf ' (+%s more lines)' "$(( $(printf '%s\n' "$2" | wc -l) - 1 ))")"
  else bad "G1 $1 -- got [$got] want [$2]"; fi
}

echo
echo "=== E181 G1: all sixteen Term formers, byte-exact at width 10^6 ==="
# ⚑ Byte-exact goldens are LEGAL here and this is not a contradiction of
# doc.sh:11-16. That header refuses to inherit E157's byte-identity because
# `dg-msg`'s WORDING is a choice and pinning a choice freezes it. `pp-term`'s
# output is not a wording: `(lam (x0) x0)` IS the grammar. Pinning it pins the
# language, which is the thing that must not drift. Every string below was
# written from the grammar (parse.chiral's head-symbol dispatch) BEFORE the
# implementation ran, and matched byte-for-byte on the first build.
expect w6-01 '(lam (x0) x0)'
expect w6-02 '(type 0)'
expect w6-03 '(-> (1 x0 I64) Str)'
expect w6-04 '(=> (w x0 I64) x0)'
expect w6-05 '(f a b)'
expect w6-06 '(let (w x0 1) x0)'
expect w6-07 '(the I64 1)'
expect w6-08 'f'
expect w6-09 'str-cat'
expect w6-10 'I64'
expect w6-11 '42'
expect w6-12 '"a\nb\"c\\d\te"'
expect w6-13 'Nil'
expect w6-14 '(mk 1)'
expect w6-15 'Unit'
expect w6-16 '(List I64)'
# `t-var` is graded INSIDE a binder (w6-01) and OUT OF SCOPE here: two code
# paths. `#0` is the one output that is not source, and it is kept on purpose --
# a printer that crashes on an out-of-range index is worse than one that says so.
expect w6-17 '(case
  #0
  ((Nil) 0)
  ((Cons x0 x1) (x0 x1))
  (_ 9))'
expect w6-18 '(refine I64 (> 3))'
expect w6-19 '(lam (xxx0) (x0 xxx0))'
# the dc-ty site: changed by E181 and graded by NOTHING before it.
# samples/e158_doc.prog's rows 5 and 6 use dc-data.
expect w6-20 'declared type I64'
# the contagious hard break, as a ROW rather than a footnote: a `case` does not
# merely print multi-line, it makes every ENCLOSING form multi-line at every
# width, because `doc-fits` refuses a hard break anywhere inside the group it
# measures (doc.chiral:131). Accepted: a `case` IS structurally multi-line.
expect w6-22 '(lam
  (x0)
  (case
    x0
    ((Nil) 0)))'

# M1: coverage by ARM DELETION. One arm, paren-balanced, nothing else.
echo
if mutlib "M1" lib/surface/pretty.chiral '/^      ((t-lit-i v)   (d-tag "term-lit" (d-text (i64->str v))))$/d'; then
  e="$(build_err "$MUTLIB" "$FIXTURE")"
  case "$e" in
    *"non-exhaustive case"*) ok "M1 delete-a-pp-term-arm -- $(printf '%s' "$e" | head -1)" ;;
    *) bad "M1 delete-a-pp-term-arm -- expected 'non-exhaustive case', got [$(printf '%s' "$e" | head -1)]" ;;
  esac
fi

# ============================================================================
# M18-M25: THE EIGHT LEAF GOLDENS, EACH WITH A MUTANT THAT REDDENS IT.
#
# M1 deletes an arm, and a non-exhaustive `case` in pretty.chiral refuses the
# whole module: the fixture stops building and NO golden moves.  So the atom and
# leaf formers -- the ones whose printed bytes ARE the whole row, with no
# enclosing form to carry them -- had no falsifier anywhere in this file.
# records/gate-audit.md GA-13 measured the eight: w6-08, w6-09, w6-10, w6-11,
# w6-12, w6-13, w6-15 and w6-20.
#
# Each mutant below changes ONE leaf's printed bytes and compiles clean, and
# each pins the FULL SET of goldens that move, the idiom matcher.sh:25-27 and
# arity.sh:23-26 use on their verdict lines.  Collateral is real and is written
# down rather than tolerated: `I64` is a `t-primty` inside six other goldens and
# `42` is a `t-lit-i` inside six more, so a mutant of either moves its own row
# and theirs.  A mutant that reddened some OTHER row and left its own green is
# then a FAIL of that mutant's row.
#
# ⚑ `nobuild` IS NOT A CONVICTION.  `g1_reds` answers `BUILD:fail` for a mutant
# that did not compile and no pin below holds that token, so a mutant that
# merely broke the syntax cannot wear a red set.

# g1_reds LIBDIR -> the G1 labels whose golden moved, or BUILD:fail
g1_reds() {
  local out="$TMP/g1m.out" l r=""
  build_raw "$1" "$FIXTURE" "$out" || { printf 'BUILD:fail'; return; }
  for l in $G1_LABELS; do
    [ "$(blk "$l" "$out")" = "${G1_WANT[$l]}" ] || r="$r $l"
  done
  printf '%s' "${r# }"
}

g1_mutant() {  # g1_mutant NAME WANT-REDS REPO-REL-PATH SED-EXPR...
  local name="$1" want="$2" rel="$3"; shift 3
  mutlib "$name" "$rel" "$@" || return
  local got; got="$(g1_reds "$MUTLIB")"
  if [ "$got" = "$want" ]; then ok "$name -- reddens exactly [$got]"
  else
    bad "$name -- the red set is not the pinned one"
    echo "          got:  [$got]"
    echo "          want: [$want]"
  fi
}

echo
echo "=== E181 G1's leaf goldens: eight mutants, each pinning the SET it reddens ==="
g1_mutant "M18 t-global-prints-a-constant" "w6-05 w6-08 w6-19" \
  lib/surface/pretty.chiral \
  's|((t-global n)  (d-tag "term-name" (d-text n)))|((t-global n)  (d-tag "term-name" (d-text "?g")))|'

g1_mutant "M19 t-prim-prints-a-constant" "w6-09" \
  lib/surface/pretty.chiral \
  's|((t-prim n)    (d-tag "term-name" (d-text n)))|((t-prim n)    (d-tag "term-name" (d-text "?p")))|'

g1_mutant "M20 t-primty-prints-a-constant" "w6-03 w6-04 w6-07 w6-10 w6-16 w6-18 w6-20" \
  lib/surface/pretty.chiral \
  's|((t-primty n)  (d-tag "term-name" (d-text n)))|((t-primty n)  (d-tag "term-name" (d-text "?t")))|'

# The off-by-one rather than a constant: an integer literal printed one too high
# is the corruption a golden of `42` exists to catch, and it stays an integer so
# nothing downstream re-lexes differently.
g1_mutant "M21 t-lit-i-is-one-too-high" "w6-06 w6-07 w6-11 w6-14 w6-17 w6-18 w6-22" \
  lib/surface/pretty.chiral \
  's|((t-lit-i v)   (d-tag "term-lit" (d-text (i64->str v))))|((t-lit-i v)   (d-tag "term-lit" (d-text (i64->str (+ v 1)))))|'

# w6-12 is the escaped-string golden and this is the mutant it was written for:
# the quoting and escaping are dropped, so the literal prints as its own bytes
# and the output stops being source.
g1_mutant "M22 t-lit-s-drops-the-quoting" "w6-12" \
  lib/surface/pretty.chiral \
  's|((t-lit-s v)   (d-tag "term-lit" (d-text (pp-quote v))))|((t-lit-s v)   (d-tag "term-lit" (d-text v)))|'

# The two NULLARY arms, which print bare.  Their applied arms are covered by
# w6-14 and w6-16; before these two the bare spelling was graded by nothing.
g1_mutant "M23 nullary-ctor-prints-a-constant" "w6-13" \
  lib/surface/pretty.chiral \
  's|          (nil (d-tag "term-name" (d-text cn)))|          (nil (d-tag "term-name" (d-text "?c")))|'

g1_mutant "M24 nullary-tcon-prints-a-constant" "w6-15" \
  lib/surface/pretty.chiral \
  's|          (nil (d-tag "term-name" (d-text dn)))|          (nil (d-tag "term-name" (d-text "?d")))|'

# w6-20 is the dc-ty site, and it is the one golden whose bytes come from
# typing/diag rather than from the printer.  Its mutant lives there too.
g1_mutant "M25 dc-ty-loses-its-word" "w6-20" \
  lib/typing/diag.chiral \
  's|                    (cons (d-text " type ")|                    (cons (d-text " ty ")|'

echo
echo "=== E181 G2: the token sequence is width-independent ==="
# `brk-soft` between two ATOMS fuses them into one token at a wide width while a
# narrow width still breaks -- so the two widths disagree, and that disagreement
# is the whole row. Not `lam`/`x0`: `(` ends an atom, so `(lam(x0)...)` re-lexes
# correctly. The fusion is only ever between two atoms.
g2_rows="01 02 03 04 05 06 07 13 14 16 17 18 19 21"
g2_bad=""
for r in $g2_rows; do
  a="$(toks "$OUT" "w6-$r")"; b="$(toks "$OUT" "w12-$r")"
  [ "$a" = "$b" ] || g2_bad="$g2_bad $r"
done
if [ -z "$g2_bad" ]; then ok "G2 the token sequence at width 10^6 equals the one at width 12 ($(echo $g2_rows | wc -w) rows)"
else bad "G2 token sequences differ at rows:$g2_bad"; fi

if mutlib "M2" lib/surface/pretty.chiral 's/(pp-lines (brk-space)/(pp-lines (brk-soft)/g'; then
  m2="$TMP/m2.out"
  if build_raw "$MUTLIB" "$FIXTURE" "$m2"; then
    m2_seen=""
    for r in $g2_rows; do
      a="$(awk -v l="==BEGIN w6-$r==" 'BEGIN{p=0} $0==l{p=1;next} p&&$0=="==END=="{exit} p{print}' "$m2" | sed -e 's/[()";]/ & /g' | tr -s ' \t\n' '\n' | sed '/^$/d' | tr '\n' '|')"
      b="$(awk -v l="==BEGIN w12-$r==" 'BEGIN{p=0} $0==l{p=1;next} p&&$0=="==END=="{exit} p{print}' "$m2" | sed -e 's/[()";]/ & /g' | tr -s ' \t\n' '\n' | sed '/^$/d' | tr '\n' '|')"
      [ "$a" = "$b" ] || m2_seen="$m2_seen $r"
    done
    if [ -n "$m2_seen" ]; then
      ok "M2 soft-break-between-atoms -- the row convicts at$m2_seen; at width 10^6: $(blk w6-02 "$m2") $(blk w6-05 "$m2") $(blk w6-07 "$m2")"
    else
      bad "M2 soft-break-between-atoms -- the token-sequence row did NOT convict; it is toothless"
    fi
  else bad "M2 soft-break-between-atoms -- the mutant did not build"; fi
fi

echo
echo "=== E181 G3: the group decision and the indent, on a real term ==="
[ "$(blk w40-21 "$OUT")" = '(frobnicate alpha beta gamma)' ] \
  && ok "G3 (frobnicate alpha beta gamma) is ONE line at width 40" \
  || bad "G3 width 40 -- got [$(blk w40-21 "$OUT")]"
[ "$(blk w12-21 "$OUT")" = '(frobnicate
  alpha
  beta
  gamma)' ] && ok "G3 at width 12 it is one argument per line, indent exactly 2" \
  || bad "G3 width 12 -- got [$(blk w12-21 "$OUT")]"

if mutlib "M3" lib/surface/pretty.chiral '/^(def pp-call /,/^$/ s/(d-group$/(d-nest 0/'; then
  m3="$TMP/m3.out"
  if build_raw "$MUTLIB" "$FIXTURE" "$m3"; then
    if [ "$(blk w40-21 "$m3")" != '(frobnicate alpha beta gamma)' ]; then
      ok "M3 pp-call-loses-its-group -- broken at width 40 too: [$(blk w40-21 "$m3" | tr '\n' '/')]"
    else bad "M3 pp-call-loses-its-group -- width 40 is still one line; G3 is toothless"; fi
  else bad "M3 pp-call-loses-its-group -- the mutant did not build"; fi
fi

if mutlib "M4" lib/surface/pretty.chiral '/^(def pp-call /,/^$/ s/(d-nest 2 /(d-nest 0 /'; then
  m4="$TMP/m4.out"
  if build_raw "$MUTLIB" "$FIXTURE" "$m4"; then
    ind="$(blk w12-21 "$m4" | sed -n '2p')"
    case "$ind" in
      alpha*) ok "M4 pp-call-loses-its-nest -- indent 0: 'alpha' at column 1" ;;
      *)      bad "M4 pp-call-loses-its-nest -- second line is [$ind]; the indent row is toothless" ;;
    esac
  else bad "M4 pp-call-loses-its-nest -- the mutant did not build"; fi
fi

echo
echo "=== E181 G4: the application spine is FLAT ==="
[ "$(blk w6-05 "$OUT")" = '(f a b)' ] \
  && ok "G4 (t-app (t-app f a) b) prints (f a b), not ((f a) b)" \
  || bad "G4 -- got [$(blk w6-05 "$OUT")]"
if mutlib "M5" lib/surface/pretty.chiral \
   's/((t-app f a) (pp-call (pp-spine p ns f (cons (pp-term p ns a) nil))))/((t-app f a) (pp-call (cons (pp-term p ns f) (cons (pp-term p ns a) nil))))/'; then
  m5="$TMP/m5.out"
  if build_raw "$MUTLIB" "$FIXTURE" "$m5"; then
    [ "$(blk w6-05 "$m5")" = '((f a) b)' ] \
      && ok "M5 binary-app-arm -- the Python baseline's shape gives ((f a) b)" \
      || bad "M5 binary-app-arm -- got [$(blk w6-05 "$m5")], expected ((f a) b)"
  else bad "M5 binary-app-arm -- the mutant did not build"; fi
fi

echo
echo "=== E181 G5: the quantity is ALWAYS printed -- the evidence row ==="
# doc.sh case 14 one layer down. BOTH forms round-trip (parse-binder/parse-lbind
# default to `2` = qw when the token is absent), so this row asserts a CHOICE
# ABOUT EVIDENCE and it must be able to fail. Eliding by default is the printer
# deciding on the reader's behalf; the quantity rides in a zero-width
# `d-tag "term-qty"` so a consumer can drop it at the EXIT instead.
[ "$(blk w6-06 "$OUT")" = '(let (w x0 1) x0)' ] && ok "G5 t-let emits the default quantity w" || bad "G5 w6-06 -- got [$(blk w6-06 "$OUT")]"
[ "$(blk w6-03 "$OUT")" = '(-> (1 x0 I64) Str)' ] && ok "G5 t-pi emits the quantity 1" || bad "G5 w6-03 -- got [$(blk w6-03 "$OUT")]"
if mutlib "M6" lib/surface/pretty.chiral 's/((qw) "w")/((qw) "")/'; then
  m6="$TMP/m6.out"
  if build_raw "$MUTLIB" "$FIXTURE" "$m6"; then
    [ "$(blk w6-06 "$m6")" = '(let ( x0 1) x0)' ] \
      && ok "M6 elide-the-default-quantity -- (let ( x0 1) x0)" \
      || bad "M6 elide-the-default-quantity -- got [$(blk w6-06 "$m6")]"
  else bad "M6 elide-the-default-quantity -- the mutant did not build"; fi
fi

echo
echo "=== E181 G6: no invented name shadows a FREE one ==="
# `resolve` (surface.chiral:117-132) searches LOCALS FIRST, so the hazard is not
# capture-avoidance: it is a `t-global "x0"` printed under a binder also named
# `x0` re-elaborating to the binder. One direction, and computable from the term.
[ "$(blk w6-19 "$OUT")" = '(lam (xxx0) (x0 xxx0))' ] \
  && ok "G6 a free x0 pushes the binder prefix to xxx (ugly, and accepted)" \
  || bad "G6 -- got [$(blk w6-19 "$OUT")]"
if mutlib "M7" lib/surface/pretty.chiral 's/(pp-any-xlike fs)/false/'; then
  m7="$TMP/m7.out"
  if build_raw "$MUTLIB" "$FIXTURE" "$m7"; then
    [ "$(blk w6-19 "$m7")" = '(lam (x0) (x0 x0))' ] \
      && ok "M7 hardcode-the-prefix -- (lam (x0) (x0 x0)): the free name is captured" \
      || bad "M7 hardcode-the-prefix -- got [$(blk w6-19 "$m7")]"
  else bad "M7 hardcode-the-prefix -- the mutant did not build"; fi
fi

echo
echo "=== E181 G7: arm binders agree with the elaborator's push order ==="
# `push-all` (surface.chiral:95) and `elab-arms` (:251-259) CONS, and `ctx-find`
# counts from the head -- so index 1 is the FIRST pattern variable. ⚑ A row that
# printed only the PATTERN would pass under M8; the BODY is what makes the
# direction observable.
case "$(blk w6-17 "$OUT")" in
  *"((Cons x0 x1) (x0 x1))"*) ok "G7 (karm Cons 2 (t-app (t-var 1) (t-var 0))) -> ((Cons x0 x1) (x0 x1))" ;;
  *) bad "G7 -- w6-17 does not contain ((Cons x0 x1) (x0 x1))" ;;
esac
if mutlib "M8" lib/surface/pretty.chiral 's/(reverse Doc acc)/acc/'; then
  m8="$TMP/m8.out"
  if build_raw "$MUTLIB" "$FIXTURE" "$m8"; then
    case "$(blk w6-17 "$m8")" in
      *"((Cons x1 x0) (x0 x1))"*) ok "M8 pattern-order-inverted -- ((Cons x1 x0) (x0 x1)): pattern and body disagree" ;;
      *) bad "M8 pattern-order-inverted -- got [$(blk w6-17 "$m8" | tr '\n' '/')]" ;;
    esac
  else bad "M8 pattern-order-inverted -- the mutant did not build"; fi
fi

echo
echo "=== E181 G8: adoption is real, and the frozen gates did not move ==="
# (a) The needles are ASSEMBLED so this row cannot match its own source, and
# DEFINING occurrences and CALL SITES are counted separately from the string:
# the two PROSE mentions in diag.chiral's header are the paragraph explaining
# why E158 shipped a flat accessor. They are history and they stay.
DTT="dg""-term-tag"
dtt_defs="$(cd "$REPO" && grep -REh "^\((def|declare) $DTT" lib prog 2>/dev/null | wc -l)"
dtt_calls="$(cd "$REPO" && grep -REoh "\($DTT " lib prog 2>/dev/null | wc -l)"
dtt_prose="$(cd "$REPO" && grep -Rh "$DTT" lib prog 2>/dev/null | wc -l)"
if [ "$dtt_defs" = 0 ] && [ "$dtt_calls" = 0 ]; then
  ok "G8(a) the flat accessor has 0 definitions and 0 call sites left ($dtt_prose prose mention(s) remain, expected 2)"
else
  bad "G8(a) the flat accessor still has $dtt_defs definition(s) and $dtt_calls call site(s)"
fi
[ "$dtt_prose" = 2 ] || bad "G8(a) expected exactly 2 surviving prose mentions, found $dtt_prose"
[ "$dtt_prose" = 2 ] && ok "G8(a) exactly the two prose mentions survive"

# (b) the import edge
if [ "$(grep -c '^(import "surface/pretty")' "$DIAG")" = 1 ]; then
  ok "G8(b) typing/diag imports surface/pretty"
else bad "G8(b) typing/diag does not import surface/pretty"; fi

# (c) FIVE gate scripts and THREE fixtures, byte-unchanged. Pinning four while
# exercising one is the same hole, one file smaller -- so every pin is checked
# and M10 moves EACH of them in turn.
PINS="400166d2bada74728abf895ef6bae8b8e5a63e5ffbce1653e348399f773e140b  diag.sh
1536b14abf23c1d36c6e26a0060bb79fc2a30bc1d40da24c862a69b7833da091  doc.sh
3f86f26b1b4bba4ab29c16dae080bb8dc73af0ef55c9956af8aa9a3d5f7ed2b0  row.sh
1cabeb7a0fa6da7e05118c766597621c9e5bcf7d9ed3a6402d0be5d381e585a9  face.sh
55ac6c4b08075fea11f465669e37b53dea750b40fcca947021b1d3d4e61228a4  render-doc.sh
713fe84d51c149d491edf8289a5799206f44b0e925a28dc7f123ba3f7ab4171c  samples/e157_diag.prog
56292ca8dfd175eb3bd1e7b79aa1b1e0b6971cde8478632790906a995fada584  samples/e158_doc.prog
a0cf04d8cb91a5bbc4f143c1315e406558f22d5c97ce76f83c8a5f53f02e75fd  samples/e174_row.prog"
pin_check() {  # pin_check DIR -> "" when every pin matches, else the offenders
  local dir="$1" n h
  echo "$PINS" | while read -r h n; do
    [ -n "$n" ] || continue
    if [ ! -f "$dir/$n" ]; then echo "$n MISSING"
    elif [ "$(sha256sum <"$dir/$n" | cut -d' ' -f1)" != "$h" ]; then echo "$n MOVED"; fi
  done
}
pin_bad="$(pin_check "$HERE")"
if [ -z "$pin_bad" ]; then ok "G8(c) five gate scripts and three fixtures are byte-unchanged (8 sha256 pins)"
else bad "G8(c) a pinned neighbour moved:"; echo "$pin_bad" | sed 's/^/          /'; fi

mkdir -p "$TMP/pins/samples"
cp "$HERE"/diag.sh "$HERE"/doc.sh "$HERE"/row.sh "$HERE"/face.sh "$HERE"/render-doc.sh "$TMP/pins/"
cp "$HERE"/samples/e157_diag.prog "$HERE"/samples/e158_doc.prog "$HERE"/samples/e174_row.prog "$TMP/pins/samples/"
m10_miss=""
for f in diag.sh doc.sh row.sh face.sh render-doc.sh samples/e157_diag.prog samples/e158_doc.prog samples/e174_row.prog; do
  cp "$HERE/$f" "$TMP/pins/$f"                      # restore the previous one
  printf '\n; mutant\n' >>"$TMP/pins/$f"
  case "$(pin_check "$TMP/pins")" in
    *"$f MOVED"*) : ;;
    *) m10_miss="$m10_miss $f" ;;
  esac
  cp "$HERE/$f" "$TMP/pins/$f"
done
if [ -z "$m10_miss" ]; then ok "M10 touch-a-pinned-gate -- all EIGHT pins move when their own file does"
else bad "M10 touch-a-pinned-gate -- these pins did not see a changed byte:$m10_miss"; fi

# (d) registration. The needle is assembled so this row cannot match its own
# source; an unregistered gate is a gate that never runs.
RP="run""_phase 18"
if [ "$(grep -cE "^$RP .* pretty.sh\$" "$HERE/run-tests.sh")" = 1 ]; then
  ok "G8(d) Phase 18 is registered in run-tests.sh -- this gate actually runs"
else bad "G8(d) Phase 18 is NOT registered in run-tests.sh"; fi
sed "/^$RP /d" "$HERE/run-tests.sh" >"$TMP/rt.sh"
if [ "$(grep -cE "^$RP .* pretty.sh\$" "$TMP/rt.sh")" = 0 ]; then
  ok "M11 drop-the-registration -- the registration check sees the missing line"
else bad "M11 drop-the-registration -- the check cannot see a dropped registration"; fi

# M9: the census must be able to SEE a re-added call site.
if mutlib "M9" lib/typing/diag.chiral "s/(cons (pp-of pfx e)/(cons (d-text (${DTT} e))/"; then
  n="$(grep -REoh "\($DTT " "$MUTLIB" 2>/dev/null | wc -l)"
  [ "$n" -ge 1 ] && ok "M9 re-add-a-flat-accessor-call -- the census sees $n call site(s)" \
                 || bad "M9 re-add-a-flat-accessor-call -- the census saw nothing; G8(a) is toothless"
fi

echo
echo "=== E181 G9: the printer is IMPORTABLE -- it was refused twice over ==="
# The fixture co-imports surface/pretty, surface/syntax AND lowering/tal/erase.
# Before E181 that root was refused twice: the file carried its own
# five-constructor `Term`, and its own `nlen` collided with erase.chiral's. Both
# colliding modules are inside prog/compiler.prog's blob, so the old file could
# never have been adopted -- which is why nothing verified its contents. This is
# the one row that CANNOT pass before the rewrite.
if grep -q '^(import "surface/syntax")' "$FIXTURE" && grep -q '^(import "lowering/tal/erase")' "$FIXTURE"; then
  ok "G9 the fixture co-imports surface/syntax and lowering/tal/erase beside the printer, and it built"
else bad "G9 the fixture no longer carries the co-imports -- the row is vacuous"; fi

if mutlib "M12" lib/surface/pretty.chiral '/^(module surface\/pretty /a (data Term () (t-zzz))'; then
  e="$(build_err "$MUTLIB" "$FIXTURE")"
  case "$e" in
    *"data redeclared: Term"*) ok "M12 restore-the-local-Term -- $(printf '%s' "$e" | head -1)" ;;
    *) bad "M12 restore-the-local-Term -- got [$(printf '%s' "$e" | head -1)]" ;;
  esac
fi
if mutlib "M13" lib/surface/pretty.chiral '/^(module surface\/pretty /a (def nlen (-> (0 A (type 0)) (List A) I64) (lam (A xs) 0))'; then
  e="$(build_err "$MUTLIB" "$FIXTURE")"
  case "$e" in
    *"duplicate label"*nlen*) ok "M13 restore-the-local-nlen -- $(printf '%s' "$e" | head -1)" ;;
    *) bad "M13 restore-the-local-nlen -- got [$(printf '%s' "$e" | head -1)]" ;;
  esac
fi

echo
echo "=== E181 G10: no cross-assertion on E157's wording ==="
# doc.sh's own non-cross-assertion scan covers only doc.sh and its fixture, so a
# NEW gate that byte-asserted the baseline exit's wording would be legal and
# unpoliced. Four lines, and it closes the hole before it is one: E181's goldens
# pin the GRAMMAR, E157's exit keeps its own wording, and the two must not be
# tied together. ⚑ The needle is assembled or the row matches its own source.
DGM="dg""-msg"
g10_gate="$(grep -v '^#' "$HERE/pretty.sh" | grep -c "$DGM")"
g10_fix="$(grep -v '^;' "$FIXTURE" | grep -c "$DGM")"
if [ "$g10_gate" = 0 ] && [ "$g10_fix" = 0 ]; then
  ok "G10 no CODE line of this gate names the baseline exit (its G1 header explains why in prose), and the fixture names it 0 times in code"
else bad "G10 the baseline exit's wording is referenced $g10_gate time(s) here and $g10_fix time(s) in fixture code"; fi
cp "$HERE/pretty.sh" "$TMP/x.sh"; printf '\n[ "$x" = "$(%s r-mismatch)" ]\n' "$DGM" >>"$TMP/x.sh"
cp "$FIXTURE" "$TMP/x.prog"; printf '(def zz Str (%s pz-r))\n' "$DGM" >>"$TMP/x.prog"
a="$(grep -v '^#' "$TMP/x.sh" | grep -c "$DGM")"; b="$(grep -v '^;' "$TMP/x.prog" | grep -c "$DGM")"
if [ "$a" -gt "$g10_gate" ] && [ "$b" -gt 0 ]; then
  ok "M14 cross-assert-the-baseline-wording -- BOTH halves of the scan move ($g10_gate->$a, $g10_fix->$b)"
else bad "M14 cross-assert-the-baseline-wording -- the scan did not move ($a, $b)"; fi

echo
echo "=== E181 G11: E154 census, tree-wide, for every pp- name ==="
# ⚑ `grep -R`, NOT `grep -r`: `-r` does not follow symlinks and would let a
# skipped file read as a clean census. ⚑ And WORD-BOUNDARIED: a fixed-string
# grep for one of these names returns sixteen hits of an unrelated `app-`
# binding in closconv.
census() {  # census DIR-OF-lib -> the number of DEFINING duplicates outside the printer
  local libdir="$1" nm n total=0
  for nm in $(grep -oE "^\((def|declare) pp-[a-z0-9-]+" "$PRETTY" | awk '{print $2}' | sort -u); do
    n="$(grep -REl "^\((def|declare) ${nm}([^A-Za-z0-9_-]|\$)" "$libdir" "$REPO/prog" 2>/dev/null \
         | grep -v "/surface/pretty.chiral\$" | wc -l)"
    total=$((total+n))
  done
  echo "$total"
}
nnames="$(grep -oE "^\((def|declare) pp-[a-z0-9-]+" "$PRETTY" | awk '{print $2}' | sort -u | wc -l)"
c="$(census "$REPO/lib")"
[ "$c" = 0 ] && ok "G11 $nnames pp- names, zero defining duplicates anywhere in lib/ or prog/" \
             || bad "G11 $c defining duplicate(s) of a pp- name outside the printer"
if mutlib "M15" lib/prelude/string.chiral '$a (def pp-term (-> I64 I64) (lam (x) x))'; then
  c2="$(census "$MUTLIB")"
  [ "$c2" -ge 1 ] && ok "M15 redefine-a-printer-name-in-a-sibling -- the census catches it ($c2)" \
                  || bad "M15 redefine-a-printer-name-in-a-sibling -- the census saw nothing; it is asserting that grep is deterministic"
fi

echo
echo "=== E181 G11b: the printer CALLS neither of the two broken string helpers ==="
# One SEGFAULTS out of range (E176) and the other rests on the false comment that
# it clamps, so a later hand reaching for either re-imports a known crash into a
# file with no `_` arm to hide behind. Prose in a header is not a row.
# ⚑ Needles assembled from fragments -- this script lives under `tools/`.
# ⚑ COMMENT LINES ARE STRIPPED: the printer's header NAMES both, on purpose, so
# the next reader meets the reason. The constraint is about what the file CALLS.
P1="str""-sub"; P2="str""-starts-with"
code_only() { grep -v '^[[:space:]]*;' "$1"; }
h="$(code_only "$PRETTY" | grep -cE "$P1|$P2")"
[ "$h" = 0 ] && ok "G11b the printer's CODE names neither unclamped helper (its header names both, deliberately)" \
             || bad "G11b the printer's code names one of them $h time(s)"
if mutlib "M16" lib/surface/pretty.chiral \
   "s/(case (=i (bget b 0) 120)/(case (str-eq (${P1} s 0 1) \"x\")/"; then
  h2="$(code_only "$MUTLIB/surface/pretty.chiral" | grep -cE "$P1|$P2")"
  [ "$h2" -ge 1 ] && ok "M16 reintroduce-the-unclamped-substring -- the census sees it ($h2)" \
                  || bad "M16 reintroduce-the-unclamped-substring -- the census saw nothing; G11b is toothless"
fi

echo
echo "=== E181 G12: the BUILD RULE's one checkable guard ==="
# The rest of the BUILD RULE is a SEQUENCE, not a mutant row: blob ->
# chirality-bin.new -> the suite under the new binary -> promote -> N1 == N2.
# What IS checkable here is the guard that makes the sequence honest: a `cmp` of
# two EMPTY files passes, so the new binary must be checked non-zero BEFORE any
# comparison. This row points the guard at two zero-byte files and requires it
# to REFUSE.
: >"$TMP/z1"; : >"$TMP/z2"
if cmp -s "$TMP/z1" "$TMP/z2"; then
  if [ -s "$TMP/z1" ] && cmp -s "$TMP/z1" "$TMP/z2"; then
    bad "G12 the non-zero guard let two empty files compare equal"
  else
    ok "G12 a bare cmp PASSES on two empty files; the -s guard refuses them (which is why it runs first)"
  fi
else
  bad "G12 cmp did not report two empty files as identical -- the premise of the guard is wrong"
fi

echo
echo "=== E181 G13: the HOME is surface/, and it closes no cycle ==="
# MAP.md sorts a file by its ROLE. `typing/` is "what a type is, and every check
# on it"; a printer checks nothing. Its input type is surface/syntax's `Term` and
# its output grammar is surface/parse's, so it is that sentence's written
# direction. ⚑ Root-relative keys make the directory the IDENTITY, so
# `(import "surface/pretty")` and the old key are DIFFERENT MODULES -- which is
# why the move had to land inside E181, before E146 depends on the key.
[ -f "$REPO/lib/surface/pretty.chiral" ] && ok "G13 the printer is lib/surface/pretty.chiral" \
  || bad "G13 lib/surface/pretty.chiral is missing"
[ -e "$REPO/lib/typing/pretty.chiral" ] && bad "G13 the old key lib/typing/pretty.chiral still exists" \
  || ok "G13 the old key lib/typing/pretty.chiral is gone"
OLDKEY='typing/''pretty'
n="$(cd "$REPO" && grep -Rh "(import \"$OLDKEY\")" lib prog tools 2>/dev/null | wc -l)"
[ "$n" = 0 ] && ok "G13 nothing imports the old key" || bad "G13 $n import(s) of the old key remain"

# the no-cycle proof, run rather than argued: walk surface/pretty's transitive
# imports and require that module/loader is not among them. `loader.chiral`
# imports typing/diag, and typing/diag now imports the printer -- so a
# printer -> loader edge would close a cycle, and it is exactly that edge E146's
# round-trip law would want. The law stays E146's; this row is why.
closure() {  # closure LIBDIR ROOTKEY -> one module key per line
  local libdir="$1" seen="" stack="$2" k f imps
  while [ -n "$stack" ]; do
    k="${stack%% *}"; stack="${stack#"$k"}"; stack="${stack# }"
    case " $seen " in *" $k "*) continue ;; esac
    seen="$seen $k"; echo "$k"
    f=""
    for ext in .chiral .port .manifest; do
      [ -f "$libdir/$k$ext" ] && { f="$libdir/$k$ext"; break; }
    done
    [ -n "$f" ] || continue
    imps="$(grep -oE '^\(import "[^"]+"\)' "$f" | sed 's/^(import "//; s/")$//' | tr '\n' ' ')"
    stack="$stack $imps"
  done
}
cl="$(closure "$REPO/lib" "surface/pretty" | sort -u)"
if echo "$cl" | grep -qx "module/loader"; then
  bad "G13 surface/pretty reaches module/loader -- that closes a cycle through typing/diag"
else
  ok "G13 surface/pretty's closure is $(echo "$cl" | wc -l) modules and does NOT reach module/loader ($(echo "$cl" | grep -c '^typing/') typing/ module(s), both already reached by surface/syntax)"
fi
if mutlib "M17" lib/surface/pretty.chiral '/^(module surface\/pretty /a (import "module/loader")'; then
  cl2="$(closure "$MUTLIB" "surface/pretty" | sort -u)"
  if echo "$cl2" | grep -qx "module/loader"; then
    ok "M17 import-the-loader -- the cycle scan sees the new edge"
  else bad "M17 import-the-loader -- the cycle scan did not see it; G13's closure row is toothless"; fi
fi

echo
echo "term printer (E181): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
