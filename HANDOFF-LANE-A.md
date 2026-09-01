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

### 1. Element state lives in TRACKED docs — this is FIXED, keep it that way
`.planning/` is excluded by `.gitignore:12`, and the consequence is not just
invisibility: **every worktree carries its own divergent copy.** This arc's rows
lived only in one worktree's copy; the live checkout never had them, which is a
split-brain, and is why two sessions minted `E173` with nothing detecting it.

**Fixed 2026-09-01.** The tracked homes now carry element state:
- **`docs/elements/diagnostics-arc.md`** — every row this arc built or minted,
  catalog and ledger text verbatim.
- **`docs/definitions/status-ledger.md`** — the arc's build-state block, the suite
  figures, and the compiler size.
- Both `.planning/` copies reconciled (12 rows + 4 SPECs).

**Keep it that way:** an element fact a second reader needs goes in a tracked file
in the same change that creates it. `.planning/` is for working detail — change
plans, decision tables, SPEC bodies — that may legitimately die with the worktree.

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

**From Lane B's E163 design session, 2026-09-01.** Detail:
`.planning/MANIFEST-DESIGN-MAP.md`.

- **The printer is the front end for file types, so its configuration space is a
  Lane A deliverable.** Settled model: `.manifest → pretty parser → upper chirality
  source → tal → mach`. One translator, one configuration per file type, emitting
  source. Lane B supplies a configuration and writes no printer. Axes it needs
  selectable: exit (`doc->str` / `doc->rendering` / `doc->json`), width, layout,
  header row on or off, display names, note placement, ordering.
- **The round-trip gate runs once per configuration.** `read (show_c v) = v` is
  E146's row; what this adds is that a *configuration* is admissible iff the law
  holds for it, so a compact layout dropping a note column fails mechanically.
  Phase 18's 61 rows gate one configuration, and that is the shape repeated.
- ⚑ **`show (read s) = s` is FALSE and should be renounced in writing.** Four
  measured axes: whitespace, comments, elidable quantities (`parse-binder` defaults
  to `2`), application spine spelling (`((f a) b)` and `(f a b)` elaborate
  identically). What holds is quotient equality with a canonizer, plus
  `fmt = show ∘ read` idempotent.
- **`doc->rendering` is editable** — author call 2026-09-01, for the ownership and
  access model. So it owes the round trip like any other exit, and a rendering may
  show nothing the file does not contain. A hint computed over the value is legal;
  one sourced from outside it is not. Cheaper held from the start.
- **`(t-ann (tm Term) (ty Term))` against the surface `(the ty e)`.** A
  schema-driven printer emitting fields in declaration order produces a term that
  re-elaborates differently. One such case in `Term` today; no gate finds a second.

**From Lane B's wiring sweep, 2026-09-01.** Detail: `docs/definitions/bug-classes.md`
(tracked) and `.planning/README-REWRITE.md`. Measured on this tree, after E181 landed.

### The upper → tal boundary: the checker is not in the compiler

Your note says `preserve-check` is built and unadopted. It is worse than unadopted.
**`lib/lowering/tal/check.chiral` is not in the compiler's import closure at all.**
Not merely uncalled. Not compiled in.

The closure of `prog/compiler.prog` is **59 modules, 16,463 LOC**, out of `lib/`'s
103 modules and 25,559. Ten modules of checking machinery, **1,680 LOC**, sit
outside it:

| module | LOC |
|---|---|
| `typing/totality` | 387 |
| `lowering/upper/optimize` | 254 |
| `lowering/tal/check` | 246 |
| `lowering/tal/eval` | 187 |
| `lowering/upper/eff-lower` | 183 |
| `typing/row-infer` | 137 |
| `lowering/tal/spec` | 126 |
| `typing/kernel-core` | 60 |
| `typing/reflect-floor` | 54 |
| `typing/effects` | 46 |

`ck-fn`'s only call site in the tree is `lowering/upper/optimize.chiral:250`, and
`optimize` has zero importers, so it is outside too. The reference interpreter and
the spec are outside. The effect membrane is outside.

**What the compile actually does.** `compile-fn` lowers eligible defs to typed SSA
(`TFn`) in every compile. `erase-fn` then strips every `TFn` to a neutral `NFn`,
and `emit-elf-m` takes `(List NFn)` only (`compile-emit.chiral:292`). So the types
are produced and discarded with nothing checking them in between.

One check does ship and does run: `ck-tiprog`, the E76 syscall chokepoint, at
`compile-emit.chiral:296`. Do not conflate it with the preserve check.

**And a lot never lowers.** `skip-reason` (`lower.chiral:83-93`) keeps a def upper
when it is dependently typed, **effectful**, carries a quantified binder, or has a
type that does not lower. E70's own catalog row says self-hosting cannot go native
without effectful lowering. The lowered-versus-skipped ratio is **unmeasured**;
`status-ledger` marks the old 48/48 as a Python-era count.

### `Judg` cannot say it, so the boundary lands in Lane A's file

`diag.chiral:97-110` has 38 `Judg` constructors and `:120-137` has 9 `Reason`
shapes. **There is no constructor for a preserve-check failure, an effect
violation, non-termination, a bounds violation, an overflow, or ABI disagreement.**
A rule cannot refuse what the vocabulary cannot say.

