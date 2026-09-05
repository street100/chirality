#!/usr/bin/env bash
# test-check-cli.sh -- H5: `chirality check` is the NATIVE compiler, not Python.
#
# `bin/chirality check` used to be `python3 -m chirality check`. It is now: resolve the
# file's imports with the shell source provider, compile the unit with B1, throw
# the ELF away, report the compiler's own message. These cases pin that it
# ACCEPTS well-typed source and REFUSES ill-typed source with a non-zero exit --
# a checker that only ever says OK is not a checker.
#
# ⚑ ALL SEVEN ROWS CARRY A NAMED MUTANT THAT IS RUN, since 2026-09-05. Until
# then this script declared none: records/gate-audit.md GA-05 measured two of
# the seven as reachable by any falsifier anywhere in the tree, and both of
# those falsifiers lived in tools/test/mutant.sh, which no run_phase line
# dispatches (GA-01). The block at the foot is that hole closed.
#
# Zero Python. Zero golden captures: every expectation is what the program MEANS.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CHIR="$REPO/bin/chirality"
SELF="${BASH_SOURCE[0]:-$0}"

pass=0; fail=0
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT

# ⚑ THE RED LOG. Every FAIL below appends its DESCRIPTION here. A mutant leg
# re-runs this whole file under a mutated compiler and reads THIS FILE to learn
# which rows went red, rather than parsing the printed FAIL lines: a compiler
# message can itself contain ` -- `, and a parse would drop the row, which is an
# under-count in the direction that reads as a pass. CHIRALITY_RED_LOG being set
# is also what tells the block at the foot it is inside a leg, so it does not
# recurse.
RED_LOG="${CHIRALITY_RED_LOG:-$T/reds}"
: >"$RED_LOG"

ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }
red() { echo "  FAIL  $1 -- $2"; printf '%s\n' "$1" >>"$RED_LOG"; fail=$((fail+1)); }

# check <desc> <want-exit> <want-substring-or-empty> <source>
check() {
  local desc="$1" want="$2" want_msg="$3" src="$4"
  local f="$T/case$((pass+fail)).chiral" out
  printf '%s' "$src" > "$f"
  out="$(ORIG_DIR="$T" "$CHIR" check "$f" 2>&1)"; local got=$?
  if [ "$got" != "$want" ]; then
    red "$desc" "exit $got, want $want: $(printf '%s' "$out" | tr '\n' ' ')"; return
  fi
  if [ -n "$want_msg" ] && ! printf '%s' "$out" | grep -q -- "$want_msg"; then
    red "$desc" "exit $got ok but message lacks '$want_msg': $(printf '%s' "$out" | tr '\n' ' ')"; return
  fi
  echo "  ok    $desc (exit $got)"; pass=$((pass+1))
}

echo
echo "=== H5: chirality check runs the native compiler (zero Python) ==="

# ---- POSITIVE: well-typed source checks clean ------------------------------
check "well-typed, no imports"          0 "OK" \
  '(def helper (-> I64 I64) (lam (x) x))'
check "well-typed, no entry def"        0 "OK" \
  '(def a (-> I64 I64) (lam (x) x)) (def b (-> I64 I64) (lam (x) (a x)))'
check "well-typed, imports resolved"    0 "OK" \
  '(import "ports/ports")
(def close-once (=> (1 f Fd) Unit) (lam (f) (fd-close f)))'

# ---- NEGATIVE: each refusal is non-zero AND named --------------------------
check "linear cap used twice"           1 "linear binder usage mismatch" \
  '(import "ports/ports")
(def double-close (=> (1 f Fd) Unit)
  (lam (f) (let (_ (fd-close f)) (fd-close f))))'
check "linear cap dropped"              1 "linear binder usage mismatch" \
  '(import "ports/ports")
(def drop-it (=> (1 f Fd) I64) (lam (f) 0))'
check "arity / type mismatch"           1 "type mismatch" \
  '(def f (-> I64 I64 I64) (lam (n) n))'
check "unknown name"                    1 "unknown name" \
  '(def f (-> I64 I64) (lam (n) (no-such-fn n)))'

