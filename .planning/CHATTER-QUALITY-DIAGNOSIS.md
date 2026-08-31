# Chatter answer-quality diagnosis — why "sort these claims" answers weakly

**Date:** 2026-08-18 · **Status:** DIAGNOSTIC (read-only; nothing in the committed tree changed).
**Symptom:** the router/planner now route "sort these claims" correctly (O6: qwen3:4b →
`evidence-sift`), but the live reply is the generic **`"The analyze pipeline ran."`** instead
of the rich **`"I sorted the flagged items: N supported by evidence, M held as speculation."`**

All outputs below are ACTUAL captured strings from live runs against the mesh
(`http://100.64.0.5:11434`), driven by a throwaway B1-compiled diagnostic
(`scratchpad/diag-test.chiral`, reverted/never committed). The concrete message is the
`flags-doc` sample from `skills.chiral` (the O6 message: a 4-item numbered list, 2 cited /
2 speculative).

---

## TL;DR

- **Failing link (pinpointed):** `verbalize-analyze` → `find-track-raw` returns `none`
  because **no RawCall in the model (`evidence-sift`) run contains the substring
  `"evidence-track"`** → falls to `"The analyze pipeline ran."`.
- **Root cause (primary):** the `evidence-track … count=N` markers `verbalize-analyze` scans
  for are a **machine format emitted ONLY by `pf-tally` (pure CODE)** in the
  `evidence-sift-refined` backtrack. The MODEL skill `evidence-sift` has a **model**
  consolidate leaf whose PROMPT asks for `{kind,target,body}` JSON — it never emits those
  literal markers. This is **prompt/flow-shaped, not model-strength-shaped**.
- **Hypothesis test verdict:** binding `evidence-sift` to **qwen3:4b** and **qwen3:8b** and
  re-running live → **BOTH still produce `"The analyze pipeline ran."`** The bigger models
  classify *better* but STILL emit zero `evidence-track`/`count=` markers. **"Bump the skill
  model" does NOT fix it** — disproven with captured output.
- **Working baseline:** `evidence-sift-refined` on the SAME message → the rich sentence,
  **deterministically, mesh-free, in ~0.03s**.
- **Recommendation:** route analyze to `evidence-sift-refined` (via the planner MENU +
  the pure fallback), OR give `evidence-sift` the same code tally backtrack. NOT a model bump.

---

## Stage-by-stage quality-loss map

### Stage 1 — Plan (qwen3:4b planner, `plan-message` / `parse-plan`)

Live, 3 runs, exact reconstructed `plan-prompt` (menu + message + "reply with ONLY the
name(s)"):

```
run1 (6.5s): 'evidence-sift'
run2 (3.9s): 'evidence-sift'
run3 (2.7s): 'evidence-sift'
```

- The planner reliably picks **`evidence-sift`** — the 0.5b MODEL skill — **3/3**, never
  `evidence-sift-refined`.
- `evidence-sift-refined` **IS** in the plannable menu (`plannable-skills`,
  `skills.chiral:73`, described "model-free, refined") — so the planner is *offered* it and
  *could* name it. It doesn't. (Same refinement-thesis lesson as O5: the model prefers the
  shorter/plainer name; prompt-nudging it toward `-refined` would be unreliable.)
