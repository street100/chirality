---
node: banks/capability
layer: bank
tier: depth
indexes: [vocabulary, glossary, permission-model, node-architecture, split-role, modules-broker, decision-b-in-type]
related: [banks/port, banks/effect-and-alarm, banks/memory, banks/evidence-and-split, banks/module, banks/profile, banks/runtime, split-role, permission-model, modules-broker, node-architecture, status-ledger, open-edges]
status: draft
updated: 2026-07-23
---

# BANK: capability

> **What a bank is.** The depth tier under the thin relational notes in `docs/`.
> A bank holds the full *refraction* of ONE concept: what it is, the shards it
> decomposes into with their principled homes and honest build-state, the
> cross-cuts where one of its shards *is* a shard of another concept, and the
> native monoliths it gets mistaken for. Thin notes link *into* here.
>
> **Why this bank exists.** "capability" is the **richest security refraction** in
> the language, and its shards live in the most widely separated homes of any
> concept — the kernel's linearity check, the profile's frozen port set, the
> refinement fragment, the fd-passing crossing, the alarm system, the broker, the
> split-role, and a not-yet-drawn reflective floor. A monolith in every prior
> system — an OS capability, a file descriptor, an object-capability reference, an
> ACL row, an OO handle — is here a *sum of shards*, most of them already built and
> **enforced**, one of them (grant-narrowing) built-but-not-yet-applied, and a
> handful genuinely designed-only. The recurring misfire is to see the monolith
> "missing" and say *you need a capability system / a permission layer / a
> revocation mechanism*. You mostly don't: authority is already a linear port whose
> type is the authority, non-forgeability is already a four-tier conjunction, and
> revocation is already a customer of the alarm system. This bank documents that
> refraction so nobody names the phantom again. Build-state is AUTHORITATIVE from
> [[status-ledger]] and `records/conformance-map.md`; where a facet is
> genuinely unbuilt it is named as such, never rounded to done.

---

## 1. The concept in chirality

**Vocabulary definition ([[vocabulary]], `capability` entry).**

> **capability.** *Is:* a port held. Authority is the set of ports you hold (P3).
> *Is not:* a ring or a privilege class. There is no privilege here, only
> possession.

And its active-role twin, the `grant` / `sidehand` entry:

> **grant (sidehand).** *Is:* a capability in its active role, what a process
> brings to a crossing to authorize the action it attempts. *Is not:* a separate
> mechanism from a capability. A grant is a held port used at a crossing.

Sharpened:

