#!/usr/bin/env bash
# capture-fields.sh -- the E186 gate: the `$k<i>_<j>` capture constructor's
# field types stay at the capture's OWN source type, and the erased word is
# reached ONLY where that source type has no ground spelling.
#
# not-a-phase: E186's number waits on the standing author call -- four documents disagree about 21-23.
# ⚑ NO SUITE PHASE NUMBER IS ASSIGNED, and the row that would hold one is
# already open.  `records/author-calls.md` carries a standing row, *Which suite
# phase number a new gate takes*: `tools/test/run-tests.sh:332` and
# `docs/decisions/decision-lane-split.md:30` reserve 21 through 23 for Lane B,
# `tools/test/tal-check.sh:5` claims 22, and `docs/definitions/testing-floors.md:69`
# reads 21 the other way, while 8 through 12 stay owed to unported old-tree
# phases.  E186 opens NO new call.  This gate takes the `crypto.sh` /
# `tal-check.sh` / `apply-word.sh` route instead -- a `not-a-phase:` declaration
# with a reason, which keeps `tools/test/registration.sh` G2 and G4 green -- and
# it runs BY HAND until the author settles the number.  It is the EIGHTH `PEND`
# and the FOURTH script waiting on that one number.  A DEBT, discharged when the
# number is settled.
#
# What `tools/test/run-tests.sh` witnesses of E186 is ONE thing: Phase 7's root
# census moves 88 -> 89, because `prog/e186-capture-fields.prog` is a new root
# and must compile.
#
# ─── THE FOUR ROWS ──────────────────────────────────────────────────────────
# All four are judged by `prog/e186-capture-fields.prog` over
# `tools/test/samples/e186_capture_fields.prog`, and every one reads what a
# compile produced.  They are reported on ONE line and every mutant pins the
# WHOLE line: `records/gate-audit.md` GA-21 and GA-22 both convict a gate that
# names one row per mutant, because a mutant reddening a row outside its own pin
# is then invisible.  M1 is exactly that case here -- it is pinned at R2 and it
# reddens R3 as well.
#
#   R1  $clo0 reaches datas->n's output with four ctors, arities 0/1/2/3
#   R2  the two-field ctor's fields are nt-i64 then (nt-data "List" ((nt-str))),
#       and neither is nt-word                                   <- THE RULING
#   R3  the one-field ctor's field is nt-word and its source Term is t-pi --
#       the word is still reached where the source has no ground spelling
#   R4  ctor-honest? holds over EVERY $clo ctor: no field lowered to the word
#       whose source Term has a ground spelling
#
# ⚑ R2 AND R3 ARE THE TWO DIRECTIONS OF ONE PARTITION and both are needed.  R2
# alone permits a tree that never reaches the word; R3 alone permits one that
# reaches it everywhere.
#
# ⚑ R4 IS THE ROW WITH A FALSIFIER OF ITS OWN, and it is the fixture's fourth
# site that gives it one.  Over the first three sites R2 ∧ R3 ⟹ R4: every field
# of every ctor is golden-pinned by R2 or R3, so R4 could not go red alone.  The
# three-field ctor is pinned by NEITHER golden -- R2 names the two-field ctor and
# R3 names the one-field one -- so R4's clause on its three fields is not
# entailed, and M5 is the witness.  R4 is also the only row quantified over every
# ctor rather than pinned to a named one, so a later fixture site or a third
# erasing arm in `term->ntalty` is caught without a new golden.
#
# ⚑ THE PROBE ASSERTS NOTHING and always exits 0.  Every comparison below is
# bash against a string constant held HERE, over the probe's bytes: a gate that
# re-derives its own verdict is green under any mutant that changes what the
# verdict SAYS (the pretty.sh / tal-check.sh / apply-word.sh rule).
#
# ⚑ NO ROW READS `ck-prog`.  EN-20 measured a live miscompile that `ck-prog`
# accepts in silence whenever the family codomain is ground, so nothing here
# leans on it catching anything.  The probe also imports nothing under
# `lowering/tal/`, for E154's eleven colliding top-level names.
#
# ⚑ NOTHING HERE BUILDS A COMPILER.  E186 changes no file under `lib/`, so the
# blob is byte-identical by construction and the build rule
# (`docs/definitions/working-discipline.md`) has no subject: there is no
# `build-new -> test -> promote` and no byte fixpoint in this element.  The
# mutant harness rebuilds the PROBE against a scratch `lib/`, never the compiler.
#
# ─── THE MUTANTS, AND ALL FIVE ARE SUBSTITUTIONS ────────────────────────────
# `records/gate-audit.md` GA-19: deleting an arm makes the module
# non-exhaustive, the compiler refuses the mutated tree, and the row is graded
# on a compile refusal instead of on the property it names.  Nothing below
# removes an arm or changes an arity.  Each substitution's occurrence count is
# asserted at exactly 1 and the mutated file is `cmp -s`'d against the base
# before it is built (GA-18).  A mutant that does not assemble, build or run
# scores `bad` with `UNBUILT measures nothing` -- a `nobuild` is never a pass.
#
# ⚑ `lib/` IS THE SCOPE OF THE NEEDLE COUNT, and it is the scope that matters:
# `mutate` copies `lib/` alone and greps the ONE file it mutates.  M1's, M2's
# and M5's needle strings also appear under `docs/`, in the E186 SPEC and in two
# worked examples, and the harness never sees them.
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

