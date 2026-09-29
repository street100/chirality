# LANE 5 — kernel port + certificate split + fixpoint (= full rung 1) [GATED]

Read `../HANDOFF.md` first. **Gated on: Lane prep (determinism paid), Lane 1
(effect row), Lane 2 (E50 total), Lane 3 (effectful+closure lowering).** Do not
start until those land. This is the serial convergence gate — the fixpoint.

## Goal
Port the trusted core to chirality, split it by the certificate discipline, freeze the
reflective floor, and prove the self-host by fixpoint + DDC. When this lands, the
last CPython is gone from check/compile/run: **rung 1 complete.**

## Rests on (read these)
- `examples/E52-certificate-split.md` — kernel-spec artifact + kernel-core +
  certificate format. **AUTHOR CALL:** the conversion-evidence tier
  (rerun/trace/cached) IS the TCB-size decision — do NOT resolve it silently;
  it's in the docket. Note: the certificate format is also **D3's succession
  payload** (E45).
- `examples/E45-reflective-floor.md` — the `SigB`→`Frozen` linear-consume; the
  interim-discipline residual is **DECIDED** (accept as rung boundary; enforcement
  lands with this port).
- `examples/E53-ddc-bootstrap.md` — the DDC ceremony; legs = self-hosted /
  py-scaffold (retires INTO leg 1) / weekend. Two comparisons: spec-conformance
  admits a leg, bit-identity convicts the binary.
- `examples/E01`…`E13` — the checker-stack elements being ported. **Key finding
  (E48):** the checker is *extrinsic* (raw `Term` sums + separate types + re-check)
  — its own records have NO value-dependent fields, so telescopes are NOT needed
  for the port. Do not build E48/E47 for this.

## The work (spec the cluster first, then implement — this is the big one)
1. Port `terms.py`/`kernel.py`/`data.py`/`effects.py`/`refine.py` (+ `lower.py`,
   `tal.py`, `runtime.py`, `surface.py`, `sexp.py`) to chirality source. The ported
   checker must classify **total over itself** (needs Lane 2).
2. E52 split: `kernel-spec` artifact (under the **spec-size budget** — readable in
   a sitting; every carrier seat spends it), `kernel-core` re-checker, the
   elaborator emitting certificates. Resolve the conversion-evidence-tier AUTHOR
   CALL first.
3. E45: split `Sig` into builder/`Frozen`; freeze at link/install completion;
   succession runs `recheck spec successor-cert`.
4. **Fixpoint:** Stage1 (checker compiled by Python-hosted chirality) == Stage2
   (checker compiled by itself), byte-identical. Use the Lane-prep compare
   harness to localize any divergence.
5. **DDC:** run the E53 ceremony across the legs; require converged.

## Conformance gate
- Byte-identical Stage1==Stage2 fixpoint.
- DDC converged across provenance-disjoint legs.
- No CPython in the check/compile/run path.
- Full existing behavior preserved (differential across the port).

## Audit obligation
This is THE convergence gate. Any byte-diff is localized by the compare harness,
not by hand. The determinism debts (Lane prep) MUST be paid before starting or
this becomes a serial hunt. Author review required for: the certificate tier, the
kernel-spec spec-size budget, and the DDC provenance-axis budget (D7).

## This completes rung 1.
After it: the security-completion wave (E73/E44/E59/E60) for the "infallible"
ceiling, then rung 2 (metal + app layer) per `SELF-HOST-PLAN.md`.
