---
node: banks/module
layer: bank
tier: depth
indexes: [vocabulary, module-map, splitting-law, joining-law, axis-typeability, axis-altitude, decision-profiles, process-and-runtime]
related: [banks/profile, banks/runtime, split-role, perspectives, modules-core, decision-split-checker, permission-model]
status: draft
updated: 2026-09-04
---

# BANK: module

> **What a bank is.** The depth tier under the thin relational notes in `docs/`.
> A bank holds the full refraction of ONE concept: what it is, the shards it
> decomposes into with their principled homes and honest build-state, the
> cross-cuts where one of its shards *is* a shard of another concept, and the
> native monoliths it gets mistaken for. Thin notes link *into* here.
>
> **Why this bank exists.** "module" is the densest refraction in the language.
> A monolith in every conventional language — file, package, class, namespace,
> compilation unit, all at once — is in chirality a *sum of shards*, each already
> living in its own principled home, most of them already built. The recurring
> misfire is to see the monolith "missing" and say *you need a module system
> like X*. You do not. X is already refracted across `process`, the two axes,
> the port-set, the two laws, and the profile. This bank documents that
> refraction so nobody names the phantom again. Build-state below is
> AUTHORITATIVE from [[status-ledger]] and `records/conformance-map.md`;
> where a facet is genuinely unbuilt it is named as such, never rounded to done.

---

## 1. The concept in chirality

**Vocabulary definition ([[vocabulary]]).** A module *is* "a process with a
type, packaged, versioned, composed, replaced. The unit the [[splitting-law]]
cuts and the [[joining-law]] connects." It *is not* "a file or a topic. A module
is individuated by its type, not its subject."

Sharpened:

- A module is a **process** (P2) — the one atom — carrying a full proof-carrying
  **type** (its effects, resources, tier weight, and outward ports; see the
  `type` entry in [[vocabulary]]). A function, a value, a declaration are special
  cases of process ([[modules-core]] §process-and-core-ir), so a module is not a
  distinct kind of thing above processes: it is a process at the granularity you
  package, version, and connect. Run a configuration of modules and connectors
  and *that* is itself a process — a runtime ([[process-and-runtime]],
  [[banks/runtime]]). Self-similarity means "module" is a role a process plays,
  not a rung above it.
- **Individuated by its type, not its subject.** Two forms with the same
  *topic* ("crypto", "the socket layer") are the same module only if they have
  the same type; two forms with different type — different effect, cost, or tier
  weight — are *different* modules that merely share a noun ([[splitting-law]]).
  Identity of modules is decided by the kernel's type-identity judgment (conv /
  definitional equality, E3), not by name, file, or folder. This is the single
  most load-bearing clause and the source of most misfires.

**What it IS.** A typed process that is (a) placed on the typeability axis in
exactly one of A/B/C, (b) spanned across the altitude axis upper→tal→metal, (c)
faced outward by a port-set (its membrane), (d) the unit the splitting law cuts
and the joining law reconnects through four typed connectors, and (e) an element
a profile composes toward a target.

**What it IS NOT.** Not a file. Not a folder. Not a topic/subject. Not a
namespace. Not a class (a record of methods with private fields). Not a
compilation unit. Not a package with a version string. Each of those is a
conventional monolith that fuses several of the shards below with an *incidental*
carrier (the file, the name) that chirality discards. See §4.

**How it is realized in code (evidence).** A module is realized as a *set of
declarations* — `data`, `def`, `porttype`, `extern`, `target`, `profile` —
accumulated into the checker's `Sig` by the toplevel dispatch `load-form`
(`lib/surface/parse.chiral:1266`). The
`lib/**/*.chiral` files are *renderings* that carry those declarations; the file is
the transport, not the module. Individuation is by the elaborated type in `Sig`
(`sig-globals`, `sig-prims`, `sig-datas` at `lib/typing/kernel.chiral:239-241`),
never by filename. ⚑ Since E160/E161 a module DOES carry a first-class
**coordinate**: `(module <name> (cat A|B|C) (alt upper|tal|metal))`, dispatched at
`lib/surface/parse.chiral:1292` to `handle-kind` (`:1166`), with a closed refusal
sum `KErr` (`:1091`) and a declared extent closed by `(end-module "<name>")`. The
coordinate states the two axes and the extent; it does not key identity to a name,
so the individuation claim below is unchanged and the sentence this paragraph
carried until 2026-09-04, "there is no first-class module construct", was wrong.
This is
the concept's own claim made concrete: the module is individuated by its type,
and the code has literally no filename-keyed notion of module identity.

