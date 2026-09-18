---
node: banks/runtime
layer: bank
tier: depth
related: [process-and-runtime, node-architecture, modules-broker, error-and-alarm, banks/profile, banks/module, vocabulary, glossary, status-ledger, open-edges]
status: draft
updated: 2026-09-18
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
| **The evaluator** — the thing that walks checked terms and produces values | E15: `lib/evidence/interp.chiral` — a big-step tree-walk over the pure fragment, in the trampoline idiom | **BUILT for the pure fragment.** Its own header scopes it: the extern/port/bridge face and the linker are the deferred connector (`:19-21`) |
| **The supervisor** — critical sections, register-root custody, the scheduler | E42: the [[modules-broker]] component-broker as specified | **DESIGNED** for those three. ⚑ `lib/runtime/supervisor.chiral` exists as E42 v1, a coarse-`=>` supervised event loop with alarm-as-crossing; the three named halves have no referent in it ([[status-ledger]] line 208-211) |
| **The node** — the running system as a peer in the graph | the process-at-system-scale of [[node-architecture]] | a *view*, not a separate artifact |
| **The staged configuration** — this particular live wiring of modules | what a [[banks/profile]] stages via the CLI staging connector | the *result* of staging; changes per profile |
| **The native execution substrate** — "what actually runs the metal" | the tal floor + the x86-64 Mach emitter + sys-face, over the untyped B substrate | **BUILT** (host-mediated): `bin/chirality-bin` runs, and what loads it is the kernel. `E20` is not one of its parts — since `a4d98ce` that number names the *unbuilt* typed seal, `design`. W^X does not hold in the built path, see Shard F |

The **hazard is named in the ledger itself**. [[status-ledger]] states what
`lib/runtime/` actually holds: `poll.chiral`, `proc.chiral` and
`supervisor.chiral`, "a coarse-`=>` supervised loop, a process face, a poll face.
The rung-2 halves have no rung-1 referent and `supervisor.chiral` says so." The
CONFORMANCE-MAP has two adjacent rows that must never be
collapsed: *"Reference interpreter / evaluator + linker … This is E15 (golden
semantics), **NOT** the E42 supervisor — keep distinct"* and *"Runtime supervisor
as specified … Not built; runtime.py is evaluator+linker, no
crit-sections/GC-roots/scheduling."* ⚑ Both map rows are phrased against the cut
Python oracle and predate `lib/runtime/supervisor.chiral`; the distinction they
draw survives the rephrasing and the artifact they name for the built side does
not.

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
authoritative from `records/conformance-map.md` and [[status-ledger]].

### Shard A — the evaluator (E15) · **BUILT / CONFORMS**

What a tree-walker does: reduce checked terms to values, run the event loop.
**Home:** the reference interpreter, a golden semantics distinct from the kernel's
NbE (which serves *type-checking*, not execution) — what "golden" means once the
Python reference is evicted at self-hosting is E71's open decision (2026-07-21
catalog extension). **State:** built for the pure fragment.
`lib/evidence/interp.chiral` is the live artifact: `eval-step` at `:75`, `run` at
`:100`, the trampoline hop an ordinary tail call so `run` is constant-stack by
construction. Its scope is stated in its own header, var/lit/lam/app/let/case, with
the extern/port/bridge face and the linker deferred (`:19-21`).
⚑ **Corrected 2026-09-04: the evaluator does not erase q=0 lets.** The claim
described the cut Python oracle. `lib/typing/kernel.chiral:680` is the live let
arm, `((t-let q v b) (eval-term (cons (eval-term env v) env) b))`, which pushes the
value whatever the quantity says and never reads `q`. What erases at eval is the
**annotation**, `:681`, `((t-ann tm ty) (eval-term env tm))`, whose own comment
reads "annotations erase at eval". Quantity erasure is a separate mechanism with
its own home; [[banks/erasure]] shard A holds it. The evaluator still carries no
usage bookkeeping, because quantities were checked statically. CONFORMANCE-MAP class
CONFORMS, E15, and that row's own wording, "erases q=0 lets", carries the same
error.

### Shard B — the linker (E15, same file) · **BUILT / CONFORMS**

