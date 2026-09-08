# chirality

This file is the agent tier's entry point, and it is tracked. `docs/` and
`records/` are written for a human reader; `.planning/`, this file and
`.claude/skills/` are written for a session. `docs/decisions/decision-ai-tier.md`
draws the line and both tiers are in git.

Doctrine lives in the tracked documents below. Do not restate a rule here. A
second statement of a rule drifts from the first, which is the defect this file
was emptied to close.

| what you came for | where it is |
|---|---|
| the build rule, the deferral rule, commits, reporting | `docs/definitions/working-discipline.md` |
| the tree contract: extensions, module key, doc roles | `MAP.md` |
| the tier split: what is written for a person, what for a session | `docs/decisions/decision-ai-tier.md` |
| serial dispatch, one stage and one agent at a time | `docs/decisions/decision-dispatch-cadence.md` |
| scope: self-hosting only, ownership deferred | `docs/decisions/decision-scope.md` |
| the two lanes and the reserved element bands | `docs/decisions/decision-lane-split.md` |
| read the bank before naming a gap | `docs/banks/INDEX.md` |
| problems, gaps, limits, unspoken territory | `records/lenses/README.md` |
| where everything stands, generated | `docs/definitions/OVERVIEW.md` |
| build state on the four rungs | `docs/definitions/status-ledger.md` |
| goals, arcs, elements | `docs/goals/`, `docs/arcs/`, `docs/elements/` |
| a claim beside its measurement | `records/` |
| a published object rendered into our forms | `docs/translations/` |
| decisions only the author can make | `records/author-calls.md` |
| where a session resumes | the arc file in `docs/arcs/`. There is no root state file |

## The agent tier

`.planning/README.md` maps it. Four protocol documents carry the procedure.

| document | answers |
|---|---|
| `.planning/protocol/tone.md` | how a sentence here is written, and what enforces it |
| `.planning/protocol/placement.md` | I have a thing to write. Which tier, which directory, which form |
| `.planning/protocol/workflow.md` | the element pipeline end to end, stage by stage |
| `.planning/protocol/dispatch.md` | how an arc session orchestrates, and what a stage prompt carries |

`.planning/PERSONA.md` is the operating stance.

## The harness

Nine skills. Each is one run, one unit of work, one artifact, then stop. The
pipeline they run is `docs/decisions/decision-design-before-mint.md`:
design, audit, mint, spec, audit, implement, with revisit reaching any of them.

| skill | turns | writes |
|---|---|---|
| `goal-open` | an ambition the repo already states into one goal | `docs/goals/<name>.md` |
| `arc-open` | one goal condition into requirements and a roster | `docs/arcs/<name>-arc.md` |
| `element-design` | one roster row into a design, before any `E#` exists | `docs/arcs/parts/<arc>-<id>.md` |
| `pipeline-audit` | gates a design before it mints, and a SPEC before it is built | the artifact under audit |
| `design-to-spec` | one minted element into an implementation SPEC | `docs/elements/specs/E<NN>-<slug>-SPEC.md` |
| `revisit` | one settled artifact against one named trigger | the artifact, and a `records/` row |
| `doc-audit` | one doc, semantic pass against its live authorities | the doc under audit |
| `translate` | one published external object into this tree's forms | `docs/translations/<object>.md` |
| `research` | one question about the outside world, with its sources pinned | an `FD` row in `records/findings.md` |

| tool | is |
|---|---|
| `python3 tools/pack/pack.py E<#> …` | every pipeline bundle, and the scaffolder |
| `python3 tools/ledger-lint/ledger-lint.py` | the mechanical doc worklist, checks A to AN |
| `python3 tools/doc/doc.py audit <node>` | one doc's audit bundle |
| `python3 tools/lens/lens.py check \| author \| overview` | the four lenses, the author sweep, the generated orientation |
| `tools/xlat/xlat.sh` | pins an external source, resolves a translation's quotes into it, and lists what the tree quotes without a pin |
| `tools/test/run-tests.sh` | the gating floor. A green line is a named phase here |

This tree has its own discipline and does not run GSD. A global instruction that
routes work into `/gsd-*` stops at the door.
