# chirality

This is a passion project. There is 0 straightforward way to introduce where I come from on this project.

The best way I can guide one through it is by explaining how I got here. The thinking started with being upset at how
much mental running around it is to achieve security, and how backwards that relationship is. Why do I need different
stacks at any level for that? How could it even be secure having to trust so many? This sparks a cascade of questions, whose
answers all point towards the same rabbithole, which is the extent that virtually all code in any environment is insecure,
even despite the efforts you can make.

The peak of the arc is this project. This is the thing I am creatively redirecting my anger at it realizing it is the case that we
have discovered and genuinely implemented more than enough to know that we can make a programming language that could solve literally
any legitimate complaint with a programming language that exists.

Pre-solve all non-logic bugs? If it's not logic its mechanical. If it's mechanical its
computable. The wiggle room there really favors us.

Why is the checker something you get instead of something you write? Every language ships a
fixed set of refusals and calls that a type system. If you can express anything you can
express the checker too. Then a bug class comes off the list because someone did the work,
not because a version shipped.

One language the whole way down? Every layer gets held to a different constraint, so nobody
tries. Hold one language to all of them at once and either it survives or you find out
exactly where it didn't. Compiler, checker, emitter, runtime, tooling, data. Same language.

Why is `unsafe` a keyword? Because the type system ran out of things it could say, and the
language handed you a door instead of a word. Give the dangerous thing a type and there is
no door to reach for.

See everything a program can touch? Enumerating what it outputs is undecidable. Enumerating
how it reaches outside itself is finite. That is a far smaller question and almost nobody
asks it. Time and memory count as reaching out too.

Proof you don't pay for? It runs at compile time and gets erased before emission. You were
picturing it running.

How much do you actually have to trust? Ours is 1,823 lines. Everything above it is text
that core checked. That number is the whole argument, and it is the number to attack.

**It self-hosts.** The compiler is written in chirality and
compiles itself to a byte-identical copy. No Python runs in the compile, check
or run path.

## Start here

