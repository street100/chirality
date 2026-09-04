#!/usr/bin/env bash
# registration.sh -- the witness for run-tests.sh's dispatch table.
#
# not-a-phase: the witness for the dispatch table, and it holds no number itself.
#
# NO PHASE NUMBER, deliberately and by author call.  The
# three unregistered gates already own the argument (run-tests.sh:332,
# docs/decisions/decision-lane-split.md:30, records/author-calls.md): 21-23 are
# Lane B's and 8-12 are names still owed to unported old-tree phases.  A number
# is not what this file needs.  It needs to RUN, and it runs because
# run-tests.sh runs.
#
# ⚑ WHAT WAS BROKEN.  records/gate-audit.md GA-24: five gate scripts each
# assert their OWN `run_phase` line (doc.sh:462-473, row.sh:683-689,
# face.sh:585-591, render-doc.sh:536-543, pretty.sh:502-509).  A row asserting
# its own registration cannot fire.  Delete the dispatch line and the script
# holding the row stops running, so the row that would have caught the deletion
# is the row the deletion silenced.  Measured then: phases 3, 4, 5, 6, 19 and 20
# were checked by nothing anywhere, and 17, 18 and 24 only by themselves.
# `matcher.sh` could be dropped from the suite with nothing going red.
#
# ⚑ THE SHAPE.  Two sources that are not each other:
#
#   THE DIRECTORY   every tools/test/*.sh that exists on disk
#   THE TABLE       every `run_phase N ... script.sh` line in run-tests.sh
#
# The rule is that the two agree.  A script on disk is either DISPATCHED by the
# table or it DECLARES ITSELF OUT, in its own header, with a reason.  Nothing
# else is legal.  Deleting a dispatch line therefore reddens a row HERE, in a
# file the deletion did not silence, and it names the orphaned script.
#
# The declaration is one comment line at the head of the script that is out:
#
#     [hash][space]not-a-phase: why it is not dispatched
#
# It is not a manifest.  It carries no phase number, no path and no copy of the
# table, so there is nothing in it to drift from.  It says one bit about the
# file it lives in, and it lives in that file.  Adding a legitimate phase is
# still ONE edit -- the `run_phase` line -- because a dispatched script needs no
# declaration at all.
#
# ⚑ WHAT IT SAYS ABOUT THE FIVE THAT DO NOT RUN.  They are printed by name and
# by reason on every run, under a heading that says they do not run, and G4
# fails a declaration whose reason is blank.  Their absence is reported, not
# laundered into the pass count: a PEND line is neither a pass nor a failure.
#
# Six rows, one verdict line, and every mutant pins the line in FULL, so a
# mutant reddening a row outside its own pin is impossible to miss:
#
#   G1  every dispatched script exists on disk                      [M6]
#   G2  every script on disk is dispatched or declares itself out   [M1,M2]
#   G3  no script is both dispatched and declared out               [M4,M7]
#   G4  every declaration carries a reason                          [M3]
#   G5  no phase number is dispatched twice                         [M5]
#   G6  the 21-23 band Lane B reserved stays unused                 [M7]
#
# ⚑ M1 IS THE ROW THIS FILE EXISTS FOR, and it is not one deletion.  It deletes
# EVERY dispatch line in turn, over a copy, and asserts the reddened count
# equals the number of lines the table holds -- so a loop whose body never ran
# is a FAIL rather than an empty miss list (records/gate-audit.md GA-19).
#
# Nothing here compiles.  No compiler, no resolver, no lib/ under test: it is
# text against text, and it costs under a second on a 3.85 GB box.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
RT_DEFAULT="$HERE/run-tests.sh"
RT="${1:-$RT_DEFAULT}"
[ -f "$RT" ] || { echo "registration: no run-tests.sh at $RT"; exit 2; }

TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# The two needles are ASSEMBLED, so neither this file's source nor its own
# header can satisfy a check it is running.  `RPH` never appears whole here and
# `MARKH` is built from a hash that is not at the head of a comment line.
RPH="run""_phase"
H='#'
MARK="^$H not-a-phase:"

