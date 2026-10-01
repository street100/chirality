---
name: goal-open
description: >-
  Open or amend ONE goal for chirality: what the project claims, cited to where it
  already claims it, numbered checkable done-conditions each naming its arc or
  declaring itself unopened, the state, and the honest limits. Writes
  docs/goals/<name>.md. Use when asked to "open a goal", "state what we are
  doing", or before opening an arc that no goal covers.
---

# goal-open: state one goal, with done-conditions that can be checked

Produce exactly **one** goal file per run, then **stop**. A goal is a broad thing
this project claims it is doing. It says what it claims, cites where the project
claims it, states what done means, and says what falls short today.

This is a **planning run.** It writes `docs/goals/<name>.md` and adds that goal's
row to `docs/goals/README.md`. It opens no arc, designs no row, mints nothing.

## When to use

When work is aimed at an ambition no goal file states, or when a standing goal's
claim has moved.

## Two rules that gate this run before it starts

**Adding a goal means citing where the project already claims it.** Every goal
in this tree is a derivation from text already in the repo, or it declares
itself an author call in its own first section. Four have done the latter:
`presentability`, `readable-surface`, `local-ai` and `display`. Authoring a new
ambition is an author call, and this run may not take one. If the citation
search comes up empty, report that and stop.

**Changing what a goal claims changes what its arcs are for.** That is a
decision, and `docs/decisions/` holds it first. Amending the state or the limits
of a standing goal is ordinary work; amending its claim is not.

## Hard rule: one run = one goal

Exactly one goal file. Do not open its arcs in the same run. End by naming the
goal path and its unopened conditions, then **STOP**.

## Step 1: get the input bundle (ONE command)

```
python3 tools/pack/pack.py --goal <name> --start
```

This prints every repo-text hit for the ambition (the root spine, `docs/`,
`records/`), the goals that neighbour or overlap it, the banks naming the
concept, the `docs/definitions/status-ledger.md` rungs in range, and any
`records/author-calls.md` row that blocks it. `--start` is the write: it
**scaffolds** `docs/goals/<name>.md` with the section headers ready, and leaves
an existing file as it is. Without `--start` the command writes nothing.

**Read the neighbouring goals.** Two goals claiming one thing is the collision
this stage catches. `docs/goals/README.md` records why `module-split` is
separate from `readable-surface` and from `presentability`, and that paragraph
is the shape of the argument this run owes when the goals sit close.

## Step 2: fill the goal (five sections, in order)

### 1. The claim, and where the project makes it

A bulleted citation list. Each line: the document, and what it already says that
amounts to this claim. `[[links]]` inline, and a path in a link is rot.

Where the goal is an author's stated ambition, this section says so in its first
sentence, with the date it was stated. That is the declared form, and four goals
carry it.

### 2. What done means

**Numbered conditions. Each one checkable.** A condition with no way to observe
it is a wish. State the observation beside it: the gate that would fail, the
count that would move, the file that would exist.

**Each condition names its arc, or says it is unopened.** A condition holding no
arc file schedules nothing, and saying so in the goal is what keeps the goal
honest. `docs/goals/display.md` carries five conditions of which four are marked
unopened, and that is the shape.

### The shape condition, where one governs

Where the author has stated a constraint that governs every arc under the goal,
it gets its own section before §2, and its consequences are listed and
checkable. `docs/goals/display.md` carries one: a design feature arrives as
primitives plus tools that harness them, with three consequences each stated as
a test. Omit this section when no such constraint was stated. Do not invent one.

### 3. Arcs

The arcs that serve this goal, by `[[link]]`. **This section carries no element
rows and no roster.** A goal file that lists elements is duplicating the arc.

**A goal held by a standing gate carries no arc, and that is its finished
shape.** Where a rule that already runs maintains the goal on every change,
there is nothing to schedule and an arc would be an empty file. Say `none open`
and name the gates. `docs/goals/self-hosting.md` is the case, and `ledger-lint`
check V reads `none open` as a recorded reason. A goal with neither an arc nor a
gate is a hole, and check V fails it.

### 4. State

Dated. Where the goal stands today, against the conditions in §2.
`docs/definitions/status-ledger.md` is the authority for what is built on the
four rungs and `records/README.md` for a claim beside its measurement, so a
summary that disagrees with either is a defect in the summary.

### 5. Honest limits

What falls short. **This is the section that keeps a goal from reading as a
pitch**, and it is the one a stranger reads to find out what this project cannot
do yet.

Each limit is specific and measured: the claim that over-reaches, what was
actually counted, and the element or row that would close it. A limit naming an
`E#` owes the deferral rule, so that element is already minted, or the limit
names a roster row instead.

## Step 3: the README row

Add the goal to the table in `docs/goals/README.md`: goal, state, arcs. Where
the goal is an author call rather than a derivation, add the paragraph saying so,
alongside the four that already carry one.

## Done

- `docs/goals/<name>.md` filled, every done-condition numbered and checkable,
  every condition naming its arc or marked unopened.
- Every §1 citation opens at what it claims.
- `## State` dated, `## Honest limits` specific and measured.
- The `docs/goals/README.md` row added.
- No arc opened, no element minted.
- `python3 tools/ledger-lint/ledger-lint.py` run, and the count compared against
  the run before.
- Final message: the goal path, the condition count, which conditions hold an
  arc, and which are unopened. Stop.
