#!/usr/bin/env bash
# mutant.sh -- the run-the-mutant rule, made mechanical.
#
# docs/definitions/testing-floors.md states the rule: a gate row must NAME a
# mutant that falsifies it, and the mutant must be RUN. Naming a mutant is a
# claim about the gate; running it is the evidence. Until now every phase script
# that honoured the rule re-implemented it (diag.sh does, at the fixture level),
# and the phases that did not honour it were indistinguishable from the ones
# that did, because nothing in the tree could tell the two apart.
#
# ⚑ 2026-09-05, THE COUNT THAT STOOD IN THAT SENTENCE IS GONE.
# records/gate-audit.md GA-11 measured it: it read "the five phases", which was
# MUT_PHASES below -- the five sub-scripts run-tests.sh dispatched at 58f4f7c,
# the commit that added this file. The same sentence exempts diag.sh, and GA-06
# measured syscall-manifest.sh as honouring the rule in its own `poison` idiom,
# so the set was three at that commit and never five. The suite dispatches
# thirteen phases today and the number has moved again. A bare figure with no
# date beside it is what docs/definitions/testing-floors.md calls a figure that
# rots, so this paragraph now carries none.
#
# not-a-phase: a sourceable library plus a matrix driver a person runs by hand.
# records/gate-audit.md GA-01 is the open row arguing the matrix wants a phase of
# its own.  Nothing has ruled yet, so it stays out and stays visible.
#
# ⚑ 2026-09-05, THE LIBRARY HALF IS NOW UNDER THE SUITE. Phases 3, 4 and 6
# source this file and declare mutants of their own (check-cli.sh,
# profile-target.sh, linear-mint.sh, for records/gate-audit.md GA-03, GA-05 and
# GA-07), so mut_count, mut_sub, mutant_build and mutant_differs are exercised
# on every run of the gate. What is still outside the gate is the MATRIX -- the
# driver at the foot of this file and its every-mutant-by-every-phase table --
# and GA-01 is that gap and nothing wider.
#
# This file is that rule as a sourceable library plus a standalone matrix
# driver. It mutates a rule in `lib/`, builds a compiler from the mutated tree,
# and puts THAT compiler under a whole phase through CHIRALITY_COMPILE -- the
# seam bin/chirality already documents as "one export really does put a chosen
# compiler under the whole suite".
#
# ⚑ FOUR WAYS THIS MEASUREMENT FAILS SILENTLY, each closed here by an assertion
# rather than by care:
#
#   1. THE MUTATION MATCHED NOTHING. A substitution whose anchor is stale hits no
#      text, the compiler is byte-identical to the base, every phase stays green,
#      and the run reads as a coverage hole. It is a harness bug. `mutate` counts
#      occurrences and refuses any count but the declared one.
#   2. THE MUTANT DID NOT BUILD. An unbuilt mutant measures nothing about any
#      gate. It is reported as UNBUILT, never as a survival.
#   3. THE MUTANT IS SEMANTICALLY INERT. The anchor matched, the compiler built,
#      and it computes what the base computed. Surviving every phase then says
#      nothing. `mutant_differs` asserts the built compiler differs from the base;
#      a caller claiming a coverage hole must additionally show the mutant admits
#      or refuses a program the base does not (see the qjoin fixture).
#   4. THE BASE WAS ALREADY RED. A phase failing for an unrelated reason convicts
#      every mutant. `mutant_control` runs the phase under the real compiler
#      first, and a red control aborts rather than scoring.
#
# ⚑ SIZE IS NOT A SIGNAL, measured 2026-08-31. Five semantic mutants of the QTT
# usage audit each produced a compiler of exactly 1,098,104 B, the size of the
# correct one, and four of them reached a byte-identical self-hosting fixpoint.
# A compiler with the linear-usage audit disabled fixpoints perfectly. That is
# HANDOFF.md's "a fixpoint is stability, never correctness" as a measurement.
#
# ⚑ 2026-09-05, ON HOW TO READ THAT PARAGRAPH. Its "four of them" was taken with
# the single `cmp C1 C2` this file did until today, and that check answers `no`
# on a mutant which converges one generation later (see mutant_fixpoints). The
# figure is a measurement as taken and stands: four fixpoints were seen. What it
# licenses is "at least four", not "exactly four" -- the fifth was never shown
# NOT to reach one. It is not rewritten, because the correction moves answers in
# the `no` direction only and every `yes` above was and remains a fixpoint.
#
# Zero Python, here as everywhere in this harness: the literal-text search and
# replace below is pure bash parameter expansion, so the tool that audits the
# gates does not reach for the floor the gates exist without.
#
# Use as a library:
#     . tools/test/mutant.sh
#     cc="$(mutant_build LABEL lib/typing/qtt.chiral 1 "$OLD" "$NEW")"
#     mutant_red "$cc" linear-mint.sh   # -> RED | green
#
# Use as a driver:
#     bash tools/test/mutant.sh --matrix      # every declared mutant x every phase
#     bash tools/test/mutant.sh --list        # the declared mutants, run nothing
set -uo pipefail

