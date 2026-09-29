---
node: records-lowering-and-emit
layer: navigation
related: [records/README, arcs/lowering-and-emit-arc, goals/self-hosting, goals/emitted-speed, status-ledger, index]
status: current
updated: 2026-09-29
---

# Lowering and emit arc

Every row is a claim [[arcs/lowering-and-emit-arc]] makes, beside what was
measured against it. The prefix is `LE`. [[records/README]] fixes the six fields
and the rule that a row whose `checked:` date predates the last change to the
files it cites is unverified.

### LE-01 the arc's unanchored FLAG was discharged by the goal edit it asked for

- state:    FIXED
- claim:    `docs/arcs/lowering-and-emit-arc.md:406-418` read that this arc is unanchored on the `arc -> goal done-condition` rung, that `docs/goals/self-hosting.md` conditions 4 and 5 name `[[arcs/sys-face-arc]]` and nothing else, and that four goal edits are owed: the conditions naming this arc, the table row opened at 23 elements, the "other three subject arcs" sentences reduced, and the honest limit's 39 corrected.
- measured: every one of the four landed at `749ce10`. Condition 4 at `docs/goals/self-hosting.md:62-64` names `[[arcs/lowering-and-emit-arc]]` with the requirements carrying it, the subject-arc table at `:102-107` carries this arc's row opened with 23 elements, and `:173` marks the honest limit that read *"39 of the compiler's own built elements hold no roster row"* as corrected in place. `python3 tools/lens/lens.py chain` reads `arc -> goal done-condition` at 37 of 37 on 2026-09-18, where the FLAG recorded 34 of 35. The FLAG's own spans `:91-96` and `:104-108` point into the pre-edit goal and land elsewhere now. The half that stands is the `⚑` at `docs/goals/self-hosting.md:124`: `docs/goals/README.md:48` still reads *"none open, and see Rules"* for this goal.
- evidence: docs/arcs/lowering-and-emit-arc.md:406-418, docs/goals/self-hosting.md:62-64, :102-107, :124, :173, docs/goals/README.md:48
- checked:  2026-09-18
- element:  none. The verdict is AMEND and the correction is in place at `docs/arcs/lowering-and-emit-arc.md:406-418`

### LE-02 the W^X question the arc routed to `E132` is `E34`'s own wanted

- state:    FIXED
- claim:    `docs/arcs/lowering-and-emit-arc.md:215`, the `E34` roster row `lowering-and-emit/LE15`, read *"The W^X question is `E132`'s, rostered by [[arcs/runtime-loading-arc]], and this row states the segment flags without asking them to change"*, and the arc's *What this arc does not take* repeated it at `:295-298` as `LE15` asking for no change to the flags.
- measured: the artifact's side moved. `records/author-calls.md:100` ruled 2026-09-18 that the static-ELF segment split is `E34`'s, carried as a wanted on this row, minting nothing: this arc at `:197` and `docs/arcs/substrate-floor-arc.md:173` each declare their arc allocates no number, and a second RW `PT_LOAD` at the code-off page boundary sits inside ELF / executable format as `E34` already defines it. The emitter says the same in its own comment: `lib/lowering/x64/elf.chiral:59-64` calls the split *"the named W^X follow-on (needs code-off page alignment)"* while `:70` writes `p_flags` `7`. `docs/arcs/runtime-loading-arc.md:208-212` already refuses the split on the other side and names this row as its carrier. Both spans are corrected in place and marked. Two things did not move: `LE15` stays `built` on `E34`, because the element is built and the split is owed work stated on a built row, and no element mints. The arc's requirement 4 at `:174` reads *"`E34`'s own header says `RX` against the `RWX` its code writes"*, which is a separate claim and was re-tested rather than assumed: `lib/lowering/x64/elf.chiral:6` still says *"one 56-byte RX PT_LOAD"* against `:60` and `:70`, so it stands unedited.
- evidence: docs/arcs/lowering-and-emit-arc.md:215, :295-302, :174, :197, records/author-calls.md:100, lib/lowering/x64/elf.chiral:6, :59-64, :70, docs/arcs/substrate-floor-arc.md:173, docs/arcs/runtime-loading-arc.md:208-212
- checked:  2026-09-18
- element:  none. The verdict is AMEND and both corrections are in place at `docs/arcs/lowering-and-emit-arc.md:215` and `:295-302`. The typed seal stays `E20`, `design` at `docs/elements/ledger.md:162`

### LE-03 the compiler's own pass work had no roster row, and this arc takes it

- state:    FIXED
- claim:    `docs/arcs/lowering-and-emit-arc.md` served [[goals/self-hosting]] alone, refused [[goals/emitted-speed]] in its `goals:` field, and stated six requirements over reach, closure, identity, state claims, the label space and a second instrument. None reached what a compile spends inside the passes this arc rosters.
- measured: the artifact's side moved. `.planning/LANGUAGE-PROFILE-2026-09.md` (`2131616`) measured a self-compile at 0.81 s and 385 MB on HEAD `96f40ee`, 56% of its self time a linear name scan by byte-wise `str-eq` inside this arc's passes, `ctor-tag` 13.8% inclusive, a second erase of every function at 70 ms and 29.0 MB, and an appending accumulator at 28.0 MB; it found a closed constant rebuilt per reference and no reachability prune, and gave six of its twelve fixes no owning row. The verdict is RESCOPE: requirement 7 is added, tied to [[goals/emitted-speed]] condition 4 over `bin/chirality-bin` short of that condition's owed budget, and rows `LE25` to `LE30` are drawn `open` and `unminted`, one per profile item 1, 2, 3, 4, 9 and 12. `LE25` to `LE28` move no emitted byte and carry the BUILD RULE as their whole check; `LE29` waits on `enforcement/N23`; `LE30` moves emitted bytes and falls outside the rewrites `opt-tfns` adopts. Items 5, 8 and 11 stay with `emitted-speed`, 6 with `text-tools`, 7 with `memory-discipline/M4` and 10 with `memory-discipline/M2`. Two things did not move: the first six requirements and rows `LE1` to `LE24`. [[goals/emitted-speed]] condition 4 still reads *"Unopened, and it holds no arc file"* at `docs/goals/emitted-speed.md:98`, which this run does not edit.
- evidence: docs/arcs/lowering-and-emit-arc.md:21-33, :121-126, :147, :158-159, :217-232, :267-272, :337-347, .planning/LANGUAGE-PROFILE-2026-09.md §"Ranked language fixes", docs/goals/emitted-speed.md:92-104
- checked:  2026-09-29
- element:  none. The verdict is RESCOPE and the six rows it drew carry `unminted`
