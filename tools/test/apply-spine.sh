#!/usr/bin/env bash
# apply-spine.sh -- the E188 gate: an `$apply` arm for a defunctionalization
# site whose `def-ctx` fails is the CALL SPINE, not the literal 0.
#
# suite phase: registered 2026-09-06 under the native-tests ruling; run-tests.sh is the authority for the number.
#   records/author-calls.md:30 -- four documents disagree about 21-23.
#
# ⚑ UNREGISTERED, AND IT CARRIES NO ROW SAYING SO.  `records/gate-audit.md`
# GA-24 measures why: a row naming its own `run_phase` line cannot fire, because
# deleting that line stops the script that holds the row.  So this gate is run
# by hand, exactly as `apply-word.sh`, `tal-check.sh`, `crypto.sh` and
# `capture-fields.sh` are, and what the suite witnesses of E188 is one thing --
# that `prog/e188-apply-spine.prog` compiles as a Phase 7 root.
#
# ─── THE SIX ROWS ───────────────────────────────────────────────────────────
# R1 to R3 are judged by the STDOUT of `tools/test/samples/e188_apply_spine.prog`,
# compiled and run.  R4 is judged by `prog/e188-apply-spine.prog`, which stops at
# `compile-front` and imports nothing under `lowering/tal/` (E154's eleven
# collisions).  R5 is judged by the compiler's own diagnostic on
# `tools/test/samples/e188_slot_break.prog`.  R6 is judged HERE, because it is
# the only leg holding two compiler binaries.  All six are reported on ONE line
# and every mutant pins the WHOLE line: GA-21 and GA-22 both convict a gate that
# names one row per mutant, because a mutant reddening a row outside its own pin
# is then invisible.
#
#   R1  `direct` prints 30 -- the same global called directly
#   R2  `apply` AGREES WITH `direct`                            <- the deliverable
#   R3  the honestly-shaped sibling still prints -10 -- the `some` path unchanged
#   R4  the family is BUILT and its dispatcher is CALLED: $apply0 is in
#       compile-front's NDef list and e188-use is too
#   R5  the slot-break fixture is refused with a named skip at the source def,
#       the blame NAMES the global at the refused site, and it does not read
#       `$apply<i>: .. unbound var`
#   R6  the PRE-CHANGE binary prints 0 on the `apply` line and this one prints 30
#
# The line carries a seventh field, `apply=<v>`, which is not a row.  It is the
# measured value of the `apply` line, and it is what separates M1 from M4: both
# redden R2 and R6 and nothing else, and without the value their pins would be
# the same string.  SPEC §5: M4 exists to separate "a spine" from "the RIGHT
# spine", and a pin that cannot tell it from M1 does not do that.
#
# ⚑ A SKIPPED COMPILE GRADES `absent`, NEVER `ok`.  If the ELF is empty or a
# line does not print, its token is `absent` -- the convention `apply-word.sh`
# spells (:60, :275) and `capture-fields.sh` uses (:243).  This is the whole
# point of R4: candidate (c), refusing the family outright, satisfies "the two
# agree" BY DELETING THE SECOND TERM, and a row reading only that would pass on
# absence.  It cannot here, because absence is a distinct cell and R4 asserts
# presence positively.
#
# ⚑ THE FIXTURE'S `def-ctx` FAILURE IS AN ANNOTATION, AND THE SPEC'S §1 CLAIM
# ABOUT EN-20's OWN FIXTURE IS CORRECTED BY MEASUREMENT.  `rewrite-one`
# (closconv-driver.chiral:251-253) leaves a def whose `def-ctx` fails untouched,
# so a genuinely shallow body does not lower either; under E188 the spine then
# CALLS it and the compile is refused by name rather than answering 0.  That is
# the element's argument (SPEC §3.3) and a strictly better outcome, but it is a
# refusal, so R1 to R3 would grade `absent` on that shape.  The fixture's own
# header carries the measurement.  `strip-lams` skips annotations
# (lower.chiral:215-218) and `peel-lam-exact` does not, which is the one shape
# where the spine's VALUE is observable.
#
# ─── R6 NEEDS A BASELINE BINARY ─────────────────────────────────────────────
# `bin/chirality-bin` is tracked, so the pre-change compiler is recoverable from
# git.  E188_BASE_REV names the revision and defaults to `4caf5f0`, the last
# commit before E188's promotion.  E188_BASE_CC overrides it with a path.  With
# neither, R6 scores `nobase` and this script exits 1: an unscored control is not
# a passing one.
#
# ⚑ THE DEFAULT REVISION IS PINNED ON PURPOSE AND IT WILL AGE.  R6 asks whether
# THIS change moved the value, so its baseline is THIS change's predecessor.  A
# stale pin is repaired by a fresh E188_BASE_REV, never by widening the
# comparison.
#
# ─── THE MUTANTS, AND ALL FIVE ARE SUBSTITUTIONS ────────────────────────────
# `records/gate-audit.md` GA-19: deleting an arm makes the module non-exhaustive,
# the compiler refuses the mutated tree, and the row is graded on a compile
# refusal instead of on the property it names.  Nothing below removes an arm or
# changes an arity.  Each substitution declares its occurrence count, the count
# is enforced at exactly 1, and the mutated file is `cmp -s`'d against the base
# before it is built (GA-18).
#
# ⚑ NO PIN BELOW IS EVIDENCE UNTIL ITS MUTANT HAS BEEN RUN.  EN-21 corrected
# E186's M5 for exactly that gap and `apply-word.sh:59-67` records the same
# correction being forced on E185 by measurement.  Every pin here was MEASURED
# on 2026-09-04, and two of them differ from the SPEC's table; the divergences
# are stated at their mutants.
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

