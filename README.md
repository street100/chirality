# chirality

*common-sense, the language.*

Most broadly, chirality is an approach to programming that takes the idea of zero
trust as far as physically possible. The idea is that almost nothing should be
trusted by position. Every claim is checked at the point it enters, carried to
the lowest level achievable.

In terms of makeup, it is a set of modules that operate at specific boundaries
to provide guarantees where they cannot be bypassed.

- A **minimal judgement core** is the sole authority on what is possible.
  (Note: this is separate from being able to say yes to anything. It
  determines, based on the set of modules run against it, what should be
  possible at compile time. Modules may add rules, but cannot go around them.)
  It is deliberately tiny enough for a human to read in full.

- The language you write is **not the language that is trusted**. Surface code
  is elaborated (translated down) into a small core calculus, and the
  judgement core checks the result of that translation. Convenience syntax
  cannot smuggle anything past checking because it no longer exists by the
  time checking happens.

- Typing is **quantitative** (QTT, in the Atkey-McBride line). Every binder
  carries a usage annotation from the 0/1/ω semiring: 0 for variables that may
  appear in types but are erased from runtime entirely, 1 for values that must
  be consumed exactly once, ω for unrestricted use. One judgement unifies
  dependency and linearity. Types may freely mention values in the erased
  fragment, while runtime resources like handles, capabilities, and secrets
  get exact-use enforcement from the same core rules, not from a bolted-on
  linearity checker.

- All values going from code to something happening in the world pass through
  **declared, typed entry points**, and everything coming back in is verified
  against its declared type at the moment of return. An outside component that
  lies produces a typed error at the boundary, not corruption downstream.

- Beneath the compiler sits a **floor of typed assembly**. Compiled output is
  re-checked there, instruction by instruction, by a checker independent of
  everything above it. Even the compiler is not taken on trust.

What a conventional language ships as one monolithic feature, chirality splits into
pieces like these, each living at the boundary responsible for enforcing it.

## Status

**Self-hosting (2026-08-05).** chirality compiles itself: the native compiler
compiles its own source to a **byte-identical** copy of itself — the fixpoint —
with no interpreter and no Python in the compile path (`selfhost.py stage2` →
`FIXPOINT: B1 == B2`, 1 s, peak 0.1 GB). The Python scaffold that *bootstrapped*
the first native compiler remains only as the reference oracle for the test
suite (pending a Rocq rewrite); it is off the build and run paths. 703 tests
(1 skipped) green as of 2026-08-10. What is real versus designed is tracked in
[docs/status-ledger.md](docs/definitions/status-ledger.md) and
[scaffold/README.md](docs/implementation/README.md).

**Measured performance** (narrow, dated, reproducible —
[scaffold/bench/](docs/benchmarks/RESULTS-2026-08-01.md), `sh run.sh` reruns
everything): on three micro-kernels, chirality-emitted x86-64 runs **2–6× faster
than gcc -O0** and **1.4×–8.4× behind gcc -O2** (compute-bound: 1.37×), the honest optimized-C
reference. Cross-side ratios only — absolute times do not travel off the
measurement guest. The remaining gap is attributed pass-by-pass, and part of
the optimizer is *trait-native* rather than borrowed: transforms licensed by
facts the checker proves (totality-licensed compile-time evaluation,
refinement/constant guard elision, dense-tag tables, Euclidean strength
reduction) — see [scaffold/bench/TRAIT-OPTS.md](docs/benchmarks/TRAIT-OPTS.md).

## Try it

```
git clone https://git.shredbox.rip/shred/chirality.git
cd chirality
ln -s "$PWD/bin/chirality" ~/.local/bin/chirality

chirality test               # 703 tests, one command
chirality run hello.chiral --entry main   # compile + run in one go
```

Write a program, compile it, run it — zero Python in the path:

```
$ echo '(def main (-> I64 I64) (lam (n) 42))' > hello.chiral
$ chirality run hello.chiral --entry main
chirality: hello.chiral -> hello (16760 bytes, entry: main)   # ELF runs, exit code 42
```

The native compiler is self-hosting:

```
$ ./build.sh
FIXPOINT: bin/chirality-bin.new == bin/chirality-bin (byte-identical)
```

## What's real — verifiable in 30 seconds

No roadmap, no "eventually." Everything here runs right now.

```
# self-hosting: chirality compiles chirality
$ ./build.sh
  → FIXPOINT: bin/chirality-bin.new == bin/chirality-bin (byte-identical)

# 703 tests
$ chirality test
  → Ran 703 tests  OK (skipped=1)

# native ELF from chirality source
$ echo '(def main (-> I64 I64) (lam (n) 42))' > hello.chiral
$ chirality run hello.chiral --entry main
  → chirality: hello.chiral -> hello (16760 bytes, entry: main)   # ELF exits 42
```

