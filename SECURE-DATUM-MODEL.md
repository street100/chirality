# Secure-datum model: CPU + RAM only, against peripheral DMA

Companion to [PRINCIPLES.md](PRINCIPLES.md). This is the threat model and defense architecture
for handling any data securely on a bare machine (no TPM, no IOMMU relied on, no token, no mesh)
against an attacker with **peripheral DMA** (Thunderbolt / PCIe / USB4 / FireWire, PCILeech-class
hardware) who can read, snapshot, write, and watch host RAM while bypassing the CPU.

Draft, 2026-06-14. Plain language. Grow and correct in place.

---

## 1. The guarantee is exponential cost, not prevention

With only CPU and RAM you **cannot prevent** DMA: software isn't on the bus, so a device can read
and write physical memory no matter what the program does. So prevention is off the table as a
*general* promise.

What you *can* promise, on any machine, with no special silicon, is this: **make every attack's cost
scale, and compose the layers so cost scales multiplicatively, i.e. exponentially in the number of
independent obstacles.** Exponential cost-increase is the strongest guarantee that is *general*.
It needs no hardware, so it holds everywhere.

This sets two hard design rules. Every mechanism in this document must satisfy both, or it's theater:

- **Rule A: guaranteed multiplier, no free bypass.** A layer counts only if it provably multiplies
  attacker work and has no cheap way around it. A layer an attacker skips for free adds nothing.
- **Rule B: independence, so they multiply not add.** Layers must be independent: defeating one must
  not help defeat another. N independent multipliers compose to a product (exponential); N layers that
  share a weakness collapse to one. The only dependency any layer may share is the register root (§3),
  and that is unreachable by the threat.

The promise we make is therefore precise and honest: *to win, the attacker must simultaneously defeat
L₁…Lₙ, each of which independently multiplies cost, so cost grows as the product.* Not "impossible."
**Exponentially expensive, guaranteed, generally.**

## 2. Threat model

**In scope (peripheral DMA):**
- A malicious/compromised peripheral or attack device (Thunderbolt, PCIe, USB4, FireWire; PCILeech).
- Capabilities: **read** (one snapshot or continuous), **write** (tamper, replay/rollback), and
  **access-pattern observation** (watching writes over time).

**The enabling fact the whole model rests on:** DMA reads *memory*. **DMA cannot read CPU registers.**
Registers are the one location outside the attacker's reach, so they are the only possible runtime root
of trust (§3).

**Out of scope (needs hardware, honestly):**
- **CPU code execution** (kernel exploit, SMM, microcode, speculation reading registers). Once the
  attacker runs code on the CPU, registers are reachable and this model's root falls. Needs capability
  silicon + a verified privilege boundary.
- **Cold-boot / direct physical dump** caught at the worst instant (the cleartext working window or a
  register spill). Needs memory encryption silicon / a hardware root.
- **The pre-IOMMU boot window** (DMA is wide open before the IOMMU is configured). Needs firmware /
  measured boot.

Realistically those three want **IOMMU + TPM + capability silicon**. This model is what holds *when
that hardware is absent, disabled, or bypassed*. That is common (IOMMU off in firmware, ACS gaps,
the boot window, no TPM). When the hardware *is* present it adds **prevention on top** of this floor;
this floor is the general guarantee underneath it.

## 3. The root: registers, derive-not-store

Registers are tiny (~256 bits of debug registers + the GP/vector file), too small to hold per-datum
secrets. So:

- **One master secret lives only in registers**, established at boot (passphrase → key schedule
  computed in-register, TRESOR-style; never written to RAM).
- **Everything per-datum is derived from it on demand** (keys, MAC keys, nonces, versions), used
  in-register, then discarded. Procedural generation is therefore *structural here, not an
  optimization*: you can't store the secrets, so you regenerate them from the register root.
- RAM holds **only ciphertext + redundancy**. All trust is in registers; all exposure is in RAM.

## 4. The cost-multiplier stack

Each entry is a layer that must satisfy Rule A (guaranteed multiplier) and Rule B (independent).

### Confidentiality: against read
- **Encryption at rest, key in registers** (TRESOR / RamCrypt model). The *kind-change* multiplier:
  turns a read from "copy the bytes" into "break the cipher or get the register key (unreachable via
  DMA)." This is the load-bearing layer; everything else multiplies on top of it.
- **Uniform high-entropy / no localization.** Encrypt everything so entropy/signature scanners can't
  *localize* the secret: the whole space looks the same. Forces the attacker to take *all* of RAM and
  work offline instead of plucking the high-entropy needle. Drowns automated extraction (aeskeyfind etc.).
- **Chaff / decoys.** Plausible fake key-schedules and structures so scanners return endless false
  positives, each of which must be tested. Multiplier ≈ number of decoys × per-candidate test cost.
  Murders automation; a linear cost to a human with an oracle.
