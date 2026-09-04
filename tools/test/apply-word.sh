#!/usr/bin/env bash
# apply-word.sh -- the E185 gate: the `$apply<i>` dispatcher's domains are the
# erased word at the lowering type level.
#
# ⚑ UNREGISTERED, AND IT CARRIES NO ROW SAYING SO.  No suite phase number is
# assigned: `tools/test/run-tests.sh:332` and `docs/decisions/decision-lane-split.md:30`
# reserve 21 through 23 for Lane B, `tools/test/tal-check.sh:5` claims 22, and
# `docs/definitions/testing-floors.md:69` reads 21 the other way.  Four documents
# disagree, the E185 SPEC files it NEEDS-AUTHOR (decision 5), and this run
# assigns nothing.  `records/gate-audit.md` GA-24 measures why there is also no
# registration ASSERTION here: a row naming its own `run_phase` line cannot
# fire, because deleting that line stops the script that holds the row.  So this
# gate is run by hand, exactly as `tal-check.sh` is, and what the suite witnesses
# of E185 is one thing only -- that `prog/e185-apply-word.prog` compiles as a
# Phase 7 root.  A DEBT, discharged when the author settles the number.
#
# ─── THE SIX ROWS ───────────────────────────────────────────────────────────
# R1 to R5 are judged by `prog/e185-apply-word.prog`, which stops at
# `compile-front` and imports nothing under `lowering/tal/` (E154's eleven
# collisions).  R6 is judged HERE, because it is the only leg holding two
# compiler binaries.  All six are reported on ONE line and every mutant pins the
# WHOLE line: GA-21 and GA-22 both convict a gate that names one row per mutant,
# because a mutant reddening a row outside its own pin is then invisible.
#
#   R1  $apply0 is present in compile-front's NDef list
#   R2  every domain parameter of $apply0 is nt-word            <- the deliverable
#   R3  the leading parameter is (nt-data "$clo0" nil)
#   R4  $apply0's ret is the family's ground codomain (nt-i64), not nt-word
#   R5  $apply0's erased vector is empty
#   R6  the fixture's emitted ELF is byte-identical under the pre-change binary
#       and the promoted one
#
# ⚑ EVERY ROW READS WHAT A COMPILE PRODUCED.  The probe PRINTS and asserts
# nothing -- it always exits 0 -- and every comparison below is bash against a
# string constant held here.  The pretty.sh / tal-check.sh idiom.
#
# ─── R6 NEEDS A BASELINE BINARY ─────────────────────────────────────────────
# `bin/chirality-bin` is tracked, so the pre-change compiler is recoverable from
# git.  E185_BASE_REV names the revision; E185_BASE_CC overrides it with a path.
# With neither, R6 scores `nobase` and this script exits 1: an unscored control
# is not a passing one.
#
# ─── THE MUTANTS, AND ALL FIVE ARE SUBSTITUTIONS ────────────────────────────
# `records/gate-audit.md` GA-19: deleting an arm makes the module non-exhaustive,
# the compiler refuses the mutated tree, and the row is graded on a compile
# refusal instead of on the property it names.  Nothing below removes an arm or
# changes an arity.  Each substitution declares its occurrence count, the count
# is enforced, and the mutated file is `cmp -s`'d against the base before it is
# built (GA-18).
#
# ⚑ M5 IS THIS RUN'S ADDITION AND THE REASON IS A MEASUREMENT.  The SPEC pins M2
# at `R1 bad, R2-R5 absent, R6 bad`, on the reading that a short stated list
# drops the dispatcher.  It does -- but in the BACK half (`lower.chiral`'s
# `expr` refusing an `lc-lam`), and the probe stops at `compile-front`, which
# still emits the `$apply0` NDef.  So M2 measures `R2 bad` and `R6 bad`, and R1
# would be a row no mutant reddens, which is GA-22's shape.  M5 is R1's
# falsifier: `peel-def`'s stated branch returns `(none)`, the dispatcher never
# reaches the NDef list, and R1 goes red where the probe can see it.
#
# The mutant harness is a scratch lib/ (`cp -a`, `sed -i`), not
# `tools/test/mutant.sh`: that one asserts a mutated COMPILER differs, and these
# mutants must be read through the probe's own front half as well as through a
# rebuilt compiler.
#
# Wall clock is printed and sets no bar (the 2026-09-01 ruling,
# docs/benchmarks/README.md:29).  Zero Python.
set -uo pipefail
T0=$SECONDS

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"

