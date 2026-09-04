---
element: C1C2
slug: style-round-trip
title: "Relate the two style representations, and make the round trip close"
kind: law
reference_class: OURS
ours_source: lib/protocol/render.chiral, lib/protocol/grid.chiral
status: drafted
updated: 2026-09-04
---

# C1C2. Relate the two style representations, and make the round trip close

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** rows `display-calculus/C1` and `C2` together, arc-local ids per
  [[decisions/decision-work-ids]], both `unminted`. C1 is a typed property value
  whose invalid states have no representation. C2 is the cascade as a total
  ordered fold with a stated law.
- **The id.** `C1C2`, and it names two rows on purpose. `C02` would claim
  `display-calculus/C2` alone and repeat the defect this run exists to correct:
  C01 was filed under `C1` while covering four rows, and its INDEX row had to
  carry the coverage in prose. `C12` collides with the live arc row
  `display-calculus/C12` (shorthands as constructors). `C1C2` names both rows in
  the id, collides with no row, and sorts beside `C01`. Frontmatter follows the
  N07 precedent: a flat `element:` field, no `E#`, no catalog row.
  `tools/pack/pack.py` scaffolds none of this. Its id regex accepts `E`, `U`,
  `S` and `N` only, and refused `C1C2` in this run with *"element id must look
  like E13 / U13 / S19 / N1"*. The bundle was assembled by hand, as C01's was.
- **Kind:** `law`. Both halves of the value are on disk. What is owed is the
  equation between them and a gate that reddens when either half moves.
- **This supersedes C01's framing.** `docs/examples/C01-typed-style-value.md` is
  `status: superseded`, `superseded_by: C1C2`. It reads C1 and C2 as machinery
  to build. `lib/protocol/grid.chiral` already carries the machinery: `Color` is
  a closed three-arm sum (`:6`), `Attrs` is six named `Bool`s over it (`:12`),
  `Sgr` (`:35`) is a boundary sum, `parse-sgr` (`:201`) is where it is built,
  `apply-one` (`:215`) cases over it arm-per-arm with no default clause, and
  `fold-sgr` folds it in order (`:232`). `docs/elements/ledger.md:177` records
  the lot as E111, `built`. **The work is retiring a duplicate representation,
  and this element does not add a third.**
- **Why chirality needs its own:** the tree carries one concept twice, facing
  opposite directions, with nothing relating them. The emit side is
  `lib/protocol/render.chiral`: `Face` (`:37`) with four bare fields, `face-sgr`
  (`:188`) turning it into SGR bytes, and `face-join` (`:366`) as a cascade rule
  written in a comment with no law and no check. The decode side is
  `grid.chiral`, above. `face-sgr` emits, `parse-sgr` and `fold-sgr` read, and
  no gate feeds one into the other.
- **Not in scope.** `display-calculus/C4` (the inherit sum) and `C5` (a
  root-supplied theme). C01 covered both; this element takes neither over, and
  both arc rows return to `not started`. Retyping `Face`'s three `I64` fields,
  which is where the emit side's invalid states actually die, is §6's follow-on.
  `A1` and `A2` stay owed and §6 states what that costs this element's gate.

## 2. Research

- **Reference class:** `OURS`. `lib/protocol/render.chiral` (`Face`,
  `default-faces`, `lookup-face`, `sgr-code`, `face-sgr`, `face-join`,
  `rnd-restore`), `lib/protocol/grid.chiral` (`Color`, `Attrs`, `Sgr`,
  `parse-sgr`, `apply-one`, `fold-sgr`), `lib/protocol/vt-parser.chiral` (the
  CSI parameter collector and `act-sgr`), `tools/test/face.sh` (the E175 gate
  and its awk SGR reducer). [[banks/render]] shards C, D, G, H and L are the
  same tier read as a refraction; every claim below is measured against the tree
  rather than taken from that bank.

**The four measurements this pre-run owed, taken 2026-09-04 at `8928028`.**

### M1. The round trip does not close, and it loses in three named places

Measured by compiling two probe roots against `lib/` and reading their output,
rather than by reading the source. `face-sgr` was applied across the whole
constructible span of `Face`'s attribute mask and colour indices; `parse-sgr`
was applied to every code from 0 to 50.

`parse-sgr` names **23** of the 51 codes: `0 1 4 7 22 24 27`, `30` through `37`,
and `40` through `47`. Every other code returns `sgr-other`, which `apply-one`
folds as identity (`grid.chiral:229`).

| the loss | measured | consequence |
|---|---|---|
| **italic** | attribute bit `4` emits `ESC[3m`; code `3` returns `sgr-other` | **8 of the 16 attribute masks lose a bit.** `Sgr` has an `sgr-italic` arm, folded at `grid.chiral:223` inside `apply-one`; `parse-sgr` never constructs one, so the arm is dead |
| **fg aliases onto bg** | `fg` 10 through 17 emit `ESC[40m` through `ESC[47m` | a foreground index decodes as a **background** change. `Face`'s `fg` is a bare `I64`, so `(face "x" 10 -1 0)` typechecks |
| **fg 8, 9 and bg 8, 9** | emit `ESC[38m` `ESC[39m` `ESC[48m` `ESC[49m` | all four return `sgr-other` and vanish. `38` and `48` are ECMA-48's extended-colour introducers, so the emitter spells the start of a sequence it never finishes |

