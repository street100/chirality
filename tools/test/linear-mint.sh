#!/usr/bin/env bash
# test-linear-mint.sh -- E159: a linear capability is only ever tracked at q1.
#
# A `porttype` buys exactly one thing: its inhabitants are quantity-1, so the
# checker can prove a capability is discharged once -- never forged into two,
# never silently dropped. That guarantee is only as good as the places a linear
# value is allowed to come to rest. check_data already pinned one of them (a
# data FIELD holding a linear value must be declared q1: "linear field declared
# non-1"). Two more were open, and either one alone re-opens the whole class:
#
#   the LET binder.  `(let (f v) ...)` binds at omega by default (parse.chiral's
#     `(lbind 2 ...)`), and the usage audit `qfits` accepts any number of uses of
#     an omega binder. So `(let (f (adopt-fd 999)) (do (fd-close f) (fd-close f)))`
#     type-checked: a forged fd, closed twice, with no complaint.
#
#   the PI binder.  `(-> Fd Unit)` is an omega-quantified parameter of a linear
#     type. Same hole one level up: the body may use the cap any number of times.
#
#   the EXTERN arrow.  A linear result is a MINT. Declared `->` the mint claims
#     to be an ordinary pure function; the rule here is that minting a capability
#     IS a membrane crossing whatever the machine does afterwards, so the arrow
#     must be `=>`. (This one is declaration hygiene: it does not by itself stop
#     the duplication above -- the binder rules do that -- but it keeps the two
#     halves of the discipline from drifting apart.)
#
# SCOPE HONESTY. This is the TYPE-LEVEL discipline and nothing more. At rung 1 an
# Fd is a raw integer at runtime; nothing here stops machine code from closing
# that integer twice. Machine authority over a descriptor is E77 (seccomp).
#
# ⚑ THE MUTANTS THIS FILE'S COMMENTS CITE ARE NOW RUN BY THIS FILE, since
# 2026-09-05. records/gate-audit.md GA-07: sections E and F were re-founded on a
# mutation run, their comments quote a measured 2x2 diagonal and a measured q0
# arm, and every falsifier they name lived in tools/test/mutant.sh -- which no
# run_phase line dispatches (GA-01). The rows were genuinely falsifiable and the
# falsification was genuinely outside the gate. The block at the foot moves it
# inside.
#
# Zero Python. Zero golden captures: every expectation is what the form MEANS.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CHIR="$REPO/bin/chirality"
# CHIRALITY_COMPILE overrides both -- one exported variable must put a chosen compiler
# under the WHOLE suite, not just run-native.sh's own inline phases. E166's
# admission gate (G3) exports it; until 2026-08-25 this script ignored it and
# silently ran under B1 while the gate reported it as chirality-bin-c coverage. Same
# resolution order as run-native.sh -- keep the two in step.
CC="${CHIRALITY_COMPILE:-}"
if [ -z "$CC" ]; then
  for c in "$REPO/bin/chirality-bin"; do
    [ -x "$c" ] && { CC="$c"; break; }
  done
fi
[ -n "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }

SELF="${BASH_SOURCE[0]:-$0}"

pass=0; fail=0
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
ulimit -s unlimited

# ⚑ THE RED LOG. Every FAIL below appends its DESCRIPTION here. A mutant leg
# re-runs this whole file under a mutated compiler and reads THIS FILE to learn
# which rows went red, rather than parsing the printed FAIL lines: a refusal
# message can itself contain ` -- ` and a parse would drop the row, which is an
# under-count in the direction that reads as a pass. CHIRALITY_RED_LOG being set
# is also what tells the block at the foot it is inside a leg, so it does not
# recurse.
RED_LOG="${CHIRALITY_RED_LOG:-$T/reds}"
: >"$RED_LOG"

ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }
red() { echo "  FAIL  $1 -- $2"; printf '%s\n' "$1" >>"$RED_LOG"; fail=$((fail+1)); }

# ---- refuse <desc> <want-msg> <src> ------------------------------------------
# the source must be REFUSED at load time with a named message. Load errors are
# reported before any lowering, so these cases need no crossing rows and no
# imports: what is under test is the judgment, not the backend.
refuse() {
  local desc="$1" want_msg="$2" src="$3" out got
  out="$(printf '%s' "$src" | "$CC" 2>&1 >/dev/null)"; got=$?
  if [ "$got" = "0" ]; then
    red "$desc" "ACCEPTED (exit 0); it must be refused"; return
  fi
  if ! printf '%s' "$out" | grep -q -- "$want_msg"; then
    red "$desc" "refused, but not for this reason. want '$want_msg', got: $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"
    return
  fi
  ok "$desc"
}

