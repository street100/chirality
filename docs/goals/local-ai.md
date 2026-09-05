---
node: goal-local-ai
layer: navigation
related: [goals/README, goals/self-tooling, goals/presentability, train-of-thought, records/author-calls, status-ledger, working-discipline, index]
status: current
updated: 2026-09-05
---

# Goal: full genuine local AI on small models

## The claim, and where the project makes it

This goal is an author call. The work that serves it has been in the tree since
2026-08-15 and the goal itself was first stated on 2026-09-01, verbatim:

> "if i can get full genuine local ai on small models that is a massive force
> multiplier for stuff after it. bare minimum is full orchestration, tui through
> scriba for full interaction, and a full framework for both entirely chirality
> ai and wrap to use python for (fine tuning, creating, full growing and
> changing set of interactions) transformer types and using ollama and llama.cpp
> for now"

On hardware, from the same author and earlier:

> "realistically we wouldnt be gunning specifically for gpu. A major goal is
> tiny models. If we have to start with fine tuning instead of ground up that is
> fine. A cpu should be enough imo (as a goal stance)"

Three places in the tree already carry pieces of the claim, which is why the
work exists before the goal did.

- `.planning/MANAS-STATE-VS-GOAL.md` §1 states the engine sentence: match a
  request to a process, gate which narrow agents fire, bind each to a model via
  a config profile, run the pipeline under a stop policy, and yield a typed
  result plus a run manifest, all in chirality, over local models, driven and
  observed inside scriba.
- `.planning/MANAS-SKILL-GROWER.md` states the sizing rule that the author's
  "small models" phrase names: decompose so hard that tiny models suffice. A
  step that needs a big model is under-decomposed, which makes it a defect.
- `docs/elements/catalog.md` rows E133 to E143 are the engine's element set.
  Eight of the eleven are implemented and dated.

## What done means

Four minimums, each one the author's own phrase, plus two conditions that
qualify all four.

**1. Full orchestration.** A gated multi-agent run executes end to end inside
this tree: match, gate, bind, fan out, combine, stop, and emit a typed
`RunManifest` that a golden oracle accepts. It runs under `bin/chirality-bin`
and the Linux syscall surface with no other language beneath it. Checkable by a
phase in `tools/test/run-tests.sh` that runs the pipeline and asserts the
conformance verdict.

**2. TUI through scriba for full interaction.** Every part of a run is authored,
composed, fired, watched and revised from `prog/scriba/`, with no step that
requires leaving the editor. Checkable by the S-series gates: author (S14),
compose (S16), run-view (S15), token streaming (S17).

**3. A full framework for entirely chirality AI.** The model of computation the
agents run under is chirality's own. Done means the `Flow` algebra is total and
type-checked over every case, its skills are enumerable data, and a new skill is
added by writing a value into the registry. Checkable by `flow-ty` covering
every `Flow` constructor and by a registry entry compiling into the binary.

**4. A wrap to use Python for fine tuning, creating, and a growing and changing
set of interactions over transformer types, using ollama and llama.cpp for
now.** Done means chirality holds a typed port for each of those verbs, the
external side is reachable and reaped under linear obligation, and swapping
ollama for llama.cpp changes a declared value. The shape of "external" is author
call A in [[records/author-calls]] and it decides whether this minimum and
[[goals/self-tooling]] conflict at all.

**5. Small models.** The run in criterion 1 uses models that fit the host, and
the decomposition rule is enforced rather than advised. Checkable when the
tiny-step contract has a lint that can fail.

**6. A CPU is enough.** The whole path above runs on a CPU. A GPU is an
accelerator this goal does not assume, and no criterion here is satisfied only
on one.

## State

Measured 2026-09-01 against this tree.

### Built