**Over the shipping registry the trip closes.** `default-faces`
(`render.chiral:148`) has eleven entries; their attribute masks are `{0, 1, 2,
8}` and every `fg`/`bg` is `-1` or in `0..7`. Not one sets bit `4`. So a gate
walking only the registry passes while every failure above stands, which is what
makes the walk over constructed values the load-bearing half of the gate.

**The direction question, confirmed with a correction.** `Face` to `Attrs` is
total as a direct function and lossy through the byte channel. `Attrs` to `Face`
is lossy outright: `Attrs` carries `blink` and `strike` for which `Face` has no
bit, and `Color` carries `color-rgb` and `color-indexed` up to 255 for which
`face-sgr` has no spelling. So `Face` is a **projection** of `Attrs`, and `Attrs`
is the representation that survives. The correction is that the projection is
faithful only on a sub-domain `Face`'s type states nowhere: `fg` and `bg` in
`{-1} ∪ 0..7`, attribute mask in `0..15`.

### M2. `grid.chiral` is reached by fixtures and by nothing that runs

`grep -rn '(import "protocol/grid")' lib/ prog/` returns **five** importers:
`lib/protocol/vt-parser.chiral` and four roots under `prog/scriba/samples/`
(`t4_minimal`, `t4_grid`, `t4_codec`, `t5_vt_parser`). `vt-parser.chiral`'s own
importers are **two**, both sample roots (`t5_vt_parser`, `t6_apc_roundtrip`).
Every path to `grid.chiral` bottoms out under `prog/scriba/samples/`.

Those roots reach Phase 7, which **compiles and runs nothing**: the phase's own
header says *"Compile only"* (`tools/test/run-tests.sh:150`) and the loop ends
at the compiler (`:177-190`). Neither `t4_grid` nor `t5_vt_parser` is in that
phase's `KNOWN_FAIL` (`:173`), and both were compiled clean in this run.

**Zero roots under `tools/test/samples/` import `protocol/grid` or
`protocol/vt-parser`.** Three import `protocol/render` (`e158_render`,
`e174_row`, `e175_face`); `e158_doc`, `e181_pretty` and `e182_arity` reach the
display tier through `prelude/doc` and `typing/diag` instead. So the half of
this element's law that runs today is the emit half, and the decode half is
gated on compilation and on nothing else.

⚑ **A root under `tools/test/samples/` creates no reach by itself, and this is
the measurement that prices the gate.** Phase 7's census is
`grep -rl '^(def compile-main' lib prog` (`run-tests.sh:175`), so `tools/` sits
outside it and nothing there is even compiled by the sweep. Phase 2's manifest
is six named roots under `prog/samples/` (`prog/test-runner.prog:40-46`) and it
is a bundled list rather than a directory walk, so it reaches nothing under
`tools/` either. ⚑ `tools/test/tal-check.sh:127-129` states the opposite,
*"everything under samples/ is walked by Phase 2's test-runner and counted by
the compile-only root census"*, and both halves are false against the two
sources above. Both were re-measured in this run and both hold. The false
claim is filed as [[records/gate-audit]] GA-25. Every root under
`tools/test/samples/` is reached by exactly one thing: a script naming it as
its `FIXTURE`. **So the reach this element needs is its own script, and §6
takes the standing precedent for a script whose suite number is unsettled:
declared out of the dispatch table, and run by hand.**

### M3. `grid.chiral` is outside the compiler's blob, measured on the blob

Built in this run: `chirality_blob_file "lib:prog" prog/compiler.prog` gives
**812,351 bytes** over **17,335 lines**. Searched:

| string | occurrences in the blob |
|---|---|
| `protocol/grid` | **0** |
| `data Attrs`, `data Color`, `data Sgr`, `parse-sgr`, `apply-one`, `fold-sgr`, `cell-bytes` | **0** each |
| `data Face`, `data Rendering`, `face-sgr`, `face-join` | **0** each |
| `protocol/render` | **4**, every one a comment inside `lib/prelude/doc.chiral` (`:48`, `:85`, `:181`, `:182`) |

So both files this element edits sit outside the fixpoint, and implementation is
a plain `chirality run FILE` under [[working-discipline]]'s ordinary rule.
⚑ `lib/protocol/render-doc.chiral:19-24` states the same measurement and says
*"two occurrences"*; the live count is four, all still comments in
`prelude/doc.chiral`. The claim holds and its figure has drifted.

### M4. `face-join` and `apply-one` are one fold, on the domain M1 names

`face-join` (`render.chiral:366`) accumulates attributes with `bor`, lets a
non-negative inner colour win, and inherits the outer's on a negative. `fold-sgr`
starts from a pen and applies each parsed code. On the sub-domain those two agree
arm for arm, and the agreement is exact rather than approximate:

| what `face-join` does | what the fold does with `face-sgr`'s bytes |
|---|---|
| `(bor oat iat)`, a set bit never clears | `face-sgr` emits a code only for a set bit, so an unset bit leaves the pen's value standing. Same result |
| a negative inner colour inherits the outer's | `face-sgr` emits nothing for a negative colour, so the pen keeps its colour. Same result |
| a non-negative inner colour replaces | `face-sgr` emits `30+fg`, `apply-one`'s `sgr-fg` arm replaces the field. Same result |
| the joined name is the inner's | no SGR code carries a name. `Attrs` has no name field |

