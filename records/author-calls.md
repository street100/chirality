---
node: records-author-calls
layer: record
related: [records/README, records/consolidation-handoff, arcs/README, elements/README, decisions/decision-erased-word-level, index]
status: current
updated: 2026-09-10
---

# Open author calls

Decisions only the author can make, that in-scope work is waiting on. Hoisted
from the root handoff on 2026-09-01; it was the one part of that file with no
tracked home.

This is not a findings list. A finding is a claim beside a measurement and lives
in [[records/baseline-alignment]] or [[records/findings]]. A row here is a fork
where the tree does not settle the answer and a pass must stop.

## The state of a row

Every row in the table below carries one token from a closed set of three. The
token is the row's first cell.

| token | means |
|---|---|
| `unreviewed` | the fork stands. The author has not decided it |
| `ruled` | the author gave a decision, and the row cites the author's words or an explicit author directive |
| `dissolved` | a measurement removed the fork, and the row cites the measurement |

`unreviewed` is the default. A wrong `unreviewed` costs the author one
re-confirmation; a wrong `ruled` corrupts the record, which
[[records/lenses/README]] names the worst defect this format admits.

**The shape, so a script and a reader agree.** One row is one line. The first
cell is the token alone, in backticks. The second cell opens with the call's
name in bold, and everything after the name is history. A reader takes the
name; `ledger-lint` check AK takes the token and the name with this pattern,
and fails while any row reads `unreviewed`:

    ^\| *`(unreviewed|ruled|dissolved)` *\| *\*\*(.+?)\*\*

⚑ **Restored 2026-09-07.** Four commits on 2026-09-06 (`74b341e`, `15e5aa0`,
`23cd212`, `3e19dba`) marked every one of the eighteen rows closed. Ten of them
were closed by routing the work to a roster row, and routing says where work
will happen while leaving the fork untouched. The sharpest instance is the `N1`
post-quantum row, whose own body ends by naming the call and which was struck
through anyway. Every closure note is kept in its row as history, and the token
says what the row is.

