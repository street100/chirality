---
element: E182
slug: arity-evidence
title: **The arity judgments carry their arity**
kind: BUILD-PROPER
example: examples/E182-arity-evidence.md
status: audited
updated: 2026-09-02
---

# E182 SPEC — **The arity judgments carry their arity**

> Implementation contract produced by the `example-to-spec` run. Bridges the
> drafted worked example into an executable change plan. An implementation run
> follows THIS file; the example remains the design rationale behind it.

> **⚑ Audited, and the one open call is ANSWERED.** Decision 12 was the
> element's own scope question, raised by the EXAMPLE audit and carried verbatim
> out of the example's §6. The author answered **yes** on 2026-09-02 and it is
> closed in `records/author-calls.md` under *Closed since the hoist*. Every
> decision is now dispositioned and §4 to §6 are executable. ⚑ The question's
> framing is what made it look like a call: it counted the arm arriving while
> two leave, and the element is **net arm-negative**.

> **⚑ The catalog premise was falsified before this SPEC was written.** The row
> proposed retiring three `Judg` arms. Two of the three are unreachable and one
> of those two is unretirable behind a sha256 pin, and the live comparison the
> row never named is a fourth arm. The correction is carried by all three
> tracked authorities already (`docs/elements/catalog.md:495`,
> `docs/elements/ledger.md:317`, `docs/arcs/diagnostics-arc.md:160`), and this
> SPEC is built on the corrected shape. Nothing below re-measures it.

## 1. Deliverable

- **After this runs:** `lib/typing/diag.chiral` carries a tenth `Reason` arm,
  `(r-arity (what Subject) (expected I64) (actual I64))`, every one of the eight
  exhaustive `case`s over `Reason` gains its arm, and the two live arity
  comparisons in `lib/typing/kernel.chiral` build it with the two integers they
  already hold. A compiler built from those sources refuses `(mk2 1)` against a
  two-field constructor with `mk2 wrong number of arguments (expected 2, actual
  1)` instead of dropping both counts on the floor, and `dg-doc` lays the two
  counts out on their own lines. Both arms behind those two comparisons,
  `jg-tparam-arity` and `jg-ctor-arg-arity`, leave `Judg`, taking it from 38
  arms to 36.
- **Non-goals:**
  - Retiring `jg-tcon-arity` or `jg-ctor-arity`. Both are unreachable, one is
    spelled by a sha256-pinned fixture, and their disposition is
    `diagnostics/D1`.
  - `dg-expected` / `dg-actual` accessors. Decision 6.
  - Any change to the nine `dg-msg` strings E157 pins byte-for-byte.
  - The other 34 nullary `Judg` arms. This element repays one family.
  - Repairing `samples/e157_diag.prog:50` and `tools/test/doc.sh:230`, whose
    exhaustiveness claim a tenth arm degrades. Both are sha256-pinned and the
    work is `diagnostics/D2`.
  - Any edit to `lib/prelude/doc.chiral`. The `dg-doc` arm uses six existing
    `Doc` constructors and adds none.

## 2. Baseline (what already exists)

- **Conformance-map verdict:** none. E182 postdates the map snapshot, so the
  pack's map section reads `(none, treat as BUILD)`. The build-state authority
  for this element is the corrected catalog row and the arc row, both cited
  above.

⚑ **The `diag.chiral` line numbers below were repointed on 2026-09-02, after this
element was implemented.** Commits `65bec90` and `d26d7a1` inserted the arm, its
two helpers and eight renderer arms, which shifted every name under them. The
numbers now name where each binding **is**, so a reader can open them; the prose
around them describes the tree **before** E182, which is what a baseline is for.
Nine names moved: `Reason` 122 to 121, `dg-subject-name` 159 to 161,
`dg-subject-tag` 176 to 178, `dg-subject` 193 to 195, `dg-newcomer` 223 to 227,
`dg-declared` 259 to 264, `dg-msg` 317 to 326, `dg-judg-msg` 419 to 429,
`dg-doc` 519 to 561.

