#!/usr/bin/env bash
# arity.sh -- E182: the arity judgments carry their arity.  The Phase 24 gate.
#
# PHASE 24, and 24 for a measured reason.  docs/decisions/decision-lane-split.md:30
# reserved 18, 19 and 20 for this lane; 18 went to E181, 19 to E173's matcher.sh,
# and d7d7cfe registered transport.sh at 20 between this element's SPEC audit and
# its implement run.  All three reserved numbers are spent, 21 through 23 are Lane
# B's, and 8-12 are names still OWED to unported old-tree phases (run-tests.sh:18-22).
# 24 is the first number that collides with nothing.  records/findings.md FD-11
# holds the measurement.
#
# --- WHAT THIS ELEMENT IS, AND WHAT IT IS GRADED ON -------------------------
#
# `Reason` (lib/typing/diag.chiral:141) gains a tenth arm,
# `(r-arity (what Subject) (expected I64) (actual I64))`, and the two LIVE arity
# comparisons in lib/typing/kernel.chiral -- check-tcon at :1042 and con-check at
# :1097 -- build it with the two integers they already held.  Two nullary `Judg`
# arms retire with them, so `Judg` reads 36.  The property is that a refusal now
# carries the numbers it compared instead of a sentence that names neither.
#
# ⚑ TWO UPGRADES THIS ARC PAID FOR, ADOPTED VERBATIM.
#
# 1. EVERY MUTANT THAT CAN MOVE A VALUE ROW PINS THE FULL VERDICT LINE.  A mutant
#    that reddens a row it was not paired with is then impossible to miss rather
#    than merely unlikely.  `verdict LIBDIR` prints all six value rows at once.
#    M1, M7 and M8 are graded BESIDE it, each for a stated reason.
# 2. THE FIXTURE ASSERTS NOTHING AND ALWAYS EXITS 0.  It prints values; every
#    comparison here is bash.  A fixture that grades itself can be wrong twice in
#    the same direction, and one that exits at its first failure masks every later
#    row from every mutant.  Fields are separated by a single byte 1, the device
#    at samples/e173_matcher.prog:199.
#
# ⚑ FOUR TRAPS, EACH LIVE FOR THIS GATE AND EACH WITH ITS MEASURED SOURCE.
#
# - A `sed` needle inside a gate script can match its OWN source.  Phase 17's
#   census went red on a clean tree for exactly that (docs/arcs/diagnostics-arc.md:106).
#   Every needle below that a neighbouring census could see is ASSEMBLED FROM TWO
#   HALVES, the idiom at tools/test/doc.sh:292 and tools/test/matcher.sh:540.
# - A fixture under `tools/` is inside a neighbouring gate's scan surface.  Three
#   censuses grep `lib prog tools` for `^\((def|data|declare) <name>`: doc.sh:380,
#   render-doc.sh:436 and row.sh:742.  ⚑ THE RULE COVERS THE HEREDOC'D SCRATCH
#   ROOT TOO.  Its text lives inside this file, which is itself under `tools/`,
#   and those three are line-anchored greps that cannot tell a heredoc from a
#   program.  doc.sh:314-320 prefixes its own probe `dpz-` for this reason; every
#   binding in the scratch root below and in samples/e182_arity.prog is `ar-`.
# - THE `r-relayed` CONSTRUCTOR APPLICATION MAY NOT APPEAR ANYWHERE in this file
#   diag.sh:224 greps `lib prog tools` for that literal with a five-entry
#   exclusion list, and diag.sh is sha256-pinned at pretty.sh:389 so the list
#   cannot grow.  G1 needs an `r-relayed` value, so G1's probe is a scratch root
#   written into `$TMP`, which E157's census correctly never looks at, and its
#   spelling is assembled from two halves.  This is doc.sh:223-238's own
#   disposition of the same trap, one arm later.
# - THE SCRATCH `lib/` MUST BE A REAL DIRECTORY, NEVER A SYMLINK.  `cp -a` copies
#   a symlink AS a symlink and every subsequent `sed -i` then writes THROUGH it
#   into the tree under test -- nineteen phantom failures, measured
#   (render-doc.sh:131-145).  `mutlib` below is matcher.sh:146's, checked rather
#   than remembered, and it REFUSES a `sed` that changed nothing.
#
#   G1  the tenth tag, over all ten Reason arms                      [M1]
#   G2  the flat exit carries both counts, at both subjects       [M2,M3]
#   G3  one arm, two nouns, read off the subject                  [M2,M3]
#   G4  the Doc exit lays both counts on their own lines             [M4]
#   G5  the constructor site reports, through a real compile         [M5]
#   G6  the type-parameter site reports, through a real compile      [M6]
#   G7  both live arms are gone, r-arity is built at exactly 2 sites [M7]
#   G8  Phase 24 is registered                                       [M8]
#
# ⚑ G5 AND G6 EACH BUILD A COMPILER FROM THE `lib/` UNDER TEST, the base row
# included, so they grade the SOURCES and not whatever binary happens to be
# shipped.  `$CC` stays the bootstrap that turns a blob into an executable
# (diag.sh:56); what no row here ever does is read a refusal off `$CC` itself.
# Measured cost: one compiler build is ~2.2 s on this box, six calls to
# `verdict` is ~13 s, and the whole phase's wall clock is reported at the end.
#
# ⚑ A BUILD THAT DID NOT HAPPEN SCORES `nobuild`, NEVER `bad`.  No pinned line
# below ever expects that token, so a mutant that merely fails to compile cannot
# wear a red row and be read as a conviction.  That is the failure mode M5 and M6
# were repaired for: both revert to a `Judg` arm that SURVIVED commit 2, because a
# mutant reaching for a deleted arm does not compile.
#
# Zero Python -- the comparisons are shell and awk, here as everywhere.
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
REPO="$(cd "$HERE/../.." && pwd)"

