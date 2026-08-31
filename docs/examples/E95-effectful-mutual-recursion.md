---
element: E95
slug: effectful-mutual-recursion
title: B1 effectful mutual recursion: fix the lowering/erase pipeline so two `=>` functions calling each other compile, matching the existing pure-mutual-recursion and effectful-self-recursion paths
kind: BUILD-PROPER
reference_class: OURS
ours_source: (none)
status: drafted
updated: 2026-08-08
---

# E95 — B1 effectful mutual recursion

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E95 — fix B1's lowering/erase pipeline so two `=>` (effectful)
  functions calling each other compile, matching the existing pure-mutual-recursion
  and effectful-self-recursion paths.
- **Kind:** BUILD-PROPER.
- **Why chirality needs its own:** scriba's command loop is blocked. The concrete
  reproducer is `command-loop-inner` → `try-dispatch` → `command-loop-inner`,
  both `=>` functions. E93's `def-sigs` pre-scans all signatures into `ce-fns`
  so the lookup is not the bottleneck. E94 provides sufficient form/type
  capacity. The blob loads clean (334 forms, zero non-list). The break is in the
  lowering or erase step: something in `lower.chiral`/`compile-back.chiral` or
  `tal-erase.chiral` treats the mutual effectful call differently from a pure
  one, causing the entry label to drop. Likely a 2-3 line fix in the effect
  counting or non-tail-case outlining path — not a new architecture.

## 2. Research

