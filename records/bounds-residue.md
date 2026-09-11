---
node: records-bounds-residue
layer: record
related: [records/README, records/enforcement-arc, records/diagnostics-arc-record, records/author-calls, decisions/decision-primitive-with-consumer, arcs/enforcement-arc, arcs/diagnostics-arc, arcs/text-tools-arc, working-discipline, index]
status: current
updated: 2026-09-10
---

# Bounds residue

Opened 2026-09-10. The `str-sub` bounds thread ran five stages in one session:
the language-primitive inventory audit, the `diagnostics/L5` design, the
enforcement RESCOPE, and the PRINCIPLES research on author calls 3, 1 and 2.
Each stage reported defects outside its own write surface and left them, which
is correct per the one-artifact rule and is how residue accumulates unowned.

This is that residue, so the next session resumes from a list rather than from
four returned reports. Prefix `BR`. Row format and the rules for changing,
retiring and re-verifying a row are in [[records/README]].

**Provenance is stated per row.** A row marked `verified here` was re-measured
by the orchestrator against the working tree. A row marked `reported` came back
from a dispatched run and has not been independently re-measured, which
[[records/README]] requires a reader to know before relying on it.

### BR-01 the pairing decision declines a question by citing the wrong relation

- state:    FIXED
- claim:    `docs/decisions/decision-primitive-with-consumer.md:126-128` declines to rule on which arc holds a pair whose halves sit in different arcs, and gives as its reason that "[[arcs/README]] already allows a goal to take work from several arcs and the relation is many to many".
- measured: verified here 2026-09-10. `docs/arcs/README.md:31-33` makes **arc to goal** many to many, in those words. The question is **element to arc**, which `docs/goals/README.md:27` makes exactly one: "An element belongs to exactly one arc." The decline cites a rule about a different axis, so the paragraph's stated support does not hold. The ruling itself, that a gap is scheduled as a pair, is untouched by this. The narrow repair is to repoint the sentence at `docs/goals/README.md:27` and say the question is left open rather than dissolved by a many-to-many rule. FIXED 2026-09-10: the decision moved. Its scope paragraph now cites `docs/goals/README.md:27`, the element-to-arc relation the question is actually about, and says the seat has to be picked and this document does not pick it. The ruling, the author's two verbatim quotes, the three-defect section, the `origin: pair` specification and the frontmatter are untouched. Written to the working tree by a run with no commit authority, so no commit carries it yet.
- evidence: `docs/decisions/decision-primitive-with-consumer.md:126-128` as repaired, `docs/arcs/README.md:31-33`, `docs/goals/README.md:25-29`
- checked:  2026-09-10
- element:  none

### BR-02 the roster contract does not define the `origin` value two rows already carry

- state:    FIXED
- claim:    `docs/arcs/README.md:74` defines `origin` as `new` · `bind` (it exists and needs a surface) · `connect` (two built things need joining).
- measured: verified here 2026-09-10. `docs/decisions/decision-primitive-with-consumer.md` added a fourth value, `pair`, on 2026-09-10, and the contract file was never amended. Two rows already carry it, `enforcement/N18` and `enforcement/N19` (`docs/arcs/enforcement-arc.md:509`, `:510`), and `docs/arcs/parts/diagnostics-L5.md` carries `origin: pair` in its frontmatter. So the coverage check at `docs/arcs/README.md:96-102`, which requires every row's `origin` to be defensible, has no definition for the value under it. Four separate dispatched runs reported this and none had it in write scope. FIXED 2026-09-10: the contract moved. `docs/arcs/README.md:74` now carries `pair` as a fourth `origin` value in the decision's own words, and the coverage check states when a `pair` row is defensible. Both cite [[decisions/decision-primitive-with-consumer]] so the two cannot drift again. The arc table, the enforcement rows and `diagnostics-L5` were not touched. Written to the working tree by a run with no commit authority, so no commit carries it yet.
- evidence: `docs/arcs/README.md:74` and `:100-104` as repaired, `docs/decisions/decision-primitive-with-consumer.md:84-92`, `docs/arcs/enforcement-arc.md:509-510`
- checked:  2026-09-10
- element:  none

### BR-03 `text-tools/L6` is cited by four documents and is in no roster

