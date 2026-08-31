# Staging chirality with zero Python — the slice plan

Goal: the chirality compiler compiles the chirality compiler's OWN source to a native
binary, that binary recompiles the source (Stage1==Stage2 byte-identical), and
**nothing in the path is CPython** — not the compile, not the orchestration, not
the file write/exec. Today: the compile LOGIC is chirality; Python still (a) shuttles
con-values between the 3 collision-forced images and (b) writes+exec()s bytes.

Where we are (session 4): the chirality compiler compiles+runs native, poly + HO-poly
+ externs + strings + string-ops + whole multi-def modules (prelude+collections
+sexp = the reader). Skip+prune+filter-erasable make whole-module compiles robust.

## Tier A — COVERAGE: every reachable compiler def lowers (bounded slices)
- **A1. Effect `=>` defs + the sys face in the compile path.** The compiler reads
  source and writes output through syscall crossings (read/write/mmap/open). E70
  routes a bound crossing as `prim <crossing>` → E51 wrapper → syscall. Today the
  chirality compile-fn leaves `=>` defs upper. Needs: the effect gate opening in the
  chirality peel/lower (a def whose crossings are all E51-bound lowers like a pure fn)
  + native routing of the crossing prim to the syscall wrapper (mach layer).
- **A2. closconv §6 — nested closures.** A closure capturing a FUNCTION (e.g.
  `m-insert-new` captures `cmp`), or nested/linear captures. Today left unconverted
  → the def skips. Needs the chirality closconv-driver to convert function-capturing
  sites (the arrow-typed capture field → a `$clo` field).
- **A3. Prim / data-model edges** each module surfaces (measured module-by-module).

## Tier B — the compiler's OWN source as input
- **B1. Resolve `(import …)`.** Either (a) a chirality file-read loader
  (`import` → sys open/read the file → parse), needing the sys face; or (b) whole-
  source concatenation (dedup imports) fed as one string. (b) is simpler but hits
  the 3-image collision (Tier C) head-on. Decide with the author.