# ---- admit <desc> <src> ------------------------------------------------------
# the source must PASS the load judgment. It may still fail later (these toy
# porttypes have no lowering rows), so the assertion is precisely "no load
# error" -- the judgment admitted it. Guarding on the `load:` prefix keeps the
# check honest: an admit that started failing at load would not be mistaken for
# a lowering failure.
admit() {
  local desc="$1" src="$2" out
  out="$(printf '%s' "$src" | "$CC" 2>&1 >/dev/null)"
  if printf '%s' "$out" | grep -q '^load:'; then
    red "$desc" "REFUSED at load: $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"
    return
  fi
  ok "$desc"
}

# ---- runs <desc> <want-exit> <src> -------------------------------------------
# a real program over the real `ports` registry, compiled through `chirality compile`
# (so imports resolve) and RUN. This is the end-to-end control: the discipline
# must still let a correct capability lifecycle through to machine code.
runs() {
  local desc="$1" want="$2" src="$3" n=$((pass+fail)) f out got rr
  f="$T/r$n.chiral"; printf '%s' "$src" > "$f"
  out="$(ORIG_DIR="$T" "$CHIR" compile "$f" -o "$T/r$n.elf" 2>&1)"; got=$?
  if [ "$got" != "0" ]; then
    red "$desc" "compile exit $got: $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"
    return
  fi
  "$T/r$n.elf" >/dev/null 2>&1; rr=$?
  if [ "$rr" != "$want" ]; then
    red "$desc" "program exit $rr, want $want"; return
  fi
  ok "$desc (program exit $rr)"
}

# a locally declared capability + its consumer: an opaque linear atom, and an
# indexed one beside it (the OTHER linear registry -- ldatas, not latoms -- which
# the rule must read too, or half the porttypes stay unprotected).
# `Unit` is prelude's, and these cases import nothing on purpose (a load error is
# reported before any import machinery matters), so declare it locally.
CAP='(data Unit () (unit))
(porttype Cap)
(extern burn (=> (1 c Cap) Unit))
'
ICAP='(porttype ICap (n I64))
'

echo
echo "=== E159 A: the extern arrow -- a linear result is a MINT, so it crosses ==="

refuse "opaque linear result behind a pure arrow" \
  "returns the linear Cap through a pure \`->\` arrow" \
  "${CAP}(extern mint (-> I64 Cap))
(def compile-main (-> I64 I64) (lam (n) 42))"

refuse "INDEXED linear result behind a pure arrow (the ldatas registry)" \
  "returns the linear ICap through a pure \`->\` arrow" \
  "${ICAP}(extern imint (-> (0 n I64) (ICap n)))
(def compile-main (-> I64 I64) (lam (n) 42))"

admit "the same mint declared \`=>\`" \
  "${CAP}(extern mint (=> I64 Cap))
(def compile-main (-> I64 I64) (lam (n) 42))"

# the judgment is over the whole Pi SPINE, not the outermost arrow: a curried
# mint may erase its q0 index purely and still cross where it matters. This is
# the shape lib/ports/pool.chiral's pool-write already has, so getting it wrong
# would have refused a committed declaration.
admit "curried mint: pure index arrow, crossing value arrow" \
  "${ICAP}(extern imint (-> (0 n I64) (=> I64 (ICap n))))
(def compile-main (-> I64 I64) (lam (n) 42))"

admit "a NON-linear result behind a pure arrow is untouched" \
  "${CAP}(extern measure (-> (1 c Cap) I64))
(def compile-main (-> I64 I64) (lam (n) 42))"

echo
echo "=== E159 B: the let binder -- a linear value binds at 1, or not at all ==="

refuse "let at omega (the default) holding a minted cap" \
  "let binds a linear value at quantity omega" \
  "${CAP}(extern mint (=> I64 Cap))
(def compile-main (=> I64 I64) (lam (n) (let (c (mint 9)) (case (burn c) (unit 42)))))"

