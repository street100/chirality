---
node: banks/evidence-and-split
layer: bank
tier: depth
indexes: [vocabulary, glossary, axis-typeability, category-bridge, split-role, certificate-discipline, decision-split-checker, floor-agreement]
related: [banks/module, banks/effect-and-alarm, banks/port, banks/capability, category-untyped, decision-bridge-elaborator, modules-custody, modules-substrate, open-edges, status-ledger]
status: draft
updated: 2026-09-04
---

# BANK: evidence-and-split

> **What a bank is.** The depth tier under the thin relational notes in `docs/`.
> A bank holds the full refraction of ONE concept: what it is, the shards it
> decomposes into with their principled homes and honest build-state, the
> cross-cuts where one of its shards *is* a shard of another concept, and the
> native monoliths it gets mistaken for. Thin notes link *into* here.
>
> **Why this bank exists — and its special hazard.** This is the concept chirality
> was built to have and no borrowed language has: **cross-checked truth about
> substrate, where proof runs out** (category C, [[vocabulary]] `evidence`).
> [[axis-typeability]] calls C "*where Chirality earns its existence*." That is
> exactly why the bank's first duty is **honesty about build-state**: the richness
> below is the design's originality, and it is **overwhelmingly DESIGNED, not
> built**. The one place trust actually rests in code today is a single
> depth-bounded tag-check (`bridge.verify`) plus a type-level secret seed. If this
> bank's density reads as shipped machinery, it has failed at the one thing it most
> needs to do. Build-state below is AUTHORITATIVE from [[status-ledger]] and
> `records/conformance-map.md`; every claim is tagged, and the novel core is
> named DESIGNED wherever it is.

---

## 1. The concept in chirality

**Vocabulary definition ([[vocabulary]]).** Evidence *is* "cross-checked truth
about substrate (redundancy, verifiable split, MAC, attestation, reconciliation).
The bridge turns substrate into evidence a typed process can check (P5)." It *is
not* "proof. It is what you fall back on when proof runs out."

Sharpened into the load-bearing claims:

- **Evidence is the C answer to a B question.** [[axis-typeability]]: a module is A
  (correct by proof), B (an admitted untypeable hole — DMA, RAM, the register root,
  foreign code), or C (a *typed* module whose *referent* is a B thing, governing it
  by evidence). Evidence is the substance C trades in. You reach for it precisely
  when proof is unavailable — not as a weaker proof, but as a *different kind of
  truth*: cross-checked rather than derived.
- **Evidence is produced at a membrane crossing, never held ambiently.** The
  [[category-bridge]] is the connector that "turns untypeable reality into checkable
  evidence." A C module "*must never return a B derived value into A without first
  turning it into evidence*." So evidence is not a property a value *has*; it is
  something the bridge *does* to a value at the crossing (inbound verify), and its
  dual is confinement (outbound).
- **A truth is held at a tier, and the tier is named.** [[vocabulary]] `tier`: T0
  typed singleton (proof), T1 copies compared, T2 plain Shamir (the *warning* case,
  no tamper-evidence), T3 verifiable split. "How a truth is held" is itself typed
  information — "do what you can, named" ([[split-role]]). Evidence lives at T1 and
  T3; T2 is the trap that looks like evidence and delivers only secrecy.
- **Where proof CAN run, evidence is a re-checkable certificate, not agreement.**
  The provability boundary cuts the concept in two ([[certificate-discipline]],
  [[decision-split-checker]]): a *provable* property is held by a certificate a
  small trusted core re-derives (show-your-work, ungameable); only the
  *genuinely-unprovable* residue is held by agreement across independent sources.
  Pushing truth from agreement-land into certificate-land is the design's standing
  job.

**What it IS.** A discipline with two operations and a ladder: **verify inbound**
(B→A: substrate to checkable evidence to typed value, disagreement is the alarm),
**confine outbound** (A→B: strip secrets/capabilities before a value reaches
ungoverned substrate), realized by **one general bridge elaborator instantiated
per evidence element**; a **tier ladder** naming how strongly a truth is held; a
**split-role** the substrate provides (containment + independence + verdict) for
the unprovable residue; and a **certificate discipline** for the provable core,
bottoming out at a **register root** and a **cross-checked set of runtimes**.

