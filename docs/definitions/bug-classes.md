---
node: bug-classes
layer: foundation
related: [status-ledger, totality, open-edges, tal-spec]
status: draft
updated: 2026-09-04
---

# Bug classes: the coverage list

The long road. Every class of failure that is not you reasoning wrong, what
would have to exist for the language to say it, and whether that exists today.

The bet is that everything can be expressed. That makes this a mechanical job.
A class can be given a way to be said, and once it can be said the checker can
refuse it. Work through the classes until what is left is a mismatch between
your specification and your intent.

Adding a class with no element is expected. The catalog was never going to cover
everything, and a row here with a blank element column is honest about being
unscoped.

## How to read the state column

| state | means |
|---|---|
| **refuses** | in the compiler binary, with a judgment, and it rejects the bad case |
| **partial** | some of the class is caught |
| **unwired** | the module is written and is **not in the compiler binary** |
| **design** | decided on paper, no module |
| **none** | nothing exists |
| **by construction** | the language has no way to express the failure |

⚑ **Unwired is the important one, and it is not the same as unbuilt.** See the
systemic finding at the bottom. 1,359 LOC of checking machinery is written and
absent from the compiler, re-measured 2026-09-04 (⚑ *1,680 on 2026-09-01, before
E11's classifier joined the closure*).

## Memory and ownership

| class | how it gets said | state | element |
|---|---|---|---|
| use-after-free, double-free | quantities on binders, 0 erased, 1 used once, ω free | refuses | |
| null deref | sums, with no null in the language | by construction | |
| aliasing, shared mutation | linear binders, plus the `(memory linear)` / `(memory region)` profile clause | partial. The clause parses and is gated on its parse. `mem-linear`, `mem-region` and `arena` are all unwired | |
| buffer overread and overwrite | bounds on indexing | none. `str-sub` reads past its buffer today | |
| uninitialized read | | none | |
| stack exhaustion | | none | |

## Effects and authority

| class | how it gets said | state | element |
|---|---|---|---|
| calling a syscall the program never declared | port registries plus the emit chokepoint | refuses. `sys-check.chiral` ships and `ck-tiprog` runs at `compile-emit.chiral:296` | E76 |
| IO from something that reads as pure | pure `->` against process `=>` | **wired at the call, 2026-09-30.** E171 refuses a `->` body applying a `=>` callee (`jg-pure-crossing`), phase 36. The effect row beyond the one bit is `enforcement/N25` | E12, E171 |
| a dependency exceeding its grant | capability types, module datasheet fencing | partial | E161 |
| secret leaving by the wrong exit | linear `Secret` with one guarded exit | type-checks. No entry in `crossing-wraps`, so nothing executes it | |
| ambient authority through globals or environment | | none | |

## Resources and termination

| class | how it gets said | state | element |
|---|---|---|---|
| non-termination, unbounded recursion | structural and numeric-measure classifier | **partial, wired 2026-09-02.** `typing/totality` (387 L) is in the compiler binary through `typing/totality-check`, which `lowering/compile-front` imports, and the gate refuses wherever a profile carries `(total)`. The gate is **opt-in** and no suite phase fails when it breaks, so a source with no profile diverges as before. `Judg` still has no termination constructor; the refusal is a `tot-holdout` string from `tot-holdout-msg`. ⚑ *This row read "unwired, and `LEDGER.md:86` files this `built`, which is wrong". `docs/elements/ledger.md:433` records the two sides AGREED on 2026-09-02.* | E11 |
| unbounded allocation | cost carried in the type | design | |
| handle and fd leaks | linear resources | partial | |
| time or fuel budget exceeded | the cost gradient | design | |

## Data at boundaries

| class | how it gets said | state | element |
|---|---|---|---|
| non-exhaustive branches | case coverage | refuses | |
| unsound recursive data | strict positivity | refuses | |
| out-of-range values | refinement types, **`I64` only** | refuses. `let`-bound results still fail to check, measured as BA-41 and `records/findings.md` FD-02 | `UNASSIGNED`. ⚑ *This read "next free number is E182"; E182 was minted, built 2026-09-02, and is a different element* |
| unchecked parse results | declared crossing plus refinements | partial | |
| integer overflow, division by zero | | none | |
| FFI and ABI signature disagreement | extern declarations checked against the real ABI | declared only. `jg-extern-nontype` checks an extern's type is a type. Nothing checks it against the ABI, at declaration or at link | |
| config drift | data declared in the file | not built | E163 |

## Compilation fidelity

| class | how it gets said | state | element |
|---|---|---|---|
| miscompilation | typed assembly, checked at instruction level | **unwired.** `lowering/tal/check` is not in the compiler binary. Its only caller, `upper/optimize`, is also absent | E16, E18 |
| non-reproducible build | fixpoint | verified, gen2 == gen3 | |

Three things stand between the miscompilation row and being caught. They are
mechanism state rather than failure classes, so they sit here instead of as rows.

| gap | element |
|---|---|
| types are erased before emit. `erase-fn` strips every `TFn` to a neutral `NFn`, and `emit-elf-m` takes `NFn` only | E16, E18 |
| effectful and dependent code never lowers, so there is no `TFn` to check | E70 |
| no reference semantics ship to check against. `tal/eval` and `tal/spec` are outside the binary | E18, E71 |

## Concurrency

Nothing in the tree points at any of this.

| class | state |
|---|---|
| data races | none |
| deadlock | none |
| time-of-check to time-of-use | none |
| memory ordering | none |

## What the checker can actually refuse today

Ground truth is the judgment vocabulary, `lib/typing/diag.chiral:97-110`
(38 `Judg` constructors) and `:120-137` (9 `Reason` evidence shapes).

| group | count | examples |
|---|---|---|
| type and arity shape | 17 plus `r-mismatch` | `jg-apply-nonfn`, `jg-tcon-arity`, `jg-type-as-value` |
| case coverage and constructor use | 10 | `jg-nonexhaustive`, `jg-empty-case`, `jg-dup-branch` |
| refinements, `I64` only | 5 | `jg-refine-unproved`, `jg-refine-i64` |
| linearity and usage | 4 | `jg-linear-field`, `r-usage`, `r-linear`, `r-arrow` |
| strict positivity | 1 | `jg-not-positive` |
| scope and binding | 4 | `jg-var-range`, `jg-esc-binders`, `r-unbound`, `r-redeclared` |
| lowering skips | 1 | `r-skipped` |

**No constructor exists for effects, termination, bounds, overflow, or ABI
agreement.** A rule cannot refuse what the vocabulary cannot say, so each of
those needs a `Judg` arm before it needs a caller.

## The systemic finding, 2026-09-01, re-measured 2026-09-04

The compiler binary is the transitive import closure of `prog/compiler.prog`:
**60 modules**, of which 50 are `lib/**.chiral` totalling **16,736 LOC**, out of
`lib/`'s 95 `.chiral` modules and 25,934 LOC. ⚑ *The 2026-09-01 reading was
**58 modules, 16,075 LOC** against 103 modules and 25,222 LOC, and it stands as
what it measured. E11's wiring on 2026-09-02 put `typing/totality` and
`typing/totality-check` into the closure, which is the whole of the module-count
move.*

**Nine** modules are checking machinery that is written and absent from that
closure. ⚑ *This read ten. `typing/totality` (387 LOC) left the list when the
classifier was wired, and `lowering/tal/check` grew from 246 to 312 when
`5b4fb71` prefixed eleven names `tck-`.*

| module | LOC |
|---|---|
| `lowering/tal/check` | 312 |
| `lowering/upper/optimize` | 254 |
| `lowering/tal/eval` | 187 |
| `lowering/upper/eff-lower` | 183 |
| `typing/row-infer` | 137 |
| `lowering/tal/spec` | 126 |
| `typing/kernel-core` | 60 |
| `typing/reflect-floor` | 54 |
| `typing/effects` | 46 |
| **total** | **1,359** |

That is 8% of the compiler's own size, down from the 10% the ten scored. Verified
two ways: no `(import "<key>")` anywhere in `lib` or `prog`, and no mention of the
full module key anywhere in `lib`, `prog` or `tools`. ⚑ `lowering/tal/check` is
now **importable** beside the compiler (`5b4fb71`) and still imported by nothing
on the compile path, which BA-26 measures: being loadable and being adopted are
two states and only the first moved.

Absent for good reasons, since the compiler has no use for them: `protocol/`
(3,729), `evidence/` (1,348), `runtime/` (379), `capability/` (216), the C
backend.

**How it happens.** `tools/test/run-tests.sh:363` says it plainly:

> `compile-only: N roots built, N failed -- gates, but asserts nothing`

87 roots go through that gate, measured 2026-09-04. A module that compiles passes it. Nothing asks
whether a module is inside the compiler's import closure. So a checking rule can
be written, compile cleanly, pass the suite, get marked built in the catalog, and
never run.

The repo named this before. `prog/test-runner.prog:8-9` calls "built but
unadopted" its measured failure mode and counts four occurrences. The sweep says
ten.

⚑ That same comment cites `scaffold/tests/run-native.sh`, a path the doc hoist
removed. Logged, not fixed here: editing `lib/` or `prog/` changes compiler
source and owes a fixpoint rebuild.

**What closes it.** A closure assertion: compute the import closure of
`prog/compiler.prog` and refuse when a named module is absent. The machinery is
already here and already chirality. `lib/module/resolve.chiral` has
`collect-imports`, `parse-imports`, `walk-imports` and `walk-list`.
`lib/evidence/test-floor.chiral` is E168's floor with `Suite` and `Expect`,
adopted by `prog/test-runner.prog`. No element covers the gate itself, so it
needs minting.

⚑ The gate reads import keys, and the file-extension scheme that defines the
module key is being reworked. The gate and the resolver move together.

## Test discipline this implies

Three per rule, and the second is the one that has been missing:

1. positive fixture, valid code passes
2. **negative fixture, invalid code is refused with the expected judgment**
3. closure assertion, the module is in the compiler binary

A rule that is wired and never refuses is the same failure in different clothes.
`tools/test/samples/e170_reject_secret_leak.prog` is already a negative fixture
with no runner.

⚑ Unmeasured: whether the seven rule groups that do ship have refusal fixtures at
all.

## Counts, 2026-09-01

28 classes across the six categories.

| state | classes |
|---|---|
| refuses | 6 |
| partial | 5 |
| unwired | 3 |
| design | 2 |
| by construction | 1 |
| none | 11 |

Six of twenty-eight refuse today. Three more are written and sitting outside the
compiler binary, and three further mechanism gaps stand behind the miscompilation
row.

⚑ Deduplicated 2026-09-01. Five rows came out. "FFI signature disagreement" and
"link and ABI mismatch" were one class written twice. "Memory discipline per
program", "effectful and dependent code never lowering", "type information
discarded at codegen" and "reference semantics to check against" are features and
mechanism state. They moved into the rows and notes they belong to.
