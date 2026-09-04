---
element: E26
slug: alarm-control-flow
title: Alarms / control flow (exceptions-as-control-flow is a crutch)
kind: REPLACE-CRUTCH
example: examples/E26-alarm-control-flow.md
status: audited
updated: 2026-08-01
---

# E26 SPEC — alarms onto the built row (handlers, KontMsg, synthesized cancel)

> ⚑ **TRIAGE 2026-09-04 — DEAD.** 0 of 5 steps are executable at HEAD.
> Re-found on the built effect row; Step 1's `KontMsg` already landed under
> E42. Bucket and evidence: `records/spec-tier-triage.md`. This file was not
> rewritten and its `status:` was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the alarm algebra lives on the built effect row. The
  **`KontMsg` protocol type** exists (recoverable-vs-fatal = the constructor
  offering: `k-resume v | k-cancel` both ⇒ recoverable, `k-cancel` alone ⇒
  fatal); **handler machinery** exists — handler surface CPS-elaborates to
  ordinary linear closures (zero new kernel forms, per the E39 worked example)
  with **row subtraction** at the handling site; **synthesized cancel** exists —
  elaboration emits the discharge closes of a captured linear-port inventory
  from a declared porttype→discharge table; and the **in-language** Python
  alarm path is retired (result sums for recoverable — already the lib idiom;
  `MetisHalt`/`MetisExit` remain only as the *host-boundary referents* of the
  `halt`/`exit` crossings, never in-language control flow).
