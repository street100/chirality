# LANE 2 — E50 mutual + lexicographic termination (the one metatheory blocker)

Read `../HANDOFF.md` first. No upstream gate.

## Goal
Implement E50 (cheap tier): a **recursion-group** termination analysis so the
self-hosted checker — whose heart is mutually recursive (`infer`/`check`,
`eval`/`quote`/`conv`) — can be classified **total over its own source**. This is
the single metatheory element that blocks self-hosting the checker as
classifiable-total. E48 (telescopes) and E47 (sized types) were verified NOT
blockers this session — do not build them for this.

## Rests on (read these)
- `examples/E50-mutual-lex-termination.md` — the mechanism and the key finding:
  **a declared shared structural measure suffices**, not full size-change graphs.
  `infer`/`check` share the subject term (non-increasing on every intra-group
  edge, strictly decreasing around every cycle); lexicographic tuple
  `(fuel, term)` covers conv-under-unfolding. Full size-change is a reserved
  fallback only for argument-permuting groups the checker lacks.
- `scaffold/chirality/data.py:669` — the current blocker (mutual recursion raises
  `_NotStructural`, "not yet checked for totality").
- `docs/totality.md` — the enforcement seam (`sig.totality`, `sig.require_total`,
  the `(total)` profile clause) this classifies into, unchanged.

## The work (spec first: `python3 tools/pack/pack.py E50 --spec`, then implement)
- A recursion group names its members + one shared structural measure argument.
- The checker verifies: every intra-group call passes a sub-term-or-equal of the
  measured argument, and every cycle strictly decreases it.
- Lexicographic tuple for nested descent (conv under definition-unfolding).
- Classify via `sig.totality` (record `None` = proven when the measure holds);
  enforcement stays on-demand (unchanged).
- Full size-change stays a reserved fallback — do not build it now.

## Conformance gate
- The `infer`/`check` and `eval`/`quote`/`conv` groups classify total by the
  shared measure.
- Existing `TestTermination` stays green.
- A **false** measure (a group that doesn't actually decrease) is REJECTED — the
  negative test is the soundness guarantee.

## Audit obligation
Verify soundness: the analysis must NEVER accept a non-terminating group. Check
the "non-increasing on every edge, strictly decreasing around every cycle"
condition is actually enforced, not approximated. This is trusted-core-adjacent
(totality feeds the "infallible" claim).

## Feeds
The kernel port (Lane 5) — the ported checker must classify total over itself,
which requires this. Post-landing: audit whether any single-recursive checker
function needs E47 sized types (the deferred gate).
