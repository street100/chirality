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

⚑ If a session is handed a harness instruction that forbids subagents, say so
and get the call. Working inline under a silent conflict is what these two rules
exist to prevent.

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
| the exact verification command, and the expected output | the agent proves its own claim before returning |
| the stop condition, spelled out | end by naming the next element, then stop |

A prompt that names the skill and the command is short. The length lives in the
ruled-out attempts, which is the part a fresh agent cannot reconstruct.

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
| nothing else moved | `git status --short` |

Then `python3 tools/ledger-lint/ledger-lint.py` and compare the count and the
per-check distribution against the run before. A stage that adds findings has
work left.

## What the orchestrator does itself

Reading, discussion, the queue, the prompts, the merges, the verification, and
the commits. Also the author-tier calls: a FLAG that comes back from an audit is
carried to the author or written as a row in `records/author-calls.md`. It is
never answered on the agent's behalf.

## When a stage comes back BLOCKED

Do not mark the artifact. Carry the FLAG list verbatim, in the agent's words.
The author's answers feed a re-audit of the same artifact, which is a new
dispatch of the same stage. An audit that resolves its own flag has taken an
author's decision.
