---
node: records-coding-turn
layer: navigation
related: [records/README, status-ledger, arcs/coding-turn-arc, arcs/tool-authority-arc, goals/coding-agent, decisions/decision-part-layout, decisions/decision-orchestration-boundary, decisions/decision-tool-capability, index]
status: current
updated: 2026-09-09
---

# Coding turn arc

Every row is a claim this repo makes about the coding turn, beside what was
actually observed.

Row format, states and the rules for adding, changing and retiring a row are in
[[records/README]]. Prefix is `CT`.

The arc's roster lives in [[arcs/coding-turn-arc]], opened 2026-09-08 on
[[goals/coding-agent]] condition 1. Its reserved element block is **none**, so
its rows carry arc-local ids `A1` upward per
`docs/decisions/decision-work-ids.md`.

## What the arc claimed, and what holds

### CT-01 the arc placed its rows against a part layout that was ruled the next day

- state:    FIXED
- claim:    [[arcs/coding-turn-arc]], opened 2026-09-08, put every G1 row inside `prog/shilpa/`, gave G3 a `Flow` node that fires a tool and G4 a tool call recorded in `RunManifest`, listed `ag-bash` as one of `coding-turn/A2`'s four tools, cited `prog/shilpa/turn.chiral`'s E100 seam passage as `:12-16` at two sites, and carried ten rows with none for the wire protocol, the duplicated transport or the `bash` deletion.
- measured: Three decisions landed 2026-09-09 and the arc RESCOPES; the arc file is amended in place and the roster now carries thirteen rows. `decision-part-layout` §3 names `prog/indriya/` the tool layer and names `coding-turn/A1` as the row its vocabulary comes from, so `A1`, `A2` and `A10` retarget out of `prog/shilpa/`; `ls prog/` returns no `indriya`, so their first commit creates it. `decision-orchestration-boundary` §4 forbids `prog/prapanca/` naming a consumer, so `A5` rescopes to a leaf whose crossing is an id, on the `flow-step` precedent at `prog/prapanca/core/flow.chiral:141` which names an expert by `(expert-id Str)` and holds no `Expert`; `A6` to one port-result `Ty` with the per-crossing assignment outside; and `A7` to a carrier threaded beside the manifest on the `RawCall` precedent (`prog/prapanca/core/types.chiral:152`), because `RunManifest` (`:166`) is pinned field-for-field to the golden's 15 top-level keys (`:154-160`) and `E141` (`docs/elements/catalog.md:247`) is the conformance that reads it back. `decision-part-layout` §5 ruled `bash` out of the goal toolset, which drops `A2` to three tools and breaks `A9`'s root, `prog/samples/shilpa-probe.prog:3-6` stating a prompt whose whole job is to force a bash tool_call. Three rows were added, one per §5 statement: `A11` the wire protocol to `prog/indriya/`, `A12` the duplicated transport deleted, `A13` `ag-bash` deleted. `A8` holds unchanged, its call direction being consumer to prapañca. `A3` and `A4` survive rather than dying: a model reads a set and cannot case a capability, so the render outlives whatever carrier `tool-authority/TA10` picks; and `A4` survives as in-process accounting that states itself as accounting, because `decision-tool-capability` §5 measures that a module reaches naming authority by writing one `extern` line. The three overlaps `tool-authority-arc` left to this revisit are resolved: `A4` beside `TA10`, `A3` beside `TA10`, and `A2` against `TA8` dissolved by the `bash` ruling, which also makes `TA8`'s "the supplied descriptor set is decorative" false. The `:12-16` citations were repointed to `:11-15` at `docs/arcs/coding-turn-arc.md:29` and `:82`, the repoint `decision-part-layout` §5 assigns to this arc. **One blocker stands and this run did not touch it**: `docs/arcs/parts/coding-turn-A1.md:241` places the tool value in `prog/shilpa/tool.chiral` and argues it by `coding-turn/A5` needing `Tool` visible from `prog/prapanca/core/flow.chiral`, which is the import direction §4 forbids from either home and which the rescoped `A5` no longer asks for, and its §6 catalog row spells a `t-bash` arm. That design is owed its own `revisit` before `pipeline-audit`.
- evidence: `docs/decisions/decision-part-layout.md` §3, §5, §6; `docs/decisions/decision-orchestration-boundary.md` §4; `docs/decisions/decision-tool-capability.md` §3, §5; `docs/arcs/parts/coding-turn-A1.md:241`; `docs/arcs/tool-authority-arc.md:200`, `:247-262`; `prog/shilpa/turn.chiral:11-15`, `:17-20`, `:23-47`, `:60`, `:145-146`, `:167`, `:201`, `:241`, `:351-359`, `:371-374`; `prog/prapanca/backend.chiral:79-86`, `:85`, `:116`; `prog/prapanca/core/flow.chiral:141`, `:212`; `prog/prapanca/core/types.chiral:152`, `:154-160`, `:166`; `prog/samples/shilpa-probe.prog:3-6`, `:9`, `:15`; commits `0aa1800`, `6ceb8c6`, `8c9a56e`, `da71912`
- checked:  2026-09-09
- element:  `coding-turn/A1`, whose design stage re-runs. The other twelve rows are `unminted` and unblocked
