# Decision docket

The seven author-calls the conformance map (`.planning/audit/CONFORMANCE-MAP.md`)
found gating real code. A worked-example written against an undecided mechanism
blueprints the wrong shape, so these are the prerequisites the worked-example series
and the refactor pass wait on. Each is framed as a **gradient**, not a yes/no — the
call is where on the spectrum to land and why. Ordered by leverage (how much each
unblocks). Resolution state is marked per item in place (banners + the closing
section): D1–D2 resolved, D3–D6 resolved (homed 2026-07-27), D7 narrowed to a budget
call — what remains to work through is the named residue under each. **D8–D9
(added 2026-07-25) were a second class: two build-obligation element-minting calls
the edge-walk surfaced — both RESOLVED 2026-07-26 (Batch A) → E73 (outbound
confinement) + E74 (tier carrier), with edge 6 → E75, all in catalog §XI.**

Convention: **D#** for docket order; each notes its **edge**, the **E-elements it
gates**, and where the design context lives.

---

## D1 — Effect mechanism · edge 16 · gates E39, E26, E51 · **RESOLVED 2026-07-21**

> **Resolved:** `docs/decision-effect-facets.md`. Landed at a strengthened form of
> the one-shot middle: two facets (possession = linear ports held; exercise = the
> effect row, inferred from crossings) joined by construction via ambient-cap
> reification; handlers are the process at the other end of the port,
> CPS-elaborating to linear closures (zero-new-kernel-forms: **verified
> 2026-07-22**, `examples/E39-effect-row.md`); resumption multiplicity is **graded by the continuation's QTT
> quantity** (captured linear ports force one-shot — the committed-crossing
> argument below held; port-free capture permits multi-shot, so backtracking
> survives) rather than decreed; abort discharges by synthesized cancel.
> Alarms are crossings (dated amendment in `decision-graded-kernel`). Catalog
> flips: E39/E26/E51 unblocked (PLAN-2026-07-21-effect-algebra.md), E69–E71
> minted for the lowering reach. The fork text below is retained as the
> decision's input record.

**The fork.** The `eff` slot is one bool today (pure `->` vs process `=>`). The design
wants it to carry an algebra. Two mechanisms, and they are genuinely different systems,
not two spellings of one:

- **Algebraic effects with resumable handlers** (Koka/Frank/Eff lineage) — effects are
  operations; a handler can *resume* the computation. Richer control (generators,
  backtracking, async fall out); heavier metatheory; the totality/linearity interaction
  is subtle (a resumption re-enters a linear scope).
- **Typed result rows** (row-typed effect sets, no resumption) — an effect is a *tag in
  a row* on the arrow; "handling" is subtraction from the row; no re-entry. Lighter,
  composes cleanly with linearity and the membrane, but cannot express resumable control.

**Why it's the keystone.** It gates the E39 refactor (conv equality → row subsumption,
the three membrane seams, surface's single-effectful-arrow rule, the Pi field type — all
together), and downstream **E26** (alarms as a typed counter-effect need the effect row
to name them) and **E51** (the sys-face linkage threads `allow_eff` through the same
seam). Deciding D1 unblocks the entire effect/self-host lane at once.

**The gradient to land on.** How much control power does chirality actually need at the
membrane — is a resumable handler load-bearing for anything in the roadmap (the
live-environment? the broker?), or is subtraction-from-a-row enough, buying clean
composition with linearity/totality at the cost of resumption? Context:
`docs/open-edges.md` G6/edge 16, `docs/error-and-alarm.md`, `docs/decision-graded-kernel.md`.

## D2 — Backend fork · Fable F7/C1 · concerns E19 · **RESOLVED 2026-07-22**

> **Resolved:** supersede, not stopgap — `docs/decision-backend.md` reconciliation
> section. The built chirality Mach path (emit-core / Mach / conforming machines /
> asm-reloc) IS the backend; LLVM/Cranelift/QBE never enter the trusted path and
> remain Tier-F/O cross-check oracles per the inspiration policy. New targets =
> new conforming `Mach` values admitted under floor-agreement. open-edges'
> first-backend bullet, status-ledger's stale-claims row, modules-lowering §Backend,
> and view-implementation all flipped. No performance claim made. Fork text below
> retained as the input record.

