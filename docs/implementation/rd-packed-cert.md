# rd-packed: the placement certificate (design proposal)

Status: RATIFIED 2026-08-02 — option A (move-script certificate) chosen by
the author from the dispositioned options below. This resolves standing
author decision #1 of OPTIMIZATIONS-TODO ("rd-packed's certificate
format"); the decided sub-calls stand as written.
Companion: `reg-disciplines.md` (the tier rule that forces the certificate
shape), `bench/OPT-LEDGER.md` List 2 (the structural elements the design
must not break), `bench/RESULTS-2026-08-01.md` runs 8–9 (the measured
residual this tier exists to remove).

## What rd-packed is, and why it cannot be a trusted plugin

rd-packed retires slots: vregs live in registers; the frame shrinks to
spill slots only. It is the only discipline that breaks truthfulness (a
slot no longer holds the real state at every boundary), so by the tier
rule (reg-disciplines call #2) it may NOT ride the trusted-emitter story.
Instead: an **untrusted allocator proposes placements, a small trusted
placement checker verifies them, and emission consumes only verified
certificates**. The allocator's strategy — linear scan, graph coloring,
search, an LLM — is permanently outside the TCB. This is the pilot for the
whole checked-producer pattern (the Tier B superoptimizer rides the same
shape).

What it attacks (measured, runs 8–9): bytesum's residual 5.2× is
store→load forwarding latency (~5 cycles) on the loop-carried dependency
chain through slots; arith's flat residual is acc spilling because mulhi
kills rdx every iteration. Removing slot round-trips from loop-carried
chains is the mechanism; reg-reg moves rename away.

## The three structural facts the checker leans on

1. **Terminator-only tree code.** `TCode` (`lib/tal-ir.chiral:41-46`) has no
   fallthrough form and branches never rejoin — control flow inside a
   function is a tree plus tail-call back-edges. No join points, no phi, no
   dominance: a forward walk visits every path exactly once.
2. **Checked SSA.** The lowered fragment enters every pass single-assignment
   (`optimize.py` `_check_single_assignment` at both pass entries), so a
   vreg's def point is unique and a location fact, once established, is
   invalidated only by clobbers — never by redefinition. Hand-tal (`nb-*`)
   reuses scratch registers and is exempt, exactly as it is exempt from
   fold: **rd-packed applies to lowered functions only; the hand library
   keeps its truthful-slot emission.**
3. **Clobbers are already data.** The `clb` Mach face (`mach-x64.chiral`
   `x64-clobbers`) maps op keys to killed registers. The checker's kill
   step is a table lookup, not ISA analysis. (rd-packed extends the table's
   register universe beyond the six argregs — r10/r11, later callee-saved —
   a mechanical widening of the same face.)

## The property the checker establishes

For each function, given (tal IR, certificate): every operand read in the
emitted stream reads the location that provably holds that SSA value at
that point; no call/ret/tail-call violates the ABI (args in SysV argregs,
result in rax, nothing live in a caller-saved register across a call
unless the certificate spills it); every spill slot read was reached by a
matching spill store on the same path. Verified by **forward symbolic
execution of the location map** — the same walk emit-core already does,
over the same lattice shape as cenv/res, with `clb` as the kill set.

The checker does NOT prove op-body semantics (op-bytes encodings stay
trusted exactly as today, differentially validated); it proves the
*placement* — the only thing rd-packed changes. TCB delta = the checker +
a handful of new reg-form Mach ops. Preserve-check, the differential
corpus, and DDC byte-identity all remain as backstops, unchanged.

## Certificate format — options dispositioned

### A. Move-script certificate (RECOMMENDED)

The certificate is a placement script keyed by the canonical preorder walk
of `TCode` (the order emit-code already traverses: seq head then rest;
case branches in list order, then default). Per instruction point:

    step := { pre:  [ (vreg, from-loc, to-loc) ... ]   ; spills/fills/moves
              src:  operand -> loc                      ; where a/b are read
              dst:  loc }                               ; where the result lands
    loc  := (reg r) | (slot s)                          ; s indexes the SPILL frame

plus per-function: `spill-slots n` (the new, smaller frame) and the used
register set. Tail calls carry their arg-placement as an explicit `pre`
move sequence — **the parallel-move problem rd-param dodged becomes a
sequence of individually-verified single moves**; a cyclic shuffle needs a
scratch step and the checker just watches each move preserve the map.

Checker = one forward walk, in lockstep with the script: apply `pre`
moves to the map (a fill requires the slot to hold that vreg; a move
requires the source to hold it), check `src` locations actually hold the
operands' vregs, apply the op's `clb` kills plus the `dst` write, recurse
into branches with the branch-point map. A wrong certificate — double
assignment, value lost to a clobber, stale fill — fails at the read that
needed the fact, with the walk index in the error. Rejection is an alarm
at compile time, never a miscompile (element 3's shape: the license is
checked per artifact).

Why recommended: soundness is local (no liveness, no dominance, no
interval reasoning **in the TCB** — the allocator does liveness, and a
liveness bug surfaces as a failed read check); the checker is the third
instance of a pattern already trusted twice (cenv, res); the walk-index
keying is computable identically by checker and emitter with no new IR.

### B. Interval certificate (REJECTED)

Linear-scan style: per-vreg live interval + assignment; checker verifies
interval containment of uses and non-overlap per register. Requires
linearizing tree code into a point numbering AND re-deriving use positions
in the checker — that is liveness analysis creeping into the TCB, the
exact thing the certificate shape exists to keep out. More checker code,
weaker locality of rejection. Nothing it buys that A doesn't.

### C. Per-block entry/exit contracts (REJECTED as separate option)

Entry/exit location maps per block, locally checked. With terminator-only
tree code there are no rejoining edges, so the contracts degenerate into
exactly A's branch-point maps — C is A with extra ceremony today. Revisit
only if tal ever grows join points (it deliberately doesn't).

## Decided sub-calls (decidable; checked against code, not taste)

- **Checked per compile, every artifact** — like preserve-check
  (`optimize()` ends in `tal.check_fn`); no caching of trust.
- **Allocator must be deterministic** — not for soundness (the checker
  covers that) but for D-2: byte-identity requires the cert be a pure
  function of the input. Pinned by the existing per-discipline
  determinism test the moment rd-packed joins `DISCIPLINES`.
- **First-cut register pool: caller-saved only** (rdx rsi rdi r8 r9 r10
  r11 as value homes; rax/rcx stay the ALU staging pair so every op-bytes
  encoding is reused unchanged — packed mode replaces 7-byte slot
  loads/stores around the ALU with 3-byte reg movs, which is where the
  latency was). Callee-saved (rbx r12–r15) is a later increment: it needs
  prologue save/restore verification in the checker, and nothing in the
  measured residual needs it (the hot loops are self-tail-calls; calls
  that kill caller-saved are outside them).
- **Homes now, ports later**: allocator = new untrusted module
  (`scaffold/chirality/regalloc.py` first; any strategy may replace it);
  checker = trusted, beside the tal checker; both port with E16/E17. The
  gate: rd-packed joins `test_regdisc.DISCIPLINES` (corpus agreement +
  determinism) plus a new alarm pin — a deliberately-corrupted certificate
  must be REJECTED (the `test_illtyped_pass_output_is_rejected` shape).

## Open residue (stays open after ratification)

- Fact-carrying lowering (E9×E16) would let refinement facts strengthen
  the allocator (e.g. rematerialize a proven-constant instead of
  spilling); the certificate format above doesn't block it — a remat step
  is just a `pre` move from a const, addable later.
- The certificate as a *serialized* artifact (for the superoptimizer's
  pattern cache, D-2 pregen) — format above is in-memory; serialization
  is a later, mechanical step.
