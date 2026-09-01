> **ARCHIVED 2026-09-01. Superseded and never executed.** None of its four outputs (shape inventory, friction log, invariant register, port-disposition table) was ever produced, and its planning idiom is a GSD phase command, which `CLAUDE.md` states this repo does not use. What it was reaching for is covered by `docs/definitions/perspectives.md`, `docs/definitions/memory-model.md` and `docs/modules/modules-broker.md`, all tracked.

# 01 — bhumi context (for chirality)

> Siblings: the other files in `.planning/projects/`.
> Umbrella: `README.md` at the tree root.

## Purpose

Build a structured view of the bhumi ecosystem **filtered through the lens of "what
would a new language need to express well to host these tools natively?"** This is
not a general bhumi catalog — those already exist in the KB
(`~/.claude/knowledgebase/projects/bhumi-*.md`). This project distills:

1. **Recurring shapes** across bhumi daemons that a language could reify as primitives
   (capability-services, broker upcalls, zero-key-custody delegation, IPC frame
   contracts, audit-emit channels, etc.).
2. **Friction points** in current/planned implementations that stem from the language
   being used (Rust, C, shell), not the design itself.
3. **Invariants** the language must preserve to make bhumi safer-by-construction
   (memory hygiene, capability scoping, no-ambient-authority, time integrity).
4. **Reimplementation candidates** — which tools are "port verbatim", which are
   "redesign under new primitives", which stay in their current language permanently.

## Anti-goals

- Do **not** re-document bhumi architecture from scratch — link to KB and `.planning/`.
- Do **not** decide language features here — that's project 02. Surface *requirements*,
  not solutions.

## Inputs (read these)

- `~/.claude/knowledgebase/projects/bhumi-navigation.md` — read first
- `~/.claude/knowledgebase/projects/bhumi-linux.md`, `bhumi-related-projects.md`, `broker-architecture.md`, `broker-mesh.md`
- `~/workspace/{sua,bija,yama,yama-bija,kavacha,sutra,saksin,bhumi-rite,prana,deepa,achala,bhumilook,shredcoord,shrepo,bhumi-CA,kosha}/.planning/PROJECT.md` (12+ daemon specs)
- KB patterns: `bhumi-key-lifecycle.md`, `security-layering-plan.md`, `mac-namespaces-bhumi.md`, `memory-hygiene-bhumi.md`

## Outputs (what this project produces)

- A **shape inventory**: recurring patterns across daemons with frequency + variance.
- A **friction log**: per-tool notes on what the current implementation language makes awkward.
- An **invariant register**: properties chirality must preserve or enforce.
- A **port-disposition table**: per tool — verbatim / redesign / leave-alone.

These outputs become **inputs to project 02** (language design) and **project 03** (dev approach).

## Phases

To be planned via `/gsd:plan-phase` once initial sweep scopes the work.

Likely phase shape (not yet committed):

- Phase 1 — Shape inventory sweep across all daemon specs.
- Phase 2 — Friction log assembled from current Rust/C/shell pain points.
- Phase 3 — Invariant register + port-disposition table.
- Phase 4 — Synthesis doc that project 02 can consume as a single brief.

## Status

Scaffold. No phases planned yet. Awaiting language-context drop from user before
deciding sweep order (some bhumi areas matter more depending on what chirality intends to be).
