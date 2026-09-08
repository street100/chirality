---
element: E174
slug: r-row-width
title: **`Rendering` gains horizontal composition (`r-row`) and the per-node width function it needs** — so one line can hold more than one segment.
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none — `lib/protocol/render.chiral` is the baseline)
status: drafted
updated: 2026-08-31
---

# E174 — **`Rendering` gains horizontal composition (`r-row`) and the per-node width function it needs**

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E174 — add **one** constructor, `(r-row (children (List Rendering)))`,
  to the closed `Rendering` sum, and build the thing it cannot exist without: a
  **per-node width function** that says how far `col` must advance past a child.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** because `Rendering` is a *medium-independent*
  value that a renderer places on a grid. Nothing off the shelf computes widths of
  *this* sum, and the two shortcuts a conventional stack would take — width from
  ambient font/terminal state, or presentation bytes smuggled inside the text —
  are both refused here on standing decisions (§4).

**⚑ The constructor is the easy half. The width function is the element.**
`r-row` is one arm and about six lines of emitter. Laying children left-to-right
requires knowing each child's rendered width, and **`Rendering` has never computed
one** — 492 lines, 25 `declare`s, not one of them a measure. Everything hard about
E174 is in §5's `rnd-cols`, and everything contentious about it is that

> **`rnd-cols` is not a property of the value. It is a *contract with*
> `render-to-ansi`.** Every constant in the width function is a constant in the
> emitter, and if the two ever disagree, `r-row` silently overwrites its own
> sibling.

That is a bolted-on invariant across a function boundary, which PRINCIPLES §5 flags
by name. §5's answer is to make the shared constants *one named def with two
readers* rather than two literals that must be kept in sync — which is more of the
real work than the new arm is.

**Explicitly NOT in scope:** nested `r-face` failing to restore the outer face.
`ansi-reset` is `\e[0m` (`render.chiral:282`), a full reset, so an inner tag's
close clears the outer one. That is **E175**, already minted (`LEDGER.md:294`).
The two are orthogonal *and §5 shows why*: a face emits SGR bytes, SGR bytes
occupy **zero columns**, so `rnd-cols`'s `r-face` arm is the identity and no
E175 fix changes a single width. See §6 for the one place they do meet.

## 2. Research

- **Reference class:** `OURS`. There is no Python baseline for this — `render.chiral`
  was written natively. The reference is the module itself, its live consumers, and
  the measure protocols of two TUI toolkits (§3).

**Key findings — all measured in this tree on 2026-08-31, several correcting the
catalog row.**

1. **The catalog's blast-radius figure is wrong, and the truth is more
   interesting.** `docs/elements/catalog.md:438` says *"12 files case
   over it"*. Measured: **17 files import `protocol/render`** (that figure is
   right), **13 files name a `Rendering` constructor**, but only **five actually
   `case` over the sum** —

   | file | how it matches | breaks on a 9th arm? |
   |---|---|---|
   | `lib/protocol/render.chiral` | `diff-node` (:223) and `render-to-ansi` (:424), both 8-arm exhaustive | **yes, twice** |
   | `lib/protocol/apc.chiral` | `enc` (:89) 6 arms, no `_`; `block-id` (:127) 2 arms **+ `_`** | **already broken — see finding 2** |
   | `prog/scriba/scriba-runview-test.prog` | 3 cases, every one ending `(_ …)` | no |
   | `prog/scriba/scriba-runview-stream-test.prog` | same 3 cases | no |
   | `prog/scriba/samples/t6_apc_roundtrip.prog` | constructs throughout, **and** cases once at `:82` — `(case r ((r-stream sid) …) (_ -4))` | no |

   The other eight files (`chat-view`, `command-loop`, `flook`, `flow-view`,
   `init-loader`, `manas-mode`, `manas-runview`, `render-str`)
   **only construct**. Construction is unaffected by a new arm. So the real cost is
   **two exhaustive cases in one file**, plus the pre-existing breakage below —
   not twelve.

   *(Audit correction, 2026-08-31: the draft put `t6_apc_roundtrip` in the
   only-construct bucket and counted four casing files. It cases once, at `:82`,
   through a `(_ -4)` default — so the count is five and the conclusion is
   unchanged.)*

