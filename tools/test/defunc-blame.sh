#!/usr/bin/env bash
# defunc-blame.sh -- the E187 gate: `closconv` STATES why it dropped a family.
#
# not-a-phase: E187's number waits on the standing suite-phase-number call in
#   records/author-calls.md:30 -- four documents disagree about 21-23.
#
# ⚑ UNREGISTERED, AND IT CARRIES NO ROW SAYING SO.  `records/gate-audit.md`
# GA-24 measures why: a row naming its own `run_phase` line cannot fire, because
# deleting that line stops the script that holds the row.  So this gate is run
# by hand, exactly as `apply-spine.sh`, `apply-word.sh`, `tal-check.sh`,
# `crypto.sh` and `capture-fields.sh` are.  `registration.sh` reads it as the
# tenth of twenty-three scripts outside the dispatch table.
#
# ─── THE SUBJECT ────────────────────────────────────────────────────────────
# `st-add-gsite` (closconv.chiral) knows the global's name and which of two
# conditions refused the site, and before E187 it discarded both through
# `st-add-pois`.  A poisoned family then surfaced as the SYMPTOM -- a def that
# does not lower -- with nothing saying which family was dropped or why.
# `sk-defunc` (skip-diag.chiral:15) was minted by E188 to carry exactly that and
# had zero callers tree-wide.  E187 gives it one.
#
# ─── THE SIX ROWS ───────────────────────────────────────────────────────────
# All six are judged on ONE run of the compiler over
# `tools/test/samples/e188_slot_break.prog`, the fixture E188 already built, and
# reported on ONE line: `records/gate-audit.md` GA-21 and GA-22 both convict a
# gate that names one row per mutant, because a mutant reddening a row outside
# its own pin is then invisible.
#
#   R1  the compile is REFUSED -- no ELF is emitted   <- graded, unfalsified
#   R2  the message carries a CAUSE CLAUSE: `defunctionalization refused:`
#   R3  the cause NAMES THE GLOBAL at the refused site: `e188-plus` is in the
#       CAUSE SEGMENT
#   R4  the cause names the RIGHT DISCRIMINANT: `family arity disagrees with
#       the global's` is in the cause segment and `no declared type` is not
#   R5  the SYMPTOM CLAUSE IS UNCHANGED, verbatim         <- the non-regression
#   R6  the PRE-CHANGE binary states no cause on the same fixture and this one
#       does
#
# ⚑ R1 IS `ok` AT HEAD AND IS NOT THE DELIVERABLE.  E188 already refuses this
# fixture, and its message already names `e188-plus`.  R1 exists so that ABSENCE
# is a graded cell rather than a silent one.  R2, R3 and R4 are the deliverable
# and all three measure `bad` before this element.
#
# ─── THE CAUSE SEGMENT, AND WHY IT IS NOT CUT ON THE LAST PIPE ──────────────
# ⚑ The pre-change message is
#
#   no emitted label for entry compile-main | skip chain for compile-main:
#   compile-main: extern does not lower: reference stays upper: e188-plus
#
# so it carries EXACTLY ONE `|` and `e188-plus` sits in the text after it.  A
# cause segment cut at the last separator would therefore make R3 green before
# any work was done, which is the trap the SPEC audit caught.
#
# THE CUT: the cause segment is the text following the FIRST
# `defunctionalization refused: ` in the stderr, and it is the EMPTY string when
# the refusal carries no such marker.  A row asserting a substring of an empty
# segment grades `bad`.  `absent` is reserved for a run with NO REFUSAL to read,
# which is M5's case alone.
#
# ─── THE SEVENTH FIELD IS NOT A ROW ─────────────────────────────────────────
# `cause=<v>` is the cause segment with its leading `<name>: ` cut at the FIRST
# `: `, normalised to [a-z0-9_] (spaces to `_`, everything else dropped), or
# `absent` when the segment is empty or there was no refusal.  That cut is what
# `defunc-lines` writes.  ⚑ M2 AND M4 REDDEN THE IDENTICAL SIX CELLS and only
# this value separates them: M2 reports the wrong discriminant for the right
# record, M4 the right discriminant's absence because the wrong record was
# selected.  A gate pinning six cells would grade them the same string and one
# of the two would be falsifying nothing.  `apply-spine.sh` carries the same
# kind of field for the same reason.
#
# ⚑ A SKIPPED OR ABSENT MEASUREMENT GRADES `absent`, NEVER `ok` -- the
# convention `apply-word.sh` spells (:60, :275) and `capture-fields.sh` uses
# (:243).
#
# ─── R6 NEEDS A BASELINE BINARY ─────────────────────────────────────────────
# `bin/chirality-bin` is tracked, so the pre-change compiler is recoverable from
# git.  E187_BASE_REV names the revision and defaults to `21e1b28`, E187's step
# 6 commit: the last commit whose tracked binary predates this element's
# promotion.  E187_BASE_CC overrides it with a path.  With neither, R6 scores
# `nobase` and this script exits 1: an unscored control is not a passing one.
#
# ⚑ THE DEFAULT REVISION IS PINNED ON PURPOSE AND IT WILL AGE.  R6 asks whether
# THIS change put the cause in the message, so its baseline is THIS change's
# predecessor.  A stale pin is repaired by a fresh E187_BASE_REV, never by
# widening the comparison.
#
# ─── THE MUTANTS, AND ALL FIVE ARE SUBSTITUTIONS ────────────────────────────
# `records/gate-audit.md` GA-19: deleting an arm makes the module
# non-exhaustive, the compiler refuses the mutated tree, and the row is graded
# on a compile refusal instead of on the property it names.  Nothing below
# removes an arm or changes an arity.  Each substitution declares its occurrence
# count, the count is enforced at exactly 1, the mutated file is `cmp -s`'d
# against the base before it is built, and the scratch lib/ is checked not to be
# a symlink (the `pretty.sh` arc, nineteen phantom failures).
#
# ⚑ EVERY ROW BUT R1 IS REDDENED BY A MUTANT: R2 by M1 and M5, R3 by M1, M3
# and M5, R4 by M1, M2, M4 and M5, R5 by M5, R6 by M1 and M5.  ⚑ R1 IS
# REDDENED BY NOTHING, AND THAT IS A MEASURED SHORTFALL AGAINST
# `records/gate-audit.md` GA-22, STATED RATHER THAN HIDDEN.  The SPEC assigned
# R1's falsifier to M5 and the measurement at M5 below refutes it.  The reason
# is a property of the FIXTURE, not of this implementation: `e188_slot_break.prog`
# is unlowerable under every substitution this element admits.  With the guard,
# the family is dropped and `compile-main` is refused naming `e188-plus`;
# without it, `e188-drive`'s higher-order application is refused instead.  Both
# are refusals, so no mutant here can produce an ELF.  R1 is kept because it is
# the cell that routes R2 to R4 to `absent` rather than to a silent `ok` should
# a later change ever emit one, and because a gate whose refusal is UNGRADED
# cannot tell "the cause is right" from "there was nothing to say".  Its own
# falsifier is owed to a fixture that lowers, which is the same fixture §6 of
# the SPEC already owes for the second discriminant.
#
# ⚑ NO PIN BELOW IS EVIDENCE UNTIL ITS MUTANT HAS BEEN BUILT AND RUN.  EN-21
# corrected E186's M5 for exactly that gap, `apply-word.sh:59-67` records the
# same correction being forced on E185, and E188's own SPEC had two of five pins
# corrected by measurement.  Every pin here was MEASURED on 2026-09-05; the
# divergences from the SPEC's table are stated at their mutants.
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

