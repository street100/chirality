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
# ⚑ TWO UPGRADES ADOPTED VERBATIM FROM tools/test/arity.sh:27-31, which is
# where this arc paid for them. records/gate-audit.md GA-23 is the measurement
# that brought them here, and it names what the old shape cost.
#
# 1. THE FIXTURE ASSERTS NOTHING AND ALWAYS EXITS 0. It prints seventeen
#    byte-1-separated fields; every comparison here is bash. It used to grade
#    itself and return the 1-based number of the FIRST failing case, which
#    masked every later row from every mutant: nine of the fourteen cases
#    carried no mutant, eight of them G3's own evidence arms, and one row had
#    to be rescued with a standalone `g2only.prog` probe because the exit code
#    could not reach it. That probe is gone; its assertion is `G2:ok` in a pin.
# 2. EVERY MUTANT PINS THE FULL VERDICT LINE. `verdict ROOTSPEC` prints all
#    fourteen case rows at once, so a mutant reddening a row it was not paired
#    with is impossible to miss rather than merely unlikely. Because the whole
#    line comes off ONE fixture build, full pinning here is free: the arm loop
#    below pins fourteen tokens per arm at the cost of one token.
#
# Every row that matters carries a NAMED MUTANT: a stated corruption of the
# source and the outcome it must produce. A row whose mutant also passes
# exercises nothing (the E156 lesson: a gate fixture can be blind to its own
# mutant).
#
#   G1  the FLAT LAW           -- what makes d-group sound        [M1]
#   G2  width independence     -- the law E146 consumes           [M2]
#   G3  evidence survival      -- THE element's row, nine arms     [M3,M9,M10-M17]
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
# Zero Python -- the comparisons are shell and awk, G6's census included.
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
# build_raw ROOTSPEC SRC OUT -> 0 and OUT holds the program's raw STDOUT
build_raw() {
  local rootspec="$1" src="$2" out="$3" blob="$TMP/b.blob" elf="$TMP/b.elf"
  ( cd "$REPO" && chirality_blob_file "$rootspec" "$src" ) >"$blob" 2>/dev/null || return 1
  ( ulimit -s unlimited; "$CC" <"$blob" >"$elf" 2>/dev/null ) || return 1
  [ -s "$elf" ] || return 1
  chmod +x "$elf"
  ( ulimit -s unlimited; "$elf" >"$out" 2>/dev/null ) || return 1
  [ -s "$out" ]
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

# fld N FILE -> the Nth byte-1-separated field of FILE, verbatim.
fld() { LC_ALL=C awk -v n="$1" 'BEGIN{RS="\1"} NR==n{printf "%s",$0}' "$2"; }

NL="
"
has()   { case "$1" in *"$2"*) return 0 ;; *) return 1 ;; esac; }
nohas() { ! has "$1" "$2"; }
both()  { has "$1" "$2" && has "$1" "$3"; }
nows()  { printf '%s' "$1" | tr -d '[:space:]'; }
# G2 and G3c are the two rows whose predicate is more than one `has`, so each is
# a NAMED function: `t` below runs a command, and a row spelled as a chain of
# `&&` inside a command substitution would bind the chain outside `t`.
g2ok()  { [ "$(nows "$1")" = "$(nows "$2")" ] && [ "$(nows "$2")" = "$(nows "$3")" ]; }
g3cok() { nohas "$1" "1" && nohas "$1" "omega" && both "$2" "1" "omega"; }

# mutlib NAME REPO-REL-PATH SED-EXPR... -> a scratch copy of lib/ with that file
# mutated, left in $MUTLIB. arity.sh:150's, symlink guard and stale-pattern
# refusal included: a mutation that does not apply is a mutant that proves
# nothing, and `cp -a` copies a symlink AS a symlink, so every subsequent
# `sed -i` would then write THROUGH it into the tree under test.
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