refuse "the forge: omega let, burned TWICE" \
  "let binds a linear value at quantity omega" \
  "${CAP}(extern mint (=> I64 Cap))
(def compile-main (=> I64 I64) (lam (n) (let (c (mint 9)) (case (burn c) (unit (case (burn c) (unit 42)))))))"

refuse "the leak: omega let, never burned" \
  "let binds a linear value at quantity omega" \
  "${CAP}(extern mint (=> I64 Cap))
(def compile-main (=> I64 I64) (lam (n) (let (c (mint 9)) 42)))"

# the value is a variable, so the erased seat is pure and the membrane (E171
# rule 2) stays silent; the binder rule is the only one left to report.
refuse "let at ZERO -- erased without ever being discharged" \
  "let binds a linear value at quantity 0" \
  "${CAP}(extern mint (=> I64 Cap))
(def f (=> (1 c Cap) I64) (lam (c) (let ((0 d c)) 42)))
(def compile-main (=> I64 I64) (lam (n) (f (mint 9))))"

admit "let at 1, burned once -- the correct lifecycle" \
  "${CAP}(extern mint (=> I64 Cap))
(def compile-main (=> I64 I64) (lam (n) (let ((1 c (mint 9))) (case (burn c) (unit 42)))))"

# the pre-existing q1 audit must survive the new rule -- it is what turns
# "bound at 1" into "used exactly once". These two are the controls that prove
# the new rule did not simply replace the old one.
refuse "q1 let, burned twice -- the usage audit still fires" \
  "let binder usage mismatch" \
  "${CAP}(extern mint (=> I64 Cap))
(def compile-main (=> I64 I64) (lam (n) (let ((1 c (mint 9))) (case (burn c) (unit (case (burn c) (unit 42)))))))"

refuse "q1 let, never burned -- the leak audit still fires" \
  "let binder usage mismatch" \
  "${CAP}(extern mint (=> I64 Cap))
(def compile-main (=> I64 I64) (lam (n) (let ((1 c (mint 9))) 42)))"

admit "a NON-linear value at omega is untouched" \
  "(def compile-main (-> I64 I64) (lam (n) (let (x 42) x)))"

echo
echo "=== E159 C: the pi binder -- an omega parameter of a linear type ==="

refuse "function parameter of a linear type at omega" \
  "function parameter of a linear type at quantity omega" \
  "${CAP}(def sink (=> Cap I64) (lam (c) (case (burn c) (unit 42))))
(def compile-main (-> I64 I64) (lam (n) 42))"

refuse "function parameter of an INDEXED linear type at omega" \
  "function parameter of a linear type at quantity omega" \
  "${ICAP}(declare isink (-> (0 n I64) (-> (ICap n) I64)))
(def compile-main (-> I64 I64) (lam (n) 42))"

refuse "function parameter of a linear type at ZERO" \
  "function parameter of a linear type at quantity 0" \
  "${CAP}(declare sink (=> (0 c Cap) I64))
(def compile-main (-> I64 I64) (lam (n) 42))"

admit "the same parameter declared (1 c Cap)" \
  "${CAP}(def sink (=> (1 c Cap) I64) (lam (c) (case (burn c) (unit 42))))
(def compile-main (-> I64 I64) (lam (n) 42))"

refuse "(1 c Cap) used twice -- the binder audit still fires" \
  "linear binder usage mismatch" \
  "${CAP}(def sink (=> (1 c Cap) I64) (lam (c) (case (burn c) (unit (case (burn c) (unit 42))))))
(def compile-main (-> I64 I64) (lam (n) 42))"

admit "a NON-linear parameter at omega is untouched" \
  "(def id2 (-> I64 I64) (lam (x) x))
(def compile-main (-> I64 I64) (lam (n) (id2 42)))"

echo
echo "=== E159 D: the real registry, end to end (ports/fd, adopt + close) ==="

# the committed lifecycle from lib/ports/fd.chiral: mint a cap from a raw fd,
# discharge it exactly once, reach machine code. If the discipline were merely
# strict rather than correct, this is what would stop working.
runs "adopt-fd at q1, closed once, runs" 42 \
  '(import "ports/ports")
(def compile-main (=> Unit I64)
  (lam (u) (let ((1 f (adopt-fd 1))) (do (fd-close f) 42))))'

runs "adopt-fd twice: two separate caps, each discharged once" 42 \
  '(import "ports/ports")
