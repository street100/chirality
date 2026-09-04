# chirality: contents

Read this first to orient. It is the index into the whole project on one screen,
with links into the detail. How to work here is the agent tier:
[`.planning/PERSONA.md`](.planning/PERSONA.md) is the stance and
[`.planning/protocol/`](.planning/protocol/) holds tone, placement, workflow and
dispatch. Both are tracked and both ship in the mirror;
[decision-ai-tier](docs/decisions/decision-ai-tier.md) draws the line between
what is written for a person and what for a session.

---

## What chirality is

A new programming language. One thesis runs under it: a gap is an ungoverned
path. To control everything you must be
able to express everything, so that everything expressible is named and
checkable. See [PRINCIPLES.md](PRINCIPLES.md).

## The spine

Root holds five markdown documents plus the two licenses. Everything that used
to float there was sorted into the tier it belongs to, and the arc handoffs
followed: the last two left on 2026-09-03.

- [README.md](README.md): the public front door.
- [PRINCIPLES.md](PRINCIPLES.md): five principles, one thesis.
- [MAP.md](MAP.md): the tree contract. Extensions, module key, doc roles.
- [CLAUDE.md](CLAUDE.md): the agent tier's entry point, tracked.
- This file, the contents.

Two more documents are spine and live in the tier that owns them:
[working-discipline](docs/definitions/working-discipline.md) is the work
contract, and [docs/index.md](docs/index.md) is the design base that goals, arcs,
elements and the banks hang off.

A lane is who works and an arc is what gets worked.
[decision-lane-split](docs/decisions/decision-lane-split.md) holds the division
and reserves the two element bands; it moved out of the root on 2026-09-01 and
`records/author-calls.md` records that placement as closed.

Moved out, and where they went:
[secure-datum-model](docs/definitions/secure-datum-model.md) and
[bootstrap](docs/definitions/bootstrap.md) are named concepts, so they are notes
in the design base. `.planning/PERSONA.md` is an internal working document and
`.planning/MIGRATION-MAP.tsv` is a record. `.planning/UMBRELLA.md` was archived
to `.planning/archive/UMBRELLA.md`: it duplicated this file and
`README.md`, which are its successors.

## The design base (docs/, linked notes)

Entry point: [docs/index.md](docs/index.md). The base is an org-roam style note
set, one idea per note, linked with `[[slug]]`. Groups:

- Foundations: `thesis`, `axis-typeability`, `axis-altitude`, `splitting-law`,
  `joining-law`, `process-and-runtime`, `bootstrap-sequence`.
- Categories: `category-typed` (A), `category-untyped` (B), `category-bridge` (C).
- Modules: `module-map` (the hub table) plus `modules-core`, `modules-security`,
  `modules-custody`, `modules-broker`, `modules-substrate`, `modules-bridges`,
  `modules-lowering`, `modules-staging`.
- Decisions: `decision-profiles`, `decision-brokers`, `decision-backend`,
  `decision-b-in-type`, `decision-split-checker` (the checker: small trusted core
  plus untrusted certificate producers), `decision-bridge-elaborator`.
- Trust discipline: `certificate-discipline` (trusted checker, untrusted
  producers: re-run the work rather than spot-check it, and prove elements and
  provable interactions rather than the whole), `split-role` (where proof runs out, the split as a tiered substrate-provided
  role for the unprovable residue).
- Applications: `live-environment` (the hub): a live self-modifying environment,
  opened first as an AI-orchestration layer, read through the node model.
- Inspirations: the touchstones the live environment fuses, each lighting one axis
  and anchoring none: `insp-smalltalk`, `insp-lisp-machine`, `insp-emacs`,
  `insp-oberon` (residential), `insp-erlang-beam`, `insp-capability-os` (mesh),
  `insp-unison` (substrate).
- Provenance and open work: `dump-integration`, `open-edges`.
- Goals, arcs, elements: `goals/README` names what this
  project claims it is doing and which arcs serve each claim; `arcs/README`
  names the arcs, each carrying its goal, its requirements, its element list and
  its resume state; `elements/README` states what the element tier still owes.
- Navigation: `index`, `relations`, `glossary`, `vocabulary`, `perspectives`.
- Banks (depth tier): `banks/INDEX`: the full refraction of a concept into
  shards, homes, and build-state, under the thin notes above (module, profile,
  runtime, capability, port, effect-and-alarm, memory, evidence-and-split).

## Architecture at a glance

Two axes place every module.

- Typeability: A typed (proof), B untyped (quarantined substrate), C the
  supervisory bridge (typed module, untyped referent, governs by evidence). C is
  the novel core.