| state | the call | why it is blocking |
|---|---|---|
| `unreviewed` | **The target ratio [[goals/emitted-speed]] condition 1 is held to** · Opened 2026-09-08 by that goal. | The condition says the shipping compiler carries a cost figure against a control outside the tree, and the goal records the number as owed rather than picking one. [[benchmarks/language-performance]]'s 1.4x on compute and 5 to 8x on memory and branch work was measured 2026-08-02 against the Python-hosted backend that the zero-python migration evicted, so it is a record and sets no bar. [[implementation/optimizer-inventory]] establishes that eviction. No other figure in the tree sets one, and [[benchmarks/crypto-kernel-allocation]] measured 13.1 MB/s against a static 35 ops per byte with no `gcc -O2` run ever made, so the distance to optimized scalar C on allocation-heavy code stands unmeasured. [[arcs/emitted-speed-arc]] took the condition because its observable is a document existing, which is producible while the target stands open. A pass can build the instrument and cannot say whether it passed |
| `unreviewed` | **The budget [[goals/emitted-speed]] condition 4 holds a shipped native tool to** · Opened 2026-09-08 by that goal, and it is why [[arcs/emitted-speed-arc]] left the condition unopened. | The condition's observable is a gate row that fails when the tool exceeds its budget, and no budget exists, so the gate cannot fail. `docs/decisions/decision-scope.md` names that shape as a gate aimed at a guess, which passes by looking at nothing. The author's 2026-09-01 ruling at `docs/benchmarks/README.md:29` makes the wall clock a recorded number that sets no bar, which is the ruling this call asks to extend or decline. Measured and unheld today: `prose-lint` runs 15.1x slower than mawk and took 1.11 GB to scan 609,872 B, OOM-killed at default scope. `crypto-primitives/K13` owes the same declaration on the crypto side, so one ruling could serve both |
| `unreviewed` | **Principle 1 has no Honest limit** · ⚑ **Routed 2026-09-06 to `presentability/D4`, and routing is not a ruling.** The row named where the work would happen and left the fork standing, so it is back at `unreviewed`. | The broadest claim in the file, the only one without one |
| `unreviewed` | **P5's present tense** · ⚑ **Routed 2026-09-06 to `presentability/D5`, and routing is not a ruling.** The row named where the work would happen and left the fork standing, so it is back at `unreviewed`. | "a split value whose only exit is a guarded combine-process": CONFORMANCE-MAP calls it vapor beyond the seed |
| `unreviewed` | **P3 vs open-edges** · ⚑ **Routed 2026-09-06 to `presentability/D6`, and routing is not a ruling.** The row named where the work would happen and left the fork standing, so it is back at `unreviewed`. | P3's limit says the membrane's inward reach is open; `open-edges` records it largely answered |
| `dissolved` | **`decision-split-checker`** · **A measurement removed this fork, 2026-09-06.** `docs/decisions/decision-split-checker.md` reads `status: settled` and has read it since 2026-07-21, so the row's premise of a `draft` disagreeing with PRINCIPLES was false when it was written. `5d68c4e` cleaned this class of row and missed this one. Nothing disagrees with PRINCIPLES. | `status: draft`, while PRINCIPLES states its content settled |
| `ruled` | **what a `docs/elements/` file holds** · **Ruled 2026-09-06 by author directive: close forking.** The directive is recorded at `docs/elements/README.md`, `The shape fork is CLOSED, 2026-09-06, by author directive: close forking`. `catalog.md` and `ledger.md` stay as they are. `pack.py` reads them and `ledger-lint` check AE gates them against each other. ⚑ **The citation is thin and the author may want to re-confirm it.** It was written by the same commit that closed this row, `3e19dba`, and no other record of the directive exists. The same file still carries its 2026-09-01 line calling the shape question open, which is stale text left behind by that edit. | one file per element, one per band, or a tracked index. `docs/elements/README.md` states the fork |
| `ruled` | **Python: outside the tree, or inside it** · **Ruled 2026-09-06 by the author: outside. There is no Python in the language.** The author's words are recorded verbatim in the note fields of `records/lenses/gaps.md` GAP-14 through GAP-17: "no fucking python in the language". The section below carries the ruling and [[arcs/tuning-arc]] is unblocked. | [[goals/self-tooling]] and [[goals/local-ai]] point opposite ways, and the call decides whether they conflict at all. The two readings are below |
| `ruled` | **A reserved element block for the nine arcs that have none** · **Ruled 2026-09-06 by the author: let overlap exist.** `docs/decisions/decision-lane-split.md`, under `Bands may overlap, and they are advisory`, carries the ruling, and commit `f533365` records it arriving in session over the session's own proposal of fifteen disjoint blocks. A band is advisory and an arc without one mints the next number free tree-wide, which `pack.py --mint` implements. | Transport, tuning, text-tools, independent-judgment, bridge and module-split write `UNASSIGNED` and stop, 16 rows in total. The three native-stack arcs, opened 2026-09-03, add 13 arc-local rows mapping to `unminted`. `docs/decisions/decision-lane-split.md` reserves `E184-E189` and `E190-E195` and nothing else. ⚑ **Widened 2026-09-04.** [[arcs/display-calculus-arc]], opened that day, adds 17 more arc-local rows mapping to `unminted`, so the standing call now covers ten arcs. ⚑ **Widened again 2026-09-05.** [[arcs/vocabulary-arc]] and [[arcs/canvas-arc]], opened that day under [[goals/own-web]], add 28 more, so it covers twelve |
| `dissolved` | **When the native-stack track opens** · **A measurement removed this fork, 2026-09-06: it had already opened on 2026-09-03.** `docs/arcs/native-protocol-arc.md` records the author opening it in session that day, `N1` slices 1 and 2 are built and gated by `tools/test/crypto.sh` at suite phase 31, and `docs/decisions/decision-scope.md` is amended to say so. ⚑ **Residue, and it is scheduling rather than a fork.** The window arc and four of the five display conditions stay unopened. | [[decisions/decision-scope]] holds the current track to self-hosting only. The author stated [[goals/native-stack]] and its internal order on 2026-09-03, then opened [[arcs/native-protocol-arc]] the same day, in session, with a next-day target on the kernels. The window and document arcs sit unopened. ⚑ **Sharpened 2026-09-04.** The document arc's subject was restated that day as [[goals/display]], whose first condition [[arcs/display-calculus-arc]] carries, so what stays unopened under this row is the window arc plus four of the five display conditions. Whether the document arc survives at all is the merge row below |
| `ruled` | **`E184-E189` is one band and two focuses draw on it** · **Ruled 2026-09-06 by the author: let overlap exist.** The same ruling as the row above, and `f533365` names this case: the band is spent, and that blocks nothing because both arcs mint the next free number tree-wide. | [[arcs/enforcement-arc]] and [[arcs/diagnostics-arc]] both mint from it, `E184` is spent, and four numbers remain. Concurrent minting is the collision that produced two `E173`s. The work split is in `docs/decisions/decision-lane-split.md` |
| `ruled` | **Which suite phase number a new gate takes** · **Ruled 2026-09-06 by the author: native tests and harnesses.** The ruling is recorded at `tools/test/run-tests.sh`, `RULED 2026-09-06 by the author: native tests and harnesses, and this file is the only authority for a phase number`, and quoted in the note fields of `records/lenses/gaps.md` GAP-02 and GAP-03. A gate takes the first number colliding with nothing, the rule phase 24 already applied. Seven registered at 25 through 31. | Four documents disagree and a session cannot pick without overwriting one of them. `tools/test/run-tests.sh:332` and `docs/decisions/decision-lane-split.md:30` reserve **21 through 23 for Lane B**; `tools/test/tal-check.sh:5` **claims 22** and leaves 21 to `crypto.sh`; `tools/test/crypto.sh:8` says **21 through 23 are free** and is itself unregistered; `docs/definitions/testing-floors.md:69` asserts the `crypto.sh` precedent **holds 21**. 8 through 12 stay owed to unported old-tree phases and must not be reused. Raised by E185's SPEC run, whose gate runs by hand until this is settled ([[records/enforcement-arc]], and the SPEC's decision 5). ⚑ **An eighth `PEND` joined the queue 2026-09-04.** E186's gate, `tools/test/capture-fields.sh`, takes the same `crypto.sh` / `tal-check.sh` / `apply-word.sh` route — a `not-a-phase:` declaration with a reason, which keeps `tools/test/registration.sh` G2 and G4 green — and opens no new call. `registration.sh` now reads **8 of 21** scripts outside the dispatch table. Of the eight, four wait on this number: `crypto.sh:6`, `tal-check.sh:11`, `apply-word.sh:5` and `capture-fields.sh:6`; the other four declare out for structural reasons. The paragraph below reads `display-calculus/C1C2`'s gate as the fourth on the count of the day it was written; E186's landed first, so C1C2's is the **fifth** when it exists |
| `unreviewed` | **Which arc owns the allocation gap** · ⚑ **Routed 2026-09-06 to [[arcs/memory-discipline-arc]], and routing is not a ruling.** An arc was opened to hold the work, which answers where the work goes and leaves the fork this row states standing. Back at `unreviewed`. | ~1,747 B of arena per input byte, no reclamation on any compiled path, and a projected ~6.3 GB at the default scope against 3.85 GB with no swap. It blocks manas and scriba from running once transport lands and no arc holds it |
| `dissolved` | **The `$kI_J` capture constructor's field types** · **A measurement removed this fork, 2026-09-04: the answer is `concrete`.** `docs/decisions/decision-erased-word-level.md` carries it under `The $kI_J capture constructor's field types`, [[records/enforcement-arc]] EN-21 is the measurement, and `tools/test/capture-fields.sh` gates it at `9 ok, 0 FAIL` over four rows and five mutants, registered as suite phase 26. No compiler source moved, because the tree already spelled it that way. ⚑ **The ruling is E186's and not the author's**, which is why this reads `dissolved`. The row itself says an implementation run records an outcome and does not make the call, so the author may still want to see it. | The 2026-09-04 ruling below settles where the `$apply` dispatcher's erased domains live and does not reach the capture constructor. `.planning/RESEARCH-EN15-prior-art.md` §7 shows both published shapes keeping constructor fields CONCRETE, and the structural reason: a capture constructor is applied at one site, so nothing forces its fields to merge, while the dispatcher's argument position is constrained by the whole family. That makes the constructor the concrete side and the dispatcher the varying side, the opposite arrangement to the measured `$apply7`, which reddens through `ck-con`'s field check. Whether the two instances are one defect or two is the call ([[records/enforcement-arc]] EN-17). ⚑ **Narrowed and given an element 2026-09-04.** The call is now **E186**, minted by E185's SPEC run. E185 states the dispatcher's parameter types at the lowering type level as the erased word, and `tal-ty=?` (`lib/lowering/tal/check.chiral:68-70`) has the erased word matching everything, so the four `$apply` dispatchers accept with the constructor's fields left concrete. The call therefore stops blocking a live `ck-prog` refusal on the dispatcher side and stays open on its own question: whether the capture constructor's fields should erase too. ⚑ **Ruled 2026-09-04 by E186.** The ruling is **`concrete`**: the capture constructor's field types stay at the capture's own source type, and the erased word is reached only where that source type has no ground spelling. It is written in [[decisions/decision-erased-word-level]], measured as [[records/enforcement-arc]] EN-21, and gated by `tools/test/capture-fields.sh` at `9 ok, 0 FAIL` over four rows and five mutants. No compiler source moved, because the tree already spelled it that way. **No work in the tree waits on this row any longer**, so closing it is the author's edit whenever the author wants it; an implementation run records an outcome and does not make the call |
| `unreviewed` | **Whether [[arcs/native-document-arc]] merges into [[goals/display]]** · ⚑ **Closed 2026-09-06 by extending the element-band overlap ruling by analogy, and an analogy is not a ruling.** The author's words settle whether two arcs may be handed the same element band. They say nothing about whether a tracked arc merges into a goal. Back at `unreviewed`. The 2026-09-06 answer, kept as the standing proposal: overlap is fine as long as the arc is unique, so the arc keeps its four rows and they may overlap other arcs'. | Its rows V1 to V4 are absorbed by [[arcs/display-calculus-arc]]'s row groups: V1 by `display-calculus/E1`, V2 by `display-calculus/C1` and `C2`, V3 by `display-calculus/C8` and `C9`. V4, the render seam into the window, is the only row with no counterpart, and it sits behind the unopened pixel condition. The arc either closes into the display goal or keeps V4 alone, and a session cannot pick without deleting one of two tracked arcs |
| `unreviewed` | **Which consumer witnesses the every-state walk (C9/H6)** · ⚑ **Picked 2026-09-06 by a session because this row called `prog/scriba/` the obvious candidate, and a session agreeing with the row is not a ruling.** Marked on `display-calculus/C9`. Back at `unreviewed`. | [[arcs/display-calculus-arc]]'s pre-run measured the cell lane's `(Env, State)` product at 1: the two witnesses declare no `Env` and no `State`, so C9's walk over this instance would prove only that the phase runs. A meaningful instance needs an interactive consumer, and the arc names none. `prog/scriba/` is the obvious candidate, on the evidence that the registry already carries a `manas-cursor` face for a navigable cursor row. Choosing it is the call this row records |
| `unreviewed` | **Whether `native-protocol/N10` closes into [[arcs/crypto-primitives-arc]]** · Opened 2026-09-07 by that arc's boundary section. | `N10` reads "the post-quantum re-scope: `.planning/CRYPTO-MODEL.md`'s twelve decisions applied to the kernel set", which is the whole subject of the arc opened 2026-09-07 on [[goals/own-web]] condition 4. The new arc takes the layers `.planning/CRYPTO-MODEL.md` §2 marks `unscoped` and leaves the wire rows where they are, so `N10` either closes into it or narrows to the two built pre-quantum slices. A session cannot pick without deleting a tracked row in one arc or the other |
| `unreviewed` | **Whether [[arcs/native-protocol-arc]]'s `N1` is re-scoped post-quantum** · ⚑ **Closed 2026-09-06 by MARKING the built slices pre-quantum and routing the re-scope to `native-protocol/N10`, and neither is a ruling.** The row's own body ends `What happens to the two built slices is the call`, and that call is `C1` in `.planning/CRYPTO-MODEL.md` section 13, which is open today. This is the clearest case of the 2026-09-06 defect: the row was marked closed while its own text said the decision was unmade. Back at `unreviewed`. | Measured 2026-09-05: zero mentions of post-quantum across that arc, `docs/examples/N01-crypto-kernels.md`, its SPEC and `.planning/NATIVE-PROTOCOL-CHECKLIST.md`. `N01` states its own reference class as WireGuard's suite, which is pre-quantum, and **slices 1 and 2 are built and gated against it** while slices 3 and 4 are specced against it. [[goals/own-web]] condition 4 states the post-quantum target and `.planning/CRYPTO-MODEL.md` holds the re-scope with twelve decisions. What happens to the two built slices is the call |
| `unreviewed` | **Which arc owns the fd-passing crossing** · ⚑ **Routed 2026-09-06 to [[arcs/native-window-arc]] `W5`, and routing is not a ruling.** Back at `unreviewed`. | `lib/lowering/tal/crossing-wraps.chiral` carries 44 lowered crossings and `sock-send-fd` is absent from them, so `prog/demo/wl-client.chiral:201` does not lower and **nothing in this tree reaches a screen**. `sock-listen`, `sock-accept` and `bind` are missing too, and it went unnoticed because no gate reads `prog/demo/`, so the demos are described as running. It sits under [[arcs/native-window-arc]] entire and under [[arcs/canvas-arc]]'s `G8`, and it is E29's unowned server half |
| `unreviewed` | **Which arc owns `display-calculus/R3`** · ⚑ **Closed 2026-09-06 on the ground that the id already said, and that is not a ruling.** The row's own body already read that [[arcs/display-calculus-arc]] rosters it and no arc is working it, so the closure restated the row. Back at `unreviewed`. | The span primitive, the measured wall. The pure `Bytes` surface is twelve externs with no `pack-u8`, no builder and no fill-with-function, so varying content has no linear-time path. It gates six raster rows, one text row and all of composite, and nothing draws beyond sprites until it lands. [[arcs/display-calculus-arc]] rosters it and no arc is working it |
| `unreviewed` | **Whether [[arcs/native-document-arc]] closes into [[goals/own-web]]** · ⚑ **Closed 2026-09-06 with the row above, by the same analogy to the element-band overlap ruling.** Back at `unreviewed`. The 2026-09-06 answer, kept as the standing proposal: nothing is deleted and no arc absorbs another. | The existing merge row above offers two answers and this is a third: `V1` and `V2` are [[arcs/vocabulary-arc]], `V3` is [[arcs/canvas-arc]]'s `G4` and `G5`, and `V4`'s render seam is `G2` and `G8`, so the arc closes with **no row left over**. A session cannot pick without deleting a tracked arc |
| `unreviewed` | **Whether `decision-preserve-check`'s tier line moves off `ttype`** · Opened 2026-09-09 by `docs/arcs/parts/enforcement-N14.md` §5 decision 1. | `docs/decisions/decision-preserve-check.md` is `status: settled` and reads "`ttype`'s `Maybe` is P5's tier boundary written into the code", with T1 covering "the region where `ttype` answers `none`". Measured 2026-09-09 in that design's §2: `ttype` (`lib/lowering/upper/lower.chiral:35`) has **zero call sites** anywhere under `lib/`, `prog/` or `tools/`, and the live type translation `term->ntalty` (`lib/lowering/compile-front.chiral:58-79`) answered `(none)` on **zero of 22,742 globals** across 63 roots. T1's region as the decision draws it is therefore empty, and `enforcement/N13` would be built against it. The decision's substance survives either way, because EN-20's `const 0` case sits inside the `(some t)` region and T1 still convicts it, which is a different job from the one the decision assigns. A session may not rewrite a settled decision and redrawing T1's region changes what `N13` builds against |
| `unreviewed` | **E184's six unruled spelling decisions** · ⚑ **MEASURED 2026-09-10, and four of the six are settled by the tree's own text rather than by the author.** **Decision 7, whether `ft-erased` keeps its arm: SETTLED, it keeps it.** R1 already states it: `The erased-by-design arm is required rather than optional: a type-level def is not a failed lowering, and without that arm every ratio built on the fates is noise.` An empty extension is the point, since the ratio needs the arm to be honest. **Decision 4, how an emitted label reaches its definition: one of its three options is eliminated.** The `$` string convention is structure carried in a string, which R2 forbids in the same words it uses for reasons, `E157's rule applies unchanged, and a str-cat'd sentence here reintroduces what E157 removed`, and [[records/findings]] FD-23 measured Rust's v0 mangling motivated by exactly this defect. What remains, a threaded pair list against a sixth `TFn` field, is a code-shape measurement. **Decision 6, whether `sl-case-nondata` carries the refused type: its premise is measured and it is not free.** Only `ntalty->talty` exists (`lib/lowering/compile-back.chiral:24`, `(-> NTalTy TalTy)`); the reverse direction is absent tree-wide, so carrying the type means building a function that does not exist. **Decision 3, result sums against a second walk: R3 already rules the pattern** for `peel-def`, so extending it to `term->ntalty` and its two siblings applies a rule the element carries rather than making a new call. ⚑ **Two stand, and only one is a fork of principle.** Decision 5, whether `skr-erase` carries evidence: `XF`'s reason is a `Str` (`lib/lowering/tal/erase.chiral:30`) which R2 condemns, and retyping it is reachable, so the live question is whether a class measured at zero members carries evidence at all, which R1's decision-7 language does not reach. ⚑ **DECISION 5 RULED 2026-09-10 by the author: YES, `skr-erase` carries evidence.** `XF`'s reason is retyped from `Str` into a sum, which is what R2 demands in its own words and what E157 removed elsewhere. ⚑ **The cost is six sums rather than one, measured 2026-09-10.** `lib/lowering/tal/erase.chiral:26-31` declares `XI`, `XC`, `XBR`, `XD`, `XF` and `XFS`, and every one carries `(reason Str)`. `XF` is the one this decision names because it is the one `filter-erasable` reads, and the five siblings are the same defect in the same file, so a SPEC that retypes `XF` alone leaves five `Str` reasons beside it. Whether the retyping takes all six in one change is a SPEC-stage sizing question rather than a fork. ⚑ **The arm's extension is zero today** and the ruling is made knowing that: `filter-erasable`'s silent arm (`lib/lowering/compile-back.chiral:189`) fires zero times on `prog/compiler.prog`, which is the same shape as decision 7, where R1 states that an arm carrying no members is required rather than optional so the ratios built on the fates stay honest. ⚑ **DECISION 2 RESEARCHED 2026-09-10 as [[records/findings]] FD-24, twenty pins, and the fork it was stated as is dissolved into a relocation.** **Zero of six surveyed refusal reports mirror a constructor set**: GHC carries 321 AST constructors against 251 message constructors, Go 53 against 145, rustc's const-eval 7 arms over all of MIR, Cranelift 6, CompCert 3. The practice classifies by refusal SITE rather than by grammar. **And a mirror survives only where the correspondence is mechanically enforced.** LLVM generates it, `Instruction.def`'s 69 `HANDLE_*_INST` rows against `LLVMOpcode`'s 69 enumerators with both directions including the table, so growth is a compile error at the mapping function and at neither declaration. Rust, Java and Go each give up the compile error at a boundary, through `#[non_exhaustive]`, `visitUnknown` and `ast.Walk`'s panicking default. GHC hand-maintains `HsSyn` against `TH.Syntax`, its authors record that it drifts, and their answer was to stop mirroring. ⚑ **So sixteen arms is refused AT `SkHead`'s DECLARATION SITE and not at the producers.** `lib/lowering/skip-diag.chiral:8` imports `prelude/prelude` alone and no shared table exists, so no instrument can check the mirror there. `lib/lowering/compile-front.chiral:18` imports `surface/parse` and therefore sees `Term`, and `lib/typing/kernel.chiral:1319` enforces exhaustiveness, so the burden is checkable at the two peel sites that today end in `(_ (none))` (`compile-front.chiral:72`, `:134`). **The live question is whether the exhaustiveness burden moves to the producers**, which is the same relocation decision 3 already puts to the author under another name, so the two should be ruled together. ⚑ **One reading in this row was wrong and is corrected here.** PRB-81 was offered as restatement drift, an argument for the three-arm shape. FD-24 measured it as the opposite: under-classification, one constructor serving four causes, 182 of 187 misattributed, which argues FOR more arms. Nothing measured in this tree is a mirrored sum drifting. The pricing is therefore lopsided from a different evidence class on each side, sixteen having no published occupant and three having the tree's own measurement against it. ⚑ **DECISION 3 RESEARCHED 2026-09-10 as [[records/findings]] FD-25, twelve pins, and it carries the ORDERING for the two.** **Decisions 2 and 3 are not one ruling.** Ruling 3 collapses or restores 2, and ruling 2 first settles nothing about 3: under full producer retyping with the `_` arms removed, `lib/typing/kernel.chiral:1319` forces one arm per unnamed head and 2 follows; under the one-bit shape `SkHead` never reaches the producer and 2 stands unchanged with no instrument. **Rule 3 first.** ⚑ **The two placements are the ends of a three-position spectrum.** The pure second walk has exactly one surveyed occupant and its two walks are published as disagreeing: CPython's PEG parser, where `print(something) $ 3` has the first walk refuse at `$` while the classifier matches the print and reports elsewhere, with the repair shipped at `Parser/pegen_errors.c:398-402`. The same system shows the silent-gap failure at 70 `invalid_` rules against 209 grammar rules. So against decision 3's second option the evidence is lopsided: one occupant, published drift, a shipped repair, nothing on the other side. The middle position, where the producer leaves a value the classifier only reads, holds the other two systems, and between it and full retyping the evidence is balanced in different currencies. ⚑ **The blast radius is measured and was unrecorded: 27 call sites, all 27 inside `lib/lowering/compile-front.chiral`.** Nothing outside that file calls any of the six functions. Eleven are self-recursion, **12 distinct enclosing functions** would read the new shape, and the refusal originates at 3 sites, propagates at 19 and is absorbed at 3 sinks that each drop a whole entity and continue. ⚑ **And E157's rule does not already cover this, which a session read wrongly.** Its enforcement clause (`lib/typing/diag.chiral:12-18`) reads `adding a judgment is then a compile error in this file's renderer`, a WITHIN-MODULE check that is silent about a producer in another module. That clause is what decision 3 is being asked to extend, rather than something already settled that decision 3 merely applies. **Decision 2, `SkHead`'s width, is the real one**: sixteen arms mirroring `Term` against three covering every measured refusal, and it sets two of the tree's own rules against each other. `lib/typing/diag.chiral:324` is the live precedent for mirroring, `NO _ arm, on purpose: a new Reason constructor must break every renderer`, while `.planning/protocol/tone.md`'s say-it-once rule is the argument against a second copy of `Term`'s shape in the lower image. · Raised 2026-09-09 by `docs/examples/E184-def-fate-sum.md` §6, decisions 2 through 7, and tracked here 2026-09-10 because they lived only in that artifact where `ledger-lint` check AK could not see them. In order: `SkHead`'s width, sixteen arms mirroring `Term` against three covering every measured refusal; whether `term->ntalty` and its two siblings are retyped as result sums or the head is re-derived on the refusal path; how an emitted label reaches its definition; whether `skr-erase` carries evidence, which needs `XF`'s reason retyped at `lib/lowering/tal/erase.chiral:30`; whether `sl-case-nondata` carries the refused type, which needs the missing `TalTy` to `NTalTy` direction; and whether `ft-erased` keeps an arm whose extension is empty for a structural reason. ⚑ **Several may not be the author's.** Decision 1 read as an author call until three research runs measured it, and decisions 5 and 6 turn on whether a retyping is reachable, which is a measurement rather than a fork. The unmeasured ones should be researched or measured before they are put to the author. | E184's SPEC stage meets all six, and the domain ruling lifted the only bar in front of them |
| `unreviewed` | **Whether a created definition and its origin take one arm or two** · Raised 2026-09-10 by `records/enforcement-arc.md` EN-30, which narrowed it without closing it. Two halves. First, whether `specialize-singletons`' and `outline`'s creations take one arm or two: [[records/findings]] FD-23 measured five principle-holders and **none folds a created entity's account into its origin's**, while FD-22 measured GCC using one construct for both of its creators, MLIR discriminating on the arity of the origin set, and DWARF giving three mechanisms three constructs. Both of this tree's creators have exactly one origin, so arity does not separate them and only mechanism does. Second, whether a definition that survives the pass and is ALSO the origin of a created one takes one arm or two: the domain ruling states `ft-specialized` as the exit of a departure and `alloc-growing` does not depart, which narrows it to a reading the author has not made. | E184's R1 arm list and R7's fold both depend on it |
| `ruled` | **The domain of E184's fate function, and whether a deleted definition keeps a fate** · Raised 2026-09-09 as `docs/examples/E184-def-fate-sum.md` §6 decision 1, priced by [[records/findings]] FD-21, FD-22 and FD-23 across 34 pins. **RULED 2026-09-10 by the author: the domain is the pre-pass set plus what the pass created, and deletion is never a fate.** A definition that leaves the globals list leaves through `ft-specialized` naming its successors, and there is no other exit; option (iii), where `x64` has no fate once the pass deleted it, is refused as the ungoverned departure `PRINCIPLES.md` §1 forbids. Option (i) was already dead, with no occupant in six systems. The ruling costs nothing to make because every deletion in this tree is already a specialization consequence: `process-mk` (`lib/lowering/upper/specialize-singleton.chiral:202`) prunes the singleton global plus its projections and `prune-live` (`:227`) drops only what nothing references. A new specialization is a new INSTANCE in `ft-specialized`'s list rather than a new arm, which is what lets R1 stay closed with no `_` arm as passes are added. ⚑ The author names E33's `Reap` as the same shape, so whether `ft-specialized` is a record or a linear obligation is a spelling the SPEC stage owes. | E184's R1, R6 and R7 all state a domain and cannot be specced until one is chosen |
| `ruled` | **Whether the 84-line unreached partition in `lower.chiral` is retired or repaired** · Opened 2026-09-09 by `docs/arcs/parts/enforcement-N14.md` §5 decision 2. **RULED 2026-09-09 by the author: NEITHER. Fix the partitioning properly, and if the proper partition is not the original one, outline it and document it.** The author's words: *fix the partitioning the proper way obviously. if its not the original partition and we're going to do it differently outline it and doc*. So the design's Shape A (repair the dead code as `docs/elements/catalog.md:449` instructs) and Shape E (retire it) are both refused, and the deliverable is the partition the tree should actually have. ⚑ **The live tree already partitions, in three places and under other names**, which is what makes this a design rather than a deletion: `term->ntalty` (`lib/lowering/compile-front.chiral:58`) decides what has a tal type, `le-skip`/`SkRec` (`lib/lowering/compile-back.chiral:270-271`) records 182 term-level refusals in three classes, and `filter-erasable` and the `prune-pass` cascade drop 5 and 160 more, 347 of 22,742 in total. The dead 84 lines are one abandoned attempt at the same job. ⚑ The outline and its documentation are owed before any code moves. ⚑ **DISCHARGED 2026-09-09 by [[records/enforcement-arc]] EN-28.** The outline is [[decisions/decision-def-partition]], placed there by `.planning/protocol/placement.md`'s line for a settled fork. It measures the proper partition as **E184's R1**, a total fate function over the closure's def set that is already minted and unbuilt, so **no element is minted for the partition**; the classes are enumerated from the live tree, the home is `lib/lowering/skip-diag.chiral` beside the `SkReason`/`SkRec` it completes, and the fifteen dead names go out inside E184's build cycle rather than on their own. The row stays `ruled` and this is where the ruling landed. | `UT`, `LowBind`, `Lowdef`, `LowRes`, `ttype`, `ttype-list`, `any-dep?`, `any-eff?`, `any-quant?`, `doms-lower?`, `types-lower?`, `skip-reason`, `eligible?`, `lower-def` and `lower-all` (`lib/lowering/upper/lower.chiral:22-105`, 84 lines of 420) have **zero consumers** anywhere in the tree, measured 2026-09-09 by grep. The tree points both ways. `docs/elements/catalog.md:449` instructs mirroring the porttype legs into `ttype`'s `u-prim` arm as part of E123, which never landed, and `docs/decisions/decision-preserve-check.md` and `records/lenses/gaps.md` GAP-22 are both written over the function, so two settled documents want it kept. `lib/lowering/upper/lower.chiral:1-16` gives the differential against `lower.py.lower_all` as the reason for keeping it, and that oracle is CUT. Either answer costs a BUILD RULE cycle on a module inside the compiler's blob and neither changes an emitted byte |
| `unreviewed` | **Whether `prog/climb.manifest` is a conformance target or is deleted** · Opened 2026-09-10 by `file-types/K1`'s design run, and raised before it by [[arcs/file-types-arc]]'s resume state. | 79 lines. It passes the `def`-body test requirement 1 states, and it also carries three `data` declarations and an `import`, so it is the file that forces the admitted-form set to be explicit. It carries no `(module …)` datasheet, so a check keyed inside the datasheet refuses it. Nothing across `bin/ lib/ prog/ tools/` imports or references it. The check cannot be designed against a file whose standing is undecided: as a conformance target it widens the admitted set, and deleted it narrows it to `lib/lowering/tal/target-linux.manifest` alone |
| `unreviewed` | **Whether a `.manifest` may import computation** · Opened 2026-09-10 by `file-types/K1`'s design run, which widened it. | [[arcs/file-types-arc]]'s resume state raised this against `prog/climb.manifest`. The design run measured that it bites both files on disk: `lib/lowering/tal/target-linux.manifest:9` imports `lowering/tal/sys-check`, which is computation, and the def's `SysReg` type comes from it. So a ruling on `climb.manifest` alone settles nothing, and the conforming file is implicated too. Blocks the admitted top-level form set, one of the five deltas `file-types/K1` names as missing |
| `unreviewed` | **Whether `GAP-04` and `GAP-05` take roster rows of their own** · Opened 2026-09-10, already flagged by [[arcs/file-types-arc]] §Coverage. | Requirements 3 and 4 of the file-types arc, codecs derived rather than hand-written and a round-trip gate with a named mutant that is actually run, are served by no row. Both are properties `K1`, `K2` and `K3` must each carry rather than deliverables of their own. As properties, each kind's design owes them and the arc's coverage claim stands; as rows, the roster grows by two and requirement 4 becomes observable on its own |
| `unreviewed` | **Whether the wiring view is a view of chirality terms or a second language** · Opened 2026-09-02 in `.planning/MANIFEST-DESIGN-MAP.md` §Amended, carried into the tracked tier 2026-09-10 by `file-types/K1`'s design run. | WIT and CAmkES are pure wiring because their implementation language is a different language. This tree's premise is one language, with a manifest as a view of it. Either the wiring view is genuinely a view of chirality terms and owes the round trip, or it is a second language and the one-language claim weakens. The prior art took the second option and does not carry this constraint, so it cannot be borrowed from |
| `unreviewed` | **Whether Lane B may write the fence into `parse`, `kernel` and `loader`** · Opened 2026-09-10 by `file-types/K1`'s design run. It has no prior statement to quote. | `file-types/K1`'s shape A takes a second commit that writes `lib/surface/parse.chiral`, `lib/typing/kernel.chiral` and `lib/module/loader.chiral`. [[decisions/decision-lane-split]] lists none of the three among Lane B's writable files, and none among the files neither lane writes, so the seam is unstated rather than refused. All three sit inside `prog/compiler.prog`'s closure via `lib/lowering/compile-front.chiral:18`, so that commit also promotes `bin/chirality-bin` under the two obligations that decision names. The fork: Lane B takes the grant, the fence moves to Lane A, or the fence becomes its own element |