(def compile-main (=> Unit I64)
  (lam (u) (let ((1 a (adopt-fd 1)))
             (let ((1 b (adopt-fd 2)))
               (do (fd-close a) (do (fd-close b) 42))))))'

echo
echo "=== E159 E: the case merge -- divergent linear use across arms saturates ==="
# The fourth place a linear value comes to rest, and the one this file did not
# cover until 2026-08-31. A `case` computes a usage vector per arm and MERGES
# them with `qjoin` (typing/qtt.chiral:30-36): using a cap in one arm and not the
# other is neither "used once" nor "unused", so the merge saturates to omega and
# the binder audit then refuses it against a declared 1. Without that saturation
# a capability is discharged on one branch and leaked on the other, and the
# program type-checks.
#
# ⚑ FOUND BY MUTATION, NOT BY READING. `tools/test/mutant.sh`'s matrix ran a
# mutant that stops the merge saturating, and it SURVIVED ALL FIVE PHASE
# SCRIPTS -- the rule had no coverage anywhere in the suite. These rows are the
# re-founding, and the run that produced them is what says they are needed.
#
# ⚑ TWO MUTANTS, NOT ONE, AND THAT IS THE POINT OF THE MIRROR ROW. `qjoin` is a
# table with two independent non-trivial arms, `qjoin q1 q0` and `qjoin q0 q1`,
# and a mutant weakening one leaves the other saturating. Measured: with the q1
# arm weakened E1 and E6 go red and E2 stays GREEN; with the q0 arm weakened E2
# goes red and E1 and E6 stay green. A clean 2x2 diagonal, so neither row is
# redundant and neither mutant alone establishes the rule. The mirror row exists
# because arm order is not a symmetry the table gives you for free.
#
# The controls ship beside the refusals because a refusal check has a way to
# pass vacuously that an outcome lock does not: refuse everything. E3 and E5 are
# the direction controls, and both are ADMITTED by the real compiler.
#
# ⚑ AND THE MESSAGE GUARD IS WHAT CONVICTS, NOT THE EXIT CODE. Under the q1-arm
# mutant E1 is ADMITTED BY THE JUDGMENT and then dies later at lowering, because
# these toy porttypes have no lowering rows -- so the compiler still exits
# non-zero and a refusal check reading only the exit status would score it
# GREEN. `refuse` greps the reason, and that is the only thing standing between
# this row and a mutant it cannot see. It is the same shape as the `admit`
# helper's `load:` guard, from the other side.

refuse "case merge: a q1 cap burned in ONE arm only" \
  "let binder usage mismatch" \
  "${CAP}(extern mint (=> I64 Cap))
(data B () (bt) (bf))
(def compile-main (=> I64 I64)
  (lam (n) (let ((1 c (mint 9)))
    (case (bt) ((bt) (case (burn c) ((unit) 42))) ((bf) 0)))))"

refuse "case merge: the MIRROR, burned in the other arm" \
  "let binder usage mismatch" \
  "${CAP}(extern mint (=> I64 Cap))
(data B () (bt) (bf))
(def compile-main (=> I64 I64)
  (lam (n) (let ((1 c (mint 9)))
    (case (bt) ((bt) 0) ((bf) (case (burn c) ((unit) 42)))))))"

admit "case merge: burned in BOTH arms -- the correct lifecycle" \
  "${CAP}(extern mint (=> I64 Cap))
(data B () (bt) (bf))
(def compile-main (=> I64 I64)
  (lam (n) (let ((1 c (mint 9)))
    (case (bt) ((bt) (case (burn c) ((unit) 42))) ((bf) (case (burn c) ((unit) 7)))))))"

# Refused by the LEAK half of the same audit rather than by saturation: both
# arms compute q0, so the merge is q0 and it is the declared 1 that rejects it.
# It is a control on the row above, not a second saturation case, and both
# qjoin mutants leave it red -- which is exactly why it cannot stand in for E1.
refuse "case merge: burned in NEITHER arm (the leak half)" \
  "let binder usage mismatch" \
  "${CAP}(extern mint (=> I64 Cap))
(data B () (bt) (bf))
(def compile-main (=> I64 I64)
  (lam (n) (let ((1 c (mint 9))) (case (bt) ((bt) 0) ((bf) 1)))))"