- **Live code this composes with, and none of it is respecced:**
  - `Reason` at `lib/typing/diag.chiral:123`, E157's evidence-bearing sum, nine
    arms. `r-mismatch` already carries `(expected Term) (actual Term)` and
    `r-usage` already carries `(declared Qty) (observed Qty)`, so the field
    order and the naming this element follows are the file's own.
  - The eight exhaustive `case`s over `Reason`, all in `diag.chiral`, none with
    a `_`: `dg-reason-tag` (`:147`), `dg-subject` (`:196`), `dg-incumbent`
    (`:209`), `dg-newcomer` (`:228`), `dg-declared` (`:265`), `dg-observed`
    (`:273`), `dg-msg` (`:328`), `dg-doc` (`:565`). The comment above `dg-msg`
    states the intent this element depends on: a new `Reason` constructor must
    break every renderer loudly.
  - `Subject` at `:80`, twelve arms, with `dg-subject-name` (`:162`) and
    `dg-subject-tag` (`:179`) already casing all twelve. `subj-data` and
    `subj-ctor` are the two subjects the detection sites already pass.
  - `i64->str`, the prelude extern at `lib/prelude/prelude.chiral:87`, already
    called from `diag.chiral:670`. The new message needs no new dependency.
  - `check-tcon` (`lib/typing/kernel.chiral:1049`), whose length guard is the
    line above its refusal, and `con-check` (`:1104`), whose guard sits five
    lines into its body. Both hold `(llen Term args)` beside the count it is
    compared against, and both discard the pair.
  - `Doc` and `doc->str` in `lib/prelude/doc.chiral`, E158's layout algebra, and
    the thirteen `d-tag` sites `dg-doc` already carries.
  - The gate devices this element copies instead of inventing: `mutlib` and the
    pinned-verdict mutant runner (`tools/test/matcher.sh:146,297`), the
    compiler-level mutant that reads a real refusal (`tools/test/diag.sh:183`
    with `refuse_msg` at `:66`), and the assembled-needle idiom that keeps a
    census row from matching its own source (`tools/test/doc.sh:291-292`).
    ⚑ **The scratch `lib/` comes from `mutlib` (`tools/test/matcher.sh:146`) and
    not from `diag.sh:184-185`**, which open-codes `cp -a` plus `sed -i` with no
    symlink guard. The symlink refusal sits at `matcher.sh:149` and the no-op-`sed`
    refusal at `:156-158`, and both are load-bearing here.

- **True delta:** one `Reason` arm, two message helpers, eight renderer arms,
  two repointed detection sites, two retired `Judg` arms, and a Phase 24 gate.
  Fifteen `.chiral` bindings move across two files: the `Reason` and `Judg` data
  forms, `dg-arity-noun` and `dg-arity-msg`, the eight `case`s over `Reason`,
  `dg-judg-msg`, and the two detection sites. Both files are inside
  `prog/compiler.prog`'s import closure.

## 3. Decisions

Every open question from the example's §6 and every knob from its §5,
dispositioned. Twelve is the only one carried out of this run.

