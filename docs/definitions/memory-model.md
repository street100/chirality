---
node: memory-model
layer: foundation
related: [banks/memory, node-architecture, modules-core, modules-substrate, modules-custody, category-untyped, decision-profiles, decision-graded-kernel, permission-model, target-tomodachi, open-edges, dump-integration]
status: current
updated: 2026-09-04
---

# Memory model

The consolidated note for how chirality holds memory. Like [[permission-model]],
this adds no module and no mechanism: it collects positions already settled
across the base and the accepted dump material, names where the flexibility
lives, and points at the open edges. Written from a research pass over the
spine, the docs, GIANTDUMP, and a set of operational memory-hygiene notes. Depth tier:
[[banks/memory]] — the shard-by-shard refraction, cross-cuts, and build-state
behind this note.

## One sentence

Memory is governed like everything else in this design: structurally, at the
port, by linearity; there is no runtime manager, and what varies is which
discipline a profile composes in, not what an allocator decides at runtime.

## The commitments, from the base

1. **Space is a port.** Interior compute spends memory, so unbounded
   allocation is a port a program incurs by running (P3 — time and space
   are ports too); the spend is part of the type's weight (P2).
   `cost-typed` carries graded time and space as an over-approximate bound
   ([[modules-core]]); termination is a property, not a grade, per the
   settled three-way split. The mechanism is settled on paper — cost as a
   kernel semiring enrichment ([[decision-graded-kernel]], E38) — but
   unbuilt; edge 2 (how far the membrane reaches) and edge 3 (the cost
   gradient) in [[open-edges]] carry what remains.

2. **No allocator, no manager, no owner.** A span of RAM is B substrate,
   owned by nothing ([[node-architecture]], [[modules-substrate]] raw-mem).
   A resource limit is the bound in the port's type, not an allocator saying
   no at runtime; ports are minted from a linear supply against real finite
   capacity, so the total handed out cannot outrun the hardware.
   Conservation by linearity, not by an accountant. Allocation, where it
   exists, is minting from that supply. Runtime exhaustion (the substrate
   refuses a mint the types permitted) is an environment alarm under
   [[error-and-alarm]], not an accounting mechanism.

