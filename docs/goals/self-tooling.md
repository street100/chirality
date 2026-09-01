---
node: goal-self-tooling
layer: navigation
related: [goals/README, arcs/diagnostics-arc, arcs/file-types-arc, arcs/zero-python-arc, index]
status: current
updated: 2026-09-01
---

# Goal: chirality writes its own tooling, and no Python remains

## The claim, and where the project makes it

- `CLAUDE.md`: *"`tools/` holds 9 Python tools carried as-is. Route step 1
  replaces them with chirality programs and deletes the directory. The target is
  zero Python in this repo."*
- `README.md:48-50`: *"14 Python files remain, 4,654 LOC ... The target is zero."*
- `README.md:79-81`: self-hosting scope includes *"being good enough to write its
  own tooling."*
- Author call, 2026-08-31: zero Python is absolute. It does not mean zero Python
  in the compile path, which has been true for the whole migration.

## What done means

No `.py` file anywhere under `/workspace/chirality`. `tools/` is deleted. Every
tool it held runs as a chirality program on the same test floor as the rest of
the tree.

## State

14 Python files, 4,654 LOC, measured 2026-08-31. `prog/prose-lint.prog` is the
one tool already ported natively and is the worked precedent. Sizing per file is
`.planning/ZERO-PYTHON-SCOPE.md`, and [[arcs/zero-python-arc]] copies the parts a
reader needs from a fresh clone.

## Arcs

| arc | what it supplies |
|---|---|
| [[arcs/diagnostics-arc]] | printing (`Doc`, `pretty`) and reporting (`Reason`) |
| [[arcs/file-types-arc]] | declared forms with derived codecs and round-trip gates |
| [[arcs/zero-python-arc]] | scanning (the total matcher), directory walk, argv, and the ports themselves |

The order is forced by measurement. Every one of the nine tools scans text,
reports what it found, and prints the report. The tools cannot be replaced
before the three things they are made of exist.

## Honest limits

- `prog/prose-lint.prog` is missing `not-but`, `parallel-no` and code-skipping,
  and prints them as NOT-CHECKED every run. Those want the matcher.
- `tools/paren-audit/paren-audit.py` still sits on disk at 154 LOC beside
  `prog/paren-audit.prog`, and their equivalence is unverified.
- `tools/scriba-run-smoke/scriba-run-smoke.py` (51 LOC) was never ported.
- Four `docs/examples/refs/gen-*.py` generators (502 LOC) are sliced into
  pipeline bundles by `pack` as the OURS baselines. Deleting them costs four
  worked examples their comparison, and that is an open decision.
