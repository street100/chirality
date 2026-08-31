# Rung-2 on libkrun — the microVM realization: drivers & programs to write

> **Status: seated, not scheduled.** This is **rung 2** — "chirality-as-OS on metal"
> (`.planning/RUNG-2-MAP.md`, `SELF-HOST-PLAN.md:18`) — realized on a **libkrun
> empty machine**. Everything here is NOTE / greenfield unless it links to a built
> element. It does **not** reopen rung-2's design; it instantiates it on one
> hypervisor and enumerates the concrete **drivers** and **programs** to write, so
> the work is documented before it's scheduled.
>
> The whole "Linux vanishes" surface is **one file**: a new
> `target-chiralityvm.chiral` replaces `target-linux.chiral` (`target-linux.chiral:1-8`
> — "a rung-2 backend replaces THIS FILE alone"). The trusted `SysReg`/`ck-sys`
> mechanism holds zero Linux numbers and does not change.

---

## 0. What this is / isn't

- **Is:** the concrete libkrun landing of `RUNG-2-MAP.md`'s abstract clusters.
  Read `RUNG-2-MAP.md` (the inventory) and `target-linux.chiral` (the seam) first.
- **Two VM modes, both bare-metal chirality — no Linux guest in either:**
  - **Mode-Full** — chirality.elf does the whole sequence: boot → memory → caps →
    register-root login → resident session.
  - **Mode-Fast** — boot the kernel once (stable), then **hot-load the upper
    layers from shared storage** and compile+run them in-guest (reuses
    `compile-all` / self-wield). The kernel rarely rebuilds; post-boot/login
    logic iterates at file-drop speed.
- **Linux appears only as** (a) the host running libkrun, and (b) the
  **differential verification oracle** — the existing `target-linux` backend with
  its E99/E103 ioctl surface (§9). It is not a guest kernel anywhere.

## 1. Verified substrate facts (libkrun / boot / virtio)

Pinned from source — not assumed. Build-time re-verification flagged in §11.

- **libkrun boots an external ELF kernel** via `krun_set_kernel(ctx,
  path, KRUN_KERNEL_FORMAT_ELF, initramfs, cmdline)`. Formats include `RAW=0`,
  `ELF=1`, plus compressed Linux Images; no Linux-only restriction in the API.
  (`libkrun/include/libkrun.h`.)
- **libkrun's VMM is an AWS-Firecracker derivative** using rust-vmm
  `linux-loader`, which loads a 64-bit `vmlinux`-shaped ELF (LOAD segments placed
  per program headers) via the **Linux 64-bit boot protocol** or **PVH**.
- **Entry state (Linux-64 path):** CPU already in **64-bit long mode**, a
  **minimal identity-mapped page table** present, **`RSI` = `&boot_params`** (the
  x86 zero page: e820 memory map + cmdline pointer), jump to the ELF entry. chirality
  does **not** cold-boot from real mode — it inherits long mode + low-RAM identity
  map and just sets its stack and reads `boot_params`.
- **Device discovery (x86):** no device tree — virtio-MMIO devices are announced
  on the kernel **cmdline** as `virtio_mmio.device=<size>@<base>:<irq>`
  (Firecracker convention; confirm for libkrun x86 — §11).
- **Devices are all virtio over MMIO transport** (not PCI): console, block, fs,
  gpu, net, vsock, balloon, rng — via libkrun's `MMIODeviceManager`.
- **Security caveat:** virtio-fs shares a host directory with **no isolation from
  other directories on that host filesystem**. Prefer virtio-blk + a dedicated
  image for the storage bridge (§5 D2).

Sources: `libkrun/include/libkrun.h`, `libkrun/README.md`, `rust-vmm/linux-loader`,
DeepWiki `containers/libkrun`, Firecracker boot notes (OSv-on-Firecracker).

## 2. The refraction — do NOT build a classical kernel

`RUNG-2-MAP.md:28-51` dissolves the kernel; honor it or you'll build the wrong
thing:

