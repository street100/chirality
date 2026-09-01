---
node: decision-ai-tier
layer: decision
related: [index, working-discipline, decision-dispatch-cadence, records/author-calls, elements/README, arcs/README]
status: settled
updated: 2026-09-01
---

# Decision: the agent tier is tracked, and it is distinct from the human tier

**Settled by author directive, 2026-09-01.** It replaces the framing in `MAP.md`
that called `.planning/` untracked working scratch, and it removes three lines
from `.gitignore`.

## The split

One repository, two audiences.

| tier | audience | holds |
|---|---|---|
| `docs/`, `records/`, the root spine | a human reader, including a stranger | definitions, decisions, banks, goals, arcs, elements, measurements |
| `.planning/`, `CLAUDE.md`, `.claude/skills/` | an agent working the tree | navigation, protocol, relational maps, queues, handoffs, captures |

A document belongs to the agent tier if its reader is a session rather than a
person: a dispatch queue, a pack bundle contract, a worktree handoff, a
run-this-then-that procedure.

## Both tiers are tracked

`.gitignore` excluded `.planning/`, `**/CLAUDE.md` and `.claude/`. That made the
agent tier fork per worktree and vanish from a fresh clone. Two sessions minted
`E173` independently and nothing caught it (`MAP.md`, "Goals, arcs, elements").

On 2026-09-01 four agent documents were hoisted into `docs/` and `records/` to
escape that: [[working-discipline]], [[decision-dispatch-cadence]],
`docs/decisions/decision-lane-split.md`, `records/lane-a-record.md`. The hoist was
correct given the exclusion. Tracking the agent tier removes the exclusion, so
future agent material has a tracked home without being pushed through the tier a
stranger reads.

The four already hoisted stay where they are. Sixteen tracked files cite
`decision-lane-split` for its element bands, twenty-five cite the build rule, and
a repoint buys nothing.

## What this frees

`docs/` sheds material that sits there only because the agent tier was ignored.
Anything under `docs/` whose reader is a session rather than a person is now
movable. Each move is its own change with its citers repointed.

## What stays ignored

| pattern | why |
|---|---|
| `.claude/*` except `.claude/skills/` | settings, caches and session files are machine state. Skills are protocol |
| build outputs, `__pycache__/` | transient |

## What this does not decide

- **The prune.** `.planning/` carries 72 entries, many of them spent handoffs and
  superseded findings from July. Tracking makes the consolidation queue visible.
  It does not bless the content, and `records/consolidation-handoff.md` still
  holds that queue.
- **Where the pipeline skills live.** `.claude/skills/` is fixed by the harness,
  which loads skills from that path. If a skill's prose outgrows a skill file, the
  prose moves to `.planning/` and the skill points at it.
