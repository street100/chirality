# Edge candidates — mined from the 2026-07-22 session

Proposals for author review, mined from the effect-decision arc, bank audit,
root/self-host mapping, ownership/vision discussion, Wave-1 examples + audit,
and the D-walk. **This file edits nothing**: the consolidation pass owns
`open-edges.md`/docket updates (its D3/D5/D6 captures were already landing in
edges 5/7/8 when this was written and are accounted for below). Triage classes:
**PROMOTE** (deserves a durable edge / doc item), **ARTIFACT** (correctly lives
in its E-row, example §6, or the plan), **COVERED** (already durably captured
or being captured by the consolidation pass).

## PROMOTE — new durable edges or doc items

- **C1 · The fd-view privilege.** Which layer may open an opaque port atom to
  its raw machine word for a syscall crossing — must be mintable only inside
  the sysface-marked bridge or opacity is decorative; and the view is forced
  by QTT to *thread the atom back* (no borrowing — `FdView` result shape, the
  RecvR pattern). Surfaced: E51 pre-run + audit; carried only by
  SELF-HOST-PLAN §open-questions. Sits between [[category-bridge]] and
  [[modules-lowering]] (the sys face). Nothing in the design names the holder.
  → promote to a numbered edge (it is the possession→machine-word seam, and
  every lane-A crossing will replicate whatever E51 decides).

- **C2 · The minting accountant.** "Ports are minted from a linear supply
  against real finite capacity" — who verifies *real finite capacity* at mint
  time, at what altitude, against what evidence? The mint is a C-bridge with
  an allocator's obligations, renamed. Surfaced: adversary-notes item 2
  (parked 2026-07-21), unresolved anywhere. Sits between [[node-architecture]]
  and [[memory-model]] (couples the bootstrap authority root: the first supply
  is minted by the floor). → promote; it is the root of the attenuation
  lattice the D3/D6 story now leans on.

- **C3 · Closure environment typing (capture visibility).** E39's soundness
  rides bind/apply-site usage accounting precisely *because* closure types do
  not record capture — but E69 (closure conversion) must lower closures to
  explicit environments at the floor, where the capture set becomes concrete
  data. Does the tal-level closure record carry quantity/port information (so
  the floor can re-check what the upper level knew only by accounting), or is
  erasure of capture info below the judgment acceptable? Surfaced: E39
  sharpening 1 + Wave-1 audit. Sits between [[modules-core]] and
  [[modules-lowering]]; gates E69/E70. → promote; this is a
  no-untyped-bottom question, not an implementation detail.

