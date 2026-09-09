---
node: arc-tuning
layer: navigation
related: [arcs/README, goals/local-ai, goals/self-tooling, records/author-calls, decision-work-ids, index]
status: current
updated: 2026-09-06
---

# Arc: fine tuning and the transformer verbs

- goals: [[goals/local-ai]]
- reserved element block: **none**. A row here would carry an arc-local id `U1`
  and up, per [[decisions/decision-work-ids]], and map to `unminted`. No row is
  written, and the Rows section says why.
- build-state authority: [[status-ledger]]

Opened 2026-09-02 from `.planning/LOCAL-AI-ARC-REALIGNMENT.md` section 3C. The
arc is opened blocked, so that criterion 4 of [[goals/local-ai]] is visible in
the tier that schedules work while it waits on a ruling.

## Why this arc exists

Criterion 4 of [[goals/local-ai]] carries the author's phrase for fine tuning,
model creation, and a growing and changing set of interactions over transformer
types, wrapping ollama and llama.cpp for now.

## The call that blocked it, and its answer

**Author call A is RULED, 2026-09-06: Python is outside the tree.** It is a
spawned external process, its scripts living outside this repo, reached through
a typed port under a linear reap obligation. There is no carve-out.

This arc is therefore **a ports arc over `E33`**. `proc-spawn` returns one
`SpawnRes` carrying a linear `Reap` (`lib/runtime/proc.chiral`), and
`raw-proc-spawn` maps to `nb-run-cmd` at
`lib/lowering/tal/crossing-wraps.chiral:54`, so the mechanism the roster rests on
is already built.

[[goals/self-tooling]] needs no rewording: no `.py` under the tree stays
literally true and [[arcs/zero-python-arc]] is unaffected. The two goals were
never in conflict; the unmade call made them look it.

⚑ This arc carried zero rows from 2026-09-02 to 2026-09-06 because either
reading changed its first one. `GAP-14` through `GAP-17` enumerated the four
requirements meanwhile and are closed by the roster below.

## What is measured today

Four absences, measured 2026-09-01 and unchanged on 2026-09-02.

| what | measured |
|---|---|
| the worker-side verbs | `prog/prapanca/backend.chiral` records `train-start` and `train-status` as documented and unbuilt. Nothing in this tree names them |
| a float type | `lib/protocol/json.chiral` keeps numbers as their raw lexeme and says why. `F64` and `Float` are grep-clean under `lib/surface/` and `lib/typing/` |
| a tensor form | `tensor` is grep-clean under `lib/` and `prog/` |
| autodiff | nothing in the tree differentiates anything |

Those four are why the author's phrase says wrap Python for this half.

## REQUIREMENTS

Draft, and each is checkable once the arc can open.

1. **Chirality holds a typed port for each verb** the criterion names: fine
   tune, create, and the interaction set over transformer types. Observed by the
   port declarations existing and type-checking.
2. **The external side is reaped under linear obligation.** A run that abandons
   a spawned worker fails to compile. Observed by a negative fixture.
3. **Swapping ollama for llama.cpp changes a declared value.** Observed by
   making the swap and reading the diff.
4. **The done condition of [[goals/self-tooling]] is still true**, or it was
   changed by a decision note that says so. Observed by reading both goal files.

## Roster

Groups: `port` is the typed crossing per verb, `custody` is the reap obligation,
and `swap` is the declared-value substitution.

| row | what | group | kind | origin | req | state | element |
|---|---|---|---|---|---|---|---|
| `tuning/U1` | the verb set, frozen: which of fine-tune, create and interact each get a port, and what each carries | port | decision | new | 1 | open | `unminted` |
| `tuning/U2` | a typed port per verb over `E33`'s `proc-spawn`, one seam serving ollama, llama.cpp and a training process | port | port | connect | 1 | open | `unminted` |
| `tuning/U3` | the external side reaped under linear obligation: a run that abandons the process fails to compile | custody | law | connect | 2 | open | `unminted` |
| `tuning/U4` | the backend as a declared value, so swapping ollama for llama.cpp changes that value and nothing else | swap | primitive | new | 3 | open | `unminted` |
| `tuning/U5` | a gate that asserts no `.py` entered the tree while this arc ran | swap | tool | new | 4 | open | `unminted` |

### Coverage

Every requirement is served: 1 by U1 and U2, 2 by U3, 3 by U4, 4 by U5. Every
row serves one. `U2` and `U3` are `connect`: `proc-spawn` and its linear `Reap`
are built at `lib/runtime/proc.chiral` and the gap is that no verb reaches them.

`GAP-14` through `GAP-17` are closed by this roster.

## Resume state


⚑ **2026-09-06: unblocked.** Author call A ruled, Python is outside the tree, so this arc is a ports arc over `E33` and its roster below is its first. `GAP-14` to `GAP-17` closed with it. **Next: `tuning/U1`**, the verb set, which every other row waits on.
**Where a session picks up.** Nowhere. The arc waits on author call A in
[[records/author-calls]], which states the two readings and picks neither.

**What the ruling decides.** Whether this arc is a ports arc over a built
primitive or a carve-out that reopens a settled goal, and therefore whether
[[goals/local-ai]] and [[goals/self-tooling]] conflict at all.

**What can proceed meanwhile.** Nothing in this arc. The other two arcs under
this goal, [[arcs/transport-arc]] and [[arcs/scriba-arc]], are independent of the
call and carry the goal's near work.
