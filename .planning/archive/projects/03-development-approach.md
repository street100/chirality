> **ARCHIVED 2026-09-01. Superseded IN HALF, and the other half has no home.** The bootstrap half is covered by `docs/definitions/bootstrap.md` and `docs/definitions/bootstrap-sequence.md`, both tracked. ⚑ **The bhumi port-strategy half has no tracked home at all and is the one thing lost by archiving this file.** Named here rather than silently dropped. Whether it is still wanted is an author call.

# 03 — development approach

> Siblings: the other files in `.planning/projects/`.
> Umbrella: `README.md` at the tree root.

## Purpose

Define **how chirality gets built** *and* **how bhumi gets reimplemented under it**, as
one coupled problem. The two questions answered here:

1. What's the **bootstrap + maturity path** for chirality itself? (Compiler, stdlib,
   tooling, package format, target arches — especially aarch64/RK3588, x86_64 server,
   x86_64 laptop.)
2. What's the **reimplementation strategy** for bhumi tools — given that a lot of
   work being planned right now is, in this future, going to be redone under a
   different form?

The second is the harder problem: it forces a call on *every current bhumi
project* — keep building in Rust today and port later? pause and wait for chirality?
build in Rust now with an eye to a clean port? skip Rust entirely for some tools?

## Anti-goals

- Do **not** advocate "stop everything until chirality exists." The bhumi roadmap has
  active commitments and real timelines.
- Do **not** ignore the cost of duplicate work. Every "port later" decision is a
  bet that chirality will materialize.
- Do **not** confuse "build chirality" with "build everything in chirality." Some bhumi
  components may never move.

## Inputs (read these)

- Outputs of project 01 (port-disposition table) and project 02 (implementation goals).
- Current bhumi v0 roadmap state + active workspace projects.
- KB: `tools/dsub.md` and `patterns/dsub-when-to-delegate.md` (delegation pattern
  matters here — bulk reimpl is exactly the dsub profile).

## Outputs (what this project produces)

- **CHIRALITY-BOOTSTRAP.md** — compiler stages (host language for v0 compiler, self-host
  target, stdlib floor, package/build tool).
- **PORT-STRATEGY.md** — per-tool decision: rewrite-in-chirality-day-1 / build-rust-port-later / leave-permanently. Includes ordering (which ports unlock which downstream gains).
- **PARALLEL-BUILD-PLAN.md** — how chirality dev + bhumi-current dev coexist without one
  starving the other.
- **FEEDBACK-LOOPS.md** — explicit description of how each of the three projects
  feeds the others; what triggers a backflow update.
- **DOGFOODING-LADDER.md** — what gets built *in chirality* in what order to stress the
  language (probably: small bhumi tool → daemon → full broker component).

## Phases

To be planned once 01 + 02 produce their first synthesis docs. Plan-phase here is
expensive — it's the project that actually sequences months/years of work.

## Status

Scaffold. **Blocked on 01 + 02 first-pass outputs.** Can be sketched in parallel
to clarify constraints, but real decisions wait for upstream context.
