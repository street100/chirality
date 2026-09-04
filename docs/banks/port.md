---
node: banks/port
layer: bank
tier: depth
related: [banks/module, banks/profile, banks/capability, banks/effect-and-alarm, banks/memory, vocabulary, glossary, category-typed, permission-model, open-edges, status-ledger, joining-law, decision-profiles]
status: draft
updated: 2026-09-04
---

# Bank: port

> **What a bank is.** The depth tier under the thin relational notes in `docs/`.
> A bank holds the full *refraction* of ONE concept: what it is, the shards it
> decomposes into with their principled homes and honest build-state, the
> cross-cuts where one of its shards *is* a shard of another concept, and the
> native monoliths it gets mistaken for. Thin notes link *into* here.
>
> **Why this bank exists.** The **port is the primitive most other governance
> concepts are built from.** Capability, membrane, grant, the module's outward
> face, the profile's frozen set, space-as-a-resource, the whole permission
> model — each is the port seen from one angle. So the port's refraction is the
> load-bearing one: get it right and the governance vocabulary is a set of views
> onto a single built mechanism; get it wrong and each view looks like a missing
> subsystem. Build-state below is AUTHORITATIVE from
> `records/conformance-map.md` (slice D) and [[status-ledger]]; where a
> facet is genuinely unbuilt it is named as such, never rounded to done.

---

## 1. The concept in chirality

**Vocabulary definition ([[vocabulary]]).** A port *is* "a typed crossing in a
process's membrane. The only way a process affects anything outside itself. The
outward-facing part of its type. Where the governance logic lives. What P3
governs." It *is not* "a plain type (it carries a protocol and state), nor an
owned channel (authority is holding the port, not owning the substrate behind
it)." It **replaces** the older word *door*.

Sharpened, a port is four things at once, and separating them is the whole job of
this bank:

- **A typed crossing** — the *type* of the crossing is owned in chirality source; the
  host referent behind it is not (§Shard 2). "The outward-facing part of a
  process's type" is literal: a module's type is (roughly) its ports plus its
  interior, and the port-set is the part the world can name ([[banks/module]]
  Shard 4).
- **The only way out (P4).** Compute is inert until it crosses a port
  ([[vocabulary]] "membrane"); a value never leaves except through a crossing.
  "A process with no port held affects nothing" is the *target* invariant, not
  yet the built fact: the ambient process externs (`print`/`put`/`trace`/
  `env-get`/`time-mono`/`sleep-ms`/`spawn`/`exit`/`halt`, `ports/clock.chiral:32–39`
  and `ports/process.chiral:13–14` — repointed 2026-08-22)
  are crossings that require **no held port** — the named current violation of
  no-ambient-authority. Their capabilities (Console/Clock/Env, …) are to be
  reified as porttypes so every crossing takes its capability as a parameter
  ([[decision-effect-facets]], 2026-07-21).
- **Where the governance logic lives (P3).** Authority, resource bounds, and
  effect are all *in the port's type*: a resource limit is a bound in the port
  (`(Pool n)`), a held port is a capability, and the arrow's `=>` marks a
  crossing — the seed of the effect *row*, the exercise facet beside the
  possession facet ([[decision-effect-facets]], 2026-07-21). P3 —
  "govern the ports" — has no other surface to act on.
- **Held, not owned.** Authority is *holding* the port, linearly; the substrate
  behind it (the socket fd, the RAM, the register root) is category B, owned by
  nothing ([[category-untyped]], [[node-architecture]]). This is the single
  clause that separates a port from a channel/handle.

**What it IS.** An opaque **linear** value (bound at q=1) whose **type** carries
(a) the crossing's contract, (b) an effect marking it as a crossing at all, (c)
optionally a value-index that puts a bound in the type (`(Pool n)`), and
optionally (d) a protocol/typestate the crossing advances (edge 14, OPEN).

**What it IS NOT.** Not a plain type (it carries protocol + linear state). Not an
owned channel (you hold it, you do not own the substrate). Not a first-class
runtime object with methods. Each of the native monoliths in §4 fuses the port
with an *incidental* carrier — the file descriptor number, the vtable, the FFI
symbol — that chirality discards.

