#!/usr/bin/env bash
# test-profile-target.sh -- H6: the composition manifest is parsed by the NATIVE
# front end (lib/parse.chiral), not by the retired Python oracle.
#
#   (target  name (require dname ty) ...)
#   (profile name (ports p...) (target t) [(memory d)] [(total)])
#
# A profile is an ADDITIVE MANIFEST over a FROZEN PORT SET. The point of these
# cases is the REFUSALS: a parser that accepts everything freezes nothing. Every
# rejection reason surface.py's top_profile/top_target names has its own case
# here, and each must come back with its own distinct message.
#
# ⚑ EVERY ROW HERE CARRIES A NAMED MUTANT THAT IS RUN, since 2026-09-05, or it
# is named at the foot of this file as a row that does not. Until then this
# script declared ZERO mutants: records/gate-audit.md GA-04 measured one of its
# thirty-one rows as reachable by any falsifier anywhere in the tree, and GA-03
# measured the consequence -- the `(total)` clause could be made DEAD, with the
# clause still parsing and still validating, and no phase in the suite noticed.
# The mutant block at the foot is that hole closed for the rows it names, and
# GA-04's residue is named there too rather than left to be rediscovered.
#
# Zero Python. Zero golden captures: every expectation is what the form MEANS.
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

# the shared preamble every profile case builds on: one linear port atom, one
# extern that CROSSES it, one extern that is PURE, and one declared target.
HDR='(porttype Cap)
(extern cap-use (=> (1 c Cap) I64))
(extern pure-add (-> I64 I64))
(target Svc (require run (-> I64 I64)))
'

echo
echo "=== H6: (target ...) / (profile ...) on the native front end ==="

# ---- POSITIVE: a well-formed manifest parses, elaborates and stores ---------
check "target with one requirement"       0 "OK" \
  '(target Svc (require run (-> I64 I64)))'
check "target with several requirements"  0 "OK" \
  '(target Svc (require run (-> I64 I64)) (require size I64) (require label Str))'
check "profile: ports + target"           0 "OK" \
  "$HDR(profile P (ports cap-use) (target Svc))"
check "profile: + memory linear"          0 "OK" \
  "$HDR(profile P (ports cap-use) (target Svc) (memory linear))"
check "profile: + memory region + total"  0 "OK" \
  "$HDR(profile P (ports cap-use) (target Svc) (memory region) (total))"
check "profile: clause order is free"     0 "OK" \
  "$HDR(profile P (total) (memory linear) (target Svc) (ports cap-use))"
check "profile: empty port set"           0 "OK" \
  "$HDR(profile P (ports) (target Svc))"
check "two profiles over one target"      0 "OK" \
  "$HDR(profile P (ports cap-use) (target Svc))
(profile Q (ports) (target Svc) (total))"
check "manifest beside real definitions"  0 "OK" \
  "$HDR(profile P (ports cap-use) (target Svc) (memory linear))
(def compile-main (-> I64 I64) (lam (n) 42))"

# ---- the (total) clause MEANS something ------------------------------------
# ⚑ records/gate-audit.md GA-03. Every other row that carries `(total)` asserts
# that the clause PARSES and nothing more. A mutant that parses it, validates
# it and stores a DEAD flag -- `total-clause-dead` at the foot of this file --
# leaves all of them green, and GA-03 measured it surviving all five phases
# tools/test/mutant.sh names. lib/surface/parse.chiral:984 hands the flag to
# mk-profile, lib/typing/totality-check.chiral:157 reads it in tot-gate, and
# lib/lowering/compile-front.chiral:340 calls tot-gate on the shipping path.
# These three rows are that path, from both directions: the demand REFUSES an
# unproven def, ADMITS a proven one, and is not made by a profile that does not
# carry the clause. Prefixed `pt-` for the reason tools/test/arity.sh:40 gives:
# three censuses grep `lib prog tools` for `^\((def|data|declare) <name>`, and
# a line-anchored grep cannot tell a bash string from a program.
check "(total): an unproven def is REFUSED" 1 "profile (total): def pt-loop not proven total" \
  '(target Svc (require run (-> I64 I64)))
  (profile P (ports) (target Svc) (total))
  (declare pt-loop (-> I64 I64))
  (def pt-loop (lam (n) (pt-loop n)))'