| Classical kernel piece | chirality refraction | Consequence for this work |
|---|---|---|
| memory manager | conservation by **linearity** (E8) + the Alloc seam (E81) | P2 owns RAM as an allocator seam, not a subsystem |
| central device owner | **device = a typed port over the B substrate** | every driver is a **wrapped-B bridge** exposing a port |
| filesystem | **port-views over blocks** | storage = virtio-blk + block-view ports, not a VFS |
| interrupt table | **a hardware event is an alarm crossing** | defer with polling; later route IRQ→alarm (E42) |

`docs/modules-substrate.md`: device + DMA is "the core threat"; **"an unwrapped
driver is not expressible."** So each driver below is quarantined-B wrapped into a
typed port — never a raw ambient driver.

## 2.5 The positive shape — what actually replaces the kernel

There is **no kernel object**. What programs run on is **one driver + a small
substrate set**, and using hardware is just **holding and calling a typed chirality
port** — the "nice API" that is *not* an API, because there is no foreign
boundary: the type *is* the interface, and the capability-check and the type-check
are the **same act** (`insp-capability-os.md:21-29`). Three strata, but continuous
chirality — the same kind of thing all the way down (nodes + ports,
`node-architecture.md`):

1. **The driver** — the one part that touches raw, untyped hardware (virtio-MMIO /
   device memory = the B substrate) and wraps it into typed ports. **virtio's own
   design is exactly this shape: one transport driver (MMIO + virtqueue) and many
   device types over it** — which is why "a driver and a set of things" is
   literally how the substrate wants to be built. (§5: **D0 = the driver**; D1–D5
   = device types over it.)
2. **The substrate set** — the handful of modules that turn "a booted machine
   exposing device ports" into "the floor a program stands on": claim RAM, mint the
   root capabilities, hold the register-root discipline, run the boot entry. **Not
   a privileged monolith** — composable modules, most of them refractions of things
   chirality already has (the Alloc seam, ports, the effect membrane). (§4: P1–P4.)
3. **Residents** — ordinary chirality programs on the floor (scriba, anything
   hot-loaded). No different in kind from the substrate. Holding granted ports is
   their runtime *mechanism* — but **the grant graph, the login surfaces, and the
   key/unlock policy are not ambient or hard-coded; they are governed by a
   persistent, install-authored `manifest`** (§5.5). "Just holding ports" is never
   the whole story; the manifest is where the ports *come from*. (§4: P5 / P0.)

The only real seam in the whole stack is **B → typed**: the driver is where
untyped device bytes become typed ports. Above that line it is one chirality mesh —
"using hardware" is indistinguishable from calling any other typed port, and there
is **no kernel/userspace privilege split as a *language* boundary**. The substrate
is simply whoever holds the device ports first and hands them out.

## 3. The seam — one backend file + one crossing-body file, one profile

- **`target-chiralityvm.chiral`** replaces `target-linux.chiral` (the `SysReg`
  instance). At rung 2 there are **no syscall numbers** — "chirality is the kernel and
  simply does not implement the unpermitted calls"
  (`decision-syscall-governance.md:47`). Crossings resolve to **MMIO / virtqueue
  ops**, not `ti-sys <nr>`.
- **`device-tal.chiral`** — the rung-2 analog of `sys-tal.chiral`: the TAL-floor
  crossing bodies, now virtio-MMIO instead of `syscall`. Same crossing *shape* as
  E29–E33/E51 (`RUNG-2-MAP.md:100-101`).
- **Composition vehicle:** a **`chirality-bare` profile** (`decision-profiles.md`;
  `RUNG-2-MAP.md:107`) — "the minimal module set that is a verified substrate."
  The **port set is profile-invariant**, so the bare profile swaps modules
  (backend + device drivers) without changing the port alphabet.

## 4. The substrate set + residents (programs to write)

*(§2.5 strata: P1–P4 = the substrate set — the floor programs stand on; P5/P0 =
residents. None is a "kernel"; they are composable modules that happen to hold the
device ports first.)*

