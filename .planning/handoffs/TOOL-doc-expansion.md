# TOOL HANDOFF — doc-expansion tooling (condense · route · capture)

> **STATUS: BUILT 2026-07-25** (commits `b588152` + `fd06152`). All three tools
> shipped: `bin/chirality-frontier.py` (condense/route/bundle) + `ledger-lint` check I
> + `bin/chirality-capture.py`. This handoff is retained as the design record; it is
> no longer a work order. See `CONTINUE-2026-07-25.md` for current state.

Entry point for a **fresh agent** building doc-tier growth/orientation tooling
for chirality. You do not need any prior chat — everything is in the repo.
Read `CLAUDE.md` and `.planning/HANDOFF.md` first for orientation, then this.

## Why this exists (the problem)

chirality has a large, well-structured doc ecosystem (`docs/`, `docs/banks/`,
`.planning/`) and a mature **correctness** toolchain — but no **growth/
orientation** toolchain. Three observed failures this is meant to end:

1. **It doesn't self-orient.** Even with the whole ecosystem laid out, a new
   chat needs hand-holding to reach the current design frontier. There is no
   cheap, always-true "where things stand" layer.
2. **Design scatters.** Settled decisions get stranded in the wrong home (e.g.
   the two-rung model lived only in `SELF-HOST-PLAN.md` until candidate C8 moved
   it into `trust-boundary.md`). Nothing tells you where a new claim belongs.
3. **Crystallization is all manual.** Turning an exploration (a `VISION-*` note)
   into canonical artifacts — a `decision-*.md`, an edge update, a bank — is
   hand-authoring every time.

## The existing toolchain you must fit (read these, mirror their philosophy)

- `tools/pack/pack.py` — the **element pipeline** bundler (`--spec` / `--audit` /
  `--kb` / `--mark`). Philosophy: **collapse many forage turns into one
  deterministic call.**
- `tools/doc/doc.py` — the **doc tier**: `audit <node>` (claim-beside-authority)
  and `new-bank <name> E#…` (scaffold a schema-conformant bank pre-seeded from
  map rows). Reuse `new-bank`.
- `tools/ledger-lint/ledger-lint.py` — mechanical checks A–H over the doc tier. **Deterministic,
  no LLM, rot-proof.** New mechanical guarantees go here.

**Non-negotiable philosophy these embody, which your tools must too:**
deterministic where possible (no LLM in a mechanical path), turn-economy,
**the authority gradient** (code > CONFORMANCE-MAP/INDEX > `decision-*.md` >
bank > thin note), **one artifact per run**, and **NEEDS-AUTHOR is surfaced,
never silently resolved.** A generated artifact must pass its own `ledger-lint`.

## The sources of truth (what the tools read)

- Open questions: `docs/open-edges.md` (edges 1–20 + sequencing; each carries a
  dated status banner: "resolved in direction" / "shaped" / stub).
- Decisions in flight: `.planning/DECISION-DOCKET.md` (D1–D7 + resolution
  states); settled: `docs/decision-*.md`.
- Pipeline state: `examples/INDEX.md` (drafted→reviewed→specced→audited→
  implemented; `.planning/specs/*` frontmatter `status: blocked`).
- Build-state authority: `.planning/audit/CONFORMANCE-MAP.md`.
- Node graph: every `docs/**/*.md` frontmatter (`node:`, `related:`, `[[links]]`)
  and `docs/banks/*`.
- Author calls: `.planning/HANDOFF.md` "Author calls", docket NEEDS-AUTHOR,
  `EDGE-CANDIDATES-*.md` PROMOTE pile, `status: blocked` specs.

---

## TOOL 1 — condense + route  (PRIORITY)

### 1a · condense — a rot-proof design-frontier digest

Deterministically **extract** (do not LLM-summarize) a short "where things stand"
layer from the sources above, to a generated file (propose `docs/FRONTIER.md` or
`.planning/FRONTIER.md`). Sections, each ~1 screen:

- **Decided recently** — resolved edges + `decision-*.md` (title + date) + docket
  items marked resolved.
- **Open** — unresolved/stub edges (one line each: number, title, status banner)
  + live author-calls.
- **In-flight** — pipeline INDEX by status; blocked specs named with their blocker.
- **Recently changed / killed** — from git log of the source files (assumptions
  killed, edges reshaped).

**Determinism is the whole point:** it's extraction + formatting, so regenerating
twice yields byte-identical output, and a **new `ledger-lint` check flags a stale
digest** (sources changed, digest not regenerated) — the same forcing function as
check D. This is what makes the ecosystem self-orient by reading ONE cheap file
that cannot rot. Do NOT summarize semantically (that rots and needs an LLM);
extract structured facts and let them speak.

### 1b · route — where does this belong?

Given a topic/claim (a string, or a file), return its **home(s)** in the
ecosystem, ranked, by matching against node names, bank names, edge topics, and
catalog elements — plus *why*. If nothing matches above a threshold, say
**"genuinely new — mint an edge/element/bank"** rather than forcing a bad home.
This kills the scatter failure (#2). Deterministic matching (token/anchor
overlap over the node graph); no LLM required.

## TOOL 2 — capture  (PRIORITY, companion to Tool 1)

Turn an exploration into scaffolded canonical artifacts. Input: a marked
`VISION-*` / exploration note (e.g. `.planning/VISION-deployment-custody-2026-07-24.md`
is a live example). For each section/claim, **route it (Tool 1b) to its home**
and **scaffold** the target: an edit-stub against an existing `docs/` node, a new
`decision-*.md` skeleton, an `open-edges.md` edge insertion, a `new-bank` call, or
a catalog-element row — each pre-seeded with the source claim + the authority it
must be checked against. **It scaffolds; a human/LLM fills** (exactly like
`new-bank` scaffolds and `worked-example` fills). Output: the scaffolds + a report
of what routed where + every **NEEDS-AUTHOR** claim surfaced verbatim, never
resolved. A captured artifact must pass `chirality-doc audit` / `ledger-lint`.

## TOOL 3 — frontier bundler  (RIDER, lowest priority)

A read-time assembler (`chirality-pack --frontier` or `chirality-doc frontier`) that
prints Tool 1a's digest plus optionally deeper slices for a fresh chat. Largely
subsumed by Tool 1a once the digest is a maintained file — build only if cheap.

---

## Conformance gate

- **condense**: regenerate twice → byte-identical. Digest content matches the
  sources on a spot-check set of edges/decisions/specs. New `ledger-lint` check:
  stale digest is flagged, clean when fresh.
- **route**: on a labelled set of known claims (e.g. "register custody" →
  `trust-boundary`/`bootstrap-sequence`; "effect row" → E39/`decision-effect-facets`),
  the correct home ranks first; an off-graph claim returns "genuinely new."
- **capture**: run on the live `VISION-deployment-custody-2026-07-24.md`; every
  scaffold it emits passes `ledger-lint`, and every author-call in that note
  appears in the report unresolved.

## Audit obligation

Deterministic paths must be deterministic (regen-twice-identical); the digest and
any scaffolds must pass `ledger-lint` (add the digest-staleness check to the
lint itself). No mechanical path may call an LLM. Hold gradients in generated
text — extract "resolved in direction / open / blocked", never flatten to
"done/not-done" (the corpus's honest-defaults discipline; over-collapse is the
cardinal doc error here).

## Not in scope

Do not build the element-pipeline side (that's `chirality-pack`) or a doc *auditor*
(that's `chirality-doc audit`). This is growth + orientation only.
