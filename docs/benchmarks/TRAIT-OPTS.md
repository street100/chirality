# Trait-native optimization survey (research → example, per trait)

Companion to `OPT-CHECKLIST.md`. That list plays gcc's game (ambient loop
optimization — regalloc, branches); this one inventories the second axis:
transforms licensed by facts the chirality checker has already **proven**, which
an untyped IR cannot have at any -O level. Method per trait: precedent
research (who did it, what it bought, what it cost them) → a concrete example
site in THIS tree (file:line, before/after shape). Status 2026-08-01 EOD: the emit-time
slices of T1 (lookup tables), T2 (total-call folding), T3 (CSE), and T4
(constant-divisor guard elision) are LANDED and measured -- run 5 in
RESULTS-2026-08-01.md: native 2-6x faster than gcc -O0, 1.7x-9.5x behind
-O2, whole-day native speedups 2.6x/8.3x/2.8x at equal guest load. T6's first BOUNDED
auto-pregen policy landed 2026-08-02 (optimize.autospec: const-arg call
sites -> deduped preserve-checked residuals, recursion+size guarded,
D-2-deterministic; px specializes on all 5 constant RGB triples in the
corpus; the unbounded policy remains the staging-modality decision) plus
pure-call CSE and a memoized comptime evaluator. T4's fact-carrying half
and T5's codegen half remain open; each entry names its seat and lane.

The organizing principle (P5 applied to optimization): **carry facts down
instead of re-deriving them.** gcc's optimizer = analysis (recover facts
from untyped IR) + transform-where-recovery-succeeds. chirality's checker already
holds the facts; the optimizer's job is to not lose them on the way to the
floor. Preserve-check + differential testing keep every transform honest.

---

## T1. Dense tags → jump/lookup tables

**Trait.** Constructor tags are dense integers `0..n-1` *by declaration
order, by construction* (`data.py` order; `_tag_of`). No density analysis
can fail.

**Research.** OCaml is the exact precedent: variants compile to integer tags
in declaration order, and the Lambda backend compiles `match` to a switch —
a **jump table** for control dispatch, and (their sharper trick) a **lookup
table** when every arm returns a constant — with conditional jumps only when
the variant count is small. gcc must *reconstruct* case density and bails to
chains when unsure; OCaml never analyzes because density is representation.
chirality is in OCaml's position, one floor lower.

**Example found.** `bench/kernels.chiral:70` `sk-next` — 5-way `case` over
`SK`, today a linear cmp/jne chain per iteration (the states kernel's
branch-bound 12×). And `kernels.chiral:67` `sk-code` is the *lookup-table*
shape: every arm a constant → `mov rax, [table + 8*tag]`, zero branches.
`sk-from` (`:79`) is a cmp-chain over integers with the same table shape.

**Seat/size/lane.** New Mach op (`tbl`) + emit-core case analysis; data
tables via the existing literal/`a-label` machinery. Medium; natural E17-family
item. Attacks: states' 12×, every FSM.