# ---- the two sources -------------------------------------------------------

# dispatched RT -> "<number> <script>" per dispatch line, in table order
dispatched() {
  grep -E "^$RPH[[:space:]]+[0-9]+[[:space:]]" "$1" | awk '{print $2, $NF}'
}

# declares_out FILE -> 0 when the file carries a declaration line
declares_out() { grep -qE "$MARK" "$1"; }

# reason_of FILE -> the declared reason, or "" when the line carries none
reason_of() { sed -nE "s|$MARK[[:space:]]*||p" "$1" | head -1; }

# ---- the rule --------------------------------------------------------------
#
# findings DIR RT -> zero or more "<KIND> <script> <sentence>" lines.  Empty
# output is the whole gate passing.  Every row below reads off THIS function,
# and so does every mutant's want, so a want cannot be re-derived somewhere a
# mutation does not reach (records/gate-audit.md GA-18).
findings() {
  local d="$1" rt="$2" disp dnames f s n
  disp="$(dispatched "$rt")"
  dnames="$(printf '%s\n' "$disp" | awk 'NF{print $2}' | sort)"

  printf '%s\n' "$disp" | while read -r n s; do
    [ -n "${s:-}" ] || continue
    [ -f "$d/$s" ] || echo "DANGLING $s phase $n dispatches a script that is not in the directory"
  done

  printf '%s\n' "$disp" | awk 'NF{print $1}' | sort | uniq -d | while read -r n; do
    [ -n "$n" ] || continue
    echo "DUPNUM $n phase number $n is dispatched more than once"
  done

  printf '%s\n' "$disp" | awk 'NF && $1+0 >= 21 && $1+0 <= 23 {print $1, $2}' | while read -r n s; do
    [ -n "${s:-}" ] || continue
    echo "RESERVED $s phase $n is inside the 21-23 band Lane B reserved"
  done

  for f in "$d"/*.sh; do
    [ -f "$f" ] || continue
    s="${f##*/}"
    local isd=0 ism=0
    printf '%s\n' "$dnames" | grep -qxF "$s" && isd=1
    declares_out "$f" && ism=1
    if [ "$isd" = 1 ] && [ "$ism" = 1 ]; then
      echo "CONTRADICTION $s is dispatched by the table AND declares itself out of the suite"
    fi
    if [ "$isd" = 0 ] && [ "$ism" = 0 ]; then
      echo "UNWITNESSED $s is on disk, is dispatched by no run_""phase line, and declares no reason to be out"
    fi
    if [ "$ism" = 1 ] && [ -z "$(reason_of "$f")" ]; then
      echo "NOREASON $s declares itself out of the suite and names no reason"
    fi
  done
}

GRP_KINDS="G1:DANGLING G2:UNWITNESSED G3:CONTRADICTION G4:NOREASON G5:DUPNUM G6:RESERVED"
ALLOK="G1:ok G2:ok G3:ok G4:ok G5:ok G6:ok"

# verdict DIR RT -> the six-token line
verdict() {
  local f g k p out=""
  f="$(findings "$1" "$2")"
  for p in $GRP_KINDS; do
    g="${p%%:*}"; k="${p#*:}"
    if printf '%s\n' "$f" | grep -q "^$k "; then out="$out $g:bad"; else out="$out $g:ok"; fi
  done
  printf '%s\n' "${out# }"
}

# ---- the report ------------------------------------------------------------

echo "=== registration: the table, the directory, and the gates that do not run ==="
ndisp="$(dispatched "$RT" | wc -l)"
nsh="$(ls -1 "$HERE"/*.sh 2>/dev/null | wc -l)"
echo "  $ndisp dispatch lines in $(basename "$RT"), $nsh scripts in $HERE"
echo "  base verdict: $(verdict "$HERE" "$RT")"

