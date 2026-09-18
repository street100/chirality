---
node: records-checker-core
layer: navigation
related: [records/README, arcs/checker-core-arc, goals/self-hosting, status-ledger, index]
status: current
updated: 2026-09-18
---

# Checker core arc

Every row is a claim [[arcs/checker-core-arc]] makes, beside what was measured
against it. The prefix is `CK`. [[records/README]] fixes the six fields and the
rule that a row whose `checked:` date predates the last change to the files it
cites is unverified.

### CK-01 the arc's unanchored FLAG was discharged by the goal edit it asked for

- state:    FIXED
- claim:    `docs/arcs/checker-core-arc.md:394-407` read that this arc is unanchored on the `arc -> goal done-condition` rung, that `docs/goals/self-hosting.md` conditions 4 and 5 name `[[arcs/sys-face-arc]]` and nothing else, and that the goal edit naming this arc is owed.
- measured: the goal side moved. `749ce10` landed the edit: condition 4 at `docs/goals/self-hosting.md:62-64` names `[[arcs/checker-core-arc]]` with the requirements carrying it, and the subject-arc table at `:102-107` carries this arc's row opened with 18 elements. `python3 tools/lens/lens.py chain` reads `arc -> goal done-condition` at 37 of 37 on 2026-09-18, where the FLAG recorded 34 of 35. The four internal spans the FLAG cited, `:62-64`, `:71-73`, `:88-89` and `:104-108`, pointed into the pre-edit goal and two of them now land elsewhere, so the FLAG was carrying dead line numbers as well as a dead claim. The one half that stands is the `⚑` at `docs/goals/self-hosting.md:124`: `docs/goals/README.md:48` still reads *"none open, and see Rules"* for this goal, true of conditions 1 to 3 and false of 4 and 5.
- evidence: docs/arcs/checker-core-arc.md:394-407, docs/goals/self-hosting.md:62-64, :102-107, :124, docs/goals/README.md:48, tools/lens/lens.py:255
- checked:  2026-09-18
- element:  none. The verdict is AMEND and the correction is in place at `docs/arcs/checker-core-arc.md:394-407`
