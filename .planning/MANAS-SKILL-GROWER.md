# manas skill-grower — tiny-step / branch⇄backtrack model (2026-08-17, rev2)

> **rev2 supersedes rev1.** rev1 treated experts as single coarse agents and read
> `branch` as "more agents in parallel". Both wrong (user correction). Corrected model
> below. The north star: **decompose so hard that tiny models suffice.**

## The invariant
**No big questions.** Every unit of work is a **tiny step**: one small question +
context on all sides (`sees`) + a small typed return, sized for a *tiny* model. If a
step needs a big model, it is not decomposed enough — that is a defect, not a config
choice.

## The atom + operators
- **Step (atom):** one tiny model call. `question` (small) · `sees` (rich context on
  all sides) · `returns` (small typed). Runs on a tiny model.
- **chain:** tiny steps in sequence (output → next input).
- **fan-out:** tiny steps in parallel on the same input (cheap redundant checks), merged.
- **branch ⇄ backtrack (the fractal pair):**
  - **branch** — *expand*: re-frame the thing into a dynamic set of **perspectives**
    (different question-sets / lenses). **Each perspective is a sub-pipeline** (recursion).
  - **backtrack** — *contract*: a **paired** pipeline that does per-branch
    **consolidation + audit** of that branch's individual results. Itself tiny-stepped.
- **Recursion:** a branch *is* a pipeline; pipelines nest. Perspectives all the way down.

A skill is a **fractal**: chains of tiny steps, expanded by branches into perspective
sub-pipelines, each contracted by a consolidate+audit backtrack.

## Re-decomposition example (why "one expert" is wrong)
`edit-apply` is NOT one agent. It is:
- **chain:** claim(passage) → spec-point(here) → locate-mismatch → draft-minimal-edit → preserves-surrounding?
- **branch** over perspectives: {naive-reader, accuracy-reviewer, style-consistency}, each a tiny-step sub-pipeline.
- **backtrack** per branch: consolidate the perspective's findings + audit (edit fixes the mismatch? no collateral?).
Every question small; `sees` populated on all sides.

---

## L0 — Model additions (MUST come first — the flat `Pipeline` can't express this)
| # | Primitive to add | Why | Current gap | Touches |
|---|---|---|---|---|
| 1 | **Recursive Step** (a step can be a Pipeline) | branch = sub-pipeline; nesting | `Pipeline` = flat `(List Str)` of expert ids | core/types + engine |
| 2 | **Branch⇄Backtrack pairing** | matched expand/contract; audit is not optional | one `COMBINER`, no pairing | core/types + runner |
| 3 | **Audit step** (≠ combine) | consolidate ≠ check | combiner merges; nothing audits | types + a slot |
| 4 | **Perspective generator** (emits dynamic (question,perspective) set) | branch fans over perspectives | nothing produces them | types + a step role |
| 5 | **Tiny-step contract + lint** | enforce "no big questions"; rich `sees` | `sees` prose, no size check | a lint + the editor |

## L1 — Operators / ORDER (re-cast — this is engine work, was "3D")
| Operator | Now | Corrected meaning | Effort |
|---|---|---|---|
| fan-out | live (fires all once) | tiny steps in parallel, merged | ✓ |
| chain | inert | tiny steps in sequence, output→next | engine |
| **branch** | inert (mis-modeled) | expand into perspective **sub-pipelines** (recursion) | engine + L0.1 |
| **backtrack** | absent | paired consolidate+audit per branch | engine + L0.2/3 |
| STOP loop | inert | loop capped/until-dry at any level | engine |

## L2 — Slots (capability classes; still bind via Config)
Each is a tiny-step role, not a mega-agent.
| Slot | Tiny-step role | Status |
|---|---|---|
| cheap-verifier / reasoner / combiner | small check / small reason / small merge | ✓ |
| **auditor** ⊕ | check one branch's consolidated result (tiny) | ✗ (L0.3) |
| **perspectivist** ⊕ | emit the next (question, perspective) | ✗ (L0.4) |
| editor ⊕ / code-context ⊕ / author ⊕ | produce edit / read code idiom / draft a Part | ✗ |