| P | Program | Does | Home | Status |
|---|---|---|---|---|
| **P1** | **Boot trampoline / entry stub** | inherit long mode; set RSP; parse `boot_params` (e820 → RAM extent, cmdline ptr); parse `virtio_mmio.device=` → device bases | **E34** residue ("entry stub = the one artifact to swap", `RUNG-2-MAP.md:50,120-123`); `docs/bootstrap-sequence.md` | greenfield |
| **P2** | **Physical-memory owner** | own e820 RAM; bump/region allocator over the identity map; later own page tables + W^X | **E81** Alloc seam; E21/E22/E28 shapes with the MMU as referent (`RUNG-2-MAP.md:44,143`) | E81 example audited; rest greenfield |
| **P3** | **Capability root ("init")** | mint the root ports from the bare devices (console/storage/…) and **hand them to `main`** — this *is* chirality "init": cap-grant, not a process launcher | **E80** (ambient-cap reification to `main`); `node-architecture.md` (authority = ports held) | E80 not built |
| **P4** | **Login (terminal + graphical)** | per the manifest: unlock keys by their declared unlock types (register-root/TRESOR as the core — passphrase → in-register schedule, never in RAM) and **release the session's dedicated capability bundle**; terminal login over D1, graphical over D4; register step in an interrupt-disabled critical section | **§5.5**; **`SECURE-DATUM-MODEL.md §3-6`**; `bootstrap-sequence.md:22-33`; **E42** | greenfield |
| **P5** | **Resident session (scriba)** | the first resident app / port-viewer over the ports login released; E103 raw-mode **inverts** — chirality owns the line discipline, no `tcsetattr` | `docs/live-environment.md`; the ~22 built `scaffold/lib/scriba/` modules; **E103** reframed | scriba partial; reframe greenfield |
| **P0** | *(Mode-Fast only)* **in-guest loader** | read `.chiral` from the storage port, `compile-all` → run, in-guest | reuses built `compile-all` / self-wield | reuses built |
| **P6** | **First-time setup (install genesis)** | interactive, run once at install: **author the manifest** — master key(s) + unlock types, login surfaces, initial capability grant graph, dedications; the genesis that makes the system securely configurable going forward | **§5.5**; `decision-deployment-custody.md` (stage + certify) | greenfield |
| **P7** | **Manifest engine** | read/validate the persistent, integrity-MAC'd manifest from storage; drive P3's grant graph + P4's login; gate reconfiguration behind the admin capability | **§5.5**; **E80**, **E40**, `permission-model.md`, `decision-reflective-floor.md` | greenfield |

**Note on "login":** there is **no user/account/multi-user subject** in chirality — by
design, authority is "which ports you hold," not "who you are"
(`node-architecture.md:41-42`). "Login" here is **exactly two things**: (P4) the
register-root establishment, and (P3) the capability grant to the first resident.
Nothing else.

## 5. The driver — one virtio-MMIO transport, many device types over it

*(§2.5: **D0 is "the driver"** — the single B→typed wrapper; **D1–D5 are device
types** configured over it, not separate drivers. Each exposes a typed port.)*

| D | Driver | Role | Home | Priority |
|---|---|---|---|---|
| **D0** | **virtio-MMIO transport core** (shared) | MMIO register handshake (MagicValue/Version/DeviceID; feature negotiation; Status `ACKNOWLEDGE→DRIVER→FEATURES_OK→DRIVER_OK`); **split-virtqueue** (descriptor table + avail + used rings in owned RAM); submit + `QueueNotify`; **poll the used ring** (defer interrupts) | `axis-typeability` (B/C bridge); `modules-substrate` (raw-mem+device); **E75** (typed ABI-layout for the virtqueue structs) | **first** — everything rides it |
| **D1** | **virtio-console** | text I/O = chirality stdout/stdin; **first light** | device-bridge (input/display class, `RUNG-2-MAP.md:47`); reuses **E98** read-key / **E105** write-fd *shapes* over a queue, not a syscall | **first light** |
| **D2** | **virtio-blk** *(recommended)* or virtio-fs | the shared-storage bridge + the Mode-Fast hot-load channel; blk fits the **"port-views over blocks"** refraction and is simpler; fs is FUSE-over-virtio + the no-isolation caveat (§1) | storage device-bridge; E21/E22 shapes | **second** |
| **D3** | **virtio-vsock** | host-mediated sockets — control channel / the oracle bridge | **E29** sockets shape | later |
| **D4** | **virtio-gpu** | display / the GPU corner | **E35/E36** (Wayland/niri protocol tier, partly built) + display bridge | far |
| **D5** | virtio-net / rng / balloon | as needed | crossing shapes | deferred |

