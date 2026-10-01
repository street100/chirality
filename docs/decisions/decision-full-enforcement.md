---
node: decision-full-enforcement
layer: decision
status: DECIDED
decided: 2026-10-01
related: [goals/enforcement, bug-classes, status-ledger, arcs/enforcement-arc, goals/independent-judgment, goals/ownership-and-trust, goals/presentability, decisions/decision-scope, decisions/decision-design-before-mint, decisions/decision-dispatch-cadence, working-discipline, index]
updated: 2026-10-01
---

# Decision: enforcement claims what the principles oblige

**Decided 2026-10-01 by the author.** Read this before amending
[[goals/enforcement]], before adding a class to [[bug-classes]], and before
opening a roster row that serves either.

## The ruling

The author's words, verbatim, 2026-10-01:

> "work on entirely outlining everything required for full enforcement based on
> principles and cascading the fully structured patterns you see already
> specified"

Offered three shapes for the goal tier the same day, the author chose the
first, *"Amend enforcement's claim"*.

The goal claimed *"what is built is gated, and what the compiler claims it
checks"* (`docs/goals/enforcement.md:9` at `2faa028`). It now claims that
every obligation `PRINCIPLES.md` implies sits at ENFORCED on the
[[status-ledger]] rungs, or that the row holding it says why it does not.

## What the claim quantifies over

Three things, each with one home.

| what | home | a member is |
|---|---|---|
| obligations | [[bug-classes]], `## From the principles` | one checkable sentence derived from a principle, from a decision that settled a principle's open edge, or from `docs/definitions/design-principles.md` |
| failure classes | [[bug-classes]], the category tables | a way a program or the compiler goes wrong that an obligation forbids |
| the cascade | [[bug-classes]], `## The cascade` | the cells a class passes through on its way to ENFORCED |

The widening is in the first two rows. Condition 1 read *"A capability sits at
ENFORCED, or its ledger row says why it does not"*
(`docs/goals/enforcement.md:25` at `2faa028`), which quantifies over what has
been built. A
class nobody had built anything for sat outside every condition, and
[[bug-classes]] listed 28 of them under `status: draft` with no goal reading
the list.

## Where the obligations go

The enforcement goal takes the obligations whose check runs in this tree's
compiler or in its gates. Three goals already claim the rest, and they keep
them.

| obligations | goal | why there |
|---|---|---|
| distinct judgment cores, their agreement, and error told apart from adversary | [[goals/independent-judgment]] | that goal's claim and its conditions 1 to 5 |
| split providers, the tier carrier, DDC, succession across the reflective floor, information flow, constant time | [[goals/ownership-and-trust]] | build-deferred and plan-live, per [[decisions/decision-scope]] |
| a note's tense ahead of its build, detection filed as prevention, lint run as a gate | [[goals/presentability]] | that goal's conditions 1 and 4 |

Each of those three goals is amended in its state and its limits only. Their
claims do not move under this decision. [[bug-classes]] still lists their
classes, with the owning goal named in the row.

## Consequences

1. [[goals/enforcement]]'s five conditions are rebuilt on the cascade. The goal
   file holds their text.
2. [[bug-classes]] becomes the coverage list the goal quantifies over: the
   obligations, one row per class an obligation names, and the cascade cells
   for each row. A class with no owner carries `unrostered` and a suggested
   arc, as the deferral rule in [[working-discipline]] requires.
3. The arcs follow by `revisit` and `arc-open`, one artifact per run, serial per
   [[decisions/decision-dispatch-cadence]]. `.planning/DISPATCH-QUEUE.md` holds
   the queue.
4. Nothing mints here. New work is a roster row first, per
   [[decisions/decision-design-before-mint]].

## Rejected

| option | why it lost |
|---|---|
| keep the claim and cascade below it | the principle-derived classes would sit in [[bug-classes]] with no goal condition quantifying over them, and a class no condition names schedules nothing |
| a second goal for the gates themselves | `docs/goals/enforcement.md:36` at `2faa028` and `docs/goals/presentability.md:42` already state the run-mutant condition under two goals, and a third goal would give it a third home |

## What this does not rule

- No open row in [[records/author-calls]] is settled here. The calls on the
  cascade's path keep their state.
- Exact cost stays undecidable and the type carries an over-approximate bound
  (`PRINCIPLES.md:66-67`). Timing, cache pressure and speculation still reach the
  world with no port (`PRINCIPLES.md:108-111`). A class those limits govern is
  listed with the limit beside it.
- Every rung stays enforcement against error until [[goals/independent-judgment]]
  holds (`docs/definitions/status-ledger.md:151-154`).
