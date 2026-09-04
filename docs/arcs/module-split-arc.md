---
node: arc-module-split
layer: navigation
related: [arcs/README, goals/module-split, splitting-law, joining-law, decision-split-checker, decision-work-ids, certificate-discipline, status-ledger, index]
status: current
updated: 2026-09-04
---

# Arc: cutting the source where the type differs

- goal: [[goals/module-split]]
- reserved element block: **none**. Rows carry arc-local ids `S1` and up, per
  [[decisions/decision-work-ids]], and map to an element or to `unminted`.
- build-state authority: [[status-ledger]]

Opened 2026-09-02. [[splitting-law]] is a standing rule with a decidable test and
nothing was scheduled against it.

## Why this arc exists

The law's floor: "A split is real if and only if the two halves have different
types." `lib/typing/kernel.chiral` inlines three judgements whose signatures
disagree, and one of them disagrees on every argument:

```
infer : (-> Sig Ctx Term TcR)      ; term in, type and usage out
check : (-> Sig Ctx Term Value CkR) ; term and expected type in, usage out
conv  : (-> I64 Value Value Bool)   ; no Sig, no Ctx, no Term
```

`conv` sits at `kernel.chiral:702-751` inside a 1517-line file whose other
occupants take a `Sig` and walk a `Term`.

Prior art puts this the same way. Andromeda's nucleus "does not perform complex
tasks like equality checking beyond syntactic equality; this responsibility is
delegated to the user, who implements one or more equality checking procedures",
and the nucleus requests witnesses of equality through operations and handlers.
Its nucleus is about 1800 lines of OCaml, the same order as this file, with
equality outside it.

## What is in the tree already

Nine files, so the typing tier is mostly cut already.

| module | lines | importers |
|---|---|---|
| `kernel.chiral` | 1517 | the checker. Inlines `infer`, `check`, `conv`, con/tcon/case |
| `diag.chiral` | 693 | imported |
| `totality.chiral` + `totality-check.chiral` | 548 | on the compile path. `totality-check` imports `totality`, and `lowering/compile-front` imports `totality-check`. ⚑ The classifier gates only under an opt-in `(total)` clause and no phase fails when it breaks. Re-measured 2026-09-04 |
| `effects.chiral` + `row-infer.chiral` | 183 | not imported by the checker. `row-infer` is reached from `module/sig-driver`, whose Phase 8 is unported, and `effects` from `row-infer` and `lowering/upper/eff-lower`. Re-measured 2026-09-04 |
| `refine.chiral` | 168 | imported by the checker |
| `qtt.chiral` | 78 | imported by the checker |
| `kernel-core.chiral` | 60 | **zero** |
| `reflect-floor.chiral` | 54 | **zero** |
| `erased-nf.chiral` | 47 | separate |
| `ty-cmp.chiral` | 40 | separate |

[[splitting-law]] also records three splits that already landed and one that was
correctly refused: integer safety folds into refinement because the type shape
matches, which is the law's ceiling working.

## REQUIREMENTS

Done when all four hold.

1. **`conv` is its own module**, because its type shape differs from everything
   it currently sits beside.
2. **The trusted core's file boundary is written down**, so which files are
   `kernel-core` and which are untrusted producers is decided by the law rather
   than by history.
3. **A cut module rejoins through a typed connector** ([[joining-law]]) rather
   than a bare import.
4. **A missing split is findable mechanically.** The law has a decidable test
   and nothing runs it.

## Rows

| row | what | state | element |
|---|---|---|---|
| `module-split/S1` | `conv` leaves `kernel.chiral` | not started. `(-> I64 Value Value Bool)` against its neighbours' `(-> Sig Ctx Term ...)` | `unminted` |
| `module-split/S2` | the trusted core's file boundary, stated | not started. `decision-split-checker` names five components, the tree has nine files and two are unreached | `unminted` |
| `module-split/S3` | a check that finds an under-split module | not started. Requirement 4. The law's floor is decidable and unrun | `unminted` |
| `module-split/S4` | the two unreached typing files wired or moved to SEEDED | not started. Shares its subject with `independent-judgment/J2`, which owns it | `unminted` |

## Resume state

Nothing built. S1 is the only row with a measured, named subject and it is where
this starts.

**What blocks the arc.** No reserved element block, so nothing here can be
minted. That is an author call, and the rows carry arc-local ids meanwhile. The
same block sits on [[arcs/independent-judgment-arc]] and [[arcs/bridge-arc]].

**S1 owes the BUILD RULE.** `lib/typing/kernel.chiral` is inside
`prog/compiler.prog`'s import closure, so moving `conv` changes compiler source
and owes `build-new`, test, promote, with the non-empty guard before the `cmp`.
`records/findings.md` FD-08 records that the tree currently reaches its fixpoint
at generation two rather than one, so an element promoting from this base either
promotes once beforehand or reports its two deltas separately.

**S4 belongs to another arc.** `independent-judgment/J2` already owns wiring
`kernel-core` and `reflect-floor`, and `J5` owns whether what they demand can be
checked at all. The row is here because a split that reaches nothing satisfies
this goal's letter and none of its point.

## Constraints this arc works under

- **The ceiling is as binding as the floor.** [[splitting-law]]: "identical type
  shape means a split is spurious." A row that cuts a module whose halves share a
  type shape adds overhead. Integer safety is the recorded case of the ceiling
  correctly refusing a split.
- **Cutting is half the theory.** [[joining-law]] holds the four typed
  connectors, and `preserve-check` is the only one with call sites at all, in
  `eff-lower`, `optimize`, `lower` and `sig-driver`. ⚑ **None of them is
  reached by a shipping compile.** [[status-ledger]] demoted `preserve-check` to
  built-and-unadopted on 2026-08-31 and records on 2026-09-03 that `ck-prog` has
  no call site on the compile path. That is the enforcement arc's requirement 2,
  and this arc rejoins nothing through a connector that runs.
- **A split is a claim about types rather than about size.** 1517 lines is what made
  `kernel.chiral` worth measuring and it is no argument on its own. The argument
  is that `conv` takes none of the three arguments its neighbours take.
