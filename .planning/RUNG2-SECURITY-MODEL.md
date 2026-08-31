# Rung-2 capability & security model — invariants, posture, ceremony

> Companion to `.planning/RUNG2-MICROVM-MAP.md` (the build map: drivers + programs)
> and `SECURE-DATUM-MODEL.md` (the CPU+RAM threat model). **This doc is the
> authority/security architecture** that constrains *how* the rung-2 substrate is
> built: what is invariant, what is configurable, how blast radius is bounded, and
> how legitimate change happens. **Seated, not scheduled.** Where it cites unbuilt
> elements it says so; §6 is the consolidated dependency list.
>
> Provenance: worked out in the 2026-08-10 design session. Grounds on
> `node-architecture.md`, `permission-model.md`, `decision-effect-facets.md`,
> `decision-reflective-floor.md`, `decision-deployment-custody.md`,
> `decision-profiles.md`, `axis-typeability.md`, `SECURE-DATUM-MODEL.md`.

---

## 1. The sole invariant: composability. Everything else is default, not floor.

The one thing truly invariant is the **composition discipline itself — ports match
ports, the checker verifies the match.** That is not a security *setting*; it is the
*medium* — it is what chirality is. Everything else, **including every security
discipline below, is a default wiring you can recompose.**

- chirality does **not forbid** insecure wiring. It makes it **legible** — a
  concentration of authority shows up *in the port graph*; you cannot hide a
  god-cap, the wiring names it — and it makes the secure composition the **default
  and the natural path.**
- The explicit escape from the typed discipline is the **B-bridge**
  (`axis-typeability.md`): leaving the typed world is a *marked, quarantined*
  bridge, never a silent hole.
- **Legibility replaces paternalism.** Sane defaults, full recompose, and any
  weakening is always visible in the wiring — *"if you want it different, match
  ports to ports."*
- The only genuinely inescapable rule is "an unmatched port won't compose" — and
  that is type-correctness, not a security dial.

**Consequence:** every "invariant" below is really *the secure default we ship + the
property it yields*. A user may recompose weaker or stronger; this doc's job is to
define the secure default and make the cost of each deviation legible.

## 2. Security posture is a configurable spectrum (per-grain, compiled, frozen)

Posture rides machinery already present: the **profile/manifest axis**
(`decision-profiles.md`) + the **type-driven per-datum policy**
(`SECURE-DATUM-MODEL.md §6`).

- **Per-grain, not one global knob.** Each capability / datum-class picks its own
  posture — some max-secured (register-rooted, split, moving-target), some
  structure-only. The manifest is that surface.
- **Compiled-in, not a runtime flag.** The compiler *weaves* the active layers per
  the manifest; turning a layer off = the compiler doesn't emit it.
- **Frozen at staging (reflective floor).** So **a running compromise cannot dial
  posture down** — a posture change is a quorum'd re-stage (§4), never a flag a
  process can flip. The config mechanism is itself structurally protected.

### 2.1 Default-secure vs. tunable

Nothing is un-recomposable (§1) — but the *default* separates cleanly:

- **Structural (default floor — yields *spatial* confinement on a *trusted*
  substrate):** no ambient authority; can't-name-what-you-don't-hold;
  linearity/Move; type-check = capability-check; judgment frozen at staging.
- **The cost-multiplier stack (tunable, max → off):** encryption at rest/wire;
  register-rooted per-datum keys; splitting + quorum threshold K; moving-target
  refresh; clear-window size; chaff; robust-shares; MAC/versioning; attenuation
  tightness; boot-chain layer count + anchor-split K; constant-time (E60);
  re-measurement frequency.

### 2.2 The honest cost of the low end (make it legible; bind it to threat model)

"Let the structure do the work" = run the structural default only. Coherent — but
structure gives **spatial** confinement on a **trusted** substrate; it does not
give:

| Dial down… | …lose (structure gives *zero* here) |
|---|---|
| crypto-at-rest | untrusted-substrate / DMA reads everything |
| moving-target + versioning | **temporal** containment → "one time" → "every time / persistent" |
| splitting + quorum | concentration points reappear — one key/admin = root |
| boot-chain layers | tamper undetectable |
| attenuation | blast radius = full cap, not minimal |