## Closed since the hoist

- **The `$apply` dispatcher's erased domains.** **ANSWERED 2026-09-04.** The
  erased-word type lives strictly at the lowering type level. `Core` gains no
  word spelling and the kernel's `conv` relation is not widened. The reasons are
  in [[decisions/decision-erased-word-level]] and the measurement is
  [[records/enforcement-arc]] EN-15. The strongest reason stands alone:
  conversion is an equivalence relation, so it is transitive, and a `Word` that
  converts with `I64` and with `(List Str)` makes `I64` convert with
  `(List Str)`, which collapses the source type system. GHC keeps `Any` a closed
  family with no equations for exactly this, and Java keeps `Object` in a
  directional relation. Behind it: `.planning/RESEARCH-EN15-prior-art.md` §6
  surveys seven systems and none admits such a type into a source conversion or
  equality relation; `closconv-sig` runs after the typecheck, so the kernel would
  never use the widened relation; `tt-word` already carries the relation at
  exactly one level; and the one argument for the kernel, re-checking
  post-closconv output, asks one instrument to work at two levels, which
  `docs/banks/verification.md` refuses, so it is an argument for unblocking
  `ck-prog`, which is the ruling. ⚑ **Two things stay open and both are named.**
  The SPELLING of the erased position is **E185**: a quantified type variable
  against a coarse word type of the lower language. The `$kI_J` capture
  constructor's field types are a separate call and hold a row in the table
  above.

