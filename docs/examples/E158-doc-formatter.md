---
element: E158
slug: doc-formatter
title: **`Doc` — structured formatting; printf's template split from its flatten**
kind: BUILD-PROPER
reference_class: OURS/PAPER
ours_source: (none)
status: drafted
updated: 2026-08-31
---

# E158 — **`Doc` — structured formatting; printf's template split from its flatten**

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the metis idea, ending in a clear-cut snippet to copy and modify.

> **⚑ Target tree.** E157 landed in **chirality** (`/workspace/chirality`), so
> E158 lands there too. §5/§6 use chirality's layout: the **extension is the
> kind** (`.chiral` module · `.prog` program · `.port` registry · `.profile`
> frozen port set · `.manifest` pure data), the **directory is the role**, and
> subject matter is neither — so there is no `stdlib/` and no `formatting/`.
> **Module keys are root-relative paths**: `(import "prelude/doc")`, never
> `(import "doc")`. Tests run `bin/chirality test`.

## 1. Scope

- **Element:** E158 — split a formatter into two halves that today are one:
  a **template** (what the structure *is*) and a **flatten** (how it becomes
  characters at a given width). The template becomes a closed sum, `Doc`; the
  flatten becomes a plural, explicit **choice** of exit — `doc->str` (width
  aware), `doc->rendering` (into scriba's display tree), `doc->json`.
- **Kind:** BUILD-PROPER. There is no Python to port; the reference is
  Wadler's algebra plus the strict-language reformulation, and the *defect* is
  measured in the tree.
- **Why metis needs its own:** because every formatter in the tree flattens at
  the construction site, and once flattened the structure is gone for good.
  Two measured instances:
  - `prog/manas/core/assemble.chiral:47-57` builds an LLM prompt — six named
    sections with provenance — as a nest of `str-cat` closing `))))))))))`.
    The sections exist in the author's head and nowhere in the value.
  - `lib/typing/pretty.chiral` (51 lines) is a `Term -> Str` printer that
    hardcodes `parens`/`sp` and produces characters at every step. It is
    imported by nobody.
  This is the same defect E157 removed one layer up. E157 widened the error
  *payload* from `Str` to a closed `Reason` carrying evidence; E158 widens the
  *rendering* from `Str` to a closed `Doc` carrying structure. `Doc`'s first
  consumer is E157's `Reason` — which is why it lands second, and why it is
  cheap: the evidence is already in the value, waiting for something that can
  lay it out.

## 2. Research

- **Reference class:** `PAPER` — Wadler, *A prettier printer* (1998), the
  algebra (`nil`/`text`/`line`/`nest`/`<>`/`group`) and its
  narrowest-first-line invariant; Lindig, *Strictly Pretty* (2000), the same
  algorithm for a **strict, non-lazy** language, which is what chirality is.
  Secondary `OURS`: `lib/typing/diag.chiral` (E157, 469 L), `lib/protocol/render.chiral`,
  `lib/typing/pretty.chiral`, `prog/manas/core/assemble.chiral`.

**Finding 1 — the algebra's whole content is one union, and the union is the
part you must not expose.** Wadler's `Doc` has a `<|>` alternative whose
correctness rests on an *invariant the type cannot state*: both branches must
flatten to the same text, and the left branch's first line must be no shorter.
Every published bug in a Wadler-family printer is a hand-built `<|>` that
breaks it. **Metis's move:** do not mint `d-union` at all. Mint `d-group`,
whose semantics *are* `union (flatten body) body` — so the only unions
expressible are the ones `group` makes, and the paper's side condition holds by
construction rather than by discipline. This is the boundary-sums directive
applied to an algebra rather than to a classification: close the sum so the
illegal state is unwritable.

**Finding 2 — Wadler's algorithm needs laziness; Lindig's does not, and
Lindig's is also the one that is obviously total.** The lazy version relies on
`best` producing a stream that `fits` consumes lazily. Lindig reformulates it
as an explicit **worklist of `(indent, mode, doc)` frames** with `mode ∈
{flat, break}`, plus a `fits` that walks the worklist prefix while the
remaining width stays `>= 0`. That form is directly writable in chirality: a
`(List Frame)` and structural recursion. Its **termination measure is the total
`Doc`-node count across the worklist**, which strictly decreases at every step
because each pop pushes only strict subterms: `d-cat` pops `1+|l|+|r|` and
pushes `|l|+|r|`; `d-nest`/`d-tag`/`d-group` pop `1+|b|` and push `|b|`;
`d-text` and `d-line` pop a leaf and push nothing. The `d-group` case is the
one worth checking twice, because it *looks* like re-examination: `fits`
re-walks the same subtree in flat mode. It is not the same worklist — `fits`
carries its own, and that one decreases by the same measure — so `doc-best`'s
measure is unaffected. No `while`, no fuel parameter, no unbounded loop.

⚑ **But the built checker cannot see this measure, and the example must not
imply otherwise** (measured 2026-08-31). `typing/totality.chiral` is E11, the
*single-function* classifier: its refusal names exactly two things it can see
— "structural (a case-bound field) or numeric (a parameter stepped toward a
constant bound a guard proves)" (`totality.chiral:387`), and its own header
scopes out mutual recursion. A node-count over a worklist that *grows* in the
`d-cat` case is neither, and `fits`↔`fits-frame` and `doc-best`↔`dc-line` are
both mutually recursive. That is **E50** — "Bidirectional/mutual termination +
lexicographic measures", catalog state **not built; totality gap**. So the
honest statement is: the measure is real and the functions terminate, but the
argument is *prose* here, not something the gate certifies. This costs nothing
at build time (enforcement is not on by default — `render.chiral`'s own
`diff-node`/`list-all-diff-same` are mutually recursive and ship), and it is
worth writing down because E158 is a natural first client for E50 rather than
evidence that E50 is already covered.

