# manas chatter — state & handoff (2026-08-17)

Start here in a fresh chat picking up the **general chatter**. It captures what the
chatter IS, what's built + verified (C1–C4), how to use it today, the concrete
remaining work (C5 + C6, minted here — not vague), the honest gaps, and the exact
build/test recipes. Companion docs: `.planning/MANAS-SKILL-GROWER.md` (the
refinement-pass + Flow-engine narrative this builds on — do NOT duplicate it) and
`.planning/SCRIBA-STATE.md` (the cockpit that hosts `:ask`).

> **NEXT ARC (2026-08-22): `.planning/CHATTER-ANSWER-QUALITY.md`.** The D&C machinery is
> done and the answers are still bad — for reasons that are OURS, not the 0.5b's. Read that doc
> before touching answer quality; it names the three changes and the two things not to do.

## What it is

A **general chatter with NO general mode.** Every user message is CLASSIFIED and
ROUTED to a named pipeline (a Flow-based skill). There is no monolithic-chat
fallback, no "general assistant" leaf — Principle #4 (general-purpose = a cop-out)
as architecture. Routing itself is symbol-manipulation, so per the refinement
thesis (see MANAS-SKILL-GROWER §REFINEMENT PASS) the router decides **in code**,
deterministically, no model. The model is only ever reached *inside* a routed
skill's Flow (and even there only for text-understanding steps). (NB: this describes
the **C1–C4 baseline**. O5 changed routing — the orchestrator now reaches a model
**planner** FIRST for the task intents, with the pure router as prior/fallback; see the
ORCHESTRATOR ARC section below. The "no general mode / every message routes to a named
pipeline" thesis still holds.)

The four pieces:

```
message ──route-message──▶ Intent ──intent->skill──▶ skill name ──run-flow-stop──▶ RunManifest
   (C1, pure)                          (C1, pure)                (C2, on the mesh)
                                                                        │
                                     verbalize-run (C3, pure) ◀─────────┘
                                                                        │
                          scriba :ask paints the prose (C4) ◀───────────┘
```

## Built + verified (C1–C4)

All four are committed and tested **deterministically, mesh-free** (no network,
no 0.5b) via the evidence-sift-refined model-free path — the whole classify →
route → run → verbalize chain runs offline because the routed skill
(`evidence-sift-refined`) is itself model-free (`flow-branch-pure` + `flow-pure`,
see MANAS-SKILL-GROWER). The model skill routes fire the same `turn` path on the
mesh.

### C1 — the pure ROUTER (`c68332f`)
- **File:** `scaffold/lib/manas/chatter/router.chiral` (+ `router-test.chiral`).
- **Key defs:** `Intent` = a CLOSED SUM (`in-social` / `in-analyze` / `in-decide`
  / `in-transform` / `in-factual` / `in-clarify` / `in-unknown`); `route-message :
  (-> Str Intent)` — a pure priority cascade of marker detection (reuses flow's
  `pure-has-any`), first-match-wins in the order social → decide → analyze →
  transform → factual → clarify(<3 non-space chars) → unknown; `intent->skill :
  (-> Intent (Maybe Str))` — the route table into the registry
  (analyze→`evidence-sift`, decide→`decision`, transform→`doc-edit`,
  factual→`research`; social/clarify/unknown → `none`, no skill); `intent-name`
  for display. Marker vocabularies are per-category substring lists
  (`social-markers`, `decide-markers`, …). Pure, total, additive; imports only
  prelude + `prapanca/core/flow`.
- **Tested:** `router-test.chiral` (deterministic) — 7 representative messages route
  to the expected intent + skill; exit 0.

