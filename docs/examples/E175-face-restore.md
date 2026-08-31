---
element: E175
slug: face-restore
title: **A face survives its body** — the ANSI renderer carries the ambient face and restores it, instead of full-resetting at every close.
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none — `lib/protocol/render.chiral` is the baseline)
status: reviewed
updated: 2026-08-31
---

# E175 — **A face survives its body**

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E175 — give `render-to-ansi` an **ambient face**, and make every
  close in the module restore it instead of emitting `\e[0m`.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** `Rendering` is a *medium-independent* value.
  The SGR register set is *terminal state*. Nothing off the shelf reconciles
  those two for this sum, and the conventional shortcut — resolve a full style
  per segment before emitting, the way `rich` does — is a different architecture
  (§3), not a patch.

**⚑ The catalog's defect statement is narrower than the defect. Measured.**
The row (`SELF-IMPLEMENT-CATALOG.md:439`, `LEDGER.md:294`) says *nested* `r-face`
loses the outer face, and prescribes *"a face stack in `render-to-ansi`,
re-emitting the enclosing face's SGR at each close"*. Both halves need
correcting, and the correction is the element:

1. **Nesting is not required.** A face over a body with **more than one drawing
   leaf** already loses the face after the first leaf — no second `r-face`
   anywhere. `r-lines` has made that shape available since the sum was written;
   E174's `r-row` just added a second way to reach it.
2. **A stack popped at `r-face` closes does not fix it.** The `\e[0m` that kills
   the second leaf is emitted by **`r-text`'s own arm** (`:687`), not by
   `r-face`'s (`:721`). **Six** drawing sites in this module open with an SGR and
   close with an unconditional full reset. Fixing one of them fixes one third of
   one case.

The honest statement of the defect is therefore:

> **The module has no notion of SGR state.** Every drawing arm turns on what it
> wants and closes by clearing *everything*. That is correct for exactly one
> level of styling, and the tree has never had two.

**⚑ And one correction the EXAMPLE audit had to make to the example (2026-08-31,
`e158-doc`).** The first draft said — and the catalog row, the ledger row and the
INDEX row still say — that under the fix *"only the close changes and all 11 live
consumers stay byte-identical"*. The audit applied §5's patch to a scratch `lib/`
copy and re-ran the probe: the live consumers are **screen-identical, not
byte-identical** (finding 5), the census is **14**, not 11, and `tools/test/row.sh`
does **not** survive unedited (§6, G7). The three-part refutation above was
re-derived independently and stands unchanged.

**Still LATENT, and that is confirmed rather than assumed** (§2, finding 3): all
fourteen live `r-face` sites wrap a single `r-text`, which is the one shape that
works. **E158 commit 4 (`doc->rendering`) is the first breaker** — and, correcting
the brief a second time, it breaks it *without nesting*, because `dg-doc`'s tags
are siblings (finding 4).

**Explicitly NOT in scope:** horizontal layout (E174, **built**), `str-cols`'s
display-width story (E177), `r-table`'s two layouts (E178). E175 changes **no
number in `rnd-cols`**: SGR bytes paint no cell, so `rnd-cols`'s `r-face` arm
(`:515`) is `(rnd-cols body)` before and after. That arithmetic independence is
why these are two elements, and it is now *checked* rather than asserted —
`row.sh`'s screen reducer discards SGR by construction.

## 2. Research

- **Reference class:** `OURS`. `render.chiral` was written natively; there is no
  Python baseline. The reference is the module, its consumers, the emitted byte
  stream (finding 1), and the style models of two conventional stacks (§3).

**Key findings — measured in this tree on 2026-08-31, on `e158-doc` at `efac8b2`,
with E174 already landed.**

