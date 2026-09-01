> **ARCHIVED 2026-09-01. Superseded by `prog/manas/chatter/egress.chiral`, which is the contract as built.** A contract proposal outlives its usefulness the moment the code exists; read the module.

# DC-0b — the F1 per-skill EGRESS CONTRACT (D1) (2026-08-20)

**Gates:** all of F1 / Wave 1 (DC-1a, DC-1b…N). Do NOT dispatch F1 implementation until the
D1 author calls at the bottom are ratified. This is a DESIGN artifact — no code, no commit to
`scaffold/`. Grounded entirely in the live code (`turn.chiral`, the five `profile/*` skills,
`core/flow.chiral` `parse-perspectives`, `core/types.chiral` `RawCall`/`RunManifest`).

## The measured finding — verbalize reads the WRONG field

Every model fractal skill (research / decision / doc-edit / code-test — and evidence-sift) has the
**same shape**: `perspectivist → per-perspective(reasoner→auditor) → backtrack(combiner→auditor)`.
`flow-ty` derives the whole arrow's codomain from the **backtrack's last step = the auditor**, so:

- **`manifest-final-yield` (the `fy` field) = the AUDIT VERDICT** — a thin judgment line like
  `"sound|has-gaps + one reason"` / `"complete|has-gaps + one reason"` / `"clean|issue + one reason"`.
- **The actual ANSWER — the synthesized recommendation / answer / merged patch / consolidated tests
  — is the COMBINER's output**, one step upstream, typed `ty-findings` (a JSON array of
  `{kind,target,body}`), tracked by angle/criterion.

`verbalize-generic` (turn.chiral:132) reads only `manifest-final-yield`. So today the "answer" the
user sees is the *audit verdict about the answer*, never the answer itself — and when the yield
looks JSON-ish it degrades to `"Here's what the <intent> pipeline produced."` **This — not model
size — is F1.** (`CHATTER-QUALITY-DIAGNOSIS`: the rich evidence-sift sentence is pure-code because
`verbalize-analyze` reaches into the *combiner's* raw, not the audit; the other four skills never
got that treatment.) The fix is a boundary parser that reaches the combiner substance, exactly as
`verbalize-analyze` already does for analyze.

## The mirror + the enabler

**Mirror:** `parse-perspectives` (flow.chiral:376) — a model emits freeform text; a LENIENT parser
(JSON array preferred, one-per-line fallback) turns it into a **closed value** (`Perspective`).
The egress contract is the same move at the skill's *output* boundary: freeform combiner/auditor
text → a closed **egress sum**, parsed once, cased totally by `verbalize`.

**Enabler (new, decisive):** `RawCall = (raw-call eid slot model prompt response)` (types.chiral:153)
— **every call carries its `slot`**. So the parser ADDRESSES the two facts it needs BY SLOT:
- `slot == "combiner"` → the substance raw (the answer/recommendation/patch/tests).
- the LAST `slot == "auditor"` → the verdict raw.

No content-marker scan (verbalize-analyze's `"evidence-track"` string-hunt was the fragile way; slot
addressing is structural and total). A `find-slot-raw : (List RawCall) Str -> Maybe Str` +
`find-last-slot-raw` are the only new extractors; both return `Maybe` (honest absence, never a crash).

## THE CONTRACT

Each skill's boundary output is parsed into a **closed egress sum**. Because the four task skills
share one shape, they share ONE egress type; only the audit-verdict vocabulary differs:

```
; the parsed substance: the combiner's per-angle/criterion findings (reuse jarr→ machinery)
(data Finding () (finding (kind Str) (target Str) (body Str)))

; the audit outcome — a CLOSED sum, not a Str (boundary-sums pattern, docs/pattern-boundary-sums.md)
(data Audit () (audit-ok (reason Str))        ; the good arm (sound/complete/clean/fixes/well-formed)
                (audit-flag (reason Str))      ; the flagged arm (has-gaps/issue/collateral/redundant/gap)
                (audit-absent))                ; the auditor raw was missing/unparseable — honest gap

; the skill egress: substance + verdict, parsed at the boundary. verbalize reads THIS, not fy.
(data SkillEgress () (egress (findings (List Finding)) (verdict Audit)))
```