**Finding 3 — E157 already proves the payoff, from the other side.** `Reason`
carries real evidence and the plain-text exit throws most of it away, *visibly*:
- `r-usage` carries `(declared Qty) (observed Qty)`, and `dg-usage-msg`
  (`diag.chiral:349`) returns `"binder usage mismatch"` for nine of its
  twelve subjects (the other three say `"linear"` / `"let"` / `"field"` binder
  usage mismatch) — and **all twelve** drop both quantities, though `Qty` is
  `(q0)/(q1)/(qw)`, three values that would have fit in the sentence.
- `jg-tcon-arity` and `jg-ctor-arity` render as the two-word stubs `"tcon
  arity"` and `"constructor arity"`. The stub *is* the tell: the message is
  short because the numbers never reached it.
So the conformance target for `doc->str` is not "prettier text". It is
**evidence that survives to the output**, which no amount of `str-cat` polish
reaches.

**Finding 4 — `Rendering` is a screen tree, not a layout algebra, and the
directory tiers already forbid the merge.** `lib/protocol/render.chiral`'s
`Rendering` has eight constructors, and four of them carry *interaction state*:
`(r-section title collapsed body)`, `(r-stream source-id)` (names a live
source), `(r-tree children selected)`, `(r-hole label)`. Its consumers are `=>`
process functions (`render-to-ansi-full : (=> Rendering (Pair I64 I64) Unit)`)
plus a `Diff` for delta redraw. `Doc` has none of that and must not acquire it:
width is an *argument to the exit*, not a field of the value. The directory
tiers point the same way. ⚑ **Precisely what LAYOUT.md does and does not say**
(measured 2026-08-31, §Tiers, L62-67): it *labels* the tiers — `protocol` is
**universal**, `typing` is **language-implementation only** — and it states no
dependency rule. That a universal module may not depend on a lang-impl one is
an inference from what "universal" means, and the tree bears it out: `grep` for
`(import "typing/` under `protocol|ports|capability|runtime|memory|evidence`
returns **zero**, and for `(import "protocol/` under `typing|surface|module`
also **zero**. So the direction is unbroken in practice but unwritten in
LAYOUT; the conclusion holds on either reading, because `protocol/` and `prog/`
both need `Doc` and neither may reach into `typing/`. `Doc` therefore cannot
live in `typing/`, and `Rendering` cannot be the thing `typing/diag` returns.

## 3. Conventional (other-language) approach

C `printf` and its descendants fuse three jobs into one string: the *template*,
the *argument list*, and the *flatten*. Nothing downstream can recover any of
them.

```c
fprintf(stderr, "%s redeclared: %s\n", kindof(d), name(d));
/* wrap? indent? a second declaration site? a color for the name?
   all of it must be re-decided here, at every call site, forever. */
```

Python is the same shape with better ergonomics and one extra tell — the
wrapping is a *separate library operating on the flattened result*:

```python
msg = f"{kind} redeclared: {name}"          # structure destroyed here
print(textwrap.fill(msg, width=80))         # …and guessed at again here
```

And the tree's own instance, `prog/manas/core/assemble.chiral:47-57` — six
sections, real provenance, one expression:

```metis
(str-cat (str-cat sec-task    (str-cat lens "\n\n"))
(str-cat (str-cat sec-sees    (str-cat sees "\n\n"))
(str-cat (str-cat sec-doc     (str-cat doc  "\n\n"))
(str-cat (str-cat sec-extra   (str-cat (render-extra extra) "\n\n"))
(str-cat (str-cat sec-context (str-cat (str-join "\n" ctx) "\n\n"))
         (str-cat sec-return returns))))))
```