BREAKER="$REPO/tools/test/samples/e188_slot_break.prog"
CC_SRC="$REPO/lib/lowering/upper/closconv.chiral"
SK_SRC="$REPO/lib/lowering/skip-diag.chiral"
for f in "$BREAKER" "$CC_SRC" "$SK_SRC"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its subject cannot fail"; exit 2; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

MARKER='defunctionalization refused: '
SYMPTOM='skip chain for compile-main: compile-main: extern does not lower: reference stays upper: e188-plus'
D_ARITY="family arity disagrees with the global's"
D_NOTYPE='no declared type'

# ─── the baseline compiler for R6 ───────────────────────────────────────────
BASE_CC="${E187_BASE_CC:-}"
BASE_REV="${E187_BASE_REV:-21e1b28}"
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

# refusal_of CCPATH BRKBLOB ERRFILE -> 0 when the compile was REFUSED (no ELF)
refusal_of() {
  local cc="$1" bb="$2" err="$3" elf="$TMP/rf.elf"
  rm -f "$elf"
  ( ulimit -s unlimited; "$cc" <"$bb" >"$elf" 2>"$err" )
  [ -s "$elf" ] && return 1
  return 0
}

# segment_of ERRFILE -> the text after the FIRST marker, empty when there is none
segment_of() {
  awk -v m="$MARKER" '{ i = index($0, m); if (i > 0) { print substr($0, i + length(m)); exit } }' "$1"
}