- **C4 · Syscall-number gating: allowlist vs frozen extern table.** The `sys`
  instruction takes an arbitrary numeric immediate; confinement is the
  sysface mark + no-surface-path (trust-boundary names it; adversary-note 4
  calls it P1's own seccomp parable). Post-E51 the extern→sys-tal table *is*
  a de-facto allowlist — should the tal checker enforce number∈table
  structurally, or is table-membership at link time the honest rung?
  Surfaced: parked note 4 + E51 scope. Sits between [[trust-boundary]] and
  [[modules-lowering]]. → promote (small); resolves the last live adversary
  note with a mechanism decision.

- **C5 · Never / empty type.** Does the kernel need first-class bottom
  (`halt : … Never`), or is a 0-constructor `data` sufficient — and what does
  case-coverage say over it? Surfaced: E26 rework §6. Sits inside
  [[modules-core]] (data/totality seam). → promote (small); every
  alarm-path signature wants the answer.

- **C6 · Dev-profile ambient threading mechanism.** decision-effect-facets
  answers trace virality by decision-profiles default-flipping ("the cap
  auto-threaded by elaboration, port set unchanged") — but no mechanism for
  profile-parameterized elaboration exists or is designed. Surfaced: effect
  decision, named costs. Sits between [[decision-profiles]] and
  [[decision-effect-facets]]. → promote (small) or fold into E39's reshape
  scope explicitly; currently homeless.

- **C7 · Spec-size budget as a checkable constraint.** Ownership requires
  kernel-spec "readable in a sitting"; the plan pins it as an E52 scope
  constraint but nothing says how it is *held* (a line/pages ceiling? a
  ledger-lint rule? reviewer discipline?). Surfaced: ownership discussion +
  SELF-HOST-PLAN. Sits between [[decision-split-checker]] and the E52 row.
  → promote as an explicit E52 acceptance criterion (doc item, not an edge).

- **C8 · Rung-1 secret-root degradation statement.** On a preemptive OS we
  don't control, register custody is unavailable (spills on context switch);
  the two-rung ladder lives only in SELF-HOST-PLAN. [[trust-boundary]] should
  carry the honest rung-1 statement (what secret custody means under Linux:
  OS-trusted, no register root) so the security claims ladder is durable.
  → promote as a trust-boundary addendum (doc item).

- **C9 · target-hostile-net.** The receive-surface requirement type (no
  authority-bearing crossing off-profile; total, cost-bounded pre-auth
  recognizer; alarm-on-divergence), exercising edges 7/14/17, E44/E60, rung 2.
  Offered and author-acknowledged in conversation only. → promote as a target
  note (the repo's own mechanism for pinning goals; G9 requirement type).

- **C10 · Tier-weight composition rule.** The type carries tier weight
  ([[vocabulary]]) but no rule says how it composes/subtypes across a
  composite — D4's one blank-page fragment. Sits inside [[decision-profiles]]
  (edge 18's list names it but the D-walk sharpened it to a distinct design
  item). → promote as an explicit sub-item if the consolidation pass's
  edge-18 update doesn't already isolate it.

## ARTIFACT — correctly living where they are

- **C11 · errno taxonomy** (one sum vs per-family; which errnos are alarms) —
  E51 §6; implementation-run choice.
- **C12 · bridge.verify depth/placement on the sys-tal return path** — E51 §6.
- **C13 · Staging economics** (spawn cost, arena churn, fine-grained-mesh
  liveness bet) — named in edge 5's sharpening as "unmeasured"; the number
  itself is the real-desktop/measurement work, plan-tracked.
- **C14 · Fixpoint determinism debts** (dict ordering, encoding pinning) —
  trust-boundary names them; SELF-HOST-PLAN carries them; they resolve by
  E-work (E27 ordered maps chose determinism for exactly this).
- **C15 · KontMsg protocol-type conventions + the quantity-1 continuation
  extern convention** — E39 §6 / decision-note verification section; E39's
  implementation enforces at call sites.

## COVERED — durably captured (or landing via the consolidation pass)

- State handover across relaunch → named in edge 5's sharpened text (rides
  edge 14).
- Succession certification direction → edge 5 sharpening; its *home decision
  note* is explicitly owed there.
- E61 home-referenced vs attenuation-chains → edge 7's updated text names it.
- In-doubt grant expiry/re-key → edge 7's zero-trust completion names the
  mechanism; detailed window design couples [[time-and-clocks]] (existing
  edge-19/20 neighborhood) — flag only if the consolidation pass drops it.
- Broker evidence-element selection + D13 residue audit → edge 8's updated
  text names both.
- Per-property compositionality catalogue + three-class framework → edge 18
  (consolidation pass, D4 capture).
- Recoverable-vs-fatal row-entry shape; row representation / row-variable /
  declared-row syntax → edge 16's residue list + decision-effect-facets
  (E39-owned).
- Row⇄sysface correspondence → E70 row names it as its opening question.
- Ambient-cap reification worklist (Console/Clock/Env) → decision-effect-facets
  + E39/E12 scope. *Slotted 2026-08-01 as **E80** (profile-grants-to-entry,
  catalog §VI) — the E29 author call resolved to build, not defer.*
- Continuation mobility boundary (within-node only) → decision-effect-facets.
- D7 axes bought-vs-asserted → docket D7 already frames it as the budget call.
