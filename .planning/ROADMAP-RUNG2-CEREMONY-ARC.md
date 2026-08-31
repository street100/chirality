# Rung-2 ceremony & auth fabric — sequencing roadmap

> **This roadmap locks the sequence and the corner that gates it.** It does not
> re-open the design (see `RUNG2-SECURITY-MODEL.md`, `RUNG2-MICROVM-MAP.md` for
> the seated architecture); it *orders* the work and names the one decision that
> must come before fabric authorship. Working draft from 2026-08-13 refinement.

## The arc — why it sequences this way

The chirality OS (rung 2) is a self-governing mesh: **programs access hardware
through typed ports; the ceremony governs which ports a session holds; the
manifest declares the ceremony's own rules; the compiler, scriba, and the
fabric are components in the mesh, themselves governed by the same caps.**
This is "supports its own development" — but it requires a deliberate
sequencing.

**The governing constraints:**

1. **Ceremony requires crypto.** Every "level of security" is a cryptographic
   check — boot-chain integrity, manifest signing, key derivation, identity
   proof, successor validation. Without crypto, splitting and cascading are
   toothless; with it, each becomes a real multiplier. (`RUNG2-MICROVM-MAP.md
   §5.6`.)

2. **The regress breaks via commitment.** The fabric must authenticate against
   the *prior committed state* (node N), not against itself (node N+1 in
   construction). This is "git-for-authority": you author the next commit
   against HEAD. So the fabric *requires* committed prior version, and the
   ceremony *is* the N→N+1 transaction — never subject to itself mid-change.
   Genesis is the one out-of-band moment (node 0, bound to a physical factor),
   everything descends from it.

3. **Each node is an authority-state.** The tree is not decoration — each
   compiled image + its manifest + the staged identity *is* an authority
   snapshot. Swap-to-any-point is instant (pre-compiled); rollback
   re-establishes a prior authority-state; succession is linear (one capability
   to emit node N+1).

4. **Scriba is the composable cockpit** — it views any port (source, running
   components, fabric, tree) and can edit+recompile, all gated by its identity
   + factor + what the session's manifested caps permit. This is the honest
   super-focal-point that isn't a manager.

## The sequence — TUI → crypto → fabric → OS → scriba

```
1. TUI + primitives   (current — the display, the chirality-boot surface)
     ↓
2. Tier-1 crypto     (CRY, E114+ — hash / sig / KDF, constant-time)
     ↓
3. Auth fabric + ceremony + genesis   (built on crypto; designed in advance)
     ↓
4. chirality OS boot   (hardware + TUI terminal + fabric = a real secure system)
     ↓
5. scriba-as-cockpit exposed to fabric
```

**Why this order:**

- **TUI first** — it's the display surface the OS boots into; no dependency on
  crypto or fabric. Gets to "chirality alive with keyboard input."

- **Crypto second** — it's not a module on the fabric; it's the prerequisite
  for the fabric's integrity claims. Boot-chain hashes, manifest signatures,
  register-derived keys, K-of-N verification all need it. It's load-bearing
  from genesis onward.

- **Fabric + ceremony + genesis together** — they're a tight triangle: the
  fabric's structure enables the ceremony (ports + Move + reflective floor);
  the ceremony's rules are the manifest; genesis *is* the first ceremony
  (staged, factored, self-dropping). They're designed in advance (seated); they
  wait on crypto to be real.

- **OS boot completes the substrate** — keyboard + monitor + basic hardware +
  TUI terminal + fabric minted caps + login = a real secured chirality system.

- **Scriba last** — once the fabric is real, scriba can view + edit + authorize
  through it. It's the graduating cockpit, not the starter.

## The unresolved corner — root=key vs root=quorum

**This is the load-bearing decision for genesis and recovery:**

- **root=key:** The install authority is a single physical key (USB, card,
  biometric factor). Genesis is one key, one key forever. **Upside:** simplest
  entry. **Downside:** single point of failure (lose it, tree freezes; steal
  it, whole descent is forged); no recovery path.

- **root=quorum:** Genesis itself is a split-role threshold from the start
  (k-of-n parties/factors, not one key). Recovery and succession are ordinary
  strongest-tier ceremonies, not an unrecoverable cliff. **Upside:** recovery
  is built-in; succession doesn't require re-rooting; adversary needs ≥K
  factors simultaneously. **Downside:** more ceremony at install, operational
  complexity.