# ============================================================================
# THE FOURTEEN CASE ROWS. Every want is HAND-DERIVED from what the program
# MEANS -- rank 3 of docs/definitions/testing-floors.md -- and none is a capture
# of what the code printed. The case numbers, their order and their meanings are
# the fixture's, unchanged by the upgrade to a verdict line.
#
#  G4f/G4b  dt-g4 flattens to "header one two", 14 columns. At w=40 it fits and
#           no break is introduced; at w=10 it cannot, and the nest is 4, so the
#           broken form carries the frame's own indent.
#  G1       THE FLAT LAW: at a huge width the document equals itself with every
#           d-line replaced by its Brk's flat text. Byte equality of two
#           `doc->str` results, never of one against a golden sentence.
#  G2       WIDTH INDEPENDENCE: the same token sequence at 1, 40 and 1000000.
#           Only breaks and leading indent may differ, so the comparison drops
#           every whitespace byte. This is the law E146 consumes.
#  G3*      EVIDENCE SURVIVAL, one row per Reason arm, as SUBSTRINGS. The ninth
#           arm (r-relayed) is asserted below on a scratch root, for E157's
#           containment reason.
#           ⚑ G3red CARRIES ONE NEEDLE, NOT TWO. It used to assert
#           "data redeclared: Box" and "Box" on the same string, and the second
#           is a substring of the first, so that half held for free
#           (records/gate-audit.md GA-23). The head is built from two functions,
#           dg-subject-tag and dg-subject-name, and blanking either one breaks
#           the single needle, so nothing is lost by dropping the free half.
#           ⚑ G3lin's "quantity omega" HALF IS ALSO CARRIED BY THE HEAD, which
#           is dg-linear-msg's own sentence, so that half is E157's row and not
#           this one's. The half this element owns is the subject tag, and M13
#           is aimed there. Measured while GA-23's repair was being written.
#  G3c      THE CONTROL THAT STATES THE WIN. Same value, both exits: dg-msg
#           contains NEITHER quantity, dg-doc contains BOTH. A positive
#           assertion about the BASELINE, so it also fails if someone "fixes"
#           the baseline, at which point E157's goldens and this row must be
#           reconciled deliberately rather than silently.
ROWS="G4f G4b G1 G2 G3red G3dcl G3mis G3use G3lin G3arr G3unb G3skp G3jud G3c"

verdict() {  # verdict ROOTSPEC -> fourteen `name:ok` / `name:bad` / `name:nobuild`
  local root="$1" raw="$TMP/v.raw" out="" r
  if ! build_raw "$root" "$FIXTURE" "$raw"; then
    for r in $ROWS; do out="$out${out:+ }$r:nobuild"; done
    echo "$out"; return
  fi
  local f1 f2 f3 f4 f5 f6 f7 f8 f9 f10 f11 f12 f13 f14 f15 f16
  f1="$(fld 1 "$raw")";   f2="$(fld 2 "$raw")";   f3="$(fld 3 "$raw")"
  f4="$(fld 4 "$raw")";   f5="$(fld 5 "$raw")";   f6="$(fld 6 "$raw")"
  f7="$(fld 7 "$raw")";   f8="$(fld 8 "$raw")";   f9="$(fld 9 "$raw")"
  f10="$(fld 10 "$raw")"; f11="$(fld 11 "$raw")"; f12="$(fld 12 "$raw")"
  f13="$(fld 13 "$raw")"; f14="$(fld 14 "$raw")"; f15="$(fld 15 "$raw")"
  f16="$(fld 16 "$raw")"
  add() { out="$out${out:+ }$1:$2"; }
  t()   { if "$@"; then printf ok; else printf bad; fi; }

  add G4f   "$(t nohas "$f1" "$NL")"
  add G4b   "$(t has   "$f2" "${NL}    one")"
  add G1    "$(t [ "$f3" = "$f4" ])"
  add G2    "$(t g2ok  "$f5" "$f6" "$f7")"
  add G3red "$(t has  "$f8"  "data redeclared: Box")"
  add G3dcl "$(t both "$f8"  "declared data Box with 1 ctor(s)" "and data Box with 2 ctor(s)")"
  add G3mis "$(t both "$f9"  "expected I64" "actual Str")"
  add G3use "$(t both "$f10" "declared 1" "used omega")"
  add G3lin "$(t both "$f11" "quantity omega" "let-binder")"
  add G3arr "$(t both "$f12" "extern mint" "result Cap")"
  add G3unb "$(t both "$f13" "nosuch" "in the def namespace")"
  add G3skp "$(t both "$f14" "lowerme" "callee")"
  add G3jud "$(t both "$f15" "constructor arity" "subject ctor Nope")"
  add G3c   "$(t g3cok "$f16" "$f10")"
  echo "$out"
}

