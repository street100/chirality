---
element: E106
slug: linear-cap-collection
title: Linear collection of caps — a monomorphic container that HOLDS N move-only `porttype` values (`Sock`/`Session`/`Fd`) and threads them linearly, the TUI `mux` (T9) NEED. E106 is the LANGUAGE FEATURE only — the linear container type + its linearity-safe ops; the porttype-consuming native cap-close is a separate follow-on. Conformance = the reproducible checker accept/reject set (four rejections + one accept) PLUS a native raw-fd drain-and-close control run (exit 42) over a lowering crossing.
kind: BUILD-PROPER
example: examples/E106-linear-cap-collection.md
status: audited
updated: 2026-08-11
---

# E106 SPEC — Linear collection of caps

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example (`examples/E106-linear-cap-collection.md`)
> remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** a new file `scaffold/lib/lincoll.chiral` exists, a sibling
  to `collections.chiral`, containing a **monomorphic linear cap vector** —
  `(data SockVec () (sv-nil) (sv-cons (1 hd Sock) (1 tl SockVec)))` — whose
  element AND tail fields are declared quantity-`1`, so the whole type registers
  linear (`is-linear` reads `ldatas`, `kernel.chiral` `is-linear`) and threads
  move-only. Alongside it: the **linearity-preserving op set** from the example §5
  — `sv-push` (move a cap in, pure `->`), `sv-count` returning a `CountR` sum that
  threads the vector back (the discard-free replacement for `length`),
  `sv-detach-at` returning a `DetachR` sum (the swap-remove analog: cap out + rest
  back, out-of-range as a value not a panic), `sv-drain` (the ONLY end of a
  `SockVec` — closes every held cap exactly once, `=>`), and the `mux-step`
  servicing skeleton (detach → service → push back). Every op that would "look
  without consuming" returns the container in a `1`-fielded result sum; no op
  discards a cap.
- **Consumer shape it must serve:** the TUI `mux` (T9, `TUI/PRIMITIVE-AUDIT.md`) —
  "hold N move-only `Session` caps, concurrent progress + serial mutation": hold
  N-1 caps in the `SockVec` between servicings, detach the ready one, service it
  (recv/send threads the SAME cap back via `RecvR`), push it back, recurse.
- **Non-goals (residue → §6):** the polymorphic `(data LVec ((A (type 0))) …)`
  form; a true O(1) array-backed swap-remove; a keyed linear map; the outer
  poll/event loop; and — the load-bearing one — the **porttype-consuming native
  close** that would let a real `SockVec` drain to a native exit-42 end-to-end.
  That is a separate follow-on element (§6), NOT E106.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no CONFORMANCE-MAP rows name E106 (it postdates the
  snapshot) — treat as **BUILD**. Stage-1 ground truth (measured through
  `scaffold/build/B1` in the audited example, re-confirmed here) is the baseline:
  the checker's linearity machinery already exists and already REJECTS the naive
  approach, which is precisely why a new type is warranted.
