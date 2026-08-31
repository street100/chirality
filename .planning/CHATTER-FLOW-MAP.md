# How a message flows — the general-chat pipeline shape (2026-08-18)

A picture, not a plan. Companion to `CHATTER-MIX-MAP.md` (the code/port principle this
uses). The canonical shape for a chat turn: **message → DIVIDE → PARALLELIZE across
specialists → CONSOLIDATE**, with **controlled context flow at every stage**. It is the
existing MoE/branch shape (`flow-branch` = perspectivist→per-perspective→backtrack *is*
divide→parallelize→consolidate) hoisted to be the whole turn, and made fractal (each
specialist can be the same shape again).

Legend from the mix-map: `[C]` = fully-typed pure-code spine; `[P]` = a PORT (membrane
crossing wrapping an AI call — typed protocol + closed-sum egress parsed at the boundary,
opaque English inside). `‡` = a controlled-context rule.

---

## The turn

```
message (opaque Str)  +  ConvState (scoped memory)
  │
  ▼ [C] INGEST — normalize for matching (str-lower), attach the granted context view
  │
  ▼ DIVIDE — message → chunks (independent sub-requests)
  │    [C] structural split FIRST: conjunctions, numbered lists, clauses (fast, deterministic)
  │    [P] semantic-divider PORT for unstructured messages — egress = closed sum `List<Chunk>`
  │    ‡ sees: the whole message + ConvState. out: `List<Chunk>`, each a typed sub-request.
  │
  ▼ ASSIGN — each chunk → specialist(s)
  │    [C] marker router (code-prior, most traffic)  +  [P] planner PORT for the residue
  │    ‡ sees: the chunk + the specialist menu. out: `(chunk, specialist)` pairs (a per-chunk Plan).
  │
  ▼ PARALLELIZE (fan-out) — run each (chunk, specialist)
  │    each specialist = a skill Flow; a specialist MAY itself be divide→fan→consolidate (FRACTAL)
  │    [C] code specialists (deterministic rubrics) wherever structure allows
  │    [P] model-port specialists for open work (extract / generate) — few, single-call
  │    ‡ EACH specialist sees ONLY its chunk + an ATTENUATED context slice granted to it —
  │      never the whole conversation, never a sibling chunk's data. (min-privilege context)
  │    ‡ latency: logically parallel, physically SERIALIZED on one GPU → keep model ports few
  │    out: `List<(specialist, typed-egress)>` — each egress is that port's closed-sum result
  │
  ▼ CONSOLIDATE (fan-in / reduce) — merge the specialists' typed egresses into one result
  │    [C] structural merge / tally where egresses are structured (deterministic; the reliable path)
  │    [P] synth PORT for prose fusion — ONE gated call, egress = one reply
  │    ‡ sees: the typed egresses ONLY — not any specialist's internal payload or raw prompt
  │
  ▼ [C] VERBALIZE — consolidated structure → prose (template)  [+ [P] synth, optional]
  │
  ▼ [C] UPDATE — fold this turn's TYPED result into ConvState (conv-update)
  │
  reply
```

The spine (INGEST, structural DIVIDE, ASSIGN-by-marker, CONSOLIDATE-merge, VERBALIZE,
UPDATE) is typed code. The AI appears only at the `[P]` crossings — semantic divider,
planner-residue, model specialists, synth — each a wrapped port with a closed-sum egress.

---

## Controlled context flow — the cross-cut (the "for everything" part)

