---
node: decision-part-layout
layer: decision
status: DECIDED
decided: 2026-09-09
related: [decisions/decision-orchestration-boundary, decisions/decision-tool-capability, decisions/decision-syscall-governance, decisions/decision-work-ids, decisions/decision-lane-split, decisions/decision-scope, arcs/tool-authority-arc, arcs/coding-turn-arc, arcs/zero-python-arc, goals/coding-agent, goals/self-tooling, elements/catalog, records/author-calls, working-discipline, index]
updated: 2026-09-09
---

# Decision: five parts under `prog/`, named and placed

**Decided 2026-09-09.** Read this before adding a directory under `prog/`, and
before writing a tool.

[[decisions/decision-orchestration-boundary]] ruled that `prog/prapanca/` holds
the orchestration interface and that a consumer is its own prog.
[[decisions/decision-tool-capability]] ruled that a tool falls outside the
language-level crossing test and that naming authority is the one thing every
tool is represented through. Neither names the parts. Neither places the tool
layer. This document closes both gaps.

## The decision

### 1. Five parts

All five names are the author's, ruled 2026-09-09. The naming rule is the one
`prapanca` set: a name is chosen when it is conceptually exact. Decoration is
no reason to pick one.

| prog | the name means | is | holds |
|---|---|---|---|
| `prog/prapanca/` | the mind's proliferation into multiplicity | the orchestration interface | the Flow algebra, the plan spine, the run loop, the `RunManifest` and its conformance oracle, and the shapes `Expert`, `Config`, `Binding`, `Pipeline` and `Skill` |
| `prog/indriya/` | the faculties. The *karmendriyas* are the action faculties, the organs through which a mind reaches the world | the tool layer. **New, and empty today** | the tool vocabulary as a value, the declared schemas, the wire protocol that puts `tools` in a request and reads `tool_calls` back, and the tool implementations |
| `prog/shilpa/` | craft, skilled making. A *śilpin* is the artisan | the coding agent. **Renamed from `prog/agent/`** | its agents, its model bindings, its tool grants and its configuration. It consumes prapañca and indriya |
| `prog/samvada/` | dialogue, discourse between two | the conversational assistant. **Renamed from `prog/prapanca/chatter/`, and moved out of prapañca** | the intent router, the divider, turn execution, egress, and the skill profiles as its config |
| `prog/scriba/` | scribe, Latin | the TUI | unchanged |

Three of the five carry a different name today, and one has no directory at
all. Current paths are current until a migration moves them.

| target | today, measured 2026-09-09 |
|---|---|
| `prog/prapanca/` | `prog/prapanca/`, since `b6065d1` on 2026-09-08 |
| `prog/indriya/` | absent. Nothing in the tree occupies the layer |
| `prog/shilpa/` | `prog/agent/` |
| `prog/samvada/` | `prog/prapanca/chatter/` plus `prog/prapanca/profile/` |
| `prog/scriba/` | `prog/scriba/` |

The four new words are free tree-wide. A grep over the repository for
`indriya`, `shilpa`, `samvada` and `karmendriya` returns zero files each,
verified 2026-09-09.

### 2. Why `agent` and `chatter` were retired

**`agent` is the worst name in the set, because everything here is an agent.**
Samvada is an agent. Scriba drives one. Prapañca exists to fan work out across
several of them. A word that every part answers to divides nothing, and a
directory name whose whole job is to divide has to.

**`chatter` names a tone.** What the part does is route an intent, divide a
task, execute a turn and shape an egress. `intent->skill` at
`prog/prapanca/chatter/router.chiral:130-139` maps four intents to four skills
and three intents to none, which is a function with a shape. `samvada` names
the function.

### 3. `prog/indriya/` is its own prog

**Because `prog/scriba/` and `prog/samvada/` may hold tools too.** Folding the
layer into the coding agent would make either one import a coding agent to get a
file read.

Scriba already holds tools, and already paid the duplication.
`prog/scriba/file-io.chiral` calls `open-rw` at `:56` and `:116` and
`open-create` at `:179` and `:200`. Its header at `:4-7` names the source:
`exactly like agent/tools-fs.chiral`. Two parts have written one file-open
shape twice, in the two directories the tool layer would otherwise have to pick
between.

