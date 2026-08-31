---
element: E71
slug: golden-restructure
title: Golden-semantics restructure: what floor agreement means once the Python reference executor is evicted — a chirality reference executor, or the spec as the golden object with the reference demoted to first-among-executors
kind: BUILD-PROPER
example: examples/E71-golden-restructure.md
status: audited
updated: 2026-08-02
---

# E71 SPEC — Golden-semantics restructure (spec-as-golden)

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.
>
> **Provisional, on purpose (author call 2026-08-02): "go with the example as
> specced — it can change."** This SPEC is written FOR branch (b),
> spec-as-golden — the provisionally-adopted direction — and is **not gated on
> ratification**. Everything below is revisitable; the artifact records it as
> provisional. Proceeding beats stalling for a blessing.

## 1. Deliverable

- **After this runs:** the floor's trust anchor moves from "the Python
  `TalMachine` is the semantics" to **spec-as-golden** — three artifacts:
  1. `docs/tal-spec.md` (NEW) — the **prose anchor**: per-instruction transition
     semantics + pinned observables, human-audited, weekend-readable (E72's
     seed). The definitional object.
  2. `lib/tal-spec.chiral` (NEW) — the checkable **data form** of the spec:
     `Obs`/`SpecEntry`/`Verdict` + `conform` (example §5), with **exemplar
     entries seeded from the existing differential corpus** (division sign grid,
     byte-cell zero-read) so the restructure changes the anchor without changing
     a passing test.
  3. `docs/floor-agreement.md` — its "Statement" section rewritten: *"a floor
     that disagrees with the spec's vectors and semantic functions is wrong by
     definition"*; the reference interpreter demoted to first-among-producers.
     (The note already carries the provisional banner; this finalizes the text.)
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
  - `docs/floor-agreement.md` — already carries the provisional spec-as-golden
    banner (from the 2026-07-26 provisional call). This SPEC finalizes the
    "Statement" section's body; the *agreement mechanism* (every executor agrees
    on the observable) is unchanged — only *what is golden* moves.
  - The existing differential suite — division sign grid (incl. INT_MIN/-1,
    /0), byte-cell zero-read, fold/native/reference triples. These become the
    spec's **seed corpus**: every observable they already check must be
    derivable from spec vectors, so no passing test changes.
  - `docs/chirality-division-euclidean` + the SMT-LIB pin — the precedent this
    generalizes (the reference was never trusted to define `/`; it was pinned to
    an external spec). E71 is that move, floor-wide.
  - `lib/ddc.chiral` / `scaffold/tests/ddc.py` (E53) — the DDC compare that climbs
    *against* the golden object; consumes this spec (E72).
- **True delta:** the two new files + the floor-agreement.md Statement rewrite.
  Nothing executable changes; the tests are re-anchored, not re-written.

## 3. Decisions

