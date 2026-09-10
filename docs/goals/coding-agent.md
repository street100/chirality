---
node: goal-coding-agent
layer: navigation
related: [goals/README, goals/local-ai, goals/self-tooling, arcs/scriba-arc, arcs/unit-lane-arc, permission-model, records/author-calls, status-ledger, working-discipline, decisions/decision-work-ids, index]
status: current
updated: 2026-09-08
---

# Goal: chirality's own coding agent, acting on a codebase

## The claim, and where the project makes it

This goal is an author call rather than a derivation, the fifth after
[[goals/presentability]], [[goals/readable-surface]], [[goals/local-ai]] and
[[goals/display]]. Stated by the author 2026-09-08, verbatim:

> "The goal is to make this chirality's own coding agent, roughly what a mix of
> pi and nanocoder would be, built native on chirality with scriba as the TUI. I
> want depth on ROUTES, ORCHESTRATION, KEYBINDS and FEATURES, and orchestration
> is the part I care most about."

`pi` (github.com/badlogic/pi-mono, now earendil-works/pi) and `nanocoder`
(github.com/Nano-Collective/nanocoder) are named for their shape. Both are
external reference harnesses. Neither is a dependency and nothing in this tree
imports either.

Four places already carry pieces of the claim, which is why the work exists
before the goal did.

- `prog/shilpa/turn.chiral:1` names itself "the Pi-minimal tool-call loop", and
  its 452 lines drive an OpenAI-compatible endpoint over `http-request` (E130)
  and `lib/protocol/json.chiral`, parse the model's `tool_call`, dispatch it,
  append the result, and loop until the model answers. The agent's turn is
  already native.
- `prog/shilpa/tools-fs.chiral` defines `fs-read` at `:50`, `fs-write` at `:62`
  and `fs-edit` at `:88` in 96 lines, and `prog/shilpa/turn.chiral:60` declares
  `ag-bash` over the `raw-proc-spawn`/`wait` crossings. Four tools, native, no
  interpreter under any of them.
- `prog/prapanca/core/types.chiral:63-68` declares the permission half already:
  "TOOLS is least-privilege (a list of permitted tool names, default read-only =
  nil)", carried as the `Expert` record's `tools` field. What a step may touch is
  a declared value in this tree.
- `prog/prapanca/core/match.chiral:5-6` states the routing stance this goal
  inherits: "No float: the score is an integer overlap count, never a cosine",
  with the membrane proving no model call can steer which pipeline runs.

### Why this is not [[goals/local-ai]]

[[goals/local-ai]] claims an **orchestration engine and a cockpit to drive it**.
Its four criteria are a gated multi-agent run that emits a `RunManifest`, full
interaction from `prog/scriba/`, a chirality-native model of computation under
the agents, and a Python wrap for tuning. None of them names a codebase.

This goal claims **the thing that acts on one**: tool use inside the type
system, filesystem reach, least-privilege over what a step may touch, and the
routes and keybinds that make it usable at a keyboard.

The tree already cuts them apart in code, which is the evidence this is two
goals rather than one. `prog/shilpa/turn.chiral` runs a tool-call turn today and
uses **none** of the engine — no `be-chat`, no `Flow`, no `RunManifest`, no
gate, no `StopPolicy`, no linear `Backend` — and its own header states the
choice at `:12-16`: "backend.chiral's be-chat is the non-tool reference and is
NOT used here". In the other direction, no file under `prog/prapanca/` executes a
tool: `prog/prapanca/core/types.chiral`'s `tools` field is read at zero sites,
measured 2026-09-08. Two working halves, neither reaching the other, is where
the source itself is cut.

Where they touch, this goal defers rather than restates. `local-ai` criterion 2
owns the scriba cockpit surfaces (`S14` through `S17`) and criterion 1 owns the
engine's own conformance verdict. Nothing below claims either.

## The shape condition

Stated by the author in the same breath, and it governs every arc under this
goal: **no route, rank or selection may assume a float.**

> "No float type in chirality. lib/protocol/json.chiral keeps numbers as raw
> lexemes. Any routing scheme that needs a score has to answer for that."

The tree has answered it once and that answer is the pattern:
`prog/prapanca/core/match.chiral:5-6` routes by an integer keyword-overlap count
and says in its own header why it is not a cosine. Three consequences, each
checkable:

1. **`F64` and `Float` stay grep-clean under `lib/surface/` and
   `lib/typing/`.** They are, verified 2026-09-08. E153, the `F64` tower, is
   minted and unbuilt (`docs/elements/catalog.md:479`); work under this goal
   that reaches for it has changed the language rather than answered the
   constraint.
2. **Every score is an integer and its module header states the arithmetic.**
   `match.chiral`'s header is the form. A score with no stated arithmetic is a
   float waiting to be found.
3. **A tie is a value, not a first-wins.** `PipelineMatch` is a closed sum over
   found / none / tied (`prog/prapanca/core/match.chiral:6-8`), and any selection
   added under this goal closes the same way.

