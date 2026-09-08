# The agent tier

`.planning/` is written for a session. `docs/` and `records/` are written for a
person. `docs/decisions/decision-ai-tier.md` draws the line, and both tiers are
tracked, so a fresh clone and every worktree see the same thing.

## What is here

| path | holds |
|---|---|
| `protocol/` | how work is done here: tone, placement, workflow, dispatch |
| `PERSONA.md` | the operating stance. How to show up, what the author steers |
| `ROADMAP.md` | the long road, a spine with backflow |
| `archive/` | spent material kept because something still cites it |
| `audit/`, `capture/`, `capture-fixtures/`, `handoffs/`, `projects/` | the older sorted tiers |
| the flat `*.md` at top level | mostly unsorted legacy from 2026-07 and 2026-08, and a few live working files. `README-PLAN.md` is the live discussion relay `protocol/placement.md` names; `FILE-KIND-STRUCTURES.md` (2026-09-02) holds the semantic split the file kinds follow from; `MANIFEST-DESIGN-MAP.md` holds `.manifest`'s own design |

The flat top level is a backlog of 72 entries and `records/consolidation-handoff.md`
holds the queue that sorts it. Several of those files are still load bearing:
`SCRIBA-UNBLOCK-MAP.md` is the cited slice authority for the E96-E100 wave, for
the S17 arena decomposition and for E95, and `USER-LAYER-GAP.md` plus
`SCRIBA-PRIMITIVE-CHECKLIST.md` are two of `pack.py`'s three ledger sources.
Read a file here before assuming it is dead.

## The four protocol documents

| document | answers |
|---|---|
| `protocol/tone.md` | how a sentence in this repo is written, and what enforces it |
| `protocol/placement.md` | I have a thing to write. Which tier, which directory, which form |
| `protocol/workflow.md` | the element pipeline end to end, stage by stage |
| `protocol/dispatch.md` | how an arc session orchestrates, and what a stage prompt carries |

Each states the operational procedure and cites the tracked document that holds
the rule. Where the two disagree the tracked document wins, and the disagreement
is a defect to fix here.

## The harness

Nine skills in `.claude/skills/`, each one run, one unit of work, one artifact,
then stop. The pipeline they run is
`docs/decisions/decision-design-before-mint.md`.

| skill | turns |
|---|---|
| `goal-open` | an ambition the repo already states into one goal |
| `arc-open` | one goal condition into requirements and a roster |
| `element-design` | one roster row into a design, before any `E#` exists |
| `pipeline-audit` | gates a design before it mints, and a SPEC before it is built |
| `design-to-spec` | one minted element into an implementation SPEC |
| `revisit` | one settled artifact against one named trigger |
| `doc-audit` | one doc, semantic pass against its live authorities |
| `translate` | one published external object into this tree's forms |
| `research` | one question about the outside world, with its sources pinned |

`worked-example` and `example-to-spec` are retired.

## What does not go here

A rule a person needs to read, a claim about the tree, and build state all have
homes in `docs/` and `records/`. `protocol/placement.md` routes them.

What the project knows about itself lives in `records/lenses/`: four enumerated
lenses for problems, gaps, limits and unspoken territory, each row carrying an
author marker. `docs/definitions/OVERVIEW.md` is the generated view over all of
it, written by `tools/lens/lens.py overview`.