FIXTURE="$REPO/tools/test/samples/e186_capture_fields.prog"
PROBE="$REPO/prog/e186-capture-fields.prog"
DRIVER_SRC="$REPO/lib/lowering/upper/closconv-driver.chiral"
FRONT_SRC="$REPO/lib/lowering/compile-front.chiral"
for f in "$FIXTURE" "$PROBE" "$DRIVER_SRC" "$FRONT_SRC"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its subject cannot fail"; exit 2; }
done

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }

# ─── helpers ────────────────────────────────────────────────────────────────
# fixture_blob LIBDIR OUT
fixture_blob() {
  ( cd "$REPO" && chirality_blob_file "$1:$REPO/prog" "$FIXTURE" ) >"$2" 2>/dev/null && [ -s "$2" ]
}

# probe_run LIBDIR FIXBLOB OUT -> OUT holds the probe's raw stdout
probe_run() {
  local lib="$1" fb="$2" out="$3" blob="$TMP/pr.blob" elf="$TMP/pr.elf"
  ( cd "$REPO" && chirality_blob_file "$lib:$REPO/prog" "$PROBE" ) >"$blob" 2>/dev/null || return 1
  [ -s "$blob" ] || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
  ( ulimit -s unlimited; "$elf" <"$fb" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ]
}

# four_tokens FILE -> the probe's four tokens
four_tokens() { sed -n 's/^==E186== //p' "$1" | head -1; }

# ─── the base run ───────────────────────────────────────────────────────────
echo "=== E186 (UNREGISTERED): the \$k<i>_<j> capture ctor's field types are concrete ==="
BASEBLOB="$TMP/fix.blob"
if ! fixture_blob "$REPO/lib" "$BASEBLOB"; then
  echo "  FAIL  the fixture blob did not assemble"; exit 1
fi
BOUT="$TMP/base.out"
if ! probe_run "$REPO/lib" "$BASEBLOB" "$BOUT"; then
  echo "  FAIL  the probe did not build/run against the real lib/"; exit 1
fi
VERDICT="$(four_tokens "$BOUT")"
echo "  line  $VERDICT"
sed -n '2,6p' "$BOUT" | sed 's/^/      /'

r()  { echo "$VERDICT" | cut -d' ' -f"$1"; }
row() { # row N NAME WANT
  local got; got="$(r "$1")"
  if [ "$got" = "$3" ]; then ok "R$1 $2"; else bad "R$1 $2 -- got '$got', want '$3'"; fi
}
row 1 "\$clo0 has four ctors, arities 0/1/2/3"                    ok
row 2 "the two-field ctor is nt-i64 then (nt-data List (nt-str))" ok
row 3 "the one-field ctor is nt-word and its source is t-pi"      ok
row 4 "ctor-honest? holds over every \$clo0 ctor"                 ok

ALLOK="ok ok ok ok"
if [ "$VERDICT" != "$ALLOK" ]; then
  echo
  echo "  the base line is not ALLOK; the mutants are NOT run (silent failure 4:"
  echo "  a mutant graded against an already-red base measures nothing)."
  echo
  echo "  capture-fields.sh: $pass ok, $fail FAIL, $((SECONDS - T0))s wall (records, sets no bar)"
  exit 1
fi

