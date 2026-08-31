#!/usr/bin/env bash
# test-syscall-manifest.sh -- E76 (H7/H8): the syscall manifest is LOAD-BEARING.
#
# E76 closed the syscall surface by default-deny at ONE enforced chokepoint
# (docs/decision-syscall-governance.md). The chokepoint itself (lib/sys-check.chiral)
# was built, but its verdict was computed and thrown away: `checked-sys-lib` had one
# definition site and zero uses, and its only enforcement was a Python test the
# build never runs. H7 moved the REFUSAL into the emit gate (compile-emit.chiral's
# `emit-elf-m`); H8 narrowed it per-program against the profile's frozen port set.
#
# Two bindings, tested here as they are enforced:
#
#   H7 (registry, every program).  Every `ti-sys` in the WHOLE emitted image must
#   name a function registered in the swappable target registry (lib/target-linux.chiral)
#   with a MATCHING number. Tested by POISONING the registry -- in the compiler's own
#   blob, never in the tree -- and showing the compiler built from it refuses to emit.
#
#   H8 (profile, per-program).  A program declaring `(profile ...)` may only call
#   the crossings its frozen port set names. Two profiles over the same body give
#   two verdicts; that is the whole point of a manifest.
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
. "$REPO/bin/chirality-resolve.sh"

pass=0; fail=0
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
ulimit -s unlimited

# ---- H8 harness: compile a source with `chirality compile`, then RUN the result ---
# want-exit is the COMPILER's exit (0 = emitted, 1 = refused); want-run, when
# given, is what the emitted program must exit with.
prof() {
  local desc="$1" want="$2" want_msg="$3" want_run="$4" src="$5"
  local n=$((pass+fail)); local f="$T/p$n.chiral" out got
  printf '%s' "$src" > "$f"
  out="$(ORIG_DIR="$T" "$CHIR" compile "$f" -o "$T/p$n.elf" 2>&1)"; got=$?
  if [ "$got" != "$want" ]; then
    echo "  FAIL  $desc -- compiler exit $got, want $want: $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"
    fail=$((fail+1)); return
  fi
  if [ -n "$want_msg" ] && ! printf '%s' "$out" | grep -q -- "$want_msg"; then
    echo "  FAIL  $desc -- exit $got ok but message lacks '$want_msg': $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"
    fail=$((fail+1)); return
  fi
  if [ -n "$want_run" ]; then
    "$T/p$n.elf" >/dev/null 2>&1; local rr=$?
    if [ "$rr" != "$want_run" ]; then
      echo "  FAIL  $desc -- emitted program exit $rr, want $want_run"; fail=$((fail+1)); return
    fi
  fi
  echo "  ok    $desc (compiler exit $got${want_run:+, program exit $want_run})"; pass=$((pass+1))
}

# ---- H7 harness: poison the compiler's OWN blob, rebuild, watch it refuse -----
# The tree is never edited. `chirality_blob` writes the compiler's source; a sed over
# THAT stream is the registry swap (lib/target-linux.chiral is the one artifact a
# backend replaces -- WATCH-2/WATCH-3), so this exercises exactly the swappable
# surface without leaving a poisoned byte behind.
BASE_BLOB="$T/base.blob"
( cd "$REPO" && chirality_blob_file "lib:prog" prog/compiler.prog ) > "$BASE_BLOB" || exit 2

poison() {
  local desc="$1" sed_expr="$2" want="$3" want_msg="$4"
  local n=$((pass+fail)); local blob="$T/x$n.blob" cc="$T/x$n.cc" out got
  sed "$sed_expr" "$BASE_BLOB" > "$blob"
  if cmp -s "$blob" "$BASE_BLOB" && [ -n "$sed_expr" ] && [ "$sed_expr" != "p;d" ]; then
    echo "  FAIL  $desc -- the poison matched nothing (registry text moved?)"; fail=$((fail+1)); return
  fi
  if ! "$CC" < "$blob" > "$cc" 2>"$T/x$n.berr"; then
    echo "  FAIL  $desc -- could not build the poisoned compiler: $(head -c 200 "$T/x$n.berr")"
    fail=$((fail+1)); return
  fi
  chmod +x "$cc"
  out="$(printf '%s' '(def compile-main (-> I64 I64) (lam (n) 42))' | "$cc" 2>&1 >/dev/null)"; got=$?
  if [ "$got" != "$want" ]; then
    echo "  FAIL  $desc -- poisoned compiler exit $got, want $want: $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"
    fail=$((fail+1)); return
  fi
  if [ -n "$want_msg" ] && ! printf '%s' "$out" | grep -q -- "$want_msg"; then
    echo "  FAIL  $desc -- exit $got ok but message lacks '$want_msg': $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"
    fail=$((fail+1)); return
  fi
  echo "  ok    $desc (exit $got)"; pass=$((pass+1))
}