1. **⚑ The whole element, in one byte string.** A probe built outside the source
   tree (the `row.sh` shape: `chirality_blob_file` → `bin/chirality-bin` → run,
   `od -tu1`) rendering four nodes at rows 1/3/5/7 through `render-to-ansi`,
   `dims = (pair 40 200)`. `ESC` shown as `@`:

   | # | node | emitted |
   |---|---|---|
   | A | `(r-face "keyword" (r-text "ab" false))` | `@[1m@[31m@[1;1H` `ab` `@[0m@[0m` |
   | B | `(r-face "keyword" (r-row [(r-text "ab") (r-text "cd")]))` | `@[1m@[31m@[3;1H` `ab` `@[0m` `@[3;3H` `cd` `@[0m@[0m` |
   | C | `(r-face "keyword" (r-row [(r-face "error" (r-text "xy")) (r-text "zw")]))` | `@[1m@[31m` `@[4m@[31m` `@[5;1H` `xy` `@[0m@[0m` `@[5;3H` `zw` `@[0m@[0m` |
   | D | `(r-face "keyword" (r-lines [(r-text "ab") (r-text "cd")]))` | `@[1m@[31m@[7;1H` `ab` `@[0m` `@[8;1H` `cd` `@[0m@[0m` |

   Read off it, in order of how much it changes the element:

   - **A is correct.** `keyword` = `(face "keyword" 1 -1 1)` → bold + fg-red, the
     `ansi-goto`, the text, then two redundant resets. One face, one leaf, fine.
   - **B and D are wrong, and neither nests.** `cd` renders with **no SGR at all**.
     The reset that did it is `r-text`'s, at `:687`. D uses only `r-lines`, which
     has been in the sum since before `r-face` — so this defect is **older than
     E174**, not enabled by it.
   - **⚑ C shows the two halves of the design question in one line.** The inner
     face's open emits `@[4m@[31m` — underline and red, and **no bold**, because
     `face-sgr` emits only the bits that are set. The terminal's bold is still on
     from the outer face, so `xy` renders **bold + underline + red**: the open
     **composed as a delta**. The close then emits `@[0m`: a **replacement**.
     *The emitter is already inconsistent with itself* — open is a delta, close is
     a replacement — and E175 is the element that picks one.

2. **Six close sites, not one.** Every one is `put <some SGR>` … content …
   `put ansi-reset`:

   | site | opens with | closes at |
   |---|---|---|
   | `rnd-emit-headers` (`:561`) | `ansi-bold` | `:569` |
   | `render-section` (`:593`) | `ansi-bold` | `:610` |
   | `render-tree` (`:616`) | `ansi-bold`, only when selected | `:624`, guarded to match |
   | `r-text` arm (`:685`) | `ansi-bold`, only when `bold` | `:687` |
   | `r-stream` arm (`:701`) | `ansi-bold` | `:705` |
   | `r-face` arm (`:714`) | `face-sgr (lookup-face …)` | `:721` |

   Five of the six are **ad-hoc faces**: a hardcoded `ansi-bold` that the face
   registry does not know about. `r-hole` (`:706`) is the exception — it emits no
   SGR and closes with `(put "")`, so it needs nothing.

3. **The latency claim holds, and here is the census.** Fourteen live `r-face`
   construction sites, every one of them `(r-face <name> (r-text …))`:
   `chat-view:125,141,195` · `command-loop:1471` · `init-loader:135,138,234` ·
   `manas-runview:74,76,101` · `manas-mode:472,473,919,1003` (four of those are
   the `mf-row`/`mh-row` helpers and their two inline siblings). **No live
   consumer builds a face over more than one leaf, and none nests.** Nothing on
   screen is wrong today. *(`manas-runview:101` reads like a multi-line body
   because of the line wrap; it is one `r-text` built by `str-cat`.)*

   **One fixture already builds the broken shape**, and it landed with E174:
   `tools/test/samples/e174_row.prog:61`, `rz-c10` =
   `(r-row [(r-face "keyword" (r-row [(r-text "x") (r-text "y")])) (r-text "z")])`.
   It is invisible because that sample exercises only the **APC codec**
   (`enc`/`dec-frame` round-trip) and never calls `render-to-ansi`. So the tree
   contains a value whose ANSI rendering is wrong and nothing that renders it.

4. **⚑ The forcing consumer does not nest either, which changes what the fix has
   to cover.** `dg-doc` (`lib/typing/diag.chiral:510`) is E158's `(-> Reason Doc)`
   and the mapping E158 commit 4 will build is `d-tag` → `r-face`
   (`lib/prelude/doc.chiral:83,182`). Its thirteen `d-tag` sites (`:519,526,528,
   535,543,546,555,573,587,601,616,624,637`) are **all siblings** — `diag-head`
   beside `diag-site`, never inside — and `dg-decl-doc` (`:647`), the one function
   called from *inside* a `d-tag` body, emits `doc-concat` of plain `d-text`s and
   no tag of its own. So `dg-doc`'s first arm, `r-redeclared`, becomes

   ```
   (r-face "diag-head" (r-row [ (r-text "term") (r-text " redeclared: ") (r-text "x") ]))
   ```

   which is **finding 1's case B exactly**: three leaves under one face, of which
   two render unfaced. A face-stack fix scoped to nested `r-face` would leave
   E158 commit 4 broken and passing its own review.