CC="${CHIRALITY_COMPILE:-}"
[ -n "$CC" ] || CC="$REPO/bin/chirality-bin"
[ -x "$CC" ] || { echo "no compiler found (bin/chirality-bin)"; exit 2; }
# shellcheck disable=SC1091
. "$REPO/bin/chirality-resolve.sh"

FIXTURE="$HERE/samples/e182_arity.prog"
RT="$HERE/run-tests.sh"
DIAG="$REPO/lib/typing/diag.chiral"
KERNEL="$REPO/lib/typing/kernel.chiral"
for f in "$FIXTURE" "$RT" "$DIAG" "$KERNEL"; do
  [ -f "$f" ] || { echo "  FAIL  $f missing -- a gate without its fixture cannot fail"; exit 2; }
done
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
pass=0; fail=0
ok()  { echo "  ok    $1"; pass=$((pass+1)); }
bad() { echo "  FAIL  $1"; fail=$((fail+1)); }
T0=$SECONDS

# ---- build and run ---------------------------------------------------------
build_elf() {  # build_elf LIBDIR SRC ELF -> 0 when the program compiled
  local lib="$1" src="$2" elf="$3" blob="$TMP/b.blob"
  ( cd "$REPO" && chirality_blob_file "$lib:$REPO/prog" "$src" ) >"$blob" 2>/dev/null || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
}

build_raw() {  # build_raw LIBDIR SRC OUT -> 0 and OUT holds the raw STDOUT
  local lib="$1" src="$2" out="$3" elf="$TMP/o.elf"
  build_elf "$lib" "$src" "$elf" || return 1
  ( ulimit -s unlimited; "$elf" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ]
}

build_err() {  # build_err LIBDIR SRC -> the compiler's STDERR for that source
  local lib="$1" src="$2" blob="$TMP/e.blob"
  ( cd "$REPO" && chirality_blob_file "$lib:$REPO/prog" "$src" ) >"$blob" 2>/dev/null \
    || { echo "resolve failed"; return; }
  ( ulimit -s unlimited; "$CC" <"$blob" >/dev/null 2>"$TMP/e.txt" )
  cat "$TMP/e.txt"
}

# build_cc LIBDIR OUT -> a compiler built from THAT lib/, per diag.sh:190-201.
build_cc() {
  local lib="$1" out="$2" blob="$TMP/cc.blob"
  ( cd "$REPO" && chirality_blob_file "$lib:$REPO/prog" "$REPO/prog/compiler.prog" ) >"$blob" 2>/dev/null || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ] || return 1
  chmod +x "$out"
}

