#!/usr/bin/env bash
# recording.sh -- the E197 gate: what a run is asked to record, judged over
# twenty priced configurations, three compile probes and six mutants.
#
# suite phase: registered 2026-09-06 under the native-tests ruling; run-tests.sh is the authority for the number.
#   records/author-calls.md -- phases 8-12 are owed to unported old-tree phases,
#   decision-lane-split reserves 21-23 for Lane B, and this lane holds no band.
#
# ⚑ UNREGISTERED, AND IT CARRIES NO ROW SAYING SO. records/gate-audit.md GA-24
# measures why: a row naming its own `run_phase` line cannot fire, because
# deleting that line stops the script that holds the row. This gate is run by
# hand, the route crypto.sh, tal-check.sh, apply-word.sh, capture-fields.sh,
# defunc-blame.sh, apply-spine.sh and E196's encoding.sh already take. What the
# suite witnesses of E197 is one thing: `prog/e197-recording-sweep.prog`
# compiles as a Phase 7 root.
#
# ─── THE SIX ROWS ───────────────────────────────────────────────────────────
#
#   R1  the sweep root resolves, compiles to a non-empty ELF and exits 0
#   R2  the refinement refuses: a `sample-every` of 0 and of -3 each fail to
#       build with `load: cannot prove refinement`, and 25 builds
#   R3  the twenty lines are byte-identical to the golden below
#   R4  the volume law holds on every row, recomputed here from the row's OWN
#       columns with the golden unread, the two rows past 2^53 declared skipped
#   R5  `ivl=none` on every spikes row and on no other
#   R6  `prog/compiler.prog`'s blob holds no `unit/recording`, AND a copied lib/
#       that imports it makes the same scan see it arrive
#
# ⚑ R3 AND R4 ARE TWO CLAIMS AND EACH CONVICTS ROWS THE OTHER CANNOT. A golden
# line is cut by running the code, so a wrong `rr-samples` is pinned as correct
# and blessed for good, while R4 recomputes the law from the row's own columns
# and never reads the golden. That is E196's argument. This element measures a
# second one on top of it: M2 moves six golden lines and R4 catches four,
# because lines 19 and 20 sit past awk's exact range and R4 declares them
# skipped; M5 moves nineteen and R4 catches four, because `xspk` couples every
# row to the spikes price while the law is checked per arm. Neither row is a
# weaker copy of the other.
#
# ⚑ R4 RENDERS WITH `%.0f` AND NEVER WITH `%d`. What loses a wide value in this
# tree's awk is the RENDERING, not `int()`: measured on mawk, `int(100000000000)`
# compares equal to `100000000000` and `printf "%.0f"` prints it back exactly,
# while `printf "%d"` clamps at 2147483647 and string coercion under CONVFMT at
# `%.6g` renders the same value as `1e+11`. That second one made a first draft
# of this row report a false finding on golden line 14. So the wide multiply
# stays in floating point, which is exact below 2^53, `int()` is applied only to
# the small quotient `t/ivl` for the floor division it is there to do, and any
# row whose recomputed volume reaches 2^53 is counted as SKIPPED rather than
# checked wrong. The row prints its own skipped count for that reason.
#
# ⚑ R2 IS A GATE ROW NO SWEEP LINE COULD BE. The worked example's twenty-first
# configuration priced a `sample-every` of -3 at -333,000. Against
# `(refine I64 (> 0))` that configuration does not compile, so the defect leaves
# the golden and becomes a compile refusal. R2 asserts the refusal in both
# directions, which is what stops a later run from quietly dropping the
# refinement: removing it turns R2's two refused probes green and R2 red, while
# every one of the twenty golden lines stays byte-identical.
#
# ⚑ R5 EXISTS BECAUSE THE ELEMENT'S CENTRAL CLAIM MOVES NO NUMBER. The interval
# on `record-spikes` is the whole structural content of the sum: it is the
# difference between three constructors and one record with an optional field.
# M3 below measures it: `rr-interval` answering `(some 1)` for spikes leaves
# every `samples=` figure in the file untouched, so R4 reports nothing and only
# the `ivl=` column moves. A gate pinning volumes alone passes M3 completely.
#
# ⚑ R6 IS ONE ROW WITH TWO HALVES, on render-doc.sh's G9-plus-M11 precedent. A
# scan for a needle that matches nothing anywhere passes by looking at nothing,
# so the negative half is checked beside a positive one over a copied lib/ that
# imports the module. Nothing E197 ships lands under lib/, so the element owes
# no fixpoint, and this row is where that claim is measured rather than asserted.
#
# ─── THE SIX MUTANTS ────────────────────────────────────────────────────────
#
# Each pins the WHOLE SET of golden lines it moves, by line number. GA-21 and
# GA-22 both convict a gate naming one row per mutant: a mutant reddening a row
# outside its own pin is then invisible.
#
#   M1  membrane-drops-neurons     the membrane price loses its neuron factor
#   M2  weights-drops-fanout       the weights price loses its fan-out
#   M3  spikes-gains-an-interval   `rr-interval` answers `(some 1)` for spikes
#   M4  ceiling-idiom              the interval divide takes the ceiling
#   M5  spikes-drops-the-rate      the spikes price loses the firing rate
#   M6  empty-is-zero              `rr-wrap` returns `(v-ok 0)` for a zero product
#
# ⚑ M3 AND M6 ARE THE TWO POSITIVE ASSERTIONS. M3 reaches the sum's structural
# claim and no `samples=` column sees it, which is what R5 is for. M6 restores
# `(v-ok 0)` and line 15 reads `xspk=0`, byte-identical in that column to line
# 16's honest quotient of zero, which is the collision
# definitions/pattern-boundary-sums names and which decision 3's second arm
# exists to prevent.
#
# ⚑ M5's BLAST RADIUS IS NINETEEN ROWS AND THAT IS `xspk`'s DOING. M1, M2, M3
# and M6 each stay inside their own arm. M4 has no single arm but stays inside
# its own arithmetic, because every weights row in the golden carries an
# interval that divides its run exactly. M5 breaks it by construction: `xspk`
# divides every row's volume by the same shape's spikes volume, so changing the
# spikes arm moves the denominator under all three. Line 15 is the one row it
# leaves alone, because `empty` in both columns is blind to the denominator.
# What localizes M5 is R4, checked per arm, which names the four `samples=` rows.
#
# ⚑ THE MUTANT DRIVER COPIES `prog/`, NEVER `lib/`. This module lands at
# `prog/unit/recording.chiral`, so a driver copying only lib/ could not mutate
# it at all and every mutant would pass by changing nothing. R6's second half is
# the one place a copied lib/ is needed, and it makes its own.

