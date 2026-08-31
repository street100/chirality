# chirality

*common-sense, the language.*

chirality takes zero trust as far as it will go. Almost nothing is trusted by
position. Every claim is checked where it enters, and the check is carried to
the lowest level reachable.

The makeup is a set of modules that sit at boundaries, so their guarantees
cannot be bypassed.

- A **minimal judgement core** is the sole authority on what is possible. It
  decides, from the modules run against it, what may happen at compile time.
  Modules add rules and cannot route around them. It is small enough for a
  human to read in full.

- The language you write is **not the language that is trusted**. Surface code
  is elaborated down into a small core calculus, and the judgement core checks
  the result of that elaboration. Convenience syntax cannot smuggle anything
  past checking, because by then it no longer exists.

- Typing is **quantitative** (QTT, in the Atkey-McBride line). Every binder
  carries a usage annotation from the 0/1/ω semiring. 0 is erased from runtime
  and may still appear in types. 1 must be consumed exactly once. ω is
  unrestricted. One judgement unifies dependency and linearity, so runtime
  resources like handles, capabilities and secrets get exact-use enforcement
  from the core rules, with no bolted-on linearity checker.

- Every value going from code to something happening in the world crosses a
  **declared, typed entry point**, and everything coming back is verified
  against its declared type at the moment of return. An outside component that
  lies produces a typed error at the boundary, and no corruption downstream.

- Beneath the compiler sits a **floor of typed assembly**. Compiled output is
  re-checked there, instruction by instruction, by a checker independent of
  everything above it. Trust does not extend even to the compiler.

What a conventional language ships as one monolithic feature, chirality splits
into pieces like these, each living at the boundary that enforces it. Those are
the boundaries by design. **Status**, below, says which of them run today.

## Status

**Self-hosting since 2026-08-05.** The compiler compiles its own source to a
byte-identical copy of itself. `bin/chirality-bin` is committed at 1,102,200
bytes, and the fixpoint is verified at generation 3 (gen2 == gen3).

No Python runs in the compile, check or run path. 14 Python files remain,
4,654 LOC, measured 2026-08-31, all under `tools/` and `docs/examples/refs/`.
The target is zero. The rule is that the compiler compiles everything.

`bin/chirality test` reports **118 assertions passed, 0 failed**, plus 86
compile-only roots that gate and assert nothing. 5 of the old suite's 12 phases
are unported; the run prints each by name and reason, every time.

What is real versus designed is tracked in
[status-ledger](docs/definitions/status-ledger.md) and
[docs/implementation/](docs/implementation/README.md).

### ⚑ Honest limits

- `python3 tools/ledger-lint/ledger-lint.py` **exits 1** today, on one check.
  Lint fails.
- The effect membrane's three refusing rules are in the tree and **nothing
  calls them**. A `->` body that reaches an `=>` one is refused nowhere. The
  bit is carried; the gate is element E171, unbuilt.
- The typed-assembly floor is built and **unadopted**. Neither the floor
  checker nor the optimizer's re-check runs in the shipping compile.
- Inbound entry-point verification is **cut**, and it has no successor in this
  tree. The declaration side is built; the return-side check is absent.
- **External judgment is cut**: the Rocq leg, the CompCert leg, the Python
  oracle. What replaces them is three semantically distinct judgment cores that
  must agree, and that is **unbuilt**. So every rung in the ledger is
  enforcement against error. An adversary who controls the source is out of
  its reach.

### Scope

Current work is **self-hosting only**: the language compiling and checking
itself, and being good enough to write its own tooling. The ownership and trust
model is a separate track, **deferred** from this one and built in its own
lane: the re-bootstrap climb, DDC, the
[secure datum model](docs/definitions/secure-datum-model.md), the register
root, the cascade.

### Measured performance

Narrow and dated: [RESULTS-2026-08-01](docs/benchmarks/RESULTS-2026-08-01.md).
On three micro-kernels, chirality-emitted x86-64 ran **2–6× faster than gcc
-O0** and **1.37×–8.4× behind gcc -O2**, the honest optimized-C reference.
Cross-side ratios only: absolute times do not travel off the measurement guest.

⚑ The benchmark harness was Python and did not come across in the doc hoist, so
these numbers cannot be re-measured in this tree today. They stand as a dated
record.

The remaining gap is attributed pass by pass, and part of the optimizer is
*trait-native* rather than borrowed: transforms licensed by facts the checker
proves. Totality-licensed compile-time evaluation, refinement and constant
guard elision, dense-tag tables, Euclidean strength reduction. See
[TRAIT-OPTS](docs/benchmarks/TRAIT-OPTS.md).

## Try it

```
git clone https://git.shredbox.rip/shred/chirality.git
cd chirality
ln -s "$PWD/bin/chirality" ~/.local/bin/chirality
```