# refuse_msg COMPILER SRCTEXT -> that compiler's stderr for that source (diag.sh:66)
refuse_msg() {
  local cc="$1" f="$TMP/s.src"
  printf '%s' "$2" >"$f"
  ( ulimit -s unlimited; "$cc" <"$f" >/dev/null 2>"$TMP/r.txt" )
  cat "$TMP/r.txt"
}

# mutlib NAME REPO-REL-PATH SED-EXPR... -> a scratch copy of lib/ with that file
# mutated, left in $MUTLIB.  matcher.sh:146, symlink guard and stale-pattern
# refusal included: a mutation that does not apply is a mutant that proves nothing.
MUTLIB=""
mutlib() {
  local name="$1" rel="$2"; shift 2
  MUTLIB="$TMP/mutlib"; rm -rf "$MUTLIB"; cp -a "$REPO/lib" "$MUTLIB"
  if [ -L "$MUTLIB" ]; then
    bad "$name -- the scratch lib/ is a SYMLINK; every sed would write into the tree under test"; return 1
  fi
  local target="$MUTLIB/${rel#lib/}" e
  for e in "$@"; do
    sed -i "$e" "$target" || { bad "$name -- sed failed"; return 1; }
  done
  if cmp -s "$target" "$REPO/$rel"; then
    bad "$name -- the mutation did not change $rel (stale pattern)"; return 1
  fi
  return 0
}

# mutlib_also REL SED-EXPR... -> a SECOND file mutated inside the existing $MUTLIB.
mutlib_also() {
  local name="$1" rel="$2"; shift 2
  local target="$MUTLIB/${rel#lib/}" e
  for e in "$@"; do
    sed -i "$e" "$target" || { bad "$name -- sed failed on $rel"; return 1; }
  done
  if cmp -s "$target" "$REPO/$rel"; then
    bad "$name -- the mutation did not change $rel (stale pattern)"; return 1
  fi
  return 0
}

# fld N FILE -> the Nth byte-1-separated field of FILE, verbatim.
fld() { LC_ALL=C awk -v n="$1" 'BEGIN{RS="\1"} NR==n{printf "%s",$0}' "$2"; }

# ---- the assembled needles -------------------------------------------------
# Never spelled out in one piece anywhere in this file.  RLY is the one that
# would trip E157's containment census (diag.sh:224); the others are here for
# uniformity, so no needle can ever match this script's own source.
RLY='(r-''relayed '
AR='(r-''arity '
AR6='(r-''arity      '
I64S='i64''->str'
JGH='(jg''-'
JG_TP='jg-''tparam-arity'
JG_CA='jg-''ctor-arg-arity'

# ---- G1's probe: a scratch root OUTSIDE the tree ---------------------------
# One value of ALL TEN `Reason` arms, joined by tag.  It lives in $TMP because it
# must build an `r-relayed` and E157's census reads `tools/`.  ⚑ It is also the
# row samples/e157_diag.prog:50 can no longer make: that file joins NINE
# hardcoded values and its comment claims one value of every arm, so a tenth arm
# leaves the claim false with nothing going red.  It is sha256-pinned and
# repairing it belongs to diagnostics/D2; this keeps the guarantee at full width
# for E182's own arm in the meantime.  Every binding is `ar-` prefixed.
TEN="$TMP/ar_ten.prog"
cat >"$TEN" <<TENPROG
(import "ports/stdio")
(import "typing/diag")

(def ar-join (-> (List Str) Str) (lam (xs) (case xs (nil "") ((cons x r) (str-cat x (str-cat "," (ar-join r)))))))

(def ar-tags (List Str)
  (cons (dg-reason-tag (r-redeclared (subj-data "Box") (dc-none) (dc-none)))
  (cons (dg-reason-tag (r-mismatch (subj-none) (t-primty "I64") (t-primty "Str")))
  (cons (dg-reason-tag (r-usage (subj-lam-binder) (q1) (qw)))
  (cons (dg-reason-tag (r-linear (subj-let-binder) (qw)))
  (cons (dg-reason-tag (r-arrow (subj-extern "mint") "Cap"))
  (cons (dg-reason-tag (r-unbound (subj-def "nosuch")))
  (cons (dg-reason-tag (r-skipped nil))
  (cons (dg-reason-tag (r-judged (subj-none) (jg-empty-case)))
  (cons (dg-reason-tag ${RLY}(rl-step) "x"))
  (cons (dg-reason-tag ${AR}(subj-ctor "mk2") 2 1))
    nil)))))))))))