### C2 — the TURN LOOP (`d9b3629`)
- **File:** `scaffold/lib/manas/chatter/turn.chiral` (+ `turn-test.chiral`).
- **Key defs:** `turn : (=> (1 b Backend) Str Str)` — routes a message, then either
  dispatches to the routed skill (`run-skill-turn`: `skill-by-name` →
  `run-flow-stop` with the message as input, `stop-single`) and verbalizes the
  manifest, or returns `no-skill-reply` (templated) for social/clarify/unknown.
  `run-skill-turn : (=> (1 b Backend) Str Str RunR)`. The linear Backend is moved
  EXACTLY ONCE on every path (skill: threaded into `run-flow-stop`, then the
  returned handle is `backend-close`d; no-skill: `backend-close` directly).
- **Tested:** `turn-test.chiral` (deterministic, mesh-free) — templated replies for
  social/clarify/unknown; a numbered-list "sort these…" routes to `in-analyze` →
  `evidence-sift`; and a FULL turn dispatched to the model-free
  evidence-sift-refined → `manifest-all-green?` = true + verbalize non-empty, zero
  network; exit 0.

### C3 — VERBALIZE (`62e7ebe`)
- **File:** `scaffold/lib/manas/chatter/turn.chiral` (verbalize section; C3 lives in
  the same file as C2).
- **Key defs:** `verbalize-run : (-> Intent RunManifest (List RawCall) Str)` — pure,
  total, no model. Dispatches on Intent. For `in-analyze` it finds the consolidate
  tally raw (`find-track-raw`, the response containing `"evidence-track"`) and reads
  the evidence/speculation counts (`count-after-marker` + `digit-run-go`, a guarded
  digit run — `str-sub` is only ever `(i, i+1)`, never a length-as-END, so no
  out-of-bounds), producing e.g. **"I sorted the flagged items: 2 supported by
  evidence, 2 held as speculation."** decide/factual/transform share
  `verbalize-generic` (a light frame; strips JSON-ish yields via `looks-jsonish?`).
  Missing/malformed tally → an honest generic line, never raw JSON, never a crash.
- **Tested:** `turn-test.chiral` now asserts the evidence-sift-refined turn response
  is CONVERSATIONAL — contains "evidence"/"speculation"/"2" and does NOT contain
  `kind` or `[{`; exit 0.

### C4 — scriba `:ask` (`8cc6c1a`)
- **File:** `TUI/scriba/command-loop.chiral` (`chatter-ask`, wired into the `:`
  command dispatch as the `"ask "` arm).
- **Key defs:** `chatter-ask` calls `turn` with the message; opens the mesh Backend,
  INLINES it into the `turn` call (moved once, mirroring `flow-load-view`'s shape —
  NOT let-bound), paints an ASK header + the response, status `ask: <msg>`, returns
  to Normal.
- **Tested:** PTY-verified on the compiled binary (committed resolver, 1192312 B):
  `:ask hi there` → social template "I route each ask to a pipeline…"; `:ask xyzzy
  qwerty` → "I don't have a pipeline for that yet." — both deterministic no-mesh
  routes. The skill routes (analyze/decide/factual/transform) fire their Flow on the
  0.5b mesh via the same `turn` path.

## How to USE it now (honest) — the arc is COMPLETE (C1–C6b)

Launch `./bin/scriba`. Two entries, both routed through `turn-seq` (compound-aware):
- **`:ask <message>`** — a ONE-SHOT: route → run pipeline → paint one routed answer →
  back to Normal. A compound `:ask` ("research X then decide Y") decomposes too.
