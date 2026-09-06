---
node: index
layer: navigation
related: [working-discipline, goals/README, arcs/README, elements/README, records/README, testing-floors, relations, glossary, thesis, splitting-law, joining-law, module-map, open-edges, floor-agreement, status-ledger, design-principles, resolution-patterns, syntax-evolution, trust-boundary, totality, live-environment, certificate-discipline, split-role]
status: draft
updated: 2026-09-04
---

# Chirality docs

Entry point for the Chirality design knowledge base. The base is a set of small
linked notes, one idea per note. Read the hub notes first, then follow links.

## How this is organized

- Notes live in `docs/`. Each note is one concept.
- Each note starts with a metadata block. The `related:` field lists the notes
  it connects to. Those connections are the point: follow them.
- Links inside the prose use `[[slug]]`, where the slug is the filename without
  `.md`. So `[[axis-typeability]]` means `docs/axis-typeability.md`.
- The root holds the locked spine: [PRINCIPLES](../PRINCIPLES.md) and
  [SECURE-DATUM-MODEL](definitions/secure-datum-model.md). The notes here refine and
  apply that spine. They do not restate it.
- For orientation above this base, read [CONTENTS](../CONTENTS.md) (the whole
  project). How to work here is the agent tier: [PERSONA](../.planning/PERSONA.md)
  is the stance and [.planning/protocol/](../.planning/protocol/) holds tone,
  placement, workflow and dispatch. The long road is in
  [.planning/ROADMAP.md](../.planning/ROADMAP.md).

## How work is done here

[[working-discipline]] is the work contract: the build rule, the deferral rule,
commits, and where state lives. `MAP.md` is the tree contract. Neither is
optional reading for someone changing the tree.

The pipeline is `design -> audit -> MINT -> spec -> audit -> implement`, with
`revisit` reaching any artifact in it
([[decisions/decision-design-before-mint]]). Work is named in an arc's roster
first, worked up in `docs/arcs/parts/`, and given an `E#` only when its design
passes audit.

What the project knows about itself sits in four enumerated lenses, problems,
gaps, limits and unspoken territory ([[decisions/decision-four-lenses]]), held in
`records/lenses/`. [[OVERVIEW]] is the generated view across goals, arcs, rosters
and those lenses; it is written by `tools/lens/lens.py overview` and a hand edit
to it is a defect.

## Reading order

1. [[thesis]] is the one idea the whole language hangs on.
1a. [[design-principles]] is the reader's-side design charter — regularity, and
   the deliberate trade of concision for safety — the human-factors complement to
   the architecture principles in `PRINCIPLES.md`.
2. [[axis-typeability]] and [[axis-altitude]] are the two axes that place every
   module.
3. [[splitting-law]] is the rule that decides where one module ends and the next
   begins. Its dual, [[joining-law]], is the rule for how cut modules reconnect:
   four typed connectors, each preserving one invariant. [[floor-agreement]]
   refines it where those invariants meet execution: type preservation is not
   value preservation, and tal has more than one executor.
3a. [[node-architecture]] is the shape of the whole: code runs in nodes that
   touch only through typed ports, no central kernel. [[process-and-runtime]] is
   the one self-similar construct those nodes are, and [[bootstrap-sequence]]
   walks it from a powered off machine to a running system, the intuitive way in.
4. [[category-typed]], [[category-untyped]], [[category-bridge]] are the three
   typeability regions.
5. [[module-map]] is the full module list and the hub for the per-subsystem
   module notes.
6. The `decision-*` notes record the design forks we have settled (CONTENTS.md
   carries the count).
7. [[open-edges]] is what is still open. [[resolution-patterns]] is its
   reader's-side companion — the recurring *moves* by which open edges resolve
   (ports carry everything; tier the honest limit; the preserve-check discipline).
7a. [[status-ledger]] is what is *built* versus *designed* — the map from these
   present-tense notes to the scaffold, on the four rungs DESIGNED / SEEDED /
   IMPLEMENTED / ENFORCED.
7a2. [[testing-floors]] is what the built is *checked by*: which floors gate and
   which are advisory, and — the part that governs every gate row in the repo —
   **the coverage map**, stage by stage down the pipeline, of what each
   instrument can actually see. Two rules generate it: a differential only
   covers what is BELOW its branch point, and it is only worth building when the
   new translator is much smaller than what it tests. It also ranks
   **expectation provenance**, because an assertion whose expected value comes
   from the thing under test is not an assertion.
