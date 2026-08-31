---
element: E1
slug: sexp-reader
title: S-expression reader (lexer/parser)
kind: SELF-HOST
reference_class: OURS/IMPL
ours_source: scaffold/chirality/sexp.py
status: drafted
updated: 2026-07-12
---

# E1 — S-expression reader (lexer/parser)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E1, the reader that turns chirality surface source text into the
  S-expression tree (`(...)`, symbols, i64 literals, `"strings"`, `;` comments)
  that the elaborator (E2) consumes.
- **Kind:** SELF-HOST — it is Python (`sexp.py`, 95 lines) that must become
  chirality source so the front end stops depending on the host reader.
- **Why chirality needs its own:** every stage above it (E2 elaborator → E3/E4
  kernel) already has a chirality target; a host-Python reader is a permanent seam
  at the very bottom of the front end. Self-hosting it removes the last
  CPython dependency before elaboration and lets the surface syntax be defined
  in the language it parses.

## 2. Research

- **Reference class:** `OURS` (the port source `scaffold/chirality/sexp.py`) +
  `IMPL` (classic Lisp readers — the recursive-descent `read` shape).
- **Sources reviewed:** `scaffold/chirality/sexp.py` (the baseline); `scaffold/lib/json.chiral`
  lines 105–273 (the in-tree chirality parser that already demonstrates the target
  idiom — a recursive-descent parser over `Bytes` returning an explicit result
  sum with position); `scaffold/lib/prelude.chiral` (the `Str`/`Bytes` externs and
  `List`/`Pair`/`Maybe` types the reader builds on).
- **Key findings:**
  1. The whole reader is one tokenize pass + one recursive `_parse`. No lookahead
     beyond one token; a stack-free structural recursion on the token list.
  2. `json.chiral` already fixes the target idiom: a `data PR` result with
     `p-ok val pos` / `p-err msg pos` constructors, threaded position, **no
     exceptions** — errors are returned values. E1 is "do that, for s-exprs."
  3. Atoms disambiguate by *trying* an integer parse and falling back to symbol.
     In chirality that becomes an explicit total classify (all-digits? → i64) rather
     than a `try/except`.

## 3. Conventional (other-language) approach

The host reader (`sexp.py`) — a tokenizer plus a recursive parser — leans on
three Python conveniences chirality does not have:

```python
def _parse(toks, i):
    kind, val, line = toks[i]              # (a) partial: IndexError if i out of range
    if kind == "(":
        items = []
        i += 1
        while True:
            if i >= len(toks):
                raise ReadError("unclosed (", line)   # (b) exceptions as control flow
            if toks[i][0] == ")":
                return items, i + 1, line
            form, i, _ = _parse(toks, i)   # (c) returns heterogeneous Python objects
            items.append(form)
    ...
    try:
        return int(val), i + 1, line       # atom: int-or-symbol by try/except
    except ValueError:
        return Sym(val), i + 1, line
```

- **Assumptions it bakes in:**
  - **Partiality is ambient** — `toks[i]` can throw; nothing in the type says the
    index is in range, so "unclosed (" is caught at runtime, not ruled out.
  - **Exceptions as control flow** — `ReadError` unwinds the stack; the error
    channel is invisible in the signature `_parse(toks, i) -> (form, i, line)`.
  - **Heterogeneous result** — `form` is `list | int | Sym | ("#str", val)`, an
    untyped union CPython tolerates; the consumer pattern-matches on Python type.
  - **Mutation-flavored threading** — `i` is re-bound as a running cursor and
    `items.append` mutates in place.

## 4. The chirality idea

chirality makes the reader a **total, pure function returning an explicit result
sum** — the `json.chiral` shape, promoted to the surface reader.

- **Chirality features in play:**
  - **Effect membrane (`->`, pure).** Reading is `(-> Bytes I64 RR)`: bytes in,
    result out, **no ports touched**. The read is inert computation — no I/O
    capability is needed to parse, only to *fetch* the bytes. The membrane makes
    "the reader cannot do I/O" a typed fact, not a convention.
  - **Errors are values (ties E26 alarms).** No exception channel. Every outcome
    is a constructor of the result type `RR` (`r-ok form pos` / `r-err msg pos`),
    so the error path is in the signature and the caller must `case` on it.
  - **Totality (E11).** The parser recurses on a byte index that *advances*
    toward `blen` — a numeric measure (`blen − i` strictly decreases), bounded
    by the `(<i i (blen b))` guard; there is no unbounded `while True`.
    "Unclosed (" is a returned `r-err`, reached by the same total recursion,
    never a throw.
  - **Closed sum for the tree.** The s-expr node is a `data Sexp` with named
    constructors (`s-list`, `s-sym`, `s-i64`, `s-str`) instead of an untyped
    Python union — the elaborator (E2) then `case`s exhaustively, coverage-checked.
  - **Bytes/I64 floor (E24/E25).** Source is `Bytes`, cursor is `I64`, atom
    classification is explicit i64 predicate + `str->i64`; no host `int()`.
