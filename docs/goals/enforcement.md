---
node: goal-enforcement
layer: navigation
related: [goals/README, arcs/enforcement-arc, status-ledger, testing-floors, index]
status: current
updated: 2026-09-03
---

# Goal: what is built is gated, and what the compiler claims it checks

## The claim, and where the project makes it

- [[status-ledger]] ranks every capability on four rungs. They measure reach:
  DESIGNED, SEEDED (nothing calls it), IMPLEMENTED (reached but ungated),
  ENFORCED (gated).
- `PRINCIPLES.md` §3: crossing the membrane is where computation becomes
  checkable and mediated, and that crossing is the type-check.
- `MAP.md:86`: the `ports/` rule is structural and could be a gate. Today it is
  prose, and prose is how three files got into the wrong directory.
- [[status-ledger]], the SEEDED rung: a capability whose code exists and that
  no shipping path reaches.

## What done means

A capability sits at ENFORCED or its ledger row says why it does not. A claim
the compiler makes about its own work is carried as a value with evidence, and
refused when it does not hold. Every gate row has a named mutant that is
actually run.

**And chirality's own tooling is chirality's.** A tool that judges chirality
source from outside the language is a floor this project does not own. Measured
2026-09-04: **12,450 lines outside the language against 782 native.** The gate
tier is 6,915 lines of shell, `prose-lint` is 223 with awk doing the matching,
nine Python tools are 4,786, and the CLI and resolver are 526. The 782 is every
`.prog` file: `prose-lint` 256, `paren-audit` 244, `test-runner` 134, `resolve`
104, `wield` 44. The 390 this row carried until 2026-09-04 counted only the
first and the third.

⚑ **The larger native figure does not improve the position.** Reach measures it
and the ratio does not. `test-runner` and `prose-lint` are the two entries
anything reaches, and they are exactly the 390. The other 392 lines sit at
SEEDED: `grep -rIn` over `tools/` and `bin/` returns no invocation of
`paren-audit.prog`, `resolve.prog` or `wield.prog` from any shell file, gate
phase or CLI subcommand. Half the native tooling is written and unreached, which
is the same defect this goal names below, turned on the tools.

Within the gate tier alone, `grep`, `sed`, `sort` and `awk` run as **240
invocations**, of which **30 have a built chirality composition** recorded in
`docs/arcs/text-tools-arc.md`. The other 210 are judgments and wait on the
independence criterion in [[arcs/independent-judgment-arc]] J1, which has not
been written.

⚑ **The 352 this row carried until 2026-09-04 was a word-occurrence count,
presented as a call count with a composition behind every one of them.**
`grep -ohE '\bgrep\b' tools/test/*.sh` and its three siblings return 149, 100,
22 and 81, summing to exactly 352. Those occurrences include comments, the
scratch filenames `g5.awk` and `g9.awk`, and the prose in
`tools/test/matcher.sh` naming the tool the native matcher is graded against.
Counting invocations in command position gives 240, and the composition claim
covers 30 of them. TC-02 in [[records/tooling-classification]] carries both.

`lib/text/matcher.chiral` has one consumer. The capability exists and the
shipping path does not reach it, which is the SEEDED pattern this goal exists to
close, turned on the tools.

⚑ Some of it is correct and stays. A comparator holding constants cannot be
fooled by a mutated compiler, which is why the crypto gate prints from the
fixture and compares in bash. Over-claiming that bucket trades a safety property
for a dependency.

⚑ The reason is the OS rung rather than the gate. Every classic tool that
becomes a composition is one fewer thing an operating system written in this
language has to trust, and a resolver and a text tool are needed long before a
test harness is. `records/gate-audit.md` holds the measurement.

## State

In flight. A bug class comes off the list when it can be stated as a judgment and
a gate fails when the judgment stops holding. Anything short of that is a bug the
language happens to catch today.

Three of the six categories in [[bug-classes]] refuse something and three refuse
nothing. The vocabulary is 36 named judgments in `lib/typing/diag.chiral`,
measured 2026-09-03, and what it does not contain is the more useful half: no
constructor exists for effects, termination, bounds, overflow or ABI agreement.

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
| the profile port set | refused at emit | `compile-emit.chiral:300`, gated by `tools/test/profile-target.sh` |
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

From [[records/enforcement-arc]]:

- The effect membrane's three refusing rules are in the tree and nothing calls
  them. E171, unbuilt.
- The typed-assembly floor is built and unadopted. Neither the floor checker nor
  the optimizer's re-check runs in the shipping compile.
- Inbound entry-point verification is cut with no successor in this tree.
- Attribution of a def's fate cannot be measured today. E184, minted 2026-09-01.

## Arcs

[[arcs/enforcement-arc]].

## Honest limits

Every rung in the ledger is enforcement against error. An adversary who controls
the source is out of its reach, because [[goals/independent-judgment]] is
unbuilt.

**On the bug classes.** An open set of classes is a program of work rather than a
property the language has. Naming a class and checking it well are different
achievements: refinement refuses out-of-range values for `I64` and for no other
type. [[bug-classes]] carries the six-way split and is `status: draft`.

**On the crossings.** The refusal is at emit rather than at check, so a program
that names a frozen crossing type-checks and fails later. `ports/ports.chiral`
has 118 importers as of 2026-09-03, which makes the facade a wide seam rather
than a narrow one.
Timing, cache pressure and speculation are reaches with no port, so the closed
set is closed only over the crossings someone thought to declare.
`http-request`, `backend-open` and `chat-open` have no wrapper entry, so a
declared crossing can compile with nothing to lower to.

**On reach.** A profile declares reach for a whole target rather than per module,
and the datasheet that would give a reader one module's reach is E161 and
unbuilt. Today the answer is assembled by hand from imports.

**On erasure.** The same erasure that makes proof free at runtime is why the
typed-assembly preserve check never runs: the types it would check are gone by
then. The benchmark harness was Python and did not survive the doc hoist, so
those numbers cannot be re-measured in this tree and stand as a dated record.
