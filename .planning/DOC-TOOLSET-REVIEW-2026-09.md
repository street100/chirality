# Documentation toolset review, 2026-09

A report for the author, written before any change is dispatched. Scope is
capability, correctness and ergonomics of `tools/ledger-lint/ledger-lint.py`,
`tools/doc/doc.py`, `tools/lens/lens.py`, `tools/pack/pack.py`,
`tools/xlat/xlat.sh`, `tools/prose-lint/prose-lint.sh` and the skills that drive
them. Speed is out of scope and belongs to the run writing
`.planning/OPTIMIZATION-GAPS-2026-09.md`.

Every measurement below was taken on 2026-09-29 against `HEAD` `6de59d4`, in a
scratch `git worktree` so that nothing ran against the live tree. Where a
reproduction wrote into the worktree, the worktree was reset afterwards. Every
proposed fix is held to `.planning/protocol/reconcile.md` §"Proper or not at
all": the proper fix, or a proper smaller fix complete on its own.

## 1. The tools as they stand

| tool | does | known limits |
|---|---|---|
| `ledger-lint.py` | 40 checks, A to AN, each a claim in the tree against the tree. Three outcome classes, violation, owed and vacuous, with exits 1, 2 and 0. `--next` hands back one task; `--census` counts citation spans | reads the working tree; G and R read `docs/` only and only `.py` and `.chiral` spans; H and M are vacuous (LIM-01); AI reads whole-file commit dates (LIM-20, LIM-22). The run on this `HEAD` reports 226 violations, 18 homes, 42 calls and 165 rulings owed, 2 vacuous |
| `doc.py` | `audit <doc>` prints one read-only bundle: the doc, its lint lines, conformance-map and INDEX rows for its `E#`s, the code behind each line citation, linked-note heads. `new-bank` scaffolds a bank | the code-slice section is empty for every `.chiral` citation (finding DT-05) |
| `lens.py` | `check` validates the four lens files; `author` lists what awaits a ruling; `overview` regenerates `docs/definitions/OVERVIEW.md`, with a read-only `--check`; `chain` counts the goal-to-element spine; `new` appends a row | nothing runs `overview --check` (DT-11) |
| `pack.py` | one bundle per pipeline stage, and the scaffolder and state-flipper for goal, arc, design, mint, spec and mark | bundle modes write into the tree, and unknown flags are ignored (DT-01) |
| `xlat.sh` | pins external sources, extracts RFC 2119 obligations, resolves `ID:LINE "span"` citations into pins, lists named sources beside their pins | `check` is gated for `docs/translations/` only (DT-12); a spaced source name is never counted as quoted (PRB-99 part 3, open) |
| `prose-lint.sh` | ten shape checks over prose, a density worklist, a baseline and `--regress` | the per-file form runs a smaller check set than the counter (DT-03, PRB-28) |
| skills | nine run procedures; seven of them call the tools above | several describe tool behaviour the tool does not have (DT-05, DT-10, DT-17, DT-18) |

## 2. Findings

Severity reads: **high**, a tool writes wrongly, or a check reports clean on a
defect a stage relies on; **medium**, a check misses a class of defect the tree
states a rule about; **low**, a false positive or a stale description.

### DT-01 `pack.py` bundle commands write, and a mistyped flag falls through to a write. High

- **Defect.** `pack.py <arc>/<id>` prints the design bundle, scaffolds the
  design and calls `set_roster_state(arc, rid, "designed")` at
  `tools/pack/pack.py:1159` with no guard on the row's current state. It prints
  a note when the row already carries an element and flips it anyway.
  `main` at `tools/pack/pack.py:1544` collects every `--` argument and tests
  for the ones it knows, so an unknown flag is ignored and the command runs
  its default mode, which for both the row form and the `E#` form is a write.
- **Reproduced.** On `errors-as-values/EV12`, state `specced`, element `E201`:
  `python3 tools/pack/pack.py errors-as-values/EV12` rewrote the roster cell
  `specced` to `designed`. `python3 tools/pack/pack.py E201 --audti spec` wrote
  `docs/examples/E201-spec.md` and appended an INDEX row, because `spec`
  became the slug of the retired example stage at `tools/pack/pack.py:1725-1755`.