## L3 — The skill-grower (produces FRACTAL compositions, safely)
| Piece | What | Builds on | Status |
|---|---|---|---|
| Skill = persisted fractal | nested pipeline+parts, named | persistence P1–P4 + L0.1 | ~ (needs recursion) |
| duplicate(skill) | clone a fractal under a new id | codec + library | ✗ small |
| **specialize(skill, ctx)** | narrow the *questions + sees* of the clone for a context (NOT swap one agent) | duplicate + N2 edits | ✗ core |
| **tool-builder** | a fractal that *emits tiny-step compositions as JSON parts* | pipelines + L0 + N4 | ✗ |
| **accept-gate** | decode (P1, rejects malformed) → compile → **tiny-model-green** → into library | L4 | ✗ wire |

## L4 — Safety + the tiny-model gate ("safely develop" + the north star)
| Gate | Mechanism | Status |
|---|---|---|
| well-formed Part | P1 total decoders reject malformed JSON | ✓ |
| compiles / runs | B1 + PTY/mesh harness | ✓ |
| **TINY-MODEL GREEN** | every step passes on smoke-local (0.5b); a step needing a bigger model = under-decomposed = reject | ✗ (the key new CI) |
| least-privilege | `Expert.tools` enforced per slot | ~ typed |
| membrane | a writing editor/builder needs an explicit capability, not ambient | ✓ membrane, ✗ wired |
| reviewed | `auditor` step + accept step | ✗ |

## L5 — Content (fractal, not single agents)
| Skill | Kind | Shape | Status |
|---|---|---|---|
| doc-refine | leaf | existing | ✓ |
| **doc-edit** | TEMPLATE | fractal: chains + perspective-branches + audit-backtracks | ✗ |
| doc-edit@\<context\> | specialization | same fractal, narrowed questions/sees | ✗ produced |
| **tool-builder** | TEMPLATE (meta) | fractal that emits tiny-step compositions | ✗ |
| tool-builder@\<project\> | specialization | narrowed to capture project language/code in `sees` | ✗ produced |

---

## Build order (dependency-true)
1. **L0.1 Recursive Step** + **L0.2/3 Branch⇄Backtrack + Audit** in core/types + runner
   (this re-opens the "complete" manas core — the vision now exceeds it).
2. **L1** actuate chain / branch(recursion) / backtrack / STOP-loop in the engine.
3. **L0.4 perspective generator** + **L0.5 tiny-step lint** + the `auditor`/`perspectivist` slots.
4. **specialize + duplicate** (L3) — the reuse engine, on the now-recursive Skill.
5. **doc-edit** template as a fractal + one specialization — proves object-level.
6. **tool-builder** emitting JSON compositions + **accept-gate incl. TINY-MODEL-GREEN** — safe agent-authoring.
7. **tool-builder@project** — the meta recursion.

Steps 1–3 are the honest core: the model must grow recursion + branch⇄backtrack +
audit before any fractal skill can be authored. Everything downstream (specialize,
doc-edit, tool-builder) then composes on top, gated by tiny-model-green.

