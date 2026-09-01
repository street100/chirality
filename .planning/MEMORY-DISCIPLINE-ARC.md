# The value-heap discipline arc (design lock, 2026-08-05)

> Scoped slice plan for the value-cell heap's composable memory-discipline seam.
> Catalog rows: E81–E85 (section XIII of `SELF-IMPLEMENT-CATALOG.md`). This file
> is the arc's authority: what each slice delivers, its size, its gate, and the
> sequencing. Each slice = ONE element through the pipeline
> (example → audit → spec → audit → implement), independently committable, sized
> so no slice expires the batch. Stop cleanly between any two.

## Why (the residue the self-compile surfaced)

chirality has **two heaps**; only one has a discipline seam.

- **byte-Pool heap** — `(Pool n)`, explicit offsets. Governed by
  `(memory linear|region)` profile clauses. Built (E22).
- **value-cell heap** — every constructor `x-alo` bumps `heapptr`
  (`lib/mach-x64.chiral`). Governed by **nothing**: raw no-reclaim bump. Cost =
  total-allocation-ever, NOT live-set. This is the 12 GB the self-compile churns
  before the arena-exhaustion `ud2` (core-verified: trap in `nb-bcat` mid-emit,
  heapptr 260 KB from a 12 GB heapend, ~12 GB churned).

The fix is not "add an allocator" (the textbook bump/region/GC trichotomy — the
rejected half-assed framing). It is: **give the value-cell heap the same
composable-moduleset seam everything else in chirality has** — a frozen allocation
seam, conforming discipline instances, selected per-phase and per-runtime by
profile, seam erased at compile time by `specialize-singletons`. This is
`Mach`-for-memory: the backend is already a record-of-functions with conforming
instances (`mach-x64`, `mach-listing`) whose seam `specialize-singletons` removes
at compile time. Allocation gets the identical treatment.

## What chirality's architecture uniquely unlocks (research → fit)

The disciplines worth building are the ones chirality's machinery makes near-free
that conventional languages bolt on. Ranked by fit × leverage on the 12 GB:

1. **Linear in-place / FBIP / DPS (E83, E84)** — Perceus is formalized in a
   *linear resource calculus* and spends a whole paper recovering the uniqueness
   chirality **already has** as a type property (E8 linear-kind, built). A linear
   cell's refcount is provably 1 → drop→reuse is a compile-time in-place update,
   no runtime RC. DPS is "purely functional via linear types." **This is the
   direct kill for the bulk of the 12 GB** (map-insert churn + the `nb-bcat`
   emit quadratic). Linearity is the cheat code.