---

## 2. The refraction — the shards, their homes, their build-state

Each shard is a facet the conventional monolith fuses; in chirality each has its own
principled home and its own build-state.

### Shard 1 — Typed process (the atom + its type)
- **What.** The module is a `process` carrying a QTT type. This is the substance;
  everything else is a facet of *this* type.
- **Home.** kernel / `process` & `core-ir` ([[modules-core]]; category A, `cross`
  in [[module-map]]).
- **Build-state.** CONFORMS. NbE eval/quote/conv (E3), bidirectional infer/check
  + universes (E4), QTT semiring 0/1/ω (E5). Evidence: `lib/typing/kernel.chiral`
  (`conv` at `:702`, `subtype` at `:799`), `lib/typing/kernel-core.chiral`,
  `lib/typing/qtt.chiral`, `lib/surface/terms.chiral`. The judgment core is ENFORCED
  ([[status-ledger]]).

### Shard 2 — Typeability placement (A / B / C)
- **What.** Every module sits in exactly one category by what its correctness
  rests on: proof (A), an admitted untyped hole (B), or cross-checked evidence
  over a hole (C) ([[axis-typeability]]). A partition, not a spectrum; the
  splitting law forces monochromaticity.
- **Home.** axis-typeability; the classification is realized as *three different
  enforcement mechanisms*: A = the kernel judgment (ENFORCED), C =
  `bridge.verify` turning a host return into checked evidence, B = named quarantined
  holes reached only through ports ([[modules-substrate]]). ⚑ `bridge.verify` was
  the Python oracle's and has **no live referent**: `lib/evidence/interp.chiral:19-21`
  records the extern/port/bridge face as the deferred connector of E15's SPEC. The
  C mechanism named here is therefore a design, and the row below is read against
  the map rather than against a live symbol.
- **Build-state.** Mixed by category. A CONFORMS (E3–E5). C inbound-half
  IMPLEMENTED (bridge.verify, depth-bounded ≤4); the C evidence bridges
  (attestation/freshness/audit/isolation/reflect-raw) are BUILD / docs-only
  (E55, assigned in the 2026-07-21 catalog extension; the CONFORMANCE-MAP D-row
  "C evidence bridges" predates the assignment). B is a discipline
  (named holes), CONFORMS as scoped.

### Shard 3 — Altitude span (upper → tal → metal)
- **What.** A module is *expressed* and it *runs*; those are the same module at
  different heights, carried down by the lowering connector, type preserved and
  re-checked the whole way ([[axis-altitude]]). `cross` in [[module-map]] means a
  connector runs *through* the module, not that altitude has a third value.
- **Home.** axis-altitude / `translate`+`preserve-check` / `tal`
  ([[modules-lowering]]).
- **Build-state.** CONFORMS for the pure, ground, non-dependent slice. Lowering +
  preserve-check (E16), tal checker + trusted interpreter (E18/E19), x86-64
  modular Mach (E19). Evidence: `lib/lowering/upper/lower.chiral`,
  `lib/lowering/upper/optimize.chiral`, `lib/lowering/tal/check.chiral`,
  `lib/lowering/tal/ir.chiral`, `lib/lowering/x64/mach.chiral`; preserve-check is
  ENFORCED ([[status-ledger]]). Honest
  slice limit: only pure/ground/non-dependent bodies lower today; closures/HO are
  separate forward work (E69, 2026-07-21 catalog extension; not a defect).

### Shard 4 — Port-set / membrane (the outward face)
- **What.** A module affects the world *only* through the typed crossings in its
  membrane; the port-set is the outward part of its type ([[vocabulary]]:
  port/membrane). Compute is inert until it crosses a port (P4). Since
  [[decision-effect-facets]] (2026-07-21) this face is two joined facets: the
  port-set *possessed* (linear capabilities) and the effect row *exercised* (the
  crossings performed), joined by construction — holding is not crossing.
