---
node: open-edges
layer: open
related: [index, relations, splitting-law, joining-law, modules-broker, modules-lowering, modules-staging, permission-model, live-environment, resolution-patterns]
status: open
updated: 2026-09-04
---

# Open edges

The unresolved boundaries. Each edge sits between two notes, and resolving it
draws a module seam. These are the design questions to settle next.

> The *answers* rhyme: see [[resolution-patterns]] for the recurring moves by which
> these edges resolve (ports carry everything · tier the honest limit · the
> preserve-check discipline). Each shaped edge below cites the pattern it took.

## From the principles

1. The non process boundary. Where pure description ends and untypeable substrate
   begins, and whether type level computation counts as a process. Sits between
   [[category-typed]] and [[category-untyped]]. **Shaped 2026-07-25 (edge-walk):**
   the non-process boundary is the membrane already drawn — not a new seam. **(a)
   Where pure description ends / untypeable substrate begins:** B is a *small named
   set of holes* (DMA-capable peripherals, raw memory + pointers, the FFI far side,
   the register root — [[category-untyped]]), reached only through
   [[category-bridge]]; everything else is A, and B-ness lives *in the type*, not
   in a special status ([[decision-b-in-type]]). So the boundary is the `=>`
   crossing / the bridge, not a fresh partition. **(b) Does type-level computation
   count as a process?** **No.** A process (G3, self-similar) is something that
   *crosses* — holds ports and exercises an effect row; type-level computation
   (NbE, elaboration, checking) and *staged* computation are **pure (`->`, the
   empty row)** and perform no crossing, so they are **description, not process**.
   Staging is the binding-time **modality** ([[decision-graded-kernel]] point 3),
   not a process — a later stage is still typed and pure until it crosses. The bit
   that makes something a process is the `=>` in its type, exactly as
   `prim-is-port` (`lib/module/sig-derive.chiral:32`) is *derived* from the effect
   arrow ([[banks/port]] Shard 3; ⚑ *this note said `prim_is_port`, the cut
   oracle's name for it*): "is
   this a process?" = "does its type carry a crossing?", the same derived read that
   answers "is this a port?". Even elaboration-time producers (row inference, cancel
   synthesis, handler elaboration — [[decision-effect-facets]]) are pure: they emit
   terms/certificates re-checked by the ordinary judgment, no crossing.
   **Residual (genuinely still open):** the one real sliver is a *check-time*
   computation that invokes an **untyped oracle** (a proofless solver / SMT call at
   elaboration time) — does check-time B-access put a crossing into the
   *elaboration's* own effect row, or is it pure-until-proven? This is where edge 1
   meets [[split-role]] (proofless solvers are the unprovable residue) and
   [[certificate-discipline]] (untrusted producers re-checked); the effect status
   of a check-time oracle call is the undecided part.
2. How far the membrane reaches inward. I/O for sure, time and space necessarily.
   Termination. Information flow. Or grade them and stop. Sits inside
   [[modules-core]] (the effects versus cost split). The consolidated memory
   positions this must mechanize are in [[memory-model]]. **Largely answered by
   two decisions** ([[decision-graded-kernel]] 2026-07-05: time/space as grades,
   info-flow a reserved factor, termination a property;
   [[decision-effect-facets]] 2026-07-21: crossings = the effect row, spends =
   grades, partiality = the mark). Remaining here: the grade domains'
   mechanization (edge 3 / E38) and filling info-flow's reserved seat.
   **Info-flow seat shaped 2026-07-25 (edge-walk):** filling it splits into a
   **grade** and a **property**, mirroring how [[decision-graded-kernel]] already
   split totality (point 2, "a property, not a grade"). **(a) The grade/label** —
   the seat holds a **lattice-valued coeffect grade**: a secrecy level in the
   existing product semiring ([[decision-graded-kernel]] point 1, "security levels
   cohabit as grades", Granule the existence proof; a trivial lattice today, a real
   secrecy lattice with declassification at stage 7–8, [[modules-security]]).
   Settled in shape — info-flow occupies its reserved factor as a level lattice,
   joined at seams by the semiring product like every other grade. **(b) The
   guarantee** — **non-interference is not that grade**; it is a *typed proof* over
   it ([[modules-security]]: "non interference is a typed proof, not evidence"), a
   **relational / whole-assembly property**, so by edge 18's D4 classification it
   lands exactly where totality does: the per-value secrecy *level* is **class 1**
   (carried in the type, composed by lattice-join subtyping at seams), while
   non-interference *across a composite* is the **class-2 / global** property (each
   module preserving level-monotonicity so the composite does). So the tension "a
   hyperproperty can't be a grade" dissolves — the grade is the label, the property
   is the guarantee, related as coeffect-vs-theorem exactly as the usage grade
   relates to totality. **Residual (genuinely still open):** the concrete secrecy
   lattice + declassification rule (a build, stage 7–8); and a declassifying
   crossing's interaction with the effect row, which is an outbound-confinement
   question ([[banks/port]] Shard 5 — the same unbuilt shard edges 14/17 surfaced).
3. The cost gradient mechanism. Totality by default, graded coeffect cost in the
   type, or runaway shapes made hard to express. Includes the honest point that
   cost is an over approximate bound, not an exact predictor, because exact cost
   is undecidable. Sits inside [[modules-core]]. Concrete test case: the idle
   bound in [[target-tomodachi]]. **Shape settled** by [[decision-graded-kernel]]
   (cost = kernel semiring enrichment, factor width frozen; the carrier now also
   reserves the effect-row seat, [[decision-effect-facets]]). Remaining: build
   it (E38) and pick the grade domains' arithmetic.
4. What picks a value's default tier, now broadened. A per value annotation, or a
   classification carried in the type that auto selects the minimum rung, so
   forgetting to split a secret is a type error. [[split-role]] generalizes this off
   secrets onto every held truth: a requirement names a minimum tier per axis
   (containment, independence, verdict), and being forced below it is a visible typed
   gap, not a silent hole. The "do what you can, named" discipline. Sits inside
   [[modules-custody]] and [[split-role]]. **Resolved in direction 2026-07-25
   (edge-walk):** [[split-role]] settles the fork — the tier is **not a per-value
   annotation** but a **type-carried classification** that auto-selects the minimum
   rung per axis, so under-reaching (forgetting to split a secret, seating a source
   below its required tier) is a **type error / visible typed gap**, and the minimum
   **defaults high** (P4: safe is the frictionless default, lowering the loud
   opt-in). So *what picks the default* is the **requirement's** minimum-tier-per-axis,
   not a value-site annotation. **Residual — one shared mechanism:** the concrete
   **tier carrier** (how a tier rides the type — a refinement predicate? a
   classification kind? a dedicated grade factor?) is unspecified, and it is the
   **same carrier** edge 18's tier-weight composition and edge 17's alarm-visibility
   tier also consume. So edges **4, 17 (tier leg), 18** share one open obligation:
   mint the split-role tier carrier once. (Info-flow's secrecy level, edge 2, is a
   *sibling* type-carried lattice — a coeffect grade, distinct from the custody
   tier, not the same seat.)
5. The reflective floor. The capability kernel sits below the level self
   modifying code can reach. Pin exactly what is and is not reconfigurable from
   inside the language. Sits between the A and B halves of the kernel, and
   between [[modules-bridges]] (reflect-raw) and [[modules-broker]]. Forcing
   function: the [[live-environment]] is the maximal live-reconfiguration
   workload, so building it cannot avoid drawing this line. Resolution direction:
   the line sits at the small trusted core. "What is modifiable from inside" becomes
   "what the trusted core will not certify" ([[decision-split-checker]],
   [[certificate-discipline]]). **Sharpened 2026-07-22 (D-walk, D3):** all
   dynamism is mesh dynamism — spawn/teardown churn, never live mutation of a
   running judgment. The drawn line: a runtime's judgment (kernel-core +
   kernel-spec) is *staged-in, never granted-to*, and not swappable after
   staging completes; E45's mechanism reduces to freezing `Sig` at link/install
   completion. The succession wall: no uncertified succession — a stager's core
   certifies a successor's core against kernel-spec before it runs, and a
   mis-checked child degrades to a B-blob bounded by its granted ports. The home
   decision note is now written — [[decision-reflective-floor]] (docket D3,
   RESOLVED 2026-07-27). Still owed: state handover across relaunch (rides edge
   14); staging economics (unmeasured). See `.planning/SELF-HOST-PLAN.md`.
   **Sharpened 2026-07-24 (dynamism reframe):** the freeze binds the *judgment*
   (`Sig`), not the *population* — an instance's hosted modules, state, and port
   wiring stay freely mutable while its judgment is frozen, so most "live" change
   (redefine, add, swap, rewire, inspect) is population editing that freeze-`Sig`
   never touches. This refines the D3 "spawn/teardown churn" framing above: churn
   is forced only for a *judgment* change. In-place mutation of a running judgment
   stays forbidden because it is **unsound** (checking with rules that change
   under the check) — the floor, not a liveness limit. Because process is
   self-similar (G3), freeze-`Sig` is only ever as coarse as the moduleset-instance
   boundary drawn, so a judgment change is a **fine-grained certified succession**
   (stage a successor instance, certify its core against kernel-spec, cut over),
   not a whole-world restart; identity rides the ports (edge 14, move-only), state
   rides a typed move. Its liveness is **parity-within-a-cutover-window, not a
   true hot-swap** — the window is (1) stage+certify latency, (2) state-migration
   size, (3) in-flight continuation drain, with **atomic port hand-over** a hard
   obligation. Two obligations this surfaces for E45: succession must certify not
   just the successor's core but that **migrated state conforms to the
   successor's types** (a typed `code_change`); and **succession-initiation must
   itself be a linear capability, never ambient**.