set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CC="${CC:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
[ -x "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
# shellcheck disable=SC1091
. "$REPO/bin/chirality-resolve.sh"

ROOT="$REPO/prog/e197-recording-sweep.prog"
MOD="$REPO/prog/unit/recording.chiral"
for f in "$ROOT" "$MOD"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its fixture cannot fail"; exit 2; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# ---- the golden ------------------------------------------------------------
# Twenty lines, reproduced byte-identically three times: by the E197 SPEC
# author, by the SPEC auditor's own compile, and by the implementation run that
# landed prog/unit/recording.chiral.
#
# Columns: n neurons, f synapses per neuron, t ticks, r spikes per neuron per
# 1,000 ticks, ivl the request's own sample-every, samples the priced volume,
# fields the bounded digest, xspk the volume as a multiple of the same shape's
# spike volume.
cat >"$TMP/golden" <<'GOLDEN'
spikes n=1000 f=100 t=1000 r=10 ivl=none samples=10000 fields=1 xspk=1
membrane n=1000 f=100 t=1000 r=10 ivl=1 samples=1000000 fields=2 xspk=100
membrane n=1000 f=100 t=1000 r=10 ivl=25 samples=40000 fields=2 xspk=4
membrane n=1000 f=100 t=1000 r=10 ivl=50 samples=20000 fields=2 xspk=2
weights n=1000 f=100 t=1000 r=10 ivl=1 samples=100000000 fields=2 xspk=10000
weights n=1000 f=100 t=1000 r=10 ivl=1000 samples=100000 fields=2 xspk=10
spikes n=1000 f=100 t=1000 r=100 ivl=none samples=100000 fields=1 xspk=1
membrane n=1000 f=100 t=1000 r=100 ivl=1 samples=1000000 fields=2 xspk=10
spikes n=1000 f=100 t=60000 r=10 ivl=none samples=600000 fields=1 xspk=1
membrane n=1000 f=100 t=60000 r=10 ivl=1 samples=60000000 fields=2 xspk=100
weights n=1000 f=100 t=60000 r=10 ivl=1000 samples=6000000 fields=2 xspk=10
spikes n=100000 f=1000 t=1000 r=10 ivl=none samples=1000000 fields=1 xspk=1
membrane n=100000 f=1000 t=1000 r=10 ivl=1 samples=100000000 fields=2 xspk=100
weights n=100000 f=1000 t=1000 r=10 ivl=1 samples=100000000000 fields=2 xspk=100000
membrane n=1000 f=100 t=1000 r=10 ivl=1001 samples=empty fields=2 xspk=empty
membrane n=1000 f=100 t=1000 r=10 ivl=999 samples=1000 fields=2 xspk=0
membrane n=1000 f=100 t=1000 r=10 ivl=3 samples=333000 fields=2 xspk=33
membrane n=1000 f=100 t=1000 r=10 ivl=7 samples=142000 fields=2 xspk=14
weights n=1000000 f=1000000 t=1000000 r=10 ivl=1 samples=1000000000000000000 fields=2 xspk=100000000
weights n=1000000 f=10000000 t=1000000 r=10 ivl=1 samples=-8446744073709551616 fields=2 xspk=-844674408
GOLDEN

# ---- helpers ---------------------------------------------------------------

# sweep PROGDIR OUT -> 0 and OUT holds the twenty lines
sweep() {
  local progdir="$1" out="$2" blob="$TMP/s.blob" elf="$TMP/s.elf"
  ( cd "$REPO" && chirality_blob_file "$REPO/lib:$progdir" "$progdir/e197-recording-sweep.prog" ) \
    >"$blob" 2>/dev/null || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
  ( ulimit -s unlimited; "$elf" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ]
}

# mutprog NAME SED-EXPR... -> a scratch copy of prog/ with unit/recording.chiral
# mutated, left in $MUTPROG. A mutation that does not apply is a mutant that
# proves nothing, so a stale pattern is REPORTED rather than silently passing.
#
# ⚑ THE SCRATCH prog/ MUST BE A REAL DIRECTORY, NEVER A SYMLINK. `cp -a` copies
# a symlink as a symlink and every subsequent `sed -i` then writes THROUGH it
# into the tree under test. render-doc.sh carries the same guard for lib/ and
# names the nineteen phantom failures that bought it.
MUTPROG=""
mutprog() {
  local name="$1"; shift
  MUTPROG="$TMP/mutprog"; rm -rf "$MUTPROG"; cp -a "$REPO/prog" "$MUTPROG"
  if [ -L "$MUTPROG" ]; then
    bad "$name -- the scratch prog/ is a SYMLINK; every sed would write into the tree under test"; return 1
  fi
  local target="$MUTPROG/unit/recording.chiral" e
  for e in "$@"; do
    sed -i "$e" "$target" || { bad "$name -- sed failed"; return 1; }
  done
  if cmp -s "$target" "$MOD"; then
    bad "$name -- the mutation did not change prog/unit/recording.chiral (stale pattern)"; return 1
  fi
  return 0
}

# moved FILE -> the 1-based golden line numbers this output differs on
moved() {
  awk 'NR==FNR { g[FNR]=$0; n=FNR; next }
       { if ($0 != g[FNR]) printf "%s%d", (c++ ? " " : ""), FNR }
       END { if (FNR != n) printf "%s(line-count %d against %d)", (c ? " " : ""), FNR, n }' \
    "$TMP/golden" "$1"
}

# r4 FILE -> "<bad line numbers>|<skipped count>"
#
# The volume law, recomputed per arm from the row's OWN columns. The golden is
# never opened here. See the `%.0f` note in the header: the wide multiply stays
# in floating point and any row reaching 2^53 is skipped, not judged.
r4() {
  awk '{
         delete c; tag=$1
         for (i=2;i<=NF;i++) { split($i,p,"="); c[p[1]]=p[2] }
         n=c["n"]+0; f=c["f"]+0; t=c["t"]+0; r=c["r"]+0
         if (tag=="spikes")        e = int(n*t*r/1000)
         else if (tag=="membrane") e = n * int(t/(c["ivl"]+0))
         else                      e = n * f * int(t/(c["ivl"]+0))
         if (e >= 9007199254740992 || e <= -9007199254740992) { sk++; next }
         want = (e == 0) ? "empty" : sprintf("%.0f", e)
         if (c["samples"] != want) printf "%s%d", (b++ ? " " : ""), FNR
       }
       END { printf "|%d", sk+0 }' "$1"
}