(def compile-main (=> I64 I64) (lam (n) (let ((_ (put (ar-join ar-tags)))) 0)))
TENPROG

# ============================================================================
# THE EXPECTED VALUES.  Every one is HAND-DERIVED from what the program MEANS --
# rank 3 of docs/definitions/testing-floors.md -- and none is a capture of what
# the code printed.
#
#  G1  dg-reason-tag over one value of each of the ten Reason arms, in the order
#      lib/typing/diag.chiral:121-142 declares them, joined by ar-join, which
#      appends a comma after every element including the last.
#  G2  dg-arity-msg is  <name> " wrong number of " <noun> " (expected " e
#      ", actual " a ")".  `mk2` is a constructor, so its noun is "arguments";
#      `Box` is a data type, so dg-arity-noun's subj-data arm gives it
#      "type parameters".  Both counts appear in both sentences, so a message
#      that keeps one and drops the other cannot pass.
#  G3  the SAME two sentences, read for their noun alone, extracted with the rest
#      of each sentence ANCHORED.  One `Reason` arm serves a site about type
#      parameters and a site about constructor arguments, and the noun is the
#      only thing that differs.  The anchor is why M2 reddens this row too: a
#      sentence whose counts moved no longer matches the pattern at all.
#  G4  dg-doc's arity arm is a d-group whose head is that sentence plus the
#      subject tag in parentheses, over a `d-nest 2` carrying `expected <e>` and
#      `actual <a>` behind two soft breaks -- field for field with the r-usage
#      arm at diag.chiral:564.  The head is 58 columns, doc->str is asked for 24,
#      so the group breaks and each count takes its own line at indent 2.
#  G5/G6 the two refusals, off a compiler built from the lib/ under test.
G1_WANT="redeclared,mismatch,usage,linear,arrow,unbound,skipped,judged,relayed,arity,"
G2A_WANT="mk2 wrong number of arguments (expected 2, actual 1)"
G2B_WANT="Box wrong number of type parameters (expected 1, actual 2)"
G3_WANT="arguments|type parameters"
G4_WANT="mk2 wrong number of arguments (expected 2, actual 1) (ctor)
  expected 2
  actual 1"
G5_SRC='(data Pair () (mk2 (a I64) (b I64)))
(def compile-main (-> I64 I64) (lam (n) (case (mk2 n) ((mk2 a b) a))))'
G5_WANT="load: mk2 wrong number of arguments (expected 2, actual 1)"
G6_SRC='(data Box ((P (type 0))) (mk (v P)))
(def ar-f (-> (Box I64 I64) I64) (lam (b) 0))
(def compile-main (-> I64 I64) (lam (n) 42))'
G6_WANT="load: Box wrong number of type parameters (expected 1, actual 2)"

# noun_of SENTENCE-1-EXPECTED-SHAPE -> the noun, or "" when the sentence moved.
noun_ctor() { printf '%s' "$1" | sed -n 's|^mk2 wrong number of \(.*\) (expected 2, actual 1)$|\1|p'; }
noun_data() { printf '%s' "$1" | sed -n 's|^Box wrong number of \(.*\) (expected 1, actual 2)$|\1|p'; }

verdict() {  # verdict LIBDIR -> six `name:ok` / `name:bad` / `name:nobuild` tokens
  local lib="$1" out="" raw="$TMP/v.raw" ten="$TMP/v.ten" cc="$TMP/v.cc" a b
  add() { out="$out${out:+ }$1:$2"; }
  eq()  { if [ "$2" = "$3" ]; then add "$1" ok; else add "$1" bad; fi; }

  if build_raw "$lib" "$TEN" "$ten"; then eq G1 "$(cat "$ten")" "$G1_WANT"; else add G1 nobuild; fi

  if build_raw "$lib" "$FIXTURE" "$raw"; then
    a="$(fld 1 "$raw")"; b="$(fld 2 "$raw")"
    if [ "$a" = "$G2A_WANT" ] && [ "$b" = "$G2B_WANT" ]; then add G2 ok; else add G2 bad; fi
    eq G3 "$(noun_ctor "$a")|$(noun_data "$b")" "$G3_WANT"
    eq G4 "$(fld 3 "$raw")" "$G4_WANT"
  else
    add G2 nobuild; add G3 nobuild; add G4 nobuild
  fi

  if build_cc "$lib" "$cc"; then
    eq G5 "$(refuse_msg "$cc" "$G5_SRC")" "$G5_WANT"
    eq G6 "$(refuse_msg "$cc" "$G6_SRC")" "$G6_WANT"
  else
    add G5 nobuild; add G6 nobuild
  fi
  echo "$out"
}