- **Bounded working window + atomic, interrupt-disabled critical section.** Cleartext exists only in
  registers / a minimal window, briefly, uninterruptibly. (The interrupt-disable is mandatory: a
  context switch *spills registers to RAM*, leaking the root, so critical sections must be small,
  brief, atomic.) Multiplier: the attacker must snapshot the exact instant and catch the tiny window.
- **Short residency / derive-on-use.** Most data isn't resident; it's regenerated from the register
  root when needed and zeroed after. A random snapshot mostly catches nothing. Multiplier ≈ 1/residency.
- **Moving target / proactive refresh.** Re-derive / re-encrypt / relocate on a timer, so a slow scrape
  races rotation. Multiplier ≈ refresh-rate / scrape-rate.
- **Encrypted split (Shamir).** Secret never assembled; need ≥K fragments *and* the window. NB: a
  multiplier **only** when combined with encryption + refresh + windowing. Raw same-RAM split is not a
  multiplier (all shares present, and they flag themselves by entropy). Reserve real value for shares
  separated in time (refresh) or across domains.
- **Access-pattern hiding (ORAM-class).** For the *watching* attacker (write-pattern leakage). Expensive
  (polylog); reserve for when continuous observation is the threat.

### Integrity + availability: against write / replay
- **Register-anchored verification (MAC or Merkle root).** Every datum verified on use against a key /
  root held *in registers*. A blind write is detected with overwhelming probability, because the
  attacker can't forge without the register master. The *kind-change* for tamper: turns "flip a bit"
  into "break the MAC." (The anchor MUST be in registers. Anchor it in RAM and the attacker rewrites
  data + MAC together: the watcher-in-the-same-memory trap.)
- **Register-anchored versioning.** A monotonic counter in registers defeats replay/rollback of an old,
  validly-MAC'd block. Closes the replay shortcut.
- **Redundancy + self-heal.** Sensitive state held redundantly (robust/verifiable shares or replicas,
  all ciphertext). Detected corruption is repaired from survivors (robust sharing corrects *t* bad
  shares and names them). The attacker must corrupt enough copies *consistently and undetectably within
  one window*. Multiplier ≈ defeating N copies + the verifier at once.
- **Detection → response.** On detected tamper, re-key / re-derive / relocate (moving target, triggered).
  A detected attack becomes a reset that invalidates the attacker's progress, forcing them to win
  *atomically before* detection-and-response completes.

## 5. Why it actually multiplies (the independence discipline)

The exponential is real only if the layers are independent. That's Rule B, and it's the part that's
easy to get wrong:

- **Distinct derivation per layer.** Each layer's key/nonce/anchor is derived from the register master
  under a distinct label, so compromising one layer's material yields nothing about another's.
- **The register root is the only shared dependency**, and it's unreachable by the threat (§2). So the
  one thing all layers share is the one thing the attacker can't get.
- **No free bypass (Rule A) per layer.** Anything an attacker skips for free is deleted from the stack;
  it's a false multiplier and it inflates the security claim dishonestly.

When both hold, attacker cost ≈ ∏(layer multipliers), exponential in the number of independent layers,
which is exactly the general guarantee from §1.

## 6. Mechanization: general and affordable (the chirality part)

- **Type-driven per-datum policy.** Each datum's type declares which layers apply
  (`confidential, register-keyed, integrity=mac|merkle, versioned, clear-window ≤ N, refresh ≤ T,
  split=k/n, constant-time`). The compiler weaves the derive-in-register / decrypt-into-window /
  verify-against-root / version-bump / re-encrypt / relocate. This is what makes it **general**: any
  program, any datum. The **uniformity is itself a multiplier**: if everything is treated, nothing
  stands out (Principle 5 applied to forensics).
- **Precompute + procedural generation** make the layers affordable *and are required*: you derive
  per-datum keys/nonces/versions from the register master because you can't store them; you precompute
  schedules and specialize constant-time kernels. **Linear/graded types** track consumable precompute
  (use-once material) and bound the exposure window (`clear-window ≤ N`), so the multipliers can't be
  silently weakened.

## 7. Honest limits (carried, not hidden)

- **The working window is irreducible.** Data must be cleartext to be computed on; a snapshot of that
  exact instant in that window wins for that datum. Everything here *minimizes and multiplies the timing
  precision required*. It does not erase the window.
- **Register spill is the one root-leak.** An interrupt/context switch saves registers to RAM. Critical
  sections must be atomic and preemption-disabled, or the root leaks. (You control the OS; design for it.)
- **This is cost-scaling, not impossibility.** The guarantee is *exponential cost*, stated as such. A
  fast enough attacker who beats the refresh and catches the window still wins a single datum.
- **CPU code execution, cold-boot/direct dump, and the pre-IOMMU window are out of scope**. They
  graduate from cost-scaling to prevention and need IOMMU / TPM / capability silicon. This model is the
  floor beneath that hardware, holding when it's absent, off, or bypassed.