MUT_HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
MUT_REPO="$(cd "$MUT_HERE/../.." && pwd)"
MUT_B1="${CHIRALITY_MUTANT_BASE:-$MUT_REPO/bin/chirality-bin}"
[ -x "$MUT_B1" ] || { echo "mutant.sh: no base compiler at $MUT_B1" >&2; exit 2; }

# The scratch root. Every mutated tree and every mutant compiler lands here and
# NOWHERE ELSE -- a mutant that can reach a promoted location is a mutant that
# can be shipped.
MUT_WORK="${CHIRALITY_MUTANT_DIR:-$(mktemp -d)}"
[ -n "${CHIRALITY_MUTANT_DIR:-}" ] || trap 'rm -rf "$MUT_WORK"' EXIT
mkdir -p "$MUT_WORK"

# ---- literal text, counted and replaced without leaving bash ----------------
# `grep -Fc` counts matching LINES, which is not the same number and is wrong
# for a multi-line anchor. These two count and replace OCCURRENCES.

# mut_slurp <file> -> the file's bytes, trailing newlines intact
mut_slurp() { local s; s="$(cat "$1"; printf x)"; printf '%s' "${s%x}"; }

# mut_count <file> <needle> -> occurrences
mut_count() {
  local rest n=0
  rest="$(mut_slurp "$1")"
  while [ "${rest#*"$2"}" != "$rest" ]; do rest="${rest#*"$2"}"; n=$((n+1)); done
  printf '%s' "$n"
}

# mut_sub <file> <needle> <replacement> -- replaces every occurrence, in place
mut_sub() {
  local s out="" rest
  rest="$(mut_slurp "$1")"
  while [ "${rest#*"$2"}" != "$rest" ]; do
    out="$out${rest%%"$2"*}$3"
    rest="${rest#*"$2"}"
  done
  printf '%s' "$out$rest" > "$1"
}

# ---- build a compiler from a mutated tree -----------------------------------
# mutant_build <label> <repo-relative file> <want-count> <old> <new>
#   echoes the mutant compiler's path, or FAIL:<reason>. Never exits: a caller
#   scoring a matrix needs the failed row as much as the built one.
mutant_build() {
  local label="$1" rel="$2" want="$3" old="$4" new="$5"
  local tree="$MUT_WORK/tree-$label" cc="$MUT_WORK/$label.cc"
  # E204: CHIRALITY_MUTANT_SRC, read per call, names the tree to poison.
  local src="${CHIRALITY_MUTANT_SRC:-$MUT_REPO}"
  rm -rf "$tree"; mkdir -p "$tree"
  cp -a "$src/lib" "$src/prog" "$src/bin" "$tree/" 2>/dev/null \
    || { echo "FAIL:copy"; return; }
  local f="$tree/$rel"
  [ -f "$f" ] || { echo "FAIL:no-such-file($rel)"; return; }

  local n; n="$(mut_count "$f" "$old")"
  [ "$n" = "$want" ] || { echo "FAIL:anchor-matched-${n}-want-${want}"; return; }
  mut_sub "$f" "$old" "$new"

  ( cd "$tree" && . "$tree/bin/chirality-resolve.sh" \
      && chirality_blob_file "lib:prog" prog/compiler.prog ) \
      >"$MUT_WORK/$label.blob" 2>"$MUT_WORK/$label.rerr" \
    || { echo "FAIL:resolve"; return; }
  ( ulimit -s unlimited; "$MUT_B1" <"$MUT_WORK/$label.blob" >"$cc" 2>"$MUT_WORK/$label.cerr" ) \
    || { echo "FAIL:compile"; return; }
  # ⚑ non-empty BEFORE anything compares it. `cmp` of two empty files passes.
  [ -s "$cc" ] || { echo "FAIL:empty"; return; }
  chmod +x "$cc"
  printf '%s' "$cc"
}