- `parse-plan` then yields `plan-single "evidence-sift"` (no substring-subsumption issue:
  the reply `"evidence-sift"` doesn't contain `"evidence-sift-refined"`).

**Verdict: routing is fine; the planner correctly identifies the task — it just points at the
variant whose answer can't be verbalized richly.**

### Stage 2 — Skill execution: `evidence-sift` (0.5b), the real chatter path

`run-skill-turn "evidence-sift"` live → `green=true`, 11 RawCalls. EVERY raw has
`has(evidence-track)=false`. The consolidate leaf (the one `verbalize-analyze` depends on):

```
RAW eid=evidence-sift-consolidate model=qwen2.5:0.5b  has(evidence-track)=false has(count=)=false
  resp=[```json
  [
    {"kind":"evidence","target":"the library has introduced new features...","body":"..."},
    {"kind":"held-speculation","target":"the latest stable release does not mention...","body":"..."}
  ]
  ```]
```

- The 0.5b's per-item work is also **semantically garbage** (hallucinated targets: "Erlang 19
  design influence", "(79) has introduced new features…") — but that is a SEPARATE problem.
- The decisive fact: the consolidate response uses `"kind":"evidence"` / `"held-speculation"`
  — **not** the literal `evidence-track` label, and there is **no `count=`** anywhere.

**`VERBALIZE=[The analyze pipeline ran.]`** ← the exact weak reply, reproduced.

### Stage 3 — Verbalize (`verbalize-analyze`, `turn.chiral:109`)

Stepping the extraction on the Stage-2 raws:

1. `find-track-raw raws` — scans each RawCall response for substring `"evidence-track"`.
   **No raw contains it → returns `none`.**
2. `verbalize-analyze` hits the `(none "The analyze pipeline ran.")` arm and returns.

The chain never reaches `count-after-marker`. (Even if `find-track-raw` had matched,
`count-after-marker rp "evidence-track"` then needs `"count="` after the marker — which no
model output contains either, so it would fail at the next link regardless.)

**Failing link = `find-track-raw` returns `none` (no `evidence-track` substring in the
model-path raws).**

### Stage 4 — Working baseline: `evidence-sift-refined` (model-free), SAME message

`run-skill-turn "evidence-sift-refined"` live → `green=true`, 11 RawCalls, all
`model=code`. The pf-tally raw:

```
RAW eid=flow-pure model=code  has(evidence-track)=true has(count=)=true
  resp=[[{"kind":"evidence-track","target":"consolidated","body":"count=2"},
         {"kind":"speculation-track","target":"consolidated","body":"count=2"}]]
```

**`VERBALIZE=[I sorted the flagged items: 2 supported by evidence, 2 held as speculation.]`**
← the rich sentence.

**Where the markers come from:** `evidence-sift-refined-backtrack`
(`evidence-sift-refined.chiral:62`) replaces the model consolidate with
`(pf-tally "evidence" "speculation" "evidence-track" "speculation-track")`. `run-pure`
(`flow.chiral:358`) emits the literal
`[{"kind":"evidence-track",…,"body":"count=<ca>"},{"kind":"speculation-track",…,"body":"count=<cb>"}]`.
The `evidence-track` label and `count=` token are **hard-wired code output**, matched
byte-for-byte by `verbalize-analyze`. The MODEL path has no such code step — its consolidate
is a model leaf asked for free `{kind,target,body}` JSON.

### Stage 5 — Hypothesis test: does a BIGGER skill model help? (NO)

Bound the `evidence-sift` FLOW (same experts/prompts) to bigger models and re-ran live.

**C — evidence-sift @ qwen3:4b** (`green=true`). Consolidate leaf output — note the
classification is now *correct* (3 evidence, 1 speculation), but the format is unchanged:

```
RAW eid=evidence-sift-consolidate model=qwen3:4b  has(evidence-track)=false has(count=)=false
  resp=[[ [ {"kind":"evidence","target":"The 2019 benchmark…"}, {"kind":"evidence","target":"…Erlang…"},
            {"kind":"evidence","target":"CVE-2021-1234…"} ],
          [ {"kind":"speculation","target":"Users likely prefer…"} ] ]]
```
**`VERBALIZE=[The analyze pipeline ran.]`**

**D — evidence-sift @ qwen3:8b** (`green=true`). Best classification yet (correctly demotes
the Erlang guess to speculation):

```
RAW eid=evidence-sift-consolidate model=qwen3:8b  has(evidence-track)=false has(count=)=false
  resp=[[{"kind":"evidence","target":"The 2019 benchmark…"},{"kind":"evidence","target":"CVE-2021-1234…"},
         {"kind":"speculation","target":"…Erlang…"},{"kind":"speculative association","target":"Users likely prefer…"}]]
```
**`VERBALIZE=[The analyze pipeline ran.]`**

**Verdict:** bumping the skill model improves the *classification quality* but produces the
**identical weak reply**, because the marker format is set by the PROMPT (which asks for
`{kind,target,body}`), not by the model's competence. Note also the model output DRIFTS across
runs/models: `evidence` / `supported_evidence` / `speculation` / `held-speculation` /
`speculative association` / `speculative_association`, and flat-array vs nested `[[…],[…]]`
shapes — exactly the freeform variance the code-tally seam exists to avoid.

---

## Root cause(s) — which of (a)-(d) are true, with evidence

| # | Candidate cause | True? | Evidence |
|---|---|---|---|
| (a) | Planner picks the model variant, not `-refined` | **TRUE (contributing)** | qwen3:4b picks `evidence-sift` 3/3; `-refined` is offered in the menu but never chosen. |
| (b) | 0.5b too weak to emit markers | **FALSE (as the cause)** | 0.5b output IS garbage, but qwen3:4b/8b classify well and STILL don't emit the markers. Model strength is orthogonal to the failing link. |
| (c) | Skill PROMPT/Flow doesn't elicit the marker format regardless of model | **TRUE — PRIMARY** | C (4b) + D (8b) both produce correct sorts with zero `evidence-track`/`count=`; the consolidate expert's `returns` asks for `{kind,target,body}`, never the tally markers. |
| (d) | Verbalize extraction too brittle | **TRUE (structural)** | `verbalize-analyze` is byte-coupled to the `pf-tally` code format (`evidence-track` + `count=N`); it cannot read ANY model's freeform/JSON sort, however correct. |

**In one line:** the analyze verbalizer only understands the machine format its own CODE tally
emits; the model skill never emits that format, so it always falls through — model size is
irrelevant.

---

## Latency budget (measured, single-GPU mesh — calls SERIALIZE)

| Stage | Model | Measured | Notes |
|---|---|---|---|
| Planner pick (`plan-message`) | qwen3:4b | **2.7–6.5s** | short output ("evidence-sift"); 3 live runs |
| Per-leaf (short JSON) | qwen2.5:0.5b | **~2.7s** idle | |
| Per-leaf (JSON + thinking) | qwen3:4b | **~3–30s** | thinking block + occasional model swap; high variance |
| `evidence-sift` skill (11 leaves) | qwen2.5:0.5b | **~30–60s** | 11 serialized 0.5b calls |
| `evidence-sift` skill (11 leaves) | qwen3:4b / 8b | **8m40s for BOTH flows** (22 calls) | thinking models, serialized; ~23s/call amortized |
| `evidence-sift-refined` skill | code (mesh-free) | **~0.03s** | zero network; the deterministic test leg |
| **Full turn, model plan-single** | qwen3:4b plan + 0.5b skill | **~35–65s** | planner + one skill run |
| **Full turn, plan-fan/chain (K skills)** | | **planner + K × skill** | fan/chain multiply the skill cost by K; K+1 backends |

Two independent latency reasons to prefer the refined path for analyze: it is **~1000× faster**
(0.03s vs 30–60s) AND **deterministic + offline**.

---

## Fix space

### Fix 1 — Route analyze → `evidence-sift-refined` (RECOMMENDED for the symptom)
- **What:** make the analyze skill the model-free refined variant.
- **Cost:** small, but must be applied at the RIGHT levers (two of them):
  1. `plannable-skills` (`skills.chiral:69`) — the MODEL planner picks from this menu and it
     picked `evidence-sift`. **Remove `evidence-sift` from the menu (leave only
     `evidence-sift-refined`)**, or have `parse-plan` map `evidence-sift`→`evidence-sift-refined`.
     Changing `intent->plan` alone is INSUFFICIENT — the model planner overrides it.
  2. `intent->plan` (`orchestrate.chiral:64`) — the PURE FALLBACK still hard-codes
     `plan-single "evidence-sift"`. Point it at `evidence-sift-refined` too, so the dead-mesh /
     empty-reply fallback path is also rich.
- **Evidence for:** Stage 4 — refined yields the exact rich sentence, deterministically,
  mesh-free, ~0.03s.
- **Does NOT fix:** refined's perspectivist is `pf-split-numbered` — it needs **numbered-list**
  input; for unstructured PROSE analyze it won't split (the model perspectivist variant exists
  for that). And decide/factual/transform stay on `verbalize-generic`. For the reported case
  (a flags list) it is a complete fix.