E182 is Lane A's and it edits `Judg`. So enforcing upper → tal needs a `Judg` arm
before it needs a caller, and that arm is in a Lane A file. This is the one place
the boundary work is not lane-neutral.

⚑ `diag.chiral:20-25` records a live landmine any new arm inherits: a `case` over
`Reason`/`Subject`/`Judg` must be the direct body of a `lam`, never nested in a
case arm. Seven exhaustive `case`s over `Reason` gain an arm each.

### "Real tests": your eleven toothless rows and my 86 roots are one defect

`tools/test/run-tests.sh:280` prints its own verdict:

> `compile-only: N roots built, N failed -- gates, but asserts nothing`

**86 roots** go through that. A module that compiles passes. Nothing asks whether a
module is inside the compiler's closure, which is exactly how 1,680 LOC of checking
machinery got written, compiled clean, marked built, and never ran.
`prog/test-runner.prog:8-9` already calls "built but unadopted" this repo's
measured failure mode and counts four. The sweep says ten.

Your finding and mine are the same hole at two altitudes: a row that cannot fail,
and a module that cannot run.

### Requirements this arc now carries, stated plainly

Author directive, 2026-09-01: **enforce upper ↔ lower as a must-always**, and
**enforce real tests**.

1. **Everything lowers.** `skip-reason`'s four exclusions go. Effectful is E70;
   dependent types, quantified binders and non-lowering types have no element.
2. **What lowers is checked.** `ck-fn` runs on every `TFn` **before** `erase-fn`,
   and failure refuses the compile.
3. **A closure gate.** A check that computes the compiler's import closure and
   refuses when a module declared required is absent. The machinery is already
   chirality: `module/resolve.chiral` has `collect-imports`, `parse-imports`,
   `walk-imports`, `walk-list`; `evidence/test-floor.chiral` is E168's floor.
4. **Every `Judg` constructor has an asserted refusal fixture.** Not compiled, run.
   `tools/test/samples/e170_reject_secret_leak.prog` is already a fixture with no
   runner.

1 and 2 together are the must-always. Either alone leaves the hole: everything
lowering with no check, or a check over a fragment.

⚑ **Neither band owns this.** Lane A is E184–E189, Lane B is E190–E195, and the
upper → tal boundary is in neither. It needs an author call: extend a band, or open
a third lane. I have not minted anything.

### Other findings from the Lane B session, for whoever needs them

- **The `let`-bound `case` defect is diagnosed and the old hypothesis is refuted.**
  There is no join. The verdict depends on **source arm order**, so it is
  first-arm-wins: arm 1 is inferred, its type becomes the expected type, later arms
  are checked against it. A branch-local assumption from the narrow hook escapes as
  the case's result type. Refusal at `kernel.chiral:1440`. `check-let`
  (`kernel.chiral:983`) is the only construct that drops into infer mode, which is
  the entire scope. The "widen the bound result" fix is **unsound** and the finding
  carries a counterexample that checks today. Three coherent shapes remain, so it
  needs a blueprint. `.planning/FINDING-let-bound-case-refinement-2026-08-31.md`.
- **`docs/definitions/bug-classes.md`** is tracked and holds 28 failure classes with
  state and element. 6 refuse today, 5 partial, 3 unwired, 2 design, 11 with
  nothing. It is the target list for "only logical bugs".
- **`ledger-lint` check T** now walks `docs/examples/E*.md` and
  `.planning/specs/E*-SPEC.md` and asserts each has a catalog row and an INDEX row.
  Every prior check started from the registry and looked outward, which is why E86
  could lose its row while keeping both artifacts. T currently flags **E57**, which
  has example, spec, catalog and ledger rows but **no INDEX row**, so check N has no
  pipeline state for it.
- **`superseded` is now a lifecycle state** with a `superseded_by:` field, defined
  in `docs/examples/INDEX.md` where the vocabulary lives. `pack.py` refuses every
  stage on a superseded artifact.
- **19 catalog rows say not-built while INDEX says implemented.** Six carry a
  deliberate "recorded rather than picked" flag; thirteen are simply stale. Nothing
  lints the catalog's State column: check J compares membership, check N compares
  LEDGER against INDEX.
- `lib/prelude/doc.chiral:6` citing `lib/typing/pretty.chiral` is confirmed dead.
  `typing/pretty` no longer exists and is gone from the zero-importer list.

## Unminted, named, needing an author

- **`typing/totality.chiral:29` declares a third local `Term`.** E181 removed one of
  the two duplicates; this one survives and has no row. Lane A's band is E184–E189
  and neither a pre-run, a spec run nor an audit may mint.
- `lib/prelude/doc.chiral:6` still cites `lib/typing/pretty.chiral` — one line of
  doc rot, doc-tier.
- **`preserve-check` is built and unadopted** — demoted from ENFORCED 2026-08-31,
  zero callers (`status-ledger.md:121`). It is the gate carrying types across
  upper → tal, so "always lowering while carrying types" is a repair at that
  boundary rather than new work. `status-ledger.md:148` already records something
  called its "first customer" while it sits unadopted. Both lanes' output flows
  through that boundary and neither owns it.