**What it IS NOT.** Not proof (that is A / T0). Not a `try/catch` (that catches a
value after the fact; evidence *is* the gate you must present to cross). Not a trust
store or a CA blob (a trusted pile, the exact thing the certificate discipline
replaces with a checked socket). Not consensus-as-a-whole (consensus is *one leg* —
the verdict — riding on independence). Not N-version programming as such (that is
one *tier* of one *leg*). Each native monolith fuses one shard below with the whole;
see §4.

**How it is realized in code (evidence).** Almost none of it, and the bank's honesty
turns on saying so. ⚑ **And less than this section claimed, re-measured
2026-09-04.** The *only* built C-bridge crossing was the inbound tag-check in
`bridge.py`: `verify()` walking a returned host value against the
extern's declared result type, depth-bounded to four, raising `PortError` on
mismatch, "evidence at the membrane, not proof of the implementation". That file
went with the Python oracle and has **no live referent**; nothing in `lib/`
re-checks an extern's return today, and `lib/evidence/interp.chiral:19-21` names
that face as E15's deferred connector. So the C bridge is built in **no** place at
all. The secret
custody seed is type-level only (`lib/capability/secret.chiral`, E40, SEEDED). The certificate
discipline's *flagship* — `preserve-check` — is built and ENFORCED, but for the
*lowering/optimizer* seam, not for the C bridge. Everything else named in this bank
is DESIGNED.

---

## 2. The refraction — the shards, their homes, their build-state

The conventional "make the untrusted trustworthy" monolith decomposes into these
shards. Build-state is authoritative from [[status-ledger]] and
`records/conformance-map.md`. Read the column: **one shard is built, one is
seeded, the rest are DESIGNED.**

### Shard 1 — inbound verify (the sliver that was built) · **no live referent**
- **What.** B→A integrity: every value an extern returns is checked against its
  declared result type at the crossing; a divergence is a typed alarm, not a
  downstream crash. This is the smallest real instance of "turn substrate into
  evidence a typed process can check."
- **Home.** the inbound face of the [[category-bridge]] connector.
- **Build-state.** ⚑ **No live referent, recorded 2026-09-04.** This was the one
  place the C bridge was real in code, and it was `bridge.py`'s `verify()`:
  tag-checking `I64/Str/Bytes`, the port atoms `Sock/Fd/Pool/LSock` and datatype
  constructors, depth-bounded to four, mismatch to `PortError`. All of it went with
  the Python oracle. CONFORMANCE-MAP "inbound bridge
  integrity-verification": CONFORMS, **no E#**, "*Integrity/inbound half only …
  Outbound confinement not built*" — a verdict on the oracle, left visible for that
  reason. The honest ceiling has moved: the shard is now **DESIGNED with a prior
  implementation**, and the C-bridge column below has no built row.
  [[banks/port]] Shard 4 carries the same finding from the port side.

### Shard 2 — outbound confine (the missing half) · **BUILD / not built**
- **What.** A→B confidentiality + capability containment: an A value crossing into B
  must be encrypted if it must not be read (a secret reaching DMA-readable RAM is a
  leak), carry no live capability into ungoverned substrate, and have a bounded
  cleartext window ([[category-bridge]] "Outbound").
- **Home.** the outbound face of the [[category-bridge]]; names `information-flow` +
  linearity (A) + `datum-policy` (C) as one discipline.
- **Build-state.** **BUILD, not built.** CONFORMANCE-MAP: "*Outbound confinement not
  built.*" The mechanisms it would *name* are themselves mostly vapor (IFC/taint/
  constant-time, E44/E59/E60, "nearly vapor in code", [[status-ledger]] gap #1). So
  the bridge is **half-preserving today**: it verifies what comes in, it does not
  confine what goes out.

