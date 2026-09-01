---
name: doc-audit
description: >-
  Doc-tier audit for chirality — one doc per run, claim-beside-authority. Use when
  asked to "audit a doc/bank/note", "bring a doc current", "check the banks",
  or after code/pipeline changes that may have rotted documentation. Mechanical
  rot is pre-sorted by tools/ledger-lint/ledger-lint.py (checks A–S); this run handles the
  semantic residue via tools/doc/doc.py audit bundles.
---

# doc-audit — keep the docs tier true

Two layers, use them in order:

**Layer 1 — the sorter (no agent needed).** `python3 tools/ledger-lint/ledger-lint.py` is the
mechanical worklist, pre-classified: A evidence paths · B stale principle
numbers · C MAP counts · D banks schema/index · E bank shard claims vs the
conformance map · F dangling [[links]]/related · G line citations that no
longer fit the file · H cheatsheet ops vs `refine.py _OPS`. Every violation
names its file:line and both sides of the disagreement. If the lint is clean
and the ask was "check the docs", say so and stop — do not invent semantic
work.

**Layer 2 — the corrector (this run).** For ONE doc that needs a semantic pass:

```
python3 tools/doc/doc.py audit <node>        # banks/port, memory-model, or a path
```

The bundle is read-only and puts every claim next to its live authority: the
doc itself, its lint findings, the `records/conformance-map.md` +
`docs/examples/INDEX.md` rows for
every E# it names (sibling-filed rows included), the ACTUAL code lines behind
every line citation, and the head of every linked note.

## Hard rule: one run = one doc

Write surface is the doc under audit, nothing else. Never lib/, prog/,
examples artifacts, other docs, or the map. Repo-side staleness discovered
while auditing (a stale map row, a wrong neighbor note) is REPORTED, never
touched.

## The authority gradient (fix direction, always)

lib/ + prog/ source + tests → records/conformance-map.md +
docs/examples/INDEX.md (build/pipeline state) → decision docs (design intent)
→ bank → thin note. A doc is corrected
TOWARD what sits above it. When two authorities above it disagree, FLAG
verbatim — never pick.

## Run the charter

The bundle's §0 charter has the 5 checks (build-state truth, line-evidence
truth, settled-decision conformance, graph integrity, refraction honesty).
FIX decidable defects in place; FLAG author-tier questions verbatim. Finish
with `python3 tools/ledger-lint/ledger-lint.py` — done = lint clean + FLAG list.

## Producing docs (same machinery)

```
python3 tools/doc/doc.py new-bank <name> E# E# …
```

scaffolds a schema-conformant bank with the elements' map rows pre-seeded into
§2 as evidence, and prints the INDEX row to add. Lint check D fails until the
INDEX row exists — that is the forcing function. A produced doc should pass
`doc.py audit` immediately; audit your own output before reporting done.

## Done

- The doc carries every FIX; lint clean (or failures are FLAGged, not silent).
- Final message: FIX summary + FLAG list + any repo-side staleness reported
  (not touched). Stop — one doc per run.
