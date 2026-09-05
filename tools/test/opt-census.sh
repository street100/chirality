#!/usr/bin/env bash
# opt-census.sh -- the gate over the optimizer's re-check on the shipping path:
# the census EN-24 closed requirement 4 on, re-derived, and the wiring it
# measures, asserted.
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
# `5b7478f` wired `re-check` onto the shipping path at
# `lib/lowering/compile-back.chiral:16` and 239, and shipped zero files under
# `tools/test/`. Cutting the import left the suite at `391 passed, 0 failed`.
# The figure the closure was written on, `1,582 TFns / 1,550 chk-ok /
# 32 chk-err`, came from a probe that was never committed. EN-25 records both.
#
# ─── THE SIX ROWS ───────────────────────────────────────────────────────────
# R1 to R4 are judged from `prog/optimizer-census.prog`'s stdout, built from the
# lib/ under measurement and run over that lib/'s own compiler blob. R5 and R6
# are judged HERE, because each holds a second tree the probe cannot see.
#
#   R1  the census root builds, runs, and reports defs=1551 skipped=10
#   R2  the census is tfns=1582 ok=1550 err=32
#   R3  ONE error class, `call: unknown tal function`, n=32, first bput-u8, and
#       every one of the 32 unknown callees is the refused TFn's OWN outlined
#       block `<name>$0`
#   R4  unfolded-ok equals ok -- the fold costs zero acceptances
#   R5  the `chk-ok` guard CHANGES WHAT THE COMPILER EMITS: a compiler built
#       from this lib/ and one built with `re-check` forced to answer `chk-ok`
#       emit DIFFERENT bytes for `opt_census_outline.prog` and IDENTICAL bytes
#       for `opt_census_control.prog`
#   R6  `lowering/upper/optimize` is IN the compiler blob, and cutting the
#       import at compile-back.chiral:16 makes it leave
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
# block is refused. All 32 are that one shape. R3 asserts it positively, so a
# later change that makes the 32 something else cannot pass by keeping the count.
#
# ⚑ R5 IS THE ROW EN-25 SAYS WAS MISSING, AND IT IS BEHAVIOURAL. A grep for the
# import passes on a tree where `opt-tfns` ignores the verdict it computes. R5
# builds two compilers and compares WHAT THEY EMIT for one fixed input: with the
# guard, the 32 refused TFns fall back to the un-folded `t`; without it, their
# folded residual is adopted and the emitted bytes move.
#
# ⚑ COMPARING THE TWO COMPILERS' OWN BYTES WOULD BE A ROW NOTHING CAN MOVE, AND
# A FIRST DRAFT OF THIS GATE MEASURED EXACTLY THAT. The counter-mutation edits a
# source line, so the two binaries differ for that reason alone: the draft
# scored R5 green under M2, which BYPASSES THE GUARD ENTIRELY. That is
# gate-audit.md GA-04's class, caught by running the mutant.
#
# ⚑ ON THE COMPILER'S OWN BLOB THE GUARD IS INERT, AND THAT IS WHY R5 NEEDS A
# FIXTURE. Measured 2026-09-05: the guarded compiler and the free one emit
# byte-identical output for `prog/compiler.prog`'s blob, 1,241,464 bytes each.
# None of the 32 refused TFns carry foldable work outside the block that
# outlined, so their residual and their fallback emit the same code. The check
# runs on every compile and refuses 32 residuals that would have cost nothing.
# `opt_census_outline.prog` is the smallest program where the refusal is
# observable, and R5 is measured there.
#
# ⚑ R6's NEGATIVE HALF IS CHECKED BESIDE A POSITIVE ONE, on render-doc.sh's
# G9-plus-M11 precedent that E197's R6 follows. A needle that matches nothing
# anywhere passes by looking at nothing, so the row cuts the import in a scratch
# lib/ and requires the needle to disappear.
#
# ─── THE SIX MUTANTS, AND ALL SIX ARE SUBSTITUTIONS ─────────────────────────
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
#   M1  unwire-the-import      compile-back.chiral:16's import is commented out
#                              and `opt-tfns` becomes the identity -- the tree
#                              exactly as it stood before `5b7478f`
#   M2  adopt-without-chk-ok   `opt-tfns`'s `chk-err` arm adopts `(fold t)`
#   M3  call-lookup-in-prims   ck-instr's `i-call` arm reads the PRIM table
#   M4  fold-const-mistyped    the folded constant is annotated `(tt-str)`
#   M5  outline-suffix         `outline` names its block `<name>@<n>`
#   M6  strip-lams-off-by-one  `compile-fn` peels one lambda too many
#
# ⚑ M1 LEAVES R1 TO R4 GREEN ON PURPOSE. `prog/optimizer-census.prog` imports
# `lowering/upper/optimize` in its own right, so unwiring the SHIPPING path does
# not disturb the probe. That is what localizes M1 onto R5 and R6 exactly, and
# it is the whole difference between this gate and the grep EN-25 found.
#
# ⚑ M4 IS WHAT SEPARATES R4 FROM R2. A folded residual the check refuses drops
# `ok` while `unfolded-ok` holds at 1550, which is the one shape a row reading
# only the accept count cannot tell from a smaller program.
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
FX_OUT="$REPO/tools/test/samples/opt_census_outline.prog"
FX_CTL="$REPO/tools/test/samples/opt_census_control.prog"
BACK="$REPO/lib/lowering/compile-back.chiral"
OPT="$REPO/lib/lowering/upper/optimize.chiral"
CHK="$REPO/lib/lowering/tal/check.chiral"
LOW="$REPO/lib/lowering/upper/lower.chiral"
for f in "$PROBE" "$FX_OUT" "$FX_CTL" "$BACK" "$OPT" "$CHK" "$LOW"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its subject cannot fail"; exit 2; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# ─── the pins ───────────────────────────────────────────────────────────────
# Reproduced 2026-09-05 by prog/optimizer-census.prog over the compiler's own
# blob. EN-24 cites the first three from an uncommitted probe and they agree.
WANT_DEFS=1551
WANT_SKIP=10
WANT_TFNS=1582
WANT_OK=1550
WANT_ERR=32
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

