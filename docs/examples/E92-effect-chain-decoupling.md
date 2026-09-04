---
element: E92
slug: effect-chain-decoupling
title: Effect chain decoupling: inline `try-dispatch` helper before `command-loop-inner` in `command-loop.chiral`, forward-declare `command-loop-inner`, replace `(false ...)` beep arm with `try-dispatch` call
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: reviewed
updated: 2026-08-08
---

# E92 — Effect chain decoupling: inline `try-dispatch` helper before `command-loop-inner` in `command-loop.chiral`, forward-declare `command-loop-inner`, replace `(false ...)` beep arm with `try-dispatch` call

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E92, the effect chain decoupling pattern — splitting one deep
  effect chain across two function bodies by inlining a helper (`try-dispatch`)
  before the recursive inner loop (`command-loop-inner`), with a forward
  `declare` of the inner loop so the helper can call back into it.
- **Kind:** BUILD-PROPER — the code has been written (`command-loop.chiral:99–160`
  has the inline helper wired in), but B1 still fails the mutual recursion
  `command-loop-inner` ↔ `try-dispatch`. The lowering pass (`lower.chiral`) needs
  multi-pass handling for effectful mutual recursion before this can compile.
- **Why chirality needs its own:** B1, the self-hosting bootstrap compiler, has a
  hard ~3-effectful-op threshold per function body. The scriba command loop
  needs `read-key-sequence` + `lookup-keymap` + `lookup-scribaop` + `op-fn` call
  + recursive loop call — five effectful ops total. No existing compiler pass
  can fuse these into a single function body; the workaround is to decouple the
  effect chain across **two** function boundaries, each staying under the
  threshold. This is a fundamental constraint of self-hosting: the bootstrap
  compiler IS the language, and its limits must be worked around until the
  next fixpoint rebuild removes them.

## 2. Research

- **Reference class:** OURS — the `chirality-dev-patterns` skill's documented
  workaround (`.planning/references/b1-effect-chain-workaround.md`), the
  `b1-complexity-threshold` reference (`.planning/references/b1-complexity-threshold.md`),
  and the `b1-limits-for-scriba` reference (`.planning/references/b1-limits-for-scriba.md`).
- **Key findings:**
  - **B1 drops the entry label at ~4 direct effectful calls** in one function
    body. `read-key-sequence + lookup-keymap + quit-check + recursion` compiles.
    Adding `lookup-scribaop` to the same body fails with "no emitted label for
    entry compile-main" and zero diagnostics. The threshold was discovered by
    incremental addition — each operation works alone, but the aggregate exceeds
    B1's internal effect-tracking capacity.
  - **The workaround: helper-before-caller with forward declare.** Define a
    helper function BEFORE the inner loop in source order, use a forward
    `declare` for the inner loop (which is defined later), and have the helper
    carry the excess effectful ops. Each function stays at ≤3 direct effectful
    calls: `command-loop-inner` does `read-key-sequence` + `put` + helper call;
    `try-dispatch` does `op-fn` call + `command-loop-inner` recursion.
  - **Other self-hosting compilers hit the same class of limit.** Kalyn
    (intuitiveexplanations.com/tech/kalyn) uses a separate bundler phase to
    resolve imports before the compiler sees source — a different decoupling
    strategy, but the same constraint: the bootstrap compiler can't do
    everything the eventual compiler will. Idris2's bootstrap passes have
    similar mutual-recursion limitations in early passes (the `TT`-to-`Scheme`
    lowering required splitting recursive type families across multiple passes).
  - **The remaining blocker is mutual recursion in `lower.chiral`.** Even with
    the helper defined before the inner loop with a forward declare, the two
    functions reference each other's signatures in a cycle: `command-loop-inner`
    calls `try-dispatch` which calls `command-loop-inner`. `compile-back.chiral`
    forward references already work for non-effectful calls, but the erase step
    (`tal-erase.chiral`) can't fuse the mutual effect chain. The `sig-assoc`
    pass in `lower.chiral` needs multi-pass handling for effectful mutual
    recursion.

