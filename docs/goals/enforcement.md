---
node: goal-enforcement
layer: navigation
related: [goals/README, decisions/decision-full-enforcement, bug-classes, arcs/enforcement-arc, arcs/syscall-custody-arc, status-ledger, testing-floors, index]
status: current
updated: 2026-10-01
---

# Goal: every obligation the principles imply is enforced, or says why not

## The claim, and where the project makes it

- [[decisions/decision-full-enforcement]]: the author ruled on 2026-10-01 that
  this goal claims every obligation `PRINCIPLES.md` implies, at ENFORCED or with
  its row saying why. The claim until then was *what is built is gated, and what
  the compiler claims it checks*.
- `PRINCIPLES.md:28`: a substrate that can do anything, so that everything it
  can do is named and therefore gateable. §3: the port-check is the type-check.
- [[bug-classes]]: once a class can be said, the checker can refuse it
  (`docs/definitions/bug-classes.md:14-16`). It carries the obligations, the
  classes and the cascade this goal quantifies over.
- [[status-ledger]] ranks every capability on four rungs by reach: DESIGNED,
  SEEDED (nothing calls it), IMPLEMENTED (reached and ungated), ENFORCED (gated).

## What done means

1. **Every class in [[bug-classes]] and every capability in [[status-ledger]]
   sits at ENFORCED, or its row says why it does not.** Observed on the cascade:
   cells R, C, P, N and G read `yes`, or the row's `next` and `owner` cells name
   the missing cell and an existing row that builds it. An `unrostered` owner
   counts as a hole. [[arcs/enforcement-arc]] and [[arcs/syscall-custody-arc]],
   and the arcs each row's `owner` cell names.
2. **Every refusal speaks a judgment with evidence.** A claim the compiler makes
   about its own work, or about the program, is carried as a value and refused
   when it does not hold. Observed by cell J: a `Judg` or `Reason` constructor
   for every class with a rule, and no gated refusal whose verdict is text.
   [[arcs/enforcement-arc]] rows `N1` to `N5`, and [[arcs/errors-as-values-arc]]
   row `EV7`. Four text verdicts are unrostered.
3. **The typed-assembly floor runs on the shipping path, and every adopted
   rewrite is checked.** Observed by `ck-prog` running on every shipping compile,
   by each rewrite the optimizer adopts carrying value-agreement evidence, and by
   the folder, the reference interpreter and native code computing one value.
   [[arcs/enforcement-arc]] rows `N6` to `N9`, `N12` to `N17`, `N19`, `N23`,
   `N24`.
4. **A passing gate means the property holds.** Observed by cell M, a named
   mutant that is run, for every gate row, and by the gates themselves being
   enforced: every phase's tally reaches the headline, a phase's verdict does not
   depend on checkout depth, every gate script is dispatched or states a true
   reason, a closure assertion refuses an absent checking module, the fixpoint
   compare runs as a phase, and a ledger row filed ENFORCED names a dispatched
   phase. [[arcs/enforcement-arc]] rows `N11` and `N21`, and
   [[arcs/lowering-and-emit-arc]] rows `LE22` and `LE24`. The closure assertion
   and the ledger check are unrostered.
5. **Chirality's own tooling is chirality's.** Observed as the ratio of lines
   outside the language to native ones, and by reach rather than the ratio
   alone. [[arcs/enforcement-arc]] row `N10`.

[[decisions/decision-full-enforcement]] leaves the mediator's obligations with
[[goals/independent-judgment]], the ownership-and-trust track's with
[[goals/ownership-and-trust]], and the doc tier's with [[goals/presentability]].
[[bug-classes]] lists their classes with the owning goal named in the row.

### The measurement behind condition 5

A tool that judges chirality source from outside the language is a floor this
project does not own.