# build_cc LIBDIR OUT -> OUT is a compiler built from LIBDIR
build_cc() {
  local lib="$1" out="$2" b="$TMP/cc.$$.blob"
  blob "$lib" "$REPO/prog/compiler.prog" "$b" || return 1
  ( ulimit -s unlimited; "$CC" <"$b" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ] || return 1
  chmod +x "$out"
}

# census LIBDIR OUT -> OUT holds the probe's stdout, the probe BUILT from LIBDIR
# and run over the TRACKED lib/'s compiler blob.
#
# ⚑ THE SUBJECT BLOB IS ALWAYS THE TRACKED ONE, NEVER THE MUTANT'S. A mutant
# that changes lib/ changes the blob assembled from it, and a census taken over
# that blob then moves because the INPUT shrank rather than because the check
# changed. Holding the input fixed is what lets M1 land on R5 and R6 alone.
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

# emit CCPATH BLOB OUT -> OUT holds what CCPATH compiled BLOB to
emit() {
  local cc="$1" b="$2" out="$3"
  rm -f "$out"
  ( ulimit -s unlimited; "$cc" <"$b" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ]
}

# f KEY FILE -> the value of KEY= on the census line
f() { sed -n 's/^census .*/&/p' "$2" | tr ' ' '\n' | sed -n "s/^$1=//p" | head -1; }