- **Home.** the port-set; `effects` module (the port algebra, A) with its C twin
  `kernel-gate` ([[modules-core]], [[module-map]]).
- **Build-state.** CONFORMS. Category-C port membrane, conformance-map tags
  E30–E33 (a sample of its crossing elements — the membrane also spans E29
  sockets; not a contiguous range): the nine registries under `lib/ports/`
  declare opaque linear porttypes (`Sock`/`LSock` at `lib/ports/sock.port:16-17`,
  `Fd` at `lib/ports/fd.port:16`, `(Pool n)` at `lib/ports/pool.port:13`), the
  extern's host referent binds at link, linearity + frozen-set enforced by the
  checker. Realized in code as `porttype` + `extern`: the dispatch arms sit at
  `lib/surface/parse.chiral:1280` and `:1279`, and `handle-extern` is defined at
  `lib/surface/parse.chiral:659`. Transport self-host
  (E51) is a separate lane, not a reshape.
- **⚑ Split the verdict by facet — added 2026-08-25.** CONFORMS is right for the
  **possession** facet (opaque linear porttypes, linearity at the binder — both
  measured real in B1, `.planning/AUTH-HARNESS-MAP.md` §2). It is **not** right
  for the **exercise** facet. E161's `crossings` field is *sense (a) BINDS* on
  purpose, and nothing else records
  what a module performs — so a module that binds no `=>` extern and only CALLS
  imported ones has an **empty** exercise facet while really crossing. Measured
  2026-08-25 against the then-current build at `4f64d91`, whose path
  `scaffold/build/B1` went with the migration: a program under `(module tfloor
  (cat A) (alt upper))` — *correctness by proof* — whose `->` def calls an `=>`
  def that calls `put` compiled, ran and wrote to stdout. The live binary is
  `bin/chirality-bin` and the measurement has not been retaken against it. The call-level gate that
  would make the facet honest is **E171**; the depth is
  [[banks/effect-and-alarm]] §5d. (The *frozen port set* half of this bullet is
  ⚑ no longer oracle-only, corrected 2026-09-04: `mf-check-ports`
  (`lib/surface/parse.chiral:907`) refuses a listed name that is not a declared
  extern and one whose type crosses nothing, and the manifest reaches the front
  end at `lib/lowering/compile-front.chiral:322`. `.planning/AUTH-HARNESS-MAP.md`
  line 42 already carried that correction, dated 2026-08-25, and what stays
  unmeasured is whether emit refuses an off-manifest crossing.)

### Shard 5 — The unit the splitting law cuts (individuation by type)
- **What.** Where one module ends and the next begins: cut a module until each
  piece is monochromatic on the typeability axis; a split is *real* iff the two
  halves have different type, *spurious* iff same type shape ([[splitting-law]]).
  This is the operational content of "individuated by its type, not its subject."
- **Home.** splitting-law (a P2 consequence). Realized as the twin pattern in
  [[module-map]]: a governance concept appears as a proof twin in A and an
  evidence twin in C (ports = `effects`/`kernel-gate`; cost =
  `cost-typed`/metered-runtime; reflection = `reflect-typed`/`reflect-raw`).
- **Build-state.** DESIGN LAW, partially exercised. The law itself is a design
  invariant; its *application* is recorded (broker split, three security splits,
  integer-safety-does-not-split — [[splitting-law]] Worked splits). The kernel
  mechanism that *decides* "same type shape" is conv (E3, CONFORMS); the twins it
  produces have per-twin build-states (many C twins are BUILD/docs-only).

### Shard 6 — The unit the joining law reconnects (four connectors)
- **What.** Cut modules reconnect *only* through a typed connector that preserves
  the invariant the split exposed; there are exactly four ([[joining-law]]).
- **Home.** joining-law. One connector per composition direction:

  | Connector | Direction | Preserves | Home | Build-state |
  |---|---|---|---|---|
  | bridge | across typeability (A↔B) | inbound: B enters A only as evidence; outbound: A enters B only confined | [[category-bridge]] | inbound IMPLEMENTED (`bridge.verify`); **outbound confinement BUILD** (not built) |
  | lowering | across altitude (upper→metal) | the type, checked to tal | [[modules-lowering]] | CONFORMS (E16/E18/E19) |
  | staging | across binding time | semantics: a residual computes what its source would | [[modules-staging]] | **SEEDED**: `spawn`+link-at-load only; binding-time *modality* DESIGNED, `gap` in [[module-map]], E57 (Fork C; 2026-07-21 catalog extension) |
  | port-composition | within one category | the closed port set (add/drop none) | [[decision-profiles]] | CONFORMS (E2 profiles enforce the frozen port set) |
