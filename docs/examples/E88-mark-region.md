---
element: E88
slug: mark-region
title: Mark + region system: mark-ring, mark (saved cursor position), region (text between point and mark), set-mark, exchange-point-and-mark, kill-region, copy-region — wires the existing kill-ring into real region operations
kind: BUILD-PROPER
reference_class: OURS/IMPL
ours_source: (none)
status: drafted
updated: 2026-08-08
---

# E88 — Mark + region system

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E88, mark + region system for the scriba editor — a mark ring
  (saved cursor positions), a current mark, region extraction (text between
  point and mark), and region-aware kill/copy operations that feed the existing
  kill-ring.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** scriba currently has a kill-ring
  (`scriba/kill-ring.chiral` — a LIFO stack of killed strings) and line-level
  kill operations (`str-kill-line`, `str-kill-lines` in
  `scriba/str-edit.chiral`) but no mark to define a region and no
  `kill-region`/`copy-region` to extract arbitrary ranges. The kill-ring is
  wired but has nothing to kill except whole lines. Every real editor needs
  region selection to be useful.

## 2. Research

- **Reference class:** OURS/IMPL — Emacs mark ring as the behavioral model;
  our own `scriba/kill-ring.chiral` as the integration target.
- **Key findings:**
  1. **Emacs mark ring** (Elisp manual §31.8): The mark ring is a global LIFO
     stack of saved buffer positions. `set-mark-command` (C-SPC) pushes the
     current point onto the mark ring and activates the mark. `pop-to-mark`
     (C-u C-SPC) cycles backward through the ring. The region is defined as
     text between point and mark — there is no separate "region" data
     structure; it's always point↔mark.
  2. **Region semantics:** `kill-region` (C-w) deletes text between point and
     mark and pushes it onto the kill-ring. `kill-ring-save` (M-w) copies
     without deleting. The region is not "active"/"inactive" in the minimalist
     design — it always exists (point and mark define it) and operations
     decide whether to use it.
  3. **Our kill-ring integration:** `scriba/kill-ring.chiral` has
     `kill-ring-push` (Str → KillRing → KillRing), `kill-ring-top` (KillRing →
     Maybe Str), and `kill-ring-empty?` (KillRing → Bool). The yank operation
     in `str-edit.chiral` reads from a `(List Str)` ring head. Region kills
     feed into this same ring — `kill-region` pushes the killed text onto the
     KillRing and returns both the mutated buffer and the updated ring.
  4. **Pure functional state threading:** scriba's command loop threads all
     state through recursion — `(=> Keymap (Puffer Str) (Pair I64 I64) …)`.
     The mark and mark-ring are additional parameters in this chain, never
     mutable globals. This matches chirality's membrane: the mark is pure data
     (a `TextZipper Str` snapshot), and operations are pure `->` functions.

## 3. Conventional (other-language) approach

How Emacs does it in C (simplified from `src/marker.c`, `src/editfns.c`):

```c
/* Emacs: mark is a mutable buffer position, region is implicit */
struct Lisp_Marker {
    struct buffer *buffer;   /* owning buffer */
    ptrdiff_t charpos;       /* character offset */
    /* ... insertion-type, next, etc. */
};

/* set-mark: mutates the current buffer's mark */
void set_mark(struct buffer *b, ptrdiff_t charpos) {
    b->mark->charpos = charpos;   /* in-place mutation */
    b->mark_active = 1;           /* side-effect: activate mark */
}

/* kill-region: extracts between point and mark, mutates kill-ring */
Lisp_Object kill_region(struct buffer *b) {
    ptrdiff_t start = min(b->pt, b->mark->charpos);
    ptrdiff_t end   = max(b->pt, b->mark->charpos);
    Lisp_Object text = make_string(b->text + start, end - start);
    del_range(start, end);                   /* mutation */
    b->kill_ring = Fcons(text, b->kill_ring); /* mutation */
    return text;
}
```

- **Assumptions it bakes in:** mutable buffer state (mark, point, kill-ring
  are all mutated in place via pointer writes), implicit global state (the
  "current buffer" is ambient), no type-level distinction between pure
  position arithmetic and effectful buffer mutation, mark activation is a
  side-effect flag rather than a data flow.

## 4. The chirality idea

- **Chirality features in play:**
  - **Pure `->` vs process `=>`:** All mark/region operations are pure
    functions on immutable data — `Mark` is a `TextZipper Str` snapshot,
    `MarkRing` is a `List (TextZipper Str)`. Only the command loop (effectful
    `=>`) calls them and threads the results.
  - **QTT quantities:** The `TextZipper` type parameter `A` is erased (`0 A
    (type 0)`) — positions are pure data with no linear resources.
  - **Result types as sum types:** Operations that can fail (e.g. region on an
    unset mark) return `Maybe` or a result sum — no exceptions, no nil
    sentinels.
  - **Categories A/B/C:** All mark/region types live in category A (fully
    typed, provably correct). No raw pointer arithmetic.