**The fork.** `docs/decision-backend.md` is marked *settled* and prescribes "use LLVM or
Cranelift as a codegen library." The build uses neither — it hand-emits x86-64 from chirality
(`native.py` + `lib/mach-x64.chiral`), which the map rates the **strongest P4 exemplar**
in the tree. So a settled decision's mechanism is contradicted by the build, and
`open-edges` still lists the backend choice as *open*. Three states, one question.

**The gradient to land on.** Does the hand-emitted path **supersede** the decision
(re-settle: own typed backend, no LLVM/Cranelift in the TCB ever — the built path is
arguably *more* aligned with the decision's own principle than its named mechanism), or
is it a **stopgap toward** an eventual codegen-library backend (reopen, and the E19 lib
carries a large blast radius later)? This is also a *trust* question, not just tooling:
re-settling decides whether LLVM/Cranelift ever enter the TCB story. Context:
`docs/decision-backend.md`, `docs/status-ledger.md` (stale-claims section), `CONTENTS.md`.

## D3 — Reflective floor line · edge 5 · gates E45, E58 · **RESOLVED 2026-07-27 → `docs/decision-reflective-floor.md`**

> **Direction (D-walk, 2026-07-22):** all dynamism is mesh dynamism —
> spawn/teardown churn, never live mutation of a running judgment. The drawn
> line: a runtime's judgment (kernel-core + kernel-spec) is *staged-in, never
> granted-to*, and not swappable after staging completes; E45's mechanism
> reduces to freezing `Sig` at link/install completion. Succession wall: no
> uncertified succession — the stager's core certifies a successor's core
> against kernel-spec before it runs; a mis-checked child degrades to a B-blob
> bounded by its granted ports. Residues: home decision note owed; state
> handover across relaunch (rides edge 14); staging economics. Recorded in
> open-edges 5 and `SELF-HOST-PLAN.md`. Fork text below retained as input
> record.

**The fork.** P1's second clause — the capability kernel is *expressible* yet not
*reconfigurable from within* — has a resolved *direction* but no drawn *line*. Today
`Sig` exposes every seam (`ext_check`, `rules`, hooks) as a mutable Python attribute, so
running chirality could in principle reconfigure the judgment core; the reflective floor is
the boundary that forbids exactly that.

**The gradient to land on.** Where does the A/B line fall — what precisely is the trusted
core that running chirality *cannot* certify or mutate, versus what it may reflect over? Draw
it too high and self-modifying code forges authority; too low and the live-environment
(the forcing workload) can't do useful metaprogramming. Gates E45 (the immutability
mechanism) and E58 (reflect-typed staging). Context: `docs/live-environment.md`,
`docs/open-edges.md` edge 5, PRINCIPLES P1.

## D4 — Whole-assembly conformance · edge 18 · gates E44 · **RESOLVED 2026-07-27 → `docs/decision-profiles.md` "The conformance mechanism"**

