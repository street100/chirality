---
node: decision-reflective-floor
layer: decision
related: [live-environment, decision-split-checker, certificate-discipline, process-and-runtime, modules-core, bootstrap-sequence, permission-model, open-edges]
status: settled
updated: 2026-07-27
---

# Decision: the reflective floor is a frozen judgment, changed only by certified succession

Settles [[open-edges]] edge 5 (docket D3, resolved-in-direction 2026-07-22,
sharpened 2026-07-24). P1's second clause — the capability kernel is *expressible*
yet not *reconfigurable from within* — had a direction but no drawn line. This note
draws it. It also serves as edge 5's home note.

## The fork

Today `Sig` exposes every seam (`ext_check`, `rules`, hooks) as a mutable Python
attribute, so a running chirality could in principle reconfigure its own judgment core.
The reflective floor is the boundary that forbids exactly that. Draw it too high and
self-modifying code forges authority; too low and the [[live-environment]] (the
maximal live-reconfiguration workload, the forcing function) cannot do useful
metaprogramming.

## The decision

**A runtime's judgment — `kernel-core` + `kernel-spec` — is staged-in, never
granted-to, and not swappable after staging completes.** The reflective floor sits
at the small trusted core: "what is modifiable from inside" becomes "what the
trusted core will not certify" ([[decision-split-checker]],
[[certificate-discipline]]). Above that line, reflection is free; the line itself is
not reflectively reachable.

The mechanism (E45) reduces to **freezing `Sig` at link/install completion** — the
judgment becomes immutable once staging is done.

**Why in-place mutation is forbidden: it is *unsound*, not merely unsafe.** Checking
a term with rules that change under the check has no fixed meaning. So this is the
floor, not a liveness limit — the immutability is a soundness requirement, not a
policy that a braver design could relax.

## Freeze binds the judgment, not the population (sharpened 2026-07-24)

The freeze binds the *judgment* (`Sig`), **not the population**. An instance's
hosted modules, its state, and its port wiring stay freely mutable while its
judgment is frozen — so most "live" change (redefine, add, swap, rewire, inspect)
is **population editing** the freeze never touches. Churn (spawn/teardown) is forced
*only* for a **judgment** change.

Because process is self-similar (G3, [[process-and-runtime]]), freeze-`Sig` is only
ever as coarse as the moduleset-instance boundary drawn, so a judgment change is a
**fine-grained certified succession** — stage a successor instance, certify its core
against `kernel-spec`, cut over — not a whole-world restart. Identity rides the ports
(edge 14, move-only); state rides a typed move. Its liveness is
**parity-within-a-cutover-window, not a true hot-swap**: the window is (1)
stage+certify latency, (2) state-migration size, (3) in-flight continuation drain,
with **atomic port hand-over** a hard obligation.

## The succession wall

No uncertified succession. A stager's core **certifies a successor's core against
`kernel-spec` before it runs**; a mis-checked child does not get the judgment — it
degrades to a **B-blob bounded by its granted ports** ([[category-untyped]] under
containment). Two obligations this surfaces for E45:

1. Succession must certify not just the successor's core but that **migrated state
   conforms to the successor's types** — a typed `code_change`.
2. **Succession-initiation must itself be a linear capability, never ambient**
   ([[permission-model]]).

## Why this resolves it

The line is drawn at the provable boundary, not at an arbitrary altitude: the
trusted core is exactly what cannot be certified from inside (it is what *does* the
certifying), and everything else is reflectable because it is re-checked. Soundness
picks the height, not taste — which is why the live-environment can metaprogram
freely right up to the judgment and no further. Dynamism is preserved as succession,
so the forcing workload is not amputated; it is only denied the one operation
(in-place judgment mutation) that has no coherent meaning.

## Gates and residues

Gates **E45** (the `Sig`-freeze / immutability mechanism) and **E58**
(reflect-typed staging). Residues, honestly named: **state handover across relaunch**
rides edge 14 (the move-only port semantics); **staging economics** (the cutover
window's real cost) is unmeasured. See `.planning/SELF-HOST-PLAN.md`.

## Principle basis

P1 — the kernel is expressible but not reconfigurable-from-within; this note is the
second clause made precise. P5 — the invariant (an immutable judgment) is pushed
into the substrate (a frozen `Sig`), not policed by a runtime check that could
itself be reconfigured. The succession wall is [[certificate-discipline]]: the
successor is untrusted until its core is re-checked against the spec.

## What this does not decide

The concrete state-migration protocol across a relaunch (rides edge 14). The
staging economics / cutover-window cost model (unmeasured). The `kernel-spec`
artifact's own size budget — that is E52/E72, and it is a *security* constraint
(the spec is the succession boundary, [[decision-deployment-custody]] worry #1),
not settled here.