**Per-skill parse table** (which combiner produces the findings, which good/flag words map to
`audit-ok`/`audit-flag`):

| skill              | combiner substance (`ty-findings`)        | audit good→`audit-ok` | audit flag→`audit-flag`      |
|--------------------|-------------------------------------------|-----------------------|------------------------------|
| evidence-sift(-ref)| two-track tally (evidence/speculation N)  | `well-formed`         | `malformed`                  |
| research           | answer tracked by angle                   | `complete`            | `has-gaps`                   |
| decision           | recommendation tracked by criterion       | `sound`               | `has-gaps`                   |
| doc-edit           | merged patch (`ty-patch`)                 | `clean`               | `issue`                      |
| code-test          | consolidated tests                        | `clean`               | `gap`, `redundant`           |

evidence-sift is the SPECIAL, already-solved case: its combiner is pure-code `pf-tally` emitting the
two-track counts, and `verbalize-analyze` already renders it. It is the BASELINE the other four are
brought up to — DC-1b does evidence-sift first only to re-express the existing rich path THROUGH the
new `SkillEgress` type (so the comparison is apples-to-apples), then research/decision/doc-edit/
code-test each get the same parser + a per-skill verbalize frame.

**The lenient parse (mirrors parse-perspectives):**
1. `findings` ← `find-slot-raw raws "combiner"` → parse the JSON array of `{kind,target,body}` (reuse
   `jarr→` shape); JSON miss → one `finding "note" "" <line>` per non-empty line (the same dual-format
   leniency parse-perspectives uses). Absent combiner → `nil` findings (honest).
2. `verdict` ← `find-last-slot-raw raws "auditor"` → `str-lower`, scan for the skill's good word →
   `audit-ok`; else its flag word(s) → `audit-flag`; neither/absent → `audit-absent`.
3. `verbalize` cases `SkillEgress` TOTALLY: render the findings tracked-by-angle + tag the verdict
   (`"(audit: sound)"` / `"(audit: has gaps — <reason>)"`); empty findings + `audit-absent` → the
   existing honest generic floor. Never dumps raw JSON, never crashes.

## D1 — the author calls to RATIFY (these gate DC-1b)

Decided here where the code decides it (feedback-decide-and-check); the genuinely-author ones are
marked ✎AUTHOR:

1. **One unified `SkillEgress` vs per-skill sums.** DECIDED: **one** `SkillEgress` (findings + Audit).
   The four task skills are structurally identical; a per-skill sum would be five copies of the same
   shape. Only the verdict *vocabulary* differs, and that is data (the parse table), not type.
2. **`Audit` as a closed sum vs a Str.** DECIDED: **closed sum** (`audit-ok`/`audit-flag`/`audit-absent`)
   — this is exactly the boundary-sums finding (parse once, reason as a value). `str-lower`-scan the
   auditor raw into it at the boundary; verbalize cases it.
3. **`Finding` reuse.** DECIDED: reuse the existing `{kind,target,body}` triple the runner already asks
   every leaf to emit + the `jarr→` parse machinery; do NOT invent a new finding shape.
4. **verdict word lists.** RESOLVED 2026-08-20 (author): the table above is ACCEPTED as drafted —
   code-test's ternary `gap|redundant|clean` → `redundant`+`gap` both map to `audit-flag`; doc-edit's
   `ty-patch` combiner (not `ty-findings`) → substance parses as ONE finding, not an array.
5. **verbalize framing per skill.** RESOLVED 2026-08-20 (author): sketch each skill's one-sentence
   skeleton INSIDE DC-1b (evidence-sift first as baseline) and ratify there — framing lives next to the
   code that emits it, not up front.

**⇒ Both gates cleared — DC-1b is unblocked.**