# r5 FILE -> the line numbers where `ivl=none` and the spikes tag disagree
r5() {
  awk '{
         delete c
         for (i=2;i<=NF;i++) { split($i,p,"="); c[p[1]]=p[2] }
         if (($1=="spikes") != (c["ivl"]=="none")) printf "%s%d", (b++ ? " " : ""), FNR
       }' "$1"
}

# nwords STR -> how many whitespace-separated words it holds
nwords() { local n=0 _w; for _w in $1; do n=$((n+1)); done; echo "$n"; }

# cell FILE LINE KEY -> the value of KEY on that line
cell() { awk -v l="$2" -v k="$3" 'FNR==l { for (i=2;i<=NF;i++) { split($i,p,"=");
           if (p[1]==k) print p[2] } }' "$1"; }

echo "=== E197: what a run is asked to record (unregistered; run by hand) ==="

# ---- R1 --------------------------------------------------------------------
if sweep "$REPO/prog" "$TMP/base"; then
  ok "R1 the sweep root compiles to a non-empty ELF and exits 0 -- $(wc -l <"$TMP/base" | tr -d ' ') lines"
else
  bad "R1 the sweep root did not build or did not run"
  echo "  R3 to R5 and M1 to M6 are UNMEASURED: every one of them reads this output."
  echo; echo "recording: $pass passed, $fail failed, 9 unmeasured"; exit 1