ALLOK="G1:ok G2:ok G3:ok G4:ok G5:ok G6:ok"

# ============================================================================
echo
echo "=== E182 G1-G6: the real tree -- six rows in one line ==="
BASE="$(verdict "$REPO/lib")"
if [ "$BASE" = "$ALLOK" ]; then
  ok "all six value rows hold: $BASE"
else
  bad "the value rows do NOT all hold"
  echo "          got:  $BASE"
  echo "          want: $ALLOK"
fi

# The measured values, printed once: a gate that only reports ok/bad about a
# refusal makes that refusal unreadable to whoever has to fix it.
if build_raw "$REPO/lib" "$FIXTURE" "$TMP/b.raw"; then
  printf '          %-24s %s\n' \
    "ctor sentence (G2a)" "$(fld 1 "$TMP/b.raw")" \
    "data sentence (G2b)" "$(fld 2 "$TMP/b.raw")"
  echo "          Doc exit (G4), width 24:"
  fld 3 "$TMP/b.raw" | sed 's/^/            /'
fi

# ============================================================================
# Each mutant names ONE corruption and pins the WHOLE verdict line it must
# produce.  A mutant that reddens a row it was not paired with is caught by the
# same assertion that catches one that reddens nothing.
echo
echo "=== E182 the named mutants (a row whose mutant passes exercises nothing) ==="
mutant() {  # mutant NAME WANT-VERDICT REPO-REL-PATH SED-EXPR...
  local name="$1" want="$2" rel="$3"; shift 3
  mutlib "$name" "$rel" "$@" || return
  local got; got="$(verdict "$MUTLIB")"
  if [ "$got" = "$want" ]; then ok "$name -- $(echo "$got" | tr ' ' '\n' | grep -c ':bad') row(s) red, exactly the pinned ones"
  else
    bad "$name -- the verdict is not the pinned one"
    echo "          got:  $got"
    echo "          want: $want"
  fi
}

# M1 (G1) -- THE TAG RENDERER LOSES THE ARITY ARM, and it is graded BESIDE the
# verdict line rather than inside it.  A non-exhaustive `case` in diag.chiral
# refuses the whole module, so the fixture, the scratch root and the compiler
# build die together; the verdict line then reads six `nobuild`, which is exactly
# what a `sed` that merely broke the syntax reads.  So M1 asserts the REFUSAL
# TEXT: the string diag.sh:174-177 already pins.  That is the eight-renderer
# property as a checked row; an all-red verdict line is not.
if mutlib "M1 tag-loses-the-arity-arm" lib/typing/diag.chiral \
     "s|(${AR6}w e a)  \"arity\")||"; then
  m1="$(build_err "$MUTLIB" "$TEN")"
  if [ "$m1" = "load: non-exhaustive case" ]; then
    ok "M1 tag-loses-the-arity-arm -- the module is refused: $m1"
  else
    bad "M1 tag-loses-the-arity-arm -- wanted 'load: non-exhaustive case', got: $m1"
  fi
fi

# M2 (G2/G3/G4/G5/G6) -- dg-arity-msg STOPS RENDERING THE EXPECTED COUNT.  Four
# other rows read that helper: it is dg-doc's head (G4) and it is the sentence
# both compiled refusals carry (G5, G6).  G1 stays green, which is what tells M2
# apart from M1; G4 and G5 are what tell it apart from M3.
# ⚑ It corrupts the HELPER and never the `Reason` arm: corrupting the arm stops
# the fixture compiling, which scores G1 nobuild and leaves G2 unexercised.
mutant "M2 msg-drops-the-expected-count" \
  "G1:ok G2:bad G3:bad G4:bad G5:bad G6:bad" \
  lib/typing/diag.chiral \
  "s|(str-cat (${I64S} e)|(str-cat \"?\"|"