## Tier C — a SINGLE native artifact (the 3-image collision, B6 — the crux)
The compiler is 3 collision-forced images (kernel `Term` / lower `TFn` / emit
`TFn` can't co-load: flat namespace). For a runnable self-compiled compiler the
emitted code must be ONE binary. Options:
- **C1a. Unify the reps** — rename the tal-ssa/tal-ir `TFn`/`t-case` collisions
  and unify kernel-`Term`/surface-`Core`/lower-`Core` into one IR. Clean, large.
- **C1b. Link 3 separately-emitted images** into one ELF (each image's fns are
  labels; the driver's cross-image calls become inter-object calls). Keeps the
  reps split; needs a chirality linker step + a chirality orchestrator that runs the
  phases in sequence over shared byte buffers (no 3 live RTs).
Recommendation: **C1b** — lower-risk than a full rep-unification; the shuttle
already works, this makes it chirality + single-artifact.

## Tier D — self-hosting mechanics (replace Python's role)
- **D1. Chirality writes the ELF + exec()s it** via the sys face (memfd/write/mmap/
  execveat or write-to-file+execve). Replaces Python's Decision-#4 crossing.
- **D2. Chirality orchestrates** parse→check→lower→emit over byte buffers in one
  process (no Python shuttle). Coupled to C1b.

## Tier E — the FIXPOINT
- **E1. Determinism (B7):** source-reproducible ordering + naming ($clo/family
  order, literal-table order, def emission order) so two stages are byte-identical.
- **E2. The ceremony:** compile the source twice, `fixpoint=?` byte-compare
  (ddc.chiral), then E53 DDC across provenance-disjoint legs.

## VALIDATED (session 4, probed through the chirality driver) — Tier A is MOSTLY DONE
Compiles + runs native: poly, HO-poly, **closures returning closures** (adder=42),
**capturing closures**, **pure-bodied `=>` effect defs** (=42), externs, string
constants + string-ops, and whole modules **prelude+collections=42, +sexp=7,
+refine=9**. So Tier A's residue is NARROW:
- **A1-crossings only:** an `=>` def with an ACTUAL syscall crossing (read/write)
  — needs E70 native routing (prim<crossing>→E51 wrapper→syscall in mach). Pure-
  body `=>` already lowers.
- **A2-§6 only:** the specific nested-FUNCTION-capture (m-insert-new captures
  `cmp`). Ordinary/returning/value-capturing closures already work.
- **B ordering:** concatenation needs dep order (e.g. SymOp before syntax) — a
  Tier-B loader concern, not a compiler gap.

**So the real remaining work is Tiers C/D/E — the architectural crux for "no
Python."** Coverage is close to done. C (single native artifact from the 3
collision-forced images) + D (chirality writes+execs + orchestrates, no Python
shuttle) are the crux, and C1a-unify-vs-C1b-link is a design decision to settle
with the author before building.

## DECISION (2026-08-03): C1b (link images) + latitude to restructure
Author: freely restructure the public `../chirality` repo (docs-only today);
keep THIS private repo as the bootstrap scaffold; goal = self-bootstrap. So:
build toward **C1b** (link the 3 emitted images into one ELF + a chirality
orchestrator), not a full rep-unify. Concrete first sub-steps, each committable:
- **D1a. add `execveat` to the sys face** (`nb-sys-execveat`, sys-tal.chiral) —
  the one missing syscall; then a chirality `=>` driver: bytes → memfd_create →
  write → execveat, replacing Python's write+exec (Decision #4). Bounded.
- **C1b-1. a chirality orchestrator** that runs front→back→emit over shared byte/
  con-value buffers in ONE process. The 3 images stay separate Sigs at BUILD
  time but their EMITTED code links into one binary; the orchestrator sequences
  the phases. This is the piece the Python MetisCompiler does today.
- **C1b-2. compile the compiler's own 3 image-sources** (each a valid Sig) to 3
  objects; resolve inter-image calls at link; the linked binary IS the compiler.
- Then **E1 determinism** + **E2 fixpoint** (compile twice, byte-compare).
Reality: C/D is a large multi-push architectural build (the crux); Tiers A/B are
~done. D1a is the smallest concrete no-Python win to start with.

## PROGRESS
- **2026-08-03 — D1a DONE (649 green).** The RUN path is now zero-python.
  - **D1a-1** (`737e2d7`): `nb-sys-execveat` added to the sys face (the one
    missing syscall; thin tal-floor TFn issuing execveat/322), registered in
    sys-lib + native.py `lib_sig` + tal.py `SYSCALL_TABLE` (E76 governance).
  - **D1a-2** (`114e0e6`): `nb-sys-exec-elf` — the fat driver memfd_create →
    write → assemble ""/argv/envp (pinned, send-fd precedent) → execveat
    (AT_EMPTY_PATH). Differential-proven: the SAME chirality-compiled ELF exits 42
    both via the python `subprocess` oracle and via the chirality driver (a fork
    only lets the parent observe the exit; the driver touches no python and no
    filesystem). Surfaced + resolved the first COMPOSITE crossing vs the E76
    registry (governed transitively; test refined to key on ti-sys issuance).
  - **NEXT = C1b-1** (the chirality orchestrator: front→back→emit over shared byte/
    con-value buffers in one process, replacing the python `MetisCompiler`
    shuttle). Then C1b-2 (link the 3 image-objects), E1 determinism, E2 fixpoint.

## ⚑ DEP-ORDER CORRECTION (2026-08-03, grounded) — C1b-1 is inverted
Verified against the live code, not the numbering:
- **The 3-image collision is real:** loading compile-front + compile-back in one
  Elab → `data Term redeclared` (tal-ssa.chiral:38). A single chirality orchestrator
  that `import`s all 3 phases is impossible — they must be called as LINKED
  NATIVE SYMBOLS, not chirality imports.
- **No linker exists** (no separate-object emission / reloc-resolution in lib or
  chirality/). **Coverage is incomplete** (compile-emit 64%).
So **C1b-1 (the orchestrator) is NOT runnable first** — it needs C1b-2's
cross-image native linking, which needs the images to fully lower. True order:
**coverage (Tier A/B residue) → C1b-2 (link) → C1b-1 (orchestrator, small).**
Both C1b-2 AND coverage are needed by every downstream architecture, so
**coverage is the unambiguous next dep.**
- **NEW FORK D1a makes cheap:** "single binary via a chirality linker" (C1b, chosen)
  vs "3-process pipeline via execveat" (front|back|emit as 3 native binaries the
  D1a execveat driver sequences over memfd/pipes). The linker is unbuilt+novel;
  the pipeline sidesteps it entirely and is newly cheap now that execveat exists.
  "Single artifact" is a doc preference, not a rung-1 requirement (the fixpoint
  byte-compare holds for a 3-binary pipeline too). **Author call — surfaced, not
  self-resolved.** Coverage is needed either way, so it does not block picking a
  coverage slice now.

## PROGRESS (cont.)
- **2026-08-03 — A1 halt-binding sub-slice 1 DONE (649 green, `164356a`).** Bound
  the `halt` crossing (wrap-halt → stderr+exit_group; the first POLYMORPHIC
  crossing). Real gap fixed: `crossing_sigs` typed doms over ALL peeled params
  incl. halt's q0 erased type-param (ttype None → wrongly excluded halt); now
  drops q0 like `lower_all` (B1). **Emit "effectful halt" leaf 22 → 0.** Gate
  parity holds chirality-side. HONEST: the ex-halt defs (emit-code/assemble/resolve)
  still cascade on **cluster 2** (mach-ret, alist-get poly, a-rel fn-field,
  partial-app) — A1 removed ONE of their blockers; cluster 2 is now the gating
  bulk for emit-core. OWED: A1 sub-slice 2 (native emission of a halt crossing —
  relax native.py Unit-only routing + chirality mirror; error-path, lower priority).

## ⚑ CURRENT COVERAGE CENSUS (2026-08-03, re-measured — supersedes session-4)
Per-image `lower_all` (with cascade; distinct leaf reasons are the signal):
- **compile-front: 310/572 lower** — only leaf = **19 "type does not lower"** (poly/HO).
- **compile-back: 75/128 lower** — **0 intrinsic leaves** (all 53 skips are cascade).
- **compile-emit: 214/328 lower** — leaves: **34 "body is not a lambda chain"**
  (all `mach-*` — projectors that return a FUNCTION field out of the 36-fn `Mach`
  record → closconv/HO), **22 "effectful 'halt'"** (emit's CORE: `emit-code`/
  `assemble`/`resolve`/`materialize` — effectful only via the `halt` crossing),
  **13 "type does not lower"**, **13 "field enc of a-rel"** (fn-in-data-field, B3),
  2 "field pro of mach", 1 "case on non-data".

**FINDING: every remaining coverage leaf is in a HARD cluster, not an easy grind.**
The three clusters:
1. **A1 effect routing, scoped to `halt`** — 22 emit-core defs lower once the `halt`
   crossing is E51-bound (`halt`→`exit_group`, already in the sys face) AND the
   chirality lower opens the effect gate + routes the crossing prim to the syscall
   wrapper (mach layer). Highest leverage (unblocks emit's core + cascade); the
   A1 MECHANISM is real trusted-lowering work, not a one-liner.
2. **closconv / HO-at-scale** — the 34 `mach-*` record-of-functions projectors +
   the ~32 "type does not lower" poly/HO + the 13 fn-in-field (B3). Trusted,
   entangled with each other and with B6 (the image split). The `mach` record of
   36 function fields is the crux specimen.
3. Tiny tail: `field pro of mach` (2), `case on non-data` (1).
Recommended next coverage slice = **cluster 1 (A1 `halt`-binding)** — bounded,
high-leverage, and it exercises the A1 mechanism that real compiler I/O needs
anyway. Cluster 2 is the larger trusted build after it.

## Order of attack
A1 → A2 → A3 (coverage, bounded, per-module) — get EVERY compiler module to
compile through the chirality driver. THEN B1 (own source) → C1b (single artifact) →
D1/D2 (chirality I/O + orchestration) → E1 (determinism) → E2 (fixpoint). Tiers C/D
are the architectural crux for "no Python"; A/B are the bounded grind that must
finish first (a single-artifact compiler that can't compile its own modules is
moot). Execute A module-by-module, committing each gap closed, 648+ green.
