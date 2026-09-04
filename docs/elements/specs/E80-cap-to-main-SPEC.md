---
element: E80
slug: cap-to-main
title: Capability reification to `main` (profile-grants-to-entry): the profile hands the entry point its reified ambient caps (Console/Clock/Timer/Env/NetCap) the way `spawn` hands `node-main` its peer port — `main` grows from `(=> Unit Unit)` to receive the granted linear porttypes; closes the ambient-authority violations named in decision-effect-facets and unblocks E29's deferred NetCap third (forward contract in the E29 SPEC §6) + the shared Clock/Timer/Env edge (added 2026-08-01, author-ratified: build, not defer)
kind: BUILD-PROPER
example: examples/E80-cap-to-main.md
status: audited
updated: 2026-08-02
---

# E80 SPEC — Capability reification to `main` (profile-grants-to-entry)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> **Position:** E80 is **buildable now** — it is *not* gated on the checker port
> (unlike E52), it is the same class of cap infrastructure E29/E32/E33 already
> added to the current host, and it ports along with the rest (E51 lane), not as
> throwaway. It is a **security-completeness** element, **not a self-host
> blocker** (chirality could self-host with ambient `print`); so its *queue position*
> relative to the build wave is the author's cadence call, surfaced in §6 — the
> *build* decision itself is already ratified.

## 1. Deliverable

- **After this runs:** `main` receives its authority as a **linear grant from
  the profile** — `main : (=> (1 g Grant) Unit)` where `Grant` bundles the
  reified caps; two new porttypes (`Console`, `NetCap`) — the `Console` cap-gated
  successors `console-put`/`console-trace` (for `print`/`trace`), and `NetCap`
  **declared + delivered to `main`**, which *unblocks* E29's deferred re-signing
  of `sock-connect`/`sock-listen` (that re-sign + its caller ripple is **E29's
  follow-on, not E80** — §6); a profile `(grants …)`
  clause plus the checker rule that enforces **the granted cap set == `main`'s
  `Grant` fields**; and the entry mints the real caps and calls `main` with them.
  Under a **cap-granting profile**, ambient `print`/`trace`/`env-get` are out of
  the port set (only the cap-gated form is reachable); the *default* profile
  keeps them for back-compat, so the existing suite stays green — full ambient
  retirement + demo migration is a follow-on (§6).
