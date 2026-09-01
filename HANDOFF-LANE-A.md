# Lane A — diagnostics & errors. Handoff, 2026-09-01

**Resume from this file.** Division of work and what enforces it: `LANES.md`.
Build-state authority: `docs/definitions/status-ledger.md` (tracked).
Design rationale for the arc: `HANDOFF-DIAGNOSTICS-ARC.md`.

## Built and merged (master, `gate PASSED`)

**E157** typed diagnostics · **E158** `Doc` (4 commits) · **E174** `r-row` + width
function · **E175** ambient-face restore · **E181** `surface/pretty`.
Suite **303 assertions, 0 failed, 11 phases, 88 roots**. `bin/chirality-bin`
**1,147,256 B**, self-reproducing.

## ⚑ BLOCKERS AND HAZARDS — read before starting anything

### 1. `.planning/` is untracked, so element state is invisible
`.gitignore:12` excludes it by master's decision. The catalog, the ledger and
every SPEC in this arc are **on disk only**. Consequences that already bit:
- **Two sessions minted `E173` independently** and nothing caught it until a merge
  put both `docs/examples/INDEX.md` rows side by side. Mine renumbered to E182.
- Six built elements were invisible to any other reader until this arc's
  build-state block was added to `status-ledger.md` on 2026-09-01.
**Working rule:** anything a second reader must know goes in a **tracked** file —
`docs/examples/INDEX.md`, `docs/definitions/status-ledger.md`, or `LANES.md`.
Mint only inside Lane A's band **E184–E189**, and land the INDEX row in the same
change; the INDEX row is the only collision detector there is.

### 2. `E176` — `str-sub` is unclamped and SEGFAULTS. This is the sharpest thing open.
`prelude/prelude.chiral:80` is a raw extern with no bounds behaviour;
`(str-sub "abc" 0 999995)` exits **139**. `prelude/string.chiral:14` says
*"str-sub clamps, so a too-long prefix is just false"* and **`str-starts-with` is
built on that false comment**, so it segfaults for any prefix longer than its
subject. **131 call sites.** It has already constrained an unrelated element:
E181's `pp-safe-prefix` had to be written byte-level (`bget`/`brepeat`) because
neither helper is safe, and that constraint is now a gated row (G11b/M16).
A memory-safety hole in a language whose thesis is that these are untypeable, and
the safety was asserted **in a comment instead of in a type**. Fix is a decision —
clamp at lowering, or refine the signature so the bad call cannot typecheck.

### 3. The gate hazard is systemic — **eleven** toothless rows found in this arc
Rows that cannot fail. Causes seen, all measured: a `grep` matching its own source
or message text · a mutant paired with a row it cannot move · a fixture whose
first failing case masks later rows · a scanner that passes on an empty result ·
a normalizer that deletes exactly the byte its mutant removes (**three separate
times**, always `doc.sh`'s whitespace stripper) · and once the language itself,
where **currying** turned an arity check into a legal partial application.
**Every row needs a named mutant that is RUN.** Reading a gate never tells you
whether it can fail.

### 4. Promotion: check the precondition, and promote the FIXPOINT
E181's deliverable enters the compiler's closure; earlier arc elements did not.
Before building, require `B1(blob)` byte-identical to `bin/chirality-bin` on the
**unmodified** tree — otherwise merge-inherited staleness gets blamed on your
element. It nearly did: after one master merge the binary was **two** generations
stale (`C1 ≠ C2`, `C2 = C3`), so a single build-compare pass **reports a failure**
and promoting `C1` installs a binary that does not reproduce itself.
Always `[ -s ]` before `cmp` — `cmp` of two empty files passes.

### 5. Red-on-success traps
Twice this arc a **fix made the suite fail**: `run-tests.sh`'s `KNOWN_FAIL` counts
a newly-passing known-failure as a gate failure (E174 repaired two roots), and a
mutant's `sed` pattern matched a line the fix rewrote, so the probe stopped
building (E175). Expect the suite to go red *because the change worked*.

### 6. Environment
Work in a **worktree off `/workspace/chirality`, under `/workspace`. Never
`/tmp`** — the sandbox exhausts file descriptors and bash stops loading. Never
work in `/workspace/chirality` itself; Lane B is there and keeps uncommitted
files. **Verify a scratch `lib` is a real directory, not a symlink**, before any
`sed -i` — a prior run wrote through the link into the tree under test: nineteen
phantom failures.

## Queue

| # | element | note |
|---|---|---|
| 1 | **E176** `str-sub` | recommended next — a live memory-safety hole, 131 sites, already shaping other elements |
| 2 | **E182** arity evidence | retires 3 of `Judg`'s 38 nullary arms |
| 3 | **E179** face registry authoritative | 5 ad-hoc `ansi-bold` sites + `lookup-face` synthesising for unknown names |
| 4 | **E180** face-aware incremental redraw | unreachable today; the hazard **E175 creates** |
| 5 | **adoption** | `dg-doc`/`doc->rendering` still have **no `prog/` consumer**. E181 narrowed this — `typing/diag` renders through `Doc` inside `lib/` — but did not close it. Fifth "built but unadopted" instance in this repo |

## Cross-lane, not gate-enforceable

- **`typing/pretty` no longer exists** — the key is **`surface/pretty`**; E146 imports that.
- **The compiler changed size twice.** Lane B measurements taken earlier were taken
  against a different binary.
- A `case` prints multi-line at **every** width and forces every **enclosing** form
  multi-line too (`doc-fits` refuses a hard break inside the group it measures).
  Accepted, not a defect — but a `.manifest` round-trip fixture assuming single-line
  output at a wide width will be surprised.

## Unminted, named, needing an author

- **`typing/totality.chiral:29` declares a third local `Term`.** E181 removed one of
  the two duplicates; this one survives and has no row. Lane A's band is E184–E189
  and neither a pre-run, a spec run nor an audit may mint.
- `lib/prelude/doc.chiral:6` still cites `lib/typing/pretty.chiral` — one line of
  doc rot, doc-tier.
