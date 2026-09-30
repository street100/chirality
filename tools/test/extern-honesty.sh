#!/usr/bin/env bash
# extern-honesty.sh -- E204: a pure-declared extern reaches no crossing.
#
# Two checks, one rule. At load, an extern whose spine never crosses
# (`ty-crosses` false) and whose name is a `crossing-wraps` key is refused
# (`load-extern-honest`, lib/module/loader.chiral). At emit, the pure library is
# closed: no `native-lib` routine holds a `ti-sys` or calls a name outside
# `native-lib`, and every `prim2lib-table` target is a member
# (`pure-lib-offender`, lib/lowering/compile-emit.chiral). Spec:
# docs/elements/specs/E204-extern-honesty-pure-declared-extern-SPEC.md §4.
#
# Rows: L wants the load refusal's sentence, A the controls, E a compiler built
# from a poisoned tree that must refuse emit with E204's sentence. The E rows
# build through mutant.sh's `mutant_build` from the tree CHIRALITY_MUTANT_SRC
# names (the repo by default), so a mutant leg grades the mutant's own sources.
# The mutant leg at the foot re-runs this file under each mutated compiler and
# pins the full red set, on membrane.sh's idiom.
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
WANT_L='extern declared pure routes to a crossing (use => not ->): '
WANT_E='E204 pure library REFUSED emit: '

pass=0; fail=0
T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT
ulimit -s unlimited

# the red log: every red row appends its description; a mutant leg reads it.
RED_LOG="${CHIRALITY_RED_LOG:-$T/reds}"
: >"$RED_LOG"

ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }
red() { echo "  FAIL  $1 -- $2"; printf '%s\n' "$1" >>"$RED_LOG"; fail=$((fail+1)); }

# mutant.sh is sourced up front: the E rows build through mutant_build. The
# scratch dir and the base are set first, so its own EXIT trap never installs
# and the poison compilers are built by the compiler under test.
export CHIRALITY_MUTANT_DIR="$T/mut"
export CHIRALITY_MUTANT_BASE="$CC"
mkdir -p "$CHIRALITY_MUTANT_DIR"
# shellcheck disable=SC1090
. "$HERE/mutant.sh"
SRC="${CHIRALITY_MUTANT_SRC:-$REPO}"

# build <src-file> [compiler]: compile a root into $T, leaving $out, $got, $elf
build() {
  elf="$T/$(basename "$1").elf"
  out="$(CHIRALITY_COMPILE="${2:-$CC}" ORIG_DIR="$T" "$CHIR" compile "$1" -o "$elf" 2>&1)"; got=$?
}
root() {  # root <src> -> a fresh root file holding src
  local f="$T/r$((pass+fail)).chiral"; printf '%s' "$1" >"$f"; printf '%s' "$f"
}

# ---- refuse_file <desc> <want-msg> <file> [compiler] -------------------------
refuse_file() {
  local desc="$1" want="$2"
  build "$3" "${4:-$CC}"
  if [ "$got" = "0" ]; then red "$desc" "ACCEPTED (exit 0); it must be refused"; return; fi
  if ! printf '%s' "$out" | grep -qF -- "$want"; then
    red "$desc" "refused, but not for this reason: $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"
    return
  fi
  ok "$desc"
}

# ---- admit_file <desc> <file> ------------------------------------------------
admit_file() {
  build "$2"
  if [ "$got" != "0" ]; then
    red "$1" "compile exit $got: $(printf '%s' "$out" | tr '\n' ' ' | head -c 200)"; return
  fi
  ok "$1"
}

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

MAIN='(def compile-main (=> Unit I64) (lam (u) 0))
'

echo "=== E204 L: a pure-declared crossing is refused at load ==="
refuse_file "L1 the probe: a pure print called from a -> def" "${WANT_L}print" \
  "$REPO/prog/samples/e204_reject_pure_print.prog"
refuse_file "L2 a pure put, declared and never called" "${WANT_L}put" "$(root '(import "prelude/prelude")
(extern put (-> Str Unit))
'"$MAIN")"
refuse_file "L3 a pure read, another route" "${WANT_L}read" "$(root '(import "prelude/prelude")
(extern read (-> I64 I64 Bytes))
'"$MAIN")"
refuse_file "L4 an erased outer binder over a pure spine" "${WANT_L}exit" \
  "$REPO/prog/samples/e204_reject_pure_exit.prog"

echo
echo "=== E204 A: the controls ==="
runs "A1 a => print called from a => compile-main" 7 '(import "prelude/prelude")
(extern print (=> Str Unit))
(def compile-main (=> Unit I64) (lam (u) (do (print "x") 7)))
'
# A2: every file holding a `->` extern loads. The list is read off the tree.
# The `_reject_` samples are this gate's own L fixtures and leave the list, as
# they leave phase 7.
XF="$( cd "$REPO" && grep -rlE '^\s*\(extern [^ ]+ \(->' lib prog 2>/dev/null \
         | grep -v '_reject_' | sort )"
case "$XF" in
  *lib/prelude/prelude.chiral*prog/prapanca/backend.chiral*)
    ok "A2 the -> extern file list holds prelude and backend ($(printf '%s\n' "$XF" | wc -l) files)" ;;
  *) bad "A2 the -> extern file list lacks prelude or backend: $(printf '%s' "$XF" | tr '\n' ' ')" ;;
