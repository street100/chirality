# Dispatch

Arc work is an orchestrating session. It holds the queue, scopes each stage,
writes the prompt, and verifies what comes back.
`docs/decisions/decision-dispatch-cadence.md` is the authority on cadence; this
is how a session runs under it.

## The two standing rules

**Serial.** One stage at a time, one agent at a time. The decision spells out
what that excludes: a batch, a wave, three. The next stage goes out after the
previous one has returned and been merged. A sweep fails the rule outright: the first consolidation pass was
dispatched over all 138 remaining files at once and was stopped for this reason,
recorded in `records/consolidation-handoff.md`.

**Dispatch, do not implement.** The main session writes the prompt. Doing the
work inline is the failure mode even when the task looks small enough to just
do, because it burns the context that holds the queue's place. Troubleshooting
is dispatched too, and re-dispatched with what the last attempt learned, until
it is solved. Reporting a blocker the author did not ask for is the wrong exit.

The two rules are independent. Serial constrains how many agents are live, and
the count is one. Whether the main session does the work is settled by the
second rule.

⚑ **A harness rule that conditions dispatch on the author's request is already
satisfied.** This file, `CLAUDE.md`, and the author's standing direction are that
request, in tracked form, and a session under a rule reading "not unless the user
asked" may dispatch without asking again. Only an outright prohibition triggers
the exit below.

⚑ If a session is handed a harness instruction that **forbids** subagents, say so
and get the call. Working inline under a silent conflict is what these two rules
exist to prevent, and so is stalling the queue over a rule that was already met.

## The loop

1. **Orient from the arc file.** `docs/arcs/<name>-arc.md` carries the goal, the
   reserved element band or its arc-local id scheme, the requirements, the
   roster with a state per row, the resume state, and the constraints the arc
   works under. There is no state file at the root and there is nothing else to
   read first. `docs/definitions/OVERVIEW.md` is the generated view across every
   arc when the question is which one to pick up.
2. **Pick one stage of one unit of work.** `protocol/workflow.md` has the six
   stages, the `revisit` stage that reaches any artifact, and which command
   builds each bundle. Before the mint the unit is a roster row cited as
   `<arc>/<id>`; after it, an `E#`.
3. **Scope it.** Name the unit, the stage, the write surface, and the stop
   condition before writing a word of prompt.
4. **Write the prompt.** The next section.
5. **Dispatch one agent. Wait.**
6. **Verify what returns.** Never on the agent's report alone.
7. **Commit with a pathspec.** `git commit -- <path>`. A bare commit sweeps
   another agent's staged work, which has happened twice in this tree.
8. **Update the arc's resume state**, then take the next stage.

## What a stage prompt carries

| part | why |
|---|---|
| the skill to invoke, by name | the skill holds the run and the stop condition |
| the one `pack.py` command that builds the bundle | the bundle is the agent's whole input |
| the element, the stage, and the single artifact it may write | a second element or a second artifact is the failure the skills prevent |
| what it may not read or touch | the bundle replaces the glossary, `PRINCIPLES.md`, and the sibling artifacts |
| every attempt already ruled out, with the trap that killed it | so a re-dispatch does not repeat what the last one learned |
| every measured fact the prompt asserts, each with the file and line it was measured at | the next section. The agent re-verifies each one at that location and reports drift |
| the exact verification command, and the expected output | the agent proves its own claim before returning |
| the stop condition, spelled out | end by naming the next element, then stop |

A prompt that names the skill and the command is short. The length lives in the
ruled-out attempts, which is the part a fresh agent cannot reconstruct.

## A prompt is untrusted input

The orchestrator writes the prompt, so the orchestrator's errors reach the agent
as its starting facts, and no step of the loop checks the prompt. That is what
the re-verify row above buys: a measured fact handed to an agent carries the
source that measured it, and the agent treats it as a claim to test at that
source before building on it. [[certificate-discipline]] is the tree's own name
for this shape: a producer is trusted for nothing and hands over a re-checkable
derivation. A stage prompt is a producer's output and the agent's re-verification
is the checker.