- **The reframing:**
  - **Mark as zipper snapshot:** Instead of a mutable `charpos` integer, the
    mark is a `TextZipper Str` — a self-contained cursor position that
    captures the full buffer context (above/left/right/below). Two zippers
    define a region; comparing their positions determines start and end.
  - **Mark ring as immutable LIFO:** Reuses the `kill-ring` pattern — a
    `List Mark` with optional max capacity. Operations return new
    rings, never mutate.
  - **Region as pure extraction:** `region-between` is a pure `->` function that
    takes two `TextZipper Str` values and returns the substring between them —
    no side effects, no "activation" flag.
  - **Kill-region composes existing pieces:** `kill-region` = `region-between` →
    `str-delete-forward`. The kill-ring integration is the command loop's
    concern — `kill-region` returns the killed text and updated buffer
    position; the command loop pushes onto the KillRing.

- **What chirality makes impossible here:**
  - No mutable global mark variable — every operation takes and returns marks
    explicitly.
  - No nil sentinel for "mark not set" — `Maybe (TextZipper Str)` makes
    absence a type-level fact.
  - No accidental region deletion without capturing the text — the return type
    includes the killed string, forcing the caller to handle it.

## 5. Chirality example (fleshed)

```chirality
; E88 — Mark + region system for scriba.
; Pure functional design: all types are immutable data, all operations are
; pure (->) functions. The effectful command loop threads these through.
;
; Deps: prelude (I64, Str, Bool, Unit, List, Maybe, Pair)
;       scriba/str-edit (TextZipper, LineCtx, zipper-to-text, advance-by,
;                         str-insert-char, str-delete-forward, str-delete-backward)
;       scriba/kill-ring (KillRing, kill-ring-push, kill-ring-top)
;
; Lands in: scaffold/lib/scriba/mark-region.chiral (~80 lines)

(import "prelude")
(import "str-edit")    ; TextZipper, LineCtx, zipper-to-text, advance-by,
                       ; text-zipper-from-str, str-delete-forward, str-len, str-sub
(import "kill-ring")   ; KillRing, kill-ring-push — for command-loop integration comment

; ---------------------------------------------------------------- Types

; Mark: a saved cursor position — a TextZipper Str snapshot.
; The mark captures the full buffer context (above, left, right, below)
; at the moment it was set. Two marks define a region.
(data Mark ()
  (mark-at (zipper (TextZipper Str))))

; MarkRing: a bounded LIFO stack of marks.
; Pushed before long jumps; popped to return. Same pattern as KillRing.
(data MarkRing ()
  (mark-ring (marks (List Mark)) (max (Maybe I64))))

; ---------------------------------------------------------------- Mark operations

; Create an empty mark ring with optional max capacity.
(def mark-ring-new (-> (Maybe I64) MarkRing)
  (lam (max)
    (mark-ring nil max)))

; Push a mark onto the ring. If the ring exceeds max, drop the oldest entry.
(def mark-ring-push (-> Mark MarkRing MarkRing)
  (lam (m mr)
    (case mr
      ((mark-ring marks max)
        (let ((new-marks (cons m marks))
              (trimmed (mark-ring-trim max new-marks)))
          (mark-ring trimmed max))))))

; Trim marks to max capacity.
(def mark-ring-trim (-> (Maybe I64) (List Mark) (List Mark))
  (lam (max marks)
    (case max
      (none marks)
      ((some n) (mark-take n marks)))))

(def mark-take (-> I64 (List Mark) (List Mark))
  (lam (n xs)
    (case xs
      (nil nil)
      ((cons h t)
        (case (=i n 0)
          (true nil)
          (false (cons h (mark-take (- n 1) t))))))))

; Pop the most recent mark from the ring. Returns (Maybe Mark, MarkRing).
(def mark-ring-pop (-> MarkRing (Pair (Maybe Mark) MarkRing))
  (lam (mr)
    (case mr
      ((mark-ring marks max)
        (case marks
          (nil (pair none mr))
          ((cons h t) (pair (some h) (mark-ring t max))))))))

; Set the mark at the current cursor position (point).
; Returns a new Mark from the current zipper.
(def set-mark (-> (TextZipper Str) Mark)
  (lam (z)
    (mark-at z)))

; ---------------------------------------------------------------- Region operations

; Compute the character offset of a zipper position within the buffer.
; The offset is the number of characters before the cursor.
(def zipper-offset (-> (TextZipper Str) I64)
  (lam (z)
    (case z
      ((text-zipper focus (line-ctx above left right below))
        ; Sum lengths of all lines above + length of left text on current line
        (let ((above-len (sum-line-lengths above)))
          (+ above-len (str-len left)))))))

; Sum the lengths of lines in a list, counting newline separators.
(def sum-line-lengths (-> (List Str) I64)
  (lam (lines)
    (case lines
      (nil 0)
      ((cons h t) (+ (+ (str-len h) 1) (sum-line-lengths t))))))

; Extract the text between two positions in the buffer.
; The positions may be in any order — this returns text from the
; earlier position to the later position (the region).
; Returns (region-text, start-offset, end-offset).
(def region-between (-> (TextZipper Str) (TextZipper Str) (Pair Str (Pair I64 I64)))
  (lam (a b)
    (let ((off-a (zipper-offset a))
          (off-b (zipper-offset b))
          (full (zipper-to-text a)))  ; reconstruct full buffer text
      (case (<i off-a off-b)
        (true
          (let ((start off-a)
                (end off-b)
                (len (- end start)))
            (pair (str-sub full start len) (pair start end))))
        (false
          ; b is before a, or they're at the same position
          (case (<i off-b off-a)
            (true
              (let ((start off-b)
                    (end off-a)
                    (len (- end start)))
                (pair (str-sub full start len) (pair start end))))
            (false
              ; same position — empty region
              (pair "" (pair off-a off-a)))))))))

; Kill the region between mark and point.
; Extracts the text, deletes it from the buffer, returns the killed text,
; the updated buffer, and the new zipper positioned at the deletion point
; (the earlier of mark and point).
(def kill-region (-> Mark (TextZipper Str) (Pair Str (TextZipper Str)))
  (lam (mk pt)
    (case mk
      ((mark-at mk-z)
        (let ((rb (region-between mk-z pt)))
          (case rb
            ((pair killed (pair start-off end-off))
              (case (str-eq killed "")
                (true (pair "" pt))  ; empty region, no-op
                (false
                  ; Delete the region. We need to position at start and
                  ; delete forward by the region length.
                  ; Naive: delete character by character from the end offset
                  ; to the start offset.
                  ; Cleaner: reconstruct a new zipper at the start position.
                  (let ((new-z (zipper-at-offset start-off pt)))
                    (let ((killed-len (str-len killed)))
                      (let ((z-after (str-delete-forward killed-len new-z)))
                        (pair killed z-after)))))))))))))

; Copy the region between mark and point to a string (no deletion).
; Returns the text and the mark (unchanged).
(def copy-region (-> Mark (TextZipper Str) Str)
  (lam (mk pt)
    (case mk
      ((mark-at mk-z)
        (let ((rb (region-between mk-z pt)))
          (case rb
            ((pair killed (pair start-off end-off))
              killed)))))))

; Exchange point and mark — the old point becomes the new mark,
; returns (new-mark, new-point-where-old-mark-was).
(def exchange-point-and-mark (-> Mark (TextZipper Str) (Pair Mark (TextZipper Str)))
  (lam (mk pt)
    (case mk
      ((mark-at mk-z)
        (pair (mark-at pt) mk-z)))))

; Position a new zipper at a given character offset within the buffer,
; using the original zipper's text as the source.
; Advances from the beginning of the buffer to the target offset.
(def zipper-at-offset (-> I64 (TextZipper Str) (TextZipper Str))
  (lam (offset z)
    (let ((full (zipper-to-text z)))
      (let ((z0 (text-zipper-from-str full)))
        (advance-by offset z0)))))

; ---------------------------------------------------------------- Knobs to modify
; - MarkRing max capacity: pass (some 16) or none.
; - Region operations could be extended with `kill-ring-save` (copy without
;   delete, push to kill-ring explicitly).
; - `zipper-offset` is O(n) over the buffer — acceptable for interactive use
;   but a future optimization could cache line-lengths.

; ---------------------------------------------------------------- Deliberately omitted
; - Transient mark mode (region highlighting) — the rendering pipeline
;   (scriba/render.chiral) is not yet built (E# scriba-4).
; - Active/inactive mark distinction — the region always exists between
;   point and mark; operations decide whether to use it.
; - Mark stack integration with the command loop — the dispatch module
;   (scriba/dispatch.chiral) is blocked on B1's effect chain threshold and
;   cannot yet call op functions.
```

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/scriba/mark-region.chiral` — a new file alongside
  the existing `kill-ring.chiral`, `str-edit.chiral`, and `puffer.chiral`.
- **Conformance target:** Emacs mark-ring behavior (minimal subset):
  `C-SPC` sets mark, `C-x C-x` exchanges point and mark, `C-w` kills region
  (pushes to kill-ring), `M-w` copies region (pushes to kill-ring without
  deleting), `C-u C-SPC` pops the mark ring. The region text between any two
  positions must be byte-identical to the substring extracted from the
  reconstructed buffer text.
- **Open questions:**
  1. Should `zipper-offset` be cached in the TextZipper type to avoid O(n)
     per operation? (Decision: defer — correct first, fast later.)
  2. How does the mark ring integrate with the command loop's state threading?
     The `command-loop-inner` signature must grow to include `MarkRing` and
     `KillRing` parameters. This is the integration point with scriba-2
     (dispatch + B1 fix).
  3. Should `region-between` handle the case where the two zippers come from
     different buffers? (Decision: no — the type system doesn't distinguish
     zipper provenance; this is a runtime invariant documented in the
     function's contract.)
- **Related:** [[E88-mark-region]], kill-ring (`scriba/kill-ring.chiral`),
  str-edit (`scriba/str-edit.chiral`).