| # | Question | Disposition | Rationale / owner |
|---|----------|-------------|-------------------|
| 1 | Which of the four `Judg` arity sites the element repoints | RESOLVED | Two. The live comparisons at `kernel.chiral:1042` and `:1097`. The arms at `:1050` and `:1107` sit behind guards their only callers apply, so there is no honest `expected` or `actual` to hand them. Measured by the example's §2 finding 1 and by four probes, and carried by all three tracked authorities |
| 2 | Whether `jg-tparam-arity` is retired once `check-tcon` stops building it | RESOLVED | Retired. It is declared at `diag.chiral:107`, rendered at `:446`, and constructed at exactly one site, `kernel.chiral:1042`, which commit 2 repoints. No gate script and no fixture pins its message. The corrected catalog row states the retirement, so it widens no scope |
| 3 | What happens to `jg-ctor-arg-arity`, which this element also leaves unconstructed | **RESOLVED: retired**, alongside decision 2 | ⚑ **This row read DEFERRED until the orchestrator measured the count and corrected all three tracked authorities at `f406524`.** Measured: declared at `diag.chiral:109`, rendered at `:452`, constructed at exactly one site, `kernel.chiral:1097`, which commit 2 repoints. No gate script and no fixture pins its message; the only hits on either string outside `lib/` are prose under `docs/examples/`. Keeping it would manufacture a third dead arm as a side effect of the element that exists to remove that class, which is worse than the state E182 starts from. `Judg` goes 38 to 36. `diagnostics/D1` keeps only the two **unreachable** arms, `jg-tcon-arity` and `jg-ctor-arity` |
| 4 | The `dg-arity-msg` wording, which no golden constrains | RESOLVED | The existing sentence survives verbatim as the prefix and the evidence is appended: `<name> wrong number of arguments (expected 2, actual 1)` and `<name> wrong number of type parameters (expected 1, actual 2)`. E157 introduces no new diagnostic and changes no wording (`diag.chiral:300-302`); this element adds evidence under the same rule, so the two probe refusals keep their meaning and gain their numbers, which is the example's §6 conformance target |
| 5 | Field order on the arm | RESOLVED | `(expected, actual)`, following `r-mismatch` (`diag.chiral:126`) and `r-usage` (`:128`). The reverse order follows nothing in this file |
| 6 | Whether `dg-expected` / `dg-actual` return `0` or a `(Maybe I64)` for the other nine arms | RESOLVED, and neither: **the accessor pair stays unbuilt** | `dg-declared` and `dg-observed` exist because `samples/e157_diag.prog` reads them. Nothing reads an arity count off a `Reason` today, and this gate reads both counts through `dg-msg` and `dg-doc`. Two accessors would add twenty boilerplate arms to an element whose cost is the open author question. Home for the unbuilt pair: nobody's yet, recorded in §6 |
| 7 | Whether a new `Subject` arm distinguishes type parameters from constructor arguments | RESOLVED | No new arm. `dg-arity-noun`, a new `(-> Subject Str)` casing all twelve `Subject` arms the way `dg-subject-tag` (`:178`) does, answers `"type parameters"` for `subj-data` and `"arguments"` for every other arm. One arm serves both sites and the sentences stay distinct. G3 is that claim as a row |
| 8 | FD-08: the shipped binary trails its sources by one generation | ACCEPTED, and it is a precondition report rather than a defect | `records/findings.md:103-110` records the measurement with state ACCEPTED. `7341ddf` changed emitted code, so `B1 != B2` and `B2 == B3` is the ordinary two-generation bootstrap. Re-filing it as a blocker would re-argue an ACCEPTED finding. Its one live consequence is attribution, which decision 9 disposes of |
| 9 | Whether E182 promotes once from the unmodified tree first, or promotes once and reports two deltas | RESOLVED, orchestrator's call | One `build-new → test → promote`, no separate re-promotion commit. Two deltas reported **separately**: the inherited one, `1,147,256 → 1,184,120 B`, which belongs to the 13 commits of other arcs since E181 promoted at `58603c3`; and E182's own, `B_after` minus `B_before` where `B_before` is 1,184,120 B on the unmodified tree. The fixpoint is **predicted at generation two**, so a gen-one fixpoint fails to be the target and its absence convicts nothing |
| 10 | `lib/typing/kernel.chiral` is absent from both of the lane-split document's file enumerations | RESOLVED, and the document stays unedited | `docs/decisions/decision-lane-split.md:260` reads "`lib/typing/` belongs to diagnostics. The enforcement arc names no path under it", which covers the file at directory granularity, and the enforcement arc names no path under `lib/typing/`. The two enumerations at `:94-97` and `:245` omit the file and that gap is recorded in the example's §6. Proceed on the prose; repairing the enumerations is a doc-tier write |
| 11 | Where the residue goes, with `E184-E189` contended | RESOLVED | Arc-local ids under `docs/decisions/decision-work-ids.md`. `diagnostics/D1` and `diagnostics/D2` already have rows in `docs/arcs/diagnostics-arc.md:223-224`. **No `E#` is minted by this run**, so the deferral rule is satisfied without touching a contended band |
| 12 | **The element's own scope, carried verbatim from the example's §6** (below) | **RESOLVED: yes, 2026-09-02, by the author.** Net arm-negative is the deciding fact the question's framing hid: `Reason` 9 to 10, `Judg` 38 to 36, so one more data constructor leaves than arrives. Closed in `records/author-calls.md` | The element shrank under its own research: from retiring three arms to minting one and repointing two sites. Two settled facts bear on it and are recorded rather than weighed. The boundary-sums standing directive's test is met verbatim at both sites, since both counts exist at the comparison and are absent at the renderer. `docs/decisions/decision-lane-split.md:198` makes closing E182 part of Lane A's definition of done. Neither settles whether the shrunken version is the version the author wants. **Owner: the author.** A row in `records/author-calls.md` is owed |

**Decision 12, verbatim:**

> Does `r-arity` carrying `(what Subject) (expected I64) (actual I64)` still pay
> for a tenth `Reason` arm and the eight renderer arms that arm costs, when it
> repoints two call sites?

Not answered here. The element keeps its measured scope in both directions,
with no quiet rescope to make the question go away. §4 to §6 are executable the moment the answer is yes.

## 4. Change plan (ordered, commit-sized)

Five commits. Commits 1 and 2 change compiler source and the promotion is
commit 3, so the gate in commit 4 runs against the compiler that carries the
change. Every commit is pathspec'd, because another session commits to this
tree concurrently.

### Commit 1: `r-arity`, its two helpers, and the eight renderer arms

- **Target:** `lib/typing/diag.chiral`.
- **Change:**
  - `Reason` (`:123`) gains a tenth arm below `r-relayed`:
    `(r-arity (what Subject) (expected I64) (actual I64))`, with the one-line
    comment the file's style gives every arm.
  - Two new bindings beside the other `dg-*-msg` helpers, each with its
    `declare` in the block at `:305-313`:
    - `dg-arity-noun (-> Subject Str)`, casing all twelve `Subject` arms in
      `dg-subject-tag`'s order. `subj-data` answers `"type parameters"`, every
      other arm answers `"arguments"`. No `_`.
    - `dg-arity-msg (-> Subject I64 I64 Str)`, which is
      `(str-cat n (str-cat " wrong number of " (str-cat noun (str-cat " (expected " (str-cat (i64->str e) (str-cat ", actual " (str-cat (i64->str a) ")")))))))`
      with `n` from `dg-subject-name` and `noun` from `dg-arity-noun`.
  - The eight `case`s gain one arm each, in the order the arms already run:
    `dg-reason-tag` → `"arity"`; `dg-subject` → `w`; `dg-incumbent` and
    `dg-newcomer` → `(dc-none)`; `dg-declared` and `dg-observed` → `(qw)`;
    `dg-msg` → `(dg-arity-msg w e a)`; `dg-doc` → the `d-group` in the example's
    §5, whose head is `dg-arity-msg` plus the subject tag in parentheses and
    whose `d-nest 2` block carries `expected <e>` and `actual <a>` on their own
    laid-out lines, field for field with the `r-usage` arm at `:564`.
