> **ARCHIVED 2026-09-01. Superseded by `LANES.md`, tracked, which is the live lane authority and defines TWO lanes (A diagnostics, B file types), not the six sequenced here.** The fixpoint this file sequences landed 2026-08-05.

# HANDOFF — rung-1 self-host BUILD lanes (the NEXT phase)

> **SUPERSEDED AS THE ENTRY POINT (2026-07-31).** The current priority is the
> **scoping wave** — flesh every drafted element to `audited` before more
> implementation. Start at `.planning/HANDOFF.md`. This file is preserved as the
> **build-phase roadmap** (the lane structure + fixpoint sequencing you execute
> once scoping is done). Some state lines below are snapshots (test counts,
> element ranges) — trust the repo, not this file.

Entry point for a **new chat** joining the rung-1 self-host build. Read this,
then the one `handoffs/LANE-*.md` for the lane you're executing. You do not need
this session's conversation — everything load-bearing is in the repo.

## What chirality is (30 seconds)
Dependently-typed language whose thesis is *a gap is an ungoverned path*: express
everything so everything is named and gateable. Modules are sliced by **modality**
(A proof / B substrate / C evidence), joined by four typed connectors. Orientation:
`README.md`, `CONTENTS.md`, `docs/index.md`, `PRINCIPLES.md`. The self-implementation
element list is `.planning/SELF-IMPLEMENT-CATALOG.md` (E1–E75; the 2026-07-26
edge-walk Batch A added §XI — **E73** outbound confinement, **E74** tier carrier,
**E75** typed ABI-layout).

## The goal right now
**Rung 1** = no-CPython self-host on Linux (Linux syscalls stay the floor — that's
"not full"), no application layer, principled logic + primitives as infallible as
Linux allows. Rung 2 (chirality-as-OS on metal + app layer) is later; do not scope it
here. Full rung model + roadmap: `.planning/SELF-HOST-PLAN.md`.

## Current state (verify, don't trust this line)
- Scaffold works on CPython: `cd scaffold && python3 -m unittest discover -s tests`
  (was ~281 green). Design lint: `python3 tools/ledger-lint/ledger-lint.py` (must be clean).
- Security today = **discipline, not enforcement** (TCB = CPython + Linux syscalls;
  `docs/trust-boundary.md`). Self-hosting is what converts it to enforcement.
- 44 worked examples drafted (`examples/INDEX.md`), covering the whole rung-1 path.
- Git initialized; commit per lane.

## The pipeline (per `CLAUDE.md`)
`worked-example` (drafted) → **`example-to-spec`** (`python3 tools/pack/pack.py E<#> --spec`
→ `.planning/specs/E<NN>-<slug>-SPEC.md`, status `specced`) → **implement** (an
agent follows the SPEC; the example stays the rationale). A spec run writes ONLY
under `.planning/specs/`. Implementation follows the SPEC's change plan and
conformance gate.

## The rung-1 build path (lanes)
Ordered by dependency; **prep is parallel and comes first**. Each has a handoff:

| Lane | Goal | Gate on | Handoff |
|------|------|---------|---------|
| **prep** | Pay determinism debts + build the DDC/differential compare harness | — (do first) | `handoffs/LANE-prep-determinism-ddc.md` |
| **1** | Effect row in the kernel (decision-effect-facets) | — | `handoffs/LANE-1-effect-row.md` |
| **2** | E50 mutual+lexicographic termination (cheap tier) | — | `handoffs/LANE-2-e50-termination.md` |
| **3** | Effectful lowering (E70) + closure conversion (E69) | lane 1 | `handoffs/LANE-3-effectful-lowering.md` |
| **4** | Syscall bank real (E28–E33) + E51 linkage → runtime-floor self-host | — (parallel) | `handoffs/LANE-4-syscall-floor.md` |
| **5** | Kernel port + E52 + E45 + fixpoint + DDC = full rung 1 | prep,1,2,3 | `handoffs/LANE-5-port-fixpoint.md` |

Lanes prep, 1, 2, 4 can run in parallel now. Lane 3 waits on 1. Lane 5 is the
serial convergence gate — the fixpoint — and waits on the rest.

**The one strategic fact:** the fixpoint (Stage1==Stage2, byte-identical) is
convergence-bound — it doesn't parallelize, and it's last. It converges cleanly
ONLY if the determinism debts are paid first (lane prep). Do prep before lane 5
or the fixpoint becomes a serial byte-diff hunt.

## Standing disciplines (how these chats work — non-negotiable)
1. **Audit agent output before propagating it.** Re-run gen-scripts, read the
   snippet, verify every cited `file:line` exists. This session caught real
   defects that way (a linear double-use, a wrong binder quantity). Producer
   output is untrusted until checked — the repo's own trust discipline, applied
   to the workflow.
2. **Verification scales with generation, or it's abuse.** When pumping work,
   auto-verify against machine-checkable ground truth: does it parse, do cited
   lines exist, does the conformance target map to a real test, do refs regen
   deterministically. Never let a firehose of artifacts outrun the checking.
3. **Decide decidable things; check the decision; don't defer by default.**
   Reserve "author's call" for genuine values/taste/scope. Everything
   architectural/engineering is yours to settle — settle it, then verify against
   the code or the settled decision docs.
4. **No unbidden agent spawns / batch spend.** The user drives wave cadence.
   "Keep going" is conversation direction, not a launch order. Get an explicit
   go that names the work.
5. **Trusted-core edits are reviewed as such.** Changes to `kernel.py`/terms/the
   carrier are the most sensitive class — show the diff explicitly, never bundle
   invisibly.

## Author calls (blocking — do NOT silently resolve)
- **D7** — **RESOLVED-IN-DIRECTION 2026-07-26**: reframed to two levels; level 1
  (bootstrap trust) = re-derivability + DDC (toolchain-diverse, authorship
  named-not-real), level 2 (operational agreement) was never D7's — it is
  floor-agreement's collapse/validate/fuzz. No author fork remains; residual is
  E62 build + E71 confirmation.
- **E71** spec-as-golden — **PROVISIONAL 2026-07-26 → spec-as-golden** (revisitable);
  catalog E71 + `floor-agreement.md` banner.
- **E52** conversion-evidence tier — **RESOLVED 2026-07-26 → per-instance** (rerun/
  trace/cached chosen per certificate site); catalog E52.
- Triage pile: `.planning/EDGE-CANDIDATES-2026-07-22.md` (10 promote candidates)
  + the salvo findings in `SELF-HOST-PLAN.md`. (E73 outbound-confinement mint is
  now DONE — written as §XI E73, Batch A 2026-07-26.)

## Key references
- Decisions: `docs/decision-effect-facets.md`, `docs/decision-graded-kernel.md`,
  `docs/decision-split-checker.md`, `docs/decision-backend.md`.
- Depth: `docs/banks/*.md` (refractions — read before naming a gap). The effect
  reshape list is `docs/banks/effect-and-alarm.md` §5a.
- Status truth: `docs/status-ledger.md`, `docs/trust-boundary.md`.
- Plan/docket/catalog: `.planning/SELF-HOST-PLAN.md`, `DECISION-DOCKET.md`,
  `SELF-IMPLEMENT-CATALOG.md`.