## ⚑ L0 ENGINE COMPLETE 2026-08-17 (slices 1–5, `MANAS-L0-SPEC.md`) — remaining slices
The typed recursive Flow engine (compose/type-check/run/loop/tiny-model-green) is DONE +
live-verified + additive. Remaining work = the skill-grower layer ON the engine, then
scriba. Serial, verify+fold each (the established cadence):
- **SG1 — Flow persistence. ✅ DONE 2026-08-17.** `flow->json`/`json->flow` (+ `ty`/`arrow`
  codecs), total + recursive over Flow+Ty+Arrow, in `scaffold/lib/manas/core/flow-persist.chiral`
  (additive; reuses P1's `gate-list->jsons`/`jsons->gate-rules` + `json.chiral`). Schema keyed by
  `"kind":"step|gate|fan|chain|branch"`; Ty = bare tag string; Arrow = `{dom,cod}`. Round-trip
  fixpoint over a hand-built NESTED Flow (branch→chain→fan/step + gate) + 3 negatives (missing
  kind / unknown kind / child-missing-field → `none`) pass green (`flow-persist-test.chiral`,
  exit 0); emitted JSON validated by python `json.load` oracle. Enables save/load/duplicate/
  specialize + scriba-load.
- **SG2 — duplicate + specialize. ✅ DONE 2026-08-17.** `scaffold/lib/manas/core/skill.chiral`
  (additive). A `Skill` = `skill-base(name,Flow,StopPolicy)` | `skill-spec(name,base,context)`;
  **specialize = CONTEXT INJECTION** (a thin `(base,context)` ref, NOT agent-swapping).
  `resolve-skill` follows the base chain, accumulating contexts base-inward→outward
  (fuel-bounded by library size → cycle/missing = honest `none`, no hang); `duplicate-skill`
  clones under a new name; `specialize-skill (base new ctx)` mints a spec; `run-skill` injects
  the resolved contexts as `context-N` pairs into `extra` → `run-flow-stop` folds them into
  EVERY step's prompt (call-expert/assemble-prompt). `skill->json`/`json->skill` total codec
  (reuses SG1 `flow->json`/`json->flow` + P1 `stop->json`/`json->stop`). Composes: specialize a
  specialization → contexts accumulate. PURE test (`skill-test.chiral`: resolve chain+order,
  missing→none, cycle-safe, duplicate, round-trip) exit 0; LIVE sample (`manas-skill-live.chiral`,
  mesh 0.5b) proved `CONTEXT-MARKER-XYZ` present in a sent prompt (6 experts fired), exit 0.
- **SG3 — doc-edit template + one specialization. ✅ DONE 2026-08-17.**
  `scaffold/lib/manas/profile/doc-edit.chiral` (additive, parallel to doc-refine — untouched).
  A real FRACTAL `doc-edit-flow` = `flow-branch(doc-edit-perspectivist ty-doc,
  per-perspective = flow-chain[doc-edit-proposer(editor)→ty-patch, doc-edit-checker(reasoner)→ty-verdict],
  backtrack = flow-chain[doc-edit-consolidate(combiner)→ty-patch, doc-edit-audit(auditor)→ty-verdict])`.
  5 tiny-step Experts (`doc-edit-pool`), each lens ONE small ask → `lint-pool` ALL CLEAN;
  `flow-ty doc-edit-flow` = `some (arrow ty-doc ty-verdict)`. `doc-edit-config` binds all 5
  slots (perspectivist/editor/reasoner/combiner/auditor) to `qwen2.5:0.5b`. PRODUCES proposed
  edits (applying them = the deferred write effect, L6 — every expert read-only). PURE gate
  `doc-edit-test.chiral` (flow-ty arrow + lint all-clean) exit 0. LIVE gate
  `samples/manas-doc-edit-live.chiral` on the mesh 0.5b: (a) `run-flow-stop doc-edit-flow
  (stop-single)` → `manifest-all-green? = true`, calls = 1+2N+2 = 19 (N=8 angles, fractal
  executed: perspectivist + 16 per-angle + 2 backtrack); (b) `specialize-skill "doc-edit"
  "doc-edit-tutorial" "CONTEXT: editing a step-by-step TUTORIAL"` + `run-skill` → green AND
  the tutorial context string PRESENT in a sent prompt (reached the model). exit 0. Proves
  object-level template→specialize on the L0 engine.
- **SG4 — tool-builder + accept-gate. ✅ DONE 2026-08-17.**
  `scaffold/lib/manas/core/builder.chiral` (additive). **`accept-gate : (-> Str (Maybe Flow))`**
  is THE WALL: `json-parse-str` → `json->flow` (SG1, rejects malformed/unknown-kind) →
  `flow-ty` (rejects a structurally-valid but ILL-TYPED Flow) → `(some flow)`; any failure →
  `none`. TOTAL (three nested Maybe folds, no crash path). Agent output is never trusted, only
  decoded + typed. The deeper runtime gate = tiny-model-green (`run-flow-stop` + `manifest-all-green?`,
  reused from SG3) is the follow-on check; the static decode+flow-ty gate is SG4's core.
  `tool-builder-flow` = `flow-step "tool-builder-author" ty-doc ty-part` (lint-clean tiny author
  step) + `tool-builder-config` (author slot → `qwen2.5:0.5b`). PURE gate `builder-test.chiral`:
  ACCEPT a known-good aligned chain (+ flow-ty of the result = some), REJECT malformed JSON,
  REJECT unknown-kind, REJECT an ill-typed chain (`ty-doc→ty-findings` then `ty-doc→ty-patch` —
  decodes fine, flow-ty rejects: THE key safety proof) — exit 0. LIVE gate
  `samples/manas-builder-live.chiral` on the mesh 0.5b: the author emitted 170 chars of
  prose/partial JSON, `accept-gate` REJECTED it (`none`) = the wall CORRECTLY protecting the
  library — exit 0 (honest, no faked accept). HONEST FINDING: emitting a WHOLE valid+typed Flow
  in one author step likely needs a bigger model OR the builder decomposing the emit into tiny
  sub-steps (a fan of {kind}/{arrow}/{child} sub-emits) — future work, SG-later.
- **SG5 — tool-builder@\<project\>. ✅ DONE 2026-08-17.** The META recursion: the SAME
  `specialize-skill` (SG2) that narrowed the OBJECT-level doc-edit per doc-context (SG3),
  applied ONE LEVEL UP to the tool-builder (SG4) — no new mechanism. Additive helper
  **`project-builder : (-> Str Str Skill)`** = `(specialize-skill "tool-builder" new-name
  project-context)` in `scaffold/lib/manas/core/builder.chiral` (builder now imports
  `prapanca/core/skill`; no cycle — skill never imports builder). `run-skill` injects the
  project context (language/code idioms) into the author step's prompt via the `extra`
  channel, identical to the object-level path. PURE gate `builder-sg5-test.chiral` (library =
  `[skill-base "tool-builder" tool-builder-flow (stop-single), project-builder
  "tool-builder@chirality" "PROJECT: chirality; code idiom marker PROJ-MARKER-abc"]`): `resolve-skill
  "tool-builder@chirality"` = `some` carrying the BASE tool-builder Flow AND a contexts list
  CONTAINING the project string; a spec over an absent base = honest `none` — exit 0. LIVE
  gate `samples/manas-project-builder-live.chiral` on the mesh 0.5b: `run-skill
  "tool-builder@chirality"` → grep the run's raws (sent prompts) for `PROJ-MARKER-abc` = **true**
  (the project context reached the author step ⇒ the builder is specialized PER PROJECT = the
  meta recursion). The author emitted 133 chars of prose; `accept-gate` REJECTED it (`none`)
  = SG4's known finding (a 0.5b rarely emits a whole valid+typed Flow), NOT the SG5 criterion
  — exit 0. Proves the specialize mechanism composes at the meta level, the recursion the
  whole vision hinges on.
- **SG6 — scriba loads + renders a Flow. ✅ DONE 2026-08-17** (Option A). Via SG1, scriba loads
  a saved Flow and renders it as a nested outline, READ-ONLY (native authoring = a later arc).
  `TUI/scriba/flow-view.chiral` (additive): **`flow-outline-nodes : (-> Flow (List OutlineNode))`**
  — a PURE, total flatten of the recursive Flow tree into the S14 `OutlineNode` shape
  (depth + label per node: `step:<id>` / `gate:<combiner>` / `fan:<combiner>` / `chain` /
  `branch:<perspectivist>`; a branch's two sub-flows sit under labelled
  `per-perspective:`/`backtrack:` headers; composites indent depth+1) + `flow-view-render`
  (pure Rendering, reuses the S14 `mf-row`/`mh-row` faces). command-loop imports
  `prapanca/core/flow-persist` (SG1 `json->flow`) + `flow-view`; a **`:flow <path>`** arm
  (`flow-load-view`, sibling of `manas-load-doc`) reads (load-bytes) → parses (json-parse) →
  decodes (json->flow, total — rejects malformed/unknown-kind) → flattens + paints, landing in
  Normal with the fractal on screen + a status line; any stage failure beeps + paints the
  stage error. NO manas-core / doc-refine change. One scriba-side collision renamed
  (test-local `nth-node`→`tv-nth`). Committed sample `scaffold/samples/demo.flow.json` (a
  branch→chain→fan/step + backtrack chain→gate/step fractal, emitted by `flow->json`+`json-show`
  via B1, python `json.load`-validated). Gates: PURE `flow-view-test.chiral` asserts the 11
  expected depth+label nodes (exit 0); PTY (committed resolve, scriba **1102200 B**, was
  1044856) `:flow scaffold/samples/demo.flow.json` rendered the full indented nested tree; the
  error path (`:flow setups/index.json`, valid JSON but not a Flow) surfaced "not a Flow: …".
- **FIX (2026-08-17) — flow-branch no longer SILENTLY SWALLOWS a dropped angle.** `branch-run`
  ran each per-perspective sub-flow and flat-concatted its (possibly EMPTY) manifest + yield,
  continuing even when a sub-run REFINE-FAILED/errored (empty manifest, zero calls) — and
  `manifest-all-green?`, reading only the composite, returned `true` on a silently-dropped
  branch (a green lie the tiny-model gate must never tell). Now: `perspective-failed? :
  (-> RunManifest Bool)` (zero calls OR an error-marked routing = `flow-refine-fail` /
  `no-expert` / `unbound` / `flow-chain-empty` / `no-perspectives`) detects a dropped angle;
  `BranchFold` carries a `dropped Bool` (OR-accumulated across perspectives); the `flow-branch`
  composite's routing goes HONEST (`"flow-refine-fail:branch-drop"`) when any angle dropped, so
  the EXISTING `manifest-all-green?` check already reads `false` — no gate weakening, output
  still produced (no halt). Behavior-only, `Flow`/`Ty` untouched. PURE test (`flow-test.chiral`):
  `perspective-failed?` true on zero-call/error-routed manifests, false on a clean ≥1-call run;
  `manifest-all-green?` = false on a drop-tagged composite (even with all-green calls), true on
  a clean branch. Regression: doc-refine `CONFORM: true`, branch-live (8 calls, no false drop),
  green-live (accept green / reject non-green) all still exit 0.

## ⚑ TEMPLATE LIBRARY (2026-08-17) — a diverse set of specializable fractal skills
Hand-authored fractal skills (like SG3's doc-edit), each built at the NARROW-LINE-OF-THOUGHT
grain (one focused reasoning move per leaf — NOT a token; over-fine starves the transformer,
over-coarse drowns it). Shared shape: `branch(reason the angles) → per-angle chain[one narrow
reasoning move → one narrow check] → backtrack chain[consolidate → audit]`. Each lint-clean,
tiny-model-green on 0.5b, ships with one specialization (SG2 context injection).
- **T0 doc-edit** — DONE (SG3, `154f8c3`).
- **T1 code-test** — ✅ DONE 2026-08-17. `scaffold/lib/manas/profile/code-test.chiral`
  (additive, parallel to doc-edit — untouched). Fractal `code-test-flow` =
  `flow-branch(code-test-perspectivist ty-doc, per-perspective = flow-chain[code-test-reasoner
  (reasoner)→ty-text, code-test-proposer(editor)→ty-patch], backtrack = flow-chain[
  code-test-consolidate(combiner)→ty-patch, code-test-audit(auditor)→ty-verdict])`. 5
  narrow-line-of-thought Experts (`code-test-pool`), each lens ONE reasoning move → `lint-pool`
  ALL CLEAN (0 flags); `flow-ty code-test-flow` = `some (arrow ty-doc ty-verdict)`.
  `code-test-config` binds all 5 slots to `qwen2.5:0.5b`. PURE gate `code-test-test.chiral`
  (flow-ty arrow + lint all-clean) exit 0. LIVE gate `samples/manas-code-test-live.chiral` on
  the mesh 0.5b: (a) `run-flow-stop code-test-flow (stop-single)` on a `clamp()` snippet →
  `manifest-all-green? = true`, calls = 1+2N+2 EXACTLY across runs (N∈{6,19} observed); (b)
  `specialize-skill "code-test" "code-test-unit" "CONTEXT: generate UNIT tests only, one
  assertion each"` + `run-skill` → green AND the unit context string PRESENT in a sent prompt.
  exit 0. HONEST FINDING (drove a seam fix): typing the reasoner's free-reasoning output
  `ty-findings` (strict validator: demands `[`/`kind`) made a 0.5b's intermittent prose output
  refine-FAIL the seam, and the branch SILENTLY SWALLOWED that per-angle chain (empty-manifest,
  routing lost) so the angle vanished while `manifest-all-green?` still read true off the
  composite — a genuine engine blind spot. Fix: the reasoner emits a narrow reasoning move as
  PROSE, typed `ty-text` (lenient, doc-edit's proven-green seam), so every angle completes and
  the call count is deterministic. Specialize → test type (unit/property/regression).
- **T2 research** — ✅ DONE 2026-08-17. `scaffold/lib/manas/profile/research.chiral`
  (additive, parallel to evidence-sift/code-test/doc-edit — untouched). Researches a question
  by decomposing it into angles and synthesizing. Fractal `research-flow` =
  `flow-branch(research-perspectivist ty-doc {definitions·prior-art·counter-evidence·
  open-questions}, per-angle = flow-chain[research-investigate(reasoner)→ty-text,
  research-assess(auditor)→ty-verdict], backtrack = flow-chain[research-synthesize(combiner)
  →ty-findings, research-audit(auditor)→ty-verdict])`. 5 narrow-line-of-thought Experts
  (`research-pool`), each lens ONE reasoning move → `lint-pool` ALL CLEAN (0 flags); `flow-ty
  research-flow` = `some (arrow ty-doc ty-verdict)`. `research-config` binds the four used slots
  to `qwen2.5:0.5b`. Same proven-green seam as T1/T3: the reasoner emits PROSE typed `ty-text`
  (a strict `ty-findings` seam refine-fails a 0.5b's prose + the branch would swallow the angle);
  the combiner's by-angle synthesis IS `ty-findings`. PURE gate `research-test.chiral` (flow-ty
  arrow + lint all-clean) exit 0. LIVE gate `samples/manas-research-live.chiral` on the mesh 0.5b
  over a research question: (a) `run-flow-stop research-flow (stop-single)` →
  `manifest-all-green? = true`, calls = 1+2N+2 EXACTLY (N=22 observed → 47 calls — HONEST green:
  the branch-drop fix 139ded7 makes a swallowed angle read non-green); (b) `specialize-skill
  "research" "research-feasibility" "research type: FEASIBILITY ..."` + `run-skill` → green AND
  the FEASIBILITY research-type context PRESENT in a sent prompt. exit 0. Specialize → research
  type (lit-review/comparison/feasibility).
- **T3 evidence-sift** (THE key primitive) — ✅ DONE 2026-08-17.
  `scaffold/lib/manas/profile/evidence-sift.chiral` (additive, parallel to code-test/doc-edit —
  untouched). Separates solid EVIDENCE from a prior cheap pass's "possibly-relevant" speculation
  into TWO SEPARATE TRACKS, at a reference level, WITHOUT merging or discarding either. Fractal
  `evidence-sift-flow` = `flow-branch(evidence-sift-perspectivist ty-doc, per-perspective =
  flow-chain[evidence-sift-reasoner(reasoner)→ty-text, evidence-sift-classify(auditor)→ty-verdict],
  backtrack = flow-chain[evidence-sift-consolidate(combiner)→ty-findings, evidence-sift-audit
  (auditor)→ty-verdict])`. 5 narrow-line-of-thought Experts (`evidence-sift-pool`), each lens ONE
  reasoning move → `lint-pool` ALL CLEAN (0 flags); `flow-ty evidence-sift-flow` = `some (arrow
  ty-doc ty-verdict)`. `evidence-sift-config` binds the four used slots (perspectivist/reasoner/
  combiner/auditor — auditor used twice: per-item classify + boundary audit) to `qwen2.5:0.5b`.
  The reasoner emits PROSE typed `ty-text` (the code-test finding — a strict `ty-findings` seam
  refine-fails a 0.5b's prose + the branch would swallow the angle); the combiner's two-track
  split IS `ty-findings` (the runner asks every leaf for a JSON array of {kind,target,body}, so a
  "sort into two lists" ask lands JSON-ish + passes). PURE gate `evidence-sift-test.chiral`
  (flow-ty arrow + lint all-clean) exit 0. LIVE gate `samples/manas-evidence-sift-live.chiral` on
  the mesh 0.5b over a MIXED text (2 cited/recorded items = evidence, 2 associations =
  speculation): (a) `run-flow-stop evidence-sift-flow (stop-single)` → `manifest-all-green? = true`,
  calls = 1+2N+2 EXACTLY across runs (N∈{6,7} observed — HONEST green: the branch-drop fix 139ded7
  makes a swallowed angle read non-green); (b) `specialize-skill "evidence-sift"
  "evidence-sift-rigorous" "reference level: RIGOROUS - evidence must cite a source"` + `run-skill`
  → green AND the RIGOROUS reference-level context PRESENT in a sent prompt. exit 0. Specialize →
  reference level (loose/rigorous).
- **T4 decision** — ✅ DONE 2026-08-17. `scaffold/lib/manas/profile/decision.chiral`
  (additive, parallel to research/evidence-sift/code-test/doc-edit — untouched). Weighs a
  decision by fanning over its CRITERIA. Fractal `decision-flow` =
  `flow-branch(decision-perspectivist ty-doc {each criterion}, per-criterion =
  flow-chain[decision-assess(reasoner)→ty-text, decision-score(auditor)→ty-verdict],
  backtrack = flow-chain[decision-weigh(combiner)→ty-findings, decision-audit(auditor)
  →ty-verdict])`. 5 narrow-line-of-thought Experts (`decision-pool`), each lens ONE reasoning
  move → `lint-pool` ALL CLEAN (0 flags); `flow-ty decision-flow` = `some (arrow ty-doc
  ty-verdict)`. `decision-config` binds the four used slots to `qwen2.5:0.5b`. Same proven-green
  seam: the reasoner emits PROSE typed `ty-text`; the combiner's cross-criterion recommendation
  IS `ty-findings`. PURE gate `decision-test.chiral` (flow-ty arrow + lint all-clean) exit 0.
  LIVE gate `samples/manas-decision-live.chiral` on the mesh 0.5b over an editor undo-stack
  decision (options A/B/C): (a) `run-flow-stop decision-flow (stop-single)` →
  `manifest-all-green? = true`, calls = 1+2N+2 EXACTLY (N=6 → 15 calls); (b) `specialize-skill
  "decision" "decision-risk-first" "decision lens: RISK-FIRST ..."` + `run-skill` → green AND the
  RISK-FIRST decision-lens context PRESENT in a sent prompt. exit 0. Specialize → lens
  (risk/cost/user-first). **Template library T0–T4 COMPLETE.**
Ty: reuse existing (ty-doc/findings/verdict/text) where sensible; add extensible Ty variants
where a real type helps compose. Each = one SG3-style build + a specialization, serial.

## ⚑ REFINEMENT PASS (2026-08-17) — a tiny model shouldn't REASON; it should TRANSFORM
Playing with the T-skills on the mesh exposed that they run green on 0.5b but produce
shallow/wrong CONTENT (research synthesis inverted "Rust has a GC"; decision output was
hallucinated garbage). The reflex fix — "0.5b too weak → use a bigger model" — is the **SG4
anti-pattern** (can't-do = decompose MORE, never up-model). The real diagnosis (user):
*a leaf that needs reasoning is under-decomposed.* The dividing line is **not big-vs-small** but
**text-understanding vs symbol-manipulation**, and it is MEASURED on the 0.5b:
- **read text → a fact** (extract / quote / presence-check): irreducibly linguistic, a 0.5b is
  RELIABLE (5/5 on "does this text say X? y/n").
- **match / select / map / score / rank / aggregate / verdict**: pure symbol-manipulation; routed
  through a 0.5b it COIN-FLIPS (1/5 on a two-arm rubric). Routing it through the model
  re-introduces the exact reasoning failure you just decomposed away.
So: **the model does ONLY the text→fact transform; every DECISION over those facts is CODE.**
"The composition does the hard part" is really *the composition does the DECIDABLE part; the model
does only the linguistic part.* The rubric/criterion lives in code, never in a prompt.

**The engine gap this exposed + closed — `flow-pure` (`8060a3a`):** every Flow step was a model
call — the engine's only tool was "call a model," so the auditor(verdict)/combiner(consolidate)
slots were symbol-manipulation forced through a 0.5b. Added a **`flow-pure`** step: a
deterministic `payload→payload` transform (no backend), carrying a **closed-sum `PureFn`** value
(so the SG1 codec stays total — boundary-as-closed-sum, NOT a raw closure). run-flow executes it
threading the linear Backend untouched + one synthesized green call (1+2N+2 + manifest-all-green?
intact). PROVEN on `evidence-sift-refined.chiral`: the per-item classify split into EXTRACT (model,
ty-text) → DECIDE (flow-pure, citation-marker scan → evidence|speculation). `manas-evidence-sift-
refined-live.chiral` exit 0 — OFFLINE the code decider is **4/4 correct + deterministic** (was a
model coin-flip), codec round-trips flow-pure; LIVE the fractal runs `manifest-all-green?=true` on
0.5b with the model doing ONLY extraction.

**The refinement-pass PROCEDURE (mechanical, apply to every leaf):**
1. Ask: text-understanding or symbol-manipulation?
2. Symbol-manipulation → replace the model `flow-step` with a **`flow-pure`** code step (the
   match/map/score becomes a `case`; extend `PureFn` with a constructor if needed — additive).
3. Text-understanding → narrow to a SINGLE fact extraction; if it needs a fact **not in `sees`**,
   the pipeline is missing a **supply/retrieval stage** — no grain manufactures absent knowledge
   (this is the honest limit on **research/decision**: they assume the model KNOWS the domain; the
   un-decomposed core is the missing evidence-gathering front, NOT leaf size).
4. Repeat until every model leaf is a single-fact extractor and every judgment is code.

**COMBINER + AUDITOR carried to code (`803d986`):** evidence-sift-refined's backtrack is now
code too — `pf-tally` (count the code-structured per-item verdicts into two tracks) for the
combiner, `pf-all-present` (structural invariant: both tracks produced) for the auditor. Two more
PureFn constructors + codec. Live on 0.5b: the tally is a correct deterministic count (evidence=5,
speculation=9, sum=N=14), audit "consistent", manifest-all-green?=true. **Evidence-sift is now the
full exemplar: the ONLY model calls are the perspectivist + N extracts; EVERY decision is code.**
An honest side-finding: code-decide wants STRUCTURED inter-leaf payloads, not the join-individuals
STRING (pf-tally counts substrings because the verdicts arrive concatenated) — typed structured
payloads between leaves is the clean version, a deeper engine improvement.

**⚑ PROPER TESTING (span-by-span, not just green) exposed real bugs (`7fa4bec`/`595cb96`):**
manifest-all-green? is a PLUMBING gate — dumping each live span→verdict showed the model EXTRACT
leaf failed on 0.5b ~3/4 (empty `[]`/`{}`/meta) and SILENTLY defaulted to `speculation`. Fixes:
(a) per-item extraction is now a PURE string op (`pf-line-after` pulls the perspectivist-isolated
"Perspective:" line — no model to fail; empty → refine-fails visibly, no silent default);
(b) `parse-perspectives` made ROBUST — the 0.5b emits malformed multi-line JSON whose parse fails
and the old line-fallback SHREDDED it into junk perspectives; now it recovers each `"target"`/
`"body"` value and skips structural lines. Testing also caught a **SEGFAULT** — `str-sub` is
`(str START END)`, I'd passed `(START LEN)`; START>value → out-of-bounds read. Deterministic
regression `manas-parse-robust-test.chiral` guards both. **Verified:** parse recovers 4/4 real
items from the exact malformed shape (zero junk); live, every extracted item classifies correctly.
**HONEST CEILING:** the pipeline is now robust + correct PER ITEM, but end-to-end COMPLETENESS is
bounded by the **perspectivist** — a 0.5b mangles the document→item-list split (garbled fragments,
1–3 of 4 items/run). That is the irreducible model text-understanding step (kept by choice); making
IT reliable is the real open problem, likely wanting its own decomposition.

**⚑ PERSPECTIVIST CEILING RESOLVED for structured input (`dd754ee`):** the doc→item split is
text-understanding ONLY for unstructured prose; evidence-sift's input is a numbered LIST, so the
split is a string op. Added **`flow-branch-pure`** — a branch whose perspectivist is a `PureFn`
(`pf-split-numbered`) instead of a model expert (full Flow surface: ctor + flow-ty/out-ty/id +
runtime arm reusing branch-run/backtrack + codec). evidence-sift-refined now uses it → the WHOLE
fractal is MODEL-FREE and **end-to-end CORRECT + deterministic**: all 4 items recovered verbatim,
classified right, tally EXACTLY evidence=2/speculation=2, audit consistent, all-green (the sample
asserts that partition mesh-free). This is the refinement pass taken to its limit — for a fully
structured task the composition does ALL of it, the model isn't needed. `flow-branch` (model
perspectivist) + robust `parse-perspectives` STAY for genuinely-unstructured prose (both paths kept).

**REMAINING (mint before deferring):** (1) apply the pass to the OTHER T-skills' combiner/auditor
slots (code-test/research/decision — mechanical, mirror evidence-sift). (2) the supply/retrieval
front research/decision need — un-decomposed CORE is missing knowledge (a fact a leaf can't see
can't be extracted); NOT live-testable in ccbox (egress blocked) but the SUPPLY half (inject
provided material into `sees`, extract) IS locally testable. All on the flow-pure substrate.