# M3 (G2/G3/G6) -- THE NOUN COLLAPSES ONTO "arguments".  dg-arity-noun's
# subj-data arm stops saying what it is counting, so the type-parameter sentence
# becomes the constructor one with a different name in front.  The `mk2` sentence
# is untouched, so G4 and G5 stay green -- which is the whole reason the verdict
# line is pinned in full: M2 and M3 both redden G2 and G3.
mutant "M3 noun-collapses-to-arguments" \
  "G1:ok G2:bad G3:bad G4:ok G5:ok G6:bad" \
  lib/typing/diag.chiral \
  "s|((subj-data   n)     \"type parameters\")|((subj-data   n)     \"arguments\")|"

# M4 (G4) -- THE DOC ARM LOSES ITS LAYOUT.  Both soft breaks inside the r-arity
# arm become empty text, so the two counts stop getting their own lines and slide
# onto the head.  The sed is range-restricted to that one arm: `((r-arity w e a)`
# with single spaces is dg-doc's spelling and nothing else in the file has it.
# G4 red ONLY, and G2 stays green -- the point being that the two exits are graded
# separately, because a fix to one leaves the other unfixed.
mutant "M4 doc-arm-drops-the-nest" \
  "G1:ok G2:ok G3:ok G4:bad G5:ok G6:ok" \
  lib/typing/diag.chiral \
  "/(${AR}w e a)/,/(cons (d-text (${I64S} a)) nil)/ s|(d-line (brk-space))|(d-text \"\")|g"

# M5 (G5) -- con-check REVERTS TO A STUB.  The constructor site goes back to a
# nullary judgment and the refusal loses both counts.
# ⚑ ITS REVERT TARGET IS `(jg-ctor-arity)`, AN ARM THAT SURVIVES.  `jg-ctor-arg-arity`,
# the arm this site used to build, was deleted by E182 commit 2, so a mutant
# reaching for it would fail to compile and score G5 nobuild instead of
# convicting -- a toothless mutant wearing a red row.
mutant "M5 con-check-reverts-to-a-stub" \
  "G1:ok G2:ok G3:ok G4:ok G5:bad G6:ok" \
  lib/typing/kernel.chiral \
  "s|${AR}(subj-ctor cn) (llen Field fields) (llen Term args))|(r-judged (subj-ctor cn) (jg-ctor-arity))|"

# M6 (G6) -- check-tcon REVERTS TO A STUB, for the same reason and with the same
# repair: `(jg-tcon-arity)` survives, `${JG_TP}` does not.  The two stubs emit
# DIFFERENT strings ("tcon arity" vs "constructor arity"), so neither row can pass
# by reading the other's failure.
mutant "M6 check-tcon-reverts-to-a-stub" \
  "G1:ok G2:ok G3:ok G4:ok G5:ok G6:bad" \
  lib/typing/kernel.chiral \
  "s|${AR}(subj-data dn) (llen Term (decl-params decl)) (llen Term args))|(r-judged (subj-data dn) (jg-tcon-arity))|"

# ============================================================================
# G7 -- THE TWO SCANS, and both halves are E182's own claims.  Outside the
# verdict line because neither reads a value.
echo
echo "=== E182 G7: the retired arms, the Judg count, and r-arity's two sites ==="

# (a) neither retired arm survives anywhere under lib/ or prog/ ...
retired() { ( cd "$REPO" && grep -RIn -E "${JG_TP}|${JG_CA}" "$1" prog 2>/dev/null ); }
rl="$(retired "$REPO/lib" | wc -l)"
if [ "$rl" -eq 0 ]; then ok "neither retired Judg arm appears under lib/ or prog/"
else bad "$rl surviving reference(s) to the two retired arms:"; retired "$REPO/lib" | sed 's/^/          /'; fi