- **Size:** M. One data arm, two bindings of about 16 lines together, eight
  case arms.
- **Verify:** `./bin/chirality check lib/typing/diag.chiral` reports OK. The
  tree still compiles: nothing constructs `r-arity` yet, and no existing arm
  moved.
- **⚑ Do not add a `_` to any of the eight.** The eight compile errors that
  greet a tenth constructor are the mechanism, and a catch-all added to quiet
  them removes the property the element is built on.

### Commit 2: the two detection sites, and the two live arms retire

- **Targets:** `lib/typing/kernel.chiral`, with `check-tcon` (`:1049`) and
  `con-check` (`:1104`) · `lib/typing/diag.chiral`, with `Judg` (`:99`) and
  `dg-judg-msg` (`:431`).
- **Change:**
  - `check-tcon`'s false branch becomes
    `(tc-err (r-arity (subj-data dn) (llen Term (decl-params decl)) (llen Term args)))`.
    Both `llen` calls already appear on the guard line above, so this reuses two
    expressions instead of computing two.
  - `con-check`'s false branch becomes
    `(tc-err (r-arity (subj-ctor cn) (llen Field fields) (llen Term args)))`,
    the same reuse.
  - `jg-tparam-arity` (`diag.chiral:107`) and `jg-ctor-arg-arity` (`:109`) are
    both deleted from the `Judg` sum, and both of their arms are deleted from
    `dg-judg-msg` (`diag.chiral:431`), whose `jg-tparam-arity` arm sits at line
    446 and whose `jg-ctor-arg-arity` arm at line 452.
    **`Judg` goes from 38 arms to 36.**
    Repointing both live comparisons leaves both arms unconstructed, and keeping
    either one would manufacture a dead arm as a side effect of the element that
    exists to remove that class.
  - ⚑ **Nothing else in `kernel.chiral` moves.** The arms at `:1050` and
    `:1107` stay exactly as they are. They are unreachable behind guards their
    only callers apply, `jg-ctor-arity` is unretirable behind a sha256 pin, and
    both belong to `diagnostics/D1`.
- **Size:** S. Four line edits and four deletions.
- **Verify:** `./bin/chirality check lib/typing/kernel.chiral` reports OK,
  `grep -rn 'jg-tparam-arity\|jg-ctor-arg-arity' lib prog` returns nothing, and
  `Judg` counts 36 arms.

### Commit 3: the promotion, with both deltas reported separately

- **Targets:** `bin/chirality-bin`.
- **Change:** the build rule end to end, per `docs/definitions/working-discipline.md:19-42`
  and decision 9.
  - **Step 0, before any measurement of E182's own delta:** on the tree as it
    stood before commit 1, record `B_before = 1,184,120 B`, which is the figure
    FD-08 measured at `3be8915`. Re-measure it if any commit has touched `lib/`
    or `prog/` since, and say so if it moved.
  - `chirality_blob_file "lib:prog" prog/compiler.prog > blob.chiral`, then
    `(ulimit -s unlimited; bin/chirality-bin < blob.chiral > N1)`.
  - **Check every artifact non-empty before its `cmp`.** Two empty files compare
    equal, so an unguarded `cmp` reports a fixpoint on a build that produced
    nothing.
  - `chmod +x N1`, run the suite under `CHIRALITY_COMPILE=$PWD/N1`, then
    `(ulimit -s unlimited; ./N1 < blob.chiral > N2)` and `cmp N1 N2`.
  - **The fixpoint is predicted at generation two**, since the base already
    reproduces itself at `B2 == B3`. If `N1 != N2`, build `N3` and require
    `N2 == N3`. Generation one fails to be the target here, and its absence convicts
    nothing.
  - Promote `N1` to `bin/chirality-bin`. **Nothing replaces itself in place.**
  - **Report two deltas separately.** Inherited: `1,147,256 → 1,184,120 B`,
    carrying 13 commits of other arcs since `58603c3`. E182's own:
    `B_after − 1,184,120 B`, and the blob delta alongside it.