**Why it's load-bearing:**

- You *cannot retrofit* it. A key-rooted tree cannot become a quorum-rooted tree
  without re-genesis; a quorum-rooted tree can be tightened to a single key
  later (tighter is a governance re-rule, not a structural change).

- It shapes the manifest schema (who can propose / who can veto / what
  thresholds). It shapes login (if quorum, do you unlock K-of-N together or
  singly to delegate?). It shapes the "factor" model (`SECURE-DATUM-MODEL.md
  §3`).

- Single-key-rooted genesis is simpler for personal / development machines
  ("I am the only root, lose my key and I accept the cost"). Quorum makes
  sense for shared/enterprise systems ("no single person is root").

**The decision needed before fabric authorship:**

Which model fits the chirality vision? Personal? Organization? Both, with profiles?

Once this is decided, the **full vision doc** (elaborated from the triangle
above, with crypto roles + ceremony structure + manifest schema + login model +
recovery procedures) can be authored with confidence.

## Dependencies, in order

| Gate | Needed for | Status |
|---|---|---|
| **root=key-vs-quorum decision** | manifest schema + genesis ceremony shape + boot-chain anchor strategy | **UNRESOLVED** (the ask) |
| **Tier-1 crypto** (hash/sig/KDF) | boot-chain measured integrity; manifest signing; key derivation; successor validation | greenfield, critical path |
| **E42 supervisor** | register custody for login; critical sections for atomic ceremony; alarm crossings for async | partial (not yet fully wired to fabric) |
| **E80 cap grant to main** | P3 mints root ports and hands them to `main`; the starter cap-release | designed, not built |
| **E45 succession** (freeze `Sig` at staging) | atomic N→N+1 transaction; linear ceremony capability; reflective-floor re-freeze | designed, not built |
| **E52 quorum checker** | T1 audit thesis ("no un-split concentration") requires checker-split below quorum | designed, not built |
| **Attenuate + Revoke** (E40 extensions) | T2 audit thesis ("one user, one time"); per-user device views; ephemeral ceremony caps; revoke | Move implemented; Attenuate/Revoke greenfield |
| **Security manifest schema + validation** | P6/P7 (genesis + manifest engine); the stable config that gates recompilation | designed, not built |
| **Measured-boot chain + register anchoring** | boot-chain integrity; manifest versioning; moving-target re-key; chain-of-trust | framework in `SECURE-DATUM §4`; boot wiring greenfield |

## Full vision doc — after the corner decision

Once root=key-vs-quorum is settled, the **complete vision** will be authored,
covering:

- The full regress-breaking ceremony model (transaction-against-committed-root,
  node-as-authority-state, governance strata).
- Manifest schema and the ceremonies it declares (genesis, add-user,
  posture-change, revoke, manifest-edit, re-root).
- Login model (register-root unlock + dedicated-cap release; quorum login if
  root=quorum).
- Boot-chain integrity strategy (split anchor channels, multi-stage crypto
  verification, moving-target re-key, robust-shares manifest).
- Recovery procedures (key loss, quorum recovery, tree rollback, successor
  repair).
- Scriba as the cockpit (what ports it sees; how to authorize edits; the grant
  graph it manipulates).

## Frames and citations

- `RUNG2-SECURITY-MODEL.md` — the seated authority/security architecture:
  composability invariant, posture spectrum, T1/T2 audit theses, secure
  ceremony shape (§4), config-of-config (§5).
- `RUNG2-MICROVM-MAP.md` — the concrete libkrun realization: boot stages
  (P1–P7), drivers (D0–D5), first-time setup + manifest (§5.5), boot-chain
  integrity (§5.6).
- `SECURE-DATUM-MODEL.md` — the threat model and per-datum security
  disciplines: register-root, split/refresh, moving-target, clear-window,
  chaff, robust-shares.
- `decision-deployment-custody.md` — the "acquire→stage→certify" pattern; the
  bootstrap base case; the distinction between install-time (genesis) and
  runtime (reconfiguration).
- `decision-reflective-floor.md` — frozen judgment at staging; linear succession
  capability; mis-checked child degrades to B-blob.
- `decision-effect-facets.md` — the effect membrane; alarms as crossings; the
  critical-section/interrupt-disabled model.