- **Intended and stated?** The flips are intended: `.planning/protocol/workflow.md`
  tabulates one per stage, and `tools/pack/pack.py:834-840` explains why the
  spec flip belongs to the run that writes the SPEC. The statement is partial.
  The usage text at `tools/pack/pack.py:14` says "design bundle + scaffold" and
  omits the flip. `.claude/skills/element-design/SKILL.md:54-55` says the
  command scaffolds and omits the flip. `--no-scaffold`, the one read-only
  design mode, exists at `tools/pack/pack.py:1567` and is documented nowhere.
  The regression of a later state was never intended: `roster_flip` at
  `tools/pack/pack.py:1181-1194` refuses a wrong predecessor for the spec flip,
  and the design flip skips that function.
- **Proper fix.** (1) Refuse an unknown flag and a missing required argument
  before any mode runs. (2) Every roster write goes through one transition table
  (`open` to `designed`, `designed` to `minted`, and on), so no command moves a
  row backwards; REOPEN in `revisit` is the one sanctioned backward move and
  names itself. (3) A read-only bundle for every stage, spelled the same way on
  every mode, with the write as the explicit flag or as a separate `start`
  subcommand. (4) The usage text and the two skills state each write.
- **Size.** About 80 lines in `pack.py` and six lines across two skills. The
  transition table replaces three ad hoc checks rather than adding a fourth.
- **Owner.** No roster row holds `pack.py`'s write safety. The nearest is
  `baseline-alignment/AL3`, the residue the gate repair left; a row opened in
  `baseline-alignment-arc` is the honest home.

### DT-02 Line citations into registers drift, and no check reads them. High

- **Defect.** Check G at `tools/ledger-lint/ledger-lint.py:413-456` resolves
  `.py` and `.chiral` spans only, under `docs/` only. No check resolves a
  `file.md:NN` citation. Every check reads the working tree, so a citation that
  is true only against uncommitted text passes the lint and is committed.
- **Evidence.** `records/author-calls.md:117`, committed at `ad95e20`, cites
  `records/findings.md:1544`. At `HEAD` that file has 1,305 lines. The author's
  uncommitted 239-line `FD-54` hunk sits above `FD-55`, which `HEAD` holds at
  `records/findings.md:1236` and the working tree at `:1475`.
- **Measured at `HEAD`.** 530 line citations point into `records/*.md`: 229
  into `records/author-calls.md` and 92 into `records/findings.md`. 17 of the
  92 point past the file's end. Of the 58 whose line also names exactly one
  `FD-` id, 15 land inside a different row, for instance
  `docs/arcs/parts/crypto-primitives-K1.md:84` cites `:156` beside `FD-13` and
  `:156` is inside `FD-15`.
- **Proper fix.** Registers keyed by id are cited by id: `FD-55`, or
  `records/findings.md` `FD-55` §3. A check resolves every such id and refuses
  a bare `records/<register>.md:NN`. A lint mode reads the index rather than the
  working tree (`--staged`), so a commit is checked as it will land; this is
  how the `pre-commit` framework avoids the same defect (research, R5).
- **Size.** The id resolver is about 60 lines, reusing DT-06's module. The 530
  citations are a mechanical migration, one file per run, serial.
- **Owner.** `baseline-alignment/AL3`.

### DT-03 `prose-lint PATH` runs a smaller check set than the counter. High

- **Defect.** Recorded as `records/lenses/problems.md` PRB-28 on 2026-09-01,
  `owner: none`, still open. The comment at `tools/prose-lint/prose-lint.sh:84`
  says both paths agree; the per-line alternation at `:164` omits
  `parallel-no`, three slop words, `in other words`, `Additionally,` and the
  contracted copulas. `tools/test/matcher.sh:57-66` records the same divergence
  and routes its gate through `--summary` to avoid it.
- **Why high.** Per-file mode is the verification command every stage prompt
  names, this one included.
- **Reproduced.** A five-line scratch file carrying `no state, no clock`,
  `Additionally,`, `In other words` and `myriad`: per-file mode prints
  `prose-lint: clean` and exits 0; `--summary` over the same file reports four
  hits and exits 1.