**The emitter already depends on this and states it nowhere.**
`render.chiral:772-773` puts `face-sgr f`, which is the **inner's** delta, and
recurses with `face-join amb f`, which is the **joined** face. Those two describe
the same terminal state only if the equation holds. `rnd-restore` (`:394`) is the
other half: it emits `ansi-reset` (`ESC[0m`, `:329`) and then `face-sgr amb`,
which the decode side reads as `sgr-reset` to `blank-attrs` followed by the
ambient's codes. E175's own comment calls `face-join` *"a DESCRIPTION of what the
emitter ALREADY DOES"*. This element is that description promoted to an equation
between two built functions.

**They diverge outside the domain**, at exactly M1's three losses, plus two
arms the emit side cannot reach at all: `sgr-blink` and `sgr-strike` have no
`Face` bit, so they stay dead after this element and §6 records it.

### M5. The blast radius, and it is smaller than the `r-face` figure

| measured | figure | command |
|---|---|---|
| `(r-face` applications | **26** tree-wide, **18** under `prog/scriba/` | `grep -rn '(r-face' lib/ prog/ \| grep -v ':[0-9]*: *;'` |
| `(face-sgr` call sites | **2**, both in `render.chiral` (`:396`, `:772`) | `grep -rn '(face-sgr' lib/ prog/` |
| `(face-sgr` inside gate mutants | **2** more, `face.sh:371` and `render-doc.sh:362`, both `sed` patterns over a copy | the same, with `tools/` added |
| `(face-join` call sites | **1**, `render.chiral:773` | `grep -rn '(face-join' lib/ prog/ tools/` |
| `Face` constructions | **14**, every one in `render.chiral` | `grep -rn '(face ' lib/ prog/` returns 20; the six the figure excludes are the `face` constructor's own field list (`:38`), `r-face`'s `face` field (`:15`), three `case` patterns (`:191`, `:369`, `:371`) and a lambda parameter named `face` (`chat-view.chiral:121`) |
| `lookup-face` call sites | **8** | `grep -rn '(lookup-face' lib/ prog/` |

**This element carries none of the 26.** The `r-face` constructor
(`render.chiral:15`) holds a `Str` face name and never a `Face` value, so
nothing in the tree walk moves when
`Face` gains a projection. The 26 price *retiring* `Face`, which §6 hands to a
follow-on row. The figure that prices this element is the second and third rows:
three call sites, one file.