The author's other constraint stated in the same breath — "Small models, and a
CPU is the stance. Decompose so hard tiny models suffice" — is **not** restated
as a condition here. It is [[goals/local-ai]] criteria 5 and 6, which are
standing constraints over that goal's every condition rather than work of their
own. A second statement of a rule drifts from the first.

## What done means

Four conditions, one per area the author named. None holds an arc file.

1. **Orchestration.** The area the author named as the one they care most about.
   A coding turn is decomposed across the engine rather than run as one loop, and
   each step holds only the tools it was granted. Three counts are zero today and
   each is the observation: `prog/shilpa/turn.chiral` imports nothing under
   `prog/prapanca/` and says so at `:12-16`; the `Expert` record's `tools` field is
   bound at seven destructuring sites across four files
   (`prog/prapanca/core/assemble.chiral:51`, `prog/prapanca/core/flow.chiral:1336` and
   `:1338`, `prog/prapanca/pipeline/plan.chiral:46` and `:47`,
   `prog/prapanca/profile/doc-refine.chiral:17` and `:19`) and read at none of them;
   and `prog/prapanca/core/stop.chiral`'s `overflow-guard` (`:20`) and `stop-policy`
   (`:25`) have no caller outside their own file, so a coding turn that outgrows
   the context window has no guard on it. Done when the first two counts are
   nonzero and a coding turn emits a `RunManifest`. **[[arcs/coding-turn-arc]]**,
   opened 2026-09-08.

2. **Routes.** A coding request reaches the right step, the right tool grant and
   the right model, and the choice is a value that can be shown. Observable in
   two places: `prog/prapanca/core/match.chiral` routes by integer overlap against a
   pipeline's WHEN text and no pipeline in `prog/prapanca/profile/` names a file
   operation, so a coding request has nothing to route to; and the `Pipeline`
   record's `stop` field is never read on the flat run path —
   `prog/prapanca/pipeline/plan.chiral:49-50` define only `pipe-gate` and
   `pipe-combiner`, and both bind `stp` and discard it. Done when a coding request
   routes to a coding pipeline under the shape condition above, and the `stop`
   field is read where the run decides to continue. **Unopened, and it holds no
   arc file.**

3. **Features.** The agent reaches a codebase rather than a path it was handed.
   Two counts are zero today: E148, `getdents64` plus `stat`, is minted and
   unbuilt with zero `getdents` occurrences under `lib/` (re-verified
   2026-09-08), so there is no directory enumeration and therefore no glob, no
   repomap and no file explorer; and `lib/text/matcher.chiral`, 602 lines gated
   by suite Phase 19, is imported by exactly one program under `prog/`, the
   prose linter at `prog/prose-lint.prog:43`, and by no tool the agent holds.
   Done when E148 is built and a search over a directory tree runs from a tool
   the agent holds.
   E148 and E149 are minted at `docs/elements/catalog.md:463-464`, so this
   condition defers only to elements that exist. **Unopened, and it holds no arc
   file.**

4. **Keybinds.** A coding turn is fired, watched, interrupted and revised from
   scriba's own entry namespace, and that namespace overlaps no layer outside it.
   Observable in the dispatch that already exists:
   `prog/scriba/command-loop.chiral:1839` tries `normal-keymap` first and `:1846`
   falls back to the buffer's configured keymap `(sc-km s)`, whose
   Emacs-compatible initial value is `default-keymap` at
   `prog/scriba/keymap.chiral:100`, loaded through `init-load` in
   `prog/scriba/scriba-main.prog`; the initial `Scriba` is constructed in
   `vm-normal` at `prog/scriba/command-loop.chiral:278`. The `:` line at
   `prog/scriba/command-loop.chiral:1813` carries 21 ex commands, of which
   `:chat`, `:ask`, `:manas`, `:run`, `:compose`, `:flow` and `:load` reach the AI
   half and **none** reaches `prog/shilpa/`. Done when `agent-run` is reachable
   from a binding rather than only from a `.prog` root, and the entry key it takes
   collides with no outer layer. **Unopened, and it holds no arc file.**

## Arcs

| arc | covers | state |
|---|---|---|
| [[arcs/coding-turn-arc]] | condition 1, decomposition | opened 2026-09-08, rescoped 2026-09-09, 13 rows |
| [[arcs/tool-authority-arc]] | condition 1, the grant | opened 2026-09-09, 12 rows |

Conditions 2, 3 and 4 hold no arc file. That is not the standing-gate shape
[[goals/self-hosting]] carries: no rule maintains them on every change, and the
absence is scheduling owed rather than a finished shape. It is the first honest
limit below.

This section carries no element rows and no roster.

## State

Stated 2026-09-08. One half is built and the other is absent.

Built, and measured in this tree on 2026-09-08:

