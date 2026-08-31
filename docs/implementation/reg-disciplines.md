# Register disciplines: the strategy is a module, not a setting

Settled in discussion 2026-08-02. "Register allocation" is a conventional
monolith; here it refracts into shards with separate homes, and each
strategy is a NAMED, conformant module passing one shared gate
(`tests/test_regdisc.py`) — the same P4 shape as Machs, memory disciplines,
and profiles. This note is the design record; the gate is the enforcement.

## The refraction

| Shard | Decides | Home |
|---|---|---|
| Truthfulness tier | when slots must hold the real state (always / at labels / at calls / never) | the discipline's declared contract |
| Residency | which values are cached in which registers between ops | emit-core state (the cenv pattern) |
| Clobber model | per-op register effects (syscall kills rcx/r11, idiv owns rdx, div-fix scratches rsi/rdi/r8, calls kill caller-saved) | the Mach — ISA knowledge, to be made an explicit table |
| Placement | where params live; tail-call re-placement; callee-saved usage | discipline × Mach |
| Trust placement | trusted-emitter plugin vs certificate-checked producer | the tier rule below |

## The disciplines

- **rd-truthful** — pure memory machine, no caching; every slot truthful at
  every boundary. The audit / DDC / debug discipline. BUILT
  (`emit-truthful`).
- **rd-cache** — truthful stores + accumulator residency (the `x64-peep`
  overlay: fall-through reloads collapse, rcx reloads become reg moves).
  BUILT (`emit`, the current default). Note: on in-order/small cores the
  savings the OOO shadow hides on big cores COUNT — the firmware-profile
  case.
- **rd-param** — entry stores kept (slots stay truthful) + params resident
  in their SysV argument registers through the body and the tail-call
  back-edge. Kills the measured bottleneck: the loop-carried param
  round-trip through slots (see RESULTS run 8's convergence analysis and
  the disassembled spill/reload chain). BUILT + measured (run 9).
- **rd-packed** — slots retired; full allocation; the -O2-parity ceiling.
  The only tier that breaks truthfulness, and therefore the only one NOT
  eligible to be a trusted-emitter plugin — see the tier rule.

## The three settled calls (2026-08-02)

1. **No default is decided.** Build so the question dissolves: rd-param
   preserves truthfulness, so if it passes the same gate it can simply BE
   the default with no tradeoff taken — "the fast one fits in the tiny
   trust story" is the goal claim. A default gets chosen only when some
   tier forces a real cost.
2. **The trusted emitter IS modular** — because the trust was never in the
   singularity. Precedent: the Mach is pluggable and trusted via
   conformance + differential validation. What is frozen and trusted:
   emit-core + the gate. **Tier rule:** truthfulness-preserving disciplines
   ride that story as small plugins; truthfulness-breaking tiers
   (rd-packed) graduate to the certificate shape — untrusted allocator
   proposes, an independent placement check verifies — outside the TCB.
3. **Compile parameter now, profile clause later.**
   `NativeBackend(discipline=...)` keys chirality emit globals by name; a
   `(regs <disc>)` profile clause (beside `(memory linear)`) binds by the
   same names with zero rework, and gets added when two profiles actually
   diverge.

## The gate (what conformance means)

Per discipline: (1) reference-floor agreement on the differential corpus
(division edges incl. INT_MIN, TCO loops, fused guards, both table kinds);
(2) determinism — two independent backends, byte-identical artifacts (the
D-2 property, per discipline); (3) the declared truthfulness tier's
contract pins (`TestPeepholeContract` for the overlay patterns); (4)
refinement ordering where declared — rd-cache emits the same label set as
rd-truthful with strictly tighter code.

## Build order

1. DONE — name the two built disciplines; discipline-selectable backend;
   the parametrized gate.
2. DONE — the clobber table: the `clb` Mach face maps op keys to
   argument-register indices (0=rdi..5=r9); x64 table in `mach-x64.chiral`
   (calls/syscalls kill all six; div family {0,1,2,3,4}; mulhi/bpt {2,3};
   proven-clean set {}; default {3}=rcx). Spot-pinned in test_regdisc;
   fully validated the moment rd-param consumes it (a wrong entry is a
   differential failure).
3. DONE (2026-08-02) — rd-param: residency map threaded through emit-core
   (cenv pattern), killed by redefinition + the clb table; binr/binir/
   fcpr/fcir source a-operands from resident argregs; ldr places
   pass-through tail-call args for ZERO bytes (position-identical only —
   the parallel-move hazard is dodged, others use truthful slots).
   Measured (RESULTS run 9): states -17%, bytesum -8%, arith flat (acc in
   rdx, killed by mulhi — honest residual). Passed the same gate as
   rd-truthful: fast-in-tiny achieved.
4. IN PROGRESS (2026-08-02) — rd-packed via the certificate shape, never
   as a trusted plugin. Certificate format RATIFIED: the move-script
   certificate + forward-symbolic-walk checker, `rd-packed-cert.md`.
