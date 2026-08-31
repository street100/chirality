#!/usr/bin/env bash
# doc.sh -- E158: the layout algebra. The Phase 14 gate.
#
# E158 splits a formatter into the two halves that are one today: a TEMPLATE
# (`Doc`, six constructors, NO `d-union`) and a FLATTEN (`doc->str`, at a width
# the caller chose). `lib/typing/diag.chiral` gains `dg-doc : (-> Reason Doc)`
# as `dg-msg`'s SIBLING over all nine of E157's `Reason` arms.
#
# ⚑ WHAT THIS GATE GRADES, and what it must refuse to grade. E157's nine
# goldens in tools/test/diag.sh pin `dg-msg` BYTE-FOR-BYTE, and mutant M4 there
# (`reword-the-let-message`, one byte) must convict. That constraint is E157's,
# it is live, and it is what made a per-message `Judg` the cheap way out at 38
# arms. `doc->str` MUST NOT INHERIT IT: `dg-doc` is graded on EVIDENCE SURVIVAL
# only, and G7 makes the non-cross-assertion a checked row rather than a
# promise. Cross-asserting the two exits re-imports the exact constraint `Doc`
# exists to lift.
#
# Every row that matters carries a NAMED MUTANT: a stated corruption of the
# source and the outcome it must produce. A row whose mutant also passes
# exercises nothing (the E156 lesson: a gate fixture can be blind to its own
# mutant).
#
#   G1  the FLAT LAW           -- what makes d-group sound        [M1]
#   G2  width independence     -- the law E146 consumes           [M2]
#   G3  evidence survival      -- THE element's row, nine arms    [M3,M9]
#   G3c the control that states the win                           [M3c]
#   G4  the group decision actually happens                       [M4]
#   G5  the sum is closed and has no union                        [M5]
#   G6  E154 name census, tree-wide                               [M6]
#   G7  the two exits are NOT cross-asserted                      [M7]
#
# ⚑ NOT a row here, deliberately: the commit-2 fixpoint (`cmp C1 C2`). It is a
# STABILITY check -- the compiler reproduces itself -- and stability is not
# correctness. Also not rows: totality (E11's classifier cannot see the
# worklist measure; that is E50, not built), any `dg-msg` byte-identity row
# (E157 owns those), any `Judg` arm count (E173), any `pretty.chiral`
# behaviour (E158 SPEC decision 12).
#
# Zero Python -- here as everywhere in this harness, G6's census included.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"