## From the dump audit

6. Where the typed assembly vocabulary is drawn, and the per hardware target
   modules. Sits inside [[modules-lowering]]. **Shaped 2026-07-24:** the tal
   floor's type universe is deliberately minimal (`lib/lowering/tal/ssa.chiral:21`;
   ⚑ *this cited `tal.py`, cut with the Python oracle*). ⚑ *It also read
   `I64`/`STR`/`BYTES` **only**, and `TalTy` carries five constructors today:
   `tt-i64`, `tt-str`, `tt-bytes`, `tt-word` (the uniform erased one-word type,
   representation-compatible with any one-word type) and `tt-data` (a data name
   with type arguments). Minimal still holds; "only" stopped being true when
   erasure landed.* Typing is imposed *above* the floor and re-seated across the
   bridge ([[category-bridge]]), never carried as floor types. A new floor opcode
   or type is the rare, justified exception; the default is composition from the
   existing floor ops — `ti-bput` already stores at a computed offset into an
   existing cell, and `nb-pack32`/`nb-pack16` already compose multi-byte integers
   from it. So "structs at the floor" (msghdr/cmsghdr/pollfd/timespec, E29–E33)
   is **library composition over `ti-bput`, governed by the bridge and the
   lowering preserve-check** — not new `ti-put-*` primitives; this is E30's
   disposition. (The earlier "irreducible floor vocabulary" framing was an
   altitude error: a pointer is an `I64` at the floor and decomposable, since tal
   has no opaque pointer type.) What this edge still owns: whether the recurring
   syscall-struct family earns a **typed ABI-layout abstraction above the floor**
   (a layout descriptor + refinement bounds, E48-flavoured, re-seated by the
   bridge) so intra-struct correctness is *typed* rather than only
   differential-tested — the recurrence across E29–E33 and E70's preserve-check
   needing a layout spec to check against are the case for it. The floor line is
   drawn; the above-floor layout abstraction was the open call — **RESOLVED
   2026-07-26 (Batch A): mint it, now element E75** (catalog §XI; a typed
   layout-descriptor + refinement bounds, re-seated by the bridge, giving E70's
   preserve-check a layout spec to check against). See [[axis-altitude]].
