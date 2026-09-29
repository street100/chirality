#!/usr/bin/env bash
# shape-census.sh -- the verdict over the shape census (E201), suite phase 34.
#
# `prog/shape-census.prog` counts declaration shapes over the tracked lib/ and
# prog/ sources and prints one `pred` line per row of
# `docs/definitions/shape-census.md`. It asserts nothing. This file holds every
# pin and every mutant.
#
# ─── WHY TWO FILES ──────────────────────────────────────────────────────────
# `prog/optimizer-census.prog:24-28` states the rule: a gate that re-derives
# its own verdict is green under any mutant that changes what the verdict says.
# So the instrument counts and this file compares.
#
# ─── THE SIX ROWS ───────────────────────────────────────────────────────────
# Each is read off one verdict line, `R1 .. R6 live=<moved> fix=<moved>`, where
# <moved> lists the rows whose reading departs from its pin, `-` for none.
#
#   R1  the instrument's pred ids equal the register's SC- ids, as sets
#   R2  the live readings equal WANT_LIVE, whole
#   R3  the fixture readings equal WANT_FIX, whole: the hand counts in
#       tools/test/samples/shape-census-fixture.chiral. This is the row that
#       tells a correct predicate from a self-consistent one.
#   R4  SC-err-arm-bare-str does not exceed SC_BARE_STR_ALLOWED
#   R5  every SC- id under docs/ and records/ names a register row
#   R6  the live list plus the unreadable fixture plus a missing path prints
#       two skip lines naming them, reads skipped=2, and moves no reading
#
# A run with no `census` line reads every row `absent`. The instrument prints
# its readings after the last file, so a reader crash on any file reddens all
# six rows. That is how a crash surfaces, without the path that caused it:
# lib/surface/sexp.chiral:44's MAX-DEPTH is read by nothing.
#
# ─── THE EIGHT MUTANTS, AND ALL EIGHT ARE SUBSTITUTIONS ─────────────────────
# records/gate-audit.md GA-19: no mutant removes an arm. Every mutated file is
# `cmp -s`'d against its base first (GA-18), so a stale pattern is reported as a
# failure. Each mutant pins the WHOLE verdict line (GA-21, GA-22).
#
#   M1  comment-blind          SC-data-decl reads the raw-text counter
#   M2  arm-rule-widened       err-side? also admits bad, -none and -invalid
#   M3  namespaces-summed      the SC-ctor-head collector also takes def names
#   M4  rebuild-loosened       rebuild-arm? compares binders as sets
#   M5  register-row-dropped   one row cut from a scratch copy of the register
#   M6  skip-dropped           the af-err arm prints nothing and counts nothing
#   M7  bare-str-grown         the fixture joins the live input
#   M8  closure-untagged       the input carries no closure tags
#
# M1 to M4 and M6 rebuild the instrument from a scratch copy; M5, M7 and M8
# reuse the base build.
#
# ─── THE INPUT ──────────────────────────────────────────────────────────────
# `git ls-files lib prog`, the tracked .chiral, .port and .prog files. A path is
# tagged `closure` when its module key is one of the compiler blob's
# line-anchored `(end-module "<key>")` markers. Unanchored, the grep also finds
# two string literals in blob text and reads 63 keys against the 61 real ones.
#
# Wall clock is printed and sets no bar (the 2026-09-01 ruling,
# docs/benchmarks/README.md:29). Zero Python.
set -uo pipefail
T0=$SECONDS

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CC="${CHIRALITY_COMPILE:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
[ -x "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
# shellcheck disable=SC1091
. "$REPO/bin/chirality-resolve.sh"

INSTR="$REPO/prog/shape-census.prog"
REGISTER="$REPO/docs/definitions/shape-census.md"
FIXTURE_REL="tools/test/samples/shape-census-fixture.chiral"
UNREAD_REL="tools/test/samples/shape-census-unreadable.chiral"
MISSING_REL="tools/test/samples/shape-census-no-such-file.chiral"
for f in "$INSTR" "$REGISTER" "$REPO/$FIXTURE_REL" "$REPO/$UNREAD_REL"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its subject cannot fail"; exit 2; }
done
[ -e "$REPO/$MISSING_REL" ] && { echo "  FAIL  $MISSING_REL exists; R6 needs a path that does not"; exit 2; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# ─── the pins ───────────────────────────────────────────────────────────────
# Read 2026-09-29 by the implement run over the tracked tree, one line per
# register row as `<id> <n> <closure>`. Set by hand and never computed here.
# The tracked tree includes prog/shape-census.prog itself, 312 files: the
# instrument is a prog/ source like any other and is counted.
# Any change to lib/ or prog/ that adds a def, a data or a case arm moves a
# reading, and moving it is the point: re-pin here and cite the new reading
# with its date.
WANT_LIVE="SC-data-decl 516 206
SC-result-sum 83 35
SC-result-sum-2arm 79 34
SC-result-sum-nplus 4 1
SC-err-arm-bare-str 33 19
SC-err-arm-str-plus 16 3
SC-err-arm-declared 15 10
SC-rebuild-unchanged 231 174
SC-passthrough-case 226 174
SC-hand-traverse 41 35
SC-def-name 4244 1538
SC-data-name 487 206
SC-ctor-head 1214 592
SC-ctor-head-sites 1251 592"

# The hand counts, from the fixture's own header. Nothing in the fixture is
# tagged, so every closure column reads 0.
WANT_FIX="SC-data-decl 10 0
SC-result-sum 6 0
SC-result-sum-2arm 5 0
SC-result-sum-nplus 1 0
SC-err-arm-bare-str 1 0
SC-err-arm-str-plus 1 0
SC-err-arm-declared 2 0
SC-rebuild-unchanged 2 0
SC-passthrough-case 1 0
SC-hand-traverse 1 0
SC-def-name 7 0
SC-data-name 10 0
SC-ctor-head 20 0
SC-ctor-head-sites 21 0"

# The ceiling R4 holds SC-err-arm-bare-str to. records/author-calls.md:52
# (EV3) is `unreviewed`: the narrow reading lets the check read 29 and the
# wide reading requires 0, both stated over a different predicate. Until it
# is ruled this is the reading pinned on the implement date and ratchets
# down only. The ruling replaces this value and nothing else.
SC_BARE_STR_ALLOWED=33

# ─── helpers ────────────────────────────────────────────────────────────────

# sub FILE BASE EXPR -> apply EXPR, and fail loudly if it changed nothing
sub() {
  local file="$1" base="$2" expr="$3"
  sed -i "$expr" "$file" || return 1
  cmp -s "$file" "$base" && return 1
  return 0
}

# build SRC ELF -> the instrument built from SRC. A copy in $TMP resolves its
# imports against the tracked lib/ (bin/chirality-resolve.sh:293-305).
build() {
  local src="$1" elf="$2" b="$TMP/instr.blob"
  rm -f "$elf"
  ( cd "$REPO" && chirality_blob_file "$REPO/lib:$REPO/prog" "$src" ) >"$b" 2>/dev/null && [ -s "$b" ] || return 1
  ( ulimit -s unlimited; "$CC" <"$b" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
}

# run ELF LIST OUT -> the instrument over LIST, from the repo root
run() {
  ( cd "$REPO" && ulimit -s unlimited && "$1" <"$2" >"$3" 2>/dev/null ) || return 1
  grep -q '^census ' "$3"
}

# readings OUT -> `<id> <n> <closure>` per pred line, in printed order
readings() { sed -n 's/^pred \(SC-[a-z0-9-]*\) n=\([0-9]*\) closure=\([0-9]*\)$/\1 \2 \3/p' "$1"; }

# moved GOT WANT -> the ids whose line differs, comma-joined without SC-, or -
moved() {
  local out
  out="$(awk 'NR==FNR { w[$1]=$0; next } { if (w[$1] != $0) m = m (m ? "," : "") substr($1, 4); seen[$1]=1 }
              END { for (k in w) if (!(k in seen)) m = m (m ? "," : "") substr(k, 4); print (m ? m : "-") }' \
          <(printf '%s\n' "$2") <(printf '%s\n' "$1"))"
  echo "$out"
}

# register_ids REG -> the SC- ids in the register's table, sorted
register_ids() { sed -n 's/^| `\(SC-[a-z0-9-]*\)` |.*/\1/p' "$1" | sort -u; }

# cited_ids -> every SC- id token under docs/ and records/, sorted
cited_ids() {
  grep -rhoE '(^|[^A-Za-z0-9_])SC-[a-z][a-z0-9-]*' "$REPO/docs" "$REPO/records" 2>/dev/null \
    | sed 's/^[^S]*//' | sort -u
}

# ─── the input ──────────────────────────────────────────────────────────────

COMPILER_BLOB="$TMP/compiler.blob"
( cd "$REPO" && chirality_blob_file "$REPO/lib:$REPO/prog" "$REPO/prog/compiler.prog" ) >"$COMPILER_BLOB" 2>/dev/null
[ -s "$COMPILER_BLOB" ] || { echo "  FAIL  the compiler blob did not assemble -- nothing here can be measured"; exit 2; }
KEYS="$TMP/keys"
sed -n 's/^(end-module "\([^"]*\)")$/\1/p' "$COMPILER_BLOB" | sort -u >"$KEYS"
[ -s "$KEYS" ] || { echo "  FAIL  the compiler blob carries no end-module marker"; exit 2; }
if grep -qx 'shape-census' "$KEYS"; then
  echo "  FAIL  shape-census is inside the compiler closure; it must stay a leaf"; exit 2
fi

SOURCES="$TMP/sources"
( cd "$REPO" && git ls-files lib prog ) | grep -E '\.(chiral|port|prog)$' >"$SOURCES"
[ -s "$SOURCES" ] || { echo "  FAIL  git ls-files returned no tracked source"; exit 2; }

# tag LIST OUT -> each path, plus TAB closure when its key closes a module.
# The key is the path under lib/ or prog/ less its extension, and lib/ wins
# a key both roots hold, as the resolver's search order does.
tag() {
  awk -F'\t' '
    function keyof(p,   k) { k = p; sub(/^[^\/]*\//, "", k); sub(/\.[a-z]+$/, "", k); return k }
    function rootof(p,  r) { r = p; sub(/\/.*/, "", r); return r }
    FNR == 1 { f++ }
    f == 1 { k[$1] = 1; next }
    f == 2 { if (rootof($0) == "lib") inlib[keyof($0)] = 1; next }
    { key = keyof($0)
      inside = (key in k) && (rootof($0) == "lib" || !(key in inlib))
      print $0 (inside ? "\tclosure" : "") }' \
    "$KEYS" "$1" "$1" >"$2"
}
LIVE_TAGGED="$TMP/live.tagged"
tag "$SOURCES" "$LIVE_TAGGED"

# ─── the six rows over one instrument, one register and one input mode ──────
# measure ELF REGISTER MODE -> "R1 R2 R3 R4 R5 R6 live=<moved> fix=<moved>"
# MODE is `base`, `with-fixture` (M7) or `untagged` (M8).
measure() {
  local elf="$1" reg="$2" mode="$3"
  local list="$TMP/m.list" lo="$TMP/m.live" fo="$TMP/m.fix" so="$TMP/m.r6"
  local r1 r2 r3 r4 r5 r6 lm fm got

  case "$mode" in
    base)          cp "$LIVE_TAGGED" "$list" ;;
    with-fixture)  { cat "$LIVE_TAGGED"; echo "$FIXTURE_REL"; } >"$list" ;;
    untagged)      cp "$SOURCES" "$list" ;;
  esac

  if ! [ -x "$elf" ] || ! run "$elf" "$list" "$lo"; then
    echo "absent absent absent absent absent absent live=absent fix=absent"; return
  fi
  got="$(readings "$lo")"

  # R1: the two id sets, both directions
  if [ "$(printf '%s\n' "$got" | awk '{print $1}' | sort -u)" = "$(register_ids "$reg")" ]; then r1=ok; else r1=bad; fi

  # R2: the live readings, whole
  lm="$(moved "$got" "$WANT_LIVE")"
  [ "$lm" = "-" ] && r2=ok || r2=bad

  # R3: the fixture readings against the hand counts
  if printf '%s\n' "$FIXTURE_REL" >"$TMP/m.flist" && run "$elf" "$TMP/m.flist" "$fo"; then
    fm="$(moved "$(readings "$fo")" "$WANT_FIX")"
    [ "$fm" = "-" ] && r3=ok || r3=bad
  else
    fm=absent; r3=absent
  fi

  # R4: the ratchet
  local nb; nb="$(printf '%s\n' "$got" | awk '$1 == "SC-err-arm-bare-str" {print $2}')"
  if [ -n "$nb" ] && [ "$nb" -le "$SC_BARE_STR_ALLOWED" ]; then r4=ok; else r4=bad; fi

  # R5: every cited id is a register row
  if [ -z "$(comm -23 <(cited_ids) <(register_ids "$reg"))" ]; then r5=ok; else r5=bad; fi

  # R6: the reader's refusals are named and counted, and move nothing
  { cat "$list"; echo "$UNREAD_REL"; echo "$MISSING_REL"; } >"$TMP/m.r6list"
  if run "$elf" "$TMP/m.r6list" "$so"; then
    r6=ok
    [ "$(grep -c '^skip ' "$so")" = 2 ] || r6=bad
    grep -q "^skip $UNREAD_REL " "$so" || r6=bad
    grep -q "^skip $MISSING_REL " "$so" || r6=bad
    grep -q '^census .* skipped=2 ' "$so" || r6=bad
    [ "$(readings "$so")" = "$got" ] || r6=bad
  else
    r6=absent
  fi

  echo "$r1 $r2 $r3 $r4 $r5 $r6 live=$lm fix=$fm"
}

echo "=== the shape census over lib/ and prog/ (E201) ==="
echo "  input  $(wc -l <"$SOURCES") tracked files, $(grep -c $'\tclosure$' "$LIVE_TAGGED") inside the closure of $(wc -l <"$KEYS") modules"

BASE_ELF="$TMP/base.elf"
build "$INSTR" "$BASE_ELF" || echo "  (the instrument did not build)"
VERDICT="$(measure "$BASE_ELF" "$REGISTER" base)"
echo "  line   $VERDICT"
[ -f "$TMP/m.live" ] && grep -E '^(census|text) ' "$TMP/m.live" | sed 's/^/         /'

r()   { echo "$VERDICT" | cut -d' ' -f"$1"; }
row() { local got; got="$(r "$1")"
  if [ "$got" = "ok" ]; then ok "R$1 $2"; else bad "R$1 $2 -- got '$got'"; fi
}
row 1 "every pred id is a register row and every register row prints a pred"
row 2 "the live readings equal WANT_LIVE"
row 3 "the fixture readings equal its hand counts"
row 4 "SC-err-arm-bare-str reads at most $SC_BARE_STR_ALLOWED"
row 5 "every SC- id under docs/ and records/ names a register row"
row 6 "an unreadable file and a missing path are skipped by name and move nothing"

ALLOK="ok ok ok ok ok ok live=- fix=-"
if [ "$VERDICT" != "$ALLOK" ]; then
  echo
  echo "  the base line is not ALLOK; the mutants are NOT run -- a mutant graded"
  echo "  against an already-red base measures nothing."
  echo
  echo "shape-census: $pass passed, $fail failed, 8 mutants unmeasured ($((SECONDS-T0))s)"
  exit 1
fi

# ─── the mutants ────────────────────────────────────────────────────────────

verdict_is() {  # verdict_is NAME WANT GOT
  if [ "$3" = "$2" ]; then ok "$1 -- [$3]"; else bad "$1 -- [$3] (want [$2])"; fi
}

# instr_mutant NAME WANT SED -> the instrument rebuilt from a mutated copy
instr_mutant() {
  local name="$1" want="$2" expr="$3" m="$TMP/mut.prog" elf="$TMP/mut.elf"
  cp "$INSTR" "$m"
  if ! sub "$m" "$INSTR" "$expr"; then
    bad "$name -- the mutation did not change prog/shape-census.prog (stale pattern)"; return
  fi
  build "$m" "$elf" || rm -f "$elf"
  verdict_is "$name" "$want" "$(measure "$elf" "$REGISTER" base)"
}

# M1 is FD-48 §11's finding in executable form: the parsed count against the
# raw text, twelve apart over lib/ and prog/ and two apart over the fixture.
instr_mutant "M1 comment-blind" \
  "ok bad bad ok ok ok live=data-decl fix=data-decl" \
  's|(lam (fs body) (count-data-forms fs)))|(lam (fs body) (text-data-count body)))|'

# M2 is the spelling difference that produced two of the five scans. The
# fixture's -invalid sum moves R3 whatever the tree holds. Over the tree it
# moves four readings and leaves SC-err-arm-bare-str where it was, so R4 stays
# green: none of the two-arm sums it admits in lib/ or prog/ carries a bare-Str
# err arm. SC-hand-traverse moves because it calls err-side? too.
instr_mutant "M2 arm-rule-widened" \
  "ok bad bad ok ok ok live=result-sum,result-sum-2arm,err-arm-declared,hand-traverse fix=result-sum,result-sum-2arm,err-arm-bare-str" \
  's|(str-eq h "bad!")|(or (str-eq h "bad!") (or (str-eq h "bad") (or (ends "-none" h) (ends "-invalid" h))))|'

# M3 sums two namespaces. R1 stays green: the ids are all there, and only the
# two readings are wrong.
instr_mutant "M3 namespaces-summed" \
  "ok bad bad ok ok ok live=ctor-head,ctor-head-sites fix=ctor-head,ctor-head-sites" \
  's|(true nil) ; def-names-are-not-ctor-heads|(true (cons (form-name form) nil)) ; def-names-are-not-ctor-heads|'

# M4 moves SC-rebuild-unchanged on the fixture's reordered arm and leaves
# SC-passthrough-case, because that case also carries an err arm that
# rebuilds nothing.
instr_mutant "M4 rebuild-loosened" \
  "ok ok bad ok ok ok live=- fix=rebuild-unchanged" \
  's|(same-seq bs ks)|(same-set bs ks)|'

# M5 cuts one register row. R1 sees a pred with no row, and R5 sees the id
# still cited by the live register and the SPEC.
REG_M5="$TMP/register.md"
cp "$REGISTER" "$REG_M5"
if sub "$REG_M5" "$REGISTER" '/^| `SC-hand-traverse` |/d'; then
  verdict_is "M5 register-row-dropped" \
    "bad ok ok ok bad ok live=- fix=-" "$(measure "$BASE_ELF" "$REG_M5" base)"
else
  bad "M5 register-row-dropped -- the register row is missing from the register (stale pattern)"
fi

# M6 swallows the reader's refusal. Only R6 feeds the instrument an
# unreadable file, so only R6 can see it.
instr_mutant "M6 skip-dropped" \
  "ok ok ok ok ok bad live=- fix=-" \
  's|((af-err m p) (note-skip path m a))|((af-err m p) a)|'

# M7 grows the gate predicate by the fixture's one bare-Str two-arm sum. The
# fixture adds to every reading, so every live id moves; R4 is the row that
# says the growth is in the gated predicate.
M7_LIVE="data-decl,result-sum,result-sum-2arm,result-sum-nplus,err-arm-bare-str,err-arm-str-plus,err-arm-declared,rebuild-unchanged,passthrough-case,hand-traverse,def-name,data-name,ctor-head,ctor-head-sites"
verdict_is "M7 bare-str-grown" \
  "ok bad ok bad ok ok live=$M7_LIVE fix=-" "$(measure "$BASE_ELF" "$REGISTER" with-fixture)"

# M8 drops every closure tag. Every reading keeps its n and loses its closure
# column, and only R2 pins that column.
M8_LIVE="data-decl,result-sum,result-sum-2arm,result-sum-nplus,err-arm-bare-str,err-arm-str-plus,err-arm-declared,rebuild-unchanged,passthrough-case,hand-traverse,def-name,data-name,ctor-head,ctor-head-sites"
verdict_is "M8 closure-untagged" \
  "ok bad ok ok ok ok live=$M8_LIVE fix=-" "$(measure "$BASE_ELF" "$REGISTER" untagged)"

echo
echo "shape-census: $pass passed, $fail failed ($((SECONDS-T0))s)"
[ "$fail" -eq 0 ]
