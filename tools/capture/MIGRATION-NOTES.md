# capture — migration notes

Carried as-is from `bin/metis-capture.py` (619 L), renamed `capture`. `ROOT` moved
three levels up. It starts and prints usage:

```
usage: metis-capture.py <VISION-note.md> [--report-only] [--out <dir>]
```

It routes a free-form note into the doc ecosystem, and every destination is absent:
`docs/banks/` (+ `docs/banks/INDEX.md`), `docs/decision-*.md`, `docs/open-edges.md`,
`docs/*.md`, and `.planning/capture/`. It also shells out to `frontier` and `doc`,
which are here but are themselves blocked on the same tier.

Not repointed: `docs/{examples,definitions,elements}/` is a different partition from
`docs/*.md` + `docs/banks/`, and picking a mapping would decide the doc tier's shape
as a side effect of migrating a tool.
