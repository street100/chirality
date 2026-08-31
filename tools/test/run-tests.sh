#!/usr/bin/env bash
# tools/test/run-tests.sh -- the gating floor.  Zero Python; the compiler is
# bin/chirality-compile and nothing else compiles anything.
#
# Ported from the old tree's scaffold/tests/run-native.sh (12 phases).  SEVEN
# phases run here; the five that do not are named below with the reason, because
# a phase that silently vanishes is a gate that reports ok forever.
#
#   1  inline behavioral          PORTED  -- source strings -> compile + run
#   2  the test-runner            PORTED  -- rebuilt from source, then run
#   3  the check CLI              PORTED  -- tools/test/check-cli.sh
#   4  composition manifest       PORTED  -- tools/test/profile-target.sh
#   5  syscall manifest enforced  PORTED  -- tools/test/syscall-manifest.sh
#   6  linear mint discipline     PORTED  -- tools/test/linear-mint.sh
#   7  downstream roots compile   PORTED  -- inline sweep, below
#   8  module datasheet (E161)    NOT PORTED -- see MIGRATION-NOTES.md
#   9  sort adoption (E156)       NOT PORTED -- needs scaffold/tests/samples/
#  10  external-compiler C leg    DROPPED    -- external judgment cut, by decision
#  11  resolver + build state     NOT PORTED -- see MIGRATION-NOTES.md
#  12  the test floor (E168)      NOT PORTED -- needs scaffold/tests/samples/
#
# Each case's expected value comes from what the program MEANS, never from a
# golden capture of chirality's own output.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"

CC="${CHIRALITY_COMPILE:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-compile"
[ -x "$CC" ] || { echo "no compiler at $CC"; exit 2; }
echo "compiler: $CC ($(wc -c <"$CC") bytes)"

RESOLVER="$REPO/bin/chirality-resolve.sh"
[ -f "$RESOLVER" ] || { echo "  FAIL  $RESOLVER missing -- a broken checkout is not a configuration"; exit 2; }
# shellcheck disable=SC1090
. "$RESOLVER"
ROOTSPEC="lib:prog"

pass=0; fail=0
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT

# check <description> <expected-exit> <source>
check() {
  local desc="$1" want="$2" src="$3" elf err got ce
  elf="$T/e$((pass+fail))"; err="$T/x$((pass+fail))"
  ( ulimit -s unlimited; printf '%s' "$src" | "$CC" >"$elf" 2>"$err" ); ce=$?
  if [ $ce -ne 0 ]; then
    echo "  FAIL  $desc -- compile error: $(head -c 120 "$err")"; fail=$((fail+1)); return
  fi
  chmod +x "$elf"; "$elf"; got=$?
  if [ "$got" = "$want" ]; then echo "  ok    $desc (exit $got)"; pass=$((pass+1))
  else echo "  FAIL  $desc -- got exit $got, want $want"; fail=$((fail+1)); fi
}

echo
echo "=== Phase 1: inline behavioral (the compiler, zero Python) ==="
check "constant 42"          42 '(def compile-main (-> I64 I64) (lam (n) 42))'
check "constant 7"            7 '(def compile-main (-> I64 I64) (lam (n) 7))'
check "multi-def call"       42 '(def helper (-> I64 I64) (lam (x) x)) (def compile-main (-> I64 I64) (lam (n) (helper 42)))'
check "boxed data, field a"  42 '(data Box () (box (a I64) (b I64))) (def compile-main (-> I64 I64) (lam (n) (case (box 42 7) ((box a b) a))))'
check "boxed data, field b"   2 '(data Box () (box (a I64) (b I64))) (def compile-main (-> I64 I64) (lam (n) (case (box 40 2) ((box a b) b))))'
check "enum tag dispatch"     5 '(data C () (red) (grn)) (def compile-main (-> I64 I64) (lam (n) (case (grn) ((red) 0) ((grn) 5))))'

inline_pass=$pass; inline_fail=$fail
echo
echo "inline behavioral: $inline_pass passed, $inline_fail failed"

