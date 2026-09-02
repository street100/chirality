#!/usr/bin/env bash
# tools/test/run-tests.sh -- the gating floor.  Zero Python; the compiler is
# bin/chirality-bin and nothing else compiles anything.
#
# Ported from the old tree's scaffold/tests/run-native.sh (12 phases).  SEVEN
# of those run here; the five that do not are named below with the reason,
# because a phase that silently vanishes is a gate that reports ok forever.
# Phases 13-17 are new here -- none has an old-tree number to inherit, and
# reusing 8-12 would have overwritten a name that is still owed.
#
#   1  inline behavioral          PORTED  -- source strings -> compile + run
#   2  the test-runner            PORTED  -- rebuilt from source, then run
#   3  the check CLI              PORTED  -- tools/test/check-cli.sh
#   4  composition manifest       PORTED  -- tools/test/profile-target.sh
#   5  syscall manifest enforced  PORTED  -- tools/test/syscall-manifest.sh
#   6  linear mint discipline     PORTED  -- tools/test/linear-mint.sh
#   7  downstream roots compile   PORTED  -- inline sweep, below
#   8  module datasheet (E161)    NOT PORTED -- see MIGRATION-NOTES.md
#   9  sort adoption (E156)       NOT PORTED -- fixtures landed slice 8; script owed
#  10  external-compiler C leg    DROPPED    -- external judgment cut, by decision
#  11  resolver + build state     NOT PORTED -- see MIGRATION-NOTES.md
#  12  the test floor (E168)      NOT PORTED -- fixtures landed slice 8; script owed
#  13  typed diagnostics (E157)  NEW HERE   -- tools/test/diag.sh
#  14  layout algebra (E158)     NEW HERE   -- tools/test/doc.sh
#  15  horizontal composition    NEW HERE   -- tools/test/row.sh
#      (E174 r-row + rnd-cols)
#  16  ambient face restore      NEW HERE   -- tools/test/face.sh
#      (E175 face-join + rnd-restore)
#  17  doc->rendering            NEW HERE   -- tools/test/render-doc.sh
#      (E158 commit 4)
#  18  the term printer (E181)   NEW HERE   -- tools/test/pretty.sh
#      (Term -> Doc, and its output IS source)
#  19  the total matcher (E173)  NEW HERE   -- tools/test/matcher.sh
#      (pd + norm, and the prose-lint differential)
#
# Each case's expected value comes from what the program MEANS, never from a
# golden capture of chirality's own output.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"

CC="${CHIRALITY_COMPILE:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
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
#   t5_utf8 t5_vt_parser    : pre-existing TUI breakage, carried over from the
#   t6_apc_roundtrip          old tree's own KNOWN_FAIL list
#   _recurse-ceiling        : a diagnostic that is SUPPOSED to fail. Its header
#                             says so: "increment N until B1 produces a runnable
#                             ELF that segfaults or B1 itself fails". It probes
#                             the native recursion ceiling by breaking.
#   e42_supervisor_accept   : binds `sock-connect`, which LEDGER E127 marks
#                             DEFERRED -- "needs a live peer; not the hermetic
#                             milestone". The wrapper is registered in
#                             crossing-wraps; the extern does not lower.
#
# The six scriba-* / flow-view-test roots left this list when the manas subtree
# landed (slice 4).  They were never broken -- they imported twelve manas keys
# that resolved to nothing.  Nothing in them was edited to fix it.
echo
echo "=== Phase 7: downstream roots compile (the apps lib/ can break) ==="
KNOWN_FAIL=" t5_utf8.prog _recurse-ceiling.prog e42_supervisor_accept.prog "
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

# ⚑ NOT TALLIED INTO THE ASSERTION COUNT, and that is the correction.  These rows
# were `tally "$r_pass" "$r_fail"` until 2026-08-31, which folded them into the same
# headline number as E157's mutant-convicted goldens.  At that point 36 of the 149
# reported assertions -- a quarter of the number -- were "the compiler exited 0 on
# this file".  A compile carries NO expected value: nothing here says what any root
# MEANS, only that producing it did not fail, so it cannot be ranked on the
# provenance ladder at all and averaging it with rows that can overstates the suite.
# It stays a gate (a failing root still fails the run, above); it stops being an
# assertion.  Reported on its own line, in its own units.

