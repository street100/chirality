---
node: arc-native-document
layer: navigation
related: [arcs/README, goals/native-stack, arcs/native-window-arc, banks/text, decisions/decision-work-ids, decisions/decision-lane-split, records/author-calls, status-ledger, index]
status: current
updated: 2026-09-03
---

# Arc: the native document

- goal: [[goals/native-stack]]
- reserved element block: **none**. Rows carry arc-local ids `V1` and up, per
  [[decisions/decision-work-ids]], and map to an element or to `unminted`.
- build-state authority: [[status-ledger]]

Opened 2026-09-03 by author statement, sequenced last of the three by the same
statement. The idea: a typed document vocabulary and a style calculus with
dynamism in the substrate, rendered in the native window. The design draft is
`.planning/NATIVE-STACK-EXPANSION.md`.

## What is in the tree already

| where | what |
|---|---|
| [[examples/U13-typed-document-seam]] | drafted 2026-08-30: the renderer takes the typed value, and it settles where document heterogeneity is packed |
| `lib/prelude/doc.chiral:77` | the closed six-constructor Doc algebra, fenced by two run mutants ([[decisions/decision-lane-split]] names them) |
| `lib/text/matcher.chiral` | the idiom the vocabulary copies: a closed constructor set as the value of a class |

## REQUIREMENTS

1. **A typed document renders without a Str seam**, U13's rule, in the native
   window.
2. **Invalid nesting fails the checker.** The vocabulary is split by context
   so the defect is unconstructible rather than validated after the fact.
3. **Style is a total function of a declared state.** When the state sum is
   finite, the gate walks every state and checks the property under test in
   each one.

## Rows

| row | what | state | element |
|---|---|---|---|
| `native-document/V1` | the document vocabulary, closed sums per context | not started | `unminted` |
| `native-document/V2` | typed style values, and the cascade as a total ordered fold | not started | `unminted` |
| `native-document/V3` | the state function, and the every-state gate | not started | `unminted` |
| `native-document/V4` | the render seam into the window | not started | `unminted` |

## Resume state

Unopened, and blocked by design: [[arcs/native-window-arc]] rows W3 and W4 are
the render floor this arc lands on. The style calculus in the planning file is
a draft and nothing more.
