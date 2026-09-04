---
node: view-security
layer: view
related: [index, perspectives, thesis, permission-model, category-bridge, node-architecture, axis-typeability, axis-altitude, modules-substrate, modules-custody, modules-security, modules-bridges, modules-broker, error-and-alarm, time-and-clocks, joining-law, open-edges]
status: draft
updated: 2026-09-03
---

# View: security

The whole system read from one seat, the reviewer asking what protects what, why
to trust it, and where the protection honestly runs out. Everything here is
restated from the linked notes; on any conflict, the notes win.

## The thesis is the threat model's shape

The [[thesis]]: anything a program can do that the framework cannot name is, by
that fact, ungoverned. Intent does not close a gap. So the security posture is
not a denylist bolted onto a language; it is the demand that the language express
everything, so that everything expressible is named and therefore gateable (P1).
Every mechanism below is this one idea applied at a different seam. Where the
idea runs out, at substrate no proof can reach, the design says so and switches
from proof to evidence (P5) instead of pretending.

## The trusted base, and how small it is

Trust bottoms out at two things: the register root and the agreement mechanism
that compares the bootstrap floor's runtimes. The register root is the master
secret established at boot and held only in CPU registers, never written to RAM;
DMA reads memory and cannot read registers, so it is the one runtime location the
in-scope threat cannot reach ([[modules-substrate]], the secure datum model).
Every per-datum key, MAC key, nonce, and version is derived from it on demand and
discarded, derive not store. The [[joining-law]] shrinks the rest of the base:
the bootstrap floor is not one trusted blob but a cross-checked set of tuned
compiler residuals whose agreement is the evidence, so the base is the root plus
the comparator, not a kernel ([[bootstrap-sequence]], [[module-map]]). One more
resident of the base: the single trusted emission step below tal where erasure
happens on ordinary hardware ([[modules-lowering]]). How many floor runtimes and
how independent they really are is edge 11 in [[open-edges]]; residuals of one
compiler may share that compiler's bugs, and the note says so.

## How authority works

There is no kernel and no ring ([[node-architecture]]). A capability is a held
port: authority is the set of typed ports a process holds, possession settled at
stage time, not a runtime request to a mediator. Complete mediation with no
mediator, because the port check is the type check. Permission is the other half
([[permission-model]]): a crossing between modules or profiles is not proven
across the seam, so it is permitted by the bridges it traverses agreeing, copies
compared, a verifiable split, a register-anchored MAC, an attestation, an audit
trail reconciled. Agreement permits the crossing; divergence is the alarm. No
owner adjudicates because agreement is evidence lining up, not privilege. The
irreducibly dynamic remainder, spawn, teardown, grant, revoke, belongs to the
component broker speaking Adhikara ([[modules-broker]]); its internal AUTH and
AUDIT decomposition is edge 8, and the Adhikara-to-capability-type correspondence
is edge 7.

## The three categories

[[axis-typeability]] partitions every module. A ([[category-typed]]) is
correctness by proof: the type system, information flow, taint, constant time,
the blocking trio in [[modules-security]]. B ([[category-untyped]]) is substrate
that can violate any type from outside the language's reach: DMA, raw memory,
foreign code, the register root itself. B is quarantined by type, not by
packaging ([[decision-b-in-type]]): a B module's signature declares its untyped
referent and forces every use through a C supervisor. A module that touches
DMA behind a light, pure-looking type is the failure this discipline is built to
avoid, the thesis's gap restated; the quarantine in the signature is what avoids
it ([[decision-b-in-type]]). C ([[category-bridge]]) is the
apparatus that lets A govern B by turning untypeable reality into checkable
evidence, and it is itself typed with no exemption, because a hole in the
supervisor would be the thesis's gap restated.

## The tier ladder

P5 names what a mechanism buys. T0, a typed singleton, secrecy and integrity by
proof, only for the typeable. T1, N full copies compared, integrity for the
untypeable, no secrecy. T2, plain Shamir, secrecy and availability but no tamper
evidence: a bad share reconstructs the wrong value silently, so anything where
silent corruption matters never sits at T2. T3, verifiable split, T2 plus
integrity, tolerating and naming t bad shares. [[modules-custody]] aims to make
declaring a split as cheap as declaring a variable, an aim, not a built property;
what picks a datum's default tier is edge 4.

## The membrane runs both ways

The bridge connector is one discipline in two directions ([[category-bridge]],
[[joining-law]]). Inbound, B to A, verify: a B-derived value enters A only as
evidence a typed process can check. This governs integrity, can I trust what I
read. Outbound, A to B, confine: an A value enters B encrypted if it must not be
read, carrying no live capability, its cleartext exposure window bounded. This
governs confidentiality and capability containment, does what I write leak. A
port that is outbound then inbound as one protocol, a device command and its
response, is the port protocol question, edge 14.

## Alarms and counter effects

Detection is only half a defense. A detected divergence is a typed effect, on the
membrane, total, impossible to drop silently ([[error-and-alarm]]). Because
everything is split, the alarm carries what diverged from what: which copy, which
share, which MAC. The response is a counter effect from a named set: re-key,
re-derive from the root, relocate, repair from survivors, quarantine, halt.
Recoverable or fatal is in the type. A detected attack becomes a reset that
invalidates the attacker's progress. The effect mechanism is edge 16; how loud an
alarm is across nodes is edge 17, and cross-node ordering is edge 19.

## Authority must lower or it is theater

[[axis-altitude]] stratifies authority ([[permission-model]]). At the upper
level, authority is over operations, a named command on a named datum. At the
metal, it is over resources, a device, a span of RAM. A command lowers to
resource access, so a guard on the command must lower into constraints on the
access it entails, across the lowering connector, or the access is ungoverned
even though the command was guarded. The same rule holds the stack down: no
untyped bottom above tal, preservation checked by `preserve-check`, and on CHERI
hardware the B mark reaches the silicon as an additive layer, never a
requirement ([[modules-lowering]]).

## The honest limits

The docs carry these, not hide them. A compromised foreign blob does whatever its
compartment allows; the orchestrator bounds the blast radius by the capability it
holds, it does not prove the foreign correct ([[axis-altitude]],
[[modules-bridges]]). DMA writes past every check, so software cannot prevent it;
the guarantee is exponential attacker cost through independent multipliers, plus
detect-and-reconcile, and whether that suffices for every device class is edge
15 (secure datum model, [[node-architecture]]). The cleartext working window is
irreducible, and a register spill on context switch is the one root leak, which
is why the `runtime` module holds the window atomic and preemption disabled. The
register-anchored counter clears on power loss, so rollback-proof persistence
needs hardware, a TPM monotonic counter, out of scope for the CPU and RAM only
model, edge 20 ([[time-and-clocks]]). The pre-IOMMU boot window and CPU code
execution are out of scope entirely; they need measured boot and capability
silicon, and the model is the floor beneath that hardware, not a substitute.

## Where the seat still has questions

Beyond the edges above: the reflective floor, what self-modifying code can and
cannot reach, is edge 5. How far the membrane reaches inward is edge 2. Which
security properties are blocking for the trusted base is recorded, not committed
([[modules-security]], [[open-edges]]). None are resolved here.
