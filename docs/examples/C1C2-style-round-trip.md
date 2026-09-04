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

`parse-sgr` names **21** of the 51 codes: `0 1 4 7 22 24 27`, `30` through `37`,
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
header says *"Compile only (no run)"* and the loop ends at the compiler
(`tools/test/run-tests.sh:172-183`). Neither `t4_grid` nor `t5_vt_parser` is in
that phase's `KNOWN_FAIL` (`:173`), and both were compiled clean in this run.

**Zero roots under `tools/test/samples/` import `protocol/grid` or
`protocol/vt-parser`.** Six import `protocol/render` (`e158_doc`,
`e158_render`, `e174_row`, `e175_face`, `e181_pretty`, `e182_arity`). So the
half of this element's law that runs today is the emit half, and the decode half
is gated on compilation and on nothing else. **A round-trip gate must therefore
create the reach it needs**, which §5 does by landing a root under
`tools/test/samples/` and §6 prices as the element's own phase.

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
| `(face-sgr` call sites | **2**, both in `render.chiral` (`:396`, `:772`) | `grep -rn '(face-sgr' lib/ prog/ tools/` |
| `(face-join` call sites | **1**, `render.chiral:773` | the same, with `face-join` |
| `Face` constructions | **14**, every one in `render.chiral` | `grep -rn '(face ' lib/ prog/` |
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

It disagrees with `apply-one` on two classes. Its final arm is
`else { attr[v]=1 }`, so `ESC[22m` sets attribute 22 where `apply-one` clears
bold; and every unknown code becomes a set flag where `parse-sgr` returns
`sgr-other` and the fold ignores it. `face-sgr` emits neither class today, so the
gate stands correct where it is. It does mean the awk reducer cannot serve as
the oracle for this element's law without diverging from it.

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

; Equality is written out rather than borrowed from `cell->bytes`. The codec is
; injective over the colours parse-sgr can produce, so byte equality WOULD serve
; — and it would put E111's codec on this element's blame chain, so a codec bug
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
            (and (beq xb yb) (and (beq xu yu) (and (beq xi yi)
            (and (beq xr yr) (and (beq xk yk) (and (beq xs ys)
            (and (color-eq xf yf) (color-eq xg yg))))))))))))))

; THE DOMAIN, as a predicate. `Face`'s three I64 fields state none of this, so
; until they do (§6) the domain is a checked value rather than a type.
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

; The inner sweep: 16 attribute masks x 9 fg x 9 bg, against one ambient.
; Structural recursion on a decreasing counter, so it is total.
(def walk-bg
  (lam (amb at fg bg)
    (case (<i bg -1)
      (true true)
      (false (and (joins-agree amb (face "probe" fg bg at))
                  (walk-bg amb at fg (- bg 1)))))))
; walk-fg and walk-attrs are the same shape one level out.  ; …

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
  a reuser changes: widening `fg` past 7 needs `parse-sgr` to grow the `38;5`
  and `38;2` forms, which is a different element. The ambient axis is
  `default-faces` and swapping it for a root-supplied list is `display-calculus/C5`.
  The probe face's name is arbitrary because no SGR code carries a name.
- **Deliberately omitted.** A byte-level leg. The gate compares parameter lists,
  and `sgr-str` composed with `sgr-code` is the only thing between a param and
  its bytes; §6 states that limit and prices closing it through
  `lib/protocol/vt-parser.chiral`'s real CSI collector. The mutants (a gate row
  that nothing can redden is the failure `tools/test/face.sh` was written
  against). `sgr-blink` and `sgr-strike`, which no `Face` can reach.

## 6. Use / modify notes

- **Lands in.** `lib/protocol/grid.chiral` (two `cond` rows in `parse-sgr`),
  `lib/protocol/render.chiral` (`face-sgr` split into `face-params` and
  `sgr-str`, no signature change and no caller change),
  `lib/protocol/style.chiral` (new, roughly 90 L),
  `tools/test/samples/c1c2_round_trip.prog` (new), and one new phase script
  under `tools/test/`. **Zero compiler changes**, and M3 is the measurement that
  licenses it: both edited files are outside `prog/compiler.prog`'s blob, so
  implementation is a plain `chirality run FILE`.
- **The layering rule holds and is respected.** `lib/prelude/doc.chiral:13-16`
  states that `Doc` depends on nothing but `Str`, `List` and `I64`. Nothing here
  touches `Doc` or `d-tag`. `protocol/style` sits at the `protocol/` tier and
  imports two `protocol/` siblings, which is the tier the rule leaves free.
- **Conformance target.** `walk-amb` returns true over the full product, giving
  exit 42, and every one of M1's three losses reddens it when reintroduced:
  removing the `(=i code 3)` row from `parse-sgr` must fail the gate; widening
  `in-sgr-domain`'s `fg` bound to 17 must fail it; and reverting `face-sgr` to
  its own code list must fail whichever row checks `face-sgr` against
  `sgr-str (face-params f)`. Alongside that, `tools/test/face.sh` stays green:
  `face-sgr`'s output is byte-identical after the split by construction, and
  E175's cell maps are graded on those bytes.
- **What this element's gate ends in, and it runs.** An exit code from a
  compiled native binary, checked by a suite phase. It does not end in screen
  bytes, and that is what keeps `display-calculus/A1` from blocking it: `A1` is
  still owed (`lib/protocol/render-doc.chiral` has zero importers and `dg-doc`
  has no consumer outside `lib/typing/diag.chiral`), so a gate ending in a
  rendered screen would have nothing producing one. This gate's producer is
  `face-params` and its consumer is `fold-sgr`, both `->`, both reached by the
  root above.
- **Shard G's keyspace survives this element untouched.** `d-tag`'s field stays
  `Str` (`lib/prelude/doc.chiral:83`), so any string is still a face-registry
  key and no key is required to exist. Nothing here closes it, and
  [[banks/render]] §3 holds the three-armed fork that would.
- **The phase number is an open author call.** `records/author-calls.md:30`
  records four documents disagreeing about which suite number a new gate takes,
  with 8 through 12 owed to unported old-tree phases and 21 through 23 contested.
  This element's phase stays `UNASSIGNED` until that is settled, and its script
  runs by hand in the meantime, which is the disposition E185's SPEC run took.
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
  5. **Whether `lib/protocol/style.chiral` carries a `(module …)` coordinate.**
     Zero of the eleven files under `lib/protocol/` do, against nine of nine
     under `lib/prelude/`. A new file is the cheapest moment to start, and
     starting alone leaves the other eleven silent.
- **Related:** [[C01-typed-style-value]] (superseded by this element),
  [[banks/render]] (shards C, D, G, H, L, and the missing shard M6 names),
  [[arcs/display-calculus-arc]] (rows C1, C2, and the A1/A2 preconditions),
  [[goals/display]], [[decisions/decision-work-ids]], [[working-discipline]],
  [[status-ledger]] (E111 and E175).