- **The `ck-prog` repair shape.** **ANSWERED 2026-09-03.** Both defects are
  repaired in the checker, and neither is a loosening: each makes `ck-prog` match
  the semantics `lib/lowering/tal/ssa.chiral:17-20` already states. That header
  defines `tt-word` as the uniform erased one-word type, representation-compatible
  with any one-word type and *checked by `tal-ty=?`*, so `ck-term` carrying no
  `tt-word` arm contradicts its own IR spec. The argument list goes the same way
  for a different reason: `targs` distinguish nothing a machine can observe, the
  parameter position erases to `tt-word` so `ck-con`'s field check cannot recover
  the distinction either, and `ck-con:123-125` and `ck-term:196` already resolve a
  data type by name alone. Carrying `targs` into the IR would enforce a
  distinction the IR erases everywhere else. It would also close nothing on its
  own: `expr-con`'s unread `exty` covers checking positions and never inference
  positions, so the wildcard is owed either way. ⚑ **Conditional on a mutant.**
  A relaxation shipped on its argument alone is the gate that cannot fail, which
  `docs/decisions/decision-scope.md` names as the failure mode. The evidence it is
  sound is that the repaired check still refuses 6 of 1,481, every one a genuine
  lowering defect, and the gate has to pin that. The six get their own row.

