# Chatter answer quality — the next arc (2026-08-22)

**Read this to start.** The divide-and-conquer arc is DONE (`CHATTER-DC-FIXES.md`): a message
divides into typed chunks, each chunk reaches a code-picked specialist on a min-privilege grant,
each skill's combiner is code, the lanes consolidate over structure, and scriba shows the shape.
The machinery works and is live-verified.

**The answers are still bad, and this doc says why.** It is not that the 0.5b is weak — that was
the wrong diagnosis, held for most of a session, and correcting it is the point of this document.

---

## The thesis

> We built a **cleanup pipeline for a mess we create one line earlier**, then read the residue as
> model weakness.

Two proofs, both measured, both from live transcripts:

**(a) The prompt's own section names leaked into the answers.** Every leaf prompt opened with
`# Lens` — manas jargon for an expert's one narrow line of thought, and to a 0.5b simply a NOUN at
the top of the page. Asked "tell me a few things about qtt" the research fractal answered about
CAMERA LENSES ("focal length, power, or curvature of surfaces"). It had been doing this across
every skill for the whole session — `code-test`, reviewing `div(a,b)`, produced *"the extended
focus of the telescope's objective is too wide"* — and every instance was filed as model thinness.
FIXED (`469edcf`); the same question now answers about quantum theory.

**(b) Five pieces of recovery machinery exist to undo one instruction we add ourselves.**
`strip-fence`, `unwrap-chunk`, `bodies-scan`, `json-item-text`/`obj-strs`, `says-something?` —
every one of them written this session, every one honest in isolation, all of them reversing the
runner's blanket "Return ONLY a JSON array" demand (see Change 1). They are downstream of the
defect, not the fix for it.

**The working rule this yields:** before blaming the model, read the prompt it actually got, and
check that what we ASKED for is what the seam will ACCEPT.

---

## Change 1 — the return instruction must follow the leaf's `out-ty`

`call-expert` (`prapanca/pipeline/runner.chiral:88`, and its twin `call-expert-stream:108`) appends to
**every** leaf prompt, unconditionally:

> "Return ONLY a JSON array of objects, each with string fields \"kind\", \"target\", \"body\". No prose."

`refine-ok` (`prapanca/core/flow.chiral`) — the seam that then JUDGES the answer — wants something
different per type:

| out-ty                                  | refine-ok accepts        | the runner asks for | coherent? |
|-----------------------------------------|--------------------------|---------------------|-----------|
| `ty-text`, `ty-doc`, `ty-patch`, `ty-span` | **non-empty prose**   | a JSON array        | **NO**    |
| `ty-findings`                           | contains `[` or `kind`   | a JSON array        | yes       |
| `ty-verdict`, `ty-part`                 | `json-ish`               | a JSON array        | yes       |

So `research-investigate` — declared `ty-text` *precisely because* "a free reasoning move is PROSE"
(its own comment) — is ordered to answer in JSON. It half-complies: fenced JSON, invalid JSON,
off-contract keys (`{"text":…,"reason":…}`), arrays of bare tokens (`["80%","high",…]`). Everything
in §(b) above exists to clean that up.

**The invariant:** *ask for exactly what the seam will accept.*

**Shape.** `oty` is already in scope at the call site and simply is not passed:
`run-flow`'s `((flow-step eid ity oty) … (call-expert b e doc extra model))`. Thread it through and
derive the instruction from it — the table above IS the mapping, because it is `refine-ok`'s own
definition read in the other direction.

*Files:* `prapanca/pipeline/runner.chiral` (`call-expert` + `call-expert-stream` signatures + the
instruction), `prapanca/core/flow.chiral` (pass `oty` at the two call sites). *Test:* pure — the
instruction for each Ty; plus live — a `ty-text` leaf returning prose that refine-oks.
**CONFORM-check:** prompts are not pinned by `manifest-conforms` (verified when the header fix
landed: `CONFORM: true`), so no golden churn is expected. If one appears, STOP.

