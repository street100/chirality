---
element: E29
slug: sockets
title: Sockets: `socket`/`connect`/`bind`/`listen`/`accept`/`send`/`recv`
kind: REPLACE-CRUTCH
example: examples/E29-sockets.md
status: audited
updated: 2026-07-31
---

# E29 SPEC — Sockets: `socket`/`connect`/`bind`/`listen`/`accept`/`send`/`recv`

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs (E29 v1):** every fallible stream-socket op carries its
  error as a constructor in its result type (no more `raise PortError`), and
  `sock-recv`'s length is refined `(> 0)` — the socket **partiality** hardened
  into the types, with `impl_ports.py` still the Category-C referent behind the
  typed face. Concretely: three new result sums (`ConnR`/`LisR`/`SendR`), an
  error arm added to the two existing ones (`RecvR`←`recv-err`, `AccR`←`acc-err`),
  five re-typed `sock-*` externs (connect/listen → sum, send → sum, recv →
  refined length), their five Python referents returning the sums, and every
  call site migrated to `case` the sums.
- **Deferred from v1 — `NetCap` capability-gating (Decision 1, the audit's key
  re-scope):** gating socket *creation* behind a `NetCap` grant is **hard-blocked
  on cap-reification-to-`main`** — every top-level `main` is `(=> Unit Unit)`, no
  demo threads a `Clock`/`Timer` from `main`, and a porttype has no constructor,
  so a required linear `NetCap` on `sock-connect`/`sock-listen` would make every
  socket-using demo untypecheckable. It rides the same reification edge as
  `Clock`/`Timer`/`Env`; the forward contract (linear `(1 net NetCap)`, threaded
  back per that precedent) is preserved in §6. E29 v1 leaves connect/listen
  cap-free.
