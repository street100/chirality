# PLAN 2026-07-21 — effect-algebra batch (edge 16 program)

Scoping for the worked-example pre-runs that precede building the effect
algebra. Produced by the 2026-07-21 adversarial design session (Fable). Until
the decision note lands, **this file is the only durable capture of the
session's design outcome** — the docs it amends still read the old way.

## The settled shape (session outcome, pending the decision note)

**Two facets, not one, and not a dissolution:**

- **Possession** — capabilities held: linear port values, already ENFORCED
  (`types`, linear kinds). Unchanged.
- **Exercise** — the effect row: the record of *crossings a term performs*,
  inferred from the transitive closure of extern crossings in the call graph
  (a call-graph fact, NOT derived from port-holding — holding ≠ crossing; pure
  transport/repack of ports stays pure, the `RecvR` pattern is load-bearing).
  Declared bounds appear only at module/profile boundaries; `->` = empty row.
  tal's per-function `sysface` bool is the row's floor prototype.
- **Containment by construction:** once every crossing takes its capability as
  a parameter, row ⊆ capabilities-in-scope is discharged by the signatures —
  no new kernel judgment. The ambient externs (`print`, `put`, `trace`,
  `env-get`, `time-mono`, `sleep-ms`) are the current violations; reify their
  capabilities (Console / Clock / Env / …) in `lib/ports.chiral`.
- **Handlers:** the handler is the process at the other end of the port.
  Handler syntax plausibly CPS-elaborates to ordinary linear closures — zero
  new kernel term forms (VERIFY in E39's example, don't assume). Continuation
  multiplicity is its QTT quantity, determined by what it captures: captured
  linear ports ⇒ 1 (one-shot forced); port-free capture ⇒ ω (multi-shot legal
  — keeps backtracking/search for the live environment). No blanket one-shot
  decree.
- **Abort/discharge:** a 1-continuation cannot be dropped. Resolution:
  **synthesized cancel** — elaboration (untrusted producer) generates the
  closing sequence for the captured inventory, with its own honest effect row;
  the existing linearity checker verifies it. Small surface addition: a
  porttype names its discharge crossing (e.g. Sock → `sock-close`).
- **Homes unchanged:** grades (usage×time×space×info-flow) stay in the kernel
  semiring; partiality stays a marked modality; staging stays out. AMENDMENT
  to `decision-graded-kernel`: alarms move out of the modality home — an alarm
  is a crossing (row entry), answered by counter-effect crossings; partiality
  stands alone as the mark. Must be a dated, on-purpose edit.
- **Carrier:** the Pi gains a row seat beside the grade seats — data growth in
  `kernel-spec`/`kernel-core`, seat count frozen now (the factor-width trick).
  The decision note must show this diff explicitly (trusted-core edit class).
- **Boundaries:** continuations move within a node only — Adhikara carries
  capabilities, never suspended computations. Erasure safety = empty row AND
  total (ties to edge 9 sequencing). Trace ergonomics via decision-profiles
  default-flipping (dev profile auto-threads the cap; port set unchanged).

## Gates before running the batch — ALL DONE 2026-07-21

1. ~~Decision note~~ — **DONE**: `docs/decision-effect-facets.md` (carrier
   diff shown; graded-kernel amendment landed in that note's own file;
   error-and-alarm + open-edges edge 16 updated to point at it).
2. ~~Cheatsheet delta~~ — **DONE**: membrane section rewritten to the
   two-facet shape.
3. ~~INDEX flags~~ — **DONE**: E12, E26 → `needs-rework`.
4. (Added) Catalog rows minted for the lowering reach: **E69–E71** in
   `.planning/SELF-IMPLEMENT-CATALOG.md` section IX.

The batch below is now unblocked; runs cite `decision-effect-facets` directly.

## The batch

| Run | Element | Slug | Status | Scope |
|-----|---------|------|--------|-------|
| 1 | E39 | `effect-row` | fresh pre-run | The algebra proper: row representation on the Pi, row inference from the call graph, row subtyping ("needs at most") for attenuation + profile conformance, row-variable seat for higher-order code, the empty-row `->`. MUST verify the CPS-elaboration claim (handlers → linear closures, no new kernel forms) with a concrete handler example. Baseline: `effects.py` + `surface.py` `used_ports`. |
| 2 | E26 | (rework existing `E26-alarm-control-flow.md`) | revision pass | Alarms as crossings; counter-effects as crossings (`halt` precedent); graded continuations (multiplicity = quantity of capture); synthesized cancel + porttype discharge clause; recoverable-vs-fatal in the type. Baseline: `alarms.py`, F3–F5 alarm paths in the demo. |
| 3 | E12 | (rework existing `E12-effect-membrane.md`) | revision pass | The membrane bit becomes the derived empty-row judgment; the three judgment points (`on_apply`/`on_binder`/`erased_allow`) recast over rows; erased positions demand empty row + total. Baseline: `effects.py`. |
| 4 | E51 | `sys-linkage` | fresh pre-run | First customer. Upper-effectful code reaching syscalls through `sys-tal`, retiring `impl_ports` as transport; the row's tal shadow (sysface mark → row lowering) + its preserve-check obligation. Depends on runs 1–3 shapes. Baseline: `impl_ports.py`, `runtime.py` dispatch, `lib/sys-tal.chiral`. |
| 5 (stretch) | E38 | `graded-cost` | fresh pre-run | Only the carrier-adjacency slice: the grade seats beside the row seat, one composition step doing row-union + grade-add. Full semiring program is its own arc; do not scope-creep it here. |

Cap reification (Console/Clock/Env) and the discharge-clause surface form are
folded into runs 1–3 scope rather than new catalog rows; if they outgrow that,
propose new E-numbers to the catalog (precedent: E51–E68 extension) rather
than letting them ride unnumbered.

## Run mechanics

- One element per run, per the worked-example skill; parallel agents pass
  `--no-index` and report `{element, slug, title, kind, reference_class}` for
  the orchestrator to append to INDEX.
- Reworks (E26, E12): the pack scaffolds fresh; agent edits the existing
  artifact instead, preserving its still-valid sections. Same read discipline.
- Every run cites the decision note (gate 1) for the two-facet shape instead
  of restating it.

## Parked adversarial context

The wider adversarial notes from this session: `.planning/ADVERSARY-NOTES-2026-07-21.md`.
Item 4 there (sys face = seccomp parable) is partially answered by run 4's scope.