ALLOK="$(for r in $ROWS; do printf '%s:ok ' "$r"; done)"; ALLOK="${ALLOK% }"

# ============================================================================
echo
echo "=== E158 G1-G4: the fixture -- fourteen case rows in one line ==="
BASE="$(verdict "lib:prog")"
if [ "$BASE" = "$ALLOK" ]; then
  ok "e158_doc: all 14 cases hold (2 group . 1 flat law . 1 width . 9 evidence . 1 control)"
else
  bad "the case rows do NOT all hold"
  echo "          got:  $BASE"
  echo "          want: $ALLOK"
fi

# The measured values, printed once: a gate that only reports ok/bad about a
# rendering makes that rendering unreadable to whoever has to fix it.
if build_raw "lib:prog" "$FIXTURE" "$TMP/b.raw"; then
  echo "          dt-g4 at width 10:"
  { fld 2 "$TMP/b.raw"; echo; } | sed 's/^/            /'
  echo "          dg-doc over r-redeclared at width 80:"
  { fld 8 "$TMP/b.raw"; echo; } | sed 's/^/            /'
fi

# ============================================================================
# Each mutant names ONE corruption and pins the WHOLE verdict line it must
# produce. A mutant that reddens a row it was not paired with is caught by the
# same assertion that catches one that reddens nothing.
echo
echo "=== E158 the named mutants (a row whose mutant passes exercises nothing) ==="
mutant() {  # mutant NAME WANT-VERDICT REPO-REL-PATH SED-EXPR...
  local name="$1" want="$2" rel="$3"; shift 3
  mutlib "$name" "$rel" "$@" || return
  local got; got="$(verdict "$MUTLIB:$REPO/prog")"
  if [ "$got" = "$want" ]; then ok "$name -- $(echo "$got" | tr ' ' '\n' | grep -c ':bad') row(s) red, exactly the pinned ones"
  else
    bad "$name -- the verdict is not the pinned one"
    echo "          got:  $got"
    echo "          want: $want"
  fi
}

# M4 (G4f): ALWAYS BREAK. The one decision point in the element stops deciding.
# ⚑ IT REDDENS G1 TOO, and that is a fact the old shape could not report: the
# fixture stopped at case 1 and never reached the flat law. G2 stays green
# because the token sequence is unchanged, which is the asymmetry that makes G4
# and G1 separate rows from G2, and it is now a pinned token rather than a
# separate probe program.
mutant "M4 always-break (d-group never picks m-flat)" \
  "G4f:bad G4b:ok G1:bad G2:ok G3red:ok G3dcl:ok G3mis:ok G3use:ok G3lin:ok G3arr:ok G3unb:ok G3skp:ok G3jud:ok G3c:ok" \
  lib/prelude/doc.chiral \
  's|(true  (doc-best w k (cons (dfr i (m-flat) b) rest) acc))|(true  (doc-best w k (cons (dfr i (m-brk) b) rest) acc))|'
# M1 (G1): SWAP SOFT AND SPACE. A brk-soft starts flattening to " ". Only the
# flat law can see it -- G2 strips whitespace and stays green.
mutant "M1 swap-soft-and-space (brk-soft flattens to a space)" \
  "G4f:ok G4b:ok G1:bad G2:ok G3red:ok G3dcl:ok G3mis:ok G3use:ok G3lin:ok G3arr:ok G3unb:ok G3skp:ok G3jud:ok G3c:ok" \
  lib/prelude/doc.chiral \
  's|((brk-soft)  (doc-best w k rest acc))|((brk-soft)  (doc-best w (+ k 1) rest (cons " " acc)))|'