- **The reframing:** the cursor is *threaded* (returned in the result), not
  mutated; the token stream can be fused into the parser (byte-directed
  recursive descent, as `json.chiral` does) so there is no intermediate mutable
  token list at all.
- **What chirality makes impossible here:** silently throwing past the caller;
  returning a value whose shape the consumer can't see in the type; a reader that
  quietly performs I/O; a non-terminating parse.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, in the `json.chiral` idiom.
Copy this skeleton; fill the byte-level scanners marked `; …`.

```chirality
; E1 skeleton: byte-directed s-expression reader. Pure (->), total, errors
; as values. Mirrors scaffold/lib/json.chiral's PR/parse-value shape.
(import "prelude")

; The surface tree the elaborator (E2) consumes. Closed sum: four node kinds,
; exhaustively case-able. (No untyped union.)
(data Sexp ()
  (s-list (items (List Sexp)))
  (s-sym  (name Str))
  (s-i64  (val I64))
  (s-str  (text Str)))

; Read-result: success carries the node and the next cursor; failure carries a
; message and the position it was detected. This is the whole error channel --
; there is no exception. (Compare json.chiral's `data PR`.)
(data RR ()
  (r-ok  (form Sexp) (pos I64))
  (r-err (msg Str)   (pos I64)))

; Skip spaces, tabs, newlines, and `;'-to-end-of-line comments; return the next
; significant index. Total: recurses on a strictly-larger i bounded by (blen b).
(declare skip-trivia (-> Bytes I64 I64))

; Read one atom starting at i (symbol or i64 literal), classifying by content:
; all-digits (with optional leading '-') -> s-i64 via str->i64, else s-sym.
(declare read-atom (-> Bytes I64 RR))

; Read the elements of a list until the matching `)'. Threads the cursor through
; each element; an unbalanced paren returns r-err, never a throw.
(declare read-list (-> Bytes I64 (List Sexp) RR))

; Read a "..."-delimited string starting after the opening quote (body elided).
(declare read-string (-> Bytes I64 RR))

; The core: read exactly one form starting at (skip-trivia b i).
(def read-form (-> Bytes I64 RR)
  (lam (b i0)
    (let ((i (skip-trivia b i0)))
      (case (<i i (blen b))
        (false (r-err "unexpected end of input" i))
        (true
          (let ((c (bget b i)))
            (case (=i c CH-LPAREN)                 ; '('
              (true  (read-list b (+ i 1) nil))
              (false (case (=i c CH-RPAREN)        ; ')'
                (true  (r-err "unexpected )" i))
                (false (case (=i c CH-DQUOTE)      ; '"'
                  (true  (read-string b (+ i 1)))  ; ; scanner elided for brevity
                  (false (read-atom b i)))))))))))))

; read-list: on ')' close with (s-list (reverse acc)); else read a form, cons it,
; recurse. Measure blen−j decreases each step -> total.
(def read-list
  (-> Bytes I64 (List Sexp) RR)
  (lam (b i acc)
    (let ((j (skip-trivia b i)))
      (case (<i j (blen b))
        (false (r-err "unclosed (" j))
        (true (case (=i (bget b j) CH-RPAREN)
          (true  (r-ok (s-list (reverse Sexp acc)) (+ j 1)))
          (false (case (read-form b j)
            ((r-err m p) (r-err m p))
            ((r-ok f p)  (read-list b p (cons f acc)))))))))))
```

- **Knobs to modify:** the atom classifier in `read-atom` (what counts as an
  i64 vs a symbol — e.g. add `#t`/keyword syntax); the escape set in the elided
  `read-string` scanner; whether to keep source line numbers (add a field to
  `RR`/`Sexp`, as `sexp.py` threads `line`).
- **Deliberately omitted:** the concrete byte scanners (`skip-trivia`,
  `read-atom`, `read-string` bodies) and the `CH-*` byte constants — they are
  mechanical `bget`/`=i` loops; the point here is the *shape* (pure, total,
  result-as-value, closed tree sum), not the character tables.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/sexp.chiral` (new), consumed by the E2 elaborator;
  eventually retires `scaffold/chirality/sexp.py`.
- **Conformance target:** reproduce `sexp.py`'s golden behavior — for every
  fixture source, `read-form`/`read-all` must yield the same tree (same atom
  int-vs-symbol split, same string escapes `\n \t \" \\`, comments stripped) and
  fail on the same inputs (`unclosed (`, `unexpected )`, unterminated string),
  now as `r-err` values rather than `ReadError` throws.
- **Open questions:** does E2 want a single `read-form` or a streaming
  `read-all` (list of toplevel forms)?; keep line numbers in the tree or only in
  errors?; fuse the tokenizer into the parser (as here / `json.chiral`) or keep a
  separate token pass to mirror `sexp.py` 1:1 for the conformance diff.
- **Related:** [[E02-surface-elaborator]] (the consumer), [[E26-alarms]] (errors
  as values vs control flow), [[E25-byte-cells]] / [[E24-i64-arith]] (the
  `Bytes`/`I64` floor the scanners stand on).