**How it is realized in code (evidence).** A port is spelled with two surface
forms and no others: `porttype` introduces the opaque linear atom
(`handle-porttype`, `lib/surface/parse.chiral:688`), `extern`
declares one typed crossing over it (`handle-extern`, `lib/surface/parse.chiral:659`). There is no
first-class `port` object — a port is a *value of a porttype produced or consumed
by an extern*, and "is this extern a crossing?" is a **derived** boolean, not a
declared one (`ty-crosses`, `lib/typing/kernel.chiral:315`, §Shard 3). ⚑ The
membrane's inbound integrity check, `bridge.verify`, was the Python oracle's and
has **no live referent**; `lib/evidence/interp.chiral:19-21` records that face as
E15's deferred connector. That is the entire mechanism; every governance
concept in §3 is a *view* onto it.

---

## 2. The refraction — the shards, their homes, their build-state

Each shard is a facet the conventional monolith (a socket, an fd, a syscall, an
FFI binding, an API method) fuses; in chirality each has its own home and build-state.

### Shard 1 — the porttype (the opaque linear atom, C-floor)
- **What.** An opaque type constant the kernel learns *nothing* about except that
  it exists and that it is **linear** — so any value of it (or anything
  transitively holding one) can only ever be bound with quantity 1. This is the
  substance a port *is*: a B-ness-in-the-type atom the checker threads move-only.
- **Home.** the port floor / category-C boundary declared in source (the nine
  registries under `lib/ports/`; [[category-typed]] "the port set").
  `(porttype Sock)` and `(porttype LSock)` at `lib/ports/sock.port:16-17`,
  `(porttype Fd)` at `lib/ports/fd.port:16`.