- **Build-state.** Two of four connectors CONFORM (lowering, port-composition);
  bridge is half-built (inbound yes, outbound no); staging is seeded-plus-designed.
  The bridge is *one general elaborator* parameterized by an evidence element, not
  written per referent ([[joining-law]] §"one general elaborator",
  [[decision-bridge-elaborator]]).

### Shard 7 — Element a profile composes (module is the alphabet)
- **What.** A profile is a named set of modules and the connectors that string
  them toward a target; the splitting law gives the alphabet (modules), the
  joining law gives the grammar (connectors) ([[joining-law]] §"A profile is
  modules plus connectors"). The module is thus the *unit of composition*.
- **Home.** [[decision-profiles]] / see the sibling **[[banks/profile]]** for the
  profile's own full refraction — do not re-read it here.
- **Build-state.** `handle-profile` (`lib/surface/parse.chiral:989`) parses
  `(profile name (ports p...) (target t) [(memory d)] [(total)])` as an additive
  manifest over a frozen port set, and judges each half: `mf-check-ports` (`:907`)
  the port list, `mf-memory-of` (`:939`) the discipline, `sig-target` the named
  target. `tools/test/profile-target.sh` is the gate. ⚑ That is PARSE, JUDGE and
  STORE, which `lib/surface/parse.chiral:723-724` says in its own words; whether
  emit refuses an off-manifest crossing was not measured, so the CONFORMS this row
  used to claim is withdrawn, and so is the subcommand this row named as its
  enforcer: `bin/chirality` dispatches check, compile, run and test, and no
  `verify` arm has ever been in it. E2.

### Shard 8 — Individuated-by-type: versioned / composed / replaced
- **What.** "packaged, versioned, composed, replaced" — a module is *replaceable*
  by any other module whose type conforms to the requirement its slot named.
  Replacement is not a package-manager operation on a name; it is subtype
  conformance to a target requirement type.
- **Home.** target / conformance ([[decision-profiles]]: conformance = the
  composite's type satisfies the target by subtyping).
- **Build-state.** Subtyping IMPLEMENTED (`subtype` at
  `lib/typing/kernel.chiral:799`); `(target name (require dname ty) ...)` is parsed
  and judged natively by `handle-target` (`lib/surface/parse.chiral:833`), each
  requirement's type elaborated in the empty scope and required to be a universe
  (`mf-req`, `:783`). ⚑ The conformance check itself, the oracle's `_target_rows`,
  has **no live referent**: nothing in `lib/` decides that a profile's composite
  satisfies its target's rows. The row is parse-and-judge, and the CONFORMS it
  used to claim covered a check that is gone (E2).
  **The "versioned" facet is the least-built** — there is *no* version machinery
  and none is owed as a separate feature: versioning reduces to swapping a
  conforming module against the same target row, which subtyping already decides
  (§5).

---

## 3. Cross-cuts — where a shard of "module" IS a shard of another concept

This is the highest-value section: the places where refracting "module" and
refracting some other concept land on the *same* shard. These are exactly the
insights a thin note cannot hold and an agent keeps missing.

**C1 · A module's port-set IS its capability set (P3).** Shard 4 (membrane) and
the concept *capability* are the same shard. [[vocabulary]]: "capability *is* a
port held. Authority is the set of ports you hold." So a module's outward face is
*not* separately "its API" and "its permissions" — the port-set is both
(precisely: the *possession* facet; the crossings actually performed are the
*exercise* facet, the effect row of [[decision-effect-facets]]). When you
ask "what can this module do", the answer is its held ports, and that set is
frozen by the profile (port-composition, Shard 6). ⚑ **As a claim about the tree
this is aspirational today, measured 2026-08-25** — a module can exercise a
crossing it neither binds nor declares, because nothing refuses a `->` def that
calls an `=>` one (Shard 4's split verdict; E171). C1 states the design, and the
design is right; what is missing is the gate that makes the answer *derivable*
rather than *asserted*. Consequence: *revocation is
not a module feature and not a capability feature* — a revoked port becomes a dead
port in the module's membrane whose next crossing raises an alarm answered by a
counter-effect, mediated by the broker ([[permission-model]], [[modules-broker]]).
Revocation is a customer of the effect/alarm system, reached *through* the module's
port-set shard.

**C2 · A module's split IS the split-role (for the unprovable case).** Shard 5's
C-twin, when the truth a module needs cannot be proven, *is* the `Split` role of
[[split-role]]. A module that needs a split does **not** build one: it declares a
requirement for a `Split` provider, and the profile must supply a conforming one
(share / guarded-combine / agree / alarm / provenance-check living in one place,
generalizing `custody-split`). So "this module holds redundant evidence" is the
same shard as "the profile supplies a split provider the module requires."
Build-state: docs-only / BUILD, gated on edge 4 + edge 11 (E54, assigned in the
2026-07-21 catalog extension; the CONFORMANCE-MAP "split-provider / split-role"
row predates it).

**C3 · Individuated-by-type IS the checker's type-identity judgment.** "A module
is individuated by its type, not its subject" ([[vocabulary]]) is *not* a slogan —
its operational meaning is the kernel's definitional-equality judgment (conv, via
NbE, E3). Two modules are the same module iff their types are conv-equal; the
splitting law's "same type shape ⇒ spurious split" (Shard 5) is decided by the
*exact same* conv the checker uses to accept a program. Module identity and type
identity are one mechanism (`conv` at `lib/typing/kernel.chiral:702`; E3,
CONFORMS). This is why there is
no filename-keyed module table in the code (§1): the checker's `Sig` already
individuates by type.

**C4 · A module's "replaced" IS subtype conformance to a target.** Shard 8 and the
concept *conformance* ([[decision-profiles]]) are the same shard. Swapping module
M for M′ in a profile is valid iff M′'s type is a subtype of the target row M
filled. ⚑ The check that would run it, the oracle's `_target_rows`, has no live
referent (Shard 8), so the collapse is sound as a design and unenforced as code.
So "hot-swap / versioning / dependency substitution" all collapse onto subtyping.
No separate substitution mechanism exists or is owed.

**C5 · The twin pattern (Shard 5) IS the joining law's rejoin (Shard 6).** The
splitting law *produces* twins (proof-in-A, evidence-in-C); the joining law
*reconnects* them with the connector fitting their boundary — A↔C governance twins
by the bridge, upper/lower faces by lowering, same-concept-across-stages by staging
([[joining-law]] §"dual of the twin pattern"). A module's split shard and its join
shard are two ends of one operation; you cannot cut without owing a preserving
reconnect.

**C6 · A running configuration of modules-plus-connectors IS a runtime.** Shard 1's
self-similarity means a profile's worth of modules, staged live, is itself a
process at system scale — a runtime ([[process-and-runtime]]). This is the same
shard the sibling **[[banks/runtime]]** refracts from the other side; a module is
what a runtime is *made of*, and a runtime is what a configuration of modules
*is*. Do not re-document runtime here.

**C7 · A module's "packaged / composed" IS the profile's manifest (Shard 7 ↔
profile).** The module-as-alphabet and the profile-as-grammar meet at
`verify_profiles`: the profile *is* the packaging, and the module contributes the
crossings the manifest freezes. Refracted fully in **[[banks/profile]]**.

**C8 · The kernel module is itself split by the checker discipline.** Shard 5
applies reflexively to the kernel: `kernel-expressed` (A) splits into `kernel-spec`
+ `kernel-core` + untrusted certificate producers ([[decision-split-checker]],
[[modules-core]]). "Module identity is by type" (C3) is precisely what lets the
core re-check an untrusted producer's certificate without trusting the producer:
the certificate is a term whose type the core checks. The checker's split is not
special-cased — it is the splitting law applied to the module that runs the
splitting law.

---

## 4. Native → chirality translation (the misfire → the correction)

For each conventional monolith, the misfire an agent makes and the shards it
actually decomposes into.

**"You need a module system / packages like Python or Rust crates."**
→ Correction: it is already refracted. `process`-with-a-type (Shard 1, built,
E3–E5) + typeability placement (Shard 2) + port-set membrane (Shard 4, built,
E30–E33) + the splitting/joining laws (Shards 5–6) + the profile (Shard 7, built,
E2). The *namespace/file/import-resolution* part a package system bundles is
**not** the module — it is the surface reader + elaborator (`resolve`, E1/E2,
`lib/module/resolve.chiral`, `lib/surface/parse.chiral`), and it is incidental
transport. Genuinely-new shard: none; the
package *manager* (version resolution) reduces to subtype conformance (C4).

**"You need classes / objects for encapsulation."**
→ Correction: a module is a *typed process*, not a record of methods over private
fields. Encapsulation is the membrane/port-set (Shard 4): the only way in or out
is a typed port, enforced by linearity and the frozen set. "Private" = not a port.
"Method" = a crossing. No class construct is owed; the encapsulation it offered is
strictly weaker than a checked membrane. (Dependent records / Σ-types, E48, are a
*data* feature, unbuilt — not the module's encapsulation shard.)

**"You need namespaces to avoid name collisions."**
→ Correction: name resolution is the surface elaborator's job (`resolve`, E2), and
module *identity* is by type, not name (C3). Two things sharing a noun are
distinct modules iff their types differ ([[splitting-law]]). The collision problem
a namespace solves is a surface concern, and it is not a property of
the module.

**"You need a compilation unit / linkage unit."**
→ Correction: the altitude span (Shard 3) is what "compilation" refracts to — a
process is lowered upper→tal→metal by the lowering connector, type-preserved and
re-checked (E16/E18/E19). The unit compiled is the *process*, carried by a
connector, not a file boundary. Linkage is the staging connector + link/load
(SEEDED: `spawn`+link-at-load; the binding-time modality is the genuinely-new,
unbuilt shard — see §5).

**"You need versioning / a package registry / semver."**
→ Correction: "versioned/replaced" (Shard 8) reduces to subtype conformance to a
target requirement type (C4, `_target_rows`, E2, built). A "new version" is a
module whose type is a subtype of the row it fills. Genuinely-new shard: none in
kind; there is no version-string machinery and none is owed — it would be a
spurious re-encoding of subtyping.

**"You need dependency injection / a service container."**
→ Correction: that is the profile supplying a required provider (Shard 7 + the
requirement-type pattern of [[decision-profiles]]); the sharpest case is the
`Split` role (C2), where a module *requires* a provider and the profile *supplies*
it, with independence and containment checked, not wired freely. DI is
port-composition + requirement types, both built (E2).

---

## 5. What's genuinely new / unbuilt — the honest residue

Only the residue, with gradients preserved and tiers named. Nothing here is
rounded to done or to undone.

1. **The staging connector as a binding-time *modality* (Shard 6, staging).** The
   only connector of the four not built. Today: SEEDED — `spawn` + link-at-load,
   ad hoc ([[status-ledger]] SEEDED/Staging). ⚑ The two files this row cited for
   it, `impl_ports.py` and `runtime.py`, were the oracle's and have no live
   referent; `lib/runtime/proc.chiral` and `lib/module/loader.chiral` are where the
   live spawn and link-at-load sit. The
   *modality* — link/load-vs-runtime carried in the type (Fork C) — is DESIGNED,
   `gap` in [[module-map]], catalogued as **E57** in the 2026-07-21 extension
   (the CONFORMANCE-MAP row predates the assignment and still reads "needs
   E-number"). This is the one shard of
   "module" where the reconnect story is genuinely incomplete.

2. **The bridge connector's outbound-confinement half (Shard 6, bridge).** Inbound
   (B→A as evidence) is IMPLEMENTED (`bridge.verify`, depth-bounded). Outbound
   (A→B only confined: secret/capability never leaks to B) is BUILD / not built
   (CONFORMANCE-MAP D-row "inbound bridge integrity-verification … Outbound
   confinement not built"). A module's A↔B seam is therefore half-preserving today.

3. **The C evidence twins of governance modules (Shard 2/5).** The proof twins in
   A are built; several evidence twins in C are docs-only: attestation, freshness,
   audit, isolation-enforce, reflect-raw, custody redundancy/datum-policy
   ([[status-ledger]] DESIGNED; E55 "C-bridge evidence-half" and E56 "custody
   redundancy" — assigned in the 2026-07-21 catalog extension). The split *law*
   is settled; the
   built-ness of the twins it names is per-twin and mostly forward.

4. **The reflective-floor line inside the kernel module (C8).** Which parts of the
   kernel module are immutable-from-inside a running chirality is a DECISION
   (E45 / edge 5): direction resolved, exact A/B line **not drawn**, no code
   (CONFORMANCE-MAP DECISION row; [[status-ledger]] DESIGNED). This gates
   reflect-typed and reflect-raw — i.e. gates the reflection twin-pair of Shard 5.

6. **Emitted-label collision — the one place the "namespace is already handled"
   correction (§4) needs a caveat.** Module *identity* by type is settled and the
   surface resolver does its job; but **below** the surface, after resolution, every
   `def` becomes a label in ONE flat emitted namespace, and two co-blobbed modules
   defining the same internal name collide. This is not the design-tier namespace
   phantom §4 refutes — it is a codegen-tier defect, and it is live: hand-patched
   three times (`gate.chiral` `str-contains`→`gate-contains`, E140; `agent.chiral`
   `ok2xx`→`agent-ok2xx`, scriba S15; `TUI/scriba/cmd-types.chiral:2` inlining
   `lookup-scribaop` "to avoid B1 label issue"). It has a second-order cost: modules
   write prefixed clones of shared helpers rather than importing them, which is the
   mechanical root of the stdlib altitude leak
   (`.planning/LANGUAGE-INVENTORY.md` §10 item 3, which measures `str-cmp` existing
   four times in four compiler modules; the `STDLIB-INVENTORY.md` this line used to
   cite has never existed in this tree).
   Catalogued 2026-08-21 as **E154** (label mangling at emit) with **E155** (a
   multi-root resolver search path) beside it. Added here because §4's "already
   handled" read true at the design tier and false at the emit tier, and the bank
   should not be usable as evidence that the collision problem does not exist.

5. **The "versioned" facet (Shard 8) has no dedicated machinery** — and that is a
   *deliberate* non-gap, not an omission: it reduces to subtyping (C4). Named here
   only so no one re-adds it as a phantom. The one live softness is that the
   subtype mechanism, though present, is **not yet applied to grant narrowing**
   ([[status-ledger]] IMPLEMENTED note on `subtype`; permission-model over-claims
   done) — so capability-attenuating replacement of a module is a present-but-
   unapplied EXTEND, not a built path.

Gradient summary: the module's *substance* (Shard 1) and two of its four
connectors are ENFORCED/CONFORMS; its membrane and profile-composition are built;
its splitting law is settled but its C-twins are mostly forward; its staging
reconnect and its bridge-outbound half are the real unbuilt edges; and its
"versioning" facet is a non-feature that correctly collapses into subtyping.

---

## 6. Relational anchors — thin notes that should link INTO this bank

These `docs/` notes each hold one facet of "module" and should point here for the
depth:

- [[vocabulary]] — the `module`, `process`, `port`, `capability`, `connector`
  entries (the definitional source; §1).
- [[module-map]] — the full module list on the two axes; the hub. Its rows are the
  per-module build-states this bank aggregates.
- [[splitting-law]] — where a module ends (Shard 5).
- [[joining-law]] — how cut modules reconnect (Shard 6); the four connectors.
- [[axis-typeability]] — A/B/C placement (Shard 2).
- [[axis-altitude]] — upper/tal/metal span (Shard 3).
- [[decision-profiles]] — module-as-alphabet, profile-as-grammar (Shard 7, 8) →
  and the sibling **[[banks/profile]]** for the profile's own depth.
- [[process-and-runtime]] — module self-similarity → **[[banks/runtime]]** (C6).
- [[modules-core]] — the category-A backbone modules named in Shards 1–7.
- [[split-role]] — the split a module requires and a profile supplies (C2).
- [[decision-split-checker]] — the kernel module split reflexively (C8).
- [[permission-model]] / [[modules-broker]] — port-set ↔ capability, revocation as
  a customer of the alarm system (C1).
- [[perspectives]] — the multi-angle view (builder/type/membrane/runtime) of the
  same construct a module is.