- **Proper fix.** One table of check patterns, read by the counter and the
  reporter both, with the reporter printing the check name on each line.
- **Size.** About 30 lines of shell and awk.
- **Owner.** None. `text-tools/P1` built the native matcher that
  `prog/prose-lint.prog` runs on, and no row holds the awk tool.

### DT-04 Nine places where a failure reads as clean or as "subject gone". High

The audit asked for pain point 4, run over every check. Two shapes: an error
converted to Vacuous or to silence, and an exit code or output left unparsed.

| where | shape | evidence | reproduced |
|---|---|---|---|
| AD | exit unparsed | `tools/ledger-lint/ledger-lint.py:1793-1795` keeps stdout lines starting `[LN]` and never reads the exit code | lens.py made to crash in the worktree: `lens rc=1`, and `--only AD` printed `[ok]` and `ledger-lint: clean`, exit 0 |
| Z | error to Vacuous | `:1633-1634` raises Vacuous when `git ls-files` fails | `GIT_DIR=/nonexistent`: `[VACUOUS] Z ... subject gone` |
| AI | exit unparsed | `:2208-2214` takes `git log`'s stdout and ignores its code; an empty date skips the row | the same run: `[ok] AI (0 issue(s))` over a register holding 168 |
| S | exit unparsed | `:1088-1090` reads exit 0 of `git check-ignore` as ignored and every other code, 128 included, as tracked-clean | read only, unrun |
| T | silent, subject misread | `:1183` reads `.planning/specs`, which does not exist; the SPEC half checks nothing while the Vacuous text at `:1196` names `docs/elements/specs/` | `ls -d .planning/specs` fails; 126 SPECs sit in `docs/elements/specs/` |
| U | silent | `:1283-1284` skips a quote whose file is missing because "check A owns a missing path", and A reads `docs/definitions/status-ledger.md` alone | read only, unrun |
| any check | crash to exit 1 | `main` at `:2967-2978` catches Vacuous and Owed only; any other exception aborts the run, prints no verdict, and exits 1, the code the header at `:17-23` gives violations | a syntax error put in `pack.py`: traceback, exit 1 |
| `--only` | selects nothing | `:2933-2935` accepts any code; an unknown one selects no check | `--only ZZ`: `ledger-lint: clean`, exit 0 |
| `doc.py audit` §2 | exit unparsed | `tools/doc/doc.py:204-210` runs ledger-lint, ignores its exit, and prints `(lint-clean for this doc)` when no line matches | follows from the crash row |

AL and AM were repaired for exactly this shape at `fe5fd88` and `fa4461a`, and
their handlers at `tools/ledger-lint/ledger-lint.py:2419-2443` and `:2471-2492`
are the pattern the rest should follow. E also reaches little: of 70 shard
headers under `docs/banks/`, 11 carry both a class token and a mapped `E#`, so
59 are skipped by design (`:283-311`, "lenient by design").

- **Proper fix.** The runner catches any exception per check and reports it in
  a fourth category, `errored`, with its own exit code, so a crash can never
  read as a finding count or as clean. Each subprocess caller checks the exit
  code and requires the callee's closing summary line (`lens: N row(s)` at
  `tools/lens/lens.py:684`) before trusting an empty parse. Z and AI report a
  failed git call as a finding. T reads `docs/elements/specs/`, with its INDEX
  limb held to example-tier artifacts, since a design-minted element owns no
  INDEX row. `--only` refuses a code outside `CHECKS`. U reports a missing
  target itself.
- **Size.** About 90 lines across `ledger-lint.py` and `doc.py`.
- **Owner.** `baseline-alignment/AL1`, requirement 1 of that arc word for word.

### DT-05 `doc.py audit` hands the doc-audit run an empty evidence section. High

- **Defect.** `evidence_slices` at `tools/doc/doc.py:130` matches
  `\.(?:py|chirality)`, and nothing in the tree ends in `.chirality`.
  `records/baseline-alignment.md` BA-02 fixed the identical regex in checks G and
  R at `0f72a33` on 2026-09-01 and left this copy.
