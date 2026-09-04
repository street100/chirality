---
element: C1
slug: typed-style-value
title: A typed Style value, a closed Role sum, and a theme a root supplies
kind: primitive+law
reference_class: OURS/EXTERNAL
ours_source: lib/protocol/render.chiral, lib/prelude/doc.chiral
status: drafted
updated: 2026-09-04
---

# C01: A typed Style value, a closed Role sum, and a theme a root supplies

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** rows `display-calculus/C1`, `C2`, `C4`, `C5` (arc-local ids per
  [[decisions/decision-work-ids]], all `unminted`). C1 is a typed property
  value with invalid states unconstructible. C2 is the cascade as a total
  ordered fold with a stated law. C4 is the inherit sum, "no opinion" as a
  constructor rather than a sentinel. C5 is a theme as a value a root
  supplies. Following U13's precedent: what a style value **is** (C1), how it
  **resolves** (C2), what "no opinion" **means** (C4) and where the theme
  **lives** (C5) cannot be settled separately, because each answer constrains
  the other three. A `Style` type with no join law is unusable in C2's fold; a
  fold with no inherit constructor has nothing to fold `-1` into; a theme is
  meaningless until both the value it supplies and the fold it feeds are
  fixed.
- **Kind:** `primitive` for C1/C4/C5, `law` for C2, per the goal's kind column
  (`.planning/DISPLAY-LAYER-GAP.md` §3).
- **Why chirality needs its own:** the defect is measured against the tree as
  it stands today. Five parts of a style system already exist in `lib/protocol/render.chiral`
  and `lib/prelude/doc.chiral` and none carries a type: `Face` is four bare
  fields, the registry is a hardcoded assoc list with an application's
  palette mixed into a library module, attachment is an open `Str` keyspace,
  resolution has a silent miss, and the cascade is a description of emitter
  behavior with no stated law. §2 and §5 below work through each shard.
- **The witness.** The cell lane: the compiler's own diagnostics renderer
  (`lib/typing/diag.chiral`) and term pretty-printer (`lib/surface/pretty.chiral`),
  the two emitters that produce every `d-tag` the tree emits today. This is
  H1's cell half: the same style value driving both `Doc` output (via
  `d-tag`) and `Rendering` output (via `r-face`).
- **Not in scope:** any drawn surface, any pixel, layout, text metrics. Colour
  spaces (R1), gradients, blend modes and every other property vocabulary
  that has no cell-lane meaning (`.planning/DISPLAY-LAYER-GAP.md` §4). Row
  `C9` (the every-state gate, `tool`) and `H6` (its suite-phase
  instantiation) sit outside this run; **this element is what C9 gates**,
  once a `Style`/`Theme`/`Env`/`State` product exists for it to walk. C3
  (attachment without selectors) is adjacent and touched only where
  measurement 3 below needs it; settling C3 stays a separate row's job.

## 2. Research

- **Reference class:** `OURS/EXTERNAL`. OURS: `lib/protocol/render.chiral`
  (`Face`, the registry, `lookup-face`, `face-join`, `Rendering`),
  `lib/prelude/doc.chiral` (`Doc`, `d-tag`), `lib/protocol/render-doc.chiral`
  (the `Doc` to `Rendering` conversion), `lib/typing/diag.chiral` and
  `lib/surface/pretty.chiral` (the two emitters). EXTERNAL, for C5 and the
  attachment question: CSS custom properties (untyped strings, failing at
  the use site) and the W3C Design Tokens format, both cited in
  `.planning/DISPLAY-LAYER-GAP.md` §3.

**Load-bearing findings, measured 2026-09-04.**

