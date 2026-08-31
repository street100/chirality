---
element: E101
slug: sexp-error-context
title: Sexp-reader error context — line/column, depth, and last-opened-form on parse failures
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-09
---

# E101 — Sexp-reader error context

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E101, enhance the chirality-native sexp reader + surface parser to
  report source location (line:column), nesting depth, and the identity of the
  last successfully opened form on parse failures.
- **Kind:** BUILD-PROPER — a designed feature not yet built. The E1 reader
  already exists and works; this adds diagnostics to it.
- **Why chirality needs its own:** B1 (the native compiler) currently produces
  opaque parse errors like `unexpected )` and `(lam (x ...) body)` with NO
  source location. The Python checker gives line numbers for type errors, but
  parse errors (from B1's own `sexp.chiral` + `parse.chiral`) carry no location.
  This makes debugging chirality source extremely painful — a single paren error in
  a multi-thousand-form blob requires form-level binary search (see
  `chirality-dev-patterns`). The reader already tracks byte position (`pos I64` in
  `RR`/`AllR`); we extend it to compute line:column from that offset, track
  nesting depth, and name the last opened form.

## 2. Research

- **Reference class:** `OURS` — this is a refinement of our own E1 reader,
  informed by our own debugging pain points.
- **Key findings:**
  1. **GCC/clang/rustc pattern:** diagnostic messages cite file:line:col and
     often include a "note: in expansion of macro X" for context. Our
     equivalent is the last-opened-form stack — when `read-list` encounters an
     unbalanced `)`, we know which `(data ...)`, `(def ...)`, or `(case ...)`
     was being read.
  2. **Python `sexp.py` position tracking:** the existing Python reader tracks
     line/col natively (`pos_line`, `pos_col` attributes on the tokenizer
     cursor). The chirality port (E1 `sexp.chiral`) simplified this to byte offset
     only. The enhancement adds line/col computation back.
  3. **The format string approach:** Rather than changing `RR`/`AllR`/`PR`
     type shapes (which would cascade through the entire compiler), we embed
     line:col:depth:form-name into the error message STRING. This is a
     pragmatic choice for a diagnostics feature — the error message IS the
     human-facing surface.

## 3. Conventional (other-language) approach

Python's `sexp.py` (the current oracle) tracks position explicitly:

```python
class Reader:
    def __init__(self, src):
        self.src = src
        self.pos = 0
        self.line = 1
        self.col = 1

    def advance(self):
        if self.src[self.pos] == '\n':
            self.line += 1
            self.col = 1
        else:
            self.col += 1
        self.pos += 1
```

- **Assumptions it bakes in:** mutation (`self.pos += 1`), imperative
  line/col tracking, exceptions for errors. The chirality port must be pure
  (position threading), errors-as-values (`r-err`), and structural recursion.

## 4. The chirality idea

- **Chirality features in play:**
  - **Purity (`->`):** The reader is already pure; position computation stays
    pure — `pos->line` is a pure fold over bytes.
  - **Errors as values:** `RR` and `AllR` already carry error messages; we
    enrich the message string without changing the sum type.
  - **Totality:** Structural recursion over `Bytes`. Every read either
    succeeds or returns an error value.
  - **Boundary sums:** The `read-list` tracking of "last opened form" uses
    a structured context stack rather than a flat count.

- **The reframing:** Instead of mutable line/col fields, we compute
  line:column from byte offset via a pure scan of the source bytes (counting
  `\n` occurrences). The depth and last-opened-form are threaded as
  parameters through the recursive read calls. On error, the error message
  string includes all context.

- **What chirality makes impossible here:** untracked position — every error
  carries its source location by construction; unstructured depth — the
  form stack preserves the identity of the containing form.

## 5. Chirality example (fleshed)

```chirality
; ---- position helpers: byte offset -> line:col -------------------------
; Count newlines in b[0..pos) to get the 1-based line number, then scan
; backward from pos to the last newline for the 1-based column.
(def pos-line (-> Bytes I64 I64)
  (lam (b pos)
    (let (p (case (<i pos (blen b)) (true pos) (false (blen b))))
      (pos-line-go b 0 p 1))))

(declare pos-line-go (-> Bytes I64 I64 I64 I64))
(def pos-line-go (lam (b i end acc)
  (case (<i i end)
    (false acc)
    (true (case (=i (bget b i) 10)  ; \n = 10
            (true (pos-line-go b (+ i 1) end (+ acc 1)))
            (false (pos-line-go b (+ i 1) end acc)))))))

(def pos-col (-> Bytes I64 I64)
  (lam (b pos)
    (let (p (case (<i pos (blen b)) (true pos) (false (blen b))))
      (pos-col-go b (- p 1) 1))))

(declare pos-col-go (-> Bytes I64 I64 I64))
(def pos-col-go (lam (b i acc)
  (case (<i 0 i)
    (false acc)
    (true (case (=i (bget b i) 10)
            (true (+ acc 1))
            (false (pos-col-go b (- i 1) (+ acc 1))))))))

; Format a position as "line:col"
(def fmt-pos (-> Bytes I64 Str)
  (lam (b pos)
    (str-cat (i64->str (pos-line b pos))
             (str-cat ":" (i64->str (pos-col b pos))))))

; ---- enhanced read-form / read-list with depth + last form ------------
; read-form* carries: source bytes b, byte offset i, nesting depth d,
;                   last-opened-form context stack (List Str).
; The stack is: [innermost ... outermost], or nil for top-level.

(declare read-form* (-> Bytes I64 I64 (List Str) RR))
(declare read-list* (-> Bytes I64 I64 Str (List Str) (List Sexp) RR))

(def read-form*
  (lam (b i0 depth ctx)
    (let (i (skip-trivia b i0))
      (case (<i i (blen b))
        (false (r-err (str-cat "unexpected end of input at "
                               (str-cat (fmt-pos b i0)
                                        (str-cat " depth="
                                                 (i64->str depth))))
                      i))
        (true (let (c (bget b i))
                (case (=i c CH-LPAREN)
                  (true (read-list* b (+ i 1) (+ depth 1) "(" (cons "(" ctx) nil))
                  (false (case (=i c CH-RPAREN)
                           (true (r-err (str-cat "unexpected ) at "
                                                 (str-cat (fmt-pos b i)
                                                          (str-cat " depth="
                                                                   (i64->str depth))))
                                        i))
                           (false (case (=i c CH-DQUOTE)
                                    (true (read-string b (+ i 1)))
                                    (false (read-atom b i)))))))))))))

; read-list*: same as read-list but carries depth + last-opened-form.
; When the first element of what we're reading is a symbol, push it as
; the "last opened form" for context on nested errors.
(def read-list*
  (lam (b i depth last-form ctx acc)
    (let (j (skip-trivia b i))
      (case (<i j (blen b))
        (false (r-err (str-cat "unclosed ( at "
                               (str-cat (fmt-pos b (- i 1))
                                        (str-cat " depth=" (i64->str depth)
                                                 (str-cat " inside " last-form))))
                      j))
        (true (case (=i (bget b j) CH-RPAREN)
                (true (r-ok (s-list (reverse Sexp acc)) (+ j 1)))
                (false (case (read-form* b j depth ctx)
                         ((r-err m p)
                           ; inject parent-form context into the error
                           (r-err (str-cat m (str-cat " (inside "
                                                       (str-cat last-form ")")))
                                  p))
                         ((r-ok f p)
                           ; update last-form: if this is the FIRST element
                           ; (acc is nil) and f is a symbol, use it
                           (let (new-last (case acc
                                            (nil (case f
                                                   ((s-sym nm) nm)
                                                   (_ last-form)))
                                            (_ last-form)))
                             (read-list* b p depth new-last ctx
                                        (cons f acc)))))))))))))

; Backward-compatible entry points: wrap the enhanced versions.
(def read-form (-> Bytes I64 RR)
  (lam (b i) (read-form* b i 0 nil)))

(def read-list (-> Bytes I64 (List Sexp) RR)
  (lam (b i acc) (read-list* b i 0 "" nil acc)))
```

- **Knobs to modify:** The position format string (line:col, col:line, or
  "L123 C45"). The depth inclusion (may truncate for very deep nesting).
  The ctx stack (currently used only for one level; future: full stack dump).
- **Deliberately omitted:**
  - `i64->str` — a helper to convert I64 to Str (exists elsewhere or must be
    built as `digits->str`; the chirality `pack-u32`+`bytes->str` idiom works).
  - Full form-stack reporting — currently we report only the parent form,
    not the full ancestry chain. Adding a full stack is a follow-up.
  - `PR` type changes — surface parse errors remain `p-err (msg Str)` with no
    position; we enhance them only at the `load-source` gateway where sexp
    positions are available.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/sexp.chiral` (replace `read-form`/`read-list`
  with `read-form*`/`read-list*`, add `pos-line`/`pos-col`/`fmt-pos` helpers).
  `scaffold/lib/parse.chiral` (enhance `load-source` to include position in
  sexp-level errors; optionally enhance surface parse errors).
- **Conformance target:** The existing `chirality test` + `chirality test-native` must
  pass unchanged — all existing parse paths must produce identical ASTs.
  The error message strings CHANGE (now include location) but the error
  conditions remain the same.
- **Open questions:**
  - Should `PR` (`surface.chiral`) gain a position field? That would touch
    every function in the elaboration pipeline. Current decision: NO —
    keep `PR` unchanged and enhance only the gateway (`load-source`).
  - Should `i64->str` be a new helper or reuse existing `pack-u32`?
    Decision: define a local `digits->str` in `sexp.chiral` mirroring the
    existing `digits->i64` pattern.
- **Related:** [[E01-sexp-reader]] (the base reader this enhances).