| you are | go to |
|---|---|
| deciding whether this is interesting | [The questions](#the-questions) |
| wanting to run it | [Try it](#try-it) |
| reading the source | [The tree](#the-tree), then [`MAP.md`](MAP.md) for the contract it follows |
| asking what actually works | [Claims, state and limits](#claims-state-and-limits), then [status-ledger](docs/definitions/status-ledger.md) |
| reading the design | [`docs/index.md`](docs/index.md), the hub of a linked note base |
| about to change something | [working-discipline](docs/definitions/working-discipline.md), then the arc in [`docs/arcs/`](docs/arcs/) that owns the work |

## Try it

```
git clone https://git.shredbox.rip/shred/chirality.git
cd chirality
ln -s "$PWD/bin/chirality" ~/.local/bin/chirality
```

Four subcommands: `compile`, `run`, `check`, `test`.

```
# the suite: one command, zero Python
$ chirality test
  → assertions: 321 passed, 0 failed
  → compile-only: 87 roots built, 0 failed
  → chirality test: gate PASSED

# source to a native ELF, compiled and run
$ echo '(def main (-> I64 I64) (lam (n) 42))' > hello.chiral
$ chirality run hello.chiral --entry main
  → exit code 42
```

`chirality check` is the compiler's own front end with the ELF thrown away. One
front end, so there is no second checker to drift. Each demo is a file of two to
four lines. Open it and see exactly what was checked.

```
$ chirality check prog/demo/_ref.chiral      # refinement: out of range
  → load: cannot prove refinement            # exit 1
$ chirality check prog/demo/_ref2.chiral     # the same program, in range
  → chirality check: prog/demo/_ref2.chiral OK
$ chirality check prog/demo/_type.chiral     # arity: 2-arg type, 1-arg lambda
  → load: type mismatch                      # exit 1
$ chirality check prog/demo/_eff.chiral      # the `=>` crossing rides in the type
  → load: type mismatch                      # exit 1
```

⚑ Honest scope on `_eff.chiral`, measured 2026-08-25. That refusal is an
**argument** mismatch: `put : (=> Str Unit)` handed an I64. Repair it to
`(put "x")` under the same `(-> I64 Unit)` signature and it compiles and prints.
The compiler carries the `->`/`=>` bit and does not yet refuse a `->` body that
calls an `=>` one. That gate is element E171, unbuilt.

Bigger programs are in `prog/demo/`: `passman-min` (a secret has no structural
path to a socket), `tomodachi` (an effect-gated behavior pack), `wl-client` (the
Wayland wire codec). `prog/samples/` holds 69 small programs the suite sweeps.

## The questions

Seven, from the wanting side. Each answer opens by taking a position, gives the
design goal underneath it, and ends with a table of what is built and what its
limit is.

1. [What bugs could a language inherently remove?](#q1)
2. [Why does one stack need half a dozen languages that share nothing?](#q2)
3. [Could escape hatches be made into checked routes?](#q3)
4. [Does a language with strong opinions have to fight you?](#q4)
5. [Why is it so hard to see what a program can actually do?](#q5)
6. [What is the smallest thing you would have to trust?](#q6)
7. [Does proof have to be costly or slow?](#q7)

### Q1

**What bugs could a language inherently remove? Could debugging be made purely
about logical bug solving?**

**The goal.** [`goals/enforcement`](docs/goals/enforcement.md): what is built is
gated, and the compiler checks what it claims to check. That turns the question
into a narrower one. A bug class comes off the list when it can be stated as a
judgment and a gate fails when the judgment stops holding. Anything short of
that is a bug the language happens to catch today.

Some of them, and the set is open. A failure you can name as a class is a
failure a checker can refuse, and because the language can express its own
checker the list is worked rather than given.

| category | what refuses today | how far it goes |
|---|---|---|
| memory and ownership | a linear binder used twice or dropped, a linear field | quantities carry it. There is no null in the language to dereference. Buffer bounds refuse nothing, and `str-sub` reads past its own buffer |
| data at boundaries | non-exhaustive and duplicate branches, an empty case, a datatype with a negative recursive occurrence, an unproved refinement | nine judgments. Refinement is `I64` only. Integer overflow and division by zero have none |
| effects and authority | a crossing outside the declared profile port set, refused at emit | `compile-emit.chiral:300`. A `->` body that calls an `=>` one has no judgment at all, which is E171 |
| resources and termination | nothing | no termination judgment exists. The classifier is written and nothing imports it |
| compilation fidelity | nothing on the shipping path | the typed-assembly floor checker exists and the compile never calls it |
| concurrency | nothing | nothing in the tree points at it |

Three of the six refuse something today and three refuse nothing. The vocabulary
is 38 named judgments in `lib/typing/diag.chiral`, and what it does not contain
is the more useful half of the answer.

The residue is whether your specification says what you meant. Intent stays
outside the checker. That is the logical bug.

⚑ **Honest limits.** Three of the six categories refuse nothing, so an open set
is a program of work rather than a property the language has today. The six-way
split is a draft and `docs/definitions/bug-classes.md` does not exist, so there
is no settled taxonomy to measure the claim against. Naming a class and checking
it well are different achievements: refinement refuses out-of-range values for
`I64` and for no other type. And every one of the 38 judgments is enforcement
against error. An adversary who controls the source is outside the reach of all
of them.

### Q2

**Why does one working stack need half a dozen languages that share nothing?**

**The goal.** [`goals/self-hosting`](docs/goals/self-hosting.md) and
[`goals/self-tooling`](docs/goals/self-tooling.md): the language compiles and
checks itself, and it is good enough to write its own tooling with no Python
left. A stack fragments because each layer is held to a different constraint, so
the test of one language is whether it survives being held to all of them at
once.

Chirality covers the compiler, the checker, the emitter, the runtime, the
tooling and the data.

| layer | written in chirality as | state |
|---|---|---|
| the compiler | `prog/compiler.prog` over `lib/lowering/` | self-hosting, byte-identical fixpoint at generation one |
| the checker | `lib/typing/`, 3,227 lines | on the path of every compile |
| the emitter | `lib/lowering/x64/emit.chiral` | emits the shipped ELF |
| the runtime | `lib/runtime/`, 3 modules | |
| the tooling | `prose-lint`, `paren-audit`, `resolve`, `test-runner`, `wield` | 9 Python tools left in `tools/`, the target is zero |
| config and data | `.manifest`, 2 files in the tree | resolves as an import target. The loader does not check the declared-data property that makes it data, which is E163 |
| a frozen port set | declared inline, `(profile name (ports ...) (target t))` | refuses at emit, `compile-emit.chiral:300`, gated by `tools/test/profile-target.sh` |

File extensions are a kind rather than a dialect. The end state is that a kind is
parsed differently while staying the same language:

- a manifest can be written and turned into code, and code back into a manifest
- a `.manifest` is a view of the code, structured for its purpose as a view
- the same applies to `.protocol`, `.grammar` and more

⚑ **Honest limits.** One language holds for the compile, check and run path. It
does not hold for the tooling: 14 Python files remain across the tree, 4,936
lines, against a target of zero. `.manifest` resolves as an import target and
nothing checks that its contents are data, so the kind is a naming convention
until E163. `.protocol` is minted as E183 and unbuilt, `.grammar` is named
nowhere in the tree, and the `.profile` extension `MAP.md` names has zero files.
The round-trip law that would make a view and its code the same artifact is
`parse(source(v)) == v` in [`arcs/file-types`](docs/arcs/file-types-arc.md), and
it is unbuilt for both carriers.

### Q3

**Could escape hatches like `unsafe`, `any` and raw casts be made into checked
routes?**

**The goal.** [`goals/enforcement`](docs/goals/enforcement.md). A hatch exists
because the type system has something it cannot express, so the language gives
you a way out of the type system instead. The dangerous thing gets a type here
and there is no exemption to reach for.

Declare it as a crossing. A port registry mints the capability, the crossing is
named, and a program that calls a crossing its profile froze out is refused at
emit.

| what | state | where |
|---|---|---|
| port registries | 9 `.port` files, one per crossing family | `lib/ports/` |
| the profile port set | refused at emit | `compile-emit.chiral:300`, gated by `tools/test/profile-target.sh` |
| capability types | `lincoll`, `secret`, `session` | `lib/capability/` |
| the crossing-to-wrapper table | one entry per lowered crossing | `lib/lowering/tal/crossing-wraps.chiral` |

⚑ **Honest limits.** The refusal is at emit rather than at check, so a program
that names a frozen crossing type-checks and fails later. `ports/ports.chiral`
has 107 importers, which makes the facade a wide seam rather than a narrow one.
Timing, cache pressure and speculation are reaches with no port, so the closed
set is closed only over the crossings someone thought to declare. And
`http-request`, `backend-open` and `chat-open` have no wrapper entry at all,
so a declared crossing can compile and have nothing to lower to.

### Q4

**Does a language with strong opinions have to fight you?**

**The goal.** [`goals/readable-surface`](docs/goals/readable-surface.md): the
surface stays convenient without buying it back in escape hatches. It is stated
against a failure mode, and the failure mode is the question: an annotation
everyone writes is an escape hatch with a polite name.

Not really. What makes an opinionated language hard is the amount you have to
hold in your head. Strong typing already exists to mechanically exclude
categories of failure, and it still leaves all of the typing to you every time.
The bit here is that if you can express anything, you can express the checker
too. Error handling becomes something you extend, one bug class at a time, until
the primitives cover it.

`paren-audit` is the small version, 244 lines of chirality. Break a paren and it
names the form, the line it opens on, and the delta. The next step is a tool that
repairs the file in place, and at that point unbalanced parens stop being
something you consider at all. That is the method: name the class, build the
primitive, stop paying attention to it.

| what | state | where | limit |
|---|---|---|---|
| usage on binders | enforced, gated | `lib/typing/qtt.chiral`, Phase 6 | |
| refinement types | enforced, gated | `lib/typing/refine.chiral` | `I64` only, `jg-refine-i64` |
| totality as the default | written, unreached | `lib/typing/totality.chiral` | zero importers, no termination judgment in `diag.chiral` |
| `->` against `=>` | carried, refused nowhere | `lib/typing/effects.chiral` | E171 |
| `paren-audit` diagnosis | built, runs | `prog/paren-audit.prog` | reports a count where a position is wanted |
| `paren-audit` repair | not built | | needs P1 spans and P4 addresses, both `UNASSIGNED` in [`arcs/text-tools`](docs/arcs/text-tools-arc.md) |

Where the checker is wired the load is off you. Where it is not, the shape is
light because nothing is weighing it.

⚑ **Honest limits.** Two of the four typing rows are unreached, so on those the
low ceremony is absence rather than design. The repair half of the paren-audit
escalation needs P1 spans and P4 addresses, neither of which is assigned to an
element. And the claim is about load rather than about correctness: a checker you
never argue with may simply have stopped looking.

### Q5

**Why is it so hard to see what a program can actually do?**

**The goal.** [`goals/ownership-and-trust`](docs/goals/ownership-and-trust.md)
and [`goals/enforcement`](docs/goals/enforcement.md). Enumerating what a program
outputs is undecidable. Enumerating how it can reach outside itself is finite,
and languages make the second hard by leaving reach implicit in whatever a
library happened to link.

The crossings are closed and named, so a module's reach is the set of boundaries
it declares. Time and memory are crossings too, which is how a regex that pins a
core stops reading as harmless.

| what | state | where |
|---|---|---|
| crossings, declared per family | 9 registries | `lib/ports/` |
| space as a crossing | arena, region, linear and two allocators | `lib/memory/` |
| a profile's frozen port set | refused at emit | `compile-emit.chiral:300` |
| the module datasheet, reach per module | not built, E161 | Phase 8 is unported and prints its reason every run |

⚑ **Honest limits.** A profile declares reach for a whole target rather than per
module, and the datasheet that would give a reader one module's reach is E161 and
unbuilt, so today the answer is assembled by hand from imports. Timing, cache
pressure and speculation have no port and are named open. `ports/ports.chiral`
has 107 importers, so most of the tree holds the facade rather than a narrow
capability.

### Q6

**What is the smallest thing you would have to trust to trust the whole
language?**

**The goal.** [`goals/independent-judgment`](docs/goals/independent-judgment.md).
This one has a number for an answer rather than an assumption to overturn.

A judgment core, and everything above it is text that core checked. The surface
is elaborated into a small calculus before checking, so convenience syntax has
nothing left to smuggle.

| what | lines | note |
|---|---|---|
| the judgment core: `kernel` + `kernel-core` + `qtt` + `refine` | 1,823 | the number the question asks for |
| all of `lib/typing/` | 3,227 | the core plus elaboration, inference and diagnostics |
| `lib/` and `prog/` | 51,084 | everything the core checks |

⚑ **Honest limits.** "Small enough to read in a sitting" is optimistic for 1,823
lines of dependently typed code, and that claim is flagged and unresolved.
`kernel-core.chiral` and `reflect-floor.chiral` both have zero importers, so part
of what is counted as the core is written and unreached. The typed-assembly floor
below the core has a checker the compile never calls, so the trust argument stops
where emission begins. And the goal this answers has no arc: nothing in the tree
currently works toward it.

### Q7

**Does proof have to be costly? Does proof have to be slow?**

**The goal.** [`goals/enforcement`](docs/goals/enforcement.md). Proof feels slow
because you picture it running. It runs at compile time and is erased before
emission, so there is no runtime proof object to pay for. That is a different
category rather than an optimisation.

Quantity-0 binders are erased before runtime and types are erased before emission,
so the checking does not ride along.

| what | measured | where |
|---|---|---|
| against `gcc -O0` | 2 to 6 times faster | three micro-kernels, 2026-08-01 |
| against `gcc -O2` | 1.37 to 8.4 times behind | same, the honest optimised-C reference |
| erasure | q0 binders before runtime, types before emission | `lib/typing/qtt.chiral` |

⚑ **Honest limits.** The same erasure that makes proof free at runtime is why the
typed-assembly preserve check never runs: the types it would check are gone by
then. The benchmark harness was Python and did not survive the doc hoist, so
these numbers cannot be re-measured in this tree today and stand as a dated
record. Cross-side ratios only: absolute times do not travel off the measurement
guest.

## How goals are handled

Three tiers. A **goal** is a broad thing the project claims it is doing. An
**arc** is the list of elements serving one goal, carrying that goal's
requirements and its own resume state. An **element** is one catalog item, an
`E#`. An arc names exactly one goal and an element belongs to exactly one arc.

Three rules keep it a record rather than an ambition:

- **A goal cites where the project already claims it.** Writing a new ambition is
  an author call. An arc serving a goal nobody has written down puts `UNWRITTEN`
  in its goal field.
- **A goal carries no build state.** What is built sits on four rungs in
  [status-ledger](docs/definitions/status-ledger.md), so a goal cannot grade
  itself.
- **An element is minted into a reserved band.** An arc without one writes
  `UNASSIGNED` and stops, because naming work that has no number is a phantom
  dependency.

| goal | arcs | state |
|---|---|---|
| the language compiles and checks itself | none open | held, maintained by the build rule |
| chirality writes its own tooling, and no Python remains | `text-tools`, `zero-python` | in flight. Neither arc has a reserved block |
| the surface is convenient without buying it back in escape hatches | `diagnostics`, `file-types` | in flight. `E184-E189` and `E190-E195` |
| what is built is gated, and the compiler checks what it claims | `enforcement` | in flight. `E184-E189`, shared with `diagnostics` |
| what this repo says about itself is true | `baseline-alignment`, `binary-split`, `presentability` | in flight. None of the three has a reserved block |
| judgment that does not rest on one formulation | none | stated and unbuilt. It has no arc, and nothing in the tree works toward it |
| the ownership and trust model | none | deferred by author decision |
| full genuine local AI on small models | three drafted, none open | blocked on two author calls in [`records/author-calls.md`](records/author-calls.md) |

⚑ Five arcs of nine cannot mint an element, because `baseline-alignment`,
`binary-split`, `presentability`, `text-tools` and `zero-python` have no reserved
block. One goal has no arc at all.

## Scope

Current work is self-hosting only: the language compiling and checking itself.

The ownership and trust model is a separate track, deferred and built in its own
lane: the re-bootstrap climb, DDC, the secure datum model, the register root, the
cascade. [decision-scope](docs/decisions/decision-scope.md) draws the line.

⚑ **Honest limits.** External judgment is cut: the Rocq leg, the CompCert leg,
the Python oracle. What replaces them is three semantically distinct judgment
cores that must agree, and that is unbuilt. So every rung in the ledger is
enforcement against error, and an adversary who controls the source is outside
all of it.

## Claims, state and limits

| claim | state today | limit | proposal |
|---|---|---|---|
| everything lowers to typed assembly | eligible defs lower to typed SSA in every compile | types erased before emit, the preserve check is never called, effectful and dependent code stays upper, the fraction is unmeasured | measure the ratio, build E70, wire `ck-fn` |
| every unit is a process with a type | the pure/process bit is carried through the front end | the three refusing rules have zero callers | E171 |
| cost is in the type | QTT and refinement run in the checker | `totality.chiral` has zero importers | wire E11, or drop termination from the claim |
| crossings are named and closed | 9 port registries, the facade has 107 importers | timing, cache pressure and speculation have no port | name it open |
| readable and self-hosting | self-hosts, byte-identical fixpoint | 14 Python files remain, 4,936 lines. Kernel and runtime rows are design | E173, E148, E150 |
| judgment frozen, the rest re-checkable | `reflect-floor.chiral` and `kernel-core.chiral` are written | zero importers | wire, or mark seeded |

## The tree

The extension is the file's kind and the directory is its role. Subject matter
is neither, so there is no `stdlib/` and no `compiler/`.
[`MAP.md`](MAP.md) is the contract.

| | |
|---|---|
| [`lib/`](lib/) | 92 modules. `prelude` `typing` `surface` `module` `lowering` `ports` `capability` `memory` `runtime` `protocol` `evidence` |
| [`prog/`](prog/) | what chirality ships, as distinct from what it is, plus `demo/` `samples/` `scriba/` `manas/` `agent/` |
| [`bin/`](bin/) | `chirality` is the CLI front door. `chirality-bin` is the compiler: a blob on stdin, an ELF on stdout |
| [`tools/`](tools/) | one folder per tool. Nine of them are the Python still being replaced |
| [`docs/`](docs/) | the design base and the element pipeline |
| [`records/`](records/) | what we measured about ourselves |
| `.planning/` | the agent tier: navigation, protocol, queues |

### Reading the documentation

`docs/` is a linked note base, one idea per note, entered at
[`docs/index.md`](docs/index.md) and linked by `[[slug]]` rather than by path.

| tier | holds |
|---|---|
| [`definitions/`](docs/definitions/) | one entry per named concept, 50 of them |
| [`decisions/`](docs/decisions/) | one settled fork per entry, carrying its reason |
| [`banks/`](docs/banks/) | the depth tier: one concept refracted into its shards and their homes |
| [`goals/`](docs/goals/) and [`arcs/`](docs/arcs/) | eight goals, and the arc of elements serving each. An arc file carries its own resume state |
| [`elements/`](docs/elements/) | the catalog, the ledger, and one SPEC per element |
| [`examples/`](docs/examples/) | one worked example per element, conventional approach beside the chirality one |
| [`records/`](records/) | a claim beside its measurement, with a state and a date |

Two documents are written for an agent rather than a person and both are
tracked: [`CLAUDE.md`](CLAUDE.md) and [`.planning/README.md`](.planning/README.md),
which maps tone, placement, workflow and dispatch.
[decision-ai-tier](docs/decisions/decision-ai-tier.md) draws that line.

## Rebuilding the compiler

The existing binary builds the next one. Nothing replaces itself in place.
[working-discipline](docs/definitions/working-discipline.md) is the full rule.

```
. bin/chirality-resolve.sh
chirality_blob_file "lib:prog" prog/compiler.prog > /tmp/blob.chiral
(ulimit -s unlimited; bin/chirality-bin < /tmp/blob.chiral > /tmp/C1) && chmod +x /tmp/C1
[ -s /tmp/C1 ] && (ulimit -s unlimited; /tmp/C1 < /tmp/blob.chiral > /tmp/C2) && cmp /tmp/C1 /tmp/C2
```

The `-s` test is load-bearing: two empty files compare equal, and a fixpoint on
nothing proves nothing. A fixpoint also shows stability and says nothing about
correctness, since a compiler can reproduce itself while being wrong the same
way twice.

## Measured performance

Narrow and dated: [RESULTS-2026-08-01](docs/benchmarks/RESULTS-2026-08-01.md).
The numbers and their limits are in [Q7](#q7).

The remaining gap is attributed pass by pass, and part of the optimizer is
*trait-native*: transforms licensed by facts the checker proves. Totality-licensed
compile-time evaluation, refinement and constant guard elision, dense-tag tables,
Euclidean strength reduction. See [TRAIT-OPTS](docs/benchmarks/TRAIT-OPTS.md).

## About this repository

This is the public mirror of a private working repo, and some older commits
reference paths that are missing here. That is a history filter at work.

## License

[AGPL-3.0-or-later](LICENSE.md), with a
[runtime exception](LICENSE.EXCEPTION.md).

**Programs you compile with chirality are yours.** The compiler emits parts of
itself into every binary it produces, so the exception lifts the copyleft from
your program. Build it, sell it, ship it closed. The exception stops only at a
work that is itself a chirality compiler.

**Changes to chirality are not.** Modify the compiler and convey it, or run it
as a service, and AGPL section 13 asks for your source back.

This replaced Business Source License 1.1 on 2026-08-31. BUSL forbade selling
chirality as a product or hosting it as a service, and no OSI-approved license
can carry that clause: the Open Source Definition forbids restricting fields of
endeavor. AGPL substitutes the nearest achievable thing, which is that a
competitor may do it and must publish their source.
[decision-license](docs/decisions/decision-license.md) has the full reasoning
and the honest limits.