- **Build-state.** CONFORMS (E30–E33). `handle-porttype`
  (`lib/surface/parse.chiral:688`) → `load-atom` (`lib/module/loader.chiral:487`)
  records an opaque linear atom in the `latoms` registry;
  `lib/ports/ports.chiral:3-8` states the invariant ("the kernel learns nothing about
  it except that it exists and that B-ness lives in the type"). Linearity is
  ENFORCED by `is-linear` (`lib/typing/kernel.chiral:325`) + the depth-bounded abstract walk (E8,
  CONFORMANCE-MAP D "Linear-kind decision"). CONFORMANCE-MAP D row "Category C
  port membrane": CONFORMS.

### Shard 2 — the extern (the crossing's typed contract)
- **What.** One typed crossing over the porttypes. **The type is owned in chirality
  source; the host referent is bound at load, not here.** This is the A-owns-the-
  contract / B-owns-the-referent split made concrete: `(extern sock-send (=> (1 s
  Sock) Bytes Sock))` names the contract; the socket syscall behind it is invisible
  to the type system.
- **Home.** the nine `lib/ports/*.port` registries (the contracts) + the linkage
  behind the membrane + `handle-extern`.
- **Build-state.** CONFORMS (E30–E33). `handle-extern`
  (`lib/surface/parse.chiral:659`) elaborates the declared type, checks it is a
  universe and installs `name : ty` into the Sig's `prims`
  (`lib/typing/kernel.chiral:240`). ⚑ The host-binding half this shard cited,
  `impl_ports.py` and `IMPL_PORTS` and `RT.__init__`, was the Python oracle's and
  has **no live referent**. The live binding seam is
  `lib/lowering/tal/sys-linkage.chiral`, whose header says it routes an effectful
  extern through a hand-tal wrapper over the sys crossings rather than through a
  CPython callable, and names E51 as the true self-host gate. Its v1 binds the
  three ambient writers only, so **the transport half of this row is a lane in
  progress** (CONFORMANCE-MAP D "Transport swap is E51 lane, not a reshape").

### Shard 3 — the effect (a crossing carries an effect; the port-check IS the type-check)
- **What.** What *makes* an extern a port rather than a pure primitive is that its
  type contains an **effect arrow `=>`**. "Is this a crossing?" is not declared —
  it is **read off the type**. So the port-check *is* the type-check (P3): to know
  a process's ports you type it; there is no separate capability audit. Under the
  two-facet decision the bit is the one-entry seed of the exercise **row** — the
  record of crossings performed, distinct from ports held
  ([[decision-effect-facets]], 2026-07-21).
- **Home.** the effect membrane ([[banks/effect-and-alarm]]); derived by
  `ty-crosses` (`lib/typing/kernel.chiral:315`).
- **Build-state.** Split gradient — the *derivation* CONFORMS, the *effect
  representation* is REFACTOR. ⚑ **Third leg, added 2026-08-25: the derivation is
  sound for an `extern` and does NOT reach a `def`.** "To know a process's ports
  you type it" holds where the port is *bound*; measured 2026-08-25 against the
  then-current build at `4f64d91`, whose path went with the migration, a
  `(-> Str I64)` def that CALLS an `(=> Str
  I64)` def compiled, ran and performed the crossing, so typing that def tells you
  nothing about its ports. ⚑ **Sharpened 2026-08-29 (E170 lane E, and it is worse
  than the 2026-08-25 reading):** the intermediate `=>` def is not needed. A `(->
  Bytes I64)` def calling the `=>` **extern directly** — `(lam (bs) (write-fd 1
  bs))` — compiles and is committed as `pe-pure-write` in
  `tools/test/samples/e170_port_zeros.prog` (Phase 12 row E7b). So the `->`/
  `=>` membrane refuses **nothing** at the call, not even the declared crossing
  itself. The three refusing seams are native now, `on-apply-ok`, `erased-allow`
  and `on-binder-ok` at `lib/typing/effects.chiral:34-46`, and nothing calls
  them ([[status-ledger]] Effects row). Reaching them is **E171**;
  the measurement and its method are [[banks/effect-and-alarm]] §5d. Until then
  P3's *"the port-check is the type-check"* is true of externs and aspirational
  for defs.
  - Derivation, CONFORMS: `ty-crosses` (`lib/typing/kernel.chiral:315`) walks the
    Pi spine and is true iff any arrow's seat is `s-proc`, computed from the stored
    type rather than cached in a registry, so there is no second copy to fall out
    of sync (`lib/typing/kernel.chiral:310-312`).
    `mf-check-ports` (`lib/surface/parse.chiral:907`) then **refuses any port-set
    member that is pure**, returning `mf-port-pure`, and any name that is not a
    declared extern, returning `mf-port-unknown`. Evidence of the pure/crossing
    split in the source: `pool-write` is `(-> (0 n I64) (=> (1 p (Pool n)) I64
    Bytes (Pool n)))` (`lib/ports/pool.port:27`) — the outer `->` (pure, erased
    bound) wraps an inner `=>` (the crossing), and `ty-crosses` is true because a
    `=>` appears.
  - Representation, REFACTOR: the effect is a **coarse boolean** on the arrow, not
    a typed row; conv compares it by equality, not subsumption. Enriching it to a
    named effect row is **E39** — its gating decision (edge 16) was **resolved
    2026-07-21** ([[decision-effect-facets]]); the gate is now implementing the
    decision, not making it (gates alarms E26). So "crossing = effect" is
    structurally CONFORMS as a P3 shape, and the *typed-effect-row* refinement of
    it is unbuilt (§5).

### Shard 4 — the inbound membrane (integrity: verify)
- **What.** The membrane runs both ways; **inbound verifies integrity**. A host
  referent is a B value the type system cannot see into, so the runtime does not
  trust it: every value an extern returns is checked against the extern's declared
  result type *at the crossing*, and a mismatch is a divergence **alarm**, not a
  crash downstream. This is *evidence at the membrane*, not proof of the
  implementation.
- **Home.** [[category-bridge]] inbound face.
- **Build-state.** ⚑ **No live referent, recorded 2026-09-04.** The whole of this
  row's evidence was `bridge.py`: `bridge.verify(sig, name, v, tyv)` tag-checking a
  runtime value against the declared result type, `PortError` as the inbound
  membrane alarm, the deliberate depth bound of four, and the pass-through for
  neutral and polymorphic result types. That file went with the Python oracle and
  nothing in `lib/` re-checks an extern's return today.
  `lib/evidence/interp.chiral:19-21` names the extern/port/bridge face as E15's
  deferred connector, and `lib/lowering/tal/sys-linkage.chiral:11-12` says the
  linkage re-seats `bridge.verify` on a wrapper's return, which is a design over a
  symbol that is gone. The CONFORMS below is the map's verdict on the oracle and
  is left visible for that reason.
  CONFORMANCE-MAP D "Inbound bridge integrity-verification": CONFORMS, "Integrity/
  inbound half only; no E#. **Outbound confinement not built**."

### Shard 5 — the outbound membrane (confinement) — **NOT BUILT**
- **What.** The other direction: **outbound confines.** A may emit into B only
  *confined* — encrypted if it must not be read, carrying no live capability, its
  exposure window bounded ([[category-typed]] "the handoff to C"). This is P4's
  membrane crossing applied to confidentiality + capability-containment on the way
  out, dual to Shard 4's integrity on the way in.
- **Home.** [[category-bridge]] outbound face; would sit beside the inbound
  check of Shard 4.
- **Build-state.** **BUILD / not built.** CONFORMANCE-MAP D "Inbound bridge …
  Outbound confinement not built"; overlaps E44. This is the port's largest single
  unbuilt shard (§5). The membrane is **half-preserving** today: it verifies what
  comes in, it does not confine what goes out.

### Shard 6 — value-indexed ports (a bound in the port's type)
- **What.** A porttype may be **value-indexed** (dependent): `(porttype Pool (n
  I64))` makes `(Pool 16384)` and `(Pool 4096)` *different types*. This is how "a
  resource limit is a bound in the port" (P3, [[open-edges]] node-model) is
  realized — the size travels *in the type*, and a target can demand a specific
  bound.
- **Home.** the port floor + dependent types (`lib/ports/pool.port:13`;
  [[banks/memory]] for the discipline over it).
- **Build-state.** CONFORMS (E30–E33). `handle-porttype`
  (`lib/surface/parse.chiral:688`) takes the indexed form and declares the porttype
  as an **empty linear `data`** (`:698`) — an atom whose only inhabitants come from
  externs, recorded in the `ldatas` registry (`lib/typing/kernel.chiral:232`).
  `pool-create : (=> (w n I64) (PoolR n))` (`lib/ports/pool.port:26`) flows the size
  argument into the result type. ⚑ The runtime cross-check of that *claim* was the
  oracle's `bridge.verify` and has **no live referent** (Shard 4), so a concrete
  `(Pool k)` whose mapping is not `k` bytes is refused nowhere at the crossing
  today. A constant offset within the bound is compile-time
  bounds-checked (`mem-put-checked`, E22); a computed offset falls back to a
  runtime check pending E9 symbolic bounds ([[banks/memory]]).

### Shard 7 — the frozen port set (the closed, named membrane)
- **What.** The port set is **closed and profile-invariant**: a program cannot
  enumerate its own outputs (undecidable), but it *can* enumerate the finite named
  ways it affects the outside — the ports. A profile *selects which crossings are
  in scope* over that frozen set; it never mints or removes a port.
- **Home.** [[category-typed]] "the port set" + the profile's `(ports …)` clause;
  see **[[banks/profile]]** Shard B for the profile's own depth — do not
  re-document it here.
- **Build-state.** `mf-check-ports` (`lib/surface/parse.chiral:907`)
  rejects any listed name that is not a declared extern and any name that is pure,
  and the manifest reaches the front end at
  `lib/lowering/compile-front.chiral:322`. ⚑ The second half, flagging a crossing
  *used* but outside the frozen set, was the oracle's `verify_profiles` and has no
  live referent; `lib/surface/parse.chiral:723-724` states the live boundary in its
  own words, that the slice parses, judges and stores and that emit's refusal reads
  `sig-profiles` later and is not there. So the row is parse-and-judge ENFORCED and
  use-site ENFORCEMENT UNMEASURED (E2).
  [[status-ledger]]: "Frozen-port-set conformance — ENFORCED (named crossings only;
  edge 18 open)."