7. The Adhikara to capability type correspondence — **resolved in direction**
   (2026-07-22, D-walk, D6): the two layers do not "agree"; Adhikara *is* the
   capability-type discipline lowered onto a B channel. Upper face = exactly
   the type operations (the four grant ops, crossings, property-certificate
   presentation, alarm signalling — a closed, enumerable message space); below
   it, the lowering connector with "translation preserves-or-reduces rights"
   as its preserve-check, and the bridge's confine-outbound/verify-inbound
   supplying confidentiality and integrity (the wire is B). Zero-trust
   completion (author-settled): **no foreign agreement is ever load-bearing
   for safety** — exactly-once and no-forge are local linear accounting plus
   derive-not-store at the authority's home membrane; a comms failure costs
   progress only (in-doubt grants discharged by local expiry/re-key counter
   effects); hostile revocation is stop-deriving, the peer never consulted.
   Remaining under this edge: the enumerated E61 choice (home-referenced
   authority vs offline-verifiable attenuation chains — both zero-trust-clean)
   and the wire lowering + its check. Sits inside [[modules-broker]].
8. The component broker's internal four part decomposition (AUTH and AUDIT), and
   how it handles runtime spawn and teardown as first class events — **resolved
   in direction** (2026-07-22, D-walk, D5): not a bespoke four-part
   architecture. The component broker is the general bridge elaborator
   ([[decision-bridge-elaborator]]) instantiated over the live-population
   B-referent ([[decision-b-in-type]]: quarantine in the signature, ordinary
   packaging, no privilege), per-runtime by self-similarity — each runtime's
   configuration carries its own broker over its own population, and no global
   registry is expressible. Internals reduce to evidence-element choices
   (audit-reconcile as the load-bearing verify; freshness; attestation) plus
   the counter-effect dispatch set. Dynamic grant/revoke stay (the
   [[live-environment]] is the forcing function): a grant to a live node is a
   port move over an existing crossing, whose protocol content is edge 7.
   Remaining: pick the evidence elements; audit dump D13's four-part material
   for any job the elaborator framing cannot seat. Sits inside
   [[modules-broker]].
9. The chirality-verify profile. The sub category where every morphism is total. Now
   framed as one instance of the conformance mechanism (G9): its requirement type
   is the global totality property. The per-def totality classifier now exists
   ([[totality]]: strict positivity + case coverage + structural recursion, the
   recursion pillar classifying via `lib/typing/totality.chiral`), and the
   profile's requirement is **wired 2026-09-02**: a bare `(total)` profile clause
   makes `chirality check` refuse the composite where any def fails to prove,
   with `tot-gate` running in `lib/lowering/compile-front.chiral` between the load
   and the peel. The demo is `prog/demo/verify-total.chiral`. ⚑ *Repointed
   2026-09-04. This read "built at scaffold scale", named `chirality verify`,
   which `bin/chirality` has never dispatched, and cited
   `scaffold/demo/verify-total.chiral`, a path the 2026-08-31 migration evicted.
   The demo's own header still invokes the retired `python3 -m chirality verify`,
   and repairing that is a source edit this note does not take.* ⚑ The gate is
   **opt-in and gated by no suite phase**, which [[totality]] states and BA-39 in
   `records/baseline-alignment.md` measures. Remaining
   work is settling whether totality is compositional, reachability-scoping the
   claim (the same refinement the port-set check wants), and the sized-types
   promotion so numeric recursion can clear the bar. Sits inside
   [[decision-profiles]]. **"Is totality compositional" now has the D4 answer
   shape** (2026-07-22, edge 18): today's `(total)` clause is class 2
   (node-local at stage time); promoting it to class 1 (signature-compositional,
   via exported termination measures) is the question this edge still owns.
10. The auditor facing proof presentation layer (an Isar equivalent). Bounded
    novel work; no off the shelf equivalent exists for this module set. Sits
    inside [[modules-core]] (reflect-typed). Catalogued **E46**. **Shaped
    2026-07-26 (edge-walk):** it is a **`reflect-typed` rendering of the
    certificates the trusted core already checks** — not novel proof machinery.
    Because the certificate *is* the elaborated term ([[certificate-discipline]];
    E39) and "the canonical representation is the single source of truth; every
    surface is a rendering of it" ([[modules-core]] A12), proof-presentation is a
    `reflect-typed` function (typed term → typed surface) that traverses the
    derivation into auditor-facing structured form (the Isar analogue). Three
    consequences, each a pattern this walk already surfaced elsewhere: (1) it is a
    **rendering, not a re-proof** — the layer adds **no trust**, it displays the
    already-checked certificate; (2) it is **one general renderer, not per-proof**
    — parallel to the bridge being one general elaborator (edge 12) and lowering
    one `translate`+`preserve-check`; (3) it must **name the tier** ([[split-role]])
    — what is proven (an A certificate), what is evidence (a C bridge), what is
    asserted (a named gap), so the auditor sees *where* trust rests, "do what you
    can, named" made legible ([[trust-boundary]]). **Residual (genuinely still
    open):** the presentation **surface** itself — the Isar-equivalent
    structured-proof format is the real novel work (no off-the-shelf for this
    module set), and it is **downstream of the certificates** (edge 12's
    preserve-checks + the E39 rows) and of `reflect-typed`, which is DESIGNED not
    built ([[modules-core]]).

## From the modularity pass

The [[joining-law]] was added as the dual of the [[splitting-law]]: cut modules
reconnect through four typed connectors. That settled two directions and opened
three seams.

