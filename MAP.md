# chirality — project map

Read this first to orient. It is the layout of the whole project on one screen,
with links into the detail. For how to work here, read `.planning/PERSONA.md` (internal
working doc; not part of the public mirror).

Draft, 2026-06-16; scaffold running since 2026-07-05. Developmental.

---

## What chirality is

A new programming language born from the bhumi OS and tool ecosystem. One thesis
runs under it: a gap is an ungoverned path. To control everything you must be
able to express everything, so that everything expressible is named and
checkable. See [PRINCIPLES.md](PRINCIPLES.md).

## The spine (root, locked, plain markdown)

Root holds four documents and nothing else. Everything that used to float there
was sorted on 2026-08-31 into the tier it belongs to.

- [README.md](README.md): the public front door.
- [PRINCIPLES.md](PRINCIPLES.md): five principles, one thesis (condensed from
  seven 2026-07-20; a crosswalk in the doc keeps old P1-P7 citations resolving).
- [LAYOUT.md](LAYOUT.md): the tree contract. Extensions, module key, doc roles.
- [HANDOFF.md](HANDOFF.md): state and route. Where a session starts.
- This map.

Moved out, and where they went:
[secure-datum-model](docs/definitions/secure-datum-model.md) and
[bootstrap](docs/definitions/bootstrap.md) are named concepts, so they are notes
in the design base. `.planning/PERSONA.md` and `.planning/UMBRELLA.md` are
internal working documents, and `.planning/MIGRATION-MAP.tsv` is a record.

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
- Trust discipline: `certificate-discipline` (trusted checker, untrusted producers —
  re-run the work, don't spot-check; prove elements and provable interactions, not the
  whole), `split-role` (where proof runs out, the split as a tiered substrate-provided
  role for the unprovable residue).
- Applications: `live-environment` (the hub) — a live self-modifying environment,
  opened first as an AI-orchestration layer, read through the node model.
- Inspirations: the touchstones the live environment fuses, each lighting one axis
  and anchoring none — `insp-smalltalk`, `insp-lisp-machine`, `insp-emacs`,
  `insp-oberon` (residential), `insp-erlang-beam`, `insp-capability-os` (mesh),
  `insp-unison` (substrate).
- Provenance and open work: `dump-integration`, `open-edges`.
- Navigation: `index`, `relations`, `glossary`, `vocabulary`, `perspectives`.
- Banks (depth tier): `banks/INDEX` — the full refraction of a concept into
  shards, homes, and build-state, under the thin notes above (module, profile,
  runtime, capability, port, effect-and-alarm, memory, evidence-and-split).

## Architecture at a glance

Two axes place every module.

- Typeability: A typed (proof), B untyped (quarantined substrate), C the
  supervisory bridge (typed module, untyped referent, governs by evidence). C is
  the novel core.
- Altitude: a span, not a partition. Three levels, upper, the typed assembly
  floor (tal), and the metal, with drops between. Types are preserved and checked
  down to tal; below tal is the one trusted drop to machine code, or to CHERI
  silicon where the marks reach the metal. No untyped bottom.

The splitting law decides boundaries: a module spanning two categories is under
split; split only when the halves have different types. Its dual, the joining
law, decides how cut modules reconnect: four typed connectors (bridge, lowering,
staging, port composition), each preserving the one invariant its boundary
protects. The modules are the alphabet; the connectors are the grammar. Full
table in [docs/module-map.md](docs/modules/module-map.md); the connectors in
[docs/joining-law.md](docs/definitions/joining-law.md).

The whole runs as nodes. Code runs in nodes that touch only through typed ports,
with no central kernel: substrate is owned by nothing and governed in the port's
type, and state is several cross-checked truths reconciled by typed processes. A
node is a self-similar compiler-plus-runtime bundle, and a remote node is just a
node you hold a port to, so distribution is native. See
[docs/node-architecture.md](docs/definitions/node-architecture.md) and
[docs/process-and-runtime.md](docs/definitions/process-and-runtime.md).

## The long road

The umbrella GSD project is in [.planning/PROJECT.md](.planning/PROJECT.md); the
developmental stages are in [.planning/ROADMAP.md](.planning/ROADMAP.md). The
short version, from here outward: resolve the load bearing open edges, build the
QTT kernel, the typed core, the lowering floor, staging and generation, the
bridge, the substrate and silicon floor, bootstrap to self host, the profiles and
targets, then reimplement the bhumi tools. It is a spine with backflow, not a
schedule.

## The scaffold (first running code)

`scaffold/` is the stage 9 host-language scaffold, pulled forward (2026-07-05)
to run the first target, [docs/target-tomodachi.md](docs/definitions/target-tomodachi.md).
It follows the module architecture, not implementation convenience:

- a minimal QTT kernel with two seams (term-former handlers, membrane rules);
  the types and effects modules live behind them, not in the kernel;
- primitives declared in chirality source (`extern`, `porttype`;
  `lib/prelude.chiral` is the A floor, `lib/ports.chiral` the C floor), host
  bindings linked at load, and the bridge connector's inbound face checking
  the values a binding returns (runtime tags and arities, depth-bounded —
  evidence at the crossing, not a deep proof);
- profiles as manifests over a frozen port set with a target requirement
  type, judged by `chirality verify` (G9); four ship over one module base,
  including a two-node split (sensor and renderer runtimes joined by one
  typed port: the node model in miniature);
- the lowering connector: the pure fragment compiles to a typed-assembly
  floor (`tal.py`) and the tal checker re-checks every compiled body against
  its declared type (the preserve-check); crossings stay upper by
  construction. `MET_TAL=1` runs the demo on the floor.

The demo is the tomodachi written in chirality: Wayland wire client (no
libwayland), niri event stream, swappable pure behavior pack. Verified
headless against protocol mocks; on a real niri session:
`python3 -m chirality run demo/tomodachi.chiral`. What is real versus stubbed:
[scaffold/README.md](docs/implementation/README.md); findings ledger in
[scaffold/AUDIT.md](docs/implementation/AUDIT.md).

## The three sibling projects

Each is its own GSD project under the umbrella.

- [01-bhumi-context](.planning/PROJECT.md) — what the bhumi tool
  family needs the language to express.
- [02-language-design](.planning/PROJECT.md) — the language
  itself. The `docs/` base is its working output.
- [03-development-approach](.planning/PROJECT.md) — how
  chirality gets built and how bhumi reimplements under it.

Information flows 01 to 02 to 03, with backflow. See the umbrella project for the
sequencing intent.

## Settled and open

- Forks settled in `docs/decisions/` (sixteen notes): additive testable profiles
  over a frozen port set; two brokers agreeing via Adhikara; own typed backend
  with no compile to C; B in the type not the packaging; the graded/cost-kernel
  direction; the inspiration policy; the checker as a small trusted core plus
  untrusted certificate producers; the bridge elaborator; effects as two facets
  (possession + exercise) with alarms as crossings; deployment/custody as a
  per-instance decentralized translation of centralized product instincts; and the
  reflective floor as a frozen judgment changed only by certified succession; and
  the user layer extending in chirality, live, above that same frozen kernel line.
- Open work: the unresolved seams enumerated in
  [docs/open-edges.md](docs/definitions/open-edges.md), with three sequencing questions not
  yet committed.

## Start here

New to the project: PRINCIPLES, then `docs/index.md`, then `docs/module-map.md`.
Picking up work: `docs/open-edges.md` for what is next, this map for where it
sits.