### Shard 3 — the evidence elements (one elaborator each) · **DESIGNED (E55), docs-only**
- **What.** attestation / freshness-verify / audit-reconcile / isolation-enforce /
  reflect-raw — named evidence-producing crossings where proof runs out at B, each
  **re-checking a certificate via `bridge-preserve-check`** rather than being a
  bespoke per-referent module ([[decision-bridge-elaborator]]: "*One general bridge
  elaborator, not per-referent bridges*", parameterized by a target A-type and an
  evidence element — the same *shape* as `translate` + `preserve-check`, an analogy
  the decision itself weakens: "entered only as evidence" constrains downstream
  *use*, which hangs on unpinned edge 18).
- **Home.** [[category-bridge]] / [[modules-bridges]]; the elaborator pattern of
  [[decision-bridge-elaborator]].
- **Build-state.** **DESIGNED, docs-only. E55** (catalog §VII, freshly authored
  2026-07-21). CONFORMANCE-MAP "C evidence bridges": "*Zero code; docs-only, only
  inbound tag-check exists.*" Edge 12 (the `bridge-preserve-check` statement) is the
  residual. Note the catalog now carries E55 where the conformance-map D-row still
  reads "needs E-number" — the number was assigned in the same 2026-07-21 pass; the
  code state is unchanged: none.