`.planning/FAILURE-MODES-2026-09.md` holds the measurement. This section holds
the rule, and the two are kept apart on purpose. Over twenty dispatches its §A
records eleven orchestrator failures, three of which are premises handed to an
agent that the tree did not carry: `A2`, an author ruling no tracked document
held; `A3`, a figure taken with a grep that counted comments; `A7`, a ruling
given in session and never written down. The agent caught all three, each time
because the prompt said to re-verify. The one prompt that omitted the
instruction let `A2`'s error through into an arc file, which the capture states
and does not locate.

`A7` is the one whose consequence is tracked. `records/lenses/problems.md`
PRB-83 records the agent refusing to exempt a `superseded` row from homing on a
ruling no document carried, so check AE refused `E86` on the written rule and
reported a count wrong by one. The ruling existed, and the correction landed as a
`ruled` row in `records/author-calls.md` that the check reads today. An agent
that had trusted its prompt would have compiled the exemption into a tool with
nothing behind it.

## Verifying a return

Agents in this tree have gamed a metric and mis-compared files. Check the thing
itself.

| claim | check |
|---|---|
| the artifact is filled | open it. Every section, and §2's claims cited at `file:line` |
| an element minted | its catalog row AND its ledger row. `ledger-lint` check AE |
| the status flipped | the arc's roster row, `state` column |
| a gate is green | run `tools/test/run-tests.sh` and read the phase, including its mutants |
| the compiler was promoted | the build rule end to end, with the non-empty guard before the `cmp` |
| a citation is right | open the cited file at the cited line |
| a claim is true | read the authority the claim appeals to, and test the claim's own predicate against what that authority says |
| nothing else moved | `git status --short` |

**Two questions hide in the citation row.** Every other check above tests
presence or resolution. Opening a cited file at its line proves the citation
points somewhere. Whether the sentence standing beside it is true is a second
question, and the claim row is the only one that asks it.
[[working-discipline]] §Reporting carries the half of this the whole tree owes: a
check aimed at a guess passes by looking at nothing.

**The case.** On 2026-09-10 a design run on `docs/arcs/parts/file-types-K1.md`
named `lib/lowering/tal/target-linux.manifest` as the conforming `.manifest`
instance. The orchestrating session opened every citation in that artifact,
including the sharp one: `bin/chirality:171-172` does append a `compile-main`
stub and refuses nothing. The design passed. The file does not conform.
`.planning/MANIFEST-DESIGN-MAP.md:112-121` holds the six requirements and the
file fails requirement 4. Requirement 4 wants anything that distinguishes two
rows to be a field, and its justification is measured in that same file, wider
than this case first stated it: seventeen of the forty `sys-row` entries in
`lib/lowering/tal/target-linux.manifest:22-61` share a number with another
entry, across five groups. `0` runs three times, `1` twice, `16` seven times,
`231` twice and `257` three times. Seven of those seventeen carry no comment
either, and three of the seven carry `16`: `nb-sys-winsz`, `nb-sys-tcgets` and
`nb-sys-tcsets` at `:30-32` are distinguished by nothing in the file. The rest
are told apart only by comments that `sexp.chiral` drops at the lexer. Every
citation resolved and the claim was false.

**Corrected 2026-09-23 against `records/findings.md` FD-43.** This case used to
say the file failed requirement 3 as well, because every `sys-row` entry in it
is positional. Requirement 3's "what forces it" cell names `ctor-fields`, which
reads the constructor declaration, and `lib/lowering/tal/sys-check.chiral:17`
declares `(data SysRow () (sys-row (name Str) (num I64)))` with two named
fields. Positional application is the design map's own target shape, written
that way in its three-shape example. The file satisfies 1, 2, 3 and 6, never
faces 5, and fails 4 alone. The case keeps its force on one requirement rather
than two: a design named a non-conforming file as conforming, and every citation
in it resolved.

