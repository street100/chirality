---
element: E14
slug: pretty-printer
title: Pretty-printer (display, non-trusted)
kind: SELF-HOST
reference_class: OURS
ours_source: scaffold/chirality/pretty.py
status: drafted
updated: 2026-08-01
---

# E14 — Pretty-printer (display, non-trusted)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E14, the term/value **pretty-printer** — `show-term` (render a core
  `Term` to its surface s-expression) and `show-value` (quote a value to a term,
  then render it). Display only.
- **Kind:** SELF-HOST — port `scaffold/chirality/pretty.py` (59 lines) to chirality source.
- **Why chirality needs its own:** to shrink the TCB — but E14 is the *low-stakes*
  member of the checker stack, and that is exactly its point. The printer is
  **non-trusted**: nothing in the judgment path (eval/conv/subtype/infer/check)
  consults it; the kernel calls `show-value` only when *raising* an error, so a
  bug here changes a message, never a verdict. Self-hosting it shows that even the
  component that could not unsound the checker is still held to the full
  discipline — no exemption from the type (P2).

## 2. Research

- **Reference class:** `OURS` — `scaffold/chirality/pretty.py` (the whole file is the
  baseline; it *is* the port source, so no external transcription).
- **Key findings:**
  1. **`show-value` = quote ∘ render.** `show_value(sig,lvl,v)` reifies the value
     to a term with the kernel's `quote` (E3's NbE) and hands it to `show_term` —
     so the only trusted-core dependency is `quote`; the renderer itself is a pure
     `Term → Str` walk.
  2. **de-Bruijn → names is a threaded list.** `show_term` carries a `names` list;
     a `Var i` renders as `names[len-1-i]`, and an **out-of-scope** index renders
     as `#i` — a graceful fallback, never an error (the printer is total over
     *every* term, well-scoped or not).
  3. **Each former → one s-expr shape.** `Pi`→`(-> (q x dom) cod)` (or `=>` when
     the effect bit is set), `Lam`→`(lam (x) body)`, `App`→`(f a)`, `Let`, `TCon`/
     `Con` (bare name when no args), `Refine`→`{base | v op operand, …}`. It is the
     inverse of E1's reader.
  4. **Two honest elisions in OURS:** `Case` renders opaquely as `(case ...)`, and
     a final `<{k}>` catch-all covers any unhandled tag — the exact spots a closed
     `data Term` + exhaustive `case` make unnecessary.

## 3. Conventional (other-language) approach

How `scaffold/chirality/pretty.py` does it — tag-dispatch with f-strings:

```python
def show_term(t, names=None):
    if names is None: names = []
    k = t[0]
    if k == "Var":
        i = t[1]
        return names[len(names) - 1 - i] if i < len(names) else f"#{i}"
    if k == "Lam":
        return f"(lam ({t[1]}) {show_term(t[2], names + [t[1]])})"
    if k == "App":
        return f"({show_term(t[1], names)} {show_term(t[2], names)})"
    # … Pi / Let / TCon / Con / Refine …
    if k == "Case":
        return "(case ...)"                 # opaque elision
    return f"<{k}>"                          # silent catch-all for any other tag
```

- **Assumptions it bakes in:** an **untyped tuple union** matched by `elif`, with a
  `<{k}>` **silent catch-all** — a new term former with no branch renders as `<k>`
  at *run* time instead of failing at build; **positional-tuple partiality**
  (`t[1]`/`t[2]` index into tag-dependent arities — a malformed node is an
  `IndexError`); and **no guard against I/O or non-termination** — nothing in the
  signature says a "display" function does not touch the world or hang.

## 4. The chirality idea

- **Chirality features in play:** closed `data` + exhaustive `case` (E6 coverage); the
  `->` pure membrane; totality by structural recursion; the I64 floor (`Var`
  indices, `#i`, universe levels are `I64`); categories A/B/C (this is A, but the
  *least* load-bearing A).
- **The reframing:** `show-term` becomes a **pure, total `Term → Str`** function
  over a closed `Term` sum. Tag dispatch is a coverage-checked `case`, so the
  `<{k}>` catch-all *cannot exist* — every former has a branch or it does not
  compile. The `names` list is an explicit `(List Str)` threaded down (extended
  under each binder), and the out-of-scope `#i` fallback stays a returned string,
  keeping the function total over *all* terms. `show-value` calls `quote` (E3) then
  `show-term` — the one trusted-core touch, and it adds nothing to the TCB.