The four subcommands are `compile`, `run`, `check` and `test`.

```
# the suite: one command, zero Python
$ chirality test
  → assertions: 118 passed, 0 failed
  → compile-only: 86 roots built, 0 failed
  → chirality test: gate PASSED

# source to a native ELF, compiled and run
$ echo '(def main (-> I64 I64) (lam (n) 42))' > hello.chiral
$ chirality run hello.chiral --entry main
  → exit code 42
```

`chirality check` is the compiler's own front end with the ELF thrown away. One
front end, so there is no second checker to drift. Each demo below is a file of
two to four lines. Open it and see exactly what was checked.

```
# refinement types: an out-of-range value is a compile error
$ chirality check prog/demo/_ref.chiral
  → load: cannot prove refinement   # exit 1
$ chirality check prog/demo/_ref2.chiral
  → chirality check: prog/demo/_ref2.chiral OK

# arity: a two-argument type given a one-argument lambda
$ chirality check prog/demo/_type.chiral
  → load: type mismatch             # exit 1

# the effect membrane: the `=>` crossing rides in the type
$ chirality check prog/demo/_eff.chiral
  → load: type mismatch             # exit 1
```

⚑ Honest scope on `_eff.chiral`, measured 2026-08-25. The refusal is an
**argument** mismatch: `put : (=> Str Unit)` handed an I64. Repair it to
`(put "x")` under the same `(-> I64 Unit)` signature and it compiles and prints.
The compiler carries the `->`/`=>` bit and does not yet refuse a `->` body that
calls an `=>` one. That gate is E171.

Bigger programs live in `prog/demo/`: `passman-min` (a secret has no structural
path to a socket), `tomodachi` (an effect-gated behavior pack), `wl-client`
(the Wayland wire codec). `prog/samples/` holds 69 small programs the suite
sweeps.

### Rebuilding the compiler

The existing binary builds the next one. Nothing replaces itself in place.

```
. bin/chirality-resolve.sh
chirality_blob_file "lib:prog" prog/compiler.prog > /tmp/blob.chiral
(ulimit -s unlimited; bin/chirality-bin < /tmp/blob.chiral > /tmp/C1) && chmod +x /tmp/C1
[ -s /tmp/C1 ] && (ulimit -s unlimited; /tmp/C1 < /tmp/blob.chiral > /tmp/C2) && cmp /tmp/C1 /tmp/C2
```

The `-s` test is load-bearing: two empty files compare equal, and a fixpoint on
nothing proves nothing.

## Where to look

| What | Where |
|---|---|
| judgement core (QTT) | [`lib/typing/kernel.chiral`](lib/typing/kernel.chiral) + [`qtt.chiral`](lib/typing/qtt.chiral) |
| effect membrane (`->` vs `=>`): carried, **refused nowhere** (E171) | [`lib/typing/effects.chiral`](lib/typing/effects.chiral) (the three seams) + demo [`_eff.chiral`](prog/demo/_eff.chiral) |
| refinement types | [`lib/typing/refine.chiral`](lib/typing/refine.chiral) + demo [`_ref.chiral`](prog/demo/_ref.chiral) |
| typed assembly floor, **built and unadopted** | [`lib/lowering/tal/check.chiral`](lib/lowering/tal/check.chiral) |
| where a crossing is declared | [`lib/ports/`](lib/ports/): 9 registries behind [`ports.chiral`](lib/ports/ports.chiral) |
| the compiler, in chirality | [`lib/lowering/compile-all.chiral`](lib/lowering/compile-all.chiral), entry [`prog/compiler.prog`](prog/compiler.prog) |
| typed process spawn | [`lib/runtime/proc.chiral`](lib/runtime/proc.chiral) + [`process.port`](lib/ports/process.port) |
| userland in chirality | [`lib/`](lib/): [JSON](lib/protocol/json.chiral), [HTTP](lib/protocol/http.chiral), FSMs, the [x86-64 emitter](lib/lowering/x64/emit.chiral) |
| the tree contract: extensions, roles, the module key | [`LAYOUT.md`](LAYOUT.md) |
| design docs | [`docs/`](docs/), starting at [`docs/index.md`](docs/index.md) |
| benchmarks | [`docs/benchmarks/`](docs/benchmarks/) |
| worked examples | [`docs/examples/INDEX.md`](docs/examples/INDEX.md) |
| threat model (ownership track, deferred) | [`secure-datum-model`](docs/definitions/secure-datum-model.md) |
| principles | [`PRINCIPLES.md`](PRINCIPLES.md) |
| project map | [`MAP.md`](MAP.md) |

## About this repository

This is the public mirror of a private working repo. Planning and process lanes
are filtered out of the published history, so some older commits reference
paths that are missing here. That is the filter at work.

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
