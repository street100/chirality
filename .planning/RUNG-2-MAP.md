# RUNG-2 MAP — everything between here and sovereignty (2026-07-28)

Purpose: name every requirement of **rung 2** (chirality-as-OS on metal) in one
place, each with its catalog/docs home and build-state, THEN back-check the
rung-1 goals against it — so rung 1 is provably building *toward* rung 2 and
not into a corner. Authorities: `SELF-HOST-PLAN.md` (the ladder),
`docs/trust-boundary.md` (what each rung converts, C8),
`docs/definitions/secure-datum-model.md` (the rung-2 threat model),
`docs/decision-deployment-custody.md` (key-level rung split), the catalog
(`SELF-IMPLEMENT-CATALOG.md` §VII trust lane), `docs/time-and-clocks.md`
(edges 19/20). This map ADDS no elements and settles no decisions — absences
are named for the docket, not minted here.

## What rung 2 is (one paragraph, from trust-boundary)

Rung 1 converts the **judgment root** and **authority root** to enforcement
(no CPython anywhere; a linear port unforgeable because there is no untyped
level to forge it at). Rung 2 converts the **secret root** and the **physical
guarantees**: the register root (TRESOR-style, derive-not-store), critical
sections under our own control, CHERI bounds carrying the B mark into
silicon — the full SECURE-DATUM story, whose guarantee is *exponential cost,
not prevention*. Rung 1 completes ownership; rung 2 completes sovereignty.
At rung 1 the whole secret-custody model is *discipline on a Linux we do not
control* (deployment-custody worry map) — only metal converts it.

## The requirement clusters

### Cluster 1 — the OS substance (chirality IS what runs)

The classical kernel is *dissolved*, not skipped: no memory manager
(conservation by linearity), no central device owner (a device is a typed
port over B substrate), no filesystem (port views over blocks), no
interrupt-handler table (a hardware event is an alarm crossing). But
dissolved-into-the-model is a **build obligation per shard**, and the catalog
carries almost none of it — this is the largest un-cataloged mass on the
ladder. (2026-07-28 revision: this cluster was under-decomposed; the hardware
rows below were previously absent.)

