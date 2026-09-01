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
| the flat `*.md` at top level | unsorted legacy from 2026-07 and 2026-08 |

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

## What does not go here

A rule a person needs to read, a claim about the tree, and build state all have
homes in `docs/` and `records/`. `protocol/placement.md` routes them.
