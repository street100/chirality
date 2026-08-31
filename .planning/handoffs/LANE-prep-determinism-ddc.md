# LANE prep — determinism debts + DDC/differential tooling (DO FIRST)

Read `../HANDOFF.md` first. This lane has no upstream gate and unblocks the
fixpoint. Run it before Lane 5 or the fixpoint becomes a serial byte-diff hunt.

## Goal
Make the checker/compiler **deterministic and byte-stable** so that (a) the
Stage1==Stage2 fixpoint can hold and (b) the DDC compare (E53) is meaningful.
Plus: build the differential compare harness that localizes any divergence
automatically instead of by hand.

## Why it's first (the strategic fact)
The fixpoint is convergence-bound and terminal — it can't be parallelized and
it's the last step. It converges cleanly only if every place the checker's
*output* depends on Python-specific behavior has been pinned to a canonical form.
Pay the debt now, while it's cheap and parallel; discovering it during the port
is the expensive path.

## Rests on (read these)
- `examples/E53-ddc-bootstrap.md` — the DDC ceremony; the two comparison notions
  (spec-conformance admits a leg; **bit-identity convicts the binary**).
- `examples/E08-linear-kinds.md` §6 — the concrete debt found: the linear-kind
  seen-set keys on Python `repr` (a borrowed canonicalizer).
- `docs/trust-boundary.md` — "porting the kernel is where the borrowed
  arithmetic, ordering, and encoding semantics will either hold or break the
  fixpoint." This lane is that sentence, pre-empted.

## The work
1. **Enumerate the debts.** Grep the trusted core (`scaffold/chirality/kernel.py`,
   `data.py`, `terms.py`, `effects.py`, `refine.py`, `surface.py`) for every
   dependence on: dict/set iteration order, `repr()`/`hash()` as a key, float,
   Python int width, str encoding, `sorted()` without a total key. Each is a
   determinism debt. Write the list to `.planning/DETERMINISM-DEBTS.md`.
2. **Pin a canonical form per debt.** Ordered maps (balanced tree, deterministic
   iteration — see `examples/E27-dict-set-to-maps.md`; E27 must land before or
   with this); a total canonical key for term comparison; explicit encoding.
   Arithmetic is already Euclidean-pinned (`docs/floor-agreement.md`) — verify it
   holds, don't redo it.
3. **Build the compare harness.** A tool that runs two executors on the same
   input and reports the FIRST divergence with its location (the DDC/differential
   localizer). This is what makes the fixpoint a check, not a hunt. It reuses the
   existing differential test pattern (`tests/test_native.py` cross-checks native
   vs `TalMachine`).

## Conformance gate
- Existing suite stays green.
- A new determinism test: the same input produces byte-identical output across
  repeated runs and across a dict-order-shuffled interpreter.
- The compare harness correctly localizes a deliberately injected one-byte
  divergence to its source.

## Audit obligation
Verify each pinned canonical form against the ACTUAL current behavior (don't
assume the debt list is complete — the failure mode is a debt you didn't grep
for surfacing at fixpoint time). Ground every entry in a real `file:line`.

## Couples
E27 (ordered maps — likely a prerequisite; spec+implement it here if not done).
Feeds Lane 5 (the fixpoint) and the E53 DDC tooling.
