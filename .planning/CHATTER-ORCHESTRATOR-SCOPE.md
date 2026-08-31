# Orchestrated Chatter — scope (2026-08-18)

Big scope for turning the chatter from **route-to-one-skill-or-dead-end** into a
**set of small models orchestrated to orchestrate**: a small orchestration that,
from the message, decides how to **combine the pipelines we already have**. This
is composition over known-good units — not a new big-model capability. Companion
authorities: `.planning/CHATTER-STATE.md` (C1–C6b, build/test recipes),
`.planning/MANAS-SKILL-GROWER.md` (branch/consolidate + tiny-step discipline),
`.planning/MANAS-STATE-VS-GOAL.md` (the MoE engine arc).

> **Refined by the newer design maps (2026-08-18).** `.planning/CHATTER-MIX-MAP.md`
> (AI = **PORT** — type the port, not the content) and `.planning/CHATTER-FLOW-MAP.md`
> (the **divide→fan→consolidate** turn shape) supersede this scope's earlier "seam"
> language and recast its as-built **model-primary** O5/O6 posture as an OPEN
> **code-prior-vs-model-primary** author call (see §6 "Planner posture" and §7). Read
> the maps for the current framing; this scope remains the build ledger.

---

## 1. Thesis & model

**The message is passed to a small orchestration that combines existing working
pipelines.** The orchestrator's job is BOUNDED — pick + sequence + combine from a
known menu of 6 working skills (`skills.chiral:33`) — and therefore tractable. Each
skill is already a Flow = a series of passes (some model, some pure code). We are
composing them, not asking one model to "understand everything."