# ---- Phase 13: typed diagnostics (E157) --------------------------------------
# Not an old-tree phase: E157 landed after the migration.  The reason it needs a
# phase of its own is that the element changes NO message -- every string the
# compiler emits after it is a string it emitted before -- so its gate is the
# EVIDENCE (both sides of a redeclare, declared-vs-observed) plus seven named
# mutants that must make the fixture go red.  It also carries the first
# assertion anywhere on "let binder usage mismatch".
run_phase 13 "typed diagnostics (E157 Reason closure)"         diag.sh

# ---- Phase 14: layout algebra (E158) ----------------------------------------
# Also new here.  E158 splits a formatter into a TEMPLATE (`Doc`, six
# constructors, no `d-union`) and a FLATTEN (`doc->str`, at a width the caller
# chose), and gives E157's `Reason` a `dg-doc` sibling beside `dg-msg`.  Its
# gate is EVIDENCE SURVIVAL, never byte-identity: `dg-msg` keeps E157's nine
# goldens and `doc->str` must not inherit them, which is itself a checked row
# (G7).  8-12 are still names owed, so this is 14.
run_phase 14 "layout algebra (E158 Doc)"                       doc.sh

# ---- Phase 15: horizontal composition (E174) --------------------------------
# Also new here, and 15 for the reason 14 was 14: 8-12 are names still owed to
# unported old-tree phases, and reusing one would make an unported gate look
# ported.  E174 gives `Rendering` its first horizontal combinator -- but `r-row`
# is one arm and six lines of emitter, and the ELEMENT is `rnd-cols`, the
# per-node advance width that laying children left to right requires.  A width
# function is exactly the thing that looks right and is off by one, so no row in
# row.sh is a shape assertion: every one of them renders through
# `render-to-ansi` and reads the emitted byte stream back as a cell map.
run_phase 15 "horizontal composition (E174 r-row + rnd-cols)"  row.sh

# ---- Phase 16: the ambient face (E175) --------------------------------------
# 16 for the reason 15 was 15: 8-12 are names still owed to unported old-tree
# phases.  E175 makes a face survive its body -- the emitter opened a face as a
# DELTA and closed it as a full `\e[0m` REPLACEMENT, so a faced node's SIBLING
# lost the enclosing face.  The defect is NOT nesting and the fix is NOT a face
# stack in the `r-face` arm: the killing reset is `r-text`'s, and five of the
# six close sites are ad-hoc `ansi-bold` the registry does not know about.
#
# ⚑ Its gate needs BOTH kinds of row, and that is the interesting part.  The
# live consumers are SCREEN-identical but NOT byte-identical -- a close now
# restores the ambient, so the stream gains bytes while every painted cell
# stays put -- so G1-G4 grade a CELL MAP carrying the SGR register set.  But a
# trailing SGR paints no cell, so G5 and G6 grade RAW BYTES: under M7 the cell
# map is byte-for-byte identical while the stream gains 13.
run_phase 16 "ambient face restore (E175 face-join + rnd-restore)"  face.sh

# ---- Phase 17: doc->rendering (E158 commit 4) --------------------------------
# 17 for the reason 16 was 16.  E158's second exit: `Doc` does not unify with
# `Rendering`, it CONVERTS, and the rule is `d-tag` -> `r-face`.  It could not
# land before E174 (a rendered `Doc` line mixes a tagged span with untagged
# material and `Rendering` had no horizontal composition at all) or before E175
# (an inner face's close cleared the outer's attributes).
#
# ⚑ Its gate needs BOTH kinds of row for a reason the element itself supplies.
# The cheap conversion re-wraps every emitted LEAF in its whole tag stack --
# screen-correct, and MEASURED to produce an identical cell map on the pre-E175
# emitter, because no `r-face` in its output ever wraps more than one painted
# node.  The implementation builds the face TREE instead, so M4 (E175 reverted)
# actually convicts.  Every mutant here pins the FULL fifteen-row verdict line,
# not merely "a row went red".
run_phase 17 "doc->rendering (E158 commit 4)"                      render-doc.sh

