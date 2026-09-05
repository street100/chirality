#!/usr/bin/env bash
# encoding.sh -- the E196 gate: the seam between a continuous value and a spike
# train, judged over twenty swept configurations and four mutants.
#
# not-a-phase: E196's number waits on the standing suite-phase-number call in
#   records/author-calls.md -- four documents disagree about 21-23.
#
# ⚑ UNREGISTERED, AND IT CARRIES NO ROW SAYING SO. records/gate-audit.md GA-24
# measures why: a row naming its own `run_phase` line cannot fire, because
# deleting that line stops the script that holds the row. This gate is run by
# hand, the route crypto.sh, tal-check.sh, apply-word.sh, capture-fields.sh,
# defunc-blame.sh and apply-spine.sh already take. What the suite witnesses of
# E196 is one thing: `prog/e196-encoding-sweep.prog` compiles as a Phase 7 root.
#
# ─── THE FIVE ROWS ──────────────────────────────────────────────────────────
#
#   G1  the sweep root resolves, compiles to a non-empty ELF and exits 0
#   G2  its twenty lines are byte-identical to the golden below
#   G3  every scalar row satisfies `maxerr <= ceil(max/window)`, computed here
#       from the row's OWN w and m, with the golden unread
#   G4  at least one population row carries `maxfire >= 2`
#   G5  `prog/compiler.prog`'s blob holds no `unit/encoding`, AND a copied lib/
#       that imports it makes the same scan see it arrive
#
# ⚑ G2 AND G3 ARE TWO CLAIMS AND THE DRIVER RUNS BOTH. Pinning `maxerr=31`
# asserts equality with 31, which is stronger than `maxerr <= ceil(1000/32)` on
# that row and silent about the law. A golden line is cut by running the code,
# so a wrong decode is pinned as correct and G2 blesses it for good. G3
# evaluates the law from the configuration and never reads the golden, so it
# convicts a row the pin cannot. Computing the bound inside the root and pinning
# the verdict it prints is the shape `prog/e188-apply-spine.prog` refuses, so
# both live here in bash.
#
# ⚑ G4 EXISTS BECAUSE ONE ROW IS BLIND AND THE GOLDEN SAYS WHICH. With `size`
# tuning values spread evenly over [0, max], spacing is `max/(size-1)` and a
# unit fires inside a half-width `h`. Silence needs `h` below half the spacing
# and overlap needs `h` above it, so no evenly spaced configuration carries
# both. A row where one unit fires decodes to that unit's own tuning value
# whatever count it carries, so the `h=20` row cannot see the tuning curve's
# shape at all, which M3 measures. G4 stops the sweep from being reduced to
# blind rows.
#
# ⚑ G5 IS ONE ROW WITH TWO HALVES, on `render-doc.sh`'s G9-plus-M11 precedent.
# A scan for a needle that matches nothing anywhere passes by looking at
# nothing, so the negative half is checked beside a positive one over a copied
# lib/ that imports the module. The row is green when the base blob holds zero
# and the mutated blob holds at least one.
#
# ─── THE FOUR MUTANTS ───────────────────────────────────────────────────────
#
# Each pins the WHOLE SET of golden lines it moves, by line number. GA-21 and
# GA-22 both convict a gate that names one row per mutant: a mutant reddening a
# row outside its own pin is then invisible. Here a mutant that reddens an arm
# it does not own fails on the set, so a green mutant row says the blast radius
# was exactly the arm.
#
#   M1  rate-window-off-by-one     `Rate` divides by `window + 1`
#   M2  latency-drops-complement   `Latency` returns (first-spike - ref)*max/window
#   M3  rectangular-curve          the tuning curve fires a flat `k` inside `h`
#   M4  silence-is-zero            `d-silent` becomes `(d-val 0)` on Population
#
# ⚑ M3 AND M4 ARE THE PAIR THAT SEPARATES THE TWO POPULATION REGIMES. M3 moves
# the five rows with `maxfire >= 2` and leaves the `h=20` row exactly where it
# was, which is the blindness G4 guards. M4 moves the `h=20` row alone and
# restores the worked example's 980, which is decision 2's positive assertion.
#
# ⚑ THE MUTANT DRIVER COPIES `prog/`, NEVER `lib/`. `render-doc.sh:133` copies
# lib/ because every target it mutates is lib/-relative. This module lands at
# `prog/unit/encoding.chiral`, so a driver copying only lib/ could not mutate
# it at all and every mutant would pass by changing nothing. G5's second half is
# the one place a copied lib/ is needed, and it makes its own.

