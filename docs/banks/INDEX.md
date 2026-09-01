---
node: banks/INDEX
layer: bank
tier: depth
related: [module-map, glossary, vocabulary, index, status-ledger]
updated: 2026-08-23
---

# Banks — the depth tier

Banks hold the full **refraction** of one chirality concept each: a thing that is ONE
feature in a conventional language is, here, a **sum of shards**, each in its own
principled home, usually mostly already built. Banks are the depth tier under the
thin relational org-roam notes in `docs/`; thin notes link *into* them.

**Before telling anyone "chirality needs X,"** read X's bank: the feature you are
reaching for is almost always already refracted across homes you have not
connected. Naming a phantom feature is the cardinal working error here — the banks
exist to end it.

## The banks

| Bank | Concept | The monolith it refracts |
|---|---|---|
| [[banks/module]] | a typed process the two laws cut and connect | file / package / class / namespace / compilation unit |
| [[banks/profile]] | a named set of modules over a frozen port set | build config / feature flags / dependency manifest / DI container |
| [[banks/runtime]] | a process at system scale, changing as configured | the RTS / VM / "the interpreter" |
| [[banks/capability]] | a port held; authority = the ports you hold | OS capability / fd / ocap object / ACL entry |
| [[banks/port]] | a typed crossing in a process's membrane | fd / socket / syscall / FFI binding / API |
| [[banks/effect-and-alarm]] | the effect membrane, alarm, and counter-effect as one algebra | exceptions / try-catch / algebraic effects / Result |
| [[banks/memory]] | space as a port; disciplines as profile choices | malloc/free / GC / ownership / the heap |
| [[banks/evidence-and-split]] | category C: cross-checked truth where proof runs out | try/catch validation / trust store / attestation / N-version |
| [[banks/verification]] | layered independent instruments, each blind above its own branch point, ranked by expectation provenance | "the test suite" / CI + coverage % / the self-host fixpoint / golden tests |
| [[banks/text]] | a payload, a way to name a part of it, and total functions between those | the regex engine / the string library / the Unix text tools / the editor buffer |

## The schema

Every bank follows six sections: **1** the concept in chirality (IS / IS-NOT; the
monoliths it's confused with) · **2** the refraction (each shard → its principled
home → build-state, authoritative from `.planning/audit/CONFORMANCE-MAP.md`) · **3**
cross-cuts (where a shard *is* another concept's shard — the highest-value part) ·
**4** native→chirality translation (the misfire → the correction) · **5** genuinely
new / unbuilt residue (tied to E# / DECISION, gradients preserved) · **6**
relational anchors (the thin notes that link in).

To add a bank: follow the schema, ground every build-state claim in the conformance
map, hunt the cross-cuts, and never name a phantom feature. `ledger-lint` checks
that every bank is listed here and carries sections 1/3/6.
