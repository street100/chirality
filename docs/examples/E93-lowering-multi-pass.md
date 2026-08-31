---
element: E93
slug: lowering-multi-pass
title: B1 lowering pass multi-pass: pre-scan all function signatures into `ce-fns` before the per-function lowering loop in `lower-defs` (`compile-back.chiral:211-226`), so mutually recursive effectful calls resolve without forward-reference failures
kind: BUILD-PROPER
reference_class: OURS/IMPL/PAPER
ours_source: (none)
status: reviewed
updated: 2026-08-08
---

# E93 — B1 lowering pass multi-pass: pre-scan all function signatures into `ce-fns` before the per-function lowering loop in `lower-defs` (`compile-back.chiral:211-226`), so mutually recursive effectful calls resolve without forward-reference failures

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E93 — the forward-declaration pre-scan in B1's lowering pass.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** B1's `compile-back.chiral` lowers every function through
  `lower-defs`, which compiles each def's body under a `CEnv` carrying the program's
  function signatures. Without a pre-scan, the signature table only contains previously
  seen defs. A mutually recursive call — `command-loop-inner` calls `try-dispatch` which
  calls `command-loop-inner` — hits `sig-assoc` for a callee whose def hasn't been
  processed yet. The lookup returns `none`, the call is skipped, and the compiled binary
  is missing a label and crashes at emit. The fix: collect ALL signatures once before the
  loop. Every `compile-fn` invocation sees the complete table, so inter-def calls resolve
  regardless of definition order.

## 2. Research

- **Reference class:** `OURS` (own `compile-back.chiral` / `lower.chiral`) + `IMPL`/`PAPER`
  (forward declaration, .hs-boot files, multi-pass type checking).
