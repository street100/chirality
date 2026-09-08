#!/usr/bin/env bash
# diag.sh -- E157: diagnostics as typed values. The Phase 13 gate.
#
# E157 widened the EIGHT containers of the checker/loader error closure
# (typing/kernel.chiral's TcR/CkR/FtR/UR/CaseR/EscR, module/loader.chiral's
# LoadR/ChkR) so their payload is a closed `Reason` value instead of a str-cat'd
# sentence, retired E159's `XErr` and kernel's `LinErr` into it, and put the one
# rendering (`dg-msg`) at the module boundary, in typing/diag.chiral.
#
# ⚑ WHAT THIS GATE HAS TO SEE, and why the obvious gate cannot. Every message
# the compiler emits after E157 is a message it emitted before, so a fixture
# that compares only strings passes with the evidence dropped -- which is the
# state the element exists to end (the E156 lesson: a gate fixture can be blind
# to its own mutant). So every row here that matters is paired with a NAMED
# MUTANT: a stated corruption of the source, and the outcome it must produce. A
# row whose mutant also passes is a row that exercises nothing.
#
# G1  the runtime fixture -- text preservation AND evidence survival
# G2  the named mutants, at the typing/diag.chiral level (the fixture must go red)
# G3  the end-to-end goldens, through a real compile -- including the FIRST
#     assertion anywhere on "let binder usage mismatch" (typing/kernel.chiral
#     close-binder), which no test pinned before E157
# G4  the r-relayed CONTAINMENT invariant: only ingress sites may build one
# G5  closure integrity: nothing outside the closure changed type, and
#     lowering/tal/check.chiral still owns its own CkR (it is not co-blobbed
#     with kernel's)
# G6  E154: every name typing/diag.chiral introduces is defined exactly once
#     tree-wide
#
# Zero Python -- here as everywhere in this harness, including G6's census,
# which the old tree ran through a python walk.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"