### Shard 8 — the port protocol (typestate / session aspect) — **OPEN**
- **What.** The **state a crossing advances** as data flows through it — the
  typestate or session aspect, "the thing meant by data gathered through the state
  of the type" ([[vocabulary]] "port protocol"). Visible already as *distinct
  porttypes for distinct protocol states*: `LSock` (listening) vs `Sock`
  (connected) are "same wire, different protocol state"
  (`lib/ports/sock.port:17`), and
  the linear return-threading (`sock-recv` hands back the *same* `Sock` moved
  onward) is a hand-encoded one-step advance.
- **Home.** the port protocol ([[vocabulary]]); the mechanism decision is
  [[open-edges]] **edge 14**.
- **Build-state.** **OPEN mechanism decision — do not assert session-typed.**
  Direction is narrowed (2026-07-04): authority is move-only, so a live port is a
  move of a typed value across a typestate crossing — message passing, no shared
  handle, no aliasing, races ruled out by construction; the one sharing mode is
  immutable read-only. The residual sync-vs-async question — whether the agreement
  (the `bridge.verify` rendezvous) and the data transfer are one step or two — was
  **shaped 2026-07-25** ([[open-edges]] edge 14): it is **continuation placement**,
  not an independent axis. One step (synchronous) = the linear `KontMsg`
  continuation ([[decision-effect-facets]]) resumed in place; two steps
  (asynchronous) = that continuation *moved* to the handler (same-node continuation
  mobility) and resumed later — a per-crossing choice typed by the continuation's
  QTT grade + mobility, both poles already-legal machinery, the async case
  exactly-once by move-only linearity. So ports carry protocol *state today only as
  distinct types + linear threading*; formal session-typing is still **undecided**,
  not built (§5) — but the residual now names *what* is undecided (a runtime
  scheduler for moved continuations; the two-step liveness engineering), not
  *whether* sync and async are both expressible.