- **Size:** S in diff, L in wall clock.
- **Verify:** the suite is green under the promoted binary at its pre-Phase-20
  total, and both deltas are in the commit message.
- **⚑ Obligation (b) of `docs/decisions/decision-lane-split.md:105-119`: tell
  Lane B the moment this lands.** Any measurement they took against the old
  binary was taken against a different compiler.

### Commit 4: the Phase 24 gate, its script and its fixture

- **Targets:** `tools/test/samples/e182_arity.prog` (**NEW**) ·
  `tools/test/arity.sh` (**NEW**) · `tools/test/run-tests.sh` (**EDIT**: one
  `run_phase 24` line after `:301`, and one line in the phase-list header at
  `:11-34`) · `tools/test/MIGRATION-NOTES.md` (**EDIT**: one row in the
  "New here" table).
- **Change:** §5 in full. Registration:
  `run_phase 24 "the arity evidence (E182 r-arity)"                   arity.sh`
- **Size:** L. About 300 lines of bash and about 60 lines of fixture.
- **Verify:** Phase 24 green, and Phases 13 through 20 unchanged at their
  measured counts. ⚑ **The number is 24 and not 20.** This SPEC was written
  against Phase 20 and `d7d7cfe` registered `transport.sh` there between the
  audit and the implement run, after `matcher.sh` had already taken 19. All
  three of Lane A's reserved phases at `docs/decisions/decision-lane-split.md:30`
  are spent and only 18 went to Lane A. 21 through 23 are Lane B's and 8 through
  12 are forbidden, so 24 is the first number that collides with nothing.
  `records/findings.md` FD-11 holds the measurement.
- **⚑ An unregistered script never runs**, which is why G8 grades the
  registration line.

### Commit 5: the state rows say built

- **Targets:** `docs/elements/catalog.md:495` · `docs/elements/ledger.md:317` ·
  `docs/examples/INDEX.md:165` · `docs/arcs/diagnostics-arc.md` rows `:85`,
  `:160`, `:162`, and the Resume state at `:66-79`.
- **Change:** the catalog and ledger rows flip `design → built` with the
  measured landing note: the arm, the two helpers, the eight renderer arms, the
  two repointed sites, the two retired `Judg` arms with `Judg` at 36, Phase 24's script and its
  assertion count, both promotion deltas, and the residue with its arc-local
  ids. The INDEX row flips `specced → implemented`. The arc's Resume state takes
  the new suite total, the new binary size and the next action.
- **Size:** M.
- **⚑ Flip every authority in one change.** This arc has already caught three
  landings that moved one authority and left another reading `design`
  (`docs/arcs/diagnostics-arc.md:104`).

## 5. Conformance gate: `tools/test/arity.sh`, Phase 24

**⚑ Phase 19 is taken.** `tools/test/run-tests.sh:301` registers E173's
`matcher.sh` there, and `docs/decisions/decision-lane-split.md:30` reserves 18,
19 and 20 for this lane, so the lane holds 20 and E182 takes it.

**Golden behavior:** an arity refusal names both integers it compared, at both
of the two sites that can produce one, through both exits, and a tenth `Reason`
constructor cannot be added without every renderer accounting for it.

**Two upgrades this arc paid for, adopted verbatim.**

1. **Every mutant that can move a value row pins the full verdict line.** A mutant that reddens an
   unpaired row then fails the same assertion as one that reddens nothing. `verdict LIBDIR` prints all
   six value rows at once. M1, M7 and M8 are graded beside it, each for a stated reason: M1 kills every
   row at once, and M7 and M8 grade scans rather than values.
2. **The fixture asserts nothing and always exits 0.** It prints values; every
   comparison is the gate's, in bash. A fixture that grades itself can be wrong
   twice in the same direction, and one that exits on its first failure masks
   every later row from every mutant. Fields are separated by a single byte 1,
   the device at `samples/e173_matcher.prog:199`.

**Four traps, each live for this gate and each with its measured source.**

- **A `sed` expression inside a gate script can match its own source.** Phase
  17's census went red on a clean tree because a mutant spelled
  `(declare doc->rendering …)` at the start of a line in the gate itself
  (`docs/arcs/diagnostics-arc.md:106`). Every needle in `arity.sh` that a
  neighbouring census could see is **assembled from two halves**, the idiom at
  `tools/test/doc.sh:292` and `tools/test/matcher.sh:540`.
