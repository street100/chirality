#!/usr/bin/env bash
# tal-check.sh -- the typed-assembly floor checker, after the EN-09/EN-11
# repairs.  The Phase 22 gate.
#
# PHASE 22, and 22 for the reason 18 was 18: 8-12 are names still OWED to
# unported old-tree phases (run-tests.sh:18-22), and reusing one would make an
# unported gate look ported.  3-6, 13-20 and 24 are taken, and 21 is left to
# tools/test/crypto.sh, which was written first and whose registration is
# already owed.
#
# not-a-phase: it claims 22, which is inside Lane B's reserved 21-23 band.
# NOT YET REGISTERED: the run_phase line in run-tests.sh is owed to the
# suite-owning session, the crypto.sh precedent.  Registering 22 ahead of 21
# would open a gap in a file another session holds, and this session is barred
# from running run-tests.sh (it has OOM-killed several), so the line could not
# be verified where it landed.  Run this script directly.
#
# ─── WHAT THIS GATES, AND WHY IT IS NOT A ONE-SIDED CHECK ───────────────────
#
# `lib/lowering/tal/check.chiral` carries two repairs, ruled on by the author
# 2026-09-03 (`records/author-calls.md`, "The `ck-prog` repair shape"):
#
#   B1  ck-term's case arm recovers the scrutinee's data name from the first
#       arm's constructor when the register carries tt-word, the recovery
#       `case-sty`/`ctor-data` already performs in the lowering
#       (lib/lowering/upper/lower.chiral:168-188).  EN-11, 105 rejects.
#   B3  tal-ty=? treats an EMPTY type-argument list on either side as a match,
#       the wildcard role tt-word already plays for a whole type.  EN-09,
#       EN-10 and 73 of EN-12's 75.
#
# ⚑ A RELAXATION SHIPPED ON ITS ARGUMENT ALONE IS THE GATE THAT CANNOT FAIL,
# which `docs/decisions/decision-scope.md` names as the failure mode.  Nine of
# the sixteen rows below are REJECT rows, and they are the point: the repaired
# checker still refuses an unbound register, a ground type against a data type,
# a case on a tt-i64 register, a data-name mismatch, a non-exhaustive tt-word
# case, an unrecoverable arm constructor, a disagreement inside two PRESENT
# argument lists, and a field arity error.
#
# ⚑ EVERY ROW READS EMITTED BYTES.  The fixture PRINTS one verdict per TFn and
# asserts nothing -- it always exits 0 -- and every comparison below is in bash
# against a string constant held here.  A gate that re-derived the verdict from
# the checker would be the same information twice and green under any mutant
# that changed what the verdict SAYS.  The pretty.sh / crypto.sh idiom.
#
#   G1   a1  EN-09's minimal shape: declared (tt-data "Lst" (tt-i64))
#            against a body producing (tt-data "Lst" nil)        ACCEPT   [M2]
#   G2   a1c EN-09's one-change control: the same body under a
#            declared return spelled with no arguments           ACCEPT
#   G3   a2  EN-11's minimal shape: a tt-word scrutinee cased
#            over Lst arms                                       ACCEPT   [M1]
#   G4   a2c EN-11's one-change control: the identical body
#            under a (tt-data "Lst" nil) parameter               ACCEPT
#   G5   a3  EN-10's shape, through ck-con's field check         ACCEPT   [M2]
#   G6   a4  EN-12's 73, through ck-args into ck-app             ACCEPT   [M2]
#   G7   a5  both sides carry an argument and agree              ACCEPT
#   G8   r1  EN-12's undefined register, passed to a call        REJECT
#   G9   r1c EN-12's one-change control: register 2 defined      ACCEPT
#   G10  r2  EN-13's ground-versus-data: tt-i64 where
#            (tt-data "List" (tt-word)) is declared               REJECT
#   G11  r3  a tt-i64 scrutinee -- the B1 recovery is scoped
#            to tt-word and refuses this one                      REJECT  [M1]
#   G12  r4  the data NAME still has to match                     REJECT
#   G13  r5  a tt-word scrutinee covering one of two ctors.  It
#            reaches exhaustiveness only BECAUSE B1 recovered
#            "Lst", so its MESSAGE is the B1 evidence             REJECT  [M1]
#   G14  r6  a tt-word scrutinee whose arm names no declared
#            constructor -- the recovery invents nothing          REJECT
#   G15  r7  two PRESENT argument lists that disagree             REJECT  [M3]
#   G16  r8  field arity                                          REJECT
#   G17  the co-import census: no module under lib/ or prog/ imports both
#        typing/kernel and lowering/tal/check (diag.sh:267-270 counts the same
#        thing, and this gate must keep that count at zero).  ⚑ WHAT ZERO NOW
#        MEANS.  It used to mean the co-import was IMPOSSIBLE -- eleven top-level
#        names of check.chiral were already in the compiler's blob, so the import
#        was `load: data redeclared: CkR`.  Those eleven are `tck-` prefixed now
#        and the co-import LOADS AND RUNS, measured against the whole compiler
#        closure.  Zero therefore means NOTHING HAS WIRED IT YET: ck-prog still
#        has no call site (enforcement-arc requirement 2) and optimize.chiral
#        still has no importer (requirement 4).  The row goes red the day one of
#        them is wired, and on that day the red row is a REMINDER to retire this
#        gate. It reports no defect.
#   G18  `def ck-prog` does not appear in the compiler's blob -- the subject of
#        this gate is OUTSIDE the compiler closure, which is why the mutant
#        harness below is a scratch lib/ and not tools/test/mutant.sh
#
#   M1   the B1 recovery returns (none) instead of walking tck-ce-datas.  RUN: G3
#        goes back to "case on non-data register" and G13's message goes back
#        with it, while G11 must stay red for the SAME reason it is red now.
#   M2   tal-ty=?'s tt-data arm calls the strict tys=? again.  RUN: G1, G5 and
#        G6 must all three go red -- one per rule that reads the relation.
#   M3   targs=? returns true for two present lists.  RUN: G15 must go red.
#        This is the mutant that proves B3 is a wildcard on an EMPTY list and
#        not a blanket accept.
#
# ⚑ THE MUTANT HARNESS IS NOT tools/test/mutant.sh.  That one rebuilds
# prog/compiler.prog and asserts the mutant compiler differs; G18 measures that
# lowering/tal/check is outside that closure, so every mutation of it builds a
# byte-identical compiler and would score INERT.  The mechanism for a module
# outside the closure is Phase 17/18/19/21's: a scratch lib/ copied with cp -a,
# mutated with sed -i, refused when the mutation changed nothing, the fixture
# compiled against that tree.
#
# The phase's wall clock is printed and sets no bar (the 2026-09-01 ruling,
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

