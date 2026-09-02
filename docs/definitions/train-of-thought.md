---
node: train-of-thought
layer: foundation
related: [goals/local-ai, records/author-calls, index]
status: settled
updated: 2026-09-02
---

# Train of thought

One named concept, and the twelve considerations a thought can be carried
through. It serves [[goals/local-ai]].

## The definition

The author's words, verbatim:

> a train of thought is a thought carried through a set of considerations
> (where reconsideration happens and changes the thought)

## The form a definition here takes

A definition states a thing's place as a relationship with what uses it as a
unit. A description of how a thing behaves is a mechanic and has another home.
Every entry here holds that form: each consideration is fixed by what the
thought is put next to, and each names what must be tracked.

## The four groups

The generalizing question is what the thought is put next to in a consideration.
That question gives four groups.

### A. The thought is put against something outside itself

| consideration | the thought is put next to | tracked |
|---|---|---|
| evidence | an observation, where disagreement changes the thought | the observation, and whether it agreed |
| another thought | a second thought, where conflict changes one or both | which two, and which gave way |
| memory | what is stored, where the stored completes a partial thought | what was retrieved, and on how much cue |
| a rule | something that licenses a next thought, where the rule carries it forward | which rule, and what it produced |

### B. The thought is transformed with nothing opposing it

| consideration | what happens to the thought | tracked |
|---|---|---|
| elaboration | carried into more detail than it had | what was added, and from where |
| abstraction | carried into less detail than it had | what was dropped |
| substitution | its parts exchanged for corresponding parts of another, where the correspondence is the point | the mapping used |

### C. The thought's standing changes, its content does not

| consideration | the standing it takes | tracked |
|---|---|---|
| commitment | carried forward as settled | what settled it |
| suspension | carried forward unsettled | what would settle it |
| rejection | carried no further | why it stopped |

### D. Considerations about the set itself

| consideration | what it is about | tracked |
|---|---|---|
| merge | two trains carried into one, where the join is itself reconsidered | both sources |
| ordering | which consideration a thought meets next | what ranked them |

## Tracked regardless of type

Every consideration has the same four slots: the thought before, the thing it
was put next to, the thought after, and whether it changed.

The fourth slot is what makes reconsideration visible rather than inferred. A
consideration that leaves the thought identical still happened, and the train
has to know it did or it will keep re-entering it.

Across the train, two more: the order the considerations were met in, and what
has already been rejected. The second is what stops a train circling.

## What the tracked column is for

The orchestration layer feeds the raw layer as much as it can. The tracked
column is that feed. It is the only thing the level below can see of what
happened above it. So track what the raw layer can use, and track more of it
where that is cheap.

## Three flagged as possibly not primitive

Each is open, and the author rules.

| consideration | the reduction that would remove it |
|---|---|
| memory | elaboration, with storage as the source instead of the thinker |
| abstraction | rejection, applied to parts instead of the whole |
| ordering | no consideration at all, since it changes no thought and only says which is next |

## Open

`thought` itself has no definition in this tree, and the definition above rests
on it.

## What this owes

No element number is minted here. `docs/decisions/decision-lane-split.md`
reserves `E184-E189` and `E190-E195` and nothing else, so work that follows from
this writes `UNASSIGNED` until author call B in [[records/author-calls]] rules on
a block.

## Where this came from

The research phase that preceded this definition is
`.planning/NEUROMORPHIC-TRANSFORMER-MECHANICS.md`, committed at `2746eab`: the
neuromorphic and transformer mechanics, measured, with their sources.
