#!/usr/bin/env bash
# opt-census.sh -- the gate over the typed-assembly checker's census of what the
# compiler emits: EN-24's three numbers, re-derived and pinned.
#
# not-a-phase: this gate takes no suite phase number. Which number a new gate
#   takes is the standing author call in records/author-calls.md -- phases 8-12
#   are owed to unported old-tree phases, decision-lane-split reserves 21-23 for
#   Lane B, four documents disagree, and this lane holds no band. The route is
#   the one crypto.sh, tal-check.sh, apply-word.sh, capture-fields.sh,
#   defunc-blame.sh, apply-spine.sh, encoding.sh and recording.sh all take.
#
# ⚑ UNREGISTERED, AND IT CARRIES NO ROW SAYING SO. records/gate-audit.md GA-24
# measures why: a row naming its own `run_phase` line cannot fire, because
# deleting that line stops the script that holds the row. This gate is run by
# hand. What the suite witnesses is one thing: `prog/optimizer-census.prog`
# compiles as a Phase 7 root.
#
# ─── WHY IT EXISTS ──────────────────────────────────────────────────────────
# The figure enforcement requirement 4 was closed on, `1,582 TFns /
# 1,550 chk-ok / 32 chk-err`, came from a probe that was never committed. EN-25
# records the gap. `prog/optimizer-census.prog` is the committed instrument and
# this file is its verdict.
#
# ─── WHAT THE 2026-09-08 RULING TOOK OUT ────────────────────────────────────
# This gate had six rows and six mutants, `12 passed, 0 failed`. Two rows and
# two mutants asserted a WIRING that no longer exists, and they are gone:
#
#   R5  the `chk-ok` guard changes what the compiler emits, on an outlining
#       fixture and not on its control
#   R6  `lowering/upper/optimize` is in the compiler blob, and cutting the
#       import at compile-back.chiral:16 makes `(def re-check` leave it
#   M1  unwire-the-import       compile-back.chiral:16 commented out
#   M2  adopt-without-chk-ok    the `chk-err` arm adopts `(fold t)`
#
# The author ruled on 2026-09-08 (records/lenses/problems.md PRB-70) that
# `lowering/tal/check` stays OUTSIDE the compiler closure. `re-check` and the
# `Checked` sum left `lib/lowering/upper/optimize.chiral` for
# `prog/optimizer-census.prog`, and `lib/lowering/compile-back.chiral`'s
# `opt-tfns` adopts `(fold t)` with no verdict to consult. R5 measured a guard
# that is gone, R6 grepped the blob for a definition that has left it, and M1
# and M2 mutated a call site that no longer exists. A row asserting a wiring
# after the wiring is cut passes by looking at nothing, which is the class
# `docs/definitions/working-discipline.md` names under Reporting.
#
# ⚑ THE CENSUS ITSELF SURVIVES, AND IT IS THE HALF THAT MEASURES SOMETHING.
# `ck-fn` judging every TFn the shipping compiler emits is enforcement
# requirement 2's territory, and it is the only committed instrument that reads
# the checker against real output. It runs from OUTSIDE the closure now:
# `prog/optimizer-census.prog` is a `prog/` leaf and is not in
# `prog/compiler.prog`'s closure, so `tools/test/tal-check.sh` G18 stays green
# while this gate runs the real checker.
#
# ─── THE FOUR ROWS ──────────────────────────────────────────────────────────
# All four are judged from `prog/optimizer-census.prog`'s stdout, built from the
# lib/ under measurement and run over the TRACKED lib/'s compiler blob.
#
#   R1  the census root builds, runs, and reports defs=1519 skipped=10
#   R2  the census is tfns=1549 ok=1518 err=31
#   R3  ONE error class, `call: unknown tal function`, n=31, first bput-u8, and
#       every one of the 31 unknown callees is the refused TFn's OWN outlined
#       block `<name>$0`
#   R4  unfolded-ok equals ok -- the fold costs zero acceptances
#
# ⚑ THE PINS MOVED ON 2026-09-08 AND THE SHAPE DID NOT. Under the old wiring
# the census read `defs=1551 skipped=10 tfns=1582 ok=1550 err=32`, over a blob
# that carried `lib/lowering/tal/check.chiral`. The ruling took that module out
# of the compiler closure, so the subject blob is 840,440 bytes against 855,545
# and carries 33 fewer defs. Every proportion held: one class, the same message,
# the same first instance, and every refused callee still the TFn's own `$0`
# block.
#
# ⚑ R3 CORRECTS EN-24. That row reads "the 32 are `call: unknown tal function`
# on port externs the tal function table does not carry, first instance
# `bput-u8`", and it is the definition `docs/arcs/enforcement-arc.md`
# requirement 2 carries for its remaining scope. Measured, `bput-u8` is the name
# of the REFUSED TFn and not of the missing callee; `bput-u8` is an ordinary def
# at `lib/lowering/tal/bytes.chiral:610` and no port extern is involved. The
# missing callee is `bput-u8$0`. `outline` (lower.chiral:311-319) names a
# non-tail-case block `<name>$<n>`, adds its signature to `St`'s fn list, and
# `compile-fn` (lower.chiral:420) returns `le-ok main extra` while DISCARDING
# `st-fns`. So the program-wide `CEnv` `lower-defs` builds from `def-sigs` never
# carries the outlined signature, and every TFn that calls its own outlined
# block is refused. All 31 are that one shape. R3 asserts it positively, so a
# later change that makes the 31 something else cannot pass by keeping the
# count.
#
# ─── THE FOUR MUTANTS, AND ALL FOUR ARE SUBSTITUTIONS ───────────────────────
# records/gate-audit.md GA-19: deleting an arm makes the module non-exhaustive,
# the compiler refuses the mutated tree, and the row is graded on a compile
# refusal instead of on the property it names. Nothing below removes an arm.
# Every mutated file is `cmp -s`'d against its base before it is built (GA-18),
# and a stale pattern is REPORTED rather than silently passing.
#
# Each mutant pins the WHOLE verdict line. GA-21 and GA-22 both convict a gate
# naming one row per mutant: a mutant reddening a row outside its own pin is
# then invisible.
#
#   M3  call-lookup-in-prims    ck-instr's `i-call` arm reads the PRIM table
#   M4  fold-const-mistyped     the folded constant is annotated `(tt-str)`
#   M5  outline-suffix          `outline` names its block `<name>@<n>`
#   M6  strip-lams-off-by-one   `compile-fn` peels one lambda too many
#
# ⚑ M4 IS WHAT SEPARATES R4 FROM R2. A folded residual the check refuses drops
# `ok` while `unfolded-ok` holds at 1518, which is the one shape a row reading
# only the accept count cannot tell from a smaller program.
#
# ⚑ M5 MOVES R3 AND NOTHING ELSE. Every count holds, the message holds, the
# first instance holds, and the callee behind each of the 31 stops being the
# refused TFn's own `$0` block. A row pinning the three numbers alone passes it
# whole.
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