CC="${CHIRALITY_COMPILE:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
[ -x "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
# shellcheck disable=SC1091
. "$REPO/bin/chirality-resolve.sh"

FIXTURE="$REPO/tools/test/samples/e185_apply_word.prog"
PROBE="$REPO/prog/e185-apply-word.prog"
DRIVER_SRC="$REPO/lib/lowering/upper/closconv-driver.chiral"
FRONT_SRC="$REPO/lib/lowering/compile-front.chiral"
for f in "$FIXTURE" "$PROBE" "$DRIVER_SRC" "$FRONT_SRC"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its subject cannot fail"; exit 2; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# ─── the baseline compiler for R6 ───────────────────────────────────────────
BASE_CC="${E185_BASE_CC:-}"
BASE_REV="${E185_BASE_REV:-}"
if [ -z "$BASE_CC" ] && [ -n "$BASE_REV" ]; then
  BASE_CC="$TMP/base-cc"
  if ! ( cd "$REPO" && git show "$BASE_REV:bin/chirality-bin" ) >"$BASE_CC" 2>/dev/null || [ ! -s "$BASE_CC" ]; then
    BASE_CC=""
  else
    chmod +x "$BASE_CC"
  fi
fi

# ─── helpers ────────────────────────────────────────────────────────────────
# fixture_blob LIBDIR OUT
fixture_blob() {
  ( cd "$REPO" && chirality_blob_file "$1:$REPO/prog" "$FIXTURE" ) >"$2" 2>/dev/null && [ -s "$2" ]
}

# probe_run LIBDIR FIXBLOB OUT -> OUT holds the probe's raw stdout
probe_run() {
  local lib="$1" fb="$2" out="$3" blob="$TMP/pr.blob" elf="$TMP/pr.elf"
  ( cd "$REPO" && chirality_blob_file "$lib:$REPO/prog" "$PROBE" ) >"$blob" 2>/dev/null || return 1
  [ -s "$blob" ] || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
  ( ulimit -s unlimited; "$elf" <"$fb" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ]
}

# build_cc LIBDIR OUT -> OUT is a compiler binary built from LIBDIR's sources
build_cc() {
  local lib="$1" out="$2" blob="$TMP/cc.blob"
  ( cd "$REPO" && chirality_blob_file "$lib:$REPO/prog" "$REPO/prog/compiler.prog" ) >"$blob" 2>/dev/null || return 1
  [ -s "$blob" ] || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ] || return 1
  chmod +x "$out"
}

# fix_elf CCPATH FIXBLOB OUT
fix_elf() {
  ( ulimit -s unlimited; "$1" <"$2" >"$3" 2>/dev/null ) || return 1
  [ -s "$3" ]
}

# five_tokens FILE -> the probe's five tokens
five_tokens() { sed -n 's/^==E185== //p' "$1" | head -1; }

# ─── the base run ───────────────────────────────────────────────────────────
echo "=== E185 (UNREGISTERED): the \$apply dispatcher's domains are the erased word ==="
BASEBLOB="$TMP/fix.blob"
if ! fixture_blob "$REPO/lib" "$BASEBLOB"; then
  echo "  FAIL  the fixture blob did not assemble"; exit 1
fi
BOUT="$TMP/base.out"
if ! probe_run "$REPO/lib" "$BASEBLOB" "$BOUT"; then
  echo "  FAIL  the probe did not build/run against the real lib/"; exit 1
fi
T15="$(five_tokens "$BOUT")"

# R6 on the shipping tree
R6="nobase"; R6WHY="E185_BASE_REV / E185_BASE_CC unset"
if [ -n "$BASE_CC" ] && [ -x "$BASE_CC" ]; then
  BE="$TMP/base.elf"; PE="$TMP/prom.elf"
  if fix_elf "$BASE_CC" "$BASEBLOB" "$BE" && fix_elf "$CC" "$BASEBLOB" "$PE"; then
    if cmp -s "$BE" "$PE"; then R6="ok"; R6WHY="$(wc -c <"$BE") bytes, identical"
    else R6="bad"; R6WHY="$(wc -c <"$BE") vs $(wc -c <"$PE") bytes, differ"; fi
  else
    R6="bad"; R6WHY="one of the two binaries did not emit the fixture's ELF"
  fi
fi
VERDICT="$T15 $R6"
echo "  line  $VERDICT"
echo "$(sed -n '2,4p' "$BOUT" | sed 's/^/        /')"
echo "        R6: $R6WHY"

r()  { echo "$VERDICT" | cut -d' ' -f"$1"; }
row() { # row N NAME WANT
  local got; got="$(r "$1")"
  if [ "$got" = "$3" ]; then ok "R$1 $2"; else bad "R$1 $2 -- got '$got', want '$3'"; fi
}
row 1 "\$apply0 is present in compile-front's NDef list"        ok
row 2 "every domain param of \$apply0 is nt-word"               ok
row 3 "the leading param is (nt-data \"\$clo0\" nil)"           ok
row 4 "\$apply0's ret is the ground codomain, not nt-word"      ok
row 5 "\$apply0's erased vector is empty"                       ok
row 6 "the fixture's ELF is byte-identical under both binaries" ok

ALLOK="ok ok ok ok ok ok"
if [ "$VERDICT" != "$ALLOK" ]; then
  echo
  echo "  the base line is not ALLOK; the mutants are NOT run (silent failure 4:"
  echo "  a mutant graded against an already-red base measures nothing)."
  echo
  echo "  apply-word.sh: $pass ok, $fail FAIL, $((SECONDS - T0))s wall (records, sets no bar)"
  exit 1