Resolving externs to host implementations at load, the "main-is-process" gate.
**Home:** the link step of the staging story. **State:** ⚑ **the artifact this
shard described has no live referent, recorded 2026-09-04.** `RT.__init__`
refusing to run when a declared extern lacks a host impl was the Python oracle's,
and `lib/evidence/interp.chiral:19-21` names the linker as E15's deferred
connector. What is live is the *load-time* half in the compiler's own front end:
`load-extern` (`lib/module/loader.chiral:457`) elaborates an extern's declared
type, refuses it unless it is a universe, and installs it into the Sig, and
`lib/lowering/tal/sys-linkage.chiral` is the seam that routes an effectful extern
to a hand-tal wrapper. The "every extern has an implementation before anything
runs" gate is not among them.

### Shard C — the staging connector (the "changes as configured" axis) · **BUILT / CONFORMS**

The act that *births* a runtime from a profile: verify the staged profile, verify
the entry crossing's type, hand the node its one port. **Home:** the CLI
`_spawn_run`, the child half of the staging connector ([[joining-law]],
[[modules-staging]]). **State:** ⚑ **no live referent, recorded 2026-09-04.**
`_spawn_run` was the Python CLI's: it refused to stage unless a profile was
declared and valid, checked `node-main` conv-equals `(=> (1 peer Sock) Unit)`, and
handed the child exactly one `Sock`. None of that is in `bin/chirality`, which
fixes the entry symbol at `compile-main` (`:88-89`) and knows nothing about
profiles. So the child half of the staging connector is **designed and unbuilt**,
and the "changes as configured" seam below describes what a profile *varies*
rather than a seam that runs.
What a profile actually varies, and therefore what a re-configured runtime differs
in ([[banks/profile]] owns the detail):

- **module set** — which modules are wired in (the profile is a named set of
  modules over a target);
- **port set** — rendered over the *frozen* port set; the profile is additive over
  it and `mf-check-ports` (`lib/surface/parse.chiral:907`) rejects pure ports and
  unknown crossings;
- **memory discipline** — `(memory linear)` vs region, a profile clause pointing
  at `lib/memory/mem-linear.chiral` / `lib/memory/mem-region.chiral` (E22);
- **`(total)` gate** — whether per-def termination is *enforced* for this staging
  (`tot-gate`, `lib/typing/totality-check.chiral:153`, reached from
  `lib/lowering/compile-front.chiral:371`, E11).

Two profiles over the same target stage two different runtimes. That is the axis in
one sentence: *the runtime is a value of the staging function, and the profile is
its argument.*

### Shard D — the supervisor (E42) · **DESIGNED / BUILD**

Critical sections, register-root custody, the scheduler — the irreducibly-dynamic
part that cannot be decided at compile time. **Home:** the **component broker (C)**
of [[modules-broker]]: "*the runtime supervisor of the part that cannot be decided
at compile time: process and runtime lifecycle (spawn and teardown), dynamic grant
and revoke, audit reconciliation against live state … a typed supervisor over
untyped runtime reality.*" **State:** the three named halves are DESIGNED and
absent. CONFORMANCE-MAP E42, class BUILD, reference
class PAPER (seL4/microkernel): *"Not built; runtime.py is evaluator+linker, no
crit-sections/GC-roots/scheduling."* ⚑ **Updated 2026-09-04: a v1 exists.**
`lib/runtime/supervisor.chiral` is E42 v1, a supervised event loop on the coarse
`=>` bit that multiplexes fd-readiness and fired alarms through one blocking
`poll` timeout, dispatches exactly one unit of work per tick, and threads the
linear `SockVec` and `Clock` caps on every arm. An alarm there is a crossing
rather than an ambient signal. The map row predates it and reads against the cut
oracle. What is still absent is exactly the three this shard names: critical
sections, register-root custody, and a scheduler ([[status-ledger]] lines 208-211,
which says `supervisor.chiral` says so itself). What *is* built of the broker
beside it is the thin dynamic slice **spawn / teardown / link-at-load**
([[status-ledger]] Broker row: `lib/runtime/proc.chiral` for spawn and teardown,
`load-extern` in `lib/module/loader.chiral` for link-at-load; grant, revoke and
audit have no code).

### Shard E — the node view (distribution) · **view, distribution native**

The runtime as a peer in the communicating graph. **Home:** [[node-architecture]].
**State:** a *perspective* on shards A–D, not a separate artifact. The port to a
node "*works the same whether the other node is on this CPU or across the mesh*"
(Adhikara carries the capability over the wire — designed). This is why "the
runtime" need not be one place: a remote node is one you hold a port to.