---

## 3. Cross-cuts — where a shard of "port" IS a shard of another concept

The highest-value section: the port is the shared shard under most governance
nouns. These are the identities a thin note cannot hold.

**C1 · A port held IS a capability.** Shard 1 (the held linear atom) and the
concept *capability* are the **same shard**. [[vocabulary]]: "capability *is* a
port held. Authority is the set of ports you hold (P3)." There is no separate
"permission" object — a process's authority *is* its held port-set, and a *grant*
(sidehand) is a held port presented at a crossing ([[vocabulary]] "grant"). This
is why the port is "the primitive most other governance concepts are built from":
capability is not a wrapper around a port, it is the port under the possession
view. Consequence: **attenuation/grant/revoke are not port features and not
capability features** — they are operations on the *same* held port, mediated by
the broker, and only *Move* (linearity) is built; grant-narrowing needs subtyping
applied to the port type (present-but-unapplied), revoke/delegate are DESIGNED
(CONFORMANCE-MAP D "Grants / revocation"; §5). See **[[banks/capability]]** for
the possession-view depth — do not re-document it here.

**C2 · The crossing IS an effect; the port-check IS the type-check.** Shard 3 and
the concept *effect* are the same shard: a port is exactly an extern whose type
carries a `=>`, and crossing-ness is *derived* from that arrow (`ty-crosses`,
`lib/typing/kernel.chiral:315`), not declared. So governing the ports (P3) requires no machinery beyond
type-checking — to enumerate a process's crossings you infer its type. Inbound
divergence at a crossing is an **alarm** in the design (Shard 4, whose mechanism
has no live referent), so a port failure is meant to surface as a typed effect on
the membrane rather than an out-of-band exception.
The typed-effect-row refinement (E39) is where this cross-cut gets richer; see
**[[banks/effect-and-alarm]]**.

**C3 · The port-set IS the module's outward face.** Shard 7 (the frozen set) is
[[banks/module]] Shard 4 (the membrane): "a module affects the world *only*
through the typed crossings in its membrane; the port-set is the outward part of
its type." A module's ports are simultaneously "its API" and "its permissions" —
the port-set is both. Do not treat the module's membrane and the port as two
things; the module bank refracts the *container*, this bank refracts the
*crossing* it is made of.

**C4 · The frozen set IS the profile's capability manifest.** Shard 7 ↔
[[banks/profile]] Shard B. Freezing the set is P3 governance applied to a whole
runtime; omitting a crossing from a profile (e.g. the tomodachi profile omitting
`time-mono`) is *capability attenuation expressed as a profile*. The profile
*selects modules, never ports* ([[category-typed]]). Refracted fully in
**[[banks/profile]]** — point there.

**C5 · Space IS a port.** Shard 6 (`(Pool n)`) ↔ [[banks/memory]]. "A resource
limit is a bound in the port and a storage view is the port's type"
([[open-edges]] node-model). This is *why* the memory discipline is a **profile
choice** and not a runtime setting ([[banks/profile]] Shard E): the pool is a
value-indexed port, the discipline (`linear` / `region`) is which library owns the
crossing, and the bound lives in the type. See **[[banks/memory]]** for the
discipline depth.