set -u

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CC="${CC:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
[ -x "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
# shellcheck disable=SC1091
. "$REPO/bin/chirality-resolve.sh"

ROOT="$REPO/prog/e196-encoding-sweep.prog"
MOD="$REPO/prog/unit/encoding.chiral"
for f in "$ROOT" "$MOD"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its fixture cannot fail"; exit 2; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# ---- the golden ------------------------------------------------------------
# Twenty lines, reproduced byte-identically four times: by the E196 SPEC author,
# by an independent Python model, by the SPEC auditor's own compile, and by the
# implementation run that landed prog/unit/encoding.chiral.
cat >"$TMP/golden" <<'GOLDEN'
rate w=100 m=100 domain=101 exact=101 silent=0 maxerr=0 maxfire=1
rate w=100 m=50 domain=51 exact=51 silent=0 maxerr=0 maxfire=1
rate w=255 m=255 domain=256 exact=256 silent=0 maxerr=0 maxfire=1
rate w=100 m=400 domain=401 exact=101 silent=0 maxerr=3 maxfire=1
rate w=32 m=1000 domain=1001 exact=9 silent=0 maxerr=31 maxfire=1
rate w=16 m=255 domain=256 exact=2 silent=0 maxerr=16 maxfire=1
rate w=7 m=255 domain=256 exact=2 silent=0 maxerr=37 maxfire=1
rate w=3 m=100 domain=101 exact=2 silent=0 maxerr=33 maxfire=1
rate w=1 m=100 domain=101 exact=2 silent=0 maxerr=99 maxfire=1
lat w=100 r=1000 m=100 domain=101 exact=100 silent=1 maxerr=0 maxfire=1
lat w=16 r=0 m=16 domain=17 exact=16 silent=1 maxerr=0 maxfire=1
lat w=1024 r=1000000 m=1024 domain=1025 exact=1024 silent=1 maxerr=0 maxfire=1
lat w=100 r=1000 m=400 domain=401 exact=100 silent=1 maxerr=3 maxfire=1
lat w=16 r=0 m=255 domain=256 exact=1 silent=1 maxerr=16 maxfire=1
pop n=8 m=1000 h=20 k=100 domain=1001 exact=8 silent=727 maxerr=19 maxfire=1
pop n=8 m=1000 h=80 k=100 domain=1001 exact=9 silent=0 maxerr=63 maxfire=2
pop n=8 m=1000 h=200 k=100 domain=1001 exact=247 silent=0 maxerr=33 maxfire=3
pop n=8 m=1000 h=400 k=100 domain=1001 exact=38 silent=0 maxerr=91 maxfire=6
pop n=32 m=1000 h=100 k=100 domain=1001 exact=430 silent=0 maxerr=24 maxfire=7
pop n=64 m=65536 h=4096 k=1024 domain=65537 exact=2014 silent=0 maxerr=1028 maxfire=8
GOLDEN

# ---- helpers ---------------------------------------------------------------

# sweep PROGDIR OUT -> 0 and OUT holds the twenty lines
sweep() {
  local progdir="$1" out="$2" blob="$TMP/s.blob" elf="$TMP/s.elf"
  ( cd "$REPO" && chirality_blob_file "$REPO/lib:$progdir" "$progdir/e196-encoding-sweep.prog" ) \
    >"$blob" 2>/dev/null || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
  ( ulimit -s unlimited; "$elf" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ]
}

# mutprog NAME SED-EXPR... -> a scratch copy of prog/ with unit/encoding.chiral
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
  local target="$MUTPROG/unit/encoding.chiral" e
  for e in "$@"; do
    sed -i "$e" "$target" || { bad "$name -- sed failed"; return 1; }
  done
  if cmp -s "$target" "$MOD"; then
    bad "$name -- the mutation did not change prog/unit/encoding.chiral (stale pattern)"; return 1
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

# g3_bad FILE -> the line numbers whose maxerr breaks ceil(max/window)
g3_bad() {
  awk '$1=="rate" || $1=="lat" {
         w=""; m=""; e="";
         for (i=2;i<=NF;i++) { split($i,kv,"=");
           if (kv[1]=="w") w=kv[2]+0; else if (kv[1]=="m") m=kv[2]+0;
           else if (kv[1]=="maxerr") e=kv[2]+0 }
         if (w > 0 && e > int((m + w - 1) / w)) printf "%s%d", (c++ ? " " : ""), FNR
       }' "$1"
}