FIXTURE="$REPO/tools/test/samples/e188_apply_spine.prog"
BREAKER="$REPO/tools/test/samples/e188_slot_break.prog"
PROBE="$REPO/prog/e188-apply-spine.prog"
CC_SRC="$REPO/lib/lowering/upper/closconv.chiral"
for f in "$FIXTURE" "$BREAKER" "$PROBE" "$CC_SRC"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its subject cannot fail"; exit 2; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# ─── the baseline compiler for R6 ───────────────────────────────────────────
BASE_CC="${E188_BASE_CC:-}"
BASE_REV="${E188_BASE_REV:-4caf5f0}"
if [ -z "$BASE_CC" ] && [ -n "$BASE_REV" ]; then
  BASE_CC="$TMP/base-cc"
  if ! ( cd "$REPO" && git show "$BASE_REV:bin/chirality-bin" ) >"$BASE_CC" 2>/dev/null || [ ! -s "$BASE_CC" ]; then
    BASE_CC=""
  else
    chmod +x "$BASE_CC"
  fi
fi

# ─── helpers ────────────────────────────────────────────────────────────────
# blob_of LIBDIR SRC OUT
blob_of() {
  ( cd "$REPO" && chirality_blob_file "$1:$REPO/prog" "$2" ) >"$3" 2>/dev/null && [ -s "$3" ]
}

# build_cc LIBDIR OUT -> OUT is a compiler binary built from LIBDIR's sources
build_cc() {
  local lib="$1" out="$2" blob="$TMP/cc.blob"
  blob_of "$lib" "$REPO/prog/compiler.prog" "$blob" || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ] || return 1
  chmod +x "$out"
}

# fixture_out CCPATH FIXBLOB OUT -> OUT holds the fixture's stdout, or is empty
fixture_out() {
  local cc="$1" fb="$2" out="$3" elf="$TMP/fx.elf"
  rm -f "$elf"
  ( ulimit -s unlimited; "$cc" <"$fb" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
  ( ulimit -s unlimited; "$elf" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ]
}

# field NAME FILE -> the value after "NAME: ", or the empty string
field() { sed -n "s/^$1 *: *//p" "$2" | head -1 | tr -d ' \r'; }

# blame_of CCPATH BRKBLOB OUT -> OUT holds the compiler's stderr on the breaker
blame_of() {
  local cc="$1" bb="$2" out="$3" elf="$TMP/bk.elf"
  rm -f "$elf"
  ( ulimit -s unlimited; "$cc" <"$bb" >"$elf" 2>"$out" )
  # a REFUSAL is what this row wants; an emitted ELF is the failure.
  [ -s "$elf" ] && return 1
  return 0
}

# probe_out LIBDIR FIXBLOB OUT -> OUT holds the probe's raw stdout
probe_out() {
  local lib="$1" fb="$2" out="$3" blob="$TMP/pr.blob" elf="$TMP/pr.elf"
  rm -f "$elf"
  blob_of "$lib" "$PROBE" "$blob" || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
  ( ulimit -s unlimited; "$elf" <"$fb" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ]
}

# ─── the six rows, measured against one compiler + one lib ──────────────────
# measure CCPATH LIBDIR FIXBLOB BRKBLOB -> echoes "R1 R2 R3 R4 R5 R6 apply=V"
measure() {
  local cc="$1" lib="$2" fb="$3" bb="$4"
  local o="$TMP/m.out" p="$TMP/m.probe" b="$TMP/m.blame"
  local r1 r2 r3 r4 r5 r6 dv av sv

  if fixture_out "$cc" "$fb" "$o"; then
    dv="$(field direct "$o")"; av="$(field apply "$o")"; sv="$(field sib "$o")"
  else
    dv=""; av=""; sv=""
  fi
  [ -n "$dv" ] && { [ "$dv" = "30" ] && r1=ok || r1=bad; } || r1=absent
  [ -n "$av" ] && { [ -n "$dv" ] && [ "$av" = "$dv" ] && r2=ok || r2=bad; } || r2=absent
  [ -n "$sv" ] && { [ "$sv" = "-10" ] && r3=ok || r3=bad; } || r3=absent

  if probe_out "$lib" "$fb" "$p"; then
    case "$(sed -n 's/^==E188== //p' "$p" | head -1)" in
      "ok ok") r4=ok ;;
      *)       r4=bad ;;
    esac
  else
    r4=bad
  fi

  if blame_of "$cc" "$bb" "$b"; then
    r5=ok
    grep -q 'skip chain for compile-main'      "$b" || r5=bad
    grep -q 'e188-plus'                        "$b" || r5=bad
    grep -Eq '\$apply[0-9]*:.*unbound var'     "$b" && r5=bad
  else
    r5=bad   # the breaker EMITTED an ELF: it was not refused at all
  fi

  # R6: the pre-change binary answers 0 on the apply line and this one answers 30.
  if [ -n "$BASE_CC" ] && [ -x "$BASE_CC" ]; then
    local bo="$TMP/m.base"
    if fixture_out "$BASE_CC" "$fb" "$bo" && [ "$(field apply "$bo")" = "0" ]; then
      [ "$av" = "30" ] && r6=ok || r6=bad
    else
      r6=bad
    fi
  else
    r6=nobase
  fi

  echo "$r1 $r2 $r3 $r4 $r5 $r6 apply=${av:-absent}"
}