Every open question from the example §6, dispositioned.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | The branch itself (reference-as-golden vs spec-as-golden). | **PROVISIONAL: spec-as-golden (b) — revisitable, not ratified.** | The author's standing call ("go for a solution, may change"); this SPEC proceeds against it. Recorded as provisional in all three artifacts. Ratification remains owed but does NOT gate the work. |
| 2 | The executable-spec circularity (`sem` functions are chirality code needing an executor). | **RESOLVED: prose is the anchor, executable form is the first derived checker.** | The human-audited **prose reading** of each entry (`docs/tal-spec.md`) is the trust root (E72's weekend artifact); `lib/tal-spec.chiral` is a derived, checkable form, not the definition. Two files, one prose one data (§4). |
| 3 | Who curates vector growth as tal grows (edge 6). | **RESOLVED: a new instruction is a new spec entry FIRST.** | Under spec-as-golden the admission rule for a new tal instruction is "add its spec entry + vectors before any executor implements it." The first cut ships exemplars; growth is this standing rule, not a backlog. |
| 4 | The `MState` abstraction level. | **RESOLVED for the first cut: minimal, exemplar-driven; grows.** | `MState` carries just what the exemplar entries (division, byte op) observe — operands + the `Obs` result. Its full shape is deliberately incremental (each new entry extends it as needed), not decided up front. |
| 5 | Spec coverage of the sys face. | **RESOLVED: pin the register/observable contract, not kernel behavior.** | A real syscall is not a pure transition; the spec pins what crosses (the `obs-sys` observable: number + args) and the register contract, not the kernel's internal effect. |

No NEEDS-AUTHOR blockers (the branch is provisional-but-working, per the author).

## 4. Change plan (ordered, commit-sized)

### Step 1 — `lib/tal-spec.chiral`: the spec's data shape
- **Target:** `lib/tal-spec.chiral` (NEW).
- **Change:** the vocabulary from example §5 — `Obs` (obs-val / obs-halt /
  obs-sys), `SpecEntry` (name + total-pure `sem` transition + pinned vectors),
  `Verdict` (admitted / diverged), `conform` declaration. Total, pure, loads
  clean.
- **Size:** ~M.

### Step 2 — exemplar entries seeded from the corpus
- **Target:** `lib/tal-spec.chiral` (entries) + a minimal `MState`.
- **Change:** two entries — `div` (the Euclidean/SMT-LIB sign grid incl.
  INT_MIN/-1 → wrapped INT_MIN and /0 → the fatal alarm, transcribed from the
  existing division differential) and a byte op (`bput`/zero-read). Vectors are
  the exact input/observable pairs the current tests assert.
- **Size:** ~M.

### Step 3 — `docs/tal-spec.md`: the prose anchor
- **Target:** `docs/tal-spec.md` (NEW).
- **Change:** the human-readable per-entry semantics + observables for the
  exemplars, written as the weekend-auditable definition; the data form (Step 1)
  references it. Marked provisional.
- **Size:** ~M.

### Step 4 — rewrite `docs/floor-agreement.md`'s Statement section
- **Target:** `docs/floor-agreement.md`.
- **Change:** replace the reference-is-golden body with spec-as-golden (the
  reference demoted to first-among-producers; divergence from the spec is
  *investigated*, not auto-ruled against either side); keep the provisional
  framing until ratification. The agreement mechanism text is unchanged.
- **Size:** ~S.

## 5. Conformance gate

- **Golden behavior:** every observable the current differential suite checks is
  **derivable from a spec vector** — the existing tests become the spec's seed
  corpus, so the restructure changes the anchor with **zero passing tests
  changed**. `lib/tal-spec.chiral` loads, is total/pure, and its exemplar vectors
  match the live division + byte-cell observables.
- **Tests to add (`scaffold/tests/test_tal_spec.py`, NEW):**
  1. **Load + totality:** `lib/tal-spec.chiral` elaborates and its `sem`/entries
     are total-pure (the spec is category-A).
  2. **Corpus agreement:** each exemplar vector's observable equals what the
     reference floor produces on that input (division sign grid + byte zero-read)
     — the spec and the reference agree on the seed corpus.
  3. **`conform` shape:** a deliberately-wrong executor (one entry perturbed)
     yields `diverged` naming the entry; a matching one yields `admitted`.
- **Green line:** 404 → **≥ 407** (the post-E69 baseline; the spec's original
  390 predates E69's closure-conversion + q=0 tests); `ledger-lint` clean; **no
  existing test changes** (the anchor moved, behavior did not).
- **Done when:** the division + byte-cell observables are pinned as spec vectors
  that the reference floor satisfies, and `floor-agreement.md` reads
  spec-as-golden (provisional).

## 6. Residue & links

- **Deliberately unbuilt (each with its home):**
  - *Ratification* — the owed author call; does not gate this work (E72 is its
    strongest argument).
  - *Complete per-instruction coverage* — grows by the "new instruction = new
    entry first" rule (§3 #3).
  - *The executable-spec runner* — `conform` as tooling; follow-on.
  - *Final `MState` shape* — incremental (§3 #4).
  - *Sysface × E70 row shadow* — → [[E70-effectful-lowering]].
- **Follow-on / links:** [[E72-re-bootstrap]] (consumes this spec — the climb's
  golden object; E72 is unbuildable without it), [[E15-reference-interpreter]]
  (demoted to first-among-producers), [[E18-tal-check]] (the checker beside the
  semantics), [[E53]] (DDC climbs against it), `docs/floor-agreement.md` (the
  note restructured), `docs/chirality-division-euclidean` (the precedent), D7/edge 11
  (where correlated agreement remains, honestly, for the floor's *executors*).
