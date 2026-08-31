---
element: E57
slug: staging-modality
title: Staging / binding-time modality (Fork C): link/load vs runtime carried in the type
kind: BUILD-PROPER
reference_class: PAPER
ours_source: (none)
status: drafted
updated: 2026-08-06
---

# E57 — Staging / binding-time modality (Fork C)

> One worked example, produced by the `worked-example` pre-run. Conventional
> approach vs the chirality idea, ending in a clear-cut snippet to copy and modify.

## 1. Scope

- **Element:** E57, the two-level staging spine — `□A` (static, known at compile
  time) and `○A` (dynamic, known at runtime) as type constructors. This is the
  smallest useful slice of Fork C: formalize the compiler's already-implicit
  stage distinction in the type system. Multi-stage generalization (compile →
  init → runtime → dynamic) is deferred.
- **Kind:** BUILD-PROPER — the decision is settled, the code is absent.
- **Why chirality needs its own:** the unbounded pregen policy needs to know which
  arguments are static. Currently `autospec` guesses from constant instructions.
  With `□`/`○`, the type declares statieness. A function `(□Keymap) → Key → Op`
  tells the compiler "specialize me on the keymap." Without this, unbounded
  pregen is either ad-hoc (current autospec) or requires programmer annotation
  at every call site.

## 2. Research

- **Reference class:** PAPER — Davies and Pfenning "A Modal Analysis of Staged
  Computation" (JACM 2001). MetaML/Taha and Sheard. The two-level lambda calculus
  with `□` (code) and `○` (next stage).
- **Key findings:**
  1. **`□A` is code for A at the current stage, `○A` is A at the next stage.**
     The judgment `Γ ⊢ e : A [s]` carries a stage index. `□A` can be spliced at
     the current stage; `○A` must be run at the next stage.
  2. **The compiler already has stages implicitly.** Surface→core is compile time.
     Tal→machine is link time. Machine execution is runtime. Fork C formalizes
     these as type-level stages rather than ad-hoc phases.
  3. **Two-level is sufficient for pregen.** The current use case is "this argument
     is known at compile time" vs "this argument is known at runtime." Two stages
     cover it. Multi-stage (N stages) is the generalization for self-similar
     process models (spawn stages a runtime that can stage another runtime) —
     not needed for unbounded pregen's first policy.
  4. **`□` composition:** `□(A → B) → □A → □B` — if you have code for a function
     and code for its argument, you can produce code for the result. This is the
     type-level version of partial evaluation: specialize the function on the
     static argument.

## 3. Conventional (other-language) approach

```ocaml
(* MetaOCaml: explicit staging annotations *)
let power (n : int) (x : int code) : int code =
  .< .~x * .~x >.   (* .< >. = code bracket, .~ = splice *)

(* The programmer manually brackets and splices. The type system
   tracks stages but the annotations are manual. *)
```

```cpp
// C++ constexpr: the compiler decides what's static
constexpr int factorial(int n) {
    return n <= 1 ? 1 : n * factorial(n - 1);
}
// If n is a literal, the compiler evaluates at compile time.
// If n is a variable, it evaluates at runtime.
// The programmer doesn't annotate stages — the compiler guesses.
```

- **Assumptions it bakes in:** MetaOCaml requires manual bracket/splice
  annotations everywhere. C++ constexpr leaves the decision to the compiler
  with no type-level guarantee — you can't write a function signature that
  *requires* a static argument. Both are ambient: any code can be staged,
  any code can be runtime. No permission model, no cost model.

## 4. The chirality idea

- **Chirality features in play:**
  - **Staging as a modality** — `□` and `○` are type constructors in the kernel,
    alongside `Pi`, `Sigma`, `Data`. The staging modality is a **property of the
    type**, not a compiler flag.
  - **QTT quantities interact with stages** — an erased (0) parameter is
    compile-time by necessity. A `□` parameter is compile-time by declaration.
    They compose: `□(0 A)` = "erased AND staged" — the value doesn't exist at
    runtime at all.
  - **Totality is the license** — only total functions can be run at an earlier
    stage (Fork B). `□(partial A)` is a type error — you can't precompute a
    potentially-diverging term.
  - **The effect membrane crosses stages** — `□(=> A)` is "code that will perform
    effects when run at the next stage." The stage boundary is a membrane crossing:
    you can't run `=>` code at compile time unless the compiler has a capability
    for that effect (e.g., file I/O at compile time needs a staged port).

- **The reframing:** conventional staging requires the programmer to annotate
  every bracket and splice. chirality infers stages from the call graph and the
  type annotations on entry points. `compile-main : □Source → ○Bytes` — the
  entry point declares its stage. Everything else flows from that. The compiler
  doesn't guess — it propagates stages through the program.

- **What chirality makes impossible here:** running `=>` code at compile time without
  a capability. Staging a partial function. Forgetting that a value is static and
  treating it as runtime (the type would mismatch). These are C++ constexpr bugs
  that chirality catches at compile time.

## 5. Chirality example (fleshed)

> **Notation.** `□A` and `○A` are kernel-internal type constructors (to be added
> by this element). The *surface syntax* the programmer writes is `(static A)` and
> `(dynamic A)`, which elaborate to `□` and `○` in the kernel. The code block
> below uses the surface syntax `(static ...)` / `(dynamic ...)`. References like
> \"the compiler propagates □\" describe the kernel-internal behaviour.