What the layer holds:

| piece | what stands today |
|---|---|
| the tool vocabulary as a value | `coding-turn/A1` (`docs/arcs/coding-turn-arc.md:160`) is designed against exactly this: the four inline `Json` schemas at `prog/agent/agent.chiral:99-147` derived from a value instead of written beside it |
| the declared schemas | those same 49 lines, written by hand |
| the wire protocol | `prog/agent/agent.chiral:167`, `:201`, `:241`. Three code sites in one file |
| the implementations | `prog/agent/tools-fs.chiral`, 96 lines, two imports at `:21-22`, zero externs, three tools: `fs-read` at `:50`, `fs-write` at `:62`, `fs-edit` at `:88` |

### 4. The line between `prog/indriya/` and [[arcs/tool-authority-arc]]

[[arcs/tool-authority-arc]] carries 12 rows, `TA1` to `TA12`, committed
`c357168`. **It is the authority mechanism**: the registry boundary (`TA1`,
`TA2`, `TA12`), the inheritance default (`TA4`), the fd hand-off (`TA5`, `TA6`),
the constructed child (`TA7`, `TA8`, `TA9`), and the ask (`TA10`, `TA11`,
meeting `E43` at `docs/elements/catalog.md:170`). Every row is arc work over
`lib/ports/` and `lib/lowering/`.

**`prog/indriya/` is the tool layer standing on that mechanism**: what a tool is
as a value, what its schema says, what shape it takes on the wire, and what its
body does.

| | [[arcs/tool-authority-arc]] | `prog/indriya/` |
|---|---|---|
| tier | `lib/` | `prog/` |
| the question | may this hold turn a name into a descriptor | what a tool is, and how it reaches the wire |
| the thing | the crossing, the registry, the constructed child, the grant | the vocabulary, the schema, the dispatch, the implementation |
| what lands | rows against `lib/ports/` and `lib/lowering/` | a directory under `prog/` |

One is where authority is enforced. The other is what is expressed in terms of
it.

A tool written before the mechanism lands holds whatever the port floor hands it
today, and the built spike shows what that comes to.
[[decisions/decision-tool-capability]] §4 measures `fs-read` calling `open-rw`
itself at `prog/agent/tools-fs.chiral:52` and `fs-write` calling `open-create`
at `:64`, so the two tools that need no naming authority hold it anyway. The
layer can be built on the floor as it stands. What it gets from the mechanism
landing is that the grant becomes real.

### 5. `prog/shilpa/` is the spike renamed, and three things leave it

Today, as `prog/agent/`, it is a spike. Measured 2026-09-09:

| what | measurement |
|---|---|
| lines | 548, across `agent.chiral` at 452 and `tools-fs.chiral` at 96 |
| rows in `docs/elements/catalog.md` | 0 |
| rows in `docs/elements/ledger.md` | 0 |
| rows in `docs/definitions/status-ledger.md` | 0 |
| rows in `records/conformance-map.md` | 0 |
| roots that reach it | 2: `prog/samples/agent-probe.prog:9` and `prog/samples/self-extend-probe.prog:13` |

A grep for `prog/agent` across those four files returns nothing. Renaming a
directory with no ledger row and two probe roots costs the tree one import
rewrite.

Three statements follow. This document makes them and performs none.

**1. The tool-call wire protocol moves to `prog/indriya/`.**
`prog/agent/agent.chiral` is the only module in the tree that puts a `tools`
array into a request, at `:201`, and the only one that reads `tool_calls` back,
at `:167` and `:241`. A tree-wide grep for either token over `.chiral` and
`.prog` returns those three code lines and five comments. That protocol is what
every consumer with a tool needs, and it is the shared piece.

**2. The duplicated transport goes.** `prog/agent/agent.chiral:11-14` records
why the agent builds its own request body:

```
; Builds its OWN request body (carrying the `tools` array, parsing
; `tool_calls`) directly over http-request + json.chiral. backend.chiral's
; be-chat is the non-tool reference and is NOT used here, so no map-list /
; fn-param-over-a-recursive-type crosses the seam (the E100 residual).
```

