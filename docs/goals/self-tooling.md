---
node: goal-self-tooling
layer: navigation
related: [goals/README, arcs/diagnostics-arc, arcs/file-types-arc, arcs/zero-python-arc, index]
status: current
updated: 2026-09-03
---

# Goal: chirality writes its own tooling, and no Python remains

## The claim, and where the project makes it

- [[arcs/zero-python-arc]] holds the replacement of the Python tools with
  chirality programs, tool by tool, and the deletion of `tools/` at the end.
- [[status-ledger]] and [[records/README]] carry the Python that remains, dated
  at each measurement. The count moves; the target of zero does not.
- `docs/decisions/decision-scope.md`: self-hosting includes being good enough to
  write its own tooling.
- Author call, 2026-08-31: zero Python is absolute. It does not mean zero Python
  in the compile path, which has been true for the whole migration.

## What done means

1. **No `.py` file anywhere under `/workspace/chirality`.** Observed by a find
   over the tree returning nothing. [[arcs/zero-python-arc]] rows `Z6`, `Z7`
   and `Z8`, behind the enablers `Z1` to `Z5`.
2. **`tools/` is deleted rather than emptied.** Observed by the directory being
   absent. [[arcs/zero-python-arc]] row `Z9`.
3. **Every tool it held runs as a chirality program on the same test floor as
   the rest of the tree.** Observed by each replacement having a phase in
   `tools/test/run-tests.sh`. **No row serves this**, and the hole is
   enumerated as `GAP-18`. [[arcs/zero-python-arc]].
4. **The primitives those tools compose from exist.** Observed by the coverage
   table in [[arcs/text-tools-arc]] holding: every classic tool a replacement
   needs is a short composition. [[arcs/text-tools-arc]].

## State

14 Python files, 4,962 LOC, measured 2026-09-03, across 9 of the 12 folders in
`tools/`. `prog/prose-lint.prog` is the
one tool already ported natively and is the worked precedent. Sizing per file is
`.planning/ZERO-PYTHON-SCOPE.md`, and [[arcs/zero-python-arc]] copies the parts a
reader needs from a fresh clone.

## Arcs

| arc | what it supplies |
|---|---|
| [[arcs/diagnostics-arc]] | printing (`Doc`, `pretty`) and reporting (`Reason`) |
| [[arcs/file-types-arc]] | declared forms with derived codecs and round-trip gates |
| [[arcs/text-tools-arc]] | the text primitives every tool scans with: the matcher, the score, the edit script, the stable address |
| [[arcs/zero-python-arc]] | scanning (the total matcher), directory walk, argv, and the ports themselves |

The order is forced by measurement. Every one of the nine tools scans text,
reports what it found, and prints the report. The tools cannot be replaced
before the three things they are made of exist.

### File kinds are the other half

The extension is a kind rather than a dialect, and the end state is that a kind
is parsed differently while staying the same language. A manifest can be written
and turned into code, and code back into a manifest; a `.manifest` is a view of
the code, structured for its purpose as a view; the same applies to `.protocol`,
`<name>.m.gram` and more. `MAP.md` is the contract.

## Honest limits

- `.manifest` resolves as an import target and nothing checks that its contents
  are data, so the kind is a naming convention until E163. `.protocol` is minted
  as E183 and unbuilt, `<name>.m.gram` is named nowhere in the tree, and the
  `.profile` extension `MAP.md` names has zero files. The round-trip law that
  would make a view and its code the same artifact is `parse(source(v)) == v` in
  [[arcs/file-types-arc]], unbuilt for both carriers.
- `prog/prose-lint.prog` is missing `not-but`, `parallel-no` and code-skipping,
  and prints them as NOT-CHECKED every run. Those want the matcher.
- `tools/paren-audit/paren-audit.py` still sits on disk at 154 LOC beside
  `prog/paren-audit.prog`, and their equivalence is unverified.
- `tools/scriba-run-smoke/scriba-run-smoke.py` (51 LOC) was never ported.
- Four `docs/examples/refs/gen-*.py` generators (502 LOC) are sliced into
  pipeline bundles by `pack` as the OURS baselines. Deleting them costs four
  worked examples their comparison, and that is an open decision.
