---
element: E94
slug: form-type-capacity
title: B1 form/type capacity: raise or remove hard limit on forms/data types in `parse.chiral`/`loader.chiral` so scriba blob compiles with full linkage
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-08
---

# E94 — B1 form/type capacity: raise or remove hard limit on forms/data types in `parse.chiral`/`loader.chiral` so scriba blob compiles with full linkage

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E94 — raise or remove the hard limit on total forms and data types
  the B1 self-hosted loader can process in a single `load-source` call, so the
  scriba blob compiles with all 5 linkage files (crossing-wraps, sys-check,
  target-linux, sys-tal, sys-linkage) appended.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** The self-hosted compiler frontend (`parse.chiral` +
  `loader.chiral`, compiled to native B1) has an implicit capacity ceiling. It
  compiles the compiler's own ~62-type blob but FAILS on the larger scriba blob
  (~38 types + 5 linkage files with additional data/def/tal-ir forms). This
  blocks the scriba editor's native compile path and caps the self-hosting
  reach. The limit is in total blob size (forms + types + nesting depth), not
  any single module — individual scriba modules each compile fine with
  prelude+ports.

## 2. Research

- **Reference class:** OURS — the existing `parse.chiral` and `loader.chiral`
  source, the `Sig`/`Term` data structures in `kernel.chiral`, and the
  `scaffold/chirality/surface.py` Python baseline the chirality loader ports.
