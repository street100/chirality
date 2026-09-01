# Chatter → functioning divide-and-conquer chat — sliced fix plan + dispatch handoff (2026-08-19)

**Read this to ORCHESTRATE.** A fresh chat can start dispatching agents from this doc
alone (plus the companions below). It slices the real fixes into commit-sized,
agent-dispatchable units, orders them by de-risk-first, names the decisions that gate
code, and states the dispatch discipline. Every claim here traces to this session's
verified work (the diagnosis + the three alignment audits), not aspiration.

## Companions (read in this order)
1. `CHATTER-MIX-MAP.md` — AI = ports (typed protocol + closed-sum egress parsed at the
   boundary); code = the typed spine. The M1/M2/M3 vocabulary the fixes use.
2. `CHATTER-FLOW-MAP.md` — the target shape: turn = DIVIDE→PARALLELIZE→CONSOLIDATE, with
   attenuated context grants. Includes the fine-grain worked trace.
3. `CHATTER-QUALITY-DIAGNOSIS.md` — the measured finding that anchors F1 (bigger skill
   model does NOT fix the answer; the rich sentence is pure-code `pf-tally`; ~1000× slower).
4. `CHATTER-ORCHESTRATOR-SCOPE.md` — the O0–O7 build ledger (what's already built).
5. `CHATTER-STATE.md` — state/handoff + the exact BUILD/TEST RECIPES (do not re-derive).

## Where it stands — ⚑ ARC COMPLETE 2026-08-21 (every slice DONE; both gates resolved)
Nine commits closed the whole ledger: `b0b275b` DC-1b·3 → `5e803ed` DC-1b·4 → `848a68f` DC-1b·5
→ (`95a3534` a core `str-trim` fix it flushed out) → `76a3be2` DC-2a → `fcfeb25` DC-2b →
`7f401fc` DC-3b → `f602386` DC-4a → `cc29ccd` DC-4b → `585de1c` DC-3a.

A message now: **divides** into typed `Chunk`s with marker-derived deps (code-first; the model
port opens only for an unstructured message long enough to plausibly hold two asks) → each chunk
is **assigned** by the code-prior ladder (the model planner sees only the residue) → each
specialist runs on a **min-privilege grant** (its own payload plus its deps' TYPED results —
never a sibling's prose) → each skill's answer is parsed into a closed `SkillEgress` whose
combiner is **CODE** (`pf-collect-angles`) → the lanes **consolidate** over that structure with
degraded lanes NAMED → scriba's transcript **shows the whole shape**, dep arrows included.
Deterministic suite: 13 gates, ~18ms, zero dials. Live: `CONFORM: true`, four skill fractals
all-green on the 0.5b, compound turns fusing both lanes, PTY-verified in the TUI.

*(Historical, for provenance — what this ledger was written against:)* a message → planner picks
**one** skill → that skill runs on **0.5b** → **generic** reply → **slowly**. The fan/consolidate
machinery existed but was never observed firing from a real message; there was **no real divide**
(only syntactic `split-conjunctions`), **no per-specialist context attenuation**, and answers were
quality-blocked by the verbalize↔code-tally coupling.

## GATING DECISIONS — settle these before dispatching the dependent slice
- **D1 (gates F1):** the per-skill **egress contract** — the closed sum each skill's output
  is parsed into at the boundary (e.g. analyze→`findings{ev,spec}`, decide→`{adopt|hold}`,
  research/doc-edit/code-test→?). Author/design call; touches the MoE golden — decide
  deliberately. Until D1, do NOT dispatch F1 implementation.
- **D2 (gated F3): RESOLVED 2026-08-21 (author) — CODE-PRIOR.** Markers decide the cases code is
  sure of; the model planner handles only the residue. Implemented as `Routed`/`routed-of`
  (`router.chiral`) — the posture is a closed VALUE the code cases on, not a convention. See DC-3a.

## DC-0a RESULT (2026-08-20) — measured, GO on single-model fans
Probe: `/api/generate` timing split (load/prompt/eval), CPU-only mesh `100.64.0.5:11434`.
Decisive number: **Ollama keeps exactly 1 model resident** (`/api/ps` — touching qwen3:4b
evicts qwen2.5:0.5b). Therefore every DISTINCT model in a turn = a full reload.
- Same-model fan (5 specialists on 0.5b): **0.82s** total, warm throughout (~0.13s load/call
  after the first). → DC-2a/2b VIABLE **iff all specialists share one model**.
- Cross-model fan (5 distinct models): **40.3s**, 74% pure load; gemma4:12b alone = 27.7s.
  → heterogeneous / **per-skill model-bump fan is NOT viable on Ollama** = a DC-5 dependency.
- **New finding:** the current O6 split (planner/synth `qwen3:4b` ↔ skills `0.5b`) crosses the
  single resident slot **twice per turn** → **~5s pure reload tax every turn** before inference
  (0.5b and 4b cannot co-reside). Left as-is for now (noted, non-blocking); fix = collapse the
  three roles onto one model, or accept the tax, or fold into DC-5 co-residence.
Verdict: **GO** on the fan shape, constrained to single-model fans. Hold model-diverse fans
behind DC-5. F2 build (DC-2a/2b) is NOT invalidated.

## Slices (dispatch one at a time; ✎ = needs a decision first)

### Wave 0 — de-risk (cheap, do FIRST; mostly measurement/decision, not big builds)
- **DC-0a — F6 latency measurement.** Drive the mesh: measure per-call model **load** vs
  **inference** time, single vs multi-skill. Decides whether a specialist-fan is viable on
  Ollama at all (A7 + the 8m40s finding). Output: a number + a go/no-go on the fan shape.
  *Files:* none (a probe script in scratch). *No commit.* Cheap, decisive.
- **DC-0b ✎ — F1 egress contract (D1). DRAFTED 2026-08-20 → `CHATTER-DC-EGRESS-CONTRACT.md`.**
  Finding: `verbalize-generic` reads `manifest-final-yield` = the AUDIT VERDICT, not the answer;
  the substance is the COMBINER slot's `ty-findings`. Contract: one closed `SkillEgress`
  (findings + closed `Audit` sum), parsed at the boundary keyed by `RawCall.slot`
  (combiner=substance, last auditor=verdict) — mirrors `parse-perspectives`. Golden-safe (adds a
  parser + rewires verbalize; touches no Flow/Config/run-semantics). **Two ✎AUTHOR calls still to
  ratify** (verdict word-lists; per-skill verbalize framing — see contract §D1). Gates all of F1.
- **DC-0c — F3 posture (D2). RESOLVED 2026-08-21: code-prior.** Recorded in `router.chiral` beside
  `routed-of`, with the measured grounds: the 0.5b planner picked doc-edit/code-test for
  "sort these…" and never evidence-sift (worse than the marker table on exactly the messages the
  table decides); O6's qwen3:4b cured that miss but became capable enough to plan a FAN for a bare
  "hello", which is why social/clarify already had to be gated in code; every structural decision
  since (DC-2a's markers, DC-2b's ASSIGN, DC-4a's dep-derived grant) has been code and has held;
  and asking is not free — the planner runs on the orchestrator tier while skills run on 0.5b, and
  Ollama keeps ONE model resident, so each avoided planner call also removes a full reload.

### Wave 1 — answer quality (F1 + the shortcut). NOTHING downstream matters until answers aren't generic.
- **DC-1a — analyze→refined shortcut. DONE 2026-08-20 (`fe14230`).** Both levers switched
  (intent->plan + plannable menu 6→5); end-to-end proof `turn-analyze-ok` (dead-endpoint fallback →
  byte-exact two-track sentence). Residue: refined is numbered-LIST specialized; prose sift → model
  variant (still in all-skills). Original slice:
- **DC-1a — analyze→refined shortcut.** Route analyze to `evidence-sift-refined` (code path)
  at BOTH levers: the `plannable-skills` menu + `intent->plan`'s analyze arm. Cheap immediate
  win — the refined skill already emits the rich sentence, deterministic, ~0.03s.
  *Files:* `profile/skills.chiral`, `orchestrate.chiral`. *Test:* mesh-free — analyze routes to
  refined + rich verbalize. *Dep:* none.
- **DC-1b slice 2 — research through the general egress parse. DONE 2026-08-20 (`d73d6f0`).**
  `parse-egress` (combiner substance + last-auditor verdict, by slot) + `combiner-findings`
  (fence-stripped JSON `{kind,target,body}`) + `render-egress` + `verbalize-research`; in-factual
  arm wired. egress-test PASS (research ok/gaps/floor + fenced). ⚑⚑ **LIVE FLAG (reshapes DC-1b
  slices 3-5):** a real 0.5b research combiner emits FENCED JSON **and a HALLUCINATED schema**
  (`[{"answerContent":{...}}]`, not `{kind,target,body}`) — so live research FLOORS even after
  fence-stripping. The PARSER is correct (canned proof); the 0.5b COMBINER is unreliable at the
  structured contract (the DC-0a 0.5b-unreliability thesis, now hitting the combiner). **AUTHOR
  DECISION owed before slices 3-5:** the combiner substance-shape — (A) keep structured findings +
  accept live floors until the combiner is reliable; (B) code combiner per skill (like
  evidence-sift-refined's `pf-tally`); (C) bump the combiner model (DC-0a reload-tax tradeoff, or
  DC-5); (D) redefine substance as freeform synthesis prose (drop `{kind,target,body}` for model
  skills).
  **RESOLVED 2026-08-20 (author): option (B) — CODE COMBINER per skill.** Follow
  evidence-sift-refined's proven pattern: replace each model combiner (a flow-step) with a
  `flow-pure` code combiner that DETERMINISTICALLY structures the joined per-angle reasoner outputs
  into a `{kind,target,body}` findings array — reliable, works live, thesis-consistent (per-angle
  reasoning stays model; the COMBINE is code). Slices 3-5 become: (i) design/build a PureFn that maps
  the joined per-perspective outputs -> findings JSON; (ii) swap each skill's combiner flow-step ->
  that flow-pure; (iii) wire verbalize via `parse-egress`. **Touches the skill Flows + the MoE golden
  — CONFORM-check + Flow-change care (recompile scriba if any Flow/PureFn ctor changes).** Design pass
  owed FIRST: the combiner-slot input shape (what the backtrack combiner receives) + the PureFn menu.
- **DC-1b slice 5 — verbalize on the code combiner; F1 CLOSED, live. DONE 2026-08-21.**
  `substance-raw` addresses the combiner by SLOT for a model combiner (`"combiner"`) and by
  SLOT+MARKER for a code one (`"pure"` + `"target":"angle-`), so one parse serves both shapes.
  Added `verbalize-decision` / `verbalize-doc-edit` / `verbalize-code-test` beside
  `verbalize-research`, each with the DC-0b verdict words + its own lead sentence (ratifying D1
  call 5 next to the code, as the contract required). **Framing is now keyed on the SKILL that
  ran, not the Intent** (`verbalize-skill`) — a real bug, not a tidy-up: `code-test` is on the
  plannable menu with NO intent routing to it, and the O5 model planner may name any menu skill
  regardless of the resolved intent, so intent-keyed framing dressed a code-test run in doc-edit's
  words. plan-single/chain/fan all go through it.
  ⚑ **What the LIVE run then exposed (and this slice fixes):** the reply was no longer generic or
  floored — but it was JSON SOUP. `call-expert` appends *"Return ONLY a JSON array of
  {kind,target,body}"* to **every** leaf prompt, so each per-angle yield is itself a (usually
  FENCED) JSON blob even though its declared out-ty is a prose type; the code combiner faithfully
  collected the blobs. Fixed at the combiner, where the shape knowledge is: `unwrap-chunk` in
  `flow.chiral` fence-strips + parses each chunk and takes the body text, over the three shapes a
  0.5b actually emits — proper `{body}` objects, bare string arrays (`["high","…"]`), and INVALID
  JSON with unescaped inner quotes (a `bodies-scan` recovery, pragmatic scan not a parser). An
  EMPTY array drops the angle; anything unrecognized is kept VERBATIM (never drop content —
  parse-perspectives' leniency). `strip-fence` moved from `chatter/egress` down into `core/flow`
  so both users share one copy.
  *Verified:* flow-test (11 byte-exact `pure-collect-angles` cases incl. all three unwrap shapes) ·
  egress-test (+ the code-combiner shape × 4 skills, with a decoy `"pure"` raw proving marker
  addressing) · turn-test byte-exact regression · flow-persist · flow-view · orchestrate · router ·
  the four skill gates · live `CONFORM: true` · scriba 1233272 B. **NEW live artifact
  `scaffold/samples/manas-chatter-live.chiral`** — drives all four skills through `execute-plan` on
  the mesh and gates the properties that are OURS (non-empty, own lead, not-generic, not-floored),
  while REPORTING json-free-prose rather than gating on model variance. **PASS on repeat runs**
  (~10s); the answers are readable prose, per skill, with the audit tag.

- **DC-1b slice 4 — the four model skills swapped to CODE combiners. DONE 2026-08-21.**
  research / decision / doc-edit / code-test each lost their model combiner `flow-step` in
  favour of `(flow-pure (pf-collect-angles "<angle|criterion|edit|test>") … ty-findings)`, and
  the now-dead combiner Experts (`research-synthesize`, `decision-weigh`, `doc-edit-consolidate`,
  `code-test-consolidate`) were **removed** from their pools + the `"combiner"` binding dropped
  from each Config — a leaf that never fires is not documentation, it is a lie about the shape.
  Pools are 4 experts now; the call-count invariant `1+2N+2` **still holds** (a `flow-pure`
  synthesizes one green call + one raw).
  **The substance flag from slice 3 is fixed, not carried:** research/decision/doc-edit's
  per-angle chains end in their judge, so each judge's `emits` now RESTATES what it judged
  ("the finding in one line, then: high|medium|low confidence + one reason"). code-test needed
  nothing — its per-angle chain already ends in the PROPOSER, so the individuals ARE the tests.
  Two latent type lies fixed while in there: doc-edit's backtrack declared `dom = ty-patch` but
  is handed joined per-angle *verdicts* (now `ty-verdict`), and both doc-edit/code-test's audit
  step now declares `ty-findings` in, matching what the code combiner emits.
  *Verified:* four PURE gates PASS (each `flow-ty … : ty-doc -> ty-verdict`, lint 0 flags) ·
  **all four LIVE on the 0.5b mesh, `manifest-all-green? = true`, exit 0** (research 9 calls /
  decision 7 / doc-edit 9 / code-test 5, each = 1+2N+2, ~5s) · flow-test · turn-test ·
  egress-test · orchestrate-test · live `CONFORM: true` · scriba rebuilt (1225080 B).
  *NEXT — slice 5:* `parse-egress` addresses the combiner substance by slot `"combiner"`, which
  a `flow-pure` no longer produces (its raw is slot `"pure"`) — rewire the parse + `verbalize`,
  and re-can the egress-test raws off the new shape.

- **DC-1b slice 3 — `pf-collect-angles`, the CODE-COMBINER primitive. DONE 2026-08-21.**
  New `PureFn` ctor `(pf-collect-angles (kind Str))` + `pure-collect-angles`: splits the
  branch's `join-individuals` input on the `"\n\n---\n\n"` rule and renders ONE
  `{kind,target,body}` finding per non-empty chunk (`target="angle-<n>"`, 1-based, contiguous —
  blank chunks dropped), bodies **JSON-escaped** via `json-quote` (chunks are model prose).
  Nothing collectable -> `""` so the `ty-findings` seam refine-FAILS (visible failure, never a
  fabricated `[]`). All four exhaustive `PureFn` sites updated: `run-pure` + the sum
  (`core/flow.chiral`), the persist codec `purefn->json`/`json->purefn` (`core/flow-persist.chiral`
  — a site the slice-3 scoping note MISSED), and scriba `pf-label` (`scriba/flow-view.chiral`).
  *Verified:* flow-test byte-exact assertions (6 cases; mutation-checked — a one-char change
  fails it), flow-persist-test round-trip on a `pf-collect-angles` flow, flow-view-test, chatter
  turn-test, egress-test, scriba recompiled clean (1229176 B), and **live `CONFORM: true`** on
  `manas-run-conform` (golden untouched, as predicted). *NEXT — slice 4:* swap each model skill's
  combiner `flow-step` -> `(flow-pure (pf-collect-angles …) ty-verdict ty-findings)`.
  ⚑ **SUBSTANCE FLAG found building this (gates slice 4's quality):** the combiner input is
  `join-individuals` of the per-angle **chain yields**, and every model skill's per-angle chain
  ENDS in its auditor (`research-assess`: "verdict: high|medium|low confidence + one reason").
  `chain-run` forwards only the last yield — so the reasoner's actual investigation is **already
  discarded before the combiner sees it**. A code combiner over that input can only ever collect
  *confidence lines*, not the researched content. Fix scoped for slice 4 (recommended, decide
  there): widen each per-angle auditor's `emits` to restate the finding it judged (e.g.
  "verdict: <one-line finding> — high|medium|low confidence + one reason"), so the substance
  rides the yield the branch actually keeps. Cheap (one `Expert` field per skill), no Flow change,
  and **golden-safe** — the CONFORM golden covers `doc-refine` only, not these four pools.

- **DC-1b slice 1 — SkillEgress contract + evidence-sift baseline. DONE 2026-08-20 (`bea5b0d`).**
  New `chatter/egress.chiral`: closed `Audit` + `SkillEgress` (reuses core/types `Finding`),
  `find-slot-raw`/`find-last-slot-raw` (model-skill extractors for slices 2-5), and
  `parse-egress-esift`+`render-analyze` (evidence-sift baseline, BYTE-IDENTICAL). `verbalize-analyze`
  now routes through egress. egress-test PASS (4 proofs); turn-test byte-exact regression PASS.
  Golden N/A (post-run, not in the conformance closure). NEXT: slices 2-5 below.
- **DC-1b…N ✎ — structured egress per model skill (needs DC-0b).** For each model skill
  (evidence-sift, decision, research, doc-edit, code-test): add the closed-sum egress +
  parse-at-boundary; rewire `verbalize` to read the parsed value not freeform JSON. ONE skill
  per slice; start with `evidence-sift` (refined is the comparison baseline).
  *Files:* the skill's `profile/*.chiral` consolidate leaf + a parser + `turn.chiral` verbalize.
  *Test:* mesh — the skill now yields a structured, verbalizable answer (or a typed fallback),
  no drifting JSON. *Dep:* DC-0b. **Touches the MoE golden — CONFORM-check.**

### Wave 2 — real divide (F2). The turn-as-branch.
- **DC-2a — semantic-divider port. DONE 2026-08-21.** New `chatter/divide.chiral`: closed `Chunk`
  (`text` = the ask · `data` = the payload after the `":"` · its OWN routed `Intent` · `deps` as
  indices · a closed `Origin`) and a closed `Divided` egress (chunks + how they were obtained).
  **Code-prior, port-second:** the structural pass reads sequencing markers (router's own
  `conj-markers`, so C6b's turn-seq and the divider cut at identical seams) and parallel markers
  (`", and "` / `" and also "` / `" also "` / `" plus "`); the model port opens ONLY for a message
  the code pass could not divide at all, and never for one under router's clarify threshold.
  **Deps are read off the marker, not guessed:** a sequencing marker makes group g wait on ALL of
  group g-1 (a barrier); parallel siblings carry `deps = nil`. Needed an OVERLAP rule in the
  marker scan — `", and "` starts one byte before `" and also "`, so overlapping matches resolve
  to the LONGER marker or the split leaves "also" glued to the next chunk.
  *Verified:* `divide-test` — 8 mesh-free gates (plain · sequencing · parallel · seq+par barrier
  with siblings NOT waiting on each other · ask/payload split · per-chunk intents differing inside
  one message · the port gate · the zero-chunk floor for a contentless message). **Live**
  `scaffold/samples/manas-divide-live.chiral` **PASS** (~21s): structured → port SHUT (2 chunks,
  intents analyze+decide); thin → SHUT; residue with no structural seam → the port DIVIDED it
  ("tell me what caused the outage last night" / "tell me whether we should roll it back");
  a genuine single ask → the model agreed, `via=whole`. Full suite + live `CONFORM: true`.
  ⚑ Two notes for DC-2b: (1) the port costs **~10s/call** on qwen3:4b, and a divided turn now
  crosses Ollama's single resident slot a THIRD time (divide 4b → skills 0.5b → synth 4b) — the
  DC-0a reload tax, now with one more crossing; a per-turn latency budget or DC-5 co-residence is
  the fix. (2) `turn.chiral` is NOT wired to the divider yet — that is DC-2b (turn-as-branch),
  deliberately kept out of this slice. *Original slice:*
- **DC-2a — semantic-divider port.** A step: message → `List<Chunk>` (each a typed sub-request).
  Code-first (structural: conjunctions/lists/clauses) + a model-residue port for unstructured
  messages; closed-sum egress. *Files:* new `chatter/divide.chiral` + `turn.chiral`. *Test:*
  mesh-free structural split + (mesh) a model-divide leg. *Dep:* DC-0a (viability).
- **DC-2b — chunk-fan / turn-as-branch. DONE 2026-08-21.** `turn-seq` (the entry scriba calls,
  signature UNCHANGED) is now DIVIDE→ASSIGN→run→CONSOLIDATE. C6b's syntactic chain is GONE:
  `turn-seq-go` deleted, `chat-tag` reads the divider instead of `split-conjunctions`.
  0 chunks → the old single path (clarify); 1 chunk → `turn` on the ORIGINAL message,
  byte-identical to before; N chunks → the branch. ASSIGN is the PURE prior (`intent->plan`),
  ONE code-decided pick per chunk instead of N model-planner calls — dividing is what makes each
  part narrow enough for code to route. CONSOLIDATE reuses O4b's `fan-synth` (model primary,
  `fuse-template` offline fallback).
  ⚑ **THE DEP RULE IS THE CONTEXT GRANT** (the part worth re-reading): a chunk WITH deps runs
  against the RUNNING ConvState and sees what its predecessors produced; an INDEPENDENT chunk runs
  against the ENTRY ConvState and cannot see a sibling's result — the bleed a fan exists to
  prevent. So the marker the user typed decides ordering AND visibility, with no heuristic and no
  model call. It also generalizes C6a per chunk: a dependent chunk re-resolves its intent through
  the running state (a bare follow-up reuses its predecessor's intent), an independent one keeps
  the divider's context-free route. **That is a real slice of DC-4a landing early**, at
  message+memory granularity.
  *Verified:* `turn-test` gains `branch-ok` — two compound messages differing by ONE marker, both
  at the dead endpoint, fully deterministic: `" and then "` → chunk 2 depends → REUSES analyze;
  `", and also "` → chunk 2 independent → routes on its own → **unknown**. The two fused replies
  differ by exactly that label, both carry chunk 1's real two-track sentence, both fuse TWO lines,
  both fold every chunk into memory. Every prior turn-test assertion still passes byte-exact.
  **Live** (`manas-chatter-live`, extended): one compound message → divided → two specialists →
  fan-synth fused ONE coherent reply covering both lanes, ~18s for the whole 5-probe sample.
  Full suite + live `CONFORM: true` + scriba 1245560 B.
  ⚑ Also landed here: the divider port gained a measured **latency gate** (`port-min-chars` 60) —
  it costs ~10s on qwen3:4b and adds a third crossing of Ollama's single resident slot, so a short
  ask is answered by the code pass for free. *Original slice:*
- **DC-2b — chunk-fan / turn-as-branch.** `execute-plan` fans specialists over CHUNKS (not the
  same whole message); `turn` becomes the branch DIVIDE→ASSIGN→fan→CONSOLIDATE. Reuses
  `fan-collect`/`fan-synth` (O4b) but keyed by chunk. *Files:* `turn.chiral`. *Test:* mesh-free
  with model-free skills over 2 chunks → 2 sub-runs fused. *Dep:* DC-2a, DC-1b (structured
  egress so the fuse is real).

### Wave 3 — selection + consolidate
- **DC-3a — M2 escalation ladder. DONE 2026-08-21.** Two rungs, and the rung is a closed value:
  `routed-sure <intent>` when a marker (or the clarify threshold, or C6a's follow-up reuse) fired,
  `routed-residue` when only the honest catch-all is left. `turn` now assigns via `assign-plan`:
  sure → `intent->plan` (no dial at all); residue → `plan-message`. The seven-arm `case` in `turn`
  is gone — O6's social/clarify fast-path was this same rule applied to the two obvious intents.
  The branch climbs the SAME ladder per chunk (`run-chunk`): dividing narrows most parts into
  code's reach, and this is what happens to the ones it does not.
  ⚑ **The observable:** the deterministic suite — which includes an ANALYZE turn against the LIVE
  mesh URL — now completes in **18ms with ZERO dials**, and that turn's answer is asserted
  BYTE-EXACT. Before DC-3a the same call went to the qwen3:4b planner, so neither the timing nor
  the string was deterministic. Each such turn also stops crossing Ollama's single resident slot
  for planning (DC-0a's reload tax).
  *Verified:* `ladder-ok` (sure for social/analyze/clarify; residue for a bare follow-up routed
  context-free; **sure again** for the same follow-up once C6a resolves it — the reuse rule is
  deterministic, hence code-certain) + `ladder-nodial-ok` (byte-exact analyze at the live URL).
  Full suite (13 gates), live `CONFORM: true`, scriba 1261944 B, live chatter PASS. *Original:*
- **DC-3a ✎ — M2 escalation ladder (needs DC-0c).** Markers decide confident cases; the model
  planner handles only the residue. *Files:* `router.chiral`/`orchestrate.chiral`. *Dep:* D2.
- **DC-3b — consolidate on structured egresses. DONE 2026-08-21.** DC-2b fused the chunks'
  rendered PROSE — each lane made a sentence and the consolidator re-read sentences, so the
  structure existed for one instant and was thrown away at the chunk boundary. Now the branch
  carries the parsed `SkillEgress` (findings + the closed `Audit`) all the way through.
  New seam in `egress.chiral`: **`skill-egress` PARSES, `render-skill` RENDERS**, and
  `verbalize-skill` is their composition — so a lane's prose and its structure can never disagree
  (it also deleted the five welded `verbalize-<skill>` one-liners). `egress-brief` renders the
  structure for the synth prompt. In `turn.chiral`: `ChunkOut` (label + reply + egress), `run-chunk`
  (runs the skill directly so the raws survive — `execute-plan` returns a `Str`, and a `Str` is
  exactly what DC-3b refuses to consolidate over), `branch-synth`, and `synth-with` — the shared
  be-chat wire that O4b's `fan-synth` now rides too, so the two consolidators differ ONLY in the
  prompt they build.
  ⚑ **The behavioral delta:** the model synth prompt lists each lane's findings (kind/target/body)
  and its audit word, and the PURE fallback **names every lane whose verdict was FLAGGED or never
  recorded**. Before, a degraded lane was fused as if it were clean — the reply looked equally
  confident either way. Offline and online, it no longer does.
  *Verified:* `branch-ok` extended — both compound messages now fuse THREE lines, `"(unverified:
  analyze)"` / `"(unverified: unknown)"` naming exactly the lane that produced nothing verifiable,
  and the clean `evidence-sift-refined` lane never named. Full suite green (13 gates), live
  `CONFORM: true`, scriba 1253752 B. **Live:** the fused compound reply now visibly reasons over
  the audits (first draft over-reported them, so the prompt was rebalanced to lead with the answer
  and cap the audit at one clause). *Original slice:*
- **DC-3b — consolidate on structured egresses.** `fan-synth` fuses the F1 structured
  sub-outputs into one reply (model synth + pure-template fallback already exist). *Files:*
  `turn.chiral`. *Dep:* DC-1b (rides F1), DC-2b.

### Wave 4 — controlled context + visibility
- **DC-4a — per-specialist context attenuation. DONE 2026-08-21.** Two levels, because `extra` is
  rendered VERBATIM into every leaf prompt (`assemble.chiral`'s "# Extra") — what a specialist is
  granted is literally what it reads.
  **(1) The chunk executor.** DC-2b's dep rule picked WHICH ConvState a chunk ran against — right
  shape, wrong grain: a dependent chunk inherited the whole running state, so `prior-message` /
  `prior-reply` became its SIBLING's message and full rendered prose, and the turn's real
  conversation history was clobbered by it. DC-4a splits the two things that were fused:
  **ROUTE on the running state** (a follow-up chunk still resolves its intent through what came
  before — a decision may look at history) but **SEE only an explicit `grant-for`**: the ENTRY
  conversation plus, per dep, that dep's `egress-brief` — findings and audit verdict, NOT its
  prose and NOT its payload, exactly as CHATTER-FLOW-MAP specifies. An independent chunk gets no
  sibling key at all: min-privilege by construction, no filter to forget.
  **(2) The fractal child.** `branch-run` used to hand a child its parent's WHOLE extra PLUS a
  tagged copy of the key NAMES its perspective asked for — a superset, and names without values.
  Now `attenuate`: a perspective that DECLARES what it needs gets EXACTLY those keys (a strict
  subset); one that declares nothing inherits, so nothing live narrows by surprise. The `sees`
  channel was also **unreachable** — `parse-perspectives` hardcoded `nil` on both parse paths, so
  no perspectivist could ever declare anything; the JSON path now reads a `sees` array.
  ⚑ Also fixed here, from a live observation: when NO lane produced findings, `branch-synth` used
  to still call the model, which could only paraphrase the bookkeeping ("both lanes had no
  findings"). It now returns the honest floor without paying for the call.
  *Verified:* `grant-ok` in turn-test (independent → no sibling key; dependent → the dep's TYPED
  result, and its rendered sentence provably absent; the real conversation reaching both) and
  `attenuate-ok` + `sees-parsed-ok` in flow-test (declared-nothing inherits 3 keys, declared-one
  yields exactly 1 with the others GONE, an absent declared key yields 0, and a perspectivist's
  JSON `sees` round-trips into a working slice). Full suite (13 gates), live `CONFORM: true`
  (branch-run semantics touched — the gate that matters), the live research fractal still
  all-green on the 0.5b, live chatter PASS, scriba 1253752 B. *Original slice:*
- **DC-4a — per-specialist context attenuation.** Slice `sees`/`extra` per specialist
  (min-privilege); a fractal child gets a subset of its parent's grant. *Files:* `run-flow-stop`
  extra-threading + the divider/executor. *Dep:* DC-2b.
- **DC-4b — scriba surfaces the turn's structure. DONE 2026-08-21.** The transcript showed a flat
  `(you, tag, reply)` row: whether the turn divided at all, which lane handled which ask, which
  lane waited on which, and what each lane's audit said existed only inside `turn-seq` and died
  there. New `TurnView` (tag + `Lane` list + fused reply) returned by **`turn-seq-view`**;
  `turn-seq` is now its projection to the reply, so its signature and every caller are untouched.
  `Exchange` gains the lanes and `exchange-rows` renders one row per lane —
  `· <intent> ⇠ <dep> [audit: <word>] <that lane's own reply>` — under the fused answer.
  scriba **re-derives nothing**: the tag comes from the view too, so the displayed structure is
  the structure that ran (the separate `chat-tag` pre-call is gone from the loop).
  A ONE-CHUNK turn carries `nil` lanes and renders exactly as before — structure appears only when
  there IS structure. `turn-branch` deleted (subsumed by `turn-seq-view`).
  *Verified:* **PTY-driven on the committed-resolver build** (1261944 B), both display modes on the
  live mesh — parallel: `compound(2) → …` + `· analyze [audit: well-formed] I sorted the flagged
  items: 1 supported by evidence, 0 held as speculation.` + `· decide [audit: -] …`; sequencing:
  the same with `· decide ⇠ analyze`, the dep arrow rendering. Full suite (13 gates) + live
  `CONFORM: true`. *Original slice:*
- **DC-4b — scriba plan surfacing (O7).** The transcript shows the Plan (skills, chain/fan,
  per-skill results), not a flat `Exchange`. *Files:* `TUI/scriba/command-loop.chiral`
  (`Exchange`/`transcript-render`). *Test:* PTY. Secondary — visibility, not function.

### Wave 5 — substrate (only if DC-0a says load dominates)
- **DC-5 — persistent model server.** Replace Ollama's per-request model with llama-server or
  vLLM (persistent KV, arbitrary-grammar, multi-adapter). Infra. *Why:* E16 (Ollama =
  one-adapter, no CFG, per-request) + A7 (per-call load). Gates whether a real fan is timely.

## Critical path — WALKED, end to end
```
DC-0a ✅ ─┐
DC-0b ✅→DC-1b ✅ (good answers) ─┼─▶ DC-2a ✅→DC-2b ✅ (real divide) ─▶ DC-3b ✅ ─▶ working D&C chat ✅
DC-0c ✅→DC-3a ✅ (reliable pick) ┘     DC-4a ✅ (attenuation) ;  DC-4b ✅ (visibility) ;  DC-5 not needed
```
DC-5 was never needed: DC-0a showed a same-model fan stays warm (0.82s for 5 specialists), so the
persistent-server work is only a dependency of MODEL-DIVERSE fans, which nothing here requires.

**What is genuinely left (new work, not ledger residue):** the supply/retrieval front
(`CHATTER-STATE` SUPPLY-1) — a fact a leaf cannot SEE cannot be extracted, and no amount of
dividing manufactures absent knowledge; and skill-OUTPUT quality (the 0.5b lanes themselves),
which is the Skill-Config model bump that touches the MoE golden.

## DISPATCH DISCIPLINE (the orchestrator MUST honor)
- **SERIAL. One agent at a time.** Never a parallel batch (standing user directive). Wait for
  each to return verified+committed before the next.
- **Build recipes: use CHATTER-STATE verbatim** — the mesh-free chatter test blob (closure
  `manas/chatter/{orchestrate,turn,router} manas/profile/skills`; use `profile/skills` NOT
  `core/skill`), and the **committed-resolver** scriba build (`echo 'scriba/scriba-main' |
  resolve`). Python compiles NOTHING.
- **B1/E137 gotchas:** flat `case`; nullary ctors WITH parens in patterns; exhaustive `case`;
  non-final `do` step must be `Unit`; `str-sub`/`str-find` are `(START,END)` END-EXCLUSIVE
  (length-as-END segfaults); a linear `Backend` is moved EXACTLY once, INLINE (never
  let-bind-then-close); **recompile scriba after ANY Flow/PureFn ctor change** (`flow-view.chiral`
  exhaustive case, flow-view.chiral:44-72).
- **Mesh:** reachable at `http://100.64.0.5:11434` (Ollama). Model zoo incl. qwen3:4b/8b,
  gemma4:12b, qwen2.5:3b-instruct. Model output is non-deterministic → committed tests stay
  deterministic (parser on canned outputs + a dead-endpoint `127.0.0.1:1` fallback leg, per
  O4b/O5); live model behavior is verified + REPORTED, not asserted byte-exact.
- **Commit cadence:** commit each finished+verified unit (do NOT wait to be asked — see
  `feedback-commit-cadence`). Trailer:
  `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>` + the session line.
- **Golden care:** DC-1b touches the MoE golden (skill Configs/Flows) — CONFORM-check; do not
  change `run-flow`/`plan-run` semantics.

## First two dispatches for the fresh chat
1. **DC-0a** (latency measurement) — cheap, decides viability of the whole fan shape.
2. **DC-0b** (F1 egress contract, D1) — the design gate everything downstream needs.
Then DC-1a (free win) and DC-1b (evidence-sift structured egress). Hold F2 until F1/F6 clear.