# cause_of SEGMENT -> the seventh field's value
cause_of() {
  local seg="$1"
  [ -n "$seg" ] || { printf 'absent'; return; }
  printf '%s' "${seg#*: }" | tr ' ' '_' | tr -cd 'a-z0-9_'
}

# ─── the six rows, measured against one compiler ────────────────────────────
# measure CCPATH BRKBLOB -> echoes "R1 R2 R3 R4 R5 R6 cause=V"
measure() {
  local cc="$1" bb="$2"
  local b="$TMP/m.blame" seg cv refused
  local r1 r2 r3 r4 r5 r6

  if refusal_of "$cc" "$bb" "$b"; then refused=yes; else refused=no; fi
  [ "$refused" = yes ] && r1=ok || r1=bad

  if [ "$refused" = yes ]; then
    seg="$(segment_of "$b")"
    grep -qF -- "$MARKER" "$b" && r2=ok || r2=bad
    case "$seg" in *e188-plus*) r3=ok ;; *) r3=bad ;; esac
    r4=bad
    case "$seg" in *"$D_ARITY"*) case "$seg" in *"$D_NOTYPE"*) r4=bad ;; *) r4=ok ;; esac ;; esac
  else
    # no refusal to read: R2 to R4 measured nothing at all
    seg=""; r2=absent; r3=absent; r4=absent
  fi

  grep -qF -- "$SYMPTOM" "$b" && r5=ok || r5=bad

  # R6: the pre-change binary refuses this fixture and states NO cause; this one
  # refuses it and does.  A control that does not hold is not a pass.
  if [ -n "$BASE_CC" ] && [ -x "$BASE_CC" ]; then
    local be="$TMP/m.base.err"
    if refusal_of "$BASE_CC" "$bb" "$be" && ! grep -qF -- "$MARKER" "$be"; then
      if [ "$refused" = yes ] && grep -qF -- "$MARKER" "$b"; then r6=ok; else r6=bad; fi
    else
      r6=bad
    fi
  else
    r6=nobase
  fi

  cv="$(cause_of "$seg")"
  echo "$r1 $r2 $r3 $r4 $r5 $r6 cause=$cv"
}

# ─── the base run ───────────────────────────────────────────────────────────
echo "=== E187 (UNREGISTERED): closconv states WHY it dropped a family ==="
BB="$TMP/brk.blob"
blob_of "$REPO/lib" "$BREAKER" "$BB" || { echo "  FAIL  the breaker blob did not assemble"; exit 1; }

VERDICT="$(measure "$CC" "$BB")"
echo "  line  $VERDICT"
if [ -z "$BASE_CC" ]; then
  echo "        R6: nobase -- E187_BASE_REV / E187_BASE_CC unset or unreadable"
fi

r()  { echo "$VERDICT" | cut -d' ' -f"$1"; }
row() { local got; got="$(r "$1")"
  if [ "$got" = "$3" ]; then ok "R$1 $2"; else bad "R$1 $2 -- got '$got', want '$3'"; fi
}
row 1 "the compile is refused -- no ELF"                          ok
row 2 "the message carries a cause clause"                        ok
row 3 "the cause names e188-plus IN THE CAUSE SEGMENT"            ok
row 4 "the cause names the arity discriminant and not the other"  ok
row 5 "the symptom clause is unchanged, verbatim"                 ok
row 6 "the pre-change binary states no cause and this one does"   ok

