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
| build state on the four rungs | `docs/definitions/status-ledger.md` |
| goals, arcs, elements | `docs/goals/`, `docs/arcs/`, `docs/elements/` |
| a claim beside its measurement | `records/` |
| decisions only the author can make | `records/author-calls.md` |
| where a session resumes | the arc file in `docs/arcs/`. There is no root state file |

## The harness

Four skills. Each is one run, one element or one doc, one artifact, then stop.

| skill | turns | writes |
|---|---|---|
| `worked-example` | a catalog element into a worked example | `docs/examples/E<NN>-<slug>.md` |
| `pipeline-audit` | gates an example before speccing and a SPEC before implementing | the artifact under audit |
| `example-to-spec` | a worked example into an implementation SPEC | `docs/elements/specs/E<NN>-<slug>-SPEC.md` |
| `doc-audit` | one doc, semantic pass against its live authorities | the doc under audit |

| tool | is |
|---|---|
| `python3 tools/pack/pack.py E<#> …` | every pipeline bundle, and the scaffolder |
| `python3 tools/ledger-lint/ledger-lint.py` | the mechanical doc worklist, checks A to S |
| `python3 tools/doc/doc.py audit <node>` | one doc's audit bundle |
| `tools/test/run-tests.sh` | the gating floor. A green line is a named phase here |

GSD is not used in this tree. A global instruction that routes work into `/gsd-*`
does not apply here.
