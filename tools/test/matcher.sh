#!/usr/bin/env bash
# matcher.sh -- E173 slice 1: the total matcher over `Str`. The Phase 19 gate.
#
# PHASE 19, and 19 for the reason 18 was 18 and 17 was 17: 8-12 are names still
# OWED to unported old-tree phases (run-tests.sh:18-22), and reusing one would
# make an unported gate look ported. 13-18 are taken.
#
# ─── WHAT THIS ELEMENT IS, AND WHAT IT IS GRADED ON ─────────────────────────
#
# `lib/text/matcher.chiral` -- a total, pure, span-returning matcher over
# Antimirov partial derivatives. `pd` is the algorithm, `norm` is the line the
# state-set bound lives in, and `find-all` is one pass over the input whose live
# set carries each thread's start offset. `prog/prose-lint.prog` is its first
# consumer and the differential rows grade it against the awk tool it replaces.
#
# ⚑ THE MUTANT HARNESS IS NOT tools/test/mutant.sh. That one mutates a file,
# rebuilds `prog/compiler.prog`'s blob and asserts the mutant compiler DIFFERS
# (`mutant_differs`, tools/test/mutant.sh:125). G8 below measures that
# `text/matcher` is OUTSIDE that closure, so every mutation of it builds a
# byte-identical compiler and that harness would score all twelve INERT. The
# mechanism for a module outside the closure is Phase 17's: a scratch `lib/`
# copied with `cp -a`, mutated with `sed -i`, refused when the mutation changed
# nothing, and the fixture compiled against that tree.
#
# ⚑ EVERY MUTANT PINS THE FULL VERDICT LINE, not just "some row went red". A
# mutant that reddens a row it was not paired with is then impossible to miss
# rather than merely unlikely. `verdict` prints all eleven value rows at once.
#
# ⚑ M3 IS THE TERMINATION MUTANT AND THE COMPILER REFUSES IT NOTHING. A `pd`
# whose `p-star` arm recurses into `(p-star q)` instead of rebuilding it in the
# result does not terminate, and `chirality check` answers OK on it -- MEASURED,
# and the cause is recorded: `lib/typing/totality.chiral` is the built E11
# classifier and no module imports it, so termination is neither enforced nor
# classified in the built compiler (docs/definitions/status-ledger.md:157).
# Wiring it is E11's remaining work. Until then a row asserting a refusal here
# would pass by looking at nothing, so G10 OBSERVES the divergence instead: the
# fixture is run under an 8 MB stack and a 20 s timeout, and the base tree
# reaching its sentinel under the same limits is the control that keeps the
# observation from being an artifact of the limit.
#
#   G1   `cls-has` at both edges of every class constant           [M6]
#   G2   `nullable` over all seven `Pat` arms, two windows      [M1,M8]
#   G3   the bound holds: the live set stays at ‖pat‖ + 1      [M2,M12]
#   G4   the bound is `norm`'s, not the input's                [M2,M12]
#   G6a  `norm`'s survivor is the LEAST start, in any order     [M5,M2,M12]
#   G6b  leftmost-longest over overlapping alternatives          [M4-adjacent]
#   G6c  the spans of one pass do not overlap                     [M9]
#   G6d  `find-at` keeps the LONGEST accept, not the first        [M4]
#   G7a  the kept lines ARE awk's kept lines, differentially       [-]
#   G7b  and they are the hand-derived set                         [-]
#   G7c  `blank-spans` preserves length                           [M7]
#   G5   the eight checks agree with awk on a written fixture     [M11]
#   G8   `text/matcher` is OUTSIDE prog/compiler.prog's closure   [M10]
#   G9   the eight checks agree with awk over the CORPUS          [M11]
#   G10  the `p-star` residual terminates                          [M3]
#
# ⚑ G9 RUNS THROUGH `prose-lint --summary`, AND THE PATH IS THE ROW. The awk
# tool carries TWO divergent check sets: `_scan` (prose-lint.sh:95-104), ten
# `gsub` checks, which is what `--summary` / `--worklist` / `--baseline` /
# `--regress` read; and `cmd_lines` (:164), one hand-merged alternation used by
# the bare `prose-lint PATH...` per-line form, which omits `parallel-no` outright
# plus four other alternatives. Over the 80 files below the native tool and
# `--summary` agree EXACTLY (em-dash 906, antithesis 392, copula-negation 159,
# parallel-no 8) while the per-line form reports 1457 against 1465. A gate
# pointed at the per-line form would fail on an awk reporter defect, and
# "fixing" the native tool to match would reproduce that defect.
#
# ⚑ WHAT THIS GATE DOES NOT GRADE. `self-reference` and `first-person` are the
# awk tool's other two checks; `prog/prose-lint.prog` prints them as NOT-CHECKED
# and the differential covers eight of ten and says so. The wall clock is
# RECORDED, not gated: no run in this tree has measured the ratio and a
# threshold taken from no run blocks a correct implementation for a reason
# unrelated to correctness.
#
# Zero Python -- the comparisons are shell and awk, here as everywhere.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"