**Measured 2026-10-01 at `2faa028`, every tool counted:** 22,222 lines outside
the language and 2,557 native. Outside: `tools/test/*.sh` 12,700 over 31 files,
Python 8,065 (`ledger-lint` 3,230, `pack` 1,951, `lens` 702, `frontier` 651,
`capture` 620, `doc` 331, the rest), `prose-lint.sh` 245, `xlat.sh` 496, the
bench harness 190, and the shell under `bin/` 526. Native: 14 `.prog` files.
**By verdict, 1 of the 27 dispatched phases judges in chirality**: Phase 2,
through `lib/evidence/test-floor.chiral`. The other 26 and the registration
witness judge in bash.

⚑ **The larger native figure does not improve the position.** Of the 2,557 native
lines, 1,249 are reached by a dispatched phase, and `prog/prose-lint.prog` among
them only as Phase 19's differential, since `prose-lint.sh` never calls it. 896
are reached only by undispatched gates (`optimizer-census`, `shape-census`), and
392 by nothing (`paren-audit`, `resolve`, `wield`). Half the native tooling is
written and unreached, which is the defect condition 1 names, turned on the
tools.

⚑ *Measured 2026-09-04, on a narrower definition (the gate tier, `prose-lint`,
nine Python tools, the CLI and the resolver, against tool `.prog` files only):
12,450 lines outside against 782 native.* Within the gate tier, `grep`, `sed`,
`sort` and `awk` then ran as **240 invocations**, of which **30 have a built
chirality composition** recorded in `docs/arcs/text-tools-arc.md`. The other
210 are judgments and wait on the independence criterion in
[[arcs/independent-judgment-arc]] J1. TC-02 in [[records/tooling-classification]]
carries the count; its scanner is untracked, so it cannot be re-taken here.

⚑ Some of it is correct and stays. A comparator holding constants cannot be
fooled by a mutated compiler, which is why the crypto gate prints from the
fixture and compares in bash. Over-claiming that bucket trades a safety property
for a dependency.

## State

In flight, measured 2026-10-01 at `2faa028`. [[bug-classes]] carries the
cascade row by row; this is its summary.

- **54 classes**, 28 carried before and 26 the principles add. ⚑ *65 later the
  same day: [[bug-classes]] added 11 found by research and probe, among them a
  checker that accepts a program which crashes (PRB-107).* **One is fully
  enforced**, IO from something that reads as pure, on its one bit (E171,
  E204). Of the 28, 9 sit at ENFORCED in whole or in part, 5 at IMPLEMENTED, 1
  at SEEDED, 4 at DESIGNED, 8 at none and 1 by construction. Sixteen have J as
  the next cell missing.
- **The vocabulary**: 38 `Judg` and 10 `Reason` constructors. 13 of the 48 have
  a negative fixture in a dispatched phase, and 5 a mutant of the rule itself.
  Five gated refusals answer in text.
- **The floor**: `ck-prog` has no call site, `lowering/tal/check` sits outside
  the compiler's closure, and `fold` ships unjudged. The reference interpreter
  has no importer and answers 0 for three comparisons the folder computes.
- **The gates**: at `2faa028` in a 50-commit clone the suite is 518 passed and
  3 failed; the headline prints `486 passed, 0 failed`. The three failures are
  history the clone lacks, and 15 mutants skip with them. No closure assertion
  exists, the fixpoint is held by hand, and nothing checks the ledger against
  the dispatch table.

### The dangerous thing has a type

A hatch exists because the type system has something it cannot express, so the
language hands you a way out of it. Declared as a crossing instead, the dangerous
thing carries a type and there is no exemption to reach for. Enumerating what a
program outputs is undecidable; enumerating how it reaches outside itself is
finite, so a module's reach is the set of boundaries it declares. Time and memory
are crossings too.

| what | state | where |
|---|---|---|
| port registries | 9 `.port` files, one per crossing family | `lib/ports/` |
| the profile port set | refused at emit | `lib/lowering/compile-emit.chiral:356`, gated by Phases 4 and 5 |
| the pure/process bit | refused at the call and at the extern | `lib/typing/kernel.chiral:900`, `lib/module/loader.chiral:471`, Phases 36 and 37 |
| capability types | `lincoll`, `secret`, `session` | `lib/capability/` |
| the crossing-to-wrapper table | one entry per lowered crossing | `lib/lowering/tal/crossing-wraps.chiral` |
| space as a crossing | arena, region, linear and two allocators | `lib/memory/` |
| the module datasheet, reach per module | not built, E161 | Phase 8 is unported and prints its reason every run |

