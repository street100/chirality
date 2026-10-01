---
node: bug-classes
layer: foundation
related: [goals/enforcement, decisions/decision-full-enforcement, status-ledger, totality, open-edges, tal-spec]
status: current
updated: 2026-10-01
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

## How to read a row

| cell | the row has it when |
|---|---|
| **J** | a `Judg` or `Reason` constructor in `lib/typing/diag.chiral` can say the class |
| **R** | a rule refuses the class, at the `file:line` the cell names |
| **C** | the rule sits in the import closure of `prog/compiler.prog` and the shipping compile calls it |
| **P**, **N** | a positive fixture passes, and a negative fixture is refused with the expected judgment |
| **G** | a phase `tools/test/run-tests.sh` dispatches runs **P** and **N** |
| **M** | a named mutant of the rule runs, and **G** goes red under it |

⚑ **Cells run in build order.** R without C is SEEDED, C without G IMPLEMENTED,
and G over N ENFORCED; full enforcement adds J and M. `next` is the first cell
missing and `owner` builds it. [[goals/enforcement]] quantifies over this list
([[decisions/decision-full-enforcement]]); `## The cascade` gives the sources.

## Memory and ownership

| class | how it gets said | J | R | C | P | N | G | M | rung | next | owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| use-after-free, double-free | quantities on binders, 0 erased, 1 used once, ω free | yes, `r-usage` and `r-linear` (`diag.chiral:129`, `:131`) | part. Binders refuse at `kernel.chiral:645`, `:657` and `:1197`. A minted `Fd` captured by a returned closure is closed twice and checks (PRB-101) | yes | yes, `check-cli.sh:60-66` | yes, `check-cli.sh:69`. Four `e124`, `e126` and `e170` rejects refuse and no phase runs them | yes, phases 3 and 6 | yes, `qfits-q1-accepts-all` (`check-cli.sh:149`), `strip-binder-off` and `close-binder-off` (`linear-mint.sh:489`, `:498`) | ENFORCED for binders | R, the closure capture | `checker-core/CK20` |
| null deref | sums, with no null in the language | n-a | by construction for sums. An extern re-typed over a prim breaks it: `(extern str-len (-> I64 I64))` then `(str-len 0)` exits 139 | n-a | n-a | no | no | no | by construction, broken through FFI | R, extern signature agreement | E75, held by no arc (UNS-26). Suggested `enforcement`, beside `N27` |
| aliasing, shared mutation | linear binders, plus the `(memory linear)` / `(memory region)` profile clause | yes, `r-usage`, `r-linear`, `jg-linear-field` (`diag.chiral:107`), `jg-linear-field-decl` (`:113`) | part. Binders, `kernel.chiral:1041`, `loader.chiral:542`. `Bytes` is immutable and mutation goes through linear `Pool`. `adopt-fd` mints two `Fd`s for one descriptor (`fd.port:32`) | part. `mem-linear`, `mem-region` and `arena` have no importer | yes | part. The two `e106` field rejects refuse and no phase runs them | part. Phase 6; phase 4 gates only the clause's parse | part. None for the field rule | ENFORCED for binders, IMPLEMENTED for fields | R, `adopt-fd` and closure capture | `checker-core/CK20`, `CK15` (E8); `memory-discipline/M6`, `M8`, `M9` |
| buffer overread and overwrite | bounds on indexing | part. `jg-refine-unproved` (`diag.chiral:107`) can say it | no. `str-sub`, `bget` and `bslice` read past their buffers, declared bare at `prelude.chiral:83`, `:97-98` | n-a | no | no. `(bget (str->bytes "abc") 99)` exits 0 | no | no | none | R | `enforcement/N22`, then `N18`, `N19`, `N20` (E198); `diagnostics/L5` (E176) |
| uninitialized read | every surface binder is bound, and a fresh cell is zero by the contract at `x64/mach.chiral:649` | no | none. The contract's pin was cut with the Python oracle | n-a | n-a | no | no | no | none | J, or a pin on the zero contract | unrostered. Suggested `memory-discipline`, whose `M2` and `M3` must keep the contract |
| stack exhaustion | | no | no. `bin/chirality:149` runs every program under `ulimit -s unlimited` | n-a | n-a | no. `_recurse-ceiling.prog` is KNOWN_FAIL (`run-tests.sh:173`) on an unrelated error | no | no | none | J | unrostered. Suggested `substrate-floor` |

## Effects and authority

