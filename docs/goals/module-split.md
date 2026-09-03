---
node: goal-module-split
layer: navigation
related: [goals/README, splitting-law, joining-law, axis-typeability, decision-split-checker, category-bridge, module-map, status-ledger, index]
status: current
updated: 2026-09-02
---

# Goal: each module is one thing, down to the trusted core

## The claim, and where the project makes it

- [[splitting-law]] states it as a rule with a floor and a ceiling: "A module
  that appears in two typeability categories is under split. Cut it until each
  piece is monochromatic... A split is real if and only if the two halves have
  different types, meaning different effect, cost, or tier weight. If the two
  halves have the same type shape, the split is spurious." One line: "overlap on
  the typeability axis means a split is missing; identical type shape means a
  split is spurious."
- [[joining-law]] is its dual: cut modules reconnect only through a typed
  connector that preserves the invariant the split exposed, and there are four.
- `PRINCIPLES.md` §2 is where it comes from: "everything is a process and the
  type is the process. Two forms with different types are therefore different
  processes, which means different modules."
- [[decisions/decision-split-checker]] applies it to the checker: kernel-spec, a
  small kernel-core, and untrusted producers, with "trust and volume decoupled."
- [[axis-typeability]]: a module that seems to be two kinds at once still awaits
  its cut.

## What done means

1. **A module's pieces have one type shape each.** Where two halves differ in
   effect, cost or tier weight they are two modules, and where they do not the
   split stays unmade.
2. **The trusted core's boundary is stated and holds.** Which files are
   `kernel-core` and which are untrusted producers, decided by the law rather
   than by history.
3. **Cut modules rejoin through a typed connector**, per [[joining-law]], rather
   than by a bare import.
4. **A missing split is measurable.** The law is a rule with a test, so a module
   that fails it is findable rather than argued about.

## State

In flight, with one measured miss and a body of precedent.

**The precedent.** [[splitting-law]] records worked splits that already landed:
the broker name carried two modules; three security modules each carried a proof
half and an evidence half; and integer safety **did not** split, because it has
the same type shape as refinement, which is the ceiling working as intended.

**The miss, measured 2026-09-02.** `lib/typing/kernel.chiral` is 1517 lines and
imports five things (`typing/qtt`, `typing/refine`, `surface/syntax`,
`surface/data`, `typing/diag`), so it delegates grades, refinements, the term
language and data declarations. It inlines `infer`, `check`, `conv` and the
con/tcon/case arms. Of those, `conv` has a plainly different type shape:

```
infer : (-> Sig Ctx Term TcR)
check : (-> Sig Ctx Term Value CkR)
conv  : (-> I64 Value Value Bool)
```

`conv` takes no `Sig`, no `Ctx` and no `Term`. By the law's own floor that is a
split the tree owes. [[decisions/decision-split-checker]] names it separately
too, as "NbE conversion including large elimination", one of five components of
the trusted core.

The rest of the typing tier is already cut: `qtt` 78, `refine` 168,
`totality` 387 with `totality-check` 161, `effects` 46 with `row-infer` 137,
`erased-nf` 47, `ty-cmp` 40, `kernel-core` 60, `reflect-floor` 54. Nine files.
The core was further along than this session first assumed.

## Arcs

[[arcs/module-split-arc]]. No reserved element block, so rows take arc-local ids
`S1` and up per [[decisions/decision-work-ids]].

## Honest limits

- Two of the nine typing files have zero importers, so a split that exists on
  disk is doing no work: `kernel-core` and `reflect-floor`
  (`records/findings.md` FD-09). Cutting a module and leaving it unreached
  satisfies this goal's letter and none of its point.
- The law's ceiling has no measurement. A spurious split costs overhead and
  nothing in the tree counts one, so this goal can only be shown failing in the
  under-split direction.
- [[joining-law]]'s four connectors are the rejoin discipline and
  `preserve-check` is the only one running today, in four lowering modules.
