---
element: E15
slug: reference-interpreter
title: Reference interpreter (golden semantics, tree-walk + TCO)
kind: SELF-HOST
example: examples/E15-reference-interpreter.md
status: audited
updated: 2026-08-01
---

# E15 SPEC — Reference interpreter (golden semantics, tree-walk + TCO)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new `scaffold/lib/interp.chiral` carrying the **big-step
  tree-walk evaluator over the pure fragment** in chirality source — the `Term`/
  `Value`/`Step` closed sums and the `eval-step`/`eval`/`run` mutual group (all
  `=>`) — that, run on the RT interpreter, reproduces `scaffold/chirality/runtime.py`'s
  `RT.run` (`:74`)/`apply1` (`:183`) on checked pure-fragment terms: same `Value`
  for every fixture, closure capture, `Case` arm selection, and **constant-stack
  behavior** on a deep tail-recursive fixture (the trampoline as a structural tail
  call, not a `while True`).
- **Non-goals (residue → §6):**
  - **The extern / port / bridge face** — `Global`/`Prim`, `pap`/`talf`
    application, `IMPLS[name](*args)` + `bridge.verify`, the `_sysbind_result`
    (E51) sys path. That is a *separate typed bridge connector* (the example's
    stated preference), owned by the bridge/E51 wiring, not E15's pure core.
  - **The linker** (`RT.__init__` extern→impl resolution, the missing-impl check,
    `run_main`'s main-is-process gate) — E15's co-resident shard, but it stands on
    the extern face; deferred with it.
  - **The pure small-step Knob** — a genuinely-`->` single-step machine that
    returns a continuation for every subterm; the shown form is big-step `=>`
    (decision #4). Author may elect to lead with the small-step form.
  - Does **not** delete or wire-in `runtime.py`; it stays the golden oracle E16/
    E18 also check against.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** `Reference interpreter / evaluator + linker |
  CONFORMS · S · E15 | "Golden tree-walk w/ TCO over checked terms, erases q=0
  lets, link-check externs, main-is-process gate. Fully built as E15 … This is E15
  (golden semantics), NOT the E42 supervisor — keep distinct."` CONFORMS ⇒ faithful
  transcription of a complete artifact. The example gate passed (`reviewed`,
  empirically load-checked). **Keep E15 (evaluator) ≠ E42 (supervisor)** — the
  runtime-bank cardinal warning.
- **Live code this composes with (do NOT respec):**
  - `scaffold/chirality/runtime.py` — the golden oracle. `RT.run` (`:74`) is the
    hand-written trampoline (`while True`, `env,t=` reassign for tail position);
    `apply1` (`:183`) is the two-shape return (`(value,None)` finished /
    `(None,(env,body))` tail-hop); `global_value` (`:64`); `run_main` (`:220`, the
    main-is-process gate). The extern/bridge face — `_result_type` (`:156`),
    `_extern_return` (`:162`, `bridge.verify`), `_sysbind_result` (`:170`, E51) —
    is the **deferred** connector.
  - `scaffold/lib/fsm.chiral` — the proven `Step`/`drive` idiom this reuses as a
    trampoline (two-constructor step, structural `drive`).
  - `scaffold/lib/collections.chiral` — `append` (list concat); `list-nth` is the
    one elided env-lookup helper the port adds. `scaffold/lib/prelude.chiral` —
    `List`/`Pair`/`cons`/`nil`, I64 ops.
  - Mutual/forward `data` support (**E79**, built 2026-08-01,
    `surface.py:_scan_data_groups`) — the example's `Value`→`Term` forward
    reference (a `v-clo` holds a `Term` body) elaborates today (verified: snippet
    loads, 48 defs OK).
- **True delta = one new library file's evaluator.** The wins over `runtime.py`:
  the `t[0]`/value-tag unions become coverage-checked `data Term`/`Value`/`Step`
  (no `raise`-on-fallthrough), the manual `while True`+`tail_jump` becomes a
  structural tail call (`run` tail-calling itself on the next `Step` — the PTC
  guarantee makes it constant-stack), and QTT erasure is structural (no
  `("erased",)` sentinel in `Value`).

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled source (cited); DEFERRED to a named
home; genuinely novel design → NEEDS-AUTHOR, surfaced never answered.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Is `step-stuck` kept as an honest data case, or is the evaluator proven **total on well-typed terms** so stuckness is statically dead? | **RESOLVED — kept (matches OURS); dead-proof is a follow-on** | The port reproduces `runtime.py`, which handles ill-shaped applications with a runtime fault; `step-stuck` is its coverage-forced, "unreachable on checked terms" analogue. Proving it *statically* dead needs the chirality kernel to certify the evaluator total over well-typed terms — available only once the checker (E3/E4) is self-hosted and a totality argument over checked terms exists. Kept now; dead-proof → residue. Derivable from the CONFORMS verdict + the example. |
| 2 | Does the extern/port face come in as **new `Term`/`Value` constructors** (one evaluator) or a **separate `=>` bridge module** the pure core calls out to? | **RESOLVED — separate bridge module; DEFERRED** | The example §4 states the preference ("a *typed bridge connector* at the one place the evaluator leaves the pure fragment — not an inline call in the hot loop"), and the live face (`_extern_return`/`bridge.verify`/`_sysbind_result`) is E51/bridge transport, not evaluator logic. So E15 ports the pure core; the extern face is a separate connector (bridge / E51). Owner: the bridge module + [[E51-sys-linkage]]. |
| 3 | How are **0-quantity arguments** represented once erasure is structural? | **RESOLVED — erased upstream; no erased `Value`** | Erasure is QTT's job (E5): a `q=0` `Let`/binder is removed before runtime, so there is no `("erased",)` in `Value` and nothing to force. The evaluator has no erased case — the property is enforced by the quantity, upstream. Owner: [[E05-qtt-semiring]]; derivable from the settled QTT erasure semantics (`kernel.py` erases q=0). |
| 4 | *(from the example audit)* **Membrane split** — big-step `=>` evaluator, or genuinely-pure small-step `->` stepper? | **RESOLVED (this SPEC) — big-step `=>` shown; small-step is a Knob. SURFACED for author revisit.** | The example audit found the "pure `->` step vs `=>` driver" split does **not** typecheck for a big-step evaluator: `eval-step` forces subterms via `eval` and the group exits through the `rt-alarm` crossing, so the checker forces the whole group `=>` (verified: the `=>` variant loads, 48 defs OK; the `->` variant fails "effectful application inside a pure function"). The shown port is big-step `=>`. A genuinely-pure `->` stepper (continuation for every subterm, only the driver `=>`) is the sharper membrane and is recorded as a Knob — an **author call on which to lead**, surfaced, not silently fixed. |

All dispositioned; none blocking (decision #4 is surfaced but does not block a
correct big-step port). `status: draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — the closed sums
- **Target:** `scaffold/lib/interp.chiral` (new) — `(import "prelude")`
  `(import "collections")`; `data Value` (`v-lit`/`v-clo (env (List Value)) (body
  Term)`/`v-con`), `data Term` (pure-fragment: `e-var`/`e-lit`/`e-lam`/`e-app`/
  `e-let`/`e-case`), `data Step` (`step-done`/`step-tail`/`step-stuck`). The
  `Value`→`Term` forward ref rides E79.
- **Change:** the example §5 decls verbatim.
- **Size:** ~S

### Step 2 — elided helpers
- **Target:** `interp.chiral` — forward-`declare` `list-nth`/`arm-body`/`rt-alarm`
  (the alarm crossing, shape mirrors `halt`), define `list-nth`/`arm-body`;
  `append` from collections.
- **Change:** as the example's forward-declares; `rt-alarm` is `=>` (alarm =
  crossing). Total (structural).
- **Size:** ~S

### Step 3 — the evaluator group (verbatim from example §5)
- **Target:** `interp.chiral` — `eval-step`/`eval`/`run`, all `=>`, all three
  declares before the first def (mutual group).
- **Change:** paste the audited example §5 bodies (structural `case` on `Term`;
  `run` tail-calls itself on `step-tail` = the constant-stack loop). Already
  load-verified.
- **Size:** ~M

### Step 4 — differential test file
- **Target:** `scaffold/tests/test_interp_chirality.py` (new; leave the Python
  runtime tests untouched).
- **Change:** load `lib/interp.chiral`, drive `run`/`eval` with the `apply1` RT
  harness + a Python↔chirality `Term`/`Value` adapter. Assert `run (eval-step nil t)`
  decodes to the same `Value` as `RT.run(t, [])` for a fixture corpus (closure
  capture, `Case` arm selection, nested `let`/`app`); and a **deep tail-recursive
  fixture** (an accumulator loop that would blow a non-TCO stack) returns without
  a `RecursionError` — the constant-stack claim.
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior:** over a corpus of checked pure-fragment terms,
  `interp.chiral::run (eval-step nil t)` yields a `Value` decoding to the same
  result `runtime.py`'s `RT.run(t, [])` produces — same closure capture, same
  `Case` arm selection by tag, same env indexing — and the deep-tail fixture runs
  in constant stack (structural tail call, not host recursion). The extern/port
  arms are out of scope (deferred bridge connector); `step-stuck` is not reached
  on checked terms.
- **Floors compared:** the **chirality RT interpreter** running `interp.chiral` vs the
  **Python `runtime.py` oracle** via a `Term`/`Value` adapter — lib-level
  chirality-vs-golden (`test_json.py` shape), not native/tal.
- **Green line:** 355 → ≥ 355 + k (the new `test_interp_chirality.py` functions);
  full suite stays green, `runtime.py` unchanged, ledger-lint clean.
- **Done when:** `test_interp_chirality.py` passes — the chirality evaluator matches
  `RT.run` on the pure-fragment corpus and the deep-tail fixture returns without
  stack growth.

## 6. Residue & links

- **Deliberately unbuilt:**
  - **The extern/port/bridge face** (`e-global`/`e-prim`, `pap`/`talf`,
    `bridge.verify`, `_sysbind_result`) — a separate `=>` bridge connector,
    decision #2 → the bridge module + [[E51-sys-linkage]].
  - **The linker** (extern resolution, missing-impl check, `run_main`
    main-is-process gate) — E15's co-resident shard, stands on the extern face;
    lands with it.
  - **The pure small-step Knob** (`->` stepper, continuation per subterm) —
    decision #4, an author call on whether to lead with it.
  - **`step-stuck` proven statically dead** (evaluator total on checked terms) —
    decision #1, rides the checker self-host (E3/E4) + a totality argument.
  - Erasure mechanism — [[E05-qtt-semiring]] (q=0 removed upstream; decision #3).
  - Retiring `runtime.py` and importing `interp.chiral` — rides the checker
    self-host; **keep distinct from the E42 supervisor**.
- **Follow-on:** the golden operational semantics [[E16-lowering]]'s
  preserve-check and [[E18-tal-check]]'s reference interpreter must preserve; the
  upper twin of the tal-floor interpreter.
- **Related:** [[E15-reference-interpreter]] (rationale) · [[E13-debruijn]] (the
  `Term`/index machinery walked) · [[E16-lowering]]/[[E18-tal-check]] (must
  preserve this semantics) · [[E12-effect-membrane]] (the `->`/`=>` split;
  decision #4) · [[E05-qtt-semiring]] (erasure; decision #3) · [[E51-sys-linkage]]
  (the deferred extern/bridge face; decision #2) · [[E24-i64-arith]] (I64 floor).