**That reason has lapsed.** `map-list` is live in
`prog/prapanca/backend.chiral` at three sites: `:85`, `:195` and `:261`. The
first sits inside `chat-body` (`:79-86`), and `chat-body` is what `be-chat`
(`:116`) calls in its body. The seam the comment declines to cross is crossed
by the very function it points at.

⚑ `docs/arcs/coding-turn-arc.md:82` cites this passage as `:12-16`. The lines
are `:11-15`, with the E100 sentence at `:11-14`. The repoint belongs to that
arc's owner, and this document leaves it there.

**3. `ag-bash` is deleted, and no design replaces it.**
`prog/agent/agent.chiral:61-63` hands `/bin/sh -c` plus the model's string to
`raw-proc-spawn`, which [[decisions/decision-tool-capability]] §7 calls the
widest authority in the tree reached from a tool schema.

**The author ruled 2026-09-09 that the goal toolset excludes `bash`.** A tool
whose capability comes from coreutils and a shell is capability chirality did
not build, and it dissolves the native stance the tree already holds:
[[goals/self-tooling]] states the target as zero Python with `tools/` deleted,
and [[arcs/zero-python-arc]] holds the replacement tool by tool. A coding agent
reaching its power through `/bin/sh` is the same shape one directory over.

Three consequences, recorded and not performed:

- [[decisions/decision-tool-capability]] §4's table loses its last row, and it
  is the row that made every other narrowing decorative.
- `tool-authority/TA8` (`docs/arcs/tool-authority-arc.md:200`) says the supplied
  descriptor set is decorative while the child holds a shell. That condition is
  now false.
- **The spawn-shape question collapses.** `spawn-in-pty`
  (`lib/ports/pty.port:47`) takes ELF bytes and a slave path, so a caller can
  spawn only what it already holds. `raw-proc-spawn`
  (`lib/runtime/proc.chiral:110`) takes a NUL-framed argv packet and resolves
  the program by name. If the only image ever spawned is chirality-compiled,
  the ELF-bytes shape has the one customer and argv resolution has none.

### 6. `prog/samvada/` is the move [[decisions/decision-orchestration-boundary]] left open

`prog/prapanca/chatter/` plus `prog/prapanca/profile/` become `prog/samvada/`,
with profile as its config. Re-measured 2026-09-09, counting `.chiral` only:

| subtree | files | lines |
|---|---|---|
| `chatter/` | 5 | 2,057 |
| `profile/` | 10 | 1,226 |

`profile/` constructs 30 `Expert` values and 10 `Config` values, which is one
product's agents and its model bindings. Its registry at
`prog/prapanca/profile/skills.chiral:35-47` holds **seven** skill entries:
`doc-edit`, `code-test`, `evidence-sift`, `evidence-sift-refined`, `research`,
`deep-research` and `decision`. `doc-refine.chiral` builds a pipeline and an
expert pool and registers no entry of its own.

**The author ruled 2026-09-09 that this move happens now.** That closes the
second of the two calls [[decisions/decision-orchestration-boundary]] carried
out and left open, "Whether `chatter/` and `profile/` move now or trail".

**This document does not perform or schedule the migration.** A separate arc
does. One seam has to be cut either way:
`prog/prapanca/pipeline/compose.chiral:18-19` imports `prapanca/profile/profiles`
and `prapanca/profile/doc-refine`, so a module that stays reaches into one that
moves. That is the violation
[[decisions/decision-orchestration-boundary]] §4 measured, and no line of it has
changed.

### 7. A name is the author's, and an override costs one rename

Any of the five names may be overridden. The price is one mechanical rename, and
`b6065d1` is the measurement of what that price is. `manas` became `prapanca` on
2026-09-08 in a single commit: 55 modules moved, 21 sample roots renamed, 300
import lines rewritten across 93 files, 104 files updated in prose, and a diff
of 180 files at 860 insertions against 860 deletions. The symmetry is the point.
The commit added and removed no logic, and every changed line in it mentioned
one of the two words.

Four names had to survive that rename and did: `/workspace/manas`,
`manas-worker`, `manas-cursor` in `face.sh`, and the three
`.planning/MANAS-*.md` filenames. A rename here is a rename with traps in it,
and the traps are findable ahead of time.