CC="${CHIRALITY_COMPILE:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
[ -x "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
# shellcheck disable=SC1091
. "$REPO/bin/chirality-resolve.sh"

FIXTURE="$HERE/samples/e173_matcher.prog"
MATCHER="$REPO/lib/text/matcher.chiral"
LINT="$REPO/prog/prose-lint.prog"
AWKLINT="$REPO/tools/prose-lint/prose-lint.sh"
for f in "$FIXTURE" "$MATCHER" "$LINT" "$AWKLINT"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its fixture cannot fail"; exit 2; }
done
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# ---- build and run ---------------------------------------------------------
# The compile always gets an unlimited stack; the RUN is where the two forms
# differ, and G10 is the reason they are separate.
build_elf() {  # build_elf LIBDIR SRC ELF -> 0 when the program compiled
  local lib="$1" src="$2" elf="$3" blob="$TMP/b.blob"
  ( cd "$REPO" && chirality_blob_file "$lib:$REPO/prog" "$src" ) >"$blob" 2>/dev/null || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
}

build_raw() {  # build_raw LIBDIR SRC OUT -> 0 and OUT holds the raw STDOUT
  local lib="$1" src="$2" out="$3" elf="$TMP/o.elf"
  build_elf "$lib" "$src" "$elf" || return 1
  ( ulimit -s unlimited; "$elf" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ]
}

# An 8 MB stack and a wall-clock ceiling. A non-terminating `pd` dies inside
# both instead of taking the machine with it, and a program that finishes has
# room to spare: the fixture's deepest recursion is 101 frames.
#
# ⚑ THE SUBSHELL'S OWN STDERR IS DISCARDED, and only here. A child killed by a
# signal makes the shell print `Segmentation fault` on ITS stderr, in the middle
# of the gate's output, where it reads as the gate breaking rather than as the
# mutant dying on cue. The exit status is kept and reported instead.
RUNRC=0
build_run_bounded() {  # build_run_bounded LIBDIR SRC OUT -> 0 when it COMPLETED
  local lib="$1" src="$2" out="$3" elf="$TMP/bd.elf"
  RUNRC=0
  build_elf "$lib" "$src" "$elf" || return 2      # 2: it did not even compile
  { ( ulimit -s 8192; timeout 20 "$elf" >"$out" 2>/dev/null ); } 2>/dev/null
  RUNRC=$?
  [ "$RUNRC" -eq 0 ] || return 1
  [ -s "$out" ]
}

# mutlib NAME REPO-REL-PATH SED-EXPR... -> a scratch copy of lib/ with that file
# mutated, left in $MUTLIB. A mutation that does not apply is a mutant that
# proves nothing, so a stale pattern is REPORTED rather than silently passing.
#
# ⚑ THE SCRATCH lib/ MUST BE A REAL DIRECTORY, NEVER A SYMLINK. `cp -a` copies a
# symlink AS a symlink and every subsequent `sed -i` then writes THROUGH it into
# the tree under test -- nineteen phantom failures, measured, in the arc that
# built this helper (tools/test/render-doc.sh:131-145). Checked, not remembered.
MUTLIB=""
mutlib() {
  local name="$1" rel="$2"; shift 2
  MUTLIB="$TMP/mutlib"; rm -rf "$MUTLIB"; cp -a "$REPO/lib" "$MUTLIB"
  if [ -L "$MUTLIB" ]; then
    bad "$name -- the scratch lib/ is a SYMLINK; every sed would write into the tree under test"; return 1
  fi
  local target="$MUTLIB/${rel#lib/}" e
  for e in "$@"; do
    sed -i "$e" "$target" || { bad "$name -- sed failed"; return 1; }
  done
  if cmp -s "$target" "$REPO/$rel"; then
    bad "$name -- the mutation did not change $rel (stale pattern)"; return 1
  fi
  return 0
}

# mutprog NAME REPO-REL-PATH SED-EXPR... -> the ENTRY file copied beside the
# tree and mutated, left in $MUTPROG. `prog/prose-lint.prog` is not under lib/,
# so mutlib cannot reach it; the refusal on a no-op sed is the same.
MUTPROG=""
mutprog() {
  local name="$1" rel="$2"; shift 2
  MUTPROG="$TMP/$(basename "$rel")"
  cp "$REPO/$rel" "$MUTPROG"
  local e
  for e in "$@"; do
    sed -i "$e" "$MUTPROG" || { bad "$name -- sed failed"; return 1; }
  done
  if cmp -s "$MUTPROG" "$REPO/$rel"; then
    bad "$name -- the mutation did not change $rel (stale pattern)"; return 1
  fi
  return 0
}

# fld N FILE -> the Nth byte-1-separated field of FILE, verbatim.
fld() { LC_ALL=C awk -v n="$1" 'BEGIN{RS="\1"} NR==n{printf "%s",$0}' "$2"; }

# ============================================================================
# THE VALUE ROWS. `verdict LIBDIR` -> one line of eleven `name:ok` / `name:bad`
# tokens, or `BUILD:fail`. Every mutant below pins this line IN FULL.
#
# Every expected value is HAND-DERIVED from what the program MEANS -- rank 3 of
# docs/definitions/testing-floors.md -- and none of them is a capture of what
# the code printed.
#
#   G1  lower 96/97/122/123 · digit 47/48/57/58 · word 64/65/90/91/95/96, then
#       byte 194 (a UTF-8 lead byte) against lower, digit, word and c-any.
#   G2  seven `Pat` arms in window (-1,'B') then in ('A',10). The FIRST window
#       is off the front of the buffer, which is a-bol's offset-0 reading and
#       the only one that distinguishes it from "prev is a newline".
#   G3  `(p-star (p-cls cls-lower))` over 100 lower bytes: ‖pat‖ + 1 = 2.
#   G4  the same input with `norm` skipped: one thread may start at every
#       offset and none of them merges, so the live set reaches 101.
#   G6a `(norm [th 1 P, th 0 P])` is `[th 0 P]`: one survivor, the LEAST start,
#       from a list handed to `norm` in the opposite order.
#   G6b `alt("ab","abc")` over "xabc" -> 1-4: earliest start, longest end.
#   G6c `"aa"` over "aaaa" -> 0-2,2-4 and NOT 0-2,1-3,2-4.
#   G6d `find-at alt("ab","abc") "abc" 0` -> 0-3, the longer accept.
#   G7a/b the nine-line fixture: prose, a fence pair, prose, an INDENTED and
#       info-stringed fence pair, and an inline-span line -> 100010001, and the
#       same answer read off awk's own fence toggle over the same bytes.
#   G7c `blank-spans` over a 24-byte line with an 8-byte span: 24 bytes out.
G1="011001100110100001"
G2="10011111000001"
G3="2"
G6A="1:0"
G6B="1-4"
G6C="0-2,2-4"
G6D="0-3"
G7B="100010001"
G7C="text with          in it"
G7SRC="text with \`a span\` in it"

# awk's kept-line set over the same bytes: 1 for a line it counts, 0 for a line
# it skips. This is prose-lint.sh:89-91's toggle, nothing else.
FENCE_AWK='
  FNR == 1 { fence = 0 }
  /^[ \t]*```/ { printf "0"; fence = !fence; next }
  fence { printf "0"; next }
  { printf "1" }'

verdict() {
  local lib="$1" raw="$TMP/v.raw" out="" g3 g4
  build_raw "$lib" "$FIXTURE" "$raw" || { echo "BUILD:fail"; return; }
  add() { out="$out${out:+ }$1:$2"; }
  eq()  { if [ "$2" = "$3" ]; then add "$1" ok; else add "$1" bad; fi; }

  eq G1  "$(fld 1 "$raw")" "$G1"
  eq G2  "$(fld 2 "$raw")" "$G2"
  eq G3  "$(fld 3 "$raw")" "$G3"
  # G4 is a COMPARISON and not a pin: it says the bound G3 reports is `norm`'s
  # doing. Neuter `norm` and the two numbers become the same one, which is the
  # only reading under which G3 could hold for a reason other than the one it
  # claims.
  g3="$(fld 3 "$raw")"; g4="$(fld 4 "$raw")"
  case "$g3$g4" in
    *[!0-9]*) add G4 bad ;;
    *) if [ "$g4" -gt "$g3" ]; then add G4 ok; else add G4 bad; fi ;;
  esac
  eq G6a "$(fld 5 "$raw")" "$G6A"
  eq G6b "$(fld 6 "$raw")" "$G6B"
  eq G6c "$(fld 7 "$raw")" "$G6C"
  eq G6d "$(fld 8 "$raw")" "$G6D"
  # G7a -- the DIFFERENTIAL. The fixture prints the text it scanned, so awk is
  # handed the same bytes rather than a second spelling of them.
  fld 9 "$raw" >"$TMP/v.lines"; printf '\n' >>"$TMP/v.lines"
  eq G7a "$(LC_ALL=C awk "$FENCE_AWK" "$TMP/v.lines")" "$(fld 10 "$raw")"
  eq G7b "$(fld 10 "$raw")" "$G7B"
  # G7c -- length preservation is the property, so both halves are asserted:
  # the bytes, and that there are as many of them as went in.
  if [ "$(fld 11 "$raw")" = "$G7C" ] && [ "${#G7C}" -eq "${#G7SRC}" ]; then
    add G7c ok; else add G7c bad; fi
  echo "$out"
}

ALLOK="G1:ok G2:ok G3:ok G4:ok G6a:ok G6b:ok G6c:ok G6d:ok G7a:ok G7b:ok G7c:ok"

# ============================================================================
echo
echo "=== E173 G1-G7: the fixture, on the real tree -- eleven rows in one line ==="
BASE="$(verdict "$REPO/lib")"
if [ "$BASE" = "$ALLOK" ]; then
  ok "all eleven value rows hold: $BASE"
else
  bad "the value rows do NOT all hold"
  echo "          got:  $BASE"
  echo "          want: $ALLOK"
fi

# The measured values, printed once, because a gate that only reports ok/bad
# about a live set makes that live set unreadable to whoever has to fix it.
if build_raw "$REPO/lib" "$FIXTURE" "$TMP/b.raw"; then
  printf '          %-28s %s\n' \
    "class edges (G1)"        "$(fld 1 "$TMP/b.raw")" \
    "nullable, 2 windows (G2)" "$(fld 2 "$TMP/b.raw")" \
    "live set, normed (G3)"   "$(fld 3 "$TMP/b.raw")" \
    "live set, raw (G4)"      "$(fld 4 "$TMP/b.raw")" \
    "norm survivor (G6a)"     "$(fld 5 "$TMP/b.raw")" \
    "leftmost-longest (G6b)"  "$(fld 6 "$TMP/b.raw")" \
    "non-overlap (G6c)"       "$(fld 7 "$TMP/b.raw")" \
    "find-at longest (G6d)"   "$(fld 8 "$TMP/b.raw")" \
    "lines kept (G7b)"        "$(fld 10 "$TMP/b.raw")" \
    "blank-spans (G7c)"       "[$(fld 11 "$TMP/b.raw")]"
fi

# ============================================================================
# Each mutant names ONE corruption and pins the WHOLE verdict line it must
# produce. A mutant that reddens a row it was not paired with is caught by the
# same assertion that catches one that reddens nothing.
echo
echo "=== E173 the named mutants (a row whose mutant passes exercises nothing) ==="
mutant() {  # mutant NAME WANT-VERDICT REPO-REL-PATH SED-EXPR...
  local name="$1" want="$2" rel="$3"; shift 3
  mutlib "$name" "$rel" "$@" || return
  local got; got="$(verdict "$MUTLIB")"
  if [ "$got" = "$want" ]; then ok "$name -- $(echo "$got" | tr ' ' '\n' | grep -c ':bad') row(s) red, exactly the pinned ones"
  else
    bad "$name -- the verdict is not the pinned one"
    echo "          got:  $got"
    echo "          want: $want"
  fi
}

# M1 (G2) -- `a-bol` KEEPS ONLY ITS NEWLINE CASE. Offset 0 of a buffer has no
# previous byte, which `at-byte` reads as -1; drop that disjunct and a pattern
# anchored at the start of the input can never fire. Three of G2's fourteen bits
# are the assertion, and every one of them is in the OFF-THE-FRONT window.
mutant "M1 a-bol-loses-offset-0 (only a preceding newline counts)" \
  "G1:ok G2:bad G3:ok G4:ok G6a:ok G6b:ok G6c:ok G6d:ok G7a:ok G7b:ok G7c:ok" \
  lib/text/matcher.chiral \
  's|((a-bol) (or (<i p 0) (=i p 10)))|((a-bol) (=i p 10))|'

# M2 (G3/G4/G6a) -- `norm` BECOMES THE IDENTITY. The matcher is then a
# backtracker wearing a set: nothing merges, the live set grows with the offset,
# and the two numbers G4 compares become the same number. G6a goes with them
# because the survivor of a list nothing dedups is the whole list.
mutant "M2 norm-is-the-identity (the state set stops being a set)" \
  "G1:ok G2:ok G3:bad G4:bad G6a:bad G6b:ok G6c:ok G6d:ok G7a:ok G7b:ok G7c:ok" \
  lib/text/matcher.chiral \
  's|    (list-dedup-adj Thread thread-cmp (list-sort Thread thread-key-cmp ts))))|    ts))|'

# M4 (G6d) -- `run-from` KEEPS THE FIRST ACCEPT. `find-at` is longest-match by
# overwriting `best` at every accepting offset; keep the earliest instead and
# `alt("ab","abc")` answers with the shorter arm. Nothing else moves: `find-all`
# has its own driver and does not go through `run-from`.
mutant "M4 find-at-keeps-the-first-accept (longest becomes shortest)" \
  "G1:ok G2:ok G3:ok G4:ok G6a:ok G6b:ok G6c:ok G6d:bad G7a:ok G7b:ok G7c:ok" \
  lib/text/matcher.chiral \
  's|(case (accepts k ts) (true (some i)) (false best))|(case (accepts k ts) (true (case best (none (some i)) ((some g) (some g)))) (false best))|'

# M5 (G6a) -- THE SORT KEY LOSES ITS `from` HALF and answers what the DEDUP key
# answers. `list-sort` is stable, so a list arriving as [th 1, th 0] keeps that
# order, `list-dedup-adj` keeps the head, and the survivor is the LATER start.
# ⚑ The bound is untouched -- G3 and G4 both stay green -- which is why this and
# M12 are two mutants and not one.
mutant "M5 sort-key-drops-from (the survivor stops being the least start)" \
  "G1:ok G2:ok G3:ok G4:ok G6a:bad G6b:ok G6c:ok G6d:ok G7a:ok G7b:ok G7c:ok" \
  lib/text/matcher.chiral \
  's|(ord-then (pat-cmp pa pb) (i64-cmp fa fb))|(pat-cmp pa pb)|'

# M6 (G1) -- `c-range` GOES HALF-OPEN AT THE TOP. The classic off-by-one, and it
# is invisible to everything except a probe that asks about the edge byte
# itself: 'a' is still lower, 'z' is not.
mutant "M6 c-range-excludes-its-high-edge (<i where <=i is meant)" \
  "G1:bad G2:ok G3:ok G4:ok G6a:ok G6b:ok G6c:ok G6d:ok G7a:ok G7b:ok G7c:ok" \
  lib/text/matcher.chiral \
  's|(and (<=i lo b) (<=i b hi))|(and (<=i lo b) (<i b hi))|'

# M7 (G7c) -- `blank-spans` DELETES THE SPAN instead of blanking it, which is
# what the awk baseline does at prose-lint.sh:93. The line shortens, so every
# offset after the span is wrong on the original text, and the two sides of the
# span can glue into a match the source never held.
mutant "M7 blank-spans-deletes (the offsets after a span stop being valid)" \
  "G1:ok G2:ok G3:ok G4:ok G6a:ok G6b:ok G6c:ok G6d:ok G7a:ok G7b:ok G7c:bad" \
  lib/text/matcher.chiral \
  's|(str-cat acc (ls-spaces (+ (str-len t) 1)))|acc|'

# M8 (G2) -- `nullable` DENIES THE STAR. Zero repetitions is exactly what a star
# accepts, and the arm is one word; both of G2's star bits are the assertion.
mutant "M8 nullable-denies-the-star (zero repetitions stops accepting)" \
  "G1:ok G2:bad G3:ok G4:ok G6a:ok G6b:ok G6c:ok G6d:ok G7a:ok G7b:ok G7c:ok" \
  lib/text/matcher.chiral \
  's|((p-star q)  true)|((p-star q)  false)|'

# M9 (G6c) -- THE PASS STOPS RESUMING AT A MATCH'S END. `th-since` is what
# retires the threads that started inside a committed span; without it "aaaa"
# reports 0-2,1-3,2-4 -- three OVERLAPPING spans where awk's `gsub` counts two.
mutant "M9 find-all-reports-overlaps (th-since stops retiring threads)" \
  "G1:ok G2:ok G3:ok G4:ok G6a:ok G6b:ok G6c:bad G6d:ok G7a:ok G7b:ok G7c:ok" \
  lib/text/matcher.chiral \
  's|(th-since t ts2)|ts2|'

# M12 (G3/G4/G6a) -- THE DEDUP KEY GAINS `from`. One thread then survives per
# (pat, from) PAIR instead of per residual, so the live set grows with the
# offset and the Antimirov bound is gone -- while every span the matcher returns
# is still correct. ⚑ This is the mutant that says G3 is a real row: a gate that
# only checked answers would ship this.
mutant "M12 dedup-key-gains-from (one thread per pair, not per residual)" \
  "G1:ok G2:ok G3:bad G4:bad G6a:bad G6b:ok G6c:ok G6d:ok G7a:ok G7b:ok G7c:ok" \
  lib/text/matcher.chiral \
  's|(case b ((th fb pb) (pat-cmp pa pb)))|(case b ((th fb pb) (ord-then (pat-cmp pa pb) (i64-cmp fa fb))))|'

# ============================================================================
# G10 -- THE STAR TERMINATES, OBSERVED RATHER THAN REFUSED.
echo
echo "=== E173 G10: the p-star residual terminates (E11 is unwired, so this is measured) ==="
g10rc=0
build_run_bounded "$REPO/lib" "$FIXTURE" "$TMP/g10.out" || g10rc=$?
if [ "$g10rc" -eq 0 ] && [ "$(fld 12 "$TMP/g10.out")" = "END" ]; then
  ok "G10 control -- the fixture reaches its sentinel under an 8 MB stack and a 20 s ceiling"
else
  bad "G10 control -- the fixture did NOT complete under the bounded limits (rc $g10rc); every M3 reading below is an artifact of the limit, not of the mutation"
fi

# M3: the `p-star` arm recurses into `(p-star q)` instead of rebuilding it in
# the result. ⚑ THE COMPILER ACCEPTS THIS. The row asserts two things in order,
# because the first is the finding: the mutant COMPILES CLEAN, and only the RUN
# diverges. `lib/typing/totality.chiral` is imported by nothing
# (status-ledger.md:157), so no static row here could be anything but green.
if mutlib "M3 pd-star-recurses-into-itself" lib/text/matcher.chiral \
     's|((p-star q) (pd-cat (pd k b q) (p-star q))))))|((p-star q) (pd-cat (pd k b (p-star q)) (p-star q))))))|'; then
  if build_elf "$MUTLIB" "$FIXTURE" "$TMP/m3.elf"; then
    ok "M3 compiles clean -- the built compiler classifies no termination (E11 unwired)"
  else
    bad "M3 did NOT compile -- something now refuses it, and status-ledger.md:157 is stale"
  fi
  m3rc=0
  build_run_bounded "$MUTLIB" "$FIXTURE" "$TMP/m3.out" || m3rc=$?
  if [ "$m3rc" -eq 1 ] && [ "$(fld 12 "$TMP/m3.out")" != "END" ]; then
    ok "M3 pd-star-recurses-into-itself -- the run diverges: exit $RUNRC (128+11 is the stack it overran), no sentinel, $(wc -c <"$TMP/m3.out") bytes emitted before it died"
  else
    bad "M3 pd-star-recurses-into-itself -- the mutant COMPLETED (rc $m3rc); G10 asserts a termination nothing here depends on"
  fi
fi

# ============================================================================
# G5 / G9 -- THE DIFFERENTIAL. `prog/prose-lint.prog` against the awk tool it
# replaces, on the SAME inputs, in the same invocation, with both live.
# .planning/PROSE-BASELINE.tsv is frozen at counts that predate a consolidation
# which moved three paths, so a gate against those numbers would be measuring a
# corpus that no longer exists.
CHECKS="em-dash antithesis copula-negation not-but parallel-no slop-word throat-clearing connective"

# native_totals ELF FILELIST -> "check<TAB>count" for the eight, zeros filled
native_totals() {
  local elf="$1" list="$2"
  ( ulimit -s unlimited; "$elf" <"$list" 2>/dev/null ) \
    | LC_ALL=C awk -F'\t' -v ks="$CHECKS" '
        $1 != "TOTAL" && $1 != "NOT-CHECKED" { h[$2] += $3 }
        END { n = split(ks, k, " "); for (i = 1; i <= n; i++) printf "%s\t%d\n", k[i], h[k[i]] + 0 }'
}

# awk_totals SCOPE... -> the same shape, read off `prose-lint --summary`, which
# is the reporting path fed by _scan (prose-lint.sh:86-113). NOT the per-line
# form: that one runs a separately maintained alternation missing five branches.
awk_totals() {
  "$AWKLINT" --summary "$@" 2>/dev/null \
    | LC_ALL=C awk -v ks="$CHECKS" '
        NR > 1 { h[$1] = $2 }
        END { n = split(ks, k, " "); for (i = 1; i <= n; i++) printf "%s\t%d\n", k[i], h[k[i]] + 0 }'
}

# The written fixture: every one of the eight checks fires, a fenced block whose
# contents would score if it were prose, and an inline span. The two tools blank
# a span differently by design (M7's comment), so the span here carries no hit.
cat >"$TMP/e173_fixture.md" <<'FIX'
An em-dash — sits here, and another — there.
This is a sentence, not a claim.
It ends there, never a moment later.
It is not just a claim.
This is not entirely but mostly true.
no alpha, no beta, no gamma
Delve into the tapestry of seamless showcase, testament to a plethora of myriad pivotal work.
It is worth noting that in essence at its core in other words this is filler.
Furthermore, Moreover, this line is Additionally, done.

```
code — that would score, and never does, because it is code
```

A line with `a span` and `another one` in it.
FIX

echo
echo "=== E173 G5: the eight checks agree with awk on a written fixture ==="
if build_elf "$REPO/lib" "$LINT" "$TMP/lint.elf"; then
  echo "$TMP/e173_fixture.md" >"$TMP/one.list"
  native_totals "$TMP/lint.elf" "$TMP/one.list" >"$TMP/g5.nat"
  awk_totals "$TMP/e173_fixture.md" >"$TMP/g5.awk"
  if cmp -s "$TMP/g5.nat" "$TMP/g5.awk"; then
    ok "G5 -- eight of the awk tool's ten checks agree exactly on the fixture"
    paste "$TMP/g5.nat" | sed 's/^/          /'
  else
    bad "G5 -- the fixture totals disagree:"; diff "$TMP/g5.awk" "$TMP/g5.nat" | sed 's/^/          /'
  fi
else
  bad "G5 -- prog/prose-lint.prog did not build against the real tree"
fi

echo
echo "=== E173 G9: the same eight checks over the corpus, through prose-lint --summary ==="
CORPUS="docs/arcs docs/decisions docs/definitions"
( cd "$REPO" && for d in $CORPUS; do find "$d" -type f -name '*.md'; done ) >"$TMP/corpus.list"
ncorp="$(grep -c . "$TMP/corpus.list")"
if [ "$ncorp" -lt 40 ]; then
  bad "G9 -- the corpus is $ncorp files; a differential over almost nothing agrees for free"
elif [ -s "$TMP/lint.elf" ]; then
  native_totals "$TMP/lint.elf" "$TMP/corpus.list" >"$TMP/g9.nat"
  ( cd "$REPO" && "$AWKLINT" --summary $CORPUS 2>/dev/null ) \
    | LC_ALL=C awk -v ks="$CHECKS" '
        NR > 1 { h[$1] = $2 }
        END { n = split(ks, k, " "); for (i = 1; i <= n; i++) printf "%s\t%d\n", k[i], h[k[i]] + 0 }' >"$TMP/g9.awk"
  if cmp -s "$TMP/g9.nat" "$TMP/g9.awk"; then
    ok "G9 -- the eight agree exactly over $ncorp files"
    grep -v '	0$' "$TMP/g9.nat" | sed 's/^/          /'
  else
    bad "G9 -- the corpus totals disagree over $ncorp files:"
    diff "$TMP/g9.awk" "$TMP/g9.nat" | sed 's/^/          /'
  fi
else
  bad "G9 -- prog/prose-lint.prog did not build; the differential ran over nothing"
fi

# M11: one needle leaves a check's `p-alt` tree. `never` is an arm of
# `p-anti-kw`, it scores on this corpus, and dropping it must move BOTH the
# fixture row and the corpus row. Without this mutant the two differentials are
# asserting that two tools which agree on zero differences agree.
if mutprog "M11 drop-a-needle-from-a-check" prog/prose-lint.prog \
     's|(p-alt (p-lit "not") (p-alt (p-lit "never") (p-lit "rather than")))|(p-alt (p-lit "not") (p-lit "rather than"))|'; then
  if build_elf "$REPO/lib" "$MUTPROG" "$TMP/m11.elf"; then
    native_totals "$TMP/m11.elf" "$TMP/one.list"    >"$TMP/m11.g5"
    native_totals "$TMP/m11.elf" "$TMP/corpus.list" >"$TMP/m11.g9"
    m11g5=ok; m11g9=ok
    cmp -s "$TMP/m11.g5" "$TMP/g5.awk" && m11g5=INERT
    cmp -s "$TMP/m11.g9" "$TMP/g9.awk" && m11g9=INERT
    if [ "$m11g5" = ok ] && [ "$m11g9" = ok ]; then
      ok "M11 drop-a-needle-from-a-check -- G5 and G9 both go red ($(diff "$TMP/g9.awk" "$TMP/m11.g9" | grep -c '^>') check moved on the corpus)"
    else
      bad "M11 drop-a-needle-from-a-check -- G5:$m11g5 G9:$m11g9; a differential that a missing needle cannot move is measuring nothing"
    fi
  else
    bad "M11 -- the mutated prog/prose-lint.prog did not build"
  fi
fi

# ============================================================================
# THE BUILD RULE, AS A ROW. `text/matcher` is imported by `prog/prose-lint.prog`
# and by nothing inside `prog/compiler.prog`'s import closure, which is what
# says no self-hosting fixpoint is owed for this element. "Outside the closure"
# is exactly the kind of claim that is true when written and false three commits
# later, so it is measured here rather than asserted in a comment.
echo
echo "=== E173 G8: text/matcher is OUTSIDE prog/compiler.prog's blob closure ==="
# Assembled, so this row cannot match its own source line.
NEEDLE="(data ""Cls ()"
blob_has() {  # blob_has LIBDIR -> 1 when the compiler blob contains the matcher
  ( cd "$REPO" && chirality_blob_file "$1:$REPO/prog" prog/compiler.prog ) 2>/dev/null \
    | grep -c -F -- "$NEEDLE"
}
if [ "$(blob_has "$REPO/lib")" -eq 0 ]; then
  ok "prog/compiler.prog's blob does not contain text/matcher -- no promotion, no byte-compare owed"
else
  bad "text/matcher IS in the compiler blob -- this element now carries a self-hosting cmp"
fi

# M10: put the import in, and the scan must SEE it. Without this row the scan
# passes on a needle that matches nothing anywhere -- which is what it would do
# if the module were ever renamed.
if mutlib "M10 import-the-matcher-into-the-compiler" lib/typing/diag.chiral \
     's|^(import "prelude/doc")|(import "prelude/doc")\n(import "text/matcher")|'; then
  if [ "$(blob_has "$MUTLIB")" -ge 1 ]; then
    ok "M10 import-the-matcher-into-the-compiler -- the closure scan sees it arrive"
  else
    bad "M10 import-the-matcher-into-the-compiler -- the closure scan is blind; it would pass on any needle"
  fi
fi

echo
echo "the total matcher (E173 pd + norm): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
