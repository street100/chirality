---
node: goal-self-hosting
layer: navigation
related: [goals/README, status-ledger, testing-floors, index]
status: current
updated: 2026-09-03
---

# Goal: the language compiles and checks itself

## The claim, and where the project makes it

- [[status-ledger]], the self-hosting fixpoint milestone: the native compiler
  compiles its own source to a byte-identical copy of itself, and CPython is
  evicted from the compile path.
- `docs/decisions/decision-scope.md`: current work is self-hosting only, the
  language compiling and checking itself.
- [[working-discipline]], The build rule: *"The compiler compiles everything.
  Python compiles nothing."* `build-new`, test, promote, and nothing replaces
  itself in place.

## What done means

**This goal carries no arc, and that is its finished shape.** The BUILD RULE in
[[working-discipline]] holds it on every change whose deliverable enters the
compiler's import closure, so there is nothing to schedule. Each condition names
the gate that maintains it, and [[goals/README]] states when this shape is
legitimate.

1. **`bin/chirality-bin` compiles the blob to a binary that compiles the same
   blob to a byte-identical binary**, with each artifact checked non-empty
   before the compare. Held by the BUILD RULE, measured by
   `tools/test/map-integrity.sh` and `bin/chirality test`.
2. **The binary is committed**, with the tree and harness that rebuild it. Held
   by the same gates, observed by a fresh clone reproducing it.
3. **Nothing replaces itself in place.** Build-new, test, promote. Held by the
   BUILD RULE, which [[working-discipline]] states and which every compiler-source
   change owes.

## State

Held. `bin/chirality-bin` is 1,188,216 B, measured 2026-09-03, reproducing itself
byte for byte. Suite 321 assertions, 0 failed, 87 roots, last recorded run
2026-09-01 in [[status-ledger]].

A stack fragments because each layer is held to a different constraint, so the
test of one language is whether it survives being held to all of them at once.

| layer | written in chirality as | state |
|---|---|---|
| the compiler | `prog/compiler.prog` over `lib/lowering/` | self-hosting, byte-identical fixpoint |
| the checker | `lib/typing/`, 3,449 lines | on the path of every compile |
| the emitter | `lib/lowering/x64/emit.chiral` | emits the shipped ELF |
| the runtime | `lib/runtime/`, 3 modules | |
| the tooling | `prose-lint`, `paren-audit`, `resolve`, `test-runner`, `wield` | 14 Python files remain, [[goals/self-tooling]] |
| config and data | `.manifest` | resolves as an import target, contents unchecked, E163 |
| a frozen port set | `(profile name (ports ...) (target t))` | refuses at emit, `compile-emit.chiral:300` |

⚑ E182 fixpointed at generation two on 2026-09-02. A source change that alters
emitted code makes the old binary's output differ from that output's own, and the
answer is to promote the fixpoint rather than generation one
([[records/findings]] FD-08).

## Arcs

None open, and none is owed. This goal is maintained by the BUILD RULE on every
change whose deliverable enters the compiler's import closure, and by
`tools/test/map-integrity.sh` and `bin/chirality test`. An arc schedules work
toward an open goal; a goal a standing gate holds on every change has no work to
schedule, so the arc would be empty. [[goals/README]] states that shape once,
under Rules, and `ledger-lint` check V reads the `none open` row there as the
recorded reason.

What would earn an arc: a decision to close the limits below, since neither is
held by a gate today.

## Honest limits

- The import closure is 59 modules and 16,463 LOC out of `lib/`'s 103 and
  25,559. 1,680 LOC of checking machinery sits outside it, including
  `lowering/tal/check`, `typing/effects` and `typing/totality`. Compiling itself
  does not exercise them.
- A fixpoint shows stability. It says nothing about correctness. That gap is
  [[goals/independent-judgment]].
