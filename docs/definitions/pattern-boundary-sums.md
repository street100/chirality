# pattern: boundary sums — parse once, reasons as values

**Standing directive (author, 2026-08-09): apply this as much as physically
possible.** Every artifact in the example → spec → implement pipeline is
expected to prefer it; the audit charters may treat a string/sentinel where a
sum belongs as a finding.

## The pattern

When a boundary classifies something — an op name, a skip reason, a syscall
result, a request kind, a verdict — **retype the classification as a closed
sum at the boundary** and pass the value downstream. Never a `Str` tag, a
sentinel integer, a log line, or a downstream re-check.

The general form (literature name: *parse, don't validate*): validation
produces a boolean and throws the evidence away; parsing produces a **value
that carries the evidence**, so downstream code cannot be wrong about it.
In chirality this lands with unusual force because of two substrate facts:

1. **Coverage is checked.** A `case` over a closed sum is exhaustive by the
   kernel; adding a constructor breaks every consumer AT CHECK TIME. A string
   tag drifts silently (the band cascade of 2026-08 was exactly this class:
   membership knowledge duplicated as a string set in one place and a case in
   another).
2. **Purity is a typed fact.** A lookup that cannot fail needs no defensive
   `halt` — and `halt` is a crossing. Parsing once at the boundary is what
   keeps downstream functions OFF the effect membrane. The sum is not just
   safer; it is what makes the pure fragment bigger.

## The test (use it in audits)

- If a `Str` or `I64` in a signature encodes *which-of-N-things*, it is a sum
  wearing a disguise. Mint the sum.
- If information exists at point A and is re-derived (or absent) at point B,
  carry it as a constructor field instead.
- If a failure path's diagnosis lives in a log line, retype it: the diagnosis
  is a value the failure CARRIES.

## Live precedents (cite these, mirror these)

- **The closed `Op` sum (E70)** — op names are parsed once at the erase
  boundary (`tal-erase.chiral` op-parse, the former native-prims membership
  test) into `(data Op () (op-add) ... (op-band))`. Every downstream consumer
  (`op-bytes`, `bini-body`, emit) cases totally. The mach-x64 comment records
  the payoff: *"no defensive 'unknown prim' halt, hence op-bytes is PURE.
  That purity is what keeps emit-instr off the effect membrane."*
- **`SkReason` (E97, drafted 2026-08-09)** — the exemplar this note was minted
  for. B1's lowering used to skip a def with a `Str` reason that was discarded
  (compile-back.chiral:225); the only symptom was "no emitted label for entry"
  and it produced three consecutive misdiagnoses. The retype:
  `(data SkReason () (sk-extern (op Str)) (sk-callee (name Str)))` — a leaf
  cause vs a propagated blame link — threaded through a `LowerOut` ledger, so
  the root-first blame chain **exists at the entry gate by construction**.
  The diagnostic is not a print that someone remembered; it is a value the
  skip IS.
- **Crossing results as errno-or-value sums** — `WinsizeR`/`TermiosR`/`RawR`
  (term.chiral): `(ws-r rows cols) | (ws-err errno)` instead of a sentinel
  return the caller must remember to compare. The error path is in the
  signature (ties the E26 alarms discipline: errors are values, not control
  flow).
- **Half-done counterexample (what NOT to leave standing):** `er-skip` today
  carries its reason as a bare `Str` — the E97 element exists precisely to
  finish that retype. When you find the half-done form, completing it is
  in-scope work, not gold-plating.

## Boundaries with the other disciplines

- *Errors are values* (cheatsheet §) is the special case for fallible ops;
  boundary sums is the general rule for ANY classification.
- Linearity is a different axis: a sum says WHAT a thing is; quantity says how
  many times it may be used. The Sock porttype→data demotion (014e0a7) lost a
  quantity fact, not a sum fact — restoring it is S14, not this pattern.
- Refinements (`(refine I64 ...)`) carry arithmetic facts; sums carry
  discrete classification facts. Prefer the sum when the fact is which-of-N,
  the refinement when it is a bound.

## Anchors

- `examples/_CHEATSHEET.md` §"Boundary sums" — the compact operational form
  every pack bundle now carries into pipeline runs.
- `examples/E97-skip-chain-diagnostics.md` — the full worked exemplar.
- `.planning/SCRIBA-UNBLOCK-MAP.md` — the band cascade postmortem (the cost
  of the string-membership anti-pattern, measured in three misdiagnoses).
