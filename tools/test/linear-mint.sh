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

pass=0; fail=0
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
ulimit -s unlimited

# ---- refuse <desc> <want-msg> <src> ------------------------------------------
# the source must be REFUSED at load time with a named message. Load errors are
# reported before any lowering, so these cases need no crossing rows and no
# imports: what is under test is the judgment, not the backend.
refuse() {
  local desc="$1" want_msg="$2" src="$3" out got
  out="$(printf '%s' "$src" | "$CC" 2>&1 >/dev/null)"; got=$?
  if [ "$got" = "0" ]; then
    echo "  FAIL  $desc -- ACCEPTED (exit 0); it must be refused"; fail=$((fail+1)); return
  fi
  if ! printf '%s' "$out" | grep -q -- "$want_msg"; then
    echo "  FAIL  $desc -- refused, but not for this reason. want '$want_msg', got: $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"
    fail=$((fail+1)); return
  fi
  echo "  ok    $desc"; pass=$((pass+1))
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
    echo "  FAIL  $desc -- REFUSED at load: $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"
    fail=$((fail+1)); return
  fi
  echo "  ok    $desc"; pass=$((pass+1))
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
    echo "  FAIL  $desc -- compile exit $got: $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"
    fail=$((fail+1)); return
  fi
  "$T/r$n.elf" >/dev/null 2>&1; rr=$?
  if [ "$rr" != "$want" ]; then
    echo "  FAIL  $desc -- program exit $rr, want $want"; fail=$((fail+1)); return
  fi
  echo "  ok    $desc (program exit $rr)"; pass=$((pass+1))
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

refuse "let at ZERO -- erased without ever being discharged" \
  "let binds a linear value at quantity 0" \
  "${CAP}(extern mint (=> I64 Cap))
(def compile-main (=> I64 I64) (lam (n) (let ((0 c (mint 9))) 42)))"

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
echo "linear mint (E159): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