- **A fixture under `tools/` is inside a neighbouring gate's scan surface.**
  Three censuses grep `lib prog tools` for `^\((def|data|declare) <name>`:
  `doc.sh:380` over `prelude/doc.chiral`'s names, `render-doc.sh:436` over
  `protocol/render-doc.chiral`'s, and `row.sh:742` over `protocol/render.chiral`'s.
  So no binding in `e182_arity.prog` may take a `d-`, `brk-`, `m-`, `dfr`,
  `rdcf`, `rdcs` or `rnd-` prefix, or reuse any top-level name from those three
  files. The fixture prefixes every binding `ar-`. ⚑ **The rule covers the
  heredoc'd scratch root too.** Its text lives inside `arity.sh`, which is itself
  under `tools/`, and the three censuses are line-anchored greps that cannot tell
  a heredoc from a program: a `(def ` at the start of a line in the gate's own
  source is scanned exactly as if it were one in a fixture. `doc.sh:314-320`
  prefixes its probe `dpz-` for this reason; the scratch root prefixes `ar-`.
- **A line-based scanner makes a fixture's line breaks part of its contract.**
  Phase 16 went red because `e175_face.prog` split a call over two lines
  (`docs/arcs/diagnostics-arc.md:106`). Every probe form in `e182_arity.prog`
  stays on one line.
- **`(r-relayed ` may not appear anywhere in either new file.** `diag.sh:224`
  greps `lib prog tools` for that literal with a five-entry exclusion list, and
  `diag.sh` is sha256-pinned at `pretty.sh:389`, so the list cannot grow. G1
  needs an `r-relayed` value, so **G1's probe is a scratch root written into
  `$TMP`**, which E157's census correctly never looks at, and its `r-relayed`
  spelling is assembled from two halves so `arity.sh` itself does not contain
  the literal. This is `doc.sh:223-238`'s own disposition of the same trap, one
  arm later.

**The two probe programs.**

- `tools/test/samples/e182_arity.prog`, committed. It imports `typing/diag` and
  `prelude/doc`, builds `r-arity` values and prints their tag, their `dg-msg`
  and `doc->str 24 (dg-doc …)`. It builds no `r-relayed`.
- A scratch root `arity.sh` writes into `$TMP` from a heredoc, which builds one
  value of **all ten** `Reason` arms and prints the joined tags. It exists
  outside the tree for the reason above.

**The rows. Six value rows in the verdict line, two rows beside it, and every one of the eight mutants is RUN.**