fi

# ---- R2 --------------------------------------------------------------------
# Three whole roots, each constructing a `record-membrane` through a parameter
# already at the refined type. The verdict is the compiler's own exit and
# message; nothing is run.
probe() {
  local v="$1" dir="$TMP/probe"
  rm -rf "$dir"; mkdir -p "$dir"
  cat >"$dir/p.prog" <<PROBE
(import "prelude/prelude")
(import "unit/recording")
(import "ports/stdio")
(def probe (=> (refine I64 (> 0)) Unit)
  (lam (e) (put (str-cat (i64->str (rr-fields (record-membrane "pop" e))) "\n"))))
(def compile-main (=> I64 I64)
  (lam (n) (do (probe $v) 0)))
PROBE
  ( cd "$REPO" && chirality_blob_file "$REPO/lib:$REPO/prog" "$dir/p.prog" ) \
    >"$dir/p.blob" 2>/dev/null || { echo "resolve-failed"; return; }
  if ( ulimit -s unlimited; "$CC" <"$dir/p.blob" >"$dir/p.elf" 2>"$dir/p.err" ) && [ -s "$dir/p.elf" ]; then
    echo "built"
  else
    tr -d '\n' <"$dir/p.err" | sed 's/  */ /g;s/ $//'
  fi
}
P_OK="$(probe 25)"; P_ZERO="$(probe 0)"; P_NEG="$(probe -3)"
REFUSE="load: cannot prove refinement"
if [ "$P_OK" = "built" ] && [ "$P_ZERO" = "$REFUSE" ] && [ "$P_NEG" = "$REFUSE" ]; then
  ok "R2 the refinement refuses at compile time: sample-every 25 builds, 0 and -3 both give '$REFUSE'"
else
  bad "R2 the refinement did not hold: 25 -> [$P_OK] (want built), 0 -> [$P_ZERO], -3 -> [$P_NEG] (want '$REFUSE')"
fi

# ---- R3 --------------------------------------------------------------------
if diff -u "$TMP/golden" "$TMP/base" >"$TMP/r3.diff"; then
  ok "R3 the twenty lines are byte-identical to the golden"
else
  bad "R3 the sweep moved off the golden"; sed -n '1,40p' "$TMP/r3.diff"
fi