### Fix 2 — Bump `evidence-sift`'s Config model to qwen3:4b/8b (REJECT)
- **Cost:** high — touches the MoE golden (`evidence-sift-config`), latency 30s+/leaf,
  8m40s for the two flows here.
- **Evidence against:** Stage 5 — C and D both still return `"The analyze pipeline ran."`
  **Disproven.** Does not fix the answer at all.

### Fix 3 — Rewrite the consolidate PROMPT to ask for `evidence-track … count=N` (WEAK)
- **Cost:** medium — edit `evidence-sift-consolidate`'s `returns`.
- **Problem:** counts would then be MODEL-computed (unreliable — the 0.5b/4b mis-tally), and
  output still drifts in format. Reintroduces exactly the model-counting fragility the
  refinement pass removed. Partial at best.

### Fix 4 — Make `verbalize-analyze` parse freeform model JSON (WEAK)
- **What:** count `"kind":"evidence"` vs `"speculation"` entries in the consolidate JSON.
- **Problem:** the label vocabulary drifts (`evidence`/`supported_evidence`/`speculation`/
  `held-speculation`/`speculative association`/`…_association`) and the JSON shape drifts
  (flat vs nested `[[…],[…]]`) — see Stage 5. Enumerating these is brittle; it pushes model
  variance INTO the verbalizer, the opposite of the code-seam design.