- **Measured.** Over the 13 banks, 220 `.chiral:NN` citations produce 0 slices.
  Charter check 2, line-evidence truth, reads that section and nothing else.
- **Three more gaps in the same bundle.** The authority section reads
  `records/conformance-map.md` and `docs/examples/INDEX.md` (`:218`); a
  design-minted element has no INDEX row, and neither the roster row nor
  `docs/definitions/status-ledger.md`, which `.planning/protocol/placement.md`
  names the one authority on element status, is shown. The charter's gradient
  at `:30` starts at "scaffold code", a directory cut on 2026-08-31.
  `.claude/skills/doc-audit/SKILL.md:15-19` lists checks A to H of forty, and
  its done-condition at `:56`, "lint clean", is unreachable on a tree that
  carries owed rows by design.
- **Proper fix.** The bundle takes its slices from DT-06's shared resolver, its
  authority from the status ledger and the roster, and its gradient from
  `.planning/protocol/workflow.md` §"The doc tier has its own loop" by pointer.
  The skill's done-condition becomes "no violation names this doc".
- **Size.** About 40 lines in `doc.py`, about 15 lines of skill.
- **Owner.** `baseline-alignment/AL3`. `zero-python/Z8` ports `doc` first, so
  the fix lands before the port or the port inherits the defect.

### DT-06 Five citation walkers disagree, and none refuses an ambiguous basename. Medium

- **Defect.** Citation parsing lives in check G, check R, `--census`,
  `doc.py`'s `evidence_slices`, `pack.py`'s `revisit_mode`, `lens.py check`,
  and the evidence regexes of check AI and `pack.py --revisit`. They differ on
  extensions, on scope and on ambiguity. `revisit_mode` at
  `tools/pack/pack.py:1491-1506` names an ambiguous basename and lists its
  homes. G and R drop it through `_unique_src` at
  `tools/ledger-lint/ledger-lint.py:388-400` and report nothing. `lens.py check`
  at `tools/lens/lens.py:161-163` accepts a path whose basename exists anywhere,
  so a wrong directory passes.
- **Pain point 3, measured.** Two source basenames are ambiguous:
  `mach.chiral` in three homes and `turn.chiral` in two. 45 line citations use
  one bare, 34 of them `mach.chiral`. `docs/arcs/parts/enforcement-N24.md:207`
  is the design that cited `mach.chiral:1005-1013`. No check refuses any of the
  45.
- **Proper fix.** One resolver module, loaded by the others through the
  importlib seam `lens.py` already uses on `ledger-lint.py`, returning a file,
  AMBIGUOUS with its homes, or GONE. A check refuses a line citation through an
  ambiguous basename, on `MAP.md`'s rule that the module key is the
  root-relative path.
- **Size.** About 120 lines for the module, minus the five copies it replaces.
- **Owner.** `baseline-alignment/AL3`.

### DT-07 The author-call register has outgrown one line per call. Medium

- **Measured.** 77 rows. Median 1,081 characters, longest 12,068, 17 over
  2,000. 229 line citations point into it. A reconcile rewrite replaces a whole
  line, so `git diff` shows one line removed and one added with no view of what
  changed inside.
- **AK's regex.** It holds today. `_AUTHOR_CALL` at
  `tools/ledger-lint/ledger-lint.py:2289-2290` matches 77 rows, and the 43rd
  `unreviewed` token cell in the file is the legend table at
  `records/author-calls.md:26`, excluded because it carries no bold name. The
  exclusion is accidental: a data row with a mistyped token, or with its name
  unbolded, drops out of the count silently. Check AN, over the lenses, reports
  exactly that case as a violation.
- **Proper fix.** The register takes the block form the lenses and records
  already use, `### AC-NN <name>` with one field per line, cited by id. AK
  reads fields the way AN does and fails a row whose token is off-set.
- **Author.** `records/author-calls.md` and `.planning/protocol/reconcile.md`
  §"Leaving a call with the author" both state the one-line shape, so the
  change amends two protocol texts. The author confirms the shape before it is
  dispatched.
- **Size.** A converter and an AK rewrite, about 70 lines, and one migration of
  77 rows.
- **Owner.** None.

