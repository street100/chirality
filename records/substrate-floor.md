---
node: records-substrate-floor
layer: navigation
related: [records/README, arcs/substrate-floor-arc, records/lenses/unspoken, goals/self-hosting, status-ledger, index]
status: current
updated: 2026-09-18
---

# Substrate floor arc

Every row is a claim [[arcs/substrate-floor-arc]] makes, beside what was
measured against it. The prefix is `SU`. [[records/README]] fixes the six fields
and the rule that a row whose `checked:` date predates the last change to the
files it cites is unverified.

### SU-01 the arc's UNS-01 and UNS-07 FLAG was discharged by the rows it named

- state:    FIXED
- claim:    `docs/arcs/substrate-floor-arc.md:390-399` read that `records/lenses/unspoken.md` UNS-01 and UNS-07 both stand at `open` with `author: unreviewed`, that both are owed a state change and a `checked:` date now that `SU15` and `SU16` home `E22` and `E41`, and that UNS-01 carries a false measurement.
- measured: both rows moved, and the arc's claim about their state is false at HEAD. `records/lenses/unspoken.md:5` reads `state: ruled` for UNS-01 and `:89` reads the same for UNS-07, each with `author: ruled 2026-09-10`, `checked: 2026-09-18` and an `owner:` naming `substrate-floor/SU15` and `substrate-floor/SU16`. The false measurement is corrected in place rather than deleted: UNS-01 keeps *"no file in docs/arcs/ names E22"* and appends that `docs/arcs/memory-discipline-arc.md:26` and `:39` name it, so the field was already false when written. The FLAG named UNS-01 alone as the false one and both halves of its state claim were wrong by the time it was read.
- evidence: docs/arcs/substrate-floor-arc.md:390-399, records/lenses/unspoken.md:5, :89, docs/arcs/memory-discipline-arc.md:26, :39
- checked:  2026-09-18
- element:  none. The verdict is AMEND and the correction is in place at `docs/arcs/substrate-floor-arc.md:390-399`