2. **⚑ The tree already carries an un-updated case over `Rendering`, and it
   already fails the coverage check.** Measured, one command:

   ```
   $ ./bin/chirality check prog/scriba/samples/t6_apc_roundtrip.prog
   chirality check: prog/scriba/samples/t6_apc_roundtrip.prog FAILED (exit 1)
   load: non-exhaustive case
   ```

   `apc.chiral:89` declares `enc : (-> Rendering Str)` (`:41`) and matches
   `r-text`/`r-table`/`r-section`/`r-stream`/`r-tree`/`r-hole` — **six of eight,
   with no default arm.** `r-lines` and `r-face` were added to the sum after the
   APC codec was written and the codec was never updated. Two controls confirm the
   diagnosis is specific: `scriba-runview-test.prog` and `scriba-test-b1.prog` both
   import `protocol/render` and both `check` **OK**.

   **The check runs on a module directly, which is the cleaner gate** (audit
   addition, 2026-08-31 — the sample only reaches `enc` through its import DAG):

   ```
   $ ./bin/chirality check lib/protocol/apc.chiral
   chirality check: lib/protocol/apc.chiral FAILED (exit 1)
   load: non-exhaustive case
   $ ./bin/chirality check lib/protocol/render.chiral
   chirality check: lib/protocol/render.chiral OK
   ```

   `render.chiral` itself is green — the sum's own two exhaustive cases are up to
   date; it is only the codec that lagged.

   **And the red reaches a second sample.** `lib/protocol/vt-parser.chiral:4`
   imports `protocol/apc`, so `prog/scriba/samples/t5_vt_parser.prog` fails with
   the identical `load: non-exhaustive case`. Measured across
   `prog/scriba/samples/`: seven of nine `check` OK, `t6_apc_roundtrip` and
   `t5_vt_parser` fail on non-exhaustive case, and `t5_utf8` fails on an
   unrelated `load: unknown name Unit`. **Not isolated:** `vt-parser.chiral` has
   40 `case`s and one `_`, so whether it *also* carries a non-exhaustive case of
   its own — and therefore whether it goes green on the `enc` fix alone — was not
   determined. Treat `lib/protocol/apc.chiral` as the gate and `t5_vt_parser` as
   a bonus to be re-measured, not promised.

   This is the single most useful fact in the pre-run, and it cuts both ways:
   - **the closed sum works.** Coverage *is* enforced (`kernel.chiral:1319`
     `jg-nonexhaustive`, via `all-covered?`), the compile error *is* real, and the
     cost of adding an arm *is* knowable — the catalog's claim is sound in
     mechanism even though its count is wrong.
   - **and the previous constructor addition shipped anyway**, leaving a red
     module in the tree — and, through `vt-parser`, a second red sample nobody
     traced back to it. "It will be a compile error" is only a cost control if
     someone is compiling that file. E174 must therefore either fix `enc` or state
     in writing that it leaves it red — §6 takes the first.

3. **The forcing consumer is confirmed, and it is one arm deep.** `dg-doc`
   (`lib/typing/diag.chiral:510`) — E158's `(-> Reason Doc)` — has this shape in its
   very first arm, `r-redeclared` (`:516-528`):

   ```chirality
   (d-group (d-cat (d-tag "diag-head" …head text…)
                   (d-nest 2 (… (d-line (brk-space)) (d-tag "diag-site" …) …))))
   ```

   `d-group` renders **flat when it fits** (`doc.chiral`, Lindig), and flat mode
   turns `(d-line (brk-space))` into a single space (`doc-best` `:140`, its `brk-space` arm at `:169`). So at any
   width where the group fits, `diag-head`'s tagged span, a space, and
   `diag-site`'s tagged span land on **one output line**. `d-tag`→`r-face`
   (`LEDGER.md:283`), and `r-face` is a wrapper that emits no `ansi-goto` of its
   own (`:469`), so there is no `Rendering` value that means "these three segments,
   side by side". Not awkward — **absent**. `doc.chiral:179-183` already says so in
   the source, naming E174 and E175 as the blockers under `doc->rendering`.

4. **`Rendering` already places horizontally in exactly two spots, and they
   disagree with each other.** `rnd-emit-headers` advances `(+ c (+ (str-len h) 2))`
   — content-derived, 2-column gutter (`:360`). `rnd-emit-one-row` advances
   `(+ col 16)` — a hardcoded grid, content ignored (`:368`). **The same `r-table`
   therefore has two different column layouts depending on which row you measure**,
   and a header wider than 14 columns overruns its own cell. This is a live defect
   E174 *surfaces* and does not fix (§6, open question 2), and it is the reason
   `r-table`'s width answer is awkward (§5).

5. **`utf8` in this tree is a decoder only — there is no width function anywhere.**
   `lib/protocol/utf8.chiral` gives `utf8-decode1 : (-> Bytes I64 (Pair I64 I64))`
   and `decode-utf8 : (-> Bytes (List I64))`, both pure, RFC-3629 well-formed, with
   U+FFFD resync. `grep -i width` over the file returns **one** hit, and it is a
   comment at `:15` naming *"the T4 wide-cell width computation"* as a **future**
   consumer of the primitive. So: codepoints are available today, display cells are
   not. It imports only `prelude/prelude`, so `protocol/render` → `protocol/utf8`
   is acyclic and cheap.