3. **Discipline is a profile choice.** This is where the flexibility lives,
   and it is composition-time, not runtime. From the dumps (the four-profile
   table and subtractive composition in GIANTDUMP 05, the elaboration-module
   framing in GIANTDUMP 02; accepted by adoption via [[dump-integration]]
   into [[decision-profiles]]):
   - linear is the memory-safety backbone (settled; use-once ownership);
   - refinement carries bounds (converged; folds integer safety);
   - region types are the arena story for systems code without GC
     (unbuilt; catalogued as E41/E22 and gated on arithmetic-expression
     refinement bounds — E9, edge 3; see the naming note below);
   - a garbage collector is an elaboration module outside the trusted core,
     never kernel, which a permissive profile may adopt by dropping
     linearity (the dump's chirality-app), and whose absence other profiles
     state structurally (the dump's chirality-bare, chirality-firmware,
     chirality-systems).
   A profile therefore picks its memory discipline the way it picks any
   module set, and conformance to a target is what holds it there (G9).

4. **Storage views are port types.** A block view, a log view, a key-value
   view are port types over the same raw blocks; they coexist and nothing
   owns the medium ([[node-architecture]]). The same shape at RAM scale: a
   buffer supply is a port carrying its size in its type
   ([[target-tomodachi]]'s memory bound).

5. **Secrets in memory follow the secure datum model.** Derive from the
   register root, do not store; RAM holds ciphertext plus redundancy;
   cleartext exists only in a bounded working window. Linear and graded
   types are already committed to tracking use-once material and bounding
   the exposure window (`clear-window <= N`), and shares are move-only and
   zeroed on drop (SECURE-DATUM-MODEL, [[modules-custody]]). These are
   design commitments: the secret custody *seed* is built (E40), but memory
   custody, per-datum policy, and zeroize-to-the-floor are unbuilt (E56). The
   operational ancestors are hygiene rules kept outside this repository:
   universal zeroize on drop, locked memory, no swap, panic drops keys.
   Those rules are what this model turns from discipline into types.

## Build status

⚑ **Paths repointed 2026-09-04 against the 2026-08-31 migration.** This section
was headed "Scaffold status" and named `lib/ports.chiral`, `lib/mem-linear.chiral`
and `lib/mem-region.chiral`. `MAP.md` is the tree contract and the module key is
the root-relative path.

The tree demonstrates commitment 3 concretely: discipline is a profile choice,
selected at composition time. Two discipline libraries sit over the *same*
substrate, the value-indexed linear `(Pool n)` declared at
`lib/ports/pool.port:13`:

- `lib/memory/mem-linear.chiral` — write at explicit offsets, close once. It
  gives the discipline a name so `(memory linear)` in a profile points somewhere
  real, and carries `mem-put-checked` (`:26`), the bounds-checked write whose
  offset is refined to `{I64 | >=0, <n}` (see the refinement paragraph below).
- `lib/memory/mem-region.chiral` — a bump-allocated arena: a linear `Region`
  wrapping the pool plus a cursor; `mem-alloc` advances the cursor and returns an
  offset; the whole arena frees as a unit. Built from what already exists, with
  no kernel feature, no collector and no runtime allocator.

A profile carries an optional `(memory <discipline>)` clause and an unknown
discipline is a surface error. `tools/test/profile-target.sh` (Phase 4) gates the
clause's parse and pins both the accepts and the refusal. ⚑ *This paragraph said
`chirality verify` reports the clause and that `tests/test_memory.py` exercises
the two disciplines including the arena running for real. `bin/chirality` is
compile / run / check / test / help and has no `verify`; `tests/test_memory.py`
is CUT with the Python oracle. So the clause's parse is gated and the arena's
runtime behaviour is gated by nothing today.*

The same shape reappears at the metal: the scaffold's native backend
(de-Pythoning milestones 2-3) represents data-with-fields as `[tag][fields]`
cells and Str/Bytes as `[len][payload]` cells, both bump-allocated from an
arena the loader maps — the region discipline again, one altitude down.
Exhaustion there is a fault (`ud2`), the alarm that refuses to corrupt; the
arena frees as a unit with the compiled batch. The arena itself is now
self-hosted (E21 COMPLETE): chirality creates and sizes its own anonymous file
and maps it — memfd_create → ftruncate → mmap(MAP_SHARED) → byte roundtrip →
munmap — differentially tested; mprotect and close are still missing from
the sys face (E28). The variable-length
representation is a scaffold-scale decision recorded in
`.planning/SCAFFOLD-NEXT.md`, pending ratification — the note base is
otherwise silent on it (flagged there as backflow).

Two honesty notes hold this to the model. First, the erased bound `n` cannot
be branched on at runtime (commitment: size lives in the type), so the region
carries a runtime capacity *witness* alongside the type index and checks the
cursor against that; over-capacity is an environment alarm (`halt`), not an
allocator saying no. Second — and this is the naming trap below — the region
*library* is not the deferred **region types** feature. It is a discipline
expressed in ordinary linear + ω code, with the offset checked at runtime.
Region types (the arena story the type system tells, retiring that runtime
check) remain unbuilt — catalogued as E41/E22, gated on arithmetic-expression
refinement bounds (E9, edge 3); nothing here advances them.

Refinement types, however, have a live slice, `lib/typing/refine.chiral`
(⚑ *this named `chirality/refine.py`, cut with the Python oracle*).
It retires *constant-bound* checks — a nonzero divisor, an index below a
literal bound — as compile-time obligations rather than runtime guards, and
path-sensitivity plus bare-variable symbolic bounds (`v < n`, learned along
comparison-guarded branches) have since landed. ⚑ *Measured 2026-09-01: a guard
over two **let-bound** `I64`s leaves an obligation nothing discharges, and
`load: cannot prove refinement` is the result. Two params of a named function are
fine. `records/baseline-alignment.md` BA-41 and `records/findings.md` FD-02 hold
the four conditions and the workaround.* That is what lets the pool
offset be typed instead of checked at the crossing: `mem-put-checked`
discharges the offset bound at compile time for literal and guarded offsets
(E22 CONFORMS), while the raw write keeps the runtime witness for computed
offsets. The honest remaining slice is arithmetic-expression bounds
(a cursor-plus-size below a capacity, E9) — the single lever that gates
region types (E41).

## What this rules out

A global heap with a runtime accountant; a mandatory collector under every
profile; an allocator API as ambient authority anything can call. A chirality
program does not ask a manager for memory; it holds a typed, usually linear,
usually bounded port to some of it, or it does not have it.

## Naming: "region" does two jobs

The base uses "region" for the deferred type-system feature (arena-style
memory regions, [[modules-core]] build order) and, in prose, for areas of
the typeability axis ("the typed region"). These are unrelated. When the
memory feature is meant, say region types; the axis sense should stay prose
only. Recorded here until the vocabulary sweep settles it.

## Open

- Edge 2 and edge 3 carry what remains of space as a graded cost (the
  mechanism is settled on paper, E38 unbuilt); the idle and memory bounds
  of [[target-tomodachi]] are their test cases.
- Edge 4 (default tier selection) decides which custody tier a value's
  memory defaults to, so forgetting to split a secret is a type error.
- Edge 15 and the G4 residue (a substrate region written and read back)
  are the memory-facing detect-versus-prevent seams.
- Region types remain unbuilt (E41/E22, gated on E9 arithmetic-expression
  bounds); nothing in this note advances them.
- Whole-assembly memory bounds (the sum over a composite, not one port's
  bound) sit inside edge 18.
