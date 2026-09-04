---
element: E71
slug: golden-restructure
title: Golden-semantics restructure: what floor agreement means once the Python reference executor is evicted — a chirality reference executor, or the spec as the golden object with the reference demoted to first-among-executors
kind: BUILD-PROPER
example: docs/examples/E71-golden-restructure.md
status: audited
updated: 2026-08-02
---

# E71 SPEC — Golden-semantics restructure (spec-as-golden)

> ⚑ **TRIAGE 2026-09-04 — DONE-ALREADY.** 2 of 4 steps are executable at HEAD.
> Self-annotated: Steps 3-4 SHIPPED under `docs/definitions/`. OT track,
> deferred, do not queue. Bucket and evidence: `records/spec-tier-triage.md`.
> This file was not rewritten and its `status:` was not changed.

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> **Provisional, on purpose (author call 2026-08-02): "go with the example as
> specced — it can change."** This SPEC is written FOR branch (b),
> spec-as-golden — the provisionally-adopted direction — and is **not gated on
> ratification**. Everything below is revisitable; the artifact records it as
> provisional. Proceeding beats stalling for a blessing.
>
> ⚑ **RE-AUDITED 2026-08-31 (SPEC level). Verdict: BLOCKED — not implementable
> as written.** Nothing below was rewritten toward a guess; four things were
> measured against the tree and corrected in place, and four author calls are
> FLAGged at their sites and left open.
>
> 1. **It is HALF SHIPPED and nothing recorded it.** Steps 3 and 4 landed:
>    `docs/definitions/tal-spec.md` exists (116 L, `status: draft`,
>    `updated: 2026-08-02`) and `docs/definitions/floor-agreement.md:28-52`
>    carries the rewritten spec-as-golden **Statement**. Steps 1 and 2 did not:
>    `lib/tal-spec.chiral` does not exist anywhere in the tree. `docs/elements/ledger.md:119`
>    says `design`; `docs/examples/INDEX.md:69` says `audited`. Neither states
>    the half-built truth — §2 and §4 now do (FLAG D).
> 2. **The conformance gate cited a floor that no longer exists.** §5's
>    "the reference floor produces" meant the Python `TalMachine`, evicted by
>    `docs/decisions/decision-scope.md` decision 5 and recorded CUT throughout
>    `docs/definitions/status-ledger.md:87,91,99,101`. The seed corpus it drew
>    on (division sign grid, byte-cell zero-read, fold/native/reference triples)
>    died with `test_native.py` / `test_optimize.py` / `test_tal.py`. §5 is
>    re-founded on `docs/definitions/testing-floors.md:214-228`'s provenance
>    ladder, rank 3.
> 3. **The paths are hoisted.** The 2026-08-31 migration moved the tree to
>    `lib/<role>/`, `prog/`, `tools/test/`, and the docs to
>    `docs/{definitions,decisions,examples}/`. Every `scaffold/…`, flat
>    `docs/*.md` and flat `lib/*.chiral` path below is rewritten to its live
>    home, or struck where the target is gone.
> 4. **A chirality reference executor already exists** — two of them
>    (`lib/evidence/interp.chiral`, E15 `built`; `lib/lowering/tal/eval.chiral`,
>    E18 `built`). §1 and §2 said "eventually". That is what §5's differential
>    direction now runs against, as a *conformance check of the executor*, never
>    as the source of a vector.
>
> Four FLAGs are open at their sites and are **not** resolved here: the L0
> `kernel-spec` is owned by no element (§2, FLAG A); this element may sit inside
> the deferred ownership/trust track (§6, FLAG B); the shipped Step 3/4 prose
> now contradicts decision 5 and nobody owns the repair (§4, FLAG C); E71's
> build-state has three claimants and three answers (§2, FLAG D).

## 1. Deliverable

