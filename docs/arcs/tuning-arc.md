---
node: arc-tuning
layer: navigation
related: [arcs/README, goals/local-ai, goals/self-tooling, records/author-calls, decision-work-ids, index]
status: current
updated: 2026-09-02
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

## What blocks it, and it is the whole arc

Author call A in [[records/author-calls]]: Python outside the tree, or inside
it. The two readings share no first row.

| reading | what this arc becomes |
|---|---|
| a spawned external process, its scripts living outside this repo | a ports arc over E33, which is BUILT native: `proc-spawn` returns one `SpawnRes` with a linear `Reap`, and the wrapper is registered in the crossing table. It mints no `.py` file and leaves [[goals/self-tooling]] intact |
| `.py` files inside the tree, under a carve-out | a `tools/`-shaped arc, which [[goals/self-tooling]]'s done condition forbids as written. That condition would have to be reworded first, and `docs/goals/README.md` makes that a decision before it is an edit |

`docs/arcs/zero-python-arc.md` serves the goal that the second reading
contradicts. Nothing is re-pointed between them until the call is made.

## What is measured today

Four absences, measured 2026-09-01 and unchanged on 2026-09-02.

| what | measured |
|---|---|
| the worker-side verbs | `prog/manas/backend.chiral` records `train-start` and `train-status` as documented and unbuilt. Nothing in this tree names them |
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

## Rows

**Zero rows, and that is the honest state.** The proposal that opened this arc
measured that the two readings of author call A share no first row, so any row
written now prejudges the call. The candidates under each reading are in the
table above and neither is scheduled.

## Resume state

**Where a session picks up.** Nowhere. The arc waits on author call A in
[[records/author-calls]], which states the two readings and picks neither.

**What the ruling decides.** Whether this arc is a ports arc over a built
primitive or a carve-out that reopens a settled goal, and therefore whether
[[goals/local-ai]] and [[goals/self-tooling]] conflict at all.

**What can proceed meanwhile.** Nothing in this arc. The other two arcs under
this goal, [[arcs/transport-arc]] and [[arcs/scriba-arc]], are independent of the
call and carry the goal's near work.