- Altitude: a span rather than a partition. Three levels, upper, the typed assembly
  floor (tal), and the metal, with drops between. Types are preserved and checked
  down to tal; below tal is the one trusted drop to machine code, or to CHERI
  silicon where the marks reach the metal. No untyped bottom.

The splitting law decides boundaries: a module spanning two categories is under
split; split only when the halves have different types. Its dual, the joining
law, decides how cut modules reconnect: four typed connectors (bridge, lowering,
staging, port composition), each preserving the one invariant its boundary
protects. The modules are the alphabet; the connectors are the grammar. Full
table in [module-map](docs/modules/module-map.md); the connectors in
[joining-law](docs/definitions/joining-law.md).

The whole runs as nodes. Code runs in nodes that touch only through typed ports,
with no central kernel: substrate is owned by nothing and governed in the port's
type, and state is several cross-checked truths reconciled by typed processes. A
node is a self-similar compiler-plus-runtime bundle, and a remote node is just a
node you hold a port to, so distribution is native. See
[node-architecture](docs/definitions/node-architecture.md) and
[process-and-runtime](docs/definitions/process-and-runtime.md).

## The long road

The developmental stages are in [.planning/ROADMAP.md](.planning/ROADMAP.md).
The short version, from here outward: resolve the load bearing open edges, build
the QTT kernel, the typed core, the lowering floor, staging and generation, the
bridge, the substrate and silicon floor, bootstrap to self host, the profiles and
targets, then build the custody tool family on it. It is a spine with backflow
rather than a schedule.

What the project claims it is doing, and who is doing it, sits one tier down:
[`docs/goals/`](docs/goals/) holds eleven goals, [`docs/arcs/`](docs/arcs/) holds
the eighteen arcs serving them, and [`docs/elements/`](docs/elements/) holds the
catalog, the ledger and one SPEC per element. A goal carries no build state;
that lives on four rungs in
[status-ledger](docs/definitions/status-ledger.md).

## The code

`scaffold/` and the Python host are gone, retired by the 2026-08-31 migration.
The compiler is written in chirality and compiles itself, and no Python runs in
the compile, check or run path. [README.md](README.md) walks the tree and
[MAP.md](MAP.md) is the contract it follows: the extension is the file's kind,
the directory is its role, and the module key is the root-relative path.

- `lib/` is the importable tree, 105 modules in thirteen groups.
- `prog/` is what chirality ships, including `demo/` and the 69 programs in
  `samples/`.
- `bin/chirality` is the CLI and `bin/chirality-bin` is the compiler, a blob on
  stdin and an ELF on stdout.
- `tools/` is one folder per tool. Nine still hold the Python being replaced.

The first target named was the tomodachi, a Wayland wire client with no
libwayland, a niri event stream and a swappable pure behavior pack. It is
parked, ungated and never run against a compositor:
[target-tomodachi](docs/definitions/target-tomodachi.md) carries the state. What the scaffold era
proved and what it stubbed is kept in
[docs/implementation/](docs/implementation/), with the findings ledger in
[AUDIT.md](docs/implementation/AUDIT.md).

## Settled and open

- Forks settled in `docs/decisions/` (24 notes): additive testable profiles
  over a frozen port set; two brokers agreeing via Adhikara; own typed backend
  with no compile to C; B in the type not the packaging; the graded/cost-kernel
  direction; the inspiration policy; the checker as a small trusted core plus
  untrusted certificate producers; the bridge elaborator; effects as two facets
  (possession + exercise) with alarms as crossings; deployment/custody as a
  per-instance decentralized translation of centralized product instincts; and the
  reflective floor as a frozen judgment changed only by certified succession; and
  the user layer extending in chirality, live, above that same frozen kernel line;
  and dispatch cadence as serial, one stage and one agent at a time; and the
  erased-word type living strictly at the lowering type level, with the kernel's
  `conv` relation left alone. One of the 24 is a proposal and says so in its own
  first line: [decision-formulation-distinctness](docs/decisions/decision-formulation-distinctness.md)
  drafts what makes two judges distinct enough that their agreement is evidence,
  and it is `status: draft` awaiting the author.
- Open work: the unresolved seams enumerated in
  [open-edges](docs/definitions/open-edges.md). Its closing section holds three
  sequencing questions: which security properties block the trusted base is open,
  the type-system build order records a later partial closure, and the
  first-backend choice was closed by reconciliation on 2026-07-22.

## Start here

New to the project: PRINCIPLES, then `docs/index.md`, then
`docs/modules/module-map.md`. Picking up work: the arc in `docs/arcs/` that owns
it, since an arc file carries its own resume state, then
`docs/definitions/open-edges.md` for the seams nobody has closed.