# ... and `Judg` reads 36 arms, counted out of the file.
# ⚑ THE COUNT TAKES EVERY `(jg-` HEAD ON A LINE, ALL OF THEM.  Judg's arms run
# three to a line, so doc.sh:298-307's paren-balanced walk is the device but its
# one-arm-per-line `print` is not: a line count reads 13 and grades nothing.
judg_arms() {  # judg_arms FILE -> the number of Judg constructor heads
  LC_ALL=C awk -v h="$JGH" '
    /^\(data Judg \(\)/ { f=1 }
    f {
      line=$0; sub(/;.*/,"",line)
      s=line; while ((p=index(s,h))>0) { c++; s=substr(s,p+length(h)) }
      o=gsub(/\(/,"",line); q=gsub(/\)/,"",line); d=d+o-q
      if (d<=0) { print c+0; exit }
    }' "$1"
}
narm="$(judg_arms "$DIAG")"
if [ "$narm" = "36" ]; then ok "Judg has exactly 36 arms (38 before E182, two retired)"
else bad "Judg has $narm arms, wanted 36"; fi

# (b) r-arity is CONSTRUCTED at exactly two sites -- the two live comparisons the
# element repointed, and no invented third one.
# ⚑ typing/diag.chiral IS EXCLUDED BY NAME: the arm's own declaration and its
# eight `case` patterns all spell it, and an unexcluded scan reads eleven.
sites() { ( cd "$REPO" && grep -RIn -F -- "$AR" "$1" prog 2>/dev/null ) | grep -v '/typing/diag\.chiral:'; }
ns="$(sites "$REPO/lib" | wc -l)"
if [ "$ns" -eq 2 ]; then
  ok "r-arity is constructed at exactly 2 sites: $(sites "$REPO/lib" | cut -d: -f1-2 | sed "s|^$REPO/||" | tr '\n' ' ')"
else bad "r-arity is constructed at $ns site(s), wanted 2:"; sites "$REPO/lib" | sed 's/^/          /'; fi

# M7 -- PUT THE ARM BACK.  A scratch lib/ gets `${JG_TP}` restored to `Judg` and
# check-tcon reverted to build it.  Both halves of G7 must see it: the arm count
# reads 37 and r-arity's construction sites drop to one.  Without this row the
# scans pass on needles matching nothing anywhere, which is what they would do if
# either name were merely renamed.
if mutlib "M7 put-the-arm-back" lib/typing/diag.chiral \
     "s|  (jg-not-positive)       (jg-linear-field-decl) (jg-field-nontype))|  (jg-not-positive)       (jg-linear-field-decl) (jg-field-nontype)\n  (${JG_TP}))|" \
   && mutlib_also "M7 put-the-arm-back" lib/typing/kernel.chiral \
     "s|${AR}(subj-data dn) (llen Term (decl-params decl)) (llen Term args))|(r-judged (subj-data dn) (${JG_TP}))|"; then
  m7r="$(retired "$MUTLIB" | wc -l)"; m7a="$(judg_arms "$MUTLIB/typing/diag.chiral")"; m7s="$(sites "$MUTLIB" | wc -l)"
  if [ "$m7r" -gt 0 ] && [ "$m7a" = "37" ] && [ "$m7s" -eq 1 ]; then
    ok "M7 put-the-arm-back -- both scans move: $m7r surviving reference(s), Judg 37, r-arity at 1 site"
  else
    bad "M7 put-the-arm-back -- the scans did not move: $m7r reference(s), Judg $m7a, r-arity at $m7s site(s)"
  fi
fi

# ============================================================================
# G8 -- PHASE 24 IS REGISTERED.  An unregistered script never runs, which is the
# whole reason this row exists.  `reg` greps a DIFFERENT file from the one doing
# the grep, so it cannot match its own source (row.sh:676).
echo
echo "=== E182 G8: the phase is registered ==="
reg() { grep -cE "^run_phase $1 .* $2\$" "$3"; }
if [ "$(reg 24 arity.sh "$RT")" -ge 1 ]; then ok "Phase 24 (E182) is registered in run-tests.sh"
else bad "Phase 24 (E182) is NOT registered in run-tests.sh -- an unregistered script never runs"; fi

# M8: strip the run_phase line from a COPY.  The row must notice.
cp "$RT" "$TMP/m8.sh"
sed -i '/^run_phase 24 /d' "$TMP/m8.sh"
if [ "$(reg 24 arity.sh "$TMP/m8.sh")" -eq 0 ] && [ "$(reg 24 arity.sh "$RT")" -ge 1 ]; then
  ok "M8 unregister-the-phase -- the registration row catches a deleted run_phase line"
else bad "M8 unregister-the-phase -- a deleted run_phase line was not caught"; fi

echo
echo "  (Phase 24 wall clock: $((SECONDS - T0))s, of which six compiler builds)"
echo "the arity evidence (E182 r-arity): $pass passed, $fail failed"
[ "$fail" -eq 0 ]
