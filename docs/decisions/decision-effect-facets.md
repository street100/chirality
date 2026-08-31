---
node: decision-effect-facets
layer: decision
related: [decision-graded-kernel, error-and-alarm, modules-core, category-typed, splitting-law, joining-law, permission-model, decision-profiles, modules-lowering, totality, open-edges]
status: settled
updated: 2026-07-21
---

# Decision: effects are two facets — possession and exercise — joined by construction

Settled 2026-07-21 in an adversarial design session (two reversals inside the
session, recorded below — the same discipline as [[decision-split-checker]]).
This resolves the mechanism half of open edge 16 and **amends
[[decision-graded-kernel]]**: alarms move out of the partiality modality and
into crossings (see the dated amendment there).

## The forks

Edge 16 asked the effect mechanism: algebraic effects with resumable handlers,
typed result rows, or another shape. Underneath it sat two more forks the
session surfaced. First, the port floor's ambient-authority contradiction:
`print`, `put`, `trace`, `env-get`, `time-mono`, `sleep-ms` are `=>` crossings
held by nothing, against "authority is the set of ports you hold; no ambient
authority." Second, an apparent fork between dissolving effects into the port
discipline entirely (capability-passing, the membrane bit derived from
port-holding) and building a row algebra beside the ports.

## The decision

The effect system is **two typed facets**, not one construct:

- **Possession** — capabilities held: linear port values. This is the already
  built discipline (`types`, linear kinds, quantity-1 binding). Unchanged.
- **Exercise** — the **effect row**: the record of the crossings a term
  performs. Inferred by elaboration from the transitive closure of extern
  crossings in the call graph (a call-graph fact, *not* derived from
  port-holding); declared bounds appear at module and profile boundaries;
  `->` is the empty row. tal's per-function `sysface` mark is the row's
  one-entry floor prototype.

They are **joined by construction, not by a new judgment**: every crossing
takes its capability as a parameter, so "crossings ⊆ capabilities in scope" is
discharged by the signatures themselves. The ambient externs are the current
violations; their capabilities (Console, Clock, Env, …) are reified as
porttypes in the port floor, handed to `main` by the profile the way `spawn`
already hands `node-main` its peer port. The honest size of the novelty:
reification completeness (no ambient crossings anywhere) plus the row as
verifiable bookkeeping that `verify` and profile conformance consume. Nothing
new enters the kernel judgment for containment.

The mechanism details:

- **Handlers.** A handler is the process at the other end of the port. Handler
  surface syntax is expected to CPS-elaborate to ordinary linear closures —
  zero new kernel term forms. That claim is to be **verified in the E39 worked
  example, not assumed**.
- **Continuations are graded, not decreed.** A captured continuation is a value
  whose QTT quantity is fixed by what it captures: captured linear ports force
  quantity 1 (one-shot — resuming twice would duplicate linear state);
  port-free capture permits ω (multi-shot stays legal — backtracking and
  search remain expressible, which the live environment's orchestration
  workload wants). No blanket one-shot rule; the semiring already owns
  multiplicity.
- **Abort discharge: synthesized cancel.** A 1-continuation cannot be dropped.
  Cancelling it runs a closing sequence over its captured inventory,
  synthesized by elaboration (an untrusted producer) with its own honest
  effect row, and checked by the *existing* linearity judgment — certificate
  discipline, no new trust. Surface addition: a porttype names its discharge
  crossing (Sock → `sock-close`, Fd → `fd-close`, Pool → `pool-close`). No
  implicit destructor enters the semantics; cancel is explicit and its row is
  visible.
- **Alarms are crossings.** Raising an alarm and answering it with a counter
  effect are port crossings carried in the row — the scaffold's `halt` and
  `exit` externs were already exactly this. Partiality stands alone as the
  marked modality of [[decision-graded-kernel]] point 2. This is the
  amendment.
- **The carrier.** The Pi gains an effect-row seat beside the grade seats.
  Today's scaffold carrier is `(q, eff-bit, dom, cod)`; the target is

      (q, row, grades⟨usage×time×space×info-flow⟩, totality-mark, dom, cod)

  with the seat count frozen now (the same factor-width move the semiring
  decision made) and a **row-variable seat** reserved for higher-order code.
  This grows the data the judgment ranges over, not the judgment logic — but
  it is a **trusted-core edit** (`kernel-spec`/`kernel-core`) and is to be
  reviewed as one, never bundled invisibly into module work.

## Why this resolves it

The dissolved-into-ports form died on the [[splitting-law]]. Possession and
exercise have different type shapes because **holding is not crossing**: pure
code may transport and repack authority without exercising it — the `RecvR`
result-shape pattern and alarm paths carrying ports to their close are
load-bearing pure plumbing today. Deriving the membrane from holding would tax
exactly the code P4 made cheap and would merge two mapped A-modules
(`types`-capability and `effects`-row) that the splitting law keeps apart.

The rows-beside-ports form *without* the containment construction died on P2:
two accounts of the same thing. The surviving shape is two accounts of
**different** things — has versus does — with their agreement enforced by
construction at the signatures. P2's "not two accounts" governs same-referent
accounts; possession and exercise have different referents.