esac
for x in $XF; do
  k="${x#*/}"; k="${k%.*}"
  admit_file "A2 $x loads" "$(root "(import \"prelude/prelude\")
(import \"$k\")
$MAIN")"
done
admit_file "A3 a => extern over a pure route: prapanca-code-test-live.prog" \
  "$REPO/prog/samples/prapanca-code-test-live.prog"

echo
echo "=== E204 E: the pure library closed at emit, graded on the sources ==="
ETRIV="$(root "(import \"prelude/prelude\")
$MAIN")"
# poison <desc> <label> <rel> <old> <new> <want-sentence>: build a compiler
# from $SRC with one poison applied, compile a trivial root with it.
poison() {
  local desc="$1" label="$2" rel="$3" old="$4" new="$5" want="$6" pc
  pc="$(mutant_build "$label" "$rel" 1 "$old" "$new")"
  case "$pc" in FAIL:*) bad "$desc BUILD:fail ($pc)"; return;; esac
  refuse_file "$desc" "${WANT_E}${want}" "$ETRIV" "$pc"
}
NBID='(ti-fn "nb-id" 1 1 (ti-ret 0))'
poison "E1 a native-lib routine calls outside it" e1-call-out \
  lib/lowering/tal/bytes.chiral "$NBID" \
  '(ti-fn "nb-id" 1 2 (t-seq (ti-call 1 "nb-arena-fail" (cons 0 nil)) (ti-ret 0)))' \
  'nb-id calls nb-arena-fail outside native-lib'
poison "E2 a prim2lib-table target outside native-lib" e2-target-out \
  lib/lowering/tal/erase.chiral '(cons (pair "brepeat" "nb-brepeat")' \
  '(cons (pair "brepeat" "nb-sys-write")' \
  'prim brepeat routes to nb-sys-write outside native-lib'
# E3: a registered ti-sys. The registry row goes into a scratch tree first, so
# ck-tiprog (registered, matching number) and first-dup-go (nb-id is in no
# other library) both admit it and E204 alone refuses.
E3T="$T/e3-src"; rm -rf "$E3T"; mkdir -p "$E3T"
if cp -a "$SRC/lib" "$SRC/prog" "$SRC/bin" "$E3T/" 2>/dev/null; then
  MF="$E3T/lib/lowering/tal/target-linux.manifest"
  if [ "$(mut_count "$MF" '(nil)')" = "1" ]; then
    mut_sub "$MF" '(nil)' '(cons (sys-row "nb-id" 60) (nil))'
    CHIRALITY_MUTANT_SRC="$E3T" poison "E3 a native-lib routine holds a registered ti-sys" e3-sys-in \
      lib/lowering/tal/bytes.chiral "$NBID" \
      '(ti-fn "nb-id" 1 2 (t-seq (ti-sys 1 60 (cons 0 nil)) (ti-ret 0)))' \
      'nb-id holds ti-sys'
  else bad "E3 the registry anchor (nil) does not occur once in target-linux.manifest"; fi
else bad "E3 could not copy the source tree"; fi

# ---- the mutants: each pins the FULL red set it reddens ----------------------
if [ -z "${CHIRALITY_RED_LOG:-}" ] && [ -z "${CHIRALITY_NO_MUTANTS:-}" ]; then
  echo
  echo "=== E204 M: the mutants -- each pins the FULL set of rows it reddens ==="
  if [ ! -s "$RED_LOG" ]; then
    ok "the base red set is EMPTY -- no mutant below is scored against a red base"
  else
    bad "the base is ALREADY RED; every mutant below would score as convicted:"
    sed 's/^/          /' "$RED_LOG"
  fi

  # leg <label> <compiler>: re-run this file under the mutant, its E rows
  # building from the mutant's own tree.
  leg() {
    local log="$CHIRALITY_MUTANT_DIR/red-$1" out="$CHIRALITY_MUTANT_DIR/out-$1"
    : >"$log"
    CHIRALITY_RED_LOG="$log" CHIRALITY_COMPILE="$2" \
      CHIRALITY_MUTANT_SRC="$CHIRALITY_MUTANT_DIR/tree-$1" bash "$SELF" >"$out" 2>&1
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

  # M1 -- the load refusal off: a pure crossing extern installs as before.
  mut_row m1-load-off lib/module/loader.chiral 1 \
    '((some w) (ld-err (r-judged (subj-extern name) (jg-extern-pure-crossing))))' \
    '((some w) (load-extern-linear s name tyt))' \
    'L1 the probe: a pure print called from a -> def
L2 a pure put, declared and never called
L3 a pure read, another route
L4 an erased outer binder over a pure spine'

  # M2 -- the emit closure off: every poison compiler emits.
  mut_row m2-emit-off lib/lowering/compile-emit.chiral 1 \
    '(pure-lib-offender native-lib prim2lib-table)' \
    '(pure-lib-offender nil nil)' \
    'E1 a native-lib routine calls outside it
E2 a prim2lib-table target outside native-lib
E3 a native-lib routine holds a registered ti-sys'
fi

echo
echo "extern-honesty (E204): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
