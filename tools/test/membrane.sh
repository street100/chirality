#!/usr/bin/env bash
# membrane.sh -- E171: the `->`/`=>` membrane, refused at the call.
#
# A Pi that crosses (`=>`) applies only at a seat that crosses. The seat a body
# runs at is the seat of the Pi its lambda is checked against; a non-arrow def
# body, an erased (quantity-0) argument, field or `let` value, and every type
# run pure. The rule is one predicate, `seat-sub`, read once, in `infer-app2`
# (lib/typing/kernel.chiral). Spec: docs/elements/specs/
# E171-membrane-enforced-at-call-seam-SPEC.md §4.
#
# Rows: `refuse` wants a refusal carrying the E171 text, since a row that wants
# only a refusal passes on any refusal. `admit` wants the root to compile.
# `runs` compiles and runs it and pins the exit. Every fixture is a root file
# compiled through `bin/chirality compile` under $CHIRALITY_COMPILE, so its
# imports resolve. The mutant leg at the foot re-runs this file under each
# mutated compiler and pins the full red set, on linear-mint.sh's idiom.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"
CHIR="$REPO/bin/chirality"
CC="${CHIRALITY_COMPILE:-}"
if [ -z "$CC" ]; then
  [ -x "$REPO/bin/chirality-bin" ] && CC="$REPO/bin/chirality-bin"
fi
[ -n "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
export CHIRALITY_COMPILE="$CC"

SELF="${BASH_SOURCE[0]:-$0}"
WANT='effectful application at a pure seat (use => not ->)'

pass=0; fail=0
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
ulimit -s unlimited

# the red log: every red row appends its description; a mutant leg reads it.
RED_LOG="${CHIRALITY_RED_LOG:-$T/reds}"
: >"$RED_LOG"

ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }
red() { echo "  FAIL  $1 -- $2"; printf '%s\n' "$1" >>"$RED_LOG"; fail=$((fail+1)); }

# build <src-file>: compile a root into $T, leaving $out, $got and $elf
build() {
  elf="$T/$(basename "$1").elf"
  out="$(ORIG_DIR="$T" "$CHIR" compile "$1" -o "$elf" 2>&1)"; got=$?
}
root() {  # root <src> -> a fresh root file holding src
  local f="$T/r$((pass+fail)).chiral"; printf '%s' "$1" >"$f"; printf '%s' "$f"
}

# ---- refuse <desc> <want-msg> <file> -----------------------------------------
refuse_file() {
  local desc="$1" want="$2"
  build "$3"
  if [ "$got" = "0" ]; then red "$desc" "ACCEPTED (exit 0); it must be refused"; return; fi
  if ! printf '%s' "$out" | grep -qF -- "$want"; then
    red "$desc" "refused, but not for this reason: $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"
    return
  fi
  ok "$desc"
}
refuse() { refuse_file "$1" "$WANT" "$(root "$2")"; }

# ---- admit <desc> <file> -----------------------------------------------------
admit_file() {
  build "$2"
  if [ "$got" != "0" ]; then
    red "$1" "compile exit $got: $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"; return
  fi
  ok "$1"
}
admit() { admit_file "$1" "$(root "$2")"; }

# ---- runs <desc> <want-exit> <src> -------------------------------------------
runs() {
  local desc="$1" want="$2" f rr
  f="$(root "$3")"; build "$f"
  if [ "$got" != "0" ]; then
    red "$desc" "compile exit $got: $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"; return
  fi
  "$elf" >/dev/null 2>&1; rr=$?
  [ "$rr" = "$want" ] || { red "$desc" "program exit $rr, want $want"; return; }
  ok "$desc (program exit $rr)"
}

HEAD='(import "prelude/prelude")
(import "ports/ports")
(def eff (=> I64 I64) (lam (n) (do (put "x") n)))
(def eff2 (=> I64 I64 I64) (lam (a b) (do (put "x") (+ a b))))
'
MAIN='(def compile-main (=> Unit I64) (lam (u) 0))
'