- **Key findings:**
  1. **Forward declaration** (Wikipedia): the standard technique for one-pass compilers
     that require declaration-before-use. The compiler sees a function's type signature
     before its body, so calls to it resolve even when the definition comes later. C and
     C++ use this explicitly; chirality does it implicitly by pre-scanning all `NDef` forms.
  2. **Haskell `.hs-boot` files** (GHC User's Guide §5.8.10): a separate file containing
     only type signatures for mutually recursive modules. GHC reads the boot file first
     to learn the interface, then compiles each module's body. This is the cross-module
     analog of the pre-scan — signatures before bodies.
  3. **Agda mutual blocks** (Agda docs): `mutual` blocks desugar into forward declarations
     — all type signatures are collected first, then bodies are checked. Same pattern, same
     motivation: make mutually recursive definitions type-check without forward-reference
     failures.
  4. **Multi-pass compilers** (Wikipedia): a compiler that processes source code multiple
     times. The first pass typically collects names and types (symbol-table building), and
     later passes use that table to compile bodies. B1 is single-pass for most things but
     already multi-pass for signatures — E93 formalizes that split.

## 3. Conventional (other-language) approach

How a naive single-pass lowerer builds the call table. This is the broken design the fix
replaces.

```python
# Hypothetical incremental approach (BROKEN for mutual recursion)
def lower_all(defs):
    ce_fns = {}                     # initially empty
    for d in defs:
        sig = extract_sig(d)        # this def's signature
        ce = CEnv(fns=ce_fns, ...)  # only previously-seen fns
        lowered = compile_fn(ce, d) # sig_assoc fails for forward refs
        ce_fns[d.name] = sig        # too late for mutual recursion
    return result
```

- **Assumptions it bakes in:** call targets appear earlier in the definition list than
  their callers. No mutual recursion. In a language with `->`/`=>` effect rows and
  membrane crossings, this assumption breaks immediately — any two functions that
  call each other (like a command loop and its dispatcher) are definition-ordered,
  and one always comes second.

## 4. The chirality idea

The fix is a two-line change in `back-program`: pass the COMPLETE pre-scanned signature
table to `lower-defs` instead of incrementally appending inside the loop. The `def-sigs`
function already maps over all `NDef` forms eagerly — the change is just routing that full
list through to every `CEnv`.

- **Chirality features in play:** `CEnv` as an immutable record (built once, reused for every
  def), `def-sigs` as a pure total transform `(List NDef) -> (List (Pair Str TalSig))`,
  and structural recursion over the def list. The effect membrane (`->` vs `=>`) isn't
  directly touched here, but the lowered calls that were previously dropped are all
  process-level crossings — exactly the calls the membrane must track.
- **The reframing:** instead of "build the table as you go" (accumulator pattern inside
  the main loop), the pre-scan separates signature COLLECTION from body COMPILATION. It's
  the same pattern as Haskell's `.hs-boot` files and Agda's `mutual` desugaring: collect
  all interfaces, then check all bodies. The pre-scan happens once at `back-program` entry;
  `lower-defs` passes the same `fnsigs` to every `cenv` unchanged.
- **What chirality makes impossible here:** the pre-scan is statically checked — `def-sigs`
  returns a value of type `(List (Pair Str TalSig))`, and `cenv` stores it in a typed
  field. You cannot accidentally use a half-built table because the type says "list of
  pairs," not "list of pairs built so far." The compiler enforces totality: `def-sigs`
  must process every `NDef` (structural recursion), no early bailout.

## 5. Chirality example (fleshed)

The two key sites. `def-sigs` is the pre-scan (already exists, unchanged by E93).
`back-program` is the entry point where the complete table is routed in.

```chirality
; ---- pre-scan: collect EVERY def's tal signature (line 74-77) --------------------
; Maps over all NDef forms eagerly. Returns (List (Pair Str TalSig)) where each
; pair is (function-name, (talsig param-types return-type)). This is the complete
; forward-declaration table — every function, regardless of definition order, has
; an entry here BEFORE any body is compiled.
(declare def-sigs (-> (List NDef) (List (Pair Str TalSig))))
(def def-sigs (lam (defs)
  (case defs (nil nil) ((cons d r) (case d ((ndef name params ret erased body)
    (cons (pair name (talsig (ntalty->talty-list params) (ntalty->talty ret)))
          (def-sigs r))))))))

; ---- THE BACK ENTRY: pass COMPLETE sig table to lower-defs (line 232-236) --------
; The fix lives in the third argument to lower-defs: (def-sigs defs) instead of
; an incremental accumulator. Every cenv built inside lower-defs (line 218) gets
; this same complete fnsigs list, so sig-assoc finds every function.
(def back-program (-> (List NDef) (List NData) (List NPrim) BR)
  (lam (defs ndatas nprims)
    (lower-defs (program-lits defs)
                (app-ts (nprims->table nprims) prim-table)
                (def-sigs defs)                   ; <- THE FIX: complete pre-scan
                (ndatas->ddatas ndatas) defs nil)))

; ---- inside lower-defs: CEnv uses the SAME fnsigs for every def (line 218) ------
; fnsigs is passed through unchanged. No append, no incremental grow.
; This is the key invariant: every compile-fn sees the same complete table.
(declare lower-defs (-> (List Str) (List (Pair Str TalSig)) (List (Pair Str TalSig))
                        (List DData) (List NDef) (List TFn) BR))
(def lower-defs (lam (lits prims fnsigs datas defs acc)
  (case defs
    (nil (erase-list lits datas (prune-fix (prim-names prims)
                                           (filter-erasable datas acc))))
    ((cons d r) (case d ((ndef name params ret erased body)
      (let (ptys (ntalty->talty-list params))
      (let (rty  (ntalty->talty ret))
      (let (ce   (cenv prims fnsigs datas lits))  ; fnsigs is the FULL table
        (case (compile-fn ce name (ncore->core body) ptys erased rty)
          ((le-skip er)        (lower-defs lits prims fnsigs datas r acc))
          ((le-ok main extra)  (lower-defs lits prims fnsigs datas r
                                 (lapp-tfn acc (cons main extra))))))))))))))

; ---- the call-site lookup in lower.chiral (sig-assoc, line 169-170) --------------
; compile-fn extracts ce-fns from CEnv into st-fns, and expr-app/exparse use
; sig-assoc to resolve call targets. Because st-fns holds the COMPLETE table,
; a call to a function defined LATER still resolves.
(declare sig-assoc (-> (List (Pair Str TalSig)) Str (Maybe TalSig)))
(def sig-assoc (lam (ps k)
  (case ps (nil (none))
    ((cons p r) (case p ((pair pk pv)
      (case (str-eq pk k) (true (some pv)) (false (sig-assoc r k)))))))))
```

Before the fix, a program with mutual recursion:

```chirality
; compiles second, calls try-dispatch — must find try-dispatch's sig
(def command-loop-inner (lam (state)
  (case (try-dispatch state) ...)))

; compiles first, signature available in ce-fns
(def try-dispatch (lam (state)
  (case (should-loop state)
    ((true) (command-loop-inner (next state)))  ; calls back — needs cmd-loop sig
    ((false) state))))
```

With incremental ce-fns: `try-dispatch` compiles first, its call to `command-loop-inner`
fails because that signature hasn't been added yet. With pre-scanned ce-fns: `def-sigs`
extracts both signatures before either body is compiled, and both `compile-fn` calls see
both entries.

- **Knobs to modify:** the `def-sigs` pre-scan is generic — it works for any list of
  `NDef`. If a new kind of callable (effect handlers, outlined case arms) joins the
  table, add a case to `def-sigs` and ensure `sig-assoc` recognizes the new entry shape.
  The separation of collection from compilation means you extend the pre-scan without
  touching the lowering loop.
- **Deliberately omitted:** higher-order calls (function pointers, closures). The current
  lowerer only handles first-order named calls. E93 doesn't change that — it only ensures
  that first-order named calls resolve across definition order. Polymorphic function
  instantiation and `lc-global` reference lowering are separate concerns (E70).

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/compile-back.chiral` — existing file, lines 74-77 (`def-sigs`)
  and 232-236 (`back-program`). The fix is already applied in the current tree; E93
  documents the pattern so future changes to the lowering loop preserve the invariant.
- **Conformance target:** the Python oracle `lower.py.lower_all` does the same thing
  with its "sig pre-pass" at `scaffold/chirality/lower.py:464-504`: iterate all
  `sig.global_defs`, install every eligible def's tal signature into `env_tal.fn_sigs`
  before lowering any body, then run the "body pass" (lines 506-547) with all
  signatures available. The chirality pre-scan (`def-sigs` at `compile-back.chiral:74-77`)
  reproduces the same semantic: signatures collected eagerly, bodies lowered with
  complete table. The conformance test: a program with mutual recursion (A calls B,
  B calls A) lowers without skipped defs and the emitted binary runs to completion
  without missing-label crashes.
- **Open questions:**
  - Does `def-sigs` need to include outlined extra functions from `compile-fn`? Currently
    no — outlined functions are anonymous continuations, never called by name from other
    defs. If future lowering passes add named outlined helpers, `def-sigs` must grow to
    cover them.
  - The `lc-global` reference path (line 251 of `lower.chiral`) uses `st-fns` for lookup
    but hits `er-skip` for non-nullary references. This is a separate limitation — E93
    doesn't address it, and it's fine because B1's surface defs are always nullary
    (partial application stays upper).
- **Related:** [[E93-lowering-multi-pass]] — forward declaration pre-scan.
  [[E70]] — effectful-call reach in the lowering partition (effect rows crossing `=>`).
  [[E16]] — lowering eligibility partition (decides which defs lower at all).
