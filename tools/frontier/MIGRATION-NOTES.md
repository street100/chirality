# frontier — migration notes

Carried as-is from `bin/metis-frontier.py` (650 L), renamed `frontier`. `ROOT` moved
three levels up. It starts and prints its two-subcommand help (`condense`, `route`).

Both subcommands read the **doc ecosystem**, which does not exist here:

| needs | for |
|---|---|
| `docs/index.md`, `docs/glossary.md`, `docs/open-edges.md`, `docs/decision-*.md` | `route`'s ranking corpus |
| `docs/banks/` | bank homes for a routed topic |
| `examples/INDEX.md` | the element corpus |
| `.planning/DECISION-DOCKET.md`, `docs/elements/specs/` | open decisions |
| `docs/FRONTIER.md` | `condense`'s **output** |

`docs/` here is `examples/ definitions/ elements/`, all empty. Whether
`docs/definitions/` is the banks tier under a new name is not settled, so the
corpus is not repointed.