5. **`face-sgr` of the default face is the empty string, and that is load-bearing.**
   `default-faces:144` maps `"default"` to `(face "default" -1 -1 0)`; `face-sgr`
   (`:184`) emits `""` for every unset bit and for `fg`/`bg` `< 0`; `lookup-face`
   (`:160`) returns `(face name -1 -1 0)` for an unknown name. So
   `(str-cat ansi-reset (face-sgr default))` **is** `ansi-reset`, byte for byte —
   which is what lets §5 handle depth 0 without a special case. Confirmed in
   finding 1: A's tail is exactly `@[0m@[0m`, not `@[0m@[m` or anything longer.

   **⚑ It does NOT make the fix byte-identical for the live consumers, and an
   earlier draft of this file, the catalog row and the ledger row all said it
   did. Measured, by applying §5's patch to a scratch `lib/` copy and re-running
   finding 1's probe:** the live shape `(r-face f (r-text …))` emits

   | | bytes |
   |---|---|
   | before | `@[1m@[31m` `@[1;1H` `ab` `@[0m` `@[0m` |
   | after  | `@[1m@[31m` `@[1;1H` `ab` `@[0m@[1m@[31m` `@[0m` |

   because the **inner** close restores the ambient, and inside an `r-face` the
   ambient is that face — not the plain one. Only a leaf at **depth 0** closes
   with a bare `\e[0m`. Depth-0 identity is what finding 5 buys; the faced leaf
   gains a redundant re-assertion that the enclosing `r-face`'s own close then
   wipes. **What is unchanged for every live consumer is the SCREEN, not the byte
   stream** — same painted cells, same SGR set per cell, same terminal state on
   exit. Measured with an SGR-tracking reducer over both streams, all four probe
   nodes, `row col byte|sgrset`: every cell A paints is identical, and the only
   cells that move are exactly the ones the defect loses (`(3,3) (3,4) (5,3)
   (5,4) (8,1) (8,2)`: `{}` → `{1,31}`). §6's G1 is written against that, because
   byte-identity is not merely unproven here — it is false, and a gate row
   asserting it could never go green.

6. **`render-to-ansi` already carries a dead parameter.** `(declare
   render-to-ansi (=> Rendering (Pair I64 I64) (Maybe Rendering) I64 I64 I64 I64
   Unit))` (`:99`) — the `(Maybe Rendering) prev`. All seven internal call sites
   (`:577,614,623,636,655,720,729`) pass `none`; no body reads it — `prev` occurs
   exactly once in the module, as the binder at `:666`. Relevant to "where does
   the new state live" (§4.3), and rejected there.

7. **The redraw path cannot be hurt yet, and the reason is temporary.**
   `render-to-ansi-delta` (`:733`) is Phase 1: `(diff-changed _)` re-renders the
   **whole tree** through `render-to-ansi-full`. So no partial repaint exists to
   land mid-face. But `diff-node`'s `r-face` arm (`:306`) recurses into the body
   when the two face names are equal and hands back the *body's* `Diff` — so a
   `diff-changed` payload escaping a face **carries no face**. The day the delta
   renderer draws that payload alone, it draws it unfaced. Named in §6, out of
   scope here, and no follow-on number is invented for it.

8. **Two `put ansi-reset` sites live outside this module** —
   `prog/scriba/command-loop.chiral:478` and `:1546`. Both run outside the tree
   walk, at depth 0, where restore and reset are the same bytes (finding 5). They
   need no change and E175 must not touch them.

## 3. Conventional (other-language) approach

Two stacks, two different answers, and neither is available here.

```python
# rich (shape, not verbatim): Style is a DELTA, and the renderer never restores.
class Style:
    bold: bool | None      # None == "inherit from below me"
    color: Color | None
    def __add__(self, other):                    # outer + inner
        return Style(bold  = other.bold  if other.bold  is not None else self.bold,
                     color = other.color if other.color is not None else self.color)

# The console resolves the FULL style for each segment before any byte is written,
# then emits that segment's complete SGR. There is no "close": the next segment
# simply carries its own resolved style, and the terminal is reset once at the end.
for text, style in doc.render(console):
    console.write(style.render(text))            # style is already the join
```

```c
/* ncurses: attron is a delta, attrset is a replacement, and PAIRING IS MANUAL. */
attron(A_BOLD | COLOR_PAIR(1));
addstr("outer ");
attron(A_UNDERLINE);        addstr("inner");
attroff(A_UNDERLINE);       /* the bug is writing attrset(A_NORMAL) here */
addstr(" outer again");
attroff(A_BOLD | COLOR_PAIR(1));
```

- **Assumptions they bake in:** `rich` assumes the renderer may **buffer and
  resolve** — it walks the document into `Segment`s first, joins styles on the
  way down, and emits once per segment. That removes the restore problem by
  removing the close. It costs an intermediate representation and a `Console`
  threaded through the measure, which is exactly what E174 refused
  (`rnd-cols : (-> Rendering I64)`, no console). ncurses assumes an **ambient
  mutable attribute register** the caller pairs by hand, and the well-known bug
  is precisely the one measured in finding 1: closing with the "off everything"
  form instead of the "off what I turned on" form.
