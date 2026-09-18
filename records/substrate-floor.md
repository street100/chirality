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

### SU-02 the `E20` author call was answered and the arc's five open-call spans moved

- state:    FIXED
- claim:    `docs/arcs/substrate-floor-arc.md` read the surviving W^X element as an unanswered author call in five places at `26e6b03^`. `:99` said what is absent is the name of the element the surviving W^X work belongs to; `:111`'s `S2 to S1` edge called the question open; `:178`'s `SU1` stood `built` and `bind`, quoted `docs/elements/catalog.md:126` as reading `BUILT native and no longer a loader`, carried the call verbatim as its blocking condition, and said the mechanism is `E132`'s and [[arcs/runtime-loading-arc]] holds it; `:303-333`'s FLAG said this run does not take the call and quoted the `E20` ledger cell verbatim at length; `:331` said the W^X mechanism is `E132`'s, rostered by [[arcs/runtime-loading-arc]].
- measured: the author side moved and the arc followed. `records/author-calls.md:100` was ruled 2026-09-18: `E20` survives as the typed W^X seal, `MapRW` sealed to `MapRX`, with module cell `loader` to `map-seal` and ledger state `built` to `design`. The measurement that settles it is the prot the entry stub's `mprotect` passes, `3` for `PROT_READ`+`PROT_WRITE` and no `PROT_EXEC`, at `lib/lowering/compile-emit.chiral:87`, so the stub's `mmap`/`mprotect` pair is `SU3`'s reserve-commit and makes no W→X transition. Three carriers had landed before this run: `docs/elements/ledger.md:162` and `:465` at `a4d98ce`, `docs/elements/catalog.md:126` at `b53a1f3`, and `docs/examples/INDEX.md:68` at `53502a8`. The arc moved at `26e6b03`: `SU1` goes `built` to `open` and `bind` to `new`, its blocking condition reads none, the stale catalog quote and the verbatim ledger quote are gone, and the `E132` mechanism sentence is replaced by the ruling. Four further spans followed the state change in the same commit: the coverage count at `:205` from fourteen and two to thirteen and three, the origin bullets at `:214`, the check AH arithmetic at `:444-448`, and the census at `:466-472`, where `E20` joins `E22` and `E41` as `design`. `SU15` and `SU16` are untouched, because their blocking condition is `records/author-calls.md:85`, a different call, still `unreviewed`. ⚑ **Check U cleared on this file and the run total did not fall.** Before: 180 violations, 18 element homes owed, 30 author calls owed, 159 lens rulings owed, 2 checks that checked nothing, with one `[U]` at `substrate-floor-arc.md:304`. After: the same five figures, `[U]` at zero, and one new `[F]` on `docs/elements/specs/E200-coverage-composite-one-span-write-SPEC.md:63`, an untracked file another session created at 15:13 on 2026-09-18 carrying a dangling wiki link. This run's delta is −1 and the concurrent session's is +1, which a third run settles rather than infers: that session repaired its own link and the total then read 179 with every other figure unchanged. ⚑ **The second stale quote was invisible to the lint.** `:178` quoted the catalog cell and check U never raised it: the pattern at `tools/ledger-lint/ledger-lint.py:1273` requires the closing backtick immediately after the file extension, so a quote hung off a citation that carries its line number never matches. Fixing only what the lint reported would have left `:178` stale. The defect is recorded in `records/homing-triage.md:467` §Known tool defects at `207f68a`.
- evidence: docs/arcs/substrate-floor-arc.md:99, :111, :178, :205, :214, :273, :311-341, :435-450, :466-472; records/author-calls.md:100, :85; lib/lowering/compile-emit.chiral:87; docs/elements/ledger.md:162, :465; docs/elements/catalog.md:126; docs/examples/INDEX.md:68; tools/ledger-lint/ledger-lint.py:1273, :1805-1806; records/homing-triage.md:467
- checked:  2026-09-18
- element:  none. The verdict is AMEND and the correction is in place at `26e6b03`. The unbuilt work the ruling leaves is `E20`'s, and `substrate-floor/SU1` holds it at `open`. Ten of the ruling's thirteen carriers are unmoved and each is its own dispatch
