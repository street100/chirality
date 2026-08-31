---
element: E102
slug: sexp-enhancements
title: Sexp-reader follow-up enhancements — per-function paren delta, max nesting depth guard, form-splitter, token start position
kind: BUILD-PROPER
reference_class: OURS
ours_source: lib/sexp.chiral, lib/parse.chiral
status: reviewed
updated: 2026-08-09
---

# E102 — Sexp-reader follow-up enhancements

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E102, four follow-up enhancements to the chirality-native sexp reader
  (`lib/sexp.chiral`) and surface parser (`lib/parse.chiral`), building on E101's
  position helpers.
- **Kind:** BUILD-PROPER — designed features not yet built.
- **Why chirality needs its own:**
  1. **Per-function paren delta:** B1 currently reports `unexpected )` with no
     clue WHICH function is unbalanced. When compiling a blob of 1000+ forms,
     knowing that `def compile-main` has 3 extra closes vs `def foo` is the
     difference between a 30-second fix and a 30-minute binary search.
  2. **Max nesting depth guard:** Deeply nested TAL forms ('emit-core.chiral',
     `mach-x64.chiral` entry stubs) produce misleading errors when arena
     corruption manifests — the reader descends 200+ levels, allocates
     intermediate lists, and crashes in unrelated code. A configurable depth
     ceiling catches this before the arena is corrupted.
  3. **Form-splitter:** Binary-searching a blob for the failing form currently
     requires `head -N` (which splits mid-form) or Python `read_all` (which
     requires the Python scaffold). A native `read-all-forms` returning
     `(List (Pair Sexp I64))` — each form plus its byte-offset — enables B1
     to binary-search its own input. This is the chirality-native equivalent of
     Python's `read_all`.
  4. **Token start position:** When atom parsing fails (invalid number,
     unterminated string), the error reports the byte offset where the error
     was *detected* (e.g., end of string), not where the token *began*. The
     start offset is the useful diagnostic.

## 2. Research

- **Reference class:** `OURS` — these are refinements of our own E1/E101 reader,
  informed by our own debugging pain points.
- **Key findings:**
  1. **GCC/clang/rustc pattern:** "in function 'X'" annotations on errors.
     Our equivalent is the per-function paren delta — when a `def` form closes
     with the wrong paren count, we name the function.
  2. **Python `sys.setrecursionlimit`:** The standard guard against runaway
     recursion. Our max-depth guard is equivalent but at the reader level —
     it prevents the reader from descending into well-formed but pathologically
     nested input.
  3. **Form-level binary search (chirality-dev-patterns §6):** The proven debugging
     technique for B1 errors. A native `read-all-forms` makes this available
     from chirality source without the Python scaffold.
  4. **Python `sexp.py` start-tracking:** The existing oracle reader captures
     `token_start` for every atom via its cursor. The chirality port simplified
     this to track only current position. Enhancement #4 restores it.

## 3. Conventional (other-language) approach

A typical Lisp reader's error reporting:

```python
class ParenTracker:
    def __init__(self):
        self.balance = {}  # function_name -> delta
        self.current_fn = None

    def on_open(self, name):
        if name in ('def', 'declare'):
            self.current_fn = extract_name()
            self.balance[self.current_fn] = 0

    def on_paren(self, c):
        if c == '(':
            if self.current_fn:
                self.balance[self.current_fn] += 1
        elif c == ')':
            if self.current_fn:
                self.balance[self.current_fn] -= 1

    def report(self):
        for fn, delta in self.balance.items():
            if delta != 0:
                print(f"function {fn}: {abs(delta)} {'missing' if delta > 0 else 'extra'} close parens")
```

- **Assumptions it bakes in:** Mutable state (`self.balance` dict), imperative
  per-character dispatch, error reporting via side effects (print). The chirality
  port must be pure, thread position, and return errors-as-values.

## 4. The chirality idea

- **Chirality features in play:**
  - **Purity (`->`):** All four enhancements are pure. Paren delta is computed
    from the `read-all` output; max-depth is a thread-local parameter; form-splitter
    is a new pure entry point returning `AllFR`; token start is a parameter threaded
    through atom readers.
  - **Errors as values:** Paren delta is a post-hoc analysis of already-parsed
    forms — no error path change. Max-depth produces `r-err`. Form-splitter
    returns `AllFR`. Token start enriches existing `r-err` messages.
  - **Totality:** All functions are structurally recursive over `Bytes` or `List`.
  - **Boundary sums:** The form-splitter's `AllFR` wraps `(List FormPos)`;
    `ParenDelta` is a closed sum for balance results (ok/extra/missing).
    The `AllR` type is unchanged for backward compatibility.

