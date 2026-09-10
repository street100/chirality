---
node: decision-orchestration-boundary
layer: decision
status: DECIDED
decided: 2026-09-09
related: [decisions/decision-user-layer-extensibility, decisions/decision-work-ids, decisions/decision-lane-split, decisions/decision-scope, arcs/transport-arc, elements/catalog, records/author-calls, working-discipline, index]
updated: 2026-09-09
---

# Decision: `prog/prapanca/` holds the orchestration interface, and a consumer is its own prog

**Decided 2026-09-09.** Read this before adding a file under `prog/prapanca/`,
and before giving a product a home under `prog/`.

`prog/manas/` became `prog/prapanca/` on 2026-09-08 in commit `b6065d1`.
Prapañca is the mind's proliferation into multiplicity, which is what a fan-out
engine does; manas was the mind itself. Every path here uses the new name.

## The decision

### 1. `prog/prapanca/` holds the orchestration interface

It owns the Flow algebra, the pure plan spine, the run loop, the run manifest
with its conformance oracle, and the shapes `Expert`, `Config`, `Binding`,
`Pipeline` and `Skill`. It knows nothing about what it orchestrates. Agents,
model names, marker vocabularies and reply templates all sit outside it.

| what stays | where | measured 2026-09-09 |
|---|---|---|
| the shapes | `prog/prapanca/core/types.chiral` | 182 lines, 17 `data`, 0 `def` |
| the Flow algebra and its checker `flow-ty` | `prog/prapanca/core/flow.chiral` | 1,432 lines |
| the plan spine `match` then `gate` then `bind` | `prog/prapanca/pipeline/plan.chiral:4-6` over `core/match.chiral`, `core/gate.chiral`, `core/bind.chiral` | 187 lines of spine over 302 of stages |
| the run loop, the one module that crosses the backend seam | `prog/prapanca/pipeline/runner.chiral:3-5` | 205 lines |
| the run manifest and its conformance oracle | `prog/prapanca/contract/manifest.chiral`, `prog/prapanca/contract/golden.chiral` | 2 files, 395 lines |
| the four root files | `backend.chiral`, `coordinator.chiral`, `fsm.chiral`, `manas.chiral` | 452 lines, and `manas.chiral` is an open call below |

Whole subtrees, counting `.chiral` only:

| subtree | files | lines | verdict |
|---|---|---|---|
| `core/` | 10 | 2,729 | stays |
| `pipeline/` | 6 | 882 | stays |
| `contract/` | 2 | 395 | stays |
| root | 4 | 452 | stays |
| `profile/` | 10 | 1,226 | moves |
| `chatter/` | 5 | 2,057 | moves |

**Why those two move, measured.** `profile/` constructs 30 `Expert` values and
10 `Config` values, which is one product's agents and its model bindings.
`chatter/` is router, turn, divide, egress and orchestrate: marker vocabularies
at `prog/prapanca/chatter/router.chiral:50-58` (`"hi "`, `"should i"`,
`"summarize"`), the social and clarify reply templates at
`prog/prapanca/chatter/orchestrate.chiral:50-53`, and `intent->skill` at
`prog/prapanca/chatter/router.chiral:130-139`, which names four specific skills
and routes three intents to none. Every one of those is a product decision.

### 2. A consumer is its own prog

A consumer holds its own agents, its own model bindings, its own tools and its
own configuration. Three exist, under names the tree already spells.

| prog | is | what it takes |
|---|---|---|
| `prog/shilpa/` | the coding agent | the directory, which it already occupies |
| `prog/chatter/` | the conversational assistant | `prapanca/chatter/` plus `prapanca/profile/` as its config |
| `prog/scriba/` | the TUI | unchanged |

`prog/shilpa/` is a spike today: 548 lines across `turn.chiral` and
`tools-fs.chiral`, zero rows in `docs/elements/catalog.md`,
`docs/elements/ledger.md`, `docs/definitions/status-ledger.md` and
`records/conformance-map.md`, and reached by two roots,
`prog/samples/shilpa-probe.prog:9` and `prog/samples/self-extend-probe.prog:13`.
`prog/scriba/chat.chiral:3` and `prog/scriba/file-io.chiral:5` mention it in
comments and import nothing from it. A spike taking over a directory costs the
tree nothing today, which is why the name is claimed now.