- **A capability IS a [[banks/port]] held** — not a token *naming* an authority, but
  the authority itself. There is no permission record to consult, no gate that
  adjudicates; *holding the port is the authority* ([[permission-model]] §"A grant
  is an authority"). "What *may* this process do?" is answered by set-membership
  over the ports it holds — possession bounds exercise: what it *does* is the
  effect row, joined to possession by construction once every crossing takes its
  capability as a parameter ([[decision-effect-facets]], 2026-07-21).
- **The TYPE is the authority.** A capability's power is exactly the crossings its
  port type admits and no others; the port type is where the governance lives
  ([[node-architecture]] "authority is not a runtime entity behind a privilege
  boundary, it is a property of a port's type, settled when the code was staged").
  Two ports over the same substrate with *different types* are *different*
  authorities (a block view vs a log view over the same RAM — [[node-architecture]]
  "Ports are where the logic lives").
- **Authority is the SET you hold, monotone under nothing but the four grant
  operations.** No ambient authority, no `root`, no ring — as the *target*
  invariant: the remaining ambient process externs (`print`/`put`/`trace`/
  `env-get`, `ports/clock.chiral:32–34` and `ports/process.chiral:13–14` — repointed
  2026-08-22, `ports.chiral` is now a 48-line façade over nine registries) cross with
  no held port, the named current
  violation, closed by capability reification ([[decision-effect-facets]],
  2026-07-21). The closure has begun: `time-mono`/`sleep-ms` were reified
  2026-07-28 (E32 — cap-gated behind linear `Clock`/`Timer`, sums threading
  the cap back), and `env-view` is `env-get`'s cap-gated successor; the
  writers ride the Console commit (E39 step 7), `env-get`'s retirement rides
  the same profile-hands-caps arc.
  Attenuate/Move/Delegate/Revoke are the only ways the set changes
  ([[permission-model]] §"What you can do with a grant").

**What it IS.** A **linear port** whose type names its authority, which is (a)
non-forgeable by a *conjunction* of four mechanisms at four tiers, (b) attenuable
by subtyping over its refinement/value-index, (c) delegable by Move locally and by
a different mechanism-set across a node boundary, (d) revocable only as a customer
of the effect/alarm system, and (e) carrying a split-role tier in its type. Each
of (a)–(e) is a shard with its own home (§2).

**What it IS NOT.** Not a privilege ring or class (there is no privilege — only
possession). Not a token/handle that *names* an authority stored elsewhere (the
port *is* the authority). Not an ACL row (there is no owner keeping a table — §4).
Not a runtime permission check (mediation is at stage time in the type, "complete
mediation with no mediator" — [[node-architecture]]). Not a first-class "capability
object" you allocate (a porttype has *no constructor* — §2 Shard B). Each of those
is a conventional monolith that fuses several of the shards below onto an owner and
a runtime gate that chirality discards.

**How it is realized in code (evidence).** A capability is a value of an **opaque
linear porttype** declared in `scaffold/lib/ports.chiral:1–19` (`Sock`, `LSock`,
`Fd`, `(Pool n)`). `porttype` introduces "an opaque linear atom: the kernel learns
nothing about it except that it exists and that … a value of it … can only ever be
bound with quantity 1" (`ports.chiral:3–8`). The declaration path is
`surface.py:108–126` → `K.declare_atom(sig, name, linear=True)`
(`kernel.py:570–575`), which registers an atom type with a `linear` flag and **no
data constructors**. Authority-crossings are `extern`s whose types are owned in
source and whose host referents bind at link (the nine `ports/*.chiral` registries —
repointed 2026-08-22; `ports.chiral` is now a façade). There is no
`capability` object, no permission table, and no runtime check — exactly as the
concept claims.

---

## 2. The refraction — the shards, their homes, their build-state

Each shard is a facet the conventional capability monolith fuses; in chirality each has
its own principled home and its own build-state.

### Shard A — the authority IS a linear port (its type is the power)
- **What.** The capability *is* a held [[banks/port]]; its port type is the
  authority. This is the substance — every other shard is a facet of *this* type.
- **Home.** the port-set / [[banks/port]]; `lib/ports.chiral` porttypes; P3.
- **Build-state.** CONFORMS. Category-C port membrane E30–E33: `ports.chiral`
  declares opaque linear porttypes, `impl_ports` binds host referents, the checker
  enforces move-only threading. Evidence: `ports.chiral:12–19`,
  `surface.py:108–130, 184`; CONFORMANCE-MAP "Category C port membrane … CONFORMS".
  Do **not** re-document port semantics here — see the sibling **[[banks/port]]**.

### Shard B — non-forgeability = a conjunction of FOUR mechanisms at four tiers
- **What.** You cannot mint a capability you were not given. This is *not* one
  guard; it is four independent mechanisms at four tiers, **and pulling any one
  leaks**:
  1. **the porttype has no constructor** (surface / kernel) — `porttype` declares an
     opaque atom with zero data constructors, so a `Sock` value is *unspeakable* in
     surface syntax; the only way to obtain one is a host-bound `extern`
     (`ports.chiral:3–8`, `surface.py:108–126`, `kernel.py:570`);
  2. **the frozen port set** (profiles / verify) — a profile may use only the named
     crossings it declares; `top_profile` rejects any listed name that is not a
     declared extern or that is pure (`surface.py:183–185`), and the off-manifest
     *violation* check is a `chirality verify` report, not run-time loading — the gate
     holds where verify is run;
  3. **q=1 linearity** (kernel, `on_binder`) — a value of a linear porttype is bound
     with quantity 1, checked at every binder (`is_linear`, `kernel.py:207–218`;
     `on_binder` at Pi/let/lambda, `kernel.py:418, 441, 477`), so a held port cannot
     be *copied* into two authorities;
  4. **the reflective floor** (E45, DECISION) — the boundary below which a running
     chirality cannot reconfigure the port set / judgment core, so you cannot forge by
     *re-editing the rules from inside*.
- **Home.** four homes, one per mechanism: [[banks/port]], [[banks/profile]],
  kernel-linearity, and the reflective floor.
- **Build-state.** Three of four CONFORM/ENFORCED (no-constructor, frozen set,
  linearity — all built, evidence above; ENFORCED here as everywhere on the host
  substrate means against a well-behaved program via the trusted Python checker,
  not an adversary at the Python level — [[trust-boundary]]). The **fourth is
  unbuilt**: the reflective
  floor is `Not built; Sig exposes every seam as mutable Python attrs`, class BUILD,
  **DECISION-gated on edge 5** (draw the A/B line first) — CONFORMANCE-MAP E45 (lines
  47, 128). So non-forgeability is *complete against a program* but *not yet against
  a running chirality that could rewrite its own `Sig`*; that last tier is §5 residue.
- **⚑ Re-counted against B1, 2026-08-25 — the "three of four" is a Python count.**
  `.planning/AUTH-HARNESS-MAP.md` §2 ran each mechanism against the compiler that
  compiles everything: **two** are real there (no-constructor, q=1 linearity);
  mechanism 2, the frozen port set, **parses/judges/stores natively but its
  enforcement half is unmeasured** (`parse.chiral:1276–1287` does dispatch
  `profile`/`target` since E2's slice landed at `eb7ec6a`, and
  `parse.chiral:722-723` says in as many words that *"this slice PARSES + JUDGES +
  STORES; ENFORCEMENT (emit refusing an off-manifest crossing) … is not here"*);
  mechanism 4 is unbuilt. And there is a **fifth** mechanism this list never
  named — the `->`/`=>` membrane, which is what makes "the only way to obtain one
  is a host-bound `extern`" *checkable per def* — and it is oracle-only too: a
  `->` def may call an `=>` one and the crossing happens (**E171**;
  [[banks/effect-and-alarm]] §5d). The scope sentence above ("via the trusted
  Python checker") was already the caveat; this bullet says what the count becomes
  once the oracle is gone, which is the whole point of the retirement.

### Shard C — attenuation = subtyping ∘ refinement ∘ the value-index
- **What.** Narrowing a capability to a weaker one — `(Pool n)` → `(Pool m)` with
  `m ≤ n`, or a port offering fewer operations. Attenuation is **subtyping**: "the
  attenuated port's type is a subtype offering less, never more. Widening is not
  expressible" ([[permission-model]] §Attenuate). Where the narrowing is *numeric*
  (a smaller pool bound), the `m ≤ n` obligation is a **refinement entailment** (E9)
  over the port's **value-index** (`(porttype Pool (n I64))`, `ports.chiral:19`),
  **not** nominal subtyping.
- **Home.** the checker's `subtype` relation (`kernel.py:321`) composed with the
  refinement fragment (E9, `refine.py`) over the value-indexed porttype
  (`ports.chiral:19, 48–50`).
- **Build-state.** **The one live softness.** The subtype *mechanism* is IMPLEMENTED
  (`kernel.py subtype`, cumulativity via subtype) but is **not yet applied to grant
  narrowing** ([[status-ledger]] line 52; CONFORMANCE-MAP lines 84, 123: "subtype
  mechanism present but NOT applied to grant narrowing"). The refinement fragment is
  built as the named I64 literal/bare-var fragment (E9; map class REFACTOR toward
  the full-predicate end-state) with the arithmetic /
  inter-var extension SEEDED (E9-var, EXTEND). So attenuation is a **present-but-
  unapplied EXTEND**, not a genuine BUILD from zero: every piece exists, the wiring
  from `subtype` to grant-narrowing is the missing step. `permission-model.md`'s
  "everything that does the work already exists" is flagged as a **stale overclaim**
  (CONFORMANCE-MAP line 84), not a live design fork.

### Shard D — delegation = Move locally, a different mechanism-set over a node boundary
- **What.** Passing a capability on. **Locally** this is **Move**: linear transfer,
  the default — "the port leaves one holder and arrives at another; it is never
  copied" ([[permission-model]] §Move). *Whether* a holder may delegate at all is
  itself an attenuable dimension of the port type ([[permission-model]] §Delegate).
  **Across a node boundary** it is a *different* mechanism-set: the linear port must
  cross the wire, which is fd-passing (SCM_RIGHTS) — `sock-send-fd` moves a linear
  `Fd` *through* a `Sock` to another node (`ports.chiral:39`), and the capability's
  transit is carried by **adhikara**, the protocol both broker halves speak
  ([[modules-broker]] §adhikara; [[node-architecture]] "Adhikara carries the
  capability over the wire").
- **Home.** local: kernel linearity (Move). Cross-node: the fd-passing crossing
  (E30), the adhikara protocol ([[modules-broker]]), the node model
  ([[node-architecture]]), and the cross-node alarm edge (edge 17).
- **Build-state.** Local Move CONFORMS/ENFORCED (linearity, the *only* built grant
  operation — [[status-ledger]] lines 42, 81–82). `sock-send-fd` is declared and its
  crossing CONFORMS (E30, `ports.chiral:39`). But **delegation-beyond-Move is
  designed-only**: adhikara is docs-only ([[status-ledger]] line 85), catalogued as
  **E61** (the CONFORMANCE-MAP row at line 141 predates the assignment); its
  capability-type correspondence was **resolved in direction 2026-07-22** (edge 7 —
  remaining: the E61 authority-style choice and the wire lowering, see §5.3);
  cross-node alarm propagation is open (edge 17).
  So delegation is *built at the linear-Move floor, designed at the node boundary*.

### Shard E — revocation = a customer of the effect/alarm system, not a capability primitive
- **What.** Withdrawing a capability already held. This is **not a capability
  mechanism**. A revoked linear port becomes a **dead port** whose *next crossing
  raises an [[banks/effect-and-alarm|alarm]]* — a typed effect on the membrane, not
  an out-of-band exception — answered by a **counter-effect** (quarantine / halt /
  re-derive), mediated by the broker (E43). [[permission-model]] §Revoke gives the
  three shapes by how the grant is held: a linear grant is *reclaimed* (Move
  reversed); a scoped grant *expires* (a deadline whose expiry fires a counter-
  effect); copied evidence is *re-keyed* (derive-not-store: the next derivation
  excludes the revoked holder).
- **Home.** the effect/alarm system ([[banks/effect-and-alarm]]) as the mechanism;
  the component broker (E43, [[modules-broker]]) as the mediator; not a home of its
  own. **This is the spine cross-cut** — see §3.
- **Build-state.** DESIGNED, no code. Revoke rides on the broker's grant/revoke/audit,
  which is `spawn / teardown / link-at-load only` ([[status-ledger]] line 73), atop
  the E40 capability model of which only Move is built. The broker's 4-part
  AUTH/AUDIT decomposition is itself **DECISION-gated on edge 8** (CONFORMANCE-MAP
  E43, line 126). So the whole revocation chain is a *design* chain (§5).

### Shard F — every capability carries a split-role TIER in its type
- **What.** Where a capability's trustworthiness cannot be *proven* (a proprietary
  blob, foreign hardware, a solver that emits no proof), the type carries an explicit
  **tier** — proprietary-contained-at-floor / audited / verified — so you always know
  where trust actually rests ([[split-role]] §"Tiering is the spine"). A member is
  contained at the floor by holding *no egress port*; the tier is a **visible typed
  gap** (edge 4), so under-reaching is a type error, not a silent hole.
- **Home.** [[split-role]] / [[banks/evidence-and-split]]; the tier carried in the
  type (edge 4).
- **Build-state.** DESIGNED (docs-only). The split-provider / split-role is BUILD,
  gated on edge 4 (tier auto-selection) + edge 11 (independence), catalogued as
  **E54** (the CONFORMANCE-MAP row at line 137 still says needs-E-number and
  predates the assignment). Containment-at-the-floor *reduces to* the
  port-set (Shard A, built); the *tier-in-the-type* machinery is the unbuilt part.

### Shard G — lifecycle / custody = the component broker (grant / revoke / audit)
- **What.** The grant/revoke/audit *lifecycle* of live capabilities against the
  running process population — "dynamic grant and revoke, audit reconciliation
  against live state … a typed supervisor over untyped runtime reality"
  ([[modules-broker]] §"broker, component"). This is the stateful custody a
  compile-time port check cannot decide.
- **Home.** the **component broker (C)**, E43 ([[modules-broker]], and the supervisor
  shard of the sibling **[[banks/runtime]]**).
- **Build-state.** DESIGNED, thin-slice built. Only spawn / teardown / link-at-load
  exist ([[status-ledger]] line 73); grant / revoke / audit are intent, gated on
  edge 8. Adhikara is the protocol its static and dynamic halves must agree on
  (edge 7). See [[banks/runtime]] §"supervisor" for the runtime-side of this shard —
  do not re-document it here.

---

### Shard H — reflection without authority (the erased witness)

**Home.** scriba (the port-viewer) + the `effects`/quantity floor. **Build-state:**
DESIGNED, shovel-ready (its prerequisite is *enforced*, not merely designed).

The graph is legible (RUNG2-SECURITY-MODEL §6: "trust is legible in the port graph"),
but legibility needs a *viewer that holds nothing*. The move: authority to **act** is
a cap at quantity 1; authority to **display** rides a **0-quantity binding** of the
same cap — present in the type, erased at runtime, structurally unable to be exercised.
scriba doesn't render the cap; it renders an ordinary datum **indexed by** the erased
graph term (`(data CapView (0 g : CapGraph) …)` — shape sketch), so **a view that
disagrees with the graph it was indexed by does not typecheck**. Fabrication is not
caught; it is inexpressible ([[decision-b-in-type]]: property in the type, not the
packaging). It is **E52's pattern reused** — untrusted producer (scriba) emits an
artifact, the index is the trusted re-check.

**Prerequisite (satisfied):** the pattern is sound only if erasure is real — a q=0
position must be effect-free. It **is enforced**: `effects.py:48` `erased_allow` forces
any quantity-0 position pure (`EMPTY_ROW`), corroborated by
[[effect-and-alarm]]. Only the *prose statement* of the rule into `open-edges` edge 2
is outstanding (doc-debt item 3), not the enforcement.

**Residue (NEEDS-AUTHOR):** *freshness* — typing gives "faithful to a graph," not "to
*the* graph, *now*"; a stale-but-correct view stays expressible. See
`TERMINAL-PORT-DESIGN §8` item 8 (leaning a linear observation token). And the
*witness shape* — `CapView` indexed by a whole `CapGraph` vs per-cap with a
composition rule; **settled: per-cap** (locality; whole-graph is simpler but wrong at
scale).

## 3. Cross-cuts — where a shard of "capability" IS a shard of another concept

This is the highest-value section: the places where refracting "capability" and
refracting some other concept land on the *same* shard. These are exactly the
insights a thin note cannot hold and an agent keeps missing.

**C1 · A capability IS a [[banks/port]] held — Shard A is not two things.** The
outward face of a process is *not* separately "its API" and "its permissions": the
port-set is both. [[vocabulary]]: "capability *is* a port held. Authority is the set
of ports you hold." So there is no capability layer *over* the ports; the capability
bank and the port bank refract the **same shard** from two sides — the port bank
owns the crossing/protocol/linearity mechanics, this bank owns the authority reading
of them. This is also the module bank's cross-cut C1: a module's port-set *is* its
capability set. Do not re-document port mechanics here.

**C2 · Revocation IS a customer of the effect/alarm system (the spine cross-cut).**
Shard E is the deepest chain in the bank and the one that motivated the bank tier.
Revocation is **not** a capability primitive and **not** a broker primitive in
isolation — it is a chain across four homes: **broker** (mediator, E43) → **port
death** (the revoked linear port becomes dead) → **alarm** (the next crossing raises
a typed effect on the membrane, [[banks/effect-and-alarm]]) → **counter-effect**
(quarantine / halt / re-derive). The runtime "does not police at runtime; it arranges
that the *type* of the next crossing carries the failure" ([[banks/runtime]] §3). So
"chirality needs a permission-revocation mechanism" is answered by *four existing homes*,
most of them designed, none of them a new "revocation module." See
[[banks/effect-and-alarm]] for the counter-effect end.

**C3 · Attenuation IS refinement entailment (E9), not nominal subtyping.** Shard C
and the concept *refinement* land on the same shard for the numeric case: narrowing
`(Pool n)` → `(Pool m)` is discharged by proving `m ≤ n` in the refinement fragment
(E9), over the porttype's value-index (`ports.chiral:19`) — the *same* `entails`
machinery that bounds-checks a pool write (`mem-put-checked`, E22). Attenuation of a
memory capability and a bounds-check on that same memory are **one mechanism**. The
non-numeric case (fewer operations) is plain `subtype` (`kernel.py:321`). Both exist;
neither is yet *wired to grant-narrowing* (Shard C build-state).

**C4 · Delegation-over-a-boundary IS the node model + fd-passing (Shard D ↔ node).**
Local delegation is Move (linearity); cross-node delegation is the *same authority*
crossing the mesh, which is the node architecture's "distribution is native" claim
made concrete by `sock-send-fd` (SCM_RIGHTS, E30) and adhikara
([[node-architecture]] §"Distribution is native"). So "how do I pass a capability to
another process/machine" is not a capability feature to invent — it is the node
model's port-to-a-peer plus the fd-passing crossing (built) plus adhikara (designed,
edge 7). The *hard one* is the cross-node case, not the local Move.

**C5 · Every capability's tier IS the split-role's tier (Shard F ↔ [[split-role]]).**
When a capability's trustworthiness is *unprovable*, the tier it carries (proprietary-
contained-at-floor / audited / verified) is exactly the `Split` role's per-axis tier
([[split-role]] §"Tiering is the spine"). A capability that needs redundant evidence
does **not** build a split — it declares a requirement for a `Split` provider and the
profile supplies a conforming one. So "this capability holds cross-checked authority"
is the same shard as "the profile supplies a split provider the module requires"
([[banks/module]] C2). Containment-at-the-floor is the port-set (Shard A) reused;
the tier-in-the-type is the split-role's own (docs-only, edge 4).

**C6 · Non-forgeability IS a four-home conjunction, not a kernel guard (Shard B).**
The tempting misfire is "put unforgeability in the kernel." But it is *distributed*
across four homes precisely so no single artifact concentrates the guarantee
([[node-architecture]] "Not kernel-centric": trust is distributed, not in one
privileged core). No-constructor is surface/kernel, the frozen set is the profile,
q=1 is the linearity check, the floor is E45. This is the capability-shard of the
same anti-concentration argument the checker makes for itself
([[decision-split-checker]]): the guarantee is a *conjunction across homes*, and the
one home not yet built (the reflective floor) is named, not hidden.

**C7 · "Authority stratified by altitude" IS the lowering connector's obligation.**
A capability is over an *operation* at the upper level and over a *resource* at the
metal; a guard on the command must **lower** into constraints on the resource access
it entails, or it is theater ([[permission-model]] §"Authority is stratified by
altitude"). What discharges that is not a new check: it is the type-preserving
lowering connector + `preserve-check` ([[banks/module]] Shard 3), which proves each
drop opened no hole. So "does my permission actually reach the hardware?" is the
lowering connector's job (E16, built), reached *through* the capability's altitude
span.

---

## 4. Native → chirality translation (the misfire → the correction)

For each conventional monolith, the misfire an agent makes and the shards it
actually decomposes into.

**"You need a capability / permission system (rings, ACLs, a permission table)."**
→ Correction: authority is already a **linear port held** (Shard A, built, E30–E33)
whose *type* is the authority; there is no table because there is no owner
([[node-architecture]] "there is nowhere for a kernel to be"). "Who may do what" is
set-membership over held ports, checked at stage time. Genuinely-new shard: none for
the *held* authority; only the *lifecycle* (grant/revoke/audit) is designed-only
(Shard G, E43).

**"You need a file descriptor / handle type with a permission bit."**
→ Correction: `Fd` (and `Sock`, `Pool n`) *are* linear porttypes (`ports.chiral:12–19`);
the "permission" is the port *type*, not a bit beside it. Passing an fd to another
process is `sock-send-fd` (SCM_RIGHTS, E30, built); passing it linearly locally is
Move (built). No handle-with-flags is owed — the flags a descriptor carries are
refracted into the type (attenuation, Shard C) and the linearity (non-copy, Shard B.3).

**"You need object-capabilities / an ocap reference you can hold and pass."**
→ Correction: chirality *is* an ocap system — "authority is which ports you hold, what
you possess. Capability, not class" ([[node-architecture]]). The ocap reference is a
linear port (Shard A); unforgeability is the four-mechanism conjunction (Shard B);
delegation is Move + fd-passing + adhikara (Shard D); attenuation is subtyping over
refinement (Shard C). The nearest prior art (seL4) is a *kernel* that checks caps at
runtime; chirality checks in the type at stage time, "complete mediation with no
mediator." Genuinely-new: the cross-node delegation protocol (adhikara, edge 7) and
revocation (§5) — the *local* ocap story is built.

**"You need an ACL / an owner that adjudicates access."**
→ Correction: there is **no owner** — "nothing owns the substrate, because ownership
is not one of the two nouns" ([[node-architecture]]). An ACL row is refracted away:
the authority is possession of the port, and no gate consults a list. What an ACL
*bundles* — subject, object, right — is (subject = the holder, decided by who holds
the linear port), (object = the substrate behind the port), (right = the port type).
No ACL mechanism is owed; it is a strictly weaker encoding of held linear ports.

**"You need a permission-revocation mechanism."**
→ Correction: revocation is **not a mechanism of its own** (Shard E, C2). It refracts
into broker (mediator, E43) + port death + alarm-effect + counter-effect, mostly in
*other* homes. Naming "a revocation module" is the misfire; the honest statement is
"the broker's grant/revoke/audit is designed-only (edge 8), and when built it drives
the *existing* alarm system." Genuinely-new: the broker internals (§5), not a
revocation primitive.

**"You need capability attenuation / rights-narrowing you can call."**
→ Correction: attenuation *is subtyping over refinement* (Shard C, C3) — the
mechanism exists (`kernel.py subtype`, E9 refinement) but is **not yet wired to
grant-narrowing**. This is a *present-but-unapplied EXTEND*, not a missing feature:
the honest statement is "the subtype relation exists; applying it to narrow `(Pool
n)`→`(Pool m)` is the unshipped wiring," not "chirality lacks attenuation."

---

## 5. What's genuinely new / unbuilt — the honest residue

Only the residue, with gradients preserved and tiers named. Nothing here is rounded
to done or to undone.

1. **Grant-narrowing (attenuation) — present-but-unapplied EXTEND (Shard C).** This
   is the **one live softness** and the most important line in the bank. The subtype
   mechanism is IMPLEMENTED (`kernel.py:321`) and the refinement fragment is built
   (E9), but the wiring that applies `subtype` to *narrow a held capability* is not
   yet in place (CONFORMANCE-MAP lines 84, 123; [[status-ledger]] line 52). Gradient:
   **not a BUILD from zero** — every piece exists; it is an EXTEND that connects two
   built things. `permission-model.md`'s "everything that does the work already
   exists" is a **stale overclaim** about *application*, not a false claim about
   *mechanism*.

2. **Revocation — DESIGNED, no code (Shard E / C2).** The whole chain (broker →
   port death → alarm → counter-effect) is a *design* chain. The broker's
   grant/revoke/audit is `spawn/teardown/link-at-load only` ([[status-ledger]] line
   73), atop E40 of which only Move is built, and the broker's 4-part decomposition
   is **DECISION-gated on edge 8** (CONFORMANCE-MAP E43). Gradient: the *alarm system
   it will drive* is a separate, further-along home ([[banks/effect-and-alarm]]); the
   revocation-specific code is genuinely absent.

3. **Delegation beyond Move — DESIGNED at the node boundary (Shard D / C4).** Local
   Move is ENFORCED and `sock-send-fd` CONFORMS (E30), but adhikara — the protocol
   that carries a capability over the wire — is docs-only, catalogued as **E61**
   (2026-07-21 extension; the CONFORMANCE-MAP row at line 141 predates the
   assignment), its capability-type **correspondence resolved in direction
   2026-07-22** (edge 7: Adhikara = the discipline lowered onto a B channel,
   safety local-only; remaining = the E61 authority-style choice and the wire
   lowering). Cross-node alarm propagation (edge 17) is
   the open residual of the distributed case. Gradient: the *local* delegation floor
   is built; the *cross-node* mechanism-set is designed.

4. **The reflective floor — DECISION, no code (Shard B.4).** The fourth
   non-forgeability mechanism — the boundary below which a running chirality cannot
   reconfigure the port set / judgment core — is `Not built; Sig exposes every seam
   as mutable Python attrs`, class BUILD, **DECISION-gated on edge 5** (draw the A/B
   line first): direction resolved, exact line **not drawn**, no code (E45,
   CONFORMANCE-MAP lines 47, 128). Gradient: unforgeability is *complete against a
   program*, *incomplete against a self-modifying running chirality* until the floor
   lands. This is the one tier of Shard B that is genuinely open.

5. **The tier-in-the-type / split-provider — DESIGNED (Shard F / C5).** Carrying a
   capability's trust tier (proprietary-contained / audited / verified) as a *typed
   gap* is docs-only, gated on edge 4 (tier auto-selection) + edge 11 (independence),
   catalogued as **E54** (split-provider, 2026-07-21 extension; the CONFORMANCE-MAP
   row at line 137 predates the assignment). Gradient:
   containment-at-the-floor *reduces to* the built port-set (Shard A); only the
   tier-in-the-type machinery is unbuilt.

6. **Component-broker lifecycle / custody — DESIGNED (Shard G).** grant/revoke/audit
   over the live process population is E43, DECISION-gated on edge 8; only
   spawn/teardown/link-at-load exist. Named here so no one re-files "a capability
   custody module" as missing — it is the broker, mostly designed
   ([[modules-broker]]), and it is the same artifact as the [[banks/runtime]]
   supervisor shard.

Gradient summary: the capability's *substance* (Shard A) and three of the four
non-forgeability tiers (Shard B) are ENFORCED; **local** Move is the one built grant
operation; attenuation is present-but-unapplied (the live softness); and revocation,
cross-node delegation, the reflective floor, the trust-tier, and broker custody are
the genuinely designed-only residue — each tied to a specific E# or DECISION edge,
none of them a phantom "capability system" to build from scratch.

---

## 6. Relational anchors — thin notes that should link INTO this bank

These `docs/` notes each hold one facet of "capability" and should point here for
the depth:

- [[vocabulary]] / [[glossary]] — the `capability`, `grant (sidehand)`, `port`,
  `Adhikara` entries (the definitional source; §1).
- [[permission-model]] — the four grant operations (Move/Attenuate/Delegate/Revoke),
  altitude stratification, and the "stale overclaim" this bank corrects (Shards C–E,
  C7). It links here for the honest build-state.
- [[banks/port]] — a capability *is* a port held; the port bank owns crossing /
  protocol / linearity mechanics (Shard A, C1). Do not re-document ports here.
- [[banks/effect-and-alarm]] — the alarm + counter-effect end of the revocation chain
  (Shard E, C2, the spine cross-cut).
- [[node-architecture]] — capability-not-class, distribution-native delegation, no
  owner (Shards A/D, C4, C6).
- [[modules-broker]] — the component broker = grant/revoke/audit lifecycle and
  adhikara (Shards E/G).
- [[split-role]] / [[banks/evidence-and-split]] — the trust tier a capability carries
  (Shard F, C5).
- [[decision-b-in-type]] — why B-ness (and hence linearity) lives in the type, not
  the packaging (Shard B.3 foundation).
- [[banks/memory]] — `(Pool n)` as a value-indexed capability; attenuation-as-bounds
  is the shared shard (C3).
- [[banks/module]] — a module's port-set *is* its capability set (module C1); the
  split a module requires (module C2).
- [[banks/runtime]] — the supervisor shard = the broker; the runtime-side of
  revocation (Shard G).
- [[status-ledger]] / `records/conformance-map.md` — the authority for every
  build-state above (E30/E40/E43/E45/E9, edges 4/5/7/8/11/17).
- [[open-edges]] — edges 5 (reflective floor), 7 (adhikara), 8 (broker), 11
  (independence), 17 (cross-node alarm).
