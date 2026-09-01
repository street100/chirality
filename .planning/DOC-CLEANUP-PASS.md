# Doc cleanup pass

**Opened 2026-08-31, author directive.** Lighter than the per-doc audit in
`DOC-AUDIT-QUEUE.md`, and separate from it. That queue checks claims against
authority. This pass does three things and stops:

1. **Cut dead references.** Anything named that does not exist and will not.
2. **Cut excess.** Duplicated content, dead history, hedging that carries nothing.
3. **De-complicate the prose.** Short, plain, punctual. Still precise.

**Cadence: serial. One document, one agent, then merge.**

> **The arc both of these serve is `docs/arcs/presentability-arc.md`, and it is
> TRACKED.** It holds the requirements and the resume state. This file holds one
> pass's rules and its per-document order. Neither this file nor
> `DOC-AUDIT-QUEUE.md` is merged into the other or into the arc: they are three
> different jobs, and `.gitignore:12` means only the arc survives a fresh clone.


## The line that matters most

**Deferred is not deleted.** The ownership and trust track (the re-bootstrap
climb, DDC, the secure datum model, the register root, the cascade; E53, E71,
E72) is out of scope for current *work* and is actively being built in the
author's own lane. Its documents stay. Its content stays. It is only required to
be honestly marked as unbuilt.

**Dead** means the referent is gone for good: the Python oracle and every
`test_*.py`, `refine.py`, `effects.py`, `bridge.py`, the Rocq leg, the CompCert
leg, `scaffold/` paths, `examples/` at the root, renamed `chirality-*.py` tools.

## What must NOT be cut

- **Honest limits.** The `⚑` flags, "unbuilt", "UNVERIFIED", "VACUOUS", "SEEDED",
  the gating notes. Removing a caveat makes a document read cleaner and lie more.
  That is the one failure this pass could cause, and it is worse than the rot.
- **The rung vocabulary** and any measured number with its date.
- Anything whose removal would need an author decision. Flag it instead.

## Gate

`bash tools/prose-lint/prose-lint.sh --regress` must pass. It is bash and awk, no
compiler, so it runs while the build gate is closed. Counts before and after go
in the row below.

## Order and state

Reading order, which is the order a session meets these documents.

| # | doc | lines | prose hits | state |
|---|---|---|---|---|
| 1 | `README.md` | 202 | 0 | queued |
| 2 | `MAP.md` | 150 | 7 | queued |
| 3 | `CONTENTS.md` | 166 | 15 | queued |
| 4 | `PRINCIPLES.md` | 280 | 24 | queued |
| 5 | `docs/index.md` | 118 | 12 | queued |
| 6+ | `docs/banks/` then `docs/definitions/`, worst-first | | | queued |

## Rename, author directive 2026-08-31

`LAYOUT.md` and `MAP.md` are both misnamed, and they are misnamed in the same
way: each carries the other's job. `LAYOUT.md` is titled "The chirality tree" and
holds extensions, importability, the module key and the doc roles, which is a map
of the tree. `MAP.md` opens "Read this first to orient" and self-describes as
"the layout of the whole project on one screen, with links into the detail",
which is a table of contents.

So they swap:

| from | to | what it is |
|---|---|---|
| `LAYOUT.md` | `MAP.md` | the tree: extensions, importability, module key, doc roles |
| `MAP.md` | `CONTENTS.md` | orientation and the index into the detail |

Blast radius measured 2026-08-31: 25 reference sites, `CONTENTS.md` unclaimed.

**Done 2026-08-31.** Both `git mv`s ran, every reference site was swept, and
`ledger-lint` check C was repointed to `CONTENTS.md`. The rename table above is
kept as the record of what moved where. The `lib/typing/diag.chiral:32` deferral
below still stands.

⚑ **`ledger-lint` check C reads `MAP.md`** (`ledger-lint.py:152`, registered at
`:1050`) for the `docs/decisions (N notes)` claim. That claim lives in the
orientation index, so it follows to `CONTENTS.md`. A swap leaves `MAP.md`
existing, so a check left unrepointed reads the wrong document rather than
erroring on a missing one. Repoint it in the same change as the rename.

⚑ **`lib/typing/diag.chiral:32`** names `LAYOUT.md` in a comment. Editing `lib/`
changes compiler source and owes a fixpoint rebuild, which is blocked while the
resolver is in flight. Deferred, tracked here.
