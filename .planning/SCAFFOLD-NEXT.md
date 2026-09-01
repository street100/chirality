# Scaffold: next moves (research pass, 2026-07-05)

> **Status update (same day, follow-up build pass):** Milestone 3 is BUILT.
> The D2 representation proposal below was taken at scaffold scale (like
> milestone 2's region decision) and awaits ratification: Bytes/Str = one
> word, a `[len][payload]` arena cell; literals in a data section; the
> 19 gate prims implemented as `lib/bytes-tal.chiral`, typed assembly
> authored in chirality at the tal level, preserve-checked and differentially
> tested. M2 (non-tail case) is ALSO BUILT: lower.py outlines a case in
> expression position into its own preserve-checked function; `rows` and
> its four sprite-dispatch cases now lower and run natively. The native
> subset is the **entire lowered pure fragment (48/48)** — everything
> still upper is upper by design (effectful crossings, dependent types).
> Wire encoder and sprites byte-exact. M1 was found near-vacuous on closer
> inspection (draw/draw-rows are *effectful*, so they stay upper by design;
> erased-binder lowering unlocks nothing real today) — dropped. M3 (string
> literals) landed as part of milestone 3.
>
> **Milestone 4, first slice, is ALSO BUILT:** the sys face — `sys` +
> `bptr` instructions at the tal floor (tal's C category in miniature),
> `lib/sys-tal.chiral` authoring write(2)/read(2) as hand-tal, the checker
> marking sys-face functions and the backend confining the mark to the
> deliberate sys library. Native code performs real syscalls through
> pipes, differentially against the reference machine doing the same
> crossing via libc. Confinement is structural (no surface path) + the
> sysface mark — a typed effect awaits edge 16. Remaining sys slices:
> socket ops (incl. sendmsg/SCM_RIGHTS fd-passing), memfd/mmap, poll.
> 114 tests green. Remaining: real-desktop run (host-side) and the D1/D3+
> design session list below, which stands unchanged.
>
> **Security tightenings + optimization primitives (same day):** W^X
> loader landed (general `a-align` assembler primitive; code region
> mprotect'd read-execute, heap pointers page-aligned + read-write —
> never RWX). Sys-face confinement pinned by tests (no lowered function is
> sysface; a rogue sysface fn is refused at load). `bput` write-once left
> as a documented TCB assumption ON PURPOSE — a sound check needs TAL
> typed init-flags threaded across calls (deferred type feature), and a
> naive freshness check would reject the library's legitimate initializer
> pattern (`nb-copy` writes a caller's fresh cell), so it was not
> half-built. `chirality/optimize.py` adds the pregen face of modules-staging:
> fold / dead / **specialize** (partial evaluation → residual, the pregen
> twin of spawn), all preserve-checked tal→tal (a broken pass = floor
> alarm, pinned by an ill-typed-output test). Residuals native-compile and
> are differentially equal. Explicitly meaning-preserving — NO graded-cost
> claim (that's edges 2/3). Optimizer is python today like lower.py;
> chirality-migration is a later de-Python step. 123 tests green.
>
> Outbound membrane (#4 from the security review) remains deferred: stages
> 7-8 + edges 7/14, genuinely additive, not this pass.
>
> **Refinement types (same day):** the next module in the settled
> type-system build order (refinement → linear → capability; linear done)
> — and NOT blocked on the semiring, which is why it was the right "just
> build a planned module" move. `chirality/refine.py`: a base type narrowed by
> a decidable predicate, behind four new kernel value-form seams
> (check/subtype/conv/quote hooks) so the kernel stays refinement-agnostic.
> Fragment: I64 + constant-bound atoms (interval-with-holes → entailment
> sound AND complete, no solver). Subtyping = entailment + forgetting.
> Retires constant-bound runtime checks (nonzero divisor, literal index
> bound) as compile-time obligations. HONEST next slice: variable bounds
> (`v < n`) need path-sensitivity — that's what finally types the pool
> offset. 133 tests green. Recorded pending author ratification (fragment
> choice), like the byte-cell representation.
>
> **Kernel minimalization pass (same day):** audited kernel.py against
> "trusted judgment only" — found it already essentially clean (the F10
> restructure held); only the pretty-printer didn't belong. Divided into
> three layers, one-way dependency: `terms.py` (pure syntax: constants +
> de Bruijn walkers, zero imports) → `kernel.py` (judgment: eval / conv /
> subtype / infer / check / reify / install) → `pretty.py` (display, NOT
> trusted). kernel.py 636 → 536 lines, judgment-only. Public API unchanged
> (re-exports + lazy shims) so zero call-site churn; 133 tests green. Sig's
> module-owned registries left as-is — Sig is legitimately the shared
> context; moving them is invasive for no gain.

Synthesis of a three-way research sweep over docs/ + GIANTDUMP + scaffold
state, commissioned before further building. Sources: the note base (cited
file:line by the sweep), `.planning/ROADMAP.md`, `scaffold/README.md`,
`scaffold/AUDIT.md`, and a mechanical inventory of the scaffold's lowered
fragment. Everything here is either a documented position, a named open
question, or a flagged silence — inferences are marked as proposals.

## Where the scaffold frontier sits

- De-Pythoning milestones 1+2 done: the emitter is chirality; native code covers
  I64/enum immediates and boxed fielded data over a bump arena. 98 tests.
- Native subset: 10/43 lowered demo functions. The gate is precisely
  inventoried: **19 Str/Bytes prims, all first-order** (str-eq, str-sub,
  str-find(-from), str-cat, str-len, str<->bytes, i64->str, str->i64, bcat,
  bslice, blen, bget, brepeat, pack/unpack-u16/u32), plus **string literals
  in 25 functions** (needs a labeled data section — the asm-reloc machinery
  already supports the shape).
- Two functions (`draw`, `draw-rows`) stay upper for a *different* reason:
  their erased `(0 n I64)` pool-bound params make the type "dependent" to
  lower.py. Erased binders are effect-free by F1, so they can vanish at the
  floor. One (`rows`) is blocked on non-tail case.

## What the research established

### The milestone chain is documented and dependency-gated
ROADMAP stage 9 prescribes: Str/Bytes → syscalls → checker+elaborator in
chirality → bootstrap fixpoint, each preconditioned on the prior. Str/Bytes is
explicitly tagged "needs the memory model, edges 2/3."

### Two genuine silences (new design work, author-level)
1. **Variable-length representation at the metal.** No note anywhere states
   what a Str/Bytes value *is* below tal — length-prefixed cell, fat pointer,
   anything. The settled cell model covers fixed-arity fields only. How a
   bound rides a data-dependent length, and where grown buffers (str-cat)
   allocate, are unjoined questions.
2. **Closures: total silence.** Zero design-note hits for closure
   representation, environment layout, linear capture, indirect calls.
   Not even listed among the open edges. The current floor has direct calls
   to named labels only.

### The stage-2 edges, precisely
- **Edge 3 (cost gradient)** is the sole hard downstream block: stage 3 (the
  kernel proper) cannot finalize its term representation without knowing
  whether cost grades enrich the kernel's {0,1,ω} semiring or live in an
  elaboration module the kernel checks. The notes lean "graded cost in the
  type" (every module note calls cost-typed *graded*) but no decision is
  recorded. Named prior art (reading list only): Granule / graded modalities.
  Settling evidence, per the docs: the tomodachi idle bound stated as a
  graded type.
- **Edge 2 (membrane reach)** has one constraint already forced by scaffold
  backflow (erased positions effect-free, F1 — needs ratifying into the
  design) and one open menu: termination? information flow? or grade-and-stop.
- **Edge 5 (reflective floor)**: location and purpose pinned; the actual
  boundary (what reflect-raw may mutate) is the unresolved part. ROADMAP says
  start stage 2 with edges 3 and 5.
- **Edge 14** is narrowed to a single question: agreement rendezvous and data
  transfer, one step or two (= sync vs async). Deciding it unlocks typing the
  spawn crossing end-to-end (the scaffold's one-sided staging check).
- **Edge 16** (effect mechanism): direction settled (typed alarms, counter
  effects, recoverable-vs-fatal in type), mechanism open (resumable handlers
  vs typed result rows vs other). Couples to edge 2's effects half.

## The work map

### Track M — mechanical, no author decision required
These follow from settled positions; each retires a named honest-limit.

- **M1. Erased-binder lowering.** 0-quantity params vanish at the floor
  (F1 guarantees they're effect-free; docs place erasure at the drop below
  tal). Retires part of "quantities not carried to the floor"; puts `draw`/
  `draw-rows` on the tal floor. Small change to lower.py's eligibility.
- **M2. Non-tail case.** `rows` stays upper only for this. A lowering
  transform (case-to-join or spill) — mechanical, medium effort.
- **M3. String literals as data-section labels.** Needed by milestone 3
  regardless of representation choice; the mechanism (labeled a-bytes after
  code, resolved by the existing two-pass assembler) is representation-
  neutral prep.
- **M4. Real-desktop run** (standing debt, host-side): `python3 -m chirality run
  demo/tomodachi.chiral` on the live niri session.

### Track D — design sessions with the author (ordered)
Per ROADMAP stage 2 ordering and what blocks what:

- **D1. Cost gradient (edge 3) + membrane reach (edge 2).** The named
  stage-2 starting point; blocks the stage-3 kernel. Minimal decision list:
  (1) posture — totality-default / graded-in-type / runaway-hard-to-express,
  or a combination; (2) kernel-semiring vs elaboration-module placement;
  (3) grade structure sufficient to state the tomodachi idle bound;
  (4) membrane menu — termination, info-flow, or grade-and-stop;
  (5) ratify F1 (erased = effect-free) into the design.
  Scaffold evidence on the table: the idle bound (poll deadline is the only
  time), the value-indexed pool, F1/F2 backflow.
- **D2. Variable-length data representation** (the milestone-3 gate; a
  silence, so it needs a decision even at scaffold scale). Proposal to react
  to, mirroring how milestone 2 spent the region decision:
  *Bytes = a boxed cell `[len][payload…]` in the arena; Str = the same cell
  with a UTF-8 claim; one word per value (fits the slot machine); the length
  is a runtime witness beside the payload (same shape as mem-region's
  capacity witness — the erased/refined bound stays in the type until
  refinement lands).* New floor vocabulary this implies (lands in edge 6's
  territory): dynamic-size allocation (size from a register, not a
  constant), byte-granular load, and byte store *into a cell under
  construction* — the initialization-write vs mutation distinction is the
  one design-sensitive bit, since tal is otherwise SSA-shaped.
  With D2 decided, the 19 gate prims can be written **in chirality** as
  recursive tal functions over byte cells (self-hosting the string library
  rather than emitting calls to host helpers), differentially tested like
  milestones 1–2.
- **D3. Closures** (milestone-4 gate; total silence). Questions a session
  must answer: representation (closure conversion vs defunctionalization —
  noting the dump's "dispatch evaporates" hint was accepted only as a
  specialize-internal technique, not the closure story); environment layout
  as a cell; linear capture (how a captured port carries quantity 1 into a
  heap cell — interacts with linear kinds/F2); indirect calls at the floor.
  Worth asking whether the self-hosted checker actually *needs* closures or
  can be written first-order — the docs nowhere enumerate the checker's
  language needs (flagged silence); enumerating them is cheap prep.
- **D4. Edge 14 (one step or two)** — unlocks typed spawn/port protocols;
  test case already built (the node wire + staging connector).
- **D5. Edge 16 mechanism** — likely rides along with D1's effects half.

### Sequencing proposal
1. M1–M3 now (mechanical, keeps momentum, no design debt incurred).
2. D1 next design session (it is the ROADMAP-named starter and the only
   hard block); D2 can be a short second half of the same session — it is
   a scaffold-scale representation ratification, like milestone 2's, not
   the full cost mechanism.
3. Milestone 3 build after D2: byte cells + chirality string library + literals;
   expected to take the native subset from 10/43 to ~40/43 (everything
   except the effectful 15 and `if`).
4. D3 (closures) prep by enumerating the self-hosted checker's actual needs
   from the collections+checker sketch; session after.
5. Syscall milestone and checker-in-chirality per the documented chain.

## Silences worth recording as backflow (candidate open-edge additions)
- Closure representation (not currently an edge at all).
- Variable-length data representation below tal (edge-6-adjacent but not
  stated there; edge 6 is about instruction vocabulary, not data layout).
- The self-hosted checker's language requirements (no enumerated list
  anywhere; "collections is the floor" is the only named artifact).
