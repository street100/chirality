---
node: glossary
layer: navigation
related: [index, axis-typeability, axis-altitude, modules-broker, modules-lowering, live-environment]
status: draft
updated: 2026-09-03
---

# Glossary

Short definitions with links to the note that owns each term. For the
authoritative definition, what a term is, what it is not, and what it replaced,
see [[vocabulary]]. This is the quick index; that is the source of truth. For the
**full depth** of a concept — its refraction into shards, homes, and build-state —
see the depth-tier banks in [[banks/INDEX]] (`module`, `profile`, `runtime`,
`capability`, `port`, `effect-and-alarm`, `memory`, `evidence-and-split`).

- process. The typed unit of computation, and run, a configuration of modules
  staged into a runtime. One self-similar construct at every scale. See
  [[process-and-runtime]].
- runtime. A process at the scale of a running system: a configuration of modules
  and connectors, staged live, itself built of processes. See
  [[process-and-runtime]].
- bootstrap sequence. The start process, off to endgoal, the intuitive view of
  the cascade. See [[bootstrap-sequence]].
- port. A named, finite way a program can affect anything outside itself: I/O, a
  held capability, time, space. The port set is closed. See P3 and
  [[category-typed]].
- membrane. The boundary a computation crosses to do anything. Compute is inert
  until it crosses a port. See P3.
- capability. A port held. Authority is the set of ports you hold. See P3 and
  [[vocabulary]].
- status rungs (DESIGNED / SEEDED / IMPLEMENTED / ENFORCED). How real a design
  claim is in the scaffold — the map from the present-tense design notes to the
  code that does or does not realize them. See [[status-ledger]].
- grant (sidehand). A capability in its active role: the held port a process
  brings to a crossing to authorize the act. Permitted by bridge agreement, not
  by an owner. See [[vocabulary]] and [[permission-model]].
- category A, typed. Correctness by proof. See [[category-typed]].
- category B, untyped. Substrate the language cannot type. See
  [[category-untyped]].
- category C, bridge. Typed module, untyped referent, governs by evidence. See
  [[category-bridge]].
- tier T0 to T3. How a truth is held: T0 typed singleton, T1 copies compared, T2
  plain Shamir, T3 verifiable split. See P5 and [[axis-typeability]].
- alarm. A detected divergence, raised as a typed effect, carrying what diverged
  from what. See [[error-and-alarm]].
- counter effect. The effect that answers an alarm: re-key, re-derive, relocate,
  repair from survivors, quarantine, halt. See [[error-and-alarm]].
- time. Three things, not one: time you spend (cost, A), time you are told (the
  untrusted external clock, B, made evidence by C), time you must act by
  (deadlines and windows whose expiry fires a counter effect). See
  [[time-and-clocks]].
- altitude. A span from intent to machine, not a partition. Three levels: upper,
  the typed assembly floor (tal), and the metal. CHERI is the metal level on
  hardware that has it. See [[axis-altitude]].
- splitting law. The rule for where one module ends: a module spanning two
  typeability categories is under split; split where the type differs, stop where
  it does not. See [[splitting-law]].
- joining law. The dual: how cut modules reconnect, through four typed
  connectors, each preserving one invariant. See [[joining-law]].
- connector. A typed join between modules. The four are bridge (across
  typeability), lowering (across altitude), staging (across stage), and port
  composition (within a category). See [[joining-law]].
- no untyped bottom. Typed assembly is the floor; no lowering step erases the
  type. See [[modules-lowering]].
- typed assembly, `tal`. The typed lowest IR everything compiles to. See
  [[modules-lowering]].
- preserve check. The proof that a lowering opened no hole. See
  [[modules-lowering]].
- stage. The binding time spine: which computation runs at compile, init, or
  runtime. See [[modules-staging]].
- pregen. Procedural generation: seed to artifact, derive rather than store. The
  generative twin of the staged compiler. See [[modules-staging]].
- QTT. Quantitative Type Theory. The kernel calculus carrying linearity,
  dependency, and erasure in one. The concrete mechanism for P2. See
  [[modules-core]].
- profile. A named set of modules required to achieve a target, rendered over a
  fixed port set. See [[decision-profiles]].
- requirement type. A target as a typed spec: the ports, effects, and guarantees a
  runtime for it must provide. See [[decision-profiles]].
- conformance. A profile fits a target iff its composite type, the type of the
  runtime it stages, satisfies the target's requirement type. A subtyping check.
  See [[decision-profiles]].
- broker, emergent. Compile time port mediation that is just the type check. No
  runtime entity. Category A. See [[modules-broker]].
- broker, component. The runtime supervisor of lifecycle, grant, revoke, and
  audit. Category C. See [[modules-broker]].
- Adhikara. The capability protocol both broker halves speak. See
  [[modules-broker]].
- register root. The master secret held only in CPU registers, never written to
  RAM. The runtime root of trust against DMA. See [[modules-substrate]] and
  [SECURE-DATUM-MODEL](secure-datum-model.md).
- CHERI floor. Optional hardware enforcement of the B type mark down to silicon.
  Additive, not required. See [[modules-lowering]].
- live environment. The first large application: a live, self-modifying
  environment on the node mesh, opened first as an AI-orchestration layer. The
  residential ideal (Smalltalk, Lisp machines, Emacs, Oberon) rebuilt on a
  capability process-mesh (Erlang, ocap OSes), anchored on no one system. See
  [[live-environment]].
- residential. The property that the environment is the program: you extend it in
  its own language, live, and it describes and modifies itself, with no
  edit-compile-run seam. One of the two invariants of the [[live-environment]].
- certificate. A re-checkable derivation an untrusted producer emits, which a small
  trusted checker re-runs against fixed rules. Show your work, not a test. See
  [[certificate-discipline]].
- certificate discipline. Trusted small checker plus untrusted producers: the LCF /
  de Bruijn pattern. chirality proves elements and the interactions that admit proof
  (default-attempt), composes them, and never proves the whole system. See
  [[certificate-discipline]].
- split role. Where proof runs out, the split as a tiered substrate-provided role a
  module requires and the profile supplies: containment by ports, independence by
  provenance, verdict by agreement or certificate. See [[split-role]].
- effect row. The exercise facet of the effect system: the record of the crossings
  a term performs, inferred from the call graph; `->` is the empty row. Distinct
  from possession (ports held) — holding is not crossing; the two are joined by
  construction. See [[decision-effect-facets]].
- synthesized cancel. The abort discharge for a captured continuation holding
  linear ports: elaboration emits the closing sequence for the captured inventory
  (each porttype names its discharge crossing), checked by the ordinary linearity
  judgment. Resumption multiplicity is the continuation's QTT quantity. See
  [[decision-effect-facets]].