- **Live code this composes with (name, do not respec):**
  - `scaffold/lib/ports.chiral` — the `porttype` floor: `(porttype Sock)` (:12),
    the `RecvR` result-sum pattern with `1`-fielded arms (:28-31), `sock-recv`
    (:62), `sock-close (=> (1 s Sock) Unit)` (:63). The new type imports this and
    copies the `RecvR` shape for `CountR`/`DetachR`.
  - `scaffold/lib/kernel.chiral` — `is-linear` (a value is linear iff its type
    constant is a registered `porttype`/`ldatas` entry) and `ctor-field-types`
    (constructor-application gate: `(and (not (=i q 1)) (is-linear …))` →
    `ft-err "linear field <name>"`, the :683-684 str-cat). These enforce the
    discipline the new type relies on — unchanged.
  - `scaffold/lib/loader.chiral` — `check-dfields`→`linear-bad?` (:208-209): the
    DECLARATION gate, `"linear field declared non-1: <name>"`. This is what
    rejects a container ctor that puts a porttype in a non-`1` field.
  - `scaffold/lib/collections.chiral` — the UNRESTRICTED `List`/`Map` this
    deliberately does NOT reuse and does NOT edit (`length` discards the head).
  - `scaffold/lib/crossing-wraps.chiral:21` — `(pair "close" "nb-sys-close")`, the
    raw-fd `close` `=>` crossing that DOES lower to native. This is the only close
    the conformance control run can reach at runtime today (verified exit 42).
  - `scaffold/lib/prelude.chiral` — imported for `I64`/`Unit`/`Bool`; `List`'s
    element param is `(type 0)` (the reason a linear atom can't safely ride it).
- **True delta:** one new file (`scaffold/lib/lincoll.chiral`) + its conformance
  samples/test. No edits to `collections.chiral`, `kernel.chiral`, `loader.chiral`,
  or `ports.chiral` — the checker gates already do the work; E106 only supplies a
  type shaped to pass them and ops that preserve linearity.

## 3. Decisions

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **Scope of E106** — prove-it-and-add-helpers, or build a new type, and how far? | **RESOLVED** (orchestrator ruling, D-scope) | E106 is the **LANGUAGE FEATURE only**: the linear container type + its linearity-safe operations, drawn **MONOMORPHIC** (`SockVec`, matching `collections.chiral`'s bootstrap status). Its conformance gate is (1) the reproducible checker accept/reject set — the four rejections + the accept, which ARE the contribution and are fully reproducible today via B1 — PLUS (2) a native drain-and-close CONTROL run over a *lowering* crossing (raw-fd `close`, verified exit 42) proving the drain-and-close shape reaches runtime. |
| 2 | **The porttype-consuming native close** (so a real `Sock`/`Session` cap drains to native exit-42 end-to-end) | **RESOLVED — out of scope, follow-on** (orchestrator ruling, D-followon) | `sock-close`/`fd-close`/`env-close` do NOT appear in `crossing-wraps.chiral`, so B1 emits no entry for an `=>` main that calls them (`no emitted label for entry compile-main`, reproduced). Landing an `nb-*`-backed porttype close is a **separate follow-on crossing element**, shaped like E105 (surface extern + `crossing-wraps` pair over an already-registered syscall). Recorded in §6 as the honest completion path; NOT implemented or absorbed here. |
| 3 | Is the polymorphic `LVec A` worth landing now? (example §6.a) | **DEFERRED** — to the `List`/`Map` native-lowering work | Blocked on the same higher-order polymorphic-container lowering that keeps `collections.chiral` checker-only during bootstrap. The `1`-fielded polymorphic form type-checks identically (verified) and is a drop-in for checker-only contexts, but `mux` is real code that must run → monomorphic `SockVec` per decision 1. Land `LVec` when List-lowering lands. |
| 4 | O(1) swap-remove vs the O(n) splice? (example §6.b) | **RESOLVED** — O(n) splice | The shown `sv-detach-at` splice is O(n) but linearity-clean; the Vec last-into-hole trick needs an array-backed linear vector (a bigger build) and is an **optimization, not a correctness need** (example §5 "Deliberately omitted"). Fine at the expected N for T9. |
| 5 | Home: new `scaffold/lib/lincoll.chiral` vs `TUI/vt-core/session-pool.chiral`? | **RESOLVED** — `scaffold/lib/lincoll.chiral` | It is a language-feature floor (the linear-fielded cousin of `collections.chiral`), not a TUI-specific consumer; `mux`/T9 imports it. Placing it beside `collections.chiral` keeps it in the compilable `scaffold/lib` floor and reusable beyond the TUI. |
| 6 | Does a keyed linear map (`Session`-id → cap) become its own element? (example §6.c) | **DEFERRED** — proposed separate future element | The AVL `Map`'s `k K`/`v V` fields are unrestricted; a linear keyed map needs the same `1`-field retype as `SockVec` plus balancing over linear values. Out of E106's bag-not-map scope; note in §6 for the catalog wave. |

No NEEDS-AUTHOR blockers remain — decisions 1 and 2 are the orchestrator's dispositioned rulings; 3–6 are decidable and decided above with citations. `status: specced`, §4–§6 fully specified.

## 4. Change plan (ordered, commit-sized)

### Step 1 — the linear container type + pure/count/detach ops
- **Target:** NEW `scaffold/lib/lincoll.chiral` — `(import "prelude")`,
  `(import "ports")`; the `SockVec` type; `sv-push`; the `CountR` sum + `sv-count`;
  the `DetachR` sum + `sv-detach-at`. Verbatim from example §5 (fields at
  quantity-`1`, result caps on `1`-fields of sums, out-of-range as a `det-none`
  value).
- **Checkable state:** `B1 < (prelude+ports+lincoll blob) ` elaborates clean — the
  `1`-fielded type is ACCEPTED and threads move-only. This is the positive half of
  the gate.
- **Size:** ~S

### Step 2 — the drain + mux-step (the consuming ops)
- **Target:** `scaffold/lib/lincoll.chiral` — append `sv-drain` (`=>`, closes each
  cap exactly once via `sock-close`, structural recursion ⇒ total) and the
  `mux-step` servicing skeleton (detach → `sock-recv` → push back / close on
  `recv-closed` / drop on `recv-err`), verbatim from example §5.
- **Checkable state:** the file elaborates clean under B1 (type-level). NOTE: an
  `=>` *main* that actually calls `sv-drain` will NOT emit a native entry today
  (`sock-close` is not in `crossing-wraps` — decision 2). So the file's runtime
  proof is deferred to the control run in Step 4; this step's gate is
  elaboration + the accept sample.
- **Size:** ~S

### Step 3 — the checker accept/reject conformance sample set
- **Target:** NEW samples under `scaffold/samples/`:
  - `e106_sockvec_accept.chiral` — imports `prelude`+`ports`+`lincoll`, constructs a
    `SockVec` holding ≥2 caps and exercises `sv-count`/`sv-detach-at`; MUST
    elaborate clean (the accept).
  - `e106_reject_list_cap.chiral` — `(cons a nil)` with `a : Env`/`Sock` into
    `List`; MUST be rejected `linear field hd`.
  - `e106_reject_length.chiral` — the unrestricted `length` over a
    `(1 xs (List Env))`; MUST be rejected `linear binder usage mismatch`.
  - `e106_reject_drop_tail.chiral` — drop the tail of a linear container in a `case`
    arm; MUST be rejected `field binder usage mismatch`.
  - `e106_reject_nonlinear_field.chiral` — a container ctor with a NON-`1` field
    over a porttype (`(bv-cons (hd Env) …)`); MUST be rejected at decl
    `linear field declared non-1: hd`.
- **Checkable state:** each blob run through B1 produces exactly its verdict/message.
- **Size:** ~M

### Step 4 — the native drain-and-close CONTROL run (exit 42, lowering crossing)
- **Target:** NEW `scaffold/samples/e106_drain_control.chiral` — an `=>` main that
  holds a small set of raw fds and drains-and-closes them recursively via the
  raw-fd `close` crossing (`crossing-wraps.chiral:21`, `close`→`nb-sys-close`),
  then `exit 42`. This proves the drain-and-close *shape* reaches native runtime
  over a *lowering* crossing (the honest control per decision 1); it is NOT the
  `SockVec` drain (which is porttype-gated, decision 2), and the sample must say so
  in a header comment.
- **Checkable state:** B1 compiles it AND it runs to exit code 42 (modelled on
  `scaffold/samples/exit42.chiral` + the raw-fd close control from the example §6).
- **Size:** ~S

### Step 5 — the test driver
- **Target:** NEW `scaffold/tests/test_e106_linear_cap.py` — a native-floor test
  (docs/testing-floors.md) that DRIVES B1 (B1 compiles; the test only invokes it and
  asserts) over the Step-3 samples (accept clean + each reject with its exact
  message) and runs the Step-4 control to exit 42. Modelled on
  `scaffold/tests/test_linear_selfhost.py` / `test_compile_run_chirality.py`.
- **Checkable state:** `pytest scaffold/tests/test_e106_linear_cap.py` green; suite
  count rises.
- **Size:** ~M

## 5. Conformance gate

- **Golden behavior (per D-scope, two legs):**
  1. **Checker accept/reject set (the contribution — fully reproducible via B1 today):**
     the accept (`e106_sockvec_accept.chiral` elaborates clean) + the four
     rejections with their exact messages: `linear field hd`,
     `linear binder usage mismatch`, `field binder usage mismatch`,
     `linear field declared non-1: hd`. **The "closes each held cap exactly once"
     property is proved HERE, at the type level:** `sv-drain` elaborating under
     the linear checker (part of `lincoll.chiral` elaborating clean — Done-when
     clause 1; the checker rejects any dropped cap as `field binder usage
     mismatch`) IS the exactly-once proof for the `SockVec` drain. Leg 2 below
     does NOT carry it — it only shows the drain-close *shape* lowers and runs.
  2. **Native control run:** `e106_drain_control.chiral` B1-compiles and runs to
     **exit 42**, proving the drain-and-close *shape* reaches runtime over the
     raw-fd `close` lowering crossing (an `(List I64)` of fds drained
     recursively — deliberately NOT the linear `SockVec` drain, whose native run
     is E-follow-on-gated per decision 2 and explicitly NOT claimed here; the
     linear exactly-once guarantee is carried entirely by leg 1).
- **Tests to add:** `scaffold/tests/test_e106_linear_cap.py` — native floor
  (B1 accept/reject assertions + exit-42 run). No python compiles anything; the
  test only invokes B1 and asserts on its output/exit code.
- **Green line:** 698 → ≥ 703 (accept + 4 rejects + control-run, one test file);
  `tools/ledger-lint/ledger-lint.py` clean.
- **Done when:** `scaffold/lib/lincoll.chiral` elaborates under B1; the five sample
  blobs each produce their exact B1 verdict; `e106_drain_control.chiral` runs to
  exit 42; and `test_e106_linear_cap.py` is green.

## 6. Residue & links

- **Deliberately unbuilt (with home):**
  - **PROPOSED FOLLOW-ON ELEMENT — porttype cap-close lowering** (decision 2, the
    honest completion path): a new crossing element shaped exactly like **E105** —
    a surface extern + a `crossing-wraps.chiral` pair over an already-registered
    syscall — that lowers `sock-close`/`fd-close`/`env-close` to an `nb-*`-backed
    close, so a real `Session`/`Sock`/`Fd` cap held in a `SockVec` drains to native
    **exit 42 end-to-end**. Until it lands, `sv-drain`'s runtime is proved only by
    the raw-fd control (§5 leg 2). *The catalog wave should mint this as its own
    E-number (suggest E107); it is NOT part of E106.*
  - **Polymorphic `LVec A`** — DEFERRED to the `List`/`Map` native-lowering work
    (decision 3).
  - **O(1) array-backed linear swap-remove** — an optimization, not built
    (decision 4).
  - **Keyed linear map** (`Session`-id → cap) — a proposed separate future element
    (decision 6): the AVL `Map` `k K`/`v V` fields need the same `1`-field retype.
  - **The outer poll/event loop + pollset marshalling** — E42 alarm-supervisor
    territory (`TUI/PRIMITIVE-AUDIT.md` LONG ROAD).
- **Follow-on this unblocks:** the TUI `mux` (T9) session-pool can hold N move-only
  caps once `lincoll` lands (checker-verified); full native `mux` awaits the
  porttype cap-close follow-on above.
- **Related:** [[E106-linear-cap-collection]], [[banks/port]] (the `porttype` floor +
  `RecvR` result-sum pattern copied), collections, an old-tree module note with no
  successor here; the unrestricted `List`/`Map` it named are `lib/prelude/list.chiral`
  and `lib/prelude/map.chiral`, deliberately not reused, the effect-facets decision (possession = holding N
  caps, exercise = `sv-drain`), E42 alarm-supervisor, E105 (the crossing-element
  shape the follow-on copies).