ALLOK="ok ok ok ok ok ok cause=family_arity_disagrees_with_the_globals"
if [ "$VERDICT" != "$ALLOK" ]; then
  echo
  echo "  the base line is not ALLOK; the mutants are NOT run (silent failure 4:"
  echo "  a mutant graded against an already-red base measures nothing)."
  echo
  echo "  defunc-blame.sh: $pass ok, $fail FAIL, $((SECONDS - T0))s wall (records, sets no bar)"
  exit 1
fi

# ─── the mutant harness ─────────────────────────────────────────────────────
# ⚑ THE SCRATCH lib/ MUST BE A REAL DIRECTORY, NEVER A SYMLINK.  cp -a copies a
# symlink AS a symlink and every sed -i then writes THROUGH it into the tree
# under test (the pretty.sh arc, nineteen phantom failures).
MUTLIB=""
sub() {  # sub NAME RELPATH NEEDLE REPLACEMENT  -- one enforced substitution
  local name="$1" rel="$2" needle="$3" repl="$4"
  local tgt="$MUTLIB/$rel" n
  n="$(grep -cF -- "$needle" "$tgt")"
  if [ "$n" -ne 1 ]; then
    bad "$name -- needle matched $n time(s), not 1 (stale pattern; the mutation would be a lie)"
    return 1
  fi
  sed -i "s|$needle|$repl|" "$tgt"
  if cmp -s "$tgt" "$REPO/lib/$rel"; then
    bad "$name -- the mutation did not change lib/$rel (stale pattern)"
    return 1
  fi
  return 0
}

mutate() {  # mutate NAME REL NEEDLE REPL [REL2 NEEDLE2 REPL2]
  local name="$1"; shift
  MUTLIB="$TMP/mutlib-$name"
  rm -rf "$MUTLIB"; cp -a "$REPO/lib" "$MUTLIB"
  if [ -L "$MUTLIB" ]; then
    bad "$name -- the scratch lib/ is a SYMLINK; sed would write into the tree under test"
    return 1
  fi
  while [ "$#" -ge 3 ]; do
    sub "$name" "$1" "$2" "$3" || return 1
    shift 3
  done
  return 0
}

run_mutant() {  # run_mutant NAME PIN DESC   (MUTLIB already set by mutate)
  local name="$1" pin="$2" desc="$3"
  local mbb="$TMP/$name.brk.blob" mcc="$TMP/$name.cc"
  if ! blob_of "$MUTLIB" "$BREAKER" "$mbb"; then
    bad "$name -- BUILD:fail, the breaker blob did not assemble under the mutant lib"; return
  fi
  if ! build_cc "$MUTLIB" "$mcc"; then
    bad "$name -- BUILD:fail, the mutant compiler did not build; UNBUILT measures nothing"; return
  fi
  local line; line="$(measure "$mcc" "$mbb")"
  if [ "$line" = "$pin" ]; then
    ok "$name $desc -- RUN: '$line'"
  else
    bad "$name $desc -- RUN: '$line', pinned '$pin'"
  fi
}

# M1: the mismatch arm reverts to `(st-add-pois st key)`.  The family is still
# poisoned and the reason goes unrecorded, which is the pre-change behaviour
# EXACTLY.  This is the element's own falsifier: a green R2/R3/R4 cannot be
# inherited from anything already in the tree.
if mutate M1 "lowering/upper/closconv.chiral" \
   "(false (st-pois-defunc st key g \"$D_ARITY\"))" '(false (st-add-pois st key))'; then
  run_mutant M1 "ok bad bad bad ok bad cause=absent" "the reason goes unrecorded again"
fi

