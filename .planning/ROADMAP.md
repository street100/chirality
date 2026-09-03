# chirality — roadmap (developmental stages)

The long road as stages. Each stage names its goal, what it produces in the note
base, which sibling owns it, and its status. No dates, no sizes. A spine with
backflow, not a schedule. See `PROJECT.md` for how the stages relate.

Status values: done, in progress, open, blocked.

## The rung ladder (added 2026-07-28 — how the stages map to the build frame)

The operative build frame since 2026-07-22 is the two-rung ladder
(`.planning/SELF-HOST-PLAN.md`; the honest trust statement is
`docs/trust-boundary.md`): **rung 1** = zero CPython in the check/compile/run
path, self-hosted *on Linux* — judgment + authority roots real, secret root
degraded (no register custody under a preemptive kernel we don't control).
**Rung 2** = chirality-as-OS on metal — E42 critical sections, register custody,
the full SECURE-DATUM story. *Rung 1 completes ownership; rung 2 completes
sovereignty.* Rung-2 items are seated, not scheduled.

The stage numbers below are the design spine, **not the build order**:

> **⚑ SEQUENCING OWNER (2026-08-21): `.planning/BUILD-ORDER.md`.** This file is the
> design spine and does not carry build order. The rung-1 lane plan below
> (`HANDOFF.md`, last touched 2026-08-03) closed with the fixpoint on 2026-08-05 and
> is **provenance now, not sequencing**. The live cross-lane order — core `E#`,
> terminal `T#`, scriba `S#` — lives in `BUILD-ORDER.md`.

- **Stages 3–6 + 9 carry rung 1.** Stage 9 is its execution vehicle; for
  sequencing, the lane plan (`.planning/HANDOFF.md` + SELF-HOST-PLAN) is
  authoritative — prep (determinism debts) before the kernel port, fixpoint+DDC
  last.
- **Stage 7 splits across the rungs**: broker/Adhikara/bridge *design* is
  rung-1-expressible; secret-custody *enforcement* is rung-2 (trust-boundary:
  OS-trusted until metal).
- **Stage 8 is rung 2** — it comes after stage 9's rung-1 completion in build
  order despite its position in the spine.
- **Stages 10–11 ride rung 1's completion.**

---

## Stage 1 — Design base
- Goal: a principled, navigable model of the language before any code.
- Produces: `../PRINCIPLES.md`, `../SECURE-DATUM-MODEL.md`, the `../docs/` note
  base, the `decision-*` notes (twelve as of 2026-07-28), `open-edges.md`, and
  the depth tier under the notes (`../docs/banks/`, 8 concept banks).
- Owner: 02-language-design.
- Status: in progress. Most of it exists; the open edges are the remainder. The
  note base gained a regularity/honesty layer 2026-07-06: `floor-agreement`,
  `status-ledger`, `design-principles`, `syntax-evolution`, `trust-boundary`
  (see the backflow note).

## Stage 2 — Resolve the load bearing open edges
- Goal: settle the seams that block module design.
- Produces: decisions on the cost gradient mechanism, the reflective floor, how
  far the membrane reaches inward, default tier selection, the non process
  boundary. Recorded as `decision-*` notes and folded into the module notes.
- Owner: 02-language-design.
- Status: cost gradient SETTLED 2026-07-05 (`docs/decision-graded-kernel.md`):
  cost lives in the kernel as an enrichment of QTT's grade structure, a
  parametric coeffect semiring over usage x time x space x info-flow (edge 3 =
  the semiring, edge 2's reach = the fixed factor set). Totality is a property
  beside the grades (total by default, ratified); staging is a modality, not a
  grade. Edge 16's mechanism was superseded 2026-07-21: effects are two facets
  (possession + exercise) joined by construction, and alarms are *crossings in
  the effect row*, not a modality (`docs/decision-effect-facets.md`, which
  amends graded-kernel). Reflective floor SETTLED 2026-07-27
  (`docs/decision-reflective-floor.md`: the judgment is frozen at staging
  completion, changed only by certified succession; in-place mutation is
  unsound, not merely unsafe). Remaining: tier selection (edge 4, resolved in
  direction, broadened) and membrane reach (edge 2, shaped).

## Stage 3 — The kernel
- Goal: the QTT trusted core, term representation plus checker, kept small.
- Produces: the substance behind `modules-core` (kernel, process, core-ir).
- Owner: 02-language-design.
- Status: unblocked (the cost gradient decision landed, see stage 2). A first checker
  with the QTT shape (quantities 0/1/w by resource counting, NbE conversion,
  pure versus process arrows) exists in `scaffold/chirality/kernel.py` as evidence,
  not as this stage's deliverable; see the stage 9 note. The "kept small" shape
  is now decided: a small derivation checker (**kernel-core**) against an
  audited **kernel-spec**, re-checking untrusted producers' certificates
  (`docs/decision-split-checker.md`; made real by E52). The self-applicability
  metatheory gate is E50 mutual+lexicographic termination
  (`.planning/SELF-HOST-PLAN.md`; SPEC audited).

## Stage 4 — The typed core
- Goal: category A upper. Types in build order (refinement, linear, capability),
  effects, graded cost, totality, surface syntax, typed reflection.
- Produces: `modules-core`, the typed parts of `modules-security`.
- Owner: 02-language-design.
- Status: open.

## Stage 5 — The lowering floor
- Goal: typed assembly as the floor, type preserving lowering, the preserve
  check, a first backend from the typed IR with no compile to C.
- Produces: `modules-lowering`. Resolves the asm vocabulary open edge.
- Status: open. A miniature exists in the scaffold (2026-07-05):
  `scaffold/chirality/tal.py` (typed register IR with its own checker) and
  `lower.py` (the connector; preserve-check = the tal re-check). The demo's
  pure fragment (43 defs) runs on it; crossings stay upper by construction.
  Evidence for the shape, not this stage's deliverable.
- Owner: 02-language-design.

## Stage 6 — Staging and generation
- Goal: one staged compiler plus the pregen twin. Binding time, partial
  evaluation, procedural generation, install of generated code.
- Produces: `modules-staging` (stage, specialize, pregen, link and load).
- Status: open. Interleaves with stage 7. Two miniatures exist in the
  scaffold (2026-07-05): extern link-at-load (declarations in source, host
  bindings bound at run, missing binding refuses the load), and `spawn`, the
  operative face of staging-births-runtimes: a profile staged into a child
  runtime that self-verifies before running, held through one linear port,
  torn down by consuming it. Evidence for the shape, not this stage's
  deliverable. The dynamism question is settled 2026-07-27
  (`docs/decision-reflective-floor.md`): all dynamism is mesh dynamism —
  population editing is free, a judgment change is fine-grained certified
  succession (stage successor, certify against kernel-spec, typed state
  migration, atomic port hand-over); no in-place judgment mutation.
- Owner: 02-language-design.

## Stage 7 — The bridge
- Goal: category C, the novel core. Custody, the component broker, Adhikara,
  attestation, the bridges, the runtime. Where custody ceremonies become language
  features.
- Produces: `modules-custody`, `modules-broker`, `modules-bridges`.
- Owner: 02-language-design, fed by the custody context.
- Status: open. Interleaves with stage 6. The broker's shape settled 2026-07-27
  (`docs/decision-brokers.md`): the static half dissolves into the type system
  (emergent); the component broker is the bridge elaborator instantiated over
  the live population, per-runtime by self-similarity, no global registry
  expressible; Adhikara is the capability-type discipline lowered onto a B
  channel, zero-trust (no foreign agreement load-bearing for safety). Rung
  honesty: secret-custody *enforcement* in this stage stays OS-trusted until
  rung 2 (`docs/trust-boundary.md`); the design work is rung-1-expressible.

## Stage 8 — Substrate and silicon
- Goal: the category B modules, the CHERI floor enforcement, the secure datum
  model woven end to end.
- Produces: `modules-substrate`, the cheri floor in `modules-lowering`.
- Owner: 02-language-design.
- Status: open — **rung 2, seated not scheduled** (`.planning/SELF-HOST-PLAN.md`).
  Register custody, E42 critical sections, and the metal floor are named rung-2
  residues; in build order this stage follows stage 9's rung-1 completion
  despite its position in the spine.

## Stage 9 — Bootstrap and self host
- Goal: a host language scaffold compiler, then chirality in chirality, then tear out the
  scaffold. Kernel equals runtime equals compiler becomes literal.
- Produces: the bootstrap sequence and self hosting story.
- Owner: 03-development-approach.
- De-Pythoning milestones 1-4 done (2026-07-05..06): the tal->machine-code emitter
  is written in chirality, modular (`lib/mach.chiral` frozen interface,
  `lib/emit-core.chiral` target-independent codegen, `mach-x64`/`mach-listing`
  conforming machines), and its output runs natively on the CPU,
  differentially verified against the reference interpreter. Milestone 2:
  fielded data as boxed [tag][fields] cells bump-allocated from an arena —
  the region discipline at the metal. Milestone 3: Str/Bytes as
  [len][payload] cells, literals in a data section, and the string library
  authored in chirality AT THE TAL LEVEL (`lib/bytes-tal.chiral`; tal's
  human-writability exercised), preserve-checked by the tal checker and
  emitted with every batch. The ENTIRE lowered pure fragment of the
  tomodachi (43/43) now runs natively; the wire encoder and sprite rows are
  byte-exact against the reference. Representation decisions taken at
  scaffold scale, recorded in `.planning/SCAFFOLD-NEXT.md`, pending
  ratification (edges 2/3 remain the design-level mechanism). Remaining
  milestones, each deleting more Python: closures (a total design silence —
  SCAFFOLD-NEXT D3), syscalls (removes the port impls), then the checker and
  elaborator in chirality (the collections library is the floor for that), then
  the bootstrap fixpoint. Milestone 4 (the sys face: write/read syscalls as
  hand-authored tal, differentially tested against real pipes) is done as a
  slice; the 2026-07-06 audit then hardened this vehicle by fixing four latent
  defects (see the audit backflow note below).
  **Update 2026-07-28 — this stage's operative plan is now the rung-1 arc**
  (`.planning/SELF-HOST-PLAN.md`; lanes in `.planning/HANDOFF.md`): catalog
  E1–E75, 44 worked examples, 10 audited implement-contracts
  (E27/E28/E30–E33/E39/E50/E51/E53), 281 tests green. Two of the "remaining
  milestones" above are superseded: closures are no longer a design silence
  (E69 drafted — defunctionalized capture records carrying quantities), and
  the syscall bank is 7 crossings built with the rest specced (E28–E33 +
  E51 linkage). The endgame is fixpoint+DDC-gated: the determinism debts are
  pre-port gates (E53) — pay them before the kernel port begins.
- Status: in progress, reordered (2026-07-05): the scaffold half was pulled
  forward as the execution vehicle for the first target
  (`docs/target-tomodachi.md`), so stage 2 decisions get tested against running
  code instead of paper. Lives in `scaffold/`, structured after the module
  architecture: minimal QTT kernel behind two seams, types and effects as
  modules, primitives declared in chirality source with host bindings linked at
  load, and a first profile-plus-target conformance check (`chirality verify`).
  What it enforces versus stubs is in `scaffold/README.md`. Self hosting
  remains open.

## Stage 10 — Profiles and targets
- Goal: the profiles as testable module manifests; multiple targets from one
  source; a dual architecture proving demo.
- Produces: the profile compositions and target backends.
- Owner: 03-development-approach.
- Status: open. The profile *model* settled 2026-07-27
  (`docs/decision-profiles.md`): additive module manifests over a
  profile-invariant frozen port set (no "full chirality" you strip down);
  conformance is subtyping — the staged runtime's composite type satisfies the
  target's requirement type; whole-assembly properties fall into three classes
  (D4, settled same day). The chirality-verify profile itself is still edge 9
  (open); the scaffold's `(total)` clause is its first slice.

## Stage 11 — Tool reimplementation
- Goal: port the custody tool family under chirality. Design the broker so those
  core services are its natural implementation rather than later integrations.
- Produces: the port disposition and the dogfooding ladder.
- Owner: 03-development-approach.
- Status: open. Depends on stage 9.

---

## Backflow notes

- The scaffold demo (target-tomodachi, 2026-07-05) already produced backflow:
  effect sequencing under linearity needed `do` sugar (linear let plus unit
  destructure); strict application makes a pure `if` a trap for effects;
  passing a linear value to an unrestricted parameter saturates to w, which is
  correct QTT and shapes how port-threading helpers must be typed. All are
  stage 2/4 inputs.
- The audit round (scaffold/AUDIT.md, 2026-07-05) added two design facts.
  First: quantities on binders alone do not make ports safe; a bare port value
  can be re-bound unrestricted and aliased. The fix that worked is linear
  kinds, linearity as a property of the type derived from its fields, judged
  at every instantiation. This is decision-b-in-type doing real work and
  should be a stage 4 kernel rule, not a scaffold patch. Second: erased (0)
  positions must be effect-free or 0 is not erasure; the membrane question of
  edge 2 has to say this explicitly. A polymorphic halt
  (`(-> (0 A (type 0)) (=> Str A))`) proved a workable stand-in for the empty
  type on alarm paths.
- The graded-kernel decision (2026-07-05, `docs/decision-graded-kernel.md`)
  settled edges 3, 2, 16's mechanism in one pass and took its first bounded
  down-payment: strict-positivity checking of data declarations
  (`scaffold/chirality/data.py`, 5 tests), the first piece of Fork B's totality
  kit. It closes the divergence hole non-positive datatypes opened and computes
  per-parameter variance so legitimate recursion through covariant containers
  (List/Pair/Maybe, exercised by the tal IR's own TCode) still type-checks. The
  heavy parts (Fork A semiring enrichment of the trusted kernel, Fork C staging
  modality) have their seats reserved and are built increment by increment, not
  dumped into the kernel at once.
- The audit + documentation round (2026-07-06) produced substantial backflow.
  (a) Four latent scaffold defects fixed, hardening the stage-9 vehicle: the
  constant-folder and the native backend disagreed with the reference
  interpreter on signed division (a well-typed value divergence the
  preserve-check cannot catch); a nested non-uniform datatype crashed the
  linear-kind checker; a type-level Pi could bind a linear port at an
  unrestricted quantity; refinement entailment missed uninhabited constraints.
  (b) Division semantics SETTLED as Euclidean across all three floors (reference,
  fold, native), matching SMT-LIB `div`/`mod` so a solver-discharged refinement
  means at runtime what it proved; I64 is now real two's-complement (wrap plus a
  const range-check). A stage 2/4 semantic decision. (c) A new invariant, FLOOR
  AGREEMENT (`docs/floor-agreement.md`), refines the joining law's lowering row:
  type preservation is not value preservation, so every executor of tal must
  agree with the reference interpreter on observable value (by collapse where
  possible, differential validation where not). This is a stage 5 lowering
  obligation the preserve-check alone does not discharge. (d) A stage-1
  design-base regularity/honesty layer: `status-ledger` (per-claim DESIGNED/
  SEEDED/IMPLEMENTED/ENFORCED, with status banners on the security/custody/
  permission notes), `design-principles` (the reader's-side charter, regularity
  as keystone), `syntax-evolution` (the grade-vector and named-effect slots
  reserved before the graded kernel and edge 16 force a break), `trust-boundary`
  (the current CPython-plus-Linux TCB versus the target; discipline, not
  enforcement). The unifying diagnosis: the division bug, the docs-read-as-
  shipped confusion, and the annotation tax were one regularity failure across
  three surfaces (semantics, docs, syntax). 144 tests green.
- The follow-on round (2026-07-06) walked a second increment line and advanced
  Fork B's totality kit. (a) Token-regularity: the `w`-vs-`0/1` marker and `the`'s
  argument order were investigated and *resolved as non-defects* — measured
  against the s-expr/Lisp family chirality belongs to, `(the ty e)` is Common Lisp's
  `the` and the marker's int-vs-symbol split is invisible to readers; the debt was
  retired in `syntax-evolution.md` rather than churned into source (a
  regularity-of-analysis lesson: judge a form against its own family first).
  (b) Fork B's **third totality pillar** landed: a sound structural-recursion
  checker (`scaffold/chirality/data.py` `check_termination`, wired via a new kernel
  `sig.def_hooks` seam, `docs/totality.md`, 7 tests). Coverage was already
  enforced; with positivity + coverage + structural recursion, all three pillars
  now exist. The recursion check **classifies, it does not yet enforce** — it
  records `sig.totality[name]` (None = proven total) and only rejects under
  `sig.require_total`, because mandatory totality regresses legitimate bounded
  *numeric* recursion (e.g. the sprite demo's `row-bytes` counting to 16) whose
  proof needs a refinement-guarded measure not yet built. IMPLEMENTED, not
  ENFORCED — the status-ledger row updated to match. Sized types are the
  promotion path (they reuse the semiring machinery, the one place totality
  touches the grade vector). 157 tests green.
- Totality got teeth (2026-07-06, same line): a bare `(total)` **profile clause**
  makes `chirality verify` demand every def in the composite be proven total —
  open-edge 9's chirality-verify sub-category at scaffold scale. Built as a
  verify-time conformance row beside the target requirement and the frozen port
  set (`surface.py verify_profiles`, `cli.py`), not a load-time gate, so it reads
  the `sig.totality` ledger the checker already fills. `demo/verify-total.chiral`
  shows both verdicts (VALID `total: proven`; add a numeric loop → INVALID
  `total: violated` with the offending def + reason + nonzero exit). Scope is the
  whole composite, as for the port set; reachability-scoping is the shared
  refinement both will want. 161 tests green.
- Refinement path-sensitivity (2026-07-06, same line): a `case` branch guarded by
  a comparison of a variable against a constant now LEARNS the bound it proves —
  `(case (<i x 64) (true <x:{<64} here>) (false <x:{>=64} here>))` — so a guarded
  body type-checks against a refined type with no runtime test. Built as a new
  kernel seam `sig.narrow_hooks` (a branch may tighten a variable's type;
  `Ctx.narrow` replaces one level's type, env untouched — sound because the value
  is unchanged and the guard proves the tighter type on that path), with
  `refine.py _narrow` owning the comparison→fact logic (`<i`/`<=i`/`=i`, var on
  either side, true/false learns fact/negation). Stays in the decidable
  interval-with-holes fragment: only constant bounds, no solver. This is the
  "honest next slice" the refinement module flagged, and the `i < c` fact
  measure-based termination needs. What remains is the SYMBOLIC slice — `v < n`
  for n another variable — which finally types the pool offset. 167 tests green.
- Measure-based termination (2026-07-06, same line): the totality checker now
  proves BOUNDED NUMERIC recursion, not just structural. A self-call decreases at
  position j when the argument is a constant step of parameter j — `(+ i k)` /
  `(- i k)` — toward a constant bound the path's guards establish (the walker
  tracks per-variable `(lo, hi)` bounds exactly as path-sensitivity does, staying
  independent of the refinement module). The measure is the distance to the bound;
  it is sound because the guard is re-checked every iteration and the step is
  monotone. `row-bytes` and all 31 sprite defs now prove total. A real soundness
  subtlety handled: the bound must EXCLUDE the two's-complement wraparound point
  (`hi ≤ MAX−k`, `lo ≥ MIN−k`), or a vacuous `i ≤ MAX` guard would "prove" a loop
  that wraps `MAX→MIN` forever — caught and tested. What remains unprovable:
  symbolic bounds (`i < n`, variable n — the refinement slice), lexicographic,
  size-change, mutual. 169 tests green.
- New sys slice (2026-07-06, same line): `lseek(2)` joins `write`/`read` in
  `lib/sys-tal.chiral` — de-Python milestone 4. An ALL-INTEGER crossing (no
  buffer), so it needs neither `ti-bptr` nor `ti-blen`, just `ti-sys` (nr 8) over
  register args; the generic `_sys(nr, args)` reference and the native x64 sys
  convention already handle it, so no reference/native change — the slice is one
  hand-tal function, its `LIB_SIGS` entry, and differential tests (native and
  reference `lseek` agree on a real seekable file: SEEK_SET/SEEK_END returns, and
  a real read from the new position). Confinement invariant still holds
  (`nb-sys-lseek` is marked sysface, no lowered code reaches it). 171 tests green.
  Remaining sys work: the struct/buffer shapes (poll's `pollfd`, the
  memfd→mmap self-hosted-arena arc) and the hard SCM_RIGHTS fd-passing case.
- Symbolic refinement bounds (2026-07-06, new line): the refinement fragment now
  admits a bound against a bare in-scope VARIABLE (`v < n`), not just a constant —
  the symbolic slice the constant work flagged as ahead. The constraint gained a
  4th slot `sym` (a set of `(op, level)` bounds keyed by the operand's de Bruijn
  level); path-sensitivity's `_narrow` learns a symbolic bound from a var-vs-var
  guard; entailment adds a syntactic subset check on `sym` (sound, no arithmetic
  between variables). The soundness keystone: a symbolic bound COLLAPSES to a
  constant when its variable is instantiated by a literal, because the enclosing
  Pi re-evaluates the Refine term on application (`< n` folds to `< 5`) — verified
  (`(use 5 5)` rejected against the collapsed `{<= 4}`). A real de-Bruijn bug
  fixed along the way: `terms.py` `shift_close`/`uses_below` skipped Refine atoms
  (safe when they were constants); they now traverse the operand terms, or a
  variable used only in a bound would be miscounted or mis-shifted. 177 tests
  green (+6 `TestSymbolicRefinement`). Next: apply it to the pool offset (retire
  F8) and to numeric loops guarded by `i < n`.
- Pool offset typed — F8's last piece (2026-07-06, same line): `mem-put-checked`
  in `lib/mem-linear.chiral` refines the write offset to `{I64 | >= 0, < n}`
  against the pool's capacity, so an out-of-bounds or guarded-in-bounds write is
  decided by the type-checker rather than the runtime witness. `< n` collapses to
  a constant at a concrete pool (a literal or a two-guard-narrowed runtime offset
  is checked directly) and threads symbolically through generic capacity code.
  The raw `mem-put`/`pool-write` stays for a computed offset the fragment cannot
  prove (a strided `(* y k)`), which keeps the runtime check — honest, non-
  breaking (draw-rows unchanged). AUDIT.md F8 + README offset limits updated.
  7 tests (`TestPoolOffsetBounds`). 184 tests green.
- Symbolic measure termination (2026-07-06, same line): the totality checker now
  proves a numeric loop bounded by a VARIABLE — `(f (+ i 1))` guarded by strict
  `(<i i n)` — total, the last-line gap. The walker's per-variable bounds grew
  from `(lo, hi)` to `(lo, hi, lt, gt)` (strict symbolic under/over sets of
  variable levels), fed by var-vs-var guards; the measure is `n − i`, well-founded
  under two soundness conditions that a naive rule would miss and that are tested:
  the step must be `±1` (a bigger step could overflow past a near-`MAX` `n`) and
  the bound variable must be passed **unchanged** in the recursive call (a growing
  `n` outruns `i`). A strict `<` needs no separate wraparound guard (`i < n ≤ MAX`
  forces `i + 1 ≤ n`). Stays local to `data.py` — no dependency on the refinement
  module. 188 tests green (+4). Only non-unit or non-strict symbolic steps,
  lexicographic, and mutual recursion remain unproven.
- Self-hosting sys advance (2026-07-06, same line): `memfd_create(2)` and
  `ftruncate(2)` join the sys face — chirality now creates its own anonymous
  in-memory file and sizes it, the first half of a chirality-side arena (the
  milestone-4 goal of not borrowing the Python loader's mmap; `mmap` is the
  remaining, harder step — a returned pointer to represent). ftruncate is
  all-integer (like lseek, zero reference/native change); memfd needs a
  NUL-terminated C name, handed a fresh one-byte NUL cell for the empty name
  rather than reading past a chirality `[len][payload]`. Differentially tested native
  vs reference, including a full create→size→write→read round-trip through the
  anonymous file and `ftruncate`-then-`lseek(END)` size checks. Confinement
  invariant still holds (both marked sysface). 191 tests green (+3).
- Building stage 5 will test whether the stage 2 cost decision survives contact
  with real lowering.
- Stage 7 will surface custody shapes that should have been language primitives,
  which feeds back into stages 3 and 4.
- Stage 11 is the real proving ground. A tool that is awkward to port is evidence
  about the language, not just the port.