PROBE="$REPO/prog/optimizer-census.prog"
OPT="$REPO/lib/lowering/upper/optimize.chiral"
CHK="$REPO/lib/lowering/tal/check.chiral"
LOW="$REPO/lib/lowering/upper/lower.chiral"
for f in "$PROBE" "$OPT" "$CHK" "$LOW"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its subject cannot fail"; exit 2; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# ─── the pins ───────────────────────────────────────────────────────────────
# Reproduced 2026-09-08 by prog/optimizer-census.prog over the compiler's own
# blob, the blob the PRB-70 ruling left behind.
WANT_DEFS=1519
WANT_SKIP=10
WANT_TFNS=1549
WANT_OK=1518
WANT_ERR=31
WANT_MSG="call: unknown tal function"
WANT_FIRST="bput-u8"

# ─── helpers ────────────────────────────────────────────────────────────────

# scratch NAME SRC-LIB -> a scratch copy of SRC-LIB at $TMP/NAME, echoed.
#
# ⚑ THE SCRATCH lib/ MUST BE A REAL DIRECTORY, NEVER A SYMLINK. `cp -a` copies a
# symlink as a symlink and every subsequent `sed -i` then writes THROUGH it into
# the tree under test. render-doc.sh carries the same guard and names the
# nineteen phantom failures that bought it.
scratch() {
  local name="$1" src="$2" dst="$TMP/$1"
  rm -rf "$dst"; cp -a "$src" "$dst"
  [ -L "$dst" ] && { echo ""; return 1; }
  echo "$dst"
}