| row | asserts | named mutant that must convict |
|---|---|---|
| **G1: the tenth tag, over all ten arms** | On the scratch root: `dg-reason-tag` over one value of every `Reason` arm joins to `redeclared,mismatch,usage,linear,arrow,unbound,skipped,judged,relayed,arity,`. ⚑ This is the row `samples/e157_diag.prog:50` can no longer make: it joins nine hardcoded values, its comment claims one value of every arm, and a tenth arm leaves the claim false with nothing going red. That file is sha256-pinned and `diagnostics/D2` owns repairing it; this row keeps the guarantee at full width for E182's own arm | **M1 `tag-loses-the-arity-arm`**, and ⚑ **it is graded beside the verdict line rather than inside it**: delete the `r-arity` arm from `dg-reason-tag`. A non-exhaustive `case` in `diag.chiral` refuses the whole module, so the fixture, the scratch root and the compiler build all die together and the verdict line reads six `bad` -- which is what a `sed` that merely broke the syntax also reads. So M1 asserts the **refusal text**: the build against the mutated `lib/` must be refused with the non-exhaustive-case message, the string `diag.sh:174-177` already pins as `load: non-exhaustive case`. That is the eight-renderer property as a checked row; an all-red verdict line is not |
| **G2: the flat exit carries both counts, at both subjects** | `dg-msg (r-arity (subj-ctor "mk2") 2 1)` is exactly `mk2 wrong number of arguments (expected 2, actual 1)`, and `dg-msg (r-arity (subj-data "Box") 1 2)` is exactly `Box wrong number of type parameters (expected 1, actual 2)`. Both strings pinned in full, so a message that keeps one count and drops the other cannot pass | **M2 `msg-drops-the-expected-count`**: `dg-arity-msg` stops calling `i64->str e`. ⚑ **Four other rows read that helper**: it is `dg-doc`'s head (G4) and it is the sentence both compiled refusals carry (G5, G6), so the pinned line is `G1:ok G2:bad G3:bad G4:bad G5:bad G6:bad`. M2 is told apart from M1 by G1 staying `ok`, and from M3 by G4 and G5. ⚑ **The mutant must corrupt `dg-arity-msg` and never the `Reason` arm**: corrupting the arm stops the fixture compiling, which convicts G1 and leaves G2 unexercised |
| **G3: one arm, two nouns, read off the subject** | The two G2 strings differ in exactly their noun, so a single `Reason` arm serves a site about type parameters and a site about constructor arguments without a new `Subject` arm. Asserted as the two nouns extracted from the two strings, `type parameters` and `arguments` | **M3 `noun-collapses-to-arguments`**: `dg-arity-noun`'s `subj-data` arm answers `"arguments"`. G3 red and G2 red, since the pinned `Box` string moves too, and **G6 red**, since the type-parameter refusal carries the same noun. The `mk2` sentence is untouched, so the pinned line is `G1:ok G2:bad G3:bad G4:ok G5:ok G6:bad`. ⚑ The pair is deliberate: M2 and M3 both redden G2 and G3, and G4 / G5 in the full verdict line are what tell them apart |
| **G4: the `Doc` exit lays both counts on their own lines** | `doc->str 24 (dg-doc (r-arity (subj-ctor "mk2") 2 1))` puts `expected 2` and `actual 1` on separate lines under a two-space nest, the shape the `r-usage` arm at `diag.chiral:564` already has. Pinned as the full multi-line string | **M4 `doc-arm-drops-the-nest`**: the `r-arity` arm of `dg-doc` returns its head alone. G4 red only, and G2 stays green, which is the point: the two exits are graded separately because a fix to one leaves the other unfixed |
| **G5: the constructor site reports, through a real compile** | ⚑ **The strongest row, and the one eleven toothless rows in this arc did not have.** A compiler **built from the `lib/` under test** is handed a source that applies a two-field constructor to one argument, and its refusal is read off stderr: `load: mk2 wrong number of arguments (expected 2, actual 1)`. The device is `diag.sh:183-201` with `refuse_msg` (`:66`). ⚑ **The base row builds its compiler from `$REPO/lib` too, so the row grades the sources and not whatever binary happens to be shipped.** `$CC` is still the bootstrap that turns each blob into an executable (`diag.sh:56`); what the row never does is read a refusal off `$CC` itself | **M5 `con-check-reverts-to-a-stub`**: `con-check`'s false branch goes back to a `r-judged`. ⚑ **Its revert target must be `(jg-ctor-arity)`, an arm that survives.** `jg-ctor-arg-arity`, the arm the site used to build, was deleted by commit 2, so a mutant reaching for it fails to compile and the row scores BUILD:fail instead of convicting, which is a toothless mutant wearing a red row. The refusal becomes `load: constructor arity`, G5 the only red, and the row emits a stub string the shipped compiler has never been able to produce |
| **G6: the type-parameter site reports, through a real compile** | The same compiler refuses a source applying a one-parameter data type to two type arguments with `load: Box wrong number of type parameters (expected 1, actual 2)`. Two sites, two rows, because one repointed site passing says nothing about the other | **M6 `check-tcon-reverts-to-a-stub`**: `check-tcon`'s false branch becomes `(tc-err (r-judged (subj-data dn) (jg-tcon-arity)))`. ⚑ **Its revert target is `(jg-tcon-arity)` for the same reason M5's is `(jg-ctor-arity)`**: `jg-tparam-arity`, the arm the site used to build, was deleted by commit 2. The refusal becomes `load: tcon arity`, G6 the only red, and the two stub strings the mutants emit are different, so neither row can pass by reading the other's failure |
| **G7: both live arms are gone, and the new arm is built at exactly two sites** | Outside the verdict line, and both halves are E182's own claims. **(a)** Neither `jg-tparam-arity` nor `jg-ctor-arg-arity` appears anywhere under `lib/` or `prog/`, and `Judg` reads **36** arms counted out of `diag.chiral`. ⚑ **The count takes every `(jg-` head on a line, all of them**: `Judg`'s arms run three to a line, so `doc.sh:298-307`'s paren-balanced walk is the device but its one-arm-per-line `print` is not -- a line count reads 13 and grades nothing. **(b)** `r-arity` is **constructed at exactly two sites** under `lib/` and `prog/`, `kernel.chiral:1042` and `:1097`, which is the claim that the element repointed the two live comparisons and invented no third one. ⚑ **`diag.chiral` is excluded by name**, because the arm's own declaration and its eight `case` patterns all spell `(r-arity ` and an unexcluded scan reads eleven. Both needles assembled from two halves | **M7 `put-the-arm-back`**: add `(jg-tparam-arity)` back to `Judg` in a scratch `lib/` and revert `check-tcon`'s false branch to build it. The census must see both: the arm count reads 37 and `r-arity`'s construction sites drop to one. Without this row the scan passes on a needle matching nothing anywhere, which is what it would do if either name were renamed |
| **G8: Phase 24 is registered** | `run_phase 24 .* arity.sh$` appears exactly once in `run-tests.sh`, asserted with `row.sh`'s `reg()` device, which greps **a different file from the one doing the grep** and so cannot match its own source | **M8 `unregister-the-phase`**: delete the `run_phase 24` line from a **copy** of `run-tests.sh`; the row must notice |

**Cost, stated because it is the one number this SPEC cannot take.** G5 and G6
each need a compiler built from the `lib/` under test, so `verdict` costs one
compiler build per call: 1 base plus M2 to M6, **six compiler builds**. M1 costs
one refused program build, M7 one scan, M8 none. **The implement run measures
Phase 24's wall clock and reports it.** If it exceeds 120 s, split the line: keep
the six-token verdict for the base, M5 and M6, and give M2, M3 and M4 a
four-token fixture-only line over G1 to G4, which costs a small program build
each and takes the count to three compiler builds. M2 and M3 stay distinguishable
under the short line, since G4 separates them. Record which was chosen and the
measurement behind it.

