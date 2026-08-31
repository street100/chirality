---
node: relations
layer: navigation
related: [index, splitting-law, joining-law, module-map, open-edges, permission-model, live-environment]
status: draft
updated: 2026-07-04
---

# Relations

The edges between notes. Each note also lists its own `related:` field; this
note names the edge types so the graph reads the same everywhere.

## Edge types

- refines: B makes A more precise without contradicting it.
- implements: B is the concrete module or mechanism for the idea in A.
- splits: B is one half of a module that A said must be cut in two.
- contradicts: B and A cannot both stand; one is wrong. Resolved edges point at
  the `decision-*` note that settled them.
- supervises: a category C note governs a category B note.
- cites: B uses a fact or claim recorded in A.

## Spine

```
PRINCIPLES (root)
   |
   | refines
   v
thesis  ->  axis-typeability  ->  category-typed / category-untyped / category-bridge
   |              |
   |              | uses
   |              v
   |         splitting-law  ->  module-map
   |                                 |
   | refines                         | implements
   v                                 v
axis-altitude  ----------------> modules-lowering
```

## Category to module

- [[category-typed]] is realized by [[modules-core]], [[modules-security]] (the
  typed parts), and the typed half of [[modules-lowering]].
- [[category-untyped]] is realized by [[modules-substrate]].
- [[category-bridge]] is realized by [[modules-custody]], [[modules-broker]],
  [[modules-bridges]], and the silicon floor noted in [[modules-lowering]].

## Decisions and what they touch

- [[decision-profiles]] settles a contradiction between subtractive composition
  and govern-the-ports. Touches [[modules-core]] and the port idea in
  [[category-typed]].
- [[decision-brokers]] splits one name into two modules. Touches
  [[modules-broker]] and [[splitting-law]].
- [[decision-backend]] forbids compiling to C. Touches [[modules-lowering]] and
  [[axis-altitude]].
- [[decision-b-in-type]] puts the quarantine in the type, not the packaging.
  Touches [[category-untyped]] and [[modules-substrate]].
- [[decision-split-checker]] holds the checker as a small trusted core plus untrusted
  certificate producers (not a quorum). Touches [[modules-core]],
  [[certificate-discipline]], and [[split-role]].
- [[decision-bridge-elaborator]] makes the bridge one general elaborator over evidence
  elements. Touches [[joining-law]] and [[category-bridge]].

## Trust discipline

- [[certificate-discipline]] `refines` [[joining-law]] and P1: a trusted checker
  re-checks untrusted producers' certificates; chirality proves elements and the
  interactions that admit proof, never the whole system.
- [[split-role]] `implements` P5/P7 for the unprovable residue: the split as a tiered
  substrate-provided role (containment by ports, independence by provenance, verdict by
  agreement or certificate). Touches [[modules-custody]] and [[decision-profiles]].

## Permission

- [[permission-model]] refines [[node-architecture]] and [[category-bridge]]. It
  applies nodes-touch-only-through-ports and bridge-agreement to how a crossing is
  permitted: a grant presented at a crossing, permitted by the bridges it traverses
  agreeing (P6, P7). No new module; it names the grant and the altitude split of
  authority.

## Views

The five `view-*` notes ([[view-security]], [[view-types]], [[view-runtime]],
[[view-authoring]], [[view-implementation]]) carry only `cites` edges. Each
restates the base from one seat and adds nothing; on any conflict the cited note
wins. They are navigation surface, not design surface, so no other note should
ever cite a view.

## Application and inspirations

- [[live-environment]] is an application note. It `cites` the foundational notes
  it applies ([[node-architecture]], [[process-and-runtime]], [[splitting-law]],
  [[axis-typeability]], [[axis-altitude]]) and names the reflective floor
  (open-edge 5) as its forcing function. It adds design content (the granularity,
  substrate, and display dissolutions), so unlike a view it is design surface.
- The `insp-*` notes ([[insp-smalltalk]], [[insp-lisp-machine]], [[insp-emacs]],
  [[insp-oberon]], [[insp-erlang-beam]], [[insp-capability-os]], [[insp-unison]])
  are reference surface. Each `cites` [[live-environment]] and an external system,
  and carries a `takes` / `differs` contrast, never a design claim of its own.
  Like the views, they are cited outward but not inward: no design note should
  cite an inspiration, so no external system's shape can leak back into the
  design. That rule is the structural form of the anchor-on-no-representation
  discipline the [[live-environment]] hub states.

## Connectors are not note edges

The edge types above relate notes; they document the design. Connectors in the
[[joining-law]] relate modules; they are part of the design. The four are bridge,
lowering, staging, and port composition. A `supervises` edge between two notes,
for instance, documents a bridge connector between the modules they describe.

## Open edges sit on seams

Every entry in [[open-edges]] is an unresolved boundary between two notes. The
note records which two.