**C6 · The port protocol IS an open session-typing question, tied to effects.**
Shard 8 ↔ [[open-edges]] edge 14, and it "sits inside [[process-and-runtime]] and
[[modules-broker]]" and is "a decision tied to `effects`, like the port protocol
of edge 14" ([[open-edges]]). So the protocol shard is *not* independently
decidable — it moves with the effect mechanism, settled 2026-07-21
([[decision-effect-facets]]); edge 14's own sync-vs-async residue was **shaped
2026-07-25** as continuation placement (in-place vs moved `KontMsg`, both
already-legal), leaving a narrower open **mechanism decision** (the scheduler +
two-step liveness), not a forward build.

**C7 · Staging is a port.** Staging is itself a crossing in the frozen set:
"who may stage is governed like any crossing: spawn sits in a
profile's frozen port set or that profile cannot use it". ⚑ The extern this
cross-cut names, `spawn : (=> Str Sock)`, is **not in the live registries**. The
one spawning crossing there is `spawn-in-pty : (=> Bytes Bytes I64)`
(`lib/ports/pty.port:47`), which hands back a pid and no `Sock`, so the
`Sock`-handing shape below is the design and not a declared crossing. So
"birth a runtime" and "hold a port to it" are the same act: the staging connector
([[joining-law]]) hands the parent one `Sock`, and teardown is *consuming* that
port. The runtime-lifecycle view lives in [[banks/runtime]]; the port is what it
is *made of*.

---

## 4. Native → chirality translation (the misfire → the correction)

**"You need file descriptors / handles."**
→ Correction: an fd is a porttype value (Shard 1) — but chirality keeps the *linear
authority* and discards the *integer*. `Fd` is opaque; there is no fd *number* a
program can forge, dup, or leak, because the value is move-only and the number
lives in B behind the membrane. The
"handle table" a kernel keeps is refracted into the checker's linearity discipline
(E8). Genuinely-new shard: none.

**"You need a socket API."**
→ Correction: a socket is a porttype (`Sock`/`LSock`) whose *protocol states are
distinct types* (Shard 8) and whose operations are externs threading it linearly
(`sock-recv` returns `RecvR` carrying the moved-back `Sock` or a named
`recv-closed` event). "A closed stream is a named event in the type, not a
sentinel value" (`lib/ports/sock.port:21`). The BSD socket API's fused blob (fd + state +
errno) splits into porttype + protocol + alarm. New shard: formal session-typing of
the state machine is edge 14 (§5).

**"You need syscalls / an FFI to reach the OS."**
→ Correction: a syscall is an extern (Shard 2) — the *type* owned in chirality source,
the syscall itself in B behind the membrane. The sys-face
(`lib/lowering/tal/sys.chiral`)
already carries write/read/lseek/memfd/ftruncate/mmap/munmap as typed crossings
(E28); the FFI "binding" a conventional language trusts blindly was to be replaced
by the inbound check at the crossing, which is Shard 4's design and has no live
referent. Genuinely-new shard: the *transport self-host* (E51), whose live seam is
`lib/lowering/tal/sys-linkage.chiral`, and mprotect/close (§5).

**"You need an interface / API / abstract class for encapsulation."**
→ Correction: **"API" fuses two things chirality splits** — the port-set-as-contract
(the outward face, Shard 7 / [[banks/module]] Shard 4) *and* an implementation
(the interior, a private matter). An interface exports method *signatures*; a
port-set exports *typed crossings with effects and linear state*, and "private" =
"not a port." An OO method is a crossing; a vtable is the incidental dispatch
carrier chirality discards. No interface construct is owed — the encapsulation an
abstract class offered is strictly weaker than a checked linear membrane.

**"You need a permissions / capability subsystem."**
→ Correction: authority *is* the held port-set (C1); there is no subsystem to
build, only the port under the possession view ([[banks/capability]]). What is
genuinely forward is grant/attenuate/delegate/revoke over that port (only *Move*
built; §5) — but those are operations on the existing port, not a new object.

---

## 5. What's genuinely new / unbuilt — the honest residue

Only the residue, gradients preserved, tiers named. Nothing rounded to done or to
undone.