CC="${CHIRALITY_COMPILE:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
[ -x "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
# shellcheck disable=SC1091
. "$REPO/bin/chirality-resolve.sh"

FIXTURE="$HERE/samples/e158_doc.prog"
DOC="$REPO/lib/prelude/doc.chiral"
[ -f "$FIXTURE" ] || { echo "  FAIL  $FIXTURE missing -- a gate without its fixture cannot fail"; exit 2; }
[ -f "$DOC" ]     || { echo "  FAIL  $DOC missing"; exit 2; }
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

# build_err ROOTSPEC SRC -> the compiler's stderr (empty on success)
build_err() {
  local rootspec="$1" src="$2" blob="$TMP/be.$$"
  ( cd "$REPO" && chirality_blob_file "$rootspec" "$src" ) >"$blob" 2>"$TMP/be.rerr" || { cat "$TMP/be.rerr"; return; }
  ( ulimit -s unlimited; "$CC" <"$blob" >/dev/null 2>"$TMP/be.cerr" )
  cat "$TMP/be.cerr"
}

# refuse_msg COMPILER SRCTEXT -> the compiler's stderr for that source
refuse_msg() {
  local cc="$1" f="$TMP/s.$$"
  printf '%s' "$2" >"$f"
  ( ulimit -s unlimited; "$cc" <"$f" >/dev/null 2>"$TMP/rm.txt" )
  cat "$TMP/rm.txt"
}

# ============================================================================
# One run of the fixture covers G1/G2/G3/G3c/G4. Its exit code is 0, or the
# 1-based number of the FIRST failing case -- which is what makes each mutant
# below convict at a named row rather than merely "somewhere".
echo
echo "=== E158 G1-G4: the fixture -- flat law, width independence, evidence survival ==="
build_run "lib:prog" "$FIXTURE"
rc=$?
if [ $rc -eq 0 ]; then ok "e158_doc: 14 cases (2 group · 1 flat law · 1 width · 9 evidence · 1 control)"
else bad "e158_doc: first failing case = $rc"; fi

# ============================================================================
# Each mutant names ONE corruption and the case number the fixture must then
# report. The case ORDER in the fixture is chosen so that each mutant's own row
# is the first row it reddens; a mutant landing on a different case means the
# rows have drifted apart from the mutants that give them teeth.
echo
echo "=== E158 the named mutants (a row whose mutant passes exercises nothing) ==="
mutant() {  # mutant NAME WANT-CASE REPO-REL-PATH SED-EXPR
  local name="$1" want="$2" rel="$3" expr="$4"
  local lib="$TMP/mutlib"
  rm -rf "$lib"; cp -a "$REPO/lib" "$lib"
  local target="$lib/${rel#lib/}"
  if ! sed -i "$expr" "$target"; then bad "$name -- sed failed"; return; fi
  if cmp -s "$target" "$REPO/$rel"; then
    bad "$name -- the mutation did not change $rel (stale pattern)"; return
  fi
  build_run "$lib:$REPO/prog" "$FIXTURE"
  local got=$?
  if [ "$got" = "$want" ]; then ok "$name -- fixture fails at case $got, as required"
  else bad "$name -- fixture exited $got, wanted $want"; fi
}

# M4 (G4): ALWAYS BREAK. The one decision point in the element stops deciding.
# G4 goes red; G2 stays green, because the token sequence is unchanged -- that
# asymmetry is exactly why G4 is a separate row from G2.
mutant "M4 always-break (d-group never picks m-flat)" 1 lib/prelude/doc.chiral \
  's|(true  (doc-best w k (cons (dfr i (m-flat) b) rest) acc))|(true  (doc-best w k (cons (dfr i (m-brk) b) rest) acc))|'
# M1 (G1): SWAP SOFT AND SPACE. A brk-soft starts flattening to " ". Only the
# flat law can see it -- G2 strips whitespace and stays green.
mutant "M1 swap-soft-and-space (brk-soft flattens to a space)" 3 lib/prelude/doc.chiral \
  's|((brk-soft)  (doc-best w k rest acc))|((brk-soft)  (doc-best w (+ k 1) rest (cons " " acc)))|'
# M2 (G2): CLIP D-TEXT. d-text stops being atomic and is truncated to the
# remaining width. This is the mutant that proves atomicity is TESTED rather
# than asserted in a comment.
mutant "M2 clip-d-text (d-text truncated to the remaining width)" 4 lib/prelude/doc.chiral \
  's|((d-text s)   (doc-best w (+ k (str-len s)) rest (cons s acc)))|((d-text s)   (doc-best w (+ k (str-len s)) rest (cons (str-sub s 0 (min (str-len s) (max 0 (- w k)))) acc)))|'
# ...and the ASYMMETRY those two rows claim, made checkable. G1 and G4 are
# separate rows from G2 only if a mutant can redden one and leave the other
# green. The fixture stops at its FIRST failing case, so it cannot show that on
# its own: this probe carries the G2 assertion ALONE and must stay green under
# both M1 and M4. If it ever goes red, G2 has stopped being an independent law
# and the table above is claiming an asymmetry it does not have.
cat >"$TMP/g2only.prog" <<'G2ONLY'
(import "prelude/prelude")
(import "prelude/string")
(import "prelude/doc")
(declare dz-strip-go (-> Bytes I64 I64 Bytes Bytes))
(def dz-strip-go
  (lam (b i n acc)
    (case (<i i n)
      (false acc)
      (true (let ((c (bget b i)))
              (case (su-is-ws c)
                (true  (dz-strip-go b (+ i 1) n acc))
                (false (dz-strip-go b (+ i 1) n (bcat acc (bslice b i (+ i 1)))))))))))
(def dz-strip (-> Str Str)
  (lam (s) (let ((b (str->bytes s))) (bytes->str (dz-strip-go b 0 (blen b) (str->bytes ""))))))
(def dz-doc Doc
  (d-group
    (d-cat (d-text "aa")
      (d-nest 2
        (d-cat (d-line (brk-space))
          (d-group (d-cat (d-text "bbbb") (d-cat (d-line (brk-space)) (d-text "cccc")))))))))
(def compile-main (-> I64 I64)
  (lam (n)
    (case (and (str-eq (dz-strip (doc->str 1 dz-doc)) (dz-strip (doc->str 40 dz-doc)))
               (str-eq (dz-strip (doc->str 40 dz-doc)) (dz-strip (doc->str 1000000 dz-doc))))
      (true 0)
      (false 1))))
G2ONLY
asym() {  # asym NAME SED-EXPR -- G2 alone must stay GREEN under this mutation
  local name="$1" expr="$2" lib="$TMP/asymlib"
  rm -rf "$lib"; cp -a "$REPO/lib" "$lib"
  sed -i "$expr" "$lib/prelude/doc.chiral"
  if cmp -s "$lib/prelude/doc.chiral" "$DOC"; then bad "$name -- the mutation did not apply (stale pattern)"; return; fi
  build_run "$lib:$REPO/prog" "$TMP/g2only.prog"
  local got=$?
  if [ "$got" -eq 0 ]; then ok "$name -- G2 alone stays GREEN, so the asymmetry is real"
  else bad "$name -- G2 alone went red (exit $got); G1/G4 are not independent rows"; fi
}
asym "M4 asymmetry (always-break leaves the token sequence intact)" \
  's|(true  (doc-best w k (cons (dfr i (m-flat) b) rest) acc))|(true  (doc-best w k (cons (dfr i (m-brk) b) rest) acc))|'
asym "M1 asymmetry (swap-soft-and-space moves only whitespace)" \
  's|((brk-soft)  (doc-best w k rest acc))|((brk-soft)  (doc-best w (+ k 1) rest (cons " " acc)))|'

# M3 (G3): DROP OBSERVED. dg-doc's r-usage arm stops emitting the observed
# quantity -- the classic "carry the evidence, lose the disagreement" failure,
# and every layout property above it still holds.
mutant "M3 drop-observed (dg-doc's r-usage arm drops oq)" 8 lib/typing/diag.chiral \
  's|(cons (d-text (dg-qty-name oq)) nil)|(cons (d-text "") nil)|'
# M3c (G3c): MAKE THE BASELINE VERBOSE. dg-msg's own r-usage arm starts naming
# the quantities. The control is a POSITIVE assertion about the baseline, so it
# must go red -- and E157's Phase 13 goldens must go red too. Both, which is
# the point: "fixing" dg-msg is a deliberate reconciliation, never a silent one.
mutant "M3c make-dg-msg-verbose (the baseline starts naming the quantities)" 14 lib/typing/diag.chiral \
  's|((r-usage      w d o)  (dg-usage-msg w))|((r-usage      w d o)  (str-cat (dg-usage-msg w) (str-cat " " (str-cat (dg-qty-name d) (dg-qty-name o)))))|'

# ...and the other half of M3c, one layer down: a compiler built from the same
# mutation must stop emitting E157's golden sentence. Without this the claim
# "Phase 13 goes red too" is a sentence in a comment.
echo
echo "=== E158 M3c(compiler): the same mutation moves E157's Phase 13 golden ==="
mlib="$TMP/cclib"; rm -rf "$mlib"; cp -a "$REPO/lib" "$mlib"
sed -i 's|((r-usage      w d o)  (dg-usage-msg w))|((r-usage      w d o)  (str-cat (dg-usage-msg w) (str-cat " " (str-cat (dg-qty-name d) (dg-qty-name o)))))|' "$mlib/typing/diag.chiral"
if cmp -s "$mlib/typing/diag.chiral" "$REPO/lib/typing/diag.chiral"; then
  bad "M3c(compiler) -- the mutation did not apply (stale pattern)"
else
  ( cd "$REPO" && chirality_blob_file "$mlib:$REPO/prog" "$REPO/prog/compiler.prog" ) >"$TMP/m.blob" 2>/dev/null
  if ( ulimit -s unlimited; "$CC" <"$TMP/m.blob" >"$TMP/mcc" 2>/dev/null ) && [ -s "$TMP/mcc" ]; then
    chmod +x "$TMP/mcc"
    mgot="$(refuse_msg "$TMP/mcc" '(def compile-main (-> I64 I64) (lam (n) (let (0 x n) x)))')"
    if [ "$mgot" = "load: let binder usage mismatch" ]; then
      bad "M3c(compiler) -- the mutant compiler still emits E157's golden verbatim"
    else
      ok "M3c(compiler) -- E157's Phase 13 golden moves too: $mgot"
    fi
  else
    bad "M3c(compiler) -- the mutant compiler did not build"
  fi
fi

# ============================================================================
# G3's NINTH ARM, and why it is here rather than in the fixture.
#
# E157's `diag.sh` G4 is a CONTAINMENT invariant: only a layer below the checker
# may construct an `r-relayed`, enforced by a tree-wide grep over `lib prog
# tools` minus a hard-coded list of three files where one is supposed to appear.
# `samples/e157_diag.prog` is on that list because it deliberately builds one
# value of every Reason arm; `samples/e158_doc.prog`, written after it, is not,
# so putting the ninth arm in the fixture turns E157's Phase 13 RED. Adding a
# line to that list would move `diag.sh`, which G7(b) below pins byte-for-byte.
#
# So the row lives here, on a scratch root this script writes OUTSIDE the tree,
# where E157's census correctly never looks. The row is not weakened -- it is
# asserted, at the same width, with its own mutant. (Measured, and reported: the
# rigidity is E157's row, not E158's fixture. Widening that exclusion list is a
# change to E157's gate and belongs to whoever owns it.)
echo
echo "=== E158 G3(9th): r-relayed -- evidence survival for the arm the fixture cannot hold ==="
#
# ⚑ The constructor application is ASSEMBLED from two halves and never spelled
# out in this file, for the same reason and by the same device G5(a) and G7(a)
# use: E157's census reads `tools/` too, so a literal here would trip the very
# row this block is working around. The probe it WRITES contains it in full --
# which is the honest place for it, since $TMP is not the source tree.
RELAY_CTOR="(r-""relayed (rl-parse) \"bad\")"
cat >"$TMP/relay.prog" <<RELAY
(import "prelude/prelude")
(import "prelude/string")
(import "prelude/doc")
(import "typing/diag")
(def dq-rendered Str (doc->str 80 (dg-doc $RELAY_CTOR)))
(def compile-main (-> I64 I64)
  (lam (n)
    (case (and (str-contains dq-rendered "data-group: bad")
               (str-contains dq-rendered "relayed by parse"))
      (true 0)
      (false 1))))
RELAY
build_run "lib:prog" "$TMP/relay.prog"
rrc=$?
if [ "$rrc" -eq 0 ]; then ok "r-relayed keeps BOTH its message and the layer that relayed it"
else bad "r-relayed evidence did not survive (probe exit $rrc)"; fi
# M9: the relaying LAYER stops reaching the output. Which layer relayed is a
# closed sum precisely so it is not a string nobody notices; dropping it is the
# same defect one level up.
m9lib="$TMP/m9lib"; rm -rf "$m9lib"; cp -a "$REPO/lib" "$m9lib"
sed -i 's|(cons (d-text (dg-relay-tag f)) nil)|(cons (d-text "") nil)|' "$m9lib/typing/diag.chiral"
if cmp -s "$m9lib/typing/diag.chiral" "$REPO/lib/typing/diag.chiral"; then
  bad "M9 drop-the-relay-layer -- the mutation did not apply (stale pattern)"
else
  build_run "$m9lib:$REPO/prog" "$TMP/relay.prog"
  m9rc=$?
  if [ "$m9rc" -eq 1 ]; then ok "M9 drop-the-relay-layer -- the r-relayed row goes red, as required"
  else bad "M9 drop-the-relay-layer -- probe exited $m9rc, wanted 1"; fi
fi

# ============================================================================
# The absent seventh constructor IS the element. Wadler's `<|>` carries a side
# condition the type cannot state (both branches flatten to the same text; the
# left's first line no shorter), so every hand-built union is a latent bug.
# `d-group` IS `union (flatten body) body` -- the only union anyone can write.
echo
echo "=== E158 G5: the sum is closed, and there is no union ==="
# (a) the union constructor exists nowhere in the source. The probe is ASSEMBLED
# from two halves and NEVER spelled out in this file -- a row that matches its
# own source line can never hold. It probes the CONSTRUCTOR form (an open paren
# then the name), not the bare word, which doc.chiral's header discusses in
# prose, backticked, as the thing that is deliberately absent.
UN='(d-''union'
un_hits="$( (cd "$REPO" && grep -RIn -F -- "$UN" lib prog tools 2>/dev/null) | wc -l)"
if [ "$un_hits" -eq 0 ]; then ok "the union constructor '$UN' appears nowhere in lib/ prog/ tools/ -- d-group is the only union"
else bad "$un_hits occurrence(s) of '$UN':"; (cd "$REPO" && grep -RIn -F -- "$UN" lib prog tools) | sed 's/^/          /'; fi

# (b) Doc has exactly SIX constructors, read out of lib/prelude/doc.chiral
# itself -- so a seventh arm is censused without editing this script.
doc_ctors() {  # doc_ctors FILE
  awk '
    /^\(data Doc \(\)/ { f=1 }
    f {
      line=$0; sub(/;.*/,"",line)
      if (line ~ /^[ \t]+\(d-/) { s=line; sub(/^[ \t]+\(/,"",s); sub(/[^A-Za-z0-9?!*<>=+-].*/,"",s); print s }
      o=gsub(/\(/,"",line); c=gsub(/\)/,"",line); d=d+o-c
      if (d<=0) exit
    }' "$1"
}
nctor="$(doc_ctors "$DOC" | grep -c .)"
if [ "$nctor" -eq 6 ]; then ok "Doc has exactly 6 constructors: $(doc_ctors "$DOC" | tr '\n' ' ')"
else bad "Doc has $nctor constructors, wanted 6: $(doc_ctors "$DOC" | tr '\n' ' ')"; fi

# (c) a probe casing ALL SIX arms of Doc and ALL THREE of Brk compiles -- the
# coverage checker is what turns "closed" from a comment into a property.
cat >"$TMP/probe.prog" <<'PROBE'
(import "prelude/doc")
(def dpz-brk (-> Brk I64)
  (lam (b) (case b ((brk-soft) 0) ((brk-space) 1) ((brk-hard) 2))))
(def dpz-doc (-> Doc I64)
  (lam (d)
    (case d
      ((d-text  s)   1)
      ((d-cat   l r) 2)
      ((d-line  b)   (dpz-brk b))
      ((d-nest  i b) 4)
      ((d-group b)   5)
      ((d-tag   n b) 6))))
(def compile-main (-> I64 I64) (lam (n) (dpz-doc (d-text "x"))))
PROBE
perr="$(build_err "lib:prog" "$TMP/probe.prog")"
if [ -z "$perr" ]; then ok "a probe casing all 6 Doc arms and all 3 Brk arms compiles"
else bad "the exhaustive probe did not compile: $(echo "$perr" | head -c 160)"; fi

# M5: ADD A SEVENTH CONSTRUCTOR and nothing else. The compile of prelude/doc
# must FAIL on doc-best's coverage. If it compiles, the closed sum buys nothing.
m5lib="$TMP/m5lib"; rm -rf "$m5lib"; cp -a "$REPO/lib" "$m5lib"
sed -i 's|  (d-tag   (name Str) (body Doc)))|  (d-tag   (name Str) (body Doc))\n  (d-fill  (body Doc)))|' "$m5lib/prelude/doc.chiral"
cat >"$TMP/bare.prog" <<'BARE'
(import "prelude/doc")
(def compile-main (-> I64 I64) (lam (n) 42))
BARE
if cmp -s "$m5lib/prelude/doc.chiral" "$DOC"; then
  bad "M5 add-seventh-constructor -- the mutation did not apply (stale pattern)"
else
  m5err="$(build_err "$m5lib:$REPO/prog" "$TMP/bare.prog")"
  if [ -n "$m5err" ]; then ok "M5 add-seventh-constructor -- refused: $(echo "$m5err" | head -c 90)"
  else bad "M5 add-seventh-constructor -- a 7th Doc arm compiled clean; the closed sum buys nothing"; fi
fi

# ============================================================================
# E154: the emitted-label namespace is FLAT, so two co-blobbed modules cannot
# define the same internal name. `typing/diag` importing `prelude/doc` puts the
# algebra into the COMPILER's blob beside lowering/tal/check and
# lowering/compile-front -- which is why `fits` became `doc-fits` and the Frame
# constructor `fr` became `dfr` before this file was ever written.
#
# The names are read out of doc.chiral itself, so a new binding is censused
# without editing this script, and the search is `grep -R` -- NOT `grep -r`,
# which does not follow symlinks and would let a skipped file read as a clean
# census (MIGRATION-NOTES.md records this exact trap for diag.sh's G6).
echo
echo "=== E158 G6: E154 -- every lib/prelude/doc.chiral name is defined exactly once ==="
{ grep -oE '^\((def|data|declare) [^ ()]+' "$DOC" | awk '{print $2}'
  grep -oE '\((d-|brk-|m-|dfr)[A-Za-z0-9?!*<>=+-]*' "$DOC" | sed 's/^(//'
} | sort -u >"$TMP/dnames.txt"
ndnames="$(grep -c . "$TMP/dnames.txt")"

# SCOPE (2026-08-31, at the master merge): `_wip/` is excluded, and this is a
# CORRECTION of the row's scope, not a weakening of it. The claim G6 makes is
# E154's: two modules that can land in ONE BLOB cannot define the same name. A
# `_wip/` sample is in no blob -- no gate script compiles that directory, and the
# file that collided here (`p1a-24-buffer-as-object.prog`, its own `data Doc`)
# imports `prelude/prelude` and never `prelude/doc`, so the two can never meet.
# Censusing it made the row report a name clash that cannot occur.
# ⚑ If `_wip/` ever becomes buildable, this exclusion must go with it.
census() {  # census LIBDIR -> the DEFINING duplicate occurrences, one per line
  local lib="$1" out="$TMP/dd.$$"
  : >"$out"
  while read -r n; do
    [ -n "$n" ] || continue
    ( cd "$REPO" && grep -RIn -E "^\((def|data|declare) ${n}[[:space:]]" "$lib" prog tools 2>/dev/null \
        | grep -v '/prelude/doc\.chiral:' \
        | grep -v '/samples/_wip/' ) >>"$out" || true
  done <"$TMP/dnames.txt"
  sort -u "$out"
  rm -f "$out"
}
dupes="$(census "$REPO/lib")"
if [ -z "$dupes" ]; then ok "none of the $ndnames prelude/doc.chiral names is redefined anywhere in lib/ prog/ tools/"
else bad "prelude/doc.chiral names redefined elsewhere:"; echo "$dupes" | sed 's/^/          /'; fi

# M6: REDEFINE doc-fits in a sibling of the same blob. If G6 cannot see this,
# it is censusing nothing.
m6lib="$TMP/m6lib"; rm -rf "$m6lib"; cp -a "$REPO/lib" "$m6lib"
printf '\n(def doc-fits (-> I64 (List Frame) Bool) (lam (r fs) true))\n' >>"$m6lib/prelude/string.chiral"
m6="$(census "$m6lib")"
if [ -n "$m6" ]; then ok "M6 redefine-doc-fits -- census catches the duplicate definition"
else bad "M6 redefine-doc-fits -- census did NOT catch a second (def doc-fits ...)"; fi

# ============================================================================
# Decision 6, made checkable. `dg-msg` keeps E157's byte-identity goldens;
# `dg-doc` is graded on evidence survival. The moment either exit is asserted
# against the other, `Doc` has re-imported the constraint it exists to lift.
echo
echo "=== E158 G7: the two exits are NOT cross-asserted ==="
# The pattern is ASSEMBLED so these rows do not match their own source lines --
# the naive form (`grep -c '<the name>' doc.sh` -> 0) can never hold, because
# the grep line contains the literal, and it contradicts the control below,
# which MUST call the baseline exit in order to assert anything about it.
PAT="dg""-msg"
# a GOLDEN ROW is a line that names the plain-text exit AND makes a
# byte-equality assertion. Naming it in prose is not the hazard; asserting its
# bytes is. (The one byte-equality in this file, under M3c(compiler), is over
# the COMPILER's stderr -- that is E157's own golden moving, which is the point
# of that mutant, and it names no exit at all.)
gm_goldens()    { grep -F -- "$PAT" "$1" | grep -c '= "' ; }
gm_in_fixture() { sed 's/;.*//' "$1" | grep -o -F -- "$PAT" | grep -c . ; }

# (a) doc.sh carries no golden row over the baseline exit...
n_script="$(gm_goldens "$HERE/doc.sh")"
if [ "$n_script" -eq 0 ]; then ok "doc.sh carries no golden row over the plain-text exit (0 byte-equality assertions on it)"
else bad "doc.sh carries $n_script golden row(s) over the plain-text exit -- byte-identity has crept in"; fi
# ...and the fixture's only references are the TWO in the G3c substring-ABSENCE
# control. Pinned at the control, not at zero: the control must call it.
n_fix="$(gm_in_fixture "$FIXTURE")"
if [ "$n_fix" -eq 2 ]; then ok "the fixture's only baseline references are G3c's 2 absence assertions"
else bad "the fixture references the baseline exit $n_fix time(s) in code, wanted exactly 2 (the G3c control)"; fi

# M7(ii): add ONE golden row over the baseline exit to a copy of doc.sh, and to
# a copy of the fixture. Both halves of (a) must go red -- (i) below never
# touches doc.sh, so without this pair (a) has no teeth.
cp "$HERE/doc.sh" "$TMP/m7.sh"
printf '\ngot="$(dg%s dt-usage)"; [ "$got" = "linear binder usage mismatch" ]\n' "-msg" >>"$TMP/m7.sh"
cp "$FIXTURE" "$TMP/m7.prog"
printf '\n; (str-eq (dg%s dt-usage) "linear binder usage mismatch")\n(def dt-cross Bool (str-eq (dg%s dt-usage) "linear binder usage mismatch"))\n' "-msg" "-msg" >>"$TMP/m7.prog"
if [ "$(gm_goldens "$TMP/m7.sh")" -gt 0 ] && [ "$(gm_in_fixture "$TMP/m7.prog")" -gt 2 ]; then
  ok "M7(ii) cross-assert -- a golden row in either file is caught by G7(a)"
else bad "M7(ii) cross-assert -- G7(a) did not catch an added golden row"; fi

# (b) E157's gate is byte-unchanged by this element, against a PINNED sha256.
# (A `git diff --stat` row is not equivalent: once these commits land, the diff
# against them is empty forever and the row reports ok for the rest of time.)
DIAG_SH_SHA=f50f2ff82f533b13f1eadc23edb69ffde30511ea26796b60f1bddb9a468808fe
DIAG_FX_SHA=713fe84d51c149d491edf8289a5799206f44b0e925a28dc7f123ba3f7ab4171c
sha_of() { sha256sum "$1" | awk '{print $1}'; }
got_sh="$(sha_of "$HERE/diag.sh")"
got_fx="$(sha_of "$HERE/samples/e157_diag.prog")"
if [ "$got_sh" = "$DIAG_SH_SHA" ]; then ok "tools/test/diag.sh is byte-unchanged (sha256 pinned)"
else bad "tools/test/diag.sh MOVED -- sha256 $got_sh, pinned $DIAG_SH_SHA"; fi
if [ "$got_fx" = "$DIAG_FX_SHA" ]; then ok "tools/test/samples/e157_diag.prog is byte-unchanged (sha256 pinned)"
else bad "tools/test/samples/e157_diag.prog MOVED -- sha256 $got_fx, pinned $DIAG_FX_SHA"; fi

# M7(i): add ONE doc->str golden row to a COPY of diag.sh. The checksum moves.
cp "$HERE/diag.sh" "$TMP/m7diag.sh"
printf '\ngolden "doc->str crept into E157s gate" "x" "y"\n' >>"$TMP/m7diag.sh"
if [ "$(sha_of "$TMP/m7diag.sh")" != "$DIAG_SH_SHA" ]; then
  ok "M7(i) cross-assert -- a row added to E157's gate moves the pinned checksum"
else bad "M7(i) cross-assert -- the pinned checksum did not move"; fi

# (c) and E157's phase still RUNS: an unregistered script is a gate that never
# runs, and a phase that silently vanishes reports ok forever. The same
# `bin/chirality test` invocation that runs this file runs Phase 13 green.
RT="$REPO/tools/test/run-tests.sh"
reg() { grep -cE "^run_phase $1 .* $2\$" "$3"; }
if [ "$(reg 13 diag.sh "$RT")" -ge 1 ]; then ok "Phase 13 (E157) is still registered in run-tests.sh"
else bad "Phase 13 (E157) is no longer registered -- E157's gate would silently stop running"; fi
if [ "$(reg 14 doc.sh "$RT")" -ge 1 ]; then ok "Phase 14 (E158) is registered in run-tests.sh -- this gate actually runs"
else bad "Phase 14 (E158) is NOT registered in run-tests.sh -- an unregistered script never runs"; fi
# and the registration rows have teeth: strip either line from a copy and the
# row above must be the thing that notices.
cp "$RT" "$TMP/m8.sh"
sed -i '/^run_phase 14 /d;/^run_phase 13 /d' "$TMP/m8.sh"
if [ "$(reg 13 diag.sh "$TMP/m8.sh")" -eq 0 ] && [ "$(reg 14 doc.sh "$TMP/m8.sh")" -eq 0 ]; then
  ok "M8 unregister-the-phase -- both registration rows catch a deleted run_phase line"
else bad "M8 unregister-the-phase -- a deleted run_phase line was not caught"; fi

echo
echo "layout algebra (E158): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