# ─── the six rows over one lib/ ─────────────────────────────────────────────
# measure LIBDIR -> "R1 R2 R3 R4 R5 R6 census=<t>/<o>/<e> cls=<n>"
measure() {
  local lib="$1" o="$TMP/m.census"
  local r1 r2 r3 r4 r5 r6 tn oks er dfs sk uo ncls
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

  # R5: the guard changes WHAT THE COMPILER EMITS, on a fixture and not on its
  # control.
  #
  # ⚑ THE TWO COMPILERS ARE COMPARED BY THEIR OUTPUT, NEVER BY THEIR OWN BYTES.
  # The counter-mutation edits a source line, so the two compiler binaries
  # differ for that reason alone and a `cmp` over them is green under every
  # mutant below -- a row nothing can move, which is the defect gate-audit.md
  # GA-04 records eleven of. What separates the trees is what each compiler DOES
  # to a fixed input.
  #
  # ⚑ AND THE CONTROL IS HALF THE ROW. `opt_census_outline.prog` carries the
  # 32's shape and must MOVE; `opt_census_control.prog` carries the same
  # arithmetic with nothing outlined and must NOT. Without the second half the
  # row would score green on a difference coming from the edit rather than from
  # the guard.
  local g; g="$(scratch "r5lib" "$lib")"
  if [ -z "$g" ]; then
    r5=bad
  elif ! sub "$g/lowering/upper/optimize.chiral" "$lib/lowering/upper/optimize.chiral" \
         's|((tck-err m) (chk-err m))|((tck-err m) (chk-ok t))|'; then
    r5=stale
  elif ! build_cc "$lib" "$TMP/cc.base" || ! build_cc "$g" "$TMP/cc.free"; then
    r5=nocc
  elif ! blob "$lib" "$FX_OUT" "$TMP/fx.blob" || ! blob "$lib" "$FX_CTL" "$TMP/ct.blob"; then
    r5=noblob
  elif ! emit "$TMP/cc.base" "$TMP/fx.blob" "$TMP/fx.base" \
       || ! emit "$TMP/cc.free" "$TMP/fx.blob" "$TMP/fx.free" \
       || ! emit "$TMP/cc.base" "$TMP/ct.blob" "$TMP/ct.base" \
       || ! emit "$TMP/cc.free" "$TMP/ct.blob" "$TMP/ct.free"; then
    r5=noemit
  elif cmp -s "$TMP/fx.base" "$TMP/fx.free"; then
    r5=bad
  elif ! cmp -s "$TMP/ct.base" "$TMP/ct.free"; then
    r5=ctl
  else
    r5=ok
  fi

  # R6: the module is in the blob, and cutting the import takes it out.
  local h b1 b2 n1 n2; h="$(scratch "r6lib" "$lib")"
  if [ -z "$h" ]; then
    r6=bad
  elif ! sub "$h/lowering/compile-back.chiral" "$lib/lowering/compile-back.chiral" \
         's|^(import "lowering/upper/optimize")|; (import "lowering/upper/optimize")|'; then
    r6=stale
  else
    b1="$TMP/r6.a"; b2="$TMP/r6.b"
    if blob "$lib" "$REPO/prog/compiler.prog" "$b1" && blob "$h" "$REPO/prog/compiler.prog" "$b2"; then
      n1="$(grep -c -F -- '(def re-check' "$b1")"
      n2="$(grep -c -F -- '(def re-check' "$b2")"
      { [ "$n1" -ge 1 ] && [ "$n2" -eq 0 ]; } && r6=ok || r6=bad
    else
      r6=bad
    fi
  fi

  echo "$r1 $r2 $r3 $r4 $r5 $r6 census=$tn/$oks/$er cls=$ncls"
}

# The one fixed subject: the TRACKED lib/'s compiler blob. Every census is taken
# over it and every R5 emission is taken from it.
SUBJECT="$TMP/subject.blob"
blob "$REPO/lib" "$REPO/prog/compiler.prog" "$SUBJECT" \
  || { echo "  FAIL  the compiler blob did not assemble -- nothing here can be measured"; exit 2; }

