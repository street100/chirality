> **ARCHIVED 2026-09-01. Superseded by `.planning/archive/HANDOFF-POLY13.md`.** The mach-specialization mechanism this file mapped survives as `lib/lowering/upper/specialize-singleton.chiral`, which is live code and is the honest successor.

# Cluster 2 map — records-of-functions / HO in the emit image (measured)

> Produced 2026-08-03 by scripting the structure over `compile-emit`'s def
> bodies (`tools/map_cluster2.py`, reusable). Every number is measured, not
> reasoned. **Headline: the biggest specimen has the SIMPLEST fix — cluster 2 is
> NOT one defunctionalization build.**

## compile-emit skip buckets (with cascade): 237/351 lower
```
 51  CASCADE (downstream of the leaves below)
 34  body is not a lambda chain   ← all 34 are mach-* projectors
 14  field enc of a-rel           ← fn stored in a data field
 13  type does not lower          ← poly/HO collections
  3  partial application
  2  field pro of mach
  1  case on non-data
```

## The decomposition (3 sub-problems, DIFFERENT cheapest fixes)

### (1) The `mach` record — 36 defs — SPECIALIZE a singleton (NOT defunctionalize)
`Mach` is a 36-field record where every field is a function (the x86-64
instruction encoders) — a backend *dictionary/vtable*. Measured:
- **Exactly ONE `Mach` value is ever constructed: `x64`.** (`Con Mach` count = 1.)
- It is injected at **3 entry points** (`emit`, `emit-truthful`, `emit-param` —
  the only defs referencing the `x64` global) and **threaded as a `Var` param
  `m`** through **51** emit functions.
- **All 125 `mach-*` projector-application sites have a `Var` (threaded param)
  receiver** — zero abstract/alternative Machs.

⇒ Since the dictionary is a **known singleton**, inline `m := x64` through the
threaded functions and reduce `((mach-X x64) …)` to `x64`'s concrete field-X
encoder. The record-of-functions **vanishes** — no `$clo`/`$apply`. This is
partial evaluation of a global constant, not closure conversion. (E17 already
has a `specialize` pass — `specialize-raw`: remap + bind static args → residual.)

### (2) The `a-rel` fn-field — 14 defs — ALSO specialize (fn is statically known)
`(a-rel (sz I64) (enc (-> I64 Bytes)) (l Str))` stores a function in `enc`.
Measured across all construction sites: **`enc` is ALWAYS a known global encoder**
(11 direct globals: `enc-stheap`/`enc-cmpheap`/`enc-ldheap`/… + 1 partial-app of
`enc-jcc`). Never an abstract/varied closure; never projected+applied like a
vtable. ⇒ The stored fn is statically known at each site → **specialize**
(inline the known encoder, or carry a tag), same family as (1). No defunctionalize.

### (3) Poly/HO collections — 13 defs — the ONLY genuine defunctionalization
`foldl foldr alist-get alist-put alist-has m-lookup m-insert m-insert-new
m-delete m-fold …` — poly functions taking a function param, varied at call
sites. This is **B2 layer 2**, the real closconv work, and the FRONTIER-MAP flags
it **entangled with B6** (the image split): the concrete closure sites live
across the 3-image split, so per-image lowerability undercounts and layer-2
collection can't be cleanly validated until the image story (unify vs shuttle)
is settled. Scope L2 + B6 together.

## The inversion (why this matters)
The "crux specimen" — the 36-field `mach` record, the biggest single leaf — is
the **simplest** fix (specialize one known global), NOT the hardest. Defunction-
alization is needed for only the **13 poly-collection defs**, and those are
gated on the B6 image decision anyway. So ~50 of the ~63 cluster-2 leaves
(mach 36 + a-rel 14) clear via **one specialization pass**, no closure conversion.

## Approach + the one design fork (author call)
Two routes for the specialize work, both far cheaper than defunctionalization:
- **A. Compiler specialization pass** — inline the singleton `Mach` (and known
  `a-rel` encoders) at lower time. Keeps the source abstraction (the `Mach`
  record stays, so a second backend is still expressible); the lowering
  monomorphizes it. General; clears mach + a-rel together. Mirror in chirality for
  the fixpoint; differential vs Python.
- **B. Source de-abstraction** — drop the `Mach` record, call the x64 encoders
  directly. Smaller change, but loses the "swap backends" design intent and
  doesn't generalize.

**Recommendation: A** (keep the abstraction, specialize in the compiler) — it is
the general answer, composes with a-rel, and preserves the backend-swap design.
**Fork is the author's** (keep-abstraction-and-specialize vs de-abstract-source).