- **Non-goals:** **Console reification** (E39 step 7 — pending the E51-vs-
  Console ordering author call, not E26's); **cross-node alarm propagation** →
  edge 17 (shaped 2026-07-25; blocked on E44 outbound confinement);
  **`Exit`-grant delivery to `main`** → **E80** (the port *shape* is decided
  here, #2; the conjuring is E80's); **bridge-side `PortError`** (inbound
  `verify` divergence — C-tier, stays host until the E55/E51 adjacency);
  **Clock/Timer/Env discharge** (no close crossing exists; they thread back —
  designed with E80's batch, #4).

## 2. Baseline (what already exists)

- **Conformance-map verdicts (two rows):**
  - **E39 (REFACTOR L): steps 1–6 BUILT 2026-07-28** — Pi pos-2 = frozen
    `Seats(row, …)`; rows call-graph-inferred at elaboration (deterministic
    canonical form, `sig.def_rows`); `effects.py` gates by set-containment;
    `subtype` has the VPi row-subsumption case; non-spine `=>` carries DYN.
    "Handler machinery/subtraction **rides E26**" — this SPEC is that rider.
  - **E26 (BUILD M):** "Python host exceptions … halt declared in chirality but no
    effect row / no handler machinery … Hard-gated on E39 (its effect row)" —
    the gate is now **open at the row level** ([[error-and-alarm]]: "typed
    alarms E26 are unblocked … the next construction").
- **Live code (do NOT respec):**
  - `alarms.py` (24 lines): `MetisExit(code)` / `MetisHalt` / `PortError` — the
    crutch being repositioned to the host boundary.
  - `ports.chiral:128–129`: `exit : (-> (0 A (type 0)) (=> I64 A))`, `halt :
    (-> (0 A (type 0)) (=> Str A))` — ambient externs (the E80 reification
    class), **polymorphic-`A` return** — the scaffold's existing bottom idiom.
  - **The settled mechanism** ([[decision-effect-facets]], amended
    [[decision-graded-kernel]]): alarms are crossings; handler = the process at
    the other end of the port; resumption multiplicity = the captured
    continuation's QTT quantity (captured linear ports ⇒ one-shot); abort =
    synthesized cancel; **the continuation is ONE linear closure over the
    `KontMsg` sum, never resume+cancel as two closures** (verified in the E39
    worked example, 2026-07-22).
  - **Recoverable tier:** result sums are already the pervasive lib idiom
    (`RecvR`/`AccR`/`SendR`/… — every `lib/` parser and port protocol); the
    example's audited §5 is the pattern. Nothing to build there — only to
    *name*.
- **True delta:** the KontMsg/alarm-record types + the handler elaboration +
  row subtraction + synthesized cancel + the host-boundary repositioning.
  Elaborator (`surface.py`) + `effects.py` work; **zero kernel forms** (the
  E39-verified claim is the design constraint).

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **`Never`: kernel bottom type or 0-ctor data?** (example §6) | **RESOLVED → neither; the built polymorphic-return idiom.** | The live `halt`/`exit` already express "does not return" as `(-> (0 A (type 0)) (=> … A))` — the erased-`A` return *is* the scaffold's bottom, and it composes with no new kernel support. A 0-ctor `data` would need the empty `case`, which `_check_case` rejects ("empty case"). The example's `Never` sketch is superseded by the existing idiom; no new type. |
| 2 | **`Exit`: one global port or per-process-zone?** (example §6) | **RESOLVED → per-process, profile/spawn-granted.** | The recorded direction in [[decision-effect-facets]]: capabilities are "handed to `main` by the profile the way `spawn` already hands `node-main` its peer port." So each process's entry holds its own `Exit` grant; no global singleton. The *delivery* machinery is **E80**; E26 fixes the shape (a linear `Exit` porttype parameterizing `halt`/`exit`) so E80 has a target. |
| 3 | **`halt` payload: `Str` or a structured alarm record?** (example §6) | **RESOLVED → structured record as the crossing payload; the `Str` face kept as compat.** | The pinned alarm definition demands *what diverged from what* ([[glossary]]) — a bare `Str` cannot feed counter-effect dispatch or the split's rich evidence (X2, [[banks/effect-and-alarm]]). The alarm record `(data Alarm () (alarm (what Str) (expected Str) (got Str)))`-shaped payload rides the KontMsg crossing; the existing `halt : … Str A` stays as the compat crossing until callers migrate. |
| 4 | **The discharge-crossing table** (which close each porttype names, for synthesized cancel — example §6). | **RESOLVED (closable ports) → a declared table; Clock/Timer/Env slice DEFERRED → E80.** | The closable ports have canonical discharges: `Sock→sock-close`, `LSock→lsock-close`, `Fd→fd-close`, `Pool→pool-close` (with its erased bound). The table is *declared data* the elaborator reads when synthesizing a cancel — not hardcoded per-port logic. Clock/Timer/Env have **no close crossing** (they thread back to the grantor); their discharge shape is designed with E80's grant-delivery batch, where their lifecycle is defined. |
| 5 | **Handler surface form.** | **RESOLVED → the E39 worked-example shape.** | The form and its elaboration were drafted and verified there (CPS to one linear closure over `KontMsg`; zero new kernel forms; resumption quantity = capture). E26 implements that artifact rather than redesigning; any surface-syntax polish is drift within the verified elaboration target. |

No NEEDS-AUTHOR: the one live author call in this area (E51-vs-Console
ordering, E39 step 7) is explicitly not E26's and sits in Non-goals.

## 4. Change plan (ordered, commit-sized)

### Step 1 — the protocol types + discharge table
- **Target:** `lib/` (beside `ports.chiral`) — `KontMsg`, the alarm record, the
  porttype→discharge table.
- **Change:** `(data KontMsg ((0 A (type 0))) (k-resume (v A)) (k-cancel))`;
  the structured `Alarm` payload (decision #3); the discharge table as declared
  data (decision #4). The `Exit` porttype (decision #2) beside Clock/Timer/Env.
- **Size:** ~S.

### Step 2 — handler elaboration (CPS to linear closures)
- **Target:** `scaffold/chirality/surface.py` — the elaborator.
- **Change:** the handler surface form (decision #5) elaborates to ordinary
  linear closures over `KontMsg` — the E39 worked example's verified target.
  The captured continuation's quantity is *computed from its capture* (a
  captured linear port ⇒ the closure binds at `q=1`; port-free ⇒ ω) — this is
  existing linearity judgment doing the work, no new kernel form.
- **Size:** ~M.
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

### Step 3 — row subtraction at the handling site
- **Target:** `scaffold/chirality/effects.py` (+ the row plumbing in `row.py` if a
  subtraction helper is missing).
- **Change:** a handled crossing is *subtracted* from the handling term's
  inferred row — the handler's scope discharges the effect, so the caller's
  `sig.def_rows` entry no longer names it. Containment gating unchanged
  elsewhere.
- **Size:** ~M.

### Step 4 — synthesized cancel
- **Target:** `scaffold/chirality/surface.py` — the abort path of the elaboration.
- **Change:** on `k-cancel`, elaboration emits the closing sequence for the
  captured inventory, looked up in Step 1's discharge table; the emitted
  closes are checked by the **ordinary** linearity judgment (nothing trusted —
  the check is the existing one). A captured port with no table entry is an
  elaboration error (not a silent leak).
- **Size:** ~M.
- 2026-09-04: cut Python oracle, no live successor.

### Step 5 — host-boundary repositioning
- **Target:** `scaffold/chirality/alarms.py` + call sites in the RT.
- **Change:** in-language paths stop raising (they already return sums — audit
  confirms nothing in `lib/` raises); `MetisExit`/`MetisHalt` remain solely as
  the host-side effects behind the `exit`/`halt` crossings (the B-referent);
  `PortError` remains solely at the bridge's inbound face (C-tier, non-goal).
  Docstring the boundary so the crutch cannot silently regrow.
- **Size:** ~S.
- 2026-09-04: cut Python oracle, no live successor.

## 5. Conformance gate

- **Golden behavior:** existing programs unchanged (rows already inferred; the
  handler machinery is additive). New behavior: (a) a **recoverable roundtrip**
  — a process raises through a port, the handler `k-resume`s with a repair
  value, execution continues (one-shot when the continuation captured a linear
  port); (b) a **fatal path** — a `k-cancel`-only handler aborts, and the
  synthesized cancel *observably closes* a captured `Sock` (the differential:
  the fd is closed); (c) **row subtraction** — the handled crossing is absent
  from the handler-scope's `sig.def_rows` entry; (d) a pure `->` function
  calling `halt` stays **rejected** (membrane, already true — regression).
- **Tests to add:** the four cases above (RT floor; (b)'s close observable via
  the existing sockets differential harness); the E39 membrane regression
  suite stays green.
- **Green line:** 367 → ≥ 371; ledger-lint clean.
- **Done when:** the roundtrip + cancel + subtraction cases pass, no `lib/`
  path raises a Python exception in-language, and the E39 suite is untouched.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **Console reification** → E39 step 7, pending the E51-vs-Console ordering
    author call.
  - **`Exit`/Clock/Timer/Env grant delivery + lifecycle** → **E80**
    (decisions #2, #4).
  - **Cross-node alarm propagation** → edge 17 (blocked on E44).
  - **Bridge-side `PortError` as a typed alarm** → the E55/E51 adjacency.
  - **Counter-effect *dispatch* beyond halt** (re-key/re-derive/relocate/
    repair/quarantine) → their performing modules (custody/broker, E42/E43,
    DESIGNED) — the row names them; the performers are separate builds.
- **Follow-on:** unblocks the full Shard-5 story (recoverable-vs-fatal in the
  type, landing here); feeds **E70** (effectful lowering — the row's tal
  shadow) and **E51**'s lane-A crossings with a typed failure story.
- **Related:** [[E26-alarm-control-flow]], [[E39-effect-row]] (the built row +
  the verified handler elaboration target), [[decision-effect-facets]] (the
  settled mechanism), [[banks/effect-and-alarm]] (Shards 3–5 + X2),
  [[error-and-alarm]], [[E80]] (grant delivery), [[E12-effect-membrane]] (the
  membrane the algebra rides).