# ---- Phase 18: the term printer (E181) --------------------------------------
# 18 for the reason 17 was 17: 8-12 are names still owed to unported old-tree
# phases.  E181 repoints the printer at the REAL sixteen-constructor `Term`,
# returns a `Doc` instead of a `Str`, and MOVES it to `surface/` -- a printer
# checks nothing, so `typing/` was never its role, and root-relative keys make
# that a real rename rather than a tidy-up.
#
# ⚑ Its gate reads EMITTED BYTES on every row.  The toothless shape for a
# printer is a row that walks the produced `Doc` and checks it has the
# constructors you expected -- the same information twice, and green under any
# mutant that changes what those constructors SAY.  It also carries the one row
# in the suite that COULD NOT PASS before its element landed: the old file was
# unimportable twice over (`data redeclared: Term`, `duplicate label ... nlen`),
# so nothing in the tree ever compiled it.
run_phase 18 "the term printer (E181 Term -> Doc)"                 pretty.sh

# ---- Phase 19: the total matcher (E173 slice 1) -----------------------------
# 19 for the reason 18 was 18: 8-12 are names still owed to unported old-tree
# phases.  `lib/text/matcher.chiral` is Antimirov partial derivatives with the
# live set bounded by a call to `norm`, and `prog/prose-lint.prog` is its first
# consumer.
#
# ⚑ Its mutant harness is NOT tools/test/mutant.sh.  That one asserts a mutated
# `prog/compiler.prog` blob DIFFERS, and G8 measures that `text/matcher` is
# outside that closure -- so every mutation of it would score INERT there.  A
# scratch `lib/` is the mechanism for a module outside the blob, as in Phase 17.
#
# ⚑ Its M3 is the mutant this tree cannot refuse.  A `pd` whose `p-star` arm
# does not rebuild the star does not terminate, and `chirality check` answers OK
# on it: `lib/typing/totality.chiral` is the built E11 classifier and nothing
# imports it (docs/definitions/status-ledger.md:157).  G10 therefore RUNS the
# mutant under a bounded stack and reads the divergence, with the base tree
# under the same limits as its control.
run_phase 19 "the total matcher (E173 pd + norm)"                  matcher.sh

echo
echo "=== not ported from the old suite (named, not hidden) ==="
echo "  Phase 8  module datasheet (E161)      -- 808 lines of fixtures on old-tree module keys; see tools/test/MIGRATION-NOTES.md"
echo "  Phase 9  sort adoption (E156)         -- fixtures ARE here now (tools/test/samples/e15{1,2,6}_*.prog, slice 8); the phase SCRIPT is not ported"
echo "  Phase 10 external-compiler C leg      -- DROPPED: external judgment cut by author decision"
echo "  Phase 11 resolver + build state       -- old basename-collision class is unreachable here; no committed blob artifact to cmp against"
echo "  Phase 12 the test floor (E168)        -- fixtures ARE here now (tools/test/samples/e168_*, e170_*, slice 8); the phase SCRIPT and its mutant machinery are not ported"

# The assertion count, summed from the phases that report one:
#   Phase 1 inline behavioral · Phases 3-6 + 13 sub-script tallies · Phase 7 roots.
# Phase 2's own checks are counted by the test-runner binary itself, which
# prints its rank and check count on its own line above and gates by exit code.
echo
echo "assertions: $((tot_pass + inline_pass)) passed, $((tot_fail + inline_fail)) failed"
echo "  (Phase 1 inline $inline_pass/$((inline_pass+inline_fail)) · Phases 3-6, 13 sub-script tallies: $tot_pass passed, $tot_fail failed)"
echo "  Phase 2: the test-runner reports its own checks above and gates by exit code."
echo "compile-only: $r_pass roots built, $r_fail failed -- gates, but asserts nothing"
echo "  A root that compiles has no expected value and no provenance rank.  It is"
echo "  reported here rather than added above so the assertion count means one thing."

echo
if [ "$fail" -eq 0 ]; then
  echo "chirality test: gate PASSED"
else
  echo "chirality test: gate FAILED ($fail failing check(s)/phase(s))"
fi
[ "$fail" -eq 0 ]