| what | evidence |
|---|---|
| The pure orchestration core | `prog/manas/core/{types,gate,bind,match,assemble,stop}.chiral`. Catalog E133, E134, E135, E136, all implemented 2026-08-15 |
| The multi-agent run loop | `prog/manas/pipeline/{plan,runner,guarded}.chiral`, catalog E138 |
| The run record crossing and profiles | `prog/manas/{contract/manifest,profile/profiles,profile/doc-refine}.chiral`, catalog E139 and E140 |
| Golden run-manifest conformance | `prog/manas/contract/{manifest,golden}.chiral`, catalog E141 |
| A linear `Backend` handle | `prog/manas/backend.chiral` `porttype Backend`, on the E144 string carrier with the E145 `be-peek` laundering peel, both built 2026-08-16 |
| The `Flow` algebra, recursive | `prog/manas/core/flow.chiral`, 1,373 lines. Seven constructors: `flow-step`, `flow-gate`, `flow-fan`, `flow-chain`, `flow-branch`, `flow-pure`, `flow-branch-pure`. Branch carries its own `backtrack` Flow, so consolidate-and-audit is paired into the type |
| A skill registry as data | `prog/manas/profile/skills.chiral` `SkillEntry`, over seven skill profiles under `prog/manas/profile/` |
| The chatter layer | `prog/manas/chatter/{router,turn,divide,egress,orchestrate}.chiral`, 2,057 lines |
| scriba, the editor | 26 modules and 6 roots under `prog/scriba/`. Two measurements dated 2026-08-21 disagree and both are recorded: `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` §0 gives 8,380 of 9,366 non-test lines live in the binary against the committed tree at `1cafe80`, and `.planning/SCRIBA-STATE.md` gives 8,738 of 9,724 against a working tree with a concurrent session's edits in it. Both put 986 lines written and inert |
| The scriba cockpit surfaces | `docs/examples/S14`, `S15`, `S16`, `S17` with SPECs under `docs/elements/specs/`. The six scriba roots compile under Phase 7 (`tools/test/run-tests.sh:166-168`) |
| The Ollama wire shape | `lib/protocol/http.chiral:600` reads Ollama's `message.content`, `:610` takes either the OpenAI delta or the Ollama field, and `:258` handles Ollama's chunked transfer with no content length |
| Typed external process spawn | E33, built native. `lib/runtime/proc.chiral` `proc-spawn` returns one `SpawnRes` with a linear `Reap`; `raw-proc-spawn` maps to `nb-run-cmd` and `wait` to `nb-wait` at `lib/lowering/tal/crossing-wraps.chiral:54-55`, with `spawn-in-pty` at `:49` |
| Writing a file | E105, `write-fd` to `nb-sys-write` at `lib/lowering/tal/crossing-wraps.chiral:36` |
| A total matcher over `Str` | E173 slice 1, `lib/text/matcher.chiral`, 602 lines, gated by Phase 19 |
| JSON both ways | `lib/protocol/json.chiral` |

### Owed

| what | measured state |
|---|---|
| A run that reaches a model server | Re-measured 2026-09-02 as `BA-42` in [[records/baseline-alignment]]: `http-request` and `chat-open` are chirality `def`s over the socket caps since E130 and E131, and `backend-open` erases rather than crossing, so the crossing-table gap this row used to name is closed. The run landed 2026-09-02: five roots under `prog/samples/` were compiled with `bin/chirality-bin` and executed on host `claude-sandbox`, each returning its header's success code, covering a non-streaming call, a streaming call and a hermetic refusal. That is the first native model call in this tree; the live runs recorded in `.planning/MANAS-STATE-VS-GOAL.md` are the CPython ones, taken through a transport that is cut. What is owed is a gate: Phase 7 of `tools/test/run-tests.sh` sweeps every root compile-only and no phase executes one. [[arcs/transport-arc]] holds it. UNASSIGNED |
| Buffer list and switching, `S19` | The `Scriba` state record that gates it is BUILT, 2026-08-23, `prog/scriba/editor-state.chiral`. This row read `S18` unbuilt until 2026-09-02 and that is `BA-43`. [[arcs/scriba-arc]] holds the S-series states |
| Fine tuning, model creation, the interaction set | `prog/manas/backend.chiral:17` records `train-start` and `train-status` as documented and unbuilt on the worker side. Nothing in this tree names them. Blocked on author call A. UNASSIGNED |
| Directory enumeration | E148 `getdents64` plus `stat`. Not built, zero occurrences under `lib/`, re-verified 2026-08-31 |
| The `.manifest` module kind | E163, minted and unbuilt. Two `.manifest` files sit on disk, `prog/climb.manifest` and `lib/lowering/tal/target-linux.manifest`, and `MAP.md` declares the kind. The loader check that makes it a kind is the owed half |
| Value back to source | E146, unbuilt. `S14`'s SPEC decision D7 defers config write-back to it, so authoring a config in scriba can read and cannot yet save |
| A tiny-step lint | `.planning/MANAS-SKILL-GROWER.md` L0 row 5. The rule is written and nothing can fail on it. UNASSIGNED |

