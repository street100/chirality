---
node: goal-<name>
layer: navigation
related: [goals/README, arcs/<name>-arc, status-ledger, index]
status: current
updated: <YYYY-MM-DD>
---

# Goal: <what the project claims it is doing>

## The claim, and where the project makes it

<A citation list. Each line: the document, and what it already says that amounts
to this claim. Where the goal is an author's stated ambition rather than a
derivation, the first sentence says so, with the date it was stated.>

- [[<doc>]] <what it says>.

## What done means

Numbered. Each condition checkable, with the observation stated beside it. Each
names its arc, or says it is unopened.

1. **<condition>.** <What would be observed. The gate that would fail, the count
   that would move, the file that would exist.> [[arcs/<name>-arc]].
2. **<condition>.** <…> **Unopened, and it holds no arc file.**

## Arcs

[[arcs/<name>-arc]].

<Or `none open`, where a rule that already runs maintains this goal on every
change. Name the gates. A goal with neither an arc nor a gate is a hole and
`ledger-lint` check V fails it.>

This section carries no element rows and no roster.

## State

<Dated. Where the goal stands against the conditions above. [[status-ledger]] is
the authority for what is built on the four rungs and [[records/README]] for a
claim beside its measurement, so a summary that disagrees with either is a
defect in the summary.>

## Honest limits

<What falls short. Each limit specific and measured: the claim that over-reaches,
what was actually counted, and the element or roster row that would close it. A
limit naming an `E#` owes the deferral rule, so that element is already minted.>