# ─── the base run ───────────────────────────────────────────────────────────
echo "=== E188 (UNREGISTERED): the \$apply arm for a failed def-ctx is the call spine ==="
FB="$TMP/fix.blob"; BB="$TMP/brk.blob"
blob_of "$REPO/lib" "$FIXTURE" "$FB" || { echo "  FAIL  the fixture blob did not assemble"; exit 1; }
blob_of "$REPO/lib" "$BREAKER" "$BB" || { echo "  FAIL  the breaker blob did not assemble"; exit 1; }

VERDICT="$(measure "$CC" "$REPO/lib" "$FB" "$BB")"
echo "  line  $VERDICT"
if [ -z "$BASE_CC" ]; then
  echo "        R6: nobase -- E188_BASE_REV / E188_BASE_CC unset or unreadable"
fi

r()  { echo "$VERDICT" | cut -d' ' -f"$1"; }
row() { local got; got="$(r "$1")"
  if [ "$got" = "$3" ]; then ok "R$1 $2"; else bad "R$1 $2 -- got '$got', want '$3'"; fi
}
row 1 "direct prints 30"                                        ok
row 2 "apply AGREES with direct"                                ok
row 3 "the sibling still prints -10"                            ok
row 4 "\$apply0 is built and e188-use calls it"                 ok
row 5 "the slot break is refused, naming e188-plus"             ok
row 6 "the pre-change binary prints 0 and this one prints 30"   ok

ALLOK="ok ok ok ok ok ok apply=30"
if [ "$VERDICT" != "$ALLOK" ]; then
  echo
  echo "  the base line is not ALLOK; the mutants are NOT run (silent failure 4:"
  echo "  a mutant graded against an already-red base measures nothing)."
  echo
  echo "  apply-spine.sh: $pass ok, $fail FAIL, $((SECONDS - T0))s wall (records, sets no bar)"
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

run_mutant() {  # run_mutant NAME PIN DESC   (MUTLIB already set by mutate)
  local name="$1" pin="$2" desc="$3"
  local mfb="$TMP/$name.fix.blob" mbb="$TMP/$name.brk.blob" mcc="$TMP/$name.cc"
  if ! blob_of "$MUTLIB" "$FIXTURE" "$mfb" || ! blob_of "$MUTLIB" "$BREAKER" "$mbb"; then
    bad "$name -- BUILD:fail, a fixture blob did not assemble under the mutant lib"; return
  fi
  if ! build_cc "$MUTLIB" "$mcc"; then
    bad "$name -- BUILD:fail, the mutant compiler did not build; UNBUILT measures nothing"; return
  fi
  local line; line="$(measure "$mcc" "$MUTLIB" "$mfb" "$mbb")"
  if [ "$line" = "$pin" ]; then
    ok "$name $desc -- RUN: '$line'"
  else
    bad "$name $desc -- RUN: '$line', pinned '$pin'"
  fi
}

# M1: step 4's arm reverted to the literal 0.  The element's own falsifier, and
# it is BUILT AND RUN rather than derived (EN-21 corrected E186's M5 for exactly
# that gap).
if mutate M1 "lowering/upper/closconv.chiral" \
   '(cspine (c-global g) (spine-args 0 0 fields (+ k d) k m d))' '(c-lit-i 0)'; then
  run_mutant M1 "ok bad ok ok ok bad apply=0" "the arm is the literal 0 again"