6. **Byte-length-as-column is already the tree's incumbent answer, and already
   documented as wrong.** `str-len` is a raw extern `(-> Str I64)`
   (`prelude/prelude.chiral:78`) over a byte string. `rnd-emit-headers` uses it as a
   column advance; so does `str-pad` (`prelude/string.chiral:209`), which
   `doc.chiral`'s `nl-indent` builds indentation from. And `cursor-row-col`
   (`render.chiral`) carries a **KNOWN LIMITATION (do not half-fix)** comment saying
   in as many words that it *"counts raw characters, not terminal columns"*.
   The live proof is inside `render.chiral` itself: the `r-stream` arm draws
   `" — live stream]"` (`:459`), whose em-dash is U+2014 — **17 bytes, 15 display
   columns.** The module's own placeholder is a counterexample to its own
   arithmetic.

7. **Prior art splits on who computes the width, and both answers cost something.**
   Python's `rich` *derives* it: every renderable implements
   `__rich_measure__(console, options) -> Measurement(minimum, maximum)`, and
   `rich.cells.cell_len` does the East-Asian-width job over a table. Rust's
   `ratatui` *refuses* to derive it: `Layout` takes caller-supplied
   `Constraint::Length/Min/Percentage` and a widget is never asked how wide it is.
   The Wadler/Lindig lineage (which `doc.chiral` already implements) gets to skip
   the question entirely — a `Doc` is text with no placement, so its width is a
   fold over string lengths. **`Rendering` is the hard case precisely because it
   places.**

8. **⚑ Added at the example audit, 2026-08-31 — `render-section` never issues an
   `ansi-goto`, so one constructor ignores `col` outright.** Every other drawing
   arm opens with `(put (ansi-goto row col))` — `r-text` (`:439`), `r-stream`
   (`:455`), `r-hole` (`:465`), and each table header (`:356`). `render-section`
   (`:383-392`) opens with `(put ansi-bold)` and then `(put title)`: **the title
   lands wherever the previous `put` left the cursor.** It reaches the right place
   today only because a section is in practice the first thing drawn on its row.

   This is the same class of defect as finding 4 and it bites E174 harder: it is
   not that `rnd-cols`'s `r-section` answer is the wrong *number* — the number is
   derivable and §5 derives it — but that an `r-section` placed as a **non-first
   child of an `r-row`** will draw at the ambient cursor no matter what number the
   width function returns. `render-row` advancing `col` correctly is not enough
   when the callee never reads `col`. So §6's gate 4 ("widths agree with the
   emitter") is **unsatisfiable for `r-section` as the tree stands**, and gate 3
   must be read as covering the arms that do honour `col`. Disposition is §6 open
   question 7.

## 3. Conventional (other-language) approach

The `rich` shape — a per-node virtual method, on an open hierarchy:

```python
# rich/measure.py (shape, not verbatim)
@dataclass
class Measurement:
    minimum: int          # narrowest it can render without truncation
    maximum: int          # widest it would like

class Panel:
    def __rich_measure__(self, console, options) -> Measurement:
        inner = Measurement.get(console, options, self.renderable)
        return Measurement(inner.minimum + 2, inner.maximum + 2)   # borders

# rich/cells.py — the width question, answered separately and correctly
def cell_len(text: str) -> int:        # sums per-codepoint East-Asian width
    ...
```

and the `ratatui` shape, which declines the question:

```rust
let cols = Layout::default()
    .direction(Direction::Horizontal)
    .constraints([Constraint::Length(10), Constraint::Min(0)])   // CALLER says
    .split(area);
```

- **Assumptions they bake in:**
  - **`rich`: width is dynamic dispatch on an open set.** A new renderable that
    forgets `__rich_measure__` inherits a default and is silently mismeasured — no
    tool tells you. That is the failure mode a closed sum plus a coverage check
    converts into a compile error (finding 2 proves the check is live here).
  - **`rich`: width is a *pair*, not a number.** `minimum`/`maximum` exists because
    once a renderable may wrap, one number cannot describe it. E174 answering a
    single `I64` is a real narrowing and §5 states its precondition explicitly.
  - **`ratatui`: the caller supplies the width.** Cheap and always consistent, but
    it moves the arithmetic to every call site — the `(+ col 16)` disease at
    `:368`, already measured in-tree as producing two layouts for one value.
  - **Both: width comes from ambient state** — a `Console`, a terminal `area`.
    Here the measure must be pure `->` over the value alone (§4).
  - **The CSS/inline-style analog** is option (B) from the E158 spec: put the
    presentation *inside* the text. Refused here, see §4.

## 4. The chirality idea

- **Chirality features in play:** closed sums with enforced coverage · the
  `->`/`=>` effect membrane · boundary-sums (a `Str` never carries which-of-N) ·
  PRINCIPLES §5 (push the invariant into the substrate rather than across a
  function seam) · `Doc`/`Rendering` kept as two types on purpose.

**The reframing.**

1. **The measure is pure, and that is the whole reason it can exist.**
   `rnd-cols : (-> Rendering I64)` takes no `Console`, no `dims`, no terminal
   query — it is arithmetic on a value. Placement stays on the pure side of the
   membrane; only emission (`render-to-ansi`, `=>`) crosses. `rich` cannot do this
   because its measure needs a `Console` for the encoding.