**Implementation note for DC-1b slice 1 (found reading run mechanics):** evidence-sift-refined's
combiner is `flow-pure` → its RawCall is `(raw-call "flow-branch-pure" "pure" "code" …)` /
`(raw-call "flow-pure" "pure" "code" …)` (flow.chiral:805/846), slot `"pure"`, NOT `"combiner"`.
Only the MODEL skills (research/decision/doc-edit/code-test) run their combiner through the runner
with `slot=="combiner"` (runner.chiral:91, `exp-slot`). So `parse-egress` has TWO substance-address
modes: (a) model skills → `find-slot-raw raws "combiner"`; (b) the pure evidence-sift-refined tally →
the existing `"evidence-track"` content-marker path (`verbalize-analyze`'s `find-track-raw`). Slice 1
(evidence-sift baseline) therefore proves the SkillEgress TYPE carries the two-track result via the
code path; slice 2 exercises the general `slot=="combiner"` parse (but see the UPDATE below). Do NOT try to force the refined
tally through `slot=="combiner"` — it isn't there.

## MoE golden safety

This contract adds a **boundary PARSER** (`parse-egress`, `find-slot-raw`) + rewires `verbalize`. It
does **NOT** touch any skill's Expert / Config / Flow / pool, and does **NOT** change `run-flow` /
`plan-run` semantics — the runs are byte-identical; only how their *output* is read changes. So the
MoE golden is not regenerated. DC-1b still CONFORM-checks (it imports the skills) but no golden churn
is expected. If a CONFORM diff appears, STOP — it means the rewire reached into run semantics, which
it must not.

## Slice mapping (feeds CHATTER-DC-FIXES Wave 1)

- **DC-1a** (free win, no egress needed) — route analyze → `evidence-sift-refined` at both levers.
  Independent of this contract; land first.
- **DC-1b** — evidence-sift THROUGH `SkillEgress` (re-express the existing rich path via the new type;
  proves the parser against the known-good baseline). Then research, decision, doc-edit, code-test —
  ONE skill per slice, each: `parse-egress` for its combiner+verdict + a per-skill verbalize frame.
- Dep: DC-1b…N all ride THIS contract. Ratify calls 4 & 5, then dispatch DC-1b (evidence-sift first).

## UPDATE 2026-08-20 — slices 3-5 pivot to CODE COMBINERS (author decision); the parse path changes again

Slice 2 (research) proved the `slot=="combiner"` parse works on CANNED conformant JSON, but a LIVE 0.5b
combiner emits FENCED + schema-HALLUCINATED JSON (`[{"answerContent":{...}}]`) — no `{kind,target,body}`,
no synthesis prose — so live model-skill egress FLOORS even after fence-stripping. Author chose **code
combiners** (option B: the evidence-sift-refined pattern). Design findings from reading `flow.chiral`:

- A `flow-pure` step emits `(raw-call "flow-pure" "pure" "code" …)` (flow.chiral:804) — slot **`"pure"`**,
  NOT `"combiner"`. So a code-combiner skill's substance is addressed by a CONTENT MARKER (the evidence-sift
  path), NOT `find-slot-raw "combiner"`. The slice-2 slot extractor stays valid infra (for any model-combiner
  skill) but slices 3-5 will not use it.
- The backtrack combiner's INPUT is `join-individuals` (flow.chiral:736): per-angle yields joined by
  `"\n\n---\n\n"`; each individual = that angle's per-perspective auditor verdict (ty-verdict prose). The
  angle label is injected into the per-perspective DOC (`"Perspective: <q>"`) but the yield need not echo it.
- The PureFn menu (pf-has-any / pf-tally / pf-all-present / pf-line-after / pf-split-numbered) has NO
  primitive that maps joined per-angle text → a `{kind,target,body}` array. **A NEW PureFn ctor is needed**
  (e.g. `pf-collect-angles`: split on `"\n\n---\n\n"` → one marked finding per chunk). That ctor touches the
  core `PureFn` sum → **recompile scriba** (flow-view exhaustive case, CLAUDE.md gotcha) + update every
  exhaustive `PureFn` case (`run-pure`, `flow-view`) + CONFORM-check.
- parse-egress for slices 3-5 reads the code-combiner's `"pure"` raw by the marker `pf-collect-angles`
  embeds → chunks → Findings; the audit verdict is also a flow-pure `"pure"` raw (the skill's word),
  addressed by content, like evidence-sift.

**This is a core-primitive build (new PureFn + flow.chiral + scriba recompile + 3 skill Flows + parse rewire +
golden), best run as its own focused effort — a good candidate for the worked-example/Flow-change discipline —
NOT tacked onto the parse work.**