### Shard 4 — the tier ladder T0–T3 · **DESIGN LAW; instances mostly forward**
- **What.** How a truth is held ([[vocabulary]] `tier`, [[axis-typeability]] "*the
  tier ladder is this axis*"): **T0** typed singleton = A = proof; **T1** copies
  compared = C; **T2** plain Shamir = the *warning* case (secrecy without C's
  integrity — "looks like C but delivers only A's secrecy"); **T3** verifiable split
  = C. The shares/replicas themselves live in B. "Do what you can, named" — a truth
  wears its tier so no one is fooled about where trust rests.
- **Home.** [[axis-typeability]] (the ladder *is* the axis) + P5 (the tiering, which is P5's operational detail).
- **Build-state.** The *ladder* is settled design law. Its *instances* per build:
  **T0 is built** (the kernel judgment, E3–E5, [[banks/module]] Shard 1). **T1
  copies-compared is partially built as a development discipline** — differential
  testing / floor-agreement (§3, [[floor-agreement]], and the scripts under
  `tools/test/` that `tools/test/run-tests.sh` drives) is the T1
  net that is real today. **T2** is named as a trap, not a target (no code owed).
  **T3 verifiable split is DESIGNED** (E54, Shard 6). So the ladder is real; the
  rungs above T0/T1-as-CI are forward.

### Shard 5 — agreement-vs-certificate (the provability cut) · **certificate flagship built; the split-checker climb DESIGNED**
- **What.** The boundary that decides *which tool*: where a property is **provable**,
  a source emits a **certificate** a small trusted core re-derives (ungameable:
  "show your work, do not spot-check", [[certificate-discipline]]); where it is
  **genuinely unprovable**, you fall back to **agreement** across independent sources
  ([[split-role]]). The design's job is to shrink agreement-land to the irreducible
  physical residue.
- **Home.** [[certificate-discipline]] (the provable side) / [[split-role]] (the
  unprovable side); the boundary drawn in [[category-bridge]] and
  [[decision-split-checker]].
- **Build-state.** Split. The certificate discipline's **flagship `preserve-check`
  is BUILT/ENFORCED** ([[status-ledger]], `lib/lowering/upper/lower.chiral` and
  `lib/lowering/upper/optimize.chiral`, whose `re-check` at `:250` is the
  preserve-check in the pipeline's signature; "*the proof that
  a lowering step opened no hole*", [[modules-lowering]]) — a real certificate re-checker for the
  lowering seam. The **kernel-core certificate split** (kernel-spec + trusted core +
  untrusted producers) that generalizes it is **DESIGNED, E52** (F2's tier-climb,
  Shard 8). The agreement side's provider is **DESIGNED, E54** (Shard 6). So the
  *pattern* is proven once in code (preserve-check); its generalization to the
  checker and to the bridge is the forward work.

### Shard 6 — the split-role (containment · independence · verdict) · **DESIGNED (E54), docs-only**
- **What.** A **substrate-provided role a module *requires* and a profile *supplies***
  ([[split-role]]) — a module that needs a split does *not* build one; it declares a
  `Split` requirement and the profile supplies a conforming provider (share /
  guarded-combine / agree / alarm / provenance-check in one place, generalizing
  `custody-split`). **Three legs:** *containment* — what a member can do to the world,
  its typed port set (floor: port-bounded overt containment); *independence* — can
  members fail together, typed provenance-disjointness the combine's type requires;
  *verdict* — is a member right, by **agreement** (K-of-N, no single member trusted).
  **Verdict rides on independence** — correlated agreement is theater — so the legs
  are two typed properties plus a verdict *parasitic* on one of them, and saying so
  is part of the honesty.
- **Home.** [[split-role]] (the role) / [[decision-profiles]] (the require/supply
  seam) / [[modules-custody]] (the machinery it generalizes).
- **Build-state.** **DESIGNED, docs-only. E54.** CONFORMANCE-MAP "split-provider /
  split-role": "*Docs-only … Gated edge 4 (tier auto-selection) + edge 11
  (independence).*" What is real of its *containment* leg is the port membrane
  (E30–E33, built, [[banks/port]]); what is real of its *redundancy* is nothing
  beyond the type-level secret seed (E40). The role itself — the require/supply, the
  guarded combine, the per-axis minimum tiers — is unbuilt.

### Shard 7 — the register root / bootstrap floor · **DESIGNED (E62/edge 11), direction only**
- **What.** Trust bottoms out somewhere physical. The **register root** — master
  secret held only in CPU registers, never in RAM, the runtime root against DMA
  ([[glossary]], [[modules-substrate]]). Below the checker, the unverifiable base is
  held the C way: a **cross-checked set of independent runtimes**, agreement over the
  residue ([[decision-split-checker]] "*N tiny independent proof-checkers over one
  portable proof object* … *plus Diverse Double-Compiling*").
- **Home.** [[modules-substrate]] (register root, part of the E42 supervisor's job) /
  [[split-role]] + [[decision-split-checker]] (the cross-checked runtimes) / DDC.
- **Build-state.** **DESIGNED — E62** (bootstrap-floor). ⚑ Do not sweep **E53**
  into that verdict: the DDC half is **BUILT** (`CONFORMANCE-MAP.md:45`,
  CONFORMS) and since 2026-08-24 runs with a second toolchain-disjoint leg
  (E166's `ddc-legc`). What stays designed is the *floor* — the cross-checked set
  of independent runtimes — not the double-compilation that would check it.
  ⚑ **2026-09-01: the second leg is gone.** The C backend was dropped
  (`d8bcec5`), so `ddc-legc` names a toolchain nothing builds with and the DDC
  half runs with one leg again. It was a second *target* under one
  formulation; see [[decision-self-verification]].
  Register-root custody is part of the unbuilt **E42 supervisor**
  ([[banks/runtime]] Shard D, DESIGNED). CONFORMANCE-MAP "bootstrap-floor": DECISION,
  "*Direction only; internals open (edge 11): count/independence/relation to the
  supervisor; shared-compiler residuals may void agreement.*" This is the deepest
  unbuilt floor — the honest bottom of the trust story.

### Shard 8 — the certificate kernel-core split · **DESIGNED (E52), F2's tier-climb**
- **What.** The checker itself split by de Bruijn / LCF: **kernel-spec** (the demanded
  statement, human-audited) + **kernel-core** (one small trusted derivation checker) +
  **untrusted producers** (elaboration, optimizers, SMT, staging — churn freely,
  trusted for nothing, each emits a certificate the core re-checks). Trust and volume
  decoupled ([[decision-split-checker]]).
- **Home.** [[decision-split-checker]] / [[certificate-discipline]]; ties
  [[banks/module]] C8 (the kernel module split reflexively).
- **Build-state.** **DESIGNED, E52.** CONFORMANCE-MAP "Kernel-core certificate
  verifier + discipline": "*Settled in docs; kernel.py is single trusted checker,
  no producer/consumer split.*" The **honest interim named in the decision itself**:
  the checker's *present-day* assurance **is agreement** — differential testing of
  diverse implementations plus `preserve-check` — and the move to the verified-core /
  certificate tier is a **tier climb taken element by element**, not a switch already
  thrown. That candor ("*the earlier draft called that agreement 'not the trust
  story', which was the dodge the audit caught*") is the model this whole bank follows.

---

## 3. Cross-cuts — where a shard of "evidence" IS a shard of another concept

The highest-value section: where refracting *evidence* and refracting some other
concept land on the *same* shard.

**X1 · Divergence IS the alarm (verdict/independence ↔ [[banks/effect-and-alarm]]).**
The moment inbound verify (Shard 1) or a split's guarded combine (Shard 6) finds
disagreement, the truth-holding operation and the *alarm* system are the same shard.
[[category-bridge]]: "*Disagreement is the alarm.*" The built `bridge.verify` already
lives this — a tag mismatch is the design's typed alarm, realized today as the
`PortError` crutch (E26, gated on E39), not a crash. A split provider's non-agreement is likewise "*a typed effect it is forced to
handle*" ([[split-role]]). So "evidence caught a divergence" and "an alarm fired" name
one event; the counter-effect (re-derive / repair-from-survivors / quarantine / halt)
is the answer. Do not re-document the alarm side — [[banks/effect-and-alarm]] owns it;
this bank owns *what produced* the divergence.

**X2 · The split a module requires IS the split-role a profile supplies ([[banks/module]]
C2).** Shard 6 is the *same shard* [[banks/module]] refracts from the module side: a
module that holds redundant evidence does not build a split, it declares a `Split`
requirement, and the profile must supply a conforming provider. Module-side ("this
module needs cross-checked truth") and evidence-side ("here is the split role,
containment+independence+verdict") are two ends of one require/supply seam. Both are
**DESIGNED, E54, gated edges 4+11.** [[banks/module]] C2 and this bank's Shard 6 must
agree; they are the same unbuilt thing seen twice.

**X3 · Containment IS a port-set IS a capability set (containment ↔ [[banks/port]] /
[[banks/capability]]).** The containment leg (Shard 6) is not a new mechanism: "*what
can a member do to the world*" is exactly its typed **port set** (P3), which is
exactly its **capability set** ([[banks/capability]]: authority is the set of ports
held). A split member holding no egress port cannot *overtly* exfiltrate the corpus —
but the verdict/alarm it emits is itself a channel it can modulate, so covert
exfiltration is a *higher tier* (constant-time / IFC), the split's own honest limit
([[split-role]]). So containment is *built at the floor* (the port membrane, E30–E33)
and *unbuilt above it* (covert-channel hardening). The tier ladder (Shard 4) even
reappears inside one leg.

**X4 · The certificate IS the kernel-core checker split (Shard 5/8 ↔ [[banks/module]]
C8).** "Evidence where the property is provable" and "the kernel re-checks an
untrusted producer's certificate" are one shard. [[banks/module]] C8: "*module
identity is by type*" is precisely what lets the core re-check a certificate without
trusting the producer — the certificate is a term whose type the core checks. The
splitting law applied to the module that runs the splitting law. Built once
(`preserve-check`), generalized as **E52, DESIGNED**.

**X5 · Independence bottoms out at the bootstrap floor (Shard 6 ↔ Shard 7).** The
independence leg is only as good as its provenance tags, and "*a trustworthy tag
needs attestation, which bottoms out at the register root like everything else*"
([[split-role]]). So the verdict-rides-on-independence chain (Shard 6) does not
terminate inside the split — it terminates at Shard 7's register root + cross-checked
runtimes, where "*shared-compiler residuals may void agreement*" (edge 11). The
whole tower of evidence rests on this one physical, DESIGNED floor.

**X6 · Every held truth carries a tier — including a capability's (Shard 4 ↔
everything).** The tier ladder is not local to secrets; it types *how strongly any
truth is held*. A capability is held at a tier ([[banks/capability]]); a floor's value
agreement is held at a tier (by-construction collapse vs by-test fuzz,
[[floor-agreement]]); the checker's own assurance is held at a tier (agreement now,
certificate later, Shard 8). "Do what you can, named" is a single discipline that
cross-cuts the entire base — the tier annotation is the shard shared by every
truth-bearing construct.

**X7 · Differential testing IS the built T1 / the honest interim (Shard 4/5/8 ↔
[[floor-agreement]]).** The one place agreement-as-evidence is *actually running*
today is differential testing: floor-agreement fuzzes native code against the
reference interpreter ([[floor-agreement]] "validate/fuzz"), and the checker's present
assurance "*is* … differential testing of diverse implementations"
([[decision-split-checker]]). This is T1 (copies compared) realized as a CI
discipline — the legitimate residue agreement is *for*, not a placeholder to
apologize for. It is the built floor under the DESIGNED certificate climb —
noting that the reference interpreter's *golden* role, once the Python reference
is evicted at self-hosting, is itself E71's open decision (2026-07-21 catalog
extension).

---

## 4. Native → chirality translation (the misfire → the correction)

Each conventional monolith is **one tier or one element** of the split — never the
whole thing. The misfire is to import the monolith; the correction names the shard
and its build-state.

**"You need `try/catch` to validate untrusted input."**
→ It is the **inbound bridge** (Shard 1) — and it is the one thing *built*
(`bridge.verify`, IMPLEMENTED). But sharpen the shape: a `try/catch` catches a value
*after* it has entered and something threw; the bridge makes the checked evidence *the
thing you must present to cross* ([[certificate-discipline]]: "*not a badge, it is the
thing you must present to cross*"). Divergence is a typed alarm (X1), not an exception
to swallow. Genuinely-new residue: the *outbound* half (Shard 2, confine) has no
`try/catch` analogue and is **not built**.

**"You need a trust store / PKI / a CA to know what to trust."**
→ That is the **certificate discipline** (Shard 5/8), and the correction is a *tier
downgrade of trust*: a trust store is a **trusted pile**; chirality replaces it with a
**checked socket** — a small trusted core that re-derives an untrusted producer's
certificate ("*a checked socket beats a trusted pile*", [[decision-split-checker]]).
The CA blob you wanted to trust becomes a certificate you re-check. **DESIGNED, E52**;
the pattern is proven once as `preserve-check`.

**"You need remote attestation."**
→ It is **one evidence element** — `attestation` (Shard 3, the first of the E55
family), a single instantiation of the general bridge elaborator, re-checking an
attestation certificate via `bridge-preserve-check`. Not a subsystem; **DESIGNED,
E55, docs-only.** And its guarantee bottoms out at the register root (X5).

**"You need N-version programming / diverse redundancy."**
→ It is **one tier of one leg**: the *verdict* leg at the *copies-compared* tier (T1),
scaled to whole runtimes at the **bootstrap floor** (Shard 7, **E62**). Crucially the
*decision-split-checker* audit found N-version was the **wrong tier for the checker** —
redundancy is cheap and genuinely independent at the *proof-checker* level, expensive
and correlation-prone at the *type-checker* level. So "run N checkers and vote" is a
misfire for the provable core (use a certificate) and correct only for the unprovable
residue. **The floor is DESIGNED (E62); the built instances are differential
testing (X7) and DDC (E53), the latter with a genuinely disjoint second leg since
E166.**

**"You need unit / differential tests to be sure."**
→ A test is the **weak end of the ladder**, and the certificate discipline names why:
"*a test says I ran some examples and both sides agreed — vacuous examples pass, so it
checks nothing meaningful; a certificate says here is my derivation, re-run it*"
(Shard 5). Differential testing is nonetheless the **honest interim** (X7, T1, built)
and the legitimate residue for the genuinely-unprovable. The correction is not "tests
are wrong" but *name the tier* — a test is agreement-grade, a `preserve-check` is
certificate-grade — "*so a reused-signature is never mistaken for a fresh proof*"
([[certificate-discipline]] Tiering).

**"You need a consensus protocol."**
→ It is **the verdict leg alone** (Shard 6): agreement, K-of-N, no single member
trusted. But verdict **rides on independence** — "*correlated agreement is theater*" —
so consensus without the typed provenance-disjointness leg is exactly the theater the
split-role forbids. Consensus is one-third of the role, and the unbuilt two-thirds
(containment at the floor is built; independence is DESIGNED) are what make the verdict
mean anything. **DESIGNED, E54.**

---

## 5. What's genuinely new / unbuilt — the honest residue

This is where the weight of the bank sits: the novel core is the design's identity
(Fable audit F1/F2) and it is **overwhelmingly DESIGNED**. Gradients preserved; E-numbers
were assigned in the 2026-07-21 catalog pass (§VII), so several conformance-map rows
that still read "needs E-number" now have one — with **no change to the code state**.

1. **The split-provider / split-role — DESIGNED (E54).** The three-leg role
   (containment / independence / verdict) a module requires and a profile supplies.
   Docs-only; gated **edge 4** (per-axis tier auto-selection, carried in the type so
   under-reaching is a type error) + **edge 11** (independence: provenance-disjointness
   against *named* axes, not absolute). What is real: the *containment* floor (port
   membrane, E30–E33) and nothing of the guarded-combine/agreement machinery.
   ([[banks/module]] C2 is the same shard.)

2. **The C-bridge evidence-half — DESIGNED (E55).** attestation / freshness-verify /
   audit-reconcile / isolation-enforce / reflect-raw, **each an instantiation of the
   one general bridge elaborator**, each re-checking a certificate via
   `bridge-preserve-check`. Docs-only; **edge 12**
   (the `bridge-preserve-check` statement) is the residual; overlaps the unbuilt
   **outbound confinement** (Shard 2). The inbound tag-check is the *only* built
   crossing.

3. **The kernel-core certificate split — DESIGNED (E52), F2's tier-climb.** kernel-spec
   + trusted core + untrusted producers. The decision is *made* (the checker is a
   checked socket, not a quorum — [[decision-split-checker]] reverses its own earlier
   draft), the code is not. The **honest interim is agreement** (differential testing +
   preserve-check); the climb to certificate-tier is per-element. **Ties [[banks/module]]
   C8.** Not "years of work" by default and not "already done" — a named tier climb.

4. **Diverse Double-Compiling — ~~DESIGNED, zero code~~ BUILT and RUNNING (E53 +
   E166).** The trusting-trust independence residue under E52 (Wheeler DDC;
   Thompson). *This item said "zero code" and that was already wrong when it was
   written*: `CONFORMANCE-MAP.md:45` records the compare core as **BUILT (E53,
   2026-07-28), CONFORMS**, `examples/INDEX.md` has E53 **implemented**, and
   `lib/evidence/ddc.chiral` is a proven-total compare core, 213 lines as of
   2026-09-04 (`Prov`/`Leg`/`DdcR`/`LegOut` + first-divergence fold). As of **2026-08-24**
   the quorum also had a second genuinely disjoint leg: `ddc-legc`
   (`lib/evidence/ddc.chiral:162`, `("c" "gcc-12" "shred" 2026)`) from **E166**,
   gated by a C-leg script and by Phase 10 of the native suite. ⚑ **That
   leg was dropped 2026-09-01** (`d8bcec5`, `d0c5dd5`) and the `Leg` value it
   registered now has zero callers and zero assertions. What follows in this item
   is the record of what the leg bought while it ran. What that
   buys is **toolchain** disjointness — the axis a Thompson attack lives on — and
   *not* a smaller trusted base, since gcc carries the whole of gcc. What is
   still honestly open: the `author` axis stays `"shred"` for every leg and is
   recorded rather than laundered (`lib/evidence/ddc.chiral:29`), and
   `ddc-verdict-code` still
   composes leg 0 with the dying Python leg 1 rather than with the C one. Depth
   tier: [[banks/verification]] Shards 4 and 8. Its shipped form is **E72**
   (re-bootstrap artifact: the climb chain as a checkable manifest — "no
   unverifiable artifact"; couples E71 spec-as-golden and the E52 spec-size
   budget; example drafted).

5. **The bootstrap floor — DESIGNED (E62), DECISION/edge 11.** A cross-checked set of
   independent runtimes; the register root (DMA defense, part of the unbuilt **E42**
   supervisor). Internals open: how many runtimes, how independent, relation to the
   supervisor; **shared-compiler residuals may void agreement** — the sharpest honest
   caveat in the whole trust story. The true bottom, and it is direction-only.

6. **Custody redundancy / datum-policy / memory custody — DESIGNED (E56).** Beyond the
   secret seed: copies-agree/divergence-detect, per-datum flow policy, register-root /
   zeroize as a *type obligation*. redundancy is an instance of the split-provider
   agreement (E54).

**Named as built, so the gradient is honest:**
- **Inbound `bridge.verify`** — ⚑ **struck 2026-09-04.** It was implemented,
  host-mediated, depth-bounded to four and tag-only, and it went with the oracle.
  There is no real C crossing.
- **Secret custody seed** — SEEDED, **type-level only**, E40 (`lib/capability/secret.chiral`):
  opaque linear `Secret`, single greppable exit `secret-reveal`. Host-copy hygiene
  partial (returns immutable `bytes` it cannot zero); memory custody absent; redundancy
  not built. The first line of [[modules-custody]], nothing more.
- **`preserve-check`** — BUILT/ENFORCED (`lib/lowering/upper/lower.chiral`,
  `lib/lowering/upper/optimize.chiral`), the certificate
  discipline's flagship — but for the *lowering* seam, not the bridge or the checker.
- **Differential testing / floor-agreement** — BUILT as a CI discipline
  ([[floor-agreement]]), the running instance of T1 agreement and the checker's honest
  present-day assurance.

**Gradient summary.** Of the eight shards: **one is built** (inbound verify), **one is
seeded** (secret custody, type-level), **one is a proven pattern awaiting
generalization** (preserve-check → E52/E55), and **five are DESIGNED** (outbound
confine, the E55 evidence elements, the split-role E54, the kernel-core split E52, the
bootstrap floor E62 — whose DDC leg E53 *is* built, while the floor it would check
is not). This is the concept chirality was built to have and has not yet
built. Do not describe the DESIGNED core as present; do not describe the built sliver
as missing.

---

## 6. Relational anchors — thin notes that should link INTO this bank

- [[vocabulary]] — the `evidence`, `tier`, `substrate` entries (the definitional
  source; §1).
- [[glossary]] — `certificate`, `certificate discipline`, `split role`, `tier`,
  `register root`; point here for depth.
- [[axis-typeability]] — A/B/C and "the tier ladder is this axis" (Shard 4).
- [[category-bridge]] — the inbound/outbound bridge, one elaborator (Shards 1–3).
- [[decision-bridge-elaborator]] — the general elaborator the evidence elements
  instantiate (Shard 3).
- [[split-role]] — the three legs, the require/supply seam (Shard 6).
- [[certificate-discipline]] — show-your-work, the provable side (Shard 5).
- [[decision-split-checker]] — the kernel-core split, the reversed quorum, the honest
  interim (Shards 5, 8).
- [[floor-agreement]] — the built T1 differential-testing instance (X7).
- [[modules-custody]] / [[modules-substrate]] — the secret seed, the register root
  (Shards 6, 7).
- [[banks/module]] — C2 (the split a module requires = Shard 6), C8 (the kernel module
  split = Shard 8); the same shards from the module side.
- [[banks/effect-and-alarm]] — "divergence is the alarm" (X1); owns the counter-effect
  end.
- [[banks/port]] / [[banks/capability]] — containment = port-set = capability-set (X3);
  every capability carries a tier (X6).
- [[open-edges]] — edge 4 (tier auto-selection), edge 11 (independence / bootstrap
  floor), edge 12 (bridge-preserve-check).