admit "case merge: a NON-linear value in one arm only is untouched" \
  "${CAP}(data B () (bt) (bf))
(def compile-main (=> I64 I64)
  (lam (n) (let ((v 5)) (case (bt) ((bt) v) ((bf) 0)))))"

# The same merge one binder up: the cap arrives as a q1 PARAMETER, so the audit
# is strip-binder rather than close-binder and the message differs. Under the
# q1-arm mutant this one is admitted with no diagnostic at all.
refuse "case merge across a pi binder: (1 c Cap) in one arm" \
  "linear binder usage mismatch" \
  "${CAP}(data B () (bt) (bf))
(def sink (=> (1 c Cap) I64)
  (lam (c) (case (bt) ((bt) (case (burn c) ((unit) 42))) ((bf) 0))))
(def compile-main (=> I64 I64) (lam (n) 0))"

echo
echo "=== E159 F: the ERASED binder -- quantity 0 means zero uses, and is checked ==="
# `qfits`'s q0 arm (typing/qtt.chiral:44): a binder declared at quantity 0 is erased,
# so any use of it is a mismatch. Section B already has two rows with ZERO in the name
# and they do NOT reach this arm: their values are linear `porttype`s, refused earlier
# by a dedicated "let binds a linear value at quantity 0" check that fires before
# `qfits` is consulted. They read as q0 coverage and are not.
#
# ⚑ MEASURED, NOT REASONED. tools/test/mutant.sh's `qfits-q0-accepts-all` weakens
# exactly this arm. Before these rows it was convicted by ONE phase in the whole
# suite, diag.sh, and only incidentally: an `e157_diag` case happens to trip over it,
# so the erased-quantity discipline was resting on a fixture about diagnostics.
#
# The values here are plain `I64` on purpose. A non-linear type is what routes the
# judgment past the linear pre-check and into `qfits` itself, which is the whole
# reason these rows exist and section B's do not serve.
#
# Three arrivals at the arm, because `qfits` is asked a different question by each:
# used once is qfits(q1,q0), used twice is qfits(qw,q0), and the pi binder reaches it
# through strip-binder rather than close-binder and so carries a different message.

refuse "erased let: (0 x 5) used once" \
  "let binder usage mismatch" \
  '(def compile-main (-> I64 I64) (lam (n) (let ((0 x 5)) x)))'

refuse "erased let: (0 x 5) used TWICE" \
  "let binder usage mismatch" \
  '(def pick (-> I64 I64 I64) (lam (a b) a))
(def compile-main (-> I64 I64) (lam (n) (let ((0 x 5)) (pick x x))))'

refuse "erased pi param: (0 n I64) used in the body" \
  "linear binder usage mismatch" \
  '(def f (-> (0 n I64) I64) (lam (n) n))
(def compile-main (-> I64 I64) (lam (m) (f 3)))'

# The direction controls. Erasure must ADMIT the zero-use cases, or the three rows
# above are satisfied by a checker that refuses every q0 binder outright.
admit "erased let: (0 x 5) never used -- erasure works" \
  '(def compile-main (-> I64 I64) (lam (n) (let ((0 x 5)) 7)))'

admit "erased pi param: (0 n I64) never used -- erasure works" \
  '(def f (-> (0 n I64) I64) (lam (n) 7))
(def compile-main (-> I64 I64) (lam (m) (f 3)))'

