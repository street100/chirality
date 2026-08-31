---
node: banks/runtime
layer: bank
tier: depth
related: [process-and-runtime, node-architecture, modules-broker, error-and-alarm, banks/profile, banks/module, vocabulary, glossary, status-ledger, open-edges]
status: draft
updated: 2026-07-21
---

# Bank: runtime

> **What a bank is.** A depth dossier for one concept, sitting *under* the thin
> relational notes in `docs/`. The thin notes state one idea and link out; this
> holds the full refraction of a concept that a conventional language ships as one
> monolith. Read [[process-and-runtime]] / [[node-architecture]] first for the
> one-idea view; come here for the decomposition, the build-state, and the
> misfire it prevents.

The word **runtime** is the single richest source of misfires in this base,
because it is the word for a thing every other language ships as one artifact —
*the runtime system, the VM, the interpreter, the thing that's doing the
language* — and chirality has no such artifact. Going by the standard vague definition
("what's the thing that's *doing* the language?"), the honest answer here is: it
is **multiple things, and it changes as configured.** That plurality is the whole
content of this bank. An agent that sees "chirality is missing a runtime / needs a
scheduler like the JVM / needs an RTS" has mistaken a refracted sum for a missing
monolith.

---

## 1. The concept in chirality

### The definition, sharpened

From [[vocabulary]], the pinned truth:

> **runtime.** *Is:* a process at the scale of a running system, a configuration
> of modules and connectors staged live, itself built of processes. *Is not:* a
> separate engine your program runs on. **There is no privileged runtime beneath
> everything.**

Three things are packed into that, and each is a distinct claim:

1. **Self-similar.** A runtime *is* a process; a process run is a runtime; a
   runtime is built of processes ([[process-and-runtime]], P2 taken all the way).
   The noun does not split into "atom type" and "runtime type" — it is one type
   discipline at two scales, so the [[splitting-law]] does not fire. There is no
   privileged runtime-system *beneath* your program, because that would be a
   *different* kind of thing, and chirality has exactly one kind. The cascade bottoms
   out at the bootstrap floor (register root + agreement), not at an RTS.

2. **A staged configuration → it changes as configured.** A runtime is not a fixed
   engine; it is *what a profile stages*. Change the profile and you have staged a
   *different* runtime — a different module set, a different port set, a different
   memory discipline, possibly a `(total)` gate. This is the "changing as
   configured" axis, and it couples directly to [[banks/profile]]: the profile is
   the *recipe*, the runtime is the *dish*. There is no runtime-in-general; there
   are only the runtimes particular profiles stage.

3. **A node, seen from outside.** Seen as a peer in the communicating graph, a
   process-runtime is a **node** — a compiler-plus-runtime bundle you hold a port
   to ([[node-architecture]]). A *remote* node is just one you hold a port to
   across the mesh; distribution is native, so "the runtime" is not even
   necessarily *here*.

### The overload — spell it out (this is where misfires happen)

"Runtime" in this codebase names **at least four different referents.** Precision
here is the entire job of the bank, because the same word slides between a *built*
artifact and a *designed* one:

| When someone says "the runtime" they may mean… | Referent | Artifact / status |
|---|---|---|
| **The evaluator** — the thing that walks checked terms and produces values | E15: `scaffold/chirality/runtime.py` — a strict tree-walking evaluator + the load-time linker | **BUILT** |
| **The supervisor** — critical sections, register-root custody, the scheduler | E42: the [[modules-broker]] component-broker as specified | **DESIGNED**, not built. `runtime.py` is **NOT** this. |
| **The node** — the running system as a peer in the graph | the process-at-system-scale of [[node-architecture]] | a *view*, not a separate artifact |
| **The staged configuration** — this particular live wiring of modules | what a [[banks/profile]] stages via the CLI staging connector | the *result* of staging; changes per profile |
| **The native execution substrate** — "what actually runs the metal" | the tal floor + W^X loader + sys-face, over the untyped B substrate | **BUILT** (host-mediated), see §2 |