# ---- Phase 2: the test-runner ------------------------------------------------
# ⚑ THE REBUILD IS PART OF THE PHASE.  In the old tree this block executed a
# prebuilt, untracked binary that no phase rebuilt, so the runner's sources could
# be reverted wholesale and the phase stayed green off a stale artifact.  It is
# rebuilt from source here, under $CC, every run -- and the built binary lands in
# a scratch dir, never in a promoted location.
echo
echo "=== Phase 2: the test-runner (chirality walks its own samples) ==="
TR="${CHIRALITY_BUILD_DIR:-$T}/test-runner"
tr_ok=0
if ( cd "$REPO" && chirality_blob_file "$ROOTSPEC" prog/test-runner.prog ) >"$T/tr.blob" 2>"$T/tr.rerr" \
   && ( ulimit -s unlimited; "$CC" <"$T/tr.blob" >"$TR.new" 2>"$T/tr.cerr" ) \
   && [ -s "$TR.new" ]; then
  chmod +x "$TR.new"; mv -f "$TR.new" "$TR"
  echo "  rebuilt $TR from source ($(wc -c <"$TR") bytes)"
  tr_ok=1
else
  echo "  FAIL  test-runner did NOT rebuild from source: $(tr '\n' ' ' <"$T/tr.rerr" | head -c 200)$(tr '\n' ' ' <"$T/tr.cerr" | head -c 200)"
  fail=$((fail+1)); rm -f "$TR.new"
fi
if [ "$tr_ok" = 1 ]; then
  ( cd "$REPO" && ulimit -s unlimited && "$TR" )
  tr_rc=$?
  echo "test-runner exit: $tr_rc"
  [ "$tr_rc" -ne 0 ] && fail=$((fail+1))
else
  echo "  FAIL  no test-runner to run"; fail=$((fail+1))
fi

# ---- Phases 3-6: the sub-scripts, each loudly guarded ------------------------
# ⚑ EVERY GUARD IS LOUD.  These were written with no `else` in the old tree, so a
# missing script meant the phase did not appear and the run still exited 0 -- an
# absent gate returning success.
# Sub-scripts each print their own "<name>: N passed, M failed" tally; those are
# real assertion counts and they are ADDED UP here, so the run ends with one
# number rather than six a reader has to sum by hand.
tot_pass=0; tot_fail=0
tally() {  # tally <passed> <failed>
  tot_pass=$((tot_pass+$1)); tot_fail=$((tot_fail+$2))
}
run_phase() {
  local num="$1" title="$2" script="$HERE/$3" rc=0
  local log="$T/p$num.log"
  if [ -f "$script" ]; then
    echo
    echo "=== Phase $num: $title ==="
    bash "$script" 2>&1 | tee "$log"; rc="${PIPESTATUS[0]}"
    [ "$rc" -eq 0 ] || fail=$((fail+1))
    local line p f
    line="$(grep -oE '[0-9]+ passed, [0-9]+ failed' "$log" | tail -1)"
    if [ -n "$line" ]; then
      p="${line%% passed*}"; f="${line#*, }"; f="${f%% failed*}"
      tally "$p" "$f"
    fi
  else
    echo "  FAIL  Phase $num ($title): $script is missing -- a gate that is not there cannot pass"
    fail=$((fail+1))
  fi
}
run_phase 3 "chirality check CLI (native type-check)"          check-cli.sh
run_phase 4 "composition manifest (profile/target)"            profile-target.sh
run_phase 5 "syscall manifest enforced (E76 chokepoint)"       syscall-manifest.sh
run_phase 6 "linear mint discipline (E159 binder + arrow)"     linear-mint.sh