⚑ **The 14 `Face` constructions are all in one file**, which reprices the
follow-on too. Two of the 14 are computed rather than literal (`lookup-face`'s
miss arm at `:167`, `face-join`'s result at `:372`), and those two are what makes
a refinement on the field a live question rather than a formality. §6 carries it.

### M6. A third SGR model exists, in the tool tier, and the bank has no shard for it

`tools/test/face.sh:176-223` is `SGR_AWK`, a **third** representation of the same
value: an `attr[]` set plus single-valued `fg` and `bg` registers, in awk, with
its own state machine over `ESC[…m`. It is E175's Phase 16 gate and it runs.

It disagrees with `apply-one` on three classes. Its final arm is
`else { attr[v]=1 }`, so `ESC[22m` sets attribute 22 where `apply-one` clears
bold; every unknown code becomes a set flag where `parse-sgr` returns
`sgr-other` and the fold ignores it; and the reducer honours `39` and `49` as
default-fg and default-bg (`face.sh:213`, `:215`) where `parse-sgr` has no row
for either and returns `sgr-other`. So the two models disagree in **both**
directions: the awk knows two codes the typed decoder does not, and the typed
decoder knows three off-codes the awk does not. `face-sgr` emits none of the
five today, so the gate stands correct where it is. It does mean the awk reducer
cannot serve as the oracle for this element's law without diverging from it.

⚑ **This is a finding about [[banks/render]].** That bank lists twenty-three
shards across twelve homes and gives none of them to `tools/test/face.sh`. A
running SGR state machine in the tool tier is a shard of the style engine by the
bank's own §1 definition, and it is the one place the emitter's bytes are
actually decoded today. The bank should carry it.

## 3. Conventional (other-language) approach

The C terminal stack has this exact split and does not close it either. ncurses
holds the emit side as a bitmask; libvterm holds the decode side as a struct of
bitfields plus a tagged colour union. Two libraries, one concept, no conversion.

```c
/* emit side: ncurses. A style is bits in an integer, plus a palette pair. */
attr_t a = A_BOLD | A_UNDERLINE | A_REVERSE;
wattr_set(win, a, color_pair_index, NULL);
/* COLOR_PAIR(n) packs the pair number into the SAME integer as the attributes,
   so the "style" is one machine word with no accessor that can fail.        */

/* decode side: libvterm. A style is named fields plus a tagged colour.      */
typedef struct {
  unsigned int bold : 1, underline : 2, italic : 1,
               blink : 1, reverse : 1, strike : 1, font : 4;
} VTermScreenCellAttrs;
/* VTermColor carries a type tag: DEFAULT_FG / DEFAULT_BG / INDEXED / RGB.   */
```

- **Assumptions it bakes in.** The bitmask is an integer, so every invalid
  combination is constructible and `a | 0x8000` is a legal `attr_t`. The two
  representations are related by a hand-written SGR emitter on one side and a
  hand-written CSI parser on the other, and nothing checks that the emitter's
  output is in the parser's input language. Round-tripping is a property a test
  suite may sample and no type states. The inherit case is a sentinel: ncurses
  has no "no opinion" colour, so callers reserve a pair index or pass `-1`.
- **The one place the conventional world does better.** Python's `rich` keeps a
  single `Style` class for both directions, with `Optional[bool]` fields where
  `None` means inherit. One representation, so no conversion can drift. It pays
  for that with a three-state field the type system does not distinguish from a
  two-state one, and with a cascade operator whose law is a docstring.

## 4. The chirality idea

- **Chirality features in play:** boundary sums, already applied on the decode
  side and cited by [[working-discipline]]'s standing directive; total `case`
  with no default arm, which is what makes `apply-one` a fold rather than a
  dispatcher; purity as a typed fact, since the whole law lives in `->` and the
  gate root is the only `=>`; substrate over bolted-on invariants, which decides
  where `face-params` lives.
- **The reframing.** The typed style value exists. Two functions in `->` state
  its relation to the untyped one, and one equation ties the two cascades:

  ```
  fold-sgr (face->attrs outer) (face-params inner)
    ==  face->attrs (face-join outer inner)
  ```

  `face->attrs` is the projection M1 measured. `face-params` is `face-sgr`'s own
  code list, hoisted out so the equation is stated over `(List I64)` with no CSI
  scanner anywhere in it. With `outer` at `rnd-face-plain` the equation degenerates
  to the plain round trip, `fold-sgr blank-attrs (face-params f) == face->attrs f`.
- **`face-params` is a split rather than a copy, and that is the whole design
  decision.** A second function returning `face-sgr`'s codes, checked against
  `face-sgr` by a gate row, is an invariant bolted across two definitions that
  can drift. One definition read twice cannot. So `face-sgr` becomes
  `(sgr-str (face-params f))`: its type does not move, its two call sites do not
  move, and the codes become a value on the way to becoming bytes.
- **What chirality makes impossible here.** `apply-one`'s `case` has an arm per
  `Sgr` constructor and no `_`, so adding a constructor is a compile error at
  every fold rather than a silent fall-through. `parse-sgr` returns a value for
  every `I64`, so an unrecognised code has a name (`sgr-other`, `grid.chiral:40`)
  instead of a halt or a dropped param. `face->attrs` and `face-params` sit in
  `->`, so neither can reach a terminal, and the law is decidable without one.
  ⚑ What chirality does **not** make impossible here is `(face "x" 10 -1 255)`.
  Three bare `I64`s state nothing, and closing that is §6's follow-on.
- **The one code this element adds to `grid.chiral`.** `parse-sgr` gains
  `3` and `23`, the arm `apply-one` has carried since E111. That single `cond`
  pair is what turns M1's italic loss into a closed trip and retires a dead
  constructor arm in the same edit.

## 5. Chirality example (fleshed)

```chirality
; ═══ 1. lib/protocol/grid.chiral — parse-sgr reaches an arm apply-one already has

; parse-sgr's cond gains two rows beside the bold/underline/reverse pairs it
; already carries. `sgr-italic` is declared at :37 and folded at :223; nothing
; in the tree constructs one today, so this is a dead arm being reached rather
; than a new capability.
(def parse-sgr
  (lam (code)
    (cond ((=i code 0)  sgr-reset)
          ((=i code 1)  (sgr-bold true))
          ((=i code 22) (sgr-bold false))
          ((=i code 3)  (sgr-italic true))      ; NEW: face-sgr emits 3 for bit 4
          ((=i code 23) (sgr-italic false))     ; NEW: ECMA-48's italic-off, for symmetry
          ((=i code 4)  (sgr-underline true))
          ; … the underline-off, reverse and colour rows are unchanged …
          (else (sgr-other code)))))

; ═══ 2. lib/protocol/render.chiral — one definition, read twice

; The codes become a VALUE before they become bytes. `face-sgr`'s type is
; unchanged, so its two call sites (:396 and :772) do not move. Built back to
; front with `cons`, because the prelude has no `append`.
(declare face-params (-> Face (List I64)))
(declare sgr-str     (-> (List I64) Str))

(def face-params
  (lam (f)
    (case f
      ((face name fg bg attrs)
        (let ((l0 nil))
        (let ((l1 (case (<i bg 0) (true l0) (false (cons (+ 40 bg) l0)))))
        (let ((l2 (case (<i fg 0) (true l1) (false (cons (+ 30 fg) l1)))))
        (let ((l3 (case (=i (band attrs 8) 8) (true (cons 7 l2)) (false l2))))
        (let ((l4 (case (=i (band attrs 4) 4) (true (cons 3 l3)) (false l3))))
        (let ((l5 (case (=i (band attrs 2) 2) (true (cons 4 l4)) (false l4))))
          (case (=i (band attrs 1) 1) (true (cons 1 l5)) (false l5))))))))))))

(def sgr-str
  (lam (ps)
    (case ps
      (nil "")
      ((cons p rest) (str-cat (sgr-code p) (sgr-str rest))))))

; the whole of face-sgr after the split. Byte-identical output by construction.
(def face-sgr (lam (f) (sgr-str (face-params f))))

; ═══ 3. lib/protocol/style.chiral (NEW) — the conversion and the law

; Homed here rather than in render.chiral, and the price is measured: a root
; importing `protocol/render` alone blobs to 64,498 bytes; the same root also
; importing `protocol/grid` blobs to 103,914. Putting the grid import into
; render.chiral charges all 18 of its importers 39,416 bytes for a type they do
; not use. `lib/protocol/render-doc.chiral` is the precedent for a bridge module
; that joins two tiers and changes no blob.
(import "prelude/prelude")
(import "protocol/render")   ; Face, face-params, face-join, default-faces
(import "protocol/grid")     ; Color, Attrs, parse-sgr, apply-one, fold-sgr, blank-attrs

(declare idx->color   (-> I64 Color))
(declare face->attrs  (-> Face Attrs))
(declare color-eq     (-> Color Color Bool))
(declare attrs-eq     (-> Attrs Attrs Bool))
(declare in-sgr-domain (-> Face Bool))
(declare joins-agree  (-> Face Face Bool))

; A negative index is "the terminal's default", which the typed side spells as a
; constructor. Every non-negative index is a palette index.
(def idx->color
  (lam (i) (case (<i i 0) (true color-default) (false (color-indexed i)))))

; The projection M1 measured: total, and lossy in the other direction. `blink`
; and `strike` are false because `Face` has no bit for either.
(def face->attrs
  (lam (f)
    (case f
      ((face name fg bg attrs)
        (attrs (=i (band attrs 1) 1)          ; bold
               (=i (band attrs 2) 2)          ; underline
               (=i (band attrs 4) 4)          ; italic
               (=i (band attrs 8) 8)          ; reverse
               false false                    ; blink, strike: unreachable from Face
               (idx->color fg) (idx->color bg))))))

; ⚑ THIS PAIR ALREADY EXISTS, in a fixture rather than in lib/.
; `prog/scriba/samples/t4_codec.prog:17-32` defines `color-eq` and `attrs-eq`
; over these same two types, structurally identical to the bodies below, with
; its own `booleq` at `:15`. That root is one of the four Phase 7 compiles and
; does not run. THE CALL, taken here: the pair is hoisted OUT of the fixture and
; into this module, and `t4_codec.prog` is reduced to a caller by importing
; `protocol/style`. One definition of a comparison over library types, in lib/.
; A second copy is the duplicate-representation defect this element exists to
; retire, and writing one while retiring another is incoherent.
;
; THE COST, measured in this run. `t4_codec.prog` blobs to 67,441 bytes today. A
; probe root importing `prelude/prelude` and `protocol/grid` blobs to 65,132,
; and the same root with `protocol/render` added blobs to 103,939. So importing
; `protocol/style` charges the fixture about 38,807 bytes for `render.chiral`.
; It is a Phase 7 compile-only root, so that charge is compile time on one
; fixture and reaches no shipping program.
;
; WHY THIS MODULE AND NOT `grid.chiral`, WHICH IS WHERE `Attrs` LIVES. `attrs-eq`
; needs a Bool equality. `grid.chiral` imports `prelude/prelude`,
; `lowering/tal/bytes` and `ports/ports` (`:1-3`) and none of the three spells
; one; `bool-eq` is `render.chiral:202`, and `grid.chiral` importing
; `protocol/render` inverts the tier and charges `vt-parser.chiral` for it. The
; clean version is `bool-eq` moving to `lib/prelude/prelude.chiral` beside `not`
; (`:137`), and that file IS inside the compiler's blob: the blob built in this
; run carries `(def not (-> Bool Bool)` at its own line 137, so a def added
; there owes the fixpoint rebuild M3 licenses this element out of. §6 hands the
; prelude move to a follow-on and states its price.
;
; Equality is written out rather than borrowed from `cell->bytes`. The codec is
; injective over the colours parse-sgr can produce, so byte equality WOULD serve
; and it would put E111's codec on this element's blame chain, so a codec bug
; would redden a style row. Total case, arm per constructor, no `_`.
(def color-eq
  (lam (a b)
    (case a
      (color-default      (case b (color-default true) (_ false)))
      ((color-indexed i)  (case b ((color-indexed j) (=i i j)) (_ false)))
      ((color-rgb r g bl) (case b ((color-rgb r2 g2 b2)
                                    (and (=i r r2) (and (=i g g2) (=i bl b2))))
                                  (_ false))))))

(def attrs-eq
  (lam (x y)
    (case x
      ((attrs xb xu xi xr xk xs xf xg)
        (case y
          ((attrs yb yu yi yr yk ys yf yg)
            ; `bool-eq` is render.chiral:202 and this module imports it. The
            ; tree has no `beq`; `t4_codec.prog:15` spells its own `booleq`.
            (and (bool-eq xb yb) (and (bool-eq xu yu) (and (bool-eq xi yi)
            (and (bool-eq xr yr) (and (bool-eq xk yk) (and (bool-eq xs ys)
            (and (color-eq xf yf) (color-eq xg yg))))))))))))))

; THE DOMAIN, as a predicate. `Face`'s three I64 fields state none of this, so
; until they do (§6) the domain is a checked value rather than a type. The gate
; root below sweeps a RAW range wider than this predicate and asks the predicate
; which probes to assert, so the predicate decides the checked set and a mutant
; on its bound moves that set.
(def in-sgr-domain
  (lam (f)
    (case f
      ((face name fg bg attrs)
        (and (and (<=i -1 fg) (<=i fg 7))
        (and (and (<=i -1 bg) (<=i bg 7))
             (and (<=i 0 attrs) (<=i attrs 15))))))))

; THE LAW. The emitter already depends on this and states it nowhere:
; render.chiral:772 puts the INNER's delta (`face-sgr f`) and recurses with the
; JOINED face (`face-join amb f`). Those describe one terminal state only if
; this holds. At `outer = rnd-face-plain` it degenerates to the plain round
; trip, because `face-params rnd-face-plain` is nil and `face->attrs` of it is
; `blank-attrs`.
(def joins-agree
  (lam (outer inner)
    (attrs-eq (fold-sgr (face->attrs outer) (face-params inner))
              (face->attrs (face-join outer inner)))))

; ═══ 4. tools/test/samples/c1c2_round_trip.prog (NEW) — the root that RUNS

; M2: nothing under tools/test/samples/ reaches protocol/grid today, so the gate
; creates its own reach. Exits 42 on the whole product holding, which is the
; convention t4_codec and t4_grid already use (ledger.md:177).
(import "prelude/prelude")
(import "protocol/render")
(import "protocol/style")

(declare walk-bg    (-> Face I64 I64 I64 Bool))
(declare walk-fg    (-> Face I64 I64 Bool))
(declare walk-attrs (-> Face I64 Bool))
(declare walk-amb   (-> (List (Pair Str Face)) Bool))

; The inner sweep: 16 attribute masks x 19 fg x 19 bg, against one ambient.
; The colour axes run -1 to 17, PAST the domain, and `in-sgr-domain` decides
; which probe is asserted. A probe outside the domain is visited and skipped,
; which is what puts the predicate on the gate's critical path: widening its
; bound admits M1's three losses into the checked set. Structural recursion on
; a decreasing counter, so it is total.
(def walk-bg
  (lam (amb at fg bg)
    (case (<i bg -1)
      (true true)
      (false (let ((p (face "probe" fg bg at)))
               (and (case (in-sgr-domain p)
                      (true  (joins-agree amb p))
                      (false true))
                    (walk-bg amb at fg (- bg 1))))))))
; walk-fg and walk-attrs are the same shape one level out, starting at 17 and
; 15.  ; …

; Every ambient is a registry face, so the ambient axis is the real palette.
(def walk-amb
  (lam (reg)
    (case reg
      (nil true)
      ((cons h rest)
        (case h
          ((pair k v) (and (and (in-sgr-domain v) (walk-attrs v 15))
                           (walk-amb rest))))))))

(def compile-main (=> I64 I64)
  (lam (n)
    (case (walk-amb default-faces)
      (true  42)
      (false 1))))
```

- **Knobs to modify.** The domain bounds in `in-sgr-domain` are the one number
  a reuser changes, and the sweep follows them because the sweep asks the
  predicate: widening `fg` past 7 needs `parse-sgr` to grow the `38;5`
  and `38;2` forms, which is a different element.
  ⚑ The attribute axis is swept at its domain width, `0` to `15`, and the colour
  axes are swept wider. The reason is measured: `face-params` and `face-join`
  read bits `1`, `2`, `4` and `8` and nothing else, so an `attrs` of `16` to `31`
  behaves exactly as `attrs - 16` and a widened attribute bound admits probes
  that agree. That half of the predicate has no mutant that can redden it, and
  §6 records it as residue rather than sweeping 16 masks that prove nothing. The ambient axis is
  `default-faces` and swapping it for a root-supplied list is `display-calculus/C5`.
  The probe face's name is arbitrary because no SGR code carries a name.
- **Deliberately omitted.** A byte-level leg. The gate compares parameter lists,
  and `sgr-str` composed with `sgr-code` is the only thing between a param and
  its bytes; §6 states that limit and prices closing it through
  `lib/protocol/vt-parser.chiral`'s real CSI collector. A row asserting
  `face-sgr f == sgr-str (face-params f)`, which §6 drops with its reason: after
  the split that equation is the definition of `face-sgr`, so the row is a
  tautology and a tautology is the gate row `tools/test/face.sh` was written
  against. `sgr-blink` and `sgr-strike`, which no `Face` can reach.

## 6. Use / modify notes

- **Lands in.** `lib/protocol/grid.chiral` (two `cond` rows in `parse-sgr`),
  `lib/protocol/render.chiral` (`face-sgr` split into `face-params` and
  `sgr-str`, no signature change and no caller change),
  `lib/protocol/style.chiral` (new, roughly 120 L, carrying the hoisted
  `color-eq` and `attrs-eq`), `prog/scriba/samples/t4_codec.prog` (its own
  `color-eq`, `attrs-eq` and `booleq` deleted, `protocol/style` imported),
  `tools/test/samples/c1c2_round_trip.prog` (new), and one new gate script
  under `tools/test/` carrying a `# not-a-phase:` declaration. **Zero compiler
  changes**, and M3 is the measurement that licenses it: the blob built in this
  run is 812,351 bytes over 17,335 lines and spells `protocol/grid` zero times,
  `data Face` zero times and `bool-eq` zero times, so implementation is a plain
  `chirality run FILE`.
- **The new script declares itself out, and that is the whole registration
  story.** `tools/test/registration.sh` grades the directory against
  `run-tests.sh`'s dispatch table, and its G2 row fails any `tools/test/*.sh`
  that is neither dispatched by a `run_phase` line nor carries a
  `# not-a-phase: <reason>` header line. Measured in this run: 13 `run_phase`
  lines, 20 scripts, 7 of them `PEND`. So this element's script ships with the
  declaration and no number, and `registration.sh` G2 stays green because of it.
  The run then prints the script by name and reason under the heading that says
  these gates do not run. Five standing declarations were verified on disk in
  this run: `crypto.sh:6`, `tal-check.sh:11`, `apply-word.sh:5`,
  `mutant.sh:11`, `map-integrity.sh:7`.
- **The blame chain for a `parse-sgr` regression, stated.** `parse-sgr` and
  `fold-sgr` are reached by `t4_grid.prog:94`, `:112` and by
  `lib/protocol/vt-parser.chiral:253`, whose own importers are two
  `prog/scriba/samples/` roots. All of them stop at Phase 7, which compiles and
  runs nothing. E111's stated conformance is *"t4_codec/t4_grid native exit
  42"*, and neither root is executed by any phase, so **E111 has no running gate
  to re-run.** `t4_grid` folds codes `1` and `31` only (`:94`, `:112`), so the
  two new `cond` rows move no existing fixture's result either way.

  | if the round trip breaks after this edit | |
  |---|---|
  | which element owns it | **this one.** The two `cond` rows exist to satisfy this element's law, and this element's gate is the only thing in the tree that reads them |
  | what catches it | this element's own root, `c1c2_round_trip.prog`, through `joins-agree`. Deleting the `(=i code 3)` row is mutant 1 below and it disagrees on 7,128 of 14,256 asserted probes |
  | what does not catch it | E111's row, because nothing runs it. Phase 7, because it compiles. `tools/test/face.sh` Phase 16, because `parse-sgr` is on the decode side and Phase 16 grades emitted bytes |
  | the cost, stated plainly | the catcher is hand-run. Between this element landing and a `run_phase` line existing, a `parse-sgr` regression is caught by a person typing the script's name |

  The residue is bookkeeping rather than blame: whether E111's ledger row is
  reopened to carry the arm it already declares is an author call, and it is
  question 5 below.
- **The layering rule holds and is respected.** `lib/prelude/doc.chiral:13-16`
  states that `Doc` depends on nothing but `Str`, `List` and `I64`. Nothing here
  touches `Doc` or `d-tag`. `protocol/style` sits at the `protocol/` tier and
  imports two `protocol/` siblings, which is the tier the rule leaves free.
- **Conformance target.** `walk-amb` returns true over the whole sweep, giving
  exit 42. The sweep VISITS 11 ambients x 16 attribute masks x 19 `fg` x 19 `bg`
  = **63,536** probes and ASSERTS the ones `in-sgr-domain` admits, which under
  the shipping predicate is 11 x 16 x 9 x 9 = **14,256**. Three mutants, each
  reddening a different part, each with the count it moves. Every figure is
  arithmetic over the registry read in this run: `default-faces`
  (`render.chiral:148`) has eleven entries, `fg` in `{-1, 1, 2, 3, 4, 7}`, every
  `bg` `-1`, attribute masks `{0, 1, 2, 8}` with exactly one entry at `8`.

  | mutant | what it moves | disagreeing probes |
  |---|---|---|
  | 1. delete `((=i code 3) (sgr-italic true))` from `parse-sgr` | M1's italic loss returns. No registry ambient carries bit 4, so nothing masks it | **7,128** of 14,256, the half of the masks carrying bit 4 |
  | 2. widen `in-sgr-domain`'s colour bound to `(<=i fg 17)` | the asserted set grows to 11 x 16 x 19 x 9 = 30,096. `fg` 8 emits `38` and `fg` 9 emits `39`, both `sgr-other`; `fg` 10 through 17 emit `40` through `47`, which `parse-sgr:211` reads as a **background** | **15,840** newly asserted, every one of them |
  | 3. delete `(cons 7 l2)` from `face-params` | the reverse bit stops being emitted while `face-join`'s `bor` still sets it | **6,480**, and the shortfall from 7,128 is the point: `manas-cursor` is the one ambient whose own `attrs` is `8`, so on its slice the pen already carries reverse and the mutant is masked. The other ten ambients convict it |

  ⚑ **The fourth row this gate deliberately does not carry.** A row
  asserting `face-sgr f == sgr-str (face-params f)` cannot redden anything: after
  the split `face-sgr` IS `(sgr-str (face-params f))`, so the row is a tautology
  and a mutant on `face-params` moves both sides together. Writing a second
  emitter in the gate root to compare against would put a second copy of the
  byte rule in the tree, which is the defect this element retires. The property
  that row wanted is convicted by a gate that already runs: `tools/test/face.sh`
  is Phase 16, its G1 pins a pre-E175 golden cell map (`:292-303`, `:346`) and
  its G5 pins raw bytes (`:495`), both downstream of `face-sgr`. So a split that
  changed the emitted bytes reddens Phase 16, and this element's root is the
  wrong home for that check.
- **This element ships a hand-run gate. That is its price, stated up front.**
  The gate ends in an exit code from a compiled native binary. ⚑ **No
  suite phase executes it, and none will until the phase-number call is
  settled.** The two censuses that sweep roots without being told about them
  both stop short of `tools/test/`, measured in M2, so the script is the only
  reach and the script carries no number.

  The route is the standing precedent. Inventing a number would overwrite one
  of four documents that disagree. [[status-ledger]] records the precedent in
  its own words: `tools/test/tal-check.sh`
  *"carries no `run_phase` line, because 21 is owed to `tools/test/crypto.sh`
  and registering 22 ahead of it would open a numbered gap. It is run directly,
  so the suite total below excludes it."* Both scripts were verified on disk in
  this run: `crypto.sh:6` and `tal-check.sh:11` each carry a
  `# not-a-phase: <reason>` line, neither appears in the 13 `run_phase` lines,
  and `registration.sh` prints both as `PEND`. This element lands its script the
  same way. **So the element's conformance is a gate a person runs, it is not
  in the suite total, and any claim that C1 and C2 are covered by the suite is
  false until a number lands.** [[working-discipline]]'s reporting rule is the
  authority: say "done" only when a gate ran, and name the skipped work. The
  skipped work here is dispatch.

  It does not end in screen bytes, and that is what keeps
  `display-calculus/A1` from blocking it: `A1` is
  still owed (`lib/protocol/render-doc.chiral` has zero importers and `dg-doc`
  has no consumer outside `lib/typing/diag.chiral`), so a gate ending in a
  rendered screen would have nothing producing one. This gate's producer is
  `face-params` and its consumer is `fold-sgr`, both `->`, both reached by the
  root above.
- **Shard G's keyspace survives this element untouched.** `d-tag`'s field stays
  `Str` (`lib/prelude/doc.chiral:83`), so any string is still a face-registry
  key and no key is required to exist. Nothing here closes it, and
  [[banks/render]] §3 holds the three-armed fork that would.
- **The phase number is an open author call and this element does not pick
  one.** [[records/author-calls]] records four documents disagreeing about which
  suite number a new gate takes, with 8 through 12 owed to unported old-tree
  phases and 21 through 23 contested. The display tier's instance of that fork is
  recorded on the same row, and no competing row exists. The script runs by hand
  until the call is made, which is the disposition E185's SPEC run,
  `tools/test/crypto.sh` and `tools/test/tal-check.sh` already took.
- **Open questions.**
  1. **Does `Face`'s field carry the domain, and can the checker prove it.**
     `lib/runtime/proc.chiral:42-43` refines a constructor field today
     (`(refine I64 (>= 0) (< 256))`), so the pattern ships. The risk is the two
     computed constructions M5 found. The result `face-join` returns, built at
     `render.chiral:372`, computes `fg` from a `case` over `(<i ifg 0)` and
     `attrs` from `(bor oat iat)`,
     so the refinement engine would have to carry a bound through occurrence
     typing and through a bitwise `or`. If either fails, the domain stays a
     predicate. This is the follow-on row's first decision.
  2. **Which representation is retired, and when.** M1 settles that `Face` is the
     projection, so `Attrs` survives. Retiring `Face` reprices against M5's
     26 `(r-face` sites, 18 of them under `prog/scriba/`, and against the fact
     that `r-face` carries a `Str` rather than a `Face`, so most of the 26 may
     not move at all. That is a measurement the follow-on owes and this element
     does not take.
  3. **Whether the gate grows a byte-level leg.** `lib/protocol/vt-parser.chiral`
     already turns bytes into `act-sgr` parameter lists (`:35`, `:224`) and
     applies them (`:253`). Using it would close the `sgr-str` gap and would drag
     a `Pool` crossing into a gate that is otherwise pure.
  4. **Whether `SGR_AWK` retires.** M6 found a third SGR model in
     `tools/test/face.sh:176-223` that runs and disagrees with `apply-one` on
     unknown and off codes. `fold-sgr` is the typed version of exactly that
     reducer. Whether a chirality decoder replaces it belongs to
     [[arcs/enforcement-arc]]'s tooling-surface requirement.
  5. **Whether E111's ledger row is reopened.** The blame chain itself is
     settled above: this element owns a `parse-sgr` regression and its own root
     is the only thing that catches one. What stays open is bookkeeping.
     `docs/elements/ledger.md:177` records E111 `built` with its conformance
     given as *"t4_codec/t4_grid native exit 42"*, and no phase executes either
     root, so the row asserts a run that does not happen. Either this element's
     row absorbs `parse-sgr` outright, or E111's row is reopened to carry an arm
     it already declares and a conformance line it cannot deliver. A session
     cannot pick without editing a `built` row.
  6. **Whether `bool-eq` moves to the prelude.** ANSWERED for `color-eq` and
     `attrs-eq`: both hoist out of `prog/scriba/samples/t4_codec.prog:17-32` into
     `lib/protocol/style.chiral`, and the fixture becomes a caller. What stays
     open is the Bool equality underneath them. Three spellings exist today:
     `bool-eq` (`render.chiral:202`), `booleq` (`t4_codec.prog:15`) and `not`
     over a `case`. This element retires the second and leaves the first where
     it is, because `lib/prelude/prelude.chiral` is INSIDE the compiler's blob,
     measured in this run at line 137 of both the file and the blob, so moving
     `bool-eq` there owes the fixpoint rebuild [[working-discipline]]'s build
     rule states and M3 licenses this element out of. Moving it is a follow-on
     with a real price and a real payoff: `grid.chiral` could then hold equality
     beside `Attrs`, which is where it belongs.
     `tools/test/row.sh:729` censuses `render.chiral`'s names for exactly the
     duplicate-definition class and would catch a second `bool-eq`; it censuses
     no name in `grid.chiral` or `style.chiral`.
  7. **Whether `lib/protocol/style.chiral` carries a `(module …)` coordinate.**
     Zero of the eleven files under `lib/protocol/` do, against nine of nine
     under `lib/prelude/`. A new file is the cheapest moment to start, and
     starting alone leaves the other eleven silent.
- **Related:** [[C01-typed-style-value]] (superseded by this element),
  [[banks/render]] (shards C, D, G, H, L, and the missing shard M6 names),
  [[arcs/display-calculus-arc]] (rows C1, C2, and the A1/A2 preconditions),
  [[goals/display]], [[decisions/decision-work-ids]], [[working-discipline]],
  [[status-ledger]] (E111, E175, and the unregistered-script precedent),
  [[records/gate-audit]] (GA-25, the census claim M2 refutes),
  [[records/author-calls]] (the phase-number fork).