# M2 (G2): CLIP D-TEXT. d-text stops being atomic and is truncated to the
# remaining width. This is the mutant that proves atomicity is TESTED rather
# than asserted in a comment.
# ⚑ G2 ALONE, and the reason is arithmetic rather than luck: clipping is a
# no-op wherever every d-text already fits in the width left on its line. The
# evidence rows render at 80 and their longest line is the r-arrow head, whose
# needle "extern mint" sits in the first eleven columns; G4 renders "header one
# two" at 40 and "one" at indent 4 in 10; G1 renders at 1000000. Only G2's
# width-1 leg has a d-text wider than the room left for it.
mutant "M2 clip-d-text (d-text truncated to the remaining width)" \
  "G4f:ok G4b:ok G1:ok G2:bad G3red:ok G3dcl:ok G3mis:ok G3use:ok G3lin:ok G3arr:ok G3unb:ok G3skp:ok G3jud:ok G3c:ok" \
  lib/prelude/doc.chiral \
  's|((d-text s)   (doc-best w (+ k (str-len s)) rest (cons s acc)))|((d-text s)   (doc-best w (+ k (str-len s)) rest (cons (str-sub s 0 (min (str-len s) (max 0 (- w k)))) acc)))|'

# M3 (G3use): DROP OBSERVED. dg-doc's r-usage arm stops emitting the observed
# quantity -- the classic "carry the evidence, lose the disagreement" failure,
# and every layout property above it still holds. It reddens G3c as well, since
# the control's second half reads the same field; the old shape reported case 8
# and said nothing about case 14.
mutant "M3 drop-observed (dg-doc's r-usage arm drops oq)" \
  "G4f:ok G4b:ok G1:ok G2:ok G3red:ok G3dcl:ok G3mis:ok G3use:bad G3lin:ok G3arr:ok G3unb:ok G3skp:ok G3jud:ok G3c:bad" \
  lib/typing/diag.chiral \
  's|(cons (d-text (dg-qty-name oq)) nil)|(cons (d-text "") nil)|'
# M3c (G3c): MAKE THE BASELINE VERBOSE. dg-msg's own r-usage arm starts naming
# the quantities. The control is a POSITIVE assertion about the baseline, so it
# must go red -- and E157's Phase 13 goldens must go red too. Both, which is the
# point: "fixing" dg-msg is a deliberate reconciliation, never a silent one.
mutant "M3c make-dg-msg-verbose (the baseline starts naming the quantities)" \
  "G4f:ok G4b:ok G1:ok G2:ok G3red:ok G3dcl:ok G3mis:ok G3use:ok G3lin:ok G3arr:ok G3unb:ok G3skp:ok G3jud:ok G3c:bad" \
  lib/typing/diag.chiral \
  's|((r-usage      w d o)  (dg-usage-msg w))|((r-usage      w d o)  (str-cat (dg-usage-msg w) (str-cat " " (str-cat (dg-qty-name d) (dg-qty-name o)))))|'

# ============================================================================
# M10-M17 -- G3's OTHER EIGHT EVIDENCE CASES, one mutant each.
#
# ⚑ EIGHT MUTANTS, NOT ONE. Before this loop, of the nine Reason arms the
# fixture walks only case 8's r-usage had a falsifier (records/gate-audit.md
# GA-23); the other eight rows were reddened by nothing anywhere in the tree.
# Each mutant below blanks ONE `d-text` inside ONE arm of dg-doc, so the arm
# still compiles -- an arm DELETION would refuse the module and score fourteen
# `nobuild`, which is GA-19's trap and no conviction at all -- and each pins the
# FULL fourteen-token line, which costs nothing extra because the whole line
# comes off the one fixture build the mutant already pays for.
#
# ⚑ THE NEEDLES ARE UNIQUE IN diag.chiral, checked rather than assumed, except
# M13's: `(d-text (dg-subject-tag w))` occurs seven times, so that one is range-
# addressed to the r-linear arm, the idiom at arity.sh:394. `mutlib` refuses any
# needle that matched nothing, so a spelling that drifts is a FAIL and not a
# silent pass.
arm_mutant() {  # arm_mutant NAME RED-ROW SED-EXPR...
  local name="$1" red="$2"; shift 2
  local want="" r
  for r in $ROWS; do
    if [ "$r" = "$red" ]; then want="$want${want:+ }$r:bad"; else want="$want${want:+ }$r:ok"; fi
  done
  mutant "$name" "$want" lib/typing/diag.chiral "$@"
}

