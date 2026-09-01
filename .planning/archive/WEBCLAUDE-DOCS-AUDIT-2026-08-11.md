> **ARCHIVED 2026-09-01. Superseded by `.planning/DOC-AUDIT-QUEUE.md` and `.planning/AI-RESIDENT-AND-CAPABILITY-RUNG.md`.** ⚑ **Its verdict INVERTED and the inversion is the point.** The erased-positions finding flipped when the Python oracle was evicted, so its recommendation (fold the erased-witness pattern into `docs/banks/capability.md`) rested on enforcement that no longer exists and would have to be re-derived before it is acted on.

# WEBCLAUDE-DOCS-AUDIT — reconciling two external-Claude docs against live state (2026-08-11)

Read-only audit. Two docs were written by an external "web-Claude" from a
point-in-time snapshot with no chirality skills and no current tree. This report sorts
every substantive claim into: genuine outside-view insight, **staleness** (snapshot
predates T1–T5 progress), or **chirality-model error**. Verdicts cite live `file:line`.
Neither target doc nor any other file was edited.

**Reality baseline reconciled against (snapshot is BEHIND this):** T1 built (fat
driver `nb-spawn-in-pty-t` + 3 crossings, B1 refixpointed 827768B, sample exit 42),
T2 built, T3 built (795000B fixpoint), T4 built + conformance test passing, T5
specced/audited (`TUI/examples/INDEX.md:9–13`). Primitive audit done
(`TUI/PRIMITIVE-AUDIT.md`): open NEEDs = linear-cap collection for mux + UTF-8
decoder; bitwise `band/bor/bxor/shl` ARE surfaced. Self-hosting achieved 2026-08-05,
703 tests green 2026-08-10 (`README.md:48–54`).

---

## Executive verdict — TARGET 1 `DOC-DEBT-2026-08-11.md`

1. **Safe to act on, with one correction.** 10 of 12 items are CONFIRMED real
   doc-debt with accurate citations; web-Claude's own fixes are sound and its chirality
   model (rung split, syscall governance, QTT erasure) is correct throughout — no
   CHIRALITY-WRONG items here.
