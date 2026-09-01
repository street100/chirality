---
node: elements-enforcement
layer: navigation
related: [status-ledger, index, diagnostics-arc, checklists/enforcement-arc]
status: current
updated: 2026-09-01
---

# Elements — the enforcement arc

**This file is TRACKED for the same reason [[diagnostics-arc]] is.** The element
catalog and the ledger live in `.planning/`, which `.gitignore:12` excludes by
design, so each worktree carries its own copy and nothing there reaches a second
reader or a second session. An element fact anyone else needs lives here.

The arc's subject is enforcement: a claim the compiler makes about its own work,
carried as a value, with evidence, and refused when it does not hold. E184 is its
first row.

`.planning/` stays the working detail (change plans, decision tables, SPECs).
This is the part that survives a fresh clone.

Build-state authority for the suite as a whole: [[status-ledger]].
Measurements this arc rests on: [[checklists/enforcement-arc]].
Lane division and what enforces it: `LANES.md`. Lane A resume: `HANDOFF-LANE-A.md`.

## Open — minted, not built

### E184

| E184 | **Attribution: every def's fate is stated by the compiler, with evidence, and checked** | Not built. Minted 2026-09-01. Attribution is **not measurable today**: five mechanisms decide a def's fate, only three leave a record, and all of it is discarded on the success arm. Seven requirements. **R1, a total fate function** over every def in the compiler's closure, a closed sum with no `_` arm: `emitted <label>` · `specialized-into <names>` (because `specialize-singletons` rewrites rather than drops) · `erased-by-design` (the type-level defs `filter-erasable` is supposed to remove) · `skipped <reason>`. The `erased-by-design` arm is required rather than optional: a type-level def is not a failed lowering, and without that arm every ratio built on the fates is noise. **R2, reasons carry evidence, not strings.** `skipped`'s reason is itself a closed sum: extern-with-no-wrapper naming the op, type-does-not-peel naming which type and where, callee-cascade naming the chain. E157's rule applies unchanged, and a `str-cat`'d sentence here reintroduces what E157 removed. **R3, `peel-def` stops returning `(Maybe NDef)`** and becomes a result sum. `compile-front.chiral:203-210` drops a def by returning `(none)` and keeps no record at all, the only one of the five mechanisms that leaves no trace, so nothing downstream can recover it. **R4, the record survives success.** `compile-all.chiral:34-38` discards the `skips` list on the `elf-ok` arm, so it surfaces only on an emit failure. **R5, the cascade is rooted.** `prune-fix` (`compile-back.chiral:210`) is transitive, so "dropped because callee X was dropped" is a pointer rather than an attribution; every chain must resolve to a non-cascade root, and `skip-diag.chiral` already carries E97's blame chain as the existing shape, which is why it is the right home. **R6, fates survive a renaming, and this is the design fork.** `specialize-singletons` (`compile-front.chiral:20`) runs before peel and changes a def's identity: `x64` becomes `x64$0`, `x64$1` and so on. Fates are therefore a relation across a renaming, and the rename mapping has to be produced by the pass that performs it and carried the rest of the way. Get it wrong and monomorphized singletons read as failures, which is exactly the misreading that made the earlier measurement worthless. **R7, conservation checked inside the compile, plus an exit.** The fates partition the closure's def set, exactly one per def, and folding them reproduces the emitted set; a def with no fate, or with two, fails the compile. That is the line between attribution and logging. `bin/chirality` has compile / run / check / test and no exit for the report, so one is owed, and the gate that reads it is a chirality program on E168's test floor rather than a shell script. **Cost:** roughly 150 to 250 LOC across five modules, three signature changes (`peel-def`, `specialize-singletons` emitting its rename relation, `compile-all` threading fates), plus build-new → test → promote with the fixpoint verified and the Step-0 precondition checked first. **Needs the full pipeline** (worked example → audit → SPEC → audit → implement): the fate taxonomy is a taxonomy and R6 is a genuine fork. The pre-run may recommend splitting R6 into its own element; if it does, that split mints its rows in the same change. ⚑ **The one read-only probe is gone.** Compiling through the E166 `Mach`→C leg and joining mangled C symbol names back to def names died with that leg (`d8bcec5`, `d0c5dd5`), and was never legitimate anyway: it shared `compile-front` and `compile-back` whole and differed only at emit, which is one formulation with two emitters, the shape `docs/decisions/decision-self-verification.md` §0 explicitly rules out. ⚑ **Measured 2026-09-01:** `skip-reason` (`lib/lowering/upper/lower.chiral:83-93`) together with `eligible?`, `lower-all`, `lower-def` and `LowRes` has **no caller outside its own file**; the live path imports `lower` for `compile-fn` only (`compile-back.chiral:15`), so the four exclusions those functions name (dependent type, effectful, quantified binder, type does not lower) are **never produced by a real compile**. Full requirement text: `docs/elements/enforcement-arc.md`. | `OURS`; ←E97, ←E157, ←E168 |