The **hazard is named in the ledger itself**. [[status-ledger]] sharpest-gap #5:
"*The `runtime` note describes a different artifact than `runtime.py`.*" The
DESIGNED-only list closes with: "*`runtime` as specified (critical sections,
register-root custody, scheduler — `runtime.py` is an evaluator + linker, a
different artifact).*" The CONFORMANCE-MAP has two adjacent rows that must never be
collapsed: *"Reference interpreter / evaluator + linker … This is E15 (golden
semantics), **NOT** the E42 supervisor — keep distinct"* and *"Runtime supervisor
as specified … Not built; runtime.py is evaluator+linker, no
crit-sections/GC-roots/scheduling."*

### The native monolith it is confused with

The RTS / VM / "the interpreter": one privileged artifact your compiled program
runs *on top of* — the JVM, the CLR, the Python VM, the Go runtime with its
scheduler and GC. In that model the runtime is (a) singular, (b) beneath
everything, (c) privileged, and (d) fixed. chirality denies all four: it is plural,
peer-level, unprivileged (authority is a port's type settled at stage time, not a
runtime entity behind a boundary — [[node-architecture]] "Not kernel-centric"),
and configuration-relative. "There is nowhere for a kernel to be. There are only
nodes and ports."

---

## 2. The refraction — the shards and their homes

The conventional "runtime system" decomposes into these shards. For each: what it
is, its principled home, and its build-state with evidence. Build-state is
authoritative from `.planning/audit/CONFORMANCE-MAP.md` and [[status-ledger]].

### Shard A — the evaluator (E15) · **BUILT / CONFORMS**

What a tree-walker does: reduce checked terms to values, run the event loop.
**Home:** the reference interpreter, a golden semantics distinct from the kernel's
NbE (which serves *type-checking*, not execution) — what "golden" means once the
Python reference is evicted at self-hosting is E71's open decision (2026-07-21
catalog extension). **State:** built complete.
`scaffold/chirality/runtime.py:1` — "*strict tree-walking evaluator over checked
kernel terms, with tail-call iteration so long-running event loops do not grow the
python stack.*" Erases q=0 lets (`runtime.py` `run`, ~line 65); carries no usage
bookkeeping because quantities were checked statically. CONFORMANCE-MAP class
CONFORMS, E15. This is the thing `runtime.py` *actually is*.

### Shard B — the linker (E15, same file) · **BUILT / CONFORMS**

Resolving externs to host implementations at load, the "main-is-process" gate.
**Home:** the link step of the staging story, folded into `RT.__init__`.
**State:** built. `runtime.py:36` — `RT()` verifies *every* declared extern has a
host impl before anything runs (`missing = [n for n in sig.prim_types if n not in
IMPLS]` → raise). `runtime.py:10` — "*Externs are declared in chirality source and
bound here at load … That is the link step of the staging story, at scaffold
scale.*"

### Shard C — the staging connector (the "changes as configured" axis) · **BUILT / CONFORMS**

The act that *births* a runtime from a profile: verify the staged profile, verify
the entry crossing's type, hand the node its one port. **Home:** the CLI
`_spawn_run`, the child half of the staging connector ([[joining-law]],
[[modules-staging]]). **State:** built. `scaffold/chirality/cli.py:101` `_spawn_run` —
refuses to stage unless a profile is declared and valid (`verify_profiles`), then
checks `node-main` conv-equals `(=> (1 peer Sock) Unit)` and hands it exactly one
`Sock` port (`cli.py:129`). **This is the concrete "changes as configured" seam.**
What a profile actually varies, and therefore what a re-configured runtime differs
in ([[banks/profile]] owns the detail):

- **module set** — which modules are wired in (the profile is a named set of
  modules over a target);
- **port set** — rendered over the *frozen* port set; the profile is additive over
  it and `verify` rejects pure ports / unknown crossings;