7b. [[trust-boundary]] is what the built claims *rest on* — the current TCB
   (CPython plus the Linux syscall surface) versus the target (self-hosted floor,
   register root, CHERI), and why today's security properties are discipline, not
   enforcement.
8. [[dump-integration]] records where this material came from and what was
   accepted or rejected.

For measured speed/scale results (native codegen vs `gcc -O2`; the E91 growing
allocator at scale; the native suite's own wall clock), see
[benchmarks/](benchmarks/README.md).

## Note groups

- Navigation: [[index]], [[relations]], [[glossary]], [[vocabulary]], [[perspectives]]
- Views: [[view-security]], [[view-types]], [[view-runtime]], [[view-authoring]],
  [[view-implementation]]. Each reads the whole system from one seat, restating
  the notes under one light; the notes win on conflict. [[perspectives]] is the
  other cut, one construct under many lights.
- Foundations: [[thesis]], [[axis-typeability]], [[axis-altitude]], [[splitting-law]], [[joining-law]], [[node-architecture]], [[process-and-runtime]], [[bootstrap-sequence]], [[permission-model]], [[memory-model]]
- Categories: [[category-typed]], [[category-untyped]], [[category-bridge]]
- Modules: [[module-map]], [[modules-core]], [[modules-security]],
  [[modules-custody]], [[modules-broker]], [[modules-substrate]],
  [[modules-bridges]], [[modules-lowering]], [[modules-staging]], [[error-and-alarm]], [[time-and-clocks]]
- Decisions: [[decision-profiles]], [[decision-brokers]], [[decision-backend]],
  [[decision-b-in-type]], [[decision-split-checker]] (the checker: a small trusted
  core plus untrusted certificate producers, not a quorum),
  [[decision-bridge-elaborator]] (one general bridge, parameterized by evidence
  elements), [[decision-effect-facets]] (effects: possession and exercise, two
  facets joined by construction; alarms are crossings),
  [[decision-dispatch-cadence]] (how work here is dispatched: serial, one stage
  and one agent at a time),
  [[decision-erased-word-level]] (the erased-word type lives at the lowering type
  level; `Core` gains no word spelling and `conv` is left alone),
  [[decision-formulation-distinctness]] (what makes two judges distinct enough
  that their agreement is evidence: formulation differs, closure is disjoint
  against the subject, the builder predates the artifact. A draft awaiting the
  author)
- Trust discipline: [[certificate-discipline]] (trusted checker, untrusted producers
  — how a socket checks what plugs into it: re-run the work, do not spot-check) and
  [[split-role]] (where proof runs out, the split as a tiered substrate-provided role
  — containment by ports, independence by provenance, agreement — that anything can
  require)
- Applications: [[live-environment]] is the hub. The live self-modifying
  environment (opened first as an AI-orchestration layer) read through the node
  model: a fusion of the residential and capability-mesh lineages, 1-1 with no
  existing system, after which granularity, substrate, and display dissolve into
  the settled model and only the reflective floor (edge 5) is left to draw.
- Inspirations: the touchstones the [[live-environment]] fuses, each lighting one
  axis and anchoring none. Residential: [[insp-smalltalk]], [[insp-lisp-machine]],
  [[insp-emacs]], [[insp-oberon]]. Mesh: [[insp-erlang-beam]],
  [[insp-capability-os]]. Substrate: [[insp-unison]].
- Targets: [[target-tomodachi]]. A target is a requirement type a profile must
  satisfy ([[decision-profiles]], G9); target notes state one requirement in
  prose and name which open edges it exercises.
- Goals, arcs, elements: [[goals/README]] is the hub for the three tiers. A
  goal is a broad thing this project claims it is doing; an arc is the list of
  elements to be done for one goal, carrying that goal's requirements and its own
  resume state; an element is one catalog item. [[arcs/README]] lists the arcs.
  [[elements/README]] states what the element tier still owes.
- Checklists: [[records/README]] is the hub. One file per arc, each row a
  claim this repo makes about itself beside what was measured, with a state and a
  date. The one doc tier any agent may extend or amend without asking; the rules
  are in the hub. Seeded with [[records/baseline-alignment]].
- Provenance and open work: [[dump-integration]], [[open-edges]], [[resolution-patterns]]

## Convention

Principles are cited as P1 through P5, matching
[PRINCIPLES](../PRINCIPLES.md) (condensed from seven on 2026-07-20; a crosswalk in
that file is the authority for every P-number in the base). Tiers are cited
as T0 through T3, matching principle 5 (the tiering). Dump source items are cited by their ledger id (for example A9,
D8, C12) and resolved in [[dump-integration]].