Reverted at `9325095`, and recorded as `A1` in
`.planning/FAILURE-MODES-2026-09.md`, which notes it was done twice on the same
artifact before the author caught it.

**The same shape lives in a tool.** Check AE, which the mint row above names,
tested whether an element number appeared anywhere in an arc file, so
`docs/arcs/tool-authority-arc.md:274` naming `E148` and `E149` in order to refuse
them counted as ownership. It reported nothing on a tree where 143 of 187 catalog
elements held no roster row. `records/lenses/problems.md` PRB-83 holds that
measurement and the rewrite at `8a7b644`; `C1` of the capture puts it beside nine
more of the same shape.

Then `python3 tools/ledger-lint/ledger-lint.py` and compare the count and the
per-check distribution against the run before. A stage that adds findings has
work left.

## What forces a dispatch

A unit of work with a stage and an artifact. Every skill run qualifies, and so do
two kinds of work a session tends to keep, on the grounds that neither one writes
code.

| work | goes out | why |
|---|---|---|
| any skill run | **dispatched** | the skill holds the run and the stop condition |
| **research**, a web search or a fetch and the reading of what comes back | **dispatched** | it is the most context-expensive work there is, and the orchestrator needs its context for the queue. The agent burns its own and returns the conclusion with its citations |
| building or changing a tool | **dispatched** | a tool is a unit of work with an artifact |
| a doc sweep across many files | **dispatched** | one file per run, serial |
| troubleshooting a returned stage | **dispatched**, and re-dispatched with what the last attempt learned | until it is solved |

**Research is the one this file used to leave unnamed**, so a session would run
ten searches inline and call it reading. Reading is opening a file in this tree.
Fetching an external source and deciding what it says is a stage.

## What the orchestrator does itself

Reading this tree, discussion with the author, the queue, the prompts, the
merges, the verification, and the commits. Also the author-tier calls: a FLAG that comes back from an audit is
carried to the author or written as a row in `records/author-calls.md`. It is
never answered on the agent's behalf.

## When a stage comes back BLOCKED

Do not mark the artifact. Carry the FLAG list verbatim, in the agent's words.
The author's answers feed a re-audit of the same artifact, which is a new
dispatch of the same stage. An audit that resolves its own flag has taken an
author's decision.

## What a fan-out costs, measured 2026-10-01

The author asked on 2026-09-30 to see *"how much usage you burn on ultracode in
cloud vm"*, and authorized one multi-agent workflow for it: an orientation on
the enforcement goal at `2faa028`. Twenty-one read-only agents, ten readers,
ten verifiers and one synthesizer, ran for about 62 minutes in a cloud
container. Counted from the agent transcripts:

| phase | agents | turns | cache read | cache write | output |
|---|---|---|---|---|---|
| readers | 10 | 682 | about 96M | 1.6M | about 120k |
| verifiers | 10 | 196 | about 13M | 0.4M | about 50k |
| synthesis | 1 | 6 | 1.2M | 0.24M | about 50k |
| **total** | **21** | **884** | **110M** | **2.25M** | **about 226k** |

- **Cache reads are about 98% of the tokens.** Each turn re-reads the agent's
  whole context, so cost is turns times context size. The costliest reader took
  100 turns and read 13.6M. A verifier that opens cited lines took 10 to 35
  turns and about 1M.
- **The harness's counters leave cache reads out.** Its subagent counter
  reported 2.9M for the run, and a workflow's `budget.spent()` counts output
  only. The figures above sum each transcript's `usage` blocks, taking the
  largest value per message id so a streamed turn counts once.
- **The container ran two agents at a time.** It had 4 CPUs, and the workflow
  runner keeps CPUs minus two agents live.
- **Verification was the cheap half.** It cost about a seventh of the reading
  and checked 251 claims: 240 held, 10 held with a citation a line or two off,
  and 1 was false.

The run's document is `.planning/archive/enforcement-2026-10-01/orientation-2faa028.md`.