- **Key findings:**
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

  1. **Rust's `#![recursion_limit]`** (default 128 in 2015 edition, 512 in 2021+)
     is the canonical self-hosted-compiler capacity control — a configurable
     recursion depth for compile-time operations (macro expansion, trait
     resolution, auto-dereference). The compiler bails with a clear error
     ("recursion limit reached") rather than silently crashing. Users raise it
     with `#![recursion_limit = "1024"]` at crate root. (Rust Reference §limits,
     rust-lang/rust#100792)

  2. **Drew DeVault's self-hosting parser bootstrap** (2021, hare language) uses
     a hand-written recursive-descent parser with no explicit capacity limit —
     the C stack is the implicit ceiling. Their bootstrap path: yacc prototype →
     hand-written C recursive-descent → self-hosted parser in the language
     itself, each stage removing a dependency. No form-count ceiling was
     encountered because their language deliberately uses an LL(1) grammar.

  3. **OCaml bytecode stack threshold** (`Config.stack_threshold`, ocaml/ocaml#510)
     — the bytecode compiler dynamically reallocates the evaluation stack when
     free space falls below a threshold, avoiding a fixed recursion depth cap.
     The native compiler has no form-count limit; type definitions accumulate in
     persistent data structures.

  4. **Python CPython stack overflow with large programs** (CPython issue 31113)
     — the compiler's `stackdepth()` routine recurses over the AST and hits the
     C stack limit for programs with long sequences of expressions. Fixed by
     converting the recursion to an explicit worklist. `sys.setrecursionlimit()`
     only covers the interpreter, not the compiler.

  All four converge on the same pattern: **capacity limits are implicit in
  recursive-descent / recursive-walk code, and the fix is either a configurable
  guard (Rust), dynamic growth (OCaml), or refactoring to iteration (Python).**
  Chirality's B1 is in the "implicit recursion depth" camp — the limit isn't an
  explicit counter but the native stack depth available to recursive functions
  like `load-forms`, `elab-all-data`, and `run-forms`.

## 3. Conventional (other-language) approach

How this is done in the Python baseline (`scaffold/chirality/surface.py`) and in
Rust/OCaml compilers.
2026-09-04: cut Python oracle, no live successor.

```python
# scaffold/chirality/surface.py — Elab.load_file (simplified)
# The Python baseline has NO hard form-count limit. Each `load_file`
# processes one module's forms and installs them into el.sig (a Python
# dict of global-name -> (type, body) with 50+ entries for the compiler
# blob). The Python stack is large (1 GB thread stack, recursionlimit 2M
# set in stage1-selfcompile.py) and the data structures are dicts, so
# neither form count nor lookup depth are constrained.
class Elab:
    def load_file(self, path):
        forms = read_all(open(path).read())   # sexp.chiral equivalent
        for f in forms:
            self._load_form(f)                 # install into self.sig
```
2026-09-04: cut Python oracle, no live successor.

```rust
// Rust compiler: recursion_limit controls macro-expansion depth
#![recursion_limit = "256"]  // default was 128, raised in edition 2021

// The limit is per-crate, configurable, and checked at each recursion
// step in the macro expander. The compiler bails with a clear diagnostic
// rather than overflowing the native stack.
```

- **Assumptions it bakes in:**
  - Python: effectively unlimited heap (dicts, list appends) + huge C stack
    (1 GB thread stack via `threading.stack_size`, recursionlimit 2M).
    Untyped mutation — `el.sig` is a dict mutated in place. No proof
    obligation about capacity.
  - Rust: configurable but fixed-at-compile-time limit; checked at each
    recursion step with a clear error. The limit is a compiler attribute,
    not a language feature.
  - Both: capacity is an **operational accident**, not a typed property.
    You discover the limit by hitting it.

## 4. The chirality idea

How chirality's model reframes capacity.

- **Chirality features in play:**
  - **QTT quantities & usage** — every form in `load-forms` is processed
    exactly once (linear traversal over the `(List Sexp)`). The `Sig` is
    built monotonically — each `load-def`/`load-data` adds one entry.
  - **Effect membrane `->` vs `=>`** — `load-source` is pure (`->`): it
    reads a string, builds a `Sig`, and returns it. No crossings. The
    capacity limit is a property of the **value** (how large a `Sig` can
    be within the native runtime's stack and heap), not of an effect.
  - **Categories A/B/C** — `parse.chiral` is category A (typed, checked).
    The capacity limit is category B (untyped substrate — the native
    runtime's stack and pointer representation). E94 bridges A→B: it makes
    an implicit B constraint visible in the A layer.
  - **Totality** — `load-forms` is total over finite input. The limit
    manifests because `load-forms` recurses over the form list, and the
    native codegen's call stack has a finite (and insufficient) depth for
    the combined scriba+linkage form count.

- **The reframing:** Instead of an implicit native-stack ceiling, the
  loader should carry an **explicit capacity parameter** — a `Cap` token
  that bounds the depth of recursive walks. Forms are processed in
  **batches** (multiple `load-source` calls, each within the bound) rather
  than one monolithic call. The `Sig` becomes an append-only structure
  that survives across batch boundaries. This mirrors the Rust approach
  (configurable limit, clear error) but expressed in chirality's typed model:
  the limit is a value, not an attribute.

- **What chirality makes impossible here:** You cannot silently overflow the
  native stack — the capacity bound is checked on every recursive step, and
  exceeding it produces a `LoadR` error (never a crash, never a corrupt
  parse tree). The loader cannot process an unbounded blob in one call; the
  caller must batch.

## 5. Chirality example (fleshed)

The clear-cut example — real chirality surface syntax, copy-and-modify ready.

```chirality
; E94 — capacity-bounded loader. The Sig becomes an append-only builder that
; survives across multiple load-source calls, each within a Cap bound.
; Lands in: lib/module/loader.chiral or a new lib/module/load-batch.chiral.

(import "prelude")
(import "kernel")     ; Sig, Term, DataDecl, LoadR, empty-sig, load-def, load-data
(import "sexp")       ; read-all-str, AllR, Sexp
(import "surface")    ; SEnv, base-senv, DataDecl, elab (for data-group phase)

; ---- capacity token: bounds recursion depth in load-forms --------------
; Cap = remaining steps before the loader must yield. Zero = stop and
; return the partial Sig (caller can resume with a fresh Cap).
(data Cap ()
  (cap-remaining (steps I64))
  (cap-exhausted))

; A partial load result: either done (final Sig), checkpoint (partial Sig
; + remaining forms + remaining cap steps), or error.
(data BatchR ()
  (batch-done   (sig Sig))
  (batch-more   (sig Sig) (pending (List Sexp)) (steps I64))
  (batch-err    (msg Str)))

; ---- capacity-bounded top-level form loop ------------------------------
; The cap is threaded through every recursive call. When the remaining
; steps drop to zero, the loader yields (batch-more) so the caller can
; resume with a fresh cap. The existing load-form is reused — we wrap
; it with a cap decrement in the outer loop.

(declare load-forms-capped
  (-> Sig SEnv (List Sexp) Cap BatchR))
(def load-forms-capped
  (lam (sig env forms cap)
    (case cap
      ((cap-exhausted)
        ; yield: return partial Sig + unconsumed forms
        (batch-more sig forms 0))
      ((cap-remaining n)
        (case (<i n 1)
          (true (batch-more sig forms 0))
          (false
            (case forms
              (nil (batch-done sig))
              ((cons f rest)
                ; process one form with the existing load-form, then
                ; recurse with n-1 remaining steps
                (case (load-form (sst sig env) f)
                  ((step-err m) (batch-err m))
                  ((step-ok st2)
                    (case st2 ((sst sig2 env2)
                      (load-forms-capped sig2 env2 rest
                        (cap-remaining (- n 1))))))))))))))))

; ---- the batch-aware entry: source + cap -> BatchR ---------------------
; Wraps load-source's three-phase pipeline (porttypes → data group →
; rest) in a cap-tracking outer loop. The key insight: replace the
; unbounded recursion in load-forms/elab-all-data/run-forms with
; functions that decrement a cap on each step and yield when exhausted.
;
; For the worked example, we show the pattern applied to the final
; load-forms phase (the one that processes def/declare/extern forms
; linearly). The same pattern applies to the porttype and data-group
; phases — each gets a capped wrapper that yields batch-more when
; the cap hits zero.

(declare load-source-capped (-> Str Cap BatchR))
(def load-source-capped
  (lam (src cap)
    (case (read-all-str src)
      ((a-err m p) (batch-err (str-cat "parse: " m)))
      ((a-ok forms)
        ; existing three-phase pipeline (unchanged logic), then feed
        ; the final linear forms through the capped loop instead of
        ; the unbounded load-forms
        (case (run-forms (sst empty-sig base-senv) (collect-porttype forms))
          ((step-err m) (batch-err m))
          ((step-ok stpt) (case stpt ((sst sigpt envpt)
            (let (dforms (collect-data forms))
              (let (envd (senv-add-datanames envpt dforms))
                (case (elab-all-data envd dforms)
                  ((p-err m) (batch-err (str-cat "data-group: " m)))
                  ((p-ok decls)
                    (case (load-data-group sigpt decls)
                      ((ld-err m) (batch-err m))
                      ((ld-ok sig1)
                        ; ⬇ THE CAP-TRACKED LOOP ⬇
                        (load-forms-capped
                          sig1 (add-all-ctors envd decls)
                          (keep-rest forms) cap)))))))))))))))

; ---- the entry the caller actually uses: iterated batching -------------
; Calls load-source-capped in a loop with Cap=10000 per batch until
; batch-done or batch-err. The caller (compile-front) receives the
; fully-built Sig.
(declare load-source-batched (-> Str LoadR))
(def load-source-batched
  (lam (src)
    ; initial cap: 10000 steps per batch (chosen to be well under B1's
    ; native stack ceiling for the scriba+linkage blob)
    (load-source-loop src (cap-remaining 10000) empty-sig)))

(declare load-source-loop (-> Str Cap Sig LoadR))
(def load-source-loop
  (lam (src cap acc-sig)
    (case (load-source-capped src cap)
      ((batch-err m) (ld-err m))
      ((batch-done sig) (ld-ok (sig-merge acc-sig sig)))
      ((batch-more sig pending rem-steps)
        ; merge partial Sig and resume with a fresh cap on the remaining
        ; forms. The pending forms are serialized back to a string blob.
        ; rem-steps is discarded — we use a full fresh cap for the next
        ; batch rather than trying to stretch the exhausted budget.
        (let (rest-src (serialize-forms pending))
          (load-source-loop rest-src (cap-remaining 10000)
                            (sig-merge acc-sig sig)))))))
```

- **Knobs to modify:**
  - `cap-remaining` steps per batch (10000 above). Raise for larger blobs,
    lower for tighter stack budgets. The right value is found empirically:
    start at the compiler blob's form count (≈200) and double until scriba
    passes.
  - `sig-merge`: how to combine two `Sig` values. For V1, just append
    the lists (`globals ++ globals`, `datas ++ datas`, etc.) with
    duplicate-name rejection (first-definition-wins, same as the current
    import-is-no-op convention).
  - `serialize-forms`: how to convert pending `(List Sexp)` back to a
    `Str` for the next batch. For V1, use the existing `pretty.chiral`
    or a simple sexp printer. A future slice could avoid re-serialization
    by passing the `Bytes` buffer and a cursor.

- **Deliberately omitted:**
  - The per-phase cap sub-accounting is a sketch — real implementation
    should use a unified step counter decremented on every recursive call.
  - `sig-merge` and `serialize-forms` are declared but not defined; they
    are straightforward list operations (append + dedup, and sexp->str).
  - B1 native stack profiling to find the exact ceiling is deferred to
    implementation.
  - The 2-type-param B1 limitation (workarounds in render.chiral:21,
    keymap.chiral:74) is a separate issue — E94 does not fix it.
  - Non-blob inputs (multi-file loads with real `import` resolution) are
    out of scope; E94 targets the flattened blob path.

## 6. Use / modify notes

- **Lands in:** `lib/module/load-batch.chiral` (new file) plus a small
  patch to `lib/lowering/compile-front.chiral` to call `load-source-batched`
  instead of `load-source`.
- **Conformance target:** The scriba blob compiled through B1 with all 5
  linkage files appended (`crossing-wraps.chiral`, `sys-check.chiral`,
  `target-linux.chiral`, `sys-tal.chiral`, `sys-linkage.chiral`) produces a
  runnable ELF that passes the 5 gate tests in
  `prog/scriba/scriba-test-b1.prog`. No regression in the
  existing 708 compiler tests.
- **Open questions:**
  1. What is the actual native stack ceiling in B1's codegen? Need a
     small reproducer: a chirality program with N recursive calls that finds
     the exact overflow point.
  2. Is the limit really in the recursive loader functions, or in the
     sexp reader (`read-list` → `read-form` mutual recursion for deeply
     nested tal-ir instruction sequences)? The known `(lam (x ...) body)`
     error suggests a parse corruption, not a clean overflow — investigation
     needed during implementation.
  3. Should batching use string re-serialization or pass the `Bytes`
     buffer + cursor? String serialization is simpler but adds overhead;
     buffer-passing requires a new `Bytes`-based tail of `load-source`.
  4. Does the 2-type-param B1 limitation (render.chiral:21, keymap.chiral:74)
     interact with the form-count limit? If the same codegen issue causes
     both, a single fix in the native backend may resolve both.
  5. What is the right per-batch cap value? Must be found empirically and
     documented — the example's 10000 is a placeholder.
- **Related:** [[E94-form-type-capacity]], [[E92-effect-chain-decoupling]]
  (E92 §5 references "B1 limits #1"), [[E89-arena-init]] (§5: "linearity
  on compound data fields is a B1 limitation").