| class | how it gets said | J | R | C | P | N | G | M | rung | next | owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| calling a syscall the program never declared | port registries plus the emit chokepoint | no. The verdict is `SysR (sbad Str)` (`sys-check.chiral:19`), turned into `elf-err` text | yes, `ck-tiprog` (`sys-check.chiral:72`) called at `compile-emit.chiral:353`; H8 at `:356` | yes | yes, `syscall-manifest.sh:113` | yes, poisons at `:115-121`, H8 at `:138-143` | yes, phase 5 | part. The poisons alter registry data; nothing mutates `ck-tiprog` or `manifest-offender` | ENFORCED. ⚑ *Until 2026-10-01 this row cited a comment line in `compile-emit.chiral` as the call site* | J | `syscall-custody/SC1` (E76). J unrostered, suggested `errors-as-values`; M `enforcement/N11` |
| IO from something that reads as pure | pure `->` against process `=>` | yes, `jg-pure-crossing` (`diag.chiral:111`), `jg-extern-pure-crossing` (`:112`) | yes, `kernel.chiral:900`, `loader.chiral:471` | yes | yes, `membrane.sh:138-141` | yes, `membrane.sh:97-128`, `extern-honesty.sh:102-110` | yes, phases 36 and 37 | yes, `membrane.sh` m1 to m4, `extern-honesty.sh` m1 and m2 | ENFORCED on the one bit, E171 and E204 | J, the effect row beyond the bit | `enforcement/N25` (E39) |
| a dependency exceeding its grant | capability types, module datasheet fencing | no. A sheet's refusal arrives as `r-relayed` text (`load-batch.chiral:83`) | part. `cat-fenced` (`loader.chiral:295`) refuses a `(cat A)` module that binds a crossing. Nothing fences per dependency | yes | no | no | no. Phase 8 is unported | no | IMPLEMENTED in part | J | E161, held by no arc. Suggested `sys-face` beside `SF20` for Phase 8, `errors-as-values` for J; `tool-authority/TA11` |
| secret leaving by the wrong exit | linear `Secret` with one guarded exit | yes, `r-mismatch` (`diag.chiral:127`) | yes, conversion in `kernel.chiral` | yes | part. `e170_port_twin` checks and no phase runs it | part. `e170_reject_secret_leak` is refused and no phase runs it | no. Phase 12 is unported | no | IMPLEMENTED for the refusal; execution SEEDED, no `crossing-wraps` entry | G | `lowering-and-emit/LE22`, `LE23`; `custody-executes` for execution (OT) |
| ambient authority through globals or environment | | no | part. `Env` is a linear capability (`clock.port:19`). Path naming (`file.port:14`) and raw-`I64` descriptor crossings (`fd.port:34`) are ambient | part, H8 only | no | no | no | no | DESIGNED | J | unrostered. R `tool-authority/TA9`, `TA12`; the reification of `print`, `trace` and the clock is suggested for `enforcement` beside `N25` |

## Resources and termination

| class | how it gets said | J | R | C | P | N | G | M | rung | next | owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| non-termination, unbounded recursion | structural and numeric-measure classifier | no. The verdict is `tot-holdout` text (`totality-check.chiral:131`) | yes, `tot-gate` (`totality-check.chiral:153`), under a `(total)` profile only | yes, `compile-front.chiral:371` | yes, `profile-target.sh:113` | yes, `profile-target.sh:108` | yes, phase 4 | part. `total-clause-dead` (`profile-target.sh:259`) turns off the demand and leaves the classifier | ENFORCED under the opt-in clause. ⚑ *This row said no suite phase fails when it breaks; phase 4 does, measured 2026-10-01* | J; the default flip | `checker-core/CK12` (E11). J unrostered, suggested `checker-core`; the flip is E47, held by no arc (UNS-12) |
| unbounded allocation | cost carried in the type | no | no. The fixed arena traps at run time (`x64/mach.chiral:459`) | n-a | n-a | no | no | no | DESIGNED | J | E38, held by no arc (UNS-05); `memory-discipline/M5` consumes a bound |
| handle and fd leaks | linear resources | yes, `r-usage` | part. `kernel.chiral:645`, `:657`. Raw-`I64` descriptors from `file.port:14` are never linear | yes | yes, `linear-mint.sh:196` | yes, `check-cli.sh:73`, `linear-mint.sh:183`. Six more rejects refuse and no phase runs them | yes, phases 3 and 6 | yes, `qfits-q1-accepts-all`, `close-binder-off` | ENFORCED for capabilities | R, raw descriptors and inheritance | `checker-core/CK20`; `tool-authority/TA1`, `TA4` |
| time or fuel budget exceeded | the cost gradient | no | no | n-a | n-a | no | no | no | DESIGNED | J | E38 (UNS-05). Suggested `enforcement` |

## Data at boundaries

| class | how it gets said | J | R | C | P | N | G | M | rung | next | owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| non-exhaustive branches | case coverage | yes, `jg-nonexhaustive` and `jg-empty-case` (`diag.chiral:105`) | yes, `kernel.chiral:1332`, `:1334` | yes | yes, every root | yes, `diag.sh:173-176` | yes, phase 13 | no. Three gates use the refusal as an oracle and nothing mutates `kernel.chiral:1332` | ENFORCED | M | `enforcement/N11`; the 11 unasserted case arms are `checker-core/CK13` |
| unsound recursive data | strict positivity | yes, `jg-not-positive` (`diag.chiral:113`) | part. `loader.chiral:539` refuses the direct case; a nullary mutual cycle is admitted (PRB-16) | yes | yes, implicitly | no. Nothing in `tools/` or `prog/` produces the refusal | no | no | IMPLEMENTED. ⚑ *This row read `refuses` until 2026-10-01* | R | `checker-core/CK14` (E7), `CK16` (E79) |
| out-of-range values | refinement types, **`I64` only** | yes, `diag.chiral:104-107` | part. `kernel.chiral:1452`. A bound at the `I64` maximum admits 0 (PRB-17); PRB-48 | yes | yes, `recording.sh:277-282` | yes, `recording.sh:278`. `e170_reject_recv_zero` refuses and no phase runs it | yes, phase 30 | no. `recording.sh` M1 to M6 mutate the pricing | ENFORCED in part. ⚑ *`let`-bound results still fail to check, BA-41 and `records/findings.md` FD-02* | R | `checker-core/CK10` (E9); `enforcement/N22` |
| unchecked parse results | declared crossing plus refinements | part, through a refined consumer | part. Only refined consumers check (`sock.port:69`). `str->i64` (`prelude.chiral:150`) maps junk to 0 and has no failure arm | yes | part | part. `e170_reject_recv_zero`, unrun | part. Phase 30 tests a literal | no | IMPLEMENTED in part | J | unrostered. Suggested `errors-as-values` |
| integer overflow, division by zero | | no. `<>` exists (`refine.chiral:11`) and `/` is declared bare (`prelude.chiral:62`) | no. A zero divisor traps with `ud2` at run time (exit 132) and overflow wraps silently | n-a | n-a | no | no | no | none | J | unrostered. Suggested `enforcement`, beside `N22` |
| FFI and ABI signature disagreement | extern declarations checked against the real ABI | part, `jg-extern-nontype` (`diag.chiral:110`), `jg-extern-pure-crossing` (`:112`) | part. The arrow kind is checked (`loader.chiral:471`, `compile-emit.chiral:350`). The declared signature is compared with nothing: a re-typed `str-len` exits 139 and an extra argument is accepted | yes, the arrow kind | yes, `extern-honesty.sh:126-135` | yes, `extern-honesty.sh:102-110` | yes, phase 37 | yes, `m1-load-off`, `m2-emit-off` | ENFORCED for the arrow kind, E204 | R, the signature | E75 (UNS-26). Suggested `enforcement`, beside `N27` |
| config drift | data declared in the file | no | no | n-a | n-a | no | no | no | DESIGNED | J | `file-types/K1` (E163) |

