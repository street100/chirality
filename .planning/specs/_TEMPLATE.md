---
element: E<NN>
slug: <slug>
title: <human title>
kind: SELF-HOST | REPLACE-CRUTCH | BUILD-PROPER
example: examples/E<NN>-<slug>.md
status: draft
updated: <YYYY-MM-DD>
---

# E<NN> SPEC — <human title>

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

## 1. Deliverable

- **After this runs:** <the one-sentence observable delta — what exists in
  `scaffold/` / `lib/` that does not exist now>.
- **Non-goals:** <what this run explicitly does not build — residue lives in §6>.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** <the CONFORMS/EXTEND/REFACTOR/BUILD/DECISION rows
  for this element and what they imply for the shape of the change>.
- **Live code:** <the shards already built that this change composes with —
  file + symbol, from the bundle outlines. Name them; do NOT respec them.>
- **True delta:** <deliverable minus baseline — the actual new/changed surface>.

## 3. Decisions

Every open question from the example §6, dispositioned. No silent design calls:
RESOLVED only when derivable from a settled doc (cite it); genuinely novel
design goes to NEEDS-AUTHOR and is surfaced, never answered on the author's behalf.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | <q> | RESOLVED / DEFERRED(E# or edge) / NEEDS-AUTHOR | <settled doc cited, or the docket edge it waits on, or the author call owed> |

If any NEEDS-AUTHOR blocks §4, set frontmatter `status: blocked`, still fill
§4–§6 for the unblocked remainder (or mark them `pending decision #n`), and stop.

## 4. Change plan (ordered, commit-sized)

### Step 1 — <name>
- **Target:** `<file>` — <symbols / section>
- **Change:** <precise description; adapt the example §5 snippet where it applies>
- **Size:** ~<S / M / L>

### Step 2 — <name>
- …

## 5. Conformance gate

- **Golden behavior:** <the example's conformance target, restated checkably —
  observable outputs, differential agreement across floors, error shapes>.
- **Tests to add:** <named tests; which floor(s) each compares>.
- **Green line:** <current N> → ≥ <N + k>; ledger-lint clean.
- **Done when:** <one sentence an executor can verify>.

## 6. Residue & links

- **Deliberately unbuilt:** <each residue item with its home — an E#, a docket
  edge, or an explicit "nobody's yet">.
- **Follow-on:** <the elements this unblocks>.
- **Related:** [[E<NN>-<slug>]] <linked elements / decisions>.