- **The reframing:** Instead of mutable per-character dispatch, each enhancement
  is a pure function that either enriches the recursive descent (depth, token-start)
  or post-processes the result (paren delta, form-splitter). The four compose:
  form-splitter enables binary-search; paren delta uses the splitter's output;
  max-depth prevents the splitter from corrupting the arena; token-start makes
  atom errors precise.

- **What chirality makes impossible here:** silent paren imbalance (every `read-all`
  can report per-function deltas); unbounded nesting (depth guard is structural);
  Python-only binary search (form-splitter is native); ambiguous atom errors
  (every error carries the token's start position).

## 5. Chirality example (fleshed)

### Enhancement 1: Per-function paren delta

```chirality
; ---- per-function paren delta (post-hoc on read-all output) -------------
; After read-all succeeds, scan the form list for def/declare boundaries
; and track ( / ) balance within each. Report any nonzero deltas.

; ParenDelta: result of scanning one function's paren balance.
(data ParenDelta ()
  (pd-ok)
  (pd-extra (fn-name Str) (count I64))     ; N extra close parens
  (pd-missing (fn-name Str) (count I64)))  ; N missing close parens

; Track function-level balance: name -> current delta.
; Uses assoc-list of (Pair Str I64) threaded through the scan.
(declare paren-scan (-> (List Sexp) I64 Str (List (Pair Str I64)) ParenDelta))
(def paren-scan
  (lam (forms depth current-fn balances)
    (case forms
      (nil (pd-ok))
      ((cons f rest)
        (case f
          ((s-list items)
            (case items
              (nil (paren-scan rest depth current-fn balances))
              ((cons head tail)
                (case head
                  ((s-sym nm)
                    (case (str-eq nm "def")
                      (true
                        ; def form: extract function name from (def NAME ...)
                        (case tail
                          ((cons name-item _)
                            (case name-item
                              ((s-sym new-fn)
                                (paren-scan rest (+ depth 1)
                                  new-fn (cons (pair new-fn 0) balances)))
                              (_ (paren-scan rest depth current-fn balances))))
                          (nil (paren-scan rest depth current-fn balances))))
                      (false
                        (case (str-eq nm "declare")
                          (true
                            (case tail
                              ((cons name-item _)
                                (case name-item
                                  ((s-sym new-fn)
                                    (paren-scan rest (+ depth 1)
                                      new-fn (cons (pair new-fn 0) balances)))
                                  (_ (paren-scan rest depth current-fn balances))))
                              (nil (paren-scan rest depth current-fn balances))))
                          (false
                            (paren-scan rest depth current-fn balances))))))
                  (_ (paren-scan rest depth current-fn balances)))))
          (_ (paren-scan rest depth current-fn balances)))))))

; Paren-delta report from a source string (post-read-all).
; Reports deltas via the ParenDelta sum; caller cases on the result.
(declare paren-delta-report (-> Str ParenDelta))
(def paren-delta-report
  (lam (src)
    (case (read-all-str src)
      ((a-err _ _) (pd-missing "" 0))  ; can't compute on broken input
      ((a-ok forms) (paren-scan forms 0 "" nil)))))
```

### Enhancement 2: Max nesting depth guard

```chirality
; ---- max nesting depth guard ---------------------------------------------
; MAX-DEPTH: configurable ceiling (I64 constant). 200 is a safe default
; that catches pathological TAL nesting before arena corruption.
(def MAX-DEPTH I64 200)

; read-form-depth: like read-form but refuses at or above max depth.
(declare read-form-depth (-> Bytes I64 I64 RR))
(def read-form-depth
  (lam (b i depth)
    (case (<=i MAX-DEPTH depth)
      (true (r-err (str-cat "max depth " (str-cat (i64->str MAX-DEPTH)
                        (str-cat " exceeded in form at "
                          (fmt-pos b i))))
                   i))
      (false (read-form* b i depth "")))))
```

### Enhancement 3: Form-splitter (read-all-forms)

```chirality
; ---- form-splitter: read-all-forms ---------------------------------------
; Returns (List FormPos) — each top-level form with its byte offset.
; This enables B1 to binary-search its own input: test forms[0:N]
; incrementally to isolate the exact failing form.
; Uses a dedicated result type (not AllR) because the payload is
; (List FormPos), not (List Sexp).

(data FormPos () (fp (form Sexp) (offset I64)))

; AllFR: form-splitter result — all forms with positions, or first error.
(data AllFR ()
  (af-ok  (forms (List FormPos)))
  (af-err (msg Str) (pos I64)))

(declare read-all-forms-go (-> Bytes I64 (List FormPos) AllFR))
(def read-all-forms-go
  (lam (b i acc)
    (case (<i i (blen b))
      (false (af-ok (reverse FormPos acc)))
      (true (case (read-form b i)
              ((r-err m p) (af-err m p))
              ((r-ok f p)
                (read-all-forms-go b (skip-trivia b p)
                  (cons (fp f i) acc))))))))

(def read-all-forms (-> Bytes AllFR)
  (lam (b) (read-all-forms-go b (skip-trivia b 0) nil)))

(def read-all-forms-str (-> Str AllFR)
  (lam (s) (read-all-forms (str->bytes s))))
```

### Enhancement 4: Token start position in errors

```chirality
; ---- token start position in atom errors ---------------------------------
; read-atom-start: like read-atom but carries the token's START offset for
; error messages. When an atom parse fails (invalid number, unterminated
; string), the error includes where the token BEGAN, not just where the
; reader detected the problem.

(declare read-atom-start (-> Bytes I64 I64 RR))
(def read-atom-start
  (lam (b i start)
    (let (j (atom-end b i))
      (let (txt (bytes->str (bslice b i j)))
        (case (is-i64-lit b i j)
          (true  (r-ok (s-i64 (case (=i (bget b i) CH-MINUS)
                                (true (- 0 (digits->i64 b (+ i 1) j 0)))
                                (false (digits->i64 b i j 0)))) j))
          (false (r-ok (s-sym txt) j)))))))

; read-string-start: like read-string but carries the opening-quote position.
(declare scan-str-start (-> Bytes I64 Bytes I64 RR))
(def scan-str-start
  (lam (b i acc start)
    (case (<i i (blen b))
      (false (r-err (str-cat "unterminated string starting at "
                      (fmt-pos b start))
                    i))
      (true (let (c (bget b i))
              (case (=i c CH-DQUOTE)
                (true (r-ok (s-str (bytes->str acc)) (+ i 1)))
                (false (case (=i c CH-BSLASH)
                         (true (scan-str-escape-start b (+ i 1) acc start))
                         (false (scan-str-start b (+ i 1) (bcat acc (u8 c)) start))))))))))

(declare scan-str-escape-start (-> Bytes I64 Bytes I64 RR))
(def scan-str-escape-start
  (lam (b i acc start)
    (case (<i i (blen b))
      (false (r-err (str-cat "unterminated escape starting at "
                      (fmt-pos b start))
                    i))
      (true (scan-str-start b (+ i 1) (bcat acc (u8 (esc-char (bget b i)))) start)))))

(def read-string-start (-> Bytes I64 RR)
  (lam (b i) (scan-str-start b i (str->bytes "") (- i 1))))
```

- **Knobs to modify:**
  - `MAX-DEPTH` constant (200 → user choice).
  - Paren delta report format (current: per-function strings; future: structured sum type).
  - `FormPos` could carry byte-length in addition to offset for slice extraction.
  - Token start could be threaded through `read-form*` to cover ALL errors, not just atoms.
- **Deliberately omitted:**
  - Full recursive paren counting inside nested `def` forms (the current scan
    only detects `def`/`declare` boundaries; interior balance within a function
    is E101's depth tracking). This can be extended by re-reading the byte
    range of each function and calling `read-all` on it — the form-splitter
    provides the offsets needed.
  - `read-all-forms` does NOT change `AllR` — the type stays unchanged for
    backward compatibility.
  - Integration of `read-atom-start` into `read-form*` — the example shows
    the pattern; the implementation wires it into the dispatch.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/sexp.chiral` (all four enhancements are pure sexp
  reader additions). `scaffold/lib/parse.chiral` (callers: `load-source` can use
  `read-all-forms` for binary-search; `handle-import` can use form offsets).
- **Conformance target:** `chirality test` + `chirality test-native` must pass unchanged.
  The existing `read-form`/`read-all` paths are unchanged. New functions are
  additive. Paren delta is post-hoc. Max-depth uses a new entry point (doesn't
  modify existing `read-form`). `read-all-forms` is a new entry point.
  Token-start versions are new functions alongside existing ones.
- **Open questions:**
  - Should `read-form*` use `read-atom-start` internally? If so, the `declare`/
    `def` signatures in `read-form*` change to carry token-start. Decision: YES
    for implementation, but keep the public `read-form` API backward-compatible.
  - Should `MAX-DEPTH` be a parameter or a constant? Decision: constant for now;
    parameterization adds complexity with no immediate use case.
  - Should paren delta be integrated into `read-all` (inline during parsing)
    or post-hoc as shown? Decision: post-hoc keeps `read-all` simple; inline
    would require threading a balance map through every recursive call.
- **Related:** [[E01-sexp-reader]] (the base reader), [[E101-sexp-error-context]]
  (position helpers and depth tracking that E102 builds on).