CHECK="$REPO/lib/lowering/tal/check.chiral"
[ -f "$CHECK" ] || { echo "  FAIL  $CHECK missing -- a gate without its module cannot fail"; exit 2; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# ─── the fixture ────────────────────────────────────────────────────────────
# Written here rather than tracked under tools/test/samples/: everything under
# samples/ is walked by Phase 2's test-runner and counted by the compile-only
# root census, and this gate has no business moving either number.  The
# crypto.sh precedent, same framing as e181_pretty.prog.
FIXTURE="$TMP/en14_tal_check.prog"
cat >"$FIXTURE" <<'CHIRAL'
; en14_tal_check.prog -- the Phase 22 emitted-bytes fixture.  Prints, never
; asserts: the assertions live in tools/test/tal-check.sh, in bash, over these
; bytes.  A checker gate that re-derives its own verdict is green under any
; mutant that changes what the verdict SAYS (the pretty.sh / crypto.sh rule).
;
; IMPORTS: prelude, lowering/tal/ssa, lowering/tal/check and the stdio port.
; It reaches neither typing/kernel nor surface/data nor lowering/upper/lower, and
; that is now ECONOMY rather than necessity: check.chiral's eleven colliding
; names are `tck-` prefixed, so a co-import loads and runs (tools/test/diag.sh:
; 253-270).  This fixture keeps the narrow closure because a smaller blob builds
; faster and the mutant harness rebuilds it four times.
(import "prelude/prelude")
(import "lowering/tal/ssa")
(import "lowering/tal/check")
(import "ports/stdio")

; ---- the data world every row is checked against ----------------------------
(def tk-lst DData
  (ddata "Lst"
    (cons (dctor "lnil" nil)
    (cons (dctor "lcons" (cons (tt-word) (cons (tt-data "Lst" nil) nil))) nil))))
; Box's one field is DECLARED with a type argument; a con of Lst is annotated
; with none.  That is EN-10's shape.
(def tk-box DData
  (ddata "Box"
    (cons (dctor "bx" (cons (tt-data "Lst" (cons (tt-word) nil)) nil)) nil)))
(def tk-list DData
  (ddata "List" (cons (dctor "lempty" nil) nil)))

; "inner" takes two I64; "consume" takes a List carrying an argument.
(def tk-fns (List (Pair Str TalSig))
  (cons (pair "inner"   (talsig (cons (tt-i64) (cons (tt-i64) nil)) (tt-i64)))
  (cons (pair "consume" (talsig (cons (tt-data "List" (cons (tt-word) nil)) nil) (tt-i64)))
        nil)))

(def tk-ce CEnv
  (cenv nil tk-fns (cons tk-lst (cons tk-box (cons tk-list nil))) nil))

; ---- shared bodies ----------------------------------------------------------
(def tk-lnil-arm Branch
  (branch "lnil" nil (block (cons (i-const 5 (tt-i64) 0) nil) (t-ret 5))))
(def tk-lcons-arm Branch
  (branch "lcons" (cons 1 (cons 2 nil))
    (block (cons (i-const 5 (tt-i64) 1) nil) (t-ret 5))))
(def tk-arms (List Branch) (cons tk-lnil-arm (cons tk-lcons-arm nil)))

; ---- ACCEPT rows ------------------------------------------------------------
; A1 / EN-09: declared return (tt-data "Lst" (tt-i64)), body producing
; (tt-data "Lst" nil).  A1C is EN-09's one-change control: respelling the
; declared return with no arguments accepted before the repair too.
(def tk-a1 TFn
  (tfn "a1" nil (tt-data "Lst" (cons (tt-i64) nil))
    (block (cons (i-con 0 "Lst" "lnil" nil (tt-data "Lst" nil)) nil) (t-ret 0)) 1))
(def tk-a1c TFn
  (tfn "a1c" nil (tt-data "Lst" nil)
    (block (cons (i-con 0 "Lst" "lnil" nil (tt-data "Lst" nil)) nil) (t-ret 0)) 1))

; A2 / EN-11: a tt-word scrutinee cased over Lst arms.  A2C is EN-11's
; one-change control: the identical body under a (tt-data "Lst" nil) parameter.
(def tk-a2 TFn
  (tfn "a2" (cons (tt-word) nil) (tt-i64) (block nil (tt-case 0 tk-arms (none))) 6))
(def tk-a2c TFn
  (tfn "a2c" (cons (tt-data "Lst" nil) nil) (tt-i64)
    (block nil (tt-case 0 tk-arms (none))) 6))

; A3 / EN-10: the field check.  The inner con's register is (tt-data "Lst" nil)
; and Box's field is declared (tt-data "Lst" (tt-word)).
(def tk-a3 TFn
  (tfn "a3" nil (tt-data "Box" nil)
    (block (cons (i-con 0 "Lst" "lnil" nil (tt-data "Lst" nil))
           (cons (i-con 1 "Box" "bx" (cons 0 nil) (tt-data "Box" nil)) nil))
      (t-ret 1)) 2))

; A4 / EN-12's 73: the same erased list reaching ck-app through ck-args.
(def tk-a4 TFn
  (tfn "a4" nil (tt-i64)
    (block (cons (i-con 0 "List" "lempty" nil (tt-data "List" nil))
           (cons (i-call 1 "consume" (cons 0 nil) (tt-i64)) nil))
      (t-ret 1)) 2))

; A5: BOTH sides carry an argument and the two are word-compatible.  The
; pre-existing elementwise relation, unchanged by the repair.
(def tk-a5 TFn
  (tfn "a5" nil (tt-data "Lst" (cons (tt-word) nil))
    (block (cons (i-con 0 "Lst" "lnil" nil (tt-data "Lst" (cons (tt-i64) nil))) nil)
      (t-ret 0)) 1))

; ---- REJECT rows: the shapes the repaired checker must still refuse ---------
; R1 / EN-12: register 2 is bound by nothing.  R1C inserts its definition.
(def tk-r1 TFn
  (tfn "r1" (cons (tt-i64) nil) (tt-i64)
    (block (cons (i-call 1 "inner" (cons 0 (cons 2 nil)) (tt-i64)) nil) (t-ret 1)) 3))
(def tk-r1c TFn
  (tfn "r1c" (cons (tt-i64) nil) (tt-i64)
    (block (cons (i-const 2 (tt-i64) 0)
           (cons (i-call 1 "inner" (cons 0 (cons 2 nil)) (tt-i64)) nil))
      (t-ret 1)) 3))

; R2 / EN-13: ground against data.  tt-i64 in a position declared
; (tt-data "List" (tt-word)).  The repair leaves tal-ty=?'s ground arms alone.
(def tk-r2 TFn
  (tfn "r2" nil (tt-i64)
    (block (cons (i-const 0 (tt-i64) 7)
           (cons (i-call 1 "consume" (cons 0 nil) (tt-i64)) nil))
      (t-ret 1)) 2))

; R3: a tt-i64 scrutinee.  The B1 recovery is scoped to tt-word, so this is
; still a case on a non-data register.
(def tk-r3 TFn
  (tfn "r3" (cons (tt-i64) nil) (tt-i64) (block nil (tt-case 0 tk-arms (none))) 6))

; R4: the data NAME still has to match.
(def tk-r4 TFn
  (tfn "r4" nil (tt-data "Box" (cons (tt-word) nil))
    (block (cons (i-con 0 "Lst" "lnil" nil (tt-data "Lst" nil)) nil) (t-ret 0)) 1))

; R5: a tt-word scrutinee covering only one of Lst's two constructors.  It
; reaches the exhaustiveness rule only BECAUSE the recovery found "Lst"; before
; the repair this row refused with "case on non-data register".
(def tk-r5 TFn
  (tfn "r5" (cons (tt-word) nil) (tt-i64)
    (block nil (tt-case 0 (cons tk-lnil-arm nil) (none))) 6))

; R6: a tt-word scrutinee whose first arm names no constructor of any declared
; data type.  The recovery does not invent one.
(def tk-r6 TFn
  (tfn "r6" (cons (tt-word) nil) (tt-i64)
    (block nil (tt-case 0
      (cons (branch "nosuchctor" nil (block (cons (i-const 5 (tt-i64) 0) nil) (t-ret 5))) nil)
      (none))) 6))

; R7: BOTH sides carry an argument and the two disagree.  An empty list is the
; wildcard; a present one is still checked.
(def tk-r7 TFn
  (tfn "r7" nil (tt-data "Lst" (cons (tt-str) nil))
    (block (cons (i-con 0 "Lst" "lnil" nil (tt-data "Lst" (cons (tt-i64) nil))) nil)
      (t-ret 0)) 1))

; R8: field arity.  Box's constructor takes one field and is given none.
(def tk-r8 TFn
  (tfn "r8" nil (tt-data "Box" nil)
    (block (cons (i-con 0 "Box" "bx" nil (tt-data "Box" nil)) nil) (t-ret 0)) 1))

; ---- printing ---------------------------------------------------------------
(declare tk-verdict (-> TckR Str))
(def tk-verdict (lam (r) (case r ((tck-ok e) "accept") ((tck-err m) (str-cat "reject: " m)))))

(declare tk-emit (=> Str TFn Unit))
(def tk-emit (lam (l f)
  (let ((_ (put (str-cat "==BEGIN " (str-cat l "==\n")))))
    (let ((_ (put (tk-verdict (ck-fn tk-ce f)))))
      (put "\n==END==\n")))))

(declare tk-all (=> (List (Pair Str TFn)) Unit))
(def tk-all (lam (rs)
  (case rs
    (nil (unit))
    ((cons p r) (case p ((pair l f) (let ((_ (tk-emit l f))) (tk-all r))))))))

(def tk-rows (List (Pair Str TFn))
  (cons (pair "a1"  tk-a1)
  (cons (pair "a1c" tk-a1c)
  (cons (pair "a2"  tk-a2)
  (cons (pair "a2c" tk-a2c)
  (cons (pair "a3"  tk-a3)
  (cons (pair "a4"  tk-a4)
  (cons (pair "a5"  tk-a5)
  (cons (pair "r1"  tk-r1)
  (cons (pair "r1c" tk-r1c)
  (cons (pair "r2"  tk-r2)
  (cons (pair "r3"  tk-r3)
  (cons (pair "r4"  tk-r4)
  (cons (pair "r5"  tk-r5)
  (cons (pair "r6"  tk-r6)
  (cons (pair "r7"  tk-r7)
  (cons (pair "r8"  tk-r8) nil)))))))))))))))))

(def compile-main (=> I64 I64)
  (lam (n) (let ((_ (tk-all tk-rows))) 0)))
CHIRAL

# ─── helpers (the crypto.sh idiom) ──────────────────────────────────────────
# build_raw LIBDIR OUT -> 0 and OUT holds the fixture's raw stdout.
build_raw() {
  local lib="$1" out="$2" blob="$TMP/o.blob" elf="$TMP/o.elf"
  ( cd "$REPO" && chirality_blob_file "$lib:$REPO/prog" "$FIXTURE" ) >"$blob" 2>/dev/null || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
  ( ulimit -s unlimited; "$elf" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ]
}

# blk LABEL FILE -> the one line inside ==BEGIN label== .. ==END==
blk() {
  awk -v l="==BEGIN $1==" 'BEGIN{p=0} $0==l{p=1;next} p&&$0=="==END=="{exit} p{print}' "$2"
}

# ─── the verdicts, spelled here in bash ─────────────────────────────────────
# Every string below is the byte-exact verdict the fixture must print.  The
# reject strings are check.chiral's own messages, so a repair that widened a
# refusal into a DIFFERENT refusal still moves a row.
W_ACC="accept"
W_ARGS="reject: argument arity or type mismatch"
W_CASE="reject: case on non-data register"
W_RET="reject: ret: type does not match declared return"
W_EXH="reject: non-exhaustive tal case"
W_FLD="reject: con: field arity or type mismatch"

# expect FILE LABEL WANT DESC
expect() {
  local got; got="$(blk "$2" "$1")"
  if [ "$got" = "$3" ]; then ok "$4"
  else bad "$4"; echo "        want: $3"; echo "        got:  $got"; fi
}

echo "=== Phase 22: the tal floor checker (EN-09 / EN-11 repairs) ==="
OUT="$TMP/real.out"
if ! build_raw "$REPO/lib" "$OUT"; then
  echo "  FAIL  the fixture did not build/run against the real lib/"; exit 1
fi

expect "$OUT" a1  "$W_ACC"  "G1  a1  EN-09's erased return argument list -- ACCEPT"
expect "$OUT" a1c "$W_ACC"  "G2  a1c EN-09's one-change control -- ACCEPT"
expect "$OUT" a2  "$W_ACC"  "G3  a2  EN-11's tt-word scrutinee -- ACCEPT"
expect "$OUT" a2c "$W_ACC"  "G4  a2c EN-11's one-change control -- ACCEPT"
expect "$OUT" a3  "$W_ACC"  "G5  a3  EN-10's field position -- ACCEPT"
expect "$OUT" a4  "$W_ACC"  "G6  a4  EN-12's 73, through ck-args -- ACCEPT"
expect "$OUT" a5  "$W_ACC"  "G7  a5  two present argument lists that agree -- ACCEPT"
expect "$OUT" r1  "$W_ARGS" "G8  r1  EN-12's undefined register -- still REFUSED"
expect "$OUT" r1c "$W_ACC"  "G9  r1c EN-12's one-change control -- ACCEPT"
expect "$OUT" r2  "$W_ARGS" "G10 r2  EN-13's ground against data -- still REFUSED"
expect "$OUT" r3  "$W_CASE" "G11 r3  a tt-i64 scrutinee -- still REFUSED"
expect "$OUT" r4  "$W_RET"  "G12 r4  a data-name mismatch -- still REFUSED"
expect "$OUT" r5  "$W_EXH"  "G13 r5  a non-exhaustive tt-word case -- REFUSED, and by the exhaustiveness rule"
expect "$OUT" r6  "$W_CASE" "G14 r6  an unrecoverable arm constructor -- still REFUSED"
expect "$OUT" r7  "$W_RET"  "G15 r7  two present argument lists that disagree -- still REFUSED"
expect "$OUT" r8  "$W_FLD"  "G16 r8  field arity -- still REFUSED"

# ─── G17: the co-import census (the same count diag.sh:267-270 holds) ───────
# Zero now means NOTHING HAS WIRED IT YET.  It no longer means the wiring is
# impossible: the eleven collisions are gone (`tck-` prefix, check.chiral's
# header), and a fixture importing lowering/compile-all beside lowering/tal/check
# compiles and runs.
# What is still missing is the call site itself: ck-prog has none, so this count
# is a measure of enforcement-arc requirement 2 remaining open.
both="$(cd "$REPO" && grep -RIl 'import "lowering/tal/check"' lib prog 2>/dev/null \
         | while read -r f; do grep -q 'import "typing/kernel"' "$f" 2>/dev/null && echo "$f"; done | wc -l)"
if [ "$both" -eq 0 ]; then ok "G17 no module under lib/ or prog/ imports both typing/kernel and lowering/tal/check -- nothing has wired it yet"
else bad "G17 $both module(s) import both typing/kernel and lowering/tal/check"; fi

# ─── G18: the subject is outside the compiler's closure ─────────────────────
# This is the row that says why the mutant harness below is a scratch lib/.  If
# it ever goes red, check.chiral has entered the blob and the BUILD RULE's
# build-new -> test -> promote applies to every edit of it.
CBLOB="$TMP/compiler.blob"
if ( cd "$REPO" && chirality_blob_file "lib:prog" prog/compiler.prog ) >"$CBLOB" 2>/dev/null && [ -s "$CBLOB" ]; then
  nck="$(grep -c 'def ck-prog' "$CBLOB")"
  if [ "$nck" -eq 0 ]; then ok "G18 lowering/tal/check is OUTSIDE the compiler blob ($(wc -c <"$CBLOB") bytes, 0 occurrences of 'def ck-prog')"
  else bad "G18 'def ck-prog' appears $nck time(s) in the compiler blob -- check.chiral entered the closure and the full rebuild applies"; fi
else
  bad "G18 the compiler blob did not assemble; the closure claim is unmeasured"
fi

# ─── the mutant harness ─────────────────────────────────────────────────────
# ⚑ THE SCRATCH lib/ MUST BE A REAL DIRECTORY, NEVER A SYMLINK.  cp -a copies a
# symlink AS a symlink and every sed -i then writes THROUGH it into the tree
# under test (nineteen phantom failures, measured, pretty.sh's arc).
#
# mutate NAME NEEDLE REPLACEMENT -> 0 and MUTLIB holds the scratch lib/ path.
# It sets a GLOBAL rather than echoing one: a command substitution runs in a
# subshell, and every bad/ok inside one is a tally that never reaches the total.
MUTLIB=""
mutate() {
  local name="$1" needle="$2" repl="$3"
  MUTLIB="$TMP/mutlib-$name"
  rm -rf "$MUTLIB"; cp -a "$REPO/lib" "$MUTLIB"
  if [ -L "$MUTLIB" ]; then
    bad "$name -- the scratch lib/ is a SYMLINK; sed would write into the tree under test"; return 1
  fi
  local tgt="$MUTLIB/lowering/tal/check.chiral"
  local n; n="$(grep -cF -- "$needle" "$tgt")"
  if [ "$n" -ne 1 ]; then
    bad "$name -- needle matched $n time(s), not 1 (stale pattern; the mutation would be a lie)"; return 1
  fi
  sed -i "s|$needle|$repl|" "$tgt"
  if cmp -s "$tgt" "$CHECK"; then
    bad "$name -- the mutation did not change check.chiral (stale pattern)"; return 1
  fi
  return 0
}

# red FILE LABEL WAS -> 0 when the row moved off its green value
red() { [ "$(blk "$2" "$1")" != "$3" ]; }

# ─── M1: the B1 recovery returns (none) ─────────────────────────────────────
if mutate M1 '((branch cn dsts body) (ctor-dn ds cn))' '((branch cn dsts body) (none))'; then
  MOUT="$TMP/m1.out"
  if ! build_raw "$MUTLIB" "$MOUT"; then
    bad "M1 -- the mutant did not build/run; UNBUILT measures nothing about the rows"
  elif red "$MOUT" a2 "$W_ACC" && red "$MOUT" r5 "$W_EXH"; then
    if [ "$(blk r3 "$MOUT")" = "$W_CASE" ]; then
      ok "M1 the tt-word recovery removed -- RUN: G3 went red ($(blk a2 "$MOUT")), G13 went red ($(blk r5 "$MOUT")), G11 held"
    else
      bad "M1 -- G3 and G13 moved and G11 moved with them; the rows fail to separate the recovery from the refusal"
    fi
  else
    bad "M1 the tt-word recovery removed -- a row stayed GREEN under the mutant; that row is toothless"
    echo "        a2: $(blk a2 "$MOUT")"; echo "        r5: $(blk r5 "$MOUT")"
  fi
fi

# ─── M2: tal-ty=?'s tt-data arm goes back to the strict tys=? ───────────────
if mutate M2 '(targs=? as1 as2)' '(tys=? as1 as2)'; then
  MOUT="$TMP/m2.out"
  if ! build_raw "$MUTLIB" "$MOUT"; then
    bad "M2 -- the mutant did not build/run; UNBUILT measures nothing about the rows"
  elif red "$MOUT" a1 "$W_ACC" && red "$MOUT" a3 "$W_ACC" && red "$MOUT" a4 "$W_ACC"; then
    ok "M2 the empty-argument-list wildcard removed -- RUN: G1 ($(blk a1 "$MOUT")), G5 ($(blk a3 "$MOUT")) and G6 ($(blk a4 "$MOUT")) all went red"
  else
    bad "M2 the empty-argument-list wildcard removed -- a row stayed GREEN under the mutant; that row is toothless"
    echo "        a1: $(blk a1 "$MOUT")"; echo "        a3: $(blk a3 "$MOUT")"; echo "        a4: $(blk a4 "$MOUT")"
  fi
fi

# ─── M3: targs=? accepts two PRESENT lists as well ──────────────────────────
# The mutant that turns the wildcard into a blanket accept.  If G15 stays green
# under it, this gate cannot tell a relaxation from a hole.
if mutate M3 '(_ (tys=? as bs))' '(_ true)'; then
  MOUT="$TMP/m3.out"
  if ! build_raw "$MUTLIB" "$MOUT"; then
    bad "M3 -- the mutant did not build/run; UNBUILT measures nothing about the rows"
  elif red "$MOUT" r7 "$W_RET"; then
    ok "M3 the wildcard widened to two present lists -- RUN: G15 went red ($(blk r7 "$MOUT"))"
  else
    bad "M3 the wildcard widened to two present lists -- G15 stayed GREEN; that row cannot tell a relaxation from a hole"
  fi
fi

echo
echo "  tal-check.sh: $pass ok, $fail FAIL, $((SECONDS - T0))s wall (records, sets no bar)"
[ "$fail" -eq 0 ] || exit 1
exit 0