Settled in direction:

- The kernel splits into `kernel-expressed` (A), `kernel-gate` (C, runtime port
  mediation), and a bootstrap floor governed as a cross-checked set of tuned
  runtimes (C), not a bare B atom. This merges the old kernel-floor question with
  the trusted-base boundary: the trusted base shrinks to the register root plus the
  agreement mechanism. The A face `kernel-expressed` is *itself* split further by
  [[decision-split-checker]] into `kernel-spec` plus a small trusted `kernel-core`
  that re-checks untrusted producers' certificates ([[certificate-discipline]]) — the
  checker is provable, so it is held by certificate, not by agreement. See
  [[joining-law]] and [[module-map]].
- Altitude is a span, not a partition. Three levels, upper, the tal floor, and
  the metal, with drops between. `cross` means a connector runs through a module,
  and the ordinary splitting law on the upper and lower faces decides when a span
  is really a twin. No separate altitude splitting law is needed. CHERI is the
  metal level on hardware that has it, carrying types into silicon. See
  [[axis-altitude]].

Still open:

11. The bootstrap floor internals, and independence generally. How many tuned
    runtimes, how independent they actually are (residuals of one compiler share
    that compiler's bugs, so their agreement may not be real evidence), and how the
    set relates to the `runtime` supervisor in [[modules-bridges]]. The checker is no
    longer a quorum ([[decision-split-checker]] went to certificates), so independence
    now governs only the genuinely-unprovable residue: the floor, hardware, proofless
    solvers. It is answered in direction by [[split-role]]: independence becomes typed
    provenance-disjointness in the combine, checkable against named axes (attestable
    ones enforced, assertable ones demanded-and-audited), never absolute. Sits between
    [[modules-staging]] and [[modules-bridges]]. **Narrowed 2026-07-22 (D-walk,
    D7), not resolved:** what remains is an author *budget* call — which
    provenance axes are bought versus asserted-and-named for the floor's N
    runtimes. Recommendation on record (a recommendation, not a decision):
    DDC (E53) plus toolchain diversity is the affordable load-bearing rung;
    authorship diversity is honestly named not-yet-real while there is one
    author.
12. The connector preservation guarantees, now load-bearing for the bridge. Each
    connector claims to preserve one invariant; the staging connector's semantics
    preservation needs a checkable statement, the way `preserve-check` discharges
    the lowering connector. The general bridge elaborator
    ([[decision-bridge-elaborator]]) needs its own `bridge-preserve-check` for "a B
    referent enters A only as evidence," which is the generic re-checker for the
    bridge's fixed statement ([[certificate-discipline]]). Bridge
    preservation is harder to state than lowering's: it preserves the semantic
    "entered only as evidence," not just the type. Sits inside [[joining-law]].
    **Two additions 2026-07-22:** the Adhikara wire lowering (edge 7) adds a
    preservation obligation of the same family — "translation
    preserves-or-reduces rights" as the wire's preserve-check; and the E39
    verification is an existence proof for the producer side (handler
    elaboration discharged entirely by the ordinary judgment — the certificate
    is the elaborated term itself). **Shaped 2026-07-25 (edge-walk, with edge 13
    — one root):** the four preserve-checks split cleanly by **type-vs-semantic**,
    which is also the build-state line. **BUILT (structural):** lowering → the
    generic `preserve-check` over `translate` (constant-time its first customer);
    port-composition → the frozen-port-set check (`verify_profiles`, ENFORCED) —
    each preserves a TYPE / a SET, mechanically checkable. **OPEN (semantic):**
    bridge → `bridge-preserve-check` "a B referent enters A only as evidence" (one
    general elaborator parameterized by an evidence element,
    [[decision-bridge-elaborator]]; E39 is the producer-side existence proof);
    staging → semantics-preservation across binding time (the succession wall — a
    stager certifies a successor's core against `kernel-spec`, edge 5 / E45). Each
    is a **certificate re-checker** ([[certificate-discipline]]), *not* a
    redundancy quorum — provability is the boundary; redundancy is only the
    bootstrap-floor residue (edge 11). **Cross-link:** the bridge preserves *both
    ways* ([[joining-law]]), but `bridge-preserve-check` states only the INBOUND
    semantic; the OUTBOUND dual ("A emits to B only confined") is the
    **outbound-confinement obligation (docket D8)** — so this edge's bridge check
    has an unstated outbound half that is the session's convergent build
    obligation. **Residual (genuinely still open):** state the two *semantic*
    preserve-checks (bridge-inbound, staging) as certificate-checkable predicates,
    plus the bridge's outbound dual (D8) — the two *structural* ones are built.
13. Whether the joining law's four connectors are complete. Sits inside
    [[joining-law]]. The `cross` stratum question is now resolved: altitude
    spans, typeability partitions, and the ordinary splitting law on the upper
    and lower faces decides when a span is really a twin. See [[axis-altitude]].
    **Stress-tested 2026-07-22:** the D-walk seated three would-be new
    mechanisms in the existing four (property flow → per-seam connectors, the
    broker → bridge elaborator, the wire protocol → lowering + bridge) —
    evidence for completeness, not proof. **Shaped 2026-07-25 (edge-walk, one root
    with edge 12):** completeness and statability (edge 12) are two faces of one
    obligation, because [[joining-law]] makes each connector **one invariant = one
    principle**. The four are one-per-principle-boundary the splitting law (which
    cuts on the type, P2) can expose: proof-boundary (bridge, P1/P5), altitude
    (lowering, no-untyped-bottom), binding-time (staging, P2), governance-surface
    (port-composition, P3). So completeness **reduces to the invariant=principle
    correspondence** — every cut separates a principle-invariant and there is
    exactly one connector per principle-boundary; the D-walk seating test is
    corroborating evidence, the correspondence is the argument. What keeps it
    "evidence, not proof" is that "the principles are the complete set of
    cut-invariants" is the thesis's own closure claim — argued, not separately
    proven. The remaining *work* is not finding a fifth connector but stating the
    two unbuilt (semantic) preserve-checks — that is edge 12.

## From the process model

G3 resolved in direction: process is one self-similar construct, not two
referents. The typed atom and the runtime are the same type discipline at two
scales; a running configuration of modules is itself a process, and it cascades
to manage itself down to the bootstrap floor. See [[process-and-runtime]] and
[[bootstrap-sequence]].

Still open:

14. The live port semantics, narrowed in direction (2026-07-04). Authority is
    move-only ([[permission-model]]), so a live port is a move of a typed value
    across a typestate crossing: message passing, no shared handle, no aliasing,
    races ruled out by construction. The one sharing mode is immutable read-only.
    What remains open is one question: whether the agreement (the bridge verify
    rendezvous) and the data transfer are one step or two, which is what decides
    synchronous versus asynchronous. Sits inside [[process-and-runtime]] and
    [[modules-broker]]. Concrete test case: one socket carrying an event stream
    plus request/reply sequences in [[target-tomodachi]]. **Softened on the wire
    2026-07-22 (D-walk, D6):** for cross-node crossings, safety never depends on
    the rendezvous — zero trust means exactly-once and no-forge are enforced by
    local accounting at the authority's home membrane, so sync-versus-async over
    the wire is pure liveness engineering. The one-step-or-two question retains
    its force for same-node port semantics only. **Shaped 2026-07-25 (edge-walk,
    same-node residual):** one-step-or-two is not an independent axis — it is
    **continuation placement**, and both poles are already legal machinery from
    [[decision-effect-facets]] (a captured continuation is one linear `KontMsg`
    closure, and *suspensions move within a node*). **One step (synchronous)** =
    the `KontMsg` closure stays on the stack and the handler-process resumes it in
    place, so the rendezvous *is* the transfer. **Two steps (asynchronous)** = the
    closure is captured and *moved* to the handler — the within-node
    continuation-mobility that note reserved cross-node but allowed same-node — the
    caller's fiber yields, and the handler resumes the moved closure later, so
    agreement (accept the moved kont + value) and transfer (resume) are distinct in
    time. So sync-vs-async is a **per-crossing choice typed by the continuation's
    QTT grade + mobility**, not a global runtime mode, and the move-only linear
    discipline ([[permission-model]]) makes the async (moved-continuation) case
    exactly-once and race-free by construction. This uses only the machinery
    [[decision-effect-facets]] built and stays on the same-node side of the
    continuation-mobility line it drew; the cross-node case remains that note's
    reserved future decision. **Residual (genuinely still open):** whether a
    runtime-level scheduler/queue for moved continuations is minted or left to the
    handler process; the liveness engineering (fairness, backpressure) of the
    two-step case; and same-node `bridge.verify`'s role for A-to-A moves (the
    verify rendezvous is the B-inbound integrity check — a pure A-to-A move's
    "agreement" is the linear handshake, not `verify`). Port depth: [[banks/port]]
    Shard 8.

## From the node model

The architecture is now named: code runs in nodes that touch only through typed
ports, no central kernel. See [[node-architecture]].

Settled in direction:

- G8 (network and distribution) dissolves. A remote node is just a node you hold a
  port to, and Adhikara carries the capability over the wire, so distribution is
  native rather than a layer added on top.
- Substrate is owned by nothing; governance is structural in the port's type;
  ports are where the logic lives; a resource limit is a bound in the port and a
  storage view is the port's type; finite hardware means a linear port supply.

Still open:

15. Concurrent access to unowned substrate where structure cannot forbid it.
    Linearity forbids a double exclusive use, but where even that cannot reach
    (DMA past every check), governance is detect-and-reconcile, not prevention.
    Whether detect-and-reconcile suffices for every device class, a disk write and
    not just a secret in RAM, is unresolved. Sits inside [[node-architecture]] and
    [[modules-bridges]]. **Shaped 2026-07-25 (edge-walk):** sufficiency turns on
    the **reversibility / detectability of the effect**, not on the device per se.
    **(a) Read-back / reversible substrate (a secret in RAM):** the loop *closes* —
    a diverged read is caught inbound by `bridge.verify` + a MAC/checksum
    ([[banks/port]] Shard 4, BUILT) and a counter-effect (re-derive from the
    register root, repair-from-survivors — [[error-and-alarm]]) *recovers*.
    Detect-and-reconcile **suffices**. **(b) Irreversible or externally-observable
    effect (a committed disk write, a network send, a physical actuation):** by the
    time divergence is detected the effect is already out, so you can *detect +
    account* (name it, quarantine, alarm) and reconcile your *own* state but cannot
    undo the external effect — it degrades to **detect-and-account**: typed
    accountability, not prevention, held honestly at its rung ([[split-role]] "do
    what you can, named"). **The structural read:** this is exactly the
    inbound/outbound membrane split — the reversible case is inbound integrity
    (built, Shard 4), the irreversible case is the **outbound-confinement gap**
    ([[banks/port]] Shard 5 / E44), whose job is to *bound the exposure window
    before* an effect escapes to B. So the DMA substrate edge 1 names as a B hole is
    governed by the alarm/counter-effect loop (edge 17) for read-back, and its
    irreducible residue is the same **outbound confinement** edges 14/17/2 surfaced.
    **Residual (genuinely still open):** the per-device-class catalogue keyed by
    reversibility (which effects are undoable, which only accountable); and whether
    an irreversible crossing should be forced through a *pre-commit* confinement
    gate (the outbound membrane) so the exposure window is typed rather than
    post-hoc — a build that rides E44.

## From the membrane (G4)

G4 resolved in direction: the membrane and the bridge connector run both ways.
Inbound (B to A) verifies, governing integrity; outbound (A to B) confines,
governing confidentiality, capability containment, and the exposure window. The
outbound mechanisms already exist (`information-flow` and linearity in A,
`datum-policy` in C); they are now named as the outbound membrane, the dual of the
inbound one. See [[category-bridge]], [[category-typed]], and [[joining-law]].

Still open: a substrate region both written and read back, and a port that is
outbound then inbound as one protocol (a device command and its response), put
both disciplines on one port in sequence. That sequencing is the port protocol of
edge 14.

## From the error model (G6)

G6 resolved in direction: an alarm is a typed effect, and its response is a
counter effect. A detected divergence is raised in the port and effect algebra,
named in the type and total, and it is rich because everything is split, so it
carries what diverged from what. The counter effects are a named set (re-key,
re-derive, relocate, repair from survivors, quarantine, halt). Recoverable or
fatal is in the type. See [[error-and-alarm]].

Still open:

16. The effect mechanism for alarms and counter effects — **settled in
    direction** (2026-07-21, [[decision-effect-facets]]): two facets,
    possession (capabilities held, linear) and exercise (the effect row,
    inferred from crossings), joined by construction once the ambient externs'
    capabilities are reified; handlers CPS-elaborate to linear closures with
    resumption multiplicity graded by the continuation's QTT quantity; abort
    discharges by synthesized cancel. The row representation and row-variable
    shape are now **pinned** (2026-07-22,
    `docs/elements/specs/E39-effect-row-SPEC.md`: set-of-crossing-names with a
    sorted-tuple canonical form; the row-variable seat reserved as a second,
    unpopulated field). Remaining under this edge: building E39 per its SPEC,
    and the row's tal shadow and its preserve-check (catalog E70, drafted).
    The zero-new-kernel-forms elaboration claim is **verified** (2026-07-22,
    `examples/E39-effect-row.md`; sharpenings recorded in
    [[decision-effect-facets]]). Sits inside [[modules-core]] and
    [[error-and-alarm]].
17. Cross-node alarm propagation: how loud a divergence in one node is to the
    nodes holding ports to it. Sits between [[error-and-alarm]] and
    [[node-architecture]]. **Shaped 2026-07-22:** alarms are crossings
    ([[decision-effect-facets]]), so propagation is ordinary port traffic
    carrying alarm evidence (a bridge certificate element, edge 18's class 3
    machinery); continuations never cross (within-node only). What this edge
    still owns is the loudness/subscription policy — who is entitled to hear,
    at what tier. **Shaped 2026-07-25 (edge-walk):** loudness and subscription
    are both refractions of the port, not new policy. **(1) Loudness = port-graph
    reachability.** There is no ambient broadcast — no central owner, nodes touch
    only through held ports ([[node-architecture]]) — so an alarm in N travels only
    along the ports held *to* N, reaching exactly its port-holders and further only
    by explicit re-emission. Loudness is structural (the mesh topology), not a
    tunable knob. **(2) Subscription = holding the alarm-carrying port.** "Entitled
    to hear" = holding a port to N whose type carries the alarm crossing in its
    effect row ([[decision-effect-facets]]); the row-entry *is* the subscription —
    no separate ACL. Push-vs-poll delivery is edge 14's continuation-placement
    applied to the alarm crossing (in-place resume = pushed to a handler;
    moved/polled = the holder crosses to check). **(3) Tier = the
    outbound-confinement tier of the (rich) alarm evidence.** An alarm is
    diagnostic by construction — it carries *what diverged from what* (which copy,
    share, MAC) — so how much a given holder is entitled to see is bounded by the
    **outbound membrane** confining that evidence ([[banks/port]] Shard 5) plus the
    evidence's own attested-vs-asserted tier ([[split-role]], [[axis-typeability]]).
    **Residual (genuinely still open):** the tier leg *depends on outbound
    confinement, which is unbuilt* ([[banks/port]] Shard 5 / E44) — the "at what
    tier" half cannot be fully specified until it exists; and whether re-emission
    (a holder forwarding an alarm onward) needs a distinct capability or is just
    another crossing. Home: [[error-and-alarm]] / [[banks/effect-and-alarm]].

## From the foreign boundary (G7)

G7 resolved in direction: foreign code is not an untyped bottom. No untyped bottom
governs the typed lowering path, which still ends at tal; foreign is a B referent
outside that path, reached only through a typed C orchestrator. The runtime is
built with no port to unwrapped foreign, so an unwrapped driver is not
expressible. Honest limit: a compromised foreign blob does whatever its
compartment allows; the orchestrator bounds the blast radius, it does not prove
the foreign correct. See [[axis-altitude]], [[modules-substrate]], and
[[modules-bridges]].

## From profiles (G9)

G9 resolved in direction: profile conformance is type-checking. A target is a
requirement type, a profile's composite type is the type of the runtime it stages,
and conformance is the composite satisfying the requirement (subtyping). Profile
validity is three reused checks: preserving connectors, substrate access through
ports, composite satisfies requirement. See [[decision-profiles]].

Still open:

- **Numeric width is a profile axis (DIRECTION SET 2026-08-10 — TODO, unscoped).**
  Integer word-width is a moduleset-configured `NumProfile`, not a fixed I64
  floor; `i64` is one profile. Same conformance shape as memory disciplines +
  backends. Cross-cutting (semantics/cells/refinement/codegen + the Rocq model).
  Full record + the open design forks (width-only vs bundled profile; mono-profile
  vs coexisting fixed-width types) in [[decision-numeric-width-pluggable]]. A
  design pass after the terminal pipeline; nothing may re-hardcode 64-bit meanwhile.

18. Which target properties are compositional. Structural demands (offers port X)
    are plain subtyping; whole-assembly properties (chirality-verify totality,
    non-interference across the composite) are subtyping-checkable only if each
    module preserves them, else they need a global analysis. chirality-verify (edge 9)
    is the first concrete requirement type. Tier weight is among the unpinned
    properties: the type carries it ([[vocabulary]]) but no note says how it
    composes or subtypes across a composite. Sits inside [[decision-profiles]]. The
    active discipline this edge governs ([[certificate-discipline]]): chirality proves not
    only elements but their interactions, by default-attempt. When a goal composes two
    concepts not yet proven together, a proof is attempted unless it is known
    impossible; type-level interactions (hard-bound elaboration and many more) are
    provable and get proven, physical interactions (hardware, DMA) are best-guessed as
    evidence. The open part is which interaction proofs are cheap (subtyping) and which
    need a dedicated argument, not whether they are attempted. Individually-sound but
    jointly-unsound feature combinations (Girard) are why they are not optional.
    **Resolved in direction 2026-07-22 (D-walk, D4):** no global mechanism, no
    one answer — per-seam handling by the existing connectors. In a
    dynamically-staged mesh "the whole assembly" is never an analyzable object
    (runtimes stage runtimes at runtime; no vantage point holds the composite),
    so a target property lands in one of three classes: (1)
    signature-compositional — carried in module/port signatures, discharged by
    subtyping at the seam; (2) node-local at single-node stage time — the only
    place a closed composite exists (the built `(total)` clause is this class);
    or (3) a named gap — genuinely non-compositional, held at its honest rung
    per [[split-role]]'s "do what you can, named." Cross-node property claims
    ride the bridge as certificate evidence elements over Adhikara (edge 7).
    Remaining: the per-property catalogue (which element, which rung — work
    that emerges from building, chirality-verify totality first) and the
    tier-weight composition rule, which is genuinely unbuilt. **Tier-weight
    shaped 2026-07-25 (edge-walk):** it lands *inside* the D4 three-class shape,
    split by leg. A tier is a rung on a per-axis chain ([[split-role]]:
    containment, independence, verdict) and a requirement names a **minimum** per
    axis. **Containment** composes as the tier of the composite's *effective*
    (post-wiring) port set — normally the **meet** (the weakest-contained member
    sets the floor), but a containing wrapper that narrows egress *lifts* it above
    its enclosed member's own tier; both are read off the port-set subtyping
    already built, so **class 1 (signature-compositional)**. **Independence** is
    **relational** — provenance-disjointness *among* members, checked at the
    guarded combine — so a member's own tag/tier subtypes at the seam (class 1)
    but the disjointness itself is **class 2 (node-local at the combine site)**,
    the one place the closed member-set exists ([[split-role]]: "the combine's
    type requires the declared tags disjoint"). **Verdict** rides on independence
    and inherits its class. So tier-weight is not a fourth mechanism: the per-axis
    rung is meet-composed by ordinary subtyping, the independence relation is the
    node-local combine check — matching D4 exactly. **Residual (genuinely still
    open):** the per-axis tier *arithmetic* (the chains read as total orders, so
    meet = min — confirm none has incomparable rungs, else a lattice meet); and
    whether the lifted-containment (wrapper narrows egress) case wants an explicit
    rule in the port-set subtyping or already falls out of it. Home:
    [[decision-profiles]] / [[banks/profile]].

## From time (G10)

G10 resolved in direction: "time" is three things, not one. Time you spend is a
proven budget (`cost-typed`, A). Time you are told is the untrusted external clock
(B), made evidence by `freshness-verify` (C) against the register-anchored
monotonic counter. Time you must act by is a deadline or window whose expiry fires
a counter effect. See [[time-and-clocks]].

Still open:

19. Cross-node ordering. Ordering events across nodes on the mesh needs causality,
    a logical or vector clock, happens-before, which the three single-machine
    senses do not cover. Sits with [[node-architecture]]. **Shaped 2026-07-26
    (edge-walk, one root with edge 20 — the register-root anchor's two gaps):** the
    three single-machine senses are anchored on the register-root counter, which is
    **local**; cross-node order is its *spatial* gap. There is no shared clock to
    reach for (no central owner — [[node-architecture]]) and a peer's clock is
    untrusted (zero trust, edge 7), so causality **rides the ports**: the causal
    edge *is* the port-move (a message received happened-after its send), so
    happens-before = the port-move order, and a logical/vector clock is **metadata
    carried on port crossings** (a bridge-certificate element over Adhikara, like
    alarm evidence in edge 17) — not a clock subsystem. Because a peer's ordering
    claim is evidence not proof, **safety never depends on it** — only local
    accounting at the home membrane does (the edge 7/14 zero-trust discipline), so
    cross-node order is a liveness/consistency convenience, not a trust root.
    **Residual (genuinely still open):** whether any mesh workload needs *total*
    order (consensus/agreement — expensive under zero trust) or partial causal
    order suffices; the design bet on record is partial-causal + local accounting.
20. Persistent monotonicity. The register-anchored counter clears on power loss, so
    a rollback-proof persistent counter needs hardware (a TPM NVRAM monotonic
    counter), out of scope for the CPU and RAM only model. A boot-window and
    hardware limit. Sits inside [[time-and-clocks]]. **Shaped 2026-07-26 (edge-walk,
    one root with edge 19):** the register-root counter is **volatile**; cross-reboot
    persistence is its *temporal* gap, and it is a genuine hardware limit —
    rollback-proofness across a reboot needs attested hardware (a TPM NVRAM monotonic
    counter), unreachable in the CPU+RAM model. The design finding is *how it
    degrades*: persistence is a **tiered capability** ([[split-role]] "do what you
    can, named" — the same shape as edge 15's reversibility and edge 4's tiers).
    **In-boot monotonicity** — the register-root counter, monotone within a boot
    window — is BUILT and sufficient for `freshness-verify` *within* a session.
    **Cross-boot rollback-proofness** is a **named hardware tier, not-had** in this
    model: absent the NVRAM tier, the **boot-window is the honest bound** — after a
    reboot monotonicity restarts, and a rollback across the reboot boundary is
    undetectable without the hardware. Named, not hidden. **Residual:** none of
    *mechanism* — this is a named tier gap, not an open design question; what remains
    is only whether a workload demands the cross-boot tier, in which case the
    hardware becomes a stated requirement (a typed gap if absent, per [[split-role]]).

## From the permission model

The [[permission-model]] note added no open edges. Earlier drafts claimed three; all
collapsed into existing structure. Two independence claims dissolved into linearity
and edge 15: overlapping exclusive grants cannot coexist because a port is minted from
a linear supply, and the physical-coupling residue is detect-not-prevent. The third, a
boundary-to-threshold interface for choosing a split's K-of-N, is not a new edge
either. A split is a set of shares that must agree, so its threshold is the agreement
quorum of the bridge ([[category-bridge]], P5), its independence domains are the
separate typed modules the shares live in, and what picks the tier is edge 4. Nothing
homeless. Permission is a set of processes agreeing on a crossing, which is the bridge
connector's verify; no new mechanism, no owner.

## From the C-backend drop (2026-09-01)

Two edges opened by `d8bcec5` and `d0c5dd5`, which deleted
`lib/lowering/c/{mach,assemble,emit}.chiral`, `prog/compiler-c.prog` and the four
`e166_*` fixtures. ⚑ **Neither edge has an element number, deliberately.** The
author has assigned none, and the deferral rule forbids naming an `E#` that is not
already minted. Mint one in the change that closes the edge.

21. **Where `lib/evidence/ddc.chiral` points now.** [[decision-self-verification]]
    §0 moved DDC off the self-verification route: self-verification is N
    semantically distinct judgment cores that must agree, on the criterion of
    different FORMULATIONS, and DDC answers the trusting-trust axiom instead,
    which `docs/decisions/decision-scope.md` defers to the ownership-and-trust track. The file
    keeps a real job in the new scheme: it is the **referee**, the thing that
    adjudicates whether independently produced answers form a quorum and agree.
    Nothing else in the tree does that.

    **What transfers.** Verdicts as values, so a caller cannot read a divergence as
    a pass. A divergence that names WHICH two legs disagreed. A quorum gate that
    fires before any byte is read. And the file's own ⚑, which is the argument the
    new scheme needs verbatim: *agreement is not a quorum, because two runs of the
    SAME compiler agree with each other by construction.*

    **What does not transfer, and it is the substance of the edge.**
    - `leg2-disjoint?` demands that both `language` and `toolchain` differ. Three
      judgment cores are all chirality, all chirality-native, so **every** quorum
      would come back `ddc-bad-quorum "provenance not pairwise disjoint"`. The
      predicate is right for the threat it was written against and wrong for this
      one.
    - `Prov` has no FORMULATION axis. Its four fields are language, toolchain,
      author and epoch. The threat has changed from a backdoored toolchain to a
      shared mistake in how the rule set was encoded, and no field of `Prov`
      records how a core encodes the rules.
    - `ddc-fold` compares BYTES. Different formulations of one judgment agree on a
      **VERDICT**, and their byte-level outputs have no reason to match. The
      comparator is the wrong comparator for the new subject.

    ⚑ **And it currently gates nothing.** After the drop, `ddc-fold`, `ddc-legs`,
    `ddc-compare`, `ddc-verdict-code`, `ddc-leg0`, `ddc-leg1`, `ddc-legc`,
    `ddc-legcc` and `DdcR` have **zero callers and zero assertions**;
    `e166_ddc_legc.prog` was their only exercise. The file stays reachable only
    because `lib/evidence/test-floor.chiral:31` imports it for `bytes=?`. **A
    verdict nothing consults is not a gate**, which is the failure this tree names
    repeatedly ([[testing-floors]] Rule 3 and its run-the-mutant rule,
    [[banks/verification]] §5), and it now applies to the file that owns the
    concept. Say it rather than let the module read as coverage.

22. **`lib/memory/alloc-fixed.chiral` is at zero importers, and that is
    DELIBERATE.** The C-leg blob was its only importer and went with the drop. The
    module stays by author decision: the two allocators exist so a future metis
    program can take `alloc-fixed` or `alloc-growing` as it needs, which is the
    entire reason `alloc.chiral` is an interface record with the instances beside
    it ([[banks/verification]] Shard 8b). Recorded here because an unexplained
    zero-importer module is exactly what a cleanup pass deletes as dead code, and
    the reason it is kept lives nowhere the deleter would look.

    **What is genuinely open, as distinct from the record above:** no gate compiles
    it any more. It left the compile-only root set with the C-leg blob (roots went
    88 to 87), so nothing catches it rotting against `Alloc`'s five accessors. The
    edge is whether the fixed allocator gets a root of its own, an
    interface-conformance check like the one the 37-field `Mach` gets from having
    two instances, or a stated acceptance that it rots until someone needs it.

## Sequencing questions, not yet committed

- Build order for the type system: refinement, then linear, then capability,
  deferring dependent, region, subtype, effect. From the dumps, recorded not
  decided. **Effect is no longer deferred-undecided** (2026-07-22): its
  mechanism is settled ([[decision-effect-facets]]) and its build is sequenced
  (`.planning/SELF-HOST-PLAN.md`, E39/E70).
- Which security properties are blocking for the trusted base. The dumps say
  information flow, constant time, taint are blocking and the other five are
  incremental. Recorded not decided. See [[modules-security]].
- First backend choice among LLVM, Cranelift, QBE — **closed by reconciliation**
  (2026-07-22, [[decision-backend]]): the first backend is the built chirality Mach
  path; none of the three enters the trusted path.
