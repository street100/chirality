# The code/model MIX — a map of the chatter pipeline (2026-08-18)

A picture, not a plan. The whole-session finding is that **neither pole works alone**:
pure code is fast/deterministic/right-format but **not agnostic** (brittle to phrasing
and novelty); pure model is agnostic but **slow, nondeterministic, and won't emit
structured output**. Every stage of the chatter has to MIX the two across an explicit
seam — and that seam is a **PORT**: you type the port, not the content (§2). This maps
where the seam sits, the three ways to mix, and what the map implies is currently
missing. No changes proposed here — this is the terrain.

---

## 1. The two poles, honestly (measured this session)

| axis | CODE (PureFn / marker rubric) | MODEL (be-chat leaf) |
|---|---|---|
| **generality / agnostic** | ✗ brittle — a fixed marker list; novel phrasing misses | ✓ handles unseen phrasing/tasks |
| **determinism** | ✓ same input → same output, always | ✗ varies run-to-run (even temp 0 across models) |
| **output format** | ✓ emits exactly the structured shape downstream needs | ✗ freeform; JSON shape + label vocab drift across models/runs |
| **latency** | ✓ ~0.03s | ✗ 3–30s **per leaf**, serialized on one GPU (two multi-leaf flows / 22 calls measured at **8m40s** together — ~4m20s each) |
| **auditable / testable** | ✓ the criterion is code you read, extend, unit-test | ✗ the criterion is a prompt + weights |

Neither column is "better." The columns are **complementary** — each is strong exactly
where the other is weak. That is why the answer is a seam, not a choice.

---

## 2. The AI boundary is a PORT, not a type — and the three ways to mix through it

The correction that reorders this whole map: **you cannot put a real (checkable) type on
English / AI output.** The content is untypeable — trying to type every layer is the wrong
instinct. So you don't. You **wrap each AI interaction as a PORT** — chirality's own
membrane/crossing; `be-chat` behind the linear `Backend` porttype is already exactly this.
What you type is the **port**, never the payload:

- its **protocol / effect** — the linear handle, the crossing signature — fully typed;
- its **egress** — a **closed sum** the freeform reply is **parsed into AT the boundary**
  (`parse-plan`, `parse-perspectives` are this act). The parse is where opaque English
  becomes a typed value — the *only* typing the AI ever gets.

The **English stays opaque** on the process side of the membrane. **Everything else is
fully-typed pure code** (the spine). And you want **more** of these ports — more, smaller,
cleanly-wrapped crossings with dense typed code between them — not one big untyped model
blob, and not a doomed attempt to type the layers.

So "mix" = **ports (opaque AI, typed boundary) ⋈ full typing (pure code)**. The three
patterns are all just *where you put a port and how tight its egress sum is*:

**M1 — SPLIT THE LEAF** (the extract→decide split is live in `evidence-sift-refined`, `:45–46`).
The pattern cuts a "decide" leaf into *understand* + *decide*: understand is a model **PORT**
(extract/quote — opaque payload crossing the membrane), decide is typed code (judge/count),
and the split *is* the port boundary. **Live-code note:** in the refined LIST path BOTH halves
are code — extract = `pf-line-after` (`:45`), decide = `pf-has-any` (`:46`) — because the
perspectivist already isolated the item, so the model-extract was measured unreliable on the
0.5b and dropped (file note `:34–36`); the diagnosis confirms the whole refined run is
`model=code`. The model-PORT understand-half is what the pattern uses where extraction is
genuine prose understanding, not a pre-isolated list item. *"The model never decides; it only
quotes."* Open weakness: the decide-half is a fixed rubric → not agnostic (that's M2's job).

**M2 — ESCALATION LADDER** (missing). Code decides the **confident** cases (marker present →
instant); the **ambiguous** residue (novel phrasing) crosses a model PORT. Most messages
never open the port → you keep the speed and regain agnosticism. The direct answer to "the
rubric isn't agnostic": code is *right when it's sure and hands off when it isn't* — the
port backstops, code doesn't have to be agnostic.

**M3 — the PORT'S TYPED EGRESS** (missing). When the model must decide, the port's result
is a **closed sum**, and the freeform reply is **parsed into it at the boundary** (lenient,
like `parse-perspectives`). You never type the English — you *parse it into a type at the
port*. Today `evidence-sift` has no tight egress (drifting `{kind,target,body}` JSON) →
nothing downstream can read it (the diagnosis root cause).

**More seams = more ports, each with a tighter egress sum. Not more types on the English.**

---

## 3. The pipeline, stage by stage, with the seam drawn

Flow of one message. `[C]` = fully-typed pure code (the spine); `[P]` = a **PORT** — a
membrane crossing wrapping an AI call: typed protocol + closed-sum egress parsed at the
boundary, opaque English inside. Every `[P]` below is a place the untypeable is contained
and re-entered into typed code — the seams. More of them, not fewer.