### DT-08 `--mint` appends rows to the file's end, and the tools read the wrong section from there. Medium

- **Defect.** `tools/pack/pack.py:1313-1323` appends the catalog row and the
  ledger row at the end of each file and prints a request to move them by hand.
- **Measured.** `E198` and `E202` sit at `docs/elements/catalog.md:650-651`,
  under `## OWED`, and at `docs/elements/ledger.md:472-473`, under `§Y ·
  Recorded disagreements and ownerless work`. Because the category and the
  kind are read off the nearest header above a row, `pack.py` derives `RT2` as
  the category of both and `RESOLVED` as the catalog kind of both, and a
  `--spec` bundle opens `# SPEC BUNDLE — RT2·E202` with `**kind**=RESOLVED`.
  Checks J and K read `RT2` from the same walk. `E201` was moved by hand and
  derives `VAL` and `BUILD-PROPER`.
- **Proper fix.** §6 of a design names the ledger category and the catalog
  section. `--mint` inserts each row as the last row of that section's table
  and refuses when the section is absent. Check K reports an element row sitting
  under a header that carries no category.
- **Size.** About 50 lines.
- **Owner.** None; the nearest is `baseline-alignment/AL3`.

### DT-09 `--mint` runs without an audit PASS, and a PASS leaves nothing to check. Medium

- **Defect.** `.planning/protocol/placement.md` says the mint runs off a design
  audit's PASS. `mint_mode` at `tools/pack/pack.py:1249-1303` refuses an
  unfilled template and a closed delta and reads nothing else, and the design
  PASS in `.claude/skills/pipeline-audit/SKILL.md:116-121` writes nothing onto
  the design. The SPEC level has `--mark audited`; the design level has no
  counterpart.
- **Measured.** Of 24 designs whose roster row maps to a parts file, 7 carry an
  element while the design reads `draft` or `blocked`, among them
  `enforcement-N20` (`E198`), `native-window-W5` (`E199`), `display-calculus-R3`
  (`E200`) and `errors-as-values-EV12` (`E201`). Two read `audited`. Whether the
  seven were audited cannot be read from the tree, which is the defect.
- **Proper fix.** A design PASS sets the design's `status: audited` with its
  date, and `--mint` refuses any other status. Elements minted before
  2026-09-05 keep the exemption check AH already gives them.
- **Size.** About 30 lines, plus one line in the skill.
- **Owner.** `baseline-alignment/AL9`, as `.planning/PIPELINE-REPAIR-QUEUE.md`
  item P7, open since 2026-09-09 with its PRB row never written.

### DT-10 Check V compares one column of the arc index. Medium

- **Defect.** V at `tools/ledger-lint/ledger-lint.py:1345-1356` compares the
  README row's goal to the arc's goal and reads nothing else in the row.
  `.claude/skills/arc-open/SKILL.md:141` says "`ledger-lint` check V fails when
  that table and the arc file disagree", which claims more than V checks.
- **Measured at `HEAD`.** Of 39 rows, 34 state a row count and 7 disagree with
  the roster. One is baseline-alignment, whose 44 counts its findings rather
  than its 9 rows. The other six: enforcement says 5 against 24, crypto-primitives 25 against 36,
  display-calculus 17 against 27, presentability 3 against 6, native-window 4
  against 6, native-protocol 9 against 10. The band cell disagrees with the
  arc's `reserved element block` for coding-turn, part-split, text-tools and
  tool-authority, each of which holds a band the README calls `none`.
  `band_of` at `tools/pack/pack.py:977-980` reads `E184-E189` out of
  errors-as-values' field, which begins `none` and names that band as spent.
- **Proper fix.** Say it once. The README keeps the columns only it holds and
  points at the arc file or at `OVERVIEW.md` for counts and states, and V
  compares the band cell it keeps. Where a count is wanted in the README, it is
  a generated region checked for drift (research, R2). `band_of` reads a band
  only from a field that does not open with `none`.
- **Size.** About 20 lines in V and `band_of`, plus one pass over 39 rows.
- **Owner.** `presentability` requirement 3, which holds no roster row and
  carries `records/lenses/gaps.md` GAP-10 instead.

