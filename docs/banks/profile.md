---
node: banks/profile
layer: bank
tier: depth
related: [decision-profiles, glossary, vocabulary, joining-law, modules-core, category-typed, totality, memory-model, open-edges, status-ledger, banks/module, banks/runtime]
status: draft
updated: 2026-09-04
---

# Bank: profile

> **What a bank is.** This is the depth tier under the thin relational notes in
> `docs/`. It holds the *full refraction* of one concept — how a thing that is a
> single monolith in a conventional language is, in chirality, a **sum of shards**
> living in principled homes, most of them already built. Thin notes link *into*
> here. If you came here about to say "chirality is missing a config/manifest/DI
> system," read §4 first: the feature you are reaching for is almost certainly
> already refracted across homes you have not connected.

---

## 1. The concept in chirality

**A profile is a named set of modules required to achieve a target, rendered over
a fixed port set.** (glossary; [[decision-profiles]].) It is a **typed conformance
contract that stages a [[banks/runtime]]** — not a knob-set that configures one.

Sharpened, a profile is exactly four things bound together:

1. a **name**;
2. a **manifest** — the set of modules it composes (in the scaffold: the `import`
   lines above the declaration) plus the connectors that string them
   ([[joining-law]]);
3. a **frozen port set** — the finite list of typed crossings the composite may
   use, *and nothing else*; and
4. a **target** — a *requirement type* the staged runtime's composite type must
   **satisfy by subtyping**.

Optionally it carries a **memory-discipline** clause (`(memory linear)` /
`(memory region)`) and a **`(total)`** clause. Its validity is a *type-checking
question*, taken by the front end while the source is read: `chirality check FILE`
(`bin/chirality:161`) compiles and discards the ELF, and the profile judgments run
on that path.

**What it IS:**

- a **typed object**, valid for exactly the targets whose requirement type its
  composite satisfies (`decision-profiles` §"Consequence: profiles are testable");