- **`:chat`** — the interactive LOOP (C5): each message appends `you → intent →
  reply` to a scrolling transcript and stays until ESC. It is now a real
  conversation: ConvState (C6a) threads across turns so bare follow-ups ("what about
  the second one?") reuse the prior intent, and compound messages (C6b) decompose
  into sequenced sub-turns with each part's result carried into the next.

Remaining is polish, not capability: the TUI checklist below (scrollback, per-intent
rendering, ConvState inspector) + the standing chatter limits in "Honest gaps"
(no `str-lower`, generic verbalize off the analyze path, unbuilt supply/retrieval
front — the last is what would let a leaf actually *read* the threaded prior context).

## REMAINING — C5 + C6 (concrete, minted here)

### C5 — interactive CHAT mode (the loop)
A scriba top-level mode that **LOOPS `turn`** instead of the one-shot `:ask`:
appends each `you → routed-intent → response` exchange to a scrolling transcript
and stays in the mode until ESC.

- **Likely shape:** a new `VimMode` variant carrying the transcript (a `List` of
  exchange rows — `you`/`intent-name`/`response`), or reuse the existing chat
  submode's plumbing. A dispatch that: reads a line (the same `vim-line-read` /
  minipuffer path `:ask` uses), calls `turn`, appends the exchange, repaints the
  transcript, waits for the next line; ESC exits to Normal.
- **Linear-Backend discipline (critical):** `turn` CONSUMES its Backend (moves it
  once). So the loop must **open a fresh mesh Backend per turn** and move it into
  that turn's `turn` call — you cannot open one handle and reuse it across
  iterations. Mirror `chatter-ask`'s inline-move shape inside the per-turn step.
- **Where it plugs in:** a new `command-loop-inner` arm for the top-level CHAT mode
  (see SCRIBA-STATE "How the dispatch encodes this"); the render is a transcript
  view (reuse the run-view/rendering-tree helpers).
- **Test:** PTY — enter chat mode, send two messages, assert both exchanges appear
  in the transcript with their routed intent tags; ESC returns to Normal. A
  deterministic leg uses only social/unknown messages (no mesh); a live leg sends an
  analyze message to exercise the 0.5b path.

### C5 — DONE (`94f6ed1`)
Built as `chatter-chat` / `chatter-chat-loop` in `command-loop.chiral`: `:chat`
enters an interactive mode that loops `turn` into a scrolling transcript
(`Exchange` = you/intent/reply, `transcript-render` via the rendering tree),
fresh mesh Backend inline-moved per turn (E137), ESC → Normal. No new `VimMode`
variant needed — the prompt-driven loop owns its own `vim-line-read`. Deterministic
mesh-free PTY leg (two exchanges + tags + ESC) and live 0.5b analyze leg both
verified. Residue: no scrollback (→ T-C5a); `gc` still reaches the legacy
single-model chat (intentional, non-destructive).

### C6a — DONE (`b002c93`)
`ConvState` = closed sum `(conv-empty)` / `(conv-state (last-intent Intent)
(last-message Str) (last-reply Str) (turn-count I64))` in `router.chiral` (last turn
only; a wider window is additive). `resolve-intent` is the pure follow-up pre-check
in front of `route-message`: with a prior turn, a bare referential fragment reuses
the prior Intent, else routes fresh. `conv->extra` serializes prior intent/message/
reply into the `run-flow-stop` `extra`/`sees` pair list (was a hard `nil`). `turn`/
`run-skill-turn` gained the memory+extra args (linear Backend still moved once,
E137). C5 loop threads + updates ConvState per turn. Verified: unit test exit 0
(the `unknown`→reused-`analyze` delta on "what about the second one?" IS the
memory) + mesh-free PTY (live follow-up reused the prior social route, never hit
the `unknown` template). Mesh leg not exercised (egress blocked); deterministic
legs carry the proof.
- **Residue (within scope, not phantom):** the `extra` context is threaded and
  visible to leaves, but no routed leaf yet *reads* prior-message/prior-reply — the
  seam is proven, leaf *consumption* of prior context is the natural next step (ties
  into the unbuilt supply/retrieval front in "Honest gaps"). Fold into whichever
  slice first needs a leaf to see prior context; mint a row if it grows its own dep.

### C6a spec (as-built above) — ConvState + follow-up resolution (conversation memory)
State threaded through the loop so turn N+1 sees turn N — what makes it "get
somewhere" instead of N independent one-shots.