2. **One STALE-CLAIM: item 5.** Its evidence (T1/T2 sys-tal edit collision, "T1
   paused", "blob red pending bisect") is overtaken — T1–T4 are all built and
   fixpointed (`TUI/examples/INDEX.md:9–12`); the doc-line it targets still exists
   but the urgency is gone.
3. **Three items are contingent on unsettled design** (3, 8, 10 lean on the
   erased-witness / plural-unlock-position models that are themselves NEEDS-AUTHOR,
   not settled) — real debt, but don't write the contingent half as fact.

## TARGET 1 — item-by-item

| # | Note | web-Claude verdict | MY verdict (bucket) | note (file:line) |
|---|---|---|---|---|
| 1 | `.planning/ROADMAP.md` | STALE/high | **CONFIRMED** | Roadmap stage 9 still "in progress", inline block still "E1–E75, 44 examples, 281 tests" (`ROADMAP.md:169–176`); README records self-hosting 2026-08-05 + 703 tests (`README.md:48–54`); catalog now runs to E105 (`SELF-IMPLEMENT-CATALOG.md:345`). Fix correct. Structural sub-item (no roadmap seat for the TUI/T-series arc) also real — grep for TUI/T1/userland in ROADMAP returns nothing → **NEEDS-AUTHOR**. |
| 2 | `.planning/SYSCALL-WIRING.md` | STALE/high | **CONFIRMED** | File still says floor is "OPEN … separate, unbuilt, author-scoped work" (`SYSCALL-WIRING.md:15–21`) and "12 crossings" (`:10`), but `decision-syscall-governance.md:5` is `status: settled` with E76/E77/E78, and E76 slice 1 is BUILT (`SELF-IMPLEMENT-CATALOG.md:205`). web-Claude's replacement layer-table + "build-time not runtime property; E77 converts to OS-enforced" is accurate to the governance doc (`decision-syscall-governance.md:65–66`; E77 `SELF-IMPLEMENT-CATALOG.md:206`). |
| 3 | `docs/open-edges.md` edge 2 | OWED/high | **CONFIRMED (doc gap); REFINE (urgency)** | ROADMAP backflow does say the rule ("erased (0) positions must be effect-free or 0 is not erasure; the membrane question of edge 2 has to say this explicitly", `ROADMAP.md:221–223`) and edge 2 omits it (`open-edges.md:49`). Real OWED. BUT its "blocks a design" urgency is conditioned on adopting the erased-witness reflection pattern — itself a NEEDS-AUTHOR design (TARGET 2). Fix the doc gap; don't inherit the urgency as settled. |
| 4 | `docs/bootstrap-sequence.md` | PREDATES/high | **CONFIRMED (staleness); NEEDS-AUTHOR (plural-position)** | Note is `updated: 2026-06-16` (`bootstrap-sequence.md:7`) and describes a single TRESOR master secret (`:24–26`), predating the rung ladder + custody/governance/rung-2 decisions. Bring-current fix is right. The "N unlock positions" model it contrasts against is not itself settled — deployment-custody has tier-based "software key levels" (`decision-deployment-custody.md:61`), so the plural-position design is an OPEN item to state, exactly as the doc frames it. |
| 5 | `TUI/examples/INDEX.md` + `CATALOG.md` | TRACKER/med | **STALE-CLAIM** | INDEX still literally says "elements are independent — safe to run in parallel" (`TUI/examples/INDEX.md:29–30`), but the cited proof (T1/T2 collision, T1 paused, blob red, T3 three-way) is resolved: T1–T4 all `built` and fixpointed (`TUI/examples/INDEX.md:9–12`). The "false at exactly the wave being executed" is no longer true — that wave shipped. Fix ("independent unless they share a file") is a fine minor clarification but no longer debt-of-consequence. |
| 6 | `docs/permission-model.md` | PREDATES/med | **CONFIRMED** | Banner `updated: 2026-07-23` (`permission-model.md:7`); governance settled 5 days later names E78 as "the capability discipline ([[permission-model]]) reaching the raw floor" (`SELF-IMPLEMENT-CATALOG.md:207`). Missing backlink + E76/77/78 worked-instance + E80 dependency are all real. Fix correct. |
| 7 | `TUI/docs/TERMINAL-PORT-DESIGN.md` | NEW/med | **CONFIRMED (E80 cite); NOVEL-USEFUL (freshness)** | §1 refers to "when profile-hands-caps lands" without the number (`TERMINAL-PORT-DESIGN.md:74`) — that is E80 (audited, unimplemented); cite it. The §8 "freshness" gap (typing gives faithful-to-a-graph, never to the *current* graph) is a genuine new observation worth recording as NEEDS-AUTHOR. |
| 8 | `docs/banks/capability.md` | NEW/med | **CONFIRMED (E80 cite); contingent (witness shard)** | Bank names remaining ambient externs `print`/`put`/`trace` as the target invariant (`capability.md:69–70`); adding E80 as the exit condition is correct debt. The "witness shard" addition is contingent on the erased-position rule being enforced (item 3) — adopt only as DESIGNED-conforming, not ENFORCED, exactly as the doc says. |
| 9 | `.planning/SELF-IMPLEMENT-CATALOG.md` | NEW/med | **NEEDS-AUTHOR** | Genuine gaps: no element for the install ceremony (nearest E43), the delegation-carrier choice (subtype vs E38 semiring vs E78), the catalog letter for the AI resident. All real, but all author-decisions (mint-vs-extend), not mechanical edits. Route as docket items, as the doc itself suggests. |
| 10 | `docs/decision-deployment-custody.md` | NEW amend/low | **CONFIRMED (as amendment); contingent** | Note is sound/settled; the plural-per-position tunability amendment (vs the singular tier line at `decision-deployment-custody.md:61`) is a reasonable house-style amendment — but it depends on the same unsettled plural-position model as item 4. State it as the open question, don't silently adopt. |
| 11 | `.planning/BUGS-AND-GAPS.md` | TRACKER/no-op | **CONFIRMED (no-op)** | Banner (`BUGS-AND-GAPS.md:3`, 2026-08-10) correctly records the pending reblob; catalog E105 confirms "pending batched reblob per BUGS-AND-GAPS" (`SELF-IMPLEMENT-CATALOG.md:345`). Correctly-filed live item; nothing to change. (Minor: T1's 827768B refixpoint suggests the batch is partly landing — recheck before commit.) |
| 12 | `docs/FRONTIER.md` | GENERATED/last | **CONFIRMED (procedure)** | Regenerate via `bin/chirality-frontier.py condense` after items touching its inputs (3/6/10) land; don't hand-edit. Sound. |

---

## Executive verdict — TARGET 2 `AI-RESIDENT-AND-CAPABILITY-RUNG.md`

1. **Safe to act on, with one correction.** Unusually well-grounded: its spine
   (reflector-not-proxy, capability-is-a-profile-not-a-system, unlock-position-vs-
   holder, inbound-verifies/outbound-confines) faithfully restates *settled* repo
   decisions, and it honestly flags its own NEW claims. **Zero hard CONTRADICTS.**
2. **One CHIRALITY-WRONG, load-bearing: §3.3.** It claims "erased (0) positions must be
   effect-free" is only an audit finding / design obligation, "NOT enforcement."
   It IS enforced today — `effects.py:40` `erased_allow` forces any q=0 position pure
   (returns `EMPTY_ROW`), corroborated `banks/effect-and-alarm.md:126`,
   `E69-E72-CHECKLIST.md:30`. So its own headline contribution is *less* blocked than
   it thinks.
3. Roughly ~60% faithful restatement, 1 stale/wrong load-bearing claim, ~4 genuine
   new insights, ~11 correctly-identified open decisions. The erased-witness
   reflection pattern is the valuable new contribution.

## TARGET 2 — section-by-section

| Claim / section | Bucket | Note (file:line) |
|---|---|---|
| 1 — scriba has no say in capability (reflector, not proxy/broker) | **CONSISTENT** | `permission-model.md:32–34` "no gate holds it and no owner adjudicates it"; `banks/capability.md:44–45`; `TERMINAL-PORT-DESIGN.md:124–128` "Identity IS a held capability"; `RUNG2-SECURITY-MODEL.md:18–22` |
| 2 — side-channel is "the weaker half"; input/authority is the crown | **CONSISTENT** | `TERMINAL-PORT-DESIGN.md:12–13` structured tier "mostly built"; §3 flagged load-bearing (`:119`); matches crown-jewel = writer-identity/trusted-display |
| 2b — `hole` as "a region a named cap-holder may fill" (write affordance) | **NOVEL-USEFUL** | Flagged NEW (`AI-RESIDENT:116`); TERMINAL-PORT-DESIGN §2 only says holes "stay addressable" (`:96`) |
| 2c — plural disposable per-consumer projections via `RendererFn` | **NOVEL-USEFUL** | Extends `decision-profiles`; `RendererFn` registry real (`TERMINAL-PORT-DESIGN.md:276`) |
| 3 — erased witness: display-authority as 0-quantity binding; disagreeing view fails to typecheck (mechanism) | **CONSISTENT / NOVEL-USEFUL** | QTT-0 erasure real (`glossary.md:76`; `E69-E72-CHECKLIST.md:30`); `decision-b-in-type`; E52 untrusted-producer reuse is a new application |
| 3b — §3.3: erased-positions-effect-free is "an audit finding, NOT enforcement" | **CHIRALITY-WRONG** | Enforced: `effects.py:40` `erased_allow` → `EMPTY_ROW` for q=0; `banks/effect-and-alarm.md:126`. Only the design-*statement* ratification (F1/edge 2 prose) is pending (`ROADMAP.md:222`) |
| 4 — user model = unlock-position vs holder (plural, heterogeneous methods) | **CONSISTENT** | `RUNG2-MICROVM-MAP.md:214–216` "'user' is exactly 'the holder of an unlock secret'"; §5.5 per-key unlock policy (`:190`); `RUNG2-SECURITY-MODEL.md:155–159`; `decision-deployment-custody.md:55–66` |
| 5 — crypto at membrane: inbound verifies / outbound confines | **CONSISTENT** | `permission-model.md:60–72` "Permission is agreement … the bridge"; doc cites `open-edges` G4 |
| 5b — nonce-uniqueness-as-quantity-1; key/context in erased fragment | **NOVEL-USEFUL** | Applies linearity + the §3 erasure move to AEAD; not in repo; buildable |
| 6 — "the capability rung is a profile, not a system" | **CONSISTENT** | `banks/capability.md:27–34` monolith-misfire warning verbatim; `RUNG2-SECURITY-MODEL.md:18–22` "composability is the sole invariant"; `decision-deployment-custody.md:18–20` "not a new subsystem" |
| 7 — §9 sequencing (TUI→AI→confidentiality/boot→cap shards→agreement) | **NEEDS-AUTHOR** | RUNG2 "Seated, not scheduled" (`RUNG2-SECURITY-MODEL.md:8`); no build order fixed. Doc self-labels "a proposal, not a plan" (`:25`) |
| 7b — crypto-as-agreement (downstream) vs crypto-as-confidentiality (boot precondition) | **CONSISTENT** | Agreement=bridge-verify downstream (`permission-model.md:60–72`); confidentiality=boot root (`RUNG2-MICROVM-MAP.md` P6 `:139`; `decision-deployment-custody.md:55–66`) |

**§10 NEEDS-AUTHOR list — is each genuinely open?**

| §10 | Item | Judgment (file:line) |
|---|---|---|
| 1 | Freshness (reserved region / linear token / discipline) | **OPEN** — sibling to `TERMINAL-PORT-DESIGN.md` §8.1; reserved region exists (`:180`), this variant is new |
| 2 | Witness shape (whole-`CapGraph` vs per-cap) | **OPEN** — novel construct, no prior |
| 3 | Erased-position rule "promote in docket?" | **MOSTLY SETTLED** — enforcement exists (`effects.py:40`); only doc-ratification F1 pending & already tracked (`SCAFFOLD-NEXT.md`). Not a new author call |
| 4 | Cap granularity (split read/write/geometry) | **OPEN** — already logged `TERMINAL-PORT-DESIGN.md` §8.3; Clock/Timer precedent `ports.chiral:89–96` |
| 5 | Delegation semantics (attenuation record, bounded re-delegation) | **OPEN** — E40/E61 designed-only, edge 7 `banks/capability.md:410–419` |
| 6 | Agent gets own catalog letter (T20+ / new series) | **OPEN** (trivial bookkeeping) — same gap as TARGET 1 item 9 |
| 7 | One master secret or N | **OPEN, real tension** — `bootstrap-sequence` single register root vs `RUNG2-MICROVM-MAP.md:190` "master key(s)" plural; map leans N. Same tension as TARGET 1 items 4/10 |
| 8 | Key-material reachability a conformance row? | **OPEN** — D4 supports join-is-whole-assembly (`permission-model.md:80`); whether `chirality verify` checks it is undecided |
| 9 | Naming two words for "user" | **OPEN-but-low** — repo already uses "holder of an unlock secret" (`RUNG2-MICROVM-MAP.md:215`); largely moot |
| 10 | Crypto boundary data direction | **OPEN** — genuine threat-model call |
| 11 | Delegation carrier: subtype narrowing vs E38 semiring | **OPEN, high-value** — both exist (Shard C subtype IMPLEMENTED-unwired `banks/capability.md:169–179`; E38 semiring designed); one answer covers Attenuate/Delegate/E78. **Same decision as TARGET 1 item 9's delegation-carrier point** |

**Per-bucket counts (TARGET 2):** CONSISTENT 7 · CONTRADICTS 0 · CHIRALITY-WRONG 1 ·
NOVEL-USEFUL 4 · NEEDS-AUTHOR 11 (§9 + §10 items 1,2,4,5,6,7,8,9,10,11; §10.3 excluded
as mostly-settled).

---

## What to actually do before the changes wave

**Act on (CONFIRMED doc-debt, mechanical-to-medium):**
- Item 1 — ROADMAP: stage 9 → done(rung 1, 2026-08-05), refresh inline block to
  E1–E105 / 703 tests / current example count, restate stages 3/5 as built. Plus the
  author call: give the T-series a roadmap seat (stage 10.5 or a declared peer spine).
- Item 2 — SYSCALL-WIRING: replace the "OPEN/author-scoped" caveat with the settled
  governance stack (E76 slice-1 BUILT / E77 / E78) + the honest "build-time not
  runtime" limit; refresh the crossing count.
- Item 3 — open-edges edge 2: add the erased-position (0-must-be-effect-free) rule as
  a named residual; add a status-ledger line. (Fix the gap; hold the urgency.)
- Item 4 — bootstrap-sequence: bring current (rung split, related-list, custody
  pointer, install-ceremony seam), stating the plural-position question as OPEN.
- Item 6 — permission-model: add `decision-syscall-governance` backlink + E76/77/78
  worked-instance paragraph + E80 dependency; refresh banner.
- Items 7/8 (the E80 citations) and 12 (regenerate FRONTIER last).

**Fold in (NOVEL-USEFUL):**
- The "freshness" observation (item 7): faithful-to-a-graph is typeable, faithful-to-
  the-*current*-graph is not — record as a NEEDS-AUTHOR sibling to the trusted-region
  question in TERMINAL-PORT-DESIGN §8.
- **The erased-witness reflection pattern** (TARGET 2 §3.1–3.2): display-authority as a
  0-quantity binding of the cap it reflects; scriba renders a `CapView` *indexed by* the
  erased cap-graph term, so a view disagreeing with its graph does not typecheck —
  fabrication is inexpressible, reusing E52's untrusted-producer/trusted-recheck
  discipline. Fold into `docs/banks/capability.md` (the "witness shard" of item 8) and
  answer permission-model's open "how do you *show* a graph nobody holds." Its erasure
  prerequisite is ALREADY enforced (`effects.py:40`), so it is more shovel-ready than
  the doc claims.
- Runner-ups: `hole`-as-cap-write-affordance; nonce-uniqueness-as-quantity-1 +
  key-in-erased-fragment for AEAD; plural disposable per-consumer `RendererFn`
  projections.

**Route as author-decisions, don't mechanically edit (NEEDS-AUTHOR):**
- Item 9 (install-ceremony element, delegation-carrier choice, AI-resident catalog
  letter); the plural-unlock-position model behind items 4/10; the erased-witness
  reflection pattern behind items 3/8.

**Discard / correct (STALE / do-not-act):**
- Item 5's collision evidence — the sys-tal wave shipped and fixpointed; drop the
  "blob red / T1 paused" framing, keep only the one-line "independent unless
  same-file" clarification if desired.
- **TARGET 2 §3.3's claim that "erased-positions-effect-free is NOT enforcement"**
  (CHIRALITY-WRONG). The rule is enforced today — `effects.py:40` `erased_allow` forces any
  q=0 position pure — corroborated `banks/effect-and-alarm.md:126`,
  `E69-E72-CHECKLIST.md:30`. Do NOT gate the erased-witness UI on "first close/enforce
  edge 2's erased-position rule"; that enforcement exists. Only the design-*statement*
  ratification (backflow F1 into edge 2's prose = TARGET 1 item 3) is outstanding, and
  it is already tracked. Building that blocker would be inventing work that isn't there.
- TARGET 2 §10.3 ("promote the erased-position rule in the docket?") — treat as
  mostly-settled for the same reason, not a fresh author decision.

**One caveat carried from the source doc:** it was assembled from a `.git`-excluded
snapshot, so "nobody fixed this yet" was never verifiable from it. This audit closes
that gap for TARGET 1 against the live working tree.
