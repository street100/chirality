---
node: axis-altitude
layer: foundation
refines: [thesis]
related: [altitude-errors, axis-typeability, splitting-law, joining-law, modules-lowering, modules-core, decision-backend, category-bridge, open-edges]
status: draft
updated: 2026-07-24
---

# Axis 2: altitude

The second axis places a module by where it sits between intent and machine. It
is orthogonal to [[axis-typeability]], but it is not the same kind of axis.
Typeability is a partition: a module is exactly one of A, B, C, and the
[[splitting-law]] forces it. Altitude is a span. A process is expressed and it
runs, and those are the same process seen at different heights, not two
processes. So a module can reach across altitude, and the thing that carries it
down is a connector. See [[joining-law]].

## The three levels

Top to bottom, with a drop between each.

- upper. Intent facing. Where a process is expressed: the calculus, the types,
  the effects, the custody declarations. The what.
- tal. The typed assembly floor. Still fully typed, human writable, with its own
  A, B, C. The lowest authored level.
- metal. Machine code, or silicon. The bottom. Plain machine code on ordinary
  hardware; CHERI capabilities on hardware that has them, where the type mark
  reaches the silicon instead of being erased.

A drop is a lowering step. The descent from upper to tal is type preserving and
checked: each drop refines the A, B, C structure and none erases it. The drop
from tal to metal is the one trusted step, where the type is erased on ordinary
hardware, or carried into silicon on CHERI. See [[modules-lowering]].

## No untyped bottom

Typeability is preserved down to tal and checked the whole way (`preserve-check`).
If a drop erased the type above tal, it would drill the thesis's gap at the
bottom of the stack, the worst place for it. Assembly is exactly where types
usually die. Chirality refuses that: tal is the floor and it is typed. Below tal is
the single trusted drop to the metal. On CHERI the type does not die there
either; it lands in the silicon.

## The floor is thin

No untyped bottom says the floor is *typed*; this says the floor is *minimal*.
The tal type universe is deliberately small — `I64`, `Str`, `Bytes` (`tal.py`) —
and the floor's instruction vocabulary is the rare, guarded exception, not the
growth point. Typing is imposed *above* the floor (the calculus, refinements,
custody) and re-seated across the [[category-bridge]] on the way back up; the
floor holds raw words, not a type for every shape.

So altitude has a default direction: **a feature lives as high as it can, and
drops only as far as it must.** A new floor type or tal opcode must earn its
place against an irreducibility argument; the default is composition from what
the floor already has (a multi-byte or pointer store is `bput` at a computed
offset, not a new store-word opcode — the floor has no opaque pointer type, so a
pointer is an `I64` there and decomposes like any word). Adding to the floor
what belongs above it is an **altitude error**: it fattens the trusted substrate
— more to prove, a bigger [[modules-lowering]] preserve-check — to buy nothing
the bridge could not carry. The forcing example is the syscall-struct vocabulary
(edge 6, [[open-edges]]): "structs at the floor" is library composition governed
by the bridge and the preserve-check, not new floor primitives.

The check this wants is mechanical — a tal-level mnemonic that is not a real
floor opcode is the tell of an altitude error — but it is unbuilt: today the
invariant is discipline enforced by review, not by the ledger.

## Foreign code is not the bottom

Foreign code looks like a counterexample: it is already-compiled external code, it
does not lower through tal, and it carries no types, so it is untyped and it runs.
But it is not the bottom of our stack. No untyped bottom is about the typed
lowering path, the path we control, which still ends at tal. Foreign code was
never in that path. It is a B referent that hangs off the side, like a device, not
a floor beneath us. See `foreign` in [[modules-substrate]].

What keeps it governed is structural. Foreign is reachable only through a typed C
orchestrator (`bridge-supervisor`, `isolation-enforce` in [[modules-bridges]]),
and the runtime is built with no port to unwrapped foreign, so using a driver that
has not been wrapped is not expressible. There is no ungoverned path to it, and
the difficulty of getting around the wrapper is the safety: the safe path is the
only path (P5). The honest limit, as with all of B: a compromised foreign blob
does whatever its compartment allows. The orchestrator bounds the blast radius by
the capability it holds; it does not prove the foreign correct. Governance by
isolation and evidence, not proof.

## When a level is a separate module and when it is not

Spanning altitude does not by itself make two modules. Ask the [[splitting-law]]
of the upper face and the lower face. If the lower one has a different type, a
different effect, cost, or tier, it is a twin and already two modules: a proof up
high and evidence or enforcement down low. Cost, ports, and reflection are the
examples. If the type is unchanged, it is one module the lowering connector
carries down, and the map marks it `cross`. So `cross` means a connector runs
through the module, not that altitude has a third value.

## Consequences recorded elsewhere

- The floor being typed forces a typed backend and forbids compiling to C, which
  would reintroduce an untyped bottom. See [[decision-backend]].
- Erasure does not vanish. On ordinary hardware it is the one trusted drop from
  tal to machine code, which the programmer never edits. See [[modules-lowering]].
- CHERI is the bottom level on hardware that has it: the type mark is carried
  into silicon rather than erased. Additive, not required. See the CHERI floor in
  [[modules-lowering]].
- This axis is about lowering and it has a `preserve-check`. Five other axes
  carry the same shape — a thing living below the level of generality that owns
  it — and none of them has a check. See [[altitude-errors]].
