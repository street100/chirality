---
node: records-sys-face
layer: navigation
related: [records/README, arcs/sys-face-arc, goals/self-hosting, status-ledger, index]
status: current
updated: 2026-09-18
---

# Sys-face arc

Every row is a claim [[arcs/sys-face-arc]] makes, beside what was measured
against it. The prefix is `SF`. [[records/README]] fixes the six fields and the
rule that a row whose `checked:` date predates the last change to the files it
cites is unverified.

### SF-01 the arc's unanchored FLAG was discharged when the goal dropped "unopened"

- state:    FIXED
- claim:    `docs/arcs/sys-face-arc.md:339-347` read that this arc is unanchored on the `arc -> goal done-condition` rung because `docs/goals/self-hosting.md` condition 5 declared itself unopened, and that the goal owes conditions 4 and 5 the word dropped.
- measured: the word is gone. A grep for `unopened`, case-insensitive, over `docs/goals/self-hosting.md` returns nothing on 2026-09-18, condition 4 names `[[arcs/sys-face-arc]]` at `:63` and condition 5 names it at `:77` with its roster of nineteen elements. `tools/lens/lens.py:254` is unchanged and still suppresses a condition's arcs when the body says unopened, so the mechanism the FLAG described is live and its subject is gone. `python3 tools/lens/lens.py chain` reads `arc -> goal done-condition` at 37 of 37, where the FLAG recorded 33 of 34. The half that stands is the `⚑` at `docs/goals/self-hosting.md:124`: `docs/goals/README.md:48` still reads *"none open, and see Rules"* for this goal.
- evidence: docs/arcs/sys-face-arc.md:339-347, docs/goals/self-hosting.md:63, :77, :124, docs/goals/README.md:48, tools/lens/lens.py:254
- checked:  2026-09-18
- element:  none. The verdict is AMEND and the correction is in place at `docs/arcs/sys-face-arc.md:339-347`
