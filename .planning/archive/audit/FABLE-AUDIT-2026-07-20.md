> **ARCHIVED 2026-09-01. Superseded by `.planning/audit/FABLE-AUDIT-DISPOSITIONS.md`, which is the disposition log for it and stays.** Every Track-A finding is fixed in the tree; Track B is the only residue and the dispositions file is where it is tracked.

# External audit — Fable 5, 2026-07-20/21

Adversarial-but-fair audit of the chirality design corpus against its implementation
state. Mandate: preserve gradients, do not collapse them. Findings lead with the
gradient or coupling a claim hides, then the evidence. Ranked most-consequential
first. Where I am uncertain I say so and say what would resolve it.

Verification baseline: I ran the full scaffold suite during this audit —
**281 tests, all green** (`python3 -m unittest discover -s tests`, 2026-07-21).
Memory/planning notes citing 262 are behind the tree in the good direction.

---

## 1. What I read

**Read in full:** `README.md`, `CONTENTS.md`, `PRINCIPLES.md`, `docs/index.md`,
`docs/glossary.md`, `docs/status-ledger.md`, `docs/open-edges.md`, all eight
`docs/decision-*.md`, `docs/certificate-discipline.md`, `docs/split-role.md`,
`docs/totality.md`, `docs/trust-boundary.md`, `docs/floor-agreement.md`,
`docs/permission-model.md`, `docs/modules-security.md`, `docs/memory-model.md`
(status sections), `.planning/SELF-IMPLEMENT-CATALOG.md`, `.planning/ROADMAP.md`,
`.planning/ASSESSMENT-selfhost-cockpit.md`, `.planning/audit/AUDIT-MAP.md`,
`scaffold/AUDIT.md`, `scaffold/README.md` (module/profile/orchestration
sections), `examples/INDEX.md`, `CLAUDE.md`.

**Code spot-checks against claims:** `kernel.py` (conv/subtype/infer, universe
rule, seam dispatch), `effects.py` (whole), `bridge.py` (whole), `refine.py`
(constraint model, `_atom`), `data.py` (`check_termination` entry),
`impl_ports.py` (secret bindings, http), `lib/ports.chiral`, `lib/secret.chiral`.
Plus the test run above.

**/kb consulted:** directory survey of `/kb/patterns` and `/kb/systems`;
verified that `docs/memory-model.md`'s two /kb citations exist
(`/kb/systems/memory-hygiene-bhumi.md`, `/kb/patterns/bhumi-key-lifecycle.md`);
read the head of `/kb/patterns/adversarial-audit-loop.md` (the distillation of
the checker-reversal arc — relevant because this audit is an instance of it).

**Deliberately skipped:** the seven family dossiers in full (~370KB — their
cross-cutting content is synthesized in `AUDIT-MAP.md`, which I read, and I
spot-checked its defect-ledger claims against code where load-bearing);
`GIANTDUMP/` (raw provenance, already adjudicated by `dump-integration`); the
`view-*` and `insp-*` notes (self-declared derivative: "the notes win on
conflict"); the bodies of the worked examples other than the INDEX (pre-runs,
not claims); the three sibling-project `.planning/` trees (stale per the repo's
own editing note); `docs/definitions/secure-datum-model.md` beyond orientation (it is a target
threat model, and `trust-boundary.md` already concedes the full distance to it,
so auditing it against code would re-derive a conceded gap).

---

## 2. Findings, ranked by severity

### F1. The realization gradient runs inverse to the novelty gradient — and all backflow so far has come from the conventional end

**The claim/location:** the corpus presents category C ("the novel core," where
"the design spends its originality" — `decision-bridge-elaborator.md`,
`category-bridge`) alongside a scaffold that the docs treat as evidence the
architecture works ("structured after the module architecture, not
implementation convenience," `CONTENTS.md`; every stage note cites scaffold
miniatures as "evidence for the shape").