### DT-11 `OVERVIEW.md` is twelve days stale and nothing gates it. Medium

- **Measured.** `python3 tools/lens/lens.py overview --check` exits 1: 358 lines
  on disk, 389 built, 121 differing. Last regenerated `26bf3be`, 2026-09-17.
  On disk it says 67 homes owed; check AE raises 18. `CLAUDE.md` and
  `.planning/protocol/dispatch.md` both route a session to this file to choose
  its arc.
- **Also.** Its "Unscheduled" list at `tools/lens/lens.py:562-563` counts an
  element as scheduled when its number appears anywhere in an arc's text, the
  rule check AE's docstring records as wrong, and by substring, so `E1` is found
  inside `E10`.
- **Proper fix.** A check that runs `overview --check`, as check I does for
  `FRONTIER.md`, and the "Unscheduled" list read through `_homed`, the parser
  `chain()` already imports.
- **Size.** About 25 lines.
- **Owner.** `baseline-alignment/AL9`, as `.planning/PIPELINE-REPAIR-QUEUE.md`
  item P8.

### DT-12 The research stage's own citations are never resolved by a gate. Medium

- **Defect.** Check AL runs `xlat check` over `docs/translations/` alone
  (`tools/ledger-lint/ledger-lint.py:2411-2412`). `records/findings.md` carries
  the pinned quotes every `FD` row rests on, and
  `.claude/skills/research/SKILL.md:86-88` verifies with `xlat unpinned` and AM,
  which ask whether a pin exists and never whether the quote is in it.
- **Measured.** `tools/xlat/xlat.sh check records/findings.md`: 2,846
  citations, 2,818 resolved, 20 NOT FOUND, 7 AMBIGUOUS, 1 MALFORMED. Several NOT
  FOUND spans carry a markdown-escaped backtick, which the grammar reads as two
  characters, for instance `CPYPARSER:706`.
- **Proper fix.** AL covers every document carrying the `ID:LINE "span"`
  grammar, and the grammar decides the escaped backtick the way it already
  decides the escaped double quote.
- **Size.** About 15 lines in AL and 5 in the awk grammar, plus a pass over the
  28 rows.
- **Owner.** `baseline-alignment/AL3`.

### DT-13 Counts in the spine drift, and one check covers two of them. Medium

- **Pain point 9.** Check C reports "CONTENTS claims 27 decision notes; tree
  has 34" (`CONTENTS.md:166`, last set `e7770c0`, 2026-09-05). The recount is
  automatable because C computes it.
- **Past C.** `README.md:272` says 14 goals and 25 arcs; the tree has 16 and
  39. `.planning/protocol/placement.md:90` says `docs/banks/INDEX.md` holds
  twelve; it holds 13. No check reads either.
- **Pain point 8.** `records/lenses/problems.md` PRB-69 records the records-row
  half, 197 of 276 evidence fields with no command, owned by
  `enforcement/N12` for the census. AA covers two literal figures and the
  binary size.
- **Proper fix.** A count that restates a directory listing is removed, per
  say-it-once, or becomes a generated region with its command beside it,
  checked for drift. The tree already has both halves of that pattern: check Q
  recomputes the conformance-map tally, and `lens.py overview --check` compares
  a generated file. A lint that rewrites the tree is refused; the check stays
  read-only and the regeneration is its own command.
- **Size.** A generic region checker is about 60 lines; each count moved into
  it is a line.
- **Owner.** `presentability` requirement 3, GAP-10, which has no roster row.

### DT-14 Check A reports two classes of false positive. Low

- `tools/ledger-lint/ledger-lint.py:132-156` resolves a span verbatim, so
  `lib/ports/process.port:36` in `docs/definitions/status-ledger.md:166` is
  reported missing while `lib/ports/process.port` exists. It also reads the
  arc-local row ids `memory-discipline/M2` and `memory-discipline/M4` on the
  same line as paths. PRB-13 fixed the module-key case on 2026-09-06.
- **Proper fix.** Strip and bounds-check a `:NN` suffix; resolve a
  `<arc>/<id>` span against the rosters, so a row id that names no row is its
  own finding. About 15 lines. Owner `baseline-alignment/AL3`.