arm_mutant "M10 redeclare-head-loses-the-verb"  G3red \
  's|(cons (d-text " redeclared: ")|(cons (d-text "")|'
arm_mutant "M11 redeclare-drops-the-newcomer"   G3dcl \
  's|(d-tag "diag-site" (dg-decl-doc "and" nw))|(d-text "")|'
arm_mutant "M12 mismatch-drops-the-actual-term" G3mis \
  's|(cons (pp-of pfx a) nil)|(cons (d-text "") nil)|'
arm_mutant "M13 linear-drops-the-subject-tag"   G3lin \
  '/(d-text (dg-linear-msg w q))/,/(cons (d-text (dg-qty-name q)) nil)/ s|(d-text (dg-subject-tag w))|(d-text "")|'
arm_mutant "M14 arrow-drops-the-linear-result"  G3arr \
  's|(cons (d-text x) nil)|(cons (d-text "") nil)|'
arm_mutant "M15 unbound-drops-the-namespace"    G3unb \
  's|(cons (d-text " namespace")|(cons (d-text "")|'
arm_mutant "M16 skipped-drops-the-chain"        G3skp \
  's|(dg-chain-doc c)|(d-text "")|'
arm_mutant "M17 judged-drops-its-head"          G3jud \
  's|(d-text (dg-judg-msg w j))|(d-text "")|'

# ...and the other half of M3c, one layer down: a compiler built from the same
# mutation must stop emitting E157's golden sentence. Without this the claim
# "Phase 13 goes red too" is a sentence in a comment.
echo
echo "=== E158 M3c(compiler): the same mutation moves E157's Phase 13 golden ==="
if mutlib "M3c(compiler)" lib/typing/diag.chiral \
     's|((r-usage      w d o)  (dg-usage-msg w))|((r-usage      w d o)  (str-cat (dg-usage-msg w) (str-cat " " (str-cat (dg-qty-name d) (dg-qty-name o)))))|'; then
  ( cd "$REPO" && chirality_blob_file "$MUTLIB:$REPO/prog" "$REPO/prog/compiler.prog" ) >"$TMP/m.blob" 2>/dev/null
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
# ⚑ THE PROBE PRINTS AND ASSERTS NOTHING, like the fixture and for the reason
# in the header. Every binding in it is `dq-` prefixed, because $TMP is outside
# the tree but this file, which holds the heredoc, is not.
RELAY_CTOR="(r-""relayed (rl-parse) \"bad\")"
cat >"$TMP/relay.prog" <<RELAY
(import "prelude/prelude")
(import "prelude/string")
(import "prelude/doc")
(import "ports/stdio")
(import "typing/diag")
(def dq-rendered Str (doc->str 80 (dg-doc $RELAY_CTOR)))
(def compile-main (=> I64 I64) (lam (n) (let ((_ (put dq-rendered))) 0)))
RELAY
relay_token() {  # relay_token ROOTSPEC -> ok / bad / nobuild for the r-relayed row
  local r="$TMP/relay.raw" s
  if build_raw "$1" "$TMP/relay.prog" "$r"; then
    s="$(cat "$r")"
    if both "$s" "data-group: bad" "relayed by parse"; then printf ok; else printf bad; fi
  else printf nobuild; fi
}
rrc="$(relay_token "lib:prog")"
if [ "$rrc" = ok ]; then ok "r-relayed keeps BOTH its message and the layer that relayed it"
else bad "r-relayed evidence did not survive (probe token $rrc)"; fi
# M9: the relaying LAYER stops reaching the output. Which layer relayed is a
# closed sum precisely so it is not a string nobody notices; dropping it is the
# same defect one level up. `nobuild` is not `bad`, so a mutation that stopped
# compiling is a FAIL of this row rather than a conviction.
if mutlib "M9 drop-the-relay-layer" lib/typing/diag.chiral \
     's|(cons (d-text (dg-relay-tag f)) nil)|(cons (d-text "") nil)|'; then
  m9rc="$(relay_token "$MUTLIB:$REPO/prog")"
  if [ "$m9rc" = bad ]; then ok "M9 drop-the-relay-layer -- the r-relayed row goes red, as required"
  else bad "M9 drop-the-relay-layer -- probe token $m9rc, wanted bad"; fi
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
# ⚑ IT ALSO RUNS (b)'s CENSUS OVER THE MUTATED TREE. M5's substitution produces
# exactly the seventh arm (b) exists to catch, and until GA-23's repair the
# census was never once run against a tree that had one: it read six on the real
# tree and nothing ever asked it for seven. This is arity.sh:451-460's M7 shape,
# one census over.
cat >"$TMP/bare.prog" <<'BARE'
(import "prelude/doc")
(def compile-main (-> I64 I64) (lam (n) 42))
BARE
if mutlib "M5 add-seventh-constructor" lib/prelude/doc.chiral \
     's|  (d-tag   (name Str) (body Doc)))|  (d-tag   (name Str) (body Doc))\n  (d-fill  (body Doc)))|'; then
  m5err="$(build_err "$MUTLIB:$REPO/prog" "$TMP/bare.prog")"
  if [ -n "$m5err" ]; then ok "M5 add-seventh-constructor -- refused: $(echo "$m5err" | head -c 90)"
  else bad "M5 add-seventh-constructor -- a 7th Doc arm compiled clean; the closed sum buys nothing"; fi
  m5n="$(doc_ctors "$MUTLIB/prelude/doc.chiral" | grep -c .)"
  if [ "$m5n" -eq 7 ]; then ok "M5 add-seventh-constructor -- the census moves to 7: $(doc_ctors "$MUTLIB/prelude/doc.chiral" | tr '\n' ' ')"
  else bad "M5 add-seventh-constructor -- the census read $m5n on a tree with a 7th arm; G5(b) is censusing nothing"; fi
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
# Decision 6, made checkable. The plain-text exit keeps E157's byte-identity
# goldens; `dg-doc` is graded on evidence survival. The moment either exit is
# asserted against the other, `Doc` has re-imported the constraint it exists to
# lift.
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
# ...and the fixture's only reference is the ONE that EMITS the baseline string
# for G3c to read. Pinned at the control, not at zero: the control must call it.
# It was two while the fixture graded itself and made the absence assertion in
# chirality; the fixture now prints and bash makes the assertion.
n_fix="$(gm_in_fixture "$FIXTURE")"
if [ "$n_fix" -eq 1 ]; then ok "the fixture's only baseline reference is G3c's 1 emitted value"
else bad "the fixture references the baseline exit $n_fix time(s) in code, wanted exactly 1 (the G3c control)"; fi