Sources: [OCaml compiler backend](https://ocaml.org/docs/compiler-backend) ·
[Real World OCaml: the compiler backend](https://dev.realworldocaml.org/compiler-backend.html) ·
[ocaml/ocaml#9741 lookup vs jump table](https://github.com/ocaml/ocaml/issues/9741)

---

## T2. Totality proof → unbounded compile-time evaluation

**Trait.** `check_termination` *proves* structural/measure recursion total
(`sig.totality`). A proven-total pure function applied to constants can be
fully evaluated at compile time with **zero divergence risk** — the fold may
simply run the reference interpreter.

**Research.** Zig's comptime evaluates anything but guarantees nothing — the
compiler can hang, and heavy comptime measurably blows up compile times
(reported 4.2 s vs 0.3 s for a DNS parser vs C). C++ `constexpr` bounds the
same risk with arbitrary step/depth limits. Both are fuel-or-faith. The
total-languages line (Agda/Idris normalization) is safe but pays for it with
totality-only programming. chirality sits in the sweet spot neither reaches:
*partial* language, but the checker CLASSIFIES totality per function — so
compile-time evaluation is unbounded exactly where the proof exists, fueled
nowhere.

**Example found.** `demo/sprites.chiral:58` `row-bytes` — proven total (the
measure pillar's flagship), called at `:71` as `(row-bytes r 0)` where every
`r` is a literal 16-char row string (`rr-full`, `rr-smile-a`, …). The whole
256-byte pixel row — and the `(brepeat … 4)` around it — is compile-time
computable; today it re-renders per draw at runtime. Folding it embeds the
rendered row as a literal cell: compile-time sprite rendering, licensed by a
termination proof.

**Seat/size/lane.** `optimize.py` fold: when every arg of a `call` is a
known constant and `sig.totality` is proven for the whole call graph of the
target, evaluate via the reference interpreter and emit the constant
(word-rep results; literal cells for Bytes/Str). Small-medium, Python-side
now, ports with E17. gcc structurally cannot make this move.

Sources: [Zig comptime overview](https://renato.athaydes.com/posts/comptime-programming) ·
[Zig comptime as unified system](https://lucioduran.com/blog/zig-language-comptime-system-programming) ·
[constexpr (limits)](https://en.wikipedia.org/wiki/Constexpr)

---

## T3. Purity + strictness → unconditionally safe CSE/hoisting

**Trait.** The lowered fragment is pure by construction (effects never
lower) *and* strict with word-rep values — a shared subexpression is a slot,
never a thunk.

**Research.** The cautionary precedent is GHC: CSE in a *lazy* language can
convert constant-space programs into linear-space ones (retained shared
structures), so GHC does CSE only in narrow circumstances and full laziness
is deliberately incomplete — Chitil's line of work is titled, tellingly,
"Common subexpressions are uncommon in lazy functional languages." Every one
of those hazards is a laziness artifact. In a strict, pure, ground-typed
fragment the transform is unconditionally safe: sharing a computed word
costs one slot, and there is no effect/alias analysis to run first because
purity is in the arrow, not inferred.

**Example found.** Live double-computes in the tree:
`lib/json.chiral` `parse-members` recomputes both `(blen b)` and
`(bget b r)`; `scan-uescape` and `parse-elems` double `(blen b)`/`(bget b k)`;
`lib/wire.chiral` `wsplit1` doubles `(blen buf)`. Each is a redundant
load-or-call in parser hot paths.

**Seat/size/lane.** A tal→tal CSE pass in `optimize.py` (value-numbering
over the SSA lowered form — SSA by construction makes this a dictionary
walk, no dominance analysis needed for straight-line + tree-shaped cases).
Small-medium; E17-family; preserve-checked like fold/dead.

Sources: [Chitil 1997, CSE in a lazy functional language](https://www.cs.kent.ac.uk/pubs/1997/1904/content.pdf) ·
[Common subexpressions are uncommon in lazy FLs](https://link.springer.com/content/pdf/10.1007/BFb0055424.pdf) ·
[GHC optimisation guide](https://mpickering.github.io/users_guide/using-optimisation.html)

---

## T4. Refinement proofs → runtime check elision

**Trait.** Refinements (`v ≥ 0`, `v < n`, path-sensitivity) prove value
ranges at compile time; a proved fact makes its runtime guard dead code.

**Research.** Bounds-checking elimination is a whole compiler subfield when
facts must be *recovered* (loop/range analysis, speculative guards); with
refinement types the checks are discharged by the type system and extraction
simply omits them — the LiquidHaskell/F* line: verify the refinement
statically, emit the unguarded access. The performance story writes itself:
the safe path IS the fast path; C gets the fast path only by dropping the
safety.

**Example found — one built, two next.**
- **Built (the trait working today):** `lib/mem-linear.chiral:26`
  `mem-put-checked` — the pool-offset bounds check exists only as the
  refinement `(refine I64 (>= 0) (< n))`; the substrate's runtime witness is
  discharged at compile time (F8's offset half). This is check elision in
  production, upstream of codegen.
- **Next, needs no new plumbing:** constant-divisor guard elision. The
  emitted division guard (test/ud2 + cmp −1/branch, `mach-x64.chiral`
  `x-guarded`) is statically decidable whenever the divisor is a known
  constant ≠ 0, ≠ −1 — which `bini` already knows. `bench/kernels.chiral:29`
  `arith-inner`'s `% 1048573` pays the full guard every iteration today.
- **Next, needs fact-carrying lowering:** Euclidean-correction elision. The
  7-instruction sign-fix (`x-mod-fix`) is dead when the *dividend* is proven
  ≥ 0 — `arith-inner`'s `acc` is `% 1048573`-bounded (∈ [0, 1048572]) and
  `i` counts up from 0; path-sensitivity can prove both, but refinement
  facts do not survive lowering into tal yet. THAT is the architectural
  item: extend the tal type carrier with range facts (E9 × E16 lane).

**Seat/size/lane.** Guard elision: few lines in `bini-body` (now). Fact
carrying: lowering + tal signature extension (E9/E16 lane, the real prize).

Sources: [Bounds-checking elimination](https://en.wikipedia.org/wiki/Bounds-checking_elimination) ·
[Intro to refinement types (LiquidHaskell)](https://ucsd-progsys.github.io/intro-refinement-types/120/02-refinements.html) ·
[Refinement Types for TypeScript (verified array safety)](https://arxiv.org/pdf/1604.02480)

---

## T5. Linearity → in-place reuse without inference

**Trait.** A `1`-quantity binder is a static single-owner proof. No
refcount, no uniqueness inference: the license to mutate in place is in the
kernel judgment.

**Research.** The state of the art infers what chirality declares: Koka's
Perceus does precise reference counting and reuses a cell **when the runtime
refcount is 1** (FBIP — "functional but in-place"); Lean 4 does the same
(destructive updates behind `refcount == 1` checks); FP² (ICFP'23) adds a
calculus proving full in-placeness — implemented, again, over Perceus
counts. All pay either a dynamic check or a new type discipline. chirality's QTT
quantities already ARE that discipline, in the trusted core: a linear
consumption site needs no check at all — the compile-time quantity is the
refcount-is-1 proof.

**Example found — one built, one next.**
- **Built (type level):** `lib/mem-linear.chiral` — `pool-write` threads
  `(1 p (Pool n))`; the linear pool is the in-place discipline as a type.
- **Next (codegen level):** the `bcat` chains. `lib/json.chiral:165-172`
  (UTF-8 emission) and every string-builder loop allocate a **fresh arena
  cell per concatenation** — O(parts) cells, O(n²) bytes copied for an
  n-part build. A `bcat` whose left operand is linear *and* bump-top
  (the last allocated cell — trivially decidable in a bump arena) can
  extend in place: zero copy, zero new cell. Arena + linearity compose
  into an optimization neither licenses alone.

**Seat/size/lane.** Needs quantities to survive lowering (today `q != W`
binders stay upper — E16 decision #3's widening) plus a bump-top check in
the allocator path. The far side of the fact-carrying-lowering road; E16/E69
lane (capture records carry quantities).

Sources: [Perceus: garbage-free RC with reuse (MSR)](https://www.microsoft.com/en-us/research/uploads/prod/2020/11/perceus-tr-v1.pdf) ·
[FP²: Fully in-Place Functional Programming](https://webspace.science.uu.nl/~swier004/publications/2023-icfp.pdf) ·
[The Koka book](https://koka-lang.github.io/koka/doc/book.html)

---

## T6. specialize/pregen → staged specialization as the default posture

**Trait.** `specialize` is a language-level primitive (partial evaluation
binding static args → preserve-checked residual), not a compiler heuristic.

**Research.** This is the Futamura-projection lineage: specializing a
program to known inputs removes interpretive overhead — the first projection
turns an interpreter+program into a compiled program, and it is *in
production* as PyPy/RPython and Truffle/Graal, where partial evaluation of
an interpreter against a user program yields optimizing-compiler output.
LMS/MetaOCaml expose the same as staged programming. The recurring result:
specialization on static structure beats generic dispatch by constant
factors that generic optimizers never recover, because the staticness is
invisible to them.

**Example found — one built, one next.**
- **Built:** `chirality/optimize.py:282` `specialize` +
  `test_specialize_collapses_dispatch` / `test_specialize_residual_runs_natively`
  — dispatch on a bound constructor already collapses to the selected
  branch, and the residual already runs natively. The mechanism exists
  end-to-end.
- **Next (the posture):** `lib/fsm.chiral:29` `fsm-run` is a miniature
  first Futamura projection waiting to happen: specialize the run loop to a
  concrete static `trans` function and the event dispatch collapses to
  straight-line transitions — the states kernel's `sk-next`-shaped code is
  exactly what falls out. Same shape: the prapanca coordinator's fixed tool
  table, HTTP route dispatch, any static config. What's missing is not
  mechanism but **policy**: when does the toolchain auto-specialize?
  That's the staging-modality decision (Fork C, decision-graded-kernel) —
  the E17-family wiring rides it.

**Seat/size/lane.** Mechanism built; policy = staging modality (Fork C);
auto-application wiring = E17 family + `chirality lower`/`pregen` CLI surface.

Sources: [Futamura projections](https://en.wikipedia.org/wiki/Futamura_projection) ·
[Practical second Futamura projection (Truffle/Graal)](https://dl.acm.org/doi/10.1145/3359061.3361077) ·
[Staged abstract interpreters (LMS)](https://www.cs.purdue.edu/homes/rompf/papers/wei-oopsla19.pdf)

---

## The honest boundary

Two things the traits do NOT buy, so this file can't be read as "types
replace optimization":

1. **Slot round-trips are semantics-blind.** bytesum's residual 5.9× is
   store/load traffic; no proof eliminates it — that's OPT-CHECKLIST item 8
   → real regalloc, table stakes both sides pay.
2. **Fact-carrying lowering is the gate.** T4's correction elision and all
   of T5's codegen half wait on refinement/quantity facts surviving into
   tal. Until that lands, the trait axis reaches only what emit-time
   constants already expose (T1, T2, T3, T4's guard elision, T6).

Ranked by payoff-per-line today: T4 guard elision (few lines) → T2
total-call folding (small-medium) → T3 CSE (small-medium) → T1 tables
(medium) → T6 policy (decision-gated) → T5 codegen (furthest, biggest
architectural pull).