check "(total): a proven def is ADMITTED" 0 "OK" \
  '(target Svc (require run (-> I64 I64)))
  (profile P (ports) (target Svc) (total))
  (data PtL () (pt-nil) (pt-cons (h I64) (t PtL)))
  (declare pt-last (-> PtL I64))
  (def pt-last (lam (l) (case l ((pt-nil) 0) ((pt-cons h t) (pt-last t)))))'
check "no (total): the same unproven def is ADMITTED" 0 "OK" \
  '(target Svc (require run (-> I64 I64)))
  (profile P (ports) (target Svc))
  (declare pt-loop (-> I64 I64))
  (def pt-loop (lam (n) (pt-loop n)))'

# ---- NEGATIVE, one case per rejection reason in surface.py ------------------
# top_profile
check "profile redeclared"                1 "profile P redeclared" \
  "$HDR(profile P (ports cap-use) (target Svc))
(profile P (ports) (target Svc))"
check "port is not a declared extern"     1 "profile port nope is not a declared extern" \
  "$HDR(profile P (ports nope) (target Svc))"
check "port is a data type, not extern"   1 "profile port Cap is not a declared extern" \
  "$HDR(profile P (ports Cap) (target Svc))"
check "port is PURE (does not cross)"     1 "profile port pure-add is pure; only crossings belong in the port set" \
  "$HDR(profile P (ports pure-add) (target Svc))"
check "missing (ports ...)"               1 "profile needs (ports p...)" \
  "$HDR(profile P (target Svc) (memory linear))"
check "missing (target ...)"              1 "profile needs (target name)" \
  "$HDR(profile P (ports cap-use) (memory linear))"
check "malformed (target)"                1 "profile needs (target name)" \
  "$HDR(profile P (ports cap-use) (target))"
check "unknown target name"               1 "profile P names unknown target Nope" \
  "$HDR(profile P (ports cap-use) (target Nope))"
check "unknown memory discipline"         1 "unknown memory discipline gc (have linear, region)" \
  "$HDR(profile P (ports cap-use) (target Svc) (memory gc))"
check "malformed (memory)"                1 "profile memory clause is (memory discipline)" \
  "$HDR(profile P (ports cap-use) (target Svc) (memory))"
check "unknown profile clause"            1 "unknown profile clause mystery" \
  "$HDR(profile P (ports cap-use) (target Svc) (mystery x))"
check "(total) takes no arguments"        1 "profile total clause is a bare (total)" \
  "$HDR(profile P (ports cap-use) (target Svc) (total yes))"
check "profile clause is not a form"      1 "bad profile clause" \
  "$HDR(profile P (ports cap-use) Svc)"
check "profile with one clause"           1 "(profile name (ports p...) (target t)" \
  "$HDR(profile P (ports cap-use))"
check "profile name is not a symbol"      1 "(profile name (ports p...) (target t)" \
  "$HDR(profile (P) (ports cap-use) (target Svc))"

# top_target
check "target redeclared"                 1 "target Svc redeclared" \
  "$HDR(target Svc (require run (-> I64 I64)))"
check "target with no requirements"       1 "(target name (require dname ty) ...)" \
  '(target Svc)'
check "target name is not a symbol"       1 "(target name (require dname ty) ...)" \
  '(target (Svc) (require run (-> I64 I64)))'
check "requirement is malformed"          1 "bad requirement (want (require name ty))" \
  '(target Svc (require run))'
check "requirement head is not require"   1 "bad requirement (want (require name ty))" \
  '(target Svc (provide run (-> I64 I64)))'
check "requirement type is not a type"    1 "requirement run of target Svc is not a type" \
  '(target Svc (require run 42))'
check "requirement type does not resolve" 1 "unknown name" \
  '(target Svc (require run (-> Nope I64)))'

