---
node: module-map
layer: module
refines: [splitting-law]
related: [modules-core, modules-security, modules-custody, modules-broker, modules-substrate, modules-bridges, modules-lowering, modules-staging, joining-law, open-edges]
status: draft
updated: 2026-07-21
---

# Module map

The full module list, placed on the two axes. This note is the hub. Each row
links to the subsystem note that describes it. Provenance tags: `frame` came
from this spine, `dump+` was added by the dump audit, `split` was produced by
the splitting law. See [[dump-integration]]. The modules are the alphabet; how
they string together is the [[joining-law]].

## Category A, typed

| Module | Stratum | Role | Note | Source |
|---|---|---|---|---|
| kernel-spec | lower | the type theory as a requirement type: judgment forms, QTT rules, port algebra. The small human-audited demanded statement, not an implementation. See [[decision-split-checker]] | [[modules-core]] | split |
| kernel-core | lower | one small trusted (climbing to machine-verified) derivation checker: QTT + grade accounting + NbE-with-large-elimination + totality + certificate verifier. The trusted core; the producers around it are untrusted. See [[decision-split-checker]], [[certificate-discipline]] | [[modules-core]] | split |
| process / core-ir | cross | the one atom and the canonical IR | [[modules-core]] | frame |
| types | upper | substructural and quantitative features: linear, refinement, dependent, region, subtype, capability | [[modules-core]] | frame |
| effects | upper | the port algebra | [[modules-core]] | frame |
| cost-typed | upper | graded time, space, termination | [[modules-core]] | frame |
| totality | upper | total by default, partial as marked | [[modules-core]] | frame |
| syntax | upper | surface forms and profile rendering | [[modules-core]] | frame |
| reflect-typed | upper | staged metaprogramming over typed terms | [[modules-core]] | frame |
| information-flow | upper | secrecy lattice, non interference | [[modules-security]] | dump+ |
| taint | upper | trusted and untrusted tracking | [[modules-security]] | dump+ |
| constant-time | lower | verified at lowering, first customer of preserve-check | [[modules-security]] | dump+ |
| isolation-type | upper | domain and label proof half | [[modules-security]] | split |
| freshness-discipline | upper | linear use once token half | [[modules-security]] | split |
| audit-mark | upper | audit obligation as an effect | [[modules-security]] | split |

## Category B, untyped

| Module | Stratum | Role | Note | Source |
|---|---|---|---|---|
| raw-mem | lower | physical memory and pointers | [[modules-substrate]] | frame |
| device / dma | lower | peripherals that write host memory | [[modules-substrate]] | frame |
| foreign | lower | the far side of the FFI | [[modules-substrate]] | frame |
| register-root | lower | the register held master secret | [[modules-substrate]] | frame |

## Category C, the bridge

| Module | Stratum | Role | Note | Source |
|---|---|---|---|---|
| kernel-gate | cross | runtime port mediation, mostly dissolved into the type check | [[modules-broker]] | frame |
| broker | cross | runtime lifecycle supervisor | [[modules-broker]] | dump+ |
| adhikara | cross | the capability protocol both broker halves speak | [[modules-broker]] | dump+ |
| custody-split | upper | T1 and T3 split values, shares, combine as effect | [[modules-custody]] | frame |
| redundancy | upper | copies must agree, divergence detection | [[modules-custody]] | frame |
| datum-policy | cross | per datum security weaving | [[modules-custody]] | frame |
| split-provider | cross | the general split role: guarded combine over independent sources, provenance-disjointness check, agreement or certificate, per-axis tiers. Generalizes `custody-split`; required by modules, supplied by the profile. Home of agreement for the unprovable residue (floor, hardware, proofless solvers). See [[split-role]] | [[modules-custody]] | split |
| bridge-supervisor | cross | typed manager over foreign and device, driver wrapping | [[modules-bridges]] | frame |
| attestation | cross | evidence chain anchored on a hardware root | [[modules-bridges]] | dump+ |
| isolation-enforce | cross | runtime compartment over foreign code | [[modules-bridges]] | split |
| freshness-verify | cross | reconcile against external clock or counter | [[modules-bridges]] | split |
| audit-reconcile | cross | write once trail checked against live state | [[modules-bridges]] | split |
| runtime | lower | critical sections, preemption control, register custody | [[modules-bridges]] | frame |
| reflect-raw | cross | substrate mutating self modification, bounded by the floor | [[modules-bridges]] | frame |

## Lowering and staging

| Module | Stratum | Role | Note | Source |
|---|---|---|---|---|
| tal | lower | typed assembly, the floor, its own A, B, C | [[modules-lowering]] | dump+ |
| translate / lower | lower | type preserving lowering | [[modules-lowering]] | frame |
| preserve-check | lower | proof a lowering opened no hole | [[modules-lowering]] | frame |
| cheri-floor | lower | the metal level on CHERI hardware: types carried into silicon, enforcing the B mark at the bottom | [[modules-lowering]] | dump+ |
| bootstrap-floor | lower | the unverifiable base the checker runs on, governed as a cross-checked set of tuned runtimes, not a bare B atom. The floor face of the kernel | [[modules-staging]] | split |
| stage | cross | the multi stage binding time spine | [[modules-staging]] | gap |
| specialize | cross | partial evaluation, normal form precompute | [[modules-staging]] | gap |
| pregen | cross | seed to artifact, derive not store | [[modules-staging]] | gap |
| link / load | lower | install generated code into a running process | [[modules-staging]] | gap |

## The C bridges are one elaborator over elements

The category C bridges above (`redundancy`, `custody-split`, `split-provider`,
`attestation`, `freshness-verify`, `audit-reconcile`) are not bespoke per referent.
Each is the general bridge elaborator instantiated with an evidence element (K-of-N,
MAC, attestation, reconcile) and a target type, the way lowering is one `translate`
plus a generic `preserve-check`, and each re-checks a certificate rather than running
a test ([[certificate-discipline]]). See [[decision-bridge-elaborator]] and
[[split-role]].

## Named gaps

Modules identified as needed but not yet designed are marked `gap` above and
tracked in [[open-edges]]: stage, specialize, pregen, link/load, and the
auditor facing proof presentation layer. `jit` is not a module; it dissolves
into stage plus tal. See [[modules-staging]]. The `bootstrap-floor` row is placed
in direction but its internals (how many tuned runtimes, how independent, how
they relate to `runtime`) are open; see [[joining-law]] and [[open-edges]].