The type system catches bugs at compile time. Each line is a tiny file in
`scaffold/demo/` — 2 to 4 lines, open them and see exactly what was checked:

```
$ cd scaffold

# effect membrane — the `=>` crossing rides in the type and is checked as part of it
$ chirality check demo/_eff.chiral
  → load: type mismatch          # exit 1
# ⚑ honest scope, measured 2026-08-25 against scaffold/build/B1: this line used
# to read "pure code structurally can't do I/O", and the demo does not show that.
# Its refusal is the ARGUMENT mismatch -- `put : (=> Str Unit)` handed an I64.
# Repair it to (put "x") under the same (-> I64 Unit) signature and it compiles
# and prints. The native compiler CARRIES the ->/=> bit but does not yet REFUSE a
# `->` body that calls an `=>` one; the three seams that refuse
# (on_apply/on_binder/erased_allow) exist only in the Python floor
# (scaffold/chirality/effects.py). Enforcing them natively is catalog element E171.

# refinement types — out-of-range values are compile errors
$ chirality check demo/_ref.chiral
  → load: cannot prove refinement # exit 1

$ chirality check demo/_ref2.chiral
  → chirality check: demo/_ref2.chiral OK

# type mismatch — arity error caught
$ chirality check demo/_type.chiral
  → load: type mismatch          # exit 1

# typed assembly floor — lowered code re-checked instruction by instruction
# (still the Python floor: there is no native `chirality lower` subcommand yet)
$ python3 -m chirality lower demo/_tal.chiral
  → lowered to tal, preserve-checked: 1
```

`chirality check` is the native compiler's own front end with the ELF thrown away —
no Python, and no second checker to drift.  Its messages are terser than the
Python floor's used to be; the diagnostics are being widened separately.

Other programs in `scaffold/demo/`: `passman-min` (a secret structurally can't
leak to a socket), `tomodachi` (effect-gated behavior pack), `wl-client`
(Wayland wire codec).  Self-contained samples with zero imports in
`scaffold/samples/` — compilable directly with `chirality compile`.

## Where to look

| What | Where |
|---|---|
| judgement core (QTT) | [`scaffold/chirality/kernel.py`](scaffold/chirality/kernel.py) |
| effect membrane (-> vs =>) — carried natively, **enforced only in the Python floor** (E171) | [`effects.py`](scaffold/chirality/effects.py) (the three seams) + [`kernel.py`](scaffold/chirality/kernel.py) + demo [`_eff.chiral`](scaffold/demo/_eff.chiral) |
| refinement types | [`scaffold/chirality/refine.py`](scaffold/chirality/refine.py) + demo [`_ref.chiral`](scaffold/demo/_ref.chiral) |
| typed assembly floor | [`scaffold/chirality/tal.py`](scaffold/chirality/tal.py) + demo [`_tal.chiral`](scaffold/demo/_tal.chiral) |
| typed entry points | [`scaffold/chirality/bridge.py`](scaffold/chirality/bridge.py) |
| native compiler (in chirality) | [`scaffold/lib/compile-all.chiral`](scaffold/lib/compile-all.chiral) |
| typed process spawn | [`scaffold/lib/proc.chiral`](scaffold/lib/proc.chiral) |
| userland in chirality | [`scaffold/lib/`](scaffold/lib/): JSON, HTTP, FSMs, x86-64 emitter |
| design docs | [`docs/`](docs/): start at [`docs/index.md`](docs/index.md) |
| benchmarks | [`docs/benchmarks/`](docs/benchmarks/): native codegen vs `gcc -O2` + growing-allocator scale |
| worked examples | [`examples/`](examples/), indexed in [`examples/INDEX.md`](docs/examples/INDEX.md) |
| threat model | [`SECURE-DATUM-MODEL.md`](SECURE-DATUM-MODEL.md) |
| principles | [`PRINCIPLES.md`](PRINCIPLES.md) |
| project map | [`MAP.md`](MAP.md) |

## About this repository

This is the public mirror of a private working repo. Planning and process
lanes are filtered out of the published history, so some older commits
reference paths that are not present here. That is the filter, not breakage.

## License

Business Source License 1.1, see [LICENSE.md](LICENSE.md). Use it for
anything, including commercially and in production: build and sell your own
software with it, run it internally, support it and teach it for pay. What
needs a commercial license: selling chirality itself or a derivative as a
product, or offering it as a hosted or managed service. Free forever.