fi

# ─── the mutant harness ─────────────────────────────────────────────────────
# ⚑ THE SCRATCH lib/ MUST BE A REAL DIRECTORY, NEVER A SYMLINK.  cp -a copies a
# symlink AS a symlink and every sed -i then writes THROUGH it into the tree
# under test (the pretty.sh arc, nineteen phantom failures).
MUTLIB=""
mutate() {  # mutate NAME RELPATH NEEDLE REPLACEMENT
  local name="$1" rel="$2" needle="$3" repl="$4"
  MUTLIB="$TMP/mutlib-$name"
  rm -rf "$MUTLIB"; cp -a "$REPO/lib" "$MUTLIB"
  if [ -L "$MUTLIB" ]; then
    bad "$name -- the scratch lib/ is a SYMLINK; sed would write into the tree under test"; return 1
  fi
  local tgt="$MUTLIB/$rel"
  local n; n="$(grep -cF -- "$needle" "$tgt")"
  if [ "$n" -ne 1 ]; then
    bad "$name -- needle matched $n time(s), not 1 (stale pattern; the mutation would be a lie)"; return 1
  fi
  sed -i "s|$needle|$repl|" "$tgt"
  if cmp -s "$tgt" "$REPO/$rel"; then
    bad "$name -- the mutation did not change $rel (stale pattern)"; return 1
  fi
  return 0
}

# run_mutant NAME PIN DESC  (MUTLIB already set by mutate)
run_mutant() {
  local name="$1" pin="$2" desc="$3"
  local fb="$TMP/$name.fix.blob" out="$TMP/$name.out" mcc="$TMP/$name.cc"
  local m15 m6 melf="$TMP/$name.elf"
  if ! fixture_blob "$MUTLIB" "$fb"; then
    bad "$name -- BUILD:fail, the fixture blob did not assemble under the mutant lib"; return
  fi
  if ! probe_run "$MUTLIB" "$fb" "$out"; then
    bad "$name -- BUILD:fail, the probe did not build/run under the mutant; UNBUILT measures nothing"; return
  fi
  m15="$(five_tokens "$out")"
  if ! build_cc "$MUTLIB" "$mcc"; then
    bad "$name -- BUILD:fail, the mutant compiler did not build; UNBUILT measures nothing"; return
  fi
  if fix_elf "$mcc" "$BASEBLOB" "$melf"; then
    if cmp -s "$TMP/base.elf" "$melf"; then m6="ok"; else m6="bad"; fi
  else
    m6="bad"   # a compiler that cannot emit the fixture certainly does not emit the base's bytes
  fi
  local line="$m15 $m6"
  if [ "$line" = "$pin" ]; then
    ok "$name $desc -- RUN: '$line'"
  else
    bad "$name $desc -- RUN: '$line', pinned '$pin'"
    sed -n '2,4p' "$out" | sed 's/^/        /'
  fi
}

# M1: sp-get's hit branch returns (none), so peel-def always falls to today's peel.
if mutate M1 "lowering/compile-front.chiral" '(true (some ps))' '(true (none))'; then
  run_mutant M1 "ok bad ok ok ok ok" "the stated channel is ignored at the bridge"
fi

# M2: apply-ptys states one domain too few.
if mutate M2 "lowering/upper/closconv-driver.chiral" '(word-ptys (cc-llen doms))' '(word-ptys (- (cc-llen doms) 1))'; then
  run_mutant M2 "ok bad ok ok ok bad" "the stated list is one short"
fi

# M3: apply-ptys erases the leading $clo argument too.
if mutate M3 "lowering/upper/closconv-driver.chiral" '(cons (nt-data (clo-name i) nil) (word-ptys' '(cons (nt-word) (word-ptys'; then
  run_mutant M3 "ok ok bad ok ok ok" "the leading \$clo argument erased as well"
fi

# M4: peel-def's stated branch overwrites the codomain with the erased word.
if mutate M4 "lowering/compile-front.chiral" '(ndef name sptys ret (ty-erased ty 0) snb)' '(ndef name sptys (nt-word) (ty-erased ty 0) snb)'; then
  run_mutant M4 "ok ok ok bad ok ok" "the ground codomain erased with the domains"
fi

# M5: peel-def's stated branch drops the def instead of peeling it.  R1's falsifier.
if mutate M5 "lowering/compile-front.chiral" '((some nb) (some (ndef name sptys ret (ty-erased ty 0) snb)))' '((some nb) (none))'; then
  run_mutant M5 "bad absent absent absent absent bad" "the dispatcher never reaches the NDef list"
fi

echo
echo "  apply-word.sh: $pass ok, $fail FAIL, $((SECONDS - T0))s wall (records, sets no bar)"
[ "$fail" -eq 0 ] || exit 1
exit 0