- **`LANES.md`'s home** — it sat at root and was orthogonal to the goal-arc-element
  tiers. Moved 2026-09-01 to `docs/decisions/decision-lane-split.md`: it settles a
  division of work and reserves element bands, which is a decision, and 16 tracked
  files cite it for those bands.
- **The binary split's goal** — the arc laddered up to nothing written down. The
  author wrote [[goals/presentability]] on 2026-09-01 and assigned it there.
- **Whether E182 still earns its keep, shrunken.** **ANSWERED YES 2026-09-02.**
  The element is built as specced. ⚑ The question as raised was framed badly and
  the framing is what made it look like a call: it asked whether the work pays
  for a *tenth* `Reason` arm, which reads as growth. The element is **net
  arm-negative**: `Reason` goes 9 to 10 while `Judg` goes 38 to 36, so one more
  data constructor leaves than arrives, and two dead render arms leave with
  them. With that counted, three things already settled it: the shape is forced
  by the measurement rather than chosen, both live sites hold both counts at the
  moment they refuse, and `docs/decisions/decision-lane-split.md:198` already
  puts the error-quality rows in Lane A's definition of done.

## Added by the consolidation

- **A reserved element block for [[arcs/text-tools-arc]]**, or a ruling that it
  mints into an existing one. Its P2 score, P3 edit script and P4 stable address
  are unnumbered and cannot be scheduled. `docs/decisions/decision-lane-split.md`
  reserves `E184-E189` and `E190-E195` and nothing else.