1. **The coverage gap reproduces, with different exact counts than either the
   arc or the gap doc report line-for-line but the same shape.** `grep -rhoE
   '\(d-tag +"[a-zA-Z0-9_-]+"' lib/ prog/` (this tree has no `TUI/` directory
   today; the arc's "and TUI/" is stale) returns exactly seven names:
   `diag-head diag-site term-kw term-lit term-name term-qty term-var`. The
   registry (`default-faces`, `render.chiral:148-162`) has eleven:
   `default comment keyword string error manas-tag manas-field manas-header
   manas-ok manas-bad manas-cursor`. The two sets have zero overlap. Five
   registry entries reach no `r-face` consumer anywhere in `lib/` or `prog/`:
   `default`, `string`, `error`, `manas-tag`, `manas-cursor`. Both numbers
   (seven, eleven, zero overlap, five orphaned) match the arc and gap doc
   exactly; only the `TUI/` claim in their grep command is stale. The two
   emitters together carry **35** `d-tag` call sites over the seven names: 14
   in `lib/typing/diag.chiral`, 21 in `lib/surface/pretty.chiral`.
2. **`lib/protocol/render.chiral` is outside the compiler's blob;
   `lib/prelude/doc.chiral` is inside it, at exactly three importers.**
   `lib/protocol/render-doc.chiral:19-24` states this as a measured fact, not
   an assumption: *"the compiler blob contains two occurrences of the string
   `protocol/render`, both of them comments in `prelude/doc.chiral`"*, so
   `Face`, the registry, `lookup-face`, `face-join` and `Rendering` itself
   change under the ordinary `chirality run FILE` discipline
   ([[working-discipline]]), no BUILD RULE fixpoint. `Doc`/`d-tag` do not
   have that freedom: `grep -rl '"prelude/doc"' lib/ prog/` returns exactly
   `lib/typing/diag.chiral`, `lib/surface/pretty.chiral`,
   `lib/protocol/render-doc.chiral`, both of the first two in the compiler's
   closure. This is the asymmetry the hard constraint rests on, and it cuts
   the design in half: the *value* side (`Face`/registry/resolution/cascade)
   is free to redesign; the *attachment carrier* (`d-tag`'s field) is not.
3. **The cascade is already an ordered, incremental fold, and the order
   already lives in the value.** `render-doc.chiral:166`, the `d-tag` arm of `rdc-best`,
   accumulates open tag names outermost-first: `(append Str tg (cons n
   nil))`. `rdc-tree` (`render-doc.chiral:232-248`) peels that list one name
   at a time into nested `r-face` nodes, outer first. `render-to-ansi`'s
   `r-face` arm (`render.chiral:767-774`) resolves one face via `lookup-face`,
   emits its SGR delta, then recurses into the body with `(face-join amb f)`
   as the new ambient (`amb`): a genuine incremental fold over the ancestor
   chain, exactly the shape C2 asks for. Nothing here needs building. It
   needs typing.
4. **`prelude/doc.chiral`'s own header states the constraint that decides
   D3 for this element**, and it carries a layering argument alongside its
   cost argument. `lib/prelude/doc.chiral:12-14`: *"`Doc` depends on nothing but
   Str/List/I64 and is needed by `typing/` … by `protocol/` … and by
   `prog/`. That is 'the base shelf over the extern floor'."* Retyping
   `d-tag`'s field from `Str` to a `Role` defined in the style layer would
   force `prelude/doc.chiral` to import a `protocol/`-tier (or newer) type,
   breaking that deliberately-stated shelf property, independent of whatever
   the BUILD RULE fixpoint would cost. D3's "leave `Doc` alone" is argued
   twice over: once by cost, once by tier.

## 3. Conventional approach

Two conventional baselines apply, one external and one already in this tree.

**External, for C5.** A CSS custom property is an untyped string, checked
nowhere until the property that consumes it fails at use:

```css
:root { --brand-fg: 3; }              /* nothing here says this is a colour */
.term-kw { color: var(--brand-fg); }  /* fails silently on a bad token */
```

The W3C Design Tokens format (reached its first stable version 2025.10) is
the industry's answer: give a token a declared `$type`. It is still a spec
enforced by tooling that reads the file; no checker runs over the value
itself.

**In-tree, for C1/C2/C4, and this is the artifact under redesign.**
`render.chiral:37-38`:

```chirality
(data Face ()
  (face (name Str) (fg I64) (bg I64) (attrs I64)))
```

`render.chiral:148-162`, eleven hardcoded entries, six of them one
application's palette:

```chirality
(def default-faces (List (Pair Str Face))
  (cons (pair "default" (face "default" -1 -1 0))
  (cons (pair "comment" (face "comment" 2 -1 0))
  ; … eight more, including manas-tag / manas-field / manas-header /
  ; manas-ok / manas-bad / manas-cursor
  nil))))))))))))
```

`render.chiral:164-172`, resolution with a silent fabrication on miss:

```chirality
(def lookup-face
  (lam (reg name)
    (case reg
      (nil (face name -1 -1 0))   ; <- the miss. Nothing reports it.
      ((cons h rest)
        (case h
          ((pair k v)
            (case (str-eq k name) (true v) (false (lookup-face rest name)))))))))
```

`render.chiral:366-380`, the cascade, written as a description of what the
emitter already does:

```chirality
(def face-join
  (lam (outer inner)
    (case outer ((face oname ofg obg oat)
      (case inner ((face iname ifg ibg iat)
        (face iname
              (case (<i ifg 0) (true ofg) (false ifg))   ; -1 = "inherit"
              (case (<i ibg 0) (true obg) (false ibg))
              (bor oat iat))))))))                        ; attrs accumulate
```

- **Assumptions it bakes in:**
  - **A colour is a bare `I64`.** `-1` doubles as "no opinion" and as a
    value indistinguishable from a mistyped `-2`. Nothing marks the
    difference between an SGR index and a sentinel.
  - **A miss goes unreported.** `lookup-face`'s `nil` arm invents a face
    rather than naming the absence, so a compiler diagnostic that emits a
    tag no theme covers renders in the fabricated default and reports
    nothing.
  - **The registry is one list, shared by every consumer.** An application's
    palette (`manas-*`) sits in a library file six of eleven entries deep,
    so a program that imports `render.chiral` for `Rendering` alone also
    imports somebody else's colours.
  - **Attachment is an open string.** `d-tag`'s `name` field
    (`doc.chiral:83`) accepts any `Str`; a typo in an emit site produces a
    tag that silently never resolves, because nothing checks it against a
    closed set.
  - **The cascade's law is nowhere written down.** `face-join` is comment
    plus code; nothing asserts it is associative, and nothing would notice
    if a future edit made it stop being one.

## 4. The chirality idea

- **Chirality features in play:** a closed sum for what CSS spells as a
  which-of-N string (boundary sums, `docs/pattern-boundary-sums.md`); a
  generic wrapper sum for "no opinion" (`Maybe`'s shape, reused for a
  property rather than for absence-of-value); the compiler's exhaustiveness
  check over a closed sum, doing C5's coverage work for free; module tier as
  a load-bearing constraint (`prelude/doc.chiral`'s own stated shelf
  property, finding 4 above).
- **The reframing.** A `Role` is a closed sum, one constructor per semantic
  tag the tree actually emits, plus one constructor for "did not resolve" so
  that state is *named* rather than fabricated. A `Style` is a record of
  properties, each wrapped in a generic `Inherit`, so "no opinion" is
  `inherit` and never a sentinel value indistinguishable from real data. A
  `Theme` is a total function from `Role` rather than a list, so the
  compiler's own closed-sum coverage check already delivers C5's "an
  incomplete theme fails to compile", with no new machinery. The cascade is
  one fold, `style-join`, replacing `face-join`'s two different undeclared rules
  (override for colour, accumulate for attributes) with two named,
  independently statable laws.

### The three measurements

**1. Is the `(Env, State)` product finite and small.** Measured against the
two witnesses (`lib/typing/diag.chiral`, `lib/surface/pretty.chiral`): `grep`
for `Env`, `State`, `focus`, `hover`, `checked`, `active` across both files
returns zero. Tree-wide, `grep -rn "(data Env" lib/ prog/` returns exactly
one hit, `EnvR` at `lib/ports/clock.port:28`, naming the process
environment rather than a style axis; `(data State` returns nothing. Both witnesses are pure functions
over a fixed value (a `Reason`, a `Term`); neither reads a terminal
capability, a colour scheme, or an interaction state. **The reachable
product for this witness is 1: one environment, one state, because neither
axis is declared.** This is finite and small in the most literal sense, but
it does not exercise C9's every-state walk in any interesting way: a walk
over a singleton product proves the tool runs. Proving it convicts anything
needs a bigger product. C8 (state-driven style) and a meaningful instance of C9 need an
*interactive* consumer, which this witness structurally is not. That
consumer is out of this element's scope; naming it is the honest form of
this measurement rather than inventing an `Env`/`State` pair with no
producer to justify it.

**2. Does one style value drive both `Doc` and `Rendering`.** Read
literally, as one single value, no. Finding 2 and finding 4 above are why:
`d-tag`'s field stays `Str`, frozen by the layering argument, so `Doc` can
only ever carry a *projection* of a `Role`; the `Role` itself never reaches
it. What actually drives both ends is **one closed `Role` sum and one
total `role-name : (-> Role Str)`**: `Doc` carries `role-name`'s image, a
`Str` indistinguishable in the type from any other string; `Rendering`,
redesigned here (§5), carries the `Role` directly, because
`protocol/render` sits outside the compiler's closure and its field types
stay free. **The accurate claim is narrower than H1 as written: one closed
vocabulary drives both surfaces, projected as a bare string at the frozen
seam and carried typed everywhere the tree is free to type it.** This
finding sharpens a claim the arc states more strongly than the frozen half
of the tree can support; the design survives, and the sharpening belongs in
H1's wording.

**3. Does attachment for seven tags need a conflict rule.** No, for a
structural reason rather than a policy choice. Attachment here is never two
independent functions racing to match one node, the shape D2 warns against.
It is 35 call sites inside two ordinary printer functions, each choosing at
most one `d-tag` name for the node it is currently emitting, by direct
code rather than by a pattern matched against the node's shape. *Nesting*
is real (`diag.chiral:570` wraps `diag.chiral:577`'s `diag-site` calls) and
it is cascade rather than collision: `render-doc.chiral:166`'s ordered tag
list is exactly the ancestor chain C2's fold walks, one `Role` per level,
joined top-down. Two roles never compete for the same leaf; an ancestor
role and a descendant role compose, which is what `style-join` computes.
D2 (attachment by function, no specificity) survives this witness
unchanged, and this measurement leaves it in place.

- **What chirality makes impossible here:**
  - **A face that fabricates itself on a miss.** `rl-unknown` (§5) makes
    "this tag did not resolve" a named, themed constructor instead of a
    silently invented `(face name -1 -1 0)`. A theme must still supply a
    style for it, so the failure mode is visible on screen instead of
    absent from the report.
  - **A colour that is also a sentinel.** `-1` cannot occur as an `SgrColor`
    value; "no opinion" is the `Inherit` sum's own constructor, so a
    mistyped `-2` and a real "inherit" are no longer the same bit pattern.
  - **A theme silently missing a role.** `Theme` is `(-> Role Style)`; a
    `case` over `Role` that omits an arm is a compiler refusal, no longer a
    runtime miss. This is C5's "incomplete theme fails to compile" and H4's
    "coverage check the compiler already runs on a closed sum," the
    existing exhaustiveness pass with no check added.
  - **A shared library file smuggling one application's palette.** `manas-*`
    has no place in `Role` (§5's closed sum is the compiler's own seven
    tags); a `Theme` is a value a *root* supplies, so manas's palette moves
    to whatever module manas's own root already owns.

## 5. Chirality example (fleshed)

```chirality
; ══ lib/protocol/style.chiral — NEW. The typed value, the cascade, the theme. ══
(import "prelude/prelude")

; Not in the compiler's blob — protocol/render.chiral confirms this for its
; own siblings (render-doc.chiral:19-24) and style.chiral is the same tier.
(module protocol/style (cat A) (alt upper))

; C1: an SGR colour as a closed sum. -1 can no longer occur as a value; it
; is not a colour, it is Inherit's own constructor, below.
(data SgrColor ()
  (sgr-black) (sgr-red) (sgr-green) (sgr-yellow)
  (sgr-blue) (sgr-magenta) (sgr-cyan) (sgr-white))

; C1: what render.chiral's bitmask attrs field actually names, as fields.
(data Attrs ()
  (attrs (bold Bool) (underline Bool) (italic Bool) (reverse Bool)))

; C4: the wrapper sum. "No opinion" is a constructor, not a sentinel value
; hiding inside the property's own representation.
(data Inherit ((A (type 0)))
  (explicit (v A))
  (inherit))

; C1: the property record. Three fields — fg, bg, attrs — matching the three
; fields render.chiral's face-join actually reads (its fourth, name, carries
; no cascade meaning: "nothing reads it", render.chiral:364).
(data Style ()
  (style (fg (Inherit SgrColor)) (bg (Inherit SgrColor)) (attrs (Inherit Attrs))))

; C1: the closed role sum — the compiler's own seven emitted tags, plus the
; one new constructor requirement 3 needs: a resolution failure is a NAME,
; never a fabricated style. This sum stays in style.chiral, not doc.chiral —
; measurement 4 in §2 is why. An application's roles (manas-*) are NOT here;
; a root that wants them declares its own closed sum, per C1/E1's "closed
; sums split by context" idiom. Scoping THAT sum is not this element's job.
(data Role ()
  (rl-diag-head) (rl-diag-site)
  (rl-term-kw) (rl-term-lit) (rl-term-name) (rl-term-qty) (rl-term-var)
  (rl-unknown))               ; the miss, named instead of fabricated

; The canonical string each role prints as. Total, and it is the ONLY place
; the seven literal strings `diag.chiral`/`pretty.chiral` emit today are
; written down once. `d-tag`'s field stays Str (frozen); this is what an
; emit site would call if it adopted the typed constructor (§6, a follow-on,
; not required by this element).
(declare role-name (-> Role Str))
(def role-name
  (lam (r)
    (case r
      (rl-diag-head "diag-head") (rl-diag-site "diag-site")
      (rl-term-kw   "term-kw")   (rl-term-lit  "term-lit")
      (rl-term-name "term-name") (rl-term-qty  "term-qty")
      (rl-term-var  "term-var")  (rl-unknown   "unknown"))))

; The inverse, TOTAL rather than Maybe: a Str that names none of the seven
; resolves to rl-unknown rather than to an absence the caller must handle.
; This is the boundary where d-tag's open Str keyspace meets the closed
; Role sum — the one place openness survives, by construction, because
; d-tag's field cannot be retyped (§2 finding 2/4).
(declare role-of (-> Str Role))
(def role-of
  (lam (s)
    (cond ((str-eq s "diag-head") rl-diag-head)
          ((str-eq s "diag-site") rl-diag-site)
          ((str-eq s "term-kw")   rl-term-kw)
          ((str-eq s "term-lit")  rl-term-lit)
          ((str-eq s "term-name") rl-term-name)
          ((str-eq s "term-qty")  rl-term-qty)
          ((str-eq s "term-var")  rl-term-var)
          (else rl-unknown))))

; C2: the fold, as two named laws rather than one undeclared rule.
; color-join: override — the inner's stated opinion wins (render.chiral's
; existing -1-inherits behaviour, typed). Identity: inherit. Associative.
(def color-join (0 A (type 0)) (-> (Inherit A) (Inherit A) (Inherit A))
  (lam (outer inner)
    (case inner
      ((explicit v) (explicit v))
      (inherit      outer))))

; attrs-join: accumulate — render.chiral's existing bor behaviour, typed.
; Identity: inherit. Associative (component-wise or is).
(declare attrs-or (-> Attrs Attrs Attrs))   ; component-wise bor, mechanical; …
(def attrs-join (-> (Inherit Attrs) (Inherit Attrs) (Inherit Attrs))
  (lam (outer inner)
    (case outer
      (inherit inner)
      ((explicit oa)
        (case inner
          (inherit (explicit oa))
          ((explicit ia) (explicit (attrs-or oa ia))))))))

; C2: style-join is the total ordered fold — one step per ancestor, exactly
; the shape render-to-ansi's `amb` threading (render.chiral:767-774) already
; runs at each r-face node, now over a typed value with a stated law:
; style-join is associative and (style inherit inherit inherit) is its
; identity, because color-join and attrs-join both are.
(declare style-join (-> Style Style Style))
(def style-join
  (lam (outer inner)
    (case outer ((style ofg obg oat)
      (case inner ((style ifg ibg iat)
        (style (color-join SgrColor ofg ifg)
               (color-join SgrColor obg ibg)
               (attrs-join oat iat))))))))

; C5: a theme is a value a root supplies — a total function over the closed
; Role sum, so an incomplete theme is a compiler refusal (H4's coverage
; check, no new machinery). This module supplies NO default theme: that was
; render.chiral's defect (six of eleven registry rows one application's
; palette). Each root writes its own; the compiler's own is one candidate,
; sized to what diag.chiral/pretty.chiral actually emit.
(declare compiler-theme (-> Role Style))
(def compiler-theme
  (lam (r)
    (case r
      (rl-diag-head (style (explicit sgr-red)    inherit (explicit (attrs true false false false))))
      (rl-diag-site (style inherit                inherit inherit))
      (rl-term-kw   (style (explicit sgr-yellow)  inherit (explicit (attrs true false false false))))
      (rl-term-lit  (style (explicit sgr-cyan)    inherit inherit))
      (rl-term-name (style inherit                inherit inherit))
      (rl-term-qty  (style (explicit sgr-magenta) inherit inherit))
      (rl-term-var  (style inherit                inherit inherit))
      ; the failure mode is LOUD, not absent: reverse video marks an
      ; unresolved role instead of rendering as an invented default.
      (rl-unknown   (style inherit inherit (explicit (attrs false false false true)))))))
```

```chirality
; ══ lib/protocol/render.chiral — EDIT. Outside the compiler's blob (§2
; ══ finding 2), so this is an ordinary source change, no BUILD RULE fixpoint.
(import "protocol/style")   ; Role, Style, style-join, SgrColor, Attrs

; was: (r-face (face Str) (body Rendering))
(data Rendering ()
  ; … the other eight constructors, unchanged …
  (r-face   (role Role) (body Rendering)))

; Face, default-faces, lookup-face, face-join: RETIRED, superseded by
; protocol/style. No default registry ships from a library module — C5's
; whole point is that a theme is a value a root supplies, not a shared list.

; render-to-ansi's r-face arm, was render.chiral:767-774:
;   ((r-face face-name body)
;     (let ((f (lookup-face default-faces face-name))) …))
; becomes a THEME parameter threaded through the walk (one new argument,
; the shape render.chiral's `dims`/`amb` threading already has room for):
(declare render-to-ansi (-> Rendering (Pair I64 I64) (Maybe Rendering) I64 I64
                             I64 I64 Style (-> Role Style) Unit))
(def render-to-ansi
  (lam (node dims prev row col drow dcol amb theme)
    (case node
      ; … the other eight arms, unchanged except passing `theme` through …
      ((r-face role body)
        (case (rd-in-view dims row)
          (false unit)
          (true
            (let ((f (theme role)))                     ; TOTAL: no lookup-face nil arm
              (let ((_ (put (style-sgr f)))) ; style-sgr succeeds style-join's old face-sgr
                (let ((_ (render-to-ansi body dims none row col drow dcol
                                          (style-join amb f) theme)))
                  (put (style-sgr-reset amb)))))))))))
```

```chirality
; ══ lib/protocol/render-doc.chiral — EDIT. Also outside the compiler's
; ══ blob (render-doc.chiral:19-24 is the same file measuring its own
; ══ exclusion). The ONE place the frozen Str meets the closed Role sum.

; rdc-tree, was render-doc.chiral:248:
;   (cons (r-face t (r-row (rdc-tree grp))) (rdc-tree after))
; becomes:
(def rdc-tree
  (lam (segs)
    (case segs
      (nil nil)
      ((cons s rest)
        (case s
          ((rdcs tags txt)
            (case tags
              (nil (cons (r-text txt false) (rdc-tree rest)))
              ((cons t ts)
                (case (rdc-take t segs nil)
                  ((pair grp after)
                    (cons (r-face (role-of t) (r-row (rdc-tree grp)))   ; role-of is TOTAL
                          (rdc-tree after))))))))))))
; Nothing else in this file changes: `tg`'s accumulation (render-doc.chiral:166)
; is still a (List Str), because d-tag's own field is still Str — role-of is
; the one function standing at the frozen/typed boundary, and it is called
; exactly once per r-face constructed, never inside the walk itself.
```

- **Knobs to modify:**
  - **Whether `diag.chiral`/`pretty.chiral` adopt `role-name`.** Swapping
    the 35 literal `"diag-head"`-style strings for `(role-name rl-diag-head)`
    closes the typo risk at the emit site (a misspelled constructor name is
    a compiler error; a misspelled string literal is not) but is a real
    edit to two compiler modules and pays the ordinary BUILD RULE
    fixpoint: the routine cost any change to those files already owes and
    a smaller cost than retyping `Doc` itself would be. This stays a
    follow-on here; C1/C2/C4/C5 exist without it.
  - **`Attrs`' join rule.** `attrs-join` here preserves `face-join`'s
    accumulate-only behaviour (an ancestor's bold cannot be un-set by a
    descendant), matching the OURS baseline exactly. A per-field
    `(Inherit Bool)` × 4 design would let a descendant explicitly clear an
    attribute, a real capability gain over today's tree. That gain is a
    deliberately separate decision from this element's job of typing what
    already exists.
  - **`compiler-theme`'s actual colours.** Placeholder mappings; any root
    picks its own, and the coverage check is the same regardless of which
    `SgrColor` each role gets.
  - **`style-sgr` / `style-sgr-reset`.** Declared here and left unfleshed:
    total functions over `Style` replacing `face-sgr`/`rnd-restore`'s
    `Face` argument with `Style`, same shape, elided as mechanical
    (`; …`-class work, no shape decision left in it).

- **Deliberately omitted:**
  - **C3, attachment as its own law.** Measurement 3 shows this witness
    needs no conflict rule; formalizing "attachment is a pure function over
    the node" as its own checked property stays C3's row.
  - **C6/C7/C8/C9/C12** and every row outside this element's four. No value
    expression algebra, no declared `Env`, no state-driven style, no gate.
  - **`manas-*`'s new home.** Evicted from `render.chiral` by construction
    (no default registry ships). Where manas's own closed role sum lives
    stays manas's own root's decision.
  - **D9's staging.** CSS separates specified/computed/used/actual values
    because layout feeds back into style. The cell lane has no percentage
    and no `em`; nothing here surfaces that question. `B5` (intrinsic
    sizing, unopened) is the row that will.
  - **Any bitmap or glyph.** The cell lane has no font; the question does
    not arise.

## 6. Use / modify notes

- **Lands in:** `lib/protocol/style.chiral`, new: `SgrColor`, `Attrs`,
  `Inherit`, `Style`, `Role`, `role-name`, `role-of`, `color-join`,
  `attrs-join`, `style-join`, `compiler-theme`. `lib/protocol/render.chiral`,
  edit: `Rendering`'s `r-face` field, `render-to-ansi`'s theme threading;
  delete `Face`, `default-faces`, `lookup-face`, `face-join`.
  `lib/protocol/render-doc.chiral`, edit: `rdc-tree`'s one `r-face`
  construction site. `lib/typing/diag.chiral` and `lib/surface/pretty.chiral`
  untouched unless the `role-name` knob above is taken.
- **Conformance target:** the compiler's own diagnostics and the term
  pretty-printer render to the same screen bytes they do today under
  `compiler-theme`, because `compiler-theme`'s seven named-role colours are
  chosen to reproduce today's `lookup-face` misses (today, every one of the
  seven tags falls through to the fabricated `(face name -1 -1 0)`, i.e. no
  colour, no attrs, ambient bold/underline/italic all `false`). The
  observable screen output stays the same; what changes is that a theme
  omitting one of the eight `Role` arms is now a compiler refusal instead of
  a silent identical-looking miss. The falsifier: delete one arm from
  `compiler-theme`'s `case` and the module must fail to compile.
- **Open questions:**
  - **`style-sgr`'s behaviour at an `Inherit`-valued root.** `style-join`'s
    fold only terminates in fully-resolved values if the root ambient style
    (depth 0, today's `rnd-face-plain`) supplies `explicit` in every field.
    `Style`'s type does not enforce this; it is a stated invariant on
    whatever seeds the walk, the same kind of unenforced-but-stated
    invariant `face-join`'s comment already carries for `-1`. A refinement
    or a distinct `RootStyle` type, fields required `explicit` and no
    `Inherit`, would close it. That type stays unbuilt here.
  - **Whether `role-name`/`role-of` round-trip is asserted anywhere.**
    `role-name (role-of s)` is not `s` in general (any string outside the
    seven collapses through `rl-unknown` to `"unknown"`); `role-of
    (role-name r)` **is** `r` for every `Role` by construction (`role-of`'s
    `cond` and `role-name`'s `case` are written from the same seven
    literals). Worth a gate row when this element is specced.
  - **H1's wording**, per measurement 2: "the same style value driving both
    `Doc` and `Rendering`" reads as one value; the achievable claim is one
    closed vocabulary, projected as a bare string at the frozen `d-tag` seam
    and carried as the typed `Role` everywhere the tree is free to type it.
- **Related:** [[arcs/display-calculus-arc]] ·
  `.planning/DISPLAY-LAYER-GAP.md` · [[banks/text]] (shard H) ·
  [[pattern-boundary-sums]] · [[decisions/decision-work-ids]] ·
  U13 (the precedent for covering more than one row in one run) · N07 (the
  precedent for an arc-local pre-run).