## Arcs

Four. Three were opened 2026-09-02 from
`.planning/LOCAL-AI-ARC-REALIGNMENT.md`, which also records which existing arcs
supply pieces of this goal while serving their own, and re-points nothing. The
fourth was opened 2026-09-05 from `.planning/AI-LANE-GAP.md`, after the section
below had already ruled that criterion 3 needed no arc.

| arc | covers | state |
|---|---|---|
| [[arcs/transport-arc]] | criterion 1, a run that reaches a model server | T1 through T4 done 2026-09-02, and all four of the arc's own requirements hold. Phase 20 gates the transport path and criterion 1 stays unmet. Rows stay `unminted` on author call B |
| [[arcs/scriba-arc]] | criterion 2, full interaction from the editor | open and unblocked. `S#` is its own namespace |
| [[arcs/tuning-arc]] | criterion 4, fine tuning and the transformer verbs | opened blocked on author call A, with no row written |
| [[arcs/unit-lane-arc]] | criterion 3, the model of computation the agents run under, extended to a neuron population and a transformer instance | 42 rows over eight layers, band `E196-E239`. `E196` built 2026-09-05, closing rows `N8` and `N9`; 40 rows open |

Criterion 3 held no arc until 2026-09-05, on the reading that the framework is
largely built and naming a gap there would be a phantom feature: the `Flow`
algebra is recursive and total over seven constructors and the skill registry is
enumerable data. That reading stands for the deliberative layer and does not
reach below it. [[arcs/unit-lane-arc]] takes the criterion's own sentence, "the
model of computation the agents run under is chirality's own", down to the unit
the agents are made of, where a census over 37 rows on 2026-09-05 found nothing
built. The one L0 row that is genuinely absent is the tiny-step lint of
criterion 5, and it is a text tool in shape, which is [[arcs/text-tools-arc]].

## Honest limits

**The engine has never run in this tree. The transport under it has.** Nine
thousand nine hundred and thirty lines under `prog/manas/` compile and lower,
and Phase 7 of `tools/test/run-tests.sh` gates them on compiling. Phase 20,
`tools/test/transport.sh`, registered at `tools/test/run-tests.sh:324`, gates
`lib/protocol/http.chiral`'s transport path through five roots under
`prog/samples/`: each is compiled with `bin/chirality-bin`, refused if the
artifact is empty, run under a `timeout`, and judged against the exit code its
own header specifies. That phase leaves `prog/manas/` compile-only. Every "live
verified" line in `.planning/MANAS-STATE-VS-GOAL.md` was measured through the
CPython transport that the migration cut. Until 2026-09-02 this limit was
written as three externs missing from the crossing table, which E130 and E131
had already made false; `BA-42` in [[records/baseline-alignment]] holds the
re-measurement. Criterion 1 remains unmet. Phase 20 performs no pipeline run. It
emits no `RunManifest` and asserts no conformance verdict, which is what
criterion 1 asks a phase for. Two roots already carry that shape.
`prog/samples/manas-run-conform.prog` reads a frozen golden off disk, runs
`guarded-run` live against `100.64.0.5:11434`, and its header gives exit 0 iff
`manifest-conforms` accepts the actual `RunManifest` against that golden, 1 on
non-conformance and 90, 91 or 92 on an IO, parse or deserialize failure.
`prog/samples/manas-flow-conform.prog` is its twin through `run-flow` over
`pipeline->flow doc-refine-pipeline`, with the same exit contract. Both name
their golden at
`/workspace/chirality-the-lang/scaffold/tests/golden/manas-smoke-doc-refine.golden.json`,
a path absent from this tree, and no `*.golden.json` file exists anywhere under
it, measured 2026-09-02. Neither basename appears in `tools/test/run-tests.sh`
or in any `tools/test/*.sh`; Phase 7 sweeps both compile-only, as roots that
define `compile-main`. `prog/samples/agent-probe.prog` is a third, a full
`agent-run` tool-call turn against `qwen3:8b`, and it carries no assertion. No
arc holds that work.

