# chirality

This project is 3 broad things:
1. A typing, judgement, and lowering arrangement for
2. An upper and lower level programming language
3. And a methodology + set of tools to reflect the intended use of the previous

This problem is a production of my anger at many things, but namely:

How is anything considered secure when being secure generally means a variety of
languages meant to cover where the rest lack?

Why do programming languages let you do unsafe things, and why do the
languages that don't, not help you deal with the extra mechanics?

And most importantly: **Why does nothing recognize how required a trait composability is?**

For me, the dissapointing but exciting thing here is that we have already done
more than enough in programming to know that these complaints can be solved.

Some examples of the lense I see this through:

**Pre-solve non-logical bugs?** Non-logical bugs are mechanical solve guaranteed.
The bit here is that if something mechanical is wrong, it must be able to be
expressed uniquely from the correct version. This is because in chirality,
the goal is that everything is a type carried from upper to lower before translation
to machine code, against a dependently typed, QTT lineage, refinement carrying judgment core.
[→ enforcement](docs/goals/enforcement.md), [→ bug-classes](docs/definitions/bug-classes.md)

**Why is the checker something you get instead of something you write?** Every
language ships a fixed set of refusals and calls that a type system. If you can
express anything you can express the checker too. Then the refusal set is
anyone's to extend at any time, in the same language everything else is done in.
[→ readable-surface](docs/goals/readable-surface.md)

**Why is nothing one language the whole way down?** Every layer gets held to a
different constraint, so nobody tries. Hold one language to all of them at once
and either it survives or you find out exactly where it did not. Compiler,
checker, emitter, runtime, tooling, data. Same language.
[→ self-hosting](docs/goals/self-hosting.md), [→ self-tooling](docs/goals/self-tooling.md)

**Why is `unsafe` a thing we let happen?** Because the type system ran out of
things it could say, and the language handed you a door instead of a word. Give
the dangerous thing a type and there is no door to reach for.
[→ enforcement](docs/goals/enforcement.md)

**Why is it hard to see everything a program can touch?** Enumerating what it
outputs is undecidable. Enumerating how it reaches outside itself is finite.
That is a far smaller question and almost nobody asks it. Time and memory count
as reaching out too.
[→ enforcement](docs/goals/enforcement.md), [→ ownership-and-trust](docs/goals/ownership-and-trust.md)

**Can you have proof without giving up speed?** Checking runs at compile time and
is erased before emission. Nothing about it survives into the binary.
[→ enforcement](docs/goals/enforcement.md)

**How much do you have to trust to trust an entire language?** For chirality,
1,823 lines. Everything above it is text that core checked. The bit here is everything 
is a type and port, carried from upper to lower, in a system focused on port boundaries.
[→ independent-judgment](docs/goals/independent-judgment.md)

**It self-hosts.** The compiler is written in chirality and compiles itself to a
byte-identical copy. No Python runs in the compile, check or run path. A
fixpoint shows stability and says nothing about a logic-level bug, so treat it
as a floor rather than a result.
[→ self-hosting](docs/goals/self-hosting.md)

## Where this is

Two months into implementation. It self-hosts to machine code with no external
library, which is a trajectory that gives me a lot of hope for this project.

Current labor is enforcing the model end to end: QTT from the upper layers down
through lowering, and a trusted core and lowering modular enough that someone
can take both and build any product of the language on them. Next is the
ownership and user security core, which makes identity another layer of the
model instead of a thing bolted on top. Two gaps sit between those focuses. Text
tools and file types need straightening up, and there is no crypto yet.