# M2: the two `why` strings are SWAPPED, so the arity arm passes "no declared
# type".  R4's falsifier.  Two substitutions, applied in order: the second
# needle stays unique after the first because the `(none)` arm's text is
# prefixed `((none)` and never `(false (`.
if mutate M2 "lowering/upper/closconv.chiral" \
   "((none)    (st-pois-defunc st key g \"$D_NOTYPE\"))" \
   "((none)    (st-pois-defunc st key g \"$D_ARITY\"))" \
   "lowering/upper/closconv.chiral" \
   "(false (st-pois-defunc st key g \"$D_ARITY\"))" \
   "(false (st-pois-defunc st key g \"$D_NOTYPE\"))"; then
  run_mutant M2 "ok ok ok bad ok ok cause=no_declared_type" "the two discriminants are swapped"
fi

# M3: the record is built as `(sk-defunc why why)` -- the right discriminant
# with no name.  R3's falsifier, and the reason R3 reads the CAUSE SEGMENT and
# never the whole stderr: `e188-plus` is in the symptom clause either way.
if mutate M3 "lowering/upper/closconv.chiral" \
   '(mk-skrec g (sk-defunc g why))' '(mk-skrec g (sk-defunc why why))'; then
  run_mutant M3 "ok ok bad ok ok ok cause=family_arity_disagrees_with_the_globals" \
    "the cause carries no name"
fi

# M4: `defunc-lines` filters on "extern" instead of "defunc".  A cause clause
# exists and reports the WRONG RECORD.  R4's second falsifier, and the mutant
# that shares M2's six cells.
if mutate M4 "lowering/skip-diag.chiral" \
   '(str-eq (skwhy-tag w) "defunc")' '(str-eq (skwhy-tag w) "extern")'; then
# ⚑ MEASURED DIVERGENCE FROM THE SPEC'S TABLE, AND THE SPEC NAMED IT IN
# ADVANCE.  §5.2 pinned `cause=e188plus_reference_stays_upper_e188plus` on a
# ONE-RECORD filter and stated the record count was unmeasured.  It is three:
# two `higher-order application` records and one `reference stays upper:
# e188-plus`, joined by `join-semi`.  `skwhy-name` and `skwhy-detail` both
# answer `op` on an `sk-extern` reason, so each line renders its op twice and
# the seventh field's cut lands inside the first one.  The SIX CELLS hold as
# pinned, which is what the SPEC said would survive either way, and the value is
# still nothing like M2's -- which is the whole job of the field.
  run_mutant M4 "ok ok ok bad ok ok cause=higherorder_application_defunctionalization_refused_higherorder_application_higherorder_application_defunctionalization_refused_reference_stays_upper_e188plus_reference_stays_upper_e188plus" \
    "the filter selects the wrong record"
fi

# M5: the guard never fires -- the mismatch is REGISTERED instead of poisoned
# (`apply-spine.sh`'s own M3).  R5's only falsifier.
# ⚑ MEASURED DIVERGENCE FROM THE SPEC'S TABLE, AND IT IS THE ONE THAT MATTERS.
# §5.2 pinned `bad absent absent absent bad bad`, deriving R1 `bad` from
# `apply-spine.sh`'s M3 pin on the reading that that gate's R5 goes red only when
# the breaker EMITTED an ELF.  It does not: `apply-spine.sh`'s `measure` also
# reddens R5 from a failed grep inside the refusal branch, which is what happens
# there.  MEASURED here: the breaker is STILL REFUSED under M5, with the
# pre-E188 blame --
#
#   no emitted label for entry compile-main | skip chain for compile-main:
#   compile-main <- e188-drive: extern does not lower: higher-order application
#
# -- because registering the mismatching site changes the family key set and
# `e188-drive`'s higher-order use is then refused first.  So R1 is `ok`, the
# symptom clause is gone (R5 `bad`), there IS a refusal to read and its cause
# segment is EMPTY, so R2 to R4 grade `bad` and not `absent`.
if mutate M5 "lowering/upper/closconv.chiral" \
   "(false (st-pois-defunc st key g \"$D_ARITY\"))" '(false (st-add-site st key (cs-g g k fields)))'; then
  run_mutant M5 "ok bad bad bad bad bad cause=absent" "the mismatch is registered, not poisoned"
fi

echo
echo "  defunc-blame.sh: $pass ok, $fail FAIL, $((SECONDS - T0))s wall (records, sets no bar)"
[ "$fail" -eq 0 ] || exit 1
exit 0
