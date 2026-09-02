---
node: goal-self-hosting
layer: navigation
related: [goals/README, status-ledger, testing-floors, index]
status: current
updated: 2026-09-01
---

# Goal: the language compiles and checks itself

## The claim, and where the project makes it

- `README.md`, What is real: *"The compiler compiles its own source to a
  byte-identical copy of itself."*
- `README.md`, Scope: *"Current work is self-hosting only: the language compiling
  and checking itself."*
- [[working-discipline]], The build rule: *"The compiler compiles everything.
  Python compiles nothing."* `build-new`, test, promote, and nothing replaces
  itself in place.

## What done means

1. `bin/chirality-bin` compiles the blob to a binary that compiles the same blob
   to a byte-identical binary. The fixpoint is verified with each artifact
   checked non-empty first.
2. The binary is committed, with the tree and harness that rebuild it.
3. Nothing replaces itself in place. Build-new, test, promote.

## State

Held. `bin/chirality-bin` is 1,147,256 B, promoted by E181 on 2026-09-01, with
`N1 == N2` at generation one. Suite 303 assertions, 0 failed, 87 roots.

## Arcs

None open. This goal is maintained by the BUILD RULE on every change whose
deliverable enters the compiler's import closure, and by
`tools/test/map-integrity.sh` and `bin/chirality test`.

## Honest limits

- The import closure is 59 modules and 16,463 LOC out of `lib/`'s 103 and
  25,559. 1,680 LOC of checking machinery sits outside it, including
  `lowering/tal/check`, `typing/effects` and `typing/totality`. Compiling itself
  does not exercise them.
- A fixpoint shows stability. It says nothing about correctness. That gap is
  [[goals/independent-judgment]].