Much of what follows is a goal rather than a shipped thing.
[Claims, state and limits](#claims-state-and-limits) is the table that separates
the two, and every ⚑ in this file marks a limit that is real today.

## Start here

| you are | go to |
|---|---|
| deciding whether this is interesting | the questions at the top, then the goal each one cites |
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

The suite figures are the last measured run, 2026-09-01, recorded in
[status-ledger](docs/definitions/status-ledger.md). Two compiler changes are
built with verified fixpoints and unpromoted, so a run today may differ.

`chirality check` is the compiler's own front end with the ELF thrown away. One
front end, so there is no second checker to drift. Each demo is a file of one to
three lines. Open it and see exactly what was checked.

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

⚑ `prog/demo/` is read by nothing under `tools/test/`, measured 2026-09-03, so
those three are ungated: open them and run them yourself. The tomodachi target
is parked and its client has never spoken to a live compositor
([target-tomodachi](docs/definitions/target-tomodachi.md)).

## What the project knows about itself

Four lenses, each fully enumerated and each row citing what it is about
([decision-four-lenses](docs/decisions/decision-four-lenses.md)):

| lens | holds | the test |
|---|---|---|
| **problem** | the tree does something wrong | a fix is owed |
| **gap** | something wanted that nothing schedules yet | it could be scheduled today |
| **limit** | a shortfall against what the project claims | it bounds a cited claim |
| **unspoken** | territory with no stated intent | nobody has ruled on it |

Three of the four sit on one chain: unspoken becomes a gap when the work is
wanted, a gap becomes a roster row when an arc takes it, a roster row mints.
Every row also carries whether the author has been over it, and their words when
they have. [`records/lenses/`](records/lenses/) holds them and
[OVERVIEW](docs/definitions/OVERVIEW.md) is the generated view across all of it.

## How goals are handled

Four tiers. A **goal** is a broad thing the project claims it is doing. An
**arc** is the work serving one goal, carrying that goal's requirements, its
roster and its own resume state. A **roster row** is one unit of work, cited as
`<arc>/<id>` before it has a number. An **element** is one catalog item, an
`E#`. An arc names every goal it serves, goals and arcs relate many to many, and
an element belongs to at least one arc: one whose components serve two goals
sits in both.

**Minting is the last step.** A roster row is worked up into a
design under [`docs/arcs/parts/`](docs/arcs/parts/), and it gets an `E#` only
when that design passes audit, because a catalog row demands title, reference,
reference class, rationale, category, module and track at the moment least is
known. [decision-design-before-mint](docs/decisions/decision-design-before-mint.md)
settled that on 2026-09-05.

Three rules keep it a record rather than an ambition:

- **A goal cites where the project already claims it.** Writing a new ambition is
  an author call. An arc serving a goal nobody has written down puts `UNWRITTEN`
  in its goal field.
- **A goal carries no build state.** What is built sits on four rungs in
  [status-ledger](docs/definitions/status-ledger.md), so a goal cannot grade
  itself.
- **Work is named before it is scheduled.** An `E#` is minted into a reserved
  band, and most of the 25 arcs hold none. Those carry arc-local ids instead, a
  row per unit of work, each mapping to an element or to nothing. Naming work that has no number used to mean writing `UNASSIGNED` and
  stopping, which made the work uncitable;
  [decision-work-ids](docs/decisions/decision-work-ids.md) settled the current
  rule on 2026-09-01.

| goal | arcs | element ids |
|---|---|---|
| the language compiles and checks itself | none | held, maintained by the build rule |
| chirality writes its own tooling, and no Python remains | `diagnostics`, `file-types`, `text-tools`, `zero-python` | `E184-E189`, `E190-E195`, `P1-P4`, `T1` |
| the surface is convenient without buying it back in escape hatches | `diagnostics`, `file-types` | `E184-E189` and `E190-E195`, two of the four reserved bands |
| what is built is gated, and the compiler checks what it claims | `enforcement` | `E184-E189`, shared with `diagnostics` |
| what this repo says about itself is true | `baseline-alignment`, `binary-split`, `presentability` | `BA-`, `B1`, `D1` |
| judgment that does not rest on one formulation | `independent-judgment` | `J1` |
| A governs B, and the bridge is what carries it | `bridge` | `C1` |
| each module is one thing, down to the trusted core | `module-split` | `S1` |
| the native stack, wire and screen in the same language | `native-protocol`, `native-window`, `native-document` | the `N` namespace, `W1`, `V1` |
| the ownership and trust model | `ownership-and-trust` | `O1`. Deferred by author decision, [decision-scope](docs/decisions/decision-scope.md) |
| full genuine local AI on small models | `scriba`, `text-tools`, `transport`, `tuning` | the `S` namespace, `P1-P4`, `T1`, `U1`. Blocked on two author calls in [`records/author-calls.md`](records/author-calls.md) |

⚑ **Twenty arcs of twenty-five hold no reserved element band**, so most of
what this project intends is named and citable without being scheduled. Two
arc-local namespaces collide today: `transport` and `zero-python` both open at
`T1`.

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
| cost is in the type | QTT and refinement run in the checker; E11's `tot-gate` is called at `compile-front.chiral:340` | no termination judgment exists in `diag.chiral`, and the one source declaring a `(total)` profile is ungated | mint the judgment, or drop termination from the claim |
| crossings are named and closed | 9 port registries, `ports/ports.chiral` has 118 importers, 2026-09-03 | timing, cache pressure and speculation have no port | name it open |
| readable and self-hosting | self-hosts, byte-identical fixpoint | 15 Python files remain, 7,592 lines. Kernel and runtime rows are design | E173, E148, E150 |
| judgment frozen, the rest re-checkable | `reflect-floor.chiral` and `kernel-core.chiral` are written | zero importers | wire, or mark seeded |

## The tree

The extension is the file's kind and the directory is its role. Subject matter
is neither, so there is no `stdlib/` and no `compiler/`.
[`MAP.md`](MAP.md) is the contract.

| | |
|---|---|
| [`lib/`](lib/) | 105 importable modules in thirteen groups: `prelude` `typing` `surface` `module` `lowering` `ports` `capability` `memory` `runtime` `protocol` `evidence` `text` `crypto` |
| [`prog/`](prog/) | what chirality ships, as distinct from what it is, plus `demo/` `samples/` `scriba/` `prapanca/` `agent/` |
| [`bin/`](bin/) | `chirality` is the CLI front door. `chirality-bin` is the compiler: a blob on stdin, an ELF on stdout |
| [`tools/`](tools/) | one folder per tool. Ten of them are the Python still being replaced |
| [`docs/`](docs/) | the design base and the element pipeline |
| [`records/`](records/) | what we measured about ourselves |
| `.planning/` | the agent tier: navigation, protocol, queues |

### Reading the documentation

`docs/` is a linked note base, one idea per note, entered at
[`docs/index.md`](docs/index.md) and linked by `[[slug]]` rather than by path.

| tier | holds |
|---|---|
| [`definitions/`](docs/definitions/) | one entry per named concept, 51 of them |
| [`decisions/`](docs/decisions/) | one settled fork per entry, carrying its reason |
| [`banks/`](docs/banks/) | the depth tier: one concept refracted into its shards and their homes |
| [`goals/`](docs/goals/) and [`arcs/`](docs/arcs/) | 14 goals, and the 25 arcs serving them. An arc file carries its roster and its own resume state |
| [`elements/`](docs/elements/) | the catalog, the ledger, and one SPEC per element |
| [`examples/`](docs/examples/) | **closed.** 133 entries from the retired worked-example pipeline; they fold into `implementation/` |
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
The numbers and their limits are in
[goals/enforcement](docs/goals/enforcement.md), under Honest limits.

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
