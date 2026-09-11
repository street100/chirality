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

- state:    OPEN
- claim:    `docs/arcs/enforcement-arc.md:509` gives `N18` a `req` cell of `1, 3`.
- measured: reported by the call 2 research run 2026-09-10. That run reads requirement 3 as "the check agrees with the compiler it checks", which concerns the tal checker against the compiler rather than a bound, and records that whether a judgment able to say a bound serves requirement 3 at all is an arc-internal question the coverage check would have to answer. Not independently re-measured. The requirement text itself has not been re-read against the cell here.
- evidence: `docs/arcs/enforcement-arc.md:509`, and that arc's REQUIREMENTS section
- checked:  2026-09-10
- element:  none

### BR-06 the `str-sub` call-site count is stale in three places

- state:    OPEN
- claim:    `docs/elements/catalog.md:490`, `docs/elements/ledger.md:312` and `docs/arcs/diagnostics-arc.md:102` each give `E176` a call-site count of 131.
- measured: reported by the `diagnostics/L5` design run 2026-09-10 as 135 three-argument `str-sub` calls plus 115 `bslice` calls, 250 through one routine. A crude unfiltered grep here returned 137 and 111, which brackets those figures without confirming them, so the exact numbers are the design's and not re-measured. The structural point is independent of the exact count and is verified: `lib/lowering/tal/erase.chiral:115` maps both `str-sub` and `bslice` to `nb-bslice`, so any count naming one surface name alone understates the population. `docs/arcs/parts/diagnostics-L5.md` §5 question 8 assigns the correction to the SPEC stage.
- evidence: `docs/elements/catalog.md:490`, `docs/elements/ledger.md:312`, `docs/arcs/diagnostics-arc.md:102`, `lib/lowering/tal/erase.chiral:115`
- checked:  2026-09-10
- element:  E176

### BR-07 `decision-lane-split` cites a retired finding as live

- state:    OPEN
- claim:    `docs/decisions/decision-lane-split.md:341` cites `FD-01` in `records/findings.md` as the live record of the `str-sub` defect.
- measured: reported by the `diagnostics/L5` design run and again by the call 3 research run, 2026-09-10. `records/findings.md` records `FD-01` as `state: RETIRED`, moved to `PRB-47` in `records/lenses/problems.md` on 2026-09-05, with `PRB-24` as the second live lens row. Not independently re-measured. Note that [[records/doc-rot]] classes a dead reference inside `docs/decisions/` as context rather than a defect **until it is cited as live**, which this one is, so it falls on the defect side of that test.
- evidence: `docs/decisions/decision-lane-split.md:341`, `records/findings.md` FD-01, `records/lenses/problems.md` PRB-47 and PRB-24
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
- measured: reported by the `diagnostics/L5` design run 2026-09-10, not independently re-measured. That is the inverted-range case, `end < start`, which was repaired on 2026-08-31 by clamping to the empty slice in `nb-bslice-t`, with the fixpoint held and the binary rebuilt byte-identically. A comment in `lib/` is compiler source under [[working-discipline]]'s build rule, so repointing it owes a generation cycle and is not free.
- evidence: `lib/protocol/term.chiral:167-168`, `lib/lowering/tal/bytes.chiral` `nb-bslice-t`, `records/findings.md` FD-01's repaired half
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