- **Assumptions it bakes in:**
  - **The output width is known at the call site.** It is not: the same
    diagnostic goes to an 80-column terminal, a scriba pane of unknown width, an
    LSP JSON payload, and a test assertion.
  - **One output medium.** `%s` can only become characters. A face, a fold, a
    clickable span, a JSON field — none are reachable.
  - **Re-wrapping a flattened string is safe.** For prose it is merely lossy;
    for *source text* (E146's `.manifest` round-trip) it is **incorrect** — a
    generic wrapper will happily break inside a string literal or a comment.
  - **Arity and types are the caller's problem.** `%d` against a `char*` is
    checkable only by an external lint that reparses the literal.

## 4. The metis idea

- **Metis features in play:** closed sums + coverage-checked `case` (the algebra
  and its invariant); the effect membrane (`->` throughout — a formatter that
  provably crosses no port); totality (Lindig's worklist has a node-count
  measure); the boundary-sums directive (a break kind is which-of-3, so it is a
  sum, not a flag); LAYOUT.md's kind/role split (where `Doc` and each exit
  live); the dependent fragment (§4, the printf question).

- **The reframing.** A formatter stops returning characters. `Doc` is the
  *record of the decision the author actually made* — "these are two sites, put
  them on separate lines if the width forces it, and tag the name so a renderer
  can face it" — and the flatten is a later, named, plural choice made by
  whoever knows the medium:

  | today | after E158 |
  |---|---|
  | `dg-msg : (-> Reason Str)` | **stays, unchanged, byte-identical** — the plain exit |
  | (nothing) | `dg-doc : (-> Reason Doc)` — the sibling |
  | (nothing) | `doc->str : (-> I64 Doc Str)` — flatten *at a width* |
  | (nothing) | `doc->rendering : (-> I64 Doc Rendering)` — `d-tag` → `r-face` |
  | (nothing) | `doc->json` — the tree, for a transport |

  The E157 header says it in one sentence: *"E158's `Doc` joins it as a sibling;
  it does not replace it."* That is a **test policy**, not politeness — see §6.

- **What metis makes impossible here:**
  - **An unsound union.** No `d-union` exists, so Wadler's side condition is not
    a rule anyone can break.
  - **A split token.** `d-text` is atomic and the renderer never subdivides it.
    A line appears **only where the producer wrote a `d-line`** — never at an
    arbitrary column, the way a word-wrapper works. This is the property E146's
    round-trip gate needs, and it is structural rather than tested.
  - **A formatter that quietly performs I/O.** Every signature here is `->`.
    Choosing a width is not a crossing; *writing the result* is, and it happens
    at a port the caller already holds.
  - **A stringly-typed break.** `"soft"` / `"hard"` / `0` / `1` as a break flag
    is which-of-N wearing a disguise; `Brk` is the sum.

## 5. Metis example (fleshed)

### 5a. `lib/prelude/doc.chiral` — the algebra and the first exit

