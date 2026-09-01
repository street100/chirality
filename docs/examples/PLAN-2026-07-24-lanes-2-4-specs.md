# PLAN 2026-07-24 — lanes 2 + 4 spec wave

The `example-to-spec` wave that follows the 2026-07-24 example-audit gate for
lanes 2 (E50) and 4 (E28–E33, E51). Each reviewed example was turned into one
implementation SPEC under `docs/elements/specs/`. E29 was **excluded** — its
example-gate surfaced an unresolved author FLAG (`recv-closed` socket-threading)
that blocks its spec until answered.

Pipeline stage: `example → audit → **spec** → audit → implement`. This wave is
the **spec** stage. The next gate is the **spec-audit** wave
(`--audit spec` per element → `--mark audited`).

## Wave shape

- Parallel agents, one element per agent, each `--spec --no-index`; orchestrator
  patched the seven `reviewed → specced` INDEX rows + `[SPEC]` links afterward.
- Cadence: run in sub-waves of ≤4 to stay under the stream-watchdog stall that
  killed two agents (E28, E50) on the first attempt; both re-ran clean solo.
- Every SPEC verified structurally before its INDEX flip (six sections filled,
  no leftover template stubs, frontmatter status honest). Deep citation-truth
  is the spec-audit wave's job, not this one.

## Result — 7/7 SPECs written

| E# | Lane | SPEC status | Author disposition |
|----|------|-------------|--------------------|
| E50 | 2 | draft | clean — all 4 §6 Qs dispositioned (measure surface RESOLVED-interim + E49; size-change reserved; measure→cert → E52). Soundness REJECT test pinned. |
| E28 | 4 | draft | non-blocking NEEDS-AUTHOR: zeroize-on-drop expression (lives in deferred typed face, not the mprotect+close EXTEND). |
| E30 | 4 | **blocked** | **blocking NEEDS-AUTHOR: the edge-6 tal-store vocabulary** (see below). |
| E31 | 4 | draft | clean — put-i16/bget-i16 RESOLVED as LE composites of existing single-byte tal ops; N-ary collections → E8. |
| E32 | 4 | draft | non-blocking NEEDS-AUTHOR: `Clock` cap granularity (single `Clock` vs `Clock`/`Timer` split); provisional single-cap carried. |
| E33 | 4 | draft | non-blocking NEEDS-AUTHOR: execve-failure convention (exit-127 vs errno-over-CLOEXEC-pipe); provisional exit-127 carried. |
| E51 | 4 | draft | clean — fd-view privilege RESOLVED (frozen-port-set absence + sysface floor gate = two locks in series); errno alarm-vs-value → E39; row⇄sysface → E39+E70. |

## Author calls surfaced (do NOT silently resolve)

1. **E30 — blocking. Tal-store vocabulary ("structs at the floor", edge 6).**
   How does the floor store `u32`/`u64`/`ptr` at a computed offset into an
   existing byte cell? Two decided-and-checked facts narrow it: (a) `ti-put-ptr`
   *must* be a primitive (operand is a runtime address, non-decomposable);
   (b) principle 5 + the `ti-bput` precedent favor a first-class store-word
   opcode family. What remains genuinely author-tier: the **TCB scope** commitment
   — expand trusted `tal-ir` with `ti-put-u32/u64/ptr` opcodes (built across
   reference + fold + mach-x64 + the typed-assembly checker), and land it **in
   E30's run** or as a **prerequisite foundational element** shared by every
   future struct crossing. Sibling in kind to E52's TCB-size decision.

2. **E28 (non-blocking).** Zeroize-on-drop obligation for the deferred typed
   `munmap` — a special variant vs a general linear-`drop` hook. No settled doc
   governs a linear-`drop` hook; deferred face, so E28's EXTEND is unblocked.

3. **E32 (non-blocking).** `Clock` capability granularity — one cap over
   read+sleep, or split `Timer`. Single-cap provisional; splittable later
   without reshaping crossings.

4. **E33 (non-blocking).** execve-failure fidelity — exit-code-127 convention
   vs errno-over-a-CLOEXEC-pipe. exit-127 provisional (matches example §6);
   pipe is a clean later fidelity upgrade.

Plus the still-open **E29** example FLAG (`recv-closed`: caller-close vs
auto-close), which gates E29's own spec run.

## Baseline catches worth keeping

- **E33:** the existing `(extern spawn …)` in `ports.chiral` is the *staging*
  spawn (Popen into a child **chirality** runtime) — NOT E33's external-program
  subprocess. E33 is a sibling primitive, not a reshape.
- **E30:** only single-byte `ti-bput` exists in the live tal vocabulary;
  `nb-pack32` builds a *fresh* cell and cannot store a runtime pointer — which
  is what makes the E30 tal-store call a real substrate decision.
- **E28:** the true delta is exactly two crossings — `nb-sys-mprotect` (nr 10)
  and `nb-sys-close` (nr 3); mmap/munmap are already built and not respec'd.

## Next

- Answer the E30 blocking author call (and, at leisure, the three non-blocking
  ones + the E29 FLAG).
- Then the **spec-audit** wave: `python3 tools/pack/pack.py E<#> --audit spec`
  per element, `--mark audited` on PASS → implement-ready.