echo "=== the optimizer re-check census, and the wiring under it (unregistered; run by hand) ==="

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
row 5 "the chk-ok guard moves the outlining fixture and not its control"
row 6 "lowering/upper/optimize is in the blob and the cut import takes it out"

ALLOK="ok ok ok ok ok ok census=$WANT_TFNS/$WANT_OK/$WANT_ERR cls=1"
if [ "$VERDICT" != "$ALLOK" ]; then
  echo
  echo "  the base line is not ALLOK; the mutants are NOT run -- a mutant graded"
  echo "  against an already-red base measures nothing."
  echo
  echo "opt-census: $pass passed, $fail failed, 6 mutants unmeasured ($((SECONDS-T0))s)"
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

# M1 restores the tree exactly as it stood before `5b7478f`. R1 to R4 stay
# green: the probe imports `lowering/upper/optimize` in its own right and the
# census is taken over the TRACKED blob, so nothing about the probe moves. R5
# goes red because there is no adoption left to bypass, and R6 goes `stale`
# because its own counter-sed finds the import already commented out. That pair
# is the whole of what `5b7478f` added and what EN-25 says nothing asserted.
run_mutant "M1 unwire-the-import" \
  "ok ok ok ok bad stale census=1582/1550/32 cls=1" "lowering/compile-back.chiral" \
  's|^(import "lowering/upper/optimize")|; (import "lowering/upper/optimize")|' \
  's|(cons (case (re-check ce (fold t)) ((chk-ok v) v) ((chk-err m) t))|(cons t|'

# M2 keeps the import, keeps the call to `re-check`, and throws the verdict
# away. R5 alone convicts it, and it is the mutant that killed the first draft
# of this gate.
run_mutant "M2 adopt-without-chk-ok" \
  "ok ok ok ok bad ok census=1582/1550/32 cls=1" "lowering/compile-back.chiral" \
  's|((chk-err m) t))|((chk-err m) (fold t)))|'

# M3 is the accept-count regression: 1550 down to 358. R4 stays green, because
# folded and un-folded fall together, which is why R2 cannot be dropped in
# favour of R4.
run_mutant "M3 call-lookup-in-prims" \
  "ok bad bad ok ok ok census=1582/358/1224 cls=1" "lowering/tal/check.chiral" \
  's|(case (tck-sig-assoc (tck-ce-fns ce) f)|(case (tck-sig-assoc (tck-ce-prims ce) f)|'

# M4 is the one mutant R4 convicts alone in kind: `ok` falls to 1536 while
# `unfolded-ok` holds at 1550, so the fold is now losing acceptances. It also
# splits the single class into three and leaves the mutated compiler unable to
# emit, which R5 reports as `noemit`.
run_mutant "M4 fold-const-mistyped" \
  "ok bad bad bad noemit ok census=1582/1536/46 cls=3" "lowering/upper/optimize.chiral" \
  's|(i-const dst (tt-i64) v)|(i-const dst (tt-str) v)|'

# M5 moves R3 and NOTHING ELSE. Every count holds, the message holds, the first
# instance holds, and the callee behind each of the 32 stops being the refused
# TFn's own `$0` block. A row pinning the three numbers alone passes it whole.
run_mutant "M5 outline-suffix" \
  "ok ok bad ok ok ok census=1582/1550/32 cls=1" "lowering/upper/lower.chiral" \
  's|(str-cat (str-cat name "\$") (i64->str ncase))|(str-cat (str-cat name "@") (i64->str ncase))|g'

# M6 is R1's falsifier: every def now skips, `defs=1551 skipped=1551`, and the
# census is empty rather than wrong.
run_mutant "M6 strip-lams-off-by-one" \
  "bad bad bad ok noemit ok census=0/0/0 cls=0" "lowering/upper/lower.chiral" \
  's|(strip-lams body total)|(strip-lams body (+ total 1))|'

echo
echo "opt-census: $pass passed, $fail failed (${SECONDS}s wall from T0=$T0)"
[ "$fail" -eq 0 ]
