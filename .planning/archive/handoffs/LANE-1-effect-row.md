> **ARCHIVED 2026-09-01. Superseded by `docs/decisions/decision-effect-facets.md`, `docs/examples/E39-effect-row.md` and `docs/banks/effect-and-alarm.md`, all tracked.** E39 steps 1-6 are built. The residue, the seams that REFUSE, is tracked as E171 in `docs/elements/ledger.md`, and the conformance gate this file states is exactly E171 unbuilt claim.

# LANE 1 — effect row in the kernel (milestone 1)

Read `../HANDOFF.md` first. No upstream gate. This is the trusted-core change the
whole effect/self-host lane rests on.

## Goal
Implement `docs/decision-effect-facets.md`: the effect **row** on the Pi carrier —
the *exercise* facet (crossings a term performs) beside the *possession* facet
(linear ports held), joined by construction. The one-bit `->`/`=>` membrane
becomes the empty/nonempty projection of the row.

## Rests on (read these)
- `docs/decision-effect-facets.md` — the settled shape. Note the **verified**
  result: handler syntax CPS-elaborates to linear closures, **zero new kernel
  term forms** (E39). And the two sharpenings: continuation multiplicity = its
  QTT quantity (enforced at bind/apply usage accounting, not the linear-kind
  hook); continuation = one linear closure over a `KontMsg` sum.
- `examples/E39-effect-row.md` — the algebra + the verified elaboration.
- `examples/E12-effect-membrane.md` — the three membrane seams reworked to
  set-containment (abstract row algebra — representation is this lane's call).
- `docs/banks/effect-and-alarm.md` §5a — **the exact reshape list**.

## The work (spec first: `python3 tools/pack/pack.py E39 --spec`, then implement)
Per the §5a reshape list:
- `terms.py`: Pi position-2 field `bool → row`.
- `kernel.py:292` (conv): keeps row *equality*; row *subsumption* = a new
  VPi case in `subtype` (`kernel.py:315`), contravariant domains
  (corrected 2026-07-22 — see E39-SPEC Step 3; subsumption inside symmetric
  conv is unsound).
- `effects.py` `on_apply`/`erased_allow`: boolean → **set-containment** (erased
  position demands **empty row AND total** — the totality tie is Lane 2).
- `surface.py:372`: per-arrow row attachment.
- **Cap reification:** the ambient writers (`print`/`put`/`trace`,
  `lib/ports.chiral:70–72`) get a reified **Console** capability handed to
  `main` by the profile — closes the no-ambient-authority violation
  `decision-effect-facets` names. *(Correction 2026-07-27: `Clock`/`Timer`/
  `Env` reification of `time-mono`/`sleep-ms`/`env-get` is now **E32's** —
  its SPEC decision #4, author-resolved, split Clock/Timer — not Lane 1's.)*
- **Reserve carrier seats** (`docs/syntax-evolution.md`): the row seat lands
  beside the reserved grade-vector and implicit-arg slots. Freeze the seat count
  now; do not fork the slot.

## Conformance gate
- Every membrane test green with the bit read as the empty/nonempty row
  projection.
- The **pure-plumbing** case is accepted: a `->` function that repacks a `RecvR`
  (holds a Sock, crosses nothing) stays pure. Holding ≠ crossing.
- A nonempty-row call inside a `->` context is rejected.
- Row inferred from the call graph (transitive extern crossings), not from
  port-holding.

## Audit obligation
**Trusted-core edit.** Show the carrier diff explicitly (`(q, eff, dom, cod)` →
`(q, seats⟨row, grades, totality⟩, dom, cod)` with the full seat set frozen —
see E39-SPEC Step 2). Review it as a kernel change, not a module change. Verify
`subtype`'s subsumption is sound (a wider row cannot flow into a narrower
context; domains contravariant) and that `conv` stays symmetric equality.

## Feeds
Lane 3 (effectful lowering needs the row to shadow), Lane 4 (E51 threads the row
through the sys seam), E26 alarms (crossings in the row).