### 3. Configuration lives inside each part

Configuration is a property of the part that reads it. There is no config tier
and no shared config directory. Each prog carries its own.

### 4. The dependency runs consumer to prapañca and never back

Prapañca must not import from a consumer, and must not name one.

**One site violates this today.** `prog/prapanca/pipeline/compose.chiral:18-19`
imports `prapanca/profile/profiles` and `prapanca/profile/doc-refine`, so a
module that stays reaches into one that moves. The violation is measured and it
is what the second open call below is about.

## The config carrier is JSON, read-only, one direction

Nothing writes it. A consumer reads its configuration off disk and the reader
does not emit.

This picks no new format. `docs/decisions/decision-user-layer-extensibility.md`
point 3 already ruled it, in text written before the rename:

```
3. **Data-loading is legitimate where the thing genuinely is data.** Saved manas
   setups (`:save`/`:load`, JSON on disk, shipped) are values, not code, and stay
   values. The test is whether the thing has behaviour: a keymap is data, a command
   body is code.
```

The reader is complete in both directions. `lib/protocol/json.chiral` carries
`json-parse` at `:335`, `json-show` at `:76`, `obj-get` at `:351`, `as-str`,
`as-int`, `as-bool` and `as-arr` at `:354-357`, and `json-quote` at `:73`. The
path is already walked: scriba's `:flow <path>` reads a file, parses it, and
decodes it through `json->flow` at `prog/scriba/command-loop.chiral:1209`.

**This is interim.** `E163` is minted and unbuilt (`docs/elements/catalog.md:475`)
and owns `.manifest` as a recognized coordinate. `MAP.md:13` already defines
`.manifest` as pure data, the replacement for JSON/TOML config. Two `.manifest`
files exist in the tree, `prog/climb.manifest` and
`lib/lowering/tal/target-linux.manifest`, so the kind is seeded and unenforced.
When E163 lands, the carrier changes and this ruling is superseded in place.

## What this rejects

**A second config format.** A TOML reader is roughly 250 lines built to be
deleted when E163 lands, against a decision that already picked JSON.

**A shared configuration directory.** It would give three consumers one home for
values only one of them reads, and it would put that home outside the part whose
behaviour the values decide.

**Prapañca knowing its callers.** The engine importing a profile is the coupling
this decision exists to name. `compose.chiral` is the one live instance.

## What this does not rule on

**Tools.** Whether a tool is a language-level crossing is a separate decision,
being written after this one. The boundary here places the tool layer on the
consumer side: a consumer holds its own tools. What a tool *is* to the language
is settled elsewhere, and this document names no filename for it.

**Element status.** `docs/definitions/status-ledger.md` is the one authority. No
row here changes.

## Two calls this decision carries out and leaves open

Both are the author's. Each owes a row in `records/author-calls.md`, and neither
row is written by this document.

1. **`prog/prapanca/manas.chiral`.** Its header calls it "the conformance
   instance that drives the whole orchestration stack", and its next sentence
   reads `this file is the only one that knows what "a prapanca run" is`. By this
   decision that makes it a consumer sitting inside the primitives. Its
   `cycle-step` breaker is generic; its notion of a run may not be. It also
   still carries the old filename while its prose reads prapanca, a deferral
   commit `b6065d1` recorded deliberately.

2. **Whether `chatter/` and `profile/` move now or trail.** 3,283 lines and an
   import rewrite, with `compose.chiral:18-19` as the one seam that has to be cut
   either way. The boundary is violated until the move happens, and the coding
   agent does not need it done first.

## Honest limit

The verdict column above is a placement call and no line of it has moved. The
two subtrees marked `moves` are where they were. What this decision buys today is
that a new file has a home rule to fail, and that `compose.chiral:18-19` is a
named violation instead of an unremarked import.