echo "=== E171 R: a crossing applied at a pure seat is refused ==="
refuse "R1 direct: a -> def calls a => def" "$HEAD
(def f (-> I64 I64) (lam (n) (eff n)))
$MAIN"
refuse "R2 callback: a -> def applies a => parameter" "$HEAD
(def app (-> (=> I64 I64) I64 I64) (lam (g n) (g n)))
$MAIN"
refuse "R3 data field: a -> def applies a => field" "$HEAD
(data Box () (box (run (=> I64 I64))))
(def unbox (-> Box I64 I64) (lam (b n) (case b ((box r) (r n)))))
$MAIN"
refuse "R4 partial application: a -> body saturates (eff2 n)" "$HEAD
(def f (-> I64 I64) (lam (n) (let (p (eff2 n)) (p n))))
$MAIN"
refuse "R5 quantity-0 argument in a => body" "$HEAD
(def k (-> (0 x I64) I64 I64) (lam (x m) m))
(def g (=> I64 I64) (lam (n) (k (eff n) n)))
$MAIN"
refuse "R6 quantity-0 let in a => body" "$HEAD
(def g (=> I64 I64) (lam (n) (let ((0 x (eff n))) n)))
$MAIN"
refuse "R7 quantity-0 field in a => body" "$HEAD
(data Tag () (tag (0 w I64) (v I64)))
(def g (=> I64 Tag) (lam (n) (tag (eff n) n)))
$MAIN"
refuse "R8 type position in a => body" "$HEAD
(def pick (=> Unit (type 0)) (lam (u) I64))
(def g (=> I64 I64) (lam (n) (the (pick unit) n)))
$MAIN"
refuse "R9 non-arrow def" "$HEAD
(def v I64 (eff 3))
$MAIN"
refuse "R10 the demo: a root importing demo/_eff" '(import "prelude/prelude")
(import "demo/_eff")
(def compile-main (=> Unit I64) (lam (u) 0))
'

echo
echo "=== E171 A: what the membrane admits ==="
runs "A1 => body: eff called from a => compile-main" 7 "$HEAD
(def compile-main (=> Unit I64) (lam (u) (eff 7)))
"
admit "A2 curried =>: a -> outer binder returns the => closure" "$HEAD
(def p (-> I64 (=> I64 I64)) (lam (n) (eff2 n)))
$MAIN"
admit "A3 pure calls pure: a -> def calls a -> def and a -> extern" '(import "prelude/prelude")
(def sub1 (-> I64 I64) (lam (n) (- n 1)))
(def twice (-> I64 I64) (lam (n) (sub1 (sub1 n))))
(def compile-main (=> Unit I64) (lam (u) (twice 9)))
'
refuse_file "A4 E42: a => arg to a -> parameter is the conv refusal" "type mismatch" \
  "$REPO/prog/samples/e42_reject_pure_as_process.prog"
for r in prog/samples/prapanca-divide-live.prog \
         prog/samples/prapanca-evidence-sift-refined-live.prog \
         prog/samples/prapanca-parse-robust-test.prog \
         prog/prapanca/chatter/turn-test.prog; do
  admit_file "A5 the retyped root ${r##*/} compiles" "$REPO/$r"
done

echo
echo "=== E171 S: the structure ==="
# seat-sub-calls <lib dir> -> the number of `(seat-sub ` call sites
seat_sub_calls() { grep -RoF -- '(seat-sub ' "$1" | wc -l; }
n="$(seat_sub_calls "$REPO/lib")"
if [ "$n" -eq 1 ]; then ok "(seat-sub  occurs at exactly one call site under lib/"
else bad "(seat-sub  occurs at $n call sites under lib/, wanted 1"; fi
# the five type-judging heads take no seat
for h in infer-pi infer-pi2 check-tparams check-refine check-ratoms; do
  l="$(awk -v h="(def $h" '$0==h {getline; print; exit}' "$REPO/lib/typing/kernel.chiral")"
  case "$l" in
    *"(lam (sig c "*) case "$l" in *amb*) bad "$h takes a seat: $l";; *) ok "$h takes no seat";; esac;;
    *) bad "$h head not found where expected: '$l'";;
  esac