2. **Phase / scope regions (E82)** — Tofte–Talpin phase regions; Effekt
   second-class regions *passed to functions* (chirality's exact design, shipped);
   Spegion (2025) sized/non-lexical regions via effects. chirality has BOTH linear
   types and an effect membrane → region-safety either way, per profile. The
   composability spine.
3. **Allocation-as-typed-port / the seam (E81, E85)** — literally chirality
   ("space is a port", P3). From-Capabilities-to-Regions + Yarrow (2026) are the
   compilation story for chirality's own effect-membrane↔region design. Zig passes an
   allocator dynamically; chirality passes it typed + linear, seam erased by
   specialize. The enabling mechanism, zero runtime cost.
4. **bump** — today's floor, re-cast as the trivial conforming instance (E81a).
5. **Tracing GC** — wrong tier for the TCB; a Category-C module permissive
   profiles opt into (`chirality-app`), never Category-A. Deferred (non-LIFO
   lifetimes only, which the compiler doesn't have). E22 residue already names it.

## Per-phase AND per-runtime (the payoff, once E81 exists)

- **Per-phase** (rustc's per-phase typed arenas, but type-enforced +
  profile-composed): front (NbE, short-lived closures) → region, reset at
  front→back; back (SSA) → region, reset at back→emit; emit (one growing buffer)
  → DPS; tree-maps → reuse/FBIP.
- **Per-runtime** (already the design's shape — `chirality-app` permissive vs
  `chirality-bare`/`chirality-firmware`): interpreted stage → discipline is a no-op
  (host GC); native stage → region+reuse+dps. Same source, different profile,
  different discipline — resolved at composition time, seam erased by specialize.

## The five slices (dependency-ordered)

```
E8 linear-kind (BUILT) ─┐
specialize-singletons ──┤
Mach precedent (BUILT) ─┴─► E81 SEAM+bump ──┬─► E82 region  ──► [A4 fixpoint lands here]
                                             ├─► E83 reuse/FBIP  ┐
                                             └─► E84 dps         ┴─► E85 compose + E38 grade
```

**⚑ E81 design RESOLVED (example audit 2026-08-05):** allocation is *already* a
`Mach` field (`alo`), so E81 adds the discipline *dimension*, not the site seam.
Shape = a **separate `Alloc` policy record whose ops take the `Mach` and compose
its primitives** (ISA-agnostic — one `alloc-region` runs on every backend),
threaded orthogonally to `Mach`; a profile selects `{ISA}×{discipline}`
independently. NOT folded into `Mach` (couples discipline×ISA) and NOT per-ISA
(re-writes region logic per backend). ISA-specific alloc asm stays in `Mach`
primitives (`alo`, `bnw`, E82's save/restore-`heapptr`). Load-bearing for
E82–E85. See `examples/E81-alloc-seam.md`.

| Slice | Element | Delivers | Gate | Size | Rung-1? |
|-------|---------|----------|------|------|---------|
| 1 ✅ | **E81** `Alloc` policy seam + `alloc-bump` (DONE d6ad519) | discipline dimension over the Mach vocabulary; bump delegates to `mach-alo`/`bnw`, no-op region/drop | **program-level byte-identity** (specialize collapses the chained projection via the sp-rw head-recheck fix); 668 green + 3 seam tests | M | critical path |
| 2 | **E82** `alloc-region` | phases run in regions, reset at boundaries; peak → max-phase live-set | self-compile peak drops to low-GB; **A4 byte-compare fixpoint holds on a normal machine** | M–L | critical path |
| 3 | **E83** `alloc-reuse` (FBIP) | linear drop→reuse in-place; map churn gone | cross-discipline differential (bump vs reuse = identical result, lower peak) | M–L | post-rung-1 |
| 4 | **E84** `alloc-dps` | destination-passing emit buffer; `nb-bcat` quadratic gone | cross-discipline differential; emit peak flat in output size | M | post-rung-1 |
| 5 | **E85** compose + grade | per-phase + per-runtime profile composition; optional E38 static size bound | compiler profile composes region/dps/reuse; interpreted vs native differ by profile | M | post-rung-1 |

## A4 / rung-1 interplay (decision: land the fixpoint properly)

**E81 + E82 are the honest A4 unblock.** Phase-region reset takes the self-compile
peak from Σ-allocation (~12 GB+) to the largest single phase's working set (low
single-digit GB) → fits a normal laptop, and the fixpoint we then celebrate is
the real one, not one that needs a 64 GB host swapfile nobody else has. E83/E84/E85
make it fast and tight (kill the specific quadratics) but are NOT A4 gates.

Interim (if a fixpoint check is wanted before E82 lands): the 48 GB NORESERVE
arena + host swap is the throwaway path — it proves the byte-compare but on a
non-portable machine. The arc above is the durable answer.

## Conventions for this arc

- Each slice is ONE element through the full pipeline; commit each finished +
  verified slice before the next (no batch pileup).
- The cross-discipline differential is the strongest gate this repo has: the same
  program under two disciplines must produce **identical output**, with measured
  peak-memory bounded by live-set under the reclaiming discipline.
- E22 is NOT reopened. E82 reuses E22/E41 region-type machinery (the ρ-brand /
  arith bound) for its typed tier; the byte-Pool region types stay E22's.
- P4 stays intact: source keeps the discipline abstraction; the compiler
  (`specialize-singletons`) removes the seam. Bump, region, reuse, dps are
  conforming instances — conformance, not configuration.