```metis
; lib/prelude/doc.chiral — E158: the layout algebra.
; Pure (`->` throughout: a formatter provably crosses no port), total
; (structural, with an explicit measure), closed (a new node with no arm in
; doc-best is a compile error).
;
; WHY prelude/. LAYOUT.md: the extension is the kind, the directory is the ROLE.
; `Doc` depends on nothing but Str/List/I64 and is needed by `typing/` (the
; diagnostics renderer), by `protocol/` (the display exit) and by `prog/`
; (assemble). `prelude/` is "the base shelf over the extern floor" — that is
; the role. It is emphatically NOT a `formatting/` bucket: formatting is
; subject matter, and subject matter is neither the extension nor the directory.
(import "prelude/prelude")         ; Str, List, Bool, I64, str-cat, str-len
(import "prelude/list")            ; reverse — note the ERASED param: (reverse Str xs)
(import "prelude/string")          ; str-join
(module prelude/doc (cat A) (alt upper))   ; E161 datasheet coordinate

; ---- what a break BECOMES when its group fits on one line -------------------
; A break is which-of-three, so it is a sum and not a Str tag or an I64 flag
; (pattern-boundary-sums). `brk-hard` is the one that cannot flatten: `fits`
; returns false the moment it meets one, so a group containing a hard break
; always breaks.
(data Brk ()
  (brk-soft)       ; flat ⇒ ""      — a break point with no separator
  (brk-space)      ; flat ⇒ " "     — Wadler's LINE
  (brk-hard))      ; never flattens

; ---- the algebra ------------------------------------------------------------
; SIX constructors, and the one that is NOT here is the point: there is no
; `d-union`. Wadler's `<|>` carries a side condition (both branches flatten to
; the same text; the left's first line is no shorter) that the type cannot
; state, so every hand-built union is a latent bug. `d-group` IS
; `union (flatten body) body` — the only union anyone can write is the correct
; one. The invariant is pushed into the substrate, not documented beside it.
(data Doc ()
  (d-text  (s Str))                ; ATOMIC — never split. A token stays whole.
  (d-cat   (l Doc) (r Doc))        ; juxtaposition; (d-text "") is the unit
  (d-line  (b Brk))                ; the ONLY place a line may be introduced
  (d-nest  (i I64) (body Doc))     ; +i on the indent of every break inside
  (d-group (body Doc))             ; flat if it fits, broken otherwise
  (d-tag   (name Str) (body Doc))) ; a semantic role, zero width, zero text.
                                   ; `Str` here is a FACE-REGISTRY KEY — the
                                   ; open set protocol/render's `lookup-face`
                                   ; already indexes — not a which-of-N, so it
                                   ; is correctly not a sum.

; ---- the anti-str-cat helpers (what callers actually reach for) --------------
(declare doc-concat    (-> (List Doc) Doc))          ; d-cat over a list
(declare doc-punctuate (-> Doc (List Doc) Doc))      ; sep between, str-join's shape
(declare doc-words     (-> (List Str) Doc))          ; texts joined by brk-space
; … three folds, elided

; ---- the strict renderer (Lindig, Strictly Pretty, 2000) --------------------
; Wadler's version needs laziness. This one is an explicit worklist, which is
; what a strict, total language can actually run.
; MEASURE: the total Doc-node count across `fs` strictly decreases at every
; step — each pop pushes only strict subterms of the doc it popped. That is the
; totality argument for doc-best, dc-line and fits alike. No fuel parameter.
; ⚑ It is an ARGUMENT, not a certificate: E11's classifier sees only a
; case-bound field or a guarded numeric parameter, and these four functions are
; two mutually-recursive pairs over a worklist that grows. That is E50, NOT
; BUILT. Nothing breaks (totality is not enforced by default), but do not write
; "the checker proves it" in the spec.
; NOT `Mode`: `protocol/render.chiral:24` already defines a `Mode`, and names
; are FLAT in a blob — "two defs of one name is `duplicate label`"
; (module/resolve.chiral:57-61, which renamed `read-fd-all` for exactly this).
; `protocol/render-doc.chiral` below must import both modules, so the two would
; co-blob. `DMode` is the rename, taken here rather than discovered there.
(data DMode () (m-flat) (m-brk))
(data Frame () (fr (indent I64) (mode DMode) (doc Doc)))

; does the worklist reach its next break within `r` remaining columns?
(declare fits (-> I64 (List Frame) Bool))
(def fits
  (lam (r fs)
    (case (<i r 0)
      (true false)
      (false
        (case fs
          (nil true)
          ((cons f rest) (fits-frame r f rest)))))))

; d-text shrinks r · brk-soft costs 0 · brk-space costs 1 · brk-hard ⇒ false
; · d-cat/d-nest/d-group/d-tag descend in m-flat · a frame already in m-brk
; whose doc is a d-line ⇒ true (we reached the end of the line, so it fits).
(declare fits-frame (-> I64 Frame (List Frame) Bool))
; …

; the renderer proper. `acc` is the output in REVERSE (the corpus idiom: build
; reversed, flip once at the end).
(declare doc-best (-> I64 I64 (List Frame) (List Str) (List Str)))
(def doc-best
  (lam (w k fs acc)
    (case fs
      (nil acc)
      ((cons f rest)
        (case f
          ((fr i md d)
            (case d
              ((d-text s)   (doc-best w (+ k (str-len s)) rest (cons s acc)))
              ((d-cat l r)  (doc-best w k (cons (fr i md l) (cons (fr i md r) rest)) acc))
              ((d-nest j b) (doc-best w k (cons (fr (+ i j) md b) rest) acc))
              ((d-tag n b)  (doc-best w k (cons (fr i md b) rest) acc))  ; zero width
              ((d-line b)   (dc-line w k i md b rest acc))
              ; THE ONE DECISION POINT IN THE WHOLE ELEMENT.
              ((d-group b)
                (case (fits (- w k) (cons (fr i (m-flat) b) rest))
                  (true  (doc-best w k (cons (fr i (m-flat) b) rest) acc))
                  (false (doc-best w k (cons (fr i (m-brk)  b) rest) acc)))))))))))

; a break resolves by (mode, kind). Broken ⇒ newline + the frame's own indent.
; The (m-flat, brk-hard) arm is unreachable in practice — `fits` refuses to
; flatten a group containing a hard break — but it is WRITTEN, and it breaks,
; because a total function does not get to halt on "can't happen".
(declare dc-line (-> I64 I64 I64 DMode Brk (List Frame) (List Str) (List Str)))
(def dc-line
  (lam (w k i md b rest acc)
    (case md
      ((m-flat)
        (case b
          ((brk-soft)  (doc-best w k rest acc))
          ((brk-space) (doc-best w (+ k 1) rest (cons " " acc)))
          ((brk-hard)  (doc-best w i rest (cons (nl-indent i) acc)))))
      ((m-brk) (doc-best w i rest (cons (nl-indent i) acc))))))

(declare nl-indent (-> I64 Str))   ; "\n" + i spaces
; …

; ---- EXIT 1 of 3: characters, at a width the CALLER chose -------------------
(declare doc->str (-> I64 Doc Str))
(def doc->str
  (lam (w d)
    (str-join "" (reverse Str (doc-best w 0 (cons (fr 0 (m-brk) d) nil) nil)))))
```