# sub FILE BASE EXPR -> apply EXPR, and fail loudly if it changed nothing
sub() {
  local file="$1" base="$2" expr="$3"
  sed -i "$expr" "$file" || return 1
  cmp -s "$file" "$base" && return 1
  return 0
}

# blob LIBDIR SRC OUT
blob() { ( cd "$REPO" && chirality_blob_file "$1:$REPO/prog" "$2" ) >"$3" 2>/dev/null && [ -s "$3" ]; }

# census LIBDIR OUT -> OUT holds the probe's stdout, the probe BUILT from LIBDIR
# and run over the TRACKED lib/'s compiler blob.
#
# ⚑ THE SUBJECT BLOB IS ALWAYS THE TRACKED ONE, NEVER THE MUTANT'S. A mutant
# that changes lib/ changes the blob assembled from it, and a census taken over
# that blob then moves because the INPUT shrank rather than because the check
# changed. Holding the input fixed is what makes each mutant's verdict readable.
census() {
  local lib="$1" out="$2" pb="$TMP/pr.blob" elf="$TMP/pr.elf"
  rm -f "$elf"
  blob "$lib" "$PROBE" "$pb" || return 1
  ( ulimit -s unlimited; "$CC" <"$pb" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
  ( ulimit -s unlimited; "$elf" <"$SUBJECT" >"$out" 2>/dev/null ) || return 1
  grep -q '^census ' "$out"
}

# f KEY FILE -> the value of KEY= on the census line
f() { sed -n 's/^census .*/&/p' "$2" | tr ' ' '\n' | sed -n "s/^$1=//p" | head -1; }

# ─── the four rows over one lib/ ────────────────────────────────────────────
# measure LIBDIR -> "R1 R2 R3 R4 census=<t>/<o>/<e> cls=<n>"
measure() {
  local lib="$1" o="$TMP/m.census"
  local r1 r2 r3 r4 tn oks er dfs sk uo ncls
  if census "$lib" "$o"; then
    tn="$(f tfns "$o")"; oks="$(f ok "$o")"; er="$(f err "$o")"
    dfs="$(f defs "$o")"; sk="$(f skipped "$o")"; uo="$(f 'unfolded-ok' "$o")"
    ncls="$(grep -c '^class ' "$o")"

    [ "$dfs" = "$WANT_DEFS" ] && [ "$sk" = "$WANT_SKIP" ] && r1=ok || r1=bad
    { [ "$tn" = "$WANT_TFNS" ] && [ "$oks" = "$WANT_OK" ] && [ "$er" = "$WANT_ERR" ]; } && r2=ok || r2=bad
    [ "$uo" = "$oks" ] && r4=ok || r4=bad

    # R3: one class, its shape, and the callee of every instance.
    r3=ok
    [ "$ncls" -eq 1 ] || r3=bad
    grep -q "^class n=$WANT_ERR first=$WANT_FIRST msg=$WANT_MSG\$" "$o" || r3=bad
    # every `err <tfn> | <callee> | <msg>` line must carry callee == <tfn>$0
    awk -F' \\| ' '/^err /{ n=substr($1,5); if ($2 != n "$0") b++ } END { exit (b>0) }' "$o" || r3=bad
    [ "$(grep -c '^err ' "$o")" = "$WANT_ERR" ] || r3=bad
  else
    r1=absent; r2=absent; r3=absent; r4=absent
    tn=absent; oks=absent; er=absent; ncls=0
  fi

  echo "$r1 $r2 $r3 $r4 census=$tn/$oks/$er cls=$ncls"
}

# The one fixed subject: the TRACKED lib/'s compiler blob.
SUBJECT="$TMP/subject.blob"
blob "$REPO/lib" "$REPO/prog/compiler.prog" "$SUBJECT" \
  || { echo "  FAIL  the compiler blob did not assemble -- nothing here can be measured"; exit 2; }

echo "=== the typed-assembly checker's census over what the compiler emits (unregistered; run by hand) ==="

VERDICT="$(measure "$REPO/lib")"
echo "  line  $VERDICT"
BASE_CENSUS="$(sed -n '1p' "$TMP/m.census" 2>/dev/null)"
[ -n "$BASE_CENSUS" ] && echo "        $BASE_CENSUS"

r()   { echo "$VERDICT" | cut -d' ' -f"$1"; }
row() { local got; got="$(r "$1")"
  if [ "$got" = "ok" ]; then ok "R$1 $2"; else bad "R$1 $2 -- got '$got'"; fi
}
row 1 "the census root runs and reports defs=$WANT_DEFS skipped=$WANT_SKIP"
row 2 "the census is tfns=$WANT_TFNS ok=$WANT_OK err=$WANT_ERR"
row 3 "one class, n=$WANT_ERR first=$WANT_FIRST, every callee the TFn's own \$0 block"
row 4 "unfolded-ok equals ok -- the fold costs zero acceptances"

ALLOK="ok ok ok ok census=$WANT_TFNS/$WANT_OK/$WANT_ERR cls=1"
if [ "$VERDICT" != "$ALLOK" ]; then
  echo
  echo "  the base line is not ALLOK; the mutants are NOT run -- a mutant graded"
  echo "  against an already-red base measures nothing."
  echo
  echo "opt-census: $pass passed, $fail failed, 4 mutants unmeasured ($((SECONDS-T0))s)"
  exit 1
fi

# ─── the mutants ────────────────────────────────────────────────────────────
# run_mutant NAME WANT-LINE FILE SED... -> the whole verdict line is the pin.
run_mutant() {
  local name="$1" want="$2" rel="$3"; shift 3
  local m; m="$(scratch "mut" "$REPO/lib")"
  if [ -z "$m" ]; then bad "$name -- the scratch lib/ is a SYMLINK"; return; fi
  local e
  for e in "$@"; do
    if ! sub "$m/$rel" "$REPO/lib/$rel" "$e"; then
      bad "$name -- the mutation did not change lib/$rel (stale pattern)"; return
    fi
  done
  local got; got="$(measure "$m")"
  if [ "$got" = "$want" ]; then
    ok "$name -- [$got]"
  else
    bad "$name -- [$got] (want [$want])"
  fi
}

# M3 is the accept-count regression: 1517 down to 353. R4 stays green, because
# folded and un-folded fall together, which is why R2 cannot be dropped in
# favour of R4.
run_mutant "M3 call-lookup-in-prims" \
  "ok bad bad ok census=1549/353/1196 cls=1" "lowering/tal/check.chiral" \
  's|(case (tck-sig-assoc (tck-ce-fns ce) f)|(case (tck-sig-assoc (tck-ce-prims ce) f)|'

# M4 is the one mutant R4 convicts alone in kind: `ok` falls to 1503 while
# `unfolded-ok` holds at 1517, so the fold is now losing acceptances. It also
# splits the single class into three.
run_mutant "M4 fold-const-mistyped" \
  "ok bad bad bad census=1549/1504/45 cls=3" "lowering/upper/optimize.chiral" \
  's|(i-const dst (tt-i64) v)|(i-const dst (tt-str) v)|'

# M5 moves R3 and NOTHING ELSE. Every count holds, the message holds, the first
# instance holds, and the callee behind each of the 31 stops being the refused
# TFn's own `$0` block. A row pinning the three numbers alone passes it whole.
run_mutant "M5 outline-suffix" \
  "ok ok bad ok census=1549/1518/31 cls=1" "lowering/upper/lower.chiral" \
  's|(str-cat (str-cat name "\$") (i64->str ncase))|(str-cat (str-cat name "@") (i64->str ncase))|g'

# M6 is R1's falsifier: every def now skips, `defs=1518 skipped=1518`, and the
# census is empty rather than wrong.
run_mutant "M6 strip-lams-off-by-one" \
  "bad bad bad ok census=0/0/0 cls=0" "lowering/upper/lower.chiral" \
  's|(strip-lams body total)|(strip-lams body (+ total 1))|'

echo
echo "opt-census: $pass passed, $fail failed (${SECONDS}s wall from T0=$T0)"
[ "$fail" -eq 0 ]