## What this rejects

**A shell escape hatch.** §5 statement 3 rules it, and no narrower spelling
survives the same argument.

**A tool implemented by an external non-chirality program.** The same ruling,
generalized. A tool that shells out to `grep` borrows its capability from
somewhere the tree does not compile. `lib/text/matcher.chiral` is 602 lines
gated by suite Phase 19 and imported by `prog/prose-lint.prog:43`, which is what
the native answer looks like when it exists.

**Folding the tool layer into the coding agent.** §3 measures the cost: scriba
would import a coding agent to open a file, and it has already written its own
copy instead.

**A `prog/manas/`.** No such directory exists. `b6065d1` moved the whole subtree
on 2026-09-08 and left zero `prog/manas` path citations behind.
`/workspace/manas` is a dead Python repo outside this tree, cited deliberately
in 23 files, and the author call `Python: outside the tree, or inside it` was
ruled 2026-09-06: outside, and there is no Python in the language.

## What this does not rule on

**The orchestration boundary.** [[decisions/decision-orchestration-boundary]]
owns it. This document places parts inside the line that decision drew and does
not move the line.

**What a tool is to the language.** [[decisions/decision-tool-capability]] owns
it. The name-to-descriptor boundary is cited here and reopened nowhere.

**Element status.** [[status-ledger]] is the one authority. No row here changes.
This document mints nothing and defers to no `E#`. `E43`
(`docs/elements/catalog.md:170`), `E148` (`:463`), `E149` (`:464`) and `E163`
(`:475`) are each already minted, and each is cited as an existing row.

**Roster rows and schedule.** Naming five parts schedules no work. The
migration, the tool layer's first element and the `ag-bash` deletion each belong
to an arc, and none of the three is opened here.

## Two calls this decision carries out and leaves open

Each is the author's, and each owes a row in [[records/author-calls]]. No row is
written by this document.

1. **Is the coding agent ever the holder of naming authority, or is it always
   handed its descriptors?** If always handed, the holder is scriba or a
   supervisor, and that is a different prog's authority. Carried from
   [[decisions/decision-tool-capability]] call 2. It governs
   `tool-authority/TA2`, it decides whether the `raw-proc-spawn` re-declaration
   at `prog/agent/agent.chiral:46` is a defect or a workaround, and it decides
   whether a `prog/indriya/` implementation may take a path at all.

2. **`prog/prapanca/manas.chiral`.** Its header at `:1-6` calls it "the
   conformance instance that drives the whole orchestration stack" and then
   reads `this file is the only one that knows what "a prapanca run" is`. By
   [[decisions/decision-orchestration-boundary]] that makes it a consumer
   sitting inside the primitives. It also still carries the old filename after
   `b6065d1`, a deferral that commit recorded on purpose. Whether it is a sixth
   part, a piece of one of the five, or stays where it sits, is the author's.

## Two calls this decision would have carried and does not

Both were ruled by the author on 2026-09-09, and both are recorded above as
rulings.

| the call | where it stood | the ruling |
|---|---|---|
| does `bash` exist in the goal toolset at all | [[decisions/decision-tool-capability]] call 1 | no. §5 statement 3 |
| do `chatter/` and `profile/` move now or trail | [[decisions/decision-orchestration-boundary]] call 2 | now. §6 |

The `bash` ruling narrows a third call without closing it.
[[decisions/decision-tool-capability]] call 3 asks which spawn shape is the
model, and §5 records that the ruling removes the argv shape's widest customer.
That call stays with the decision that opened it.

## Honest limit

No directory moved. `prog/indriya/` does not exist, `prog/agent/` still reads
`agent`, `prog/prapanca/chatter/` and `prog/prapanca/profile/` are where they
were, and `compose.chiral:18-19` is still the live boundary violation
[[decisions/decision-orchestration-boundary]] named. Nothing here is checked by
anything, the same limit that decision and
[[decisions/decision-tool-capability]] each record.

What this buys today is four things. Five parts have names a reader can use. A
tool has a directory to go to other than a coding agent. The line between the
authority mechanism and the layer standing on it is drawn before either is
built. And `ag-bash` is a deletion with a date on it in place of a design owed.