2. **`r-row` is bare juxtaposition. No implicit separator. This is a decision.**
   The two existing horizontal placers both bake a spacing constant in — `+2` at
   `:360`, `+16` at `:368` — and finding 4 is what that costs. A combinator with a
   baked-in gap cannot express "no gap" (which is exactly what a `d-cat` of two
   tagged spans needs), while a caller who *wants* a gap writes one more child:
   `(r-text " " false)`. One constructor, one meaning.

3. **Faces have width zero, so E174 and E175 do not interact in the arithmetic.**
   SGR bytes are not printed cells. `rnd-cols`'s `r-face` arm is `(rnd-cols body)`,
   and it stays that way whether the renderer resets (today) or restores (E175).
   The two elements share a file and nothing else.

4. **What chirality makes impossible here** — and these are the settled calls
   E174 *records* rather than re-opens, both already on the catalog row (`:438`):
   - **SGR escapes inside `r-text`'s `Str` are REFUSED.** A `Str` carrying
     which-of-N presentation structure is the precise flattening defect E157 and
     E158 exist to remove, and it would make `Rendering` unsafe to re-render to any
     non-ANSI medium — including `apc.chiral`'s codec, which transports the value
     itself. Closed on the standing boundary-sums directive.
   - **Restricting `doc->rendering` to single-segment lines is measured dead** — it
     fails on E158's own first consumer (finding 3). An exit `dg-doc` cannot use is
     not an exit.
   Horizontal composition wins **by elimination**, not by preference. Nothing below
   re-argues it.

## 5. Chirality example (fleshed)

A patch against `lib/protocol/render.chiral` (which imports only `prelude/prelude`
and `ports/ports`, and carries **no** `(module …)` datasheet line — adding one is
E161 adoption and out of scope here). Mechanical recursion is elided with `; …`;
what is written out is what a later run must get *right*, not what it must type.