## Compilation fidelity

| class | how it gets said | J | R | C | P | N | G | M | rung | next | owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| miscompilation | typed assembly, checked at instruction level | no. The verdict is `tck-err` text (`tal/check.chiral:47`) | yes, `ck-fn` (`tal/check.chiral:290`), `ck-prog` (`:309`) | no. `tal/check` is outside the closure, and `fold` ships unjudged (`compile-back.chiral:247`) | yes, `tal-check.sh` | yes, `tal-check.sh` | no. Nothing dispatches `tal-check.sh` (`run-tests.sh:356-360`) | part. Three mutants, run by hand | SEEDED. ⚑ *This row said `upper/optimize` was absent too; it joined the closure at `compile-back.chiral:16` and no longer calls the checker* | C | `enforcement/N8` (E18), `N12`; rewrites `N7` (E17), `N23`, `N24`; J `errors-as-values/EV7` |
| non-reproducible build | fixpoint | n-a. The rule is `cmp` | yes, by hand. `bin/chirality-bin` reproduces itself at 1,261,944 bytes, measured 2026-10-01 | n-a | yes, by hand | no | no | no | IMPLEMENTED | G | `lowering-and-emit/LE24`; placement at `records/author-calls.md:113` |

Three things stand between the miscompilation row and being caught. They are
mechanism state rather than failure classes, so they sit here instead of as rows.

| gap | owner |
|---|---|
| types are erased before emit. `erase-fn` strips every `TFn` to a neutral `NFn`, and `emit-elf-m` takes `NFn` only (`compile-emit.chiral:346`) | `enforcement/N6` (E16), `N8` (E18), `N12` |
| effectful and dependent code never lowers, so there is no `TFn` to check. `eff-lower` is reached only through `sig-driver`, which has no importer | `enforcement/N9` (E70), after `N25` |
| no reference semantics ship to check against. `tal/eval`, `tal/spec` and `evidence/interp` have no importer | `enforcement/N13`; the `eval-prim` repair is unrostered. `tal/spec` is `ownership-and-trust/O2` (E71, OT) |

## Concurrency

No row in the tree owns any of these. Live ports are move-only (`open-edges.md:368-371`), which rules races out only while no thread crossing exists.

| class | how it gets said | J | R | C | P | N | G | M | rung | next | owner |
|---|---|---|---|---|---|---|---|---|---|---|---|
| data races | move-only ports. No thread crossing exists in `target-linux.manifest`, and `fork` is locked to fork plus exec (`proc.chiral:4`) | no | no | n-a | n-a | no | no | no | none | J | unrostered. Nearest `memory-discipline/M9` |
| deadlock | expressible today with spawn and pipes | no | no | n-a | n-a | no | no | no | none | J | unrostered. Nearest `tool-authority/TA7`, `TA8` |
| time-of-check to time-of-use | path naming at `file.port:14` | no | no | n-a | n-a | no | no | no | none | J | unrostered. Nearest `tool-authority/TA9` |
| memory ordering | no shared-memory threads exist | no | no | n-a | n-a | no | no | no | none | J | unrostered. Nearest `memory-discipline/M9` |

## What the checker can actually refuse today

Ground truth is the judgment vocabulary, `lib/typing/diag.chiral:99-113`
(38 `Judg` constructors) and `:123-143` (10 `Reason` evidence shapes).

| group | count | negative fixture in a dispatched phase | mutant of the rule | examples |
|---|---|---|---|---|
| type and arity shape | 17 plus `r-mismatch`, `r-arity` | 1 of 17, plus `r-mismatch` and `r-arity` | `r-arity` only | `jg-apply-nonfn`, `jg-tcon-arity`, `jg-type-as-value` |
| case coverage and constructor use | 10 | 1 of 10 | none | `jg-nonexhaustive`, `jg-empty-case`, `jg-dup-branch` |
| refinements, `I64` only | 5 | 1 of 5 | none | `jg-refine-unproved`, `jg-refine-i64` |
| linearity and usage | 4 | 3 of 4 | `r-usage` only | `jg-linear-field`, `r-usage`, `r-linear`, `r-arrow` |
| strict positivity | 1 | 0 of 1 | none | `jg-not-positive` |
| scope and binding | 4 | 1 of 4 | none on a rule site | `jg-var-range`, `jg-esc-binders`, `r-unbound`, `r-redeclared` |
| lowering skips | 1 | 0 of 1. Nothing constructs it | none | `r-skipped` |
| effects | 2 | 2 of 2 | 2 of 2 | `jg-pure-crossing`, `jg-extern-pure-crossing` |

**No constructor exists for termination, bounds, overflow, allocation, ABI
agreement or concurrency.** A rule cannot refuse what the vocabulary cannot say,
so each of those needs a `Judg` arm before it needs a caller. ⚑ *This sentence
named effects too until E171 and E204 added their two arms on 2026-09-30.*