⚑ **Phase 20 ran inside `tools/test/run-tests.sh` once, on 2026-09-02, on host
`claude-sandbox`.** The suite was run end to end and exited 0, `chirality test:
gate PASSED`. `MemAvailable` was 3,395,072 kB at launch and the suite completed
without an OOM kill. Phase 20 reported `transport: 5 passed, 0 failed, 0
deferred`; the endpoint answered and the streaming root printed `Hello! How may
I help you today?`. Its five assertions are counted in the suite total, which is
the part that proves the registration: `6 + 7 + 31 + 12 + 32 + 30 + 26 + 41 + 38
+ 19 + 61 + 18 + 5` sums to 326 with `5` as the transport term, and the run
reported `assertions: 326 passed, 0 failed`. So `run_phase`'s two-field `grep`
parses the tally line correctly despite its trailing `, 0 deferred`. The same
run reported `compile-only: 87 roots built, 0 failed`, so Phase 7 held. The
phase itself was measured standalone on 2026-09-02 on host `claude-sandbox`:
`bash tools/test/transport.sh` reported 5 passed, 0 failed, 0 deferred and
exited 0; with the probe host and port overridden to a closed port it reported
3 passed, 0 failed, 2 deferred and exited 0; with `CHIRALITY_COMPILE=/bin/true`
it reported 0 passed, 5 failed and exited 1, every root refused as an empty
artifact. That suite run happened once, on one box, on one day, with the
endpoint up. The memory risk recorded in `.planning/HANDOFF-DOC-SESSION.md` is
real and other sessions here were OOM-killed by it. Phase 20 is written to run
standalone for that reason, and that remains the reason.

**There is no float type.** `lib/protocol/json.chiral:4` states it and keeps
numbers as their raw lexeme for that reason. `F64` and `Float` are absent from
`lib/surface/` and `lib/typing/`, grep-clean 2026-09-01. E153, the `F64` tower,
is minted and unbuilt.

**There is no tensor form and no autodiff.** `tensor` and `Tensor` are
grep-clean across `lib/` and `prog/`. Nothing in the tree differentiates
anything. Criterion 4's "fine tuning" therefore has no in-language half today,
which is exactly why the author's phrase says wrap Python for it.

**A CPU is the stance and it is untested here.** The sandbox this tree is
developed in is CPU-only with no GPU, so criterion 6 has never been contradicted
and has also never been measured. No benchmark under `docs/benchmarks/` times a
model call.

**The Python conflict is unresolved.** [[goals/self-tooling]] states done as no
`.py` file anywhere under this repository, and criterion 4 wants Python for fine
tuning. Author call A in [[records/author-calls]] states the two readings and
picks neither. Until it is picked, the two goals are of unknown compatibility
and neither should be worked as though it had won.

**The work has no element numbers.** `docs/decisions/decision-lane-split.md`
reserves `E184-E189` and `E190-E195` and nothing else, so every owed row above
writes `UNASSIGNED`. Author call B asks for a block. The scriba half is the
exception: `S#` is namespaced by its own letter per `docs/elements/ledger.md`,
`S18` already has a SPEC, and `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` numbers
`S18` through `S30`.

**Two citations under this goal point at things that are gone.**
`.planning/METIS-PORT-SPEC.md` is cited five times as the contract for E133 to
E136 and is present nowhere in the tree, which is already an open row in
[[records/author-calls]]. `records/conformance-map.md:209-210` records the skill
registry and the chatter as built against `scaffold/lib/manas/` and
`TUI/scriba/` paths, and those directories do not exist here; the files live
under `prog/`.