### DT-15 Check R cannot tell a definition citation from a site citation. Low

- `docs/arcs/parts/enforcement-N14.md:61` writes `` `lower-defs`,
  `lib/lowering/compile-back.chiral:264` `` in a table cell naming the caller;
  line 264 is the call inside `lower-defs`, and R reports it against the
  definition at 253. `_defines` at `tools/ledger-lint/ledger-lint.py:459-474`
  also counts the `(declare` line, which is why the report reads "defines it at
  252, 253".
- **Proper fix.** A citation grammar that marks a site citation, which DT-06's
  resolver can carry, and `_defines` reporting a declaration apart from a
  definition. Widening R to accept any line inside the defining form would
  pass a drifted definition citation, and is refused.
- About 20 lines. Owner `baseline-alignment/AL3`.

### DT-16 Checks G and R read `docs/` and nothing else. Low

- `doc_tier` at `tools/ledger-lint/ledger-lint.py:180-183` is their corpus. Run
  over the root spine, `.claude/skills/` and `.planning/protocol/`, their walker
  finds 0 today, so the gap is latent. Over `records/` it finds 33 and 56, which
  is check AI's territory by the tier rule, save one R hit in the live register
  `records/author-calls.md:84`.
- **Proper fix.** Add the spine, the skills and the protocol to their corpus.
  About 5 lines. Owner `presentability` requirement 4, whose stated instrument
  is checks A and G and which reaches neither `README.md` nor `MAP.md` today.

### DT-17 The design-to-spec skill promises a section the spec bundle lacks. Low

- `.claude/skills/design-to-spec/SKILL.md:54-58` says the bundle carries the
  element's status-ledger rung. `spec_mode` at `tools/pack/pack.py:790-810`
  prints the catalog row, the design, the conformance-map rows, the outlines and
  the test baseline. `ledger_rungs` already exists for the design bundle.
- **Proper fix.** Add the rung to the spec bundle. About 5 lines. Owner none.

### DT-18 The toolset's self-descriptions are stale. Low

- The `ledger-lint.py` docstring at `:9-15` lists checks A to C.
  `.claude/skills/doc-audit/SKILL.md:15-19` lists A to H. A reader of either
  learns three or eight of forty checks.
- **Proper fix.** A `--checks` listing generated from `CHECKS` and each
  docstring's first line, as `prose-lint --checks` already provides, with the
  skill pointing at it. About 15 lines. Owner none.

## 3. Research: how comparable projects keep docs honest

Proportionate: the technique, what it would catch here, and whether it fits
this tree's forms. Sources are cited and deliberately left unpinned.