### ⚑ Route A PROTOTYPED (2026-08-03) — it is a partial evaluator, not a rewrite
Spiked A end-to-end on compile-emit (rewrite `(mach-X _)`→`x64.field`, retype
Mach params q0, prune projectors+x64). Findings that resize A:
- **Inlining alone does NOT lower** — `(mach-X m)`→field-lambda leaves an
  `(App (Lam…) arg)` **beta-redex** the lowerer rejects ("higher-order
  application"). A needs real **beta-reduction** (de-Bruijn substitution) after
  inlining, not just a rewrite.
- **Kernel NbE can't do it here** — `eval_term`+`quote` (which would beta-reduce
  while keeping globals neutral) throws *"stuck case in type-level computation
  (scaffold limit: no case in types)"* on the core drivers (`emit-fn`,
  `emit-with`, `emit-data`). So a custom beta-reducer is needed, not free NbE.
- **Retype must be total** — only 13 defs directly project; 51 THREAD the Mach
  param, so every Mach param (any position, incl. nested VPi cod) must be q0'd
  together for B1 to erase them consistently. The first-param-only spike left
  most threaded params typed `w` → still un-lowered.
So route A ≈ a **partial evaluator** (inline + de-Bruijn beta-reduce + total-q0
retype + prune) **plus its chirality mirror**. Real, sound, but a multi-slice trusted
build — NOT the quick coverage slice the leaf-count implied.

**Reassessed fork:** given A's true cost, **route B (source de-abstraction)** —
lift `x64`'s 35 fields to named globals, replace `(mach-X m)` with the direct
encoder global, drop the Mach param from the 51 emit defs — is a bounded one-time
source edit with **no new compiler pass and no chirality mirror** (the source is just
directly lowerable). It loses the backend-swap abstraction (against chirality's
"architecture over convenience"), but it reaches full emit coverage far sooner.

### ⚑⚑ The tractable path — a THIRD option (lift-and-reference as a PASS)
A's fatal move was *inlining the field LAMBDA* (→ beta-redex → NbE → kernel
limit). The fix: **lift** `x64`'s 35 fields to fresh globals (`x64$0…x64$34`)
and rewrite `(mach-X m)` → `(Global x64$idx)` — a direct **call**, not an applied
lambda. **No beta-redex, no normalize, no kernel limit.** As a compiler pass it
also **keeps the source abstraction** (the `Mach` record stays; the pass lifts +
rewrites at compile time) — so it dominates both pure-A (no partial evaluator)
and pure-B (no source de-abstraction). The pass:
1. lift: `x64$i := fields[i]` (declare/install 35 globals);
2. rewrite: `(App (Global mach-X) _)` → `(Global x64$idx)` (single Mach ⇒ receiver
   discarded); projector-app spines become ordinary global calls;
3. **eliminate the threaded Mach param** — the one remaining hard part, shared by
   ALL routes: 51 defs thread `m`, so every Mach binder must go (drop the binder +
   de-Bruijn-shift the body + drop the arg at every call site, OR total-q0 retype
   so B1 erases them). This is the de-Bruijn-sensitive slice;
4. prune the now-dead `mach-*` projectors + `x64`.
Then mirror in chirality for the fixpoint (steps 1–2 are pure Term surgery; the chirality
mirror is mechanical). **Recommend this lift-and-reference pass.** The remaining
uncertainty is purely step 3's param-elimination mechanics — the fresh-focus,
one-edit-at-a-time slice to build next. **The route choice (this pass vs source-B)
is the author's**, but the pass is now the recommended default.

## ⚑⚑⚑ ENTANGLEMENT (2026-08-03, measured) — the sub-problems are NOT independent
Built the lift-and-reference mach pass end-to-end (`tools/spec_mach_probe.py`):
the **mechanism is validated** — rewrite `(mach-X m)`→`(Global x64$idx)` + total-q0
retype work, and `emit-instr` then cascades cleanly on `x64$3` alone (Mach param
gone). BUT compile-emit coverage did **not** climb, because the emit cascade is:
```
emit-fn → emit-code → … → mach fields (x64$i) → wrap → one-b → a-rel(fn-field)
                                              ↘ x-alo / x-fin → a-rel
        …and foldl / alist-get / m-lookup (poly-13) throughout
```
So **mach, a-rel, and the poly-13 are ONE coupled cascade** — solving mach alone
moves 0 defs; they climb together or not at all. Field kinds also vary: some
`x64` fields are lambdas (`pro`/`con`), some bare `(Global x-Y)` references
(`fin`/`sys`/`alo`) — the reference fields need **eta-expansion** to lift as
lowerable defs (a bare `(Global x-Y)` is "not a lambda chain").