done
# the count row convicts a second call site
cp -a "$REPO/lib" "$T/lib2"
printf '\n(def e171-probe Bool (seat-sub seat-none seat-none))\n' >>"$T/lib2/typing/kernel.chiral"
n2="$(seat_sub_calls "$T/lib2")"
if [ "$n2" -eq 2 ]; then ok "a scratch lib/ with a second seat-sub call reads 2 and reddens the count row"
else bad "a scratch lib/ with a second seat-sub call reads $n2, wanted 2"; fi

# ---- the mutants: each pins the FULL red set it reddens ----------------------
if [ -z "${CHIRALITY_RED_LOG:-}" ] && [ -z "${CHIRALITY_NO_MUTANTS:-}" ]; then
  echo
  echo "=== E171 M: the mutants -- each pins the FULL set of rows it reddens ==="
  if [ ! -s "$RED_LOG" ]; then
    ok "the base red set is EMPTY -- no mutant below is scored against a red base"
  else
    bad "the base is ALREADY RED; every mutant below would score as convicted:"
    sed 's/^/          /' "$RED_LOG"
  fi

  export CHIRALITY_MUTANT_DIR="$T/mut"
  export CHIRALITY_MUTANT_BASE="$CC"
  mkdir -p "$CHIRALITY_MUTANT_DIR"
  # shellcheck disable=SC1090
  . "$HERE/mutant.sh"

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

  R_ALL='R1 direct: a -> def calls a => def
R2 callback: a -> def applies a => parameter
R3 data field: a -> def applies a => field
R4 partial application: a -> body saturates (eff2 n)
R5 quantity-0 argument in a => body
R6 quantity-0 let in a => body
R7 quantity-0 field in a => body
R8 type position in a => body
R9 non-arrow def
R10 the demo: a root importing demo/_eff'

  # M1 -- the refusal off: seat-sub admits every application.
  mut_row m1-refusal-off lib/typing/kernel.chiral 1 \
    '(lam (callee amb) (case (seat-crosses callee) (false true) (true (seat-crosses amb)))))' \
    '(lam (callee amb) true))' \
    "$R_ALL"

  # M2 -- erased positions keep the ambient: only the quantity-0 rows go green.
  mut_row m2-erased-arg-off lib/typing/kernel.chiral 1 \
    '(lam (q amb) (case q ((q0) seat-none) (_ amb))))' \
    '(lam (q amb) amb))' \
    'R5 quantity-0 argument in a => body
R6 quantity-0 let in a => body
R7 quantity-0 field in a => body'

  # M3 -- a lambda's body runs pure whatever its Pi: every => body that applies
  # a crossing is refused, so the admits that hold one go red.
  mut_row m3-lambda-ambient-pure lib/typing/kernel.chiral 1 \
    '(case (check sig (ctx-bind qp dom c) s b' \
    '(case (check sig (ctx-bind qp dom c) seat-none b' \
    'A1 => body: eff called from a => compile-main
A2 curried =>: a -> outer binder returns the => closure
A4 E42: a => arg to a -> parameter is the conv refusal
A5 the retyped root prapanca-divide-live.prog compiles
A5 the retyped root prapanca-evidence-sift-refined-live.prog compiles
A5 the retyped root prapanca-parse-robust-test.prog compiles
A5 the retyped root turn-test.prog compiles'

  # M4 -- an annotation's type runs at the ambient: only the type-position row.
  mut_row m4-annotation-type-ambient lib/typing/kernel.chiral 1 \
    '(case (infer sig c seat-none ty)' \
    '(case (infer sig c amb ty)' \
    'R8 type position in a => body'
fi

echo
echo "membrane (E171): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