# ─── the mutant harness ─────────────────────────────────────────────────────
# ⚑ THE SCRATCH lib/ MUST BE A REAL DIRECTORY, NEVER A SYMLINK.  cp -a copies a
# symlink AS a symlink and every sed -i then writes THROUGH it into the tree
# under test (the pretty.sh arc, nineteen phantom failures).
MUTLIB=""
mutate() {  # mutate NAME RELPATH NEEDLE REPLACEMENT
  local name="$1" rel="$2" needle="$3" repl="$4"
  MUTLIB="$TMP/mutlib-$name"
  rm -rf "$MUTLIB"; cp -a "$REPO/lib" "$MUTLIB"
  if [ -L "$MUTLIB" ]; then
    bad "$name -- the scratch lib/ is a SYMLINK; sed would write into the tree under test"; return 1
  fi
  local tgt="$MUTLIB/$rel"
  local n; n="$(grep -cF -- "$needle" "$tgt")"
  if [ "$n" -ne 1 ]; then
    bad "$name -- needle matched $n time(s), not 1 (stale pattern; the mutation would be a lie)"; return 1
  fi
  sed -i "s|$needle|$repl|" "$tgt"
  if cmp -s "$tgt" "$REPO/$rel"; then
    bad "$name -- the mutation did not change $rel (stale pattern)"; return 1
  fi
  return 0
}

# run_mutant NAME PIN DESC  (MUTLIB already set by mutate)
run_mutant() {
  local name="$1" pin="$2" desc="$3"
  local fb="$TMP/$name.fix.blob" out="$TMP/$name.out" line
  if ! fixture_blob "$MUTLIB" "$fb"; then
    bad "$name -- BUILD:fail, the fixture blob did not assemble under the mutant lib; UNBUILT measures nothing"; return
  fi
  if ! probe_run "$MUTLIB" "$fb" "$out"; then
    bad "$name -- BUILD:fail, the probe did not build/run under the mutant; UNBUILT measures nothing"; return
  fi
  line="$(four_tokens "$out")"
  if [ "$line" = "$pin" ]; then
    ok "$name $desc -- RUN: '$line'"
  else
    bad "$name $desc -- RUN: '$line', pinned '$pin'"
  fi
  sed -n '2,6p' "$out" | sed 's/^/      /'
}

# M1: every kept field's source Term is spelled as an erased variable -- the
# OPPOSITE ruling, as closely as `Core` can express it.  It reddens R2 AND R3:
# R3 asserts the one-field ctor's SOURCE is t-pi, and M1 rewrites that too.
# ⚑ IT IS ALSO A MEASURED LIMIT ON `ctor-honest?`.  Under M1 the probe reads
# `src: t-var:0` against `low: nt-word` and R4 stays GREEN, because the
# predicate compares a field's lowering against that field's OWN declared Term
# and a driver that rewrites the source is self-consistent.  R2 is what catches
# it.  R4 alone does not separate `concrete` from `word`.
if mutate M1 "lowering/upper/closconv-driver.chiral" \
    '(str-cat "cap" (i64->str n)) (core->term fty)' \
    '(str-cat "cap" (i64->str n)) (t-var 0)'; then
  run_mutant M1 "ok bad bad ok" "every kept field's source Term erased to a variable"
fi

# M2: a ground source spelling lowers to the word.
if mutate M2 "lowering/compile-front.chiral" \
    '(str-eq n "I64") (true (some (nt-i64)))' \
    '(str-eq n "I64") (true (some (nt-word)))'; then
  run_mutant M2 "ok bad ok bad" "the I64 source spelling lowers to the word"
fi

# M3: the word is no longer reached where the source has no ground spelling.
if mutate M3 "lowering/compile-front.chiral" \
    '((t-pi _ _ _ _) (some (nt-word)))' \
    '((t-pi _ _ _ _) (some (nt-i64)))'; then
  run_mutant M3 "ok ok bad ok" "the arrow source no longer reaches the word"
fi

# M4: `field-tys->n` fails on the (List Str) field, `ctors->n` returns none for
# the whole DataDecl, `datas->n` drops $clo0, and the subject never arrives.
if mutate M4 "lowering/compile-front.chiral" \
    '((t-tcon dn args) (case (term->ntalty-list args) ((some ts) (some (nt-data dn ts))) (none (none))))' \
    '((t-tcon dn args) (none))'; then
  run_mutant M4 "bad absent absent absent" "the applied-data arm stops lowering, \$clo0 is dropped"
fi

# M5: R4's own falsifier.  The three-field site's `Bytes` capture lowers to the
# word while its source Term is `(t-primty "Bytes")`, which
# `no-ground-spelling?` does not admit -- so `ctor-honest?` is false on a ctor
# NO GOLDEN PINS, and R4 reddens ALONE.
if mutate M5 "lowering/compile-front.chiral" \
    '(str-eq n "Bytes") (true (some (nt-bytes)))' \
    '(str-eq n "Bytes") (true (some (nt-word)))'; then
  run_mutant M5 "ok ok ok bad" "the Bytes source spelling lowers to the word -- R4 alone"
fi

echo
echo "  capture-fields.sh: $pass ok, $fail FAIL, $((SECONDS - T0))s wall (records, sets no bar)"
[ "$fail" -eq 0 ] || exit 1
exit 0