- **Non-goals (→ §6):** self-hosting the socket crossings into `sys-tal`
  (hand-tal `socket`/`connect`/… behind the E51 seam — the result-sum *shapes*
  specced here are exactly what those wrappers will later produce at the floor);
  fd-passing (`sock-send-fd` is E30); poll/non-blocking deadline modes (E31);
  AF_INET (OURS is AF_UNIX); partial-send handling (keep `sendall`); the
  explicit local close of an *errored* fd.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the **Category-C port membrane** row is
  **CONFORMS** ("crossing SHAPE conforms to P3; opaque linear porttypes in the
  frozen set; linearity + frozen-set enforced by the checker") — so the *shape*
  is right and this run **must not reshape** it, only harden the fallible arms
  (creation-gating is deferred, Decision 1). E29 is REPLACE-CRUTCH: the typed
  face hardens; the CPython referent stays until the `sys-tal` socket element
  sheds it.
- **Live code (compose, do NOT respec):**
  - `scaffold/lib/ports.chiral` — the porttypes `Sock`/`LSock`/`Fd` and the full
    `sock-*` extern set already exist and are `=>` process arrows with linear
    (`1`) socket binders. **`RecvR` already carries the FLAG-corrected shape**
    `recv-r (bs Bytes) (1 sock Sock)` / `recv-closed (1 sock Sock)` (the
    half-close threads the live socket back). `AccR` = `acc-r (1 l LSock)
    (1 s Sock)` (listener + fresh stream, both linear). This run **adds error
    arms** and re-types connect/listen/send to their sums, keeping existing
    constructor names.
  - `scaffold/chirality/impl_ports.py` — `_sockconnect`/`_socklisten`/`_sockaccept`/
    `_socksend`/`_sockrecv`/`_sockclose`/`_lsockclose` (lines 129–199): the
    AF_UNIX referents. `_socklisten` already does `bind`+`listen(1)`; `_sockrecv`
    already lifts `b""`→`("con","recv-closed",[sv])`; sends use `sendall`. Each
    fallible op currently `raise PortError` on `OSError`.
  - The capability precedent: `Clock`/`Timer`/`Env` porttypes with
    `time-mono`/`sleep-ms`/`env-view` (ports.chiral:84–101) — `NetCap` is the
    same shape (authority = a held port), see Decision 1.
  - `bridge.verify` (bridge.py) already checks each extern return against its
    declared result type — the new sums verify structurally with no bridge change.
- **True delta (v1) = the fallible arms + refined recv**, not the crossings and
  not (yet) the creation gate: (a) error constructors on
  connect/listen/send/recv/accept; (b) the `(> 0)` refinement on recv length;
  (c) the referents returning sums instead of raising; (d) the call-site ripple.
  `NetCap`-gating is the deferred (b) above — its precedent (`Clock`/`Timer`/
  `Env`, ports.chiral:84–101) is named here only as the forward contract.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | **`NetCap` provenance + multiplicity** — minted per-process or granted by a parent? Linear-and-returned or shared? | **DEFERRED → cap-reification-to-`main`** *(the audit's key re-scope; see §6)* | The **multiplicity is decidable** from the built precedent — `docs/banks/capability.md` ("holding the port IS the authority… no ambient authority"; non-forgeability mechanism 3 = **q=1 linearity**, "a held port cannot be copied into two authorities") plus the three reified caps: `NetCap` would be `(1 net NetCap)`, a durable authority **threaded back through every arm, error arms included** (`ports.chiral:88–101`: `time-err`/`sleep-err`/`env-none` all carry their cap back). **But *provisioning* is blocked**, so gating can't land in v1: every top-level `main` is `(=> Unit Unit)`, no demo threads a `Clock`/`Timer` from `main` (profile-tomodachi: "time-mono deliberately absent"), and a porttype has no constructor — so a required `NetCap` param makes every socket-using demo untypecheckable. `NetCap`-gating therefore rides the **shared** reification edge (`Clock`/`Timer`/`Env`; tests conjure the atom until the profile-grants-to-entry path lands). v1 leaves connect/listen cap-free; the linear-threaded shape above is the forward contract (§6). *(The example §5's `conn-ok (s Sock)` also mis-modeled the cap by omitting the return — moot for v1, noted for the reification pass.)* |
| 2 | **Error arms: return the operand socket, or drop it?** | **RESOLVED** | On error the **operand** handle being operated on (the `Sock` in send/recv, the `LSock` in accept) is a **corpse** — `send-err`/`recv-err`/`acc-err`/`conn-err`/`lis-err` carry **only a `Str` msg**, no port back — the example's own post-`decision-effect-facets` note (2026-07-26, §2 finding 3), matching OURS golden (an `OSError` abandons the Python socket; GC closes the fd) and "no implicit destructor" (the errored fd is not a *live* resource the caller still holds). Only success and half-close (`recv-closed`) thread the live socket back. The narrow residual (does a self-hosted wrapper still need an explicit local close on the operand error path?) is **DEFERRED** to the `sys-tal` socket element (§6). *(When `NetCap`-gating lands, its durable cap threads back even on the error arm — Decision 1 — a distinct rule from the operand corpse here.)* |
| 3 | **`recv-closed` half-close shape** (the earlier FLAG). | **RESOLVED (already in code)** | `RecvR.recv-closed` already carries `(1 sock Sock)` in `ports.chiral` — peer EOF is a half-close, the local fd stays live and must be closed explicitly ([[decision-effect-facets]]: "no implicit destructor; cancel is explicit"). This SPEC only *adds* `recv-err`; it does not touch `recv-closed`. |
| 4 | **poll-deadline composition with a blocked `sock-recv`.** | **DEFERRED → E31** | Non-blocking / deadline modes are the poll element's lane; E29 keeps OURS blocking semantics. `poll2` already exists as the readiness primitive. |
| 5 | **Self-host the crossings, or stay on `impl_ports`?** | **RESOLVED → stay on `impl_ports`** | Example §6 is explicit ("`impl_ports.py` remains the Category-C referent until self-hosting sheds it"). The `sys-tal` socket crossings are the **E51 lane-A residue** — a distinct later element that will produce *these same result sums* at the floor via the E51 `sysbind` seam (built v1 2026-07-30, put/print/trace). This SPEC deliberately does not touch that seam. |
| 6 | **E39 effect-row interaction** with the re-typed externs. | **RESOLVED (no new interaction)** | The `sock-*` externs are *already* `=>` process arrows; changing a **result type** or adding a **domain parameter** does not change effectful status or the call-graph-inferred row (E39 steps 1–6, `row.py`). The new result sums are **pure `data`** (no arrows in ctor fields). No row annotation is owed. Regression-guarded by the existing effect-row + membrane tests. |

All dispositioned; none blocking. `status: draft` (unblocked).

## 4. Change plan (ordered, commit-sized)

> Constructor-name discipline: **keep existing names** (`recv-r`, `acc-r`) and
> only *add* arms — this minimizes the exhaustiveness ripple in §Step 5 to
> "every `case` grows one arm" rather than a rename.

### Step 1 — the result sums (types only)
- **Target:** `scaffold/lib/ports.chiral` — the `data` block (lines 24–30).
- **Change:** success threads the operand back; error is a corpse carrying only
  a `msg` (Decision 2). v1 is cap-free (Decision 1):
  - `(data ConnR () (conn-r (1 s Sock)) (conn-err (msg Str)))`
  - `(data LisR () (lis-r (1 l LSock)) (lis-err (msg Str)))`
  - `(data SendR () (send-r (1 s Sock)) (send-err (msg Str)))`
  - add `(recv-err (msg Str))` to `RecvR`; add `(acc-err (msg Str))` to `AccR`.
  Keep existing ctor names (`recv-r`/`acc-r`). Checks in isolation.
- **Size:** S

### Step 2 — connect/listen re-typed to their result sums
- **Target:** `scaffold/lib/ports.chiral` — externs (lines 34–35).
- **Change:** `(extern sock-connect (=> Str ConnR))` and
  `(extern sock-listen (=> Str LisR))` — result-sum only, **no `NetCap` param**
  (deferred, Decision 1). The ambient-creation gap stays exactly as today (the
  named capability violation, closed later by reification); v1 changes only the
  error surface, not the authority.
- **Size:** S

### Step 3 — `send`/`recv` re-typed
- **Target:** `scaffold/lib/ports.chiral` — externs (lines 38, 40).
- **Change:** `(extern sock-send (=> (1 s Sock) Bytes SendR))`;
  `(extern sock-recv (=> (1 s Sock) (refine I64 (> 0)) RecvR))` (`>` is a
  supported refine op, `refine.py:41 _OPS`). `sock-accept` already returns
  `AccR` (arm added in Step 1); `sock-close`/`lsock-close`/`sock-send-fd`
  unchanged (send-fd's error hardening rides E30).
- **Size:** S

### Step 4 — the five referents return sums (`impl_ports.py`)
- **Target:** `scaffold/chirality/impl_ports.py` — `_sockconnect` (129), `_socklisten`
  (139), `_sockaccept` (150), `_socksend` (165), `_sockrecv` (183).
- **Change:** replace each `try/except OSError → raise PortError(msg)` with a
  `return ("con","<op>-err",[msg])` carrying the **same message shape**; wrap the
  success path in its `-r` constructor (`("con","conn-r",[sockval])`,
  `("con","lis-r",[lsockval])`, `("con","send-r",[sockval])`). `recv-r`/
  `recv-closed`/`acc-r` success shells unchanged. Signatures are cap-free (no
  `netcap` arg — Decision 1). `_sockrecv`'s `n` stays a runtime int; the `(> 0)`
  obligation is discharged at compile time, no runtime guard.
- **Size:** M

### Step 5 — migrate every call site (the ripple)
- **Target:** demos `duo`/`node-sensor`/`tomodachi`/`sensor-core`/`wl-client`
  (+ their `profile-*`), any `lib/*` sender, and tests
  `test_kernel`/`test_secret`/`test_effect_row` that construct `sock` values.
- **Change:** (a) every `sock-connect`/`sock-listen` site `case`s `ConnR`/`LisR`
  (bind the socket on `-r`, surface `msg` on `-err`) instead of binding a bare
  handle — **no `NetCap` threading in v1** (Decision 1: connect/listen stay
  cap-free); (b) every `sock-send` site `case`s `SendR` instead of binding a
  bare `Sock`; (c) every `(case (sock-recv …))`/`(case (sock-accept …))` grows a
  `recv-err`/`acc-err` arm (surfacing the msg upstream, or `halt`); (d) `refine`d
  recv args are literals ≥ 1 already (`4096`), so they satisfy `(> 0)` unchanged.
  The example §5 `echo-turns`/`serve` skeleton is the template for the `case`
  shape (ignore its `NetCap` parameter — deferred). Profiles' frozen port sets
  are unchanged (same crossing names).
- **Size:** L (the exhaustiveness/threading churn across ~6 demos + 3 test files)

### Step 6 — bookkeeping
- **Target:** `records/conformance-map.md` (Category-C row: note the
  error-arms + `NetCap` gate landed; still CONFORMS), `examples/INDEX.md`
  (E29 → `implemented`), frontier re-condense if flagged.
- **Size:** S

## 5. Conformance gate

- **Golden behavior (differential vs the pre-change `impl_ports` semantics):**
  1. **Success path unchanged, observably.** The tomodachi e2e (`test_e2e.py`,
     driving `demo/tomodachi.chiral` against the mock compositor/niri) checks and
     runs with byte-identical frames/behavior after the call-site migration —
     `sock-listen` = bind+listen(1), `recv` EOF surfaces `recv-closed` (never
     `b""`), send is `sendall`.
  2. **Errors are constructors, same message shape.** Injecting an `OSError` in
     a referent (mock) yields the matching `*-err` con carrying the same string
     OURS would have put in the `PortError`, and the caller's `case` must handle
     it (coverage-enforced) — no `PortError` escapes a fallible op.
  3. **Recv length is refined.** A `sock-recv` with a `0`/negative length
     literal is a **refinement (compile) error**; `4096` passes. *(Creation
     capability-gating is deferred — Decision 1 — so no `NetCap` check in v1.)*
- **Tests to add (`scaffold/tests/`):** `test_sock_error_arms` (each fallible op
  → its `*-err` con with OURS message shape, via a referent-injected `OSError` —
  e.g. connect to a bogus path); `test_recv_length_refined` (`sock-recv s 0`
  fails `check`, `sock-recv s 4096` passes). Compare against the reference
  runtime; the tomodachi e2e success-path regression is the differential floor.
- **Green line:** 328 → ≥ 330 (`test_sock_error_arms` may split per-op);
  existing `test_e2e` + effect-row + membrane suites green; `tools/ledger-lint/ledger-lint.py`
  clean.
- **Done when:** every fallible `sock-*` op carries its error as a constructor
  (no `PortError` escapes), `sock-recv` length is refined `(> 0)`, and the
  tomodachi e2e plus all migrated callers check and run with unchanged
  success-path observables.

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - **Self-hosted socket crossings** — hand-tal `socket`/`connect`/`bind`/
    `listen`/`accept`/`send`/`recv` behind the **E51 `sysbind` seam** (built v1
    2026-07-30), producing *these* result sums at the floor. The **E51 lane-A**
    residue; the sums specced here are their forward contract. [[E51-sys-linkage]]
  - **Explicit local close of an errored fd** — the narrow question the 2026-07-26
    note scoped out (Decision 2); lands with the self-hosted wrapper (which must
    close-on-error at the floor), not the CPython referent (GC closes today).
  - **`NetCap` capability-gating (deferred from v1, Decision 1)** — gate socket
    creation behind a `NetCap` grant, closing the ambient-authority violation
    for the net face. **Blocked on cap-reification-to-`main`**: top-level `main`
    is `(=> Unit Unit)` and cannot obtain a linear porttype (no constructor), so
    this rides the **same** edge as `Clock`/`Timer`/`Env` (the profile grants the
    cap to the entry; tests conjure the atom until then). **Forward contract when
    it lands:** `(porttype NetCap)`; `sock-connect : (=> (1 net NetCap) Str ConnR)`
    / `sock-listen : (=> (1 net NetCap) Str LisR)`; `NetCap` is a *durable* linear
    authority **threaded back through every arm including the error arm** —
    `conn-r (1 net NetCap) (1 s Sock)` / `conn-err (1 net NetCap) (msg Str)`
    (exactly `TimeR`/`SleepR`/`EnvR`, `ports.chiral:88–101`; the example §5's
    cap-less `conn-ok` mis-modeled this). [[capability]] · [[decision-effect-facets]]
  - **Knobs deferred:** `ConnectCap`/`ListenCap` split; AF_INET; non-blocking /
    poll-deadline modes (→ E31); partial-send; `listen` backlog > 1.
- **Follow-on:** [[E30-fd-passing]] (`sock-send-fd` rides on `Sock` + its own
  error hardening); the `sys-tal` socket self-host (E51 lane A); E31 poll
  steps 4–6 (readiness surface over these sockets).
- **Related:** [[E29-sockets]] · [[E26-alarm-control-flow]] (`PortError` →
  result sums) · [[E51-sys-linkage]] · [[decision-effect-facets]] · [[capability]].
