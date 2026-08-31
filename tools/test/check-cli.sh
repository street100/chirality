#!/usr/bin/env bash
# test-check-cli.sh -- H5: `chirality check` is the NATIVE compiler, not Python.
#
# `bin/chirality check` used to be `python3 -m chirality check`. It is now: resolve the
# file's imports with the shell source provider, compile the unit with B1, throw
# the ELF away, report the compiler's own message. These cases pin that it
# ACCEPTS well-typed source and REFUSES ill-typed source with a non-zero exit --
# a checker that only ever says OK is not a checker.
#
# Zero Python. Zero golden captures: every expectation is what the program MEANS.
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

echo
echo "chirality check CLI: $pass passed, $fail failed"
[ "$fail" -eq 0 ]
