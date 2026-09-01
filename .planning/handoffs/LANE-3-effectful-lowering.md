# LANE 3 — effectful lowering (E70) + closure conversion (E69)

Read `../HANDOFF.md` first. **Gated on Lane 1** (needs the effect row to shadow).

## Goal
Make the effectful, closure-heavy compiler/checker able to **go native**. Today
only pure, unrestricted-arrow, closure-free code lowers — and the checker is none
of those. Two elements:
- **E70**: the effect row's **tal shadow** + preserve-check over the effect claim,
  making `=>` arrows lowerable.
- **E69**: closure conversion + carrying quantities (0/1/ω) to the floor.

## Rests on (read these)
- `examples/E70-effectful-lowering.md` — the shadow + the extended preserve-check.
  **Key finding:** the E51 binding table is a *certificate-bearing* artifact — the
  check must run *across* it (shadow in upper crossing-names, body in floor
  symbols, table presented as a re-checked mapping witness), not trust it.
- `examples/E69-closure-conversion.md` — **key finding:** defunctionalization
  (closed-world `case` dispatch, capture records as `[tag][fields]` cells) needs
  zero new tal type formers and re-derives E39's continuation-quantity law
  structurally. Honest now (batch-compiled); revisit at E57 staging (separate
  compilation). The capture record must carry quantities (a port-capturing
  closure is linear at the floor — EDGE-CANDIDATES C3).
- `scaffold/chirality/lower.py` (the `=>` eligibility gate), `tal.py` (`TalFn.sysface`
  — the row's one-entry floor prototype).

## The work (spec both first: `--spec`, then implement)
- **E70:** open the `=>` eligibility gate when the declared row is available;
  crossings compile to binding-table calls; extend `preserve-check` to re-derive
  the reachable floor-crossing set from the compiled body and demand it ⊆ the
  declared row shadow. A lowering/optimizer bug that introduces a crossing is a
  floor alarm, never shipped.
- **E69:** defunctionalize captures into `data`/`case` the existing lowering
  already handles; capture record fields carry quantities (0 erased, 1 linear);
  the converted body preserve-checks like any lowered code.

## Conformance gate
- The 11 tomodachi upper crossings lower and run with observables identical to
  the interpreter (differential, both floors).
- Every currently-lowered pure function re-checks with an empty row shadow.
- A `row-escape` (a crossing not in the declared shadow) is rejected at the floor.
- A port-capturing closure duplicated is rejected (the linear cell).

## Audit obligation
The tal-shadow vocabulary decision (check-across-the-table, not trust-the-table) —
verify the binding table is re-checked, not believed. Verify a converted
port-capturing closure is actually linear at the floor.

## Feeds
Lane 4 (crossings land on the binding table), Lane 5 (the checker can only go
native once effectful + closure code lowers).