- **additive toward a target**, never subtractive from a maximal language — there
  is no "full chirality" you strip down; `chirality-bare` is *the minimal module set that
  is a verified substrate*, which happens to be small (`decision-profiles` §"The
  decision");
- a **conformance check reusing three existing checks** — connectors preserve,
  every module routes through a port, and the composite subtypes the requirement.

**What it IS NOT:**

- **NOT a build config / `#ifdef` feature-flag set.** A flag *toggles code paths*
  in one artifact; a profile *selects modules* and never adds or removes a port.
  Where a permissive profile "allows" what a strict one forbids (e.g.
  partiality), that permission is *still a port in the type* — flipped from loud
  opt-in to quiet default. The cost gradient's zero point moves; **the port set
  does not** (`decision-profiles` §"Why this resolves it").
- **NOT a linker script / dependency manifest.** A dependency manifest lists
  *artifacts to fetch and order*; it carries no type and proves nothing. A
  profile's manifest is *typed* — its composite has a type, and conformance is a
  judgment against a spec, not a resolution of version constraints.
- **NOT a DI-container / service-wiring config.** DI wiring is runtime lookup by
  name/interface with no static guarantee that the graph is complete or safe. A
  profile's "wiring" is the **connectors** ([[joining-law]]), each of which
  *preserves an invariant*; the completeness question ("does this compose to the
  target?") is discharged at check time by subtyping, not deferred to a runtime
  resolver.

The one-line refutation of all three: **a profile conforms to a frozen port set
rather than configuring it away** (P3, P5; `decision-profiles` §"Principle
basis"). Configuration mutates the substrate; conformance is measured against it.

---

## 2. The refraction — the shards

A profile is not one mechanism. It is a *sum* of shards, each already homed:

### Shard A — the manifest (module set + connectors)
**What:** the roster of modules the profile composes, plus the typed connectors
that string them toward the target. The splitting law gives the alphabet, the
joining law the grammar (`decision-profiles` §"A profile is modules plus
connectors").
**Home:** [[banks/module]] (the modules), [[joining-law]] (bridge / lowering /
staging / port-composition — the four connectors). The manifest is the *set-of*;
the elements live in the module bank.
**Build-state:** CONFORMS. The manifest is the `import` lines
above the `(profile …)` form; the composite is the loaded globals, `sig-globals`
at `lib/typing/kernel.chiral:239`. Rosters "held loosely, derived
not asserted" (`decision-profiles`). Evidence:
`prog/demo/profile-tomodachi.chiral:30`.

### Shard B — the frozen port set
**What:** the finite, profile-invariant set of typed crossings the composite may
use — *the governance surface*. A profile *selects which of the frozen crossings
are in scope*; it never mints or removes a port.
**Home:** the `(ports …)` clause + P3 (the port set is closed; [[category-typed]],
[[vocabulary]] "port"). This is the capability/containment shard — see cross-cut
§3.
**Build-state:** the declaration half is checked while the profile form is read.
`mf-check-ports` (`lib/surface/parse.chiral:907`) rejects any listed name that is
**not a declared extern** (`mf-port-unknown`) and any name that is **pure**
(`mf-port-pure`), and the manifest reaches the front end at
`lib/lowering/compile-front.chiral:322`. ⚑ The use-site half, computing the
crossings the composite actually reaches and flagging one outside the frozen set,
was the oracle's `verify_profiles` and has **no live referent**.
`lib/surface/parse.chiral:723-724` states the boundary in its own words: the slice
parses, judges and stores, and the refusal at emit reads `sig-profiles` later and
is not there. Evidence: `prog/demo/profile-tomodachi.chiral:28-29` deliberately
*omits* `time-mono` — "the companion has no clock beyond the poll deadline". The
ledger's **IMPLEMENTED** rung for "Frozen-port-set conformance" is the right one
and the reason is now the missing use-site check rather than a host-side driver.

### Shard C — the target as a requirement type
**What:** the target ("be an OS substrate," "host the broker," "be the
tomodachi") stated as a **typed spec**: the ports it must offer, the effects it
must support, the guarantees it must provide — expressed as a list of
`(require name ty)` rows.
**Home:** the `(target …)` top-form; the `types`/`effects` modules of
[[modules-core]] supply the types the rows are written in.
**Build-state:** CONFORMS (the slice of G9 that is parsed and judged).
`handle-target` (`lib/surface/parse.chiral:833`) with `mf-req` (`:783`) elaborates
each requirement's type in the empty local scope and refuses it unless it infers
to a universe (`mf-req-not-type`), so a target is a *well-typed* spec, not prose.
Evidence: `prog/demo/profile-tomodachi.chiral:15`'s `(target tomodachi (require main …)
(require draw (-> (0 n I64) (=> (1 p (Pool n)) Mood (Pool n)))) …)` — note the
requirement is a **dependent, linear, effectful** arrow: the spec can demand a
memory bound (`(Pool n)`) and a linearity (`1 p`) as *part of the type*.

### Shard D — conformance = the subtyping check
**What:** "the profile fits the target iff its composite type **satisfies** the
requirement type: at least those ports, at least those effects, the demanded
guarantees." Satisfaction is a **subtyping relation in the existing type system**
— which is why validity is checkable, not a slogan (`decision-profiles`
§"Conformance").
**Home:** the checker's `subtype` relation (`lib/typing/kernel.chiral:807`).
Conformance is *not a
new analysis* — it is three reused checks (preserving connectors, port-routing,
subtyping). See cross-cut §3.
**Build-state:** ⚑ **the conformance check has no live referent, recorded
2026-09-04.** The mechanism it would reuse is real: `subtype`
(`lib/typing/kernel.chiral:799`) is IMPLEMENTED, and a target's rows are parsed and
judged into the Sig by `handle-target` (`lib/surface/parse.chiral:833`). What is
missing is the step between them. The oracle's `_target_rows`, which looked each
requirement's provider up and called subtype on it, went with the Python and
nothing in `lib/` decides that a composite satisfies its target's rows. So the
row is mechanism IMPLEMENTED and application ABSENT, the same shape
[[banks/capability]] Shard C carries for grant-narrowing. Evidence:
`prog/demo/profile-headless.chiral` is a *second*
runtime — different port set, same behavior modules — declared against a distinct
target, and nothing checks that it meets it.

### Shard E — the memory-discipline clause
**What:** the optional `(memory linear)` / `(memory region)` clause naming the
composite's allocation discipline over the same `(Pool n)` substrate.
**Home:** the memory-discipline modules (`lib/memory/mem-linear.chiral`,
`lib/memory/mem-region.chiral`; [[memory-model]]). Discipline is a *profile choice*
because space is a port (P3).
**Build-state:** linear CONFORMS/ENFORCED (E22 — `mem-put-checked`, bounds
discharged at compile time for literal/guarded offsets); region REFACTOR (E41/E22
— lib built but the capacity check is still a *runtime* branch, gated on the E9
arithmetic-expression fragment (`cursor + size ≤ cap`; symbolic `v < n` landed
2026-07-06)). `mf-memory-of` (`lib/surface/parse.chiral:939`) admits `linear` and
`region` and refuses anything else with `mf-memory-unknown`;
`tools/test/profile-target.sh:92` asserts the refusal and its message. Evidence:
`prog/demo/profile-tomodachi.chiral` `(memory linear)` — "a different discipline over
the same `(Pool n)` substrate is a one-word change here plus its import."

### Shard F — the `(total)` clause
**What:** a flag demanding the composite be **a sub-category where every morphism
is total** — the `chirality-verify` requirement type.
**Home:** the totality modality ([[totality]]; the `(total)` profile clause is one
of two enforcement handles, the other being `sig.require_total`).
**Build-state:** EXTEND (E11). Totality is *classified* everywhere (all three
pillars — positivity, coverage, termination — built and recording
`sig.totality`), and **enforced on demand** via the profile clause, but not yet
globally on-by-default (gated on E47 sized types + E50 mutual/lexicographic).
`mf-has-total` (`lib/surface/parse.chiral:956`) reads `(total)` as a bare flag
onto the profile record, and `tot-gate` (`lib/typing/totality-check.chiral:153`)
is the gate, called from the front end at `lib/lowering/compile-front.chiral:340`;
a source declaring no `(total)` profile pays nothing (`:333`). Evidence:
`prog/demo/verify-total.chiral` — adding an unguarded `spin` loop turns the gate
against the source. ⚑ That demo's own header, measured 2026-09-04, still invokes
the cut oracle by module and names a subcommand the CLI does not have; the repoint
is an edit to `prog/` and is left to the owner of that tree.

### Shard G — the driver that runs the judgment
**What:** the command that renders all of the above into a pass/fail answer per
profile and per target.
**Home:** the CLI entrypoint (E2), `bin/chirality`.
**Build-state:** ⚑ **partly present, corrected 2026-09-04.** There is no
`chirality verify`: `bin/chirality` dispatches `compile`, `run`, `check` and
`test` (`:211-214`) and has never had a `verify` arm. What survives of this shard
is `chirality check FILE` (`:161`), which compiles and discards the ELF, so every
judgment the front end takes while reading a profile runs on that path: the port
list, the discipline, the target rows, the `(total)` gate. What does not survive
is the *report*, a per-profile and per-target pass/fail rendering, and the two
use-site checks it carried (Shards B and D). The *testability* consequence
(`decision-profiles` §"Consequence: profiles are testable") is real for the
declaration half and absent for the use half.

---

## 3. Cross-cuts — where a shard of "profile" IS another concept's shard

This is the highest-value section: the places where "you need a profile feature"
is really "that already lives in another home."

- **profile ↔ [[banks/module]] — a profile IS a set of them.** Shard A is not a
  new container type; it is *the set-of over modules*. Everything about
  individuation-by-type, versioning, replacement lives in the module bank; the
  profile only *names a roster*. Do not re-document module semantics here.

- **profile ↔ [[banks/runtime]] — a profile STAGES one.** This is the load-bearing
  cross-cut. "The composite type is *the type of the runtime the profile stages*"
  (`decision-profiles` §"Composite type"): a profile selects modules + connectors,
  **staging assembles them into a runtime**, a runtime is a process, a process is
  its type. So **"the system changes as configured" is not a profile feature — it
  is the runtime being staged differently**. `prog/demo/profile-headless.chiral` vs
  `prog/demo/profile-tomodachi.chiral` are *two runtimes from one module base* — that
  IS "configurable profiles" at this scale. The dynamic/lifecycle story belongs to
  [[banks/runtime]]; the profile is the *static contract* that says which runtime
  is legal.

- **conformance-as-subtyping ↔ the checker's subtype relation (Shard D).** There
  is **no profile-validation engine**. Conformance is meant to reuse `subtype`
  (`lib/typing/kernel.chiral:799`) verbatim, and the call site that would do it is
  absent (Shard D). Any request for "a profile matcher / compatibility
  resolver" is answered by the *type system's existing subtyping* — the same
  relation that does universe cumulativity. If subtyping gets richer (grant
  narrowing, effect rows), conformance gets richer *for free*.

- **frozen-port-set ↔ capability / containment (Shard B).** The `(ports …)` clause
  is a **capability manifest**: authority is the set of ports you hold
  ([[vocabulary]] "capability"). Freezing the set is P3 governance applied to a
  whole runtime; omitting `time-mono` from the tomodachi profile is *capability
  attenuation expressed as a profile*. The confinement half doubles up:
  behavior-pack requirements are *pure arrows*, so "a conforming pack cannot
  perform a port operation" (`prog/demo/profile-tomodachi.chiral`) — the requirement
  type and the port set jointly confine.

- **`(total)` clause ↔ the totality modality (Shard F).** The clause does not
  *implement* totality; it *demands* the totality property the [[totality]] pillars
  already decide. The profile is a **customer of the totality checker**, exactly as
  revocation is a customer of the alarm system. `chirality-verify` is "the first
  concrete requirement type" written under the conformance mechanism
  ([[open-edges]] edge 18).

- **memory-discipline clause ↔ [[memory-model]] (Shard E).** The `(memory …)`
  choice is a *profile-level selection among discipline modules*; the disciplines
  themselves (linear bounds-checking, region cursors) are owned by the memory
  bank. Space-as-a-port (P3) is what makes discipline a profile choice at all.

---

## 4. Native → chirality translation (the anti-misfire table)

| Conventional monolith | The MISFIRE | The correction (built shards + genuinely-new residue) |
|---|---|---|
| **Build config / feature flags** (`#ifdef`, Cargo features, `-D`) | "chirality needs a feature-flag / build-variant system to configure builds." | **Already refracted.** Variants = *additive module selection* (Shard A) over an **invariant** port set (Shard B); a "flag" that grants a capability is *a port in the type* (`decision-profiles`). No flag system to build — the composite's type IS the variant. New residue: none. |
| **Dependency manifest / lockfile** (`package.json`, `Cargo.lock`) | "chirality needs a manifest + resolver to declare and pin deps." | **Already refracted.** The manifest is the module roster (Shard A); "does it fit together" is not version-resolution but **subtyping against the target** (Shard D). New residue: none for the *typed* question. (Fetch/version pinning is out of the language's scope by design.) |
| **DI container / service wiring** (Spring, Guice) | "chirality needs a DI container to wire modules and inject implementations." | **Already refracted.** Wiring = the four **connectors** ([[joining-law]]), each preserving an invariant; "graph complete & safe" is discharged by conformance subtyping (Shard D), not a runtime resolver. New residue: none — the resolver is a compile-time type check. |
| **Runtime/OS image spec** ("this is an OS build", "this is firmware") | "chirality needs a target-triple / image-builder for OS vs app vs firmware." | **Mostly refracted.** Each target is a **requirement type** (Shard C); "be an OS substrate / firmware" is a spec the composite subtypes. `chirality-bare` = minimal conforming module set, not app-minus-features. New residue: the **whole-assembly** requirement types (non-interference, tier-weight compositionality) — see §5. |
| **Conformance / cert test suite** ("does this runtime meet the spec?") | "chirality needs a conformance test harness." | **Refracted into type-checking.** The front end runs the *judgment*, not tests, and `chirality check FILE` is the command that runs it (`decision-profiles` §"Consequence"). Show-your-work, not a test-pass. New residue: only the properties that are *not compositional* need a dedicated global argument (§5). |

---

## 5. What's genuinely new / unbuilt (honest residue only)

The refraction is real, but not everything is done. Preserving the gradient:

- **Whole-assembly conformance — DECISION-gated (E44 / edge 18).** This is the one
  true open edge. Structural demands ("offers port X") are **plain subtyping and
  work today**. But a *whole-assembly* property — every morphism total for
  `chirality-verify`, **non-interference across the composite**, tier-weight
  compositionality — is subtyping-checkable *only if each module preserves it so
  the composite does*; where it is **not** compositional it needs a **global
  analysis**, not a per-row subtype check. **Which properties are compositional is
  UNPINNED** (CONFORMANCE-MAP G-row "Whole-assembly conformance": DECISION;
  `decision-profiles` §final; [[open-edges]] edge 18). **Tier-weight specifically
  was shaped 2026-07-25** (edge 18 edge-walk): it is *not* a fourth mechanism but
  lands inside the D4 three-class shape by leg — **containment** class 1 (the tier
  of the composite's effective port set, meet-composed by port-set subtyping, a
  narrowing wrapper *lifts* it); **independence** class 2 for the disjointness
  relation (checked node-local at the guarded combine) with the per-member tag
  class 1 at the seam; **verdict** rides independence. So the tier-weight part of
  this residue narrows to the per-axis tier *arithmetic* and the lifted-containment
  rule, not "whether it composes." The current `verify_profiles` still does
  named-crossings + the `(total)` clause and *no more* — status-ledger flags
  exactly this: "named crossings only; edge 18 open." So a profile today
  **CONFORMS on port-set + target-rows + per-def totality, and does NOT yet cover
  cross-composite non-interference/tier-weight.**

- **`(total)` enforcement default — EXTEND, gated (E11 on E47+E50).** The clause
  *works on demand*; flipping enforcement global-default-ON is deferred until sized
  types (E47) and mutual/lexicographic termination (E50) prove enough measures not
  to regress real code.

- **`region` memory discipline — REFACTOR (E41/E22).** Selectable as a profile
  clause, but the capacity check is still a runtime branch until E9's
  arithmetic-expression bounds (`cursor + size ≤ cap`) land — symbolic `v < n`
  landed 2026-07-06 (edge 3). `linear` is fully ENFORCED (E22).

- **Sequencing note (settled, not a gap):** conformance needs "at least that much
  subtyping machinery" — [[modules-core]] deferred the subtype feature to a later
  slice, now IMPLEMENTED (status-ledger). This is an ordering constraint that has
  been discharged, recorded so no one re-files it as missing.

Everything else in §2 (Shards A–G minus the above) is CONFORMS/built. **Do not
name a phantom "profile system," "flag engine," or "conformance harness" — those
are the refraction, already homed.**

---

## 6. Relational anchors — thin notes that should link INTO this bank

- [[decision-profiles]] — the settled decision; the canonical thin note. Its
  "Consequence: profiles are testable" and "The conformance mechanism" sections
  are *summaries of* Shards C/D/G here.
- [[glossary]] / [[vocabulary]] — "profile," "requirement type," "conformance"
  entries point here for depth.
- [[joining-law]] — the connectors (Shard A grammar).
- [[modules-core]] — `syntax` module ("surface forms and profile rendering"),
  `types`/`effects` (requirement-type vocabulary), the subtype-sequencing note.
- [[category-typed]] — the frozen port set / P3 (Shard B).
- [[totality]] — the `(total)` clause customer (Shard F).
- [[memory-model]] — the memory-discipline clause (Shard E).
- [[open-edges]] — edge 18 (whole-assembly conformance) and the G9 resolution.
- [[status-ledger]] — build-state rungs for the frozen-port-set / totality rows.
- [[banks/module]], [[banks/runtime]] — the two sibling banks the biggest
  cross-cuts point to (§3): a profile is a *set of modules* and *stages a runtime*.