⚑ **THE RESIDUE IS NOW MEASURED PER PORT, and the map is not here.** E170 lane E
(2026-08-29) ran the question *does this port's type reject a wrong implementation
that satisfies its shape* over all ten porttypes and recorded the answer facet by
facet. The map lives in `.planning/RUNG1-CHECKLIST.md` §Lane E — with the coverage
tables Lanes C and D landed in, because it is a coverage claim and this bank is the
concept's refraction — and Phase 12 rows E1–E10 keep it honest. What it changes for
this bank, in four lines, each of which is a committed fixture and not a reading:

- **Custody is the only facet that carries meaning across the whole family**, and
  it is Shard 1's one mechanism rather than ten answers: every porttype is an
  opaque linear atom, so every one refuses a dropped or duplicated capability
  (E8: 10/10, quantified over the family read off the tree; E9 is its direction
  control). Only **three** ports carry anything beyond custody — `Sock`'s
  `(refine I64 (> 0))` on `sock-recv`, `Pool`'s value index (Shard 6), and
  `Secret`'s nominal identity.
- **Shard 3's ceiling, stated as a zero:** no port type in the tree says anything
  about **what a crossing does**. A `sock-send` stand-in with the crossing's exact
  type that reports success and sends nothing typechecks. "The port-check is the
  type-check" buys custody of the authority, not the effect.
- **Non-forgeability is 0 for every port.** Every cap has an ambient mint —
  `adopt-fd` and `adopt-pty` from a bare `I64`, `env-open` from `Unit`,
  `secret-seal`, `backend-open`, `pool-create`, `sock-connect`/`sock-listen`/
  `socketpair`. Holding a port is evidence of a threading obligation discharged,
  **not of provenance**; the §1 bullet "a held port is a capability" should be read
  with that limit attached. And **42 of the 62 crossings took no
  capability at all**, measured 2026-08-29 over the pre-migration tree — the
  no-ambient-authority violation this bank names in §1,
  now with a number and a program (`pe-ambient-w`: the real `write(2)`, no `Fd`
  held, beside `fd-close`, which demands one).
- **Shard 8 gets its program.** *"Do not assert ports are session-typed"* is
  now measured: `recv-closed (1 sock Sock)` hands back a plain `Sock`, so a send
  on a socket the peer has already closed typechecks (`pe-send-after`, row E7b).
  Protocol state lives only in the `Sock`/`LSock` split, which E4 shows is real
  and which is the whole of it.
- **`Clock` and `Timer` are UNINHABITED.** No extern returns either and a porttype
  has no constructor, so `time-mono` and `sleep-ms` are crossings no program can
  reach and `supervisor.chiral`'s `(1 c Clock)` parameter makes it uncallable from a
  root. Their types still refuse a drop or a duplicate — a refusal quantified over
  an empty set of callers.

1. **The outbound confinement half of the membrane (Shard 5) — BUILD / not
   built.** Inbound integrity (`bridge.verify`) is CONFORMS; outbound confinement
   (no live capability leaks to B, exposure window bounded, encrypt-if-secret) has
   **zero code** (CONFORMANCE-MAP D "Outbound confinement not built"; overlaps
   E44). This is the port's single largest unbuilt shard — the membrane is
   half-preserving today.

2. **The port protocol / session-typing (Shard 8) — OPEN mechanism DECISION (edge
   14), narrowed.** *Not a forward build — a decision.* Direction narrowed
   (move-only, message-passing, no aliasing); the sync-vs-async residual was
   **shaped 2026-07-25** as **continuation placement** (in-place vs moved `KontMsg`
   continuation, both already-legal machinery from [[decision-effect-facets]]), so
   the open part narrows to a runtime scheduler for moved continuations + the
   two-step liveness engineering. Tied to the effect-mechanism decision (edge 16 /
   E39), so it cannot be settled in isolation. Today protocol state is carried only
   as distinct porttypes + linear threading, not as a formal session type. **Do not
   assert ports are session-typed.**

3. **The typed-effect-row refinement of the crossing (Shard 3) — REFACTOR (E39;
   edge 16 resolved 2026-07-21, [[decision-effect-facets]]).** The crossing/pure
   split is a coarse **boolean** today (`prim_is_port`, conv-by-equality).
   Enriching it to the named effect row — under the settled mechanism: a handler
   is the process at the other end of the port, CPS-elaborated to linear
   closures, resumption multiplicity graded by the continuation's QTT quantity,
   abort by synthesized cancel; alarms and counter-effects are crossings in the
   row — is E39, which gates alarms (E26) and the self-host seam (E51).
   Gradient: the P3 *shape* CONFORMS; the *effect algebra* under it is unbuilt.

