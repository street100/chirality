# Fable audit — disposition log

Working record of the serious pass through `FABLE-AUDIT-2026-07-20.md`. Two tracks:
**truth-restoration** (mechanical drift; docs made to match the tree — done inline)
and **design gradients** (decisions only the author makes — worked one at a time,
in the loop). One row per finding; updated as each is closed.

Baseline verified at pass start (2026-07-21): full scaffold suite **281 green**
(`python3 -m unittest discover -s tests`, run from `scaffold/`).

## Track A — truth-restoration (mechanical)

| # | Finding | Disposition | Where |
|---|---|---|---|
| F3 | Status ledger 9 days stale; custody false-negative | **FIXED** | `docs/status-ledger.md`: date→07-21; custody→SEEDED w/ tier; added orchestration + sys-face/arena rows; sharpest-gap #1 corrected |
| F4 | P-citations ambiguous; split-role mixes schemes | **FIXED (broader than reported)** | `docs/split-role.md` swept; `PRINCIPLES.md` crosswalk convention added. The lint then caught **5 more post-condensation docs** Fable missed still citing P6/P7 (category-bridge, index¹, joining-law, node-architecture, open-edges) — all swept P6/P7→P5. ¹index.md was a false positive (meta-text naming the old range), now excluded in the lint. **Residual (accepted / flag):** the lint catches only P6/P7 (old-only tokens); old-P4 (inert→new P3) and old-P5 (safe→new P4) citations in pre-condensation docs are undetectable by token and would need a per-citation judgment sweep — not done. |
| F9 | CONTENTS overstates the depth-4 bridge check | **FIXED** | `CONTENTS.md`: "verifying every value" → tags/arities, depth-bounded, evidence-not-proof |
| F10 | E40 "implemented" hides three tiers | **FIXED** | `examples/INDEX.md`: status → "impl (type-level)" |
| C2 | Orientation spine (CONTENTS/README/CLAUDE) stale counts | **FIXED** | `CONTENTS.md` forks/edges/date; `README.md` Status; `CLAUDE.md` E1–E50, 25/50 |
| C5 | Comment rot at ports/refine seams | **FIXED** | `scaffold/lib/ports.chiral` offset comment; `scaffold/README.md` refine table + detail (symbolic slice landed) |
| C6 | Honesty apparatus is discipline, not substrate | **FIXED (partial)** | ledger-lint added — see below; the remainder (make more of it structural) is a Track-B gradient |
| C3/C4 | = F3 / F4 | folded into F3 / F4 | — |

**Ledger-lint** (C6, the mechanizable core): `tools/ledger-lint/ledger-lint.py` — cross-checks
status-ledger evidence paths against file existence, rejects P6/P7 citations in
post-condensation docs, and counts open-edges vs MAP's claim. Run in CI/pre-commit
so the apparatus stops decaying silently.

## Track B — design gradients (author in the loop; NOT yet actioned)

| # | Finding | The gradient (not a yes/no) | Status |
|---|---|---|---|
| F1 | Realization runs inverse to novelty; novel layer has had zero contact-with-code | Which novel element gets forced through running code first — edge-16 effect algebra / E51 linkage / a real evidence bridge — before more design accretes | **OPEN — first up** |
| F2/F5 | Tier-climb has no E-numbered rungs; "certificate discipline already in preserve-check" overclaims | Does certificate machinery (kernel-spec, cert format, proof-checker, DDC) enter the catalog, and pre- or post-self-host | OPEN |
| F7/C1 | "already chirality" flattens chirality-over-CPython; backend fork settled+diverged+open | Is the backend fork re-settled by the build or reopened by it; what is the bar for "already chirality" | OPEN |
| F8 | Alarm design's only realization is the anti-pattern it names | Is edge-16's effect algebra the keystone the error model/counter-effects/partiality hang on | OPEN |
| F6 | "85% in two days" anchor does scope-setting work its own hedge disclaims | Whether to strike the unsourced anchor from the trust doc | OPEN (cheap; deferred with the trust-layer docs) |

Open questions Q1–Q6 from the audit map onto F1 (Q1), F2/F5 (Q2), C6 (Q3),
F4 (Q4 — resolved by the sweep + convention), C1 (Q5), F7 (Q6).

## Serious-phase pipeline (map → prerequisites → worked-examples → refactor)

1. **Conformance map — DONE** (`.planning/audit/CONFORMANCE-MAP.md`): 83 rows,
   CONFORMS 32 / EXTEND 7 / REFACTOR 8 / BUILD 29 / DECISION 7. Answers F1's "how
   much refactor": the frame conforms; only E38 (graded kernel) is large-and-core.
2. **Prerequisites pass — DONE (2026-07-21):**
   - Authored **E51–E68** into `SELF-IMPLEMENT-CATALOG.md` (§VII trust/custody novel
     core E52–E63, §VIII already-chirality orchestration E64–E68, E51 sys-face linkage in
     §IV) — the ~13 actionable elements F2 found had no E-number now do. CLAUDE.md →
     E1–E68.
   - Stood up `.planning/DECISION-DOCKET.md` — the 7 DECISIONs as gradients (D1 effect
     mechanism/edge-16 is highest leverage: gates E39/E26/E51).
3. **Worked-example series — NEXT:** one pre-run per actionable E# (EXTEND+REFACTOR+
   BUILD), via the `worked-example` skill in parallel waves (each agent `--no-index`,
   orchestrator appends INDEX rows). Blocked items wait on their docket decision.
4. **Refactor pass — LAST:** must respect the REFACTOR checklist (E38 first — its
   worked-example must *prove* the judgment-seam containment claim).