**Interrupts:** deferred by **polling** the used ring (skips IDT/APIC entirely for
first light). When you want async/efficiency, a **used-buffer notification becomes
an alarm crossing** (`decision-effect-facets.md` — alarms are crossings;
`RUNG-2-MAP.md` interrupt→alarm), owned by the **E42** supervisor. That's the
threshold where E42's IDT/APIC + critical-section machinery is needed.

## 5.5 The security manifest, first-time setup, and login

> **The authority/security/ceremony architecture that governs this section — the
> composability invariant, the configurable posture spectrum, the T1/T2 audit
> invariants, and the secure-change ceremony — lives in its own planning doc:
> `.planning/RUNG2-SECURITY-MODEL.md`.** This section is the concrete
> manifest/login surface; that doc is the model behind it.

Holding granted ports is the runtime *mechanism* — but **the grant graph, the
login surfaces, and the key/unlock policy are governed by a persistent,
install-authored `manifest`.** This is the layer that makes the system securely
*configurable going forward*; it is first-class substrate, not an afterthought.

**The manifest declares:**
- **Capabilities** — the capability ports that exist and the **initial grant
  graph** (which caps each resident/role receives). This is the *data* behind E80's
  "hand caps to `main`."
- **Login securities** — both a **terminal login** (over the console port, D1) and
  a **graphical login** (over the display port, D4 / E35-36), each with its
  security requirements.
- **Keys + unlock types** — every key and *how it unlocks*: passphrase →
  register-root (TRESOR, `SECURE-DATUM-MODEL.md §3`), keyfile, hardware token, TPM,
  biometric, multi-factor. Unlock policy is per key.
- **Dedications** — **which keys are assigned to what.** For each key: the
  capabilities / data / resources it unlocks or governs. So P4 login unlocks a key
  and receives exactly what that key is assigned to — nothing else.
- **Per-datum security classes** — the type-driven policy of `SECURE-DATUM-MODEL.md
  §6` (confidential / register-keyed / integrity / versioned / clear-window /
  refresh / split) is *configured* here at install.

