# syscall-map — migration notes

Carried from `bin/syscall-map.py` (238 L). **It runs**, and its output is
byte-comparable to the old tree's.

Two changes, both forced:

1. `scaffold/lib/sys-tal.metis` → `lib/lowering/tal/sys.chiral` (the MIGRATION-MAP
   row for that file, mechanical).
2. The **referent layer is gone.** It read `@impl("…")` out of
   `scaffold/metis/impl_ports.py` — the Python oracle's implementation registry.
   The Python oracle is cut by author decision, so `referents` is now the empty set
   and the column is *empty rather than guessed*. Restoring it means naming a new
   referent source, not fixing a path.

## A pre-existing staleness, carried faithfully

The tool reports `BUILT (native tal crossing): 0`. That is **not** migration damage:
the old tree prints the same 0 on the same file. Its crossing regex is
`\(def (nb-sys-\S+) TFn`, and the actual defs read `(def nb-sys-write-t TIFn` — the
`-t` suffix and `TIFn` type both post-date the regex. 180 `nb-sys-` occurrences and
55 `ti-sys` sites in `lib/lowering/tal/sys.chiral` are invisible to it.

Fixing that regex is a real change to what the tool measures, not a port, so it is
recorded here rather than done silently in a migration.