**Five refusals run the other way.** The rule and its gate exist and the verdict
is text. The E76 chokepoint and the H8 profile check build `elf-err` from a
string (`compile-emit.chiral:354`, `:357`), termination answers `tot-holdout`
(`totality-check.chiral:131`), a sheet's fence arrives as relayed text
(`load-batch.chiral:83`), and the floor checker answers `tck-err`
(`tal/check.chiral:47`). `errors-as-values/EV7` rosters the last. The other four
are unrostered.

**A typed refusal is flattened on the shipping path.** Def, declare and extern
refusals become text at `parse.chiral:580` and `:673` and come back wrapped as
`r-relayed` at `load-batch.chiral:81`, so a gate over any of them compares
strings. Only data-group refusals reach `compile-front.chiral` carrying the
`Reason` the rule built.

## The systemic finding, 2026-09-01, re-measured 2026-10-01

The compiler binary is the transitive import closure of `prog/compiler.prog`:
**61 modules**, of which 51 are `lib/**.chiral` totalling **17,566 LOC**, out of
`lib/`'s 95 `.chiral` modules and 26,510 LOC. The other ten are the nine `.port`
registries and `target-linux.manifest`. ⚑ *The 2026-09-04 reading was 60 modules
and 16,736 LOC. `lowering/upper/optimize` joined through
`lib/lowering/compile-back.chiral:16`, which accounts for the module count.*

**Eight** modules of the set this section has always counted are checking
machinery written and absent from that closure. ⚑ *This read nine, with
`lowering/upper/optimize` at 254 LOC; it left the list when it joined the
closure.*

| module | LOC |
|---|---|
| `lowering/tal/check` | 312 |
| `lowering/tal/eval` | 187 |
| `lowering/upper/eff-lower` | 183 |
| `typing/row-infer` | 137 |
| `lowering/tal/spec` | 126 |
| `typing/kernel-core` | 60 |
| `typing/reflect-floor` | 54 |
| `typing/effects` | 46 |
| **total** | **1,105** |

Six more belong in the set and were never counted, which brings it to **14
modules and 1,546 LOC**, 8.8% of the compiler's own size.

| module | LOC | why it counts |
|---|---|---|
| `evidence/interp` | 109 | the source evaluator a value-agreement check needs |
| `module/sig-derive` | 108 | the effect floor's driver chain |
| `module/sig-driver` | 77 | the only importer of `eff-lower`, and itself imported by nothing |
| `memory/mem-region` | 75 | the referent of `(memory region)` |
| `typing/ty-cmp` | 40 | |
| `memory/mem-linear` | 32 | holds `mem-put-checked`, the pool-offset bound |

Verified two ways: no `(import "<key>")` anywhere in `lib` or `prog`, and no
mention of the full module key anywhere in `lib`, `prog` or `tools`. ⚑
`lowering/tal/check` is **importable** beside the compiler (`5b4fb71`) and its
importers are `prog/optimizer-census.prog` and `tools/test/tal-check.sh`, which
BA-26 measures: being loadable and being adopted are two states and only the
first moved.

Absent for good reasons, since the compiler has no use for them: `protocol/`
(3,729), `evidence/` (1,348) other than `interp`, `runtime/` (379),
`capability/` (216), the C backend. `evidence/ddc` is on the
ownership-and-trust track.

**How it happens.** `tools/test/run-tests.sh:444` says it plainly:

> `compile-only: N roots built, N failed -- gates, but asserts nothing`

96 roots of 107 swept go through that gate, measured 2026-09-30 at `2faa028`. A
module that compiles passes it. Nothing asks whether a module is inside the
compiler's import closure. So a checking rule can be written, compile cleanly,
pass the suite, get marked built in the catalog, and
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
adopted by `prog/test-runner.prog`. No element covers the gate itself.

**Every closure scan in the suite asserts the other direction**, that a module
stays outside: `encoding.sh` G5, `recording.sh` R6, `mul-widen.sh` G6,
`render-doc.sh` G9, `matcher.sh` G8, and the undispatched `tal-check.sh` G18.
Three arcs state the closure as their requirement 2 (`checker-core`,
`lowering-and-emit`, `substrate-floor`) and serve it with rows that move modules.
The instrument is unrostered; the suggested home is a `tool` row in
[[arcs/lowering-and-emit-arc]], serving all three.

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

The three are cells **P**, **N** and the closure half of **C**, and the cascade
adds **J**, **G** and **M** around them.

⚑ **Measured 2026-10-01 at constructor grain**, which this section listed as
unmeasured. 13 of the 48 constructors have a negative fixture in a dispatched
phase, and 5 have a mutant of the rule itself that runs. The 22 `*_reject_*`
fixtures are skipped by name at `run-tests.sh:179` and named by no script, and
every one of them refuses at `2faa028`. `lowering-and-emit/LE22` ports Phase 12,
which runs them. Twelve judgments with no fixture were probed on the shipping
binary and all twelve refuse, which puts them at IMPLEMENTED.

## From the principles

[[decisions/decision-full-enforcement]] makes [[goals/enforcement]] claim every
obligation `PRINCIPLES.md` implies. These are the obligations, each one
checkable, with the class row that carries its cascade. Where a goal other than
enforcement owns the obligation, the last column names it.

### P1: to control everything, express everything

