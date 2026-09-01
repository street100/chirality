# chirality

A dependently typed language that compiles and checks itself. One language covers
the compiler, the checker, the emitter, the runtime, the tooling and the data.

What a conventional language ships as one monolithic feature, this splits into
pieces that each live at the boundary enforcing them. Every claim is checked
where it enters, and the check is carried as far down as it reaches.

**Self-hosting since 2026-08-05.** The compiler is written in chirality and
compiles itself to a byte-identical copy. No Python runs in the compile, check,
run or test path.

## Start here

| you are | go to |
|---|---|
| deciding whether this is interesting | [The idea](#the-idea), then [`PRINCIPLES.md`](PRINCIPLES.md) |
| wanting to run it | [Try it](#try-it) |
| reading the source | [The tree](#the-tree), then [`MAP.md`](MAP.md) for the contract it follows |
| asking what actually works | [What is real](#what-is-real), then [status-ledger](docs/definitions/status-ledger.md) |
| reading the design | [`docs/index.md`](docs/index.md), the hub of a linked note base |
| about to change something | [working-discipline](docs/definitions/working-discipline.md), then the arc in [`docs/arcs/`](docs/arcs/) that owns the work |

## Questions

**What bugs could a language inherently remove? Could debugging become purely
about logical bugs?**
Every non-logic failure is a class. A class can be given a way to be said, and
once it can be said the checker can refuse it. Work through the classes until
what is left is you reasoning wrong. Six categories and their current state are
in [bug-classes](docs/definitions/bug-classes.md). The residue is whether your
specification says what you meant, and intent stays outside the checker.

**Why does one working stack need half a dozen languages that share nothing?**
The file extension carries the kind. `.chiral` is a module, `.prog` an entry
point, `.port` a registry that mints capability types, `.profile` a frozen port
set, `.manifest` data. Config stops being a second language.

**Could escape hatches like `unsafe`, `any` and raw casts be checked routes?**
Declare the dangerous thing as a crossing with a type. A registry mints the
capability, the crossing is named, and a program that calls a crossing its
profile froze out is refused at emit. Nothing gets an exemption from the type, so
there is no hatch to reach for.

**Does a language with strong opinions have to fight you?**
Make the well-behaved shape the low-ceremony one. An empty signature is the light
base case, and every effect and every unit of fuel makes a type heavier. The
risky shape is the one you opt into out loud.

**Why is it so hard to see what a program can actually do?**
Enumerating what a program outputs is undecidable. Enumerating how it can reach
outside itself is finite. Those crossings are closed and named, so a module's
reach is the set of boundaries it declares. Time and memory are crossings too,
which is how a regex that pins a core stops reading as harmless.

**What is the smallest thing you would have to trust to trust the whole
language?**
A judgement core of 1,823 lines: `kernel`, `kernel-core`, `qtt` and `refine`.
Everything above it is text that core checked, and the surface elaborates down
into a small calculus before checking, so convenience syntax has nothing left to
smuggle. The rest of the tree is 50,927 lines across 299 files.

**Does proof have to be costly? Does proof have to be slow?**
Proof runs at compile time. Quantity-0 binders are erased before runtime and
types are erased before emission, so the checking does not ride along. Measured
against C on three micro-kernels: 2 to 6 times faster than `gcc -O0`, and 1.37 to
8.4 times behind `gcc -O2`.

⚑ That same erasure is why the typed-assembly preserve check never runs. The
claim and its limit are the same mechanism, and both are below.

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
  → assertions: 303 passed, 0 failed
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
Wayland wire codec). `prog/samples/` holds 56 small programs the suite sweeps.

## The idea

Five claims. Each says where it lives and whether it runs today, because the
gap between the two is the interesting part.

**A minimal judgement core is the sole authority on what is possible.** It
decides, from the modules run against it, what may happen at compile time.
Modules add rules and cannot route around them. Small enough for a human to read
in full.
→ [`lib/typing/kernel.chiral`](lib/typing/kernel.chiral). ENFORCED, reached by
every compile, gated by Phase 3.

**The language you write is not the language that is trusted.** Surface code
elaborates down into a small core calculus and the judgement core checks the
result. Convenience syntax cannot smuggle anything past checking, because by
then it no longer exists.
→ [`lib/surface/`](lib/surface/) into the kernel, via
[`lib/module/loader.chiral`](lib/module/loader.chiral). On the compile path.

**Typing is quantitative** (QTT, in the Atkey-McBride line). Every binder
carries a usage annotation from the 0/1/ω semiring. 0 is erased from runtime and
may still appear in types, 1 must be consumed exactly once, ω is unrestricted.
One judgement unifies dependency and linearity, so handles, capabilities and
secrets get exact-use enforcement from the core rules with no bolted-on linearity
checker.
→ [`lib/typing/qtt.chiral`](lib/typing/qtt.chiral). ENFORCED: the suite rejects
used-twice and dropped linear binders by name.

**Every value crossing into the world crosses a declared, typed entry point.**
An outside component that lies produces a typed error at the boundary and no
corruption downstream.
→ [`lib/ports/`](lib/ports/), nine registries behind
[`ports.chiral`](lib/ports/ports.chiral). The declaration side is built. The
return-side check is **cut** and has no successor here.

**Beneath the compiler sits a floor of typed assembly**, where output is
re-checked instruction by instruction by a checker independent of everything
above it. Trust does not extend even to the compiler.
→ [`lib/lowering/tal/check.chiral`](lib/lowering/tal/check.chiral). Built and
**unadopted**: it does not run in the shipping compile.

## What is real

Measured 2026-09-01, in this tree.

| | |
|---|---|
| self-hosting fixpoint | a 772,967-byte blob in, a 1,147,256-byte ELF out, and that ELF compiles the same blob to itself. Generation one, and it equals the committed `bin/chirality-bin` byte for byte |
| suite | **303 assertions passed, 0 failed**, plus 87 compile-only roots that gate and assert nothing. It runs 13 phases; 4 more are unported and the run names each one, every time |
| Python | 14 files, 4,829 LOC: nine under `tools/`, four generators under `docs/examples/refs/`, one fixture under `.planning/`. None on the compile, check or run path. The target is zero |

What is real against what is designed is tracked on four rungs in
[status-ledger](docs/definitions/status-ledger.md), with the source tree
described in [`docs/implementation/`](docs/implementation/README.md).

### Claims, state, limit, proposal

The gap between a claim and its state is the interesting part, so it is a column
rather than a footnote.

| claim | state today | limit | proposal |
|---|---|---|---|
| everything lowers to typed assembly | eligible defs lower to typed SSA in every compile | types are erased before emit; `ck-prog` and `ck-block` have 0 callers and `ck-fn`'s only caller sits in a module with 0 importers | measure the lowered/skipped ratio, build E70, wire `ck-fn` |
| every unit is a process with a type | the pure/process bit is carried through the front end | the three refusing rules have no live caller; a `->` body calling an `=>` crossing is accepted and runs | E171 |
| cost is in the type | QTT and refinement run in the checker | `totality.chiral` has 0 importers; refinement bounds wrap at the I64 extremes | wire E11, guard `c-atom`, or drop termination from the claim |
| crossings are named and closed | 9 port registries, the facade has 108 importers | timing, cache pressure and speculation have no port; 33 of 50 crossings take no capability | name it open |
| data at boundaries is declared | `.port` and `.manifest` are kinds the tree sorts by | the kind is never checked, and a profile requirement never meets its provider | E163, and a conformance judgment to replace the one cut with the oracle |
| data is well formed | the positivity walk runs on every data declaration | it recurses into a constructor's arguments, so two mutually referencing nullary types pass and diverge | fix the walk in `surface/data.chiral` |
| readable and self-hosting | self-hosts, fixpoint at generation one | 14 Python files in tooling; the kernel and runtime notes are design | E173, E148, E150 |
| judgment frozen, the rest re-checkable | `reflect-floor` and `kernel-core` are written | 0 importers each | wire them, or mark them seeded |

### ⚑ Honest limits

- `python3 tools/ledger-lint/ledger-lint.py` **exits 1** today with 249 findings
  across nine of its twenty checks. 130 are line citations that no longer fit the
  file they name. Lint fails.
- The effect membrane's three refusing rules are in the tree and **nothing calls
  them**. The bit is carried; the gate is E171, unbuilt.
- **Termination checking does not run.** `lib/typing/totality.chiral` has zero
  importers, and `(def spin (lam (n) (spin n)))` type-checks, compiles and never
  halts. The `(measure ...)` syntax the checker needs is refused by the parser.
- **Refinement types are unsound at the I64 extremes.** A strict bound is built by
  adjusting the literal by one, and at `I64_MAX` that wraps, so
  `(refine I64 (> 9223372036854775807))` accepts `0`. One step off the extreme is
  correct, and so are the non-adjusting `>=` and `<=`. The refinement demo above
  is real; this is its hole.
- **Strict positivity accepts a nullary mutual cycle**, for the reason in the
  table above.
- **A profile declares a requirement and nothing checks it.** A `(require ...)`
  whose provider is missing, or present at the wrong type, checks OK and emits an
  ELF. The judgment that checked it went with the Python oracle.
- The typed-assembly floor is built and **unadopted**. Neither the floor checker
  nor the optimizer's re-check runs in the shipping compile.
- Inbound entry-point verification is **cut**, with no successor in this tree.
- **External judgment is cut**: the Rocq leg, the CompCert leg, the Python
  oracle. What replaces them is three semantically distinct judgment cores that
  must agree, and that is **unbuilt**. So every rung in the ledger is enforcement
  against error. An adversary who controls the source is out of its reach.

### Scope

Current work is **self-hosting only**: the language compiling and checking
itself, and being good enough to write its own tooling. The ownership and trust
model is a separate track, **deferred** and built in its own lane: the
re-bootstrap climb, DDC, the
[secure datum model](docs/definitions/secure-datum-model.md), the register root,
the cascade. [decision-scope](docs/decisions/decision-scope.md) holds the line.

## The tree

The extension is the file's kind and the directory is its role. Subject matter
is neither, so there is no `stdlib/` and no `compiler/`.
[`MAP.md`](MAP.md) is the contract.

| | |
|---|---|
| [`lib/`](lib/) | 100 modules. `prelude` `typing` `surface` `module` `lowering` `ports` `capability` `memory` `runtime` `protocol` `evidence` |
| [`prog/`](prog/) | what chirality ships, as distinct from what it is. 96 programs, plus `demo/` `samples/` `scriba/` `manas/` `agent/` |
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
| [`definitions/`](docs/definitions/) | one entry per named concept, 49 of them |
| [`decisions/`](docs/decisions/) | one settled fork per entry, carrying its reason |
| [`banks/`](docs/banks/) | the depth tier: one concept refracted into its shards and their homes |
| [`goals/`](docs/goals/) and [`arcs/`](docs/arcs/) | seven goals, and the arc of elements serving each. An arc file carries its own resume state |
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
On three micro-kernels, chirality-emitted x86-64 ran **2 to 6 times faster than
gcc -O0** and **1.37 to 8.4 times behind gcc -O2**, the honest optimized-C
reference. Cross-side ratios only: absolute times do not travel off the
measurement guest.

⚑ The benchmark harness was Python and did not survive the doc hoist, so these
numbers cannot be re-measured in this tree today. They stand as a dated record.

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