# cell FILE LINE KEY -> the value of KEY on that line
cell() { awk -v l="$2" -v k="$3" 'FNR==l { for (i=2;i<=NF;i++) { split($i,kv,"=");
           if (kv[1]==k) print kv[2] } }' "$1"; }

echo "=== E196: the encoding seam (unregistered; run by hand) ==="

# ---- G1 --------------------------------------------------------------------
if sweep "$REPO/prog" "$TMP/base"; then
  ok "G1 the sweep root compiles to a non-empty ELF and exits 0 -- $(wc -l <"$TMP/base" | tr -d ' ') lines"
else
  bad "G1 the sweep root did not build or did not run"
  echo "  G2 to G5 and M1 to M4 are UNMEASURED: every one of them reads this output."
  echo; echo "encoding: $pass passed, $fail failed, 8 unmeasured"; exit 1
fi

# ---- G2 --------------------------------------------------------------------
if diff -u "$TMP/golden" "$TMP/base" >"$TMP/g2.diff"; then
  ok "G2 the twenty lines are byte-identical to the golden"
else
  bad "G2 the sweep moved off the golden"; sed -n '1,40p' "$TMP/g2.diff"
fi

# ---- G3 --------------------------------------------------------------------
G3="$(g3_bad "$TMP/base")"
if [ -z "$G3" ]; then
  ok "G3 all fourteen scalar rows satisfy maxerr <= ceil(max/window), computed from w and m"
else
  bad "G3 scalar rows breaking maxerr <= ceil(max/window): $G3"
fi

# ---- G4 --------------------------------------------------------------------
NOVER="$(awk '$1=="pop" { for (i=2;i<=NF;i++) { split($i,kv,"=");
           if (kv[1]=="maxfire" && kv[2]+0 >= 2) c++ } } END { print c+0 }' "$TMP/base")"
if [ "$NOVER" -ge 1 ]; then
  ok "G4 $NOVER population rows carry maxfire >= 2 -- the tuning curve is observable on those"
else
  bad "G4 every population row carries maxfire < 2; the tuning curve's shape is unobserved"
fi

# ---- G5 --------------------------------------------------------------------
# blob_needles LIBDIR -> "<bytes> <unit/encoding count> <enc-decode count>"
blob_needles() {
  ( cd "$REPO" && chirality_blob_file "$1:$REPO/prog" prog/compiler.prog ) 2>/dev/null >"$TMP/blob"
  printf '%s %s %s' "$(wc -c <"$TMP/blob" | tr -d ' ')" \
    "$(grep -c -F -- 'unit/encoding' "$TMP/blob")" \
    "$(grep -c -F -- 'enc-decode' "$TMP/blob")"
}
read -r B_BYTES B_KEY B_FN <<<"$(blob_needles "$REPO/lib")"
MUTLIB="$TMP/mutlib"; rm -rf "$MUTLIB"; cp -a "$REPO/lib" "$MUTLIB"
if [ -L "$MUTLIB" ]; then
  bad "G5 the scratch lib/ is a SYMLINK; the sed would write into the tree under test"
else
  sed -i 's|^(import "prelude/doc")|(import "prelude/doc")\n(import "unit/encoding")|' \
    "$MUTLIB/typing/diag.chiral"
  if cmp -s "$MUTLIB/typing/diag.chiral" "$REPO/lib/typing/diag.chiral"; then
    bad "G5 the counter-mutation did not change lib/typing/diag.chiral (stale pattern)"
  else
    read -r M_BYTES M_KEY M_FN <<<"$(blob_needles "$MUTLIB")"
    if [ "$B_KEY" -eq 0 ] && [ "$B_FN" -eq 0 ] && [ "$M_KEY" -ge 1 ] && [ "$M_FN" -ge 1 ]; then
      ok "G5 unit/encoding is outside the compiler blob ($B_BYTES B, 0 hits) and the scan sees it arrive ($M_BYTES B, $M_KEY key / $M_FN enc-decode) -- no fixpoint obligation"
    elif [ "$B_KEY" -ne 0 ] || [ "$B_FN" -ne 0 ]; then
      bad "G5 unit/encoding IS in the compiler blob ($B_BYTES B, $B_KEY key / $B_FN enc-decode) -- this element now carries a self-hosting cmp"
    else
      bad "G5 the closure scan is blind: importing the module leaves $M_KEY key / $M_FN enc-decode hits; the row would pass on any needle"
    fi
  fi