**The gradient it hides:** what is ENFORCED is precisely the *least* novel
territory — QTT 0/1/ω counting, strict positivity, a tal re-check, all
well-trodden prior art — while every identity-bearing novel claim sits at
DESIGNED or a thin SEEDED slice: the C evidence disciplines (attestation,
freshness-verify, audit-reconcile, custody-split: no code beyond `secret.chiral`
and 88 lines of `bridge.py` dynamic tag-checking), the effect algebra (one
boolean at three judgment points, `effects.py`, 46 lines), the cost/coeffect
semiring (kernel still 0/1/ω), Adhikara, grants/revocation (Move only),
information-flow/taint/constant-time (zero lines). P2 ("the type is the whole
cost") and P3's own core caveat ("time and space are ports") have **no
mechanism anywhere in the tree** — not even a reserved field in the Pi type;
the graded-kernel decision reserved the seat on paper only.

The consequence is not merely "unbuilt" (the status ledger says that honestly).
It is that **the design has never been stress-tested where it is novel**. Every
piece of backflow the ROADMAP records — linear kinds, erased-effects, floor
agreement, Euclidean division, the do-sugar — came from building the
*conventional* parts. The novel layer has accreted five substantial design docs
(split-role, certificate-discipline, bridge-elaborator, permission-model,
modules-custody) with zero equivalent backflow pressure. If the scaffold arc
demonstrates anything, it is that contact with running code *reverses settled
positions* (see the split-checker reversal); the layer most likely to be wrong
is the layer that has had no such contact.

**Evidence:** `docs/status-ledger.md` DESIGNED list; `effects.py` (whole file);
`kernel.py` (no grade beyond 0/1/ω); grep for cost/time/space grades: absent.
**Confidence:** high on the facts; medium-high on the inference (it is possible
the novel layer is more robust than average — but the project's own history
argues otherwise).

### F2. The newest trust-central decision has no downstream implementation hooks: the catalog predates the split-checker reversal and contains no certificate machinery

**The claim/location:** `decision-split-checker.md` commits the trust story to
kernel-spec + kernel-core + untrusted certificate-emitting producers, and calls
the move from today's agreement-tier to certificate-tier "a tier climb, taken
element by element as resources allow."

**The gap:** the artifact that actually drives implementation —
`.planning/SELF-IMPLEMENT-CATALOG.md` (E1–E52, dated 2026-07-06) — predates the
decision (2026-07-20/21) and contains **no element for any of it**: no
kernel-spec authoring, no certificate format, no proof-object representation,
no proof-producing elaboration, no tiny proof-checkers, no DDC build step. I
grepped: `certificate`/`proof object` do not appear in the catalog;
`kernel-spec` exists only as a `module-map.md` row. So "element by element"
currently names a climb with no ladder: the pre-run pipeline
(worked-example → implement) cannot even be pointed at the tier climb, because
the tier climb has no E-numbers. Meanwhile the decision doc leans on the claim
that certificate discipline is "already used in `preserve-check`" — see F5 for
why that is an over-collapse.

**Evidence:** grep of `.planning/` for `kernel-spec|certificate|proof object`
(only `module-map.md` and the decision/discipline docs hit);
`SELF-IMPLEMENT-CATALOG.md` element list.
**Confidence:** high. **Resolution:** either add E-elements (spec authoring,
certificate format, proof-checker, DDC) or state in the decision that the climb
is deferred past self-hosting — right now the decision implies near-term
element-wise motion that nothing downstream can execute.

### F3. The status ledger — "the status source of truth" — is itself nine days stale and now under-reports in both directions

**The claim/location:** `docs/status-ledger.md` (updated 2026-07-06): "This
ledger is the status source of truth… a claim that silently stays DESIGNED
while its note reads as shipped is the exact failure this ledger exists to
prevent."

**The gap:** since 2026-07-06 the tree gained: E40 secret custody
(`lib/secret.chiral`, host bindings, `test_secret.py`, `demo/passman-min.chiral`,
2026-07-15 — the first running slice of `modules-custody`, which the ledger
still lists wholesale under "DESIGNED — docs only, no code": "custody-split /
redundancy / datum-policy (all of [[modules-custody]])"); the entire
orchestration substrate (json/http+SSE/backend/fsm/manas/coordinator, proven
live per `ASSESSMENT-selfhost-cockpit.md`); mmap/munmap sys crossings and the
completed E21 arena; and the suite grew 191 → 281. None of it is on the ledger.
A reader using the ledger as directed now gets a *false negative* on custody —
the mirror image of the failure it names. The deeper coupling this exposes: the
ledger is maintained by discipline, not by mechanism, in a project whose
principle 4/5 is "push invariants into the substrate." Nothing fails when the
ledger rots.

**Evidence:** file dates (`secret.chiral` 2026-07-15 vs ledger 2026-07-06);
ledger DESIGNED list vs `lib/secret.chiral` + `tests/test_secret.py`;
`examples/INDEX.md` marks E40 `implemented`.
**Confidence:** high.

### F4. Post-condensation principle citations are ambiguous tokens, and same-day docs mix the two numbering schemes within one file

**The claim/location:** `PRINCIPLES.md` (condensed seven→five, 2026-07-20):
"The crosswalk at the end preserves existing P-number citations across the base
until a sweep renumbers them."

**The gap:** the crosswalk only disambiguates P6/P7, which exist solely in the
old scheme. **P3, P4, and P5 are valid tokens in both schemes with different
meanings** (old-P4 = inert interior → new-3; old-P5 = safe-path-cheap → new-4;
new-P5 = split/tier), and a citation does not say which scheme it uses. This is
not hypothetical: `split-role.md` (updated 2026-07-21, *after* the
condensation) uses **both schemes in one document** — line 36 "(P3, P4,
[[node-architecture]])" for ports+inert-interior is old numbering; line 86
"(P4: the safe path is the cheap path)" is new numbering; line 16 cites tiering
as "P7" (old) while `decision-split-checker.md`:119 and
`certificate-discipline.md`:60 — same-day docs — cite tiering as "P5" (new).
Two documents written the same day cite the same principle under two different
numbers, and a third mixes schemes internally. For the project whose reader-side
keystone is regularity ("make the language behave as it looks"), the principle
citations no longer behave as they look, and the crosswalk cannot repair them
because the ambiguity is in the token, not the mapping.

**Evidence:** quoted lines above, verified by grep.
**Confidence:** high. **Fix shape:** cheap — either sweep now, or adopt an
unambiguous interim convention (e.g. cite new numbers as N1–N5) until the sweep.

### F5. "Certificate discipline is already used in preserve-check" upgrades a same-trust-domain re-check into the LCF architecture

**The claim/location:** `certificate-discipline.md`: the pattern is "chirality's
house pattern, already used in `preserve-check`."

**The gradient it hides:** preserve-check is `lower.py` handing its own output
to `tal.py`'s checker — *both trusted, same package, same process, same
authors*. There is no untrusted producer, no portable proof object, no fixed
demanded statement at a socket, no independence between producer and checker
beyond a Python module boundary. It is re-derivation, which is genuinely the
germ of the discipline — but the load-bearing properties of LCF/de Bruijn
(trust concentrated in a *small frozen* core while *untrusted* bulk churns;
certificates as artifacts that cross a trust boundary) are exactly the parts
preserve-check does not exhibit. The distance between "the compiler re-checks
its own output" and "kernel-core re-checks certificates from untrusted
elaborators and proof-producing SMT" is precisely the unbuilt hard part (F2).
Calling the pattern "already used" makes the trust story sound bootstrapped
when only its cheapest half exists.

**Evidence:** `lower.py`/`tal.py` structure; no certificate/proof-object
representation anywhere in `scaffold/`.
**Confidence:** high.

### F6. The velocity claim inside the trust decision does rhetorical work its own hedge disclaims

**The claim/location:** `decision-split-checker.md`:96–103: the "years of work"
prior for machine-verifying a checker "is the wrong prior for this project:
roughly 85% of the chirality-related code… was built in about two days of
agent-orchestrated work, so estimate at that throughput."

**The gap:** the hedge that follows ("machine-checked *verification* is a
distinct activity… the velocity does not transfer automatically; no replacement
number is claimed") is correct — but the paragraph's argumentative direction is
set by the unhedged figure, inside a *trust* document. Two problems: (a) 85% is
unsourced (no measurement artifact anywhere in `.planning/`); (b) build
throughput and verification throughput differ by the thing that makes
verification verification — CakeML/seL4 pace was set by proof engineering, not
typing speed, and no evidence exists that agent orchestration compresses proof
engineering at the same ratio. The honest form of this paragraph is "the
conventional prior may be wrong; we have no estimate" — which is what the last
clause says, after the preceding clauses have implanted the two-day anchor. The
same anchor recurs in `ASSESSMENT-selfhost-cockpit.md` §1.4 as "load-bearing
for scope."

**Evidence:** quoted text; absence of any throughput measurement or
verification-effort estimate in `.planning/`.
**Confidence:** high on the text; the risk it creates is scope-setting, not
soundness.

### F7. "The model interface is ALREADY chirality and proven live" — true above the extern line, and the verdict line erases the line

**The claim/location:** `ASSESSMENT-selfhost-cockpit.md` §1.1 and §3a: "The
model interface is ALREADY chirality and proven live… `ports.chiral` — a real
socket floor."

**The gradient it hides:** everything below the extern seam is CPython:
`http-request` is urllib, sockets are the Python `socket` module, `poll2` is
`select` (`impl_ports.py`). The genuinely self-hosted syscall floor
(`lib/sys-tal.chiral`) is *not connected* to any of it — the project's own audit
synthesis is blunt: "today NOTHING in chirality-land can call the sys crossings
except tests" (`AUDIT-MAP.md`, E51). The assessment does state this two
sections later (§3c lists `impl_ports` as crutch; Phase S1 retires it), so the
document as a whole carries the gradient — but its TL;DR verdicts, which are
what a cold reader (its declared audience) takes away, flatten "chirality logic
over a Python transport" into "already chirality." "A real socket floor" is a typed
*face*; the floor is Python.

**Evidence:** `impl_ports.py` (urllib, socket, select); `AUDIT-MAP.md` E51
finding; `lib/ports.chiral` externs.
**Confidence:** high.

### F8. The alarm/effect design is "resolved in direction" while its only realization is the exact anti-pattern the design names

**The claim/location:** `docs/open-edges.md` G6: "resolved in direction: an
alarm is a typed effect… raised in the port and effect algebra, named in the
type and total, and it is rich because everything is split, so it carries what
diverged from what."

**The gap:** there is no effect algebra (edge 16 open, `effects.py` is one
bit), and every live alarm in the scaffold is a **Python exception**
(`alarms.py`, 24 lines: MetisExit/Halt/PortError) — which the project's own
catalog names as the crutch to shed: E26 "Alarms / control flow
(exceptions-as-control-flow is a crutch)." "Resolved in direction" is a fair
status for a design settlement, but the note's present-tense richness ("it is
rich because everything is split") describes a mechanism whose sole realization
contradicts its stated shape, and — coupling to F1 — nothing built exercises
whether alarms-as-typed-effects composes with linearity, totality, and the
membrane. Edge 16 is listed as one open mechanism choice; it is closer to the
keystone the error model, the counter-effects, partiality-as-effect
(graded-kernel item 2), and E26/E39 all hang on.

**Evidence:** `alarms.py`; `effects.py`; catalog E26/E39.
**Confidence:** high on facts; medium on how much composition risk hides there.

### F9. MAP's "verifying every value a binding returns" overstates the bridge's depth-4, tag-level check

**The claim/location:** `CONTENTS.md`: "the bridge connector's inbound face
verifying every value a binding returns."

**The gap:** `bridge.py` verifies runtime *tags* and arities, recurses only to
depth 4 ("bounded: evidence at the crossing, not a deep proof"), silently
passes neutral/polymorphic results and any TCon without a decl, and checks the
Pool index only when concrete. The ledger states the bound honestly
("dynamic, depth-bounded ≤4; outbound confinement not built"); MAP does not.
Small, but it is exactly the claim-vs-mechanism gap the project polices, on the
front-page document.

**Evidence:** `bridge.py`:70–78 (`depth < 4`), `_ATOM_TAG` shallow checks;
`status-ledger.md` row.
**Confidence:** high.

### F10. E40 "implemented" carries no tier: what runs is exit-discipline custody, not memory custody

**The claim/location:** `examples/INDEX.md` marks E40 `implemented`;
`lib/secret.chiral` is the artifact.

**The gradient:** what is implemented is the *type-level* discipline (opaque
linear atom, single greppable exit — genuinely elegant, see §4). What is not:
the plaintext handed to `secret-seal` persists wherever the caller materialized
it (Python immutable `bytes`); `secret-reveal` zeroes the internal bytearray
but returns a fresh immutable `bytes` that can never be zeroed; CPython
copies/interns freely. The `.chiral` comments are honest about scope, and
PRINCIPLES P5 names zeroing-down-to-the-floor as unfinished — but a one-word
status (`implemented`) in the INDEX flattens a three-tier reality (type
discipline: yes; host-copy hygiene: partial; memory custody: no). This is the
per-claim tier-naming that `split-role.md` itself prescribes, not applied to
the project's own first custody artifact.

**Evidence:** `impl_ports.py`:239–266; `lib/secret.chiral` honest-limit comment.
**Confidence:** high.

---

## 3. Contradictions & drift

**C1. The backend fork is simultaneously settled, diverged, and open — three
docs, three states.** `decision-backend.md` (status: *settled*) prescribes
"use LLVM or Cranelift as a codegen library." The build uses neither
(hand-emitted x86-64 from chirality, `native.py` + `lib/mach-x64.chiral`), which the
decision's own Note and the status ledger flag as "unreconciled." And
`open-edges.md`'s sequencing list still says "First backend choice among LLVM,
Cranelift, QBE. **Open**." A settled decision whose mechanism the build
contradicts, held open elsewhere, should be re-settled or re-opened — the
built path is arguably *more* aligned with the decision's principle (no untyped
bottom, own the erasure step) than the decision's named mechanism, which makes
leaving it unreconciled stranger.

**C2. The front door is five weeks behind the house.** `README.md` (Jun 16):
"Status: Principles drafted… Next work is resolving those edges" — no
scaffold, no tests, no self-host arc; it does not know the project has running
code. `CONTENTS.md` (touched 2026-07-20 for the principles crosswalk) still says
"Four forks settled" (there are at least six decision notes plus two drafts)
and "ten unresolved seams" (open-edges enumerates twenty plus three sequencing
questions). `CLAUDE.md` says "elements E1–E36" and "24 of ~33 elements" against
a 52-element catalog with 26 INDEX rows. Each individually trivial; together
the orientation spine — the exact path `CONTENTS.md` tells a new reader to walk —
tells a materially out-of-date story, in a project that built a status ledger
precisely so docs would not do this.

**C3. Ledger vs tree on custody** — F3 above (DESIGNED row falsified in the
good direction by `secret.chiral`).

**C4. Principle-numbering schemes coexist in same-day documents** — F4 above.

**C5. Comment rot at the seam the docs celebrate.** `lib/ports.chiral` still
says "Offsets within the bound remain a runtime check until refinement types
land (open edge 3)" — but `mem-put-checked` landed 2026-07-06 and `AUDIT.md` F8
records offsets as a compile-time obligation. Similarly `scaffold/README.md`'s
module table describes `refine.py` as "I64 constant-bound fragment, sound and
complete" — pre-symbolic; the symbolic slice (sound, incomplete) is absent.
Both are the docs-lag-code direction of C2.

**C6. Design-vs-principles drift: the honesty apparatus is discipline, not
substrate.** PRINCIPLES 4/5 and the user's own operating principles say push
invariants into the substrate rather than across a runtime seam. The project's
*documentation* invariants — ledger currency, principle citations, status
banners, MAP counts — are all maintained by hand and are the audit's richest
source of drift (F3, F4, C1, C2, C5). Nothing structural fails when they rot.
This is not hypocrisy (docs are not code), but it is the same failure shape the
language exists to eliminate, reproduced one level up, and partially
mechanizable (a lint that cross-checks ledger rows against file existence,
counts edges, and rejects ambiguous P-citations would catch most of the above).

---

## 4. What is genuinely solid

Named specifically, because the credibility of §2 depends on it.

- **The honesty apparatus as a genre.** `trust-boundary.md`'s one-liner —
  "While chirality runs on CPython, its security properties are compile-time
  discipline, not runtime enforcement" — is exactly the sentence most projects
  never write. `status-ledger.md`'s four rungs, `floor-agreement.md`'s "by
  construction where floors collapse, by test everywhere else," and the "honest
  limit" sections threaded through PRINCIPLES are structurally correct
  self-description. My findings about the apparatus (F3, C2) are that it decays,
  not that it lies by design.
- **The kernel's seam architecture is real in code, not just described.**
  `kernel.py` genuinely does not know constructors, effects, ports, or
  refinements: `EXT_TERMS` dispatch, `sig.rules`, `def_hooks`, `narrow_hooks`,
  `check/subtype/conv/quote_hooks` are all live, and `data.py`/`effects.py`/
  `refine.py` really do install through them. Universes are predicative with
  cumulativity (`('Type', l) : Type l+1`; `subtype` does `l ≤ l'`) — no
  type-in-type hole. ~600 lines, small as claimed.
- **The linear-kind discipline (AUDIT F2) closes a real hole correctly.**
  `Rules.on_binder` judged at Pi formation, let, constructor fields, *and* at
  application on the instantiated parameter (`on_apply`) — the polymorphic
  smuggle is genuinely closed, and the fix is in the type (linearity derived
  from fields) rather than patched at binders, exactly as `decision-b-in-type`
  demands.
- **Floor agreement is a first-class original contribution of the process.**
  The division bug (three executors, one type, three values) was found,
  root-caused as a *missing invariant class* rather than a bug, fixed by
  collapse (fold imports the reference's arithmetic — one definition cannot
  disagree with itself), and pinned to SMT-LIB semantics so refinement proofs
  mean at runtime what they proved. This is the strongest evidence in the repo
  that the build process converts contact into design.
- **The termination checker's soundness conditions are the ones naive
  implementations miss:** the wraparound exclusion (`hi ≤ MAX−k`) that defeats
  the vacuous `i ≤ MAX` "proof," and the ±1-step / bound-invariance conditions
  on the symbolic measure. The blind spots (higher-order use, forward declares,
  mutual, lexicographic) are enumerated, not elided. Classify-then-enforce with
  a per-def reason ledger and a profile `(total)` gate is the right shape.
- **The split-checker reversal itself.** A settled decision was reversed under
  adversarial pressure, the false inference step is named in the corrected doc
  ("cannot prove *itself* silently upgraded to cannot *be* proven"), and the
  method was distilled into `/kb/patterns/adversarial-audit-loop.md`. Systems
  that can do this once can do it again; several findings above are candidates.
- **The inspiration policy's Tier O (oracle-only)** — run Z3/Agda/Idris as
  behavioral oracles, never read their source — is a genuinely good move:
  mature-tool correctness leverage with zero provenance cost, and it makes the
  clean-room claim about the checker checkable rather than asserted.
- **The defect ledger practice.** D2–D7 fixed with tests (I verified the suite);
  D1 correctly scoped as a port-time rule — and my read of `refine.py`'s
  `_atom` confirms the scoping: Python bignums make `k±1` non-wrapping today,
  so it is genuinely a future-port hazard, not a live bug.
- **281 tests green, verified by execution during this audit.**

---

## 5. Open questions for the author

Phrased as gradients; these are the calls only you can make.

1. **Where on the novelty axis do the next increments land?** The self-host
   port (checker in chirality) climbs further up the well-understood end; the C
   layer (effect algebra, one real evidence bridge, grants beyond Move) has had
   zero contact-with-code and five docs of accretion (F1). How much more design
   should the novel layer accrue before one of its elements is forced through
   the same contact that reversed the checker decision — and which element is
   the cheapest forcing function (edge 16's algebra? E51 linkage? a real
   attestation bridge)?
2. **What is the tier-climb's first rung, concretely?** Between "agreement is
   the trust story today" and "machine-verified kernel-core" lies a spectrum:
   author kernel-spec as an artifact; define a certificate format; make one
   producer (the optimizer is closest) emit a re-checkable derivation across a
   real trust boundary; DDC the build. Which rung is worth buying before
   self-hosting, and which after? (Right now none has an E-number — F2.)
3. **How current must the honesty apparatus be to stay honest?** The ledger
   decayed in nine days of fast building (F3). The gradient runs from
   "update-on-touch discipline" through "definition-of-done checklist item" to
   "mechanized lint over ledger rows, edge counts, and P-citations." How much
   of it should become substrate, given the project's own principle that
   discipline-held invariants rot?
4. **Which numbering is normative during the crosswalk window** (F4), and does
   the sweep happen before or after the next wave of trust-layer docs — the
   docs currently most affected?
5. **Is the backend fork settled by the build or reopened by it?** (C1). The
   hand-emitted path is running evidence; the decision text names a mechanism
   the build rejected. Re-settling it would also decide whether LLVM/Cranelift
   ever enter the TCB story at all — which is a trust question, not just a
   tooling one.
6. **What does "proven live" require before the assessment's verdict lines say
   "already chirality"** (F7) — is the bar "chirality logic over any transport," or
   "no `impl_ports` in the path," and should the TL;DR carry the tier the way
   split-role prescribes for every other held truth?

---

*Audit method note: read-only except this file; all quoted lines verified
against the tree; test suite executed once (281 green). Where I inferred beyond
evidence (F1's stress-test inference, F8's composition risk) I said so inline.*