**LANDED 2026-08-22.** `ty-return-instruction` sits in `flow.chiral` beside `refine-ok` (the third
option — ask and validator in one place); `call-expert`/`call-expert-stream` take the ask as a
`ret` parameter, and `ret-json-findings` stays the SINGLE definition of the JSON ask in
`runner.chiral` beside `parse-findings` that reads it back. Prose Tys (ty-doc/ty-span/ty-text) get a
prose ask, ty-patch a diff ask, the JSON-shaped Tys and ty-perspectives keep the JSON one.
Verified: `flow-test` (new `ask-ok` block — prose Tys do not demand JSON, JSON Tys do, the ask is
the runner's un-drifted constant, and a compliant answer to each ask refine-oks its Ty) exit 0;
every manas `*-test` + chatter turn/router exit 0; **`manas-run-conform` and `manas-flow-conform`
both `CONFORM: true`** on the mesh (no golden churn, as predicted); `manas-chatter-live` gate PASS.
Re-measured live residue, for Change 2/§Do-NOT: `code-test` now reports `json-free prose: TRUE`,
`doc-edit` still FALSE (the 0.5b fenced a JSON block unasked). Do not filter it — that is the next
measurement, not the next filter.

**Pipeline criterion** (CLAUDE.md, amended 2026-08-22 — "iff implementing it requires CHOOSING
between shapes the codebase does not already settle"): **mostly forced, one open choice.** The
per-Ty table is dictated by `refine-ok`; the defect is the blueprint. The genuine choice is WHERE
the instruction is composed — the runner (as now), `assemble.chiral` beside the other sections, or a
`ty-return-instruction` in `flow.chiral` next to `refine-ok` so the ask and the validator sit
together and cannot drift. **Recommend the third**, and it is one decision, not a design space —
so: skip the full pipeline, record the choice in the commit.

---

## Change 2 — the per-angle chain ends in its judge, so the judge's words are what survive

`research-per-perspective` = `investigate` (ty-text, the content) → `assess` (ty-verdict, the
grade). `chain-run` forwards only the LAST yield, so **the grade survives and the content does
not**. DC-1b "fixed" this by widening `research-assess`'s `emits` to *"the finding in one line,
then: high|medium|low confidence"* — i.e. the judge was asked to re-type the content, rather than
the content being allowed to survive. That is exactly where `…; high; …; confidence medium` in the
bodies comes from, and F4/F6 then filter it back out.

An assessment is **metadata about** an answer. It does not belong in the value path.

*Files:* `prapanca/profile/research.chiral` (and the same shape in `decision`, `doc-edit`; `code-test`
already ends in its proposer and is the model to copy). *Dep:* do AFTER Change 1 — the emits
widening exists partly because JSON-shaped prose was already mangled, and some of this may
evaporate.

**Pipeline criterion: RUN IT.** The shape is a real choice the codebase does not settle — drop the
per-angle judge entirely, move it into the backtrack, make it a `flow-pure` structural check, or
keep it and carry both values. `code-test` settles one option by example; the others are open.

---

## Change 3 — nothing supplies facts (SUPPLY-1)

Asked about "qtt" the model answered *Quantum Tunneling*. In this repo QTT is **Quantitative Type
Theory** and it is written down — `docs/glossary.md`, `PRINCIPLES.md`, the catalog. Nothing
retrieves it into `sees`.

No division, no fan, no filter manufactures a fact the leaf was never shown. This is the only one
of the three that changes what the system can KNOW, and it is the largest unbuilt thing on the
board. Already named as SUPPLY-1 in `CHATTER-STATE.md` ("a fact a leaf can't SEE can't be
extracted"); the `sees`/`extra` channel it would feed is built and attenuated (DC-4a), so the
missing piece is retrieval, not plumbing.

**Pipeline criterion: RUN IT.** Every part is an open choice — what corpus, what index (none
exists), whether retrieval is a Flow step or a pre-pass, whether a grant is per-chunk or per-angle,
how a miss is reported honestly rather than hallucinated over.

---

## Order

1. **Change 1** — contained, offline-testable, and it should make several of the filters below stop
   being load-bearing. Do it first so the residue can be re-measured rather than re-guessed.
2. **Change 2** — small, same seam, do it with or right after 1.
3. **Change 3** — the real unlock, and the one that deserves the full pipeline.

## Do NOT

- **Do not add another filter.** The known residue — mixed prose+JSON chunks (`["high"]` embedded
  in a sentence), short label-ish bodies ("existing models", "confidence medium") — are SYMPTOMS of
  Change 1. Re-measure them after it lands; fixing them first buys another layer of cleanup.
- **Do not blame the 0.5b before reading the prompt it got.** That error cost most of a session.
- **Do not re-pitch** code-prior (D2, resolved), the code combiners (DC-1b option B, resolved), or
  the model-fan cap vs data-fan distinction (R3) — all decided with measurements in the ledger.

## What already exists (so it is not rebuilt)

This session, on top of the DC arc: `deep-research` — a fractal skill that expands one broad ask
into specific questions and runs the WHOLE research fractal per question (R1 `9b7d216`, R2
`d59f924`, R3 `da4efd0`, R4 `24d268e`); the model-fan cap; the per-turn progress hook and CHAT as a
real top-level scriba mode; the prompt-header fix (`469edcf`).

Recipes, gotchas and the mesh details: **`CHATTER-STATE.md` §Build + test recipes** — do not
re-derive them. The live artifacts to re-run when judging quality:
`scaffold/samples/manas-chatter-live.chiral`, `manas-deep-research-live.chiral`, and PTY-driving the
committed-resolver scriba build.
