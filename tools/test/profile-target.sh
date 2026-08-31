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
# Zero Python. Zero golden captures: every expectation is what the form MEANS.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CHIR="$REPO/bin/chirality"

pass=0; fail=0
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT

# check <desc> <want-exit> <want-substring-or-empty> <source>
check() {
  local desc="$1" want="$2" want_msg="$3" src="$4"
  local f="$T/case$((pass+fail)).chiral" out
  printf '%s' "$src" > "$f"
  out="$(ORIG_DIR="$T" "$CHIR" check "$f" 2>&1)"; local got=$?
  if [ "$got" != "$want" ]; then
    echo "  FAIL  $desc -- exit $got, want $want: $(printf '%s' "$out" | tr '\n' ' ')"
    fail=$((fail+1)); return
  fi
  if [ -n "$want_msg" ] && ! printf '%s' "$out" | grep -q -- "$want_msg"; then
    echo "  FAIL  $desc -- exit $got ok but message lacks '$want_msg': $(printf '%s' "$out" | tr '\n' ' ')"
    fail=$((fail+1)); return
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

echo
echo "profile/target manifest: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