# mutant_differs <compiler> -> 0 if it differs from the base, 1 if identical
# A mutant byte-identical to the base cannot convict anything and cannot be a
# coverage hole either. Size is NOT the test; these compilers are size-stable.
mutant_differs() { ! cmp -s "$1" "$MUT_B1"; }

# ---- run a phase under a chosen compiler ------------------------------------
# mutant_red <compiler> <phase script name> -> RED | green
#
# ⚑ CHIRALITY_NO_MUTANTS is set for the leg. Three dispatched phases source
# this file and build mutants of their own; under the matrix those legs would
# build a mutant of a mutant and cost minutes to say nothing about this cell. A
# matrix cell means "the phase's own rows, under this compiler", so the phase's
# own mutant block is turned off for it.
mutant_red() {
  if CHIRALITY_COMPILE="$1" CHIRALITY_NO_MUTANTS=1 \
       timeout "${CHIRALITY_MUTANT_TIMEOUT:-600}" \
       bash "$MUT_HERE/$2" >/dev/null 2>&1
  then printf 'green'; else printf 'RED'; fi
}

# mutant_control <phase script name> -> 0 if green under the real compiler
# A phase red for an unrelated reason convicts every mutant it is shown.
mutant_control() { [ "$(mutant_red "$MUT_B1" "$1")" = green ]; }

