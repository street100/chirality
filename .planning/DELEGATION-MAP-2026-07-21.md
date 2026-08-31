# Delegation map — 2026-07-21

Toward the big jump: strong judgment core + actual self-hosting (= zero CPython
anywhere in the check/compile/run path). Partitioned by the house criterion,
which is the certificate discipline applied to workflow: **an agent is an
untrusted producer — delegate only where a trusted re-check already exists**
(SPEC conformance, differential oracle, preserve-check). Opus-managed sessions
are where the spec/checker itself is being authored — fork-bearing, back-and-
forth work.

## Agent lanes (parallel, low-touch; each names its oracle)

| Lane | Work | Oracle / re-check | Notes |
|------|------|-------------------|-------|
| A | Syscall bank: E28 (mmap/munmap/mprotect/close) → E29 (sockets) → E31 (poll) → E30 (fd-passing SCM_RIGHTS) → E32 (clock/exit/env) → E33 (spawn) | Linux ABI (SPEC) + differential vs real syscalls (sys-tal precedent) | Unblocked NOW. hand-tal pattern established in `lib/sys-tal.chiral`. E30 is the admitted hard one (cmsg layout); E32 first struct-returning. The E51 *linkage* stays in the Opus lane (gated on effect decision) — agents build the crossings, not the wiring. |
| B | E34 ELF writer + E20 loader follow-up (entry point, shed ctypes) | System V gABI (SPEC); readelf + execute-the-output | asm-reloc already does two-pass relocation; this is layout + headers. "No python" endgame needs this — a binary Python never loads. |
| C | E27 ordered maps (dict/set → chirality) | unit tests + differential vs Python dict semantics where used | ONE pre-decision needed first (10 min, Opus or inline): balanced tree, not hash — deterministic iteration is a fixpoint requirement, and the floor has compare but no hash prim. Then fully mechanical. |
| D | Pure OURS ports: E1 (sexp reader), E13 (de Bruijn walkers), E14 (pretty) | differential vs the Python originals, input-for-input | E13 is trusted-core-adjacent: mandatory differential harness, flag for review. All pure → lower/native-test today, no effect algebra needed. |
| E | Floor-agreement fuzz harness (generate well-typed tal, mutate, cross-check floors) | the reference interpreter IS the oracle | Development discipline named in floor-agreement.md, mechanism 3. Pure tooling. |
| F | E64–E68 EXTEND payloads (json surrogate prim on a bitwise floor, coordinator router/log/retry) | existing test suites + mock backends | Orchestration-lane hygiene; independent. |

## Opus-managed sessions (you drive the back-and-forth), in dependency order

1. **Effect-algebra arc completion** — decision note, graded-kernel amendment,
   cheatsheet delta, INDEX flags. (This session's program; PLAN-2026-07-21-
   effect-algebra.md is the input.)
2. **Worked examples E39 + E26/E12 rework + E51** — design-carrying pre-runs;
   the pack mechanics allow agents but the content encodes fresh design, so
   manage these, don't fire-and-forget.
3. **Carrier + effects module build** — the row seat lands in kernel-spec/core
   (trusted-core edit class), row inference in the elaborator, tal shadow +
   preserve-check extension.
4. **Effectful lowering + closure conversion** — mint the missing catalog rows
   first (they have NO E-numbers today), then design: closure representation at
   the floor, environment layout vs arena, quantities-to-tal. Highest fork
   density after the effect arc; the compiler cannot go native without it.
5. **E52: kernel-spec artifact + kernel-core + certificate format** — the
   authored socket everything else plugs into. Elaborator emits the first
   certificates here. Maximal sensitivity; never delegate.
6. **E38 graded semiring** — second carrier enrichment; interacts with
   refinement entailment.
7. **Golden-semantics restructure + fixpoint/DDC strategy** — what "reference"
   means once the Python TalMachine is evicted (chirality reference executor vs
   spec-as-golden); Stage1==Stage2 determinism debts (ordering, encoding);
   E53 DDC. Decision-note session; DDC *execution* can later go to an agent.
8. **Judgment features for self-applicability** — totality enforcement, E48
   telescopes, E47 sized types, E50 mutual/lexicographic. Kernel semantics;
   sequence after the carrier stabilizes.

## Interlocks

- Lane A/B/D products are testable today (differential harnesses exist or are
  lane E); nothing in them waits on the effect decision except E51 wiring.
- Session 4's catalog rows should be minted during session 1 (they're a
  paragraph each) so the reach is numbered even before it's designed.
- The last Python to die, by construction: `kernel.py` (session 5's port) —
  verified by fixpoint + DDC (session 7), not by review. That is the "actual"
  in actual self-hosting.
