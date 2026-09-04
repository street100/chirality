---
node: banks/memory
layer: bank
tier: depth
related: [memory-model, decision-graded-kernel, modules-substrate, modules-custody, permission-model, banks/profile, banks/capability, banks/port, banks/evidence-and-split, vocabulary, glossary, status-ledger, open-edges]
status: draft
updated: 2026-09-04
---

# Bank: memory

> **What a bank is.** The depth tier under the thin relational notes in `docs/`.
> A bank holds the full *refraction* of ONE concept: what it is, the shards it
> decomposes into with their principled homes and honest build-state, the
> cross-cuts where one shard *is* a shard of another concept, and the native
> monoliths it gets mistaken for. Thin notes link *into* here; read
> [[memory-model]] first for the one-idea view.
>
> **Why this bank exists.** Every conventional language ships **memory
> management** as one subsystem — an allocator, a heap, a collector, an
> ownership discipline. chirality has no such subsystem, because **space is a port**
> (P3: "time and space are ports too"). "Memory" is therefore not one thing that
> is missing; it is a *sum of shards* living in the port/capability, refinement,
> profile, and cost-grade homes — most already built. The recurring misfire is
> to see the monolith absent and say *you need an allocator / a GC / a borrow
> checker*. You do not; each is refracted below. Build-state is AUTHORITATIVE
> from `records/conformance-map.md` and [[status-ledger]]; where a facet
> is genuinely unbuilt it is named as such, never rounded to done.

---

## 1. The concept in chirality

**The one-sentence truth ([[memory-model]]).** "Memory is governed like
everything else in this design: structurally, at the port, by linearity; there
is no runtime manager, and what varies is which discipline a profile composes
in, not what an allocator decides at runtime."

**What memory IS.**

