> **ARCHIVED 2026-09-01. Superseded by `CONTENTS.md` and `README.md`, both tracked, which carry the orientation this file duplicates.**

# chirality

Planning umbrella for **chirality**, a new programming language with modular focus,
designed in dialogue with the reimplementation needs of the bhumi tool ecosystem.

- Longhand: `chirality`
- Short: `chirality`
- Shortest (when context is obvious): `chirality`

Tagline read: *common-sense, the language*.

## Start here

- [CONTENTS.md](../CONTENTS.md): the whole project on one screen, with links into detail.
- [PERSONA.md](PERSONA.md): how to work in this repo.
- [.planning/PROJECT.md](PROJECT.md) and [.planning/ROADMAP.md](ROADMAP.md): the long road as developmental stages.

## Three sibling GSD projects

Each subfolder is an independent GSD project (`.planning/PROJECT.md` + phases).

| # | Project | Purpose |
|---|---------|---------|
| 01 | `01-bhumi-context/` | Gather + structure the parts of bhumi that should shape the language. What patterns recur across daemons, what gets reimplemented, what abstractions are missing today. |
| 02 | `02-language-design/` | Principles, semantics, type system, module model, runtime story, ABI/FFI posture, and concrete implementation goals for chirality. |
| 03 | `03-development-approach/` | How to build chirality itself + the meta-strategy for reimplementing bhumi tools under it. Bootstrap order, parity-vs-replacement calls, dogfooding loop, and how each stage feeds the next. |

## Sequencing intent

Information flows 01 → 02 → 03, but expect backflow:

- 02 may surface a missing bhumi observation → adds to 01.
- 03 may expose a feature gap → adds to 02.
- 01 may reveal a recurring shape that *should be* a language primitive → seeds 02.

Treat the order as the **primary spine** rather than a one-way pipeline.

## Design knowledge base

The cross-cutting design lives in two places:

- Root spine docs: [PRINCIPLES.md](../PRINCIPLES.md) and [SECURE-DATUM-MODEL.md](../docs/definitions/secure-datum-model.md).
- A linked note set under [`docs/`](docs/), one idea per note, organized like an
  org-roam base. Start at [docs/index.md](../docs/index.md). The module map is
  [docs/module-map.md](../docs/modules/module-map.md); settled forks are the `docs/decision-*`
  notes; open work is [docs/open-edges.md](../docs/definitions/open-edges.md).

The raw brainstorm material it was built from is in [`GIANTDUMP/`](GIANTDUMP/);
the audit of what was kept or rejected is [docs/dump-integration.md](../docs/definitions/dump-integration.md).

## Status

Actively developed. Principles are drafted (condensed seven→five, 2026-07-20) and
the module architecture is mapped across two axes (typeability and altitude) in
`docs/`, with the major forks settled (`docs/decision-*`) and the open edges
listed. Since 2026-07-05 a host-language **scaffold** runs first targets: a QTT
kernel, typed-assembly floor, native x86-64 backend, refinement/totality slices,
a self-hosted syscall arena, and an orchestration substrate. 281 tests are
green. What is real vs. designed is tracked in
[docs/status-ledger.md](../docs/definitions/status-ledger.md) and
[scaffold/README.md](../docs/implementation/README.md).