# ---- the fixpoint, as a measurement rather than a claim ---------------------
# mut_first_diff <a> <b> -> cmp's first differing char, without the long paths
mut_first_diff() {
  local d; d="$(cd "$MUT_WORK" && cmp "${1##*/}" "${2##*/}" 2>&1)"
  printf '%s' "${d##*differ: }"
}

# mutant_fixpoints <label> -> 0 when two CONSECUTIVE generations agree
# Sets MUT_FP to where they agreed (C1==C2, C2==C3, C3==C4) or to `no`, and
# MUT_FP_WHY to the sizes and the first differing char when they did not.
# Reported so "it self-hosts" is never read as "it is correct".
#
# ⚑ NOT ONE `cmp C1 C2`, which is what this function did until 2026-09-05.
# docs/definitions/working-discipline.md was corrected at 76d3296: convergence
# is two consecutive generations agreeing, and C1 carries the new sources
# emitted by the OLD code generator. A change to EMITTED CODE that the
# compiler's own blob reaches separates C1 from C2 for that reason alone and
# first agrees at C2 == C3. The single `cmp` therefore answered `no` on a mutant
# that converges one generation later, so every `no` the matrix printed was
# inconclusive. Bounded at C4, since the same argument caps the first agreement
# at C2 == C3.
#
# ⚑ COST, and the answer is `converged-at-N` rather than yes/no so the cost is
# visible in the matrix. A generation past the second is built ONLY when the
# previous pair differed, which is the corrected rule read literally rather than
# a cheaper approximation of it: a mutant converging at C1 == C2 builds the one
# generation it always built. Measured 2026-09-05 on this box: a generation is
# about 1 s (mutant_build's 5 s is the tree copy and the blob resolve, not the
# compile), and all seven declared mutants answer C1 == C2 with ONE generation
# built each. The whole fixpoint stage over the declared set is 28 s, unchanged,
# and the matrix's ceiling if every mutant went the long way is +14 s.
#
# ⚑ VERIFIED against a mutant that does change emitted code, 2026-09-05. The
# declared set is typing and parse rules and none of it reaches emission, so the
# falsifier for this repair was built by hand: E188's step-4 fix reverted, which
# 6d59b81 measured as an emission change the compiler's own blob reaches twice.
#     . tools/test/mutant.sh
#     mutant_build emit-probe lib/lowering/upper/closconv.chiral 1 \
#       '((none) (rw sig ka (arm-rw-ctx fields) none
#            (cspine (c-global g) (spine-args 0 0 fields (+ k d) k m d))))))' \
#       '((none) (c-lit-i 0))))'      # indentation as in the file
# C1 1,184,120 B, C2 1,192,312 B differing at char 98, C3 byte-identical to C2.
# The old check answered `no` on it. This one answers C2 == C3. That `no` was
# the defect: a correct three-generation convergence reported as a failure.
#
# ⚑ NON-EMPTY BEFORE EVERY cmp, and (ulimit -s unlimited) on EVERY build. Two
# empty files compare equal, so an unguarded cmp reports a fixpoint on a build
# that produced nothing. The corrected rule needs both guards in three places
# where the old one needed them in one.
MUT_FP=""; MUT_FP_WHY=""
mutant_fixpoints() {
  local label="$1" next n
  local blob="$MUT_WORK/$label.blob" prev="$MUT_WORK/$label.cc"
  MUT_FP=no; MUT_FP_WHY=""
  [ -s "$prev" ] && [ -s "$blob" ] || { MUT_FP_WHY="no C1, or no blob to build one from"; return 1; }
  MUT_FP_WHY="C1 $(wc -c <"$prev") B"
  for n in 2 3 4; do
    next="$MUT_WORK/$label.c$n"
    ( ulimit -s unlimited; "$prev" <"$blob" >"$next" 2>/dev/null ) \
      || { MUT_FP_WHY="$MUT_FP_WHY; C$n did not build"; return 1; }
    [ -s "$next" ] || { MUT_FP_WHY="$MUT_FP_WHY; C$n is empty"; return 1; }
    chmod +x "$next"
    if cmp -s "$prev" "$next"; then MUT_FP="C$((n-1))==C$n"; return 0; fi
    MUT_FP_WHY="$MUT_FP_WHY; C$n $(wc -c <"$next") B, $(mut_first_diff "$prev" "$next")"
    prev="$next"
  done
  return 1
}

# ============================================================================
# The declared mutants. One per line: label, file, count, old, new, intent.
# `intent` is what the mutant is EXPECTED to convict; the matrix prints what it
# actually convicted, and the difference is the finding.
# ============================================================================
MUT_PHASES="check-cli.sh profile-target.sh linear-mint.sh syscall-manifest.sh diag.sh"

mut_each() {  # calls `$1 label file count old new intent` per declared mutant
  "$1" qfits-q1-accepts-all lib/typing/qtt.chiral 1 \
    '((q1) (case computed ((q1) true) ((q0) false) ((qw) false)))' \
    '((q1) true)' \
    'a q1 declaration admits any usage: the forge and the leak both pass'

  "$1" qfits-q0-accepts-all lib/typing/qtt.chiral 1 \
    '((q0) (case computed ((q0) true) ((q1) false) ((qw) false)))' \
    '((q0) true)' \
    'an erased binder admits any usage'

  # ⚑ TWO qjoin mutants, one per non-trivial arm of the table, because a mutant
  # of `qjoin q1 q0` leaves `qjoin q0 q1` saturating and vice versa. Measured
  # 2026-08-31 as a 2x2 diagonal against linear-mint.sh section E: the q1 mutant
  # reddens E1 and E6 and NOT E2, the q0 mutant reddens E2 and NOT E1 or E6.
  # One mutant here would have licensed one row and left the other arm bare.
  "$1" qjoin-q1-no-saturate lib/typing/qtt.chiral 1 \
    '((q1) (case b ((q0) (qw)) ((q1) (q1)) ((qw) (qw))))' \
    '((q1) (case b ((q0) (q1)) ((q1) (q1)) ((qw) (qw))))' \
    'used in arm 1 and not arm 2 stops saturating to w'

  "$1" qjoin-q0-no-saturate lib/typing/qtt.chiral 1 \
    '((q0) (case b ((q0) (q0)) ((q1) (qw)) ((qw) (qw))))' \
    '((q0) (case b ((q0) (q0)) ((q1) (q1)) ((qw) (qw))))' \
    'used in arm 2 and not arm 1 stops saturating to w'

  "$1" strip-binder-off lib/typing/kernel.chiral 1 \
    '(false (ck-err (r-usage (subj-lam-binder) q (last-qty u))))' \
    '(false (ck-ok (drop-last u)))' \
    'the lam/pi binder usage audit never fires'

  "$1" close-binder-off lib/typing/kernel.chiral 1 \
    '(false (ck-err (r-usage (subj-let-binder) q (last-qty ub))))' \
    '(false (ck-ok (uadd (drop-last ub) (uscale q uv))))' \
    'the let binder usage audit never fires'

  "$1" port-purity-off lib/surface/parse.chiral 1 \
    '(false (mf-bad (mf-port-pure pn)))' \
    '(false (case (mf-check-ports sig rest) ((mf-bad e) (mf-bad e)) ((mf-ok r) (mf-ok (cons pn r)))))' \
    'a pure extern is admitted into a frozen port set'
}

mut_list_one() { printf '  %-22s %-24s %s\n' "$1" "$2" "$6"; }

mut_matrix_one() {
  local label="$1" rel="$2" want="$3" old="$4" new="$5" intent="$6"
  printf '\n=== %s (%s)\n    expected to convict: %s\n' "$label" "$rel" "$intent"
  local cc; cc="$(mutant_build "$label" "$rel" "$want" "$old" "$new")"
  case "$cc" in
    FAIL:*) printf '  UNBUILT (%s) -- measures nothing about any gate\n' "$cc"
            printf '%s\tUNBUILT\t%s\n' "$label" "$cc" >>"$MUT_WORK/matrix.tsv"; return;;
  esac
  if ! mutant_differs "$cc"; then
    printf '  INERT -- byte-identical to the base; it can neither convict nor be a hole\n'
    printf '%s\tINERT\n' "$label" >>"$MUT_WORK/matrix.tsv"; return
  fi
  mutant_fixpoints "$label"
  printf '  built %s B, differs from base, self-hosting fixpoint: %s\n' "$(wc -c <"$cc")" "$MUT_FP"
  [ "$MUT_FP" = no ] && printf '    no fixpoint by C4: %s\n' "$MUT_FP_WHY"
  local row="$label" survived=1 p v
  for p in $MUT_PHASES; do
    v="$(mutant_red "$cc" "$p")"
    printf '  %-22s %s\n' "${p%.sh}" "$v"
    [ "$v" = RED ] && survived=0
    row="$row	${p%.sh}=$v"
  done
  [ "$survived" = 1 ] && printf '  ⚑ SURVIVED EVERY PHASE -- the rule it breaks has no coverage\n'
  printf '%s\tfixpoint=%s\n' "$row" "$MUT_FP" >>"$MUT_WORK/matrix.tsv"
}