# ============================================================================
# THE MUTANTS. records/gate-audit.md GA-05.
#
# ⚑ WHAT WAS BROKEN. Two of the seven rows had a falsifier and five had none,
# and the two that had one were reddened by mutants declared in
# tools/test/mutant.sh -- a file no run_phase line dispatches, so the evidence
# for those two rows was produced by hand and never by the gate.
#
# ⚑ THE SHAPE. A mutant leg re-runs THIS WHOLE FILE under the mutated compiler
# and reads the red log, so the want is graded by the same `check` that emitted
# the base rows (GA-18). Every mutant pins the FULL red set (GA-22). A mutant
# that did not build scores BUILD:fail, which no pin holds (GA-19); one that is
# byte-identical to the base scores INERT. The base red set is asserted EMPTY
# before any mutation.
#
# ⚑ WHICH HALF OF A ROW EACH MUTANT CONVICTS, because the two halves are not
# the same claim. `:68` says each refusal is non-zero AND NAMED. M1 convicts the
# non-zero half of the two linear refusals: under it the ill-typed source is
# ADMITTED. M3 and M4 convict the NAMED half of the other two: the source is
# still refused, with the wrong reason. A mutant that makes the checker admit an
# arity mismatch or an unbound name is not declared here, so the non-zero half
# of those two rows is still reddened by nothing, and that is said rather than
# rounded up.
if [ -z "${CHIRALITY_RED_LOG:-}" ] && [ -z "${CHIRALITY_NO_MUTANTS:-}" ]; then
  echo
  echo "=== H5 M: the mutants -- each pins the FULL set of rows it reddens ==="
  if [ ! -s "$RED_LOG" ]; then
    ok "the base red set is EMPTY -- no mutant below is scored against a red base"
  else
    bad "the base is ALREADY RED; every mutant below would score as convicted:"
    sed 's/^/          /' "$RED_LOG"
  fi

  export CHIRALITY_MUTANT_DIR="$T/mut"
  export CHIRALITY_MUTANT_BASE="${CHIRALITY_COMPILE:-$REPO/bin/chirality-bin}"
  mkdir -p "$CHIRALITY_MUTANT_DIR"
  # shellcheck disable=SC1090
  . "$HERE/mutant.sh"

  # leg LABEL CC -> the description of every row that goes red under CC
  leg() {
    local log="$CHIRALITY_MUTANT_DIR/red-$1" out="$CHIRALITY_MUTANT_DIR/out-$1"
    : >"$log"
    CHIRALITY_RED_LOG="$log" CHIRALITY_COMPILE="$2" bash "$SELF" >"$out" 2>&1
    grep -q " passed, " "$out" || { echo "LEG-DID-NOT-FINISH"; return; }
    cat "$log"
  }

  # mut_row LABEL FILE COUNT OLD NEW WANT-RED-SET
  mut_row() {
    local label="$1" rel="$2" n="$3" old="$4" new="$5" want="$6" cc got
    cc="$(mutant_build "$label" "$rel" "$n" "$old" "$new")"
    case "$cc" in
      FAIL:*) bad "$label BUILD:fail ($cc) -- an unbuilt mutant convicts nothing"; return;;
    esac
    mutant_differs "$cc" || { bad "$label INERT -- byte-identical to the base"; return; }
    got="$(leg "$label" "$cc")"
    if [ "$got" = "$want" ]; then
      ok "$label reddens exactly [$(printf '%s' "$got" | tr '\n' '|')]"
    else
      bad "$label red set disagrees
          want [$(printf '%s' "$want" | tr '\n' '|')]
          got  [$(printf '%s' "$got" | tr '\n' '|')]"
    fi
  }

  # M1 -- a q1 declaration admits any usage. Declared in mutant.sh and run there
  # by hand until today; the row it convicts is here, so it runs here.
  mut_row qfits-q1-accepts-all lib/typing/qtt.chiral 1 \
    '((q1) (case computed ((q1) true) ((q0) false) ((qw) false)))' \
    '((q1) true)' \
    'linear cap used twice
linear cap dropped'

  # M2 -- the mirror, and the only falsifier the three POSITIVE rows have: an
  # omega declaration stops admitting anything, so well-typed source is refused
  # and a checker that only ever says OK is not the failure this catches -- it
  # is the opposite one, a checker that never says OK.
  mut_row qfits-refuses-all lib/typing/qtt.chiral 1 \
    '((qw) true)' \
    '((qw) false)' \
    'well-typed, no imports
well-typed, no entry def
well-typed, imports resolved'

  # M3 -- the mismatch sentence is renamed. The source is still refused; the
  # row's NAMED half is what goes red.
  mut_row mismatch-msg-renamed lib/typing/diag.chiral 1 \
    '(def dg-mismatch-msg (lam (w) "type mismatch"))' \
    '(def dg-mismatch-msg (lam (w) "types disagree"))' \
    'arity / type mismatch'

  # M4 -- the same, one refusal over, at the name resolver's own sentence.
  mut_row unknown-name-renamed lib/surface/surface.chiral 1 \
    '(str-cat "unknown name " name)' \
    '(str-cat "no such thing " name)' \
    'unknown name'
fi

echo
echo "chirality check CLI: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
