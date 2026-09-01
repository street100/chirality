> **ARCHIVED 2026-09-01. Superseded by its own Status section, which already declares it.** MODULES, SEMANTICS, TYPES and RUNTIME landed as the `docs/definitions/` notes and `PRINCIPLES.md` is written.

# 02 — chirality language design

> Siblings: the other files in `.planning/projects/`.
> Umbrella: `README.md` at the tree root.

## Purpose

Specify **chirality** — its principles, semantics, and implementation goals. Driven by
two pressures simultaneously:

1. **The user's principles** (to be dropped — modular focus is the headline so far).
2. **The shape inventory from project 01** (what bhumi needs to express).

The design is not bhumi-specific, but bhumi is the **proving ground**: every design
choice should be checked against "does this make the bhumi tool family better, or
just different?"

## Anti-goals

- Do **not** treat this as a bhumi DSL. chirality is a general-purpose language; bhumi is
  one (very demanding) consumer.
- Do **not** plan implementation phases yet — that's project 03. This project produces
  the *what*, not the *how*.
- Do **not** chase novelty for its own sake. Borrow shamelessly where prior art is good.

## Inputs (read these)

- User-supplied principles document (to be dropped into this project; see Status).
- Outputs of project 01 — shape inventory, friction log, invariant register.
- Prior-art references (to be enumerated based on what the user's principles signal):
  Rust, Zig, Hare, Roc, Koka, Austral, Inko, Gleam, Unison, etc. — pick those the
  principles overlap with.

## Outputs (what this project produces)

- **PRINCIPLES.md** — locked design principles with rationale (the spine).
- **SEMANTICS.md** — evaluation model, ownership/lifetime/effect story, error model.
- **TYPES.md** — type system shape.
- **MODULES.md** — modularity model (headline focus per user).
- **RUNTIME.md** — runtime/no-runtime posture, async story, FFI/ABI.
- **IMPLEMENTATION-GOALS.md** — concrete deliverables (compiler, stdlib slice, target backends, bootstrap path) that project 03 then sequences.

## Phases

To be planned once user principles are captured. Likely:

- Phase 1 — Capture + structure user principles → PRINCIPLES.md.
- Phase 2 — Cross-check principles against project 01 outputs; flag conflicts.
- Phase 3 — Semantics + types + modules + runtime decisions (probably 1 phase each).
- Phase 4 — Implementation-goals doc that project 03 consumes.

## Status

Principles captured (`../../PRINCIPLES.md`, `../../SECURE-DATUM-MODEL.md`) and the
module architecture mapped in `../../docs/`. The map places every module on two
axes: typeability (typed / untyped / supervisory-bridge) and altitude
(upper / lower), with a splitting law deciding module boundaries. Brainstorm
dumps audited and integrated (`../../docs/dump-integration.md`). Four design
forks settled (`../../docs/decision-*`). Outstanding work is tracked in
`../../docs/open-edges.md`.

The outputs listed above now map onto the `docs/` notes: MODULES.md is
`module-map.md` plus the `modules-*` notes; SEMANTICS/TYPES/RUNTIME content is
distributed across the category and module notes; remaining specs get written as
the open edges close.