> **Direction (D-walk, 2026-07-22):** no global mechanism, no one answer —
> per-seam handling by the existing connectors. In a dynamically-staged mesh
> "the whole assembly" is never an analyzable object, so a target property is
> (1) signature-compositional (carried in interfaces, discharged by subtyping),
> (2) node-local at single-node stage time (the only closed composite — the
> built `(total)` clause), or (3) a named gap (split-role's "do what you can,
> named"). Cross-node claims ride the bridge as certificate evidence elements
> over Adhikara (couples D6). Residue: the per-property catalogue (which
> element, which rung) and the tier-weight composition rule (unbuilt). Fork
> text below retained as input record.

**The fork.** Profile conformance today checks named-crossings + the `(total)` clause.
The design wants it to also cover non-interference / tier-weight compositionality across
a whole assembly. The open part: **which** target properties are compositional (provable
by cheap subtyping at each boundary) versus which need a dedicated global argument.

**The gradient to land on.** How much does the profile system attempt automatically
(default-attempt interaction proofs, cheap-subtyping where it works) versus punt to an
explicit whole-assembly argument? Sets what E44 (security trio, esp. IFC) can lean on.
Context: `docs/open-edges.md` edge 18, `docs/decision-profiles.md`, `docs/view-security.md`.

## D5 — Broker decomposition · edge 8 · gates E43 · **RESOLVED 2026-07-27 → `docs/decision-brokers.md` "Resolved (D-walk)"**

> **Direction (D-walk, 2026-07-22):** not a bespoke four-part architecture.
> The component broker is the general bridge elaborator
> (decision-bridge-elaborator) instantiated over the live-population
> B-referent (decision-b-in-type: quarantine in the signature, ordinary
> packaging, no privilege), per-runtime by self-similarity — each runtime's
> configuration carries its own broker over its own population; no global
> registry is expressible. Internals = evidence-element choices
> (audit-reconcile as the load-bearing verify; freshness; attestation) plus
> the counter-effect dispatch set. Dynamic grant/revoke stay (live-environment
> forcing function): a grant to a live node is a port move over an existing
> crossing; its protocol content is D6's. Residue: pick the evidence elements;
> audit dump D13's four-part material for any job the elaborator framing
> cannot seat. Fork text below retained as input record.

**The fork.** The component broker is spawn/teardown/link-at-load today. The design names
a 4-part AUTH/AUDIT internal decomposition, undecided. The internals can't build right
until the decomposition is fixed.

**The gradient to land on.** What are the four parts and where does authority actually
sit — how much is grant/revoke/audit a broker responsibility versus pushed into the
capability-type discipline (couples D6). Context: `docs/modules-broker.md`,
`docs/permission-model.md`, `docs/open-edges.md` edge 8.

## D6 — Adhikara correspondence · edge 7 · gates E61 · couples E40 · **RESOLVED 2026-07-27 → `docs/decision-brokers.md` "Resolved (D-walk)"**

> **Direction (D-walk, 2026-07-22):** Adhikara is the capability-type
> discipline *lowered onto a B channel*, not a sibling protocol needing
> agreement. Upper face = exactly the type operations (four grant ops,
> crossings, property-certificate presentation, alarm signalling — closed and
> enumerable); below it, the lowering connector with "translation
> preserves-or-reduces rights" as its preserve-check; confidentiality and
> integrity from the bridge's confine-outbound / verify-inbound (the wire is
> B). **Zero-trust completion (author-settled): no foreign agreement is ever
> load-bearing for safety** — authority is what a membrane honors;
> exactly-once and no-forge are local linear accounting + derive-not-store at
> the authority's home; comms failure costs progress only (in-doubt grants
> discharged by local expiry/re-key counter-effects); hostile revocation =
> stop deriving, the peer never consulted. Rendezvous/acks demote to liveness
> engineering (edge 14's wire coupling softens accordingly). Enumerated E61
> choice left: home-referenced authority vs offline-verifiable attenuation
> chains — both zero-trust-clean. Fork text below retained as input record.

**The fork.** The claim is that the Adhikara capability protocol maps *exactly* to the
capability-type discipline (so distribution is native — a remote capability is just a
port you hold). The mapping is unpinned.

**The gradient to land on.** How tight is the correspondence — is every protocol message
a capability-type operation (clean, but constrains the protocol), or is there protocol
machinery with no type-level counterpart (looser, but reintroduces an ungoverned path)?
Context: `docs/decision-brokers.md`, `docs/permission-model.md`, `docs/open-edges.md` edge 7.

## D7 — Bootstrap-floor internals · edge 11 · gates E62 · **RESOLVED-IN-DIRECTION 2026-07-26 (no author fork remains)**

> **Narrowed (D-walk, 2026-07-22), not resolved:** the framework is settled by
> split-role (independence = typed provenance-disjointness; attestable axes
> enforced, assertable ones demanded-and-audited, never absolute), and the
> checker's certificate exit means agreement guards only this floor. What
> remains is an **author budget call**: which provenance axes are bought
> versus asserted-and-named for the floor's N runtimes. Recommendation on
> record (a recommendation, NOT a decision): DDC (E53) plus toolchain
> diversity is the affordable load-bearing rung; authorship diversity is
> honestly named not-yet-real while there is one author. Fork text below
> retained as input record.

> **Reframed 2026-07-26 (the 2026-07-22 "provenance-axis budget for N runtimes"
> perspective was off — flattened two concerns into one fleet).** The floor's
> trust has **two distinct levels, coupled by spec-size, not identical**:
>
> 1. **Artifact-faithfulness (auditability).** Does the shipped floor faithfully
>    implement the spec? Guarded by **re-derivability**: re-derive from a small
>    spec in a *different* toolchain and let DDC (E53) bit-identity convict a bad
>    binary. On-demand, offline, point-in-time; the independence axis is the
>    diversity of the *re-derivation*. This half is **relocated onto spec-size**
>    by the Batch-B decisions (E71 spec-as-golden + E72 weekend-reimplementable +
>    E53 DDC) — it does *not* need a standing diverse
>    fleet, so most of the old "how many runtimes" burden dissolves here.
> 2. **Operational agreement (execution on live inputs).** On *this* input, does
>    the floor compute the right observable? Guarded by **either** live N-way
>    runtime diversity (compare running floors) **or** a total floor-agreement
>    proof (translation validation over the frozen core). Per-execution; the
>    independence axis is the diversity of the *running executors*.
>
> **Where re-derivability stops** (why this is not a collapse): re-derivation
> checks *artifact vs spec* — it says nothing about whether the **spec itself** is
> right, nor about an **input-dependent divergence** that only manifests at
> runtime unless the floor-agreement proof is total. So level 1 cannot absorb
> level 2.
>
> **The coupling:** a small spec (E52/E72) helps *both* — cheap re-derivation
> *and* a small-enough core to prove floor-agreement over. Spec-size is the shared
> enabler, which is why the two feel like one but are not.
>
> **Resolution (2026-07-26): no author fork remains — the level-2 "fork" was a
> phantom.** Each level goes to its proper home:
>
> - **Level 1 is D7's, and it resolves to re-derivability.** Bootstrap-floor trust
>   is a small spec re-derivable in a *different* toolchain + DDC (E53) bit-identity
>   — not a standing diverse fleet. The re-derivation's provenance is
>   toolchain-diverse (bought via DDC); authorship-diversity is named not-yet-real
>   while there is one author (split-role "do what you can, named"). That is the
>   recommendation on record, now on the corrected axis. Pending only E71
>   confirmation (spec-as-golden makes the spec the object re-derived against).
> - **Level 2 was never D7's.** Operational agreement lives in
>   `docs/floor-agreement.md`, already answered: **collapse → validate → fuzz**,
>   offline / per-compile (translation validation carries a proof; no live runtime
>   fleet). There is no "how many runtimes at runtime" question for D7 to own.
>
> So D7 closes in-direction: bootstrap independence = re-derivability + DDC,
> toolchain-diverse, authorship honestly named. The residual is **build** (E62) and
> **E71 confirmation**, not an author call. (Any future "minimum rigor to ship a
> floor" question is a floor-agreement refinement, not D7.)

**The fork.** The unverifiable base is to be a cross-checked set of tuned runtimes, with
safety by agreement over the residue. Open: how many runtimes, how independent, and their
relation to the runtime supervisor (E42).

**The gradient to land on.** The real risk named in the map: *shared-compiler residuals
may void agreement-as-evidence* — if the N runtimes share a toolchain, their agreement
proves nothing. So the call is how much genuine independence (diverse toolchains/authors,
D-level of DDC E53) is bought versus asserted. Context: `docs/floor-agreement.md`,
`docs/split-role.md`, `docs/open-edges.md` edge 11.

---

## D8 — Outbound confinement element (**E73**) · edges 14/17/2/15 · gates E44/E55 as consumers · **RESOLVED 2026-07-26 → E73 written (Batch A)**

> **Origin: the 2026-07-25 edge-walk, not the map audit.** The outbound half of the
> membrane — A emits into B only *confined* (no live-capability leak, exposure
> window bounded, encrypt-if-secret; dual to the built `bridge.verify` inbound
> half) — is **not built** (CONFORMANCE-MAP "Outbound confinement not built";
> `docs/banks/port.md` Shard 5, the port's largest unbuilt shard) and has **no
> dedicated E#**; it only "overlaps" E44 (the IFC property) and E55 (evidence
> bridges). Four edges independently reduce to it: 14 (a moved continuation must
> not leak capabilities across the crossing), 17 (alarm-visibility tier = the
> confinement tier of the evidence), 2 (a declassifying crossing *is* an
> outbound-confinement act), 15 (an irreversible outbound effect degrades to
> detect-and-account because nothing confines it before it escapes).

**The call (roadmap scope, author-tier).** Mint a dedicated mechanism element for
the outbound-confinement membrane, with E44/E55 as its consumers — or leave it
smeared across them. **Reconciliation (2026-07-26):** the id **E73 is already
reserved** for exactly this ("E73 outbound-confinement mint" in HANDOFF's triage
pile; "security-completion wave E73/E44/E59/E60" in LANE-5) but was **never written
into the catalog** (which stops at E72). So this call is concretely "ratify and
write the reserved E73 row," not "pick a fresh number." Resolving it = a
`SELF-IMPLEMENT-CATALOG.md` E73 row + a CONFORMANCE-MAP element-id.
Recommendation on record (a recommendation, NOT a decision):
**mint it** — four independent edges converging on one unbuilt mechanism is the
signature of a real element, and the property-elements (E44 IFC, E55 evidence)
*consume* it rather than contain it. Context:
`.planning/BUILD-OBLIGATIONS-2026-07-25.md`, `docs/banks/port.md` Shard 5,
`docs/open-edges.md` edges 14/17/2/15.

---

## D9 — Tier carrier element (**E74**) · edges 4/17/18 · couples E44 · **RESOLVED 2026-07-26 → E74 minted (Batch A)**

> **Origin: the 2026-07-25 edge-walk.** `docs/split-role.md` settles the tier
> *discipline* (a minimum rung per axis — containment/independence/verdict —
> default-high, under-reach = a typed gap) but not the **carrier**: how a tier is
> actually represented in the type (a refinement predicate? a classification kind?
> a grade factor beside info-flow?). Three edges share this one unbuilt carrier: 4
> (what picks a value's default tier), 17 (alarm-visibility tier), 18 (tier-weight
> composition needs a carrier to subtype at the seam). E44 holds only tier-weight
> *compositionality* (the property), not the carrier.

**The call (roadmap scope, author-tier).** Mint a small carrier element ("how a
per-axis split-role tier rides the type"), consumed by E44 tier-weight and by
alarm-visibility — or state explicitly in E44's row that its scope includes the
carrier. Recommendation on record: **mint or explicitly scope into E44**; do not
leave the carrier implicit while three edges depend on it. Context:
`.planning/BUILD-OBLIGATIONS-2026-07-25.md`, `docs/split-role.md` §Tiering,
`docs/open-edges.md` edges 4/17/18.

---

## Resolving these

D1 (effect mechanism) is **resolved** (2026-07-21, `docs/decision-effect-facets.md`) —
E39, E26, E51 are unblocked. D2 (backend) is **resolved** (2026-07-22, reconciliation
in `docs/decision-backend.md` — supersede; no codegen library in the trusted path).
D3–D6 received direction from the 2026-07-22 D-walk and are now **RESOLVED
(homed) 2026-07-27** — the owed home-notes are written: D3 → new
`docs/decision-reflective-floor.md` (also edge 5's home note); D4 → folded into
`docs/decision-profiles.md` ("Whole-assembly conformance: three classes"); D5 and
D6 → folded into `docs/decision-brokers.md` ("Resolved (D-walk)"). D7 is
**resolved-in-direction** (re-derivability; the banner above). Each still flips its
catalog row when the *mechanism* lands (E45/E58, E44, E43, E61 remain builds).

D8–D9 (2026-07-25 edge-walk) were a different kind: not mechanism-gating calls the
map audit found, but roadmap **element-minting** calls the edge-walk surfaced when
several edges converged on one unbuilt mechanism (outbound confinement, D8; the
tier carrier, D9). **Both RESOLVED 2026-07-26 (Batch A):** the author ratified the
mints — D8 → **E73** (the reserved id, now written), D9 → **E74** (new) — plus the
edge-6 typed ABI-layout abstraction → **E75**. Rows live in
`SELF-IMPLEMENT-CATALOG.md` §XI (added 2026-07-26); each is a mechanism the property
elements (E44/E55) consume, not contain. Source:
`.planning/BUILD-OBLIGATIONS-2026-07-25.md`.

D10 (2026-07-28 syscall-map) is another element-minting call, surfaced when the
syscall coverage map exposed a P1 gap: the floor *performs* ~12 crossings but
does not *govern* the surface — `ti-sys` binds no number to a crossing name and
no profile bounds the set, so "deny by default" was asserted (twice, wrongly)
without a mechanism. **RESOLVED 2026-07-28:** the author ratified the
default-deny-at-a-chokepoint model (`docs/decision-syscall-governance.md`) and
its three mints — **E76** (the chokepoint: name↔number registry + profile
subset; first slice built same day), **E77** (rung-1 seccomp default-deny),
**E78** (number-in-type attenuation). Rows live in `SELF-IMPLEMENT-CATALOG.md`
§XII. NOT an enumeration of 362 — three mechanisms. Per-profile syscall policy
(which subset each profile permits) is profile-author taste, deliberately left
open.
