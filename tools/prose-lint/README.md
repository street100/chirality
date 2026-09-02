# prose-lint

The doc tier's prose sorter. `ledger-lint` checks whether a document's *claims*
match the tree. This checks whether it *reads* like a person wrote it.

**The checks now live in `prog/prose-lint.prog`, in chirality.** "Shell, not
Python" was the wrong bar: route step 1 says *replace the tools with chirality
programs*, and shell is no more chirality than Python is.

What the language could not do was **enumerate a directory**. That is E148
(`getdents64` + `stat`), not built, and the catalog names three standing
workarounds already waiting on it. This tool is the fourth, which is worth
counting rather than hiding, because the count of workarounds is E148's
justification.

Everything else was already there: `slurp-fd` reads a file, `str-find-from` is a
primitive so the scan recurses once per match, and `str-len` / `str-sub` /
`str-cat` / `i64->str` cover the rest. The program takes its path list on stdin,
which is the tree's existing idiom (`chirality-bin < blob`, `wield.prog`). When
E148 lands, the `find` in front of the pipe is the only thing that goes away.

This shell script remains the front end: ranking, the baseline, `--regress`,
per-line output, and code-skipping. Those are ordinary work to move across, not
blocked on anything.

## Why these checks

The obvious LLM-slop word list was measured against this corpus before anything
was written. Almost all of it scored zero: `delve` 0, `tapestry` 0, `seamless` 0,
`Furthermore` 0, `showcase` 0. Shipping that list would have produced a linter
that always says "clean" while the docs read the way they do.

What actually saturates the corpus is structural:

| check | baseline hits | files |
|---|---|---|
| em-dash | 18,678 | 468 |
| antithesis (`, not x`) | 3,407 | 479 |
| copula-negation (`is not just x`) | 1,028 | 278 |
| parallel-no (`no x, no y`) | 95 | 67 |
| self-reference (`see above`) | 7 | 7 |
| first-person (`I wrote`) | 6 | 6 |
| slop-word | 5 | 4 |
| not-but | 3 | 3 |
| throat-clearing | 1 | 1 |
| connective | 1 | 1 |

Re-measured 2026-09-01, when `self-reference` and `first-person` were added and
`.claude/skills` entered the scope.

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
the rule got written.

⚑ The counter and the per-line reporter share the code filter and **not** the
pattern set. `cmd_lines` carries its own regex, and it omits `parallel-no`,
`Additionally,`, three of the slop words, `in other words`, and the
`isn't`/`aren't` half of `copula-negation`. So a file's worklist count can
exceed the lines the reporter prints, and a hit in one of those checks is
findable only through `--summary`. Measured 2026-09-01 on a file counted at 14
and reported at 13.

## It sorts. It does not correct.

Every check matches a *shape*, and a shape is sometimes the right sentence.
`.prog and .profile are not import targets` is a fact about the resolver and
trips `copula-negation` anyway. Two of the ten hits in `CLAUDE.md` survived the
first cleanup pass for exactly that reason.

So this is the same split `ledger-lint` has with `doc`: the tool produces the
worklist, a human decides each line. Nothing here rewrites a file.

`self-reference` shows why a check gets narrowed. It was proposed as a catch for
revision notes glued onto content, and the first draft matched `an earlier draft
of this` and `Rewritten <date>` as well. Measured first: those score 37 and 2
here, and every hit is the honest-correction convention, a doc recording what it
used to say wrongly beside what is right. The tic and the convention are the same
words in a different place. So the check ships as the pointing half only, where a
sentence refers to the document instead of saying the thing.

## The iteration

`.planning/PROSE-BASELINE.tsv` holds per-file counts. Clean a file, re-run, watch
the number fall. `--regress` refuses to let any file get worse than its recorded
count, and treats a file with no row as new and held to zero.

The baseline was re-frozen at **23,231 hits across 515 files** on 2026-09-01,
with the two new checks in it. The 21,456 before that predates them. That number
going down is the only evidence that a cleanup pass did anything, which is why
the tool is deterministic and has no model in any path.

Not wired into `chirality test`. 21k findings would fail the gate on day one.
`--regress` is the part that could become a gate once the corpus is under control.