| id | obligation | source | class |
|---|---|---|---|
| P1.a | a `sys` op in an unregistered function is refused at one default-deny chokepoint | `docs/decisions/decision-syscall-governance.md:24-40` | calling a syscall the program never declared |
| P1.b | on rung 1 the OS refuses any syscall the permitted set does not name | `decision-syscall-governance.md:42-49` | a syscall issued by a non-chirality path |
| P1.c | a profile attenuates which syscalls one component reaches, as subtyping over the immediate | `decision-syscall-governance.md:51-56` | a dependency exceeding its grant |
| P1.d | who widened the permitted set is recorded where the set is read | `decision-syscall-governance.md:36-40` | a syscall issued by a non-chirality path |
| P1.e | every crossing takes its capability as a parameter; `print`, `trace`, the clock and the environment become porttypes the profile hands to `main` | `docs/decisions/decision-effect-facets.md:20-24`, `:41-49` | ambient authority through globals or environment |
| P1.f | no linear capability is minted from a raw value | `docs/decisions/decision-tool-capability.md:146-150` | a capability forged from a raw value |
| P1.g | a module outside `lib/ports/` that declares a naming crossing is refused | `decision-tool-capability.md:132-144` | a crossing declared outside its registry |
| P1.h | every checking module the compiler ships sits in its import closure, and an assertion refuses its absence | `PRINCIPLES.md:31-32` | a checking rule written and never run |
| P1.i | a tool that judges chirality source is chirality, and something reaches it | `PRINCIPLES.md:30-32` | [[goals/enforcement]] condition 5 |
| P1.j | a module over an untyped referent declares it in its signature, and a pure-looking signature over one is refused | `docs/decisions/decision-b-in-type.md:26-33` | a B referent behind an A signature |
| P1.k | the emitted image carries no segment both writable and executable | `PRINCIPLES.md:37-38` | a writable-executable image |
| P1.l | every caller-indexed byte or string access is checked or refused, and no read sees uninitialized memory | `docs/definitions/trust-boundary.md:104-106` | buffer overread and overwrite; uninitialized read |

### P2: everything is a process, and the type is the whole cost

| id | obligation | source | class |
|---|---|---|---|
| P2.a | a `->` body that applies a `=>` callee is refused at the call | `PRINCIPLES.md:53-58` | IO from something that reads as pure |
| P2.b | an extern declared `->` reaches no crossing | `PRINCIPLES.md:56-57` | IO from something that reads as pure |
| P2.c | the Pi carries an effect row, and a body exceeding its declared row is refused | `decision-effect-facets.md:34-40`, `:77-83` | IO from something that reads as pure |
| P2.d | the row has a typed-assembly shadow and a preserve-check over the effect claim | `decision-effect-facets.md:130-134` | miscompilation, the effectful gap |
| P2.e | usage, time, space and information flow are grades in one semiring, and a term over its grade is refused | `docs/decisions/decision-graded-kernel.md:29-49` | unbounded allocation; time or fuel budget exceeded |
| P2.f | a non-terminating definition is refused with a judgment | `decision-graded-kernel.md:51-58` | non-termination, unbounded recursion |
| P2.g | the compiler evaluates a subterm early only when that subterm is total | `decision-graded-kernel.md:61-64` | a non-total subterm runs at compile time |
| P2.h | a quantity-0 position requires an empty row and totality | `decision-effect-facets.md:127-129` | an effectful or partial term in an erased position |
| P2.i | a closure's quantity follows its capture, so a port-capturing closure is never ω | `decision-effect-facets.md:57-63` | use-after-free, double-free |
| P2.j | a 1-continuation is never dropped; cancel is synthesized and re-checked | `decision-effect-facets.md:64-71` | a continuation dropped or escaping its node |
| P2.k | recoverable and fatal are told apart by structure | `decision-effect-facets.md:188-198` | a continuation dropped or escaping its node |
| P2.l | binding time is a modality in the type | `decision-graded-kernel.md:66-75` | binding time confused |
| P2.m | a suspension never crosses a node | `decision-effect-facets.md:124-126` | a continuation dropped or escaping its node |

### P3: govern the ports, the interior is free

| id | obligation | source | class |
|---|---|---|---|
| P3.a | a program naming a crossing outside its profile's port set is refused at check | `PRINCIPLES.md:84-85` | a crossing outside the port set passes the check |
| P3.b | a loaded artifact cannot widen the resident port set | `docs/decisions/decision-profiles.md:26-28` | a loaded artifact widens the port set |
| P3.c | a profile is valid only when its connectors preserve, its access goes through ports, and its composite covers the requirement | `decision-profiles.md:61-63` | a profile composite fails its requirement |
| P3.d | allocation and stack depth carry a bound | `PRINCIPLES.md:87-90` | unbounded allocation; stack exhaustion |
| P3.e | `lib/ports/` holds crossing declarations, and an extern outside it is refused | `PRINCIPLES.md:98-102` | a crossing declared outside its registry |
| P3.f | information flow holds a lattice grade, and non-interference is a typed proof over it | `docs/definitions/open-edges.md:60-78` | a covert or timing channel |
| P3.g | constant time is checked at the typed-assembly floor | [[status-ledger]], sharpest gap 1 | a covert or timing channel |
| P3.h | an irreversible crossing passes a pre-commit confinement gate | `open-edges.md:447-450` | an irreversible effect escapes unconfined |
| P3.i | an untyped referent enters typed code only as evidence, re-checked by one generic bridge check | `open-edges.md:301-309` | a B referent behind an A signature |
| P3.j | a live port is move-only, and no shared mutable handle crosses one | `open-edges.md:368-371` | data races |

### P4: the safe path should be the cheap path