**First-time setup (P6, install genesis):** an interactive setup, run once when the
system is installed, **authors the manifest** — sets the master key(s) + unlock
types, defines the login surfaces, the initial capability grant graph, and the
dedications. This genesis is what gives the system "the ability to be secure and
configurable going forward." It **is** the staging/certification step of
`decision-deployment-custody.md` ("acquire a moduleset, stage it, certify at
staging"; "personal-host = a self-similar staged instance") — the manifest is the
staged instance's configured identity.

**Login (P4, each session):** gates entry per the manifest — presents the unlock
secret(s) for the chosen surface (terminal or graphical), unlocks the keys by their
declared unlock types (register-root first), and **releases the dedicated
capability bundle** for that session.

**Why this stays ocap-consistent (reconciling `node-architecture.md`'s "no login
subject"):** login does **not** reintroduce identity-as-ambient-authority. It is
the **unlock layer** — *present the dedicated secret → release the dedicated caps*.
The "user" is exactly "the holder of an unlock secret"; the manifest binds
unlock-secrets → dedicated capability bundles. Authority is still **only the ports
you hold** — the manifest + login are how you come to hold the *right* ones,
securely and configurably, instead of by ambient hard-coding. **Reconfiguring the
manifest is itself a capability-gated operation** (needs the admin capability P6
minted), and edits fall under the reflective-floor succession discipline
(`decision-reflective-floor.md`).

**Where it lands:** manifest storage → the storage port (D2), integrity-MAC'd,
register-anchored (`SECURE-DATUM-MODEL.md §4`). Grant graph → E80 + E40 +
`permission-model.md` (Move/Attenuate/Delegate/Revoke). Keys + register-root →
`SECURE-DATUM-MODEL.md §3-6` + E42. Graphical login → D4 (virtio-gpu) + E35/E36.
Terminal login → D1 (virtio-console) + scriba/key-parser. **The manifest schema,
the install genesis, and the config-edit capability are greenfield — no element.**

## 5.6 Boot-chain integrity — the one place crypto is a prerequisite, not a module

The goal: **download → install → running system, never tampered — on CPU+RAM
only** (no TPM, no secure-boot silicon). This is the concern that makes crypto
non-optional. Runtime *confinement* needs no crypto (§6 — it's ports + types); but
**integrity of bits that crossed an untrusted channel cannot be established without
crypto.** No information-theoretic path exists; visual confirmation is the only
alternative and it neither scales nor completes (a human can't eyeball a whole
system, and a network/updates keep moving the surface).

**Reject the single root — apply the cost-multiplier stack to trust-establishment
itself.** The classical "one root you must trust a priori" *is* the single point of
trust the model forbids (`SECURE-DATUM-MODEL.md §1`, Rules A+B). There is no single
anchor. Boot-chain integrity is itself a stack of **independent, multiplying
obstacles** an attacker must defeat *simultaneously* to tamper undetected — and
**crypto is the primitive that turns each obstacle into a guaranteed multiplier**
(a hash that binds bits, a signature that can't be forged, a Shamir split that
needs K shares, a register-anchored MAC). Without crypto, splitting / cascading /
zero-trust are toothless; with it, each becomes a real independent multiplier. That
is why crypto is load-bearing here — **not** because it yields one verifiable
anchor, but because it makes the whole distributed cost-stack meaningful.

**The layers (each crypto-enabled, independent, multiplicative):**
- **Split anchor — no single fingerprint.** The verification anchor is
  **Shamir-split across independent channels** (printed card + second device +
  network + a party); forging it needs ≥K channels compromised *at once*. Splitting
  applied to the anchor is what dissolves the single point.
- **Reproducible-build consensus — split the trust origin.** The byte-identical
  self-compile **fixpoint** means N independent rebuilders derive the *same* hash; a
  tamper must forge agreement across independent verifiers, not fool one source.
  (chirality gets this free from determinism.)
- **Cross-checked runtimes / split-checker quorum** (**E62**, "many truths
  reconciled" P5): independent checkers must **agree**; defeat the quorum, not one.
- **Per-stage independent keys** (Rule B): each measured-boot stage verified under a
  **distinct register-derived key** — breaking one yields nothing about another, so
  cost is the *product* across stages. (P1 hashes the substrate; the substrate
  hashes residents; against the signed manifest §5.5.)
- **Register-anchored MAC** (`SECURE-DATUM-MODEL.md §4`): verification anchors are
  register-derived, unreachable by DMA — can't rewrite data + MAC together.
- **Moving-target re-measurement** (§4): continuous re-measure + re-key at *every*
  boot; a static tamper is caught next round; the attacker must win in the window
  **and keep winning** as it rotates. Mismatch → refuse / re-key / **alarm crossing**.
- **Robust-shared manifest + self-heal** (§4): the manifest held as robust shares;
  detected corruption repaired from survivors; must corrupt enough shares
  consistently within one window.
- **Chaff / decoys** (§4): fake boot structures drown automated tampering.

**The guarantee (the model's standard one, now applied to boot):** not "trusted
root," but *to tamper undetected the attacker must simultaneously defeat L₁…Lₙ,
each independently multiplying cost → **exponential***. Human/visual confirmation is
**not** the single fallback anchor — it is **one split channel** among several, made
meaningful by the crypto that binds it.

**Two crypto tiers (this revises "crypto is deferrable"):**
- **Tier 1 — critical path, needed from install onward:** **hash** (SHA-256 /
  BLAKE3), **signature** (Ed25519), **KDF** (Argon2 / scrypt). Powers the
  boot-chain measured integrity + the signed manifest + keys/login. Bounded, but
  **not deferrable** — the integrity thesis rests on it.
- **Tier 2 — graduation, deferrable to real metal:** the full register-rooted
  per-datum encrypt / MAC / version / constant-time (**E60**) / taint (**E59**) /
  moving-target stack vs peripheral DMA (`SECURE-DATUM-MODEL.md §4-6`).

**Honest residual limits (CPU+RAM only) — the model's universal residue, not a
single point of trust:**
- The residue is **cost-scaling, not impossibility** — a fast enough attacker who
  defeats *every* layer within one window wins a single boot; but that cost is the
  **product** of all layers (`SECURE-DATUM-MODEL.md §1, §7`).
- **Pre-boot RAM vs DMA** is wide open (`§2`, needs hardware for prevention) — this
  floor is the general guarantee *underneath* IOMMU/TPM, holding when they're
  absent/off/bypassed.
- **Independence is the load-bearing discipline (Rule B):** the split anchor's
  channels multiply only if genuinely independent — collapse them (all delivered
  over the one compromised network) and the multiplier collapses to one. Faking
  independence is the cardinal error, not a single hardware root.

**Homes:** `SECURE-DATUM-MODEL.md §2`; `bootstrap-sequence.md`;
`certificate-discipline.md` / split-checker (**E52** — signed-verification is the
same crypto family); `decision-deployment-custody.md` ("certify at staging" = the
anchor check); **E62** bootstrap-floor; the manifest (§5.5). **Tier-1
crypto-primitives = greenfield element, on the critical path.**

## 6. Security woven through (not bolted on)

- **Register-root at boot (P4), TRESOR-style, never in RAM** — the anchor of the
  whole secure-datum stack (`SECURE-DATUM-MODEL.md §3-6`).
- **Interrupt-disabled, atomic critical sections (E42)** — a context switch spills
  registers to RAM = root leak (`SECURE-DATUM-MODEL.md §7`). This constrains P4
  and any future scheduler.
- **Every driver is a typed port over quarantined B** — "an unwrapped driver is
  not expressible" (`modules-substrate.md`). D0–D5 mint ports; nothing has ambient
  device reach.
- **No ambient authority** — the boot layer (P3/E80) mints caps and hands them to
  `main`; the current ambient externs (`print`/`put`/`trace`) are the violations
  to reify (`decision-effect-facets.md:43-49`).
- **Reflective floor** — the running system's judgment (`Sig`) is **frozen at
  staging**, succession is a **linear capability**, a mis-checked child degrades to
  a B-blob bounded by its ports (`decision-reflective-floor.md`).
- **Host-trust scoping (honest):** in a microVM the **host/hypervisor can read
  guest RAM by construction** — so `SECURE-DATUM-MODEL`'s peripheral-DMA floor is
  the guarantee for **real bare metal**, and is mostly *latent* on a trusted-host
  microVM. The microVM is the fast dev/verification vehicle; the secure-datum
  multipliers earn their keep when you graduate to physical hardware. Say this;
  don't overclaim DMA resistance inside a hypervisor you trust.

## 7. The two modes, concretely

- **Mode-Full:** `chirality.elf` = P1 → P2 → P3 → P4 → P5, entirely in chirality. "Just a
  machine with hardware; make it start and do all boot + login properly."
- **Mode-Fast:** boot `chirality.elf` to a stable P1–P4, then **hot-load P5-and-above
  `.chiral` programs from D2 storage** via P0 (in-guest `compile-all`). Same kernel
  as Mode-Full; the upper layer arrives as data. This is the fast loop for
  iterating on post-boot / login / session behavior.

## 8. The host harness (throwaway — the only Linux code)

`bash → ~30-line C krun launcher → chirality.elf + shared storage`:
`krun_create_ctx` → `krun_set_kernel(chirality.elf, ELF)` → attach virtio-blk image /
virtiofs dir → `krun_start_enter` → teardown. Two flags: `--full` / `--fast`.
Bash owns build (`B1` compiles `chirality.elf`), console tee, and cleanup.

## 9. The verification oracle (the ioctl 2nd layer)

The existing **`target-linux` backend** (with the E99 ioctl surface, E103 termios)
runs the **same high-level chirality programs** on the host as ordinary Linux
userspace. Because both backends sit under the **same target-agnostic pure core**
(compiler, self-host, scriba edit/render/key-parser), the differential is
**structural**: `target-chiralityvm` must produce the same observable behavior as
`target-linux` for the same program. The ioctl path — the *harder-to-write* one,
already paid for — is the executable spec the bare-metal lane is checked against,
the same way native/rocq cross-check the compiler today.

## 10. Build order (dependency) + first light

1. **D0** (transport core) + **P1** (entry) + **P2** (memory) + **D1** (console)
   → **first light: "chirality alive" on virtio-console.**
2. **D2** (blk) + **P3** (caps) + **P0** (in-guest loader) → **Mode-Fast online.**
3. **E42** (supervisor: critical sections, register custody, later IRQ→alarm) —
   the spine P4 needs.
4. **P4** (register-root login) → **P5** (scriba resident) → Mode-Full complete.

## 11. Must-verify-at-build (do not assume)

1. Exact libkrun external-ELF entry for `krun_set_kernel(…ELF)` — Linux-64 vs PVH,
   and that **`RSI = &boot_params`** holds (vs PVH's `%ebx → hvm_start_info`).
2. libkrun x86 device discovery — confirm `virtio_mmio.device=` on cmdline (vs any
   other mechanism); ARM/riscv use FDT, x86 uses cmdline.
3. **Which virtio devices a minimal `krun_set_kernel` machine actually
   instantiates** — is virtio-console guaranteed? blk? fs? (libkrunfw normally
   wires these; a bare external kernel may get a different/leaner set.)
4. virtio-MMIO **exact register offsets + version** (legacy vs modern/1.2) and the
   **split-vs-packed** virtqueue from the OASIS virtio 1.2 spec §4.2.
5. Whether `krun_set_kernel` yields a **truly device-minimal** machine or still
   hardwires libkrunfw assumptions.

## 12. Status & element gaps

All of the above is **NOTE / greenfield / seated-not-scheduled** — rung-2's
"largest un-cataloged mass" (`RUNG-2-MAP.md:35`). New element homes that do **not
exist yet** and would need to be created for this arc:

- **D0 virtio-MMIO transport core** — no element; the shared driver substrate.
- **Per-class device bridges** (console/blk/vsock/gpu) — no elements
  (`RUNG-2-MAP.md:47,134-151`; protocol tier only partly built via E35/E36).
- **Boot-on-metal / entry stub** — `docs/bootstrap-sequence.md`, no element (rides
  E34 residue).
- **Memory-at-metal** — reuses E21/E22/E28 shapes, no element.
- **target-chiralityvm.chiral + device-tal.chiral** — the new backend instance + crossing
  bodies.
- **The security manifest** — schema + integrity-MAC'd persistence + validation
  (§5.5); no element.
- **First-time setup / install genesis (P6)** + the **config-edit capability** —
  the interactive manifest authoring that makes the system securely configurable;
  no element. The single most-greenfield piece — nothing in the repo authors
  install-time security config today.
- **Graphical + terminal login (P4)** + **manifest engine (P7)** — no element.
- **Tier-1 crypto-primitives** (hash + signature + KDF) — no element, **on the
  critical path** for the boot-chain integrity guarantee (§5.6). Constant-time via
  E60; the primitives themselves are greenfield.
- **Measured-boot chain + signed manifest + anchor pinning** (§5.6) — no element.
- **The capability/security/ceremony invariants** — see
  `.planning/RUNG2-SECURITY-MODEL.md §6` for the full dependency list (Attenuate +
  Revoke, E45 succession, E52 quorum checker, split admin caps + genesis self-drop,
  monotonic manifest versioning, per-datum posture weaving). These gate T1
  ("no full control") and T2 ("one user, one time") and are all unbuilt.

Existing homes to extend, not reinvent: **E42** (supervisor), **E80** (cap
grant to main), **E34** (boot image), **E81** (Alloc seam), **E103/E105/E98**
(terminal/IO shapes), the **`chirality-bare` profile** (composition), and
**`SECURE-DATUM-MODEL.md` + `decision-reflective-floor.md`** (the security spine).