```chirality
(import "prelude/prelude")
(import "ports/ports")
(import "protocol/utf8")        ; NEW — decode-utf8, for str-cols. Acyclic:
                                ; utf8.chiral imports prelude only.

; ─── the sum gains ONE arm ────────────────────────────────────────────────
; r-row: children laid left-to-right on the SAME row, each starting where the
; previous one ended. No implicit separator (§4.2) — a gap is (r-text " " false).
(data Rendering ()
  (r-text   (content Str) (bold Bool))
  (r-table  (headers (List Str)) (rows (List (List Rendering))))
  (r-section (title Str) (collapsed Bool) (body Rendering))
  (r-stream (source-id Str))
  (r-tree   (children (List Rendering)) (selected Rendering))
  (r-lines  (children (List Rendering)))
  (r-hole   (label Str))
  (r-face   (face Str) (body Rendering))
  (r-row    (children (List Rendering))))          ; ← the new arm

; ─── the shared constants: ONE name, TWO readers ──────────────────────────
; These are the E174 substance. Each was a bare literal inside an emitter; the
; width function needs the SAME number, and two literals that must agree is the
; bolted-on invariant PRINCIPLES §5 refuses. Naming them makes rnd-cols and
; render-to-ansi read one definition instead of agreeing by luck.
(def rnd-tree-indent    I64 2)      ; render-tree      :401  (+ col 2)
(def rnd-section-indent I64 2)      ; render-section   :392  (+ col 2)
(def rnd-table-cell     I64 16)     ; rnd-emit-one-row :368  (+ col 16)
(def rnd-header-gutter  I64 2)      ; rnd-emit-headers :360  (+ (str-len h) 2)
(def rnd-collapsed-mark Str " [+]") ; render-section   :387
(def rnd-hole-mark      Str "<?>")  ; the r-hole arm   :466
(def rnd-stream-open    Str "[")    ; the r-stream arm :457
(def rnd-stream-close   Str " — live stream]")      ; :459 — 17 BYTES, 15 COLUMNS

; ─── str-cols: the ONE place the width unit is decided ────────────────────
; The unit is TERMINAL COLUMNS, and the name says so, because a later wcwidth
; landing must be a body change and not a re-audit of every call site. This is
; the E176 lesson applied ahead of the defect: the property lives in a named
; function, not in a comment beside 131 uses of a raw extern.
;
; Codepoints, not bytes: (str-len s) is a byte count (prelude:75) and the module's
; own " — live stream]" is the counterexample (17 vs 15). Codepoints are RIGHT for
; the accented case and STILL WRONG for CJK/emoji (2 cells) and combining marks
; (0 cells) — see §6 open question 1. That residue is named, not papered over.
(declare str-cols (-> Str I64))
(declare cp-count (-> (List I64) I64 I64))
(def str-cols (lam (s) (cp-count (decode-utf8 (str->bytes s)) 0)))
(def cp-count (lam (cps acc) (case cps (nil acc) ((cons c t) (cp-count t (+ acc 1))))))

; ─── rnd-cols: the element ────────────────────────────────────────────────
; What it answers: how far `col` must advance so the NEXT sibling in an r-row
; does not overwrite this child. An ADVANCE width, not an extent.
;
; PRECONDITION, stated because §3 shows why one number is not obviously enough:
; a single I64 is honest here ONLY because no Rendering constructor wraps. rich
; returns (minimum, maximum) for exactly the case chirality does not have. If a
; wrapping constructor ever lands, this signature is wrong, not just imprecise.
;
; NO `_` ARM. A tenth constructor must break this function, which is the whole
; reason the cost of a ninth was knowable (finding 2).
(declare rnd-cols     (-> Rendering I64))
(declare rnd-cols-sum (-> (List Rendering) I64 I64))   ; r-row:   fold with +
(declare rnd-cols-max (-> (List Rendering) I64 I64))   ; stacks:  fold with max
(declare rnd-hdr-cols (-> (List Str) I64 I64))         ; headers: content + gutter
(declare rnd-row-cells (-> (List (List Rendering)) I64 I64))  ; widest row's COUNT

(def rnd-cols
  (lam (node)
    (case node
      ; ── DERIVED, exactly: the emitter draws content and stops (:435).
      ; `bold` costs SGR bytes and ZERO columns — which is also why E175 changes
      ; no width anywhere in this function.
      ((r-text content bold) (str-cols content))

      ; ── DERIVED: a face is a wrapper that emits no ansi-goto (:469).
      ((r-face face-name body) (rnd-cols body))

      ; ── DERIVED: the new arm. Sum, because children abut (§4.2).
      ((r-row children) (rnd-cols-sum children 0))

      ; ── DERIVED, but MAX not sum: a vertical stack's advance is its widest row
      ; (render-lines steps `row`, holds `col`, :409). See §6 open question 3 —
      ; the number is settled, what an r-row DOES with a multi-row child is not.
      ((r-lines children) (rnd-cols-max children 0))

      ; ── DERIVED: render-tree draws each child at (+ col rnd-tree-indent) (:401).
      ; The constant is READ, not repeated — that is the point of the defs above.
      ((r-tree children selected) (+ rnd-tree-indent (rnd-cols-max children 0)))

      ; ── DERIVED, and `collapsed` is genuinely load-bearing (:383-392).
      ; ⚑ The NUMBER is derivable; the PLACEMENT is not honoured — render-section
      ; issues no ansi-goto (finding 8), so an r-section that is not the first
      ; child of an r-row draws its title at the ambient cursor whatever this
      ; returns. §6 open question 7.
      ;   collapsed -> title + " [+]" and the body is NOT DRAWN AT ALL;
      ;   open      -> the head, or the body indented by 2, whichever is wider.
      ((r-section title collapsed body)
        (case collapsed
          (true  (+ (str-cols title) (str-cols rnd-collapsed-mark)))
          (false (max (str-cols title)
                      (+ rnd-section-indent (rnd-cols body))))))

      ; ── DERIVED FROM A PLACEHOLDER + ONE DEFINITION. A source-id is not its
      ; content, and the content is not present in the value. But the emitter
      ; today draws a fixed placeholder (:451-460), so THAT is derivable — and
      ; the DECISION is that a stream RESERVES NOTHING for content it does not
      ; hold. A future streaming renderer that draws real content in place makes
      ; this underivable again and would need a declared reservation FIELD on the
      ; constructor. §6 open question 4. (Note rnd-stream-close is the module's
      ; own bytes-vs-columns counterexample — 17 bytes, 15 columns.)
      ((r-stream source-id)
        (+ (str-cols rnd-stream-open)
           (+ (str-cols source-id) (str-cols rnd-stream-close))))

      ; ── DERIVED: the arm draws "<?>" then the label (:461-468). (Its third
      ; `put` is (put "") — dead, and left alone: deleting it is not E174.)
      ((r-hole label) (+ (str-cols rnd-hole-mark) (str-cols label)))

      ; ── ⚑ DEFINED, NOT DERIVED — and the ONLY arm where that is forced by a
      ; DEFECT rather than by missing information. The emitter lays headers by
      ; CONTENT (:360) and body cells on a FIXED GRID (:368): one value, two
      ; layouts. The grid is what a body cell actually obeys, so the grid is the
      ; answer, and `headers` is the half that is already wrong on screen for any
      ; header wider than 14 columns. Recorded as a pre-existing defect E174
      ; surfaces and does NOT fix (§6 open question 2) — not silently averaged.
      ((r-table headers rows)
        (max (rnd-hdr-cols headers 0)
             (* rnd-table-cell (rnd-row-cells rows 0)))))))

(def rnd-cols-sum (lam (xs acc) (case xs (nil acc) ((cons h t) (rnd-cols-sum t (+ acc (rnd-cols h)))))))
(def rnd-cols-max (lam (xs acc) (case xs (nil acc) ((cons h t) (rnd-cols-max t (max acc (rnd-cols h)))))))
; … rnd-hdr-cols folds (str-cols h) for every header plus rnd-header-gutter
;   BETWEEN them — n-1 gutters, not n. The emitter advances c by (str-len h)+2
;   after each header INCLUDING the last (:360), but that final advance is
;   consumed by the nil case and nothing is ever drawn in it, so the last column
;   the header row touches is (Σ lengths) + 2(n-1). Folding n gutters would bake
;   a two-column trailing separator into a width function whose own §4.2 decision
;   is that r-row has NO implicit separator. (Corrected at the example audit.)
;   rnd-row-cells folds max over each row's LENGTH. Both are three-line
;   accumulator walks in this module's existing style (cf. rnd-append-list :178).

; ─── render-to-ansi gains its arm, and it is six lines ────────────────────
; A container, so it follows r-lines/r-tree: no ansi-goto of its own and no
; rd-in-view clip — the leaves clip themselves (the comment at :426 says why).
(declare render-row (=> (List Rendering) (Pair I64 I64) I64 I64 I64 I64 Unit))

(def render-row
  (lam (children dims row col drow dcol)
    (case children
      (nil unit)
      ((cons child rest)
        (let ((_ (render-to-ansi child dims none row col drow dcol)))
          (render-row rest dims row (+ col (rnd-cols child)) drow dcol))))))

; … and inside render-to-ansi's case, beside the r-lines and r-tree arms:
;       ((r-row children) (render-row children dims row col drow dcol))

; ─── diff-node gains its arm too (:223) — this is the SECOND exhaustive case ──
; Structural, in the shape of the existing r-lines arm; list-all-diff-same
; already exists (:191) and needs no change.
;       ((r-row ch1)
;         (case new
;           ((r-row ch2)
;             (case (list-all-diff-same ch1 ch2)
;               (true diff-same)
;               (false (diff-changed new))))
;           (_ (diff-changed new))))

; ─── lib/protocol/apc.chiral — the file that is ALREADY RED ───────────────
; `enc : (-> Rendering Str)` (:41/:89) matches SIX of eight and has no default,
; so `chirality check prog/scriba/samples/t6_apc_roundtrip.prog` fails TODAY with
; `load: non-exhaustive case`. E174 makes it six of NINE. Adding a `_` arm would
; "fix" it by defeating the closed sum — the exact thing that made this element's
; cost knowable — so the arms are written, tag letters continuing the existing
; scheme (t/T/s/S/h/r, all graphic-ASCII per the APC envelope rule at :1-6):
;       ((r-lines children) (str-cat "L" (enc-rends children)))
;       ((r-face f body)    (str-cat "F" (str-cat (enc-str f) (enc body))))
;       ((r-row children)   (str-cat "R" (enc-rends children)))
; … and the matching decode cases, which are `enc-rends`/`dec-rends` walks the
;   file already has for r-tree. Whether this lands INSIDE E174 is §6.
```

