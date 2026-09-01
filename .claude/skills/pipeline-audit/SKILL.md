---
name: pipeline-audit
description: >-
  Audit run for the chirality self-implementation pipeline: one tool, two levels.
  EXAMPLE level gates a drafted example before speccing (phantom-feature /
  settled-decision / build-state / syntax checks); SPEC level gates a SPEC
  before implementation (citation truth / baseline honesty / right homes /
  gate soundness). Use when asked to "audit E#", "audit the example", "audit
  the spec", or before promoting an artifact to the next pipeline stage.
---

# pipeline-audit: the gates between pipeline stages

The corpus pipeline is **example → audit → spec → audit → implement**. The
example is `docs/examples/E<NN>-<slug>.md`, the SPEC is
`docs/elements/specs/E<NN>-<slug>-SPEC.md`, and the build-state authority is
`records/conformance-map.md`. `.planning/` is untracked scratch. Do not cite it
and do not write into it.

Cadence is serial, one stage and one agent at a time
(`docs/decisions/decision-dispatch-cadence.md`), and that decision overrides
every parallel-waves protocol in this tree.

This
skill is both audit gates: same tool, level picked by which artifact is under
audit. Produce exactly **one** audited artifact per run, then **stop**.

An audit's ONLY write surface is the artifact under audit (the example at
EXAMPLE level, the SPEC at SPEC level). It never touches `lib/`, `prog/`,
the other artifact, or any doc.

## Step 1: get the bundle (ONE command, read-only)

```
python3 tools/pack/pack.py E<#> --audit example   # pre-spec gate
python3 tools/pack/pack.py E<#> --audit spec      # implement-ready gate
python3 tools/pack/pack.py E<#> --audit           # audits the furthest artifact
```

The bundle opens with the level's **audit charter** (the 5 checks, in order)
and contains everything the checks run against: the artifact under audit, the
catalog row, the element's `records/conformance-map.md` rows, and **KB slices**: the
docs-tier notes resolved from the artifact's own `[[links]]` plus every bank
naming this element, cut to the blocks that carry this element's shards,
cross-cuts, and residue. SPEC level adds the example (as rationale), live
target outlines, and the test baseline; EXAMPLE level adds the idioms
reference for syntax legality.

Nothing is scaffolded and no status changes. The bundle is pure input.

**Read the bundle and little else.** Each slice header says how many blocks
were elided; the caveat at the top of the KB section names the one known blind
spot (E-ranges). Grep a cited note narrowly before judging a claim its slice
doesn't settle. Silence in a slice is never grounds for calling a citation wrong.

## Step 2: run the charter

Work the 5 checks in the printed order. For every defect found:

- **FIX**: mechanical, decidable from the bundle (wrong build-state, stale
  citation, illegal syntax, arithmetic): edit the artifact in place. Decide
  decidable things; verify each fix against the slice you used.
- **FLAG**: author-tier (genuine values / taste / scope): record it in your
  report with the exact question. Resolving one yourself takes an author's
  decision, and burying one inside a fix hides that you took it.

## Step 3: verdict

- **PASS** (no blocking FLAG): finish with the deterministic flip,
  `python3 tools/pack/pack.py E<#> --mark reviewed` (EXAMPLE level) or
  `--mark audited` (SPEC level; also flips the SPEC's frontmatter status).
  This run updates the INDEX row itself: cadence is serial, so nothing races
  it and `--no-index` does not apply.
- **BLOCKED**: do NOT mark. Report the FLAG list; the author's answers feed a
  re-audit.
- **REFUSED, superseded**: `pack.py` stops before it bundles anything when the
  element's artifacts carry `status: superseded` (their work was reshaped into
  the *different* element their `superseded_by:` field names). Do not re-run it
  as a BLOCKED audit: there is nothing to gate, because the element will not be
  built. Report the successor and stop. The state, the
  `superseded_by:` field, and the rule that it is reachable from any state are
  defined once, in the Status section of `docs/examples/INDEX.md`: not here.

## Done

- The artifact carries every FIX; nothing else in the repo changed.
- Status flipped only on PASS (`drafted → reviewed` / `specced → audited`).
- `superseded` is never written by this run: it names a successor element, which
  is an author's call, so it is set by hand.
- Final message: verdict + FIX summary + FLAG list (verbatim questions) + the
  single suggested next pipeline step. Stop, and do not roll into speccing or
  implementing.
