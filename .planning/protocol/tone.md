# Tone

How a sentence in this repository is written. It applies to every tier: chat
replies, code comments, commit messages, doc files, skill files, and the prose
inside a spec.

## The voice

Straightforward and dense. Declarative sentences. State the thing once,
positively, and stop. One concrete case per claim, the way `PRINCIPLES.md` uses
them. Prefer a table or a short list over a paragraph.

If a contrast carries real weight, give it its own sentence. Wedging it into a
comma clause is the tic, and the tic is what the linter finds.

## What the linter checks

`tools/prose-lint/prose-lint.sh` is the enforcement. Ten checks, each matching a
shape rather than a word, because the obvious word list was measured against this
corpus first and scored near zero: `delve` 0, `tapestry` 0, `seamless` 0,
`Furthermore` 0. Shipping that list would have produced a linter that always says
clean.

| check | matches | baseline hits |
|---|---|---|
| `em-dash` | every `—` | 17,533 |
| `antithesis` | `, not x`, `, never x`, `, rather than x`, and the same with a conjunction wedged in | 3,033 |
| `copula-negation` | `is not just x`, `are not merely x` | 794 |
| `parallel-no` | `no x, no y`, `never x, never y` | 88 |
| `slop-word` | eight words, listed by `prose-lint --checks` | 5 |
| `throat-clearing` | `worth noting`, `important to note`, `in essence`, `at its core`, `in other words` | 2 |
| `not-but` | `not x but y` | 1 |
| `connective` | `Furthermore`, `Moreover`, `Additionally,` | 1 |
| `self-reference` | `as noted above`, `see above`, `the draft below`, `Notes on this` | 7 |
| `first-person` | `I wrote`, `I added`, `my row` | 6 |

The top two were named by the author as tics before any of this was built, and
the measurement agreed with them by three orders of magnitude over the word list.

Code is skipped. Fenced blocks and inline spans come out before counting, so a
finding never lands on an identifier or on a check name quoted in a doc. This
section would trip `slop-word` if it spelled the eight words out, which is how
that rule got written.

## What the linter cannot check

It sorts, and a person decides each line. Every check matches a shape and a
shape is sometimes the right sentence. `MAP.md` states a fact about the
resolver in the exact form `copula-negation` matches, and it is the correct
sentence there.

These carry no check and still apply:

- **Do not narrate the edit inside the artifact.** A dated note about how a
  document got rewritten, glued to the content it describes, stands between the
  reader and the thing. Git carries the history and the commit message carries
  the reason. This is distinct from recording a correction: `banks/verification`
  writing "the old text said X, and X was wrong" is a fact about the tree and it
  belongs. The `self-reference` check catches only the pointing half.
- **Say it once.** Two documents stating one thing differently is the regularity
  violation `docs/definitions/design-principles.md` names as the worst class of
  defect. A pointer costs nothing and cannot drift.
- **No padded rhythm.** Restating for emphasis, a summary of the summary, and a
  sentence announcing the next sentence all read as filler.
- **Honest numbers.** A count, a size or a date appears only when something was
  measured. `docs/definitions/working-discipline.md` carries the reporting rule:
  failures with their output, skipped work named, "done" only when a gate ran.
- **Commit messages.** What changed, what was verified, what was skipped.

## The iteration

```
prose-lint                  ranked worklist, worst first, by density
prose-lint PATH...          per-line findings
prose-lint --summary        totals per check
prose-lint --baseline       freeze today's counts
prose-lint --regress        fail on any file worse than the baseline
prose-lint --checks         what each check matches, and why
```

Ranking is density, hits per 100 lines, so a short bad note outranks a long
adequate one and it is also the one that can be finished in a sitting.

`.planning/PROSE-BASELINE.tsv` holds per-file counts, frozen at 21,456 hits
across 475 files on 2026-08-31. That number falling is the only evidence a
cleanup pass did anything, which is why the tool is deterministic with no model
in any path. A file with no baseline row is new and held to zero.

Re-frozen 2026-09-01 at **23,231 hits across 515 files**, which is the figure
that counts against the two checks added that day. The earlier 21,456 was taken
before them and before the consolidation moved `.planning/specs/`,
`.planning/LEDGER.md` and `.planning/audit/CONFORMANCE-MAP.md`.

Not wired into `chirality test`. 23k findings would fail the gate on day one.
`--regress` is the part that becomes a gate once the corpus is under control.