- **memory discipline** — `(memory linear)` vs region, a profile clause pointing
  at `lib/mem-linear.chiral` / `lib/mem-region.chiral` (E22);
- **`(total)` gate** — whether per-def termination is *enforced* for this staging
  (`surface.py` `verify_profiles`, E11).

Two profiles over the same target stage two different runtimes. That is the axis in
one sentence: *the runtime is a value of the staging function, and the profile is
its argument.*

### Shard D — the supervisor (E42) · **DESIGNED / BUILD**

Critical sections, register-root custody, the scheduler — the irreducibly-dynamic
part that cannot be decided at compile time. **Home:** the **component broker (C)**
of [[modules-broker]]: "*the runtime supervisor of the part that cannot be decided
at compile time: process and runtime lifecycle (spawn and teardown), dynamic grant
and revoke, audit reconciliation against live state … a typed supervisor over
untyped runtime reality.*" **State:** DESIGNED, not built — and this is the shard
most often mistaken for `runtime.py`. CONFORMANCE-MAP E42, class BUILD, reference
class PAPER (seL4/microkernel): *"Not built; runtime.py is evaluator+linker, no
crit-sections/GC-roots/scheduling."* What *is* built of the broker is only the
thin dynamic slice: **spawn / teardown / link-at-load** ([[status-ledger]] SEEDED
row: "*Broker — spawn / teardown / link-at-load only; grant / revoke / audit not
built*", `impl_ports.py`, `runtime.py`). The scheduler and critical-section
machinery are genuinely absent (§5).

### Shard E — the node view (distribution) · **view, distribution native**

The runtime as a peer in the communicating graph. **Home:** [[node-architecture]].
**State:** a *perspective* on shards A–D, not a separate artifact. The port to a
node "*works the same whether the other node is on this CPU or across the mesh*"
(Adhikara carries the capability over the wire — designed). This is why "the
runtime" need not be one place: a remote node is one you hold a port to.

### Shard F — the native execution substrate · **BUILT (host-mediated) / mixed**

"What actually drives the metal." Refracted again into: the **tal floor** (typed
assembly + trusted interpreter, E18/E19, BUILT/CONFORMS), the **x86-64 Mach
emitter** (E19, BUILT), the **W^X loader** (E20, IMPLEMENTED but Python-mediated —
REFACTOR to self-host), and the **sys-face syscall crossings** (E28, `lib/sys-tal.chiral`,
write/read/lseek/memfd/ftruncate/mmap/munmap built; mprotect/close missing). The
untyped reality underneath — devices, RAM, the register root — is **category B
substrate**, owned by nothing ([[modules-substrate]], [[node-architecture]] "The
substrate is owned by nothing"). Note the honest TCB caveat from [[status-ledger]]:
today even ENFORCED properties rest on the CPython + Linux-syscall host; adversarial
enforcement arrives with self-hosting (E51).

---

## 3. Cross-cuts — where the runtime surfaces as a customer of other systems

The highest-value content. "The runtime" is not self-contained; the supervisor
shard in particular is a *node* in a chain of other refractions. Chase them.

### The supervisor **is** the component broker → mediator of revocation → customer of the effect/alarm system

This is the deepest chain in the bank; it is the runtime-side of the worked
revocation example that motivated the bank tier.

1. **The supervisor is the broker.** There is no separate "runtime manager." The
   thing the design calls the runtime supervisor *is* the component broker (C) of
   [[modules-broker]] — same artifact, two names. Its referent is the live set of
   running processes (a B thing); it is "*a typed supervisor over untyped runtime
   reality.*"

2. **The broker is the mediator of grant / revoke / audit.** [[glossary]]:
   "*broker, component. The runtime supervisor of lifecycle, grant, revoke, and
   audit.*" So capability **revocation is not a capability feature** — it is a
   broker operation, mediated by the supervisor shard of the runtime, speaking the
   **adhikara** protocol (designed; edge 7 pins its correspondence to the
   capability type).

3. **Revocation lands as an effect/alarm.** A revoked linear port becomes a dead
   port; the next crossing raises an **alarm** ([[error-and-alarm]]) — a typed
   effect on the membrane, *not* an out-of-band exception — answered by a
   **counter-effect** (quarantine / halt / re-derive). So the supervisor's revoke
   is a **customer of the effect/alarm system**: it does not "kill" anything; it
   makes the next crossing diverge, and divergence is the alarm (P5). The runtime
   does not police at runtime; it arranges that the *type* of the next crossing
   carries the failure.

The misfire this kills: "chirality needs a runtime with a permission-revocation
mechanism." No — revocation refracts into broker (mediator) + port death +
alarm-effect + counter-effect, most of which live in *other* homes and are
partly designed, partly built.

### "Changes as configured" ↔ [[banks/profile]] staging

The configuration-relativity of a runtime is entirely the profile's doing. The
profile bank owns *how* staging selects module/port/memory/total; this bank owns
the consequence: **there is no runtime noun independent of a profile.** Do not
re-document staging here — point to [[banks/profile]]. (The concrete seam is
Shard C above, `_spawn_run`.)

### Self-similar process ↔ staging modality / spawn

"A runtime is a process is a runtime" is the staging connector applied to the
process model: **spawn = instantiate-and-stage; teardown = consume, linear, use
once** ([[modules-staging]], [[process-and-runtime]]). The *binding-time modality*
that would carry link/load-vs-runtime in the type is designed (Fork C, E57 —
2026-07-21 catalog extension); only the ad-hoc link-at-load slice is built. So the self-similarity is
real in the design and *partially* real in code (spawn/teardown built; the modality
that makes it type-level is not).

### Node ↔ distribution + cross-node alarm (edge 17)

The node view makes the runtime distributable, which raises a genuinely open
question: **how loud is a divergence in one node to the nodes holding ports to
it?** That is [[open-edges]] edge 17 (cross-node alarm propagation), sitting
between [[error-and-alarm]] and [[node-architecture]]. It is unbuilt and undecided
(§5) — the runtime-as-node view is what surfaces it.

### Evaluator ≠ NbE (a within-runtime cross-cut worth stating)

Even inside the built shards the word forks: the kernel's **NbE** normalizer
(`kernel.py`) serves *type-checking*; the **evaluator** (`runtime.py`) serves
*execution*. Two reducers, deliberately separate (`runtime.py:3`). Conflating them
is a smaller cousin of the main overload.

---

## 4. Native → chirality translation (the misfire and its correction)

**The misfire:** *"chirality is missing its runtime — you need a runtime system / a VM
/ a scheduler like the JVM or Go's."*

**The correction:** "The runtime" is not one engine; it is a plural,
configuration-relative sum, mostly already built:

- **the evaluator** — BUILT (E15, `runtime.py`);
- **the linker** — BUILT (E15, same file, extern resolution at load);
- **the staging connector that births it from a profile** — BUILT (E15,
  `cli.py:_spawn_run`) — this is the "changes as configured" seam;
- **the native execution substrate** (tal floor + Mach emitter + W^X loader +
  sys-face) — BUILT, host-mediated (E18/E19/E20/E28);
- **the supervisor** (scheduler, critical sections, register-root custody) —
  **DESIGNED, not built** (E42), and it is the component **broker**, not a
  separate manager;
- **the node view** — a *perspective* that also makes it distributable (native).

So the correct sentence is: *chirality has an evaluator + linker + staging connector +
native substrate (built), a supervisor (designed as the broker, E42), and a node
view; "the runtime" is what a particular profile stages, not one engine beneath
everything.* If the concern is scheduling / GC-roots / critical sections
specifically, that is the one genuinely-unbuilt shard (E42) — name it precisely,
don't call the whole thing missing.

---

## 5. What is genuinely new / unbuilt (honest residue)

Only the true gaps, with gradients preserved.

- **The E42 runtime supervisor — DESIGNED, not built.** Critical sections,
  register-root custody, and a scheduler are a *separate forward-construction
  artifact* from the evaluator. CONFORMANCE-MAP E42, class BUILD, size L,
  reference class PAPER (seL4-shaped). Gradient: the *dynamic-lifecycle slice*
  (spawn/teardown/link-at-load) **is** built ([[status-ledger]] SEEDED); it is the
  *scheduler / crit-sections / register-root custody* that are absent — not the
  whole supervisor from zero.

- **The component broker's grant / revoke / audit — DESIGNED.** The broker's
  4-part AUTH/AUDIT decomposition is **DECISION-gated on edge 8** before its
  internals can build right (CONFORMANCE-MAP E43). It sits atop the (also mostly
  designed) capability model E40, of which only *Move* (linearity) is built.
  Revocation therefore has no code yet — the chain in §3 is a *design* chain.

- **The staging / binding-time modality — DESIGNED (Fork C, E57 — 2026-07-21
  catalog extension).** The
  self-similar "runtime is a process" is type-level only on paper; code has the
  ad-hoc link-at-load slice, not the modality that carries binding-time in the
  type.

- **Cross-node alarm propagation — OPEN (edge 17).** How loud a node's divergence
  is to nodes holding ports to it is undecided; it is the distribution-native
  node view's residual.

- **The register root as a runtime obligation — DESIGNED.** Register-root custody
  (master secret in CPU registers, never in RAM — [[modules-substrate]]) is part
  of the E42 supervisor's job and is docs-only.

- **True self-hosting of the native substrate — REFACTOR (E51; edge 16 settled
  by [[decision-effect-facets]] 2026-07-21, so the gate is now *implementing*
  that decision, not awaiting it).** The execution substrate is built but runs
  chirality-logic-over-CPython-transport; the E51 sys-face linkage that would make
  it self-hosting (and enforcement adversarial rather than host-trusted) is the
  real chirality-in-chirality gate, still test-reachable-only — and E51 alone does not
  take the compiler native: effectful lowering (E70) and closure conversion +
  quantities-to-tal (E69) are the remaining lowering reach (2026-07-21 catalog
  extension).

Everything else the word "runtime" reaches — evaluator, linker, staging connector,
tal floor, Mach emitter, W^X loader, present sys-face crossings — is **built**. The
residue is: the supervisor's scheduler/crit-sections/register-root, the
broker's grant/revoke/audit, the binding-time modality, cross-node alarms, and
self-hosting. Do not describe the built shards as missing; do not describe the
residue as present.

---

## 6. Relational anchors

Thin `docs/` notes that should link *into* this bank (the bank is their depth
tier):

- [[process-and-runtime]] — the self-similar-construct one-idea view; links here
  for the overload + build-state.
- [[node-architecture]] — the node/peer view and distribution; links here for the
  evaluator-vs-supervisor disambiguation.
- [[modules-broker]] — the component broker = the supervisor shard; links here for
  the revocation cross-cut chain.
- [[error-and-alarm]] — the counter-effect end of the revocation chain.
- [[vocabulary]] / [[glossary]] — the pinned `runtime` / `node` / `process` /
  `broker` term truth; point here for depth.
- [[status-ledger]] — sharpest-gap #5 (the `runtime.py`-vs-`runtime`-note gap);
  the authority for build-state, mirrored here.
- [[banks/profile]] — the "changes as configured" axis (staging detail lives
  there, not here).
- [[banks/module]] — the module set a profile wires into a runtime.
- [[open-edges]] — edge 8 (broker decomposition), edge 17 (cross-node alarm),
  edge 7 (adhikara), edge 5 (reflective floor / register-root).
- [[modules-staging]] — spawn/teardown as staging; the binding-time modality.