- state:    OPEN
- claim:    Four places defer the length-indexed `Str` to roster row `text-tools/L6`.
- measured: verified here 2026-09-10. `docs/arcs/text-tools-arc.md:184-187` holds `P1` through `P4` and no `L6`. `docs/decisions/decision-work-ids.md` gives text-tools the letter `P`; `L` is the diagnostics arc's letter. The design that coined the name says in its own disposition cell that the row "does not yet exist and is not opened by this run". So four documents defer to a row that identifies nothing, which is the deferral rule's defect one tier down from an unminted `E#`. Either the row is opened in `docs/arcs/text-tools-arc.md` under that arc's own letter, or the four citations stop naming it. Author call 2 turns on this: the text-tools side of that call rests entirely on this row existing. **Revisit 2026-09-10 against `docs/arcs/text-tools-arc.md`: HOLDS, and that closes the first branch of the disjunction below.** The arc's §5 holds four requirements and none of them covers a length-indexed `Str`. Requirement 1's own gloss fixes *total* as a **cost** bound (*"A primitive whose cost is not bounded in its input cannot be typed here, per `PRINCIPLES.md` §2"*), and the arc's *Why the constraint picks the algorithm* section spends it entirely on backtracking versus one-pass; a range refinement is not that subject. Requirement 3 is the coverage table, and an indexed carrier changes no composition in it: `find-all` returns spans into the buffer it scanned, so `cut` = `find-all` → spans → `str-sub` holds with or without the index. Requirements 2 and 4 are purity and differential verification. The arc's own primitives are `P1` to `P4` plus two enablers it *"depends on but does not own"*; `str-sub`, `bslice` and `bget` are the built prelude floor and are in neither set, which is what `GAP-11` already measured when it found requirement 1 *"served by none of P1 to P4"*. So a row here would name no requirement, and [[arcs/README]] `:98` makes that row **out of scope** by the coverage check's second bullet. Adding it would also take author call 2 by fait accompli, since text-tools is one of that call's three candidate homes and the call is `unreviewed`. **The arc is not the defective party.** It never claimed `L6`; the whole defect is on the citing side, and the repair branch is now determined: the four citation sites stop naming `text-tools/L6` and name what the author's ruling on call 2 leaves standing. The arc's next free id is `P5` (`P1` to `P4` in the roster, no `P5` anywhere under `docs/` or `records/`), and it stays free. **Half done:** the branch is settled and no citation is repaired, which is why this row stays `OPEN`. **Also corrected here:** this row's own evidence named `docs/arcs/enforcement-arc.md:550`, which is a `SkHead` paragraph; the second citation in that file is `:572`. The four sites are three documents, not four. `.planning/BOUNDS-AUTHOR-CALLS.md` carries thirteen further hits and is agent tier.
- evidence: `docs/arcs/text-tools-arc.md:184-187` (roster), `:200-210` (REQUIREMENTS), `:189-198` (Coverage), `:212-233` (why the cost bound picks the algorithm), `docs/arcs/parts/diagnostics-L5.md:523`, `docs/arcs/enforcement-arc.md:509`, `:572`, `records/author-calls.md:363`, `docs/decisions/decision-work-ids.md:85-92`, [[working-discipline]] `:75-83`, [[arcs/README]] `:74`, `:96-104`, [[decisions/decision-primitive-with-consumer]], `records/lenses/gaps.md:145-157` (`GAP-11`), [[banks/text]] `:47`, `:138-139` (shard A routes the defect to `E176` in both places and names no indexed carrier, so no phantom), `records/enforcement-arc.md` EN-31. Re-runnable: `grep -rn 'text-tools/L6' --include=*.md docs/ records/` returns the four sites; `grep -rn 'text-tools/P5' --include=*.md docs/ records/` returns none. Nothing under `lib/`, `prog/` or `tools/` was read or changed by the revisit, and `docs/arcs/text-tools-arc.md` was not edited
- checked:  2026-09-10
- element:  none

### BR-04 the call 2 author-call row carries two claims that do not hold

- state:    OPEN
- claim:    `records/author-calls.md:363` states that if the arc-ownership call goes against enforcement, `enforcement/N18` "moves whole and keeps its id", and frames the enforcement side as serving "requirements 1 and 6".
- measured: reported by the call 2 research run 2026-09-10, not independently re-measured except where noted. `docs/decisions/decision-work-ids.md` protects an id across promotion to an `E#` and not across arc transfer, and the citable name is `<arc>/<id>`, so the arc is inside the id. Fourteen citations across four files, three of them in an append-only record. On the requirements: verified here, `docs/arcs/enforcement-arc.md:509` gives `N18` a `req` cell of `1, 3` and `:512` gives `N21` a `req` of `6`, so no single row serves 1 and 6 and the row's framing does not match the roster.
- evidence: `records/author-calls.md:363`, `docs/arcs/enforcement-arc.md:509`, `:512`, `docs/decisions/decision-work-ids.md`
- checked:  2026-09-10
- element:  none