| E184 | lowering | design | **Attribution: every def's fate is stated by the compiler, with evidence, and checked.** A total fate function over every def in the compiler's closure, a closed sum with no `_` arm: `emitted <label>` / `specialized-into <names>` / `erased-by-design` / `skipped <reason>`, with `skipped`'s reason itself a closed sum carrying evidence (extern-with-no-wrapper, type-does-not-peel, callee-cascade), so E157's rule applies unchanged. `peel-def` stops returning `(Maybe NDef)`: `compile-front.chiral:203-210` drops a def with no record at all. `compile-all.chiral:34-38` stops discarding `skips` on the `elf-ok` arm. `prune-fix`'s transitive cascade (`compile-back.chiral:210`) resolves to a non-cascade root, in `skip-diag.chiral` beside E97's blame chain. Fates survive `specialize-singletons`' renaming (`compile-front.chiral:20`, `x64` becomes `x64$0`), which is the design fork: get it wrong and monomorphized singletons read as failures. Conservation is checked inside the compile, one fate per def, folding to the emitted set, with a report exit `bin/chirality` does not have and a gate on E168's floor. **Attribution is not measurable today:** five mechanisms decide a fate, three leave a record, all of it discarded on success. The one read-only probe died with the E166 C leg (`d8bcec5`, `d0c5dd5`) and was never legitimate, one formulation with two emitters. Measured 2026-09-01: `skip-reason` (`lib/lowering/upper/lower.chiral:83-93`) with `eligible?`/`lower-all`/`lower-def`/`LowRes` has no caller outside its own file, so its four exclusions never occur in a real compile. ~150-250 LOC, five modules, three signature changes, full BUILD RULE. **Pipeline: yes.** Minted 2026-09-01; full text in `docs/elements/enforcement-arc.md`. | ←E97, ←E157, ←E168 |


#### The seven requirements

**R1. A total fate function.** Every def in the compiler's closure maps to exactly
one fate. Closed sum, no `_` arm. Arms: `emitted <label>`; `specialized-into
<names>`, because `specialize-singletons` rewrites rather than drops;
`erased-by-design`, for the type-level defs `filter-erasable` is supposed to
remove; `skipped <reason>`. The `erased-by-design` arm is required rather than
optional: a type-level def is not a failed lowering, and without that arm every
ratio built on the fates is noise.

**R2. Reasons carry evidence, not strings.** `skipped`'s reason is itself a closed
sum: extern-with-no-wrapper naming the op; type-does-not-peel naming which type and
where; callee-cascade naming the chain. E157's rule applies unchanged, and a
`str-cat`'d sentence here reintroduces what E157 removed.

**R3. `peel-def` stops returning `(Maybe NDef)`.** `compile-front.chiral:203-210`
drops a def by returning `(none)` and keeps no record at all. It becomes a result
sum. This is the only one of the five mechanisms that leaves no trace, so nothing
downstream can recover it.

**R4. The record survives success.** `compile-all.chiral:34-38` discards the
`skips` list on the `elf-ok` arm, so it surfaces only on an emit failure. Fates
must return on success.

**R5. The cascade is rooted.** `prune-fix` (`compile-back.chiral:210`) is
transitive. "Dropped because callee X was dropped" is a pointer rather than an
attribution. Every chain resolves to a non-cascade root. `skip-diag.chiral`
already carries E97's blame chain as the existing shape, which is why it is the
right home.

**R6. Fates survive a renaming.** `specialize-singletons`
(`compile-front.chiral:20`) runs before peel and changes a def's identity: `x64`
becomes `x64$0`, `x64$1` and so on. Fates are therefore a relation across a
renaming, and the rename mapping has to be produced by the pass that performs it
and carried the rest of the way. This is the design fork in the element. Get it
wrong and monomorphized singletons read as failures, which is exactly the
misreading that made the earlier measurement worthless. The pre-run may recommend
splitting R6 into its own element; if it does, that split mints its rows in the
same change.

**R7. Conservation, checked inside the compile, plus an exit.** The fates
partition the closure's def set: exactly one per def, and folding them reproduces
the emitted set. A def with no fate, or with two, fails the compile. That is the
line between attribution and logging. `bin/chirality` has compile / run / check /
test and no exit for the report, so one is owed, and the gate that reads it is a
chirality program on E168's test floor rather than a shell script.

#### Cost

Roughly 150 to 250 LOC across five modules. Three signature changes: `peel-def`,
`specialize-singletons` emitting its rename relation, and `compile-all` threading
fates. Plus build-new → test → promote with the fixpoint verified and the Step-0
precondition checked first. **Needs the full pipeline** (worked example → audit →
SPEC → audit → implement): the fate taxonomy is a taxonomy, and R6 is a genuine
fork.

#### Why the element exists

Attribution is not measurable today. Five mechanisms determine a def's fate and
only three leave a record, all of it discarded on success.

The one read-only probe, compiling through the E166 `Mach`→C leg and joining
mangled C symbol names back to def names, is gone with that leg (`d8bcec5`,
`d0c5dd5`), and was never legitimate anyway: it shared `compile-front` and
`compile-back` whole and differed only at emit, which is one formulation with two
emitters, the shape `docs/decisions/decision-self-verification.md` §0 explicitly
rules out.

Also recorded, measured 2026-09-01: `skip-reason`
(`lib/lowering/upper/lower.chiral:83-93`) together with `eligible?`, `lower-all`,
`lower-def` and `LowRes` have **no caller outside their own file**. The live path
imports `lower` for `compile-fn` only (`compile-back.chiral:15`). So the four
exclusions those functions name (dependent type, effectful, quantified binder,
type does not lower) are **never produced by a real compile**.

## Numbering

E184 is the **first row of this arc**. The highest previously minted element was
**E183**. Lane A mints in **E184–E189**, Lane B in **E190–E195** (`LANES.md`).
A new element's row lands in `docs/examples/INDEX.md` **and here** in the same
change: those are the only two tracked places, and therefore the only collision
detectors that exist.
