# chirality — handoff

**Written 2026-08-31.** Start here in a new session. `LAYOUT.md` is the contract
(tree, extensions, module key); this file is state and route.

## Where it is

A working, self-hosting language at `/workspace/chirality`. Migrated out of
`/workspace/metis-the-lang` (still intact, read-only during the migration).

| | |
|---|---|
| modules + programs | 153 (`.chiral` 116 · `.prog` 20 · `.port` 9 · `.manifest` 2) |
| compiler | `bin/chirality-bin`, 1,077,624 B, committed |
| CLI | `bin/chirality` — `compile` · `run` · `check` · `test` |
| resolver | `bin/chirality-resolve.sh` (shell) + `lib/module/resolve.chiral` (native), a matched pair |
| tests | `bin/chirality test` → **88 assertions, 0 failed**, 7 of 12 old phases ported |
| tools | `tools/` — 9 Python tools carried as-is, each with `MIGRATION-NOTES.md` |

### Verified, not asserted

- **Fixpoint**: `C1 == C2` byte-identical at 1,077,624 B.
- **Stronger**: the old compiler and the new one emit **byte-identical code for the
  same source**. 147 files moved, 355 extensions rewritten, every module key changed —
  and no emitted code changed. That is a rank-2 differential (a fixed committed
  artifact, independent of the thing under test), not a self-check.
- The test-runner is **rebuilt from source on every run**; the old tree's
  stale-binary-reports-green hole did not come along.
- The 5 unported phases **print at the end of every run with their reason**. A phase
  that silently vanishes is a gate that reports ok forever.

## Decisions, with the reason (do not re-litigate without reading these)

1. **Extension = kind, directory = role, subject matter in neither.** A module is
   individuated by its type, not its topic — so no `stdlib/`, no `compiler/`.
2. **Module key = the root-relative path.** Forced: dropping the affix a directory
   carries yields `mach` ×4 and `emit` ×2. Taking the path as the key makes the
   directory load-bearing and makes the basename-collision class *unreachable*.
3. **Importability is the partition.** `.prog` and `.profile` are not import targets
   (an entry cannot be imported — two in a blob is `duplicate label`), so the resolver
   probes **three** extensions and 44% of files never enter the space. Bad states
   unrepresentable, not detected.
4. **`.manifest` is declared, not sniffed.** The shape is crisp — every `def` body a
   literal value — but it is a property of *term structure*, so only the loader can
   check it. A line-based test caught 9 files of which 2 were manifests.
5. **External judgment is cut** (Rocq, CompCert, the Python oracle). Replaced by three
   **semantically distinct judgment cores** that must agree. ⚑ The legitimacy criterion
   is *different formulations*, not three implementations of one rule set — the way
   natural deduction, sequent calculus and combinatory logic converging is what made
   type theory believable. Three encodings of the same rules would be worth nothing.
   **This reverses `decision-split-checker.md` in the old repo and still needs writing
   down as a decision.**
6. **`bin/chirality-bin` is committed.** The source tree and recompile harness ship
   with it, so a checkout rebuilds and byte-compares rather than trusting it.

## The route (author, 2026-08-31)

1. **Finish the migration.** Then **replace the Python tools with chirality programs
   and delete `tools/`.**
2. **Error handling and diagnostics** — serially: the pretty-printer and the parser.
3. **The new file types** — `.manifest`, `.protocol`.

## Queue

**Migration remainder**
- `scaffold/lib/manas/**` (51 files) → `prog/manas/`. Twelve import names in nine
  `prog/scriba/` files reach into it; they are already in path form and resolve
  unchanged once it lands. This is what takes imports to 147/147 without staging.
- samples / demo / fixtures (~204 files). ⚑ `prog/samples/` currently holds **six
  files recreated by judgment** — Phase 2's manifest named them and
  `MIGRATION-MAP.tsv` has zero rows for `scaffold/samples/`. They move if this slice
  picks another home.
- `collections` → `ord` / `list` / `map` / `set` / `alist`. Held deliberately until
  after the fixpoint went green; **now unblocked**. Its own file declares three data
  types; `banks/module` individuates by type.
- Coordinates: **8 of 127** files carry `(module … (cat …) (alt …))`, and **three are
  now visibly false** — `lowering/tal/target-linux`, `lowering/c/mach`,
  `lowering/c/assemble` all still claim `(alt upper)`. The restructure exposed it.

**Then**
- `E157 → E158 → E146` — the pretty-printer chain. Highest leverage item left: it is
  the diagnostics work in route step 2 *and* the prerequisite for both new file types.
  `typing/pretty.chiral` is half-finished (6 of 11 formers) and imported by nobody
  because it is `Term -> Str`, flattening at every step.
- **`.protocol` needs minting.** Justification measured: 1,891 lines / 177 defs /
  122 byte-ops across five hand-written codecs (`http` 780 · `vt-parser` 402 ·
  `json` 361 · `apc` 252 · `wire` 96).
- `.manifest` = **E163** (the form) + **E146** (value→source; its round-trip gate
  `parse(source(v)) ≡ v` is already specified) + **E158** (`Doc`).
  ⚑ Both new types are **one law, two carriers**: a declared form → a derived codec →
  a round-trip gate. `.manifest` round-trips against metis source, `.protocol` against
  bytes.
- The element catalog has **not** migrated. `.planning/SELF-IMPLEMENT-CATALOG.md` and
  `LEDGER.md` are still only in the old repo, and every tool that reads them
  (`ledger-lint`, `pack`, `frontier`, `capture`, `doc`) reports exactly what it needs
  in its `MIGRATION-NOTES.md`. **None was repointed at a guess** — a linter aimed at a
  guess passes by looking at nothing.
- `docs/{examples,definitions,elements}/` exist and are empty. Element status must be
  **derived** from a build-state authority, never hand-written: ~171 hand-maintained
  status lines is the rot the old tree's lint checks exist to catch.
- `make-public` for the new remote (new repo; the old link redirects).

## Known-wrong, small

- `prog/climb.manifest` is in the wrong place — `prog/` is for deliverable programs and
  climb is data (E72, the re-bootstrap chain). **Nothing imports it**; its own header
  says a future `chirality climb --verify` consumes it. Its header also still says
  `lib/climb.chiral`.
- `syscall-map` reports `BUILT: 0` — **pre-existing**, not migration damage. Its regex
  says `TFn` where the defs say `TIFn`; 180 occurrences invisible to it. Fixing it
  changes what the tool measures.
- `ledger-lint` exits **2** with all 14 missing inputs named — distinct from 0 (clean)
  and 1 (violations), because "nothing to lint" is not "the tree is clean".