CC="${CHIRALITY_COMPILE:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
[ -x "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
# shellcheck disable=SC1091
. "$REPO/bin/chirality-resolve.sh"

FIXTURE="$HERE/samples/e157_diag.prog"
[ -f "$FIXTURE" ] || { echo "  FAIL  $FIXTURE missing -- a gate without its fixture cannot fail"; exit 2; }
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()   { echo "  ok    $1"; pass=$((pass+1)); }
bad()  { echo "  FAIL  $1"; fail=$((fail+1)); }

# ---- helpers ---------------------------------------------------------------
# build_run ROOTSPEC SRC -> exit code of the compiled program (255 = compile error)
build_run() {
  local rootspec="$1" src="$2" blob="$TMP/b.$$" elf="$TMP/e.$$"
  ( cd "$REPO" && chirality_blob_file "$rootspec" "$src" ) >"$blob" 2>/dev/null || return 255
  ( ulimit -s unlimited; "$CC" <"$blob" >"$elf" 2>/dev/null ) || return 255
  [ -s "$elf" ] || return 255
  chmod +x "$elf"
  ( ulimit -s unlimited; "$elf" >/dev/null 2>&1 )
  local rc=$?
  rm -f "$blob" "$elf"
  return $rc
}

# refuse_msg COMPILER SRCTEXT -> the compiler's stderr for that source
refuse_msg() {
  local cc="$1" f="$TMP/s.$$"
  printf '%s' "$2" >"$f"
  ( ulimit -s unlimited; "$cc" <"$f" >/dev/null 2>"$TMP/e.txt" )
  cat "$TMP/e.txt"
}

# ============================================================================
echo
echo "=== E157 G1: the runtime fixture -- text preservation AND evidence survival ==="
build_run "lib:prog" "$FIXTURE"
rc=$?
if [ $rc -eq 0 ]; then ok "e157_diag: 21 cases, incl. the evidence rows (exit 0)"
else bad "e157_diag: first failing case = $rc"; fi

# ============================================================================
# Each mutant names ONE corruption of lib/typing/diag.chiral and the case number
# the fixture must then report. A mutant that leaves the fixture at 0 means the
# row it targets is decorative.
echo
echo "=== E157 G2: the named mutants (a row whose mutant passes exercises nothing) ==="
mutant() {  # mutant NAME WANT-CASE SED-EXPR
  local name="$1" want="$2" expr="$3"
  local lib="$TMP/mutlib"
  rm -rf "$lib"; cp -a "$REPO/lib" "$lib"
  if ! sed -i "$expr" "$lib/typing/diag.chiral"; then bad "$name -- sed failed"; return; fi
  if cmp -s "$lib/typing/diag.chiral" "$REPO/lib/typing/diag.chiral"; then
    bad "$name -- the mutation did not change typing/diag.chiral (stale pattern)"; return
  fi
  build_run "$lib:$REPO/prog" "$FIXTURE"
  local got=$?
  if [ "$got" = "$want" ]; then ok "$name -- fixture fails at case $got, as required"
  else bad "$name -- fixture exited $got, wanted $want"; fi
}

# M1: DROP THE INCUMBENT. dg-incumbent stops returning the redeclare's first
# declaration. Every TEXT row still passes -- "data redeclared: Box" does not
# mention it -- so this is precisely the mutant a text-only fixture cannot see.
mutant "M1 drop-the-incumbent (dg-incumbent -> dc-none)" 13 \
  's/((r-redeclared w i nw) i)/((r-redeclared w i nw) (dc-none))/'
# M2: ALIAS THE TWO SIDES. Both declarations come back, but they are the SAME
# one -- the classic "carry evidence, lose the disagreement" failure.
mutant "M2 alias-the-sides (dg-newcomer -> the incumbent)" 14 \
  's/((r-redeclared w i nw) nw)/((r-redeclared w i nw) i)/'
# M3: COLLAPSE OBSERVED ONTO DECLARED. A usage refusal that reports what was
# promised twice cannot show the mismatch it is about.
mutant "M3 collapse-observed (dg-observed -> declared)" 16 \
  's/((r-usage      w d o)  o)/((r-usage      w d o)  d)/'
# M4: MOVE THE TEXT. One byte of one message; the evidence rows are unaffected.
mutant "M4 reword-the-let-message" 2 \
  's/"let binder usage mismatch"/"let binder usage mismatched"/'
# M5: DROP AN INGRESS PREFIX. The relay layer stops contributing "data-group: ".
mutant "M5 drop-the-relay-prefix (rl-parse)" 12 \
  's/((rl-parse)  (str-cat "data-group: " m))/((rl-parse)  m)/'
# M6: LOSE AN ARM'"'"'S IDENTITY. Two Reason arms report the same tag, so the
# exhaustiveness row can no longer tell them apart.
mutant "M6 merge-two-tags (r-linear reports as usage)" 19 \
  's/((r-linear     w q)    "linear")/((r-linear     w q)    "usage")/'

# ============================================================================
echo
echo "=== E157 G3: the end-to-end goldens, through a real compile ==="
golden() {  # golden DESC EXPECTED-STDERR SRC
  local got; got="$(refuse_msg "$CC" "$3")"
  if [ "$got" = "$2" ]; then ok "$1"
  else bad "$1 -- got: $got"; fi
}
M='(def compile-main (-> I64 I64) (lam (n) 42))'

# ⚑ THE UNTESTED TWIN (E157 decision 9). kernel's close-binder has said
# "let binder usage mismatch" since E04 and NO test asserted it -- measured.
# Step 2 rewrote that line, so shipping it still untested is how the gap
# survives an atomic commit. This is its first assertion anywhere.
golden "let binder usage mismatch (close-binder -- FIRST assertion)" \
  "load: let binder usage mismatch" \
  '(def compile-main (-> I64 I64) (lam (n) (let (0 x n) x)))'
golden "linear binder usage mismatch (strip-binder -- the hard golden)" \
  "load: linear binder usage mismatch" \
  '(porttype Cap)
(extern mint (=> I64 Cap))
(def sink (=> (1 c Cap) I64) (lam (c) 42))
'"$M"
golden "data redeclared -- BOTH decls now ride along" \
  "load: data redeclared: Box" \
  '(data Box () (mk (v I64)))
(data Box () (mk (v I64)))
'"$M"
golden "extern redeclared (XErr retired, wording kept)" \
  "load: extern redeclared: foo" \
  '(extern foo (-> I64 I64))
(extern foo (-> I64 I64))
'"$M"
golden "extern linear result behind a pure arrow (XErr -> r-arrow)" \
  'load: extern mint returns the linear Cap through a pure `->` arrow: a minted capability must cross (`=>`), else it is never tracked at q1' \
  '(porttype Cap)
(extern mint (-> I64 Cap))
'"$M"
golden "atom type redeclared" "load: atom type redeclared: Cap" \
  '(porttype Cap)
(porttype Cap)
'"$M"
golden "the reader RELAYS in with its own prefix (rl-reader)" \
  "load: parse: unclosed ( at 1:43 depth=1" \
  '(def compile-main (-> I64 I64) (lam (n) 42)'
golden "the data-group path relays with its prefix (rl-parse)" \
  "load: data-group: bad data parameter (want (P kind))" \
  '(data Bad (42) (b))
'"$M"
golden "a judgment with no evidence but its form" \
  "load: non-exhaustive case" \
  '(data Tri () (a) (b) (c))
(def compile-main (-> I64 I64) (lam (n) (case (a) ((a) 1) ((b) 2))))'

# the compiler-level mutant for the untested twin: flip close-binder's subject
# and the let refusal starts saying the LAMBDA binder's sentence. If the golden
# above cannot see that, it is pinning nothing.
echo
echo "=== E157 G3m: the compiler-level mutant behind the untested twin ==="
mlib="$TMP/cclib"; rm -rf "$mlib"; cp -a "$REPO/lib" "$mlib"
sed -i 's/(ck-err (r-usage (subj-let-binder) q (last-qty ub)))/(ck-err (r-usage (subj-lam-binder) q (last-qty ub)))/' "$mlib/typing/kernel.chiral"
if cmp -s "$mlib/typing/kernel.chiral" "$REPO/lib/typing/kernel.chiral"; then
  bad "M7 close-binder-subject-flip -- the mutation did not apply (stale pattern)"
else
  ( cd "$REPO" && chirality_blob_file "$mlib:$REPO/prog" "$REPO/prog/compiler.prog" ) >"$TMP/m.blob" 2>/dev/null
  if ( ulimit -s unlimited; "$CC" <"$TMP/m.blob" >"$TMP/mcc" 2>/dev/null ) && [ -s "$TMP/mcc" ]; then
    chmod +x "$TMP/mcc"
    mgot="$(refuse_msg "$TMP/mcc" '(def compile-main (-> I64 I64) (lam (n) (let (0 x n) x)))')"
    if [ "$mgot" = "load: let binder usage mismatch" ]; then
      bad "M7 close-binder-subject-flip -- mutant still says the same thing"
    else
      ok "M7 close-binder-subject-flip -- mutant says: $mgot"
    fi
  else
    bad "M7 close-binder-subject-flip -- the mutant compiler did not build"
  fi
fi

# ============================================================================
# The invariant that keeps r-relayed from becoming `r-legacy` in a hat: all ~50
# ORIGINATING detection sites know their own reason, so only a site where a
# layer BELOW the checker hands one up may build an r-relayed. Anywhere else is
# the string defect re-created under a new name, and this is the only row that
# can see it.
echo
echo "=== E157 G4: the r-relayed containment invariant ==="
ing="$(cd "$REPO" && grep -c '(r-relayed ' lib/surface/parse.chiral lib/module/load-batch.chiral \
        | awk -F: '{s+=$2} END {print s+0}')"
if [ "$ing" -eq 10 ]; then ok "r-relayed built at exactly the 10 ingress lines (parse 5 + load-batch 5)"
else bad "r-relayed built at $ing ingress lines, wanted 10"; fi
# ⚑ grep -r does NOT follow symlinks; -R does. This tree has none today, and a
# census that silently skips a file is the failure mode this row exists to stop.
#
# The scope is the SOURCE the compiler is built from -- lib/ and prog/. This
# gate's own fixture is excluded by name, not by accident: e157_diag.prog builds
# one value of every Reason arm on purpose (that IS the exhaustiveness row), and
# it is not a detection site in any compiler. The exclusion list is three files
# long and every entry is a place r-relayed is SUPPOSED to appear.
relayed_census() {
  (cd "$REPO" && grep -RIn '(r-relayed ' lib prog tools 2>/dev/null) \
    | grep -v '^lib/surface/parse.chiral:' \
    | grep -v '^lib/module/load-batch.chiral:' \
    | grep -v '^lib/typing/diag.chiral:' \
    | grep -v '^tools/test/diag.sh:' \
    | grep -v '^tools/test/samples/e157_diag.prog:'
}
out="$(relayed_census | wc -l)"
if [ "$out" -eq 0 ]; then ok "no ORIGINATING site anywhere reaches for r-relayed"
else bad "$out r-relayed construction(s) outside the ingress set:"
     relayed_census | sed 's/^/          /'; fi
# and its from-field is a closed sum, so a new ingress SOURCE is a compile error
# rather than a new string nobody notices.
if (cd "$REPO" && grep -q '(data Relay ()' lib/typing/diag.chiral) \
   && ! (cd "$REPO" && grep -q '(r-relayed    (from Str)' lib/typing/diag.chiral); then
  ok "r-relayed's from-field is the closed Relay sum, never a Str"
else bad "r-relayed's from-field is not a closed sum"; fi

# ============================================================================
echo
echo "=== E157 G5: closure integrity -- nothing outside the closure moved ==="
keep() {  # keep FILE PATTERN DESC
  if (cd "$REPO" && grep -qF "$2" "$1"); then ok "$3"; else bad "$3 -- '$2' not found in $1"; fi
}
keep lib/surface/parse.chiral          '(step-err (msg Str))'   "StepR keeps its Str payload"
keep lib/module/load-batch.chiral      '(batch-err  (msg Str))' "BatchR keeps its Str payload"
keep prog/optimizer-census.prog        '(chk-err (msg Str))'    "Checked keeps its Str payload"
keep lib/lowering/compile-front.chiral '(fr-err (msg Str))'     "FrontR keeps its Str payload"
keep lib/surface/data.chiral           '(pos-bad (reason Str))' "PosR keeps its Str payload"
# decision 2: lowering/tal/check has its OWN verdict sum with its own Str
# payload, and E157's widening must not sweep it. It used to spell that sum CkR
# with a ck-err arm, which is exactly what made the row fragile -- a tree-wide
# ck-err rewrite would have corrupted it silently. The sum is TckR/tck-err now
# (E154's flat-namespace hand-patch, check.chiral's header), so the literal this
# row greps for is unique to that file by CONSTRUCTION and no longer merely by
# luck. The guarantee is unchanged: tal/check keeps a Str payload of its own.
keep lib/lowering/tal/check.chiral     '(tck-err (msg Str))'    "tal/check still owns its own verdict sum with a Str payload"
# The co-import count. It used to say the two verdict sums COULD NOT meet: the
# import was `load: data redeclared: CkR` before any type-checking ran. The
# eleven collisions are `tck-` prefixed now and the co-import loads and runs, so
# zero says something weaker and truer: NO ONE MODULE REACHES BOTH NAMESPACES.
# `ck-prog` still has no call site anywhere in lib/ or prog/ (enforcement-arc
# requirement 2), verified 2026-09-05.
#
# ⚑ THE `Checked` ROW ABOVE READS `prog/optimizer-census.prog` FROM 2026-09-08.
# The sum lived at `lib/lowering/upper/optimize.chiral:22` from E17 until the
# author's PRB-70 ruling took `lowering/tal/check` back out of the compiler
# closure; `re-check` and `Checked` moved to the census probe whole. The
# invariant is what it always was: a sum outside E157's widening keeps its Str
# payload, and the widening did not sweep it.
#
# The count stays zero, and the reason changed with it. Only
# `prog/optimizer-census.prog` imports `lowering/tal/check` now, and it imports
# no `typing/kernel`. `lib/lowering/compile-back.chiral` reaches neither: it
# still imports `lowering/upper/optimize` for `fold`, and optimize points at
# `lowering/tal/ssa` for the typed IR. tools/test/tal-check.sh G18 asserts the
# closure claim and reads green.
both="$(cd "$REPO" && grep -RIl 'import "lowering/tal/check"' lib prog 2>/dev/null \
         | while read -r f; do grep -q 'import "typing/kernel"' "$f" 2>/dev/null && echo "$f"; done | wc -l)"
if [ "$both" -eq 0 ]; then ok "no module imports both typing/kernel and lowering/tal/check (nothing has wired it yet)"
else bad "$both module(s) import both typing/kernel and lowering/tal/check"; fi
# the eight containers really did widen
w="$(cd "$REPO" && grep -c '(why Reason)' lib/typing/kernel.chiral lib/module/loader.chiral | awk -F: '{s+=$2} END {print s}')"
if [ "$w" -eq 8 ]; then ok "all EIGHT containers carry (why Reason)"
else bad "$w containers carry (why Reason), wanted 8"; fi
# and the two retired sums are really gone
g=0
(cd "$REPO" && grep -q '(data XErr ()' lib/module/loader.chiral) && g=$((g+1))
(cd "$REPO" && grep -q '(data LinErr ()' lib/typing/kernel.chiral) && g=$((g+1))
if [ "$g" -eq 0 ]; then ok "XErr (E159) and LinErr are retired, not left beside Reason"
else bad "$g of the two retired sums is still declared"; fi

# ============================================================================
# E154: the emitted-label namespace is FLAT, so two co-blobbed modules cannot
# define the same internal name. Every name typing/diag.chiral introduces must
# be defined exactly once across the whole tree.
#
# The old tree ran this census through a python walk. It is shell here: the
# names are read out of diag.chiral itself (so a new arm is censused without
# editing this script), and the search is `grep -R` -- NOT `grep -r`, which does
# not follow symlinks and would make a skipped file look like a clean census.
echo
echo "=== E157 G6: E154 -- every typing/diag.chiral name is defined exactly once ==="
DIAG="$REPO/lib/typing/diag.chiral"
{
  # top-level def / data / declare heads
  grep -oE '^\((def|data|declare) [^ ()]+' "$DIAG" | awk '{print $2}'
  # every constructor head inside this file's data forms, by their reserved prefixes
  grep -oE '\((r-|subj-|jg-|dc-|rl-)[A-Za-z0-9?!*<>=+-]*' "$DIAG" | sed 's/^(//'
} | sort -u > "$TMP/names.txt"
nnames="$(wc -l <"$TMP/names.txt")"
: >"$TMP/dupes.txt"
while read -r n; do
  [ -n "$n" ] || continue
  (cd "$REPO" && grep -RIn -E "^\((def|data|declare) ${n}[[:space:]]" lib prog 2>/dev/null \
     | grep -v '^lib/typing/diag.chiral:' ) >>"$TMP/dupes.txt" || true
  (cd "$REPO" && grep -RIn -E "\(${n}[ )]" lib prog 2>/dev/null \
     | grep -v '^lib/typing/diag.chiral:' \
     | grep -E "^[^:]+:[0-9]+:[[:space:]]*\(${n}[ )]" ) >>"$TMP/dupes.txt" || true
done <"$TMP/names.txt"
# a use is not a definition: only DEFINING occurrences count as a collision.
# The second grep above is deliberately narrow (a form in head position at the
# start of a line) and its hits are reported for the reader, not counted.
defdupes="$(grep -E '^[^:]+:[0-9]+:\((def|data|declare) ' "$TMP/dupes.txt" | sort -u || true)"
if [ -z "$defdupes" ]; then ok "none of the $nnames typing/diag.chiral names is redefined anywhere in lib/ or prog/"
else bad "typing/diag.chiral names redefined elsewhere:"; echo "$defdupes" | sed 's/^/          /'; fi

echo
echo "typed diagnostics (E157): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