| id | obligation | source | class |
|---|---|---|---|
| P4.a | with no profile clause the compile refuses an unproven definition unless it is marked partial | `PRINCIPLES.md:144-147` | non-termination, unbounded recursion |
| P4.b | the checked compile is the default path and takes no flag | `docs/decisions/decision-floor-check-per-compile.md:75-78` | a compile path bypasses the check |
| P4.c | declaring a port set is cheaper than declining to | `decision-syscall-governance.md:75-77` | a dependency exceeding its grant |
| P4.d | the minimum tier per axis defaults high, and lowering it is loud | `docs/definitions/split-role.md:92-95` | a below-minimum tier |
| P4.e | no gate enumerates bad sites where a default-deny chokepoint exists | `PRINCIPLES.md:125-126` | the checker rejects safe code unmeasured |
| P4.f | each conservative checker's false-reject tax is measured, and its sacrifice stated | `PRINCIPLES.md:137-142` | the checker rejects safe code unmeasured |

### P5: where proof runs out, split the truth and require agreement

| id | obligation | rung | source | class |
|---|---|---|---|---|
| P5.a | every shipped program is target well-typed under `ck-prog` | T0 | `docs/decisions/decision-preserve-check.md:19-21` | miscompilation |
| P5.b | type preservation holds over every definition that lowers | T0 | `decision-preserve-check.md:21` | miscompilation |
| P5.c | the source and target evaluators agree on value over the definitions that lower | T1 | `decision-preserve-check.md:22` | executors disagree on a value |
| P5.d | a rewrite the optimizer adopts carries value-agreement evidence, or is refused | T1 | [[arcs/enforcement-arc]] requirement 7 | miscompilation |
| P5.e | a definition that does not lower is routed with a stated fate | | `decision-preserve-check.md:94-101` | a definition silently dropped |
| P5.f | detection is never filed as prevention, and each row names its rung | | `PRINCIPLES.md:159-162` | [[goals/presentability]] |
| P5.g | a split is one type: one guarded combine, move-only shares zeroed on drop, reconstruction an effect | T2, T3 | `PRINCIPLES.md:184-189` | [[goals/ownership-and-trust]] |
| P5.h | a plain Shamir split cannot satisfy an integrity requirement | T1 or T3 | `PRINCIPLES.md:176-178` | a below-minimum tier |
| P5.i | a provider below the named minimum does not conform, and the gap shows in the type | | `PRINCIPLES.md:191-195` | a below-minimum tier |
| P5.j | zeroing on drop survives to the typed-assembly floor | T0 | `PRINCIPLES.md:200-204` | secret residue survives drop |
| P5.k | the combine requires disjoint provenance on the threat's axes | | `split-role.md:46-53` | agreement that is correlated |
| P5.l | a member holds only its typed port set | | `split-role.md:36-45` | a covert or timing channel |
| P5.m | divergence is a typed effect the consumer must handle | | `split-role.md:26-27` | a continuation dropped or escaping its node |
| P5.n | foreign code is seated at its honest rung and contained at its port set | | `PRINCIPLES.md:195-197` | a B referent behind an A signature |
| P5.o | certificate strength is named per site | | `docs/definitions/certificate-discipline.md:58-64` | a vacuous certificate |
| P5.p | a read-back divergence on unowned substrate is recovered, and an irreversible effect accounted | | `open-edges.md:427-445` | an irreversible effect escapes unconfined |

### The mediator: the checker, its floor, its agreement

| id | obligation | source | class |
|---|---|---|---|
| M.a | `kernel-spec` is a small human-audited rule table held as data | `docs/decisions/decision-split-checker.md:49-50` | [[goals/independent-judgment]] |
| M.b | `kernel-core` re-checks a certificate from every untrusted producer | `decision-split-checker.md:51-59` | a vacuous certificate |
| M.c | the demanded statement is fixed at the socket | `certificate-discipline.md:42-49` | a vacuous certificate |
| M.d | each artifact carries a derivation the trusted core re-checks step by step | `docs/decisions/decision-self-verification.md:161-167` | a vacuous certificate |
| M.e | lowered output is checked by the floor checker, and `conv` stays narrow | `docs/decisions/decision-erased-word-level.md:39-40` | miscompilation |
| M.f | a trusted-core edit is reviewed alone | `decision-effect-facets.md:84-86` | a process rule; [[arcs/enforcement-arc]] carries it with `N25` |
| M.g | the judgment is frozen at staging, and in-place mutation is refused as unsound | `docs/decisions/decision-reflective-floor.md:27-40` | the running judgment reconfigured |
| M.h | no successor core runs uncertified | `decision-reflective-floor.md:61-64` | the running judgment reconfigured |
| M.i | migrated state conforms to the successor's types | `decision-reflective-floor.md:66-67` | the running judgment reconfigured |
| M.j | succession is initiated by a linear capability | `decision-reflective-floor.md:68-69` | a capability forged from a raw value |
| M.k | the port hand-over at cutover is atomic | `decision-reflective-floor.md:54-57` | the running judgment reconfigured |
| M.l | distinct-formulation judgment cores run on one input, and disagreement is a refusal | `decision-self-verification.md:23-26` | agreement that is correlated |
| M.m | the quorum refuses fewer than two live legs | [[goals/independent-judgment]] condition 3 | agreement that is correlated |
| M.n | the referee compares verdicts and names the two legs that disagreed | `open-edges.md:681-699` | agreement that is correlated |
| M.o | each ordered pair of cores owes an encoding, adequacy and conservativity | `decision-self-verification.md:214-224` | agreement that is correlated |
| M.p | only a strict order of cores exchanges soundness, and a cycle is refused | `decision-self-verification.md:233-238` | agreement that is correlated |
| M.q | `ck-prog` runs on every shipping compile in its own process, and output is withheld on `tck-err` | `decision-floor-check-per-compile.md:33-45` | miscompilation |
| M.r | every compile, run, check and build generation goes through one checked entry | `decision-floor-check-per-compile.md:170-174` | a compile path bypasses the check |
| M.s | a gate goes red when the per-compile check is cut | `decision-floor-check-per-compile.md:176-179` | a compile path bypasses the check |
| M.t | a condition holds the compiler's and the checker's own time and memory | `PRINCIPLES.md:66-69` | the mediator runs over budget |
| M.u | the fixpoint compare runs as a phase, each artifact checked non-empty | `docs/goals/self-hosting.md:33-37` | non-reproducible build |
| M.v | a second, independently produced compiler | `decision-self-verification.md:259-266` | a backdoor survives the fixpoint |
| M.w | the shipped form carries its own re-derivation, and `kernel-spec` has a size budget | `decision-self-verification.md:280-286` | [[goals/ownership-and-trust]] |
| M.x | the reference semantics `tal/spec.chiral` is reached as the golden object | [[goals/ownership-and-trust]] condition 3 | executors disagree on a value |
| M.y | the ledger tells enforcement against error from enforcement against an adversary | [[goals/independent-judgment]] condition 5 | [[goals/independent-judgment]] |
| M.z | several small independent proof checkers run over one proof object | `decision-split-checker.md:81-85` | a vacuous certificate |

