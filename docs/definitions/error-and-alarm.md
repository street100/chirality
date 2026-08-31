---
node: error-and-alarm
layer: module
implements: [category-typed, category-bridge]
related: [modules-core, modules-custody, modules-bridges, axis-typeability, open-edges, decision-effect-facets, banks/effect-and-alarm]
status: draft
updated: 2026-07-25
---

# Errors and alarms

What a detected divergence does at the language level. The whole C apparatus ends
in "divergence is the alarm." This is what the alarm is. Depth tier:
[[banks/effect-and-alarm]] — the shard-by-shard refraction, cross-cuts, and
build-state behind this note.

## An alarm is an effect

A detected divergence is not an out-of-band exception and not a silent failure. It
is raised as a typed effect, in the same port and effect algebra as everything
else (P3, P4). So it is on the membrane, named in the type, and total: every way a
thing can signal "this does not match the rest" is in the type, and code cannot
drop an alarm without the drop showing in its type. This is the thesis applied to
failure. An unnamed failure path would be the gap.

A divergence is distinct from non-termination. `totality` governs whether a
process ends; an alarm governs whether what it produced or read agrees with the
rest. Different effects. See [[modules-core]].

## The alarm is rich because everything is split

Because the design splits every truth (T1 copies compared, T3 verifiable split,
the C bridges, the audit trail), a divergence is never opaque. The matching logic,
"this does not agree with the rest," runs over the full cross-checked set, so the
alarm it raises carries what diverged from what: which copy disagreed (T1), which
share is bad, named by robust decoding (T3), which MAC failed, which attestation
or audit line did not reconcile. That detail is the material response forming works
with. An alarm here is diagnostic by construction, not a stringly "something went
wrong." See [[axis-typeability]] (the tier ladder) and [[modules-custody]].

## The response is a counter effect

The handler for an alarm is itself an effect, a counter effect, drawn from a named
set: re-key, re-derive from the register root, relocate, repair from survivors
(robust decoding corrects t bad shares), quarantine the diverged source, halt. So
the secure-datum detection-to-response loop is, at the language level, effect to
counter effect: a divergence raises an alarm, a counter effect answers it. See the
secure datum model and `runtime` in [[modules-bridges]].

## Recoverable or fatal is in the type

Whether an alarm is recoverable is whether a counter effect can restore agreement:
re-derive from the root, repair from survivors. Where it can, the process
continues; where it cannot, the counter effect is halt or quarantine. The type
says which, so a fatal divergence cannot be silently treated as recoverable.

How the type says it is now fixed ([[decision-effect-facets]], sharpened
2026-07-22 by the E39 worked example and discharged by its SPEC): the alarm's
handler signature carries a `KontMsg` protocol sum, and recoverable-vs-fatal is
which constructors that sum offers — `k-resume` and `k-cancel` means
recoverable, `k-cancel` alone means fatal. `data`/`case` enforce the
distinction structurally; it is not a row-entry shape and adds no carrier
field.

## Open

The mechanism is settled ([[decision-effect-facets]], 2026-07-21; edge 16
resolved): an alarm and its counter effects are crossings in the effect row; a
handler is the process at the other end of the port, with handler syntax
CPS-elaborating to ordinary linear closures — verified 2026-07-22 in the E39
worked example (zero new kernel forms; the continuation is ONE linear closure
over the `KontMsg` sum, never resume and cancel as two closures); a captured
continuation's resumption multiplicity is its QTT quantity (captured linear
ports force one-shot; repair-then-resume is the one-shot case), and the abort
path discharges by a synthesized cancel over the captured inventory, checked
by the existing linearity judgment. What remains open here: the row itself is
now **built** (E39 carrier edit landed 2026-07-28 — crossing-name rows on the
Pi seat, call-graph-inferred, containment-gated; Console reification and the
handler machinery remain), so typed alarms E26 are unblocked at the row level
and are the next construction; and
cross-node alarm propagation — shaped 2026-07-22 as ordinary port traffic
carrying alarm evidence. The loudness/subscription policy was **shaped
2026-07-25** (edge 17 edge-walk): loudness is **port-graph reachability** (no
ambient broadcast — an alarm reaches exactly the holders of ports to N, further
only by re-emission), subscription is **holding the alarm-carrying port** (the
alarm crossing in the port's row *is* the subscription, no separate ACL; push-vs-
poll is edge 14's continuation placement), and the "at what tier" leg is the
**outbound-confinement tier** of the rich evidence — which is **blocked on
outbound confinement being unbuilt** ([[banks/port]] Shard 5 / E44), the honest
residual. See [[open-edges]] (edges 16, 17).