# ---- Phase 7: the downstream roots still compile -----------------------------
# A phase that only tests lib/ cannot see an app that lib/ broke.  Compile only
# (no run): several of these are TUI programs that want a tty.
#
# Sweeps EVERY root in the tree (a def of compile-main), with the known-failing
# ones listed by name and reason.  A root that starts failing is caught; a KNOWN
# one that starts PASSING is also reported, so the list cannot rot silently.
#
#   scriba-* flow-view-test : import manas/core/*, manas/chatter/*,
#                             manas/pipeline/*, manas/profile/* -- the manas
#                             subtree is NOT migrated (separate slice); only
#                             prog/manas/{backend,coordinator,fsm,manas} are here
#   t5_utf8 t5_vt_parser    : pre-existing TUI breakage, carried over from the
#   t6_apc_roundtrip          old tree's own KNOWN_FAIL list
echo
echo "=== Phase 7: downstream roots compile (the apps lib/ can break) ==="
KNOWN_FAIL=" scriba-main.prog scriba-manas-test.prog scriba-runview-test.prog scriba-runview-stream-test.prog scriba-test-b1.prog flow-view-test.prog t5_utf8.prog t5_vt_parser.prog t6_apc_roundtrip.prog "
r_pass=0; r_fail=0; r_skip=0; r_newpass=0
ALL_ROOTS="$( cd "$REPO" && grep -rl '^(def compile-main' lib prog 2>/dev/null \
                | while read -r x; do [ -L "$x" ] || echo "$x"; done | sort )"
for rootf in $ALL_ROOTS; do
  rb="$(basename "$rootf")"
  case "$rb" in *_reject_*) r_skip=$((r_skip+1)); continue ;; esac
  n=$((r_pass+r_fail+r_skip)); ok=1
  ( cd "$REPO" && chirality_blob_file "$ROOTSPEC" "$rootf" ) >"$T/rt.blob" 2>"$T/rt.err" || ok=0
  [ "$ok" = 1 ] && { ( ulimit -s unlimited; "$CC" <"$T/rt.blob" >/dev/null 2>"$T/rt.err" ) || ok=0; }
  case "$KNOWN_FAIL" in
    *" $rb "*)
      if [ "$ok" = 1 ]; then
        echo "  NEWPASS  $rb -- known-failing root now COMPILES; remove it from KNOWN_FAIL"
        r_newpass=$((r_newpass+1))
      else r_skip=$((r_skip+1)); fi ;;
    *)
      if [ "$ok" = 1 ]; then r_pass=$((r_pass+1))
      else echo "  FAIL  $rootf -- $(head -c 140 "$T/rt.err" | tr '\n' ' ')"; r_fail=$((r_fail+1)); fi ;;
  esac
done
echo
echo "downstream roots: $r_pass compiled, $r_fail failed, $r_skip known/negative, $r_newpass newly passing"
[ "$r_newpass" -eq 0 ] || fail=$((fail+1))
[ "$r_fail" -eq 0 ] || fail=$((fail+1))

tally "$r_pass" "$r_fail"

echo
echo "=== not ported from the old suite (named, not hidden) ==="
echo "  Phase 8  module datasheet (E161)      -- 808 lines of fixtures on old-tree module keys; see tools/test/MIGRATION-NOTES.md"
echo "  Phase 9  sort adoption (E156)         -- needs scaffold/tests/samples/{e151,e152,e156}; fixtures tree NOT migrated"
echo "  Phase 10 external-compiler C leg      -- DROPPED: external judgment cut by author decision"
echo "  Phase 11 resolver + build state       -- old basename-collision class is unreachable here; no committed blob artifact to cmp against"
echo "  Phase 12 the test floor (E168)        -- needs scaffold/tests/samples/e168_*, e170_*; fixtures tree NOT migrated"

# The assertion count, summed from the phases that report one:
#   Phase 1 inline behavioral · Phases 3-6 sub-script tallies · Phase 7 roots.
# Phase 2's own checks are counted by the test-runner binary itself, which
# prints its rank and check count on its own line above and gates by exit code.
echo
echo "assertions: $((tot_pass + inline_pass)) passed, $((tot_fail + inline_fail)) failed"
echo "  (Phase 1 inline $inline_pass/$((inline_pass+inline_fail)) · Phases 3-6 + Phase 7 roots: $tot_pass passed, $tot_fail failed)"
echo "  Phase 2: the test-runner reports its own checks above and gates by exit code."

echo
if [ "$fail" -eq 0 ]; then
  echo "chirality test: gate PASSED"
else
  echo "chirality test: gate FAILED ($fail failing check(s)/phase(s))"
fi
[ "$fail" -eq 0 ]