echo
echo "--- written, and NOT dispatched: these gates do not run under \`bin/chirality test\` ---"
npend=0
for f in "$HERE"/*.sh; do
  [ -f "$f" ] || continue
  declares_out "$f" || continue
  npend=$((npend+1))
  printf '  PEND  %-20s -- %s\n' "${f##*/}" "$(reason_of "$f")"
done
echo "  $npend of $nsh scripts are outside the dispatch table by their own declaration."
echo "  A PEND is neither a pass nor a failure.  It is a gate nobody is running."

echo
echo "=== the rule: every script is dispatched, or declares itself out with a reason ==="
base="$(verdict "$HERE" "$RT")"
if [ "$base" = "$ALLOK" ]; then
  ok "the directory and the dispatch table agree -- $base"
else
  bad "the directory and the dispatch table DISAGREE -- $base"
  findings "$HERE" "$RT" | sed 's/^/          /'
fi

# ---- the mutants -----------------------------------------------------------
#
# Every one runs against a COPY.  `changed` refuses a mutation that matched
# nothing, which is the first of mutant.sh:19-40's four silent failures and the
# one a text gate is most exposed to.
T="$TMP/t"; mkdir -p "$T"; cp "$HERE"/*.sh "$T/"
RTC="$TMP/rt.sh"

changed() { ! cmp -s "$1" "$2"; }

echo
echo "=== M1: delete a dispatch line and the row that reddens is not the deleted phase ==="
# ⚑ THE COUNT IS ASSERTED.  Every dispatch line in turn, and the reddened total
# must equal the number of lines the table holds.
m1_miss=""; m1_red=0; m1_want="G1:ok G2:bad G3:ok G4:ok G5:ok G6:ok"
while read -r num scr; do
  [ -n "${scr:-}" ] || continue
  esc="$(printf '%s' "$scr" | sed 's/\./\\./g')"
  sed -E "/^$RPH[[:space:]]+$num[[:space:]].*[[:space:]]$esc\$/d" "$RT" >"$RTC"
  if changed "$RT" "$RTC"; then
    v="$(verdict "$T" "$RTC")"
    if [ "$v" = "$m1_want" ]; then m1_red=$((m1_red+1)); else m1_miss="$m1_miss $scr=[$v]"; fi
  else
    m1_miss="$m1_miss $scr=unmutated"
  fi
done <<EOT
$(dispatched "$RT")
EOT
if [ -z "$m1_miss" ] && [ "$m1_red" -eq "$ndisp" ]; then
  ok "M1 unregister-a-phase -- all $ndisp dispatch lines, deleted one at a time, redden G2 and nothing else"
else
  bad "M1 unregister-a-phase -- $m1_red of $ndisp reddened G2 alone; misses:$m1_miss"
fi

echo
echo "=== M2-M7: the other five rows, each pinned on the full line ==="

# M2 a script appears on disk that the table does not name.
: >"$T/ghost.sh"
v="$(verdict "$T" "$RT")"
rm -f "$T/ghost.sh"
if [ "$v" = "G1:ok G2:bad G3:ok G4:ok G5:ok G6:ok" ]; then
  ok "M2 an-undeclared-script-appears -- G2:bad, the other five ok"
else bad "M2 an-undeclared-script-appears -- got [$v]"; fi

# M3 a declaration with its reason stripped.
victim=""
for f in "$T"/*.sh; do declares_out "$f" && { victim="$f"; break; }; done
if [ -n "$victim" ]; then
  cp "$victim" "$TMP/v.orig"
  sed -E "s|$MARK.*|$H not-a-phase:|" "$TMP/v.orig" >"$victim"
  if changed "$TMP/v.orig" "$victim"; then
    v="$(verdict "$T" "$RT")"
    if [ "$v" = "G1:ok G2:ok G3:ok G4:bad G5:ok G6:ok" ]; then
      ok "M3 strip-the-reason -- ${victim##*/} declares itself out and says nothing: G4:bad, the other five ok"
    else bad "M3 strip-the-reason -- got [$v]"; fi
  else bad "M3 strip-the-reason -- the mutation matched nothing in ${victim##*/}"; fi
  cp "$TMP/v.orig" "$victim"