| what | evidence |
|---|---|
| A native tool-call loop | `prog/shilpa/turn.chiral`, 452 lines, over `http-request` and `lib/protocol/json.chiral`, carrying four tool schemas at `:99-147` |
| Four native tools | `fs-read`, `fs-write`, `fs-edit` in `prog/shilpa/tools-fs.chiral` (96 lines), and `ag-bash` at `prog/shilpa/turn.chiral:60` over `raw-proc-spawn`/`wait` |
| One real turn, run | `prog/samples/shilpa-probe.prog` drives `agent-run` against `qwen3:8b` at `100.64.0.5:11434`, one tool-call turn, all chirality |
| A float-free routing precedent | `prog/prapanca/core/match.chiral`, integer overlap count, closed `PipelineMatch` sum |
| A declared least-privilege grant | `prog/prapanca/core/types.chiral:63-68`, and `prog/prapanca/profile/code-test.chiral:50` granting `(cons "read" nil)` |
| The editor the agent is to be driven from | `prog/scriba/`, 26 modules and 6 roots, compiled under suite Phase 7. [[goals/local-ai]] holds its state, which is the authority for it |

Absent, and each count is the observation in the condition it belongs to: no
import from `prog/shilpa/` into `prog/prapanca/` or back; no read of the `tools`
field; no caller of `overflow-guard` or `stop-policy`; no read of `Pipeline`'s
`stop` on the flat path; no directory enumeration; no consumer of
`lib/text/matcher.chiral` other than the prose linter; no keybind reaching
`prog/shilpa/`.

[[status-ledger]] is the authority for what is built on the four rungs and
[[records/README]] for a claim beside its measurement.

## Honest limits

**Three of the four conditions schedule nothing.** [[arcs/coding-turn-arc]]
opened 2026-09-08 against condition 1's decomposition half and carries 13
rows after the 2026-09-09 rescope; [[arcs/tool-authority-arc]] carries the
grant half in 12.
Conditions 2, 3 and 4 hold no arc file, so routes, features and keybinds are
stated here and booked nowhere.

**No gate can fail on the agent.** `prog/samples/shilpa-probe.prog` drives a full
`agent-run` tool-call turn and its `compile-main` ends in `0` unconditionally:
it prints `AGENT-ANSWER:` and the model's text, then returns success whatever
came back. No `prog/shilpa/` or `prog/prapanca/` path appears in any
`tools/test/*.sh`, verified 2026-09-08, so suite Phase 7 sweeps both
compile-only. There is no assertion in this tree that a coding turn can fail.
No roster row holds that work.

**Least-privilege tool grants are declared and inert.**
`prog/prapanca/core/types.chiral:64-65` calls `tools` least-privilege and
`prog/prapanca/profile/code-test.chiral:39-40` says of its own grant "TOOLS is
least-privilege (read only — producing a proposed test never writes; running it
is a later effect)", granting `(cons "read" nil)` at `:50`. The field is bound at
seven destructuring sites and read at zero. The tree's own
[[permission-model]] agrees at a higher altitude: of four grant operations only
Move is enforced, and Delegate, Revoke and the broker's grant/revoke/audit
(E43) are design. A grant nothing reads permits everything.

**The context-window guard is written and unreached.**
`prog/prapanca/core/stop.chiral` states in its header that `overflow-guard` answers
"does the assembled prompt fit num_ctx" on an integer chars/4 estimate, and
`overflow-guard` (`:20`) and `stop-policy` (`:25`) have no caller outside that
file. A coding agent reads files into its context, so this is the guard the
whole goal most needs and it fires nowhere.

**The agent cannot see a directory.** E148 is minted and unbuilt, zero
`getdents` occurrences under `lib/`. Every enumeration site in this tree is a
hand-maintained manifest or index file (`docs/elements/catalog.md:463`). Both
reference harnesses the author named are built on file discovery, so this is the
single count that puts their baseline out of reach.

**The matcher is built and reaches no tool.** `lib/text/matcher.chiral` is 602
lines, gated by suite Phase 19. Its one consumer under `prog/` is the prose
linter (`prog/prose-lint.prog:43`), so the engine is proven in use and reaches
nothing the agent holds. The search half of condition 3 is a wiring gap rather
than a build gap.

⚑ **This row read "used by nothing" until 2026-09-09**, which was false when
written. The claim entered from a dispatch brief and was propagated rather than
measured. `decision-tool-capability` caught it.

**The keybind namespace rests on a document outside this repository, and that
document does not name scriba.** The author stated the discipline as "each layer
owns one entry namespace, namespaces never overlap. scriba is the innermost
layer", citing `/workspace/MUDRA-KEYBINDS-HANDOFF.md`. That path is outside this
tree, so it is not a citable authority here, and its own entry-namespace table
names the innermost layer "editor (emacs Evil / nvim)" and never mentions
scriba. The author's words are recorded above as the author's. Where scriba
sits in that stack, and which entry key it owns, is an author call.

**The work has no element numbers, and that blocks nothing.** No band is
reserved for this goal in `docs/decisions/decision-lane-split.md`. Author call B
was ruled 2026-09-06, "let overlap exist": a band is advisory and an arc without
one mints the next number free tree-wide. Rows take arc-local ids per
[[decisions/decision-work-ids]] when an arc opens. Author call A was ruled the
same day, "outside. There is no Python in the language", so nothing under this
goal proposes any.