**Revised chunk:** cluster 2 is a single coupled build =
(a) mach lift-and-reference (mechanism validated; eta-expand reference fields) +
(b) a-rel specialize (same family — `enc` is always a known encoder) +
(c) poly-13 defunctionalize (B2-L2), all landed together, then emit coverage
climbs. Each with a chirality mirror. This is a multi-slice trusted build, correctly
sized only now. `tools/spec_mach_probe.py` is the validated mach-mechanism
reference for the port.

## ✅ RESOLUTION (2026-08-03) — mach + a-rel DONE; poly-13 is B6-gated (proven)
Built and landed:
- **mach specialization** — `chirality/specialize.py`, hooked in `lower_all`: lift the
  singleton's lambda fields to globals + point reference fields at the underlying
  encoder + total-q0 retype the threaded param + prune. mach-* gone, no regression.
- **a-rel defunctionalization** — `EncTag` sum + `apply-enc` (inlined x86 bytes,
  no module cycle). BYTE-CORRECT (ELF differential green).
- **compile-emit lowerability 237 → 271** (the "field enc"/"not a lambda chain"
  leaves eliminated). 649 green throughout, each a clean commit.

**poly-13 is genuinely B6-gated (measured, not guessed):** in the isolated
compile-emit image `str-eq` is **absent** and `alist-get`/`alist-put` are called
with a **`Var` comparator** (threaded across the image boundary) — the concrete
closure site lives in the FRONT image. So per-image defunctionalization has
nothing to collect; it needs the 3-image story resolved (unify the reps into one
image [C1a], where `str-eq` is present, OR a cross-image closure protocol).
**This is the same B6/C1b decision** — so poly-13, the single-artifact, and the
fixpoint all unblock from ONE architecture call. Remaining tiny leaves
(x64$1/$2 partial-app from the lifted `=>` fields, `$apply0` case-on-non-data,
`x64-peep` HO) are separate and small.

## ⚑ THE PRINCIPLED PATH: rep-unification (P3/P5) — IN PROGRESS
poly-13 is B6-gated; the principled fix (not the shortcuts) is to pay the dedup
debt so the compiler is ONE program: the 3-image split is the compiler
REINVENTING its reps (P3 violation) joined by a con-value shuttle (P5: a runtime
seam that can't carry closures). Enumerated: **12 cross-image name collisions**
(script: transitive-import disambiguation, 0 seam modules). Resolved so far
(each a commit, 649 green):
- **3 helper name-clashes** renamed (ssa-fresh / drop-last-env / resolve-label).
- **5 dual-meaning IR types** distinguished (P6): TalTerm (vs kernel Term), TIFn
  (vs tal-ssa TFn), LCore/LCArm/LowBind (vs surface Core/CArm/LBind).

**Remaining to one-image co-load (the harder tail):**
- **Constructor collisions** — `t-case` is a ctor of kernel `Term` AND tal-ssa
  `TalTerm` AND tal-ir `TCode` (3 stages); renaming ripples into the Python tal
  machine (`native.py`/`tal.py` string tags, distinct from `kernel.py`). Likely
  more shared ctors (`dctor`, …). Each needs the 3-stage-distinct rename +
  Python sync.
- **The 4 true-duplicate helpers** (llen/snoc/find-ctor/all-in) — merge to a
  shared leaf.
- **tal-ssa vs tal-ir** — two tal IRs; P3 wants ONE (a semantic merge), else
  3-stage-distinct ctor names.
Then: load the compiler as one Sig → `str-eq` present with `alist-get` → poly-13
defunctionalizes → emit fully lowers → single artifact → fixpoint. This is a
multi-session milestone; the type-level bulk is done, the ctor-level + wiring
remain.

## What stays hard / gated
- The 13 poly-collection defs (defunctionalization, B2-L2) — gated on **B6**
  (unify-reps vs con-value-shuttle), which is also the C1b linker-vs-pipeline
  fork. So the last hard coverage bit and the single-artifact architecture are
  the same decision.

## Reusable measurement
`tools/map_cluster2.py` **(DELETED 2026-08-22 — H4b)**. It was an
interpreted-compile tool (drove CPython over the compiler source) and was already
broken (`KernelError: effectful application inside a pure function` on
`compile-emit.chiral`). Its question — specialize vs defunctionalize — was answered
by E70; the numbers below are its preserved output. To re-measure, write a chirality
root program (entry `compile-main`) rather than resurrecting it. Formerly re-run to track: Mach-value count (must stay 1),
projector-receiver kinds, a-rel enc shapes, and the per-leaf buckets.
