# Deployment, personal-host & custody — session capture (2026-07-24)

> **PROMOTED 2026-07-26 → canon.** Ratified into `docs/decision-deployment-custody.md`
> (a settled `decision-*.md`). The sub-call is decided there: "personal host" does
> **not** enter `live-environment` as a new construct — it is the deployment view of
> the existing self-similar instance. This note is retained as the exploration
> record; the decision note is authoritative.

**Status: EXPLORED → PROMOTED.** This consolidates a design session so it survives
context compaction. Settled sub-parts were captured into canonical docs
(see "Captured elsewhere" below); the vision itself is now
`docs/decision-deployment-custody.md`.

## Why this note exists

The session kept reaching for a **product/deployment layer** (chirality you download
and run as a personal host, with configurable secret custody). Research
(deployment/bootstrap/custody sweep) found the split below. The recurring shape:
the *machinery* is real; the *product framing* is unwritten and mostly a
**decentralised translation of a centralised instinct**.

## Documented vs. synthesis (the honest split)

| Piece | State | Note |
|---|---|---|
| Two-rung ladder (self-hosted-on-Linux ↔ chirality-as-OS-on-metal) | **REAL**, planning-only | `SELF-HOST-PLAN.md`; C8 says port the rung-1 statement into `trust-boundary`. "Rung 1 completes ownership; rung 2 completes sovereignty." |
| Personal-host = any staged instance | **mechanism REAL, framing NEW** | G3 self-similarity is documented; "a downloaded instance IS a personal host" is not. "cockpit" already means the Emacs/manas UI. |
| Install / 1-click / skip-install ergonomics | **ABSENT** | Only real hook: tomodachi's *"customization = a typed module swap."* |
| Bootstrap model | **REAL**; download-trust link ABSENT | Trust ties to boot roots + stage-time succession, never to "trust the download." |
| Secret custody (store + capability-guarded access) | **DESIGNED + type-level seed (E40)**, enforcement unbuilt (E56, E43) | opaque linear `Secret`, single guarded exit; memory custody absent (`status-ledger`). |
| Configurable multi-level keys | **SPLIT** | abstract tiers T0–T3 documented; physical/hardware keys ABSENT (only TPM-as-out-of-scope-counter, edge 20). |

## The centralised → decentralised translation

The instincts survive; the *shape* inverts (the architecture forbids centres:
edge 8 "no global registry is expressible"; module bank "no package registry";
`derive-not-store`).

| Centralised instinct | chirality (per-instance) form |
|---|---|
| personal host | *your own* self-similar instance — not a special host role |
| secure store | per-instance custody + derive-not-store — not a central vault |
| download + trust it | acquire a moduleset, **stage it, certify at staging** — not trust-the-download |
| 1-click customization | **customization = a typed module swap** (tomodachi already says this) |

## Multi-level keys land on the rung ladder

Not a gap — *seated where it belongs*:
- **Software key levels** (passphrase-derived, split-K-of-N, tier-by-classification) → **rung 1**, already the T0–T3 model.
- **Physical/hardware key levels** (TPM, token, register custody) → **rung 2** — the same place register-custody and the full SECURE-DATUM story live. Out of scope until metal, by design.

## Security worry map (the instance/succession model)

Four clusters, not a pile:

1. **Succession integrity** — the judgment-change path is the top target. Defended by kernel-spec certification + degrade-to-B-blob. Real worry: *kernel-spec itself is the security boundary* (→ C7/E52 "spec readable in a sitting" is a security constraint). **Two new obligations** (now in edge 5): migrated state must be certified against the successor's types (a typed `code_change`); succession-*initiation* must be a linear capability, never ambient.
2. **Capability discipline** — no ambient authority anywhere; auth = linear ports; configuring auth = ordinary typed code. Every ambient extern (`print`, clock, env) is a live hole until reified.
3. **Bootstrap base case** — the chicken-and-egg: the first judgment can't be certified by a prior one. Answer is *attestation by independent reconstruction* (DDC/E53, re-bootstrap manifest/E72), not certification. Honest residue: one author ⇒ authorship-diversity named-not-real (D7/edge 11).
4. **Prevention/detection boundary** — typed zone = structural prevention; substrate/foreign/DMA zone = detection + blast-radius bounding. **At rung 1 the whole model is discipline on a Linux we don't control, not enforcement** — only metal (rung 2) converts it. Do not overstate this.

## The "auth everywhere but structurally can't do whatever" bet

The constraints *are* the ergonomics: because auth = linear ports = ordinary
values, configuring auth is ordinary code, not a separate security system to
subvert. "Can't do whatever" = ungoverned action is *inexpressible*, not
*forbidden-by-a-disable-able-checker*. Failure mode (held, not collapsed): if
threading caps everywhere is painful, people route around it — **C6 (dev-profile
ambient threading)** is the unbuilt ergonomics lever that makes it livable.

## Captured elsewhere this session (settled parts)

- **Edge 6** shaped (`open-edges.md`) — the tal-vocabulary line drawn: floor is
  thin, structs are library composition, not floor primitives; E30 disposition.
- **Edge 5** sharpened (`open-edges.md`) — dynamism reframe: freeze binds the
  judgment not the population; fine-grained certified succession; the
  cutover-window (not a hot-swap); the two new obligations.
- **`axis-altitude.md`** — new "The floor is thin" section (the substrate-
  minimality invariant + the "altitude error" name).

## Open author calls (do NOT silently resolve)

- ~~Canon-level + home for this vision~~ — **RESOLVED 2026-07-26 → promoted to
  `docs/decision-deployment-custody.md`**; "personal host" does NOT enter
  `live-environment` as a new construct (it's the deployment view of the existing
  self-similar instance).
- Whether to mint the **typed ABI-layout abstraction** (edge 6's open call).
- The tool priority for the next handoff: **doc-expansion tooling** (grow/
  condense the ecosystem so it self-orients) > the frontier-orientation bundler
  (has use for opening chats, secondary).
- ~~C8 propagation (rung model → `trust-boundary`)~~ — **DONE 2026-07-24** (the "two rungs" section, with the honest rung-1 secret-custody statement).