# ---- R4 --------------------------------------------------------------------
R4="$(r4 "$TMP/base")"; R4BAD="${R4%|*}"; R4SK="${R4#*|}"
if [ -z "$R4BAD" ]; then
  ok "R4 the volume law holds on every judged row, recomputed per arm from n, f, t, r and ivl -- $((20 - R4SK)) checked, $R4SK skipped past 2^53"
else
  bad "R4 rows breaking the volume law: $R4BAD ($R4SK skipped past 2^53)"
fi

# ---- R5 --------------------------------------------------------------------
R5="$(r5 "$TMP/base")"
if [ -z "$R5" ]; then
  ok "R5 ivl=none on every spikes row and on no other -- $(awk '$1=="spikes"' "$TMP/base" | wc -l | tr -d ' ') spikes rows"
else
  bad "R5 rows where the spikes tag and ivl=none disagree: $R5"
fi

# ---- R6 --------------------------------------------------------------------
# blob_needles LIBDIR -> "<bytes> <unit/recording count> <rr-samples count>"
blob_needles() {
  ( cd "$REPO" && chirality_blob_file "$1:$REPO/prog" prog/compiler.prog ) 2>/dev/null >"$TMP/blob"
  printf '%s %s %s' "$(wc -c <"$TMP/blob" | tr -d ' ')" \
    "$(grep -c -F -- 'unit/recording' "$TMP/blob")" \
    "$(grep -c -F -- 'rr-samples' "$TMP/blob")"
}
read -r B_BYTES B_KEY B_FN <<<"$(blob_needles "$REPO/lib")"
MUTLIB="$TMP/mutlib"; rm -rf "$MUTLIB"; cp -a "$REPO/lib" "$MUTLIB"
if [ -L "$MUTLIB" ]; then
  bad "R6 the scratch lib/ is a SYMLINK; the sed would write into the tree under test"
else
  sed -i 's|^(import "prelude/doc")|(import "prelude/doc")\n(import "unit/recording")|' \
    "$MUTLIB/typing/diag.chiral"
  if cmp -s "$MUTLIB/typing/diag.chiral" "$REPO/lib/typing/diag.chiral"; then
    bad "R6 the counter-mutation did not change lib/typing/diag.chiral (stale pattern)"
  else
    read -r M_BYTES M_KEY M_FN <<<"$(blob_needles "$MUTLIB")"
    if [ "$B_KEY" -eq 0 ] && [ "$B_FN" -eq 0 ] && [ "$M_KEY" -ge 1 ] && [ "$M_FN" -ge 1 ]; then
      ok "R6 unit/recording is outside the compiler blob ($B_BYTES B, 0 hits) and the scan sees it arrive ($M_BYTES B, $M_KEY key / $M_FN rr-samples) -- no fixpoint obligation"
    elif [ "$B_KEY" -ne 0 ] || [ "$B_FN" -ne 0 ]; then
      bad "R6 unit/recording IS in the compiler blob ($B_BYTES B, $B_KEY key / $B_FN rr-samples) -- this element now carries a self-hosting cmp"
    else
      bad "R6 the closure scan is blind: importing the module leaves $M_KEY key / $M_FN rr-samples hits; the row would pass on any needle"
    fi
  fi
fi

# ---- the mutants -----------------------------------------------------------

# run_mutant NAME WANT-MOVED WANT-R4-COUNT SED... -> judged on both the pinned
# set and the recomputed law, because the two convict different rows.
run_mutant() {
  local name="$1" want_moved="$2" want_r4="$3"; shift 3
  mutprog "$name" "$@" || return
  if ! sweep "$MUTPROG" "$TMP/m"; then
    bad "$name -- the mutated tree did not build or run"; return
  fi
  local mv r4o r4bad n4
  mv="$(moved "$TMP/m")"
  r4o="$(r4 "$TMP/m")"; r4bad="${r4o%|*}"
  n4="$(nwords "$r4bad")"
  if [ "$mv" = "$want_moved" ] && [ "$n4" -eq "$want_r4" ]; then
    ok "$name -- R3 red on [$mv], R4 red on $n4 rows [$r4bad]"
  else
    bad "$name -- R3 red on [$mv] (want [$want_moved]), R4 red on $n4 rows [$r4bad] (want $want_r4)"
  fi
}