### The reader's side

| id | obligation | source | class |
|---|---|---|---|
| DP.a | the folder, the reference interpreter and native code compute one value | `docs/definitions/design-principles.md:37-40` | executors disagree on a value |
| DP.b | a note's tense matches its build status | `design-principles.md:41-43` | [[goals/presentability]] |
| DP.c | no surface form carries two meanings | `design-principles.md:34-36` | `records/author-calls.md:538`, a ruling |

## Classes the principles add

These rows come from the obligations above and had no row before 2026-10-01.
Every cascade cell reads `no` unless the `state` cell says otherwise. Rows on the
ownership-and-trust track are marked OT: build-deferred and planned, per
[[decisions/decision-scope]].

| class | category | obligations | how it gets said | state | next | owner |
|---|---|---|---|---|---|---|
| a writable-executable image | memory | P1.k | a typed seal, mapped writable then sealed executable | `lib/lowering/x64/elf.chiral` emits one RWX `PT_LOAD` ([[status-ledger]], the W^X row) | R | `substrate-floor/SU1` (E20) |
| secret residue survives drop | memory | P5.j | zeroing carried as a property down to the typed-assembly floor | none | J | `custody-executes/CU4` (E40) for the wipe. The floor property is E56, held by no arc. OT |
| a capability forged from a raw value | authority | P1.f, M.j | a linear capability mints only at an open or a receive | `adopt-fd` mints a linear `Fd` from any `I64` (`fd.port:32`) | R | `tool-authority/TA6` on the receive path. The general rule is unrostered, suggested `tool-authority` |
| a crossing declared outside its registry | authority | P1.g, P3.e | a module outside `lib/ports/` that declares a crossing is refused | 21 files outside `lib/ports/` declare an `extern` (`decision-tool-capability.md:135`) | J | `tool-authority/TA12` for five naming crossings. The rest unrostered, suggested `tool-authority` |
| a crossing outside the port set passes the check | authority | P3.a | the port-check is the type-check | refused at emit by H8 (`compile-emit.chiral:356`), after the check has passed | R, at check time | unrostered. Suggested [[arcs/syscall-custody-arc]] requirement 3 |
| a syscall issued by a non-chirality path | authority | P1.b, P1.d | a seccomp default-deny filter derived from the permitted set, and the widener recorded where the set is read | none | R | `syscall-custody/SC3` (E77), `SC4` (E162) |
| a loaded artifact widens the port set | authority | P3.b | the port set is profile-invariant | none | R | `runtime-loading/RL3` |
| a B referent behind an A signature | authority | P1.j, P3.i, P5.n | B carried in the type; one generic bridge preserve-check on entry | inbound verification is CUT ([[status-ledger]], the inbound bridge row) | J | `bridge/C1`, `C2`, `C3`, `C5`; `sys-face/SF20` |
| a profile composite fails its requirement | authority | P3.c | three checks per profile | grants take no subtyping ([[status-ledger]], the subtyping row) | R | `bridge/C1` to `C3` for the ports leg. Whole-assembly conformance is E44, held by no arc (UNS-09). OT |
| a covert or timing channel | authority | P3.f, P3.g, P5.l | an information-flow grade with non-interference as a typed proof; constant time checked at the floor | no port exists for timing, cache or speculation (`PRINCIPLES.md:108-111`) | J | E44, E59, E60, held by no arc (UNS-09, UNS-19, UNS-20). OT |
| an irreversible effect escapes unconfined | authority | P3.h, P5.p | outbound confinement with a pre-commit gate | none | J | E73, held by no arc (UNS-24). OT |
| a non-total subterm runs at compile time | resources | P2.g | `fold`, `specialize` and pregeneration run only total subterms | nothing in `lib/lowering/upper/optimize.chiral` reads totality | R | unrostered. Suggested [[arcs/enforcement-arc]] requirement 7 |
| an effectful or partial term in an erased position | resources | P2.h | a quantity-0 position requires an empty row and totality | none | J | the design of `enforcement/N25` (E39). Unrostered at row grain |
| a continuation dropped or escaping its node | resources | P2.j, P2.k, P2.m, P5.m | one linear closure per continuation; cancel synthesized and re-checked | none | J | `enforcement/N25` (E39) |
| binding time confused | resources | P2.l | a staging modality | nothing represents binding time in a type ([[status-ledger]], the Staging row) | J | E57, held by no arc (UNS-17). OT |
| the mediator runs over budget | resources | M.t | a condition on the compiler's and the checker's own time and memory | none | J | unrostered. Suggested [[arcs/enforcement-arc]] |
| a below-minimum tier | data | P4.d, P5.h, P5.i | a tier carrier per axis, defaulting high | none | J | E74, held by no arc (UNS-25). OT |
| a checking rule written and never run | fidelity | P1.h | a closure assertion over `prog/compiler.prog` | 14 modules, 1,546 LOC, outside the closure (`## The systemic finding`) | G | unrostered. Suggested a `tool` row in [[arcs/lowering-and-emit-arc]] |
| a compile path bypasses the check | fidelity | P4.b, M.r, M.s | one checked entry that withholds output until a spawned checker answers `tck-ok` | 28 scripts under `tools/` call the binary directly (`decision-floor-check-per-compile.md:97-98`) | R | `enforcement/N8` (E18), under that draft decision |
| a definition silently dropped | fidelity | P5.e | every definition's fate stated with evidence | `sk-defunc` blame is built (E187, phase 27). The success-arm fate is design | R | `enforcement/N1` (E184), `N4` (E187) |
| executors disagree on a value | fidelity | DP.a, P5.c, M.x | the folder, the reference interpreter and native code compute one value | `eval-prim` returns 0 for `=i`, `<i` and `<=i` (`tal/eval.chiral:86-95`) where `fold-cmp` computes them (`optimize.chiral:68`) | R | `enforcement/N13`, `N24`. The `eval-prim` repair is unrostered |
| a backdoor survives the fixpoint | fidelity | M.v | diverse double-compiling | none | R | `ownership-and-trust/O1` (E53). OT |
| the running judgment reconfigured | the checker | M.g, M.h, M.i, M.k | the judgment frozen at staging; succession certified | `typing/reflect-floor` is written and has no importer | C | `independent-judgment/J2` wires the model. Succession is E45, held by no arc (UNS-10). OT |
| a vacuous certificate | the checker | M.b, M.c, M.d, M.z, P5.o | the demanded statement fixed at the socket | none | J | `independent-judgment/J5`. E52 is held by no arc and by no lens row. OT |
| agreement that is correlated | the checker | P5.k, M.l, M.m, M.n, M.o, M.p | distinct-formulation cores; a referee naming the disagreeing legs; a strict order for soundness | `ddc-bad-quorum` exists in `lib/evidence/ddc.chiral` and no fixture produces it | G | `independent-judgment/J1`, `J3`, `J4`. The referee and the core order are unrostered, suggested [[arcs/independent-judgment-arc]] |
| the checker rejects safe code unmeasured | the checker | P4.e, P4.f | each conservative checker's tax measured, its sacrifice stated | measured for `ck-prog` at 38,333 of 38,333 accepted (`decision-floor-check-per-compile.md:114-116`), and in part by `enforcement/N12`, `N15`, `N16`, `checker-core/CK10` | a measurement per checker | unrostered in general. Suggested [[arcs/enforcement-arc]] requirement 3 |