# ---- the driver -------------------------------------------------------------
if [ "${BASH_SOURCE[0]:-$0}" = "${0}" ]; then
  case "${1:---matrix}" in
    --list)
      echo "declared mutants:"
      mut_each mut_list_one
      ;;
    --matrix)
      : >"$MUT_WORK/matrix.tsv"
      echo "base compiler: $MUT_B1 ($(wc -c <"$MUT_B1") bytes)"
      echo
      echo "=== the control: every phase under the REAL compiler ==="
      ctl_bad=0
      for p in $MUT_PHASES; do
        v="$(mutant_red "$MUT_B1" "$p")"
        printf '  %-22s %s\n' "${p%.sh}" "$v"
        [ "$v" = green ] || ctl_bad=1
      done
      if [ "$ctl_bad" = 1 ]; then
        echo
        echo "  ABORT: a phase is red before any mutation. Every mutant would score"
        echo "  as convicted and the matrix would mean nothing. Fix the suite first."
        exit 2
      fi
      mut_each mut_matrix_one
      echo
      echo "=== matrix (rows are mutants, a green cell is a phase that did not notice) ==="
      cat "$MUT_WORK/matrix.tsv"
      ;;
    *)
      echo "usage: bash tools/test/mutant.sh [--matrix|--list]" >&2; exit 1;;
  esac
fi
