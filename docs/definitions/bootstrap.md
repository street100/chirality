# Re-bootstrapping chirality from prose (the climb)

> **What this is.** The shipped form of chirality contains its own re-derivation.
> Starting from *any Linux-ish box plus any programming language* (and **no
> trusted chirality binary anywhere**), you can climb back up to a native,
> self-checked chirality, and verify every step. This file is the human-facing
> chain; `scaffold/lib/climb.chiral` is the same chain as checkable data (the two
> must agree). The machine-checkable golden object each stage validates against
> is `docs/tal-spec.md` (the tal specification: prose + pinned vectors, E71).
>
> **Provisional (2026-08-02).** The golden object is spec-as-golden, the
> provisionally-adopted branch (ratification owed). And the climb *running*
> end-to-end is **gated**. See "What runs today" at the bottom. This manifest is
> buildable now; it does not pretend the climb runs yet.

## The two trust roots

Trust bottoms out in exactly two places, and nowhere else:

1. **The audited prose:** `docs/tal-spec.md` (the tal semantics + observable
   vectors) and the kernel spec. Small enough to read in an afternoon.
2. **The human reading it.** Everything else is text a previous stage checked.

There is no third root. In particular there is no blessed prior binary: the
"trusting-trust" regress every other language cuts by fiat, chirality cuts by audit.

## The climb, stage by stage

Each stage's input is text the previous stage produced; each stage's **check** is
against the spec or a prior stage's output: never against a shipped binary,
because there is none.

### Stage 0: unpack

Unpack the shipped artifact: the prose (kernel-spec + `docs/tal-spec.md`), the
upper chirality source tree, the preserve-checked tal lowering (with its per-function
signatures), and the ref-bank generator scripts (`examples/refs/gen-*.py`).
**Checked by:** a human audit of the prose, and re-running the gen-refs *locally*
so every ABI constant re-derives on your box. The artifact carries no
unexplained numbers.

### Stage 1: the weekend leg

In **any language you like**, implement three small things from the tal-spec
prose: a **tal executor** (a register machine over I64 + byte cells, one
instruction table), a **tal checker** (verifies a tal function against its
signature), and an **s-expression reader**. This is the only thing you write by
hand, and it is weekend-sized. The E52 spec-size budget exists to keep it so.
**Checked by:** the tal-spec **vectors**, pinned input/observable pairs per
instruction. Your executor is admitted exactly like any other floor (E71): it
must reproduce every vector.

### Stage 2: check the shipped tal, then run chirality on itself

Use your stage-1 tal checker to **verify the shipped tal against its signatures**
before running any of it: the shipped tal is not a trusted binary, it is
*checkable text*. Then run the (now-checked) **chirality checker** over the upper
source, and the compiler over itself. **Checked by:** the shipped tal's
preserve-check, re-derived independently by your checker, plus the chirality checker's
own verdicts on the source. A corrupted shipped-tal (one instruction changed) is
**caught here**. That negative catch *is* the ownership claim.

### Stage 3: go native, then demand the fixpoint

Run the checked compiler to emit machine code (go native), then **regenerate the
shipped tal from the upper source** using the compiler you just climbed.
**Checked by:** the regenerated tal must equal the shipped tal **byte-for-byte**,
the tal fixpoint. A mismatch names a lie somewhere: in the spec, in the shipped
tal, or in your climb.

### Stage 4: DDC (diverse double-compile)

Have a **second party** run their own independent stage-1..3 climb and compare
final artifacts. **Checked by:** Wheeler's diverse-double-compiling compare
(E53). Your weekend leg *is* the provenance-disjoint compiler DDC needs, so
re-bootstrap and DDC are one machinery. Agreement across provenance-disjoint
climbs, or a named divergence.

## Why nothing here can lie silently

- A step needing a specific prior binary is **impossible**: every stage's input is
  text the previous stage checked.
- Semantics living outside the spec are **rejected**: a behavior not derivable from
  the spec's vectors is a bug *even if every executor agrees on it* (E71's
  anti-correlated-agreement rule).
- Silent spec drift is **turned into a named divergence** by the stage-3 fixpoint
  and the stage-4 DDC compare.
- Unexplained platform constants are **re-derived locally** by the ref-bank scripts.

## What runs today (honest gating)

This manifest ships now; the climb runs as its gates clear:

- **Stage 1's golden object** (`docs/tal-spec.md` + vectors): **built** (E71,
  provisional).
- **Stages 2–3 (checked-chirality-checker + native fixpoint)** need the native
  compiler: **E69 (closure conversion) done; E70 (effectful lowering) pending**
  (the checker/compiler are closure-heavy effectful code).
- **Stage 3's byte-for-byte fixpoint** needs the D-1/D-2 determinism debts paid
  (a **pre-port gate**).
- **Stage 4 (leg-running)** needs E53's DDC tooling extended to full legs.
- **The "weekend" bound as a *measured* claim** is owed: someone runs the climb
  and clocks it once the gates clear (a target-note, not an estimate).

Each gate is pinned as a `breaker` in `scaffold/lib/climb.chiral` and tracked in
`docs/elements/specs/E72-re-bootstrap-SPEC.md` §6.