| # | technique | what it catches here | fits |
|---|---|---|---|
| R1 | Stable ids with suspect-link fingerprints, as Doorstop does: a link stores the parent's fingerprint when last reviewed, and a changed parent makes the link suspect ([Doorstop, Item](https://doorstop.readthedocs.io/en/v2.1.2/reference/item/), [validation](https://doorstop.readthedocs.io/en/latest/cli/validation.html)) | DT-02 by id, and LIM-22: AI keyed on a hash of the cited span or row would stop staling every row when one line of a file moves | yes. `FD-`, `PRB-` and roster ids exist; `checked:` becomes a fingerprint beside a date |
| R2 | Generated regions checked for drift, as `cog --check` does: "Check that the files would not change if run again" ([cog](https://cog.readthedocs.io/en/latest/running.html)) | DT-10, DT-13, and the arcs README counts | yes. `lens.py overview --check` and check Q are this pattern already; the step is generalising it to a region inside a hand-written doc |
| R3 | Docs executed as tests, as rustdoc runs code examples "to make sure that examples within your documentation are up to date" ([rustdoc](https://doc.rust-lang.org/rustdoc/write-documentation/documentation-tests.html)) | PRB-69: a `re-runnable:` command with its stated result, run and compared | partly. Many commands need a compiler build, so the runner has to name what it skipped, the way the suite names unported phases |
| R4 | Named snippet regions instead of line numbers, as MarkdownSnippets does with `begin-snippet: KEY` in source and `snippet: KEY` in the doc ([MarkdownSnippets](https://github.com/SimonCropp/MarkdownSnippets)) | the line drift G and R chase, for the citations that mean a region | partly. Symbol citations fit R's rule today; a region marker in `.chiral` is a comment convention the source would have to adopt, which is a language-side call |
| R5 | Linting the staged content, as `pre-commit` does: it "only runs on the staged contents of files by temporarily stashing the unstaged changes" ([pre-commit](https://pre-commit.com/)) | pain point 2: the lint passes a citation that holds only in the working tree | yes, as a `--staged` mode reading the index |
| R6 | Fragment checking in a link checker, as `lychee --include-fragments` checks `#anchor` targets in Markdown ([lychee](https://github.com/lycheeverse/lychee)) | a citation by id resolved to a heading anchor | yes, and check F's `[[slug]]` resolver is the natural home |
| R7 | One rule table read by every reporting path, as any linter with a rule registry does | DT-03 and DT-18 | yes, and it needs no dependency |

## 4. Ranked shortlist: what to dispatch first

1. **DT-01, `pack.py` write safety.** Unknown flags refused, one transition
   table, a read-only bundle on every stage. The only finding where a tool
   damages tracked state today.
2. **DT-04, the nine failure-to-clean paths.** An `errored` category, exit
   codes checked, `--only` validated. `baseline-alignment/AL1` states it as its
   requirement.
3. **DT-03, one prose-lint table.** Small, and every stage's verification runs
   through the broken path.
4. **DT-06 with DT-02, one citation resolver, citations into registers by id,
   and a `--staged` lint.** The largest item, and the one that ends pain points
   2 and 3 together.
5. **DT-05, `doc.py`'s bundle.** Two lines fix the regex; the rest rides on
   DT-06. Lands before `zero-python/Z8` ports `doc`.
6. **DT-11, gate `OVERVIEW.md`.** The session-orientation document is wrong
   and nothing says so.
7. **DT-09 and DT-08, the mint.** A PASS that leaves a trace, and rows placed in
   their section.
8. **DT-10 and DT-13, generated counts.** One region checker serves both.
9. **DT-07, the register's shape,** after the author confirms it.
10. **DT-12, AL over `records/findings.md`.**

Counts: 5 high, 8 medium, 5 low, 18 findings.

## 5. Ruled out, and why

| item | why it is out |
|---|---|
| tool and suite speed, including AI's per-file `git log` and AM's budget | the optimization run owns it |
| the rot checks' paragraph-date excuse (W to AA, `:1494-1503`) | declared under-reporting by construction in the tier rule at `:1367-1398`; changing it reopens that rule, and nothing measured here shows it hiding a live defect |
| deleting H and M | `records/lenses/limits.md` LIM-01 holds them `accepted`, and `baseline-alignment-arc` requirement 1 already calls Vacuous an interim; the call is that arc's |
| AM's spaced source names and its PINNED column | `records/lenses/problems.md` PRB-99 part 3, open, owned by `baseline-alignment/AL1`, and blocked on the author's definition of an attributed quotation |
| AI keyed on whole files | LIM-20 and LIM-22 hold it `accepted`; R1 names the technique that would lift it |
| AK's regex failing on long rows | measured: it holds on the 12,068-character row; the defect is readability and the silent skip, DT-07 |
| a `--fix` mode for check C | a lint that writes is refused; the count is regenerated by its own command or removed (DT-13) |
| the G and R citations that fire in `records/` | dated history by the tier rule, and AI's to revisit |
| porting any tool to native | `zero-python/Z8`; DT-05 is the one place its order matters |
| `xlat`'s substring match in `_is_pinned` | a false "pinned" needs a meta naming another source's id; PRB-99 already records the column's gaps |

## 6. What this run could not verify

- Whether the seven minted designs in DT-09 were audited in a session that left
  no trace. The tree cannot say, which is the finding.
- The `git check-ignore` exit-128 path in DT-04 was read and not run.
- Check U's silent skip was read and not run; no instance was searched for.
- The research sources were read through a fetch that summarises. Every quote
  in §3 is short and was checked against the returned text, and none is pinned,
  as the brief directed.