# M7(ii): add ONE golden row over the baseline exit to a copy of doc.sh, and to
# a copy of the fixture. Both halves of (a) must go red -- (i) below never
# touches doc.sh, so without this pair (a) has no teeth.
cp "$HERE/doc.sh" "$TMP/m7.sh"
printf '\ngot="$(dg%s dt-usage)"; [ "$got" = "linear binder usage mismatch" ]\n' "-msg" >>"$TMP/m7.sh"
cp "$FIXTURE" "$TMP/m7.prog"
printf '\n; (str-eq (dg%s dt-usage) "linear binder usage mismatch")\n(def dt-cross Bool (str-eq (dg%s dt-usage) "linear binder usage mismatch"))\n' "-msg" "-msg" >>"$TMP/m7.prog"
if [ "$(gm_goldens "$TMP/m7.sh")" -gt 0 ] && [ "$(gm_in_fixture "$TMP/m7.prog")" -gt 1 ]; then
  ok "M7(ii) cross-assert -- a golden row in either file is caught by G7(a)"
else bad "M7(ii) cross-assert -- G7(a) did not catch an added golden row"; fi

# (b) E157's gate is byte-unchanged by this element, against a PINNED sha256.
# (A `git diff --stat` row is not equivalent: once these commits land, the diff
# against them is empty forever and the row reports ok for the rest of time.)
DIAG_SH_SHA=ec0d72f3793459af9719e8eeb8816e065c9d5b9efd49110251ebf2e4ed8cd8fd
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
