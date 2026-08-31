# SELF-HOST PLAN — deliverables by 2026-07-30

Produced 2026-07-22 from the effect-decision + audit + reach-mapping arc.
Deliverables: (1) this plan, (2) worked-example coverage of the self-host
critical path (every gating element drafted in `examples/`), on the schedule
below. Companion artifacts: `DELEGATION-MAP-2026-07-21.md` (who runs what),
`examples/PLAN-2026-07-21-effect-algebra.md` (the effect batch, gates DONE),
`DECISION-DOCKET.md` (D1, D2 resolved; D3 direction below; D4–D7 open).

## What "self-hosted" means here

**Zero CPython anywhere in the check/compile/run path.** Rung 1: self-hosted
*on Linux* (kernel grants us syscalls; judgment + authority roots real, secret
root degraded — no register custody under a preemptive kernel we don't
control). Rung 2: chirality-as-OS on metal (E42 critical sections + register
custody; the full SECURE-DATUM story). **Rung 1 completes ownership; rung 2
completes sovereignty.** This plan targets rung 1; rung 2 items are seated,
not scheduled.

## The two goals, decomposed (what the names hide)

**Rung-1 metatheory blocker set — DECIDED 2026-07-22 (required wave, each
checked against the checker's own source):** exactly ONE element blocks
self-hosting the checker as *classifiable-total* — **E50 mutual + lexicographic
termination, cheap tier** (a declared shared structural measure per recursion
group + lexicographic for conv-under-unfolding; full size-change deferred).
The other three self-removed: **E48** (dependent records) is NOT a blocker —
the extrinsic/LCF checker manipulates raw `Term` sums + `(Qty,Term)` context,
no value-dependent field in its own records; bounded `data.py:134` completeness
extension. **E47** (sized types) deferred — promotes single-function decrease,
irrelevant to the mutual heart; gate on a post-E50 audit of the ported source.
**E45** (reflective floor) folds into the kernel-core port as the `SigB`→
`Frozen` split (interim floor is discipline, the settled rung boundary;
enforcement lands at self-host). So the judgment-core self-host critical path
is E50-cheap-tier, not a four-element wave.

**Strong judgment core** = four programs:
1. Carrier completion — Pi seats: quantities (built) + effect row
   (decision-effect-facets; E39) + grades (E38) + totality mark (built,
   enforce via E11-EXTEND/E47/E50). Seat count frozen; composition law in
   kernel-spec.
2. The E52 split made real — kernel-spec as an artifact, kernel-core as
   derivation checker, elaborator emitting the first certificates. Until then
   the LCF trust story is prose.
3. Totality as enforcement + erasure completion.
4. Self-applicability — the judgment must type the checker's own source:
   E27 maps, E48 telescopes, E50 mutual/lexicographic, likely E47 sized.

**Actual self-hosting** = mostly *lowering*, not porting:
- E70 effectful lowering (the compiler is effectful; only pure arrows lower
  today) — gated on implementing E39's row + tal shadow. **Head of the
  critical path.**
- E69 closure conversion + quantities-to-tal (NbE is made of closures).
- Syscall bank E28–E33 complete + E51 linkage (sys-tal the only transport).
- E34 ELF + E20 loader endgame (a binary Python never loads).
- E71 golden-semantics restructure (what "reference" means once the Python
  TalMachine is evicted).
- Stage1==Stage2 fixpoint (determinism debts: ordering, encoding) + E53 DDC.
  The last Python to die is kernel.py, verified by fixpoint+DDC, not review.
  **GATE (E53 pre-run, 2026-07-22): the determinism debts — E8's `repr`
  canonicalization, ordering/encoding pins, the serialized certificate
  encoding — must be PAID BEFORE the kernel port begins**, or the DDC legs
  and the fixpoint can never bit-agree; sequencing them after the port
  strands it.

## The root story (decided; consolidated here for the plan)

Three roots meet at boot (bootstrap-sequence, SECURE-DATUM-MODEL): **secret
root** = register root (derive-not-store; exponential-cost guarantee);
**judgment root** = bootstrap floor, cross-checked tuned runtimes at
agreement tier (the legitimately-unprovable residue; D7 independence);
**authority root** = the initial linear port supply minted against hardware.
Trusted base = "the register root plus the agreement mechanism."

**D3 direction (from the all-chirality-mesh framing, 2026-07-22):** all dynamism
is mesh dynamism — spawn/teardown, never live mutation. Authority flows down
the spawn tree attenuation-only (no refresh-gains-authority; inexpressible,
not forbidden). The reflective-floor line: *a runtime's judgment
(kernel-core + spec) is staged-in, never granted-to, never swappable after
staging completes* — E45's mechanism reduces to freezing `Sig` at
link/install completion. Succession wall: no uncertified succession — a
staged successor's core is certified against kernel-spec by the stager's
core; a mis-checked child degrades to a B-blob bounded by its granted ports.
Residues: the root terminates the regress at boot (pre-language); state
handover across relaunch (edge 14); staging economics (E33/arena, unmeasured).

## Ownership requirements (pinned; they gate the ship-form)

1. **Spec-size budget.** You own the language iff you can read kernel-spec in
   a sitting and audit kernel-core against it. Every carrier seat spends this
   budget. Goes into E52's scope as an explicit constraint, not taste.
2. **Re-bootstrap artifact (E72, minted this pass).** The shipped form must
   contain its own re-derivation: spec + a reference semantics simple enough
   to reimplement in a weekend in anything, + DDC to check the climb. No
   trusted binary in the forever-story. E71 should resolve spec-as-golden
   with this as a stated requirement.
- Owed later, not this window: `target-hostile-net` — the receive-surface
  requirement type (no authority-bearing crossing off-profile, total
  pre-auth recognizer, cost-bounded parse); exercises D6/E61, edges 14/17,
  E44/E60, rung 2.

## Worked-example production schedule (7/22 → 7/30)

25/71 drafted before this window. Missing self-host-critical: E5, E7, E8,
E30, E31, E32, E34, E38, E39, E51, E52, E53, E69, E70, E71, E72 (+ E12/E26
reworks). Waves of ~3 per the working cadence; agents pass `--no-index`;
orchestrator appends INDEX rows from reported
`{element, slug, title, kind, reference_class}`.

| Date | Wave | Elements |
|---|---|---|
| 7/22 | 1 | **DONE** — E39 `effect-row` (hypothesis VERIFIED, two sharpenings recorded in decision-effect-facets), E51 `sys-linkage` (surfaced the fd-view question, below), E26 reworked |
| 7/23 | 2 | **DONE 7/22 (early)** — E12 reworked (abstract row algebra), E70 (surfaced: the E51 binding table is a certificate-bearing artifact), E69 (defunctionalization now, revisit at E57; capture records make E39's law structural) |
| 7/24 | 3 | **DONE 7/22 (early)** — E71 (recommends spec-as-golden — AUTHOR CALL PENDING), E38 (carrier slice; surfaced ω-absorption-per-factor), E5 (surfaced: parametric-semiring E69-vs-E17 dependency fork) |
| 7/25 | 4 | **DONE 7/22 (early)** — E7, E8 (E8 surfaced: seen-set keys on Python `repr` — fixpoint determinism debt); E34 (surfaced: the entry stub — who captures the psABI entry stack) |
| 7/26 | 5 | **DONE 7/22 (early)** — E30 (structs-at-the-floor: multi-byte LE stores = shared tal vocabulary, edge 6), E31 (N-ary linear collections forced — `(List Sock)` is forbidden by design), E32 (env-get is a row entry with NO syscall ⇒ the row is not a syscall list — E39 representation input). All four SPEC elements carry script-derived ref banks in `examples/refs/` (regen-verified deterministic; fdpass self-asserting) |
| 7/27–28 | 6 | **DONE 7/22 — CORPUS COMPLETE.** E52 (conversion-evidence tier = the TCB-size call, author's; certificate format = D3's succession payload), E53 (determinism debts are PRE-PORT gates or legs never bit-agree; scaffold retires into leg 1), E72 (climb enters at the tal floor; "no trusted binary" sharpened to "no unverifiable artifact"). Author review of all three still owed before status advances past drafted. |
| 7/29 | review | status pass drafted→reviewed, INDEX + CLAUDE.md counts reconciled, this plan updated with slips; **expanded scope:** full-corpus staleness + snippet-soundness audit over the 25 pre-decision examples (Wave-1 style — the E51 double-use class; all drafted before decision-effect-facets) |
| 7/30 | ship | buffer; plan + corpus declared |

Elements deliberately NOT in this window: E14/E23/E37 (low/disappearing),
E64–E68 EXTENDs (no example owed), E40-full/E54–E63 (trust/custody lane —
gated on D3–D7 sessions), E42 (rung 2), E47/E48/E50 (judgment features —
after the carrier stabilizes).

## Open questions surfaced by the waves (feed the review pass)

- **`fd-view` privilege (E51 pre-run, 2026-07-22):** who may open an opaque
  port atom to its raw integer at the syscall crossing. Must be expressible
  ONLY inside the sysface-marked bridge or port opacity is decorative — the
  possession→machine-word conversion point has no named holder in the design
  yet. Candidate: a view crossing minted only by the sys library itself,
  confined the way `sysface` marks are.

## Standing constraints

- One element per run; a pre-run writes ONLY under `examples/`; never
  implements in the same run (CLAUDE.md hard conventions).
- Wave agents read the pack bundle + `_CHEATSHEET.md` (now two-facet-current)
  + cite `decision-effect-facets` — never the stale pre-decision framing.
- E39's example is the *verification vehicle* for the zero-new-kernel-forms
  hypothesis; if it falsifies, decision-effect-facets gets a dated amendment,
  not a silent patch.