# ============================================================================
# THE MUTANTS. records/gate-audit.md GA-03 and GA-04.
#
# ⚑ WHAT WAS BROKEN. This script declared no mutant, no poison and no scratch
# tree. Exactly ONE of its thirty-one rows was reddened by anything anywhere in
# the tree -- `port is PURE`, by `port-purity-off`, declared in mutant.sh and
# run by a driver run-tests.sh does not dispatch. Thirty rows had no falsifier
# at all, and GA-03 is one measured consequence of that: the `(total)` clause
# could be emptied of meaning with every row still green.
#
# ⚑ THE SHAPE. A mutant leg re-runs THIS WHOLE FILE under the mutated compiler
# and reads the red log, so the want is graded by the same `check` that emitted
# the base rows and cannot be re-derived somewhere a mutation does not reach
# (GA-18). Every mutant pins the FULL red set, one description per line, so a
# mutant reddening a row outside its pin is a FAIL rather than a miss (GA-22).
# A mutant that did not build scores BUILD:fail, which no pin holds, so it can
# never wear a red row (GA-19); a mutant byte-identical to the base scores
# INERT. The base red set is asserted EMPTY first, because a phase already red
# convicts every mutant it is shown.
#
# ⚑ WHAT IS STILL UNCOVERED, named rather than left to be rediscovered.
# M3 is a COARSE mutant. It reddens twenty-three of the thirty-four rows at
# once, and what that establishes is that those rows RUN and that the manifest
# path is load-bearing -- not that each row's own message is the thing holding
# it up. M1 and M2 are the discriminating ones and each reddens exactly one row.
# ELEVEN ROWS ARE REDDENED BY NOTHING HERE: `target with one requirement`,
# `target with several requirements`, `profile with one clause`, `profile name
# is not a symbol`, and the seven `top_target` refusals. Each wants its own
# message-rename mutant and its own compiler build, about eleven more builds on
# a phase that cost two seconds before this block. That is GA-04's residue,
# measured, and the row stays open on it.
if [ -z "${CHIRALITY_RED_LOG:-}" ] && [ -z "${CHIRALITY_NO_MUTANTS:-}" ]; then
  echo
  echo "=== H6 M: the mutants -- each pins the FULL set of rows it reddens ==="
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

  # M1 -- the one falsifier this script already had, now RUN by the phase that
  # owns the row rather than by a driver nothing dispatches.
  mut_row port-purity-off lib/surface/parse.chiral 1 \
    '(false (mf-bad (mf-port-pure pn)))' \
    '(false (case (mf-check-ports sig rest) ((mf-bad e) (mf-bad e)) ((mf-ok r) (mf-ok (cons pn r)))))' \
    'port is PURE (does not cross)'

  # M2 -- GA-03. The clause still parses, still validates, still stores; the
  # stored flag is false, so tot-profile-demands always answers false and
  # tot-gate always returns tot-proven. The two ADMIT rows stay green, which is
  # what says the refusal row is reading the demand and not the def.
  mut_row total-clause-dead lib/surface/parse.chiral 1 \
    '(case (mf-find-clause cs "total") (none false) ((some x) true))' \
    '(case (mf-find-clause cs "total") (none false) ((some x) false))' \
    '(total): an unproven def is REFUSED'

  # M3 -- no profile clause head is recognised. The seven profile positives are
  # refused and thirteen refusals come back with the wrong reason, so this is
  # what stands between the positive rows and a parser that accepts nothing.
  mut_row known-clause-refuses-all lib/surface/parse.chiral 1 \
    '(lam (h) (or (str-eq h "ports")
               (or (str-eq h "target") (or (str-eq h "memory") (str-eq h "total"))))))' \
    '(lam (h) false))' \
    'profile: ports + target
profile: + memory linear
profile: + memory region + total
profile: clause order is free
profile: empty port set
two profiles over one target
manifest beside real definitions
(total): an unproven def is REFUSED
(total): a proven def is ADMITTED
no (total): the same unproven def is ADMITTED
profile redeclared
port is not a declared extern
port is a data type, not extern
port is PURE (does not cross)
missing (ports ...)
missing (target ...)
malformed (target)
unknown target name
unknown memory discipline
malformed (memory)
unknown profile clause
(total) takes no arguments
profile clause is not a form'
fi

echo
echo "profile/target manifest: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