- **A third conventional answer exists and this element rejects it:** SGR has
  per-attribute off codes — `22` normal intensity, `23` not italic, `24` not
  underlined, `27` not reversed, `39`/`49` default fg/bg. `face-sgr` emits none of
  them. Turning off exactly what you turned on needs the *difference* between the
  inner face and the ambient — so it needs the ambient anyway, and buys nothing
  the restore does not (§4.4).

## 4. The chirality idea

- **Chirality features in play:** the `->`/`=>` membrane (the join is pure; only
  the emission crosses) · closed sums with enforced coverage · boundary-sums (SGR
  never rides inside a `Str`) · PRINCIPLES §5, push the invariant into the
  substrate: the ambient face becomes a *binder the recursion already threads*
  rather than a register two functions agree about.

**1. ⚑ The recursion is the stack. There is no stack.**
The catalog says "a face stack". A stack is what you need when pushes and pops
are separated in *time*. Here they are separated by a **call**: `render-to-ansi`
descends into the body and returns. So the enclosing face is just a parameter —
the chirality call stack already holds every enclosing face, one frame each, and
a second `(List Face)` would be a shadow copy of it that can desynchronise.

One `Face` parameter, not a list, and the parameter is the **joined ambient**, not
the immediately-enclosing face. That distinction is the whole of finding 1's case
C: at `zw` the correct state is `keyword`, at `xy` it is `keyword ⊔ error`, and
only a joined value gives both without a re-walk.

**2. ⚑ Faces are DELTAS. The decision is forced by the bytes, not by taste.**
The open question the brief names — *is a face a replacement or a delta?* — has an
answer in this tree, and it is not a coin flip:

- `face-sgr` **already emits a delta**: `-1` fg emits nothing, an unset attr bit
  emits nothing. It has no vocabulary for "off".
- The terminal **already composes** those deltas: finding 1's `xy` is bold because
  the outer's bold was never cleared.
- So **delta is what live consumers already see.** Choosing replacement means
  emitting `\e[0m` before every face open and then the ambient's full resolved
  SGR — strictly more bytes for the identical screen, and it couples the OPEN to
  the ambient too, so `face-sgr` of the looked-up face would no longer be enough
  to open a face. Delta keeps the open a function of the face alone.
  *(Note what this argument is NOT: it is not "delta leaves the bytes alone".
  Finding 5 measures that it does not — every faced leaf's CLOSE gains the
  ambient's SGR under delta as well. The claim that survives is that the open is
  byte-unchanged, the screen is unchanged, and replacement costs more bytes to
  reach the same screen.)*
- And it makes `face-join` a **description of the existing emitter**, not a new
  policy: attrs OR, inner's colour wins when set. Write down what the terminal
  does, then make the close agree with it. **Only the close changes.**

The cost is stated rather than smoothed over: under delta semantics a face
**cannot turn anything off**. `(r-face "default" body)` is a no-op, not a
reset-to-plain, because `face-sgr (face "default" -1 -1 0)` is `""` — and
`lookup-face` gives an *unknown* name that same face, so a typo'd face name and
an explicit `"default"` are indistinguishable. That is true today and E175 does
not make it worse; it makes it *visible*, because today's full reset accidentally
gives `"default"` a meaning at the close. §6 open question 1.

**3. Where the ambient lives: one more parameter, and the S18 precedent is read
the other way.**
`render-to-ansi` goes from seven parameters to eight. The record shape (S18's
editor-state record) earned itself at **11 parameters over 436 sites**; this is
**one** parameter over ~20 call sites **inside one file**, with no external caller
affected — `render-to-ansi-full` and `render-to-ansi-delta` keep their signatures
and seed the ambient themselves. Trading a positional parameter for a record here
buys a constructor, an accessor per field, and a rewrite of every internal call,
to save one argument. Refused, with the number that would flip it named: if a
*second* piece of renderer state lands, build the record then and move both.

Finding 6's dead `prev : (Maybe Rendering)` slot is **not** reused. Repurposing a
parameter to a type it was not declared for is exactly the "a `Str` carries
which-of-N" flattening this repo removes elsewhere. Deleting it is a separate,
unrelated cleanup and gets no number here (§6 open question 4).

**4. Depth 0 is not a special case; it is finding 5.**
`render-to-ansi-full` seeds the ambient with the default face, whose `face-sgr` is
`""`, so `restore` at depth 0 emits `\e[0m` and nothing else. No `(case depth
(0 …))`, no bottom-of-stack sentinel. The general rule *is* the base case, which
is the difference between an invariant and a guard.

**5. What chirality makes impossible here.** The `rich` answer — buffer the tree
into resolved segments, emit each with its full style, never close — is available
in principle and is refused for a reason already on the record: it needs a second
intermediate representation between `Rendering` and the bytes, and it puts style
resolution on the *emission* side of the membrane, where `rnd-cols` deliberately
is not. E174 established that placement is pure arithmetic on the value; E175
keeps styling on the same side. `face-join` is `(-> Face Face Face)`. Only `put`
crosses.