- **Knobs to modify:** `str-cols`'s body (the unit decision — §6 q1); the four
  layout constants, which a caller-supplied-constraint design would move to call
  sites instead (§3, `ratatui`); whether `r-row` gains a separator field (rejected
  in §4.2, but it is one field if a consumer demands it).
- **Deliberately omitted:** any `_` catch-all anywhere; wrapping/reflow inside a
  row; the E175 face stack; `doc->rendering` itself (that is E158 commit 4, which
  *consumes* this); the E161 `(module protocol/render …)` datasheet line;
  `apc.chiral`'s decode side, sketched not written.

## 6. Use / modify notes

- **Lands in:** `lib/protocol/render.chiral` — the sum (`:6`), the new constants,
  `str-cols` + `rnd-cols` + its four folds, the `render-to-ansi` arm (`:731-732`), the
  `diff-node` arm (`:303-309`), and a new `(import "protocol/utf8")`. Secondarily
  `lib/protocol/apc.chiral` (`enc` at `:89`, plus decode) — see open question 5.
  Nothing in `prog/` needs touching: the eight only-constructing files are
  unaffected by a new arm, and all three `.prog` files that do case
  (`scriba-runview-test`, `scriba-runview-stream-test`, `t6_apc_roundtrip:82`)
  match through `(_ …)` arms.