## Placement: no new module

The row fills the `effects` seat [[module-map]] has carried as DESIGNED all
along; `totality` keeps the partiality mark; [[error-and-alarm]] keeps alarms
with its mechanism now fixed; the reified capabilities are port-floor library
declarations; row inference, cancel synthesis, and handler elaboration are
untrusted producers; the carrier diff is the one trusted-core change. No
merge, no split — the map is untouched, which is the strongest sign the slice
is right.

## Named costs and boundaries

- **Row polymorphism returns.** Higher-order effectful code needs the
  row-variable seat. Reserved in the carrier now; the machinery is standard;
  the ceremony lands on signatures that already exist (module and profile
  boundaries), not on every arrow, because rows are inferred elsewhere.
- **Trace virality.** Threading a Console to add a debug print is viral by
  design. Dev-profile ergonomics use [[decision-profiles]] default-flipping —
  the capability auto-threaded by elaboration, the port set unchanged — not an
  exemption. An unlogged escape hatch would be the gap.
- **Continuation mobility.** Suspensions move within a node only. Adhikara
  carries capabilities, never suspended computations. Crossing that line is a
  future decision taken on purpose, not a default.
- **Erasure.** A quantity-0 position requires empty row **and** total. The row
  replaces the eff-bit proxy; divergence was never covered by either, and its
  enforcement arrives with the totality gate (edge 9 ties here).
- **The named downstream consumer: effectful lowering (catalog E70).** Only
  pure arrows lower today, and the compiler is effectful code — self-hosting
  cannot go native until the row lowers and `preserve-check` covers the effect
  claim. The tal shadow is the future compiler's admission ticket to the
  floor; build it as such, not as an appendix.

## The reversals, recorded

The first in-session draft dissolved effects into linearity plus port types
(derive `=>` from transitive holding). Reversed: holding ≠ crossing, above.
The second decreed one-shot continuations as a QTT-forced bound. Reversed: the
semiring itself grades multiplicity, and a blanket decree would have amputated
multi-shot search from the flagship workload. What survived each reversal:
ambient-capability reification (from the first), and the linearity-forced
1-continuation case (from the second).

## Principle basis

P1 — ambient crossings are ungoverned paths; reification closes them. P2 —
the row and the capabilities are both the process's type, as distinct
components with distinct referents. P3 — the row is the port algebra's record
of the membrane; the port-check is the type-check. P4 — pure plumbing of
authority stays cheap; partiality and low tiers stay the loud opt-ins. P5 —
cancel synthesis and row inference are untrusted producers re-checked by the
existing judgment ([[certificate-discipline]]).

## What this does not decide

The live-port protocol (edge 14: rendezvous versus transfer, sync versus
async) — untouched. Cross-node alarm loudness (edge 17). The concrete row
representation (set of crossing names versus porttype-keyed structure) and the
row-variable surface — E39's worked example owns those. So does
**recoverable-vs-fatal in the type** ([[error-and-alarm]]'s fourth commitment,
surfaced by `banks/effect-and-alarm` Shard 5): in this shape, recoverable means
the handler holds a resumption it can consume and fatal means the cancel/halt
discharge — how the *type* names which is E39's design obligation, not settled
here. The grade-side
factors ([[decision-graded-kernel]] point 1, unchanged).

## Hypothesis verified (2026-07-22)

The zero-new-kernel-forms claim was tested in the E39 worked example
(`examples/E39-effect-row.md`) and **survived**: the full handler scenario
(alarm mid-protocol, port-peer handler, resume-or-cancel) CPS-elaborates to
existing `data`/`case`/`lam`/apply with QTT quantities — no delimited-control
primitive, no new core form. Two sharpenings bind the implementation:

1. **The continuation-quantity law is enforced by usage accounting, not the
   linear-kind hook.** Closure types do not record their capture, so the
   ω-vs-1 distinction lands at bind/apply-site accounting (ω-binding a
   port-capturing closure fails `uscale`); alarm-protocol externs must declare
   continuation parameters at quantity 1.
2. **The continuation is ONE linear closure over a `KontMsg` sum**
   (`k-resume v | k-cancel`), never resume/cancel as two closures — two would
   double-capture the linear inventory. The `k-cancel` branch is what the
   elaborator synthesizes from its elaboration-time capture set (the
   synthesized cancel of this note, given its concrete shape).

And recoverable-vs-fatal found its structural direction: **which constructors
the alarm's protocol type offers** — both `k-resume` and `k-cancel` means
recoverable, `k-cancel` only means fatal. The row-entry shape that carries
this into the type is still E39's design work — direction found, not yet
discharged ([[error-and-alarm]]'s fourth commitment remains E39-owned).

*Discharged 2026-07-22 by the E39 SPEC (disposition b,
`.planning/specs/E39-effect-row-SPEC.md`): it is **not a row-entry shape** —
the row names the crossing; the crossing's handler extern signature carries
the `KontMsg` sum, and `data`/`case` enforce fatal-vs-recoverable
structurally. No new carrier field.*
