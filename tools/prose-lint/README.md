# prose-lint

The doc tier's prose sorter. `ledger-lint` checks whether a document's *claims*
match the tree. This checks whether it *reads* like a person wrote it.

Shell, no Python. Route step 1 exists to take Python out of this tree, so a tool
added now should not grow what that step has to remove.

## Why these checks

The obvious LLM-slop word list was measured against this corpus before anything
was written. Almost all of it scored zero: `delve` 0, `tapestry` 0, `seamless` 0,
`Furthermore` 0, `showcase` 0. Shipping that list would have produced a linter
that always says "clean" while the docs read the way they do.

What actually saturates the corpus is structural:

| check | baseline hits | files |
|---|---|---|
| em-dash | 17,533 | 440 |
| antithesis (`, not x`) | 3,033 | 444 |
| copula-negation (`is not just x`) | 794 | 244 |
| parallel-no (`no x, no y`) | 88 | 63 |
| slop-word | 5 | 4 |
| throat-clearing | 2 | 2 |
| not-but | 1 | 1 |

Both of the top two were named by the author as tics before any of this was
built. The measurement agreed with them by three orders of magnitude over the
word list.

Words that *did* score were checked in context and left out on purpose.
`robust` appears 37 times and means `robust-shares`, the T3 rung. `leverage`
appears 20 times as a noun, in `highest-leverage row`. Flagging either would
make the tool noise, and a linter you learn to ignore is worse than none.

## Use

```
prose-lint                  ranked worklist, worst first
prose-lint PATH...          per-line findings for a file or directory
prose-lint --summary        totals per check
prose-lint --baseline       freeze today's counts
prose-lint --regress        fail on any file worse than the baseline
prose-lint --checks         what each check matches, and why
```

Exit `0` clean or no regressions, `1` findings or regressions, `2` cannot run.

Ranking is **density**, hits per 100 lines. A 58-line note with 59 hits is a
worse read than a 654-line spec with 272, and it is also the one you can finish
in a sitting.

## Code is skipped

Fenced blocks and inline `spans` are removed before counting. An identifier, a
shell snippet, or a check name quoted in a doc is not a finding. This README
tripped its own `slop-word` check by naming the words it looks for, which is how
the rule got written. The counter and the per-line reporter share the filter, so
a worklist number always matches the lines it will show you.

## It sorts. It does not correct.

Every check matches a *shape*, and a shape is sometimes the right sentence.
`.prog and .profile are not import targets` is a fact about the resolver and
trips `copula-negation` anyway. Two of the ten hits in `CLAUDE.md` survived the
first cleanup pass for exactly that reason.

So this is the same split `ledger-lint` has with `doc`: the tool produces the
worklist, a human decides each line. Nothing here rewrites a file.

## The iteration

`.planning/PROSE-BASELINE.tsv` holds per-file counts. Clean a file, re-run, watch
the number fall. `--regress` refuses to let any file get worse than its recorded
count, and treats a file with no row as new and held to zero.

The baseline was frozen at **21,456 hits across 475 files** on 2026-08-31. That
number going down is the only evidence that a cleanup pass did anything, which is
why the tool is deterministic and has no model in any path.

Not wired into `chirality test`. 21k findings would fail the gate on day one.
`--regress` is the part that could become a gate once the corpus is under control.