### Checking costs nothing at runtime

Proof runs at compile time and is erased before emission, so there is no runtime
proof object to pay for. Quantity-0 binders are erased before runtime and types
before emit, in `lib/typing/qtt.chiral`. The measurements are
`docs/benchmarks/RESULTS-2026-08-01.md`.

### The named gaps

From [[records/enforcement-arc]] and [[bug-classes]]:

- The typed-assembly floor is built and unadopted. Neither the floor checker nor
  the optimizer's re-check runs in the shipping compile.
- The three refusing rules in `lib/typing/effects.chiral` still have no caller.
  The one bit they generalize is refused by E171 instead, and the row is
  `enforcement/N25`.
- Inbound entry-point verification is cut with no successor in this tree.
- A definition's fate is stated only when the compile fails. E184 states it on
  success and has a draft SPEC.

## Arcs

[[arcs/enforcement-arc]].

[[arcs/syscall-custody-arc]], opened 2026-09-14 on condition 1, over the
syscall surface: the permitted set, who may widen it, and who declares the
profile that narrows it. Five rows, each holding an element minted before the
arc, with arc-local ids `SC1` and up.

Condition 1 also reaches every arc a [[bug-classes]] row names as `owner`, among
them [[arcs/checker-core-arc]], [[arcs/substrate-floor-arc]],
[[arcs/sys-face-arc]], [[arcs/tool-authority-arc]],
[[arcs/lowering-and-emit-arc]], [[arcs/errors-as-values-arc]],
[[arcs/memory-discipline-arc]] and [[arcs/runtime-loading-arc]]. Their goal
lines name other goals today, and adding this one is a `revisit` per arc.

## Honest limits

Every rung in the ledger is enforcement against error. An adversary who controls
the source is out of its reach, because [[goals/independent-judgment]] is
unbuilt.

**On the obligations.** They were derived on 2026-10-01 from the five principles,
fourteen decisions that settled a principle's edge, and the reader's-side rules:
86 obligations. A list derived by reading is as complete as the reading, and a
principle edge settled later adds rows. Naming a class and checking it well are
different achievements: refinement refuses out-of-range values for `I64` and for
no other type.

**On what stays undecidable.** Exact cost is undecidable, so a grade is an
over-approximate bound (`PRINCIPLES.md:66-67`). Timing, cache pressure and
speculation reach the world with no port (`PRINCIPLES.md:108-111`), so the
closed set of crossings is closed only over the crossings someone thought to
declare, and the covert-channel class waits on a track that is build-deferred.

**On the crossings.** The refusal is at emit rather than at check, so a program
that names a frozen crossing type-checks and fails later; [[bug-classes]] lists
that as a class of its own. `ports/ports.chiral` has 108 importers as of
2026-10-01, which makes the facade a wide seam rather than a narrow one.
`backend-open` has no wrapper entry and erases to `nb-id` under the E144 string
carrier. ⚑ *This limit named `http-request` and `chat-open` too; both have been
chirality definitions over the socket capabilities since E130 and E131.*

**On reach.** A profile declares reach for a whole target rather than per module,
and the datasheet that would give a reader one module's reach is E161 and
unbuilt. Today the answer is assembled by hand from imports.

**On erasure.** The same erasure that makes proof free at runtime is why the
typed-assembly preserve check never runs: the types it would check are gone by
then. The benchmark harness was Python and did not survive the doc hoist, so
those numbers cannot be re-measured in this tree and stand as a dated record.

**On the gates.** The suite's verdict in a default cloud checkout is red for a
reason in the checkout, and its headline reports zero failures beside three. Both
are condition 4's, and until they are repaired a green line from this tree is
weaker evidence than the rungs read.