```
message
  │
  ▼  ROUTE  — classify intent            [C] route-message (markers)  +  [P] plan-message (qwen3:4b)
  │           WHO decides which skill(s)      brittle but instant           agnostic but 3–7s, nondeterministic
  │           MIX = M2: code-prior, model only for the residue (unknown / low-confidence)
  ▼
  ▼  PLAN   — intent → Plan (single/chain/fan/reply)   [C] intent->plan  /  [P] parse-plan(menu pick)
  │           the qwen3:4b pick currently OVERRIDES the code table; that's the posture still open
  ▼
  ▼  SKILL (a Flow of leaves) ── per the refinement pass, each leaf is itself a mix:
  │     PERSPECTIVE  split doc→items        [C] pf-split-numbered (lists)  |  [P] perspectivist (prose)  ← M2 by input shape
  │     EXTRACT      isolate the sentence   [C] pf-line-after (item pre-isolated)  |  [P] model quote (prose)  ← M1
  │     DECIDE       evidence|speculation   [C] citation-marker scan  ← NOT agnostic; needs M2+M3         ← M1 (code half)
  │     TALLY        count the two tracks   [C] pf-tally → "evidence-track count=N"  (keep as code)
  │     AUDIT        well-formed?           [C] pf-all-present (well-formedness, not correctness)
  ▼
  ▼  VERBALIZE — result → prose             [C] verbalize-analyze (template over the code tally)
  │            byte-coupled to the tally format; can't read freeform model output (diagnosis link 4)
  │            MIX = code-template on the structured tally (reliable) + optional [P] synth for richer prose (O4b), gated
  ▼
reply
```

The **DECIDE** row is the whole argument in miniature: today it's `[C]` (marker scan) →
correct-but-not-agnostic. The mix it wants is **M1 + M2 + M3**: model extracted the
sentence (M1); code decides when a marker is clearly present (fast path); the ambiguous
residue escalates to the model (M2) **constrained to `evidence|speculation`** (M3); then
code tallies. That skill is then *agnostic* (model catches novel citations) **and**
*right-format/fast on the common case* (code) **and** *always tally-able* (M3).

---

## 4. The two binding constraints (they shape every choice above)

**Latency is the hard ceiling.** One GPU, serialized: every model leaf is 3–30s, and two
multi-leaf model flows (22 calls) hit **8m40s** together (~4m20s each). So the design rule is **minimize model calls on the
hot path**: code decides the common case; the model is a *fallback* (M2) or a *single*
constrained call, never an 11-leaf-per-item model flow. A chatter turn budget of **≤1–2
model calls** is the target; anything that fans model leaves per item is the anti-pattern.

**Downstream needs structure.** Tally and verbalize are code and *must* stay code (a count
is a count; templating over facts is not text-generation). Therefore **everything upstream
must deliver a code-structured result** — which is exactly what M3 guarantees when the
model is in the loop. The model may be *inside* a skill, but its output crosses into code
through a typed, constrained seam, never as freeform prose the tail has to parse.

---

## 5. The redrawn picture (what "mix" means concretely, per stage)

- **Route** → **M2**: markers decide the confident cases (fast, most traffic); the qwen3:4b
  planner is the *residue* handler (unknown / ambiguous), not the primary. (This is the
  "pure-prior + model-for-residue" posture — now evidence-backed by the diagnosis + latency.)
- **Skill DECIDE** → **M1+M2+M3**: model extracts (M1); code decides on a clear marker;
  escalate the ambiguous residue to a model constrained to a structured token (M2+M3).
  Extending the marker list improves the *code fast-path coverage*; the model backstops
  agnosticism. Neither pole alone.
- **Tally / Audit** → **code**, always.
- **Verbalize** → **code template** over the structured tally; **model synth** only as a
  gated enrichment (O4b), never the reliability path.

The through-line: **the model is for understanding, extraction, generation, and the
ambiguous residue; code is for the decision, the structure, the count, and the hot path.**
The seam between them is typed and constrained. That is the mix — the refinement pass, but
applied at *every* stage and made *agnostic-by-escalation*, not agnostic-by-bigger-model.

---

## 6. What the map implies is TRUE but currently missing (terrain, not tasks)

- The **escalation ladder (M2) doesn't exist** — code decides OR model decides, never
  code-then-model-for-residue. That's the missing piece that makes code non-brittle.
- The **model, when it decides, is unconstrained (M3 missing)** — `evidence-sift` asks for
  drifting JSON instead of a structured token, so its output can't be tallied (the diagnosis).
- **Only `evidence-sift` has a refined (M1) twin.** doc-edit / research / decision / code-test
  are un-split model skills — same latency + format exposure.
- **Route is model-primary** for the five TASK intents (social/clarify are already
  code-fast-pathed, O6 `turn.chiral`), **not code-prior** across the board — inverts the
  latency/reliability gradient on the task picks.
- **No per-turn latency budget** is enforced; a fan/chain of model skills can blow to minutes.
- **The marker lists (router, citation) are the code fast-path's coverage knob** — extending
  them is cheap, auditable generality; today they're small and hand-picked.

None of these are proposed changes here — they're the shape of the gap the mix has to fill,
so the picture is honest about what "mix properly" would actually take.

---

## 7. One-line picture

**Code is the typed spine; every AI touch is a PORT — a membrane crossing with a typed
protocol and a closed-sum egress parsed at the boundary, wrapping an opaque English payload
you never type. You don't type the AI; you wrap it and type the port. More seams = more
ports, not more types on the English — the refinement pass as chirality's membrane, everywhere.**
