#!/usr/bin/env bash
# mutant.sh -- the run-the-mutant rule, made mechanical.
#
# docs/definitions/testing-floors.md states the rule: a gate row must NAME a
# mutant that falsifies it, and the mutant must be RUN. Naming a mutant is a
# claim about the gate; running it is the evidence. Until now every phase script
# that honoured the rule re-implemented it (diag.sh does, at the fixture level),
# and the five phases that did not honour it were indistinguishable from the
# ones that did, because nothing in the tree could tell the two apart.
#
# not-a-phase: a sourceable library plus a matrix driver a person runs by hand.
# records/gate-audit.md GA-01 is the open row arguing the matrix wants a phase of
# its own.  Nothing has ruled yet, so it stays out and stays visible.
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
  rm -rf "$tree"; mkdir -p "$tree"
  cp -a "$MUT_REPO/lib" "$MUT_REPO/prog" "$MUT_REPO/bin" "$tree/" 2>/dev/null \
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
mutant_red() {
  if CHIRALITY_COMPILE="$1" timeout "${CHIRALITY_MUTANT_TIMEOUT:-600}" \
       bash "$MUT_HERE/$2" >/dev/null 2>&1
  then printf 'green'; else printf 'RED'; fi
}

# mutant_control <phase script name> -> 0 if green under the real compiler
# A phase red for an unrelated reason convicts every mutant it is shown.
mutant_control() { [ "$(mutant_red "$MUT_B1" "$1")" = green ]; }

# ---- the fixpoint, as a measurement rather than a claim ---------------------
# mutant_fixpoints <label> -> 0 if the mutant compiler reproduces itself
# Reported so "it self-hosts" is never read as "it is correct".
mutant_fixpoints() {
  local cc="$MUT_WORK/$1.cc" blob="$MUT_WORK/$1.blob" c2="$MUT_WORK/$1.c2"
  [ -s "$cc" ] && [ -s "$blob" ] || return 1
  ( ulimit -s unlimited; "$cc" <"$blob" >"$c2" 2>/dev/null ) || return 1
  [ -s "$c2" ] && cmp -s "$cc" "$c2"
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
  local fp=no; mutant_fixpoints "$label" && fp=yes
  printf '  built %s B, differs from base, self-hosting fixpoint: %s\n' "$(wc -c <"$cc")" "$fp"
  local row="$label" survived=1 p v
  for p in $MUT_PHASES; do
    v="$(mutant_red "$cc" "$p")"
    printf '  %-22s %s\n' "${p%.sh}" "$v"
    [ "$v" = RED ] && survived=0
    row="$row	${p%.sh}=$v"
  done
  [ "$survived" = 1 ] && printf '  ⚑ SURVIVED EVERY PHASE -- the rule it breaks has no coverage\n'
  printf '%s\tfixpoint=%s\n' "$row" "$fp" >>"$MUT_WORK/matrix.tsv"
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