fi

# ---- the mutants -----------------------------------------------------------

# M1: nine rate rows, every exact collapsing to 1, and G3 convicting five of them.
if mutprog "M1 rate-window-off-by-one" \
     's|((enc-rate w c m) (d-val (/ (\* c m) w)))|((enc-rate w c m) (d-val (/ (* c m) (+ w 1))))|'; then
  if sweep "$MUTPROG" "$TMP/m1"; then
    MV="$(moved "$TMP/m1")"; G3M="$(g3_bad "$TMP/m1")"
    NG3=0; for _x in $G3M; do NG3=$((NG3+1)); done
    if [ "$MV" = "1 2 3 4 5 6 7 8 9" ] && [ "$NG3" -eq 5 ]; then
      ok "M1 rate-window-off-by-one -- G2 red on the nine rate rows alone, exact $(cell "$TMP/m1" 1 exact) on row 1, G3 red on 5 rows [$G3M]"
    else
      bad "M1 rate-window-off-by-one -- moved [$MV] (want 1..9), G3 red on $NG3 rows [$G3M] (want 5)"
    fi
  else bad "M1 rate-window-off-by-one -- the mutated tree did not build or run"; fi
fi

# M2: five latency rows, and G3 convicting all five.
if mutprog "M2 latency-drops-complement" \
     's|((some t) (d-val (/ (\* (- w (- t r)) m) w)))|((some t) (d-val (/ (* (- t r) m) w)))|'; then
  if sweep "$MUTPROG" "$TMP/m2"; then
    MV="$(moved "$TMP/m2")"; G3M="$(g3_bad "$TMP/m2")"
    NG3=0; for _x in $G3M; do NG3=$((NG3+1)); done
    if [ "$MV" = "10 11 12 13 14" ] && [ "$NG3" -eq 5 ]; then
      ok "M2 latency-drops-complement -- G2 red on the five latency rows alone, exact $(cell "$TMP/m2" 10 exact) on row 10, G3 red on 5 rows [$G3M]"
    else
      bad "M2 latency-drops-complement -- moved [$MV] (want 10..14), G3 red on $NG3 rows [$G3M] (want 5)"
    fi
  else bad "M2 latency-drops-complement -- the mutated tree did not build or run"; fi
fi

# M3: the five overlapping population rows, and the blind h=20 row unmoved.
if mutprog "M3 rectangular-curve" \
     's|(true  (cons (- k (/ (\* k d) h)) (enc-counts r v h k)))|(true  (cons k (enc-counts r v h k)))|'; then
  if sweep "$MUTPROG" "$TMP/m3"; then
    MV="$(moved "$TMP/m3")"
    if [ "$MV" = "16 17 18 19 20" ]; then
      ok "M3 rectangular-curve -- G2 red on the five maxfire>=2 rows, exact $(cell "$TMP/m3" 16 exact) on row 16; the h=20 row holds at exact $(cell "$TMP/m3" 15 exact) silent $(cell "$TMP/m3" 15 silent) maxerr $(cell "$TMP/m3" 15 maxerr)"
    else
      bad "M3 rectangular-curve -- moved [$MV], expected [16 17 18 19 20]"
    fi
  else bad "M3 rectangular-curve -- the mutated tree did not build or run"; fi
fi

# M4: the blind h=20 row alone, restoring the worked example's 980.
if mutprog "M4 silence-is-zero" \
     's|^          (true  (d-silent))$|          (true  (d-val 0))|'; then
  if sweep "$MUTPROG" "$TMP/m4"; then
    MV="$(moved "$TMP/m4")"; S="$(cell "$TMP/m4" 15 silent)"; E="$(cell "$TMP/m4" 15 maxerr)"
    if [ "$MV" = "15" ] && [ "$S" = "0" ] && [ "$E" = "980" ]; then
      ok "M4 silence-is-zero -- G2 red on the h=20 row alone: silent 727 -> $S, maxerr 19 -> $E"
    else
      bad "M4 silence-is-zero -- moved [$MV] (want 15), silent $S (want 0), maxerr $E (want 980)"
    fi
  else bad "M4 silence-is-zero -- the mutated tree did not build or run"; fi
fi

echo
echo "encoding: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