fi

# M2: step 3's guard always refuses, so every cs-g family is poisoned and the
# dispatcher is never built.  R4's falsifier, and the reason R2 cannot be bought
# by deleting the second term.
# ⚑ MEASURED DIVERGENCE FROM THE SPEC'S TABLE.  §5 pins M2 at
# `absent absent absent bad ok bad`, on the reading that R5 goes green on the
# family drop alone.  It does under the REAL guard, where only the mismatching
# family is dropped: `e188-drive` still lowers, so the refusal lands on
# `compile-main` naming `e188-plus`, the global at the refused site.  Under M2
# the `(-> I64 I64)` family is poisoned too, `e188-drive` is refused first on
# `higher-order application`, and the skip chain stops there -- the blame no
# longer names the site that broke.  Measured: `compile-main <- e188-drive:
# extern does not lower: higher-order application`.  So R5 measures `bad`, and
# that is a real signal rather than a defect in the row: a guard that refuses
# everything cannot attribute anything.
if mutate M2 "lowering/upper/closconv.chiral" \
   '(=i ar (+ k (cc-llen(peel-pi-doms key))))' '(=i ar (+ k (+ 1 (cc-llen(peel-pi-doms key)))))'; then
  run_mutant M2 "absent absent absent bad bad bad apply=absent" "the guard refuses every site"
fi

# M3: step 3's guard never fires on a mismatch.  R5's falsifier: without it R5
# would be a row no mutant reddens, which is GA-22's shape.
# ⚑ REPOINTED BY E187.  The mismatch arm now calls `st-pois-defunc`, which
# poisons through `st-add-pois` and STATES why, so `(false (st-add-pois st key))`
# matched zero times and `mutate` graded this row `bad` on a stale pattern.  The
# substitution and M3's pin are unmoved: the arm still registers the mismatch
# instead of poisoning it.  ⚑ THE NEEDLE IS DOUBLE-QUOTED because the pinned
# discriminant carries an apostrophe in `global's`; a single-quoted argument
# cannot hold it, and a needle cut short of it leaves the tail behind, `sed`
# writes a tree that does not compile, and the row is graded on a build failure
# (GA-19 through a different door).
if mutate M3 "lowering/upper/closconv.chiral" \
   "(false (st-pois-defunc st key g \"family arity disagrees with the global's\"))" \
   '(false (st-add-site st key (cs-g g k fields)))'; then
  run_mutant M3 "ok ok ok ok bad ok apply=30" "the mismatch is registered instead of poisoned"
fi

# M4: ARITY-PRESERVING, VALUE-CHANGING.  spine-args' supplied index reads the
# binders in the opposite order; the argument count stays (+ k d), the fixture
# still compiles, $apply0 is still called, and the apply line prints a number
# that is not direct's.  This is what separates "a spine" from "the RIGHT
# spine": R2 without it is satisfied by any spine that happens to return 30.
# ⚑ The SPEC's original substitution -- (<i p arity) -> (<i p (- arity 1)) --
# was replaced by the SPEC audit because it makes the arm a PARTIAL application,
# which `lower` refuses at expr-args, collapsing M4 into M2.  This one keeps the
# count.  Its pin is identical to M1's on the six rows, which is why the line
# carries the measured apply value: M1 answers 0 and M4 answers 40.
if mutate M4 "lowering/upper/closconv.chiral" \
   '(c-var (- (- (+ m d) 1) (- p k)))' '(c-var (- (- (+ m d) 1) (- (- arity 1) p)))'; then
  run_mutant M4 "ok bad ok ok ok bad apply=40" "the spine reads its binders in reverse"
fi

# M5: g-subst-go's supplied index off by one.  The `some` path, so R3 alone.
# ⚑ MEASURED DIVERGENCE FROM THE SPEC'S TABLE.  §5 pins M5 at
# `ok ok bad ok ok bad`.  R6 reads the APPLY line, which is the `none` path and
# is untouched by a mutation of g-subst-go, so R6 measures `ok`.  The pin below
# is the measurement; the SPEC's sixth cell was derived and is wrong.
if mutate M5 "lowering/upper/closconv.chiral" \
   '(pair src (- (- (+ m d) 1) (- p k)))' '(pair src (- (+ m d) (- p k)))'; then
  run_mutant M5 "ok ok bad ok ok ok apply=30" "the some path's supplied index is off by one"
fi

echo
echo "  apply-spine.sh: $pass ok, $fail FAIL, $((SECONDS - T0))s wall (records, sets no bar)"
[ "$fail" -eq 0 ] || exit 1
exit 0