### BR-05 `enforcement/N18` may serve a requirement that is not about bounds

- state:    FIXED
- claim:    `docs/arcs/enforcement-arc.md:509` gives `N18` a `req` cell of `1, 3`.
- measured: verified here 2026-09-10 by reading the arc's REQUIREMENTS section whole. Requirement 3 is **"The check agrees with the compiler it checks"** (`:122`), and everything stated under it is the tal checker against the compiler's emitted TFns: the 1,481 / 727 / 754 accept-reject split, `tal-ty=?` refusing an erased type-argument list, the `tt-word` scrutinee `ck-term` has no arm for, EN-20's `arm-body` `(none)`, E185's four `$apply` dispatchers, and Phase 22 with G18. `N18` delivers an indexed carrier for `Str` and a bounds arm in `lib/typing/diag.chiral`; it writes nothing in `lib/lowering/tal/check.chiral` and moves no acceptance count, so it does not serve requirement 3. The tal-level bounds subject is already placed elsewhere in the arc's own words: requirement 2's last ⚑ block ends *"buys nothing here. `enforcement/N19` is the row"* (`:120-121`). What `N18` does serve is requirement 1, **"A capability sits at ENFORCED, or its ledger row says why it does not"** (`:42`), which is the cell `N1`, `N4` and `N20` each carry alone, `N20` being the same memory-safety family. FIXED 2026-09-10: **the arc moved.** `:509` now reads `req` `1`, and the Coverage paragraph at `:516-517` drops `N18` from requirement 3's list. Requirement 3 keeps eight rows, `N2`, `N3`, `N5`, `N13`, `N15`, `N16`, `N17` and `N19`, so no requirement is left unserved and `N18` still names one: [[arcs/README]] `:96-104` holds in both directions. Nothing else in the arc was touched. Written to the working tree by a run with no commit authority, so no commit carries it yet. **Residue, outside this run's write surface:** `BR-04` quotes the old `1, 3` cell in its own claim line, and `N18`'s row text still says *"the 250 calls through `nb-bslice`"*, which `BR-06` below re-measures as 242.
- evidence: `docs/arcs/enforcement-arc.md:509` as repaired, `:516-517` (Coverage), `:42-48` (requirement 1), `:122-186` (requirement 3), `:104-121` (requirement 2's ⚑ block naming `N19`), `:510` (`N19`), `:511` (`N20`), [[arcs/README]] `:96-104`
- checked:  2026-09-10
- element:  none

### BR-06 the `str-sub` call-site count is stale in three places

- state:    OPEN
- claim:    `docs/elements/catalog.md:490`, `docs/elements/ledger.md:312` and `docs/arcs/diagnostics-arc.md:102` each give `E176` a call-site count of 131.
- measured: **re-measured here 2026-09-10, with the method stated, and the three numbers deliberately left alone.** Method: a paren-balanced tokeniser over all 303 `.chiral`, `.prog` and `.manifest` files under `lib/` and `prog/`, counting only list forms whose **head token** is `str-sub` or `bslice`, with `;` comments and string literals removed before counting, so neither a mention in prose nor a `declare` or `extern` head is counted. Result: **134** `str-sub` calls and **108** `bslice` calls, **242** through `nb-bslice`. Every one of the 242 is exactly three-argument; there are no partial applications. The method reconciles exactly with the crude grep in both directions: `grep -o '(str-sub'` over the same files returns 137 and `'(bslice'` returns 111, and the differences are three comment lines each, named here so the reconciliation is re-runnable: `lib/prelude/string.chiral:14`, `lib/protocol/render.chiral:576`, `prog/scriba/str-edit.chiral:723` for `str-sub`, and `lib/protocol/term.chiral:168`, `prog/scriba/file-io.chiral:29`, `prog/shilpa/tools-fs.chiral:25` for `bslice`. Outside `lib/` and `prog/` there are **6** further `bslice` calls in `tools/test/samples/` and no `str-sub`, so the tree-wide figure is 134 + 114 = **248**. The design's 135 + 115 = 250 does not reproduce at HEAD and neither does 131; the structural point both rest on does, and is re-verified: `lib/lowering/tal/erase.chiral:115` maps both surface names to `nb-bslice`, so any count naming one alone understates the population. **Not edited, and that is the decision.** `docs/arcs/parts/diagnostics-L5.md` §5 question 8 reads `DEFERRED to the mint/SPEC stage for E176`, and that assignment stands: the same design's mint packet lists the count as **one of three** stale statements in the same two cells, beside the scope (`str-sub` alone, where the routine is `nb-bslice`) and the proposed refined signature (which §2 measured unconstructible over a `Str` with no index), and hands all three to the SPEC stage together. `E176` has no SPEC under `docs/elements/specs/`, so that stage is still ahead and still owns them. Writing `134` into three cells now would repair the least of the three, leave a number whose disagreement with the design's own `135` is unexplained where it sits, and take work already routed. This row therefore stays `OPEN` carrying a second independent measurement for the SPEC stage to use.
- evidence: `docs/elements/catalog.md:490`, `docs/elements/ledger.md:312`, `docs/arcs/diagnostics-arc.md:102`, `lib/lowering/tal/erase.chiral:115`, `docs/arcs/parts/diagnostics-L5.md:527` (question 8), `:592-603` (the three stale statements routed to the SPEC stage), `:118-128` (the design's own census). Re-runnable: the head-token count is `grep -o '(str-sub'` / `'(bslice'` over `lib/` and `prog/` minus the six comment lines named above
- checked:  2026-09-10
- element:  E176

### BR-07 `decision-lane-split` cites a retired finding as live

- state:    FIXED
- claim:    `docs/decisions/decision-lane-split.md:341` cites `FD-01` in `records/findings.md` as the live record of the `str-sub` defect.
- measured: verified here 2026-09-10 against the working tree. `records/findings.md:30` reads `state: RETIRED` and its `measured` line opens *"MOVED to PRB-47 in records/lenses/problems.md (2026-09-05): the lens row carries the live state, this row is the history"*. Both candidate live rows were read before choosing and they are not interchangeable. `PRB-47` is `FD-01` itself moved, `from: FD-01`, same claim, and its measurement is the one the sentence needs: it holds **both** range cases and says which side of the repair boundary each fell on, the inverted half fixed at `nb-bslice-t` under `lib/lowering/` on 2026-08-31 and the `end > len` half untouched. That is exactly the question the paragraph is unable to settle, a guard in `lib/prelude/string.chiral` against a change under `lib/lowering/`. `PRB-24` carries a narrower measurement, the unbounded read alone, explicitly declines the SIGSEGV half as not reproducing, and points back at this same decision for ownership, so it cannot be the decision's support for it; what it does carry that `PRB-47` does not is `owner: E176`. FIXED 2026-09-10: **the decision moved.** `:341` now cites `PRB-47` as holding the measurement, says where it came from and when, and names `PRB-24` as the second live row on the same defect and the one carrying `E176`. The bullet's first three sentences, the extern and lowering line numbers, and the `file-types` bullet beside it are untouched. [[records/doc-rot]] classes a dead reference inside `docs/decisions/` as context rather than a defect **until it is cited as live**; this one was, which is what put it on the defect side, and it no longer is. Written to the working tree by a run with no commit authority, so no commit carries it yet. **Residue, outside this run's write surface:** `docs/arcs/parts/diagnostics-L5.md:151` records this citation as stale, which it no longer is, and `:182` labels its quotation of the bullet `336-341` where the bullet now runs to `:343` (the quoted text itself ends at *"nothing settles it"* and is unchanged).
- evidence: `docs/decisions/decision-lane-split.md:336-343` as repaired, `records/findings.md:28-34` (FD-01, RETIRED), `records/lenses/problems.md` PRB-47 (`from: FD-01`, both range cases) and PRB-24 (`owner: E176`, the unbounded read alone), [[records/doc-rot]]
- checked:  2026-09-10
- element:  none

### BR-08 the five language-primitive forks are documented in one working file and routed nowhere

- state:    OPEN
- claim:    `.planning/LANGUAGE-INVENTORY.md` §12 enumerates five forks where the tree points two ways on a language primitive: `F64`, the `Op` sum's admission test, the indexed record-of-functions, the six reserved CRY slots, and `Clock`/`Timer`.
- measured: verified here 2026-09-10. None of the five has a row in `records/author-calls.md`, a lens row, or a roster row. They sit in one `.planning` working file. `docs/decisions/decision-primitive-with-consumer.md` requires a gap to be written down where it belongs and scheduled as a pair, and these five predate that decision by hours and were never brought under it. The indexed record-of-functions is the sharpest: measured 2026-08-24, it parses and type-checks and does not lower, and it has carried no row anywhere for seventeen days.
- evidence: `.planning/LANGUAGE-INVENTORY.md` §12, `records/author-calls.md`, `docs/decisions/decision-primitive-with-consumer.md`
- checked:  2026-09-10
- element:  none

### BR-09 three working files cite the CRY slots as minted elements

- state:    OPEN
- claim:    `.planning/USER-LAYER-GAP.md:170`, `:171` and `:704` cite `E114`-`E119` and `E116` as minted, `:704` listing them under "Already minted, cite freely".
- measured: reported by the language-inventory audit 2026-09-10. Verified here that the premise holds: `docs/elements/catalog.md` carries no row for any of the six and states in its own words that they are slots rather than elements, with `?` on the track axis. The citations themselves have not been re-read. Same run reported `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md:177` and `:201` using the word `blocked`, which [[working-discipline]] `:112-124` rules is the wrong word for a capability the substrate lacks, and `:200` citing an evicted `scaffold/` path.
- evidence: `.planning/USER-LAYER-GAP.md:170-171`, `:704`, `docs/elements/catalog.md` CRY note, `.planning/SCRIBA-PRIMITIVE-CHECKLIST.md:177`, `:200-201`
- checked:  2026-09-10
- element:  none

### BR-10 `lib/protocol/term.chiral` describes a fault that was repaired

- state:    OPEN
- claim:    `lib/protocol/term.chiral:167-168` describes `bslice c 4 0` as faulting.
- measured: **the comment is verified stale here 2026-09-10, and the repoint is deliberately deferred. Both halves of that are this row's result.** Stale, two ways. From the source: `nb-bslice-t` (`lib/lowering/tal/bytes.chiral:147-160`) tests `j < i` with `(ti-prim 4 (op-lti) 2 1)` and, on the true arm, returns `(ti-bnew 5 3)` over the constant `0`, which is the empty slice. `bslice c 4 0` on a 4-byte cell is `end < start`, so it takes that arm. From the running binary: a probe compiled and run out of tree against `bin/chirality-bin`, `(blen (bslice (pack-u32 0) 4 0))` as `compile-main`'s return, **exits 0**, and a control differing only in its indices, `(blen (bslice (pack-u32 0) 1 4))`, **exits 3**, which is what shows the 0 is a measured length and not a swallowed failure. No fault, and the comment at `:168` says there is one. **Deferred, not fixed.** [[working-discipline]] makes a comment-only edit to `lib/` or `prog/` a change to compiler source that owes the full `build-new` → test → promote generation cycle, and gives its own standing precedent: `lib/typing/diag.chiral:32` still names `LAYOUT.md` six days after that file became `MAP.md`, the repoint being correct and deliberately deferred rather than taken for free. This is the same shape and takes the same answer. Nothing under `lib/` was edited by this run. **What a later session should do:** fold the repoint into the next generation cycle that opens `lib/protocol/term.chiral` for another reason, so the comment costs no cycle of its own. The replacement text is determined and narrow: the end-boundary case the sentence describes clamps to the empty slice since 2026-08-31, and the reason `pack-u32 0` is used in `nb-ptunlock-w` rather than `(bput-u32-le (cell-new 4) 0 0)` is now a preference and not a fault avoidance.
- evidence: `lib/protocol/term.chiral:164-170` (the stale comment, `:168`), `lib/lowering/tal/bytes.chiral:147-160` (`nb-bslice-t`, the `op-lti` test and the `ti-bnew` empty-slice arm), `records/lenses/problems.md` PRB-47 (the repaired half, fixpoint at 1,102,200 B), [[working-discipline]] (the build rule and the `lib/typing/diag.chiral:32` precedent), `lib/typing/diag.chiral:32`
- checked:  2026-09-10
- element:  none

## Resume state

Nothing fixed. Opened 2026-09-10 from four dispatched runs' out-of-scope
reports plus two measurements taken here.

**Order.** `BR-01` and `BR-02` are one unit: both are the pairing decision's own
integrity, one in the decision and one in the contract it amended, and neither
is defensible while the other stands. `BR-03` and `BR-04` gate author call 2,
because that call's text-tools side rests on a row that does not exist and its
enforcement side is described against the wrong requirements. `BR-06`, `BR-07`,
`BR-09` and `BR-10` are citation rot and carry no decision. `BR-05` is
arc-internal. `BR-08` is the largest and is not rot: it is five forks that were
measured and never scheduled.

**What is not owed here.** No row in this file changes a ruling. `BR-01`'s
repair leaves the pairing decision's ruling intact and corrects the support its
scope section claims. The clamp-versus-trap question and author calls 1 through
5 stay with the author.
