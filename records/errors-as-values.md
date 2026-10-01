---
node: records-errors-as-values
layer: navigation
related: [records/README, arcs/errors-as-values-arc, bug-classes, goals/readable-surface, goals/enforcement, records/lenses/unspoken, index]
status: current
updated: 2026-10-01
---

# Errors-as-values arc

Every row is a claim [[arcs/errors-as-values-arc]] makes, beside what was
measured against it. The prefix is `ER`. [[records/README]] fixes the six fields
and the rule that a row whose `checked:` date predates the last change to the
files it cites is unverified.

The file opens with `ER-01`. The arc's header promised a record with its first
adoption row, and the revisit below is the first run that owed one, so the file
is created by the run that needed it, as [[records/text-tools]] was.

### ER-01 the arc takes the author's three principles, and principle 1 has four sides where the arc covered two

- state:    FIXED
- claim:    [[arcs/errors-as-values-arc]] served [[goals/readable-surface]] conditions 2 and 1 with five requirements about one carrier, its combinators and its classification. Nothing in it said that a program fails to compile while a detectable error goes unhandled. Its requirements covered an error produced as a declared sum and fed back with evidence, and left two sides unstated: an error held in band as a value of the success type, and an error dropped or escaping a boundary.
- measured: **RESCOPE.** Trigger: the author's direction in session on 2026-10-01, verbatim, *"doesnt compile until the errors we can detect are handled"*, *"feedback is great even if tests arent thorough (because tests should be for logic bugs anyway"*, *"error handling is made more convenient/straightforward for all cases we can detect"*, and *"these three need to be principle goals of error handling arc"*. **The arc moved.** The three become its principles, each row serving at least one. Principle 1 reads as four sides: produced, ruled out, consumed, fed back. Two sides had no requirement: requirement 2 widens to errors held in band (`open-rw`'s `fd | -errno` in one `I64`, `lib/ports/file.port:14`; `str->i64`'s junk to 0, `lib/prelude/prelude.chiral:150`), and requirement 6 opens for an error dropped or escaping. Rows `EV13` (linear error arm), `EV14` (in-band census), `EV15` (typed refusals kept past `lib/surface/parse.chiral:580` and `:673`) and `EV16` (alarm discharged before a profile boundary, paired with `enforcement/N25`) open. The ruled-out side stays [[arcs/enforcement-arc]]'s. The goal line adds [[goals/enforcement]] conditions 1 and 2. How a program's logic tests are required is left to `records/lenses/unspoken.md` UNS-52.
- evidence: docs/arcs/errors-as-values-arc.md:11-17 (goal line), :53-88 (`## The three principles`), :158-166 (requirement 2), :183-187 (requirement 6), :209-212 (`EV13` to `EV16`), the coverage block, :240-248 (resume state); lib/ports/file.port:14; lib/prelude/prelude.chiral:150; lib/surface/parse.chiral:580, :673; lib/module/load-batch.chiral:81
- checked:  2026-10-01
- element:  `errors-as-values/EV13` to `EV16`, all `open`, `unminted`, next stage `element-design`; `EV13` beside `EV1`. No element minted, nothing under `lib/` or `prog/` changed.