- **After this runs:** the floor's trust anchor moves from "the Python
  `TalMachine` is the semantics" to **spec-as-golden** — three artifacts:
  1. ~~`docs/tal-spec.md` (NEW)~~ **`docs/definitions/tal-spec.md` — SHIPPED**
     (116 L, `status: draft`, `updated: 2026-08-02`; §4 Step 3): the **prose
     anchor**, per-instruction transition semantics + pinned observables,
     human-audited, weekend-readable (E72's seed). The definitional object.
  2. `lib/tal-spec.chiral` (NEW) — **NOT SHIPPED; the whole remaining build.**
     The checkable **data form** of the spec: `Obs`/`SpecEntry`/`Verdict` +
     `conform` (example §5). ~~with **exemplar entries seeded from the existing
     differential corpus** (division sign grid, byte-cell zero-read) so the
     restructure changes the anchor without changing a passing test~~ ⚑ **that
     seeding route is gone** — the differential corpus was the Python oracle's
     and is CUT (§2). The exemplar entries are hand-derived at rank 3 and the
     executors are checked *against* them (§5).
  3. ~~`docs/floor-agreement.md`~~ **`docs/definitions/floor-agreement.md` —
     SHIPPED** (§4 Step 4): its "Statement" section reads *"a floor that
     disagrees with the spec's vectors and semantic functions is wrong by
     definition"* (`:47-48`); the reference interpreter demoted to
     first-among-producers (`:35-36`, `:50-52`).
- **Non-goals:** ratification (stays provisional); **complete** per-instruction
  coverage (the first cut ships the shape + exemplars; vectors grow with the
  corpus — §3 #3); the executable-spec *runner* (`conform` as running tooling —
  the data shape lands, the runner is follow-on); the final `MState`
  abstraction (a minimal shape carries the exemplars — §3 #4); sysface entries'
  interaction with E70's row shadow (E70 owns that).

## 2. Baseline (what already exists)

- **Conformance-map verdict:** no E71 row (postdates snapshot) — **BUILD**. This
  is a decision + doc + one data artifact; no port.
- **Live code/docs this composes with (do NOT respec):**
  - `docs/definitions/floor-agreement.md` — ⚑ **already carries the finished
    rewrite, not merely the banner.** `:12-20` is the provisional banner and
    `:28-52` is the spec-as-golden **Statement**. Step 4 is SHIPPED. What the
    note still owes is named at §4 Step 4.
  - `docs/definitions/tal-spec.md` — ⚑ **exists**, 116 L, the Step 3 deliverable.
    Step 3 is SHIPPED. What it still owes is named at §4 Step 3.
  - **The two built chirality executors**, which this SPEC wrote as "eventually":
    `lib/evidence/interp.chiral` (E15, `LEDGER.md:114` `built` — upper-term
    evaluator) and `lib/lowering/tal/eval.chiral` (E18, `LEDGER.md:117` `built`
    — the fuel-bounded tal reference interpreter, explicit threaded `Store`,
    `bnew` zero-inits at `:148-150`). ⚑ Neither is on the compile path and
    neither is gated: `status-ledger.md:99` records that nothing imports
    `lib/lowering/tal/eval.chiral`. They are producers to be admitted, not
    sources of truth.
  - ~~The existing differential suite — division sign grid (incl. INT_MIN/-1,
    /0), byte-cell zero-read, fold/native/reference triples. These become the
    spec's **seed corpus**: every observable they already check must be
    derivable from spec vectors, so no passing test changes.~~ ⚑ **CUT
    2026-08-31 — the seed corpus does not exist.** It lived in the Python
    oracle: `status-ledger.md:91` records `test_optimize.py` / `test_native.py`
    (the fold/native/reference triples and the sign grid) CUT, `:99` records
    `test_tal.py` CUT. No live gate in `tools/test/` divides negatively or reads
    an unwritten byte — grepped 2026-08-31. Consequence: E71 cannot re-anchor
    existing tests, because there are none to re-anchor. It must **found**
    vectors and **add** its own gate (§5).
  - ~~`docs/chirality-division-euclidean` + the SMT-LIB pin~~ ⚑ **that path names
    nothing in the tree.** The Euclidean/SMT-LIB pin's live homes are
    `docs/definitions/floor-agreement.md:90-100` (§*Worked example: division*,
    the canonical floor-agreement failure and its fix) and
    `docs/decisions/decision-numeric-width-pluggable.md:43` (`wrapW` and
    Euclidean div/mod at the profile's width). That is the precedent this
    generalizes: the reference was never trusted to define `/`; it was pinned to
    an external spec. E71 is that move, floor-wide.
  - ~~`lib/ddc.chiral` / `scaffold/tests/ddc.py`~~ **`lib/evidence/ddc.chiral`**
    (E53) — the DDC compare that climbs *against* the golden object; consumes
    this spec (E72). ⚑ Its Python driver `scaffold/tests/ddc.py` is CUT with the
    oracle, and E72 is in the deferred track (§6, FLAG B).
- ~~**True delta:** the two new files + the floor-agreement.md Statement rewrite.
  Nothing executable changes; the tests are re-anchored, not re-written.~~
- ⚑ **True delta, re-measured 2026-08-31:** **one** file —
  `lib/tal-spec.chiral` — plus one gate that did not exist when this was
  written, plus the corrections the two shipped docs now owe (§4 Steps 3-4,
  FLAG C). "Nothing executable changes" still holds. "The tests are re-anchored,
  not re-written" is **false**: there is nothing left to re-anchor.

- ⚑ **FLAG A (2026-08-31) — the L0 `kernel-spec` is owned by no element, and
  this SPEC is where the E52 audit sent the question.** `docs/elements/catalog.md:212`
  (E71's own catalog row) calls **the kernel-spec** the golden object, and
  `docs/decisions/decision-self-verification.md:253-256` repeats it — *"E71 is
  the frame the cores sit in … the kernel-spec is the golden object"* — with
  `:98-102` making `kernel-spec` the **L0 audited base** the whole hierarchy
  terminates in (`:121-122`: *"terminates downward in an artifact a human reads,
  not in a proof"*). But this SPEC delivers `docs/definitions/tal-spec.md` +
  `lib/tal-spec.chiral` — the **tal** floor — and names kernel-spec nowhere.
  E52's SPEC makes `docs/kernel-spec.md` an explicit non-goal *because it
  "couples E71"* (`docs/elements/specs/E52-certificate-split-SPEC.md:71-79`), and
  E72 merely *couples* it (`SELF-IMPLEMENT-CATALOG.md:218`). **No element builds
  it.** Consequence already in code: `Spec`/`SpecRule` exist at
  `lib/typing/kernel-core.chiral:28-29` with nothing populating them. Report,
  never pick.

- ⚑ **FLAG D (2026-08-31) — E71's build-state has three claimants and three
  answers:**
  | claimant | says |
  |---|---|
  | `docs/elements/ledger.md:119` | `design` |
  | `docs/examples/INDEX.md:69` | `audited` |
  | this SPEC's frontmatter | `status: audited`, `updated: 2026-08-02` |
  | the tree | Steps 3-4 SHIPPED, Steps 1-2 absent — half built |
  No row anywhere records "half built". The frontmatter is left untouched by
  this re-audit because the verdict is BLOCKED and the skill forbids a status
  flip that no gate earned.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | The branch itself (reference-as-golden vs spec-as-golden). | **PROVISIONAL: spec-as-golden (b) — revisitable, not ratified.** | The author's standing call ("go for a solution, may change"); this SPEC proceeds against it. Recorded as provisional in all three artifacts. Ratification remains owed but does NOT gate the work. |
| 2 | The executable-spec circularity (`sem` functions are chirality code needing an executor). | **RESOLVED: prose is the anchor, executable form is the first derived checker.** | The human-audited **prose reading** of each entry (`docs/tal-spec.md`) is the trust root (E72's weekend artifact); `lib/tal-spec.chiral` is a derived, checkable form, not the definition. Two files, one prose one data (§4). |
| 3 | Who curates vector growth as tal grows (edge 6). | **RESOLVED: a new instruction is a new spec entry FIRST.** | Under spec-as-golden the admission rule for a new tal instruction is "add its spec entry + vectors before any executor implements it." The first cut ships exemplars; growth is this standing rule, not a backlog. |
| 4 | The `MState` abstraction level. | **RESOLVED for the first cut: minimal, exemplar-driven; grows.** | `MState` carries just what the exemplar entries (division, byte op) observe — operands + the `Obs` result. Its full shape is deliberately incremental (each new entry extends it as needed), not decided up front. |
| 5 | Spec coverage of the sys face. | **RESOLVED: pin the register/observable contract, not kernel behavior.** | A real syscall is not a pure transition; the spec pins what crosses (the `obs-sys` observable: number + args) and the register contract, not the kernel's internal effect. |

~~No NEEDS-AUTHOR blockers (the branch is provisional-but-working, per the author).~~

⚑ **Reversed 2026-08-31.** The five rows above stand as dispositioned — the
2026-08-02 re-audit did not disturb them and neither does this one; decision #2's
path citation is hoisted to `docs/definitions/tal-spec.md` and its data-form
target is unchanged. What reversed is the *conclusion*: this SPEC now waits on
**four author calls** (FLAG A §2, FLAG B §6, FLAG C §4, FLAG D §2), none of them
about the branch. It is **BLOCKED**, not implementable as written.

## 4. Change plan (ordered, commit-sized)

> **Step order re-measured 2026-08-31: Steps 3 and 4 SHIPPED; Steps 1 and 2 did
> not.** The plan is left in its authored order and each step marked, because
> renumbering would erase which half landed.

### Step 1 — `lib/tal-spec.chiral`: the spec's data shape · **NOT SHIPPED**
- **Target:** `lib/tal-spec.chiral` (NEW — verified absent 2026-08-31). ⚑ Under
  the hoist (`MAP.md`, `CLAUDE.md` "the module key is the root-relative path
  under `lib:`") a flat `lib/*.chiral` is no longer a home. The live neighbours
  are `lib/lowering/tal/{ssa,check,eval}.chiral`. **Home is a placement call the
  implementation run must make against `MAP.md`, not inherit from this line.**
- **Change:** the vocabulary from example §5 — `Obs` (obs-val / obs-halt /
  obs-sys), `SpecEntry` (name + total-pure `sem` transition + pinned vectors),
  `Verdict` (admitted / diverged), `conform` declaration. Total, pure, loads
  clean.
- **Size:** ~M.

### Step 2 — exemplar entries, hand-derived · **NOT SHIPPED**
- **Target:** the Step 1 module (entries) + a minimal `MState`.
- **Change:** two entries — `div` (the Euclidean/SMT-LIB sign grid incl.
  INT_MIN/-1 → wrapped INT_MIN and /0 → the fatal alarm) and a byte op
  (`bput`/zero-read). ~~transcribed from the existing division differential …
  Vectors are the exact input/observable pairs the current tests assert.~~
  ⚑ **Corrected 2026-08-31: there is no differential left to transcribe from,
  and transcribing from an executor would invert the golden relation this
  element exists to establish.** The vectors are **rank 3**
  (`docs/definitions/testing-floors.md:222-224` — *"the meaning of the form,
  hand-derived … from what the program is supposed to mean, by hand, before
  running anything"*), which is the highest rank still available: rank 1 is
  external judgment and `docs/decisions/decision-scope.md` decision 5 emptied it. The seven-row sign
  grid already written out at `docs/definitions/tal-spec.md:77-86` is that
  hand-derivation and is the transcription source for this step.
- **Size:** ~M.

### Step 3 — the prose anchor · **SHIPPED**
- **Target:** ~~`docs/tal-spec.md` (NEW)~~ **`docs/definitions/tal-spec.md`**,
  116 L, `status: draft`, `updated: 2026-08-02`.
- **Change:** the human-readable per-entry semantics + observables for the
  exemplars, written as the weekend-auditable definition; the data form (Step 1)
  references it. Marked provisional. **Landed**: observables at `:37-60`, the
  `div` entry + full sign grid at `:62-88`, `byte-zero-read` at `:90-96`,
  *What this makes impossible* at `:98-108`, *Reach* at `:110-116`.
- **Size:** ~M.
- ⚑ **FLAG C (2026-08-31) — the shipped prose now contradicts a later author
  decision, and nobody owns the repair.** Two defects, both in artifacts E71
  authored, both **above the doc tier** so this audit does not pick:
  1. `docs/definitions/tal-spec.md:19-21` still lists *"the Python reference
     `TalMachine`"* first among tal's executors. `docs/decisions/decision-scope.md` decision 5 evicted
     it and `status-ledger.md:22-24` records external judgment CUT. The same
     name survives at `docs/definitions/floor-agreement.md:35` inside the
     rewritten Statement (Step 4's own output), so the contradiction is in
     **both** shipped artifacts. The live substitutes are named in §2.
  2. `docs/definitions/tal-spec.md:74-75` says each vector is *"the exact
     observable the reference floor independently produces — verified in
     `tests/test_tal_spec.py`"*. That file never existed, is Python, and would
     be forbidden by `CLAUDE.md` ("Python compiles nothing. EVER."; zero Python
     is absolute, `docs/decisions/decision-scope.md`:40,85`). It also asserts the inverted founding
     relation §5 corrects. **The question for the author, verbatim: is repairing
     these two shipped E71 artifacts a re-opened E71 step, or doc-tier rot for a
     `doc-audit` run?** E71 authored both files, which argues E71; the tier
     rule says a doc-audit owns doc prose, which argues elsewhere; and
     `docs/decisions/decision-scope.md` may forbid touching them at all (FLAG B).

### Step 4 — the Statement section · **SHIPPED**
- **Target:** ~~`docs/floor-agreement.md`~~ **`docs/definitions/floor-agreement.md`**.
- **Change:** replace the reference-is-golden body with spec-as-golden (the
  reference demoted to first-among-producers; divergence from the spec is
  *investigated*, not auto-ruled against either side); keep the provisional
  framing until ratification. The agreement mechanism text is unchanged.
  **Landed**: banner `:12-20`, Statement `:28-52`, the "wrong by definition"
  sentence now pointing at the spec `:47-48`, the demotion `:35-36` and `:50-52`.
- **Size:** ~S.
- ⚑ **Residue, measured:** the note's own banner (`:17-20`) concedes its lower
  sections "still read *against the reference*", and `Reach` (`:118-120`) still
  states the admission rule as *"agrees with the **reference interpreter** on
  observable value"* — the pre-restructure sentence, verbatim, in the section
  that states the rule for every future backend. Under spec-as-golden that line
  is the thing this element denies. It is a Step 4 residue, not a new step;
  ownership of the repair is FLAG C.

## 5. Conformance gate

⚑ **REWRITTEN 2026-08-31. The gate as authored could not run, and its failure
was not arithmetic drift — it named the evicted Python `TalMachine` as the thing
the spec's own vectors must match.** Struck text is kept so the inversion is
visible rather than quietly replaced.

- ~~**Golden behavior:** every observable the current differential suite checks is
  **derivable from a spec vector** — the existing tests become the spec's seed
  corpus, so the restructure changes the anchor with **zero passing tests
  changed**.~~ ⚑ Unmeetable: the suite is CUT (§2), so there is nothing to
  re-anchor and "zero passing tests changed" is trivially true and evidences
  nothing.
- **Golden behavior, re-founded:** the exemplar vectors are **hand-derived from
  the meaning of the form** — rank 3, `docs/definitions/testing-floors.md:222-224`
  — because rank 1 (external judgment) is empty by `docs/decisions/decision-scope.md` decision 5 and
  rank 2 (an independent in-house reference: `interp`, `tal-eval`) **may not
  found this artifact**: under spec-as-golden a vector taken from an executor is
  semantics-by-accident, which `docs/definitions/tal-spec.md:98-104` and
  `floor-agreement.md:47-52` make the one thing this element exists to forbid.
  The direction runs the other way: the executors are checked **against** the
  spec, and a divergence is *investigated, not auto-ruled against either side*
  (`tal-spec.md:104-108`). The Step 1 module loads, is total/pure, and its
  vectors reproduce `docs/definitions/tal-spec.md:77-86` row for row.
- ~~**Tests to add (`scaffold/tests/test_tal_spec.py`, NEW)**~~ ⚑ **that path is
  dead twice over**: `scaffold/` is deleted, and a Python gate is forbidden
  outright (`CLAUDE.md`: "the compiler compiles everything. Python compiles
  nothing. EVER."; zero Python is absolute, `docs/decisions/decision-scope.md`:40,85`). **The gate is a
  chirality sample + a phase in `tools/test/run-tests.sh`**, the shape every live
  gate has (`tools/test/samples/*.prog` driven by Phase 2 / Phases 3-6, 13):
  1. **Load + totality:** the Step 1 module elaborates under `bin/chirality-bin`
     and its `sem`/entries are total-pure (the spec is category-A).
  2. **Vector fidelity, rank 3:** every vector in the module equals the
     hand-derived observable written out at `docs/definitions/tal-spec.md:77-86`
     — the prose anchor is the source, the data form is checked against it. This
     is the check that replaces "corpus agreement"; it compares the data form to
     the *definition*, not to a producer.
  3. **Executor conformance (the differential, in its correct direction):** run
     `lib/lowering/tal/eval.chiral` on each vector's input and require the
     observable the **spec** pins. A divergence names the entry and is a finding
     against the executor or against the spec — never silently against the
     executor. ⚑ Note the honest limit: `eval.chiral` is unreached and ungated
     today (`status-ledger.md:99`), so this phase is also its first gate.
  4. **`conform` shape:** a deliberately-wrong executor (one entry perturbed)
     yields `diverged` naming the entry; a matching one yields `admitted`.
  5. **Run the mutant** (`docs/definitions/testing-floors.md:231-236`): perturb
     one sign-grid row (e.g. `-7 / 2` → `obs-val -3`, the truncating answer) and
     record the measured failure of check 2; revert. A gate row that cannot name
     a RUN mutant is a finding.
- ~~**Green line:** 404 → **≥ 407** (the post-E69 baseline; the spec's original
  390 predates E69's closure-conversion + q=0 tests); `ledger-lint` clean; **no
  existing test changes** (the anchor moved, behavior did not).~~ ⚑ **A pytest
  function count is not a green line here.** The Python oracle suite is CUT, so
  no such number exists to move. **Green line:** `tools/test/run-tests.sh` gains
  one named phase, exits 0, and every phase it already passes still passes; the
  5 unported phases keep printing by name and reason; `ledger-lint` no worse than
  its recorded state (⚑ it **exits 1** today on check I for a reason unrelated to
  this element — `docs/decisions/decision-scope.md`:38` — so "clean" is not an available bar; the bar is
  *no new FAIL*).
- **Done when:** the division + byte-cell observables are pinned as spec vectors
  **hand-derived from `docs/definitions/tal-spec.md`**, ~~that the reference floor
  satisfies~~ **that `lib/lowering/tal/eval.chiral` is measured against**, and
  `docs/definitions/floor-agreement.md` reads spec-as-golden throughout — ⚑
  including `Reach` (`:118-120`), which does not yet (§4 Step 4).

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - *Ratification* — the owed author call; does not gate this work (E72 is its
    strongest argument).
  - *Complete per-instruction coverage* — grows by the "new instruction = new
    entry first" rule (§3 #3).
  - *The executable-spec runner* — `conform` as tooling; follow-on.
  - *Final `MState` shape* — incremental (§3 #4).
  - *Sysface × E70 row shadow* — → [[E70-effectful-lowering]].
  - ⚑ *The L0 `kernel-spec`* — **not deliberately unbuilt: ownerless.** FLAG A, §2.
- **Follow-on / links:** [[E72-re-bootstrap]] (consumes this spec — the climb's
  golden object; E72 is unbuildable without it), [[E15-reference-interpreter]]
  (demoted to first-among-producers; **built**, `lib/evidence/interp.chiral`),
  [[E18-tal-check]] (the checker beside the semantics; **built**,
  `lib/lowering/tal/{check,eval}.chiral`), [[E53]] (DDC climbs against it —
  `lib/evidence/ddc.chiral`), `docs/definitions/floor-agreement.md` (the note
  restructured), ~~`docs/chirality-division-euclidean`~~
  `docs/definitions/floor-agreement.md:90-100` +
  `docs/decisions/decision-numeric-width-pluggable.md:43` (the precedent),
  D7/edge 11 (where correlated agreement remains, honestly, for the floor's
  *executors*).

- ⚑ **FLAG B (2026-08-31) — this element may be out of scope entirely, and that
  call is above the audit.** `docs/decisions/decision-scope.md` section, set by the author
  2026-08-31, reads: *"The ownership and trust model is a **separate track,
  deferred**: the re-bootstrap climb, DDC, the secure datum model, the register
  root, the cascade. Do not pull any of it into current work, and do not audit
  its documents."* E71's stated consumers are exactly that track — E72 (the
  re-bootstrap climb) and E53/DDC — and
  `docs/decisions/decision-self-verification.md:253-256` files E71 as the frame
  for the L0/L1/L2 hierarchy, which is the same track. Against that: E71's own
  deliverable is the **tal floor**, and floor agreement gates every backend and
  every new tal instruction, which is self-hosting work. **The question for the
  author, verbatim: is E71 in the deferred ownership/trust track, or does the
  tal floor stay in scope while E72/E53/kernel-spec wait?** Nothing in this
  re-audit assumes an answer; the corrections above are true either way.