### Shard F — the native execution substrate · **BUILT (host-mediated) / the W^X seal unbuilt**

"What actually drives the metal." Refracted again into: the **tal floor** (typed
assembly + trusted interpreter, E18/E19, BUILT/CONFORMS), the **x86-64 Mach
emitter** (E19, BUILT), and the **sys-face syscall crossings** (E28,
`lib/lowering/tal/sys.chiral`, all nine present —
write/read/lseek/memfd/ftruncate/mmap/munmap/mprotect/close, `nb-sys-mprotect-t`
at `:113` and `nb-sys-close-t` at `:200`; CONFORMANCE-MAP E28 CONFORMS since
2026-07-28). The untyped reality underneath — devices, RAM, the register
root — is **category B substrate**, owned by nothing ([[modules-substrate]],
[[node-architecture]] "The substrate is owned by nothing"). Note the honest TCB
caveat from [[status-ledger]]: even ENFORCED properties rest on the
Linux-syscall host, and adversarial enforcement arrives with self-hosting (E51).
⚑ The CPython half of that caveat is spent: the oracle is cut and
`bin/chirality-bin` is the compiler that compiles everything.

⚑ **There is no loader in this shard, and that is the 2026-09-18
re-derivation.** The list above carried an **E20 loader** among the built parts
and described it as `built` in LEDGER. Both halves are false now, and they went
false in opposite directions, so the repair is a re-measurement rather than a
second demotion. What loads `bin/chirality-bin` is the **kernel**: `readelf -l`
reports one `PT_LOAD` and file type `EXEC`, and nothing chirality-side maps or
seals code at run time. `E20` names the work that would — a mapping taken
writable and then sealed executable so that W^X holds as a *type* fact — and
that work is **unbuilt**. `docs/elements/ledger.md:162` files it module
`map-seal`, state `design`, titled *"Typed W^X loader: `MapRW` sealed to
`MapRX`"*; `docs/elements/catalog.md:126` opens `Not built.`;
`docs/examples/INDEX.md:68` keeps `audited`, an audited SPEC standing over work
nobody has built. `records/author-calls.md:100` is the ruling that named the
surviving element, on 2026-09-18, and `docs/elements/ledger.md:465` closes the
reconciliation row. So the shard is rated **BUILT (host-mediated)** on what runs
and the seal is carried in §5 as residue; the substrate being built and the
seal being unbuilt are two claims, and this shard spent its whole life
conflating them.

⚑ **W^X does not hold in the built path.** `docs/definitions/status-ledger.md:214`
demotes that row to **NOT HELD in the built path**. The emitter writes `p_flags`
`7`, `PF_R|PF_W|PF_X`, at `lib/lowering/x64/elf.chiral:70`, under the comment at
`:59-64` naming the segment split *"the named W^X follow-on"*; `readelf -l
bin/chirality-bin` prints that one segment's flags as `RWE` and reports no other
`LOAD`, measured 2026-09-18. `nb-sys-mprotect-t` does exist and the entry stub
does call `mprotect`, at `lib/lowering/compile-emit.chiral:83`, but the prot it
passes is `3` at `:87`, `PROT_READ`+`PROT_WRITE`, which is `E89`/`E91`'s arena
reserve-commit and makes no W→X transition (`docs/elements/catalog.md:126`).
The static-ELF segment split that would is `E34`'s, carried as a wanted on
`lowering-and-emit/LE15`. The load-time seam that *is* built, `load-extern`
link-at-load, is Shard B's and is a third thing again.

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
(`eval-term`, `lib/typing/kernel.chiral:672`) serves *type-checking*; the
**evaluator** (`eval-step`, `lib/evidence/interp.chiral:75`) serves
*execution*. Two reducers, deliberately separate. Conflating them
is a smaller cousin of the main overload.

---

## 4. Native → chirality translation (the misfire and its correction)

**The misfire:** *"chirality is missing its runtime — you need a runtime system / a VM
/ a scheduler like the JVM or Go's."*

**The correction:** "The runtime" is not one engine; it is a plural,
configuration-relative sum, mostly already built:

- **the evaluator** — BUILT for the pure fragment (E15,
  `lib/evidence/interp.chiral`);
