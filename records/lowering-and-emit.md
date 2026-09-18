---
node: records-lowering-and-emit
layer: navigation
related: [records/README, arcs/lowering-and-emit-arc, goals/self-hosting, status-ledger, index]
status: current
updated: 2026-09-18
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
