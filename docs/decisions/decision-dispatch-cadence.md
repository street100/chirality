---
node: decision-dispatch-cadence
layer: decision
related: [decision-inspiration-policy, arcs/presentability-arc, elements/README, index]
status: settled
updated: 2026-09-01
---

# Decision: dispatch cadence is serial

**Settled by standing author directive.** It governs how every queue in this
repository is worked: the pipeline (example, audit, spec, audit), the doc-audit
and doc-cleanup passes, the `.planning` consolidation, and any lane that
dispatches a subagent.

Hoisted here 2026-09-01. Until then it lived in four `.planning` files and in
`CLAUDE.md` at the root, all five ignored by `.gitignore:12` or by the rule that
ignores `.claude/`. A fresh clone got the queues without the rule that runs
them. `HANDOFF.md` carried a sixth statement and is tracked, but `HANDOFF.md` is
session state and is rewritten every few days. The sources are quoted below,
because a hoist is only honest if what was hoisted can be checked against what
was there.

## The directive

**Cadence is serial. One stage at a time, one agent at a time. Not a batch, not
a wave, not three.** The orchestrator dispatches the next stage only after the
previous one has returned and been merged.

It overrides every parallel-waves protocol written anywhere in this tree,
including the ones the pipeline documents describe for themselves.

## What follows from it

Each of these follows from the rule above and adds nothing to it. They are
written down because each names a protocol that exists only to make concurrency
safe, and a serial cadence leaves no concurrency for them to make safe.

- No agent waves. No `max N live`. No worktree fan-out for pipeline runs.
- `--no-index` does not apply, and neither does orchestrator-appends-rows.
  Each run updates its own INDEX row, because nothing races it.
- The next stage is dispatched after the previous one returns and is merged.
  Launch one, wait, merge, launch the next.
- A sweep fails the rule outright. The first consolidation pass was dispatched
  over all 138 remaining `.planning` files at once and was stopped for this
  reason (`records/consolidation-handoff.md`). Iterative passes, each checkable.

## What it does not decide

It says nothing about whether a stage runs in a subagent. That is a separate
standing rule, and it points the other way: the main session dispatches and
does not implement (`CLAUDE.md`, "You are the orchestrator", and `HANDOFF.md`,
"How to work here"). Serial cadence constrains how many agents are live at
once. It is one.

## The sources, and where they disagree

Six sites carried the directive on 2026-09-01. Verbatim, so the reconstruction
above can be audited:

| source | what it says |
|---|---|
| `CLAUDE.md`, "You are the orchestrator" | "Cadence is serial. One run at a time." Standing user directive, "it overrides the parallel-waves protocol the pipeline docs describe". Carries the four consequences above. |
| `.planning/SCRIBA-UNBLOCK-MAP.md`, "Dispatch queue" | "Cadence is serial: exactly ONE agent live at a time." Standing author directive, overriding the parallel-waves text that section used to carry. |
| `.planning/USER-LAYER-PIPELINE-PLAN.md` §1 | "these runs go serially, one at a time", standing user directive, "which overrides `CLAUDE.md`'s 'parallel waves' guidance for pre-runs". §4 is titled "The serial queue". |
| `.planning/USER-LAYER-TRACKER.md` | "Cadence: SERIAL. One stage at a time, one agent at a time." |
| `.planning/DOC-AUDIT-QUEUE.md` | "Cadence: serial. One document at a time, one agent at a time. Not a batch, not a wave, not three." |
| `HANDOFF.md`, "How to work here" | "Serial dispatch: exactly ONE subagent at a time. Standing user directive. Launch one, wait, merge, launch the next." |

Three disagreements, all recorded rather than smoothed:

1. **Each source names a different document as the one it overrides.**
   `SCRIBA-UNBLOCK-MAP` says it overrides `.planning/USER-LAYER-PIPELINE-PLAN.md`
   §1. That file and `USER-LAYER-TRACKER` both say they override `CLAUDE.md`.
   `CLAUDE.md` says it overrides "the pipeline docs". The citation is circular,
   and the `CLAUDE.md` half of it is stale: `CLAUDE.md` carries no parallel-waves
   text today and states the serial directive itself. **This note is the
   authority; nothing in the tree is left to override.**

2. **The unit differs across sources.** "One run" (`CLAUDE.md`,
   `USER-LAYER-PIPELINE-PLAN` §4), "one agent live" (`SCRIBA-UNBLOCK-MAP`),
   "one stage, one agent" (`USER-LAYER-TRACKER`), "one document, one agent"
   (`DOC-AUDIT-QUEUE`). A run is four stages, so the stage is the strictest
   reading, and it is the one `CLAUDE.md`'s own consequence clause agrees with:
   the next **stage** is dispatched after the previous one returns.
   **The binding unit is the stage.**

3. **"User directive" against "author directive".** Four sources say user, one
   says author, `records/consolidation-handoff.md` says author. Same person, and
   no source disputes the authority. Recorded because the phrasing differs. The
   origin is not in doubt.

Two tracked sources scope the rule to their own queue rather than to the repo:
`docs/arcs/presentability-arc.md` says its two working queues "run serial, one
document and one agent at a time, by standing user directive", and
`records/consolidation-handoff.md` states it for the consolidation. Both are
tracked and both remain correct as local restatements. This note is what they
are instances of.

`.planning/SCRIBA-UNBLOCK-MAP.md` was queued for archive once this hoist landed.
It is **not** archived, and the reason is written down here because the queue
will ask again: it is still the cited slice authority for the E96-E100 wave
(`docs/elements/catalog.md:418`), for the S17 arena decomposition that the E81,
E89, E90 and E91 examples and specs cite by section, and for E95's ground truth.
Its S12(d) ruling also carries a guardrail with no tracked home: `Sock` stays
`porttype`, and when real spawn returns, handing a socket to a child is a
transfer crossing that consumes the linear cap, never a re-demotion to `data`.
Until that lands somewhere tracked, the file is a KEEP.

## Why this tier

A decision is answerable and a definition is not (`MAP.md`, "The doc tier sorts
by role too"), and serial against parallel is answerable. `decisions/` is not
scoped to the language: it already holds `[[decision-inspiration-policy]]`,
which governs what external material may be read while an element is built, and
`[[decision-license]]`. `records/` was rejected because a record row is a claim
beside a measurement and this is neither. `PRINCIPLES.md` was rejected because
it is the locked spine about the language. `CONTENTS.md` and `[[index]]` link
the decisions rather than carry them, and they link this one.
