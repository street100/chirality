---
node: modules-staging
layer: module
related: [module-map, modules-lowering, modules-core, open-edges, dump-integration, joining-law]
status: draft
updated: 2026-06-16
---

# Staging and generation modules

The precompute and procedural generation focus. These are mostly gaps: needed
but not yet designed. The unifying claim collapses several would be modules into
one.

## The unifying claim

There is no separate runtime compiler. There is one compiler, multi staged.
Precompilation, ahead of time compilation, and runtime compilation are the same
process invoked at different stages. Runtime compilation falls out for free once
staging exists; it is the compiler running at a later stage. The dumps confirm
this: their compiler as factory of ephemeral runtimes is, once the metaphor is
stripped, partial evaluation plus dead module elimination producing a residual
runtime (dump C9, C10), and each such runtime is itself a process. See
[[process-and-runtime]]. So `jit` is not a module; it dissolves into stage plus
tal.

Pregen is the generative twin of that staged compiler. The compiler is code to
code; pregen is seed to artifact. Do not build three compilers; build one staged
compiler plus a generator.

Staging is the staging connector of the [[joining-law]]: the across-stage join,
one binding time to the next, whose preserved invariant is semantics. A residual
must compute what its source would; a specialization that changes behavior is the
connector's failure mode. The tuned runtimes that govern the bootstrap floor are
residuals of this connector, cross-checked under the bridge. See [[joining-law]]
and the bootstrap floor in [[module-map]].

## stage (gap)

The binding time spine. Assigns each computation a stage (compile, init,
runtime) and lets stages cross compile. It is an upper concept that governs lower
execution, so it threads through the whole grid. The precompute focus is
impossible without it. This is the biggest gap.

## specialize (gap)

Partial evaluation: staged inputs in, a residual program specialized to them out.
The grown up form of constant folding. The compiling to categories idea is a
technique for this, but only in the A region; it breaks at the B and C boundary,
because DMA, raw pointers, and untyped referents do not live in a closed
category. See [[dump-integration]].

## pregen (gap)

Procedural generation: seed or root to artifact. Distinct from reflection, which
is code to code. Covers derive not store: register root key schedules, generated
tables, on demand constant time kernels. The principles call this structural, not
an optimization, so it is a required module. It is absent from the dumps; it
comes from the secure datum model. Its artifacts are consumable (use once
material), so it is a client of `cost-typed` and custody linearity, which track
single use precompute and bound the exposure window.

## link and load (gap)

Installing generated code into a running process touches the substrate, so this
is lower C. Mostly absent from the dumps; only the deferred broker gestures touch
it.

## What the dumps did and did not fill

They confirm stage and specialize and tal strongly, leave pregen and link
untouched, and contribute a fabricated speedup number that does not enter the
frame. See [[dump-integration]].