### 5b. `lib/typing/diag.chiral` — the consumer: E157's `Reason`, laid out

```metis
; ADDED to the existing diag.chiral, beside dg-msg — not replacing it.
(import "prelude/doc")

; The SIBLING of dg-msg. Same ACCESSOR-FUNCTION PATTERN the file already
; mandates: one `case` on Reason as the DIRECT body of a lam, callers construct
; and never match (the nested-case "unknown name" compiler bug).
;
; Note what is absent: not one `str-cat` in this function. That is the element.
(declare dg-doc (-> Reason Doc))
(def dg-doc
  (lam (r)
    (case r
      ; the arm dg-msg structurally cannot serve: BOTH declarations are in hand,
      ; and a Doc can put them on their own indented lines instead of choosing
      ; one and discarding the other.
      ((r-redeclared w i nw)
        (d-group
          (d-cat
            (d-tag "diag-head"
              (doc-concat (cons (d-text (dg-subject-tag w))
                          (cons (d-text " redeclared: ")
                          (cons (d-text (dg-subject-name w)) nil)))))
            (d-nest 2
              (doc-punctuate (d-line (brk-space))
                (cons (d-tag "diag-site" (dg-decl-doc "declared" i))
                (cons (d-tag "diag-site" (dg-decl-doc "and"      nw)) nil)))))))

      ; and the arm that measures the win: dg-usage-msg answers nine of its
      ; twelve subjects with the same three words ("binder usage mismatch"), and
      ; drops BOTH quantities in all twelve. Qty is (q0)/(q1)/(qw) — three
      ; values, and they fit.
      ((r-usage w dq oq)
        (d-group
          (d-cat (d-tag "diag-head" (d-text (dg-usage-msg w)))
                 (d-nest 2 (doc-concat
                   (cons (d-line (brk-space))
                   (cons (d-text "declared ") (cons (d-text (dg-qty-name dq))
                   (cons (d-line (brk-space))
                   (cons (d-text "used ")     (cons (d-text (dg-qty-name oq)) nil)))))))))))

      ; … the seven remaining arms: r-mismatch nests two show-term Docs,
      ;   r-skipped folds E97's chain one frame per line, r-relayed tags its
      ;   origin, and the four leaf arms are a d-text over the existing
      ;   dg-*-msg accessor.
      )))
```

- **Knobs to modify:**
  - **`Brk`'s arity.** Three is the minimum that covers soft/space/hard. A
    fourth (`brk-hard-blank`, a blank line that survives flattening) is a
    one-arm addition and the coverage checker will name every site.
  - **`d-tag`'s payload.** `Str` (a face-registry key) today. If a *closed*
    role set ever appears — `diag-head`/`diag-site`/`diag-evidence` and nothing
    else — that is the moment it becomes a sum, and the registry becomes the
    mapping from the sum, not from a string.
  - **The output accumulator.** `(List Str)` + `str-join ""` is O(n²) in
    `str-cat` for a large document. A `Bytes` builder is the drop-in swap and
    changes no signature above `doc->str`.
  - **`doc-best`'s accumulator type** is the knob that buys exit 2: carry
    `(Pair (List Str) (List Str))` — output plus a **tag stack** — and the same
    walk emits `Rendering` segments instead of raw text (§6).

