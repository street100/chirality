# chirality — handoff

**Written 2026-08-31.** Start here in a new session. `LAYOUT.md` is the contract
(tree, extensions, module key); this file is state and route.

## Where it is

A working, self-hosting language at `/workspace/chirality`. Migrated out of
`/workspace/metis-the-lang` (still intact, read-only during the migration).

| | |
|---|---|
| modules + programs | 210 (`.chiral` 155 · `.prog` 44 · `.port` 9 · `.manifest` 2) |
| compiler | `bin/chirality-bin`, 1,098,104 B, committed (1,102,200 B before the collections split) |
| CLI | `bin/chirality` — `compile` · `run` · `check` · `test` |
| resolver | `bin/chirality-resolve.sh` (shell) + `lib/module/resolve.chiral` (native), a matched pair |
| tests | `bin/chirality test` → **142 assertions, 0 failed**, 7 of 12 old phases ported + Phase 13 (E157), new here |
| tools | `tools/` — 9 Python tools carried as-is, each with `MIGRATION-NOTES.md` |
| docs | 226 files, sorted by role (`LAYOUT.md`); `.planning/` 245, catalog + LEDGER included |
| record | `.planning/MIGRATION-MAP.tsv`, 677 rows, every `new_path` verified to exist |

### Verified, not asserted

- **Fixpoint**: `C1 == C2` byte-identical at 1,098,104 B, re-run after the split.
  ⚑ `C1` is checked **non-empty before** the `cmp` — `cmp` of two empty files passes,
  and a fixpoint is stability, never correctness.
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
- ~~`scaffold/lib/manas/**`~~ **DONE** (slice 4) — 51 files → `prog/manas/`,
  18 `.prog` + 33 `.chiral` by LAYOUT's structural test. All 18 gates compile and
  run green; 707 import sites in the tree, 0 unresolved. Six scriba/flow-view roots
  left `KNOWN_FAIL` untouched: they were only ever missing twelve manas keys.
  ⚑ Seven `prog/manas/profile/` files are 0-`data`/all-`def`/zero-`lam`, the manifest
  shape by LAYOUT's letter. They ship `.chiral` because E163's loader check does not
  exist. They are E163's first candidates.
- samples / demo / fixtures (~204 files). ⚑ `prog/samples/` currently holds **six
  files recreated by judgment** — Phase 2's manifest named them and
  `.planning/MIGRATION-MAP.tsv` has zero rows for `scaffold/samples/`. They move if this slice
  picks another home.
- ~~`collections`~~ **DONE** (slice 5) — split into `prelude/{ord,list,maybe,alist,map,set}`,
  with `str-join` moved to `prelude/string`. Two past the four named: `maybe` because
  `Maybe` is its own type and `str-join` because it produces a `Str`; leaving either in
  `list` would break the rule the split is for. 49 defs moved byte-identical, 37
  importers repointed at what they actually name. `prelude/collections` is gone as a key.
- ~~Coordinates~~ **DONE** (slice 6) — the three false ones corrected against
  `docs/axis-altitude.md` and `docs/modules-lowering.md` in the old repo:
  `lowering/tal/target-linux` → `(alt tal)`, `lowering/c/mach` and
  `lowering/c/assemble` → `(alt metal)` ("the codegen below tal is the Mach path",
  modules-lowering L65). These are the tree's first non-`upper` coordinates, so
  there was no in-tree precedent to copy; overrule them if the axis reads otherwise.
  13 of 164 modules now carry a coordinate, up from 8 of 127 because the collections
  split carried its `(cat A) (alt upper)` onto each piece.

**Then**
- ~~`E157`~~ **DONE** — ported from the old tree, `lib/typing/diag.chiral`. The eight
  containers of the checker/loader error closure carry a closed `Reason`; `XErr`
  (E159) and `LinErr` retired into it; `dg-msg` renders once at the module boundary.
  Gate: `tools/test/diag.sh` + `tools/test/samples/e157_diag.prog`, Phase 13, 30
  assertions, seven named mutants all convicting. Every message is byte-for-byte
  what it was — which is exactly why the text rows cannot be the gate and the
  evidence rows are.
- `E158 → E146` — the rest of the pretty-printer chain. Highest leverage item left:
  it is the diagnostics work in route step 2 *and* the prerequisite for both new file
  types. `typing/pretty.chiral` is half-finished (6 of 11 formers) and imported by
  nobody because it is `Term -> Str`, flattening at every step. **E158 now has a
  concrete consumer to render**: `Reason`, and `dg-msg` is the sibling it joins
  rather than replaces.
- **`.protocol` needs minting.** Justification measured: 1,891 lines / 177 defs /
  122 byte-ops across five hand-written codecs (`http` 780 · `vt-parser` 402 ·
  `json` 361 · `apc` 252 · `wire` 96).
- `.manifest` = **E163** (the form) + **E146** (value→source; its round-trip gate
  `parse(source(v)) ≡ v` is already specified) + **E158** (`Doc`).
  ⚑ Both new types are **one law, two carriers**: a declared form → a derived codec →
  a round-trip gate. `.manifest` round-trips against metis source, `.protocol` against
  bytes.
- ~~The element catalog~~ **HOISTED** (slice 7). `.planning/` is here whole, catalog and
  `LEDGER.md` included. `ledger-lint` went from **14 of 14 inputs missing to 7**, and
  the remaining 7 are *path* mismatches, not absences: `docs/status-ledger.md`,
  `open-edges.md` and `FRONTIER.md` are under `docs/definitions/` now, `examples/` is
  `docs/examples/`, and `scaffold/` is `lib/` + `prog/`. The first six are a mechanical
  repoint. The seventh is not: checks G/R read line citations of the form
  `scaffold/lib/x.metis:123`, and both the path and the line moved, so repointing that
  one produces confident nonsense. **Still not repointed at a guess** — but the guesses
  are gone, so this is now a small measured job.
- `docs/elements/` is the one doc dir still empty, and stays empty until something
  **derives** it from a build-state authority. ~171 hand-maintained status lines is the
  rot the old tree's lint checks exist to catch.
- 184 wikilinks across `docs/` do not resolve. That is **exactly the old repo's count**
  on the same file set (129 distinct slugs, byte-for-byte the same list), so the hoist
  broke none of them. They are pre-existing, and mostly `[[E##]]` element refs that want
  `docs/elements/` to exist.
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