| Requirement | Home | Build-state |
|---|---|---|
| Runtime supervisor: critical sections (interrupt/preemption-disabled — SECURE-DATUM: "atomic, preemption-disabled or the root leaks"), register-root custody, scheduler | **E42** | PAPER; design notes only |
| Boot path on metal: CPU bring-up, master secret established in registers at boot, measured boot for the pre-IOMMU window | `docs/bootstrap-sequence.md` — **no catalog element** | docs-only |
| **Interrupt → alarm translation**: hardware events entering the effect row as alarm crossings; preemption control as the mechanism under E42's critical sections | **no catalog element** — consumes E39's row + E26's alarms as its shape | shape specced (E39), hardware half absent |
| **Memory at metal**: physical page supply, page tables, W^X without an OS (`mprotect`'s referent becomes our own MMU writes); the pool/arena minted against real physical capacity | **no catalog element** — consumes E21/E22/E28's shapes; E20's loader logic moves down a level | Linux-referent versions built/specced |
| **IOMMU configuration**: the DMA defense's *prevention* half (P5 verb honesty: the IOMMU denies, the split only detects); SECURE-DATUM holds when it is absent, but rung 2 should configure it when present | **no catalog element** | docs name it; zero design |
| **Hardware time anchor**: the register-anchored monotonic counter's real referent (TSC-class), replacing CLOCK_MONOTONIC under the same `Clock` cap | **no catalog element** — E32's split is its typed face | face audited (E32) |
| **Device bridges, per class**: NIC (target-hostile-net's substrate), storage (block-port views), display (the compositor lineage — `wire.chiral` speaks the protocol today), input. "An unwrapped driver is not expressible" (modules-substrate) — so each driver IS a wrapped-B bridge to write | **no catalog elements** — the port/bridge shape is E29–E33's | protocol tier partly chirality (E35/E36); device tier absent |
| **SMP / multi-core**: cores as the concurrency substrate under share-nothing ports; per-core bring-up and cross-core scheduling | inside **E42**'s scheduler mandate, decomposition unspecified | nothing |
| Bootstrap floor: cross-checked independent runtimes over the unverifiable residue | **E62** (edge 11; D7: re-derivability + DDC, no standing fleet) | direction only |
| Boot-image packaging (the rung-2 successor of ELF) | rides **E34**'s residue — the entry stub is the one Linux-specific artifact to swap | E34 drafted (Linux ELF) |

### Cluster 2 — the secret root (what rung 2 exists FOR)

| Requirement | Home | Build-state |
|---|---|---|
| Register root: derive-not-store, keys never in RAM | SECURE-DATUM §3; **E42** custody half; `modules-substrate` | docs-only |
| Memory custody: per-datum policy, zeroize-as-type-obligation, zeroize-to-the-floor (spills/DSE — P5's named honest limit) | **E56** (memory bank Shard 9; E28 decision #2 homed here 2026-07-27) | secret seed built (E40 type-level); rest vapor |
| Physical key levels: TPM, token, register custody | deployment-custody ("physical/hardware key levels → rung 2") | absent, by design |
| Persistent monotonicity: cross-boot rollback-proofness | edge 20 — **named hardware tier** (TPM NVRAM counter); boot-window is the honest rung-1 bound | shaped 2026-07-26 |
| Cleartext exposure window bounded (`clear-window <= N`) | graded types (E38 carrier) + custody (E56) | E38 drafted |

### Cluster 3 — the hardware type floor

| Requirement | Home | Build-state |
|---|---|---|
| CHERI floor: the B mark carried into silicon | **E63** (SPEC-tier; explicitly out of the CPU/RAM sandbox) | docs-only, hardware-gated |
| Constant-time enforcement (preserve-check's first customer) | **E60** | preserve-check built, unwired |
| Taint tracking | **E59** | zero code |
| IFC / whole-assembly non-interference + tier weight | **E44** (consumer of E73/E74) | named-crossings only |
| The membrane's inward reach settled (covert channels graded or scoped out on purpose) | edge 2 (P3's honest limit) | shaped |

### Cluster 4 — the trust/evidence mesh at full strength (a sovereign node facing a hostile world)

| Requirement | Home | Build-state |
|---|---|---|
| Outbound confinement membrane (no live capability leaks; the inbound `bridge.verify`'s dual) | **E73** (docket D8; 5 edges converge) | not built |
| Tier carrier (containment/independence/verdict riding the type) | **E74** (docket D9) | discipline designed, carrier unspecified |
| Split-role / guarded combine over independent sources | **E54** | docs-only |
| C-bridge evidence elaborator (attestation, freshness, audit…) | **E55** | inbound tag-check only |
| Adhikara over wire (zero-trust settled 2026-07-27; E61 authority-style choice open) | **E61** / decision-brokers | docs-only |
| `target-hostile-net` requirement type (total pre-auth recognizer, cost-bounded parse) | SELF-HOST-PLAN "owed later" — exercises D6/E61, edges 14/17, E44/E60 | not written |
| Cross-node ordering (causality rides the ports) | edge 19 | shaped 2026-07-26 |

### Cluster 5 — reflection & staging completion (the live environment on metal)

| Requirement | Home | Build-state |
|---|---|---|
| Staging / binding-time modality (Fork C) | **E57** | ad-hoc link-at-load only |
| reflect-typed staged metaprogramming, bounded by the frozen judgment | **E58** (gated on E45 + E57) | docs-only |
| Certified succession live (typed `code_change`, atomic port hand-over, succession-initiation a linear capability) | **E45** obligations (decision-reflective-floor) | drafted |

## The back-check: are rung-1 goals legitimately oriented?

Verdict per rung-1 goal — CONFIRMED (feeds rung 2 as-is) or WATCH (fine now,
one named thing must not leak).

| Rung-1 goal | Rung-2 consumer | Verdict |
|---|---|---|
| E50 termination + kernel port + fixpoint/DDC (lanes 2, prep, 5) | The judgment root is rung-invariant — E42/E58 are *checked by* this kernel | **CONFIRMED** — nothing Linux-shaped in the judgment |
| E51 sys-linkage (binding table, sysface confinement) | The table/wrapper *shape* is the rung-2 device-crossing shape; only the `nb-sys-*` bank is Linux | **CONFIRMED + WATCH-1** (below) |
| E28–E33 syscall bank | Rung-2 swaps the B referent (Linux nr → E42 supervisor crossing); Category C exists exactly for transport swaps | **CONFIRMED + WATCH-2** |
| E32 Clock/Timer split (2026-07-27) | `time-mono`'s referent upgrades Linux CLOCK_MONOTONIC → register-anchored counter with the cap unchanged; the split IS the rung-2 shape (anchor-read vs deadline) | **CONFIRMED** — the split was made *for* this |
| E45 freeze-Sig / succession | E42 itself is staged under this law; E58 is bounded by it | **CONFIRMED** — directly rung-2 load-bearing |
| E53 DDC + E72 re-bootstrap manifest | The climb chain must extend onto metal; E72 already enters at the tal floor, not at Linux | **CONFIRMED** |
| E40 secret seed + E56 obligations | Types land at rung 1 with degraded referents; referents upgrade at rung 2. C8 keeps the claim honest (OS-trusted until metal) | **CONFIRMED** — build the obligations in the type now, never fake the enforcement |
| E34 ELF + E20 loader | ELF/psABI is Linux packaging; rung 2 needs a boot image instead | **WATCH-3** |
| Profiles / conformance (stage 10) | `chirality-bare`/`chirality-firmware` are the rung-2 vehicles; port set is profile-invariant | **CONFIRMED** |

## Watch items (the leaks that would make rung 2 a fight)

1. **WATCH-1 — per-runtime, not module-global.** `runtime.py`'s `IMPLS` and
   E51's binding table are module-global today; the node model says each
   runtime's configuration carries its own (no global registry expressible —
   decision-brokers). E51's implementation must not deepen the global-ness.
2. **WATCH-2 — Linux numerics stay in the B bank.** Syscall numbers and errno
   values are B-referent data. The typed face may carry `errno I64` as value
   *payload*, but no Linux constant may become load-bearing in a Category-A/C
   *type* (constructor set, refinement bound). E39/E26's future classification
   of errnos must classify by *meaning* (recoverable/fatal), not by number.
3. **WATCH-3 — one entry-stub artifact.** All psABI/entry-protocol knowledge
   (argv/envp walk, E32 dec #6's env-get body) concentrates in E34's entry
   stub so rung 2 swaps exactly one artifact. Nothing else may read the entry
   stack.
4. **WATCH-4 — the sysface allowlist debt. PARTLY PAID 2026-07-28 (E76).**
   Was: the `sys` instruction carried an arbitrary numeric immediate, gated
   only by the `nb-sys-*` naming discipline. Now: `tal.py SYSCALL_TABLE` is an
   enumerated permitted set; `check_fn` refuses an unregistered `sys` op and
   binds each crossing's name to its number (`docs/decision-syscall-governance.md`,
   E76 first slice). Still owed on rung 1: the profile-permitted-**subset** gate
   + load-time enforcement (E76 remainder), the seccomp default-deny (**E77**),
   and number-in-type attenuation (**E78**). At rung 2 the set is closed by
   being the kernel. Do not let new crossings bypass the registry.

## Named absences (docket-tier; NOT minted here)

Cluster 1's un-cataloged rows, gathered (2026-07-28 revision — this list is
the honest size of the rung-2 hardware family):

- **Boot-on-metal path** — CPU bring-up, register-root establishment,
  measured boot; has a doc (`bootstrap-sequence`), no element.
- **Interrupt → alarm translation + preemption control** — the mechanism
  under E42's critical sections; consumes E39/E26's shapes.
- **Memory at metal** — page supply, page tables, self-managed W^X; the
  rung-2 referent under E21/E22/E28's shapes.
- **IOMMU configuration** — the prevention half of the DMA defense.
- **Hardware time anchor** — the register-anchored counter's referent under
  E32's Clock face.
- **Device bridges per class** — NIC, storage, display, input; each a
  wrapped-B bridge (modules-substrate: an unwrapped driver is not
  expressible).
- **SMP decomposition** — inside E42's mandate, unspecified.

All belong on the docket if/when rung-2 scheduling begins; per
SELF-HOST-PLAN, rung-2 items stay **seated, not scheduled**. The count
matters even unscheduled: it is the honest denominator behind "rung 1
completes ownership" — sovereignty is a module *family*, not a milestone.

## One-line verdict

Rung 1's goals are legitimately oriented: every lane feeds a rung-2 cluster
or is rung-invariant, the two decisions taken this week (Clock/Timer split,
frozen face) are *more* rung-2-aligned than the defaults they replaced, and
the only real risks are the four named leaks — all cheap to hold while the
substrate is still soft.