```chirality
; ── Stage modality types ──
; (static A)  = "available at this stage" (known at compile/link time)
; (dynamic A) = "available at the next stage" (known at runtime)
;
; These elaborate to kernel type constructors □ and ○, like Pi and Sigma.
; Stages are inferred from the entry point — the programmer declares the boundary.

; ── Entry point declares the stage boundary ──
; compile-main : (static Source) → (dynamic Bytes)
; "Given source text available at compile time, produce bytes at runtime"
(declare compile-main (-> (0 src (static Source)) (dynamic Bytes)))

; ── Aspirational helpers (not yet built) ──
(declare theme-fg (-> (static Theme) (static I64)))
(declare theme-bg (-> (static Theme) (static I64)))
(declare bcat (-> Bytes Bytes Bytes))
(declare r-text (-> Bytes Bool Rendering))

; ── A function parameterized by static config ──
; render-with-theme : (static Theme) → Str → (dynamic Rendering)
; "Given a theme known at compile time and a string known at runtime,
;  produce a rendering at runtime. The compiler SHOULD specialize on
;  the theme."
(declare render-with-theme (-> (0 theme (static Theme)) (0 s Str) (dynamic Rendering)))

(def render-with-theme
  (lam (theme s)
    ; theme.fg, theme.bg are known at compile time — the □ (static) propagates
    (let (fg ((theme-fg theme)))    ; fg : (static I64) — compile-time constant
      (let (bg ((theme-bg theme)))  ; bg : (static I64) — compile-time constant
        ; fg-str and bg-str can be precomputed from the static I64 values
        ; bcat of precomputed-Str + runtime-Str → the □ part folds at compile time
        (r-text (bcat (i64->str fg) (i64->str bg) s) false)))))

; ── The pregen call site ──
; specialize detects that theme is (static) and s is (dynamic).
; It binds theme to a static value at compile time.
; The residual: (-> Str Rendering) with no (static) parameter — the theme folds in.
; specialize(render-with-theme, {theme: dracula-theme})
;   → render-with-theme#dracula : Str → Rendering
;   → the fg/bg I64→Str conversions execute at compile time; only Str→Rendering
;     remains at runtime

; ── Command loop dispatch with static keymap ──
; dispatch : (static Keymap) → (dynamic Key) → (dynamic (Puffer A)) → (dynamic (Puffer A))
; Aspirational types: Keymap, Key, Puffer (not yet built)
(declare dispatch
  (-> (0 A (type 0))
      (0 km (static Keymap))
      (0 k (dynamic Key))
      (0 puf (dynamic (Puffer A)))
      (dynamic (Puffer A))))

; specialize(dispatch, {km: scriba-keymap}) produces:
; dispatch#scriba : (dynamic Key) → (dynamic (Puffer A)) → (dynamic (Puffer A))
; The keymap lookup collapses to a case tree at compile time.
; Every (dynamic Key) variant is a jump target. O(1) dispatch per keystroke.
```

- **Knobs to modify:** the stage depth (two-level vs multi-stage — the scaffold
  does two-level first), the surface syntax (the `(static A)` / `(dynamic A)` form
  shown above elaborates to kernel-internal `□`/`○`; a terser syntax like
  `[A]`/`@A` could replace the S-expression form later), the inference rules
  (how far does `□` propagate through let-bindings and case branches).
- **Deliberately omitted:** multi-stage (N stages — compile → init → runtime →
  dynamic), cross-stage persistence (values that survive from one stage to the
  next), staged effects (□(=> A) — code that performs effects at a later stage),
  the reflective floor (E45 — staged metaprogramming over typed terms).

## 6. Use / modify notes

- **Lands in:**
  - `scaffold/chirality/kernel.py` — `□` and `○` as type constructors in `Type`.
    The type universe grows: `Type = ... | Static(Type) | Next(Type)`.
    The judgment `Γ ⊢ e : A [s]` gains a stage index.
  - `scaffold/chirality/surface.py` — `(static A)` and `(dynamic A)` surface syntax,
    elaborated to `□` and `○`.
  - `scaffold/chirality/lower.py` — `□A` values are already erased (they were computed
    at an earlier stage). `○A` values become runtime TAL values. The lowering
    boundary is the stage boundary.
  - `scaffold/chirality/optimize.py` — `autospec` reads `□` annotations to decide
    which parameters are static (replacing the current "is it a const
    instruction?" heuristic).
- **Conformance target:** a function with a `□` parameter, called with a static
  argument, produces a residual that is preserve-checked and byte-identical to
  the original function called with the same static argument at runtime. The
  existing `specialize` test suite (test_optimize.py) is the oracle.
- **Open questions:**
  - Inference: does the compiler propagate `□` forward through the program, or
    do entry points annotate and everything else is `○` by default? (Answer:
    entry points annotate the boundary; the compiler propagates `□` forward
    through pure, total code. Effectful code breaks `□` propagation — effects
    happen at runtime, not compile time.)
  - Interaction with E38 (graded cost): does `□` carry a cost grade? (Answer:
    no — staging is a modality, not a grade. The cost of running `□` code at
    compile time is accounted by E38 as a separate concern. The type `□A` says
    *when* A is available; the grade says *how much* it costs.)
- **Related:** [[E57-staging-modality]] · [[E38-graded-cost]] · [[E17-optimizer]]
  · [[decision-graded-kernel]] (Fork C, settled) · [[modules-staging]]
  · [[E9-refinement-decision]] · [[E16-lowering]] · `.planning/FORK-C-UNROLLED.md`