## 3. Conventional (other-language) approach

How a non-self-hosting compiler (or even chirality's own Python checker) would
handle this — one function body, no decoupling needed:

```python
# Python: the command loop in the Python checker's reference implementation.
# All effectful ops in one function body — no threshold, no helper needed.
def command_loop_inner(state: State) -> None:
    while True:
        ks = read_key_sequence()          # effectful 1
        opname = lookup_keymap(ks)        # pure
        if opname is None:
            beep()                        # effectful 2
            continue
        if opname == "quit":
            return
        op = lookup_scribaop(opname)      # pure
        if op is None:
            beep()                        # effectful 2 (same as above)
            continue
        state = op.fn(state.puffer)       # effectful 3
        # All of this — 3+ effectful ops, deep case nesting, mutable state —
        # fits in one function. No forward declare, no helper, no decoupling.
```

```chirality
;; The same idea in chirality surface syntax — a single function body with all
;; five effectful ops. This is what you'd WRITE if B1 had no threshold:
(declare command-loop-inner
  (=> (Puffer Str) (Pair I64 I64) Rendering (List (Pair Str RendererFn)) (List ScribaOp) Unit))
(def command-loop-inner
  (lam (puf dims rendering renderers ops)
    (let (ks (read-key-sequence default-keymap))             ;; effectful 1
      (case (lookup-keymap ks default-keymap)              ;; pure
        (none
          (let (_ (put "\x07"))                              ;; effectful 2
            (command-loop-inner puf dims rendering renderers ops)))
        ((some opname)
          (case (str-eq opname "quit")
            (true unit)
            (false
              (case (lookup-scribaop ops opname)           ;; pure
                (none
                  (let (_ (put "\x07"))                      ;; effectful 2
                    (command-loop-inner puf dims rendering renderers ops)))
                ((some scribaop)
                  (case scribaop
                    ((op name fn doc)
                      (let (puf2 (fn puf))                   ;; effectful 3
                        (command-loop-inner puf2 dims rendering renderers ops)))))))))))))
;; ^ B1 rejects this with "no emitted label": 5 effectful ops in one function
;; body exceeds the ~3-op threshold.
```

- **Assumptions it bakes in:** the compiler has no fixed upper bound on
  effectful operations per function body; mutual recursion through effectful
  calls is handled transparently by the lowering pass; the erase step can
  traverse arbitrary call graphs without a two-pass sig-assoc phase; there
  is no bootstrap-compiler ceiling that the source must stay under. All of
  these hold for a mature compiler — they do NOT hold for B1, which IS the
  first self-hosting iteration and carries every bootstrap constraint.

## 4. The chirality idea

Decouple the effect chain across **two function bodies**, each staying under
B1's ~3-effectful-op threshold. The helper (`try-dispatch`) is defined
BEFORE the caller (`command-loop-inner`) in source order, and the caller is
forward-declared so the helper can reference it.

- **Chirality features in play:**
  - **The `->`/`=>` effect membrane:** each function's effect row is explicit
    in its signature. `command-loop-inner` is `=>` (reads stdin, writes ANSI,
    polls for input). `try-dispatch` is also `=>` (calls the effectful
    `op-fn` and recurses into `command-loop-inner`). Purity (`->`) lives on
    the other side of the membrane — `lookup-scribaop` and `str-eq` are pure
    `->` functions whose calls don't count toward the effectful-op threshold.
    The membrane makes the decoupling possible: you can SEE which calls are
    effectful and redistribute them without guessing.
  - **Forward `declare` + source ordering:** the helper is defined after the
    `declare` of `command-loop-inner` but before the `def` of `command-loop-inner`.
    This is legal because `declare` introduces the name and type without the
    body; the helper can call `command-loop-inner` because the signature is
    already known. The body comes later. This is the same forward-reference
    mechanism `compile-back.chiral` uses for pure functions.
  - **Category B1 constraint:** this is not a language-level feature — it's
    a workaround for the current bootstrap compiler's limit. The long-term
    chirality idea is that `lower.chiral` gains multi-pass effectful mutual
    recursion handling, and the decoupling is no longer necessary. Until
    then, the pattern IS the compiler's reality.
  - **Capability threading:** both functions thread state parameters
    (`puf`, `dims`, `rendering`, `renderers`, `ops`) through every call.
    No globals, no mutation — the puffer is threaded as `(Puffer Str)`
    without linear quantity (B1 rejects `(1 ...)` on compound types).
  - **Errors as values, not control flow:** the `none` branch of
    `lookup-scribaop` returns to the command loop (no crash, no halt).
    The quit path returns `unit` — the loop terminates by structural
    recursion reaching a base case, not by an exception.

- **The reframing:** in a conventional compiler, the command loop is one
  function. In chirality-on-B1, the command loop is TWO functions that
  collaborate through the call graph, each contributing part of the
  effect row. The compiler's limit forces a design decision that is
  actually cleaner — `try-dispatch` is a separable concern (op resolution
  → execution) with its own signature and its own effect row. When B1's
  threshold eventually rises, the code can be inlined back into one
  function if desired, but the two-function split is arguably better
  architecture regardless.

- **What chirality makes impossible here:** you cannot write a single function
  with 5 direct effectful operations and expect it to compile through B1.
  You cannot hide effects behind an abstraction — the `=>` in the
  signature forces every effect to be visible. You cannot use ambient
  authority — every crossing (`put`, `read-key-sequence`) takes its
  capability explicitly (even if the cap is `unit` for now, the pattern
  is in the signature). These constraints are all deliberate features,
  not bugs — they prevent the "effect soup" that makes conventional
  codebases hard to audit.

## 5. Chirality example (fleshed)

The before/after as it lives in `prog/scriba/command-loop.chiral`.

**Before (fails B1)** — all dispatch logic inline in `command-loop-inner`,
pushing past the ~3-effectful-op threshold:

```chirality
; Forward declare for recursion
(declare command-loop-inner
  (=> (Puffer Str) (Pair I64 I64) Rendering (List (Pair Str RendererFn)) (List ScribaOp) Unit))

; command-loop-inner with ALL dispatch inline — BLOCKED by B1 threshold
(def command-loop-inner
  (lam (puf dims rendering renderers ops)
    (let (ks (read-key-sequence default-keymap))       ;; effectful 1
      (case (lookup-keymap ks default-keymap)          ;; pure
        (none
          (let (_ (put "\x07"))                         ;; effectful 2
            (command-loop-inner puf dims rendering renderers ops)))
        ((some opname)
          (case (str-eq opname "quit")                 ;; pure
            (true unit)
            (false
              ;; This inline dispatch adds 2+ effectful ops (lookup-scribaop
              ;; traversal + op-fn call) to a body that already has 2
              ;; → exceeds B1's ~3-op threshold → "no emitted label"
              (case (lookup-scribaop ops opname)
                (none
                  (let (_ (put "\x07"))
                    (command-loop-inner puf dims rendering renderers ops)))
                ((some scribaop)
                  (case scribaop
                    ((op name fn doc)
                      (let (puf2 (fn puf))              ;; effectful 3+
                        (command-loop-inner puf2 dims rendering renderers ops)))))))))))))
```

**After (decoupled)** — the actual code in `command-loop.chiral:99–160`.
The inline dispatch is extracted into `try-dispatch`, defined BEFORE
`command-loop-inner`. Each function has ≤3 direct effectful calls:

```chirality
; ─── Forward declare so the helper can recurse ──────────────────────────────
(declare command-loop-inner
  (=> (Puffer Str) (Pair I64 I64) Rendering (List (Pair Str RendererFn)) (List ScribaOp) Unit))

; ─── dispatch helper (before command-loop-inner — decouples effect chains) ───
(declare try-dispatch
  (=> (Puffer Str) (Pair I64 I64) Rendering (List (Pair Str RendererFn)) (List ScribaOp) Str Unit))
(def try-dispatch
  (lam (puf dims rendering renderers ops opname)
    (case (lookup-scribaop ops opname)                 ;; pure
      (none
        ;; Op not registered — beep and loop (beep is inlined as put "\x07")
        (let (_ (put "\x07"))                           ;; effectful 1 in helper
          (command-loop-inner default-keymap puf dims rendering renderers ops)))
      ((some scribaop)
        (case scribaop
          ((op name fn doc)
            ;; Execute the op function — this IS the effectful crossing
            (let (puf2 (fn puf))                        ;; effectful 1 in helper (op-fn)
              ;; Recurse into the main loop with updated puffer
              (command-loop-inner default-keymap puf2 dims rendering renderers ops))))))))
            ;; Total effectful calls in try-dispatch: 2 (put + op-fn)
            ;; Note: command-loop-inner call counts as 1 effectful call in
            ;; B1's accounting, bringing the helper's total to 2.

; ─── Inner loop (defined AFTER helper to satisfy source ordering) ───────────
(def command-loop-inner
  (lam (km puf dims old-rendering renderers ops)
    (let (ks (keyseq nil))
      (case (lookup-keymap ks km)                       ;; pure
        (none
          ;; No keymap match — beep and loop. Keys are stubs in v1.
          (case ks
            ((keyseq keys)
              (case keys
                ((cons k rest)
                  (case rest
                    (nil
                      (case k
                        ((k-char code)
                          (let (_ (render-to-ansi-delta old-rendering (r-hole "stub") dims))
                            (command-loop-inner km puf dims old-rendering renderers ops)))
                        (_
                          (let (_ (put "\x07"))           ;; effectful 1 or 2
                            (command-loop-inner km puf dims old-rendering renderers ops)))))
                    (_
                      (let (_ (put "\x07"))
                        (command-loop-inner km puf dims old-rendering renderers ops)))))
                (_
                  (let (_ (put "\x07"))
                    (command-loop-inner km puf dims old-rendering renderers ops)))))
            (_
              (let (_ (put "\x07"))
                (command-loop-inner km puf dims old-rendering renderers ops)))))
        ((some opname)
          (case (str-eq opname "quit")                   ;; pure
            (true unit)
            ;; The key change: dispatch is delegated to the helper, keeping
            ;; command-loop-inner's body at ≤3 effectful ops per branch.
            (false (try-dispatch puf dims old-rendering renderers ops opname))))))))
            ;; Effectful calls in this function:
            ;;   render-to-ansi-delta (branch A) — 1
            ;;   put "\x07" (branch B)            — 1
            ;;   try-dispatch call (branch C)     — 1 (the call itself)
            ;;   recursive command-loop-inner     — 0 (recursion doesn't count)
            ;; Each branch has ≤1 direct effectful call + helper delegation.
```

- **Knobs to modify:**
  - **The helper's effectful ops:** `try-dispatch` currently does `put`
    (beep) + `fn puf` (op execution). If you need an additional effectful
    operation in dispatch (e.g., logging the op name via `put`), you may
    need a SECOND helper to stay under the threshold.
  - **The forward declare list:** if more helpers depend on
    `command-loop-inner`, add their `declare` forms in the same block
    after the forward `declare` of `command-loop-inner`.
  - **The `Keymap` parameter:** `command-loop-inner` takes `km` as a
    parameter but `try-dispatch` uses `default-keymap` directly. This is
    because B1 rejects `(=> Keymap (Puffer Str) ...)` in signatures
    (the `Keymap + Puffer` type combination kills labels). If B1 fixes
    this, unify on passing `km` through both functions.
  - **The effect threshold number:** if B1's threshold rises from ~3 to
    ~5, the decoupling may no longer be necessary. The code can be
    collapsed into one function at that point.
  - **`render-to-ansi-delta` rendering:** the current code uses a
    `(r-hole "stub")` placeholder for the new rendering. A real
    implementation would compute the actual diff between old and new
    puffer states.

- **Deliberately omitted:**
  - **Self-insert for printable keys:** the current `command-loop-inner`
    only handles `k-char` with a stub and beeps on all other keys. Full
    self-insert (growing the puffer, rendering the inserted character)
    is a separate E-element.
  - **The rendering diff computation:** the `render-to-ansi-delta` call
    uses a placeholder `r-hole "stub"` instead of the real delta between
    old and new renderings. Rendering is scriba's S2, not this example's
    concern.
  - **The `dispatch.chiral` file:** `scaffold/lib/scriba/dispatch.chiral`
    exists (145 lines, includes `try-dispatch` and an activation patch
    template) but is blocked by the same mutual-recursion limitation.
    It's kept as a reference for when `lower.chiral` is fixed. The inline
    version in `command-loop.chiral` supersedes it for now.
  - **`(import "collections")`:** `command-loop.chiral` currently imports
    `collections` on line 16. This is a known label-poison (the
    2-type-param functions in `collections.chiral` kill labels just by
    being in the blob) and must be removed before this code can compile.
    The import is present as of 2026-08-08 and is a separate blocker
    (B1 limits #1 — collections import poison).

## 6. Use / modify notes

- **Lands in:** `prog/scriba/command-loop.chiral` — lines 99–160
  contain the inline `try-dispatch` helper, the forward `declare` of
  `command-loop-inner`, and the decoupled inner loop. The outer
  `command-loop` entry point is lines 87–97.
- **Conformance target:** the command loop must (1) read a key sequence
  from stdin, (2) look it up in the keymap, (3) on "quit" return `unit`
  to exit, (4) on any other match dispatch to the registered ScribaOp
  and recurse with the updated puffer, (5) on no match beep and recurse.
  The golden behavior is: `C-f` moves cursor forward, `C-b` moves
  backward, `C-x C-c` quits, unknown keys beep — all threaded through
  the same `command-loop-inner` / `try-dispatch` split.
- **Open questions:**
  - **When will `lower.chiral` handle effectful mutual recursion?** The
    `sig-assoc` pass needs multi-pass handling for the
    `command-loop-inner` ↔ `try-dispatch` cycle. `compile-back.chiral`
    forward references already work for non-effectful calls; the gap is
    in the effect-tracking layer. A two-pass approach (first pass
    collects all `=>` signatures, second pass lowers bodies) may be
    sufficient. Until this is fixed, the scriba dispatch remains blocked
    even with the inlined helper.
  - **Should `try-dispatch` stay inline or move back to `dispatch.chiral`?**
    Inline (current state) avoids the import-chain complexity and keeps
    the decoupling visible in one file. Moving to a separate file would
    match the longer-term architecture (one module per concern) but adds
    an import that may trigger the collections import poison or the
    subdirectory-def label-killer. Decision deferred until B1's other
    limits are resolved.
  - **Does the `Keymap` parameter need a Category-C bridge?** Currently
    `command-loop` takes `km` but `try-dispatch` uses `default-keymap`.
    If/when B1 handles the `Keymap + (Puffer Str)` type combination,
    both functions should thread `km` consistently. If B1 never handles
    it, `default-keymap` must be used everywhere — the same workaround
    already applied in the current code.
  - **Can the beep (`put "\x07"`) be extracted into its own helper?**
    Currently the beep is duplicated across multiple `case` branches in
    `command-loop-inner`. A `beep-and-loop` helper could reduce the
    effectful-op count per branch, but each branch already has ≤1
    direct effectful call — no pressure to refactor yet.
- **Related:** [[E92-effect-chain-decoupling]] · `prog/scriba/command-loop.chiral` ·
  `prog/scriba/dispatch.chiral` (blocked reference) ·
  `docs/decision-effect-facets.md` · `lib/lowering/compile-back.chiral` (forward-ref mechanism) ·
  `lib/lowering/upper/lower.chiral` (blocking `sig-assoc` pass)