- **Conformance target.** Four gates, all cheap and all with a mutant available:
  1. **The red sample goes green.** `./bin/chirality check
     prog/scriba/samples/t6_apc_roundtrip.prog` currently prints
     `load: non-exhaustive case`; after E174 it must print `OK`. This is a gate the
     tree hands you for free, and it grades the coverage claim rather than
     asserting it.
  2. **The controls stay green.** `scriba-runview-test.prog` and
     `scriba-test-b1.prog` both `check` OK today; they must still.
  3. **The row is a row.** `(r-row (cons (r-face "diag-head" (r-text "a" false))
     (cons (r-text " " false) (cons (r-face "diag-site" (r-text "bb" false))
     nil))))` renders three segments on ONE line at columns 1, 2, 3 — verified by
     the emitted byte stream carrying exactly the expected `ansi-goto`s, the way
     E112's codec tests read raw bytes. **Mutant:** perturb `rnd-cols`'s `r-text`
     arm to `(+ 1 (str-cols content))` and the assertion must fail.
  4. **Widths agree with the emitter.** For each constructor, the column the
     emitter *actually leaves the cursor at* equals `rnd-cols` of that node. This
     is the invariant §1 says is bolted on, so it must be a *test*, not a comment
     — and it is the row that catches a future edit to `render-tree` that forgets
     `rnd-tree-indent`. **`r-section` cannot pass this row as the tree stands**
     (finding 8: `render-section` emits no `ansi-goto`, so where it leaves the
     cursor is a function of what was drawn before it, not of `col`). Either the
     gate excludes `r-section` and says why, or open question 7 is answered first.