## The cascade

Where each cell comes from. The cells restate rules the tree already held, so
none of them is new.

| cell | source |
|---|---|
| **J** | `## What the checker can actually refuse today`: a rule cannot refuse what the vocabulary cannot say |
| **R**, **C** | [[status-ledger]]'s rungs: built and adopted are two states, and SEEDED means nothing reaches it |
| **P**, **N** | `## Test discipline this implies`, items 1 and 2 |
| **C**, the closure half | `## Test discipline this implies`, item 3 |
| **G** | [[status-ledger]], ENFORCED: a check in the kernel, the loader or the suite fails when the property stops holding |
| **M** | [[goals/enforcement]] condition 4, a named mutant that is actually run |

A cell reads `yes` with its citation, `part` with what is missing, `no`, or
`n-a` where the cell has no meaning for the class.

**Superseded 2026-10-01: the state column.** Each table carried one `state`
cell, read by this legend. The cascade replaced it because one word could not
say which cell was missing.

| state | meant | cascade reading |
|---|---|---|
| **refuses** | in the compiler binary, with a judgment, and it rejects the bad case | J, R and C; says nothing of P to M |
| **partial** | some of the class is caught | R reads `part` |
| **unwired** | the module is written and is **not in the compiler binary** | R without C, SEEDED |
| **design** | decided on paper, no module | DESIGNED |
| **none** | nothing exists | every cell `no` |
| **by construction** | the language has no way to express the failure | `n-a`, and the row names what would break it |

⚑ **Unwired was the important one, and it is the C cell.** Built and unreached is
a separate state from unbuilt, and `## The systemic finding` measures it.

## Counts, 2026-10-01

**54 classes**: the 28 the six categories carried, and 26 the principles add.

The 28, by rung:

| rung | classes |
|---|---|
| ENFORCED, in whole or in part | 9 |
| IMPLEMENTED | 5 |
| SEEDED | 1 |
| DESIGNED | 4 |
| none | 8 |
| by construction | 1 |

The 28, by the next cell missing:

| next | classes |
|---|---|
| J | 16 |
| R | 8 |
| C | 1 |
| G | 2 |
| M | 1 |

**One class is fully enforced**, IO from something that reads as pure, on its
one bit: every cell from J to M reads `yes`. Sixteen of the 28 have J as the
next cell, that one included for the effect row beyond its bit. Of the 26 the
principles add, 9 are OT and the other 17 sit at `none` or `part`.

⚑ *The 2026-09-01 counts read: 28 classes, 6 refuses, 5 partial, 3 unwired, 2
design, 1 by construction, 11 none.*

⚑ Deduplicated 2026-09-01. Five rows came out. "FFI signature disagreement" and
"link and ABI mismatch" were one class written twice. "Memory discipline per
program", "effectful and dependent code never lowering", "type information
discarded at codegen" and "reference semantics to check against" are features and
mechanism state. They moved into the rows and notes they belong to.