- **What chirality makes impossible here:** a term former the printer **forgot**
  (coverage turns OURS's `<k>` into a compile error); a display function that
  **hangs** (structural recursion is total); a "printer" that **secretly performs
  I/O** (it is `->` — a `show-*` that logs to a file or opens a socket is
  untypeable); and a **crash on a malformed term** (the closed sum has no malformed
  inhabitant; an out-of-scope variable renders `#i`, it does not throw). The point
  is the *stakes*: the component that could never unsound the checker still gets
  totality, coverage, and effect-freedom **for free** — "it is just display" is not
  an exemption.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready. A
representative former subset; the rest (`t-pi`/`t-tcon`/`t-con`/`t-refine`/
`t-case`/`t-global`) are the same walk with more arms (coverage forces each).

```chirality
(import "prelude")   ; List, Str, I64, str-cat, i64->str, nil/cons

; the core term sum this renders (subset; from E01/E03/E13). The FULL set adds
; t-pi / t-tcon / t-con / t-refine / t-case / t-global -- same shape, more arms.
(data Term ()
  (t-type (n I64))                      ; universe:  (type n)
  (t-var  (i I64))                      ; de-Bruijn index
  (t-lam  (name Str) (body Term))       ; body sees 1 new binder
  (t-app  (fn Term) (arg Term))
  (t-let  (name Str) (rhs Term) (body Term)))

; display helpers, forward-declared (mechanical string plumbing):
;   sp a b     = a ++ " " ++ b        parens s = "(" ++ s ++ ")"
;   names-snoc = append one name      nth-name = names[len-1-i], else "#i"
; nth-name's fallback is why the printer is TOTAL over every term, in-scope or
; not -- an out-of-range index renders "#i", it never errors.
(declare sp        (-> Str Str Str))
(declare parens    (-> Str Str))
(declare names-snoc (-> (List Str) Str (List Str)))
(declare nth-name  (-> (List Str) I64 Str))

; show-term : names -> Term -> Str. PURE (->): a display function provably crosses
; no port, so a "printer" that writes a file is untypeable. TOTAL: structural
; recursion on Term. EXHAUSTIVE: a new former with no arm is a COMPILE error --
; there is no `<k>` catch-all (OURS pretty.py:105) to hide it.
(declare show-term (-> (List Str) Term Str))
(def show-term                          ; type from the declare above
  (lam (names t)
    (case t
      ((t-type n)     (parens (sp "type" (i64->str n))))
      ((t-var i)      (nth-name names i))                 ; names[len-1-i] or "#i"
      ((t-lam nm b)   (parens (sp "lam" (sp (parens nm)
                        (show-term (names-snoc names nm) b)))))
      ((t-app f a)    (parens (sp (show-term names f) (show-term names a))))
      ((t-let nm r b) (parens (sp "let"
                        (sp (parens (sp nm (show-term names r)))
                            (show-term (names-snoc names nm) b))))))))

; show-value : quote the value to a term (E03's NbE quote), then render. The one
; trusted-core touch -- and show-* itself adds nothing to the TCB.
(declare Value (type 0))                ; opaque here (E03/E04)
(declare quote (-> I64 Value Term))     ; E03 (NbE); opaque here
(def show-value (-> I64 Value Str)
  (lam (lvl v) (show-term nil (quote lvl v))))
```

- **Knobs to modify:** the `Term` former set (add `t-pi`/`t-con`/`t-refine`/… to
  reach `pretty.py` parity — coverage forces the matching arm); how much of a
  `t-case` to render (OURS punts with `(case ...)` — a knob toward a full arm
  print); the name-collision policy in `names-snoc` (OURS does none); whether
  `show-value` takes a value (calling `quote`) or an already-quoted `Term`.
- **Deliberately omitted:** the string plumbing (`sp`/`parens`/`names-snoc`/
  `nth-name` bodies — mechanical `str-cat`); the full former table beyond the
  subset; and any width-aware/indenting layout (OURS is flat s-expr, no
  line-breaking).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/pretty.chiral` (new), replacing `scaffold/chirality/pretty.py`.
  Reached only on the kernel's error path (`show-value` at a raised error), so it
  stays **out of the judgment path** — the non-trusted-display line drawn as
  cleanly as OURS keeps it (a separate file from the judgment).
- **Conformance target:** reproduce `pretty.py`'s rendered strings on golden
  terms — the same s-expr per former, the same `names` threading under binders, the
  same `#i` for an out-of-scope `Var`, and the same opaque `(case ...)` for `Case`.
  Differential vs `pretty.py.show_term` over a term corpus.
- **Open questions:** (a) does `show-value` keep the `quote` dependency (E03) or
  take an already-quoted term, so the renderer is `quote`-free? (b) how much of a
  `Case` to render (OURS's `(case ...)` elision vs full arms); (c) width-aware
  layout — out of scope now, but the first thing a *human-facing* printer (vs the
  error-path one) would add.
- **Related:** [[E03-nbe-normalize]] (the `quote` `show-value` calls) ·
  [[E13-debruijn]] (the `Term`/index machinery walked) · [[E01-sexp-reader]]
  (this is its inverse — un-parsing a `Term` to the s-expr the reader parses) ·
  [[E24-i64-arith]] (the I64 index/level floor).