- **`.planning/METIS-PORT-SPEC.md`** is cited 5x as the contract for E133-E136 and
  is present nowhere in the tree. Whether those four built manas elements are
  re-grounded on a surviving document or recorded as ungrounded is a call.
- **The shape of a tracked element row** — one file per element, one per band, or
  a single index. `docs/elements/README.md` states the fork; the catalog and
  ledger were moved without reshaping so the question stays open.

## Added by the E173 SPEC audit, and closed

Both were raised by the SPEC-level audit at `4f233d4` and ruled on 2026-09-01.
The rulings are applied in `docs/elements/specs/E173-total-matcher-SPEC.md`.

- **E173 decision 4's leftmost-longest, which does not fall out of `norm`.** §4
  step 3 grounds the semantics in *"New threads are appended, so starts run
  non-decreasing along the live list"*, and `norm` returns the list sorted by
  `pat`. `Pat` carries no start, so from step 2 onward the order is `pat`-order
  and the `from` values in it are arbitrary. `list-sort` is stable and
  `list-dedup-adj` keeps the first of a run (`lib/prelude/list.chiral:113-145`,
  `:156`), so the survivor of a `pat`-run is whichever thread was earliest in the
  pre-sort list, which is the previous step's `pat`-order. Counterexample, under a
  `pat-cmp` that follows the `data Pat` declaration order (`p-alt` before
  `p-star`): pattern `a*|aa*` over `"aa"`. After byte 0 the live set is
  `[(0, a*), (1, a*|aa*)]` and `norm` returns `[(1, alt), (0, star)]`; after byte
  1 both derive to `a*`, the derived list is `[(1, a*), (0, a*)]`, and the dedup
  keeps `from = 1`. The thread anchored at 0 is dropped and the longest match at 0
  can no longer be found. Three shapes, and the SPEC settles none of them: (a)
  `norm` sorts with a `(pat, from)` comparator and dedups with the `pat`-only one,
  which the two primitives already allow since each takes its comparator
  separately, and which makes mutant M5 wrong as written; (b) leftmost-longest
  moves to slice 2 with the priority-ordered residual list decision 4 says it
  needs, and slice 1 ships an unordered set for the counting consumer that is
  indifferent to it; (c) something else.
  **Ruled 2026-09-01: shape (a).** `norm` sorts with a `(pat, from)` comparator
  and dedups with the `pat`-only one. The two primitives already allow it,
  because each takes its comparator separately
  (`lib/prelude/list.chiral:143`, `:184-186`), so no new primitive is owed.
  Sorting on `(pat, from)` puts the least start adjacent-first inside each
  `pat` run and the `pat`-only dedup keeps it. Leftmost-longest stays in
  slice 1. Applied in SPEC §4 step 3: two declared comparators, the old
  append-order rationale replaced by the sort key, and mutant M5 rewritten to
  neuter the sort key's `from` half.
  ⚑ The counterexample above is over-strong as spelled. `pd-cat` builds
  `(p-cat p-nil r)` without collapsing the `p-nil`
  (`docs/examples/E173-total-matcher.md:358-360`), so the residual of `a*` is a
  `p-cat` node, which sorts ahead of the freshly spawned `p-alt` and leaves
  that input's start order intact under the old `norm` too. What the row
  establishes is the class: a `pat`-only sort makes the survivor a function of
  the pre-sort order, and the pre-sort order is `norm`'s own previous output.
  Shape (a) removes the dependence, so the ruling rests on the property and
  not on that input. The SPEC's G6(a) asserts the property directly.
- **E173 gate row G9's wall-clock threshold.** G9 gates on a chirality-to-awk
  ratio `<= 1.0` and nothing has measured that number. §4 step 3 states the arrow
  as `O(n x ‖pat‖² log ‖pat‖)`, a merge sort over the live set at every input
  byte, against awk's compiled DFA with no per-byte allocation. Removing the 31
  passes is a large win and landing at or under 1.0 is a bet. Is `<= 1.0` the bar
  slice 1 must clear to land, or is the gate the pass count with the wall clock
  recorded rather than gated?
  **Ruled 2026-09-01: record, do not gate.** G9 keeps its correctness half,
  now the corpus differential against the awk tool, and the wall clock becomes
  a measurement written down with its host and its date under
  `docs/benchmarks/`. Gating on a number nothing has measured would block a
  correct implementation for a reason unrelated to correctness, and the ratio
  can be tightened later from a real number. Applied in SPEC §5: G9 rewritten,
  a recorded-not-gated bullet naming
  `docs/benchmarks/text-matcher-prose-lint.md`, and the cost of the ruling
  written down in §6 residue, which is that the n-pass driver shape now ships
  with no gate row that can convict it.

## Added by the local-ai goal, 2026-09-01

### Python: outside the tree, or inside it

`docs/goals/self-tooling.md` states done as no `.py` file anywhere under
`/workspace/chirality`, with `tools/` deleted. `docs/goals/local-ai.md`
criterion 4 carries the author's phrase *"wrap to use python for (fine tuning,
creating, full growing and changing set of interactions) transformer types"*.
Two readings survive that sentence and they permit different things.

| reading | what it permits | what it costs |
|---|---|---|
| Python as a spawned external process, its scripts living outside this repo | The whole of criterion 4, through E33's typed spawn, with [[goals/self-tooling]] intact and its file count still headed to zero. ollama and llama.cpp get wrapped by the same mechanism, so the author's "for now" clause needs one seam and not three | The training scripts live in a second repository. This tree cannot gate them and cannot claim them, so a capability the goal names is verified nowhere here |
| `.py` files inside the tree, under a carve-out | The scripts are tracked, testable and versioned beside the chirality that calls them | [[goals/self-tooling]]'s done condition becomes false as written and has to be reworded, which `docs/goals/README.md` makes a decision before it is an edit. `tools/` cannot be deleted |

**RULED 2026-09-06 by the author: reading one. There is no Python in the
language.** Python is a spawned external process, its scripts outside this repo,
reached through a typed port under a linear reap obligation. There is no
carve-out and `docs/goals/self-tooling.md` needs no rewording: no `.py` under
`/workspace/chirality` stays literally true, and `tools/` is still deleted.

The two goals were never in conflict; only the unmade call made them look it.
[[goals/local-ai]] criterion 4 becomes port work, and the same seam serves
ollama, llama.cpp and a training process, which is the author's "for now" clause
needing one seam rather than three.

⚑ This row stood open since the 2026-09-01 hoist and blocked
[[arcs/tuning-arc]] entire, which carried zero rows for five days because either
answer changed its first one. It is closed.

The mechanism the first reading rests on is built: E33 `proc-spawn` returns one
`SpawnRes` with a linear `Reap` obligation (`lib/runtime/proc.chiral`), and
`raw-proc-spawn` maps to `nb-run-cmd` at
`lib/lowering/tal/crossing-wraps.chiral:54`.

### A reserved element block for the local-ai goal

The transport arc (give `http-request`, `backend-open` and `chat-open` a runtime
referent) and the tuning arc (criterion 4) have no block, so every row in them
writes `UNASSIGNED`. This is the same block that stops
[[arcs/text-tools-arc]]'s P2, P3 and P4 rows, and that arc already carries its
own row above. One ruling can cover both.

**Widened 2026-09-02.** The same ruling now blocks three more arcs, so it is one
call over six rather than two:

| arc | rows waiting | opened |
|---|---|---|
| [[arcs/transport-arc]] | `T1` to `T4` | before |
| [[arcs/tuning-arc]] | criterion 4 | before |
| [[arcs/text-tools-arc]] | `P2`, `P3`, `P4` | before |
| [[arcs/independent-judgment-arc]] | `J1` to `J5` | 2026-09-01 |
| [[arcs/bridge-arc]] | `C1`, `C2`, `C3`, `C5`. `C4` holds `E40`/`E56`, minted 2026-07-21 | 2026-09-02 |
| [[arcs/module-split-arc]] | `S1` to `S4` | 2026-09-02 |

Sixteen rows across six arcs carry arc-local ids and map to `unminted`. Every
one of them names measured work: `bridge/C2` has `cat-fenced`'s two missing
arms, `module-split/S1` has `conv`'s signature, `independent-judgment/J5` has
`SpecRule.statement` being a `Str`. The naming is done and the numbering is what
is missing, which is [[decisions/decision-work-ids]]' own diagnosis one year of
arcs later.

The scriba half of this goal is exempt and needs no ruling: `S#` is namespaced
by its own letter per `docs/elements/ledger.md`, `S18` already has a SPEC at
`docs/elements/specs/S18-scriba-record-SPEC.md`, and
`.planning/SCRIBA-PRIMITIVE-CHECKLIST.md` numbers `S18` through `S30`.

`.planning/LOCAL-AI-ARC-REALIGNMENT.md` is the proposal both calls block.

## Added by the work split, 2026-09-02

Both rows are in the table above and the detail is here.
`docs/decisions/decision-lane-split.md` carries the measured file ownership the
split rests on.

### The no-Python focus cannot mint

[[arcs/zero-python-arc]] and [[arcs/text-tools-arc]] serve
[[goals/self-tooling]], hold no reserved band, and are both frozen.
`text-tools`' row under the consolidation heading states half of this; the
`zero-python` half has never had a row. Two routes are open and the tree settles
neither.

| route | what it gives | what it costs |
|---|---|---|
| a reserved band each | catalog rows, ledger rows and a pipeline stage per piece of work, which is what `E#` buys | two more bands out of a numbering space that has produced one collision already, spent on two arcs that are frozen |
| the arc-local scheme the other five arcs took | it works today at no cost. `baseline-alignment` uses `BA-`, `binary-split` `B`, `presentability` `D`, `independent-judgment` `J`, `transport` `T`, and [[decisions/decision-work-ids]] settles the form | an arc-local id claims identification and nothing else. `text-tools`' P2 score, P3 edit script and P4 stable address stay `unminted` and cannot be scheduled as catalog work |

`text-tools` already spells `P1` to `P4` and `zero-python` already spells `T1`
and up, so the second route is in the tree for both. What the ruling decides is
whether either arc gets a band on top of that.

### `E184-E189` is shared and `E184` is spent

Two of the four focuses draw on one band of five.
[[arcs/enforcement-arc]] minted `E184` on 2026-09-01;
[[arcs/diagnostics-arc]] has five open rows against the same band. Neither can
mint while the other is minting, because the two tracked collision detectors,
`docs/examples/INDEX.md` and the arc file, catch a collision after it happened.

| route | what it gives |
|---|---|
| split the four remaining numbers | both arcs mint concurrently. Whichever arc runs out first stops on a fresh call |
| give one focus its own band | the band is whole for one arc and the other waits, which is the state today with the wait unstated |

Nothing else in the split sequences these two: their measured write sets share
no file.

### Which arc owns the allocation gap

The measurement is [[benchmarks/text-matcher-allocation]], taken 2026-09-02 on
the tree at `c23947e`. The runtime is a bump allocator with no reclamation on any
path a compiled program takes, so peak RSS equals total bytes ever allocated.
`lib/memory/` holds six modules and four have zero importers, `mem-region`
included, which is the only reclamation discipline in the tree. `9f46c6c` cut
peak 58.0% and the itemised default-scope projection is still ~6.3 GB against
this box's 3.85 GB with no swap.

[[arcs/transport-arc]] delivers the model call. This gap decides whether the run
survives it, and the seven arcs cover none of it.

| route | why it is arguable |
|---|---|
| [[arcs/enforcement-arc]] holds it | a proven bound the machine ignores is an enforcement failure, which is the arc's own subject |
| its own arc | the work is a runtime discipline over `lib/memory/` and the x64 emitter, and touches none of enforcement's five rows |

### Whether E182 still earns its keep, shrunken: ANSWERED YES

Raised by the E182 EXAMPLE audit on 2026-09-02, carried as SPEC decision 12,
answered by the author the same day. Kept because the framing is the lesson.

As asked:

> Does `r-arity` carrying `(what Subject) (expected I64) (actual I64)` still pay
> for a tenth `Reason` arm and the eight renderer arms that arm costs, when it
> repoints two call sites?

⚑ **The framing hid the deciding fact.** Counting only the arm being added makes
the element read as growth. Counted whole it shrinks the tree's constructors:

| | before | after |
|---|---|---|
| `Reason` arms | 9 | 10 |
| `Judg` arms | 38 | 36 |
| `dg-judg-msg` render arms | 38 | 36 |
| `unreviewed` | **A sixth done-condition for [[goals/enforcement]], memory safety** · Opened 2026-09-10 by the enforcement arc's RESCOPE, `records/enforcement-arc.md` EN-31. | The goal's five conditions are about ledger rows, the tal floor, checker agreement, gate mutants and native tooling, and none observes whether a program can read outside a buffer. The goal's own State section names bounds among the five things the vocabulary cannot say, and `docs/definitions/bug-classes.md`'s "buffer overread and overwrite" row reads `none` with a blank element cell. Against: condition 1 is the general form and bounds is one class among 28, a condition per class turns a five-condition goal into a checklist, and `bug-classes.md` is `status: draft` and says a class with no element is expected. Authoring an ambition is the author's, so the revisit wrote no condition and four rows sit under a goal that may not claim their subject |
| `unreviewed` | **Which arc owns the bounds class** · Opened 2026-09-10 by the same revisit. | Enforcement: the missing artifacts are a judgment and a gate, requirements 1 and 6's subjects. Diagnostics: `E176` and `diagnostics/L5` already own the routine, and splitting one defect across two arcs is the collision `arc-open` exists to catch. Text-tools: [[banks/text]] shard A owns the slice territory and `text-tools/L6`, the length-indexed `Str`, is already owed there. [[decisions/decision-primitive-with-consumer]] explicitly does not rule on a pair whose halves sit in different arcs. `enforcement/N18` is written on the judgment-and-gate reading; if the call goes the other way the row moves whole and keeps its id |
| `unreviewed` | **Is a clamp an enforcement outcome, or does it discharge the class by hiding it** · Opened 2026-09-10 by the same revisit, and it is the sharpest of the five. | `docs/arcs/parts/diagnostics-L5.md` §4 Shape A's own Forbids reads "an out-of-range call can no longer be detected. Silent truncation replaces silent over-read." For the clamp: it closes the memory-safety hole, and §2 measured the refinement route unconstructible over a `Str` with no index, so demanding a judgment blocks the repair behind a language element nobody has scheduled. Against: a clamp is a total runtime function that answers rather than a rule that refuses, so the capability lands at IMPLEMENTED and never at ENFORCED, and `bug-classes.md`'s row moves from `none` to something the language still cannot say. The goal's State section calls that "a bug the language happens to catch today." The call decides what state that row may read after `E176` builds, and `E176` is the next thing to build |
| `unreviewed` | **Does the typed-assembly floor owe a bounds obligation** · Opened 2026-09-10 by the same revisit. | Whole claim: [[decisions/decision-preserve-check]] fixes the floor as two rungs, T0 type preservation and T1 value agreement, and bounds is a third property belonging to a memory-safety rung nobody has drawn. Owes it: `lib/lowering/tal/ssa.chiral:24-25` claims the artifact carries what the checker needs to re-verify independently, PRB-75 and `enforcement/N17` already measure three constructors short of that closure, and an index with no bound is the same argument in a second direction. FD-17 put `checkcast` and `ref.cast` at this exact position. `enforcement/N19` carries both branches in its `what` cell because the call is unmade |
| `unreviewed` | **Does [[goals/enforcement]] condition 4 quantify over gate rows or over bug classes** · Opened 2026-09-10 by the same revisit. | Rows: it is inherited verbatim as the arc's requirement 6 and is a quality check on the gates that exist, checkable against [[records/gate-audit]]. Classes: as written it is satisfied by a suite reading `412 passed, 0 failed` over a primitive that segfaults, because a class with no row cannot fail a row-quality check. Every `str-sub` and `bslice` call under `tools/test/` is in range and `pretty.sh:35` G11b asserts `str-sub` is not called, so the gate tier's whole contact with the primitive is safe by accident. Widening a goal condition is the author's; `enforcement/N21` is scoped to the mechanical half either way |
| `ruled` | **Whether the orphan program reaches the `OT` track** · Opened 2026-09-10 by the homing review in [[records/pipeline-orphans]]. **Ruled 2026-09-10 by the author: all thirteen get homed.** The author's words: the deferral "is just an implementation work defer. says literally nothing about planning". So homing is planning and the scope statement does not reach it. The instruction that comes with the ruling: each row records what is actually wanted when the track begins, and what stays deferred, naming the real blocking condition rather than the track. The author's worked example is E63, deferred because no CHERI hardware is available, which `docs/elements/catalog.md` already carries as "docs-only, hardware-dependent; out of the CPU/RAM-only sandbox". `docs/arcs/ownership-and-trust-arc.md:45-48` says the other seventeen "stay deferred with the track" and is now wrong. | 13 of the 32 unhomed `design` orphans are Track `OT`: E43, E44, E46, E54, E55, E58, E59, E60, E61, E62, E63, E73 and E74. [[decisions/decision-scope]] defers the ownership-and-trust track, and `docs/elements/ledger.md:36-38` bars `OT` work from current work and exempts its documents from audit. Homing an element is scheduling it, so doing this to the 13 does the thing the scope statement exists to prevent. Against that, `docs/goals/README.md:27` says every element belongs to exactly one arc, and all 13 carry an `unreviewed` row in [[records/lenses/unspoken]] awaiting exactly this. Either the 13 stay unhomed until the track undefers and the lens rows are the correct resting place, or homing is separated from scheduling and they take rows in an arc nobody works. The homing queue is 16 or 29 depending on the answer |
| `unreviewed` | **The six `?` UNSORTED tracks** · Raised 2026-08-31 by `docs/elements/catalog.md` §UNSORTED, and tracked here 2026-09-10 because they lived only in that section, where `ledger-lint` check AK could not see them. | E52 kernel-core certificate split, E71 golden-semantics restructure, E77 rung-1 seccomp default-deny, E78 number-in-type attenuation, E166 the C-emitting `Mach` (answered 2026-09-01: parked, code deleted) and E167 `tal-c`. The section states that every one of these needs one word from the author, and that a row wrongly marked **SH** pulls deferred work into current work, which is the thing the scope statement exists to prevent. Three of them, E77, E78 and E167, are unhomed `design` orphans, so the track answer gates their homing: an `OT` element is deferred and an `SH` one is queued |
| net data constructors | 47 | 46 |

The eight `case`s over `Reason` each gain an arm, at `:145`, `:193`, `:209`,
`:223`, `:259`, `:273`, `:317` and `:519`, and most return the subject or a
nullary constructor. `diag.chiral:315-316` says a new `Reason` constructor must
break every renderer loudly, so that cost is one the tree chose.

Three things settled it. The shape is forced by the measurement rather than
chosen: both live sites hold both counts at the point of refusal and build a
nullary judgment carrying neither, which is what E157's own taxonomy line
forbids. `docs/decisions/decision-lane-split.md:198` already puts "the
error-quality rows (E182, E176, E179) are closed" in Lane A's definition of
done, so the element was in scope before the flag existed. And both audits
independently reached the same answer on the bundle alone.

⚑ **A sequencing note the flag did not ask and the author raised.** `E176` is on
this arc, unbuilt, and is sharper than E182 on consequence: `str-sub` is
unclamped, segfaults, has 131 call sites, and its safety was asserted in a
comment that `str-starts-with` was then built on. E182 buys two error messages
that gain their numbers. Both are in Lane A's definition of done. On sharpness
alone E176 goes first, and that is a sequencing question rather than a scope
one, so it decides nothing here.

## Added by the display goal, 2026-09-04

[[goals/display]] was stated in session that day. Three directives came with it
and all three are settled, so none of them holds a row in the table above. They
are recorded here because each one constrains work a later pass will do, and
because a directive kept only in a session transcript is lost.

| ruling | what it settles |
|---|---|
| **Scope.** The immediate roadmap excludes non-chirality | Rendering HTML, CSS, JS or HTTPS from a foreign server is out. Focus stays on local primitives until the crypto and enforcement arcs finish. It sorts the 59-row roster in `.planning/DISPLAY-LAYER-GAP.md`: the cell-lane rows are reachable now, lanes R and Z wait on the two clocks, and foreign documents leave the roadmap entirely |
| **Lanes.** Cell, raster, layered and 3D are separate lanes | A property vocabulary for one does not generalize to another. A blend mode has no cell-lane meaning and sub-cell position does not exist in a grid of characters. The calculus is parameterised over a property algebra per lane, so lanes share an algebra and share no stylesheet |
| **Shape.** A design feature arrives as primitives plus tools that harness them | No arc under the goal ships a display engine, a style engine, a layout engine or a toolkit. [[goals/display]] states its three checkable consequences and [[arcs/display-calculus-arc]]'s `kind` column is where a row declares which half it is |

The fourth item is a fork rather than a directive and holds its own row above:
whether [[arcs/native-document-arc]] merges into the display goal.

**A fifth item, found by the C01 EXAMPLE audit, is also a fork and is recorded
rather than resolved.** `docs/banks/text.md:75-77` states `d-tag`'s carried
key as a face-registry key rather than a which-of-N, open by design, which is
what lets an address ride on rendered output at zero width. That open keyspace
is shard G's home ([[banks/text]] §2, the stable address, BA-20/BA-21). C1's
central move is closing it: `Role` becomes a closed sum. Either `Role` gains a
constructor an address can occupy, or shard G's open keyspace stops existing
once C1 lands. `.planning/DISPLAY-LAYER-GAP.md` §5 D10 carries the exact quote
and the decision-tier detail.

**A sixth item, raised by the C1C2 example and its audit, extends a standing
row instead of opening a new one.** The row is *Which suite phase number a new
gate takes*, in the table above. The display tier now supplies its own instance
and the instance sharpens the cost.

Measured 2026-09-04, in this tree. Phase 7's root census is
`grep -rl '^(def compile-main' lib prog` (`tools/test/run-tests.sh:175`), so it
stops short of `tools/`. Phase 2's manifest is six named roots under
`prog/samples/` (`prog/test-runner.prog:40-46`), a bundled list rather than a
directory walk. So a gate root landing under `tools/test/samples/` is reached by
one thing only: a script naming it as its `FIXTURE`. A script carrying no
`run_phase` line runs when a person types its name and at no other time.

`docs/examples/C1C2-style-round-trip.md` takes the `crypto.sh` and
`tal-check.sh` route: a `# not-a-phase: <reason>` declaration, outside the suite
total, run directly. That keeps `tools/test/registration.sh` G2 green and prices
the element honestly as shipping a hand-run gate. What it does not do is make
the standing call cheaper. Three scripts already wait on one number
(`crypto.sh:6`, `tal-check.sh:11`, `apply-word.sh:5`), C1C2's would be the
fourth, and `display-calculus/C1` and `C2` would then join E185 in landing
conformance the suite does not execute. Measured the same day: 13 `run_phase`
lines against 20 scripts under `tools/test/`, 7 of them printed as `PEND`.

The fork is unchanged and no new one is opened here. 8 through 12 stay owed to
unported old-tree phases. 21 through 23 are contested by the four documents the
standing row names.