# ============================================================================
# THE MUTANTS. records/gate-audit.md GA-07.
#
# ⚑ WHAT WAS BROKEN. Nothing about the rows: they are falsifiable and the
# falsifiers are correct. What was broken is WHERE the falsification happened.
# `:271-275` records that a mutant SURVIVED ALL FIVE PHASE SCRIPTS and that
# these rows are the re-founding; `:277-284` names the two qjoin arms and the
# 2x2 diagonal; `:354-357` names qfits-q0-accepts-all. Every one of those measurements
# was taken by tools/test/mutant.sh --matrix, which a person runs by hand. A row
# whose evidence is produced by hand is a row the gate does not hold.
#
# ⚑ THE SHAPE. A mutant leg re-runs THIS WHOLE FILE under the mutated compiler
# and reads the red log, so the want is graded by the same `refuse` and `admit`
# that emitted the base rows (GA-18). Every mutant pins the FULL red set, one
# description per line, so a mutant reddening a row outside its pin is a FAIL
# rather than a miss (GA-22). A mutant that did not build scores BUILD:fail,
# which no pin holds (GA-19); one byte-identical to the base scores INERT. The
# base red set is asserted EMPTY first.
#
# ⚑ THE DIAGONAL IS THE PIN, not a sentence beside it. M1's pin holds E1 and E6
# and NOT E2; M2's holds E2 and neither E1 nor E6. That is the 2x2 `:277-284`
# describes, and it is now a comparison the phase makes rather than a claim the
# comment makes.
#
# ⚑ WHAT IS STILL UNCOVERED. Sections A, B and C, and the two `runs` controls,
# are reddened by nothing here: twenty-two of the thirty-two rows. M4 and M5
# reach four of them and the rest want mutants of the extern-arrow and
# porttype-registry rules, which no declared mutant touches. GA-07's claim is
# about the rows whose comments cite a mutant, and those are E, F and the two
# binder-audit rows M4 and M5 land on. The residue is named, not closed.
if [ -z "${CHIRALITY_RED_LOG:-}" ] && [ -z "${CHIRALITY_NO_MUTANTS:-}" ]; then
  echo
  echo "=== E159 M: the mutants -- each pins the FULL set of rows it reddens ==="
  if [ ! -s "$RED_LOG" ]; then
    ok "the base red set is EMPTY -- no mutant below is scored against a red base"
  else
    bad "the base is ALREADY RED; every mutant below would score as convicted:"
    sed 's/^/          /' "$RED_LOG"
  fi

  export CHIRALITY_MUTANT_DIR="$T/mut"
  export CHIRALITY_MUTANT_BASE="$CC"
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

  # M1 -- the q1 arm of qjoin stops saturating. E1 and E6 red, E2 GREEN.
  mut_row qjoin-q1-no-saturate lib/typing/qtt.chiral 1 \
    '((q1) (case b ((q0) (qw)) ((q1) (q1)) ((qw) (qw))))' \
    '((q1) (case b ((q0) (q1)) ((q1) (q1)) ((qw) (qw))))' \
    'case merge: a q1 cap burned in ONE arm only
case merge across a pi binder: (1 c Cap) in one arm'

  # M2 -- the mirror arm. E2 red, E1 and E6 GREEN. The other half of the 2x2.
  mut_row qjoin-q0-no-saturate lib/typing/qtt.chiral 1 \
    '((q0) (case b ((q0) (q0)) ((q1) (qw)) ((qw) (qw))))' \
    '((q0) (case b ((q0) (q0)) ((q1) (q1)) ((qw) (qw))))' \
    'case merge: the MIRROR, burned in the other arm'

  # M3 -- an erased binder admits any usage. Section F, all three arrivals.
  mut_row qfits-q0-accepts-all lib/typing/qtt.chiral 1 \
    '((q0) (case computed ((q0) true) ((q1) false) ((qw) false)))' \
    '((q0) true)' \
    'erased let: (0 x 5) used once
erased let: (0 x 5) used TWICE
erased pi param: (0 n I64) used in the body'

  # M4 -- the lam/pi binder usage audit never fires. Reaches sections C and E
  # and F through the strip-binder side, which is the side whose message differs.
  mut_row strip-binder-off lib/typing/kernel.chiral 1 \
    '(false (ck-err (r-usage (subj-lam-binder) q (last-qty u))))' \
    '(false (ck-ok (drop-last u)))' \
    '(1 c Cap) used twice -- the binder audit still fires
case merge across a pi binder: (1 c Cap) in one arm
erased pi param: (0 n I64) used in the body'

  # M5 -- the let binder usage audit never fires. The close-binder side, and the
  # only falsifier the two section-D let rows and the leak-half control have.
  mut_row close-binder-off lib/typing/kernel.chiral 1 \
    '(false (ck-err (r-usage (subj-let-binder) q (last-qty ub))))' \
    '(false (ck-ok (uadd (drop-last ub) (uscale q uv))))' \
    'q1 let, burned twice -- the usage audit still fires
q1 let, never burned -- the leak audit still fires
case merge: a q1 cap burned in ONE arm only
case merge: the MIRROR, burned in the other arm
case merge: burned in NEITHER arm (the leak half)
erased let: (0 x 5) used once
erased let: (0 x 5) used TWICE'
fi

echo
echo "linear mint (E159): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