**Not gate rows, deliberately, and each says where it lives:**

- **A byte-identity row over the nine `dg-msg` strings E157 pins.**
  `pretty.sh:365-372` already pins `diag.sh`, `doc.sh`, `row.sh`, `face.sh`,
  `render-doc.sh` and the three fixtures by sha256, and Phase 13 grades the nine
  strings. A second pin here would grade them twice.
- **A `Reason` name census.** `diag.sh:298-315` builds its name set out of
  `diag.chiral` and interpolates the count into its own pass message without
  comparing it to a literal, so the three new names (`r-arity`, `dg-arity-noun`, `dg-arity-msg`) grow the set by three and move no
  assertion. Measured, and a second census would double-grade it.
- **Anything about `jg-tcon-arity` or `jg-ctor-arity`.** `diagnostics/D1`.
- **Repairing `e157_diag.prog:50` or `doc.sh:230`.** `diagnostics/D2`.

**Green line:** the last measured suite total is **321 passed, 0 failed**
(E173, `docs/examples/INDEX.md:163`). **This run did not execute the suite**, on
a 3.85 GB box with no swap, so the implement run measures the total before
commit 1 and after commit 4 and reports both. Expected: `321 → 321 + <Phase 24's
count>`, Phases 13 through 19 unchanged, `gate PASSED`, exit 0. ledger-lint
stays at its baseline of 251 findings, and no check A to V gains one.

**Done when:** Phase 24 is green with all eight rows holding and all eight
mutants convicting at their pinned verdict lines, the promoted binary reproduces
itself, both promotion deltas are reported separately, and the five authorities
in commit 5 agree that E182 is built.

## 6. Residue & links

**Deliberately unbuilt, each with its home:**

- **The two provably unreachable `Judg` arms get a disposition.** `jg-tcon-arity`
  (`kernel.chiral:1050`) and `jg-ctor-arity` (`:1107`) are dead branches kept for
  totality, and `tools/test/samples/e158_doc.prog:189` spells the second one's
  message behind a sha256 pin held at `pretty.sh:371`, `face.sh:545` and
  `row.sh:644`. Whether such an arm is removed, kept with its proof written
  beside it, or refused by a totality gate belongs to **`diagnostics/D1`**
  (`docs/arcs/diagnostics-arc.md:223`), whose scope after decision 3 is these two
  arms and nothing else.
- **The `Reason` exhaustiveness claim becomes checkable.**
  `samples/e157_diag.prog:50` and `tools/test/doc.sh:230` both assert one value
  of every `Reason` arm, and a tenth arm degrades that to nine of ten with
  nothing going red. Both files are sha256-pinned, so repairing them is a change
  to E157's and E158's gates. **`diagnostics/D2`**
  (`docs/arcs/diagnostics-arc.md:224`). G1 keeps E182's own arm covered in the
  meantime.
- **`dg-expected` / `dg-actual`.** Unbuilt, and the home is nobody's yet. They
  earn a row the day a consumer reads an arity count off a `Reason` instead of
  off its message. Decision 6.
- **The other 34 nullary `Judg` arms.** E157's taxonomy debt is repaid one
  family at a time and this is the first payment. No `E#` is minted for the
  rest, since `E184-E189` is contended with the enforcement arc and the deferral
  rule forbids naming a number nobody has minted.
- **The two file enumerations in `docs/decisions/decision-lane-split.md`**
  (`:94-97`, `:245`) omit `lib/typing/kernel.chiral`, and `:94` still names
  `lib/typing/pretty.chiral`, which E181 moved to `lib/surface/pretty.chiral`.
  The prose at `:260` governs, so E182 proceeds. Repairing the enumerations is a
  doc-tier write and no element owns it.

**Follow-on:** none minted by this run. `diagnostics/D1` and `diagnostics/D2`
are arc-local ids with tracked rows, and promotion to an `E#` waits on the band.

**Related:** [[E182-arity-evidence]] · [[E157-typed-diagnostics]] (the `Reason`
sum, the nine pinned goldens, the 38-arm `Judg` this repays) ·
[[E158-doc-formatter]] (`dg-doc`, the fixture that pins `jg-ctor-arity`, and the
audit FLAG that minted this row) · [[E181-pretty-term-doc]] (Phase 18, and the
promotion base FD-08 measures) · [[E173-total-matcher]] (Phase 19, and the
pinned-verdict mutant device this gate copies) ·
[[decisions/decision-lane-split]] · [[decisions/decision-work-ids]] ·
[[arcs/diagnostics-arc]] · `records/findings.md` FD-08.