# the shared preamble: one declared target, and the stdio crossings.
HDR='(import "ports/stdio")
(target Svc (require run (-> I64 I64)))
'

echo
echo "=== H7: the chokepoint verdict REFUSES the emit (registry, every program) ==="

# positive control FIRST: an unpoisoned rebuild of the same blob emits fine, so a
# refusal below is the poison and not the harness.
poison "control: the clean blob still compiles" \
  "p;d" 0 ""
poison "re-pointed number: write's row renumbered 1 -> 999" \
  's/(sys-row "nb-sys-write"         1)/(sys-row "nb-sys-write"       999)/' \
  1 "ti-sys number does not match registered number"
poison "unregistered crossing: write's row renamed away" \
  's/(sys-row "nb-sys-write" /(sys-row "nb-sys-write-gone" /' \
  1 "crossing not in permitted registry (default-deny"
poison "re-pointed number: exit_group renumbered 231 -> 60" \
  's/(sys-row "nb-sys-exit-group"   231)/(sys-row "nb-sys-exit-group"    60)/' \
  1 "ti-sys number does not match registered number"

echo
echo "=== H8: the profile's frozen port set narrows PER PROGRAM ==="

# the DEFAULT: no profile declared -> no narrowing (H7 still governs). This is the
# whole existing tree, the compiler included, and it must keep working.
prof "no profile: a crossing still emits and runs" 0 "" 42 \
  '(import "ports/stdio")
(def compile-main (=> I64 I64) (lam (n) (do (print "no profile") 42)))'

# the SAME body under two different manifests -> two different verdicts.
prof "profile names the crossing it uses" 0 "" 42 \
  "$HDR(profile Talker (ports print) (target Svc))
(def compile-main (=> I64 I64) (lam (n) (do (print \"talker\") 42)))"
prof "profile names a DIFFERENT crossing -> REFUSED" 1 \
  "E76 profile REFUSED emit: crossing print (wrap-print) is outside the declared profile port set" "" \
  "$HDR(profile Muted (ports put) (target Svc))
(def compile-main (=> I64 I64) (lam (n) (do (print \"muted\") 42)))"
prof "empty port set + a crossing -> REFUSED" 1 \
  "E76 profile REFUSED emit: crossing print" "" \
  "$HDR(profile Sealed (ports) (target Svc))
(def compile-main (=> I64 I64) (lam (n) (do (print \"sealed\") 42)))"
# an empty port set is not a broken program: a composite that crosses nothing
# satisfies it, which is what makes the refusal above about the CROSSING.
prof "empty port set + no crossing -> emits" 0 "" 42 \
  "$HDR(profile Sealed (ports) (target Svc))
(def compile-main (-> I64 I64) (lam (n) 42))"
prof "the port set is per-CROSSING, not per-module" 0 "" 42 \
  "$HDR(profile Putter (ports put) (target Svc))
(def compile-main (=> I64 I64) (lam (n) (do (put \"putter\") 42)))"

# several profiles = several manifests, all of which must hold: the effective set
# is their INTERSECTION, so a second declaration can only NARROW.
prof "two profiles: intersection still permits" 0 "" 42 \
  "$HDR(profile A (ports print put) (target Svc))
(profile B (ports print) (target Svc))
(def compile-main (=> I64 I64) (lam (n) (do (print \"both\") 42)))"
prof "two profiles: intersection narrows -> REFUSED" 1 \
  "E76 profile REFUSED emit: crossing print" "" \
  "$HDR(profile A (ports print put) (target Svc))
(profile B (ports put) (target Svc))
(def compile-main (=> I64 I64) (lam (n) (do (print \"narrowed\") 42)))"

echo
echo "syscall manifest (E76 H7/H8): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