Context is a **scoped capability, not ambient state.** No stage reads a global; each
receives an explicit, **attenuated** view and can pass a *further-attenuated* subset
onward. This is chirality's no-ambient-authority / attenuation applied to context, riding the
`sees`/`extra` tagged-pair channel (`conv->extra` → `run-flow-stop`'s extra slot).

| stage | what it is GRANTED to see | what it must NOT see |
|---|---|---|
| DIVIDE | full message + ConvState | — (it's the top; it holds the most) |
| ASSIGN | one chunk + the specialist menu | other chunks, full history |
| a SPECIALIST | its chunk + the slice explicitly granted to it | the conversation, sibling chunks, other specialists' payloads |
| CONSOLIDATE | the specialists' **typed egresses** | their internal reasoning / raw prompts |
| UPDATE / ConvState | the consolidated **typed** result | freeform model text |

Why it matters: (1) **no bleed** — chunk A's data can't leak into chunk B's specialist;
(2) **min-privilege ports** — each crossing gets the least context it needs, so the opaque
model side is contained; (3) **auditable** — context flow is explicit grants, not a global
anyone can read; (4) **attenuation is composable** — a fractal sub-pipeline gets a subset
of its parent's grant, never more.

The knob: attenuation = passing a **subset** of the `sees`/`extra` pairs to each specialist,
plus a summarized/typed handoff (not the raw payload) at each fan-in.

---

## Fractal — "a set of pipelines," not one

A specialist is itself a Flow, so it can be divide→fan→consolidate again, one level down,
on a further-attenuated context. The "set of pipelines" is a **tree of the same shape**:
the turn is the root branch; each skill is a branch; each perspective can be a branch.
`flow-branch` / `flow-fan` are the recursion primitives; `flow-ty` checks that any branch
nests in any composite. Depth is bounded by the **latency budget**, not by the structure.

---

## What already exists vs what the shape needs (terrain, not tasks)

Exists: `flow-branch` (perspectivist→per-perspective→backtrack = divide→fan→consolidate),
`flow-fan` (fan-out + combiner), `pf-split-numbered` / `split-conjunctions` (code dividers),
`run-flow-stop` threading an `extra`/`sees` context, `conv->extra` (memory→context),
`plan-fan`/`fan-collect`/`fan-synth` (chatter fan-out + synth), the doc-refine MoE exemplar.

Needs: (a) a **semantic-divider port** (only structural split exists); (b) **per-specialist
context attenuation** (today `extra` is passed whole, not sliced/min-privilege); (c) the
**turn itself** structured as this branch (today a turn is route→one-skill, or a flat
`plan-fan` over skills / a `split-conjunctions` chain — not a divide→fan→consolidate branch
over message chunks); (d) a **per-turn latency budget** gating fan width/depth (model
ports are serialized — fan-out of model specialists is the 8m40s anti-pattern); (e) the
**code-prior dividers/routers** so the hot path stays off the model.

---

## One line

**A turn is a branch — divide (code, or a divider port) → fan out to specialists (code where
structured, ports where open, few and single-call) → consolidate (code merge, gated synth
port) — recursing fractally, with context handed down as attenuated grants (never ambient)
and up as typed egresses (never raw payload). The spine is typed; the AI is ports; the
context is capabilities.**

---

## Worked trace (fine grain) — one concrete message end-to-end

```
legend:  [C] fully-typed pure code (spine)   ·   [P] PORT = AI crossing (typed protocol + closed-sum egress, opaque
inside)   ·   ‡ controlled-context rule   ·   ⤷ concrete value at that point   ·   ⟨x⟩ = a typed egress handed across

MESSAGE  "sort these two claims by evidence vs speculation, then recommend whether to adopt the API.
          (a) 2019 benchmark logged a 37% gain, measured, table 4.   (b) users probably prefer it."
ConvState  conv-empty
   │
   ▼ ① INGEST ..................................................... [C]
   │     str-lower(for matching only) · attach granted ctx
   │     ⤷ msg:Str   ctx0 = {}                                                       ‡ nothing ambient; ctx starts empty
   │
   ▼ ② DIVIDE   message → chunks .................................. [C] structural split on " , then "
   │     [P] semantic-divider  ── SKIPPED (structure present; port stays shut)       ‡ open the port only for the residue
   │     ⤷ Chunk1 { text:"sort these two claims by evidence vs speculation"
   │     │          data:"(a) 2019 benchmark… measured, table 4.  (b) users probably prefer it."
   │     │          intent:analyze }
   │     ⤷ Chunk2 { text:"recommend whether to adopt the API"   data:—   intent:decide   deps:[Chunk1] }
   │
   ▼ ③ ASSIGN   chunk → specialist ............................... [C] markers   [P planner SKIPPED: markers hit]
   │     Chunk1  "sort " → analyze  → evidence-sift-refined   (CODE specialist)
   │     Chunk2  "recommend/whether" → decide → decision       (MODEL-PORT specialist)
   │
   ▼ ④ GRANT   build each specialist's attenuated view ........... [C]              ‡ MIN-PRIVILEGE, no bleed
   │     grant(esr) = { data:Chunk1.data }                          ← ONLY the claims; NOT Chunk2, NOT history
   │     grant(dec) = { ask:Chunk2.text , prior:⟨esr.egress⟩ }      ← Chunk1's TYPED result only, NOT its raw claims
   │
   ▼ ⑤ SCHEDULE (DAG by deps) → fan out ..........................  Chunk1 independent → first;  Chunk2 waits on ⟨esr⟩
   │
   │  ┌─ lane A ── evidence-sift-refined ──────── FRACTAL: itself divide→fan→consolidate ───────────────────────┐
   │  │  input = grant(esr).data
   │  │    ▼ divide   pf-split-numbered ................. [C]   ⤷ item_a="(a) 2019 benchmark… measured, table 4"
   │  │    │                                                    ⤷ item_b="(b) users probably prefer it"
   │  │    ▼ fan (per item)
   │  │    │   item_a  extract pf-line-after ........... [C]   ⤷ "2019 benchmark… measured, table 4"
   │  │    │           decide  pf-has-any(citation) .... [C]   "measured","table" present → EVIDENCE
   │  │    │   item_b  extract pf-line-after ........... [C]   ⤷ "users probably prefer it"
   │  │    │           decide  pf-has-any(citation) .... [C]   no marker  ─‡ESCALATE→ decide-PORT [P]
   │  │    │                                                    egress-sum{ evidence | speculation }
   │  │    │                                                    parse@boundary ⤷ SPECULATION   (reasoning opaque)
   │  │    ▼ consolidate  pf-tally .................... [C]   ⤷ ⟨esr.egress⟩ = findings{ evidence:1, speculation:1 }
   │  └──────────────────────────────────────────────────────────────────────────────────────────────────────┘
   │             │ ⟨esr.egress⟩ handed UP as a TYPED value ────────────────┐    ‡ only the closed-sum crosses;
   │             ▼                                                         │      esr's raw items never leave lane A
   │  ┌─ lane B ── decision ───────────────────────────────────────────┐  │
   │  │  input = grant(dec) = { ask:"…adopt the API", prior:{ev:1,spec:1} }
   │  │    ▼ reason(ask, prior) ...................... [P] MODEL PORT
   │  │    │   egress-sum{ adopt | hold }  + rationale:Str(opaque)
   │  │    │   parse@boundary ⤷ HOLD   (verdict typed; rationale stays opaque)
   │  │    ▼ ⟨dec.egress⟩ = decision{ verdict: hold }
   │  └──────────────────────────────────────────────────────────────────┘
   │
   ▼ ⑥ CONSOLIDATE (turn fan-in) ................................. [C] merge typed egresses  ‡ sees ⟨egresses⟩ only
   │     ⤷ result = { sift:{ev:1,spec:1} , decide:{hold} }
   │
   ▼ ⑦ VERBALIZE ................................................. [C] template   [+ [P] synth OPTIONAL, 1 gated call]
   │     ⤷ "I sorted the two claims — 1 evidence, 1 speculation — and on that thin support I'd hold on the API."
   │
   ▼ ⑧ UPDATE ConvState .......................................... [C] fold TYPED result   ‡ no freeform text stored
   │     ⤷ ConvState' = { last:{sift,decide}, turn:1 }
   │
   ▼ reply

──────────────────────────── CONTEXT LEDGER (what each stage is GRANTED — the attenuation) ────────────────────────────
 stage            GRANTED (can read)                         DENIED (cannot read)
 DIVIDE           whole msg + ConvState                      —          (top of the tree, holds the most)
 ASSIGN           one chunk + specialist menu                other chunks · full history
 esr (lane A)     Chunk1.data                                Chunk2 · conversation · sibling data
 decide-PORT      one item's text                            the doc · other items · the conversation
 decision (B)     Chunk2.text + ⟨esr.egress⟩ (typed)         Chunk1's raw claims · esr's internal items · history
 CONSOLIDATE      ⟨esr.egress⟩, ⟨dec.egress⟩ (typed)         either specialist's raw/opaque payload
 UPDATE           the merged TYPED result                    any freeform model text

ports opened this whole turn:  decide-PORT (escalation) + decision + (optional synth)  =  2–3 model calls, rest is code
```

Notes on this trace vs today's code (honest): the structural DIVIDE (`split-conjunctions`), the
`esr` fractal (`pf-split-numbered`/`pf-line-after`/`pf-has-any`/`pf-tally`), and the code
ASSIGN (markers) EXIST. The **escalation `[P]` on `item_b`**, the **per-specialist GRANT
attenuation** (today `conv->extra` passes context whole), the **turn-as-branch** (today a turn
is route→one-skill, or a flat `plan-fan`/`split-conjunctions` chain — not a
divide→fan→consolidate branch over message chunks), and the **decision port's `{adopt|hold}`
closed-sum egress** do NOT exist yet — they are the seams §"What already exists vs what the
shape needs" lists.