**Posture must be bound to threat model:** microVM-on-trusted-host → structure-heavy
is right (DMA isn't the threat); real-metal-vs-DMA → must dial up. The manifest
should surface, at each setting, what has been given up.

## 3. The two hard invariants (the audit theses)

The secure default must deliver both. Each reduces to one test.

### T1 — structurally no full control ⇔ *no un-split concentration point*

Full control is unreachable **iff every would-be-root is split below a
quorum/threshold or self-destructs.**

| Concentration | Must be | Status |
|---|---|---|
| **trusted checker core** (`node-architecture.md` — the one named concentration) | quorum'd — E52 producer/consumer split | **UNBUILT** (one checker today) → T1 unproven |
| **admin / config-edit capability** (P7 — rewrites the manifest) | Shamir K-of-N, never one holder | **UNSPEC'd — #1 hole**: anything that rewrites dedications is the new root |
| **install genesis authority** (P6) | mint-then-**drop**, no persistent genesis cap | **UNSPEC'd** — the base case (§4.4) |
| **register master secret** (`SECURE-DATUM §3`) | split + refresh (§4 warns raw same-RAM split isn't a multiplier) | holds vs **DMA**, **not vs CPU-code-execution** (model excludes; needs hardware) |
| **manifest-write path** | unreachable from any resident session + quorum'd to edit | **UNSPEC'd** |

### T2 — blast radius = one user, one time ⇔ *every release is attenuated + ephemeral + per-user*

("one user, one time" is exactly the model's irreducible clear-window residue,
`SECURE-DATUM §7` — the ceiling coincides with the goal.)

| Condition | Mechanism | Status |
|---|---|---|
| **attenuated** (minimal grant; shared devices → per-user port-views) | Attenuate | **UNBUILT** (present-but-unapplied) |
| **one-time** (session-ephemeral caps + old-key invalidation + version) | moving-target re-key + register versioning | designed; static passphrase→same-bundle gives "every time" — must be session-scoped |
| **cut-off-able** (revoke a compromised cap) | Revoke | **UNBUILT** (design only) |
| **non-persistent** (a won session can't write the manifest) | manifest-write isolation | **UNSPEC'd** |

Only **Move** (linearity) is enforced today (`permission-model.md`). The ops that
*bound* blast radius — Attenuate, Revoke — are unbuilt, so **T2 is currently
unenforceable.**

## 4. Secure ceremony — how only legitimate change happens

The tension "do whatever (§1) vs. only legitimate changes" resolves on a
**meta/operational split**, self-similar:

- **Compose/genesis time — do whatever.** You author the system *and its own
  change-ceremony rules and posture*. Ports to ports. No paternalism.
- **Once staged — the live system changes only via the ceremony it declared for
  itself.** "Legitimate" is defined by *that system's* manifest, not by chirality from
  above.

### 4.1 Legitimacy conditions

A change (re-dedicate a key, add/remove a user, move posture) is **legitimate iff**
it:
1. **presents the required quorum** — K-of-N ceremony caps (no single actor; quorum
   is also the anti-coercion multiplier — one held party isn't enough);
2. is **measured + signed + monotonically versioned** (register-anchored,
   `SECURE-DATUM §4`) — no replay, no rollback to a weaker manifest;
3. is applied **atomically via re-staging** — reflective-floor succession re-freezes
   the judgment; no weakened intermediate;
4. runs through an **ephemeral ceremony capability that is consumed** — the
   authority to change exists only for the change, then is gone.

### 4.2 Why illegitimate change is structurally impossible (not policed)

A compromised running process lacks the quorum caps, lacks the succession
capability, and cannot sign — so it **cannot produce a valid staged successor.** The
frozen checker rejects an unsigned / un-quorum'd manifest **at the staging
boundary** (`decision-reflective-floor.md` — "no uncertified succession; a
mis-checked child degrades to a B-blob bounded by its ports"). Legitimacy is
enforced *at succession*, not by a runtime cop. The illegitimate path doesn't get
*caught* — it doesn't *exist*.

### 4.3 Users are dedications

A "user" = an unlock-secret → dedicated caps (`RUNG2-MICROVM-MAP.md §5.5`). So
add/change user = **re-dedication ceremony**; remove user = **revoke ceremony**
(needs Revoke — unbuilt). There is no separate user subsystem — user management *is*
capability-dedication ceremony.

### 4.4 The base case (the one irreducible concentration)

The *first* ceremony rules are set at **genesis (P6)**, which has no prior ceremony
to gate it. This is the single concentrated moment. It is protected not by a
ceremony but by **`RUNG2-MICROVM-MAP.md §5.6`'s split out-of-band anchor +
cost-multiplier stack**, and **genesis must self-drop its authority** (mint-then-
drop) or it *is* the permanent root. This is `decision-deployment-custody.md`'s
"bootstrap base case" — where "no un-split concentration" is hardest to honor.

## 5. Config-of-config invariants (posture change is itself a critical capability)

Because posture is configurable, *lowering* it is an attack surface:
1. Posture-change is gated by the **split/quorum'd admin capability** (§3 T1) — or it
   is the new root.
2. **Genesis sets a floor**; operating above it is normal-admin, but **lowering the
   floor is a higher op** — re-genesis / larger quorum. One compromised admin must
   not be able to set everything to "off."
3. Posture-down is a **measured, alarmed event** (an alarm crossing), never silent.

## 6. Consolidated build dependencies (what must exist for any of this to be real)

All greenfield or designed-not-built, ranked by load-bearing:

| Piece | Gates | Home | Status |
|---|---|---|---|
| **Attenuate + Revoke** | T2 containment; per-user device views; user-removal; ephemeral ceremony caps | `permission-model.md`, E40 | **UNBUILT** (only Move) |
| **E45 succession** (freeze `Sig` at staging) | the atomic re-stage that *is* ceremony (§4) | `decision-reflective-floor.md` | designed, **not built** |
| **E52 quorum checker** | T1 checker-split; no single rubber-stamp | `decision-split-checker.md` | designed, **not built** |
| **Split admin/ceremony caps + genesis self-drop** | T1 #1 hole; base case (§4.4) | new | **UNSPEC'd** |
| **Monotonic register-anchored manifest versioning** | anti-rollback in ceremony (§4.1) | `SECURE-DATUM §4` | exists, not wired to manifest |
| **Tier-1 crypto primitives** (hash/sig/KDF; constant-time via E60) | boot-chain + ceremony signing + keys | new | **UNBUILT, critical path** (`RUNG2-MICROVM-MAP.md §5.6`) |
| **Per-datum posture weaving** (compiler emits active layers per manifest) | §2, the whole spectrum | `SECURE-DATUM §6`, `decision-profiles.md` | partial (profiles+verify built; posture-weave greenfield) |

## 7. The through-line

One discipline runs through boot trust (`RUNG2-MICROVM-MAP.md §5.6`),
authority-granting (§3), posture (§2), and change (§4): **no un-split concentration;
every grant attenuated / ephemeral / per-user; every high-privilege act a quorum'd,
measured, staged ceremony — all of it a recomposable default, legible in the wiring,
never paternalistically enforced.** Where the system deviates, the wiring shows it.
Where it isn't yet real, §6 names the unbuilt piece.