else bad "M3 strip-the-reason -- no declared-out script to mutate; the PEND report is vacuous"; fi

# M4 a dispatched script that also declares itself out.
first="$(dispatched "$RT" | awk 'NR==1{print $2}')"
if [ -n "$first" ] && [ -f "$T/$first" ]; then
  cp "$T/$first" "$TMP/f.orig"
  { head -1 "$TMP/f.orig"; printf '%s not-a-phase: a mutant claim\n' "$H"; tail -n +2 "$TMP/f.orig"; } >"$T/$first"
  if changed "$TMP/f.orig" "$T/$first"; then
    v="$(verdict "$T" "$RT")"
    if [ "$v" = "G1:ok G2:ok G3:bad G4:ok G5:ok G6:ok" ]; then
      ok "M4 dispatched-and-declared-out -- $first cannot be both: G3:bad, the other five ok"
    else bad "M4 dispatched-and-declared-out -- got [$v]"; fi
  else bad "M4 dispatched-and-declared-out -- the mutation matched nothing"; fi
  cp "$TMP/f.orig" "$T/$first"
else bad "M4 dispatched-and-declared-out -- the table named no first script"; fi

# M5 one phase number, dispatched twice.
dupnum="$(dispatched "$RT" | awk 'NR==1{print $1}')"
dupscr="$(dispatched "$RT" | awk 'NR==2{print $2}')"
cp "$RT" "$RTC"
printf '%s %s "a mutant duplicate" %s\n' "$RPH" "$dupnum" "$dupscr" >>"$RTC"
if changed "$RT" "$RTC"; then
  v="$(verdict "$T" "$RTC")"
  if [ "$v" = "G1:ok G2:ok G3:ok G4:ok G5:bad G6:ok" ]; then
    ok "M5 one-number-twice -- phase $dupnum dispatched twice: G5:bad, the other five ok"
  else bad "M5 one-number-twice -- got [$v]"; fi
else bad "M5 one-number-twice -- the append changed nothing"; fi

# M6 a dispatch line naming a script that is not there.
cp "$RT" "$RTC"
printf '%s 99 "a mutant ghost" no-such-gate.sh\n' "$RPH" >>"$RTC"
if changed "$RT" "$RTC"; then
  v="$(verdict "$T" "$RTC")"
  if [ "$v" = "G1:bad G2:ok G3:ok G4:ok G5:ok G6:ok" ]; then
    ok "M6 dispatch-a-missing-script -- G1:bad, the other five ok"
  else bad "M6 dispatch-a-missing-script -- got [$v]"; fi
else bad "M6 dispatch-a-missing-script -- the append changed nothing"; fi

# M7 the reserved band, taken.  tal-check.sh claims Phase 22 in its own header
# (tools/test/tal-check.sh:3) and is declared out, so registering it there is
# both trespasses at once and the pin says so.
cp "$RT" "$RTC"
printf '%s 22 "a mutant registration" tal-check.sh\n' "$RPH" >>"$RTC"
if changed "$RT" "$RTC"; then
  v="$(verdict "$T" "$RTC")"
  if [ "$v" = "G1:ok G2:ok G3:bad G4:ok G5:ok G6:bad" ]; then
    ok "M7 take-the-reserved-band -- registering tal-check.sh at 22: G6:bad and G3:bad, the other four ok"
  else bad "M7 take-the-reserved-band -- got [$v]"; fi
else bad "M7 take-the-reserved-band -- the append changed nothing"; fi

# ---- the base line is still green after every mutant restored ---------------
if [ "$(verdict "$T" "$RT")" = "$ALLOK" ]; then
  ok "the copied tree is ALLOK again -- no mutant leaked into the base"
else bad "a mutant leaked: the copied tree reads [$(verdict "$T" "$RT")]"; fi

echo
echo "registration: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