- **Reference class:** OURS — `compile-back.chiral` (the lowering drive),
  `lower.chiral` (the partition + compile-fn), `tal-erase.chiral` (the erasure
  step), `command-loop.chiral` (the reproducer), and `SCRIBA-DISPATCH-BLOCKER.md`
  (the handoff documenting what's been ruled out).
- **Key findings:**
  1. **What works:** pure mutual recursion compiles (two `->` functions calling
     each other). Effectful self-recursion compiles (one `=>` function calling
     itself). Effectful mutual recursion (two `=>` functions calling each
     other) fails with `no emitted label for entry compile-main`.
  2. **What's been ruled out:** form/type capacity (E94), arena/heap capacity,
     pre-scan (E93 `def-sigs` collects all sigs before lowering), collections
     import poison (removed from command-loop.chiral), nested case patterns
     (flattened), multi-expression case branches (wrapped in `let`), and
     declare ordering (forward-declared before use).
  3. **The pipeline:** `compile-back.chiral` drives `lower-defs` which iterates
     through NDefs, calling `compile-fn` for each. `compile-fn` constructs a
     `CEnv` from the pre-scanned `def-sigs` and compiles the body via
     `tail`/`expr`/`expr-app`. Calls to other lowered functions go through
     `(lc-global n)` → `sig-assoc` on `st-fns` → `emit-call`. The call graph
     is resolved by signature lookup, not by compilation order.
  4. **The suspicious paths:** `compile-fn` wraps the body in `strip-lams`
     then `tail`. A case arm that calls an effectful function produces a
     non-tail call chain inside the case outline. The erasure step
     (`erase-instr-onto`) has special handling for effectful crossings
     (`cw-lookup` → wrapper call + Unit overwrite). Either the non-tail
     outlining (`build-outline` in lower.chiral:328-338) or the erasure's
     crossing wrapper expansion could be the break point.

## 3. Conventional (other-language) approach

How a typical single-pass compiler handles mutual recursion:

```c
// C: forward declarations decouple mutual recursion from compilation order
void try_dispatch(Puffer*, Dims, Rendering*, RendererList*, OpList*, char*);
void command_loop_inner(Keymap*, Puffer*, Dims, Rendering*, RendererList*, OpList*);

void command_loop_inner(Keymap* km, Puffer* puf, Dims dims,
                        Rendering* rendering, RendererList* renderers,
                        OpList* ops) {
    // ... quit check ...
    try_dispatch(puf, dims, rendering, renderers, ops, opname);
}

void try_dispatch(Puffer* puf, Dims dims, Rendering* rendering,
                  RendererList* renderers, OpList* ops, char* opname) {
    // ... execute op ...
    command_loop_inner(&default_keymap, puf2, dims, rendering, renderers, ops);
}
```

- **Assumptions it bakes in:** no effect tracking — a function call is a
  function call regardless of side effects. The compiler doesn't distinguish
  pure from effectful at the call-graph level. Forward declarations are
  sufficient to resolve any mutual recursion. No typed SSA, no erasure pass,
  no crossing-wrapper expansion.

## 4. The chirality idea

- **Chirality features in play:** effect membrane (`->` pure vs `=>` process),
  typed SSA lowering (`lower.chiral` `compile-fn`), erasure (`tal-erase.chiral`
  `erase-fn` → neutral `NFn`), and the crossing-wrapper routing table
  (`crossing-wraps.chiral` E70).
- **The reframing:** chirality's back half already does a multi-pass shape:
  `def-sigs` collects all signatures first, then `lower-defs` compiles each
  body. The CEnv carries the full function table. The issue is NOT the lookup
  — it's that when compiling an effectful function's body, the SSA emission
  for an inter-function call to another effectful function differs from a pure
  call in a way that the erasure or outline step doesn't expect.
- **What chirality makes impossible here:** in chirality, effectful calls are typed
  differently than pure ones. The lowering partition checks `any-eff?` on
  binders and skips effectful defs from the *eligibility* gate (the partition
  slice in lower.chiral:82-94). But `compile-back.chiral` bypasses that gate
  and calls `compile-fn` directly. The mismatch is: the partition says
  "effectful stays upper" but the back half tries to lower them anyway. This
  is the tension — the partition and the back half disagree on whether
  effectful functions lower, and the mutual case exposes the gap.

## 5. Chirality example (fleshed)

The reproducer — two effectful functions calling each other:

```chirality
(import "prelude")
(import "ports")  ; provides put

; Two effectful functions in mutual recursion.
; Pure mutual recursion (-> → ->) compiles.
; Effectful self-recursion (=> → self) compiles.
; Effectful mutual recursion (=> → => → =>) fails.

(declare f (=> I64 Unit))
(declare g (=> I64 Unit))

(def f
  (lam (n)
    (case (=i n 0)
      (true unit)
      (false
        (let (_ (put "f"))
          (g (- n 1)))))))

(def g
  (lam (n)
    (case (=i n 0)
      (true unit)
      (false
        (let (_ (put "g"))
          (f (- n 1)))))))

; scriba's concrete shape: command-loop-inner calls try-dispatch
; via a case arm, and try-dispatch calls command-loop-inner back.
; The case creates a non-tail position that interacts with the
; effect chain counting or outline path.

(declare command-loop-inner
  (=> Keymap (Puffer Str) (Pair I64 I64) Rendering
      (List (Pair Str RendererFn)) (List ScribaOp) Unit))

(declare try-dispatch
  (=> (Puffer Str) (Pair I64 I64) Rendering
      (List (Pair Str RendererFn)) (List ScribaOp) Str Unit))

(def try-dispatch
  (lam (puf dims rendering renderers ops opname)
    (case (lookup-scribaop ops opname)
      (none
        (let (_ (put "\x07"))
          (command-loop-inner default-keymap puf dims rendering renderers ops)))
      ((some scribaop)
        (case scribaop
          ((op name fn doc)
            (let (puf2 (fn puf))
              (command-loop-inner default-keymap puf2 dims rendering renderers ops))))))))

(def command-loop-inner
  (lam (km puf dims old-rendering renderers ops)
    (let (ks (keyseq nil))
      (case (lookup-keymap ks km)
        ((some opname)
          (case (str-eq opname "quit")
            (true unit)
            (false (try-dispatch puf dims old-rendering renderers ops opname))))
        ...))))
```

- **Knobs to modify:** the specific effectful functions in mutual recursion —
  any pair of `=>` functions that call each other. The fix should generalize
  beyond scriba's specific shape.
- **Deliberately omitted:** the full scriba command loop (key parsing,
  rendering, keymap lookup). The minimal reproducer above — `f` calling `g`
  calling `f`, both `=>` — is sufficient to exercise the bug. If the case
  arm context matters (tail vs non-tail position), the scriba shape with a
  case discriminator between effectful calls should also be a test case.

## 6. Use / modify notes

- **Lands in:** `scaffold/lib/compile-back.chiral` (the `lower-defs` drive) or
  `scaffold/lib/lower.chiral` (the `compile-fn` / `tail` / `expr-app` /
  `build-outline` paths) or `scaffold/lib/tal-erase.chiral` (the
  `erase-instr-onto` crossing-wrapper expansion). Most likely a 2-3 line
  fix, not a new module.
- **Conformance target:** the minimal reproducer (`f` ↔ `g`, both `=>`)
  must compile through B1 and produce a runnable ELF. The scriba blob
  (334 forms + linkage) must produce `compile-main` label without error.
  Pure mutual recursion and effectful self-recursion must continue to work.
- **Open questions:**
  1. Is the break in the non-tail case outlining (`build-outline`)? When an
     effectful call is in a case arm, the outline path constructs a synthetic
     function — does the effect tracking carry through?
  2. Is the break in the erasure's crossing-wrapper expansion
     (`erase-instr-onto`)? The `cw-lookup` path expands a bound crossing into
     two instructions (call + Unit overwrite) — does this interact with the
     call graph?
  3. Does the partition gate (`eligible?` / `any-eff?`) interfere? The
     partition says effectful defs stay upper, but `compile-back.chiral`
     bypasses it. Does the native compiler's own effect chain limit
     (the ~3 ops threshold from E92) kick in when the lowered functions
     themselves have inter-function effect chains?
- **Related:** [[E92]] (effect chain decoupling), [[E93]] (pre-scan signatures),
  [[E94]] (form/type capacity), `.planning/handoffs/SCRIBA-DISPATCH-BLOCKER.md`
  (the handoff documenting the full state).