- **A port with a size in its type.** Interior compute spends memory, so
  allocation is a port a program incurs by running (P3, [[PRINCIPLES]] — old P4
  folded into it at the 2026-07-20 condensation: "time and space are ports too"
  is P3's core). A buffer supply is a linear
  `(Pool n)` carrying its capacity `n` *in* the type (`lib/ports/pool.port:13`,
  `(porttype Pool (n I64))`). `(Pool 16384)` and `(Pool 4096)` are *different
  types*.
- **A discipline a profile chooses.** The flexibility is composition-time, not
  runtime: `(memory linear)` vs `(memory region)` is a profile clause pointing
  at a real library ([[banks/profile]]; [[memory-model]] commitment 3).
- **Conservation by linearity, not by an accountant.** A `(Pool n)` is a linear
  resource threaded and dropped exactly once; the total handed out cannot outrun
  the hardware because ports are minted from a finite linear supply
  ([[memory-model]] commitment 2). No allocator says "no" at runtime; runtime
  exhaustion is an *environment alarm* ([[error-and-alarm]]), not an accounting
  step.

**What memory IS NOT.** Not a heap. Not a `malloc`/`free` pair as ambient
authority anything can call. Not a garbage collector under every profile. Not
Rust ownership/borrow (chirality has *use-once threading*, not a borrow checker —
§4). Not "a memory pool library" (the Pool is a dependently-typed linear
*porttype*, not a data structure). Each of these fuses several shards below with
an incidental carrier chirality discards.

**How it is realized in code (evidence).** There is no allocator module and no
heap object. At the metal, a span of RAM is `mmap`'d anonymous memory: `init-heap`
at `lib/memory/arena.chiral:27` takes 64 MB of `MAP-PRIVATE | MAP-ANON |
MAP-NORESERVE` and returns it as an `(arena base len)` pair, and `arena-grow` at
`:37` doubles it when the bump cursor exhausts it. Allocation is a *cursor bump*
over that span (`alloc-growing` at `lib/memory/alloc-growing.chiral:18`, with
`alloc-fixed` at `lib/memory/alloc-fixed.chiral:17` as the non-growing profile
choice). ⚑ The measurements this paragraph used to carry, `ARENA_BYTES = 1<<20`
and a `ud2`/`MemoryError` exhaustion path, were the cut Python loader's and are
gone with it; the live arena's figure is the 64 MB above. At the chirality surface the
same span is the linear `(Pool n)`; the discipline libraries add a cursor over
it but no new kernel feature. RAM itself is **category-B substrate, owned by
nothing** ([[modules-substrate]], [[node-architecture]]: "The substrate is owned
by nothing").

---

## 2. The refraction — the shards, their homes, their build-state

Each shard is a facet the conventional "memory management" monolith fuses; in
chirality each has its own principled home and its own honest build-state.

### Shard 1 — the arena (mmap'd anonymous span as a bump region) · **BUILT / CONFORMS (E21, E25)**
- **What.** A raw span acquired from the substrate and consumed by advancing a
  cursor; frees as a unit.
- **Home.** the native execution substrate / sys-face crossings.
  `lib/memory/arena.chiral` *sets up* (`init-heap` at `:27` takes the span,
  `arena-grow` at `:37` doubles it); the **chirality side bumps** the cursor.
- **Build-state.** BUILT. **E21 self-hosted arena is COMPLETE**: chirality creates
  and sizes its own anonymous file and maps it — `memfd_create → ftruncate →
  mmap(MAP_SHARED) → byte-roundtrip → munmap`, *differentially tested*
  (`lib/lowering/tal/sys.chiral:69-90`; [[status-ledger]] "*chirality sizes+maps its own anonymous
  file*"). The self-hosted crossings present: write/read/lseek/memfd/ftruncate/
  mmap/munmap/mprotect/close — **E28 complete** (implemented 2026-07-28,
  CONFORMANCE-MAP CONFORMS; mprotect unblocks E20's W^X loader swap). TCB
  caveat: the substrate is still host-mediated until E51 (§5).

### Shard 2 — the Pool (value-indexed linear porttype) · **BUILT / CONFORMS (E30–E33, E4)**
- **What.** `(Pool n)` — one linear resource carrying its bound `n` in its type
  (dependent). You write at explicit offsets and close it once.
- **Home.** the port-set / category-C port membrane. `lib/ports/pool.port`:
  `(porttype Pool (n I64))` (`:13`), `pool-create : (=> (w n I64) (PoolR n))`
  (`:26`), `pool-write`/`pool-close` take the bound as an *erased* `(0 n I64)`
  parameter (`:27`, `:31`) — size lives in the type, nothing branches on it at
  runtime. `PoolR` bundles the pool with its `Fd` (`:15`).
- **Build-state.** CONFORMS. Opaque linear porttypes in the frozen set, host
  referents bound by `impl_ports`, linearity + frozen-set enforced by the
  checker (CONFORMANCE-MAP tags E30–E33 — a sample of the membrane's crossing
  elements, also spanning E29 sockets; not a contiguous range). The dependent index rides the value-indexed
  Pi already in the kernel (E4, [[status-ledger]]: "*Dependent types (Pi,
  value-indexed `(Pool n)`)*"). **A Pool is a linear port** — the tie to
  [[banks/capability]]/[[banks/port]] (C2).

### Shard 3 — `mem-put-checked` (the offset refined to a bound) · **CONFORMS as scoped (E22); variable-bound is E9-SEEDED**
- **What.** The bounds-checked write: the offset is refined to
  `{I64 | >=0, <n}`, so the substrate's runtime bound check is discharged **at
  COMPILE time** for literal/guarded offsets — the offset half of F8.
- **Home.** the refinement fragment / `lib/mem-linear.chiral`. `mem-put-checked :
  (-> (0 n I64) (=> (1 p (Pool n)) (refine I64 (>= 0) (< n)) Bytes (Pool n)))`
  — the `< n` references the *erased* capacity; at a concrete pool it collapses
  to a constant bound. The raw `mem-put`/`pool-write` stays for **computed
  offsets** (e.g. a strided `(* y k)`) which keep the runtime witness.
- **Build-state.** The literal/guarded slice CONFORMS (CONFORMANCE-MAP E22:
  "*bounds-checked write discharges bound at compile time … collapses runtime
  check for literal/guarded offsets*"). The general case — an offset below a
  *variable* capacity `v<n` — is **E9 SEEDED** ("*const or bare-var only;
  arithmetic-expression bounds out*", CONFORMANCE-MAP), an EXTEND, and is the
  enabling sub-capability for Shard 5 (§3, §5).

### Shard 4 — the linear discipline · **BUILT / ENFORCED (E22)**
- **What.** `(memory linear)`: write at explicit offsets, close once, no
  bookkeeping. The memory-safety backbone.
- **Home.** `lib/memory/mem-linear.chiral`, whose own header at `:8-9` says it
  adds nothing over the port floor and exists to give the discipline a name and a
  home, so `(memory linear)` in a profile points somewhere real. ⚑ That header
  still spells the floor with the pre-migration module key; a comment-only edit to
  `lib/` owes the compiler rebuild, so the repoint is deferred rather than taken
  for free. `mem-drop`
  (`:31`) closes the pool (zeroized by the
  substrate on close — but see Shard 9 on how far that promise reaches).
- **Build-state.** CONFORMS/ENFORCED (CONFORMANCE-MAP E22; [[status-ledger]]
  "*Memory discipline as a profile choice … `lib/mem-linear.chiral`*"). ⚑ The
  exercise this row cited, `tests/test_memory.py`, went with the Python oracle
  and `tools/test/` has no memory script, so the row's *test* evidence has no
  live referent. Linearity itself is a property of the TYPE
  (linear-kind, E8; CONFORMANCE-MAP "*Linearity a property of the TYPE*").

### Shard 5 — the region discipline · **lib BUILT / CONFORMS; region TYPES REFACTOR (E41/E22), edge-3-gated**
- **What.** `(memory region)`: a bump-allocated arena — a linear `Region`
  wrapping the pool plus a `used` cursor; `mem-alloc` advances the cursor and
  returns an offset; the whole arena frees as a unit.
- **Home.** `lib/mem-region.chiral`. `(data Region ((n I64)) (region (1 pool
  (Pool n)) (cap I64) (used I64)))`; `mem-alloc` reserves and advances,
  `region-close` drops the whole arena.
- **Build-state — two-part, do not collapse.** The *library* is BUILT and
  correctly shaped, but the capacity check is **still a RUNTIME branch**:
  `mem-alloc` checks `(<=i (+ used len) cap)` against a runtime capacity
  *witness* `cap` (never against the erased `n`) and `halt`s on overflow. The
  **region TYPES** feature — a refined/indexed cursor that discharges the
  capacity check *statically* and retires that runtime branch — is **REFACTOR,
  E41/E22, gated on E9 symbolic bounds (edge 3)** (CONFORMANCE-MAP: "*Region
  data gains refined cursor; mem-alloc runtime branch→type obligation … Gated on
  E9 symbolic-bound*"). The map reconciles this as two tiers of one element:
  the discipline-lib reshape (refined cursor, offsets to `(refine …)`) is the
  REFACTOR; region-types-*in-the-kernel* classes BUILD-L. **The region library
  is NOT the deferred region-types feature** — the sharpest naming trap in
  [[memory-model]] ("Naming: 'region' does two jobs").

### Shard 6 — byte cells `[len][payload]` · **BUILT / CONFORMS (E25)**
- **What.** Native arena cells: data-with-fields as `[tag][fields]`, Str/Bytes
  as `[len][payload]`, both bump-allocated from the arena the loader maps — the
  region discipline again, one altitude down.
- **Home.** `lib/lowering/tal/bytes.chiral` + the arena
  (`lib/memory/arena.chiral:27`).
- **Build-state.** CONFORMS. Real path built + self-hosted; `nb-*` prims
  preserve-checked at load, arena cells execute (CONFORMANCE-MAP E25). The host
  `bytearray` in the reference interpreter is a **deliberate differential
  oracle, not an unmet crutch to shed** — the honest framing the catalog pins.

### Shard 7 — discipline-as-profile-choice · **BUILT / CONFORMS (E2)**
- **What.** Which discipline is composed is a profile clause, checked at
  composition time; an unknown discipline is a surface error.
- **Home.** the profile manifest / `handle-profile-body` — see the sibling
  **[[banks/profile]]** for the profile's own full refraction; do not
  re-document it here.
- **Build-state.** CONFORMS. A profile carries an optional `(memory
  <discipline>)` clause; `mf-memory-of` (`lib/surface/parse.chiral:939`) admits
  `linear` and `region` and refuses anything else with `mf-memory-unknown`, at
  the moment the profile form is read. `tools/test/profile-target.sh:92` asserts
  the refusal and its message (CONFORMANCE-MAP E2).

### Shard 8 — space-as-a-grade (the cost coeffect) · **REFACTOR, settled-on-paper (E38)**
- **What.** Space reserved as a **coeffect factor in the cost semiring** —
  distinct from the region/linear *disciplines*. Where Shards 4–5 govern *who
  holds* the memory, this grade bounds *how much* a term costs, over-approximate,
  in the type.
- **Home.** the graded kernel ([[decision-graded-kernel]]): QTT's grade set
  enriched from `{0,1,w}` to a product coeffect semiring `usage × time × space ×
  info-flow`, `cost = ℕ∞`, parametric.
- **Build-state.** **DECISION SETTLED, not built.** The factor set is fixed on
  paper (option A: cost lives in the kernel as a semiring enrichment), but
  `qadd/qmul/qjoin/qfits` are hardcoded to the 3-point lattice today
  (CONFORMANCE-MAP E38, REFACTOR-L). Crucially the reshape touches the semiring
  arithmetic **but not the judgment seams** (conv/infer/check) — the containment
  win. Edges 2, 3.

### Shard 9 — zeroize / register-root custody · **type-level seed CONFORMS (E40); memory-custody + zeroize-to-floor BUILD**
- **What.** Zeroed-on-drop hygiene, and the register-root defense against
  peripheral DMA: derive-not-store, RAM holds only ciphertext + redundancy,
  cleartext lives in a bounded window.
- **Home.** the custody modules ([[modules-custody]]) + [[secure-datum-model]].
  The secret custody *seed* is built: opaque linear `Secret`, `seal/reveal/wipe`,
  a single greppable guarded exit (CONFORMANCE-MAP E40, CONFORMS *as far as it
  claims*).
- **Build-state — honest gradient.** Zeroed-on-drop is a **semantics promise the
  machine can break**: spills and dead-store elimination can leave copies, and
  carrying zeroing down to the tal floor is **unfinished** — `secret-reveal`
  returns immutable `bytes` it *cannot* zero, so host-copy hygiene is
  *inherently partial* ([[status-ledger]]; documented limit). **Memory custody,
  per-datum flow policy, and register-root/zeroize-as-type-obligation are BUILD**
  — "*vapor beyond the secret seed*", **E56** (2026-07-21 catalog extension; the
  CONFORMANCE-MAP row predates the assignment; adjacent E42 register-root
  supervisor). The register root (master secret in CPU
  registers, never in RAM) is the DMA defense of [[secure-datum-model]] §3 and is
  docs-only.

---

## 3. Cross-cuts — where a shard of "memory" IS a shard of another concept

The highest-value section: the places where refracting "memory" lands on the
*same* shard as another concept.

**C1 · Discipline-choice IS the profile's memory clause (Shard 7 ↔
[[banks/profile]]).** "Which memory discipline" is not a memory setting resolved
somewhere in a runtime — it is one of the things a profile *stages*, alongside
module set, port set, and the `(total)` gate. There is no memory policy
independent of a profile; change the profile and you have staged a different
memory regime. The profile bank owns *how* staging selects it; this bank owns
the consequence. Built (E2).

**C2 · A Pool IS a linear port, so its capacity IS part of its capability
(Shards 2, 4 ↔ [[banks/capability]]/[[banks/port]]).** `(Pool n)` is an opaque
linear porttype in the frozen set — the same shard the capability bank refracts
from the authority side ([[vocabulary]]: "capability *is* a port held"). So "how
much memory this holds" and "what authority this is" are one object: the port,
with its bound `n` in the type. Conservation-by-linearity (Shard 4) *is*
use-once capability discipline (Move, the one built half of the capability model,
E40). Consequence: you cannot duplicate a Pool to double the memory, for the same
reason you cannot duplicate a capability — linearity forbids both, at one
mechanism. Do not re-document the port here; point to [[banks/port]].

**C3 · The offset bound IS a refinement obligation (Shard 3, 5 ↔ refinement
E9).** "The write is in bounds" is *not* a runtime memory-safety check in the
compile-time-provable case — it is the refinement fragment discharging
`{>=0, <n}` (`mem-put-checked`). The region-types residue (Shard 5) is blocked on
the *exact same* mechanism reaching the variable case (`v<n`, E9 symbolic
bounds): once refinement learns non-constant bounds, `mem-alloc`'s runtime
`(<=i …)` branch becomes a type obligation. Memory bounds-safety and refinement
are one chain, not two (CONFORMANCE-MAP: E9 "*Enables E41*").

**C4 · Space-as-grade IS a factor of the cost semiring, NOT a discipline (Shard 8
↔ [[decision-graded-kernel]]).** The category error to avoid: space-the-coeffect
and region/linear-the-discipline are *different shards in different homes*. The
discipline governs custody (who holds the span, use-once); the grade bounds
consumption (how much a term costs, over-approximate, in the type). Both are
"memory", neither subsumes the other. Space rides the *coeffect* semiring (it
scales under substitution, adds under sequencing); it is emphatically **not**
totality (a property) or staging (a modality) — the three-way split the graded
decision turns on. Settled on paper, unbuilt (E38).

**C5 · Zeroize / redundancy IS a customer of custody + the split-role (Shard 9 ↔
[[modules-custody]]/[[banks/evidence-and-split]]).** Zeroed-on-drop and secret
custody are *not* a memory feature — they are the custody modules, and **custody
redundancy is an instance of split-provider agreement** (CONFORMANCE-MAP:
"*redundancy is an instance of split-provider agreement*"). So "hold the datum
redundantly and self-heal" refracts onto the same `Split` role
([[banks/evidence-and-split]]) that any unprovable-truth module requires: copies
that must agree, mediated in one place. The register root is the *one shared
dependency* the split independence discipline (Rule B, [[secure-datum-model]] §5)
is allowed, because it is unreachable by DMA. Memory-custody's zeroize is thus a
customer of evidence-and-split, not a self-contained mechanism.

**C6 · Exhaustion IS an environment alarm, not an allocator return (Shards 1, 5 ↔
[[error-and-alarm]]).** When the substrate refuses a mint the types permitted —
arena past capacity, `ud2` at the metal, `halt` in `mem-alloc` — that is an
**environment alarm** (P5), the divergence that refuses to corrupt, *not* a
`malloc` returning `NULL` for the program to branch on. The failure is carried by
the effect/alarm system, one home over. This is why there is no error path
through the allocator: there is no allocator.

---

## 4. Native → chirality translation (the misfire → the correction)

**"You need `malloc`/`free` — an allocator API."**
→ Correction: allocation is a **cursor bump over an `mmap`'d arena** (Shard 1,
`lib/memory/arena.chiral`, BUILT), and deallocation is **linear drop of the whole region as a
unit** (Shard 4/5, `mem-drop`/`region-close`). There is no allocator-of-record
and no ambient `free`; the Pool is threaded and dropped exactly once. A general
free-list allocator beyond the bump arena is genuinely unbuilt — and owed only if
a profile wants it (§5), not as a default.

**"You need a garbage collector."**
→ Correction: refracted into **space-is-a-port + discipline-as-profile +
linearity + regions**. Conservation is by linearity, not by a tracing collector
([[memory-model]] commitment 2–3). A GC is an **elaboration module *outside* the
trusted core, never kernel**, which a *permissive profile may adopt by dropping
linearity* (the dump's `chirality-app`); other profiles state its absence
structurally (`chirality-bare`, `chirality-firmware`, `chirality-systems`). So "you need a
GC" is false as a universal and true only as one profile's opt-in — the GC lives
outside the TCB by construction.

**"You need the heap — a global heap with a runtime accountant."**
→ Correction: a span of RAM is **category-B substrate owned by nothing**
([[modules-substrate]]); there is no global heap and no accountant. A resource
limit is the bound `n` *in the port's type*, not an allocator saying no at
runtime; the total handed out cannot outrun the hardware because ports are minted
from a finite linear supply. Runtime exhaustion is an *environment alarm* (C6),
not an accounting mechanism.

**"You need Rust-style ownership / a borrow checker."**
→ Correction: chirality has **linearity as a property of the TYPE** (linear-kind, E8,
BUILT) — use-once threading — but *not* a borrow checker. There is no borrow: an
operation that reads the arena **hands it back** (`region-avail` returns
`(avail-r free rgn)`, threading the `Region`; "*you cannot peek without
threading*"). Aliasing control is the same linearity that controls ports (C2),
not a separate lifetime/borrow analysis. Shared-immutable borrowing is simply not
the model; threading is.

**"You need a memory-pool library."**
→ Correction: the `(Pool n)` is a **dependently-typed linear porttype** in the
frozen port set (Shard 2), not a heap-allocated data structure you `new`. Its
capacity is a *type index*, its identity is *linear*, and it is minted by
`pool-create`, not constructed. It is a capability, not a container.

---

## 5. What's genuinely new / unbuilt — the honest residue

Only the true gaps, gradients preserved, tiers named. Nothing rounded to done or
to undone.

1. **Region TYPES (Shard 5) — REFACTOR, E41/E22, edge-3-gated.** The region
   *library* is built (bump arena, unit free); what is unbuilt is the type
   machinery that retires the runtime capacity check: a refined/indexed cursor so
   `mem-alloc`'s `(<=i (+ used len) cap)` halt becomes a *type obligation* and
   offsets become `(refine I64 …)`. Gated on E9 symbolic bounds. Gradient: the
   discipline is exercised and correct *today* with a runtime witness; only the
   compile-time discharge is owed.

2. **Space-as-a-grade (Shard 8) — REFACTOR, E38, settled-on-paper.** The cost
   semiring enrichment (`usage × time × space × info-flow`, `cost = ℕ∞`) is a
   *decided* reshape of the existing 3-point lattice, not built. It is distinct
   from the region/linear disciplines (C4). Gradient: shape fixed, judgment seams
   untouched by design; the arithmetic ops are the reshape.

3. **E9 variable-bound refinement — SEEDED, the enabling sub-capability.** `v<n`
   over inter-variable arithmetic is const/bare-var only today; it is the EXTEND
   that unblocks *both* residue-1 (region types) and the general case of
   `mem-put-checked` (Shard 3). Named once here because two memory residues share
   this single lever.

4. **Zeroize-to-the-floor + memory custody (Shard 9) — BUILD, E56 (2026-07-21
   catalog extension).**
   Zeroed-on-drop is a semantics promise the machine can break (spills / DSE);
   carrying zeroing to the tal floor is unfinished, and `secret-reveal`'s
   host-copy hygiene is inherently partial. Register-root/zeroize *as a type
   obligation*, per-datum flow policy, and custody redundancy are "vapor beyond
   the secret seed" — the secret *seed* (E40) is built and CONFORMS as scoped;
   the bulk is DESIGNED (adjacent E42 register-root supervisor). Custody
   redundancy is an instance of split-provider agreement (C5), so it inherits
   that role's gate.

5. **An allocator beyond the bump arena (Shards 1, 4/5) — unbuilt, mostly a
   non-gap.** Only the bump arena and unit-free exist; a general free-list /
   sub-allocation allocator is not built and is *not owed as a default* — it
   would be an elaboration-module choice for a profile that wants it (like the
   GC, outside the TCB), not a missing subsystem. Named so no one re-adds it as a
   phantom.

**Do not describe as missing (BUILT, so no residue):** the arena — **E21
self-hosted arena is COMPLETE** (chirality `memfd→ftruncate→mmap→roundtrip→munmap`,
differentially tested); the Pool porttype (E30–E33); `mem-put-checked`'s
literal/guarded slice (E22); the linear discipline (E22); byte cells (E25); the
profile memory clause (E2). The one standing caveat over *all* built shards:
enforcement rests on the CPython + Linux-syscall host until self-hosting (E51;
its former edge-16 gate was resolved 2026-07-21, `docs/decision-effect-facets.md`
— the remaining gate is the E39 row shape) makes it adversarial rather than
host-trusted — and the sys-face still lacks `mprotect`/`close` (E28, EXTEND).

Gradient summary: memory's *substance* (arena, Pool, linear discipline, byte
cells, self-hosted E21 arena) is BUILT; its bounds-safety is compile-time in the
literal case and runtime-witnessed elsewhere; its region-*types*, space-*grade*,
and zeroize-*to-floor* are the real forward edges — each blocked on a *named*
mechanism (E9, E38, E42/custody), none from zero.

---

## 6. Relational anchors — thin notes that should link INTO this bank

- [[memory-model]] — the consolidated one-idea view (the five commitments,
  scaffold status, the "region does two jobs" naming trap); the definitional
  source, links here for the shard decomposition and build-state.
- [[decision-graded-kernel]] — space-as-a-grade vs discipline (Shard 8, C4); the
  three-way split (coeffect / property / modality).
- [[secure-datum-model]] — the register root, derive-not-store, zeroize hygiene
  (Shard 9, C5).
- [[modules-custody]] — secret custody, redundancy, memory custody (Shard 9);
  the bulk that is BUILD.
- [[modules-substrate]] — RAM as category-B substrate owned by nothing (§1, C6).
- [[permission-model]] — the port-as-authority framing that C2 shares.
- [[banks/profile]] — discipline-as-choice (Shard 7, C1); do not re-document
  staging here.
- [[banks/capability]] / [[banks/port]] — a Pool *is* a linear port (Shard 2,
  C2); the capability/port depth.
- [[banks/evidence-and-split]] — custody redundancy as split-provider agreement
  (Shard 9, C5).
- [[error-and-alarm]] — exhaustion as an environment alarm (C6).
- [[vocabulary]] / [[glossary]] — the `port`/`capability`/`linear` term truth;
  point here for the memory refraction.
- [[status-ledger]] — the authority for build-state, mirrored here.
- [[open-edges]] — edge 2 (membrane reach), edge 3 (cost gradient / E9 symbolic
  bounds), edge 4 (default custody tier), edge 15 + G4 (substrate write-and-read
  detect-vs-prevent seam), edge 18 (whole-assembly memory bounds).
