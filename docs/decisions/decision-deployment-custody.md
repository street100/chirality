---
node: decision-deployment-custody
layer: decision
related: [live-environment, trust-boundary, node-architecture, modules-custody, split-role, target-tomodachi, bootstrap-sequence, open-edges, thesis]
status: settled
updated: 2026-07-26
---

# Decision: deployment, personal-host & custody are a per-instance decentralized translation

Ratified 2026-07-26 — promoted from `.planning/VISION-deployment-custody-2026-07-24.md`
(the 2026-07-24 exploration). The exploration found a recurring shape: the
*machinery* a product/deployment layer needs is already real; the *product
framing* was unwritten and was mostly a **decentralized translation of a
centralized instinct**. This note settles that framing as canon.

## The decision

chirality's product / deployment / custody layer is **not a new subsystem**. It is the
**per-instance, decentralized form** of the centralized instincts a product layer
usually reaches for. The architecture forbids centres — [[open-edges]] edge 8 ("no
global registry is expressible"), no package registry, `derive-not-store` — so each
centralized instinct **inverts** into a per-instance shape rather than being added
as a central organ:

| Centralised instinct | chirality (per-instance) form |
|---|---|
| personal host | *your own* self-similar instance — not a special host role |
| secure store | per-instance custody + `derive-not-store` — not a central vault |
| download + trust it | acquire a moduleset, **stage it, certify at staging** — not trust-the-download |
| 1-click customization | **customization = a typed module swap** ([[target-tomodachi]] already says this) |

The instincts survive; the *shape* inverts. This is the thesis applied to product
form: a centre is not forbidden by a rule, it is **inexpressible** — there is
nowhere in the node model ([[node-architecture]]) for it to be.

## Personal-host = a self-similar staged instance

A downloaded/staged instance **is** a personal host — G3 self-similarity
([[node-architecture]], [[bootstrap-sequence]]), not a special host role bolted on.
Trust ties to boot roots + stage-time succession, never to "trust the download":
you acquire a moduleset and **certify it at staging**, the same crossing any staged
runtime already goes through.

**Sub-decision (the exploration's open call): "personal host" does NOT enter
[[live-environment]] as a new construct.** It is the *deployment view* of the same
self-similar instance the live-environment already describes (the reflective floor +
the node model); live-environment *references* it, it does not *mint* it. Adding a
"personal-host" construct would be overhead an existing abstraction already covers
(principle 6). The word **cockpit** stays the Emacs/manas UI; "personal host" is the
ownership/deployment framing of the instance beneath it.

## Custody: derive-not-store, keys on the rung ladder

Secret custody is **per-instance `derive-not-store`** with a single guarded exit —
an opaque linear `Secret` ([[modules-custody]]); the type-level seed exists (E40),
enforcement is unbuilt (E56, E43), and memory custody is absent ([[trust-boundary]],
`status-ledger`). Multi-level keys are **not a gap** — they land on the two-rung
ladder ([[trust-boundary]]):

- **Software key levels** (passphrase-derived, split-K-of-N, tier-by-classification)
  → **rung 1**, already the T0–T3 model ([[split-role]]'s tiers).
- **Physical/hardware key levels** (TPM, token, register custody) → **rung 2** —
  where register-custody and the full secure-datum story live. Out of scope until
  metal, by design (the TPM monotonic counter is [[open-edges]] edge 20's
  out-of-scope hardware).

## The security worry map — four clusters, not a pile

1. **Succession integrity** — the judgment-change path is the top target, defended
   by kernel-spec certification + degrade-to-B-blob. The real worry: *kernel-spec
   itself is the security boundary*, so "spec readable in a sitting" (E52/E72) is a
   **security constraint**, not just ergonomics. Two obligations now live in
   [[open-edges]] edge 5: migrated state must be certified against the successor's
   types (a typed `code_change`); succession-*initiation* must be a linear
   capability, never ambient.
2. **Capability discipline** — no ambient authority anywhere; auth = linear ports;
   configuring auth = ordinary typed code. Every ambient extern (`print`, clock,
   env) is a live hole until reified ([[open-edges]] edge 16 / decision-effect-facets).
3. **Bootstrap base case** — the first judgment cannot be certified by a prior one.
   The answer is **attestation by independent reconstruction** (DDC/E53, re-bootstrap
   manifest/E72), not certification. Honest residue: one author ⇒ authorship-diversity
   named-not-real ([[open-edges]] edge 11 / docket D7, resolved-in-direction to
   re-derivability).
4. **Prevention/detection boundary** — the typed zone is structural prevention; the
   substrate/foreign/DMA zone is detection + blast-radius bounding ([[open-edges]]
   edge 15). **At rung 1 the whole model is discipline on a Linux we do not control,
   not enforcement** — only metal (rung 2) converts it. Do not overstate this.

## The bet: the constraints are the ergonomics

Because auth = linear ports = ordinary values, **configuring auth is ordinary code**,
not a separate security system to subvert. "Can't do whatever" means an ungoverned
action is **inexpressible**, not *forbidden by a disable-able checker*. The honest
failure mode, held not collapsed: if threading capabilities everywhere is painful,
people route around it — **C6 (dev-profile ambient threading)** is the unbuilt
ergonomics lever that makes the discipline livable ([[decision-profiles]]
default-flipping, not an exemption).

## Honest state — machinery real, product framing new

The machinery is real; only the framing was unwritten. Per the exploration's audit:
the two-rung ladder is real (planning-only, `SELF-HOST-PLAN.md`); personal-host
mechanism is real, framing was new (now this note); install/skip-install ergonomics
are absent (only tomodachi's "customization = typed module swap" is real); the
bootstrap model is real but any "trust the download" link is absent; secret custody
is designed with a type-level seed, enforcement unbuilt; configurable multi-level
keys are split (abstract tiers documented, physical keys are rung-2/absent). This
note settles the **framing**; it does not claim the enforcement is built.

## Principle basis

P1 — a centre is not banned, it is inexpressible (no node for it). P2/P3 — custody,
auth, and key levels are all *typed* (linear `Secret`, linear ports, tier-in-the-type),
so "configure security" is "write ordinary governed code." P4 — the safe path is the
cheap path only if the ergonomics lever (C6) lands; named as the held risk. P5 —
the unprovable base (bootstrap) is covered by independent reconstruction, not by a
trusted centre. The decentralization is not a preference; it is what the thesis
forces once no centre is expressible.