4. **Transport self-host (E51) — REFACTOR; edge 16 resolved 2026-07-21
   ([[decision-effect-facets]]), the remaining gate is the E39 row shape.** The
   Python impl table this row was written against is gone with the oracle. The live
   seam is `lib/lowering/tal/sys-linkage.chiral`, which routes an effectful extern
   through a hand-tal wrapper over the sys crossings, and its own header scopes v1
   to the three ambient writers, leaving sockets, poll and spawn to lane A
   (CONFORMANCE-MAP D "E51 sys-face linkage"). This does not
   reshape the *contracts* (Shard 2) — it swaps what sits behind them. Adjacent:
   sys-tal's memory/fd bank is complete (E28 implemented 2026-07-28); the
   socket/poll/spawn crossings remain E29/E31/E33.

5. **Grant / revoke / delegate over the held port (C1) — mostly DESIGNED.** Only
   *Move* (linearity) is built. Subtyping is present but **not applied to grant
   narrowing** (a present-but-unapplied EXTEND); revoke/delegate and the broker's
   AUTH/AUDIT are genuine BUILD (E40/E43, edges 7/8). The permission-model doc's
   "done" is a stale overclaim, not a live path (CONFORMANCE-MAP D "Grants /
   revocation"). Revocation lands as a dead port → alarm → counter-effect — a
   *design* chain, mostly in other homes ([[banks/capability]],
   [[banks/effect-and-alarm]]).

6. **The C evidence bridges (Shard 4, richer inbound) — BUILD, E55 (2026-07-21
   catalog extension).**
   Beyond the dynamic tag-check, the named evidence-producing crossings
   (attestation, freshness, audit, isolation, reflect-raw) where proof runs out at
   B are **docs-only** — "one bridge elaborator per evidence element, each
   re-checking a cert via bridge-preserve-check" (CONFORMANCE-MAP D "C evidence
   bridges"; edge 12). Not a refactor of `verify()`, a forward family.

Gradient summary: the port's **substance** (opaque linear atom), its **contract**
(extern), its **crossing-detection** (effect-derived), its **inbound integrity**,
its **value-indexing**, and its **frozen set** are all CONFORMS/ENFORCED — the
mechanism the whole governance vocabulary rests on is *built*. The real edges are
**outbound confinement** (unbuilt), the **session-typed protocol** (open decision,
edge 14), the **effect-row** enrichment (E39), **transport self-host** (E51), and
**grant/revoke** over the held port (mostly designed). Do not describe the built
shards as missing; do not describe the residue as present.

---

## 6. Relational anchors — thin notes that should link INTO this bank

- [[vocabulary]] — the `port`, `port protocol`, `membrane`, `capability`, `grant`
  entries (the definitional source; §1).
- [[glossary]] — the one-line `port` / `membrane` / `capability` truth; point here
  for depth.
- [[category-typed]] — "the port set" (Shard 7) and "the handoff to C" (Shards 4/5,
  the bridge runs both ways).
- [[category-bridge]] — the inbound/outbound membrane (Shards 4, 5).
- [[open-edges]] — **edge 14** (port protocol / session-typing, Shard 8 + C6),
  edge 16 (effect mechanism), edge 18 (frozen-set / whole-assembly conformance).
- [[banks/capability]] — "a port held IS a capability" (C1); the possession view.
- [[banks/effect-and-alarm]] — "crossing = effect; the port-check is the
  type-check" (C2); inbound divergence as alarm.
- [[banks/module]] — "the port-set IS the module's outward face" (C3, its Shard 4).
- [[banks/profile]] — the frozen set as a capability manifest (C4, its Shard B).
- [[banks/memory]] — "space is a port", `(Pool n)` (Shard 6, C5).
- [[banks/runtime]] — staging is a port; the runtime the `spawn` crossing births
  (C7).
- [[permission-model]] — grant/attenuate/revoke over the held port (§5.5); note its
  "done" is a stale overclaim.
- [[status-ledger]] — build-state rungs for the frozen-port-set, inbound bridge,
  and the port residue (authoritative, mirrored here).