- **Deliberately omitted:**
  - `d-align`/`d-fill`/`d-column` (Leijen's extensions). Nothing in the tree
    needs them, and each is additive later.
  - `doc->json`. Named as an exit, but nothing consumes it today; building an
    unconsumed exit is exactly the "built but unadopted" trap this repo has
    logged four times. It is one `case` over six constructors when a consumer
    appears.
  - Repointing `typing/pretty.chiral` — see §6, it is a bigger job than the
    handoff says.
  - Any dependent-printf machinery — §6, open question 3.

## 6. Use / modify notes

- **Lands in** (chirality — `.chiral`, root-relative keys, `bin/chirality test`):
  | file | what | why there |
  |---|---|---|
  | **`lib/prelude/doc.chiral`** *(new)* | `Brk`, `Doc`, `DMode`, `Frame`, `fits`, `doc-best`, `doc->str`, the concat helpers | the base shelf: pure, depends only on Str/List, needed by three tiers |
  | **`lib/typing/diag.chiral`** *(edit, +~70 L)* | `dg-doc`, `dg-decl-doc`, `dg-qty-name` | the accessor-function rule keeps every `case` on `Reason` in this file; `typing` may import `prelude` |
  | **`lib/protocol/render-doc.chiral`** *(new)* | `doc->rendering : (-> I64 Doc Rendering)` | keeps the arrow `prelude ← protocol`. `protocol` is **universal**, `typing` is **lang-impl-only**, so this must never live in `typing/` |
  | **`tools/test/samples/e158_doc.prog`** + a `tools/test/doc.sh` | the gate | mirrors E157's `e157_diag.prog` shape |
  | **`tools/test/run-tests.sh`** *(edit, 1 line)* | `run_phase 14 "layout algebra (E158 Doc)" doc.sh` | ⚑ measured: gates are phase-registered (`run-tests.sh:131-187`, E157 is `run_phase 13 … diag.sh`). An unregistered `doc.sh` is a gate that never runs |

  ⚑ **`Doc` does not go in `typing/`, and `Rendering` is not extended.** Both
  follow from LAYOUT.md's tiers, not from taste — see §2 finding 4.

- **Conformance target** — three laws, none of them "the text looks nicer":
  1. **Flat law.** `doc->str <huge-width> d` equals the same document with every
     `d-line` replaced by its `Brk`'s flat text. This is the property that makes
     `d-group` sound, and it is directly testable.
  2. **Width independence (the one E146 needs).** For every width `w`, the
     *token sequence* of `doc->str w d` is identical; only line breaks and
     leading indent differ. Structural, because `d-text` is atomic and breaks
     occur only at `d-line`. Test it by asserting E146's round-trip
     `parse (doc->str w (config->doc v)) ≡ v` at **three** widths — `1`, `40`,
     `1000000` — rather than at one. (This widens *E146's* gate, not E158's; it
     is the same author decision as the signature change above, and it lands
     when E146 does.)
  3. **Evidence survival.** For each of `Reason`'s nine arms, `doc->str 80
     (dg-doc r)` **contains** every field the arm carries. `r-redeclared` names
     both declarations; `r-usage` names both quantities. This is the gate that
     `dg-msg` provably fails, which is why it is the right one.

  **Test policy, stated so it cannot drift** — and stated against what
  `tools/test/doc.sh`'s sibling actually asserts, not against a paraphrase.
  `tools/test/diag.sh` (Phase 13) is careful *not* to call byte-identity its
  gate: its own header says a fixture that compares only strings "passes with
  the evidence dropped — which is the state the element exists to end", so the
  rows that count are G1's evidence rows and G2's seven named mutants. But
  byte-identity is nonetheless **pinned**, by G3's nine goldens comparing the
  compiler's stderr with `[ "$got" = "$2" ]` and by mutant M4
  (`reword-the-let-message`, one byte, must convict). So the accurate statement
  is: *preserving the strings is a live constraint E157 carries and its goldens
  enforce, and it is what made a per-message `Judg` the cheap way out at 38
  arms.* **`doc->str` must not inherit that constraint.** `dg-msg` keeps its
  existing goldens unchanged — nothing here touches them, and nothing here can,
  since `doc->str` does not exist for them to assert on. `dg-doc` is graded by
  law 3 only. If the two are ever cross-asserted, `Doc` re-imports the
  constraint it exists to lift.

- **On E157's `Judg` residue (38 nullary arms, one per *message*, which the
  element's own taxonomy line forbade):** `Doc` is **orthogonal to the cause and
  a lever on the cure — and it is a mild hazard if used carelessly.**
  - *Orthogonal to the cause:* `Judg` is large because a string-preserving
    constraint met a `Reason` that carried only a `Subject`. `Doc` changes what
    a renderer can do with evidence, not what evidence a call site has. Adding
    `Doc` shrinks `Judg` by zero arms.
  - *A lever on the cure:* the shrink is a `Reason` change, and `Doc` is what
    makes it worth making. Three arms — `jg-tcon-arity`, `jg-ctor-arity`,
    `jg-ctor-arg-arity` — have integers at their sites and none of them reach
    the message. Two are bare two-word stubs, `"tcon arity"` /
    `"constructor arity"` (`diag.chiral:428-429`); the third is
    `(str-cat n " wrong number of arguments")` (`:450`) — a sentence that names
    the constructor and still not the numbers. One evidence-shaped arm,
    `(r-arity (what Subject) (expected I64) (actual I64))`, retires all three
    and turns three stubs into a real message *that a `Doc` can lay out*. Same
    move for `r-usage`, which already carries the evidence `dg-usage-msg`
    throws away. That is the taxonomy rule being honoured late rather than
    abandoned.
  - *The hazard:* per-message layout is cheap under `Doc`, which makes adding a
    39th nullary `Judg` arm feel free. It is not — it is the same error, now
    with better typography. The guard is the test policy above: grade by
    evidence survival, and a nullary arm has no evidence to survive.
  - This is **not** deferred to an element number. It is a scoped follow-on
    inside E157's own file that E158 makes worth doing; if it is to be tracked,
    it belongs on the E157 row, not on a new one.

- **On `.manifest` / `.protocol`** — what `Doc` owes each, corrected against
  the tree:
  - **`.manifest` (E163 form + E146 value→source + E158 `Doc`)**: `Doc` owes it
    exactly **law 2, width independence**. E146's stated gate is
    `parse(source(v)) ≡ v`; inserting a formatter under it is only safe if
    layout cannot change meaning. A generic wrapper breaks that (it will split a
    string literal); `Doc` cannot, because breaks occur only where the producer
    put a `d-line` and `d-text` is atomic. So the honest contract is: **E146
    emits `config->doc : (-> Config Doc)` (and `pipeline->doc`, and one per
    type — E146's catalog row names five emitters, not one), rather than
    `config->source : (-> Config Str)`**, with `config->source w = doc->str w .
    config->doc` kept as the convenience wrapper so nothing above E146 changes.
    ⚑ **This is a proposal about a DIFFERENT element, and E158's example is not
    the place it takes effect.** E146's catalog row today reads
    `config->source : (-> Config Str)` / `pipeline->source : (-> Pipeline Str)`
    (`docs/elements/catalog.md:411`) and has no example and no SPEC,
    so nothing is being contradicted — but the row is the authority, and this
    example cannot edit it. Naming the change here is the point of running E158
    first; **making** it is an author decision on the E146 row.
  - **`.protocol`**: `Doc` owes it **nothing**, and the brief's symmetry is
    misleading. HANDOFF.md's own line — *"`.manifest` round-trips against metis
    source, `.protocol` against bytes"* — is the reason: bytes have no layout
    freedom, so there is nothing for a layout algebra to decide. `.protocol` is
    also **not yet an extension**: LAYOUT.md lists five (`.chiral`/`.prog`/
    `.port`/`.profile`/`.manifest`) and HANDOFF says `.protocol` still needs
    minting.

- **Open questions** (named, not deferred — none of these has an element number
  and none should be invented for it):
  1. **`fits`'s lookahead bound.** Lindig's `fits` walks the *rest of the
     worklist*, not just the group. Chirality's `Doc`s are small (a diagnostic,
     a manifest), so the honest first cut is the full walk with the node-count
     measure; whether a deep `d-cat` spine ever makes it quadratic is a
     measurement to take after the first real consumer, not a design to
     pre-optimise.
  2. **`doc->rendering`'s tag spans.** A `d-tag` that survives a break covers
     *parts of two output lines*, and `Rendering`'s `r-face` wraps a whole node.
     So `doc->rendering` cannot be `doc->str` plus a wrapper — it must re-run
     `doc-best` with a tag stack in the accumulator and emit one `r-face` per
     segment per line. **First commit ships the naive version** (one `r-face`
     around the whole `r-lines`), which is correct for the single-tag diagnostic
     case and visibly wrong for nested tags. Say so in the commit rather than
     shipping it silently.
  3. **Does a dependently-typed printf ride on top?** *Not in E158, and here is
     what was actually checked.* The Cayenne/Idris shape needs a **type-level
     function** — `FmtTy : (-> (List Spec) (type 0))` computing an arity- and
     type-indexed result — and `lib/typing/reflect-floor.chiral` shows only
     *declared* type constants (`(declare Former (type 0))`), not a `def` whose
     body computes a type by recursion. So whether chirality's NbE elaborator
     supports it is **an open fact about the checker, not a design choice**, and
     E158 must not assume it. Two further notes: (a) the two are **orthogonal** —
     a dependent printf checks the *argument* side (arity/type), `Doc` fixes the
     *result* side (structure), and they compose without either needing the
     other; (b) the metis-native version should not be format-*string* driven at
     all — the format is a `(List Spec)` **value** over a closed `Spec` sum,
     which is the boundary-sums directive, and it removes the "reparse the
     literal" problem that makes C's version need an external lint. If this is
     wanted, it needs its own catalog row minted first.
  4. **What actually happens to `typing/pretty.chiral`** — and the handoff
     understates this. Two measured corrections: it renders **5 of 11** formers,
     not 6 of 11 (`t-type`/`t-var`/`t-lam`/`t-app`/`t-let`; its own comment
     names Pi/TCon/Con/Refine/Case/Global as the missing six). More
     importantly it **declares its own local 5-constructor `Term`**, which is
     *not* `surface/syntax.chiral`'s `Term` — that one has **16** constructors,
     `t-lam` carries no name (de Bruijn), and `t-let` carries a `Qty`. So
     "make it `Term -> Doc`" is not a signature change: the module must first be
     repointed at the real `Term` and grown eleven arms, and its
     `names-snoc`/`nth-name` scaffolding is the only part that survives. That is
     a second commit at least, and it should not be smuggled into E158's gate.
  5. **Does `assemble-prompt` migrate in this element?** It is the loudest
     instance and the *least* load-bearing consumer (an LLM prompt has no width
     constraint). Recommend: **no** — it converts once `Doc` is proven on
     `Reason`, so it is a follow-on commit in `prog/`, not part of the algebra's
     gate.

- **Related** (slugs checked against `examples/` and `docs/`, 2026-08-31; the
  four that resolve are linked, the rest are named because no note exists yet
  and this run may not mint one):
  [[E157-typed-diagnostics]] (built — supplies the `Reason` this renders, and
  the `Judg` residue §6 takes a position on) ·
  [[E97-skip-chain-diagnostics]] (the accessor-function pattern and the blame
  chain `r-skipped` joins) ·
  [[E161-kind-identifier]] (the `(module …)` coordinate the new file carries) ·
  [[pattern-boundary-sums]] ·
  **E146** *(no note — catalog row only)*: its gate becomes
  width-parameterised and its signature should become `config->doc` ·
  **E163** *(no note — catalog row only)*: the `.manifest` form ·
  **U16 "the block algebra"** *(not a note — `.planning/USER-LAYER-TRACKER.md:92`,
  status `blocked`, dependency `E158`)*: the user layer's blocked consumer

---

## Author decisions on the audit's FLAGs (2026-08-31)

**FLAG A — E146's signature: ACCEPTED, and ENACTED ON E146's ROW, not here.**
E158 owns the **law** (width independence: identical token sequence at every
width). E146 owns the **consequence** (its five emitters return `Doc`, gate at
widths 1 / 40 / 10⁶). The amendment is written into
`docs/elements/catalog.md`'s E146 row in the same change that landed
this file — because a decision about E146 recorded only inside E158's example is
invisible to whoever implements E146. Per-type siblings, not one generic
`v->doc`: that row names five emitters and a single generic under-specifies them.
`config->source w = doc->str w . config->doc` stays as a thin wrapper, so no
existing caller breaks.

**FLAG B — the `Judg` arity residue: MINTED as E182.** The example was right to
refuse a phantom dep, but wrong that E157's row is a home: **E157 is DONE, and a
completed element's row is a record, not a worklist.** Parking it there tracks
nothing, which is the same "it evaporates if it isn't written where it lives"
failure that made E157's own two bonus finds into decision rows before dispatch.
`E182 — the arity judgments carry their arity` now has a catalog row and a ledger
row. It is not E158's work and does not gate this element.

**FLAG C — a knowingly-wrong `doc->rendering`: REFUSED. It stays in E158 and it
ships CORRECT.** The proposal was to ship the naive whole-node `r-face` first,
"visibly wrong for nested tags", disclosed in the commit message. Rejected: this
repo has **four logged "built but unadopted" findings**, and a wrong artifact is
worse than an unbuilt one — unadopted code is inert, whereas a renderer that is
plausibly right and quietly wrong is one someone adopts. The artifact itself
cites that record when deferring `doc->json`, so shipping wrong here contradicts
its own reasoning. The fix is small and bounded — a stack of face names threaded
through the render walk, popped at each `d-tag` close — so this is scoped IN
rather than deferred, and no new row is minted for it. **`doc->rendering` is
correct for nested tags or it does not land.**
