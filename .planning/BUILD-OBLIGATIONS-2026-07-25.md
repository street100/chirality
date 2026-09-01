# Build obligations surfaced by the edge-walk (2026-07-25)

## Why this note exists

The 2026-07-25 edge-walk shaped seven open edges (1, 2, 4, 14, 15, 17, 18). Two
convergent **BUILD obligations** fell out — mechanisms that several edges
independently reduce to, but which the catalog currently smears across *property*
elements rather than homing as *mechanisms*. This note names them for the doctools
loop (route → stage → author-reconcile). Build-state is authoritative from
`.planning/audit/CONFORMANCE-MAP.md`; nothing is minted here — the element-minting
calls are surfaced as author calls below.

## Outbound confinement — the outbound membrane half

- The membrane runs both ways. The **inbound** integrity half is built
  (`bridge.verify`, CONFORMS). The **outbound confinement** half — A may emit into
  B only confined (no live capability leaks out, the exposure window bounded,
  encrypt-if-secret) — is **not built** (CONFORMANCE-MAP "Outbound confinement not
  built"; [[banks/port]] Shard 5, the port's single largest unbuilt shard).
- **Four independent edges converge on it:** edge 14 (an async moved-continuation
  must not leak capabilities across the crossing), edge 17 (the alarm-visibility
  *tier* is the confinement tier of the divergence evidence), edge 2 (a
  declassifying crossing *is* an outbound-confinement act), edge 15 (an irreversible
  outbound effect degrades to detect-and-account precisely because nothing confines
  it *before* it escapes).
- Current catalog home is **smeared**: the id **E73 is reserved** for it (HANDOFF
  triage; LANE-5 "security-completion wave") but the catalog row was **never
  written** (the catalog stops at E72); it otherwise only "overlaps E44" (IFC /
  non-interference — a *property*) and E55 (C-bridge evidence). The *mechanism* —
  the outbound membrane that bounds the exposure window before an effect crosses to
  B, dual to `bridge.verify` — has a reserved id but no written element. **unbuilt.**
- Home: [[banks/port]] Shard 5 · [[category-bridge]] outbound face · [[category-typed]] "the handoff to C" · CONFORMANCE-MAP slice D.

## Tier carrier — how a tier rides the type

- [[split-role]] settles the tier *discipline* (a minimum rung per axis —
  containment / independence / verdict — default-high, under-reach = a typed gap)
  but not the **carrier**: how a tier is actually represented *in the type*. A
  refinement predicate? a classification kind? a dedicated grade factor beside
  info-flow? That mechanism is **DESIGNED** in direction, its carrier **unbuilt**.
- **Three edges converge on it:** edge 4 (what picks a value's default tier =
  the type-carried classification), edge 17 (the alarm-visibility tier), edge 18
  (tier-weight composition needs a carrier to subtype at the seam).
- Current catalog home: **none for the carrier.** E44 covers tier-weight
  *compositionality* (the property, edge 18) but not the carrier itself.
- Home: [[split-role]] §Tiering · [[decision-profiles]] · [[vocabulary]] "tier weight".

## Captured elsewhere this session (settled parts)

- The *edge-level* shapings are already crystallized in `docs/open-edges.md`
  (edges 14/17/2/15 and 4/17/18) and their banks; this note consolidates only the
  BUILD residue those shapings pointed at, so it is not folded into edge numbering.
- Info-flow's own split (secrecy-lattice grade vs non-interference property) is
  edge 2 / [[modules-security]] and rides E44 (IFC), not restated here.

## Open author calls (do NOT silently resolve)

> **RESOLVED 2026-07-26 (Batch A).** The author ratified both mints: outbound
> confinement → **E73** (the reserved id, now written), tier carrier → **E74** (new),
> and the coupled edge-6 typed ABI-layout abstraction → **E75**. Rows are in
> `SELF-IMPLEMENT-CATALOG.md` §XI; docket D8/D9 flipped RESOLVED. The two calls
> below are kept as the rationale of record.

- **Ratify and write the reserved E73 row for outbound confinement?** The id E73
  is already reserved for it (HANDOFF triage; LANE-5) but was never written into
  the catalog (which stops at E72); today it is otherwise
  smeared across E44 (the IFC property) + E55 (evidence bridges); four edges
  converge on the outbound-membrane *mechanism* as a distinct build. Recommendation:
  **yes** — a mechanism element ("outbound confinement membrane — exposure-window
  bound + capability-non-leak + encrypt-if-secret, dual to `bridge.verify`"), with
  E44/E55 as its consumers. Author call: it touches the catalog roadmap (a new E#).
- **Mint a catalog element for the tier carrier, or fold it explicitly into E44?**
  Edges 4/17/18 share one unbuilt carrier; E44 holds only the compositionality
  property, not the representation. Recommendation: **mint** a small carrier element
  ("tier carrier — how a per-axis split-role tier rides the type; consumed by E44
  tier-weight and by alarm-visibility"), or state in E44's row that its scope
  includes the carrier. Author call: roadmap scope.