## 5. Chirality example (fleshed)

A patch against `lib/protocol/render.chiral`. The module imports
`prelude/prelude`, `ports/ports`, `protocol/utf8` and carries no `(module …)`
datasheet line (E161 adoption, out of scope). Mechanical recursion is elided with
`; …`; what is written out is what a later run must get *right*.

```chirality
; ─── new declares, beside the existing face block (:57-61) ─────────────────

; The join of an enclosing face and one nested under it. NOT a new policy: this
; is a description of what the terminal already does with face-sgr's output,
; written down so the CLOSE can agree with the OPEN. See §4.2.
(declare face-join (-> Face Face Face))

; The default ambient — what `render-to-ansi-full` starts from, and the reason
; depth 0 needs no special case. face-sgr of this is "" (measured), so
; (rnd-restore rnd-face-plain) is byte-identical to (put ansi-reset) — at DEPTH 0
; only; see rnd-restore's own note below.
(declare rnd-face-plain Face)

; ⚑ THE ONE NEW EMITTER, and the only place `ansi-reset` may still appear inside
; the tree walk. Six sites call it; none of them spells the reset itself.
(declare rnd-restore (=> Face Unit))

; ─── the joined ambient ────────────────────────────────────────────────────

; attrs OR (an attribute nested inside another shows both — that is what the
; terminal does with two attron-shaped opens, and finding 1's `xy` proves it).
; fg/bg: the INNER wins when it has an opinion (>= 0), otherwise the outer's
; survives. -1 means "no opinion", NOT "default" — see §6 open question 1, which
; is the one place this choice is felt.
; The joined face's NAME is the inner's: nothing reads it, and carrying the
; outer's would make a debug print lie about which face is on top.
(def face-join
  (lam (outer inner)
    (case outer
      ((face on ofg obg oat)
        (case inner
          ((face iname ifg ibg iat)
            (face iname
                  (case (<i ifg 0) (true ofg) (false ifg))
                  (case (<i ibg 0) (true obg) (false ibg))
                  (bor oat iat))))))))

(def rnd-face-plain Face (face "default" -1 -1 0))

; RESET THEN REAPPLY, and not per-attribute off codes: `face-sgr` has no
; vocabulary for "off" (§3), the ambient is in hand either way, and this is one
; expression instead of six conditional off-codes that must stay in step with
; face-sgr's six on-codes. When `amb` is rnd-face-plain the tail is "" and this
; emits exactly `\e[0m` — the DEPTH-0 close, byte for byte what it emits today.
; Inside a face the tail is that face's SGR, so a faced leaf's close is LONGER
; than today's by exactly `face-sgr amb`, which the enclosing r-face's own close
; then wipes: same screen, more bytes. Measured — finding 5, and §6 gate G1 is
; written against the SCREEN for that reason.
(def rnd-restore
  (lam (amb) (put (str-cat ansi-reset (face-sgr amb)))))

; ─── the threaded signatures ───────────────────────────────────────────────
; Every walker gains ONE trailing `Face`. `render-to-ansi-full` / `-delta` do
; NOT: they are the entry points, and they seed.

(declare render-to-ansi
  (=> Rendering (Pair I64 I64) (Maybe Rendering)
      I64 I64 I64 I64 Face Unit))                 ; <- amb
(declare render-lines   (=> (List Rendering) (Pair I64 I64) I64 I64 I64 I64 Face Unit))
(declare render-row     (=> (List Rendering) (Pair I64 I64) I64 I64 I64 I64 Face Unit))
(declare render-tree    (=> (List Rendering) Rendering (Pair I64 I64) I64 I64 I64 I64 Face Unit))
(declare render-section (=> Str Bool Rendering (Pair I64 I64) I64 I64 I64 I64 Face Unit))
(declare render-table   (=> (List Str) (List (List Rendering)) (Pair I64 I64) I64 I64 Face Unit))
(declare rnd-emit-headers  (=> (List Str) I64 I64 Face Unit))
(declare rnd-emit-rows     (=> (List (List Rendering)) (Pair I64 I64) I64 I64 Face Unit))
(declare rnd-emit-one-row  (=> (List Rendering) (Pair I64 I64) I64 I64 Face Unit))

; ─── the arms that change ──────────────────────────────────────────────────

(def render-to-ansi
  (lam (node dims prev row col drow dcol amb)
    (case node
      ; containers: thread `amb` through unchanged. They emit nothing.
      ((r-lines children)  (render-lines children dims row col drow dcol amb))
      ((r-row   children)  (render-row   children dims row col drow dcol amb))
      ((r-tree  children selected)
                           (render-tree children selected dims row col drow dcol amb))

      ; ⚑ THE ARM THE CATALOG ROW NAMES, and it is the SMALL half of the fix.
      ; The OPEN is byte-unchanged: still `face-sgr` of the looked-up face, still
      ; a delta (§4.2). Only the close moves, and the descent carries the join.
      ((r-face face-name body)
        (case (rd-in-view dims row)
          (false unit)
          (true
            (let ((f (lookup-face default-faces face-name)))
              (let ((_ (put (face-sgr f))))
                (let ((_ (render-to-ansi body dims none row col drow dcol
                                         (face-join amb f))))
                  (rnd-restore amb)))))))          ; was: (put ansi-reset)

      ; ⚑ THE ARM THAT ACTUALLY FIXES FINDINGS 1B/1D, and it is not an r-face
      ; arm at all. This close is what unfaced `cd`. `bold` here is an AD-HOC
      ; face (finding 2) — it is NOT joined into `amb`, because it ends at this
      ; leaf and nothing descends past it.
      ((r-text content bold)
        (case (rd-in-view dims row)
          (false unit)
          (true
            (let ((_ (put (ansi-goto row col))))
              (let ((_ (case bold (true (put ansi-bold)) (false unit))))
                (let ((_ (put content)))
                  (rnd-restore amb)))))))          ; was: (put ansi-reset)

      ; the remaining four arms: identical shape. `r-table` / `r-section` pass
      ; `amb` down; `r-stream` closes with (rnd-restore amb); `r-hole` opens no
      ; SGR and closes with (put "") — UNCHANGED, and it is the control that
      ; shows the fix is not a blanket edit.
      ; …
      )))

; ─── the two ad-hoc-face closes outside render-to-ansi ─────────────────────

(def rnd-emit-headers
  (lam (hs r c amb)
    (case hs
      (nil unit)
      ((cons h rest)
        (let ((_ (put (ansi-goto r c))))
          (let ((_ (put ansi-bold)))
            (let ((_ (put h)))
              (let ((_ (rnd-restore amb)))         ; was: (put ansi-reset)
                (rnd-emit-headers rest r (+ c (+ (str-len h) rnd-header-gutter))
                                  amb)))))))))

(def render-tree
  (lam (children selected dims row col drow dcol amb)
    (case children
      (nil unit)
      ((cons child rest)
        (let ((is-sel (rnd-is-selected child selected)))
          ; the selection highlight is a face in everything but name. It stays
          ; ad-hoc here — turning it into a real face is a SEPARATE change with
          ; its own consumers (§6 open question 3), and E175 only fixes its close.
          (let ((_ (case is-sel (true (put ansi-bold)) (false unit))))
            (let ((_ (render-to-ansi child dims none row (+ col rnd-tree-indent)
                                     drow dcol amb)))
              (let ((_ (case is-sel (true (rnd-restore amb)) (false unit))))
                (render-tree rest selected dims (+ row 1) col drow dcol amb)))))))))

; ─── the entry points seed, and their signatures do not move ───────────────

(def render-to-ansi-full
  (lam (tree dims)
    (let ((_ (put ansi-clear)))
      (let ((_ (put ansi-home)))
        (render-to-ansi tree dims none 1 1 1 1 rnd-face-plain)))))
```

- **Knobs to modify:** `face-join`'s colour rule (inner-wins-when-set) is the one
  line that encodes §4.2's decision — invert it and you have "outermost wins", a
  coherent alternative that no consumer wants. `rnd-face-plain` is what a caller
  would change to render a whole tree onto a themed background.
- **Deliberately omitted:** the four unchanged arms of `render-to-ansi`, the
  mechanical `amb` threading through `render-lines`/`render-row`/`render-table`/
  `rnd-emit-rows`/`rnd-emit-one-row`/`render-section`, and any change to
  `diff-node`, `rnd-cols`, `apc.chiral`, or `prog/`.

## 6. Use / modify notes

- **Lands in:** `lib/protocol/render.chiral`, **and three probe programs inside
  `tools/test/row.sh`** — see the second bullet; "nothing else" was wrong. Three new names
  (`face-join`, `rnd-face-plain`, `rnd-restore`) beside the face block; one
  trailing `Face` on nine signatures (`:99,103,105,107,109,111,115,117` and
  `render-row`'s at `:97`) and their bodies; six closes rewritten
  (`:569,610,624,687,705,721`); two seeds in `render-to-ansi-full` (`:725`) and,
  if it ever stops being a full redraw, `render-to-ansi-delta` (`:733`).
  **Not touched:** `rnd-cols` (`:473`) and its folds — E175 changes no width;
  `diff-node` (`:259`, declared `:67`); `lib/protocol/apc.chiral` — the codec
  transports the *value*, and the value is unchanged; all fourteen `prog/`
  construction sites — **no `prog/` file calls `render-to-ansi` at all**, only
  `render-to-ansi-full` (41 call sites) and `-delta`, whose signatures do not move;
  `command-loop:478,1546` (finding 8).

- **Conformance target — a new `tools/test/face.sh`, and every row reads the
  emitted byte stream.** A rendering defect that is invisible on screen cannot be
  graded by a shape assertion, and this repo has turned up six self-matching gate
  rows this session. `row.sh`'s screen reducer **discards SGR by construction**
  (its `ESC[<p>m` case is a documented no-op — that is what makes `rnd-cols`
  checkably invariant under E175), so `face.sh` carries its own reducer variant
  that tracks the SGR register set and emits **`row col bytes sgrset`** per
  painted cell. `row.sh`'s **reducer** stays unchanged — but **`row.sh` itself
  does not, and G7 said it did.** `tools/test/row.sh:236,241,305` call
  `render-to-ansi` with **seven** arguments, and G8's whole point is that a
  seven-argument call stops compiling; the two rows contradicted each other.
  Those three probe programs gain the trailing `rnd-face-plain` seed and nothing
  else. `diag.sh` and `doc.sh` name `render-to-ansi` nowhere and are genuinely
  untouched.

  | | row | mutant that must redden it |
  |---|---|---|
  | **G1** | **⚑ NO-OP where the tree already works — ON THE SCREEN, not in the bytes.** The fourteen live shapes — `(r-face f (r-text …))`, bold and plain, at depth 0, **each followed on the same row by an unfaced `r-text`** — reduce to a **cell map identical** to the pre-E175 build, `row col bytes sgrset` for every painted cell, golden taken from a pristine `lib/` copy the way `mutlib` takes a mutated one. **The byte streams are NOT identical and no row may assert that they are** (finding 5, measured: the faced leaf's close gains `face-sgr f`). The trailing unfaced sibling is not decoration — without a cell painted *after* the faced node, this row's own mutants paint nothing different and the row is self-matching. | seed `render-to-ansi-full` with a non-plain face (the trailing sibling then carries the seed's SGR); or drop `str-cat ansi-reset` from `rnd-restore` (the trailing sibling then carries `f`'s SGR) |
  | **G2** | **Finding 1B, the defect itself.** In `(r-face "keyword" (r-row [(r-text "ab") (r-text "cd")]))`, cell `(3,3)` = `c` carries SGR set `{1,31}`. Today it carries `{}`. | revert `r-text`'s close to `put ansi-reset` — and note this mutant **passes** any fix scoped to the `r-face` arm, which is the point of §1 |
  | **G3** | **Finding 1D, without `r-row`.** Same, through `r-lines`: cell `(8,1)` = `a` carries `{1,31}`. Proves the fix predates and outlives E174. | the same revert |
  | **G4** | **Finding 1C, the join — and it needs a bigger fixture than the brief's, measured.** ⚑ `face-join` feeds `rnd-restore` and **nothing else**; an open is always `face-sgr` of the *looked-up* face, never the join. So the only cell that reads a join is **the leaf after another leaf inside the same inner face** — the first leaf is painted straight off the two opens and carries `{1,32}` on the UNFIXED tree too. An inner face with **one** leaf grades nothing. Two shapes, because the fg rule and the attrs rule are convicted by different inner faces: **(a)** `(r-face "keyword" (r-row [(r-face "comment" (r-row [(r-text "xy") (r-text "zw")])) (r-text "pq")]))` — `keyword (1 -1 1)`, `comment (2 -1 0)` — `x,y,z,w` = `{1,32}`, `p,q` = `{1,31}`; **(b)** the same with `manas-cursor (-1 -1 8)`, an inner face with **no fg opinion** — `x,y,z,w` = `{1,7,31}`, `p,q` = `{1,31}`. Unfixed, `z,w,p,q` are `{}` in both. | measured, all three convict and each at a named cell: `oat` for `(bor oat iat)` → (a) `z,w`→`{32}`, `p,q`→`{31}`; (b) `z,w`→`{31}`; `ofg` unconditionally → (a) `z,w`,`p,q`→`{1}`; (b) `z,w`→`{1,7}`; `ifg` unconditionally → **(a) is completely unchanged** and only (b) convicts, `z,w`→`{1,7}` — which is why shape (b) is not optional |
  | **G5** | **Depth 0 emits exactly `\e[0m`** — no trailing `\e[m`, no doubled parameters. The literal byte tail of a depth-0 close is `27 91 48 109`. ⚑ **Raw bytes, not the cell map**: a trailing SGR paints no cell, so the tracking reducer cannot see this and this row must `od` the tail. | give `rnd-face-plain` a set attr bit |
  | **G6** | **`r-hole` is unchanged** — it opens no SGR and closes with none. The control that shows the edit was not a blanket sed. ⚑ Also **raw bytes**: `(r-face f (r-lines [(r-hole "h") (r-text …)]))` must emit `r-hole`'s `\e[0m`-free close verbatim. Under the cell map alone the mutant is invisible, because `(rnd-restore amb)` there restores the very face already on. | make `r-hole` call `rnd-restore` |
  | **G7** | **`rnd-cols` is invariant, and the OTHER gates hold.** Every `rnd-cols` value in `row.sh`'s G4 is unchanged, and `row.sh` passes with **its three probes' only edit being the added `rnd-face-plain` seed** (`:236,241,305` — see above; the claim that row.sh is byte-unchanged was false and contradicted G8). `diag.sh` (E157) and `doc.sh` (E158) pass **byte-unchanged** — neither names `render-to-ansi`. | any `rnd-cols` edit; already covered by `row.sh`'s own mutants |
  | **G8** | **The nine signatures moved together.** `render-to-ansi` with seven arguments does not compile — the arity is the coverage check here, the way the closed sum is `row.sh`'s. | drop `amb` from one walker's declare only |

  Fixture placement follows E174: the probe nodes are spelled **once** and
  interpolated into the emit probe, written outside the source tree, so the
  measured SGR and the measured layout cannot be reading two fixtures.

- **Open questions — the honest residue. Nothing here is deferred to an element
  that does not exist; where a follow-on would be needed I say so and stop.**

  1. **⚑ Under delta semantics a face cannot turn anything off, and `"default"`
     stops meaning "plain".** `face-sgr (face "default" -1 -1 0)` is `""`, so
     `(r-face "default" body)` becomes a no-op inside a `keyword`, where today's
     full reset accidentally gives it teeth at the close. `lookup-face` returns
     that same face for an **unknown name**, so a typo and an explicit `"default"`
     are indistinguishable — also true today, but today nobody nests so nobody
     notices. Three dispositions, none free: (i) accept it, and document that
     `-1` means *no opinion*; (ii) give `Face` a fourth field — an attrs *clear*
     mask — so a face can say "not bold"; (iii) treat the literal name
     `"default"` as a reset-to-plain, which is a magic string and a boundary-sum
     violation. §5 takes (i). **The author's call**, and (ii) is a constructor
     change with its own element if it is wanted.
  2. **The redraw hazard is real and not yet reachable (finding 7).** A face is now
     context-dependent, so a subtree's correct bytes depend on its ancestors —
     while `diff-node`'s `r-face` arm (`:306`) hands back a `diff-changed` payload
     stripped of the face it was found under. `render-to-ansi-delta` is a full
     redraw today, so nothing renders that payload alone. The day it does, either
     the payload carries its ambient face or the delta path must re-walk from a
     face boundary. **No number is invented for it here**; it is a hazard on the
     record, and the spec run should decide whether to mint one.
  3. **Five of the six closes are ad-hoc faces (finding 2)** — a hardcoded
     `ansi-bold` the registry does not know about, in `rnd-emit-headers`,
     `render-section`, `render-tree`'s selection, `r-text`'s `bold` field and
     `r-stream`. E175 fixes their *closes* and leaves them ad-hoc, because turning
     them into registry faces changes what those five draw and touches `r-text`'s
     constructor. That is a real element and **this pre-run cannot mint one** — so
     it is named, not shelved, and not pointed at a number.
  4. **The dead `prev` parameter (finding 6)** is left in place. Deleting it is
     right and unrelated; doing it inside E175 would make G1's cell-map row grade
     two changes at once.
  5. **Does the *open* need to change too?** §4.2 says no. ⚑ The ground it used
     to stand on — *delta leaves the live consumers' bytes alone and replacement
     would not* — **is gone**: finding 5 measures that delta changes the close
     bytes of every faced leaf too. What survives: the open stays a function of
     the looked-up face **alone**, so opening a face needs no ambient in hand;
     replacement would emit `\e[0m` plus the full resolved join at every open, i.e.
     strictly more bytes and a second use of the join, for the identical screen.
     Recorded so the spec run rejects it deliberately rather than never
     considering it.

- **Related:** [[E174-r-row-width]] (built; supplies the `r-row` that makes case B
  reachable a second way, and whose `rnd-cols` is provably invariant here) ·
  [[E158-doc-formatter]] (commit 4, `doc->rendering` — the forcing consumer, and
  it does *not* nest) · [[E157-typed-diagnostics]] (`dg-doc`'s `Reason` sum, whose
  gate must not move) · E177 (display width, `LEDGER.md:296`) and E178
  (`r-table` columns, `LEDGER.md:297`) — both minted, both in `render.chiral`,
  neither touched here.