**Anti-patterns this explicitly rejects:**
- **Big-understanding model** — handing a raw message to a model and asking it to
  "understand → decompose → gather → respond." That is a *big question* to a tiny
  model; a 0.5b is a coin-flip at exactly that (flow.chiral:66–90, the refinement
  thesis; measured 1/5 on evidence-sift's classify). This is the corrected error —
  do NOT reach for it.
- **The current dead-end** — the pure-code marker router picks one intent, and
  anything it can't place returns a hardcoded template with ZERO model, ZERO
  passes (`turn.chiral:33–42`, `no-skill-reply`). "Hello" and "look at scriba" both
  hit this today.

**Reconciliation with the three governing principles:**
- **Principle #4 (no general-purpose cop-out).** Preserved: the orchestrator is a
  NAMED pipeline of passes (a Flow that emits a Plan, then executes named skills),
  not a monolithic chat leaf. There is still no "general assistant" model.
- **Skill-grower north star (no big questions; tiny models).** Preserved: the
  orchestration decision is decomposed into small steps; if a single pick is shaky,
  reliability comes from the branch = N-perspective sub-pipeline + consolidate/audit
  backtrack that already exists (`flow.chiral:861` flow-branch), NOT a bigger model.
- **Refinement thesis (route in code where reliable).** Preserved and reused: the
  existing pure-code router (`router.chiral:74` route-message) becomes a **fast-path
  / prior / fallback planner**, not the whole story. Symbol-manipulation that code
  does reliably stays in code; the model is reached only to *plan a combination* of
  reliable units, and even there with a code fallback.

---

## 2. What already exists (grounded inventory)

The "we already have the pipelines" evidence base. Each item cites file:line and an
honest build-state.

| Capability | Where | State |
|---|---|---|
| **6 working skills** (each a Flow of passes) | `skills.chiral:33–45` `all-skills` = `doc-edit`, `code-test`, `evidence-sift`, `evidence-sift-refined`, `research`, `decision` | **BUILT.** Registry with name+Flow+Config+pool+sample. `evidence-sift-refined` is fully model-free + verified; the model skills fire on the 0.5b mesh. |
| **Skill resolution** | `skills.chiral:53–61` `skill-by-name` | **BUILT.** name → entry, miss = `none` (value). |
| **Flow engine** (the pass model) | `flow.chiral:110–124` `Flow` sum (`flow-step/gate/fan/chain/branch/pure/branch-pure`); `flow.chiral:99–108` `PureFn` (6 ctors incl. `pf-collect-angles`); `flow.chiral:851` `run-flow`; `flow.chiral:995` `run-flow-stop` | **BUILT + verified.** Recursive typed composition; `flow-ty` (flow.chiral:182) is the compositional checker — any Flow nests in any composite iff it type-checks. |
| **Fan + by-id combiner** (fuse sub-flows) | `flow.chiral:161` `fan-ty`, `flow.chiral:821–838` `fan-run` + `call-combiner` | **BUILT.** `flow-fan` runs N children on ONE shared input and a by-id combiner merges them. NOTE: children must share one `dom` Ty; the combiner is a model expert resolved in the pool. |
| **Per-skill consolidate** (in-Flow) | `evidence-sift-refined.chiral` backtrack (`pf-tally`); `doc-edit.chiral:69` `doc-edit-consolidate` | **BUILT.** Each skill fuses its OWN internal per-perspective outputs in its backtrack. There is **no** component that fuses outputs of DIFFERENT skills — that is NEW (see §4/§5 O4). |
| **`turn`** (route → run one skill → verbalize) | `turn.chiral:174–182` | **BUILT.** Consumes one linear Backend once (E137); ConvState-aware (C6a). |
| **`turn-seq`** (sequence over a compound message) | `turn.chiral:206–233` | **BUILT.** Runs an ordered list of skills, fresh Backend per part, threading ConvState. BUT the sequence comes only from *surface conjunctions* the user typed — see §3. |
| **ConvState memory** | `router.chiral:136–138`, `conv-update` :168, `conv->extra` :182 | **BUILT (C6a).** Threads prior intent/message/reply into the routed Flow's `extra`/`sees` slot. Residue: no leaf yet READS it (CHATTER-STATE honest gaps). |
| **verbalize-run** (result → prose, pure) | `turn.chiral:44–146` | **BUILT (C3).** Rich for `analyze`; generic frame for the rest. |
| **`compose` pick + preflight** | `compose.chiral:47` `compose-preflight`, `:54` `all-pipelines`, `:58` `pipeline-by-id` | **PARTIAL.** Picks ONE flat `Pipeline` + Config and pre-flight-binds. `all-pipelines` holds ONLY `doc-refine` (compose.chiral:54–55) — it does NOT see the 6 Flow skills, and it is NOT wired to the chatter. |
| **`plan-run`** (who-fires bind discipline) | `plan.chiral:97–114`; `empty-manifest` :185 | **BUILT.** Pure match→gate→bind for the flat pipeline path; the bind/BindResult discipline is reusable. |
| **TINY-MODEL-GREEN gate** | `flow.chiral:1039` `manifest-all-green?`; lint `:979` | **BUILT (slice 5).** A composition passes iff every leaf ran green; the per-skill acceptance gate the orchestrator can reuse to reject a bad sub-run. |
| **scriba surface** | `command-loop.chiral:1730` `chatter-ask`, `:1803` `chatter-chat-loop`, `:1824` `chatter-chat`, `:1757` `Exchange`, `:1784` `transcript-render`, `:1836` `:chat`/`:ask` dispatch | **BUILT (C4/C5).** Both entries already route through `turn-seq`. |

The raw materials for "combine a few pipelines" are all present: the units
(skills), the runner (`run-flow-stop`), sequencing (`turn-seq`), memory
(`ConvState`), a fan combiner pattern, and an acceptance gate.

---

## 3. The gap — why a message dead-ends today

Precisely, with citations:

1. **The router picks EXACTLY ONE intent, then AT MOST ONE skill.**
   `route-message` (`router.chiral:74–88`) is a first-match marker cascade → one
   `Intent`. `intent->skill` (`router.chiral:96–105`) maps 4 intents to one skill
   each and maps `social`/`clarify`/`unknown` → `none`. On `none`, `turn`
   (`turn.chiral:179`) calls `no-skill-reply` — a hardcoded template
   (`turn.chiral:33–42`). **No model, no passes, no combination.**

2. **`turn-seq` sequences skills only on SURFACE conjunctions the user typed.**
   `turn-seq` (`turn.chiral:225`) splits on `split-conjunctions`
   (`router.chiral:255`), which matches literal " then "/"; " markers. Each part is
   then run through the SAME single-skill router. So a *chain* only happens if the
   user writes "X then Y" — it is a syntactic split, **not an orchestration
   decision** about how to combine skills for one ask.

3. **`compose` can't see the skills.** `all-pipelines` (`compose.chiral:54–55`)
   contains only `doc-refine-pipeline`. The 6 Flow skills live in a SEPARATE
   registry (`skills.chiral:33`) that `compose` never imports. `compose` also isn't
   wired to the chatter path at all. So the one existing "pick a pipeline"
   mechanism is blind to the units we want to combine.

4. **There is no orchestrator.** Nothing takes `(message, skill-menu)` and emits a
   PLAN (which skills, in what order, combined how). The mapping is the static
   marker table, full stop.

5. **There is no cross-skill synthesizer.** Fusion happens INSIDE each skill's
   backtrack (§2). `flow-fan`'s combiner (`flow.chiral:821`) fuses sub-Flows sharing
   one input Ty via a model expert — reusable *shape*, but nothing today fuses the
   heterogeneous outputs of DIFFERENT skills into one reply.

Net: the funnel is `markers → one skill or a template`. Everything outside the ~5
marker vocabularies gets a canned non-answer with no model involvement.

---

## 4. Target architecture

```
message ─┬─ (fast-path prior: route-message, pure)                    [reused]
         │
         ▼
   ORCHESTRATOR (a Flow of small passes)                              [NEW]
     understand-lite (optional model read: message + skill menu → hints)
     plan            (model picks/sequences from the 6-skill menu;
                      pure fallback planner is the prior + safety net)
     [optional] branch/consolidate to HARDEN the pick                 [reuse flow-branch]
         │
         ▼  emits a Plan (closed sum) — NEVER a dead-end
   ┌─────────────── Plan ───────────────┐
   │ plan-single skill                  │ → run-skill-turn            [reused]
   │ plan-chain  [skill…]               │ → turn-seq (ConvState)      [reused]
   │ plan-fan    [skill…] synth         │ → run each + SYNTHESIZE     [NEW synth; reuse fan pattern]
   │ plan-reply  text                   │ → templated (honest floor)  [reused]
   └────────────────────────────────────┘
         │
         ▼
   one reply  ── verbalize per skill (reused) + synth fuse (NEW) ──▶ transcript
         │
         └─ thread ConvState forward (conv-update)                    [reused, C6a]
```

**The `Plan` type (boundary-as-closed-sum, docs/pattern-boundary-sums.md).**
Proposed:

```
(data Plan ()
  (plan-single (skill Str))                       ; one skill (== today's behavior)
  (plan-chain  (skills (List Str)))               ; sequential, output→next (turn-seq)
  (plan-fan    (skills (List Str)) (synth Str))   ; parallel on the message, then synth
  (plan-reply  (text Str)))                        ; the honest templated floor (no skill)
```

A Plan is a VALUE the executor cases totally — never a sentinel, never a
dead-end. `unknown`/`social`/`clarify` map to a `plan-reply` (or a sensible default
`plan-single`), so **every** message yields a plan.

**Reused vs new — explicit:**
- **REUSED:** `all-skills`/`skill-by-name`, `run-flow-stop` (runs a skill Flow),
  `run-skill-turn`/`turn`/`turn-seq` (dispatch + sequence + ConvState),
  `verbalize-run`, `ConvState`/`conv-update`/`conv->extra`, the flow engine and
  its `flow-fan` combiner *pattern* (flow.chiral:821), `manifest-all-green?` (reject
  a bad sub-run), the bind discipline (`plan-run`), the scriba `chatter-chat-loop`
  surface, the three build/test recipes.
- **NEW:** the `Plan` closed sum; the **pure fallback planner** (Intent → Plan, no
  dead-end); `execute-plan` (Plan → execution, dispatching to the reused runners);
  the **cross-skill synthesizer** (fuse heterogeneous skill outputs → one reply);
  the **model planner Flow** (message + menu → Plan, with the pure planner as
  prior/fallback); a **unified plannable skill registry** so orchestrator/compose
  see the 6 skills; the scriba plan-surfacing.

The orchestrator being a **Flow** means it type-checks and nests exactly like any
skill (flow-ty, flow.chiral:173) — the composability guarantee applies to the
orchestrator itself.

---

## 5. Staging into commit-sized slices

Each slice is independently buildable + verifiable, with a mesh-free deterministic
leg wherever possible (mirroring C1–C6b). Ordered so the **dead-end dies first**
(O1) with zero model dependency, then capability is layered on.

**O0 — `str-lower` normalization (pre-req, small, additive).**
- Deliverable: an ASCII-lowercase pure helper; lowercase message + markers before
  matching in `route-message`/`resolve-intent`. Fixes "Hello"/"Hey"/"SORT THESE".
- Files: `router.chiral` (+ possibly a helper in `flow.chiral`/prelude), tests.
- Reused: marker cascade. New: the lowercase pass.
- Test: `router-test.chiral` — capitalized greetings/asks route correctly. Mesh-free.
- Note: standing chatter limit today (router.chiral:28–34); promote it here because
  the pure fallback planner (O1) inherits the case bug otherwise.

**O1 — `Plan` sum + PURE fallback planner that NEVER dead-ends.**
- Deliverable: the `Plan` type; `plan-of-intent : (-> ConvState Str Plan)` mapping
  the resolved Intent to a Plan — the 4 skill intents → `plan-single <skill>`;
  `social` → `plan-reply <social-template>`; `clarify` → `plan-reply <ask-for-more>`;
  **`unknown` → `plan-single "research"`** (attempt an answer, per the author call) —
  never a dead-end.
- Files: `router.chiral` or a new `chatter/orchestrate.chiral`; tests.
- Reused: `resolve-intent`, `intent->skill`, `no-skill-reply` templates. New: `Plan`,
  `plan-of-intent`.
- Test: deterministic — every Intent yields a Plan; no input maps to a dead-end.
- Why first: this alone converts "route or dead-end" into "always a plan" with NO
  model — the honest floor becomes a plan, and everything downstream is additive.

**O2 — `execute-plan` + wire `turn` through the planner.**
- Deliverable: `execute-plan : (=> (1 b Backend) ConvState Plan Str Str)` casing the
  Plan — `plan-single`→`run-skill-turn`; `plan-chain`→`turn-seq`; `plan-reply`→text;
  `plan-fan` deferred to O4. `turn` becomes `message → plan-of-intent → execute-plan`.
- Files: `turn.chiral`, tests; (scriba unchanged — it already calls `turn-seq`).
- Reused: `run-skill-turn`, `turn-seq`, `verbalize-run`, linear-Backend discipline.
  New: `execute-plan`, the re-wire.
- Test: mesh-free — a `plan-single` on `evidence-sift-refined` reproduces today's
  reply byte-for-byte (regression); a `plan-reply` path returns the template.

**O3 — plannable skill menu (the orchestrator's menu).**
- Deliverable: a `plannable-skills : (List (Pair Str Str))` menu of (skill-name,
  one-line description) for the 6 skills — the menu the pure planner and the O5 model
  planner range over. Home: `skills.chiral` (registry metadata), NO `SkillEntry` ctor
  change (a sibling list guarded by a name-consistency test against `all-skills`, so
  scriba's SkillEntry match sites are untouched).
- Files: `skills.chiral` (+ test). Pure, mesh-free.
- Reused: `all-skills`/`skill-names`/`skill-by-name`. New: `plannable-skills` + accessor.
- Test: deterministic — all 6 skills present, each with a non-empty description, and
  every `plannable-skills` name resolves via `skill-by-name` (no drift).
- NOTE (rescoped 2026-08-18): the compose-registry "unification" is a SEPARATE
  concern, NOT this slice. `compose` works over the OLD flat `Pipeline` type; skills
  are the NEW `Flow`/`SkillEntry` type — a type MISMATCH, not a merge — and the
  orchestrator does NOT need `compose` (it runs skills via `all-skills`/
  `run-skill-turn`). The `all-pipelines`-only-`doc-refine` gap (compose.chiral:54) is
  out of the orchestrator critical path; mint its own row IF the `:compose` cockpit
  feature is later extended to skills.

**O4a — plan-chain executor + the multi-backend seam.** (split from O4, 2026-08-18)
- The seam: today `turn-seq-go` opens ONE `(backend-open endpoint)` per PART and hands
  it to `turn`/`execute-plan` — fine for `plan-single`/`plan-reply` (one backend), but
  a `plan-chain` of K skills needs K backends. So refactor the backend-opening DOWN
  into the executor: change `turn`/`execute-plan` to take the ENDPOINT (Str), not a
  pre-opened `(1 b Backend)`, and open a fresh backend PER skill run internally
  (mirroring `turn-seq-go`'s existing per-part fresh-backend shape). `turn-seq`'s own
  signature `(=> Str ConvState Str (Pair ConvState Str))` is UNCHANGED, so scriba is
  untouched; only `turn-seq-go`'s inner call changes to pass the endpoint.
- Deliverable: the `plan-chain` executor — run the skill list SEQUENTIALLY, a FRESH
  backend per skill, threading `ConvState` so each skill sees the prior's result;
  combine (tagged lines, like `turn-seq-go`). REPLACES O2's `plan-chain` placeholder.
- Files: `turn.chiral`, tests. Reused: `run-skill-turn` (the atom), `verbalize-run`,
  `conv-update`/`conv->extra`, `turn-seq-go`'s fresh-backend idiom. New: the endpoint
  refactor + the chain fold.
- E137: each `(backend-open endpoint)` moved EXACTLY once inline into its
  `run-skill-turn`; never reuse a handle across skills. plan-single stays
  byte-identical (same run+close+verbalize, backend opened one line earlier).
- Test: MESH-FREE — a `plan-chain ["evidence-sift-refined" "evidence-sift-refined"]`
  runs both sub-skills and combines their (identical, model-free) replies; plan-single
  regression byte-identical; plan-reply unchanged. Exit 0. PTY: `:chat` social leg
  still green (proves the endpoint refactor didn't break the loop).

**O4b — plan-fan executor + the model synthesizer.** (split from O4, 2026-08-18)
- Deliverable: run N skills on the message INDEPENDENTLY (a fresh backend each, reuse
  O4a's seam), collect their (verbalized) outputs, fuse into ONE reply. Synth =
  **MODEL** call as the primary/richer path (author call); a **pure-template fusion**
  is the fallback used when the mesh is unreachable OR a sub-run failed — mirrors the
  O5 pure-planner-as-fallback pattern and gives the deterministic leg. REPLACES O2's
  `plan-fan` placeholder.
- Files: `turn.chiral`/`orchestrate.chiral`, tests. Reused: the `flow-fan` combiner
  *pattern* (flow.chiral:821) as shape; per-skill `verbalize-run`; `manifest-all-green?`
  to DROP a failed sub-run (not crash); O4a's per-skill-backend seam.
- Test: the MODEL synth leg needs the mesh (egress-blocked in-sandbox) — ship a
  deterministic STRUCTURAL leg: `plan-fan` over model-free skills assembles the fused
  synth-INPUT naming each, and the **pure-template fallback** synth produces one fused
  reply naming both; a failed sub-run is dropped, not crashed. The model-prose synth
  verifies on the mesh. Exit 0.

**O5 — the MODEL planner.**  (MESH IS REACHABLE — corrected 2026-08-18, see §7)
- Deliverable: a small model call reads the message + the skill menu (`plannable-skills`,
  O3) and picks the handling skill(s); parsed leniently into a `Plan`. The O1 pure
  planner (`plan-of-intent`) is the **prior/fallback** — used when the model reply
  names no valid menu skill OR the mesh call fails. Wire into `turn`: try the model
  planner first, fall back to the pure plan; then `execute-plan` as today.
- Model call: a `be-chat` planner (same primitive O4b's synth uses — NOT a new
  backend primitive; a formal understand-lite→plan Flow wrapper is an optional
  refinement / O6, not required for v1). Prompt = the menu + the message → "which
  skill(s) fit?".
- **Plan parser** (lenient, mirrors `parse-perspectives`): scan the model reply for
  `plannable-skills` names present → 0 names ⇒ FALLBACK to `plan-of-intent`; 1 name ⇒
  `plan-single`; 2+ names ⇒ `plan-fan` (independent, fused via O4b's synth). (chain
  stays driven by explicit compounds / a later refinement.)
- Files: `orchestrate.chiral` (the pure parser) + `turn.chiral` (the be-chat planner +
  the `turn` wire) + tests. Reused: `be-chat`, `plannable-skills`, `plan-of-intent`
  fallback, `execute-plan` (single/fan already built). New: the planner call + parser.
- Test: **committed = deterministic** — unit-test the Plan parser on CANNED model
  replies (name→plan-single, two-names→plan-fan, no-name→fallback), and a dead-endpoint
  leg proving fallback to the pure plan (mirrors O4b's `127.0.0.1:1` pattern), since
  model output is non-deterministic. **Live leg = verified + REPORTED** (mesh is
  reachable): drive a real message, confirm the 0.5b picks a sensible skill → plan →
  runs; report it, do NOT assert it byte-exact in the suite.

**O6 — bump the planner model (supersedes branch/consolidate).** (revised 2026-08-18)
- WHY the revision: O5's live leg showed the 0.5b's miss is SYSTEMATIC, not variance
  (never picked `evidence-sift` for sort-claims). Branch/consolidate cures variance,
  not a systematic bias — so the right fix is a bigger planner model. Live probe
  (temp 0, real planner prompt): `qwen2.5:3b-instruct` 2/4 (unreliable); **`qwen3:4b`
  4/4** (sort→evidence-sift, decide→decision, research→research, rewrite→doc-edit) —
  the smallest reliable pick. Author call ("bump model size").
- Deliverable: change the orchestrator's model calls (the `be-chat` planner in
  `plan-message` AND the fan synth in `fan-synth` — a shared `synth-model` constant if
  they share one) from `qwen2.5:0.5b` → `qwen3:4b`. Make `parse-plan` ROBUST to a
  `<think>…</think>` block (scan only the text after `</think>` if present) — qwen3 is
  a thinking model; ollama returns thinking in a separate field so `content` is clean,
  but strip inline think anyway so parse is format-agnostic.
- Files: `turn.chiral` (model constant + be-chat calls), `orchestrate.chiral` (parse
  robustness), tests.
- Test: COMMITTED deterministic legs unchanged (parser on canned outputs incl. a
  `<think>…</think>`-wrapped reply → correct single name; dead-endpoint fallback).
  LIVE leg (mesh reachable): qwen3:4b via `be-chat` picks reliably across the 4 message
  types — verify + REPORT (incl. latency), not asserted byte-exact.
- NOTE: branch/consolidate (`flow-branch`, flow.chiral:861) stays available as a LATER
  fallback IF qwen3:4b proves unreliable at scale — not built now.
- SCOPE BOUNDARY: this bumps the ORCHESTRATOR's own calls only. The 6 skills still run
  their own Config model bindings (possibly 0.5b) — so skill OUTPUT quality is a
  SEPARATE bump that touches Configs / the MoE golden (non-goal §8; handle carefully,
  its own slice). Flag it; do not silently change skill Configs here.

**O7 — scriba plan surfacing.**
- Deliverable: show the plan in the transcript (which skills ran, combine-mode); a
  plan/ConvState inspector key (ties to TUI checklist T-C6a).
- Files: `command-loop.chiral` (`transcript-render`, a new row), PTY.
- Reused: `Exchange`/`transcript-render` (command-loop.chiral:1757/1784). New: plan row.
- Test: PTY — a fanned/chained message shows its plan; recompile scriba (flow-view
  exhaustive case) after any Flow ctor change.

---

## 6. Decisions (dispositioned)

- **Plan format.** RESOLVED (§4 closed sum: single/chain/fan/reply) —
  boundary-as-closed-sum, executor cases totally. Variant set RESOLVED (author call
  2026-08-18): `plan-branch` is NOT a first-class Plan variant — branch/consolidate
  is a planner-INTERNAL reliability mechanism (the pre-revision O6, now a deferred
  fallback since O6 shipped as the model bump), not a user-facing answer shape. Plan
  stays single/chain/fan/reply (code-confirmed: `orchestrate.chiral:39–43`).
- **Does `unknown` always get a plan (no dead-end)?** RESOLVED — yes, O1 makes every
  Intent map to a `Plan`. Default for unmatched asks RESOLVED (author call
  2026-08-18): **`unknown` → `plan-single "research"`** (attempt an answer), NOT the
  honest template. Accepted tradeoff: a research attempt on a codebase ask answers
  from the model's own priors, NOT repo contents (bounded by the supply/retrieval
  gap §7); SUPPLY-1 is minted in CHATTER-STATE to close that, and honest-defaults is
  preserved by SURFACING the limit, not by refusing to answer. (`social` → social
  template, `clarify` → ask-for-more; only `unknown` attempts research.)
- **chain vs fan vs branch default.** NEEDS-AUTHOR. Proposal: `plan-single` for a
  clear single-intent ask; `plan-chain` for sequential asks ("research then
  decide"); `plan-fan` for compare/overview asks. The DEFAULT combine-mode when the
  planner is unsure is a taste call.
- **Keep the pure-code router?** RESOLVED — yes, as the O1 fallback planner + the O5
  prior. Not thrown away (non-goal §8). Refinement thesis preserved.
- **Planner reliability: single pick vs harden.** RESOLVED-with-citation — started
  single (O5, 0.5b); O5 measured it SYSTEMATICALLY unreliable, so O6 escalated by
  BUMPING THE MODEL to qwen3:4b (`0eea1f6`), NOT branch/consolidate (a systematic
  miss isn't variance). branch/consolidate stays a later fallback only if qwen3:4b
  proves unreliable at scale. `manifest-all-green?` (flow.chiral:1039) is the
  acceptance signal.
- **Planner posture: code-prior vs model-primary.** DEFERRED / NEEDS-AUTHOR (open) —
  the code as built is **model-primary** (O5/O6: the qwen3:4b planner runs FIRST, the
  pure `plan-of-intent` is only the fallback). The diagnosis + the design maps
  (`CHATTER-MIX-MAP.md` §5–6, `CHATTER-FLOW-MAP.md`) **recommend the inverse** —
  **code-prior**: markers decide the confident cases, the model handles only the
  ambiguous residue (the M2 escalation ladder), on the latency + reliability evidence
  (0.5b pick systematically unreliable; the model path ~1000× slower). This is a
  RECOMMENDATION over the current code, NOT a decided reversal — the author's open call
  (tracked as deferred in CHATTER-STATE's ORCHESTRATOR ARC).
- **Reuse the MoE combiner vs a new synthesizer.** RESOLVED-partial — `flow-fan`'s
  by-id combiner (flow.chiral:821) fuses sub-FLOWS sharing one input Ty; fusing
  DIFFERENT skills' heterogeneous outputs needs a NEW small synth step (O4).
  Synth kind RESOLVED (author call 2026-08-18): **model synthesizer** (richer prose
  fusion), NOT the pure template. Caveat: it needs the 0.5b mesh (**since found
  reachable in-sandbox — §7**; the model prose leg CAN now be live-verified), so O4
  still ships a deterministic STRUCTURAL leg (synth assembles the fused reply from
  stubbed sub-outputs, mesh-free) + a Plan/output parser unit test as the committed
  proof, with the model prose leg verified live on the mesh.
- **Where the orchestrator lives.** RESOLVED — a new `scaffold/lib/manas/chatter/
  orchestrate.chiral` (keeps `router.chiral` the pure classifier, `turn.chiral` the
  runner); the orchestrator is itself a `Flow`.

---

## 7. Honest gaps & risks (no phantom deferrals)

- **Supply/retrieval front — THE blocker for "look at scriba and give an overview."**
  Even with full orchestration, no skill leaf can READ repo files: all 6 skills take
  the message text as their `doc` (skills.chiral samples), none fetch external
  content. A fact a leaf can't SEE can't be extracted (CHATTER-STATE honest gaps).
  Orchestration combines what the skills produce; it does not manufacture absent
  knowledge. **This is OUT of scope for O1–O7** and must be its own work. Because the
  author chose the research-attempt default (§6), a plan now DOES imply codebase Q&A
  is attempted — so per the guardrail, **`SUPPLY-1` is MINTED** in CHATTER-STATE's
  remaining-work table (retrieve context → inject into `sees`/`extra` → extract; its
  SUPPLY half is locally testable). The research attempt answers from model priors,
  NOT repo contents, until SUPPLY-1 lands — the honest limit is surfaced, not hidden.
- **`str-lower` / case-sensitivity.** router.chiral:28–34; O0 addresses it. Until O0,
  the pure fallback planner inherits the "Hello"→unknown miss.
- **Planner mesh-reliability.** CORRECTED 2026-08-18: the 0.5b mesh IS reachable
  in-sandbox (O4b invoked `be-chat` and got live qwen2.5:0.5b prose — "raw egress
  blocked" does not cover the local/private-mesh model endpoint). So O5's model leg
  CAN be live-verified. Discipline: COMMITTED tests stay deterministic (model output
  is non-deterministic — parser on canned outputs + a dead-endpoint fallback leg, per
  O4b's `127.0.0.1:1` pattern); the live model-picks-a-plan behavior is verified and
  REPORTED, not asserted byte-exact. Earlier "egress-blocked, not exercised" notes in
  C6b/O2 were unverified assumptions — the mesh works.
- **Tiny-model reliability of the pick.** Choosing from 6 is bounded but still a
  classification a 0.5b flubs SYSTEMATICALLY (measured — O5 live leg). Mitigation
  is O6 = the MODEL BUMP to qwen3:4b (the revised O6, `0eea1f6`; a systematic miss
  is not variance, so branch/consolidate can't cure it — a bigger planner does).
  branch/consolidate stays a LATER fallback only if qwen3:4b proves unreliable at
  scale. Do not report single-pick as proven reliable beyond the measured 4/4.
- **Cross-skill Ty compatibility.** `flow-fan` requires children share one input Ty
  (flow.chiral:147 `fan-check`). Skills have heterogeneous arrows (evidence-sift
  ty-doc→ty-verdict vs doc-edit ty-doc→ty-verdict — mostly ty-doc-in, but verify per
  skill). The O4 synth works over VERBALIZED strings (ty-text) to sidestep this;
  noted so O4 doesn't assume a typed fan over raw skill outputs.

---

## 8. Non-goals

- **Not a monolithic general chat.** No "general assistant" leaf (Principle #4).
- **Not a big-understanding model.** The orchestrator plans over a bounded menu; it
  does not ask a model to comprehend the world (the corrected anti-pattern).
- **Not discarding the working code fast-path.** `route-message` survives as the
  planner's prior/fallback.
- **Not building the supply/retrieval front here.** Named in §7, minted separately.
- **Not an engine change to the MoE golden.** The orchestrator composes ABOVE the
  skills; it does not modify `run-flow`/`plan-run` semantics (the MoE arc is golden-
  verified — leave it intact).

---

## 9. Build / test recipes

Do NOT reinvent — use the exact recipes in `.planning/CHATTER-STATE.md`:
- **Deterministic mesh-free chatter test** (router/turn/orchestrate) — the
  `chirality_blob … turn router profile/skills` recipe (with the `manas/core/skill`
  collision warning: use `profile/skills`, NOT `core/skill`).
- **scriba build (COMMITTED resolver only)** — `echo 'scriba/scriba-main' | resolve`,
  then B1; recompile scriba after ANY Flow/PureFn ctor change (`flow-view.chiral`
  exhaustive case).
- **PTY drive** — fork bash under a PTY (ioctl 40×120), chars one-at-a-time, `\r` to
  submit; verify the compiled binary.

B1 gotchas (CHATTER-STATE): flat `case`, nullary ctors WITH parens in patterns,
exhaustive `case`, `str-sub`/`str-find` are `(START, END)` END-EXCLUSIVE (segfaults
otherwise), a linear Backend must be INLINED into its consuming call (E137).
