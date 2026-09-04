---
element: E50
slug: mutual-lex-termination
title: Bidirectional/mutual termination + lexicographic measures
kind: BUILD-PROPER
example: examples/E50-mutual-lex-termination.md
status: audited
updated: 2026-07-24
---

# E50 SPEC — Bidirectional/mutual termination + lexicographic measures

> ⚑ **TRIAGE 2026-09-04 — DEAD.** 0 of 5 steps are executable at HEAD. Nothing
> to run; the ledger already reads `built` on `lib/typing/totality.chiral`.
> Bucket and evidence: `records/spec-tier-triage.md`. This file was not
> rewritten and its `status:` was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** the totality checker proves termination over a **mutual
  recursion group** carrying a **declared shared measure** — a structural
  subject argument (cheap tier) or a lexicographic tuple — instead of blanket-
  bailing on any inter-def call. A group whose declared measure actually
  decreases around every cycle classifies every member `sig.totality[m] = None`
  (proven total) and passes `require_total` / `(total)`; a group whose measure
  does **not** decrease (a false measure) is REJECTED with a reason and a hard
  error under `(total)`. The self-hosted `infer`/`check` shape (and the
  `eval`/`quote`/`conv` shape) becomes provably total — the rung-1 gate.
- **Non-goals:** full **size-change graph** analysis for argument-permuting
  groups (reserved fallback, §6); measure **inference** (the core only
  re-checks a *declared* measure — certificate discipline); the permanent
  ergonomic `recgroup` surface (E49-era, §3 #1); certificate *serialization*
  for E52's trusted core (§3 #4). Numeric single-position measures and the
  single-function structural pillar are already built — not re-touched.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** the three E50 rows reconcile to **additive
  analysis over the existing check** — "Adds measures into existing check;
  mutual may require call-graph structure (possible partial reshape)." So E50 is
  a **generalization** of the built single-function pillar (E11), not a second
  mechanism: a one-node SCC is the existing check unchanged. The gated
  companion row (flip `require_total` default) is **out of scope** here — it is
  E11's payload, GATED on E47+E50 first, and stays default-OFF.
- **Live code (built shards this composes with — do NOT respec):**
  - `scaffold/chirality/data.py` `check_termination` (`:481`) — the `def_hooks`
    entry; records `sig.totality[name]` (None = total, else reason); already
    honors `sig.require_total` as a hard-error gate.
  - `scaffold/chirality/data.py` `_totality_reason` (`:603`) — the per-def `walk`
    that collects decreasing argument positions per self-call and returns None
    iff `set.intersection(*calls)` is non-empty (a uniform decreasing position).
    Structural (`size` tokens, case-bound subterm) AND numeric (`_num_delta` +
    `_guard_bound` + `_meet` + `_passes_unchanged`, symbolic/constant bounds)
    descent already work — reused verbatim per intra-group edge.
  - `scaffold/chirality/kernel.py` `finish_def` (`:548`) — runs `def_hooks` after a
    body type-checks, **before** installing `sig.global_defs[name]`; so a hook
    can already distinguish an as-yet-unfinished forward reference from a
    finished global (this is exactly the group-completion signal E50 needs).
  - `sig.require_total` (`kernel.py:130`), `sig.def_hooks` (`:127`).
- **The blocker site:** `_totality_reason`'s `k == "Global"` branch — when a
  call targets a name in `sig.global_types` but not `sig.global_defs` (a
  declared-but-undefined mutual-group member) it raises `_NotStructural(
  "... mutual recursion is not yet checked for totality")`. That single raise
  is what makes every mutual group classify not-total. Its live regression
  witness is `test_forward_reference_flagged_as_mutual`
  (`test_kernel.py:585`, the `ev`/`od` pair, **no measure declared**).
- **True delta:** (a) a way to *declare* a group + its shared measure; (b) at
  the blocker, treat an intra-group call as a **measure edge** to verify rather
  than a raise; (c) a **group verdict** run at group completion that checks the
  size-change condition (every intra-group edge non-increasing on the declared
  measure; every cycle strictly decreasing) and writes the per-member verdict.

## 3. Decisions

Every open question from example §6, dispositioned:

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Measure-declaration **surface**: `recgroup` form vs per-`def` `(measure …)` attribute vs full inference | RESOLVED (interim) + DEFERRED (permanent) | Implement against an **interim `(measure …)` attribute on the existing `declare`** — the example §6 itself offers it ("or a `(declare …)` attribute in the interim"). The ergonomic `recgroup`/`measure` surface is **E49-era** (example §6, §Related). Full measure **inference** is a non-goal: certificate discipline puts inference in a later *untrusted producer*; the trusted core only re-checks a declared measure. Non-blocking: the group-analysis engine + soundness gate are surface-independent and drive the conformance tests through the interim form. |
| 2 | Do the checker's own groups need only a declared shared measure, or does some group (conv) force the full size-change graph? | RESOLVED | Example §2/§6 finding: `infer`/`check` and `eval`/`quote`/`conv` need only a **declared shared structural measure** (the subject term/value); **lexicographic** (budget, term) covers conv-under-unfolding. Cheap tier suffices for rung-1 self-hosting. |
| 3 | Full **size-change graph** analysis (argument-permuting groups) | DEFERRED | Reserved fallback the checker's groups largely do not need; not built here. Home: its own follow-on element (§6). |
| 4 | How a measure becomes a **certificate** E52's trusted core re-checks | DEFERRED → **E52** | This SPEC builds the *re-checker* (the verifier of a declared measure) — the certificate-*checking* half. Producing/serializing the certificate for an external core is E52's obligation (`certificate-discipline`, `[[E52-certificate-split]]`). |

No disposition blocks §4. Frontmatter `status: draft`.

## 4. Change plan (ordered, commit-sized)

### Step 1 — Measure record + group registry (plumbing)
- **Target:** `scaffold/chirality/data.py` — new `Measure` record (kind ∈
  `{structural, lexicographic}`; for structural, the measured argument name/
  position; for lexicographic, an ordered list of positions each tagged
  `structural`|`numeric`). New `sig` fields registered at `install(sig)`:
  `sig.measures: {name -> Measure}` and `sig.recgroups: {group_id -> [names]}`
  with an inverse `sig.recgroup_of: {name -> group_id}`.
- **Surface (interim, per decision #1):** parse a `(measure structural <arg>)` /
  `(measure lexicographic (<arg> <kind>) …)` attribute where `declare` is
  handled, populating the registry and grouping every member that shares the
  declaration. Members without a measure keep today's behavior untouched.
- **Size:** M

### Step 2 — Turn the blocker raise into a measure edge
- **Target:** `scaffold/chirality/data.py` `_totality_reason` — the `k == "App"`
  head-is-`Global` case and the `k == "Global"` bail branch.
- **Change:** when the called name is in the **same recgroup** as `name`
  (`sig.recgroup_of.get(callee) == sig.recgroup_of.get(name)` and the group has
  a `Measure`), do NOT raise. Instead reuse the existing decreasing-position
  logic against the **declared measured argument position(s)** and record an
  edge `(caller=name, callee, delta ∈ {strict, equal, unknown})` into a group-
  scoped accumulator on `sig` (e.g. `sig._recgroup_edges[group_id]`). A
  self-call is the degenerate intra-group edge (unchanged single-function
  path still applies for one-node SCCs). Calls outside the group are unchanged.
- **Size:** L

### Step 3 — Group verdict at completion (the soundness gate)
- **Target:** `scaffold/chirality/data.py` — new `_check_recgroup(sig, group_id)`,
  invoked from `check_termination` when the finishing def is the **last**
  member of its group (all other members already in `sig.global_defs`;
  `finish_def` installs the current one only after hooks — so "last" =
  every *other* member present). 
- **Change / soundness condition (cheap tier, single shared measure):** over
  the accumulated intra-group edges — (i) if any edge is `unknown` (the
  measured argument is neither a subterm-or-equal for structural, nor a
  well-founded step for numeric) → **REJECT**; (ii) else require every cycle to
  contain a strict-decrease edge, i.e. the subgraph of `equal`-only edges is
  **acyclic** → else **REJECT**. Lexicographic compares the declared tuple
  left-to-right (an edge is `strict` if some position strictly decreases with
  all earlier positions `equal`; `equal` if all positions `equal`; else
  `unknown`). On PASS: `sig.totality[m] = None` for every member. On REJECT: a
  reason string (`"mutual group <g>: measure does not decrease around every
  cycle …"`) on the offending member(s); with `sig.require_total`/`(total)` the
  existing raise in `check_termination` fires. **This is the trusted-core
  soundness point: a false measure never classifies total.**
- **Size:** L

### Step 4 — One-node SCC / no-measure = current behavior (regression guard)
- **Target:** `scaffold/chirality/data.py` `check_termination` / `_totality_reason`.
- **Change:** gate the entire new path behind "member has a declared measure &
  belongs to a multi-member group." A def with no declared group routes through
  the existing `_totality_reason` byte-for-byte; a declared mutual group with
  **no** measure keeps today's `mutual recursion is not yet checked` reason (so
  `test_forward_reference_flagged_as_mutual` stays green). Verify no change to
  any existing `sig.totality` verdict.
- **Size:** S

### Step 5 — Tests (§5)
- **Target:** `scaffold/tests/test_kernel.py` `TestTermination` (add methods
  beside the existing single-function cases).
- **Size:** M

## 5. Conformance gate

- **Golden behavior:** a mutual group with a **truthful** shared measure proves
  every member total; a group with a **false** measure (equal-only cycle, or a
  call passing a non-subterm / unbounded numeric step) is rejected; every
  single-function verdict is unchanged.
- **Tests to add** (all in `TestTermination`, pure kernel floor — no native
  differential needed, this is a static-analysis verdict):
  1. `test_mutual_structural_group_is_total` — a two-member group (`infer`/
     `check`-shaped, e.g. `ev`/`od` over a `List`/`Nat` subject) with a declared
     shared **structural** measure: `assertIsNone(totality[m])` for both members.
  2. `test_mutual_lexicographic_group_is_total` — a `(fuel, term)` lexicographic
     measure: one edge drops fuel, one holds fuel and shrinks the term →
     both members total.
  3. **`test_false_measure_mutual_group_rejected`** (the soundness negative —
     the point of E50): a mutual pair whose declared measure does **not**
     decrease around the cycle (equal-only, or a `(+ i 1)`-unbounded step)
     → `assertIsNotNone(totality[m])`; and under `el.sig.require_total = True`
     the load `assertRaises` with the group reason. A false measure MUST be
     rejected, exactly like `test_vacuous_extreme_bound_does_not_prove` guards
     the single-function checker.
  4. `test_mutual_no_measure_still_flagged` — the current `ev`/`od` with **no**
     declared measure keeps the `"mutual recursion"` reason (Step 4 guard;
     may be the existing `test_forward_reference_flagged_as_mutual` retained).
- **Regression:** the whole existing `TestTermination` class stays green —
  `test_structural_recursion_is_total`, `test_nonrecursive_is_total`,
  `test_guarded_numeric_recursion_is_total`,
  `test_unbounded_recursion_not_proven`, `test_require_total_rejects_unprovable`,
  `test_vacuous_extreme_bound_does_not_prove`, `test_require_total_admits_structural`,
  `test_escaping_self_reference_not_proven`, `test_symbolic_bounded_loop_is_total`,
  `test_symbolic_decrement_is_total`, `test_symbolic_bound_must_stay_fixed`,
  `test_symbolic_step_must_be_unit`,
  and `test_forward_reference_flagged_as_mutual` — unchanged verdicts.
- **Green line:** 281 → ≥ 284 test functions (≥ 285 if gate test 4 is a new
  method rather than the retained `test_forward_reference_flagged_as_mutual`);
  `python3 -m pytest scaffold/tests` clean; `tools/ledger-lint/ledger-lint.py` clean.
- **Done when:** a truthful mutual group classifies all members total and
  passes `(total)`, a false-measure group is rejected (reason + `require_total`
  raise), and the full existing `TestTermination` is green.

## 6. Residue & links

- **Deliberately unbuilt:**
  - Full **size-change graph** analysis for argument-permuting groups — its own
    follow-on element (decision #3); the reserved fallback tier.
  - Measure **inference** — a later *untrusted* producer (certificate
    discipline); the core here only re-checks a declared measure.
  - The permanent ergonomic `recgroup`/`measure` **surface** — **E49**-era
    (decision #1); this SPEC uses the interim `declare`-attribute.
  - Measure **certificate serialization** for an external trusted core — **E52**
    (decision #4); this SPEC builds the re-checker, not the emitter.
  - Flipping `require_total` **default ON** — **E11**'s payload, GATED on
    E47+E50 both landing (map row); stays default-OFF here.
- **Follow-on (this unblocks):** the rung-1 self-applicability gate — proving
  the self-hosted `infer`/`check` and `eval`/`quote`/`conv` groups total, hence
  E52's trusted-core normalization/termination obligation; and E11's
  enforcement-default flip once E47 also lands.
- **Related:** [[E50-mutual-lex-termination]] (the worked example / rationale),
  [[E11-totality-checker]] (single-function pillar generalized — one-node SCC),
  [[E47]] (sized types — sibling numeric-measure path; bound-in-the-type vs
  measure-over-args), [[E52-certificate-split]] (trusted core discharged here),
  [[E03-nbe-normalize]] / [[E04-bidir-universes]] (the mutual groups being
  proven), `docs/totality.md` (the classify-then-enforce pillar),
  `docs/certificate-discipline.md` (declared-and-verified, not inferred).