- **Open questions — the honest residue. None of these is deferred to an element
  that does not exist; where a follow-on would be needed I say so and stop.**

  1. **⚑ What does `str-cols` mean, finally?** §5 takes **codepoints**, because
     that is derivable from `utf8.chiral` today, is strictly better than the
     incumbent byte count, and localises the unit in one named function. It is
     **still wrong** for CJK/full-width (2 cells), combining marks and ZWJ
     sequences (0 cells), and it costs an O(n) decode per node per render where
     `str-len` was O(1). The correct answer is a wcwidth-class codepoint→cell
     table, which `utf8.chiral:15` anticipates ("the T4 wide-cell width
     computation") and **nothing in this tree builds**. That is its own element and
     **a pre-run cannot mint one**, so it is recorded here as an open question, not
     as a deferral to a phantom row. *The author's call: mint a wide-cell-width
     element, or accept codepoints and say so in the spec.* Fallback if the decode
     cost measures badly: keep `str-cols` as the seam and let its body be
     `str-len`, which is the same signature and a worse body — the seam is what
     matters.
  2. **`r-table`'s header/body disagreement (finding 4).** Headers advance by
     content, cells by a fixed 16. §5 answers with the grid and calls `headers`
     the wrong half, because that is what a cell obeys. Fixing it means either
     giving `r-table` real column widths (a per-column measure fold — a genuine
     feature) or deleting the header gutter arithmetic. **Neither belongs in
     E174**, and again there is no minted row to hand it to. Named, not shelved.
  3. **What does `r-row` do with a multi-row child?** `rnd-cols` of an `r-lines`
     is `max`, which is the only defensible number. But an `r-lines` inside an
     `r-row` means the "row" occupies several rows — that is 2-D box layout, more
     than E174 promised. Three dispositions, all cheap, none obviously right:
     (i) allow it, since `render-row` already works — each child draws where it
     wants and `col` advances by max; (ii) document `r-row` as single-line and let
     a stacked child be representable-but-mis-rendering; (iii) refuse it, which
     needs a check `Rendering` has nowhere to put. **Recommend (i)** — it is what
     the code in §5 does with no extra line — but it should be *stated*, because a
     silently-2-D combinator is a surprise.
  4. **`r-stream` reserves nothing.** §5 defines a stream's width as its
     placeholder's, i.e. a stream occupies no space for content it does not hold.
     Correct while the emitter draws a placeholder; a real streaming renderer
     invalidates it and would want a reservation field on the constructor. Cheap
     to revisit; recorded so the definition is visible as a definition.
  5. **Does fixing `apc.chiral` land inside E174 or beside it?** It is not E174's
     defect — `r-lines` and `r-face` broke it — but E174 is what forces the file to
     be recompiled, and gate 1 above is only available if E174 fixes it. Against:
     it widens the element and the APC wire format is a compatibility surface.
     **Recommend: inside**, because leaving a knowingly-red sample behind is the
     failure mode finding 2 documents, and because three constructors of codec is
     smaller than a separate element's ceremony.
  6. **Should `rnd-cols` be `(-> Rendering I64)` at all?** §3's `rich` returns a
     pair. §5 argues one number is honest *because nothing wraps*. If wrapping ever
     enters `Rendering`, this signature is wrong rather than imprecise — worth one
     sentence in the spec so a later reader knows it was considered.
  7. **⚑ Does E174 give `render-section` its `ansi-goto`?** (Added at the example
     audit.) Finding 8: it is the one drawing arm that never positions itself, so
     `r-row`'s whole contract — child *n* draws at `col + Σ widths` — is void for
     an `r-section` child. One `(put (ansi-goto row col))` at `render.chiral:385`
     is the whole fix and it is smaller than the `enc` repair E174 already takes
     on (open question 5). **Against:** it is a pre-existing defect, not E174's,
     and it changes what a bare `render-to-ansi` of an `r-section` puts on the
     wire, which is a behaviour every existing caller currently gets away with.
     There is no minted row to hand it to. *The author's call: fix it inside E174,
     or scope `r-row` to exclude `r-section` children in writing.*

- **Where E174 and E175 do meet — one place, and it is not the arithmetic.**
  Faces are zero-width, so no E175 fix changes any number in `rnd-cols`. But
  `render-row` draws sibling *after* sibling on one line, which is exactly the
  arrangement in which E175's full `ansi-reset` becomes visible: an `r-row` whose
  first child is an `r-face` currently resets SGR before the second child draws, so
  a row nested inside an outer face renders its tail unfaced. **E174 does not lower
  the nesting depth at which E175 bites — that is two `r-face`s either way.**
  (Audit correction: the draft said "one level of nesting instead of two", which
  its own next clause contradicts and which `r-lines` already refutes —
  `r-face(outer, r-lines(r-face(inner, …), rest))` exhibits the identical
  two-deep unfaced tail today, `render-lines:409` holding `col` while `r-face:469`
  emits the full reset.) What E174 changes is *where* the defect shows: from
  across rows, where a lost face reads as a styling glitch, to **within one line**,
  where it lands mid-sentence in a diagnostic — which is precisely the output
  E158 commit 4 produces. Order them E174 then E175, and E158's G8 gate grades the
  pair.

- **Contradiction to record.** `docs/elements/catalog.md:438` and
  `docs/elements/ledger.md:293` both state *"12 files case over it"*. Measured (finding
  1): 17 import, 13 name a constructor, **5 case, and only 1 has an exhaustive case
  that breaks**. The catalog figure appears to be a count of constructor-naming
  files other than `render.chiral` itself (exactly 12), which is a different and
  much larger set than "cases over". The mechanism the row describes is right; the
  number overstates the cost by roughly 3×, and the row understates a different
  cost entirely — that one of those files is **already broken** by the previous
  arm addition (finding 2).

- **Related:** [[E158-doc-formatter]] (the forcing consumer; commit 4 is gated on
  this) · [[E157-typed-diagnostics]] (the `Reason` sum `dg-doc` renders) ·
  E175 (nested `r-face`, `LEDGER.md:294` — orthogonal, see above) ·
  E176 (`str-sub` unclamped, `LEDGER.md:295` — the same
  property-asserted-in-prose-not-in-a-type shape that `str-cols` is written to
  avoid) · [[E112-apc-sidechannel]] (the codec that must learn the new arm).

---

## Author decision on FLAG A (2026-08-31)

**`render-section` gets its `ansi-goto`, inside E174.** Option (a).

**Measured first.** `render-section` (`render.chiral:383-392`) takes `row` and
`col` as parameters and **never reads `col`** — it opens `(put ansi-bold)` then
`(put title)`, so the title lands wherever the previous `put` left the cursor,
and `col` survives only as `(+ col 2)` handed to the body. Every other drawing
arm opens with `(put (ansi-goto …))`: `:356` (table headers), `:439` (`r-text`),
`:455` (`r-stream`), `:465` (`r-hole`). **`render-section` is the single
outlier**, and it is correct today only because a section happens to be first on
its row.

**Why inside E174 rather than excluded or deferred:**

1. **The alternative restricts the type to dodge a renderer bug.** Writing "an
   `r-row` may not contain an `r-section`" makes the sum unable to express
   something legitimate, and it is the same shape as the *restrict-the-contract*
   option already refused for E158 — which was measured to fail on its own first
   consumer. A type narrowed around a defect outlives the defect.
2. **Gate 4 would otherwise be unsatisfiable.** §6's "widths agree with the
   emitter" cannot hold for `r-section` while the emitter ignores `col`: a gate
   that *cannot* pass for one constructor is a gate with no teeth there. This
   session has already found **four** gate rows that could never fail; shipping a
   fifth knowingly is not available.
3. **E174 already takes on the larger repair.** The `apc.chiral` `enc` fix — a
   codec, a wire format, two red samples — is E174's red→green gate. Accepting
   that and refusing a one-line positioning fix in the same module is
   inconsistent about what "in scope" means.
4. **It removes a special case rather than adding one.** After the change every
   drawing arm positions itself the same way. That is a smaller renderer, not a
   bigger one.

**The cost, stated honestly:** this changes what a bare `render-to-ansi` of an
`r-section` puts on the wire — it will now emit a positioning sequence it did not
emit before. That is a *correction* (the section lands where it was told rather
than where the cursor drifted), but it is a behaviour change and needs its own
gate row: **a section rendered first-on-row must land exactly where it lands
today**, so the fix is proved to be a no-op in the only configuration the tree
currently produces.

**Not minted, deliberately.** This is one line in a module E174 already edits,
under a gate E174 already owns. Minting a row for it would be the ceremony the
deferral rule exists to prevent, not the tracking it exists to guarantee.