- **Non-goals:** the **native entry-stub** minting (the raw-x86 psABI entry that
  constructs caps for an ELF binary → **E34** follow-on; this SPEC does the
  CPython-host minting via `impl_ports`, the current floor). **Attenuation /
  grant-narrowing** (`subtype`∘refinement, capability bank Shard C — a separate
  present-but-unapplied EXTEND). NetCap's *richer* operations beyond gating
  socket creation (E29's surface). The **reflective-floor** non-forgery tier
  (Shard B mechanism #4 → E45). `argv` as a capability (stays entry-stack data;
  §3).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none — E80 postdates the map snapshot; treat as
  **BUILD**. The capability bank is the build-state authority: Shard A
  (authority = a held linear port) **CONFORMS**; Shard B non-forgeability =
  four mechanisms, three built (no-constructor porttype, frozen port set,
  q=1 linearity), the fourth (reflective floor) unbuilt (E45). **No bank shard
  covers "the entry receives its caps"** — that origin seam is exactly E80's gap.
- **Live code this composes with (do NOT respec):**
  - `lib/ports/ports.chiral` — the cap model is half-built: `(porttype Clock/Timer/Env)`
    (106–108) with cap-gated `time-mono`/`sleep-ms`/`env-view` (121–123) that
    thread the cap back (the RecvR pattern, `TimeR`/`SleepR`/`EnvR` at 110–119).
    `Sock`/`LSock`/`Fd`/`Pool` porttypes (12–19). **The `spawn`→`node-main`
    precedent** E80 mirrors: `spawn : (=> Str Sock)` (88) mints a peer;
    `node-main : (=> (1 peer Sock) Unit)` (`demo/node-render.chiral:72`) receives
    it linearly. **Ambient holdouts:** `print`/`put`/`trace`/`env-get` (92–95),
    and `sock-connect`/`sock-listen` (56–57) take **no** NetCap — network
    authority is ambient today.
  - `surface.py` — profile machinery: `top_profile` (226), `verify_profiles`
    (~528) build a report over the frozen port set; `(target … (require main
    …))` + `(profile … (ports …) (target …))` is the existing surface
    (`demo/profile-headless.chiral:7–14`). E80 adds a `(grants …)` clause and a
    verify rule here.
  - Cap minting today = `impl_ports` binding host referents (the E32 pattern for
    Clock/Env); E80 adds Console/NetCap bindings and the entry hand-off.
- **True delta:** two new porttypes + cap-gate the five ambient externs + the
  `Grant` type + `main`'s grant parameter + the profile `(grants …)` clause +
  the checker's grants-set == `Grant`-fields rule + the entry mint-and-hand-off.

## 3. Decisions

| # | Question (example §6) | Disposition | Rationale / owner |
|---|-----------------------|-------------|-------------------|
| 1 | `Grant`-as-record vs `main` taking individual linear params | **RESOLVED → bundled `Grant` record** | Decidable design call (not author-tier): the checker contract is identical either way; one record matches "one grant handed to the entry" and keeps `main`'s arity stable as the cap set evolves (add a field, not a param). Individual params remain a mechanical alternative if a profile grants a single cap. |
| 2 | Do `argv`/command-line args arrive as a cap, or as entry-stack data? | **RESOLVED → entry-stack data** | Follows the settled E32 precedent (`env` = entry-stack data, "not a syscall"; `docs/E32` / `ports.chiral` env split). `argv` is *input*, not *authority* — it carries no crossing power, so gating it would be ceremony without a violation to close. A gated `Args` cap remains available later if a use case needs read-mediation, exactly as `Env`/`env-view` sits beside raw env. |
| 3 | New `(grants …)` profile keyword vs reusing the `(ports …)` frozen-set entry | **RESOLVED → new `(grants …)` clause** | Distinct semantics: `(ports …)` names the *crossings the composite may use* (a permission set, `surface.py` verify); `(grants …)` names the *caps minted and handed to `main`* (a mint list bound to the entry's `Grant`). Collapsing them would overload one clause with two meanings — the P2 "not two accounts of different things in one" smell. Checker-mechanical either way; the separate clause is the honest surface. |
| — | **Queue position** (build now vs after self-host) | **AUTHOR (non-blocking) — priority/cadence** | E80 is buildable now and independent of the checker port, but is a security-completeness element, not a self-host blocker. When it lands relative to the build wave is the author's cadence call (the user drives wave order). Does **not** block this SPEC — it is `audited`/implement-ready whenever chosen. |

No blocking NEEDS-AUTHOR → `status: draft`. The build decision is already
author-ratified (2026-08-01); §3 rows 1–3 are decidable design calls settled
here; the only author input owed is *when* to build it.

## 4. Change plan (ordered, commit-sized)

> **Trusted-checker edit flagged:** Step 3 touches `surface.py` (profile
> verification) — reviewed as the sensitive class (diff shown explicitly).

### Step 1 — reify the two ambient caps (`lib/ports/ports.chiral`)
- **Target:** `lib/ports/ports.chiral` — new porttypes + successors near the process block.
- **Change:** `(porttype Console)`, `(porttype NetCap)`; `(data OutR () (out-r
  (1 c Console)))` + `(extern console-put (=> (1 c Console) Str OutR))` and
  `console-trace` (the `print`/`trace` successors, RecvR-threaded). **NetCap is
  declared here so `Grant` can carry it and the entry can mint it — but
  `sock-connect`/`sock-listen` are NOT re-signed in E80.** Re-signing them
  changes E29's built externs and ripples through every caller +
  `test_sockets.py` (the E29 caller-ripple lesson); that is E29's deferred-third
  follow-on, which E80 *unblocks* by making NetCap exist and reach `main` (§6).
  Ambient externs stay present; their exclusion is *per-profile* (Step 4).
- **Size:** ~M.

### Step 2 — the `Grant` bundle + the entry convention
- **Target:** `lib/ports/ports.chiral` (or a small `lib/entry.chiral`).
- **Change:** `(data Grant () (grant (1 con Console) (1 clk Clock) (1 tmr Timer)
  (1 env Env) (1 net NetCap)))` — linear bundle (linear by E8's walk). Document
  the entry convention: a program's `main` is `(=> (1 g Grant) Unit)`; a profile
  that grants a subset produces a correspondingly narrower `Grant`.
- **Size:** ~S.

### Step 3 — the profile `(grants …)` clause + the checker rule
- **Target:** `scaffold/chirality/surface.py` — `top_profile` (parse) +
  `verify_profiles` (the rule).
- **Change:** parse `(grants Cap …)` in a profile block; on `chirality verify`,
  enforce that the granted cap set **equals** the field cap-types of the `Grant`
  that the profile's `(require main …)` names — a mismatch is a verify failure
  (the report shape already used for target/port-set rows). This is the "profile
  hands caps to `main`" contract made structural.
- **Size:** ~M.
- 2026-09-04: the Python oracle was cut, and scaffold/ went with it in the 2026-08-31 migration. The citations it left are kept as a record and have no live successor.

### Step 4 — mint at the entry + profile-scoped ambient exclusion
- **Target:** the entry/runtime (`impl_ports` bindings + the `main` invocation
  path) + the cap-granting profile's port set.
- **Change:** the CPython-host entry constructs `Console` (fd 1/2), `NetCap`
  (socket-creation authority), reuses the E32 `Clock`/`Env` mints, packs a
  `Grant`, and calls `main` with it (the top-level analog of `spawn` handing
  `node-main` its `Sock`). A **cap-granting profile** excludes ambient
  `print`/`trace`/`env-get` from its port set (only the cap-gated form is
  reachable under it); the *default* profile is unchanged for back-compat, so the
  existing 430 stay green. Forced global retirement + migrating existing
  demos/tests off ambient externs is a follow-on (§6). (Native entry-stub minting
  → E34; non-goal here.)
- **Size:** ~M.

### Step 5 — demo + conformance tests
- **Target:** `scaffold/demo/` + `scaffold/tests/test_cap_to_main.py`.
- **Change:** a demo `main : (=> (1 g Grant) Unit)` that greets the console and
  reads an env key under a profile that `(grants Console Env)`; plus the negative
  tests (§5).
- **Size:** ~S.
- 2026-09-04: cut Python oracle, no live successor.

## 5. Conformance gate

- **Golden behavior:** the demo runs and produces output **identical** to an
  ambient baseline of the same program — but authority now flows from the profile
  grant through `main`, not ambiently. The split is proven by three rejections:
  (a) under the cap-granting profile, code calling ambient `print` (excluded from
  its port set) → **verify reject**; (b) a `main` that leaves any granted cap
  unconsumed → **linearity
  reject** (the q=1 account); (c) a profile whose `(grants …)` set ≠ `main`'s
  `Grant` fields → **verify reject** (Step 3's rule).
- **Tests to add:** `test_cap_to_main.py` — (1) `test_granted_main_runs`
  (positive, output matches baseline); (2) `test_ambient_print_rejected`;
  (3) `test_dropped_cap_rejected` (linearity); (4) `test_grants_mismatch_rejected`
  (verify rule). Python-host floor now; native-entry differential rides E34.
- **Green line:** 430 → ≥ 434; `python3 tools/ledger-lint/ledger-lint.py` clean.
- **Done when:** a program's entry authority is a typed grant from its profile,
  the demo runs identically to its ambient baseline, and each of the three
  ambient/dropped/mismatch cases is a rejection rather than a silent success.

## 6. Residue & links

- **Deliberately unbuilt (with homes):**
  - Native entry-stub minting (psABI entry constructs caps for an ELF binary) →
    **[[E34-elf-writer]]** (its entry stub is already a raw-x86 shrinking crutch).
  - Grant-narrowing / attenuation (`subtype`∘refinement over grants) → capability
    bank **Shard C** EXTEND (present-but-unapplied; separate element).
  - The reflective-floor non-forgery tier (can't forge by rewriting `Sig`) →
    **E45** (Shard B mechanism #4).
  - **Re-signing `sock-connect`/`sock-listen` to consume NetCap + the caller
    ripple** (`test_sockets.py` and every call site) → **[[E29-sockets]]**
    deferred-third follow-on, which E80 unblocks by making NetCap exist and reach
    `main`. E80 delivers the cap; E29 gates the sockets.
  - **Forced global ambient retirement + migrating existing demos/tests** off
    `print`/`env-get` → follow-on; E80 makes cap-gating available + enforced
    under a cap-granting profile, keeping the default back-compatible.
  - NetCap's richer operations beyond gating socket creation → **[[E29-sockets]]**.
  - `argv`-as-a-cap (`Args`) → deferred; entry-stack data suffices (decision #2).
- **Follow-on this unblocks:** E29's deferred NetCap third (its SPEC §6 forward
  contract) fully closed; Clock/Timer/Env become *reachable* from real programs
  (today their cap-gated ops are uncallable — no cap source); the "no ambient
  authority" thesis holds down to the entry.
- **Related:** [[E80-cap-to-main]] (rationale), `decision-effect-facets` (the
  profile-hands-caps-to-main direction), `banks/capability` (the refraction —
  Shards A/B/C the entry seam completes), [[E29-sockets]] (NetCap),
  [[E32-clock-exit-env]] (Clock/Timer/Env + env-as-entry-stack precedent),
  [[E33-process-spawn]] / spawn→node-main (the precedent mirrored),
  [[E34-elf-writer]] (native entry minting).