- **Shape:** a `ConvState` value (last topic / last skill / recent entities / recent
  turns) threaded INTO `turn` as an `extra` argument. `run-flow-stop` already takes
  an `extra`/`sees`-style slot (the trailing `nil` in `run-skill-turn`) — thread the
  serialized `ConvState` there so the routed Flow's leaves SEE prior context.
- **What it unlocks:** follow-ups ("what about the second one?", "and the third?")
  resolve against `ConvState` (the prior turn's items/verdicts), instead of routing
  as a fresh, context-free message; the router gains a "follow-up" pre-check that
  reuses the last Intent when the message is a bare referential fragment.
- **Test:** deterministic — a two-message transcript where message 2 is a follow-up
  ("the second one") asserts the response references the prior turn's item, proving
  `ConvState` threaded.

### C6b — DONE (`f32f247`)
`split-conjunctions : (-> Str (List Str))` (pure, total, fuel=`str-len`) splits on
`conj-markers = [" and then ", " then ", " after that ", "; ", ";"]` by earliest
index (`" and then "` before `" then "` so no dangling "and"); NO conjunction → a
one-element list (common case byte-identical to the old one-shot). `turn-seq :
(=> Str ConvState Str (Pair ConvState Str))` runs each part through `turn`, threading
ConvState part→part (C6a mechanism), a FRESH Backend inline-moved per part (N parts =
N moves, E137); single part untagged, multiple parts tagged per routed intent, chat
tag = `"compound"`. The C5 loop and `:ask` both route through `turn-seq`. Verified:
unit test exit 0 (splitter cases + regression guard "plain" → 1 part + a compound
firing two sub-turns with part 2 reusing social via threaded ConvState +
`turn-count = 2`) and PTY (compound message → `compound` tag + ≥2 sub-turns, part 2
not the unknown template, ESC → Normal). Mesh not exercised (egress blocked);
model-free legs carry the proof.

### C6b spec (as-built above) — compound-intent decomposition
- **Compound-intent decomposition:** a message like "research X then decide Y"
  decomposes into a SEQUENCE of turns (`in-factual` on X, then `in-decide` on Y with
  X's result in `ConvState`) — a small pure splitter over conjunctions, each part run
  through `turn`, results accumulated. This is the "chain of asks" the flat one-shot
  can't express. Depends on C6a (`ConvState` must exist to carry X's result into Y).
- **Test:** deterministic — a compound message asserts two routed sub-turns fired,
  the second seeing the first's result via `ConvState`.

> Both C5 and C6 are minted here as the chatter's remaining work — no phantom
> deferral. If either grows a dependency on an engine primitive that doesn't exist
> yet (e.g. a `sees`-threading seam `turn` lacks), mint that as its own row here +
> in the L0 table of MANAS-SKILL-GROWER before deferring to it.

## TUI work — AFTER C5/C6 (checklist, scheduled not blocking)

Cockpit polish that only makes sense once the CHAT loop + memory exist, plus the
pre-existing scriba open items. Ordered; each is a commit-sized slice. Not phantom
— the pre-existing ones are cross-referenced to their authority in SCRIBA-STATE.

**Chatter-derived (unlocked by C5/C6):**
- **T-C5a — transcript scrollback / paging.** Once CHAT loops, long transcripts
  overflow the viewport. Add scroll (`C-u`/`C-d` or `j/k` over the transcript) +
  a "N earlier turns" indicator. Cosmetic until a transcript is long enough to
  clip — hence after C5, not part of it.
- **T-C5b — per-intent chat rendering.** Tag each exchange row with its routed
  intent (color/label chip) and render the routed answer distinctly from the
  `you →` line. Reuse the rendering-tree; richer than C5's plain transcript.
- **T-C6a — ConvState inspector.** A key in CHAT mode that paints the live
  `ConvState` (last topic/skill/entities) so the memory is legible, not invisible.

**Pre-existing scriba open items (authority: SCRIBA-STATE "KNOWN GAPS"):**
- **T-B — `:manas` browser inline candidate list.** Currently Tab-completion only;
  a scrollable inline list is polish (SCRIBA-STATE gap 2 UX caveat).
- **T-W — long-row wrap/scroll.** EXPERTS row + any wide row truncates at terminal
  width, no wrap (SCRIBA-STATE slice B residue).
- **T-SliceC — per-Expert fields (DESIGN-BLOCKED).** lens/sees/returns/slot/tools;
  needs the `doc-expert` view design call FIRST (SCRIBA-STATE slice C).
- **T-SliceD — actuate ORDER (ENGINE).** `plan-run` (`plan.chiral:97`) ignores the
  pipeline `Order`; the `o` editor changes the view but not the run (SCRIBA-STATE
  slice D). Engine change against the MoE golden — CONFORM check.
- **T-Type — VimMode two-level type split.** ~130-site mechanical; low value.

## ORCHESTRATOR ARC — ACTIVE, model bumped (2026-08-18)

> **STATUS: RESUMED.** O0–O6 built + committed. The O5 finding (0.5b pick unreliable)
> was fixed by BUMPING THE PLANNER MODEL, not by shelving — author call ("bump
> model size and continue"). Live probe picked **qwen3:4b** as the smallest reliable
> planner (4/4 vs the 0.5b's systematic miss). **O6 = the model bump** (`0eea1f6`,
> supersedes branch/consolidate — a bigger model fixes a systematic miss that
> consolidation can't). Only O7 (scriba plan surfacing) remains. Skill-Config model
> bumps (skill OUTPUT quality) are a SEPARATE later slice (touches the MoE golden).

The chatter's orchestrator front: turn `route-to-one-skill-or-dead-end` into a small
**orchestration that combines the working pipelines** (message → a `Plan` over the
6-skill menu → execute by reusing `turn-seq`/the combiner → one reply). Full design,
grounded slices, dispositioned decisions = **`.planning/CHATTER-ORCHESTRATOR-SCOPE.md`**.

**Chatter design doc set (read in this order):**
1. `CHATTER-MIX-MAP.md` — the code/model principle: AI = PORTS (typed protocol + closed-sum
   egress parsed at the boundary, opaque English inside); code = the typed spine; more seams
   = more ports, never types on the English.
2. `CHATTER-FLOW-MAP.md` — how a message flows: turn = a branch (DIVIDE → PARALLELIZE across
   specialists → CONSOLIDATE), fractal, with controlled context as attenuated grants; includes
   a fine-grain worked trace.
3. `CHATTER-QUALITY-DIAGNOSIS.md` — the answer-quality finding (downstream of O6, DISTINCT
   from the O5/O6 planner-routing fix): bigger SKILL models do NOT fix the weak answer (the
   rich sentence is code `pf-tally`, no model emits it); the model path is also ~1000× slower.
   Grounds the mix/flow maps in measured evidence.
4. `CHATTER-ORCHESTRATOR-SCOPE.md` — the O0–O7 build ledger (partially superseded by the maps:
   the maps' port/escalation framing refines the scope's "typed seam" language, and the
   code-prior posture is now the evidence-backed recommendation over O5's model-primary).
5. `CHATTER-DC-FIXES.md` — the sliced fix plan + **agent-dispatch handoff** to turn the
   chatter into a functioning divide-and-conquer chat (F1–F7 → DC-slices, waves, gating
   decisions, dispatch discipline). Start here to orchestrate the next build.
6. This file — state/handoff + commit map.

Built + committed: **O0** str-lower `81c9f96` · **O1** Plan sum + pure planner
`9677851` · **O2** execute-plan (turn through the Plan) `1e34bea` · **O3** plannable
skill menu `e923e27` · **O4a** plan-chain + endpoint backend seam `df0dd67` · **O4b**
plan-fan + model synth (pure-template fallback) `f052e6f` · **O5** model planner
(0.5b picks from the menu, pure fallback) `65b1df3` · **O6** bump planner+synth model
to qwen3:4b + think-robust parse `0eea1f6`.

Deferred (on resume): **O7** scriba plan surfacing · **the planner-posture decision**
(§6 of the scope — pure-prior vs model-primary vs prompt-tune; see finding). NOTE:
branch/consolidate hardening (the pre-revision O6) is SUPERSEDED by the model bump —
it stays available as a LATER fallback only if qwen3:4b proves unreliable at scale.

**KEY FINDING (O5 live leg, durable):** the 0.5b's single planner pick is UNRELIABLE
and WORSE than the deterministic code router for marker-matchable messages — for
"sort these claims" the markers correctly route `evidence-sift`, but the 0.5b picked
`doc-edit`/`code-test`, varied run-to-run, and never picked `evidence-sift`. This is
the refinement thesis as DATA (code > 0.5b at classification). Implication: O6
branch/consolidate cures VARIANCE, not this SYSTEMATIC miss — the resume should
weigh pure-prior-model-for-residue over model-primary. Also corrected: **the 0.5b
mesh IS reachable in-sandbox** (local/private endpoint; "raw egress blocked" ≠ mesh
blocked) — earlier C6b/O2 "egress-blocked" notes were unverified assumptions.

- **SUPPLY-1 — the supply/retrieval front (MINTED, not yet started).** No skill leaf
  can READ repo files today — all 6 skills take the message text as their `doc`. So
  the `unknown → research` default *attempts* codebase Q&A but answers from model
  priors, not repo contents. SUPPLY-1 closes it: retrieve context → inject into the
  `sees`/`extra` slot (the C6a channel) → a leaf extracts from it. Its SUPPLY half
  (retrieve + inject) is locally testable and is the entry point. This is the real
  blocker behind "look at scriba and give an overview"; orchestration (O0–O7) does
  NOT fix it. Depends on nothing; unblocks grounded factual/analyze chat.

## Honest gaps (named, not phantom-deferred)

- **No `str-lower`** → markers match CASE-SENSITIVELY against the common lowercase
  casing users type. A shouted "SORT THESE" misses `sort ` and falls to `in-unknown`.
  The additive `str-lower` normalization pass is named for a later slice (router.chiral
  header). This is a real limitation, not a defect.
- **verbalize is rich only for `analyze`.** `in-analyze` gets the two-track evidence
  /speculation sentence; decide/factual/transform share `verbalize-generic` (a light
  "here's what the X pipeline produced" frame). Richer per-intent prose is future work.
- **The supply/retrieval front is unbuilt.** For `factual` asks especially: a fact a
  leaf can't SEE can't be extracted — no grain manufactures absent knowledge (see
  MANAS-SKILL-GROWER §REFINEMENT PASS, the "supply/retrieval stage" note). Factual
  chat is bounded until a supply stage (retrieve context → inject into `sees` →
  extract) exists. Its SUPPLY half is locally testable; that's the entry point.

## Build + test recipes (copy exactly)

### Deterministic mesh-free chatter test (router / turn)
```
. bin/chirality-resolve.sh
chirality_blob scaffold/lib prapanca/chatter/turn prapanca/chatter/router prapanca/profile/skills > blob
cat scaffold/lib/manas/chatter/turn-test.chiral >> blob   # (or router-test.chiral)
echo >> blob
for l in tal-ir crossing-wraps sys-check target-linux sys-tal sys-linkage; do cat scaffold/lib/$l.chiral >> blob; echo >> blob; done
ulimit -s unlimited
./scaffold/build/B1 < blob > t.elf && chmod +x t.elf && ./t.elf; echo $?
```
**DO NOT add `prapanca/core/skill` to the closure** — it collides with `profile/skills`
on `skill-by-name`. The chatter closure needs only `profile/skills`.

### scriba build (COMMITTED resolver only)
```
B1=./scaffold/build/B1; RESOLVE=./scaffold/build/resolve
blob=$(mktemp); echo 'scriba/scriba-main' | "$RESOLVE" > "$blob"
for l in crossing-wraps sys-check target-linux sys-tal sys-linkage; do cat scaffold/lib/$l.chiral >> "$blob"; echo >> "$blob"; done
ulimit -s unlimited; "$B1" < "$blob" > /tmp/scriba.elf && chmod +x /tmp/scriba.elf
# bin/scriba does the same build+exec interactively.
```
Use the **committed resolver** (`scaffold/build/resolve`), NOT the shell
`chirality_blob` resolver — for scriba the latter yields a broken closure ("zb-move" /
broken scriba closure).

### PTY drive (verify the compiled binary)
Fork a bash exec'ing `/tmp/scriba.elf` under a PTY (`pty.fork` + `ioctl TIOCSWINSZ`
40×120), **send chars ONE AT A TIME**, and send `\r` to submit a `:` command. e.g.
type `:ask hi there` then `\r`; read the painted screen.

## B1 gotchas (from this session's commits)

- **`str-sub`/`str-find` are `(START, END)`, END EXCLUSIVE** — NOT `(START, LEN)`.
  Passing a length as the END index when `START > value` reads out-of-bounds and
  **SEGFAULTS** (this bit `pure-line-after`/`next-field` in `595cb96`; C3's
  `digit-run-go` is written so END is always `START+1`, always in-bounds).
- **A linear Backend must be INLINED** into its consuming call, not let-bound then
  let-`_`-closed — the let-bound form mis-reads as **"field binder usage mismatch"**
  (E137 discipline; `turn`/`chatter-ask` both move it exactly once inline).
- Flat `case` patterns; **nullary ctor WITH parens** (`(in-social)`, not `in-social`
  in a pattern); exhaustive `case`; a non-final `do` step must be `Unit`.
- **After ANY Flow/PureFn constructor change, RECOMPILE scriba** — `flow-view.chiral`
  has an exhaustive `case` over the Flow sum (adding `flow-pure`/`flow-branch-pure`
  broke it in `d08d109`). Rebuild via the committed resolver.

## File + commit map

| Piece | File(s) | Commit |
|---|---|---|
| C1 router | `scaffold/lib/manas/chatter/router.chiral` (+ `router-test.chiral`) | `c68332f` |
| C2 turn loop | `scaffold/lib/manas/chatter/turn.chiral` (+ `turn-test.chiral`) | `d9b3629` |
| C3 verbalize | `scaffold/lib/manas/chatter/turn.chiral` (verbalize section) | `62e7ebe` |
| C4 scriba `:ask` | `TUI/scriba/command-loop.chiral` (`chatter-ask`) | `8cc6c1a` |
| C5 interactive chat loop | `TUI/scriba/command-loop.chiral` (`chatter-chat` / `chatter-chat-loop` / `Exchange` / `transcript-render`) | `94f6ed1` |
| Skill registry (routed targets) | `scaffold/lib/manas/profile/skills.chiral` | `7838921` |
| Flow-engine substrate (flow-pure / flow-branch-pure / PureFn) | `scaffold/lib/manas/core/flow.chiral` | see MANAS-SKILL-GROWER + CONFORMANCE-MAP |
| C6a ConvState + follow-up resolution | `router.chiral` (`ConvState`/`is-followup?`/`resolve-intent`/`conv-update`/`conv->extra`) + `turn.chiral` (`turn`/`run-skill-turn` gain memory+extra args) + `command-loop.chiral` (loop threads it) | `b002c93` |
| C6b compound-intent decomposition | `router.chiral` (`split-conjunctions`) + `turn.chiral` (`turn-seq`/`turn-seq-go`/`chat-tag`) + `command-loop.chiral` (loop + `:ask` route through `turn-seq`) | `f32f247` |
</content>
</invoke>