### Fix 5 — Give `evidence-sift` a CODE tally backtrack (DURABLE, if a model per-item pass is wanted)
- **What:** keep the model perspectivist/reasoner/classify (for prose/unstructured input) but
  replace the model consolidate/audit with the pure `pf-tally` / `pf-all-present` from
  `evidence-sift-refined-backtrack`. The classify leaves already emit `"kind":"evidence"` /
  `"speculation"`; `pf-tally` counts those markers in the joined verdicts and emits the
  code-format tally regardless of the per-item model.
- **Cost:** medium — a flow edit to `evidence-sift.chiral` (touches the golden; verify).
- **Fixes:** verbalize works for BOTH list AND prose analyze, with the tally always
  code-emitted. Preserves the "model quotes, code decides the tally" refinement invariant.
- **Does NOT fix:** per-item classification is still a model verdict (the refinement pass's
  whole point was that even THAT should be code for citation-style claims — hence refined).

---

## Recommendation

**For the reported symptom, apply Fix 1** — route analyze to `evidence-sift-refined` at BOTH
levers (remove/rewrite `evidence-sift` in `plannable-skills` so the planner can't pick it, AND
repoint `intent->plan`'s analyze arm). It restores the rich sentence **deterministically,
mesh-free, in ~0.03s**, and is proven by Stage 4. **Do NOT bump the skill model** — Stage 5
disproves it (4b and 8b both still return the generic line).

If the project wants the model per-item reasoning for **unstructured prose** analyze (where
`pf-split-numbered` can't split), pursue **Fix 5** as the durable structural fix: a code tally
backtrack makes `verbalize-analyze` work regardless of the leaf model, keeping the
"model quotes, code counts" invariant. Fixes 3 and 4 both push model variance back into a place
the design deliberately keeps code-deterministic — avoid them.

**Note the design tension surfaced:** `verbalize-run` is only rich for analyze, and only for the
CODE tally format. This is consistent with the "verbalize is rich only for analyze" honest gap
already recorded in `CHATTER-STATE.md`; this diagnosis adds that even *within* analyze it is
rich only for the code-tally (refined) variant, never the model variant.