# M1: the nine membrane rows. Line 15 does not move: a zero quotient is v-empty
# under either arithmetic.
run_mutant "M1 membrane-drops-neurons" "2 3 4 8 10 13 16 17 18" 9 \
  's|(rr-wrap (\* n (/ t e)))|(rr-wrap (/ t e))|'

# M2: the six weights rows, collapsing 19 and 20 onto 1,000,000,000,000 both so
# the wall stops being observable. R4 catches four; 19 and 20 are past its range.
run_mutant "M2 weights-drops-fanout" "5 6 11 14 19 20" 4 \
  's|(rr-wrap (\* (\* n f) (/ t e)))|(rr-wrap (\* n (/ t e)))|'

# M3: the four spikes rows, in the `ivl=` column ONLY. Not one samples= figure
# in the file moves, so R4 catches nothing and R5 is what convicts.
if mutprog "M3 spikes-gains-an-interval" \
     's|((record-spikes p)     none)|((record-spikes p)     (some 1))|'; then
  if sweep "$MUTPROG" "$TMP/m3"; then
    MV="$(moved "$TMP/m3")"; R4O="$(r4 "$TMP/m3")"; R4B="${R4O%|*}"
    R5M="$(r5 "$TMP/m3")"; N4="$(nwords "$R4B")"; N5="$(nwords "$R5M")"
    if [ "$MV" = "1 7 9 12" ] && [ "$N4" -eq 0 ] && [ "$R5M" = "1 7 9 12" ]; then
      ok "M3 spikes-gains-an-interval -- R3 red on [$MV] in the ivl= column alone (row 1 ivl=$(cell "$TMP/m3" 1 ivl) samples=$(cell "$TMP/m3" 1 samples)), R4 red on 0 rows, R5 red on $N5 [$R5M]"
    else
      bad "M3 spikes-gains-an-interval -- R3 red on [$MV] (want [1 7 9 12]), R4 red on $N4 [$R4B] (want 0), R5 red on [$R5M] (want [1 7 9 12])"
    fi
  else bad "M3 spikes-gains-an-interval -- the mutated tree did not build or run"; fi
fi

# M4: the four rows where the interval does not divide the run. The sixteen
# whose interval divides exactly, or which carry none, are blind to the rule.
run_mutant "M4 ceiling-idiom" "15 16 17 18" 4 \
  's|(/ t e)|(/ (+ t (- e 1)) e)|g'

# M5: nineteen of twenty rows. Four move on samples=; the rest move on xspk
# alone, whose denominator is the spikes price. Line 15 is blind to it, because
# `empty` in both columns cannot see the denominator. R4 is checked per arm and
# names the four samples= rows exactly.
run_mutant "M5 spikes-drops-the-rate" \
  "1 2 3 4 5 6 7 8 9 10 11 12 13 14 16 17 18 19 20" 4 \
  's|(rr-wrap (/ (\* (\* n t) r) 1000))|(rr-wrap (/ (\* n t) 1000))|'

# M6: line 15 alone. `samples=empty xspk=empty` becomes `samples=0 xspk=0`, at
# which point line 15's xspk reads identically to line 16's honest quotient of
# zero. That is decision 3's positive assertion.
if mutprog "M6 empty-is-zero" \
     's|(case (=i v 0) (true (v-empty)) (false (v-ok v)))|(v-ok v)|'; then
  if sweep "$MUTPROG" "$TMP/m6"; then
    MV="$(moved "$TMP/m6")"; S="$(cell "$TMP/m6" 15 samples)"; X="$(cell "$TMP/m6" 15 xspk)"
    R4O="$(r4 "$TMP/m6")"; R4B="${R4O%|*}"
    if [ "$MV" = "15" ] && [ "$S" = "0" ] && [ "$X" = "0" ] && [ "$R4B" = "15" ]; then
      ok "M6 empty-is-zero -- R3 red on line 15 alone: samples empty -> $S, xspk empty -> $X, colliding with line 16's xspk=$(cell "$TMP/m6" 16 xspk); R4 red on [$R4B]"
    else
      bad "M6 empty-is-zero -- moved [$MV] (want 15), samples $S / xspk $X (want 0 / 0), R4 red on [$R4B] (want 15)"
    fi
  else bad "M6 empty-is-zero -- the mutated tree did not build or run"; fi
fi

echo
echo "recording: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