- **the linker** — ⚑ the runtime-side link gate has **no live referent** (Shard B);
  the load-time half is `load-extern` (`lib/module/loader.chiral:457`);
- **the staging connector that births it from a profile** — ⚑ **no live referent**
  (Shard C); `bin/chirality` knows nothing about profiles;
- **the native execution substrate** (tal floor + Mach emitter + sys-face) —
  BUILT, host-mediated (E18/E19/E28); `bin/chirality-bin` is a static ELF the
  kernel enters, no chirality-side loader stands in that path, and W^X does not
  hold in it (Shard F). The typed seal that would hold it is `E20`, `design`
  and unbuilt (§5);
- **the supervisor** (scheduler, critical sections, register-root custody) —
  those three **DESIGNED and absent** (E42), over a built v1 event loop
  (`lib/runtime/supervisor.chiral`), and it is the component **broker**, not a
  separate manager;
- **the node view** — a *perspective* that also makes it distributable (native).

So the correct sentence is: *chirality has an evaluator + linker + staging connector +
native substrate (built), a supervisor (designed as the broker, E42), and a node
view; "the runtime" is what a particular profile stages, not one engine beneath
everything.* If the concern is scheduling / GC-roots / critical sections
specifically, that is the supervisor's three named halves (E42) — name it
precisely, don't call the whole thing missing. If the concern is W^X, that is
`E20`'s typed seal, `design` and unbuilt — name that precisely too, and do not
let it take the running substrate down with it.

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

- **The typed W^X seal — DESIGNED, not built (`E20`).** The built substrate
  emits one RWX `PT_LOAD` and the kernel loads it; a mapping taken writable and
  then sealed executable, so that W^X holds as a *type* fact, is the unbuilt
  residue. `docs/elements/ledger.md:162` reads state `design`, module
  `map-seal`; `docs/elements/catalog.md:126` opens `Not built.`; the file the
  worked example names, `lib/loader.chiral`, does not exist, and no
  `MapRW`/`MapRX` porttype exists anywhere. `docs/examples/INDEX.md:68` keeps
  `audited`: the SPEC passed its audit and nobody built it, which is what
  `design` and `audited` say together. ⚑ Two neighbours are *not* this one: the
  `REFACTOR` at `records/conformance-map.md:115` records the 2026-07-29
  mechanism refactor that put memory mapping chirality-side, and the static-ELF
  segment split is `E34`'s wanted on `lowering-and-emit/LE15`. Ruled 2026-09-18,
  `records/author-calls.md:100`.

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
tal floor, Mach emitter, the nine sys-face crossings — is **built**. The
residue is: the typed W^X seal (`E20`), the supervisor's
scheduler/crit-sections/register-root, the broker's grant/revoke/audit, the
binding-time modality, cross-node alarms, and self-hosting. Do not describe the
built shards as missing; do not describe the residue as present.

⚑ **That instruction spent eighteen days protecting a false claim, so read it
with its history.** The list above named "W^X loader" among the built shards
from `6707f1f` (2026-08-31, the doc-tier hoist) to `9302d5a` (2026-09-18), and
the sentence beside it told the next reader not to call the built shards
missing. `docs/definitions/status-ledger.md:214` had demoted the W^X row on
2026-08-31, the same day, so the loader was the one item in the list nobody had
built for every day the instruction stood over it.
The instruction is right and the list was wrong, which is the failure mode worth
naming: a *do-not-say-X* rule inherits whatever list stands next to it, so the
list is the half that has to be re-measured. Both halves of the `E20` claim
moved in opposite directions — `9302d5a` demoted the W^X half here while the
ledger still read `built`, and `a4d98ce` then moved the ledger to `design`, so
re-applying either correction unchanged would have landed the error the other
way round. The standing rule for this bank: **the substrate is built, the seal
is not, and those are two claims.**

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
- [[status-ledger]] — what `lib/runtime/` holds against what the `runtime` note
  specifies; the authority for build-state, mirrored here.
- [[banks/profile]] — the "changes as configured" axis (staging detail lives
  there, not here).
- [[banks/module]] — the module set a profile wires into a runtime.
- [[open-edges]] — edge 8 (broker decomposition), edge 17 (cross-node alarm),
  edge 7 (adhikara), edge 5 (reflective floor / register-root).
- [[modules-staging]] — spawn/teardown as staging; the binding-time modality.
