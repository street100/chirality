# chirality — umbrella project (the long road)

> Spine: `../PRINCIPLES.md`, `../SECURE-DATUM-MODEL.md`, `../PERSONA.md`, `../MAP.md`
> Design base: `../docs/`
> Siblings: `../01-bhumi-context/`, `../02-language-design/`, `../03-development-approach/`

## Purpose

Hold the long road of building chirality as one developmental arc. The three sibling
projects each own a slice; this umbrella names the whole route from a design base
to a self hosting language that the bhumi tool family is reimplemented under. It
is the place to see where any piece of work sits on the road.

This is a developmental project. There are no dates and no size budgets. The
dumps were full of both and all of it was rejected as estimate theater for a
language that does not exist (see `../docs/dump-integration.md`). Stages are a
spine with backflow, not a schedule.

## Where the road runs

From here outward, in `../.planning/ROADMAP.md`:

1. Design base (current).
2. Resolve the load bearing open edges.
3. The kernel (QTT trusted core).
4. The typed core (category A upper).
5. The lowering floor (typed assembly, no untyped bottom, first backend).
6. Staging and generation (one staged compiler plus the pregen twin).
7. The bridge (category C, the novel core).
8. Substrate and silicon (category B, the CHERI floor, secure datum end to end).
9. Bootstrap and self host.
10. Profiles and targets.
11. Bhumi reimplementation.

The ordering is a primary spine. Expect backflow: building a stage will surface a
gap in an earlier one. Stages 6 and 7 interleave; 10 and 11 depend on 9.

## How the siblings map onto the road

- `01-bhumi-context` feeds stages 7 and 11. What recurs across bhumi daemons that
  the language should reify, and which tools port how.
- `02-language-design` owns stages 2 through 8. The `../docs/` base is its live
  output.
- `03-development-approach` owns stages 9 through 11. Bootstrap order, the
  reimplementation strategy, the dogfooding ladder.

## How this relates to the docs base

The `../docs/` notes are the design substance. This project is the route through
them. A stage completes when its modules have homes in the note base, their
decisions are recorded, and their open edges are either closed or named. The road
does not duplicate the notes; it sequences them.

## Anti-goals

- Do not put design substance here. That lives in `../docs/`. This is sequencing.
- Do not commit dates or sizes. Developmental means the stages firm up as real
  work earns the detail.
- Do not treat the road as one way. Backflow is expected and is how the earlier
  stages get corrected.

## Status

Stage 1 in progress. The design base exists: principles, secure datum model, the
two axis module map, four settled decisions, and the open edges. Next work is
stage 2, resolving the load bearing open edges, starting with the cost gradient
mechanism and the reflective floor. See `../docs/open-edges.md`.
